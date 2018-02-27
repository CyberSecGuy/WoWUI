-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
TSMAPI_FOUR.Addon = {}
local private = { Addon = nil, addonLookup = {}, initializeQueue = {}, enableQueue = {}, disableQueue = {} }



-- ============================================================================
-- Event Handling
-- ============================================================================

function private.EventHandler(event, arg1)
	if event == "PLAYER_LOGOUT" then
		for _, addon in ipairs(private.disableQueue) do
			if addon.OnDisable then
				addon.OnDisable()
			end
		end
		wipe(private.disableQueue)
	else
		if event == "ADDON_LOADED" and arg1 == "Blizzard_DebugTools" then
			-- need to ignore this event according to comments in AceAddon
			return
		end
		for _, addon in ipairs(private.initializeQueue) do
			if addon.OnInitialize then
				addon.OnInitialize()
			end
			tinsert(private.enableQueue, addon)
		end
		wipe(private.initializeQueue)

		if IsLoggedIn() then
			for _, addon in ipairs(private.enableQueue) do
				if addon.OnEnable then
					addon.OnEnable()
				end
				tinsert(private.disableQueue, addon)
			end
			wipe(private.enableQueue)
		end
	end
end

do
	TSMAPI_FOUR.Event.Register("ADDON_LOADED", private.EventHandler)
	TSMAPI_FOUR.Event.Register("PLAYER_LOGIN", private.EventHandler)
	TSMAPI_FOUR.Event.Register("PLAYER_LOGOUT", private.EventHandler)
end



-- ============================================================================
-- AddonPackage Class
-- ============================================================================

local AddonPackage = TSMAPI_FOUR.Class.DefineClass("AddonPackage")

function AddonPackage.__init(self, name, ...)
	self.name = name
	for i = 1, select("#", ...) do
		local embed = select(i, ...)
		LibStub(embed):Embed(self)
	end
	tinsert(private.initializeQueue, self)
end

function AddonPackage.__tostring(self)
	return self.name
end

function AddonPackage.NewPackage(self, name, ...)
	local package = AddonPackage(name, ...)
	assert(not self[name])
	self[name] = package
	return package
end



-- ============================================================================
-- Addon Class
-- ============================================================================

local Addon = TSMAPI_FOUR.Class.DefineClass("Addon", AddonPackage)

function Addon.__init(self, name, ...)
	self.__super:__init(name, ...)

	self._name = name
	self._shortName = gsub(name, "TradeSkillMaster_", "")
	self._logger = TSMAPI_FOUR.Logger.New(self:GetShortName())
end

-- FIXME: remove this
function Addon.NewModule(self, ...)
	return self:NewPackage(...)
end
function Addon.GetModule(self, name)
	return self[name]
end

function Addon.GetVersion(self)
	local version = GetAddOnMetadata("TradeSkillMaster", "X-Curse-Packaged-Version") or GetAddOnMetadata("TradeSkillMaster", "Version")
	if version == "@project-version@" then
		version = "Dev"
	end
	return version
end

function Addon.GetFullName(self)
	return self._name
end

function Addon.GetShortName(self)
	return self._shortName
end

function Addon.PrintRaw(self, str)
	TSM:GetChatFrame():AddMessage(str)
end

function Addon.PrintfRaw(self, ...)
	self:PrintRaw(format(...))
end

function Addon.Print(self, str)
	-- FIXME: hard-coded color
	self:PrintRaw("|cff33ff99"..tostring(self).."|r: "..str)
end

function Addon.Printf(self, ...)
	self:Print(format(...))
end

function Addon.LOG_INFO(self, ...)
	self._logger:LogMessage("INFO", ...)
end

function Addon.LOG_WARN(self, ...)
	self._logger:LogMessage("WARN", ...)
end

function Addon.LOG_ERR(self, ...)
	self._logger:LogMessage("ERR", ...)
end

function Addon.LOG_STACK_TRACE(self)
	self._logger:LogMessage("STACK", "Stack Trace:")
	local level = 2
	local line = TSMAPI_FOUR.Util.GetDebugStackInfo(level)
	while line do
		self._logger:LogMessage("STACK", "  " .. line)
		level = level + 1
		line = TSMAPI_FOUR.Util.GetDebugStackInfo(level)
	end
end

function Addon.AnalyticsEvent(self, moduleEvent, ...)
	TSMAPI_FOUR.Analytics.LogEvent(moduleEvent, self:GetShortName(), self:GetVersion(), ...)
end

function Addon.LoadSettings(self, name, defaults)
	local db, upgradeObj = TSMAPI_FOUR.Settings.New(name, defaults)
	self.db = db
	return upgradeObj
end

function Addon.LoadOperations(self, defaults, maxOperations, callbackInfo, callbackOptions)
	for key, value in pairs(TSM.CONST.OPERATION_DEFAULT_FIELDS) do
		assert(not defaults[key], "Invalid use of reserved operation field: "..key)
		defaults[key] = value
	end
	local moduleName = self:GetShortName()

	-- register operation info
	TSM.Operations.Register(moduleName, defaults, maxOperations, callbackInfo, callbackOptions)
	TSM.operations[moduleName] = TSM.operations[moduleName] or {}
	self.operations = TSM.operations[moduleName]
	for _, operation in pairs(self.operations) do
		operation.ignorePlayer = operation.ignorePlayer or {}
		operation.ignoreFactionrealm = operation.ignoreFactionrealm or {}
		operation.relationships = operation.relationships or {}
	end
	TSM.Modules:CheckOperationRelationships(moduleName)
end

function Addon.RegisterPriceSource(self, key, label, callback, fullLink, arg)
	TSM.CustomPrice.RegisterSource(self:GetShortName(), key, label, callback, fullLink, arg)
end

function Addon.RegisterSlashCommand(self, key, callback, label)
	TSM.SlashCommands.Register(self:GetShortName(), key, callback, label)
end

function Addon.RegisterTooltipInfo(self, defaults, callbackLoad, callbackOptions)
	TSM.Tooltips.Register(self:GetShortName(), defaults, callbackLoad, callbackOptions)
end

function Addon.RegisterModuleAPI(self, key, callback)
	-- FIXME: register these in a better way
	self.moduleAPIs = self.moduleAPIs or {}
	tinsert(self.moduleAPIs, { key = key, callback = callback })
end



-- ============================================================================
-- TSMAPI Functions
-- ============================================================================

function TSMAPI_FOUR.Addon.New(name, tbl)
	assert(type(name) == "string" and type(tbl) == "table", "Invalid arguments")
	assert(not private.addonLookup[tbl], "Addon already created")

	local addon = TSMAPI_FOUR.Class.ConstructWithTable(tbl, Addon, name)
	private.addonLookup[tbl] = addon
	return addon
end
