local PowerBar = class("PowerBar",function()
    return display.createUI(Csbs.NODE_POWER_CSB)
end)

local panel = nil

function PowerBar:create()
    local ui = PowerBar.new()
    ui:setNodeEventEnabled()
    return ui
end

function PowerBar:onEnter()
    self.panel = self:getChildByName("Panel_1")
    self.panel:getChildByName("Text_2"):setVisible(false)
    Color.setLableShadows({self.panel:getChildByName("Text_1"),self.panel:getChildByName("Text_2")})
    self.panel:onClick(function()DialogManager:open("game.view.power.PowerDialog")end, true)
    -- self:getChildByName("Button_2"):onClick(function()DialogManager:open("game.view.power.PowerDialog")end, true)

    local function setPowerText()
        local power = SharedManager:readData(Config.POWER)
        local limitpower = SharedManager:readData(Config.LIMITPOWER)
        self.panel:getChildByName("Text_1"):setString(power .."/" ..  limitpower)
        local node = self.panel:getChildByName("LoadingBar_1")
        local percent = power/limitpower*100
        node:setPercent(percent)
        node:setColor(percent<26 and cc.c3b(255, 0, 0) or cc.c3b(255, 187, 0))
    end
    setPowerText()

    self:addEventListener(Event.UPDATA_POWER,function() 
        setPowerText()
        local power = SharedManager:readData(Config.POWER)
        local limitpower = SharedManager:readData(Config.LIMITPOWER)
        if power>=limitpower then
            self:stopAllActions()
            self.panel:getChildByName("Text_2"):setVisible(false)
        end
    end)
    self:addEventListener(Event.UPDATA_POWERLIMIT,function() 
        setPowerText()
    end)
    self:powerTime()
end

--计算倒计时和体力
function PowerBar:powerTime()
    self:stopAllActions()
    local saveTime  = SharedManager:readData(Config.POWERTIME)
    if saveTime == 0 then--如果没记录时间
        saveTime =  math.floor(socket.gettime())--保存一下时间
        SharedManager:saveData(Config.POWERTIME, saveTime, false)
    end
    
    local curPower = SharedManager:readData(Config.POWER)
    local limitPower = SharedManager:readData(Config.LIMITPOWER)
    
    if curPower < limitPower then--体力没大上限
        local curTime = math.floor(socket.gettime())
        local diayTime = os.difftime(curTime, saveTime)
        local power = math.floor(diayTime/(Config.POWER_CD_TIME * 60)) * 2
        if power > 0 then--登陆恢复的体力数
            power = power+SharedManager:readData(Config.POWER)
            if power >= limitPower then
            	power = limitPower
                self.panel:getChildByName("Text_2"):setVisible(false)
            end
            SharedManager:saveData(Config.POWER,power,false)
            SharedManager:saveData(Config.POWERTIME,curTime,false)
            self.panel:getChildByName("Text_1"):setString(power .."/" ..  limitPower)
            self:dipatchGlobalEvent(Event.UPDATA_POWER)
            --没全部恢复体力
            self:scheduleTimeHandler(power, limitPower)
        else--倒计时恢复体力
            self:scheduleTimeHandler(power, limitPower)
        end
    else--体力达上限保存一下
        saveTime =  math.floor(socket.gettime())
        SharedManager:saveData(Config.POWERTIME, saveTime, false)
    end
end

--倒计时
function PowerBar:scheduleTimeHandler(curPower, limitPower, time)
    
    if curPower >= limitPower then
        self:stopAllActions()
    	return
    end
    local saveTime =  SharedManager:readData(Config.POWERTIME)
    self:schedule(function()
        local diayTime = os.difftime(math.floor(socket.gettime()), saveTime)
        if diayTime >= Config.POWER_CD_TIME*60 then 
            local limitPower = SharedManager:readData(Config.LIMITPOWER)
            local power = 2 + SharedManager:readData(Config.POWER)
            if power >= limitPower then
                power = limitPower
                self.panel:getChildByName("Text_2"):setVisible(false)
            end
            SharedManager:saveData(Config.POWER,power,false)
            SharedManager:saveData(Config.POWERTIME,math.floor(socket.gettime()),false)
            self.panel:getChildByName("Text_1"):setString(power .."/" ..  limitPower)
            self:dipatchGlobalEvent(Event.UPDATA_POWER)
            saveTime = math.floor(socket.gettime())
        end
        local time = Config.POWER_CD_TIME * 60 - os.difftime(math.floor(socket.gettime()), saveTime)
        self.panel:getChildByName("Text_2"):setString(getTimeString(time))
    end, 1)
    
    self.panel:getChildByName("Text_2"):setVisible(true)
end


return PowerBar
