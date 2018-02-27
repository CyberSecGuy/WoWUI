-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local Destroying = TSM.MainUI.Settings:NewPackage("Destroying")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = {}
local TIME_FORMAT_VALUES = { L["_ Hr _ Min ago"], L["MM/DD/YY HH:MM"], L["YY/MM/DD HH:MM"], L["DD/MM/YY HH:MM"] }
local TIME_FORMAT_KEYS = { "ago", "usdate", "aidate", "eudate" }


-- ============================================================================
-- Module Functions
-- ============================================================================

function Destroying.OnInitialize()
	assert(#TIME_FORMAT_VALUES == #TIME_FORMAT_KEYS)
	TSM.MainUI.Settings.RegisterSettingPage("Destroying", "middle", private.GetDestroyingSettingsFrame)
end



-- ============================================================================
-- Destroying Settings UI
-- ============================================================================

function private.GetDestroyingSettingsFrame()
	-- TODO: move these to some sort of layout sheet
	local labelWidth = 400
	local headingMargin = { top = 16, bottom = 16 }
	local lineMargin = { bottom = 16 }

	return TSMAPI_FOUR.UI.NewElement("ScrollFrame", "destroyingSettings")
		:SetStyle("padding", 10)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "generalTitle")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 34)
			:SetStyle("margin", headingMargin)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "generalOptions")
				:SetStyle("textColor", "#79a2ff")
				:SetStyle("fontHeight", 24)
				:SetStyle("margin", { right = 8 })
				:SetStyle("autoWidth", true)
				:SetText(L["General Options"])
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Texture", "vline")
				:SetStyle("color", "#e2e2e2")
				:SetStyle("height", 2)
			)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "timeFormat")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 26)
			:SetStyle("margin", lineMargin)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
				:SetStyle("textColor", "#e2e2e2")
				:SetStyle("fontHeight", 18)
				:SetStyle("justifyV", "CENTER")
				:SetStyle("width", labelWidth)
				:SetText(L["Set time format:"])
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Dropdown", "timeDropdown")
				:SetItems(TIME_FORMAT_VALUES, private.TimeFormatKeyToValue(TSM.db.global.destroyingOptions.timeFormat))
				:SetScript("OnSelectionChanged", private.TimeFormatOnSelectionChanged)
			)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "clearLog")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 26)
			:SetStyle("margin", lineMargin)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
				:SetStyle("textColor", "#e2e2e2")
				:SetStyle("fontHeight", 18)
				:SetStyle("justifyV", "CENTER")
				:SetStyle("width", labelWidth)
				:SetText(L["Clear log after 'X' amount of days:"])
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Input", "logDays")
				:SetText(TSM.db.global.destroyingOptions.logDays)
				:SetStyle("background", "#1ae2e2e2")
				:SetStyle("justifyH", "CENTER")
				:SetScript("OnEscapePressed", private.LogDaysOnEscapePressed)
				:SetScript("OnEnterPressed", private.LogDaysOnEnterPressed)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
				:SetStyle("textColor", "#e2e2e2")
				:SetStyle("fontHeight", 18)
				:SetStyle("justifyV", "CENTER")
				:SetText(L["(minimum 0 - maximum 30)"])
			)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "autoStack")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 26)
			:SetStyle("margin", lineMargin)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
				:SetStyle("textColor", "#e2e2e2")
				:SetStyle("fontHeight", 18)
				:SetStyle("justifyV", "CENTER")
				:SetStyle("width", labelWidth)
				:SetText(L["Enable automatic stack combination?"])
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Toggle", "autoStackToggle")
				:SetStyle("height", 20)
				:SetStyle("width", 80)
				:SetBooleanToggle(TSM.db.global.destroyingOptions, "autoStack")
			)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "autoShow")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 26)
			:SetStyle("margin", lineMargin)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
				:SetStyle("textColor", "#e2e2e2")
				:SetStyle("fontHeight", 18)
				:SetStyle("justifyV", "CENTER")
				:SetStyle("width", labelWidth)
				:SetText(L["Show Destroying frame automatically?"])
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Toggle", "autoShowToggle")
				:SetStyle("height", 20)
				:SetStyle("width", 80)
				:SetBooleanToggle(TSM.db.global.destroyingOptions, "autoShow")
			)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "disenchantTitle")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 34)
			:SetStyle("margin", headingMargin)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "disenchantOptions")
				:SetStyle("textColor", "#79a2ff")
				:SetStyle("fontHeight", 24)
				:SetStyle("margin", { right = 8 })
				:SetStyle("autoWidth", true)
				:SetText(L["Disenchanting Options"])
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Texture", "vline")
				:SetStyle("color", "#e2e2e2")
				:SetStyle("height", 2)
			)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "deQuality")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 26)
			:SetStyle("margin", lineMargin)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
				:SetStyle("textColor", "#e2e2e2")
				:SetStyle("fontHeight", 18)
				:SetStyle("justifyV", "CENTER")
				:SetStyle("width", labelWidth)
				:SetText(L["Maximum disenchant quality:"])
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Toggle", "qualityToggle")
				:SetStyle("border", "#e2e2e2")
				:SetStyle("textColor", "#e2e2e2")
				:SetStyle("selectedBackground", "#e2e2e2")
				:SetStyle("height", 20)
				:AddOption(ITEM_QUALITY2_DESC, TSM.db.global.destroyingOptions.deMaxQuality == 2)
				:AddOption(ITEM_QUALITY3_DESC, TSM.db.global.destroyingOptions.deMaxQuality == 3)
				:AddOption(ITEM_QUALITY4_DESC, TSM.db.global.destroyingOptions.deMaxQuality == 4)
				:SetScript("OnValueChanged", private.QualityToggleOnValueChanged)
			)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "includeSoulbound")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 26)
			:SetStyle("margin", lineMargin)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
				:SetStyle("textColor", "#e2e2e2")
				:SetStyle("fontHeight", 18)
				:SetStyle("justifyV", "CENTER")
				:SetStyle("width", labelWidth)
				:SetText(L["Include soulbound items?"])
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Toggle", "soulboundToggle")
				:SetStyle("height", 20)
				:SetStyle("width", 80)
				:SetBooleanToggle(TSM.db.global.destroyingOptions, "includeSoulbound")
			)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "customPriceText")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 26)
			:SetStyle("margin", lineMargin)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
				:SetStyle("textColor", "#e2e2e2")
				:SetStyle("fontHeight", 18)
				:SetStyle("justifyV", "LEFT")
				:SetText(L["Only show items with disenchant value above custom price:"])
			)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "customPrice")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 29)
			:SetStyle("margin", lineMargin)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Input", "customPriceInput")
				:SetText(TSM.db.global.destroyingOptions.deAbovePrice)
				:SetStyle("background", "#1ae2e2e2")
				:SetStyle("height", 29)
				:SetStyle("justifyH", "LEFT")
				:SetScript("OnEnterPressed", private.AboveValueInputOnEnterPressed)
				:SetScript("OnEscapePressed", private.AboveValueInputOnEscapePressed)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "priceReset")
				:SetStyle("borderTexture", "Interface\\Addons\\TradeSkillMaster\\Media\\ButtonEdgeFrame.blp")
				:SetStyle("borderSize", 7)
				:SetStyle("margin", { left = 20 })
				:SetStyle("width", 120)
				:SetStyle("height", 29)
				:SetText(RESET)
				:SetScript("OnClick", private.AboveValueResetOnClick)
			)
		)
end



-- ============================================================================
-- Private Helper Functions
-- ============================================================================

function private.TimeFormatKeyToValue(key)
	for i, v in ipairs(TIME_FORMAT_KEYS) do
		if v == key then
			return TIME_FORMAT_VALUES[i]
		end
	end
end

function private.TimeFormatValueToKey(value)
	for i, v in ipairs(TIME_FORMAT_VALUES) do
		if v == value then
			return TIME_FORMAT_KEYS[i]
		end
	end
end



-- ============================================================================
-- Local Script Handlers
-- ============================================================================

function private.TimeFormatOnSelectionChanged(self, value)
	TSM.db.global.destroyingOptions.timeFormat = private.TimeFormatValueToKey(value)
end

function private.LogDaysOnEscapePressed(self)
	self:SetText(TSM.db.global.destroyingOptions.logDays)
	self:Draw()
end

function private.LogDaysOnEnterPressed(self)
	local value = tonumber(strtrim(self:GetText()))
	if value then
		value = TSMAPI_FOUR.Util.Round(value)
		TSM.db.global.destroyingOptions.logDays = value
	else
		value = TSM.db.global.destroyingOptions.logDays
	end
	self:SetText(value)
	self:Draw()
end

function private.QualityToggleOnValueChanged(self, value)
	if value == ITEM_QUALITY2_DESC then
		TSM.db.global.destroyingOptions.deMaxQuality = 2
	elseif value == ITEM_QUALITY3_DESC then
		TSM.db.global.destroyingOptions.deMaxQuality = 3
	elseif value == ITEM_QUALITY4_DESC then
		TSM.db.global.destroyingOptions.deMaxQuality = 4
	else
		error("Unexpected value: "..tostring(value))
	end
end

function private.AboveValueInputOnEscapePressed(self)
	self:SetText(TSM.db.global.destroyingOptions.deAbovePrice)
	self:Draw()
end

function private.AboveValueInputOnEnterPressed(self)
	local value = self:GetText()
	local isValid, err = TSMAPI_FOUR.CustomPrice.Validate(value)
	if isValid then
		TSM.db.global.destroyingOptions.deAbovePrice = value
		self:SetText(value)
		self:Draw()
	else
		TSM:Print(L["Invalid custom price."].." "..err)
		self:SetFocused(true)
	end
end

function private.AboveValueResetOnClick(self)
	TSM.db.global.destroyingOptions.deAbovePrice = "0c"
	local input = self:GetElement("__parent.customPriceInput")
	input:SetText(TSM.db.global.destroyingOptions.deAbovePrice)
	input:Draw()
end
