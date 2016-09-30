--支付中心
DPayCenter = {}
--当前发布的平台ios,iosft,google,mm,coolpad,unipay,egame,ioshaima,haima,XM,gamesample,baidu
DPayCenter.platform = "haima"
DPayCenter.isOpenUmeng = false --友盟开关
--谷歌支付
DPayCenter.google = {}
--移动支付
DPayCenter.mm = {}
--苹果GameCenter支付
DPayCenter.gameCenter = {}
--酷派支付
DPayCenter.coolpad = {}
--联通支付
DPayCenter.unipay = {}
--海马安卓支付
DPayCenter.haima = {}
--海马ios支付
DPayCenter.ioshaima = {}
--电信爱游戏支付
DPayCenter.egame = {}
--15M游戏支付
DPayCenter.XM = {}
--移动基地 和游戏支付
DPayCenter.gamesample = {}
--百度游戏支付
DPayCenter.baidu = {}


--记录是否消费了
function DPayCenter.isDiamondSaveData()
    if SharedManager:readData(Config.isDiamond) == 0 then 
        SharedManager:saveData(Config.isDiamond, 1, true)
    end
end

----------------------------------------------------------------------------------------------

--统一计费平台productId共用商品ID
DPayCenter.pay = function(productId, payCompelete, failueFun)
    local nOrderid = DPayCenter.getShopDataById(productId).payId
    if device.platform == "windows" or device.platform == "mac" then
        DPayCenter.updataPlay(productId)
        DPayCenter.isDiamondSaveData() --记录是否消费
        if payCompelete ~= nil then
            payCompelete()
        else
            if failueFun then
                failueFun()
            end
        end
    elseif device.platform == "ios" or device.platform == "ipad" then
        if DPayCenter.platform == "ioshaima" then
            DPayCenter.ioshaima.pay(nOrderid, payCompelete, failueFun)
        else 
            DPayCenter.gameCenter.pay(nOrderid, payCompelete, failueFun)
        end
    elseif device.platform == "wp8" then
    
    elseif device.platform == "winrt" then
    
    elseif device.platform == "android" then
        if DPayCenter.platform == "google" then
            DPayCenter.google.pay(nOrderid, payCompelete, failueFun)
        elseif DPayCenter.platform == "mm" then
            DPayCenter.mm.pay(nOrderid, payCompelete, failueFun)
        elseif DPayCenter.platform == "coolpad" then
            DPayCenter.coolpad.pay(nOrderid, payCompelete, failueFun)
        elseif DPayCenter.platform == "unipay" then
            DPayCenter.unipay.pay(nOrderid, payCompelete, failueFun)
        elseif DPayCenter.platform == "egame" then
            DPayCenter.egame.pay(nOrderid, payCompelete, failueFun)
        elseif DPayCenter.platform == "haima" then
            DPayCenter.haima.pay(nOrderid, payCompelete, failueFun)
        elseif DPayCenter.platform == "XM" then
            DPayCenter.XM.pay(nOrderid, payCompelete, failueFun)
        elseif DPayCenter.platform == "gamesample" then
            DPayCenter.gamesample.pay(nOrderid, payCompelete, failueFun)
        elseif DPayCenter.platform == "baidu" then
            DPayCenter.baidu.pay(nOrderid, payCompelete, failueFun)
        end
    end
end

-----------------------------------------------------------------------------------------

--http://dualface.github.io/blog/2013/01/01/call-java-from-lua/
--谷歌支付 nOrderid int商品后缀ID payCompelete支付成功回调函数
DPayCenter.google.pay = function(nOrderid, payCompelete, failueFun)
    local currentScene = SceneManager.currentScene
    DPayCenter.google.mask = display.createMaskLayer(cc.rect(0, 0, stageWidth, stageHeight), 30, 0.1, nil)
    DPayCenter.google.mask:setTouchEnabled(true)
    local logoEffect = display.createEffect("effect_loding", "effect_loding", nil, false, true)
    logoEffect:stageCenter()
    DPayCenter.google.mask:addChild(logoEffect)
    currentScene:addToEffectLayer(DPayCenter.google.mask)

    local order = DPayCenter.platform.."-"..nOrderid.."-"..os.time()
    
    local function luaFunctionId(event)
        local value = string.split(event, "_")
        local type = value[1]
        local result = value[2]
        local txt = nil
        if "sucess" == type then
            local payData = DPayCenter.getShopDataByPayId(tonumber(result)) 
            DPayCenter.updataPlay(tonumber(payData.productId))
            txt = Language.PAY_SUCESS
            DPayCenter.isDiamondSaveData() --记录是否消费
            if payCompelete ~= nil then
                payCompelete()
            end
            TalkingData.onChargeSuccess(order,payData.price,DPayCenter.platform)
        elseif "failed" == type then
            txt = Language.PAY_FAILURE
            if failueFun then
                failueFun()
            end
        elseif "cancel" == type then
            txt = Language.PAY_CANCEL
            if failueFun then
                failueFun()
            end
        elseif "log" == type then
            txt = Language.PAY_LOG
            if failueFun then
                failueFun()
            end
        end
        TipsManager:ShowText(txt, nil, 28)
        performWithDelay(SceneManager.currentScene, function()
            DPayCenter.google.mask:removeFromParent(true)
        end, 0.8)
    end
    
    local luaj = require("cocos.cocos2d.luaj")
    local javaClassName = "org.cocos2dx.lua.AppActivity"
    local javaMethodName = "payment"
    local sig = "(Ljava/lang/String;II)I"
    local payData = DPayCenter.getShopDataByPayId(tonumber(nOrderid)) 
    local args ={tostring(payData.payCode),tonumber(nOrderid),luaFunctionId}
    luaj.callStaticMethod(javaClassName, javaMethodName, args, sig)
    TalkingData.onChargeRequest(order,nOrderid,payData.price,payData.num,DPayCenter.platform)
end

----------------------------------------------------------------------------------------------

--移动支付 nOrderid int商品后缀ID payCompelete支付成功回调函数
DPayCenter.mm.pay = function(nOrderid, payCompelete, failueFun)

    local currentScene = SceneManager.currentScene
    DPayCenter.mm.mask = display.createMaskLayer(cc.rect(0, 0, stageWidth, stageHeight), 30, 0.1, nil)
    DPayCenter.mm.mask:setTouchEnabled(true)
    local logoEffect = display.createEffect("effect_loding", "effect_loding", nil, false, true)
    logoEffect:stageCenter()
    DPayCenter.mm.mask:addChild(logoEffect)
    currentScene:addToEffectLayer(DPayCenter.mm.mask)

    local order = DPayCenter.platform.."-"..nOrderid.."-"..os.time()
    
    local function luaFunctionId(event)
        local value = string.split(event, "_")
        local type = value[1]
        local result = value[2]
        local txt = nil
        if "sucess" == type then
            local payData = DPayCenter.getShopDataByPayId(tonumber(result)) 
            DPayCenter.updataPlay(tonumber(payData.productId))
            txt = Language.PAY_SUCESS
            DPayCenter.isDiamondSaveData() --记录是否消费
            if payCompelete ~= nil then
                payCompelete()
            end
            TalkingData.onChargeSuccess(order,payData.price,DPayCenter.platform)
        elseif "failed" == type then
            txt = Language.PAY_FAILURE
            if failueFun then
                failueFun()
            end
        end
        TipsManager:ShowText(txt, nil, 28)
        
        performWithDelay(SceneManager.currentScene, function()
                DPayCenter.mm.mask:removeFromParent(true)
        end,0.8)
    end

    local luaj = require("cocos.cocos2d.luaj")
    local javaClassName = "org.cocos2dx.lua.AppActivity"
    local javaMethodName = "payment"
    local sig = "(Ljava/lang/String;II)I"
    local payData = DPayCenter.getShopDataByPayId(tonumber(nOrderid))
    local payCode = payData.payCode .. "_" .. payData.title .. "_" .. payData.price .. "_" ..payData.num
    local args ={tostring(payCode),tonumber(nOrderid), luaFunctionId}
    luaj.callStaticMethod(javaClassName, javaMethodName, args, sig)

    TalkingData.onChargeRequest(order,nOrderid,payData.price,payData.num,DPayCenter.platform)
end

----------------------------------------------------------------------------------------------

--苹果支付 nOrderid int商品后缀ID payCompelete支付成功回调函数
DPayCenter.gameCenter.pay = function(nOrderid, payCompelete, failueFun)
    local currentScene = SceneManager.currentScene
    DPayCenter.gameCenter.mask = display.createMaskLayer(cc.rect(0, 0, stageWidth, stageHeight), 30, 0.1, nil)
    DPayCenter.gameCenter.mask:setTouchEnabled(true)
    local logoEffect = display.createEffect("effect_loding","effect_loding",nil,false,true)
    logoEffect:stageCenter()
    DPayCenter.gameCenter.mask:addChild(logoEffect)
    currentScene:addToEffectLayer(DPayCenter.gameCenter.mask)

    local order = DPayCenter.platform.."-"..nOrderid.."-"..os.time()
    
    local AppStorPayment = require("sdk.AppStorPayment")
    local function callBack(type)
        local txt = nil
        if "purchased" == type then
            local payData = DPayCenter.getShopDataByPayId(tonumber(nOrderid)) 
            DPayCenter.updataPlay(tonumber(payData.productId))
            txt = Language.PAY_SUCESS
            DPayCenter.isDiamondSaveData() --记录是否消费
            if payCompelete~=nil then
                payCompelete()
            end
            TalkingData.onChargeSuccess(order,payData.price,DPayCenter.platform)
        elseif "failed" == type then
            txt = Language.PAY_FAILURE
            if failueFun then
                failueFun()
            end
        elseif "cancelled" == type then
            txt = Language.PAY_CANCEL
            if failueFun then
                failueFun()
            end
        end
        
        TipsManager:ShowText(txt, nil, 28)
        performWithDelay(SceneManager.currentScene, function()
            DPayCenter.gameCenter.mask:removeFromParent(true)
        end, 0.8)
    end
    
    local payData = DPayCenter.getShopDataByPayId(tonumber(nOrderid)) 
    AppStorPayment:payment(payData.payCode, callBack)

    TalkingData.onChargeRequest(order,nOrderid,payData.price,payData.num,DPayCenter.platform)
end

----------------------------------------------------------------------------------------------

--酷派支付
DPayCenter.coolpad.pay = function(nOrderid, payCompelete, failueFun)
    local currentScene = SceneManager.currentScene
    DPayCenter.coolpad.mask = display.createMaskLayer(cc.rect(0, 0, stageWidth, stageHeight), 30, 0.1, nil)
    DPayCenter.coolpad.mask:setTouchEnabled(true)
    local logoEffect = display.createEffect("effect_loding","effect_loding", nil, false, true)
    logoEffect:stageCenter()
    DPayCenter.coolpad.mask:addChild(logoEffect)
    currentScene:addToEffectLayer(DPayCenter.coolpad.mask)

    local order = DPayCenter.platform.."-"..nOrderid.."-"..os.time()

    local function luaFunctionId(event)
        local value = string.split(event, "_")
        local type = value[1]
        local result = value[2]
        local txt = nil
        if "sucess" == type then
            local payData = DPayCenter.getShopDataByPayId(tonumber(result)) 
            DPayCenter.updataPlay(tonumber(payData.productId))
            txt = Language.PAY_SUCESS
            DPayCenter.isDiamondSaveData() --记录是否消费
            if payCompelete ~= nil then
                payCompelete()
            end
            TalkingData.onChargeSuccess(order,payData.price,DPayCenter.platform)
        elseif "failed" == type then
            txt = Language.PAY_FAILURE
            if failueFun then
                failueFun()
            end
        end
        TipsManager:ShowText(txt, nil, 28)

        performWithDelay(SceneManager.currentScene,function()
            DPayCenter.coolpad.mask:removeFromParent(true)
        end, 0.8)

    end

    local luaj = require("cocos.cocos2d.luaj")
    local javaClassName = "org.cocos2dx.lua.AppActivity"
    local javaMethodName = "payment"
    local sig = "(Ljava/lang/String;II)I"
    local payData = DPayCenter.getShopDataByPayId(tonumber(nOrderid))
    local payCode = payData.payCode .. "_".. payData.title .. "_" .. payData.price .. "_" ..payData.num
    local args ={tostring(payCode), tonumber(nOrderid), luaFunctionId}
    luaj.callStaticMethod(javaClassName, javaMethodName, args, sig)

    TalkingData.onChargeRequest(order,nOrderid,payData.price,payData.num,DPayCenter.platform)
end

----------------------------------------------------------------------------------------------

--联通支付
DPayCenter.unipay.pay = function(nOrderid, payCompelete, failueFun)
    local currentScene = SceneManager.currentScene
    DPayCenter.unipay.mask = display.createMaskLayer(cc.rect(0, 0, stageWidth, stageHeight), 30, 0.1, nil)
    DPayCenter.unipay.mask:setTouchEnabled(true)
    local logoEffect = display.createEffect("effect_loding", "effect_loding", nil, false, true)
    logoEffect:stageCenter()
    DPayCenter.unipay.mask:addChild(logoEffect)
    currentScene:addToEffectLayer(DPayCenter.unipay.mask)

    local order = DPayCenter.platform.."-"..nOrderid.."-"..os.time()

    local function luaFunctionId(event)
        local value = string.split(event, "_")
        local type = value[1]
        local result = value[2]
        local txt = nil
        if "sucess" == type then
            local payData = DPayCenter.getShopDataByPayId(tonumber(result)) 
            DPayCenter.updataPlay(tonumber(payData.productId))
            txt = Language.PAY_SUCESS
            DPayCenter.isDiamondSaveData() --记录是否消费
            if payCompelete ~= nil then
                payCompelete()
            end
            TalkingData.onChargeSuccess(order,payData.price,DPayCenter.platform)
        elseif "failed" == type then
            txt = Language.PAY_FAILURE
            if failueFun then
                failueFun()
            end
        elseif "cancel" == type then
            txt = Language.PAY_CANCEL
            if failueFun then
                failueFun()
            end
        end
        TipsManager:ShowText(txt, nil, 28)

        performWithDelay(SceneManager.currentScene,function()
            DPayCenter.unipay.mask:removeFromParent(true)
        end, 0.8)
    end

    local luaj = require("cocos.cocos2d.luaj")
    local javaClassName = "org.cocos2dx.lua.AppActivity"
    local javaMethodName = "payment"
    local sig = "(Ljava/lang/String;II)I"
    local payData = DPayCenter.getShopDataByPayId(tonumber(nOrderid))
    local payCode = payData.payCode .. "_" .. payData.title .. "_" .. payData.price .. "_" .. payData.num
    local args ={tostring(payCode), tonumber(nOrderid), luaFunctionId}
    luaj.callStaticMethod(javaClassName, javaMethodName, args, sig)

    TalkingData.onChargeRequest(order,nOrderid,payData.price,payData.num,DPayCenter.platform)
end

----------------------------------------------------------------------------------------------

--海马安卓支付
DPayCenter.haima.pay = function(nOrderid, payCompelete, failueFun)
--    local currentScene = SceneManager.currentScene
--    DPayCenter.haima.mask = display.createMaskLayer(cc.rect(0, 0, stageWidth, stageHeight), 30, 0.1, nil)
--    DPayCenter.haima.mask:setTouchEnabled(true)
--    local logoEffect = display.createEffect("effect_loding", "effect_loding", nil, false, true)
--    logoEffect:stageCenter()
--    DPayCenter.haima.mask:addChild(logoEffect)
--    currentScene:addToEffectLayer(DPayCenter.haima.mask)

    local order = DPayCenter.platform.."-"..nOrderid.."-"..os.time()
    
    Socket = require("game.net.Socket")
    local function luaFunctionId(event)
        local value = string.split(event, "_")
        local type = value[1]
        local result = value[2]
        local txt = nil
        if "sucess" == type then
            local payData = DPayCenter.getShopDataByPayId(tonumber(result)) 
            DPayCenter.updataPlay(tonumber(payData.productId))
            txt = Language.PAY_SUCESS
            DPayCenter.isDiamondSaveData() --记录是否消费
            if payCompelete ~= nil then
                payCompelete()
            end
            TalkingData.onChargeSuccess(order,payData.price,DPayCenter.platform)
        elseif "failed" == type then
            txt = Language.PAY_FAILURE
            if failueFun then
                failueFun()
            end
        elseif "cancel" == type then
            txt = Language.PAY_CANCEL
            if failueFun then
                failueFun()
            end
        end
        TipsManager:ShowText(txt, nil, 28)

--        performWithDelay(SceneManager.currentScene, function()
--            if(DPayCenter.haima.mask ~= nil)then
--                DPayCenter.haima.mask:removeFromParent()
--            end
                Socket:close()
--        end, 0.8)
    end
    
    local function connectSocket()
        local function __onStatus( _event )
            if(_event.name == SocketTCP.EVENT_CONNECTED)then 
                local userid = haima.func("getUserInfo")
                Socket:send(ServerCode.order[2], ServerCode.order[1], userid, tonumber(nOrderid),"hm")
            elseif(_event.name ~= SocketTCP.EVENT_CLOSE) then --连接服务器失败
                luaFunctionId("failed_" .. nOrderid)
            end
        end
        
        local function __onData( _event )
            _event.data = string.sub(_event.data, 3, string.len(_event.data))
            local num, tList = seri.unpack(_event.data)
            -- luaFunctionId("cancel" .. nOrderid)
            if(tList.err)then 
--                print(">>type", tList.type, " err:", tList.err)
            else
                if(tList.type == ServerCode.order[1])then
--                    print(">>发送",tList.type, " good_id:", tList.good_id)
                    local payData = DPayCenter.getShopDataByPayId(tonumber(nOrderid))
                    local payCode = payData.payCode .. "_" .. payData.title .. "_" .. payData.price .. "_" .. payData.num .. "_" .. tList.order
                    haima.func("startPay", payCode)
                    TalkingData.onChargeRequest(order,nOrderid,payData.price,payData.num,DPayCenter.platform)
                end
            end
        end
        Socket:initSocket(ServerCode.host, ServerCode.port, {onStatus = __onStatus, onData = __onData})
        Socket:connect()
    end
    
    __addSdkFuncListener(function(_strName, _param1, _param2, _param3, _param4, _param5)
        if(_strName == "LoginSuccess")then --登录成功
            connectSocket()
        elseif(_strName == "LoginFailed")then --登录失败
            luaFunctionId("failed_" .. nOrderid)
        elseif(_strName == "LoginCancel")then --登录取消
            luaFunctionId("cancel_" .. nOrderid)
        elseif(_strName == "ResultSuccess")then --支付成功
            luaFunctionId("sucess_" .. nOrderid)
        elseif(_strName == "ResultFailed")then --支付失败
            luaFunctionId("failed_" .. nOrderid) 
        elseif(_strName == "ResultCancel")then --支付取消
            TipsManager:ShowText(Language.PAY_CANCEL, nil, 28)
            Socket:close()
--            luaFunctionId("cancel_" .. nOrderid)
        elseif(_strName == "DidLogout")then --注销成功
            SharedManager:start()
        end
    end)

    if(tonumber(haima.func("isLogin")) == 1)then
        connectSocket()
    else
        haima.func("login")
    end
end

----------------------------------------------------------------------------------------------

--ios海马支付
DPayCenter.ioshaima.pay = function(nOrderid, payCompelete, failueFun)
    local currentScene = SceneManager.currentScene
    DPayCenter.ioshaima.mask = display.createMaskLayer(cc.rect(0, 0, stageWidth, stageHeight), 30, 0.1, nil)
    DPayCenter.ioshaima.mask:setTouchEnabled(true)
    local logoEffect = display.createEffect("effect_loding", "effect_loding", nil, false, true)
    logoEffect:stageCenter()
    DPayCenter.ioshaima.mask:addChild(logoEffect)
    currentScene:addToEffectLayer(DPayCenter.ioshaima.mask)

    local order = DPayCenter.platform.."-"..nOrderid.."-"..os.time()

    Socket = require("game.net.Socket")
    local function luaFunctionId(event)
        local value = string.split(event, "_")
        local type = value[1]
        local result = value[2]
        local txt = nil
        if "sucess" == type then
            local payData = DPayCenter.getShopDataByPayId(tonumber(result)) 
            DPayCenter.updataPlay(tonumber(payData.productId))
            txt = Language.PAY_SUCESS
            DPayCenter.isDiamondSaveData() --记录是否消费
            if payCompelete ~= nil then
                payCompelete()
            end
            TalkingData.onChargeSuccess(order,payData.price,DPayCenter.platform)
        elseif "failed" == type then
            txt = Language.PAY_FAILURE
            if failueFun then
                failueFun()
            end
        elseif "cancel" == type then
            txt = Language.PAY_CANCEL
            if failueFun then
                failueFun()
            end
        end
        TipsManager:ShowText(txt, nil, 28)

        performWithDelay(SceneManager.currentScene,function()
            --if(DPayCenter.ioshaima.mask:getParent() ~= nil)then
            DPayCenter.ioshaima.mask:removeFromParent()
            --end
            Socket:close()
        end, 0.8)
    end

    local function connectSocket()
        local function __onStatus( _event )
            if(_event.name == SocketTCP.EVENT_CONNECTED)then 
                local userid = haima.func("getUserInfo")
                -- string.char(_serverid) .. seri.pack_tostring( ... )
                -- Socket:send(ServerCode.order[1],ServerCode.order[0],userid,1,"hm")
                Socket:send(ServerCode.order[2], ServerCode.order[1],userid,tonumber(nOrderid),"hm")
            elseif(_event.name ~= SocketTCP.EVENT_CLOSE)then--连接服务器失败
                -- print("========__onStatus:",_event.name)
                luaFunctionId("failed_"..nOrderid)
            end
        end
        local function __onData( _event )
            _event.data = string.sub(_event.data, 3, string.len(_event.data))
            local num, tList = seri.unpack(_event.data)
            -- luaFunctionId("cancel"..nOrderid)
            if(tList.err)then 
                print(">>type", tList.type, " err:", tList.err) 
            else
                if(tList.type == ServerCode.order[1])then
--                    print(">>发送",tList.type," good_id:", tList.good_id)
                    payData = DPayCenter.getShopDataByPayId(tonumber(tList.good_id))
                    haima.func("startPay", tList.order, payData.des, "消灭小兽人", payData.price)
                    TalkingData.onChargeRequest(order,nOrderid,payData.price,payData.num,DPayCenter.platform)
                end
            end
        end
        Socket:initSocket(ServerCode.host, ServerCode.port, {onStatus = __onStatus, onData = __onData})
        Socket:connect()
    end

    __addSdkFuncListener(function(_strName,_param1,_param2,_param3,_param4,_param5)
        if(_strName=="LoginSuccess")then
            connectSocket()
        elseif(_strName=="LoginCancel")then
            luaFunctionId("failed_" .. nOrderid)
        elseif(_strName=="ResultSuccess")then
            luaFunctionId("sucess_" .. nOrderid)
        elseif(_strName=="ResultFailed")then
            luaFunctionId("failed_" .. nOrderid)
        elseif(_strName=="ResultCancel")then
            luaFunctionId("cancel_" .. nOrderid)
        elseif(_strName=="DidLogout")then
            SharedManager:start()
        end
    end)

    if(haima.func("isLogin"))then
        connectSocket()
    else
        haima.func("login")
    end
end

------------------------------------------------------------------------------------------------

--15M安卓支付
DPayCenter.XM.pay = function(nOrderid, payCompelete, failueFun)
    local currentScene = SceneManager.currentScene
    DPayCenter.XM.mask = display.createMaskLayer(cc.rect(0, 0, stageWidth, stageHeight), 30, 0.1, nil)
    DPayCenter.XM.mask:setTouchEnabled(true)
    local logoEffect = display.createEffect("effect_loding", "effect_loding", nil, false, true)
    logoEffect:stageCenter()
    DPayCenter.XM.mask:addChild(logoEffect)
    currentScene:addToEffectLayer(DPayCenter.XM.mask)

    local order = DPayCenter.platform.."-"..nOrderid.."-"..os.time()
    
    local function luaFunctionId(event)
        local value = string.split(event, "_")
        local type = value[1]
        local result = value[2]
        local txt = nil
        if "sucess" == type then
            local payData = DPayCenter.getShopDataByPayId(tonumber(result)) 
            DPayCenter.updataPlay(tonumber(payData.productId))
            txt = Language.PAY_SUCESS
            DPayCenter.isDiamondSaveData() --记录是否消费
            if payCompelete ~= nil then
                payCompelete()
            end
            TalkingData.onChargeSuccess(order,payData.price,DPayCenter.platform)
        elseif "failed" == type then
            txt = Language.PAY_FAILURE
            if failueFun then
                failueFun()
            end
        elseif "cancel" == type then
            txt = Language.PAY_CANCEL
            if failueFun then
                failueFun()
            end
        end
        TipsManager:ShowText(txt, nil, 28)

        performWithDelay(SceneManager.currentScene, function()
            DPayCenter.XM.mask:removeFromParent(true)
        end, 0.8)
    end

    local luaj = require("cocos.cocos2d.luaj")
    local javaClassName = "org.cocos2dx.lua.AppActivity"
    local javaMethodName = "payment"
    local sig = "(Ljava/lang/String;II)I"
    local payData = DPayCenter.getShopDataByPayId(tonumber(nOrderid))
    local payCode = payData.payCode .. "_" .. payData.title .. "_" .. payData.price .. "_" .. payData.num
    local args ={tostring(payCode), tonumber(nOrderid), luaFunctionId}
    luaj.callStaticMethod(javaClassName, javaMethodName, args, sig)

    TalkingData.onChargeRequest(order,nOrderid,payData.price,payData.num,DPayCenter.platform)
end

------------------------------------------------------------------------------------------------

--电信爱游戏支付
DPayCenter.egame.pay = function(nOrderid, payCompelete, failueFun)
    local currentScene = SceneManager.currentScene
    DPayCenter.egame.mask = display.createMaskLayer(cc.rect(0, 0, stageWidth, stageHeight), 30, 0.1, nil)
    DPayCenter.egame.mask:setTouchEnabled(true)
    local logoEffect = display.createEffect("effect_loding", "effect_loding", nil, false, true)
    logoEffect:stageCenter()
    DPayCenter.egame.mask:addChild(logoEffect)
    currentScene:addToEffectLayer(DPayCenter.egame.mask)

    local order = DPayCenter.platform.."-"..nOrderid.."-"..os.time()

    local function luaFunctionId(event)
        local value = string.split(event, "_")
        local type = value[1]
        local result = value[2]
        local txt = nil
        if "sucess" == type then
            local payData = DPayCenter.getShopDataByPayId(tonumber(result)) 
            DPayCenter.updataPlay(tonumber(payData.productId))
            txt = Language.PAY_SUCESS
            DPayCenter.isDiamondSaveData() --记录是否消费
            if payCompelete ~= nil then
                payCompelete()
            end
            TalkingData.onChargeSuccess(order,payData.price,DPayCenter.platform)
        elseif "failed" == type then
            txt = Language.PAY_FAILURE
            if failueFun then
                failueFun()
            end
        elseif "cancel" == type then
            txt = Language.PAY_CANCEL
            if failueFun then
                failueFun()
            end
        end
        TipsManager:ShowText(txt, nil, 28)

        performWithDelay(SceneManager.currentScene,function()
            DPayCenter.egame.mask:removeFromParent(true)
        end, 0.8)
    end

    local luaj = require("cocos.cocos2d.luaj")
    local javaClassName = "org.cocos2dx.lua.AppActivity"
    local javaMethodName = "payment"
    local sig = "(Ljava/lang/String;II)I"
    local payData = DPayCenter.getShopDataByPayId(tonumber(nOrderid))
    local payCode = payData.payCode .. "_" .. payData.title .. "_" .. payData.price .. "_" .. payData.num
    local args ={tostring(payCode), tonumber(nOrderid), luaFunctionId}
    luaj.callStaticMethod(javaClassName, javaMethodName, args, sig)

    TalkingData.onChargeRequest(order,nOrderid,payData.price,payData.num,DPayCenter.platform)
end

---------------------------------------------------------------------------------------------

--移动基地 和游戏支付
DPayCenter.gamesample.pay = function(nOrderid, payCompelete, failueFun)
    local currentScene = SceneManager.currentScene
    DPayCenter.gamesample.mask = display.createMaskLayer(cc.rect(0, 0, stageWidth, stageHeight), 30, 0.1, nil)
    DPayCenter.gamesample.mask:setTouchEnabled(true)
    local logoEffect = display.createEffect("effect_loding", "effect_loding", nil, false, true)
    logoEffect:stageCenter()
    DPayCenter.gamesample.mask:addChild(logoEffect)
    currentScene:addToEffectLayer(DPayCenter.gamesample.mask)

    local order = DPayCenter.platform.."-"..nOrderid.."-"..os.time()

    local function luaFunctionId(event)
        local value = string.split(event, "_")
        local type = value[1]
        local result = value[2]
        local txt = nil
        if "sucess" == type then
            local payData = DPayCenter.getShopDataByPayId(tonumber(result)) 
            DPayCenter.updataPlay(tonumber(payData.productId))
            txt = Language.PAY_SUCESS
            DPayCenter.isDiamondSaveData() --记录是否消费
            if payCompelete ~= nil then
                payCompelete()
            end
            TalkingData.onChargeSuccess(order,payData.price,DPayCenter.platform)
        elseif "failed" == type then
            txt = Language.PAY_FAILURE
            if failueFun then
                failueFun()
            end
        elseif "cancel" == type then
            txt = Language.PAY_CANCEL
            if failueFun then
                failueFun()
            end
        end
        TipsManager:ShowText(txt, nil, 28)

        performWithDelay(SceneManager.currentScene,function()
            DPayCenter.gamesample.mask:removeFromParent(true)
        end, 0.8)
    end

    local luaj = require("cocos.cocos2d.luaj")
    local javaClassName = "org.cocos2dx.lua.AppActivity"
    local javaMethodName = "payment"
    local sig = "(Ljava/lang/String;II)I"
    local payData = DPayCenter.getShopDataByPayId(tonumber(nOrderid))
    local payCode = payData.payCode .. "_" .. payData.title .. "_" .. payData.price .. "_" .. payData.num
    local args ={tostring(payCode), tonumber(nOrderid), luaFunctionId}
    luaj.callStaticMethod(javaClassName, javaMethodName, args, sig)

    TalkingData.onChargeRequest(order,nOrderid,payData.price,payData.num,DPayCenter.platform)
end

---------------------------------------------------------------------------------------------

--百度游戏支付
DPayCenter.baidu.pay = function(nOrderid, payCompelete, failueFun)
    local currentScene = SceneManager.currentScene
    DPayCenter.baidu.mask = display.createMaskLayer(cc.rect(0, 0, stageWidth, stageHeight), 30, 0.1, nil)
    DPayCenter.baidu.mask:setTouchEnabled(true)
    local logoEffect = display.createEffect("effect_loding", "effect_loding", nil, false, true)
    logoEffect:stageCenter()
    DPayCenter.baidu.mask:addChild(logoEffect)
    currentScene:addToEffectLayer(DPayCenter.baidu.mask)

    local order = DPayCenter.platform.."-"..nOrderid.."-"..os.time()

    local function luaFunctionId(event)
        local value = string.split(event, "_")
        local type = value[1]
        local result = value[2]
        local txt = nil
        if "sucess" == type then
            local payData = DPayCenter.getShopDataByPayId(tonumber(result)) 
            DPayCenter.updataPlay(tonumber(payData.productId))
            txt = Language.PAY_SUCESS
            DPayCenter.isDiamondSaveData() --记录是否消费
            if payCompelete ~= nil then
                payCompelete()
            end
            TalkingData.onChargeSuccess(order,payData.price,DPayCenter.platform)
        elseif "failed" == type then
            txt = Language.PAY_FAILURE
            if failueFun then
                failueFun()
            end
        elseif "cancel" == type then
            txt = Language.PAY_CANCEL
            if failueFun then
                failueFun()
            end
        end
        TipsManager:ShowText(txt, nil, 28)

        performWithDelay(SceneManager.currentScene, function()
            DPayCenter.baidu.mask:removeFromParent(true)
        end, 0.8)
    end

    local luaj = require("cocos.cocos2d.luaj")
    local javaClassName = "org.cocos2dx.lua.AppActivity"
    local javaMethodName = "payment"
    local sig = "(Ljava/lang/String;II)I"
    local payData = DPayCenter.getShopDataByPayId(tonumber(nOrderid))
    local payCode = payData.payCode .. "_" .. payData.title .. "_" .. payData.price .. "_" .. payData.num
    local args ={tostring(payCode), tonumber(nOrderid), luaFunctionId}
    luaj.callStaticMethod(javaClassName, javaMethodName, args, sig)

    TalkingData.onChargeRequest(order,nOrderid,payData.price,payData.num,DPayCenter.platform)
end

---------------------------------------------------------------------------------------------

--pingcoo广告
DPayCenter.pingcooHandler = function()
    if device.platform == "windows"  or device.platform == "mac" then--测试
        javaCallLuaFunction("sucess_-2_pingcoo")
    else
        local function luaFunctionId(event)
        -- local value = string.split(event,"_")
        -- local type = value[1]
        -- local result = value[2]
        -- TipsManager:ShowText("javaCallLuaGlobalFunction",nil,28)
        end
        local luaj = require("cocos.cocos2d.luaj")
        local javaClassName = "org.cocos2dx.lua.AppActivity"
        local javaMethodName = "showVideoPop"
        local sig = "(I)I"
        local args ={luaFunctionId}
        luaj.callStaticMethod(javaClassName, javaMethodName, args, sig)
    end
end

-----------------------------------------------------------------------------------------------

--java调用回接口
function javaCallLuaFunction(event)
    local value = string.split(event, "_")
    local type = value[1]
    local result = value[2]
    local platform = value[3]
    if platform == "pingcoo" then--广告平台
        if type == "sucess" then
            performWithDelay(SceneManager.currentScene,function()
                local data = SharedManager:readData(Config.PingCoo)
                
                local from = os.time()
                local curTab = os.date("*t")
                local toDate = os.date("*t")
                toDate.year = curTab.year
                toDate.month = curTab.month
                toDate.day = curTab.day
                toDate.hour = 28
                toDate.min = 0
                toDate.sec = 0
                local to = os.time(toDate) 
                local date = os.date("*t", to)
                local time = from-to
                
                data.date = date
                data.time = time
                data.times = data.times-1
                
                --保存更新信息
                SharedManager:saveData(Config.PingCoo, data, true)
                SceneManager.currentScene:dipatchGlobalEvent(Event.UPDATA_PINGCOO_UI)
                local shopData  = {goods={[1] = {id = data.id, num = data.num}}, des = data.num .. " " .. Language.Game_Diamond}
                TipsManager:ShowText(DPayCenter.getToolsDataAndUpdate(shopData).tips, nil, 28)
                TalkingData.onCompletedTask(Language.Video_Num_diamonds .. " " ..(8 - data.times))
            end, 1)
       else
            SceneManager.currentScene:dipatchGlobalEvent(Event.UPDATA_PINGCOO_UI)
       end
    end
end

----------------------------------------------------------------------------------------------

--更新支付
DPayCenter.updataPlay = function(productId)
    local currentScene = SceneManager.currentScene
    local shopData = DPayCenter.getShopDataById(productId)
    if productId == Config.PLAY_ID250 or productId == Config.PLAY_ID750
        or productId == Config.PLAY_ID1800 or productId == Config.PLAY_ID4500
        or productId == Config.PLAY_ID10000 or productId == Config.PLAY_ID15000
    then --钻石250
        local diamond = SharedManager:readData(Config.DIAMOND) + shopData.num
        TalkingData.onReward(shopData.num,diamond,"人民币购买获得")
        SharedManager:saveData(Config.DIAMOND,diamond, true)
        currentScene:dipatchGlobalEvent(Event.UPDATA_DIAMOND)
    elseif productId == Config.PLAY_ID5 then -- 体力 加满足  
        local power = SharedManager:readData(Config.LIMITPOWER)
        SharedManager:saveData(Config.POWER,power,true)
        currentScene:dipatchGlobalEvent(Event.UPDATA_POWER)
    elseif productId == Config.PLAY_ID6 then -- +5步数
        local BattleEvent = require("game.view.battle.BattleEvent")
        currentScene:dipatchGlobalEvent(BattleEvent.OnUpDataMoves)
    elseif productId == 1001 then --道具1
        TipsManager:ShowText(DPayCenter.getToolsDataAndUpdate(shopData).tips, nil, 28)
    elseif productId == 1002 then --道具2
        TipsManager:ShowText(DPayCenter.getToolsDataAndUpdate(shopData).tips, nil, 28)
    elseif productId == 1003 then --道具3
        TipsManager:ShowText(DPayCenter.getToolsDataAndUpdate(shopData).tips, nil, 28)
    elseif productId == 1004 then --道具4
        TipsManager:ShowText(DPayCenter.getToolsDataAndUpdate(shopData).tips, nil, 28)
    elseif productId == 1005 then --礼包1
        TipsManager:ShowText(DPayCenter.getToolsDataAndUpdate(shopData).tips, nil, 28)
    elseif productId == 1006 then --礼包2
        TipsManager:ShowText(DPayCenter.getToolsDataAndUpdate(shopData).tips, nil, 28)
    elseif productId == 1007 then --礼包3
        TipsManager:ShowText(DPayCenter.getToolsDataAndUpdate(shopData).tips, nil, 28)
    elseif productId == 1008 then --新手礼包
        TipsManager:ShowText(DPayCenter.getToolsDataAndUpdate(shopData).tips, nil, 28)
        
    elseif productId == 10086 then --测试支付
        TipsManager:ShowText(DPayCenter.getToolsDataAndUpdate(shopData).tips, nil, 28)
        SharedManager:saveData(Config.DIAMOND,SharedManager:readData(Config.DIAMOND) + 100, true)
        currentScene:dipatchGlobalEvent(Event.UPDATA_DIAMOND)
        
    elseif productId == 300 then --三星礼包
        TipsManager:ShowText(DPayCenter.getToolsDataAndUpdate(shopData).tips, nil, 28)
    elseif productId == 301 then --关卡解锁
        currentScene:dipatchGlobalEvent(Event.UPDATA_POINT_UNLOCK)
    elseif productId == 302 then --签到一键领取
        currentScene:dipatchGlobalEvent(Event.UPDATA_Akey_RECEIVE)
    elseif productId == 303 then --抽奖一键开启
        currentScene:dipatchGlobalEvent(Event.UPDATA_Akey_OPEN)
    elseif productId == 304 then --英雄快速升级
        currentScene:dipatchGlobalEvent(Event.UPDATA_RAPID_ESCALATION)
    elseif productId == 305 then --中级道具礼包
        TipsManager:ShowText(DPayCenter.getToolsDataAndUpdate(shopData).tips, nil, 28)
    end
end

DPayCenter.getToolsDataAndUpdate = function(shopData)
    local data = {}
    local currentScene = SceneManager.currentScene
    data.tips = Language.Congratulations_You_Get .. shopData.des
    for key, var in pairs(shopData.goods) do
        if var.id == Config.DIANMOND_ID1 then--钻石  
            SharedManager:saveData(Config.DIAMOND,SharedManager:readData(Config.DIAMOND) + var.num,true)
            currentScene:dipatchGlobalEvent(Event.UPDATA_DIAMOND)
        elseif var.id == Config.KEY_ID then--钥匙
            SharedManager:saveData(Config.KEY,SharedManager:readData(Config.KEY) + var.num,true)
            currentScene:dipatchGlobalEvent(Event.UPDATA_KEY)
        elseif var.id == Config.YELLOW_ID1 then--黄色材料
            SharedManager:saveData(Config.YELLOW,SharedManager:readData(Config.YELLOW) + var.num,true)
            currentScene:dipatchGlobalEvent(Event.UPDATA_YELLOW)
        elseif var.id == Config.BULE_ID1 then--蓝色材料
            SharedManager:saveData(Config.BLUE,SharedManager:readData(Config.BLUE) + var.num,true)
            currentScene:dipatchGlobalEvent(Event.UPDATA_BLUE)
        elseif var.id == Config.TOOL_RAINBOW_BALL or var.id == Config.TOOL_MAGIC_BALL or var.id == Config.TOOL_BRUSH or var.id == Config.TOOL_BOMB then
            local items = SharedManager:readData(Config.Storage)
            items[tostring(var.id)] = items[tostring(var.id)] + var.num
            SharedManager:saveData(Config.Storage, items)
        end
    end
    data.data = shopData.goods
    return data
end

--获取商品数据通过共用商品ID和当前设置平台
DPayCenter.getShopDataById = function(productId)
    for key, var in pairs(ShopData) do
        if var.platform == DPayCenter.platform then
            if productId == var.productId then
                return var
            end
        end
    end
    return nil
end

--获取商品数据通过商品后缀ID和当前设置平台
DPayCenter.getShopDataByPayId = function(payId)
    for key, var in pairs(ShopData) do
        if var.platform == DPayCenter.platform then
            if payId == var.payId then
                return var
            end
        end
    end
    return nil
end


