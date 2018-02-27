-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Auctioning                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctioning          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSMCore = select(2, ...)
local TSM = TSMCore.old.Auctioning
local BankUI = TSM:NewPackage("BankUI")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = { currentBank = nil, frame = nil }



function BankUI:OnEnable()
	TSMAPI_FOUR.Event.Register("GUILDBANKFRAME_OPENED", private.EventHandler)
	TSMAPI_FOUR.Event.Register("GUILDBANKFRAME_CLOSED", private.EventHandler)
	TSMAPI_FOUR.Event.Register("BANKFRAME_OPENED", private.EventHandler)
	TSMAPI_FOUR.Event.Register("BANKFRAME_CLOSED", private.EventHandler)
end

function private.EventHandler(event)
	if event == "GUILDBANKFRAME_OPENED" then
		private.currentBank = "guildbank"
	elseif event == "BANKFRAME_OPENED" then
		private.currentBank = "bank"
	elseif event == "GUILDBANKFRAME_CLOSED" or event == "BANKFRAME_CLOSED" then
		private.currentBank = nil
	end
end

function BankUI.createTab(parent)
	if private.frame then return private.frame end

	local BFC = TSMAPI.GUI:GetBuildFrameConstants()
	local frameInfo = {
		type = "Frame",
		parent = parent,
		hidden = true,
		points = "ALL",
		children = {
			{
				type = "GroupTreeFrame",
				key = "groupTree",
				groupTreeInfo = { "Auctioning", "Auctioning_Bank" },
				points = { { "TOPLEFT" }, { "BOTTOMRIGHT", 0, 137 } },
			},
			{
				type = "Frame",
				key = "buttonFrame",
				points = { { "TOPLEFT", BFC.PREV, "BOTTOMLEFT", 0, 0 }, { "BOTTOMRIGHT" } },
				children = {
					{
						type = "Button",
						key = "btnToBags",
						text = L["Post Cap To Bags"],
						textHeight = 14,
						size = { 0, 28 },
						points = { { "TOPLEFT", 5, -5 }, { "TOPRIGHT", BFC.PARENT, "CENTER", -3, -15 } },
						scripts = { "OnClick" },
					},
					{
						type = "Button",
						key = "btnAHToBags",
						text = L["AH Shortfall To Bags"],
						textHeight = 14,
						size = { 0, 28 },
						points = { { "TOPLEFT", BFC.PREV, "TOPRIGHT", 5, 0 }, { "TOPRIGHT", -5, -5 } },
						scripts = { "OnClick" },
					},
					{
						type = "Button",
						key = "btnToBank",
						text = L["Group To Bank"],
						textHeight = 14,
						size = { 0, 28 },
						points = { { "TOPLEFT", "btnToBags", "BOTTOMLEFT", 0, -5 }, { "TOPRIGHT", "btnToBags", "BOTTOMRIGHT", 0, -5 } },
						scripts = { "OnClick" },
					},
					{
						type = "Button",
						key = "btnAllToBags",
						text = L["Group To Bags"],
						textHeight = 14,
						size = { 0, 28 },
						points = { { "TOPLEFT", BFC.PREV, "TOPRIGHT", 5, 0 }, { "TOPRIGHT", "btnAHToBags", "BOTTOMRIGHT", 0, -5 } },
						scripts = { "OnClick" },
					},
					{
						type = "Button",
						key = "btnMaxExpToBank",
						text = L["Max Expired to Bank"],
						textHeight = 14,
						size = { 0, 28 },
						points = { { "TOPLEFT", "btnToBank", "BOTTOMLEFT", 0, -5 }, { "TOPRIGHT", "btnToBank", "BOTTOMRIGHT", 0, -5 } },
						scripts = { "OnClick" },
					},
					{
						type = "Button",
						key = "btnMaxExpToBags",
						text = L["Max Expired to Bags"],
						textHeight = 14,
						size = { 0, 28 },
						points = { { "TOPLEFT", BFC.PREV, "TOPRIGHT", 5, 0 }, { "TOPRIGHT", "btnAllToBags", "BOTTOMRIGHT", 0, -5 } },
						scripts = { "OnClick" },
					},
					{
						type = "Button",
						key = "btnNonGroupBank",
						text = L["Non Group to Bank"],
						textHeight = 14,
						size = { 0, 28 },
						points = { { "TOPLEFT", "btnMaxExpToBank", "BOTTOMLEFT", 0, -5 }, { "TOPRIGHT", "btnMaxExpToBank", "BOTTOMRIGHT", 0, -5 } },
						scripts = { "OnClick" },
					},
					{
						type = "Button",
						key = "btnNonGroupBags",
						text = L["Non Group to Bags"],
						textHeight = 14,
						size = { 0, 28 },
						points = { { "TOPLEFT", BFC.PREV, "TOPRIGHT", 5, 0 }, { "TOPRIGHT", "btnMaxExpToBags", "BOTTOMRIGHT", 0, -5 } },
						scripts = { "OnClick" },
					},
				},
			},
		},
		handlers = {
			buttonFrame = {
				btnToBank = {
					OnClick = function() private.groupTree(private.frame.groupTree:GetSelectedGroupInfo(), "bags") end,
				},
				btnMaxExpToBank = {
					OnClick = function() private.groupTree(private.frame.groupTree:GetSelectedGroupInfo(), "bags", false, false, true) end,
				},
				btnNonGroupBank = {
					OnClick = function() private.nonGroupTree(private.frame.groupTree:GetSelectedGroupInfo(), "bags") end,
				},
				btnNonGroupBags = {
					OnClick = function() private.nonGroupTree(private.frame.groupTree:GetSelectedGroupInfo(), private.currentBank) end,
				},
				btnToBags = {
					OnClick = function() private.groupTree(private.frame.groupTree:GetSelectedGroupInfo(), private.currentBank) end,
				},
				btnAHToBags = {
					OnClick = function() private.groupTree(private.frame.groupTree:GetSelectedGroupInfo(), private.currentBank, false, true) end,
				},
				btnMaxExpToBags = {
					OnClick = function() private.groupTree(private.frame.groupTree:GetSelectedGroupInfo(), private.currentBank, false, true, true) end,
				},
				btnAllToBags = {
					OnClick = function() private.groupTree(private.frame.groupTree:GetSelectedGroupInfo(), private.currentBank, true) end,
				},
			},
		},
	}

	private.frame = TSMAPI.GUI:BuildFrame(frameInfo)
	return private.frame
end

function private.groupTree(grpInfo, src, all, ah, maxExpired)
	local next = next
	local newgrp = {}
	local totalItems = private.getTotalItems(src)
	local bagItems = private.getTotalItems("bags") or {}
	for groupName, data in pairs(grpInfo) do
		groupName = TSMAPI_FOUR.Groups.FormatPath(groupName, true)
		for _, opName in ipairs(data.operations) do
			local opSettings = TSM.operations[opName]
			if not opSettings then
				-- operation doesn't exist anymore in Auctioning
				TSM:Printf(L["'%s' has an Auctioning operation of '%s' which no longer exists."], groupName, opName)
			else
				--it's a valid operation
				for itemString in pairs(data.items) do
					local totalq = 0
					if totalItems then
						totalq = totalItems[itemString] or 0
					end
					--check if maxExpires has been exceeded
					local expired = false
					if opSettings.maxExpires > 0 and TSMAPI_FOUR.Modules.IsPresent("Accounting") then
						local _, numExpires = TSMAPI_FOUR.Modules.API("Accounting", "getAuctionStatsSinceLastSale", itemString)
						if type(numExpires) == "number" and numExpires > opSettings.maxExpires then
							expired = true
						end
					end
					if src == "bags" then -- move them all back to bank/gbank
					if (maxExpired and expired) or not maxExpired then
						if totalq > 0 then
							newgrp[itemString] = totalq * -1
							totalItems[itemString] = nil -- remove the current bag count in case we loop round for another operation
						end
					end
					else -- move from bank/gbank to bags
						if (maxExpired and expired) or (not maxExpired and not expired) then
							if totalq > 0 then
								if all or maxExpired then
									newgrp[itemString] = totalq
									totalItems[itemString] = nil
								else
									local availQty = totalq
									if opSettings.keepQuantity > 0 then
										if src == "bank" then
											if opSettings.keepQtySources.bank then
												if opSettings.keepQtySources.guild then
													availQty = availQty + TSMAPI_FOUR.Inventory.GetGuildQuantity(itemString)
												end
												availQty = availQty - opSettings.keepQuantity
											end
										end
										if src == "guildbank" then
											if opSettings.keepQtySources.guild then
												if opSettings.keepQtySources.bank then
													availQty = availQty + TSMAPI_FOUR.Inventory.GetBankQuantity(itemString) + TSMAPI_FOUR.Inventory.GetReagentBankQuantity(itemString)
												end
												availQty = availQty - opSettings.keepQuantity
											end
										end
									end

									local _, _, numAuctions = TSMAPI_FOUR.Inventory.GetPlayerTotals(itemString)
									local ahQty = ah and (TSMAPI_FOUR.Inventory.GetMailQuantity(itemString) + numAuctions) or 0
									local quantity = min(availQty, (opSettings.stackSize * opSettings.postCap) - ahQty - (bagItems[itemString] or 0))
									if quantity > 0 then
										newgrp[itemString] = (newgrp[itemString] or 0) + quantity
										totalItems[itemString] = totalItems[itemString] - quantity -- remove this operations qty to move from source quantity in case we loop again for another operation
										if bagItems[itemString] then --remove this operations maxPost quantity from the bag total in case we loop again for another operation
											bagItems[itemString] = bagItems[itemString] - (opSettings.stackSize * opSettings.postCap)
											if bagItems[itemString] <= 0 then
												bagItems[itemString] = nil
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end

	if next(newgrp) == nil then
		TSM:Print(L["Nothing to Move"])
	else
		TSM:Print(L["Preparing to Move"])
		TSMAPI_FOUR.Mover.MoveItems(newgrp, private.PrintMsg, false)
	end
end

function private.nonGroupTree(grpInfo, src)
	local next = next
	local newgrp = {}
	local totalItems = private.getTotalItems(src, true)
	local bagItems = private.getTotalItems("bags", true)
	for groupName, data in pairs(grpInfo) do
		groupName = TSMAPI_FOUR.Groups.FormatPath(groupName, true)
		for _, opName in ipairs(data.operations) do
			local opSettings = TSM.operations[opName]
			if not opSettings then
				-- operation doesn't exist anymore in Auctioning
				TSM:Printf(L["'%s' has an Auctioning operation of '%s' which no longer exists."], groupName, opName)
			else
				-- it's a valid operation so remove all the items from bagItems so we are left with non group items to move
				for itemString in pairs(data.items) do
					if totalItems then
						if totalItems[itemString] then
							totalItems[itemString] = nil
						end
					end
				end
			end
		end
	end


	for itemString, quantity in pairs(totalItems) do
		if src == "bags" then -- move them all back to bank/gbank
		newgrp[itemString] = totalItems[itemString] * -1
		else -- move from bank/gbank to bags
		newgrp[itemString] = quantity
		end
	end

	if next(newgrp) == nil then
		TSM:Print(L["Nothing to Move"])
	else
		TSM:Print(L["Preparing to Move"])
		TSMAPI_FOUR.Mover.MoveItems(newgrp, private.PrintMsg, true)
	end
end

function private.PrintMsg(message)
	TSM:Print(message)
end

function private.getTotalItems(src, includeSoulbound)
	local results = {}
	if src == "bank" then
		for _, _, _, itemString, quantity in TSMAPI_FOUR.Inventory.BankIterator(true, includeSoulbound, false, true) do
			results[itemString] = (results[itemString] or 0) + quantity
		end
		return results
	elseif src == "guildbank" then
		for tab = 1, GetNumGuildBankTabs() do
			local _, _, _, _, numWithdrawals = GetGuildBankTabInfo(tab)
			if numWithdrawals > 0 or IsGuildLeader(UnitName("player")) then
				for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB or 98 do
					local itemString = TSMAPI_FOUR.Item.ToBaseItemString(GetGuildBankItemLink(tab, slot), true)
					if itemString == "i:82800" then
						local speciesID = GameTooltip:SetGuildBankItem(tab, slot)
						itemString = speciesID and ("p:" .. speciesID)
					end
					if itemString then
						local _, itemCount = GetGuildBankItemInfo(tab, slot)
						results[itemString] = (results[itemString] or 0) + itemCount
					end
				end
			end
		end
		return results
	elseif src == "bags" then
		for _, bag, slot, itemString, quantity in TSMAPI_FOUR.Inventory.BagIterator(true, includeSoulbound) do
			local isBOP, isBOA = TSMAPI_FOUR.Inventory.IsSoulbound(bag, slot)
			if private.currentBank == "bank" or not (isBOP or isBOA) then
				results[itemString] = (results[itemString] or 0) + quantity
			end
		end
		return results
	end
end
