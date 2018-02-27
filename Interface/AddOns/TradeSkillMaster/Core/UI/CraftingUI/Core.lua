-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local CraftingUI = TSM.UI:NewPackage("CraftingUI")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = { topLevelPages = {}, fsm = nil, defaultUISwitchBtn = nil }
local MIN_FRAME_SIZE = { width = 820, height = 587 }



-- ============================================================================
-- Module Functions
-- ============================================================================

function CraftingUI.OnInitialize()
	private.FSMCreate()
end

function CraftingUI.RegisterTopLevelPage(name, textureInfo, callback)
	tinsert(private.topLevelPages, { name = name, textureInfo = textureInfo, callback = callback })
end

function CraftingUI.Toggle()
	private.fsm:ProcessEvent("EV_FRAME_TOGGLE")
end

function CraftingUI.IsProfessionIgnored(name)
	for i in pairs(TSM.CONST.IGNORED_PROFESSIONS) do
		local ignoredName = GetSpellInfo(i)
		if ignoredName == name then
			return true
		end
	end
end



-- ============================================================================
-- Main Frame
-- ============================================================================

function private.CreateMainFrame()
	local frame = TSMAPI_FOUR.UI.NewElement("LargeApplicationFrame", "base")
		:SetParent(UIParent)
		:SetMinResize(MIN_FRAME_SIZE.width, MIN_FRAME_SIZE.height)
		:SetContextTable(TSM.db.global.internalData.craftingUIFrameContext, TSM.db:GetDefaultReadOnly("global", "internalData", "craftingUIFrameContext"))
		:SetStyle("smallNavArea", true)
		:SetStyle("strata", "HIGH")
		:SetTitle("TSM Crafting")
		:SetScript("OnHide", private.BaseFrameOnHide)
	frame:GetElement("titleFrame")
		:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "switchBtn")
			:SetStyle("width", 131)
			:SetStyle("height", 16)
			:SetStyle("backgroundTexturePack", "uiFrames.DefaultUIButton")
			:SetStyle("margin", { left = 8 })
			:SetStyle("font", TSM.UI.Fonts.MontserratBold)
			:SetStyle("fontHeight", 10)
			:SetStyle("textColor", "#2e2e2e")
			:SetText(L["Switch to WoW UI"])
			:SetScript("OnClick", private.SwitchBtnOnClick)
		)
	for _, info in ipairs(private.topLevelPages) do
		frame:AddNavButton(info.name, info.textureInfo, info.callback)
	end
	return frame
end



-- ============================================================================
-- Local Script Handlers
-- ============================================================================

function private.BaseFrameOnHide()
	private.fsm:ProcessEvent("EV_FRAME_TOGGLE")
end

function private.GetNavFrame(_, path)
	return private.topLevelPages.callback[path]()
end

function private.SwitchBtnOnClick(button)
	local wasDefault = button == private.defaultUISwitchBtn
	if wasDefault then
		button:SetPressed(false)
	end
	private.fsm:ProcessEvent("EV_SWITCH_BTN_CLICKED", wasDefault)
end



-- ============================================================================
-- FSM
-- ============================================================================

function private.FSMCreate()
	-- delay EV_TRADE_SKILL_SHOW by a frame to give textures some time to load
	local function DelayedShowEvent()
		private.fsm:ProcessEvent("EV_TRADE_SKILL_SHOW")
	end
	TSMAPI_FOUR.Event.Register("TRADE_SKILL_SHOW", function()
		TSMAPI_FOUR.Delay.AfterFrame(1, DelayedShowEvent)
	end)
	TSMAPI_FOUR.Event.Register("TRADE_SKILL_DATA_SOURCE_CHANGING", function()
		private.fsm:ProcessEvent("EV_DATA_SOURCE_CHANGING")
	end)
	-- we'll implement UIParent's event handler directly when necessary for TRADE_SKILL_SHOW
	UIParent:UnregisterEvent("TRADE_SKILL_SHOW")

	local fsmContext = {
		frame = nil,
	}
	local function UpdateCraftingFrame(context)
		if not context.frame then
			return
		end
		context.frame:Draw()
	end
	private.fsm = TSMAPI_FOUR.FSM.New("CRAFTING_UI")
		:AddState(TSMAPI_FOUR.FSM.NewState("ST_FRAME_CLOSED")
			:SetOnEnter(function(context, isSwitching)
				if context.frame then
					context.frame:Hide()
					context.frame:Release()
					context.frame = nil
				end
				if not C_TradeSkillUI.GetTradeSkillLine() then return end
				if isSwitching then
					UIParent_OnEvent(UIParent, "TRADE_SKILL_SHOW")
					if not private.defaultUISwitchBtn then
						private.defaultUISwitchBtn = TSMAPI_FOUR.UI.NewElement("ActionButton", "switchBtn")
							:SetStyle("width", 60)
							:SetStyle("height", 15)
							:SetStyle("anchors", { { "TOPRIGHT", -30, -4 } })
							:SetStyle("font", TSM.UI.Fonts.MontserratBold)
							:SetStyle("fontHeight", 12)
							:SetText(L["TSM4"])
							:SetScript("OnClick", private.SwitchBtnOnClick)
						private.defaultUISwitchBtn:_GetBaseFrame():SetParent(TradeSkillFrame)
					end
					if context.default then
						private.defaultUISwitchBtn:Hide()
					else
						private.defaultUISwitchBtn:Draw()
					end
					TradeSkillFrame:SetScript("OnHide", nil)
					TradeSkillFrame:OnEvent("TRADE_SKILL_DATA_SOURCE_CHANGED")
					TradeSkillFrame:OnEvent("TRADE_SKILL_LIST_UPDATE")
				else
					C_TradeSkillUI.CloseTradeSkill()
					C_Garrison.CloseGarrisonTradeskillNPC()
				end
			end)
			:AddTransition("ST_FRAME_OPENING")
			:AddEvent("EV_FRAME_TOGGLE", TSMAPI_FOUR.FSM.SimpleTransitionEventHandler("ST_FRAME_OPENING"))
			:AddEvent("EV_TRADE_SKILL_SHOW", TSMAPI_FOUR.FSM.SimpleTransitionEventHandler("ST_FRAME_OPENING"))
			:AddEvent("EV_SWITCH_BTN_CLICKED", TSMAPI_FOUR.FSM.SimpleTransitionEventHandler("ST_FRAME_OPENING"))
			:AddEvent("EV_DATA_SOURCE_CHANGING", TSMAPI_FOUR.FSM.SimpleTransitionEventHandler("ST_FRAME_OPENING"))
		)
		:AddState(TSMAPI_FOUR.FSM.NewState("ST_FRAME_OPENING")
			:SetOnEnter(function(context, wasDefault)
				if wasDefault or context.default then
					HideUIPanel(TradeSkillFrame)
					context.default = nil
				end
				local _, name = C_TradeSkillUI.GetTradeSkillLine()
				if CraftingUI.IsProfessionIgnored(name) then
					context.default = true
					return "ST_FRAME_CLOSED", true
				end
				context.frame = private.CreateMainFrame()
				context.frame:Show()
				return "ST_FRAME_OPEN"
			end)
			:AddTransition("ST_FRAME_OPEN")
			:AddTransition("ST_FRAME_CLOSED")
		)
		:AddState(TSMAPI_FOUR.FSM.NewState("ST_FRAME_OPEN")
			:SetOnEnter(function(context)
				UpdateCraftingFrame(context)
			end)
			:AddTransition("ST_FRAME_OPEN")
			:AddTransition("ST_FRAME_CLOSED")
			:AddTransition("ST_SWITCHING_TO_DEFAULT")
			:AddEvent("EV_SWITCH_BTN_CLICKED", TSMAPI_FOUR.FSM.SimpleTransitionEventHandler("ST_SWITCHING_TO_DEFAULT"))
			:AddEvent("EV_DATA_SOURCE_CHANGING", function(context)
				local _, name = C_TradeSkillUI.GetTradeSkillLine()
				if TSM.UI.CraftingUI.IsProfessionIgnored(name) then
					context.default = true
					return "ST_FRAME_CLOSED", true
				end
				return "ST_FRAME_OPEN"
			end)
		)
		:AddState(TSMAPI_FOUR.FSM.NewState("ST_SWITCHING_TO_DEFAULT")
			:SetOnEnter(function(context)
				if not C_TradeSkillUI.GetTradeSkillLine() then
					TSM:Printf(L["Cannot switch to the default UI when no profession is opened."])
					return "ST_FRAME_OPEN"
				end
				return "ST_FRAME_CLOSED", true
			end)
			:AddTransition("ST_FRAME_OPEN")
			:AddTransition("ST_FRAME_CLOSED")
		)
		:AddDefaultEvent("EV_FRAME_TOGGLE", TSMAPI_FOUR.FSM.SimpleTransitionEventHandler("ST_FRAME_CLOSED"))
		:Init("ST_FRAME_CLOSED", fsmContext)
end
