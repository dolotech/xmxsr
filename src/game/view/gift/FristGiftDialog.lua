
-- 新手礼包
local FristGiftDialog = class("FristGiftDialog",function()
    return cc.CSLoader:createNode("FristGiftDialog.csb")
end)

function FristGiftDialog:create()
    local dialog = FristGiftDialog.new()
    return dialog
end

function FristGiftDialog:onEnter()
    self:updateData()
	Color.setLableShadows({self:getChildByName("Text_1"),self:getChildByName("Text_2"),self:getChildByName("Text_3")})
	self:getChildByName("closeButton"):onClick(function()self:close()end)
	self:getChildByName("Button_1"):onClick(function()self:getHandler()end)

	local shop = DPayCenter.getShopDataById(1008)
	self:getChildByName("Text_1"):setString(shop.title)
    if shop.payType == 1 then
        self:getChildByName("Text_2"):setString(tostring(shop.pay .. " " .. shop.price))
    else
        self:getChildByName("Text_2"):setString(tostring(shop.price .. " " .. shop.pay))
    end
	self:getChildByName("Text_3"):setString(shop.des)
	
    self:getChildByName("Image_7"):setVisible(false)--隐藏价格
    self:getChildByName("Text_2"):setVisible(false)
end

function FristGiftDialog:updateData()
    local _isNo1 = SharedManager:readData(Config.isNo)
    if _isNo1 < 1 then
        self:getChildByName("Button_1"):setEnabled(false)
        self:getChildByName("Button_1"):setColor(cc.c4b(117, 117, 117, 255))
    else
        self:getChildByName("Button_1"):setEnabled(true)
        self:getChildByName("Button_1"):setColor(cc.c4b(255, 255, 255, 255))
    end
end

--获取礼包
function FristGiftDialog:getHandler()
	 self:getChildByName("Button_1"):setEnabled(false)
	 DPayCenter.pay(1008, function()self:paySuccesHandler()end, function()self:payFialerHandler()end)
end

function FristGiftDialog:paySuccesHandler()
    local data = SharedManager:readData(Config.isFrist)
    data.frist = 1
    SharedManager:saveData(Config.isFrist, data, true)
    
    self:dipatchGlobalEvent(Event.UPDATA_FRISTGIFT_UI)
    performWithDelay(self, function()
        self:close()
    end, 0.5)
end

function FristGiftDialog:payFialerHandler()
	self:getChildByName("Button_1"):setEnabled(true)
end

return FristGiftDialog
