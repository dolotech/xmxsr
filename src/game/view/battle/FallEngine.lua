-- 道具下落引擎
local Vector2D = require("game.util.Vector2D")
local FallEngine = class("FallEngine",function () return cc.Node:create() end)
local AlgorithmFall= require("game.view.battle.algorithm.AlgorithmFall")
local Widget = require("game.view.battle.Widget")
local BattleEvent = require("game.view.battle.BattleEvent")
local socket = require("socket")

local GAP = (1000/Config.FRAME_RATE)/1000

function FallEngine:create(elements,widgets,layerData,widgetLayer)
    local instance = FallEngine.new(elements,widgets,layerData,widgetLayer)
    return instance
end

function FallEngine:ctor(elements,widgets,layerData,widgetLayer)
    self.elements = elements
    self.data = layerData
    self.widgets = widgets
    self.widgetLayer = widgetLayer
    self.clock = socket.gettime()
    self.playing = true
    self.droping = false
    
    -- 左下角掉落加速度向量
    self.downLeftGravity = Vector2D.new(-Config.Grid_MAX_Pix_Width,-Config.Grid_MAX_Pix_Height)
    self.downLeftGravity:setLength(Widget.Gracity)
    -- 右下角掉落加速度向量
    self.downRightGravity = Vector2D.new(Config.Grid_MAX_Pix_Width,-Config.Grid_MAX_Pix_Height)
    self.downRightGravity:setLength(Widget.Gracity)
    -- 正下方掉落加速度向量
    self.downGravity = Vector2D.new(0,-Widget.Gracity)
    
    self:addEventListener(BattleEvent.RESUME ,handler(self,self.onPlaye))
    self:addEventListener(BattleEvent.PAUSE ,handler(self,self.onPause))
end

function FallEngine:onPlaye()
    self.playing = true
end

function FallEngine:onPause()
    self.playing = false
end


-- 帧頻检测道具掉落
function FallEngine:onEnterFrame()
    if not self.playing then return end

    if not self.droping then
        if(self.isSendStop)then return end
        self:stop()
        self:dispatchEvent(BattleEvent.ENGINE_STOP)
    else 
        local clock = socket.gettime()
        local gapTime = clock - self.clock
        local scale =gapTime/GAP 
        self.droping = false
        -- 生成道具
        self:generateWidget() 
        local data = self.data.data
        local len = #data 
        for i=1,len do
            local v = data[i]
            local widgetData = v.widget
            if widgetData and widgetData.pang == nil and  widgetData.eliminate.fall == 1 then
                local widget = self.widgets[widgetData]
                if widget.isFalling then         --不在掉落状态的道具不启用帧頻驱动
                    self.droping  = true
                    widget:onEnterFrame(scale)        -- 正在下落的道具，需要掉落驱动
                    -- 到达掉落目标点，继续下轮掉落，不把速度置零，保持道具连续的加速度掉落
                    if widget.y <= widget.targetY  then    
                        -- widget:setPosition(widget.targetX,widget.targetY)     
                        self:contineFall(widget,true)
                    end
                else      
                    self:contineFall(widget,false)
                end
            end
        end  
        self.clock = clock
    end 
end

-- 智能生成道具
function FallEngine:generateWidget()
    self.data:generateForFirstLine()
    for k,elementData in pairs(self.data.generateElementDatas) do
        if elementData.widget ~= nil then
            local widget = Widget:create(elementData.widget)
            widget:setPosition(elementData.x * Config.Grid_MAX_Pix_Width,elementData.y * Config.Grid_MAX_Pix_Height)
            self.widgetLayer:addChild(widget)
            self.widgets[elementData.widget] = widget
        end
    end
end

function FallEngine:swap(widgetData,nextElementData)
    local elementData = widgetData.element
    elementData.widget = nil
    nextElementData.widget = widgetData
    widgetData.x = nextElementData.x
    widgetData.y = nextElementData.y
    widgetData.element = nextElementData
end

function FallEngine:contineFall(widget,isDroping)
    local widgetData = widget.data
    
    local nextElementData = AlgorithmFall.isFallDown(widgetData,self.data)
    if  nextElementData ~= nil then
        self:swap(widgetData,nextElementData)
        widget:setGravity(self.downGravity)
        self.droping = true
    else
        nextElementData = AlgorithmFall.isFallDownLeft(widgetData,self.data)
        if  nextElementData ~= nil then
            self:swap(widgetData,nextElementData)
            widget:setGravity(self.downLeftGravity)
            self.droping = true
        else
            nextElementData = AlgorithmFall.isFallDownRight(widgetData,self.data)
            if  nextElementData ~= nil then
                self:swap(widgetData,nextElementData)
                widget:setGravity(self.downRightGravity)
                self.droping = true
            else
                widget:reset()   
                -- 下落完成，播放抖动动作
                
                if isDroping then
                    widget:bubble()
                end
            end
        end   
    end     
end


function FallEngine:start( _isSendStop )
    if self.entryID == nil then
        self.clock = socket.gettime()
        self.isSendStop = _isSendStop
        self.droping = true
        self.entryID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function () self:onEnterFrame() end,1.0 / Config.FRAME_RATE,false)
    end
end

function FallEngine:stop()
    if self.entryID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.entryID)
        self.entryID = nil
    end
end


return FallEngine