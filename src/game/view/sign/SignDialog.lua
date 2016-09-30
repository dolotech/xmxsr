-- 签到
--Samuel
local SignDialog = class("SignDialog",function()
    return cc.CSLoader:createNode("SignDialog.csb")
end)

--进入
function SignDialog:onEnter()
    self:getChildByName("closeButton"):onClick(function()self:close()end)
    self:getChildByName("Button_1"):onClick(function()self:signHandler()end)
    self:getChildByName("Button_2"):onClick(function()self:signHandlers()end)
    self:getChildByName("Text_dayTie"):setString(Language.Success_Received) --一键领取成功可以获得所有物品
    self.SignData = require("game.data.SignData")
    Color.setLableShadow(self:getChildByName("Text_day"))
    local data = SharedManager:readData(Config.Sign)
    
    self:getChildByName("Image_Item_9"):setVisible(false) --隐藏价格
    self:getChildByName("Text_8"):setVisible(false)
    if data.day == 0 then
        self:getChildByName("Text_day"):setString(Language.Game_do_Sign)
    else
        self:getChildByName("Text_day"):setString(Language.Game_Checked_Sign .. data.day .. Language.Game_Day)
    end

    local from = os.time()
    local to = os.time(data.date)
    local bool = false  --判断是否禁用按钮
    if (from - to) >= 0 then
        self:getChildByName("Button_1"):setEnabled(true)
        self:getChildByName("Button_1"):setColor(cc.c4b(255,255,255,255))
        self:getChildByName("Button_1"):setTitleText(Language.Game_Sign)
        bool = false
    else
        self:getChildByName("Button_1"):setEnabled(false)
        self:getChildByName("Button_1"):setColor(cc.c4b(117,117,117,255))
        self:getChildByName("Button_1"):setOpacity(64)
        self:getChildByName("Button_1"):setTitleText(Language.Game_Checked_Sign)
        bool = true
    end

    if data.day >= 7 then
        if bool then --如果7天时间过了重置
            data.day = 0
            SharedManager:saveData(Config.Sign,data)
        end
    end

    for key, var in pairs(self.SignData) do
        if var.day <= data.day then
            self:getChildByName("Image_g"..var.day):setVisible(true)
        else
            self:getChildByName("Image_g"..var.day):setVisible(false)
        end

        local goods = GoodsData[tostring(var.type)]
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(Prefix.PREBATTLE_PICTURE .. goods.picture .. PNG)
        self:getChildByName("Sprite_"..var.day):setSpriteFrame(frame)
        self:getChildByName("Text_"..var.day):setString(tostring(var.num))
        Color.setLableShadow(self:getChildByName("Text_"..var.day))
    end

    self:addEventListener(Event.UPDATA_Akey_RECEIVE, handler(self, self.updateAKeyReceive))
end

--签到处理
function SignDialog:signHandler()
    local cday = SharedManager:readData(Config.Sign).day
    local day = cday + 1
    local from = os.time()
    local curTab = os.date("*t")
    local toDate = os.date("*t")
    toDate.year = curTab.year
    toDate.month = curTab.month
    toDate.day = curTab.day
    toDate.hour = 24
    toDate.min = 0
    toDate.sec = 0
    local to = os.time(toDate) 
    local date = os.date("*t",to)
    local time = from - to
    --保存更新信息
    SharedManager:saveData(Config.Sign, {day = day, date = date, time = time}, true)
    self:getChildByName("Text_day"):setString(Language.Game_Checked_Sign .. day .. Language.Game_Day)
    self:getChildByName("Button_1"):setTitleText(Language.Game_Checked_Sign)
    self:getChildByName("Button_1"):setEnabled(false)
    self:getChildByName("Button_1"):setColor(cc.c4b(117, 117, 117, 255))
    self:getChildByName("Button_1"):setOpacity(64)
    self:saveData(day, true)
    self:dispatchEvent(Event.UPDATA_SGIN_UI)
end

-- 点击 一键签到  请求购买
function SignDialog:signHandlers()
    DPayCenter.pay(302)
end

-- 一键签到 成功后
function SignDialog:updateAKeyReceive()
    for _day = 1, 7 do
        self:saveData(_day, false)
    end
end

--保存更新信息
function SignDialog:saveData(day, bol)
    for key, var in pairs(self.SignData) do
        if var.day == day then
            local goods = GoodsData[tostring(var.type)]
            local picturePath = Prefix.PREBATTLE_PICTURE .. goods.picture .. PNG

            if tostring(var.type) == tostring(Config.DIANMOND_ID1) then--钻石
                local diamond = SharedManager:readData(Config.DIAMOND) + var.num
                TalkingData.onReward(var.num,diamond,"签到获得")
                SharedManager:saveData(Config.DIAMOND, diamond, true)
            elseif tostring(var.type) == tostring(Config.KEY_ID) then--钥匙
                SharedManager:saveData(Config.KEY, SharedManager:readData(Config.KEY) + var.num, true)
            elseif tostring(var.type) == tostring(Config.YELLOW_ID1) then--黄色材料
                SharedManager:saveData(Config.YELLOW, SharedManager:readData(Config.YELLOW) + var.num, true)
            elseif tostring(var.type) == tostring(Config.BULE_ID1) then--蓝色材料
                SharedManager:saveData(Config.BLUE, SharedManager:readData(Config.BLUE) + var.num, true)
            end

            local image =  self:getChildByName("Image_g" .. day)
            local  function callBack()
                if bol == true then
                    self:updateData({num = var.num, dropID = var.type, bool = bol, gou_Image = image, _day = var.day})
                else
                    self:performWithDelay(function() self:updateData({num = var.num, dropID = var.type, bool = bol, gou_Image = image, _day = var.day}) end, 0.3 * (day - 1))
                end
            end

            image:setVisible(true)
            image:setScale(0.05, 0.05)
            local qequence = cc.Sequence:create(
                cc.EaseBackOut:create(cc.ScaleTo:create(0.3, 1.5, 1.5)),
                cc.EaseBackOut:create(cc.ScaleTo:create(0.15, 1, 1)),
                cc.CallFunc:create(callBack)
            )
            image:runAction(qequence)
            break
        end
    end
end


function SignDialog:updateData(data)
    local text = ""
    if data.dropID == Config.DIANMOND_ID1 then--钻石
        self:dipatchGlobalEvent(Event.UPDATA_DIAMOND)
        text = Language.Congratulations_You_Get .. data.num .. Language.Game_Num_Diamond
    elseif data.dropID == Config.KEY_ID then--钥匙  
        self:dipatchGlobalEvent(Event.UPDATA_KEY)
        text = Language.Congratulations_You_Get .. data.num .. Language.Game_TheKey
    elseif data.dropID == Config.YELLOW_ID1 then--黄色材料
        self:dipatchGlobalEvent(Event.UPDATA_YELLOW)
        text = Language.Congratulations_You_Get .. data.num .. Language.Game_Yellow_Rune
    elseif data.dropID == Config.BULE_ID1 then--蓝色材料 
        self:dipatchGlobalEvent(Event.UPDATA_BLUE)
        text = Language.Congratulations_You_Get .. data.num .. Language.Game_Blue_Rune
    end

    TipsManager:ShowText(text, nil, 26)
    data.gou_Image:setVisible(data.bool)
    local cday = SharedManager:readData(Config.Sign).day
    if data._day == cday then
        self:performWithDelay(function()data.gou_Image:setVisible(true)end, 2.2)
    end

end

return SignDialog
