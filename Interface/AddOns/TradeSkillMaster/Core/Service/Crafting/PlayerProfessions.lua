-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local PlayerProfessions = TSM.Crafting:NewPackage("PlayerProfessions")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = { playerProfessionsThread = nil, db = nil, query = nil }
local DB_SCHEMA = {
	fields = {
		player = "string",
		profession = "string",
		level = "number",
		maxLevel = "number",
		isSecondary = "boolean",
	}
}



-- ============================================================================
-- Module Functions
-- ============================================================================

function PlayerProfessions.OnInitialize()
	private.db = TSMAPI_FOUR.Database.New(DB_SCHEMA)
	private.query = private.db:NewQuery()
	private.playerProfessionsThread = TSMAPI_FOUR.Thread.New("PLAYER_PROFESSIONS", private.PlayerProfessionsThread)
	private.StartPlayerProfessionsThread()
	TSMAPI_FOUR.Event.Register("LEARNED_SPELL_IN_TAB", private.StartPlayerProfessionsThread)
end

function PlayerProfessions.GetQuery()
	private.query:Reset()
	return private.query
end



-- ============================================================================
-- Player Professions Thread
-- ============================================================================

function private.StartPlayerProfessionsThread()
	if private.playerProfessionsThreadRunning then
		TSMAPI_FOUR.Thread.Kill(private.playerProfessionsThread)
	end
	private.playerProfessionsThreadRunning = true
	TSMAPI_FOUR.Thread.Start(private.playerProfessionsThread)
end

function private.PlayerProfessionsThread()
	local playerName = UnitName("player")
	local playerProfessions = TSM.db.factionrealm.internalData.playerProfessions[playerName] or {}
	TSM.db.factionrealm.internalData.playerProfessions[playerName] = playerProfessions

	-- get the player's tradeskills
	SpellBook_UpdateProfTab()
	local forgetProfession = TSMAPI_FOUR.Thread.AcquireSafeTempTable()
	for name in pairs(playerProfessions) do
		forgetProfession[name] = true
	end
	TSMAPI_FOUR.Thread.WaitForFunction(GetProfessions)
	local professionIds = TSMAPI_FOUR.Thread.AcquireSafeTempTable(GetProfessions())
	-- ignore archeology and fishing which are in the 3rd and 4th slots respectively
	professionIds[3] = nil
	professionIds[4] = nil
	for i, id in pairs(professionIds) do -- needs to be pairs since there might be holes
		local name, _, level, maxLevel = TSMAPI_FOUR.Thread.WaitForFunction(GetProfessionInfo, id)
		if not TSM.UI.CraftingUI.IsProfessionIgnored(name) then --exclude ignored professions
			forgetProfession[name] = nil
			local professionInfo = playerProfessions[name] or {}
			playerProfessions[name] = professionInfo
			-- preserve whether or not we've prompted to create groups and the profession link if possible
			local oldPrompted = professionInfo.prompted or nil
			local oldLink = professionInfo.link or nil
			wipe(professionInfo)
			professionInfo.level = level
			professionInfo.maxLevel = maxLevel
			professionInfo.isSecondary = i > 2
			professionInfo.prompted = oldPrompted
			professionInfo.link = oldLink
		end
	end
	TSMAPI_FOUR.Thread.ReleaseSafeTempTable(professionIds)
	for name in pairs(forgetProfession) do
		playerProfessions[name] = nil
	end
	TSMAPI_FOUR.Thread.ReleaseSafeTempTable(forgetProfession)

	-- clean up crafts which are no longer known
	local matUsed = TSMAPI_FOUR.Thread.AcquireSafeTempTable()
	local spellIds = TSMAPI_FOUR.Thread.AcquireSafeTempTable()
	for _, spellId in TSM.Crafting.SpellIterator() do
		tinsert(spellIds, spellId)
	end
	for _, spellId in ipairs(spellIds) do
		local playersToRemove = TSMAPI_FOUR.Util.AcquireTempTable()
		for _, player in TSMAPI_FOUR.Util.VarargIterator(TSM.Crafting.GetPlayers(spellId)) do
			-- check if the player still exists and still has this profession
			if not TSM.db.factionrealm.internalData.playerProfessions[player] or not TSM.db.factionrealm.internalData.playerProfessions[player][TSM.Crafting.GetProfession(spellId)] then
				tinsert(playersToRemove, player)
			end
		end
		local stillExists = true
		if #playersToRemove > 0 then
			stillExists = TSM.Crafting.RemovePlayers(spellId, playersToRemove)
		end
		TSMAPI_FOUR.Util.ReleaseTempTable(playersToRemove)
		if stillExists then
			for _, itemString in TSM.Crafting.MatIterator(spellId) do
				matUsed[itemString] = true
			end
		end
		TSMAPI_FOUR.Thread.Yield()
	end
	TSMAPI_FOUR.Thread.ReleaseSafeTempTable(spellIds)

	-- clean up mats which aren't used anymore
	local toRemove = TSMAPI_FOUR.Util.AcquireTempTable()
	for itemString, matInfo in pairs(TSM.db.factionrealm.internalData.mats) do
		-- clear out old names
		matInfo.name = nil
		if not matUsed[itemString] then
			tinsert(toRemove, itemString)
		end
	end
	TSMAPI_FOUR.Thread.ReleaseSafeTempTable(matUsed)
	for _, itemString in ipairs(toRemove) do
		TSM.db.factionrealm.internalData.mats[itemString] = nil
	end
	TSMAPI_FOUR.Util.ReleaseTempTable(toRemove)

	-- update our DB
	private.db:SetQueryUpdatesPaused(true)
	private.db:Truncate()
	for player, professions in pairs(TSM.db.factionrealm.internalData.playerProfessions) do
		for profession, info in pairs(professions) do
			private.db:NewRow()
				:SetField("player", player)
				:SetField("profession", profession)
				:SetField("level", info.level)
				:SetField("maxLevel", info.maxLevel)
				:SetField("isSecondary", info.isSecondary)
				:Save()
		end
	end
	private.db:SetQueryUpdatesPaused(false)

	private.playerProfessionsThreadRunning = false
end
