-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local Purchases = TSM.MainUI.Ledger.Expenses:NewPackage("Purchases")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = {}



-- ============================================================================
-- Module Functions
-- ============================================================================

function Purchases.OnInitialize()
	TSM.MainUI.Ledger.Expenses.RegisterPage(L["Purchases"], private.DrawPurchasesPage)
end



-- ============================================================================
-- Purchases UI
-- ============================================================================

function private.DrawPurchasesPage()
	return TSMAPI_FOUR.UI.NewElement("Frame", "content")
		:SetLayout("VERTICAL")
end
