-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local Import = TSM.MainUI:NewPackage("ImportExport")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = {
	currentGroupPath = TSM.CONST.ROOT_GROUP_PATH,
	selectedGroupList = {},
	blacklistedItemsByGroup = {},
	groupedItemList = {},
	itemsByGroup = {},
	groupSearch = "",
	importExportMode = "Import",
	-- TODO: this should eventually go in the saved variables
	dividedContainerContext = {},
}

local DEFAULT_DIVIDED_CONTAINER_CONTEXT = {
	leftWidth = 300,
}

local SETTING_LINE_MARGIN = {
	bottom = 16
}



-- ============================================================================
-- Module Functions
-- ============================================================================

function Import.OnInitialize()
	TSM.MainUI.RegisterTopLevelPage("Import/Export", "iconPack.24x24/Import", private.GetOuterFrame)
end

local colors = {
	red = "#ffff0000",
	green = "#ff00ff00",
	blue = "#ff0000ff",
	black = "#ff000000",
	white = "#ffffffff",
}

local stylesheet = {
	LINE_COLOR = "#e2e2e2",
	BANANA_YELLOW = "#ffd839",
	--GROUP_LABEL_COLOR = "#79a2ff",
	GROUP_LABEL_COLOR = "#e2e2e2",
	HIGHLIGHT_TEXT_COLOR = "#ff000000",
	HIGHLIGHT_BACKGROUND_COLOR = colors.green,
	OPERATIONS_LABEL_COLOR = colors.red,
	--HIGHLIGHT_BACKGROUND_COLOR = "#ffb2b2b2",
}



-- ============================================================================
-- Builder Functions
-- ============================================================================
local builder = {}

function builder.CheckBox(name, label, optionTable, optionKey, width)
	local element = TSMAPI_FOUR.UI.NewElement("Checkbox", name)
		:SetText(label)
		:SetSettingInfo(optionTable, optionKey)
	if width then
		element:SetStyle("width", width)
	end
	return element
end

function builder.ExporterGroupLine(name, path, removeHandler)
	return TSMAPI_FOUR.UI.NewElement("Frame", name)
		:SetLayout("HORIZONTAL")
		:SetContext(path)
		:SetStyle("height", 40)
		:SetStyle("padding", 10)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "groupName")
			:SetText(TSMAPI_FOUR.Groups.BaseName(path))
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "removeGroupButton")
			:SetText("X")
			:SetScript("OnClick", removeHandler)
		)
end

function builder.SectionHeaderLine(name, text)
	return TSMAPI_FOUR.UI.NewElement("Text", name)
		:SetStyle("height", 19)
		:SetStyle("fontHeight", 16)
		:SetStyle("font", TSM.UI.Fonts.MontserratBold)
		:SetStyle("textColor", "#ffffffff")
		:SetStyle("margin", { bottom = 8 })
		:SetText(text)
end

function builder.ImporterModuleLine(name, module, removeHandler)
	return TSMAPI_FOUR.UI.NewElement("Frame", name)
		:SetLayout("HORIZONTAL")
		:SetStyle("height", 40)
		:SetStyle("padding", 10)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "groupName")
			:SetText(module)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Spacer", "spacer")
			:SetStyle("height", 40)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "removeGroupButton")
			:SetText("X")
			:SetScript("OnClick", removeHandler)
		)
end

function builder.ImporterOperationLine(name, label, removeHandler)
	return TSMAPI_FOUR.UI.NewElement("Frame", name)
		:SetLayout("HORIZONTAL")
		:SetContext(label)
		:SetStyle("height", 40)
		:SetStyle("padding", 10)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Spacer", "spacer")
			:SetStyle("width", 40)
			:SetStyle("height", 40)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "operationName")
			:SetText(label)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Spacer", "spacerTwo")
			:SetStyle("height", 40)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "removeButton")
			:SetText("X")
			:SetScript("OnClick", removeHandler)
		)
end

function builder.ExporterItemLine(name, itemLink, removeHandler)
	return TSMAPI_FOUR.UI.NewElement("Frame", name)
		:SetLayout("HORIZONTAL")
		:SetStyle("height", 30)
		:SetStyle("padding", 10)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "itemName")
			:SetText(TSMAPI_FOUR.Item.GetName(itemLink))
			:SetStyle("textColor", TSMAPI_FOUR.Item.GetQualityColor(itemLink))
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "removeItemButton")
			:SetText("X")
			:SetScript("OnClick", removeHandler)
		)
end

function builder.ColoredHeadingLine(id, text, color)
	return TSMAPI_FOUR.UI.NewElement("Frame", id)
		:SetLayout("HORIZONTAL")
		:SetStyle("height", 34)
		:SetStyle("margin", { top = 16, bottom = 16 })
		:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "text")
			:SetStyle("textColor", color)
			:SetStyle("fontHeight", 24)
			:SetStyle("margin", { right = 8 })
			:SetStyle("autoWidth", true)
			:SetText(text)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Texture", "vline")
			:SetStyle("color", stylesheet.LINE_COLOR)
			:SetStyle("height", 2)
		)
end

function builder.SpacerFrame(name)
	name = name or 'spacerFrame'
	return TSMAPI_FOUR.UI.NewElement("Spacer", name)
end

function builder.SelectionGroupTree(name)
	local tree = TSMAPI_FOUR.UI.NewElement("SelectionGroupTree", "groupTree")
		:SetStyle("background", "#131313")
		:SetScript("OnGroupSelectionChanged", private.ImportGroupSelectionChangedHandler)
		:SetGroupListFunc(private.GroupTreeGetList)
	return tree
end

function private.ImportGroupSelectionChangedHandler(element, selectedGroups, groupPath)
	private.importer.rootPath = selectedGroups

end

function builder.SelectedCountHeader(name, text, color, items)
	return TSMAPI_FOUR.UI.NewElement("Frame", "selectedGroupsLine")
		:SetLayout("HORIZONTAL")
		:SetStyle("height", 40)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "selectedGroupsLabel")
			:SetText(text)
			:SetStyle("width", 200)
			:SetStyle("height", 24)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "selectedGroupsCountDecoration")
			--:SetStyle("backgroundTexture", stylesheet.HIGHLIGHT_BACKGROUND_COLOR)
			:SetStyle("textColor", stylesheet.HIGHLIGHT_TEXT_COLOR)
			:SetStyle("width", 40)
			:SetStyle("height", 24)
			:SetStyle("justifyH", "CENTER")
			:SetStyle("fontHeight", 20)
			:SetText(TSMAPI_FOUR.Util.Count(items))
		)
-- FIXME texture / count rendering not right
--			:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "decoration")
--				:SetStyle("background", stylesheet.HIGHLIGHT_BACKGROUND_COLOR)
--				:SetStyle("width", 40)
--				:SetStyle("height", 24)
--				:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "selectedGroupsCount")
--					:SetStyle("textColor", stylesheet.HIGHLIGHT_TEXT_COLOR)
--					:SetStyle("fontHeight", 20)
--					:SetText(TSMAPI_FOUR.Util.Count(items))
--				)
--			)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "spacerFrame"))
end

function builder.DefaultHeadingLine(name, text)
	return builder.ColoredHeadingLine(name, text, stylesheet.LINE_COLOR)
end

-- FIXME ended up unused?
function builder.GroupsHeadingLine(name, text)
	return builder.ColoredHeadingLine(name, text, stylesheet.GROUP_LABEL_COLOR)
end

function builder.OperationsHeadingLine(name, text)
	return builder.ColoredHeadingLine(name, text, stylesheet.OPERATIONS_LABEL_COLOR)
end

function builder.ImportOptionToggle(name, labelText, optionTable)
	return TSMAPI_FOUR.UI.NewElement("Frame", name)
		:SetLayout("HORIZONTAL")
		:SetStyle("height", 26)
		:SetStyle("margin", SETTING_LINE_MARGIN)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "left")
			:SetLayout("HORIZONTAL")
			:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
				:SetStyle("fontHeight", 14)
				:SetStyle("textColor", "#e2e2e2")
				:SetText(labelText)
			)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", name.."Frame")
			:SetLayout("HORIZONTAL")
			-- move the right by the width of the toggle so this frame gets half the total width
			:SetStyle("margin", { right = -TSM.UI.TexturePacks.GetWidth("uiFrames.ToggleOn") })
			:AddChild(TSMAPI_FOUR.UI.NewElement("ToggleOnOff", "toggle")
				:SetSettingInfo(optionTable, name)
			)
			:AddChild(builder.SpacerFrame())
		)
end



-- ============================================================================
-- Import UI
-- ============================================================================

local function GetFakeExporter()
	local exporter = {
		options = {
			includeSubgroupStructure = true,
			includeAttachedOperations = true
		},
		GetExporterString = false
	}
	function exporter.GetExportString(self)
		return "i:2400;i:3500"
	end
	return exporter
end

function private.GetOuterFrame()
	return TSMAPI_FOUR.UI.NewElement("ViewContainer", "ImportExportOuterViewContainer")
		:SetNavCallback(private.GetImportExportOuterViewContainerCallback)
		:AddPath("import", true)
		:AddPath("importConfirmation")
		:AddPath("exportSelection")
		:AddPath("exportResult")
end

function private.GetImportExportOuterViewContainerCallback(self, path)
	if path == "import" then
		private.importer = TSMAPI_FOUR.Importer.New()
		return private.GetImportExportFrame()
	elseif path == "importConfirmation" then
		return private.GetImporterConfirmationFrame()
	else
		error("Unexpected path for ImportExportOuterViewContainer: " .. path)
	end
end

function private.GetImportExportFrame()
	private.currentGroupPath = TSM.CONST.ROOT_GROUP_PATH
	local frame = TSMAPI_FOUR.UI.NewElement("DividedContainer", "groups")
		:SetStyle("background", "#272727")
		:SetContextTable(private.dividedContainerContext, DEFAULT_DIVIDED_CONTAINER_CONTEXT)
		:SetMinWidth(250, 250)
		:SetLeftChild(TSMAPI_FOUR.UI.NewElement("Frame", "groupSelection")
			:SetLayout("VERTICAL")
			:AddChild(TSMAPI_FOUR.UI.NewElement("SearchInput", "search")
				:SetStyle("height", 20)
				:SetStyle("margin", { left = 12, right = 12, top = 35, bottom = 12 })
				:SetText(private.groupSearch)
				:SetHintText(L["Search Groups"])
				:SetScript("OnTextChanged", private.GroupSearchOnTextChanged)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Texture", "line")
				:SetStyle("height", 2)
				:SetStyle("color", "#9d9d9d")
			)
			:AddChild(builder.SelectionGroupTree("groupTree")
			)
		)
		:SetRightChild(TSMAPI_FOUR.UI.NewElement("Frame", "content")
			:SetLayout("VERTICAL")
			:SetStyle("padding", { top = 30 })
			:SetStyle("background", "#272727")
			:AddChild(TSMAPI_FOUR.UI.NewElement("TabGroup", "buttons")
				:SetStyle("margin", { top = 16 })
				:SetNavCallback(private.GetImportExportPage)
				:AddPath(L["Import"], true)
				:AddPath(L["Export"])
			)
		)
	return frame
end

function private.GetImportExportPage(self, button)
	if button == L["Import"] then
		private.importer = TSMAPI_FOUR.Importer.New()
		return private.GetImportEntryFrame()
	elseif button == L["Export"] then
		private.exporter = GetFakeExporter()
		return private.GetNotImplementedExportFrame()
	else
		error("Unknown path for GetModeFrame: " .. button)
	end
end

function private.GetNotImplementedExportFrame()
	return TSMAPI_FOUR.UI.NewElement("Text", "groupName")
		:SetText("Under Construction - please check back later")
end

function private.GroupTreeGetList(groups, headerNameLookup)
	if strmatch(strlower(L["Base Group"]), TSMAPI_FOUR.Util.StrEscape(private.groupSearch)) then
		tinsert(groups, TSM.CONST.ROOT_GROUP_PATH)
		headerNameLookup[TSM.CONST.ROOT_GROUP_PATH] = L["Base Group"]
	end

	local temp = TSMAPI_FOUR.Util.AcquireTempTable()
	TSM.Groups:GetSortedGroupPathList(temp)
	for _, path in ipairs(temp) do
		local _, groupName = TSMAPI_FOUR.Groups.SplitPath(path)
		if strmatch(strlower(groupName), TSMAPI_FOUR.Util.StrEscape(private.groupSearch)) then
			tinsert(groups, path)
		end
	end
	TSMAPI_FOUR.Util.ReleaseTempTable(temp)
end

function private.GetImportEntryFrame()
	return TSMAPI_FOUR.UI.NewElement("ScrollFrame", "importContent")
		:SetStyle("padding", 16)
		:SetStyle("background", "#ff1e1e1e")
		:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "instructions")
			:SetStyle("height", 54)
			:SetStyle("font", TSM.UI.Fonts.MontserratMedium)
			:SetStyle("fontHeight", 14)
			:SetStyle("fontSpacing", 2)
			:SetStyle("textColor", "#ffe2e2e2")
			:SetStyle("margin", { bottom = 44})
			:SetText(L["Paste your import string in the field below and then press 'IMPORT'. You can import everything from item lists (comma delineated please) to whole group & operation structures."])
		)
		:AddChild(builder.SectionHeaderLine("label", L["Import Groups & Operations"]))
		:AddChild(TSMAPI_FOUR.UI.NewElement("Input", "userInput")
			:SetStyle("height", 100)
			:SetStyle("fontHeight", 12)
			:SetStyle("background", "#ff585858")
			:SetStyle("hintTextColor", "#ffe2e2e2")
			:SetStyle("hintJustifyH", "LEFT")
			:SetStyle("margin", { bottom = 16})
			:SetHintText(" " .. L["Paste string here"])
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "layout")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 26)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Spacer", "spacer")
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("ActionButton", "IMPORT")
				:SetStyle("width", 160)
				:SetStyle("height", 26)
				:SetStyle("font", TSM.UI.Fonts.MontserratMedium)
				:SetStyle("fontHeight", 14)
				:SetText(L["IMPORT"])
				:SetScript("OnClick", private.ImportOnClick)
			)
		)
		:AddChild(builder.SectionHeaderLine("generalOptionsTitle", L["Advanced Options"])
			:SetStyle("margin", { top = 64, bottom = 8})
		)
		:AddChild(builder.ImportOptionToggle("moveAlreadyGroupedItems", L["Move already grouped items?"], private.importer.options))
		:AddChild(builder.ImportOptionToggle("includeOperations", L["Include operations?"], private.importer.options))
		--:AddChild(builder.ImportOptionToggle("includeCustomPrices", L["Include custom prices?"], private.importer.options))
		:AddChild(builder.ImportOptionToggle("ignoreDuplicateOperations", L["Ignore duplicate operations?"], private.importer.options))
		:AddChild(builder.ImportOptionToggle("skipImportExportConfirmations", L["Skip Import / Export confirmations?"], private.importer.options))
end



-- ============================================================================
-- Older Import UI
-- ============================================================================
local oldprivate = {}

function oldprivate.GetExportFrame()
	return TSMAPI_FOUR.UI.NewElement("Frame", "ExportFrame")
		:SetLayout("HORIZONTAL")
		:SetStyle("background", "#363636")
		:SetStyle("borderTexture", "Interface\\Addons\\TradeSkillMaster\\Media\\InnerEdgeFrame.tga")
		:SetStyle("borderSize", 10)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "groupSelection")
			:SetStyle("background", "#1ae2e2e2")
			:SetStyle("width", 400)
			:SetStyle("padding", { top = 10 })
			:SetLayout("VERTICAL")
			:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "title")
				:SetStyle("height", 40)
				:SetStyle("fontHeight", 20)
				:SetStyle("justifyH", "CENTER")
				:SetText("Group Tree")
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Texture", "line")
				:SetStyle("height", 2)
				:SetStyle("color", "#ff252525")
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("ApplicationGroupTree", "groupTree")
				:SetGroupListFunc(private.GroupTreeGetList)
				:SetScript("OnGroupSelectionChanged", private.ExportGroupsSelectionChanged)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Texture", "line")
				:SetStyle("height", 2)
				:SetStyle("color", "#ff252525")
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "buttons")
				:SetStyle("height", 50)
				:SetLayout("HORIZONTAL")
				:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "spacerLeft")
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "expand")
					:SetStyle("margin", 10)
					:SetStyle("width", 150)
					:SetStyle("borderTexture", "Interface\\Addons\\TradeSkillMaster\\Media\\ButtonEdgeFrame.blp")
					:SetStyle("borderSize", 7)
					:SetText(L["Expand All"])
					:SetScript("OnClick", private.ExpandAllOnClick)
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "collapse")
					:SetStyle("margin", 10)
					:SetStyle("width", 150)
					:SetStyle("borderTexture", "Interface\\Addons\\TradeSkillMaster\\Media\\ButtonEdgeFrame.blp")
					:SetStyle("borderSize", 7)
					:SetText(L["Collapse All"])
					:SetScript("OnClick", private.CollapseAllOnClick)
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "spacerRight")
				)
			)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "divider")
			:SetStyle("background", "#ff2a2a2a")
			:SetStyle("border", "#ff000000")
			:SetStyle("borderSize", 1)
			:SetStyle("width", 20)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "content")
			:SetStyle("padding", { top = 10 })
			:SetLayout("VERTICAL")
			:AddChild(TSMAPI_FOUR.UI.NewElement("ViewContainer", "groupExportFrame")
				:SetNavCallback(private.GetExporterGroupsFrame)
				:AddPath("selected_groups", true)
				:AddPath("export_output")
			)
		)
end

function oldprivate.GetExporterGroupsFrame(self, path)
	if path == "selected_groups" then
		return private.GetExporterGroupsFrameSelectedGroups()
	elseif path == "export_output" then
		return private.GetExporterGroupsFrameExportOutput()
	else
		error("Unexpected path for ExporterGroupsFrame: " .. path)
	end
end

function oldprivate.GetExporterGroupsFrameSelectedGroups()
	return TSMAPI_FOUR.UI.NewElement("Frame", "exportFeedback")
		:SetLayout("VERTICAL")
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "buttonLayout")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 60)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "CancelButton")
					:SetText(L["Reset"])
					:SetScript("OnClick", private.ExporterResetSelectedGroupsOnClick)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "ExportLabel")
				:SetStyle("height", 30)
				:SetStyle("fontHeight", 24)
				:SetStyle("justifyH", "CENTER")
				:SetText(L["Export List"])
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "ConfirmButton")
				:SetText(L["Next"])
				:SetScript("OnClick", private.ExporterExportSelectedGroupsOnClick)
			)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "CheckBoxesLine")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 40)
			:SetStyle("padding", 10)
			:AddChild(builder.CheckBox("includeSubgroupStructureCheckbox", L["Include Subgroup Structure"], private.exporter.options, "includeSubgroupStructure"))
			:AddChild(builder.CheckBox("includeAttachedOperationsCheckbox", L["Include Attached Operations"], private.exporter.options, "includeAttachedOperations"))
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("ScrollFrame", "ScrollFrame")
			:AddChild(TSMAPI_FOUR.UI.NewElement("ViewContainer", "exportViewContainer")
				:SetNavCallback(private.GetExportViewContainer)
				:AddPath("blank", true)
				:AddPath("show_selection")
				:AddPath("show_export_string")
			)
		)
end

function oldprivate.GetExportViewContainer(element, path)
	if path == "blank" then
		return TSMAPI_FOUR.UI.NewElement("Text", "title")
			:SetStyle("height", 40)
			:SetStyle("fontHeight", 20)
			:SetStyle("justifyH", "CENTER")
			:SetText(L["Please select a group to export"])
	elseif path == "show_selection" then
		local items = TSMAPI_FOUR.UI.NewElement("Frame", "ExportStuff")
			:SetLayout("VERTICAL")

		items:AddChild(builder.SelectedCountHeader("selectedGroupsLine", L["Selected Groups"], colors.green, private.selectedGroups))

		for i, path in pairs(private.selectedGroups) do
			items:AddChild(builder.ExporterGroupLine("group_" .. i, path, private.GroupExporterRemoveGroupHandler))
		end

		if private.exporter.options.includeAttachedOperations then
			items:AddChild(builder.SelectedCountHeader("selectedOperationsHeaderLine", L["Selected Operations"], colors.green, private.selectedGroups))
			for i, path in pairs(private.selectedGroups) do
				-- FIXME group_i and group_i_item_j strings are polluting string space
				items:AddChild(builder.ExporterGroupLine("group_" .. i, path, private.GroupExporterRemoveGroupHandler))
			end
		end
		return items
	elseif path == "show_export_string" then
		return TSMAPI_FOUR.UI.NEwElement("Text", "exportString")
			:SetText(private.exporter:GetExportString())
	else
		error("Unknown path "..path.." for exportViewContainer")
	end
end

function oldprivate.GroupExporterRemoveGroupHandler(element)
	local textLabel = element:GetElement("__parent.groupName")
	print(textLabel)
	print("eyaaaarp")
	print(textLabel:GetContext())

	local exportFrame = element:GetElement("__parent.__parent.__parent.__parent.__parent.__parent.__parent.__parent") -- are we there yet
	local groupTree = exportFrame:GetElement("groupSelection.groupTree")

	print(groupTree)
	print("Content here")

	-- FIXME this is where it all goes to pieces
	-- Trying to call Click() on the groupTree frame that has the same group path

	-- FIXME at this point groupTree is the right frame object, just need to find
	-- the right child and call :Click()
	-- but GetChildren is a nil value

	-- FIXME broken is fine for this second, rather have import / export working
	for i, element in ipairs(groupTree:GetChildren()) do
		print("I saw a thing so I did")
		print(element)
	end
	print("that cookie done crumbled")
end

function oldprivate.GroupExporterRemoveItemHandler(element)
	print("I'm here to remove your Items")
	print(element)
	print("Element is " .. element.name)
end

function oldprivate.ExportGroupsSelectionChanged(element, selectedGroups)
	private.selectedGroups = {}
	for path, isSelected in pairs(selectedGroups) do
		if isSelected then
			tinsert(private.selectedGroups, path)
		end
	end
	TSMAPI_FOUR.Groups.SortGroupList(private.selectedGroups)

	--local path = TSMAPI_FOUR.Debug.SearchUIUp(element, "content.groupExportFrame.exportFeedback.ScrollFrame")
	local path = "__parent.__parent.content.groupExportFrame.exportFeedback.ScrollFrame"
	local scrollFrame = element:GetElement(path)

	local exportViewContainer = scrollFrame:GetElement("exportViewContainer")
	exportViewContainer:SetPath("blank", false)
	exportViewContainer:SetPath("show_selection", true)
	--exportViewContainer:ReloadContent() -- Doesn't work? WTF
	scrollFrame:Draw()
end

function oldprivate.GetExporterGroupsFrameExportOutput()
	return TSMAPI_FOUR.UI.NewElement("Input", "exportOutput")
		:SetText(private.exporter:GetExportString())
		:SetStyle("borderSize", 3)
		:SetStyle("border", "#e2e2e2")
		:SetStyle("height", 120)
		:SetStyle("fontHeight", 24)
		:SetStyle("background", "#ffb2b2b2")
		:SetStyle("margin", { left = 10, right = 10, top = 3, bottom = 3 })
		:SetStyle("hintTextColor", "#ff000000")
		:SetStyle("hintJustifyH", "LEFT")
end

function private.CountOperations(operations)
	local total = 0
	for label, module in pairs(operations) do
		total = total + TSMAPI_FOUR.Util.Count(module)
	end
	return total
end

function private.ConfirmImportOnClick(element)
	private.importer:Finalize()
	TSM:Print("Finished importing "..private.importer.rootPath)
end

function private.GetImporterConfirmationFrame()
	local importerItemsCount = TSMAPI_FOUR.Util.Count(private.importer.items)
	local importerOperationsCount = private.CountOperations(private.importer.operations)
	local frame = TSMAPI_FOUR.UI.NewElement("Frame", "ImportConfirmation")
		:SetLayout("VERTICAL")
		:SetStyle("background", "#272727")
		:AddChild(TSMAPI_FOUR.UI.NewElement("Spacer", "spacer")
			:SetStyle("height", 25)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "ButtonLine")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 50)
			:SetStyle("textColor", "#ffe2e2e2")
			:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "CancelButton")
				:SetText(L["Cancel"])
				:SetStyle("font", TSM.UI.Fonts.MontserratBold)
				:SetStyle("fontHeight", 16)
				:SetStyle("fontSpacing", 2)
				:SetScript("OnClick", private.CancelConfirmOnClick)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Spacer", "spacer"))
			:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "ImportPrompt")
				:SetText(table.concat({ L["Import"], importerItemsCount, L["Items and"], importerOperationsCount, L["Operations?"] }, " "))
				:SetStyle("autoWidth", true)
				:SetStyle("fontHeight", 18)
				:SetStyle("font", TSM.UI.Fonts.MontserratBold)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Spacer", "spacer"))
			:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "ConfirmButton")
				:SetText(L["Confirm"])
				:SetStyle("font", TSM.UI.Fonts.MontserratBold)
				:SetStyle("fontHeight", 16)
				:SetStyle("fontSpacing", 2)
				:SetStyle("textColor", stylesheet.BANANA_YELLOW)
				:SetScript("OnClick", private.ConfirmImportOnClick)
			)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "divider")
			:SetStyle("background", "#9d9d9d")
			:SetStyle("height", 1)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("ImportConfirmationList")
			:SetImporter(private.importer, true)
		)
	return frame
end

function private.CancelConfirmOnClick(element)

	local importViewContainer = element:GetElement("__parent.__parent.__parent")
	importViewContainer:SetPath("import", true)
end

function oldprivate.ExporterExportSelectedGroupsOnClick(element)
	local path = "__parent.__parent.__parent.__parent.__parent.content.groupExportFrame"
	local exportViewContainer = element:GetElement(path)
	exportViewContainer:SetPath("export_output", true)
	-- FIXME remove these prints
	print("Exportering your selected groups")
	if private.exporter.options.includeSubgroupStructure then
		print("and subgroup structure")
	end
	if private.exporter.options.includeAttachedOperations then
		print("and operations")
	end
end

function oldprivate.GroupTreeGetList(groups, headerNameLookup)
	TSM.Groups:GetSortedGroupPathList(groups)
	tinsert(groups, 1, TSM.CONST.ROOT_GROUP_PATH)
	headerNameLookup[TSM.CONST.ROOT_GROUP_PATH] = "Root"
end

function private.ImportOnClick(element)
	local userInput = element:GetElement("__parent.__parent.userInput")
	local input = userInput:GetText()
	private.importer:CreateGroupIfNoneSelected()
	private.importer:ParseUserInput(input)

	if private.importer.options.skipImportExportConfirmations then
		private.importer:Finalize()
	end

	local path = "__parent.__parent.__parent.__parent.__parent.__parent.__parent.ImportExportOuterViewContainer"

	local importViewContainer = element:GetElement(path)
	importViewContainer:SetPath("importConfirmation", true)
end
