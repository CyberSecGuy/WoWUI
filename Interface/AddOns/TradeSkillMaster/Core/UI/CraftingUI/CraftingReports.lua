-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local CraftingReports = TSM.UI.CraftingUI:NewPackage("CraftingReports")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = { craftsQuery = nil, matsQuery = nil, craftProfessions = {}, matProfessions = {}, MatPriceSources = {L["All"], L["Default Price"], L["Custom Price"]} }



-- ============================================================================
-- Module Functions
-- ============================================================================

function CraftingReports.OnInitialize()
	TSM.UI.CraftingUI.RegisterTopLevelPage("Crafting Reports", "iconPack.24x24/Inventory", private.GetCraftingReportsFrame)
end



-- ============================================================================
-- CraftingReports UI
-- ============================================================================

function private.GetCraftingReportsFrame()
	private.craftsQuery = private.craftsQuery or TSM.Crafting.CreateCraftsQuery()
	private.craftsQuery:Reset()
	private.matsQuery = private.matsQuery or TSM.Crafting.CreateMatsQuery()
	private.matsQuery:Reset()
	private.matsQuery:Distinct("itemString")
	return TSMAPI_FOUR.UI.NewElement("Frame", "craftingReportsContent")
		:SetLayout("VERTICAL")
		:SetStyle("padding", { top = 37 })
		:SetStyle("background", "#272727")
		:AddChild(TSMAPI_FOUR.UI.NewElement("TabGroup", "buttons")
			:SetNavCallback(private.GetTabElements)
			:AddPath(L["Crafts"], true)
			:AddPath(L["Materials"])
			-- :AddPath(L["Cooldowns"])
		)
end

function private.GetTabElements(self, path)
	if path == L["Crafts"] then
		local dropdownSelection = nil
		wipe(private.craftProfessions)
		tinsert(private.craftProfessions, L["All Professions"])
		local query = TSM.Crafting.PlayerProfessions.GetQuery()
			:Select("profession", "player")
			:OrderBy("isSecondary", true)
			:OrderBy("level", false)
			:OrderBy("profession", true)
		for _, profession, player in query:Iterator(true) do
			tinsert(private.craftProfessions, format("%s - %s", profession, player))
		end

		return TSMAPI_FOUR.UI.NewElement("Frame", "crafts")
			:SetLayout("VERTICAL")
			:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "filters")
				:SetLayout("HORIZONTAL")
				:SetStyle("height", 44)
				:SetStyle("margin", { top = 8, bottom = 16, left = 12, right = 12 })
				:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "search")
					:SetLayout("VERTICAL")
					:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
						:SetStyle("height", 14)
						:SetStyle("margin", { bottom = 4 })
						:SetStyle("font", TSM.UI.Fonts.MontserratBold)
						:SetStyle("fontHeight", 10)
						:SetText(strupper(SEARCH))
					)
					:AddChild(TSMAPI_FOUR.UI.NewElement("Input", "input")
						:SetStyle("height", 26)
						:SetHintText(L["Filter by Keyword"])
						:SetScript("OnEnterPressed", private.CraftsInputOnEnterPressed)
					)
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "profession")
					:SetLayout("VERTICAL")
					:SetStyle("margin", { left = 16, right = 16 })
					:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
						:SetStyle("height", 14)
						:SetStyle("margin", { bottom = 4 })
						:SetStyle("font", TSM.UI.Fonts.MontserratBold)
						:SetStyle("fontHeight", 10)
						:SetText(L["PROFESSION"])
					)
					:AddChild(TSMAPI_FOUR.UI.NewElement("Dropdown", "dropdown")
						:SetStyle("height", 26)
						:SetItems(private.craftProfessions, private.craftProfessions[1])
						:SetScript("OnSelectionChanged", private.CraftsDropdownOnSelectionChanged)
					)
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "craftable")
					:SetLayout("HORIZONTAL")
					:SetStyle("width", 200)
					:SetStyle("margin", { top = 18 })
					:AddChild(TSMAPI_FOUR.UI.NewElement("Checkbox", "checkbox")
						:SetStyle("width", 24)
						:SetStyle("height", 24)
						:SetScript("OnValueChanged", private.CheckboxOnValueChanged)
					)
					:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
						:SetStyle("height", 20)
						:SetStyle("fontHeight", 14)
						:SetText(L["Only show craftable"])
					)
				)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Texture", "line")
				:SetStyle("height", 2)
				:SetStyle("color", "#9d9d9d")
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("FastScrollingTable", "crafts")
				:SetStyle("headerFontHeight", 12)
				:GetScrollingTableInfo()
					:NewColumn("queued")
						:SetTitleIcon("iconPack.18x18/Queue")
						:SetWidth(16)
						:SetFont(TSM.UI.Fonts.FRIZQT)
						:SetFontHeight(12)
						:SetJustifyH("CENTER")
						:SetTextFunction(private.CraftsGetQueuedText)
						:SetSortValueFunction(private.CraftsQueuedSortFunction)
						:Commit()
					:NewColumn("craftName")
						:SetTitles(L["Craft Name"])
						:SetFont(TSM.UI.Fonts.MontserratRegular)
						:SetFontHeight(12)
						:SetJustifyH("LEFT")
						:SetTextFunction(private.CraftsGetCraftNameText)
						:SetSortValueFunction(private.CraftsCraftNameSortFunction)
						:SetTooltipFunction(private.CraftsGetCraftNameTooltip)
						:Commit()
					:NewColumn("operation")
						:SetTitles(L["Operation"])
						:SetWidth(100)
						:SetFont(TSM.UI.Fonts.MontserratRegular)
						:SetFontHeight(12)
						:SetJustifyH("LEFT")
						:SetTextFunction(private.CraftsGetOperationText)
						:SetSortValueFunction(private.CraftsOperationSortFunction)
						:Commit()
					:NewColumn("bags")
						:SetTitles(L["Bag"])
						:SetWidth(24)
						:SetFont(TSM.UI.Fonts.RobotoMedium)
						:SetFontHeight(12)
						:SetJustifyH("RIGHT")
						:SetTextFunction(private.CraftsGetBagsText)
						:SetSortValueFunction(private.CraftsBagsSortFunction)
						:Commit()
					:NewColumn("ah")
						:SetTitles(L["AH"])
						:SetWidth(24)
						:SetFont(TSM.UI.Fonts.RobotoMedium)
						:SetFontHeight(12)
						:SetJustifyH("RIGHT")
						:SetTextFunction(private.CraftsGetAHText)
						:SetSortValueFunction(private.CraftsAHSortFunction)
						:Commit()
					:NewColumn("craftingCost")
						:SetTitles(L["Crafting Cost"])
						:SetWidth(100)
						:SetFont(TSM.UI.Fonts.RobotoMedium)
						:SetFontHeight(12)
						:SetJustifyH("RIGHT")
						:SetTextFunction(private.CraftsGetCraftingCostText)
						:SetSortValueFunction(private.CraftsCraftingCostSortFunction)
						:Commit()
					:NewColumn("itemValue")
						:SetTitles(L["Item Value"])
						:SetWidth(100)
						:SetFont(TSM.UI.Fonts.RobotoMedium)
						:SetFontHeight(12)
						:SetJustifyH("RIGHT")
						:SetTextFunction(private.CraftsGetItemValueText)
						:SetSortValueFunction(private.CraftsItemValueSortFunction)
						:Commit()
					:NewColumn("profit")
						:SetTitles(L["Profit"])
						:SetWidth(100)
						:SetFont(TSM.UI.Fonts.RobotoMedium)
						:SetFontHeight(12)
						:SetJustifyH("RIGHT")
						:SetTextFunction(private.CraftsGetProfitText)
						:SetSortValueFunction(private.CraftsProfitSortFunction)
						:Commit()
					:NewColumn("saleRate")
						:SetTitleIcon("iconPack.18x18/SaleRate")
						:SetWidth(32)
						:SetFont(TSM.UI.Fonts.RobotoMedium)
						:SetFontHeight(12)
						:SetJustifyH("CENTER")
						:SetTextFunction(private.CraftsGetSaleRateText)
						:SetSortValueFunction(private.CraftsSaleRateSortFunction)
						:Commit()
					:SetDefaultSort("craftName", true)
					:Commit()
				:SetQuery(private.craftsQuery)
				:SetSelectionDisabled(true)
				:SetScript("OnRowClick", private.CraftsOnRowClick)
			)
	elseif path == L["Materials"] then
		local dropdownSelection = nil
		wipe(private.matProfessions)
		tinsert(private.matProfessions, L["All Professions"])
		local query = TSM.Crafting.PlayerProfessions.GetQuery()
			:Select("profession")
			:OrderBy("isSecondary", true)
			:OrderBy("level", false)
			:OrderBy("profession", true)
		for _, profession in query:Iterator(true) do
			if not private.matProfessions[profession] then
				tinsert(private.matProfessions, profession)
				private.matProfessions[profession] = true
			end
		end

		return TSMAPI_FOUR.UI.NewElement("Frame", "materials")
			:SetLayout("VERTICAL")
			:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "filters")
				:SetLayout("HORIZONTAL")
				:SetStyle("height", 44)
				:SetStyle("margin", { top = 8, bottom = 16, left = 12, right = 12 })
				:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "search")
					:SetLayout("VERTICAL")
					:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
						:SetStyle("height", 14)
						:SetStyle("margin", { bottom = 4 })
						:SetStyle("font", TSM.UI.Fonts.MontserratBold)
						:SetStyle("fontHeight", 10)
						:SetText(strupper(SEARCH))
					)
					:AddChild(TSMAPI_FOUR.UI.NewElement("Input", "input")
						:SetStyle("height", 26)
						:SetHintText(L["Filter by Keyword"])
						:SetScript("OnEnterPressed", private.MatsInputOnEnterPressed)
					)
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "profession")
					:SetLayout("VERTICAL")
					:SetStyle("margin", { left = 16 })
					:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
						:SetStyle("height", 14)
						:SetStyle("margin", { bottom = 4 })
						:SetStyle("font", TSM.UI.Fonts.MontserratBold)
						:SetStyle("fontHeight", 10)
						:SetText(L["PROFESSION"])
					)
					:AddChild(TSMAPI_FOUR.UI.NewElement("Dropdown", "dropdown")
						:SetStyle("height", 26)
						:SetItems(private.matProfessions, private.matProfessions[1])
						:SetScript("OnSelectionChanged", private.MatsDropdownOnSelectionChanged)
					)
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "priceSource")
					:SetLayout("VERTICAL")
					:SetStyle("margin", { left = 16 })
					:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
						:SetStyle("height", 14)
						:SetStyle("margin", { bottom = 4 })
						:SetStyle("font", TSM.UI.Fonts.MontserratBold)
						:SetStyle("fontHeight", 10)
						:SetText(L["PRICE SOURCE"])
					)
					:AddChild(TSMAPI_FOUR.UI.NewElement("Dropdown", "dropdown")
						:SetStyle("height", 26)
						:SetItems(private.MatPriceSources, private.MatPriceSources[1])
						:SetScript("OnSelectionChanged", private.MatsDropdownOnSelectionChanged)
					)
				)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Texture", "line")
				:SetStyle("height", 2)
				:SetStyle("color", "#9d9d9d")
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("FastScrollingTable", "mats")
				:GetScrollingTableInfo()
					:NewColumn("name")
						:SetTitles(L["Material Name"])
						:SetFont(TSM.UI.Fonts.FRIZQT)
						:SetFontHeight(12)
						:SetJustifyH("LEFT")
						:SetTextFunction(private.MatsGetNameText)
						:SetSortValueFunction(private.MatsGetNameSortFunction)
						:SetTooltipFunction(private.MatsGetNameTooltip)
						:Commit()
					:NewColumn("price")
						:SetTitles(L["Mat Price"])
						:SetWidth(100)
						:SetFont(TSM.UI.Fonts.RobotoMedium)
						:SetFontHeight(12)
						:SetJustifyH("RIGHT")
						:SetTextFunction(private.MatsGetPriceText)
						:SetSortValueFunction(private.MatsGetPriceSortFunction)
						:Commit()
					:NewColumn("professions")
						:SetTitles(L["Professions Used In"])
						:SetWidth(300)
						:SetFont(TSM.UI.Fonts.FRIZQT)
						:SetFontHeight(12)
						:SetJustifyH("LEFT")
						:SetTextFunction(private.MatsGetProfessionsText)
						:SetSortValueFunction(private.MatsGetProfessionsSortFunction)
						:Commit()
					:NewColumn("num")
						:SetTitles(L["Number Owned"])
						:SetWidth(120)
						:SetFont(TSM.UI.Fonts.RobotoMedium)
						:SetFontHeight(12)
						:SetJustifyH("RIGHT")
						:SetTextFunction(private.MatsGetNumText)
						:SetSortValueFunction(private.MatsGetNumSortFunction)
						:Commit()
					:SetDefaultSort("name", true)
					:Commit()
				:SetQuery(private.matsQuery)
				:SetSelectionDisabled(true)
				:SetScript("OnRowClick", private.MatsOnRowClick)
			)
	elseif path == L["Cooldowns"] then
		return TSMAPI_FOUR.UI.NewElement("Frame", "cooldowns")
			:SetLayout("VERTICAL")
	else
		error("Unknown path: "..tostring(path))
	end
end



-- ============================================================================
-- Crafts ScrollingTable Functions
-- ============================================================================

function private.CraftsGetQueuedText(_, record)
	return TSM.Crafting.Queue.GetNum(record:GetField("spellId"))
end

function private.CraftsQueuedSortFunction(_, record)
	return TSM.Crafting.Queue.GetNum(record:GetField("spellId"))
end

function private.CraftsGetCraftNameText(_, record)
	return TSM.UI.GetColoredItemName(record:GetField("itemString")) or record:GetField("name")
end

function private.CraftsGetCraftNameTooltip(_, record)
	local itemString = record:GetField("itemString")
	return itemString ~= "" and itemString or nil
end

function private.CraftsCraftNameSortFunction(_, record)
	return record:GetField("itemName") or ""
end

function private.CraftsGetOperationText(_, record)
	return TSMAPI.Operations:GetFirstByItem(record:GetField("itemString"), "Crafting") or ""
end

function private.CraftsOperationSortFunction(_, record)
	return TSMAPI.Operations:GetFirstByItem(record:GetField("itemString"), "Crafting") or ""
end

function private.CraftsGetBagsText(_, record)
	return 0 -- TODO
end

function private.CraftsBagsSortFunction(_, record)
	return 0 -- TODO
end

function private.CraftsGetAHText(_, record)
	return 0 -- TODO
end

function private.CraftsAHSortFunction(_, record)
	return 0 -- TODO
end

function private.CraftsGetCraftingCostText(_, record)
	return TSMAPI_FOUR.Money.ToString(TSM.Crafting.Cost.GetCraftingCostBySpellId(record:GetField("spellId")), "OPT_PAD")
end

function private.CraftsCraftingCostSortFunction(_, record)
	return TSM.Crafting.Cost.GetCraftingCostBySpellId(record:GetField("spellId"))
end

function private.CraftsGetItemValueText(_, record)
	local craftedItemValue = TSM.Crafting.Cost.GetCraftedItemValue(record:GetField("itemString")) or nil
	return craftedItemValue and TSMAPI_FOUR.Money.ToString(craftedItemValue, "OPT_PAD") or ""
end

function private.CraftsItemValueSortFunction(_, record)
	return TSM.Crafting.Cost.GetCraftedItemValue(record:GetField("itemString")) or -math.huge
end

function private.CraftsGetProfitText(_, record)
	local profit = TSM.Crafting.Cost.GetProfitBySpellId(record:GetField("spellId")) or nil
	if not profit then
		return ""
	end
	return TSMAPI_FOUR.Money.ToString(profit, "OPT_PAD", profit >= 0 and "|cff2cec0d" or "|cffd50000") or ""
end

function private.CraftsProfitSortFunction(_, record)
	return TSM.Crafting.Cost.GetProfitBySpellId(record:GetField("spellId")) or -math.huge
end

function private.CraftsGetSaleRateText(_, record)
	local itemString = record:GetField("itemString")
	local saleRate = itemString and TSM.old.AuctionDB.GetRegionItemData(itemString, "regionSalePercent")
	return saleRate and format("%0.2f", saleRate / 100) or ""
end

function private.CraftsSaleRateSortFunction(_, record)
	local itemString = record:GetField("itemString")
	local saleRate = itemString and TSM.old.AuctionDB.GetRegionItemData(itemString, "regionSalePercent")
	saleRate = saleRate and (saleRate / 100)
	return saleRate or 0
end



-- ============================================================================
-- Mats ScrollingTable Functions
-- ============================================================================

function private.MatsGetNameText(_, record)
	return TSM.UI.GetColoredItemName(record:GetField("itemString"))
end

function private.MatsGetNameSortFunction(_, record)
	return TSMAPI_FOUR.Item.GetName(record:GetField("itemString")) or ""
end

function private.MatsGetNameTooltip(_, record)
	return record:GetField("itemString")
end

function private.MatsGetPriceText(_, record)
	return TSMAPI_FOUR.Money.ToString(TSM.Crafting.Cost.GetMatCost(record:GetField("itemString")), "OPT_PAD")
end

function private.MatsGetPriceSortFunction(_, record)
	return TSM.Crafting.Cost.GetMatCost(record:GetField("itemString"))
end

function private.MatsGetProfessionsText(_, record)
	local professions = TSMAPI_FOUR.Util.AcquireTempTable()
	for _, profession in TSM.Crafting.MatProfessionIterator(record:GetField("itemString")) do
		tinsert(professions, profession)
	end
	sort(professions)
	return strjoin(",", TSMAPI_FOUR.Util.UnpackAndReleaseTempTable(professions))
end

function private.MatsGetProfessionsSortFunction(_, record)
	local professions = TSMAPI_FOUR.Util.AcquireTempTable()
	for _, profession in TSM.Crafting.MatProfessionIterator(record:GetField("itemString")) do
		tinsert(professions, profession)
	end
	sort(professions)
	return strjoin(",", TSMAPI_FOUR.Util.UnpackAndReleaseTempTable(professions))
end

function private.MatsGetNumText(_, record)
	return 0 -- TODO
end

function private.MatsGetNumSortFunction(_, record)
	return 0 -- TODO
end



-- ============================================================================
-- Local Script Handlers
-- ============================================================================

function private.CraftsInputOnEnterPressed(input)
	private.UpdateCraftsQueryWithFilters(input:GetParentElement():GetParentElement())
end

function private.CraftsDropdownOnSelectionChanged(dropdown, selection)
	private.UpdateCraftsQueryWithFilters(dropdown:GetParentElement():GetParentElement())
end

function private.CheckboxOnValueChanged(checkbox)
	private.UpdateCraftsQueryWithFilters(checkbox:GetParentElement():GetParentElement())
end

function private.CraftsOnRowClick(scrollingTable, record, mouseButton)
	if mouseButton == "LeftButton" then
		TSM.Crafting.Queue.Add(record:GetField("spellId"), 1)
	elseif mouseButton == "RightButton" then
		TSM.Crafting.Queue.Remove(record:GetField("spellId"), 1)
	end
	scrollingTable:Draw()
end

function private.MatsInputOnEnterPressed(input)
	private.UpdateMatsQueryWithFilters(input:GetParentElement():GetParentElement())
end

function private.MatsDropdownOnSelectionChanged(dropdown, selection)
	private.UpdateMatsQueryWithFilters(dropdown:GetParentElement():GetParentElement())
end

function private.MatsOnRowClick(scrollingTable, record)
	local itemString = record:GetField("itemString")
	local priceStr = TSM.db.factionrealm.internalData.mats[itemString].customValue or TSM.db.global.craftingOptions.defaultMatCostMethod
	local frame = TSMAPI_FOUR.UI.NewElement("Frame", "frame")
		:SetLayout("VERTICAL")
		:SetStyle("width", 600)
		:SetStyle("height", 187)
		:SetStyle("anchors", { { "CENTER" } })
		:SetStyle("background", "#2e2e2e")
		:SetStyle("border", "#e2e2e2")
		:SetStyle("borderSize", 2)
		:SetContext(itemString)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "title")
			:SetStyle("height", 44)
			:SetStyle("margin", { top = 24, left = 16, right = 16, bottom = 16 })
			:SetStyle("font", TSM.UI.Fonts.MontserratBold)
			:SetStyle("fontHeight", 18)
			:SetStyle("justifyH", "CENTER")
			:SetText(TSM.UI.GetColoredItemName(itemString))
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Input", "normalPriceInput")
			:SetStyle("height", 26)
			:SetStyle("margin", { left = 16, right = 16, bottom = 25 })
			:SetStyle("background", "#5c5c5c")
			:SetStyle("font", TSM.UI.Fonts.MontserratMedium)
			:SetStyle("fontHeight", 12)
			:SetStyle("justifyH", "LEFT")
			:SetStyle("textColor", "#ffffff")
			:SetText(TSMAPI_FOUR.Money.ToString(priceStr, "OPT_NO_COLOR") or priceStr)
			:SetScript("OnEnterPressed", private.MatPriceInputOnEnterPressed)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "buttons")
			:SetLayout("HORIZONTAL")
			:SetStyle("margin", { left = 16, right = 16, bottom = 16 })
			:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "spacer")
				-- spacer
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("ActionButton", "confirmBtn")
				:SetStyle("width", 126)
				:SetStyle("height", 26)
				:SetText(CLOSE)
				:SetScript("OnClick", private.DialogCloseBtnOnClick)
			)
		)
	scrollingTable:GetBaseElement():ShowDialogFrame(frame)
end

function private.DialogCloseBtnOnClick(button)
	button:GetBaseElement():HideDialog()
end

function private.MatPriceInputOnEnterPressed(input)
	local value = strtrim(input:GetText())
	if value ~= "" and TSMAPI_FOUR.CustomPrice.Validate(value) then
		local itemString = input:GetParentElement():GetContext()
		TSM.db.factionrealm.internalData.mats[itemString].customValue = value
	else
		-- TODO: better error message
		TSM:Print(L["Invalid custom price entered."])
	end
end



-- ============================================================================
-- Private Helper Functions
-- ============================================================================

function private.UpdateCraftsQueryWithFilters(frame)
	private.craftsQuery:Reset()
	-- apply search filter
	local filter = strtrim(frame:GetElement("search.input"):GetText())
	if filter ~= "" then
		private.craftsQuery:Matches("itemName", TSMAPI_FOUR.Util.StrEscape(filter))
	end
	-- apply dropdown filter
	local professionPlayer = frame:GetElement("profession.dropdown"):GetSelection()
	if professionPlayer ~= private.craftProfessions[1] then
		local profession, player = strmatch(professionPlayer, "^([^ ]+) %- ([^ ]+)$")
		private.craftsQuery
			:Equal("profession", profession)
			:Or()
				:Equal("players", player)
				:Matches("players", "^"..player..",")
				:Matches("players", ","..player..",")
				:Matches("players", ","..player.."$")
			:End()
	end
	-- apply craftable filter
	local craftableOnly = frame:GetElement("craftable.checkbox"):IsChecked()
	if craftableOnly then
		private.craftsQuery:Custom(private.IsCraftableQueryFilter)
	end
	frame:GetElement("__parent.crafts"):SetQuery(private.craftsQuery, true)
end

function private.IsCraftableQueryFilter(record)
	return TSM.Crafting.ProfessionUtil.GetNumCraftableFromDB(record:GetField("spellId")) > 0
end

function private.UpdateMatsQueryWithFilters(frame)
	private.matsQuery:Reset()
	private.matsQuery:Distinct("itemString")
	-- apply search filter
	local filter = strtrim(frame:GetElement("search.input"):GetText())
	if filter ~= "" then
		private.matsQuery:Custom(private.MatItemNameQueryFilter, strlower(TSMAPI_FOUR.Util.StrEscape(filter)))
	end
	-- apply dropdown filters
	local profession = frame:GetElement("profession.dropdown"):GetSelection()
	if profession ~= private.matProfessions[1] then
		private.matsQuery:Equal("profession", profession)
	end
	local priceSource = frame:GetElement("priceSource.dropdown"):GetSelection()
	if priceSource == private.MatPriceSources[2] then
		private.matsQuery:Equal("customValue", false)
	elseif priceSource == private.MatPriceSources[3] then
		private.matsQuery:Equal("customValue", true)
	end
	frame:GetElement("__parent.mats"):SetQuery(private.matsQuery, true)
end

function private.MatItemNameQueryFilter(record, filter)
	local name = TSMAPI_FOUR.Item.GetName(record:GetField("itemString"))
	return strmatch(strlower(name), filter)
end
