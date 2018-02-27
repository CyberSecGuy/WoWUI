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
local Options = TSM:NewPackage("Options")
local AceGUI = LibStub("AceGUI-3.0") -- load the AceGUI libraries
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = {}



-- ============================================================================
-- Module Options
-- ============================================================================

function Options.Load(container)
	local tg = AceGUI:Create("TSMTabGroup")
	tg:SetLayout("Fill")
	tg:SetFullHeight(true)
	tg:SetFullWidth(true)
	tg:SetTabs({{value=1, text=L["General"]}})
	tg:SetCallback("OnGroupSelected", function(self, _, value)
		self:ReleaseChildren()
		if value == 1 then
			private:DrawGeneralSettings(self)
		end
	end)
	container:AddChild(tg)
	tg:SelectTab(1)
end

function private:DrawGeneralSettings(container)
	-- inventory tracking characters / guilds
	local altCharacters, altGuilds = {}, {}
	for name in pairs(TSMAPI.Player:GetCharacters()) do
		altCharacters[name] = name
	end
	for name in pairs(TSMAPI.Player:GetGuilds()) do
		altGuilds[name] = name
	end

	local page = {
		{
			-- scroll frame to contain everything
			type = "ScrollFrame",
			layout = "List",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Inventory Settings"],
					children = {
						{
							type = "Dropdown",
							label = L["Characters (Bags/Bank/AH/Mail) to Ignore:"],
							value = TSMCore.db.global.craftingOptions.ignoreCharacters,
							list = altCharacters,
							relativeWidth = 0.49,
							multiselect = true,
							callback = function(self, _, key, value)
								TSMCore.db.global.craftingOptions.ignoreCharacters[key] = value
							end,
						},
						{
							type = "Dropdown",
							label = L["Guilds (Guild Banks) to Ignore:"],
							value = TSMCore.db.global.craftingOptions.ignoreGuilds,
							list = altGuilds,
							relativeWidth = 0.49,
							multiselect = true,
							callback = function(_, _, key, value)
								TSMCore.db.global.craftingOptions.ignoreGuilds[key] = value
							end,
						},
					},
				},
				{
					type = "Spacer"
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Default Price Settings"],
					children = {
						{
							type = "EditBox",
							label = L["Default Material Cost Method"],
							settingInfo = {TSMCore.db.global.craftingOptions, "defaultMatCostMethod"},
							relativeWidth = 1,
							acceptCustom = "matprice",
							tooltip = L["This is the default method Crafting will use for determining material cost."],
						},
						{
							type = "HeadingLine",
						},
						{
							type = "EditBox",
							label = L["Default Craft Value Method"],
							settingInfo = {TSMCore.db.global.craftingOptions, "defaultCraftPriceMethod"},
							relativeWidth = 1,
							acceptCustom = "crafting",
							tooltip = L["This is the default method Crafting will use for determining the value of crafted items."],
						},
						{
							type = "HeadingLine",
						},
						{
							type = "CheckBox",
							label = L["Exclude Crafts with a Cooldown from Craft Cost"],
							settingInfo = { TSMCore.db.global.craftingOptions, "ignoreCDCraftCost" },
							relativeWidth = 1,
							tooltip = L["If checked, if there is more than one way to craft the item then the craft cost will exclude any craft with a daily cooldown when calculating the lowest craft cost."],
						},
					},
				},
			},
		},
	}

	TSMAPI.GUI:BuildOptions(container, page)
end

function Options.LoadTooltipOptions(container, options)
	local page = {
		{
			type = "SimpleGroup",
			layout = "Flow",
			fullHeight = true,
			children = {
				{
					type = "CheckBox",
					label = L["Show Crafting Cost in Tooltip"],
					settingInfo = { options, "craftingCost" },
					tooltip = L["If checked, the crafting cost of items will be shown in the tooltip for the item."],
				},
				{
					type = "CheckBox",
					label = L["Show Material Cost in Tooltip"],
					settingInfo = { options, "matPrice" },
					tooltip = L["If checked, the material cost of items will be shown in the tooltip for the item."],
				},
				{
					type = "CheckBox",
					label = L["List Mats in Tooltip"],
					settingInfo = { options, "detailedMats" },
					tooltip = L["If checked, the mats needed to craft an item and their prices will be shown in item tooltips."],
				},
			},
		},
	}

	TSMAPI.GUI:BuildOptions(container, page)
end
