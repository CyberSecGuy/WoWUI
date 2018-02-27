-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local Cancelled = TSM.MainUI.Ledger.FailedAuctions:NewPackage("Cancelled")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = {}



-- ============================================================================
-- Module Functions
-- ============================================================================

function Cancelled.OnInitialize()
	TSM.MainUI.Ledger.FailedAuctions.RegisterPage(L["Cancelled"], private.DrawCancelledPage)
end



-- ============================================================================
-- Cancelled UI
-- ============================================================================

function private.DrawCancelledPage()
	return TSMAPI_FOUR.UI.NewElement("Frame", "content")
		:SetLayout("VERTICAL")
end
