-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local Ledger = TSM.MainUI:NewPackage("Ledger")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = {
	pages = {},
	childPages = {},
	callback = {},
}
local PAGE_PATH_SEP = "`"
local SHOW_TSM3_UI = true



-- ============================================================================
-- Module Functions
-- ============================================================================

function Ledger.OnInitialize()
	TSM.MainUI.RegisterTopLevelPage("Ledger", "iconPack.24x24/Inventory", private.GetLedgerFrame)
end

function Ledger.RegisterPage(name, callback)
	tinsert(private.pages, name)
	private.callback[name] = callback
end

function Ledger.RegisterChildPage(parentName, childName, callback)
	local path = parentName..PAGE_PATH_SEP..childName
	private.childPages[parentName] = private.childPages[parentName] or {}
	tinsert(private.childPages[parentName], childName)
	private.callback[path] = callback
end



-- ============================================================================
-- Ledger UI
-- ============================================================================

function private.GetLedgerFrame()
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

		if not private.tsm3SimpleFrame then
			private.tsm3SimpleFrame = LibStub("AceGUI-3.0"):Create("TSMSimpleFrame")
			private.tsm3SimpleFrame:SetLayout("Fill")
		else
			private.tsm3SimpleFrame:Show()
		end
		if #private.tsm3SimpleFrame.children > 0 then
			private.tsm3SimpleFrame:ReleaseChildren()
		end
		private.tsm3SimpleFrame.frame:SetParent(frame:GetElement("content"):_GetBaseFrame())
		private.tsm3SimpleFrame.frame:SetAllPoints()
		TSM.old.Accounting.Viewer.Load(private.tsm3SimpleFrame)
		frame:SetScript("OnHide", function()
			private.tsm3SimpleFrame:Hide()
		end)
		return frame
	end

	local defaultPage = private.pages[1]
	local frame = TSMAPI_FOUR.UI.NewElement("Frame", "ledger")
		:SetLayout("HORIZONTAL")
		:SetStyle("background", "#2e2e2e")
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "navigation")
			:SetLayout("VERTICAL")
			:SetStyle("background", "#585858")
			:SetStyle("width", 160)
			:SetStyle("padding.top", 31)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Texture", "shadow")
			:SetStyle("width", TSM.UI.TexturePacks.GetWidth("uiFrames.LargeApplicationFrameInnerFrameLeftEdge"))
			:SetStyle("texturePack", "uiFrames.LargeApplicationFrameInnerFrameLeftEdge")
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "contentFrame")
			:SetLayout("VERTICAL")
			:SetStyle("padding.top", 39)
			:AddChild(TSMAPI_FOUR.UI.NewElement("ViewContainer", "content")
				:SetNavCallback(private.ContentNavCallback)
			)
		)


	local content = frame:GetElement("contentFrame.content")
	local navFrame = frame:GetElement("navigation")
	for _, pageName in ipairs(private.pages) do
		navFrame:AddChild(TSMAPI_FOUR.UI.NewElement("Button", pageName)
			:SetStyle("height", 20)
			:SetStyle("justifyH", "LEFT")
			:SetStyle("margin.top", 8)
			:SetStyle("margin.left", 16)
			:SetStyle("fontHeight", 14)
			:SetContext(pageName)
			:SetText(pageName)
			:SetScript("OnClick", private.NavButtonOnClick)
		)
		print(pageName, defaultPage)
		content:AddPath(pageName, pageName == defaultPage)
		if private.childPages[pageName] then
			for _, childPageName in ipairs(private.childPages[pageName]) do
				local path = pageName..PAGE_PATH_SEP..childPageName
				navFrame:AddChild(TSMAPI_FOUR.UI.NewElement("Button", path)
					:SetStyle("height", 20)
					:SetStyle("justifyH", "LEFT")
					:SetStyle("margin.top", 4)
					:SetStyle("margin.left", 24)
					:SetStyle("fontHeight", 10)
					:SetContext(path)
					:SetText(strupper(childPageName))
					:SetScript("OnClick", private.NavButtonOnClick)
				)
				content:AddPath(path, path == defaultPage)
			end
		end
	end
	-- make all the navigation align to the top
	navFrame:AddChild(TSMAPI_FOUR.UI.NewElement("Spacer", "spacer"))

	private.UpdateNavFrame(navFrame, defaultPage)
	return frame
end

function private.ContentNavCallback(self, path)
	return private.callback[path]()
end



-- ============================================================================
-- Local Script Handlers
-- ============================================================================

function private.NavButtonOnClick(button)
	local path = button:GetContext()
	if private.childPages[path] then
		-- select the first child
		path = path..PAGE_PATH_SEP..private.childPages[path][1]
	end

	local ledgerFrame = button:GetParentElement():GetParentElement()
	local contentFrame = ledgerFrame:GetElement("contentFrame")
	local navFrame = ledgerFrame:GetElement("navigation")
	private.UpdateNavFrame(navFrame, path)
	navFrame:Draw()
	contentFrame:GetElement("content"):SetPath(path, true)
end



-- ============================================================================
-- Private Helper Functions
-- ============================================================================

function private.UpdateNavFrame(navFrame, selectedPath)
	local selectedPage = strsplit(PAGE_PATH_SEP, selectedPath)
	for _, pageName in ipairs(private.pages) do
		navFrame:GetElement(pageName)
			:SetStyle("font", pageName == selectedPage and TSM.UI.Fonts.MontserratBold or TSM.UI.Fonts.MontserratRegular)
			:SetStyle("textColor", pageName == selectedPage and "#ffffff" or "#e2e2e2")
		if private.childPages[pageName] then
			for _, childPageName in ipairs(private.childPages[pageName]) do
				local path = pageName..PAGE_PATH_SEP..childPageName
				if pageName == selectedPage then
					navFrame:GetElement(path)
						:SetStyle("font", TSM.UI.Fonts.MontserratBold)
						:SetStyle("textColor", path == selectedPath and "#ffd839" or "#e2e2e2")
						:Show()
				else
					navFrame:GetElement(path):Hide()
				end
			end
		end
	end
end
