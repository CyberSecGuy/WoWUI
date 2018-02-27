-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_AuctionDB                           --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctiondb           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- register this file with Ace Libraries
local TSMCore = select(2, ...)
TSMCore.old.AuctionDB = TSMCore.old.AuctionDB or {}
local TSM = TSMAPI_FOUR.Addon.New("TradeSkillMaster_AuctionDB", TSMCore.old.AuctionDB)
local AceGUI = LibStub("AceGUI-3.0") -- load the AceGUI libraries
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = { region = nil, globalKeyLookup = { } }

TSM.MAX_AVG_DAY = 1
local SECONDS_PER_DAY = 60 * 60 * 24

StaticPopupDialogs["TSM_AUCTIONDB_NO_DATA_POPUP"] = {
	text = L["|cffff0000WARNING:|r TSM_AuctionDB doesn't currently have any pricing data for your realm. Either download the TSM Desktop Application from |cff99ffffhttp://tradeskillmaster.com|r to automatically update TSM_AuctionDB's data, or run a manual scan in-game."],
	button1 = OKAY,
	timeout = 0,
	hideOnEscape = false,
}

local tooltipDefaults = {
	_version = 2,
	minBuyout = true,
	marketValue = true,
	historical = false,
	regionMinBuyout = false,
	regionMarketValue = true,
	regionHistorical = false,
	regionSale = true,
	regionSalePercent = true,
	regionSoldPerDay = true,
	globalMinBuyout = false,
	globalMarketValue = false,
	globalHistorical = false,
	globalSale = false,
}

function TSM:OnInitialize()
	TSM:RegisterTooltipInfo(tooltipDefaults, TSM.LoadTooltip, TSM.Config.LoadTooltipOptions)

	TSM:RegisterModuleAPI("lastCompleteScanTime", TSM.GetLastCompleteScanTime)

	TSM:RegisterPriceSource("DBMarket", L["AuctionDB - Market Value"], TSM.GetRealmItemData, false, "marketValue")
	TSM:RegisterPriceSource("DBMinBuyout", L["AuctionDB - Minimum Buyout"], TSM.GetRealmItemData, false, "minBuyout")
	TSM:RegisterPriceSource("DBHistorical", L["AuctionDB - Historical Price (via TSM App)"], TSM.GetRealmItemData, false, "historical")
	TSM:RegisterPriceSource("DBRegionMinBuyoutAvg", L["AuctionDB - Region Minimum Buyout Average (via TSM App)"], TSM.GetRegionItemData, false, "regionMinBuyout")
	TSM:RegisterPriceSource("DBRegionMarketAvg", L["AuctionDB - Region Market Value Average (via TSM App)"], TSM.GetRegionItemData, false, "regionMarketValue")
	TSM:RegisterPriceSource("DBRegionHistorical", L["AuctionDB - Region Historical Price (via TSM App)"], TSM.GetRegionItemData, false, "regionHistorical")
	TSM:RegisterPriceSource("DBRegionSaleAvg", L["AuctionDB - Region Sale Average (via TSM App)"], TSM.GetRegionItemData, false, "regionSale")
	TSM:RegisterPriceSource("DBRegionSaleRate", L["AuctionDB - Region Sale Rate (via TSM App)"], TSM.GetRegionSaleInfo, false, "regionSalePercent")
	TSM:RegisterPriceSource("DBRegionSoldPerDay", L["AuctionDB - Region Sold Per Day (via TSM App)"], TSM.GetRegionSaleInfo, false, "regionSoldPerDay")
	TSM:RegisterPriceSource("DBGlobalMinBuyoutAvg", L["AuctionDB - Global Minimum Buyout Average (via TSM App)"], TSM.GetGlobalItemData, false, "globalMinBuyout")
	TSM:RegisterPriceSource("DBGlobalMarketAvg", L["AuctionDB - Global Market Value Average (via TSM App)"], TSM.GetGlobalItemData, false, "globalMarketValue")
	TSM:RegisterPriceSource("DBGlobalHistorical", L["AuctionDB - Global Historical Price (via TSM App)"], TSM.GetGlobalItemData, false, "globalHistorical")
	TSM:RegisterPriceSource("DBGlobalSaleAvg", L["AuctionDB - Global Sale Average (via TSM App)"], TSM.GetGlobalItemData, false, "globalSale")
	TSM:RegisterPriceSource("DBGlobalSaleRate", L["AuctionDB - Global Sale Rate (via TSM App)"], TSM.GetGlobalSaleInfo, false, "globalSalePercent")
	TSM:RegisterPriceSource("DBGlobalSoldPerDay", L["AuctionDB - Global Sold Per Day (via TSM App)"], TSM.GetGlobalSaleInfo, false, "globalSoldPerDay")

	TSMAPI_FOUR.Modules.Register(TSM)
end

function TSM:OnEnable()
	private.region = TSMAPI:GetRegion()

	local realmAppData = nil
	local appData = TSMAPI.AppHelper and TSMAPI.AppHelper:FetchData("AUCTIONDB_MARKET_DATA") -- get app data from TSM_AppHelper if it's installed
	if appData then
		for _, info in ipairs(appData) do
			local realm, data = unpack(info)
			local downloadTime = "?"
			if realm == "US" then
				local regionData, lastUpdate = TSM:LoadRegionAppData(data)
				if regionData then
					TSM.regionDataUS = regionData
					downloadTime = SecondsToTime(time() - lastUpdate).." ago"
				end
			elseif realm == "EU" then
				local regionData, lastUpdate = TSM:LoadRegionAppData(data)
				if regionData then
					TSM.regionDataEU = regionData
					downloadTime = SecondsToTime(time() - lastUpdate).." ago"
				end
			elseif TSMAPI.AppHelper:IsCurrentRealm(realm) then
				realmAppData = TSM:ProcessRealmAppData(data)
				downloadTime = SecondsToTime(time() - realmAppData.downloadTime).." ago"
			end
			TSM:LOG_INFO("Got AppData for %s (isCurrent=%s, %s)", realm, tostring(TSMAPI.AppHelper:IsCurrentRealm(realm)), downloadTime)
		end
	end

	-- check if we can load realm data from the app
	if realmAppData and (realmAppData.downloadTime > TSMCore.db.realm.internalData.lastAuctionDBCompleteScan or (realmAppData.downloadTime == TSMCore.db.realm.internalData.lastAuctionDBCompleteScan)) then
		TSM.updatedRealmData = (realmAppData.downloadTime > TSMCore.db.realm.internalData.lastAuctionDBCompleteScan)
		TSMCore.db.realm.internalData.lastAuctionDBCompleteScan = realmAppData.downloadTime
		TSM.realmData = {}
		local fields = realmAppData.fields
		for _, data in ipairs(realmAppData.data) do
			local itemString
			for i, key in ipairs(fields) do
				if i == 1 then
					-- item string must be the first field
					if type(data[i]) == "number" then
						itemString = "i:"..data[i]
					else
						itemString = gsub(data[i], ":0:", "::")
					end
					TSM.realmData[itemString] = {}
				else
					TSM.realmData[itemString][key] = data[i]
				end
			end
			TSM.realmData[itemString].lastScan = realmAppData.downloadTime
		end
	else
		TSM.Compress:LoadRealmData()
	end

	TSM.regionDataEU = TSM.regionDataEU or {}
	TSM.regionDataUS = TSM.regionDataUS or {}
	for itemString in pairs(TSM.realmData) do
		TSMAPI_FOUR.Item.FetchInfo(itemString)
	end
	if not next(TSM.realmData) then
		TSMAPI_FOUR.Util.ShowStaticPopupDialog("TSM_AUCTIONDB_NO_DATA_POPUP")
	end
	collectgarbage()
end

function TSM:ProcessRealmAppData(rawData)
	if #rawData < 3500000 then
		-- we can safely just use loadstring() for strings below 3.5M
		return assert(loadstring(rawData)())
	end
	-- load the data in chunks
	local leader, itemData, trailer = strmatch(rawData, "^(.+)data={({.+})}(.+)$")
	local resultData = {}
	local chunkStart, chunkEnd, nextChunkStart = 1, nil, nil
	while chunkStart do
		chunkEnd, nextChunkStart = strfind(itemData, "},{", chunkStart + 3400000)
		local chunkData = assert(loadstring("return {"..strsub(itemData, chunkStart, chunkEnd).."}")())
		for _, data in ipairs(chunkData) do
			tinsert(resultData, data)
		end
		chunkStart = nextChunkStart
	end
	__AUCTIONDB_IMPORT_TEMP = resultData
	local result = assert(loadstring(leader.."data=__AUCTIONDB_IMPORT_TEMP"..trailer)())
	__AUCTIONDB_IMPORT_TEMP = nil
	return result
end

function TSM:LoadRegionAppData(appData)
	local code = [[
		local result = ...
		for _, data in ipairs(%s) do
			-- item string must be the first field
			local itemString = data[1]
			if type(itemString) == "number" then
				itemString = "i:"..itemString
			else
				itemString = gsub(itemString, ":0:", "::")
			end
			tinsert(result, data)
			result.itemLookup[itemString] = #result
		end
	]]
	local leader, itemData, trailer = strmatch(appData, "^return (.+),data={({.+})}(.+)$")
	local partialData = assert(loadstring("return "..leader..trailer))()
	local result = { fieldLookup = {}, itemLookup = {} }
	for i, field in ipairs(partialData.fields) do
		result.fieldLookup[field] = i
	end
	-- load the data in ~1MB chunks
	local chunkStart, chunkEnd, nextChunkStart = 1, nil, nil
	while chunkStart do
		chunkEnd, nextChunkStart = strfind(itemData, "},{", chunkStart + 1000000)
		local chunkCode = format(code, "{"..strsub(itemData, chunkStart, chunkEnd).."}")
		assert(loadstring(chunkCode))(result)
		chunkStart = nextChunkStart
	end
	return result, partialData.downloadTime
end

function TSM:OnTSMDBShutdown()
	TSM.Compress:SaveRealmData()
end

local TOOLTIP_STRINGS = {
	minBuyout = {L["Min Buyout:"], L["Min Buyout x%s:"]},
	marketValue = {L["Market Value:"], L["Market Value x%s:"]},
	historical = {L["Historical Price:"], L["Historical Price x%s:"]},
	regionMinBuyout = {L["Region Min Buyout Avg:"], L["Region Min Buyout Avg x%s:"]},
	regionMarketValue = {L["Region Market Value Avg:"], L["Region Market Value Avg x%s:"]},
	regionHistorical = {L["Region Historical Price:"], L["Region Historical Price x%s:"]},
	regionSale = {L["Region Sale Avg:"], L["Region Sale Avg x%s:"]},
	regionSalePercent = {L["Region Sale Rate:"], L["Region Sale Rate x%s:"]},
	regionSoldPerDay = {L["Region Avg Daily Sold:"], L["Region Avg Daily Sold x%s:"]},
	globalMinBuyout = {L["Global Min Buyout Avg:"], L["Global Min Buyout Avg x%s:"]},
	globalMarketValue = {L["Global Market Value Avg:"], L["Global Market Value Avg x%s:"]},
	globalHistorical = {L["Global Historical Price:"], L["Global Historical Price x%s:"]},
	globalSale = {L["Global Sale Avg:"], L["Global Sale Avg x%s:"]},
}
local function TooltipMoneyFormat(value, quantity, moneyCoins)
	return TSMAPI_FOUR.Money.ToString(value*quantity, "|cffffffff", "OPT_PAD", moneyCoins and "OPT_ICON" or nil)
end
local function TooltipX100Format(value)
	return "|cffffffff"..format("%0.2f", value/100).."|r"
end
local function InsertTooltipValueLine(itemString, quantity, key, scope, lines, options, formatter, ...)
	if not options[key] then return end
	local value = nil
	if scope == "global" then
		value = TSM.GetGlobalItemData(itemString, key)
	elseif scope == "region" then
		value = TSM.GetRegionItemData(itemString, key)
	elseif scope == "realm" then
		value = TSM.GetRealmItemData(itemString, key)
	else
		error("Invalid scope: "..tostring(scope))
	end
	if not value then return end
	local strings = TOOLTIP_STRINGS[key]
	assert(strings, "Could not find tooltip strings for :"..tostring(key))

	local leftStr = "  "..(quantity > 1 and format(strings[2], quantity) or strings[1])
	local rightStr = formatter(value, quantity, ...)
	tinsert(lines, {left=leftStr, right=rightStr})
end

function TSM.LoadTooltip(itemString, quantity, options, moneyCoins, lines)
	if not itemString then return end
	local numStartingLines = #lines

	-- add min buyout
	InsertTooltipValueLine(itemString, quantity, "minBuyout", "realm", lines, options, TooltipMoneyFormat, moneyCoins)
	-- add market value
	InsertTooltipValueLine(itemString, quantity, "marketValue", "realm", lines, options, TooltipMoneyFormat, moneyCoins)
	-- add historical price
	InsertTooltipValueLine(itemString, quantity, "historical", "realm", lines, options, TooltipMoneyFormat, moneyCoins)
	-- add region min buyout
	InsertTooltipValueLine(itemString, quantity, "regionMinBuyout", "region", lines, options, TooltipMoneyFormat, moneyCoins)
	-- add region market value
	InsertTooltipValueLine(itemString, quantity, "regionMarketValue", "region", lines, options, TooltipMoneyFormat, moneyCoins)
	-- add region historical price
	InsertTooltipValueLine(itemString, quantity, "regionHistorical", "region", lines, options, TooltipMoneyFormat, moneyCoins)
	-- add region sale avg
	InsertTooltipValueLine(itemString, quantity, "regionSale", "region", lines, options, TooltipMoneyFormat, moneyCoins)
	-- add region sale rate
	InsertTooltipValueLine(itemString, quantity, "regionSalePercent", "region", lines, options, TooltipX100Format)
	-- add region sold per day
	InsertTooltipValueLine(itemString, quantity, "regionSoldPerDay", "region", lines, options, TooltipX100Format)
	-- add global min buyout
	InsertTooltipValueLine(itemString, quantity, "globalMinBuyout", "global", lines, options, TooltipMoneyFormat, moneyCoins)
	-- add global market value
	InsertTooltipValueLine(itemString, quantity, "globalMarketValue", "global", lines, options, TooltipMoneyFormat, moneyCoins)
	-- add global historical price
	InsertTooltipValueLine(itemString, quantity, "globalHistorical", "global", lines, options, TooltipMoneyFormat, moneyCoins)
	-- add global sale avg
	InsertTooltipValueLine(itemString, quantity, "globalSale", "global", lines, options, TooltipMoneyFormat, moneyCoins)

	-- add the header if we've added at least one line
	if #lines > numStartingLines then
		local lastScan = TSM.GetRealmItemData(itemString, "lastScan")
		local rightStr = "|cffffffff"..L["Not Scanned"].."|r"
		if lastScan then
			local timeColor = (time() - lastScan) > 60*60*3 and "|cffff0000" or "|cff00ff00"
			local timeDiff = SecondsToTime(time() - lastScan)
			local numAuctions = TSM.GetRealmItemData(itemString, "numAuctions") or 0
			rightStr = format("%s (%s)", format("|cffffffff"..L["%d auctions"].."|r", numAuctions), format(timeColor..L["%s ago"].."|r", timeDiff))
		end
		tinsert(lines, numStartingLines+1, {left="|cffffff00TSM AuctionDB:|r", right=rightStr})
	end
end

function TSM.GetLastCompleteScanTime()
	return TSMCore.db.realm.internalData.lastAuctionDBCompleteScan
end

function TSM.LastScanIteratorThreaded()
	local itemNumAuctions = TSMAPI_FOUR.Thread.AcquireSafeTempTable()
	local itemMinBuyout = TSMAPI_FOUR.Thread.AcquireSafeTempTable()
	local baseItems = TSMAPI_FOUR.Thread.AcquireSafeTempTable()

	for itemString, data in pairs(TSM.realmData) do
		if data.lastScan >= TSMCore.db.realm.internalData.lastAuctionDBCompleteScan then
			itemString = TSMAPI_FOUR.Item.ToItemString(itemString)
			local baseItemString = TSMAPI_FOUR.Item.ToBaseItemString(itemString)
			if baseItemString ~= itemString then
				baseItems[baseItemString] = true
			end
			if not itemNumAuctions[itemString] then
				itemNumAuctions[itemString] = 0
			end
			itemNumAuctions[itemString] = itemNumAuctions[itemString] + data.numAuctions
			if data.minBuyout and data.minBuyout > 0 then
				itemMinBuyout[itemString] = min(itemMinBuyout[itemString] or math.huge, data.minBuyout)
			end
		end
		TSMAPI_FOUR.Thread.Yield()
	end

	-- remove the base items since they would be double-counted with the specific variants
	for itemString in pairs(baseItems) do
		itemNumAuctions[itemString] = nil
		itemMinBuyout[itemString] = nil
	end
	TSMAPI_FOUR.Thread.ReleaseSafeTempTable(baseItems)

	-- convert the remaining items into a list
	local itemList = TSMAPI_FOUR.Thread.AcquireSafeTempTable()
	itemList.numAuctions = itemNumAuctions
	itemList.minBuyout = itemMinBuyout
	for itemString in pairs(itemNumAuctions) do
		tinsert(itemList, itemString)
	end
	return TSMAPI_FOUR.Util.TableIterator(itemList, private.LastScanIteratorHelper, itemList, private.LastScanIteratorCleanup)
end

function private.LastScanIteratorHelper(index, itemString, tbl)
	return index, itemString, tbl.numAuctions[itemString], tbl.minBuyout[itemString]
end

function private.LastScanIteratorCleanup(tbl)
	TSMAPI_FOUR.Thread.ReleaseSafeTempTable(tbl.numAuctions)
	TSMAPI_FOUR.Thread.ReleaseSafeTempTable(tbl.minBuyout)
	TSMAPI_FOUR.Thread.ReleaseSafeTempTable(tbl)
end

function private.GetItemDataHelper(tbl, key, itemString)
	if not itemString or not tbl then return end
	local value = nil
	if tbl[itemString] then
		value = tbl[itemString][key]
	else
		local quality = TSMAPI_FOUR.Item.GetQuality(itemString)
	if quality and quality >= 3 then
		if strmatch(itemString, "^i:[0-9]+:[0-9%-]*:") then return end
	end
		local baseItemString = TSMAPI_FOUR.Item.ToBaseItemString(itemString)
		if not baseItemString then return end
		value = tbl[baseItemString] and tbl[baseItemString][key]
	end
	if not value or value <= 0 then return end
	return value
end

function private.GetRegionItemDataHelper(tbl, key, itemString)
	if not itemString or not tbl then
		return
	end
	local fieldIndex = tbl.fieldLookup[key]
	assert(fieldIndex)
	local index = tbl.itemLookup[itemString]
	if not index and not strmatch(itemString, "^[ip]:[0-9]+$") then
		-- for items with random enchants or for pets, get data for the base item
		local quality = TSMAPI_FOUR.Item.GetQuality(itemString)
		if quality and quality >= 3 then
			if strmatch(itemString, "^i:[0-9]+:[0-9%-]*:") then
				return
			end
		end
		local baseItemString = TSMAPI_FOUR.Item.ToBaseItemString(itemString)
		if not baseItemString then return end
		index = tbl.itemLookup[baseItemString]
	end
	if not index then
		return
	end
	local value = tbl[index][fieldIndex]
	if not value or value <= 0 then
		return
	end
	return value
end

function TSM.GetRealmItemData(itemString, key)
	return private.GetItemDataHelper(TSM.realmData, key, itemString)
end

function TSM.GetRegionItemData(itemString, key)
	if private.region == "US" then
		return private.GetRegionItemDataHelper(TSM.regionDataUS, key, itemString)
	elseif private.region == "EU" then
		return private.GetRegionItemDataHelper(TSM.regionDataEU, key, itemString)
	else
		-- unsupported region (or PTR)
		return
	end
end

function TSM.GetRegionSaleInfo(itemString, key)
	-- need to divide the result by 100
	if private.region == "US" then
		local result = private.GetRegionItemDataHelper(TSM.regionDataUS, key, itemString)
		return result and (result / 100) or nil
	elseif private.region == "EU" then
		local result = private.GetRegionItemDataHelper(TSM.regionDataEU, key, itemString)
		return result and (result / 100) or nil
	else
		-- unsupported region (or PTR)
		return
	end
end

function TSM.GetGlobalItemData(itemString, key)
	-- translate to region keys
	if not private.globalKeyLookup[key] then
		private.globalKeyLookup[key] = gsub(key, "^global", "region")
	end
	key = private.globalKeyLookup[key]
	local valueUS = private.GetRegionItemDataHelper(TSM.regionDataUS, key, itemString)
	local valueEU = private.GetRegionItemDataHelper(TSM.regionDataEU, key, itemString)
	if valueUS and valueEU then
		-- average the regions to get the global value
		return TSMAPI_FOUR.Util.Round((valueUS + valueEU) / 2)
	elseif valueUS then
		return valueUS
	elseif valueEU then
		return valueEU
	else
		-- neither region has a valid price
		return
	end
end

function TSM.GetGlobalSaleInfo(itemString, key)
	if not private.globalKeyLookup[key] then
		private.globalKeyLookup[key] = gsub(key, "^global", "region")
	end
	key = private.globalKeyLookup[key]
	local valueUS = private.GetRegionItemDataHelper(TSM.regionDataUS, key, itemString)
	local valueEU = private.GetRegionItemDataHelper(TSM.regionDataEU, key, itemString)
	if valueUS and valueEU then
		-- average the regions to get the global value
		return TSMAPI_FOUR.Util.Round((valueUS + valueEU) / 2) / 100
	elseif valueUS then
		return valueUS / 100
	elseif valueEU then
		return valueEU / 100
	else
		-- neither region has a valid price
		return
	end
end
