-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- This file contains all the code for the new tooltip options

local _, TSM = ...
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local FeaturesGUI = TSM:NewModule("FeaturesGUI")
local AceGUI = LibStub("AceGUI-3.0") -- load the AceGUI libraries
local private = {inventoryFilters={characters={}, guilds={}, name="", group=nil}}



-- ============================================================================
-- Module Functions
-- ============================================================================

function FeaturesGUI.LoadGUI(parent)
	local tabGroup = AceGUI:Create("TSMTabGroup")
	tabGroup:SetLayout("Fill")
	tabGroup:SetTabs({{text=L["Macro Setup"], value=1}, {text=L["Custom Price Sources"], value=2}})
	tabGroup:SetCallback("OnGroupSelected", function(_, _, value)
		tabGroup:ReleaseChildren()
		if value == 1 then
			private:LoadMacroCreation(tabGroup)
		elseif value == 2 then
			private:LoadCustomPriceSources(tabGroup)
		end
	end)
	parent:AddChild(tabGroup)
	tabGroup:SelectTab(1)
end



-- ============================================================================
-- Macro Setup Tab
-- ============================================================================

function private:LoadMacroCreation(container)
	-- set default buttons (or use current ones)
	local macroButtonNames = {}
	local macroButtons = {}
	local body = GetMacroBody(GetMacroIndexByName("TSMMacro") or 0)
	macroButtonNames.sniper = "TSMSniperBtn"
	macroButtons.sniper = (not body or strfind(body, macroButtonNames.sniper)) and true or false
	macroButtonNames.cancel = "TSMCancelAuctionBtn"
	macroButtons.cancel = (not body or strfind(body, macroButtonNames.cancel)) and true or false
	macroButtonNames.auctioning = "TSMAuctioningBtn"
	macroButtons.auctioning = (not body or strfind(body, macroButtonNames.auctioning)) and true or false
	macroButtonNames.craftingCraftNext = "TSMCraftingBtn"
	macroButtons.craftingCraftNext = (not body or strfind(body, macroButtonNames.craftingCraftNext)) and true or false
	macroButtonNames.destroyingDestroyNext = "TSMDestroyBtn"
	macroButtons.destroyingDestroyNext = (not body or strfind(body, macroButtonNames.destroyingDestroyNext)) and true or false
	macroButtonNames.shoppingBuyout = "TSMShoppingBuyoutBtn"
	macroButtons.shoppingBuyout = (not body or strfind(body, macroButtonNames.shoppingBuyout)) and true or false
	macroButtonNames.vendoringSellAll = "TSMVendoringSellAllButton"
	macroButtons.vendoringSellAll = (not body or strfind(body, macroButtonNames.vendoringSellAll)) and true or false

	-- set default options (or use current ones)
	local macroOptions = nil
	local currentBindings = {GetBindingKey("MACRO TSMMacro")}
	if #currentBindings > 0 and #currentBindings <= 2 and strfind(currentBindings[1], "MOUSEWHEEL") then
		macroOptions = {}
		if #currentBindings == 2 then
			-- assume it's up/down
			macroOptions.up = true
			macroOptions.down = true
		else
			macroOptions.up = strfind(currentBindings[1], "MOUSEWHEELUP") and true or false
			macroOptions.down = strfind(currentBindings[1], "MOUSEWHEELDOWN") and true or false
		end
		-- use modifiers from the first binding
		macroOptions.ctrl = strfind(currentBindings[1], "CTRL") and true or false
		macroOptions.shift = strfind(currentBindings[1], "SHIFT") and true or false
		macroOptions.alt = strfind(currentBindings[1], "ALT") and true or false
	else
		macroOptions = {down=true, up=true, ctrl=true, shift=false, alt=false}
	end

	local page = {
		{
			type = "ScrollFrame",
			layout = "list",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					children = {
						{
							type = "Label",
							text = L["Many commonly-used buttons in TSM can be macro'd and bound to your scroll wheel. Below, select the buttons you would like to include in this macro and the modifier(s) you would like to use with the scroll wheel."],
							relativeWidth = 1,
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					children = {
						{
							type = "CheckBox",
							label = "TSM Sniper Button",
							settingInfo = { macroButtons, "sniper" },
							tooltip = "Will include the TSM Sniper button in the macro.",
						},
						{
							type = "HeadingLine",
						},
						{
							type = "CheckBox",
							label = "TSM Cancel Button",
							settingInfo = { macroButtons, "cancel" },
							tooltip = "Will include the TSM Cancel button in the macro.",
						},
						{
							type = "HeadingLine",
						},
						{
							type = "CheckBox",
							label = "TSM Auctioning Button",
							settingInfo = { macroButtons, "auctioning" },
							tooltip = "Will include the TSM Auctioning button in the macro.",
						},
						{
							type = "HeadingLine",
						},
						{
							type = "CheckBox",
							label = L["TSM_Crafting 'Craft Next' Button"],
							settingInfo = { macroButtons, "craftingCraftNext" },
							tooltip = L["Will include the TSM_Crafting 'Craft Next' button in the macro."],
						},
						{
							type = "HeadingLine",
						},
						{
							type = "CheckBox",
							label = L["TSM_Destroying 'Destroy Next' Button"],
							settingInfo = { macroButtons, "destroyingDestroyNext" },
							tooltip = L["Will include the TSM_Destroying 'Destroy Next' button in the macro."],
						},
						{
							type = "HeadingLine",
						},
						{
							type = "CheckBox",
							label = L["TSM_Shopping 'Buyout' Button"],
							settingInfo = { macroButtons, "shoppingBuyout" },
							tooltip = L["Will include the TSM_Shopping button in the macro."],
						},
						{
							type = "HeadingLine",
						},
						{
							type = "CheckBox",
							label = L["TSM_Vendoring 'Sell All' Button"],
							settingInfo = { macroButtons, "vendoringSellAll" },
							tooltip = L["Will include the TSM_Vendoring 'Sell All' button in the macro."],
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					children = {
						{
							type = "Label",
							text = L["Scroll Wheel Direction:"],
							relativeWidth = 0.4,
						},
						{
							type = "CheckBox",
							label = L["Up"],
							relativeWidth = 0.3,
							settingInfo = { macroOptions, "up" },
							tooltip = L["Will cause the macro to be triggered when the scroll wheel goes up (with the selected modifiers pressed)."],
						},
						{
							type = "CheckBox",
							label = L["Down"],
							relativeWidth = 0.3,
							settingInfo = { macroOptions, "down" },
							tooltip = L["Will cause the macro to be triggered when the scroll wheel goes down (with the selected modifiers pressed)."],
						},
						{
							type = "Label",
							text = L["Modifiers:"],
							relativeWidth = 0.4,
						},
						{
							type = "CheckBox",
							label = "ALT",
							relativeWidth = 0.2,
							settingInfo = { macroOptions, "alt" },
						},
						{
							type = "CheckBox",
							label = "CTRL",
							relativeWidth = 0.2,
							settingInfo = { macroOptions, "ctrl" },
						},
						{
							type = "CheckBox",
							label = "SHIFT",
							relativeWidth = 0.2,
							settingInfo = { macroOptions, "shift" },
						},
						{
							type = "HeadingLine",
						},
						{
							type = "Button",
							relativeWidth = 1,
							text = L["Create Macro and Bind Scroll Wheel"],
							callback = function()
								-- delete old bindings
								for _, binding in ipairs({GetBindingKey("MACRO TSMAucBClick")}) do
									SetBinding(binding)
								end
								for _, binding in ipairs({GetBindingKey("MACRO TSMMacro")}) do
									SetBinding(binding)
								end

								-- delete old macros
								DeleteMacro("TSMAucBClick")
								DeleteMacro("TSMMacro")

								-- create the new macro
								local lines = {}
								for key, enabled in pairs(macroButtons) do
									if enabled then
										TSMAPI:Assert(macroButtonNames[key])
										tinsert(lines, "/click "..macroButtonNames[key])
									end
								end
								local macroText = table.concat(lines, "\n")
								CreateMacro("TSMMacro", "Achievement_Faction_GoldenLotus", macroText)

								-- create the scroll wheel binding
								local modifierStr = (macroOptions.ctrl and "CTRL-" or "")..(macroOptions.alt and "ALT-" or "")..(macroOptions.shift and "SHIFT-" or "")
								local bindingNum = (GetCurrentBindingSet() == 1) and 2 or 1
								if macroOptions.up then
									SetBinding(modifierStr.."MOUSEWHEELUP", nil, bindingNum)
									SetBinding(modifierStr.."MOUSEWHEELUP", "MACRO TSMMacro", bindingNum)
								end
								if macroOptions.down then
									SetBinding(modifierStr.."MOUSEWHEELDOWN", nil, bindingNum)
									SetBinding(modifierStr.."MOUSEWHEELDOWN", "MACRO TSMMacro", bindingNum)
								end
								SaveBindings(2)

								TSM:Print(L["Macro created and scroll wheel bound!"])
								if #macroText > 255 then
									TSM:Print(L["WARNING: The macro was too long, so was truncated to fit by WoW."])
								end
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
-- Custom Price Sources Tab
-- ============================================================================

function private:LoadCustomPriceSources(parent)
	private.treeGroup = AceGUI:Create("TSMTreeGroup")
	private.treeGroup:SetLayout("Fill")
	private.treeGroup:SetCallback("OnGroupSelected", private.SelectCustomPriceSourcesTree)
	parent:AddChild(private.treeGroup)

	private:UpdateCustomPriceSourcesTree()
	private.treeGroup:SelectByPath(1)
end

function private:UpdateCustomPriceSourcesTree()
	if not private.treeGroup then return end

	local children = {}
	for name in pairs(TSM.db.global.userData.customPriceSources) do
		tinsert(children, {value=name, text=name})
	end
	sort(children, function(a, b) return strlower(a.value) < strlower(b.value) end)
	private.treeGroup:SetTree({{value=1, text=L["Sources"], children=children}})
end

function private.SelectCustomPriceSourcesTree(treeGroup, _, selection)
	treeGroup:ReleaseChildren()

	selection = {("\001"):split(selection)}
	if #selection == 1 then
		private:DrawNewCustomPriceSource(treeGroup)
	else
		local name = selection[#selection]
		private:DrawCustomPriceSourceOptions(treeGroup, name)
	end
end

function private:DrawNewCustomPriceSource(container)
	local page = {
		{	-- scroll frame to contain everything
			type = "ScrollFrame",
			layout = "List",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["New Custom Price Source"],
					children = {
						{
							type = "Label",
							relativeWidth = 1,
							text = L["Custom price sources allow you to create more advanced custom prices throughout all of the TSM modules. Just as you can use the built-in price sources such as 'vendorsell' and 'vendorbuy' in your custom prices, you can use ones you make here (which themselves are custom prices)."],
						},
						{
							type = "HeadingLine",
						},
						{
							type = "EditBox",
							label = L["Custom Price Source Name"],
							relativeWidth = 1,
							callback = function(self,_,value)
								value = strlower(strtrim(value or ""))
								if value == "" then return end
								if gsub(value, "([a-z]+)", "") ~= "" then
									return TSM:Print(L["The name can ONLY contain letters. No spaces, numbers, or special characters."])
								end
								if not TSMAPI_FOUR.CustomPrice.ValidateName(value) then
									return TSM:Printf(L["Error creating custom price source. Price source with name '%s' already exists."], value)
								end
								TSM.CustomPrice.CreateCustomPriceSource(value, "")
								private:UpdateCustomPriceSourcesTree()
								private.treeGroup:SelectByPath(1, value)
							end,
							tooltip = L["Give your new custom price source a name. This is what you will type in to custom prices and is case insensitive (everything will be saved as lower case)."].."\n\n"..TSMAPI.Design:ColorText(L["The name can ONLY contain letters. No spaces, numbers, or special characters."], "link"),
						},
					},
				},
			},
		},
	}
	TSMAPI.GUI:BuildOptions(container, page)
end

function private:DrawCustomPriceSourceOptions(container, customPriceName)
	local page = {
		{	-- scroll frame to contain everything
			type = "ScrollFrame",
			layout = "List",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Custom Price Source"],
					children = {
						{
							type = "Label",
							relativeWidth = 1,
							text = L["Below, set the custom price that will be evaluated for this custom price source."],
						},
						{
							type = "HeadingLine",
						},
						{
							type = "EditBox",
							label = L["Custom Price for this Source"],
							settingInfo = {TSM.db.global.userData.customPriceSources, customPriceName},
							relativeWidth = 1,
							acceptCustom = true,
							tooltip = "",
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Management"],
					children = {
						{
							type = "EditBox",
							label = L["Rename Custom Price Source"],
							value = customPriceName,
							relativeWidth = 0.5,
							callback = function(self,_,name)
								name = strlower(strtrim(name or ""))
								if name == "" then return end
								if gsub(name, "([a-z]+)", "") ~= "" then
									return TSM:Print(L["The name can ONLY contain letters. No spaces, numbers, or special characters."])
								end
								if not TSMAPI_FOUR.CustomPrice.ValidateName(name) then
									return TSM:Printf(L["Error creating custom price source. Price source with name '%s' already exists."], name)
								end
								TSM.CustomPrice.RenameCustomPriceSource(customPriceName, name)
								private:UpdateCustomPriceSourcesTree()
								private.treeGroup:SelectByPath(1, name)
							end,
							tooltip = L["Give your new custom price source a name. This is what you will type in to custom prices and is case insensitive (everything will be saved as lower case)."].."\n\n"..TSMAPI.Design:ColorText(L["The name can ONLY contain letters. No spaces, numbers, or special characters."], "link"),
						},
						{
							type = "Button",
							text = L["Delete Custom Price Source"],
							relativeWidth = 0.5,
							callback = function()
								TSM.CustomPrice.DeleteCustomPriceSource(customPriceName)
								private:UpdateCustomPriceSourcesTree()
								private.treeGroup:SelectByPath(1)
								TSM:Printf(L["Removed '%s' as a custom price source. Be sure to update any custom prices that were using this source."], customPriceName)
							end,
						},
					},
				},
			},
		},
	}
	TSMAPI.GUI:BuildOptions(container, page)
end
