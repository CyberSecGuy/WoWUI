-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

--- SmallApplicationFrame UI Element Class.
-- This is the base frame of the small TSM windows (i.e. Destroying). It is a subclass of the @{ApplicationFrame} class.
-- @classmod SmallApplicationFrame

local _, TSM = ...
local SmallApplicationFrame = TSMAPI_FOUR.Class.DefineClass("SmallApplicationFrame", TSM.UI.ApplicationFrame)
TSM.UI.SmallApplicationFrame = SmallApplicationFrame
local TITLE_BG_OFFSET_TOP = -11
local TITLE_BG_LEFT_OFFSET = 19
local TITLE_BG_RIGHT_OFFSET = -10
local TITLE_BG_CLOSE_PADDING = 6
local INNER_FRAME_OFFSET = 10
local INNER_FRAME_TOP_OFFSET = -46
local INNER_BORDER_RELATIVE_LEVEL = 10



-- ============================================================================
-- Public Class Methods
-- ============================================================================

function SmallApplicationFrame.__init(self)
	self.__super:__init()
	local frame = self:_GetBaseFrame()

	frame.headerBgLeft = frame:CreateTexture(nil, "BACKGROUND")
	frame.headerBgLeft:SetPoint("TOPLEFT")
	TSM.UI.TexturePacks.SetTextureAndSize(frame.headerBgLeft, "uiFrames.SmallApplicationOuterFrameTopLeftCorner")

	frame.headerBgRight = frame:CreateTexture(nil, "BACKGROUND")
	frame.headerBgRight:SetPoint("TOPRIGHT")
	TSM.UI.TexturePacks.SetTextureAndSize(frame.headerBgRight, "uiFrames.SmallApplicationOuterFrameTopRightCorner")

	frame.headerBgCenter = frame:CreateTexture(nil, "BACKGROUND")
	frame.headerBgCenter:SetPoint("TOPLEFT", frame.headerBgLeft, "TOPRIGHT")
	frame.headerBgCenter:SetPoint("TOPRIGHT", frame.headerBgRight, "TOPLEFT")
	TSM.UI.TexturePacks.SetTextureAndHeight(frame.headerBgCenter, "uiFrames.SmallApplicationOuterFrameTopEdge")

	frame.titleBgLeft = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
	frame.titleBgLeft:SetPoint("TOPLEFT", TITLE_BG_LEFT_OFFSET, TITLE_BG_OFFSET_TOP)
	TSM.UI.TexturePacks.SetTextureAndSize(frame.titleBgLeft, "uiFrames.HeaderLeft")

	frame.titleBgClose = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
	frame.titleBgClose:SetPoint("TOPRIGHT", frame, "TOPRIGHT", TITLE_BG_RIGHT_OFFSET, TITLE_BG_OFFSET_TOP)
	TSM.UI.TexturePacks.SetTextureAndSize(frame.titleBgClose, "uiFrames.SmallApplicationCloseFrameBackground")

	frame.titleBgRight = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
	frame.titleBgRight:SetPoint("TOPRIGHT", frame.titleBgClose, "TOPLEFT", -TITLE_BG_CLOSE_PADDING, 0)
	TSM.UI.TexturePacks.SetTextureAndSize(frame.titleBgRight, "uiFrames.HeaderRight")

	frame.titleBgCenter = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
	frame.titleBgCenter:SetPoint("TOPLEFT", frame.titleBgLeft, "TOPRIGHT")
	frame.titleBgCenter:SetPoint("TOPRIGHT", frame.titleBgRight, "TOPLEFT")
	TSM.UI.TexturePacks.SetTextureAndHeight(frame.titleBgCenter, "uiFrames.HeaderMiddle")

	frame.bottomLeftCorner = frame:CreateTexture(nil, "BACKGROUND")
	frame.bottomLeftCorner:SetPoint("BOTTOMLEFT")
	TSM.UI.TexturePacks.SetTextureAndSize(frame.bottomLeftCorner, "uiFrames.SmallApplicationOuterFrameBottomLeftCorner")

	frame.bottomRightCorner = frame:CreateTexture(nil, "BACKGROUND")
	frame.bottomRightCorner:SetPoint("BOTTOMRIGHT")
	TSM.UI.TexturePacks.SetTextureAndSize(frame.bottomRightCorner, "uiFrames.SmallApplicationOuterFrameBottomRightCorner")

	frame.leftEdge = frame:CreateTexture(nil, "BACKGROUND")
	frame.leftEdge:SetPoint("TOPLEFT", frame.headerBgLeft, "BOTTOMLEFT")
	frame.leftEdge:SetPoint("BOTTOMLEFT", frame.bottomLeftCorner, "TOPLEFT")
	TSM.UI.TexturePacks.SetTextureAndWidth(frame.leftEdge, "uiFrames.SmallApplicationOuterFrameLeftEdge")

	frame.rightEdge = frame:CreateTexture(nil, "BACKGROUND")
	frame.rightEdge:SetPoint("TOPRIGHT", frame.headerBgRight, "BOTTOMRIGHT")
	frame.rightEdge:SetPoint("BOTTOMRIGHT", frame.bottomRightCorner, "TOPRIGHT")
	TSM.UI.TexturePacks.SetTextureAndWidth(frame.rightEdge, "uiFrames.SmallApplicationOuterFrameRightEdge")

	frame.bottomEdge = frame:CreateTexture(nil, "BACKGROUND")
	frame.bottomEdge:SetPoint("BOTTOMLEFT", frame.bottomLeftCorner, "BOTTOMRIGHT")
	frame.bottomEdge:SetPoint("BOTTOMRIGHT", frame.bottomRightCorner, "BOTTOMLEFT")
	TSM.UI.TexturePacks.SetTextureAndHeight(frame.bottomEdge, "uiFrames.SmallApplicationOuterFrameBottomEdge")

	frame.innerBorderFrame = CreateFrame("Frame", nil, frame, nil)
	frame.innerBorderFrame:SetPoint("TOPLEFT", INNER_FRAME_OFFSET, INNER_FRAME_TOP_OFFSET)
	frame.innerBorderFrame:SetPoint("BOTTOMRIGHT", -INNER_FRAME_OFFSET, INNER_FRAME_OFFSET)

	frame.innerBottomRightCorner = frame.innerBorderFrame:CreateTexture(nil, "BACKGROUND")
	frame.innerBottomRightCorner:SetPoint("BOTTOMRIGHT")
	TSM.UI.TexturePacks.SetTextureAndSize(frame.innerBottomRightCorner, "uiFrames.SmallApplicationInnerFrameBottomRightCorner")

	frame.innerBottomLeftCorner = frame.innerBorderFrame:CreateTexture(nil, "BACKGROUND")
	frame.innerBottomLeftCorner:SetPoint("BOTTOMLEFT")
	TSM.UI.TexturePacks.SetTextureAndSize(frame.innerBottomLeftCorner, "uiFrames.SmallApplicationInnerFrameBottomLeftCorner")

	frame.innerTopRightCorner = frame.innerBorderFrame:CreateTexture(nil, "BACKGROUND")
	frame.innerTopRightCorner:SetPoint("TOPRIGHT")
	TSM.UI.TexturePacks.SetTextureAndSize(frame.innerTopRightCorner, "uiFrames.SmallApplicationInnerFrameTopRightCorner")

	frame.innerTopLeftCorner = frame.innerBorderFrame:CreateTexture(nil, "BACKGROUND")
	frame.innerTopLeftCorner:SetPoint("TOPLEFT")
	TSM.UI.TexturePacks.SetTextureAndSize(frame.innerTopLeftCorner, "uiFrames.SmallApplicationInnerFrameTopLeftCorner")

	frame.innerLeftEdge = frame.innerBorderFrame:CreateTexture(nil, "BACKGROUND")
	frame.innerLeftEdge:SetPoint("TOPLEFT", frame.innerTopLeftCorner, "BOTTOMLEFT")
	frame.innerLeftEdge:SetPoint("BOTTOMLEFT", frame.innerBottomLeftCorner, "TOPLEFT")
	TSM.UI.TexturePacks.SetTextureAndWidth(frame.innerLeftEdge, "uiFrames.SmallApplicationInnerFrameLeftEdge")

	frame.innerRightEdge = frame.innerBorderFrame:CreateTexture(nil, "BACKGROUND")
	frame.innerRightEdge:SetPoint("TOPRIGHT", frame.innerTopRightCorner, "BOTTOMRIGHT")
	frame.innerRightEdge:SetPoint("BOTTOMRIGHT", frame.innerBottomRightCorner, "TOPRIGHT")
	TSM.UI.TexturePacks.SetTextureAndWidth(frame.innerRightEdge, "uiFrames.SmallApplicationInnerFrameRightEdge")

	frame.innerTopEdge = frame.innerBorderFrame:CreateTexture(nil, "BACKGROUND")
	frame.innerTopEdge:SetPoint("TOPLEFT", frame.innerTopLeftCorner, "TOPRIGHT")
	frame.innerTopEdge:SetPoint("TOPRIGHT", frame.innerTopRightCorner, "TOPLEFT")
	TSM.UI.TexturePacks.SetTextureAndHeight(frame.innerTopEdge, "uiFrames.SmallApplicationInnerFrameTopEdge")

	frame.innerBottomEdge = frame.innerBorderFrame:CreateTexture(nil, "BACKGROUND")
	frame.innerBottomEdge:SetPoint("BOTTOMLEFT", frame.innerBottomLeftCorner, "BOTTOMRIGHT")
	frame.innerBottomEdge:SetPoint("BOTTOMRIGHT", frame.innerBottomRightCorner, "BOTTOMLEFT")
	TSM.UI.TexturePacks.SetTextureAndHeight(frame.innerBottomEdge, "uiFrames.SmallApplicationInnerFrameBottomEdge")

	frame.resizingContent = frame:CreateTexture(nil, "BACKGROUND")
	frame.resizingContent:SetAllPoints(frame.innerBorderFrame)
	frame.resizingContent:SetColorTexture(TSM.UI.HexToRGBA("#363636"))
	frame.resizingContent:Hide()
end

function SmallApplicationFrame.Acquire(self)
	local frame = self:_GetBaseFrame()
	self:AddChildNoLayout(TSMAPI_FOUR.UI.NewElement("Text", "title")
		:SetStyle("height", 15)
		:SetStyle("anchors", { { "LEFT", frame.titleBgLeft, "LEFT", 20, 0 }, { "RIGHT", frame.titleBgRight, "RIGHT", -5, 0 } })
		:SetStyle("font", TSM.UI.Fonts.MontserratMedium)
		:SetStyle("fontHeight", 12)
		:SetStyle("justifyH", "CENTER")
	)
	self:AddChildNoLayout(TSMAPI_FOUR.UI.NewElement("Button", "closeBtn")
		:SetStyle("anchors", { { "TOPLEFT", frame.titleBgClose }, { "BOTTOMRIGHT", frame.titleBgClose } })
		:SetStyle("backgroundTexturePack", "iconPack.24x24/Close/Default")
	)
	self.__super:Acquire()
end

--- Sets the content frame.
-- @see ApplicationFrame.SetContentFrame
-- @tparam SmallApplicationFrame self The small application frame object
-- @tparam Frame frame The content frame
-- @treturn SmallApplicationFrame The small application frame object
function SmallApplicationFrame.SetContentFrame(self, frame)
	frame:SetStyle("anchors", { { "TOPLEFT", INNER_FRAME_OFFSET, INNER_FRAME_TOP_OFFSET }, { "BOTTOMRIGHT", -INNER_FRAME_OFFSET, INNER_FRAME_OFFSET } })
	self.__super:SetContentFrame(frame)
	return self
end

function SmallApplicationFrame.Draw(self)
	self.__super:Draw()
	local frame = self:_GetBaseFrame()
	frame.innerBorderFrame:SetFrameLevel(frame:GetFrameLevel() + INNER_BORDER_RELATIVE_LEVEL)
end
