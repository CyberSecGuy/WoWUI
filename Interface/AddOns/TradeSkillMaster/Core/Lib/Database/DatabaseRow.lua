-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

--- Database Row Class.
-- This class represents a single row in a @{Database}.
-- @classmod DatabaseRow

local _, TSM = ...
local DatabaseRow = TSMAPI_FOUR.Class.DefineClass("DatabaseRow")
TSM.Database.classes.DatabaseRow = DatabaseRow



-- ============================================================================
-- Class Meta Methods
-- ============================================================================

function DatabaseRow.__init(self)
	self._db = nil
	self._created = false
	self._noInsert = false
	self._pendingChanges = {}
end

function DatabaseRow._Acquire(self, db)
	self._db = db
	self._created = false
	self._noInsert = false
end

function DatabaseRow._Release(self)
	self._db = nil
	assert(not next(self._pendingChanges))
end



-- ============================================================================
-- Public Class Methods
-- ============================================================================

--- Set the value of a field.
-- Note that any changes made will be pending and not visible until @{DatabaseRow.Save} is called.
-- @tparam DatabaseRow self The database row object
-- @tparam string field The field to set
-- @param value The value to set the field to
-- @treturn DatabaseRow The database row object
function DatabaseRow.SetField(self, field, value)
	local fieldType = self._db:_GetFieldType(field)
	if not fieldType then
		error(format("Field %s doesn't exist", tostring(field)), 3)
	elseif fieldType ~= type(value) then
		error(format("Field %s should be a %s, got %s", tostring(field), tostring(self._db:_GetFieldType(field)), type(value)), 3)
	end
	if value == self[field] then
		-- setting the field to its original value, so clear any pending change
		self._pendingChanges[field] = nil
	else
		self._pendingChanges[field] = value
	end
	return self
end

--- Increment a field.
-- Note that any changes made will be pending and not visible until @{DatabaseRow.Save} is called.
-- @tparam DatabaseRow self The database row object
-- @tparam string field The field to increment
-- @treturn DatabaseRow The database row object
function DatabaseRow.IncrementField(self, field)
	local fieldType = self._db:_GetFieldType(field)
	assert(self._db:_GetFieldType(field) == "number", format("Cannot increment a field of type %s", fieldType))
	local value = (self._pendingChanges[field] or self[field]) + 1
	if value == self[field] then
		-- setting the field to its original value, so clear any pending change
		self._pendingChanges[field] = nil
	else
		self._pendingChanges[field] = value
	end
	return self
end

--- Decrement a field.
-- Note that any changes made will be pending and not visible until @{DatabaseRow.Save} is called.
-- @tparam DatabaseRow self The database row object
-- @tparam string field The field to decrement
-- @treturn DatabaseRow The database row object
function DatabaseRow.DecrementField(self, field)
	local fieldType = self._db:_GetFieldType(field)
	assert(self._db:_GetFieldType(field) == "number", format("Cannot increment a field of type %s", fieldType))
	local value = (self._pendingChanges[field] or self[field]) - 1
	if value == self[field] then
		-- setting the field to its original value, so clear any pending change
		self._pendingChanges[field] = nil
	else
		self._pendingChanges[field] = value
	end
	return self
end

--- Get the value of a field.
-- @tparam DatabaseRow self The database row object
-- @tparam string field The field to get
-- @return The value of the field
function DatabaseRow.GetField(self, field)
	local fieldType = self._db:_GetFieldType(field)
	if not fieldType then
		error(format("Field %s doesn't exist", tostring(field)))
	end
	return self[field]
end

--- Get the value of multiple fields.
-- This method currently supports up to 8 fields.
-- @tparam DatabaseRow self The database row object
-- @tparam vararg ... The fields to get the value of
-- @return The values of the fields
function DatabaseRow.GetFields(self, ...)
	local numFields = select("#", ...)
	local field1, field2, field3, field4, field5, field6, field7, field8 = ...
	if numFields == 0 then
		return
	elseif numFields == 1 then
		return self:GetField(field1)
	elseif numFields == 2 then
		return self:GetField(field1), self:GetField(field2)
	elseif numFields == 3 then
		return self:GetField(field1), self:GetField(field2), self:GetField(field3)
	elseif numFields == 4 then
		return self:GetField(field1), self:GetField(field2), self:GetField(field3), self:GetField(field4)
	elseif numFields == 5 then
		return self:GetField(field1), self:GetField(field2), self:GetField(field3), self:GetField(field4), self:GetField(field5)
	elseif numFields == 6 then
		return self:GetField(field1), self:GetField(field2), self:GetField(field3), self:GetField(field4), self:GetField(field5), self:GetField(field6)
	elseif numFields == 7 then
		return self:GetField(field1), self:GetField(field2), self:GetField(field3), self:GetField(field4), self:GetField(field5), self:GetField(field6), self:GetField(field7)
	elseif numFields == 8 then
		return self:GetField(field1), self:GetField(field2), self:GetField(field3), self:GetField(field4), self:GetField(field5), self:GetField(field6), self:GetField(field7), self:GetField(field8)
	else
		error("GetFields() only supports up to 8 fields")
	end
end

--- Save any pending changes to the row.
-- Saves all pending changes made via @{DatabaseRow.SetField}. This will also cause it to be inserted into the
-- @{Database} if it's not already.
-- @tparam DatabaseRow self The database row object
-- @treturn DatabaseRow The database row object
function DatabaseRow.Save(self)
	assert(not self._noInsert)
	local oldValues = nil
	-- apply all the pending changes
	for field, value in pairs(self._pendingChanges) do
		if self._created then
			oldValues = oldValues or TSMAPI_FOUR.Util.AcquireTempTable()
			oldValues[field] = self[field]
		end
		self[field] = value
	end
	wipe(self._pendingChanges)

	-- go through and handle the extensions
	for _, callback in ipairs(self._db._extensionCallbacks) do
		callback(self)
	end

	-- apply all the pending changes from the extensions
	for field, value in pairs(self._pendingChanges) do
		if self._created then
			oldValues = oldValues or TSMAPI_FOUR.Util.AcquireTempTable()
			oldValues[field] = self[field]
		end
		self[field] = value
	end
	wipe(self._pendingChanges)

	if not self._created then
		self._created = true
		self._db:_InsertRow(self)
	elseif oldValues then
		self._db:_UpdateRow(self, oldValues)
		TSMAPI_FOUR.Util.ReleaseTempTable(oldValues)
	end

	return self
end

--- Save any pending changes to the row without inserting it.
-- Saves all pending changes made via @{DatabaseRow.SetField}.
-- @tparam DatabaseRow self The database row object
-- @treturn DatabaseRow The database row object
function DatabaseRow.SaveNoInsert(self)
	assert(not self._db:_GetRowIndex(self))
	-- apply all the pending changes
	for field, value in pairs(self._pendingChanges) do
		self[field] = value
	end
	wipe(self._pendingChanges)
	self._noInsert = true
	return self
end

--- Discard the row.
-- @tparam DatabaseRow self The database row object
-- @treturn DatabaseRow The database row object
function DatabaseRow.Discard(self)
	assert(self._noInsert)
	self:_Release()
	TSM.Database.RecycleDatabaseRow(self)
end

--- Calculate the hash of a list of fields.
-- @tparam DatabaseRow self The database row object
-- @tparam table fields An ordered list of fields to include in the hash calculation
-- @treturn number The hash value
function DatabaseRow.CalculateHash(self, fields)
	local hash = nil
	for _, field in ipairs(fields) do
		hash = TSMAPI_FOUR.Util.CalculateHash(self[field], hash)
	end
	return hash
end
