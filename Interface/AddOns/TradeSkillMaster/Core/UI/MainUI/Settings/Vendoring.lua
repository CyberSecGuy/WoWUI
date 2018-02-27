-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local Vendoring = TSM.MainUI.Settings:NewPackage("Vendoring")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = {}
local DEFAULT_PAGE = { L["Buy"], L["Buyback"], L["TSM Groups"], L["Quick Sell"] }


-- ============================================================================
-- Module Functions
-- ============================================================================

function Vendoring.OnInitialize()
	TSM.MainUI.Settings.RegisterSettingPage("Vendoring", "middle", private.GetVendoringSettingsFrame)
end



-- ============================================================================
-- Vendoring Settings UI
-- ============================================================================

function private.GetVendoringSettingsFrame()
	return TSMAPI_FOUR.UI.NewElement("ScrollFrame", "vendoringSettings")
		:SetStyle("padding.left", 12)
		:SetStyle("padding.right", 12)
		:AddChild(TSM.MainUI.Settings.CreateHeading("generalOptionsTitle", L["General Options"])
			:SetStyle("margin.bottom", 15)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "generalHeadingDesc")
			:SetStyle("height", 18)
			:SetStyle("margin.bottom", 4)
			:SetStyle("font", TSM.UI.Fonts.MontserratMedium)
			:SetStyle("fontHeight", 14)
			:SetStyle("textColor", "#ffffff")
			:SetText(L["Default vendoring page"])
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "dropdownFrame")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 26)
			:SetStyle("margin.bottom",8)
			:AddChild(TSMAPI_FOUR.UI.NewElement("SelectionDropdown", "defaultVendoringPageDropdown")
				:SetItems(DEFAULT_PAGE)
				:SetSelectedItem(DEFAULT_PAGE[TSM.db.global.vendoringOptions.defaultPage])
				:SetSettingInfo(TSM.db.global.vendoringOptions, "defaultPage")
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Spacer", "spacer"))
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Checkbox", "checkbox")
			:SetStyle("height", 28)
			:SetStyle("margin.left", -5)
			:SetStyle("font", TSM.UI.Fonts.MontserratMedium)
			:SetStyle("fontHeight", 12)
			:SetSettingInfo(TSM.db.global.vendoringOptions, "defaultMerchantTab")
			:SetText(L["Make vendoring default merchant tab?"])
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Checkbox", "checkbox")
			:SetStyle("height", 28)
			:SetStyle("margin.left", -5)
			:SetStyle("font", TSM.UI.Fonts.MontserratMedium)
			:SetStyle("fontHeight", 12)
			:SetSettingInfo(TSM.db.global.vendoringOptions, "autoSellTrash")
			:SetText(L["Automatically sell vendor trash?"])
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Checkbox", "checkbox")
			:SetStyle("height", 28)
			:SetStyle("margin.left", -5)
			:SetStyle("margin.bottom", 24)
			:SetStyle("font", TSM.UI.Fonts.MontserratMedium)
			:SetStyle("fontHeight", 12)
			:SetSettingInfo(TSM.db.global.vendoringOptions, "displayMoneyCollected")
			:SetText(L["Display total money recieved in chat?"])
		)
		:AddChild(TSM.MainUI.Settings.CreateHeading("quicksellOptionsTitle", L["Quick Sell Options"])
			:SetStyle("margin.bottom", 16)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
			:SetStyle("height", 18)
			:SetStyle("font", TSM.UI.Fonts.MontserratMedium)
			:SetStyle("fontHeight", 14)
			:SetStyle("textColor", "#ffffff")
			:SetStyle("margin.bottom", 4)
			:SetText(L["Batch size"])
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "qsBatchSizeInputFrame")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 20)
			:SetStyle("margin.bottom", 16)
			:AddChild(TSMAPI_FOUR.UI.NewElement("InputNumeric", "qsBatchSizeInput")
				:SetStyle("font", TSM.UI.Fonts.MontserratMedium)
				:SetStyle("textColor", "#ffffff")
				:SetStyle("background", "#5c5c5c")
				:SetStyle("height", 20)
				:SetStyle("width", 50)
				:SetStyle("fontHeight", 14)
				:SetStyle("margin.right", 10)
				:SetStyle("justifyH", "CENTER")
				:SetSettingInfo(TSM.db.global.vendoringOptions, "qsBatchSize")
				:SetMaxNumber(100)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "qsBatchSizeLabel")
				:SetStyle("fontHeight", 12)
				:SetText(L["(minimum 1 - maximum 100)"])
			)
		)
		:AddChild(TSM.MainUI.Settings.CreateInputWithReset("qsMarketValueSourceField", L["Market Value Price Source"], "global.vendoringOptions.qsMarketValue", private.CheckCustomPrice))
		:AddChild(TSM.MainUI.Settings.CreateInputWithReset("qsMaxMarketValueField", L["Max Market Value"], "global.vendoringOptions.qsMaxMarketValue", private.CheckCustomPrice))
		:AddChild(TSM.MainUI.Settings.CreateInputWithReset("qsDestroyValueField", L["Destroy Value"], "global.vendoringOptions.qsDestroyValue", private.CheckCustomPrice))
		:AddChild(TSM.MainUI.Settings.CreateInputWithReset("qsMaxDestroyField", L["Max Destroy Value"], "global.vendoringOptions.qsMaxDestroyValue", private.CheckCustomPrice))
end



-- ============================================================================
-- Local Script Handlers
-- ============================================================================

function private.CheckCustomPrice(value)
	if TSMAPI_FOUR.CustomPrice.Validate(value) then
		return true
	else
		-- TODO: better error message
		TSM:Print("Your custom price was incorrect. Please try again.")
		return false
	end
end
