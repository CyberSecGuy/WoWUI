-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

--- Database TSMAPI_FOUR Functions.
-- @module Database

TSMAPI_FOUR.Database = {}
local _, TSM = ...
local Database = TSM:NewPackage("Database")
Database.classes = {}
local private = { recycledRows = {}, recycledQueries = {}, recycledQueryClauses = {} }



-- ============================================================================
-- TSMAPI Functions
-- ============================================================================

--- Create a new database.
-- @tparam table schema The database schema
-- @treturn Database The database object
function TSMAPI_FOUR.Database.New(schema)
	return Database.classes.Database(schema)
end



-- ============================================================================
-- Module Functions (Internal)
-- ============================================================================

function Database.GetDatabaseRow()
	if #private.recycledRows > 0 then
		return tremove(private.recycledRows)
	else
		return Database.classes.DatabaseRow()
	end
end

function Database.RecycleDatabaseRow(row)
	tinsert(private.recycledRows, row)
end

function Database.GetDatabaseQuery()
	if #private.recycledQueries > 0 then
		return tremove(private.recycledQueries)
	else
		return Database.classes.DatabaseQuery()
	end
end

function Database.RecycleDatabaseQuery(query)
	tinsert(private.recycledQueries, query)
end

function Database.GetDatabaseQueryClause()
	if #private.recycledQueryClauses > 0 then
		return tremove(private.recycledQueryClauses)
	else
		return Database.classes.DatabaseQueryClause()
	end
end

function Database.RecycleDatabaseQueryClause(queryClause)
	tinsert(private.recycledQueryClauses, queryClause)
end
