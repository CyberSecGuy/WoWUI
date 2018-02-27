-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

--- Scrolling Table UI Element Class.
-- NOTE: This class is deprecated and shouldn't be used for new code. @{FastScrollingTable} should be used instead.
-- @classmod ScrollingTable

local _, TSM = ...
local ScrollingTable = TSMAPI_FOUR.Class.DefineClass("ScrollingTable", TSM.UI.Frame)
TSM.UI.ScrollingTable = ScrollingTable
local ScrollingTable_ScrollList = TSMAPI_FOUR.Class.DefineClass("ScrollingTable_ScrollList", TSM.UI.ScrollList)
TSM.UI.ScrollingTable_ScrollList = ScrollingTable_ScrollList
local private = { sortContext = nil, sortCache = {}, queryScrollListLookup = {} }
local ROW_PADDING = { left = 8, right = 8 }
local SORT_ICON_MARGIN = { left = 2 }



-- ============================================================================
-- ScrollingTable - Public Class Methods
-- ============================================================================

function ScrollingTable.__init(self, scrollListClass)
	scrollListClass = scrollListClass or ScrollingTable_ScrollList
	assert(scrollListClass and scrollListClass:__isa(ScrollingTable_ScrollList))
	self.__super:__init()
	self._scrollListClass = scrollListClass
	self._showingAltTitles = false
	self._tableInfo = TSM.UI.Util.ScrollingTableInfo()
	self._selectionValidator = nil
	self._sortDisabled = false
end

function ScrollingTable.Acquire(self)
	self.__super:Acquire()
	self:SetLayout("VERTICAL")
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "header")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 22)
			:SetStyle("padding", ROW_PADDING)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Texture", "line")
			:SetStyle("height", 2)
			:SetStyle("color", "#9d9d9d")
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement(self._scrollListClass, "scrollList"))
	self._scrollList = self:GetElement("scrollList")
	self._showingAltTitles = false
	self._tableInfo:_Acquire(self)
end

function ScrollingTable.Release(self)
	self._selectionValidator = nil
	self._sortDisabled = false
	self._tableInfo:_Release()
	self.__super:Release()
end

function ScrollingTable.GetScrollingTableInfo(self)
	return self._tableInfo
end

function ScrollingTable.CommitTableInfo(self)
	-- recreate the header
	local header = self:GetElement("header")
	header:ReleaseAllChildren()
	for i, col in ipairs(self._tableInfo:_GetCols()) do
		local headerIndent = col:_GetHeaderIndent()
		local headerCol = TSMAPI_FOUR.UI.NewElement("Frame", col:_GetId())
			:SetLayout("HORIZONTAL")
			:SetStyle("width", col:_GetWidth())
			:SetStyle("margin", { left = (i ~= 1 and 16 or 0) + (headerIndent or 0) })
			:SetContext(col)
			:AddChildNoLayout(TSMAPI_FOUR.UI.NewElement("Button", "button")
				:SetStyle("anchors", { { "TOPLEFT" }, { "BOTTOMRIGHT" } })
				:EnableRightClick()
				:SetScript("OnClick", private.HeaderCellOnClick)
			)
		local justifyH = col:_GetJustifyH() or "LEFT"
		if justifyH == "LEFT" then
			-- no spacer on the left
		elseif justifyH == "CENTER" then
			headerCol:AddChild(TSMAPI_FOUR.UI.NewElement("Spacer", "leftSpacer"))
		elseif justifyH == "RIGHT" then
			headerCol:AddChild(TSMAPI_FOUR.UI.NewElement("Spacer", "leftSpacer"))
		else
			error("Invalid justifyH: "..tostring(justifyH))
		end
		if col:_GetTitleIcon() then
			headerCol:AddChild(TSMAPI_FOUR.UI.NewElement("Texture", "iconFrame")
				:SetStyle("width", 14)
				:SetStyle("height", 14)
			)
		else
			headerCol:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "text")
				:SetStyle("autoWidth", true)
				:SetStyle("font", TSM.UI.Fonts.bold)
				:SetStyle("justifyH", col:_GetJustifyH())
				:SetStyle("fontHeight", 14)
				:SetText(col:_GetTitle())
			)
		end
		headerCol:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "sortIcon")
			:SetStyle("margin", SORT_ICON_MARGIN)
			:SetStyle("height", 10)
			:SetStyle("width", 10)
		)
		if justifyH == "LEFT" then
			headerCol:AddChild(TSMAPI_FOUR.UI.NewElement("Spacer", "rightSpacer"))
		elseif justifyH == "CENTER" then
			headerCol:AddChild(TSMAPI_FOUR.UI.NewElement("Spacer", "rightSpacer"))
		elseif justifyH == "RIGHT" then
			-- no spacer on the right
		else
			error("Invalid justifyH: "..tostring(justifyH))
		end
		header:AddChild(headerCol)
	end
	self._scrollList:_SetTableInfo(self._tableInfo)
	return self
end

function ScrollingTable.SetQuery(self, query, redraw)
	self._scrollList:_SetQuery(query, redraw)

	if redraw then
		self:Draw()
	end

	return self
end

function ScrollingTable.SetScript(self, script, handler)
	if script == "OnSelectionChanged" then
		self._scrollList:_SetScript("OnSelectionChanged", handler)
	elseif script == "OnRowClick" then
		self._scrollList:_SetScript("OnRowClick", handler)
	else
		error("Unknown ScrollingTable script: "..tostring(script))
	end
	return self
end

function ScrollingTable.GetSelection(self)
	return self._scrollList:_GetSelection()
end

function ScrollingTable.GetSelectionIndex(self)
	return self._scrollList:_GetSelectionIndex()
end

function ScrollingTable.SetSelection(self, record)
	if record and self._selectionValidator and not self:_selectionValidator(record) then
		record = nil
	end
	self._scrollList:_SetSelection(record)
	return self
end

function ScrollingTable.SetSelectionDisabled(self, disabled)
	self._scrollList:_SetSelectionDisabled(disabled)
	return self
end

function ScrollingTable.SetSelectionValidator(self, validator)
	self._selectionValidator = validator
	return self
end

function ScrollingTable.GetDataByIndex(self, index)
	return self._scrollList:_GetDataByIndex(index)
end

function ScrollingTable.SetSortDisabled(self, disabled)
	self._sortDisabled = disabled
	return self
end



-- ============================================================================
-- ScrollingTable - Private Class Methods
-- ============================================================================

function ScrollingTable.Draw(self)
	self._scrollList:SetStyle("rowHeight", self:_GetStyle("rowHeight"))
	self._scrollList:SetStyle("altBackground", self:_GetStyle("altBackground"))
	local header = self:GetElement("header")
	header:SetStyle("background", self:_GetStyle("headerBackground"))
	for _, col in ipairs(self._tableInfo:_GetCols()) do
		local colElement = header:GetElement(col:_GetId())
		if col:_GetTitleIcon() then
			colElement:GetElement("iconFrame"):SetStyle("texturePack", col:_GetTitleIcon())
		else
			colElement:GetElement("text"):SetText(self._scrollList._showingAltTitles and col:_GetTitle(true) or col:_GetTitle())
		end

		local sortIcon = colElement:GetElement("sortIcon")
		if col == self._scrollList._sortCol then
			sortIcon:SetStyle("backgroundTexturePack", self._scrollList._sortAscending and "iconPack.10x10/Arrow/Up" or "iconPack.10x10/Arrow/Down")
			sortIcon:SetStyle("margin", SORT_ICON_MARGIN)
			sortIcon:SetStyle("width", 10)
		else
			sortIcon:SetStyle("backgroundTexturePack", nil)
			sortIcon:SetStyle("margin", nil)
			sortIcon:SetStyle("width", 0)
		end
	end
	self.__super:Draw()
end



-- ============================================================================
-- ScrollingTable Private Script Handlers
-- ============================================================================

function private.HeaderCellOnClick(button, mouseButton)
	local colFrame = button:GetParentElement()
	local self = colFrame:GetParentElement():GetParentElement()
	local col = colFrame:GetContext()
	if mouseButton == "LeftButton" then
		if self._sortDisabled then
			return
		end
		if col ~= self._scrollList._sortCol then
			self._scrollList._sortCol = col
			self._scrollList._sortAscending = true
		else
			self._scrollList._sortAscending = not self._scrollList._sortAscending
		end
	elseif mouseButton == "RightButton" and col:_GetTitle(true) then
		self._scrollList._showingAltTitles = not self._scrollList._showingAltTitles
	end

	self:SetSelection(nil)
	self._scrollList:_UpdateData()
	self:Draw()
end




-- ============================================================================
-- ScrollingTable_ScrollList - Class Methods
-- ============================================================================

function ScrollingTable_ScrollList.__init(self)
	self.__super:__init()

	self._query = nil
	self._tableInfo = nil
	self._selection = nil
	self._sortCol = nil
	self._sortAscending = true
	self._sortSecondaryComparator = nil
	self._selectionDisabled = false
	self._onSelectionChangedHandler = nil
	self._onClickHandler = nil
end

function ScrollingTable_ScrollList.Release(self)
	if self._query then
		self._query:SetUpdateCallback()
		private.queryScrollListLookup[self._query] = nil
		self._query = nil
	end
	self._tableInfo = nil
	self._selection = nil
	self._sortCol = nil
	self._sortAscending = true
	self._sortSecondaryComparator = nil
	self._selectionDisabled = false
	self._onSelectionChangedHandler = nil
	self._onClickHandler = nil
	self.__super:Release()
end

function ScrollingTable_ScrollList._SetTableInfo(self, tableInfo)
	self._tableInfo = tableInfo
	local defaultSortKey, defaultSortAscending, secondaryComparator = self._tableInfo:_GetSortInfo()
	self._sortAscending = defaultSortAscending
	self._sortSecondaryComparator = secondaryComparator
	for _, col in ipairs(self._tableInfo:_GetCols()) do
		if defaultSortKey == col:_GetId() then
			self._sortCol = col
			break
		end
	end
end

function ScrollingTable_ScrollList._SetQuery(self, query, redraw)
	if query == self._query and not redraw then
		return
	end
	if self._query then
		self._query:SetUpdateCallback()
		private.queryScrollListLookup[self._query] = nil
	end
	self._query = query
	private.queryScrollListLookup[self._query] = self
	self._query:SetUpdateCallback(private.QueryUpdateCallback)
	self:_UpdateData(true)
end

function ScrollingTable_ScrollList._UpdateData(self, queryChanged)
	wipe(self._data)
	for _, record in self._query:Iterator(true) do
		tinsert(self._data, record)
	end
	if self._tableInfo:_GetSortInfo() then
		-- pre-compute the sort value for every record to speed up the sort
		private.sortContext = self
		for _, record in ipairs(self._data) do
			private.sortCache[record] = self._sortCol:_GetSortValue(record)
		end
		sort(self._data, private.DataSortComparator)
		private.sortContext = nil
		wipe(private.sortCache)
	end
end

function ScrollingTable_ScrollList._CreateRow(self)
	local row = self.__super:_CreateRow()
		:SetLayout("HORIZONTAL")
		:SetStyle("padding", ROW_PADDING)
		:AddChildNoLayout(TSMAPI_FOUR.UI.NewElement("Frame", "highlight")
			:SetStyle("anchors", { { "TOPLEFT" }, { "BOTTOMRIGHT" } })
		)
		:SetScript("OnUpdate", private.RowOnUpdate)
	for i, col in ipairs(self._tableInfo:_GetCols()) do
		local id = col:_GetId()
		local extraMargin = i ~= 1 and 16 or nil
		local width = col:_GetWidth()
		local iconSize = col:_GetIconSize()
		if iconSize then
			row:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", id.."_icon")
				:SetStyle("relativeLevel", 2)
				:SetStyle("margin", { left = extraMargin, right = col:_HasText() and 4 or nil })
				:SetStyle("width", iconSize)
				:SetStyle("height", iconSize)
			)
			extraMargin = nil
			width = width and (width - iconSize) or width
		end
		row:AddChild(TSMAPI_FOUR.UI.NewElement("Button", id)
			:SetStyle("margin", extraMargin and { left = extraMargin } or nil)
			:SetStyle("width", width)
			:SetStyle("justifyH", col:_GetJustifyH())
			:SetStyle("font", col:_GetFont())
			:SetStyle("fontHeight", col:_GetFontHeight())
			:EnableRightClick()
			:SetScript("OnClick", private.RowOnClick)
		)
	end
	row:GetElement("highlight"):Hide()
	return row
end

function ScrollingTable_ScrollList._SetRowHitRectInsets(self, row, top, bottom)
	for _, col in ipairs(self._tableInfo:_GetCols()) do
		row:GetElement(col:_GetId()):SetHitRectInsets(0, 0, top, bottom)
	end
	self.__super:_SetRowHitRectInsets(row, top, bottom)
end

function ScrollingTable_ScrollList._DrawRow(self, row, dataIndex)
	local context = row:GetContext()
	-- set the text for each cell
	for _, col in ipairs(self._tableInfo:_GetCols()) do
		local id = col:_GetId()
		local text = row:GetElement(id)
		text:SetStyle("fontHeight", 12)
		text:SetText(col:_GetText(context))
		text:SetTooltip(col:_GetTooltip(context))
		if col:_GetIconSize() then
			local texture = col:_GetIcon(context)
			local isTexturePack = texture and TSM.UI.TexturePacks.IsValid(texture)
			row:GetElement(id.."_icon")
				:SetStyle("backgroundTexturePack", isTexturePack and texture or nil)
				:SetStyle("backgroundTexture", not isTexturePack and texture or nil)
		end
	end
	row:GetElement("highlight"):SetStyle("background", self:_GetStyle("highlight"))
	self.__super:_DrawRow(row, dataIndex)
end

function ScrollingTable_ScrollList._SetSelection(self, selection)
	self._selection = selection
	if self._onSelectionChangedHandler then
		self._onSelectionChangedHandler(self:GetParentElement())
	end
end

function ScrollingTable_ScrollList._GetSelection(self)
	return self._selection
end

function ScrollingTable_ScrollList._SetScript(self, script, handler)
	if script == "OnSelectionChanged" then
		self._onSelectionChangedHandler = handler
	elseif script == "OnRowClick" then
		self._onClickHandler = handler
	else
		error("Unknown ScrollingTable_ScrollList script: "..tostring(script))
	end
end

function ScrollingTable_ScrollList._SetSelectionDisabled(self, disabled)
	self._selectionDisabled = disabled
end

function ScrollingTable_ScrollList._GetDataByIndex(self, index)
	return self._data[index]
end

function ScrollingTable_ScrollList._GetSelectionIndex(self, index)
	if not self._selection then
		return
	end
	return TSMAPI_FOUR.Util.GetDistinctTableKey(self._data, self._selection)
end




-- ============================================================================
-- ScrollingTable_ScrollList Private Script Handlers
-- ============================================================================

function private.RowOnClick(button, mouseButton)
	local row = button:GetParentElement()
	local self = row:GetParentElement()
	if not self._selectionDisabled and mouseButton == "LeftButton" then
		self:GetParentElement():SetSelection(row:GetContext())
		self:Draw()
	elseif self._onClickHandler then
		self:_onClickHandler(row:GetContext(), mouseButton)
	end
end

function private.RowOnUpdate(row)
	local self = row:GetParentElement()
	if row:IsMouseOver() or row:GetContext() == self:_GetSelection() then
		row:GetElement("highlight"):Show()
	else
		row:GetElement("highlight"):Hide()
	end
end

function private.QueryUpdateCallback(query)
	local self = private.queryScrollListLookup[query]
	self:_UpdateData()
	self:Draw()
end



-- ============================================================================
-- Private Helper Functions
-- ============================================================================

function private.DataSortComparator(a, b)
	local self = private.sortContext
	local aValue = private.sortCache[a]
	local bValue = private.sortCache[b]
	if aValue == bValue then
		if self._sortSecondaryComparator then
			return self:_sortSecondaryComparator(a, b)
		else
			return tostring(a) < tostring(b)
		end
	elseif self._sortAscending then
		return aValue < bValue
	else
		return aValue > bValue
	end
end
