-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- This file contains support code for the custom TSM widgets
local _, TSM = ...
local private = {coloredFrames={}, coloredTexts={}}



-- ============================================================================
-- TSMAPI Functions
-- ============================================================================

function TSMAPI.Design:SetFrameBackdropColor(obj)
	return private:SetFrameColor(obj, "frameBG")
end

function TSMAPI.Design:SetFrameColor(obj)
	return private:SetFrameColor(obj, "frame")
end

function TSMAPI.Design:SetContentColor(obj)
	return private:SetFrameColor(obj, "content")
end

function TSMAPI.Design:SetIconRegionColor(obj)
	return private:SetTextColor(obj, "iconRegion")
end

function TSMAPI.Design:SetWidgetTextColor(obj, isDisabled)
	return private:SetTextColor(obj, "text", isDisabled)
end

function TSMAPI.Design:SetWidgetLabelColor(obj, isDisabled)
	return private:SetTextColor(obj, "label", isDisabled)
end

function TSMAPI.Design:SetTitleTextColor(obj)
	return private:SetTextColor(obj, "title")
end

function TSMAPI.Design:GetContentFont(size)
	size = size or "normal"
	assert(TSM.designDefaults.fontSizes[size], format("Invalid font size '%s", tostring(size)))
	return TSM.designDefaults.fonts.content, TSM.designDefaults.fontSizes[size]
end

function TSMAPI.Design:GetBoldFont()
	return TSM.designDefaults.fonts.bold
end

function TSMAPI.Design:GetInlineColor(key)
	local r, g, b, a = unpack(TSM.designDefaults.inlineColors[key])
	return format("|c%02X%02X%02X%02X", a, r, g, b)
end

function TSMAPI.Design:ColorText(text, key)
	local color = TSMAPI.Design:GetInlineColor(key)
	return color..text.."|r"
end



-- ============================================================================
-- Helper Functions
-- ============================================================================

function private:ExpandColor(tbl)
	tbl = CopyTable(tbl)
	for i=1, 3 do
		tbl[i] = tbl[i] / 255
	end
	return unpack(tbl)
end

function private:SetFrameColor(obj, colorKey)
	local color = TSM.designDefaults.frameColors[colorKey]
	if not obj then return private:ExpandColor(color.backdrop) end
	private.coloredFrames[obj] = {obj, colorKey}
	if obj:IsObjectType("Frame") then
		obj:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Buttons\\WHITE8X8", edgeSize=TSM.designDefaults.edgeSize})
		obj:SetBackdropColor(private:ExpandColor(color.backdrop))
		obj:SetBackdropBorderColor(private:ExpandColor(color.border))
	else
		obj:SetColorTexture(private:ExpandColor(color.backdrop))
	end
end

function private:SetTextColor(obj, colorKey, isDisabled)
	local color = TSM.designDefaults.textColors[colorKey]
	if not obj then return private:ExpandColor(color.enabled) end
	private.coloredTexts[obj] = {obj, colorKey, isDisabled}
	if obj:IsObjectType("Texture") then
		obj:SetColorTexture(private:ExpandColor(color.enabled))
	else
		if isDisabled then
			obj:SetTextColor(private:ExpandColor(color.disabled))
		else
			obj:SetTextColor(private:ExpandColor(color.enabled))
		end
	end
end
