-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--          http://www.curse.com/addons/wow/tradeskillmaster_warehousing          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local AuctionTracking = TSM.Inventory:NewPackage("AuctionTracking")
local private = {
	db = nil,
	updateQuery = nil,
	isAHOpen = false,
	callbacks = {},
	indexUpdates = {
		list = {},
		pending = {},
	},
}
local DB_SCHEMA = {
	fields = {
		index = "number",
		itemString = "string",
		baseItemString = "string",
		autoBaseItemString = "string",
		itemLink = "string",
		itemTexture = "number",
		itemName = "string",
		itemQuality = "number",
		duration = "number",
		highBidder = "string",
		currentBid = "number",
		buyout = "number",
		stackSize = "number",
		saleStatus = "number",
	},
	fieldAttributes = {
		index = { "unique", "index" },
	},
}



-- ============================================================================
-- Module Functions
-- ============================================================================

function AuctionTracking.OnInitialize()
	TSMAPI_FOUR.Event.Register("AUCTION_HOUSE_SHOW", private.AuctionHouseShowHandler)
	TSMAPI_FOUR.Event.Register("AUCTION_HOUSE_CLOSED", private.AuctionHouseClosedHandler)
	TSMAPI_FOUR.Event.Register("AUCTION_OWNED_LIST_UPDATE", private.AuctionOwnedListUpdateHandler)
	private.db = TSMAPI_FOUR.Database.New(DB_SCHEMA)
	private.updateQuery = private.db:NewQuery()
		:SetUpdateCallback(private.OnCallbackQueryUpdated)
end

function AuctionTracking.RegisterCallback(callback)
	tinsert(private.callbacks, callback)
end

function AuctionTracking.DatabaseFieldIterator()
	return private.db:FieldIterator()
end

function AuctionTracking.DatabaseSetQueryUpdatesPaused(paused)
	private.db:SetQueryUpdatesPaused(paused)
end

function AuctionTracking.ExtendDatabaseSchema(schema, callback)
	private.db:ExtendSchema(schema, callback)
end

function AuctionTracking.CreateQuery()
	return private.db:NewQuery()
end



-- ============================================================================
-- Event Handlers
-- ============================================================================

function private.AuctionHouseShowHandler()
	private.isAHOpen = true
	GetOwnerAuctionItems()
end

function private.AuctionHouseClosedHandler()
	private.isAHOpen = false
end

function private.AuctionOwnedListUpdateHandler()
	wipe(private.indexUpdates.pending)
	wipe(private.indexUpdates.list)
	for i = 1, GetNumAuctionItems("owner") do
		if not private.indexUpdates.pending[i] then
			private.indexUpdates.pending[i] = true
			tinsert(private.indexUpdates.list, i)
		end
	end
	TSMAPI_FOUR.Delay.AfterFrame("auctionOwnedListScan", 2, private.AuctionOwnedListUpdateDelayed)
end

-- this is not a WoW event, but we fake it based on a delay from private.BankSlotChangedHandler
function private.AuctionOwnedListUpdateDelayed()
	if not private.isAHOpen then
		return
	end
	-- check if we need to change the sort
	local needsSort = false
	local numColumns = #AuctionSort.owner_duration
	for i, info in ipairs(AuctionSort.owner_duration) do
		local col, reversed = GetAuctionSort("owner", numColumns - i + 1)
		-- we want to do the opposite order
		reversed = not reversed
		if col ~= info.column or info.reverse ~= reversed then
			needsSort = true
			break
		end
	end
	if needsSort then
		TSM:LOG_INFO("Sorting owner auctions")
		AuctionFrame_SetSort("owner", "duration", true)
		SortAuctionApplySort("owner")
		return
	end

	-- scan the auctions
	private.db:SetQueryUpdatesPaused(true)
	private.db:Truncate()
	wipe(TSM.db.sync.internalData.auctionQuantity)
	for i = #private.indexUpdates.list, 1, -1 do
		local index = private.indexUpdates.list[i]
		if private.ScanAuction(index) then
			private.indexUpdates.pending[index] = nil
			tremove(private.indexUpdates.list, i)
		end
	end
	TSM:LOG_INFO("Scanned auctions (left=%d)", #private.indexUpdates.list)
	private.db:SetQueryUpdatesPaused(false)
	if #private.indexUpdates.list > 0 then
		-- some failed to scan so try again
		TSMAPI_FOUR.Delay.AfterFrame("auctionOwnedListScan", 2, private.AuctionOwnedListUpdateDelayed)
	end
end



-- ============================================================================
-- Private Helper Functions
-- ============================================================================

function private.ScanAuction(index)
	local name, texture, stackSize, quality, _, _, _, minBid, _, buyout, bid, highBidder, _, _, _, saleStatus = GetAuctionItemInfo("owner", index)
	if not name or name == "" then
		return false
	end
	assert(saleStatus == 0 or saleStatus == 1)
	local duration = GetAuctionItemTimeLeft("owner", index)
	local link = GetAuctionItemLink("owner", index)
	if not link then
		return false
	end
	highBidder = highBidder or ""
	texture = texture or TSMAPI_FOUR.Item.GetTexture(link)
	local itemString = TSMAPI_FOUR.Item.ToItemString(link)
	local baseItemString = TSMAPI_FOUR.Item.ToBaseItemString(itemString)
	local row = private.db:NewRow()
		:SetField("index", index)
		:SetField("itemString", itemString)
		:SetField("baseItemString", baseItemString)
		:SetField("autoBaseItemString", TSMAPI_FOUR.Item.ToBaseItemString(itemString, true))
		:SetField("itemLink", link)
		:SetField("itemTexture", texture)
		:SetField("itemName", name)
		:SetField("itemQuality", quality)
		:SetField("duration", saleStatus == 0 and duration or (time() + duration))
		:SetField("highBidder", highBidder)
		:SetField("currentBid", highBidder ~= "" and bid or minBid)
		:SetField("buyout", buyout)
		:SetField("stackSize", stackSize)
		:SetField("saleStatus", saleStatus)
		:Save()
	if saleStatus == 0 then
		TSM.db.sync.internalData.auctionQuantity[baseItemString] = (TSM.db.sync.internalData.auctionQuantity[baseItemString] or 0) + stackSize
	end
	return true
end

function private.OnCallbackQueryUpdated()
	for _, callback in ipairs(private.callbacks) do
		callback()
	end
end
