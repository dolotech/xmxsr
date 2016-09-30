
SocketTCP = require("game.net.SocketTCP")
ByteArray = require("game.util.ByteArray")
local Socket = class("Socket")
------------------------------------------------------------
local RECVBUFFERSIZE = 65535
local socket_ = nil
function Socket:initSocket( _host, _port, _funList )
	if not socket_ then
		socket_ = SocketTCP.new(_host, _port, false)
		socket_:addEventListener(SocketTCP.EVENT_CONNECTED, _funList.onStatus)
		socket_:addEventListener(SocketTCP.EVENT_CLOSE, _funList.onStatus)
		socket_:addEventListener(SocketTCP.EVENT_CLOSED, _funList.onStatus)
		socket_:addEventListener(SocketTCP.EVENT_CONNECT_FAILURE, _funList.onStatus)
		socket_:addEventListener(SocketTCP.EVENT_DATA, handler(self, self.onData))
		self.funOnData = _funList.onData
	end
end

function Socket:connect( )
	socket_:connect()
end

function Socket:close( )
	if(socket_ ~= nil)then socket_:close() end
	socket_ = nil
end

function Socket:send( _serverid, ...)
	-- local str = string.char(2) .. seri.pack_tostring(2, "123", 13, "hm") //测试数据
	local str = string.char(_serverid) .. seri.pack_tostring(...)
	local len = string.len(str)
	if(len < RECVBUFFERSIZE)then 
		self:sendOne(str)
		return
	end
	local slen = 0
	while slen + RECVBUFFERSIZE <= len do
		self:sendOne(str:sub(slen + 1, slen + RECVBUFFERSIZE))
		slen = slen + RECVBUFFERSIZE
	end
	if(slen<len)then
		self:sendOne(str:sub(slen + 1, len))
	else
		self:sendOne("")
	end
end
function Socket:sendOne( _strMsg )
	local buf = ByteArray.new()
	buf:writeUShort(string.len(_strMsg))
	buf:writeString(_strMsg)
	socket_:send(buf:getBytes())
end

-------------
-- function Socket:onStatus( _event )
--     if(_event.name == SocketTCP.EVENT_CONNECTED)then 
--         local buf = cc.utils.ByteArray.new()
--         local str = "1021237sldfjsldf"
--         -- 0 a 7b 22 74 79 70 65 22 3a 33 7d 
--         buf:writeUShort(string.len(str))
--         buf:writeString(str)
--         local data = buf:getBytes()
--         Socket:send(data)
--         print("send data:", buf.toString(data, 16))
--     end
-- end

function Socket:onData( _event )
    -- print("socket receive raw data:", cc.utils.ByteArray.toString(_event.data, string.byte(_event.data)))
    -- local __msgs = self._buf:parsePackets(_event.data)
    -- local __msg = nil
    -- for i=1,#__msgs do
    --     __msg = __msgs[i]
    --     dump(__msg)
    -- end
	self.funOnData(_event)
end

------------------------------------------------------------
return Socket