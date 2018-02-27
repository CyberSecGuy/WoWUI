-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local Accounting = TSM.MainUI.Settings:NewPackage("Accounting")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = { marketValues = {} }
local DAYS_OLD_OPTIONS = { 30, 45, 60, 75, 90 }
local TIME_FORMAT_VALUES = { L["_ Hr _ Min ago"], L["MM/DD/YY HH:MM"], L["YY/MM/DD HH:MM"], L["DD/MM/YY HH:MM"] }
local TIME_FORMAT_KEYS = { "ago", "usdate", "aidate", "eudate" }



-- ============================================================================
-- Module Functions
-- ============================================================================

function Accounting.OnInitialize()
	assert(#TIME_FORMAT_VALUES == #TIME_FORMAT_KEYS)
	TSM.MainUI.Settings.RegisterSettingPage("Accounting", "middle", private.GetAccountingSettingsFrame)
end



-- ============================================================================
-- Accounting Settings UI
-- ============================================================================

function private.GetAccountingSettingsFrame()
	wipe(private.marketValues)
	for source in TSMAPI_FOUR.CustomPrice.Iterator() do
		tinsert(private.marketValues, source)
	end

	return TSMAPI_FOUR.UI.NewElement("ScrollFrame", "accountingSettings")
		:SetStyle("padding", 10)
		:AddChild(TSM.MainUI.Settings.CreateHeadingLine("generalOptionsTitle", L["General Options"]))
		:AddChild(TSM.MainUI.Settings.CreateSettingLine("timeFormatFrame", L["Set Time Format:"])
			:AddChild(TSMAPI_FOUR.UI.NewElement("Dropdown", "timeFormatDropdown")
				:SetItems(TIME_FORMAT_VALUES, private.TimeFormatKeyToValue(TSM.db.global.accountingOptions.timeFormat))
				:SetScript("OnSelectionChanged", private.SetTimeFormat)
			)
		)
		:AddChild(TSM.MainUI.Settings.CreateSettingLine("mvSourceFrame", L["Set Market Value Source:"])
			:AddChild(TSMAPI_FOUR.UI.NewElement("Dropdown", "mvSourceDropdown")
				:SetItems(private.marketValues, TSM.db.global.accountingOptions.mvSource)
				:SetScript("OnSelectionChanged", private.SetMarketValueSource)
			)
		)
		:AddChild(TSM.MainUI.Settings.CreateSettingLine("itemResaleFrame", L["Item / Resale price format:"])
			:AddChild(TSMAPI_FOUR.UI.NewElement("Toggle", "itemResaleToggle")
				:SetStyle("border", "#e2e2e2")
				:SetStyle("textColor", "#e2e2e2")
				:SetStyle("selectedBackground", "#e2e2e2")
				:SetStyle("height", 20)
				:AddOption(L["Per Item"], TSM.db.global.accountingOptions.priceFormat == "avg")
				:AddOption(L["Total Value"], TSM.db.global.accountingOptions.priceFormat == "total")
				:SetScript("OnValueChanged", private.SetPriceFormat)
			)
		)
		:AddChild(TSM.MainUI.Settings.CreateSettingLine("trackSalesFrame", L["Track Sales / Purchases via trade?"])
			:AddChild(TSMAPI_FOUR.UI.NewElement("Toggle", "trackSalesToggle")
				:SetStyle("width", 80)
				:SetStyle("height", 20)
				:SetBooleanToggle(TSM.db.global.accountingOptions, "trackTrades")
			)
		)
		:AddChild(TSM.MainUI.Settings.CreateSettingLine("promptTradesFrame", L["Prompt to record trades?"])
			:AddChild(TSMAPI_FOUR.UI.NewElement("Toggle", "promptTradesToggle")
				:SetStyle("width", 80)
				:SetStyle("height", 20)
				:SetBooleanToggle(TSM.db.global.accountingOptions, "autoTrackTrades")
			)
		)
		:AddChild(TSM.MainUI.Settings.CreateSettingLine("smartAvgFrame", L["Use smart average for purchase price?"])
			:AddChild(TSMAPI_FOUR.UI.NewElement("Toggle", "smartAvgToggle")
				:SetStyle("width", 80)
				:SetStyle("height", 20)
				:SetBooleanToggle(TSM.db.global.accountingOptions, "smartBuyPrice")
			)
		)
		:AddChild(TSM.MainUI.Settings.CreateHeadingLine("clearOldDataTitle", L["Clear Old Data"]))
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "clearDataDesc")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 70)
			:SetStyle("margin", { bottom = 16 })
			:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
				:SetStyle("textColor", "#e2e2e2")
				:SetStyle("fontHeight", 16)
				:SetStyle("justifyV", "CENTER")
				:SetText(L["You can use the options below to clear old data. It is recommended to occasionally clear your old data to keep the accounting module running smoothly. Select the minimum number of days old to be removed, then click ‘confirm’"])
			)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "minDaysOldFrame")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 26)
			:SetStyle("margin", { bottom = 16 })
			:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
				:SetStyle("textColor", "#e2e2e2")
				:SetStyle("fontHeight", 18)
				:SetStyle("justifyV", "CENTER")
				:SetStyle("width", 250)
				:SetText(L["Minimum Days Old:"])
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Dropdown", "minDaysOldDropdown")
				:SetItems(DAYS_OLD_OPTIONS)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "confirmMinDaysOld")
				:SetStyle("width", 100)
				:SetStyle("height", 20)
				:SetStyle("fontHeight", 16)
				:SetStyle("borderTexture", "Interface\\Addons\\TradeSkillMaster\\Media\\ButtonEdgeFrame.blp")
				:SetStyle("borderSize", 3)
				:SetText("CONFIRM")
				:SetScript("OnClick", private.ConfirmRemoveOldOnclick)
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

function private.SetTimeFormat(self, value)
	TSM.db.global.accountingOptions.timeFormat = private.TimeFormatValueToKey(value)
end

function private.SetMarketValueSource(self, value)
	TSM.db.global.accountingOptions.mvSource = value
end

function private.SetPriceFormat(self, value)
	if value == L["Per Item"] then
		TSM.db.global.accountingOptions.priceFormat = "avg"
	elseif value == L["Total Value"] then
		TSM.db.global.accountingOptions.priceFormat = "total"
	else
		error("Unknown value: "..tostring(value))
	end
end

function private.ConfirmRemoveOldOnclick(self)
	local dropdown = self:GetElement("__parent.minDaysOldDropdown")
	local daysOld = dropdown:GetSelection()
	if not daysOld then
		return
	end
	TSM.old.Accounting.ViewerUtil:RemoveOldData(daysOld)
	dropdown:SetSelection(nil)
end
