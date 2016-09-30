local Upfunc = require("game.view.update.upfunc")


local UpLayer = class("UpLayer")
local M = UpLayer

function M:init()
  --下载进度
  self.filesize_cur = 0
  self.filesize_max = 0
  --文件整理进度
  self.filecount_cur =0
  self.filecount_max =0

  --文件检查进度
  self.checkcount_cur =0
  self.checkcount_max =0


end

function M:updateFileSize(files_size)
  --下载大小
  self.filesize_cur = 0
  self.filesize_max = string.format("%.2f", tonumber(files_size) / 1024)
  self.filesize_max = tonumber(self.filesize_max)
  if files_size >=0 then 
    self.updateScene.imgBar:getChildByName("Text"):setString("".. self.filesize_cur .."k / "..self.filesize_max.."k")
  end 
end

function M:showNewVersion(scene, lua_upd, old_version, new_version, is_force_update, upd_info)
  self.updateScene = scene
  self.lua_upd = lua_upd
  self.updateScene.imgBar:setVisible(true)
  self.updateScene.imgBar:getChildByName("LoadingBar"):setPercent(0)
  self.updateScene.imgBar:getChildByName("Text"):setString("资源包检查") 
  self.lua_upd:downListFile()
end


function M:showResourcebundleArrangement(scene)
     self.updateScene = scene
     self.filesize_cur = 0
     self.updateScene.imgBar:getChildByName("LoadingBar"):setPercent(0)
     self.updateScene.imgBar:getChildByName("Text"):setString("资源包整理")
end 

function M:updateBar(addsize)
 -- if not self.updata_font_max then return end   
  self.filesize_cur  = self.filesize_cur+ string.format("%.2f", tonumber(addsize) / 1024)  
  self.updateScene.imgBar:getChildByName("Text"):setString("".. self.filesize_cur .."k / "..self.filesize_max.."k")
  local percentage = math.floor(self.filesize_cur / self.filesize_max * 100)  
  self.updateScene.imgBar:getChildByName("LoadingBar"):setPercent(percentage)
end

function M:setUpdateResourceCount(size)
    self.filecount_max =size
end 

function M:addUpdateResourceCount()
    self.filesize_cur =self.filesize_cur +1
end 

function M:getupdateResourceCount()
    return self.filesize_cur
end 


function M:updateResourceBar()  
    local percentage =math.floor(self.filesize_cur / self.filecount_max * 100)
    self.updateScene.imgBar:getChildByName("LoadingBar"):setPercent(percentage)
end 




function M:setCheckResourceCount(size)
    self.checkcount_max =size
end 

function M:addCheckResourceCount()
    self.checkcount_cur =self.checkcount_cur +1
end 
function M:getCheckResourceCount()
    return self.checkcount_cur
end 

function M:checkResourceBar()  
    local percentage =math.floor(self.checkcount_cur / self.checkcount_max * 100)
    self.updateScene.imgBar:getChildByName("LoadingBar"):setPercent(percentage)
end 






function M:addFilesizeCur(size)
--  self.filesize_cur = self.filesize_cur + size
end

function M:setAnchPos(node, x, y, anX, anY) 
 -- local posX , posY , aX , aY = x or 0 , y or 0 , anX or 0 , anY or 0 
 -- node:setAnchorPoint(ccp(aX,aY)) 
  --node:setPosition(ccp(posX,posY)) 
end


return M