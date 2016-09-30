--author:chenkaixi
--开启宝箱掉落奖励场景

local DropDataCtrl = require("game.view.key.DropDataCtrl")

local KeyScene = class("KeyScene", function()
    return require("game.view.base.BaseScene"):create()
end)

function KeyScene:create()
    local scene = KeyScene.new()
    scene:setNodeEventEnabled()
    return scene
end

function KeyScene:onCleanup()
    -- unschedulerUpdate(self)
end
--进入
function KeyScene:onEnter()
    self.FlyToModel  = require("game.view.comm.FlyToModel"):create()
    
    local bg = cc.Sprite:create(Picture.RES_KEYBG_PNG)
    bg:stageCenter()
    self:addToGameLayer(bg)
    self:initButtonHandler()
    
    self.enbled = false
    self.page = 1
    self.timeTable = {}
    self:createBoxPage(self.page)
    self:createBoxPage(self.page + 1)
    
    self:addEventListener(Event.UPDATA_Akey_OPEN, handler(self, self.updateAKeyOpen))

    self.eventHandle = require("game.event.EventHandle").new(self)
    self.eventHandle:itEventData("reward")
    -- schedulerUpdate(self, handler(self, self.update))
    self:schedule(self.update, 0.1)
end

function KeyScene:update( _delta )
    self.eventHandle:runEvent(_delta)
end

--事件获得控件回调
function KeyScene:GetChildByScene( _tStrs )
    local originalName = table.remove(_tStrs,1)
    local name = originalName..".csb"
    local node = nil
    if(name == Csbs.NODE_MATERIAL_CSB)then
        node = self.meteril:getChildByNameFo(_tStrs)
    elseif(name==Csbs.NODE_DIAMOND_CSB)then
        node = self.rigthTopBtn:getChildByNameFo(_tStrs)
    elseif(name==Csbs.NODE_RETURN_CSB)then
        node = self.returnBtn:getChildByNameFo(_tStrs)
    elseif(name==Csbs.NODE_KEYADD_CSB)then
        node = self.keyBtn:getChildByNameFo(_tStrs)
    else
        -- node = self.ui:getChildByNameFo(_tStrs)
    end
    -- print("-------KeyScene.GetChildByScene]",originalName,node)
    return node
end

--按钮事件操作
function KeyScene:initButtonHandler()
    --体力
    local leftTopBtn = require("game.view.comm.PowerBar"):create()
    leftTopBtn:stageLeftTop()
    self:addToUILayer(leftTopBtn)

    --升级材料
    local meteril = display.createUI(Csbs.NODE_MATERIAL_CSB)
    meteril:stageTop()
    self:addToUILayer(meteril)
    meteril:getChildByName("Text_1"):setString(tostring(SharedManager:readData(Config.YELLOW)))
    meteril:getChildByName("Text_2"):setString(tostring(SharedManager:readData(Config.BLUE)))
    self.meteril = meteril

    local rigthTopBtn = display.createUI(Csbs.NODE_DIAMOND_CSB)
    rigthTopBtn:stageRightTop()
    self:addToUILayer(rigthTopBtn)
    self.rigthTopBtn=rigthTopBtn
    --钻石
    rigthTopBtn = rigthTopBtn:getChildByName("Panel_5")
    rigthTopBtn:getChildByName("Text_1"):setString(tostring(SharedManager:readData(Config.DIAMOND)))
    Color.setLableShadow(rigthTopBtn:getChildByName("Text_1"))
    rigthTopBtn:getChildByName("Button_1"):onClick(function() DialogManager:open(Dialog.Diamond)end, true)
--    rigthTopBtn:getChildByName("Button_2"):onClick(function() DialogManager:open(Dialog.Diamond)end, true)

    --返回
    local returnBtn = display.createUI(Csbs.NODE_RETURN_CSB)
    returnBtn:stageRightBottom(-70, 70)
    returnBtn:getChildByName("Button_1"):onClick(function()SceneManager.changeScene(Scene.City)end, true, true, Sound.SOUND_UI_LOTTERY_BACK)
    self:addToDialogLayer(returnBtn)
    self.returnBtn=returnBtn
    
    local buyDianond = DropDataCtrl:getBuyDianomd(SharedManager:readData(Config.POINT))
    
    local function addKeyHandler()
        local diamond = SharedManager:readData(Config.DIAMOND)
        if diamond < buyDianond then
            DialogManager:open(Dialog.Diamond)
            TalkingData.onPageStart("购买钥匙")
        	return
        end
        local key = SharedManager:readData(Config.KEY)
        key = key + Config.BUY_KEY_NUM
        diamond = diamond-buyDianond
        TalkingData.onReward(buyDianond, diamond, "购买钥匙")
        SharedManager:saveData(Config.KEY, key, false)
        SharedManager:saveData(Config.DIAMOND, diamond, true)
        self:dipatchGlobalEvent(Event.UPDATA_DIAMOND)
        self:dipatchGlobalEvent(Event.UPDATA_KEY)
        self.keyBtn:stopAllActions()
        self.keyBtn:setScale(1)
        
        self.keyBtn:getChildByName("Image_4"):setVisible(false)
        self.keyBtn:getChildByName("Image_5"):setVisible(true)
        self.keyBtn:getChildByName("Image_5"):runAction(cc.Sequence:create(cc.ScaleTo:create(0.15, 0.6), cc.ScaleTo:create(0.15, 1.2), cc.CallFunc:create(function()
            Audio.playSound(Sound.SOUND_KEY, false)--购买钥匙
            self.keyBtn:getChildByName("Image_4"):setVisible(true)
        end)))
    end
    
    --添加钥匙
    local keyBtn = display.createUI(Csbs.NODE_KEYADD_CSB)
    keyBtn:stageCenter(0, 400)
    keyBtn:getChildByName("Button_1"):onClick(addKeyHandler, false, false)
    keyBtn:getChildByName("Button_1"):setTitleText("  +" .. Config.BUY_KEY_NUM)
    local point = SharedManager:readData(Config.POINT)
    if point <= Config.OPEN_KEY_POINT then
        TipsManager:ShowText(Language.Open_Chestoff, nil, 28) --一键开启宝箱,6关通过开启
        keyBtn:getChildByName("Button_2"):setEnabled(false)
        keyBtn:getChildByName("Button_2"):setColor(cc.c4b(117, 117, 117, 255))
    else
        keyBtn:getChildByName("Button_2"):setEnabled(true)
        keyBtn:getChildByName("Button_2"):setColor(cc.c4b(255, 255, 255, 255))
        tween.RepeatScale(keyBtn:getChildByName("Button_2"), 0.5, 1, 1.15)
    end
    
    keyBtn:getChildByName("Button_2"):onClick(function()
        self:signHandlers()
        TalkingData.onPageStart("一键开启")
    end)
    
    self:addToDialogLayer(keyBtn)
    keyBtn:getChildByName("Text_2"):setString("0")
    keyBtn:getChildByName("Text_1"):setString(tostring(buyDianond))
    self.keyBtn = keyBtn
    
    self.scale =  keyBtn:getChildByName("Button_1"):getScale()
    local function setkeyVisible()
        local keyNum = SharedManager:readData(Config.KEY)
        if keyNum > 0 then
            keyBtn:getChildByName("Text_2"):setVisible(true)
            keyBtn:getChildByName("Image_5"):setVisible(true)
            keyBtn:getChildByName("Text_2"):setString(tostring(keyNum))
            
            keyBtn:getChildByName("Button_1"):setVisible(false)
            keyBtn:getChildByName("Image_1"):setVisible(false)
            keyBtn:getChildByName("Image_2"):setVisible(false)
            keyBtn:getChildByName("Text_1"):setVisible(false)
            returnBtn:setVisible(false)
        else
            keyBtn:getChildByName("Text_2"):setVisible(false)
            keyBtn:getChildByName("Image_5"):setVisible(false)
            keyBtn:getChildByName("Text_2"):setString(tostring(0))
            
            keyBtn:setVisible(SharedManager:readData(Config.POINT) > Config.OPEN_KEY_POINT)--第六关可以买钻石买钥匙
            keyBtn:getChildByName("Button_1"):setVisible(true)
            keyBtn:getChildByName("Image_1"):setVisible(true)
            keyBtn:getChildByName("Image_2"):setVisible(true)
            keyBtn:getChildByName("Text_1"):setVisible(true)
            returnBtn:setVisible(true)
            
            local scaleTo1 = cc.ScaleTo:create(0.5, self.scale * 0.8, self.scale * 0.8)
            local scaleTo2 = cc.ScaleTo:create(0.5, self.scale * 1, self.scale * 1)
            local seq = cc.Sequence:create(scaleTo1, scaleTo2)
            seq = cc.RepeatForever:create(seq)
            keyBtn:getChildByName("Button_1"):runAction(seq)
           -- tween.RepeatScale(returnBtn, 0.5, 1, 1.15) --返回主城按钮缓动
        end
    end
    setkeyVisible()
    
    keyBtn:getChildByName("Image_6"):setVisible(false) --隐藏价格
    keyBtn:getChildByName("Text_3"):setVisible(false)
    
    self:addEventListener(Event.UPDATA_KEY, function() 
        keyBtn:getChildByName("Text_2"):setString(tostring(SharedManager:readData(Config.KEY)))
        setkeyVisible()
    end)
    
    self:addEventListener(Event.UPDATA_DIAMOND,function() 
        rigthTopBtn:getChildByName("Text_1"):setString(tostring(SharedManager:readData(Config.DIAMOND)))
    end)
    
    self:addEventListener(Event.UPDATA_YELLOW,function() 
        meteril:getChildByName("Text_1"):setString(tostring(SharedManager:readData(Config.YELLOW)))
    end)
    
    self:addEventListener(Event.UPDATA_BLUE,function() 
        meteril:getChildByName("Text_2"):setString(tostring(SharedManager:readData(Config.BLUE)))
    end)
    
    Color.setLableShadows({
        meteril:getChildByName("Text_1"),
        meteril:getChildByName("Text_2"),
        keyBtn:getChildByName("Text_1"),
        keyBtn:getChildByName("Text_2")
    })
end

-- 请求购买一键开启 全部箱子
function KeyScene:signHandlers()
    DPayCenter.pay(303)
    -- self:updateAKeyOpen()
end

-- 返回请求购买箱子结果
function KeyScene:updateAKeyOpen()
    local layer = self["layer" .. self.page]
    -- for var = 1, 9 do
    --     local box = layer.boxLayer:getChildByTag(var):getChildByName("Button_1")
    --     if box:isVisible() == true then
    --         self:openBox(layer.boxLayer:getChildByTag(var))
    --     end
    -- end
    
    local index = 1
    while index <= 9 do
        local box = layer.boxLayer:getChildByTag(index)
        if(box:getChildByName("Button_1"):isVisible())then 
            self:openBox(box, layer.boxLayer, index)
            break
        else
            index = index + 1
        end
    end
end

--初始化按钮操作
function KeyScene:touchEndedHandler(box)
    if self.enbled then return end

    if box.seta == nil then
        local x,y = box:getChildByName("Button_1"):getPosition()
        local size = box:getChildByName("Button_1"):getContentSize()
        box:getChildByName("Button_1"):setAnchorPoint(0.37, 0.32)
        box:getChildByName("Button_1"):setPosition(x -size.width * (0.5 - 0.37),y -size.height * (0.5 - 0.32))
        box.seta = true
    end

    local keyNum = SharedManager:readData(Config.KEY)
    if keyNum > 0 then
        keyNum = keyNum - 1
        SharedManager:saveData(Config.KEY,keyNum,true)
        self:dipatchGlobalEvent(Event.UPDATA_KEY)
        box:getChildByName("Button_1"):setEnabled(false)
        local flystartPoint = cc.p(self.keyBtn:getPositionX() - 74, self.keyBtn:getPositionY() - 38)
        local flyendPoint = cc.p(box:getChildByName("Button_1"):getPositionX() - 30, box:getChildByName("Button_1"):getPositionY())
        self.FlyToModel:flyDropModel(Picture.RES_KEY_PNG, flystartPoint,flyendPoint, 1.1, 1.2, 1.2, nil, function()
            self:openBox(box)
        end, 0.5, 0.1, 0.2)
    else
        self.keyBtn:setScale(1)
        local scaleTo1 = cc.ScaleTo:create(0.12, 1.4, 1.4)
        local scaleTo2 = cc.ScaleTo:create(0.12, 1, 1)
        local seq = cc.Sequence:create(scaleTo1, scaleTo2)
        self.keyBtn:runAction(seq)
        Audio.playSound(Sound.SOUND_UI_LOTTERY_UNTOUGH, false)--无效点击
        --DialogManager:open(Dialog.Diamond)
    end
end

--打开箱子
function KeyScene:openBox(box, _boxLayer, _index)
    local function allOpen()
        if(_boxLayer == nil)then return end
        _index = _index + 1
        if(_index > 9)then return end
        local box = _boxLayer:getChildByTag(_index)
        if(not box:getChildByName("Button_1"):isVisible())then 
            allOpen()
        else
            self:openBox(box, _boxLayer, _index)
        end
    end

    local point = SharedManager:readData(Config.POINT)
    local dropData  = DropDataCtrl:getPointDropData(point - 1, self.timeTable)
    if self.timeTable[dropData.id] ~= nil then--读取已经抽次数
        self.timeTable[dropData.id].times = self.timeTable[dropData.id].times+1
    else
        self.timeTable[dropData.id] = {id = dropData.id,times = 1}   
    end
    local starPoint = cc.p(box:getChildByName("Button_1"):getPosition())
    -- dropData.rwardType = 2
    -- dropData.type = 1021
    if dropData.rwardType == 1 then--道具类型
        local endPoint = {x = 0, y = 0}
        local endScale, aniStyle = 1, 0
        if dropData.type==Config.YELLOW_ID1 or dropData.type==Config.YELLOW_ID2 or dropData.type==Config.YELLOW_ID3 then --黄色元素小中大
            local yellow = SharedManager:readData(Config.YELLOW)
            yellow = yellow+dropData.num
            SharedManager:saveData(Config.YELLOW,yellow,true)
            endPoint.x = stageWidth / 2 - 25
            endPoint.y = stageHeight - 25
            endScale = 0.5
            if(dropData.type == Config.YELLOW_ID3)then aniStyle = 1 end
        elseif dropData.type == Config.BULE_ID1 or dropData.type == Config.BULE_ID2 or dropData.type == Config.BULE_ID3 then --蓝色元素小中大
            local blue = SharedManager:readData(Config.BLUE)
            blue = blue+dropData.num
            SharedManager:saveData(Config.BLUE, blue, true)
            endPoint.x =  stageWidth / 2 - 25
            endPoint.y =  stageHeight - 55
            endScale = 0.5
            if(dropData.type==Config.BULE_ID3)then aniStyle = 1 end
        elseif dropData.type==Config.DIANMOND_ID2 or dropData.type==Config.DIANMOND_ID3 then --钻石 ，打包钻石
            local diamond = SharedManager:readData(Config.DIAMOND)
            diamond = diamond + dropData.num
            TalkingData.onReward(dropData.num, diamond, "开宝箱获得")
            SharedManager:saveData(Config.DIAMOND, diamond,true)
            endPoint.x = stageWidth - 196
            endPoint.y =  stageHeight - 47
            if(dropData.type==Config.DIANMOND_ID3)then aniStyle = 1 end
        elseif dropData.type==Config.POWER_ID then --体力
            local power = SharedManager:readData(Config.POWER)
            endScale = 0.75
            power = power + dropData.num
            SharedManager:saveData(Config.POWER,power,true)
            endPoint.x = 42
            endPoint.y =  stageHeight - 32
        elseif dropData.type==Config.POWER_LIMIT_ID then --体力上限
            local limitPower = SharedManager:readData(Config.LIMITPOWER)
            limitPower = limitPower+dropData.num
            SharedManager:saveData(Config.LIMITPOWER, limitPower, true)
            endPoint.x = 40
            endPoint.y = stageHeight - 35
            aniStyle = 1
        end
        
        Audio.playSound(Sound.SOUND_UI_LOTTERY_KEY)--宝箱抖动
        local function onComplete()
            self:playBoxEffect(box)
            local picturePath = Prefix.PREBATTLE_PICTURE..GoodsData[tostring(dropData.type)].picture ..PNG
            self.FlyToModel:flyDropModel(picturePath, starPoint, endPoint, 0.3, 1, endScale, dropData.num, function()
                self:updateData(dropData)
                if self.enbled==false then
                    self:chekPage()
                end
            end,35,1,1)
        end
        
        local function onComplete1()
            self:playBoxEffect(box)
            local function closeCallBack( _startPoint )
                local picPath = Prefix.PREBATTLE_PICTURE..GoodsData[tostring(dropData.type)].picture ..PNG
                self.FlyToModel:flyDropModel(picPath,_startPoint,endPoint,2,1,endScale,dropData.num,function()
                        self:updateData(dropData)
                    end, 35, 0.3, 0.5)
                self.enbled = false
                self:chekPage()
                allOpen()
            end
            Audio.playSound(Sound.SOUND_RECEIVE) --星星兑换 购买英雄音效
            DialogManager:open("game.view.key.DialogItemInfo",
                {isTween = false, goods = GoodsData[tostring(dropData.type)],
                starPoint = starPoint,
                num = dropData.num,
                funCloseCallBack = closeCallBack},0)
        end
        --宝箱抖动
        local n,list=0,{}
        n=n+1 list[n]=cc.RotateTo:create(0.07, 360 / 24)
        n=n+1 list[n]=cc.RotateTo:create(0.07, -360 / 24)
        n=n+1 list[n]=cc.RotateTo:create(0.05, 360 / 36)
        n=n+1 list[n]=cc.RotateTo:create(0.05, -360 / 36)
        n=n+1 list[n]=cc.RotateTo:create(0.05, 360 / 36)
        n=n+1 list[n]=cc.RotateTo:create(0.05, -360 / 50)
        n=n+1 list[n]=cc.RotateTo:create(0.05, 0)
        if(aniStyle == 0)then 
            n=n+1 list[n]=cc.CallFunc:create(onComplete) 
            allOpen()
        elseif(aniStyle==1)then 
            self.enbled = true
            n=n+1 list[n]=cc.CallFunc:create(onComplete1)
        end
        box:getChildByName("Button_1"):runAction(cc.Sequence:create(list))
    elseif dropData.rwardType == 2 then--宠物
        Audio.playSound(Sound.SOUND_RECEIVE) --星星兑换 购买英雄音效
        self:playBoxEffect(box)
        self.enbled = true
        RoleDataManager.addRole(dropData.type)
        local roledata = clone(RoleData[tostring(dropData.type)])
        roledata.startPoint = starPoint
        roledata.isTween = false
        roledata.funCloseCallBack = function()
            self.enbled = false
            self:chekPage()
            allOpen()
        end
        DialogManager:open("game.view.key.ShowPetDialog", roledata, 0)
    end
end

--播放箱子特效
function KeyScene:playBoxEffect(box)
    local boxEffect = display.createEffect("effect_014","effect_014")
    self:addToEffectLayer(boxEffect)
    boxEffect:setPosition(box:getChildByName("Button_1"):getPosition())
    box:getChildByName("Button_1"):setVisible(false)
    box:getChildByName("Button_2"):setVisible(true)
--    Audio.playSound(Sound.SOUND_UI_LOTTERY_OPEN, false)--开宝箱
end

--检测翻页
function KeyScene:chekPage()
    if self:detectionBox()then
        self.timeTable = {}
        local moveTo1 = cc.MoveTo:create(0.8,cc.p(stageWidth,0))
        local callBack = cc.CallFunc:create(handler(self,self.restPage))
        local seq1 = cc.Sequence:create(moveTo1,callBack)
        local moveTo2 = cc.MoveTo:create(0.8,cc.p(0,0))
        local seq2 = cc.Sequence:create(moveTo2,cc.CallFunc:create(function()
            self.enbled = false
        end))
        self.enbled = true
        if self.page == 1 then
            self["layer1"]:runAction(seq1)
            self["layer2"]:runAction(seq2)
        elseif self.page == 2 then
            self["layer2"]:runAction(seq1)
            self["layer1"]:runAction(seq2)
        end
        
    end
end

--重置页面
function KeyScene:restPage()
    Audio.playSound(Sound.SOUND_UI_HERO_SLIDE, false)--切换界面
    local layer = self["layer" .. tostring(self.page)]

    local count = 9
    for i=1, count, 1 do
        local box1 = layer.boxLayer:getChildByTag(i):getChildByName("Button_1")
        box1:setVisible(true)
        box1:setEnabled(true)
        local box2= layer.boxLayer:getChildByTag(i):getChildByName("Button_2")
        box2:setVisible(false)
    end
    layer:setPosition(-stageWidth+offSetX,0)

    if self.page==1 then
        self.page = 2
    elseif self.page==2 then
        self.page = 1
    end
end

--检测当前页的箱子是否都开了
function KeyScene:detectionBox()
    local layer = self["layer" .. self.page]
    local count,n = 9,0
    for i=1, count, 1 do
        local box = layer.boxLayer:getChildByTag(i):getChildByName("Button_1")
        if box:isVisible() == false then
            n = n+1
        end
    end
    
    if n >= 9 then
        return true
    end
    return false
end

--创建开宝箱页
function KeyScene:createBoxPage(page)
    local layer = cc.Layer:create()
    layer:setContentSize(stageWidth,stageHeight)
    self:addToGameLayer(layer)
    
    local kuang = display.createUI("node_key_rewardbg_base.csb")
    kuang:stageCenter(0,-140)
    layer:addChild(kuang)

    local boxLayer = cc.Layer:create()
    boxLayer:setContentSize(stageWidth,stageHeight)
    layer.boxLayer = boxLayer
    local count,index = 3,0
    for i=1, count, 1 do
        for j=1, count, 1 do
            index = index+1
            local box = display.createUI(Csbs.NODE_LOCKGRID_BTN)
            box:getChildByName("Button_1"):setPosition((j-1)*180+(265+offSetX),((i-1)*210)+300)
            box:getChildByName("Button_2"):setPosition((j-1)*180+(265+offSetX),((i-1)*210)+300)--适配宽
            box:getChildByName("Button_2"):setVisible(false)
            boxLayer:addChild(box)
            box:setTag(index)
            box:getChildByName("Button_1"):onClick(function()self:touchEndedHandler(box)end,false,false,nil)
        end  
    end  
    layer:addChild(boxLayer)
    
     layer:setAnchorPoint(0,0)
    if page==1 then
      layer:setPosition(0,0)
    elseif page==2 then
      layer:setPosition(-stageWidth+offSetX,0)
    end
    self["layer" ..page] = layer
end

--保存数据得到道具
function KeyScene:updateData(dropData)
    if dropData.type==Config.YELLOW_ID1 or dropData.type==Config.YELLOW_ID2 or dropData.type==Config.YELLOW_ID3 then --黄色元素小中大
--        Audio.playSound(Sound.SOUND_RUNE1)--获得符文1
        self:dipatchGlobalEvent(Event.UPDATA_YELLOW)
    elseif dropData.type==Config.BULE_ID1 or dropData.type==Config.BULE_ID2 or dropData.type==Config.BULE_ID3 then --蓝色元素小中大
--        Audio.playSound(Sound.SOUND_RUNE2)--获得符文2
        self:dipatchGlobalEvent(Event.UPDATA_BLUE)
    elseif dropData.type==Config.DIANMOND_ID2 or dropData.type==Config.DIANMOND_ID3 then --钻石 ，打包钻石
--        Audio.playSound(Sound.SOUND_DIOMOND)--获得钻石的音效
        self:dipatchGlobalEvent(Event.UPDATA_DIAMOND)
    elseif dropData.type==Config.POWER_ID then --体力
        self:dipatchGlobalEvent(Event.UPDATA_POWER)
    elseif dropData.type==Config.POWER_LIMIT_ID then --体力上限
--        Audio.playSound(Sound.SOUND_UI_LOTTERY_OPEN)--开宝箱
        self:dipatchGlobalEvent(Event.UPDATA_POWERLIMIT)
    end
end

return KeyScene
