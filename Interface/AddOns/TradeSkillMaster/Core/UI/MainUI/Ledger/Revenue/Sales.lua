-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local Sales = TSM.MainUI.Ledger.Revenue:NewPackage("Sales")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = {}
local TIMELIST, TIMELIST_ORDER, RARITY_LIST, RARITY_LIST_ORDER = nil, nil, nil, nil
do
	TIMELIST = {[99]=L["All"], [0]=L["Today"], [1]=L["Yesterday"]}
	for _, days in TSMAPI_FOUR.Util.VarargIterator(7, 14, 30, 60) do
		TIMELIST[days] = format(L["Last %d Days"], days)
	end
	TIMELIST_ORDER = { 0, 1, 7, 14, 30, 60, 99 }
	RARITY_LIST = {[0]=L["None"]}
	for i = 1, 4 do
		RARITY_LIST[i] = _G[format("ITEM_QUALITY%d_DESC", i)]
	end
	RARITY_LIST_ORDER = { 0, 1, 2, 3, 4 }
end



-- ============================================================================
-- Module Functions
-- ============================================================================

function Sales.OnInitialize()
	TSM.MainUI.Ledger.Revenue.RegisterPage(L["Sales"], private.DrawSalesPage)
end



-- ============================================================================
-- Sales UI
-- ============================================================================

function private.DrawSalesPage()
	return TSMAPI_FOUR.UI.NewElement("Frame", "content")
		:SetLayout("VERTICAL")
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "firstRow")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 60)
			:SetStyle("margin", { top = 40 })
			:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "searchFrame")
				:SetLayout("VERTICAL")
				:SetStyle("margin", { bottom = 16 })
				:SetStyle("width", 200)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
					:SetStyle("fontHeight", 18)
					:SetText(L["SEARCH"])
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Input", "searchInput")
					:SetStyle("background", "#1ae2e2e2")
					:SetStyle("justifyH", "LEFT")
					:SetText("")
				)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "groupFrame")
				:SetLayout("VERTICAL")
				:SetStyle("margin", { bottom = 16, left = 20 })
				:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
					:SetStyle("textColor", "#e2e2e2")
					:SetStyle("fontHeight", 18)
					:SetStyle("justifyV", "CENTER")
					:SetStyle("width", 200)
					:SetText(L["GROUP"])
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Input", "groupInput")
					:SetStyle("background", "#1ae2e2e2")
				)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "typeFrame")
				:SetLayout("VERTICAL")
				:SetStyle("margin", { bottom = 16, left = 20, right = 20 })
				:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
					:SetStyle("textColor", "#e2e2e2")
					:SetStyle("fontHeight", 18)
					:SetStyle("justifyV", "CENTER")
					:SetStyle("width", 200)
					:SetText(L["TYPE"])
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Input", "typeInput")
					:SetStyle("background", "#1ae2e2e2")
					:SetStyle("justifyH", "LEFT")
					:SetText("")
				)
			)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "secondRow")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 60)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "rarityFrame")
				:SetLayout("VERTICAL")
				:SetStyle("margin", { bottom = 16 })
				:SetStyle("width", 200)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
					:SetStyle("textColor", "#e2e2e2")
					:SetStyle("fontHeight", 18)
					:SetStyle("justifyV", "CENTER")
					:SetStyle("width", 200)
					:SetText(L["RARITY"])
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Dropdown", "rarityInput")
					:SetDictionaryItems(RARITY_LIST, L["None"], RARITY_LIST_ORDER)
				)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "characterFrame")
				:SetLayout("VERTICAL")
				:SetStyle("margin", { bottom = 16, left = 20 })
				:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
					:SetStyle("textColor", "#e2e2e2")
					:SetStyle("fontHeight", 18)
					:SetStyle("justifyV", "CENTER")
					:SetStyle("width", 200)
					:SetText(L["CHARACTER"])
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Input", "characterInput")
					:SetStyle("background", "#1ae2e2e2")
					:SetStyle("justifyH", "LEFT")
					:SetText("")
				)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "timeFrameFrame")
				:SetLayout("VERTICAL")
				:SetStyle("margin", { bottom = 16, left = 20, right = 20 })
				:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
					:SetStyle("textColor", "#e2e2e2")
					:SetStyle("fontHeight", 18)
					:SetStyle("justifyV", "CENTER")
					:SetStyle("width", 200)
					:SetText(L["TIME FRAME"])
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Dropdown", "timeFrameInput")
					:SetDictionaryItems(TIMELIST, L["Last 30 Days"], TIMELIST_ORDER)
				)
			)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "accountingScrollingTableFrame")
			:SetLayout("VERTICAL")
			:SetStyle("margin", { right = 20 })
			:AddChild(TSMAPI_FOUR.UI.NewElement("Texture", "line")
				:SetStyle("height", 2)
				:SetStyle("color", "#9d9d9d")
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("ScrollingTable", "scrollingTable")
				:GetScrollingTableInfo()
				:NewColumn("item")
					:SetTitles(L["Item"])
					:SetJustifyH("LEFT")
					:Commit()
				:NewColumn("player")
					:SetTitles(L["Player"])
					:SetJustifyH("LEFT")
					:Commit()
				:NewColumn("type")
					:SetTitles(L["Type"])
					:SetWidth(80)
					:SetJustifyH("LEFT")
					:Commit()
				:NewColumn("stack")
					:SetTitles(L["Stack"])
					:SetWidth(40)
					:SetJustifyH("RIGHT")
					:Commit()
				:NewColumn("auctions")
					:SetTitles(L["Auctions"])
					:SetWidth(40)
					:SetJustifyH("RIGHT")
					:Commit()
				:NewColumn("perItem")
					:SetTitles(L["Per Item"])
					:SetJustifyH("RIGHT")
					:Commit()
				:NewColumn("timeFrame")
					:SetTitles(L["Time Frame"])
					:SetJustifyH("RIGHT")
					:Commit()
				:SetDefaultSort("item", true)
				:Commit()
			)
		)
end
