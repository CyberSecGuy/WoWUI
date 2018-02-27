-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Shopping                           --
--            http://www.curse.com/addons/wow/tradeskillmaster_shopping           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSMCore = select(2, ...)
local TSM = TSMCore.old.Shopping
local Options = TSM:NewPackage("Options")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = {}



-- ============================================================================
-- Module Options
-- ============================================================================

function Options.Load(container)
	local page = {
		{
			type = "ScrollFrame",
			layout = "list",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["General Options"],
					children = {
						{
							type = "EditBox",
							label = L["% Column Source"],
							settingInfo = { TSMCore.db.global.shoppingOptions, "pctSource" },
							relativeWidth = 0.5,
							acceptCustom = true,
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Disenchant Search Options"],
					children = {
						{
							type = "Slider",
							label = L["Min Disenchant Level"],
							settingInfo = { TSMCore.db.global.shoppingOptions, "minDeSearchLvl" },
							min = 1,
							max = 905,
							step = 1,
							isPercent = false,
							callback = function(self, _, value)
								if value > TSMCore.db.global.shoppingOptions.maxDeSearchLvl then
									TSM:Print(TSMAPI.Design:GetInlineColor("link2") .. L["Warning: The min disenchant level must be lower than the max disenchant level."] .. "|r")
								end
								TSMCore.db.global.shoppingOptions.minDeSearchLvl = min(value, TSMCore.db.global.shoppingOptions.maxDeSearchLvl)
							end,
							tooltip = L["This is the minimum item level that the Other > Disenchant search will display results for."],
						},
						{
							type = "Slider",
							label = L["Max Disenchant Level"],
							settingInfo = { TSMCore.db.global.shoppingOptions, "maxDeSearchLvl" },
							min = 1,
							max = 905,
							step = 1,
							isPercent = false,
							callback = function(self, _, value)
								if value < TSMCore.db.global.shoppingOptions.minDeSearchLvl then
									TSM:Print(TSMAPI.Design:GetInlineColor("link2") .. L["Warning: The max disenchant level must be higher than the min disenchant level."] .. "|r")
								end
								TSMCore.db.global.shoppingOptions.maxDeSearchLvl = max(value, TSMCore.db.global.shoppingOptions.minDeSearchLvl)
							end,
							tooltip = L["This is the maximum item level that the Other > Disenchant search will display results for."],
						},
						{
							type = "Slider",
							label = L["Max Disenchant Search Percent"],
							settingInfo = { TSMCore.db.global.shoppingOptions, "maxDeSearchPercent" },
							min = .1,
							max = 1,
							step = .01,
							isPercent = true,
							tooltip = L["This is the maximum percentage of disenchant value that the Other > Disenchant search will display results for."],
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Sniper Options"],
					children = {
						{
							type = "Dropdown",
							label = L["Found Auction Sound"],
							list = TSMAPI:GetSounds(),
							settingInfo = { TSMCore.db.global.sniperOptions, "sniperSound" },
							tooltip = L["Play the selected sound when a new auction is found to snipe."],
						},
						{
							type = "Button",
							text = L["Test Selected Sound"],
							callback = function() TSMAPI:DoPlaySound(TSMCore.db.global.sniperOptions.sniperSound) end,
						},
					},
				},
			},
		},
	}

	TSMAPI.GUI:BuildOptions(container, page)
end



-- ============================================================================
-- Operation Options
-- ============================================================================

function Options.GetOperationOptionsInfo()
	local description = L["Shopping operations contain settings items which you regularly buy from the auction house."]
	local tabInfo = {
		{ text = L["General"], callback = private.DrawOperationGeneral},
	}
	local relationshipInfo = {
		{
			label = L["General Settings"],
			{ key = "maxPrice", label = L["Maximum Auction Price (per item)"] },
			{ key = "showAboveMaxPrice", label = L["Show Auctions Above Max Price"] },
			{ key = "evenStacks", label = L["Even (5/10/15/20) Stacks Only"] },
			{ key = "includeInSniper", label = L["Include in Sniper Searches"] },
			{ key = "restockQuantity", label = L["Max Restock Quantity"] },
			{ key = "restockSources", label = L["Sources to Include in Restock"] },
		},
	}
	return description, tabInfo, relationshipInfo
end

function private.DrawOperationGeneral(container, operationName)
	local operation = TSM.operations[operationName]
	local page = {
		{
			type = "ScrollFrame",
			layout = "list",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["General Operation Options"],
					children = {
						{
							type = "EditBox",
							label = L["Maximum Auction Price (per item)"],
							settingInfo = { operation, "maxPrice" },
							relativeWidth = 0.5,
							acceptCustom = true,
							disabled = operation.relationships.maxPrice,
							tooltip = L["The highest price per item you will pay for items in affected by this operation."],
						},
						{
							type = "CheckBox",
							label = L["Show Auctions Above Max Price"],
							settingInfo = { operation, "showAboveMaxPrice" },
							relativeWidth = 0.49,
							disabled = operation.relationships.showAboveMaxPrice,
							tooltip = L["If checked, auctions above the max price will be shown."],
						},
						{
							type = "CheckBox",
							label = L["Even (5/10/15/20) Stacks Only"],
							settingInfo = { operation, "evenStacks" },
							relativeWidth = 0.5,
							disabled = operation.relationships.evenStacks,
							tooltip = L["If checked, only auctions posted in even quantities will be considered for purchasing."],
						},
						{
							type = "CheckBox",
							label = L["Include in Sniper Searches"],
							settingInfo = { operation, "includeInSniper" },
							relativeWidth = 0.49,
							disabled = operation.relationships.includeInSniper,
							tooltip = L["If checked, auctions below the max price will be shown while sniping."],
						},
						{
							type = "HeadingLine",
						},
						{
							type = "Slider",
							label = L["Max Restock Quantity"],
							settingInfo = { operation, "restockQuantity" },
							disabled = operation.relationships.restockQuantity,
							min = 0,
							max = 10000,
							step = 1,
							relativeWidth = 0.5,
							tooltip = L["Shopping will only search for enough items to restock your bags to the specific quantity. Set this to 0 to disable this feature."],
						},
						{
							type = "Dropdown",
							label = L["Sources to Include in Restock"],
							disabled = operation.relationships.restockSources,
							relativeWidth = 0.5,
							list = {bank=BANK, guild=GUILD, alts=L["Alts"], auctions = L["Auctions"]},
							value = operation.restockSources,
							multiselect = true,
							callback = function(_, _, key, value)
								operation.restockSources[key] = value
							end,
						},
					},
				},
			},
		},
	}

	TSMAPI.GUI:BuildOptions(container, page)
end



-- ============================================================================
-- Tooltip Options
-- ============================================================================

function Options.LoadTooltipOptions(container, options)
	local page = {
		{
			type = "SimpleGroup",
			layout = "Flow",
			fullHeight = true,
			children = {
				{
					type = "CheckBox",
					label = L["Show Shopping Max Price in Tooltip"],
					settingInfo = { options, "maxPrice" },
					tooltip = L["If checked, the maximum shopping price will be shown in the tooltip for the item."],
				},
			},
		},
	}

	TSMAPI.GUI:BuildOptions(container, page)
end
