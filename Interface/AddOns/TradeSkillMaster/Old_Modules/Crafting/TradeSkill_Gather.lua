-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Crafting                           --
--            http://www.curse.com/addons/wow/tradeskillmaster_crafting           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSMCore = select(2, ...)
local TSM = TSMCore.old.Crafting
local Gather = TSM.TradeSkill:NewPackage("Gather")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = { gatherSelection = {} }


function Gather:OnEnable()
	TSMAPI_FOUR.Event.Register("GUILDBANKFRAME_OPENED", private.EventHandler)
	TSMAPI_FOUR.Event.Register("GUILDBANKFRAME_CLOSED", private.EventHandler)
	TSMAPI_FOUR.Event.Register("GUILDBANKBAGSLOTS_CHANGED", private.EventHandler)
	TSMAPI_FOUR.Event.Register("MERCHANT_SHOW", private.EventHandler)
	TSMAPI_FOUR.Event.Register("MERCHANT_UPDATE", private.EventHandler)
	TSMAPI_FOUR.Event.Register("MERCHANT_CLOSED", private.EventHandler)
	TSMAPI_FOUR.Event.Register("MAIL_SHOW", private.EventHandler)
	TSMAPI_FOUR.Event.Register("MAIL_INBOX_UPDATE", private.EventHandler)
	TSMAPI_FOUR.Event.Register("MAIL_CLOSED", private.EventHandler)
	TSMAPI_FOUR.Event.Register("BANKFRAME_OPENED", private.EventHandler)
	TSMAPI_FOUR.Event.Register("BANKFRAME_CLOSED", private.EventHandler)
	TSMAPI_FOUR.Event.Register("UPDATE_PENDING_MAIL", private.EventHandler)
	TSMAPI_FOUR.Event.Register("AUCTION_HOUSE_SHOW", private.EventHandler)
	TSMAPI_FOUR.Event.Register("AUCTION_HOUSE_CLOSED", private.EventHandler)
	TSMAPI_FOUR.Event.Register("BAG_UPDATE", private.EventHandler)
	TSMAPI_FOUR.Event.Register("TRADE_SKILL_SHOW", private.EventHandler)
	TSMAPI_FOUR.Event.Register("TRADE_SKILL_CLOSE", private.EventHandler)

	Gather:CreateMainFrame()
	if next(TSMCore.db.factionrealm.internalData.gathering.neededMats) then
		TSMAPI.Delay:AfterTime("gatheringShowThrottle", 2, Gather.ShowGatheringFrame)
	end
end


-- ============================================================================
-- Module Functions
-- ============================================================================

function Gather:ShowGatheringFrame()
	if private.gatheringFrame then
		private.gatherSelection.player = TSMCore.db.factionrealm.internalData.gathering.crafter
		private.gatherSelection.professions = TSMCore.db.factionrealm.internalData.gathering.professions
		private.gatheringFrame:Show()
		if AuctionFrame and AuctionFrame:IsVisible() then
			private.EventHandler("AUCTION_HOUSE_SHOW")
		elseif BankFrame and BankFrame:IsVisible() then
			private.EventHandler("BANKFRAME_OPENED")
		elseif MerchantFrame and MerchantFrame:IsVisible() then
			private.EventHandler("MERCHANT_SHOW")
		elseif GuildBankFrame and GuildBankFrame:IsVisible() then
			private.EventHandler("GUILDBANKFRAME_OPENED")
		elseif private:canTransform() then
			private.EventHandler("BAG_UPDATE")
		end
		Gather:Update()
	end
end

function Gather:OnButtonClicked(frame)
	private.selectionFrame = frame
	private:UpdateGatherSelectionWindow()
end

function Gather:ResetGathering(hide)
	if private.gatheringFrame and hide then
		private.gatheringFrame:Hide()
		TSMCore.db.factionrealm.internalData.gathering.crafter = nil
		TSMCore.db.factionrealm.internalData.gathering.professions = nil
	end
	TSMCore.db.factionrealm.internalData.gathering.availableMats = {}
	TSMCore.db.factionrealm.internalData.gathering.neededMats = {}
	TSMCore.db.factionrealm.internalData.gathering.gatheredMats = false
	TSMCore.db.factionrealm.internalData.gathering.destroyingMats = {}
	TSMCore.db.factionrealm.internalData.gathering.selectedSourceStatus = {}
	TSMCore.db.factionrealm.internalData.gathering.selectedSources = {}
	TSMCore.db.factionrealm.internalData.gathering.shortItems = {}
	TSMCore.db.factionrealm.internalData.gathering.sessionOptions = {}
	private.currentSource = nil
end

function Gather:GetFrameInfo()
	local BFC = TSMAPI.GUI:GetBuildFrameConstants()

	return {
		type = "Frame",
		key = "gather",
		size = { 300, 450 },
		points = { { "CENTER" } },
		scripts = { "OnShow" },
		children = {
			{
				type = "Text",
				text = "TSM_Crafting - " .. L["Gathering"],
				size = { 0, 20 },
				points = { { "TOPLEFT" }, { "TOPRIGHT" } },
			},
			{
				type = "HLine",
				offset = -25,
			},
			{
				type = "Text",
				key = "instructions",
				text = L["First select a crafter"],
				size = { 0, 20 },
				justify = { "CENTER", "CENTER" },
				points = { { "TOPLEFT", 5, -28 }, { "TOPRIGHT", -5, -28 } },
			},
			{
				type = "HLine",
				offset = -52,
			},
			{
				type = "Dropdown",
				key = "playerDropdown",
				label = L["Crafter"],
				points = { { "TOPLEFT", 5, -55 }, { "TOPRIGHT", -5, -55 } },
				scripts = { "OnValueChanged" },
			},
			{
				type = "Dropdown",
				key = "professionDropdown",
				label = L["Professions"],
				multiselect = true,
				points = { { "TOPLEFT", 5, -100 }, { "TOPRIGHT", -5, -100 } },
				scripts = { "OnValueChanged" },
			},
			{
				type = "HLine",
				offset = -150,
			},
			{
				type = "Text",
				text = L["Override global options for the session"],
				size = { 0, 20 },
				justify = { "CENTER", "CENTER" },
				points = { { "TOPLEFT", BFC.PREV, "BOTTOMLEFT" }, { "TOPRIGHT", BFC.PREV, "BOTTOMRIGHT" } },
			},
			{
				type = "CheckBox",
				key = "disableCheckBox",
				label = L["Disable Crafting AH Search"],
				tooltip = L["Toggle to switch between Crafting and Normal searches at the Auction House."],
				size = { 190, 25 },
				points = { { "TOPLEFT", BFC.PREV, "BOTTOMLEFT" } },
				scripts = { "OnValueChanged" },
			},
			{
				type = "CheckBox",
				key = "ignoreDECheckBox",
				label = L["Disable DE Search"],
				tooltip = L["If enabled the crafting search at the Auction House will ignore Disenchantable Items."],
				size = { 155, 25 },
				points = { { "TOPLEFT", BFC.PREV, "BOTTOMLEFT" } },
				scripts = { "OnValueChanged" },
			},
			{
				type = "CheckBox",
				key = "evenStacksCheckBox",
				label = L["Even Stacks Only"],
				tooltip = L["If enabled the crafting search will only search for multiples of 5."],
				size = { 190, 25 },
				points = { { "TOPLEFT", BFC.PREV, "BOTTOMLEFT" } },
				scripts = { "OnValueChanged" },
			},
			{
				type = "CheckBox",
				key = "ignoreAlts",
				label = L["Ignore Alts"],
				tooltip = L["Toggle to ignore gathering from Alts."],
				size = { 190, 25 },
				points = { { "TOPLEFT", BFC.PREV, "BOTTOMLEFT" } },
				scripts = { "OnValueChanged" },
			},
			{
				type = "CheckBox",
				key = "ignoreIntermediate",
				label = L["Ignore Intermediate Crafting"],
				tooltip = L["Toggle to ignore intermediate crafting."],
				size = { 210, 25 },
				points = { { "TOPLEFT", BFC.PREV, "BOTTOMLEFT" } },
				scripts = { "OnValueChanged" },
			},
			{
				type = "CheckBox",
				key = "inkTrade",
				label = L["Trade Inks at the vendor"],
				tooltip = L["Toggle to suggest trading inks at the vendor."],
				size = { 190, 25 },
				points = { { "TOPLEFT", BFC.PREV, "BOTTOMLEFT" } },
				scripts = { "OnValueChanged" },
			},
			{
				type = "CheckBox",
				key = "buyAH",
				label = L["Always Buy from AH"],
				tooltip = L["If enabled, buying from AH will always be suggested even if you have enough via other sources. If disabled only short items will be searched for at the AH"],
				size = { 190, 25 },
				points = { { "TOPLEFT", BFC.PREV, "BOTTOMLEFT" } },
			},
			{
				type = "Button",
				key = "gatherSelectionButton",
				text = L["Start Gathering"],
				textHeight = 24,
				size = { 0, 40 },
				points = { { "BOTTOMLEFT", 5, 5 }, { "BOTTOMRIGHT", -5, 5 } },
				scripts = { "OnClick" },
			},
		},
		handlers = {
			OnShow = function(self)
				private:UpdateGatherSelectionWindow()
			end,
			playerDropdown = {
				OnValueChanged = function(self, value)
					private.gatherSelection.player = value
					private.gatherSelection.professions = nil
					private:UpdateGatherSelectionWindow()
				end,
			},
			professionDropdown = {
				OnValueChanged = function(self, profession, value)
					private.gatherSelection.professions[profession] = value or nil
					private:UpdateGatherSelectionWindow()
				end,
			},
			disableCheckBox = {
				OnValueChanged = function(self, value)
					TSMCore.db.factionrealm.internalData.gathering.sessionOptions.disableCheckBox = value
				end,
			},
			ignoreDECheckBox = {
				OnValueChanged = function(self, value)
					TSMCore.db.factionrealm.internalData.gathering.sessionOptions.ignoreDECheckBox = value
				end,
			},
			evenStacksCheckBox = {
				OnValueChanged = function(self, value)
					TSMCore.db.factionrealm.internalData.gathering.sessionOptions.evenStacks = value
				end,
			},
			ignoreAlts = {
				OnValueChanged = function(self, value)
					TSMCore.db.factionrealm.internalData.gathering.sessionOptions.ignoreAlts = value
				end,
			},
			ignoreIntermediate = {
				OnValueChanged = function(self, value)
					TSMCore.db.factionrealm.internalData.gathering.sessionOptions.ignoreIntermediate = value
				end,
			},
			inkTrade = {
				OnValueChanged = function(self, value)
					TSMCore.db.factionrealm.internalData.gathering.sessionOptions.inkTrade = value
				end,
			},
			gatherSelectionButton = {
				OnClick = function(self)
					TSMCore.db.factionrealm.internalData.gathering.sessionOptions = {
						disableCheckBox = private.selectionFrame.disableCheckBox:GetValue(),
						ignoreDECheckBox = private.selectionFrame.ignoreDECheckBox:GetValue(),
						evenStacks = private.selectionFrame.evenStacksCheckBox:GetValue(),
						ignoreAlts = private.selectionFrame.ignoreAlts:GetValue(),
						ignoreIntermediate = private.selectionFrame.ignoreIntermediate:GetValue(),
						inkTrade = private.selectionFrame.inkTrade:GetValue(),
						buyAH = private.selectionFrame.buyAH:GetValue()
					}
					Gather:StartGathering(private.gatherSelection.player, private.gatherSelection.professions)
					private.gatherSelection = {}
				end,
			},
		},
	}
end

function Gather:CreateMainFrame()
	if private.gatheringFrame then return end

	local frameDefaults = {
		x = 100,
		y = 300,
		width = 500,
		height = 400,
		scale = 1,
	}
	local BFC = TSMAPI.GUI:GetBuildFrameConstants()
	local frameInfo = {
		type = "MovableFrame",
		name = "TSMCraftingGatherFrame",
		movableDefaults = frameDefaults,
		minResize = { 365, 300 },
		children = {
			{
				type = "Text",
				text = "TSM_Crafting - " .. L["Gathering"],
				textFont = { TSMAPI.Design:GetContentFont(), 16 },
				points = { { "TOP", BFC.PARENT, 0, -5 } },
			},
			{
				type = "Button",
				key = "modeToggleBtn",
				text = L["Intermediate Crafting"],
				textHeight = 14,
				size = { 105, 30 },
				points = { { "TOPLEFT", 5, -35 }, { "RIGHT", BFC.PARENT, "CENTER", -5, 0 } },
				scripts = { "OnClick" },
			},
			{
				type = "HLine",
				offset = -70,
			},
			{
				type = "Frame",
				key = "mainFrame",
				points = { { "TOPLEFT", 5, -73 }, { "BOTTOMLEFT", 5, 33 }, { "RIGHT", BFC.PARENT, "RIGHT", -3, 0 } },
				children = {
					{
						type = "ScrollingTableFrame",
						key = "matST",
						headFontSize = 16,
						stCols = { { name = L["Sources"], width = 1 } },
						stDisableSelection = true,
						points = { { "TOPLEFT", BFC.PARENT, "TOPLEFT" }, { "BOTTOMLEFT", BFC.PARENT, "BOTTOMLEFT", -3, 33 }, { "RIGHT", BFC.PARENT, "CENTER", -3, 33 } },
					},
					{
						type = "VLine",
						offset = 0,
						points = { { "TOPLEFT", "matST", "TOPRIGHT", 2, 3 }, { "BOTTOMLEFT", "matST", "BOTTOMRIGHT", 2, -2 } },
					},
					{
						type = "ScrollingTableFrame",
						key = "sourceST",
						headFontSize = 16,
						stCols = { { name = L["Current Source"], width = 1 } },
						stDisableSelection = true,
						points = { { "TOPLEFT", "matST", "TOPRIGHT", 6, 0 }, { "BOTTOMLEFT", "matST", "BOTTOMRIGHT", 6, 0 }, { "TOPRIGHT", -5, -5 } },
						scripts = { "OnClick", "OnEnter", "OnLeave" },
					},
					{
						type = "HLine",
						offset = 0,
						size = { 0, 2 },
						points = { { "TOPLEFT", "matST", "BOTTOMLEFT", -5, -2 }, { "TOPRIGHT", "sourceST", "BOTTOMRIGHT", 5, -2 } },
					},
					{
						type = "Frame",
						key = "buttonsFrame",
						points = { { "TOPLEFT", BFC.PREV, "BOTTOMLEFT", 5, -10 }, { "BOTTOMRIGHT", BFC.PARENT, "BOTTOMRIGHT", -5, 5 } },
						children = {
							{
								type = "Button",
								key = "gatherItemsBtn",
								text = L["Gather Items"],
								disabled = true,
								textHeight = 18,
								size = { 105, 30 },
								points = { { "LEFT", 2, 0 }, { "RIGHT", BFC.PARENT, "CENTER", -2, 0 } },
								scripts = { "OnClick" },
							},
							{
								type = "Button",
								key = "gatherStopBtn",
								text = L["Stop Gathering"],
								textHeight = 18,
								size = { 105, 30 },
								points = { { "LEFT", BFC.PARENT, "CENTER", 2, 0 }, { "RIGHT", -2, 0 } },
								scripts = { "OnClick" },
							},
						},
					},
				},
			},
			{
				type = "Frame",
				key = "optionsFrame",
				points = { { "TOPLEFT", BFC.PREV, "BOTTOMLEFT", 0, -11 }, { "BOTTOMRIGHT", BFC.PARENT, "BOTTOMRIGHT" } },
				children = {
					{
						type = "IconButton",
						key = "sizer",
						icon = "Interface\\Addons\\TradeSkillMaster\\Media\\Sizer",
						size = { 16, 16 },
						points = { { "BOTTOMRIGHT", -2, 2 } },
						scripts = { "OnMouseDown", "OnMouseUp" },
					},
				},
			},
			{
				type = "Frame",
				key = "interFrame",
				hidden = true,
				points = { { "TOPLEFT", 5, -73 }, { "BOTTOMLEFT", 5, 33 }, { "RIGHT", BFC.PARENT, "RIGHT", -3, 0 } },
				children = {
					{
						type = "ScrollingTableFrame",
						key = "interSelST",
						headFontSize = 16,
						stCols = { { name = L["Selection"], width = 1 } },
						stDisableSelection = true,
						points = { { "TOPLEFT", BFC.PARENT, "TOPLEFT" }, { "BOTTOMLEFT", BFC.PARENT, "BOTTOMLEFT", -3, 33 }, { "RIGHT", BFC.PARENT, "CENTER", -3, 33 } },
						scripts = { "OnClick" },
					},
					{
						type = "VLine",
						offset = 0,
						points = { { "TOPLEFT", "interSelST", "TOPRIGHT", 2, 3 }, { "BOTTOMLEFT", "interSelST", "BOTTOMRIGHT", 2, -2 } },
					},
					{
						type = "ScrollingTableFrame",
						key = "interCraftST",
						headFontSize = 16,
						stCols = { { name = L["Craftable"], width = 1 } },
						stDisableSelection = true,
						points = { { "TOPLEFT", "interSelST", "TOPRIGHT", 6, 0 }, { "BOTTOMLEFT", "interSelST", "BOTTOMRIGHT", 6, 0 }, { "TOPRIGHT", -5, -5 } },
						--scripts = { "OnClick", "OnEnter", "OnLeave" },
					},
					{
						type = "HLine",
						offset = 0,
						size = { 0, 2 },
						points = { { "TOPLEFT", "interSelST", "BOTTOMLEFT", -5, -2 }, { "TOPRIGHT", "interCraftST", "BOTTOMRIGHT", 5, -2 } },
					},
					{
						type = "Frame",
						key = "interBtnFrame",
						points = { { "TOPLEFT", BFC.PREV, "BOTTOMLEFT", 5, -10 }, { "BOTTOMRIGHT", BFC.PARENT, "BOTTOMRIGHT", -5, 5 } },
						children = {
							{
								type = "Button",
								key = "craftNextBtn",
								text = L["Craft Next"],
								disabled = true,
								textHeight = 18,
								size = { 105, 30 },
								points = { { "LEFT", 2, 0 }, { "RIGHT", BFC.PARENT, "CENTER", -2, 0 } },
								scripts = { "OnClick" },
							},
						},
					},
				},
			},
		},
		handlers = {
			modeToggleBtn = {
				OnClick = function()
					if private.gatheringFrame.mainFrame:IsShown() then
						private.gatheringFrame.mainFrame:Hide()
						private.gatheringFrame.interFrame:Show()
						private.gatheringFrame.modeToggleBtn:SetText(L["Gathering"])
					else
						private.gatheringFrame.interFrame:Hide()
						private.gatheringFrame.mainFrame:Show()
						private.gatheringFrame.modeToggleBtn:SetText(L["Intermediate Crafting"])
					end
				end,
			},
			mainFrame = {
				sourceST = {
					OnClick = function(self, data, _, button)
						if not data.isTitle and data.sourceName == "auction" then
							--FIXME: should check if shopping is visible
							local disableCrafting = TSMCore.db.factionrealm.internalData.gathering.sessionOptions.disableCheckBox
							local ignoreDE = TSMCore.db.factionrealm.internalData.gathering.sessionOptions.ignoreDECheckBox
							local evenStacks = TSMCore.db.factionrealm.internalData.gathering.sessionOptions.evenStacks
							if button == "LeftButton" then
								TSM.Gather:ShoppingSearch(data.itemString, data.quantity, disableCrafting, ignoreDE, evenStacks, true)
							elseif button == "RightButton" then
								TSM.Gather:ShoppingSearch(data.itemString, math.huge, disableCrafting, ignoreDE, evenStacks, true)
							end
						end
					end,
					OnEnter = function(self, data)
						if data.isTitle or data.sourceName ~= "auction" then return end
						GameTooltip:SetOwner(self, "ANCHOR_NONE")
						GameTooltip:SetPoint("LEFT", self, "BOTTOM")
						GameTooltip:AddLine(L["Perform a manual AH search for this item"])
						GameTooltip:AddLine(L["Left click will set max quantity as quantity required"])
						GameTooltip:AddLine(L["Right click will search with no max quantity"])
						GameTooltip:Show()
					end,
					OnLeave = function()
						GameTooltip:Hide()
					end,
				},
				buttonsFrame = {
					gatherItemsBtn = {
						OnClick = function(self)
							TSM.Gather:gatherItems(private.currentSource, private.currentTask, TSMCore.db.factionrealm.internalData.gathering.sessionOptions.disableCheckBox, TSMCore.db.factionrealm.internalData.gathering.sessionOptionsignoreDECheckBox, TSMCore.db.factionrealm.internalData.gathering.sessionOptions.evenStacks)
						end,
					},
					gatherStopBtn = {
						OnClick = function(self)
							TSM.TradeSkill.Gather:ResetGathering(true)
						end,
					},
				},
			},
			optionsFrame = {
				sizer = {
					OnMouseDown = function()
						private.gatheringFrame:StartSizing("BOTTOMRIGHT")
					end,
					OnMouseUp = function()
						private.gatheringFrame:StopMovingOrSizing()
					end,
				},
			},
			interFrame = {
				interSelST = {
					OnClick = function(self, data)
						if data.isTitle then return end
						TSMCore.db.factionrealm.internalData.gathering.selectedSourceStatus[data.spellID] = not TSMCore.db.factionrealm.internalData.gathering.selectedSourceStatus[data.spellID]
						Gather:Update()
					end,
				},
				interBtnFrame = {
					craftNextBtn = {
						OnClick = function(self)
							TSM.Gather:gatherItems(private.currentSource, private.currentTask, TSMCore.db.factionrealm.internalData.gathering.sessionOptions.disableCheckBox, TSMCore.db.factionrealm.internalData.gathering.sessionOptionsignoreDECheckBox, TSMCore.db.factionrealm.internalData.gathering.sessionOptions.evenStacks)
						end,
					},
				},
			},
		},
	}

	private.gatheringFrame = TSMAPI.GUI:BuildFrame(frameInfo)
	TSMAPI.Design:SetFrameBackdropColor(private.gatheringFrame)
end

-- ============================================================================
-- Gather Selection Frame Update Functions
-- ============================================================================

function private:UpdateGatherSelectionWindow()
	-- create table of crafters
	local queuedCrafts = TSM.Queue:GetQueuedCrafts()

	-- get the list of players involved in the queue
	local crafters = {}
	local numCrafters = 0
	local currentPlayerName = UnitName("player")
	local hasCurrentPlayer = false
	for profession in pairs(queuedCrafts) do
		for player, data in pairs(TSMCore.db.factionrealm.internalData.playerProfessions) do
			if data[profession] then
				crafters[player] = player
				numCrafters = numCrafters + 1
				if player == currentPlayerName then
					hasCurrentPlayer = true
				end
			end
		end
	end
	private.gatherSelection.player = private.gatherSelection.player or (hasCurrentPlayer and currentPlayerName) or (numCrafters == 1 and next(crafters))
	private.selectionFrame.playerDropdown:SetList(crafters)
	private.selectionFrame.playerDropdown:SetValue(private.gatherSelection.player)
	if not private.gatherSelection.player then
		-- wait for user to choose a player
		private.selectionFrame.instructions:SetText(L["First select a crafter"])
		private.selectionFrame.playerDropdown:SetValue()
		private.selectionFrame.professionDropdown:SetDisabled(true)
		private.selectionFrame.professionDropdown:SetValue({})
		private.selectionFrame.gatherSelectionButton:Disable()
		return
	end

	private.selectionFrame.instructions:SetText(L["Select profession(s) and click start"])
	-- create table of professions
	local professions = {}
	for profession in pairs(queuedCrafts) do
		if TSMCore.db.factionrealm.internalData.playerProfessions[private.gatherSelection.player][profession] then
			professions[profession] = profession
		end
	end
	private.selectionFrame.professionDropdown:SetList(professions)
	if not private.gatherSelection.professions then
		private.gatherSelection.professions = {}
		for profession in pairs(professions) do
			private.gatherSelection.professions[profession] = true
		end
	end

	local currentProfession = TSM:GetCurrentProfessionName()
	if currentProfession and professions[currentProfession] then
		private.gatherSelection.professions[currentProfession] = true
	end

	if next(private.gatherSelection.professions) then
		private.selectionFrame.gatherSelectionButton:Enable()
	else
		private.selectionFrame.gatherSelectionButton:Disable()
	end
	private.selectionFrame.professionDropdown:SetDisabled(false)
	for profession in pairs(professions) do
		private.selectionFrame.professionDropdown:SetItemValue(profession, private.gatherSelection.professions[profession])
	end
end


-- ============================================================================
-- Gathering Frame Update Functions
-- ============================================================================

function Gather:StartGathering(player, professions)
	TSM:AnalyticsEvent("GATHERING_STARTED")
	private.gatheringFrame:Hide()
	TSMCore.db.factionrealm.internalData.gathering.gatheredMats = false
	local queuedMats = TSM.Queue:GetMatsByProfession(professions)

	local neededMats = {}
	for _, data in pairs(queuedMats) do
		for itemString, quantity in pairs(data) do
			neededMats[itemString] = (neededMats[itemString] or 0) + quantity
		end
	end

	if not next(neededMats) then
		TSM:Print(L["Nothing To Gather"])
		TSM.TradeSkill.Gather:ResetGathering(true)
	else
		TSMCore.db.factionrealm.internalData.gathering.crafter = player
		TSMCore.db.factionrealm.internalData.gathering.professions = professions
		TSMCore.db.factionrealm.internalData.gathering.neededMats = neededMats
		private.gatheringFrame:Show()
		Gather:Update(true)
	end
end

function private:GetAuctionQty(availableMats, itemString)
	if not availableMats or not itemString then return 0 end
	local auctionQty = 0
	for source, data in pairs(availableMats) do
		if source ~= "auction" then
			if source == "vendor" or source == "vendorT" then
				for itemString2, quantity in pairs(data) do
					if itemString == itemString2 then
						auctionQty = auctionQty + quantity
					end
				end
			else
				for location, items in pairs(data) do
					for itemString3, quantity in pairs(items) do
						if itemString == itemString3 then
							auctionQty = auctionQty + quantity
						end
					end
				end
			end
		end
	end
	return auctionQty
end

function private:canTransform()
	return true
end

function Gather:QueueUpdate()
	if not private.gatheringFrame or not private.gatheringFrame:IsVisible() then return end
	Gather:Update()
end

function Gather:Update(firstRun)
	if not private.gatheringFrame or not private.gatheringFrame:IsVisible() then return end
	if not TSMCore.db.factionrealm.internalData.gathering.crafter or not next(TSMCore.db.factionrealm.internalData.gathering.neededMats) then return end
	private.gatheringFrame.modeToggleBtn:SetDisabled(TSMCore.db.factionrealm.internalData.gathering.sessionOptions.ignoreIntermediate)
	-- recheck the craft queue and update neededMats
	local queuedMats = TSM.Queue:GetMatsByProfession(TSMCore.db.factionrealm.internalData.gathering.professions)
	local neededMats = {}
	for _, data in pairs(queuedMats) do
		for itemString, quantity in pairs(data) do
			neededMats[itemString] = (neededMats[itemString] or 0) + quantity
		end
	end

	local crafter = TSMCore.db.factionrealm.internalData.gathering.crafter
	local sources = TSM.Gather:GetItemSources(crafter, neededMats) or {}

	-- double check if crafter already has all the items needed
	local shortItems = {}
	for itemString, quantity in pairs(neededMats) do
		-- query item info as early as possible
		TSMAPI.Item:FetchInfo(itemString)
		local numHave = TSMAPI.Inventory:GetBagQuantity(itemString, crafter)
		if itemString ~= TSM.VELLUM_ITEM_STRING then
			numHave = numHave + TSMAPI.Inventory:GetReagentBankQuantity(itemString, crafter)
		end
		if numHave < quantity then
			shortItems[itemString] = quantity - numHave
		end
	end

	if not next(shortItems) then
		if TSMCore.db.factionrealm.internalData.gathering.gatheredMats == true then
			TSM:Print(L["Finished Gathering"])
		end
		Gather:ResetGathering(true)
		return
	else
		TSMCore.db.factionrealm.internalData.gathering.neededMats = neededMats
		TSMCore.db.factionrealm.internalData.gathering.shortItems = shortItems
	end

	local stData = {}
	for itemString, quantity in pairs(neededMats) do
		local need = max(quantity - TSMAPI.Inventory:GetTotalQuantity(itemString), 0)
		local color
		local crafterQty = TSMAPI.Inventory:GetBagQuantity(itemString, crafter) + TSMAPI.Inventory:GetReagentBankQuantity(itemString, crafter)

		if crafterQty < quantity then
			local selectedQuantity = sources[itemString] and sources[itemString]["selected"] or 0
			local selectedAH = sources[itemString] and sources[itemString]["ahQty"]
			if selectedAH and selectedQuantity >= (quantity - crafterQty) then
				color = "|cff00ff00"
			elseif selectedQuantity >= (quantity - crafterQty) then
				color = "|cffffff00"
			else
				color = "|cffff0000"
			end
			local itemName = TSMAPI.Item:GetName(itemString)
			local headerText = format(" %s %s|r", TSMAPI.Item:GetLink(itemString), color .. "(" .. min(selectedQuantity, (quantity - crafterQty)) .. "/" .. (quantity - crafterQty) .. ")")
			tinsert(stData, { cols = { { value = headerText } }, isTitle = true, itemString = itemString, name = itemName, need = need, quantity = quantity, selectedQuantity = selectedQuantity })

			local rowInserted = false
			for item, source in pairs(sources) do
				if item == itemString then
					local rowText, subRowText
					local leader = "     "
					local quantity = 0
					for sourceName, data in pairs(source) do
						if sourceName ~= "selected" and sourceName ~= "ahQty" then
							local total = 0
							for task, taskQuantity in pairs(data) do
								total = total + taskQuantity
							end
							quantity = total
							if sourceName == "crafting" then
								rowText = format("%s|r", leader .. L["Intermediate Craft"])
								tinsert(stData, { cols = { { value = rowText } }, isSubTitle = true, itemString = itemString, name = itemName, sourceName = sourceName, quantity = quantity })
								rowInserted = true
							else
								if sourceName == "auction" then
									rowText = format("%s|r", leader .. L["Buy From AH"])
								elseif sourceName == "vendorBuy" then
									rowText = format("%s|r", leader .. L["Buy From Vendor"])
								elseif sourceName == "vendorTrade" then
									rowText = format("%s|r", leader .. L["Vendor Trade"])
								elseif sourceName == "transform" then
									rowText = format("%s|r", leader .. L["Transform"])
								else
									rowText = format("%s|r", leader .. L["Retrieve From "] .. sourceName .. " (" .. min(shortItems[item], quantity) .. ")")
								end
								tinsert(stData, { cols = { { value = rowText } }, isTitle = false, itemString = itemString, name = itemName, sourceName = sourceName, quantity = quantity })
								rowInserted = true
							end
						end
					end
				end
			end
			if not rowInserted then
				local noneText = format("%s|r", "|cffff0000     " .. L["None Found"])
				tinsert(stData, { cols = { { value = noneText } }, isTitle = false, itemString = itemString, name = itemName, sourceName = "none", quantity = quantity })
			end
		end
	end
	sort(stData, private.SortSources)


	private.gatheringFrame.mainFrame.matST:SetData(stData)

	-- populate the selected sources
	local stData2 = {}
	local tempData = {}
	if next(sources) then
		local auctions, vendorBuy, vendorTrade, crafting, convert = {}, {}, {}, {}, {}
		local crafterTasks = {}
		local altTasks = {}
		for item, source in pairs(sources) do
			for sourceName, data in pairs(source) do
				if sourceName ~= "selected" and sourceName ~= "ahQty" then
					for task, taskQuantity in pairs(data) do
						if sourceName == "auction" then
							auctions[item] = taskQuantity
						elseif sourceName == "vendorBuy" then
							vendorBuy[item] = taskQuantity
						elseif sourceName == "vendorTrade" then
							vendorTrade[item] = taskQuantity
						elseif sourceName == "crafting" then
							crafting[task] = crafting[task] or {}
							crafting[task][item] = taskQuantity
						elseif sourceName == "transform" then
							convert[task] = convert[task] or {}
							convert[task][item] = taskQuantity
						elseif sourceName == crafter then
							crafterTasks[task] = crafterTasks[task] or {}
							crafterTasks[task][item] = taskQuantity
						else
							altTasks[sourceName] = altTasks[sourceName] or {}
							altTasks[sourceName][task] = altTasks[sourceName][task] or {}
							altTasks[sourceName][task][item] = taskQuantity
						end
					end
				end
			end
		end
		if next(crafterTasks) then
			tinsert(tempData, { source = "crafter", tasks = crafterTasks })
		end
		if next(vendorBuy) then
			tinsert(tempData, { source = "vendor", tasks = vendorBuy })
		end
		if next(crafting) then
			tinsert(tempData, { source = "crafting", tasks = crafting })
		end
		if next(convert) then
			tinsert(tempData, { source = "convert", tasks = convert })
		end
		if next(vendorTrade) then
			tinsert(tempData, { source = "vendorT", tasks = vendorTrade })
		end
		if next(altTasks) then
			tinsert(tempData, { source = "alts", tasks = altTasks })
		end
		if next(auctions) then
			tinsert(tempData, { source = "auction", tasks = auctions })
		end
	end

	-- store the selected sources and create availableMats
	TSMCore.db.factionrealm.internalData.gathering.selectedSources = tempData
	TSMCore.db.factionrealm.internalData.gathering.availableMats = {}
	local availableMats = {}

	for _, data in pairs(tempData) do
		local headerText, rowText, subRowText
		local leader = "    "
		local leader2 = "        "
		local color = ""
		if data.source == "alts" then
			for charName, tasks in pairs(data.tasks) do
				color = ""
				availableMats[charName] = availableMats[charName] or {}
				local headerAdded = false
				for location, items in pairs(tasks) do
					availableMats[charName][location] = availableMats[charName][location] or {}
					local locationText
					if location == "bank" then
						locationText = L["Visit Bank"]
					elseif location == "gVault" then
						locationText = L["Visit Guild Vault"]
					elseif location == "mail" then
						locationText = L["Visit Mailbox"]
					else
						locationText = L["Mail To "] .. crafter
					end
					local rowAdded = false
					for item, quantity in pairs(items) do
						local rowQty = min(quantity, (location ~= "bags" and (shortItems[item] or quantity) - TSMAPI.Inventory:GetBagQuantity(item, charName)) or quantity)
						if rowQty > 0 then
							if not headerAdded then
								headerText = format(" %s|r", color .. L["Mail From "] .. charName)
								tinsert(stData2, { cols = { { value = headerText } }, isTitle = true, name = charName })
								headerAdded = true
							end
							if not rowAdded then
								if private.currentSource == charName and private.currentTask == location then
									color = "|cff00ff00"
								elseif private.currentSource == charName and private.currentTask == "mail" and location == "bags" then
									color = "|cff00ff00"
								else
									color = ""
								end
								rowText = format(" %s|r", color .. leader .. locationText)
								tinsert(stData2, { cols = { { value = rowText } }, location = location, sourceName = data.source })
								rowAdded = true
							end
							availableMats[charName][location][item] = rowQty
							local itemName = TSMAPI.Item:GetName(item)
							subRowText = format("%s x %s|r", color .. leader2 .. itemName, color .. rowQty)
							tinsert(stData2, { cols = { { value = subRowText } }, itemString = item, quantity = rowQty, sourceName = data.source })
						end
					end
				end
			end
		elseif data.source == "crafter" then
			color = ""
			availableMats[crafter] = availableMats[crafter] or {}
			headerText = format(" %s|r", L["From "] .. crafter)
			tinsert(stData2, { cols = { { value = headerText } }, isTitle = true, name = crafter })
			for location, items in pairs(data.tasks) do
				availableMats[crafter][location] = availableMats[crafter][location] or {}
				local locationText
				if location == "bank" then
					locationText = L["Visit Bank"]
				elseif location == "gVault" then
					locationText = L["Visit Guild Vault"]
				elseif location == "mail" then
					locationText = L["Visit Mailbox"]
				end
				if private.currentSource == crafter and private.currentTask == location then
					color = "|cff00ff00"
				else
					color = ""
				end
				rowText = format(" %s|r", color .. leader .. locationText)
				tinsert(stData2, { cols = { { value = rowText } }, location = location, sourceName = data.source })
				for item, quantity in pairs(items) do
					availableMats[crafter][location][item] = quantity
					local itemName = TSMAPI.Item:GetName(item)
					subRowText = format("%s x %s|r", color .. leader2 .. itemName, color .. quantity)
					tinsert(stData2, { cols = { { value = subRowText } }, itemString = item, quantity = quantity, sourceName = data.source })
				end
			end
		elseif data.source == "vendor" or data.source == "vendorT" then
			color = ""
			availableMats["vendor"] = availableMats["vendor"] or {}
			availableMats["vendor"]["buy"] = availableMats["vendor"]["buy"] or {}
			if data.source == "vendor" then
				headerText = format(" %s|r", color .. L["Vendor"])
			else
				headerText = format(" %s|r", color .. L["Vendor Trade"])
			end
			tinsert(stData2, { cols = { { value = headerText } }, isTitle = true, sourceName = data.source })
			for item, quantity in pairs(data.tasks) do
				availableMats["vendor"]["buy"][item] = quantity
				local itemName = TSMAPI.Item:GetName(item)
				rowText = format("%s x %s|r", color .. leader .. itemName, color .. quantity)
				tinsert(stData2, { cols = { { value = rowText } }, itemString = item, quantity = quantity, sourceName = data.source })
			end
		elseif data.source == "crafting" then
			headerText = format(" %s|r", color .. L["Intermediate Craft"])
			tinsert(stData2, { cols = { { value = headerText } }, isTitle = true, sourceName = data.source })
			availableMats["crafting"] = availableMats["crafting"] or {}
			for spellID, items in pairs(data.tasks) do
				color = ""
				local spellData = TSMCore.db.factionrealm.internalData.crafts[spellID]
				for item, quantity in pairs(items) do
					availableMats["crafting"][spellData.profession] = availableMats["crafting"][spellData.profession] or {}
					local spellName = spellData.name .. (spellData.hasCD and L[" (CD)"] or "")
					local spellQuantity = ceil(quantity / spellData.numResult)
					availableMats["crafting"][spellData.profession][spellID] = spellQuantity
					rowText = format("%s x %s|r", color .. leader .. spellName, color .. spellQuantity)
					tinsert(stData2, { cols = { { value = rowText } }, spellID = spellID, profession = spellData.profession, itemString = item, quantity = spellQuantity, sourceName = data.source })
				end
			end
		elseif data.source == "convert" then
			color = ""
			availableMats[data.source] = availableMats[data.source] or {}
			headerText = format(" %s|r", color .. L["Conversions"])
			tinsert(stData2, { cols = { { value = headerText } }, isTitle = true, name = data.source })
			for method, items in pairs(data.tasks) do
				availableMats[data.source][method] = availableMats[data.source][method] or {}
				local methodText
				if method == "transform" then
					methodText = L["Transform"]
				elseif method == "prospect" then
					methodText = L["Prospect"]
				else
					methodText = L["Convert"]
				end
				rowText = format(" %s|r", color .. leader .. methodText)
				tinsert(stData2, { cols = { { value = rowText } }, location = method, sourceName = data.source })
				for item, quantity in pairs(items) do
					availableMats[data.source][method][item] = quantity
					local itemName = TSMAPI.Item:GetName(item)
					subRowText = format("%s x %s|r", color .. leader2 .. itemName, color .. quantity)
					tinsert(stData2, { cols = { { value = subRowText } }, itemString = item, quantity = quantity, sourceName = data.source })
				end
			end
		else
			local color = ""
			availableMats[data.source] = availableMats[data.source] or {}
			availableMats[data.source]["buy"] = availableMats[data.source]["buy"] or {}
			local headerAdded = false
			for item, quantity in pairs(data.tasks) do
				local auctionQty = (shortItems[item] or 0) - private:GetAuctionQty(availableMats, item)
				if auctionQty > 0 then
					if not headerAdded then
						headerText = format("%s|r", color .. L["Auction House"])
						tinsert(stData2, { cols = { { value = headerText } }, isTitle = true, sourceName = data.source })
						headerAdded = true
					end
					availableMats[data.source]["buy"][item] = auctionQty
					local itemName = TSMAPI.Item:GetName(item)
					rowText = format("%s x %s|r", color .. leader .. itemName, color .. auctionQty)
					tinsert(stData2, { cols = { { value = rowText } }, itemString = item, quantity = auctionQty, sourceName = data.source })
				end
			end
		end
	end

	private.gatheringFrame.mainFrame.sourceST:SetData(stData2)

	-- populate intermediate crafts selection frame
	local stData3 = {}
	local headerText, rowText
	local leader = "    "
	for itemString, quantity in pairs(neededMats) do
		local color = "|cffff0000"
		local crafterQty = TSMAPI.Inventory:GetBagQuantity(itemString, crafter) + TSMAPI.Inventory:GetBankQuantity(itemString, crafter) + TSMAPI.Inventory:GetReagentBankQuantity(itemString, crafter) + TSMAPI.Inventory:GetMailQuantity(itemString, crafter)
		local need = max(quantity - crafterQty, 0)

		if crafterQty < quantity then
			for item, source in pairs(sources) do
				if item == itemString then
					local itemName = TSMAPI.Item:GetName(itemString)
					for sourceName, data in pairs(source) do
						if sourceName == "crafting" then
							for spellID, taskQuantity in pairs(data) do
								local spellData = TSMCore.db.factionrealm.internalData.crafts[spellID]
								local spellQuantity = ceil(need / spellData.numResult)
								headerText = format("%s|r", itemName .. " (" .. need .. ")")
								if TSMCore.db.factionrealm.internalData.gathering.selectedSourceStatus[spellID] then color = "|cff00ff00" end
								rowText = format("%s|r", color .. leader .. GetSpellInfo(spellID) .. " x " .. spellQuantity)
								tinsert(stData3, { cols = { { value = headerText } }, isTitle = true, itemString = itemString, name = itemName, sourceName = sourceName, quantity = need })
								tinsert(stData3, { cols = { { value = rowText } }, isTitle = false, spellID = spellID, spellQty = spellQuantity, itemString = itemString, name = itemName, sourceName = sourceName, quantity = need })
							end
						end
					end
				end
			end
		end
	end

	private.gatheringFrame.interFrame.interSelST:SetData(stData3)

	-- populate intermediate crafts craftable frame
	local stData4 = {}
	local headerText, rowText
	local leader = "    "
	if availableMats and availableMats["crafting"] then
		for profession, spells in pairs(availableMats["crafting"]) do
			local headerAdded = false
			for spellID, spellQuantity in pairs(spells) do
				local craft = TSMCore.db.factionrealm.internalData.crafts[spellID]
				local name = craft and craft.name
				-- figure out how many we can craft with mats in our bags
				local numCanCraft = math.huge
				for itemString, quantity in pairs(craft.mats) do
					local bagQuantity = TSMAPI_FOUR.Inventory.GetBagQuantity(itemString) + TSMAPI_FOUR.Inventory.GetReagentBankQuantity(itemString)
					numCanCraft = min(numCanCraft, floor((bagQuantity or 0) / quantity))
				end
				numCanCraft = min(spellQuantity, floor(numCanCraft / craft.numResult))
				if numCanCraft > 0 and TSMCore.db.factionrealm.internalData.gathering.selectedSourceStatus[spellID] then
					if not headerAdded then
						headerText = format(" %s|r", profession)
						tinsert(stData4, { cols = { { value = headerText } }, isTitle = true, name = profession, sourceName = profession })
						headerAdded = true
					end
					rowText = format("%s x %s|r", leader .. name, numCanCraft)
					tinsert(stData4, { cols = { { value = rowText } }, name = profession, itemName = name, quantity = numCanCraft, sourceName = profession })
				end
			end
		end
	end

	sort(stData4, private.SortSources)
	private.gatheringFrame.interFrame.interCraftST:SetData(stData4)

	-- update available mats if at a valid source
	if private.currentSource and private.currentTask then
		if private.currentSource ~= crafter and private.currentTask == "mail" and availableMats[private.currentSource] and availableMats[private.currentSource]["bags"] then
			TSMCore.db.factionrealm.internalData.gathering.availableMats = availableMats[private.currentSource]["bags"]
		elseif private.currentSource == "crafting" and availableMats["crafting"] and availableMats["crafting"][TSM:GetCurrentProfessionName()] then
			local craftingMats = {}
			for _, spellID in ipairs(C_TradeSkillUI.GetFilteredRecipeIDs()) do
				if availableMats["crafting"][TSM:GetCurrentProfessionName()][spellID] then
					local craft = TSMCore.db.factionrealm.internalData.crafts[spellID]
					-- figure out how many we can craft with mats in our bags
					local numCanCraft = math.huge
					for itemString, quantity in pairs(craft.mats) do
						local bagQuantity = TSMAPI_FOUR.Inventory.GetBagQuantity(itemString) + TSMAPI_FOUR.Inventory.GetReagentBankQuantity(itemString)
						numCanCraft = min(numCanCraft, floor((bagQuantity or 0) / quantity))
					end
					if numCanCraft > 0 and TSMCore.db.factionrealm.internalData.gathering.selectedSourceStatus[spellID] then
						craftingMats[spellID] = availableMats[private.currentSource][TSM:GetCurrentProfessionName()][spellID]
					end
				end
			end
			if next(craftingMats) then
				TSMCore.db.factionrealm.internalData.gathering.availableMats = craftingMats
			end
		elseif availableMats[private.currentSource] and availableMats[private.currentSource][private.currentTask] then
			TSMCore.db.factionrealm.internalData.gathering.availableMats = availableMats[private.currentSource][private.currentTask]
		end
	end

	private.gatheringFrame.mainFrame.buttonsFrame.gatherItemsBtn:SetText(L["Gather Items"])
	if next(TSMCore.db.factionrealm.internalData.gathering.availableMats) then
		private.gatheringFrame.mainFrame.buttonsFrame.gatherItemsBtn:Enable()
		if private.currentSource == "vendor" then
			private.gatheringFrame.mainFrame.buttonsFrame.gatherItemsBtn:SetText(L["Buy Vendor Items"])
		elseif private.currentSource ~= crafter and private.currentTask == "mail" then
			private.gatheringFrame.mainFrame.buttonsFrame.gatherItemsBtn:SetText(L["Mail Items"])
		elseif private.currentTask == "buy" then
			private.gatheringFrame.mainFrame.buttonsFrame.gatherItemsBtn:SetText(L["Buy Items"])
		elseif private.currentSource == "crafting" then
			private.gatheringFrame.interFrame.interBtnFrame.craftNextBtn:Enable()
		elseif private.currentSource == "bags" and private.currentTask == "transform" then
			private.gatheringFrame.mainFrame.buttonsFrame.gatherItemsBtn:SetText(L["Transform Next"])
		end
	else
		private.gatheringFrame.mainFrame.buttonsFrame.gatherItemsBtn:Disable()
		private.gatheringFrame.interFrame.interBtnFrame.craftNextBtn:Disable()
	end
end

function private.EventHandler(event)
	if not private.gatheringFrame then return end

	if event == "GUILDBANKFRAME_OPENED" then
		private.currentSource = UnitName("player")
		private.currentTask = "gVault"
	elseif event == "GUILDBANKFRAME_CLOSED" then
		private.currentSource = nil
		private.currentTask = nil
		private.gatheringFrame.mainFrame.buttonsFrame.gatherItemsBtn:Disable()
	elseif event == "BANKFRAME_OPENED" then
		private.currentSource = UnitName("player")
		private.currentTask = "bank"
	elseif event == "BANKFRAME_CLOSED" then
		private.currentSource = nil
		private.currentTask = nil
		private.gatheringFrame.mainFrame.buttonsFrame.gatherItemsBtn:Disable()
	elseif event == "MERCHANT_SHOW" then
		private.currentSource = "vendor"
		private.currentTask = "buy"
	elseif event == "MERCHANT_CLOSED" then
		private.currentSource = nil
		private.currentTask = nil
		private.gatheringFrame.mainFrame.buttonsFrame.gatherItemsBtn:Disable()
	elseif event == "MAIL_SHOW" then
		private.currentSource = UnitName("player")
		private.currentTask = "mail"
	elseif event == "MAIL_CLOSED" then
		private.currentSource = nil
		private.currentTask = nil
		private.gatheringFrame.mainFrame.buttonsFrame.gatherItemsBtn:Disable()
	elseif event == "AUCTION_HOUSE_SHOW" then
		TSM.Gather.gatherQuantity = nil
		TSM.Gather.gatherItem = nil
		private.currentSource = "auction"
		private.currentTask = "buy"
	elseif event == "AUCTION_HOUSE_CLOSED" then
		TSM.Gather.gatherQuantity = nil
		TSM.Gather.gatherItem = nil
		private.currentSource = nil
		private.currentTask = nil
		private.gatheringFrame.mainFrame.buttonsFrame.gatherItemsBtn:Disable()
	elseif event == "TRADE_SKILL_SHOW" then
		private.currentSource = "crafting"
		private.currentTask = "craft"
	elseif event == "TRADE_SKILL_CLOSE" then
		private.currentSource = nil
		private.currentTask = nil
		private.gatheringFrame.mainFrame.buttonsFrame.gatherItemsBtn:Disable()
	elseif event == "BAG_UPDATE" then
		if not private.currentSource then
			if private:canTransform() then
				private.currentSource = "bags"
				private.currentTask = "transform"
			end
		end
	end
	TSMAPI.Delay:AfterTime("gatheringUpdateThrottle", 0.2, Gather.Update)
end

function private.SortSources(a, b)
	if a.name == b.name then
		if a.sourceName == b.sourceName then
			if a.isTitle and b.isTitle then
				return false
			end
			if a.isSubTitle and b.isSubTitle then
				return false
			end
			if a.isSubRow and b.IsSubRow then
				return false
			end
			if a.isTitle then return true end
			if b.isTitle then return false end
			if a.isSubTitle then return true end
			if b.isSubTitle then return false end
		end
		if a.isTitle and b.isTitle then
			return false
		end
		if a.isSubTitle and b.isSubTitle then
			return false
		end
		if a.isTitle then return true end
		if b.isTitle then return false end
		return a.sourceName < b.sourceName
	end

	return a.name < b.name
end
