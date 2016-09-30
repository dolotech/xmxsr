-- 星星兑换
--lfr 2015年3月24日 14:06:09
local starExDialog = class("StarExDialog",function()
    return cc.CSLoader:createNode("StarExDialog.csb")
end)

require("game.view.dataCenter.UserAccountDataCenter")

--进入
function starExDialog:onEnter()
    self:getChildByName("closeButton"):onClick(function()self:close()end)
    self:getChildByName("Button_ok"):setTitleText(Language.Determine_Exchange)
    self:getChildByName("Button_ok"):onClick(function()self:starHandler()end, true, true, Sound.SOUND_RECEIVE)
    self:getChildByName("Text_1"):setString(Language.Stars_Exchange)
    self.starData = require("game.data.StarData")
    local data = SharedManager:readData(Config.Star)
    self._HaveStarNum = data.count
-- self._HaveStarNum = 50
    
    local len = table.nums(self.starData)
    for key, var in pairs(self.starData) do
        if data.starID < len then
            local arr = self.starData[tostring(data.starID + 1)]
            local goods = GoodsData[tostring(arr.goodsID)]
            local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(Prefix.PREBATTLE_PICTURE .. goods.picture .. PNG)
            self:getChildByName("Sprite_1"):setSpriteFrame(frame)
            self:getChildByName("Text_goods"):setString("x ".. arr.goodsNum)
            self:getChildByName("Text_goodsNum"):setString(self._HaveStarNum .." / ".. arr.starNum)
        end
    end
    
    if data.starID == len then
        self:getChildByName("Text_goods"):setString("x ".. self.starData[tostring(len)].goodsNum)
        self:getChildByName("Text_goodsNum"):setString(self._HaveStarNum .." / ".. self.starData[tostring(len)].starNum)
        self:getChildByName("Button_ok"):setEnabled(false)
        self:getChildByName("Button_ok"):setColor(cc.c4b(117, 117, 117, 255))
    elseif data.starID >= len or self.starData[tostring(data.starID + 1)].starNum > self._HaveStarNum then
        SharedManager:saveData(Config.Star, data)
--        self:dipatchGlobalEvent(Event.UPDATA_STARCOUNT)
        self:getChildByName("Button_ok"):setEnabled(false)
        self:getChildByName("Button_ok"):setColor(cc.c4b(117, 117, 117, 255))
    else
        self:getChildByName("Button_ok"):setEnabled(true)
        self:getChildByName("Button_ok"):setColor(cc.c4b(255, 255, 255, 255))
    end
end

--兑换处理
function starExDialog:starHandler()
    self:aniGetItem()
    local data = SharedManager:readData(Config.Star)
    data.starID = data.starID + 1
    SharedManager:saveData(Config.Star, data, true)
--    self:dipatchGlobalEvent(Event.UPDATA_STARCOUNT)
    self:saveData(data)
    --数据同步到server
    UserAccountDataCenter.saveAllUserDataToServer()
end

--保存
function starExDialog:saveData(data)
    for key, var in pairs(self.starData) do
        if key == tostring(data.starID) then
            local goods = GoodsData[tostring(var.goodsID)]
            local picturePath = Prefix.PREBATTLE_PICTURE .. goods.picture .. PNG

            local  num = self.starData[tostring(data.starID)].goodsNum
            if tostring(var.goodsID) == tostring(Config.DIANMOND_ID1) then--钻石
                local diamond = SharedManager:readData(Config.DIAMOND) + num
                TalkingData.onReward(num,diamond,"星星兑换获得")
                SharedManager:saveData(Config.DIAMOND, num, true)
            elseif tostring(var.goodsID) == tostring(Config.KEY_ID) then--钥匙
                SharedManager:saveData(Config.KEY, SharedManager:readData(Config.KEY) + num, true)
            elseif tostring(var.goodsID) == tostring(Config.YELLOW_ID1) then--黄色材料
                SharedManager:saveData(Config.YELLOW, SharedManager:readData(Config.YELLOW) + num, true)
            elseif tostring(var.goodsID) == tostring(Config.BULE_ID1) then--蓝色材料
                SharedManager:saveData(Config.BLUE, SharedManager:readData(Config.BLUE) + num, true)
            elseif var.goodsID == Config.TOOL_RAINBOW_BALL or var.goodsID == Config.TOOL_MAGIC_BALL or var.goodsID == Config.TOOL_BRUSH or var.goodsID == Config.TOOL_BOMB then
                local items = SharedManager:readData(Config.Storage)
                items[tostring(var.goodsID)] = items[tostring(var.goodsID)] + num
                SharedManager:saveData(Config.Storage, items)
            end
    
            self:updateData({num = num, dropID = self.starData[tostring(data.starID)].goodsID, star = data.starID})
       end 
    end
end

--更新
function starExDialog:updateData(data)
    local len = table.nums(self.starData)
    for key, var in pairs(self.starData) do
        local sel = self.starData[tostring(data.star + 1)]
        
        if data.star >= len or sel.starNum > self._HaveStarNum then
            self:getChildByName("Button_ok"):setEnabled(false)
            self:getChildByName("Button_ok"):setColor(cc.c4b(117, 117, 117, 255))
            self:onEnter()
            self:performWithDelay(function()TipsManager:ShowText(Language.Star_Exchange_Get, nil, 26)end, 0.8)
        else
            local goods = GoodsData[tostring(sel.goodsID)]
            local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(Prefix.PREBATTLE_PICTURE .. goods.picture .. PNG)
            self:getChildByName("Sprite_1"):setSpriteFrame(frame)
            self:getChildByName("Text_goods"):setString("x "..sel.goodsNum)
            self:getChildByName("Text_goodsNum"):setString(self._HaveStarNum .. " / " .. sel.starNum)
            self:getChildByName("Button_ok"):setEnabled(true)
            self:getChildByName("Button_ok"):setColor(cc.c4b(255, 255, 255, 255))
        end
    end
    
    local text = ""
    if data.dropID == Config.DIANMOND_ID1 then--钻石
        self:dipatchGlobalEvent(Event.UPDATA_DIAMOND)
        text = Language.Congratulations_You_Get .. data.num .. " ".. Language.Game_Num_Diamond
    elseif data.dropID == Config.KEY_ID then--钥匙  
        self:dipatchGlobalEvent(Event.UPDATA_KEY)
        text = Language.Congratulations_You_Get .. data.num .. " ".. Language.Game_TheKey
    elseif data.dropID == Config.YELLOW_ID1 then--黄色材料
        self:dipatchGlobalEvent(Event.UPDATA_YELLOW)
        text = Language.Congratulations_You_Get .. data.num .. " ".. Language.Game_Yellow_Rune
    elseif data.dropID == Config.BULE_ID1 then--蓝色材料 
        self:dipatchGlobalEvent(Event.UPDATA_BLUE)
        text = Language.Congratulations_You_Get .. data.num .. " ".. Language.Game_Blue_Rune
    elseif data.dropID == Config.TOOL_RAINBOW_BALL or data.dropID == Config.TOOL_MAGIC_BALL or data.dropID == Config.TOOL_BRUSH or data.dropID == Config.TOOL_BOMB then
        text = Language.Congratulations_You_Get .. data.num .. " ".. Language[string.format("ToolItem%d", data.dropID)]
    end
    TipsManager:ShowText(text, nil, 26)
end

--播放获得道具动画
function starExDialog:aniGetItem()
    local imgBg = self:getChildByName("Image_2")
    -- imgBg:setScale(1)
    -- imgBg:setOpacity(255)
    -- imgBg:setRotation(0)

    local seq = cc.Sequence:create(
        cc.Spawn:create(cc.ScaleBy:create(0.2,1.5),cc.RotateTo:create(1,180)),
        cc.Spawn:create(cc.ScaleBy:create(1,1),cc.RotateTo:create(1,360),cc.FadeOut:create(0.5))
    )
    imgBg:stopAllActions()
    imgBg:runAction(seq)

    local btn = self:getChildByName("Button_ok")
    btn:setTouchEnabled(false)
    local label = self:getChildByName("Text_goods")
    label:setVisible(false)
    local sprItem = self:getChildByName("Sprite_1")
    sprItem:setVisible(false)
    local spr = sprItem:clone()
    self:addChild(spr)

    local seq = cc.Sequence:create(
        cc.ScaleBy:create(0.2,1.5),
        cc.ScaleBy:create(0.8,0.8),
        cc.DelayTime:create(0.5),
        cc.MoveBy:create(0.2,cc.p(0,-20)),
        cc.Spawn:create(cc.MoveBy:create(0.8,cc.p(0,800)),cc.FadeOut:create(0.5)),
        cc.CallFunc:create(function() 
            spr:removeFromParent()
            sprItem:setVisible(true)

            local scale = sprItem:getScale()
            imgBg:setScale(1)
            imgBg:setRotation(0)
            imgBg:setOpacity(0)
            imgBg:runAction(cc.FadeIn:create(0.3))
            sprItem:setScale(0)
            local seq = cc.Sequence:create(
                cc.ScaleTo:create(0.3,scale+0.5),
                cc.ScaleTo:create(0.3,scale),
                cc.CallFunc:create(function() 
                    label:setVisible(true)
                    if(btn:isEnabled())then btn:setTouchEnabled(true) end
                end)
            )
            sprItem:runAction(seq)
        end)
    )
    spr:runAction(seq)
end

return starExDialog

