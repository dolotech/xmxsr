--log场景
local loginScene = class("LoginScene",function()
    return cc.Scene:create()
end)

function loginScene:create(param)
    local scene = loginScene.new(param)
    return scene
end

--构建函数
function loginScene:ctor(param)
    local logo = cc.Sprite:create("ui/picture/logo.jpg")
    logo:stageCenter()
    self:addChild(logo)
end

return loginScene
