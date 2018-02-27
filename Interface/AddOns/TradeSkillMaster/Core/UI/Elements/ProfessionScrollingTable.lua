-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

--- ProfessionScrollingTable UI Element Class.
-- This is used to display the crafts within the currently-selected profession in the CraftingUI. It is a subclass of
-- the @{FastScrollingTable} class.
-- @classmod ProfessionScrollingTable

local _, TSM = ...
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local ProfessionScrollingTable = TSMAPI_FOUR.Class.DefineClass("ProfessionScrollingTable", TSM.UI.FastScrollingTable)
TSM.UI.ProfessionScrollingTable = ProfessionScrollingTable
local private = { rowFrameLookup = {} }
local PREFIX_ICON_SIZE = 14
local PREFIX_ICON_SPACING_RIGHT = 2
local PREFIX_ICON_SPACING_LEFT = 2
local INDENT_SPACING = 16
local RECIPE_COLORS = {
	optimal = "|cffff8040",
	medium = "|cffffff00",
	easy = "|cff40c040",
	trivial = "|cff808080",
	header = "|cffffd100",
	subheader = "|cffffd100",
	nodifficulty = "|cfff5f5f5",
}



-- ============================================================================
-- Public Class Methods
-- ============================================================================

function ProfessionScrollingTable.__init(self)
	self.__super:__init()

	self._collapsed = {}
	self._categoryIndents = {}
	self._recordLookupBySpellId = {}
end

function ProfessionScrollingTable.Acquire(self)
	self.__super:Acquire()
	self:GetScrollingTableInfo()
		:NewColumn("nane")
			:SetTitles(L["Name"])
			:SetFont(TSM.UI.Fonts.FRIZQT)
			:SetFontHeight(12)
			:SetJustifyH("LEFT")
			:SetTextFunction(private.GetNameCellText)
			:Commit()
		:NewColumn("qty")
			:SetTitles(L["Craft"])
			:SetWidth(54)
			:SetFont(TSM.UI.Fonts.RobotoRegular)
			:SetFontHeight(12)
			:SetJustifyH("CENTER")
			:SetTextFunction(private.GetQtyCellText)
			:Commit()
		:NewColumn("rank")
			:SetTitles(L["Rank"])
			:SetWidth(40)
			:SetFont(TSM.UI.Fonts.MontserratRegular)
			:SetFontHeight(12)
			:SetJustifyH("CENTER")
			:Commit()
		:NewColumn("profit")
			:SetTitles(L["Profit"])
			:SetWidth(115)
			:SetFont(TSM.UI.Fonts.RobotoMedium)
			:SetFontHeight(12)
			:SetJustifyH("RIGHT")
			:SetTextFunction(private.GetProfitCellText)
			:Commit()
		:NewColumn("saleRate")
			:SetTitleIcon("iconPack.14x14/SaleRate")
			:SetWidth(30)
			:SetFont(TSM.UI.Fonts.RobotoMedium)
			:SetFontHeight(12)
			:SetJustifyH("RIGHT")
			:SetTextFunction(private.GetSaleRateCellText)
			:Commit()
		:Commit()
end

function ProfessionScrollingTable.Release(self)
	wipe(self._collapsed)
	wipe(self._categoryIndents)
	wipe(self._recordLookupBySpellId)
	self.__super:Release()
end



-- ============================================================================
-- Private Class Methods
-- ============================================================================

function ProfessionScrollingTable._ToggleCollapsed(self, data)
	self._collapsed[data] = not self._collapsed[data] or nil
end

function ProfessionScrollingTable._GetTableRow(self, isHeader)
	local row = self.__super:_GetTableRow(isHeader)
	if not isHeader then
		for _, tooltipFrame in pairs(row._buttons) do
			tooltipFrame:SetScript("OnClick", private.TooltipFrameOnClick)
		end
		row._frame:SetScript("OnClick", private.RowOnClick)
		private.rowFrameLookup[row._frame] = row

		-- add the prefix icon texture before the first col
		local firstText = row._texts[self._tableInfo:_GetCols()[1]:_GetId()]
		local prefixIcon = row:_GetTexture()
		prefixIcon:SetWidth(PREFIX_ICON_SIZE)
		prefixIcon:SetHeight(PREFIX_ICON_SIZE)
		row._icons.prefixIcon = prefixIcon

		local prefixIconBtn = row:_GetButton()
		prefixIconBtn:SetAllPoints(prefixIcon)
		prefixIconBtn:SetScript("OnClick", private.PrefixIconOnClick)
		prefixIconBtn:SetScript("OnEnter", private.PrefixIconOnEnter)
		prefixIconBtn:SetScript("OnLeave", private.PrefixIconOnLeave)
		row._buttons.prefixIconBtn = prefixIconBtn

		firstText:ClearAllPoints()
		firstText:SetPoint("LEFT", prefixIcon, "RIGHT", PREFIX_ICON_SPACING_RIGHT, 0)
		firstText:SetPoint("RIGHT", row._texts[self._tableInfo:_GetCols()[2]:_GetId()], "LEFT", -self:_GetStyle("colSpacing"), 0)

		-- add star textures
		local rankText = row._texts.rank
		local star1 = row:_GetTexture()
		TSM.UI.TexturePacks.SetSize(star1, "iconPack.12x12/Star/Filled")
		star1:SetPoint("LEFT", rankText)
		row._icons.star1 = star1
		local star2 = row:_GetTexture()
		TSM.UI.TexturePacks.SetSize(star2, "iconPack.12x12/Star/Filled")
		star2:SetPoint("CENTER", rankText)
		row._icons.star2 = star2
		local star3 = row:_GetTexture()
		TSM.UI.TexturePacks.SetSize(star3, "iconPack.12x12/Star/Filled")
		star3:SetPoint("RIGHT", rankText)
		row._icons.star3 = star3

	end
	return row
end

function ProfessionScrollingTable._UpdateData(self)
	local currentCategoryPath = TSMAPI_FOUR.Util.AcquireTempTable()
	local prevSpellId = self:GetSelection() or nil
	local foundSelection = false
	-- populate the ScrollList data
	wipe(self._data)
	wipe(self._categoryIndents)
	wipe(self._recordLookupBySpellId)
	local allData = TSMAPI_FOUR.Util.AcquireTempTable()
	for _, row in self._query:Iterator(true) do
		local categoryId = row:GetField("categoryId")
		if categoryId ~= currentCategoryPath[#currentCategoryPath] then
			-- this is a new category
			local newCategoryPath = TSMAPI_FOUR.Util.AcquireTempTable()
			local categoryInfo = TSMAPI_FOUR.Util.AcquireTempTable()
			local currentCategoryId = categoryId
			while currentCategoryId do
				wipe(categoryInfo)
				C_TradeSkillUI.GetCategoryInfo(currentCategoryId, categoryInfo)
				tinsert(newCategoryPath, 1, currentCategoryId)
				self._categoryIndents[currentCategoryId] = categoryInfo.numIndents
				currentCategoryId = categoryInfo.parentCategoryID
			end
			TSMAPI_FOUR.Util.ReleaseTempTable(categoryInfo)
			-- create new category headers
			for i = 1, #newCategoryPath do
				if currentCategoryPath[i] ~= newCategoryPath[i] then
					tinsert(allData, newCategoryPath[i])
				end
			end
			TSMAPI_FOUR.Util.ReleaseTempTable(currentCategoryPath)
			currentCategoryPath = newCategoryPath
		end
		local spellId = row:GetField("spellId")
		foundSelection = foundSelection or spellId == self:GetSelection()
		tinsert(allData, spellId)
		self._recordLookupBySpellId[spellId] = row
	end
	TSMAPI_FOUR.Util.ReleaseTempTable(currentCategoryPath)
	for _, data in ipairs(allData) do
		if not self:_IsDataHidden(data) then
			tinsert(self._data, data)
		end
	end
	TSMAPI_FOUR.Util.ReleaseTempTable(allData)
	if not foundSelection then
		self:SetSelection(nil)
	end
end

function ProfessionScrollingTable._IsDataHidden(self, data)
	local record = self._recordLookupBySpellId[data]
	local categoryId = record and record:GetField("categoryId") or data
	if record and self._collapsed[categoryId] then
		return true
	end
	local categoryInfo = TSMAPI_FOUR.Util.AcquireTempTable()
	C_TradeSkillUI.GetCategoryInfo(categoryId, categoryInfo)
	local parent = categoryInfo.parentCategoryID
	while parent do
		if self._collapsed[parent] then
			TSMAPI_FOUR.Util.ReleaseTempTable(categoryInfo)
			return true
		end
		wipe(categoryInfo)
		C_TradeSkillUI.GetCategoryInfo(parent, categoryInfo)
		parent = categoryInfo.parentCategoryID
	end
	TSMAPI_FOUR.Util.ReleaseTempTable(categoryInfo)
	return false
end

function ProfessionScrollingTable._SetRowData(self, row, data)
	local record = self._recordLookupBySpellId[data]
	local numSkillUps = record and record:GetField("numSkillUps")
	local prefixIcon = row._icons.prefixIcon
	if not record then
		prefixIcon:SetPoint("LEFT", PREFIX_ICON_SPACING_LEFT + self._categoryIndents[data] * INDENT_SPACING, 0)
		TSM.UI.TexturePacks.SetTexture(prefixIcon, self._collapsed[data] and "iconPack.14x14/Carot/Collapsed" or "iconPack.14x14/Carot/Expanded")
		prefixIcon:SetVertexColor(1, 1, 1, 1)
		prefixIcon:Show()
	elseif numSkillUps > 1 then
		prefixIcon:SetPoint("LEFT", PREFIX_ICON_SPACING_LEFT + INDENT_SPACING, 0)
		TSM.UI.TexturePacks.SetTexture(prefixIcon, "iconPack.18x18/SkillUp")
		prefixIcon:SetVertexColor(TSM.UI.HexToRGBA("#ff8040"))
		prefixIcon:Show()
	else
		prefixIcon:SetPoint("LEFT", PREFIX_ICON_SPACING_LEFT + INDENT_SPACING, 0)
		prefixIcon:Hide()
	end
	local rank = record and record:GetField("rank") or -1
	if rank == -1 then
		row._icons.star1:Hide()
		row._icons.star2:Hide()
		row._icons.star3:Hide()
	else
		TSM.UI.TexturePacks.SetTexture(row._icons.star1, rank >= 1 and "iconPack.12x12/Star/Filled" or "iconPack.12x12/Star/Unfilled")
		TSM.UI.TexturePacks.SetTexture(row._icons.star2, rank >= 2 and "iconPack.12x12/Star/Filled" or "iconPack.12x12/Star/Unfilled")
		TSM.UI.TexturePacks.SetTexture(row._icons.star3, rank >= 3 and "iconPack.12x12/Star/Filled" or "iconPack.12x12/Star/Unfilled")
		row._icons.star1:Show()
		row._icons.star2:Show()
		row._icons.star3:Show()
	end
	self.__super:_SetRowData(row, data)
end



-- ============================================================================
-- Private Helper Functions
-- ============================================================================

function private.GetNameCellText(self, spellId)
	local record = self._recordLookupBySpellId[spellId]
	if not record then
		-- this is a category
		local categoryInfo = TSMAPI_FOUR.Util.AcquireTempTable()
		C_TradeSkillUI.GetCategoryInfo(spellId, categoryInfo)
		local name = categoryInfo.name

		if not name then
			-- happens if we're switching to another profession
			return "?"
		end
		local level = categoryInfo.numIndents
		TSMAPI_FOUR.Util.ReleaseTempTable(categoryInfo)
		if level == 0 then
			return "|cffffd839"..name.."|r"
		else
			return "|cff79a2ff"..name.."|r"
		end
	end
	local name, difficulty = record:GetFields("name", "difficulty")
	local color = nil
	if C_TradeSkillUI.IsTradeSkillGuild() then
		color = RECIPE_COLORS.easy
	elseif C_TradeSkillUI.IsNPCCrafting() then
		color = RECIPE_COLORS.nodifficulty
	else
		color = RECIPE_COLORS[difficulty]
	end
	return color..name.."|r"
end

function private.GetQtyCellText(self, spellId)
	if not self._recordLookupBySpellId[spellId] then
		return ""
	end
	local num, numAll = TSM.Crafting.ProfessionUtil.GetNumCraftable(spellId)
	if num == numAll then
		if num > 0 then
			return "|cff2cec0d"..num.."|r"
		end
		return tostring(num)
	else
		if num > 0 then
			return "|cff2cec0d"..num.."-"..numAll.."|r"
		elseif numAll > 0 then
			return "|cfffcf141"..num.."-"..numAll.."|r"
		else
			return num.."-"..numAll
		end
	end
end

function private.GetProfitCellText(self, spellId)
	if not self._recordLookupBySpellId[spellId] then
		return ""
	end
	local profit = TSM.Crafting.Cost.GetProfitBySpellId(spellId)
	if profit then
		return TSMAPI_FOUR.Money.ToString(profit, profit >= 0 and "|cff2cec0d" or "|cffd50000", "OPT_PAD")
	else
		return ""
	end
end

function private.GetSaleRateCellText(self, spellId)
	return self._recordLookupBySpellId[spellId] and TSM.Crafting.Cost.GetSaleRateBySpellId(spellId) or ""
end



-- ============================================================================
-- Local Script Handlers
-- ============================================================================

function private.RowOnClick(frame, mouseButton)
	local self = private.rowFrameLookup[frame]
	local scrollingTable = self._scrollingTable
	local data = self:GetData()
	if mouseButton == "LeftButton" then
		if scrollingTable._recordLookupBySpellId[data] then
			scrollingTable:SetSelection(data)
		else
			scrollingTable:_ToggleCollapsed(data)
		end
		scrollingTable:_UpdateData()
		scrollingTable:Draw()
	end
end

function private.TooltipFrameOnClick(frame, mouseButton)
	private.RowOnClick(frame:GetParent(), mouseButton)
end

function private.PrefixIconOnClick(button, mouseButton)
	private.RowOnClick(button:GetParent(), mouseButton)
end

function private.PrefixIconOnEnter(button)
	local frame = button:GetParent()
	frame:GetScript("OnEnter")(frame, button)
	local self = private.rowFrameLookup[frame]
	local record = self._scrollingTable._recordLookupBySpellId[self:GetData()]
	local numSkillUps = record and record:GetField("numSkillUps")
	if numSkillUps and numSkillUps > 1 then
		TSM.UI.ShowTooltip(button, format(SKILLUP_TOOLTIP, numSkillUps))
	end
end

function private.PrefixIconOnLeave(button)
	local frame = button:GetParent()
	frame:GetScript("OnLeave")(frame, button)
	TSM.UI.HideTooltip()
end
