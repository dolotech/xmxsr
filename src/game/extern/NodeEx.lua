--[[--

针对 cc.Node 的扩展

]]

local Node = cc.Node
local winSize = cc.Director:getInstance():getWinSize()

local cx                 = winSize.width / 2
local cy                 = winSize.height / 2
local c_left             = -winSize.width / 2
local c_right            = winSize.width / 2
local c_top              = winSize.height / 2
local c_bottom           = -winSize.height / 2
local left               = 0
local right              = winSize.width
local top                = winSize.height
local bottom             = 0

function Node:onEnter()
end

function Node:onExit()
end

function Node:onEnterTransitionFinish()
end

function Node:onExitTransitionStart()
end

function Node:onCleanup()

end


function Node:setNodeEventEnabled()
    self:registerScriptHandler(function(event)
        if "enter" == event then
            self:onEnter()
        elseif "exit" == event then
            self:onExit()
        elseif "cleanup" == event then
            self:onCleanup()
        end
    end
    )
    return self
end

--设置点击事件(只对程序添加生效)
function Node:setTouchEnded(eventHandlerEnd,eventHandlerBegan,eventHandlerMove)
    self.isTouch = false
	local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:registerScriptHandler(function(touch, event)
        local location = touch:getLocation()
        if self:hitTest(cc.p(location.x,location.y))==true then
            self.isTouch = true
            if eventHandlerBegan~=nil then
                eventHandlerBegan()
            end
        end
       
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN )
    -------------------------------------------------------------------
    listenner:registerScriptHandler(function(touch, event)
        if  self.isTouch == true then
            local location = touch:getLocation()
            if self:hitTest(cc.p(location.x,location.y))==true then
                if eventHandlerMove~=nil then
                    eventHandlerMove()
                end
            end
        end
        return true
    end,cc.Handler.EVENT_TOUCH_MOVED )
    -------------------------------------------------------------------
    listenner:registerScriptHandler(function(touch, event)
        if self.isTouch == true then
            self.isTouch = false
            local location = touch:getLocation()
            if self:hitTest(cc.p(location.x,location.y))==true then
                if eventHandlerEnd~=nil then
                    eventHandlerEnd()
                end
            end
        end
        return true
    end,cc.Handler.EVENT_TOUCH_ENDED )
    -------------------------------------------------------------------
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self)
end



-------------------------------------计划，计时---------------------------------------
function Node:schedule(callback, delay)
    local delay = cc.DelayTime:create(delay)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    local action = cc.RepeatForever:create(sequence)
    self:runAction(action)
    return action
end

function Node:performWithDelay(callback, delay)
    local delay = cc.DelayTime:create(delay)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    self:runAction(sequence)
    return sequence
end

-------------------------------------物理碰撞---------------------------------------
local function isPointIn( rc, pt )
    local rect = cc.rect(rc.x, rc.y, rc.width, rc.height)
    return cc.rectContainsPoint(rect, pt)
end
--[[--
测试一个点是否在当前结点区域中
@param tabel point cc.p的点位置,世界坐标
@return boolean 是否在结点区域中
]]
function Node:hitTest(point)
    local nsp = self:convertToNodeSpace(point)
    local rect = self:getBoundingBox()
    if cc.rectContainsPoint(rect, point) then
        return true
    end
    return false
end

-------------------------------------缓动---------------------------------------

-- actions

--[[--

停止结点的所有动作

@return node 当前结点

]]
--function Node:stop()
--    self:stopAllActions()
--    return self
--end

--[[--

渐显动画

@param number time 渐显时间

@return node 当前结点

]]
function Node:fadeIn(time)
    self:runAction(cc.FadeIn:create(time))
    return self
end

--[[--

渐隐动画

@param number time 渐隐时间

@return node 当前结点

]]
function Node:fadeOut(time)
    self:runAction(cc.FadeOut:create(time))
    return self
end

--[[--

渐变到一个固定透明度

@param number time 渐变时间
@param number opacity 最终的透明度

@return node 当前结点

]]
function Node:fadeTo(time, opacity)
    self:runAction(cc.FadeTo:create(time, opacity))
    return self
end

--[[--

在一段时间内移动结点到特定位置

@param number time 移动时间
@param number x 要移动到的X点
@param number y 要移动到的Y点

@return node 当前结点

]]
function Node:moveTo(time, x, y)
    self:runAction(cc.MoveTo:create(time, cc.p(x or self:getPositionX(), y or self:getPositionY())))
    return self
end

--[[--

在一段时间内移动相对位置

@param number time 移动时间
@param number x 要移动的相对X值
@param number y 要移动的相对Y值

@return node 当前结点

]]
function Node:moveBy(time, x, y)
    self:runAction(cc.MoveBy:create(time, cc.p(x or 0, y or 0)))
    return self
end

--[[--

在一段时间内旋转的角度

@param number time 移动时间
@param number rotation 旋转的角度

@return node 当前结点

]]
function Node:rotateTo(time, rotation)
    self:runAction(cc.RotateTo:create(time, rotation))
    return self
end

--[[--

在一段时间内旋转的相对角度

@param number time 移动时间
@param number rotation 旋转的相对角度

@return node 当前结点

]]
function Node:rotateBy(time, rotation)
    self:runAction(cc.RotateBy:create(time, rotation))
    return self
end

--[[--

在一段时间内缩放

@param number time 移动时间
@param number scale 缩放的值

@return node 当前结点

]]
function Node:scaleTo(time, scale)
    self:runAction(cc.ScaleTo:create(time, scale))
    return self
end

--[[--

在一段时间内的相对缩放

@param number time 移动时间
@param number scale 相对缩放的值

@return node 当前结点

]]
function Node:scaleBy(time, scale)
    self:runAction(cc.ScaleBy:create(time, scale))
    return self
end

--[[--

在一段时间内倾斜的大小

@param number time 移动时间
@param number sx 倾斜的X值
@param number sy 倾斜的Y值

@return node 当前结点

]]
function Node:skewTo(time, sx, sy)
    self:runAction(cc.SkewTo:create(time, sx or self:getSkewX(), sy or self:getSkewY()))
    return self
end

--[[--

在一段时间内倾斜的相对大小

@param number time 移动时间
@param number sx 倾斜的相对X值
@param number sy 倾斜的相对Y值

@return node 当前结点

]]
function Node:skewBy(time, sx, sy)
    self:runAction(cc.SkewBy:create(time, sx or 0, sy or 0))
    return self
end

--[[--

在一段时间内染色

@param number time 移动时间
@param number r 染色的R值
@param number g 染色的G值
@param number b 染色的B值

@return node 当前结点

]]
function Node:tintTo(time, r, g, b)
    self:runAction(cc.TintTo:create(time, r or 0, g or 0, b or 0))
    return self
end


--[[--

在一段时间内相对染色

@param number time 移动时间
@param number r 染色的相对R值
@param number g 染色的相对G值
@param number b 染色的相对B值

@return node 当前结点

]]
function Node:tintBy(time, r, g, b)
    self:runAction(cc.TintBy:create(time, r or 0, g or 0, b or 0))
    return self
end

-------------------------------------舞台布局---------------------------------------

--舞台左居中(0,0.5）
function Node:stageLeft(gapx,gapy)
    self:setAnchorPoint(0,0.5)
    self:setPosition(gapx or 0 ,cy + (gapy or 0))
    return self
end

--舞台右居中(1,0.5）
function Node:stageRight(gapx,gapy)
    self:setAnchorPoint(1,0.5)
    self:setPosition(right + (gapx or 0) ,cy + (gapy or 0))
    return self
end

--舞台上居中(0.5,1）
function Node:stageTop(gapx,gapy)
    self:setAnchorPoint(0.5,1)
    self:setPosition(cx + (gapx or 0) ,top + (gapy or 0))
    return self
end

--舞台下居中(0.5,0）
function Node:stageBottom(gapx,gapy)
    self:setAnchorPoint(0.5,0)
    self:setPosition(cx + (gapx or 0) ,(gapy or 0))
    return self
end

--舞台居中(0.5,0.5）
function Node:stageCenter(gapx,gapy)
    self:setAnchorPoint(0.5,0.5)
    self:setPosition(cx + (gapx or 0) ,cy + (gapy or 0))
    return self
end

--舞台左上角对齐（0,1）
function Node:stageLeftTop(gapx,gapy)
    self:setAnchorPoint(0,1)
    self:setPosition(gapx or 0,top + (gapy or 0))
    return self
end

--舞台右上对齐（1,1）
function Node:stageRightTop(gapx,gapy)
    self:setAnchorPoint(1,1)
    self:setPosition(right + (gapx or 0),top + (gapy or 0))
    return self
end

--舞台左下角对齐（0,0）
function Node:stageLeftBottom(gapx,gapy)
    self:setAnchorPoint(0,0)
    self:setPosition(gapx or 0,gapy or 0)
    return self
end

--舞台右下角对齐（1,0）
function Node:stageRightBottom(gapx,gapy)
    self:setAnchorPoint(1,0)
    self:setPosition(right + (gapx or 0),gapy or 0)
    return self
end

-------------------------------------NODE布局---------------------------------------

--添加时根据锚点设置位置
function Node:addChildWithAnchor(node)
    self:addChild(node)
    local anchor = self:getAnchorPoint()
    local size = self:getContentSize()
    node:setPosition(size.width*anchor.x,size.height*anchor.y) 
end

-------------------------------------事件模型---------------------------------------

--监听事件
function Node:addEventListener(eventType,eventHandler)
    local listener = cc.EventListenerCustom:create(eventType, eventHandler)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

--派发事件
function Node:dispatchEvent(eventType,data)
    local eventCustom  = cc.EventCustom:new(eventType)
    eventCustom._userdata = data
    eventCustom._eventName = eventType
    self:getEventDispatcher():dispatchEvent(eventCustom)
end

--派发全局事件
function Node:dipatchGlobalEvent(eventType,data)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    local eventCustom  = cc.EventCustom:new(eventType)
    eventCustom._userdata = data
    eventDispatcher:dispatchEvent(eventCustom) 
end

function Node:removeEventListener(eventType)
    self:getEventDispatcher():removeCustomEventListeners(eventType)
end

-------------------------------------按键模型---------------------------------------

function Node:setTouchHandler( _beganFunc, _movedFunc, _endedFunc )
    local function ccTouchBegan(eventType,x,y) return true end
    local function ccTouchMoved(eventType,x,y) return true end
    local function ccTouchEnded(eventType,x,y)  
        if touchCallback~=nil then touchCallback(x,y) end
    end  
    local function onTouchHandler(eventType,x,y)
        if eventType=="began" then
            if(_beganFunc ~= nil)then return _beganFunc(eventType,x,y)
            else return ccTouchBegan(eventType,x,y)
            end
        elseif eventType=="moved" then
            if(_movedFunc ~= nil)then return _movedFunc(eventType,x,y)
            else return ccTouchMoved(eventType,x,y)
            end
        else
            if(_endedFunc ~= nil)then return _endedFunc(eventType,x,y)
            else return ccTouchEnded(eventType,x,y)
            end
        end
    end
    self:registerScriptTouchHandler(onTouchHandler, false, 0, true) 
end

------------------------------------转换坐标-----------------------------------------------

function Node:getChildByNameFo( ... )
    local list = { ... }
    if(type(list[1]) == "table")then list = list[1] end 
    local node = nil
    for i,v in ipairs(list) do
        if(node == nil)then node = self:getChildByName(v)
        else node = node:getChildByName(v)
        end
        -- print(">>getChildByNameFo:"..v)
    end
    return node
end

function Node:getChildByTagFo( ... )
    local list = { ... }
    if(type(list[1]) == "table")then list = list[1] end 
    local node = nil
    for i,v in ipairs(list) do
        if(node == nil)then node = self:getChildByTag(v)
        else node = node:getChildByTag(v)
        end
    end
    return node
end

function Node:convertToWSAR( _node )
    return self:convertToWorldSpaceAR( cc.p( _node:getPosition() ) )
end
function Node:convertToWS( _node )
    -- print("convertToWS]",self:getPositionX(),self:getPositionY().."  node:",_node:getPositionX(),_node:getPositionY())
    return self:convertToWorldSpace( cc.p( _node:getPosition() ) )
end

------------------------------------窗口-----------------------------------------------

--[[--
打开窗口
@param container
@param 数据
--]]
function Node:open(container,param,_func)
    self.param = param
    self.funOpenCallBack = _func
    container:addChild(self)
    self:stageCenter()
    
    if self.param and self.param.isTween==false then
    	if(self.funOpenCallBack ~= nil)then self.funOpenCallBack() end
    else
        self:openAni(self)
    end
end
function Node:openAni(_node)
    -- local function onComplete()
    -- end 
    local function onMusicPlayer()
        Audio.playSound(Sound.SOUND_UI_HERO_POPUP,false)
    end 
    local n,list = 0,{}
    n=n+1 list[n] = cc.ScaleTo:create(0.2,1.1,1.10)
    n=n+1 list[n] = cc.CallFunc:create(onMusicPlayer)
    n=n+1 list[n] = cc.ScaleTo:create(0.1,0.98,0.98)
    n=n+1 list[n] = cc.ScaleTo:create(0.094,1.02,1.02)
    n=n+1 list[n] = cc.ScaleTo:create(0.094,1.00, 1.00)
    if(self.funOpenCallBack ~= nil)then n=n+1 list[n] = cc.CallFunc:create(self.funOpenCallBack) end
    
    _node:setScale(0.5,0.5)
    _node:runAction(cc.Sequence:create(list))
end

--[[--
关闭窗口
--]]
function Node:close()
    self:dispatchEvent(EVENT_CLOSE_DIALOG,self)
end
