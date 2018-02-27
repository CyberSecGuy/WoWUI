-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local DatabaseQueryClause = TSMAPI_FOUR.Class.DefineClass("DatabaseQueryClause")
TSM.Database.classes.DatabaseQueryClause = DatabaseQueryClause



-- ============================================================================
-- Class Method Methods
-- ============================================================================

function DatabaseQueryClause.__init(self)
	self._query = nil
	self._operation = nil
	self._parent = nil
	-- equal
	self._field = nil
	self._value = nil
	-- or / and
	self._subClauses = {}
end

function DatabaseQueryClause._Acquire(self, query, parent)
	self._query = query
	self._parent = parent
end

function DatabaseQueryClause._Release(self)
	self._query = nil
	self._operation = nil
	self._parent = nil
	self._field = nil
	self._value = nil
	for _, clause in ipairs(self._subClauses) do
		clause:_Release()
	end
	wipe(self._subClauses)
	TSM.Database.RecycleDatabaseQueryClause(self)
end



-- ============================================================================
-- Public Class Method
-- ============================================================================

function DatabaseQueryClause.Equal(self, field, value)
	return self:_SetComparisonOperation("EQUAL", field, value)
end

function DatabaseQueryClause.NotEqual(self, field, value)
	return self:_SetComparisonOperation("NOT_EQUAL", field, value)
end

function DatabaseQueryClause.LessThan(self, field, value)
	return self:_SetComparisonOperation("LESS", field, value)
end

function DatabaseQueryClause.LessThanOrEqual(self, field, value)
	return self:_SetComparisonOperation("LESS_OR_EQUAL", field, value)
end

function DatabaseQueryClause.GreaterThan(self, field, value)
	return self:_SetComparisonOperation("GREATER", field, value)
end

function DatabaseQueryClause.GreaterThanOrEqual(self, field, value)
	return self:_SetComparisonOperation("GREATER_OR_EQUAL", field, value)
end

function DatabaseQueryClause.Matches(self, field, value)
	return self:_SetComparisonOperation("MATCHES", field, value)
end

function DatabaseQueryClause.Custom(self, func, arg)
	return self:_SetComparisonOperation("CUSTOM", func, arg)
end

function DatabaseQueryClause.HashEqual(self, fields, value)
	return self:_SetComparisonOperation("HASH_EQUAL", fields, value)
end

function DatabaseQueryClause.Or(self)
	return self:_SetSubClauseOperation("OR")
end

function DatabaseQueryClause.And(self)
	return self:_SetSubClauseOperation("AND")
end



-- ============================================================================
-- Private Class Method
-- ============================================================================

function DatabaseQueryClause._GetParent(self)
	return self._parent
end

function DatabaseQueryClause._IsTrue(self, row)
	if self._operation == "EQUAL" then
		return row:GetField(self._field) == self._value
	elseif self._operation == "NOT_EQUAL" then
		return row:GetField(self._field) ~= self._value
	elseif self._operation == "LESS" then
		return row:GetField(self._field) < self._value
	elseif self._operation == "LESS_OR_EQUAL" then
		return row:GetField(self._field) <= self._value
	elseif self._operation == "GREATER" then
		return row:GetField(self._field) > self._value
	elseif self._operation == "GREATER_OR_EQUAL" then
		return row:GetField(self._field) >= self._value
	elseif self._operation == "MATCHES" then
		return strmatch(strlower(row:GetField(self._field)), self._value) and true or false
	elseif self._operation == "CUSTOM" then
		return self._field(row, self._value) and true or false
	elseif self._operation == "HASH_EQUAL" then
		return row:CalculateHash(self._field) == self._value
	elseif self._operation == "OR" then
		for _, subClause in ipairs(self._subClauses) do
			if subClause:_IsTrue(row) then
				return true
			end
		end
		return false
	elseif self._operation == "AND" then
		for _, subClause in ipairs(self._subClauses) do
			if not subClause:_IsTrue(row) then
				return false
			end
		end
		return true
	else
		error("Invalid operation: " .. tostring(self._operation))
	end
end

function DatabaseQueryClause._GetIndexValue(self, indexField)
	if self._operation == "EQUAL" then
		if self._field ~= indexField then
			return nil
		end
		return self._value
	elseif self._operation == "AND" then
		if #self._subClauses ~= 1 then
			return nil
		end
		return self._subClauses[1]:_GetIndexValue(indexField)
	end
end

function DatabaseQueryClause._InsertSubClause(self, subClause)
	assert(self._operation == "OR" or self._operation == "AND")
	tinsert(self._subClauses, subClause)
	return self
end

function DatabaseQueryClause._SetComparisonOperation(self, operation, field, value)
	assert(not self._operation)
	self._operation = operation
	self._field = field
	self._value = value
	return self
end

function DatabaseQueryClause._SetSubClauseOperation(self, operation)
	assert(not self._operation)
	self._operation = operation
	assert(#self._subClauses == 0)
	return self
end
