-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local SavedSearches = TSM.Shopping:NewPackage("SavedSearches")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = { db = nil }
local SAVED_SEARCHES_SCHEMA = {
	fields = {
		index = "number",
		name = "string",
		lastSearch = "number",
		isFavorite = "boolean",
		mode = "string",
		filter = "string",
	}
}



-- ============================================================================
-- Module Functions
-- ============================================================================

function SavedSearches.OnInitialize()
	-- remove duplicates
	local keepSearch = TSMAPI_FOUR.Util.AcquireTempTable()
	for i, data in ipairs(TSM.db.global.userData.savedShoppingSearches) do
		local filter = strlower(data.filter)
		if not keepSearch[filter] then
			keepSearch[filter] = data
		else
			if data.isFavorite == keepSearch[filter].isFavorite then
				if data.lastSearch > keepSearch[filter].lastSearch then
					keepSearch[filter] = data
				end
			elseif data.isFavorite then
				keepSearch[filter] = data
			end
		end
	end
	for i = #TSM.db.global.userData.savedShoppingSearches, 1, -1 do
		if not keepSearch[strlower(TSM.db.global.userData.savedShoppingSearches[i].filter)] then
			tremove(TSM.db.global.userData.savedShoppingSearches, i)
		end
	end
	TSMAPI_FOUR.Util.ReleaseTempTable(keepSearch)

	private.db = TSMAPI_FOUR.Database.New(SAVED_SEARCHES_SCHEMA)
	for i, data in ipairs(TSM.db.global.userData.savedShoppingSearches) do
		assert(data.searchMode == "normal" or data.searchMode == "crafting")
		private.db:NewRow()
			:SetField("index", i)
			:SetField("name", data.name)
			:SetField("lastSearch", data.lastSearch)
			:SetField("isFavorite", data.isFavorite and true or false)
			:SetField("mode", data.searchMode)
			:SetField("filter", data.filter)
			:Save()
	end
end

function SavedSearches.CreateRecentSearchesQuery()
	return private.db:NewQuery()
		:OrderBy("lastSearch", false)
end

function SavedSearches.CreateFavoriteSearchesQuery()
	return private.db:NewQuery()
		:Equal("isFavorite", true)
		:OrderBy("name", true)
end

function SavedSearches.SetSearchIsFavorite(dbRow, isFavorite)
	local data = TSM.db.global.userData.savedShoppingSearches[dbRow:GetField("index")]
	data.isFavorite = isFavorite or nil
	dbRow:SetField("isFavorite",  isFavorite)
		:Save()
end

function SavedSearches.RenameSearch(dbRow, newName)
	local data = TSM.db.global.userData.savedShoppingSearches[dbRow:GetField("index")]
	data.name = newName
	dbRow:SetField("name", data.name)
		:Save()
end

function SavedSearches.DeleteSearch(dbRow)
	local index = dbRow:GetField("index")
	tremove(TSM.db.global.userData.savedShoppingSearches, index)
	private.db:SetQueryUpdatesPaused(true)
	private.db:DeleteRow(dbRow)
	-- need to decrement the index fields of all the rows which got shifted up
	local query = private.db:NewQuery()
		:GreaterThanOrEqual("index", index)
	for _, row in query:Iterator() do
		row:DecrementField("index")
			:Save()
	end
	query:Release()
	private.db:SetQueryUpdatesPaused(false)
end

function SavedSearches.RecordFilterSearch(filter)
	local found = false
	for i, data in ipairs(TSM.db.global.userData.savedShoppingSearches) do
		if strlower(data.filter) == strlower(filter) then
			data.lastSearch = time()
			local query = private.db:NewQuery()
				:Equal("index", i)
			local dbRow = query:GetSingleResult()
			query:Release()
			dbRow:SetField("lastSearch", data.lastSearch)
			dbRow:Save()
			found = true
			break
		end
	end
	if not found then
		local data = {
			name = filter,
			filter = filter,
			lastSearch = time(),
			searchMode = "normal",
			isFavorite = nil,
		}
		tinsert(TSM.db.global.userData.savedShoppingSearches, data)
		private.db:NewRow()
			:SetField("index", #TSM.db.global.userData.savedShoppingSearches)
			:SetField("name", data.name)
			:SetField("lastSearch", data.lastSearch)
			:SetField("isFavorite", data.isFavorite and true or false)
			:SetField("mode", data.searchMode)
			:SetField("filter", data.filter)
			:Save()
	end
end
