-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local Auctioning = TSM.MainUI.Settings.Tooltip:NewPackage("Auctioning")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = {}



-- ============================================================================
-- Module Functions
-- ============================================================================

function Auctioning.OnInitialize()
	TSM.MainUI.Settings.Tooltip.RegisterTooltipPage(L["Auctioning"], private.GetTooltipSettingsFrame)
end



-- ============================================================================
-- Tooltip Settings UI
-- ============================================================================

function private.GetTooltipSettingsFrame()
	return TSMAPI_FOUR.UI.NewElement("ScrollFrame", "tooltipSettings")
		:SetStyle("padding", 10)
		:AddChild(TSM.MainUI.Settings.CreateHeadingLine("auctioningTooptipSettingsTitle", L["Auctioning Tooltips"]))
		:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "auctioningTooptipSettingsDesc")
			:SetStyle("height", 35)
			:SetStyle("fontHeight", 16)
			:SetStyle("justifyV", "CENTER")
			:SetText(L["Show auction operation values in item tooltips."])
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Checkbox", "auctioningValuesCheckbox")
			:SetStyle("height", 35)
			:SetContext("operationPrices")
			:SetText(L["Display auctioning values"])
			:SetChecked(TSM.db.global.tooltipOptions.moduleTooltips.Auctioning.operationPrices)
			:SetScript("OnValueChanged", private.SetAuctioningTooltipOption)
		)
end

function private.SetAuctioningTooltipOption(self, value)
	 TSM.db.global.tooltipOptions.moduleTooltips.Auctioning[self:GetContext()] = value
end