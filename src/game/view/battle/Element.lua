-- 游戏战斗格子显示对象

local Element = class("Element",function(data)
    return cc.Node:create()
end)
local Goods = require("game.view.battle.Goods")
    
function Element:create(data)
    local instance = Element.new(data)
    instance:setNodeEventEnabled()
    instance.vBlock = nil           --纵向格挡
    instance.hBlock = nil           -- 横向格挡
    instance.block = nil            -- 障碍物（占用元素格不可被清除）
    
    return instance
end

function Element:onTouch(eventType, x, y)
    if eventType == "began" then 
--        return self:ccTouchBegan(x,y); 
    elseif eventType == "moved" then 
--        return self:ccTouchMoved(x,y); 
        print("self:ccTouchMoved")
    else 
--        return self:ccTouchEnded(x,y);
    end 
end
 
    
function Element:ctor(data)
    self.data = data

end


function Element:onExit()
   
end


function Element:setOpacity(value)
    if self.data.block ~= nil then
        self.block.setOpacity(value)
    end

    if self.data.vBlock ~= nil then
        self.hBlock.setOpacity(value)
    end

    if self.data.hBlock ~= nil then
        self.vBlock.setOpacity(value)
    end  
end

function Element:updateVBlock()
    if self.vBlock ~= nil then
        self:removeChild(self.vBlock,true)
    end

    if self.data.vBlock ~= nil then
        local goods = Goods:create(self.data.vBlock)
        self:addChild(goods)
        self.vBlock = goods
    end
end


function Element:updateHBlock()
    if self.hBlock ~= nil then
        self:removeChild(self.hBlock,true)
    end

    if self.data.hBlock ~= nil then
        local goods = Goods:create(self.data.hBlock)
        self:addChild(goods)
        self.hBlock = goods
    end
end

function Element:onEnter()
    
    -- 显示不可消除的障碍
    if self.data.block ~= nil then
        local goods = Goods:create(self.data.block)
        self.block = goods
        self:addChild(goods)
    end
    
    if self.data.vBlock ~= nil then
        local goods = Goods:create(self.data.vBlock)
        self.vBlock = goods
        self:addChild(goods)
    end
    
    if self.data.hBlock ~= nil then
        local goods = Goods:create(self.data.hBlock)
        self.hBlock = goods
        self:addChild(goods)
    end  
end
return Element