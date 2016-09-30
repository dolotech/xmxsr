-- 中级道具礼包
local FristGiftDialogTool = class("FristGiftDialogTool", function()
    return cc.CSLoader:createNode("FristGiftDialogTool.csb")
end)

local shopId = 305 -- 中级道具礼包

function FristGiftDialogTool:create()
    local dialog = FristGiftDialogTool.new()
    return dialog
end

function FristGiftDialogTool:onEnter()
    self:getChildByName("closeButton"):onClick(function()self:close()end)
	Color.setLableShadows({self:getChildByName("labelTitle"),
        self:getChildByName("label1"),self:getChildByName("label2"),
        self:getChildByName("label3"),self:getChildByName("labelPrice")
    })
	self:getChildByName("btnBuy"):onClick(function()self:getHandler()end)

    local shop = DPayCenter.getShopDataById(shopId)
    self:getChildByName("labelTitle"):setString(shop.title)
    
    if shop.payType == 1 then
        self:getChildByName("labelPrice"):setString(tostring(shop.pay .. " " .. shop.price))
    else
        self:getChildByName("labelPrice"):setString(tostring(shop.price .. " " .. shop.pay))
    end
    
    self:getChildByName("Image_6"):setVisible(false)    --隐藏价格
    self:getChildByName("labelPrice"):setVisible(false)
end

--获取礼包
function FristGiftDialogTool:getHandler()
	 self:getChildByName("btnBuy"):setEnabled(false)
    DPayCenter.pay(shopId, function()self:paySuccesHandler()end, function()self:payFialerHandler()end)
end

function FristGiftDialogTool:paySuccesHandler()
    performWithDelay(self, function()
        self:close()
    end, 0.5)
end

function FristGiftDialogTool:payFialerHandler()
	self:getChildByName("btnBuy"):setEnabled(true)
end

return FristGiftDialogTool
