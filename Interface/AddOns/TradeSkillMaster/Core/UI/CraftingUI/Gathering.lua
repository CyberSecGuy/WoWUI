-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local Gathering = TSM.UI.CraftingUI:NewPackage("Gathering")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = { oldFrame = nil }
local SHOW_TSM3_UI = true



-- ============================================================================
-- Module Functions
-- ============================================================================

function Gathering.OnInitialize()
	TSM.UI.CraftingUI.RegisterTopLevelPage("Gathering", "iconPack.24x24/Boxes", private.GetGatheringFrame)
end



-- ============================================================================
-- Gathering UI
-- ============================================================================

function private.GetGatheringFrame()
	if SHOW_TSM3_UI then
		-- temporarily show the TSM3 UI since the TSM4 one isn't ready yet
		local frame = TSMAPI_FOUR.UI.NewElement("Frame", "accounting")
			:SetLayout("VERTICAL")
			:SetStyle("padding", { top = 30 })
			:SetStyle("background", "#171717")
			:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "text")
				:SetStyle("height", 20)
				:SetStyle("textColor", "#ff2222")
				:SetStyle("justifyH", "CENTER")
				:SetText("This is a temporary view of the TSM3 UI until this one is updated for TSM4.")
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Texture", "line")
				:SetStyle("height", 2)
				:SetStyle("color", "#9d9d9d")
				:SetStyle("margin", { top = 16, bottom = 16 })
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "content"))
		local contentFrame = frame:GetElement("content"):_GetBaseFrame()
		if not private.oldFrame then
			private.oldFrame = TSM.old.Crafting.TradeSkill.CreateOldGatheringFrame(contentFrame)
		end
		private.oldFrame:ClearAllPoints()
		private.oldFrame:SetParent(contentFrame)
		private.oldFrame:SetAllPoints(contentFrame)
		private.oldFrame:Show()
		frame:SetScript("OnHide", function()
			private.oldFrame:Hide()
			private.oldFrame:SetParent(nil)
			private.oldFrame:ClearAllPoints()
		end)
		return frame
	end
	return TSMAPI_FOUR.UI.NewElement("Frame", "gatheringContent")
		:SetStyle("background", "#363636")
		:SetLayout("VERTICAL")
end
