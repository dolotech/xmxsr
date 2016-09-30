--好友
local FriendDialog = class("FriendDialog", function()
    return display.createUI("FriendDialog.csb")
end)
require("game.view.dataCenter.FriendDataCenter")
require("game.view.serverInterface.serverInterface")
local tFriendInfo = {}
function FriendDialog:onEnter()
    --self:setVisible(false)
    --serverinterface.MsgDoneById(serverinterface.GETFRIEND,handler(self, self.GetFriendInfoCallBack),handler(self, self.GetFriendInfoCallBackNoInfo))

    self:getChildByName("Panel_1"):setVisible(false)
    self:getChildByName("Button_1"):onClick(function() 
        Audio.playSound(Sound.SOUND_UI_READY_BACK, false)
        self:closeSelf()
    end, true)
    
    self:getChildByName("Button_2"):onClick(function() 
        Audio.playMusic(Audio.currentBGM)
        DialogManager:open(Dialog.friendadd)
    end, true)
    --self:GetFriendInfoCallBackNoInfo(0)
    self:showDialogData()   
end

function FriendDialog:showDialogData()
    if table.nums(serverinterface.friendData) == 0 then
        self:GetFriendInfoCallBackNoInfo(0)
    else
        self:GetFriendInfoCallBack(serverinterface.friendData)
    end
end

function FriendDialog:closeSelf()
   -- Socket:close()
    self:close()
end
function FriendDialog:getSelfData()
    local name = SharedManager:readData("playName")
    local pre,bin = string.find(name,"nil")
    if string.len(name) == bin then
        name = Language.gm_NoNamePlay
    end
    local tSelf = {{["name"] = name,["checkPoint"] = SharedManager:readData(Config.POINT),
        ["starCount"] = SharedManager:readData(Config.Star).count,
        ["userid"] = SharedManager:readData("name"),
        ["self"] = "self" } }
--    name = SharedManager:readData(Config.playName)
--    tSelf.checkPoint = 4
--    tSelf.starCount = SharedManager:readData(Config.Star).count
    return tSelf
end

function FriendDialog:getLocalData()
    return SharedManager:readData(Config.friendInfo)
end

function FriendDialog:saveLocalData(tList)
    SharedManager:saveData(Config.friendInfo,tList,true)
end

function FriendDialog:unpack(pData)
    local tData = {}
    print(table.nums(pData))
    local i = 1
    for uid, tab in pairs(pData) do
        tData[i] = tData[i] or {}
        tData[i].userid = uid
        if tab.nickname ~= nil then
            tData[i].name = tab.nickname
        else
            tData[i].name = Language.gm_NoNamePlay
        end

        if tab.cur_stage ~= nil then
            tData[i].checkPoint = tab.cur_stage
        else
            tData[i].checkPoint = 1001
        end
        
        if tab.star ~= nil then
            tData[i].starCount = tab.star
        else
            tData[i].starCount = 0
        end
        i = i + 1
    end
    return tData
end

function FriendDialog:GetFriendInfoCallBack(pData)
    local tServerData  = self:unpack(pData)
    local selfData = self:getSelfData()
    tServerData[#tServerData + 1] = selfData[1]
    self:setData(tServerData)
end

function FriendDialog:GetFriendInfoCallBackNoInfo(calltype)
    if calltype == 1 then --未联网
        TipsManager:ShowText(Language.gm_ServerClose)
        self:close()
    elseif calltype == 2 then --没有userid
--        print("获取失败，userid错误")
        self:close()
    elseif calltype == 4 then --未联网
        self:close()
    elseif calltype == 0 then
        local tServerData = self:getSelfData()
        self:setData(tServerData)
     end
end

function FriendDialog:setData(tServerData)
    local saveData = {}
    local needCreateNum = 0
    local tlocalData = self:getLocalData()
    for i = 1,#tlocalData do
        tServerData[#tServerData + 1] = tlocalData[i]
    end
    
    needCreateNum = 6 - #tServerData
    if needCreateNum > 0 then
        math.randomseed(os.time())
        for i = 1, needCreateNum do
            tServerData[#tServerData + 1] =  self:createSingFriend(math.random(8))
        end
    end
    tServerData = self:DataSort(tServerData)
    for i = 1, #tServerData do
        local panel = self:getChildByName("Panel_1"):clone()
        panel:getChildByName("Text_2"):setString(tServerData[i].name)
        local point = tServerData[i].checkPoint
        if point >= 1000 then
            point = point - 1000
        end
        if point <= 0 then
            point = 1
        end
        panel:getChildByName("Text_3"):setString(Language.gm_di .. tostring(point) .. Language.gm_guan)
        panel:getChildByName("Text_4"):setString(tostring(tServerData[i].starCount))
        panel:getChildByName("Text_5"):setString(tostring(i))
        if tServerData[i].self ~= nil then
            panel:getChildByName("Image_3"):loadTexture("ui/ui_comm_kuang_8.png", ccui.TextureResType.plistType)
        end 
        if tServerData[i].userid == nil then
            saveData[#saveData +1] = tServerData[i]
        end
        panel:setVisible(true)
        self:getChildByName("ListView_1"):addChild(panel)
    end
    self:saveLocalData(saveData)
    self:setVisible(true)
end

function FriendDialog:createSingFriend(randNum)
    local tData  = {}
    tData.name = Language.gm_NoNamePlay
    tData.checkPoint = SharedManager:readData(Config.POINT) + randNum - 1000;
    tData.starCount = SharedManager:readData(Config.Star).count + randNum;
    return tData
end

function FriendDialog:DataSort(tList)
    local tData = {}
    tData[1] = tList[1]
    table.remove(tList,1)
    for i = 1,#tList do
        local tloc = tList[i]
        for j = 1,#tData do
            if tloc.starCount > tData[j].starCount then
                local tpar = tData[j]
                tData[j] = tloc
                tloc = tpar
            elseif tloc.starCount == tData[j].starCount then
                if tloc.starCount >= tData[j].starCount then
                    local tpar = tData[j]
                    tData[j] = tloc
                    tloc = tpar
                end
            end
       end
       tData[#tData + 1] = tloc
    end
    return tData
end

return FriendDialog
