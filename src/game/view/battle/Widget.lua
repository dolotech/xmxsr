-- 游戏战斗道具显示对象
-- 建立了对象池，Widget.Pool
local Widget = class("Widget",function()
    return cc.Node:create()
end)

local Vector2D = require("game.util.Vector2D")
Widget.Gracity = Config.FALL_GRAVITY/Config.FRAME_RATE        -- 掉落加速度
Widget.Velocity = Config.FALL_VELOCITY/Config.FRAME_RATE        -- 掉落加速度
--Widget.Pool = {}

function Widget:create(data)
    local instance = nil
    instance = Widget.new(data)
    instance:setNodeEventEnabled()
    instance.gravity = Vector2D.new(0,0)                -- 掉落加速度-每帧速度叠加值，分母是帧蘋
    instance.velocity = Vector2D.new(0,0)               -- 掉落初始，分母是帧蘋
    instance.velocity:setLength(Widget.Velocity)        
    return instance
end

function Widget:light() 
    self.eliminate:light()
end

function Widget:unLight() 
    self.eliminate:unLight()
end

function Widget:setOpacity(value)
    self.eliminate:setOpacity(value)
    if self.data.pang ~= nil then
        self.pang:setOpacity(value)
    end
end


function Widget:ctor(data)
    self.data = data
    if self.eliminate == nil then
        self.eliminate = Goods:create(self.data.eliminate)
        self:addChild(self.eliminate)
    else
        self:updateEliminate() 
    end
   self.isFalling = false
   self:updatePang()
end


function Widget:updateEliminate(saveState)

    local light = self.eliminate.lightState
    if self.data.eliminate ~= nil then
        self.eliminate:reset(self.data.eliminate)
    else
    end

    if saveState and light then
        self.eliminate:light()
    end
end

function Widget:updatePang()
    if self.data.pang ~= nil then
        if self.pang == nil then
            self.pang = Goods:create(self.data.pang)
            self:addChild(self.pang)
        else
            self.pang:reset(self.data.pang)
        end
    else
        if self.pang then 
            self.pang:removeFromParent(true) 
            self.pang = nil
        end
    end
end


function Widget:bubble(callback)
    if self.bubblling or self.data.eliminate.type > 5 then
        return
    end
    
    self.bubblling = true
    
    local function onComplete()
        self.bubblling = false
        if callback then
            callback()
        end
        self:stopAction(self.bubbleAction)
    end
    
    local qequence = cc.Sequence:create(cc.ScaleTo:create(0.07,1.2,0.8),
                                        cc.ScaleTo:create(0.09,0.9,1.1),
                                        cc.ScaleTo:create(0.12,1.1, 0.95),
                                        cc.ScaleTo:create(0.11,0.93,1.13),
                                        cc.ScaleTo:create(0.12,1.05,0.97),
                                        cc.ScaleTo:create(0.13,0.95,1.03),
                                        cc.ScaleTo:create(0.15,1.0,1.0),
                                        cc.CallFunc:create(onComplete))
    self.bubbleAction = self:runAction(qequence)
end

-- 帧頻驱动掉落加速运算
function Widget:onEnterFrame(scale)   

        if self.y == self.targetY then return end
        self.velocity.x =  self.velocity.x + self.gravity.x 
        self.velocity.y =  self.velocity.y + self.gravity.y
        self.x = self.x + (self.velocity.x * scale)
        self.y = self.y + (self.velocity.y * scale)

        if self.y < self.targetY then
            self.y = self.targetY
            self.x = self.targetX
        end
        self:setPosition(self.x,self.y)  
end


function Widget:setGravity(currentGravity)
    local x,y = self:getPosition()
    self.originalx = x
    self.originaly = y
    self.x = x
    self.y = y
   
    local angle = currentGravity:getAngle()
    if self.gravity.x == 0 and self.gravity.y == 0 then
        self.gravity.x = currentGravity.x
        self.gravity.y = currentGravity.y
        self.velocity:setAngle(angle)
    else
        self.velocity:setAngle(angle)
        self.gravity:setAngle(angle)
    end
    
    if currentGravity.x > 0 then
        self.targetX = x + Config.Grid_MAX_Pix_Width
    elseif currentGravity.x < 0 then
        self.targetX = x - Config.Grid_MAX_Pix_Width
    else
        self.targetX = x 
    end
   
    self.targetY = y - Config.Grid_MAX_Pix_Height
    self.isFalling = true
end

function Widget:reset()
    self.originalx = 0          -- 掉落前的X位置，用于掉落完成位置矫正
    self.originaly = 0          -- 掉落前的Y位置，用于掉落完成位置矫正
    self.targetX = 0            -- 掉落目标X位置
    self.targetY = 0            -- 掉落目标X位置
    self.x = 0                  -- 实时记录位置X，避免重复获取getPositionX,提升性能
    self.y = 0                  -- 实时记录位置Y，避免重复获取getPositionX,提升性能
    self.isFalling = false      -- 记录当前是否处于掉落状态,不在掉落状态的道具不启用帧頻驱动
    self.gravity.x = 0
    self.gravity.y = 0
    self.velocity:setLength(Widget.Velocity)
end

function Widget:onEnter()
    self:reset()
    
    self.bubblling = false
end

function Widget:onExit()

end

-- 从舞台移除调用本方法，放入对象池下次重用
function Widget:remove()
    self:removeFromParent(true)
end

return Widget

