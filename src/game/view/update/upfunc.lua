local Upfunc = class("Upatefunc")
local M = Upfunc
local lfs =require ("lfs")
local crypto = require ("framework.crypto")

function M:hex(s)
  s=string.gsub(s,"(.)",function (x) return string.format("%02X",string.byte(x)) end)
  return s
end

function M:readFile(path)
  
  local file = io.open(path, "rb")
  if file then
    local content = file:read("*all")
    io.close(file)
    return content
  end
  return nil
end

function M:removeFile(path)
  CCLuaLog("removeFile: "..path)
  
  io.writefile(path, "")
  if device.platform == "windows" then
    os.execute("del " .. string.gsub(path, '/', '\\'))
  else
    os.execute("rm " .. path)
  end
end

function M:renameFile(path,newfilename)
  CCLuaLog("renameFile: "..path) 
  if device.platform == "windows" then
   os.execute("ren " .. string.gsub(path, '/', '\\').." "..newfilename)
  else
    os.execute("mv " .. path.." "..newfilename)
  end
end



function  M:getFileName(str, split_char)
  local sub_str_str =""
   while (true) do
      local pos = string.find(str, split_char);
      if (not pos) then
          sub_str_str = str;
          break;
      end
      local sub_str = string.sub(str, 1, pos - 1);     
      str = string.sub(str, pos + 1, #str);
  end
  return sub_str_str
end 




function M:writefile(filePath, info)
  local file = io.open(filePath,"w+")
  file:write(info)
  file:close()
  
end



function M:checkFile(fileName, cryptoCode)
  --CCLuaLog("checkFile: " .. fileName)
  --CCLuaLog("down md5: " .. cryptoCode)

  if not io.exists(fileName) then 
    print("exit...........................")
    return false
  end

  local data = self:readFile(fileName)
  if data == nil then
    return false
  end

  if cryptoCode == nil then
    return true
  end
  --print(data)
  --
  local ms = crypto.md5(self:hex(data))
  --CCLuaLog("local md5: " .. ms)
  
  if ms==cryptoCode then
    return true
  end

  return false
end

function M:checkDirOK(path)
  require "lfs"
  local oldpath = lfs.currentdir()
  CCLuaLog("old path------> "..oldpath)

  if lfs.chdir(path) then
    lfs.chdir(oldpath)
    CCLuaLog("path check OK------> "..path)
    return true
  end

  if lfs.mkdir(path) then
    CCLuaLog("path create OK------> "..path)
    return true
  end
end

--创建绝对目录
function M:mkdir(path)
  local list = self:split(path, "/")
  local p = ""
  local attr = nil
  
  print("======= mkdir =========")
  for i=1, #list-1 do    
   -- p = p .. "/" .. list[i]   
    -- p = p  .. list[i].."/" 
    p = p .. list[i].."/"   
    attr = lfs.attributes(p)
    --print(p)
    if not attr then
    --  print(p,"dir")
      lfs.mkdir(p)
      
    end
    
  end
  

  lfs.touch(path)
end



function M:removePath(path)  
    if string.sub(path,#path)  == "/" then 
      path = string.sub(path,1,#path -1)
    end  
    local mode = lfs.attributes(path, "mode")
   
    if mode == "directory" then
        local dirPath = path.."/"
        for file in lfs.dir(dirPath) do
            if file ~= "." and file ~= ".." then 
                local f = dirPath..file 
                print(f)
                self:removePath(f)
            end 
        end
        os.remove(path)
    else
        os.remove(path)
    end
end



function M:exists(path)
  local file = io.open(path, "r")
    if file then
      io.close(file)
      return true
    end
    return false
end

--list operator
function M:a_is_blist(avalue, listb)

   for i,v in  ipairs(listb) do 
     if avalue ==v then      
        return true
     end 
   end 
   return false
end
--list operator
function M:split(s, sep)
  local t = {}
  for o in string.gmatch(s, "([^" .. (sep or " ") .. "]+)") do 
    table.insert(t, o) 
  end
  return t
end




local print = print
local tconcat = table.concat
local tinsert = table.insert
local srep = string.rep
local type = type
local pairs = pairs
local tostring = tostring
local next = next
 
function M:print_r(root)
  local cache = {  [root] = "." }
  local function _dump(t,space,name)
    local temp = {}
    for k,v in pairs(t) do
      local key = tostring(k)
      if cache[v] then
        tinsert(temp,"+" .. key .. " {" .. cache[v].."}")
      elseif type(v) == "table" then
        local new_key = name .. "." .. key
        cache[v] = new_key
        tinsert(temp,"+" .. key .. _dump(v,space .. (next(t,k) and "|" or " " ).. srep(" ",#key),new_key))
      else
        tinsert(temp,"+" .. key .. " [" .. tostring(v).."]")
      end
    end
    return tconcat(temp,"\n"..space)
  end
  print(_dump(root, "",""))
end

return M
