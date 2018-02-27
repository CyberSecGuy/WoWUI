-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local Other = TSM.MainUI.Ledger.FailedAuctions:NewPackage("Other")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = {}



-- ============================================================================
-- Module Functions
-- ============================================================================

function Other.OnInitialize()
	TSM.MainUI.Ledger.FailedAuctions.RegisterPage(L["Other"], private.DrawOtherPage)
end



-- ============================================================================
-- Other UI
-- ============================================================================

function private.DrawOtherPage()
	return TSMAPI_FOUR.UI.NewElement("Frame", "content")
		:SetLayout("VERTICAL")
end
