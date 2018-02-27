-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local Shopping = TSM.UI.AuctionUI:NewPackage("Shopping")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = {
	singleItemSearchType = "normal",
	fsm = nil,
	rarityList = nil,
	frame = nil,
	hasLastScan = false,
	contentPath = "selection",
	selectedGroups = {},
	groupSearch = "",
}
local SINGLE_ITEM_SEARCH_TYPES = {
	normal = "|cffffd839" .. L["Normal"] .. "|r",
	crafting = "|cffffd839" .. L["Crafting"] .. "|r"
}
local SINGLE_ITEM_SEARCH_TYPES_ORDER = { "normal", "crafting" }
local LINE_MARGIN = { bottom = 16 }
local MAX_ITEM_LEVEL = 1000
local DEFAULT_DIVIDED_CONTAINER_CONTEXT = {
	leftWidth = 272,
}
local function NoOp()
	-- do nothing - what did you expect?
end
-- TODO: this should eventually go in the saved variables
private.dividedContainerContext = {}



-- ============================================================================
-- Module Functions
-- ============================================================================

function Shopping.OnInitialize()
	TSM.UI.AuctionUI.RegisterTopLevelPage("Shopping", "iconPack.24x24/Shopping", private.GetShoppingFrame)
	private.FSMCreate()

	-- setup hooks to shift-click on items to quickly search for them
	local function HandleShiftClickItem(origFunc, link)
		local putIntoChat = origFunc(link)
		if putIntoChat or not private.frame then
			return putIntoChat
		end
		local name = TSMAPI_FOUR.Item.GetName(link)
		if name then
			private.frame:SetPath("selection")
			private.StartFilterSearchHelper(private.frame, name .. "/exact")
			return true
		end
		return putIntoChat
	end
	local origHandleModifiedItemClick = HandleModifiedItemClick
	HandleModifiedItemClick = function(link)
		return HandleShiftClickItem(origHandleModifiedItemClick, link)
	end
	local origChatEdit_InsertLink = ChatEdit_InsertLink
	ChatEdit_InsertLink = function(link)
		return HandleShiftClickItem(origChatEdit_InsertLink, link)
	end
end

function Shopping.StartGatheringSearch(itemString, need, buyCallback)
	--TODO: crafting search and other gathering filters once implemented
	local name = TSMAPI_FOUR.Item.GetName(itemString)
	private.frame:SetPath("selection")
	private.StartFilterSearchHelper(private.frame, name .. "/exact/x" .. need, "matPrice", buyCallback, true)
end



-- ============================================================================
-- Shopping UI
-- ============================================================================

function private.GetShoppingFrame()
	if not private.hasLastScan then
		private.contentPath = "selection"
	end
	local frame = TSMAPI_FOUR.UI.NewElement("ViewContainer", "shopping")
		:SetNavCallback(private.GetShoppingContentFrame)
		:AddPath("selection")
		:AddPath("scan")
		:SetPath(private.contentPath)
		:SetScript("OnHide", private.FrameOnHide)
	private.frame = frame
	return frame
end

function private.GetShoppingContentFrame(viewContainer, path)
	private.contentPath = path
	if path == "selection" then
		return private.GetSelectionFrame()
	elseif path == "scan" then
		return private.GetScanFrame()
	else
		error("Unexpected path: "..tostring(path))
	end
end

function private.GetSelectionFrame()
	local frame = TSMAPI_FOUR.UI.NewElement("DividedContainer", "selection")
		:SetStyle("background", "#272727")
		:SetContextTable(private.dividedContainerContext, DEFAULT_DIVIDED_CONTAINER_CONTEXT)
		:SetMinWidth(250, 250)
		:SetLeftChild(TSMAPI_FOUR.UI.NewElement("Frame", "groupSelection")
			:SetLayout("VERTICAL")
			:SetStyle("padding", { top = 21 })
			:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "title")
				:SetLayout("HORIZONTAL")
				:SetStyle("height", 44)
				:SetStyle("padding", 12)
				:AddChild(TSMAPI_FOUR.UI.NewElement("SearchInput", "search")
					:SetText(private.groupSearch)
					:SetHintText(L["Search Groups"])
					:SetScript("OnTextChanged", private.GroupSearchOnTextChanged)
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "moreBtn")
					:SetStyle("width", 18)
					:SetStyle("height", 18)
					:SetStyle("margin", { left = 8 })
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
				:SetContextTable(TSM.db.profile.internalData.shoppingGroupTreeContext)
				:SetSearchString(private.groupSearch)
				:SetScript("OnGroupSelectionChanged", private.GroupTreeOnGroupSelectionChanged)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Texture", "line")
				:SetStyle("height", 2)
				:SetStyle("color", "#9d9d9d")
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("ActionButton", "scanBtn")
				:SetStyle("height", 26)
				:SetStyle("margin", 12)
				:SetText(L["RUN SHOPPING SCAN"])
				:SetDisabled(true)
				:SetScript("OnClick", private.ScanButtonOnClick)
			)
		)
		:SetRightChild(TSMAPI_FOUR.UI.NewElement("ViewContainer", "content")
			:SetNavCallback(private.GetSelectionContent)
			:AddPath("search", true)
			:AddPath("advanced")
		)
	local noGroupSelected = frame:GetElement("groupSelection.groupTree"):IsSelectionCleared(true)
	frame:GetElement("groupSelection.scanBtn"):SetDisabled(noGroupSelected)
	return frame
end

function private.GetSelectionContent(viewContainer, path)
	if path == "search" then
		return private.GetSelectionSearchFrame()
	elseif path == "advanced" then
		return private.GetAdvancedFrame()
	else
		error("Unexpected path: "..tostring(path))
	end
end

function private.GetSelectionSearchFrame()
	return TSMAPI_FOUR.UI.NewElement("ScrollFrame", "search")
		:SetStyle("padding", { top = 41, left = 8, right = 8, bottom = 8 })
		:AddChild(TSMAPI_FOUR.UI.NewElement("TabGroup", "buttons")
			:SetStyle("height", 152)
			:SetStyle("margin", { left = -8, right = -8 })
			:SetNavCallback(private.GetSearchesElement)
			:AddPath(L["Recent Searches"], true)
			:AddPath(L["Favorite Searches"])
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Texture", "line")
			:SetStyle("height", 2)
			:SetStyle("margin", { left = -8, right = -8 })
			:SetStyle("color", "#9d9d9d")
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "itemHeader")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 22)
			:SetStyle("margin", { top = 16, bottom = 4 })
			:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "text")
				:SetStyle("font", TSM.UI.Fonts.MontserratBold)
				:SetStyle("fontHeight", 16)
				:SetStyle("autoWidth", true)
				:SetText(L["Filter Shopping"])
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Dropdown", "dropdown")
				:SetStyle("width", 80)
				:SetStyle("height", 14)
				:SetStyle("margin", { left = 8 })
				:SetStyle("background", "#00000000")
				:SetStyle("border", "#00000000")
				:SetStyle("font", TSM.UI.Fonts.MontserratBold)
				:SetStyle("fontHeight", 11)
				:SetStyle("openFont", TSM.UI.Fonts.MontserratBold)
				:SetStyle("openFontHeight", 11)
				:SetDictionaryItems(SINGLE_ITEM_SEARCH_TYPES, SINGLE_ITEM_SEARCH_TYPES[private.singleItemSearchType], SINGLE_ITEM_SEARCH_TYPES_ORDER)
				:SetSettingInfo(private, "singleItemSearchType")
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Spacer", "spacer"))
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "text")
			:SetStyle("height", 14)
			:SetStyle("fontHeight", 11)
			:SetText(L["Use the field below to search the auction house by filter"])
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Input", "filterInput")
			:SetStyle("height", 26)
			:SetStyle("margin", { top = 16, bottom = 16 })
			:SetStyle("background", "#525252")
			:SetStyle("border", "#9d9d9d")
			:SetStyle("borderSize", 2)
			:SetStyle("fontHeight", 11)
			:SetStyle("textColor", "#e2e2e2")
			:SetStyle("hintJustifyH", "LEFT")
			:SetStyle("hintTextColor", "#e2e2e2")
			:SetHintText(L["Enter Filter"])
			:SetScript("OnEnterPressed", private.FilterSearchInputOnEnterPressed)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "advanced")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 18)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "textBtn")
				:SetStyle("font", TSM.UI.Fonts.MontserratBold)
				:SetStyle("fontHeight", 11)
				:SetStyle("autoWidth", true)
				:SetText(L["Advanced Item Search"])
				:SetScript("OnClick", private.AdvancedButtonOnClick)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "iconBtn")
				:SetStyle("width", 18)
				:SetStyle("height", 18)
				:SetStyle("backgroundTexturePack", "iconPack.18x18/Chevron/Collapsed")
				:SetScript("OnClick", private.AdvancedButtonOnClick)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Spacer", "spacer"))
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "text")
			:SetStyle("height", 22)
			:SetStyle("margin", { top = 27 })
			:SetStyle("font", TSM.UI.Fonts.MontserratBold)
			:SetStyle("fontHeight", 16)
			:SetText(L["Other Shopping Searches"])
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "buttonsLine1")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 26)
			:SetStyle("margin", { top = 16, bottom = 16 })
			:AddChild(TSMAPI_FOUR.UI.NewElement("ActionButton", "dealsBtn")
				:SetStyle("margin", { right = 16 })
				:SetText(L["GREAT DEALS SEARCH"])
				:SetDisabled(not TSM.Shopping.GreatDealsSearch.GetFilter())
				:SetScript("OnClick", private.DealsButtonOnClick)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("ActionButton", "vendorBtn")
				:SetText(L["VENDOR SEARCH"])
				:SetScript("OnClick", private.VendorButtonOnClick)
			)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "buttonsLine1")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 26)
			:AddChild(TSMAPI_FOUR.UI.NewElement("ActionButton", "disenchantBtn")
				:SetStyle("margin", { right = 16 })
				:SetText(L["DISENCHANT SEARCH"])
				:SetScript("OnClick", private.DisenchantButtonOnClick)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Spacer", "spacer"))
		)
end

function private.GetAdvancedFrame()
	if not private.rarityList then
		private.rarityList = {}
		for i = 1, 7 do
			tinsert(private.rarityList, _G["ITEM_QUALITY"..i.."_DESC"])
		end
	end
	return TSMAPI_FOUR.UI.NewElement("Frame", "search")
		:SetLayout("VERTICAL")
		:AddChild(TSMAPI_FOUR.UI.NewElement("ScrollFrame", "search")
			:SetStyle("padding", { top = 10, left = 10 })
			:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "header")
				:SetLayout("HORIZONTAL")
				:SetStyle("height", 46)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "backBtn")
					:SetStyle("width", 100)
					:SetStyle("padding", { left = -10 })
					:SetText("<  "..BACK)
					:SetScript("OnClick", private.AdvancedBackButtonOnClick)
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "title")
					:SetStyle("margin", { right = 100 })
					:SetStyle("fontHeight", 24)
					:SetStyle("justifyH", "CENTER")
					:SetText(L["Advanced Item Search"])
				)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Input", "filterInput")
				:SetStyle("height", 26)
				:SetStyle("margin", LINE_MARGIN)
				:SetHintText(L["Item Name Filter"])
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "level")
				:SetLayout("HORIZONTAL")
				:SetStyle("height", 26)
				:SetStyle("margin", LINE_MARGIN)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
					:SetStyle("autoWidth", true)
					:SetStyle("margin", { right = 10 })
					:SetText(L["Required Level Range:"])
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Slider", "slider")
					:SetRange(0, MAX_PLAYER_LEVEL)
				)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "itemLevel")
				:SetLayout("HORIZONTAL")
				:SetStyle("height", 26)
				:SetStyle("margin", LINE_MARGIN)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
					:SetStyle("autoWidth", true)
					:SetStyle("margin", { right = 10 })
					:SetText(L["Item Level Range:"])
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Slider", "slider")
					:SetRange(0, MAX_ITEM_LEVEL)
				)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "classAndSubClass")
				:SetLayout("HORIZONTAL")
				:SetStyle("height", 26)
				:SetStyle("margin", LINE_MARGIN)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "classLabel")
					:SetStyle("autoWidth", true)
					:SetStyle("margin", { right = 10 })
					:SetText(L["Item Class:"])
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Dropdown", "classDropdown")
					:SetStyle("height", 20)
					:SetItems(TSMAPI_FOUR.Item.GetItemClasses())
					:SetScript("OnSelectionChanged", private.ClassDropdownOnSelectionChanged)
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "subClassLabel")
					:SetStyle("autoWidth", true)
					:SetStyle("margin", { left = 20, right = 10 })
					:SetText(L["Item Subclass:"])
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Dropdown", "subClassDropdown")
					:SetStyle("height", 20)
					:SetDisabled(true)
					:SetItems(TSMAPI_FOUR.Item.GetItemClasses())
				)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "rarity")
				:SetLayout("HORIZONTAL")
				:SetStyle("height", 26)
				:SetStyle("margin", LINE_MARGIN)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
					:SetStyle("autoWidth", true)
					:SetStyle("margin", { right = 10 })
					:SetText(L["Minimum Rarity:"])
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Dropdown", "dropdown")
					:SetStyle("height", 20)
					:SetItems(private.rarityList)
				)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "quantity")
				:SetLayout("HORIZONTAL")
				:SetStyle("height", 26)
				:SetStyle("margin", LINE_MARGIN)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
					:SetStyle("autoWidth", true)
					:SetStyle("margin", { right = 10 })
					:SetText(L["Maximum Quantity to Buy:"])
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("InputNumeric", "input")
					:SetStyle("justifyH", "CENTER")
					:SetStyle("height", 20)
					:SetStyle("width", 80)
				)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "usableAndExact")
				:SetLayout("HORIZONTAL")
				:SetStyle("height", 26)
				:SetStyle("margin", LINE_MARGIN)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "usableLabel")
					:SetStyle("autoWidth", true)
					:SetStyle("margin", { right = 10 })
					:SetText(L["Search Usable Items Only?"])
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Toggle", "usableToggle")
					:SetStyle("width", 80)
					:SetStyle("height", 20)
					:AddOption(YES)
					:AddOption(NO, true)
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "exactLabel")
					:SetStyle("autoWidth", true)
					:SetStyle("margin", { left = 20, right = 10 })
					:SetText(L["Exact Match Only?"])
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Toggle", "exactToggle")
					:SetStyle("width", 80)
					:SetStyle("height", 20)
					:AddOption(YES)
					:AddOption(NO, true)
				)
			)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "buttons")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 53)
			:SetStyle("background", "#404040")
			:SetStyle("padding", { left = 10, right = 10})
			:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "startBtn")
				:SetStyle("height", 24)
				:SetStyle("padding", { right = 20 })
				:SetStyle("borderTexture", "Interface\\Addons\\TradeSkillMaster\\Media\\ButtonEdgeFrame.blp")
				:SetStyle("borderSize", 7)
				:SetText(L["Start Advanced Item Search"])
				:SetScript("OnClick", private.AdvancedStartOnClick)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "resetBtn")
				:SetStyle("height", 24)
				:SetStyle("width", 120)
				:SetText(L["Reset Filters"])
				:SetScript("OnClick", private.ResetButtonOnClick)
			)
		)
end

function private.GetSearchesElement(self, button)
	if button == L["Recent Searches"] then
		return TSMAPI_FOUR.UI.NewElement("SearchList", "list")
			:SetQuery(TSM.Shopping.SavedSearches.CreateRecentSearchesQuery())
			:SetEditButtonHidden(true)
			:SetScript("OnFavoriteChanged", private.SearchListOnFavoriteChanged)
			:SetScript("OnDelete", private.SearchListOnDelete)
			:SetScript("OnRowClick", private.SearchListOnRowClick)
	elseif button == L["Favorite Searches"] then
		return TSMAPI_FOUR.UI.NewElement("SearchList", "list")
			:SetQuery(TSM.Shopping.SavedSearches.CreateFavoriteSearchesQuery())
			:SetScript("OnFavoriteChanged", private.SearchListOnFavoriteChanged)
			:SetScript("OnNameChanged", private.SearchListOnNameChanged)
			:SetScript("OnDelete", private.SearchListOnDelete)
			:SetScript("OnRowClick", private.SearchListOnRowClick)
	else
		error("Unexpected button: "..tostring(button))
	end
end

function private.GetScanFrame()
	return TSMAPI_FOUR.UI.NewElement("Frame", "scan")
		:SetLayout("VERTICAL")
		:SetStyle("background", "#272727")
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "backFrame")
			:SetLayout("HORIZONTAL")
			:SetStyle("margin", { left = 8, top = 6, bottom = 4 })
			:SetStyle("height", 18)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "backIcon")
				:SetStyle("width", 18)
				:SetStyle("backgroundTexturePack", "iconPack.18x18/SideArrow")
				:SetStyle("backgroundTextureRotation", 180)
				:SetScript("OnClick", private.ScanBackButtonOnClick)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Spacer"))
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "searchText")
			:SetStyle("margin.left", 8)
			:SetStyle("margin.bottom", 2)
			:SetStyle("margin.top", 4)
			:SetStyle("height", 13)
			:SetStyle("font", TSM.UI.Fonts.MontserratBold)
			:SetStyle("fontHeight", 10)
			:SetText(L["CURRENT SEARCH"])
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "searchFrame")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 26)
			:SetStyle("margin.left", 8)
			:SetStyle("margin.right", 8)
			:SetStyle("margin.bottom", 8)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Input", "filterInput")
				:SetStyle("height", 26)
				:SetStyle("background", "#404040")
				:SetStyle("border", "#585858")
				:SetStyle("borderSize", 1)
				:SetStyle("fontHeight", 11)
				:SetStyle("textColor", "#e2e2e2")
				:SetStyle("hintJustifyH", "LEFT")
				:SetStyle("hintTextColor", "#e2e2e2")
				:SetHintText(L["Enter Filter"])
				:SetScript("OnEnterPressed", private.ScanFilterInputOnEnterPressed)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("ActionButton", "rescanBtn")
				:SetStyle("width", 150)
				:SetStyle("margin.left", 8)
				:SetText(L["RESCAN"])
				:SetScript("OnClick", private.RescanBtnOnClick)
			)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Texture", "line")
			:SetStyle("height", 2)
			:SetStyle("color", "#9d9d9d")
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("ShoppingScrollingTable", "auctions")
			:SetScript("OnSelectionChanged", private.AuctionsOnSelectionChanged)
			:SetScript("OnPostButtonClick", private.AuctionsOnPostButtonClick)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "bottom")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 38)
			:SetStyle("padding.bottom", -2)
			:SetStyle("padding.top", 6)
			:SetStyle("background", "#363636")
			:AddChild(TSMAPI_FOUR.UI.NewElement("ProgressBar", "progressBar")
				:SetStyle("margin.right", 8)
				:SetStyle("height", 28)
				:SetProgress(0)
				:SetProgressIconHidden(false)
				:SetText(L["Starting Scan..."])
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("ActionButton", "bidBtn")
				:SetStyle("width", 107)
				:SetStyle("height", 26)
				:SetStyle("margin.right", 8)
				:SetStyle("iconTexturePack", "iconPack.14x14/Bid")
				:SetText(strupper(BID))
				:SetDisabled(true)
				:SetScript("OnClick", private.BidButtonOnClick)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("ActionButton", "buyoutBtn", "TSMShoppingBuyoutBtn")
				:SetStyle("width", 107)
				:SetStyle("height", 26)
				:SetStyle("margin.right", 8)
				:SetStyle("iconTexturePack", "iconPack.14x14/Post")
				:SetText(strupper(BUYOUT))
				:SetDisabled(true)
				:SetScript("OnClick", private.BuyoutButtonOnClick)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("ActionButton", "stopBtn")
				:SetStyle("width", 107)
				:SetStyle("height", 26)
				:SetStyle("iconTexturePack", "iconPack.14x14/Stop")
				:SetText(L["STOP"])
				:SetDisabled(true)
				:SetScript("OnClick", private.StopButtonOnClick)
			)
		)
		:SetScript("OnUpdate", private.ScanFrameOnUpdate)
		:SetScript("OnHide", private.ScanFrameOnHide)
end

function private.PostDialogShow(baseFrame, record)
	local itemString = record:GetField("itemString")
	local undercut = record:GetField("seller") == UnitName("player") and 0 or 1
	local frame = TSMAPI_FOUR.UI.NewElement("Frame", "frame")
		:SetLayout("VERTICAL")
		:SetStyle("width", 300)
		:SetStyle("height", 250)
		:SetStyle("anchors", { { "CENTER" } })
		:SetStyle("background", "#2e2e2e")
		:SetStyle("border", "#e2e2e2")
		:SetStyle("borderSize", 2)
		:SetStyle("padding", 16)
		:SetMouseEnabled(true)
		:SetContext(record)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "title")
			:SetStyle("height", 44)
			:SetStyle("margin", { top = 8, bottom = 16 })
			:SetStyle("font", TSM.UI.Fonts.MontserratBold)
			:SetStyle("fontHeight", 18)
			:SetStyle("justifyH", "CENTER")
			:SetText(TSM.UI.GetColoredItemName(itemString))
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "quantity")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 16)
			:SetStyle("margin", { bottom = 8 })
			:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "desc")
				:SetStyle("font", TSM.UI.Fonts.MontserratBold)
				:SetStyle("fontHeight", 12)
				:SetStyle("textColor", "#e2e2e2")
				:SetStyle("autoWidth", true)
				:SetText(L["Stack / Quantity"] .. ":")
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("EditableText", "text")
				:SetStyle("font", TSM.UI.Fonts.RobotoMedium)
				:SetStyle("fontHeight", 12)
				:SetStyle("justifyH", "RIGHT")
				:SetText(format(L["%d of %d"], 1, record:GetField("stackSize")))
				:SetScript("OnValueChanged", private.StackQuantityTextOnValueChanged)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "editBtn")
				:SetStyle("width", 12)
				:SetStyle("height", 12)
				:SetStyle("margin", { left = 4 })
				:SetStyle("backgroundTexturePack", "iconPack.12x12/Edit")
				:SetScript("OnClick", private.PostEditBtnOnClick)
			)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "duration")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 24)
			:SetStyle("margin", { bottom = 16 })
			:AddChild(TSMAPI_FOUR.UI.NewElement("Toggle", "toggle")
				:SetStyle("height", 24)
				:SetStyle("border", "#e2e2e2")
				:SetStyle("textColor", "#e2e2e2")
				:SetStyle("selectedBackground", "#e2e2e2")
				:SetStyle("fontHeight", 12)
				:AddOption(AUCTION_DURATION_ONE)
				:AddOption(AUCTION_DURATION_TWO, true)
				:AddOption(AUCTION_DURATION_THREE)
			)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "bid")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 16)
			:SetStyle("margin", { bottom = 8 })
			:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "desc")
				:SetStyle("font", TSM.UI.Fonts.MontserratBold)
				:SetStyle("fontHeight", 12)
				:SetStyle("textColor", "#e2e2e2")
				:SetStyle("autoWidth", true)
				:SetText(L["Bid Price (stack)"] .. ":")
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("EditableText", "text")
				:SetStyle("font", TSM.UI.Fonts.RobotoMedium)
				:SetStyle("fontHeight", 12)
				:SetStyle("justifyH", "RIGHT")
				:SetText(TSMAPI_FOUR.Money.ToString(record:GetField("displayedBid") - undercut))
				:SetContext("bid")
				:SetScript("OnValueChanged", private.BidTextOnValueChanged)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "editBtn")
				:SetStyle("width", 12)
				:SetStyle("height", 12)
				:SetStyle("margin", { left = 4 })
				:SetStyle("backgroundTexturePack", "iconPack.12x12/Edit")
				:SetScript("OnClick", private.PostEditBtnOnClick)
			)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "buyout")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 16)
			:SetStyle("margin", { bottom = 8 })
			:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "desc")
				:SetStyle("font", TSM.UI.Fonts.MontserratBold)
				:SetStyle("fontHeight", 12)
				:SetStyle("textColor", "#e2e2e2")
				:SetStyle("autoWidth", true)
				:SetText(L["Buyout Price (stack)"] .. ":")
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("EditableText", "text")
				:SetStyle("font", TSM.UI.Fonts.RobotoMedium)
				:SetStyle("fontHeight", 12)
				:SetStyle("justifyH", "RIGHT")
				:SetText(TSMAPI_FOUR.Money.ToString(record:GetField("buyout") - undercut))
				:SetContext("buyout")
				:SetScript("OnValueChanged", private.BuyoutTextOnValueChanged)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "editBtn")
				:SetStyle("width", 12)
				:SetStyle("height", 12)
				:SetStyle("margin", { left = 4 })
				:SetStyle("backgroundTexturePack", "iconPack.12x12/Edit")
				:SetScript("OnClick", private.PostEditBtnOnClick)
			)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Spacer", "spacer"))
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "buttons")
			:SetLayout("HORIZONTAL")
			:AddChild(TSMAPI_FOUR.UI.NewElement("ActionButton", "confirmBtn")
				:SetStyle("margin", { right = 16 })
				:SetStyle("height", 26)
				:SetText(L["POST"])
				:SetScript("OnClick", private.PostButtonOnClick)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "confirmBtn")
				:SetStyle("width", 60)
				:SetStyle("height", 26)
				:SetText(CLOSE)
				:SetScript("OnClick", private.PostDialogCloseBtnOnClick)
			)
		)
	baseFrame:ShowDialogFrame(frame)
end



-- ============================================================================
-- Local Script Handlers
-- ============================================================================

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
	baseFrame:GetElement("content.shopping.selection.groupSelection.groupTree"):SelectAll()
	baseFrame:HideDialog()
end

function private.DeselectAllBtnOnClick(button)
	local baseFrame = button:GetBaseElement()
	baseFrame:GetElement("content.shopping.selection.groupSelection.groupTree"):DeselectAll()
	baseFrame:HideDialog()
end

function private.GroupTreeOnGroupSelectionChanged(groupTree, selectedGroups)
	local scanBtn = groupTree:GetElement("__parent.scanBtn")
	scanBtn:SetDisabled(not next(selectedGroups))
	scanBtn:Draw()
end

function private.FrameOnHide(frame)
	assert(frame == private.frame)
	private.frame = nil
end

function private.GroupTreeGetList(groups, headerNameLookup)
	TSM.UI.ApplicationGroupTreeGetGroupList(groups, headerNameLookup, "Shopping")
end

function private.ScanButtonOnClick(button)
	if not TSM.UI.AuctionUI.StartingScan("Shopping") then
		button:SetPressed(false)
		button:Draw()
		return
	end
	wipe(private.selectedGroups)
	for _, groupPath in button:GetElement("__parent.groupTree"):SelectedGroupsIterator() do
		if groupPath ~= "" and not strmatch(groupPath, "^`") then
			tinsert(private.selectedGroups, groupPath)
		end
	end

	button:GetParentElement():GetParentElement():GetParentElement():SetPath("scan", true)
	local threadId, marketValueFunc = TSM.Shopping.GroupSearch.GetScanContext()
	private.fsm:ProcessEvent("EV_START_SCAN", threadId, marketValueFunc, NoOp, "", private.selectedGroups)
end

function private.SearchListOnFavoriteChanged(_, dbRow, isFavorite)
	TSM.Shopping.SavedSearches.SetSearchIsFavorite(dbRow, isFavorite)
end

function private.SearchListOnNameChanged(_, dbRow, newName)
	TSM.Shopping.SavedSearches.RenameSearch(dbRow, newName)
end

function private.SearchListOnDelete(_, dbRow)
	TSM.Shopping.SavedSearches.DeleteSearch(dbRow)
end

function private.SearchListOnRowClick(searchList, dbRow)
	local viewContainer = searchList:GetParentElement():GetParentElement():GetParentElement():GetParentElement():GetParentElement()
	private.StartFilterSearchHelper(viewContainer, dbRow:GetField("filter"))
end

function private.AdvancedButtonOnClick(button)
	button:GetParentElement():GetParentElement():GetParentElement():SetPath("advanced", true)
end

function private.AdvancedBackButtonOnClick(button)
	button:GetParentElement():GetParentElement():GetParentElement():GetParentElement():SetPath("search", true)
end

function private.ClassDropdownOnSelectionChanged(dropdown, selection)
	local subClassDropdown = dropdown:GetElement("__parent.subClassDropdown")
	if selection then
		subClassDropdown:SetItems(TSMAPI_FOUR.Item.GetItemSubClasses(selection))
		subClassDropdown:SetDisabled(false)
		subClassDropdown:SetSelection(nil)
	else
		subClassDropdown:SetDisabled(true)
		subClassDropdown:SetSelection(nil)
	end
end

function private.ResetButtonOnClick(button)
	local searchFrame = button:GetElement("__parent.__parent.search")
	searchFrame:GetElement("filterInput"):SetText("")
	searchFrame:GetElement("level.slider"):SetValue(0, MAX_PLAYER_LEVEL)
	searchFrame:GetElement("itemLevel.slider"):SetValue(0, MAX_ITEM_LEVEL)
	searchFrame:GetElement("classAndSubClass.classDropdown"):SetSelection(nil)
	searchFrame:GetElement("classAndSubClass.subClassDropdown"):SetSelection(nil)
	searchFrame:GetElement("rarity.dropdown"):SetSelection(nil)
	searchFrame:GetElement("quantity.input"):SetText("")
	searchFrame:GetElement("usableAndExact.usableToggle"):SetOption(NO)
	searchFrame:GetElement("usableAndExact.exactToggle"):SetOption(NO)
	searchFrame:Draw()
end

function private.AdvancedStartOnClick(button)
	local searchFrame = button:GetElement("__parent.__parent.search")
	local filterParts = TSMAPI_FOUR.Util.AcquireTempTable()

	tinsert(filterParts, strtrim(searchFrame:GetElement("filterInput"):GetText()))

	local levelMin, levelMax = searchFrame:GetElement("level.slider"):GetValue()
	if levelMin ~= 0 or levelMax ~= MAX_PLAYER_LEVEL then
		tinsert(filterParts, levelMin)
		tinsert(filterParts, levelMax)
	end

	local itemLevelMin, itemLevelMax = searchFrame:GetElement("itemLevel.slider"):GetValue()
	if itemLevelMin ~= 0 or itemLevelMax ~= MAX_ITEM_LEVEL then
		tinsert(filterParts, itemLevelMin)
		tinsert(filterParts, itemLevelMax)
	end

	local class = searchFrame:GetElement("classAndSubClass.classDropdown"):GetSelection()
	if class then
		tinsert(filterParts, class)
	end

	local subClass = searchFrame:GetElement("classAndSubClass.subClassDropdown"):GetSelection()
	if subClass then
		tinsert(filterParts, subClass)
	end

	local rarity = searchFrame:GetElement("rarity.dropdown"):GetSelection()
	if rarity then
		tinsert(filterParts, rarity)
	end

	local quantity = tonumber(searchFrame:GetElement("quantity.input"):GetText())
	if quantity then
		tinsert(filterParts, "x"..quantity)
	end

	if searchFrame:GetElement("usableAndExact.usableToggle"):GetValue() == YES then
		tinsert(filterParts, "usable")
	end

	if searchFrame:GetElement("usableAndExact.exactToggle"):GetValue() == YES then
		tinsert(filterParts, "exact")
	end

	local filter = table.concat(filterParts, "/")
	TSMAPI_FOUR.Util.ReleaseTempTable(filterParts)
	local viewContainer = searchFrame:GetParentElement():GetParentElement():GetParentElement():GetParentElement()
	private.StartFilterSearchHelper(viewContainer, filter)
end

function private.FilterSearchInputOnEnterPressed(input)
	local filter = strtrim(input:GetText())
	if filter == "" then
		return
	end
	local viewContainer = input:GetParentElement():GetParentElement():GetParentElement():GetParentElement()
	private.StartFilterSearchHelper(viewContainer, filter)
end

function private.FilterSearchButtonOnClick(button)
	private.FilterSearchInputOnEnterPressed(button:GetElement("__parent.filterInput"))
end

function private.StartFilterSearchHelper(viewContainer, filter, pctSource, buyCallback, isSpecial)
	if not TSM.UI.AuctionUI.StartingScan("Shopping") then
		return
	end
	viewContainer:SetPath("scan", true)
	local threadId, marketValueFunc = TSM.Shopping.FilterSearch.GetScanContext(pctSource, isSpecial)
	private.fsm:ProcessEvent("EV_START_SCAN", threadId, marketValueFunc, buyCallback or NoOp, filter, filter)
end

function private.DealsButtonOnClick(button)
	button:SetPressed(false)
	button:Draw()
	local viewContainer = button:GetParentElement():GetParentElement():GetParentElement():GetParentElement():GetParentElement()
	private.StartFilterSearchHelper(viewContainer, TSM.Shopping.GreatDealsSearch.GetFilter(), nil, nil, true)
end

function private.VendorButtonOnClick(button)
	button:SetPressed(false)
	button:Draw()
	if not TSM.UI.AuctionUI.StartingScan("Shopping") then
		return
	end
	button:GetParentElement():GetParentElement():GetParentElement():GetParentElement():GetParentElement():SetPath("scan", true)
	local threadId, marketValueFunc = TSM.Shopping.VendorSearch.GetScanContext()
	private.fsm:ProcessEvent("EV_START_SCAN", threadId, marketValueFunc, NoOp, L["Vendor Search"])
end

function private.DisenchantButtonOnClick(button)
	button:SetPressed(false)
	button:Draw()
	if not TSM.UI.AuctionUI.StartingScan("Shopping") then
		return
	end
	button:GetParentElement():GetParentElement():GetParentElement():GetParentElement():GetParentElement():SetPath("scan", true)
	local threadId, marketValueFunc = TSM.Shopping.DisenchantSearch.GetScanContext()
	private.fsm:ProcessEvent("EV_START_SCAN", threadId, marketValueFunc, NoOp, L["Disenchant Search"])
end

function private.ScanBackButtonOnClick(button)
	local baseFrame = button:GetBaseElement()
	baseFrame:SetStyle("bottomPadding", nil)
	baseFrame:Draw()
	button:GetParentElement():GetParentElement():GetParentElement():SetPath("selection", true)
end

function private.AuctionsOnSelectionChanged()
	private.fsm:ProcessEvent("EV_AUCTION_SELECTION_CHANGED")
end

function private.AuctionsOnPostButtonClick(_, record)
	private.fsm:ProcessEvent("EV_POST_BUTTON_CLICK", record)
end

function private.BidButtonOnClick(button)
	button:SetPressed(false)
	button:Draw()
	private.fsm:ProcessEvent("EV_BID_AUCTION")
end

function private.BuyoutButtonOnClick(button)
	button:SetPressed(false)
	button:Draw()
	private.fsm:ProcessEvent("EV_BUY_AUCTION")
end

function private.StopButtonOnClick(button)
	button:SetPressed(false)
	button:Draw()
	private.fsm:ProcessEvent("EV_STOP_SCAN")
end

function private.ScanFrameOnUpdate(frame)
	frame:SetScript("OnUpdate", nil)
	local baseFrame = frame:GetBaseElement()
	baseFrame:SetStyle("bottomPadding", 38)
	baseFrame:Draw()
	private.fsm:ProcessEvent("EV_SCAN_FRAME_SHOWN", frame)
end

function private.ScanFrameOnHide(frame)
	private.fsm:ProcessEvent("EV_SCAN_FRAME_HIDDEN")
end

function private.PostEditBtnOnClick(button)
	button:GetElement("__parent.text"):SetEditing(true)
end

function private.BidTextOnValueChanged(text, value)
	value = TSMAPI_FOUR.Money.FromString(value)
	if value then
		text:SetText(TSMAPI_FOUR.Money.ToString(value))
	end
	text:Draw()
end

function private.BuyoutTextOnValueChanged(text, value)
	value = TSMAPI_FOUR.Money.FromString(value)
	if value then
		text:SetText(TSMAPI_FOUR.Money.ToString(value))
	end
	text:Draw()
end

function private.StackQuantityTextOnValueChanged(text, value)
	local matchStr = gsub(L["%d of %d"], "%%d", "(%%d+)")
	local num, stackSize = strmatch(value, matchStr)
	num = tonumber(num)
	stackSize = tonumber(stackSize)
	if num and stackSize then
		text:SetText(format(L["%d of %d"], num, stackSize))
	end
	text:Draw()
end

function private.PostButtonOnClick(button)
	local frame = button:GetParentElement():GetParentElement()
	local matchStr = gsub(L["%d of %d"], "%%d", "(%%d+)")
	local num, stackSize = strmatch(frame:GetElement("quantity.text"):GetText(), matchStr)
	num = tonumber(num)
	stackSize = tonumber(stackSize)
	local bid = TSMAPI_FOUR.Money.FromString(frame:GetElement("bid.text"):GetText())
	local buyout = TSMAPI_FOUR.Money.FromString(frame:GetElement("buyout.text"):GetText())
	local postTime = frame:GetElement("duration.toggle"):GetValue()
	if postTime == AUCTION_DURATION_ONE then
		postTime = 1
	elseif postTime == AUCTION_DURATION_TWO then
		postTime = 2
	elseif postTime == AUCTION_DURATION_THREE then
		postTime = 3
	else
		error("Invalid post time")
	end

	local postBag, postSlot = nil, nil
	for _, bag, slot, itemString, quantity in TSMAPI_FOUR.Inventory.BagIterator() do
		if not postBag and not postSlot and itemString == frame:GetContext():GetField("itemString") then
			postBag = bag
			postSlot = slot
		end
	end
	if postBag and postSlot then
		-- need to set the duration in the default UI to avoid Blizzard errors
		AuctionFrameAuctions.duration = postTime
		ClearCursor()
		PickupContainerItem(postBag, postSlot)
		ClickAuctionSellItemButton(AuctionsItemButton, "LeftButton")
		StartAuction(bid, buyout, postTime, stackSize, num)
		ClearCursor()
	end
	frame:GetBaseElement():HideDialog()
end

function private.PostDialogCloseBtnOnClick(button)
	button:GetBaseElement():HideDialog()
end

function private.ScanFilterInputOnEnterPressed(input)
	local filter = strtrim(input:GetText())
	if filter == "" then
		return
	end
	local viewContainer = input:GetParentElement():GetParentElement():GetParentElement()
	viewContainer:SetPath("selection")
	private.StartFilterSearchHelper(viewContainer, filter)
end

function private.RescanBtnOnClick(button)
	button:SetPressed(false)
	button:Draw()
	if not TSM.UI.AuctionUI.StartingScan("Shopping") then
		return
	end
	private.fsm:ProcessEvent("EV_RESCAN_CLICKED")
end



-- ============================================================================
-- FSM
-- ============================================================================

function private.FSMCreate()
	local fsmContext = {
		db = TSMAPI_FOUR.Auction.NewDatabase(),
		scanFrame = nil,
		scanName = "",
		scanThreadId = nil,
		marketValueFunc = nil,
		auctionScan = nil,
		query = nil,
		progress = 0,
		progressText = L["Starting Scan..."],
		bidDisabled = true,
		buyoutDisabled = true,
		stopDisabled = true,
		findHash = nil,
		findAuction = nil,
		findResult = nil,
		numFound = 0,
		numBought = 0,
		numBid = 0,
		numConfirmed = 0,
		scanContext = nil,
		buyCallback = nil
	}
	TSMAPI_FOUR.Event.Register("CHAT_MSG_SYSTEM", private.FSMMessageEventHandler)
	TSMAPI_FOUR.Event.Register("UI_ERROR_MESSAGE", private.FSMMessageEventHandler)
	TSMAPI_FOUR.Event.Register("AUCTION_HOUSE_CLOSED", function()
		private.fsm:ProcessEvent("EV_AUCTION_HOUSE_CLOSED")
	end)
	local function UpdateScanFrame(context)
		if not context.scanFrame then
			return
		end
		context.scanFrame:GetElement("searchFrame.filterInput"):SetText(context.scanName)
		local bottom = context.scanFrame:GetElement("bottom")
		bottom:GetElement("bidBtn"):SetDisabled(context.bidDisabled)
		bottom:GetElement("buyoutBtn"):SetDisabled(context.buyoutDisabled)
		bottom:GetElement("stopBtn"):SetDisabled(context.stopDisabled)
		bottom:GetElement("progressBar"):SetProgress(context.progress)
			:SetText(context.progressText or "")
			:SetProgressIconHidden(context.progress == 1 or (context.findResult and context.numBought + context.numBid == context.numConfirmed))
		local auctionList = context.scanFrame:GetElement("auctions")
			:SetContext(context.auctionScan)
			:SetQuery(context.query)
			:SetMarketValueFunction(context.marketValueFunc)
			:SetSelectionDisabled(context.numBought + context.numBid ~= context.numConfirmed)
		if context.findAuction and not auctionList:GetSelectedRecord() then
			auctionList:SetSelection(context.findAuction)
		end
		context.scanFrame:Draw()
	end
	private.fsm = TSMAPI_FOUR.FSM.New("SHOPPING")
		:AddState(TSMAPI_FOUR.FSM.NewState("ST_INIT")
			:SetOnEnter(function(context, ...)
				private.hasLastScan = false
				context.db:Truncate()
				context.scanName = ""
				if context.scanThreadId then
					TSMAPI_FOUR.Thread.Kill(context.scanThreadId)
					context.scanThreadId = nil
				end
				if context.query then
					context.query:Release()
				end
				if context.scanContext then
					TSMAPI_FOUR.Util.ReleaseTempTable(context.scanContext)
					context.scanContext = nil
				end
				context.query = nil
				context.marketValueFunc = nil
				context.progress = 0
				context.progressText = L["Starting Scan..."]
				context.bidDisabled = true
				context.buyoutDisabled = true
				context.stopDisabled = true
				context.findHash = nil
				context.findAuction = nil
				context.findResult = nil
				context.numFound = 0
				context.numBought = 0
				context.numBid = 0
				context.numConfirmed = 0
				if context.auctionScan then
					context.auctionScan:Release()
					context.auctionScan = nil
				end
				if ... then
					return "ST_STARTING_SCAN", ...
				elseif context.scanFrame then
					context.scanFrame:GetParentElement():SetPath("selection", true)
					context.scanFrame = nil
				end
				TSM.UI.AuctionUI.EndedScan("Shopping")
			end)
			:AddTransition("ST_INIT")
			:AddTransition("ST_STARTING_SCAN")
		)
		:AddState(TSMAPI_FOUR.FSM.NewState("ST_STARTING_SCAN")
			:SetOnEnter(function(context, scanThreadId, marketValueFunc, buyCallback, scanName, ...)
				context.scanContext = TSMAPI_FOUR.Util.AcquireTempTable(scanThreadId, marketValueFunc, buyCallback, scanName, ...)
				private.hasLastScan = true
				context.scanThreadId = scanThreadId
				context.marketValueFunc = marketValueFunc
				context.scanName = scanName
				context.buyCallback = buyCallback
				context.auctionScan = TSMAPI_FOUR.Auction.NewAuctionScan(context.db)
					:SetResolveSellers(true)
					:SetScript("OnProgressUpdate", private.FSMAuctionScanOnProgressUpdate)
				context.query = context.db:NewQuery()
				context.stopDisabled = false
				UpdateScanFrame(context)
				TSMAPI_FOUR.Thread.SetCallback(context.scanThreadId, private.FSMScanCallback)
				TSMAPI_FOUR.Thread.Start(context.scanThreadId, context.auctionScan, ...)
				return "ST_SCANNING"
			end)
			:AddTransition("ST_SCANNING")
		)
		:AddState(TSMAPI_FOUR.FSM.NewState("ST_SCANNING")
			:AddTransition("ST_UPDATING_SCAN_PROGRESS")
			:AddTransition("ST_RESULTS")
			:AddTransition("ST_INIT")
			:AddEvent("EV_SCAN_PROGRESS_UPDATE", TSMAPI_FOUR.FSM.SimpleTransitionEventHandler("ST_UPDATING_SCAN_PROGRESS"))
			:AddEvent("EV_SCAN_COMPLETE", function(context)
				TSM.UI.AuctionUI.EndedScan("Shopping")
				if context.scanFrame then
					context.scanFrame:GetElement("auctions"):ExpandSingleResult()
				end
				return "ST_RESULTS"
			end)
			:AddEvent("EV_SCAN_FAILED", TSMAPI_FOUR.FSM.SimpleTransitionEventHandler("ST_INIT"))
			:AddEvent("EV_STOP_SCAN", TSMAPI_FOUR.FSM.SimpleTransitionEventHandler("ST_RESULTS"))
			:AddEvent("EV_RESCAN_CLICKED", function(context)
				if context.scanFrame then
					local viewContainer = context.scanFrame:GetParentElement()
					viewContainer:SetPath("selection", true)
					viewContainer:SetPath("scan", true)
					context.scanFrame = viewContainer:GetElement("scan")
				end
				local scanContext = context.scanContext
				context.scanContext = nil
				return "ST_INIT", TSMAPI_FOUR.Util.UnpackAndReleaseTempTable(scanContext)
			end)
		)
		:AddState(TSMAPI_FOUR.FSM.NewState("ST_UPDATING_SCAN_PROGRESS")
			:SetOnEnter(function(context)
				local filtersScanned, numFilters, pagesScanned, numPages = context.auctionScan:GetProgress()
				local progress, text = nil, nil
				if filtersScanned == numFilters then
					progress = 1
					text = L["Done Scanning"]
				else
					if numPages == 0 then
						progress = filtersScanned / numFilters
						numPages = 1
					else
						progress = (filtersScanned + pagesScanned / numPages) / numFilters
					end
					text = format(L["Scanning %d / %d (Page %d / %d)"], filtersScanned + 1, numFilters, pagesScanned + 1, numPages)
				end
				context.progress = progress
				context.progressText = text
				UpdateScanFrame(context)
				return "ST_SCANNING"
			end)
			:AddTransition("ST_SCANNING")
		)
		:AddState(TSMAPI_FOUR.FSM.NewState("ST_RESULTS")
			:SetOnEnter(function(context)
				TSM.UI.AuctionUI.EndedScan("Shopping")
				TSMAPI_FOUR.Thread.Kill(context.scanThreadId)
				context.findAuction = nil
				context.findResult = nil
				context.numFound = 0
				context.numBought = 0
				context.numBid = 0
				context.numConfirmed = 0
				context.progress = 1
				context.progressText = L["Done Scanning"]
				context.bidDisabled = true
				context.buyoutDisabled = true
				context.stopDisabled = true
				UpdateScanFrame(context)
				if context.scanFrame and context.scanFrame:GetElement("auctions"):GetSelectedRecord() and TSM.UI.AuctionUI.StartingScan("Shopping") then
					return "ST_FINDING_AUCTION"
				end
			end)
			:AddTransition("ST_FINDING_AUCTION")
			:AddTransition("ST_INIT")
			:AddEvent("EV_AUCTION_SELECTION_CHANGED", function(context)
				assert(context.scanFrame)
				if context.scanFrame:GetElement("auctions"):GetSelectedRecord() and TSM.UI.AuctionUI.StartingScan("Shopping") then
					return "ST_FINDING_AUCTION"
				end
			end)
			:AddEvent("EV_POST_BUTTON_CLICK", function(context, record)
				private.PostDialogShow(context.scanFrame:GetBaseElement(), record)
			end)
			:AddEvent("EV_RESCAN_CLICKED", function(context)
				if context.scanFrame then
					local viewContainer = context.scanFrame:GetParentElement()
					viewContainer:SetPath("selection", true)
					viewContainer:SetPath("scan", true)
					context.scanFrame = viewContainer:GetElement("scan")
				end
				local scanContext = context.scanContext
				context.scanContext = nil
				return "ST_INIT", TSMAPI_FOUR.Util.UnpackAndReleaseTempTable(scanContext)
			end)
		)
		:AddState(TSMAPI_FOUR.FSM.NewState("ST_FINDING_AUCTION")
			:SetOnEnter(function(context)
				assert(context.scanFrame)
				context.findAuction = context.scanFrame:GetElement("auctions"):GetSelectedRecord()
				context.findHash = context.findAuction:GetField("hash")
				context.progress = 0
				context.progressText = L["Finding Selected Auction"]
				context.bidDisabled = true
				context.buyoutDisabled = true
				UpdateScanFrame(context)
				TSM.Shopping.SearchCommon.StartFindAuction(context.auctionScan, context.findAuction, private.FSMFindAuctionCallback, false)
			end)
			:SetOnExit(function(context)
				TSM.Shopping.SearchCommon.StopFindAuction()
			end)
			:AddTransition("ST_FINDING_AUCTION")
			:AddTransition("ST_RESULTS")
			:AddTransition("ST_AUCTION_FOUND")
			:AddTransition("ST_AUCTION_NOT_FOUND")
			:AddTransition("ST_INIT")
			:AddEvent("EV_AUCTION_FOUND", TSMAPI_FOUR.FSM.SimpleTransitionEventHandler("ST_AUCTION_FOUND"))
			:AddEvent("EV_AUCTION_NOT_FOUND", TSMAPI_FOUR.FSM.SimpleTransitionEventHandler("ST_AUCTION_NOT_FOUND"))
			:AddEvent("EV_AUCTION_SELECTION_CHANGED", function(context)
				assert(context.scanFrame)
				if context.scanFrame:GetElement("auctions"):GetSelectedRecord() and TSM.UI.AuctionUI.StartingScan("Shopping") then
					return "ST_FINDING_AUCTION"
				else
					return "ST_RESULTS"
				end
			end)
			:AddEvent("EV_POST_BUTTON_CLICK", function(context, record)
				private.PostDialogShow(context.scanFrame:GetBaseElement(), record)
			end)
			:AddEvent("EV_RESCAN_CLICKED", function(context)
				if context.scanFrame then
					local viewContainer = context.scanFrame:GetParentElement()
					viewContainer:SetPath("selection", true)
					viewContainer:SetPath("scan", true)
					context.scanFrame = viewContainer:GetElement("scan")
				end
				local scanContext = context.scanContext
				context.scanContext = nil
				return "ST_INIT", TSMAPI_FOUR.Util.UnpackAndReleaseTempTable(scanContext)
			end)
		)
		:AddState(TSMAPI_FOUR.FSM.NewState("ST_AUCTION_FOUND")
			:SetOnEnter(function(context, result)
				context.findResult = result
				context.numFound = min(#result, context.auctionScan:GetNumCanBuy(context.findAuction) or math.huge)
				assert(context.numBought == 0 and context.numBid == 0 and context.numConfirmed == 0)
				return "ST_BUYING"
			end)
			:AddTransition("ST_BUYING")
		)
		:AddState(TSMAPI_FOUR.FSM.NewState("ST_AUCTION_NOT_FOUND")
			:SetOnEnter(function(context)
				local link = context.findAuction:GetField("rawLink")
				context.auctionScan:DeleteRowFromDB(context.findAuction)
				TSM:Printf(L["Failed to find auction for %s, so removing it from the results."], link)
				return "ST_RESULTS"
			end)
			:AddTransition("ST_RESULTS")
		)
		:AddState(TSMAPI_FOUR.FSM.NewState("ST_BUYING")
			:SetOnEnter(function(context, removeRecord)
				if removeRecord then
					if context.scanFrame then
						-- move to the next auction
						context.scanFrame:GetElement("auctions"):SelectNextRecord()
					end
					-- remove the one we just bought
					context.auctionScan:DeleteRowFromDB(context.findAuction, true)
					context.findAuction = context.scanFrame and context.scanFrame:GetElement("auctions"):GetSelectedRecord()
				end
				local selection = context.scanFrame and context.scanFrame:GetElement("auctions"):GetSelectedRecord()
				local auctionSelected = selection and context.findHash == selection:GetField("hash")
				local numCanBuy = not auctionSelected and 0 or (context.numFound - context.numBought - context.numBid)
				local numConfirming = context.numBought + context.numBid - context.numConfirmed
				local progressText = nil
				if numConfirming == 0 and numCanBuy == 0 then
					-- we're done buying and confirming this batch - try to select the next auction
					return "ST_RESULTS"
				elseif numConfirming == 0 then
					-- we can still buy more
					progressText = format(L["Buy %d / %d"], context.numBought + context.numBid + 1, context.numFound)
				elseif numCanBuy == 0 then
					-- we're just confirming
					progressText = format(L["Confirming %d / %d"], context.numConfirmed + 1, context.numFound)
				else
					-- we can buy more while confirming
					progressText = format(L["Buy %d / %d (Confirming %d / %d)"], context.numBought + context.numBid + 1, context.numFound, context.numConfirmed + 1, context.numFound)
				end
				context.progress = context.numConfirmed / context.numFound
				context.progressText = progressText
				context.bidDisabled = context.numBought > 0 or numCanBuy == 0 or GetMoney() < selection:GetField("requiredBid")
				context.buyoutDisabled = context.numBid > 0 or numCanBuy == 0 or GetMoney() < selection:GetField("buyout")
				UpdateScanFrame(context)
			end)
			:AddTransition("ST_BUYING")
			:AddTransition("ST_PLACING_BUY")
			:AddTransition("ST_PLACING_BID")
			:AddTransition("ST_CONFIRMING_BUY")
			:AddTransition("ST_RESULTS")
			:AddTransition("ST_INIT")
			:AddEvent("EV_AUCTION_SELECTION_CHANGED", TSMAPI_FOUR.FSM.SimpleTransitionEventHandler("ST_BUYING"))
			:AddEvent("EV_BID_AUCTION", TSMAPI_FOUR.FSM.SimpleTransitionEventHandler("ST_PLACING_BID"))
			:AddEvent("EV_BUY_AUCTION", TSMAPI_FOUR.FSM.SimpleTransitionEventHandler("ST_PLACING_BUY"))
			:AddEvent("EV_MSG", function(context, msg)
				if not context.findAuction then
					return
				end
				if msg == LE_GAME_ERR_AUCTION_HIGHER_BID or msg == LE_GAME_ERR_ITEM_NOT_FOUND or msg == LE_GAME_ERR_AUCTION_BID_OWN or msg == LE_GAME_ERR_NOT_ENOUGH_MONEY then
					-- failed to buy an auction
					return "ST_CONFIRMING_BUY", false
				elseif msg == format(ERR_AUCTION_WON_S, context.findAuction:GetField("rawName")) or (context.numBid > 0 and msg == ERR_AUCTION_BID_PLACED) then
					-- bought an auction
					return "ST_CONFIRMING_BUY", true
				end
			end)
			:AddEvent("EV_POST_BUTTON_CLICK", function(context, record)
				private.PostDialogShow(context.scanFrame:GetBaseElement(), record)
			end)
			:AddEvent("EV_RESCAN_CLICKED", function(context)
				if context.scanFrame then
					local viewContainer = context.scanFrame:GetParentElement()
					viewContainer:SetPath("selection", true)
					viewContainer:SetPath("scan", true)
					context.scanFrame = viewContainer:GetElement("scan")
				end
				local scanContext = context.scanContext
				context.scanContext = nil
				return "ST_INIT", TSMAPI_FOUR.Util.UnpackAndReleaseTempTable(scanContext)
			end)
		)
		:AddState(TSMAPI_FOUR.FSM.NewState("ST_PLACING_BUY")
			:SetOnEnter(function(context)
				local index = tremove(context.findResult, #context.findResult)
				assert(index)
				if context.auctionScan:ValidateIndex(index, context.findAuction) then
					-- buy the auction
					PlaceAuctionBid("list", index, context.findAuction:GetField("buyout"))
					context.numBought = context.numBought + 1
				else
					TSM:Printf(L["Failed to buy auction of %s."], context.findAuction:GetField("rawLink"))
				end
				return "ST_BUYING"
			end)
			:AddTransition("ST_BUYING")
		)
		:AddState(TSMAPI_FOUR.FSM.NewState("ST_CONFIRMING_BUY")
			:SetOnEnter(function(context, success)
				if success then
					context.buyCallback(context.findAuction:GetField("itemString"), context.findAuction:GetField("stackSize"))
				else
					TSM:Printf(L["Failed to buy auction of %s."], context.findAuction:GetField("rawLink"))
				end
				context.numConfirmed = context.numConfirmed + 1
				return "ST_BUYING", true
			end)
			:AddTransition("ST_BUYING")
		)
		:AddState(TSMAPI_FOUR.FSM.NewState("ST_PLACING_BID")
			:SetOnEnter(function(context)
				local index = tremove(context.findResult, #context.findResult)
				assert(index)
				if context.auctionScan:ValidateIndex(index, context.findAuction) then
					-- bid on the auction
					PlaceAuctionBid("list", index, context.findAuction:GetField("minBid"))
					context.numBid = context.numBid + 1
				else
					TSM:Printf(L["Failed to bid on auction of %s."], context.findAuction:GetField("rawLink"))
				end
				return "ST_BUYING"
			end)
			:AddTransition("ST_BUYING")
		)
		:AddDefaultEvent("EV_START_SCAN", function(context, ...)
			return "ST_INIT", ...
		end)
		:AddDefaultEvent("EV_SCAN_FRAME_SHOWN", function(context, scanFrame)
			context.scanFrame = scanFrame
			UpdateScanFrame(context)
		end)
		:AddDefaultEvent("EV_SCAN_FRAME_HIDDEN", function(context)
			context.scanFrame = nil
		end)
		:AddDefaultEvent("EV_AUCTION_HOUSE_CLOSED", TSMAPI_FOUR.FSM.SimpleTransitionEventHandler("ST_INIT"))
		:Init("ST_INIT", fsmContext)
end

function private.FSMMessageEventHandler(_, msg)
	private.fsm:ProcessEvent("EV_MSG", msg)
end

function private.FSMAuctionScanOnProgressUpdate(auctionScan)
	private.fsm:ProcessEvent("EV_SCAN_PROGRESS_UPDATE")
end

function private.FSMScanCallback(success)
	if success then
		private.fsm:ProcessEvent("EV_SCAN_COMPLETE")
	else
		private.fsm:ProcessEvent("EV_SCAN_FAILED")
	end
end

function private.FSMFindAuctionCallback(result)
	if result then
		private.fsm:ProcessEvent("EV_AUCTION_FOUND", result)
	else
		private.fsm:ProcessEvent("EV_AUCTION_NOT_FOUND")
	end
end
