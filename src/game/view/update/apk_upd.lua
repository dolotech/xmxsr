local Apk_upd = class("Apk_upd")
local M = Apk_upd

local Upfunc = require("game.view.update.upfunc")
local apk_server = UPDARE_APK_SERVER
local apk_List_filename = "apk_flist"
local network =require("game.net.network")
local scheduler = require("framework.scheduler")
require("framework.functions")

function M:ctor(updateScene, filePath, random)
  self.updateScene = updateScene
  self.curApkListFile = filePath..apk_List_filename
  self.filePath =filePath
 
  self.random = random

  self.apkFileList = nil
  
  self.requestCount = 0
  self.dataRecv = nil
  self.requesting = ""
  
  self.newApkListFile = ""
  
end

function M:updateApk()
  --优先可写目录
  if Upfunc:exists(self.curApkListFile) then
    self.apkFileList = dofile(self.curApkListFile)
  end
  --资源目录后先
 
  if self.apkFileList == nil then   
  
   if  cc.FileUtils:getInstance():isFileExist(apk_List_filename) then           
          local fileData =cc.FileUtils:getInstance():getStringFromFile(apk_List_filename)
          self.apkFileList  =loadstring(fileData)() 
          print(fileData)
    end 
  end  


  if self.apkFileList == nil then
    self.apkFileList = {
      ver = VERSION,
      stage = {},
      remove = {},
    }
  end

  self.requestCount = 0
  self.dataRecv = nil
  
  self.requesting = apk_List_filename
  self.newApkListFile = self.curApkListFile..".upd"

  local url = apk_server .. apk_List_filename .. "?random=" .. self.random 

  if  not Upfunc:exists(self.newApkListFile) then
    Upfunc:mkdir(self.newApkListFile)
 end 


  self:requestApkFromServer(url)
 

  scheduler.performWithDelayGlobal(function() self:onEnterFrameInApkVersion() end,1/60)
end

function M:requestApkFromServer(url)
 -- CCLuaLog("down apk url : " .. url)

  local index = self.requestCount
  local filesize = 0
  local request = network.createHTTPRequest(function(event)
    self:onResponse(event, filesize, index)
  end, url, "GET")
  
  if request then
    request:setTimeout(waittime or 1)
    request:start()
  else
   self.updateScene:endProcess()
  end
end

function M:onResponse(event, filesize, index)
  local request = event.request
  
  if event.name == "completed" then
  
   -- printf("APK REQUEST %d - getResponseStatusCode() = %d", index, request:getResponseStatusCode())

    if request:getResponseStatusCode() ~= 200 then
     self.updateScene:endProcess()
      
    else
      self.dataRecv = request:getResponseData()
      
    end

  elseif event.name == "progress" then      
    
  else  
   printf("APK REQUEST %d - getErrorCode() = %d, getErrorMessage() = %s", 
                          index, request:getErrorCode(), request:getErrorMessage())
    self.updateScene:endProcess()
    
  end
end

function M:onEnterFrameInApkVersion()
  if not self.dataRecv or self.requesting ~= apk_List_filename then return end

  Upfunc:writefile(self.newApkListFile, self.dataRecv)
  self.dataRecv = nil

  self.apkFileListNew = dofile(self.newApkListFile)
  if self.apkFileListNew == nil then
    print(self.newListFile..": Open Error!")
    
    self.updateScene:updateLua()
    
    return
    
  end

  print("old apk ver : " .. self.apkFileList.ver)
  print("new apk ver : " .. self.apkFileListNew.ver)
  
  if self:getApkVersion(self.apkFileListNew.ver) == self:getApkVersion(self.apkFileList.ver) then
   self.updateScene:updateLua()    
    return
  end 
   local winSize = cc.Director:getInstance():getWinSize()
    local node = cc.CSLoader:createNode("updateDialog.csb")
    self.updateScene:addChild(node)
    node:setAnchorPoint(0.5,0.5)
    node:setPosition(winSize.width / 2 ,winSize.height / 2)     
    self.updateScene.updateBn = node:getChildByName("Button1")    
      
     self.updateScene.updateBn:addTouchEventListener(
            function (sender,eventType)
            if eventType == ccui.TouchEventType.began then           
            end

            if eventType == ccui.TouchEventType.canceled then         
            end        
            if eventType == ccui.TouchEventType.ended then                  
                   Upfunc:removePath(self.filePath)
                   self.updateScene.apk_upd_doing = true
                   self:downApkFiles()  
            end            
        end )
end

function M:downApkFiles()
  -- call Java method
  local javaClassName = "com.xiguagames.frameworks.Local_SDK"
  local javaMethodName = "downLoadApk"
  local javaParams = {self.apkFileListNew.url}


  local javaMethodSig = "(Ljava/lang/String;)V"
  local ok, ret = luaj.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)

  if not ok then
      print("luaj error:", ret)
  else
      print("ret:", 5) -- 输出 ret: 5
  end
end

function M:getApkVersion(version)
  local verList = string.split(version, ".")
  -- verList = {"1", "2", "3"}
  return verList[1]
end

return M