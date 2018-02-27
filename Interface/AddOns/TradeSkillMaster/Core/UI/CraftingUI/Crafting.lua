-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local Crafting = TSM.UI.CraftingUI:NewPackage("Crafting")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = {
	db = nil,
	fsm = nil,
	professionsOrder = {},
	professions = {},
	page = "profession",
	groupSearch = "",
	showDelayFrame = 0,
	professionQuery = nil,
}
local SHOW_DELAY_FRAMES = 2
local KEY_SEP = "\001"
local DEFAULT_DIVIDED_CONTAINER_CONTEXT = {
	leftWidth = 496,
}
local MINING_SPELLID = 2575
local SMELTING_SPELLID = 2656
local MAX_NUM_INPUT_VALUE = 999
-- TODO: this should eventually go in the saved variables
private.dividedContainerContext = {}



-- ============================================================================
-- Module Functions
-- ============================================================================

function Crafting.OnInitialize()
	TSM.UI.CraftingUI.RegisterTopLevelPage("Crafting", "iconPack.24x24/Crafting", private.GetCraftingFrame)
	private.FSMCreate()
end

function Crafting.GatherCraftNext(spellId, quantity)
	private.fsm:ProcessEvent("EV_CRAFT_NEXT_BUTTON_CLICKED", spellId, quantity)
end

-- ============================================================================
-- Crafting UI
-- ============================================================================

function private.GetCraftingFrame()
	return TSMAPI_FOUR.UI.NewElement("DividedContainer", "crafting")
		:SetContextTable(private.dividedContainerContext, DEFAULT_DIVIDED_CONTAINER_CONTEXT)
		:SetMinWidth(450, 250)
		:SetLeftChild(TSMAPI_FOUR.UI.NewElement("Frame", "left")
			:SetLayout("VERTICAL")
			:SetStyle("background", "#272727")
			:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "header")
				:SetLayout("HORIZONTAL")
				:SetStyle("height", 20)
				:SetStyle("margin", 8)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Toggle", "pageToggle")
					:SetStyle("width", 124)
					:SetStyle("height", 20)
					:SetStyle("font", TSM.UI.Fonts.MontserratMedium)
					:SetStyle("fontHeight", 12)
					:SetStyle("textColor", "#e2e2e2")
					:SetStyle("border", "#e2e2e2")
					:SetStyle("selectedBackground", "#e2e2e2")
					:SetStyle("selectedTextColor", "#2e2e2e")
					:AddOption(L["Crafts"], true)
					:AddOption(L["Groups"])
					:SetScript("OnValueChanged", private.PageToggleOnValueChanged)
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Spacer", "spacer"))
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("ViewContainer", "content")
				:SetNavCallback(private.GetCraftingElements)
				:AddPath("profession", private.page == "profession")
				:AddPath("group", private.page == "group")
			)
		)
		:SetRightChild(TSMAPI_FOUR.UI.NewElement("Frame", "right")
			:SetLayout("VERTICAL")
			:SetStyle("background", "#000000")
			:SetStyle("padding.left", 3)
			:SetStyle("padding.right", 3)
			:SetStyle("padding.bottom", 2)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "queue")
				:SetLayout("VERTICAL")
				:SetStyle("background", "#404040")
				:SetStyle("padding.top", 37)
				:SetStyle("padding.left", 4)
				:SetStyle("padding.right", 4)
				:SetStyle("padding.bottom", 4)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
					:SetStyle("height", 20)
					:SetStyle("margin.bottom", 6)
					:SetStyle("font", TSM.UI.Fonts.MontserratMedium)
					:SetStyle("fontHeight", 14)
					:SetText(L["Crafting Queue"])
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("CraftingQueueList", "queueList")
					:SetStyle("margin.bottom", 10)
					:SetStyle("background", "#000000")
					:SetQuery(TSM.Crafting.Queue.CreateQuery())
					:SetScript("OnRowClick", private.QueueOnRowClick)
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "queueCost")
					:SetLayout("HORIZONTAL")
					:SetStyle("height", 16)
					:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
						:SetStyle("autoWidth", true)
						:SetStyle("font", TSM.UI.Fonts.MontserratRegular)
						:SetStyle("fontHeight", 12)
						:SetStyle("textColor", "#ffffff")
						:SetText(L["Estimated Cost:"])
					)
					:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "text")
						:SetStyle("font", TSM.UI.Fonts.RobotoMedium)
						:SetStyle("fontHeight", 12)
						:SetStyle("textColor", "#ffffff")
						:SetStyle("justifyH", "RIGHT")
					)
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "queueProfit")
					:SetLayout("HORIZONTAL")
					:SetStyle("height", 16)
					:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
						:SetStyle("autoWidth", true)
						:SetStyle("font", TSM.UI.Fonts.MontserratRegular)
						:SetStyle("fontHeight", 12)
						:SetStyle("textColor", "#ffffff")
						:SetText(L["Estimated Profit:"])
					)
					:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "text")
						:SetStyle("font", TSM.UI.Fonts.RobotoMedium)
						:SetStyle("fontHeight", 12)
						:SetStyle("justifyH", "RIGHT")
					)
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "craft")
					:SetLayout("HORIZONTAL")
					:SetStyle("height", 26)
					:SetStyle("margin.top", 4)
					:AddChild(TSMAPI_FOUR.UI.NewElement("ActionButton", "craftNextBtn", "TSMCraftingBtn")
						:SetStyle("width", 170)
						:SetStyle("margin.right", 16)
						:SetStyle("font", TSM.UI.Fonts.MontserratMedium)
						:SetStyle("fontHeight", 14)
						:SetText(L["CRAFT NEXT"])
						:SetScript("OnClick", private.CraftNextOnClick)
					)
					:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "clearBtn")
						:SetStyle("margin.right", 8)
						:SetStyle("font", TSM.UI.Fonts.MontserratMedium)
						:SetStyle("fontHeight", 12)
						:SetStyle("textColor", "#ffffff")
						:SetText(L["Clear Queue"])
						:SetScript("OnClick", TSM.Crafting.Queue.Clear)
					)
				)
			)
		)
		:SetScript("OnUpdate", private.FrameOnUpdate)
		:SetScript("OnHide", private.FrameOnHide)
end

function private.GetCraftingElements(self, button)
	if button == "profession" then
		if not private.professionQuery then
			private.professionQuery = TSM.Crafting.ProfessionScanner.CreateQuery()
		end
		private.professionQuery:Reset()
		local frame = TSMAPI_FOUR.UI.NewElement("Frame", "profession")
			:SetLayout("VERTICAL")
			:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "dropdownFilterFrame")
				:SetLayout("HORIZONTAL")
				:SetStyle("height", 20)
				:SetStyle("margin.left", 8)
				:SetStyle("margin.right", 8)
				:SetStyle("margin.bottom", 8)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Dropdown", "professionDropdown")
					:SetStyle("margin.right", 8)
					:SetHintText(L["No Profession Opened"])
					:SetScript("OnSelectionChanged", private.ProfessionDropdownOnSelectionChanged)
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "filterBtn")
					:SetStyle("width", 40)
					:SetStyle("height", 14)
					:SetStyle("margin.right", 4)
					:SetStyle("font", TSM.UI.Fonts.MontserratMedium)
					:SetStyle("fontHeight", 12)
					:SetStyle("justifyH", "RIGHT")
					:SetText(FILTERS)
					-- TODO
					-- :SetScript("OnClick", private.FilterButtonOnClick)
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "filterBtnIcon")
					:SetStyle("width", 14)
					:SetStyle("height", 14)
					:SetStyle("backgroundTexturePack", "iconPack.14x14/Filter")
					-- TODO
					-- :SetScript("OnClick", private.FilterButtonOnClick)
				)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("SearchInput", "filterInput")
				:SetStyle("height", 20)
				:SetStyle("margin.left", 8)
				:SetStyle("margin.right", 8)
				:SetStyle("margin.bottom", 8)
				:SetHintText(L["Search Patterns"])
				:SetScript("OnEnterPressed", private.FilterSearchInputOnEnterPressed)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Texture", "line")
				:SetStyle("height", 2)
				:SetStyle("color", "#585858")
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "recipeContent")
				:SetLayout("VERTICAL")
				:AddChild(TSMAPI_FOUR.UI.NewElement("ProfessionScrollingTable", "recipeList")
					:SetQuery(private.professionQuery)
					:SetScript("OnSelectionChanged", private.RecipeListOnSelectionChanged)
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Texture", "line")
					:SetStyle("height", 2)
					:SetStyle("color", "#585858")
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "details")
					:SetLayout("HORIZONTAL")
					:SetStyle("height", 118)
					:SetStyle("background", "#2e2e2e")
					:SetStyle("padding", 8)
					:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "left")
						:SetLayout("VERTICAL")
						:SetStyle("width", 194)
						:SetStyle("margin.right", 6)
						:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "title")
							:SetLayout("HORIZONTAL")
							:SetStyle("height", 40)
							:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "icon")
								:SetStyle("width", 32)
								:SetStyle("height", 32)
								:SetStyle("margin.left", 2)
								:SetStyle("margin.right", 8)
							)
							:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "name")
								:SetStyle("justifyH", "LEFT")
								:SetStyle("font", TSM.UI.Fonts.FrizQT)
								:SetStyle("fontHeight", 16)
							)
						)
						:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "num")
							:SetStyle("height", 13)
							:SetStyle("margin.left", 42)
							:SetStyle("margin.bottom", 4)
							:SetStyle("textColor", "#ffffff")
							:SetStyle("font", TSM.UI.Fonts.MontserratMedium)
							:SetStyle("fontHeight", 10)
						)
						:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "error")
							:SetStyle("height", 13)
							:SetStyle("margin.bottom", 8)
							:SetStyle("margin.left", 42)
							:SetStyle("textColor", "#f72d20")
							:SetStyle("font", TSM.UI.Fonts.MontserratBold)
							:SetStyle("fontHeight", 10)
						)
						:AddChild(TSMAPI_FOUR.UI.NewElement("ActionButton", "craftAllBtn")
							:SetStyle("height", 26)
							:SetText(L["CRAFT ALL"])
							:SetScript("OnClick", private.CraftAllBtnOnClick)
						)
					)
					:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "right")
						:SetLayout("VERTICAL")
						:AddChild(TSMAPI_FOUR.UI.NewElement("CraftingMatList", "matList")
							:SetStyle("height", 70)
							:SetStyle("margin.bottom", 8)
						)
						:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "buttons")
							:SetLayout("HORIZONTAL")
							:SetStyle("height", 26)
							:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "number")
								:SetLayout("HORIZONTAL")
								:SetStyle("border", "#6d6d6d")
								:SetStyle("borderSize", 1)
								:AddChild(TSMAPI_FOUR.UI.NewElement("InputNumeric", "input")
									:SetStyle("margin.left", 8)
									:SetStyle("margin.right", 12)
									:SetStyle("backgroundTexturePacks", false)
									:SetStyle("background", "#00000000")
									:SetStyle("font", TSM.UI.Fonts.RobotoMedium)
									:SetStyle("fontHeight", 12)
									:SetStyle("textColor", "#ffffff")
									:SetStyle("textInset", 0)
									:SetStyle("justifyH", "CENTER")
									:SetText(1)
									:SetMaxNumber(MAX_NUM_INPUT_VALUE)
								)
								:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "minusBtn")
									:SetStyle("width", 14)
									:SetStyle("height", 14)
									:SetStyle("margin.right", 6)
									:SetStyle("backgroundTexturePack", "iconPack.14x14/Subtract/Default")
									:SetScript("OnClick", private.MinusBtnOnClick)
								)
								:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "plusBtn")
									:SetStyle("width", 14)
									:SetStyle("height", 14)
									:SetStyle("margin.right", 8)
									:SetStyle("backgroundTexturePack", "iconPack.14x14/Add/Default")
									:SetScript("OnClick", private.PlusBtnOnClick)
								)
							)
							:AddChild(TSMAPI_FOUR.UI.NewElement("ActionButton", "craftBtn")
								:SetStyle("width", 90)
								:SetStyle("height", 26)
								:SetStyle("margin.left", 6)
								:SetStyle("margin.right", 6)
								:SetText(L["CRAFT"])
								:SetScript("OnClick", private.CraftBtnOnClick)
							)
							:AddChild(TSMAPI_FOUR.UI.NewElement("ActionButton", "queueBtn")
								:SetStyle("width", 90)
								:SetStyle("height", 26)
								:SetText(L["QUEUE"])
								:SetScript("OnClick", private.QueueBtnOnClick)
							)
						)
					)
				)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "recipeListLoadingText")
				:SetStyle("justifyH", "CENTER")
				:SetText(L["Profession loading..."])
			)
		frame:GetElement("recipeContent.recipeList"):Hide()
		return frame
	elseif button == "group" then
		return TSMAPI_FOUR.UI.NewElement("Frame", "group")
			:SetLayout("VERTICAL")
			:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "search")
				:SetLayout("HORIZONTAL")
				:SetStyle("height", 20)
				:SetStyle("margin.left", 8)
				:SetStyle("margin.right", 8)
				:SetStyle("margin.bottom", 8)
				:AddChild(TSMAPI_FOUR.UI.NewElement("SearchInput", "input")
					:SetText(private.groupSearch)
					:SetHintText(L["Search Groups"])
					:SetScript("OnTextChanged", private.GroupSearchOnTextChanged)
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "moreBtn")
					:SetStyle("width", 18)
					:SetStyle("height", 18)
					:SetStyle("margin.left", 8)
					:SetStyle("backgroundTexturePack", "iconPack.18x18/More")
					:SetScript("OnClick", private.MoreBtnOnClick)
				)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Texture", "line")
				:SetStyle("height", 2)
				:SetStyle("color", "#9d9d9d")
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("ApplicationGroupTree", "groupTree")
				:SetGroupListFunc(private.GroupTreeGetList)
				:SetSearchString(private.groupSearch)
				:SetScript("OnGroupSelectionChanged", private.GroupTreeOnGroupSelectionChanged)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Texture", "line")
				:SetStyle("height", 2)
				:SetStyle("color", "#9d9d9d")
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("ActionButton", "addBtn")
				:SetStyle("height", 26)
				:SetStyle("margin", 8)
				:SetText(L["RESTOCK SELECTED GROUPS"])
				:SetDisabled(true)
				:SetScript("OnClick", private.QueueAddBtnOnClick)
			)
	else
		error("Unexpected button: "..tostring(button))
	end
end



-- ============================================================================
-- Local Script Handlers
-- ============================================================================

function private.FrameOnUpdate(frame)
	-- delay the FSM event by a few frames to give textures a chance to load
	if private.showDelayFrame == SHOW_DELAY_FRAMES then
		frame:SetScript("OnUpdate", nil)
		private.fsm:ProcessEvent("EV_FRAME_SHOW", frame)
	else
		private.showDelayFrame = private.showDelayFrame + 1
	end
end

function private.FrameOnHide()
	private.showDelayFrame = 0
	private.fsm:ProcessEvent("EV_FRAME_HIDE")
end

function private.GroupSearchOnTextChanged(input)
	private.groupSearch = strlower(strtrim(input:GetText()))
	input:GetElement("__parent.__parent.groupTree")
		:SetSearchString(private.groupSearch)
		:Draw()
end

local function MoreDialogRowIterator(_, prevIndex)
	if prevIndex == nil then
		return 1, L["Select All Groups"], private.SelectAllBtnOnClick
	elseif prevIndex == 1 then
		return 2, L["Deselect All Groups"], private.DeselectAllBtnOnClick
	end
end
function private.MoreBtnOnClick(button)
	button:GetBaseElement():ShowMoreButtonDialog(button, MoreDialogRowIterator)
end

function private.SelectAllBtnOnClick(button)
	local baseFrame = button:GetBaseElement()
	baseFrame:GetElement("content.crafting.left.content.group.groupTree"):SelectAll()
	baseFrame:HideDialog()
end

function private.DeselectAllBtnOnClick(button)
	local baseFrame = button:GetBaseElement()
	baseFrame:GetElement("content.crafting.left.content.group.groupTree"):DeselectAll()
	baseFrame:HideDialog()
end

function private.GroupTreeGetList(groups, headerNameLookup)
	TSM.UI.ApplicationGroupTreeGetGroupList(groups, headerNameLookup, "Crafting")
end

function private.GroupTreeOnGroupSelectionChanged(groupTree)
	local addBtn = groupTree:GetElement("__parent.addBtn")
	addBtn:SetDisabled(groupTree:IsSelectionCleared())
	addBtn:Draw()
end

function private.PageToggleOnValueChanged(toggle, value)
	local page = nil
	if value == L["Crafts"] then
		page = "profession"
	elseif value == L["Groups"] then
		page = "group"
	else
		error("Unexpected value: "..tostring(value))
	end
	private.page = page
	toggle:GetElement("__parent.__parent.content"):SetPath(page, true)
	private.fsm:ProcessEvent("EV_PAGE_CHANGED")
end

function private.ProfessionDropdownOnSelectionChanged(_, value)
	if not value then
		-- nothing selected
	else
		local key = TSMAPI_FOUR.Util.GetDistinctTableKey(private.professions, value)
		local player, profession = strsplit(KEY_SEP, key)
		if not profession then
			-- the current linked / guild / NPC profession was re-selected, so just ignore this change
			return
		end
		private.fsm:ProcessEvent("EV_CHANGE_PROFESSION", player, profession)
	end
end

function private.FilterSearchInputOnEnterPressed(input)
	private.professionQuery:Reset()
	local filter = strtrim(input:GetText())
	if filter ~= "" then
		private.professionQuery:Matches("name", TSMAPI_FOUR.Util.StrEscape(filter))
	end
	input:GetElement("__parent.__parent.recipeContent.recipeList"):SetQuery(private.professionQuery, true)
end

function private.RecipeListOnSelectionChanged(list)
	private.fsm:ProcessEvent("EV_RECIPE_SELECTION_CHANGED", list:GetSelection())
	if IsShiftKeyDown() then
		local item = C_TradeSkillUI.GetRecipeLink(list:GetSelection())
		ChatEdit_InsertLink(item)
	end
end

function private.MinusBtnOnClick(button)
	local input = button:GetElement("__parent.input")
	local value = max(input:GetNumber() or 0, 2) - 1
	input:SetText(value)
	input:Draw()
end

function private.PlusBtnOnClick(button)
	local input = button:GetElement("__parent.input")
	local value = min(max(input:GetNumber() or 0, 0) + 1, MAX_NUM_INPUT_VALUE)
	input:SetText(value)
	input:Draw()
end

function private.QueueBtnOnClick(button)
	local value = max(button:GetElement("__parent.number.input"):GetNumber() or 0, 1)
	private.fsm:ProcessEvent("EV_QUEUE_BUTTON_CLICKED", value)
	button:SetPressed(false)
	button:Draw()
end

function private.CraftBtnOnClick(button)
	local quantity = max(button:GetElement("__parent.number.input"):GetNumber() or 0, 1)
	private.fsm:ProcessEvent("EV_CRAFT_BUTTON_CLICKED", quantity)
end

function private.CraftAllBtnOnClick(button)
	private.fsm:ProcessEvent("EV_CRAFT_BUTTON_CLICKED", -1)
end

function private.QueueOnRowClick(button, data, mouseButton)
	local spellId = data:GetField("spellId")
	if mouseButton == "RightButton" then
		private.fsm:ProcessEvent("EV_QUEUE_RIGHT_CLICKED", spellId)
	else
		private.fsm:ProcessEvent("EV_CRAFT_NEXT_BUTTON_CLICKED", spellId, TSM.Crafting.Queue.GetNum(spellId))
	end
end

function private.CraftNextOnClick(button)
	local spellId = button:GetElement("__parent.__parent.queueList"):GetFirstData():GetField("spellId")
	private.fsm:ProcessEvent("EV_CRAFT_NEXT_BUTTON_CLICKED", spellId, TSM.Crafting.Queue.GetNum(spellId))
end

function private.QueueAddBtnOnClick(button)
	local groups = TSMAPI_FOUR.Util.AcquireTempTable()
	for _, groupPath in button:GetElement("__parent.groupTree"):SelectedGroupsIterator() do
		tinsert(groups, groupPath)
	end
	TSM.Crafting.Queue.RestockGroups(groups)
	TSMAPI_FOUR.Util.ReleaseTempTable(groups)
	button:SetPressed(false)
	button:Draw()
end

function private.HandleOnTitleClick(button)
	if IsShiftKeyDown() then
		local data = button:GetContext()
		ChatEdit_InsertLink(TSMAPI_FOUR.Item.GetLink(data))
	end
end


-- ============================================================================
-- FSM
-- ============================================================================

function private.FSMCreate()
	local function OnTradeSkillClose()
		private.fsm:ProcessEvent("EV_TRADE_SKILL_CLOSED")
	end
	TSMAPI_FOUR.Event.Register("TRADE_SKILL_CLOSE", OnTradeSkillClose)
	TSMAPI_FOUR.Event.Register("GARRISON_TRADESKILL_NPC_CLOSE", OnTradeSkillClose)
	TSMAPI_FOUR.Event.Register("TRADE_SKILL_DATA_SOURCE_CHANGING", function()
		private.fsm:ProcessEvent("EV_DATA_SOURCE_CHANGING")
	end)
	TSMAPI_FOUR.Event.Register("UPDATE_TRADESKILL_RECAST", function()
		private.fsm:ProcessEvent("EV_UPDATE_TRADESKILL_RECAST")
	end)
	TSMAPI_FOUR.Event.Register("UNIT_SPELLCAST_SUCCEEDED", function(_, unit, _, _, _, spellId)
		if unit ~= "player" then
			return
		end
		private.fsm:ProcessEvent("EV_SPELLCAST_COMPLETE", spellId, true)
	end)
	local function SpellcastFailedEventHandler(_, unit, _, _, _, spellId)
		if unit ~= "player" then
			return
		end
		private.fsm:ProcessEvent("EV_SPELLCAST_COMPLETE", spellId, false)
	end
	TSMAPI_FOUR.Event.Register("UNIT_SPELLCAST_INTERRUPTED", SpellcastFailedEventHandler)
	TSMAPI_FOUR.Event.Register("UNIT_SPELLCAST_FAILED", SpellcastFailedEventHandler)
	TSMAPI_FOUR.Event.Register("UNIT_SPELLCAST_FAILED_QUIET", SpellcastFailedEventHandler)

	local function QueryUpdateCallback()
		private.fsm:ProcessEvent("EV_QUERY_CHANGED")
	end
	local fsmContext = {
		frame = nil,
		selectedRecipeSpellId = nil,
		craftingSpellId = nil,
		craftingQuantity = nil,
		craftingType = nil,
		scannerQuery = nil,
		queueQuery = nil,
		currentProfession = nil,
	}
	local function UpdateCraftingFrame(context)
		if not context.frame then
			return
		end

		local dropdownSelection = nil
		local _, currentProfession = C_TradeSkillUI.GetTradeSkillLine()
		local isCurrentProfessionPlayer = not C_TradeSkillUI.IsNPCCrafting() and not C_TradeSkillUI.IsTradeSkillLinked() and not C_TradeSkillUI.IsTradeSkillGuild()
		wipe(private.professions)
		wipe(private.professionsOrder)
		if currentProfession and not isCurrentProfessionPlayer then
			local playerName = nil
			local linked, linkedName = C_TradeSkillUI.IsTradeSkillLinked()
			if linked then
				playerName = linkedName or "?"
			elseif C_TradeSkillUI.IsNPCCrafting() then
				playerName = L["NPC"]
			elseif C_TradeSkillUI.IsTradeSkillGuild() then
				playerName = L["Guild"]
			end
			assert(playerName)
			local key = currentProfession
			tinsert(private.professionsOrder, key)
			private.professions[key] = format("%s - %s", currentProfession, playerName)
			dropdownSelection = key
		end
		local query = TSM.Crafting.PlayerProfessions.GetQuery()
			:Select("player", "profession", "level", "maxLevel")
			-- TODO: support showing of other player's professions?
			:Equal("player", UnitName("player"))
			:OrderBy("isSecondary", true)
			:OrderBy("level", false)
			:OrderBy("profession", true)
		for _, player, profession, level, maxLevel in query:Iterator(true) do
			local key = player..KEY_SEP..profession
			tinsert(private.professionsOrder, key)
			private.professions[key] = format("%s %d/%d - %s", profession, level, maxLevel, player)
			if isCurrentProfessionPlayer and profession == currentProfession then
				assert(not dropdownSelection)
				dropdownSelection = key
			end
		end

		local recipeList = nil
		local craftingContentFrame
		if private.page == "profession" then
			craftingContentFrame = context.frame:GetElement("left.content.profession")
			craftingContentFrame:GetElement("dropdownFilterFrame.professionDropdown")
				:SetDictionaryItems(private.professions, private.professions[dropdownSelection], private.professionsOrder)
			recipeList = craftingContentFrame:GetElement("recipeContent.recipeList")
			if not currentProfession then
				recipeList:Hide()
				local text = craftingContentFrame:GetElement("recipeListLoadingText")
				text:SetText(L["No Profession Selected"])
				text:Show()
			elseif not C_TradeSkillUI.IsTradeSkillReady() or C_TradeSkillUI.IsDataSourceChanging() then
				recipeList:Hide()
				local text = craftingContentFrame:GetElement("recipeListLoadingText")
				text:SetText(L["Loading..."])
				text:Show()
			else
				recipeList:Show()
				craftingContentFrame:GetElement("recipeListLoadingText"):Hide()
			end
		end

		local queueFrame = context.frame:GetElement("right.queue")
		if private.page == "profession" and context.selectedRecipeSpellId and C_TradeSkillUI.IsTradeSkillReady() and not C_TradeSkillUI.IsDataSourceChanging() then
			if recipeList:GetSelection() ~= context.selectedRecipeSpellId then
				recipeList:SetSelection(context.selectedRecipeSpellId)
			end
			local resultName, resultItemString = TSM.Crafting.ProfessionUtil.GetResultInfo(context.selectedRecipeSpellId)
			local detailsFrame = craftingContentFrame:GetElement("recipeContent.details")
			detailsFrame:GetElement("left.title.name")
				:SetText(resultName)
				:SetContext(resultItemString)
			detailsFrame:GetElement("left.title.icon")
				:SetStyle("backgroundTexture", TSMAPI_FOUR.Item.GetTexture(resultItemString))
				:SetTooltip(resultItemString)
			detailsFrame:GetElement("left.num")
				:SetFormattedText(L["Crafts %d"], TSM.Crafting.GetNumResult(context.selectedRecipeSpellId))
			local toolsStr, hasTools = C_TradeSkillUI.GetRecipeTools(context.selectedRecipeSpellId)
			local errorText = detailsFrame:GetElement("left.error")
			local canCraft = false
			if toolsStr and not hasTools then
				errorText:SetText(REQUIRES_LABEL..toolsStr)
			elseif (not toolsStr or hasTools) and TSM.Crafting.ProfessionUtil.GetNumCraftable(context.selectedRecipeSpellId) == 0 then
				errorText:SetText(L["Missing Materials"])
			else
				canCraft = true
				errorText:SetText("")
			end
			local isEnchant = TSM.Crafting.ProfessionUtil.IsEnchant(context.selectedRecipeSpellId)
			detailsFrame:GetElement("right.buttons.craftBtn")
				:SetDisabled(not canCraft or context.craftingSpellId)
				:SetPressed(context.craftingSpellId and context.craftingType == "craft")
			detailsFrame:GetElement("left.craftAllBtn")
				:SetText(isEnchant and L["Enchant Vellum"] or L["Craft All"])
				:SetDisabled(not canCraft or context.craftingSpellId)
				:SetPressed(context.craftingSpellId and context.craftingType == "all")
			detailsFrame:GetElement("right.matList")
				:SetRecipe(context.selectedRecipeSpellId)
		else
			if private.page == "profession" and recipeList:GetSelection() then
				recipeList:SetSelection(nil)
			end
		end

		local totalCost, totalProfit = TSM.Crafting.Queue.GetTotalCostAndProfit()
		local totalCostText = totalCost and TSMAPI_FOUR.Money.ToString(totalCost, "OPT_SEP") or ""
		queueFrame:GetElement("queueCost.text"):SetText(totalCostText)
		local totalProfitText = totalProfit and TSMAPI_FOUR.Money.ToString(totalProfit, totalProfit >= 0 and "|cff2cec0d" or "|cffd50000", "OPT_SEP") or ""
		queueFrame:GetElement("queueProfit.text"):SetText(totalProfitText)
		queueFrame:GetElement("queueList"):Draw()
		local nextCraftRecord = queueFrame:GetElement("queueList"):GetFirstData()
		if nextCraftRecord and (TSM.Crafting.GetProfession(nextCraftRecord:GetField("spellId")) ~= context.currentProfession or TSM.Crafting.ProfessionUtil.GetNumCraftable(nextCraftRecord:GetField("spellId")) == 0) then
			nextCraftRecord = nil
		end
		local canCraftFromQueue = currentProfession and isCurrentProfessionPlayer and C_TradeSkillUI.IsTradeSkillReady() and not C_TradeSkillUI.IsDataSourceChanging()
		queueFrame:GetElement("craft.craftNextBtn")
			:SetDisabled(not canCraftFromQueue or not nextCraftRecord or context.craftingSpellId)
			:SetPressed(context.craftingSpellId and context.craftingType == "queue")
		if nextCraftRecord and canCraftFromQueue then
			C_TradeSkillUI.SetRecipeRepeatCount(nextCraftRecord:GetField("spellId"), nextCraftRecord:GetField("num"))
		end

		context.frame:Draw()
	end
	private.fsm = TSMAPI_FOUR.FSM.New("CRAFTING_UI_CRAFTING")
		:AddState(TSMAPI_FOUR.FSM.NewState("ST_FRAME_CLOSED")
			:SetOnEnter(function(context)
				context.selectedRecipeSpellId = nil
				context.frame = nil
				context.currentProfession = nil
				if context.scannerQuery then
					context.scannerQuery:Release()
					context.scannerQuery = nil
				end
			end)
			:AddTransition("ST_FRAME_CLOSED")
			:AddTransition("ST_FRAME_OPENING")
			:AddEvent("EV_FRAME_SHOW", TSMAPI_FOUR.FSM.SimpleTransitionEventHandler("ST_FRAME_OPENING"))
		)
		:AddState(TSMAPI_FOUR.FSM.NewState("ST_FRAME_OPENING")
			:SetOnEnter(function(context, frame)
				local _, currentProfession = C_TradeSkillUI.GetTradeSkillLine()
				if currentProfession ~= context.currentProfession then
					context.selectedRecipeSpellId = TSM.Crafting.ProfessionScanner.GetFirstSpellId()
					context.currentProfession = currentProfession
				end
				if not context.queueQuery then
					context.queueQuery = TSM.Crafting.Queue.CreateQuery()
					context.queueQuery:SetUpdateCallback(QueryUpdateCallback)
				end
				context.scannerQuery = TSM.Crafting.ProfessionScanner.CreateQuery()
				context.scannerQuery:SetUpdateCallback(QueryUpdateCallback)
				context.frame = frame
				TSM:LOG_INFO("Selected %s", context.selectedRecipeSpellId)
				return "ST_FRAME_OPEN"
			end)
			:AddTransition("ST_FRAME_OPEN")
		)
		:AddState(TSMAPI_FOUR.FSM.NewState("ST_FRAME_OPEN")
			:SetOnEnter(function(context)
				if context.currentProfession and not context.selectedRecipeSpellId then
					context.selectedRecipeSpellId = TSM.Crafting.ProfessionScanner.GetFirstSpellId()
				end
				UpdateCraftingFrame(context)
			end)
			:AddTransition("ST_FRAME_CLOSED")
			:AddTransition("ST_FRAME_OPEN")
			:AddTransition("ST_CHANGING_SELECTION")
			:AddTransition("ST_STARTING_CRAFT")
			:AddTransition("ST_CASTING_COMPLETE")
			:AddEvent("EV_PAGE_CHANGED", TSMAPI_FOUR.FSM.SimpleTransitionEventHandler("ST_FRAME_OPEN"))
			:AddEvent("EV_DATA_SOURCE_CHANGING", function(context, selection)
				context.selectedRecipeSpellId = nil
				return "ST_FRAME_OPEN"
			end)
			:AddEvent("EV_QUERY_CHANGED", TSMAPI_FOUR.FSM.SimpleTransitionEventHandler("ST_FRAME_OPEN"))
			:AddEvent("EV_TRADE_SKILL_CLOSED", function(context, selection)
				context.selectedRecipeSpellId = nil
				TSM:LOG_INFO("Selected %s", context.selectedRecipeSpellId)
				return "ST_FRAME_OPEN"
			end)
			:AddEvent("EV_CHANGE_PROFESSION", function(context, player, profession)
				context.selectedRecipeSpellId = nil
				TSM:LOG_INFO("Selected %s", context.selectedRecipeSpellId)
				-- TODO: support showing of other player's professions?
				assert(player == UnitName("player"))
				if profession == GetSpellInfo(MINING_SPELLID) then
					-- mining needs to be opened as smelting
					CastSpellByName(GetSpellInfo(SMELTING_SPELLID))
				else
					CastSpellByName(profession)
				end
				return "ST_FRAME_OPEN"
			end)
			:AddEvent("EV_RECIPE_SELECTION_CHANGED", TSMAPI_FOUR.FSM.SimpleTransitionEventHandler("ST_CHANGING_SELECTION"))
			:AddEvent("EV_CRAFT_BUTTON_CLICKED", function(context, quantity)
				context.craftingType = quantity == -1 and "all" or "craft"
				return "ST_STARTING_CRAFT", context.selectedRecipeSpellId, quantity
			end)
			:AddEvent("EV_CRAFT_NEXT_BUTTON_CLICKED", function(context, spellId, quantity)
				if TSM.Crafting.GetProfession(spellId) ~= context.currentProfession or TSM.Crafting.ProfessionUtil.GetNumCraftable(spellId) == 0 then
					-- FIXME
					-- context.frame:GetElement("recipeContent.details.craft.craftBtn"):SetPressed(false)
					return
				end
				context.craftingType = "queue"
				return "ST_STARTING_CRAFT", spellId, quantity
			end)
			:AddEvent("EV_SPELLCAST_COMPLETE", function(context, spellId, success)
				if context.craftingSpellId ~= spellId then
					return
				end
				return "ST_CASTING_COMPLETE", spellId, success
			end)
			:AddEvent("EV_QUEUE_BUTTON_CLICKED", function(context, quantity)
				assert(context.selectedRecipeSpellId)
				TSM.Crafting.Queue.Add(context.selectedRecipeSpellId, quantity)
				return "ST_FRAME_OPEN"
			end)
			:AddEvent("EV_UPDATE_TRADESKILL_RECAST", function(context)
				if context.craftingSpellId then
					C_TradeSkillUI.SetRecipeRepeatCount(context.craftingSpellId, context.craftingQuantity)
				end
			end)
			:AddEvent("EV_QUEUE_RIGHT_CLICKED", function(context, spellId)
				if TSM.Crafting.GetProfession(spellId) == context.currentProfession then
					context.selectedRecipeSpellId = spellId
					TSM:LOG_INFO("Selected %s", context.selectedRecipeSpellId)
					return "ST_FRAME_OPEN"
				end
			end)
		)
		:AddState(TSMAPI_FOUR.FSM.NewState("ST_CHANGING_SELECTION")
			:SetOnEnter(function(context, selection)
				context.selectedRecipeSpellId = selection
				TSM:LOG_INFO("Selected %s", context.selectedRecipeSpellId)
				return "ST_FRAME_OPEN"
			end)
			:AddTransition("ST_FRAME_OPEN")
		)
		:AddState(TSMAPI_FOUR.FSM.NewState("ST_STARTING_CRAFT")
			:SetOnEnter(function(context, spellId, quantity)
				TSM:LOG_INFO("Crafting %d of %d", quantity, spellId)
				if quantity == -1 then
					quantity = TSM.Crafting.ProfessionUtil.GetNumCraftable(spellId)
					if quantity == 0 then
						return "ST_FRAME_OPEN"
					end
				end
				context.craftingAll = quantity == -1
				local isEnchant = TSM.Crafting.ProfessionUtil.IsEnchant(spellId)
				if isEnchant then
					quantity = 1
				end
				if context.craftingType == "craft" then
					-- FIXME: since we don't have the repeat count set, we can only craft one due to blizzard weirdness
					quantity = 1
				end
				C_TradeSkillUI.CraftRecipe(spellId, quantity)
				if isEnchant and context.craftingType ~= "craft" then
					UseItemByName(TSMAPI_FOUR.Item.GetName(TSM.CONST.VELLUM_ITEM_STRING))
				end
				context.craftingSpellId = spellId
				context.craftingQuantity = quantity
				return "ST_FRAME_OPEN"
			end)
			:AddTransition("ST_FRAME_OPEN")
		)
		:AddState(TSMAPI_FOUR.FSM.NewState("ST_CASTING_COMPLETE")
			:SetOnEnter(function(context, spellId, success)
				if success then
					TSM:LOG_INFO("Crafted %d", spellId)
					TSM.Crafting.Queue.Remove(context.craftingSpellId, 1)
					context.craftingQuantity = context.craftingQuantity - 1
					assert(context.craftingQuantity >= 0)
					if context.craftingQuantity == 0 then
						context.craftingSpellId = nil
						context.craftingQuantity = nil
						context.craftingType = nil
					end
				else
					context.craftingSpellId = nil
					context.craftingQuantity = nil
					context.craftingType = nil
				end
				return "ST_FRAME_OPEN"
			end)
			:AddTransition("ST_FRAME_OPEN")
		)
		:AddDefaultEvent("EV_FRAME_HIDE", TSMAPI_FOUR.FSM.SimpleTransitionEventHandler("ST_FRAME_CLOSED"))
		:AddDefaultEvent("EV_SPELLCAST_COMPLETE", function(context, spellId)
			if context.craftingSpellId == spellId then
				context.craftingSpellId = nil
				context.craftingQuantity = nil
				context.craftingType = nil
			end
		end)
		:Init("ST_FRAME_CLOSED", fsmContext)
end
