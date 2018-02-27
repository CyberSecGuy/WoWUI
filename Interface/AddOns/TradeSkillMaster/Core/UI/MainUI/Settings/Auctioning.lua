-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local Auctioning = TSM.MainUI.Settings:NewPackage("Auctioning")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = { sounds = {} }



-- ============================================================================
-- Module Functions
-- ============================================================================

function Auctioning.OnInitialize()
	TSM.MainUI.Settings.RegisterSettingPage("Auctioning", "middle", private.GetAuctioningSettingsFrame)
	for _, name in pairs(TSMAPI_FOUR.Sound.GetSounds()) do
		tinsert(private.sounds, name)
	end
end



-- ============================================================================
-- Auctioning Settings UI
-- ============================================================================

function private.GetAuctioningSettingsFrame()
	return TSMAPI_FOUR.UI.NewElement("ScrollFrame", "auctioningSettings")
		:SetStyle("padding", 10)
		:AddChild(TSM.MainUI.Settings.CreateHeadingLine("generalOptionsTitle", L["General Options"]))
		:AddChild(TSM.MainUI.Settings.CreateSettingLine("cancelAuctionBidsFrame", L["Cancel auctions with bids?"])
			:AddChild(TSMAPI_FOUR.UI.NewElement("Toggle", "cancelAuctionsBidsToggle")
				:SetStyle("width", 80)
				:SetStyle("height", 20)
				:SetBooleanToggle(TSM.db.global.auctioningOptions, "cancelWithBid")
			)
		)
		:AddChild(TSM.MainUI.Settings.CreateSettingLine("roundNormalPriceFrame", L["Round normal price?"])
			:AddChild(TSMAPI_FOUR.UI.NewElement("Toggle", "roundNormalPriceToggle")
				:SetStyle("width", 80)
				:SetStyle("height", 20)
				:SetBooleanToggle(TSM.db.global.auctioningOptions, "roundNormalPrice")
			)
		)
		:AddChild(TSM.MainUI.Settings.CreateSettingLine("disableInvalidWarningsFrame", L["Disable invalid price warnings?"])
			:AddChild(TSMAPI_FOUR.UI.NewElement("Toggle", "disableInvalidWarningsToggle")
				:SetStyle("width", 80)
				:SetStyle("height", 20)
				:SetBooleanToggle(TSM.db.global.auctioningOptions, "disableInvalidMsg")
			)
		)
		:AddChild(TSM.MainUI.Settings.CreateHeadingLine("ahFrameOptionsTitle", L["Auction House Frame Options"]))
		:AddChild(TSM.MainUI.Settings.CreateSettingLine("scanCompleteSoundFrame", L["Scan complete sound:"])
			:AddChild(TSMAPI_FOUR.UI.NewElement("Dropdown", "scanCompleteSoundDropdown")
				:SetItems(private.sounds, TSMAPI_FOUR.Sound.GetSounds()[TSM.db.global.auctioningOptions.scanCompleteSound])
				:SetScript("OnSelectionChanged", private.ScanCompleteSoundOnSelectionChanged)
			)
		)
		:AddChild(TSM.MainUI.Settings.CreateSettingLine("confirmCompleteSoundFrame", L["Confirm complete sound:"])
			:AddChild(TSMAPI_FOUR.UI.NewElement("Dropdown", "confirmCompleteSoundDropdown")
				:SetItems(private.sounds, TSMAPI_FOUR.Sound.GetSounds()[TSM.db.global.auctioningOptions.confirmCompleteSound])
				:SetScript("OnSelectionChanged", private.ConfirmCompleteSoundOnSelectionChanged)
			)
		)
		:AddChild(TSM.MainUI.Settings.CreateHeadingLine("whitelistTitle", L["Whitelist"]))
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "whitelistHelpFrame")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 70)
			:SetStyle("margin", { bottom = 16 })
			:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
				:SetStyle("textColor", "#e2e2e2")
				:SetStyle("fontHeight", 16)
				:SetText(L["Whitelists allow you to set other players besides yourself that you do not want to undercut; however, if somebody on your whitelist matches your buyout but lists a lower bid, it will still consider them undercutting"])
			)
		)
		:AddChild(TSM.MainUI.Settings.CreateSettingLine("matchWhitelistPlayersFrame", L["Match whitelisted players?"])
			:AddChild(TSMAPI_FOUR.UI.NewElement("Toggle", "matchWhitelistPlayersToggle")
				:SetStyle("width", 80)
				:SetStyle("height", 20)
				:SetBooleanToggle(TSM.db.global.auctioningOptions, "matchWhitelist")
			)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "whitelistedPlayersFrame")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 26)
			:SetStyle("margin", { bottom = 16 })
			:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "label")
				:SetStyle("textColor", "#e2e2e2")
				:SetStyle("fontHeight", 18)
				:SetText(L["Whitelisted players:"])
			)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "whitelistPlayersInputFrame")
			:SetLayout("HORIZONTAL")
			:SetStyle("height", 26)
			:SetStyle("margin", { bottom = 16 })
			:AddChild(TSMAPI_FOUR.UI.NewElement("Input", "nameInput")
				:SetStyle("margin", { right = 10 })
			)
			:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "addBtn")
				:SetStyle("width", 100)
				:SetStyle("height", 20)
				:SetStyle("fontHeight", 16)
				:SetStyle("borderTexture", "Interface\\Addons\\TradeSkillMaster\\Media\\ButtonEdgeFrame.blp")
				:SetStyle("borderSize", 3)
				:SetText("Add Player")
				:SetScript("OnClick", private.AddWhitelistOnClick)
			)
		)
		:AddChildrenWithFunction(private.AddWhitelistRows)
end

function private.AddWhitelistRows(frame)
	for player in pairs(TSM.db.factionrealm.auctioningOptions.whitelist) do
		private.AddWhitelistRow(frame, player)
	end
end

function private.AddWhitelistRow(frame, player)
	frame:AddChild(TSMAPI_FOUR.UI.NewElement("Frame", "whitelist_"..player)
		:SetLayout("HORIZONTAL")
		:SetStyle("height", 24)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Button", "removeBtn")
			:SetStyle("borderTexture", "Interface\\Addons\\TradeSkillMaster\\Media\\ButtonEdgeFrame.blp")
			:SetStyle("borderSize", 7)
			:SetStyle("width", 120)
			:SetContext(player)
			:SetText(REMOVE)
			:SetScript("OnClick", private.RemoveWhitelistOnClick)
		)
		:AddChild(TSMAPI_FOUR.UI.NewElement("Text", "playerName")
			:SetText(player)
		)
	)
end



-- ============================================================================
-- Local Script Handlers
-- ============================================================================

function private.ScanCompleteSoundOnSelectionChanged(self, selection)
	local key = nil
	for k, v in pairs(TSMAPI_FOUR.Sound.GetSounds()) do
		if v == selection then
			key = k
			break
		end
	end
	assert(key)
	TSM.db.global.auctioningOptions.scanCompleteSound = key
end

function private.ConfirmCompleteSoundOnSelectionChanged(self, selection)
	local key = nil
	for k, v in pairs(TSMAPI_FOUR.Sound.GetSounds()) do
		if v == selection then
			key = k
			break
		end
	end
	assert(key)
	TSM.db.global.auctioningOptions.confirmCompleteSound = key
end

function private.AddWhitelistOnClick(self)
	local newPlayer = strlower(strtrim(self:GetElement("__parent.nameInput"):GetText()))
	if newPlayer == "" or strfind(newPlayer, ",") or newPlayer ~= TSMAPI_FOUR.Util.StrEscape(newPlayer) then
		TSM:Printf(L["Invalid player name."])
		return
	elseif TSM.db.factionrealm.auctioningOptions.whitelist[newPlayer] then
		TSM:Printf(L["The player \"%s\" is already on your whitelist."], TSM.db.factionrealm.auctioningOptions.whitelist[newPlayer])
		return
	end

	for player in pairs(TSM.old.Auctioning.db.factionrealm.player) do
		if strlower(player) == newPlayer then
			TSM:Printf(L["You do not need to add \"%s\", alts are whitelisted automatically."], player)
			return
		end
	end

	TSM.db.factionrealm.auctioningOptions.whitelist[newPlayer] = newPlayer

	-- add a new row to the UI
	local frame = self:GetParentElement():GetParentElement()
	private.AddWhitelistRow(frame, newPlayer)
	frame:Draw()
end

function private.RemoveWhitelistOnClick(self)
	local player = self:GetContext()
	TSM.db.factionrealm.auctioningOptions.whitelist[player] = nil

	-- remove this row
	local row = self:GetParentElement()
	local frame = row:GetParentElement()
	frame:RemoveChild(row)
	row:Release()
	frame:Draw()
end
