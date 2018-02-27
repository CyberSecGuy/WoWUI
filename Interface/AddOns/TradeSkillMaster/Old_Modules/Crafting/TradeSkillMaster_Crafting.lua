-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Crafting                           --
--            http://www.curse.com/addons/wow/tradeskillmaster_crafting           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSMCore = select(2, ...)
TSMCore.old.Crafting = TSMCore.old.Crafting or {}
local TSM = TSMAPI_FOUR.Addon.New("TradeSkillMaster_Crafting", TSMCore.old.Crafting)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table

TSM.VELLUM_ITEM_STRING = "i:38682"
TSM.MASS_MILLING_RECIPES = {
	[190381] = "i:114931",  -- Frostweed
	[190382] = "i:114931",  -- Fireweed
	[190383] = "i:114931",  -- Gorgrond Flytrap
	[190384] = "i:114931",  -- Starflower
	[190385] = "i:114931",  -- Nargrand Arrowbloom
	[190386] = "i:114931",  -- Talador Orchid
}

local tooltipDefaults = {
	craftingCost = true,
	matPrice = false,
	detailedMats = false,
}
local operationDefaults = {
	minRestock = 1, -- min of 1
	maxRestock = 3, -- max of 3
	minProfit = 1000000,
	craftPriceMethod = nil,
}
TSM.operationDefaults = operationDefaults

-- Called once the player has loaded WOW.
function TSM:OnInitialize()
	TSM:UpdateCraftReverseLookup()

	TSM:RegisterTooltipInfo(tooltipDefaults, TSM.LoadTooltip, TSM.Options.LoadTooltipOptions)

	TSM:LoadOperations(operationDefaults, 1, TSM.GetOperationInfo, nil)

	TSM:RegisterPriceSource("Crafting", L["Crafting Cost"], TSM.GetCraftingCost)
	TSM:RegisterPriceSource("matPrice", L["Crafting Material Cost"], TSM.GetCraftingMatCost)

	TSM:RegisterSlashCommand("restock_help", TSM.RestockHelp, L["Tells you why a specific item is not being restocked and added to the queue."])

	-- FIXME: keep crafting working in the old UIs for now
	TSM.moduleOptions = { callback = TSM.Options.Load }

	TSMAPI_FOUR.Modules.Register(TSM)

	-- register 1:1 crafting conversions
	for spell, data in pairs(TSMCore.db.factionrealm.internalData.crafts) do
		local sourceItem, rate = nil, nil
		local numMats = 0
		for itemString, num in pairs(data.mats) do
			numMats = numMats + 1
			if numMats > 1 then break end -- skip crafts which involve more than one mat
			if not TSMAPI.Item:ToItemString(itemString) then
				-- this is not a valid itemString so remove it and bail out for this craft
				data.mats[itemString] = nil
				sourceItem = nil
				numMats = 2
				TSM:LOG_INFO("Found bad material itemString: %s", itemString)
				break
			end
			sourceItem = itemString
			rate = data.numResult / num
		end
		if numMats == 1 and not data.hasCD and not TSM.MASS_MILLING_RECIPES[spell] then
			TSMAPI.Conversions:Add(data.itemString, sourceItem, rate, "craft")
		end
	end
end

function TSM:OnEnable()
	local isValid, err = TSMAPI:ValidateCustomPrice(TSMCore.db.global.craftingOptions.defaultCraftPriceMethod, "crafting")
	if not isValid then
		TSM:Printf(L["Your default craft value method was invalid so it has been returned to the default. Details: %s"], err)
		TSMCore.db.global.craftingOptions.defaultCraftPriceMethod = TSMCore.db:GetDefault("global", "craftingOptions", "defaultCraftPriceMethod")
	end
	for name, operation in pairs(TSM.operations) do
		if operation.craftPriceMethod then
			local isValid, err = TSMAPI:ValidateCustomPrice(operation.craftPriceMethod, "crafting")
			if not isValid then
				TSM:Printf(L["Your craft value method for '%s' was invalid so it has been returned to the default. Details: %s"], name, err)
				operation.craftPriceMethod = operationDefaults.craftPriceMethod
			end
		end
	end
end

function TSM.GetOperationInfo(name)
	TSMAPI.Operations:Update("Crafting", name)
	local operation = TSM.operations[name]
	if not operation then return end
	if operation.minProfit then
		return format(L["Restocking to a max of %d (min of %d) with a min profit."], operation.maxRestock, operation.minRestock)
	else
		return format(L["Restocking to a max of %d (min of %d) with no min profit."], operation.maxRestock, operation.minRestock)
	end
end

function TSM.LoadTooltip(itemString, quantity, options, moneyCoins, lines)
	TSM:UpdateCraftReverseLookup()
	itemString = TSMAPI.Item:ToBaseItemString(itemString)
	local numStartingLines = #lines

	if TSM.craftReverseLookup[itemString] and options.craftingCost then
		local spellID, cost, buyout, profit = TSM.Cost:GetItemCraftPrices(itemString)
		if cost then
			local costText = (TSMAPI:MoneyToString(cost, "|cffffffff", "OPT_PAD", moneyCoins and "OPT_ICON" or nil) or "|cffffffff---|r")
			local profitColor = (profit or 0) < 0 and "|cffff0000" or "|cff00ff00"
			local profitText = (TSMAPI:MoneyToString(profit, profitColor, "OPT_PAD", moneyCoins and "OPT_ICON" or nil) or "|cffffffff---|r")
			tinsert(lines, { left = "  " .. L["Crafting Cost"], right = format(L["%s (%s profit)"], costText, profitText) })

			local craftInfo = TSMCore.db.factionrealm.internalData.crafts[spellID]
			if options.detailedMats and craftInfo then
				for matItemString, matQuantity in pairs(craftInfo.mats) do
					local name = TSMAPI.Item:GetName(matItemString)
					local mat = TSMCore.db.factionrealm.internalData.mats[matItemString]
					if name and mat then
						local cost = TSMAPI:GetCustomPriceValue(mat.customValue or TSMCore.db.global.craftingOptions.defaultMatCostMethod, matItemString)
						if cost then
							local quality = TSMAPI.Item:GetQuality(matItemString)
							local colorName = format("|c%s%s%s%s|r", select(4, GetItemQualityColor(quality)), name, " x ", TSMAPI.Util:Round(matQuantity / craftInfo.numResult, 0.01))
							tinsert(lines, { left = "    " .. colorName, right = TSMAPI:MoneyToString((cost * matQuantity) / craftInfo.numResult, "|cffffffff", "OPT_PAD", moneyCoins and "OPT_ICON" or nil) })
						end
					end
				end
			end
		end
	end

	-- add mat price
	if options.matPrice then
		local matInfo = TSMCore.db.factionrealm.internalData.mats[itemString]
		local cost = matInfo and TSMAPI:GetCustomPriceValue(matInfo.customValue or TSMCore.db.global.craftingOptions.defaultMatCostMethod, itemString) or nil
		if cost then
			tinsert(lines, { left = "  " .. L["Mat Cost"], right = TSMAPI:MoneyToString(cost, "|cffffffff", "OPT_PAD", moneyCoins and "OPT_ICON" or nil) })
		end
	end

	if #lines > numStartingLines then
		tinsert(lines, numStartingLines + 1, "|cffffff00TSM Crafting:|r")
	end
end

function TSM.GetCraftingCost(itemString)
	itemString = TSMAPI.Item:ToBaseItemString(TSMAPI.Item:ToItemString(itemString))
	if not itemString then return end

	TSM:UpdateCraftReverseLookup()
	local _, cost = TSM.Cost:GetItemCraftPrices(itemString)
	return cost
end

function TSM.GetCraftingMatCost(itemString)
	itemString = TSMAPI.Item:ToBaseItemString(TSMAPI.Item:ToItemString(itemString))
	if not itemString then return end

	TSM:UpdateCraftReverseLookup()
	return TSM.Cost:GetMatCost(itemString)
end

local reverseLookupUpdate = 0
function TSM:UpdateCraftReverseLookup()
	if reverseLookupUpdate >= time() - 30 then return end
	reverseLookupUpdate = time()
	TSM.craftReverseLookup = {}

	for spellID, data in pairs(TSMCore.db.factionrealm.internalData.crafts) do
		TSM.craftReverseLookup[data.itemString] = TSM.craftReverseLookup[data.itemString] or {}
		tinsert(TSM.craftReverseLookup[data.itemString], spellID)
	end
end

function TSM.RestockHelp(link)
	local itemString = TSMAPI.Item:ToItemString(link)
	if not itemString then
		return print(L["No item specified. Usage: /tsm restock_help [ITEM_LINK]"])
	end

	TSM:Printf(L["Restock help for %s:"], link)

	-- check if the item is in a group
	local groupPath = TSMAPI.Groups:GetPath(itemString)
	if not groupPath then
		return print(L["This item is not in a TSM group."])
	end

	-- check that there's a crafting operation applied
	local opName = TSMAPI.Operations:GetFirstByItem(itemString, "Crafting")
	local opSettings = opName and TSM.operations[opName]
	if not opSettings then
		return print(format(L["There is no TSM_Crafting operation applied to this item's TSM group (%s)."], TSMAPI.Groups:FormatPath(groupPath)))
	end

	-- check if it's an invalid operation
	if opSettings.minRestock > opSettings.maxRestock then
		return print(format(L["The operation applied to this item is invalid! Min restock of %d is higher than max restock of %d."], opSettings.minRestock, opSettings.maxRestock))
	end

	-- check that this item is craftable
	TSM:UpdateCraftReverseLookup()
	local spellID = TSM.craftReverseLookup[itemString] and TSM.craftReverseLookup[itemString][1]
	if not spellID or not TSMCore.db.factionrealm.internalData.crafts[spellID] then
		return print(L["You don't know how to craft this item."])
	end

	-- check the restock quantity
	local numHave = TSMAPI.Inventory:GetTotalQuantity(itemString)
	if numHave >= opSettings.maxRestock then
		return print(format(L["You already have at least your max restock quantity of this item. You have %d and the max restock quantity is %d"], numHave, opSettings.maxRestock))
	elseif (opSettings.maxRestock - numHave) < opSettings.minRestock then
		return print(format(L["The number which would be queued (%d) is less than the min restock quantity (%d)."], (opSettings.maxRestock - numHave), opSettings.minRestock))
	end

	-- check the prices on the item and the min profit
	if opSettings.minProfit then
		local cheapestSpellID, cost, craftedValue, profit = TSM.Cost:GetItemCraftPrices(itemString)

		-- check that there's a crafted value
		if not craftedValue then
			local craftPriceMethod = opSettings and opSettings.craftPriceMethod or TSMCore.db.global.craftingOptions.defaultCraftPriceMethod
			return print(format(L["The 'Craft Value Method' (%s) did not return a value for this item. If it is based on some price database (AuctionDB, TSM_WoWuction, TUJ, etc), then ensure that you have scanned for or downloaded the data as appropriate."], craftPriceMethod))
		end

		-- check that there's a crafted cost
		if not cost then
			return print(L["This item does not have a crafting cost. Check that all of its mats have mat prices. If the mat prices are based on some price database (AuctionDB, TSM_WoWuction, TUJ, etc), then ensure that you have scanned for or downloaded the data as appropriate."])
		end

		-- check that there's a profit
		if not profit then
			return print(L["There is a crafting cost and crafted item value, but TSM_Crafting wasn't able to calculate a profit. This shouldn't happen!"])
		end

		local minProfit = TSMAPI:GetCustomPriceValue(opSettings.minProfit, itemString)
		if not minProfit then
			return print(format(L["The min profit (%s) did not evalulate to a valid value for this item."], opSettings.minProfit))
		end

		if profit < minProfit then
			return print(format(L["The profit of this item (%s) is below the min profit (%s)."], TSMAPI:MoneyToString(profit), TSMAPI:MoneyToString(minProfit)))
		end
	end

	print(L["This item will be added to the queue when you restock its group. If this isn't happening, make a post on the TSM forums with a screenshot of the item's tooltip, operation settings, and your general TSM_Crafting options."])
end

function TSM:GetSpellId(link)
	TSMAPI:Assert(type(link) == "string")
	return tonumber(strmatch(link, ":(%d+)\124h"))
end

function TSM:GetCurrentProfessionName()
	local _, name = C_TradeSkillUI.GetTradeSkillLine()
	if name and C_TradeSkillUI.IsNPCCrafting() then
		return name .. " (" .. GARRISON_LOCATION_TOOLTIP..")"
	end
	return name or "UNKNOWN"
end

function TSM:IsCurrentProfessionEnchanting()
	return select(2, C_TradeSkillUI.GetTradeSkillLine()) == GetSpellInfo(7411)
end

function TSM:GetInventoryTotals()
	local ignoreCharacters = CopyTable(TSMCore.db.global.craftingOptions.ignoreCharacters)
	ignoreCharacters[UnitName("player")] = nil
	return TSMAPI.Inventory:GetCraftingTotals(ignoreCharacters, { [TSM.VELLUM_ITEM_STRING] = true })
end
