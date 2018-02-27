-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Auctioning                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctioning          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSMCore = select(2, ...)
local TSM = TSMCore.old.Auctioning
local Util = TSM:NewPackage("Util")
local private = { priceCache = {} }
local INVALID_PRICE = {}
local VALID_PRICE_KEYS = {
	minPrice = true,
	normalPrice = true,
	maxPrice = true,
	undercut = true,
	cancelRepostThreshold = true,
	priceReset = true,
	aboveMax = true,
}



function Util.GetPrice(key, operation, itemString)
	assert(VALID_PRICE_KEYS[key])
	local cacheKey = key..tostring(operation)..itemString
	if private.priceCache.updateTime ~= GetTime() then
		wipe(private.priceCache)
		private.priceCache.updateTime = GetTime()
	end
	if not private.priceCache[cacheKey] then
		if key == "normalPrice" then
			local normalPrice = TSMAPI_FOUR.CustomPrice.GetValue(operation.normalPrice, itemString)
			if normalPrice and TSMCore.db.global.auctioningOptions.roundNormalPrice then
				-- round up to the nearest gold
				normalPrice = ceil(normalPrice / COPPER_PER_GOLD) * COPPER_PER_GOLD
			end
			private.priceCache[cacheKey] = normalPrice
		elseif key == "aboveMax" or key == "priceReset" then
			-- redirect to the selected price (if applicable)
			local priceKey = operation[key]
			if VALID_PRICE_KEYS[priceKey] then
				private.priceCache[cacheKey] = Util.GetPrice(priceKey, operation, itemString)
			end
		else
			private.priceCache[cacheKey] = TSMAPI_FOUR.CustomPrice.GetValue(operation[key], itemString)
		end
		private.priceCache[cacheKey] = private.priceCache[cacheKey] or INVALID_PRICE
	end
	if private.priceCache[cacheKey] == INVALID_PRICE then return end
	return private.priceCache[cacheKey]
end
