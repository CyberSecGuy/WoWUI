-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local Destroying = TSM:NewPackage("Destroying")
local private = {
	combineThread = nil,
	destroyThread = nil,
	destroyThreadRunning = false,
	bagDB = nil,
	bagQuery = nil,
	canDestroyCache = {},
	destroyQuantityCache = {},
	pendingCombines = {},
	newBagUpdate = false,
	bagUpdateCallback = nil,
	canDestroy = false,
	pendingSpellId = nil,
	sessionIgnoreItems = {},
	didAutoShow = false,
}
local DB_SCHEMA = {
	fields = {
		itemString = "string",
		itemLink = "string",
		itemTexture = "number",
		bag = "number",
		slot = "number",
		slotId = "number",
		stackSize = "number",
		destroySpellId = "number",
	}
}
local SPELL_IDS = {
	milling = 51005,
	prospect = 31252,
	disenchant = 13262,
}
local ITEM_SUB_CLASS_METAL_AND_STONE = 7
local ITEM_SUB_CLASS_HERB = 9
local SLOT_ID_BAG_MULTIPLIER = 1000
local TARGET_SLOT_ID_MULTIPLIER = 100000
local GEM_CHIPS = {
	["i:129099"] = "i:129100",
	["i:130200"] = "i:129100",
	["i:130201"] = "i:129100",
	["i:130202"] = "i:129100",
	["i:130203"] = "i:129100",
	["i:130204"] = "i:129100",
}



-- ============================================================================
-- Module Functions
-- ============================================================================


function Destroying.OnInitialize()
	private.combineThread = TSMAPI_FOUR.Thread.New("COMBINE_STACKS", private.CombineThread)
	private.destroyThread = TSMAPI_FOUR.Thread.New("DESTROY", private.DestroyThread)
	private.bagDB = TSMAPI_FOUR.Database.New(DB_SCHEMA)
	private.bagQuery = private.bagDB:NewQuery()
	TSM.Inventory.BagTracking.RegisterCallback(private.UpdateBagDB)
	TSMAPI_FOUR.Event.Register("UNIT_SPELLCAST_START", private.SpellCastEventHandler)
	TSMAPI_FOUR.Event.Register("UNIT_SPELLCAST_INTERRUPTED", private.SpellCastEventHandler)
	TSMAPI_FOUR.Event.Register("UNIT_SPELLCAST_SUCCEEDED", private.SpellCastEventHandler)
	TSMAPI_FOUR.Event.Register("UNIT_SPELLCAST_FAILED", private.SpellCastEventHandler)
end

function Destroying.SetBagUpdateCallback(callback)
	assert(not private.bagUpdateCallback)
	private.bagUpdateCallback = callback
end

function Destroying.GetBagQuery()
	return private.bagQuery
end

function Destroying.CanCombine()
	return #private.pendingCombines > 0
end

function Destroying.CanDestroy()
	return private.canDestroy
end

function Destroying.GetCombineThread()
	return private.combineThread
end

function Destroying.GetDestroyThread()
	return private.destroyThread
end

function Destroying.KillDestroyThread()
	TSMAPI_FOUR.Thread.Kill(private.destroyThread)
	private.destroyThreadRunning = false
end

function Destroying.IgnoreItemSession(itemString)
	private.sessionIgnoreItems[itemString] = true
	private.UpdateBagDB(true)
end

function Destroying.IgnoreItemPermanent(itemString)
	TSM.db.global.userData.destroyingIgnore[itemString] = true
	private.UpdateBagDB(true)
end



-- ============================================================================
-- Combine Stacks Thread
-- ============================================================================

function private.CombineThread()
	while Destroying.CanCombine() do
		for _, combineSlotId in ipairs(private.pendingCombines) do
			local sourceBag, sourceSlot, targetBag, targetSlot = private.CombineSlotIdToBagSlot(combineSlotId)
			PickupContainerItem(sourceBag, sourceSlot)
			PickupContainerItem(targetBag, targetSlot)
		end
		-- wait for the bagDB to change
		private.newBagUpdate = false
		TSMAPI_FOUR.Thread.WaitForFunction(private.HasNewBagUpdate)
	end
end

function private.CombineSlotIdToBagSlot(combineSlotId)
	local sourceSlotId = combineSlotId % TARGET_SLOT_ID_MULTIPLIER
	local targetSlotId = floor(combineSlotId / TARGET_SLOT_ID_MULTIPLIER)
	return floor(sourceSlotId / SLOT_ID_BAG_MULTIPLIER), sourceSlotId % SLOT_ID_BAG_MULTIPLIER, floor(targetSlotId / SLOT_ID_BAG_MULTIPLIER), targetSlotId % SLOT_ID_BAG_MULTIPLIER
end

function private.HasNewBagUpdate()
	return private.newBagUpdate
end



-- ============================================================================
-- Destroy Thread
-- ============================================================================

function private.DestroyThread(button, row)
	private.destroyThreadRunning = true
	-- we get send a sync message so we run right away
	TSMAPI_FOUR.Thread.ReceiveMessage()

	local itemString = row:GetField("itemString")
	local spellId = row:GetField("destroySpellId")
	local spellName = GetSpellInfo(spellId)
	button:SetMacroText(format("/cast %s;\n/use %d %d", spellName, row:GetField("bag"), row:GetField("slot")))

	-- wait for the spell cast to start or fail
	private.pendingSpellId = spellId
	local event = TSMAPI_FOUR.Thread.ReceiveMessage()
	if event ~= "UNIT_SPELLCAST_START" then
		-- the spell cast failed for some reason
		ClearCursor()
		private.destroyThreadRunning = false
		return
	end

	-- discard any other messages
	TSMAPI_FOUR.Thread.Yield(true)
	while TSMAPI_FOUR.Thread.HasPendingMessage() do
		TSMAPI_FOUR.Thread.ReceiveMessage()
	end

	-- wait for the spell cast to finish
	local event = TSMAPI_FOUR.Thread.ReceiveMessage()
	if event ~= "UNIT_SPELLCAST_SUCCEEDED" then
		-- the spell cast was interrupted
		private.destroyThreadRunning = false
		return
	end

	-- wait for the loot window to open
	TSMAPI_FOUR.Thread.WaitForEvent("LOOT_OPENED")

	-- add to the log
	local newEntry = {
		item = itemString,
		time = time(),
		result = {},
	}
	assert(GetNumLootItems() > 0)
	for i = 1, GetNumLootItems() do
		local itemString = TSMAPI_FOUR.Item.ToItemString(GetLootSlotLink(i))
		local _, _, quantity = GetLootSlotInfo(i)
		if itemString and (quantity or 0) > 0 then
			itemString = GEM_CHIPS[itemString] or itemString
			newEntry.result[itemString] = quantity
		end
	end
	TSM.db.global.internalData.destroyingHistory[spellName] = TSM.db.global.internalData.destroyingHistory[spellName] or {}
	tinsert(TSM.db.global.internalData.destroyingHistory[spellName], newEntry)

	-- wait for the loot window to close
	TSMAPI_FOUR.Thread.WaitForEvent("LOOT_CLOSED")

	-- we're done
	private.destroyThreadRunning = false
end

function private.SpellCastEventHandler(event, unit, _, _, _, spellId)
	if not private.destroyThreadRunning or unit ~= "player" or spellId ~= private.pendingSpellId then
		return
	end
	TSMAPI_FOUR.Thread.SendMessage(private.destroyThread, event)
end



-- ============================================================================
-- Bag Update Functions
-- ============================================================================

function private.UpdateBagDB(isManual)
	private.bagDB:SetQueryUpdatesPaused(true)
	private.bagDB:Truncate()
	private.canDestroy = false
	wipe(private.pendingCombines)
	local itemPrevSlotId = TSMAPI_FOUR.Util.AcquireTempTable()
	for _, bag, slot, itemString, stackSize in TSMAPI_FOUR.Inventory.BagIterator(nil, TSM.db.global.destroyingOptions.includeSoulbound, TSM.db.global.destroyingOptions.includeSoulbound) do
		private.ProcessBagSlot(bag, slot, itemString, stackSize, itemPrevSlotId)
	end
	TSMAPI_FOUR.Util.ReleaseTempTable(itemPrevSlotId)
	if not isManual then
		private.newBagUpdate = true
	end
	private.bagDB:SetQueryUpdatesPaused(false)
	if private.bagUpdateCallback then
		private.bagUpdateCallback()
	end
end

function private.ProcessBagSlot(bag, slot, itemString, stackSize, itemPrevSlotId)
	if private.sessionIgnoreItems[itemString] or TSM.db.global.userData.destroyingIgnore[itemString] then
		return
	end

	local destroySpellId, destroyStackSize = private.IsDestroyable(itemString)
	if not destroySpellId then
		return
	end

	local deSpellName = GetSpellInfo(SPELL_IDS.disenchant)
	if destroySpellId == SPELL_IDS.disenchant then
		local deAbovePrice = TSMAPI_FOUR.CustomPrice.GetValue(TSM.db.global.destroyingOptions.deAbovePrice, itemString) or 0
		local deValue = TSMAPI_FOUR.CustomPrice.GetValue("Destroy", itemString) or math.huge
		if deValue < deAbovePrice then
			return
		end
	end

	local slotId = bag * SLOT_ID_BAG_MULTIPLIER + slot
	if stackSize >= destroyStackSize then
		private.bagDB:NewRow()
			:SetField("itemString", itemString)
			:SetField("itemLink", TSMAPI_FOUR.Item.GetLink(itemString))
			:SetField("bag", bag)
			:SetField("slot", slot)
			:SetField("slotId", slotId)
			:SetField("stackSize", stackSize)
			:SetField("destroySpellId", destroySpellId)
			:Save()
		private.canDestroy = true
	end

	if stackSize % destroyStackSize ~= 0 then
		if itemPrevSlotId[itemString] then
			-- we can combine this with the previous partial stack
			tinsert(private.pendingCombines, itemPrevSlotId[itemString] * TARGET_SLOT_ID_MULTIPLIER + slotId)
			itemPrevSlotId[itemString] = nil
		else
			itemPrevSlotId[itemString] = slotId
		end
	end
end

function private.IsDestroyable(itemString)
	if private.destroyQuantityCache[itemString] then
		return private.canDestroyCache[itemString], private.destroyQuantityCache[itemString]
	end

	-- disenchanting
	local quality = TSMAPI_FOUR.Item.GetQuality(itemString)
	if TSMAPI_FOUR.Item.IsDisenchantable(itemString) and quality <= TSM.db.global.destroyingOptions.deMaxQuality then
		private.canDestroyCache[itemString] = IsSpellKnown(SPELL_IDS.disenchant) and SPELL_IDS.disenchant
		private.destroyQuantityCache[itemString] = 1
		return private.canDestroyCache[itemString], private.destroyQuantityCache[itemString]
	end

	local destroyMethod, destroySpellId = nil, nil
	local classId = TSMAPI_FOUR.Item.GetClassId(itemString)
	local subClassId = TSMAPI_FOUR.Item.GetSubClassId(itemString)
	if classId == LE_ITEM_CLASS_TRADEGOODS and subClassId == ITEM_SUB_CLASS_HERB then
		destroyMethod = "mill"
		destroySpellId = SPELL_IDS.milling
	elseif classId == LE_ITEM_CLASS_TRADEGOODS and subClassId == ITEM_SUB_CLASS_METAL_AND_STONE then
		destroyMethod = "prospect"
		destroySpellId = SPELL_IDS.prospect
	else
		private.canDestroyCache[itemString] = false
		private.destroyQuantityCache[itemString] = nil
		return private.canDestroyCache[itemString], private.destroyQuantityCache[itemString]
	end

	for _, targetItem in ipairs(TSMAPI_FOUR.Conversions.GetTargetItemsByMethod(destroyMethod)) do
		local items = TSMAPI_FOUR.Conversions.GetData(targetItem)
		if items[itemString] then
			private.canDestroyCache[itemString] = IsSpellKnown(destroySpellId) and destroySpellId
			private.destroyQuantityCache[itemString] = 5
			return private.canDestroyCache[itemString], private.destroyQuantityCache[itemString]
		end
	end

	return private.canDestroyCache[itemString], private.destroyQuantityCache[itemString]
end
