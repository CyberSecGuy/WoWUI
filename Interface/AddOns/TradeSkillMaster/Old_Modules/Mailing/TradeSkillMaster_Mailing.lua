-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Mailing                            --
--            http://www.curse.com/addons/wow/tradeskillmaster_mailing            --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSMCore = select(2, ...)
TSMCore.old.Mailing = TSMCore.old.Mailing or {}
local TSM = TSMAPI_FOUR.Addon.New("TradeSkillMaster_Mailing", TSMCore.old.Mailing)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
TSM.SPELLING_WARNING = "|cffff0000"..L["BE SURE TO SPELL THE NAME CORRECTLY!"].."|r"

local operationDefaults = {
	maxQtyEnabled = nil,
	maxQty = 10,
	target = "",
	restock = nil, -- take into account how many the target already has
	restockSources = {guild=nil, bank=nil},
	keepQty = 0,
}

function TSM:OnInitialize()
	TSM:LoadOperations(operationDefaults, 30, TSM.GetOperationInfo, TSM.Options.GetOperationOptionsInfo)

	TSM:RegisterModuleAPI("mailItems", TSM.AutoMail.SendItems)

	-- FIXME: keep mailing working in the old UIs for now
	TSM.moduleOptions = { callback = TSM.Options.ShowOptions }
	TSM.bankUiButton = { callback = TSM.BankUI.createTab }

	TSMAPI_FOUR.Modules.Register(TSM)
end

function TSM.GetOperationInfo(operationName)
	local operation = TSM.operations[operationName]
	if not operation then return end
	if operation.target == "" then return end

	if operation.maxQtyEnabled then
		return format(L["Mailing up to %d to %s."], operation.maxQty, operation.target)
	else
		return format(L["Mailing all to %s."], operation.target)
	end
end
