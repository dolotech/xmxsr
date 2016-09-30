local GameMgr = class("GameMgr")

local cclog = function(...)
    print(string.format(...))
end


local function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
    return msg
end

function GameMgr:EnableListenOnTCP(port_number)
    return cc.Director:getInstance():getConsole():listenOnTCP(port_number)
end

function GameMgr:AddConsoleCommand(name, help, call_back)
    return cc.Director:getInstance():getConsole():addCommand({name = name, help = help}, call_back)
end


function GameMgr:InsertConsoleCmd(cmd_string)
    self.wait_execute_cmd_string = cmd_string
end

function GameMgr:Init()
    local function executeCmd(handler, cmd_string)
        self:InsertConsoleCmd(cmd_string)
    end
    
    self:EnableListenOnTCP(10001)
    
    self:AddConsoleCommand("lua", "Execute a Lua Command String.", executeCmd)
    
    cc.Director:getInstance():getScheduler():scheduleScriptFunc(function () self:onEnterFrame() end,0,false)

end

function GameMgr:onEnterFrame()
    if self.wait_execute_cmd_string then
        self:ExecuteCmdString(self.wait_execute_cmd_string)
        self.wait_execute_cmd_string = nil
    end  
    

end

function GameMgr:ExecuteCmdString(cmd_string)
    if cmd_string then
        local cmd_func = loadstring(cmd_string)
        if cmd_func then
            xpcall(cmd_func, __G__TRACKBACK__)
        else
            cclog("Invalid CMD! %s", cmd_string)
        end
    end
end

return GameMgr