local QNumberLocal = 0
local AAP_ArrowUpdateNr = 0
local ETAStep = 0
local AAP_AntiTaxiLoop = 0
local HBDP = LibStub("HereBeDragons-Pins-2.0")
local HBD = LibStub("HereBeDragons-2.0")
AAP.HBDP = HBDP
AAP.HBD = HBD
local AAP_BonusObj = {
---- Legion Bonus Obj ----
	[36811] = 1,
	[37466] = 1,
	[37779] = 1,
	[37965] = 1,
	[37963] = 1,
	[37495] = 1,
	[39393] = 1,
	[38842] = 1,
---- Duskwood ----
	[26623] = 1,
---- Hillsbrad Foothills ----
	[28489] = 1,
---- BFA Bonus Obj ----
	[50009] = 1,
	[50080] = 1,
	[50448] = 1,
	[50133] = 1,
	[51534] = 1,
	[50779] = 1,
	[49739] = 1,
	[51689] = 1,
	[50497] = 1,
	[48093] = 1,
	[47996] = 1,
	[48934] = 1,
	[49315] = 1,
	[48852] = 1,
	[49406] = 1,
	[48588] = 1,
	[47756] = 1,
	[49529] = 1,
	[49300] = 1,
	[47797] = 1,
	[49315] = 1,
	[50178] = 1,
	[49918] = 1,
	[47527] = 1,
	[47647] = 1,
	[51900] = 1,
	[50805] = 1,
	[48474] = 1,
	[48525] = 1,
	[45972] = 1,
	[47969] = 1,
	[48181] = 1,
	[48680] = 1,
	[50091] = 1,
}
local MapRects = {};
local TempVec2D = CreateVector2D(0,0);
local function GetPlayerMapPos(MapID, dx, dy)
    local R,P,_ = MapRects[MapID],TempVec2D;
    if not R then
        R = {};
        _, R[1] = C_Map.GetWorldPosFromMapPos(MapID,CreateVector2D(0,0));
        _, R[2] = C_Map.GetWorldPosFromMapPos(MapID,CreateVector2D(1,1));
        R[2]:Subtract(R[1]);
        MapRects[MapID] = R;
    end
	if (dx) then
		P.x, P.y = dx, dy
	else
		P.x, P.y = UnitPosition('Player');
	end
    P:Subtract(R[1]);
    return (1/R[2].y)*P.y, (1/R[2].x)*P.x;
end
function AAP.RemoveIcons()
	for CLi = 1, 20 do
		if (AAP["Icons"][CLi].A == 1) then
			AAP["Icons"][CLi].A = 0
			AAP["Icons"][CLi].P = 0
			AAP["Icons"][CLi].D = 0
			AAP.HBDP:RemoveMinimapIcon("AAP", AAP["Icons"][CLi])
		end
	end
end
function AAP:MoveIcons()
	if (IsInInstance()) then
		AAP.RemoveIcons()
		return
	end
	local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
	local ix, iy
	if (AAP.SettingsOpen == 1) then
		ix, iy = GetPlayerMapPos(C_Map.GetBestMapForUnit('player'), AAP.ArrowActive_Y, AAP.ArrowActive_X)
	elseif (CurStep and AAP.ActiveMap and AAP.QuestStepList[AAP.ActiveMap] and AAP.QuestStepList[AAP.ActiveMap][CurStep]) then
		local steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
		if (steps and steps["TT"]) then
			ix, iy = GetPlayerMapPos(C_Map.GetBestMapForUnit('player'), steps["TT"]["y"],steps["TT"]["x"])
		else
			return
		end
	else
		return
	end
	local steps
	if (AAP.SettingsOpen == 1) then
		steps = {}
		steps["TT"] = {}
		steps["TT"]["y"] = AAP.ArrowActive_Y
		steps["TT"]["x"] = AAP.ArrowActive_X
	else
		steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
	end
	if (steps["CRange"]) then
		local CLi
		local totalCR = 1
		if (AAP.QuestStepList[AAP.ActiveMap][CurStep+1] and AAP.QuestStepList[AAP.ActiveMap][CurStep+1]["CRange"]) then
			totalCR = 3
		end
		local px, py = GetPlayerMapPos(C_Map.GetBestMapForUnit('player'))
		local CLi, CLi2
		for CLi = 1, 20 do
			local px2, py2
			px2 = px - ix
			py2 = py - iy
			if (AAP["Icons"][CLi]["A"] == 1 and (AAP["Icons"][CLi]["D"] == 0 or AAP["Icons"][CLi]["D"] == 1)) then
				AAP["Icons"][CLi]["P"] = AAP["Icons"][CLi]["P"] + 0.02
				local test = 0.2
				if (AAP["Icons"][CLi]["P"] > 0.399 and AAP["Icons"][CLi]["P"] < 0.409) then
					local set = 0
					for CLi2 = 1, 20 do
						if (set == 0 and AAP["Icons"][CLi2]["A"] == 0) then
							AAP["Icons"][CLi2]["A"] = 1
							AAP["Icons"][CLi2]["D"] = 1
							set = 1
						end
					end
				end
				if (AAP["Icons"][CLi].P < 1) then
					px2 = px - px2 * AAP["Icons"][CLi]["P"]
					py2 = py - py2 * AAP["Icons"][CLi]["P"]
					AAP["Icons"][CLi]["D"] = 1
					AAP.HBDP:AddMinimapIconMap("AAP", AAP["Icons"][CLi], C_Map.GetBestMapForUnit('player'), px2, py2, true, true)
				else
					AAP["Icons"][CLi]["A"] = 1
					AAP["Icons"][CLi]["P"] = 0
					AAP["Icons"][CLi]["D"] = 2
					AAP.HBDP:RemoveMinimapIcon("AAP", AAP["Icons"][CLi])
				end
			end
		end
		local px, py = GetPlayerMapPos(C_Map.GetBestMapForUnit('player'), AAP.QuestStepList[AAP.ActiveMap][CurStep]["TT"]["y"],AAP.QuestStepList[AAP.ActiveMap][CurStep]["TT"]["x"])
		local CLi, CLi2
		local ix, iy = GetPlayerMapPos(C_Map.GetBestMapForUnit('player'), AAP.QuestStepList[AAP.ActiveMap][CurStep+1]["TT"]["y"],AAP.QuestStepList[AAP.ActiveMap][CurStep+1]["TT"]["x"])
		for CLi = 1, 20 do
			local px2, py2
			px2 = px - ix
			py2 = py - iy
			if (AAP["Icons"][CLi]["A"] == 1 and (AAP["Icons"][CLi]["D"] == 0 or AAP["Icons"][CLi]["D"] == 2)) then
				AAP["Icons"][CLi]["P"] = AAP["Icons"][CLi]["P"] + 0.02
				local test = 0.2

				if (AAP["Icons"][CLi].P < 1) then
					px2 = px - px2 * AAP["Icons"][CLi]["P"]
					py2 = py - py2 * AAP["Icons"][CLi]["P"]
					AAP["Icons"][CLi]["D"] = 2
					AAP.HBDP:AddMinimapIconMap("AAP", AAP["Icons"][CLi], C_Map.GetBestMapForUnit('player'), px2, py2, true, true)
				else
					AAP["Icons"][CLi]["A"] = 0
					AAP["Icons"][CLi]["P"] = 0
					if (totalCR == 3) then
						AAP["Icons"][CLi]["A"] = 1
						AAP["Icons"][CLi]["D"] = 3
					elseif (totalCR == 2) then
						AAP["Icons"][CLi]["D"] = 1
					elseif (totalCR == 1) then
						AAP["Icons"][CLi]["D"] = 1
					end
					AAP.HBDP:RemoveMinimapIcon("AAP", AAP["Icons"][CLi])
				end
			end
		end
		if (totalCR == 3) then
			local px, py = GetPlayerMapPos(C_Map.GetBestMapForUnit('player'), AAP.QuestStepList[AAP.ActiveMap][CurStep+1]["TT"]["y"],AAP.QuestStepList[AAP.ActiveMap][CurStep+1]["TT"]["x"])
			local CLi, CLi2
			local ix, iy = GetPlayerMapPos(C_Map.GetBestMapForUnit('player'), AAP.QuestStepList[AAP.ActiveMap][CurStep+2]["TT"]["y"],AAP.QuestStepList[AAP.ActiveMap][CurStep+2]["TT"]["x"])
			for CLi = 1, 20 do
				local px2, py2
				px2 = px - ix
				py2 = py - iy
				if (AAP["Icons"][CLi]["A"] == 1 and (AAP["Icons"][CLi]["D"] == 0 or AAP["Icons"][CLi]["D"] == 3)) then
					AAP["Icons"][CLi]["P"] = AAP["Icons"][CLi]["P"] + 0.02
					local test = 0.2

					if (AAP["Icons"][CLi].P < 1) then
						px2 = px - px2 * AAP["Icons"][CLi]["P"]
						py2 = py - py2 * AAP["Icons"][CLi]["P"]
						AAP["Icons"][CLi]["D"] = 3
						AAP.HBDP:AddMinimapIconMap("AAP", AAP["Icons"][CLi], C_Map.GetBestMapForUnit('player'), px2, py2, true, true)
					else
						AAP["Icons"][CLi]["A"] = 0
						AAP["Icons"][CLi]["P"] = 0
						AAP["Icons"][CLi]["D"] = 0
						AAP.HBDP:RemoveMinimapIcon("AAP", AAP["Icons"][CLi])
					end
				end
			end
		end
	else
		local px, py = GetPlayerMapPos(C_Map.GetBestMapForUnit('player'))
		local CLi, CLi2
		for CLi = 1, 20 do
			local px2, py2
			px2 = px - ix
			py2 = py - iy
			if (AAP["Icons"][CLi]["A"] == 1) then
				AAP["Icons"][CLi]["P"] = AAP["Icons"][CLi]["P"] + 0.02
				local test = 0.2
				if (AAP["Icons"][CLi]["P"] > 0.39 and AAP["Icons"][CLi]["P"] < 0.41) then
					local set = 0
					for CLi2 = 1, 20 do
						if (set == 0 and AAP["Icons"][CLi2]["A"] == 0) then
							AAP["Icons"][CLi2]["A"] = 1
							set = 1
						end
					end
				end
				if (AAP["Icons"][CLi].P < 1) then
					px2 = px - px2 * AAP["Icons"][CLi]["P"]
					py2 = py - py2 * AAP["Icons"][CLi]["P"]
					AAP.HBDP:AddMinimapIconMap("AAP", AAP["Icons"][CLi], C_Map.GetBestMapForUnit('player'), px2, py2, true, true)
				else
					AAP["Icons"][CLi]["A"] = 0
					AAP["Icons"][CLi]["P"] = 0
					AAP.HBDP:RemoveMinimapIcon("AAP", AAP["Icons"][CLi])
				end
			end
		end
	end
end
AAP.DubbleMacro = {}
AAP.ButtonList = {}
AAP.SetButtonVar = nil
AAP.ButtonVisual = nil
local function AAP_LeaveQuest(QuestIDs)
	local tempa = 0
	for j=1, GetNumQuestLogEntries() do
		local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID = GetQuestLogTitle(j)
		if (QuestIDs == questID and not isHeader) then
			SelectQuestLogEntry(j)
			SetAbandonQuest()
			tempa = 1
		end
	end
	if (tempa == 1) then
		AbandonQuest()
	end
end
local function AAP_ExitVhicle()
	VehicleExit()
end
local function AAP_TaxiSearchFunc(AAPMrX, AAPMrY)
	AAPMrX = floor(AAPMrX + 0.5)
	AAPMrY = floor(AAPMrY + 0.5)
	local CLi
	for CLi = 1, NumTaxiNodes() do
		if (TaxiNodeGetType(CLi) == "REACHABLE") then
			local aapx,aapy = TaxiNodePosition(CLi)
			aapx = floor((floor(aapx * 1000)/10)+0.5)
			aapy = floor((floor(aapy * 1000)/10)+0.5)
			if (tonumber(AAPMrX) == tonumber(aapx) and tonumber(AAPMrY) == tonumber(aapy)) then
				return CLi
			end
		end
	end

end
local function AAP_UseTaxiFunc()
	local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
	local steps
	if (CurStep and AAP.ActiveMap and AAP.QuestStepList and AAP.QuestStepList[AAP.ActiveMap] and AAP.QuestStepList[AAP.ActiveMap][CurStep]) then
		steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
	end
	if (steps["ETA"]) then
		AAP.AFK_Timer(steps["ETA"])
	end
	local Nodetotake = AAP_TaxiSearchFunc(steps["PosX"], steps["PosY"])
--	TaxiNodeOnButtonEnter(getglobal("TaxiButton"..Nodetotake))
	TakeTaxiNode(Nodetotake)
	AAP.BookingList["TestTaxiFunc"] = Nodetotake
end
local function AAP_QAskPopWanted()
	local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
	local steps
	if (CurStep and AAP.ActiveMap and AAP.QuestStepList and AAP.QuestStepList[AAP.ActiveMap] and AAP.QuestStepList[AAP.ActiveMap][CurStep]) then
		steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
	end
	local Qid = steps["QaskPopup"]
	if (IsQuestFlaggedCompleted(Qid) == true) then
		AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
		AAP.BookingList["PrintQStep"] = 1
		AAP.QuestList.SugQuestFrame:Hide()
	elseif (steps["QuestLineSkip"] and AAP1[AAP.Realm][AAP.Name]["QlineSkip"][steps["QuestLineSkip"]] and AAP1[AAP.Realm][AAP.Name]["QlineSkip"][steps["QuestLineSkip"]] == 0) then
		AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
		AAP.BookingList["PrintQStep"] = 1
	else
		local SugGroupNr = steps["Group"]
		AAP.QuestList.SugQuestFrameFS1:SetText(AAP_Locals["Optional"])
		AAP.QuestList.SugQuestFrameFS2:SetText(AAP_Locals["Suggested Players"]..": "..SugGroupNr)
		AAP.QuestList.SugQuestFrame:Show()
	end
end
function AAP.QAskPopWantedAsk(AAP_answer)
	local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
	local steps
	if (CurStep and AAP.ActiveMap and AAP.QuestStepList and AAP.QuestStepList[AAP.ActiveMap] and AAP.QuestStepList[AAP.ActiveMap][CurStep]) then
		steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
	end
	if (AAP_answer == "yes") then
		AAP1[AAP.Realm][AAP.Name]["WantedQuestList"][steps["QaskPopup"]] = 1
		AAP.QuestList.SugQuestFrame:Hide()
		AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
		AAP.BookingList["PrintQStep"] = 1
	else
		AAP.QuestList.SugQuestFrame:Hide()
		AAP1[AAP.Realm][AAP.Name]["WantedQuestList"][steps["QaskPopup"]] = 0
		AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
		AAP.BookingList["PrintQStep"] = 1
	end
end
local function AAP_PrintQStep()
	if (AAP.InCombat == 1) then
		AAP.BookUpdAfterCombat = 1
	end
	local CLi
	for CLi = 1, 10 do
		if (AAP.QuestList.QuestFrames[CLi]:IsShown()) then
			AAP.QuestList.QuestFrames[CLi]:Hide()
		end
		if (not InCombatLockdown()) then
			if (AAP.QuestList.QuestFrames["FS"..CLi]["Button"]:IsShown()) then
				AAP.QuestList.QuestFrames["FS"..CLi]["Button"]:Hide()
			end
			if (AAP.QuestList2["BF"..CLi]:IsShown()) then
				AAP.QuestList2["BF"..CLi]:Hide()
			end
		end
	end
	local LineNr = 0
	local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
	-- Extra liners here
	local MissingQs = {}
	if (AAP.Level ~= UnitLevel("player")) then
		AAP.BookingList["UpdateMapId"] = 1
		AAP.BookingList["PrintQStep"] = 1
		AAP.Level = UnitLevel("player")
	end
	if (AAP1["Debug"]) then
		print("AAP_PrintQStep() Step:".. CurStep)
	end
	if (AAP.SettingsOpen == 1) then
		if (AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowQList"] == 0) then
			return
		end
		LineNr = LineNr + 1
		AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Test Quest number 1")
		AAP.QuestList.QuestFrames[LineNr]:Show()
		AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
		local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
		if (aapwidth and aapwidth > 400) then
			AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
		else
			AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
		end
		LineNr = LineNr + 1
		AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Test Quest number 2")
		AAP.QuestList.QuestFrames[LineNr]:Show()
		AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
		local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
		if (aapwidth and aapwidth > 400) then
			AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
		else
			AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
		end
		LineNr = LineNr + 1
		AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Test Quest number 3")
		AAP.QuestList.QuestFrames[LineNr]:Show()
		AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
		local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
		if (aapwidth and aapwidth > 400) then
			AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
		else
			AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
		end
		return
	end
	if (AAP.QuestStepList[AAP.ActiveMap] and AAP.QuestStepList[AAP.ActiveMap][CurStep]) then
		local steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
		local StepP, IdList
		if (steps and steps["LoaPick"] and steps["LoaPick"] == 123 and ((AAP.ActiveQuests[47440] or IsQuestFlaggedCompleted(47440)) or (AAP.ActiveQuests[47439] or IsQuestFlaggedCompleted(47439)))) then
			AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
			AAP.BookingList["PrintQStep"] = 1
			return
		elseif (steps["PickedLoa"] and steps["PickedLoa"] == 2 and (AAP.ActiveQuests[47440] or IsQuestFlaggedCompleted(47440))) then
			AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
			AAP.BookingList["PrintQStep"] = 1
			if (AAP1["Debug"]) then
				print("PickedLoa Skip 2 step:".. CurStep)
			end
			return
		elseif (steps["PickedLoa"] and steps["PickedLoa"] == 1 and (AAP.ActiveQuests[47439] or IsQuestFlaggedCompleted(47439))) then
			AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
			AAP.BookingList["PrintQStep"] = 1
			if (AAP1["Debug"]) then
				print("PickedLoa Skip 1 step:".. CurStep)
			end
			return
		elseif (steps["PickUp"]) then
			StepP = "PickUp"
		elseif (steps["WarMode"]) then
			StepP = "WarMode"
		elseif (steps["DalaranToOgri"]) then
			StepP = "DalaranToOgri"
		elseif (steps["Qpart"]) then
			StepP = "Qpart"
		elseif (steps["Done"]) then
			StepP = "Done"
		elseif (steps["CRange"]) then
			StepP = "CRange"
		elseif (steps["ZonePick"]) then
			StepP = "ZonePick"
		elseif (steps["QpartPart"]) then
			StepP = "QpartPart"
		elseif (steps["DropQuest"]) then
			StepP = "DropQuest"
		elseif (steps["SetHS"]) then
			StepP = "SetHS"
		elseif (steps["UseHS"]) then
			StepP = "UseHS"
		elseif (steps["GetFP"]) then
			StepP = "GetFP"
		elseif (steps["UseFlightPath"]) then
			StepP = "UseFlightPath"
		elseif (steps["QaskPopup"]) then
			StepP = "QaskPopup"
		elseif (steps["Treasure"]) then
			StepP = "Treasure"
		elseif (steps["UseDalaHS"]) then
			StepP = "UseDalaHS"
		elseif (steps["ZoneDone"]) then
			StepP = "ZoneDone"
		end
		if (IsQuestFlaggedCompleted(47440) == true) then
			AAP1[AAP.Realm][AAP.Name]["LoaPick"] = 1
		elseif (IsQuestFlaggedCompleted(47439) == true) then
			AAP1[AAP.Realm][AAP.Name]["LoaPick"] = 2
		end
		if (steps["LeaveQuest"]) then
			AAP_LeaveQuest(steps["LeaveQuest"])
		end
		if (steps["LeaveQuests"]) then
			for AAP_index,AAP_value in pairs(steps["LeaveQuests"]) do
				AAP_LeaveQuest(AAP_value)
			end
		end
		if (AAP1["Debug"]) then
			print(StepP)
		end
		if (steps["SpecialLeaveVehicle"]) then
			C_Timer.After(1, AAP_ExitVhicle)
			C_Timer.After(3, AAP_ExitVhicle)
			C_Timer.After(5, AAP_ExitVhicle)
			C_Timer.After(10, AAP_ExitVhicle)
		end
		if (steps["VehicleExit"]) then
			VehicleExit()
		end
		if (AAP.Heirlooms < 5 and AAP.Level < 110) then
			LineNr = LineNr + 1
			AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** You only got "..AAP.Heirlooms.." xp gaining Heirlooms Equiped!")
			AAP.QuestList.QuestFrames[LineNr]:Show()
			AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
			local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
			if (aapwidth and aapwidth > 400) then
				AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
			else
				AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
			end
		end
		if (AAP.Dinged60 == 1) then
			LineNr = LineNr + 1
			AAP.Dinged60nr = LineNr
			AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** Time for Northrend! (hearthstone)")
			AAP.QuestList.QuestFrames[LineNr]:Show()
			AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
			local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
			if (aapwidth and aapwidth > 400) then
				AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
			else
				AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
			end
		end
		if (AAP.Dinged80 == 1) then
			LineNr = LineNr + 1
			AAP.Dinged80nr = LineNr
			AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** Time for Hyjal! (hearthstone)")
			AAP.QuestList.QuestFrames[LineNr]:Show()
			AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
			local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
			if (aapwidth and aapwidth > 400) then
				AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
			else
				AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
			end
		end
		if (AAP.Dinged90 == 1) then
			LineNr = LineNr + 1
			AAP.Dinged90nr = LineNr
			AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** Time for Draenor! (hearthstone)")
			AAP.QuestList.QuestFrames[LineNr]:Show()
			AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
			local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
			if (aapwidth and aapwidth > 400) then
				AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
			else
				AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
			end
		end
		if (steps["SpecialFlight"] and IsQuestFlaggedCompleted(steps["SpecialFlight"])) then
			AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
			AAP.BookingList["PrintQStep"] = 1
		end
		if (steps["GroupTask"] and AAP1[AAP.Realm][AAP.Name]["WantedQuestList"][steps["GroupTask"]] and AAP1[AAP.Realm][AAP.Name]["WantedQuestList"][steps["GroupTask"]] == 0) then
			AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
			AAP.BookingList["PrintQStep"] = 1
			return
		end
		if (steps["ETA"] and not steps["UseFlightPath"]) then
			if (ETAStep ~= CurStep) then
				AAP.AFK_Timer(steps["ETA"])
				ETAStep = CurStep
			end
		end
		if (steps["UseGlider"]) then
			if (AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowQList"] == 1) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["Use Item"]..": "..AAP.GliderFunc())
				AAP.QuestList.QuestFrames[LineNr]:Show()
				AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
				local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
				if (aapwidth and aapwidth > 400) then
					AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
				else
					AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
				end
			end
		end
		if (steps["Bloodlust"]) then
			if (AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowQList"] == 1) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** "..AAP_Locals["Bloodlust"].." **")
				AAP.QuestList.QuestFrames[LineNr]:Show()
				AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
				local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
				if (aapwidth and aapwidth > 400) then
					AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
				else
					AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
				end
			end
		end
		if (steps["InVehicle"] and not UnitInVehicle("player")) then
			LineNr = LineNr + 1
			AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Mount a Horse and scare Spiders")
			AAP.QuestList.QuestFrames[LineNr]:Show()
			AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
			local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
			if (aapwidth and aapwidth > 400) then
				AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
			else
				AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
			end
		elseif (steps["InVehicle"] and steps["InVehicle"] == 2 and UnitInVehicle("player")) then
			LineNr = LineNr + 1
			AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Scare Spiders into the Lumbermill")
			AAP.QuestList.QuestFrames[LineNr]:Show()
			AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
			local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
			if (aapwidth and aapwidth > 400) then
				AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
			else
				AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
			end
		end
		if (steps["ExtraActionB"]) then
			local isFound, macroSlot = AAP.MacroFinder()
			if isFound and macroSlot then
				AAP.MacroUpdater(macroSlot, 123123123)
			end
		end
		if (steps["DalaranToOgri"]) then
			if (AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowQList"] == 1) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["DalaranToOgri"])
				AAP.QuestList.QuestFrames[LineNr]:Show()
				AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
				local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
				if (aapwidth and aapwidth > 400) then
					AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
				else
					AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
				end
			end
		end
		if (steps["ExtraLine"] and AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowQList"] == 1) then
			LineNr = LineNr + 1
			local AAPExtralk = steps["ExtraLine"]
			if (AAPExtralk == 1) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** "..AAP_Locals["HeFlying"].." **")
			end
			if (AAPExtralk == 2) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["ClickShrine"])
			end
			if (AAPExtralk == 3) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["Talk to NPC to ride boat"])
			end
			if (AAPExtralk == 4) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["Takes little dmg at start1"])
			end
			if (AAPExtralk == 5) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["Click 1 Dirt Pile"])
			end
			if (AAPExtralk == 6) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["Go Up Elevator"])
			end
			if (AAPExtralk == 7) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["Jump off Bridge"])
			end
			if (AAPExtralk == 8) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["Jump off"])
			end
			if (AAPExtralk == 9) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["ClickAltar"])
			end
			if (AAPExtralk == 10) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["ClickTotem"])
			end
			if (AAPExtralk == 11) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["Kajamite"])
			end
			if (AAPExtralk == 12) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["Spices"])
			end
			if (AAPExtralk == 13) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["SeaUrchineBrine"])
			end
			if (AAPExtralk == 14) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["JolPoweder"])
			end
			if (AAPExtralk == 15) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["JolStir"])
			end
			if (AAPExtralk == 16) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["JolNotes"])
			end
			if (AAPExtralk == 17) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["JolHandin"])
			end
			if (AAPExtralk == 18) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["TopOfBoat"])
			end
			if (AAPExtralk == 19) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["Dontwaitrun"])
			end
			if (AAPExtralk == 20) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["Doesntmatterwep"])
			end
			if (AAPExtralk == 21) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["Extracaravans"])
			end
			if (AAPExtralk == 22) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["dotsexpire"])
			end
			if (AAPExtralk == 23) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["Banneronstuff"])
			end
			if (AAPExtralk == 24) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["GetSaurolistBuff"])
			end
			if (AAPExtralk == 25) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["Get Flight Point"])
			end
			if (AAPExtralk == 26) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["Fixed Quest"])
			end
			if (AAPExtralk == 27) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["Talk to Princess Talanji"])
			end
			if (AAPExtralk == 28) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["Zone Complete"])
			end
			if (AAPExtralk == 29) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["Missing quest"])
			end
			if (AAPExtralk == 30) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** "..AAP_Locals["waitforportal"].." **")
			end
			if (AAPExtralk == 31) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** "..AAP_Locals["WaitforsetHS"].." **")
			end
			if (AAPExtralk == 32) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["BeneathHandin"])
			end
			if (AAPExtralk == 33) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** "..AAP_Locals["Totemdmg"].." **")
			end
			if (AAPExtralk == 34) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** "..AAP_Locals["WarModeOff"].." **")
			end
			if (AAPExtralk == 35) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** "..AAP_Locals["LoaInfo1"])
				AAP.QuestList.QuestFrames[LineNr]:Show()
				AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
				local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
				if (aapwidth and aapwidth > 400) then
					AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
				else
					AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
				end
			end
			if (AAPExtralk == 35) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** "..AAP_Locals["LoaInfo2"])
			end
			if (AAPExtralk == 36) then
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["Dontglide"])
			end
			if (AAPExtralk == 37) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Use Orb on a Canyon Ettin, then save Oslow")
			end
			if (AAPExtralk == 38) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Get Key in cave")
			end
			if (AAPExtralk == 39) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Talk to FlightMaster")
			end
			if (AAPExtralk == 40) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Talk to War-Mage Erallier to teleport")
			end
			if (AAPExtralk == 41) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Leveling Starts in Redridge Mountains")
			end
			if (AAPExtralk == 42) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("NPC is ontop of the tower")
			end
			if (AAPExtralk == 43) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("*** Open the Cannary's Cache Bag to continue!")
			end
			if (AAPExtralk == 44) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("*** disguise yourself as a plant close by the merlocs")
			end
			if (AAPExtralk == 45) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("*** Use Pheromones Close by Mosshide Representative")
			end
			if (AAPExtralk == 46) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** Use Command Board")
			end
			if (AAPExtralk == 47) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** Use Portal To Undercity on top of the tower")
			end
			if (AAPExtralk == 48) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** Don't skip video")
			end
			if (AAPExtralk == 49) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** Use Dalaran Crater Portal")
			end
			if (AAPExtralk == 50) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** Use Portal Back")
			end
			if (AAPExtralk == 51) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** Use Portal")
			end
			if (AAPExtralk == 52) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** Use Zepelin to Stranglethorn Vale")
			end
			if (AAPExtralk == 53) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Learn Journeyman Riding and then type /aap skip or click skip waypoint")
			end
			if (AAPExtralk == 54) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Loot: Pamela's Doll's Head, Left and Right Side and combine them.")
			end
			if (AAPExtralk == 55) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Use Disguise.")
			end
			if (AAPExtralk == 56) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Place Lightwells around the corpsebeasts")
			end
			if (AAPExtralk == 57) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Take Portal to Stranglethorn Vale")
			end
			if (AAPExtralk == 58) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** Get Cozzle's Key")
			end
			if (AAPExtralk == 59) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** Use Portal to Orgrimmar")
			end
			if (AAPExtralk == 60) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** Train Flying")
			end
			if (AAPExtralk == 61) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** Go to Borean Tundra on Zepelin")
			end
			if (AAPExtralk == 62) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** Handin is on roof")
			end
			if (AAPExtralk == 63) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Beryl Hounds drops Cores to release Kaskala")
			end
			if (AAPExtralk == 64) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Beryl Reclaimers drop bombs")
			end
			if (AAPExtralk == 65) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Beryl Mage Hunters drops the key for the Arcane Prison")
			end
			if (AAPExtralk == 66) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Hand in far up, on a flying rock")
			end
			if (AAPExtralk == 67) then
				LineNr = LineNr + 1
				local CL_Items, itemLink, clt3, clt4, clt5, clt6, clt7, clt8, clt9, CL_ItemTex = GetItemInfo(35586)
				if (itemLink and GetItemCount(itemLink)) then
					AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Kill Coldarra Wyrmkin and loot 5 Frozen Axes (".. GetItemCount(itemLink) .."/5)")
					if (GetItemCount(itemLink) > 4) then
						AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
						AAP.BookingList["UpdateQuest"] = 1
						AAP.BookingList["PrintQStep"] = 1
					end
				else
					AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Kill Coldarra Wyrmkin and loot 5 Frozen Axes (0/5)")
				end
			end
			if (AAPExtralk == 68) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Use item on a dead Mechagnome to capture")
			end
			if (AAPExtralk == 69) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("*** Click Valve")
			end
			if (AAPExtralk == 70) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Loot Dead Mage Hunters for the plans")
			end
			if (AAPExtralk == 71) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Use Unholy gem on Duke Vallenhal below 35%hp")
			end
			if (AAPExtralk == 72) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Talk to Rokhan to make Sarathstra land")
			end
			if (AAPExtralk == 73) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Woodlands Walkers drop bark for Lothalor Ancients")
			end
			if (AAPExtralk == 74) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Lieutenant Ta'zinni drops Ley Line Focus")
			end
			if (AAPExtralk == 75) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Talk to Budd")
			end
			if (AAPExtralk == 76) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Use Budds stun on a troll and then cage it")
			end
			if (AAPExtralk == 77) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Use Dull Carving Knife (by the tree stump), then talk to him")
			end
			if (AAPExtralk == 78) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Buy a Crystal Vial from Ameenah")
			end
			if (AAPExtralk == 79) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** Loot a mummy")
			end
			if (AAPExtralk == 80) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Kill Trolls for 5 Frozen Mojo")
			end
			if (AAPExtralk == 81) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Kill Warlord Zim 'bo for his Mojo")
			end
			if (AAPExtralk == 82) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Kill Trolls for 5 Desperate Mojo")
			end
			if (AAPExtralk == 83) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** Drakuru mobs drop Lock Openers")
			end
			if (AAPExtralk == 84) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** Use Portal to Hellfire Peninsula")
			end
			if (AAPExtralk == 85) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** Use Portal to Hyjal")
			end
			if (AAPExtralk == 86) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** Loot Juniper Berries and use them on Faerie Dragons")
			end
			if (AAPExtralk == 87) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** Kill Explosive Hatreds to disable shield")
			end
			if (AAPExtralk == 88) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** Use boat to go to Northrend")
			end
			if (AAPExtralk == 89) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** Loot bombs")
			end
			if (AAPExtralk == 90) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("** Dismiss pets and pick up a miner (don't mount), and run and deliver miner")
			end
			AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
			AAP.QuestList.QuestFrames[LineNr]:Show()
			local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
			if (aapwidth and aapwidth > 400) then
				AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
			else
				AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
			end
		end
		if (StepP == "Qpart") then
			IdList = steps["Qpart"]
			local Flagged = 0
			local Total = 0
			for AAP_index,AAP_value in pairs(IdList) do
				for AAP_index2,AAP_value2 in pairs(AAP_value) do
					Total = Total + 1
					local qid = AAP_index.."-"..AAP_index2
					if (IsQuestFlaggedCompleted(AAP_index) or ((UnitLevel("player") == 120) and AAP_BonusObj[AAP_index]) or AAP1[AAP.Realm][AAP.Name]["BonusSkips"][AAP_index]) then
						Flagged = Flagged + 1
					elseif (AAP.ActiveQuests[qid] and AAP.ActiveQuests[qid] == "C") then
						Flagged = Flagged + 1
					elseif (AAP.ActiveQuests[qid]) then
						if (AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowQList"] == 1) then
							LineNr = LineNr + 1
							AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("["..LineNr.."] "..AAP.ActiveQuests[qid])
							AAP.QuestList.QuestFrames[LineNr]:Show()
							AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
							local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
							if (aapwidth and aapwidth > 400) then
								AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
							else
								AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
							end
							if (steps["Button"] and steps["Button"][qid]) then
								if (not AAP.SetButtonVar) then
									AAP.SetButtonVar = {}
								end
								AAP.SetButtonVar[qid] = LineNr
							end
							if (AAP_BonusObj[AAP_index]) then
								AAP.QuestList.QuestFrames[LineNr]["BQid"] = AAP_index
								AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Show()
							else
								AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
							end
						end
					elseif (not AAP.ActiveQuests[AAP_index] and not MissingQs[AAP_index]) then
						if (AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowQList"] == 1) then
							LineNr = LineNr + 1
							AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Error - Missing Quest: "..AAP_index)
							AAP.QuestList.QuestFrames[LineNr]:Show()
							AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
							local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
							if (aapwidth and aapwidth > 400) then
								AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
							else
								AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
							end
							MissingQs[AAP_index] = 1
							if (AAP_BonusObj[AAP_index]) then
								AAP.QuestList.QuestFrames[LineNr]["BQid"] = AAP_index
								AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Show()
							else
								AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
							end
						end
					end
				end
			end
			if (Flagged == Total and Flagged > 0) then
				AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
				AAP.BookingList["PrintQStep"] = 1
--			elseif (LineNr == 0) then
--				AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
--				AAP.BookingList["PrintQStep"] = 1
			end
		elseif (StepP == "PickUp") then
			IdList = steps["PickUp"]
			local NrLeft = 0
			local Flagged = 0
			local Total = 0
			local NrLeft2 = 0
			local Flagged2 = 0
			local Total2 = 0
			for h=1, getn(IdList) do
				local theqid = IdList[h]
				Total = Total + 1
				if (not AAP.ActiveQuests[theqid]) then
					NrLeft = NrLeft + 1
				end
				if (IsQuestFlaggedCompleted(theqid) or AAP.ActiveQuests[theqid]) then
					Flagged = Flagged + 1
				end
			end
			if (steps["PickUp2"]) then
				IdList2 = steps["PickUp2"]
				for h=1, getn(IdList2) do
					local theqid = IdList2[h]
					Total2 = Total2 + 1
					if (not AAP.ActiveQuests[theqid]) then
						NrLeft2 = NrLeft2 + 1
					end
					if (IsQuestFlaggedCompleted(theqid) or AAP.ActiveQuests[theqid]) then
						Flagged2 = Flagged2 + 1
					end
				end
			end
			if (Total == Flagged) then
				AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
				if (AAP1["Debug"]) then
					print("AAP.PrintQStep:PickUp:Plus:"..AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap])
				end
				AAP.BookingList["UpdateQuest"] = 1
				AAP.BookingList["PrintQStep"] = 1
			elseif (steps["PickUp2"] and Total2 == Flagged2) then
				AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
				if (AAP1["Debug"]) then
					print("AAP.PrintQStep:PickUp:Plus2:"..AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap])
				end
				AAP.BookingList["UpdateQuest"] = 1
				AAP.BookingList["PrintQStep"] = 1
			else
				if (AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowQList"] == 1) then
					LineNr = LineNr + 1
					AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["Pick Up Quests"]..": "..NrLeft)
					AAP.QuestList.QuestFrames[LineNr]:Show()
					AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
					local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
					if (aapwidth and aapwidth > 400) then
						AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
					else
						AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
					end
				end
			end
		elseif (StepP == "CRange") then
			IdList = steps["CRange"]
			if (IsQuestFlaggedCompleted(IdList)) then
				AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
				if (AAP1["Debug"]) then
					print("AAP.PrintQStep:CRange:Plus:"..AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap])
				end
				AAP.BookingList["UpdateQuest"] = 1
				AAP.BookingList["PrintQStep"] = 1
			else
				if (AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowQList"] == 1) then
					LineNr = LineNr + 1
					AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP.CheckCRangeText())
					AAP.QuestList.QuestFrames[LineNr]:Show()
					AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
					local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
					if (aapwidth and aapwidth > 400) then
						AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
					else
						AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
					end
				end
			end
		elseif (StepP == "Treasure") then
			IdList = steps["Treasure"]
			if (IsQuestFlaggedCompleted(IdList)) then
				AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
				if (AAP1["Debug"]) then
					print("AAP.PrintQStep:Treasure:Plus:"..AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap])
				end
				AAP.BookingList["UpdateQuest"] = 1
				AAP.BookingList["PrintQStep"] = 1
			else
				if (AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowQList"] == 1) then
					LineNr = LineNr + 1
					AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Get the Treasure")
					AAP.QuestList.QuestFrames[LineNr]:Show()
					AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
					local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
					if (aapwidth and aapwidth > 400) then
						AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
					else
						AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
					end
				end
			end
		elseif (StepP == "DropQuest") then
			IdList = steps["DropQuest"]
			if (IsQuestFlaggedCompleted(IdList) or AAP.ActiveQuests[IdList]) then
				AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
				if (AAP1["Debug"]) then
					print("AAP.PrintQStep:DropQuest:Plus:"..AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap])
				end
				AAP.BookingList["UpdateQuest"] = 1
				AAP.BookingList["PrintQStep"] = 1
			end
		elseif (StepP == "Done") then
			IdList = steps["Done"]
			local NrLeft = 0
			local Flagged = 0
			local Total = 0
			for h=1, getn(IdList) do
				Total = Total + 1
				local theqid = IdList[h]
				if (AAP.ActiveQuests[theqid]) then
					NrLeft = NrLeft + 1
				end
				if (IsQuestFlaggedCompleted(theqid)) then
					Flagged = Flagged + 1
				end
				if (steps["Button"] and steps["Button"][tostring(theqid)]) then
					if (not AAP.SetButtonVar) then
						AAP.SetButtonVar = {}
					end
					AAP.SetButtonVar[tostring(theqid)] = LineNr+1
				end
			end
			if (Total == Flagged) then
				AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
				AAP.BookingList["PrintQStep"] = 1
			else
				if (AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowQList"] == 1) then
					LineNr = LineNr + 1
					AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["Turn in Quest"]..": "..NrLeft)
					AAP.QuestList.QuestFrames[LineNr]:Show()
					AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
					local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
					if (aapwidth and aapwidth > 400) then
						AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
					else
						AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
					end
				end
			end
		elseif (StepP == "WarMode") then
			if (IsQuestFlaggedCompleted(steps["WarMode"]) or C_PvP.IsWarModeDesired() == true) then
				AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
				AAP.BookingList["PrintQStep"] = 1
			else
				if (AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowQList"] == 1) then
					LineNr = LineNr + 1
					AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("*** Turn on WARMODE ***")
					AAP.QuestList.QuestFrames[LineNr]:Show()
					AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
					local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
					if (aapwidth and aapwidth > 400) then
						AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
					else
						AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
					end
				end
				if (C_PvP.IsWarModeDesired() == false and C_PvP.CanToggleWarMode("toggle") == true) then
					C_PvP.ToggleWarMode()
					AAP.BookingList["PrintQStep"] = 1
				end
			end
		elseif (StepP == "UseDalaHS") then
			if (IsQuestFlaggedCompleted(steps["UseDalaHS"])) then
				AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
				AAP.BookingList["PrintQStep"] = 1
			else
				if (AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowQList"] == 1) then
					LineNr = LineNr + 1
					if (steps["Button"] and steps["Button"]["12112552-1"]) then
						if (not AAP.SetButtonVar) then
							AAP.SetButtonVar = {}
						end
						AAP.SetButtonVar["12112552-1"] = LineNr
					end
					AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["UseDalaHS"])
					AAP.QuestList.QuestFrames[LineNr]:Show()
					AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
					local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
					if (aapwidth and aapwidth > 400) then
						AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
					else
						AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
					end
					AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Show()
				end
			end
		elseif (StepP == "ZonePick") then
			if (AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowQList"] == 1) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["Pick Zone"])
				AAP.QuestList.QuestFrames[LineNr]:Show()
				AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
				local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
				if (aapwidth and aapwidth > 400) then
					AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
				else
					AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
				end
			end
		elseif (StepP == "SetHS") then
			if (AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowQList"] == 1) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["Set Hearthstone"])
				AAP.QuestList.QuestFrames[LineNr]:Show()
				AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
				local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
				if (aapwidth and aapwidth > 400) then
					AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
				else
					AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
				end
			end
			if (IsQuestFlaggedCompleted(steps["SetHS"])) then
				AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
				AAP.BookingList["PrintQStep"] = 1
			end
		elseif (StepP == "UseHS") then
			if (AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowQList"] == 1) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["Use Hearthstone"])
				AAP.QuestList.QuestFrames[LineNr]:Show()
				AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
				local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
				if (aapwidth and aapwidth > 400) then
					AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
				else
					AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
				end
				if (not AAP.SetButtonVar) then
					AAP.SetButtonVar = {}
				end
				AAP.SetButtonVar[steps["UseHS"]] = LineNr
			end
			if (IsQuestFlaggedCompleted(steps["UseHS"])) then
				AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
				AAP.BookingList["PrintQStep"] = 1
			end
		elseif (StepP == "GetFP") then
			if (AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowQList"] == 1) then
				LineNr = LineNr + 1
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["Get Flight Point"])
				AAP.QuestList.QuestFrames[LineNr]:Show()
				AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
				local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
				if (aapwidth and aapwidth > 400) then
					AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
				else
					AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
				end
			end
			if (IsQuestFlaggedCompleted(steps["GetFP"])) then
				AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
				AAP.BookingList["PrintQStep"] = 1
			end
		elseif (StepP == "UseFlightPath") then
			if (AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowQList"] == 1) then
				LineNr = LineNr + 1
				if (steps["Boat"]) then
					AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["Boat to"])
				else
					if (steps["Name"]) then
						AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["Fly to"]..": "..steps["Name"])
					else
						AAP.QuestList.QuestFrames["FS"..LineNr]:SetText(AAP_Locals["Fly to"])
					end
				end
				AAP.QuestList.QuestFrames[LineNr]:Show()
				AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
				local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
				if (aapwidth and aapwidth > 400) then
					AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
				else
					AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
				end
			end
			if (steps["SkipIfOnTaxi"] and UnitOnTaxi("player")) then
				AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
				AAP.BookingList["PrintQStep"] = 1
			end
			if (IsQuestFlaggedCompleted(steps["UseFlightPath"])) then
				AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
				AAP.BookingList["PrintQStep"] = 1
			end
		elseif (StepP == "QaskPopup") then
			if (IsQuestFlaggedCompleted(steps["QaskPopup"])) then
				AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
				AAP.BookingList["PrintQStep"] = 1
			else
				AAP_QAskPopWanted()
			end
		elseif (StepP == "QpartPart") then
			IdList = steps["QpartPart"]
			local Flagged = 0
			local Total = 0
			for AAP_index,AAP_value in pairs(IdList) do
				for AAP_index2,AAP_value2 in pairs(AAP_value) do
					Total = Total + 1
					if (IsQuestFlaggedCompleted(AAP_index)) then
						Flagged = Flagged + 1
					end
					local qid = AAP_index.."-"..AAP_index2
					if (AAP.ActiveQuests[qid] and AAP.ActiveQuests[qid] == "C") then
						Flagged = Flagged + 1
					elseif (AAP.ActiveQuests[qid]) then
						if (AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowQList"] == 1) then
							LineNr = LineNr + 1
							AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("["..LineNr.."] "..AAP.ActiveQuests[qid])
							AAP.QuestList.QuestFrames[LineNr]:Show()
							AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
							local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
							if (aapwidth and aapwidth > 400) then
								AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
							else
								AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
							end
						end
					elseif (not AAP.ActiveQuests[AAP_index] and not MissingQs[AAP_index]) then
						if (AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowQList"] == 1) then
							LineNr = LineNr + 1
							AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("Error - Missing Quest: "..AAP_index)
							AAP.QuestList.QuestFrames[LineNr]:Show()
							AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
							local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
							if (aapwidth and aapwidth > 400) then
								AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
							else
								AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
							end
						end
						MissingQs[AAP_index] = 1
					end
				end
			end
			if (Flagged == Total) then
				AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
				AAP.BookingList["PrintQStep"] = 1
			elseif (LineNr == 0) then
				AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
				AAP.BookingList["PrintQStep"] = 1
			elseif (steps and steps["TrigText"]) then
				for AAP_index,AAP_value in pairs(steps["QpartPart"]) do
					for AAP_index2,AAP_value2 in pairs(AAP_value) do
						if (AAP.ActiveQuests[AAP_index.."-"..tonumber(AAP_index2)]) then
							if (string.find(AAP.ActiveQuests[AAP_index.."-"..tonumber(AAP_index2)], steps["TrigText"])) then
								AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
								AAP.BookingList["PrintQStep"] = 1
							end
						end
					end
				end
			end
		end
		if (steps["DroppableQuest"] and not IsQuestFlaggedCompleted(steps["DroppableQuest"]["Qid"]) and not AAP.ActiveQuests[steps["DroppableQuest"]["Qid"]]) then
			if (AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowQList"] == 1) then
				LineNr = LineNr + 1
				local MobName = steps["DroppableQuest"]["Text"]
				if (AAP.NPCList[steps["DroppableQuest"]["MobId"]]) then
					MobName = AAP.NPCList[steps["DroppableQuest"]["MobId"]]
				end
				AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("[".. LineNr .."] "..MobName.." drops quest")
				AAP.QuestList.QuestFrames[LineNr]:Show()
				AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
				local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
				if (aapwidth and aapwidth > 400) then
					AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
				else
					AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
				end
			end
		end
		if (steps["Fillers"] and AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowQList"] == 1) then
			IdList = steps["Fillers"]
			for AAP_index,AAP_value in pairs(IdList) do
				for AAP_index2,AAP_value2 in pairs(AAP_value) do
					if (IsQuestFlaggedCompleted(AAP_index) == false and not AAP1[AAP.Realm][AAP.Name]["BonusSkips"][AAP_index]) then
						if ((UnitLevel("player") ~= 120) or (UnitLevel("player") == 120 and not AAP_BonusObj[AAP_index])) then
							local qid = AAP_index.."-"..AAP_index2
							if (AAP.ActiveQuests[qid] and AAP.ActiveQuests[qid] == "C") then
							elseif (AAP.ActiveQuests[qid]) then
								LineNr = LineNr + 1
								AAP.QuestList.QuestFrames["FS"..LineNr]:SetText("["..LineNr.."] "..AAP.ActiveQuests[qid])
								AAP.QuestList.QuestFrames[LineNr]:Show()
								AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
								local aapwidth = AAP.QuestList.QuestFrames["FS"..LineNr]:GetStringWidth()
								if (aapwidth and aapwidth > 400) then
									AAP.QuestList.QuestFrames[LineNr]:SetWidth(aapwidth+10)
								else
									AAP.QuestList.QuestFrames[LineNr]:SetWidth(410)
								end
								if (steps["Button"] and steps["Button"][qid]) then
									if (not AAP.SetButtonVar) then
										AAP.SetButtonVar = {}
									end
									AAP.SetButtonVar[qid] = LineNr
								end
								if (AAP_BonusObj[AAP_index]) then
									AAP.QuestList.QuestFrames[LineNr]["BQid"] = AAP_index
									AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Show()
								else
									AAP.QuestList.QuestFrames["FS"..LineNr]["Button"]:Hide()
								end
							end
						end
					end
				end
			end
		end
		if (AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowQList"] == 1) then
			AAP.SetButton()
		end
		if (AAP.QuestListShown ~= LineNr) then
			if (AAP.QuestListShown > LineNr) then
				local FrameHideNr = AAP.QuestListShown - LineNr
				local NewLine = LineNr
				local CLi
				for CLi = 1, FrameHideNr do
					NewLine = NewLine + CLi
					AAP.QuestList.QuestFrames[NewLine]:Hide()
					if (not InCombatLockdown()) then
						AAP.QuestList.QuestFrames["FS"..NewLine]["Button"]:Hide()
						AAP.QuestList2["BF"..NewLine]:Hide()
					end
					if (AAP1["Debug"]) then
						print("Hide:"..NewLine)
					end
				end
			end
		end
		if (StepP == "ZoneDone" or (AAP.ActiveMap == 862 and AAP1[AAP.Realm][AAP.Name]["HordeD"] and AAP1[AAP.Realm][AAP.Name]["HordeD"] == 1)) then
			local CLi
			for CLi = 1, 10 do
				AAP.QuestList.QuestFrames[CLi]:Hide()
				AAP.QuestList.QuestFrames["FS"..CLi]["Button"]:Hide()
				AAP.QuestList2["BF"..CLi]:Hide()
				if (AAP1["Debug"]) then
					print("Hide:"..CLi)
				end
			end
			AAP.ArrowActive = 0
		end
		AAP.QuestListShown = LineNr
		AAP.BookingList["SetQPTT"] = 1
	end
end
function AAP.SetButton()
	local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
	local steps
	if (CurStep and AAP.ActiveMap and AAP.QuestStepList and AAP.QuestStepList[AAP.ActiveMap] and AAP.QuestStepList[AAP.ActiveMap][CurStep]) then
		steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
	end
	if (steps and steps["Button"] or (AAP.Dinged60 == 1 and AAP.Dinged60nr > 0) or (AAP.Dinged80 == 1 and AAP.Dinged80nr > 0) or (AAP.Dinged90 == 1 and AAP.Dinged90nr > 0)) then
		if (not InCombatLockdown()) then
			if (AAP.SetButtonVar) then
				if (AAP1["Debug"]) then
					print("SetButton")
				end
				AAP.ButtonList = nil
				AAP.ButtonList = {}
				local HideVar = {}
				for AAP_index2,AAP_value2 in pairs(AAP.SetButtonVar) do
					for AAP_index,AAP_value in pairs(steps["Button"]) do
						if (AAP1["Debug"]) then
							print(AAP_index)
						end
						if (AAP_index2 == AAP_index or steps["UseHS"]) then
							local CL_Items, itemLink, clt3, clt4, clt5, clt6, clt7, clt8, clt9, CL_ItemTex = GetItemInfo(AAP_value)
							if (CL_Items and string.sub(CL_Items, 1, 1) and CL_ItemTex) then
								HideVar[AAP_value2] = AAP_value2
								AAP.ButtonList[AAP_index] = AAP_value2
								AAP.QuestList2["BF"..AAP_value2]["AAP_Buttonptex"]:SetTexture(CL_ItemTex)
								AAP.QuestList2["BF"..AAP_value2]["AAP_Buttonntex"]:SetTexture(CL_ItemTex)
								AAP.QuestList2["BF"..AAP_value2]["AAP_Button"]:SetNormalTexture(CL_ItemTex)
								AAP.QuestList2["BF"..AAP_value2]["AAP_Button"]:SetText("")
								AAP.QuestList2["BF"..AAP_value2]["AAP_Button"]:SetAttribute("type", "item");
								AAP.QuestList2["BF"..AAP_value2]["AAP_Button"]:SetAttribute("item", "item:"..AAP_value);
								AAP.QuestList2["BF"..AAP_value2]["AAP_Button"]:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:SetItemByID(AAP_value); GameTooltip:Show() end)
								AAP.QuestList2["BF"..AAP_value2]["AAP_Button"]:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
								if (GetItemCount(itemLink) and GetItemCount(itemLink) > 0) then
									AAP.QuestList2["BF"..AAP_value2]:Show()
								else
									AAP.QuestList2["BF"..AAP_value2]:Hide()
								end
								local Topz = AAP1[AAP.Realm][AAP.Name]["Settings"]["left"]
								local Topz2 = AAP1[AAP.Realm][AAP.Name]["Settings"]["top"]
								AAP.QuestList20:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Topz, Topz2)
								AAP.QuestList2["BF"..AAP_value2]:SetPoint("BOTTOMLEFT", AAP.QuestList21, "BOTTOMLEFT",0,-((AAP_value2 * 38)+AAP_value2))
								if (not AAP.ButtonVisual) then
									AAP.ButtonVisual = {}
								end
								local _, Spellidz = GetItemSpell(AAP_value)
								if (Spellidz) then
									AAP.QuestStepList[AAP.ActiveMap][CurStep]["ButtonSpellId"] = { [Spellidz] = AAP_index }
								end
								AAP.ButtonVisual[AAP_value2] = AAP_value2
								local isFound, macroSlot = AAP.MacroFinder()
								if isFound and macroSlot then
									if (steps and steps["SpecialDubbleMacro"]) then
										if (not AAP.DubbleMacro[1]) then
											AAP.DubbleMacro[1] = CL_Items
										elseif (AAP.DubbleMacro and AAP.DubbleMacro[1] and not AAP.DubbleMacro[2]) then
											AAP.DubbleMacro[2] = CL_Items
										end
									else
										AAP.DubbleMacro = nil
										AAP.DubbleMacro = {}
									end
									AAP.MacroUpdater(macroSlot, CL_Items)
								end
							end
						end
					end
				end
				for i=1, 10 do
					if (not HideVar[i]) then
						AAP.QuestList2["BF"..i]:Hide()
					end
				end
				if (AAP.Dinged60 == 1 and AAP.Dinged60nr > 0) then
					local CL_Items, clt2, clt3, clt4, clt5, clt6, clt7, clt8, clt9, CL_ItemTex = GetItemInfo(6948)
					if (CL_Items and string.sub(CL_Items, 1, 1) and CL_ItemTex) then
						HideVar[AAP.Dinged60nr] = AAP.Dinged60nr
						AAP.ButtonList[123451234] = AAP.Dinged60nr
						AAP.QuestList2["BF"..AAP.Dinged60nr]["AAP_Buttonptex"]:SetTexture(CL_ItemTex)
						AAP.QuestList2["BF"..AAP.Dinged60nr]["AAP_Buttonntex"]:SetTexture(CL_ItemTex)
						AAP.QuestList2["BF"..AAP.Dinged60nr]["AAP_Button"]:SetNormalTexture(CL_ItemTex)
						AAP.QuestList2["BF"..AAP.Dinged60nr]["AAP_Button"]:SetText("")
						AAP.QuestList2["BF"..AAP.Dinged60nr]["AAP_Button"]:SetAttribute("type", "item");
						AAP.QuestList2["BF"..AAP.Dinged60nr]["AAP_Button"]:SetAttribute("item", "item:6948");
						AAP.QuestList2["BF"..AAP.Dinged60nr]:Show()
							AAP.QuestList2["BF"..AAP.Dinged60nr]["AAP_Button"]:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:SetItemByID(6948); GameTooltip:Show() end)
							AAP.QuestList2["BF"..AAP.Dinged60nr]["AAP_Button"]:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
						local Topz = AAP1[AAP.Realm][AAP.Name]["Settings"]["left"]
						local Topz2 = AAP1[AAP.Realm][AAP.Name]["Settings"]["top"]
						AAP.QuestList20:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Topz, Topz2)
						AAP.QuestList2["BF"..AAP.Dinged60nr]:SetPoint("BOTTOMLEFT", AAP.QuestList21, "BOTTOMLEFT",0,-((AAP.Dinged60nr * 38)+AAP.Dinged60nr))
						if (not AAP.ButtonVisual) then
							AAP.ButtonVisual = {}
						end
						AAP.ButtonVisual[AAP.Dinged60nr] = AAP.Dinged60nr
						local isFound, macroSlot = AAP.MacroFinder()
						if isFound and macroSlot then
							if (steps and steps["SpecialDubbleMacro"]) then
								if (not AAP.DubbleMacro[1]) then
									AAP.DubbleMacro[1] = CL_Items
								elseif (AAP.DubbleMacro and AAP.DubbleMacro[1] and not AAP.DubbleMacro[2]) then
									AAP.DubbleMacro[2] = CL_Items
								end
							else
								AAP.DubbleMacro = nil
								AAP.DubbleMacro = {}
							end
							AAP.MacroUpdater(macroSlot, CL_Items)
						end
					end
				end
				if (AAP.Dinged80 == 1 and AAP.Dinged80nr > 0) then
					local CL_Items, clt2, clt3, clt4, clt5, clt6, clt7, clt8, clt9, CL_ItemTex = GetItemInfo(6948)
					if (CL_Items and string.sub(CL_Items, 1, 1) and CL_ItemTex) then
						HideVar[AAP.Dinged80nr] = AAP.Dinged80nr
						AAP.ButtonList[123451234] = AAP.Dinged80nr
						AAP.QuestList2["BF"..AAP.Dinged80nr]["AAP_Buttonptex"]:SetTexture(CL_ItemTex)
						AAP.QuestList2["BF"..AAP.Dinged80nr]["AAP_Buttonntex"]:SetTexture(CL_ItemTex)
						AAP.QuestList2["BF"..AAP.Dinged80nr]["AAP_Button"]:SetNormalTexture(CL_ItemTex)
						AAP.QuestList2["BF"..AAP.Dinged80nr]["AAP_Button"]:SetText("")
						AAP.QuestList2["BF"..AAP.Dinged80nr]["AAP_Button"]:SetAttribute("type", "item");
						AAP.QuestList2["BF"..AAP.Dinged80nr]["AAP_Button"]:SetAttribute("item", "item:6948");
						AAP.QuestList2["BF"..AAP.Dinged80nr]:Show()
						AAP.QuestList2["BF"..AAP.Dinged80nr]["AAP_Button"]:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:SetItemByID(6948); GameTooltip:Show() end)
						AAP.QuestList2["BF"..AAP.Dinged80nr]["AAP_Button"]:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
						local Topz = AAP1[AAP.Realm][AAP.Name]["Settings"]["left"]
						local Topz2 = AAP1[AAP.Realm][AAP.Name]["Settings"]["top"]
						AAP.QuestList20:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Topz, Topz2)
						AAP.QuestList2["BF"..AAP.Dinged80nr]:SetPoint("BOTTOMLEFT", AAP.QuestList21, "BOTTOMLEFT",0,-((AAP.Dinged80nr * 38)+AAP.Dinged80nr))
						if (not AAP.ButtonVisual) then
							AAP.ButtonVisual = {}
						end
						AAP.ButtonVisual[AAP.Dinged80nr] = AAP.Dinged80nr
						local isFound, macroSlot = AAP.MacroFinder()
						if isFound and macroSlot then
							if (steps and steps["SpecialDubbleMacro"]) then
								if (not AAP.DubbleMacro[1]) then
									AAP.DubbleMacro[1] = CL_Items
								elseif (AAP.DubbleMacro and AAP.DubbleMacro[1] and not AAP.DubbleMacro[2]) then
									AAP.DubbleMacro[2] = CL_Items
								end
							else
								AAP.DubbleMacro = nil
								AAP.DubbleMacro = {}
							end
							AAP.MacroUpdater(macroSlot, CL_Items)
						end
					end
				end
				if (AAP.Dinged90 == 1 and AAP.Dinged90nr > 0) then
					local CL_Items, clt2, clt3, clt4, clt5, clt6, clt7, clt8, clt9, CL_ItemTex = GetItemInfo(6948)
					if (CL_Items and string.sub(CL_Items, 1, 1) and CL_ItemTex) then
						HideVar[AAP.Dinged90nr] = AAP.Dinged90nr
						AAP.ButtonList[123451234] = AAP.Dinged90nr
						AAP.QuestList2["BF"..AAP.Dinged90nr]["AAP_Buttonptex"]:SetTexture(CL_ItemTex)
						AAP.QuestList2["BF"..AAP.Dinged90nr]["AAP_Buttonntex"]:SetTexture(CL_ItemTex)
						AAP.QuestList2["BF"..AAP.Dinged90nr]["AAP_Button"]:SetNormalTexture(CL_ItemTex)
						AAP.QuestList2["BF"..AAP.Dinged90nr]["AAP_Button"]:SetText("")
						AAP.QuestList2["BF"..AAP.Dinged90nr]["AAP_Button"]:SetAttribute("type", "item");
						AAP.QuestList2["BF"..AAP.Dinged90nr]["AAP_Button"]:SetAttribute("item", "item:6948");
						AAP.QuestList2["BF"..AAP.Dinged90nr]:Show()
						AAP.QuestList2["BF"..AAP.Dinged90nr]["AAP_Button"]:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:SetItemByID(6948); GameTooltip:Show() end)
						AAP.QuestList2["BF"..AAP.Dinged90nr]["AAP_Button"]:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
						local Topz = AAP1[AAP.Realm][AAP.Name]["Settings"]["left"]
						local Topz2 = AAP1[AAP.Realm][AAP.Name]["Settings"]["top"]
						AAP.QuestList20:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Topz, Topz2)
						AAP.QuestList2["BF"..AAP.Dinged90nr]:SetPoint("BOTTOMLEFT", AAP.QuestList21, "BOTTOMLEFT",0,-((AAP.Dinged90nr * 38)+AAP.Dinged90nr))
						if (not AAP.ButtonVisual) then
							AAP.ButtonVisual = {}
						end
						AAP.ButtonVisual[AAP.Dinged90nr] = AAP.Dinged90nr
						local isFound, macroSlot = AAP.MacroFinder()
						if isFound and macroSlot then
							if (steps and steps["SpecialDubbleMacro"]) then
								if (not AAP.DubbleMacro[1]) then
									AAP.DubbleMacro[1] = CL_Items
								elseif (AAP.DubbleMacro and AAP.DubbleMacro[1] and not AAP.DubbleMacro[2]) then
									AAP.DubbleMacro[2] = CL_Items
								end
							else
								AAP.DubbleMacro = nil
								AAP.DubbleMacro = {}
							end
							AAP.MacroUpdater(macroSlot, CL_Items)
						end
					end
				end
			else
				if (steps and not steps["Button"]) then
					for i=1, 10 do
						AAP.QuestList2["BF"..i]:Hide()
					end
				end
				if (AAP.Dinged60 == 1 and AAP.Dinged60nr > 0) then
					local CL_Items, clt2, clt3, clt4, clt5, clt6, clt7, clt8, clt9, CL_ItemTex = GetItemInfo(6948)
					if (CL_Items and string.sub(CL_Items, 1, 1) and CL_ItemTex) then
						AAP.ButtonList[123451234] = AAP.Dinged60nr
						AAP.QuestList2["BF"..AAP.Dinged60nr]["AAP_Buttonptex"]:SetTexture(CL_ItemTex)
						AAP.QuestList2["BF"..AAP.Dinged60nr]["AAP_Buttonntex"]:SetTexture(CL_ItemTex)
						AAP.QuestList2["BF"..AAP.Dinged60nr]["AAP_Button"]:SetNormalTexture(CL_ItemTex)
						AAP.QuestList2["BF"..AAP.Dinged60nr]["AAP_Button"]:SetText("")
						AAP.QuestList2["BF"..AAP.Dinged60nr]["AAP_Button"]:SetAttribute("type", "item");
						AAP.QuestList2["BF"..AAP.Dinged60nr]["AAP_Button"]:SetAttribute("item", "item:6948");
						AAP.QuestList2["BF"..AAP.Dinged60nr]:Show()
						AAP.QuestList2["BF"..AAP.Dinged60nr]["AAP_Button"]:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:SetItemByID(6948); GameTooltip:Show() end)
						AAP.QuestList2["BF"..AAP.Dinged60nr]["AAP_Button"]:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
						local Topz = AAP1[AAP.Realm][AAP.Name]["Settings"]["left"]
						local Topz2 = AAP1[AAP.Realm][AAP.Name]["Settings"]["top"]
						AAP.QuestList20:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Topz, Topz2)
						AAP.QuestList2["BF"..AAP.Dinged60nr]:SetPoint("BOTTOMLEFT", AAP.QuestList21, "BOTTOMLEFT",0,-((AAP.Dinged60nr * 38)+AAP.Dinged60nr))
						if (not AAP.ButtonVisual) then
							AAP.ButtonVisual = {}
						end
						AAP.ButtonVisual[AAP.Dinged60nr] = AAP.Dinged60nr
						local isFound, macroSlot = AAP.MacroFinder()
						if isFound and macroSlot then
							AAP.DubbleMacro = nil
							AAP.DubbleMacro = {}
							AAP.MacroUpdater(macroSlot, CL_Items)
						end
					end
				end
				if (AAP.Dinged80 == 1 and AAP.Dinged80nr > 0) then
					local CL_Items, clt2, clt3, clt4, clt5, clt6, clt7, clt8, clt9, CL_ItemTex = GetItemInfo(6948)
					if (CL_Items and string.sub(CL_Items, 1, 1) and CL_ItemTex) then
						AAP.ButtonList[123451234] = AAP.Dinged80nr
						AAP.QuestList2["BF"..AAP.Dinged80nr]["AAP_Buttonptex"]:SetTexture(CL_ItemTex)
						AAP.QuestList2["BF"..AAP.Dinged80nr]["AAP_Buttonntex"]:SetTexture(CL_ItemTex)
						AAP.QuestList2["BF"..AAP.Dinged80nr]["AAP_Button"]:SetNormalTexture(CL_ItemTex)
						AAP.QuestList2["BF"..AAP.Dinged80nr]["AAP_Button"]:SetText("")
						AAP.QuestList2["BF"..AAP.Dinged80nr]["AAP_Button"]:SetAttribute("type", "item");
						AAP.QuestList2["BF"..AAP.Dinged80nr]["AAP_Button"]:SetAttribute("item", "item:6948");
						AAP.QuestList2["BF"..AAP.Dinged80nr]:Show()
						AAP.QuestList2["BF"..AAP.Dinged80nr]["AAP_Button"]:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:SetItemByID(6948); GameTooltip:Show() end)
						AAP.QuestList2["BF"..AAP.Dinged80nr]["AAP_Button"]:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
						local Topz = AAP1[AAP.Realm][AAP.Name]["Settings"]["left"]
						local Topz2 = AAP1[AAP.Realm][AAP.Name]["Settings"]["top"]
						AAP.QuestList20:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Topz, Topz2)
						AAP.QuestList2["BF"..AAP.Dinged80nr]:SetPoint("BOTTOMLEFT", AAP.QuestList21, "BOTTOMLEFT",0,-((AAP.Dinged80nr * 38)+AAP.Dinged80nr))
						if (not AAP.ButtonVisual) then
							AAP.ButtonVisual = {}
						end
						AAP.ButtonVisual[AAP.Dinged80nr] = AAP.Dinged80nr
						local isFound, macroSlot = AAP.MacroFinder()
						if isFound and macroSlot then
							AAP.DubbleMacro = nil
							AAP.DubbleMacro = {}
							AAP.MacroUpdater(macroSlot, CL_Items)
						end
					end
				end
				if (AAP.Dinged90 == 1 and AAP.Dinged90nr > 0) then
					local CL_Items, clt2, clt3, clt4, clt5, clt6, clt7, clt8, clt9, CL_ItemTex = GetItemInfo(6948)
					if (CL_Items and string.sub(CL_Items, 1, 1) and CL_ItemTex) then
						AAP.ButtonList[123451234] = AAP.Dinged90nr
						AAP.QuestList2["BF"..AAP.Dinged90nr]["AAP_Buttonptex"]:SetTexture(CL_ItemTex)
						AAP.QuestList2["BF"..AAP.Dinged90nr]["AAP_Buttonntex"]:SetTexture(CL_ItemTex)
						AAP.QuestList2["BF"..AAP.Dinged90nr]["AAP_Button"]:SetNormalTexture(CL_ItemTex)
						AAP.QuestList2["BF"..AAP.Dinged90nr]["AAP_Button"]:SetText("")
						AAP.QuestList2["BF"..AAP.Dinged90nr]["AAP_Button"]:SetAttribute("type", "item");
						AAP.QuestList2["BF"..AAP.Dinged90nr]["AAP_Button"]:SetAttribute("item", "item:6948");
						AAP.QuestList2["BF"..AAP.Dinged90nr]:Show()
						AAP.QuestList2["BF"..AAP.Dinged90nr]["AAP_Button"]:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:SetItemByID(6948); GameTooltip:Show() end)
						AAP.QuestList2["BF"..AAP.Dinged90nr]["AAP_Button"]:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
						local Topz = AAP1[AAP.Realm][AAP.Name]["Settings"]["left"]
						local Topz2 = AAP1[AAP.Realm][AAP.Name]["Settings"]["top"]
						AAP.QuestList20:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Topz, Topz2)
						AAP.QuestList2["BF"..AAP.Dinged90nr]:SetPoint("BOTTOMLEFT", AAP.QuestList21, "BOTTOMLEFT",0,-((AAP.Dinged90nr * 38)+AAP.Dinged90nr))
						if (not AAP.ButtonVisual) then
							AAP.ButtonVisual = {}
						end
						AAP.ButtonVisual[AAP.Dinged90nr] = AAP.Dinged90nr
						local isFound, macroSlot = AAP.MacroFinder()
						if isFound and macroSlot then
							AAP.DubbleMacro = nil
							AAP.DubbleMacro = {}
							AAP.MacroUpdater(macroSlot, CL_Items)
						end
					end
				end
			end
			AAP.QuestList20:SetPoint("TOPLEFT", UIParent, "TOPLEFT", AAP1[AAP.Realm][AAP.Name]["Settings"]["left"], AAP1[AAP.Realm][AAP.Name]["Settings"]["top"])
			AAP.SetButtonVar = nil
		end
	elseif (AAP.ButtonVisual and not InCombatLockdown()) then
		for AAP_index,AAP_value in pairs(AAP.ButtonVisual) do
			AAP.QuestList2["BF"..AAP_index]:Hide()
		end
		AAP.ButtonVisual = nil
	end
end
function AAP.CheckCRangeText()
	local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
	local steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
	local i = 1
	while i  <= 15 do
		CurStep = CurStep + 1
		steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
		if (steps and steps["FlightPath"]) then
			local Derp2 = AAP_Locals["Get Flight Point"]
			return Derp2
		elseif (steps and steps["UseFlightPath"]) then
			if (steps["Boat"]) then
				local Derp2 = AAP_Locals["Boat to"]
				return Derp2
			else
				local Derp2 = AAP_Locals["Fly to"]
				return Derp2
			end
		elseif (steps and steps["PickUp"]) then
			local Derp2 = AAP_Locals["Accept Quest"]
			return Derp2
		elseif (steps and steps["Done"]) then
			local Derp2 = AAP_Locals["Turn in Quest"]
			return Derp2
		elseif (steps and steps["Qpart"]) then
			local Derp2 = AAP_Locals["Complete Quest"]
			return Derp2
		elseif (steps and steps["SetHS"]) then
			local Derp2 = AAP_Locals["Set Hearthstone"]
			return Derp2
		elseif (steps and steps["QpartPart"]) then
			local Derp2 = AAP_Locals["Complete Quest"]
			return Derp2
		end

		i = i + 1
	end
	local Derp2 = AAP_Locals["Travel to"]
	return Derp2
end
local function AAP_UpdateQuest()
	local i = 1
	local UpdateQpart = 0
	while GetQuestLogTitle(i) do
		local questTitle, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID = GetQuestLogTitle(i)
		if (questID > 0) then
			if (not isHeader) then
				local numObjectives = GetNumQuestLeaderBoards(SelectQuestLogEntry(i))
				if (not AAP.ActiveQuests[questID]) then
					if (AAP1["Debug"]) then
						print("New Q:"..questID)
					end
				end
				if (not isComplete) then
					isComplete = 0
					AAP.ActiveQuests[questID] = "P"
				else
					isComplete = 1
					AAP.ActiveQuests[questID] = "C"
				end
				if (numObjectives == 0) then
					if (isComplete == 1) then
						AAP.ActiveQuests[questID.."-".."1"] = "C"
					else
						AAP.ActiveQuests[questID.."-".."1"] = questTitle
					end
				else
					for h=1, numObjectives do
						local text = 0
						local text, type, finished = GetQuestLogLeaderBoard(h, SelectQuestLogEntry(i))
						if (finished == true) then
							finished = 1
						else
							finished = 0
						end
						if (finished == 1) then
							if (AAP.ActiveQuests[questID.."-"..h] and AAP.ActiveQuests[questID.."-"..h] ~= "C") then
								if (AAP1["Debug"]) then
									print("Update:".."C")
								end
								Update = 1
							end
							AAP.ActiveQuests[questID.."-"..h] = "C"
						elseif ((select(2,GetQuestObjectiveInfo(questID, 1, false)) == "progressbar") and text) then
							local AAP_Mathstuff = tonumber(GetQuestProgressBarPercent(questID))
							AAP_Mathstuff = floor((AAP_Mathstuff + 0.5))
							text = "["..AAP_Mathstuff.."%] " .. text
							if (not AAP.ActiveQuests[questID.."-"..h]) then
								if (AAP1["Debug"]) then
									print("New1:"..text)
								end
							end
							if (AAP.ActiveQuests[questID.."-"..h] and AAP.ActiveQuests[questID.."-"..h] ~= text) then
								if (AAP1["Debug"]) then
									print("Update:"..text)
								end
								Update = 1
								AAP.ActiveQuests[questID.."-"..h] = text
							else
								AAP.ActiveQuests[questID.."-"..h] = text
							end
						else
							if (not AAP.ActiveQuests[questID.."-"..h]) then
								--print("New2:"..text)
							end
							if (AAP.ActiveQuests[questID.."-"..h] and AAP.ActiveQuests[questID.."-"..h] ~= text) then
								if (AAP1["Debug"]) then
									print("Update:"..text)
								end
								Update = 1
								AAP.ActiveQuests[questID.."-"..h] = text
							else
								AAP.ActiveQuests[questID.."-"..h] = text
							end
						end
					end
				end
			end
		end
	i = i + 1
	end
	if (Update == 1) then
		AAP.BookingList["PrintQStep"] = 1
	end
end
function AAP.MacroFinder()
	local found = false
	local global, character = GetNumMacros()
	for i=1, global do
		local name = GetMacroInfo(i)
		if name == "AAP_MACRO" then
			found = true
			return true, i
		end
	end
	if not found then
		return false, nil
	end
end
function AAP.CreateMacro()
	if InCombatLockdown() then
		return
	end
	if (AAP1["Debug"]) then
		print("AAP.CreateMacro()")
	end
	local global, character = GetNumMacros()
	local isFound, macroSlot = AAP.MacroFinder()
	local aap_hasSpace = global < MAX_ACCOUNT_MACROS
	if aap_hasSpace then 
		if not isFound and not InCombatLockdown() then
			CreateMacro("AAP_MACRO","INV_MISC_QUESTIONMARK","/script print('no button yet')",nil,nil)
		end
	else
		print("AAP: No global macro space. Please delete a macro to create space.")
	end
end
function AAP.MacroUpdater(macroSlot,itemName,aapextra)
	if (itemName) then
		if (itemName == 123123123) then
			EditMacro(macroSlot, "AAP_MACRO","INV_MISC_QUESTIONMARK","#showtooltip\n/click ExtraActionButton1",nil,nil)
		elseif (aapextra == 65274) then
			EditMacro(macroSlot, "AAP_MACRO","INV_MISC_QUESTIONMARK","#showtooltip\n/script AAP.SaveOldSlot()\n/use "..itemName,nil,nil)
		else
			local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
			local steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
			if (AAP.DubbleMacro and AAP.DubbleMacro[1] and AAP.DubbleMacro[2] and steps["SpecialDubbleMacro"]) then
				EditMacro(macroSlot, "AAP_MACRO","INV_MISC_QUESTIONMARK","#showtooltip\n/use "..AAP.DubbleMacro[1].."\n/use "..AAP.DubbleMacro[2],nil,nil)
			elseif (steps["SpecialMacro"]) then
				EditMacro(macroSlot, "AAP_MACRO","INV_MISC_QUESTIONMARK","#showtooltip\n/target Serrik\n/use "..itemName,nil,nil)
			elseif (steps["SpecialMacro2"]) then
				EditMacro(macroSlot, "AAP_MACRO","INV_MISC_QUESTIONMARK","#showtooltip\n/target Hrillik's\n/use "..itemName,nil,nil)
			else
				EditMacro(macroSlot, "AAP_MACRO","INV_MISC_QUESTIONMARK","#showtooltip\n/use "..itemName,nil,nil)
			end
		end
	else
		EditMacro(macroSlot, "AAP_MACRO","INV_MISC_QUESTIONMARK","/script print('no button yet')",nil,nil)
	end
end
function AAP.GliderFunc()
	if (AAP1["GliderName"]) then
		return AAP1["GliderName"]
	else
		local bag, slot, itemLink, itemName, count
		local DerpGot = 0
		for bag = 0,4 do
			for slot = 1,GetContainerNumSlots(bag) do
				local itemID = GetContainerItemID(bag, slot)
				if (itemID and itemID == 109076) then
					DerpGot = 1
					itemLink = GetContainerItemLink(bag,slot)
					itemName = GetItemInfo(itemLink)
					count = GetItemCount(itemLink)
				end
			end
		end
		if (DerpGot == 1) then
			AAP1["GliderName"] = itemName
			return itemName
		else
			return "Goblin Glider Kit"
		end
	end
end
local function AAP_QuestStepIds()
	if (AAP.QuestStepList[AAP.ActiveMap]) then
		local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
		if (CurStep and AAP.QuestStepList[AAP.ActiveMap][CurStep]) then
			local steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
			if (steps["PickUp"]) then
				return steps["PickUp"], "PickUp"
			elseif (steps["Qpart"]) then
				return steps["Qpart"], "Qpart"
			elseif (steps["Done"]) then
				return steps["Done"], "Done"
			else
				return
			end
		else
			return
		end
	else
		return
	end
end
local function AAP_RemoveQuest(questID)
	AAP.ActiveQuests[questID] = nil
	for AAP_index,AAP_value in pairs(AAP.ActiveQuests) do
		if (string.find(AAP_index, "(.*)-(.*)")) then
			local _, _, AAP_First, AAP_Rest = string.find(AAP_index, "(.*)-(.*)")
			if (tonumber(AAP_First) == questID) then
				AAP.ActiveQuests[AAP_index] = nil
			end
		end
	end
	local IdList, StepP = AAP_QuestStepIds()
	if (StepP == "Done") then
		local NrLeft = 0
		for AAP_index,AAP_value in pairs(IdList) do
			if (IsQuestFlaggedCompleted(AAP_value) or questID == AAP_value) then
			else
				NrLeft = NrLeft + 1
			end
		end
		if (NrLeft == 0) then
			AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
			if (AAP1["Debug"]) then
				print("AAP.RemoveQuest:Plus"..AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap])
			end
			AAP.BookingList["UpdateQuest"] = 1
		end
	end
	AAP.BookingList["PrintQStep"] = 1
end
local function AAP_AddQuest(questID)
	AAP.ActiveQuests[questID] = "P"
	local IdList, StepP = AAP_QuestStepIds()
	if (StepP == "PickUp") then
		local NrLeft = 0
		for AAP_index,AAP_value in pairs(IdList) do
			if (not AAP.ActiveQuests[AAP_value]) then
				NrLeft = NrLeft + 1
			end
		end
		if (NrLeft == 0) then
			AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
			if (AAP1["Debug"]) then
				print("AAP.AddQuest:Plus"..AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap])
			end
			AAP.BookingList["UpdateQuest"] = 1
		end
	end
	AAP.BookingList["PrintQStep"] = 1
end
local function AAP_UpdateMapId()
	local OldMap = AAP.ActiveMap
	local levelcheck = 0
	local levelcheck80 = 0
	local levelcheck90 = 0
	AAP.Level = UnitLevel("player")
	AAP.ActiveMap = C_Map.GetBestMapForUnit("player")
	local currentMapId, TOP_MOST = C_Map.GetBestMapForUnit('player'), true
	AAP.ActiveMap = MapUtil.GetMapParentInfo(currentMapId, Enum.UIMapType.Continent+1, TOP_MOST)
	if (AAP.ActiveMap and AAP.ActiveMap["mapID"]) then
		AAP.ActiveMap = AAP.ActiveMap["mapID"]
	else
		AAP.ActiveMap = C_Map.GetBestMapForUnit("player")
	end
	if (OldMap and OldMap ~= AAP.ActiveMap) then
		AAP.BookingList["PrintQStep"] = 1
	end
	if (AAP.Faction == "Alliance") then
		AAP.ActiveMap = "A"..AAP.ActiveMap
	end
	if (AAP.ActiveMap == "A895") then
		if ((AAP.ActiveQuests[47961] or IsQuestFlaggedCompleted(47961) == true) and not IsQuestFlaggedCompleted(48622)) then
			AAP.ActiveMap = "A895-1"
		elseif ((AAP.ActiveQuests[47962] or IsQuestFlaggedCompleted(47962) == true) and not IsQuestFlaggedCompleted(51490)) then
			AAP.ActiveMap = "A895-2"
		elseif ((AAP.ActiveQuests[47960] or IsQuestFlaggedCompleted(47960) == true) and not IsQuestFlaggedCompleted(50972)) then
			AAP.ActiveMap = "A895-3"
		end
	end
	if (AAP.ActiveMap == 862) then
		if ((AAP.ActiveQuests[47514] or IsQuestFlaggedCompleted(47514) == true) and IsQuestFlaggedCompleted(50963) == false) then
			AAP.ActiveMap = "862-3"
		elseif ((AAP.ActiveQuests[47513] or IsQuestFlaggedCompleted(47513) == true) and IsQuestFlaggedCompleted(47315) == false) then
			AAP.ActiveMap = "862-1"
		elseif ((AAP.ActiveQuests[47512] or IsQuestFlaggedCompleted(47512) == true) and IsQuestFlaggedCompleted(47105) == false) then
			AAP.ActiveMap = "862-2"
		elseif (IsQuestFlaggedCompleted(47105) == true and IsQuestFlaggedCompleted(47315) == true and IsQuestFlaggedCompleted(50963) == true) then
			AAP1[AAP.Realm][AAP.Name]["HordeD"] = 1
		end
	end
	if ((AAP.ActiveMap == "A23" or AAP.ActiveMap == 23) and AAP.Class[3] == 6 and IsQuestFlaggedCompleted(13189) == false) then
		AAP.ActiveMap = "DK23"
	end
	if (AAP.ActiveMap == "A630") then
		AAP.ActiveMap = 630
	end
	if (AAP.ActiveMap == 1 and (AAP.ActiveQuests[53372] or IsQuestFlaggedCompleted(53372) == true)) then
		AAP.ActiveMap = "1-110"
	end
	if (AAP.ActiveMap == 1 and AAP.Level == 20 and AAP.Race == "MagharOrc") then
		AAP.ActiveMap = "1-MagharOrc"
	end
	if (AAP.ActiveMap == 1 and AAP.Level == 20 and AAP.Race == "HighmountainTauren") then
		AAP.ActiveMap = "1-HighmountainTauren"
	end
	if (AAP.ActiveMap == 1 and AAP.Level == 20 and AAP.Race == "Nightborne") then
		AAP.ActiveMap = "1-Nightborne"
	end
	if (AAP.ActiveMap == 1 and AAP.Level > 19 and AAP.Level < 60) then
		AAP.ActiveMap = "1-20-60"
	end
	if (AAP.ActiveMap == 76 and AAP.Level > 19 and AAP.Level < 60) then
		AAP.ActiveMap = "76-20-60"
	end
	
	--if (AAP.ActiveMap == 1 and AAP.Level > 24 and AAP.Level < 60) then
	--	AAP.ActiveMap = "1-25-STV"
	--end
	if (AAP.ActiveMap == 90 and AAP.Level > 19 and AAP.Level < 60) then
		AAP.ActiveMap = "90-20Silverpine"
	end
	if (AAP.ActiveMap == 18 and AAP.Level > 19 and AAP.Level < 60) then
		AAP.ActiveMap = "18-20Silverpine"
	end
	if (AAP.ActiveMap == 18 and AAP.Level > 59 and AAP.Level < 80) then
		AAP.ActiveMap = "18-60-80"
	end
	if (AAP.ActiveMap == 18 and AAP.Level > 79 and AAP.Level < 90) then
		AAP.ActiveMap = "18-80-90"
	end
	if (AAP.ActiveMap == 1 and AAP.Level > 59 and AAP.Level < 80) then
		AAP.ActiveMap = "1-60to80"
	end
	if (AAP.ActiveMap == 1 and AAP.Level > 79 and AAP.Level < 90) then
		AAP.ActiveMap = "1-80to90"
	end
	if (AAP.Faction == "Horde" and AAP.ActiveMap == 22 and AAP.Level > 19 and AAP.Level < 63) then
		AAP.ActiveMap = "22-20-63"
		if (AAP.Level >	59) then
			levelcheck = 1
		end
	end
	if (AAP.Faction == "Horde" and AAP.ActiveMap == 23 and AAP.Level > 19 and AAP.Level < 63) then
		AAP.ActiveMap = "23-20-63"
		if (AAP.Level >	59) then
			levelcheck = 1
		end
	end
	if (AAP.Faction == "Horde" and AAP.ActiveMap == 217 and AAP.Level > 19 and AAP.Level < 63) then
		AAP.ActiveMap = "217-20-63"
		if (AAP.Level >	59) then
			levelcheck = 1
		end
	end
	if (AAP.Faction == "Horde" and AAP.ActiveMap == 21 and AAP.Level > 19 and AAP.Level < 63) then
		AAP.ActiveMap = "21-20-63"
		if (AAP.Level >	59) then
			levelcheck = 1
		end
	end
	if (AAP.Faction == "Horde" and AAP.ActiveMap == 25 and AAP.Level > 19 and AAP.Level < 63) then
		AAP.ActiveMap = "25-20-63"
		if (AAP.Level >	59) then
			levelcheck = 1
		end
	end
	if (AAP.Faction == "Horde" and AAP.ActiveMap == 224 and AAP.Level > 19 and AAP.Level < 63) then
		AAP.ActiveMap = "224-20-63"
		if (AAP.Level >	59) then
			levelcheck = 1
		end
	end
	
	if (AAP.Faction == "Horde" and AAP.ActiveMap == 114 and AAP.Level > 59 and AAP.Level < 83) then
		AAP.ActiveMap = "114-60-83"
		if (AAP.Level >	79) then
			levelcheck80 = 1
		end
	end
	if (AAP.Faction == "Horde" and AAP.ActiveMap == 127 and AAP.Level > 59 and AAP.Level < 83) then
		AAP.ActiveMap = "127-60-83"
		if (AAP.Level >	79) then
			levelcheck80 = 1
		end
	end
	if (AAP.Faction == "Horde" and AAP.ActiveMap == 115 and AAP.Level > 59 and AAP.Level < 83) then
		AAP.ActiveMap = "115-60-83"
		if (AAP.Level >	79) then
			levelcheck80 = 1
		end
	end
	if (AAP.Faction == "Horde" and AAP.ActiveMap == 116 and AAP.Level > 59 and AAP.Level < 83) then
		AAP.ActiveMap = "116-60-83"
		if (AAP.Level >	79) then
			levelcheck80 = 1
		end
	end
	if (AAP.Faction == "Horde" and AAP.ActiveMap == 121 and AAP.Level > 59 and AAP.Level < 83) then
		AAP.ActiveMap = "121-60-83"
		if (AAP.Level >	79) then
			levelcheck80 = 1
		end
	end
	if (AAP.Faction == "Horde" and AAP.ActiveMap == 100 and AAP.Level > 59 and AAP.Level < 83) then
		AAP.ActiveMap = "100-60-83"
		if (AAP.Level >	79) then
			levelcheck80 = 1
		end
	end
	if (AAP.Faction == "Horde" and AAP.ActiveMap == 102 and AAP.Level > 59 and AAP.Level < 83) then
		AAP.ActiveMap = "102-60-83"
		if (AAP.Level >	79) then
			levelcheck80 = 1
		end
	end
	if (AAP.Faction == "Horde" and AAP.ActiveMap == 108 and AAP.Level > 59 and AAP.Level < 83) then
		AAP.ActiveMap = "108-60-83"
		if (AAP.Level >	79) then
			levelcheck80 = 1
		end
	end
	if (AAP.Faction == "Horde" and AAP.ActiveMap == 107 and AAP.Level > 59 and AAP.Level < 83) then
		AAP.ActiveMap = "107-60-83"
		if (AAP.Level >	79) then
			levelcheck80 = 1
		end
	end
	if (AAP.Faction == "Horde" and AAP.ActiveMap == 198 and AAP.Level > 79 and AAP.Level < 93) then
		AAP.ActiveMap = "198-80-93"
		if (AAP.Level >	89) then
			levelcheck90 = 1
		end
	end
	if (AAP.Faction == "Horde" and AAP.ActiveMap == 12 and AAP.Level > 79 and AAP.Level < 93) then
		AAP.ActiveMap = "12-80-93"
		if (AAP.Level >	89) then
			levelcheck90 = 1
		end
	end
	if (AAP.Faction == "Horde" and AAP.ActiveMap == 371 and AAP.Level > 79 and AAP.Level < 93) then
		AAP.ActiveMap = "371-80-93"
		if (AAP.Level >	89) then
			levelcheck90 = 1
		end
	end
	if (AAP.Faction == "Horde" and AAP.ActiveMap == 433 and AAP.Level > 79 and AAP.Level < 94) then
		AAP.ActiveMap = "433-80-93"
		if (AAP.Level >	89) then
			levelcheck90 = 1
		end
	end
	if (AAP.Faction == "Horde" and AAP.ActiveMap == 379 and AAP.Level > 79 and AAP.Level < 94) then
		AAP.ActiveMap = "379-80-93"
		if (AAP.Level >	89) then
			levelcheck90 = 1
		end
	end


	
	

	if (AAP.ActiveMap == 627 and AAP.Level > 109) then
		AAP.ActiveMap = "627-110"
	end
	if (AAP.Faction == "Alliance" and AAP.ActiveMap == "A830" and AAP.Level == 20 and AAP.Race == "LightforgedDraenei") then
		AAP.ActiveMap = "A830-20"
	end
	if (AAP.Faction == "Alliance" and AAP.ActiveMap == "A84" and AAP.Level > 19 and AAP.Level < 60 and (IsQuestFlaggedCompleted(26504) == false) and (IsQuestFlaggedCompleted(26726) == false)) then
		AAP.ActiveMap = "A84-LF-20"
	end
	if (AAP.Faction == "Alliance" and AAP.ActiveMap == "A37" and AAP.Level > 19 and AAP.Level < 60 and (IsQuestFlaggedCompleted(26504) == false) and (IsQuestFlaggedCompleted(26726) == false)) then
		AAP.ActiveMap = "A37-20"
	end
	if (AAP.Faction == "Alliance" and AAP.ActiveMap == "A56" and AAP.Level > 19 and AAP.Level < 63) then
		AAP.ActiveMap = "A56-20-63"
		if (AAP.Level >	59) then
			levelcheck = 1
		end
	end
	if (AAP.Faction == "Alliance" and AAP.ActiveMap == "A23" and AAP.Level > 19 and AAP.Level < 63) then
		AAP.ActiveMap = "A23-20-63"
		if (AAP.Level >	59) then
			levelcheck = 1
		end
	end
	if (AAP.Faction == "Alliance" and AAP.ActiveMap == "A22" and AAP.Level > 19 and AAP.Level < 63) then
		AAP.ActiveMap = "A22-20-63"
		if (AAP.Level >	59) then
			levelcheck = 1
		end
	end
	if (AAP.Faction == "Alliance" and AAP.ActiveMap == "A224" and AAP.Level > 19 and AAP.Level < 63) then
		AAP.ActiveMap = "A224-20-63"
		if (AAP.Level >	59) then
			levelcheck = 1
		end
	end
	if (AAP.Faction == "Alliance" and AAP.ActiveMap == "A47" and AAP.Level > 19 and AAP.Level < 63) then
		AAP.ActiveMap = "A47-20-63"
		if (AAP.Level >	59) then
			levelcheck = 1
		end
	end
	if (AAP.Faction == "Alliance" and AAP.ActiveMap == "A49" and AAP.Level > 19 and AAP.Level < 63) then
		AAP.ActiveMap = "A49-20-63"
		if (AAP.Level >	59) then
			levelcheck = 1
		end
	end
	if (AAP.Faction == "Alliance" and AAP.ActiveMap == "A48" and AAP.Level > 19 and AAP.Level < 63) then
		AAP.ActiveMap = "A48-20-63"
		if (AAP.Level >	59) then
			levelcheck = 1
		end
	end
	
	if (AAP.Faction == "Alliance" and AAP.ActiveMap == "A14" and AAP.Level > 19 and AAP.Level < 63 and (AAP.ActiveQuests[26139] or IsQuestFlaggedCompleted(26139) == true)) then
		AAP.ActiveMap = "A14-20-63"
		if (AAP.Level >	59) then
			levelcheck = 1
		end
	end
	if (AAP.Faction == "Alliance" and AAP.ActiveMap == "A84" and AAP.Level > 59 and AAP.Level < 80) then
		AAP.ActiveMap = "A84-Flight-Northrend"
	end
	
	
	
	--levelcheck = 1
	if (levelcheck == 1) then
		AAP.Dinged60 = 1
	else
		AAP.Dinged60 = 0
	end
	if (levelcheck80 == 1) then
		AAP.Dinged80 = 1
	else
		AAP.Dinged80 = 0
	end
	if (levelcheck90 == 1) then
		AAP.Dinged90 = 1
	else
		AAP.Dinged90 = 0
	end
	
	if (not AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]) then
		AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = 1
	end
	local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
	if (CurStep and AAP.QuestStepList[AAP.ActiveMap] and AAP.QuestStepList[AAP.ActiveMap][CurStep]) then
	else
		AAP.BookingList["ClosedSettings"] = 1
	end
end
local function AAP_CheckZonePick()
	if (AAP.ActiveMap == 862) then
		if (IsQuestFlaggedCompleted(50963) == false and (AAP.ActiveQuests[47514] or IsQuestFlaggedCompleted(47514) == true)) then
			AAP.BookingList["UpdateMapId"] = 1
			AAP.BookingList["PrintQStep"] = 1
		elseif ((AAP.ActiveQuests[47513] or IsQuestFlaggedCompleted(47513) == true) and IsQuestFlaggedCompleted(47315) == false) then
			AAP.BookingList["UpdateMapId"] = 1
			AAP.BookingList["PrintQStep"] = 1
		elseif ((AAP.ActiveQuests[47512] or IsQuestFlaggedCompleted(47512) == true) and IsQuestFlaggedCompleted(47105) == false) then
			AAP.BookingList["UpdateMapId"] = 1
			AAP.BookingList["PrintQStep"] = 1
		elseif (IsQuestFlaggedCompleted(47105) == true and IsQuestFlaggedCompleted(47315) == true and IsQuestFlaggedCompleted(50963) == true) then
			AAP.BookingList["UpdateMapId"] = 1
			AAP.BookingList["PrintQStep"] = 1
		end
	end
end
local function AAP_CheckDistance()
	local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
	if (CurStep and AAP.QuestStepList[AAP.ActiveMap] and AAP.QuestStepList[AAP.ActiveMap][CurStep]) then
		if (AAP.QuestStepList[AAP.ActiveMap][CurStep]["CRange"]) then
			AAP.ArrowFrame.Button:Show()
			local plusnr = CurStep
			local Distancenr = 0
			local testad = true
			if (AAP.QuestStepList[AAP.ActiveMap][CurStep]["NoExtraRange"]) then
				testad = false
			end
			while testad do
				local oldx = AAP.QuestStepList[AAP.ActiveMap][plusnr]["TT"]["x"]
				local oldy = AAP.QuestStepList[AAP.ActiveMap][plusnr]["TT"]["y"]
				plusnr = plusnr + 1
				if (AAP.QuestStepList[AAP.ActiveMap][plusnr] and AAP.QuestStepList[AAP.ActiveMap][plusnr]["CRange"]) then
					local newx = AAP.QuestStepList[AAP.ActiveMap][plusnr]["TT"]["x"]
					local newy = AAP.QuestStepList[AAP.ActiveMap][plusnr]["TT"]["y"]
					local deltaX, deltaY = oldx - newx, newy - oldy
					local distance = (deltaX * deltaX + deltaY * deltaY)^0.5
					Distancenr = Distancenr + distance
				else
					if (AAP.QuestStepList[AAP.ActiveMap][plusnr] and AAP.QuestStepList[AAP.ActiveMap][plusnr]["TT"]) then
						local newx = AAP.QuestStepList[AAP.ActiveMap][plusnr]["TT"]["x"]
						local newy = AAP.QuestStepList[AAP.ActiveMap][plusnr]["TT"]["y"]
						local deltaX, deltaY = oldx - newx, newy - oldy
						local distance = (deltaX * deltaX + deltaY * deltaY)^0.5
						Distancenr = Distancenr + distance
					end
					return floor(Distancenr + 0.5)
				end
			end
		end
	end
	return 0
end
local function AAP_SetQPTT()
	if (AAP.SettingsOpen == 1) then
		return
	end
	local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
	if (QNumberLocal ~= CurStep and AAP.QuestStepList and AAP.QuestStepList[AAP.ActiveMap] and AAP.QuestStepList[AAP.ActiveMap][CurStep] and AAP.QuestStepList[AAP.ActiveMap][CurStep]["TT"]) then
		AAP.ArrowActive = 1
		AAP.ArrowActive_X = AAP.QuestStepList[AAP.ActiveMap][CurStep]["TT"]["x"]
		AAP.ArrowActive_Y = AAP.QuestStepList[AAP.ActiveMap][CurStep]["TT"]["y"]
		QNumberLocal = CurStep
		AAP["Icons"][1].A = 1
	end
end
local function AAP_Heirloomscheck()
	AAP.Heirlooms = 0
	for slots2 = 0,18 do
		if (slots2 == 1 or slots2 == 3 or slots2 == 5 or slots2 == 7 or slots2 == 11 or slots2 == 12 or slots2 == 15) then
			local itemLink = GetInventoryItemLink("player", slots2)
			if (itemLink) then
				local _, _, quality, _, _, _, _, _, SpotName = GetItemInfo(itemLink)
				if (quality and quality == 7) then
					AAP.Heirlooms = AAP.Heirlooms + 1
				end
			end
		end
	end
	AAP.BookingList["PrintQStep"] = 1
end
local function AAP_PosTest()
	if (AAP1 and AAP1[AAP.Realm][AAP.Name] and AAP1[AAP.Realm][AAP.Name]["Settings"] and AAP1[AAP.Realm][AAP.Name]["Settings"]["ShowArrow"] == 0) then
		AAP.ArrowActive = 0
		AAP.ArrowFrame:Hide()
		
		AAP.RemoveIcons()
	else
		local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
		if (AAP.QuestStepList[AAP.ActiveMap] and AAP.QuestStepList[AAP.ActiveMap][CurStep] and AAP.QuestStepList[AAP.ActiveMap][CurStep]["AreaTriggerZ"]) then
			local d_y, d_x = UnitPosition("player")
			x = AAP.QuestStepList[AAP.ActiveMap][CurStep]["AreaTriggerZ"]["x"]
			y = AAP.QuestStepList[AAP.ActiveMap][CurStep]["AreaTriggerZ"]["y"]
			local deltaX, deltaY = d_x - x, y - d_y
			local distance = (deltaX * deltaX + deltaY * deltaY)^0.5
			if (AAP.QuestStepList[AAP.ActiveMap][CurStep]["AreaTriggerZ"]["R"] > distance) then
				AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
				QNumberLocal = 0
				AAP.BookingList["UpdateQuest"] = 1
				AAP.BookingList["PrintQStep"] = 1
			end
		end
		if ((AAP.ArrowActive == 0) or (AAP.ArrowActive_X == 0) or (IsInInstance())) then
			AAP.ArrowActive = 0
			AAP.ArrowFrame:Hide()
			AAP.RemoveIcons()
		else
			AAP.ArrowFrame:Show()
			AAP.ArrowFrame.Button:Hide()
			local d_y, d_x = UnitPosition("player")
			if (d_x and d_y) then
				x = AAP.ArrowActive_X
				y = AAP.ArrowActive_Y
				local AAP_ArrowActive_TrigDistance
				local PI2 = math.pi * 2
				local atan2 = math.atan2
				local twopi = math.pi * 2
				local deltaX, deltaY = d_x - x, y - d_y
				local distance = (deltaX * deltaX + deltaY * deltaY)^0.5
				local angle = atan2(-deltaX, deltaY)
				local player = GetPlayerFacing()
				angle = angle - player
				local perc = math.abs((math.pi - math.abs(angle)) / math.pi)
				if perc > 0.98 then
					AAP.ArrowFrame.arrow:SetVertexColor(0,1,0)
				elseif perc > 0.49 then
					AAP.ArrowFrame.arrow:SetVertexColor((1-perc)*2,1,0)
				else
					AAP.ArrowFrame.arrow:SetVertexColor(1,perc*2,0)
				end
				local cell = floor(angle / twopi * 108 + 0.5) % 108
				local col = cell % 9
				local row = floor(cell / 9)
				AAP.ArrowFrame.arrow:SetTexCoord((col * 56) / 512,((col + 1) * 56) / 512,(row * 42) / 512,((row + 1) * 42) / 512)
				AAP.ArrowFrame.distance:SetText(floor(distance + AAP_CheckDistance()) .. " "..AAP_Locals["Yards"])
				local AAP_ArrowActive_Distance = 0
				if (CurStep and AAP.ActiveMap and AAP.QuestStepList[AAP.ActiveMap] and AAP.QuestStepList[AAP.ActiveMap][CurStep]) then
					if (AAP.QuestStepList[AAP.ActiveMap][CurStep]["Trigger"]) then
						local d_y, d_x = UnitPosition("player")
						local AAP_ArrowActive_Trigger_X = AAP.QuestStepList[AAP.ActiveMap][CurStep]["Trigger"]["x"]
						local AAP_ArrowActive_Trigger_Y = AAP.QuestStepList[AAP.ActiveMap][CurStep]["Trigger"]["y"]
						local deltaX, deltaY = d_x - AAP_ArrowActive_Trigger_X, AAP_ArrowActive_Trigger_Y - d_y
						AAP_ArrowActive_Distance = (deltaX * deltaX + deltaY * deltaY)^0.5
						AAP_ArrowActive_TrigDistance = AAP.QuestStepList[AAP.ActiveMap][CurStep]["Range"]
						if (AAP.QuestStepList[AAP.ActiveMap][CurStep]["HIDEME"]) then
							AAP.ArrowActive = 0
						end
					end
				end
				if (distance < 5 and AAP_ArrowActive_Distance == 0) then
					AAP.ArrowActive_X = 0
				elseif (AAP_ArrowActive_Distance and AAP_ArrowActive_TrigDistance and AAP_ArrowActive_Distance < AAP_ArrowActive_TrigDistance) then
					AAP.ArrowActive_X = 0
					if (CurStep and AAP.ActiveMap and AAP.QuestStepList[AAP.ActiveMap] and AAP.QuestStepList[AAP.ActiveMap][CurStep]) then
						if (AAP.QuestStepList[AAP.ActiveMap][CurStep]["CRange"]) then
							AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
							QNumberLocal = 0
							AAP.BookingList["UpdateQuest"] = 1
							AAP.BookingList["PrintQStep"] = 1
						end
					end
				end
			end
		end
	end
end
local function AAP_LoopBookingFunc()
	if (AAP.BookingList["OpenedSettings"]) then
		AAP.BookingList["OpenedSettings"] = nil
		AAP.ArrowActive = 1
		AAP.ArrowActive_Y, AAP.ArrowActive_X = UnitPosition("player")
		QNumberLocal = 0
		AAP.ArrowActive_Y = AAP.ArrowActive_Y + 150
		AAP.ArrowActive_X = AAP.ArrowActive_X + 150
		AAP["Icons"][1].A = 1
		AAP.BookingList["PrintQStep"] = 1
	elseif (AAP.BookingList["ClosedSettings"]) then
		AAP.BookingList["ClosedSettings"] = nil
		QNumberLocal = 0
		AAP.ArrowActive = 0
		AAP.RemoveIcons()
		local CLi
		for CLi = 1, 10 do
			AAP.QuestList.QuestFrames[CLi]:Hide()
			AAP.QuestList.QuestFrames["FS"..CLi]["Button"]:Hide()
			AAP.QuestList2["BF"..CLi]:Hide()
		end
		AAP.BookingList["UpdateQuest"] = 1
		AAP.BookingList["PrintQStep"] = 1
	elseif (AAP.BookingList["UpdateMapId"]) then
		AAP.BookingList["UpdateMapId"] = nil
		AAP_UpdateMapId()
		if (AAP1["Debug"]) then
			print("LoopBookingFunc:UpdateMapId:"..AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap])
		end
	elseif (AAP.BookingList["AcceptQuest"]) then
		AAP.BookingList["AcceptQuest"] = nil
		AcceptQuest()
	elseif (AAP.BookingList["CompleteQuest"]) then
		AAP.BookingList["CompleteQuest"] = nil
		CompleteQuest()
	elseif (AAP.BookingList["CreateMacro"]) then
		AAP.BookingList["CreateMacro"] = nil
		AAP_CreateMacro()
	elseif (AAP.BookingList["AddQuest"]) then
		if (AAP1["Debug"]) then
			print("LoopBookingFunc:AddQuest:"..AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap])
		end
		AAP_AddQuest(AAP.BookingList["AddQuest"])
		AAP.BookingList["AddQuest"] = nil
	elseif (AAP.BookingList["RemoveQuest"]) then
		if (AAP1["Debug"]) then
			print("LoopBookingFunc:RemoveQuest:"..AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap])
		end
		AAP_RemoveQuest(AAP.BookingList["RemoveQuest"])
		AAP.BookingList["RemoveQuest"] = nil
		AAP.BookingList["UpdateMapId"] = 1
		AAP.BookingList["PrintQStep"] = 1
	elseif (AAP.BookingList["UpdateQuest"]) then
		if (AAP1["Debug"]) then
			print("LoopBookingFunc:UpdateQuest:"..AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap])
		end
		AAP.BookingList["UpdateQuest"] = nil
		AAP_UpdateQuest()
	elseif (AAP.BookingList["PrintQStep"]) then
		if (AAP1["Debug"]) then
			print("LoopBookingFunc:PrintQStep:"..AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap])
		end
		AAP.BookingList["PrintQStep"] = nil
		AAP_PrintQStep()
	elseif (AAP.BookingList["UpdateILVLGear"]) then
		AAP.BookingList["UpdateILVLGear"] = nil
		AAP_UpdateILVLGear()
	elseif (AAP.BookingList["CheckSaveOldSlot"]) then
		AAP.BookingList["CheckSaveOldSlot"] = nil
		AAP_CheckSaveOldSlot()
	elseif (AAP.BookingList["CheckZonePick"]) then
		AAP.BookingList["CheckZonePick"] = nil
		AAP_CheckZonePick()
	elseif (AAP.BookingList["SetQPTT"]) then
		AAP.BookingList["SetQPTT"] = nil
		AAP_SetQPTT()
	elseif (AAP.BookingList["UseTaxiFunc"]) then
		AAP.BookingList["UseTaxiFunc"] = nil
		AAP_UseTaxiFunc()
	elseif (AAP.BookingList["TestTaxiFunc"]) then
		AAP_AntiTaxiLoop = AAP_AntiTaxiLoop + 1
		if (UnitOnTaxi("player")) then
			AAP.BookingList["TestTaxiFunc"] = nil
			AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
			AAP.BookingList["PrintQStep"] = 1
			AAP_AntiTaxiLoop = 0
		elseif (AAP_AntiTaxiLoop == 50 or AAP_AntiTaxiLoop == 100 or AAP_AntiTaxiLoop == 150) then
			--TaxiNodeOnButtonEnter(getglobal("TaxiButton"..AAP.BookingList["TestTaxiFunc"]))
			TakeTaxiNode(AAP.BookingList["TestTaxiFunc"])
		end
		if (AAP_AntiTaxiLoop > 200) then
			print ("AAP: Error - AntiTaxiLoop")
			AAP.BookingList["TestTaxiFunc"] = nil
			AAP_AntiTaxiLoop = 0
		end
	elseif (AAP.BookingList["SkipCutscene"]) then
		AAP.BookingList["SkipCutscene"] = nil
		CinematicFrame_CancelCinematic()
	elseif (AAP.BookingList["MoveIcons"]) then
		AAP.BookingList["MoveIcons"] = nil
		AAP:MoveIcons()
	elseif (AAP.BookingList["ButtonSpellidchk"]) then
		for AAP_index,AAP_value in pairs(AAP.BookingList["ButtonSpellidchk"]) do
			if (AAP_value) then
				local _, duration = GetItemCooldown(AAP_value)
				if (duration and duration > 0 and AAP_index and AAP.QuestList2 and AAP.QuestList2["BF"..AAP_index] and AAP.QuestList2["BF"..AAP_index]["AAP_ButtonCD"]) then
					AAP.QuestList2["BF"..AAP_index]["AAP_ButtonCD"]:SetCooldown(GetTime(), duration)
				end
			end
		end
		AAP.BookingList["ButtonSpellidchk"] = nil
	elseif (AAP.BookingList["Heirloomscheck"]) then
		AAP.BookingList["Heirloomscheck"] = nil
		AAP_Heirloomscheck()
	end
	if (AAP_ArrowUpdateNr > 1) then
		AAP_PosTest()
		AAP_ArrowUpdateNr = 0
	else
		AAP_ArrowUpdateNr = AAP_ArrowUpdateNr + 1
	end
end
local function AAP_BuyMerchFunc()
	local i
	for i=1,GetMerchantNumItems() do
		local link = GetMerchantItemLink(i)
		if (link) then
			local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, Name = string.find(link, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
			if (tonumber(Id) == 160499) then
				BuyMerchantItem(i)
				MerchantFrame:Hide()
				return 1
			end
		end
	end
	return 0
end
local function AAP_PopupFunc()
	if (GetNumAutoQuestPopUps() > 0) then
		local questID, popUpType = GetAutoQuestPopUp(1)
		if(popUpType == "OFFER") then
			ShowQuestOffer(GetQuestLogIndexByID(questID))
		else
			ShowQuestComplete(GetQuestLogIndexByID(questID))
		end
	else
		C_Timer.After(1, AAP_PopupFunc)
	end
end
function AAP_BookQStep()
	AAP.BookingList["UpdateQuest"] = 1
	AAP.BookingList["PrintQStep"] = 1
	if (AAP1["Debug"]) then
		print("Extra BookQStep")
	end
end

AAP.LoopBooking = CreateFrame("frame")
AAP.LoopBooking:SetScript("OnUpdate", AAP_LoopBookingFunc)

AAP_QH_EventFrame = CreateFrame("Frame")
AAP_QH_EventFrame:RegisterEvent ("QUEST_REMOVED")
AAP_QH_EventFrame:RegisterEvent ("QUEST_ACCEPTED")
AAP_QH_EventFrame:RegisterEvent ("UNIT_QUEST_LOG_CHANGED")
AAP_QH_EventFrame:RegisterEvent ("PLAYER_EQUIPMENT_CHANGED")
AAP_QH_EventFrame:RegisterEvent ("ZONE_CHANGED")
AAP_QH_EventFrame:RegisterEvent ("ZONE_CHANGED_NEW_AREA")
AAP_QH_EventFrame:RegisterEvent ("UPDATE_MOUSEOVER_UNIT")
AAP_QH_EventFrame:RegisterEvent ("GOSSIP_SHOW")
AAP_QH_EventFrame:RegisterEvent ("UI_INFO_MESSAGE")
AAP_QH_EventFrame:RegisterEvent ("HEARTHSTONE_BOUND")
AAP_QH_EventFrame:RegisterEvent ("UNIT_SPELLCAST_SUCCEEDED")
AAP_QH_EventFrame:RegisterEvent ("UNIT_SPELLCAST_START")
AAP_QH_EventFrame:RegisterEvent ("QUEST_PROGRESS")
AAP_QH_EventFrame:RegisterEvent ("QUEST_DETAIL")
AAP_QH_EventFrame:RegisterEvent ("QUEST_COMPLETE")
AAP_QH_EventFrame:RegisterEvent ("TAXIMAP_OPENED")
AAP_QH_EventFrame:RegisterEvent ("MERCHANT_SHOW")
AAP_QH_EventFrame:RegisterEvent ("QUEST_GREETING")
AAP_QH_EventFrame:RegisterEvent ("ITEM_PUSH")
AAP_QH_EventFrame:RegisterEvent ("QUEST_AUTOCOMPLETE")
AAP_QH_EventFrame:RegisterEvent ("QUEST_ACCEPT_CONFIRM")
AAP_QH_EventFrame:RegisterEvent ("UNIT_ENTERED_VEHICLE")
AAP_QH_EventFrame:RegisterEvent ("QUEST_CHOICE_UPDATE")
AAP_QH_EventFrame:RegisterEvent ("PLAYER_REGEN_ENABLED")
AAP_QH_EventFrame:RegisterEvent ("PLAYER_REGEN_DISABLED")
AAP_QH_EventFrame:RegisterEvent ("QUEST_CHOICE_UPDATE")


AAP_QH_EventFrame:SetScript("OnEvent", function(self, event, ...)
	if (event=="PLAYER_REGEN_ENABLED") then
		AAP.InCombat = 0
		if (AAP.BookUpdAfterCombat == 1) then
			AAP.BookingList["PrintQStep"] = 1
		end
	end
	if (event=="PLAYER_REGEN_DISABLED") then
		AAP.InCombat = 1
	end
	if (event=="QUEST_CHOICE_UPDATE") then
		local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
		local steps
		if (CurStep and AAP.QuestStepList and AAP.QuestStepList[AAP.ActiveMap]) then
			steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
		end
		local choiceID, questionText, numOptions = GetQuestChoiceInfo()
		if (numOptions and numOptions > 1 and steps and steps["PickUpSpecial"]) then
			local CLi
			for CLi = 1, numOptions do
				local optionID, buttonText, description, artFile = GetQuestChoiceOptionInfo(CLi)
				if (steps["PickUpSpecial"] == optionID) then
					SendQuestChoiceResponse(GetQuestChoiceOptionInfo(CLi))
					AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
					AAP.BookingList["UpdateQuest"] = 1
					AAP.BookingList["PrintQStep"] = 1
					break
				end
			end
		end
	end
	if (event=="UNIT_ENTERED_VEHICLE") then
		local arg1, arg2, arg3, arg4, arg5 = ...;
		if (arg1 == "player") then
			local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
			local steps
			if (CurStep and AAP.QuestStepList and AAP.QuestStepList[AAP.ActiveMap]) then
				steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
				if (steps and steps["InVehicle"]) then
					AAP.BookingList["PrintQStep"] = 1
				end
			end
		end
	end
	if (event=="QUEST_AUTOCOMPLETE") then
		local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
		local steps
		if (CurStep and AAP.QuestStepList and AAP.QuestStepList[AAP.ActiveMap]) then
			steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
		end
		if(AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoHandIn"] == 1 and not IsControlKeyDown()) then
			if (steps and steps["SpecialNoAutoHandin"]) then
			else
				AAP_PopupFunc()
			end
		end
	end
	if (event=="QUEST_ACCEPT_CONFIRM") then
		if (AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoAccept"] == 1 and not IsControlKeyDown()) then
			AcceptQuest()
		end
	end
	if (event=="QUEST_GREETING") then
		local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
		local steps
		if (CurStep and AAP.QuestStepList and AAP.QuestStepList[AAP.ActiveMap]) then
			steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
		end
		if (steps and steps["SpecialNoAutoHandin"]) then
			return
		end
		if (UnitGUID("target") and string.find(UnitGUID("target"), "(.*)-(.*)")) then
			local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",UnitGUID("target"))
			if (npc_id and ((tonumber(npc_id) == 141584) or (tonumber(npc_id) == 142063) or (tonumber(npc_id) == 25809))) then
				return
			end
		end
		local numAvailableQuests = 0;
		local numActiveQuests = 0;
		local lastActiveQuest = 0
		local lastAvailableQuest = 0;
		numAvailableQuests = GetNumAvailableQuests();
		numActiveQuests = GetNumActiveQuests();
		if numAvailableQuests > 0 or numActiveQuests > 0 then
			local guid = UnitGUID("target");
			if lastNPC ~= guid then
				lastActiveQuest = 1;
				lastAvailableQuest = 1;
				lastNPC = guid;
			end
			if (lastAvailableQuest > numAvailableQuests) then
				lastAvailableQuest = 1;
			end    
			for i = lastAvailableQuest, numAvailableQuests do
				lastAvailableQuest = i;
				if (AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoAccept"] == 1 and not IsControlKeyDown()) then
					SelectAvailableQuest(i);
				end
			end
		end
		if lastActiveQuest > numActiveQuests then
			lastActiveQuest = 1;
		end
		if (AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoHandIn"] == 1 and not IsControlKeyDown()) then
			local TempQList = {}
			local i = 1
			local UpdateQpart = 0
			while GetQuestLogTitle(i) do
				local questTitle, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID = GetQuestLogTitle(i)
				if (questID > 0) then
					if (not isHeader) then
						TempQList[questID] = {}
						if (isComplete) then
							TempQList[questID]["C"] = 1
						end
						TempQList[questID]["T"] = questTitle
					end
				end
				i = i + 1
			end
			local CLi
			for CLi = 1, numActiveQuests do
				for CL_index,CL_value in pairs(TempQList) do
					if (GetActiveTitle(CLi) == TempQList[CL_index]["T"] and TempQList[CL_index]["C"] and TempQList[CL_index]["C"] == 1) then
						SelectActiveQuest(CLi)
					end
				end
			end
		end
	end
	if (event=="ITEM_PUSH") then
		local arg1, arg2, arg3, arg4, arg5 = ...;
		local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
		local steps
		if (CurStep and AAP.QuestStepList and AAP.QuestStepList[AAP.ActiveMap]) then
			steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
		end
		if (AAP1["Debug"]) then
			print(arg2)
		end
		if (steps and 133717 == arg2 and steps["ExtraLine"] == 89) then		
			AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
			AAP.BookingList["UpdateQuest"] = 1
			AAP.BookingList["PrintQStep"] = 1
		end
		if (steps and 134754 == arg2 and steps["ExtraLine"] == 81) then		
			AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
			AAP.BookingList["UpdateQuest"] = 1
			AAP.BookingList["PrintQStep"] = 1
		end
		if (steps and 133798 == arg2 and steps["ExtraLine"] == 79) then		
			AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
			AAP.BookingList["UpdateQuest"] = 1
			AAP.BookingList["PrintQStep"] = 1
		end
		if (steps and 132394 == arg2 and steps["ExtraLine"] == 67) then		
			AAP.BookingList["PrintQStep"] = 1
			C_Timer.After(1, AAP_BookQStep)
		end
		if (steps and 237425 == arg2 and steps["ExtraLine"] == 43) then
			AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
			AAP.BookingList["UpdateQuest"] = 1
			AAP.BookingList["PrintQStep"] = 1
		end
		if (steps and 134241 == arg2 and steps["ExtraLine"] == 58) then
			AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
			AAP.BookingList["UpdateQuest"] = 1
			AAP.BookingList["PrintQStep"] = 1
		end
		if (steps and 134241 == arg2 and steps["ExtraLine"] == 38) then
			AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
			AAP.BookingList["UpdateQuest"] = 1
		end
		AAP.BookingList["PrintQStep"] = 1
		C_Timer.After(1, AAP_BookQStep)
	end
	if (event=="MERCHANT_SHOW") then
		local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
		local steps
		if (CurStep and AAP.QuestStepList and AAP.QuestStepList[AAP.ActiveMap] and AAP.QuestStepList[AAP.ActiveMap][CurStep]) then
			steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
		end
		if (steps and steps["BuyMerchant"]) then
				if (not IsControlKeyDown() and AAP_BuyMerchFunc() == 0) then
					C_Timer.After(0.1,print(AAP_BuyMerchFunc()))
				end
		end
		if (AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoRepair"] == 1) then
			if (CanMerchantRepair()) then	
				repairAllCost, canRepair = GetRepairAllCost();
				if (canRepair and repairAllCost > 0) then
					guildRepairedItems = false
					if (IsInGuild() and CanGuildBankRepair()) then
						local amount = GetGuildBankWithdrawMoney()
						local guildBankMoney = GetGuildBankMoney()
						amount = amount == -1 and guildBankMoney or min(amount, guildBankMoney)
						if (amount >= repairAllCost) then
							RepairAllItems(true);
							guildRepairedItems = true
							DEFAULT_CHAT_FRAME:AddMessage("AAP: Equipment has been repaired by your Guild")
						end
					end
					if (repairAllCost <= GetMoney() and not guildRepairedItems) then
						RepairAllItems(false);
						print("AAP: Equipment has been repaired for "..GetCoinTextureString(repairAllCost))
					end
				end
			end
		end
		if (AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoVendor"] == 1) then
			local AAPtotal = 0
			for myBags = 0,4 do
				for bagSlots = 1, GetContainerNumSlots(myBags) do
					local CurrentItemLink = GetContainerItemLink(myBags, bagSlots)
					if CurrentItemLink then
						local _, _, itemRarity, _, _, _, _, _, _, _, itemSellPrice = GetItemInfo(CurrentItemLink)
						local _, itemCount = GetContainerItemInfo(myBags, bagSlots)
						if itemRarity == 0 and itemSellPrice ~= 0 then
							AAPtotal = AAPtotal + (itemSellPrice * itemCount)
							UseContainerItem(myBags, bagSlots)
						end
					end
				end
			end
			if AAPtotal ~= 0 then
				print("AAP: Items were sold for "..GetCoinTextureString(AAPtotal))
			end
		end
	end
	if (event=="UI_INFO_MESSAGE") then
		local arg1, arg2, arg3, arg4, arg5 = ...;
		if (arg1 == 280) then
			local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
			local steps
			if (CurStep and AAP.QuestStepList and AAP.QuestStepList[AAP.ActiveMap]) then
				steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
			end
			if (steps and steps["GetFP"]) then
				AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
				AAP.BookingList["PrintQStep"] = 1
			end
		end
	end
	if (event=="TAXIMAP_OPENED") then
	
	--local CLi
	--for CLi = 1, NumTaxiNodes() do
	--	local aapx,aapy = TaxiNodePosition(CLi)
	--	aapx = (floor(aapx * 1000)/10)
	--	aapy = (floor(aapy * 1000)/10)
	--	if (TaxiNodeGetType(CLi) == "REACHABLE") then
	--		print(CLi .. "-" .. TaxiNodeName(CLi).."-X:"..aapx.."-Y:"..aapy.." Status: "..TaxiNodeGetType(CLi))
	--	end
	--end
	
	
	
	
	
		local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
		local steps
		if (CurStep and AAP.QuestStepList and AAP.QuestStepList[AAP.ActiveMap] and AAP.QuestStepList[AAP.ActiveMap][CurStep]) then
			steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
		end
		if (steps and steps["GetFP"] and not IsControlKeyDown()) then
			AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
			AAP.BookingList["PrintQStep"] = 1
		end
		if (steps and not IsControlKeyDown()) then
			if (steps["UseFlightPath"]) then
				AAP.BookingList["UseTaxiFunc"] = 1
			end
		end
	end
	if (event=="UNIT_SPELLCAST_SUCCEEDED") then
		local arg1, arg2, arg3, arg4, arg5 = ...;
		if (arg1 == "player" and arg3 == 85141) then
			local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
			local steps
			if (CurStep) then
				steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
			end
			if (steps and steps["ExtraLine"] and steps["ExtraLine"] == 55) then
				AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
				AAP.BookingList["PrintQStep"] = 1
			end
		end
		--print(arg3)
		if (arg1 == "player" and arg3 == 82788) then
			AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
			AAP.BookingList["PrintQStep"] = 1
		end
		if ((arg1 == "player") and (arg3 == 8690)) then
			local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
			local steps
			if (CurStep) then
				steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
			end
			if (steps and steps["UseHS"]) then
				AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
				AAP.BookingList["PrintQStep"] = 1
			end
		end
		if (arg1 == "player") then
			local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
			local steps
			if (CurStep and AAP.QuestStepList and AAP.ActiveMap and AAP.QuestStepList[AAP.ActiveMap] and AAP.QuestStepList[AAP.ActiveMap][CurStep]) then
				steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
			end
			if (steps and steps["ButtonSpellId"]) then
				for AAP_index,AAP_value in pairs(steps["ButtonSpellId"]) do
					if (arg3 == AAP_index) then
						for AAP_index2,AAP_value2 in pairs(AAP.ButtonList) do
							if (AAP_index2 == AAP_value) then
								if (not AAP.BookingList["ButtonSpellidchk"]) then
									AAP.BookingList["ButtonSpellidchk"] = {}
								end
								AAP.BookingList["ButtonSpellidchk"][AAP_value2] = steps["Button"][AAP_value]
							end
						end
					end
				end
			end
		end
	end
	if (event=="UNIT_SPELLCAST_START") then
		local arg1, arg2, arg3, arg4, arg5 = ...;
		if ((arg1 == "player") and (arg3 == 222695)) then
			local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
			local steps
			if (CurStep and AAP.QuestStepList and AAP.QuestStepList[AAP.ActiveMap]) then
				steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
			end
			if (steps and steps["UseDalaHS"]) then
				AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
			end
		end
	end
	if (event=="HEARTHSTONE_BOUND") then
		local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
		local steps
		if (CurStep and AAP.QuestStepList and AAP.QuestStepList[AAP.ActiveMap]) then
			steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
		end
		if (steps and steps["SetHS"]) then
			AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
			AAP.BookingList["PrintQStep"] = 1
		end
	end
	if (event=="QUEST_ACCEPTED") then
		local arg1, arg2, arg3, arg4, arg5 = ...;
		if (AAP1["Debug"]) then
			print("QUEST_ACCEPTED: ".. arg2)
		end
		if (arg2 and arg2 > 0 and not AAP.ActiveQuests[arg2]) then
			AAP.BookingList["AddQuest"] = arg2
		end
		local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
		if (CurStep and AAP.QuestStepList and AAP.ActiveMap and AAP.QuestStepList[AAP.ActiveMap] and AAP.QuestStepList[AAP.ActiveMap][CurStep]) then
			local steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
			if (steps and steps["ZonePick"]) then
				AAP.BookingList["CheckZonePick"] = 1
			end
			if (steps and steps["LoaPick"] and steps["LoaPick"] == 123 and (AAP.ActiveQuests[47440] or AAP.ActiveQuests[47439])) then
				AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
				AAP.BookingList["PrintQStep"] = 1
			end
		end
		C_Timer.After(3, AAP_BookQStep)
	end
	if (event=="QUEST_REMOVED") then
		if (AAP1["Debug"]) then
			print("QUEST_REMOVED")
		end
		local arg1, arg2, arg3, arg4, arg5 = ...;
		AAP.BookingList["RemoveQuest"] = arg1
	end
	if (event=="UNIT_QUEST_LOG_CHANGED") then
		local arg1, arg2, arg3, arg4, arg5 = ...;
		if (arg1 == "player") then
			AAP.BookingList["UpdateQuest"] = 1
		end
	end
	if (event=="PLAYER_EQUIPMENT_CHANGED") then
		AAP.BookingList["Heirloomscheck"] = 1
	end
	if (event=="ZONE_CHANGED") then
		AAP.BookingList["UpdateMapId"] = 1
	end
	if (event=="ZONE_CHANGED_NEW_AREA") then
		AAP.BookingList["UpdateMapId"] = 1
	end
	if (event=="GOSSIP_SHOW") then
		local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
		if (CurStep and AAP.QuestStepList[AAP.ActiveMap] and AAP.QuestStepList[AAP.ActiveMap][CurStep]) then
			if (UnitGUID("target") and string.find(UnitGUID("target"), "(.*)-(.*)")) then
				local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",UnitGUID("target"))
				if (npc_id and ((tonumber(npc_id) == 141584) or (tonumber(npc_id) == 142063) or (tonumber(npc_id) == 45400) or (tonumber(npc_id) == 25809))) then
					local steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
					if (steps and steps["Gossip"] and steps["Gossip"] == 27373) then
						SelectGossipOption(1)
						AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
						AAP.BookingList["PrintQStep"] = 1
					end
					return
				end
				if (npc_id and (tonumber(npc_id) == 43733)) then
					Dismount()
				end
			end
			local steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
			local AAPDenied = 0
			if (steps and steps["DenyNPC"]) then
				if (UnitGUID("target") and UnitName("target")) then
					local guid, name = UnitGUID("target"), UnitName("target")
					local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",guid);
					if (npc_id and name) then
						if (tonumber(npc_id) == steps["DenyNPC"]) then
							AAPDenied = 1
						end
					end
				end
			end
			if (steps and steps["SpecialNoAutoHandin"]) then
				return
			end
			if (AAPDenied == 1) then
				CloseGossip()
				print("AAP: Not Yet!")
			elseif (steps and steps["Gossip"] and AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoGossip"] == 1 and not IsControlKeyDown()) then
				if (steps["Gossip"] == 99) then
					SelectGossipOption(1)
					AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
					AAP.BookingList["PrintQStep"] = 1
				elseif (steps["Gossip"] == 12097) then
					SelectGossipOption(1)
					AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
					AAP.BookingList["PrintQStep"] = 1
				elseif (steps["Gossip"] == 11984) then
					SelectGossipOption(1)
					AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
					AAP.BookingList["PrintQStep"] = 1
				elseif (steps["Gossip"] == 26773) then
					SelectGossipOption(1)
					AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
				elseif (steps["Gossip"] == 26359) then
					SelectGossipOption(1)
					AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
				elseif (steps["Gossip"] == 26301) then
					SelectGossipOption(2)
				elseif (steps["Gossip"] == 999) then
					SelectGossipOption(1)
					AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
					AAP.BookingList["PrintQStep"] = 1
				elseif (steps["Gossip"] == 101) then
					SelectGossipOption(1)
					AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
					AAP.BookingList["PrintQStep"] = 1
				else
					SelectGossipOption(steps["Gossip"])
					if (steps["ExtraLine"] == 39) then
						AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap] + 1
						AAP.BookingList["PrintQStep"] = 1
					end
				end
			end
		end
		local arg1, arg2, arg3, arg4 = ...;
		local ActiveQuests = {GetGossipActiveQuests()}
		local ActiveQNr = GetNumGossipActiveQuests()
		local CLi
		local NumAvailableQuests = GetNumGossipAvailableQuests()
		local AvailableQuests = {GetGossipAvailableQuests()}
		if (ActiveQuests and AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoHandIn"] == 1 and not IsControlKeyDown()) then
			for CLi = 1, ActiveQNr do
				if (ActiveQuests[(((CLi-1) * 6)+4)] == true) then
					SelectGossipActiveQuest(CLi)
				end
			end
		end
		if (NumAvailableQuests > 0 and AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoAccept"] == 1 and not IsControlKeyDown()) then
			if (steps and steps["SpecialPickupOrder"]) then
				SelectGossipAvailableQuest(2)
			else
				SelectGossipAvailableQuest(1)
			end
		end
	end
	if (event=="QUEST_DETAIL") then
		if (UnitGUID("target") and string.find(UnitGUID("target"), "(.*)-(.*)")) then
			local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",UnitGUID("target"))
			if (npc_id and ((tonumber(npc_id) == 141584) or (tonumber(npc_id) == 142063) or (tonumber(npc_id) == 45400))) then
				return
			end
			if (npc_id and (tonumber(npc_id) == 43733)) then
				Dismount()
			end
			local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
			if (CurStep and AAP.ActiveMap and AAP.QuestStepList and AAP.QuestStepList[AAP.ActiveMap] and AAP.QuestStepList[AAP.ActiveMap][CurStep]) then
				local steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
				local AAPDenied = 0
				if (steps and steps["DenyNPC"]) then
					if (UnitGUID("target") and UnitName("target")) then
						local guid, name = UnitGUID("target"), UnitName("target")
						local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",guid);
						if (npc_id and name) then
							if (tonumber(npc_id) == steps["DenyNPC"]) then
								AAPDenied = 1
							end
						end
					end
				end
				if (AAPDenied == 1) then
					CloseQuest()
					print("AAP: Not Yet!")
				end
			end
		end
		if (GetQuestID() and (AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoAccept"] == 1) and (not IsControlKeyDown()) and (GetQuestID() ~= 50476) and (GetQuestID() ~= 52058) and (53372 ~= GetQuestID()) and (52946 ~= GetQuestID())) then
			if (27406 == GetQuestID()) then
				Dismount()
			end
			AAP.BookingList["AcceptQuest"] = 1
		end
	end
	if (event=="QUEST_PROGRESS") then
		if (AAP1["Debug"]) then
			print("QUEST_PROGRESS")
		end
		if (UnitGUID("target") and string.find(UnitGUID("target"), "(.*)-(.*)")) then
			local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",UnitGUID("target"))
			if (npc_id and ((tonumber(npc_id) == 141584) or (tonumber(npc_id) == 142063) or (tonumber(npc_id) == 45400))) then
				return
			end
		end
		local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
		local steps
		if (CurStep and AAP.QuestStepList and AAP.QuestStepList[AAP.ActiveMap]) then
			steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
		end
		if (AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoHandIn"] == 1 and not IsControlKeyDown()) then
			if (steps and steps["SpecialNoAutoHandin"]) then
				return
			end
			AAP.BookingList["CompleteQuest"] = 1
			if (AAP1["Debug"]) then
				print("Complete")
			end
		end
	end
	if (event=="QUEST_COMPLETE") then
		if (UnitGUID("target") and string.find(UnitGUID("target"), "(.*)-(.*)")) then
			local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",UnitGUID("target"))
			if (npc_id and ((tonumber(npc_id) == 141584) or (tonumber(npc_id) == 142063) or (tonumber(npc_id) == 45400))) then
				return
			end
		end
		if (GetNumQuestChoices() > 1) then
			if (AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoHandInChoice"] == 1) then
				local AAP_GearIlvlList = {}
				for slots2 = 0,18 do
					local itemLink = GetInventoryItemLink("player", slots2)
					if (itemLink) then
						local _, _, _, _, _, _, _, _, SpotName = GetItemInfo(itemLink)
						local ilvl = GetDetailedItemLevelInfo(itemLink)
						if (SpotName and ilvl) then
							if (SpotName == "INVTYPE_WEAPONOFFHAND") then
								SpotName = "INVTYPE_WEAPON"
							end
							if (SpotName == "INVTYPE_WEAPONMAINHAND") then
								SpotName = "INVTYPE_WEAPON"
							end
							if (AAP_GearIlvlList[SpotName]) then
								if (AAP_GearIlvlList[SpotName] > ilvl) then
									AAP_GearIlvlList[SpotName] = ilvl
								end
							else
								AAP_GearIlvlList[SpotName] = ilvl
							end
						end
					end
				end
				local AAPTempGearList = {}
				local isweaponz = 0
				local AAPColorof = 0
				for h=1, GetNumQuestChoices() do
					local _, _, ItemRarityz, _, _, _, _, _, SpotName = GetItemInfo(GetQuestItemLink("choice", h))
					local ilvl = GetDetailedItemLevelInfo(GetQuestItemLink("choice", h))
					if (AAP_GearIlvlList[SpotName]) then
						if (ItemRarityz > 2) then
							AAPColorof = ItemRarityz
						end
						AAPTempGearList[h] = ilvl - AAP_GearIlvlList[SpotName]
						if (SpotName == "INVTYPE_WEAPON" or SpotName == "INVTYPE_SHIELD" or SpotName == "INVTYPE_2HWEAPON" or SpotName == "INVTYPE_WEAPONMAINHAND" or SpotName == "INVTYPE_WEAPONOFFHAND" or SpotName == "INVTYPE_HOLDABLE" or SpotName == "INVTYPE_RANGED" or SpotName == "INVTYPE_THROWN" or SpotName == "INVTYPE_RANGEDRIGHT" or SpotName == "INVTYPE_RELIC") then
							isweaponz = 1
						end
					end
				end
				if (AAPColorof > 2) then
				elseif (isweaponz == 1) then

				else
					local PickOne = 0
					local PickOne2 = -99999
					for AAP_indexx,AAP_valuex in pairs(AAPTempGearList) do
						if (AAP_valuex > PickOne2) then
							PickOne = AAP_indexx
							PickOne2 = AAP_valuex
						end
					end
					if (PickOne > 0) then
						GetQuestReward(PickOne)
					end
				end
			end
		else
			local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
			local steps
			if (CurStep and AAP.QuestStepList and AAP.QuestStepList[AAP.ActiveMap]) then
				steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
			end
			if (AAP1[AAP.Realm][AAP.Name]["Settings"]["AutoHandIn"] == 1 and not IsControlKeyDown()) then
				if (steps and steps["SpecialNoAutoHandin"]) then
					return
				end
				if (UnitGUID("target") and string.find(UnitGUID("target"), "(.*)-(.*)")) then
					local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",UnitGUID("target"))
					if (npc_id and ((tonumber(npc_id) == 141584) or (tonumber(npc_id) == 142063) or (tonumber(npc_id) == 45400) or (tonumber(npc_id) == 25809))) then
						return
					end
				end
				GetQuestReward(1)
			end
		end
	end
	if (event=="UPDATE_MOUSEOVER_UNIT") then
		local CurStep = AAP1[AAP.Realm][AAP.Name][AAP.ActiveMap]
		if (CurStep and AAP.QuestStepList[AAP.ActiveMap] and AAP.QuestStepList[AAP.ActiveMap][CurStep]) then
			local steps = AAP.QuestStepList[AAP.ActiveMap][CurStep]
			if (steps and steps["RaidIcon"]) then
				local guid = UnitGUID("mouseover")
				if (guid) then
					local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",guid)
					if (npc_id and tonumber(steps["RaidIcon"]) == tonumber(npc_id)) then
						if (not GetRaidTargetIndex("mouseover")) then
							SetRaidTarget("mouseover",8)
						end
					end
				end
			elseif (steps and steps["DroppableQuest"]) then
				if (UnitGUID("mouseover") and UnitName("mouseover")) then
					local guid, name = UnitGUID("mouseover"), UnitName("mouseover")
					local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",guid);
					if (type == "Creature" and npc_id and name and steps["DroppableQuest"]["MobId"] == tonumber(npc_id)) then
						if (AAP.NPCList and not AAP.NPCList[tonumber(npc_id)]) then
							AAP.NPCList[tonumber(npc_id)] = name

						end
					end
				end
			end
		end
	end
end)