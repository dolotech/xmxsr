-- 游戏入口

require_ex("sdk.DPayCenter")
require("sdk.Talkingdata")
require("sdk.PushService")
require("game.const.ConstData")
require("game.const.ResPath")

require("game.data.ConfigData")
require("game.data.SoundData") 
require("game.data.ColorData")
require("game.data.CsbsData")
require("game.data.PictureData")
require("game.data.ItemIndexData")
require("game.data.ServerCodeData")
require("game.data.DirtyWord")
--require("src.sdk.umengInterFace")

require("game.util.init")
--游戏单例
local GameInstance = class("GameInstance")
--创建游戏
function GameInstance.create()
    GameInstance = GameInstance.new()
    return GameInstance
end

--启动游戏
function GameInstance:startUp( _param )
    --舞台宽度
    stageWidth = cc.Director:getInstance():getWinSize().width
    --舞台高度
    stageHeight = cc.Director:getInstance():getWinSize().height
    --居中距离
    offSetX = (stageWidth-Config.DATA_DESIGN_WIDTH)/2
    
    -- 防止各种隐性bug，不能注释下面这行
    --setmetatable(_G,{__index = function (n) error("你访问的全局变量为nil") end,__newindex = function (n) cclog(debug.traceback()) error("最好不要保存为全局变量") end})
    cc.SpriteFrameCache:getInstance():addSpriteFrames("ui01.plist","ui01.png")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("ui02.plist","ui02.png")
    SharedManager:start()
    
    local function luaFunctionId(str)
        local value = string.split(str, "_")
        local type = value[1]
        local result = value[2]
        local txt = nil
        if "off" == type then
            Audio.bgm = 0
            Audio.sound = 0
            Audio.stopAllSounds()
            Audio.stopMusic()
        elseif "open" == type then
            Audio.bgm = 1
            Audio.sound = 1
        end
        SharedManager:saveData("bgm", Audio.bgm, true)
        SharedManager:saveData("sound", Audio.sound, true)
    end
    
    if(DPayCenter.platform == "gamesample" and device.platform == "android" ) then
        local luaj = require("cocos.cocos2d.luaj")
        local javaClassName = "org.cocos2dx.lua.AppActivity"
        local javaMethodName = "isMusicEnabledOFF"
        local sig = "(I)I"
        local args ={luaFunctionId}
        luaj.callStaticMethod(javaClassName, javaMethodName, args, sig)
    end
end

--返回类
return GameInstance
