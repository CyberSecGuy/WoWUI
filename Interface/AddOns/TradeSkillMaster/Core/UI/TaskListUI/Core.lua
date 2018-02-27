-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local TaskListUI = TSM.UI:NewPackage("TaskListUI")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = { frame = nil, categoryCollapsed = {}, taskCollapsed = {} }
local DEFAULT_FRAME_CONTEXT = {
	topRightX = -250,
	topRightY = -30,
}
-- TODO: this should eventually go in the saved variables
private.frameContext = {}



-- ============================================================================
-- Module Functions
-- ============================================================================

function TaskListUI.Toggle()
	if private.frame then
		private.frame:Hide()
		assert(not private.frame)
	else
		private.frame = private.CreateMainFrame()
		private.frame:Show()
		private.frame:Draw()
	end
end



-- ============================================================================
-- Task List UI
-- ============================================================================

function private.CreateMainFrame()
	return TSMAPI_FOUR.UI.NewElement("OverlayApplicationFrame", "base")
		:SetParent(UIParent)
		:SetStyle("width", 307)
		:SetStyle("strata", "HIGH")
		:SetContextTable(private.frameContext, DEFAULT_FRAME_CONTEXT)
		:SetTitle(L["TSM TASK LIST"])
		:SetScript("OnHide", private.BaseFrameOnHide)
		:SetContentFrame(TSMAPI_FOUR.UI.NewElement("Frame", "content")
			:SetLayout("VERTICAL")
			:AddChild(TSMAPI_FOUR.UI.NewElement("Texture", "hline")
				:SetStyle("color", "#9d9d9d")
				:SetStyle("height", 2)
			)
			:AddChildrenWithFunction(private.CreateTaskListElements)
		)
end

function private.CreateTaskListElements(frame)
	-- get all the category counts
	local categoryCount = TSMAPI_FOUR.Util.AcquireTempTable()
	for _, categoryDesc in TSM.TaskList.Iterator() do
		categoryCount[categoryDesc] = (categoryCount[categoryDesc] or 0) + 1
	end

	local currentCategoryFrame, currentTaskFrame = nil, nil
	local lastCategory, lastCharacter, lastTask = nil, nil, nil
	for _, categoryDesc, character, taskDesc, subTaskDesc, buttonText, isActive in TSM.TaskList.Iterator() do
		-- draw a category row if this is the first task for a category
		local isNewCategory = categoryDesc ~= lastCategory
		if isNewCategory then
			private.CreateCategoryLine(frame, categoryDesc, categoryCount[categoryDesc])
			local categoryFrame = TSMAPI_FOUR.UI.NewElement("Frame", "categoryChildren_"..categoryDesc)
				:SetLayout("VERTICAL")
			frame:AddChild(categoryFrame)
			if private.categoryCollapsed[categoryDesc] then
				categoryFrame:Hide()
			else
				categoryFrame:Show()
			end
			currentCategoryFrame = categoryFrame
		end
		lastCategory = categoryDesc

		-- draw a character row if this is the first task for a character
		if isNewCategory or character ~= lastCharacter then
			private.CreateCharacterLine(currentCategoryFrame, character, isNewCategory)
		end
		lastCharacter = character

		-- draw a task header row if this is the first task for the subtasks
		local hasSubTask = subTaskDesc ~= ""
		if isNewCategory or taskDesc ~= lastTask then
			private.CreateTaskHeaderLine(currentCategoryFrame, taskDesc, buttonText, isActive, hasSubTask)
			if hasSubTask then
				local taskFrame = TSMAPI_FOUR.UI.NewElement("Frame", "taskChildren_"..taskDesc)
					:SetLayout("VERTICAL")
				currentCategoryFrame:AddChild(taskFrame)
				if private.taskCollapsed[taskDesc] then
					taskFrame:Hide()
				else
					taskFrame:Show()
				end
				currentTaskFrame = taskFrame
			else
				currentTaskFrame = nil
			end
		end
		lastTask = taskDesc

		if hasSubTask then
			-- draw a subtask row
			private.CreateSubTaskLine(currentTaskFrame, subTaskDesc)
		end
	end


	TSMAPI_FOUR.Util.ReleaseTempTable(categoryCount)
end

function private.CreateCategoryLine(frame, category, count)
	frame:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "category_"..category)
		:SetLayout("HORIZONTAL")
		:SetStyle("height", 28)
		:SetStyle("margin", { left = 4, right = 4, bottom = 2 })
		:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "expanderBtn")
			:SetStyle("width", 18)
			:SetStyle("height", 18)
			:SetStyle("backgroundTexturePack", private.categoryCollapsed[category] and "iconPack.18x18/Carot/Collapsed" or "iconPack.18x18/Carot/Expanded")
			:SetContext(category)
			:SetScript("OnClick", function(self)
				local baseFrame = self:GetParentElement():GetParentElement()
				local category = self:GetContext()
				private.categoryCollapsed[category] = not private.categoryCollapsed[category]
				if private.categoryCollapsed[category] then
					self:SetStyle("backgroundTexturePack", "iconPack.18x18/Carot/Collapsed")
					baseFrame:GetElement("categoryChildren_"..category):Hide()
				else
					self:SetStyle("backgroundTexturePack", "iconPack.18x18/Carot/Expanded")
					baseFrame:GetElement("categoryChildren_"..category):Show()
				end
				baseFrame:Draw()
			end)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "desc")
			:SetStyle("autoWidth", true)
			:SetStyle("margin", { left = 2, right = 4 })
			:SetStyle("font", TSM.UI.Fonts.MontserratBold)
			:SetStyle("fontHeight", 16)
			:SetStyle("textColor", "#79a2ff")
			:SetText(category)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "count")
			:SetStyle("font", TSM.UI.Fonts.MontserratMedium)
			:SetStyle("fontHeight", 14)
			:SetStyle("textColor", "#ffffff")
			:SetText(format("(%d)", count))
		)
	)
end

function private.CreateCharacterLine(frame, character, isFirst)
	local text = character == "" and L["On All Characters"] or format(L["On %s"], character)
	frame:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "text")
		:SetStyle("height", 16)
		:SetStyle("margin", { left = 18, right = 18, bottom = 2, top = isFirst and 0 or 6 })
		:SetStyle("font", TSM.UI.Fonts.MontserratItalic)
		:SetStyle("fontHeight", 12)
		:SetStyle("textColor", "#ffffff")
		:SetText(text)
	)
end

function private.CreateTaskHeaderLine(frame, task, buttonText, isActive, hasSubTask)
	frame:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "task_"..task)
		:SetLayout("HORIZONTAL")
		:SetStyle("height", 26)
		:SetStyle("padding", { left = 18, right = 8 })
		:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "expanderBtn")
			:SetStyle("width", 18)
			:SetStyle("height", 18)
			:SetStyle("backgroundTexturePack", private.taskCollapsed[task] and "iconPack.18x18/Carot/Collapsed" or "iconPack.18x18/Carot/Expanded")
			:SetContext(task)
			:SetScript("OnClick", function(self)
				local baseFrame = self:GetParentElement():GetParentElement()
				local task = self:GetContext()
				private.taskCollapsed[task] = not private.taskCollapsed[task]
				if private.taskCollapsed[task] then
					self:SetStyle("backgroundTexturePack", "iconPack.18x18/Carot/Collapsed")
					baseFrame:GetElement("taskChildren_"..task):Hide()
				else
					self:SetStyle("backgroundTexturePack", "iconPack.18x18/Carot/Expanded")
					baseFrame:GetElement("taskChildren_"..task):Show()
				end
				baseFrame:Draw()
			end)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "desc")
			:SetStyle("margin", { left = 2, right = 4 })
			:SetStyle("font", TSM.UI.Fonts.MontserratBold)
			:SetStyle("fontHeight", 16)
			:SetStyle("textColor", "#ffd839")
			:SetText(task)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("ActionButton", "actionBtn")
			:SetStyle("width", 68)
			:SetStyle("height", 15)
			:SetStyle("font", TSM.UI.Fonts.MontserratBold)
			:SetStyle("fontHeight", 12)
			:SetDisabled(not isActive)
			:SetText(buttonText)
		)
	)
	if not hasSubTask then
		frame:GetElement("task_"..task..".expanderBtn"):Hide()
	end
end

function private.CreateSubTaskLine(frame, subTask)
	frame:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "text")
		:SetStyle("height", 20)
		:SetStyle("margin", { left = 38, right = 8, bottom = 2 })
		:SetStyle("font", TSM.UI.Fonts.MontserratBold)
		:SetStyle("fontHeight", 14)
		:SetStyle("textColor", "#ffffff")
		:SetText(subTask)
	)
end



-- ============================================================================
-- Local Script Handlers
-- ============================================================================

function private.BaseFrameOnHide(frame)
	assert(frame == private.frame)
	frame:Release()
	private.frame = nil
end
