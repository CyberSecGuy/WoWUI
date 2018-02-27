-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- This file contains function for the bank/gbank frame

-- load the parent file (TSM) into a local variable and register this file as a module
local _, TSM = ...
local BankUI = TSM:NewModule("BankUI")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = {registeredModules={}, bankUiButtons={}, bankType=nil, ui = nil, bankFrame = nil, bFrame = nil, opened = true}

function BankUI.OnEnable()
	TSMAPI_FOUR.Event.Register("GUILDBANKFRAME_OPENED", function()
		private.bankType = "guild"
		TSMAPI.Delay:AfterTime(0.1, function()
			private.bankFrame = BankUI:getBankFrame("guildbank")
			if private.opened then
				if #private.bankUiButtons > 0 then
					if private.ui then
						BankUI:resetPoints(private.ui)
						private.ui:Show()
						if TSM.db.global.coreOptions.bankUITab then
							for index, info in ipairs(private.bankUiButtons) do
								if info.moduleName == TSM.db.global.coreOptions.bankUITab then
									private.ui.buttons[index]:Click()
									break
								end
							end
						else
							private.ui.buttons[1]:Click()
						end
						return
					end
					private.ui = BankUI:getFrame(private.bankFrame)
				end
			end
		end)
	end)

	TSMAPI_FOUR.Event.Register("BANKFRAME_OPENED", function()
		private.bankType = "bank"
		TSMAPI.Delay:AfterTime(0.1, function()
			private.bankFrame = BankUI:getBankFrame("bank")
			if private.opened then
				if #private.bankUiButtons > 0 then
					if private.ui then
						BankUI:resetPoints(private.ui)
						private.ui:Show()
						if TSM.db.global.coreOptions.bankUITab then
							for index, info in ipairs(private.bankUiButtons) do
								if info.moduleName == TSM.db.global.coreOptions.bankUITab then
									private.ui.buttons[index]:Click()
									break
								end
							end
						else
							private.ui.buttons[1]:Click()
						end
						return
					end
					private.ui = BankUI:getFrame(private.bankFrame)
				end
			end
		end)
	end)

	TSMAPI_FOUR.Event.Register("GUILDBANKFRAME_CLOSED", function()
		if private.ui then private.ui:Hide() end
		private.bankType = nil
	end)

	TSMAPI_FOUR.Event.Register("BANKFRAME_CLOSED", function()
		if private.ui then private.ui:Hide() end
		private.bankType = nil
	end)
end

local function createCloseButton(text, parent, func)
	local btn = TSM.GUI:CreateButton(private.bFrame, 18, "Button")
	btn:SetText(text)
	btn:SetHeight(20)
	btn:SetWidth(20)
	return btn
end

function TSM:RegisterBankUiButton(moduleName, callback)
	if private.registeredModules[moduleName] then return end
	private.registeredModules[moduleName] = true
	local info = {}
	info.moduleName = moduleName
	info.callback = callback
	tinsert(private.bankUiButtons, info)
	sort(private.bankUiButtons, function(a, b)
		if a.moduleName == "Warehousing" then
			return true
		elseif b.moduleName == "Warehousing" then
			return false
		else
			return a.moduleName < b.moduleName
		end
	end)
end

function BankUI:getBankFrame(bank)
	if BagnonFrameguild and BagnonFrameguild:IsVisible() then
		return BagnonFrameguild
	elseif BagnonFramebank and BagnonFramebank:IsVisible() then
		return BagnonFramebank
	elseif GuildBankFrame and GuildBankFrame:IsVisible() then
		return GuildBankFrame
	elseif BankFrame and BankFrame:IsVisible() then
		return BankFrame
	elseif (famBankFrame and famBankFrame:IsVisible()) then
		return famBankFrame
	elseif (ARKINV_Frame4 and ARKINV_Frame4:IsVisible()) then
		return ARKINV_Frame4
	elseif (ARKINV_Frame3 and ARKINV_Frame3:IsVisible()) then
		return ARKINV_Frame3
	elseif (OneBankFrame and OneBankFrame:IsVisible()) then
		return OneBankFrame
	elseif (TukuiBank and TukuiBank:IsShown()) then
		return TukuiBank
	elseif (ElvUI_BankContainerFrame and ElvUI_BankContainerFrame:IsVisible()) then
		return ElvUI_BankContainerFrame
	elseif (LUIBank and LUIBank:IsVisible()) then
		return LUIBank
	elseif (AdiBagsContainer1 and AdiBagsContainer1.isBank and AdiBagsContainer1:IsVisible()) then
		return AdiBagsContainer1
	elseif (AdiBagsContainer2 and AdiBagsContainer2.isBank and AdiBagsContainer2:IsVisible()) then
		return AdiBagsContainer2
	elseif (BagsFrameBank and BagsFrameBank:IsVisible()) then
		return BagsFrameBank
	elseif AspUIBank and AspUIBank:IsVisible() then
		return AspUIBank
	elseif NivayacBniv_Bank and NivayacBniv_Bank:IsVisible() then
		return NivayacBniv_Bank
	elseif DufUIBank and DufUIBank:IsVisible() then
		return DufUIBank
	end

	return nil
end

function BankUI:getFrame(frameType)
	private.bFrame = CreateFrame("Frame", nil, UIParent)
	private.bFrame:Hide()
	--size--
	private.bFrame:SetWidth(305)
	private.bFrame:SetHeight(490)
	private.bFrame:SetPoint("CENTER", UIParent)

	--for moving--
	private.bFrame:SetScript("OnMouseDown", private.bFrame.StartMoving)
	private.bFrame:SetScript("OnMouseUp", function(...) private.bFrame.StopMovingOrSizing(...)
	if private.bankType == "guild" then
		TSM.db.profile.internalData.bankUIGBankFramePosition = { private.bFrame:GetLeft(), private.bFrame:GetBottom() }
	else
		TSM.db.profile.internalData.bankUIBankFramePosition = { private.bFrame:GetLeft(), private.bFrame:GetBottom() }
	end
	end)
	private.bFrame:SetMovable(true)
	private.bFrame:EnableMouse(true)

	private.bFrame:SetPoint("CENTER", UIParent)

	local function OnFrameShow(self)
		self:SetFrameLevel(0)
		self:ClearAllPoints()
		if private.bankType == "guild" then
			self:SetPoint("BOTTOMLEFT", UIParent, unpack(TSM.db.profile.internalData.bankUIGBankFramePosition))
		else
			self:SetPoint("BOTTOMLEFT", UIParent, unpack(TSM.db.profile.internalData.bankUIBankFramePosition))
		end
	end

	TSMAPI.Design:SetFrameBackdropColor(private.bFrame)
	private.bFrame:SetScript("OnShow", OnFrameShow)
	private.bFrame:Show()

	local title = TSM.GUI:CreateLabel(private.bFrame)
	title:SetPoint("TOPLEFT", 25, -13)
	title:SetPoint("BOTTOMRIGHT", private.bFrame, "TOPRIGHT", -5, -33)
	title:SetJustifyH("CENTER")
	title:SetJustifyV("CENTER")
	title:SetText("TradeSkillMaster - " .. TSM:GetVersion())
	TSMAPI.Design:SetTitleTextColor(title)

	local title2 = TSM.GUI:CreateLabel(private.bFrame)
	title2:SetPoint("TOPLEFT", title, "BOTTOMLEFT")
	title2:SetPoint("TOPRIGHT", title, "BOTTOMRIGHT")
	title2:SetJustifyH("CENTER")
	title2:SetJustifyV("CENTER")
	title2:SetText(L["BankUI"])
	TSMAPI.Design:SetTitleTextColor(title2)


	private.bFrame.btnClose = createCloseButton("X", private.bFrame, nil)
	private.bFrame.btnClose:SetPoint("TOPRIGHT", private.bFrame, "TOPRIGHT")
	private.bFrame.btnClose:SetScript("OnClick", function(self)
		if private.bFrame then private.bFrame:Hide() end
		private.opened = false
		TSM:Print(L["You have closed the bankui. Use '/tsm bankui' to view again."])
	end)

	-- module buttons
	private.bFrame.buttons = {}

	local iconFrame = CreateFrame("Frame", nil, private.bFrame)
	iconFrame:SetPoint("CENTER", private.bFrame, "TOPLEFT", 20, -20)
	iconFrame:SetHeight(70)
	iconFrame:SetWidth(70)
	local icon = iconFrame:CreateTexture(nil, "ARTWORK")
	icon:SetAllPoints()
	icon:SetTexture("Interface\\Addons\\TradeSkillMaster\\Media\\TSM_Icon_Big")
	local ag = iconFrame:CreateAnimationGroup()
	local spin = ag:CreateAnimation("Rotation")
	spin:SetOrder(1)
	spin:SetDuration(2)
	spin:SetDegrees(90)
	local spin = ag:CreateAnimation("Rotation")
	spin:SetOrder(2)
	spin:SetDuration(4)
	spin:SetDegrees(-180)
	local spin = ag:CreateAnimation("Rotation")
	spin:SetOrder(3)
	spin:SetDuration(2)
	spin:SetDegrees(90)
	ag:SetLooping("REPEAT")
	iconFrame:SetScript("OnEnter", function() ag:Play() end)
	iconFrame:SetScript("OnLeave", function() ag:Stop() end)

	local container = CreateFrame("Frame", nil, private.bFrame)
	container:SetPoint("TOPLEFT", 5, -80)
	container:SetPoint("BOTTOMRIGHT", -5, 5)
	TSMAPI.Design:SetFrameColor(container)

	for _, info in ipairs(private.bankUiButtons) do
		info.bankTab = info.callback(container)
		private:CreateBankButton(info.moduleName)
	end

	if TSM.db.global.coreOptions.bankUITab then
		for index, info in ipairs(private.bankUiButtons) do
			if info.moduleName == TSM.db.global.coreOptions.bankUITab then
				private.bFrame.buttons[index]:Click()
				break
			end
		end
	else
		private.bFrame.buttons[1]:Click()
	end
	return private.bFrame
end

function BankUI:resetPoints(container)
	if private.bankType == "guild" then
		container:SetPoint("BOTTOMLEFT", UIParent, unpack(TSM.db.profile.internalData.bankUIGBankFramePosition))
	else
		container:SetPoint("BOTTOMLEFT", UIParent, unpack(TSM.db.profile.internalData.bankUIBankFramePosition))
	end
end

function private:CreateBankButton(module)
	local buttonIndex
	local buttonCount = 0
	for record, info in ipairs(private.bankUiButtons) do
		if info.moduleName == module then
			buttonIndex = record
		end
		buttonCount = buttonCount + 1
	end

	local function OnButtonClick(self)
		for _, info in ipairs(private.bankUiButtons) do
			info.bankTab:Hide()
		end

		for index, button in ipairs(private.bFrame.buttons) do
			button:UnlockHighlight()
			if self == button then
				private.bankUiButtons[index].bankTab:Show()
			end
		end
		self:LockHighlight()
	end
	local buttonWidth = (buttonCount * 70) + ((buttonCount - 1)*5)
	local offset = (305 - buttonWidth ) / 2

	local button = TSM.GUI:CreateButton(private.bFrame, 12)
	if buttonIndex == 1 then
		button:SetPoint("TOPLEFT", offset, -60)
	else
		button:SetPoint("TOPLEFT", private.bFrame.buttons[buttonIndex - 1], "TOPRIGHT", 5, 0)
	end
	button:SetHeight(20)
	button:SetWidth(70)
	button:SetText(module)
	button:SetScript("OnClick", OnButtonClick)
	tinsert(private.bFrame.buttons, button)
end

function TSM:toggleBankUI()
	if TSM:areBanksVisible() then
		if private.ui then
			if private.ui:IsShown() then
				private.ui:Hide()
			else
				private.ui:Show()
				private.opened = true
			end
		else
			private.ui = BankUI:getFrame(private.bankFrame)
			private.opened = true
		end
	else
		TSM:Print(L["There are no visible banks."])
	end
end

function TSM:getBankTabs()
	local tabs = {}
	for record, info in ipairs(private.bankUiButtons) do
		tabs[info.moduleName] = info.moduleName
	end
	return tabs
end

function TSM:ResetBankUIFramePosition()
	TSM.db.profile.internalData.bankUIGBankFramePosition = { 100, 300 }
	TSM.db.profile.internalData.bankUIBankFramePosition = { 100, 300 }
	if private.ui then
		private.ui:Hide()
		private.ui:Show()
	end
end
