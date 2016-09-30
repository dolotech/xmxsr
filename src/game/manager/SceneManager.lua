-- 场景管理器

local SceneManager = class("SceneManager")

if SceneManager.scene==nil then
    SceneManager.scene = {}
end


--切换场景
function SceneManager.changeScene(_sceneName, _param, _funEffect)

    if DialogManager ~= nil then
        if DialogManager.dialog ~=nil then
            DialogManager.dialog = {}
        end
        if DialogManager.mask ~=nil then
            DialogManager.mask = {}
        end
    end
    
    local scene = require(_sceneName):create(_param)
    SceneManager.currentScene = scene
    cc.Director:getInstance():setDepthTest(false)
    if(_funEffect~=nil)then scene = _funEffect(scene) end
    --scene = cc.TransitionFade:create(0.1, scene)
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(scene)
    else
        cc.Director:getInstance():runWithScene(scene)
    end
    --SceneManager.renmoveCache()
end

--清除缓存切换界面后
function SceneManager.renmoveCache()
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    -- cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
--    cc.Director:getInstance():getActionManager():removeAllActions()
--    cc.Director:getInstance():getScheduler():release()
--    cc.Director:getInstance():getEventDispatcher():release()
    
end

return SceneManager
