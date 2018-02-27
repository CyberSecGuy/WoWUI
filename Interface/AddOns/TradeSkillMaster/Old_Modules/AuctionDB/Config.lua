-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_AuctionDB                           --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctiondb           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable and register this file as a module
local TSMCore = select(2, ...)
local TSM = TSMCore.old.AuctionDB
local Config = TSM:NewPackage("Config")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table



-- ============================================================================
-- Tooltip Options
-- ============================================================================

function Config.LoadTooltipOptions(container, options)
	local page = {
		{
			type = "SimpleGroup",
			layout = "Flow",
			fullHeight = true,
			children = {
				{
					type = "CheckBox",
					label = L["Display min buyout in tooltip."],
					settingInfo = { options, "minBuyout" },
					relativeWidth = 1,
					tooltip = L["If checked, the lowest buyout value seen in the last scan of the item will be displayed."],
				},
				{
					type = "CheckBox",
					label = L["Display market value in tooltip."],
					settingInfo = { options, "marketValue" },
					relativeWidth = 1,
					tooltip = L["If checked, the market value of the item will be displayed"],
				},
				{
					type = "HeadingLine",
				},
				{
					type = "CheckBox",
					label = L["Display historical price (via TSM Application) in the tooltip."],
					settingInfo = { options, "historical" },
					relativeWidth = 1,
					tooltip = L["If checked, the historical price of the item will be displayed. This is provided exclusively via the TradeSkillMaster Application."],
				},
				{
					type = "CheckBox",
					label = L["Display region min buyout avg (via TSM Application) in the tooltip."],
					settingInfo = { options, "regionMinBuyout" },
					relativeWidth = 1,
					tooltip = L["If checked, the region minimum buyout average of the item will be displayed. This is provided exclusively via the TradeSkillMaster Application."],
				},
				{
					type = "CheckBox",
					label = L["Display region market value avg (via TSM Application) in the tooltip."],
					settingInfo = { options, "regionMarketValue" },
					relativeWidth = 1,
					tooltip = L["If checked, the region market value average of the item will be displayed. This is provided exclusively via the TradeSkillMaster Application."],
				},
				{
					type = "CheckBox",
					label = L["Display region historical price (via TSM Application) in the tooltip."],
					settingInfo = { options, "regionHistorical" },
					relativeWidth = 1,
					tooltip = L["If checked, the region historical price of the item will be displayed. This is provided exclusively via the TradeSkillMaster Application."],
				},
				{
					type = "CheckBox",
					label = L["Display region sale avg (via TSM Application) in the tooltip."],
					settingInfo = { options, "regionSale" },
					relativeWidth = 1,
					tooltip = L["If checked, the region sale average of the item will be displayed. This is provided exclusively via the TradeSkillMaster Application."],
				},
				{
					type = "CheckBox",
					label = L["Display region sale rate (via TSM Application) in the tooltip."],
					settingInfo = { options, "regionSalePercent" },
					relativeWidth = 1,
					tooltip = L["If checked, the region sale rate of the item will be displayed. This is provided exclusively via the TradeSkillMaster Application."],
				},
				{
					type = "CheckBox",
					label = L["Display region average daily sold quantity (via TSM Application) in the tooltip."],
					settingInfo = { options, "regionSoldPerDay" },
					relativeWidth = 1,
					tooltip = L["If checked, the region average daily sold quantity of the item will be displayed. This is provided exclusively via the TradeSkillMaster Application."],
				},
				{
					type = "CheckBox",
					label = L["Display global min buyout avg (via TSM Application) in the tooltip."],
					settingInfo = { options, "globalMinBuyout" },
					relativeWidth = 1,
					tooltip = L["If checked, the global minimum buyout average of the item will be displayed. This is provided exclusively via the TradeSkillMaster Application."],
				},
				{
					type = "CheckBox",
					label = L["Display global market value avg (via TSM Application) in the tooltip."],
					settingInfo = { options, "globalMarketValue" },
					relativeWidth = 1,
					tooltip = L["If checked, the global market value average of the item will be displayed. This is provided exclusively via the TradeSkillMaster Application."],
				},
				{
					type = "CheckBox",
					label = L["Display global historical price (via TSM Application) in the tooltip."],
					settingInfo = { options, "globalHistorical" },
					relativeWidth = 1,
					tooltip = L["If checked, the global historical price of the item will be displayed. This is provided exclusively via the TradeSkillMaster Application."],
				},
				{
					type = "CheckBox",
					label = L["Display global sale avg (via TSM Application) in the tooltip."],
					settingInfo = { options, "globalSale" },
					relativeWidth = 1,
					tooltip = L["If checked, the global sale average of the item will be displayed. This is provided exclusively via the TradeSkillMaster Application."],
				},
			},
		},
	}

	TSMAPI.GUI:BuildOptions(container, page)
end
