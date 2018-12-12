AAP.AAP_panel = CreateFrame( "Frame", "CLPanelFrame", UIParent)
AAP.AAP_panel.name = "Azeroth Auto Pilot"
InterfaceOptions_AddCategory(AAP.AAP_panel)
AAP_panel = {}
AAP_panel.title = CreateFrame("SimpleHTML",nil,AAP.AAP_panel)
AAP_panel.title:SetWidth(500)
AAP_panel.title:SetHeight(20)
AAP_panel.title:SetPoint("TOPLEFT", AAP.AAP_panel, 0,-30)
AAP_panel.title:SetFontObject("GameFontHighlightLarge")
AAP_panel.title:SetText("Azeroth Auto Pilot - v" .. AAP.Version)

AAP_panel.Button1 = CreateFrame("Button", "ZPButton2", AAP.AAP_panel)
AAP_panel.Button1:SetPoint("TOPLEFT", AAP.AAP_panel, "TOPLEFT", 120, -100)
AAP_panel.Button1:SetWidth(70)
AAP_panel.Button1:SetHeight(30)
AAP_panel.Button1:SetText("Load")
AAP_panel.Button1:SetNormalFontObject("GameFontNormal")
AAP_panel.Button1ntex = AAP_panel.Button1:CreateTexture()
AAP_panel.Button1ntex:SetTexture("Interface/Buttons/UI-Panel-Button-Up")
AAP_panel.Button1ntex:SetTexCoord(0, 0.625, 0, 0.6875)
AAP_panel.Button1ntex:SetAllPoints()	
AAP_panel.Button1:SetNormalTexture(AAP_panel.Button1ntex)
AAP_panel.Button1htex = AAP_panel.Button1:CreateTexture()
AAP_panel.Button1htex:SetTexture("Interface/Buttons/UI-Panel-Button-Highlight")
AAP_panel.Button1htex:SetTexCoord(0, 0.625, 0, 0.6875)
AAP_panel.Button1htex:SetAllPoints()
AAP_panel.Button1:SetHighlightTexture(AAP_panel.Button1htex)
AAP_panel.Button1ptex = AAP_panel.Button1:CreateTexture()
AAP_panel.Button1ptex:SetTexture("Interface/Buttons/UI-Panel-Button-Down")
AAP_panel.Button1ptex:SetTexCoord(0, 0.625, 0, 0.6875)
AAP_panel.Button1ptex:SetAllPoints()
AAP_panel.Button1:SetPushedTexture(AAP_panel.Button1ptex)
AAP_panel.Button1:SetScript("OnClick", function(self, arg1)
	InterfaceOptionsFrame:Hide()
	HideUIPanel(GameMenuFrame)
	AAP.OptionsFrame.MainFrame:Show()
end)
function AAP.LoadOptionsFrame()
	AAP.OptionsFrame = {}
	AAP.OptionsFrame.MainFrame = CreateFrame("frame", "AAP_OptionsMainFrame",  UIParent)
	AAP.OptionsFrame.MainFrame:SetWidth(450)
	AAP.OptionsFrame.MainFrame:SetHeight(360)
	AAP.OptionsFrame.MainFrame:SetFrameStrata("MEDIUM")
	AAP.OptionsFrame.MainFrame:SetPoint("CENTER",  UIParent, "CENTER",0,0)
	AAP.OptionsFrame.MainFrame:SetMovable(true)
	AAP.OptionsFrame.MainFrame:EnableMouse(true)
	AAP.OptionsFrame.MainFrame:SetBackdrop( { 
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 10, edgeSize = 10, insets = { left = 2, right = 2, top = 2, bottom = 2 }
	});
	AAP.OptionsFrame.MainFrame:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" and not AAP.OptionsFrame.MainFrame.isMoving then
			AAP.OptionsFrame.MainFrame:StartMoving();
			AAP.OptionsFrame.MainFrame.isMoving = true;
		end
	end)
	AAP.OptionsFrame.MainFrame:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" and AAP.OptionsFrame.MainFrame.isMoving then
			AAP.OptionsFrame.MainFrame:StopMovingOrSizing();
			AAP.OptionsFrame.MainFrame.isMoving = false;
		end
	end)
	AAP.OptionsFrame.MainFrame:SetScript("OnHide", function(self)
		if ( AAP.OptionsFrame.MainFrame.isMoving ) then
			AAP.OptionsFrame.MainFrame:StopMovingOrSizing();
			AAP.OptionsFrame.MainFrame.isMoving = false;
		end
	end)
	AAP.OptionsFrame.MainFrame:Hide()

	
	AAP.OptionsFrame.MainFrame.Options = CreateFrame("frame", "AAP_OptionsMainFrame_1",  AAP_OptionsMainFrame)
	AAP.OptionsFrame.MainFrame.Options:SetWidth(150)
	AAP.OptionsFrame.MainFrame.Options:SetHeight(320)
	AAP.OptionsFrame.MainFrame.Options:SetFrameStrata("MEDIUM")
	AAP.OptionsFrame.MainFrame.Options:SetPoint("LEFT",  AAP_OptionsMainFrame, "LEFT",0,-20)
	AAP.OptionsFrame.MainFrame.Options:SetMovable(true)
	AAP.OptionsFrame.MainFrame.Options:EnableMouse(true)
	AAP.OptionsFrame.MainFrame.Options:SetBackdrop( { 
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 10, edgeSize = 10, insets = { left = 2, right = 2, top = 2, bottom = 2 }
	});
	AAP.OptionsFrame.MainFrame.Options:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" and not AAP.OptionsFrame.MainFrame.isMoving then
			AAP.OptionsFrame.MainFrame:StartMoving();
			AAP.OptionsFrame.MainFrame.isMoving = true;
		end
	end)
	AAP.OptionsFrame.MainFrame.Options:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" and AAP.OptionsFrame.MainFrame.isMoving then
			AAP.OptionsFrame.MainFrame:StopMovingOrSizing();
			AAP.OptionsFrame.MainFrame.isMoving = false;
		end
	end)
	AAP.OptionsFrame.MainFrame.Options:SetScript("OnHide", function(self)
		if ( AAP.OptionsFrame.MainFrame.isMoving ) then
			AAP.OptionsFrame.MainFrame:StopMovingOrSizing();
			AAP.OptionsFrame.MainFrame.isMoving = false;
		end
	end)
	AAP.OptionsFrame.FontString1 = AAP.OptionsFrame.MainFrame:CreateFontString("AAPSettingsFS1","ARTWORK", "ChatFontNormal")
	AAP.OptionsFrame.FontString1:SetParent(AAP.OptionsFrame.MainFrame)
	AAP.OptionsFrame.FontString1:SetPoint("TOP",AAP.OptionsFrame.MainFrame,"TOP",0,0)
	AAP.OptionsFrame.FontString1:SetWidth(240)
	AAP.OptionsFrame.FontString1:SetHeight(20)
	AAP.OptionsFrame.FontString1:SetFontObject("GameFontHighlightLarge")
	AAP.OptionsFrame.FontString1:SetText("Azeroth Auto Pilot - v" .. AAP.Version)
	AAP.OptionsFrame.FontString1:SetTextColor(1, 1, 0)
-------------------- Quest Options ----------------------------------------
	AAP.OptionsFrame.MainFrame.OptionsB1 = CreateFrame("frame", "AAP_OptionsMainFrame_QuestOptions",  AAP_OptionsMainFrame)
	AAP.OptionsFrame.MainFrame.OptionsB1:SetWidth(150)
	AAP.OptionsFrame.MainFrame.OptionsB1:SetHeight(30)
	AAP.OptionsFrame.MainFrame.OptionsB1:SetFrameStrata("HIGH")
	AAP.OptionsFrame.MainFrame.OptionsB1:SetPoint("TOPLEFT",  AAP_OptionsMainFrame, "TOPLEFT",0,-40)
	AAP.OptionsFrame.MainFrame.OptionsB1:SetMovable(true)
	AAP.OptionsFrame.MainFrame.OptionsB1:EnableMouse(true)
	AAP.OptionsFrame.MainFrame.OptionsB1:SetBackdrop( { 
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 10, edgeSize = 10, insets = { left = 2, right = 2, top = 2, bottom = 2 }
	});
	AAP.OptionsFrame.MainFrame.OptionsB1:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			AAP.OptionsFrame.MainFrame.OptionsQuests:Show()
			AAP.OptionsFrame.MainFrame.OptionsArrow:Hide()
			AAP.OptionsFrame.MainFrame.OptionsGeneral:Hide()
		end
	end)
	AAP.OptionsFrame.MainFrame.OptionsB1:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" and AAP.OptionsFrame.MainFrame.isMoving then
			AAP.OptionsFrame.MainFrame:StopMovingOrSizing();
			AAP.OptionsFrame.MainFrame.isMoving = false;
		end
	end)
	AAP.OptionsFrame.MainFrame.OptionsB1:SetScript("OnHide", function(self)
		if ( AAP.OptionsFrame.MainFrame.isMoving ) then
			AAP.OptionsFrame.MainFrame:StopMovingOrSizing();
			AAP.OptionsFrame.MainFrame.isMoving = false;
		end
	end)
	AAP.OptionsFrame.MainFrame.OptionsB1.FontString = AAP.OptionsFrame.MainFrame:CreateFontString("AAP_OptionsB1FS1","ARTWORK", "ChatFontNormal")
	AAP.OptionsFrame.MainFrame.OptionsB1.FontString:SetParent(AAP.OptionsFrame.MainFrame.OptionsB1)
	AAP.OptionsFrame.MainFrame.OptionsB1.FontString:SetPoint("CENTER",AAP.OptionsFrame.MainFrame.OptionsB1,"CENTER",0,0)
	AAP.OptionsFrame.MainFrame.OptionsB1.FontString:SetWidth(240)
	AAP.OptionsFrame.MainFrame.OptionsB1.FontString:SetHeight(20)
	AAP.OptionsFrame.MainFrame.OptionsB1.FontString:SetFontObject("GameFontHighlightLarge")
	AAP.OptionsFrame.MainFrame.OptionsB1.FontString:SetText("Quest Options")
	AAP.OptionsFrame.MainFrame.OptionsB1.FontString:SetTextColor(1, 1, 0)

	AAP.OptionsFrame.MainFrame.OptionsQuests = CreateFrame("frame", "AAP_OptionsMainFrame_Quests",  AAP_OptionsMainFrame)
	AAP.OptionsFrame.MainFrame.OptionsQuests:SetWidth(295)
	AAP.OptionsFrame.MainFrame.OptionsQuests:SetHeight(320)
	AAP.OptionsFrame.MainFrame.OptionsQuests:SetFrameStrata("MEDIUM")
	AAP.OptionsFrame.MainFrame.OptionsQuests:SetPoint("LEFT",  AAP_OptionsMainFrame, "LEFT",155,-20)
	AAP.OptionsFrame.MainFrame.OptionsQuests:SetMovable(true)
	AAP.OptionsFrame.MainFrame.OptionsQuests:EnableMouse(true)
	AAP.OptionsFrame.MainFrame.OptionsQuests:SetBackdrop( { 
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 10, edgeSize = 10, insets = { left = 2, right = 2, top = 2, bottom = 2 }
	});
	AAP.OptionsFrame.MainFrame.OptionsQuests:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" and not AAP.OptionsFrame.MainFrame.isMoving then
			AAP.OptionsFrame.MainFrame:StartMoving();
			AAP.OptionsFrame.MainFrame.isMoving = true;
		end
	end)
	AAP.OptionsFrame.MainFrame.OptionsQuests:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" and AAP.OptionsFrame.MainFrame.isMoving then
			AAP.OptionsFrame.MainFrame:StopMovingOrSizing();
			AAP.OptionsFrame.MainFrame.isMoving = false;
		end
	end)
	AAP.OptionsFrame.MainFrame.OptionsQuests:SetScript("OnHide", function(self)
		if ( AAP.OptionsFrame.MainFrame.isMoving ) then
			AAP.OptionsFrame.MainFrame:StopMovingOrSizing();
			AAP.OptionsFrame.MainFrame.isMoving = false;
		end
	end)
	AAP.OptionsFrame.MainFrame.OptionsQuests:Hide()
		AAP.OptionsFrame.AutoAcceptCheckButton = CreateFrame("CheckButton", "AAP_AutoAcceptCheckButton", AAP.OptionsFrame.MainFrame.OptionsQuests, "ChatConfigCheckButtonTemplate");
	AAP.OptionsFrame.AutoAcceptCheckButton:SetPoint("TOPLEFT", AAP.OptionsFrame.MainFrame.OptionsQuests, "TOPLEFT", 10, -10)
	if (AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoAccept"] == 0) then
		AAP.OptionsFrame.AutoAcceptCheckButton:SetChecked(false)
	else
		AAP.OptionsFrame.AutoAcceptCheckButton:SetChecked(true)
	end
	getglobal(AAP.OptionsFrame.AutoAcceptCheckButton:GetName() .. 'Text'):SetText(": "..AAP_Locals["Accept Quest"])
	getglobal(AAP.OptionsFrame.AutoAcceptCheckButton:GetName() .. 'Text'):SetTextColor(1, 1, 1)
	AAP.OptionsFrame.AutoAcceptCheckButton:SetScript("OnClick", function()
		if (AAP.OptionsFrame.AutoAcceptCheckButton:GetChecked() == true) then
			AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoAccept"] = 1
		else
			AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoAccept"] = 0
		end
	end)
	AAP.OptionsFrame.AutoHandInCheckButton = CreateFrame("CheckButton", "AAP_AutoHandInCheckButton", AAP.OptionsFrame.MainFrame.OptionsQuests, "ChatConfigCheckButtonTemplate");
	AAP.OptionsFrame.AutoHandInCheckButton:SetPoint("TOPLEFT", AAP.OptionsFrame.MainFrame.OptionsQuests, "TOPLEFT", 10, -30)
	if (AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoHandIn"] == 0) then
		AAP.OptionsFrame.AutoHandInCheckButton:SetChecked(false)
	else
		AAP.OptionsFrame.AutoHandInCheckButton:SetChecked(true)
	end
	getglobal(AAP.OptionsFrame.AutoHandInCheckButton:GetName() .. 'Text'):SetText(": "..AAP_Locals["Turn in Quest"])
	getglobal(AAP.OptionsFrame.AutoHandInCheckButton:GetName() .. 'Text'):SetTextColor(1, 1, 1)
	AAP.OptionsFrame.AutoHandInCheckButton:SetScript("OnClick", function()
		if (AAP.OptionsFrame.AutoHandInCheckButton:GetChecked() == true) then
			AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoHandIn"] = 1
		else
			AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoHandIn"] = 0
		end
	end)
	AAP.OptionsFrame.AutoHandInChoiceCheckButton = CreateFrame("CheckButton", "AAP_AutoHandInChoiceCheckButton", AAP.OptionsFrame.MainFrame.OptionsQuests, "ChatConfigCheckButtonTemplate");
	AAP.OptionsFrame.AutoHandInChoiceCheckButton:SetPoint("TOPLEFT", AAP.OptionsFrame.MainFrame.OptionsQuests, "TOPLEFT", 10, -50)
	if (AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoHandInChoice"] == 0) then
		AAP.OptionsFrame.AutoHandInChoiceCheckButton:SetChecked(false)
	else
		AAP.OptionsFrame.AutoHandInChoiceCheckButton:SetChecked(true)
	end
	getglobal(AAP.OptionsFrame.AutoHandInChoiceCheckButton:GetName() .. 'Text'):SetText(": "..AAP_Locals["Choose Reward Ilvl"])
	getglobal(AAP.OptionsFrame.AutoHandInChoiceCheckButton:GetName() .. 'Text'):SetTextColor(1, 1, 1)
	AAP.OptionsFrame.AutoHandInChoiceCheckButton:SetScript("OnClick", function()
		if (AAP.OptionsFrame.AutoHandInChoiceCheckButton:GetChecked() == true) then
			AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoHandInChoice"] = 1
		else
			AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoHandInChoice"] = 0
		end
	end)
	AAP.OptionsFrame.ShowQListCheckButton = CreateFrame("CheckButton", "AAP_ShowQListCheckButton", AAP.OptionsFrame.MainFrame.OptionsQuests, "ChatConfigCheckButtonTemplate");
	AAP.OptionsFrame.ShowQListCheckButton:SetPoint("TOPLEFT", AAP.OptionsFrame.MainFrame.OptionsQuests, "TOPLEFT", 10, -70)
	if (AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowQList"] == 0) then
		AAP.OptionsFrame.ShowQListCheckButton:SetChecked(false)
	else
		AAP.OptionsFrame.ShowQListCheckButton:SetChecked(true)
	end
	getglobal(AAP.OptionsFrame.ShowQListCheckButton:GetName() .. 'Text'):SetText(": "..AAP_Locals["Show QuestList"])
	getglobal(AAP.OptionsFrame.ShowQListCheckButton:GetName() .. 'Text'):SetTextColor(1, 1, 1)
	AAP.OptionsFrame.ShowQListCheckButton:SetScript("OnClick", function()
		if (AAP.OptionsFrame.ShowQListCheckButton:GetChecked() == true) then
			AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowQList"] = 1
			AAP.BookingList["PrintQStep"] = 1
		else
			AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowQList"] = 0
			for CLi = 1, 10 do
				AAP.QuestList.QuestFrames[CLi]:Hide()
				AAP.QuestList.QuestFrames["FS"..CLi]["Button"]:Hide()
				AAP.QuestList2["BF"..CLi]:Hide()
			end
			AAP.BookingList["PrintQStep"] = 1
		end
	end)
	AAP.OptionsFrame.LockQuestListCheckButton = CreateFrame("CheckButton", "AAP_LockQuestListCheckButton", AAP.OptionsFrame.MainFrame.OptionsQuests, "ChatConfigCheckButtonTemplate");
	AAP.OptionsFrame.LockQuestListCheckButton:SetPoint("TOPLEFT", AAP.OptionsFrame.MainFrame.OptionsQuests, "TOPLEFT", 10, -90)
	if (AAP1[AAP.Realm][AAP.Name]["Settings"]["Lock"] == 0) then
		AAP.OptionsFrame.LockQuestListCheckButton:SetChecked(false)
	else
		AAP.OptionsFrame.LockQuestListCheckButton:SetChecked(true)
	end
	getglobal(AAP.OptionsFrame.LockQuestListCheckButton:GetName() .. 'Text'):SetText(": "..AAP_Locals["Lock QuestList"])
	getglobal(AAP.OptionsFrame.LockQuestListCheckButton:GetName() .. 'Text'):SetTextColor(1, 1, 1)
	AAP.OptionsFrame.LockQuestListCheckButton:SetScript("OnClick", function()
		if (AAP.OptionsFrame.LockQuestListCheckButton:GetChecked() == true) then
			AAP1[AAP.Realm][AAP.Name]["Settings"]["Lock"] = 1
		else
			AAP1[AAP.Realm][AAP.Name]["Settings"]["Lock"] = 0
		end
	end)
	AAP.OptionsFrame.QuestListScaleSlider = CreateFrame("Slider", "AAP_QuestListScaleSlider",AAP.OptionsFrame.MainFrame.OptionsQuests, "OptionsSliderTemplate")
	AAP.OptionsFrame.QuestListScaleSlider:SetWidth(160)
	AAP.OptionsFrame.QuestListScaleSlider:SetHeight(15)
	AAP.OptionsFrame.QuestListScaleSlider:SetPoint("TOPLEFT", AAP.OptionsFrame.MainFrame.OptionsQuests, "TOPLEFT", 20, -140)
	AAP.OptionsFrame.QuestListScaleSlider:SetOrientation("HORIZONTAL")
	AAP.OptionsFrame.QuestListScaleSlider:SetMinMaxValues(1, 200)
	AAP.OptionsFrame.QuestListScaleSlider.minValue, AAP.OptionsFrame.QuestListScaleSlider.maxValue = AAP.OptionsFrame.QuestListScaleSlider:GetMinMaxValues() 
	getglobal(AAP.OptionsFrame.QuestListScaleSlider:GetName() .. 'Low'):SetText("1%")
	getglobal(AAP.OptionsFrame.QuestListScaleSlider:GetName() .. 'High'):SetText("200%")
	getglobal(AAP.OptionsFrame.QuestListScaleSlider:GetName() .. 'Text'):SetText("QuestList Scale:")
	AAP.OptionsFrame.QuestListScaleSlider:SetValueStep(1)
	AAP.OptionsFrame.QuestListScaleSlider:SetValue(100)
	AAP.OptionsFrame.QuestListScaleSlider:SetScript("OnValueChanged", function(self,event) 
		event = event - event%1
		AAP1[AAP.Realm][AAP.Name]["Settings"]["Scale"] = event / 100
		AAP.QuestList.ButtonParent:SetScale(AAP1[AAP.Realm][AAP.Name]["Settings"]["Scale"])
		AAP.QuestList.ListFrame:SetScale(AAP1[AAP.Realm][AAP.Name]["Settings"]["Scale"])
		AAP.QuestList21:SetScale(AAP1[AAP.Realm][AAP.Name]["Settings"]["Scale"])
	end)
	AAP.OptionsFrame.QuestListScaleSlider:SetScript("OnMouseWheel", function(self,delta) 
		if tonumber(self:GetValue()) == nil then return end
		self:SetValue(tonumber(self:GetValue())+delta)
	end)
	AAP.OptionsFrame.QuestListScaleSlider:SetValue(AAP1[AAP.Realm][AAP.Name]["Settings"]["Scale"] * 100)
----------------- Arrow Options --------------------------------------------------------------------------------------------
	AAP.OptionsFrame.MainFrame.OptionsB2 = CreateFrame("frame", "AAP_OptionsMainFrame_ArrowOptions",  AAP_OptionsMainFrame)
	AAP.OptionsFrame.MainFrame.OptionsB2:SetWidth(150)
	AAP.OptionsFrame.MainFrame.OptionsB2:SetHeight(30)
	AAP.OptionsFrame.MainFrame.OptionsB2:SetFrameStrata("HIGH")
	AAP.OptionsFrame.MainFrame.OptionsB2:SetPoint("TOPLEFT",  AAP_OptionsMainFrame, "TOPLEFT",0,-70)
	AAP.OptionsFrame.MainFrame.OptionsB2:SetMovable(true)
	AAP.OptionsFrame.MainFrame.OptionsB2:EnableMouse(true)
	AAP.OptionsFrame.MainFrame.OptionsB2:SetBackdrop( { 
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 10, edgeSize = 10, insets = { left = 2, right = 2, top = 2, bottom = 2 }
	});
	AAP.OptionsFrame.MainFrame.OptionsB2:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			AAP.OptionsFrame.MainFrame.OptionsQuests:Hide()
			AAP.OptionsFrame.MainFrame.OptionsArrow:Show()
			AAP.OptionsFrame.MainFrame.OptionsGeneral:Hide()
		end
	end)
	AAP.OptionsFrame.MainFrame.OptionsB2:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" and AAP.OptionsFrame.MainFrame.isMoving then
			AAP.OptionsFrame.MainFrame:StopMovingOrSizing();
			AAP.OptionsFrame.MainFrame.isMoving = false;
		end
	end)
	AAP.OptionsFrame.MainFrame.OptionsB2:SetScript("OnHide", function(self)
		if ( AAP.OptionsFrame.MainFrame.isMoving ) then
			AAP.OptionsFrame.MainFrame:StopMovingOrSizing();
			AAP.OptionsFrame.MainFrame.isMoving = false;
		end
	end)
	AAP.OptionsFrame.MainFrame.OptionsB2.FontString = AAP.OptionsFrame.MainFrame:CreateFontString("AAP_OptionsB2FS1","ARTWORK", "ChatFontNormal")
	AAP.OptionsFrame.MainFrame.OptionsB2.FontString:SetParent(AAP.OptionsFrame.MainFrame.OptionsB2)
	AAP.OptionsFrame.MainFrame.OptionsB2.FontString:SetPoint("CENTER",AAP.OptionsFrame.MainFrame.OptionsB2,"CENTER",0,0)
	AAP.OptionsFrame.MainFrame.OptionsB2.FontString:SetWidth(240)
	AAP.OptionsFrame.MainFrame.OptionsB2.FontString:SetHeight(20)
	AAP.OptionsFrame.MainFrame.OptionsB2.FontString:SetFontObject("GameFontHighlightLarge")
	AAP.OptionsFrame.MainFrame.OptionsB2.FontString:SetText("Arrow Options")
	AAP.OptionsFrame.MainFrame.OptionsB2.FontString:SetTextColor(1, 1, 0)

	AAP.OptionsFrame.MainFrame.OptionsArrow = CreateFrame("frame", "AAP_OptionsMainFrame_Arrow",  AAP_OptionsMainFrame)
	AAP.OptionsFrame.MainFrame.OptionsArrow:SetWidth(295)
	AAP.OptionsFrame.MainFrame.OptionsArrow:SetHeight(320)
	AAP.OptionsFrame.MainFrame.OptionsArrow:SetFrameStrata("MEDIUM")
	AAP.OptionsFrame.MainFrame.OptionsArrow:SetPoint("LEFT",  AAP_OptionsMainFrame, "LEFT",155,-20)
	AAP.OptionsFrame.MainFrame.OptionsArrow:SetMovable(true)
	AAP.OptionsFrame.MainFrame.OptionsArrow:EnableMouse(true)
	AAP.OptionsFrame.MainFrame.OptionsArrow:SetBackdrop( { 
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 10, edgeSize = 10, insets = { left = 2, right = 2, top = 2, bottom = 2 }
	});
	AAP.OptionsFrame.MainFrame.OptionsArrow:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" and not AAP.OptionsFrame.MainFrame.isMoving then
			AAP.OptionsFrame.MainFrame:StartMoving();
			AAP.OptionsFrame.MainFrame.isMoving = true;
		end
	end)
	AAP.OptionsFrame.MainFrame.OptionsArrow:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" and AAP.OptionsFrame.MainFrame.isMoving then
			AAP.OptionsFrame.MainFrame:StopMovingOrSizing();
			AAP.OptionsFrame.MainFrame.isMoving = false;
		end
	end)
	AAP.OptionsFrame.MainFrame.OptionsArrow:SetScript("OnHide", function(self)
		if ( AAP.OptionsFrame.MainFrame.isMoving ) then
			AAP.OptionsFrame.MainFrame:StopMovingOrSizing();
			AAP.OptionsFrame.MainFrame.isMoving = false;
		end
	end)
	AAP.OptionsFrame.MainFrame.OptionsArrow:Hide()
	AAP.OptionsFrame.LockArrowCheckButton = CreateFrame("CheckButton", "AAP_LockArrowCheckButton", AAP.OptionsFrame.MainFrame.OptionsArrow, "ChatConfigCheckButtonTemplate");
	AAP.OptionsFrame.LockArrowCheckButton:SetPoint("TOPLEFT", AAP.OptionsFrame.MainFrame.OptionsArrow, "TOPLEFT", 10, -10)
	if (AAP1[AAP.Realm][AAP.Name]["Settings"]["LockArrow"] == 0) then
		AAP.OptionsFrame.LockArrowCheckButton:SetChecked(false)
	else
		AAP.OptionsFrame.LockArrowCheckButton:SetChecked(true)
	end
	getglobal(AAP.OptionsFrame.LockArrowCheckButton:GetName() .. 'Text'):SetText(": "..AAP_Locals["Lock Arrow"])
	getglobal(AAP.OptionsFrame.LockArrowCheckButton:GetName() .. 'Text'):SetTextColor(1, 1, 1)
	AAP.OptionsFrame.LockArrowCheckButton:SetScript("OnClick", function()
		if (AAP.OptionsFrame.LockArrowCheckButton:GetChecked() == true) then
			AAP1[AAP.Realm][AAP.Name]["Settings"]["LockArrow"] = 1
		else
			AAP1[AAP.Realm][AAP.Name]["Settings"]["LockArrow"] = 0
		end
	end)
	AAP.OptionsFrame.ShowArrowCheckButton = CreateFrame("CheckButton", "AAP_ShowArrowCheckButton", AAP.OptionsFrame.MainFrame.OptionsArrow, "ChatConfigCheckButtonTemplate");
	AAP.OptionsFrame.ShowArrowCheckButton:SetPoint("TOPLEFT", AAP.OptionsFrame.MainFrame.OptionsArrow, "TOPLEFT", 10, -30)
	if (AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowArrow"] == 0) then
		AAP.OptionsFrame.ShowArrowCheckButton:SetChecked(false)
	else
		AAP.OptionsFrame.ShowArrowCheckButton:SetChecked(true)
	end
	getglobal(AAP.OptionsFrame.ShowArrowCheckButton:GetName() .. 'Text'):SetText(": "..AAP_Locals["Show Arrow"])
	getglobal(AAP.OptionsFrame.ShowArrowCheckButton:GetName() .. 'Text'):SetTextColor(1, 1, 1)
	AAP.OptionsFrame.ShowArrowCheckButton:SetScript("OnClick", function()
		if (AAP.OptionsFrame.ShowArrowCheckButton:GetChecked() == true) then
			AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowArrow"] = 1
			AAP.ArrowActive = 1
		else
			AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowArrow"] = 0
		end
	end)
	AAP.OptionsFrame.ArrowScaleSlider = CreateFrame("Slider", "AAP_ArrowScaleSlider",AAP.OptionsFrame.MainFrame.OptionsArrow, "OptionsSliderTemplate")
	AAP.OptionsFrame.ArrowScaleSlider:SetWidth(160)
	AAP.OptionsFrame.ArrowScaleSlider:SetHeight(15)
	AAP.OptionsFrame.ArrowScaleSlider:SetPoint("TOPLEFT", AAP.OptionsFrame.MainFrame.OptionsArrow, "TOPLEFT", 20, -70)
	AAP.OptionsFrame.ArrowScaleSlider:SetOrientation("HORIZONTAL")
	AAP.OptionsFrame.ArrowScaleSlider:SetMinMaxValues(1, 200)
	AAP.OptionsFrame.ArrowScaleSlider.minValue, AAP.OptionsFrame.ArrowScaleSlider.maxValue = AAP.OptionsFrame.ArrowScaleSlider:GetMinMaxValues() 
	getglobal(AAP.OptionsFrame.ArrowScaleSlider:GetName() .. 'Low'):SetText("1%")
	getglobal(AAP.OptionsFrame.ArrowScaleSlider:GetName() .. 'High'):SetText("200%")
	getglobal(AAP.OptionsFrame.ArrowScaleSlider:GetName() .. 'Text'):SetText("Arrow Scale:")
	AAP.OptionsFrame.ArrowScaleSlider:SetValueStep(1)
	AAP.OptionsFrame.ArrowScaleSlider:SetValue(100)
	AAP.OptionsFrame.ArrowScaleSlider:SetScript("OnValueChanged", function(self,event) 
		event = event - event%1
		AAP1[AAP.Realm][AAP.Name]["Settings"]["ArrowScale"] = event / 100
		AAP.ArrowFrame:SetScale(AAP1[AAP.Realm][AAP.Name]["Settings"]["ArrowScale"])

	end)
	AAP.OptionsFrame.ArrowScaleSlider:SetScript("OnMouseWheel", function(self,delta) 
		if tonumber(self:GetValue()) == nil then return end
		self:SetValue(tonumber(self:GetValue())+delta)
	end)
	AAP.OptionsFrame.ArrowScaleSlider:SetValue(AAP1[AAP.Realm][AAP.Name]["Settings"]["ArrowScale"] * 100)
------------------------- General Options --------------------------------------------------------------------------
	AAP.OptionsFrame.MainFrame.OptionsB3 = CreateFrame("frame", "AAP_OptionsMainFrame_GeneralOptions",  AAP_OptionsMainFrame)
	AAP.OptionsFrame.MainFrame.OptionsB3:SetWidth(150)
	AAP.OptionsFrame.MainFrame.OptionsB3:SetHeight(30)
	AAP.OptionsFrame.MainFrame.OptionsB3:SetFrameStrata("HIGH")
	AAP.OptionsFrame.MainFrame.OptionsB3:SetPoint("TOPLEFT",  AAP_OptionsMainFrame, "TOPLEFT",0,-100)
	AAP.OptionsFrame.MainFrame.OptionsB3:SetMovable(true)
	AAP.OptionsFrame.MainFrame.OptionsB3:EnableMouse(true)
	AAP.OptionsFrame.MainFrame.OptionsB3:SetBackdrop( { 
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 10, edgeSize = 10, insets = { left = 2, right = 2, top = 2, bottom = 2 }
	});
	AAP.OptionsFrame.MainFrame.OptionsB3:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			AAP.OptionsFrame.MainFrame.OptionsQuests:Hide()
			AAP.OptionsFrame.MainFrame.OptionsArrow:Hide()
			AAP.OptionsFrame.MainFrame.OptionsGeneral:Show()
		end
	end)
	AAP.OptionsFrame.MainFrame.OptionsB3:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" and AAP.OptionsFrame.MainFrame.isMoving then
			AAP.OptionsFrame.MainFrame:StopMovingOrSizing();
			AAP.OptionsFrame.MainFrame.isMoving = false;
		end
	end)
	AAP.OptionsFrame.MainFrame.OptionsB3:SetScript("OnHide", function(self)
		if ( AAP.OptionsFrame.MainFrame.isMoving ) then
			AAP.OptionsFrame.MainFrame:StopMovingOrSizing();
			AAP.OptionsFrame.MainFrame.isMoving = false;
		end
	end)
	AAP.OptionsFrame.MainFrame.OptionsB3.FontString = AAP.OptionsFrame.MainFrame:CreateFontString("AAP_OptionsB3FS1","ARTWORK", "ChatFontNormal")
	AAP.OptionsFrame.MainFrame.OptionsB3.FontString:SetParent(AAP.OptionsFrame.MainFrame.OptionsB3)
	AAP.OptionsFrame.MainFrame.OptionsB3.FontString:SetPoint("CENTER",AAP.OptionsFrame.MainFrame.OptionsB3,"CENTER",0,0)
	AAP.OptionsFrame.MainFrame.OptionsB3.FontString:SetWidth(240)
	AAP.OptionsFrame.MainFrame.OptionsB3.FontString:SetHeight(20)
	AAP.OptionsFrame.MainFrame.OptionsB3.FontString:SetFontObject("GameFontHighlightLarge")
	AAP.OptionsFrame.MainFrame.OptionsB3.FontString:SetText("General Options")
	AAP.OptionsFrame.MainFrame.OptionsB3.FontString:SetTextColor(1, 1, 0)

	AAP.OptionsFrame.MainFrame.OptionsGeneral = CreateFrame("frame", "AAP_OptionsMainFrame_General",  AAP_OptionsMainFrame)
	AAP.OptionsFrame.MainFrame.OptionsGeneral:SetWidth(295)
	AAP.OptionsFrame.MainFrame.OptionsGeneral:SetHeight(320)
	AAP.OptionsFrame.MainFrame.OptionsGeneral:SetFrameStrata("MEDIUM")
	AAP.OptionsFrame.MainFrame.OptionsGeneral:SetPoint("LEFT",  AAP_OptionsMainFrame, "LEFT",155,-20)
	AAP.OptionsFrame.MainFrame.OptionsGeneral:SetMovable(true)
	AAP.OptionsFrame.MainFrame.OptionsGeneral:EnableMouse(true)
	AAP.OptionsFrame.MainFrame.OptionsGeneral:SetBackdrop( { 
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 10, edgeSize = 10, insets = { left = 2, right = 2, top = 2, bottom = 2 }
	});
	AAP.OptionsFrame.MainFrame.OptionsGeneral:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" and not AAP.OptionsFrame.MainFrame.isMoving then
			AAP.OptionsFrame.MainFrame:StartMoving();
			AAP.OptionsFrame.MainFrame.isMoving = true;
		end
	end)
	AAP.OptionsFrame.MainFrame.OptionsGeneral:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" and AAP.OptionsFrame.MainFrame.isMoving then
			AAP.OptionsFrame.MainFrame:StopMovingOrSizing();
			AAP.OptionsFrame.MainFrame.isMoving = false;
		end
	end)
	AAP.OptionsFrame.MainFrame.OptionsGeneral:SetScript("OnHide", function(self)
		if ( AAP.OptionsFrame.MainFrame.isMoving ) then
			AAP.OptionsFrame.MainFrame:StopMovingOrSizing();
			AAP.OptionsFrame.MainFrame.isMoving = false;
		end
	end)
	AAP.OptionsFrame.MainFrame.OptionsGeneral:Hide()
	AAP.OptionsFrame.CutSceneCheckButton = CreateFrame("CheckButton", "AAP_CutSceneCheckButton", AAP.OptionsFrame.MainFrame.OptionsGeneral, "ChatConfigCheckButtonTemplate");
	AAP.OptionsFrame.CutSceneCheckButton:SetPoint("TOPLEFT", AAP.OptionsFrame.MainFrame.OptionsGeneral, "TOPLEFT", 10, -10)
	if (AAP1[AAP.Realm][AAP.Name]["Settings"]["CutScene"] == 0) then
		AAP.OptionsFrame.CutSceneCheckButton:SetChecked(false)
	else
		AAP.OptionsFrame.CutSceneCheckButton:SetChecked(true)
	end
	getglobal(AAP.OptionsFrame.CutSceneCheckButton:GetName() .. 'Text'):SetText(": "..AAP_Locals["Skipped cutscene"])
	getglobal(AAP.OptionsFrame.CutSceneCheckButton:GetName() .. 'Text'):SetTextColor(1, 1, 1)
	AAP.OptionsFrame.CutSceneCheckButton:SetScript("OnClick", function()
		if (AAP.OptionsFrame.CutSceneCheckButton:GetChecked() == true) then
			AAP1[AAP.Realm][AAP.Name]["Settings"]["CutScene"] = 1
		else
			AAP1[AAP.Realm][AAP.Name]["Settings"]["CutScene"] = 0
		end
	end)
	AAP.OptionsFrame.AutoVendorCheckButton = CreateFrame("CheckButton", "AAP_AutoVendorCheckButton", AAP.OptionsFrame.MainFrame.OptionsGeneral, "ChatConfigCheckButtonTemplate");
	AAP.OptionsFrame.AutoVendorCheckButton:SetPoint("TOPLEFT", AAP.OptionsFrame.MainFrame.OptionsGeneral, "TOPLEFT", 10, -30)
	if (AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoVendor"] == 0) then
		AAP.OptionsFrame.AutoVendorCheckButton:SetChecked(false)
	else
		AAP.OptionsFrame.AutoVendorCheckButton:SetChecked(true)
	end
	getglobal(AAP.OptionsFrame.AutoVendorCheckButton:GetName() .. 'Text'):SetText(": "..AAP_Locals["AutoVendor"])
	getglobal(AAP.OptionsFrame.AutoVendorCheckButton:GetName() .. 'Text'):SetTextColor(1, 1, 1)
	AAP.OptionsFrame.AutoVendorCheckButton:SetScript("OnClick", function()
		if (AAP.OptionsFrame.AutoVendorCheckButton:GetChecked() == true) then
			AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoVendor"] = 1
		else
			AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoVendor"] = 0
		end
	end)
	AAP.OptionsFrame.AutoRepairCheckButton = CreateFrame("CheckButton", "AAP_AutoRepairCheckButton", AAP.OptionsFrame.MainFrame.OptionsGeneral, "ChatConfigCheckButtonTemplate");
	AAP.OptionsFrame.AutoRepairCheckButton:SetPoint("TOPLEFT", AAP.OptionsFrame.MainFrame.OptionsGeneral, "TOPLEFT", 10, -50)
	if (AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoRepair"] == 0) then
		AAP.OptionsFrame.AutoRepairCheckButton:SetChecked(false)
	else
		AAP.OptionsFrame.AutoRepairCheckButton:SetChecked(true)
	end
	getglobal(AAP.OptionsFrame.AutoRepairCheckButton:GetName() .. 'Text'):SetText(": "..AAP_Locals["AutoRepair"])
	getglobal(AAP.OptionsFrame.AutoRepairCheckButton:GetName() .. 'Text'):SetTextColor(1, 1, 1)
	AAP.OptionsFrame.AutoRepairCheckButton:SetScript("OnClick", function()
		if (AAP.OptionsFrame.AutoRepairCheckButton:GetChecked() == true) then
			AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoRepair"] = 1
		else
			AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoRepair"] = 0
		end
	end)
	AAP.OptionsFrame.ShowGroupCheckButton = CreateFrame("CheckButton", "AAP_ShowGroupCheckButton", AAP.OptionsFrame.MainFrame.OptionsGeneral, "ChatConfigCheckButtonTemplate");
	AAP.OptionsFrame.ShowGroupCheckButton:SetPoint("TOPLEFT", AAP.OptionsFrame.MainFrame.OptionsGeneral, "TOPLEFT", 10, -70)
	if (AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowGroup"] == 0) then
		AAP.OptionsFrame.ShowGroupCheckButton:SetChecked(false)
	else
		AAP.OptionsFrame.ShowGroupCheckButton:SetChecked(true)
	end
	getglobal(AAP.OptionsFrame.ShowGroupCheckButton:GetName() .. 'Text'):SetText(": "..AAP_Locals["ShowGroup"])
	getglobal(AAP.OptionsFrame.ShowGroupCheckButton:GetName() .. 'Text'):SetTextColor(1, 1, 1)
	AAP.OptionsFrame.ShowGroupCheckButton:SetScript("OnClick", function()
		if (AAP.OptionsFrame.ShowGroupCheckButton:GetChecked() == true) then
			AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowGroup"] = 1
		else
			AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowGroup"] = 0
		end
	end)
	AAP.OptionsFrame.AutoGossipCheckButton = CreateFrame("CheckButton", "AAP_AutoGossipCheckButton", AAP.OptionsFrame.MainFrame.OptionsGeneral, "ChatConfigCheckButtonTemplate");
	AAP.OptionsFrame.AutoGossipCheckButton:SetPoint("TOPLEFT", AAP.OptionsFrame.MainFrame.OptionsGeneral, "TOPLEFT", 10, -90)
	if (AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoGossip"] == 0) then
		AAP.OptionsFrame.AutoGossipCheckButton:SetChecked(false)
	else
		AAP.OptionsFrame.AutoGossipCheckButton:SetChecked(true)
	end
	getglobal(AAP.OptionsFrame.AutoGossipCheckButton:GetName() .. 'Text'):SetText(": "..AAP_Locals["Auto-selection of dialog"])
	getglobal(AAP.OptionsFrame.AutoGossipCheckButton:GetName() .. 'Text'):SetTextColor(1, 1, 1)
	AAP.OptionsFrame.AutoGossipCheckButton:SetScript("OnClick", function()
		if (AAP.OptionsFrame.AutoGossipCheckButton:GetChecked() == true) then
			AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoGossip"] = 1
		else
			AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoGossip"] = 0
		end
	end)
	AAP.OptionsFrame.BannerShowCheckButton = CreateFrame("CheckButton", "AAP_BannerShowCheckButton", AAP.OptionsFrame.MainFrame.OptionsGeneral, "ChatConfigCheckButtonTemplate");
	AAP.OptionsFrame.BannerShowCheckButton:SetPoint("TOPLEFT", AAP.OptionsFrame.MainFrame.OptionsGeneral, "TOPLEFT", 10, -110)
	if (AAP1[AAP.Realm][AAP.Name]["Settings"]["BannerShow"] == 0) then
		AAP.OptionsFrame.BannerShowCheckButton:SetChecked(false)
	else
		AAP.OptionsFrame.BannerShowCheckButton:SetChecked(true)
	end
	getglobal(AAP.OptionsFrame.BannerShowCheckButton:GetName() .. 'Text'):SetText(": "..AAP_Locals["BannerShow"])
	getglobal(AAP.OptionsFrame.BannerShowCheckButton:GetName() .. 'Text'):SetTextColor(1, 1, 1)
	AAP.OptionsFrame.BannerShowCheckButton:SetScript("OnClick", function()
		if (AAP.OptionsFrame.BannerShowCheckButton:GetChecked() == true) then
			AAP1[AAP.Realm][AAP.Name]["Settings"]["BannerShow"] = 1
			AAP.Banners.BannersFrame.Frame:Show()
		else
			AAP1[AAP.Realm][AAP.Name]["Settings"]["BannerShow"] = 0
			AAP.Banners.BannersFrame.Frame:Hide()
		end
	end)
	AAP.OptionsFrame.BannerScaleSlider = CreateFrame("Slider", "AAP_BannerScaleSlider",AAP.OptionsFrame.MainFrame.OptionsGeneral, "OptionsSliderTemplate")
	AAP.OptionsFrame.BannerScaleSlider:SetWidth(160)
	AAP.OptionsFrame.BannerScaleSlider:SetHeight(15)
	AAP.OptionsFrame.BannerScaleSlider:SetPoint("TOPLEFT", AAP.OptionsFrame.MainFrame.OptionsGeneral, "TOPLEFT", 20, -150)
	AAP.OptionsFrame.BannerScaleSlider:SetOrientation("HORIZONTAL")
	AAP.OptionsFrame.BannerScaleSlider:SetMinMaxValues(1, 200)
	AAP.OptionsFrame.BannerScaleSlider.minValue, AAP.OptionsFrame.BannerScaleSlider.maxValue = AAP.OptionsFrame.BannerScaleSlider:GetMinMaxValues() 
	getglobal(AAP.OptionsFrame.BannerScaleSlider:GetName() .. 'Low'):SetText("1%")
	getglobal(AAP.OptionsFrame.BannerScaleSlider:GetName() .. 'High'):SetText("200%")
	getglobal(AAP.OptionsFrame.BannerScaleSlider:GetName() .. 'Text'):SetText(AAP_Locals["BannerScale"])
	AAP.OptionsFrame.BannerScaleSlider:SetValueStep(1)
	AAP.OptionsFrame.BannerScaleSlider:SetValue(100)
	AAP.OptionsFrame.BannerScaleSlider:SetScript("OnValueChanged", function(self,event) 
		event = event - event%1
		AAP1[AAP.Realm][AAP.Name]["Settings"]["BannerScale"] = event / 100
		AAP.Banners.BannersFrame.Frame:SetScale(AAP1[AAP.Realm][AAP.Name]["Settings"]["BannerScale"])
		AAP.Banners.BannersFrame["Frame1"]:SetScale(AAP1[AAP.Realm][AAP.Name]["Settings"]["BannerScale"])
		AAP.Banners.BannersFrame["Frame2"]:SetScale(AAP1[AAP.Realm][AAP.Name]["Settings"]["BannerScale"])
		AAP.Banners.BannersFrame["Frame3"]:SetScale(AAP1[AAP.Realm][AAP.Name]["Settings"]["BannerScale"])
		AAP.Banners.BannersFrame["Frame4"]:SetScale(AAP1[AAP.Realm][AAP.Name]["Settings"]["BannerScale"])
	end)
	AAP.OptionsFrame.BannerScaleSlider:SetScript("OnMouseWheel", function(self,delta) 
		if tonumber(self:GetValue()) == nil then return end
		self:SetValue(tonumber(self:GetValue())+delta)
	end)
	AAP.OptionsFrame.BannerScaleSlider:SetValue(AAP1[AAP.Realm][AAP.Name]["Settings"]["BannerScale"] * 100)








	AAP.OptionsFrame["Button1"] = CreateFrame("Button", "AAP_OptionsButtons1", AAP.OptionsFrame.MainFrame, "SecureActionButtonTemplate")
	AAP.OptionsFrame["Button1"]:SetPoint("BOTTOMRIGHT",AAP.OptionsFrame.MainFrame,"BOTTOMRIGHT",-5,5)
	AAP.OptionsFrame["Button1"]:SetWidth(70)
	AAP.OptionsFrame["Button1"]:SetHeight(30)
	AAP.OptionsFrame["Button1"]:SetText("Close")
	AAP.OptionsFrame["Button1"]:SetParent(AAP.OptionsFrame.MainFrame)
	AAP.OptionsFrame.Button1:SetNormalFontObject("GameFontNormal")
	AAP.OptionsFrame.Button1ntex = AAP.OptionsFrame.Button1:CreateTexture()
	AAP.OptionsFrame.Button1ntex:SetTexture("Interface/Buttons/UI-Panel-Button-Up")
	AAP.OptionsFrame.Button1ntex:SetTexCoord(0, 0.625, 0, 0.6875)
	AAP.OptionsFrame.Button1ntex:SetAllPoints()	
	AAP.OptionsFrame.Button1:SetNormalTexture(AAP.OptionsFrame.Button1ntex)
	AAP.OptionsFrame.Button1htex = AAP.OptionsFrame.Button1:CreateTexture()
	AAP.OptionsFrame.Button1htex:SetTexture("Interface/Buttons/UI-Panel-Button-Highlight")
	AAP.OptionsFrame.Button1htex:SetTexCoord(0, 0.625, 0, 0.6875)
	AAP.OptionsFrame.Button1htex:SetAllPoints()
	AAP.OptionsFrame.Button1:SetHighlightTexture(AAP.OptionsFrame.Button1htex)
	AAP.OptionsFrame.Button1ptex = AAP.OptionsFrame.Button1:CreateTexture()
	AAP.OptionsFrame.Button1ptex:SetTexture("Interface/Buttons/UI-Panel-Button-Down")
	AAP.OptionsFrame.Button1ptex:SetTexCoord(0, 0.625, 0, 0.6875)
	AAP.OptionsFrame.Button1ptex:SetAllPoints()
	AAP.OptionsFrame.Button1:SetPushedTexture(AAP.OptionsFrame.Button1ptex)
	AAP.OptionsFrame["Button1"]:SetScript("OnClick", function(self, arg1)
		AAP.OptionsFrame.MainFrame:Hide()
		AAP.SettingsOpen = 0
		AAP.BookingList["ClosedSettings"] = 1
	end)



	AAP.OptionsFrame["Button2"] = CreateFrame("Button", "AAP_OptionsButtons2", AAP.OptionsFrame.MainFrame, "SecureActionButtonTemplate")
	AAP.OptionsFrame["Button2"]:SetPoint("BOTTOMRIGHT",AAP.OptionsFrame.MainFrame,"BOTTOMRIGHT",-185,5)
	AAP.OptionsFrame["Button2"]:SetWidth(100)
	AAP.OptionsFrame["Button2"]:SetHeight(30)
	AAP.OptionsFrame["Button2"]:SetText(AAP_Locals["Keybinds"])
	AAP.OptionsFrame["Button2"]:SetParent(AAP.OptionsFrame.MainFrame)
	AAP.OptionsFrame.Button2:SetNormalFontObject("GameFontNormal")
	AAP.OptionsFrame.Button2ntex = AAP.OptionsFrame.Button2:CreateTexture()
	AAP.OptionsFrame.Button2ntex:SetTexture("Interface/Buttons/UI-Panel-Button-Up")
	AAP.OptionsFrame.Button2ntex:SetTexCoord(0, 0.625, 0, 0.6875)
	AAP.OptionsFrame.Button2ntex:SetAllPoints()	
	AAP.OptionsFrame.Button2:SetNormalTexture(AAP.OptionsFrame.Button2ntex)
	AAP.OptionsFrame.Button2htex = AAP.OptionsFrame.Button2:CreateTexture()
	AAP.OptionsFrame.Button2htex:SetTexture("Interface/Buttons/UI-Panel-Button-Highlight")
	AAP.OptionsFrame.Button2htex:SetTexCoord(0, 0.625, 0, 0.6875)
	AAP.OptionsFrame.Button2htex:SetAllPoints()
	AAP.OptionsFrame.Button2:SetHighlightTexture(AAP.OptionsFrame.Button2htex)
	AAP.OptionsFrame.Button2ptex = AAP.OptionsFrame.Button2:CreateTexture()
	AAP.OptionsFrame.Button2ptex:SetTexture("Interface/Buttons/UI-Panel-Button-Down")
	AAP.OptionsFrame.Button2ptex:SetTexCoord(0, 0.625, 0, 0.6875)
	AAP.OptionsFrame.Button2ptex:SetAllPoints()
	AAP.OptionsFrame.Button2:SetPushedTexture(AAP.OptionsFrame.Button2ptex)
	AAP.OptionsFrame["Button2"]:SetScript("OnClick", function(self, arg1)
		KeyBindingFrame_LoadUI()
		KeyBindingFrame:Show()
	end)

	AAP.OptionsFrame["Button3"] = CreateFrame("Button", "AAP_OptionsButtons3", AAP.OptionsFrame.MainFrame, "SecureActionButtonTemplate")
	AAP.OptionsFrame["Button3"]:SetPoint("BOTTOMRIGHT",AAP.OptionsFrame.MainFrame,"BOTTOMRIGHT",-90,5)
	AAP.OptionsFrame["Button3"]:SetWidth(70)
	AAP.OptionsFrame["Button3"]:SetHeight(30)
	AAP.OptionsFrame["Button3"]:SetText("Reset")
	AAP.OptionsFrame["Button3"]:SetParent(AAP.OptionsFrame.MainFrame)
	AAP.OptionsFrame.Button3:SetNormalFontObject("GameFontNormal")
	AAP.OptionsFrame.Button3ntex = AAP.OptionsFrame.Button3:CreateTexture()
	AAP.OptionsFrame.Button3ntex:SetTexture("Interface/Buttons/UI-Panel-Button-Up")
	AAP.OptionsFrame.Button3ntex:SetTexCoord(0, 0.625, 0, 0.6875)
	AAP.OptionsFrame.Button3ntex:SetAllPoints()	
	AAP.OptionsFrame.Button3:SetNormalTexture(AAP.OptionsFrame.Button3ntex)
	AAP.OptionsFrame.Button3htex = AAP.OptionsFrame.Button3:CreateTexture()
	AAP.OptionsFrame.Button3htex:SetTexture("Interface/Buttons/UI-Panel-Button-Highlight")
	AAP.OptionsFrame.Button3htex:SetTexCoord(0, 0.625, 0, 0.6875)
	AAP.OptionsFrame.Button3htex:SetAllPoints()
	AAP.OptionsFrame.Button3:SetHighlightTexture(AAP.OptionsFrame.Button3htex)
	AAP.OptionsFrame.Button3ptex = AAP.OptionsFrame.Button3:CreateTexture()
	AAP.OptionsFrame.Button3ptex:SetTexture("Interface/Buttons/UI-Panel-Button-Down")
	AAP.OptionsFrame.Button3ptex:SetTexCoord(0, 0.625, 0, 0.6875)
	AAP.OptionsFrame.Button3ptex:SetAllPoints()
	AAP.OptionsFrame.Button3:SetPushedTexture(AAP.OptionsFrame.Button3ptex)
	AAP.OptionsFrame["Button3"]:SetScript("OnClick", function(self, arg1)
		AAP.ResetSettings()
	end)



end



