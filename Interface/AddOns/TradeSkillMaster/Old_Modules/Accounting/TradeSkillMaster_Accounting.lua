-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- register this file with Ace Libraries
local TSMCore = select(2, ...)
TSMCore.old.Accounting = TSMCore.old.Accounting or {}
local TSM = TSMAPI_FOUR.Addon.New("TradeSkillMaster_Accounting", TSMCore.old.Accounting)
TSM.SELL_KEYS = { "itemString", "stackSize", "quantity", "price", "buyer", "player", "time", "source" }
TSM.BUY_KEYS = { "itemString", "stackSize", "quantity", "price", "seller", "player", "time", "source" }
TSM.INCOME_KEYS = { "type", "amount", "source", "player", "time" }
TSM.EXPENSE_KEYS = { "type", "amount", "destination", "player", "time" }
TSM.EXPIRED_KEYS = { "itemString", "stackSize", "quantity", "player", "time" }
TSM.CANCELLED_KEYS = { "itemString", "stackSize", "quantity", "player", "time" }
TSM.GOLD_LOG_KEYS = { "startMinute", "endMinute", "copper" }
local MAX_CSV_RECORDS = 55000
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local LibParse = LibStub("LibParse")
local baseItemLookup = { update = 0 }

local tooltipDefaults = {
	sale = true,
	expiredAuctions = false,
	cancelledAuctions = false,
	saleRate = false,
	purchase = true,
}

-- Called once the player has loaded WOW.
function TSM:OnInitialize()
	TSM:RegisterTooltipInfo(tooltipDefaults, TSM.LoadTooltip, TSM.Options.LoadTooltipOptions)

	TSM:RegisterModuleAPI("getAuctionStatsSinceLastSale", TSM.GetAuctionStatsSinceLastSale)

	TSM:RegisterPriceSource("avgSell", L["Avg Sell Price"], TSM.GetAvgSellPrice)
	TSM:RegisterPriceSource("maxSell", L["Max Sell Price"], TSM.GetMaxSellPrice)
	TSM:RegisterPriceSource("minSell", L["Min Sell Price"], TSM.GetMinSellPrice)
	TSM:RegisterPriceSource("avgBuy", L["Avg Buy Price"], TSM.GetAvgBuyPrice)
	TSM:RegisterPriceSource("maxBuy", L["Max Buy Price"], TSM.GetMaxBuyPrice)
	TSM:RegisterPriceSource("minBuy", L["Min Buy Price"], TSM.GetMinBuyPrice)
	TSM:RegisterPriceSource("NumExpires", L["Expires Since Last Sale"], TSM.GetNumExpires)

	-- FIXME: keep Accounting working in the old settings UI for now
	TSM.moduleOptions = { callback = TSM.Options.Load }

	TSMAPI_FOUR.Modules.Register(TSM)

	for key, timestamp in pairs(TSMCore.db.realm.internalData.accountingTrimmed) do
		TSM:Printf(L["|cffff0000IMPORTANT:|r When TSM_Accounting last saved data for this realm, it was too big for WoW to handle, so old data was automatically trimmed in order to avoid corruption of the saved variables. The last %s of %s data has been preserved."], SecondsToTime(time() - timestamp), key)
	end
	wipe(TSMCore.db.realm.internalData.accountingTrimmed)

	TSM.Data:Load()

	-- fix issues in gold log
	for player, playerData in pairs(TSM.goldLog) do
		for i = #playerData, 1, -1 do
			local data = playerData[i]
			data.startMinute = floor(data.startMinute)
			data.endMinute = floor(data.endMinute)
			if data.startMinute == data.endMinute and data.copper == 0 then
				tremove(playerData, i)
			else
				-- round to nearest 1k gold
				data.copper = TSMAPI_FOUR.Util.Round(data.copper, COPPER_PER_GOLD * 1000)
			end
		end
		if #playerData >= 2 then
			for i = 2, #playerData do
				playerData[i].startMinute = playerData[i - 1].endMinute + 1
			end
			for i = #playerData - 1, 1, -1 do
				if playerData[i].copper == playerData[i + 1].copper then
					playerData[i].endTime = playerData[i + 1].endTime
					tremove(playerData, i + 1)
				end
			end
			for i = #playerData - 2, 1, -1 do
				i = min(i, #playerData - 2)
				if i < 1 then break end
				if playerData[i].copper == playerData[i + 2].copper and playerData[i + 1].copper == 0 then
					playerData[i].endTime = playerData[i + 2].endTime
					tremove(playerData, i + 2)
					tremove(playerData, i + 1)
				end
			end
		end
	end

	-- fix issues with repair expenses
	for i, data in pairs(TSM.money.expense) do
		if data.key == "Repair" and data.copper > 8000000 then
			tremove(TSM.money.expense, i)
		end
	end
end

function TSM.LoadTooltip(itemString, quantity, options, moneyCoins, lines)
	TSM.UpdateBaseItemLookup()
	if not TSM.items[itemString] and not baseItemLookup[itemString] then return end
	local numStartingLines = #lines
	TSM.cache[itemString] = TSM.cache[itemString] or {}
	wipe(TSM.cache[itemString])

	local avgSalePrice, totalSaleNum = nil, nil
	if options.sale or options.saleRate then
		avgSalePrice, totalSaleNum = TSM.GetAvgSellPrice(itemString)
		totalSaleNum = totalSaleNum or 0
	end
	local lastSold = 0
	if options.sale and totalSaleNum > 0 then
		local totalSalePrice = avgSalePrice * totalSaleNum
		if TSM.items[itemString] then
			for i = #TSM.items[itemString].sales, 1, -1 do
				local record = TSM.items[itemString].sales[i]
				if record.key ~= "Vendor" then
					lastSold = record.time
					break
				end
			end
		else
			for _, item in ipairs(baseItemLookup[itemString]) do
				for i = #TSM.items[item].sales, 1, -1 do
					local record = TSM.items[item].sales[i]
					if record.key ~= "Vendor" then
						lastSold = record.time
						break
					end
				end
			end
		end

		if IsShiftKeyDown() then
			tinsert(lines, { left = "  " .. L["Sold (Total Price):"], right = format("%s (%s)", "|cffffffff" .. totalSaleNum .. "|r", (TSMAPI_FOUR.Money.ToString(totalSalePrice, "|cffffffff", "OPT_PAD", moneyCoins and "OPT_ICON" or nil) or "|cffffffff?|r")) })
		else
			local minPrice = TSM.GetMinSellPrice(itemString)
			local maxPrice = nil
			if TSM.items[itemString] then
				maxPrice = TSM.GetMaxSellPrice(itemString)
			else
				for _, item in ipairs(baseItemLookup[itemString]) do
					maxPrice = max(TSM.GetMaxSellPrice(item) or 0, maxPrice or 0)
				end
				if maxPrice == 0 then
					maxPrice = nil
				end
			end
			tinsert(lines, { left = "  " .. L["Sold (Min/Avg/Max Price):"], right = format("%s (%s / %s / %s)", "|cffffffff" .. totalSaleNum .. "|r", (TSMAPI_FOUR.Money.ToString(minPrice, "|cffffffff", "OPT_PAD", moneyCoins and "OPT_ICON" or nil) or "|cffffffff?|r"), (TSMAPI_FOUR.Money.ToString(avgSalePrice, "|cffffffff", "OPT_PAD", moneyCoins and "OPT_ICON" or nil) or "|cffffffff?|r"), (TSMAPI_FOUR.Money.ToString(maxPrice, "|cffffffff", "OPT_PAD", moneyCoins and "OPT_ICON" or nil) or "|cffffffff?|r")) })
		end
		if lastSold > 0 then
			local timeDiff = SecondsToTime(time() - lastSold)
			tinsert(lines, { left = "  " .. L["Last Sold:"], right = "|cffffffff" .. format(L["%s ago"], timeDiff) })
		end
	end

	local cancelledNum, expiredNum, totalFailed = TSM.GetAuctionStats(itemString, lastSold)
	if expiredNum > 0 and cancelledNum > 0 and options.expiredAuctions and options.cancelledAuctions then
		tinsert(lines, { left = "  " .. L["Failed Since Last Sale (Expired/Cancelled):"], right = format("|cffffffff%s|r (|cffffffff%s|r/|cffffffff%s|r)", expiredNum + cancelledNum, expiredNum, cancelledNum) })
	elseif expiredNum > 0 and options.expiredAuctions then
		tinsert(lines, { left = "  " .. L["Expired Since Last Sale:"], right = "|cffffffff" .. expiredNum .. "|r" })
	elseif cancelledNum > 0 and options.cancelledAuctions then
		tinsert(lines, { left = "  " .. L["Cancelled Since Last Sale:"], right = "|cffffffff" .. cancelledNum .. "|r" })
	end

	if options.saleRate and totalSaleNum > 0 and totalFailed > 0 then
		local saleRate = TSMAPI_FOUR.Util.Round(totalSaleNum / (totalSaleNum + totalFailed or 0), 0.01)
		tinsert(lines, { left = "  " .. L["Sale Rate:"], right = "|cffffffff" .. saleRate .. "|r" })
	end

	local lastPurchased, totalBuyPrice, totalBuyNum = nil, 0, 0
	if TSM.items[itemString] then
		for i = #TSM.items[itemString].buys, 1, -1 do
			local record = TSM.items[itemString].buys[i]
			if record.key ~= "Vendor" then
				lastPurchased = lastPurchased or record.time
				totalBuyPrice = totalBuyPrice + record.copper * record.quantity
				totalBuyNum = totalBuyNum + record.quantity
			end
		end
	else
		for _, item in ipairs(baseItemLookup[itemString]) do
			for i = #TSM.items[item].buys, 1, -1 do
				local record = TSM.items[item].buys[i]
				if record.key ~= "Vendor" then
					lastPurchased = lastPurchased or record.time
					totalBuyPrice = totalBuyPrice + record.copper * record.quantity
					totalBuyNum = totalBuyNum + record.quantity
				end
			end
		end
	end
	if options.purchase and lastPurchased then
		if IsShiftKeyDown() then
			tinsert(lines, { left = "  " .. L["Purchased (Total Price):"], right = format("|cffffffff%s|r (%s)", totalBuyNum, (TSMAPI_FOUR.Money.ToString(totalBuyPrice, "|cffffffff", "OPT_PAD", moneyCoins and "OPT_ICON" or nil) or "|cffffffff?|r")) })
		else
			local minPrice = TSM.GetMinBuyPrice(itemString)
			local avgPrice = TSM.GetAvgBuyPrice(itemString)
			local maxPrice = TSM.GetMaxBuyPrice(itemString)
			tinsert(lines, { left = "  " .. L["Purchased (Min/Avg/Max Price):"], right = format("|cffffffff%s|r (%s / %s / %s)", totalBuyNum, (TSMAPI_FOUR.Money.ToString(minPrice, "|cffffffff", "OPT_PAD", moneyCoins and "OPT_ICON" or nil) or "|cffffffff?|r"), (TSMAPI_FOUR.Money.ToString(avgPrice, "|cffffffff", "OPT_PAD", moneyCoins and "OPT_ICON" or nil) or "|cffffffff?|r"), (TSMAPI_FOUR.Money.ToString(maxPrice, "|cffffffff", "OPT_PAD", moneyCoins and "OPT_ICON" or nil) or "|cffffffff?|r")) })
		end
		local timeDiff = SecondsToTime(time() - lastPurchased)
		tinsert(lines, { left = "  " .. L["Last Purchased:"], right = "|cffffffff" .. format(L["%s ago"] .. "|r", timeDiff) })
	end

	-- add heading
	if #lines > numStartingLines then
		tinsert(lines, numStartingLines + 1, "|cffffff00TSM Accounting:|r")
	end
end

function TSM:OnTSMDBShutdown()
	-- process items
	local sales, buys, cancels, expires = {}, {}, {}, {}
	local saveTimeSales, saveTimeBuys, saveTimeExpires, saveTimeCancels = {}, {}, {}, {}
	for itemString, data in pairs(TSM.items) do
		-- process sales
		for _, record in ipairs(data.sales) do
			record.itemString = itemString
			record.buyer = record.otherPlayer
			record.source = record.key
			record.price = record.copper
			if record.key == "Auction" then
				record.saveTime = record.saveTime or time()
				tinsert(saveTimeSales, record.saveTime)
			end
			tinsert(sales, record)
		end

		-- process buys
		for _, record in ipairs(data.buys) do
			record.itemString = itemString
			record.seller = record.otherPlayer
			record.source = record.key
			record.price = record.copper
			if record.key == "Auction" then
				record.saveTime = record.saveTime or time()
				tinsert(saveTimeBuys, record.saveTime)
			end
			tinsert(buys, record)
		end

		-- process auctions
		for _, record in ipairs(data.auctions) do
			record.itemString = itemString
			if record.key == "Cancel" then
				record.saveTime = record.saveTime or time()
				tinsert(saveTimeCancels, record.saveTime)
				tinsert(cancels, record)
			elseif record.key == "Expire" then
				record.saveTime = record.saveTime or time()
				tinsert(saveTimeExpires, record.saveTime)
				tinsert(expires, record)
			end
		end
	end

	-- trim anything that'll be too long
	for key, data in pairs({ ["sales"] = sales, ["buys"] = buys }) do
		if #data > MAX_CSV_RECORDS then
			sort(data, function(a, b) return a.time > b.time end)
			while (#data > floor(MAX_CSV_RECORDS * 0.9)) do
				tremove(data)
			end
			TSMCore.db.realm.internalData.accountingTrimmed[key] = data[#data].time
		end
	end

	TSMCore.db.realm.internalData.saveTimeSales = table.concat(saveTimeSales, ",")
	TSMCore.db.realm.internalData.saveTimeBuys = table.concat(saveTimeBuys, ",")
	TSMCore.db.realm.internalData.saveTimeExpires = table.concat(saveTimeExpires, ",")
	TSMCore.db.realm.internalData.saveTimeCancels = table.concat(saveTimeCancels, ",")
	TSMCore.db.realm.internalData.csvSales = LibParse:CSVEncode(TSM.SELL_KEYS, sales)
	TSMCore.db.realm.internalData.csvBuys = LibParse:CSVEncode(TSM.BUY_KEYS, buys)
	TSMCore.db.realm.internalData.csvCancelled = LibParse:CSVEncode(TSM.CANCELLED_KEYS, cancels)
	TSMCore.db.realm.internalData.csvExpired = LibParse:CSVEncode(TSM.EXPIRED_KEYS, expires)

	-- process income
	local income = {}
	for _, record in ipairs(TSM.money.income) do
		if record.key == "Transfer" then
			record.type = "Money Transfer"
			record.source = record.otherPlayer
			record.amount = record.copper
			tinsert(income, record)
		elseif record.key == "Garrison" then
			record.type = "Garrison"
			record.source = "Mission"
			record.amount = record.copper
			tinsert(income, record)
		end
	end
	TSMCore.db.realm.internalData.csvIncome = LibParse:CSVEncode(TSM.INCOME_KEYS, income)

	-- process expense
	local expense = {}
	for _, record in ipairs(TSM.money.expense) do
		record.amount = record.copper
		record.destination = record.otherPlayer
		if record.key == "Transfer" then
			record.type = "Money Transfer"
			tinsert(expense, record)
		elseif record.key == "Postage" then
			record.type = "Postage"
			tinsert(expense, record)
		elseif record.key == "Repair" then
			record.type = "Repair Bill"
			tinsert(expense, record)
		end
	end
	TSMCore.db.realm.internalData.csvExpense = LibParse:CSVEncode(TSM.EXPENSE_KEYS, expense)

	-- process gold log
	TSM.GoldTracker:LoggingOut()
	for player, data in pairs(TSM.goldLog) do
		if type(data) == "table" then
			TSMCore.db.realm.internalData.goldLog[player] = LibParse:CSVEncode(TSM.GOLD_LOG_KEYS, data)
		end
	end
end

function TSM.UpdateBaseItemLookup(force)
	if time() - baseItemLookup.update < 30 and not force then return end
	wipe(baseItemLookup)
	baseItemLookup.update = time()
	for itemString in pairs(TSM.items) do
		local baseItemString = TSMAPI_FOUR.Item.ToBaseItemString(itemString)
		if baseItemString ~= itemString then
			baseItemLookup[baseItemString] = baseItemLookup[baseItemString] or {}
			tinsert(baseItemLookup[baseItemString], itemString)
		end
	end
end

local function GetAuctionStats(itemString, minTime)
	local cancel, expire, total = 0, 0, 0
	if TSM.items[itemString] then
		for _, record in ipairs(TSM.items[itemString].auctions) do
			if record.key == "Cancel" and record.time > minTime then
				cancel = cancel + record.quantity
			elseif record.key == "Expire" and record.time > minTime then
				expire = expire + record.quantity
			end
			total = total + record.quantity
		end
	elseif baseItemLookup[itemString] then
		for _, item in ipairs(baseItemLookup[itemString]) do
			for _, record in ipairs(TSM.items[item].auctions) do
				if record.key == "Cancel" and record.time > minTime then
					cancel = cancel + record.quantity
				elseif record.key == "Expire" and record.time > minTime then
					expire = expire + record.quantity
				end
				total = total + record.quantity
			end
		end
	end
	return cancel, expire, total
end

function TSM.GetAuctionStats(itemString, minTime)
	minTime = minTime or 0
	if not itemString then return end
	if not TSM.cache[itemString] then
		TSM.UpdateBaseItemLookup()
		TSM.cache[itemString] = TSM.cache[itemString] or {}
		wipe(TSM.cache[itemString])
	end
	if not TSM.cache[itemString].totalFailed then
		local cancel, expire, total = GetAuctionStats(itemString, minTime)
		TSM.cache[itemString].totalCancel = cancel
		TSM.cache[itemString].totalExpire = expire
		TSM.cache[itemString].totalFailed = total
	end
	return TSM.cache[itemString].totalCancel, TSM.cache[itemString].totalExpire, TSM.cache[itemString].totalFailed
end

local function GetAverageSellPrice(itemString, noBaseItem)
	if not noBaseItem and itemString and baseItemLookup[itemString] then
		local totalPrice, totalNum = 0, 0
		for _, item in ipairs(baseItemLookup[itemString]) do
			local price, num = GetAverageSellPrice(item, true)
			if price and num and num > 0 then
				totalPrice = totalPrice + price
				totalNum = totalNum + num
			end
		end
		if totalNum > 0 then
			return TSMAPI_FOUR.Util.Round(totalPrice / totalNum), totalNum
		end
	end
	if not TSM.items[itemString] then return end

	local totalPrice, totalSaleNum = 0, 0
	for _, record in ipairs(TSM.items[itemString].sales) do
		if record.key ~= "Vendor" then
			totalSaleNum = totalSaleNum + record.quantity
			totalPrice = totalPrice + record.copper * record.quantity
		end
	end

	if totalSaleNum == 0 then return end
	return TSMAPI_FOUR.Util.Round(totalPrice / totalSaleNum), totalSaleNum
end

function TSM.GetAvgSellPrice(itemString)
	if not itemString then return end
	TSM.UpdateBaseItemLookup()
	TSM.cache[itemString] = TSM.cache[itemString] or {}
	wipe(TSM.cache[itemString])
	if not TSM.cache[itemString].avgSellPrice then
		local price, num = GetAverageSellPrice(itemString)
		TSM.cache[itemString].avgSellPrice = price
		TSM.cache[itemString].avgSellNum = num
	end
	return TSM.cache[itemString].avgSellPrice, TSM.cache[itemString].avgSellNum
end

local function GetAverageBuyPrice(itemString, noBaseItem)
	if not noBaseItem and itemString and baseItemLookup[itemString] then
		local totalPrice, totalNum = 0, 0
		for _, item in ipairs(baseItemLookup[itemString]) do
			if not baseItemLookup[item] then
				local price, num = GetAverageBuyPrice(item, true)
				if price and num and num > 0 then
					totalPrice = totalPrice + price
					totalNum = totalNum + num
				end
			end
		end
		if totalNum > 0 then
			return TSMAPI_FOUR.Util.Round(totalPrice / totalNum), totalNum
		end
	end
	if not TSM.items[itemString] then return end

	local itemCount = TSMCore.db.global.accountingOptions.smartBuyPrice and TSMAPI_FOUR.Inventory.GetTotalQuantity(itemString) or 0
	local totalNum, totalPrice = 0, 0
	for i = #TSM.items[itemString].buys, 1, -1 do
		local record = TSM.items[itemString].buys[i]
		if record.key ~= "Vendor" then
			for j = 1, record.quantity do
				totalNum = totalNum + 1
				totalPrice = totalPrice + record.copper
				if itemCount > 0 and totalNum >= itemCount then break end
			end
			if itemCount > 0 and totalNum >= itemCount then break end
		end
	end

	if totalNum == 0 then return end
	return TSMAPI_FOUR.Util.Round(totalPrice / totalNum), totalNum
end

function TSM.GetAvgBuyPrice(itemString)
	if not itemString then return end
	TSM.cache[itemString] = TSM.cache[itemString] or {}
	wipe(TSM.cache[itemString])
	TSM.UpdateBaseItemLookup()
	if not TSM.cache[itemString].avgBuyPrice then
		local price, num = GetAverageBuyPrice(itemString)
		TSM.cache[itemString].avgBuyPrice = price
		TSM.cache[itemString].avgBuyNum = num
	end
	return TSM.cache[itemString].avgBuyPrice, TSM.cache[itemString].avgBuyNum
end

function TSM.GetMaxSellPrice(itemString)
	if not (itemString and TSM.items[itemString] and #TSM.items[itemString].sales > 0) then return end
	TSM.cache[itemString] = TSM.cache[itemString] or {}
	wipe(TSM.cache[itemString])

	local maxPrice = 0
	if not TSM.cache[itemString].maxSellPrice then
		for _, record in ipairs(TSM.items[itemString].sales) do
			if record.key ~= "Vendor" then
				maxPrice = max(maxPrice, record.copper)
			end
		end
		TSM.cache[itemString].maxSellPrice = maxPrice
	end
	if maxPrice == 0 then return end

	return TSM.cache[itemString].maxSellPrice
end

function TSM.GetMaxBuyPrice(itemString)
	if not (itemString and TSM.items[itemString] and #TSM.items[itemString].buys > 0) then return end
	TSM.cache[itemString] = TSM.cache[itemString] or {}
	wipe(TSM.cache[itemString])

	local maxPrice = 0
	if not TSM.cache[itemString].maxBuyPrice then
		for _, record in ipairs(TSM.items[itemString].buys) do
			if record.key ~= "Vendor" then
				maxPrice = max(maxPrice, record.copper)
			end
		end
		TSM.cache[itemString].maxBuyPrice = maxPrice
	end
	if maxPrice == 0 then return end

	return TSM.cache[itemString].maxBuyPrice
end

function TSM.GetMinSellPrice(itemString)
	if not (itemString and TSM.items[itemString] and #TSM.items[itemString].sales > 0) then return end
	TSM.cache[itemString] = TSM.cache[itemString] or {}
	wipe(TSM.cache[itemString])

	local minPrice = 0
	if not TSM.cache[itemString].minSellPrice then
		for _, record in ipairs(TSM.items[itemString].sales) do
			if record.key ~= "Vendor" then
				minPrice = (minPrice > 0 and min(minPrice, record.copper)) or record.copper
			end
		end
		TSM.cache[itemString].minSellPrice = minPrice
	end
	if minPrice == 0 then return end

	return TSM.cache[itemString].minSellPrice
end

function TSM.GetMinBuyPrice(itemString)
	if not (itemString and TSM.items[itemString] and #TSM.items[itemString].buys > 0) then return end
	TSM.cache[itemString] = TSM.cache[itemString] or {}
	wipe(TSM.cache[itemString])

	local minPrice = 0
	if not TSM.cache[itemString].minBuyPrice then
		for _, record in ipairs(TSM.items[itemString].buys) do
			if record.key ~= "Vendor" then
				minPrice = (minPrice > 0 and min(minPrice, record.copper)) or record.copper
			end
		end
		TSM.cache[itemString].minBuyPrice = minPrice
	end
	if minPrice == 0 then return end

	return TSM.cache[itemString].minBuyPrice
end

function TSM.GetAuctionStatsSinceLastSale(itemString)
	if not TSM.items[itemString] and not baseItemLookup[itemString] then return 0 end
	local lastSold = 0
	if TSM.items[itemString] then
		for i = #TSM.items[itemString].sales, 1, -1 do
			local record = TSM.items[itemString].sales[i]
			if record.key ~= "Vendor" then
				lastSold = record.time
				break
			end
		end
	else
		for _, item in ipairs(baseItemLookup[itemString]) do
			for i = #TSM.items[item].sales, 1, -1 do
				local record = TSM.items[item].sales[i]
				if record.key ~= "Vendor" then
					lastSold = record.time
					break
				end
			end
		end
	end
	return TSM.GetAuctionStats(itemString, lastSold)
end

function TSM.GetNumExpires(itemString)
	local _, numExpires = TSM.GetAuctionStatsSinceLastSale(itemString)
	return numExpires
end
