-- 消除连线道具，关联道具和爆炸技能消除
local EliminateWidget = class("EliminateWidget",function () return cc.Node:create() end)
local BattleEvent = require("game.view.battle.BattleEvent")
local EffectCreator  = require("game.view.battle.EffectCreator")
local WidgetDropData = require("game.data.WidgetDropData")

local Del_Time = Config.DELETE_WIDGET_INTERVAL       -- 删除每个道具的间隔
local Del_Skill_Time = Config.DELETE_BOMB_INTERVAL  -- 爆炸删除道具的间隔

function EliminateWidget:create(elements,widgets,effectLayer,tollgateData,getDataByGridXY)
    local instance = EliminateWidget.new(elements,widgets,effectLayer,tollgateData)
    instance.getDataByGridXY = getDataByGridXY
    return instance
end

function EliminateWidget:ctor(elements,widgets,effectLayer,tollgateData)

    self.elements=elements
    self.widgets= widgets
    self.effectLayer = effectLayer
    self.tollgateData = tollgateData
    
    self.dropWidgetList = {}
    
    for k,dropData in pairs(WidgetDropData) do
        if self.tollgateData.widgetDrop == dropData.tollgate then
           -- print(dropData.widgetID,dropData.rewards)
            self.dropWidgetList[tostring(dropData.widgetID)] = clone(dropData.rewards)
        end
    end
end

function EliminateWidget:setUpdateScoreL(updateScore)
    self.updateScore = updateScore
end

-- 消除道具
function EliminateWidget:deleteElement(elementData)
    local widgetData = elementData.widget
    if widgetData then
        widgetData.rewards =  self.dropWidgetList[tostring(widgetData.eliminate.widgetID)]
        local widget = self.widgets[widgetData]
        self:dispatchEvent(BattleEvent.OnDeleteOne,elementData)
        elementData.widget = nil
        widget:remove()
        self.widgets[widgetData] = nil
    end
end

function EliminateWidget:startEliminate(pathArr,bombPath,triggerList)
    self.pathArr = pathArr
    self.bombPath = bombPath
    self.triggerList = triggerList
    self.count = 1
    self.scheduleAction = self:schedule(function() 
        self:eliminateWidget() 
    end,Del_Time)
end

--  爆炸道具
function EliminateWidget:addEffectSkill(elementData)
    local effectName = "effect_012"
    local armature = display.createEffect(effectName,effectName,nil,true,false,false)
    -- local armature = display.createArmature({path="effect/"..effectName.."/"..effectName},effectName)
    self.effectLayer:addChild(armature)
    -- print("-------",self.effectLayer)
    -- local point = elementData:offSetPoint()
    -- armature:setPosition(point.x, point.y)
    armature:setPosition(elementData.x * Config.Grid_MAX_Pix_Width,elementData.y * Config.Grid_MAX_Pix_Height)
end

-- 播放消除音效
function EliminateWidget:playSound(goodsData)
    if goodsData.sound then
        local soundName = Sound[goodsData.sound]
        Audio.playSound(soundName)
    end
end

--播放消除特效
function EliminateWidget:addEffect(id,effectName)
    if effectName ~= nil and effectName ~= "" then
        local element = self.elements[id]
        local x,y = element:getPosition()
        -- y = y + Config.BATTLE_SCENE_OFFSET_HEIGHT
        local movementName = effectName
        if string.sub(effectName,#effectName-1,#effectName-1) == "_" then
            effectName = string.sub(effectName,1,#effectName-2)
        end
        return EffectCreator:createEffect(self.effectLayer,effectName,movementName,x,y)
    end
    return nil
end

--  消除道具
function EliminateWidget:deleteWidget(_elementData)
    -- 消除选中元素
    self:deleteWidgetOne(_elementData)
    -- 消除路径周边的元素
    local list = self.triggerList[_elementData]
    if list ~= nil then
        for goodsData,nextElementData in pairs(list) do
             self:deleteAroundOne(nextElementData, goodsData)
        end
    end
end
function EliminateWidget:deleteAroundOne(_elementData, _widgetData)
    local element = self.elements[_elementData.id]
    local effectGoods = nil
    if _elementData.vBlock ~= nil and _elementData.vBlock == _widgetData then  
        effectGoods = _elementData.vBlock
        self:playSound(effectGoods)
        if _elementData.vBlock.conver > 0 then
            _elementData.vBlock = clone(GoodsData[tostring(_elementData.vBlock.conver)])
        else
            _elementData.vBlock = nil
        end
        element:updateVBlock()

    elseif _elementData.hBlock ~= nil and  _elementData.hBlock == _widgetData then
        effectGoods = _elementData.hBlock
        self:playSound(effectGoods)
        if _elementData.hBlock.conver > 0 then
            _elementData.hBlock = clone(GoodsData[tostring(_elementData.hBlock.conver)])
        else
            _elementData.hBlock = nil
        end
        element:updateHBlock()
    elseif _elementData.widget ~= nil and _elementData.widget == _widgetData then
        local widget = self.widgets[_widgetData]
        if widget ~= nil then
            if _widgetData.pang ~= nil then
                effectGoods =_widgetData.pang
                self:playSound(effectGoods)
                if _widgetData.pang.conver > 0 then
                    _widgetData.pang = clone(GoodsData[tostring(_widgetData.pang.conver)])
                else
                    _widgetData.pang = nil
                end
                widget:updatePang() 
                
                self:dispatchEvent(BattleEvent.OnCONVER,_elementData)
            else
                effectGoods =_widgetData.eliminate
                self:playSound(effectGoods)
                if _widgetData.eliminate.conver > 0 then
                    local rewards = self.dropWidgetList[tostring(_widgetData.eliminate.widgetID)]
                    if rewards then
                        _widgetData.rewards = rewards
                        self:dispatchEvent(BattleEvent.OnDeleteOne,_elementData)
                    end
                    _widgetData.eliminate = clone(GoodsData[tostring(_widgetData.eliminate.conver)])
                    widget:updateEliminate()
                    self:dispatchEvent(BattleEvent.OnCONVER,_elementData)
                elseif _widgetData.eliminate.type ~= 10 then
                    self:deleteElement(_elementData)
                end             
            end
        end
    end
    if effectGoods~=nil then
        local effect = self:addEffect(_elementData.id,effectGoods.triggerEffect)
        return effect~=nil
    end   
    return false
end
function EliminateWidget:deleteWidgetOne(_elementData)
    -- 消除连线的道具
    local widgetData = _elementData.widget
    if widgetData ~= nil then
        local widget = self.widgets[widgetData]
        -- 先消除附着物
        if widgetData.pang ~= nil then
            self:addEffect(_elementData.id,widgetData.pang.triggerEffect)
            if  widgetData.pang.conver > 0 then
                widgetData.pang = clone(GoodsData[tostring(widgetData.pang.conver)])
                self:dispatchEvent(BattleEvent.OnCONVER,_elementData)
            else
                widgetData.pang = nil
            end
            widget:updatePang()
            return false
        else
            self:addEffect(_elementData.id,widgetData.eliminate.triggerEffect)
            _elementData.skillTriggle = nil

            self:deleteElement(_elementData)
            return true
        end      
    end
    return false
end

function EliminateWidget:delSkillReady(_bombPath, _bOnComplete, _pathArr)
    if _bombPath and #_bombPath > 0 then
        self.bombPath = _bombPath
    end
    if _pathArr then
        self.pathArr = _pathArr
    end
    local pathArr = self.pathArr
    self.countSkill = 1
    _bOnComplete = _bOnComplete or true
    ----------------------------爆炸从中心点开始--------------
    local first,isBomb = nil,false
    for i = 1,#self.bombPath do
        local ele = self.bombPath[i]
        if ele.widget and ele.widget.eliminate.type == 13 then --type13 炸弹
            first = self.bombPath[i]
            isBomb = true
            break
        end
    end
    if first == nil and self.pathArr and #self.pathArr > 0 then
        first = self.pathArr[#self.pathArr]
    elseif first == nil and self.bombPath and #self.bombPath > 0 then
        first = self.bombPath[1]
    end

    local function comp(a,b)
        return (first.x - a.x) * (first.x - a.x) + (first.y - a.y) * (first.y - a.y) < (first.x - b.x) * (first.x - b.x) + (first.y - b.y) * (first.y - b.y)
    end
    if first then
        table.sort(self.bombPath,comp)      
        -----------------------------------------------------------
        local tBomb = {}
        for k,v in pairs(self.bombPath) do
            local z = math.abs(first.x - v.x) + math.abs(first.y - v.y) + 1
            if(tBomb[z] == nil)then tBomb[z] = {}end
            tBomb[z][#tBomb[z]+1] = v
        end
        local delay,n,tList = 0.25,0,{}
        if(isBomb)then n=n+1 tList[n]=cc.DelayTime:create(delay) end
        for key,var in pairs(tBomb) do
            n=n+1 tList[n]=cc.CallFunc:create(function()
                for i,v in ipairs(var) do
                    self:deleteSkillWidget(v, i==1)
                end
            end)
            n=n+1 tList[n]=cc.DelayTime:create(delay)
        end
        -- n=n+1 tList[n]=cc.DelayTime:create(delay)
        n=n+1 tList[n]=cc.CallFunc:create(function()
            if(_bOnComplete)then self:dispatchEvent(BattleEvent.OnDeleteComplete) end
        end)
        self:runAction(cc.Sequence:create(tList))  
    else
        self:eliminateSkillWidget(_bOnComplete)
        self.scheduleSkillAction = self:schedule(function() 
            self:eliminateSkillWidget(_bOnComplete) 
        end,Del_Skill_Time)
    end
end

function EliminateWidget:eliminateSkillWidget(_bOnComplete)
    if self.countSkill == #self.bombPath + 1 then
        self:stopAction(self.scheduleSkillAction)
        if(_bOnComplete)then self:dispatchEvent(BattleEvent.OnDeleteComplete) end
    else
        local elementData = self.bombPath[self.countSkill]
        self:deleteSkillWidget(elementData)
        self.countSkill = self.countSkill + 1
    end
end

function EliminateWidget:deleteSkillWidget(elementData, _isNoSoundBomb)
    -- 爆炸后，当前格子上的挡板立即清除(如果是可消除的挡板)

    function checkElementVBlock( _elementData )
        if _elementData.vBlock and _elementData.vBlock.eliminable == 1 then  
            self:playSound(_elementData.vBlock)
            _elementData.vBlock = nil
            self.elements[_elementData.id]:updateVBlock()
        end
    end
    function checkElementHBlock( _elementData )
        if _elementData.hBlock and _elementData.hBlock.eliminable == 1 then  
            self:playSound(_elementData.hBlock)
            _elementData.hBlock = nil
            self.elements[_elementData.id]:updateHBlock()
        end
    end
    checkElementVBlock(elementData)
    checkElementHBlock(elementData)
    local leftElementData = self.getDataByGridXY(elementData.x - 1,elementData.y)
    if leftElementData and table.indexof(self.bombPath,leftElementData) == false then
        checkElementVBlock(leftElementData)
    end
    local rightElementData = self.getDataByGridXY(elementData.x + 1,elementData.y) 
    if rightElementData and table.indexof(self.bombPath,rightElementData) == false then
        checkElementVBlock(rightElementData)
    end
    if elementData.y < 8 then 
        local upElementData = self.getDataByGridXY(elementData.x ,elementData.y + 1)
        if upElementData and table.indexof(self.bombPath,upElementData) == false then
            checkElementHBlock(upElementData)
        end
    end

            
    local widgetData = elementData.widget
    if widgetData ~= nil then
       local widget = self.widgets[widgetData]
            -- 先消除附着物
       if widgetData.pang ~= nil then
            self:playSound(widgetData.pang)
            widgetData.pang = nil
            widget:updatePang()
       else
            -- 类型10为不可爆破的道具(比如宝箱残留物)
            if widgetData.eliminate.type ~= 10 then
                if widgetData.eliminate.conver > 0 then
                    while (true) do
                        if widgetData.eliminate.conver == 0 then
                           
                            break
                        else
                            local rewards = self.dropWidgetList[tostring(widgetData.eliminate.widgetID)]
                            if rewards then
                                widgetData.rewards = rewards
                                self:dispatchEvent(BattleEvent.OnDeleteOne,elementData)
                            end
                            
                            self:dispatchEvent(BattleEvent.OnCONVER,elementData)
                            widgetData.eliminate = clone(GoodsData[tostring(widgetData.eliminate.conver)])
                        end
                    end  
                    local widget = self.widgets[widgetData]
                    widget:updateEliminate()
                end
                
                if widgetData.eliminate.type ~= 10 then
                    self:playSound(widgetData.eliminate)
                    self:deleteElement(elementData)
                    --计算分数为元素的才能得分
                    -- if(widgetData.eliminate.type <= Config.DATA_PETTYPE_COUNT) then
                    --     self.updateScore({len = 1})
                    -- end
                end
            end   
        end  
    end
    if(_isNoSoundBomb==nil or _isNoSoundBomb)then Audio.playSound(Sound.SOUND_BOMB) end
    self:addEffectSkill(elementData) 
end

function EliminateWidget:eliminateWidget()
    local pathArr = self.pathArr
    local len = #pathArr
    if self.count <= len then
        local elementData = pathArr[self.count]
        self:deleteWidget(elementData)
        self.count = self.count +1
    else
        self:stopAction(self.scheduleAction)
        if self.bombPath and #self.bombPath > 0 then
            self:delSkillReady()
        else
            self:dispatchEvent(BattleEvent.OnDeleteComplete)
        end
        --计算分数
        -- self.updateScore({len = #pathArr})
    end
end

return EliminateWidget