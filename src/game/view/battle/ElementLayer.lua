--[[ 游戏战斗层显示对象及逻辑.
    组合了战斗道具显示，连线判定，下落判定，宠物技能逻辑及显示处理 
]]
local ElementLayer = class("ElementLayer" ,function () return cc.Node:create() end)
local AlgorithmTrigger= require("game.view.battle.algorithm.AlgorithmTrigger")
local ElementPath  = require("game.view.battle.algorithm.ElementPath")
local AutoBubble  = require("game.view.battle.algorithm.AutoBubble")
local Widget = require("game.view.battle.Widget")
local Element = require("game.view.battle.Element")
local AlgorithmSkill = require("game.view.battle.algorithm.AlgorithmSkill")
local BattleEvent = require("game.view.battle.BattleEvent")
local ElementLayerConstrutor = require("game.view.battle.ElementLayerConstrutor")
local FallEngine = require("game.view.battle.FallEngine")
local EliminateWidget = require("game.view.battle.EliminateWidget")
local ConverSkill = require("game.view.battle.ConverSkill")
local PacMan = require("game.view.battle.element.PacMan")
local Sludge = require("game.view.battle.element.Sludge")
local Chimney = require("game.view.battle.element.Chimney")
local WidgetData = require("game.data.WidgetData")
local Newbie = require("game.view.battle.Newbie")
local GameoverToRewards = require("game.view.battle.GameoverToRewards")

--data elementLayerData
function ElementLayer:create(data, param)
    local instance = ElementLayer.new(data)
    instance:setNodeEventEnabled()
    instance.data = data
    instance.playing = true
    instance.clsToolBar = param.clsToolBar
    return instance
end

-- 获取当前怪物的防御类型
function ElementLayer:setDefTypeFun( fun )
    -- body
    self.getDefType = fun
end

-- 宠物扔技能 skillData
function ElementLayer:dropSkill(elementData,skillData)
    if(elementData.widget == nil)then return end
    elementData.widget.eliminate = clone(GoodsData[tostring(skillData.wigetID)])
    elementData.widget.skill = clone(skillData)
    local widget = self.widgets[elementData.widget]
    widget:updateEliminate()
end

-- 怪物扔游戏道具 goodsData
function ElementLayer:dropGoods(elementData,goodsData)
    local widget = self.widgets[elementData.widget]
    if goodsData.type == 9 then
        elementData.widget.pang = clone(goodsData)
        widget:updatePang()
    elseif goodsData.widgetID == 36 then--蝙蝠
        widget:removeFromParent()
        self.widgets[elementData.widget] = nil
        
        local widgetData = WidgetData:create()
        elementData.widget = widgetData 
        widgetData.eliminate = clone(goodsData)
        widgetData.x = elementData.x
        widgetData.y = elementData.y
        widgetData.element = elementData
        
        local pacman = PacMan:create(widgetData,self.autoBubble,self.widgets,self.widgetLayer)
        self.widgets[elementData.widget] = pacman
        pacman:setPosition(elementData.x * Config.Grid_MAX_Pix_Width,elementData.y * Config.Grid_MAX_Pix_Height)
        self.widgetLayer:addChild(pacman)
    else
        elementData.widget.eliminate = clone(goodsData)
        elementData.widget.skill = nil
        widget:updateEliminate()
    end
end

-- 全盘换位
function ElementLayer:transposition()
    local arr = self.autoBubble:transposition()
    for k,elementData in pairs(arr) do
        if elementData.widget ~= nil then
            local widget = self.widgets[elementData.widget]
            widget.x = elementData.x * Config.Grid_MAX_Pix_Width
            widget.y = elementData.y * Config.Grid_MAX_Pix_Height
            elementData.widget.x = elementData.x
            elementData.widget.y = elementData.y
            widget:moveTo(0.2,widget.x,widget.y)
            elementData.widget.element = elementData
            self:bubble(self.elements[elementData.id])
        end
    end
    if #arr>0 then
        self:dispatchEvent(BattleEvent.OnBattleSpeak,Language.Speak_Rest_Game)
    end
    self:gameStart()
    self:startTips()
end

-- 连线选中道具(高光)
function ElementLayer:light(path)
    for i = 1,#path do
        local elementData = path[i]
        local widgetData = elementData.widget
        if widgetData ~= nil then
            local widget = self.widgets[widgetData]
            widget:light() 
        end
    end 
end

-- 让其他不同类元素暗下去
function ElementLayer:alaphOthers(currentElement)
    for k,element in pairs(self.elements) do  
        local widgetData = element.data.widget
        if widgetData ~= nil then
            local widget = self.widgets[widgetData] 
            -- if widget:getOpacity() == 128 then
               widget:setOpacity(255)
            -- end
            if widgetData.eliminate.type ~= currentElement.widget.eliminate.type and currentElement.widget.eliminate.type <= 5 then
                if widgetData.eliminate.fall == 1 then      -- 不可掉落的道具不能变暗 
                    widget:setOpacity(128)
                else
                   
                end
            else
                 
            end
        end
    end
end

function ElementLayer:unAlaphOthers()
    for k,element in pairs(self.elements) do  
        local widgetData = element.data.widget
        if widgetData ~= nil then
            local widget = self.widgets[widgetData]   
            widget:setOpacity(255)
        end
    end 
end

-- 取消连线道具(恢复非高光)
function ElementLayer:unLight(path)
    for i = 1,#path do
        local elementData = path[i]
        local widgetData = elementData.widget
        if widgetData ~= nil then
            local widget = self.widgets[widgetData]
            widget:unLight()
            self.lineLayer:removeLine(elementData.id,path) 
        end
    end 
    local pathArr = self.path:getPath()
    if #pathArr > 0 then
        self.lineLayer:removeLine(pathArr[#pathArr].id) 
    end
end

-- 新手引导非引导路径上的元素暗下去
function ElementLayer:unAlphaNewbie()
    local path = self.newbie:getPath()
    local function isInPath(elementData)
         for i = 1,#path do
            local pos = path[i]
            if pos.x == elementData.x and pos.y == elementData.y then
                return true
            end
         end
         return false
    end

   for i = 1,#self.data.data do
        local elementData = self.data.data[i]
        local widgetData = elementData.widget
        if widgetData ~= nil then
            local widget = self.widgets[widgetData]
            if not isInPath(elementData) then
                widget:setOpacity(128)
            end
        end
    end 
end

function ElementLayer:stopTips()
    if self.delayBubble then
        self:stopAction(self.delayBubble)
        self.delayBubble  = nil
    end
end

--自动搜索能消除的元素并作提示
function ElementLayer:startTips()
    if self.newbie:isNewbie() then
        return
    end
    if not self.playing then  return end
    self:stopTips()
    local path = self.autoBubble:findPath()
    
    local function callback()
        local i = 1
        if path then
            local function bubble()
                if i == 4 then
                    self:stopAction(self.act)
                    return
                end
                self:bubble(path[i])
                i = i + 1
            end
            self.act = schedule(self,bubble,0.3)
        end
    end
    self.delayBubble = schedule(self,callback,3)
end

function ElementLayer:onExit()
    self.fallEngine:stop()
end

-- 创建遮罩层
function ElementLayer:createOPacityBackgroud()
    local rect = cc.rect(0,0,Config.Grid_MAX_Pix_Width*Config.Element_Grid_Width,Config.Grid_MAX_Pix_Height*Config.Element_Grid_Height)
    local layer = display.createMaskLayer(rect)
    layer:setPosition(0,-Config.Grid_MAX_Pix_Height)
    return layer
end

function ElementLayer:showMaskLayer()
    if(not self.maskLayer:isVisible())then
        self.maskLayer:setVisible(true)
        self.maskLayer.sprite:fadeIn(0.2)
    end
end
function ElementLayer:hideMaskLayer( _funCallBack )
    self.maskLayer.sprite:runAction(cc.Sequence:create(
    cc.FadeOut:create(0.1),cc.CallFunc:create(function()
        self.maskLayer:setVisible(false)
        if(_funCallBack ~= nil)then _funCallBack() end
    end)
    ))
end

-- 连线完消除道具时，道具上层加上遮罩
function ElementLayer:activateMaskLayer()
    -- print("=========================ElementLayer:activateMaskLayer")
   self.maskLayer:setTouchEnabled(true)
   self.maskLayer:setVisible(false)
   self.maskLayer:setTag(1)
end

--去掉遮罩
function ElementLayer:activateFallEngine(bool, _isSendStop)
    -- print("------ElementLayer:activateFallEngine")
    if(self.maskLayer:getTag()==1 or bool)then 
        self.maskLayer:setTag(0)
        self:onEngineStart(_isSendStop)
    end
    -- self.maskLayer:setVisible(false) 
end

function ElementLayer:touchEnabled(bool)
    self.maskLayer:setTouchEnabled(bool)
end

function ElementLayer:userStartToTouch() 
    self:hideMaskLayer(function()
        self.maskLayer:setTouchEnabled(false)       --下落完成才可以点击 
        self.newbie:next()
        if self.newbie:isNewbie() then
           self:unAlphaNewbie()
        end
    end)
end

-- 玩家可以开始游戏（可以连线,用于怪物丢道具完成才开始游戏）
function ElementLayer:gameStart() 
    if not self.hasPacman then
       self:userStartToTouch()
    end
end
 
function ElementLayer:onEnter()
    self.elementLayer = cc.Node:create()                -- 格子层
    self.widgetLayer = cc.Node:create()                 -- 可消除的道具层
    self.lineLayer = require("game.view.battle.Line"):create()                  -- 连线特效层
    self.maskLayer = self:createOPacityBackgroud()      --  遮罩层
    self.effectLayer = cc.Node:create()                 -- 消除特效层
    self.bombElementList = {}
    self:addChild(self.elementLayer)
    self:addChild(self.lineLayer)
    self:addChild(self.widgetLayer)
    self:addChild(self.maskLayer)
    self:addChild(self.effectLayer) 
    -- self.effectLayer.setVisible(false)
    self.maskLayer:setTouchEnabled(false)       --下落完成才可以点击
    self.path = ElementPath:create()
    self.trigger = AlgorithmTrigger:create()
    self.newbie = Newbie:create(self.data.guide,self.effectLayer)
   
    self.autoBubble = AutoBubble:create(self.data.data,handler(self.data,self.data.getDataByGridXY))
    self.isTouched = false
    self.elements,self.widgets = ElementLayerConstrutor(self.elementLayer,self.widgetLayer,self.data.data,handler(self.data,self.data.getDataByGridXY))
    self.fallEngine =  FallEngine:create(self.elements,self.widgets,self.data,self.widgetLayer)
    self:addChild(self.fallEngine)
    self.eliminateWidget = EliminateWidget:create(self.elements,self.widgets,self.effectLayer,self.data.tollgateData,handler(self.data,self.data.getDataByGridXY))
    self:addChild(self.eliminateWidget)
    self.converSkill = ConverSkill:create(self.widgets,handler(self.data,self.data.getDataByGridXY))
    self.skill = AlgorithmSkill:create(self.widgets,handler(self.data,self.data.getDataByGridXY))
    
    self.gameoverToRewards = GameoverToRewards:create(self.data,self.skill,self.eliminateWidget,self.trigger)
    local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:registerScriptHandler(handler(self,self.onTouchBegan),cc.Handler.EVENT_TOUCH_BEGAN )
    listenner:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED )
    listenner:registerScriptHandler(handler(self,self.onTouchEnd),cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self)
   
    self:addEventListener(BattleEvent.RESUME ,handler(self,self.onPlaye))
    self:addEventListener(BattleEvent.PAUSE ,handler(self,self.onPause))
    
    self.fallEngine:addEventListener(BattleEvent.ENGINE_STOP ,handler(self,self.onEngineStop))
    
    self.eliminateWidget:addEventListener(BattleEvent.OnDeleteOne,handler(self,self.acive))
    self.eliminateWidget:addEventListener(BattleEvent.OnCONVER,handler(self,self.acive))
    self:addEventListener(BattleEvent.START_ENGINE ,handler(self,self.onEngineStart))
    -- self:addEventListener(BattleEvent.ShowMaskLayer ,handler(self,self.showMaskLayer)

    if self.newbie:isNewbie() then
        self.newbie:start()
        self:unAlphaNewbie()
    end

    -- 初始化检测场景内是否有道具，因为有些关卡内的道具全部是有程序生成的
    performWithDelay(self,function ()
        self.maskLayer:setVisible(false) 
        self:onEngineStart()
    end,0.5)
end

function ElementLayer:acive(event)
    local elemData = event._userdata
    if (elemData.widget.eliminate.sort == 35) then
        Sludge.aciveState = true
    end
end

function ElementLayer:onEngineStart( _isSendStop, _isBattleWin )
    self:showMaskLayer()
    -- print("------onEnterFrame]",self.isSendStop)
    self.fallEngine:start( _isSendStop )
    self.isBattleWin = _isBattleWin
end

function ElementLayer:onEngineStop()
    self:hideMaskLayer()
    --不开启时不计算步数
    if self.startEliminate then
        -- 当前轮没有消除淤泥，就随机抽取一个四个方向随机发生感染
        if not Sludge.aciveState then 
            local elementData = self.autoBubble:searchInfection()
            if elementData then
                local widget = self.widgets[elementData.widget]
                widget:removeFromParent(true)
                self.widgets[elementData.widget] = nil

                local widgetData = WidgetData:create()
                elementData.widget = widgetData 
                widgetData.eliminate = clone(GoodsData[tostring(35)])
                widgetData.x = elementData.x
                widgetData.y = elementData.y
                widgetData.element = elementData

                local sludge = Sludge:create(widgetData,self.autoBubble,self.widgets,self.widgetLayer)
                self.widgets[elementData.widget] = sludge
                sludge:setPosition(elementData.x * Config.Grid_MAX_Pix_Width,elementData.y * Config.Grid_MAX_Pix_Height)
                self.widgetLayer:addChild(sludge)
                sludge:setScale(0.1)
                sludge:runAction(cc.ScaleTo:create(0.8, 1.0))
            end
        end
        -- 烟囱生成,除非该烟囱被打趴下，不然随机从站起来的烟囱中随机抽取一个，向8个方向随机释放一坨淤泥
        local elementData,originalElementData = self.autoBubble:searchChimneyDrop()
        if elementData then
            local widgetData = WidgetData:create()
             widgetData.eliminate = clone(GoodsData[tostring(35)])
            local sludge = Sludge:create(widgetData,self.autoBubble,self.widgets,self.widgetLayer)
            sludge:setPosition(originalElementData.x * Config.Grid_MAX_Pix_Width,originalElementData.y * Config.Grid_MAX_Pix_Height)
            self.widgetLayer:addChild(sludge)

            local x = elementData.x * Config.Grid_MAX_Pix_Width
            local y = elementData.y * Config.Grid_MAX_Pix_Height
            local midX = (elementData.x + originalElementData.x) * Config.Grid_MAX_Pix_Width * 0.5
            local midY = (elementData.y + originalElementData.y) * Config.Grid_MAX_Pix_Height * 0.5
            local spawn1 = cc.Spawn:create(cc.ScaleTo:create(0.2, 2.0),cc.MoveTo:create(0.2, cc.p(midX,midY)))
            local spawn2 = cc.Spawn:create(cc.ScaleTo:create(0.2, 1.0),cc.MoveTo:create(0.2, cc.p(x,y)))
            
            local function callback()
                 if elementData.widget then
                    local widget = self.widgets[elementData.widget]
                    widget:removeFromParent(true)
                end

                widgetData.x = elementData.x
                widgetData.y = elementData.y
                elementData.widget = widgetData 
                widgetData.element = elementData
                self.widgets[elementData.widget] = sludge
            end
            local sequence= cc.Sequence:create(spawn1,spawn2,cc.CallFunc:create(callback))
            sludge:runAction(sequence)
        end
        -- 通知怪物丢道具
        self:dispatchEvent(BattleEvent.FALL_COMPLETE)
        self.startEliminate = nil
    else --跳过怪物流程 直接进入宠物流程 
        if(self.isBattleWin==true)then SceneManager.currentScene:dispatchEvent(BattleEvent.OnDeleteComplete)
        else SceneManager.currentScene:dispatchEvent(BattleEvent.OnDropMonsterSkill)
        end
    end
end

function ElementLayer:checkThreeWidgetInAll()
    -- 是否有3个位置可用于换位的
    -- local path1 = self.autoBubble:findPath(true)
    -- 是否有三个相同的元素
    if self.autoBubble:isThreeWidgetInAll() and self.autoBubble:findPath(true) then
        -- 是否有可连线的三个元素
        local path = self.autoBubble:findPath()
        -- 如果有三个相同的元素，没有连在一起，则随机换位
        if path == nil then
            self.PacmanAction = false
            performWithDelay(self, handler(self,self.transposition),0.5)
        else
            self:gameStart()
            self:startTips()
        end
    else --当没有能连接,能转换的元素时跳转到失败 (bug?)
        TipsManager:ShowText(Language.No_Element_Can, nil, 28)
        self:performWithDelay(function()self:dispatchEvent(BattleEvent.NON_THREE_IN_ALL)end, 1.2)
        TalkingData.onTaskFailed(Language.Statistics_Task..Global.selChapterId,"没有能连接的元素")
    end
end

function ElementLayer:onPlaye()
    self.playing = true
    self:startTips()
end

function ElementLayer:onPause()
    self:stopTips()
    self.playing = false
end
  
-- 添加爆破技能圈圈特效标示  
function ElementLayer:addBombEffect(elementData)
    local effectName = "effect_015"
    local armature = display.createArmature({path="effect/"..effectName.."/"..effectName},effectName)
    self.effectLayer:addChild(armature)
    armature:setPosition(elementData.x * Config.Grid_MAX_Pix_Width,elementData.y * Config.Grid_MAX_Pix_Height)
    return armature
end

-- 刷新爆破技能圈圈特效标示  
function ElementLayer:refrshBombShow(path)
    for elementData,v in pairs(self.bombElementList) do
        -- 不在当前爆破列表的,移除
        if not table.indexof(path,elementData) then     
            v:removeFromParent()
            self.bombElementList[elementData] = nil   
        end
        if elementData.widget then
            local widget = self.widgets[elementData.widget]
            widget:updateEliminate(true)
        end
    end
    
    for i,elementData in pairs(path) do
        -- 新添加爆破特效
        if not self.bombElementList[elementData] then
            local effect= self:addBombEffect(elementData)
            self.bombElementList[elementData] = effect
        end
        if elementData.widget then
            local widget = self.widgets[elementData.widget]
            widget:updateEliminate(true)
        end
     end
     
    local pathArr = self.path:getPath()
    for i,elementData in pairs(pathArr) do
        if elementData.widget then
            local widget = self.widgets[elementData.widget]
            widget:updateEliminate(true)
        end
     end
end

function ElementLayer:opBombList(pathArr,bombArr)
    local t = {}
    for i = 1,#bombArr do
        local te = bombArr[i]
        if te and te.widget and te.widget.eliminate.type <= 5 and te.widget.pang == nil then
            if not table.indexof(pathArr,te) then
                t[#t + 1] = bombArr[i]
            end
        end
    end
    return t
end

-- 添加防御图片
function ElementLayer:addDef(location,type)
    local defType = self.getDefType()
    if type == defType and defType>0 then
          if self.defIcon == nil then
                self.defIcon = cc.Sprite:createWithSpriteFrameName("ui/icon_shield_06_01.png")
                self:getParent():getParent():addChild(self.defIcon)
    
                local scaleTo1 = cc.ScaleTo:create(1.2,1)
                local scaleTo2 = cc.ScaleTo:create(1.2,1.1)
                local seq = cc.Sequence:create(scaleTo1, scaleTo2)
                seq = cc.RepeatForever:create(seq)
                self.defIcon:runAction(seq)  
          end 
          self.defIcon:setPosition(location.x ,location.y )
          self.defIcon:setVisible(true)   
    end
end

-- 移除防御图片
function ElementLayer:removeDef(type)
    if self.defIcon then
        self.defIcon:setVisible(false)
        self.defType = 0
    end
end

-- 播放连线音效
function ElementLayer:playConnectSound(len)
   if len < 1 then
    len = 1
   elseif len > 15 then
    len = 15
   end   
    local soundName = Sound["SOUND_BATTLE_CONNECTING" .. len]
    Audio.playSound(soundName)
end
    
function ElementLayer:onTouchBegan(touch, event)
    Global.touchStateElement = 0
    --使用道具时
    if(self.clsToolBar.itemIdx>0)then 
        return true
    end
    ------------------------

    if self.isTouched then
        return false
    end
    local location = touch:getLocation()
    self.path:clear()
    self.trigger.triggerList = {}
    self.skill.bombPath = {}
    self:removeDef()
    local elementData = self.data:getElementByXY(self,location.x,location.y)
    if elementData ~= nil then
        Global.touchStateElement = 1
        local canConneted =  self.autoBubble:connected(elementData,self.path)
        if canConneted then
            local pathArr = self.path:getPath()
            if self.newbie:isNewbie() then
                if not self.newbie:isNewbieGrid(#pathArr+1,elementData.x,elementData.y) then
                    return false
                end
            end

            self.path:push(elementData)
            
            self:playConnectSound(#pathArr)
            self.trigger:add(elementData,self.data,pathArr)
            self:bubble(elementData)
            self.defType = elementData.widget.eliminate.type
            self:addDef(location,self.defType)
            self:light(pathArr)
            self.lineLayer:addLine(pathArr)
            self:alaphOthers(elementData)
            self:stopTips()
            local bombArr = self:bomb(pathArr)
            self:dispatchEvent(BattleEvent.OnTouchBegan,{pathArr,self:opBombList(pathArr,bombArr)})
        end
    end
    self.isTouched = true
    Sludge.aciveState = false
--    self.PacmanAction = false
    return true
end

function ElementLayer:onTouchMove(touch, event)
    --使用道具时
    if(self.clsToolBar.itemIdx>0)then 
        return 
    end
    ------------------------

    local location = touch:getLocation()
    local elementData = self.data:getElementByXY(self,location.x,location.y)
    if elementData ~= nil then

        local pathArr =  self.path:getPath()
         
        -- 回退
        local tElment = self.path:isBack(elementData)
        if tElment ~= nil then
            self.trigger:remove(tElment)
            self:unLight({tElment})
            self:bubble(pathArr[#pathArr])
            self:playConnectSound(#pathArr)
            -- 反转换
            self.converSkill:unConver(tElment,self.widgets)
            local bombArr = self:bomb(pathArr,tElment)
            self:dispatchEvent(BattleEvent.OnConnectBack,{pathArr,self:opBombList(pathArr,bombArr)})
        else

            if self.newbie:isNewbie() then
                if not self.newbie:isNewbieGrid(#pathArr+1,elementData.x,elementData.y) then
                    return false
                end 
            end

            local canConneted =  self.autoBubble:connected(elementData,self.path)
            if canConneted then
                self.path:push(elementData)
                self:playConnectSound(#pathArr)
                self.trigger:add(elementData,self.data,pathArr)
                
                self.lineLayer:addLine(pathArr)
                self:light(pathArr)
                -- self:alaphOthers(elementData)
                self:bubble(elementData)
               local bombArr =  self:bomb(pathArr)
                self:dispatchEvent(BattleEvent.OnConnected,{pathArr,self:opBombList(pathArr,bombArr)})
                -- 转换
                self.converSkill:conver(elementData,pathArr,self.widgets)
            end
        end 
    end
     self:addDef(location,self.defType)  
end
function ElementLayer:onTouchEnd(touch, event)
    Global.touchStateElement = 3
    --使用道具时
    if(self.newbie:isNewbie()==false and self.clsToolBar.itemIdx>0)then 
        local location = touch:getLocation()
        local elementData = self.data:getElementByXY(self,location.x,location.y)
        if(elementData~=nil)then
            self.path:clear()
            self.clsToolBar:useItem(elementData, self.widgets, self.eliminateWidget, self.autoBubble,
                function(_elementData)
                    if(_elementData == nil)then 
                        self.path:clear()
                    else self.path:push(_elementData) end
                end,
                function(_bombArr)
                    if(_bombArr ~= nil)then 
                        local pathArr = self.path:getPath()
                        self:dispatchEvent(BattleEvent.UPDATE_DATA,{pathArr,self:opBombList(pathArr,_bombArr)})
                    else 
                        self:activateMaskLayer()
                        local pathArr = self.path:getPath()
                        self.defType = elementData.widget.eliminate.type
                        self:addDef(location,self.defType)
                        local bombArr = self:bomb(pathArr, true)
                        self:dispatchEvent(BattleEvent.UPDATE_DATA,{pathArr,self:opBombList(pathArr,bombArr)})
                        -- self.skill:clearAllConver()
                        self:refrshBombShow({})         -- 移除爆炸选中圈圈
                        self:stopTips()
                        Audio.playSound(Sound.SOUND_BATTLE_CHOSE)
                        return bombArr
                    end
                end,
                function()
                    self:onEngineStart()
                end)
        else--没有元素时取消道具模式
            self.clsToolBar:cancelItem()
        end
        self:removeDef()
        return 
    end
    ------------------------

    self:dispatchEvent(BattleEvent.OnTouchEnd)
    self:eliminate()
    self.isTouched = false
    self:removeDef()
end

function ElementLayer:bomb(pathArr, bool)            
    local path = self.skill:bombAlgorithm(pathArr, bool)
    self:refrshBombShow(path)
    return path
end

-- 3个及以上连线才可以消除
function ElementLayer:eliminate()
    local pathArr = self.path:getPath()
    self:unLight(pathArr)           
    self.skill:clearAllConver()
    self:refrshBombShow({})         -- 移除爆炸选中圈圈
    if(#pathArr >= 3) then    
        -- 应该大于新手连线数量
        if self.newbie:isNewbie() and  #pathArr < #self.newbie:getPath() then
            self:unAlphaNewbie()
            self:dispatchEvent(BattleEvent.OnTouchEndDelete,true)
            return
        end          
        self.startEliminate = true
        -- 按连线路径逐个消除
        self.eliminateWidget:startEliminate(pathArr,self.skill.bombPath,self.trigger.triggerList)
        self:activateMaskLayer()
        self:stopTips()
        
        Audio.playSound(Sound.SOUND_BATTLE_CHOSE)
        self.newbie:clear()--清除新手教程
        self:dispatchEvent(BattleEvent.NEWBIE_EVENT)
        self:unAlaphOthers()
        self:dispatchEvent(BattleEvent.OnTouchEndDelete,false)

    else -- 不足3个反转换
        if #pathArr > 0 then 
            self.converSkill:unConver(pathArr[#pathArr],self.widgets)
        end

        if #pathArr > 0 then Audio.playSound(Sound.SOUND_BATTLE_CANCEL) end
        if self.newbie:isNewbie() then
            self:unAlphaNewbie()
        else
            self:unAlaphOthers()
        end 
    end
end

--气泡动画
function ElementLayer:bubble(elementData,callback)
    local widgetData = elementData.widget
    if widgetData ~= nil then
        local widget = self.widgets[widgetData]
        widget:bubble(callback)
    end
end

return ElementLayer