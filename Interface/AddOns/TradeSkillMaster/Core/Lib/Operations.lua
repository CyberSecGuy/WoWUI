-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

TSMAPI_FOUR.Operations = {}
local _, TSM = ...
local Operations = TSM:NewPackage("Operations")
local private = { operationInfo = {}, operationModules = {} }




local function OperationIteratorHelper(_, operationName, moduleName)
	if operationName == "" or TSM.Modules:IsOperationIgnored(moduleName, operationName) then return end
	return operationName, private.GetModuleOperations(moduleName)[operationName]
end



-- ============================================================================
-- TSMAPI_FOUR Functions
-- ============================================================================

function TSMAPI_FOUR.Operations.ModuleHasOperations(moduleName)
	return private.operationInfo[moduleName] and true or false
end

function TSMAPI_FOUR.Operations.ModuleHasOperationNamed(moduleName, operation)
	return private.operationInfo[moduleName] and TSM.operations[moduleName][operation] and true or false
end

function TSMAPI_FOUR.Operations.ModuleHasOperationNamedForGroup(moduleName, operation, groupPath)
	local operationExists = TSMAPI_FOUR.Operations.ModuleHasOperationNamed(moduleName, operation)
	if not operationExists then
		return false
	end
	if not TSM.db.profile.userData.groups[groupPath] then
		return false
	end
	if TSM.db.profile.userData.groups[groupPath][moduleName] then
		for index, name in ipairs(TSM.db.profile.userData.groups[groupPath][moduleName]) do
			if name == operation then
				return true
			end
		end
	end
	return false
end

function TSMAPI_FOUR.Operations.Rename(moduleName, oldName, newName)
	TSM.operations[moduleName][newName] = TSM.operations[moduleName][oldName]
	TSM.operations[moduleName][oldName] = nil
	for _, modules in pairs(TSM.db.profile.userData.groups) do
		if modules[moduleName] then
			for i = 1, #modules[moduleName] do
				if modules[moduleName][i] == oldName then
					modules[moduleName][i] = newName
				end
			end
		end
	end
	TSM.Modules:CheckOperationRelationships(moduleName)
end

function TSMAPI_FOUR.Operations.IsCircularRelationship(moduleName, operationName, key)
	local visited = TSMAPI_FOUR.Util.AcquireTempTable()
	while operationName do
		if visited[operationName] then
			TSMAPI_FOUR.Util.ReleaseTempTable(visited)
			return true
		end
		visited[operationName] = true
		operationName = TSM.operations[moduleName][operationName].relationships[key]
	end
	TSMAPI_FOUR.Util.ReleaseTempTable(visited)
	return false
end

function TSMAPI_FOUR.Operations.Iterator(moduleName, groupPath)
	local operationNames = TSM.db.profile.userData.groups[groupPath][moduleName]
	return TSMAPI_FOUR.Util.TableIterator(operationNames, OperationIteratorHelper, moduleName)
end



-- ============================================================================
-- TSMAPI Functions
-- FIXME: these APIs are all deprecated
-- ============================================================================

function TSMAPI.Operations:GetFirstByItem(itemString, moduleName)
	local groupPath = TSMAPI_FOUR.Groups.GetPathByItem(itemString)
	if not groupPath or not TSM.db.profile.userData.groups[groupPath] or not TSM.db.profile.userData.groups[groupPath][moduleName] then return end
	local operationNames = TSM.db.profile.userData.groups[groupPath][moduleName]
	local resultName, resultSettings = nil, nil
	for name, settings in TSMAPI_FOUR.Util.TableIterator(operationNames, OperationIteratorHelper, moduleName) do
		if not resultName then
			resultName = name
			resultSettings = settings
		end
	end
	return resultName, resultSettings
end

function TSMAPI.Operations:GetFirstByGroup(groupPath, moduleName)
	if not groupPath or not TSM.db.profile.userData.groups[groupPath] or not TSM.db.profile.userData.groups[groupPath][moduleName] then return end
	local operationNames = TSM.db.profile.userData.groups[groupPath][moduleName]
	local resultName, resultSettings = nil, nil
	for name, settings in TSMAPI_FOUR.Util.TableIterator(operationNames, OperationIteratorHelper, moduleName) do
		if not resultName then
			resultName = name
			resultSettings = settings
		end
	end
	return resultName, resultSettings
end

function TSMAPI.Operations:Update(moduleName, operationName)
	if not TSM.operations[moduleName][operationName] then return end
	private.UpdateRelationships(moduleName, operationName)
end



-- ============================================================================
-- Module Functions
-- ============================================================================

function Operations.Register(moduleName, defaults, maxOperations, callbackInfo, callbackOptions)
	TSM.operations[moduleName] = TSM.operations[moduleName] or {}
	tinsert(private.operationModules, moduleName)
	private.operationInfo[moduleName] = {
		defaults = defaults,
		maxOperations = maxOperations,
		callbackInfo = callbackInfo,
		callbackOptions = callbackOptions
	}
end

function Operations:RegisterModuleOperationInfo(moduleName, info)
	Operations.Register(moduleName, info.defaults, info.maxOperations, info.callbackInfo, info.callbackOptions)
end

function Operations.GetDefaults(moduleName)
	return private.operationInfo[moduleName].defaults
end

function Operations.GetMaxOperations(moduleName)
	return private.operationInfo[moduleName].maxOperations
end

function Operations:GetModuleOperationInfo(moduleName)
	return private.operationInfo[moduleName]
end

function Operations:GetModulesWithOperations()
	return private.operationModules
end

function Operations.IteratorByGroup(moduleName, groupPath)
	return TSMAPI_FOUR.Util.TableIterator(TSM.db.profile.userData.groups[groupPath][moduleName], OperationIteratorHelper, moduleName)
end

function Operations.GetFirstOptionsByItem(moduleName, itemString)
	local groupPath = TSMAPI_FOUR.Groups.GetPathByItem(itemString)
	if not groupPath then
		return
	end
	local groupOperations = TSM.db.profile.userData.groups[groupPath][moduleName]
	if not groupOperations then
		return
	end
	for _, operationName in ipairs(groupOperations) do
		if operationName ~= "" and not TSM.Modules:IsOperationIgnored(moduleName, operationName) then
			return TSM.operations[moduleName][operationName]
		end
	end
end

function private.UpdateRelationships(moduleName, operationName)
	for key in pairs(TSM.operations[moduleName][operationName].relationships) do
		local operation = TSM.operations[moduleName][operationName]
		while operation.relationships[key] do
			local newOperation = TSM.operations[moduleName][operation.relationships[key]]
			if not newOperation then break end
			operation = newOperation
		end
		TSM.operations[moduleName][operationName][key] = operation[key]
	end
end

function private.GetModuleOperations(moduleName)
	return TSM.operations[moduleName]
end
