-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Auctioning                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctioning          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSMCore = select(2, ...)
TSMCore.old.Auctioning = TSMCore.old.Auctioning or {}
local TSM = TSMAPI_FOUR.Addon.New("TradeSkillMaster_Auctioning", TSMCore.old.Auctioning)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
TSM.operationLookup = {}
TSM.operationNameLookup = {}


local tooltipDefaults = {
	operationPrices = false,
}
local operationDefaults = {
	-- general
	matchStackSize = nil,
	blacklist = "",
	ignoreLowDuration = 0,
	-- post
	stackSize = 1,
	stackSizeIsCap = nil,
	postCap = 5,
	keepQuantity = 0,
	keepQtySources = {},
	maxExpires = 0,
	duration = 24,
	bidPercent = 1,
	undercut = 1,
	minPrice = "max(0.25*avg(crafting,dbmarket,dbregionmarketavg),1.5*vendorsell)",
	maxPrice = "max(5*avg(crafting,dbmarket,dbregionmarketavg),30*vendorsell)",
	normalPrice = "max(2*avg(crafting,dbmarket,dbregionmarketavg),12*vendorsell)",
	priceReset = "none",
	aboveMax = "normalPrice",
	-- cancel
	cancelUndercut = true,
	keepPosted = 0,
	cancelRepost = true,
	cancelRepostThreshold = 10000,
}

-- Addon loaded
function TSM:OnInitialize()
	TSM:LoadOperations(operationDefaults, 20, TSM.GetOperationInfo, nil)
	TSM:RegisterTooltipInfo(tooltipDefaults, TSM.LoadTooltip, TSM.Options.LoadTooltipOptions)

	-- FIXME: keep auctioning working in the old UIs for now
	TSM.moduleOptions = { callback = TSM.Options.Load }
	TSM.bankUiButton = { callback = TSM.BankUI.createTab }

	TSMAPI_FOUR.Modules.Register(TSM)
end

function TSM.GetOperationInfo(operationName)
	local operation = TSM.operations[operationName]
	if not operation then return end
	local parts = TSMAPI_FOUR.Util.AcquireTempTable()

	-- get the post string
	if operation.postCap == 0 then
		tinsert(parts, L["No posting."])
	else
		tinsert(parts, format(L["Posting %d stack(s) of %d for %d hours."], operation.postCap, operation.stackSize, operation.duration))
	end

	-- get the cancel string
	if operation.cancelUndercut and operation.cancelRepost then
		tinsert(parts, format(L["Canceling undercut auctions and to repost higher."]))
	elseif operation.cancelUndercut then
		tinsert(parts, format(L["Canceling undercut auctions."]))
	elseif operation.cancelRepost then
		tinsert(parts, format(L["Canceling to repost higher."]))
	else
		tinsert(parts, L["Not canceling."])
	end

	local result = table.concat(parts, " ")
	TSMAPI_FOUR.Util.ReleaseTempTable(parts)
	return result
end

local function TooltipPriceHelper(operation, itemString, priceKey, moneyCoins)
	local price = TSM.Util.GetPrice(priceKey, operation, itemString)
	return TSMAPI_FOUR.Money.ToString(price, "|cffffffff", moneyCoins and "OPT_ICON" or nil) or "|cffffffff---|r"
end
function TSM.LoadTooltip(itemString, quantity, options, moneyCoins, lines)
	if not options.operationPrices then return end -- only 1 tooltip option
	itemString = TSMAPI_FOUR.Item.ToBaseItemString(itemString, true)
	local operation = TSMCore.Operations.GetFirstOptionsByItem("Auctioning", itemString)
	if not operation then return end

	tinsert(lines, "|cffffff00TSM Auctioning:|r")
	local minPrice = TooltipPriceHelper(operation, itemString, "minPrice", moneyCoins)
	local normalPrice = TooltipPriceHelper(operation, itemString, "normalPrice", moneyCoins)
	local maxPrice = TooltipPriceHelper(operation, itemString, "maxPrice", moneyCoins)
	tinsert(lines, { left = "  "..L["Min/Normal/Max Prices:"], right = format("%s / %s / %s", minPrice, normalPrice, maxPrice) })
end
