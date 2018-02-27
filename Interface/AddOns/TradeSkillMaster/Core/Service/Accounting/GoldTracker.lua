-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local GoldTracker = TSM.Accounting:NewPackage("GoldTracker")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = { lastDay = {} }



-- ============================================================================
-- Module Functions
-- ============================================================================

function GoldTracker.PopulateGraphData(xData, xDataValue, yData, xUnit, numXUnits, selectedCharacter)
	local timeTable = TSMAPI_FOUR.Util.AcquireTempTable()
	local numPoints = numXUnits
	if xUnit == "halfMonth" then
		assert(numXUnits % 24 == 0)
		timeTable.year = tonumber(date("%Y")) - numXUnits / 24
		timeTable.month = tonumber(date("%m"))
		timeTable.day = tonumber(date("%d")) >= 15 and 15 or 1
		private.AddXUnit(timeTable, xUnit)
		if timeTable.day == 15 then
			-- need to start on the first day of a month, so add another point
			private.AddXUnit(timeTable, xUnit)
			numPoints = numPoints - 1
		end
	elseif xUnit == "month" then
		assert(numXUnits % 30 == 0)
		timeTable.year = tonumber(date("%Y"))
		timeTable.month = tonumber(date("%m")) - numXUnits / 30
		timeTable.day = tonumber(date("%d")) + 1
		private.AddXUnit(timeTable, xUnit)
	elseif xUnit == "sevenDays" then
		assert(numXUnits % 24 == 0)
		timeTable.year = tonumber(date("%Y"))
		timeTable.month = tonumber(date("%m"))
		timeTable.day = tonumber(date("%d")) - 6
		timeTable.hour = tonumber(date("%H")) - numXUnits / 24
		private.AddXUnit(timeTable, xUnit)
	elseif xUnit == "hour" then
		assert(numXUnits % 24 == 0)
		timeTable.year = tonumber(date("%Y"))
		timeTable.month = tonumber(date("%m"))
		timeTable.day = tonumber(date("%d")) - numXUnits / 24
		timeTable.hour = tonumber(date("%H")) + 1
		private.AddXUnit(timeTable, xUnit)
	else
		error("Invalid xUnit: "..tostring(xUnit))
	end
	for i = 1, numPoints do
		tinsert(xData, i)
		tinsert(xDataValue, time(timeTable))
		tinsert(yData, 0)
		private.AddXUnit(timeTable, xUnit)
	end
	TSMAPI_FOUR.Util.ReleaseTempTable(timeTable)

	for player, logEntries in pairs(TSM.old.Accounting.goldLog) do
		if selectedCharacter == player or selectedCharacter == TSMAPI_FOUR.PlayerInfo.GetPlayerGuild(player) or selectedCharacter == L["All Characters and Guilds"] then
			for i, timestamp in ipairs(xDataValue) do
				yData[i] = yData[i] + private.GetGoldValueAtTime(logEntries, timestamp)
			end
		end
	end
end



-- ============================================================================
-- Private Helper Functions
-- ============================================================================

function private.AddXUnit(timeTable, xUnit)
	if xUnit == "halfMonth" then
		if timeTable.day == 1 then
			timeTable.day = 15
		else
			timeTable.day = 1
			if timeTable.month == 12 then
				timeTable.month = 1
				timeTable.year = timeTable.year + 1
			else
				timeTable.month = timeTable.month + 1
			end
		end
	elseif xUnit == "month" then
		if timeTable.day == private.GetMonthLastDay(timeTable) then
			timeTable.day = 1
			if timeTable.month == 12 then
				timeTable.month = 1
				timeTable.year = timeTable.year + 1
			else
				timeTable.month = timeTable.month + 1
			end
		else
			timeTable.day = timeTable.day + 1
		end
	elseif xUnit == "sevenDays" then
		if timeTable.hour == 23 then
			timeTable.hour = 0
			if timeTable.day == private.GetMonthLastDay(timeTable) then
				timeTable.day = 1
				if timeTable.month == 12 then
					timeTable.month = 1
					timeTable.year = timeTable.year + 1
				else
					timeTable.month = timeTable.month + 1
				end
			else
				timeTable.day = timeTable.day + 1
			end
		else
			timeTable.hour = timeTable.hour + 6
		end
	elseif xUnit == "hour" then
		if timeTable.hour == 23 then
			timeTable.hour = 0
			timeTable.day = timeTable.day + 1
		else
			timeTable.hour = timeTable.hour + 1
		end
	end
end

function private.GetMonthLastDay(timeTable)
	private.lastDay.year = timeTable.year
	private.lastDay.month = timeTable.month + 1
	private.lastDay.day = 0

	return tonumber(date("%d", time(private.lastDay)))
end

function private.GetGoldValueAtTime(logEntries, timestamp)
	local minuteTimestamp = floor(timestamp / 60)
	if #logEntries == 0 or logEntries[1].startMinute > minuteTimestamp then
		-- timestamp is before we had any data
		return 0
	end
	local goldValue = 0
	for _, entry in ipairs(logEntries) do
		goldValue = TSMAPI_FOUR.Util.Round(entry.copper / 10000000)
		if entry.startMinute <= minuteTimestamp and entry.endMinute >= minuteTimestamp then
			break
		end
	end
	return goldValue
end