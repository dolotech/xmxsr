require("game.util.functions")
require("sdk.DPayCenter")
require("sdk.SdkGlobal")
require("game.view.serverInterface.serverInterface")
--加载场景

if(DPayCenter.platform=="ioshaima" or DPayCenter.platform=="haima")then
end

--加载loadScene类
local loadScene = class("LoadScene",function()
    return require("game.view.base.BaseScene"):create()
end)

function loadScene:create(param)
    local scene = loadScene.new(param)
    return scene
end

--构建函数
function loadScene:ctor(param)
    local paths = {}
    paths[#paths+1] = device.writablePath.."src"
    paths[#paths+1] = device.writablePath.."res"
    paths[#paths+1] = device.writablePath
    cc.FileUtils:getInstance():setSearchPaths(paths)
    cc.FileUtils:getInstance():addSearchPath("src")
    cc.FileUtils:getInstance():addSearchPath("res")
    cc.FileUtils:getInstance():addSearchPath("")

	local winSize = cc.Director:getInstance():getWinSize()
    local node = cc.CSLoader:createNode("LoadScene.csb")
    self:addChild(node)
    node:setAnchorPoint(0.5,0.5)
    node:setPosition(winSize.width / 2 ,winSize.height / 2) 

    self.imgBar = node:getChildByName("imgBar")
    self.imgBar:setVisible(false)
    local lable = self.imgBar:getChildByName("Text")
    lable:enableShadow(cc.c4b(20,20,20,150),cc.size(3,-3),shadow or 5)
    lable:enableOutline(cc.c4b(20,20,20,150),outline or 1)

    if(DPayCenter.platform == "ioshaima" or DPayCenter.platform == "haima") then
		__initSdk()
    	__addSdkFuncListener(function(_strName,_param1,_param2,_param3,_param4,_param5) 
    		if(_strName == "LoginSuccess")then
				self:updateForServer()
			elseif(_strName == "LoginCancel")then
				self:updateForServer()
			end
    	end)
    	haima.func("login")
    else
		self:updateForServer()
	end
end

local UPDATE_SERVER = "http://119.147.141.93:1080/orc/"
-- local UPDATE_SERVER = "http://119.147.141.93:1080/orc/temp/"
local OLD_VERSION = "old_version"
local VERSION_FILE = "VER_CFG"
local oldVer = 0
local versionfile = VERSION_FILE..".lua"
--当内部版本大于存储的版本时，删除更新下来的文件
function loadScene:delUpdate()
	oldVer = INTERNAL_VERSION_NUM
	device.version = INTERNAL_VERSION
	io.rmdir(device.writablePath.."src")
	io.rmdir(device.writablePath.."res")
end

--更新
function loadScene:updateForServer()
	local oldVersion = cc.UserDefault:getInstance():getStringForKey(OLD_VERSION, INTERNAL_VERSION_NUM.."_"..INTERNAL_VERSION)
	local array = string.split(oldVersion,"_")
	oldVer = tonumber(array[1]) 
	device.version = array[2]
	if(oldVer < INTERNAL_VERSION_NUM)then 
		self:delUpdate()
	end

	UpdateManager = require("game.manager.UpdateManager")
	UpdateManager:setServer(UPDATE_SERVER, device.writablePath)

    --比对更新
    local function updateEnd( _bool )
	    if(not _bool)then 
	    	oldVer = VER_CFG.now
	    	local info = VER_CFG[tostring(oldVer)]
	    	if(info ~= nil)then device.version = info.version end
	    	cc.UserDefault:getInstance():setStringForKey(OLD_VERSION, oldVer.."_"..device.version)
	    end
	    self:init()
    end
    local function updateStart()
		oldVer = oldVer + 1
    	if(oldVer > VER_CFG.now)then 
    		updateEnd()
    		return
    	end
    	local info = VER_CFG[tostring(oldVer)]
    	local index = 0
	    local function updated()
	    	index = index + 1
	    	if(not info or index > #info.res)then
	    		updateStart()
	    		return 
	    	end
	    	local file = info.res[index]
		    UpdateManager:downloadFile(file, file, function( _param )
		    	if(_param.event == "succeed")then 
			    	updated()
			    	self:setLoadingBarCountAdd()
		    	elseif (_param.event == "failure") then -- 更新资源不全
		    		oldVer = oldVer - 1 
	    			updateEnd(true)
		    	end
		    end)
	    end
    	updated()
	end
	--获得更新配置
    UpdateManager:downloadFile(versionfile, versionfile, function( _param )
    	if(_param.event == "succeed")then 
    		VER_CFG = require(VERSION_FILE)
    		self:initLoadingBar()
    		if(self.barCountMax < 1)then self:init()
    		else updateStart() end
    	elseif(_param.event == "failure")then--更新失败忽略更新
    		self:init()
    		return
    	end
    end, 5)
end

function loadScene:getUpdateFileNum()
	local num = 0
	for i=oldVer+1,VER_CFG.now do
		num = num + #VER_CFG[tostring(i)].res
	end
	return num
end

function loadScene:initLoadingBar()
    self.barCount = 0
    self.barCountMax = self:getUpdateFileNum()
    if(self.barCount<self.barCountMax)then
	    self:setLoadingBarCountAdd()
	    self.imgBar:setVisible(true)
	end
end

function loadScene:setLoadingBarCountAdd()
	self.barCount = self.barCount + 1
	local percent = self.barCount/self.barCountMax
	percent = math.min(percent, 1)
	self.imgBar:getChildByName("LoadingBar"):setPercent(percent * 100)
	self.imgBar:getChildByName("Text"):setString(self.barCount.."/"..self.barCountMax)
end

--更新完成正式初始化游戏
function loadScene:init()
	package.loaded["VER_CFG"] = nil
	VER_CFG = nil
	io.removefile(device.writablePath..versionfile)

    local gameInstance = require("GameInstance")
    local game = gameInstance.create()
    game:startUp({imgBar = self.imgBar})
    
    serverinterface.MsgDoneById(serverinterface.ACCOUNT)

   if device.platform=="ios" or device.platform == "ipad" then
       local AppStorPayment = require("sdk.AppStorPayment")
       AppStorPayment:init()
   end
end

function loadScene:playBgMusic()

end

return loadScene
