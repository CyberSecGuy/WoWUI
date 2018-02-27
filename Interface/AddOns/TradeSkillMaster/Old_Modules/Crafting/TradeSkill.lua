-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Crafting                           --
--            http://www.curse.com/addons/wow/tradeskillmaster_crafting           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- create a local reference to the TradeSkillMaster_Crafting table and register a new module
local TSMCore = select(2, ...)
local TSM = TSMCore.old.Crafting
local TradeSkill = TSM:NewPackage("TradeSkill")



-- ============================================================================
-- General Module Functions
-- ============================================================================

function TradeSkill.CreateOldGatheringFrame(parent)
	local frame = TSMAPI.GUI:BuildFrame(TradeSkill.Gather:GetFrameInfo())
	TSMAPI.Design:SetFrameBackdropColor(frame)
	TradeSkill.Gather:OnButtonClicked(frame)
	return frame
end
