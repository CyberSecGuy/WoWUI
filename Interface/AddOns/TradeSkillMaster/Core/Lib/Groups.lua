-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

TSMAPI_FOUR.Groups = {}
local _, TSM = ...
local Groups = TSM:NewPackage("Groups")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = {}
local GROUP_LEVEL_COLORS = {
	"FCF141",
	"BDAEC6",
	"06A2CB",
	"FFB85C",
	"51B599",
}



-- ============================================================================
-- New TSMAPI Functions
-- ============================================================================

-- Creates a new group with the specified path
function TSMAPI_FOUR.Groups.Create(groupPath)
	if TSM.db.profile.userData.groups[groupPath] then return end
	local parentPath = TSMAPI_FOUR.Groups.SplitPath(groupPath)
	if parentPath and parentPath ~= TSM.CONST.ROOT_GROUP_PATH then
		TSMAPI_FOUR.Groups.Create(parentPath)
	end
	TSM.db.profile.userData.groups[groupPath] = {}
	for _, moduleName in ipairs(TSM.Operations:GetModulesWithOperations()) do
		TSM.db.profile.userData.groups[groupPath][moduleName] = TSM.db.profile.userData.groups[groupPath][moduleName] or {}
		if parentPath and parentPath ~= TSM.CONST.ROOT_GROUP_PATH then
			Groups:SetOperationOverride(groupPath, moduleName, nil, true)
		end
	end
end

function TSMAPI_FOUR.Groups.CreateLikeName(path)
	if TSM.db.profile.userData.groups[path] then
		local num = 1
		while TSM.db.profile.userData.groups[path.." "..num] do
			num = num + 1
		end
		path = path.." "..num
	end
	TSMAPI_FOUR.Groups.Create(path)
	return path
end

function TSMAPI_FOUR.Groups.GetPathByItem(itemString)
	itemString = TSMAPI_FOUR.Item.ToBaseItemString(itemString, true)
	if not itemString then return end
	local groupPath = TSM.db.profile.userData.items[itemString]
	if groupPath and not TSM.db.profile.userData.groups[groupPath] then
		TSM.db.profile.userData.items[itemString] = nil
		groupPath = nil
	end
	return groupPath or TSM.CONST.ROOT_GROUP_PATH
end

function TSMAPI_FOUR.Groups.FormatPath(path, useColor)
	if not path then return end
	local result = gsub(path, TSM.CONST.GROUP_SEP, "->")
	if useColor then
		return TSMAPI.Design:GetInlineColor("link")..result.."|r"
	else
		return result
	end
end

function TSMAPI_FOUR.Groups.JoinPath(...)
	if select("#", ...) == 2 then
		if select(1, ...) == "" then
			return select(2, ...)
		end
	end
	return strjoin(TSM.CONST.GROUP_SEP, ...)
end

-- Splits the given group path into the parent path and group name
-- Parent will be nil if there is no parent
function TSMAPI_FOUR.Groups.SplitPath(path)
	local parent, groupName = strmatch(path, "^(.+)"..TSM.CONST.GROUP_SEP.."([^"..TSM.CONST.GROUP_SEP.."]+)$")
	if parent then
		return parent, groupName
	elseif path ~= TSM.CONST.ROOT_GROUP_PATH then
		return TSM.CONST.ROOT_GROUP_PATH, path
	else
		return nil, path
	end
end

function TSMAPI_FOUR.Groups.IsChild(path, parentPath)
	if parentPath == TSM.CONST.ROOT_GROUP_PATH then
		return path ~= TSM.CONST.ROOT_GROUP_PATH
	end
	return strmatch(path, "^"..TSMAPI_FOUR.Util.StrEscape(parentPath)..TSM.CONST.GROUP_SEP) and true or false
end

function TSMAPI_FOUR.Groups.IteratorByOperation(moduleName, operationName)
	local groupList = TSMAPI_FOUR.Util.AcquireTempTable()
	for path, modules in pairs(TSM.db.profile.userData.groups) do
		if modules[moduleName] and (path == TSM.CONST.ROOT_GROUP_PATH or modules[moduleName].override) then
			for i = 1, #modules[moduleName] do
				if modules[moduleName][i] == operationName then
					tinsert(groupList, path)
				end
			end
		end
	end
	return TSMAPI_FOUR.Util.TempTableIterator(groupList)
end

function TSMAPI_FOUR.Groups.RemoveOperationByName(path, module, operation)
	local moduleOperations = TSM.db.profile.userData.groups[path][module]
	assert(moduleOperations.override or path == TSM.CONST.ROOT_GROUP_PATH)
	for i = #moduleOperations, 1, -1 do
		if moduleOperations[i] == operation then
			local numOperations = #moduleOperations
			-- shift the latter operations down an index to preserve the order and remove the last one
			for j = i + 1, numOperations do
				Groups:SetOperation(path, module, moduleOperations[j], j - 1)
			end
			-- remove the last one
			Groups:SetOperation(path, module, nil, numOperations)
		end
	end
end

function TSMAPI_FOUR.Groups.HasOperationsByModule(path, module)
	if not TSM.db.profile.userData.groups[path][module] then
		return false
	end

	for _, operation in ipairs(TSM.db.profile.userData.groups[path][module]) do
		if operation ~= "" and not TSM.Modules:IsOperationIgnored(module, operation) then
			return true
		end
	end

	return false
end

function TSMAPI_FOUR.Groups.AppendOperation(path, module, operation)
	local index = #TSM.db.profile.userData.groups[path][module]
	if TSM.db.profile.userData.groups[path][module][index] ~= "" then
		index = index + 1
	end
	assert(index <= TSM.Operations.GetMaxOperations(module))
	Groups:SetOperation(path, module, operation, index)
end

function TSMAPI_FOUR.Groups.SortGroupList(list)
	sort(list, private.GroupSortFunction)
end

function TSMAPI_FOUR.Groups.ItemIterator(path)
	local hasItem = TSMAPI_FOUR.Util.AcquireTempTable()
	local items = TSMAPI_FOUR.Util.AcquireTempTable()
	for itemString, groupPath in pairs(TSM.db.profile.userData.items) do
		if groupPath == path then
			itemString = TSMAPI_FOUR.Item.ToItemString(itemString)
			if itemString and not hasItem[itemString] then
				hasItem[itemString] = true
				tinsert(items, itemString)
			end
		end
	end
	TSMAPI_FOUR.Util.ReleaseTempTable(hasItem)
	return TSMAPI_FOUR.Util.TempTableIterator(items)
end

function TSMAPI_FOUR.Groups.BaseName(path)
	local _, name = TSMAPI_FOUR.Groups.SplitPath(path)
	return name
end



-- ============================================================================
-- Module Functions
-- ============================================================================

function Groups:GetSortedGroupPathList(list)
	list = list or {}
	for groupPath in pairs(TSM.db.profile.userData.groups) do
		if groupPath ~= TSM.CONST.ROOT_GROUP_PATH then
			tinsert(list, groupPath)
		end
	end
	Groups:SortGroupList(list)
	return list
end

function Groups:GetGroupPathList(module)
	if not module then
		return Groups:GetSortedGroupPathList()
	end
	local list, disabled = {}, {}
	for groupPath in pairs(TSM.db.profile.userData.groups) do
		if groupPath ~= "" then
			if module then
				local operations = Groups:GetGroupOperations(groupPath, module)
				if not operations then
					disabled[groupPath] = true
				end
			end
			tinsert(list, groupPath)
		end
	end

	for groupPath in pairs(TSM.db.profile.userData.groups) do
		if groupPath ~= "" and not disabled[groupPath] then
			local path = nil
			for _, part in TSMAPI_FOUR.Util.VarargIterator(strsplit(TSM.CONST.GROUP_SEP, groupPath)) do
				path = path and (path..TSM.CONST.GROUP_SEP..part) or part
				if path ~= groupPath then
					disabled[path] = nil
				end
			end
		end
	end

	Groups:SortGroupList(list)
	return list, disabled
end

function Groups:GetGroupOperations(path, module)
	if not TSM.db.profile.userData.groups[path] then return end

	if module and TSM.db.profile.userData.groups[path][module] then
		local operations = CopyTable(TSM.db.profile.userData.groups[path][module])
		for i = #operations, 1, -1 do
			if not operations[i] or operations[i] == "" or TSM.Modules:IsOperationIgnored(module, operations[i]) then
				tremove(operations, i)
			end
		end
		if #operations > 0 then
			return operations
		end
	end
end

function Groups:ColorName(groupName, level)
	local color = GROUP_LEVEL_COLORS[(level-1) % #GROUP_LEVEL_COLORS + 1]
	return "|cFF"..color..groupName.."|r"
end

function Groups:GetItems(path)
	local items = {}
	for itemString, groupPath in pairs(TSM.db.profile.userData.items) do
		if groupPath == path then
			itemString = TSMAPI_FOUR.Item.ToItemString(itemString)
			if itemString then
				items[itemString] = true
			end
		end
	end
	return items
end

-- Deletes a group with the specified path and everything (items/subGroups) below it
function Groups:Delete(groupPath)
	assert(groupPath ~= TSM.CONST.ROOT_GROUP_PATH)
	if not TSM.db.profile.userData.groups[groupPath] then return end

	-- delete this group and all subgroups
	for path in pairs(TSM.db.profile.userData.groups) do
		if path == groupPath or TSMAPI_FOUR.Groups.IsChild(path, groupPath) then
			TSM.db.profile.userData.groups[path] = nil
		end
	end

	local parent = TSMAPI_FOUR.Groups.SplitPath(groupPath)
	if parent and parent ~= TSM.CONST.ROOT_GROUP_PATH then
		-- move all items in this group its subgroups to the parent
		local changes = {}
		for itemString, path in pairs(TSM.db.profile.userData.items) do
			if path == groupPath or TSMAPI_FOUR.Groups.IsChild(path, groupPath) then
				changes[itemString] = parent
			end
		end
		for itemString, newPath in pairs(changes) do
			TSM.db.profile.userData.items[itemString] = newPath
		end
	else
		-- delete all items in this group or subgroup
		for itemString, path in pairs(TSM.db.profile.userData.items) do
			if path == groupPath or TSMAPI_FOUR.Groups.IsChild(path, groupPath) then
				TSM.db.profile.userData.items[itemString] = nil
			end
		end
	end
end

-- Moves (renames) a group at the given path to the newPath
function Groups:Move(groupPath, newPath)
	assert(groupPath ~= TSM.CONST.ROOT_GROUP_PATH)
	if not TSM.db.profile.userData.groups[groupPath] then return end
	if TSM.db.profile.userData.groups[newPath] then return end

	-- change the path of all subgroups
	local changes = {}
	for path, groupData in pairs(TSM.db.profile.userData.groups) do
		if path == groupPath or TSMAPI_FOUR.Groups.IsChild(path, groupPath) then
			changes[path] = gsub(path, "^"..TSMAPI_FOUR.Util.StrEscape(groupPath), TSMAPI_FOUR.Util.StrEscape(newPath))
		end
	end
	for oldPath, newPath in pairs(changes) do
		TSM.db.profile.userData.groups[newPath] = TSM.db.profile.userData.groups[oldPath]
		TSM.db.profile.userData.groups[oldPath] = nil
	end

	-- change the path for all items in this group (and subgroups)
	wipe(changes)
	for itemString, path in pairs(TSM.db.profile.userData.items) do
		if path == groupPath or TSMAPI_FOUR.Groups.IsChild(path, groupPath) then
			changes[itemString] = gsub(path, "^"..TSMAPI_FOUR.Util.StrEscape(groupPath), TSMAPI_FOUR.Util.StrEscape(newPath))
		end
	end
	for itemString, newPath in pairs(changes) do
		TSM.db.profile.userData.items[itemString] = newPath
	end
	for _, moduleName in ipairs(TSM.Operations:GetModulesWithOperations()) do
		TSM.db.profile.userData.groups[newPath][moduleName] = TSM.db.profile.userData.groups[newPath][moduleName] or {}
		if TSMAPI_FOUR.Groups.SplitPath(newPath) and not TSM.db.profile.userData.groups[newPath][moduleName].override then
			Groups:SetOperationOverride(newPath, moduleName, nil, true)
		end
	end
end

-- Adds an item to the group at the specified path.
function Groups:AddItem(itemString, path)
	if not (strfind(path, TSM.CONST.GROUP_SEP) or not TSM.db.profile.userData.items[itemString]) then return end
	if not TSM.db.profile.userData.groups[path] then return end

	TSM.db.profile.userData.items[itemString] = path
end

-- Deletes an item from the group at the specified path.
function Groups:RemoveItem(itemString)
	if not TSM.db.profile.userData.items[itemString] then return end
	TSM.db.profile.userData.items[itemString] = nil
end

-- Moves an item from an existing group to the group at the specified path.
function Groups:MoveItem(itemString, path)
	if not TSM.db.profile.userData.items[itemString] then return end
	if not TSM.db.profile.userData.groups[path] then return end
	TSM.db.profile.userData.items[itemString] = path
end

function Groups:SetOperation(path, module, operation, index)
	if not TSM.db.profile.userData.groups[path] then return end
	if not TSM.db.profile.userData.groups[path][module] then return end
	TSM.db.profile.userData.groups[path][module][index] = operation
	private.UpdateGroupOperations(module, path)
end

function Groups:AddOperation(path, module)
	if not TSM.db.profile.userData.groups[path] then return end
	tinsert(TSM.db.profile.userData.groups[path][module], "")
	private.UpdateGroupOperations(module, path)
end

function Groups:RemoveOperation(path, module, index)
	if not TSM.db.profile.userData.groups[path] then return end
	TSMAPI_FOUR.Groups.RemoveOperationByName(path, module, TSM.db.profile.userData.groups[path][module][index])
end

function Groups:SetOperationOverride(path, module, override, force)
	if not TSM.db.profile.userData.groups[path] or (not force and TSM.db.profile.userData.groups[path][module] and TSM.db.profile.userData.groups[path][module].override == override) then return end

	-- clear all operations for this path/module
	TSM.db.profile.userData.groups[path][module] = {override=(override or nil)}
	private.UpdateGroupOperations(module, path)
	if not override then
		-- set this group's (and all applicable subgroups') operation to the parent's
		local parentPath = TSMAPI_FOUR.Groups.SplitPath(path)
		if parentPath then
			private.UpdateGroupOperations(module, parentPath)
		end
	end
end

function Groups:SortGroupList(list)
	sort(list, private.GroupSortFunction)
end



-- ============================================================================
-- Group Helper Functions
-- ============================================================================

function private.UpdateGroupOperations(module, parentPath)
	local groupList = TSMAPI_FOUR.Util.AcquireTempTable()
	Groups:GetSortedGroupPathList(groupList)
	for _, path in ipairs(groupList) do
		if parentPath == TSM.CONST.ROOT_GROUP_PATH or TSMAPI_FOUR.Groups.IsChild(path, parentPath) then
			TSM.db.profile.userData.groups[path][module] = TSM.db.profile.userData.groups[path][module] or {}
			if not TSM.db.profile.userData.groups[path][module].override then
				wipe(TSM.db.profile.userData.groups[path][module])
				local parentGroupPath = TSMAPI_FOUR.Groups.SplitPath(path)
				-- assign all the parent group's operations to this subgroup
				for i, operationName in ipairs(TSM.db.profile.userData.groups[parentGroupPath][module]) do
					TSM.db.profile.userData.groups[path][module][i] = operationName
				end
			end
		end
	end
	TSMAPI_FOUR.Util.ReleaseTempTable(groupList)
end

function private.GroupSortFunction(a, b)
	return strlower(gsub(a, TSM.CONST.GROUP_SEP, "\001")) < strlower(gsub(b, TSM.CONST.GROUP_SEP, "\001"))
end
