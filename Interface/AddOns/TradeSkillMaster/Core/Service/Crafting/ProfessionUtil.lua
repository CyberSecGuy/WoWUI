-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local ProfessionUtil = TSM.Crafting:NewPackage("ProfessionUtil")



-- ============================================================================
-- Module Functions
-- ============================================================================

function ProfessionUtil.GetResultInfo(spellId)
	-- get the links
	local itemLink = C_TradeSkillUI.GetRecipeItemLink(spellId)
	assert(itemLink, "Invalid craft: "..tostring(spellId))

	if strfind(itemLink, "enchant:") then
		-- result of craft is not an item
		local itemString = TSM.CONST.ENCHANT_ITEM_STRINGS[spellId] or TSM.CONST.MASS_MILLING_RECIPES[spellId]
		if itemString then
			return TSM.UI.GetColoredItemName(itemString), itemString
		else
			return GetSpellInfo(spellId), nil
		end
	elseif strfind(itemLink, "item:") then
		-- result of craft is an item
		return TSM.UI.GetColoredItemName(itemLink), TSMAPI_FOUR.Item.ToItemString(itemLink)
	else
		error("Invalid craft: "..tostring(spellId))
	end
end

function ProfessionUtil.GetNumCraftable(spellId)
	local num, numAll = math.huge, math.huge
	for i = 1, C_TradeSkillUI.GetRecipeNumReagents(spellId) do
		local itemString = TSMAPI_FOUR.Item.ToItemString(C_TradeSkillUI.GetRecipeReagentItemLink(spellId, i))
		if not itemString then
			return 0, 0
		end
		local _, _, quantity = C_TradeSkillUI.GetRecipeReagentInfo(spellId, i)
		if not quantity then
			return 0, 0
		end
		local bagQuantity = TSMAPI_FOUR.Inventory.GetBagQuantity(itemString) + TSMAPI_FOUR.Inventory.GetReagentBankQuantity(itemString)
		num = min(num, floor(bagQuantity / quantity))
		numAll = min(numAll, floor(TSMAPI_FOUR.Inventory.GetTotalQuantity(itemString) / quantity))
	end
	if num == math.huge or numAll == math.huge then
		return 0, 0
	end
	return num, numAll
end

function ProfessionUtil.GetNumCraftableFromDB(spellId)
	local num = math.huge
	for _, itemString, quantity in TSM.Crafting.MatIterator(spellId) do
		local bagQuantity = TSMAPI_FOUR.Inventory.GetBagQuantity(itemString) + TSMAPI_FOUR.Inventory.GetReagentBankQuantity(itemString)
		num = min(num, floor(bagQuantity / quantity))
	end
	if num == math.huge then
		return 0
	end
	return num
end

function ProfessionUtil.IsEnchant(spellId)
	if select(2, C_TradeSkillUI.GetTradeSkillLine()) ~= GetSpellInfo(7411) then
		return false
	end
	if not strfind(C_TradeSkillUI.GetRecipeItemLink(spellId), "enchant:") then
		return false
	end
	local recipeInfo = C_TradeSkillUI.GetRecipeInfo(spellId, TSMAPI_FOUR.Util.AcquireTempTable())
	local altVerb = recipeInfo.alternateVerb
	TSMAPI_FOUR.Util.ReleaseTempTable(recipeInfo)
	return altVerb and true or false
end
