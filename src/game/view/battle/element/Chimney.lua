-- 烟囱
local  Widget = require("game.view.battle.Widget") 
local BattleEvent = require("game.view.battle.BattleEvent")
local Chimney = class("Chimney",Widget)

local Vector2D = require("game.util.Vector2D")

function Chimney:create(widgetData,getDataByGridXY)
    local instance = Chimney.new(widgetData,getDataByGridXY)
    
    instance:setNodeEventEnabled()
    instance.gravity = Vector2D.new(0,0)                -- 掉落加速度-每帧速度叠加值，分母是帧蘋
    instance.velocity = Vector2D.new(0,0)               -- 掉落初始，分母是帧蘋
    instance.velocity:setLength(Widget.Velocity)    

    return instance
end

function Chimney:fallComlete()
    if self.round == 1 then
        self.data.eliminate = clone(GoodsData[tostring(28)])
        self:updateEliminate()  
    end
    
    if self.data.eliminate.widgetID == 113 then
        self.round = 0
    end
    
    self.round = self.round + 1
end


function Chimney:ctor(data,getDataByGridXY)
    self.data = data
    self.getDataByGridXY = getDataByGridXY

    if self.eliminate == nil then
        self.eliminate = Goods:create(self.data.eliminate)
        self:addChild(self.eliminate)
    else
        self:updateEliminate() 
    end
    self.isFalling = false
    self:updatePang()
   
    self:addEventListener(BattleEvent.FALL_COMPLETE,handler(self,self.fallComlete))
    self.round = 0
end

return Chimney