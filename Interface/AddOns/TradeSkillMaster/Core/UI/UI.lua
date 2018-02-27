-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

--- UI Functions
-- @module UI

local _, TSM = ...
TSMAPI_FOUR.UI = {}
local UI = TSM:NewPackage("UI")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = { namedElements = {}, recycledElements = {}, elementIdMap = {}, propagateScripts = {} }
local TIME_LEFT_STRINGS = {
	"|cfff72d1f30m|r",
	"|cfff72d1f2h|r",
	"|cffe1f71f12h|r",
	"|cff4ff71f48h|r",
}
local GROUP_LEVEL_COLORS = {
	"#ffb85c",
	"#fcf141",
	"#bdaec6",
	"#06a2cb",
}



-- ============================================================================
-- TSMAPI Functions
-- ============================================================================

--- Creates a new UI element.
-- @tparam ?string|Class elementType Either the name of the element class or the class itself
-- @tparam string id The id to assign to the element
-- @tparam[opt] string name The global name of the element (should be used only for very specific macro-able buttons)
-- @return The created UI element object
function TSMAPI_FOUR.UI.NewElement(elementType, id, name)
	local class = nil
	if type(elementType) == "string" then
		class = TSM.UI[elementType]
	elseif type(elementType) == "table" then
		class = elementType
	end
	assert(class and class:__isa(UI.Element))
	local element = nil
	if name then
		private.namedElements[name] = private.namedElements[name] or class(name)
		element = private.namedElements[name]
		assert(_G[name] == element:_GetBaseFrame())
	elseif private.recycledElements[class] and #private.recycledElements[class] > 0 then
		element = tremove(private.recycledElements[class])
	else
		element = class()
	end
	element:SetId(id)
	element:Acquire()
	private.elementIdMap[element:_GetBaseFrame()] = element._id
	return element
end



-- ============================================================================
-- Module Functions
-- ============================================================================

--- Converts a hex value to RGBA components.
-- The values returned are floats between 0 and 1 inclusive. The alpha channel is option and set to 1 if not specified.
-- @tparam string hex The hex color string
-- @treturn number The red value
-- @treturn number The green value
-- @treturn number The blue value
-- @treturn number The alpha value
function TSM.UI.HexToRGBA(hex)
	local a, r, g, b = strmatch(strlower(hex), "^#([0-9a-f]?[0-9a-f]?)([0-9a-f][0-9a-f])([0-9a-f][0-9a-f])([0-9a-f][0-9a-f])$")
	assert(a and r and g and b, format("Invalid color (%s)!", hex))
	return tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255, (a ~= "") and (tonumber(a, 16) / 255) or 1
end

--- Colors an item name based on its quality.
-- @tparam string item The item to retrieve the name and quality of
-- @tparam[opt=1] number colorMultiplier A multiplier to apply to the color (must be <= 1)
-- @treturn string The colored name
function TSM.UI.GetColoredItemName(item, colorMultiplier)
	local name = TSMAPI_FOUR.Item.GetName(item)
	local quality = TSMAPI_FOUR.Item.GetQuality(item)
	return TSM.UI.GetQualityColoredText(name, quality, colorMultiplier)
end

--- Colors an item name based on its quality.
-- @tparam string name The name of the item
-- @tparam number quality The quality of the item
-- @tparam[opt=1] number colorMultiplier A multiplier to apply to the color (must be <= 1)
-- @treturn string The colored name
function TSM.UI.GetQualityColoredText(name, quality, colorMultiplier)
	if not name or not quality then
		return
	end
	local r, g, b = nil, nil, nil
	if ITEM_QUALITY_COLORS[quality] then
		r, g, b = ITEM_QUALITY_COLORS[quality].r, ITEM_QUALITY_COLORS[quality].g, ITEM_QUALITY_COLORS[quality].b
	else
		r, g, b = 1, 0, 0
	end
	colorMultiplier = colorMultiplier or 1
	r = floor(r * colorMultiplier * 255)
	g = floor(g * colorMultiplier * 255)
	b = floor(b * colorMultiplier * 255)
	return format("|cff%02x%02x%02x", r, g, b)..name.."|r"
end

--- Gets the UI color of the specified group level.
-- @tparam number level The group level
-- @treturn string The color as a hex value (`#xxxxxx`)
function TSM.UI.GetGroupLevelColor(level)
	level = level % #GROUP_LEVEL_COLORS
	return GROUP_LEVEL_COLORS[level + 1]
end

--- Gets the string representation of an auction time left.
-- @tparam number timeLeft The time left index (i.e. from WoW APIs)
-- @treturn string The localized string representation
function TSM.UI.GetTimeLeftString(timeLeft)
	local str = TIME_LEFT_STRINGS[timeLeft]
	assert(str, "Invalid timeLeft: "..tostring(timeLeft))
	return str
end

function UI.RecyleElement(element)
	local isNamed = false
	for _, namedElement in pairs(private.namedElements) do
		if element == namedElement then
			isNamed = true
			break
		end
	end
	if not isNamed then
		private.recycledElements[element.__class] = private.recycledElements[element.__class] or {}
		tinsert(private.recycledElements[element.__class], element)
	end
end

--- Creates a scrollbar.
-- @tparam Frame frame The parent frame
-- @tparam number scrollbarWidth The width of the scrollbar
-- @return The newly-created scrollbar
function TSM.UI.CreateScrollbar(frame, scrollbarWidth)
	assert(frame and scrollbarWidth)
	local scrollbar = CreateFrame("Slider", nil, frame, nil)
	scrollbar:ClearAllPoints()
	scrollbar:SetPoint("TOPRIGHT", 0, -4)
	scrollbar:SetPoint("BOTTOMRIGHT", 0, 4)
	scrollbar:SetWidth(scrollbarWidth)
	scrollbar:SetValueStep(1)
	scrollbar:SetObeyStepOnDrag(true)

	scrollbar:SetThumbTexture(scrollbar:CreateTexture())
	scrollbar.thumb = scrollbar:GetThumbTexture()
	scrollbar.thumb:SetPoint("CENTER")

	return scrollbar
end

--- Gets a script handler function which simply propogates the script to the parent element.
-- @tparam string script The script which the function should handle
-- @treturn function The propogate function
function TSM.UI.GetPropagateScriptFunc(script)
	if not private.propagateScripts[script] then
		private.propagateScripts[script] = function(self, ...)
			self:PropagateScript(script, ...)
		end
	end
	return private.propagateScripts[script]
end

function UI.ToggleFrameStack()
	if not TSMFrameStackTooltip then
		local STRATA_ORDER = {"TOOLTIP", "FULLSCREEN_DIALOG", "FULLSCREEN", "DIALOG", "HIGH", "MEDIUM", "LOW", "BACKGROUND", "WORLD"}
		local framesByStrata = {
			WORLD = {},
			BACKGROUND = {},
			LOW = {},
			MEDIUM = {},
			HIGH = {},
			DIALOG = {},
			FULLSCREEN = {},
			FULLSCREEN_DIALOG = {},
			TOOLTIP = {},
		}

		local function FrameLevelSortFunction(a, b)
			return a:GetFrameLevel() > b:GetFrameLevel()
		end

		local function GetFrameName(frame)
			local name = frame:GetName() or private.elementIdMap[frame]
			if not name then
				local parent = frame:GetParent()
				if parent then
					for i, v in pairs(parent) do
						if v == frame then
							name = tostring(i)
						end
					end
				end
			end
			return name or gsub(tostring(frame), ": ?0*", ":")
		end

		CreateFrame("GameTooltip", "TSMFrameStackTooltip", UIParent, "GameTooltipTemplate")
		TSMFrameStackTooltip.highlightFrame = CreateFrame("Frame")
		TSMFrameStackTooltip.highlightFrame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
		TSMFrameStackTooltip.highlightFrame:SetBackdropColor(1, 0, 0, 0.3)
		TSMFrameStackTooltip:Hide()
		TSMFrameStackTooltip.lastUpdate = 0
		TSMFrameStackTooltip:SetScript("OnUpdate", function(self)
			if self.lastUpdate + 0.05 >= GetTime() then return end
			self.lastUpdate = GetTime()

			for _, strata in ipairs(STRATA_ORDER) do
				wipe(framesByStrata[strata])
			end

			local frame = EnumerateFrames()
			while frame do
				if frame ~= self.highlightFrame and not frame:IsForbidden() and frame:IsVisible() and MouseIsOver(frame) then
					local strata = frame:GetFrameStrata()
					tinsert(framesByStrata[frame:GetFrameStrata()], frame)
				end
				frame = EnumerateFrames(frame)
			end

			self:ClearLines()
			self:AddDoubleLine("TSM Frame Stack", format("%0.2f, %0.2f", GetCursorPosition()))
			local topFrame = nil
			for _, strata in ipairs(STRATA_ORDER) do
				if #framesByStrata[strata] > 0 then
					sort(framesByStrata[strata], FrameLevelSortFunction)
					self:AddLine(strata, 0.6, 0.6, 1)
					for _, frame in ipairs(framesByStrata[strata]) do
						local level = frame:GetFrameLevel()
						local width = frame:GetWidth()
						local height = frame:GetHeight()
						local mouseEnabled = frame:IsMouseEnabled()
						local name = ""
						local childFrame = frame
						while childFrame and (childFrame ~= UIParent or name == "") do
							name = GetFrameName(childFrame)..(#name > 0 and "." or "")..name
							childFrame = childFrame:GetParent()
						end
						local text = format("  <%d> %s (%d, %d)", level, name, TSMAPI_FOUR.Util.Round(width), TSMAPI_FOUR.Util.Round(height))
						if mouseEnabled then
							self:AddLine(text, 0.6, 1, 1)
						else
							self:AddLine(text, 0.8, 0.8, 0.8)
						end
						if not topFrame and GetFrameName(frame) ~= "innerBorderFrame" then
							topFrame = frame
						end
					end
				end
			end
			self.highlightFrame:ClearAllPoints()
			self.highlightFrame:SetAllPoints(topFrame)
			self.highlightFrame:SetFrameStrata("TOOLTIP")
			self:Show()
		end)
	end
	if TSMFrameStackTooltip:IsVisible() then
		TSMFrameStackTooltip:Hide()
		TSMFrameStackTooltip.highlightFrame:Hide()
	else
		TSMFrameStackTooltip:SetOwner(UIParent, "ANCHOR_NONE")
		TSMFrameStackTooltip:SetPoint("TOPLEFT", 0, 0)
		TSMFrameStackTooltip:AddLine("Loading...")
		TSMFrameStackTooltip:Show()
		TSMFrameStackTooltip.highlightFrame:Show()
	end
end

--- A helper function for getting groups to be shown in an @{ApplicationGroupTree}.
-- Any groups which have an operation for the specified module will be included.
-- @tparam table groups The table to populate with the groups
-- @tparam table headerNameLookup The lookup table to populate with the group header (currently just "Base Group")
-- @tparam string moduleName The name of the module to filter groups by
function TSM.UI.ApplicationGroupTreeGetGroupList(groups, headerNameLookup, moduleName)
	TSM.Groups:GetSortedGroupPathList(groups)

	-- need to filter out the groups without operations
	local keep = TSMAPI_FOUR.Util.AcquireTempTable()
	for i = #groups, 1, -1 do
		local groupPath = groups[i]
		local _, groupName = TSMAPI_FOUR.Groups.SplitPath(groupPath)
		if TSMAPI_FOUR.Groups.HasOperationsByModule(groupPath, moduleName) then
			-- add all parent groups to the keep table so we don't remove those
			local checkPath = TSMAPI_FOUR.Groups.SplitPath(groupPath)
			while checkPath and checkPath ~= TSM.CONST.ROOT_GROUP_PATH do
				keep[checkPath] = true
				checkPath = TSMAPI_FOUR.Groups.SplitPath(checkPath)
			end
		elseif not keep[groupPath] then
			tremove(groups, i)
		end
	end
	TSMAPI_FOUR.Util.ReleaseTempTable(keep)

	tinsert(groups, 1, TSM.CONST.ROOT_GROUP_PATH)
	headerNameLookup[TSM.CONST.ROOT_GROUP_PATH] = L["Base Group"]
end

--- Shows a tooltip which is anchored to the frame.
-- @tparam Frame parent The parent and anchor frame for the tooltip
-- @param tooltip The tooltip information which can be either an itemId, itemString, raw text string, or function which
-- returns one of the other options
function TSM.UI.ShowTooltip(parent, tooltip)
	if not tooltip then
		return
	elseif type(tooltip) == "function" then
		tooltip = tooltip()
	else
		tooltip = tooltip
	end
	GameTooltip:SetOwner(parent, "ANCHOR_NONE")
	GameTooltip:SetPoint("LEFT", parent, "RIGHT")
	if type(tooltip) == "number" then
		GameTooltip:SetHyperlink("item:"..tooltip)
	elseif tonumber(tooltip) then
		GameTooltip:SetHyperlink("enchant:"..tooltip)
	elseif type(tooltip) == "string" and (strfind(tooltip, "\124Hitem:") or strfind(tooltip, "\124Hbattlepet:") or strfind(tooltip, "^i:") or strfind(tooltip, "^p:")) then
		TSMAPI_FOUR.Util.SafeTooltipLink(tooltip)
	else
		for _, line in TSMAPI_FOUR.Util.VarargIterator(strsplit("\n", tooltip)) do
			local textLeft, textRight = strsplit(TSM.CONST.TOOLTIP_SEP, line)
			if textRight then
				GameTooltip:AddDoubleLine(textLeft, textRight, 1, 1, 1, 1, 1, 1)
			else
				GameTooltip:AddLine(textLeft, 1, 1, 1)
			end
		end
	end
	GameTooltip:Show()
end

--- Hides the current tooltip.
function TSM.UI.HideTooltip()
	GameTooltip:Hide()
	BattlePetTooltip:Hide()
end
