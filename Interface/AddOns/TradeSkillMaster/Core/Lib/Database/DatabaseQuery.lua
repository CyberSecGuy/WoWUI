-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

--- Database Query Class.
-- This class represents a database query which is used for reading data out of a @{Database} in a structured and
-- efficient manner.
-- @classmod DatabaseQuery

local _, TSM = ...
local DatabaseQuery = TSMAPI_FOUR.Class.DefineClass("DatabaseQuery")
TSM.Database.classes.DatabaseQuery = DatabaseQuery
local private = { sortContext = nil }



-- ============================================================================
-- Class Meta Methods
-- ============================================================================

function DatabaseQuery.__init(self)
	self._db = nil
	self._rootClause = nil
	self._currentClause = nil
	self._orderBy = {}
	self._orderByAscending = {}
	self._distinct = nil
	self._updateCallback = nil
	self._select = {}
	self._iterReadOnlyState = nil
end

function DatabaseQuery._Acquire(self, db)
	self._db = db
	-- implicit root AND clause
	self._rootClause = private.NewDatabaseQueryClause(self)
		:And()
	self._currentClause = self._rootClause
end

function DatabaseQuery._Release(self)
	assert(self._iterReadOnlyState == nil)
	-- remove from the database
	self._db:_RemoveQuery(self)
	self._db = nil
	self._rootClause:_Release()
	self._rootClause = nil
	self._currentClause = nil
	wipe(self._orderBy)
	wipe(self._orderByAscending)
	self._distinct = nil
	self._updateCallback = nil
	wipe(self._select)
end



-- ============================================================================
-- Public Class Methods
-- ============================================================================

--- Releases the database query.
-- The database query object will be recycled and must not be accessed after calling this method.
-- @tparam DatabaseQuery self The database query object
function DatabaseQuery.Release(self)
	self:_Release()
	TSM.Database.RecycleDatabaseQuery(self)
end

--- Whether or not the database has the field.
-- @tparam DatabaseQuery self The database query object
-- @tparam string field The name of the field
-- @treturn DatabaseQueryClause The database query object
function DatabaseQuery.HasField(self, field)
	return self._db:_GetFieldType(field) and true or false
end

--- Where a field equals a value.
-- @tparam DatabaseQuery self The database query object
-- @tparam string field The name of the field
-- @param value The value to compare to
-- @treturn DatabaseQueryClause The database query object
function DatabaseQuery.Equal(self, field, value)
	assert(self._db:_GetFieldType(field) == type(value))
	self:_NewClause()
		:Equal(field, value)
	return self
end

--- Where a field does not equals a value.
-- @tparam DatabaseQuery self The database query object
-- @tparam string field The name of the field
-- @param value The value to compare to
-- @treturn DatabaseQueryClause The database query object
function DatabaseQuery.NotEqual(self, field, value)
	assert(self._db:_GetFieldType(field) == type(value))
	self:_NewClause()
		:NotEqual(field, value)
	return self
end

--- Where a field is less than a value.
-- @tparam DatabaseQuery self The database query object
-- @tparam string field The name of the field
-- @param value The value to compare to
-- @treturn DatabaseQueryClause The database query object
function DatabaseQuery.LessThan(self, field, value)
	assert(self._db:_GetFieldType(field) == type(value))
	self:_NewClause()
		:LessThan(field, value)
	return self
end

--- Where a field is less than or equal to a value.
-- @tparam DatabaseQuery self The database query object
-- @tparam string field The name of the field
-- @param value The value to compare to
-- @treturn DatabaseQueryClause The database query object
function DatabaseQuery.LessThanOrEqual(self, field, value)
	assert(self._db:_GetFieldType(field) == type(value))
	self:_NewClause()
		:LessThanOrEqual(field, value)
	return self
end

--- Where a field is greater than a value.
-- @tparam DatabaseQuery self The database query object
-- @tparam string field The name of the field
-- @param value The value to compare to
-- @treturn DatabaseQueryClause The database query object
function DatabaseQuery.GreaterThan(self, field, value)
	assert(self._db:_GetFieldType(field) == type(value))
	self:_NewClause()
		:GreaterThan(field, value)
	return self
end

--- Where a field is greater than or equal to a value.
-- @tparam DatabaseQuery self The database query object
-- @tparam string field The name of the field
-- @param value The value to compare to
-- @treturn DatabaseQueryClause The database query object
function DatabaseQuery.GreaterThanOrEqual(self, field, value)
	assert(self._db:_GetFieldType(field) == type(value))
	self:_NewClause()
		:GreaterThanOrEqual(field, value)
	return self
end

--- Where a string field matches a pattern.
-- @tparam DatabaseQuery self The database query object
-- @tparam string field The name of the field
-- @tparam string value The pattern to match
-- @treturn DatabaseQueryClause The database query object
function DatabaseQuery.Matches(self, field, value)
	assert(self._db:_GetFieldType(field) == "string" and type(value) == "string")
	self:_NewClause()
		:Matches(field, strlower(value))
	return self
end

--- A custom query clause.
-- @tparam DatabaseQuery self The database query object
-- @tparam function func The function which gets passed the row being evaulated and returns true/false if the query
-- should include it
-- @param[opt] arg An argument to pass to the function
-- @treturn DatabaseQueryClause The database query object
function DatabaseQuery.Custom(self, func, arg)
	assert(type(func) == "function")
	self:_NewClause()
		:Custom(func, arg)
	return self
end

--- Where the hash of a row equals a value.
-- @tparam DatabaseQuery self The database query object
-- @tparam function fields An ordered list of fields to hash
-- @tparam number value The hash value to compare to
-- @treturn DatabaseQueryClause The database query object
function DatabaseQuery.HashEqual(self, fields, value)
	assert(type(fields) == "table")
	for _, field in ipairs(fields) do
		local fieldType = self._db:_GetFieldType(field)
		if not fieldType then
			error(format("Field %s doesn't exist", tostring(field)))
		elseif fieldType ~= "number" and fieldType ~= "string" then
			error(format("Cannot hash field of type %s", fieldType))
		end
	end
	self:_NewClause()
		:HashEqual(fields, value)
	return self
end

--- Starts a nested AND clause.
-- All of the clauses following this (until the matching @{DatabaseQuery.End}) must be true for the OR clause to be true.
-- @tparam DatabaseQuery self The database query object
-- @treturn DatabaseQueryClause The database query object
function DatabaseQuery.And(self)
	self._currentClause = self:_NewClause()
		:And()
	return self
end

--- Starts a nested OR clause.
-- At least one of the clauses following this (until the matching @{DatabaseQuery.End}) must be true for the OR clause
-- to be true.
-- @tparam DatabaseQuery self The database query object
-- @treturn DatabaseQueryClause The database query object
function DatabaseQuery.Or(self)
	self._currentClause = self:_NewClause()
		:Or()
	return self
end

--- Ends a nested AND/OR clause.
-- @tparam DatabaseQuery self The database query object
-- @treturn DatabaseQueryClause The database query object
function DatabaseQuery.End(self)
	assert(self._currentClause ~= self._rootClause, "No current clause to end")
	self._currentClause = self._currentClause:_GetParent()
	assert(self._currentClause)
	return self
end

--- Order the results by a field.
-- This may be called multiple times to provide additional ordering constraints. The priority of the ordering will be
-- descending as this method is called additional times (meaning the first OrderBy will have highest priority).
-- @tparam DatabaseQuery self The database query object
-- @tparam string field The name of the field to order by
-- @tparam boolean ascending Whether to order in ascending order (descending otherwise)
-- @treturn DatabaseQueryClause The database query object
function DatabaseQuery.OrderBy(self, field, ascending)
	assert(ascending == true or ascending == false)
	local fieldType = self._db:_GetFieldType(field)
	if not fieldType then
		error(format("Field %s doesn't exist", tostring(field)))
	elseif fieldType ~= "number" and fieldType ~= "string" and fieldType ~= "boolean" then
		error(format("Cannot order by field of type %s", tostring(fieldType)))
	end
	tinsert(self._orderBy, field)
	tinsert(self._orderByAscending, ascending)
	return self
end

--- Only return distinct results based on a field.
-- This method can be used to ensure that only the first row for each distinct value of the field is returned.
-- @tparam DatabaseQuery self The database query object
-- @tparam string field The field to ensure is distinct in the results
-- @treturn DatabaseQueryClause The database query object
function DatabaseQuery.Distinct(self, field)
	assert(self._db:_GetFieldType(field), format("Field %s doesn't exist", tostring(field)))
	self._distinct = field
	return self
end

--- Select specific fields in the result.
-- @tparam DatabaseQuery self The database query object
-- @tparam vararg ... The fields to select
-- @treturn DatabaseQueryClause The database query object
function DatabaseQuery.Select(self, ...)
	assert(#self._select == 0)
	local numFields = select("#", ...)
	assert(numFields > 0, "Must select at least 1 field")
	-- DatabaseRow.GetFields() only supports 8 fields, so we can only support 8 here as well
	assert(numFields <= 8, "Select() only supports up to 8 fields")
	for i = 1, numFields do
		local field = select(i, ...)
		assert(self._db:_GetFieldType(field), format("Field %s doesn't exist", tostring(field)))
		tinsert(self._select, field)
	end
	return self
end

--- Set an update callback.
-- This callback gets called whenever any rows in the underlying database change.
-- @tparam DatabaseQuery self The database query object
-- @tparam function func The callback function
-- @treturn DatabaseQueryClause The database query object
function DatabaseQuery.SetUpdateCallback(self, func)
	self._updateCallback = func
	return self
end

--- Results iterator.
-- Note that the iterator must run to completion (don't use `break` or `return` to escape it early).
-- @tparam DatabaseQuery self The database query object
-- @tparam[opt=false] boolean isReadOnly If the query is read-only (the rows will not be modified while iterating) which
-- allows for significant additional optimizations
-- @return An iterator for the results of the query
function DatabaseQuery.Iterator(self, isReadOnly)
	return self:_Iterator(isReadOnly)
end

--- Results iterator which releases upon completion.
-- Note that the iterator must run to completion (don't use `break` or `return` to escape it early).
-- @tparam DatabaseQuery self The database query object
-- @tparam[opt=false] boolean isReadOnly If the query is read-only (the rows will not be modified while iterating) which
-- allows for significant additional optimizations
-- @return An iterator for the results of the query
function DatabaseQuery.IteratorAndRelease(self, isReadOnly)
	return self:_Iterator(isReadOnly, true)
end

--- Get the number of resulting rows.
-- @tparam DatabaseQuery self The database query object
-- @treturn number The number of rows
function DatabaseQuery.Count(self)
	local count = 0
	for _ in self:Iterator(true) do
		count = count + 1
	end
	return count
end

--- Get the number of resulting rows and release.
-- @tparam DatabaseQuery self The database query object
-- @treturn number The number of rows
function DatabaseQuery.CountAndRelease(self)
	local count = self:Count()
	self:Release()
	return count
end

--- Get a single result.
-- This method will assert that there is exactly one result from the query and return it.
-- @tparam DatabaseQuery self The database query object
-- @treturn DatabaseRow The result row
function DatabaseQuery.GetSingleResult(self)
	local result = nil
	for _, row in self:Iterator(true) do
		assert(not result)
		result = row
	end
	assert(result)
	return result
end

--- Get a single result and release.
-- This method will assert that there is exactly one result from the query and return it.
-- @tparam DatabaseQuery self The database query object
-- @treturn DatabaseRow The result row
function DatabaseQuery.GetSingleResultAndRelease(self)
	local result = self:GetSingleResult()
	self:Release()
	return result
end

--- Get the first result.
-- Note that this method internally iterates over all the results.
-- @tparam DatabaseQuery self The database query object
-- @treturn DatabaseRow The result row
function DatabaseQuery.GetFirstResult(self)
	local result = nil
	for _, row in self:Iterator(true) do
		-- can't break out of the iterator so just continue looping and store the first one
		result = result or row
	end
	return result
end

--- Get the first result and release.
-- Note that this method internally iterates over all the results.
-- @tparam DatabaseQuery self The database query object
-- @treturn DatabaseRow The result row
function DatabaseQuery.GetFirstResultAndRelease(self)
	local result = self:GetFirstResult()
	self:Release()
	return result
end

--- Resets the database query.
-- @tparam DatabaseQuery self The database query object
-- @treturn DatabaseQueryClause The database query object
function DatabaseQuery.Reset(self)
	self._distinct = nil
	wipe(self._select)
	self._rootClause:_Release()
	wipe(self._orderBy)
	wipe(self._orderByAscending)
	self._rootClause = private.NewDatabaseQueryClause(self)
		:And()
	self._currentClause = self._rootClause
	return self
end



-- ============================================================================
-- Private Class Methods
-- ============================================================================

function DatabaseQuery._DataUpdated(self)
	if self._updateCallback then
		self:_updateCallback()
	end
end

function DatabaseQuery._NewClause(self)
	local newClause = private.NewDatabaseQueryClause(self, self._currentClause)
	self._currentClause:_InsertSubClause(newClause)
	return newClause
end

function DatabaseQuery._Iterator(self, isReadOnly, release)
	assert(self._rootClause and self._currentClause == self._rootClause, "Did not end sub-clause")
	-- try to find an index to use to optimize this query
	local indexField, indexValue = nil, nil
	for field in self._db:_UniquesIterator() do
		local value = self._rootClause:_GetIndexValue(field)
		if not indexField and value ~= nil then
			indexField = field
			indexValue = value
		end
	end
	if not indexField then
		for field in self._db:_IndexIterator() do
			local value = self._rootClause:_GetIndexValue(field)
			if not indexField and value ~= nil then
				indexField = field
				indexValue = value
			end
		end
	end
	-- get all the rows which match the query
	local result = nil
	local firstOrderBy = self._orderBy[1]
	local sortNeeded = firstOrderBy and true or false
	if indexField and self._db:_IsUnique(indexField) then
		-- we are looking for a unique row, so return an iterator which passes it through
		local context = TSMAPI_FOUR.Util.AcquireTempTable()
		context.row = self._db:GetUniqueRow(indexField, indexValue)
		context.selectList = #self._select > 0 and self._select or nil
		context.query = self
		context.releaseQuery = release and self or nil
		assert(self._iterReadOnlyState == nil)
		self._iterReadOnlyState = isReadOnly and true or false
		return private.PassThroughIterator, context, nil
	elseif indexField then
		-- we're querying on an index, so use that index to populate the result
		local isAscending = true
		if firstOrderBy and indexField == firstOrderBy then
			-- we're also ordering by this field so can skip the first OrderBy field
			sortNeeded = #self._orderBy > 1
			isAscending = self._orderByAscending[1]
		end
		if not sortNeeded and isReadOnly then
			local selectList = #self._select > 0 and self._select or nil
			assert(self._iterReadOnlyState == nil)
			self._iterReadOnlyState = isReadOnly and true or false
			return self._db:_RowByIndexIterator(indexField, indexValue, isAscending, self._distinct, selectList, release and self or nil, self)
		end
		result = TSMAPI_FOUR.Util.AcquireTempTable(result)
		assert(self._iterReadOnlyState == nil)
		self._iterReadOnlyState = isReadOnly and true or false
		for _, row in self._db:_RowByIndexIterator(indexField, indexValue, isAscending, self._distinct, nil, nil, self) do
			tinsert(result, row)
		end
	elseif firstOrderBy and self._db:_IsIndex(firstOrderBy) then
		-- we're ordering on an index, so use that index to iterate through all the rows in order to skip the first OrderBy field
		sortNeeded = #self._orderBy > 1
		local indexTable = self._db:_GetAllRowsByIndex(firstOrderBy)
		if not sortNeeded and isReadOnly then
			local context = TSMAPI_FOUR.Util.AcquireTempTable()
			context.query = self
			context.rows = indexTable
			context.ascending = self._orderByAscending[1]
			context.queryClause = self._rootClause
			context.selectList = #self._select > 0 and self._select or nil
			context.releaseQuery = release and self or nil
			if self._distinct then
				context.distinctField = self._distinct
				context.distinctUsed = TSMAPI_FOUR.Util.AcquireTempTable()
			end
			assert(self._iterReadOnlyState == nil)
			self._iterReadOnlyState = isReadOnly and true or false
			return private.RowByQueryIterator, context, context.ascending and 0 or #context.rows + 1
		end
		result = TSMAPI_FOUR.Util.AcquireTempTable(result)
		if self._orderByAscending[1] then
			for i = 1, #indexTable do
				local row = indexTable[i]
				if self._rootClause:_IsTrue(row) then
					tinsert(result, row)
				end
			end
		else
			for i = #indexTable, 1, -1 do
				local row = indexTable[i]
				if self._rootClause:_IsTrue(row) then
					tinsert(result, row)
				end
			end
		end
	elseif not sortNeeded and isReadOnly then
		local context = TSMAPI_FOUR.Util.AcquireTempTable()
		context.query = self
		context.rows = self._db:_GetRows()
		context.ascending = true
		context.queryClause = self._rootClause
		context.selectList = #self._select > 0 and self._select or nil
		context.releaseQuery = release and self or nil
		if self._distinct then
			context.distinctField = self._distinct
			context.distinctUsed = TSMAPI_FOUR.Util.AcquireTempTable()
		end
		assert(self._iterReadOnlyState == nil)
		self._iterReadOnlyState = isReadOnly and true or false
		return private.RowByQueryIterator, context, 0
	else
		result = TSMAPI_FOUR.Util.AcquireTempTable(result)
		-- no optimizations
		local distinctUsed = TSMAPI_FOUR.Util.AcquireTempTable()
		for _, row in ipairs(self._db:_GetRows()) do
			if self._rootClause:_IsTrue(row) then
				if self._distinct then
					local distinctValue = row:GetField(self._distinct)
					if not distinctUsed[distinctValue] then
						distinctUsed[distinctValue] = true
						tinsert(result, row)
					end
				else
					tinsert(result, row)
				end
			end
		end
		TSMAPI_FOUR.Util.ReleaseTempTable(distinctUsed)
	end
	assert(result)
	if sortNeeded then
		private.sortContext = self
		sort(result, private.DatabaseQuerySort)
		private.sortContext = nil
	end
	result._iterQuery = self
	result._iterSelectList = #self._select > 0 and self._select or nil
	result._iterReleaseQuery = release and self or nil
	assert(self._iterReadOnlyState == nil)
	self._iterReadOnlyState = isReadOnly and true or false
	return private.QueryResultIterator, result, 0
end



-- ============================================================================
-- Private Helper Functions
-- ============================================================================

function private.DatabaseQuerySort(a, b)
	local self = private.sortContext
	for i = 1, #self._orderBy do
		local orderByField = self._orderBy[i]
		local aValue = a:GetField(orderByField)
		local bValue = b:GetField(orderByField)
		local fieldType = self._db:_GetFieldType(orderByField)
		if fieldType == "string" then
			aValue = strlower(aValue)
			bValue = strlower(bValue)
		elseif fieldType == "boolean" then
			aValue = aValue and 1 or 0
			bValue = bValue and 1 or 0
		end
		if aValue == bValue then
			-- continue looping
		elseif self._orderByAscending[i] then
			return aValue < bValue
		else
			return aValue > bValue
		end
	end
	-- make the sort stable
	return tostring(a) < tostring(b)
end

function private.NewDatabaseQueryClause(query, parent)
	local clause = TSM.Database.GetDatabaseQueryClause()
	clause:_Acquire(query, parent)
	return clause
end

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

function private.RowByQueryIterator(context, index)
	while true do
		index = index + (context.ascending and 1 or -1)
		local row = context.rows[index]
		if not row then
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
		elseif context.distinctField and context.distinctUsed[row:GetField(context.distinctField)] then
			-- continue looping
		elseif not context.queryClause:_IsTrue(row) then
			-- continue looping
		else
			if context.distinctField then
				context.distinctUsed[row:GetField(context.distinctField)] = true
			end
			if context.selectList then
				return index, row:GetFields(unpack(context.selectList))
			else
				return index, row
			end
		end
	end
end

function private.PassThroughIterator(context, index)
	if index or not context.row then
		assert(context.query._iterReadOnlyState ~= nil)
		context.query._iterReadOnlyState = nil
		if context.releaseQuery then
			context.releaseQuery:Release()
		end
		TSMAPI_FOUR.Util.ReleaseTempTable(context)
		return
	end
	if context.selectList then
		return 1, context.row:GetFields(unpack(context.selectList))
	else
		return 1, context.row
	end
end

function private.QueryResultIterator(tbl, index)
	index = index + 1
	local row = tbl[index]
	if not row then
		assert(tbl._iterQuery._iterReadOnlyState ~= nil)
		tbl._iterQuery._iterReadOnlyState = nil
		if tbl._iterReleaseQuery then
			tbl._iterReleaseQuery:Release()
		end
		TSMAPI_FOUR.Util.ReleaseTempTable(tbl)
		return
	elseif tbl._iterSelectList then
		return index, row:GetFields(unpack(tbl._iterSelectList))
	else
		return index, row
	end
end
