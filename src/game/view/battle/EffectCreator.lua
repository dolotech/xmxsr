-- 战斗内的特效创建

local EffectCreator = class("EffectCreator")

function EffectCreator:createEffect(container,effectName,movementName,x,y)
    local armature = nil
    if effectName ~= nil and effectName ~= "" then
        armature = display.createArmature(
            {path="effect/"..effectName.."/"..effectName,bool=true},
            movementName,function(_armature,_movementType,_movementID) 
            if _movementType == ccs.MovementEventType.complete then
                _armature:getAnimation():stop()
                container:removeChild(_armature,true)
            end  
        end)
        container:addChild(armature)
        armature:setPosition(x,y)
    end
    return armature  
end

return EffectCreator