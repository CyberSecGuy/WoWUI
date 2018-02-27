-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local VendorSearch = TSM.Shopping:NewPackage("VendorSearch")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = { itemList = {}, scanThreadId = nil }



-- ============================================================================
-- Module Functions
-- ============================================================================

function VendorSearch.OnInitialize()
	-- initialize thread
	private.scanThreadId = TSMAPI_FOUR.Thread.New("VENDOR_SEARCH", private.ScanThread)
end

function VendorSearch.GetScanContext()
	return private.scanThreadId, private.MarketValueFunction
end



-- ============================================================================
-- Scan Thread
-- ============================================================================

function private.ScanThread(auctionScan)
	if TSMAPI_FOUR.Modules.API("AuctionDB", "lastCompleteScanTime") < time() - 60 * 60 * 12 then
		TSM:Print(L["No recent AuctionDB scan data found."])
		return false
	end
	auctionScan:SetCustomFilterFunc(private.ScanFilter)

	-- create the list of items, and add filters for them
	wipe(private.itemList)
	for _, itemString, _, minBuyout in TSM.old.AuctionDB.LastScanIteratorThreaded() do
		local vendorSell = TSMAPI_FOUR.Item.GetVendorSell(itemString) or 0
		if vendorSell and minBuyout and minBuyout < vendorSell then
			tinsert(private.itemList, itemString)
		end
		TSMAPI_FOUR.Thread.Yield()
	end
	auctionScan:AddItemListFiltersThreaded(private.itemList)

	-- run the scan
	auctionScan:StartScanThreaded()
	return true
end

function private.ScanFilter(row)
	local itemBuyout = row:GetField("itemBuyout")
	local vendorSell = TSMAPI_FOUR.Item.GetVendorSell(row:GetField("itemString"))
	return not vendorSell or itemBuyout == 0 or itemBuyout >= vendorSell
end

function private.MarketValueFunction(row)
	return TSMAPI_FOUR.Item.GetVendorSell(row:GetField("itemString"))
end
