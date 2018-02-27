-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- This file contains all the code for the stuff that shows under the "Status" icon in the main TSM window.

local _, TSM = ...
local Options = TSM:NewModule("Options")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local LibDBIcon = LibStub("LibDBIcon-1.0")
local AceGUI = LibStub("AceGUI-3.0") -- load the AceGUI libraries
local private = {treeGroup=nil, moduleOptions={}}



-- ============================================================================
-- Module Functions
-- ============================================================================

function Options:RegisterModuleOptions(moduleName, callback)
	private.moduleOptions[moduleName] = callback
end

function Options.Load(parent)
	private.treeGroup = AceGUI:Create("TSMTreeGroup")
	private.treeGroup:SetLayout("Fill")
	private.treeGroup:SetCallback("OnGroupSelected", private.SelectTree)
	parent:AddChild(private.treeGroup)

	local moduleChildren = {}
	for name, callback in pairs(private.moduleOptions) do
		tinsert(moduleChildren, {value=name, text=name})
	end
	sort(moduleChildren, function(a, b) return a.value < b.value end)

	-- update the tree items
	local treeInfo = {
		{
			value = "feature",
			text = L["Features"]
		},
		{
			value = "module",
			text = L["Module Options"],
			children = moduleChildren,
		},
		TSM.Tooltips:GetTreeInfo("tooltip"),
	}
	private.treeGroup:SetTree(treeInfo)
	private.treeGroup:SelectByPath("feature")
end

function private.SelectTree(treeGroup, _, selection)
	treeGroup:ReleaseChildren()
	StaticPopup_Hide("TSM_GLOBAL_OPERATIONS")

	local major, minor = ("\001"):split(selection)
	if major == "feature" then
		TSM.FeaturesGUI.LoadGUI(treeGroup)
	elseif major == "module" then
		if not minor then
			private:LoadOptions(treeGroup)
		else
			private.moduleOptions[minor](treeGroup)
		end
	elseif major == "tooltip" then
		TSM.Tooltips:LoadOptions(treeGroup, minor)
	end
end



-- ============================================================================
-- General Options Page
-- ============================================================================

function private:LoadOptions(parent)
	local tg = AceGUI:Create("TSMTabGroup")
	tg:SetLayout("Fill")
	tg:SetFullHeight(true)
	tg:SetFullWidth(true)
	tg:SetTabs({{value=1, text=L["General"]}, {value=3, text=L["Profiles"]}, {value=4, text=L["Account Syncing"]}, {value=5, text=L["Misc. Features"]}})
	tg:SetCallback("OnGroupSelected", function(self, _, value)
		self:ReleaseChildren()
		if value == 1 then
			private:LoadOptionsPage(self)
		elseif value == 3 then
			private:LoadProfilesPage(self)
		elseif value == 4 then
			private:LoadMultiAccountPage(self)
		elseif value == 5 then
			private:LoadMiscFeatures(self)
		end
	end)
	parent:AddChild(tg)
	tg:SelectTab(1)
end

function private:LoadOptionsPage(container)
	local auctionTabs, auctionTabOrder
	if AuctionFrame and AuctionFrame.numTabs then
		auctionTabs, auctionTabOrder = {}, {}
		for i = 1, AuctionFrame.numTabs do
			local text = gsub(_G["AuctionFrameTab" .. i]:GetText(), "|r", "")
			text = gsub(text, "|c[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]", "")
			auctionTabs[text] = text
			tinsert(auctionTabOrder, text)
		end
	end

	local characterList = {}
	for character in pairs(TSMAPI.Player:GetCharacters(true)) do
		if character ~= UnitName("player") then
			tinsert(characterList, character)
		end
	end

	local guildList, guildValues = {}, {}
	for guild in pairs(TSMAPI.Player:GetGuilds(true)) do
		tinsert(guildList, guild)
		tinsert(guildValues, TSM.db.factionrealm.coreOptions.ignoreGuilds[guild])
	end

	local chatFrameList = {}
	local chatFrameValue, defaultValue
	for i=1, NUM_CHAT_WINDOWS do
		if DEFAULT_CHAT_FRAME == _G["ChatFrame"..i] then
			defaultValue = i
		end
		local name = strlower(GetChatWindowInfo(i) or "")
		if name ~= "" then
			if name == TSM.db.global.coreOptions.chatFrame then
				chatFrameValue = i
			end
			tinsert(chatFrameList, name)
		end
	end
	chatFrameValue = chatFrameValue or defaultValue

	local page = {
		{
			type = "ScrollFrame",
			layout = "flow",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["General Settings"],
					children = {
						{
							type = "CheckBox",
							label = L["Hide Minimap Icon"],
							settingInfo = { TSM.db.global.coreOptions.minimapIcon, "hide" },
							relativeWidth = 0.5,
							callback = function(_, _, value)
								if value then
									LibDBIcon:Hide("TradeSkillMaster")
								else
									LibDBIcon:Show("TradeSkillMaster")
								end
							end,
						},
						{
							type = "CheckBox",
							label = L["Store Operations Globally"],
							value = TSM.db.global.coreOptions.globalOperations,
							relativeWidth = 0.5,
							callback = function(_, _, value)
								StaticPopupDialogs["TSM_GLOBAL_OPERATIONS"] = StaticPopupDialogs["TSM_GLOBAL_OPERATIONS"] or {
									text = L["If you have multiple profile set up with operations, enabling this will cause all but the current profile's operations to be irreversibly lost. Are you sure you want to continue?"],
									button1 = YES,
									button2 = CANCEL,
									timeout = 0,
									hideOnEscape = true,
									OnAccept = function()
										-- we shouldn't be running the OnProfileUpdated callback while switching profiles
										TSM.Modules.ignoreProfileUpdated = true
										TSM.db.global.coreOptions.globalOperations = StaticPopupDialogs["TSM_GLOBAL_OPERATIONS"].newValue
										if TSM.db.global.coreOptions.globalOperations then
											-- move current profile to global
											TSM.db.global.userData.operations = CopyTable(TSM.db.profile.userData.operations)
											-- clear out old operations
											for profile in TSMAPI:GetTSMProfileIterator() do
												TSM.db.profile.userData.operations = nil
											end
										else
											-- move global to all profiles
											for profile in TSMAPI:GetTSMProfileIterator() do
												TSM.db.profile.userData.operations = CopyTable(TSM.db.global.userData.operations)
											end
											-- clear out old operations
											TSM.db.global.userData.operations = nil
										end
										TSM.Modules.ignoreProfileUpdated = false
										TSM.Modules.ProfileUpdated()
										if container.frame:IsVisible() then
											container:Reload()
										end
									end,
								}
								StaticPopupDialogs["TSM_GLOBAL_OPERATIONS"].newValue = value
								container:Reload()
								TSMAPI.Util:ShowStaticPopupDialog("TSM_GLOBAL_OPERATIONS")
							end,
							tooltip = L["If checked, operations will be stored globally rather than by profile. TSM groups are always stored by profile. Note that if you have multiple profiles setup already with separate operation information, changing this will cause all but the current profile's operations to be lost."],
						},
						{
							type = "Dropdown",
							label = L["Chat Tab"],
							list = chatFrameList,
							value = chatFrameValue,
							callback = function(_, _, value)
								TSM.db.global.coreOptions.chatFrame = chatFrameList[value]
							end,
							relativeWidth = 0.5,
							tooltip = L["This option sets which tab TSM and its modules will use for printing chat messages."],
						},
						{
							type = "HeadingLine",
						},
						{
							type = "Dropdown",
							label = L["Forget Characters"],
							list = characterList,
							relativeWidth = 0.5,
							callback = function(_, _, value)
								local name = characterList[value]
								TSM.db:RemoveSyncCharacter(name)
								TSM.db.factionrealm.internalData.pendingMail[name] = nil
								TSM.db.factionrealm.internalData.characterGuilds[name] = nil
								TSM:Printf(L["%s removed."], name)
								container:Reload()
							end,
							tooltip = L["If you delete, rename, or transfer a character off the current faction/realm, you should remove it from TSM's list of characters using this dropdown."],
						},
						{
							type = "Dropdown",
							label = L["Ignore Guilds"],
							list = guildList,
							value = guildValues,
							relativeWidth = 0.5,
							multiselect = true,
							callback = function(_, _, key, value)
								local guild = guildList[key]
								TSM.db.factionrealm.coreOptions.ignoreGuilds[guild] = value
							end,
							tooltip = L["Any guilds which are selected will be ignored for inventory tracking purposes."],
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["BankUI Settings"],
					children = {
						{
							type = "Dropdown",
							label = L["Default BankUI Tab"],
							list = TSM:getBankTabs(),
							settingInfo = { TSM.db.global.coreOptions, "bankUITab" },
							relativeWidth = 0.5,
							tooltip = L["The default tab shown in the 'BankUI' frame."],
						},
						{
							type = "Slider",
							value = TSM.db.global.coreOptions.moveDelay,
							label = L["BankUI Move Delay"],
							min = 0,
							max = 2,
							step = 0.1,
							relativeWidth = 0.49,
							disabled = not TSM.db.global.coreOptions.moveDelay,
							callback = function(self, _, value)
								if value > 2 then value = 2 end
								self:SetValue(value)
								TSM.db.global.coreOptions.moveDelay = value
							end,
							tooltip = L["This slider controls how long the BankUI code will sleep betwen individual moves, default of 0 should be fine but increase it if you run into problems."],
						},
						{
							type = "HeadingLine",
						},
						{
							type = "CheckBox",
							label = L["Clean Bags Automatically"],
							settingInfo = { TSM.db.profile.coreOptions, "cleanBags" },
							relativeWidth = 0.5,
							tooltip = L["If checked, after moving items using BankUI your bags will be automatically sorted / re-stacked."],
						},
						{
							type = "CheckBox",
							label = L["Clean Bank Automatically"],
							settingInfo = { TSM.db.profile.coreOptions, "cleanBank" },
							relativeWidth = 0.5,
							tooltip = L["If checked, after moving items using BankUI at the bank your bank bags will be automatically sorted / re-stacked."],
						},
						{
							type = "CheckBox",
							label = L["Clean Reagent Bank Automatically"],
							settingInfo = { TSM.db.profile.coreOptions, "cleanReagentBank" },
							relativeWidth = 0.5,
							tooltip = L["If checked, after moving items using BankUI at the bank your reagent bank bags will be automatically sorted / re-stacked."],
						},
					}
				},
			},
		},
	}

	TSMAPI.GUI:BuildOptions(container, page)
end



-- ============================================================================
-- Profiles Tab
-- ============================================================================

function private:LoadProfilesPage(container)
	-- Popup Confirmation Window used in this module
	StaticPopupDialogs["TSMDeleteConfirm"] = StaticPopupDialogs["TSMDeleteConfirm"] or {
		text = L["Are you sure you want to delete the selected profile?"],
		button1 = ACCEPT,
		button2 = CANCEL,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		OnCancel = false,
		-- OnAccept defined later
	}
	StaticPopupDialogs["TSMCopyProfileConfirm"] = StaticPopupDialogs["TSMCopyProfileConfirm"] or {
		text = L["Are you sure you want to overwrite the current profile with the selected profile?"],
		button1 = ACCEPT,
		button2 = CANCEL,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		OnCancel = false,
		-- OnAccept defined later
	}

	local profiles = {}
	for _, profileName in ipairs(TSM.db:GetProfiles()) do
		if profileName ~= TSM.db:GetCurrentProfile() then
			profiles[profileName] = profileName
		end
	end

	local page = {
		{
			-- scroll frame to contain everything
			type = "ScrollFrame",
			layout = "Flow",
			children = {
				{
					type = "Label",
					text = L["You can change the active database profile, so you can have different settings for every character."],
					relativeWidth = 1,
				},
				{
					type = "Spacer"
				},
				{
					type = "Label",
					text = L["Reset the current profile back to its default values, in case your configuration is broken, or you simply want to start over."],
					relativeWidth = 1,
				},
				{
					type = "Button",
					text = L["Reset Profile"],
					relativeWidth = 0.5,
					callback = function() TSM.db:ResetProfile() end,
				},
				{
					type = "Label",
					text = L["Current Profile:"].." "..TSMAPI.Design:ColorText(TSM.db:GetCurrentProfile(), "link"),
					relativeWidth = 0.5,
				},
				{
					type = "HeadingLine",
				},
				{
					type = "Label",
					text = L["You can either create a new profile by entering a name in the editbox, or choose one of the already exisiting profiles."],
					relativeWidth = 1,
				},
				{
					type = "EditBox",
					label = L["New"],
					value = "",
					relativeWidth = 0.5,
					callback = function(_, _, value)
						value = strtrim(value)
						if not TSM.db:IsValidProfileName(value) then
							return TSM:Print(L["This is not a valid profile name. Profile names must be at least one character long and may not contain '@' characters."])
						end
						TSM.db:SetProfile(value)
						container:Reload()
					end,
				},
				{
					type = "Dropdown",
					label = L["Existing Profiles"],
					list = profiles,
					value = TSM.db:GetCurrentProfile(),
					disabled = not next(profiles),
					relativeWidth = 0.5,
					callback = function(_, _, value)
						if value == TSM.db:GetCurrentProfile() then return end
						TSM.db:SetProfile(value)
						container:Reload()
					end,
				},
				{
					type = "HeadingLine",
				},
				{
					type = "Label",
					text = L["Copy the settings from one existing profile into the currently active profile."],
					relativeWidth = 1,
				},
				{
					type = "Dropdown",
					label = L["Copy From"],
					list = profiles,
					disabled = not next(profiles),
					value = "",
					callback = function(_, _, value)
						if value == TSM.db:GetCurrentProfile() then return end
						StaticPopupDialogs["TSMCopyProfileConfirm"].OnAccept = function()
							TSM.db:CopyProfile(value)
							container:Reload()
						end
						TSMAPI.Util:ShowStaticPopupDialog("TSMCopyProfileConfirm")
					end,
				},
				{
					type = "HeadingLine",
				},
				{
					type = "Label",
					text = L["Delete existing and unused profiles from the database to save space, and cleanup the SavedVariables file."],
					relativeWidth = 1,
				},
				{
					type = "Dropdown",
					label = L["Delete a Profile"],
					list = profiles,
					disabled = not next(profiles),
					value = "",
					callback = function(_, _, value)
						if TSM.db:GetCurrentProfile() == value then return end
						StaticPopupDialogs["TSMDeleteConfirm"].OnAccept = function()
							TSM.db:DeleteProfile(value)
							container:Reload()
						end
						TSMAPI.Util:ShowStaticPopupDialog("TSMDeleteConfirm")
					end,
				},
			},
		},
	}

	TSMAPI.GUI:BuildOptions(container, page)
end



-- ============================================================================
-- Multi-Account Tab
-- ============================================================================

function private:LoadMultiAccountPage(parent)
	local page = {
		{
			type = "ScrollFrame",
			layout = "flow",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					children = {
						{
							type = "Label",
							relativeWidth = 1,
							text = L["Various modules can sync their data between multiple accounts automatically whenever you're logged into both accounts."],
						},
						{
							type = "Spacer",
						},
						{
							type = "Label",
							relativeWidth = 1,
							text = L["First, log into a character on the same realm (and faction) on both accounts. Type the name of the OTHER character you are logged into in the box below. Once you have done this on both accounts, TSM will do the rest automatically. Once setup, syncing will automatically happen between the two accounts while on any character on the account (not only the one you entered during this setup)."],
						},
						{
							type = "EditBox",
							relativeWidth = 1,
							label = L["Character Name on Other Account"],
							callback = function(self, _, value)
								value = strtrim(value)
								local function OnSyncSetup()
									TSM:Print(L["Connection established!"])
									if value == self:GetText() then
										parent:Reload()
									end
								end
								if TSM.Sync.Connection.Establish(strtrim(value), OnSyncSetup) then
									TSM:Printf(L["Establishing connection to %s. Make sure that you've entered this character's name on the other account."], value)
								else
									self:SetText("")
								end
							end,
							tooltip = L["See instructions above this editbox."],
						},
					},
				},
			},
		},
	}

	-- extra multi-account syncing widgets
	local addedHeader = false
	for _, account in TSM.db:SyncAccountIterator() do
		if not addedHeader then
			addedHeader = true
			local widgets = {
				{
					type = "HeadingLine",
				},
				{
					type = "Button",
					text = L["Refresh Sync Status"],
					relativeWidth = 1,
					callback = function() parent:Reload() end,
				},
			}
			for _, widget in ipairs(widgets) do
				tinsert(page[1].children[1].children, widget)
			end
		end
		local playerList = {}
		for _, player in TSM.db:FactionrealmCharacterByAccountIterator(account) do
			tinsert(playerList, player)
		end
		local widget = {
			type = "InlineGroup",
			layout = "flow",
			children = {
				{
					type = "Label",
					relativeWidth = 0.7,
					text = L["Status: "]..TSM.Sync.Connection.GetStatus(account),
				},
				{
					type = "Label",
					relativeWidth = 0.05,
				},
				{
					type = "Button",
					text = L["Remove Account"],
					relativeWidth = 0.24,
					callback = function()
						TSM.Sync.Connection.Remove(account)
						TSM:Print(L["Sync removed. Make sure you remove the sync from the other account as well."])
						parent:Reload()
					end,
				},
				{
					type = "Label",
					relativeWidth = 1,
					text = L["Known Characters: "]..TSMAPI.Design:GetInlineColor("link")..table.concat(playerList, ", ").."|r",
				},
			},
		}
		tinsert(page[1].children, widget)
	end

	TSMAPI.GUI:BuildOptions(parent, page)
end



-- ============================================================================
-- Multi-Account Tab
-- ============================================================================

function private:PromptToReload()
	StaticPopupDialogs["TSMReloadPrompt"] = StaticPopupDialogs["TSMReloadPrompt"] or {
		text = L["You must reload your UI for these settings to take effect. Reload now?"],
		button1 = YES,
		button2 = NO,
		timeout = 0,
		OnAccept = ReloadUI,
	}
	TSMAPI.Util:ShowStaticPopupDialog("TSMReloadPrompt")
end

function private:LoadMiscFeatures(container)
	local page = {
		{
			type = "ScrollFrame",
			layout = "list",
			children = {
				{
					type = "InlineGroup",
					layout = "Flow",
					title = L["Auction Buys"],
					children = {
						{
							type = "Label",
							text = L["The auction buys feature will change the 'You have won an auction of XXX' text into something more useful which contains the link, stack size, and price of the item you bought."],
							relativeWidth = 1,
						},
						{
							type = "HeadingLine"
						},
						{
							type = "CheckBox",
							label = L["Enable Auction Buys Feature"],
							relativeWidth = 1,
							settingInfo = {TSM.db.global.coreOptions, "auctionBuyEnabled"},
							callback = private.PromptToReload,
						},
					},
				},
				{
					type = "Spacer"
				},
				{
					type = "InlineGroup",
					layout = "Flow",
					title = L["Auction Sales"],
					children = {
						{
							type = "Label",
							text = L["The auction sales feature will change the 'A buyer has been found for your auction of XXX' text into something more useful which contains a link to the item and, if possible, the amount the auction sold for."],
							relativeWidth = 1,
						},
						{
							type = "HeadingLine"
						},
						{
							type = "CheckBox",
							label = L["Enable Auction Sales Feature"],
							relativeWidth = 1,
							settingInfo = {TSM.db.global.coreOptions, "auctionSaleEnabled"},
							callback = private.PromptToReload,
						},
						{
							type = "Dropdown",
							label = L["Enable Sound"],
							relativeWidth = 0.5,
							list = TSMAPI:GetSounds(),
							settingInfo = {TSM.db.global.coreOptions, "auctionSaleSound"},
							tooltip = L["Play the selected sound when one of your auctions sells."],
						},
						{
							type = "Button",
							text = L["Test Selected Sound"],
							relativeWidth = 0.49,
							callback = function() TSMAPI:DoPlaySound(TSM.db.global.coreOptions.auctionSaleSound) end,
						},
					},
				},
				{
					type = "Spacer"
				},
				{
					type = "InlineGroup",
					layout = "Flow",
					title = L["Twitter Integration"],
					children = {
						{
							type = "Label",
							text = L["If you have WoW's Twitter integration setup, TSM will add a share link to its enhanced auction sale / purchase messages (enabled above) as well as replace the URL in item tweets with a TSM link."],
							relativeWidth = 1,
						},
						{
							type = "HeadingLine"
						},
						{
							type = "CheckBox",
							label = L["Enable Tweet Enhancement (Only Works if WoW Twitter Integration is Setup)"],
							relativeWidth = 1,
							disabled = not C_Social.IsSocialEnabled(),
							settingInfo = {TSM.db.global.coreOptions, "tsmItemTweetEnabled"},
							callback = private.PromptToReload,
						},
					},
				},
			},
		},
	}
	TSMAPI.GUI:BuildOptions(container, page)
end
