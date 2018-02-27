-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Destroying                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_destroying          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSMCore = select(2, ...)
TSMCore.old.Destroying = TSMCore.old.Destroying or {}
local TSM = TSMAPI_FOUR.Addon.New("TradeSkillMaster_Destroying", TSMCore.old.Destroying)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table

-- Called once the player has loaded WOW.
function TSM:OnInitialize()
	-- FIXME: keep destroying working in the old settings UI for now
	TSM.moduleOptions = { callback = TSM.Options.LoadOptions }

	TSMAPI_FOUR.Modules.Register(TSM)
end
