-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local MyAuctions = TSM:NewPackage("MyAuctions")
local private = {
	db = nil,
	query = nil,
	updateCallback = nil,
	ahOpen = false,
	pendingIndexes = {},
	pendingHashes = {},
	expectedCounts = {},
	auctionInfo = { numPosted = 0, numSold = 0, postedGold = 0, soldGold = 0 },
	dbHashFields = {},
	ignoreUpdate = nil,
}
local PENDING_SEP = ","
local AUCTION_UPDATE_DELAY = 2
local EXTENDED_DB_SCHEMA = {
	fields = {
		hash = "number",
		isPending = "boolean",
	},
}



-- ============================================================================
-- Module Functions
-- ============================================================================

function MyAuctions.OnInitialize()
	for field in TSM.Inventory.AuctionTracking.DatabaseFieldIterator() do
		if field ~= "index" then
			tinsert(private.dbHashFields, field)
		end
	end
	TSM.Inventory.AuctionTracking.ExtendDatabaseSchema(EXTENDED_DB_SCHEMA, private.RowSetExtendedFields)
	private.query = TSM.Inventory.AuctionTracking.CreateQuery()

	TSMAPI_FOUR.Event.Register("AUCTION_HOUSE_SHOW", private.AuctionHouseShowEventHandler)
	TSMAPI_FOUR.Event.Register("AUCTION_HOUSE_CLOSED", private.AuctionHouseHideEventHandler)
	TSMAPI_FOUR.Event.Register("CHAT_MSG_SYSTEM", private.ChatMsgSystemEventHandler)
	TSMAPI_FOUR.Event.Register("UI_ERROR_MESSAGE", private.UIErrorMessageEventHandler)
	TSM.Inventory.AuctionTracking.RegisterCallback(private.OnAuctionsUpdated)
end

function MyAuctions.GetQuery()
	private.query:Reset()
	return private.query
		:OrderBy("index", false)
end

function MyAuctions.SetUpdateCallback(callback)
	private.updateCallback = callback
end

function MyAuctions.CancelAuction(index)
	local row = TSM.Inventory.AuctionTracking.CreateQuery()
		:Equal("index", index)
		:GetFirstResultAndRelease()
	local hash = row:GetField("hash")
	if private.expectedCounts[hash] then
		private.expectedCounts[hash] = private.expectedCounts[hash] - 1
	else
		private.expectedCounts[hash] = private.GetNumRowsByHash(hash) - 1
	end
	assert(private.expectedCounts[hash] >= 0)

	TSM:LOG_INFO("Canceling (index=%d, hash=%d)", index, hash)
	CancelAuction(index)
	assert(not private.pendingIndexes[hash..PENDING_SEP..index])
	private.pendingIndexes[hash..PENDING_SEP..index] = true

	-- calling :Save() will cause the isPending field to be updated
	-- ignore the auction tracking callback which will be trigged by this
	private.ignoreUpdate = true
	row:Save()
	assert(not private.ignoreUpdate)

	tinsert(private.pendingHashes, hash)
	TSMAPI_FOUR.Delay.AfterTime("cancelingUpdate", AUCTION_UPDATE_DELAY, private.UpdateOwnerAuctions, AUCTION_UPDATE_DELAY)
end

function MyAuctions.CanCancel(index)
	for key in pairs(private.pendingIndexes) do
		local _, pendingIndex = strsplit(PENDING_SEP, key)
		pendingIndex = tonumber(pendingIndex)
		if pendingIndex <= index then
			return false
		end
	end
	return true
end

function MyAuctions.GetNumPending()
	local query = TSM.Inventory.AuctionTracking.CreateQuery()
		:Equal("isPending", true)
	local num = query:Count()
	query:Release()
	return num
end

function MyAuctions.GetRecordByIndex(index)
	return TSM.Inventory.AuctionTracking.CreateQuery()
		:Equal("index", index)
		:GetFirstResultAndRelease()
end

function MyAuctions.GetAuctionInfo()
	if not private.ahOpen then
		return
	end
	return private.auctionInfo.numPosted, private.auctionInfo.numSold, private.auctionInfo.postedGold, private.auctionInfo.soldGold
end



-- ============================================================================
-- Private Helper Functions
-- ============================================================================

function private.RowSetExtendedFields(row)
	local hash = row:CalculateHash(private.dbHashFields)
	row:SetField("hash", hash)
	row:SetField("isPending", private.pendingIndexes[hash..PENDING_SEP..row:GetField("index")] and true or false)
end

function private.AuctionHouseShowEventHandler()
	private.ahOpen = true
end

function private.AuctionHouseHideEventHandler()
	private.ahOpen = false
end

function private.ChatMsgSystemEventHandler(_, msg)
	if msg == ERR_AUCTION_REMOVED and #private.pendingHashes > 0 then
		local hash = tremove(private.pendingHashes, 1)
		assert(hash)
		TSM:LOG_INFO("Confirmed (hash=%d)", hash)
	end
end

function private.UIErrorMessageEventHandler(_, _, msg)
	if msg == ERR_ITEM_NOT_FOUND and #private.pendingHashes > 0 then
		local hash = tremove(private.pendingHashes, 1)
		assert(hash)
		TSM:LOG_INFO("Failed to cancel (hash=%d)", hash)
		if private.expectedCounts[hash] then
			private.expectedCounts[hash] = private.expectedCounts[hash] + 1
		end
	end
end

function private.GetNumRowsByHash(hash)
	return TSM.Inventory.AuctionTracking.CreateQuery()
		:Equal("hash", hash)
		:CountAndRelease()
end

function private.ProcessCancels()
	local toRemove = TSMAPI_FOUR.Util.AcquireTempTable()
	for hash, expectedCount in pairs(private.expectedCounts) do
		if private.GetNumRowsByHash(hash) == expectedCount then
			tinsert(toRemove, hash)
		end
	end
	for _, hash in ipairs(toRemove) do
		local query = TSM.Inventory.AuctionTracking.CreateQuery()
			:Equal("hash", hash)
		for _, row in query:Iterator() do
			private.pendingIndexes[hash..PENDING_SEP..row:GetField("index")] = nil
			row:Save()
		end
		query:Release()
		private.expectedCounts[hash] = nil
	end
	TSMAPI_FOUR.Util.ReleaseTempTable(toRemove)
end

function private.OnAuctionsUpdated()
	if private.ignoreUpdate then
		private.ignoreUpdate = nil
		return
	end
	local hasPending = false
	private.auctionInfo.numPosted = 0
	private.auctionInfo.numSold = 0
	private.auctionInfo.postedGold = 0
	private.auctionInfo.soldGold = 0
	local query = TSM.Inventory.AuctionTracking.CreateQuery()
		:Select("isPending", "saleStatus", "buyout", "currentBid")
	for _, isPending, saleStatus, buyout, currentBid in query:Iterator(true) do
		if isPending then
			hasPending = true
		end
		private.auctionInfo.numPosted = private.auctionInfo.numPosted + 1
		private.auctionInfo.postedGold = private.auctionInfo.postedGold + buyout
		if saleStatus == 1 then
			private.auctionInfo.numSold = private.auctionInfo.numSold + 1
			-- if somebody did a buyout, then bid will be equal to buyout, otherwise it'll be the winning bid
			private.auctionInfo.soldGold = private.auctionInfo.soldGold + currentBid
		end
	end
	query:Release()
	TSM.Inventory.AuctionTracking.DatabaseSetQueryUpdatesPaused(true)
	private.ProcessCancels()
	TSM.Inventory.AuctionTracking.DatabaseSetQueryUpdatesPaused(false)
	if private.updateCallback then
		private.updateCallback()
	end
	if hasPending then
		TSMAPI_FOUR.Delay.AfterTime("cancelingUpdate", AUCTION_UPDATE_DELAY, private.UpdateOwnerAuctions, AUCTION_UPDATE_DELAY)
	end
end

function private.UpdateOwnerAuctions()
	if MyAuctions.GetNumPending() == 0 then
		TSMAPI_FOUR.Delay.Cancel("cancelingUpdate")
		return
	end
	GetOwnerAuctionItems()
end
