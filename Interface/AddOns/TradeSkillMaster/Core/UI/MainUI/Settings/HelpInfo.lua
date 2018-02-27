-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local HelpInfo = TSM.MainUI.Settings:NewPackage("HelpInfo")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = {}



-- ============================================================================
-- Module Functions
-- ============================================================================

function HelpInfo.OnInitialize()
	TSM.MainUI.Settings.RegisterSettingPage(L["Help & Info"], "bottom", private.GetHelpInfoSettingsFrame)
end



-- ============================================================================
-- HelpInfo Settings UI
-- ============================================================================

function private.GetHelpInfoSettingsFrame()
	return TSMAPI_FOUR.UI.NewElement("ScrollFrame", "content")
end
