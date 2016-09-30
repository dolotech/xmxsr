--[[--
针对 cc.Button 的扩展

]]
local Widget = ccui.Widget
--音效类
Audio = require("game.audio.Audio")

-------------------------------------按键模型---------------------------------------

--[[--
--封装按钮事件
  touchEndedHandler 点击回调函数
  isSingle          布尔值是否单状态 如果是执行缩放
]]

function Widget:onClick(touchEndedHandler,isSingle,isSound,url)
    if isSingle==nil then
        isSingle = true
    end
    
    if isSound==nil then
        isSound = true
    end
    
    if url==nil then
        url = Sound.SOUND_UI_MAP_CLICK
    end
    
    if isSingle then
        self.curScale = self:getScale()
    end

    local function touchHandler(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            if isSound then
                Audio.playSound(url)
            end
            if isSingle then
                self:runAction(cc.ScaleTo:create(0.05,self.curScale*0.8,self.curScale*0.8))
            end
        end

        if eventType == ccui.TouchEventType.canceled then
            if isSingle then
                self:runAction(cc.ScaleTo:create(0.05,self.curScale,self.curScale))
            end
        end
        
        if eventType == ccui.TouchEventType.ended then
            if isSingle then
                local function touchHandler()
                    if touchEndedHandler~=nil then
                        self:setScale(self.curScale)
                        touchEndedHandler(sender)
                    end
                end
                self:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05,self.curScale,self.curScale),cc.CallFunc:create(touchHandler)))
            else
                if touchEndedHandler~=nil then
                    touchEndedHandler(sender)
                end
            end
            
        end
    end
    self:addTouchEventListener(touchHandler)
end

--[[--
--封装按钮事件 可以透过操作
  touchEndedHandler 点击回调函数
  isSingle          布尔值是否单状态 如果是执行缩放
]]

function Widget:onClick(touchEndedHandler,isSingle,isSound,url)
    if isSingle==nil then
        isSingle = true
    end
    
    if isSound==nil then
        isSound = true
    end
    
    if url==nil then
        url = Sound.SOUND_UI_MAP_CLICK
    end
    
    if isSingle then
        self.curScale = self:getScale()
    end

    local function touchHandler(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            if isSound then
                Audio.playSound(url)
            end
            if isSingle then
                self:runAction(cc.ScaleTo:create(0.05,self.curScale*0.8,self.curScale*0.8))
            end
        end

        if eventType == ccui.TouchEventType.canceled then
            if isSingle then
                self:runAction(cc.ScaleTo:create(0.05,self.curScale,self.curScale))
            end
        end
        
        if eventType == ccui.TouchEventType.ended then
            if isSingle then
                local function touchHandler()
                    if touchEndedHandler~=nil then
                        self:setScale(self.curScale)
                        touchEndedHandler(sender)
                    end
                end
                self:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05,self.curScale,self.curScale),cc.CallFunc:create(touchHandler)))
            else
                if touchEndedHandler~=nil then
                    touchEndedHandler(sender)
                end
            end
            
        end
    end
    self:addTouchEventListener(touchHandler)
end

-------------------------------------获得实际位置---------------------------------------
--左上
function Widget:rectLT()
    local x, y = self:getPosition()
    local size = self:getContentSize()
    local anchor = self:getAnchorPoint()
    return cc.rect(x-size.width*anchor.x, y+size.height*(1-anchor.y), size.width, size.height)
end
--左下
function Widget:rectLD()
    local x, y = self:getPosition()
    local size = self:getContentSize()
    local anchor = self:getAnchorPoint()
    return cc.rect(x-size.width*anchor.x, y-size.height*anchor.y, size.width, size.height)
end

-------------------------------------button扩展---------------------------------------
function Widget:setButtonEnabled(_isEnabled)
    self:setBright(_isEnabled)
    self:setEnabled(_isEnabled)
end