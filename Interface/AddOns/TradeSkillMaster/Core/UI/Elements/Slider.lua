-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

--- Slider UI Element Class.
-- A slider allows for selecting a numerical range. It is a subclass of the @{Element} class.
-- @classmod Slider

local _, TSM = ...
local Slider = TSMAPI_FOUR.Class.DefineClass("Slider", TSM.UI.Element)
TSM.UI.Slider = Slider
local private = { frameSliderLookup = {} }
local THUMB_WIDTH = 8
local THUMB_TEXT_PADDING = 2
local INPUT_WIDTH = 100



-- ============================================================================
-- Public Class Methods
-- ============================================================================

function Slider.__init(self)
	local frame = CreateFrame("Frame", nil, nil, nil)
	frame:EnableMouse(true)
	frame:SetScript("OnMouseDown", private.FrameOnMouseDown)
	frame:SetScript("OnMouseUp", private.FrameOnMouseUp)
	frame:SetScript("OnUpdate", private.FrameOnUpdate)
	private.frameSliderLookup[frame] = self

	self.__super:__init(frame)

	-- create the extures
	frame.barTexture = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
	frame.activeBarTexture = frame:CreateTexture(nil, "BACKGROUND", nil, 2)
	frame.thumbTextureLeft = frame:CreateTexture(nil, "ARTWORK")
	frame.thumbTextureRight = frame:CreateTexture(nil, "ARTWORK")

	-- create the left text and input
	frame.textLeft = frame:CreateFontString()
	frame.textLeft:SetJustifyH("CENTER")
	frame.inputLeft = CreateFrame("EditBox", nil, frame, nil)
	frame.inputLeft:SetPoint("TOP", frame.textLeft)
	frame.inputLeft:SetPoint("BOTTOM", frame.textLeft)
	frame.inputLeft:SetJustifyH("CENTER")
	frame.inputLeft:SetWidth(INPUT_WIDTH)
	frame.inputLeft:SetAutoFocus(true)
	frame.inputLeft:SetNumeric(true)
	frame.inputLeft:SetScript("OnEscapePressed", private.InputOnEscapePressed)
	frame.inputLeft:SetScript("OnEnterPressed", private.InputOnEnterPressed)

	-- create the right text and input
	frame.textRight = frame:CreateFontString()
	frame.textRight:SetJustifyH("CENTER")
	frame.inputRight = CreateFrame("EditBox", nil, frame, nil)
	frame.inputRight:SetPoint("TOP", frame.textLeft)
	frame.inputRight:SetPoint("BOTTOM", frame.textLeft)
	frame.inputRight:SetJustifyH("CENTER")
	frame.inputRight:SetWidth(INPUT_WIDTH)
	frame.inputRight:SetAutoFocus(true)
	frame.inputRight:SetNumeric(true)
	frame.inputRight:SetScript("OnEscapePressed", private.InputOnEscapePressed)
	frame.inputRight:SetScript("OnEnterPressed", private.InputOnEnterPressed)

	self._leftValue = nil
	self._rightValue = nil
	self._minValue = nil
	self._maxValue = nil
	self._dragging = nil
end

function Slider.Acquire(self)
	local frame = self:_GetBaseFrame()
	frame.textLeft:Show()
	frame.textRight:Show()
	frame.inputLeft:Hide()
	frame.inputRight:Hide()
	self.__super:Acquire()
end

function Slider.Release(self)
	self._leftValue = nil
	self._rightValue = nil
	self._minValue = nil
	self._maxValue = nil
	self._dragging = nil
	self.__super:Release()
end

--- Set the extends of the possible range.
-- @tparam Slider self The slider object
-- @tparam number minValue The minimum value
-- @tparam number maxValue The maxmimum value
-- @treturn Slider The slider object
function Slider.SetRange(self, minValue, maxValue)
	self._minValue = minValue
	self._maxValue = maxValue
	self._leftValue = minValue
	self._rightValue = maxValue
	return self
end

--- Sets the current value.
-- @tparam Slider self The slider object
-- @tparam number leftValue The lower end of the range
-- @tparam number rightValue The upper end of the range
-- @treturn Slider The slider object
function Slider.SetValue(self, leftValue, rightValue)
	assert(leftValue < rightValue and leftValue >= self._minValue and rightValue <= self._maxValue)
	self._leftValue = leftValue
	self._rightValue = rightValue
	return self
end

--- Gets the current value
-- @tparam Slider self The slider object
-- @treturn number The lower end of the range
-- @treturn number The upper end of the range
function Slider.GetValue(self)
	return self._leftValue, self._rightValue
end

function Slider.Draw(self)
	self.__super:Draw()
	local frame = self:_GetBaseFrame()

	-- wow renders the font slightly bigger than the designs would indicate, so subtract one from the font height
	frame.textLeft:SetFont(self:_GetStyle("font"), self:_GetStyle("fontHeight") - 1)
	frame.textLeft:SetTextColor(TSM.UI.HexToRGBA(self:_GetStyle("textColor")))
	frame.textLeft:SetText(self._leftValue)

	-- wow renders the font slightly bigger than the designs would indicate, so subtract one from the font height
	frame.inputLeft:SetFont(self:_GetStyle("font"), self:_GetStyle("fontHeight") - 1)
	frame.inputLeft:SetTextColor(TSM.UI.HexToRGBA(self:_GetStyle("textColor")))

	-- wow renders the font slightly bigger than the designs would indicate, so subtract one from the font height
	frame.textRight:SetFont(self:_GetStyle("font"), self:_GetStyle("fontHeight") - 1)
	frame.textRight:SetTextColor(TSM.UI.HexToRGBA(self:_GetStyle("textColor")))
	frame.textRight:SetText(self._rightValue)

	local frame = self:_GetBaseFrame()
	local sliderHeight = self:_GetDimension("HEIGHT") / 2 - THUMB_TEXT_PADDING
	local width = self:_GetDimension("WIDTH")
	local leftPos = TSMAPI_FOUR.Util.Scale(self._leftValue, self._minValue, self._maxValue, 0, width - THUMB_WIDTH)
	local rightPos = TSMAPI_FOUR.Util.Scale(self._rightValue, self._minValue, self._maxValue, 0, width - THUMB_WIDTH)

	frame.barTexture:ClearAllPoints()
	frame.barTexture:SetPoint("TOPLEFT", 0, -sliderHeight / 4)
	frame.barTexture:SetPoint("TOPRIGHT", 0, -sliderHeight / 4)
	frame.barTexture:SetHeight(sliderHeight / 2)
	frame.barTexture:SetColorTexture(TSM.UI.HexToRGBA("#22979797"))

	frame.thumbTextureLeft:SetHeight(sliderHeight)
	frame.thumbTextureLeft:SetWidth(THUMB_WIDTH)
	frame.thumbTextureLeft:SetColorTexture(TSM.UI.HexToRGBA("#ffd839"))
	frame.thumbTextureLeft:SetPoint("LEFT", frame.barTexture, leftPos, 0)
	self:_SetTextLayout(frame.textLeft, frame.thumbTextureLeft)

	frame.thumbTextureRight:SetHeight(sliderHeight)
	frame.thumbTextureRight:SetWidth(THUMB_WIDTH)
	frame.thumbTextureRight:SetColorTexture(TSM.UI.HexToRGBA("#ffd839"))
	frame.thumbTextureRight:SetPoint("LEFT", frame.barTexture, rightPos, 0)
	self:_SetTextLayout(frame.textRight, frame.thumbTextureRight)

	frame.activeBarTexture:SetPoint("LEFT", frame.thumbTextureLeft, "CENTER")
	frame.activeBarTexture:SetPoint("RIGHT", frame.thumbTextureRight, "CENTER")
	frame.activeBarTexture:SetHeight(sliderHeight / 2)
	frame.activeBarTexture:SetColorTexture(TSM.UI.HexToRGBA("#979797"))
end



-- ============================================================================
-- Private Class Methods
-- ============================================================================

function Slider._SetTextLayout(self, text, texture)
	local frame = self:_GetBaseFrame()
	text:SetWidth(500)
	text:SetHeight(self:_GetDimension("HEIGHT") / 2)
	text:SetPoint("TOP", texture, "BOTTOM", 0, -2)
	text:SetWidth(text:GetStringWidth())

	local offset = 0
	if text:GetLeft() < frame:GetLeft() then
		offset = frame:GetLeft() - text:GetLeft()
	elseif text:GetRight() > frame:GetRight() then
		offset = frame:GetRight() - text:GetRight()
	end
	text:SetPoint("TOP", texture, "BOTTOM", offset, -2)
end

function Slider._GetCursorPositionValue(self)
	local frame = self:_GetBaseFrame()
	local x = GetCursorPosition() / frame:GetEffectiveScale()
	local left = frame:GetLeft() + THUMB_WIDTH / 2
	local right = frame:GetRight() - THUMB_WIDTH / 2
	x = min(max(x, left), right)
	local value = TSMAPI_FOUR.Util.Scale(x, left, right, self._minValue, self._maxValue)
	return min(max(TSMAPI_FOUR.Util.Round(value), self._minValue), self._maxValue)
end

function Slider._UpdateLeftValue(self, value)
	local newValue = max(min(value, self._rightValue), self._minValue)
	if newValue == self._leftValue then
		return
	end
	self._leftValue = newValue
	self:Draw()
end

function Slider._UpdateRightValue(self, value)
	local newValue = min(max(value, self._leftValue), self._maxValue)
	if newValue == self._rightValue then
		return
	end
	self._rightValue = newValue
	self:Draw()
end



-- ============================================================================
-- Local Script Handlers
-- ============================================================================

function private.InputOnEscapePressed(input)
	input:ClearFocus()
	input:HighlightText(0, 0)
	input:Hide()
	local frame = input:GetParent()
	if input == frame.inputLeft then
		frame.textLeft:Show()
	elseif input == frame.inputRight then
		frame.textRight:Show()
	else
		error("Unexpected input")
	end
end

function private.InputOnEnterPressed(input)
	input:ClearFocus()
	input:HighlightText(0, 0)
	input:Hide()
	local frame = input:GetParent()
	local self = private.frameSliderLookup[frame]
	if input == frame.inputLeft then
		frame.textLeft:Show()
		self:_UpdateLeftValue(input:GetNumber())
	elseif input == frame.inputRight then
		frame.textRight:Show()
		self:_UpdateRightValue(input:GetNumber())
	else
		error("Unexpected input")
	end
end

function private.FrameOnMouseDown(frame)
	local self = private.frameSliderLookup[frame]
	if frame.textLeft:IsMouseOver() then
		frame.textLeft:Hide()
		frame.inputLeft:Show()
		frame.inputLeft:SetNumber(self._leftValue)
	elseif frame.textRight:IsMouseOver() then
		frame.textRight:Hide()
		frame.inputRight:Show()
		frame.inputRight:SetNumber(self._rightValue)
	else
		private.InputOnEscapePressed(frame.inputLeft)
		private.InputOnEscapePressed(frame.inputRight)
		local value = self:_GetCursorPositionValue()
		local leftDiff = abs(value - self._leftValue)
		local rightDiff = abs(value - self._rightValue)
		if value < self._leftValue then
			-- clicked to the left of the left thumb, so drag that
			self._dragging = "left"
		elseif value > self._rightValue then
			-- clicked to the right of the right thumb, so drag that
			self._dragging = "right"
		elseif self._leftValue == self._rightValue then
			-- just ignore this click since they clicked on both thumbs
		elseif leftDiff < rightDiff then
			-- clicked closer to the left thumb, so drag that
			self._dragging = "left"
		else
			-- clicked closer to the right thumb (or right in the middle), so drag that
			self._dragging = "right"
		end
	end
end

function private.FrameOnMouseUp(frame)
	local self = private.frameSliderLookup[frame]
	self._dragging = nil
end

function private.FrameOnUpdate(frame)
	local self = private.frameSliderLookup[frame]
	if not self._dragging then
		return
	end
	if self._dragging == "left" then
		self:_UpdateLeftValue(self:_GetCursorPositionValue())
	elseif self._dragging == "right" then
		self:_UpdateRightValue(self:_GetCursorPositionValue())
	else
		error("Unexpected dragging: "..tostring(self._dragging))
	end
end
