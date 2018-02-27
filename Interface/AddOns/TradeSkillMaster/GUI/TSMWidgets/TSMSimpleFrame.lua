--[[-----------------------------------------------------------------------------
Frame Container
-------------------------------------------------------------------------------]]
local Type, Version = "TSMSimpleFrame", 24
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local pairs, assert, type = pairs, assert, type
local wipe = table.wipe

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function Frame_OnClose(frame)
	frame.obj:Fire("OnClose")
end

local function Frame_OnMouseDown(frame)
	AceGUI:ClearFocus()
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		self.frame:SetParent(UIParent)
		self.frame:SetFrameStrata("FULLSCREEN_DIALOG")
		self:Show()
	end,

	["OnRelease"] = function(self)
		self.status = nil
		wipe(self.localstatus)
	end,

	["OnWidthSet"] = function(self, width)
		local content = self.content
		content:SetWidth(width)
		content.width = width
	end,

	["OnHeightSet"] = function(self, height)
		local content = self.content
		content:SetHeight(height)
		content.height = height
	end,

	["Hide"] = function(self)
		self.frame:Hide()
	end,

	["Show"] = function(self)
		self.frame:Show()
	end,
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:Hide()

	frame:SetFrameStrata("FULLSCREEN_DIALOG")
	frame:SetScript("OnHide", Frame_OnClose)
	frame:SetScript("OnMouseDown", Frame_OnMouseDown)

	--Container Support
	local content = CreateFrame("Frame", nil, frame)
	content:SetAllPoints()

	local widget = {
		localstatus = {},
		content     = content,
		frame       = frame,
		type        = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
