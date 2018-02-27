-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Vendoring                           --
--           http://www.curse.com/addons/wow/tradeskillmaster_vendoring           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSMCore = select(2, ...)
TSMCore.old.Vendoring = TSMCore.old.Vendoring or {}
local TSM = TSMAPI_FOUR.Addon.New("TradeSkillMaster_Vendoring", TSMCore.old.Vendoring)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = {}

local operationDefaults = {
	qsPreference = 1,
	sellAfterExpired = 20,
	sellSoulbound = false,
	keepQty = 0,
	restockQty = 0,
	restockSources = {},
	enableBuy = true,
	enableSell = true,
	vsMarketValue = "dbmarket",
	vsMaxMarketValue = "0c",
	vsDestroyValue = "Destroy",
	vsMaxDestroyValue = "0c",
}

function TSM:OnInitialize()
	TSM:LoadOperations(operationDefaults, 1, TSM.GetOperationInfo, TSM.Options.GetOperationOptionsInfo)

	-- FIXME: keep vendoring working in the old UIs for now
	TSM.moduleOptions = { callback = TSM.Options.Load }

	TSMAPI_FOUR.Modules.Register(TSM)
end

function TSM.GetOperationInfo(operationName)
	local operation = TSM.operations[operationName]
	if not operation then return end
	if operation.target == "" then return end

	local parts = {}
	if operation.enableBuy and operation.restockQty > 0 then
		tinsert(parts, format(L["Restocking to %d."], operation.restockQty))
	end

	if operation.enableSell then
		if operation.keepQty > 0 then
			tinsert(parts, format(L["Keeping %d."], operation.keepQty))
		end
		local sellString = ""
		local sellSeparator = ""
		if operation.sellAfterExpired > 0 then
			sellString = format(L["Selling after %d expired auctions"], operation.sellAfterExpired)
			sellSeparator = L[" and "]
		else
			sellString = L["Selling if "]
			sellSeparator = ""
		end
		if operation.vsMaxMarketValue ~= '0c' and operation.vsMaxDestroyValue ~= '0c' then
			sellString = format(L["%s%smarket value is below %s, destroy value is below %s"], sellString, sellSeparator, operation.vsMaxMarketValue, operation.vsMaxDestroyValue)
		elseif operation.vsMaxMarketValue ~= '0c' and operation.vsMaxDestroyValue == '0c' then
			sellString = format(L["%s%smarket value is below %s"], sellString, sellSeparator, operation.vsMaxMarketValue)
		elseif operation.vsMaxMarketValue == '0c' and operation.vsMaxDestroyValue ~= '0c' then
			sellString = format(L["%s%sdestroy value is below %s"], sellString, sellSeparator, operation.vsMaxDestroyValue)
		elseif operation.sellAfterExpired == 0 then
			sellString = L["Selling always"]
		end

		tinsert(parts, format("%s.", sellString))

		if operation.sellSoulbound then
			tinsert(parts, L["Selling soulbound items."])
		end
	end

	return table.concat(parts, " ")
end
