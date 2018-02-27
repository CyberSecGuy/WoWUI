-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local MyAuctions = TSM.UI.AuctionUI:NewPackage("MyAuctions")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = { fsm = nil, frame = nil }
local DURATION_LIST = {
	"Short (Under 30m)",
	"Medium (30m to 2h)",
	"Long (2h to 12h)",
	"Very Long (Over 12h)",
}



-- ============================================================================
-- Module Functions
-- ============================================================================

function MyAuctions.OnInitialize()
	private.FSMCreate()
	TSM.UI.AuctionUI.RegisterTopLevelPage(L["My Auctions"], "iconPack.24x24/Auctions", private.GetMyAuctionsFrame)

	-- setup hooks to shift-click on items to quickly filter for them
	local function HandleShiftClickItem(origFunc, link)
		local putIntoChat = origFunc(link)
		if putIntoChat or not private.frame then
			return putIntoChat
		end
		local name = TSMAPI_FOUR.Item.GetName(link)
		if name then
			private.frame:GetElement("headerFrame.keywordInput")
				:SetText(name)
				:Draw()
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



-- ============================================================================
-- MyAuctions UI
-- ============================================================================

function private.GetMyAuctionsFrame()
	local frame = TSMAPI_FOUR.UI.NewElement("Frame", "myAuctions")
		:SetLayout("VERTICAL")
		:SetStyle("background", "#272727")
		:SetStyle("padding", { top = 31 })
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "headerLabelFrame")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 14)
			:SetStyle("margin", { left = 16, right = 16, bottom = 4 })
			:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "durationLabel")
				:SetStyle("width", 245)
				:SetStyle("font", TSM.UI.Fonts.MontserratBold)
				:SetStyle("fontHeight", 10)
				:SetText(L["Filter Auctions by Duration"])
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "keywordLabel")
				:SetStyle("margin", { left = 16, right = 158 })
				:SetStyle("font", TSM.UI.Fonts.MontserratBold)
				:SetStyle("fontHeight", 10)
				:SetText(L["Filter Auctions by Keyword"])
			)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "headerFrame")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 26)
			:SetStyle("margin", { left = 16, right = 16, bottom = 16 })
			:AddChild(TSMAPI_FOUR.UI.NewElement("Dropdown", "durationDropdown")
				:SetStyle("width", 245)
				:SetItems(DURATION_LIST)
				:SetHintText(L["Select Duration"])
				:SetScript("OnSelectionChanged", private.FilterChanged)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Input", "keywordInput")
				:SetStyle("margin", { left = 16, right = 16 })
				:SetStyle("background", "#585858")
				:SetStyle("border", "#9d9d9d")
				:SetStyle("borderSize", 2)
				:SetStyle("textColor", "#e2e2e2")
				:SetStyle("hintTextColor", "#e2e2e2")
				:SetStyle("justifyH", "LEFT")
				:SetStyle("hintJustifyH", "LEFT")
				:SetHintText(L["Type Something"])
				:SetScript("OnTextChanged", private.FilterChanged)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("ActionButton", "clearfilterBtn")
				:SetStyle("width", 142)
				:SetText(L["Clear Filters"])
				:SetScript("OnClick", private.ClearFilterBtnOnClick)
			)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Texture", "line")
			:SetStyle("height", 2)
			:SetStyle("color", "#9d9d9d")
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("FastScrollingTable", "auctions")
			:GetScrollingTableInfo()
				:NewColumn("item")
					:SetTitles(L["Item Name"])
					:SetFont(TSM.UI.Fonts.FRIZQT)
					:SetFontHeight(12)
					:SetJustifyH("LEFT")
					:SetIconSize(12)
					:SetTextFunction(private.AuctionsGetItemText)
					:SetIconFunction(private.AuctionsGetItemIcon)
					:SetTooltipFunction(private.AuctionsGetItemTooltip)
					:Commit()
				:NewColumn("duration")
					:SetTitleIcon("iconPack.14x14/Clock")
					:SetWidth(80)
					:SetFont(TSM.UI.Fonts.MontserratRegular)
					:SetFontHeight(12)
					:SetJustifyH("CENTER")
					:SetTextFunction(private.AuctionsGetTimeLeftText)
					:Commit()
				:NewColumn("highbidder")
					:SetTitles(L["High Bidder"])
					:SetWidth(104)
					:SetFont(TSM.UI.Fonts.MontserratRegular)
					:SetFontHeight(12)
					:SetJustifyH("LEFT")
					:SetTextFunction(private.AuctionsGetHighBidderText)
					:Commit()
				:NewColumn("group")
					:SetTitles(L["Group"])
					:SetWidth(140)
					:SetFont(TSM.UI.Fonts.MontserratRegular)
					:SetFontHeight(12)
					:SetJustifyH("LEFT")
					:SetTextFunction(private.AuctionsGetGroupText)
					:Commit()
				:NewColumn("currentBid")
					:SetTitles(L["Bid"])
					:SetWidth(100)
					:SetFont(TSM.UI.Fonts.RobotoMedium)
					:SetFontHeight(12)
					:SetJustifyH("RIGHT")
					:SetTextFunction(private.AuctionsGetCurrentBidText)
					:Commit()
				:NewColumn("buyout")
					:SetTitles(L["Buyout"])
					:SetWidth(100)
					:SetFont(TSM.UI.Fonts.RobotoMedium)
					:SetFontHeight(12)
					:SetJustifyH("RIGHT")
					:SetTextFunction(private.AuctionsGetCurrentBuyoutText)
					:Commit()
				:Commit()
			:SetQuery(TSM.MyAuctions.GetQuery())
			:SetSelectionValidator(private.AuctionsValidateSelection)
			:SetScript("OnSelectionChanged", private.AuctionsOnSelectionChanged)
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
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "labels")
				:SetLayout("VERTICAL")
				:SetStyle("width", 100)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "sold")
					:SetStyle("font", TSM.UI.Fonts.MontserratMedium)
					:SetStyle("fontHeight", 11)
					:SetStyle("justifyH", "RIGHT")
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "posted")
					:SetStyle("font", TSM.UI.Fonts.MontserratMedium)
					:SetStyle("fontHeight", 11)
					:SetStyle("justifyH", "RIGHT")
				)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "values")
				:SetLayout("VERTICAL")
				:SetStyle("margin.right", 8)
				:SetStyle("width", 105)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "sold")
					:SetStyle("font", TSM.UI.Fonts.RobotoMedium)
					:SetStyle("fontHeight", 11)
					:SetStyle("justifyH", "RIGHT")
				)
				:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "posted")
					:SetStyle("font", TSM.UI.Fonts.RobotoMedium)
					:SetStyle("fontHeight", 11)
					:SetStyle("justifyH", "RIGHT")
				)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("ActionButton", "cancelBtn", "TSMCancelAuctionBtn")
				:SetStyle("width", 110)
				:SetStyle("height", 26)
				:SetStyle("margin.right", 8)
				:SetStyle("iconTexturePack", "iconPack.14x14/Close/Circle")
				:SetText(strupper(CANCEL))
				:SetDisabled(true)
				:SetScript("OnClick", private.CancelButtonOnClick)
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("ActionButton", "skipBtn")
				:SetStyle("width", 110)
				:SetStyle("height", 26)
				:SetStyle("iconTexturePack", "iconPack.14x14/Skip")
				:SetText(L["SKIP"])
				:SetDisabled(true)
				:SetScript("OnClick", private.SkipButtonOnClick)
			)
		)
		:SetScript("OnUpdate", private.FrameOnUpdate)
		:SetScript("OnHide", private.FrameOnHide)
	private.frame = frame
	return frame
end



-- ============================================================================
-- Local Script Handlers
-- ============================================================================

function private.FrameOnUpdate(frame)
	local baseFrame = frame:GetBaseElement()
	baseFrame:SetStyle("bottomPadding", 38)
	baseFrame:Draw()
	frame:SetScript("OnUpdate", nil)
	private.fsm:ProcessEvent("EV_FRAME_SHOWN", frame)
end

function private.FrameOnHide(frame)
	assert(frame == private.frame)
	private.frame = nil
	local baseFrame = frame:GetBaseElement()
	baseFrame:SetStyle("bottomPadding", nil)
	baseFrame:Draw()
	private.fsm:ProcessEvent("EV_FRAME_HIDDEN")
end

function private.FilterChanged(self)
	private.fsm:ProcessEvent("EV_FILTER_UPDATED")
end

function private.ClearFilterBtnOnClick(button)
	button:SetPressed(false)
	button:GetElement("__parent.keywordInput")
		:SetText("")
		:SetFocused(false)
	button:GetElement("__parent.durationDropdown")
		:SetOpen(false)
		:SetSelection(nil)
	button:GetParentElement():GetParentElement():Draw()
	private.fsm:ProcessEvent("EV_FILTER_UPDATED")
end

function private.AuctionsValidateSelection(_, record)
	return record:GetField("saleStatus") == 0
end

function private.AuctionsOnSelectionChanged()
	private.fsm:ProcessEvent("EV_SELECTION_CHANGED")
end

function private.CancelButtonOnClick(button)
	button:SetPressed(false)
	button:Draw()
	private.fsm:ProcessEvent("EV_CANCEL_CLICKED")
end

function private.SkipButtonOnClick(button)
	button:SetPressed(false)
	button:Draw()
	private.fsm:ProcessEvent("EV_SKIP_CLICKED")
end



-- ============================================================================
-- FSM
-- ============================================================================

function private.FSMCreate()
	local fsmContext = {
		frame = nil,
		currentSelectionIndex = nil,
	}
	TSM.MyAuctions.SetUpdateCallback(function()
		private.fsm:ProcessEvent("EV_DATA_UPDATED")
	end)
	local function UpdateFrame(context)
		if not context.frame then
			return
		end
		local auctions = context.frame:GetElement("auctions")
		-- select the next row we can cancel (or clear the selection otherwise)
		local data = TSM.MyAuctions.GetRecordByIndex(context.currentSelectionIndex or 0)
		while data and not TSM.MyAuctions.CanCancel(data:GetField("index")) do
			context.currentSelectionIndex = context.currentSelectionIndex - 1
			data = TSM.MyAuctions.GetRecordByIndex(context.currentSelectionIndex)
		end
		context.currentSelectionIndex = data and context.currentSelectionIndex or nil
		auctions:SetSelection(data)

		local hasFilter = false
		local query = TSM.MyAuctions.GetQuery()
		local headerFrame = context.frame:GetElement("headerFrame")
		local durationFilter = headerFrame:GetElement("durationDropdown"):GetSelection()
		if durationFilter then
			query:Equal("duration", TSMAPI_FOUR.Util.GetDistinctTableKey(DURATION_LIST, durationFilter))
			hasFilter = true
		end
		local keywordFilter = headerFrame:GetElement("keywordInput"):GetText()
		if keywordFilter ~= "" then
			query:Matches("itemName", TSMAPI_FOUR.Util.StrEscape(keywordFilter))
			hasFilter = true
		end
		auctions:SetQuery(query, true)
		local clearfilterBtn = headerFrame:GetElement("clearfilterBtn")
		clearfilterBtn:SetDisabled(not hasFilter)
		clearfilterBtn:Draw()

		local selectedRecord = auctions:GetSelection()
		local bottomFrame = context.frame:GetElement("bottom")
		bottomFrame:GetElement("cancelBtn"):SetDisabled(not selectedRecord)
		bottomFrame:GetElement("skipBtn"):SetDisabled(not selectedRecord)
		local numPending = TSM.MyAuctions.GetNumPending()
		local progressText = nil
		if numPending > 0 then
			progressText = format(L["Canceling %d Auctions..."], numPending)
		elseif selectedRecord then
			progressText = L["Ready to Cancel"]
		else
			progressText = L["Select Auction to Cancel"]
		end
		local progressBar = bottomFrame:GetElement("progressBar")
			:SetProgressIconHidden(numPending == 0)
			:SetText(progressText)
		local numPosted, numSold, postedGold, soldGold = TSM.MyAuctions.GetAuctionInfo()
		bottomFrame:GetElement("labels.sold")
			:SetFormattedText(L["Sold Auctions %s:"], "|cffffd839"..numSold.."|r")
		bottomFrame:GetElement("labels.posted")
			:SetFormattedText(L["Posted Auctions %s:"], "|cff6ebae6"..numPosted.."|r")
		bottomFrame:GetElement("values.sold")
			:SetText(TSMAPI_FOUR.Money.ToString(soldGold, "OPT_PAD", "OPT_SEP"))
		bottomFrame:GetElement("values.posted")
			:SetText(TSMAPI_FOUR.Money.ToString(postedGold, "OPT_PAD", "OPT_SEP"))
		bottomFrame:Draw()
	end
	private.fsm = TSMAPI_FOUR.FSM.New("MY_AUCTIONS")
		:AddState(TSMAPI_FOUR.FSM.NewState("ST_HIDDEN")
			:SetOnEnter(function(context)
				context.frame = nil
			end)
			:AddTransition("ST_HIDDEN")
			:AddTransition("ST_SHOWNING")
			:AddEvent("EV_FRAME_SHOWN", TSMAPI_FOUR.FSM.SimpleTransitionEventHandler("ST_SHOWNING"))
		)
		:AddState(TSMAPI_FOUR.FSM.NewState("ST_SHOWNING")
			:SetOnEnter(function(context, frame)
				context.frame = frame
				return "ST_SHOWN"
			end)
			:AddTransition("ST_SHOWN")
		)
		:AddState(TSMAPI_FOUR.FSM.NewState("ST_SHOWN")
			:SetOnEnter(function(context)
				UpdateFrame(context)
			end)
			:AddTransition("ST_HIDDEN")
			:AddTransition("ST_SHOWN")
			:AddTransition("ST_CANCELING")
			:AddTransition("ST_SKIPPING")
			:AddTransition("ST_CHANGING_SELECTION")
			:AddTransition("ST_UPDATING_FILTER")
			:AddEvent("EV_CANCEL_CLICKED", TSMAPI_FOUR.FSM.SimpleTransitionEventHandler("ST_CANCELING"))
			:AddEvent("EV_SKIP_CLICKED", TSMAPI_FOUR.FSM.SimpleTransitionEventHandler("ST_SKIPPING"))
			:AddEvent("EV_SELECTION_CHANGED", TSMAPI_FOUR.FSM.SimpleTransitionEventHandler("ST_CHANGING_SELECTION"))
			:AddEvent("EV_DATA_UPDATED", TSMAPI_FOUR.FSM.SimpleTransitionEventHandler("ST_SHOWN"))
			:AddEvent("EV_FILTER_UPDATED", TSMAPI_FOUR.FSM.SimpleTransitionEventHandler("ST_UPDATING_FILTER"))
		)
		:AddState(TSMAPI_FOUR.FSM.NewState("ST_CHANGING_SELECTION")
			:SetOnEnter(function(context)
				context.currentSelectionIndex = context.frame:GetElement("auctions"):GetSelection():GetField("index")
				return "ST_SHOWN"
			end)
			:AddTransition("ST_SHOWN")
		)
		:AddState(TSMAPI_FOUR.FSM.NewState("ST_CANCELING")
			:SetOnEnter(function(context)
				local buttonsFrame = context.frame:GetElement("bottom")
				buttonsFrame:GetElement("cancelBtn"):SetDisabled(true)
				buttonsFrame:GetElement("skipBtn"):SetDisabled(true)
				buttonsFrame:Draw()
				local selectedRecord = context.frame:GetElement("auctions"):GetSelection()
				local selectedIndex = selectedRecord:GetField("index")
				if TSM.MyAuctions.CanCancel(selectedIndex) then
					TSM.MyAuctions.CancelAuction(selectedRecord:GetField("index"))
				end
				return "ST_SHOWN"
			end)
			:AddTransition("ST_HIDDEN")
			:AddTransition("ST_SHOWN")
		)
		:AddState(TSMAPI_FOUR.FSM.NewState("ST_SKIPPING")
			:SetOnEnter(function(context)
				local auctions = context.frame:GetElement("auctions")
				context.currentSelectionIndex = context.currentSelectionIndex - 1
				auctions:SetSelection(TSM.MyAuctions.GetRecordByIndex(context.currentSelectionIndex))
				return "ST_SHOWN"
			end)
			:AddTransition("ST_SHOWN")
		)
		:AddState(TSMAPI_FOUR.FSM.NewState("ST_UPDATING_FILTER")
			:SetOnEnter(function(context)
				context.currentSelectionIndex = nil
				return "ST_SHOWN"
			end)
			:AddTransition("ST_SHOWN")
		)
		:AddDefaultEvent("EV_FRAME_HIDDEN", TSMAPI_FOUR.FSM.SimpleTransitionEventHandler("ST_HIDDEN"))
		:Init("ST_HIDDEN", fsmContext)
end



-- ============================================================================
-- Private Helper Functions
-- ============================================================================

function private.AuctionsGetItemText(_, record)
	local multiplier = record:GetField("saleStatus") == 0 and not record:GetField("isPending") and 1 or 0.8
	return TSM.UI.GetQualityColoredText(record:GetField("itemName"), record:GetField("itemQuality"), multiplier)
end

function private.AuctionsGetItemIcon(_, record)
	return record:GetField("itemTexture")
end

function private.AuctionsGetItemTooltip(_, record)
	local itemString = record:GetField("itemString")
	if itemString == TSM.CONST.PET_CAGE_ITEMSTRING then
		return nil
	end
	return itemString
end

function private.AuctionsGetTimeLeftText(_, record)
	local saleStatus = record:GetField("saleStatus")
	local duration = record:GetField("duration")
	if saleStatus == 1 then
		local timeLeft = duration - time()
		return timeLeft < 60 and format("%ds", timeLeft) or format("%dm %ds", floor(timeLeft / 60), timeLeft % 60)
	elseif record:GetField("isPending") then
		return L["Canceling..."]
	else
		return TSM.UI.GetTimeLeftString(duration)
	end
end

function private.AuctionsGetHighBidderText(_, record)
	return record:GetField("highBidder")
end

function private.AuctionsGetGroupText(_, record)
	local groupPath = TSMAPI_FOUR.Groups.GetPathByItem(record:GetField("itemString"))
	if not groupPath then
		return ""
	end
	local _, groupName = TSMAPI_FOUR.Groups.SplitPath(groupPath)
	local level = select('#', strsplit(TSM.CONST.GROUP_SEP, groupPath))
	local color = gsub(TSM.UI.GetGroupLevelColor(level), "#", "|cff")
	return color..groupName.."|r"
end

function private.AuctionsGetCurrentBidText(_, record)
	local saleStatus = record:GetField("saleStatus")
	if saleStatus == 1 then
		return L["Sold"]
	elseif record:GetField("highBidder") == "" then
		return TSMAPI_FOUR.Money.ToString(record:GetField("currentBid"), "OPT_PAD", "OPT_DISABLE", "|cff808080")
	else
		return TSMAPI_FOUR.Money.ToString(record:GetField("currentBid"), "OPT_PAD")
	end
end

function private.AuctionsGetCurrentBuyoutText(_, record)
	local saleStatus = record:GetField("saleStatus")
	return TSMAPI_FOUR.Money.ToString(record:GetField(saleStatus == 1 and "currentBid" or "buyout"), "OPT_PAD")
end
