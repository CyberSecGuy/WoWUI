-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local FilterSearch = TSM.Shopping:NewPackage("FilterSearch")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = { scanThreadId = nil, filterInfo = {}, source = nil, isSpecial = false }



-- ============================================================================
-- Module Functions
-- ============================================================================

function FilterSearch.OnInitialize()
	-- initialize thread
	private.scanThreadId = TSMAPI_FOUR.Thread.New("FILTER_SEARCH", private.ScanThread)
end

function FilterSearch.GetScanContext(source, isSpecial)
	private.source = source
	private.isSpecial = isSpecial
	return private.scanThreadId, private.MarketValueFunction
end



-- ============================================================================
-- Scan Thread
-- ============================================================================

function private.ScanThread(auctionScan, filterStr)
	-- FIXME: support maxQuantity
	local hasFilter = false
	for _, filter in TSMAPI_FOUR.Util.VarargIterator(strsplit(";", filterStr)) do
		filter = strtrim(filter)
		if filter ~= "" then
			if auctionScan:AddStringFilter(filter) then
				hasFilter = true
			end
		end
	end
	if not hasFilter then
		return false
	end
	if not private.isSpecial then
		TSM.Shopping.SavedSearches.RecordFilterSearch(filterStr)
	end

	-- run the scan
	auctionScan:StartScanThreaded()
	return true
end

function private.MarketValueFunction(row)
	return TSMAPI_FOUR.CustomPrice.GetValue(private.source or TSM.db.global.shoppingOptions.pctSource, row:GetField("itemString"))
end
