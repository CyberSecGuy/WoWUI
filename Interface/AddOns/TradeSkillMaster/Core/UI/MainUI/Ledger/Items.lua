-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local Items = TSM.MainUI.Ledger:NewPackage("Items")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = {}



-- ============================================================================
-- Module Functions
-- ============================================================================

function Items.OnInitialize()
	TSM.MainUI.Ledger.RegisterPage(L["Items"], private.DrawItemsPage)
end



-- ============================================================================
-- Items UI
-- ============================================================================

function private.DrawItemsPage()
	return TSMAPI_FOUR.UI.NewElement("Frame", "content")
		:SetLayout("VERTICAL")
end
