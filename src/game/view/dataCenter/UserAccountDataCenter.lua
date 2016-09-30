UserAccountDataCenter = {}

TollgateData = require("game.data.TollgateData")
require("game.view.serverInterface.serverInterface")

UserAccountDataCenter.bagData = {}

UserAccountDataCenter.isNewBattle = false
UserAccountDataCenter.isOpenShop = false
UserAccountDataCenter.settingSureClick = function() end
UserAccountDataCenter.settingCanelClick = function() end

UserAccountDataCenter.getAllUserDataTable = function()
	local tUserData = {}
	tUserData.userid = SharedManager:readData("name")

	tUserData.data = {}
	local name = SharedManager:readData("playName")
    local pre,bin = string.find(name,"nil")
    if string.len(name) == bin then
        name = Language.gm_NoNamePlay
    end
	tUserData.data.nickname = name
	tUserData.data.cur_power = SharedManager:readData(Config.POWER)
	tUserData.data.max_power = SharedManager:readData(Config.LIMITPOWER)

	tUserData.data.stage = {}
	tUserData.data.stage.cur_stage = SharedManager:readData(Config.POINT)
	tUserData.data.stage.no_star3 = {}
	tUserData.data.stage.no_star3 = UserAccountDataCenter.getTollgateData()
	
	tUserData.data.bag = {}
    tUserData.data.bag.relive = SharedManager:readData(Config.Relive)
    tUserData.data.bag.key = SharedManager:readData(Config.KEY)
    tUserData.data.bag.diamond = SharedManager:readData(Config.DIAMOND)
    local items = SharedManager:readData(Config.Storage)
    tUserData.data.bag.brush = items[tostring(Config.TOOL_BRUSH)]
    tUserData.data.bag.bebbled = items[tostring(Config.TOOL_MAGIC_BALL)]
    tUserData.data.bag.bomb = items[tostring(Config.TOOL_BOMB)]
    tUserData.data.bag.medicine1 = items[tostring(67)]
    tUserData.data.bag.medicine2 = items[tostring(68)]
    tUserData.data.bag.medicine3 = items[tostring(69)]
    
    tUserData.data.bag.rune = {}
    tUserData.data.bag.rune[1] = SharedManager:readData(Config.YELLOW)
    tUserData.data.bag.rune[2] = SharedManager:readData(Config.BLUE)
    

    UserAccountDataCenter.bagData = tUserData.data.bag
	return tUserData
end

UserAccountDataCenter.getTollgateData = function()
	local tData = {}
	local num = SharedManager:readData(Config.POINT) - 1000--table.nums(TollgateData)
	for index = 1,num do
		local data = SharedManager:readData(tostring(index + 1000),Config.POINT_DATA_DUALFT)
		if data.star < 3 then
			tData[tostring(index + 1000)] = data.star
		end
	end
	return tData
end

UserAccountDataCenter.setBagData = function(tData)
    UserAccountDataCenter.bagData = tData.bag
    DialogManager:open(Dialog.playPack)
end

UserAccountDataCenter.openShop = function()
    if UserAccountDataCenter.isOpenShop then
        UserAccountDataCenter.isOpenShop =false
        DialogManager:open(Dialog.shop,{["num"] = 1})
    end

end

UserAccountDataCenter.getNil = function()
    local tData = {}
    return tData
end

UserAccountDataCenter.requstBagData = function()
    serverinterface.MsgDoneById(serverinterface.SAVEACCOUINTINFO,UserAccountDataCenter.getNil,UserAccountDataCenter.setBagData)
end

UserAccountDataCenter.saveAllUserDataToServer = function()
    if UserAccountDataCenter.isNewBattle then
	   serverinterface.MsgDoneById(serverinterface.SAVEACCOUINTINFO,UserAccountDataCenter.getAllUserDataTable)
	end
    UserAccountDataCenter.isNewBattle = false
end

UserAccountDataCenter.saveData = function(index,count)
    if index >=64 or index <=69 then
        local items = SharedManager:readData(Config.Storage)
        if items[tostring(index)] == nil then
            items[tostring(index)] = count
        else
            items[tostring(index)] = items[tostring(index)] + count
        end
        SharedManager:saveData(Config.Storage,items,true)
    end
end
