-- ------------------------------------------------------------------------------ --
--                          TradeSkillMaster_Warehousing                          --
--          http://www.curse.com/addons/wow/tradeskillmaster_warehousing          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSMCore = select(2, ...)
TSMCore.old.Warehousing = TSMCore.old.Warehousing or {}
local TSM = TSMAPI_FOUR.Addon.New("TradeSkillMaster_Warehousing", TSMCore.old.Warehousing)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = { bank = nil }
TSM.bagState = {}
TSM.ShowLogData = false

local operationDefaults = {
	moveQtyEnabled = nil,
	moveQuantity = 1, -- move 1
	keepBagQtyEnabled = nil,
	keepBagQuantity = 1, -- keep 1 in bags
	keepBankQtyEnabled = nil,
	keepBankQuantity = 1, --keep 1 in bank
	restockQtyEnabled = nil,
	restockQuantity = 1, --restock 1
	stackSize = 5,
	stackSizeEnabled = nil,
	restockKeepBankQtyEnabled = nil,
	restockKeepBankQuantity = 1,
	restockStackSizeEnabled = nil,
	restockStackSize = 5,
}

function TSM:OnInitialize()
	TSM:LoadOperations(operationDefaults, 12, TSM.GetOperationInfo, TSM.Options.GetOperationOptionsInfo)

	TSM:RegisterSlashCommand("movedata", TSM.SetLogFlag, L["Displays realtime move data."])
	TSM:RegisterSlashCommand("get", TSM.GetItem, L["Gets items from the bank or guild bank matching the itemstring, itemID or partial text entered."])
	TSM:RegisterSlashCommand("put", TSM.PutItem, L["Puts items matching the itemstring, itemID or partial text entered into the bank or guild bank."])

	-- FIXME: keep warehousing working in the old UIs for now
	TSM.bankUiButton = { callback = TSM.BankUI.createTab }

	TSMAPI_FOUR.Modules.Register(TSM)

	TSMAPI_FOUR.Event.Register("GUILDBANKFRAME_OPENED", function(event)
		private.bank = "guildbank"
	end)

	TSMAPI_FOUR.Event.Register("BANKFRAME_OPENED", function(event)
		private.bank = "bank"
	end)

	TSMAPI_FOUR.Event.Register("GUILDBANKFRAME_CLOSED", function(event, addon)
		private.bank = nil
	end)

	TSMAPI_FOUR.Event.Register("BANKFRAME_CLOSED", function(event)
		private.bank = nil
	end)
end

function TSM.GetOperationInfo(name)
	TSMAPI.Operations:Update("Warehousing", name)
	local settings = TSM.operations[name]
	if not settings then return end
	if (settings.keepBagQtyEnabled or settings.keepBankQtyEnabled) and not settings.moveQtyEnabled then
		if settings.keepBagQtyEnabled then
			if settings.keepBankQtyEnabled then
				if settings.restockQtyEnabled then
					return format(L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."], settings.keepBagQuantity, settings.keepBankQuantity, settings.restockQuantity)
				else
					return format(L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags."], settings.keepBagQuantity, settings.keepBankQuantity)
				end
			else
				if settings.restockQtyEnabled then
					return format(L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank. Restock will maintain %d items in your bags."], settings.keepBagQuantity, settings.restockQuantity)
				else
					return format(L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank."], settings.keepBagQuantity)
				end
			end
		else
			if settings.restockQtyEnabled then
				return format(L["Warehousing will move all of the items in this group keeping %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."], settings.keepBankQuantity, settings.restockQuantity)
			else
				return format(L["Warehousing will move all of the items in this group keeping %d of each item back when bank/gbank > bags."], settings.keepBankQuantity)
			end
		end
	elseif (settings.keepBagQtyEnabled or settings.keepBankQtyEnabled) and settings.moveQtyEnabled then
		if settings.keepBagQtyEnabled then
			if settings.keepBankQtyEnabled then
				if settings.restockQtyEnabled then
					return format(L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."], settings.moveQuantity, settings.keepBagQuantity, settings.keepBankQuantity, settings.restockQuantity)
				else
					return format(L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags."], settings.moveQuantity, settings.keepBagQuantity, settings.keepBankQuantity)
				end
			else
				if settings.restockQtyEnabled then
					return format(L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank. Restock will maintain %d items in your bags."], settings.keepBankQuantity, settings.restockQuantity)
				else
					return format(L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank."], settings.keepBankQuantity)
				end
			end
		else
			if settings.restockQtyEnabled then
				return format(L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."], settings.moveQuantity, settings.keepBankQuantity, settings.restockQuantity)
			else
				return format(L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bank/gbank > bags."], settings.moveQuantity, settings.keepBankQuantity)
			end
		end
	elseif settings.moveQtyEnabled then
		if settings.restockQtyEnabled then
			return format(L["Warehousing will move a max of %d of each item in this group. Restock will maintain %d items in your bags."], settings.moveQuantity, settings.restockQuantity)
		else
			return format(L["Warehousing will move a max of %d of each item in this group."], settings.moveQuantity)
		end
	else
		if settings.restockQtyEnabled then
			return format(L["Warehousing will move all of the items in this group. Restock will maintain %d items in your bags."], settings.restockQuantity)
		else
			return L["Warehousing will move all of the items in this group."]
		end
	end
end

function TSM.SetLogFlag()
	if TSM.ShowLogData then
		TSM.ShowLogData = false
		TSM:Print(L["Move Data has been turned off"])
	else
		TSM.ShowLogData = true
		TSM:Print(L["Move Data has been turned on"])
	end
end

function TSM.GetItem(args)
	if args then
		if TSM.move:areBanksVisible() then
			local quantity = tonumber(strmatch(args, " ([0-9]+)$"))
			local searchString = gsub(args, " ([0-9]+)$", "")
			if not searchString and TSMAPI.Item:GetTexture(quantity) then -- incase an itemID was entered but no qty then the strmatch would have incorrectly set as quantity
				searchString = quantity
				quantity = nil
			end
			TSM.move:manualMove(searchString, private.bank, quantity)
		else
			TSM:Print(L["There are no visible banks."])
		end
	else
		TSM:Print(L["Invalid criteria entered."])
	end
end

function TSM.PutItem(args)
	if args then
		if TSM.move:areBanksVisible() then
			local quantity = tonumber(strmatch(args, " ([0-9]+)$"))
			local searchString = gsub(args, " ([0-9]+)$", "")
			if not searchString and TSMAPI.Item:GetTexture(quantity) then -- incase an itemID was entered but no qty then the strmatch would have incorrectly set as quantity
				searchString = quantity
				quantity = nil
			end
			TSM.move:manualMove(searchString, "bags", quantity)
		else
			TSM:Print(L["There are no visible banks."])
		end
	else
		TSM:Print(L["Invalid criteria entered."])
	end
end
