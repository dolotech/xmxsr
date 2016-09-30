-- 淤泥
local  Widget = require("game.view.battle.Widget") 
local BattleEvent = require("game.view.battle.BattleEvent")
local Sludge = class("Sludge",Widget)

local Vector2D = require("game.util.Vector2D")

function Sludge:create(widgetData)
    local instance = Sludge.new(widgetData)

    instance:setNodeEventEnabled()
    instance.gravity = Vector2D.new(0,0)                -- 掉落加速度-每帧速度叠加值，分母是帧蘋
    instance.velocity = Vector2D.new(0,0)               -- 掉落初始，分母是帧蘋
    instance.velocity:setLength(Widget.Velocity)    

    return instance
end

function Sludge:fallComlete()

end

function Sludge:ctor(data)
    self.data = data

    if self.eliminate == nil then
        self.eliminate = Goods:create(self.data.eliminate)
        self:addChild(self.eliminate)
    else
        self:updateEliminate() 
    end
    self.isFalling = false
    self:updatePang()

    self:addEventListener(BattleEvent.FALL_COMPLETE,handler(self,self.fallComlete))
end

return Sludge