--基本场景
local BaseScene = class("BaseScene",function()
    return cc.Scene:create()
end)

function BaseScene:create()
    local scene = BaseScene.new()
    
    --游戏背景层
    scene.bgLayer = cc.Layer:create()
    
    --游戏主体层
    scene.gLayer = cc.Layer:create()
    
    --游戏UI层
    scene.uiLayer = cc.Layer:create()
    
    --游戏对话框层
    scene.pLayer = cc.Layer:create()
  
    --游戏特效层
    scene.eLayer = cc.Layer:create()
    
    --游戏角色层
    scene.roleLayer = cc.Layer:create()
    
    scene:addChild(scene.bgLayer)
    scene:addChild(scene.gLayer)
    scene:addChild(scene.roleLayer)
    scene:addChild(scene.uiLayer)
    scene:addChild(scene.pLayer)
    scene:addChild(scene.eLayer)
    
    return scene
end

function BaseScene:addToRoleLayer(child,index)
    if index~=nil then
        self.roleLayer:addChild(child,index)
    else
        self.roleLayer:addChild(child)
    end
end

function BaseScene:addToBgLayer(child,index)
    if index~=nil then
        self.bgLayer:addChild(child,index)
    else
        self.bgLayer:addChild(child)
    end
end

function BaseScene:addToGameLayer(child,index)
    if index~=nil then
        self.gLayer:addChild(child,index)
    else
        self.gLayer:addChild(child)
    end
end


function BaseScene:addToEffectLayer(child,index)
    if index~=nil then
        self.eLayer:addChild(child,index)
    else
        self.eLayer:addChild(child)
    end
end

function BaseScene:addToUILayer(child,index)
    if index~=nil then
        self.uiLayer:addChild(child,index)
    else
        self.uiLayer:addChild(child)
    end
end

function BaseScene:addToDialogLayer(child,index)
    if index~=nil then
        self.pLayer:addChild(child,index)
    else
        self.pLayer:addChild(child)
    end
end

--播放背景音乐
function BaseScene:playMusic(url)
    Audio:playMusic(url,true)
end

--屏幕震动
function BaseScene:shakeScreen( )
    local i, list = 0, {}
    local delay = 0.1 -- 时间
    i=i+1 list[i] = cc.MoveTo:create(delay,cc.p( 0, 6 ))
    i=i+1 list[i] = cc.MoveTo:create(delay,cc.p( 6, 0 ))
    i=i+1 list[i] = cc.MoveTo:create(delay,cc.p( 0, 4 ))
    i=i+1 list[i] = cc.MoveTo:create(delay,cc.p( 4, 0 ))
    i=i+1 list[i] = cc.MoveTo:create(delay,cc.p( 0, 2 ))
    i=i+1 list[i] = cc.MoveTo:create(delay,cc.p( 2, 0 ))
    i=i+1 list[i] = cc.MoveTo:create(delay,cc.p( 0, 1 ))
    i=i+1 list[i] = cc.MoveTo:create(delay,cc.p( 1, 0 ))
        
    self:setPosition(cc.p(0,0))
    self:runAction(cc.Sequence:create(list))
end


return BaseScene;