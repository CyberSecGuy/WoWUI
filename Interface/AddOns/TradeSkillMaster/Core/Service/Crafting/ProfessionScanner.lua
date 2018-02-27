-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local ProfessionScanner = TSM.Crafting:NewPackage("ProfessionScanner")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = { db = nil }
-- don't want to scan a bunch of times when the profession first loads so add a 10 frame debounce to update events
local SCAN_DEBOUNCE_FRAMES = 100
local RECIPE_DB_SCHEMA = {
	fields = {
		index = "number",
		spellId = "number",
		name = "string",
		categoryId = "number",
		difficulty = "string",
		rank = "number",
		numSkillUps = "number",
	},
	fieldAttributes = {
		index = { "unique" },
		spellId = { "unique" },
	}
}



-- ============================================================================
-- Module Functions
-- ============================================================================

function ProfessionScanner.OnInitialize()
	private.db = TSMAPI_FOUR.Database.New(RECIPE_DB_SCHEMA)
	TSMAPI_FOUR.Event.Register("TRADE_SKILL_CLOSE", private.OnTradeSkillClose)
	TSMAPI_FOUR.Event.Register("GARRISON_TRADESKILL_NPC_CLOSE", private.OnTradeSkillClose)
	TSMAPI_FOUR.Event.Register("TRADE_SKILL_DATA_SOURCE_CHANGED", private.OnTradeSkillUpdateEvent)
	TSMAPI_FOUR.Event.Register("TRADE_SKILL_LIST_UPDATE", private.OnTradeSkillUpdateEvent)
end

function ProfessionScanner.CreateQuery()
	return private.db:NewQuery()
end

function ProfessionScanner.GetRankBySpellId(spellId)
	local record = private.db:NewQuery()
		:Equal("spellId", spellId)
		:GetSingleResultAndRelease()
	return record and record:GetField("rank")
end

function ProfessionScanner.GetFirstSpellId()
	return private.db:NewQuery()
		:OrderBy("index", true)
		:GetFirstResultAndRelease()
		:GetField("spellId")
end



-- ============================================================================
-- Event Handlers
-- ============================================================================

function private.OnTradeSkillClose()
	TSMAPI_FOUR.Delay.Cancel("PROFESSION_SCAN_DELAY")
end

function private.OnTradeSkillUpdateEvent()
	local prevRecipeIds = TSMAPI_FOUR.Util.AcquireTempTable()
	local nextRecipeIds = TSMAPI_FOUR.Util.AcquireTempTable()
	local recipeLearned = TSMAPI_FOUR.Util.AcquireTempTable()
	local recipes = C_TradeSkillUI.GetFilteredRecipeIDs(TSMAPI_FOUR.Util.AcquireTempTable())
	local spellIdIndex = TSMAPI_FOUR.Util.AcquireTempTable()
	for index, spellId in ipairs(recipes) do
		-- There's a Blizzard bug where First Aid duplicates spellIds, so check that we haven't seen this before
		if not spellIdIndex[spellId] then
			spellIdIndex[spellId] = index
			local info = C_TradeSkillUI.GetRecipeInfo(spellId, TSMAPI_FOUR.Util.AcquireTempTable())
			if info.previousRecipeID then
				prevRecipeIds[spellId] = info.previousRecipeID
				nextRecipeIds[info.previousRecipeID] = spellId
			end
			recipeLearned[spellId] = info.learned
			TSMAPI_FOUR.Util.ReleaseTempTable(info)
		end
	end
	private.db:SetQueryUpdatesPaused(true)
	private.db:Truncate()
	for index, spellId in ipairs(recipes) do
		local hasHigherRank = nextRecipeIds[spellId] and recipeLearned[nextRecipeIds[spellId]]
		-- TODO: show unlearned recipes in the TSM UI
		-- There's a Blizzard bug where First Aid duplicates spellIds, so check that this is the right index
		if spellIdIndex[spellId] == index and recipeLearned[spellId] and not hasHigherRank then
			local info = C_TradeSkillUI.GetRecipeInfo(spellId, TSMAPI_FOUR.Util.AcquireTempTable())
			local rank = -1
			if prevRecipeIds[spellId] or nextRecipeIds[spellId] then
				rank = 1
				local tempSpellId = spellId
				while prevRecipeIds[tempSpellId] do
					rank = rank + 1
					tempSpellId = prevRecipeIds[tempSpellId]
				end
			end
			private.db:NewRow()
				:SetField("index", index)
				:SetField("spellId", spellId)
				:SetField("name", info.name)
				:SetField("categoryId", info.categoryID)
				:SetField("difficulty", info.difficulty)
				:SetField("rank", rank)
				:SetField("numSkillUps", info.difficulty == "optimal" and info.numSkillUps or 1)
				:Save()
			TSMAPI_FOUR.Util.ReleaseTempTable(info)
		end
	end
	TSMAPI_FOUR.Util.ReleaseTempTable(spellIdIndex)
	TSMAPI_FOUR.Util.ReleaseTempTable(recipes)
	TSMAPI_FOUR.Util.ReleaseTempTable(prevRecipeIds)
	TSMAPI_FOUR.Util.ReleaseTempTable(nextRecipeIds)
	TSMAPI_FOUR.Util.ReleaseTempTable(recipeLearned)
	private.db:SetQueryUpdatesPaused(false)

	TSMAPI_FOUR.Delay.Cancel("PROFESSION_SCAN_DELAY")
	TSMAPI_FOUR.Delay.AfterFrame("PROFESSION_SCAN_DELAY", SCAN_DEBOUNCE_FRAMES, private.ScanProfession)
end



-- ============================================================================
-- Profession Scan Thread
-- ============================================================================

function private.ScanProfession()
	if InCombatLockdown() then
		-- we are in combat so try again in a bit
		TSMAPI_FOUR.Delay.AfterFrame("PROFESSION_SCAN_DELAY", SCAN_DEBOUNCE_FRAMES, private.ScanProfession)
		return
	end
	local playerName = UnitName("player")
	local playerProfessions = TSM.db.factionrealm.internalData.playerProfessions[UnitName("player")]
	local _, professionName = C_TradeSkillUI.GetTradeSkillLine()

	-- check if we should scan this profession
	if not professionName or not playerProfessions or not playerProfessions[professionName] or not C_TradeSkillUI.IsTradeSkillReady() or C_TradeSkillUI.IsDataSourceChanging() then
		-- this is a transient state so we should try again
		TSMAPI_FOUR.Delay.AfterFrame("PROFESSION_SCAN_DELAY", SCAN_DEBOUNCE_FRAMES, private.ScanProfession)
		return
	elseif C_TradeSkillUI.IsNPCCrafting() or C_TradeSkillUI.IsTradeSkillLinked() or C_TradeSkillUI.IsTradeSkillGuild() then
		-- no point in trying again until something changes
		return
	end

	-- update the link for this profession
	playerProfessions[professionName].link = C_TradeSkillUI.GetTradeSkillListLink()

	-- scan all the recipes
	local query = private.db:NewQuery()
		:Select("spellId")
	local numFailed = 0
	for _, spellId in query:Iterator(true) do
		if not private.ScanRecipe(professionName, spellId) then
			numFailed = numFailed + 1
		end
	end
	query:Release()

	TSM:LOG_INFO("Scanned %s (failed to scan %d)", professionName, numFailed)
	if numFailed > 0 then
		-- didn't completely scan, so we'll try again
		TSMAPI_FOUR.Delay.AfterFrame("PROFESSION_SCAN_DELAY", SCAN_DEBOUNCE_FRAMES, private.ScanProfession)
	end
end

function private.ScanRecipe(professionName, spellId)
	-- get the links
	local itemLink = C_TradeSkillUI.GetRecipeItemLink(spellId)
	local spellLink = C_TradeSkillUI.GetRecipeLink(spellId)
	assert(itemLink and spellLink and strfind(spellLink, "enchant:"), "Invalid craft: "..tostring(spellId))

	-- get the itemString and craft name
	local itemString, craftName = nil, nil
	if strfind(itemLink, "enchant:") then
		-- result of craft is not an item
		itemString = TSM.CONST.ENCHANT_ITEM_STRINGS[spellId] or TSM.CONST.MASS_MILLING_RECIPES[spellId]
		if not itemString then
			-- we don't care about this craft
			return true
		end
		craftName = GetSpellInfo(spellId)
	elseif strfind(itemLink, "item:") then
		-- result of craft is item
		itemString = TSMAPI_FOUR.Item.ToItemString(itemLink)
		craftName = TSMAPI_FOUR.Item.GetName(itemLink)
	else
		error("Invalid craft: "..tostring(spellId))
	end
	if not itemString or not craftName then
		return false
	end

	-- get the result number
	local numResult = nil
	local isEnchant = professionName == GetSpellInfo(7411) and strfind(itemLink, "enchant:")
	if isEnchant then
		numResult = 1
	else
		local lNum, hNum = C_TradeSkillUI.GetRecipeNumItemsProduced(spellId)
		-- workaround for incorrect values returned for Temporal Crystal
		if spellId == 169092 and itemString == "i:113588" then
			lNum, hNum = 1, 1
		end
		-- workaround for incorrect values returned for new mass milling recipes
		if TSM.CONST.MASS_MILLING_RECIPES[spellId] then
			lNum, hNum = 8, 8.8
		end
		numResult = floor(((lNum or 1) + (hNum or 1)) / 2)
	end

	-- store general info about this recipe
	local hasCD = select(2, C_TradeSkillUI.GetRecipeCooldown(spellId)) and true or false
	TSM.Crafting.CreateOrUpdate(spellId, itemString, professionName, craftName, numResult, UnitName("player"), hasCD)

	-- get the mat quantities and add mats to our DB
	local matQuantities = TSMAPI_FOUR.Util.AcquireTempTable()
	local haveInvalidMats = false
	for i = 1, C_TradeSkillUI.GetRecipeNumReagents(spellId) do
		local matItemString = TSMAPI_FOUR.Item.ToItemString(C_TradeSkillUI.GetRecipeReagentItemLink(spellId, i))
		if not matItemString then
			haveInvalidMats = true
			break
		end
		local name, _, quantity = C_TradeSkillUI.GetRecipeReagentInfo(spellId, i)
		if not name or not quantity then
			haveInvalidMats = true
			break
		end
		TSM.ItemInfo.StoreItemName(matItemString, name)
		TSM.db.factionrealm.internalData.mats[matItemString] = TSM.db.factionrealm.internalData.mats[matItemString] or {}
		matQuantities[matItemString] = quantity
	end
	-- if this is an enchant, add a vellum to the list of mats
	if isEnchant then
		local matItemString = TSM.CONST.VELLUM_ITEM_STRING
		TSM.db.factionrealm.internalData.mats[matItemString] = TSM.db.factionrealm.internalData.mats[matItemString] or {}
		matQuantities[matItemString] = 1
	end

	if not haveInvalidMats then
		TSM.Crafting.SetMats(spellId, matQuantities)
	end
	TSMAPI_FOUR.Util.ReleaseTempTable(matQuantities)
	return not haveInvalidMats
end
