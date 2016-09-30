

function JCL_NotificationALL(param)
    local PushService = require("sdk.PushService")
    
    --体力满推送
    local curPower = SharedManager:readData(Config.POWER)
    local limitPower = SharedManager:readData(Config.LIMITPOWER)
    local diffPower = limitPower - curPower - 1
    
    if diffPower > -1 then
        local saveTime =  SharedManager:readData(Config.POWERTIME)
        local time = Config.POWER_CD_TIME*60 - os.difftime(math.floor(socket.gettime()),saveTime)
        PushService:notificationMessage("体力满了",(Config.POWER_CD_TIME*60)*diffPower+time)
    end
    
    --中午晚上送体力
    local curDate = os.date("*t");
    local futuretime = os.time({year=curDate.year, month=curDate.month, day=curDate.day, hour=12})
    local time = futuretime - os.time()
    if time>0 then PushService:notificationMessage("中午赠送体力",time) end
    
    futuretime = os.time({year=curDate.year, month=curDate.month, day=curDate.day, hour=18})
    time = futuretime - os.time()
    if time>0 then PushService:notificationMessage("下午赠送体力",time) end
    
    --每日签到
    local from = os.time()
    local data = SharedManager:readData(Config.Sign)
    from = os.time(data.date) - from
    if (from) >= 0 then
        if curDate.hour > 20 then 
            from = from + 11*3600 - (60 - curDate.min)*60
        end
        PushService:notificationMessage("可以签到",from) 
    end
end

--推送服务
local PushService = class("PushService")
----------------------------------------------------------------------

function PushService:notificationMessage(message,time,repeats)
    if device.platform=="android" then
        local luaj = require("cocos.cocos2d.luaj")
        local javaClassName = "org.cocos2dx.lua.AppActivity"
        local javaMethodName = "pushMessage"
        local args ={message,time,repeats or 1}
        luaj.callStaticMethod(javaClassName, javaMethodName, args)
    elseif device.platform=="ios" then
        
    end
end

----------------------------------------------------------------------
return PushService
