-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Crafting                           --
--            http://www.curse.com/addons/wow/tradeskillmaster_crafting           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable and register this file as a module
local TSMCore = select(2, ...)
local TSM = TSMCore.old.Crafting
local Queue = TSM:NewPackage("Queue")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = { isQueued = {} }



function Queue:OnEnable()
	private.query = TSMCore.Crafting.Queue.CreateQuery()
end

function Queue:Add(spellId, quantity)
	return TSMCore.Crafting.Queue.Add(spellId, quantity or 1)
end

function Queue:Remove(spellId, quantity)
	return TSMCore.Crafting.Queue.Remove(spellId, quantity or 1)
end

function Queue:Clear()
	TSMCore.Crafting.Queue.Clear()
end

function Queue:GetQueuedCrafts()
	local queueCrafts = {}
	for _, row in private.query:Iterator(true) do
		local spellId, profession, num = row:GetFields("spellId", "profession", "num")
		queueCrafts[profession] = queueCrafts[profession] or {}
		queueCrafts[profession][spellId] = num
	end
	return queueCrafts
end

function Queue:GetMatsByProfession(professionsList)
	local queueMats = {}
	if not professionsList then
		return queueMats
	end
	for _, row in private.query:Iterator(true) do
		local spellId, profession, num = row:GetFields("spellId", "profession", "num")
		if professionsList[profession] then
			queueMats[profession] = queueMats[profession] or {}
			for itemString, quantity in pairs(TSMCore.db.factionrealm.internalData.crafts[spellId].mats) do
				queueMats[profession][itemString] = (queueMats[profession][itemString] or 0) + quantity * num
			end
		end
	end
	return queueMats
end
