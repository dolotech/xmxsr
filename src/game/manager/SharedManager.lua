--[[--
数据存档
autor Samule
]]

json = require("json")                                 -- JSON 的编码和解码接口
UserData = require("game.data.UserData")["1"]           -- 玩家存档数据接口
crypto = require("game.util.crypto")                             -- 加解密、数据编码
local Base64 = require "game.util.Base64"
local mime = require("mime")
local SharedManager = class("SharedManager")

--启动 初始化数据
function SharedManager:start()
    local function readData(key,defaultValue)
        local enValue = nil
        if defaultValue then
            enValue = json.encode(defaultValue)
        else
            enValue = json.encode(UserData[key])
        end
        -- if enValue == nil then return nil end
        -- 默认值参数enValue，如果不传入，移动设备上不能取值
        enValue = Base64.to_base64(enValue)
        key = Base64.to_base64(key)
        local value = cc.UserDefault:getInstance():getStringForKey(key,enValue)
        -- value = string.reverse(value)
        value = Base64.from_base64(value)
        value = json.decode(value)
        return value
    end
    --更新用户数据
    for k,v in pairs(UserData) do
        UserData[k] = clone(readData(k))
    end
    --更新关卡数据
    for k,v in pairs(TollgateData) do
        UserData[k] = readData(k, Config.POINT_DATA_DUALFT)
    end
    -- for k,v in pairs(TollgateData) do
    --     UserData[k] = Config.POINT_DATA_DUALFT
    -- end
    -- UserData[Config.POINT] = 1001

    --初始化自己所拥有宠物数据
    for type=1, 5, 1 do
        local pets = self:readData("pet" .. tostring(type))
        if pets~=nil then
            for id, pet in pairs(pets) do
                --print("SharedManager 宠物类型",pet.type,"宠物id",pet.id,"出战状态",pet.embattle)
                RoleDataManager.createRoleData(pet.id,pet.type,pet.embattle)--ID 是否出战状态
            end
        end
    end
    Audio.sound = SharedManager:readData("sound")
    Audio.bgm = SharedManager:readData("bgm")

    local events = SharedManager:readData(Config.Events)
    local _index = events["city"] or 0
    if _index == 0 then
        SceneManager.changeScene("game.view.scene.DramaScene")
    else
        SceneManager.changeScene("game.view.scene.CityScene")
    end
    
    --初始化关卡数据
    Global.lastPoint = SharedManager:readData(Config.POINT)
    
end

--读取数据
function SharedManager:readData(key,defaultValue)
    if(UserData[key] == nil)then return defaultValue end
    return UserData[key]
end

--保存数据
--key 
--value
--flush是否马上刷新存档
function SharedManager:saveData(key,value,flush)
    UserData[key] = clone(value)
    local enValue = json.encode(value)
    enValue = Base64.to_base64(enValue)
    key = Base64.to_base64(key)
    cc.UserDefault:getInstance():setStringForKey(key,enValue)
    if flush then
        cc.UserDefault:getInstance():flush()
    end
end
--刷新存档
function SharedManager:flush()
    cc.UserDefault:getInstance():flush()
end

return SharedManager