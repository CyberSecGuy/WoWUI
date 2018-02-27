-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Shopping                           --
--            http://www.curse.com/addons/wow/tradeskillmaster_shopping           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSMCore = select(2, ...)
TSMCore.old.Shopping = TSMCore.old.Shopping or {}
local TSM = TSMAPI_FOUR.Addon.New("TradeSkillMaster_Shopping", TSMCore.old.Shopping)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table

local tooltipDefaults = {
	maxPrice = false,
}
local operationDefaults = {
	restockQuantity = 0,
	maxPrice = 1,
	evenStacks = nil,
	showAboveMaxPrice = nil,
	includeInSniper = nil,
	restockSources = {},
}

function TSM:OnInitialize()
	TSM:LoadOperations(operationDefaults, 1, TSM.GetOperationInfo, TSM.Options.GetOperationOptionsInfo)

	TSM:RegisterTooltipInfo(tooltipDefaults, TSM.LoadTooltip, TSM.Options.LoadTooltipOptions)

	-- FIXME: keep shopping working in the old UIs for now
	TSM.moduleOptions = { callback = TSM.Options.Load }

	TSMAPI_FOUR.Modules.Register(TSM)
end

function TSM.GetOperationInfo(operationName)
	TSMAPI.Operations:Update("Shopping", operationName)
	local operation = TSM.operations[operationName]
	if not operation then return end

	if operation.showAboveMaxPrice and operation.evenStacks then
		return format(L["Shopping for even stacks including those above the max price"])
	elseif operation.showAboveMaxPrice then
		return format(L["Shopping for auctions including those above the max price."])
	elseif operation.evenStacks then
		return format(L["Shopping for even stacks with a max price set."])
	else
		return format(L["Shopping for auctions with a max price set."])
	end
end

function TSM.LoadTooltip(itemString, quantity, options, moneyCoins, lines)
	if not options.maxPrice then return end -- only 1 tooltip option
	itemString = TSMAPI.Item:ToBaseItemString(itemString, true)
	local numStartingLines = #lines

	local operationName = TSMAPI.Operations:GetFirstByItem(itemString, "Shopping")
	if not operationName or not TSM.operations[operationName] then return end
	TSMAPI.Operations:Update("Shopping", operationName)

	local maxPrice = TSMAPI:GetCustomPriceValue(TSM.operations[operationName].maxPrice, itemString)
	if maxPrice then
		local priceText = (TSMAPI:MoneyToString(maxPrice, "|cffffffff", "OPT_PAD", moneyCoins and "OPT_ICON" or nil) or "|cffffffff---|r")
		tinsert(lines, { left = "  " .. L["Max Shopping Price:"], right = format("%s", priceText) })
	end

	if #lines > numStartingLines then
		tinsert(lines, numStartingLines + 1, "|cffffff00TSM Shopping:|r")
	end
end
