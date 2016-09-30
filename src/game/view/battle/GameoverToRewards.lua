-- Author: Your Name
-- Date: 2015-02-01 16:21:57
--
-- 战斗结束剩余技能和步数换算成奖励
local Vector2D = require("game.util.Vector2D")
local Newbie = class("Newbie")
local AlgorithmFall= require("game.view.battle.algorithm.AlgorithmFall")
local Widget = require("game.view.battle.Widget")
local BattleEvent = require("game.view.battle.BattleEvent")

local GameoverToRewards = class("GameoverToRewards")
function GameoverToRewards:create(data,skill,eliminateWidget,trigger)
    local instance = GameoverToRewards.new(data,skill,eliminateWidget,trigger)
    return instance
end

function GameoverToRewards:ctor(data,skill,eliminateWidget,trigger)
    self.skill = skill
	self.data = data.data
    self.layerData = data
    self.eliminateWidget = eliminateWidget
    self.trigger = trigger
end


--关卡初次胜利时从右上角剩余回合数出射出绿色圆球消除当前画面上剩余技能
--return elementData 数组
function GameoverToRewards:getSkill()
	-- body
	-- local skills = {}
	local data = self.data
    local len = #data 
    for i=1,len do
        local elementData = data[i]
        local widgetData = elementData.widget
        if widgetData and widgetData.pang == nil and widgetData.skill then
            return elementData
        end
    end  

    return  nil
end

-- 触发技能
-- GameoverToRewards 方法获取的 elementData数据 
function GameoverToRewards:triggerSkill(_elementData, _bRewad)

   -- 转换技能
   -- if not _elementData.widget then return end
   if _elementData.widget.skill.type == 2 then
        if(_bRewad)then _elementData.widget.gameoverRewards = {{id=6,count=1}}
        else _elementData.widget.gameoverRewards = {{id=114,count=1}} end

        self.trigger.triggerList = {}
        self.trigger:add(_elementData,self.layerData,{_elementData})
        self.eliminateWidget:startEliminate({_elementData},{},self.trigger.triggerList)
    else
     -- 爆炸技能
       local path = self.skill:bombAlgorithm({_elementData})
        if #path > 0 then
            for i = 1,#self.skill.bombPath do
                local ele = self.skill.bombPath[i]
                if ele.widget then  
                   ele.widget.gameoverRewards = {{id=114,count=1}}
                end
            end
            if(_bRewad)then _elementData.widget.gameoverRewards = {{id=6,count=1}}
            else _elementData.widget.gameoverRewards = {{id=114,count=1}} end
            self.eliminateWidget:delSkillReady(self.skill.bombPath,nil,{_elementData})
        end
    end
end

-- 按照剩余步数随机消除地图上的基本元素，转换为一级符文
--return elementData
function GameoverToRewards:getRandElement( _num )
	local i,ranElementDatas = 0,{}
    for k,elementData in pairs(self.data) do
        local widgetData = elementData.widget
        if widgetData 
            -- and widgetData.pang == nil and widgetData.eliminate.type <= 5 
        then
            i=i+1 ranElementDatas[i] = elementData
        end
    end
    function randElement(_num)
        local n, list = 0, {}
        local rand,len
        for i=1,_num do
            len = #ranElementDatas
            if(len<1)then break end
            rand = random_range(1, #ranElementDatas)
            n=n+1 list[n] = table.remove(ranElementDatas, rand)
        end
        return #list>0 and list or nil
    end

    if #ranElementDatas > 0 then
        return randElement(_num)
    else
        return nil
    end
end	

-- 根据剩余步数触发普通元素
-- getRandElement 方法获取的 _elementData 
function GameoverToRewards:triggerElement( _tBombArr, _cToolBar, _bRewad )

    for i,v in ipairs(_tBombArr) do
        local tList = _cToolBar:getBombPath(v.eleData, 1, self.eliminateWidget.getDataByGridXY)
        for key,var in pairs(tList) do
            if(var.widget)then
                if(_bRewad)then var.widget.gameoverRewards = {{id=114,count=1}}
                else var.widget.gameoverRewards = {} end
            end
        end
        v.sprite:performWithDelay(function()
            _cToolBar:playBombAni(v.sprite, self.eliminateWidget, tList, true)
        end, 0.1*i)
    end

    -- self.trigger.triggerList = {}
    -- self.trigger:add(_elementData,self.layerData,{_elementData})

    -- self.eliminateWidget.triggerList = self.trigger.triggerList
    -- self.eliminateWidget:deleteWidget(_elementData)
    -- self.eliminateWidget:startEliminate({_elementData},{},self.trigger.triggerList)
end



return GameoverToRewards