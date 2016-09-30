
--加载dramaScne类
local dramaScene = class("dramaScene",function()
    return require("game.view.base.BaseScene"):create()
end)

function dramaScene:create(param)
    local scene = dramaScene.new(param)
    return scene
end

--[[
--判断是否进入剧情动画
local events = SharedManager:readData(Config.Events)
local _index = events["city"] or 0
if _index == 0 then
end

]]
--构建函数
function dramaScene:ctor(param)
    self.nextIndex          =   2       -- 下一次播放的动画ID
    self.waitTime           =   0       -- 等待的时间
    self.WAITMAX            =   2       -- 每次等待的时间
    self.aniMax             =   9       -- 总共的动画个数
    self.scheduerHandle     =   nil     -- 计时器ID
    self.animation          =   nil     -- 动画
    self.isEnd              =   false   -- 是否播完

    local armature = display.createArmature({path="drama/Gushidonghua"},"Animation1",nil,function ( bone, evt, originFrameIndex, currentFrameIndex )
            -- print("========event======= ", evt, currentFrameIndex, originFrameIndex, self.nextIndex)
            if evt == "end" then -- 判断帧事件名称是否为kill
                self.waitTime = self.WAITMAX
                if self.nextIndex > self.aniMax then
                    self.isEnd = true
                end
            end
        end)
    local animation = armature:getAnimation()
    self:addChild(armature)
    armature:setPosition(0,0) 
    self.aniMax  = armature:getAnimation():getMovementCount() -- 获取动作列表数量
    self.animation = animation

    local layer = self:createTouchLayer( function() self:playeNextAni() end) -- 触摸结束后切换动画
    self:addChild(layer)

    -- 添加计时器
    local id  = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
            function(dt)
                if self.waitTime <= 0 then return end
                self.waitTime = self.waitTime - dt
                if self.waitTime <= 0 then
                    if self.isEnd then
                        self:init() -- performWithDelay(n, function () self:init() end, 0.001)
                    else
                        self:playeNextAni()
                    end
                end
            end
            ,0, false)

    self:registerScriptHandler(function(event)
        if event == 'exit' then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(id)
            display.removeArmature(armature.fullPath)
        end
    end)

end

function dramaScene:onExit()
end

--更新完成正式初始化游戏
function dramaScene:init()
    -- local gameInstance = require("GameInstance")
    -- local game = gameInstance.create()
    -- game:startUp({imgBar = self.imgBar})

    SceneManager.changeScene("game.view.scene.CityScene",nil,function(scene)
        return cc.TransitionFade:create(0.6, scene)
    end)
end

function dramaScene:playBgMusic()

end

function dramaScene:playeNextAni()
    if self.isEnd then return end

    if self.nextIndex > self.aniMax then return end

    self.animation:play("Animation"..tostring(self.nextIndex))
    -- print("=========== nextIndex ", self.nextIndex)
    self.nextIndex = self.nextIndex + 1
    self.waitTime = 0
end


function dramaScene:createTouchLayer(touchCallback)
    local layer = cc.Layer:create()
    layer:setTouchEnabled(true)
    layer:setTouchHandler(nil,nil,function(eventType,x,y)
        if touchCallback~=nil then touchCallback(x,y) end
    end)
    return layer
end


return dramaScene
