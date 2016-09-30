
-- 说话精灵
local SpeakElves = class("SpeakElves",function()
    return display.createUI("node_speak_base.csb")
end)

function SpeakElves:create()
    local ui = SpeakElves.new()
    ui:setNodeEventEnabled()
    return ui
end

--进入
function SpeakElves:onEnter()
    self.imgbg = self:getChildByName("imgbg")
    self.imgbg.loc = cc.p(self.imgbg:getPosition())
    self.imgbg.size = self.imgbg:getContentSize()
    self.label = self.imgbg:getChildByName("label")
    -- Color.setLableShadow(self.label)
    self:setVisible(false)
    self:setAnchorPoint(0.5,0)
end

--战斗提示说话
function SpeakElves:speak(text)
    self.label:setString(text)
    local x = -(self.imgbg.loc.x+self.imgbg.size.width)
    local y = stageHeight/2 + self.imgbg.size.height + 50
    self:setPosition(x, y)
    local inMoveTo = cc.EaseBackIn:create(cc.MoveTo:create(0.6,cc.p(10,y)))
    local inSqe = cc.Sequence:create(inMoveTo,cc.DelayTime:create(1),cc.CallFunc:create(function()self:backSpeak()end))
    self:stopAllActions()
    self:runAction(inSqe)
    self:setVisible(true)
end

--返回
function SpeakElves:backSpeak()
    local x = -(self.imgbg.loc.x+self.imgbg.size.width)
    local y = stageHeight/2 + self.imgbg.size.height + 50
    local backMoveTo = cc.EaseBackIn:create(cc.MoveTo:create(0.5,cc.p(x,y)))
    local backSqe = cc.Sequence:create(backMoveTo,cc.CallFunc:create(function()self:setVisible(false)end))
    self:runAction(backSqe)
end

--提示(固定宽度)
function SpeakElves:openHint( _msg, _loc, _width, _height )
    self.label:setString(_msg)
    local w = _width or self.imgbg.size.width

    self.imgbg:setPositionX(-(self.imgbg.loc.x+w)/2)
    self.imgbg:setContentSize(w, self.imgbg.size.height)
    self.label:setContentSize(w-130, self.label:getContentSize().height)
    self:setPosition(_loc.x,_loc.y)
    self:setVisible(true)

    self:setScale(0.2)
    local sequence = cc.Sequence:create(
        cc.ScaleTo:create(0.15,0.6,1.5),
        cc.ScaleTo:create(0.1,1.2,0.6),
        cc.ScaleTo:create(0.1,0.8,1.2),
        cc.ScaleTo:create(0.1,1.0,1.0)
        )
    self:stopAllActions()
    self:runAction(sequence)
end
function SpeakElves:closeHint()
    self:setVisible(false)
end

return SpeakElves
