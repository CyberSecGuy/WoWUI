-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

--- LargeApplicationFrame UI Element Class.
-- This is the base frame of the large TSM windows which have tabs along the top (i.e. MainUI, AuctionUI, CraftingUI).
-- It is a subclass of the @{ApplicationFrame} class.
-- @classmod LargeApplicationFrame

local _, TSM = ...
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local LargeApplicationFrame = TSMAPI_FOUR.Class.DefineClass("LargeApplicationFrame", TSM.UI.ApplicationFrame)
TSM.UI.LargeApplicationFrame = LargeApplicationFrame
local private = {}
local ICON_SIZE = 22
local ICON_PADDING = 4
local NAV_BAR_HEIGHT = 26
local INNER_BORDER_RELATIVE_LEVEL = 20
local NAV_BAR_RELATIVE_LEVEL = INNER_BORDER_RELATIVE_LEVEL + 1

local TITLE_BG_OFFSET_X = 19
local TITLE_BG_OFFSET_TOP = -11
local TITLE_BG_CLOSE_PADDING = 6
local INNER_FRAME_PADDING = 10
local INNER_FRAME_TOP_OFFSET = -64
local NAV_BAR_TOP_OFFSET = INNER_FRAME_TOP_OFFSET + 15
local CONTENT_PADDING = 2



-- ============================================================================
-- Public Class Methods
-- ============================================================================

function LargeApplicationFrame.__init(self)
	self.__super:__init()
	local frame = self:_GetBaseFrame()
	local globalFrameName = tostring(frame)
	_G[globalFrameName] = frame
	tinsert(UISpecialFrames, globalFrameName)

	frame.headerBgLeft = frame:CreateTexture(nil, "BACKGROUND")
	frame.headerBgLeft:SetPoint("TOPLEFT", frame, "TOPLEFT")
	TSM.UI.TexturePacks.SetTextureAndSize(frame.headerBgLeft, "uiFrames.LargeApplicationOuterFrameTopLeftCorner")

	frame.headerBgRight = frame:CreateTexture(nil, "BACKGROUND")
	frame.headerBgRight:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
	TSM.UI.TexturePacks.SetTextureAndSize(frame.headerBgRight, "uiFrames.LargeApplicationOuterFrameTopRightCorner")

	frame.headerBgCenter = frame:CreateTexture(nil, "BACKGROUND")
	frame.headerBgCenter:SetPoint("TOPLEFT", frame.headerBgLeft, "TOPRIGHT")
	frame.headerBgCenter:SetPoint("TOPRIGHT", frame.headerBgRight, "TOPLEFT")
	TSM.UI.TexturePacks.SetTextureAndHeight(frame.headerBgCenter, "uiFrames.LargeApplicationOuterFrameTopEdge")

	frame.titleBgLeft = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
	frame.titleBgLeft:SetPoint("TOPLEFT", frame, "TOPLEFT", TITLE_BG_OFFSET_X, TITLE_BG_OFFSET_TOP)
	TSM.UI.TexturePacks.SetTextureAndSize(frame.titleBgLeft, "uiFrames.HeaderLeft")

	frame.titleBgClose = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
	frame.titleBgClose:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -TITLE_BG_OFFSET_X, TITLE_BG_OFFSET_TOP)
	TSM.UI.TexturePacks.SetTextureAndSize(frame.titleBgClose, "uiFrames.LargeApplicationCloseFrameBackground")

	frame.titleBgRight = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
	frame.titleBgRight:SetPoint("TOPRIGHT", frame.titleBgClose, "TOPLEFT", -TITLE_BG_CLOSE_PADDING, 0)
	TSM.UI.TexturePacks.SetTextureAndSize(frame.titleBgRight, "uiFrames.HeaderRight")

	frame.titleBgCenter = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
	frame.titleBgCenter:SetPoint("TOPLEFT", frame.titleBgLeft, "TOPRIGHT")
	frame.titleBgCenter:SetPoint("TOPRIGHT", frame.titleBgRight, "TOPLEFT")
	TSM.UI.TexturePacks.SetTextureAndHeight(frame.titleBgCenter, "uiFrames.HeaderMiddle")

	frame.bottomLeftCorner = frame:CreateTexture(nil, "BACKGROUND")
	frame.bottomLeftCorner:SetPoint("BOTTOMLEFT")
	TSM.UI.TexturePacks.SetTextureAndSize(frame.bottomLeftCorner, "uiFrames.LargeApplicationOuterFrameBottomLeftCorner")

	frame.bottomRightCorner = frame:CreateTexture(nil, "BACKGROUND")
	frame.bottomRightCorner:SetPoint("BOTTOMRIGHT")
	TSM.UI.TexturePacks.SetTextureAndSize(frame.bottomRightCorner, "uiFrames.LargeApplicationOuterFrameBottomRightCorner")

	frame.leftEdge = frame:CreateTexture(nil, "BACKGROUND")
	frame.leftEdge:SetPoint("TOPLEFT", frame.headerBgLeft, "BOTTOMLEFT")
	frame.leftEdge:SetPoint("BOTTOMLEFT", frame.bottomLeftCorner, "TOPLEFT")
	TSM.UI.TexturePacks.SetTextureAndWidth(frame.leftEdge, "uiFrames.LargeApplicationOuterFrameLeftEdge")

	frame.rightEdge = frame:CreateTexture(nil, "BACKGROUND")
	frame.rightEdge:SetPoint("TOPRIGHT", frame.headerBgRight, "BOTTOMRIGHT")
	frame.rightEdge:SetPoint("BOTTOMRIGHT", frame.bottomRightCorner, "TOPRIGHT")
	TSM.UI.TexturePacks.SetTextureAndWidth(frame.rightEdge, "uiFrames.LargeApplicationOuterFrameRightEdge")

	frame.bottomEdge = frame:CreateTexture(nil, "BACKGROUND")
	frame.bottomEdge:SetPoint("BOTTOMLEFT", frame.bottomLeftCorner, "BOTTOMRIGHT")
	frame.bottomEdge:SetPoint("BOTTOMRIGHT", frame.bottomRightCorner, "BOTTOMLEFT")
	TSM.UI.TexturePacks.SetTextureAndHeight(frame.bottomEdge, "uiFrames.LargeApplicationOuterFrameBottomEdge")

	frame.innerBorderFrame = CreateFrame("Frame", nil, frame, nil)
	frame.innerBorderFrame:SetPoint("TOPLEFT", INNER_FRAME_PADDING, INNER_FRAME_TOP_OFFSET)
	frame.innerBorderFrame:SetPoint("BOTTOMRIGHT", -INNER_FRAME_PADDING, INNER_FRAME_PADDING)

	frame.topEdge = frame:CreateTexture(nil, "BACKGROUND")
	frame.topEdge:SetPoint("BOTTOMLEFT", frame.innerBorderFrame, "TOPLEFT")
	frame.topEdge:SetPoint("BOTTOMRIGHT", frame.innerBorderFrame, "TOPRIGHT")
	frame.topEdge:SetPoint("TOP", frame.headerBgCenter, "BOTTOM")
	frame.topEdge:SetColorTexture(TSM.UI.HexToRGBA("#363636"))

	frame.innerBottomRightCorner = frame.innerBorderFrame:CreateTexture(nil, "BACKGROUND")
	frame.innerBottomRightCorner:SetPoint("BOTTOMRIGHT")
	TSM.UI.TexturePacks.SetTextureAndSize(frame.innerBottomRightCorner, "uiFrames.LargeApplicationFrameInnerFrameBottomRightCorner")

	frame.innerBottomLeftCorner = frame.innerBorderFrame:CreateTexture(nil, "BACKGROUND")
	frame.innerBottomLeftCorner:SetPoint("BOTTOMLEFT")
	TSM.UI.TexturePacks.SetTextureAndSize(frame.innerBottomLeftCorner, "uiFrames.LargeApplicationFrameInnerFrameBottomLeftCorner")

	frame.innerTopRightCorner = frame.innerBorderFrame:CreateTexture(nil, "BACKGROUND")
	frame.innerTopRightCorner:SetPoint("TOPRIGHT")
	TSM.UI.TexturePacks.SetTextureAndSize(frame.innerTopRightCorner, "uiFrames.LargeApplicationInnerFrameTopRightCorner")

	frame.innerTopLeftCorner = frame.innerBorderFrame:CreateTexture(nil, "BACKGROUND")
	frame.innerTopLeftCorner:SetPoint("TOPLEFT")
	TSM.UI.TexturePacks.SetTextureAndSize(frame.innerTopLeftCorner, "uiFrames.LargeApplicationInnerFrameTopLeftCorner")

	frame.innerLeftEdge = frame.innerBorderFrame:CreateTexture(nil, "BACKGROUND")
	frame.innerLeftEdge:SetPoint("TOPLEFT", frame.innerTopLeftCorner, "BOTTOMLEFT")
	frame.innerLeftEdge:SetPoint("BOTTOMLEFT", frame.innerBottomLeftCorner, "TOPLEFT")
	TSM.UI.TexturePacks.SetTextureAndWidth(frame.innerLeftEdge, "uiFrames.LargeApplicationFrameInnerFrameLeftEdge")

	frame.innerRightEdge = frame.innerBorderFrame:CreateTexture(nil, "BACKGROUND")
	frame.innerRightEdge:SetPoint("TOPRIGHT", frame.innerTopRightCorner, "BOTTOMRIGHT")
	frame.innerRightEdge:SetPoint("BOTTOMRIGHT", frame.innerBottomRightCorner, "TOPRIGHT")
	TSM.UI.TexturePacks.SetTextureAndWidth(frame.innerRightEdge, "uiFrames.LargeApplicationFrameInnerFrameRightEdge")

	frame.innerTopEdge = frame.innerBorderFrame:CreateTexture(nil, "BACKGROUND")
	frame.innerTopEdge:SetPoint("TOPLEFT", frame.innerTopLeftCorner, "TOPRIGHT")
	frame.innerTopEdge:SetPoint("TOPRIGHT", frame.innerTopRightCorner, "TOPLEFT")
	TSM.UI.TexturePacks.SetTextureAndHeight(frame.innerTopEdge, "uiFrames.LargeApplicationInnerFrameTopEdge")

	frame.innerBottomEdge = frame.innerBorderFrame:CreateTexture(nil, "BACKGROUND")
	frame.innerBottomEdge:SetPoint("BOTTOMLEFT", frame.innerBottomLeftCorner, "BOTTOMRIGHT")
	frame.innerBottomEdge:SetPoint("BOTTOMRIGHT", frame.innerBottomRightCorner, "BOTTOMLEFT")
	TSM.UI.TexturePacks.SetTextureAndHeight(frame.innerBottomEdge, "uiFrames.LargeApplicationFrameInnerFrameBottomEdge")

	frame.resizingContent = CreateFrame("Frame", nil, frame.innerBorderFrame, nil)
	frame.resizingContent:SetPoint("TOPLEFT")
	frame.resizingContent:SetPoint("BOTTOMRIGHT", frame, -INNER_FRAME_PADDING, INNER_FRAME_PADDING)
	frame.resizingContent:Hide()
	frame.resizingContent.texture = frame.resizingContent:CreateTexture(nil, "ARTWORK")
	frame.resizingContent.texture:SetAllPoints()
	frame.resizingContent.texture:SetColorTexture(TSM.UI.HexToRGBA("#363636"))
	frame.resizingContent.texture:Show()

	self._buttons = {}
	self._selectedButton = nil
	self._buttonIndex = {}
end

function LargeApplicationFrame.Acquire(self)
	local frame = self:_GetBaseFrame()
	local lastScan = TSM.old.AuctionDB.GetLastCompleteScanTime()
	self:AddChildNoLayout(TSMAPI_FOUR.UI.NewElement("Frame", "titleFrame")
		:SetLayout("HORIZONTAL")
		:SetStyle("height", 15)
		:SetStyle("anchors", { { "LEFT", frame.titleBgCenter, "LEFT", 0, 0 }, { "RIGHT", frame.titleBgCenter, "RIGHT", 16, 0 } })
		:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "title")
			:SetStyle("autoWidth", true)
			:SetStyle("font", TSM.UI.Fonts.MontserratBold)
			:SetStyle("fontHeight", 12)
			:SetStyle("textColor", "#ffffff")
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "version")
			:SetStyle("autoWidth", true)
			:SetStyle("font", TSM.UI.Fonts.MontserratMedium)
			:SetStyle("fontHeight", 12)
			:SetStyle("textColor", "#ffffff")
			:SetText("v4.0")
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Texture", "line")
			:SetStyle("width", 1)
			:SetStyle("margin", { left = 8, right = 8 })
			:SetStyle("color", "#80e2e2e2")
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "lastUpdate")
			:SetStyle("autoWidth", true)
			:SetStyle("font", TSM.UI.Fonts.MontserratMedium)
			:SetStyle("fontHeight", 12)
			:SetText(L["Last Data Update:"].." "..(lastScan and date("%c", lastScan) or L["No Data"]))
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Spacer"))
		:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "money")
			:SetStyle("autoWidth", true)
			:SetStyle("font", TSM.UI.Fonts.RobotoMedium)
			:SetStyle("fontHeight", 14)
			:SetStyle("textColor", "#ffffff")
			:SetText(TSMAPI_FOUR.Money.ToString(GetMoney(), "OPT_PAD", "OPT_SEP"))
			:SetTooltip(private.MoneyTooltipFunc)
			:SetScript("OnUpdate", private.MoneyOnUpdate)
		)
	)
	self:AddChildNoLayout(TSMAPI_FOUR.UI.NewElement("Button", "closeBtn")
		:SetStyle("anchors", { { "TOPLEFT", frame.titleBgClose } })
		:SetStyle("width", 36)
		:SetStyle("height", 28)
		:SetStyle("backgroundTexturePack", "iconPack.24x24/Close/Default")
	)
	self:SetContentFrame(TSMAPI_FOUR.UI.NewElement("Frame", "content")
		:SetLayout("VERTICAL")
		:SetStyle("background", "#363636")
		:SetStyle("padding", CONTENT_PADDING)
		:SetStyle("anchors", { { "TOPLEFT", INNER_FRAME_PADDING, INNER_FRAME_TOP_OFFSET }, { "BOTTOMRIGHT", -INNER_FRAME_PADDING, INNER_FRAME_PADDING } })
	)
	self.__super:Acquire()
end

function LargeApplicationFrame.Release(self)
	wipe(self._buttons)
	wipe(self._buttonIndex)
	self._selectedButton = nil
	self.__super:Release()
end

--- Sets the title text.
-- @tparam LargeApplicationFrame self The large application frame object
-- @tparam string title The title text
-- @treturn LargeApplicationFrame The large application frame object
function LargeApplicationFrame.SetTitle(self, title)
	local titleFrame = self:GetElement("titleFrame")
	titleFrame:GetElement("title"):SetText(title.." - ")
	titleFrame:Draw()
	return self
end

--- Sets the context table.
-- This table can be used to preserve position, size, and current page information across lifecycles of the frame and
-- even WoW sessions if it's within the settings DB.
-- @see ApplicationFrame.SetContextTable
-- @tparam LargeApplicationFrame self The large application frame object
-- @tparam table tbl The context table
-- @tparam table defaultTbl Default values (see @{ApplicationFrame.SetContextTable} for fields)
-- @treturn LargeApplicationFrame The large application frame object
function LargeApplicationFrame.SetContextTable(self, tbl, defaultTbl)
	assert(defaultTbl.page)
	tbl.page = tbl.page or defaultTbl.page
	self.__super:SetContextTable(tbl, defaultTbl)
	return self
end

--- Adds a top-level navigation button.
-- @tparam LargeApplicationFrame self The large application frame object
-- @tparam string text The button text
-- @tparam string texturePack The texture pack for the button icon
-- @tparam function drawCallback The function called when the button is clicked to get the corresponding content
-- @treturn LargeApplicationFrame The large application frame object
function LargeApplicationFrame.AddNavButton(self, text, texturePack, drawCallback)
	local button = TSMAPI_FOUR.UI.NewElement("AlphaAnimatedFrame", "NavBar_"..text)
		:SetRange(1, 0.3)
		:SetDuration(1)
		:SetLayout("HORIZONTAL")
		:SetStyle("relativeLevel", NAV_BAR_RELATIVE_LEVEL)
		:SetContext(drawCallback)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "button")
			:SetStyle("justifyH", "LEFT")
			:SetText(text)
			:SetScript("OnClick", private.OnNavBarButtonClicked)
		)
		:AddChildNoLayout(TSMAPI_FOUR.UI.NewElement("Frame", "icon")
			:SetStyle("anchors", { { "LEFT" } })
			:SetContext(texturePack)
		)
	self:AddChildNoLayout(button)
	tinsert(self._buttons, button)
	self._buttonIndex[text] = #self._buttons
	if self._buttonIndex[text] == self._contextTable.page then
		self:SetSelectedNavButton(text)
	end
	return self
end

--- Set the selected nav button.
-- @tparam LargeApplicationFrame self The large application frame object
-- @tparam string buttonText The button text
-- @tparam boolean redraw Whether or not to redraw the frame
function LargeApplicationFrame.SetSelectedNavButton(self, buttonText, redraw)
	if buttonText == self._selectedButton then
		return
	end
	local index = self._buttonIndex[buttonText]
	self._contextTable.page = index
	self._selectedButton = buttonText
	local contentFrame = self:GetElement("content")
	contentFrame:ReleaseAllChildren()
	contentFrame:AddChild(self._buttons[index]:GetContext()(self))
	if redraw then
		self:Draw()
	end
	return self
end

--- Sets which nav button is pulsing.
-- @tparam LargeApplicationFrame self The large application frame object
-- @tparam ?string buttonText The button text or nil if no nav button should be pulsing
function LargeApplicationFrame.SetPulsingNavButton(self, buttonText)
	local index = buttonText and self._buttonIndex[buttonText]
	for i, button in ipairs(self._buttons) do
		if not index or i ~= index then
			button:SetPlaying(false)
		elseif not button:IsPlaying() then
			button:SetPlaying(true)
		end
	end
end

--- Shows a dialog frame.
-- @tparam LargeApplicationFrame self The large application frame object
-- @tparam Element frame The element to show in a dialog
-- @param context The context to set on the dialog frame
function LargeApplicationFrame.ShowDialogFrame(self, frame, context)
	self:GetElement("content"):AddChildNoLayout(TSMAPI_FOUR.UI.NewElement("Frame", "dialog")
		:SetStyle("relativeLevel", INNER_BORDER_RELATIVE_LEVEL - 2)
		:SetStyle("anchors", { { "TOPLEFT" }, { "BOTTOMRIGHT" } })
		:SetStyle("background", "#592e2e2e")
		:SetMouseEnabled(true)
		:SetContext(context)
		:SetScript("OnMouseUp", private.DialogOnMouseUp)
		:SetScript("OnHide", private.DialogOnHide)
		:AddChildNoLayout(frame)
	)
	local dialog = self:GetElement("content.dialog")
	dialog:Show()
	dialog:Draw()
end

--- Show a dialog triggered by a "more" button.
-- @tparam LargeApplicationFrame self The large application frame object
-- @tparam Button moreBtn The "more" button
-- @tparam function iter A dialog menu row iterator with the following fields: `index, text, callback`
function LargeApplicationFrame.ShowMoreButtonDialog(self, moreBtn, iter)
	local frame = TSMAPI_FOUR.UI.NewElement("MenuDialogFrame", "moreDialog")
		:SetLayout("VERTICAL")
		:SetStyle("width", 180)
		:SetStyle("anchors", { { "TOPRIGHT", moreBtn:_GetBaseFrame(), "BOTTOM", 22, -16 } })
		:SetStyle("padding.top", 8)
		:SetStyle("padding.bottom", 4)
		:SetStyle("background", "#2e2e2e")
		:SetStyle("borderInset", 8)
	local numRows = 0
	for i, text, callback in iter do
		frame:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "row"..i)
			:SetStyle("height", 20)
			:SetStyle("font", TSM.UI.Fonts.MontserratMedium)
			:SetStyle("fontHeight", 14)
			:SetStyle("justifyH", "CENTER")
			:SetStyle("textColor", "#ffffff")
			:SetText(text)
			:SetScript("OnClick", callback)
		)
		numRows = numRows + 1
	end
	frame:SetStyle("height", 4 + numRows * 28)
	self:ShowDialogFrame(frame)
end

--- Show a confirmation dialog.
-- @tparam LargeApplicationFrame self The large application frame object
-- @tparam string title The title of the dialog
-- @tparam string subTitle The sub-title of the dialog
-- @tparam string confirmBtnText The confirm button text
-- @tparam function callback The callback for when the dialog is closed
-- @tparam[opt] varag ... Arguments to pass to the callback
function LargeApplicationFrame.ShowConfirmationDialog(self, title, subTitle, confirmBtnText, callback, ...)
	local context = TSMAPI_FOUR.Util.AcquireTempTable(...)
	context.callback = callback
	local frame = TSMAPI_FOUR.UI.NewElement("Frame", "frame")
		:SetLayout("VERTICAL")
		:SetStyle("width", 411)
		:SetStyle("height", 187)
		:SetStyle("anchors", { { "CENTER" } })
		:SetStyle("background", "#2e2e2e")
		:SetStyle("border", "#e2e2e2")
		:SetStyle("borderSize", 2)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "title")
			:SetStyle("height", 20)
			:SetStyle("margin", { top = 24, left = 16, right = 16, bottom = 16 })
			:SetStyle("font", TSM.UI.Fonts.bold)
			:SetStyle("fontHeight", 18)
			:SetStyle("justifyH", "CENTER")
			:SetText(title)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "desc")
			:SetStyle("height", 60)
			:SetStyle("margin", { left = 32, right = 32, bottom = 25 })
			:SetStyle("font", TSM.UI.Fonts.MontserratItalic)
			:SetStyle("fontHeight", 14)
			:SetStyle("justifyH", "CENTER")
			:SetText(subTitle)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "buttons")
			:SetLayout("HORIZONTAL")
			:SetStyle("margin", { left = 16, right = 16, bottom = 16 })
			:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "spacer")
				-- spacer
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "cancelBtn")
				:SetStyle("width", 80)
				:SetStyle("height", 26)
				:SetStyle("margin", { right = 16 })
				:SetStyle("font", TSM.UI.Fonts.MontserratMedium)
				:SetStyle("fontHeight", 16)
				:SetText(CANCEL)
				:SetScript("OnClick", private.DialogCancelBtnOnClick)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("ActionButton", "deleteBtn")
				:SetStyle("width", 126)
				:SetStyle("height", 26)
				:SetText(confirmBtnText)
				:SetScript("OnClick", private.DialogConfirmBtnOnClick)
			)
		)
	self:ShowDialogFrame(frame, context)
end

--- Hides the current dialog.
-- @tparam LargeApplicationFrame self The large application frame object
function LargeApplicationFrame.HideDialog(self)
	local dialog = self:GetElement("content.dialog")
	dialog:GetParentElement():RemoveChild(dialog)
	dialog:Hide()
	dialog:Release()
end

function LargeApplicationFrame.Draw(self)
	self.__super:Draw()
	self:GetElement("titleFrame"):Draw()
	local smallNavArea = self:_GetStyle("smallNavArea")
	local sidePadding = smallNavArea and 170 or 80
	local textColor = self:_GetStyle("textColor")
	local selectedTextColor = self:_GetStyle("selectedTextColor")
	local extraWidth = self:_GetDimension("WIDTH") - sidePadding * 2
	for i, buttonFrame in ipairs(self._buttons) do
		local button = buttonFrame:GetElement("button")
		local icon = buttonFrame:GetElement("icon")
		local color = i == self._contextTable.page and selectedTextColor or textColor
		button:SetStyle("font", self:_GetStyle("buttonFont"))
		button:SetStyle("fontHeight", self:_GetStyle("buttonFontHeight"))
		button:SetStyle("textColor", color)
		button:SetStyle("textIndent", ICON_SIZE + ICON_PADDING)
		button:Draw()
		local buttonWidth = ICON_SIZE + button:GetStringWidth() + ICON_PADDING
		icon:SetStyle("backgroundVertexColor", color)
		icon:SetStyle("backgroundTexturePack", icon:GetContext())
		icon:SetStyle("width", ICON_SIZE)
		icon:SetStyle("height", ICON_SIZE)
		buttonFrame:SetStyle("height", NAV_BAR_HEIGHT)
		buttonFrame:SetStyle("width", buttonWidth)
		extraWidth = extraWidth - buttonWidth
	end

	local spacing = extraWidth / #self._buttons
	local offsetX = spacing / 2 + sidePadding
	for _, buttonFrame in ipairs(self._buttons) do
		local buttonWidth = buttonFrame:GetElement("button"):GetStringWidth() + ICON_SIZE + ICON_PADDING
		buttonFrame:SetStyle("width", buttonWidth)
		buttonFrame:SetStyle("height", NAV_BAR_HEIGHT)
		local anchors = buttonFrame:_GetStyle("anchors")
		if anchors then
			anchors[1][2] = offsetX
		else
			buttonFrame:SetStyle("anchors", { { "TOPLEFT", offsetX, NAV_BAR_TOP_OFFSET } })
		end
		offsetX = offsetX + buttonWidth + spacing
		-- draw the buttons again now that we know their dimensions
		buttonFrame:Draw()
	end

	local frame = self:_GetBaseFrame()
	frame:SetToplevel(true)
	frame.resizingContent:SetFrameLevel(frame:GetFrameLevel() + INNER_BORDER_RELATIVE_LEVEL + 5)
	frame.innerBorderFrame:SetFrameLevel(frame:GetFrameLevel() + INNER_BORDER_RELATIVE_LEVEL)
	frame.innerBorderFrame:SetPoint("BOTTOMRIGHT", -INNER_FRAME_PADDING, INNER_FRAME_PADDING + (self:_GetStyle("bottomPadding") or 0))

	if smallNavArea then
		TSM.UI.TexturePacks.SetTextureAndSize(frame.innerTopRightCorner, "uiFrames.CraftingApplicationInnerFrameTopRightCorner")
		TSM.UI.TexturePacks.SetTextureAndSize(frame.innerTopLeftCorner, "uiFrames.CraftingApplicationInnerFrameTopLeftCorner")
	else
		TSM.UI.TexturePacks.SetTextureAndSize(frame.innerTopRightCorner, "uiFrames.LargeApplicationInnerFrameTopRightCorner")
		TSM.UI.TexturePacks.SetTextureAndSize(frame.innerTopLeftCorner, "uiFrames.LargeApplicationInnerFrameTopLeftCorner")
	end
end



-- ============================================================================
-- Public Class Methods
-- ============================================================================

function LargeApplicationFrame._SetResizing(self, resizing)
	for _, button in ipairs(self._buttons) do
		if resizing then
			button:Hide()
		else
			button:Show()
		end
	end
	self.__super:_SetResizing(resizing)
	if resizing then
		local minWidth, minHeight = self:_GetBaseFrame():GetMinResize()
		self._contentFrame:SetStyle("anchors", { { "CENTER" } })
		self._contentFrame:SetStyle("width", minWidth - 20)
		self._contentFrame:SetStyle("height", minHeight - 150)
		self._contentFrame:Draw()
	else
		self._contentFrame:SetStyle("anchors", { { "TOPLEFT", INNER_FRAME_PADDING, INNER_FRAME_TOP_OFFSET }, { "BOTTOMRIGHT", -INNER_FRAME_PADDING, INNER_FRAME_PADDING } })
		self._contentFrame:SetStyle("width", nil)
		self._contentFrame:SetStyle("height", nil)
	end
end



-- ============================================================================
-- Local Script Handlers
-- ============================================================================

function private.CloseButtonOnClick(button)
	button:GetBaseElement():Hide()
end

function private.OnNavBarButtonClicked(button)
	local self = button:GetParentElement():GetParentElement()
	self:SetSelectedNavButton(button:GetText(), true)
end

function private.DialogOnMouseUp(dialog)
	local self = dialog:GetParentElement():GetParentElement()
	self:HideDialog()
end

function private.DialogOnHide(dialog)
	local context = dialog:GetContext()
	if context then
		TSMAPI_FOUR.Util.ReleaseTempTable(context)
	end
end

function private.DialogCancelBtnOnClick(button)
	local self = button:GetBaseElement()
	self:HideDialog()
end

function private.DialogConfirmBtnOnClick(button)
	local self = button:GetBaseElement()
	local dialog = self:GetElement("content.dialog")
	local context = dialog:GetContext()
	dialog:SetContext(nil)
	self:HideDialog()
	context.callback(TSMAPI_FOUR.Util.UnpackAndReleaseTempTable(context))
end

function private.MoneyOnUpdate(text)
	text:SetText(TSMAPI_FOUR.Money.ToString(GetMoney(), "OPT_PAD", "OPT_SEP"))
	text:Draw()
end

function private.MoneyTooltipFunc()
	local tooltipLines = TSMAPI_FOUR.Util.AcquireTempTable()
	tinsert(tooltipLines, strjoin(TSM.CONST.TOOLTIP_SEP, L["Player Gold"]..":", TSMAPI_FOUR.Money.ToString(GetMoney(), "OPT_PAD", "OPT_SEP")))
	local numPosted, numSold, postedGold, soldGold = TSM.MyAuctions.GetAuctionInfo()
	if numPosted then
		tinsert(tooltipLines, strjoin(TSM.CONST.TOOLTIP_SEP, format(L["%d Sold Auctions"], numSold)..":", TSMAPI_FOUR.Money.ToString(soldGold, "OPT_PAD", "OPT_SEP")))
		tinsert(tooltipLines, strjoin(TSM.CONST.TOOLTIP_SEP, format(L["%d Posted Auctions"], numPosted)..":", TSMAPI_FOUR.Money.ToString(postedGold, "OPT_PAD", "OPT_SEP")))
	end
	return strjoin("\n", TSMAPI_FOUR.Util.UnpackAndReleaseTempTable(tooltipLines))
end
