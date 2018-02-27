-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

--- Item Info Functions
-- @module ItemInfo

local _, TSM = ...
local ItemInfo = TSM:NewPackage("ItemInfo")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = { maxLoadedIndex = nil, itemStringLookup = {}, names = nil, newData = {}, pendingItems = {} }
local MAX_REQUESTED_ITEM_INFO = 100
local UNKNOWN_ITEM_NAME = L["Unknown Item"]
local DB_VERSION = 2
local RECORD_DATA_LENGTH = 17
local FIELDS = { "itemLevel", "minLevel", "maxStack", "vendorSell", "bitfield", "invSlotId", "texture", "classId", "subClassId" }
local FIELD_INFO = {
	itemLevel = { offset = 0, length = 2 },
	minLevel = { offset = 2, length = 1 },
	maxStack = { offset = 3, length = 2 },
	vendorSell = { offset = 5, length = 4 },
	bitfield = { offset = 9, length = 1 },
	invSlotId = { offset = 10, length = 1 },
	texture = { offset = 11, length = 4 },
	classId = { offset = 15, length = 1 },
	subClassId = { offset = 16, length = 1 },
}
local BITFIELD_INFO = {
	quality = { offset = 0, length = 4 },
	isBOP = { offset = 4, length = 2 },
	isCraftingReagent = { offset = 6, length = 2 },
}
do
	local offset = 0
	for _, field in ipairs(FIELDS) do
		local info = FIELD_INFO[field]
		assert(info and info.offset == offset)
		offset = offset + info.length
	end
	assert(offset == RECORD_DATA_LENGTH)
	for _, info in pairs(BITFIELD_INFO) do
		info.mask = bit.lshift(2 ^ info.length - 1, info.offset)
	end
end



-- ============================================================================
-- Module Functions
-- ============================================================================

function ItemInfo.OnInitialize()
	-- load hard-coded vendor costs
	for itemString, cost in pairs(TSM.CONST.VENDOR_SELL_PRICES) do
		TSM.db.global.internalData.vendorItems[itemString] = TSM.db.global.internalData.vendorItems[itemString] or cost
	end

	TSMAPI_FOUR.Event.Register("GET_ITEM_INFO_RECEIVED", function(_, itemId)
		private.StoreGetItemInfo("i:"..itemId)
	end)

	-- load the item info database
	if not TSMItemInfoDB or TSMItemInfoDB.version ~= DB_VERSION or TSMItemInfoDB.locale ~= GetLocale() or TSMItemInfoDB.build ~= GetBuildInfo() then
		TSMItemInfoDB = {
			names = nil,
			itemStrings = nil,
			data = "",
		}
	end
	private.names = TSMItemInfoDB and TSMItemInfoDB.names and TSMAPI_FOUR.Util.SafeStrSplit(TSMItemInfoDB.names, "\0") or {}
	private.maxLoadedIndex = #private.names
	if TSMItemInfoDB.itemStrings then
		for i, itemString in ipairs(TSMAPI_FOUR.Util.SafeStrSplit(TSMItemInfoDB.itemStrings, "\0")) do
			private.itemStringLookup[itemString] = i
		end
	end
	TSM:LOG_INFO("Imported %d items worth of data", #private.names)

	-- process pending item info every 0.1 seconds
	TSMAPI_FOUR.Delay.AfterTime(0, private.ProcessItemInfo, 0.1)
	-- scan the merchant every 0.5 seconds (will be a no-op if it's not visible)
	TSMAPI_FOUR.Delay.AfterTime(0, private.ScanMerchant, 0.5)
end

function ItemInfo.OnDisable()
	-- save the DB
	if not TSMItemInfoDB then
		-- bailing if TSMItemInfoDB doesn't exist gives us an easy way to wipe the DB via "/run TSMItemInfoDB = nil"
		return
	end
	local newNames = {}
	local newItemStrings = {}
	local newDataParts = {}
	for itemString, index in pairs(private.itemStringLookup) do
		tinsert(newNames, private.names[index])
		tinsert(newItemStrings, itemString)
		local newDataStr = nil
		if index > private.maxLoadedIndex then
			newDataStr = ""
			for _, field in pairs(FIELDS) do
				newDataStr = newDataStr..private.EncodeNumber(private.newData[itemString][field], FIELD_INFO[field].length)
			end
		else
			newDataStr = strsub(TSMItemInfoDB.data, RECORD_DATA_LENGTH * (index - 1) + 1, RECORD_DATA_LENGTH * index)
		end
		tinsert(newDataParts, newDataStr)
	end
	TSMItemInfoDB.names = #newNames > 0 and table.concat(newNames, "\0") or nil
	TSMItemInfoDB.itemStrings = #newItemStrings > 0 and table.concat(newItemStrings, "\0") or nil
	TSMItemInfoDB.data = table.concat(newDataParts)

	TSMItemInfoDB.version = DB_VERSION
	TSMItemInfoDB.locale = GetLocale()
	TSMItemInfoDB.build = GetBuildInfo()
	TSMItemInfoDB.saveTime = nil
end

--- Store the name of an item.
-- This function is used to opportunistically populate the item cache with item names.
-- @tparam string itemString The itemString
-- @tparam string name The item name
function TSM.ItemInfo.StoreItemName(itemString, name)
	local index = private.GetItemRecordIndex(itemString)
	if private.names[index] == "" then
		private.names[index] = name
	end
end

--- Get the itemString from an item name.
-- This API will return the base itemString when there are multiple variants with the same name and will return nil if
-- there are multiple distinct items with the same name.
-- @tparam string name The item name
-- @treturn ?string The itemString
function TSM.ItemInfo.ItemNameToItemString(name)
	local result = nil
	for itemString, index in pairs(private.itemStringLookup) do
		if private.names[index] == name then
			if result then
				-- multiple matching items
				if TSMAPI_FOUR.Item.ToBaseItemString(itemString) == TSMAPI_FOUR.Item.ToBaseItemString(result) then
					result = TSMAPI_FOUR.Item.ToBaseItemString(itemString)
				else
					return TSM.CONST.UNKNOWN_ITEM_ITEMSTRING
				end
			end
			result = itemString
		end
	end
	return result
end



-- ============================================================================
-- TSMAPI Functions
-- ============================================================================

--- Get the name.
-- @tparam string item The item
-- @treturn ?string The name
function TSMAPI_FOUR.Item.GetName(item)
	local itemString = TSMAPI_FOUR.Item.ToItemString(item)
	if not itemString then return end
	if itemString == TSM.CONST.UNKNOWN_ITEM_ITEMSTRING then
		return UNKNOWN_ITEM_NAME
	end
	local speciesId = strmatch(itemString, "p:([0-9]+)")
	if speciesId then
		local name, texture = C_PetJournal.GetPetInfoBySpeciesID(tonumber(speciesId))
		-- name is equal to the speciesId if it's invalid, so check the texture instead
		if not texture then return end
		return name
	else
		local name = private.names[private.GetItemRecordIndex(itemString)]
		if name == "" then
			-- if we got passed an item link, we can maybe extract the name from it
			name = strmatch(item, "^\124cff[0-9a-z]+\124[Hh].+\124h%[(.+)%]\124h\124r$")
			if name == "" or name == UNKNOWN_ITEM_NAME then
				name = nil
			end

			TSMAPI_FOUR.Item.FetchInfo(itemString)
		end
		return name
	end
end

--- Get the link.
-- @tparam string item The item
-- @treturn string The link or an "Unknown Item" link
function TSMAPI_FOUR.Item.GetLink(item)
	local itemString = TSMAPI_FOUR.Item.ToItemString(item)
	if not itemString then return end
	local link = nil
	local itemStringType, speciesId, level, quality, health, power, speed, petId = strsplit(":", itemString)
	if itemStringType == "p" then
		local name = TSMAPI_FOUR.Item.GetName(item) or UNKNOWN_ITEM_NAME
		local fullItemString = strjoin(":", speciesId, level or "", quality or "", health or "", power or "", speed or "", petId or "")
		local quality = tonumber(quality) or 0
		local qualityColor = ITEM_QUALITY_COLORS[quality] and ITEM_QUALITY_COLORS[quality].hex or "|cffff0000"
		link = qualityColor.."|Hbattlepet:"..fullItemString.."|h["..name.."]|h|r"
	else
		local name = TSMAPI_FOUR.Item.GetName(item) or UNKNOWN_ITEM_NAME
		local quality = TSMAPI_FOUR.Item.GetQuality(item)
		local qualityColor = ITEM_QUALITY_COLORS[quality] and ITEM_QUALITY_COLORS[quality].hex or "|cffff0000"
		link = qualityColor.."|H"..TSMAPI_FOUR.Item.ToWowItemString(itemString).."|h["..name.."]|h|r"
	end
	return link
end

--- Get the quality.
-- @tparam string item The item
-- @treturn ?number The quality
function TSMAPI_FOUR.Item.GetQuality(item)
	local itemString = TSMAPI_FOUR.Item.ToItemString(item)
	if not itemString then return end
	local itemStringType, _, _, quality = strsplit(":", itemString)
	if itemStringType == "p" then
		-- we can get the quality directly from the itemString
		return tonumber(quality) or 0
	else
		local quality = private.GetBitfield(itemString, "quality")
		if not quality then
			if strmatch(itemString, "^i:[0-9]+:[%-0-9]+$") then
				-- there is a random enchant, but no bonusIds, so the quality is the same as the base item
				quality = TSMAPI_FOUR.Item.GetQuality(TSMAPI_FOUR.Item.ToBaseItemString(itemString))
			elseif strmatch(itemString, "^i:[0-9]+:[0-9]*:[0-9]+") then
				-- this item has bonusIds
				local classId = TSMAPI_FOUR.Item.GetClassId(itemString)
				if classId and classId ~= LE_ITEM_CLASS_WEAPON and classId ~= LE_ITEM_CLASS_ARMOR then
					-- the bonusId does not affect the quality of this item
					quality = TSMAPI_FOUR.Item.GetQuality(TSMAPI_FOUR.Item.ToBaseItemString(itemString))
				end
			end
			if quality then
				private.SetBitfield(itemString, "quality", quality)
			end
			TSMAPI_FOUR.Item.FetchInfo(itemString)
		end
		return quality
	end
end

--- Get the quality color.
-- @tparam string item The item
-- @treturn ?string The quality color string
function TSMAPI_FOUR.Item.GetQualityColor(item)
	local itemString = TSMAPI_FOUR.Item.ToItemString(item)
	local quality = TSMAPI_FOUR.Item.GetQuality(itemString)
	return ITEM_QUALITY_COLORS[quality] and ITEM_QUALITY_COLORS[quality].hex
end

--- Get the item level.
-- @tparam string item The item
-- @treturn ?number The item level
function TSMAPI_FOUR.Item.GetItemLevel(item)
	local itemString = TSMAPI_FOUR.Item.ToItemString(item)
	if not itemString then return end
	local itemStringType, _, itemLevel = strsplit(":", itemString)
	if itemStringType == "p" then
		-- we can get the level directly from the itemString
		return tonumber(itemLevel) or 0
	else
		local itemLevel = private.GetField(itemString, "itemLevel")
		if not itemLevel then
			if strmatch(itemString, "^i:[0-9]+:[%-0-9]+$") then
				-- there is a random enchant, but no bonusIds, so the itemLevel is the same as the base item
				itemLevel = TSMAPI_FOUR.Item.GetItemLevel(TSMAPI_FOUR.Item.ToBaseItemString(itemString))
			end
			if itemLevel then
				private.SetField(itemString, "itemLevel", itemLevel)
			end
			TSMAPI_FOUR.Item.FetchInfo(itemString)
		end
		return itemLevel
	end
end

--- Get the min level.
-- @tparam string item The item
-- @treturn ?number The min level
function TSMAPI_FOUR.Item.GetMinLevel(item)
	local itemString = TSMAPI_FOUR.Item.ToItemString(item)
	if not itemString then return end
	if strmatch(itemString, "^p:") then
		-- min level is always 0 for battlepets
		return 0
	else
		local minLevel = private.GetField(itemString, "minLevel")
		if not minLevel then
			if strmatch(itemString, "^i:[0-9]+:[%-0-9]+$") then
				-- there is a random enchant, but no bonusIds, so the itemLevel is the same as the base item
				minLevel = TSMAPI_FOUR.Item.GetMinLevel(TSMAPI_FOUR.Item.ToBaseItemString(itemString))
			else
				local baseItemString = TSMAPI_FOUR.Item.ToBaseItemString(itemString)
				local classId = TSMAPI_FOUR.Item.GetClassId(itemString)
				local subClassId = TSMAPI_FOUR.Item.GetClassId(itemString)
				if itemString ~= baseItemString and classId and subClassId and classId ~= LE_ITEM_CLASS_WEAPON and classId ~= LE_ITEM_CLASS_ARMOR and (classId ~= LE_ITEM_CLASS_GEM or subClassId ~= LE_ITEM_GEM_ARTIFACTRELIC) then
					-- the bonusId does not affect the minLevel of this item
					minLevel = TSMAPI_FOUR.Item.GetMinLevel(baseItemString)
				end
			end
			if minLevel then
				private.SetField(itemString, "minLevel", minLevel)
			end
			TSMAPI_FOUR.Item.FetchInfo(itemString)
		end
		return minLevel
	end
end

--- Get the max stack size.
-- @tparam string item The item
-- @treturn ?number The max stack size
function TSMAPI_FOUR.Item.GetMaxStack(item)
	local itemString = TSMAPI_FOUR.Item.ToItemString(item)
	if not itemString then return end
	if strmatch(itemString, "^p:") then
		-- min level is always 1 for battlepets
		return 1
	else
		local maxStack = private.GetField(itemString, "maxStack")
		if not maxStack then
			local baseItemString = TSMAPI_FOUR.Item.ToBaseItemString(itemString)
			if itemString ~= baseItemString then
				-- the maxStack is the same as the base item
				maxStack = TSMAPI_FOUR.Item.GetMaxStack(baseItemString)
			end
			if not maxStack then
				-- we might be able to deduce the maxStack based on the classId and subClassId
				local classId = TSMAPI_FOUR.Item.GetClassId(item)
				local subClassId = TSMAPI_FOUR.Item.GetClassId(item)
				if classId and subClassId then
					if classId == 1 then
						maxStack = 1
					elseif classId == 2 then
						maxStack = 1
					elseif classId == 4 then
						if subClassId > 0 then
							maxStack = 1
						end
					elseif classId == 15 then
						if subClassId == 5 then
							maxStack = 1
						end
					elseif classId == 16 then
						maxStack = 20
					elseif classId == 17 then
						maxStack = 1
					elseif classId == 18 then
						maxStack = 1
					end
				end
			end
			if maxStack then
				private.SetField(itemString, "maxStack", maxStack)
			end
			TSMAPI_FOUR.Item.FetchInfo(itemString)
		end
		return maxStack
	end
end

--- Get the inventory slot id.
-- @tparam string item The item
-- @treturn ?number The inventory slot id
function TSMAPI_FOUR.Item.GetInvSlotId(item)
	local itemString = TSMAPI_FOUR.Item.ToItemString(item)
	if not itemString then return end
	local invSlotId = private.GetField(itemString, "invSlotId")
	if not invSlotId then
		-- the invSlotId is the same for the base item
		local baseItemString = TSMAPI_FOUR.Item.ToBaseItemString(itemString)
		if baseItemString ~= itemString then
			return TSMAPI_FOUR.Item.GetInvSlotId(baseItemString)
		end
	end
	if not invSlotId then
		private.StoreGetItemInfoInstant(itemString)
		invSlotId = private.GetField(itemString, "invSlotId")
	end
	return invSlotId
end

--- Get the texture.
-- @tparam string item The item
-- @treturn ?number The texture
function TSMAPI_FOUR.Item.GetTexture(item)
	local itemString = TSMAPI_FOUR.Item.ToItemString(item)
	if not itemString then return end
	local texture = private.GetField(itemString, "texture")
	if not texture then
		-- the texture is the same for the base item (at least as far as we care)
		local baseItemString = TSMAPI_FOUR.Item.ToBaseItemString(itemString)
		if baseItemString ~= itemString then
			return TSMAPI_FOUR.Item.GetTexture(baseItemString)
		end
	end
	if not texture then
		private.StoreGetItemInfoInstant(itemString)
		texture = private.GetField(itemString, "texture")
	end
	return texture
end

--- Get the vendor sell price.
-- @tparam string item The item
-- @treturn ?number The vendor sell price
function TSMAPI_FOUR.Item.GetVendorSell(item)
	local itemString = TSMAPI_FOUR.Item.ToItemString(item)
	if not itemString then return end
	if strmatch(itemString, "^p:") then
		-- battlepets can't be sold to a vendor
		return
	else
		local vendorSell = private.GetField(itemString, "vendorSell")
		if not vendorSell then
			TSMAPI_FOUR.Item.FetchInfo(itemString)
		end
		return vendorSell
	end
end

--- Get the class id.
-- @tparam string item The item
-- @treturn ?number The class id
function TSMAPI_FOUR.Item.GetClassId(item)
	local itemString = TSMAPI_FOUR.Item.ToItemString(item)
	if not itemString then return end
	local classId = private.GetField(itemString, "classId")
	if not classId then
		-- the classId is the same for the base item
		local baseItemString = TSMAPI_FOUR.Item.ToBaseItemString(itemString)
		if baseItemString ~= itemString then
			return TSMAPI_FOUR.Item.GetClassId(baseItemString)
		end
	end
	if not classId then
		private.StoreGetItemInfoInstant(itemString)
		classId = private.GetField(itemString, "classId")
	end
	return classId
end

--- Get the sub-class id.
-- @tparam string item The item
-- @treturn ?number The sub-class id
function TSMAPI_FOUR.Item.GetSubClassId(item)
	local itemString = TSMAPI_FOUR.Item.ToItemString(item)
	if not itemString then return end
	local subClassId = private.GetField(itemString, "subClassId")
	if not subClassId then
		-- the subClassId is the same for the base item
		local baseItemString = TSMAPI_FOUR.Item.ToBaseItemString(itemString)
		if baseItemString ~= itemString then
			return TSMAPI_FOUR.Item.GetSubClassId(baseItemString)
		end
	end
	if not subClassId then
		private.StoreGetItemInfoInstant(itemString)
		subClassId = private.GetField(itemString, "subClassId")
	end
	return subClassId
end


--- Get whether or not the item is bind on pickup.
-- @tparam string item The item
-- @treturn boolean Whether or not the item is bind on pickup
function TSMAPI_FOUR.Item.IsSoulbound(item)
	local itemString = TSMAPI_FOUR.Item.ToItemString(item)
	if not itemString then return end
	if strmatch(itemString, "^p:") then
		-- battlepets are never soulbound
		return false
	else
		local isBOP = private.GetBitfield(itemString, "isBOP")
		if isBOP == nil then
			local baseItemString = TSMAPI_FOUR.Item.ToBaseItemString(itemString)
			if itemString ~= baseItemString then
				-- the bindType is the same as the base item
				isBOP = TSMAPI_FOUR.Item.IsSoulbound(baseItemString)
			end
			if isBOP ~= nil then
				private.SetBitfield(itemString, "isBOP", isBOP and 1 or 0)
			end
			TSMAPI_FOUR.Item.FetchInfo(itemString)
		else
			isBOP = isBOP == 1
		end
		return isBOP
	end
end

--- Get whether or not the item is a crafting reagent.
-- @tparam string item The item
-- @treturn boolean Whether or not the item is a crafting reagent
function TSMAPI_FOUR.Item.IsCraftingReagent(item)
	local itemString = TSMAPI_FOUR.Item.ToItemString(item)
	if not itemString then return end
	if strmatch(itemString, "^p:") then
		-- battlepets are never crafting reagents
		return false
	else
		local isCraftingReagent = private.GetBitfield(itemString, "isCraftingReagent")
		if isCraftingReagent == nil then
			local baseItemString = TSMAPI_FOUR.Item.ToBaseItemString(itemString)
			if itemString ~= baseItemString then
				-- the isCraftingReagent field is the same as the base item
				isCraftingReagent = TSMAPI_FOUR.Item.IsCraftingReagent(baseItemString)
			end
			if isCraftingReagent ~= nil then
				private.SetBitfield(itemString, "isCraftingReagent", isCraftingReagent and 1 or 0)
			end
			TSMAPI_FOUR.Item.FetchInfo(itemString)
		else
			isCraftingReagent = isCraftingReagent == 1
		end
		return isCraftingReagent
	end
end

--- Get whether or not the item is a soulbound material.
-- @tparam string item The item
-- @treturn boolean Whether or not the item is a soulbound material
function TSMAPI_FOUR.Item.IsSoulboundMat(item)
	local itemString = TSMAPI_FOUR.Item.ToItemString(item)
	if not itemString then return end
	return TSM.CONST.SOULBOUND_CRAFTING_MATS[itemString]
end

--- Get the vendor buy price.
-- @tparam string item The item
-- @treturn ?number The vendor buy price
function TSMAPI_FOUR.Item.GetVendorBuy(item)
	local itemString = TSMAPI_FOUR.Item.ToItemString(item)
	if not itemString then return end
	return TSM.db.global.internalData.vendorItems[itemString]
end

--- Get whether or not the item is disenchantable.
-- @tparam string item The item
-- @treturn ?boolean Whether or not the item is disenchantable (nil means we don't know)
function TSMAPI_FOUR.Item.IsDisenchantable(item)
	local itemString = TSMAPI_FOUR.Item.ToItemString(item)
	if not itemString then return end
	if TSM.CONST.NON_DISENCHANTABLE_ITEMS[itemString] then return end
	local quality = TSMAPI_FOUR.Item.GetQuality(itemString)
	local classId = TSMAPI_FOUR.Item.GetClassId(itemString)
	if not quality or not classId then
		return nil
	end
	return quality >= LE_ITEM_QUALITY_UNCOMMON and (classId == LE_ITEM_CLASS_ARMOR or classId == LE_ITEM_CLASS_WEAPON)
end

--- Fetch info for the item.
-- This function can be called ahead of time for items which we know we need to have info cached for.
-- @tparam string item The item
function TSMAPI_FOUR.Item.FetchInfo(item)
	local itemString = TSMAPI_FOUR.Item.ToItemString(item)
	if not itemString then return end
	if strmatch(itemString, "^p:") then
		-- no point in fetching info for battlepets
		return
	end
	private.pendingItems[itemString] = true
end

--- Generalize an item link.
-- @tparam string itemLink The item link
-- @treturn ?string The generalized link
function TSMAPI_FOUR.Item.GeneralizeLink(itemLink)
	local itemString = TSMAPI_FOUR.Item.ToItemString(itemLink)
	if not itemString then return end
	if not strmatch(itemString, "p:") and not strmatch(itemString, "i:[0-9]+:[0-9%-]*:[0-9]*") then
		-- swap out the itemString part of the link
		local leader, quality, _, name, trailer, trailer2, extra = ("\124"):split(itemLink)
		if trailer2 and not extra then
			return strjoin("\124", leader, quality, "H"..TSMAPI_FOUR.Item.ToWowItemString(itemString), name, trailer, trailer2)
		end
	end
	return TSMAPI_FOUR.Item.GetLink(itemString)
end



-- ============================================================================
-- Helper Functions
-- ============================================================================

function private.ProcessItemInfo()
	local toRemove = TSMAPI_FOUR.Util.AcquireTempTable()
	local numRequested = 0
	for itemString in pairs(private.pendingItems) do
		local index = private.itemStringLookup[itemString]
		if index and private.names[index] ~= "" then
			-- we have info for this item
			tinsert(toRemove, itemString)
		elseif numRequested < MAX_REQUESTED_ITEM_INFO then
			-- request info for this item
			if not private.StoreGetItemInfo(itemString) then
				numRequested = numRequested + 1
			end
		end
	end
	for _, itemString in ipairs(toRemove) do
		private.pendingItems[itemString] = nil
	end
	TSMAPI_FOUR.Util.ReleaseTempTable(toRemove)
end

function private.ScanMerchant()
	for i = 1, GetMerchantNumItems() do
		local itemString = TSMAPI_FOUR.Item.ToItemString(GetMerchantItemLink(i))
		if itemString then
			local price, quantity, _, _, _, extendedCost = select(3, GetMerchantItemInfo(i))
			-- bug with big keech vendor returning extendedCost = true for gold only items so need to check GetMerchantItemCostInfo
			if price > 0 and (not extendedCost or GetMerchantItemCostInfo(i) == 0) then
				TSM.db.global.internalData.vendorItems[itemString] = TSMAPI_FOUR.Util.Round(price / quantity)
			else
				TSM.db.global.internalData.vendorItems[itemString] = nil
			end
		end
	end
end

function private.EncodeNumber(value, length)
	if value == nil then
		value = 2 ^ (length * 8) - 1
	end
	if length == 1 then
		return strchar(value)
	elseif length == 2 then
		return strchar(value % 256, value / 256)
	elseif length == 3 then
		return strchar(value % 256, (value % 65536) / 256, value / 65536)
	elseif length == 4 then
		return strchar(value % 256, (value % 65536) / 256, (value % 16777216) / 65536, value / 16777216)
	else
		error("Invalid length: "..tostring(length))
	end
end

function private.DecodeNumber(str, length, offset)
	offset = (offset or 0) + 1
	local value = nil
	if length == 1 then
		value = strbyte(str, offset)
	elseif length == 2 then
		value = strbyte(str, offset) + strbyte(str, offset + 1) * 256
	elseif length == 3 then
		value = strbyte(str, offset) + strbyte(str, offset + 1) * 256 + strbyte(str, offset + 2) * 65536
	elseif length == 4 then
		value = strbyte(str, offset) + strbyte(str, offset + 1) * 256 + strbyte(str, offset + 2) * 65536 + strbyte(str, offset + 3) * 16777216
	else
		error("Invalid length: "..tostring(length))
	end
	-- a max value indiciates nil
	if value == 2 ^ (length * 8) - 1 then
		return
	end
	return value
end

function private.CreateNewRecord(itemString, copyIndex)
	assert(not copyIndex or copyIndex <= private.maxLoadedIndex)
	-- create a new record for this item
	local index = #private.names + 1
	private.names[index] = copyIndex and private.names[copyIndex] or ""
	private.itemStringLookup[itemString] = index
	private.newData[itemString] = {}
	for key, info in pairs(FIELD_INFO) do
		private.newData[itemString][key] = copyIndex and private.DecodeNumber(TSMItemInfoDB.data, info.length, info.offset + RECORD_DATA_LENGTH * (copyIndex - 1)) or (2 ^ (info.length * 8) - 1)
	end
	return index
end

function private.GetItemRecordIndex(itemString)
	return private.itemStringLookup[itemString] or private.CreateNewRecord(itemString)
end

function private.GetField(itemString, key)
	local index = private.GetItemRecordIndex(itemString)
	if index > private.maxLoadedIndex then
		-- this is new data so get it directly
		local value = private.newData[itemString][key]
		if value == 2 ^ (FIELD_INFO[key].length * 8) - 1 then
			-- all high bits means it wasn't yet set
			value = nil
		end
		return value
	else
		-- get the field from the DB string
		return private.DecodeNumber(TSMItemInfoDB.data, FIELD_INFO[key].length, FIELD_INFO[key].offset + RECORD_DATA_LENGTH * (index - 1))
	end
end

function private.SetField(itemString, key, value)
	-- validate that the value can actually be encoded later and avoid crashes during logout
	-- note needs to be max length -2 as max length -1 is used to indicate nil
	assert(value >= 0 and value <= 2 ^ (FIELD_INFO[key].length * 8) - 2)
	local index = private.GetItemRecordIndex(itemString)
	if index <= private.maxLoadedIndex then
		-- "delete" the existing record and copy the existing data to a new one
		private.CreateNewRecord(itemString, index)
	end
	private.newData[itemString][key] = value
end

function private.GetBitfield(itemString, key)
	local value = private.GetField(itemString, "bitfield")
	if not value then return end

	value = bit.band(value, BITFIELD_INFO[key].mask)
	if value == BITFIELD_INFO[key].mask then
		-- all high bits indicates a nil value
		return nil
	end
	return bit.rshift(value, BITFIELD_INFO[key].offset)
end

function private.SetBitfield(itemString, key, value)
	value = bit.lshift(value, BITFIELD_INFO[key].offset)
	assert(bit.band(value, BITFIELD_INFO[key].mask) == value)
	local bitfieldValue = private.GetField(itemString, "bitfield") or (2 ^ (FIELD_INFO.bitfield.length * 8) - 1)
	bitfieldValue = bit.band(bitfieldValue, bit.bnot(BITFIELD_INFO[key].mask))
	bitfieldValue = bit.bor(bitfieldValue, value)
	private.SetField(itemString, "bitfield", bitfieldValue)
end

function private.StoreGetItemInfoInstant(itemString)
	local itemStringType, id = strmatch(itemString, "^([pi]):([0-9]+)")
	id = tonumber(id)

	if itemStringType == "i" then
		local _, classStr, subClassStr, equipSlot, texture, classId, subClassId = GetItemInfoInstant(id)
		if not texture then
			return
		end
		-- some items (such as i:37445) give a classId of -1 for some reason in which case we can look up the classId
		if classId < 0 then
			classId = TSMAPI_FOUR.Item.GetClassIdFromClassString(classStr)
			assert(subClassStr == "")
			subClassId = 0
		end
		private.SetField(itemString, "texture", texture)
		private.SetField(itemString, "classId", classId)
		private.SetField(itemString, "subClassId", subClassId)
		private.SetField(itemString, "invSlotId", TSMAPI_FOUR.Item.GetInventorySlotIdFromInventorySlotString(equipSlot) or 0)
		local baseItemString = TSMAPI_FOUR.Item.ToBaseItemString(itemString)
		if baseItemString ~= itemString then
			private.SetField(baseItemString, "texture", texture)
			private.SetField(baseItemString, "classId", classId)
			private.SetField(baseItemString, "subClassId", subClassId)
			private.SetField(baseItemString, "invSlotId", TSMAPI_FOUR.Item.GetInventorySlotIdFromInventorySlotString(equipSlot) or 0)
		end
	elseif itemStringType == "p" then
		local _, texture, petTypeId = C_PetJournal.GetPetInfoBySpeciesID(id)
		if not texture then
			return
		end
		private.SetField(itemString, "texture", texture)
		private.SetField(itemString, "classId", LE_ITEM_CLASS_BATTLEPET)
		private.SetField(itemString, "subClassId", petTypeId - 1)
		private.SetField(itemString, "invSlotId", 0)
		local baseItemString = TSMAPI_FOUR.Item.ToBaseItemString(itemString)
		if baseItemString ~= itemString then
			private.SetField(baseItemString, "texture", texture)
			private.SetField(baseItemString, "classId", LE_ITEM_CLASS_BATTLEPET)
			private.SetField(baseItemString, "subClassId", petTypeId - 1)
			private.SetField(baseItemString, "invSlotId", 0)
		end
	else
		assert("Invalid itemString: "..itemString)
	end
end

function private.StoreGetItemInfo(itemString)
	local wowItemString = TSMAPI_FOUR.Item.ToWowItemString(itemString)
	local baseItemString = TSMAPI_FOUR.Item.ToBaseItemString(itemString)
	local baseWowItemString = TSMAPI_FOUR.Item.ToWowItemString(baseItemString)

	-- store info for the base item
	local name, _, quality, itemLevel, minLevel, _, _, maxStack, _, _, vendorSell, _, _, bindType, _, _, isCraftingReagent = GetItemInfo(baseWowItemString)
	if name then
		private.SetField(baseItemString, "minLevel", minLevel)
		private.SetField(baseItemString, "itemLevel", itemLevel)
		-- some items (i.e. "i:40752" produce a very high max stack, so cap it)
		maxStack = min(maxStack, 2 ^ (8 * FIELD_INFO.maxStack.length) - 2)
		private.SetField(baseItemString, "maxStack", maxStack)
		private.SetField(baseItemString, "vendorSell", vendorSell)
		private.SetBitfield(baseItemString, "quality", quality)
		private.SetBitfield(baseItemString, "isBOP", (bindType == LE_ITEM_BIND_ON_ACQUIRE or bindType == LE_ITEM_BIND_QUEST) and 1 or 0)
		private.SetBitfield(baseItemString, "isCraftingReagent", isCraftingReagent and 1 or 0)
		-- need to set at least one other field before the name to create the record
		private.names[private.GetItemRecordIndex(baseItemString)] = name
	end

	-- store info for the specific item if it's different
	if itemString ~= baseItemString then
		-- get new values of the fields which can change from the base item
		name, _, quality, _, minLevel = GetItemInfo(wowItemString)
		itemLevel = GetDetailedItemLevelInfo(wowItemString)
		if name then
			private.SetBitfield(itemString, "quality", quality)
			-- some items (i.e. "i:117356::1:573") produce an negative min level
			minLevel = max(minLevel, 0)
			private.SetField(itemString, "minLevel", minLevel)
			-- need to set at least one other field before the name to create the record
			private.names[private.GetItemRecordIndex(itemString)] = name
		end
		if itemLevel then
			private.SetField(itemString, "itemLevel", itemLevel)
		end
		if maxStack then
			-- some items (i.e. "i:40752" produce a very high max stack, so cap it)
			maxStack = min(maxStack, 2 ^ (8 * FIELD_INFO.maxStack.length) - 2)
			private.SetField(itemString, "maxStack", maxStack)
			private.SetField(itemString, "vendorSell", vendorSell)
			private.SetBitfield(itemString, "isBOP", (bindType == LE_ITEM_BIND_ON_ACQUIRE or bindType == LE_ITEM_BIND_QUEST) and 1 or 0)
			private.SetBitfield(itemString, "isCraftingReagent", isCraftingReagent and 1 or 0)
		end
	end

	return name ~= nil
end
