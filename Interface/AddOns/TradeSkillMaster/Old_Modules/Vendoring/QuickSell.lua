-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Vendoring                           --
--           http://www.curse.com/addons/wow/tradeskillmaster_vendoring           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSMCore = select(2, ...)
local TSM = TSMCore.old.Vendoring
local QuickSell = TSM:NewPackage("QuickSell")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table

local private = { ignore = {}, sellAmount = 0, sellIndex = 0, sellQueue = {}, sellInfo = {}, sellThreadId = nil, sellProfit = 0, frame = nil, inspecting = false, hovering = false }

function QuickSell:CreateTab(parent)

	local BFC = TSMAPI.GUI:GetBuildFrameConstants()
	local color = TSMAPI.Design:GetInlineColor("link")
	local frameInfo = {
		type = "Frame",
		key = "quickSellTab",
		hidden = true,
		points = "ALL",
		scripts = {"OnShow"},
		children = {
			{
				type = "Text",
				text = format(L["%sLeft-Click|r to ignore an item for this session. Hold %sshift|r to ignore permanently. You can remove items from permanent ignore in the Vendoring options."], color, color),
				textFont = { TSMAPI.Design:GetContentFont("small") },
				justify = { "LEFT", "TOP" },
				points = { { "TOPLEFT", 5, -5 }, { "TOPRIGHT", -5, -5 } },
			},
			{
				type = "ScrollingTableFrame",
				key = "quicksellST",
				stCols = {
						{
							name = L["Item"],
							width = 0.5,
						},
						{
							name = L["Vendor"],
							width = 0.25,
						},
						{
							name = L["Potential"],
							width = 0.25
						},
					},
				scripts = {"OnClick", "OnEnter", "OnLeave" },
				points = { {"TOPLEFT", BFC.PREV, "BOTTOMLEFT", 0, -3}, {"BOTTOMRIGHT", -5, 95}},
				stDisableSelection = true,
				sortInfo = {true, 3},
			},
			{
				type = "CheckBox",
				key = "hideGroupedChk",
				label = L["Hide Grouped Items"],
				scripts = {"OnValueChanged"},
				points = {{"TOPLEFT",  BFC.PREV, "BOTTOMLEFT", 0, -2 }}
			},
			{
				type = "CheckBox",
				key = "hideSoulboundChk",
				label = L["Hide Soulbound Items"],
				scripts = {"OnValueChanged"},
				points = {{"TOPLEFT", BFC.PREV, "TOPRIGHT", 5, 0}}
			},
			{
				type = "Button",
				name = "TSMVendoringSellAllButton",
				key = "sellAllBtn",
				text = L["Sell All"],
				textHeight = 25,
				size = {25, 35},
				points = {{"BOTTOMLEFT", 170, 25}, {"BOTTOMRIGHT", -5, 25}},
				scripts = {"OnClick"},
			},
			{
				type = "Text",
				text = L["Sell Only:"],
				textSize = "small",
				justify = {"LEFT", "CENTER"},
				size = {0, 20},
				points = {{"BOTTOMLEFT", 5, 25}},
			},
			{
				type = "Button",
				key = "sellTrashBtn",
				text = L["Trash"],
				textHeight = 15,
				size = {40, 20},
				points = {{"BOTTOMLEFT", BFC.PREV, "BOTTOMRIGHT", 10,0}},
				scripts = {"OnClick"},
			},
			{
				type = "Button",
				key = "sellBOEBtn",
				text = L["BOEs"],
				textHeight = 15,
				size = {40, 20},
				points = {{"BOTTOMLEFT", BFC.PREV, "BOTTOMRIGHT", 10,0}},
				scripts = {"OnClick"},
			}

		},
		handlers = {
			OnShow = function(self)
				private.frame = self
				private.frame.hideGroupedChk:SetValue(TSMCore.db.global.vendoringOptions.qsHideGrouped)
				private.frame.hideSoulboundChk:SetValue(TSMCore.db.global.vendoringOptions.qsHideSoulbound)
				private:UpdateQuicksellST()
			end,
			hideGroupedChk = {
				OnValueChanged = function(self, value)
					TSMCore.db.global.vendoringOptions.qsHideGrouped = value
					private:UpdateQuicksellST()
				end
			},
			hideSoulboundChk = {
				OnValueChanged = function(self, value)
					TSMCore.db.global.vendoringOptions.qsHideSoulbound = value
					private:UpdateQuicksellST()
				end
			},
			sellAllBtn = {
				OnClick = function(self)
					private:AutoSell("all")
				end
			},
			sellTrashBtn = {
				OnClick = function(self)
					private:AutoSell("trash")
				end
			},
			sellBOEBtn = {
				OnClick = function(self)
					private:AutoSell("boe")
				end
			},
			quicksellST = {
				OnClick = function(_, data, self, button)
					if not data then return end

					if IsModifiedClick("DRESSUP") then
						HandleModifiedItemClick(data.itemLink)
						return
					end

					if button == "RightButton" then
						if not private.sellThreadId then
							UseContainerItem(data.bag,data.slot)
						end
					end

					if button == "LeftButton" then
						if IsShiftKeyDown() then
							TSMCore.db.global.userData.vendoringIgnore[data.itemString] = true
							TSM:Printf(L["Ignoring all %s permanently. You can undo this in the Vendoring options."], data.itemLink)
							TSM.Options:UpdateIgnoreST()
						else
							private.ignore[data.itemString] = true
							TSM:Printf(L["Ignoring all %s this session (until your UI is reloaded)."], data.itemLink)
						end
						private:UpdateQuicksellST()
					end
				end,
				OnEnter = function(_, data, self)
					if not data then return end

					if private.inspecting then
						ShowInspectCursor()
					else
						SetCursor("BUY_CURSOR")
					end

					private.hovering = true

					local color = TSMAPI.Design:GetInlineColor("link")
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
					TSMAPI.Util:SafeTooltipLink(data.itemLink)
					GameTooltip:Show()
				end,
				OnLeave = function()
					ResetCursor()
					GameTooltip:ClearLines()
					GameTooltip:Hide()
					BattlePetTooltip:Hide()
					private.hovering = false
				end
			}
		}
	}

	return frameInfo
end

function private:AutoSell(mode)
	private.moneyCollected = 0
	private:DisableButtons()

	private.sellQueue = {}

	private.sellIndex = 0
	private.sellAmount = 0

	for j, info in ipairs(private.sellInfo) do
		if(private.sellAmount < TSMCore.db.global.vendoringOptions.qsBatchSize) then
			if mode == "all" then
				private.sellQueue[private.sellAmount] = { bag = info.bag, slot = info.slot, itemString = info.itemString, itemLink = info.itemLink, vendorValue = info.vendorValue, quantity = info.quantity }
				private.sellAmount = private.sellAmount + 1
			elseif mode == "trash" and info.isTrash then
				private.sellQueue[private.sellAmount] = { bag = info.bag, slot = info.slot, itemString = info.itemString, itemLink = info.itemLink, vendorValue = info.vendorValue, quantity = info.quantity }
				private.sellAmount = private.sellAmount + 1
			elseif mode == "boe" and info.isBOE then
				private.sellQueue[private.sellAmount] = { bag = info.bag, slot = info.slot, itemString = info.itemString, itemLink = info.itemLink, vendorValue = info.vendorValue, quantity = info.quantity }
				private.sellAmount = private.sellAmount + 1
			end
		end
	end

	if private.sellAmount > 0 then
		private.sellThreadId = TSMAPI.Threading:Start(private.AutoSellThread, 0.7, private.DoneSelling)
	else
		private:EnableButtons()
	end
end

function QuickSell:BeginInspect()
	private.inspecting = true
	ShowInspectCursor()
end

function QuickSell:EndInspect()
	private.inspecting = false
	if private.frame and private.frame:IsVisible() then
		if private.hovering then
			SetCursor("BUY_CURSOR")
		else
			ResetCursor()
		end
	end
end

function private:EnableButtons()
	if private.frame then
		private.frame.sellAllBtn:Enable()
		private.frame.sellTrashBtn:Enable()
		private.frame.sellBOEBtn:Enable()
	end
end

function private:DisableButtons()
	private.frame.sellAllBtn:Disable()
	private.frame.sellBOEBtn:Disable()
	private.frame.sellTrashBtn:Disable()
end

function private.AutoSellThread(self, args)

	private.sellProfit = 0
	for i = 0, private.sellAmount-1 do
		UseContainerItem(private.sellQueue[i].bag,private.sellQueue[i].slot)
		private.sellIndex = i
		self:Yield(true)
	end

	if private.sellAmount > 0 then
		self:Sleep(1)
		for k = 0, private.sellAmount-1 do
			local numYields = 0
			while true do
				if not GetContainerItemInfo(private.sellQueue[k].bag,private.sellQueue[k].slot) then
					private.sellProfit = private.sellProfit + (private.sellQueue[k].vendorValue * (private.sellQueue[k].quantity or 1))
					break
				elseif numYields >= 100 then
					break
				end
				numYields = numYields+1
				self:Yield(true)
			end
		end
	end
end

function private:DoneSelling()
	private.sellThreadId = nil
	private:EnableButtons()

	if TSMCore.db.global.vendoringOptions.displayMoneyCollected and private.sellProfit > 0 then
		TSM:Printf("Collected: %s",TSMAPI:MoneyToString(private.sellProfit, "OPT_TRIM"))
	end
end

function QuickSell:OnMerchantShow()
	private:UpdateQuicksellST()
end

function QuickSell:OnMerchantUpdate()
	private:UpdateQuicksellST()
end

function QuickSell:OnBagUpdate()
	private:UpdateQuicksellST()
end

function private:UpdateQuicksellST()
	if not private.frame or not private.frame.quicksellST then
		return
	end

	private.sellInfo = {}

	for _, bag,slot,itemString,quantity in TSMAPI.Inventory:BagIterator(nil,true) do
		local values = private:ShouldSell(bag,slot,quantity)

		if values then
			tinsert(private.sellInfo,values)
		end
	end

	local stData = {}
	for j, info in ipairs(private.sellInfo) do

		tinsert(stData, {
			cols = {
				{ value = format("|T%s:0|t %s", info.texture or "", info.itemLink), sortArg = info.name},
				{ value = TSMAPI:MoneyToString(info.vendorValue), sortArg = info.vendorValue },
				{ value = TSMAPI:MoneyToString(info.potentialValue), sortArg = info.potentialValue },
			},
			index = j,
			itemString = info.itemString,
			itemLink = info.itemLink,
			bag = info.bag,
			slot = info.slot,
			isTrash = info.isTrash,
			isExpired = info.isExpired
		})
	end

	private.frame.quicksellST:SetData(stData)
end

function private:ShouldSell(bag,slot,quantity)
	local itemLink = GetContainerItemLink(bag,slot)

	if not itemLink then
		return
	end

	local itemString = TSMAPI.Item:ToItemString(itemLink)
	local name = TSMAPI.Item:GetName(itemString)
	local texture = TSMAPI.Item:GetTexture(itemString)
	local vendorValue = TSMAPI.Item:GetVendorPrice(itemString) or 0

	if vendorValue == 0 then
		return
	end

	if TSMCore.db.global.vendoringOptions.qsHideGrouped then
		local groupPath = TSMAPI_FOUR.Groups.GetPathByItem(itemString) or TSMCore.CONST.ROOT_GROUP_PATH

		if groupPath ~= TSMCore.CONST.ROOT_GROUP_PATH then
			return
		end
	end

	if private.ignore[itemString] or TSMCore.db.global.userData.vendoringIgnore[itemString] then
		return
	end

	local grey = string.find(itemLink,"|cff9d9d9d")

	if grey then
		return {
			texture = texture,
			name = name,
			itemString = itemString, itemLink = itemLink,
			Sell = true,
			vendorValue = vendorValue,
			potentialValue = vendorValue,
			bag = bag,
			slot = slot,
			quantity = quantity,
			isTrash = true,
			isExpired = false,
		}
	end

	local isSoulbound = TSMAPI.Item:IsSoulbound(bag, slot)

	if not isSoulbound or not TSMCore.db.global.vendoringOptions.qsHideSoulbound then

		local qsMarketValue = TSMCore.db.global.vendoringOptions.qsMarketValue
		local qsDestroyValue = TSMCore.db.global.vendoringOptions.qsDestroyValue
		local qsMaxMarketValue = TSMCore.db.global.vendoringOptions.qsMaxMarketValue
		local qsMaxDestroyValue = TSMCore.db.global.vendoringOptions.qsMaxDestroyValue

		local destroyValue = TSMAPI:GetCustomPriceValue(qsDestroyValue,itemLink) or 0
		local marketValue = TSMAPI:GetCustomPriceValue(qsMarketValue,itemLink) or 0

		local maxMarketValue = TSMAPI:GetCustomPriceValue(qsMaxMarketValue,itemLink) or 0
		local maxDestroyValue = TSMAPI:GetCustomPriceValue(qsMaxDestroyValue,itemLink) or 0

		if destroyValue >= maxDestroyValue then
			return
		end

		if marketValue >= maxMarketValue then
			return
		end

		return {
			itemString = itemString, itemLink = itemLink,
			texture = texture,
			name = name,
			Sell = true,
			vendorValue = vendorValue,
			potentialValue = max(destroyValue,marketValue),
			bag = bag,
			slot = slot,
			isTrash = false,
			isExpired = false,
			isBOE = not isSoulbound and TSMAPI.Item:IsDisenchantable(itemString)
		}
	end

	return
end

function QuickSell:SellTrash()
	if not TSMCore.db.global.vendoringOptions.autoSellTrash then
		return
	end

	private.sellThreadId = TSMAPI.Threading:Start(private.AutoSellTrash, 0.7, private.DoneSelling)
end

function private.AutoSellTrash(self,args)
	private.sellProfit = 0
	local slotIds = TSMAPI_FOUR.Util.AcquireTempTable()
	for _, bag, slot, itemString, quantity in TSMAPI.Inventory:BagIterator(nil, true) do
		if TSMAPI_FOUR.Item.GetQuality(itemString) == 0 then
			private.sellProfit = private.sellProfit + (TSMAPI:GetItemValue(itemString, "VendorSell") or 0) * quantity
			tinsert(slotIds, bag * 1000 + slot)
		end
	end
	for _, slotId in ipairs(slotIds) do
		local bag = floor(slotId / 1000)
		local slot = slotId % 1000
		UseContainerItem(bag, slot)
		self:Yield(true)
	end
	TSMAPI_FOUR.Util.ReleaseTempTable(slotIds)
end
