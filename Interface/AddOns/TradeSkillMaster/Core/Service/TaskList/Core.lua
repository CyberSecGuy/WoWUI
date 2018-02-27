-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local TaskList = TSM:NewPackage("TaskList")
local private = { db = nil, nextId = 1 }
local DB_SCHEMA = {
	fields = {
		id = "number",
		categoryDesc = "string",
		character = "string",
		taskDesc = "string",
		subTaskDesc = "string",
		buttonText = "string",
		isActive = "boolean",
	}
}



-- ============================================================================
-- Module Functions
-- ============================================================================

function TaskList.OnInitialize()
	private.db = TSMAPI_FOUR.Database.New(DB_SCHEMA)

	-- FIXME: test tasks
	TaskList.AddTask("Cool Downs", "Sapy", "Scroll of Wisdom", "", "Craft", false)
	TaskList.AddTask("Cool Downs", "Polyu", "Wild Transmutation", "", "Craft", false)
	TaskList.AddTask("Gathering", "", "Buy from AH", "Buy 90 Shadow Pigment", "Scan", false)
	TaskList.AddTask("Gathering", "Sapy", "Craft with Inscription", "Craft 45 Ink of Dreams", "Craft", false)
end

function TaskList.Iterator()
	-- wrap the query iterator with our own
	local context = TSMAPI_FOUR.Util.AcquireTempTable()
	context.query = private.db:NewQuery()
		:OrderBy("categoryDesc", true)
		:OrderBy("character", true)
		:OrderBy("taskDesc", true)
		:OrderBy("subTaskDesc", false)
		:OrderBy("isActive", false)
	local func, tbl, index = context.query:Iterator()
	context.iterFunc = func
	context.iterTable = tbl
	return private.IteratorHelper, context, index
end

function TaskList.AddTask(categoryDesc, character, taskDesc, subTaskDesc, buttonText, isActive)
	private.db:NewRow()
		:SetField("id", private.nextId)
		:SetField("categoryDesc", categoryDesc)
		:SetField("character", character)
		:SetField("taskDesc", taskDesc)
		:SetField("subTaskDesc", subTaskDesc)
		:SetField("buttonText", buttonText)
		:SetField("isActive", isActive)
		:Save()
	private.nextId = private.nextId + 1
end



-- ============================================================================
-- Private Helper Functions
-- ============================================================================

function private.IteratorHelper(context, index)
	local nextIndex, row = context.iterFunc(context.iterTable, index)
	if not nextIndex then
		context.query:Release()
		TSMAPI_FOUR.Util.ReleaseTempTable(context)
		return
	end
	return nextIndex, row:GetFields("categoryDesc", "character", "taskDesc", "subTaskDesc", "buttonText", "isActive")
end
