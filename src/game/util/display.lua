

local display = display or {}

--[[创建遮罩层
]]
function display.createMaskLayer(rect,layerOpacity,delay,touchCallback,url)
    local layer = cc.Layer:create()
    layer:setContentSize(cc.size(rect.width,rect.height))
    local sprite
    -- if(not url)then 
    --     sprite = cc.LayerColor:create(cc.c4b(0,0,0,150))
    -- else 
        sprite = ccui.Scale9Sprite:createWithSpriteFrameName(url or Picture.RES_DIALOG_BG_PNG)
    -- end
    sprite:setContentSize(cc.size(rect.width,rect.height))
    sprite:setAnchorPoint(0,0)
    sprite:fadeTo(delay or 0.5,layerOpacity or 255)
    layer:setTouchEnabled(true)
    layer:addChild(sprite)
    layer.sprite = sprite

    layer:setTouchHandler(nil, nil, function(eventType,x,y)  
        if touchCallback~=nil then touchCallback(x,y) end
    end)
    return layer
end

--[[创建ui
]]
function display.createUI(uiName)
    return cc.CSLoader:createNode(uiName)
end

--[[由动画编辑器创建的Animation
    _bool 是否不循环动作的动作
    _remove 是否自动释放
]]
function display.createEffect(_fileName, _actionName, _funCallBack, _remove, _bLoopType, _bool)
    local function eventCallFunc(_armature, _movementType, _movementID)
        local eventType = ccs.MovementEventType.loopComplete
        if _bLoopType then eventType = ccs.MovementEventType.complete end

        if _movementType == eventType and _movementID == _actionName then
        -- if _movementID == _actionName then
            if _funCallBack ~= nil then _funCallBack(_armature) end
            if _remove==nil or _remove then
                _armature:getAnimation():stop()
                _armature:removeFromParent()
                -- display.removeArmature(_armature.fullPath)
            end
        end
    end
    return display.createArmature({path=Prefix.PRES_EFFECT.._fileName.."/".._fileName,bool=_bool or true}, _actionName, eventCallFunc)
end

--[[由动画编辑器创建的Animation
    _tPath {path=路径, key=键名, png=指定png, plist=指定plist, bool=特殊}
    _action 播放的动画帧名字 可string 和 int
    _funAnimationEvent 动画事件回调 function(CCArmature _armature, MovementEventType _movementType, string _movementID) end
    _funAnimationFrameEvent 动画真事件回调 function(CCBone _bone, string _evt, int _originFrameIndex, int _currentFrameIndex)
]]
function display.createArmature( _tInfo, _action, _funMovementEvent, _funFrameEvent )
    local key = _tInfo.key ~= nil and _tInfo.key or io.pathinfo(_tInfo.path).filename

    if(png == nil)then
        if(not _tInfo.bool)then
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(_tInfo.path..CSB)
        else
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(_tInfo.path.."0"..PNG, _tInfo.path.."0"..PLIST , _tInfo.path..CSB)
        end 
    else 
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(_tInfo.png..PNG, _tInfo.plist..PLIST, _tInfo.path..CSB)
    end
    local armature = ccs.Armature:create(key)
    local animation = armature:getAnimation()
    armature.fullPath = _tInfo.path..CSB
    if(_funMovementEvent ~= nil)then animation:setMovementEventCallFunc(_funMovementEvent) end
    if(_funFrameEvent ~= nil)then animation:setFrameEventCallFunc(_funFrameEvent) end
    if(_action ~= nil)then
        if(type(_action) == "string")then 
            animation:play(_action)
        else
            animation:playWithIndex(_action)
        end 
    end
    return armature
end
function display.removeArmature( _name )
    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo( _name )
end

return display