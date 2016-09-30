
-- package.path = package.path .. ";src/"
cc.FileUtils:getInstance():addSearchPath("src")
require "cocos.init"
device = require("game.util.device")

--SceneManager = require("game.manager.SceneManager")


--CC_USE_DEPRECATED_API = true

DATA_DESIGN_WIDTH = 852
DATA_DESIGN_HEIGHT = 1136
FRAME_RATE = 60
INTERNAL_VERSION_NUM = 0
INTERNAL_VERSION = "1.0.0"

local GameMgr = require("GameMgr")
-- cclog
local cclog = function(...)
    print(string.format(...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
    return msg
end

local function main()

    collectgarbage("collect")           -- 执行一轮完整的垃圾收集周期，收集并释放所有不可到达的对象
    collectgarbage("setpause", 100)     -- 设置Lua垃圾回收结束后不等待,马上开始下一轮的回收(默认值是200%，表示使用到当前2倍内存是启用垃圾回收)
    collectgarbage("setstepmul", 5000)  -- 设置Lua垃圾回收工作的速度，Lua垃圾收集是增量收集机制，如果这个值很大，会变成非增量式收集(默认值是200%)

    local director = cc.Director:getInstance()
    --set FPS. the default value is 1.0/60 if you don't call this
    director:setAnimationInterval(1.0 / FRAME_RATE)
    
    director:getOpenGLView():setDesignResolutionSize(DATA_DESIGN_WIDTH, DATA_DESIGN_HEIGHT, cc.ResolutionPolicy.FIXED_HEIGHT)
    

    if device.platform == "windows" then
        cc.Director:getInstance():setDisplayStats(true)
        -- cc.FileUtils:getInstance():setWritablePath(cc.FileUtils:getInstance():getWritablePath().."save/")
    end
 
   
    --创建游戏
    local scene = require("game.view.update.update"):create()
   --[[ director:setDepthTest(false)
    if director:getRunningScene() then
        director:replaceScene(scene)
    else
        director:runWithScene(scene)
    end ]]
   director:replaceScene(scene)
   GameMgr:Init()



    --创建游戏
    -- SceneManager.changeScene("game.view.scene.LoadScene")
    --SceneManager.changeScene("game.view.update.update")

   --[[ local paths = {}
    paths[#paths+1] = device.writablePath.."src"
    paths[#paths+1] = device.writablePath.."res"
    paths[#paths+1] = device.writablePath
    cc.FileUtils:getInstance():setSearchPaths(paths)
    cc.FileUtils:getInstance():addSearchPath("src")
    cc.FileUtils:getInstance():addSearchPath("res")
    cc.FileUtils:getInstance():addSearchPath("")

    local gameInstance = require("GameInstance")
    local game = gameInstance.create()
    game:startUp({})

   if device.platform=="ios" or device.platform == "ipad" then
       local AppStorPayment = require("sdk.AppStorPayment")
       AppStorPayment:init()
   end
    GameMgr:Init()]] 
    
end


local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
--   debug.traceback()
end



