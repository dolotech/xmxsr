-- 钻石购买

local diamondDialog = class("DiamondDialog", function()
    return cc.CSLoader:createNode("DiamondDialog.csb")
end)

function diamondDialog:onEnter()
    self:initView()

    self:getChildByName("closeButton"):onClick(function()
        Audio.playSound(Sound.SOUND_UI_READY_BACK, false)
        require("game.view.dataCenter.UserAccountDataCenter")
        UserAccountDataCenter.openShop()
        self:close()
    end, true, false)
    
    self:getChildByName("money"):setString(Language.RICH .. "："  .. tostring(SharedManager:readData(Config.DIAMOND)))
    
    self:addEventListener(Event.UPDATA_DIAMOND,function() 
        self:getChildByName("money"):setString(Language.RICH .. "：" .. SharedManager:readData(Config.DIAMOND))
    end)
end

function diamondDialog:onBuy(var)
    DPayCenter.pay(var.productId)
end

function diamondDialog:initView()
--    self.listView = self:getChildByName("ListView_1")
--    local index = 0
--    for key, var in pairs(ShopData) do
--        if var.type == 1 and  DPayCenter.platform == var.platform then
--            index = index + 1
--            local item = ccui.Layout:create()
--            item:setTouchEnabled(true)
--            local friendsitem = display.createUI(Csbs.NODE_DIAMONDSHOP_BASE_CSB)
--            friendsitem:setContentSize(cc.size(530, 130))
--            friendsitem:setPosition(265, 65)
--            friendsitem:setName("friendsitem")
--            item:setContentSize(friendsitem:getContentSize())
--            item:addChild(friendsitem)
--            item:setName("item_"..index)
--            self.listView:addChild(item)
--        end
--    end
--    
--    for key, var in pairs(ShopData) do
--        if var.type == 1 and DPayCenter.platform == var.platform then
--            local friendsitem = self.listView:getChildByName("item_"..var.order):getChildByName("friendsitem")
--            local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(var.icon)
--            friendsitem:getChildByName("Sprite_1"):setSpriteFrame(frame)
--            friendsitem:getChildByName("Image_2"):getChildByName("money_1"):setString(tostring(var.num))
--            friendsitem:getChildByName("Text_1"):setString(tostring(var.des))
--            Color.setLableShadows({friendsitem:getChildByName("Text_1"), friendsitem:getChildByName("Image_2"):getChildByName("money_1")})
--            
--            --payType == 1 图标在前面 价格在后面
--            if var.payType == 1 then
--                friendsitem:getChildByName("Button_1"):setTitleText(tostring(var.pay .. " " .. var.price))
--            else
--                friendsitem:getChildByName("Button_1"):setTitleText(tostring(var.price .. " " .. var.pay))
--            end
--            
--            friendsitem:getChildByName("Button_1"):onClick(function()self:onBuy(var)end, true)
--        end
--    end

    self.listView = self:getChildByName("ListView_1")
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

return diamondDialog
