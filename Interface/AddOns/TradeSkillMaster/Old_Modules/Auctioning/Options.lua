-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Auctioning                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctioning          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable and register this file as a module
local TSMCore = select(2, ...)
local TSM = TSMCore.old.Auctioning
local Options = TSM:NewPackage("Options")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local AceGUI = LibStub("AceGUI-3.0") -- load the AceGUI libraries
local private = {}



-- ============================================================================
-- Module Options
-- ============================================================================

function Options.Load(container)
	local tg = AceGUI:Create("TSMTabGroup")
	tg:SetLayout("Fill")
	tg:SetFullHeight(true)
	tg:SetFullWidth(true)
	tg:SetTabs({{value=1, text=L["General"]}, {value=2, text=L["Whitelist"]}})
	tg:SetCallback("OnGroupSelected", function(self, _, value)
		self:ReleaseChildren()
		if value == 1 then
			private:DrawGeneralSettings(self)
		elseif value == 2 then
			private:DrawWhitelistSettings(self)
		end
	end)
	container:AddChild(tg)
	tg:SelectTab(1)
end

function private:DrawGeneralSettings(container)
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
							type = "CheckBox",
							label = L["Cancel Auctions with Bids"],
							settingInfo = { TSMCore.db.global.auctioningOptions, "cancelWithBid" },
							tooltip = L["Will cancel auctions even if they have a bid on them, you will take an additional gold cost if you cancel an auction with bid."],
						},
						{
							type = "CheckBox",
							label = L["Round Normal Price"],
							settingInfo = { TSMCore.db.global.auctioningOptions, "roundNormalPrice" },
							tooltip = L["If checked, whenever you post an item at its normal price, the buyout will be rounded up to the nearest gold."],
						},
						{
							type = "CheckBox",
							label = L["Disable Invalid Price Warnings"],
							settingInfo = { TSMCore.db.global.auctioningOptions, "disableInvalidMsg" },
							relativeWidth = 1,
							tooltip = L["If checked, TSM will not print out a chat message when you have an invalid price for an item. However, it will still show as invalid in the log."],
						},
						{
							type = "Dropdown",
							label = L["Scan Complete Sound"],
							list = TSMAPI_FOUR.Sound.GetSounds(),
							settingInfo = { TSMCore.db.global.auctioningOptions, "scanCompleteSound" },
							tooltip = L["Play the selected sound when a post / cancel scan is complete and items are ready to be posted / canceled (the gray bar is all the way across)."],
						},
						{
							type = "Button",
							text = L["Test Selected Sound"],
							callback = function() TSMAPI_FOUR.Sound.PlaySound(TSMCore.db.global.auctioningOptions.scanCompleteSound) end,
						},
						{
							type = "Dropdown",
							label = L["Confirm Complete Sound"],
							list = TSMAPI_FOUR.Sound.GetSounds(),
							settingInfo = { TSMCore.db.global.auctioningOptions, "confirmCompleteSound" },
							tooltip = L["Play the selected sound when all posts / cancels are confirmed for a post / cancel scan."],
						},
						{
							type = "Button",
							text = L["Test Selected Sound"],
							callback = function() TSMAPI_FOUR.Sound.PlaySound(TSMCore.db.global.auctioningOptions.confirmCompleteSound) end,
						},
					},
				},
			},
		},
	}

	TSMAPI.GUI:BuildOptions(container, page)
end

function private:DrawWhitelistSettings(container)
	local function AddPlayer(self, _, value)
		value = string.trim(strlower(value or ""))
		if value == "" then return TSM:Print(L["No name entered."]) end

		if TSMCore.db.factionrealm.auctioningOptions.whitelist[value] then
			TSM:Printf(L["The player \"%s\" is already on your whitelist."], TSMCore.db.factionrealm.auctioningOptions.whitelist[value])
			return
		end

		local invalidPlayer = nil
		for _, character in TSMCore.db:FactionrealmCharacterIterator() do
			if strlower(character) == value then
				invalidPlayer = character
			end
		end
		if invalidPlayer then
			TSM:Printf(L["You do not need to add \"%s\", alts are whitelisted automatically."], invalidPlayer)
			return
		end

		TSMCore.db.factionrealm.auctioningOptions.whitelist[strlower(value)] = value
		container:Reload()
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
					title = L["Help"],
					children = {
						{
							type = "Label",
							relativeWidth = 1,
							fontObject = GameFontNormal,
							text = L["Whitelists allow you to set other players besides you and your alts that you do not want to undercut; however, if somebody on your whitelist matches your buyout but lists a lower bid it will still consider them undercutting."],
						},
						{
							type = "CheckBox",
							label = L["Match Whitelist Players"],
							settingInfo = { TSMCore.db.global.auctioningOptions, "matchWhitelist" },
							tooltip = L["If enabled, instead of not posting when a whitelisted player has an auction posted, Auctioning will match their price."],
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Add player"],
					children = {
						{
							type = "EditBox",
							label = L["Player Name"],
							relativeWidth = 1,
							callback = AddPlayer,
							tooltip = L["Add a new player to your whitelist."],
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Whitelist"],
					children = {},
				},
			},
		},
	}

	for name in pairs(TSMCore.db.factionrealm.auctioningOptions.whitelist) do
		tinsert(page[1].children[3].children,
			{
				type = "Label",
				text = TSMCore.db.factionrealm.auctioningOptions.whitelist[name],
				fontObject = GameFontNormal,
			})
		tinsert(page[1].children[3].children,
			{
				type = "Button",
				text = L["Delete"],
				relativeWidth = 0.3,
				callback = function(self)
					TSMCore.db.factionrealm.auctioningOptions.whitelist[name] = nil
					container:Reload()
				end,
			})
	end

	if #(page[1].children[3].children) == 0 then
		tinsert(page[1].children[3].children,
			{
				type = "Label",
				text = L["You do not have any players on your whitelist yet."],
				fontObject = GameFontNormal,
				relativeWidth = 1,
			})
	end

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
					label = L["Show Auctioning values in Tooltip"],
					settingInfo = { options, "operationPrices" },
					tooltip = L["If checked, the minimum, normal and maximum prices of the first operation for the item will be shown in tooltips."],
				},
			},
		},
	}

	TSMAPI.GUI:BuildOptions(container, page)
end
