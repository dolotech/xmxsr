-- 体力购买

local PowerDialog = class("PowerDialog",function()
    return display.createUI("PowerDialog.csb")
end)

function PowerDialog:onEnter()
    self:getChildByName("Text_5"):setVisible(false)
    self:getChildByName("Button_1"):setTitleText(Language.Buy_Fatigue)
    self:getChildByName("Button_2"):setTitleText(Language.Game_Limit .. "+" .. Config.BUY_LIMIT_POWER_ADD)
    self:getChildByName("closeButton"):onClick(function(parameters)Audio.playSound(Sound.SOUND_UI_READY_BACK,false)self:close()end, true, false)
    local txt = SharedManager:readData(Config.POWER) .. "/" ..  SharedManager:readData(Config.LIMITPOWER)
    self:getChildByName("Text_2"):setString(txt)
    
    local shopdata = DPayCenter.getShopDataById(Config.PLAY_ID5)
    if shopdata.payType == 1 then
        self:getChildByName("Text_3"):setString(tostring(shopdata.pay .. " " .. shopdata.price))
    else
        self:getChildByName("Text_3"):setString(tostring(shopdata.price .. " " .. shopdata.pay))
    end
    
    self:getChildByName("Text_4"):setString(Config.BUY_LIMIT_POWER_DIAMOND)
    self:getChildByName("bar"):setPercent(SharedManager:readData(Config.POWER) / SharedManager:readData(Config.LIMITPOWER) * 100)
    
    Color.setLableShadows({
        self:getChildByName("Text_1"),
        self:getChildByName("Text_2"),
        self:getChildByName("Text_3"),
        self:getChildByName("Text_4"),
        self:getChildByName("Text_5"),
        self:getChildByName("Text_9"),
    })
    
    self:getChildByName("Button_1"):onClick(function(parameters)
        DPayCenter.pay(Config.PLAY_ID5)
        TalkingData.onPageStart("购买体力")
    end)
    
     -- 购买体力上限
    self:getChildByName("Button_2"):onClick(function(parameters)
        TalkingData.onPageStart("购买体力上限")
        local limit = SharedManager:readData(Config.LIMITPOWER)
        if limit < Config.Maximum_physical_limit then
            if SharedManager:readData(Config.DIAMOND) >= Config.BUY_LIMIT_POWER_DIAMOND then
                local limitPower = limit+Config.BUY_LIMIT_POWER_ADD
                if limitPower > Config.Maximum_physical_limit then
                    limitPower = Config.Maximum_physical_limit
                end
                 SharedManager:saveData(Config.LIMITPOWER, limitPower, false)
                 self:dipatchGlobalEvent(Event.UPDATA_POWER)
    
                local diamond = SharedManager:readData(Config.DIAMOND)-Config.BUY_LIMIT_POWER_DIAMOND
                TalkingData.onPurchase("购买体力上限",1,Config.BUY_LIMIT_POWER_DIAMOND,diamond)
                SharedManager:saveData(Config.DIAMOND,diamond,true)
                self:dipatchGlobalEvent(Event.UPDATA_DIAMOND)

                TipsManager:ShowText(Language.Buy_MaxPowerLimit .. SharedManager:readData(Config.LIMITPOWER), nil, 36)
            else
                DialogManager:open(Dialog.Diamond)
             end
        else
            TipsManager:ShowText(Language.MaxPowerLimit, nil, 36)
        end
     end)
    
    self:addEventListener(Event.UPDATA_POWER,function()
        local power = SharedManager:readData(Config.POWER)
        local limitPower = SharedManager:readData(Config.LIMITPOWER)
        self:getChildByName("Text_2"):setString(power .. "/" .. limitPower)
        self:getChildByName("bar"):setPercent(power / limitPower * 100)
        self:scheduleTimeHandler()
    end)
    self:scheduleTimeHandler()
end

--设置按钮状态
function PowerDialog:setEnabledButton()
    local curPower = SharedManager:readData(Config.POWER)
    local limitPower = SharedManager:readData(Config.LIMITPOWER)
    if curPower >= limitPower then
        self:getChildByName("Button_1"):setEnabled(false)
        self:getChildByName("Button_1"):setTitleText(Language.Power_Mian)
        self:getChildByName("Button_1"):setColor(cc.c4b(255, 255, 255, 255))
        self:getChildByName("Text_5"):setVisible(false)
        self:stopAllActions()
        return true
    else
        self:getChildByName("Button_1"):setEnabled(true)
        self:getChildByName("Text_5"):setVisible(true)
        self:getChildByName("Button_1"):setTitleText(Language.Buy_Fatigue)
        self:getChildByName("Button_1"):setColor(cc.c4b(178, 255, 63 ,255))
        return false
    end
    return false
end

--倒计时
function PowerDialog:scheduleTimeHandler()
    if self:setEnabledButton() == false then
        local saveTime =  SharedManager:readData(Config.POWERTIME)
        self:schedule(function()
            local diayTime = os.difftime(math.floor(socket.gettime()), saveTime)
            if diayTime >= Config.POWER_CD_TIME * 60 then 
                local curPower = SharedManager:readData(Config.POWER)
                local limitPower = SharedManager:readData(Config.LIMITPOWER)
                local power = 1 + curPower
                if power >= limitPower then
                    power = limitPower
                    self:getChildByName("Text_5"):setVisible(false)
                end
                saveTime =math.floor(socket.gettime())
            end
            local time = Config.POWER_CD_TIME * 60 - os.difftime(math.floor(socket.gettime()), saveTime)
            self:getChildByName("Text_5"):setString(getTimeString(time))
        end, 1)
        self:getChildByName("Text_5"):setVisible(true)
    else
        self:stopAllActions()
        self:getChildByName("Text_5"):setVisible(false)
    end
end

return PowerDialog
