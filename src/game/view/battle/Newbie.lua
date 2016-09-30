-- 战斗内新手引导
local Vector2D = require("game.util.Vector2D")
local Newbie = class("Newbie")
local AlgorithmFall= require("game.view.battle.algorithm.AlgorithmFall")
local Widget = require("game.view.battle.Widget")
local BattleEvent = require("game.view.battle.BattleEvent")

--guideData：新手引导数据
-- effectLayer：手指显示曾
function Newbie:create(guideData,effectLayer)
    local instance = Newbie.new(guideData,effectLayer)
    return instance
end

function Newbie:ctor(guideData,effectLayer)
    self.guideData = guideData
    self.effectLayer = effectLayer
    self.count = 1
end

-- 获取当前新手引导路径
function Newbie:getPath()
    -- body
    return self.guideData[self.count]
end

-- 走完一轮引导，进入下一轮
function Newbie:next()
    if self.sprite then return end
    self.count = self.count + 1
    self:start()
end

-- 当前是否有新手引导
function Newbie:isNewbie()
    return self.guideData[self.count] ~= nil
end

-- 连线触及的元素是否在引导路径内
function Newbie:isNewbieGrid(i,x,y)
    if self.guideData[self.count] then
        if i > #self.guideData[self.count] then
            return true
        end 

        local pos = self.guideData[self.count][i]
         if x == pos.x and y == pos.y then
            return true
         end  
    end
    return false
end

-- 启动新手引导
function Newbie:start()

    local function run(sprite,array)
        local sequence = cc.Sequence:create(array)
        sprite:runAction(sequence)
    end
    -- self:clear()

    if #self.guideData > 0  and self.count <= #self.guideData then
        
        local guide = self.guideData[self.count]

        local sprite =  ccui.Scale9Sprite:createWithSpriteFrameName("ui/finger" .. PNG)
        local pos = guide[1]
        sprite:setAnchorPoint(0,1)
        sprite:setPosition(pos.x * Config.Grid_MAX_Pix_Width,pos.y * Config.Grid_MAX_Pix_Height)
        self.effectLayer:addChild(sprite)

        local array = {cc.DelayTime:create(Config.Newbie_Move_Delay)}
        for i = 1,#guide do
            local pos = guide[i]
            array[#array + 1] = cc.MoveTo:create(Config.Newbie_Move_Delay,cc.p(pos.x * Config.Grid_MAX_Pix_Width,pos.y * Config.Grid_MAX_Pix_Height))
        end

        array[#array + 1] = cc.DelayTime:create(Config.Newbie_Move_Delay)
       array[#array + 1] = cc.CallFunc:create(function() 
            sprite:setPosition(pos.x * Config.Grid_MAX_Pix_Width,pos.y * Config.Grid_MAX_Pix_Height)
            run(sprite,array) 
        end)

        self.sprite= sprite
        -- self.sprite:setOpacity(1)
        -- local sequence = cc.Sequence:create(cc.FadeTo:create(1,255),cc.CallFunc:create(function() run(sprite,array) end))
        -- self.sprite:runAction(sequence)
        run(sprite,array)
    else
       -- self.guideData[self.count] = nil
       
    end
end

-- 清除新手引导
function Newbie:clear()
    if self.sprite then
        self.sprite:removeFromParent(true)
        self.sprite = nil
    end
end


return Newbie