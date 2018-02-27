-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

--- Analytics TSMAPI_FOUR Functions
-- @module Analytics

local _, TSM = ...
TSMAPI_FOUR.Analytics = {}
local private = { events = {}, lastEventTime = nil }
local MAX_ANALYTICS_AGE = 14 * 24 * 60 * 60 -- 2 weeks



-- ============================================================================
-- TSMAPI Functions
-- ============================================================================

--- Logs an analytics event.
-- @tparam string moduleEvent The event type
-- @tparam string moduleName The module which triggered the event
-- @tparam string moduleVersion The version of the module which triggered the error
-- @tparam ?string|number|boolean arg An argument to store with the event
function TSMAPI_FOUR.Analytics.LogEvent(moduleEvent, moduleName, moduleVersion, arg)
	if arg == nil then
		arg = ""
	end
	TSMAPI:Assert(type(moduleEvent) == "string" and strmatch(moduleEvent, "^[A-Z_]+$"))
	TSMAPI:Assert(type(arg) == "string" or type(arg) == "number" or type(arg) == "boolean")
	arg = "\""..gsub(tostring(arg), "\"", "'").."\""
	moduleEvent = "\""..moduleEvent.."\""
	moduleName = "\""..moduleName.."\""
	moduleVersion = "\""..(moduleVersion or "").."\""
	tinsert(private.events, "["..strjoin(",", moduleName, moduleEvent, moduleVersion, arg, time()).."]")
	private.lastEventTime = time()
end



-- ============================================================================
-- Module Functions
-- ============================================================================

function TSM.SaveAnalytics(appDB)
	appDB.analytics = appDB.analytics or {updateTime=0, data={}}
	if private.lastEventTime then
		appDB.analytics.updateTime = private.lastEventTime
	end
	-- remove any events which are too old
	for i = #appDB.analytics.data, 1, -1 do
		local event = appDB.analytics.data
		local eventTime = strmatch(appDB.analytics.data[i], "([0-9]+)%]$") or ""
		if (tonumber(eventTime) or 0) < time() - MAX_ANALYTICS_AGE then
			tremove(appDB.analytics.data, i)
		end
	end
	for _, event in ipairs(private.events) do
		tinsert(appDB.analytics.data, event)
	end
end
