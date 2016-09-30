--[[--

针对 cc.Layer 的扩展

]]

local Layer = cc.Layer

--[[--

在层上注册触摸监听

@param function listener 监听函数

@return Layer 当前层

]]
function Layer:onTouch(listener)
    if USE_DEPRECATED_EVENT_ARGUMENTS then
        self:addNodeEventListener(c.Csbs.NODE_TOUCH_EVENT, function(event)
            return listener(event.name, event.x, event.y, event.prevX, event.prevY)
        end)
    else
        self:addNodeEventListener(c.Csbs.NODE_TOUCH_EVENT, listener)
    end
    return self
end

--[[--

设置层的触摸是否打开

@param boolean enabled 是否打开触摸

@return Layer 当前层

]]
function Layer:enableTouch(enabled)
    self:setTouchEnabled(enabled)
    return self
end

--[[--

在层上注册键盘监听

@param function listener 监听函数

@return Layer 当前层

]]
function Layer:onKeypad(listener)
    if USE_DEPRECATED_EVENT_ARGUMENTS then
        self:addNodeEventListener(c.KEYPAD_EVENT, function(event)
            return listener(event.name)
        end)
    else
        self:addNodeEventListener(c.KEYPAD_EVENT, listener)
    end
    return self
end

--[[--

设置层的键盘事件是否打开

@param boolean enabled 是否打开键盘事件

@return Layer 当前层

]]
function Layer:enableKeypad(enabled)
    self:setKeypadEnabled(enabled)
    return self
end

--[[--

在层上注册重力感应监听

@param function listener 监听函数

@return Layer 当前层

]]
function Layer:onAccelerate(listener)
    if USE_DEPRECATED_EVENT_ARGUMENTS then
        self:addNodeEventListener(c.ACCELERATE_EVENT, function(event)
            return listener(event.x, event.y, event.z, event.timestamp)
        end)
    else
        self:addNodeEventListener(c.ACCELERATE_EVENT, listener)
    end
    return self
end

--[[--

设置层的重力感应事件是否打开

@param boolean enabled 是否打开加速度事件

@return Layer 当前层

]]
function Layer:enableAccelerometer(enabled)
    self:setAccelerometerEnabled(enabled)
    return self
end


