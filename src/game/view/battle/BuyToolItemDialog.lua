-- 战斗中购买道具提示对话框
local BattleEvent = require("game.view.battle.BattleEvent")
local ToolShopData = require("game.data.ToolShopData")

local BuyToolItemDialog = class("BuyToolItemDialog",function()
    return display.createUI("node_toolitem_buy.csb")
end)
---------------------------------------------------------------------
function BuyToolItemDialog:onExit()
    self:dipatchGlobalEvent(BattleEvent.RESUME)
end
function BuyToolItemDialog:onEnter()
    self:dipatchGlobalEvent(BattleEvent.PAUSE)

	local item = ToolShopData[tostring(self.param.index)]
	local count = 0
	local money = SharedManager:readData(Config.DIAMOND)
    
    local auto = self:getChildByName("imgIco")
    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(item.icon .. PNG)
    auto:setSpriteFrame(frame)

    auto = self:getChildByName("labelTitle")
    Color.setLableShadow(auto)
    auto:setString(Language.Buy_buyStone .. " " .. item.des)

	auto = self:getChildByName("labelMoney")
    auto:setString(tostring(money))

    self:addEventListener(Event.UPDATA_DIAMOND,function() 
    	money = SharedManager:readData(Config.DIAMOND)
    	auto = self:getChildByName("labelMoney")
	    auto:setString(tostring(money))
    end)

    --------
    function addItem( )
		count = count + 1
		local auto = self:getChildByName("labelCount")
	    auto:setString(tostring(item.num*count))
	    auto = self:getChildByName("labelPrice")
	    auto:setString(tostring(item.price*count))
	end
	function delItem( )
		count = count - 1
		if(count<1)then count = 1 end
		local auto = self:getChildByName("labelCount")
	    auto:setString(tostring(item.num*count))
	    auto = self:getChildByName("labelPrice")
	    auto:setString(tostring(item.price*count))
	end
	function buyItem(  )
		local coin = item.price*count
		money = SharedManager:readData(Config.DIAMOND)
		if(coin<=money)then 
			money = money - coin
			SharedManager:saveData(Config.DIAMOND,money)
            print("sdfd")
			if self.param.addItem ~= nil then
			     self.param.addItem(self.param.sender, self.param.index, item.num*count)
			else
			     require("game.view.dataCenter.UserAccountDataCenter")
                UserAccountDataCenter.saveData(self.param.index, item.num*count)
			end
            self:closeSelf()
			TalkingData.onPurchase(item.des,1,coin,money)
		else -- 价格不够 跳转购买钻石
			DialogManager:open(Dialog.Diamond)
		end
	end

	addItem()
    self:getChildByName("btnAdd"):onClick(addItem)
    self:getChildByName("btnDel"):onClick(delItem)
    self:getChildByName("btnBuy"):onClick(buyItem)

    self:getChildByName("closeButton"):onClick(function()self:closeSelf()end)

end

function BuyToolItemDialog:closeSelf()
    require("game.view.dataCenter.UserAccountDataCenter")
    UserAccountDataCenter.openShop()
    self:close()
end
---------------------------------------------------------------------
return BuyToolItemDialog