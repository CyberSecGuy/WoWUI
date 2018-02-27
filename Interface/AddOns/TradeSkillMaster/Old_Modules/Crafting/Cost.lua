-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Crafting                           --
--            http://www.curse.com/addons/wow/tradeskillmaster_crafting           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable and register this file as a module
local TSMCore = select(2, ...)
local TSM = TSMCore.old.Crafting
local Cost = TSM:NewPackage("Cost")
local private = { matsVisited = {} }



-- ============================================================================
-- Module Functions
-- ============================================================================

-- gets the cost of a material
function Cost:GetMatCost(itemString)
	if not TSMCore.db.factionrealm.internalData.mats[itemString] then return end
	if private.matsVisited[itemString] then return end

	private.matsVisited[itemString] = true
	local cost = TSMAPI:GetCustomPriceValue(TSMCore.db.factionrealm.internalData.mats[itemString].customValue or TSMCore.db.global.craftingOptions.defaultMatCostMethod, itemString)
	private.matsVisited[itemString] = nil

	return cost
end

-- calculates the cost, buyout, and profit for a crafted item
function Cost:GetSpellCraftPrices(spellId)
	if not spellId or not TSMCore.db.factionrealm.internalData.crafts[spellId] then return end

	local cost = private:GetSpellCraftingCost(spellId)
	local buyout = private:GetCraftValue(TSMCore.db.factionrealm.internalData.crafts[spellId].itemString)
	local profit = nil
	if cost and buyout then
		profit = TSMAPI.Util:Round(buyout - cost)
	end
	return cost, buyout, profit
end

-- gets the spellId, cost, buyout, and profit for the cheapest way to craft the given item
function Cost:GetItemCraftPrices(itemString)
	local spellIds = TSM.craftReverseLookup[itemString]
	if not spellIds then return end

	local lowestCost, cheapestSpellId = nil, nil
	for _, spellId in ipairs(spellIds) do
		local cost = private:GetSpellCraftingCost(spellId)
		if cost and (not lowestCost or cost < lowestCost) then
			-- exclude spells with cooldown if option to ignore is enabled and there is more than one way to craft
			if not TSMCore.db.factionrealm.internalData.crafts[spellId].hasCD or not TSMCore.db.global.craftingOptions.ignoreCDCraftCost or #spellIds == 1 then
				lowestCost = cost
				cheapestSpellId = spellId
			end
		end
	end

	if not lowestCost or not cheapestSpellId then return end
	local buyout = private:GetCraftValue(itemString)
	local profit = nil
	if buyout then
		profit = floor(buyout - lowestCost + 0.5)
	end

	return cheapestSpellId, lowestCost, buyout, profit
end



-- ============================================================================
-- Helper Functions
-- ============================================================================

-- gets the craft cost for a given spell
function private:GetSpellCraftingCost(spellId)
	if not TSMCore.db.factionrealm.internalData.crafts[spellId] then return end
	local cost = 0
	for itemString, quantity in pairs(TSMCore.db.factionrealm.internalData.crafts[spellId].mats) do
		local matCost = Cost:GetMatCost(itemString) or 0
		if matCost == 0 then
			return
		end
		cost = cost + quantity * matCost
	end
	cost = TSMAPI.Util:Round(cost / TSMCore.db.factionrealm.internalData.crafts[spellId].numResult)
	return cost > 0 and cost or nil
end

-- gets the value of a crafted item
function private:GetCraftValue(itemString)
	if not itemString then return end

	local priceMethod = TSMCore.db.global.craftingOptions.defaultCraftPriceMethod
	local operation = TSMAPI.Operations:GetFirstByItem(itemString, "Crafting")
	if operation and TSM.operations[operation] then
		TSMAPI.Operations:Update("Crafting", operation)
		priceMethod = TSM.operations[operation].craftPriceMethod or priceMethod
	end
	return TSMAPI:GetCustomPriceValue(priceMethod, itemString)
end
