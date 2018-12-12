AAP = {}
AAP.Name = UnitName("player")
AAP.Realm = string.gsub(GetRealmName(), " ", "")
AAP.Faction = UnitFactionGroup("player")
AAP.Level = UnitLevel("player")
AAP.Class = {}
AAP.Heirlooms = 0
AAP.RaceLocale, AAP.Race = UnitRace("player")
AAP.Class[1],AAP.Class[2],AAP.Class[3] = UnitClass("player")
AAP.QuestList = {}
AAP.NPCList = {}
AAP.Icons = {}
AAP.ActiveQuests = {}
AAP.Version = tonumber(GetAddOnMetadata("Azeroth Auto Pilot", "Version"))
local CoreLoadin = 0
AAP.AfkTimerVar = 0
AAP.QuestListLoadin = 0
AAP.BookingList = {}
AAP.SettingsOpen = 0
AAP.InCombat = 0
AAP.BookUpdAfterCombat = 0
AAP.QuestListShown = 0
AAP.Dinged60 = 0
AAP.Dinged60nr = 0
AAP.Dinged80 = 0
AAP.Dinged80nr = 0
AAP.Dinged90 = 0
AAP.Dinged90nr = 0
AAP.ArrowActive = 0
AAP.ArrowActive_X = 0
AAP.ArrowActive_Y = 0
AAP.MiniMap_X = 0
AAP.MiniMap_Y = 0
BINDING_HEADER_AzerothAutoPilot = "Azeroth Auto Pilot"
BINDING_NAME_AAP_MACRO = "Quest Item 1"
AAP.AfkFrame = CreateFrame("frame", "AAP_AfkFrames", UIParent)
AAP.AfkFrame:SetWidth(120)
AAP.AfkFrame:SetHeight(40)
AAP.AfkFrame:SetPoint("CENTER", UIParent, "CENTER",0,150)
AAP.AfkFrame:EnableMouse(true)
AAP.AfkFrame:SetMovable(true)
AAP.AfkFrame:SetBackdrop( { 
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 10, edgeSize = 10, insets = { left = 2, right = 2, top = 2, bottom = 2 }
});
AAP.AfkFrame:SetScript("OnMouseDown", function(self, button)
	if button == "LeftButton" then
		AAP.AfkFrame:StartMoving();
		AAP.AfkFrame.isMoving = true;
	end
end)
AAP.AfkFrame:SetScript("OnMouseUp", function(self, button)
	if button == "LeftButton" and AAP.AfkFrame.isMoving then
		AAP.AfkFrame:StopMovingOrSizing();
		AAP.AfkFrame.isMoving = false;
	end
end)
AAP.AfkFrame:SetScript("OnHide", function(self)
	if ( AAP.AfkFrame.isMoving ) then
		AAP.AfkFrame:StopMovingOrSizing();
		AAP.AfkFrame.isMoving = false;
	end
end)
AAP.AfkFrame.Fontstring = AAP.AfkFrame:CreateFontString("AAPAFkFont","ARTWORK", "ChatFontNormal")
AAP.AfkFrame.Fontstring:SetParent(AAP.AfkFrame)
AAP.AfkFrame.Fontstring:SetPoint("LEFT", AAP.AfkFrame, "LEFT", 10, 0)
AAP.AfkFrame.Fontstring:SetFontObject("GameFontNormalLarge")
AAP.AfkFrame.Fontstring:SetText("AFK:")
AAP.AfkFrame.Fontstring:SetJustifyH("LEFT")
AAP.AfkFrame.Fontstring:SetTextColor(1, 1, 0)
AAP.AfkFrame:Hide()
local PlayMovie_hook = MovieFrame_PlayMovie

MovieFrame_PlayMovie = function(...)

	if (IsControlKeyDown() or (AAP1[AAP.Realm][AAP.Name]["Settings"]["CutScene"] == 0)) then

		PlayMovie_hook(...)

	else
		print("AAP: "..AAP_Locals["Skipped cutscene"])
		GameMovieFinished()

	end

end
function AAP.AFK_Timer(AAP_AFkTimeh)
	AAP.AfkTimerVar = AAP_AFkTimeh
	AAP.ArrowEventAFkTimer:Play()
end

function AAP.ResetSettings()
	AAP1[AAP.Realm][AAP.Name]["Settings"] = {}
	AAP1[AAP.Realm][AAP.Name]["Settings"]["left"] = 150
	AAP1[AAP.Realm][AAP.Name]["Settings"]["top"] = -150
	AAP1[AAP.Realm][AAP.Name]["Settings"]["Scale"] = UIParent:GetScale()
	AAP1[AAP.Realm][AAP.Name]["Settings"]["Lock"] = 0
	AAP1[AAP.Realm][AAP.Name]["Settings"]["Hide"] = 0
	AAP1[AAP.Realm][AAP.Name]["Settings"]["alpha"] = 1
	AAP1[AAP.Realm][AAP.Name]["Settings"]["arrowleft"] = 150
	AAP1[AAP.Realm][AAP.Name]["Settings"]["arrowtop"] = -150
	AAP1[AAP.Realm][AAP.Name]["Settings"]["Hcampleft"] = 150
	AAP1[AAP.Realm][AAP.Name]["Settings"]["Hcamptop"] = -150
	AAP1[AAP.Realm][AAP.Name]["Settings"]["CutScene"] = 1
	AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoAccept"] = 1
	AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoHandIn"] = 1
	AAP1[AAP.Realm][AAP.Name]["Settings"]["ChooseQuests"] = 0
	AAP1[AAP.Realm][AAP.Name]["Settings"]["ArrowScale"] = UIParent:GetScale()
	AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoHandInChoice"] = 0
	AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowQList"] = 1
	AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoVendor"] = 0
	AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoRepair"] = 0
	AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowGroup"] = 1
	AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoGossip"] = 1
	AAP1[AAP.Realm][AAP.Name]["Settings"]["BannerShow"] = 0
	if (AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowQList"] == 0) then
		AAP.OptionsFrame.ShowQListCheckButton:SetChecked(false)
	else
		AAP.OptionsFrame.ShowQListCheckButton:SetChecked(true)
	end
	if (AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowGroup"] == 0) then
		AAP.OptionsFrame.ShowGroupCheckButton:SetChecked(false)
	else
		AAP.OptionsFrame.ShowGroupCheckButton:SetChecked(true)
	end
	if (AAP1[AAP.Realm][AAP.Name]["Settings"]["BannerShow"] == 0) then
		AAP.OptionsFrame.BannerShowCheckButton:SetChecked(false)
	else
		AAP.OptionsFrame.BannerShowCheckButton:SetChecked(true)
	end
	if (AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoGossip"] == 0) then
		AAP.OptionsFrame.AutoGossipCheckButton:SetChecked(false)
	else
		AAP.OptionsFrame.AutoGossipCheckButton:SetChecked(true)
	end
	if (AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoVendor"] == 0) then
		AAP.OptionsFrame.AutoVendorCheckButton:SetChecked(false)
	else
		AAP.OptionsFrame.AutoVendorCheckButton:SetChecked(true)
	end
	if (AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoRepair"] == 0) then
		AAP.OptionsFrame.AutoRepairCheckButton:SetChecked(false)
	else
		AAP.OptionsFrame.AutoRepairCheckButton:SetChecked(true)
	end
	if (AAP1[AAP.Realm][AAP.Name]["Settings"]["Lock"] == 0) then
		AAP.OptionsFrame.LockQuestListCheckButton:SetChecked(false)
	else
		AAP.OptionsFrame.LockQuestListCheckButton:SetChecked(true)
	end
	if (AAP1[AAP.Realm][AAP.Name]["Settings"]["CutScene"] == 0) then
		AAP.OptionsFrame.CutSceneCheckButton:SetChecked(false)
	else
		AAP.OptionsFrame.CutSceneCheckButton:SetChecked(true)
	end
	if (AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoAccept"] == 0) then
		AAP.OptionsFrame.AutoAcceptCheckButton:SetChecked(false)
	else
		AAP.OptionsFrame.AutoAcceptCheckButton:SetChecked(true)
	end
	if (AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoHandIn"] == 0) then
		AAP.OptionsFrame.AutoHandInCheckButton:SetChecked(false)
	else
		AAP.OptionsFrame.AutoHandInCheckButton:SetChecked(true)
	end
	if (AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoHandInChoice"] == 0) then
		AAP.OptionsFrame.AutoHandInChoiceCheckButton:SetChecked(false)
	else
		AAP.OptionsFrame.AutoHandInChoiceCheckButton:SetChecked(true)
	end
	
	AAP.QuestList.ButtonParent:SetScale(AAP1[AAP.Realm][AAP.Name]["Settings"]["Scale"])
	AAP.QuestList.ListFrame:SetScale(AAP1[AAP.Realm][AAP.Name]["Settings"]["Scale"])
	AAP.QuestList21:SetScale(AAP1[AAP.Realm][AAP.Name]["Settings"]["Scale"])
	AAP.OptionsFrame.QuestListScaleSlider:SetValue(AAP1[AAP.Realm][AAP.Name]["Settings"]["Scale"] * 100)
	AAP.OptionsFrame.ArrowScaleSlider:SetValue(AAP1[AAP.Realm][AAP.Name]["Settings"]["ArrowScale"] * 100)


	AAP.QuestList.MainFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", AAP1[AAP.Realm][AAP.Name]["Settings"]["left"], AAP1[AAP.Realm][AAP.Name]["Settings"]["top"])
	AAP.ArrowFrame:SetScale(AAP1[AAP.Realm][AAP.Name]["Settings"]["ArrowScale"])
	AAP.ArrowFrameM:SetPoint("TOPLEFT", UIParent, "TOPLEFT", AAP1[AAP.Realm][AAP.Name]["Settings"]["arrowleft"], AAP1[AAP.Realm][AAP.Name]["Settings"]["arrowtop"])
end
local function AAP_SlashCmd(AAP_index)
	if (AAP_index == "reset") then
		print("AAP: Resetting Zone.")
		AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = 1
		AAP.BookingList["UpdateQuest"] = 1
		AAP.BookingList["PrintQStep"] = 1
	elseif (AAP_index == "skip") then
		print("AAP: Skipping QuestStep.")
		AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
		AAP.BookingList["UpdateQuest"] = 1
		AAP.BookingList["PrintQStep"] = 1
	elseif (AAP_index == "skipcamp") then
		print("AAP: Skipping CampStep.")
		AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 14
		AAP.BookingList["UpdateQuest"] = 1
		AAP.BookingList["PrintQStep"] = 1
	else
		AAP.SettingsOpen = 1
		AAP.OptionsFrame.MainFrame:Show()
		AAP.RemoveIcons()
		AAP.BookingList["OpenedSettings"] = 1
	end
end
	
AAP.ArrowFrameM = CreateFrame("Button", "AAP_Arrow", UIParent)
AAP.ArrowFrameM:SetHeight(1)
AAP.ArrowFrameM:SetWidth(1)
AAP.ArrowFrameM:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
AAP.ArrowFrameM:EnableMouse(true)
AAP.ArrowFrameM:SetMovable(true)

AAP.ArrowFrame = CreateFrame("Button", "AAP_Arrow", UIParent)
AAP.ArrowFrame:SetHeight(42)
AAP.ArrowFrame:SetWidth(56)
AAP.ArrowFrame:SetPoint("TOPLEFT", AAP.ArrowFrameM, "TOPLEFT", 0, 0)
AAP.ArrowFrame:EnableMouse(true)
AAP.ArrowFrame:SetMovable(true)
AAP.ArrowFrame.arrow = AAP.ArrowFrame:CreateTexture(nil, "OVERLAY")
AAP.ArrowFrame.arrow:SetTexture("Interface\\Addons\\Azeroth Auto Pilot\\Img\\Arrow.blp")
AAP.ArrowFrame.arrow:SetAllPoints()
AAP.ArrowFrame.distance = AAP.ArrowFrame:CreateFontString("ARTWORK", "ChatFontNormal")
AAP.ArrowFrame.distance:SetFontObject("GameFontNormalSmall")
AAP.ArrowFrame.distance:SetPoint("TOP", AAP.ArrowFrame, "BOTTOM", 0, 0)
AAP.ArrowFrame:Hide()
AAP.ArrowFrame:SetScript("OnMouseDown", function(self, button)
	if button == "LeftButton" and not AAP.ArrowFrameM.isMoving and AAP1[AAP.Realm][AAP.Name]["Settings"]["LockArrow"] == 0 then
		AAP.ArrowFrameM:StartMoving();
		AAP.ArrowFrameM.isMoving = true;
	end
end)
AAP.ArrowFrame:SetScript("OnMouseUp", function(self, button)
	if button == "LeftButton" and AAP.ArrowFrameM.isMoving then
		AAP.ArrowFrameM:StopMovingOrSizing();
		AAP.ArrowFrameM.isMoving = false;
		AAP1[AAP.Realm][AAP.Name]["Settings"]["arrowleft"] = AAP.ArrowFrameM:GetLeft()
		AAP1[AAP.Realm][AAP.Name]["Settings"]["arrowtop"] = AAP.ArrowFrameM:GetTop() - GetScreenHeight()
		AAP.ArrowFrameM:SetPoint("TOPLEFT", UIParent, "TOPLEFT", AAP1[AAP.Realm][AAP.Name]["Settings"]["arrowleft"], AAP1[AAP.Realm][AAP.Name]["Settings"]["arrowtop"])
	end
end)
AAP.ArrowFrame:SetScript("OnHide", function(self)
	if ( AAP.ArrowFrameM.isMoving ) then
		AAP.ArrowFrameM:StopMovingOrSizing();
		AAP.ArrowFrameM.isMoving = false;
		AAP1[AAP.Realm][AAP.Name]["Settings"]["arrowleft"] = AAP.ArrowFrameM:GetLeft()
		AAP1[AAP.Realm][AAP.Name]["Settings"]["arrowtop"] = AAP.ArrowFrameM:GetTop() - GetScreenHeight()
		AAP.ArrowFrameM:SetPoint("TOPLEFT", UIParent, "TOPLEFT", AAP1[AAP.Realm][AAP.Name]["Settings"]["arrowleft"], AAP1[AAP.Realm][AAP.Name]["Settings"]["arrowtop"])
	end
end)

AAP.ArrowFrame.Button = CreateFrame("Button", "AAP_ArrowActiveButton", AAP_ArrowFrame)
AAP.ArrowFrame.Button:SetWidth(85)
AAP.ArrowFrame.Button:SetHeight(17)
AAP.ArrowFrame.Button:SetParent(AAP.ArrowFrame)
AAP.ArrowFrame.Button:SetPoint("BOTTOM", AAP.ArrowFrame, "BOTTOM", 0, -30)
AAP.ArrowFrame.Button:SetScript("OnMouseDown", function(self, button)
	AAP.ArrowFrame.Button:Hide()
	print("AAP: Skipping Waypoint")
	AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
	AAP.ArrowActive_X = 0
	AAP.ArrowActive_Y = 0
	AAP.BookingList["UpdateQuest"] = 1
	AAP.BookingList["PrintQStep"] = 1
end)
AAP.ArrowFrame.Button:SetBackdrop( { 
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 10, edgeSize = 10, insets = { left = 2, right = 2, top = 2, bottom = 2 }
});
AAP.ArrowFrame.Fontstring = AAP.ArrowFrame:CreateFontString("CLSettingsFS2212","ARTWORK", "ChatFontNormal")
AAP.ArrowFrame.Fontstring:SetParent(AAP.ArrowFrame.Button)
AAP.ArrowFrame.Fontstring:SetPoint("CENTER", AAP.ArrowFrame.Button, "CENTER", 0, 0)

AAP.ArrowFrame.Fontstring:SetFontObject("GameFontNormalSmall")
AAP.ArrowFrame.Fontstring:SetText("Skip waypoint")
AAP.ArrowFrame.Fontstring:SetTextColor(1, 1, 0)
AAP.ArrowFrame.Button:Hide()


AAP.CoreEventFrame = CreateFrame("Frame")
AAP.CoreEventFrame:RegisterEvent ("ADDON_LOADED")
AAP.CoreEventFrame:RegisterEvent ("CINEMATIC_START")

AAP.CoreEventFrame:SetScript("OnEvent", function(self, event, ...)
	if (event=="ADDON_LOADED") then
		local arg1, arg2, arg3, arg4, arg5 = ...;
		if (arg1 ~= "Azeroth Auto Pilot") then
			return
		end
		if (not AAP1) then
			AAP1 = {}
		end
		if (not AAP1[AAP.Realm]) then
			AAP1[AAP.Realm] = {}
		end
		if (not AAP1[AAP.Realm][AAP.Name]) then
			AAP1[AAP.Realm][AAP.Name] = {}
		end
		if (not AAP1[AAP.Realm][AAP.Name]["BonusSkips"]) then
			AAP1[AAP.Realm][AAP.Name]["BonusSkips"] = {}
		end
		AAP_LoadInTimer = AAP.CoreEventFrame:CreateAnimationGroup()
		AAP_LoadInTimer.anim = AAP_LoadInTimer:CreateAnimation()
		AAP_LoadInTimer.anim:SetDuration(1)
		AAP_LoadInTimer:SetLooping("REPEAT")
		AAP_LoadInTimer:SetScript("OnLoop", function(self, event, ...)
			if (CoreLoadin == 1 and AAP.QuestListLoadin == 1) then
				AAP.LoadOptionsFrame()
				AAP.BookingList["UpdateMapId"] = 1
				AAP.BookingList["UpdateQuest"] = 1
				AAP.BookingList["PrintQStep"] = 1
				AAP.BookingList["Heirloomscheck"] = 1
				AAP.CreateMacro()
				print("Loaded")
				AAP_LoadInTimer:Stop()
				C_Timer.After(5, AAP_BookQStep)
			end
		end)
		AAP_LoadInTimer:Play()
		
		
		
		AAP_IconTimer = AAP.CoreEventFrame:CreateAnimationGroup()
		AAP_IconTimer.anim = AAP_IconTimer:CreateAnimation()
		AAP_IconTimer.anim:SetDuration(0.05)
		AAP_IconTimer:SetLooping("REPEAT")
		AAP_IconTimer:SetScript("OnLoop", function(self, event, ...)
			if (AAP.Icons[1]) then
				AAP.BookingList["MoveIcons"] = 1
			end
		end)
		AAP_IconTimer:Play()
		
		
		if (not AAP1[AAP.Realm][AAP.Name]["LoaPick"]) then
			AAP1[AAP.Realm][AAP.Name]["LoaPick"] = 0
		end
			if (not AAP1[AAP.Realm][AAP.Name]["QlineSkip"]) then
				AAP1[AAP.Realm][AAP.Name]["QlineSkip"] = {}
			end
			if (not AAP1[AAP.Realm][AAP.Name]["SkippedBonusObj"]) then
				AAP1[AAP.Realm][AAP.Name]["SkippedBonusObj"] = {}
			end
			if (not AAP1[AAP.Realm][AAP.Name]["Settings"]) then
				AAP1[AAP.Realm][AAP.Name]["Settings"] = {}
				AAP1[AAP.Realm][AAP.Name]["Settings"]["left"] = GetScreenWidth() / 1.6
				AAP1[AAP.Realm][AAP.Name]["Settings"]["top"] = -(GetScreenHeight() / 5)
				AAP1[AAP.Realm][AAP.Name]["Settings"]["Scale"] = UIParent:GetScale()
				AAP1[AAP.Realm][AAP.Name]["Settings"]["Lock"] = 0
				AAP1[AAP.Realm][AAP.Name]["Settings"]["Hide"] = 0
				AAP1[AAP.Realm][AAP.Name]["Settings"]["alpha"] = 1
				AAP1[AAP.Realm][AAP.Name]["Settings"]["arrowleft"] = GetScreenWidth() / 2.05
				AAP1[AAP.Realm][AAP.Name]["Settings"]["arrowtop"] = -(GetScreenHeight() / 1.5)
			end
			if (not AAP1[AAP.Realm][AAP.Name]["Settings"]["LockArrow"]) then
				AAP1[AAP.Realm][AAP.Name]["Settings"]["LockArrow"] = 0
			end
			if (not AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoGossip"]) then
				AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoGossip"] = 1
			end
			if (not AAP1[AAP.Realm][AAP.Name]["Settings"]["BannerScale"]) then
				AAP1[AAP.Realm][AAP.Name]["Settings"]["BannerScale"] = UIParent:GetScale()
			end
			if (not AAP1[AAP.Realm][AAP.Name]["Settings"]["BannerShow"]) then
				AAP1[AAP.Realm][AAP.Name]["Settings"]["BannerShow"] = 0
			end
			if (not AAP1[AAP.Realm][AAP.Name]["Settings"]["Hcampleft"]) then
				AAP1[AAP.Realm][AAP.Name]["Settings"]["Hcampleft"] = GetScreenWidth() / 1.6
			end
			if (not AAP1[AAP.Realm][AAP.Name]["Settings"]["Hcamptop"]) then
				AAP1[AAP.Realm][AAP.Name]["Settings"]["Hcamptop"] = -(GetScreenHeight() / 5)
			end
			if (not AAP1[AAP.Realm][AAP.Name]["Settings"]["CutScene"]) then
				AAP1[AAP.Realm][AAP.Name]["Settings"]["CutScene"] = 1
			end
			if (not AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoAccept"]) then
				AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoAccept"] = 1
			end
			if (not AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoHandIn"]) then
				AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoHandIn"] = 1
			end
			AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoShareQ"] = 0
			if (not AAP1[AAP.Realm][AAP.Name]["Settings"]["ChooseQuests"]) then
				AAP1[AAP.Realm][AAP.Name]["Settings"]["ChooseQuests"] = 0
			end
			if (not AAP1[AAP.Realm][AAP.Name]["Settings"]["ArrowScale"]) then
				AAP1[AAP.Realm][AAP.Name]["Settings"]["ArrowScale"] = UIParent:GetScale()
			end
			if (not AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoHandInChoice"]) then
				AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoHandInChoice"] = 0
			end
			if (not AAP1[AAP.Realm][AAP.Name]["Settings"]["Greetings"]) then
				AAP1[AAP.Realm][AAP.Name]["Settings"]["Greetings"] = 0
			end
			if (not AAP1[AAP.Realm][AAP.Name]["Settings"]["Greetings3"]) then
				AAP1[AAP.Realm][AAP.Name]["Settings"]["Greetings3"] = 0
			end
			if (not AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoVendor"]) then
				AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoVendor"] = 0
			end
			if (not AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoRepair"]) then
				AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoRepair"] = 0
			end
			if (not AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowGroup"]) then
				AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowGroup"] = 1
			end
			if (not AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowArrow"]) then
				AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowArrow"] = 1
			end
			if (not AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowQList"]) then
				AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowQList"] = 1
			end
			if (not AAP1[AAP.Realm][AAP.Name]["AAP_DoWarCampaign"]) then
				AAP1[AAP.Realm][AAP.Name]["AAP_DoWarCampaign"] = 0
			end

			if (not AAP1[AAP.Realm][AAP.Name]["WantedQuestList"]) then
				AAP1[AAP.Realm][AAP.Name]["WantedQuestList"] = {}
			end
			AAP_MakeBanners()
			AAP.Banners.BannersFrame.Frame:SetScale(AAP1[AAP.Realm][AAP.Name]["Settings"]["BannerScale"])
			AAP.Banners.BannersFrame["Frame1"]:SetScale(AAP1[AAP.Realm][AAP.Name]["Settings"]["BannerScale"])
			AAP.Banners.BannersFrame["Frame2"]:SetScale(AAP1[AAP.Realm][AAP.Name]["Settings"]["BannerScale"])
			AAP.Banners.BannersFrame["Frame3"]:SetScale(AAP1[AAP.Realm][AAP.Name]["Settings"]["BannerScale"])
			AAP.Banners.BannersFrame["Frame4"]:SetScale(AAP1[AAP.Realm][AAP.Name]["Settings"]["BannerScale"])
			AAP.ArrowFrame:SetScale(AAP1[AAP.Realm][AAP.Name]["Settings"]["ArrowScale"])
			AAP.ArrowFrameM:SetPoint("TOPLEFT", UIParent, "TOPLEFT", AAP1[AAP.Realm][AAP.Name]["Settings"]["arrowleft"], AAP1[AAP.Realm][AAP.Name]["Settings"]["arrowtop"])

			
			
			AAP.ButtonBookingTimer = AAP.CoreEventFrame:CreateAnimationGroup()
			AAP.ButtonBookingTimer.anim = AAP.ButtonBookingTimer:CreateAnimation()
			AAP.ButtonBookingTimer.anim:SetDuration(0.1)
			AAP.ButtonBookingTimer:SetLooping("REPEAT")
			AAP.ButtonBookingTimer:SetScript("OnLoop", function(self, event, ...)
				AAP.SetButton()
			end)
			AAP.ButtonBookingTimer:Play()
			AAP.LoadInTimer = AAP.CoreEventFrame:CreateAnimationGroup()
			AAP.LoadInTimer.anim = AAP.LoadInTimer:CreateAnimation()
			AAP.LoadInTimer.anim:SetDuration(10)
			AAP.LoadInTimer:SetLooping("REPEAT")
			AAP.LoadInTimer:SetScript("OnLoop", function(self, event, ...)
				AAP.BookingList["PrintQStep"] = 1
				AAP.LoadInTimer:Stop()
			end)
			AAP.LoadInTimer:Play()
			AAP.ArrowEventAFkTimer = AAP.CoreEventFrame:CreateAnimationGroup()
			AAP.ArrowEventAFkTimer.anim = AAP.ArrowEventAFkTimer:CreateAnimation()
			AAP.ArrowEventAFkTimer.anim:SetDuration(0.1)
			AAP.ArrowEventAFkTimer:SetLooping("REPEAT")
			AAP.ArrowEventAFkTimer:SetScript("OnLoop", function(self, event, ...)
				if (AAP.AfkTimerVar > 0) then
					AAP.AfkTimerVar = AAP.AfkTimerVar - 0.1
					AAP.AfkTimerVar = floor(AAP.AfkTimerVar * 10)/10
					local aap_printtext = ""
					local aap_min = 0
					local aap_sec = AAP.AfkTimerVar
					if (aap_sec > 60) then
						aap_min = floor(aap_sec/60)
						aap_sec = aap_sec - (aap_min*60)
						if (aap_min > 9) then
							aap_printtext = aap_min .. ":"
						else
							aap_printtext = "0" .. aap_min .. ":"
						end
					end
					if (string.find(aap_sec, "(%d+).(%d+)")) then
						if (aap_sec > 10 and aap_min > 0) then
							aap_printtext = aap_printtext .. aap_sec
						elseif (aap_min > 0) then
							aap_printtext = aap_printtext .. "0" .. aap_sec
						else
							aap_printtext = aap_printtext .. aap_sec
						end
					else
						if (aap_sec > 10 and aap_min > 0) then
							aap_printtext = aap_printtext .. aap_sec .. ".0"
						elseif (aap_min > 0) then
							aap_printtext = aap_printtext .. "0" .. aap_sec .. ".0"
						else
							aap_printtext = aap_printtext .. aap_sec .. ".0"
						end
					end
					AAP.AfkFrame.Fontstring:SetText("AFK: " .. aap_printtext)
					local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
					if (AAP.QuestStepList[AAP.ActiveMap] and AAP.QuestStepList[AAP.ActiveMap][CurStep]) then
						local steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
						if (steps and steps["SpecialETAHide"]) then
							AAP.AfkFrame:Hide()
						else
							AAP.AfkFrame:Show()
						end
					else
						AAP.AfkFrame:Show()
					end
				else
					AAP.ArrowEventAFkTimer:Stop()
					AAP.AfkFrame:Hide()
				end
			end)
		SlashCmdList["AAP_Cmd"] = AAP_SlashCmd
		SLASH_AAP_Cmd1 = "/aap"
		CoreLoadin = 1
	elseif (event=="CINEMATIC_START") then
		if (not IsControlKeyDown()) then
			local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
			local steps
			if (CurStep and AAP.QuestStepList and AAP.QuestStepList[AAP.ActiveMap]) then
				steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
			end
			if (AAP1[AAP.Realm][AAP.Name]["Settings"]["CutScene"] == 1 and (steps and not steps["Dontskipvid"])) then
				AAP.BookingList["SkipCutscene"] = 1
			end
		end
	end
end)