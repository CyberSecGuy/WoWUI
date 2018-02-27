-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local Cost = TSM.Crafting:NewPackage("Cost")
local private = { matsVisited = {} }



-- ============================================================================
-- Module Functions
-- ============================================================================

function Cost.GetMatCost(itemString)
	if not TSM.db.factionrealm.internalData.mats[itemString] then
		return
	end
	if private.matsVisited[itemString] then
		-- there's a loop in the mat cost, so bail
		return
	end
	private.matsVisited[itemString] = true
	local priceStr = TSM.db.factionrealm.internalData.mats[itemString].customValue or TSM.db.global.craftingOptions.defaultMatCostMethod
	local cost = TSMAPI_FOUR.CustomPrice.GetValue(priceStr, itemString)
	private.matsVisited[itemString] = nil
	return cost
end

function Cost.GetCraftingCostBySpellId(spellId)
	local cost = 0
	local hasMats = false
	for _, itemString, quantity in TSM.Crafting.MatIterator(spellId) do
		hasMats = true
		local matCost = Cost.GetMatCost(itemString)
		if not matCost then
			cost = nil
		elseif cost then
			cost = cost + matCost * quantity
		end
	end
	if not cost or not hasMats then
		return
	end
	cost = TSMAPI_FOUR.Util.Round(cost / TSM.Crafting.GetNumResult(spellId))
	return cost > 0 and cost or nil
end

function Cost.GetCraftedItemValue(itemString)
	-- TODO: replace with new operation APIs
	local operation = TSMAPI.Operations:GetFirstByItem(itemString, "Crafting")
	local operationSettings = operation and TSM.operations.Crafting[operation]
	local priceStr = TSM.db.global.craftingOptions.defaultCraftPriceMethod
	if operationSettings then
		TSMAPI.Operations:Update("Crafting", operation)
		priceStr = operationSettings.craftPriceMethod or priceStr
	end
	return TSMAPI_FOUR.CustomPrice.GetValue(priceStr, itemString)
end

function Cost.GetProfitBySpellId(spellId)
	local _, _, profit = Cost.GetCostsBySpellId(spellId)
	return profit
end

function Cost.GetCostsBySpellId(spellId)
	local craftingCost = Cost.GetCraftingCostBySpellId(spellId)
	local itemString = TSM.Crafting.GetItemString(spellId)
	local craftedItemValue = itemString and Cost.GetCraftedItemValue(itemString) or nil
	return craftingCost, craftedItemValue, craftingCost and craftedItemValue and (craftedItemValue - craftingCost) or nil
end

function Cost.GetSaleRateBySpellId(spellId)
	local itemString = TSM.Crafting.GetItemString(spellId)
	return itemString and TSMAPI_FOUR.CustomPrice.GetItemPrice(itemString, "DBRegionSaleRate") or nil
end
