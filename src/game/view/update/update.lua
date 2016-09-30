------------------------------------------------------------------------------
--Load origin framework
------------------------------------------------------------------------------
--CCLuaLoadChunksFromZIP("res/framework_precompiled.zip")

------------------------------------------------------------------------------
--If you would update the modoules which have been require here,
--you can reset them, and require them again in modoule "appentry"
------------------------------------------------------------------------------

require("game.util.functions")
require("sdk.DPayCenter")
--require("game.view.guide.guidearea")
--加载场景

if(DPayCenter.platform=="ioshaima")then
    require("sdk.SdkGlobal")
end




require("game.view.update.util.config")
echoInfo  = print
--require("framework.init")
local Upfunc = require("game.view.update.upfunc")
local Apk_upd = require("game.view.update.apk_upd")
local Lua_upd = require("game.view.update.lua_upd")

------------------------------------------------------------------------------
--define UpdateScene
------------------------------------------------------------------------------

local UpdateScene = class("UpdateScene",function()
    return require("game.view.base.BaseScene"):create()
end)

function UpdateScene:create()
    local scene = UpdateScene.new()
    return scene
end

function UpdateScene:ctor()
  
  self:statReq({event="step", label="s_s_update"})

  self:addPathsSearch()

  self.path = device.writablePath.."upd/"
  
  local random = os.time()
  
  self.apk_upd = Apk_upd.new(self, self.path, random)
  self.lua_upd = Lua_upd.new(self, self.path, random)
  
  self.apk_upd_doing = false
  self:onInit()
end

function UpdateScene:onInit()  

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

    
--[[

    local forcedguid =require("game.view.guide.forcedguid")
    local begin_pos =cc.p(200,500)
    local end_pos =cc.p(350,50)
    local  node =drawGuideRoundRect(begin_pos,end_pos,3, 1) 
     
    local function get_rect_Guid(begin_pos,end_pos)
      local x,y,width,height =nil
      x = math.min(begin_pos.x,end_pos.x)
      y = math.min(begin_pos.y,end_pos.y)
      width = math.max(begin_pos.x,end_pos.x) -math.min(begin_pos.x,end_pos.x)
      height = math.max(begin_pos.y,end_pos.y) -math.min(begin_pos.y,end_pos.y) 
      print(x,y,width,height)
      return x,y,width,height
    end 
    local origin = cc.Director:getInstance():getVisibleOrigin()
    forcedguid:createForcedguid(self,node,cc.rect(get_rect_Guid(begin_pos,end_pos))) --]]


   --  local autoforcedguid =require("game.view.guide.autocraticguid")
   --  autoforcedguid:createAutocraticguid(self,nil,nil)

    self:onEnter()
end

function UpdateScene:onEnter()
     
  if self:networkCheck() then

     self.apk_upd:updateApk()
  end 

end


function UpdateScene:networkCheck()
  local javaClassName = "com.xiguagames.frameworks.Local_SDK"
  local javaMethodName = "isNetworkActive"
  local javaParams = {}

  local javaMethodSig = "()Z"
  local ok, ret
  if luaj then
    ok, ret = luaj.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)

  else
    ok = true
    ret = true 

  end
  
  echoInfo("ok[%s] ret[%s] ... ", ok, ret)

  if not ok then
      print("networkCheck luaj error:", ret)
  else
      print("networkCheck ret:", ret) -- 输出 ret: 5
      
  end
  
  return ret

end

function UpdateScene:updateLua()
  self.lua_upd:updateLua()
 
end

function UpdateScene:endProcess()
--  CCLuaLog("----------------------------------------UpdateScene:endProcess")  
 
    package.loaded["VER_CFG"] = nil
    VER_CFG = nil   
    local gameInstance = require("GameInstance")
    local game = gameInstance.create()
    game:startUp({imgBar = self.imgBar})

   if device.platform=="ios" or device.platform == "ipad" then
       local AppStorPayment = require("sdk.AppStorPayment")
       AppStorPayment:init()
   end 
end

function UpdateScene:addPathsSearch()
  local updPath = ""
  if device.platform == "android" then
  --  updPath = device.writablePath .. "upd/images/"  
  elseif device.platform == "mac" then
  --  updPath = device.writablePath .. "upd/images/"  
  end  
  cc.FileUtils:getInstance():addSearchPath("res/")

end


function UpdateScene:showDialog(params)

  local SystemConfirm = require "game.view.dialogs.SystemConfirm"

  self:addChild(SystemConfirm.new(params))

end

function UpdateScene:statReq(data)
  echoInfo("UpdateScene statReq .... ")
  
  if not luaj then return end

  local event = data.event or "unknown"
  local label = data.label or "unknown"

  local javaClassName = "com.xiguagames.frameworks.Talkingdata_SDK"
  local javaMethodName = "stat"
  local javaParams = {
    event,
    label
  }
  local javaMethodSig = "(Ljava/lang/String;Ljava/lang/String;)V"
  luaj.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)

end

  
--local upd = UpdateScene.new()
--display.replaceScene(upd)
return UpdateScene