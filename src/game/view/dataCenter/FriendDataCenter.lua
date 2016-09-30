FriendDataCenter = {}

FriendDataCenter.friendData = {}
require("game.view.serverInterface.serverInterface")
FriendDataCenter.msgDone = function(_msg)
	if _msg == 0 then
		FriendDataCenter.FriendDone()
	elseif _msg == 1 then
        TipsManager:ShowText(Language.gm_ServerClose)
	elseif _msg == 2 then
        TipsManager:ShowText(Language.gm_SeverConnectFails)
	end
end

FriendDataCenter.msgDone1 = function(tData)
	print("呵呵")
	FriendDataCenter.friendData = tData
	FriendDataCenter.FriendDone()
end

FriendDataCenter.FriendDone = function()
	--if DialogManager:isopen() == nil
		DialogManager:open(Dialog.friend) 
	--else
		--DialogManager:getDialogByName(Dialog.friend):showDialogData()
	--end
end

FriendDataCenter.warnAddFriendCallBack = function()
	local tlocalData = FriendDataCenter.getLocalData()
	tlocalData[#tlocalData + 1] =  FriendDataCenter.getLocalData()
	FriendDataCenter.saveLocalData(tlocalData)
end	

FriendDataCenter.getLocalData = function()
    return SharedManager:readData(Config.friendInfo)
end

FriendDataCenter.saveLocalData = function(tList)
    SharedManager:saveData(Config.friendInfo,tList,true)
end

FriendDataCenter.createSingFriend = function(randNum)
	local tData  = {}
    tData.name = Language.gm_NoNamePlay
    tData.checkPoint = SharedManager:readData(Config.POINT) + randNum - 1000;
    tData.starCount = SharedManager:readData(Config.Star).count + randNum * 2;
    return tData
end