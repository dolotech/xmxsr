
local func_
function __addSdkFuncListener( _func )
	func_ = _func
end

function __sdkFunc( _strName, _param1, _param2, _param3, _param4, _param5 )
	if(func_~=nil)then
		func_(_strName, _param1, _param2, _param3, _param4, _param5)
	end
end

--java调用回接口
function __javaCallLuaSdkFunc(event)
    local value = string.split(event, "_")
	if(func_ ~= nil)then
		func_(value[1], value[2], value[3], value[4], value[5], value[6])
	end
end

function __initSdk()
	if(DPayCenter.platform=="haima" and device.platform == "android")then 
		haima = {}
		haima.func = function( _funName, _strData ) 
    		local str = ""
    		local function luaFunctionId(event)
                str = event
    		end
			if(_strData == nil)then _strData = "" end
		    local luaj = require("cocos.cocos2d.luaj")
		    local javaClassName = "org.cocos2dx.lua.AppActivity"
		    local javaMethodName = "haiMaSdkFunc"
		    local sig = "(Ljava/lang/String;Ljava/lang/String;I)I"
            local args ={tostring(_funName), tostring(_strData), luaFunctionId}
		    luaj.callStaticMethod(javaClassName, javaMethodName, args, sig)
		    return str
		end
	end
end

