-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local PostScan = TSM.Auctioning:NewPackage("PostScan")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = {
	scanThreadId = nil,
	queueDB = nil,
	nextQueueIndex = 1,
	bagDB = nil,
	auctionScanDB = nil,
	itemList = {},
	postBagsQuery = nil,
}
local QUEUE_DB_SCHEMA = {
	fields = {
		index = "number",
		itemString = "string",
		operationName = "string",
		bid = "number",
		buyout = "number",
		itemBuyout = "number",
		stackSize = "number",
		numStacks = "number",
		postTime = "number",
		numPosted = "number",
		numConfirmed = "number",
		numFailed = "number",
	}
}
local BAG_DB_SCHEMA = {
	fields = {
		itemString = "string",
		bag = "number",
		slot = "number",
		quantity = "number",
		slotId = "number",
	}
}
local BAGS_EXTENDED_DB_SCHEMA = {
	fields = {
		operation = "string",
	},
}
local RESET_REASON_LOOKUP = {
	minPrice = "postResetMin",
	maxPrice = "postResetMax",
	normalPrice = "postResetNormal"
}
local ABOVE_MAX_REASON_LOOKUP = {
	minPrice = "postAboveMaxMin",
	maxPrice = "postAboveMaxMax",
	normalPrice = "postAboveMaxNormal",
	none = "postAboveMaxNoPost"
}
local SLOT_ID_BAG_MULTIPLIER = 1000



-- ============================================================================
-- Module Functions
-- ============================================================================

function PostScan.OnInitialize()
	TSM.Inventory.BagTracking.ExtendDatabaseSchema(BAGS_EXTENDED_DB_SCHEMA, private.PostBagsRowSetExtendedFields)
	private.postBagsQuery = TSM.Inventory.BagTracking.CreateQuery()
		:GreaterThanOrEqual("bag", 0)
		:LessThanOrEqual("bag", NUM_BAG_SLOTS)
		:Distinct("autoBaseItemString")
		:Custom(function(row)
			-- don't include BoP or BoA items
			local isBoP, isBoA = TSMAPI_FOUR.Inventory.IsSoulbound(row:GetFields("bag", "slot"))
			return not isBoP and not isBoA
		end)
	private.scanThreadId = TSMAPI_FOUR.Thread.New("POST_SCAN", private.ScanThread)
	private.queueDB = TSMAPI_FOUR.Database.New(QUEUE_DB_SCHEMA)
	-- We maintain our own bag database rather than using the one in BagTracking since we need to be able to remove items
	-- as they are posted, without waiting for bag update events, and control when our DB updates.
	private.bagDB = TSMAPI_FOUR.Database.New(BAG_DB_SCHEMA)
end

function PostScan.GetBagsQuery()
	return private.postBagsQuery
end

function PostScan.Prepare()
	return private.scanThreadId
end

function PostScan.GetStatus()
	local nextProcessRow = nil
	local numPosted, numConfirmed, numFailed, totalNum = 0, 0, 0, 0
	local query = private.queueDB:NewQuery()
		:OrderBy("index", true)
	for _, row in query:Iterator(true) do
		local rowNumStacks, rowNumPosted, rowNumConfirmed, rowNumFailed = row:GetFields("numStacks", "numPosted", "numConfirmed", "numFailed")
		totalNum = totalNum + rowNumStacks
		numPosted = numPosted + rowNumPosted
		numConfirmed = numConfirmed + rowNumConfirmed
		numFailed = numFailed + rowNumFailed
		if not nextProcessRow and rowNumPosted < rowNumStacks then
			nextProcessRow = row
		end
	end
	query:Release()
	return nextProcessRow, numPosted, numConfirmed, numFailed, totalNum
end

function PostScan.DoProcess()
	local postRow = PostScan.GetStatus()
	local bag, slot = private.GetPostBagSlot(postRow:GetField("itemString"), postRow:GetField("stackSize"))
	if bag and slot then
		-- need to set the duration in the default UI to avoid Blizzard errors
		AuctionFrameAuctions.duration = postRow:GetField("postTime")
		ClearCursor()
		PickupContainerItem(bag, slot)
		ClickAuctionSellItemButton(AuctionsItemButton, "LeftButton")
		StartAuction(postRow:GetField("bid"), postRow:GetField("buyout"), postRow:GetField("postTime"), postRow:GetField("stackSize"), 1)
		ClearCursor()

		postRow:IncrementField("numPosted")
			:Save()
		return true
	else
		-- we couldn't find this item, so mark this post as failed and we'll try again later
		postRow:IncrementField("numPosted")
			:Save()
		return false
	end
end

function PostScan.DoSkip()
	local postRow = PostScan.GetStatus()
	local numStacks = postRow:GetField("numStacks")
	postRow:SetField("numPosted", numStacks)
		:SetField("numConfirmed", numStacks)
		:Save()
end

function PostScan.HandleConfirm(success, canRetry)
	if not success then
		ClearCursor()
	end

	local confirmRow = nil
	local query = private.queueDB:NewQuery()
		:OrderBy("index", true)
	for _, row in query:Iterator(true) do
		-- can't break from an iterator so just grab the one we care about and continue looping
		if not confirmRow and row:GetField("numConfirmed") < row:GetField("numPosted") then
			confirmRow = row
		end
	end
	query:Release()
	if not confirmRow then
		-- we may have posted something outside of TSM
		return
	end

	if canRetry then
		confirmRow:IncrementField("numFailed")
	end
	confirmRow:IncrementField("numConfirmed")
		:Save()
end

function PostScan.PrepareFailedPosts()
	local query = private.queueDB:NewQuery()
		:GreaterThan("numFailed", 0)
		:OrderBy("index", true)
	for _, row in query:Iterator() do
		local numFailed, numPosted, numConfirmed = row:GetFields("numFailed", "numPosted", "numConfirmed")
		assert(numPosted >= numFailed and numConfirmed >= numFailed)
		row:SetField("numFailed", 0)
			:SetField("numPosted", numPosted - numFailed)
			:SetField("numConfirmed", numConfirmed - numFailed)
			:Save()
	end
	query:Release()
	private.UpdateBagDB()
end

function PostScan.Reset()
	private.auctionScanDB = nil
	private.queueDB:Truncate()
	private.nextQueueIndex = 1
	private.bagDB:Truncate()
end

function PostScan.ChangePostDetail(field, value)
	local postRow = PostScan.GetStatus()
	if field == "bid" then
		value = min(max(value, 1), postRow:GetField("buyout"))
	end
	postRow:SetField(field, value)
		:Save()
end



-- ============================================================================
-- Scan Thread
-- ============================================================================

function private.ScanThread(auctionScan, auctionScanDB, scanContext)
	private.auctionScanDB = auctionScanDB
	auctionScan:SetScript("OnFilterDone", private.AuctionScanOnFilterDone)
	private.UpdateBagDB()

	-- get the state of the player's bags
	local bagCounts = TSMAPI_FOUR.Util.AcquireTempTable()
	local bagQuery = private.bagDB:NewQuery()
		:Select("itemString", "quantity")
	for _, itemString, quantity in bagQuery:Iterator(true) do
		bagCounts[itemString] = (bagCounts[itemString] or 0) + quantity
	end
	bagQuery:Release()

	-- generate the list of items we want to scan for
	wipe(private.itemList)
	for itemString, numHave in pairs(bagCounts) do
		local groupPath = TSMAPI_FOUR.Groups.GetPathByItem(itemString)
		local contextFilter = scanContext.isItems and itemString or groupPath
		if groupPath and tContains(scanContext, contextFilter) and private.CanPostItem(itemString, groupPath, numHave) then
			tinsert(private.itemList, itemString)
		end
	end
	TSMAPI_FOUR.Util.ReleaseTempTable(bagCounts)
	if #private.itemList == 0 then
		return
	end
	-- record this search
	TSM.Auctioning.SavedSearches.RecordSearch(scanContext, scanContext.isItems and "postItems" or "postGroups")

	-- run the scan
	auctionScan:AddItemListFiltersThreaded(private.itemList)
	auctionScan:StartScanThreaded()
end



-- ============================================================================
-- Private Helper Functions for Scanning
-- ============================================================================

function private.UpdateBagDB()
	private.bagDB:Truncate()
	for _, bag, slot, itemString, quantity in TSMAPI_FOUR.Inventory.BagIterator(true) do
		private.bagDB:NewRow()
			:SetField("itemString", itemString)
			:SetField("bag", bag)
			:SetField("slot", slot)
			:SetField("quantity", quantity)
			:SetField("slotId", bag * SLOT_ID_BAG_MULTIPLIER + slot)
			:Save()
	end
end

function private.CanPostItem(itemString, groupPath, numHave)
	local hasValidOperation, hasInvalidOperation = false, false
	for operationName, operationSettings in TSM.Operations.IteratorByGroup("Auctioning", groupPath) do
		local isValid, numUsed = private.IsOperationValid(itemString, numHave, operationName, operationSettings)
		if isValid == true then
			assert(numUsed and numUsed > 0)
			numHave = numHave - numUsed
			hasValidOperation = true
		elseif isValid == false then
			hasInvalidOperation = true
		else
			-- we are ignoring this operation
			assert(isValid == nil, "Invalid return value")
		end
	end

	return hasValidOperation and not hasInvalidOperation
end

function private.GetKeepQuantity(itemString, operationSettings)
	local keepQuantity = operationSettings.keepQuantity
	if operationSettings.keepQtySources.bank then
		keepQuantity = keepQuantity - TSMAPI_FOUR.Inventory.GetBankQuantity(itemString) - TSMAPI_FOUR.Inventory.GetReagentBankQuantity(itemString)
	end
	if operationSettings.keepQtySources.guild then
		keepQuantity = keepQuantity - TSMAPI_FOUR.Inventory.GetGuildQuantity(itemString)
	end
	return max(keepQuantity, 0)
end

function private.IsOperationValid(itemString, num, operationName, operationSettings)
	if operationSettings.postCap == 0 then
		-- posting is disabled, so ignore this operation
		TSM.Auctioning.Log.AddEntry(itemString, operationName, "postDisabled", "", 0)
		return nil
	end

	-- check the stack size
	local maxStackSize = TSMAPI_FOUR.Item.GetMaxStack(itemString)
	local minPostStackSize = operationSettings.stackSizeIsCap and 1 or operationSettings.stackSize
	if not maxStackSize then
		-- couldn't lookup item info for this item (shouldn't happen)
		if not TSM.db.global.auctioningOptions.disableInvalidMsg then
			TSM:Printf(L["Did not post %s because Blizzard didn't provide all necessary information for it. Try again later."], TSMAPI_FOUR.Item.GetLink(itemString))
		end
		TSM.Auctioning.Log.AddEntry(itemString, operationName, "invalidItemGroup", "", 0)
		return false
	elseif maxStackSize < minPostStackSize then
		-- invalid stack size
		if not TSM.db.global.auctioningOptions.disableInvalidMsg then
			TSM:Printf(L["Did not post %s because your stack size (%d) is higher than the max stack size of the item (%d)."], TSMAPI_FOUR.Item.GetLink(itemString), minPostStackSize, maxStackSize)
		end
		TSM.Auctioning.Log.AddEntry(itemString, operationName, "invalidItemGroup", "", 0)
		return false
	end

	-- check that we have enough to post
	num = num - private.GetKeepQuantity(itemString, operationSettings)
	if num < minPostStackSize then
		-- not enough items to post for this operation
		TSM.Auctioning.Log.AddEntry(itemString, operationName, "postNotEnough", "", 0)
		return nil
	end

	-- check the max expires
	if operationSettings.maxExpires > 0 then
		local _, numExpires = TSMAPI_FOUR.Modules.API("Accounting", "getAuctionStatsSinceLastSale", itemString)
		if type(numExpires) == "number" and numExpires > operationSettings.maxExpires then
			-- too many expires, so ignore this operation
			TSM.Auctioning.Log.AddEntry(itemString, operationName, "postMaxExpires", "", 0)
			return nil
		end
	end

	local errMsg = nil
	local minPrice = TSM.Auctioning.Util.GetPrice("minPrice", operationSettings, itemString)
	local normalPrice = TSM.Auctioning.Util.GetPrice("normalPrice", operationSettings, itemString)
	local maxPrice = TSM.Auctioning.Util.GetPrice("maxPrice", operationSettings, itemString)
	local undercut = TSM.Auctioning.Util.GetPrice("undercut", operationSettings, itemString)
	if not minPrice then
		errMsg = format(L["Did not post %s because your minimum price (%s) is invalid. Check your settings."], TSMAPI_FOUR.Item.GetLink(itemString), operationSettings.minPrice)
	elseif not maxPrice then
		errMsg = format(L["Did not post %s because your maximum price (%s) is invalid. Check your settings."], TSMAPI_FOUR.Item.GetLink(itemString), operationSettings.maxPrice)
	elseif not normalPrice then
		errMsg = format(L["Did not post %s because your normal price (%s) is invalid. Check your settings."], TSMAPI_FOUR.Item.GetLink(itemString), operationSettings.normalPrice)
	elseif not undercut then
		errMsg = format(L["Did not post %s because your undercut (%s) is invalid. Check your settings."], TSMAPI_FOUR.Item.GetLink(itemString), operationSettings.undercut)
	elseif normalPrice < minPrice then
		errMsg = format(L["Did not post %s because your normal price (%s) is lower than your minimum price (%s). Check your settings."], TSMAPI_FOUR.Item.GetLink(itemString), operationSettings.normalPrice, operationSettings.minPrice)
	elseif maxPrice < minPrice then
		errMsg = format(L["Did not post %s because your maximum price (%s) is lower than your minimum price (%s). Check your settings."], TSMAPI_FOUR.Item.GetLink(itemString), operationSettings.maxPrice, operationSettings.minPrice)
	end

	if errMsg then
		if not TSM.db.global.auctioningOptions.disableInvalidMsg then
			TSM:Print(errMsg)
		end
		TSM.Auctioning.Log.AddEntry(itemString, operationName, "invalidItemGroup", "", 0)
		return false
	else
		local vendorSellPrice = TSMAPI_FOUR.Item.GetVendorSell(itemString) or 0
		if vendorSellPrice > 0 and minPrice <= vendorSellPrice / 0.95 then
			-- just a warning, not an error
			TSM:Printf(L["WARNING: You minimum price for %s is below its vendorsell price (with AH cut taken into account). Consider raising your minimum price, or vendoring the item."], TSMAPI_FOUR.Item.GetLink(itemString))
		end
		return true, operationSettings.stackSize * operationSettings.postCap
	end
end


function private.AuctionScanOnFilterDone(_, filter)
	for _, itemString in ipairs(filter:GetItems()) do
		local isBaseItemString = itemString == TSMAPI_FOUR.Item.ToBaseItemString(itemString)
		local query = private.auctionScanDB:NewQuery()
			:Equal(isBaseItemString and "baseItemString" or "itemString", itemString)
			:GreaterThan("itemBuyout", 0)
			:OrderBy("itemBuyout", true)
		local groupPath = TSMAPI_FOUR.Groups.GetPathByItem(itemString)
		if groupPath then
			local numHave = 0
			local bagQuery = private.bagDB:NewQuery()
				:Select("quantity")
				:Equal("itemString", itemString)
			for _, quantity in bagQuery:Iterator(true) do
				numHave = numHave + quantity
			end
			bagQuery:Release()

			for operationName, operationSettings in TSM.Operations.IteratorByGroup("Auctioning", groupPath) do
				if private.IsOperationValid(itemString, numHave, operationName, operationSettings) then
					local operationNumHave = numHave - private.GetKeepQuantity(itemString, operationSettings)
					if operationNumHave > 0 then
						local reason, numUsed, itemBuyout, seller = private.GeneratePosts(itemString, operationName, operationSettings, operationNumHave, query)
						numHave = numHave - (numUsed or 0)
						seller = seller or ""
						TSM.Auctioning.Log.AddEntry(itemString, operationName, reason, seller, itemBuyout or 0)
					end
				end
			end
		else
			TSM:LOG_WARN("Item removed from group since start of scan: %s", itemString)
		end
		query:Release()
	end
end

function private.GeneratePosts(itemString, operationName, operationSettings, numHave, query)
	if numHave == 0 then
		return "postNotEnough"
	end

	local maxStackSize = TSMAPI_FOUR.Item.GetMaxStack(itemString)
	if operationSettings.stackSize > maxStackSize and not operationSettings.stackSizeIsCap then
		return "postNotEnough"
	end

	local perAuction = min(operationSettings.stackSize, maxStackSize)
	local maxCanPost = min(floor(numHave / perAuction), operationSettings.postCap)
	if maxCanPost == 0 then
		if operationSettings.stackSizeIsCap then
			perAuction = numHave
			maxCanPost = 1
		else
			-- not enough for single post
			return "postNotEnough"
		end
	end

	local lowestAuction = TSMAPI_FOUR.Util.AcquireTempTable()
	if not TSM.Auctioning.Util.GetLowestAuction(query, itemString, operationSettings, lowestAuction) then
		TSMAPI_FOUR.Util.ReleaseTempTable(lowestAuction)
		lowestAuction = nil
	end
	local minPrice = TSM.Auctioning.Util.GetPrice("minPrice", operationSettings, itemString)
	local normalPrice = TSM.Auctioning.Util.GetPrice("normalPrice", operationSettings, itemString)
	local maxPrice = TSM.Auctioning.Util.GetPrice("maxPrice", operationSettings, itemString)
	local undercut = TSM.Auctioning.Util.GetPrice("undercut", operationSettings, itemString)
	local resetPrice = TSM.Auctioning.Util.GetPrice("priceReset", operationSettings, itemString)
	local aboveMax = TSM.Auctioning.Util.GetPrice("aboveMax", operationSettings, itemString)

	local reason, bid, buyout, seller, activeAuctions = nil, nil, nil, nil, 0
	if not lowestAuction then
		-- post as many as we can at the normal price
		reason = "postNormal"
		buyout = normalPrice
	elseif lowestAuction.hasInvalidSeller then
		-- we didn't get all the necessary seller info
		TSM:Printf(L["The seller name of the lowest auction for %s was not given by the server. Skipping this item."], TSMAPI_FOUR.Item.GetLink(itemString))
		TSMAPI_FOUR.Util.ReleaseTempTable(lowestAuction)
		return "invalidSeller"
	elseif lowestAuction.isBlacklist and lowestAuction.isPlayer then
		TSM:Printf(L["Did not post %s because you or one of your alts (%s) is on the blacklist which is not allowed. Remove this character from your blacklist."], TSMAPI_FOUR.Item.GetLink(itemString), lowestAuction.seller)
		TSMAPI_FOUR.Util.ReleaseTempTable(lowestAuction)
		return "invalidItemGroup"
	elseif lowestAuction.isBlacklist and lowestAuction.isWhitelist then
		TSM:Printf(L["Did not post %s because the owner of the lowest auction (%s) is on both the blacklist and whitelist which is not allowed. Adjust your settings to correct this issue."], TSMAPI_FOUR.Item.GetLink(itemString), lowestAuction.seller)
		TSMAPI_FOUR.Util.ReleaseTempTable(lowestAuction)
		return "invalidItemGroup"
	elseif lowestAuction.buyout <= minPrice then
		seller = lowestAuction.seller
		if resetPrice then
			-- lowest is below the min price, but there is a reset price
			assert(RESET_REASON_LOOKUP[operationSettings.priceReset], "Unexpected 'below minimum price' setting: "..tostring(operationSettings.priceReset))
			reason = RESET_REASON_LOOKUP[operationSettings.priceReset]
			buyout = resetPrice
			bid = max(bid or buyout * operationSettings.bidPercent, minPrice)
			activeAuctions = TSM.Auctioning.Util.GetPlayerAuctionCount(query, itemString, operationSettings, floor(bid), buyout, perAuction)
		elseif lowestAuction.isBlacklist then
			-- undercut the blacklisted player
			reason = "postBlacklist"
			buyout = lowestAuction.buyout - undercut
		else
			-- don't post this item
			TSMAPI_FOUR.Util.ReleaseTempTable(lowestAuction)
			return "postBelowMin", nil, nil, seller
		end
	elseif lowestAuction.isPlayer or (lowestAuction.isWhitelist and TSM.db.global.auctioningOptions.matchWhitelist) then
		-- we (or a whitelisted play we should match) is lowest, so match the current price and post as many as we can
		activeAuctions = TSM.Auctioning.Util.GetPlayerAuctionCount(query, itemString, operationSettings, lowestAuction.bid, lowestAuction.buyout, perAuction)
		if lowestAuction.isPlayer then
			reason = "postPlayer"
		else
			reason = "postWhitelist"
		end
		bid = lowestAuction.bid
		buyout = lowestAuction.buyout
		seller = lowestAuction.seller
	elseif lowestAuction.isWhitelist then
		-- don't undercut a whitelisted player
		seller = lowestAuction.seller
		TSMAPI_FOUR.Util.ReleaseTempTable(lowestAuction)
		return "postWhitelistNoPost", nil, nil, seller
	elseif (lowestAuction.buyout - undercut) > maxPrice then
		-- we'd be posting above the max price, so resort to the aboveMax setting
		seller = lowestAuction.seller
		if operationSettings.aboveMax == "none" then
			TSMAPI_FOUR.Util.ReleaseTempTable(lowestAuction)
			return "postAboveMaxNoPost", nil, nil, seller
		end
		assert(ABOVE_MAX_REASON_LOOKUP[operationSettings.aboveMax], "Unexpected 'above max price' setting: "..tostring(operationSettings.aboveMax))
		reason = ABOVE_MAX_REASON_LOOKUP[operationSettings.aboveMax]
		buyout = aboveMax
	else
		-- we just need to do a normal undercut of the lowest auction
		reason = "postUndercut"
		buyout = lowestAuction.buyout - undercut
		seller = lowestAuction.seller
	end
	if reason == "postBlacklist" then
		bid = bid or buyout * operationSettings.bidPercent
	else
		buyout = max(buyout, minPrice)
		bid = max(bid or buyout * operationSettings.bidPercent, minPrice)
	end
	if lowestAuction then
		TSMAPI_FOUR.Util.ReleaseTempTable(lowestAuction)
	end
	bid = floor(bid)

	-- check if we can't post anymore
	local queueQuery = private.queueDB:NewQuery()
		:Select("numStacks")
		:Equal("itemString", itemString)
		:Equal("stackSize", perAuction)
		:Equal("itemBuyout", buyout)
	for _, numStacks in queueQuery:Iterator(true) do
		activeAuctions = activeAuctions + numStacks
	end
	queueQuery:Release()
	maxCanPost = min(operationSettings.postCap - activeAuctions, maxCanPost)
	if maxCanPost <= 0 then
		return "postTooMany"
	end

	-- insert the posts into our DB
	local postTime = (operationSettings.duration == 48 and 3) or (operationSettings.duration == 24 and 2) or 1
	private.AddToQueue(itemString, operationName, bid, buyout, perAuction, maxCanPost, postTime)
	-- check if we can post an extra partial stack
	local extraStack = (maxCanPost < operationSettings.postCap and operationSettings.stackSizeIsCap and (numHave % perAuction)) or 0
	if extraStack > 0 then
		private.AddToQueue(itemString, operationName, bid, buyout, extraStack, 1, postTime)
	end
	return reason, (perAuction * maxCanPost) - extraStack, buyout, seller
end

function private.AddToQueue(itemString, operationName, itemBid, itemBuyout, stackSize, numStacks, postTime)
	private.queueDB:NewRow()
		:SetField("index", private.nextQueueIndex)
		:SetField("itemString", itemString)
		:SetField("operationName", operationName)
		:SetField("bid", itemBid * stackSize)
		:SetField("buyout", itemBuyout * stackSize)
		:SetField("itemBuyout", itemBuyout)
		:SetField("stackSize", stackSize)
		:SetField("numStacks", numStacks)
		:SetField("postTime", postTime)
		:SetField("numPosted", 0)
		:SetField("numConfirmed", 0)
		:SetField("numFailed", 0)
		:Save()
	private.nextQueueIndex = private.nextQueueIndex + 1
end



-- ============================================================================
-- Private Helper Functions for Posting
-- ============================================================================

function private.GetPostBagSlot(itemString, quantity)
	-- start with the slot which is closest to the desired stack size
	local row = private.bagDB:NewQuery()
		:Equal("itemString", itemString)
		:GreaterThanOrEqual("quantity", quantity)
		:OrderBy("quantity", true)
		:GetFirstResultAndRelease()
	if not row then
		row = private.bagDB:NewQuery()
			:Equal("itemString", itemString)
			:LessThanOrEqual("quantity", quantity)
			:OrderBy("quantity", false)
			:GetFirstResultAndRelease()
	end
	local bag, slot = private.ItemBagSlotHelper(itemString, row:GetField("bag"), row:GetField("slot"), quantity)

	if TSMAPI_FOUR.Item.ToBaseItemString(GetContainerItemLink(bag, slot), true) ~= itemString then
		-- something changed with the player's bags so we can't post the item right now
		return
	end
	local _, _, _, quality = GetContainerItemInfo(bag, slot)
	assert(quality)
	if quality == -1 then
		-- the game client doesn't have item info cached for this item, so we can't post it yet
		return
	end
	return bag, slot
end

function private.ItemBagSlotHelper(itemString, bag, slot, quantity)
	local slotId = bag * SLOT_ID_BAG_MULTIPLIER + slot

	-- try to post completely from the selected slot
	local row = private.bagDB:NewQuery()
		:Equal("slotId", slotId)
		:GreaterThanOrEqual("quantity", quantity)
		:GetFirstResultAndRelease()
	if row then
		private.RemoveBagQuantity(row, quantity)
		return bag, slot
	end

	-- try to find a stack at a lower slot which has enough to post from
	local row = private.bagDB:NewQuery()
		:Equal("itemString", itemString)
		:LessThan("slotId", slotId)
		:GreaterThanOrEqual("quantity", quantity)
		:OrderBy("slotId", true)
		:GetFirstResultAndRelease()
	if row then
		private.RemoveBagQuantity(row, quantity)
		return bag, slot
	end

	-- try to post using the selected slot and the lower slots
	local selectedQuantity = private.bagDB:NewQuery()
		:Equal("slotId", slotId)
		:GetFirstResultAndRelease()
		:GetField("quantity")
	local query = private.bagDB:NewQuery()
		:Equal("itemString", itemString)
		:LessThan("slotId", slotId)
		:OrderBy("slotId", true)
	local numNeeded = quantity - selectedQuantity
	local numUsed = 0
	local usedRows = TSMAPI_FOUR.Util.AcquireTempTable()
	for _, row in query:Iterator(true) do
		if numNeeded ~= numUsed then
			numUsed = min(numUsed + row:GetField("quantity"), numNeeded)
			tinsert(usedRows, row)
		end
	end
	query:Release()
	if numNeeded == numUsed then
		for _, row in TSMAPI_FOUR.Util.TempTableIterator(usedRows) do
			local rowNumUsed = min(numUsed, row:GetField("quantity"))
			numUsed = numUsed - rowNumUsed
			private.RemoveBagQuantity(row, rowNumUsed)
		end
		return bag, slot
	else
		TSMAPI_FOUR.Util.ReleaseTempTable(usedRows)
	end

	-- try posting from the next highest slot
	local nextRow = private.bagDB:NewQuery()
		:Equal("itemString", itemString)
		:GreaterThan("slotId", slotId)
		:OrderBy("slotId", true)
		:GetFirstResultAndRelease()
	return private.ItemBagSlotHelper(itemString, nextRow:GetField("bag"), nextRow:GetField("slot"), quantity)
end

function private.RemoveBagQuantity(row, quantity)
	local remainingQuantity = row:GetField("quantity") - quantity
	if remainingQuantity > 0 then
		row:SetField("quantity", remainingQuantity)
			:Save()
	else
		assert(remainingQuantity == 0)
		private.bagDB:DeleteRow(row)
	end
end

function private.PostBagsRowSetExtendedFields(row)
	local itemString = row:GetField("autoBaseItemString")
	if TSMAPI_FOUR.Groups.GetPathByItem(itemString) == TSM.CONST.ROOT_GROUP_PATH then
		row:SetField("operation", TSMAPI.Operations:GetFirstByGroup(TSM.CONST.ROOT_GROUP_PATH, "Auctioning") or "")
	else
		row:SetField("operation", TSMAPI.Operations:GetFirstByItem(itemString, "Auctioning") or "")
	end
end
