-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local Accounting = TSM:NewPackage("Accounting")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = { }



-- ============================================================================
-- Module Functions
-- ============================================================================

function Accounting.GetSummarySalesInfo(timePeriod, selectedCharacter)
	local topItemString, topItemTotal, total, numDays = nil, 0, 0, 1
	local dateFilter = private.DateFilter(timePeriod)
	for itemString, data in pairs(TSM.old.Accounting.items) do
		local itemTotal = 0
		for _, record in ipairs(data.sales) do
			if selectedCharacter == record.player or selectedCharacter == TSMAPI_FOUR.PlayerInfo.GetPlayerGuild(record.player) or selectedCharacter == L["All Characters and Guilds"] then
				if dateFilter <= record.time then
					local daysAgo = floor((time() - record.time) / (24 * 60 * 60))
					numDays = max(numDays, daysAgo)
					itemTotal = itemTotal + record.copper * record.quantity
				end
			end
		end
		total = total + itemTotal
		if itemTotal > topItemTotal then
			topItemString = itemString
			topItemTotal = itemTotal
		end
	end
	return total, TSMAPI_FOUR.Util.Round(total / numDays), topItemString
end

function Accounting.GetSummaryExpensesInfo(timePeriod, selectedCharacter)
	local topItemString, topItemTotal, total, numDays = nil, 0, 0, 1
	local dateFilter = private.DateFilter(timePeriod)
	for itemString, data in pairs(TSM.old.Accounting.items) do
		local itemTotal = 0
		for _, record in ipairs(data.buys) do
			if selectedCharacter == record.player or selectedCharacter == TSMAPI_FOUR.PlayerInfo.GetPlayerGuild(record.player) or selectedCharacter == L["All Characters and Guilds"] then
				if dateFilter <= record.time then
					local daysAgo = floor((time() - record.time) / (24 * 60 * 60))
					numDays = max(numDays, daysAgo)
					itemTotal = itemTotal + record.copper * record.quantity
				end
			end
		end
		total = total + itemTotal
		if itemTotal > topItemTotal then
			topItemString = itemString
			topItemTotal = itemTotal
		end
	end
	return total, TSMAPI_FOUR.Util.Round(total / numDays), topItemString
end

function Accounting.GetSummaryProfitTopItem(timePeriod, selectedCharacter)
	local topItemString, topItemProfit = nil, 0
	local dateFilter = private.DateFilter(timePeriod)
	for itemString, data in pairs(TSM.old.Accounting.items) do
		local totalBuy, numBuys, totalSale, numSales = 0, 0, 0, 0
		for _, record in ipairs(data.buys) do
			totalBuy = totalBuy + record.copper * record.quantity
			numBuys = numBuys + record.quantity
		end
		for _, record in ipairs(data.sales) do
			if selectedCharacter == record.player or selectedCharacter == TSMAPI_FOUR.PlayerInfo.GetPlayerGuild(record.player) or selectedCharacter == L["All Characters and Guilds"] then
				if dateFilter <= record.time then
					totalSale = totalSale + record.copper * record.quantity
					numSales = numSales + record.quantity
				end
			end
		end
		if numBuys > 0 and numSales > 0 then
			local profit = (totalSale / numSales - totalBuy / numBuys) * min(numBuys, numSales)
			if profit > topItemProfit then
				topItemString = itemString
				topItemProfit = profit
			end
		end
	end
	return topItemString
end



-- ============================================================================
-- Private Helper Functions
-- ============================================================================

function private.DateFilter(timePeriod)
	local dateFilter = 0
	if timePeriod == L["Past Year"] then
		dateFilter = time() - (60 * 60 * 24 * 30 * 12)
	elseif timePeriod == L["Past Month"] then
		dateFilter = time() - (60 * 60 * 24 * 30)
	elseif timePeriod == L["Past 7 Days"] then
		dateFilter = time() - (60 * 60 * 24 * 7)
	elseif timePeriod == L["Past Day"] then
		dateFilter = time() - (60 * 60 * 24)
	else
		error("Unknown Time Period")
	end
	return dateFilter
end