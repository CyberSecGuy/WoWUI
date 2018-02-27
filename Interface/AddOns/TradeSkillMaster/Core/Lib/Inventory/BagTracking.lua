-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--          http://www.curse.com/addons/wow/tradeskillmaster_warehousing          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local BagTracking = TSM.Inventory:NewPackage("BagTracking")
local private = {
	db = nil,
	bagUpdates = {
		pending = {},
		bagList = {},
		bankList = {},
	},
	bankSlotUpdates = {
		pending = {},
		list = {},
	},
	reagentBankSlotUpdates = {
		pending = {},
		list = {},
	},
	bankOpen = false,
	isFirstBankOpen = true,
	slotIdLocked = {},
	slotIdSoulboundCached = {},
	slotIdIsBoP = {},
	slotIdIsBoA = {},
	callbackQuery = nil,
	callbacks = {},
}
local BAG_DB_SCHEMA = {
	fields = {
		slotId = "number",
		bag = "number",
		slot = "number",
		itemLink = "string",
		itemString = "string",
		baseItemString = "string",
		autoBaseItemString = "string",
		itemTexture = "number",
		quantity = "number",
		isBoP = "boolean",
		isBoA = "boolean",
	},
	fieldAttributes = {
		slotId = { "unique", "index" },
		bag = { "index" },
	}
}
local NEGATIVE_BAG_OFFSET = 100
local SLOT_ID_BAG_MULTIPLIER = 1000



-- ============================================================================
-- Module Functions
-- ============================================================================

function BagTracking.OnInitialize()
	TSMAPI_FOUR.Event.Register("BAG_UPDATE", private.BagUpdateHandler)
	TSMAPI_FOUR.Event.Register("BAG_UPDATE_DELAYED", private.BagUpdateDelayedHandler)
	TSMAPI_FOUR.Event.Register("BANKFRAME_OPENED", private.BankOpenedHandler)
	TSMAPI_FOUR.Event.Register("BANKFRAME_CLOSED", private.BankClosedHandler)
	TSMAPI_FOUR.Event.Register("PLAYERBANKSLOTS_CHANGED", private.BankSlotChangedHandler)
	TSMAPI_FOUR.Event.Register("PLAYERREAGENTBANKSLOTS_CHANGED", private.ReagentBankSlotChangedHandler)
	TSMAPI_FOUR.Event.Register("ITEM_LOCKED", private.ItemLockedHandler)
	TSMAPI_FOUR.Event.Register("ITEM_UNLOCKED", private.ItemUnlockedHandler)
	private.db = TSMAPI_FOUR.Database.New(BAG_DB_SCHEMA)
	private.callbackQuery = private.db:NewQuery()
		:SetUpdateCallback(private.OnCallbackQueryUpdated)
end

-- Not all APIs return valid values as of OnInitialize when you first log in, so delay until OnEnable
function BagTracking.OnEnable()
	-- we'll scan all the bags and reagent bank right away, so wipe the existing quantities
	wipe(TSM.db.sync.internalData.bagQuantity)
	wipe(TSM.db.sync.internalData.reagentBankQuantity)

	private.db:SetQueryUpdatesPaused(true)
	-- WoW does not fire an update event for the backpack when you log in, so trigger one
	private.BagUpdateHandler(nil, 0)
	-- trigger an update event for all bank (initial container) and reagent bank slots since we won't get one otherwise on login
	for slot = 1, GetContainerNumSlots(BANK_CONTAINER) do
		private.BankSlotChangedHandler(nil, slot)
	end
	for slot = 1, GetContainerNumSlots(REAGENTBANK_CONTAINER) do
		private.ReagentBankSlotChangedHandler(nil, slot)
	end
	private.db:SetQueryUpdatesPaused(false)
end

function BagTracking.RegisterCallback(callback)
	tinsert(private.callbacks, callback)
end

function BagTracking.DatabaseSetQueryUpdatesPaused(paused)
	private.db:SetQueryUpdatesPaused(paused)
end

function BagTracking.ExtendDatabaseSchema(schema, callback)
	private.db:ExtendSchema(schema, callback)
end

function BagTracking.CreateQuery()
	return private.db:NewQuery()
end



-- ============================================================================
-- TSMAPI Functions
-- ============================================================================

function TSMAPI_FOUR.Inventory.IsSoulbound(bag, slot)
	local slotId = private.BagSlotToSlotId(bag, slot)
	if private.slotIdSoulboundCached[slotId] then
		return private.slotIdIsBoP[slotId], private.slotIdIsBoA[slotId]
	end
	if not TSMScanTooltip then
		CreateFrame("GameTooltip", "TSMScanTooltip", UIParent, "GameTooltipTemplate")
	end
	TSMScanTooltip:Show()
	TSMScanTooltip:SetClampedToScreen(false)
	TSMScanTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT", 1000000, 100000)

	-- figure out if this item has a max number of charges
	local itemId = GetContainerItemID(bag, slot)
	local maxCharges = nil
	if itemId then
		TSMScanTooltip:SetItemByID(itemId)
		maxCharges = private.GetScanTooltipCharges()
	end

	-- set TSMScanTooltip to show the inventory item
	if bag == -1 then
		TSMScanTooltip:SetInventoryItem("player", slot + 39)
	else
		TSMScanTooltip:SetBagItem(bag, slot)
	end

	-- check if there are used charges
	if maxCharges and private.GetScanTooltipCharges() ~= maxCharges then
		private.slotIdSoulboundCached[slotId] = true
		private.slotIdIsBoP[slotId] = true
		private.slotIdIsBoA[slotId] = false
		return true, false
	end

	-- scan the tooltip
	local numLines = TSMScanTooltip:NumLines()
	if numLines <= 1 then
		-- the tooltip didn't fully load or there's nothing in this slot
		return nil, nil
	end
	local isBOP, isBOA = false, false
	for id = 1, numLines do
		local text = private.GetTooltipText(_G["TSMScanTooltipTextLeft"..id])
		if text then
			if (text == ITEM_BIND_ON_PICKUP and id < 4) or text == ITEM_SOULBOUND or text == ITEM_BIND_QUEST then
				isBOP = true
				break
			elseif (text == ITEM_ACCOUNTBOUND or text == ITEM_BIND_TO_ACCOUNT or text == ITEM_BIND_TO_BNETACCOUNT or text == ITEM_BNETACCOUNTBOUND) then
				isBOA = true
				break
			end
		end
	end
	private.slotIdSoulboundCached[slotId] = true
	private.slotIdIsBoP[slotId] = isBOP
	private.slotIdIsBoA[slotId] = isBOA
	return isBOP, isBOA
end

function TSMAPI_FOUR.Inventory.BagIterator(autoBaseItems, includeBoP, includeBoA)
	local query = private.db:NewQuery()
		:GreaterThanOrEqual("slotId", private.BagSlotToSlotId(0, 1))
		:LessThanOrEqual("slotId", private.BagSlotToSlotId(NUM_BAG_SLOTS + 1, 0))
		:OrderBy("slotId", true)
		:Select("bag", "slot", autoBaseItems and "autoBaseItemString" or "itemString", "quantity")
	if not includeBoP then
		query:Equal("isBoP", false)
	end
	if not includeBoA then
		query:Equal("isBoA", false)
	end
	return query:IteratorAndRelease(true)
end

function TSMAPI_FOUR.Inventory.BankIterator(autoBaseItems, includeBoP, includeBoA, includeReagents)
	local query = private.db:NewQuery()
		:OrderBy("slotId", true)
		:Select("bag", "slot", autoBaseItems and "autoBaseItemString" or "itemString", "quantity")
		:Or()
			:Equal("bag", BANK_CONTAINER)
			:And()
				:GreaterThan("bag", NUM_BAG_SLOTS)
				:LessThanOrEqual("bag", NUM_BAG_SLOTS + NUM_BANKBAGSLOTS)
			:End()
	if includeReagents and IsReagentBankUnlocked() then
		query:Equal("bag", REAGENTBANK_CONTAINER)
	end
	query:End() -- end the Or()
	if not includeBoP then
		query:Equal("isBoP", false)
	end
	if not includeBoA then
		query:Equal("isBoA", false)
	end
	return query:IteratorAndRelease(true)
end

function TSMAPI_FOUR.Inventory.IsBagSlotLocked(bag, slot)
	return private.slotIdLocked[private.BagSlotToSlotId(bag, slot)]
end



-- ============================================================================
-- Event Handlers
-- ============================================================================

function private.BankOpenedHandler()
	if private.isFirstBankOpen then
		private.isFirstBankOpen = false
		-- this is the first time opening the bank so we'll scan all the items so wipe our existing quantities
		wipe(TSM.db.sync.internalData.bankQuantity)
	end
	private.bankOpen = true
	private.BagUpdateDelayedHandler()
	private.BankSlotUpdateDelayed()
end

function private.BankClosedHandler()
	private.bankOpen = false
end

local function SlotIdSoulboundCachedFilter(slotId, _, bag)
	return private.SlotIdToBagSlot(slotId) == bag
end
function private.BagUpdateHandler(_, bag)
	-- clear the soulbound cache for everything in this bag
	TSMAPI_FOUR.Util.TableFilter(private.slotIdSoulboundCached, SlotIdSoulboundCachedFilter, bag)
	if private.bagUpdates.pending[bag] then
		return
	end
	private.bagUpdates.pending[bag] = true
	if bag >= BACKPACK_CONTAINER and bag <= NUM_BAG_SLOTS then
		tinsert(private.bagUpdates.bagList, bag)
	elseif bag == BANK_CONTAINER or (bag > NUM_BAG_SLOTS and bag <= NUM_BAG_SLOTS + NUM_BANKBAGSLOTS) then
		tinsert(private.bagUpdates.bankList, bag)
	else
		error("Unexpected bag: "..tostring(bag))
	end
end

function private.BagUpdateDelayedHandler()
	private.db:SetQueryUpdatesPaused(true)

	-- scan any pending bags
	for i = #private.bagUpdates.bagList, 1, -1 do
		local bag = private.bagUpdates.bagList[i]
		if private.ScanBagOrBank(bag) then
			private.bagUpdates.pending[bag] = nil
			tremove(private.bagUpdates.bagList, i)
		end
	end
	if #private.bagUpdates.bagList > 0 then
		-- some failed to scan so try again
		TSMAPI_FOUR.Delay.AfterFrame("bagBankScan", 2, private.BagUpdateDelayedHandler)
	end

	if private.bankOpen then
		-- scan any pending bank bags
		for i = #private.bagUpdates.bankList, 1, -1 do
			local bag = private.bagUpdates.bankList[i]
			if private.ScanBagOrBank(bag) then
				private.bagUpdates.pending[bag] = nil
				tremove(private.bagUpdates.bankList, i)
			end
		end
		if #private.bagUpdates.bankList > 0 then
			-- some failed to scan so try again
			TSMAPI_FOUR.Delay.AfterFrame("bagBankScan", 2, private.BagUpdateDelayedHandler)
		end
	end

	private.db:SetQueryUpdatesPaused(false)
end

function private.BankSlotChangedHandler(_, slot)
	-- clear the soulbound cache for this slot
	private.slotIdSoulboundCached[private.BagSlotToSlotId(BANK_CONTAINER, slot)] = nil
	if private.bankSlotUpdates.pending[slot] then
		return
	end
	private.bankSlotUpdates.pending[slot] = true
	tinsert(private.bankSlotUpdates.list, slot)
	TSMAPI_FOUR.Delay.AfterFrame("bankSlotScan", 2, private.BankSlotUpdateDelayed)
end

-- this is not a WoW event, but we fake it based on a delay from private.BankSlotChangedHandler
function private.BankSlotUpdateDelayed()
	if not private.bankOpen then
		return
	end
	private.db:SetQueryUpdatesPaused(true)

	-- scan any pending slots
	for i = #private.bankSlotUpdates.list, 1, -1 do
		local slot = private.bankSlotUpdates.list[i]
		if private.ScanBankSlot(slot) then
			private.bankSlotUpdates.pending[slot] = nil
			tremove(private.bankSlotUpdates.list, i)
		end
	end
	if #private.bankSlotUpdates.list > 0 then
		-- some failed to scan so try again
		TSMAPI_FOUR.Delay.AfterFrame("bankSlotScan", 2, private.BankSlotUpdateDelayed)
	end

	private.db:SetQueryUpdatesPaused(false)
end

function private.ReagentBankSlotChangedHandler(_, slot)
	-- clear the soulbound cache for this slot
	private.slotIdSoulboundCached[private.BagSlotToSlotId(REAGENTBANK_CONTAINER, slot)] = nil
	if private.reagentBankSlotUpdates.pending[slot] then
		return
	end
	private.reagentBankSlotUpdates.pending[slot] = true
	tinsert(private.reagentBankSlotUpdates.list, slot)
	TSMAPI_FOUR.Delay.AfterFrame("reagentBankSlotScan", 2, private.ReagentBankSlotUpdateDelayed)
end

-- this is not a WoW event, but we fake it based on a delay from private.ReagentBankSlotChangedHandler
function private.ReagentBankSlotUpdateDelayed()
	private.db:SetQueryUpdatesPaused(true)

	-- scan any pending slots
	for i = #private.reagentBankSlotUpdates.list, 1, -1 do
		local slot = private.reagentBankSlotUpdates.list[i]
		if private.ScanReagentBankSlot(slot) then
			private.reagentBankSlotUpdates.pending[slot] = nil
			tremove(private.reagentBankSlotUpdates.list, i)
		end
	end
	if #private.reagentBankSlotUpdates.list > 0 then
		-- some failed to scan so try again
		TSMAPI_FOUR.Delay.AfterFrame("reagentBankSlotScan", 2, private.ReagentBankSlotUpdateDelayed)
	end

	private.db:SetQueryUpdatesPaused(false)
end

function private.ItemLockedHandler(_, bag, slot)
	if not slot then
		return
	end
	private.slotIdLocked[private.BagSlotToSlotId(bag, slot)] = true
end

function private.ItemUnlockedHandler(_, bag, slot)
	if not slot then
		return
	end
	private.slotIdLocked[private.BagSlotToSlotId(bag, slot)] = nil
end



-- ============================================================================
-- Scanning Functions
-- ============================================================================

function private.ScanBagOrBank(bag)
	local numSlots = GetContainerNumSlots(bag)
	private.RemoveExtraSlots(bag, numSlots)
	local result = true
	for slot = 1, numSlots do
		if not private.ScanBagSlot(bag, slot) then
			result = false
		end
	end
	return result
end

function private.ScanBankSlot(slot)
	return private.ScanBagSlot(BANK_CONTAINER, slot)
end

function private.ScanReagentBankSlot(slot)
	return private.ScanBagSlot(REAGENTBANK_CONTAINER, slot)
end



-- ============================================================================
-- Private Helper Functions
-- ============================================================================

function private.RemoveExtraSlots(bag, numSlots)
	-- the number of slots of this bag may have changed, in which case we should remove any higher ones from our DB
	local query = private.db:NewQuery()
		:Equal("bag", bag)
		:GreaterThan("slot", numSlots)
	for _, row in query:Iterator() do
		local oldBaseItemString, oldQuantity = row:GetFields("baseItemString", "quantity")
		private.ChangeItemTotal(bag, oldBaseItemString, -oldQuantity)
		private.db:DeleteRow(row)
	end
	query:Release()
end

function private.ScanBagSlot(bag, slot)
	local texture, quantity, _, _, _, _, link, _, _, itemId = GetContainerItemInfo(bag, slot)
	if quantity and not itemId then
		-- we are pending item info for this slot so try again later to scan it
		return false
	end
	local baseItemString = link and TSMAPI_FOUR.Item.ToBaseItemString(link)
	local slotId = private.BagSlotToSlotId(bag, slot)
	local row = private.db:GetUniqueRow("slotId", slotId)
	if baseItemString then
		local isBoP, isBoA = nil, nil
		if row then
			if row:GetField("itemLink") == link then
				-- the item didn't change, so use the previous values
				isBoP, isBoA = row:GetFields("isBoP", "isBoA")
			else
				isBoP, isBoA = TSMAPI_FOUR.Inventory.IsSoulbound(bag, slot)
				if isBoP == nil then
					return false
				end
			end
			-- remove the old row from the item totals
			local oldBaseItemString, oldQuantity = row:GetFields("baseItemString", "quantity")
			private.ChangeItemTotal(bag, oldBaseItemString, -oldQuantity)
		else
			isBoP, isBoA = TSMAPI_FOUR.Inventory.IsSoulbound(bag, slot)
			if isBoP == nil then
				return false
			end
			-- there was nothing here previously so create a new row
			row = private.db:NewRow()
				:SetField("slotId", slotId)
				:SetField("bag", bag)
				:SetField("slot", slot)
		end
		-- update the row
		row:SetField("itemLink", link)
			:SetField("itemString", TSMAPI_FOUR.Item.ToItemString(link))
			:SetField("baseItemString", baseItemString)
			:SetField("autoBaseItemString", TSMAPI_FOUR.Item.ToBaseItemString(link, true))
			:SetField("itemTexture", texture or TSMAPI_FOUR.Item.GetTexture(link))
			:SetField("quantity", quantity)
			:SetField("isBoP", isBoP)
			:SetField("isBoA", isBoA)
			:Save()
		-- add to the item totals
		private.ChangeItemTotal(bag, baseItemString, quantity)
	elseif row then
		-- nothing here now so delete the row and remove from the item totals
		local oldBaseItemString, oldQuantity = row:GetFields("baseItemString", "quantity")
		private.ChangeItemTotal(bag, oldBaseItemString, -oldQuantity)
		private.db:DeleteRow(row)
	end
	return true
end

function private.ChangeItemTotal(bag, itemString, changeQuantity)
	local totalsTable = nil
	if bag >= BACKPACK_CONTAINER and bag <= NUM_BAG_SLOTS then
		totalsTable = TSM.db.sync.internalData.bagQuantity
	elseif bag == BANK_CONTAINER or (bag > NUM_BAG_SLOTS and bag <= NUM_BAG_SLOTS + NUM_BANKBAGSLOTS) then
		totalsTable = TSM.db.sync.internalData.bankQuantity
	elseif bag == REAGENTBANK_CONTAINER then
		totalsTable = TSM.db.sync.internalData.reagentBankQuantity
	else
		error("Unexpected bag: "..tostring(bag))
	end
	totalsTable[itemString] = (totalsTable[itemString] or 0) + changeQuantity
	assert(totalsTable[itemString] >= 0)
	if totalsTable[itemString] == 0 then
		totalsTable[itemString] = nil
	end
end

function private.BagSlotToSlotId(bag, slot)
	if bag < 0 then
		-- translate bags which are less than 0 to values of NEGATIVE_BAG_OFFSET+
		bag = NEGATIVE_BAG_OFFSET - bag
	end
	return bag * SLOT_ID_BAG_MULTIPLIER + slot
end

function private.SlotIdToBagSlot(slotId)
	local bag = floor(slotId / SLOT_ID_BAG_MULTIPLIER)
	if bag > NEGATIVE_BAG_OFFSET then
		bag = NEGATIVE_BAG_OFFSET - bag
	end
	return bag, slotId % SLOT_ID_BAG_MULTIPLIER
end

function private.GetScanTooltipCharges()
	for id = 1, TSMScanTooltip:NumLines() do
		local text = private.GetTooltipText(_G["TSMScanTooltipTextLeft"..id])
		local maxCharges = text and strmatch(text, "^([0-9]+) Charges?$")
		if maxCharges then
			return maxCharges
		end
	end
end

function private.GetTooltipText(text)
	local textStr = strtrim(text and text:GetText() or "")
	if textStr == "" then return end

	local r, g, b = text:GetTextColor()
	return textStr, floor(r * 256), floor(g * 256), floor(b * 256)
end

function private.OnCallbackQueryUpdated()
	for _, callback in ipairs(private.callbacks) do
		callback()
	end
end
