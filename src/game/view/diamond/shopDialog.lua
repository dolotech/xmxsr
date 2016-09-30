--商城
local shopDialog = class("shopDialog", function()
    return display.createUI("shopDialog.csb")
end)

local nameTable = {}

local tData = {} --{["count"] = 34},{["count"] = 5},{["count"] = 90},{["count"] = 78}

function shopDialog:onEnter()
    self:getChildByName("Panel_base"):setVisible(false)
    self:addEventListener(Event.UPDATA_DIAMOND,function() 
        self:getChildByName("money"):setString(Language.RICH .. "：" .. SharedManager:readData(Config.DIAMOND))
    end)

    self:getChildByName("closeButton"):onClick(function() self:close() end)
    self:getChildByName("Button_6"):onClick(function() 
        self:getChildByName("ListView_1"):setVisible(false) 
        self:getChildByName("ListView_2"):setVisible(true) 
        self:getChildByName("Button_6"):setBright(true)
        self:getChildByName("Button_5"):setBright(false)
        self:getChildByName("Button_6"):setEnabled(false)
        self:getChildByName("Button_5"):setEnabled(true)
        end)
    self:getChildByName("Button_5"):onClick(function() 
        self:getChildByName("ListView_2"):setVisible(false) 
        self:getChildByName("ListView_1"):setVisible(true) 
        self:getChildByName("Button_5"):setBright(true)
        self:getChildByName("Button_6"):setBright(false)
        self:getChildByName("Button_5"):setEnabled(false)
        self:getChildByName("Button_6"):setEnabled(true)
    end)
    if self.param == nil then
        self:getChildByName("ListView_1"):setVisible(false)
        self:getChildByName("Button_5"):setBright(false)
        self:getChildByName("Button_6"):setEnabled(false)
    else
        self:getChildByName("ListView_2"):setVisible(false)
        self:getChildByName("Button_6"):setBright(false)
        self:getChildByName("Button_5"):setEnabled(false)
    end
    
    self:showAllItem() 
    self:initView() 
end

function shopDialog:onBuy(var)
    DPayCenter.pay(var.productId)
end

function shopDialog:initView()
    self.listView = self:getChildByName("ListView_2")
    local index = 0
    local item = nil
    for key, var in pairs(ShopData) do
        if var.type == 1 and  DPayCenter.platform == var.platform then
            index = index + 1
            item = ccui.Layout:create()
            item:setTouchEnabled(true)
            local friendsitem = display.createUI(Csbs.NODE_DIAMONDSHOP_BASE_CSB)
            friendsitem:setContentSize(cc.size(530, 130))
            friendsitem:setPosition(265, 65)
            friendsitem:setName("friendsitem")
            item:setContentSize(friendsitem:getContentSize())
            item:addChild(friendsitem)
            item:setName("item_" .. index)
            self.listView:addChild(item)
            local button1 = friendsitem:getChildByName("Button_1")
            button1:removeFromParent()
            button1:setName("Button_" .. index)
            button1:setPosition(430, 65)
            item:addChild(button1)
        end
    end

    for key, var in pairs(ShopData) do
        if var.type == 1 and DPayCenter.platform == var.platform then
            item = self.listView:getChildByName("item_"..var.order)
            local friendsitem = item:getChildByName("friendsitem")
            local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(var.icon)
            friendsitem:getChildByName("Sprite_1"):setSpriteFrame(frame)
            friendsitem:getChildByName("Image_2"):getChildByName("money_1"):setString(tostring(var.num))
            friendsitem:getChildByName("Text_1"):setString(tostring(var.des))
            Color.setLableShadows({friendsitem:getChildByName("Text_1"), friendsitem:getChildByName("Image_2"):getChildByName("money_1")})

            local button = item:getChildByName("Button_" .. var.order)
            --payType == 1 图标在前面 价格在后面
            if var.payType == 1 then
                button:setTitleText(tostring(var.pay .. " " .. var.price))
            else
                button:setTitleText(tostring(var.price .. " " .. var.pay))
            end
            button:onClick(function()self:onBuy(var)end, true)
        end     
    end


end

function shopDialog:showAllItem()
    local panel = nil
    local count = 1
    local index = 1
    local i = 1
    local result = false
    self:unpack()
    self:getChildByName("money"):setString(Language.RICH .. "：" .. tostring(SharedManager:readData(Config.DIAMOND)))
    local listChildCount = self:getChildByName("ListView_1"):getChildrenCount()
    if listChildCount > 0 then
        result = true
    end
    for i = 1, table.nums(tData) do
        local btn = nil
        if count == 1 then
            if result then
                panel = self:getChildByName("ListView_1"):getChildByName(nameTable[index])
            else
                panel = self:getChildByName("Panel_base"):clone()
                panel:setName("Panel_" .. tostring(index))
                nameTable[index] = panel:getName()
                self:getChildByName("ListView_1"):addChild(panel)
                panel:setVisible(true)
            end
            btn = panel:getChildByName("Panel_1")
            panel:getChildByName("Panel_2"):setVisible(false)
            panel:getChildByName("Panel_3"):setVisible(false)
            index = index + 1
        elseif count == 2 then
            btn = panel:getChildByName("Panel_2")
        elseif count == 3 then
            btn = panel:getChildByName("Panel_3")
        end
        btn:getChildByName("Text_price"):setString(tostring(tData[i].price))
        btn:getChildByName("Image_icon"):loadTexture(tData[i].icon .. ".png", ccui.TextureResType.plistType)

        btn:onClick(function() 
            UserAccountDataCenter.isOpenShop = true
            DialogManager:open("game.view.battle.BuyToolItemDialog", {index = tData[i].index}) 
            self:close() 
            end)
        btn:setVisible(true)
        if count >= 3 then
            count = 1
        else
            count = count + 1
        end
    end
    for i = index,table.nums(nameTable) do
        panel = self:getChildByName("ListView_1"):getChildByName(nameTable[i])
        if panel ~= nil then
            panel:setVisible(false)
        end
    end
end

function shopDialog:unpack()
    local localData = require("game.data.ToolShopData")
    local index = 1
    for i = 64, table.nums(localData) + 64 do
        local str = tostring(i)
        if localData[str]~= nil then
            if localData[str].type ~= nil and localData[str].type == 2 then
                tData[index] = localData[str]
                tData[index].index = i
                index = index + 1
            end
        end
    end
end

return shopDialog