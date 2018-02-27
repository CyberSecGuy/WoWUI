-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local Crafting = TSM:NewPackage("Crafting")
local private = { spellDB = nil, matDB = nil }
local PLAYER_SEP = ","
local SPELL_DB_SCHEMA = {
	fields = {
		spellId = "number",
		itemString = "string",
		itemName = "string",
		name = "string",
		profession = "string",
		numResult = "number",
		players = "string",
		hasCD = "boolean",
	},
	fieldAttributes = {
		spellId = { "unique" },
		itemString = { "index" },
	}
}
local MAT_DB_SCHEMA = {
	fields = {
		spellId = "number",
		itemString = "string",
		quantity = "number",
		profession = "string",
		customValue = "boolean"
	},
	fieldAttributes = {
		spellId = { "index" },
		itemString = { "index" },
	}
}



-- ============================================================================
-- Module Functions
-- ============================================================================

function Crafting.OnEnable()
	private.spellDB = TSMAPI_FOUR.Database.New(SPELL_DB_SCHEMA)
	private.matDB = TSMAPI_FOUR.Database.New(MAT_DB_SCHEMA)
	for spellId, info in pairs(TSM.db.factionrealm.internalData.crafts) do
		local players = TSMAPI_FOUR.Util.AcquireTempTable()
		for player in pairs(info.players) do
			tinsert(players, player)
		end
		private.spellDB:NewRow()
			:SetField("spellId", spellId)
			:SetField("itemString", info.itemString)
			:SetField("itemName", TSMAPI_FOUR.Item.GetName(info.itemString) or "")
			:SetField("name", info.name or "")
			:SetField("profession", info.profession)
			:SetField("numResult", info.numResult)
			:SetField("players", strjoin(PLAYER_SEP, TSMAPI_FOUR.Util.UnpackAndReleaseTempTable(players)))
			:SetField("hasCD", info.hasCD and true or false)
			:Save()
		for itemString, quantity in pairs(info.mats) do
			TSM.db.factionrealm.internalData.mats[itemString] = TSM.db.factionrealm.internalData.mats[itemString] or { name = TSMAPI_FOUR.Item.GetName(itemString) }
			private.matDB:NewRow()
				:SetField("spellId", spellId)
				:SetField("itemString", itemString)
				:SetField("quantity", quantity)
				:SetField("profession", info.profession)
				:SetField("customValue", TSM.db.factionrealm.internalData.mats[itemString].customValue and true or false)
				:Save()
		end
	end
end

function Crafting.CreateCraftsQuery()
	return private.spellDB:NewQuery()
end

function Crafting.CreateMatsQuery()
	return private.matDB:NewQuery()
end

function Crafting.SpellIterator()
	return private.spellDB:NewQuery()
		:Select("spellId")
		:IteratorAndRelease(true)
end

function Crafting.GetSpellIdsByItem(itemString)
	return private.spellDB:NewQuery()
		:Select("spellId")
		:Equal("itemString", itemString)
		:IteratorAndRelease(true)
end

function Crafting.GetItemString(spellId)
	return private.GetRowFieldBySpellId(spellId, "itemString")
end

function Crafting.GetProfession(spellId)
	return private.GetRowFieldBySpellId(spellId, "profession")
end

function Crafting.GetNumResult(spellId)
	return private.GetRowFieldBySpellId(spellId, "numResult")
end

function Crafting.GetPlayers(spellId)
	local players = private.GetRowFieldBySpellId(spellId, "players")
	if not players then
		return
	end
	return strsplit(PLAYER_SEP, players)
end

function Crafting.MatIterator(spellId)
	return private.matDB:NewQuery()
		:Select("itemString", "quantity")
		:Equal("spellId", spellId)
		:IteratorAndRelease(true)
end

function Crafting.RemovePlayers(spellId, playersToRemove)
	local shouldRemove = TSMAPI_FOUR.Util.AcquireTempTable()
	for _, player in ipairs(playersToRemove) do
		shouldRemove[player] = true
	end
	local players = TSMAPI_FOUR.Util.AcquireTempTable(Crafting.GetPlayers(spellId))
	for i = #players, 1, -1 do
		local player = players[i]
		if shouldRemove[player] then
			TSM.db.factionrealm.internalData.crafts[spellId].players[player] = nil
			tremove(players, i)
		end
	end
	TSMAPI_FOUR.Util.ReleaseTempTable(shouldRemove)
	local row = private.GetRowBySpellId(spellId)
	local playersStr = strjoin(PLAYER_SEP, TSMAPI_FOUR.Util.UnpackAndReleaseTempTable(players))
	if playersStr == "" then
		-- no more players so remove this spell and all its mats
		private.spellDB:DeleteRow(row)
		local query = private.matDB:NewQuery()
			:Equal("spellId", spellId)
		for _, matRow in query:Iterator() do
			private.matDB:DeleteRow(matRow)
		end
		query:Release()
		TSM.db.factionrealm.internalData.crafts[spellId] = nil
		return false
	else
		row:SetField("players", playersStr)
		row:Save()
		return true
	end
end

function Crafting.CreateOrUpdate(spellId, itemString, profession, name, numResult, player, hasCD)
	local row = private.GetRowBySpellId(spellId)
	if row then
		local foundPlayer = false
		local playersStr = row:GetField("players")
		for _, existingPlayer in TSMAPI_FOUR.Util.VarargIterator(strsplit(PLAYER_SEP, playersStr)) do
			if existingPlayer == player then
				foundPlayer = true
			end
		end
		if not foundPlayer then
			assert(playersStr ~= "")
			playersStr = playersStr .. PLAYER_SEP .. player
		end
		row:SetField("itemString", itemString)
			:SetField("profession", profession)
			:SetField("itemName", TSMAPI_FOUR.Item.GetName(itemString) or "")
			:SetField("name", name)
			:SetField("numResult", numResult)
			:SetField("players", playersStr)
			:SetField("hasCD", hasCD)
			:Save()
		local info = TSM.db.factionrealm.internalData.crafts[spellId]
		info.itemString = itemString
		info.profession = profession
		info.name = name
		info.numResult = numResult
		info.players[player] = true
		info.hasCD = hasCD or nil
		return
	else
		TSM.db.factionrealm.internalData.crafts[spellId] = {
			mats = {},
			players = { [player] = true },
			queued = 0,
			itemString = itemString,
			name = name,
			profession = profession,
			numResult = numResult,
			hasCD = hasCD,
		}
		private.spellDB:NewRow()
			:SetField("spellId", spellId)
			:SetField("itemString", itemString)
			:SetField("profession", profession)
			:SetField("itemName", TSMAPI_FOUR.Item.GetName(itemString) or "")
			:SetField("name", name)
			:SetField("numResult", numResult)
			:SetField("players", player)
			:SetField("hasCD", hasCD)
			:Save()
	end
end

function Crafting.SetMats(spellId, matQuantities)
	local usedMats = TSMAPI_FOUR.Util.AcquireTempTable()
	wipe(TSM.db.factionrealm.internalData.crafts[spellId].mats)
	for itemString, quantity in pairs(matQuantities) do
		TSM.db.factionrealm.internalData.crafts[spellId].mats[itemString] = quantity
	end
	local query = private.matDB:NewQuery()
		:Equal("spellId", spellId)
	for _, row in query:Iterator() do
		local itemString = row:GetField("itemString")
		local quantity = matQuantities[itemString]
		if not quantity then
			-- remove this row
			private.matDB:DeleteRow(row)
		else
			usedMats[itemString] = true
			row:SetField("quantity", quantity)
				:Save()
		end
	end
	query:Release()
	local profession = TSM.db.factionrealm.internalData.crafts[spellId].profession
	for itemString, quantity in pairs(matQuantities) do
		if not usedMats[itemString] then
			private.matDB:NewRow()
				:SetField("spellId", spellId)
				:SetField("itemString", itemString)
				:SetField("quantity", quantity)
				:SetField("profession", profession)
				:SetField("customValue", TSM.db.factionrealm.internalData.mats[itemString].customValue and true or false)
				:Save()
		end
	end
	TSMAPI_FOUR.Util.ReleaseTempTable(usedMats)
end

function Crafting.MatProfessionIterator(itemString)
	return private.matDB:NewQuery()
		:Select("profession")
		:Equal("itemString", itemString)
		:Distinct("profession")
		:IteratorAndRelease(true)
end



-- ============================================================================
-- Private Helper Functions
-- ============================================================================

function private.GetRowBySpellId(spellId)
	return private.spellDB:NewQuery()
		:Equal("spellId", spellId)
		:GetFirstResultAndRelease()
end

function private.GetRowFieldBySpellId(spellId, field)
	local row = private.GetRowBySpellId(spellId)
	return row and row:GetField(field) or nil
end
