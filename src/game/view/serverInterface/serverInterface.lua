serverinterface = {}

serverinterface.friendData = {}

serverinterface.CLOSE = 1
serverinterface.CLOSING = 2
serverinterface.CONNECTING = 3
serverinterface.CONNECTED = 4
serverinterface.CONNECT_FAILURE = 5

serverinterface.NIL = 0
serverinterface.ACCOUNT = 1
serverinterface.MOTIFYNAME = 2
serverinterface.GETFRIEND = 3
serverinterface.ADDFRIEND = 4
serverinterface.SAVEACCOUINTINFO = 5
serverinterface.WARMADDFRIEND = 6

serverinterface.netstate = serverinterface.CLOSE
serverinterface.curMsg = serverinterface.NIL
serverinterface.callfunc1 = function() end
serverinterface.callfunc2 = function() end
serverinterface.MsgCollect = {}

Socket = require("game.net.Socket")
require("game/data/ServerCodeData")

serverinterface.__onStatus = function( _event )
    if(_event.name == SocketTCP.EVENT_CONNECTED)then 
        serverinterface.netstate = serverinterface.CONNECTED
        serverinterface.sendMsg()
    elseif(_event.name == SocketTCP.EVENT_CONNECT_FAILURE) then --连接服务器失败
        serverinterface.netstate = serverinterface.CLOSE
        if serverinterface.curMsg == serverinterface.MOTIFYNAME then
            serverinterface.callfunc1(2)
        elseif serverinterface.curMsg == serverinterface.GETFRIEND then
            serverinterface.callfunc1(1)
        elseif serverinterface.curMsg == serverinterface.ADDFRIEND then
            serverinterface.callfunc1(2)
        end
        serverinterface.closeConnect()
    elseif(_event.name == SocketTCP.EVENT_CLOSE) then --连接正在关闭
        serverinterface.netstate = serverinterface.CLOSING
    elseif _event.name == SocketTCP.EVENT_CLOSED then
        print("connect close")
        serverinterface.netstate = serverinterface.CLOSE
        --TipsManager.ShowText("can do num = " .. tostring(#serverinterface.MsgCollect))
        if #serverinterface.MsgCollect >= 1 then
            serverinterface.MsgDoneById(serverinterface.MsgCollect[1].msg,serverinterface.MsgCollect[1].func1,serverinterface.MsgCollect[1].func2)
            table.remove(serverinterface.MsgCollect,1)
        end
    end
end

serverinterface.__onData = function( _event )
    print("data come ,hehe ")
    _event.data = string.sub(_event.data, 4, string.len(_event.data))
    local tList = seri.unpack(_event.data)
    if tList.err ~= nil then 
        print(" dataErr: " .. tostring(tList.err)) 
        serverinterface.callDataErr(tList.err)
    else
        print("come here")
        serverinterface.callData(tList)
    end
end

--消息管理
serverinterface.MsgDoneById = function(_msg,_func1,_func2)
    if device.platform == "windows" then
        if _msg ~= serverinterface.ACCOUNT then
            TipsManager:ShowText(Language.gm_SeverConnectFails)
        end
        return
    end
    if serverinterface.isMsgNeedDone(_msg) then
        local result = true
        print("curMsg: " .. tostring(serverinterface.curMsg) .. " netState: " .. tostring(serverinterface.netstate))
        if serverinterface.curMsg == serverinterface.NIL then
            if serverinterface.netstate == serverinterface.CLOSE then
                result = false
                serverinterface.curMsg = _msg
                serverinterface.callfunc1 = _func1
                serverinterface.callfunc2 = _func2
                serverinterface.netstate = serverinterface.CONNECTING
                Socket:initSocket(ServerCode.host, ServerCode.port, {onStatus = serverinterface.__onStatus, onData = serverinterface.__onData})
                Socket:connect()
            end
        end
        print("result: " .. tostring(result))
        if result then
            if _msg == serverinterface.curMsg then
                return
            end
            local index = #serverinterface.MsgCollect + 1
            TipsManager.ShowText("num = " .. tostring(index))
            serverinterface.MsgCollect[index] = {}
            serverinterface.MsgCollect[index].msg = _msg
            serverinterface.MsgCollect[index].func1 = _func1
            serverinterface.MsgCollect[index].func2 = _func2
        end
    end
end

--发送消息
serverinterface.sendMsg = function()
    if serverinterface.curMsg == serverinterface.ACCOUNT then
        print("serverinterface ACCOUNT")
        Socket:send(ServerCode.AccountNumber[1], ServerCode.AccountNumber[2],"",cc.Native:getOpenUDID(),"hm")
    elseif serverinterface.curMsg == serverinterface.MOTIFYNAME then
        print("serverinterface MOTIFYNAME")
        if userid == "nil" then
            serverinterface.closeConnect()
            serverinterface.callfunc1(3)
        else
            local userid = SharedManager:readData("name")
            local name = serverinterface.callfunc2()
            Socket:send(ServerCode.AccountNameMotify[1], ServerCode.AccountNameMotify[2],userid,name)
        end
    elseif serverinterface.curMsg == serverinterface.GETFRIEND then
        print("serverinterface GETFRIEND")
        if userid == "nil" then
            serverinterface.closeConnect()
            serverinterface.callfunc1(2)
        else
            print("getFriend .. userid is not nil")
            local userid = SharedManager:readData("name")
            Socket:send(ServerCode.FriendInfo[1], ServerCode.FriendInfo[2],userid)
        end
    elseif serverinterface.curMsg == serverinterface.ADDFRIEND then
        print("serverinterface ADDFRIEND")
        local userid = SharedManager:readData("name")
        if userid == "nil" then
            serverinterface.closeConnect()
            serverinterface.callfunc1(3)
        else
            local name = serverinterface.callfunc2()
            print("other id is: " .. name)
            Socket:send(ServerCode.AddFriend[1], ServerCode.AddFriend[2],userid,name)
        end
    elseif serverinterface.curMsg == serverinterface.SAVEACCOUINTINFO then
        print("serverinterface SAVEACCOUINTINFO")
        local tData = serverinterface.callfunc1()
        if tData == nil then
            print("发的是nil ma")
        end
        Socket:send(ServerCode.AccountInfo[1], ServerCode.AccountInfo[2],tData.userid,tData.data)
    elseif serverinterface.curMsg == serverinterface.WARMADDFRIEND then
        print("serverinterface WARMADDFRIEND")
        local userid = SharedManager:readData("name")
        Socket:send(ServerCode.WarnAddFriend[1], ServerCode.WarnAddFriend[2],userid)
    end
end

serverinterface.callData = function(tList)
    local msg = serverinterface.curMsg
    serverinterface.closeConnect()
    if msg == serverinterface.ACCOUNT then
        if tList.type == ServerCode.AccountNumber[2] then
            SharedManager:saveData("name",tList.userid,true)
        end
    elseif msg == serverinterface.MOTIFYNAME then
        if tList.type == ServerCode.AccountNameMotify[2] then
            serverinterface.callfunc1(1)
        end
    elseif msg == serverinterface.GETFRIEND then
        if tList.type == ServerCode.FriendInfo[2] then
            if tList.friends == nil then
                serverinterface.callfunc1(0)
            else
                print(table.nums(tList.friends))
                serverinterface.friendData = tList.friends
                serverinterface.callfunc1(0)
            end
        end
    elseif msg == serverinterface.ADDFRIEND then
        if tList.type == ServerCode.AddFriend[2] then
            serverinterface.callfunc1(1)
        end
    elseif msg == serverinterface.SAVEACCOUINTINFO then
        if tList.type == ServerCode.AccountInfo[2] then
            if tList ~= nil then
                print("Account Info is not nil")
                --serverinterface.callfunc2(tList)
            end
        end
    elseif msg == serverinterface.WARMADDFRIEND then
        if tList.type == ServerCode.WarnAddFriend[2] then
            local tlocalData = SharedManager:readData(Config.friendInfo)
            local tData  = {}
            math.randomseed(os.time())
            local randomNum = math.random(12)
            tData.name = "未命名玩家"
            tData.checkPoint = SharedManager:readData(Config.POINT) + randomNum - 1000;
            tData.starCount = SharedManager:readData(Config.Star).count + randomNum*2;
            tlocalData[#tlocalData + 1] =  tData
            SharedManager:saveData(Config.friendInfo,tlocalData,true)
        end
    end
end

serverinterface.callDataErr = function(err)
    if serverinterface.curMsg == serverinterface.ACCOUNT then
        
    elseif serverinterface.curMsg == serverinterface.MOTIFYNAME then
        
    elseif serverinterface.curMsg == serverinterface.GETFRIEND then
        serverinterface.callfunc1(2)
    elseif serverinterface.curMsg == serverinterface.ADDFRIEND then
        serverinterface.callfunc1(err)
    end
    serverinterface.closeConnect()
end

serverinterface.isMsgNeedDone = function(_msg)
    -- if _msg == serverinterface.ACCOUNT then
    --     local userid = SharedManager:readData("name")
    --     if userid ~= "nil" then
    --         return false
    --     end
    -- end
    return true
end

serverinterface.closeConnect = function()
    serverinterface.netstate = serverinterface.CLOSING
    serverinterface.curMsg = serverinterface.NIL
    Socket:close()

end




