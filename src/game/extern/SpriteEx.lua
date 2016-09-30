--[[--

针对 cc.Sprite 的扩展

]]

local Sprite = cc.Sprite


--[[--

设置当前精灵的显示帧

@param mixed frame 要显示的图片名或图片帧的frame

@return Sprite 当前精灵

]]
function Sprite:displayFrame(frame)
    self:setSpriteFrame(frame)
    return self
end

--[[--

在X方向上翻转当前精灵

@param boolean b 是否翻转

@return Sprite 当前精灵

]]
function Sprite:flipX(b)
    self:setFlippedX(b)
    return self
end

--[[--

在Y方向上翻转当前精灵

@param boolean b 是否翻转

@return Sprite 当前精灵

]]
function Sprite:flipY(b)
    self:setFlippedY(b)
    return self
end

function Sprite:clone()
    local spr = cc.Sprite:create()
    spr:setSpriteFrame(self:getSpriteFrame())
    spr:setPosition(self:getPosition())
    spr:setAnchorPoint(self:getAnchorPoint())
    spr:setScale(self:getScale())
    spr:setRotation(self:getRotation())
    spr:setOpacity(self:getOpacity())
    return spr
end



