-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

--- Fast Scrolling Table UI Element Class.
-- A fast scrolling table contains a scrollable list of rows with a fixed set of columns. It is a subclass of the
-- @{Element} class.
-- @classmod FastScrollingTable

local _, TSM = ...
local FastScrollingTable = TSMAPI_FOUR.Class.DefineClass("FastScrollingTable", TSM.UI.Element)
TSM.UI.FastScrollingTable = FastScrollingTable
local TableRow = TSMAPI_FOUR.Class.DefineClass("TableRow")
local private = {
	recycledRows = {},
	queryFastScrollingTableLookup = {},
	frameFastScrollingTableLookup = {},
	rowFrameLookup = {},
	sortContext = nil,
	sortValues = {},
}
local ROW_PADDING = 8
local ICON_SPACING = 4
local MOUSE_WHEEL_SCROLL_AMOUNT = 60
local HEADER_HEIGHT = 22
local HEADER_LINE_HEIGHT = 2



-- ============================================================================
-- FastScrollingTable - Public Class Methods
-- ============================================================================

function FastScrollingTable.__init(self)
	local frame = CreateFrame("Frame", nil, nil, nil)

	self.__super:__init(frame)

	frame.backgroundTexture = frame:CreateTexture(nil, "BACKGROUND")
	frame.backgroundTexture:SetAllPoints()

	frame.line = frame:CreateTexture(nil, "ARTWORK")
	frame.line:SetPoint("TOPLEFT", 0, -HEADER_HEIGHT)
	frame.line:SetPoint("TOPRIGHT", 0, -HEADER_HEIGHT)
	frame.line:SetHeight(HEADER_LINE_HEIGHT)
	frame.line:SetColorTexture(TSM.UI.HexToRGBA("#9d9d9d"))

	self._scrollFrame = CreateFrame("ScrollFrame", nil, frame, nil)
	self._scrollFrame:SetPoint("TOPLEFT", 0, -HEADER_HEIGHT - HEADER_LINE_HEIGHT)
	self._scrollFrame:SetPoint("BOTTOMRIGHT")

	self._scrollFrame:EnableMouseWheel(true)
	self._scrollFrame:SetScript("OnUpdate", private.FrameOnUpdate)
	self._scrollFrame:SetScript("OnMouseWheel", private.FrameOnMouseWheel)
	private.frameFastScrollingTableLookup[self._scrollFrame] = self

	self._scrollbar = TSM.UI.CreateScrollbar(self._scrollFrame, 0)

	self._content = CreateFrame("Frame", nil, self._scrollFrame)
	self._content:SetPoint("TOPLEFT")
	self._content:SetPoint("TOPRIGHT")
	self._scrollFrame:SetScrollChild(self._content)

	self._rows = {}
	self._query = nil
	self._data = {}
	self._scrollValue = 0
	self._onSelectionChangedHandler = nil
	self._onRowClickHandler = nil
	self._selection = nil
	self._selectionDisabled = nil
	self._selectionValidator = nil
	self._tableInfo = TSM.UI.Util.ScrollingTableInfo()
	self._header = nil
	self._sortCol = nil
	self._sortAscending = nil
	self._sortSecondaryComparator = nil
end

function FastScrollingTable.Acquire(self)
	self._tableInfo:_Acquire(self)
	self._scrollValue = 0
	self._scrollbar:SetScript("OnValueChanged", private.OnScrollbarValueChangedNoDraw)
	self._scrollbar:SetMinMaxValues(0, self:_GetMaxScroll())
	-- don't want to cause this element to be drawn for this initial scrollbar change
	self._scrollbar:SetValue(0)
	self._scrollbar:SetScript("OnValueChanged", private.OnScrollbarValueChanged)

	self._scrollbar:ClearAllPoints()
	self._scrollbar:SetWidth(self:_GetStyle("scrollbarWidth"))
	self._scrollbar:SetPoint("TOPRIGHT", -self:_GetStyle("scrollbarMargin"), -self:_GetStyle("scrollbarMargin"))
	self._scrollbar:SetPoint("BOTTOMRIGHT", -self:_GetStyle("scrollbarMargin"), self:_GetStyle("scrollbarMargin"))
	self._scrollbar.thumb:SetWidth(self:_GetStyle("scrollbarThumbWidth"))
	self._scrollbar.thumb:SetColorTexture(TSM.UI.HexToRGBA(self:_GetStyle("scrollbarThumbBackground")))

	self.__super:Acquire()
end

function FastScrollingTable.Release(self)
	if self._header then
		self._header:Release()
		tinsert(private.recycledRows, self._header)
		self._header = nil
	end
	for _, row in ipairs(self._rows) do
		row:Release()
		tinsert(private.recycledRows, row)
	end
	wipe(self._rows)
	self._tableInfo:_Release()
	wipe(self._data)
	self._onSelectionChangedHandler = nil
	self._onRowClickHandler = nil
	self._selection = nil
	self._selectionDisabled = nil
	self._selectionValidator = nil
	if self._query then
		self._query:SetUpdateCallback()
		private.queryFastScrollingTableLookup[self._query] = nil
		self._query = nil
	end
	self._sortCol = nil
	self._sortAscending = nil
	self._sortSecondaryComparator = nil
	self.__super:Release()
end

--- Sets the @{DatabaseQuery} source for this table.
-- This query is used to populate the entries in the fast scrolling table.
-- @tparam FastScrollingTable self The fast scrolling table object
-- @tparam DatabaseQuery query The query object
-- @tparam[opt=false] bool redraw Whether or not to redraw the scrolling table
-- @treturn FastScrollingTable The fast scrolling table object
function FastScrollingTable.SetQuery(self, query, redraw)
	if query == self._query and not redraw then
		return self
	end
	if self._query then
		self._query:SetUpdateCallback()
		private.queryFastScrollingTableLookup[self._query] = nil
	end
	self._query = query
	private.queryFastScrollingTableLookup[self._query] = self
	self._query:SetUpdateCallback(private.QueryUpdateCallback)
	self:_UpdateData(true)

	if redraw then
		self:Draw()
	end

	return self
end

--- Gets the @{ScrollingTableInfo} object.
-- @tparam FastScrollingTable self The fast scrolling table object
function FastScrollingTable.GetScrollingTableInfo(self)
	return self._tableInfo
end

--- Commits the scrolling table info.
-- This should be called once the scrolling table info is completely set (retrieved via @{FastScrollingTable.GetScrollingTableInfo}).
-- @tparam FastScrollingTable self The fast scrolling table object
-- @treturn FastScrollingTable The fast scrolling table object
function FastScrollingTable.CommitTableInfo(self)
	if self._header then
		self._header:Release()
	end
	self._header = self:_GetTableRow(true)
	self._header:SetBackgroundColor(self:_GetStyle("headerBackground"))
	self._header:SetHeight(HEADER_HEIGHT)
	local sortDefaultKey, sortDefaultAscending, sortSecondaryComparator = self._tableInfo:_GetSortInfo()
	if sortDefaultKey then
		for _, col in ipairs(self._tableInfo:_GetCols()) do
			if col:_GetId() == sortDefaultKey then
				self._sortCol = col
				break
			end
		end
		assert(self._sortCol)
		self._sortAscending = sortDefaultAscending
		self._sortSecondaryComparator = sortSecondaryComparator
	end
	return self
end

--- Registers a script handler.
-- @tparam FastScrollingTable self The fast scrolling table object
-- @tparam string script The script to register for (supported scripts: `OnSelectionChanged`, `OnRowClick`)
-- @tparam function handler The script handler which will be called with the fast scrolling table object followed by any
-- arguments to the script
-- @treturn FastScrollingTable The fast scrolling table object
function FastScrollingTable.SetScript(self, script, handler)
	if script == "OnSelectionChanged" then
		self._onSelectionChangedHandler = handler
	elseif script == "OnRowClick" then
		self._onRowClickHandler = handler
	else
		error("Unknown FastScrollingTable script: "..tostring(script))
	end
	return self
end

--- Sets the select record.
-- @tparam FastScrollingTable self The fast scrolling table object
-- @param selection The selected record or nil to clear the selection
-- @treturn FastScrollingTable The fast scrolling table object
function FastScrollingTable.SetSelection(self, selection)
	if selection and self._selectionValidator and not self:_selectionValidator(selection) then
		return self
	end
	if selection and not TSMAPI_FOUR.Util.TableKeyByValue(self._data, selection) then
		selection = nil
	end
	self._selection = selection
	if selection then
		-- set the scroll so that the selection is visible if necessary
		local rowHeight = self:_GetStyle("rowHeight")
		local index = TSMAPI_FOUR.Util.GetDistinctTableKey(self._data, selection)
		local firstVisibleIndex = ceil(self._scrollValue / rowHeight) + 1
		local lastVisibleIndex = floor((self._scrollValue + self:_GetDimension("HEIGHT")) / rowHeight)
		if lastVisibleIndex > firstVisibleIndex and (index < firstVisibleIndex or index > lastVisibleIndex) then
			self:_OnScrollValueChanged(min((index - 1) * rowHeight, self:_GetMaxScroll()))
		end
	end
	for _, row in ipairs(self._rows) do
		if not row:IsMouseOver() and row:GetData() ~= selection then
			row:SetHighlightVisible(false)
		end
	end
	if self._onSelectionChangedHandler then
		self:_onSelectionChangedHandler()
	end
	return self
end

--- Gets the currently selected record.
-- @tparam FastScrollingTable self The fast scrolling table object
-- @return The selected record or nil if there's nothing selected
function FastScrollingTable.GetSelection(self)
	return self._selection
end

--- Gets the data record at the specified index.
-- @tparam FastScrollingTable self The fast scrolling table object
-- @tparam number index The index to get the data at
-- @return The data record
function FastScrollingTable.GetDataByIndex(self, index)
	return self._data[index]
end

--- Sets a selection validator function.
-- @tparam FastScrollingTable self The fast scrolling table object
-- @tparam function validator A function which gets called with the fast scrolling table object and a record to validate
-- whether or not it's selectable (returns true if it is, false otherwise)
-- @treturn FastScrollingTable The fast scrolling table object
function FastScrollingTable.SetSelectionValidator(self, validator)
	self._selectionValidator = validator
	return self
end

--- Sets whether or not selection is disabled.
-- @tparam FastScrollingTable self The fast scrolling table object
-- @tparam boolean disabled Whether or not to disable selection
-- @treturn FastScrollingTable The fast scrolling table object
function FastScrollingTable.SetSelectionDisabled(self, disabled)
	self._selectionDisabled = disabled
	return self
end

function FastScrollingTable.Draw(self)
	self.__super:Draw()
	self:_ApplyFrameBackgroundTexture()

	if self._sortCol then
		self._header:SetSort(self._sortCol:_GetId(), self._sortAscending)
	else
		self._header:SetSort(nil, nil)
	end

	local rowHeight = self:_GetStyle("rowHeight")
	local totalHeight = #self._data * rowHeight
	local visibleHeight = self._scrollFrame:GetHeight()
	local numVisibleRows = ceil(visibleHeight / rowHeight)
	local scrollOffset = min(self._scrollValue, self:_GetMaxScroll())
	local dataOffset = floor(scrollOffset / rowHeight)

	self._scrollbar.thumb:SetHeight(min(visibleHeight / 2, self:_GetStyle("scrollbarThumbHeight")))
	self._scrollbar:SetMinMaxValues(0, self:_GetMaxScroll())
	self._scrollbar:SetValue(scrollOffset)
	self._content:SetWidth(self._scrollFrame:GetWidth())
	self._content:SetHeight(numVisibleRows * rowHeight)

	if TSMAPI_FOUR.Util.Round(scrollOffset + visibleHeight) == totalHeight then
		-- we are at the bottom
		self._scrollFrame:SetVerticalScroll(numVisibleRows * rowHeight - visibleHeight)
	else
		self._scrollFrame:SetVerticalScroll(0)
	end

	while #self._rows < numVisibleRows do
		local row = self:_GetTableRow(false)
		if #self._rows == 0 then
			row._frame:SetPoint("TOPLEFT", self._content)
			row._frame:SetPoint("TOPRIGHT", self._content)
		else
			row._frame:SetPoint("TOPLEFT", self._rows[#self._rows]._frame, "BOTTOMLEFT")
			row._frame:SetPoint("TOPRIGHT", self._rows[#self._rows]._frame, "BOTTOMRIGHT")
		end
		tinsert(self._rows, row)
	end

	local altBackground = self:_GetStyle("altBackground")
	for i, row in ipairs(self._rows) do
		local dataIndex = i + dataOffset
		local data = self._data[dataIndex]
		if i > numVisibleRows or not data then
			row:SetVisible(false)
		else
			local topInset, bottomInset = 0, 0
			if i == 1 then
				-- this is the first visible row so might have an inset at the top
				topInset = max(scrollOffset % rowHeight, 0)
			end
			if i == numVisibleRows then
				-- this is the last visible row so might have an inset at the bottom
				bottomInset = max((numVisibleRows + dataOffset) * rowHeight - (scrollOffset + visibleHeight), 0)
			end
			self:_SetRowData(row, data)
			row:SetBackgroundColor(dataIndex % 2 == 1 and "#00000000" or altBackground)
			row:SetHeight(rowHeight)
			row:SetHitRectInsets(0, 0, topInset, bottomInset)
			row:SetVisible(true)
		end
	end
end



-- ============================================================================
-- FastScrollingTable - Private Class Methods
-- ============================================================================

function FastScrollingTable._SetRowData(self, row, data)
	if data == self._selection then
		row:SetHighlightVisible(true)
	elseif not row:IsMouseOver() then
		row:SetHighlightVisible(false)
	end
	row:SetData(data)
end

function FastScrollingTable._GetTableRow(self, isHeader)
	local row = tremove(private.recycledRows)
	if not row then
		row = TableRow()
	end
	row:Acquire(self, isHeader)
	return row
end

function FastScrollingTable._OnScrollValueChanged(self, value, noDraw)
	self._scrollValue = value
	if not noDraw then
		self:Draw()
	end
end

function FastScrollingTable._GetMaxScroll(self)
	return max(#self._data * self:_GetStyle("rowHeight") - self._scrollFrame:GetHeight(), 0)
end

function FastScrollingTable._UpdateData(self, queryChanged)
	wipe(self._data)
	for _, record in self._query:Iterator(true) do
		tinsert(self._data, record)
		if self._sortCol then
			-- pre-compute the sort value for every record to speed up the sort
			private.sortValues[record] = self._sortCol:_GetSortValue(record)
		end
	end

	if self._sortCol then
		private.sortContext = self
		sort(self._data, self._sortAscending and private.DataSortAscending or private.DataSortDescending)
		private.sortContext = nil
		wipe(private.sortValues)
	end
end

function FastScrollingTable._ToggleSort(self, id)
	if not self._sortCol or not self._query then
		-- sorting disabled so ignore
		return
	end

	local sortCol = nil
	for _, col in ipairs(self._tableInfo:_GetCols()) do
		if col:_GetId() == id then
			sortCol = col
		end
	end
	assert(sortCol)
	if sortCol == self._sortCol then
		self._sortAscending = not self._sortAscending
	else
		self._sortCol = sortCol
		self._sortAscending = true
	end
	self:_UpdateData()
	self:Draw()
end



-- ============================================================================
-- FastScrollingTable - Local Script Handlers
-- ============================================================================

function private.QueryUpdateCallback(query)
	local self = private.queryFastScrollingTableLookup[query]
	self:_UpdateData()
	self:Draw()
end

function private.OnScrollbarValueChanged(scrollbar, value)
	local self = private.frameFastScrollingTableLookup[scrollbar:GetParent()]
	value = max(min(value, self:_GetMaxScroll()), 0)
	self:_OnScrollValueChanged(value)
end

function private.OnScrollbarValueChangedNoDraw(scrollbar, value)
	local self = private.frameFastScrollingTableLookup[scrollbar:GetParent()]
	value = max(min(value, self:_GetMaxScroll()), 0)
	self:_OnScrollValueChanged(value, true)
end

function private.FrameOnUpdate(frame)
	local self = private.frameFastScrollingTableLookup[frame]
	if frame:IsMouseOver() and self:_GetMaxScroll() > 0 then
		self._scrollbar:Show()
	else
		self._scrollbar:Hide()
	end
end

function private.FrameOnMouseWheel(frame, direction)
	local self = private.frameFastScrollingTableLookup[frame]
	local scrollAmount = MOUSE_WHEEL_SCROLL_AMOUNT
	self._scrollbar:SetValue(self._scrollbar:GetValue() + -1 * direction * scrollAmount)
end



-- ============================================================================
-- Private Helper Functions
-- ============================================================================

function private.DataSortAscending(a, b)
	local aValue = private.sortValues[a]
	local bValue = private.sortValues[b]
	if aValue == bValue then
		if private.sortContext._sortSecondaryComparator then
			return private.sortContext:_sortSecondaryComparator(a, b)
		else
			return tostring(a) < tostring(b)
		end
	end
	return aValue < bValue
end

function private.DataSortDescending(a, b)
	local aValue = private.sortValues[a]
	local bValue = private.sortValues[b]
	if aValue == bValue then
		if private.sortContext._sortSecondaryComparator then
			return private.sortContext:_sortSecondaryComparator(a, b)
		else
			return tostring(a) > tostring(b)
		end
	end
	return aValue > bValue
end



-- ============================================================================
-- TableRow - Public Class Methods
-- ============================================================================

function TableRow.__init(self)
	self._scrollingTable = nil
	self._cols = nil
	self._rowData = nil
	self._texts = {}
	self._icons = {}
	self._buttons = {}
	self._sortIcons = {}
	self._recycled = { buttons = {}, texts = {}, icons = {} }

	local frame = CreateFrame("Button", nil, nil, nil)
	self._frame = frame
	private.rowFrameLookup[frame] = self

	frame.background = frame:CreateTexture(nil, "BACKGROUND")
	frame.background:SetAllPoints()

	frame.highlight = frame:CreateTexture(nil, "ARTWORK", -1)
	frame.highlight:SetAllPoints()
	frame.highlight:Hide()
end

function TableRow.Acquire(self, scrollingTable, isHeader)
	self._scrollingTable = scrollingTable
	self._cols = self._scrollingTable._tableInfo:_GetCols()

	self._frame:SetParent(isHeader and self._scrollingTable:_GetBaseFrame() or self._scrollingTable._content)
	self._frame:Show()
	self._frame.highlight:SetColorTexture(TSM.UI.HexToRGBA(self._scrollingTable:_GetStyle("highlight")))

	if isHeader then
		self:_CreateHeaderRowCols()
		self._frame:SetPoint("TOPLEFT")
		self._frame:SetPoint("TOPRIGHT")
		self:_LayoutHeaderRow()
	else
		self:_CreateDataRowCols()
		self._frame:SetScript("OnEnter", private.RowOnEnter)
		self._frame:SetScript("OnLeave", private.RowOnLeave)
		self._frame:SetScript("OnClick", private.RowOnClick)
		self:_LayoutDataRow()
	end
end

function TableRow.Release(self)
	self._scrollingTable = nil
	self._cols = nil
	self._rowData = nil
	self._frame:ClearAllPoints()
	self._frame:SetParent(nil)
	self._frame:SetScript("OnEnter", nil)
	self._frame:SetScript("OnLeave", nil)
	self._frame:SetScript("OnClick", nil)
	for _, text in pairs(self._texts) do
		text:ClearAllPoints()
		text:SetWidth(0)
		text:SetHeight(0)
		text:SetTextColor(1, 1, 1, 1)
		text:Hide()
		tinsert(self._recycled.texts, text)
	end
	wipe(self._texts)
	for _, icon in pairs(self._icons) do
		icon:SetDrawLayer("ARTWORK", 0)
		icon:SetTexture(nil)
		icon:SetTexCoord(0, 0, 0, 1, 1, 0, 1, 1)
		icon:SetColorTexture(0, 0, 0, 0)
		icon:SetVertexColor(1, 1, 1, 1)
		icon:ClearAllPoints()
		icon:SetWidth(0)
		icon:SetHeight(0)
		icon:Hide()
		tinsert(self._recycled.icons, icon)
	end
	wipe(self._icons)
	for _, tooltip in pairs(self._buttons) do
		tooltip:SetScript("OnEnter", nil)
		tooltip:SetScript("OnLeave", nil)
		tooltip:SetScript("OnClick", nil)
		tooltip:ClearAllPoints()
		tooltip:SetWidth(0)
		tooltip:SetHeight(0)
		tooltip:Hide()
		tinsert(self._recycled.buttons, tooltip)
	end
	wipe(self._buttons)
	for _, icon in pairs(self._sortIcons) do
		icon.direction = nil
		icon:ClearAllPoints()
		icon:SetWidth(0)
		icon:SetHeight(0)
		icon:Hide()
		tinsert(self._recycled.icons, icon)
	end
	wipe(self._sortIcons)
	self._frame:Hide()
end

function TableRow.SetData(self, data)
	for _, col in ipairs(self._cols) do
		local id = col:_GetId()
		self._texts[id]:SetText(col:_GetText(data))
		if col:_GetIconSize() then
			self._icons[id]:SetTexture(col:_GetIcon(data))
		end
	end
	self._rowData = data
end

function TableRow.GetData(self)
	return self._rowData
end

function TableRow.SetHeight(self, height)
	for _, text in pairs(self._texts) do
		text:SetHeight(height)
	end
	for _, btn in pairs(self._buttons) do
		btn:SetHeight(height)
	end
	self._frame:SetHeight(height)
end

function TableRow.SetBackgroundColor(self, color)
	self._frame.background:SetColorTexture(TSM.UI.HexToRGBA(color))
end

function TableRow.SetVisible(self, visible)
	if visible == self._frame:IsVisible() then
		return
	end
	if visible then
		self._frame:Show()
		self._frame.highlight:Hide()
	else
		self._frame:Hide()
	end
end

function TableRow.SetHighlightVisible(self, visible)
	if visible then
		self._frame.highlight:Show()
	else
		self._frame.highlight:Hide()
	end
end

function TableRow.IsMouseOver(self)
	return self._frame:IsMouseOver()
end

function TableRow.SetHitRectInsets(self, left, right, top, bottom)
	for _, tooltipFrame in pairs(self._buttons) do
		tooltipFrame:SetHitRectInsets(left, right, top, bottom)
	end
	self._frame:SetHitRectInsets(left, right, top, bottom)
end

function TableRow.SetSort(self, sortId, sortAscending)
	local didChange = false
	-- clear all the other sorts
	for id, sortIcon in pairs(self._sortIcons) do
		if id ~= sortId then
			didChange = didChange or sortIcon.direction ~= nil
			sortIcon.direction = nil
		end
	end
	if sortId then
		-- set the sort
		local sortIcon = self._sortIcons[sortId]
		assert(sortIcon)
		didChange = didChange or sortIcon.direction ~= sortAscending
		sortIcon.direction = sortAscending
	end
	if didChange then
		self:_LayoutHeaderRow()
	end
end



-- ============================================================================
-- TableRow - Private Class Methods
-- ============================================================================

function TableRow._GetFontString(self)
	local fontString = tremove(self._recycled.texts)
	if not fontString then
		fontString = self._frame:CreateFontString()
	end
	fontString:Show()
	return fontString
end

function TableRow._GetTexture(self)
	local texture = tremove(self._recycled.icons)
	if not texture then
		texture = self._frame:CreateTexture()
	end
	texture:Show()
	return texture
end

function TableRow._GetButton(self)
	local frame = tremove(self._recycled.buttons)
	if not frame then
		frame = CreateFrame("Button", nil, self._frame, nil)
	end
	frame:Show()
	return frame
end

function TableRow._CreateHeaderRowCols(self)
	for i, col in ipairs(self._cols) do
		local id = col:_GetId()
		local button = self:_GetButton()
		button:SetScript("OnClick", private.HeaderColOnClick)
		self._buttons[id] = button
		local iconTexture = col:_GetTitleIcon()
		if iconTexture then
			local icon = self:_GetTexture()
			icon:SetDrawLayer("ARTWORK")
			TSM.UI.TexturePacks.SetTextureAndSize(icon, iconTexture)
			self._icons[id] = icon
		else
			local text = self:_GetFontString()
			text:SetFont(self._scrollingTable:_GetStyle("headerFont"), self._scrollingTable:_GetStyle("headerFontHeight"))
			text:SetJustifyH(col:_GetJustifyH())
			text:SetText(col:_GetTitle())
			self._texts[id] = text
		end
		local sortIcon = self:_GetTexture()
		sortIcon:Hide()
		self._sortIcons[id] = sortIcon
	end
end

function TableRow._CreateDataRowCols(self)
	for i, col in ipairs(self._cols) do
		local id = col:_GetId()
		local iconSize = col:_GetIconSize()
		if iconSize then
			local icon = self:_GetTexture()
			icon:SetDrawLayer("ARTWORK", 1)
			icon:SetWidth(iconSize)
			icon:SetHeight(iconSize)
			self._icons[id] = icon
		end
		local text = self:_GetFontString()
		text:SetFont(col:_GetFont(), col:_GetFontHeight())
		text:SetJustifyH(col:_GetJustifyH())
		self._texts[id] = text
		if col:_HasTooltip() then
			local tooltipFrame = self:_GetButton()
			tooltipFrame:SetScript("OnEnter", private.TooltipFrameOnEnter)
			tooltipFrame:SetScript("OnLeave", private.TooltipFrameOnLeave)
			tooltipFrame:SetScript("OnClick", private.TooltipFrameOnClick)
			self._buttons[id] = tooltipFrame
		end
	end
end

function TableRow._LayoutHeaderRow(self)
	for _, button in pairs(self._buttons) do
		button:ClearAllPoints()
	end

	-- build buttons from the left until we get to the col without a width
	local xOffsetLeft = ROW_PADDING
	for _, col in ipairs(self._cols) do
		local id = col:_GetId()
		local button = self._buttons[id]
		button:SetPoint("LEFT", xOffsetLeft, 0)
		local width = col:_GetWidth()
		if width then
			button:SetWidth(width)
		else
			break
		end
		xOffsetLeft = xOffsetLeft + width + self._scrollingTable:_GetStyle("colSpacing")
	end

	-- build buttons from the right until we get to the col without a width
	local xOffsetRight = -ROW_PADDING
	for i = #self._cols, 1, -1 do
		local col = self._cols[i]
		local id = col:_GetId()
		local button = self._buttons[id]
		button:SetPoint("RIGHT", xOffsetRight, 0)
		local width = col:_GetWidth()
		if width then
			button:SetWidth(width)
		else
			break
		end
		xOffsetRight = xOffsetRight - width - self._scrollingTable:_GetStyle("colSpacing")
	end

	-- update the text, icons, and sort icons
	for _, col in ipairs(self._cols) do
		local id = col:_GetId()
		local button = self._buttons[id]
		local sortIcon = self._sortIcons[id]
		sortIcon:ClearAllPoints()
		local iconTexture = col:_GetTitleIcon()
		if iconTexture then
			local icon = self._icons[id]
			icon:ClearAllPoints()
			icon:SetPoint(col:_GetJustifyH(), button)
			if sortIcon.direction ~= nil then
				TSM.UI.TexturePacks.SetTextureAndSize(sortIcon, sortIcon.direction and "iconPack.10x10/Arrow/Up" or "iconPack.10x10/Arrow/Down")
				sortIcon:SetPoint("LEFT", icon, "RIGHT", 2, 0)
				sortIcon:Show()
			else
				sortIcon:Hide()
			end
		else
			local text = self._texts[id]
			text:ClearAllPoints()
			if sortIcon.direction ~= nil then
				TSM.UI.TexturePacks.SetTextureAndSize(sortIcon, sortIcon.direction and "iconPack.10x10/Arrow/Up" or "iconPack.10x10/Arrow/Down")
				sortIcon:Show()
				local justifyH = col:_GetJustifyH()
				if justifyH == "LEFT" then
					text:SetAllPoints(button)
					sortIcon:SetPoint("LEFT", button, text:GetStringWidth() + 6, 0)
				elseif justifyH == "CENTER" then
					text:SetAllPoints(button)
					if not text:GetText() or text:GetText() == "" then
						sortIcon:SetPoint("CENTER", button)
					else
						sortIcon:SetPoint("LEFT", button, "CENTER", text:GetStringWidth() / 2 + 4, 0)
					end
				elseif justifyH == "RIGHT" then
					text:SetPoint("LEFT", button)
					text:SetPoint("RIGHT", button, -sortIcon:GetWidth(), 0)
					sortIcon:SetPoint("RIGHT", button)
				else
					error("Invalid justifyH: "..tostring(justifyH))
				end
			else
				text:SetAllPoints(button)
				sortIcon:Hide()
			end
		end
	end
end

function TableRow._LayoutDataRow(self)
	-- build from the left until we get to the col without a width
	local prevText = nil
	for i, col in ipairs(self._cols) do
		local id = col:_GetId()
		local width = col:_GetWidth()
		local icon = self._icons[id]
		if icon then
			if prevText then
				icon:SetPoint("LEFT", prevText, "RIGHT", self._scrollingTable:_GetStyle("colSpacing"), 0)
			else
				icon:SetPoint("LEFT", ROW_PADDING, 0)
			end
			local iconSize = col:_GetIconSize()
			width = width and (width - iconSize - ICON_SPACING) or nil
		end
		local text = self._texts[id]
		if icon then
			text:SetPoint("LEFT", icon, "RIGHT", ICON_SPACING, 0)
		elseif prevText then
			text:SetPoint("LEFT", prevText, "RIGHT", self._scrollingTable:_GetStyle("colSpacing"), 0)
		else
			text:SetPoint("LEFT", ROW_PADDING, 0)
		end
		if col:_HasTooltip() then
			local tooltipFrame = self._buttons[id]
			tooltipFrame:SetPoint("LEFT", icon or text)
			tooltipFrame:SetPoint("RIGHT", self._texts[id])
		end
		if width then
			text:SetWidth(width)
		else
			break
		end
		prevText = text
	end

	-- build from the right until we get to the col without a width
	prevText = nil
	for i = #self._cols, 1, -1 do
		local col = self._cols[i]
		local id = col:_GetId()
		local width = col:_GetWidth()
		local text = self._texts[id]
		if prevText then
			text:SetPoint("RIGHT", prevText, "LEFT", -self._scrollingTable:_GetStyle("colSpacing"), 0)
		else
			text:SetPoint("RIGHT", -ROW_PADDING, 0)
		end
		if width then
			text:SetWidth(width)
		else
			break
		end
		assert(not self._icons[id], "Not supported")
		prevText = text
	end
end



-- ============================================================================
-- TableRow - Local Script Handlers
-- ============================================================================

function private.HeaderColOnClick(button, mouseButton)
	local self = private.rowFrameLookup[button:GetParent()]
	if mouseButton == "LeftButton" then
		local id = TSMAPI_FOUR.Util.GetDistinctTableKey(self._buttons, button)
		self._scrollingTable:_ToggleSort(id)
	end
end

function private.RowOnClick(frame, mouseButton)
	local self = private.rowFrameLookup[frame]
	if self._scrollingTable._onRowClickHandler then
		self._scrollingTable:_onRowClickHandler(self:GetData(), mouseButton)
	end
	if mouseButton == "LeftButton" then
		if not self._scrollingTable._selectionDisabled then
			self._scrollingTable:SetSelection(self:GetData())
		end
	end
end

function private.RowOnEnter(frame)
	local self = private.rowFrameLookup[frame]
	self:SetHighlightVisible(true)
end

function private.RowOnLeave(frame)
	local self = private.rowFrameLookup[frame]
	local selection = self._scrollingTable:GetSelection()
	if not selection or selection ~= self:GetData() then
		self:SetHighlightVisible(false)
	end
end

function private.TooltipFrameOnEnter(frame)
	local self = private.rowFrameLookup[frame:GetParent()]
	self._frame:GetScript("OnEnter")(self._frame)
	local tooltip = nil
	for _, col in ipairs(self._cols) do
		local id = col:_GetId()
		if self._buttons[id] == frame then
			if col:_HasTooltip() then
				tooltip = col:_GetTooltip(self:GetData())
			end
			break
		end
	end
	TSM.UI.ShowTooltip(frame, tooltip)
end

function private.TooltipFrameOnLeave(frame)
	local self = private.rowFrameLookup[frame:GetParent()]
	self._frame:GetScript("OnLeave")(self._frame)
	TSM.UI.HideTooltip()
end

function private.TooltipFrameOnClick(frame, ...)
	local self = private.rowFrameLookup[frame:GetParent()]
	if IsShiftKeyDown() or IsControlKeyDown() then
		local tooltip = nil
		for _, col in ipairs(self._cols) do
			local id = col:_GetId()
			if self._buttons[id] == frame then
				if col:_HasTooltip() then
					tooltip = col:_GetTooltip(self:GetData())
				end
				break
			end
		end
		local link = tooltip and TSMAPI_FOUR.Item.GetLink(tooltip)
		if link then
			if IsShiftKeyDown() then
				TSMAPI_FOUR.Util.SafeItemRef(link)
			elseif IsControlKeyDown() then
				DressUpItemLink(link)
			end
			return
		end
	end
	self._frame:GetScript("OnClick")(self._frame, ...)
end
