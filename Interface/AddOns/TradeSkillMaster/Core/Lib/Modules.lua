-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

TSMAPI_FOUR.Modules = {}
local _, TSM = ...
local Modules = TSM:NewPackage("Modules")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = { hasOutdatedAddons = nil, names = {}, objects = {} }
local OFFICIAL_MODULES = {
	["TradeSkillMaster"] = true,
	["AppHelper"] = true,
}
local MODULE_FIELD_INFO = { -- info on all the possible fields of the module objects which TSM core cares about
	-- operation fields
	{ key = "operations", type = "table", subFieldInfo = { maxOperations = "number", callbackOptions = "function", callbackInfo = "function", defaults = "table" } },
	-- tooltip fields
	{ key = "tooltip", type = "table", subFieldInfo = { callbackLoad = "function", callbackOptions = "function", defaults = "table"}},
	-- shared feature fields
	{ key = "slashCommands", type = "table", subTableInfo = { key = "string", label = "string", callback = "function" } },
	{ key = "icons", type = "table", subTableInfo = { side = "string", desc = "string", callback = "function", icon = "string" } },
	{ key = "auctionTab", type = "table", subFieldInfo = { callbackShow = "function", callbackHide = "function" } },
	{ key = "bankUiButton", type = "table", subFieldInfo = { callback = "function" } },
	{ key = "moduleOptions", type = "table", subFieldInfo = { callback = "function" } },
	-- data access fields
	{ key = "priceSources", type = "table", subTableInfo = { key = "string", label = "string", callback = "function" } },
	{ key = "moduleAPIs", type = "table", subTableInfo = { key = "string", callback = "function" } },
}



-- ============================================================================
-- TSMAPI Functions
-- ============================================================================

function TSMAPI_FOUR.Modules.Register(obj)
	if tContains(private.names, obj:GetShortName()) and tContains(TSM.CONST.OLD_TSM_MODULES, obj:GetFullName()) then
		-- this is a refactored old module, so prevent it from loading too much
		obj.OnEnable = nil
		obj.OnDisable = nil
		return
	end

	-- FIXME: temporary code to keep the old frames working
	if obj.moduleOptions then
		TSM.Options:RegisterModuleOptions(obj:GetShortName(), obj.moduleOptions.callback)
	end
	if obj.bankUiButton then
		TSM:RegisterBankUiButton(obj:GetShortName(), obj.bankUiButton.callback)
	end

	local shortName = obj:GetShortName()
	private.objects[shortName] = obj
	tinsert(private.names, shortName)
	sort(private.names, private.NameSortFunc)
	obj:LOG_INFO("Registered module %s", obj)
end

function TSMAPI_FOUR.Modules.IsPresent(moduleName)
	return private.objects[moduleName] and true or false
end

function TSMAPI_FOUR.Modules.API(moduleName, key, ...)
	if type(moduleName) ~= "string" or type(key) ~= "string" then return nil, "Invalid args" end
	if not private.objects[moduleName] then return nil, "Invalid module" end

	for _, info in ipairs(private.objects[moduleName].moduleAPIs or {}) do
		if info.key == key then
			return info.callback(...)
		end
	end
	return nil, "Key not found"
end



-- ============================================================================
-- Module Functions
-- ============================================================================

function Modules.OnInitialize()
	TSM.db:RegisterCallback("OnLogout", Modules.OnLogout)
	TSM.db:RegisterCallback("OnProfileUpdated", Modules.ProfileUpdated)
end

function Modules.OnEnable()
	-- no modules and update available popups
	TSMAPI_FOUR.Delay.AfterTime(3, function()
		Modules.ProfileUpdated()

		if #private.names == 1 then
			StaticPopupDialogs["TSMInfoPopup"] = {
				text = L["|cffffff00Important Note:|r You do not currently have any modules installed / enabled for TradeSkillMaster! |cff77ccffYou must download modules for TradeSkillMaster to have some useful functionality!|r\n\nPlease visit http://www.curse.com/addons/wow/tradeskill-master and check the project description for links to download modules."],
				button1 = L["I'll Go There Now!"],
				timeout = 0,
				whileDead = true,
				OnAccept = function()
					TSM:Print(L["Just incase you didn't read this the first time:"])
					TSM:Print(L["|cffffff00Important Note:|r You do not currently have any modules installed / enabled for TradeSkillMaster! |cff77ccffYou must download modules for TradeSkillMaster to have some useful functionality!|r\n\nPlease visit http://www.curse.com/addons/wow/tradeskill-master and check the project description for links to download modules."])
				end,
			}
			TSMAPI_FOUR.Util.ShowStaticPopupDialog("TSMInfoPopup")
		end
		local addonVersions = TSM:GetAppAddonVersions()
		if addonVersions then
			for _, obj in pairs(private.objects) do
				local fullName = gsub(obj.name, "TSM_", "TradeSkillMaster_")
				local currentVersion = private.VersionStrToInt(obj:GetVersion())
				if currentVersion and addonVersions[fullName] and currentVersion < addonVersions[fullName] then
					StaticPopupDialogs["TSMUpdatePopup_"..fullName] = {
						text = format(L["|cffffff00Important Note:|r An update is available for %s. You should update as soon as possible to ensure TSM continues to function properly."], fullName),
						button1 = L["I'll Go Update!"],
						timeout = 0,
						whileDead = true,
					}
					TSMAPI_FOUR.Util.ShowStaticPopupDialog("TSMUpdatePopup_"..fullName)
					private.hasOutdatedAddons = true
				end
			end
		end
	end)
end

function Modules.HasOutdatedAddons()
	return private.hasOutdatedAddons
end

function Modules.ProfileUpdated(isReset)
	if Modules.ignoreProfileUpdated then
		return
	end
	if isReset then
		-- reset tooltip options
		for moduleName, obj in pairs(private.objects) do
			TSM.db.global.tooltipOptions.moduleTooltips[moduleName] = obj.tooltip and obj.tooltip.defaults or nil
		end
	end

	-- fix groups with `` in their path from Sheyrah's export
	local didFix = true
	while didFix do
		didFix = false
		local fixes = TSMAPI_FOUR.Util.AcquireTempTable()
		for groupPath, group in pairs(TSM.db.profile.userData.groups) do
			if strmatch(groupPath, TSM.CONST.GROUP_SEP..TSM.CONST.GROUP_SEP) then
				fixes[groupPath] = gsub(groupPath, TSM.CONST.GROUP_SEP..TSM.CONST.GROUP_SEP, ",")
			end
		end
		for oldGroupPath, newGroupPath in pairs(fixes) do
			TSM:LOG_INFO("Fixing group path: "..oldGroupPath)
			local temp = TSM.db.profile.userData.groups[oldGroupPath]
			TSM.db.profile.userData.groups[oldGroupPath] = nil
			TSM.db.profile.userData.groups[newGroupPath] = temp
			didFix = true
		end
		wipe(fixes)
		for itemString, groupPath in pairs(TSM.db.profile.userData.items) do
			if strmatch(groupPath, TSM.CONST.GROUP_SEP..TSM.CONST.GROUP_SEP) then
				fixes[itemString] = gsub(groupPath, TSM.CONST.GROUP_SEP..TSM.CONST.GROUP_SEP, ",")
			end
		end
		for itemString, groupPath in pairs(fixes) do
			TSM.db.profile.userData.items[itemString] = groupPath
			didFix = true
		end
		TSMAPI_FOUR.Util.ReleaseTempTable(fixes)
	end

	-- update operations
	if TSM.db.global.coreOptions.globalOperations then
		for _, moduleName in ipairs(TSM.Operations:GetModulesWithOperations()) do
			TSM.db.global.userData.operations[moduleName] = TSM.db.global.userData.operations[moduleName] or {}
		end
		for moduleName, obj in pairs(private.objects) do
			if TSMAPI_FOUR.Operations.ModuleHasOperations(moduleName) then
				obj.operations = TSM.db.global.userData.operations[moduleName]
				for _, groupOperations in pairs(TSM.db.profile.userData.groups) do
					groupOperations[moduleName] = groupOperations[moduleName] or {}
				end
			end
		end
		TSM.operations = TSM.db.global.userData.operations
	else
		for _, moduleName in ipairs(TSM.Operations:GetModulesWithOperations()) do
			TSM.db.profile.userData.operations[moduleName] = TSM.db.profile.userData.operations[moduleName] or {}
		end
		for moduleName, obj in pairs(private.objects) do
			if TSMAPI_FOUR.Operations.ModuleHasOperations(moduleName) then
				obj.operations = TSM.db.profile.userData.operations[moduleName]
				for _, groupOperations in pairs(TSM.db.profile.userData.groups) do
					groupOperations[moduleName] = groupOperations[moduleName] or {}
				end
			end
		end
		TSM.operations = TSM.db.profile.userData.operations
	end

	-- remove operations which no longer exist from groups
	for groupPath, operations in pairs(TSM.db.profile.userData.groups) do
		for _, moduleName in ipairs(TSM.Operations:GetModulesWithOperations()) do
			operations[moduleName] = operations[moduleName] or {}
			local moduleOperations = operations[moduleName]
			if #moduleOperations > 1 or moduleOperations[1] ~= "" then
				for i = #moduleOperations, 1, -1 do
					local operationName = moduleOperations[i]
					if not TSM.operations[moduleName][operationName] then
						TSM:LOG_INFO("Removing invalid operation (%s->%s) from %s", moduleName, operationName, groupPath)
						tremove(moduleOperations, i)
					end
				end
			end
			if #moduleOperations == 0 then
				tinsert(moduleOperations, "")
			end
		end
	end

	for moduleName, operations in pairs(TSM.operations) do
		if TSMAPI_FOUR.Operations.ModuleHasOperations(moduleName) then
			if not TSM.db.profile.internalData.createdDefaultOperations and not operations["#Default"] then
				operations["#Default"] = CopyTable(TSM.Operations.GetDefaults(moduleName))
			end
			for _, operation in pairs(operations) do
				operation.ignorePlayer = operation.ignorePlayer or {}
				operation.ignoreFactionrealm = operation.ignoreFactionrealm or {}
				operation.relationships = operation.relationships or {}
			end
			Modules:CheckOperationRelationships(moduleName)
		end
	end
	TSM.db.profile.internalData.createdDefaultOperations = true

	-- create the root group if it doesn't exist and assign default operations
	if not TSM.db.profile.userData.groups[TSM.CONST.ROOT_GROUP_PATH] then
		-- make sure all previously-top-level groups have the override flag set
		for groupPath, moduleOperations in pairs(TSM.db.profile.userData.groups) do
			if not strfind(groupPath, TSM.CONST.GROUP_SEP) then
				for moduleName in pairs(TSM.operations) do
					if TSMAPI_FOUR.Operations.ModuleHasOperations(moduleName) then
						moduleOperations[moduleName] = moduleOperations[moduleName] or {}
						moduleOperations[moduleName].override = true
					end
				end
			end
		end
		TSMAPI_FOUR.Groups.Create(TSM.CONST.ROOT_GROUP_PATH)
		for moduleName, operations in pairs(TSM.operations) do
			if TSMAPI_FOUR.Operations.ModuleHasOperations(moduleName) and operations["#Default"] then
				TSM.Groups:SetOperation(TSM.CONST.ROOT_GROUP_PATH, moduleName, "#Default", 1)
			end
		end
	end

	-- fix bad imports which contain operations but don't have the override flag set
	local groupList = TSMAPI_FOUR.Util.AcquireTempTable()
	for path in pairs(TSM.db.profile.userData.groups) do
		tinsert(groupList, path)
	end
	TSMAPI_FOUR.Groups.SortGroupList(groupList)
	assert(not TSM.db.profile.userData.groups[TSM.CONST.ROOT_GROUP_PATH] or groupList[1] == TSM.CONST.ROOT_GROUP_PATH)
	for _, path in ipairs(groupList) do
		local parentPath = TSMAPI_FOUR.Groups.SplitPath(path)
		local operations = TSM.db.profile.userData.groups[path]
		if parentPath then
			local parentOperations = TSM.db.profile.userData.groups[parentPath]
			assert(parentOperations)
			for _, moduleName in ipairs(TSM.Operations:GetModulesWithOperations()) do
				operations[moduleName] = operations[moduleName] or {}
				parentOperations[moduleName] = parentOperations[moduleName] or {}
				local moduleOperations = operations[moduleName]
				local parentModuleOperations = parentOperations[moduleName]
				if not moduleOperations.override then
					if parentPath == TSM.CONST.ROOT_GROUP_PATH then
						local equalOperations = true
						for i = 1, max(#moduleOperations, #parentModuleOperations) do
							if moduleOperations[i] ~= parentModuleOperations[i] then
								equalOperations = false
								break
							end
						end
						if not equalOperations then
							-- just apply the root group operations to this group
							TSM:LOG_INFO("Applying root group operations to %s %s", path, moduleName)
							wipe(moduleOperations)
							for i, operationName in ipairs(parentModuleOperations) do
								moduleOperations[i] = operationName
							end
						end
					else
						local equalOperations = true
						for i = #moduleOperations, 1, -1 do
							if moduleOperations[i] == "" then
								tremove(moduleOperations, i)
							end
						end
						for i = #parentModuleOperations, 1, -1 do
							if parentModuleOperations[i] == "" then
								tremove(parentModuleOperations, i)
							end
						end
						for i = 1, max(#moduleOperations, #parentModuleOperations) do
							if moduleOperations[i] ~= parentModuleOperations[i] then
								equalOperations = false
								break
							end
						end
						if not equalOperations then
							TSM:LOG_INFO("Setting override for %s %s", path, moduleName)
							moduleOperations.override = true
						end
					end
				end
			end
		end
	end
	TSMAPI_FOUR.Util.ReleaseTempTable(groupList)
end

function Modules.IsOfficial(moduleName)
	local moduleName = gsub(moduleName, "TradeSkillMaster_", "")
	return OFFICIAL_MODULES[moduleName]
end

function Modules.PrintVersions()
	TSM:Print(L["TSM Version Info:"])
	-- print official modules
	for _, name in ipairs(private.names) do
		local obj = private.objects[name]
		if Modules.IsOfficial(name) then
			TSM:PrintfRaw("%s |cff99ffff%s|r", name, obj:GetVersion())
		end
	end
	-- print unofficial modules
	for _, name in ipairs(private.names) do
		local obj = private.objects[name]
		if not Modules.IsOfficial(name) then
			TSM:PrintfRaw("%s |cff99ffff%s|r |cffff0000[%s]|r", name, obj:GetVersion(), L["Unofficial Module"])
		end
	end
end

function Modules.OnLogout()
	local appDB = nil
	if TSMAPI.AppHelper then
		TradeSkillMaster_AppHelperDB = TradeSkillMaster_AppHelperDB or {}
		appDB = TradeSkillMaster_AppHelperDB
	end
	local originalProfile = TSM.db:GetCurrentProfile()
	for _, obj in pairs(private.objects) do
		-- erroring here would cause the profile to be reset, so use pcall
		if obj.OnTSMDBShutdown and not pcall(obj.OnTSMDBShutdown, nil, appDB) then
			-- the callback hit an error, so ensure the correct profile is restored
			TSM.db:SetProfile(originalProfile)
		end
	end
	-- ensure we're back on the correct profile
	TSM.db:SetProfile(originalProfile)
end

function Modules:IsOperationIgnored(module, operationName)
	local operationSettings = TSM.operations[module][operationName]
	if not operationSettings then return end
	local factionrealm = UnitFactionGroup("player").." - "..GetRealmName()
	local playerKey = UnitName("player").." - "..factionrealm
	return operationSettings.ignorePlayer[playerKey] or operationSettings.ignoreFactionrealm[factionrealm]
end

function Modules:CheckOperationRelationships(moduleName)
	for _, operation in pairs(TSM.operations[moduleName]) do
		for key, target in pairs(operation.relationships or {}) do
			if not TSM.operations[moduleName][target] then
				operation.relationships[key] = nil
			end
		end
	end
end

function Modules:ModulePrint(moduleName, str)
	private.objects[moduleName]:Print(str)
end

function Modules:ModulePrintf(moduleName, ...)
	private.objects[moduleName]:Printf(...)
end



-- ============================================================================
-- Helper Functions
-- ============================================================================

-- if the passed function is a string, will check if it's a method of the object and return a wrapper function
function private.GetFunction(obj, func)
	if type(func) == "string" then
		local part1, part2 = (":"):split(func)
		if part2 and obj[part1] and obj[part1][part2] then
			return function(...) return obj[part1][part2](obj[part1], ...) end
		elseif obj[part1] then
			return function(...) return obj[part1](obj, ...) end
		end
	end
	return func
end

-- validates a simple list of sub-tables which have the basic key/label/callback fields
function private.ValidateList(obj, val, keys)
	for i, v in ipairs(val) do
		if type(v) ~= "table" then
			return "invalid entry in list at index " .. i
		end
		for key, valType in pairs(keys) do
			if valType == "function" then
				v[key] = private.GetFunction(obj, v[key])
			end
			if type(v[key]) ~= valType then
				return format("expected %s type for field %s, got %s at index %d", valType, key, type(v[key]), i)
			end
		end
	end
end

function private.ValidateModuleObject(obj)
	-- make sure it's a table
	if type(obj) ~= "table" then
		return format("Expected table, got %s.", type(obj))
	end
	-- simple check that it's an AceAddon object which stores the name in .name and implements a .__tostring metamethod.
	if tostring(obj) ~= obj.name then
		return "Passed object is not an AceAddon-3.0 object."
	end

	-- validate all the fields
	for _, fieldInfo in ipairs(MODULE_FIELD_INFO) do
		local val = obj[fieldInfo.key]
		if val then
			-- make sure it's of the correct type
			if type(val) ~= fieldInfo.type then
				return format("For field '%s', expected type of %s, got %s.", fieldInfo.key, fieldInfo.type, type(val))
			end
			-- if there's required subfields, check them
			if fieldInfo.subFieldInfo then
				for key, valType in pairs(fieldInfo.subFieldInfo) do
					if valType == "function" then
						val[key] = private.GetFunction(obj, val[key])
					end
					if type(val[key]) ~= valType then
						return format("expected %s type for field %s, got %s", valType, key, type(val[key]))
					end
				end
			end
			-- if there's subTableInfo specified, run private.ValidateList on this field
			if fieldInfo.subTableInfo then
				local errMsg = private.ValidateList(obj, val, fieldInfo.subTableInfo)
				if errMsg then
					return format("Invalid value for '%s': %s.", fieldInfo.key, errMsg)
				end
			end
		end
	end
end

function private.VersionStrToInt(str)
	local gen, major, minor, beta = strmatch(str, "^v([0-9])%.([0-9]+)%.?([0-9]*)%.?([0-9]*)$")
	gen = tonumber(gen) or 0
	major = tonumber(major) or 0
	minor = tonumber(minor) or 0
	beta = tonumber(beta) or 0
	if gen ~= 3 then return end
	return gen * 1000000 + major * 10000 + minor * 100 + beta
end

function private.NameSortFunc(a, b)
	if a == "TradeSkillMaster" then
		return true
	elseif b == "TradeSkillMaster" then
		return false
	else
		return a < b
	end
end
