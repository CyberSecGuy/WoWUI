-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Mailing                            --
--            http://www.curse.com/addons/wow/tradeskillmaster_mailing            --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSMCore = select(2, ...)
local TSM = TSMCore.old.Mailing
local Other = TSM:NewPackage("Other")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = { frame = nil, deMailTarget = "", goldMailTarget = "", goldKeepAmount = 1000000 }


function Other:CreateTab()
	local BFC = TSMAPI.GUI:GetBuildFrameConstants()
	local frameInfo = {
		type = "Frame",
		key = "otherTab",
		hidden = true,
		points = "ALL",
		scripts = { "OnShow" },
		children = {
			{
				type = "Frame",
				key = "deBox",
				size = { 0, 80 },
				points = { { "TOPLEFT", 5, -5 }, { "TOPRIGHT", -5, -5 } },
				children = {
					{
						type = "Text",
						text = L["Mail Disenchantables"],
						textSize = "normal",
						justify = { "CENTER", "TOP" },
						size = { 0, 20 },
						points = { { "TOPLEFT", 5, -5 }, { "TOPRIGHT", -5, -5 } },
					},
					{
						type = "Text",
						text = L["Target Player:"],
						textSize = "small",
						justify = { "LEFT", "MIDDLE" },
						size = { 0, 20 },
						points = { { "TOPLEFT", 5, -30 } },
					},
					{
						type = "InputBox",
						key = "targetBox",
						text = private.deMailTarget,
						tooltip = L["Enter name of the character disenchantable items should be sent to."] .. "\n\n" .. TSM.SPELLING_WARNING,
						size = { 0, 20 },
						points = { { "TOPLEFT", BFC.PREV, "TOPRIGHT", 5, 0 }, { "TOPRIGHT", -5, -30 } },
						scripts = { "OnEnterPressed" },
					},
					{
						type = "Button",
						key = "btn",
						text = "",
						textHeight = 15,
						tooltip = L["Click this button to send all disenchantable items in your bags to the specified character. You can set the maximum quality to be sent in the options."],
						size = { 0, 20 },
						points = { { "TOPLEFT", 5, -55 }, { "TOPRIGHT", -5, -55 } },
						scripts = { "OnClick" },
					},
				},
			},
			{
				type = "Frame",
				key = "sendGoldBox",
				size = { 0, 80 },
				points = { { "TOPLEFT", BFC.PREV, "BOTTOMLEFT", 0, -50 }, { "TOPRIGHT", BFC.PREV, "BOTTOMRIGHT", 0, -50 } },
				children = {
					{
						type = "Text",
						text = L["Send Excess Gold to Banker"],
						textSize = "normal",
						justify = { "CENTER", "TOP" },
						size = { 0, 20 },
						points = { { "TOPLEFT", 5, -5 }, { "TOPRIGHT", -5, -5 } },
					},
					{
						type = "Text",
						text = L["Target Player:"],
						textSize = "small",
						justify = { "LEFT", "MIDDLE" },
						size = { 0, 20 },
						points = { { "TOPLEFT", 5, -30 } },
					},
					{
						type = "InputBox",
						key = "targetBox",
						text = private.goldMailTarget,
						tooltip = L["Enter the name of the player you want to send excess gold to."] .. "\n\n" .. TSM.SPELLING_WARNING,
						size = { 80, 20 },
						points = { { "TOPLEFT", BFC.PREV, "TOPRIGHT", 5, 0 } },
						scripts = { "OnEnterPressed" },
					},
					{
						type = "Text",
						text = L["Limit (In Gold):"],
						textSize = "small",
						justify = { "LEFT", "MIDDLE" },
						size = { 0, 20 },
						points = { { "TOPLEFT", BFC.PREV, "TOPRIGHT", 15, 0 } },
					},
					{
						type = "InputBox",
						key = "goldBox",
						numeric = true,
						text = private.goldKeepAmount,
						tooltip = L["This is maximum amount of gold you want to keep on the current player. Any amount over this limit will be send to the specified character."],
						size = { 80, 20 },
						points = { { "TOPLEFT", BFC.PREV, "TOPRIGHT", 5, 0 }, { "TOPRIGHT", -5, -30 } },
						scripts = { "OnEnterPressed" },
					},
					{
						type = "Button",
						key = "btn",
						text = "",
						textHeight = 15,
						tooltip = L["Click this button to send excess gold to the specified character (Maximum of 200k per mail)."],
						size = { 0, 20 },
						points = { { "TOPLEFT", 5, -55 }, { "TOPRIGHT", -5, -55 } },
						scripts = { "OnClick" },
					},
				},
			},
		},
		handlers = {
			OnShow = function(self)
				private.frame = self
				private:UpdateDisenchantButton()
				private:UpdateSendGoldButton()
			end,
			deBox = {
				targetBox = {
					OnEnterPressed = function(self)
						private.deMailTarget = strtrim(self:GetText())
						self:ClearFocus()
						private:UpdateDisenchantButton()
					end,
				},
				btn = {
					OnClick = function(self)
						local target = private.deMailTarget
						if target == "" or target == UnitName("player") then return end
						local items = {}
						local hasItems
						for _, bag, slot, itemString, quantity in TSMAPI.Inventory:BagIterator() do
							if TSMAPI_FOUR.Item.IsDisenchantable(itemString) and TSMAPI.Groups:GetPath(TSMAPI_FOUR.Item.ToBaseItemString(itemString, true)) == "" and not TSMAPI_FOUR.Inventory.IsSoulbound(bag, slot) then
								local quality = TSMAPI_FOUR.Item.GetQuality(itemString)
								if (quality >= 2 and quality <= TSMCore.db.global.mailingOptions.deMaxQuality) then
									items[itemString] = (items[itemString] or 0) + quantity
									hasItems = true
								end
							end
						end
						if hasItems then
							local function callback()
								TSM:Printf(L["Sent all disenchantable items to %s."], target)
								private:UpdateDisenchantButton()
							end

							self:Disable()
							self:SetText(L["Sending..."])
							TSM.AutoMail.SendItems(items, target, callback)
						end
					end,
				},
			},
			sendGoldBox = {
				targetBox = {
					OnEnterPressed = function(self)
						private.goldMailTarget = strtrim(self:GetText())
						self:ClearFocus()
						private:UpdateSendGoldButton()
					end,
				},
				goldBox = {
					OnEnterPressed = function(self)
						private.goldKeepAmount = tonumber(strtrim(self:GetText()))
						self:ClearFocus()
					end,
				},
				btn = {
					OnClick = function()
						if not private.goldKeepAmount then
							TSM:Print(L["Not sending any gold as you either did not enter a limit or did not press enter to store the limit."])
							return
						end
						local extra = (GetMoney() - 30) - (private.goldKeepAmount * COPPER_PER_GOLD)
						if extra <= 0 then
							TSM:Print(L["Not sending any gold as you have less than the specified limit."])
							return
						else
							extra = min(extra, 200000 * COPPER_PER_GOLD)
						end
						SetSendMailMoney(extra)
						SendMail(private.goldMailTarget, L["TSM_Mailing Excess Gold"], "")
						TSM:Printf(L["Sent %s to %s."], TSMAPI:MoneyToString(extra), private.goldMailTarget)
					end,
				},
			},
		},
	}
	return frameInfo
end

function private:UpdateDisenchantButton()
	local btn = private.frame.deBox.btn
	if private.deMailTarget ~= "" then
		btn:Enable()
		btn:SetText(format(L["Send Disenchantable Items to %s"], private.deMailTarget))
	else
		btn:Disable()
		btn:SetText(L["No Target Player"])
	end
end

function private:UpdateSendGoldButton()
	local btn = private.frame.sendGoldBox.btn
	if private.goldMailTarget == "" then
		btn:Disable()
		btn:SetText(L["Not Target Specified"])
	elseif TSMAPI.Player:IsPlayer(private.goldMailTarget) then
		btn:Disable()
		btn:SetText(L["Target is Current Player"])
	else
		btn:Enable()
		btn:SetText(format(L["Send Excess Gold to %s"], private.goldMailTarget))
	end
end
