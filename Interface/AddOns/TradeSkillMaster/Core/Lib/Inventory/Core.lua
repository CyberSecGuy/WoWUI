-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

--- Inventory TSMAPI_FOUR Functions
-- @module Inventory

TSMAPI_FOUR.Inventory = {}
local _, TSM = ...
local Inventory = TSM:NewPackage("Inventory")
local private = {}
local PLAYER_NAME = UnitName("player")


-- ============================================================================
-- TSMAPI Functions
-- ============================================================================

--- Check if an item will go in a bag.
-- @tparam string link The item
-- @tparam number bag The bag index
-- @treturn boolean Whether or not the item will go in the bag
function TSMAPI_FOUR.Inventory.ItemWillGoInBag(link, bag)
	if not link or not bag then
		return
	end
	if bag == 0 then
		return true
	end
	local itemFamily = GetItemFamily(link)
	local _, bagFamily = GetContainerNumFreeSlots(bag)
	if not bagFamily then
		return
	end
	return bagFamily == 0 or bit.band(itemFamily, bagFamily) > 0
end

function TSMAPI_FOUR.Inventory.GetBagQuantity(itemString, character, factionrealm)
	return private.InventoryQuantityHelper(itemString, "bagQuantity", character, factionrealm)
end

function TSMAPI_FOUR.Inventory.GetBankQuantity(itemString, character, factionrealm)
	return private.InventoryQuantityHelper(itemString, "bankQuantity", character, factionrealm)
end

function TSMAPI_FOUR.Inventory.GetReagentBankQuantity(itemString, character, factionrealm)
	return private.InventoryQuantityHelper(itemString, "reagentBankQuantity", character, factionrealm)
end

function TSMAPI_FOUR.Inventory.GetAuctionQuantity(itemString, character, factionrealm)
	return private.InventoryQuantityHelper(itemString, "auctionQuantity", character, factionrealm)
end

function TSMAPI_FOUR.Inventory.GetMailQuantity(itemString, character, factionrealm)
	itemString = TSMAPI_FOUR.Item.ToBaseItemString(itemString)
	character = character or PLAYER_NAME
	local pendingQuantity = itemString and TSM.db.factionrealm.internalData.pendingMail[character] and TSM.db.factionrealm.internalData.pendingMail[character][itemString] or 0
	return private.InventoryQuantityHelper(itemString, "mailQuantity", character, factionrealm) + pendingQuantity
end

function TSMAPI_FOUR.Inventory.GetGuildQuantity(itemString, guild)
	itemString = TSMAPI_FOUR.Item.ToBaseItemString(itemString)
	if not itemString then
		return 0
	end
	guild = guild or (IsInGuild() and GetGuildInfo("player") or nil)
	if not guild or TSM.db.factionrealm.coreOptions.ignoreGuilds[guild] then
		return 0
	end
	return TSM.db.factionrealm.internalData.guildVaults[guild] and TSM.db.factionrealm.internalData.guildVaults[guild][itemString] or 0
end

function TSMAPI_FOUR.Inventory.GetPlayerTotals(itemString)
	local numPlayer, numAlts, numAuctions, numAltAuctions = 0, 0, 0, 0
	for factionrealm in TSM.db:GetConnectedRealmIterator("factionrealm") do
		for _, character in TSM.db:FactionrealmCharacterIterator(factionrealm) do
			if character == PLAYER_NAME and factionrealm == UnitFactionGroup("player").." - "..GetRealmName() then
				numPlayer = numPlayer + TSMAPI_FOUR.Inventory.GetBagQuantity(itemString)
				numPlayer = numPlayer + TSMAPI_FOUR.Inventory.GetBankQuantity(itemString)
				numPlayer = numPlayer + TSMAPI_FOUR.Inventory.GetReagentBankQuantity(itemString)
				numPlayer = numPlayer + TSMAPI_FOUR.Inventory.GetMailQuantity(itemString)
			else
				numPlayer = numPlayer + TSMAPI_FOUR.Inventory.GetBagQuantity(itemString, character, factionrealm)
				numPlayer = numPlayer + TSMAPI_FOUR.Inventory.GetBankQuantity(itemString, character, factionrealm)
				numPlayer = numPlayer + TSMAPI_FOUR.Inventory.GetReagentBankQuantity(itemString, character, factionrealm)
				numPlayer = numPlayer + TSMAPI_FOUR.Inventory.GetMailQuantity(itemString, character, factionrealm)
				numAltAuctions = numAltAuctions + TSMAPI_FOUR.Inventory.GetAuctionQuantity(itemString, character, factionrealm)
			end
			numAuctions = numAuctions + TSMAPI_FOUR.Inventory.GetAuctionQuantity(itemString, character, factionrealm)
		end
	end
	return numPlayer, numAlts, numAuctions, numAltAuctions
end

function TSMAPI_FOUR.Inventory.GetGuildTotal(itemString)
	itemString = TSMAPI_FOUR.Item.ToBaseItemString(itemString)
	if not itemString then
		return 0
	end
	local numGuild = 0
	for guild, data in pairs(TSM.db.factionrealm.internalData.guildVaults) do
		if not TSM.db.factionrealm.coreOptions.ignoreGuilds[guild] then
			numGuild = numGuild + (data[itemString] or 0)
		end
	end
	return numGuild
end

function TSMAPI_FOUR.Inventory.GetTotalQuantity(itemString)
	itemString = TSMAPI_FOUR.Item.ToBaseItemString(itemString)
	if not itemString then
		return 0
	end
	local numPlayer, numAlts, numAuctions = TSMAPI_FOUR.Inventory.GetPlayerTotals(itemString)
	local numGuild = TSMAPI_FOUR.Inventory.GetGuildTotal(itemString)
	return numPlayer + numAlts + numAuctions + numGuild
end

function TSMAPI_FOUR.Inventory.GetCraftingTotals(ignoreCharacters, otherItems)
	local bagTotal, auctionTotal, otherTotal, total = {}, {}, {}, {}

	for factionrealm in TSM.db:GetConnectedRealmIterator("factionrealm") do
		for _, character in TSM.db:FactionrealmCharacterIterator(factionrealm) do
			if not ignoreCharacters[character] then
				for itemString, quantity in pairs(private.GetCharacterInventoryData("bagQuantity", character, factionrealm)) do
					if character == PLAYER_NAME then
						bagTotal[itemString] = (bagTotal[itemString] or 0) + quantity
						total[itemString] = (total[itemString] or 0) + quantity
					else
						otherTotal[itemString] = (otherTotal[itemString] or 0) + quantity
						total[itemString] = (total[itemString] or 0) + quantity
					end
				end
				for itemString, quantity in pairs(private.GetCharacterInventoryData("bankQuantity", character, factionrealm)) do
					otherTotal[itemString] = (otherTotal[itemString] or 0) + quantity
					total[itemString] = (total[itemString] or 0) + quantity
				end
				for itemString, quantity in pairs(private.GetCharacterInventoryData("reagentBankQuantity", character, factionrealm)) do
					if character == PLAYER_NAME then
						if otherItems[itemString] then
							otherTotal[itemString] = (otherTotal[itemString] or 0) + quantity
						else
							bagTotal[itemString] = (bagTotal[itemString] or 0) + quantity
						end
					else
						otherTotal[itemString] = (otherTotal[itemString] or 0) + quantity
					end
					total[itemString] = (total[itemString] or 0) + quantity
				end
				for itemString, quantity in pairs(private.GetCharacterInventoryData("mailQuantity", character, factionrealm)) do
					otherTotal[itemString] = (otherTotal[itemString] or 0) + quantity
					total[itemString] = (total[itemString] or 0) + quantity
				end
				for itemString, quantity in pairs(private.GetCharacterInventoryData("auctionQuantity", character, factionrealm)) do
					auctionTotal[itemString] = (auctionTotal[itemString] or 0) + quantity
					total[itemString] = (total[itemString] or 0) + quantity
				end
			end
		end
	end

	for player, data in pairs(TSM.db.factionrealm.internalData.pendingMail) do
		for itemString, quantity in pairs(data) do
			otherTotal[itemString] = (otherTotal[itemString] or 0) + quantity
			total[itemString] = (total[itemString] or 0) + quantity
		end
	end

	for guild, data in pairs(TSM.db.factionrealm.internalData.guildVaults) do
		if not TSM.db.factionrealm.coreOptions.ignoreGuilds[guild] then
			for itemString, quantity in pairs(data) do
				otherTotal[itemString] = (otherTotal[itemString] or 0) + quantity
				total[itemString] = (total[itemString] or 0) + quantity
			end
		end
	end

	return bagTotal, auctionTotal, otherTotal, total
end



-- ============================================================================
-- Private Helper Functions
-- ============================================================================

function private.GetCharacterInventoryData(settingKey, character, factionrealm)
	assert(PLAYER_NAME)
	local scopeKey = character and character ~= PLAYER_NAME and TSM.db:GetSyncScopeKeyByCharacter(character, factionrealm) or nil
	return TSM.db:Get("sync", scopeKey, "internalData", settingKey)
end

function private.InventoryQuantityHelper(itemString, settingKey, character, factionrealm)
	itemString = TSMAPI_FOUR.Item.ToBaseItemString(itemString)
	if not itemString then
		return 0
	end
	return private.GetCharacterInventoryData(settingKey, character, factionrealm)[itemString] or 0
end
