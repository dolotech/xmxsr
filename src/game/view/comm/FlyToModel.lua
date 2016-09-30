-- 掉落飞动模型
local FlyToModel = class("FlyToModel")
FlyToModel.__index = FlyToModel

function FlyToModel:create()
    local ins = FlyToModel:new()
    self:initModuleData()
    return ins
end

function FlyToModel:initModuleData()
    --怪物受击声音时间间隔
    self.mt = os.clock()
    --怪物防御声音时间间隔
    self.ft = os.clock()
    --宠物收集元素时间间隔
    self.ct = os.clock()
end

--1怪物受击声音时间间隔
--2怪物防御声音时间间隔
--3宠物收集元素时间间隔
function FlyToModel:playSound(type)
    if type==1 then
        if os.clock()-self.mt>=0.05 then
            Audio.playSound(Sound.SOUND_BATTLE_UNDERATTACK)
            self.mt = os.clock()
        end
    elseif type==2 then
        if os.clock()-self.ft>=0.05 then
            Audio.playSound(Sound.SOUND_BATTLE_IMMUNITY)
            self.ft =os.clock()
        end
    elseif type==3 then
        if os.clock()-self.ct>=0.05 then
            Audio.playSound(Sound.SOUND_BATTLE_COLLECT)
            self.ct =os.clock()
        end
    end
end

--掉落物品
function FlyToModel:flyDropModelParticle(path,starPoint,endPoint,scale,starScale,endScale,num,callBack,outY,starTime,moveTime)
    local goods = cc.ParticleSystemQuad:create(path)
    self:flyDropModelBase(goods,starPoint,endPoint,scale,starScale,endScale,num,callBack,outY,starTime,moveTime)
end
function FlyToModel:flyDropModel(picturePath,starPoint,endPoint,scale,starScale,endScale,num,callBack,outY,starTime,moveTime)
    local goods = cc.Sprite:createWithSpriteFrameName(picturePath)
    self:flyDropModelBase(goods,starPoint,endPoint,scale,starScale,endScale,num,callBack,outY,starTime,moveTime)
end
function FlyToModel:flyDropModelBase(goods,starPoint,endPoint,scale,starScale,endScale,num,callBack,outY,starTime,moveTime)
    goods:setPosition(starPoint)
    goods:setScale(scale)
    if num~=nil then
        goods:addChild(self:textLable(tostring(num),goods:getContentSize().width))
    end

    SceneManager.currentScene:addToEffectLayer(goods)
    local function callBackHandler(parameters)
        goods:removeFromParent(true)
        goods = nil
        if callBack~=nil then
            callBack()
        end
    end

    local sacleStart = cc.ScaleTo:create(starTime or 0.5,starScale,starScale)
    local moveStart = cc.MoveTo:create(starTime or 0.5,cc.p(starPoint.x,starPoint.y+(outY or 60)))
    local seq = cc.Sequence:create(cc.Spawn:create(sacleStart,moveStart),cc.CallFunc:create(function()
        local moveTo = cc.EaseIn:create(cc.MoveTo:create(moveTime or 1,endPoint),1.5)
        local sacleTo = cc.ScaleTo:create(moveTime or 1,endScale,endScale)
         goods:runAction(cc.Sequence:create(cc.Spawn:create(moveTo,sacleTo),cc.CallFunc:create(callBackHandler)))
    end))
    goods:runAction(seq)
end

--获取物品
function FlyToModel:flyGetModel(goodsData,starPoint,endPoint,num,callBack)
    local goods = cc.Sprite:createWithSpriteFrameName(Prefix.PREBATTLE_PICTURE.. goodsData.picture .. PNG)
    goods:setPosition(starPoint)
    if num~=nil then
        goods:addChild(self:textLable(tostring(num),goods:getContentSize().width))
    end
    SceneManager.currentScene:addToEffectLayer(goods)
    
    local function callBackHandler(parameters)
        goods:removeFromParent(true)
        goods = nil
        if callBack~=nil then
            callBack()
        end
    end
    local sacleStart = cc.ScaleTo:create(1,1.2,1.2)
    local moveStart = cc.MoveTo:create(1,cc.p(starPoint.x,starPoint.y+60))
    local seq = cc.Sequence:create(cc.Spawn:create(sacleStart,moveStart),cc.CallFunc:create(function()
        local moveTo = cc.MoveTo:create(1,endPoint)
        local sacleTo = cc.ScaleTo:create(1,1.4,1.4)
        local facTo = cc.FadeTo:create(1, 120)
        goods:runAction(cc.Sequence:create(cc.Spawn:create(moveTo,sacleTo,facTo),cc.CallFunc:create(callBackHandler)))
    end))
    goods:runAction(seq)
end

--飞到宠物
function FlyToModel:flyPetModel(elementData,toPoint,petCompete,isRemove,defType,data)

    if elementData then
        local widgetData = elementData.widget
        if widgetData then     
            local grid = elementData:offSetPoint()
            local goodsData = widgetData.eliminate      -- 道具
            local goods = cc.Sprite:createWithSpriteFrameName(Prefix.PREBATTLE_PICTURE..goodsData.pictureLight .. PNG)
            goods:setPosition(grid.x,grid.y)
            SceneManager.currentScene:addToRoleLayer(goods)
            goods:setLocalZOrder(1100)
            goods:setScale(0.6)
            goods.isDef = defType>0 and defType==goodsData.type
            
            local function callBackHandler(data)
                if data.isRemove then
                    if petCompete~=nil then
                        petCompete(data.goodsData)
                    end
                    data.goods:removeFromParent(true)
                    data.goods = nil
                else
                    data.goods:setVisible(false)
                    if petCompete~=nil then
                        petCompete(data)
                    end
                end
            end
            
            local sacleStart = cc.ScaleTo:create(0.1,1.4,1.4)
            local moveStart = cc.MoveTo:create(0.1,cc.p(grid.x,grid.y+60))
            local ndata = {goods=goods,goodsData=goodsData,isRemove=isRemove}
            
            local function callFunc(cdata) 
                self:playSound(3)
                local moveTo = cc.EaseIn:create(cc.MoveTo:create(0.5,toPoint),2)
                local sacleTo = cc.ScaleTo:create(0.5,0.5,0.5)
                local seq = cc.Sequence:create(cc.Spawn:create(moveTo,sacleTo),cc.CallFunc:create(handler(cdata,callBackHandler)))
                goods:runAction(seq)
            end
            local seqStart = cc.Sequence:create(cc.Spawn:create(moveStart,sacleStart),cc.CallFunc:create(handler(ndata,callFunc)))
            goods:runAction(seqStart)
        end
    end
end

--先飞到宠物再怪物
function FlyToModel:flyPetMonsterModel(data)

    if self.flyArrs==nil then
        self.flyArrs = {[1]={},[2]={},[3]={},[4]={},[5]={}}
        self.attackArr = clone(data.attackArr)
    end
    local function flyPetCompete(flydata)
        local type = flydata.goodsData.type
        local list  = self.flyArrs[type]
        local attack = data.attackArr[type]
        list[#list+1]  = flydata
        if #list>=attack.allLen then
            if attack.allLen>0 and data.powerCompleteHandler~=nil then
                data.powerCompleteHandler(type)
            end
            
            local len = #list
            for index, value in pairs(list) do
                local goods = value.goods
                local goodsData = value.goods
                goods:setVisible(true)
                goods:setScale(0.5)
                
                local function callBackHandler(cdata)
                    if data.flyMonstModel~=nil then
                        data.flyMonstModel(cdata.goodsData)
                    end
                    if cdata.goods.isDef==true then
                        self:defMoveModel(cdata.goods,0.7,1,0.3)
                    else
                        self:playSound(1)
                        cdata.goods:removeFromParent(true)
                        cdata.goods = nil
                        cdata = nil
                    end
                end

                local sacleStart = cc.ScaleTo:create(0.2,1,1)
                local x,y = goods:getPosition()
                local moveStart = cc.MoveTo:create(0.2,cc.p(x,y+60))
                
                local d = (index-1)*(0.08 * 3 /len)
                local delayTo = cc.DelayTime:create(d)
                local moveTo = cc.EaseIn:create(cc.MoveTo:create(0.2,data.endPoint),2)
                local sacleTo = cc.ScaleTo:create(0.2,0.5,0.5)
                
                local seq = cc.Sequence:create(delayTo,cc.Spawn:create(moveStart,sacleStart),cc.Spawn:create(moveTo,sacleTo),cc.CallFunc:create(handler(value,callBackHandler)))
                goods:runAction(seq)
                goods:setLocalZOrder(10+index)
            end
        end 
    end
    self:flyPetModel(data.elementData,data.toPoint,flyPetCompete,false,data.defType)
end

--直接飞到怪物身上
function FlyToModel:flyMonstModel(elementData,endPoint,attackMonsterComplete,defType)
    if elementData then
        local widgetData = elementData.widget
        if widgetData then
            local grid = elementData:offSetPoint()
            local goodsData = widgetData.eliminate -- 道具
            local goods = cc.Sprite:createWithSpriteFrameName(Prefix.PREBATTLE_PICTURE..goodsData.pictureLight .. PNG)
            goods:setPosition(grid.x,grid.y)
            SceneManager.currentScene:addToRoleLayer(goods)
            goods:setLocalZOrder(1100)
            goods:setScale(0.6)
            goods.isDef = defType>0 and defType==goodsData.type
            
            local function callBackHandler(parameters)
                if attackMonsterComplete~=nil then
                    attackMonsterComplete(goodsData)
                end
                if goods.isDef~=nil and goods.isDef==true then
                    self:defMoveModel(goods,0.7,1,0.3)
                else
                    goods:removeFromParent(true)
                    goods = nil
                    self:playSound(1)
                end
            end
            local sacleStart = cc.ScaleTo:create(0.1,1.4,1.4)
            local moveStart = cc.MoveTo:create(0.1,cc.p(grid.x,grid.y+60))
            local seqStart = cc.Sequence:create(cc.Spawn:create(moveStart,sacleStart),cc.CallFunc:create(function()
                self:playSound(3)
                local moveTo = cc.EaseIn:create(cc.MoveTo:create(0.6,endPoint),2)
                local sacleTo = cc.ScaleTo:create(0.6,0.5,0.5)
                local seq = cc.Sequence:create(cc.Spawn:create(moveTo,sacleTo),cc.CallFunc:create(callBackHandler))
                goods:runAction(seq)
            end))
            goods:runAction(seqStart)
        end
   end
end

--防御元素移动模型
function FlyToModel:defMoveModel(targer,time,startScale,endScale)
    self:playSound(2)
    targer:setScale(startScale)
    local r = math.random(1,10)
    local endPoint = nil
    if r<=5 then
        endPoint = cc.p(stageWidth+100,650)
    else
        endPoint = cc.p(-100,650)
    end
    local moveTo = cc.EaseBackOut:create(cc.MoveTo:create(time,endPoint))
    local sacleTo = cc.EaseBackOut:create(cc.ScaleTo:create(time,endScale))
    local swp = cc.Spawn:create(moveTo,sacleTo)
    local function callBackHandler()
        targer:removeFromParent()
    end
    local seq = cc.Sequence:create(swp,cc.CallFunc:create(callBackHandler))
    targer:runAction(seq)
end

--宠物丢技能
function FlyToModel:battlePetSkilModel(elementData,skillData,starPoint,callBack)
        local grid = elementData:offSetPoint()
        local goodsData =  GoodsData[tostring(skillData.wigetID)]
        local goods = cc.Sprite:createWithSpriteFrameName(Prefix.PREBATTLE_PICTURE..goodsData.picture.. PNG)
        goods:setScale(0.8)
        goods:setPosition(starPoint)
        SceneManager.currentScene:addToEffectLayer(goods)
      
        local sacleStart = cc.ScaleTo:create(0.2,1.4,1.4)
        local moveStart = cc.MoveTo:create(0.2,cc.p(starPoint.x,starPoint.y+60))
        local moveTo = cc.EaseIn:create(cc.MoveTo:create(0.3,grid),2)
        local sacleTo = cc.ScaleTo:create(0.3,1,1)
        local seqStart = cc.Sequence:create(cc.Spawn:create(moveStart,sacleStart),
            cc.Spawn:create(moveTo,sacleTo),cc.CallFunc:create(function()
                goods:setPosition(grid)
                goods:removeFromParent()
                if callBack~=nil then callBack() end
            end))
        goods:runAction(seqStart)
end

--怪物丢道具
function FlyToModel:battleMonsterSkilModel(elementData,goodsData,starPoint,callBack)
    local grid = elementData:offSetPoint()
    local goods = cc.Sprite:createWithSpriteFrameName(Prefix.PREBATTLE_PICTURE..goodsData.picture.. PNG)
    goods:setScale(0.8)
    goods:setPosition(starPoint)
    SceneManager.currentScene:addToEffectLayer(goods)

    local sacleStart = cc.ScaleTo:create(0.2,1.4,1.4)
    local moveStart = cc.MoveTo:create(0.2,cc.p(starPoint.x,starPoint.y+60))
    local moveTo = cc.EaseIn:create(cc.MoveTo:create(0.3,grid),2)
    local sacleTo = cc.ScaleTo:create(0.3,1,1)
    local seqStart = cc.Sequence:create(cc.Spawn:create(moveStart,sacleStart),
        cc.Spawn:create(moveTo,sacleTo),cc.CallFunc:create(function()
                goods:setPosition(grid)
                goods:removeFromParent()
                if callBack~=nil then callBack() end
            end))
    goods:runAction(seqStart)
end

--任务收集选项滑动
-- function FlyToModel:battleStartModel(list, onCompelete)
--     for index, item in pairs(list) do
--         local function callBackHandler()
--             if index >=#list then
--                 --全部完成回调
--                 if onCompelete~=nil then
--                     onCompelete()
--                     onCompelete = nil
--                 end
--             end
--         end

--         local x,y = item:getPosition()
--         local toPoint = cc.p(150, y)
--         local d = (index - 1) * (0.2)
--         local delayTo = cc.DelayTime:create(d)
--         local moveTo = cc.EaseBackOut:create(cc.MoveTo:create(0.3, toPoint))

--         local seq = cc.Sequence:create(delayTo, moveTo, cc.CallFunc:create(callBackHandler))
--         item:runAction(seq)
--     end
-- end

--消除元素掉落物品
function FlyToModel:battleDropGoods(elementData,goodsData,num,callBack)

    if goodsData.type==Config.DIANMOND_ID1 then
        Audio.playSound(Sound.SOUND_DIOMOND,false)
    elseif goodsData.type==Config.KEY_ID then
    	 Audio.playSound(Sound.KEY_ID,false)
    end
    
    local grid = elementData:offSetPoint()
    local goods = cc.Sprite:createWithSpriteFrameName(Prefix.PREBATTLE_PICTURE..goodsData.picture.. PNG)
    if num~=nil then
        goods:addChild(self:textLable(tostring(num),goods:getContentSize().width))
    end
    goods:setScale(0.8)
    goods:setPosition(grid)
    SceneManager.currentScene:addToEffectLayer(goods)

    local faceTo = cc.FadeTo:create(1.5,150)
    local sacleStart = cc.ScaleTo:create(1.5,1.5,1.5)
    local moveStart = cc.MoveTo:create(1.5,cc.p(grid.x,grid.y+150))

    local seqStart = cc.Sequence:create(cc.Spawn:create(moveStart,sacleStart,faceTo),cc.CallFunc:create(function()
        goods:removeFromParent()
        if callBack~=nil then callBack() end
    end))
    goods:runAction(seqStart)
end

function FlyToModel:textLable(text,offsetx)
    local ttfConfig = {}
    ttfConfig.fontFilePath =FONT_FZZT_TTF
    ttfConfig.fontSize = 48
    ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
    ttfConfig.customGlyphs = nil
    ttfConfig.distanceFieldEnabled = true
    local textLable = cc.Label:createWithTTF(ttfConfig,text,cc.TEXT_ALIGNMENT_CENTER)
    textLable:setPosition(offsetx-15,48)
    textLable:enableShadow()
    return textLable
end

--精灵移动
function FlyToModel:spriteMoveEaseOut(_picPath,_startPoint,_endPoint,_starTime,_moveTime,_randW,_scale,_startScale,_endScale, _color, callBack, _fDelay)
    local sprite = cc.Sprite:create(_picPath)
    sprite:setPosition(_startPoint)
    sprite:setScale(_scale or 1)
    sprite:setColor(_color or cc.c3b(175, 255, 179))
    SceneManager.currentScene:addToEffectLayer(sprite)
    -------------------------
    local function callBackHandler()
        sprite:removeFromParent()
        if callBack~=nil then callBack() end
    end

    local sacleStart = cc.ScaleTo:create(_starTime or 0.5,_startScale,_startScale)
    local moveStart = cc.MoveTo:create(_starTime or 0.5,cc.p(_startPoint.x+math.random(-_randW,_randW),_startPoint.y+math.random(0,_randW)))
    local rotateStart = cc.RotateTo:create(_starTime or 0.5, 180)

    local list = {}
    if(_fDelay ~= nil)then list[#list+1] = cc.DelayTime:create(_fDelay) end
    list[#list+1] = cc.Spawn:create(sacleStart,moveStart,rotateStart)
    list[#list+1] = cc.CallFunc:create(function()
            local moveTo = cc.EaseIn:create(cc.MoveTo:create(_moveTime or 1,_endPoint),2)
            local sacleTo = cc.ScaleTo:create(_moveTime or 1,_endScale,_endScale)
            local rotateTo = cc.RotateTo:create(_moveTime or 1, 720)
            sprite:runAction(cc.Sequence:create(cc.Spawn:create(moveTo,sacleTo,rotateTo),
                cc.CallFunc:create(callBackHandler)))
        end)
    sprite:runAction(cc.Sequence:create(list))
end

return FlyToModel


