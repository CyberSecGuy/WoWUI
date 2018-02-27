-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

--- Database Class.
-- This class represents a database which has a defined schema, contains rows which follow the schema, and allows for
-- queries to made against it. It also supports more advanced features such as indexes (including unique).
-- @classmod Database

local _, TSM = ...
local Database = TSMAPI_FOUR.Class.DefineClass("Database")
TSM.Database.classes.Database = Database
local private = {}
local VALID_TYPES = {
	boolean = true,
	string = true,
	number = true,
}


-- ============================================================================
-- Class Meta Methods
-- ============================================================================

function Database.__init(self, schema)
	self._schema = schema
	self._rows = {}
	self._queries = {}
	self._indexLists = {}
	self._uniques = {}
	self._queryUpdatesPaused = 0
	self._queuedQueryUpdate = false
	self._extensionCallbacks = {}

	for fieldName, fieldType in pairs(schema.fields) do
		assert(type(fieldName) == "string" and strsub(fieldName, 1, 1) ~= "_")
		assert(VALID_TYPES[fieldType])
	end
	if schema.fieldAttributes then
		for field, attributes in pairs(schema.fieldAttributes) do
			assert(schema.fields[field])
			-- make sure attributes is a list
			assert(TSMAPI_FOUR.Util.Count(attributes) == #attributes)
			for _, attribute in ipairs(attributes) do
				if attribute == "index" then
					self._indexLists[field] = {}
				elseif attribute == "unique" then
					self._uniques[field] = {}
				else
					error("Unknown field attribute: "..tostring(attribute))
				end
			end
		end
	end
end



-- ============================================================================
-- Public Class Methods
-- ============================================================================

--- Iterate over the fields.
-- @tparam Database self The database object
-- @return An iterator which iterates over the database's fields and has the following values: `index, field`
function Database.FieldIterator(self)
	return TSMAPI_FOUR.Util.TableKeyIterator(self._schema.fields)
end

--- Extends the schema of the database.
-- The extension schema must not include any field attributes (i.e. index / unique).
-- @tparam Database self The database object
-- @tparam table schema The extension schema
-- @tparam function callback A callback which updates the extended fields of a row whenever it is otherwise updated
function Database.ExtendSchema(self, schema, callback)
	assert(not schema.fieldAttributes, "Extending fieldAttributes is not currently supported")
	for fieldName, fieldType in pairs(schema.fields) do
		assert(type(fieldName) == "string" and strsub(fieldName, 1, 1) ~= "_")
		assert(VALID_TYPES[fieldType])
		assert(not self:_GetFieldType(fieldName))
		self._schema.fields[fieldName] = fieldType
	end
	tinsert(self._extensionCallbacks, callback)
	self:SetQueryUpdatesPaused(true)
	for _, row in ipairs(self:_GetRows()) do
		row:Save()
	end
	self:SetQueryUpdatesPaused(false)
end

--- Create a new row.
-- @tparam Database self The database object
-- @treturn DatabaseRow The new database row object
function Database.NewRow(self)
	local row = TSM.Database.GetDatabaseRow()
	row:_Acquire(self)
	return row
end

--- Create a new query.
-- @tparam Database self The database object
-- @treturn DatabaseQuery The new database query object
function Database.NewQuery(self)
	local query = TSM.Database.GetDatabaseQuery()
	query:_Acquire(self)
	tinsert(self._queries, query)
	return query
end

--- Delete a row.
-- @tparam Database self The database object
-- @tparam DatabaseRow deleteRow The database row object to delete
function Database.DeleteRow(self, deleteRow)
	for _, indexList in pairs(self._indexLists) do
		TSMAPI_FOUR.Util.TableRemoveByValue(indexList, deleteRow)
	end
	for field, uniqueValues in pairs(self._uniques) do
		uniqueValues[deleteRow:GetField(field)] = nil
	end
	assert(TSMAPI_FOUR.Util.TableRemoveByValue(self._rows, deleteRow) == 1)
	deleteRow:_Release()
	TSM.Database.RecycleDatabaseRow(deleteRow)
	self:_UpdateQueries()
end

--- Remove all rows.
-- @tparam Database self The database object
function Database.Truncate(self)
	for _, row in ipairs(self._rows) do
		row:_Release()
		TSM.Database.RecycleDatabaseRow(row)
	end
	wipe(self._rows)
	for _, indexList in pairs(self._indexLists) do
		wipe(indexList)
	end
	for _, uniqueValues in pairs(self._uniques) do
		wipe(uniqueValues)
	end
	self:_UpdateQueries()
end

--- Pauses or unpaused query updates.
-- Query updates should be paused while performing batch row updates to avoid spamming the update callbacks.
-- @tparam Database self The database object
-- @tparam boolean paused Whether or not query updates are paused
function Database.SetQueryUpdatesPaused(self, paused)
	self._queryUpdatesPaused = self._queryUpdatesPaused + (paused and 1 or -1)
	if self._queryUpdatesPaused == 0 and self._queuedQueryUpdate then
		self:_UpdateQueries()
	end
end

--- Get a unique row.
-- @tparam Database self The database object
-- @tparam string field The unique field
-- @param value The value of the unique field
-- @treturn ?DatabaseRow The result row
function Database.GetUniqueRow(self, field, value)
	local fieldType = self:_GetFieldType(field)
	if not fieldType then
		error(format("Field %s doesn't exist", tostring(field)), 3)
	elseif fieldType ~= type(value) then
		error(format("Field %s should be a %s, got %s", tostring(field), tostring(fieldType), type(value)), 3)
	end
	assert(self:_IsUnique(field))
	return self._uniques[field][value]
end



-- ============================================================================
-- Private Class Methods
-- ============================================================================

function Database._GetFieldType(self, field)
	return self._schema.fields[field]
end

function Database._IsIndex(self, field)
	return self._indexLists[field] and true or false
end

function Database._IsUnique(self, field)
	return self._uniques[field] and true or false
end

function Database._IndexIterator(self)
	return TSMAPI_FOUR.Util.TableKeyIterator(self._indexLists)
end

function Database._UniquesIterator(self)
	return TSMAPI_FOUR.Util.TableKeyIterator(self._uniques)
end

function Database._GetRows(self)
	return self._rows
end

function Database._GetAllRowsByIndex(self, indexField)
	return self._indexLists[indexField]
end

function Database._RowByIndexIterator(self, indexField, indexValue, isAscending, distinctField, selectList, releaseQuery, query)
	assert(type(isAscending) == "boolean")
	local indexList = self._indexLists[indexField]
	-- figure out what row to start on
	local rowIndex = nil
	if isAscending then
		rowIndex = TSMAPI_FOUR.Util.BinarySearchGetFirstIndex(indexList, indexValue, indexField)
		rowIndex = rowIndex and (rowIndex - 1) or 0
	else
		rowIndex = TSMAPI_FOUR.Util.BinarySearchGetLastIndex(indexList, indexValue, indexField)
		rowIndex = rowIndex and (rowIndex + 1) or (#indexList + 1)
	end

	local context = TSMAPI_FOUR.Util.AcquireTempTable()
	context.query = query
	context.rows = indexList
	context.ascending = isAscending
	context.field = indexField
	context.value = indexValue
	context.selectList = selectList
	context.releaseQuery = releaseQuery
	if distinctField then
		context.distinctField = distinctField
		context.distinctUsed = TSMAPI_FOUR.Util.AcquireTempTable()
	end
	return private.RowByIndexIterator, context, rowIndex
end

function Database._RemoveQuery(self, queryToRemove)
	local queryIndex = nil
	for i, query in ipairs(self._queries) do
		if query == queryToRemove then
			assert(not queryIndex)
			queryIndex = i
		end
	end
	assert(queryIndex)
	tremove(self._queries, queryIndex)
end

function Database._UpdateQueries(self)
	for _, query in ipairs(self._queries) do
		assert(not query._iterReadOnlyState)
	end
	if self._queryUpdatesPaused > 0 then
		self._queuedQueryUpdate = true
	else
		self._queuedQueryUpdate = false
		for _, query in ipairs(self._queries) do
			query:_DataUpdated()
		end
	end
end

function Database._IndexListInsert(self, field, row)
	local indexList = self._indexLists[field]
	local insertIndex = TSMAPI_FOUR.Util.BinarySearchGetInsertIndex(indexList, row:GetField(field), field)
	tinsert(indexList, insertIndex, row)
end

function Database._InsertRow(self, row)
	tinsert(self._rows, row)
	for indexField in pairs(self._indexLists) do
		self:_IndexListInsert(indexField, row)
	end
	for uniqueField, values in pairs(self._uniques) do
		local rowValue = row:GetField(uniqueField)
		assert(not self._uniques[uniqueField][rowValue], "A row with this unique value already exists")
		self._uniques[uniqueField][rowValue] = row
	end
	self:_UpdateQueries()
end

function Database._UpdateRow(self, row, oldValues)
	for field, oldValue in pairs(oldValues) do
		local indexList = self._indexLists[field]
		local uniqueValues = self._uniques[field]
		if indexList then
			-- remove and re-add row to the index list since the index value changed
			TSMAPI_FOUR.Util.TableRemoveByValue(indexList, row)
			self:_IndexListInsert(field, row)
		elseif uniqueValues then
			assert(uniqueValues[oldValue] == row)
			uniqueValues[oldValue] = nil
			uniqueValues[row:GetField(field)] = row
		end
	end
	self:_UpdateQueries()
end



-- ============================================================================
-- Private Helper Functions
-- ============================================================================

function private.RowByIndexIterator(context, index)
	while true do
		index = index + (context.ascending and 1 or -1)
		local row = context.rows[index]
		if not row or row[context.field] ~= context.value then
			assert(context.query._iterReadOnlyState ~= nil)
			context.query._iterReadOnlyState = nil
			if context.releaseQuery then
				context.releaseQuery:Release()
			end
			if context.distinctField then
				TSMAPI_FOUR.Util.ReleaseTempTable(context.distinctUsed)
			end
			TSMAPI_FOUR.Util.ReleaseTempTable(context)
			return
		elseif context.distinctField and context.distinctUsed[row[context.distinctField]] then
			-- skip this row
			row = nil
		end
		if row then
			if context.distinctField then
				context.distinctUsed[row[context.distinctField]] = true
			end
			if context.selectList then
				return index, row:GetFields(unpack(context.selectList))
			else
				return index, row
			end
		end
	end
end
