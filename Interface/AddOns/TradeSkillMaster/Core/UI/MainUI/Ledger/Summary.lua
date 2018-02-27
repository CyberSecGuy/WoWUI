-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local Summary = TSM.MainUI.Ledger:NewPackage("Summary")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = {}



-- ============================================================================
-- Module Functions
-- ============================================================================

function Summary.OnInitialize()
	TSM.MainUI.Ledger.RegisterPage(L["Summary"], private.DrawSummaryPage)
end



-- ============================================================================
-- Summary UI
-- ============================================================================

function private.DrawSummaryPage()
	return TSMAPI_FOUR.UI.NewElement("Frame", "content")
		:SetLayout("VERTICAL")
end
