-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--          http://www.curse.com/addons/wow/tradeskillmaster_warehousing          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local GuildTracking = TSM.Inventory:NewPackage("GuildTracking")
local private = {
	isOpen = nil,
	lastUpdate = 0,
	pendingPetSlotIds = {},
	petSpeciesCache = {},
}
local PLAYER_NAME = UnitName("player")
local PLAYER_GUILD = nil
local SLOT_ID_TAB_MULTIPLIER = 1000
local MAX_PET_SCANS = 10
-- don't use MAX_GUILDBANK_SLOTS_PER_TAB since it isn't available right away
local GUILD_BANK_TAB_SLOTS = 98



-- ============================================================================
-- Module Functions
-- ============================================================================

function GuildTracking.OnEnable()
	TSMAPI_FOUR.Event.Register("GUILDBANKFRAME_OPENED", private.GuildBankFrameOpenedHandler)
	TSMAPI_FOUR.Event.Register("GUILDBANKFRAME_CLOSED", private.GuildBankFrameClosedHandler)
	TSMAPI_FOUR.Event.Register("GUILDBANKBAGSLOTS_CHANGED", private.GuildBankBagSlotsChangedHandler)
	TSMAPI_FOUR.Delay.AfterFrame(1, private.GetGuildName)
end



-- ============================================================================
-- Private Helper Functions
-- ============================================================================

function private.GetGuildName()
	if not IsInGuild() then
		TSM.db.factionrealm.internalData.characterGuilds[PLAYER_NAME] = nil
		return
	end
	PLAYER_GUILD = GetGuildInfo("player")
	if not PLAYER_GUILD then
		-- try again next frame
		TSMAPI_FOUR.Delay.AfterFrame(1, private.GetGuildName)
		return
	end

	TSM.db.factionrealm.internalData.characterGuilds[PLAYER_NAME] = PLAYER_GUILD

	-- clean up any guilds with no players in them
	local validGuilds = TSMAPI_FOUR.Util.AcquireTempTable()
	for _, character in TSM.db:FactionrealmCharacterByAccountIterator() do
		local guild = TSM.db.factionrealm.internalData.characterGuilds[character]
		if guild then
			validGuilds[guild] = true
		end
	end
	local toRemove = TSMAPI_FOUR.Util.AcquireTempTable()
	for character, guild in pairs(TSM.db.factionrealm.internalData.characterGuilds) do
		if not validGuilds[guild] then
			tinsert(toRemove, character)
		end
	end
	for _, character in ipairs(toRemove) do
		TSM.db.factionrealm.internalData.characterGuilds[character] = nil
	end
	wipe(toRemove)
	for guild in pairs(TSM.db.factionrealm.internalData.guildVaults) do
		if not validGuilds[guild] then
			tinsert(toRemove, guild)
		end
	end
	for _, guild in ipairs(toRemove) do
		TSM.db.factionrealm.internalData.guildVaults[guild] = nil
	end
	TSMAPI_FOUR.Util.ReleaseTempTable(toRemove)
	TSMAPI_FOUR.Util.ReleaseTempTable(validGuilds)
	TSM.db.factionrealm.internalData.guildVaults[PLAYER_GUILD] = TSM.db.factionrealm.internalData.guildVaults[PLAYER_GUILD] or {}
end

function private.GuildBankFrameOpenedHandler()
	local initialTab = GetCurrentGuildBankTab()
	for i = 1, GetNumGuildBankTabs() do
		QueryGuildBankTab(i)
	end
	QueryGuildBankTab(initialTab)
	private.isOpen = true
end

function private.GuildBankFrameClosedHandler()
	private.isOpen = nil
end

function private.GuildBankBagSlotsChangedHandler()
	private.lastUpdate = GetTime()
	TSMAPI_FOUR.Delay.AfterFrame("guildBankScan", 2, private.GuildBankChangedDelayed)
end

function private.GuildBankChangedDelayed()
	if not private.isOpen then
		return
	end
	if not PLAYER_GUILD then
		-- we don't have the guild name yet, so try again after a short delay
		TSMAPI_FOUR.Delay.AfterFrame("guildBankScan", 2, private.GuildBankChangedDelayed)
		return
	end
	private.ScanGuildBank()
end


function private.ScanGuildBank()
	local guildVaultItems = TSM.db.factionrealm.internalData.guildVaults[PLAYER_GUILD]
	wipe(guildVaultItems)
	wipe(private.pendingPetSlotIds)
	for tab = 1, GetNumGuildBankTabs() do
		-- only scan tabs which we have at least enough withdrawals to withdraw every slot
		local _, _, _, _, numWithdrawals = GetGuildBankTabInfo(tab)
		if numWithdrawals == -1 or numWithdrawals >= GUILD_BANK_TAB_SLOTS then
			for slot = 1, GUILD_BANK_TAB_SLOTS do
				local link = GetGuildBankItemLink(tab, slot)
				local itemString = TSMAPI_FOUR.Item.ToBaseItemString(link)
				if itemString == TSM.CONST.PET_CAGE_ITEMSTRING then
					if not private.petSpeciesCache[link] then
						-- defer the scanning of pets which we don't have cached info for
						private.pendingPetSlotIds[tab * SLOT_ID_TAB_MULTIPLIER + slot] = true
					end
					itemString = private.petSpeciesCache[link] and ("p:" .. private.petSpeciesCache[link])
				end
				if itemString then
					guildVaultItems[itemString] = (guildVaultItems[itemString] or 0) + select(2, GetGuildBankItemInfo(tab, slot))
				end
			end
		end
	end
	if next(private.pendingPetSlotIds) then
		TSMAPI_FOUR.Delay.AfterFrame("guildBankPetScan", 2, private.ScanPetsDeferred)
	else
		TSMAPI_FOUR.Delay.Cancel("guildBankPetScan")
	end
end

function private.ScanPetsDeferred()
	local guildVaultItems = TSM.db.factionrealm.internalData.guildVaults[PLAYER_GUILD]
	local numPetSlotIdsScanned = 0
	local toRemove = TSMAPI_FOUR.Util.AcquireTempTable()
	for slotId in pairs(private.pendingPetSlotIds) do
		local tab, slot = floor(slotId / SLOT_ID_TAB_MULTIPLIER), slotId % SLOT_ID_TAB_MULTIPLIER
		local link = GetGuildBankItemLink(tab, slot)
		private.petSpeciesCache[link] = GameTooltip:SetGuildBankItem(tab, slot)
		local itemString = private.petSpeciesCache[link] and ("p:" .. private.petSpeciesCache[link])
		if itemString then
			tinsert(toRemove, slotId)
			guildVaultItems[itemString] = (guildVaultItems[itemString] or 0) + select(2, GetGuildBankItemInfo(tab, slot))
		end
		-- throttle how many pet slots we scan per call (regardless of whether or not it was successful)
		numPetSlotIdsScanned = numPetSlotIdsScanned + 1
		if numPetSlotIdsScanned == MAX_PET_SCANS then
			break
		end
	end
	TSM:LOG_INFO("Scanned %d pet slots", numPetSlotIdsScanned)
	for _, slotId in ipairs(toRemove) do
		private.pendingPetSlotIds[slotId] = nil
	end
	TSMAPI_FOUR.Util.ReleaseTempTable(toRemove)

	if next(private.pendingPetSlotIds) then
		-- there are more to scan
		TSMAPI_FOUR.Delay.AfterFrame("guildBankPetScan", 2, private.ScanPetsDeferred)
	end
end
