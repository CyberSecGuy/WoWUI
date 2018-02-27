-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--          http://www.curse.com/addons/wow/tradeskillmaster_warehousing          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local MailTracking = TSM.Inventory:NewPackage("MailTracking", "AceHook-3.0")
local private = {
	isOpen = false,
}
local PLAYER_NAME = UnitName("player")



-- ============================================================================
-- Module Functions
-- ============================================================================

function MailTracking.OnInitialize()
	-- update the structure of TSM.db.factionrealm.internalData.pendingMail
	local toUpdate = TSMAPI_FOUR.Util.AcquireTempTable()
	for character, pendingMailData in pairs(TSM.db.factionrealm.internalData.pendingMail) do
		if pendingMailData.items then
			TSM:LOG_INFO("Converting pending mail data for %s", character)
			toUpdate[character] = pendingMailData.items
		end
	end
	for character, items in pairs(toUpdate) do
		TSM.db.factionrealm.internalData.pendingMail[character] = items
	end
	TSMAPI_FOUR.Util.ReleaseTempTable(toUpdate)

	-- remove data for characters we don't own
	local toRemove = TSMAPI_FOUR.Util.AcquireTempTable()
	for character in pairs(TSM.db.factionrealm.internalData.pendingMail) do
		local owner = TSM.db:GetSyncOwnerAccountKey(character)
		if owner and owner ~= TSM.db:GetSyncAccountKey() then
			TSM:LOG_INFO("Removed pending mail data for %s", character)
			tinsert(toRemove, character)
		end
	end
	for _, character in ipairs(toRemove) do
		TSM.db.factionrealm.internalData.pendingMail[character] = nil
	end
	TSMAPI_FOUR.Util.ReleaseTempTable(toRemove)

	TSM.db.factionrealm.internalData.pendingMail[PLAYER_NAME] = TSM.db.factionrealm.internalData.pendingMail[PLAYER_NAME] or {}
	TSMAPI_FOUR.Event.Register("MAIL_SHOW", private.MailShowHandler)
	TSMAPI_FOUR.Event.Register("MAIL_CLOSED", private.MailClosedHandler)
	TSMAPI_FOUR.Event.Register("MAIL_INBOX_UPDATE", private.MailInboxUpdateHandler)

	-- handle auction buying
	MailTracking:SecureHook("PlaceAuctionBid", function(listType, index, bidPlaced)
		local itemString = TSMAPI_FOUR.Item.ToBaseItemString(GetAuctionItemLink(listType, index))
		local name, _, stackSize, _, _, _, _, _, _, buyout = GetAuctionItemInfo(listType, index)
		if not itemString or bidPlaced ~= buyout then
			return
		end
		TSM.db.factionrealm.internalData.pendingMail[PLAYER_NAME][itemString] = (TSM.db.factionrealm.internalData.pendingMail[PLAYER_NAME][itemString] or 0) + stackSize
	end)

	-- handle auction canceling
	MailTracking:SecureHook("CancelAuction", function(index)
		local itemString = TSMAPI_FOUR.Item.ToBaseItemString(GetAuctionItemLink("owner", index))
		local _, _, stackSize = GetAuctionItemInfo("owner", index)
		if not itemString or not stackSize then
			return
		end
		TSM.db.factionrealm.internalData.pendingMail[PLAYER_NAME][itemString] = (TSM.db.factionrealm.internalData.pendingMail[PLAYER_NAME][itemString] or 0) + stackSize
	end)

	-- handle sending mail to alts
	MailTracking:SecureHook("SendMail", function(target)
		local character = private.ValidateCharacter(target)
		if not character then
			return
		end
		TSM.db.factionrealm.internalData.pendingMail[character] = TSM.db.factionrealm.internalData.pendingMail[character] or {}
		local altPendingMail = TSM.db.factionrealm.internalData.pendingMail[character]
		for i = 1, ATTACHMENTS_MAX_SEND do
			local itemString = TSMAPI_FOUR.Item.ToBaseItemString(GetSendMailItemLink(i))
			local _, _, _, quantity = GetSendMailItem(i)
			if itemString and quantity then
				altPendingMail[itemString] = (altPendingMail[itemString] or 0) + quantity
			end
		end
	end)

	-- handle returning mail to alts
	MailTracking:SecureHook("ReturnInboxItem", function(index)
		local character = private.ValidateCharacter(select(3, GetInboxHeaderInfo(index)))
		if not character then
			return
		end
		TSM.db.factionrealm.internalData.pendingMail[character] = TSM.db.factionrealm.internalData.pendingMail[character] or {}
		local altPendingMail = TSM.db.factionrealm.internalData.pendingMail[character]
		for i = 1, ATTACHMENTS_MAX_SEND do
			local itemString = TSMAPI_FOUR.Item.ToBaseItemString(GetInboxItemLink(index, i))
			local _, _, _, quantity = GetInboxItem(index, i)
			if itemString and quantity then
				altPendingMail[itemString] = (altPendingMail[itemString] or 0) + quantity
			end
		end
	end)
end



-- ============================================================================
-- Event Handlers
-- ============================================================================

function private.MailShowHandler()
	private.isOpen = true
end

function private.MailClosedHandler()
	private.isOpen = false
end

function private.MailInboxUpdateHandler()
	TSMAPI_FOUR.Delay.AfterFrame("mailInboxScan", 2, private.MailInboxUpdateDelayed)
end

function private.MailInboxUpdateDelayed()
	if not private.isOpen then
		return
	end

	wipe(TSM.db.factionrealm.internalData.pendingMail[PLAYER_NAME])
	wipe(TSM.db.sync.internalData.mailQuantity)
	for i = 1, GetInboxNumItems() do
		local _, _, _, _, _, _, _, hasItem = GetInboxHeaderInfo(i)
		for j = 1, hasItem and ATTACHMENTS_MAX_RECEIVE or 0 do
			local itemString = TSMAPI_FOUR.Item.ToBaseItemString(GetInboxItemLink(i, j))
			local _, _, _, quantity = GetInboxItem(i, j)
			if itemString and quantity then
				TSM.db.sync.internalData.mailQuantity[itemString] = (TSM.db.sync.internalData.mailQuantity[itemString] or 0) + quantity
			end
		end
	end
end



-- ============================================================================
-- Private Helper Functions
-- ============================================================================

function private.ValidateCharacter(character)
	if not character then
		return
	end
	local characterName, realm = strsplit("-", strlower(character))
	-- we only care to track mails with characters on this realm
	if realm and realm ~= strlower(GetRealmName()) then
		return
	end
	-- we only care to track mails with characters on this account
	local result = nil
	for _, name in TSM.db:FactionrealmCharacterByAccountIterator() do
		if strlower(name) == characterName then
			result = name
		end
	end
	return result
end
