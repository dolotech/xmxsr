-- 吃豆人
local  Widget = require("game.view.battle.Widget") 
local BattleEvent = require("game.view.battle.BattleEvent")
local PacMan = class("PacMan",Widget)

local Vector2D = require("game.util.Vector2D")

function PacMan:create(widgetData,autoBubble,widgets,widgetLayer)
    local instance = PacMan.new(widgetData,autoBubble,widgets,widgetLayer)
    
    instance:setNodeEventEnabled()
    instance.gravity = Vector2D.new(0,0)                -- 掉落加速度-每帧速度叠加值，分母是帧蘋
    instance.velocity = Vector2D.new(0,0)               -- 掉落初始，分母是帧蘋
    instance.velocity:setLength(Widget.Velocity)    

    return instance
end

function PacMan:ctor(data,autoBubble,widgets,widgetLayer)
    self.data = data
    self.autoBubble = autoBubble
    self.widgets = widgets
    self.widgetLayer = widgetLayer
    
    if self.eliminate == nil then
        self.eliminate = Goods:create(self.data.eliminate)
        self:addChild(self.eliminate)
    else
        self:updateEliminate() 
    end
    self.isFalling = false
    self.isNewPacman = true -- 刚生成的不参与行动
    self:updatePang()
    
    self:addEventListener(BattleEvent.ONPACMAN_ACTION,handler(self,self.pacmanAction))
end

-- 吃豆人跳跃
function PacMan:pacmanAction( targetElementData, _func )
    -- local tElements =  self.autoBubble:searchMonstetGoods()
    -- local targetElementData = tElements[math.random(1,#tElements)]
    local originalElementData = self.data.element
    
    local targetWidgetData = targetElementData.widget
    local originalWidgetData = self.data
    originalWidgetData.element = targetElementData
    targetElementData.widget,originalElementData.widget = originalWidgetData,nil
    
    originalWidgetData.x = targetElementData.x
    originalWidgetData.y = targetElementData.y 
   
    local originalWidget = self.widgets[originalWidgetData]
    
    originalWidget:setLocalZOrder(self.widgets[targetWidgetData]:getLocalZOrder()+1)
    local x = targetElementData.x * Config.Grid_MAX_Pix_Width
    local y = targetElementData.y * Config.Grid_MAX_Pix_Height
    
    local function callback(targetWidgetData)
        local targetWidget= self.widgets[targetWidgetData]
        targetWidget:removeFromParent(true)
        self.widgets[targetWidgetData] = nil
        
        if(_func)then _func() end

        -- self.running = false
        -- self:dispatchEvent(BattleEvent.START_ENGINE)
    end
    local midX = (targetElementData.x + originalElementData.x) * Config.Grid_MAX_Pix_Width * 0.5
    local midY = (targetElementData.y + originalElementData.y) * Config.Grid_MAX_Pix_Height * 0.5
    local spawn1 = cc.Spawn:create(cc.ScaleTo:create(0.2, 2.0),cc.MoveTo:create(0.2, cc.p(midX,midY)))
    local spawn2 = cc.Spawn:create(cc.ScaleTo:create(0.2, 1.0),cc.MoveTo:create(0.2, cc.p(x,y)))
    
    local sequence= cc.Sequence:create(spawn1,spawn2,cc.CallFunc:create(handler(targetWidgetData,callback)))
    
    self:runAction(sequence) 
end

return PacMan