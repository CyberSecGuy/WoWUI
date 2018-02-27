-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local RPC = TSM.Sync:NewPackage("RPC")
local private = {
	rpcFunctions = {},
	pendingRPC = {},
	rpcSeqNum = 0,
}
local RPC_TIMEOUT = 5



-- ============================================================================
-- TSMAPI Functions
-- ============================================================================

function TSMAPI_FOUR.Sync.RegisterRPC(name, func)
	RPC.Register(name, func)
end

function TSMAPI_FOUR.Sync.CallRPC(name, targetPlayer, handler, ...)
	assert(targetPlayer)
	if not TSM.Sync.Connection.IsPlayerConnected(targetPlayer) then
		return false
	end

	assert(private.rpcFunctions[name], "Cannot call an RPC which is not also registered locally.")
	private.rpcSeqNum = private.rpcSeqNum + 1

	local requestData = TSMAPI_FOUR.Util.AcquireTempTable()
	requestData.name = name
	requestData.args = TSMAPI_FOUR.Util.AcquireTempTable(...)
	requestData.seq = private.rpcSeqNum
	TSM.Sync.Comm.SendData(TSM.Sync.DATA_TYPES.RPC_CALL, targetPlayer, requestData)
	TSMAPI_FOUR.Util.ReleaseTempTable(requestData.args)
	TSMAPI_FOUR.Util.ReleaseTempTable(requestData)

	local context = TSMAPI_FOUR.Util.AcquireTempTable()
	context.name = name
	context.handler = handler
	context.sendTime = time()
	private.pendingRPC[private.rpcSeqNum] = context

	return true
end

function TSMAPI_FOUR.Sync.CancelRPC(name, handler)
	for seq, info in pairs(private.pendingRPC) do
		if info.name == name and info.handler == handler then
			TSMAPI_FOUR.Util.ReleaseTempTable(info)
			private.pendingRPC[seq] = nil
			return
		end
	end
end



-- ============================================================================
-- Module Functions
-- ============================================================================

function RPC.OnInitialize()
	TSM.Sync.Comm.RegisterHandler(TSM.Sync.DATA_TYPES.RPC_CALL, private.HandleCall)
	TSM.Sync.Comm.RegisterHandler(TSM.Sync.DATA_TYPES.RPC_RETURN, private.HandleReturn)
end

function RPC.Register(name, func)
	assert(name)
	private.rpcFunctions[name] = func
end

function RPC.CheckPending()
	local timedOut = TSMAPI_FOUR.Util.AcquireTempTable()
	for seq, info in pairs(private.pendingRPC) do
		if time() - info.sendTime > RPC_TIMEOUT then
			tinsert(timedOut, seq)
		end
	end
	for _, seq in ipairs(timedOut) do
		local info = private.pendingRPC[seq]
		info.handler()
		TSMAPI_FOUR.Util.ReleaseTempTable(info)
		private.pendingRPC[seq] = nil
	end
	TSMAPI_FOUR.Util.ReleaseTempTable(timedOut)
end



-- ============================================================================
-- Message Handlers
-- ============================================================================

function private.HandleCall(dataType, _, sourcePlayer, data)
	assert(dataType == TSM.Sync.DATA_TYPES.RPC_CALL)
	if type(data) ~= "table" or type(data.name) ~= "string" or type(data.seq) ~= "number" or type(data.args) ~= "table" then
		return
	end
	local rpcFunc = private.rpcFunctions[data.name]
	if not rpcFunc then
		return
	end
	local responseData = TSMAPI_FOUR.Util.AcquireTempTable()
	responseData.result = TSMAPI_FOUR.Util.AcquireTempTable(private.rpcFunctions[data.name](unpack(data.args)))
	responseData.seq = data.seq
	TSM.Sync.Comm.SendData(TSM.Sync.DATA_TYPES.RPC_RETURN, sourcePlayer, responseData)
	TSMAPI_FOUR.Util.ReleaseTempTable(responseData.result)
	TSMAPI_FOUR.Util.ReleaseTempTable(responseData)
end

function private.HandleReturn(dataType, _, _, data)
	assert(dataType == TSM.Sync.DATA_TYPES.RPC_RETURN)
	if type(data.seq) ~= "number" or type(data.result) ~= "table" then
		return
	elseif not private.pendingRPC[data.seq] then
		return
	end
	private.pendingRPC[data.seq].handler(unpack(data.result))
	TSMAPI_FOUR.Util.ReleaseTempTable(private.pendingRPC[data.seq])
	private.pendingRPC[data.seq] = nil
end
