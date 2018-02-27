-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

--- AuctionScrollingTable UI Element Class.
-- An auction scrolling table displays a scrollable list of auctions with a fixed set of columns. It operations on
-- auction records returned by the scanning code. It is a subclass of the @{FastScrollingTable} class.
-- @classmod AuctionScrollingTable

local _, TSM = ...
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local AuctionScrollingTable = TSMAPI_FOUR.Class.DefineClass("AuctionScrollingTable", TSM.UI.FastScrollingTable)
TSM.UI.AuctionScrollingTable = AuctionScrollingTable
local private = { sortContext = { baseRecordSortValues = {}, sortValueByHash = {}, baseItemStringByHash = {}, isBaseItemHash = {} }, rowFrameLookup = {} }
local AUCTION_PCT_COLORS = {
	{ -- blue
		color = "|cff2992ff",
		value = 50,
	},
	{ -- green
		color = "|cff16ff16",
		value = 80,
	},
	{ -- yellow
		color = "|cffffff00",
		value = 110,
	},
	{ -- orange
		color = "|cffff9218",
		value = 135,
	},
	{ -- red
		color = "|cffff0000",
		value = math.huge,
	},
}
local EXPANDER_LEFT_SPACING = 4
local EXPANDER_RIGHT_SPACING = 4
local ICON_SPACING = 4
local ICON_SIZE = 12
local INDENT_WIDTH = 8



-- ============================================================================
-- Public Class Methods
-- ============================================================================

function AuctionScrollingTable.__init(self)
	self.__super:__init()

	self._marketValueFunc = nil
	self._expanded = {}
	self._baseRecordByItem = {}
	self._baseRecordByHash = {}
	self._numAuctionsByItem = {}
	self._numAuctionsByHash = {}
end

function AuctionScrollingTable.Acquire(self)
	self.__super:Acquire()
	self:GetScrollingTableInfo()
		:NewColumn("item")
			:SetHeaderIndent("8")
			:SetTitles(L["Item"])
			:SetFont(TSM.UI.Fonts.FRIZQT)
			:SetFontHeight(12)
			:SetJustifyH("LEFT")
			:SetIconSize(ICON_SIZE)
			:SetTextFunction(private.GetItemCellText)
			:SetIconFunction(private.GetItemCellIcon)
			:SetTooltipFunction(private.GetItemCellTooltip)
			:Commit()
		:NewColumn("ilvl")
			:SetTitles(L["ilvl"])
			:SetWidth(32)
			:SetFont(TSM.UI.Fonts.RobotoMedium)
			:SetFontHeight(12)
			:SetJustifyH("RIGHT")
			:SetTextFunction(private.GetItemLevelCellText)
			:Commit()
		:NewColumn("auctions")
			:SetTitles(L["Auctions"])
			:SetWidth(64)
			:SetFont(TSM.UI.Fonts.RobotoMedium)
			:SetFontHeight(12)
			:SetJustifyH("RIGHT")
			:SetTextFunction(private.GetAuctionsCellText)
			:Commit()
		:NewColumn("timeLeft")
			:SetTitleIcon("iconPack.14x14/Clock")
			:SetWidth(40)
			:SetFont(TSM.UI.Fonts.RobotoRegular)
			:SetFontHeight(12)
			:SetJustifyH("RIGHT")
			:SetTextFunction(private.GetTimeLeftCellText)
			:Commit()
		:NewColumn("seller")
			:SetTitles(L["Seller"])
			:SetWidth(80)
			:SetFont(TSM.UI.Fonts.FRIZQT)
			:SetFontHeight(12)
			:SetJustifyH("LEFT")
			:SetTextFunction(private.GetSellerCellText)
			:Commit()
		:NewColumn("bid")
			:SetTitles(L["Bid (item)"], L["Bid (stack)"])
			:SetWidth(115)
			:SetFont(TSM.UI.Fonts.RobotoMedium)
			:SetFontHeight(12)
			:SetJustifyH("RIGHT")
			:SetTextFunction(private.GetBidCellText)
			:Commit()
		:NewColumn("buyout")
			:SetTitles(L["Buyout (item)"], L["Buyout (stack)"])
			:SetWidth(115)
			:SetFont(TSM.UI.Fonts.RobotoMedium)
			:SetFontHeight(12)
			:SetJustifyH("RIGHT")
			:SetTextFunction(private.GetBuyoutCellText)
			:Commit()
		:NewColumn("pct")
			:SetTitles(L["%"])
			:SetWidth(40)
			:SetFont(TSM.UI.Fonts.RobotoRegular)
			:SetFontHeight(12)
			:SetJustifyH("RIGHT")
			:SetTextFunction(private.GetPercentCellText)
			:Commit()
		:SetDefaultSort("pct", true)
		:Commit()
end

function AuctionScrollingTable.Release(self)
	self._marketValueFunc = nil
	wipe(self._expanded)
	wipe(self._baseRecordByItem)
	wipe(self._baseRecordByHash)
	wipe(self._numAuctionsByItem)
	wipe(self._numAuctionsByHash)
	for _, row in ipairs(self._rows) do
		private.rowFrameLookup[row._frame] = nil
		row._frame:SetScript("OnDoubleClick", nil)
		for _, tooltipFrame in pairs(row._buttons) do
			tooltipFrame:SetScript("OnDoubleClick", nil)
		end
	end
	self.__super:Release()
end

--- Sets the market value function.
-- @tparam AuctionScrollingTable self The auction scrolling table object
-- @tparam function func The function to call with the item DB record to get the market value
-- @treturn AuctionScrollingTable The auction scrolling table object
function AuctionScrollingTable.SetMarketValueFunction(self, func)
	self._marketValueFunc = func
	return self
end

--- Gets the selected auction record.
-- @tparam AuctionScrollingTable self The auction scrolling table object
-- @return The selected auction record or nil if there's no selection
function AuctionScrollingTable.GetSelectedRecord(self)
	local selection = self:GetSelection()
	return selection and self._baseRecordByHash[selection] or nil
end

--- Expands a single auction result.
-- If there is a single top-level auction result, this will cause it to be expanded. Otherwise, this does nothing.
-- @tparam AuctionScrollingTable self The auction scrolling table object
-- @treturn AuctionScrollingTable The auction scrolling table object
function AuctionScrollingTable.ExpandSingleResult(self)
	-- if only one result, expand it
	local singleResult = nil
	for baseItemString in pairs(self._baseRecordByItem) do
		if not singleResult then
			singleResult = baseItemString
		elseif singleResult then
			singleResult = nil
			break
		end
	end
	if singleResult then
		self._expanded[singleResult] = true
		self:_UpdateData()
		self:Draw()
	end
end



-- ============================================================================
-- Private Class Methods
-- ============================================================================

function AuctionScrollingTable._UpdateData(self, queryChanged)
	if queryChanged then
		wipe(self._expanded)
	end
	local sortKey = self._sortCol:_GetId()

	wipe(self._data)
	wipe(self._baseRecordByItem)
	wipe(self._baseRecordByHash)
	wipe(self._numAuctionsByItem)
	wipe(self._numAuctionsByHash)

	local hashes = TSMAPI_FOUR.Util.AcquireTempTable()
	local sortAscending = self._sortAscending
	local showingAltTitles = self._showingAltTitles
	for _, record in self._query:Iterator(true) do
		local baseItemString = record.baseItemString
		local hash = record.hash
		local sortValue = private.sortContext.sortValueByHash[hash]
		if not sortValue then
			if sortKey == "item" then
				sortValue = TSMAPI_FOUR.Item.GetName(baseItemString)
			elseif sortKey == "ilvl" then
				sortValue = TSMAPI_FOUR.Item.GetItemLevel(record:GetField("itemString"))
			elseif sortKey == "auctions" then
				sortValue = record.stackSize
			elseif sortKey == "timeLeft" then
				sortValue = record.timeLeft
			elseif sortKey == "seller" then
				sortValue = record.seller
			elseif sortKey == "bid" then
				sortValue = record[showingAltTitles and "displayedBid" or "itemDisplayedBid"]
			elseif sortKey == "buyout" then
				local buyout = record[showingAltTitles and "buyout" or "itemBuyout"]
				sortValue = buyout == 0 and (sortAscending and math.huge or -math.huge) or buyout
			elseif sortKey == "pct" then
				local pct = self:_GetRecordMarketValuePct(record)
				sortValue = pct or (sortAscending and math.huge or -math.huge)
			else
				sortValue = self._sortCol:_GetSortValue(record)
			end
			private.sortContext.sortValueByHash[hash] = sortValue
		end
		if not private.sortContext.baseItemStringByHash[hash] then
			-- insert the hash
			tinsert(hashes, hash)
			private.sortContext.baseItemStringByHash[hash] = baseItemString
		end

		-- determine if this comes before the current base record
		local baseRecordSortValue = private.sortContext.baseRecordSortValues[baseItemString]
		if not baseRecordSortValue or (sortAscending and sortValue < baseRecordSortValue) or (not sortAscending and sortValue > baseRecordSortValue) then
			local prevRecord = self._baseRecordByItem[baseItemString]
			self._baseRecordByItem[baseItemString] = record
			private.sortContext.isBaseItemHash[record.hash] = true
			if prevRecord then
				private.sortContext.isBaseItemHash[prevRecord.hash] = nil
			end
			private.sortContext.baseRecordSortValues[baseItemString] = sortValue
		end

		-- count the number of auctions grouped by hash
		if not self._numAuctionsByHash[hash] then
			self._numAuctionsByItem[baseItemString] = (self._numAuctionsByItem[baseItemString] or 0) + 1
			self._numAuctionsByHash[hash] = 0
		end
		self._numAuctionsByHash[hash] = self._numAuctionsByHash[hash] + 1

		-- use the highest filterId record so more recent auctions show up first in sniper
		if not self._baseRecordByHash[hash] or record.filterId > self._baseRecordByHash[hash].filterId then
			self._baseRecordByHash[hash] = record
			-- need to make sure _baseRecordByHash and _baseRecordByItem are kept in sync
			if private.sortContext.baseRecordSortValues[baseItemString] == sortValue then
				local prevRecord = self._baseRecordByItem[baseItemString]
				self._baseRecordByItem[baseItemString] = record
				private.sortContext.isBaseItemHash[record.hash] = true
				if prevRecord then
					private.sortContext.isBaseItemHash[prevRecord.hash] = nil
				end
			end
		end
	end

	-- sort the data
	sort(hashes, sortAscending and private.SortByHashAscendingHelper or private.SortByHashDescendingHelper)

	-- populate the visible rows
	for _, hash in ipairs(hashes) do
		if not self:_IsDataHidden(hash) then
			tinsert(self._data, hash)
		end
	end

	TSMAPI_FOUR.Util.ReleaseTempTable(hashes)
	sort(self._data, sortAscending and private.SortByHashAscendingHelper or private.SortByHashDescendingHelper)
	wipe(private.sortContext.sortValueByHash)
	wipe(private.sortContext.baseRecordSortValues)
	wipe(private.sortContext.baseItemStringByHash)
	wipe(private.sortContext.isBaseItemHash)

	-- reselect the row in case the grouping changed
	local newSelection = self:GetSelection()
	if newSelection and (not self._baseRecordByHash[newSelection] or self:_IsDataHidden(newSelection)) then
		newSelection = nil
	end
	self:SetSelection(newSelection)
end

function AuctionScrollingTable._IsDataHidden(self, hash)
	local record = self._baseRecordByHash[hash]
	local baseItemString = record.baseItemString
	if not self._expanded[baseItemString] and record ~= self._baseRecordByItem[baseItemString] then
		-- this item is collapsed and this is not the top auction for it
		return true
	end
	return false
end

function AuctionScrollingTable._GetTableRow(self, isHeader)
	local row = self.__super:_GetTableRow(isHeader)
	if not isHeader then
		for _, tooltipFrame in pairs(row._buttons) do
			tooltipFrame:SetScript("OnDoubleClick", private.TooltipFrameOnDoubleClick)
		end
		row._frame:SetScript("OnDoubleClick", private.RowOnDoubleClick)
		private.rowFrameLookup[row._frame] = row

		local prevText = nil
		for i, col in ipairs(self._tableInfo:_GetCols()) do
			if col:_GetId() == "item" then
				if i > 1 then
					local prevCol = self._tableInfo:_GetCols()[i-1]
					prevText = row._texts[prevCol:_GetId()]
				end
				break
			end
		end

		-- add the expander texture before the first col
		local expander = row:_GetTexture()
		TSM.UI.TexturePacks.SetSize(expander, "iconPack.10x10/Carot/Collapsed")
		if prevText then
			expander:SetPoint("LEFT", prevText, "RIGHT", 16, 0)
		else
			expander:SetPoint("LEFT", EXPANDER_LEFT_SPACING, 0)
		end
		row._icons.expander = expander

		local expanderBtn = row:_GetButton()
		expanderBtn:SetAllPoints(expander)
		expanderBtn:SetScript("OnClick", private.ExpanderOnClick)
		row._buttons.expander = expanderBtn

		local icon = row._icons.item
		icon:ClearAllPoints()
		icon:SetPoint("LEFT", expander, "RIGHT", EXPANDER_RIGHT_SPACING, 0)
	end
	return row
end

function AuctionScrollingTable._SetRowData(self, row, data)
	local record = self._baseRecordByHash[data]
	local baseItemString = record:GetField("baseItemString")
	local isIndented = self._expanded[baseItemString] and record ~= self._baseRecordByItem[baseItemString]
	local expander = row._icons.expander
	if not isIndented and self._numAuctionsByItem[baseItemString] > 1 then
		TSM.UI.TexturePacks.SetTextureAndSize(expander, self._expanded[baseItemString] and "iconPack.10x10/Carot/Expanded" or "iconPack.10x10/Carot/Collapsed")
		expander:Show()
		row._buttons.expander:Show()
	else
		expander:Hide()
		row._buttons.expander:Hide()
	end
	row._icons.item:SetPoint("LEFT", expander, "RIGHT", EXPANDER_RIGHT_SPACING + (isIndented and INDENT_WIDTH or 0), 0)
	self.__super:_SetRowData(row, data)
end

function AuctionScrollingTable._GetRecordMarketValuePct(self, record)
	if not self._marketValueFunc then
		-- no market value function was set
		return nil, nil
	end
	local marketValue = self._marketValueFunc(record) or 0
	if marketValue == 0 then
		-- this item doesn't have a market value
		return nil, nil
	end
	if record:GetField("itemBuyout") > 0 then
		-- calculate just the buyout market value
		return record:GetField("itemBuyout") / marketValue, nil
	else
		-- calculate the bid market value since there's no buyout
		return nil, record:GetField("itemDisplayedBid") / marketValue
	end
end



-- ============================================================================
-- Local Script Handlers
-- ============================================================================

function private.RowOnDoubleClick(frame)
	local self = private.rowFrameLookup[frame]
	local scrollingTable = self._scrollingTable
	local baseItemString = scrollingTable._baseRecordByHash[self:GetData()]:GetField("baseItemString")
	scrollingTable._expanded[baseItemString] = not scrollingTable._expanded[baseItemString]
	local selection = scrollingTable:GetSelection()
	if selection and scrollingTable:_IsDataHidden(selection) then
		scrollingTable:SetSelection(nil)
	end
	scrollingTable:_UpdateData()
	scrollingTable:Draw()
end

function private.ExpanderOnClick(button)
	private.RowOnDoubleClick(button:GetParent())
end

function private.TooltipFrameOnDoubleClick(tooltipFrame, ...)
	local row = tooltipFrame:GetParent()
	row:GetScript("OnDoubleClick")(row, ...)
end



-- ============================================================================
-- Private Helper Functions
-- ============================================================================

function private.SortByHashAscendingHelper(a, b)
	local sortContext = private.sortContext
	local aBaseItemString = sortContext.baseItemStringByHash[a]
	local bBaseItemString = sortContext.baseItemStringByHash[b]
	if aBaseItemString == bBaseItemString then
		local aSortValue = sortContext.sortValueByHash[a]
		local bSortValue = sortContext.sortValueByHash[b]
		if aSortValue == bSortValue then
			-- always show base records first
			if sortContext.isBaseItemHash[a] then
				return true
			elseif sortContext.isBaseItemHash[b] then
				return false
			else
				return a < b
			end
		end
		return aSortValue < bSortValue
	else
		-- we're sorting different items
		local aSortValue = sortContext.baseRecordSortValues[aBaseItemString]
		local bSortValue = sortContext.baseRecordSortValues[bBaseItemString]
		if aSortValue == bSortValue then
			return a < b
		end
		return aSortValue < bSortValue
	end
end

function private.SortByHashDescendingHelper(a, b)
	local sortContext = private.sortContext
	local aBaseItemString = sortContext.baseItemStringByHash[a]
	local bBaseItemString = sortContext.baseItemStringByHash[b]
	if aBaseItemString == bBaseItemString then
		local aSortValue = sortContext.sortValueByHash[a]
		local bSortValue = sortContext.sortValueByHash[b]
		if aSortValue == bSortValue then
			-- always show base records first
			if sortContext.isBaseItemHash[a] then
				return true
			elseif sortContext.isBaseItemHash[b] then
				return false
			else
				return a > b
			end
		end
		return aSortValue > bSortValue
	else
		-- we're sorting different items
		local aSortValue = sortContext.baseRecordSortValues[aBaseItemString]
		local bSortValue = sortContext.baseRecordSortValues[bBaseItemString]
		if aSortValue == bSortValue then
			return a > b
		end
		return aSortValue > bSortValue
	end
end

function private.GetItemCellText(self, context)
	local record = self._baseRecordByHash[context]
	local baseItemString = record:GetField("baseItemString")
	local isIndented = self._expanded[baseItemString] and record ~= self._baseRecordByItem[baseItemString]
	return TSM.UI.GetColoredItemName(record:GetField("itemLink"), isIndented and 0.8 or 1)
end

function private.GetItemLevelCellText(self, context)
	local record = self._baseRecordByHash[context]
	return TSMAPI_FOUR.Item.GetItemLevel(record:GetField("itemLink"))
end

function private.GetAuctionsCellText(self, context)
	local record = self._baseRecordByHash[context]
	local baseItemString = record:GetField("baseItemString")
	local canExpand = self._numAuctionsByItem[baseItemString] > 1 and not self._expanded[baseItemString]
	local numAuctions = self._numAuctionsByHash[record:GetField("hash")]
	return format("%d |cffaaaaaaof|r %d", numAuctions, record:GetField("stackSize"))
end

function private.GetTimeLeftCellText(self, context)
	local record = self._baseRecordByHash[context]
	return TSM.UI.GetTimeLeftString(record:GetField("timeLeft"))
end

function private.GetSellerCellText(self, context)
	local record = self._baseRecordByHash[context]
	return record:GetField("seller")
end

function private.GetBidCellText(self, context)
	local record = self._baseRecordByHash[context]
	return TSMAPI_FOUR.Money.ToString(record:GetField(self._showingAltTitles and "displayedBid" or "itemDisplayedBid"), "OPT_PAD")
end

function private.GetBuyoutCellText(self, context)
	local record = self._baseRecordByHash[context]
	return TSMAPI_FOUR.Money.ToString(record:GetField(self._showingAltTitles and "buyout" or "itemBuyout"), "OPT_PAD")
end

function private.GetPercentCellText(self, context)
	local record = self._baseRecordByHash[context]
	local pct, bidPct = self:_GetRecordMarketValuePct(record)
	local pctColor = "|cffffffff"
	if pct then
		pct = TSMAPI_FOUR.Util.Round(100 * pct)
		for i, info in ipairs(AUCTION_PCT_COLORS) do
			if pct < info.value then
				pctColor = info.color
				break
			end
		end
	elseif bidPct then
		pctColor = "|cffbbbbbb"
		pct = TSMAPI_FOUR.Util.Round(100 * bidPct)
	end
	if pct and pct > 999 then
		pct = ">999"
	end
	return pct and format("%s%s%%|r", pctColor, pct) or "---"
end

function private.GetItemCellIcon(self, context)
	local record = self._baseRecordByHash[context]
	return record:GetField("texture")
end

function private.GetItemCellTooltip(self, context)
	local record = self._baseRecordByHash[context]
	return record:GetField("itemString")
end
