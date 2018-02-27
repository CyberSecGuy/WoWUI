-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

--- ApplicationFrame UI Element Class.
-- An application frame is an abstract class which contains common functionality for @{LargeApplicationFrame} and
-- @{SmallApplicationFrame}. It is a subclass of the @{Frame} class.
-- @classmod ApplicationFrame

local _, TSM = ...
local ApplicationFrame = TSMAPI_FOUR.Class.DefineClass("ApplicationFrame", TSM.UI.Frame, "ABSTRACT")
TSM.UI.ApplicationFrame = ApplicationFrame
local private = {}



-- ============================================================================
-- Public Class Methods
-- ============================================================================

function ApplicationFrame.__init(self)
	self.__super:__init()
	self._contentFrame = nil
	self._contextTable = nil
	self._defaultContextTable = nil
end

function ApplicationFrame.Acquire(self)
	self:AddChildNoLayout(TSMAPI_FOUR.UI.NewElement("Button", "resizeBtn")
		:SetStyle("anchors", { { "BOTTOMRIGHT" } })
		:SetStyle("height", TSM.UI.TexturePacks.GetHeight("iconPack.14x14/Resize"))
		:SetStyle("width", TSM.UI.TexturePacks.GetWidth("iconPack.14x14/Resize"))
		:SetStyle("backgroundTexturePack", "iconPack.14x14/Resize")
		:EnableRightClick()
		:SetScript("OnMouseDown", private.ResizeButtonOnMouseDown)
		:SetScript("OnMouseUp", private.ResizeButtonOnMouseUp)
		:SetScript("OnClick", private.ResizeButtonOnClick)
	)
	self.__super:Acquire()
	local frame = self:_GetBaseFrame()
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetResizable(true)
	frame:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart", private.FrameOnDragStart)
	self:SetScript("OnDragStop", private.FrameOnDragStop)
	self:GetElement("closeBtn"):SetScript("OnClick", private.CloseButtonOnClick)
end

function ApplicationFrame.Release(self)
	self._contentFrame = nil
	self._contextTable = nil
	self._defaultContextTable = nil
	self:_GetBaseFrame():SetMinResize(0, 0)
	self.__super:Release()
end

--- Sets the title text.
-- @tparam ApplicationFrame self The application frame object
-- @tparam string title The title text
-- @treturn ApplicationFrame The application frame object
function ApplicationFrame.SetTitle(self, title)
	self:GetElement("title"):SetText(title)
	return self
end

--- Sets the content frame.
-- @tparam ApplicationFrame self The application frame object
-- @tparam Frame frame The frame's content frame
-- @treturn ApplicationFrame The application frame object
function ApplicationFrame.SetContentFrame(self, frame)
	assert(frame:__isa(TSM.UI.Frame))
	self._contentFrame = frame
	self:AddChildNoLayout(frame)
	return self
end

--- Sets the context table.
-- This table can be used to preserve position and size information across lifecycles of the application frame and even
-- WoW sessions if it's within the settings DB.
-- @tparam ApplicationFrame self The application frame object
-- @tparam table tbl The context table
-- @tparam table defaultTbl Default values (required attributes: `width`, `height`, `centerX`, `centerY`)
-- @treturn ApplicationFrame The application frame object
function ApplicationFrame.SetContextTable(self, tbl, defaultTbl)
	assert(defaultTbl.width > 0 and defaultTbl.height > 0)
	assert(defaultTbl.centerX and defaultTbl.centerY)
	tbl.width = tbl.width or defaultTbl.width
	tbl.height = tbl.height or defaultTbl.height
	tbl.centerX = tbl.centerX or defaultTbl.centerX
	tbl.centerY = tbl.centerY or defaultTbl.centerY
	self._contextTable = tbl
	self._defaultContextTable = defaultTbl
	return self
end

--- Sets the minimum size the application frame can be resized to.
-- @tparam ApplicationFrame self The application frame object
-- @tparam number minWidth The minimum width
-- @tparam number minHeight The minimum height
-- @treturn ApplicationFrame The application frame object
function ApplicationFrame.SetMinResize(self, minWidth, minHeight)
	self:_GetBaseFrame():SetMinResize(minWidth, minHeight)
	return self
end

function ApplicationFrame.Draw(self)
	local frame = self:_GetBaseFrame()

	-- update the size if it's less than the set min size
	local minWidth, minHeight = frame:GetMinResize()
	assert(minWidth > 0 and minHeight > 0)
	self._contextTable.width = max(self._contextTable.width, minWidth)
	self._contextTable.height = max(self._contextTable.height, minHeight)

	-- set the frame size from the contextTable
	self:SetStyle("width", self._contextTable.width)
	self:SetStyle("height", self._contextTable.height)

	-- make sure the center of the frame is on the screen
	local maxAbsCenterX = UIParent:GetWidth() / 2
	local maxAbsCenterY = UIParent:GetHeight() / 2
	self._contextTable.centerX = min(max(self._contextTable.centerX, -maxAbsCenterX), maxAbsCenterX)
	self._contextTable.centerY = min(max(self._contextTable.centerY, -maxAbsCenterY), maxAbsCenterY)

	-- set the frame position from the contextTable
	local anchors = self:_GetStyle("anchors") or { { "CENTER" } }
	anchors[1][2] = self._contextTable.centerX
	anchors[1][3] = self._contextTable.centerY
	self:SetStyle("anchors", anchors)

	self.__super:Draw()
end



-- ============================================================================
-- Private Class Methods
-- ============================================================================

function ApplicationFrame._SavePositionAndSize(self)
	local frame = self:_GetBaseFrame()
	local parentFrame = frame:GetParent()
	local width = frame:GetWidth()
	local height = frame:GetHeight()
	self._contextTable.width = width
	self._contextTable.height = height
	local frameLeftOffset = frame:GetLeft() - parentFrame:GetLeft()
	self._contextTable.centerX = frameLeftOffset - (parentFrame:GetWidth() - width) / 2
	local frameBottomOffset = frame:GetBottom() - parentFrame:GetBottom()
	self._contextTable.centerY = frameBottomOffset - (parentFrame:GetHeight() - height) / 2
end

function ApplicationFrame._SetResizing(self, resizing)
	if resizing then
		self:_GetBaseFrame().resizingContent:Show()
	else
		self:_GetBaseFrame().resizingContent:Hide()
	end
end



-- ============================================================================
-- Local Script Handlers
-- ============================================================================

function private.CloseButtonOnClick(button)
	button:GetParentElement():Hide()
end

function private.ResizeButtonOnMouseDown(button, mouseButton)
	if mouseButton ~= "LeftButton" then
		return
	end
	local self = button:GetParentElement()
	self:_SetResizing(true)
	self:_GetBaseFrame():StartSizing("BOTTOMRIGHT")
end

function private.ResizeButtonOnMouseUp(button, mouseButton)
	if mouseButton ~= "LeftButton" then
		return
	end
	local self = button:GetParentElement()
	self:_SetResizing(false)
	self:_GetBaseFrame():StopMovingOrSizing()
	self:_SavePositionAndSize()
	self:Draw()
end

function private.ResizeButtonOnClick(button, mouseButton)
	if mouseButton ~= "RightButton" then
		return
	end
	local self = button:GetParentElement()
	self._contextTable.width = self._defaultContextTable.width
	self._contextTable.height = self._defaultContextTable.height
	self._contextTable.centerX = self._defaultContextTable.centerX
	self._contextTable.centerY = self._defaultContextTable.centerY
	self:Draw()
end

function private.FrameOnDragStart(self)
	self:_GetBaseFrame():StartMoving()
end

function private.FrameOnDragStop(self)
	local frame = self:_GetBaseFrame()
	frame:StopMovingOrSizing()
	self:_SavePositionAndSize()
end
