local Upfunc = require("game.view.update.upfunc")
local UpLayer = require("game.view.update.uplayer")

local Lua_upd = class("game.view.update.Lua_upd")
local M = Lua_upd

local lua_upd_server = UPDARE_LUA_SERVER
local lua_ver_filename = "flist_ver"
local lua_list_filename = "flist"




local network =require("game.net.network")
local scheduler = require("framework.scheduler")
require("framework.functions")
 -- 需要处理的文件列表
local downList = {}
-- 服务器文件比较得到的需要更新的列表
local differentList ={}
 -- 已经下载的文件
local downFile = {}

local dealwithDownCount=0 

CCLuaLog =print

function M:ctor(updateScene, filePath, random)
  self.updateScene = updateScene
  self.path = filePath
  self.curVerFile = filePath..lua_ver_filename
  self.curListFile = filePath..lua_list_filename
  self.random = random
  
  self.fileListInfo = nil
  
  self.requestCount = 0
  self.dataRecv = nil
  self.requesting = ""
  
  self.newVerFile = ""
  self.newListFile = ""
  self.localFileListInfo = {}
  
  self.fileListInfoNew = nil
  
  self.numFileCheck = 0
  
  self.curStageFile = nil

  self.downFileSize =0

 

  
  UpLayer:init()
  
end

function M:updateLua()

  if Upfunc:exists(self.curVerFile) then
    self.fileListInfo = dofile(self.curVerFile)
  end  
  if self.fileListInfo == nil then   
    if  cc.FileUtils:getInstance():isFileExist(lua_ver_filename) then 
        local fileData =cc.FileUtils:getInstance():getStringFromFile(lua_ver_filename)
        self.fileListInfo  =loadstring(fileData)()   
    end 
  end 


  if self.fileListInfo == nil then
    print("fileListInfo is nil ")
    
    self.fileListInfo = {
      ver = VERSION,
      stage = {},
      remove = {},
    }
  end

  self.requestCount = 0
  self.dataRecv = nil
  
  self.requesting = lua_ver_filename
  self.newVerFile = self.curVerFile..".upd"
  self:requestFromServer(self.requesting, 0)

  scheduler.performWithDelayGlobal(function() self:onEnterFrameInVersion() end,0)

end

function M:requestFromServer(filename, filesize, waittime,serverfiledir)
  local url = nil
  if serverfiledir ~= nil then 
    url= lua_upd_server .."updatefile/"..filename .. "?random=" .. self.random
    print("|....",url,"......|")
  else
    url = lua_upd_server .. filename .. "?random=" .. self.random
  end 
   
  self.requestCount = self.requestCount + 1
  
  
  print("down url : " .. url)

  local index = self.requestCount
  local request = network.createHTTPRequest(function(event)
    self:onResponse(event, filesize, index)
  end, url, "GET")
  
  if request then
    request:setTimeout(waittime or 5)
    request:start()
  else
    self:endProcess()
  end
  
end

function M:onEnterFrameInVersion()
 
  if not self.dataRecv or self.requesting ~= lua_ver_filename then return end 
  io.writefile(self.newVerFile, self.dataRecv)
  self.dataRecv = nil
  self.fileListInfoNew = dofile(self.newVerFile)
  print(self.fileListInfoNew)
  if self.fileListInfoNew == nil then
    print(self.newVerFile..": Open Error!")
    self:endProcess()    
    return    
  end

  if self:checkVer() == 0 then
    self:endProcess()
    return  
  end
  
  self.is_force_update = self:checkMinForceVer()
  if self.is_force_update == 0 then
    self.is_force_update = self:checkWifi()
  end
  
  UpLayer:showNewVersion(self.updateScene, self, self.fileListInfo.ver, 
                        self.fileListInfoNew.ver, is_force_update, self.fileListInfoNew.info)

end

function M:downListFile()
  self.dataRecv = nil  
  self.requesting = lua_list_filename
  self.newListFile = self.curListFile..".upd"
  self:requestFromServer(self.requesting, 0) 
  scheduler.performWithDelayGlobal(function() self:onEnterFrameInFileList() end,0)
end



function M:compareLocalAndNewListDiff()
  -- 比较方法。
  --两列表是按目录顺序生成的，所以，当 A 列表。在B列表的当前行没有对应名称，可知道，B列表当前行是新加行，B列表code对应不上A列表，可知 当前行是被修改过。
  --只考虑，添加资源，更新资源，暂时不考虑删除资源。
  local i =1 
  local nowi =i
  while(i <=#self.localFileListInfo.stage and nowi <=#self.fileListInfoNew.stage) do   
       --有新行数据
        if self.localFileListInfo.stage[i].name  ~= self.fileListInfoNew.stage[nowi].name then 
            nowi=  (function (subi)                                   
                                   while( subi <=#self.fileListInfoNew.stage)  do                                     
                                      if  self.localFileListInfo.stage[i].name  ~=self.fileListInfoNew.stage[subi].name then                                             
                                          table.insert(differentList, self.fileListInfoNew.stage[subi])  
                                          subi = subi+1
                                      else                                        
                                        return subi
                                      end                                       
                                   end 
                                   return -1
                           end)(nowi)
            if nowi == -1 then return nil end  
        end           
        
        if self.localFileListInfo.stage[i].code  ~= self.fileListInfoNew.stage[nowi].code then             
           table.insert(differentList, self.fileListInfoNew.stage[nowi])           
        end 
        nowi = nowi+1
        i =i+1
  end  
  --处理A表比B表长的情况 
  if i  <= #self.localFileListInfo.stage then 
     --[[ for s_i =i,#self.localFileListInfo.stage do        
        table.insert(differentList, self.localFileListInfo.stage[s_i])  
      end  -]]
      return 
  end 
  --处理B表比A表长的情况
  -- nowi 已被上处处理过
  if  nowi <=#self.fileListInfoNew.stage then        
      if nowi  <= #self.fileListInfoNew.stage then 
        for s_i =nowi,#self.fileListInfoNew.stage do   
          table.insert(differentList, self.fileListInfoNew.stage[s_i])  
        end 
      end  
  end 
end 


function M:onEnterFrameInFileList()

  if not self.dataRecv or self.requesting ~= lua_list_filename then return end
  
  io.writefile(self.newListFile, self.dataRecv)
  self.dataRecv = nil

  local fileListInfoNew = dofile(self.newListFile)
  if fileListInfoNew == nil then
    print(self.newListFile..": Open Error!")
    self:endProcess()
    return    
  end
  for i,v in pairs(fileListInfoNew) do
    self.fileListInfoNew[i] = v
  end

   --local list file
    local localFileListInfo =nil
    if Upfunc:exists(self.curListFile) then
       localFileListInfo = dofile(self.curListFile)
    end    
     
    if localFileListInfo == nil then   
      if  cc.FileUtils:getInstance():isFileExist(lua_list_filename) then         
          local fileData =cc.FileUtils:getInstance():getStringFromFile(lua_list_filename)
          localFileListInfo  =loadstring(fileData)()   
      end  
    end   

   if localFileListInfo == nil then
      print(self.curListFile..": Open Error!")
      self:endProcess()      
      return    
    end 
  for i,v in pairs(localFileListInfo) do    
    self.localFileListInfo[i] = v
  end
 

  -- 比较列表生成下载数据列表
  self:compareLocalAndNewListDiff()  
  
   --检查本地已下载资源   

   UpLayer:setCheckResourceCount(#differentList) 

  self.checkLocalResSchedule = scheduler.scheduleGlobal(
               function() 
                    UpLayer:checkResourceBar()
                     --检查完成下载文件
                    if UpLayer:getCheckResourceCount() == #differentList then 
                        if  self.checkLocalResSchedule then 
                            print("close......")
                            print(self.downFileSize,#downList)
                            scheduler.unscheduleGlobal(self.checkLocalResSchedule)
                        end 
                        UpLayer:updateFileSize(self.downFileSize)
                     --   for i,v in ipairs(downList) do
                      --    print(i,v) 
                     --   end 
                        self:downFiles()
                    end             
               end,0.1)
  
  --处理检查文件计算大小
  self:calculateDownSize(1)  
  
end


function M:calculateDownSize(listCountSub)    
     local fn = ""
    scheduler.performWithDelayGlobal(function() 
            v =differentList[listCountSub]
            fn = self.path .. v.name  

            -----资源检查。分批处理

             --1. 已下载资源标记
            if  Upfunc:checkFile(fn, v.code) then
                table.insert(downFile,fn) 
            -- 2. 已下载资源未整理标记          
            elseif  Upfunc:checkFile(fn..".upd", v.code) then                      
                 table.insert(downList, fn..".upd") 
            -- 3. 需要下载的资源计算大小
            else
                self.downFileSize = self.downFileSize + v.size   
            end            
          
            UpLayer:addCheckResourceCount() 
            listCountSub = listCountSub +1
            if  listCountSub <= #differentList then 
                self:calculateDownSize(listCountSub)
            end
            end,0.01) 
end 



function M:checkVer()
  
  CCLuaLog("old ver : " .. self.fileListInfo.ver)
  CCLuaLog("new ver : " .. self.fileListInfoNew.ver)
  
  local is_update = 0

  local currVers = Upfunc:split(self.fileListInfo.ver, ".")
  local newVers = Upfunc:split(self.fileListInfoNew.ver, ".")
  for i=1, #currVers do
  
    CCLuaLog("currVer : " .. currVers[i])
    CCLuaLog("newVer : " .. newVers[i])
    
    if tonumber(currVers[i]) > tonumber(newVers[i]) then
      break
                
    elseif tonumber(currVers[i]) < tonumber(newVers[i]) then
      is_update = 1
      break
      
    end
  end
  
  CCLuaLog("check ver update : " .. is_update)
    
  return is_update
  
end

function M:checkMinForceVer()
  CCLuaLog(" ------------------------------------------------------- ")
  CCLuaLog("min force ver : " .. self.fileListInfoNew.min_force_ver)
  
  local is_force_update = 0
  if string.len(self.fileListInfoNew.min_force_ver) > 0 then
    local currVers = Upfunc:split(self.fileListInfo.ver, ".")
    local minForceVers = Upfunc:split(self.fileListInfoNew.min_force_ver, ".")
    for i=1, #currVers do
    
      CCLuaLog("currVer : " .. currVers[i])
      CCLuaLog("minForceVer : " .. minForceVers[i])
      
      if tonumber(currVers[i]) > tonumber(minForceVers[i]) then
        break
      
      elseif tonumber(currVers[i]) < tonumber(minForceVers[i]) then
        is_force_update = 1
        break
        
      end
    end
    
  end
  
  CCLuaLog("check min force ver update : " .. is_force_update)
 
  
  return is_force_update

end

function M:downFiles()
  self.numFileCheck = 0
  self.requesting = "files"
  self:reqNextFile()  

  self.downFileSchedule =scheduler.scheduleGlobal(function() self:onEnterFrameInFiles() end,0)


  self.updateFileSchedule  =scheduler.scheduleGlobal(
     function() 
    
      if  dealwithDownCount  == #differentList then 
           if  self.updateFileSchedule then 
              scheduler.unscheduleGlobal(self.updateFileSchedule)
           end 
           if  self.downFileSchedule then 
              scheduler.unscheduleGlobal(self.downFileSchedule)
           end

           UpLayer:showResourcebundleArrangement(self.updateScene)
           UpLayer:setUpdateResourceCount(#downList)

           self.updateResSchedule = scheduler.scheduleGlobal(
                               function()
                                  --资源整理进度条更新 
                                  UpLayer:updateResourceBar()

                                  -- 更新版配置文件
                                  if UpLayer:getupdateResourceCount() == #downList then 
                                      if self.updateResSchedule then
                                         print("close..................file.....") 
                                         scheduler.unscheduleGlobal(self.updateResSchedule)


                                           --更新本地版本 文件    
                                          local data = Upfunc:readFile(self.newVerFile)
                                          io.writefile(self.curVerFile, data)
                                          self.fileListInfo = dofile(self.curVerFile)
                                          if self.fileListInfo == nil then 
                                            self:endProcess() 
                                            return
                                          end   
                                            -- 移除.UPD的服务器版本文件
                                          Upfunc:removeFile(self.newVerFile)    
                                          VERSION = self.fileListInfo.ver   
                                          --更新本地FList 文件
                                          Upfunc:removeFile(self.curListFile)
                                          local data = Upfunc:readFile(self.newListFile)      
                                          io.writefile(self.curListFile, data)
                                          Upfunc:removeFile(self.newListFile)   


                                           for i,v in ipairs(differentList) do
                                                if v.act == "load" then
                                                  CCLuaLog("CCLuaLoadChunksFromZIP : " .. self.path..v.name)
                                                  CCLuaLoadChunksFromZIP(self.path..v.name)
                                                end
                                           end 
                                          self:endProcess()
                                      end 
                                  end 
                                end,0.1)
          self:updateFiles(1)   
      end 
   end  ,0)
end


  


function M:reqNextFile()
    
     self.numFileCheck = self.numFileCheck + 1
     self.curStageFile = differentList[self.numFileCheck]
     if self.curStageFile and self.curStageFile.name then
     local fn = self.path..self.curStageFile.name       

      ---存在本地已下好的文件               
        if Upfunc:a_is_blist(fn,downFile)  == true then          
           dealwithDownCount = dealwithDownCount +1
           self:reqNextFile()
          return      
       end   
       
       --已下载没有整理的文件
        fn = fn..".upd"       
        if Upfunc:a_is_blist(fn,downList) == true then                      
           dealwithDownCount = dealwithDownCount +1  
           self:reqNextFile()
           return
        end    
      
        --需要下载的文件
        Upfunc:mkdir(fn)         
        self:requestFromServer(self.curStageFile.name, self.curStageFile.size,nil,1)  
        return 
    end 
    
end



function M:onEnterFrameInFiles()
  if not self.dataRecv or self.requesting ~= "files" then return end

  local fn = self.path..self.curStageFile.name..".upd"
  io.writefile(fn, self.dataRecv)
  self.dataRecv = nil
  
  if Upfunc:checkFile(fn, self.curStageFile.code) then    
    table.insert(downList, fn)     
    dealwithDownCount = dealwithDownCount +1   
    self:reqNextFile()
  else
    self:endProcess()
  end  
end





function M:updateFiles(downListCount)        
  
    scheduler.performWithDelayGlobal(function() 
            v =downList[downListCount]
            local data = Upfunc:readFile(v)
            local fn = string.sub(v, 1, -5)  
            io.writefile(fn, data)  
            Upfunc:removeFile(v)
            UpLayer:addUpdateResourceCount() 
            downListCount = downListCount +1
            if  downListCount <= #downList then 
               self:updateFiles(downListCount)
            end 
               end,0.01)

end

function M:endProcess()
 
  CCLuaLog("----------------------------------------Lua_upd:endProcess end...........")  

  self.updateScene:endProcess()  
end

function M:onResponse(event, filesize, index)
  local request = event.request   
  
 
  if event.name == "completed" then  
      printf("REQUEST %d - getResponseStatusCode() = %d", index, request:getResponseStatusCode())
      if request:getResponseStatusCode() ~= 200 then
        self:endProcess()        
      else
         self.dataRecv = request:getResponseData() 
          --进度控制  
         if  self.requesting == "files"  then       
            UpLayer:updateBar(filesize) 
         end 
        
      end
  elseif event.name == "progress" then      
    
  else  
    printf("REQUEST %d - getErrorCode() = %d, getErrorMessage() = %s", 
                          index, request:getErrorCode(), request:getErrorMessage())
    self:endProcess()
    
 end

end

function M:checkWifi()
  -- call Java method
  local javaClassName = "com.xiguagames.frameworks.Local_SDK"
  local javaMethodName = "isWiFiActive"
  local javaParams = {
  }

  local javaMethodSig = "()Z"
  local ok, ret
  if luaj then
    ok, ret = luaj.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
  end

  if not ok then
      print("luaj error:", ret)
  else
      print("ret:", ret) -- 输出 ret: 5
      return ret
  end
end

return M