--友盟分享
--umengInterFace = {}
local umengInterFace = class("LoadScene")

function umengInterFace:openUmeng()
    local function luaFunctionId(event)

    end
    if DPayCenter.isOpenUmeng == false then 
        return
    end
    --self:screen()
   -- self:setShareContent("《消灭小兽人》是一款连线消除+战斗玩法的休閒游戏!","消灭小兽人","mainShareImage","http://www.baidu.com/")
    local luaj = require("cocos.cocos2d.luaj")
    local javaClassName = "org.cocos2dx.lua.AppActivity"
    local javaMethodName = "openShare"
    local sig = "(Ljava/lang/String;II)V"
    local payCode = "dhasda" 
    local args ={tostring(payCode),000,luaFunctionId}
    luaj.callStaticMethod(javaClassName, javaMethodName, args, sig)
end

function umengInterFace:setShareContent(_shareImage,functionId)
    local function luaFunctionId(event)

    end
    if DPayCenter.isOpenUmeng == false then 
        return
    end
    local _shareContent = "《消灭小兽人》是一款连线消除+战斗玩法的休閒游戏!"
    local _shareTargetUrl = "http://www.play12.cn/"
    local _shareTitle = "消灭小兽人"
    local luaj = require("cocos.cocos2d.luaj")
    local javaClassName = "org.cocos2dx.lua.AppActivity"
    local javaMethodName = "setShareValue"
    local sig = "(Ljava/lang/String;II)V"
    local num = 0
    if _shareImage == "mainShareImage" then num = 1 else functionId = luaFunctionId end
    local payCode = _shareContent .. "_" .. _shareTitle .. "_" .. _shareTargetUrl .. "_".._shareImage .. "_" ..tostring(num)
    local args ={tostring(payCode),000,functionId}
    luaj.callStaticMethod(javaClassName, javaMethodName, args, sig)
end

--截屏代码 有一个咔嚓的动画
function umengInterFace:screen()
    if DPayCenter.isOpenUmeng == false then 
        return
    end
    self:capt()
    --[[local path = device.writablePath
    local size = cc.Director:getInstance():getWinSize()
    local screen = cc.RenderTexture:create(size.width/4, size.height/4)
    local temp  = cc.Director:getInstance():getRunningScene()
    local point = temp:getAnchorPoint()
    screen:begin()
    temp:setScale(0.4)
    temp:setAnchorPoint(cc.p(0,0))
    temp:visit()
    screen:endToLua()
    local pathsave = path.."/share.png"
    screen:saveToFile('share.png', true)

    temp:setScale(1)
    temp:setAnchorPoint(point)

    self:setShareContent(device.writablePath .."/share.png")
    print("sdfdsf1111111111")
    self:openUmeng()
    print(pathsave)]]--

    --[[ local colorLayer1 = display.newColorLayer(cc.c4b(0, 0, 0, 125)):addTo(self)
    colorLayer1:setAnchorPoint(cc.p(0, 0))
    colorLayer1:setPosition(cc.p(0, display.height))


    local colorLayer2 = display.newColorLayer(cc.c4b(0, 0, 0, 125)):addTo(self)
    colorLayer2:setAnchorPoint(cc.p(0, 0))
    colorLayer2:setPosition(cc.p(0, - display.height))


    transition.moveTo(colorLayer1, {y = display.cy, time = 0.5})
    self:performWithDelay(function () 
    transition.moveTo(colorLayer1, {y = display.height, time = 0.3})
    end, 0.5) 


    transition.moveTo(colorLayer2, {y = -display.cy, time = 0.5})
    self:performWithDelay(function () 
    transition.moveTo(colorLayer2, {y = -display.height, time = 0.3})
    end, 0.5) ]]--
end

function umengInterFace:afterCaptured(succeed, outputFile)
    --if succeed then
    self:setShareContent(device.writablePath .."/share.png")
    print("sdfdsf0000000000000000000")
    self:openUmeng()
   -- else
   -- print("失败！")
   -- end
end

function umengInterFace:capt()
    cc.Director:getInstance():getTextureCache():removeTextureForKey("share.png")  
    cc.utils:captureScreen(handler(self,self.afterCaptured) , "share.png")
    --self:setShareContent(device.writablePath .."/share.png")
    print("sdfdsf1111111111")
    --self:openUmeng()
end

return umengInterFace
