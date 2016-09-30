local BattleEvent = require("game.view.battle.BattleEvent")
local OutOfMovesDialog = class("OutOfMovesDialog",function()
    return display.createUI("OutOfMovesDialog.csb")
end)

function OutOfMovesDialog:onEnter()
    self:getChildByName("Button_1"):onClick(function(parameters)self:dipatchGlobalEvent(BattleEvent.OnUpDataMoves)self:close()end, true)
    self:getChildByName("Button_1"):setTitleText(Language.Continue .. Language.Game)
    self:getChildByName("Button_2"):setTitleText(Language.Buy_buyStone)
    self.toolShopData = require("game.data.ToolShopData")
    
    self:getChildByName("Text_6"):setString(Language.Steps_Have_Exhausted)
    local poitData = TollgateData[tostring(self.param.id)]
    self:getChildByName("Text_7"):setString(poitData.pointName)
    local shop = DPayCenter.getShopDataById(Config.PLAY_ID6)
    if shop.payType == 1 then
        self:getChildByName("Text_4"):setString(tostring(shop.pay .. " " .. shop.price))
    else
        self:getChildByName("Text_4"):setString(tostring(shop.price .. " " .. shop.pay))
    end
    self:getChildByName("Text_8"):setString("+ 5".. Language.Game_moveStep)
    self.time = Config.MOVE_FAIL_INTERVAL
    
    Color.setLableShadows({
        self:getChildByName("Text_1"),
        self:getChildByName("Text_2"),
        self:getChildByName("Text_3"),
        self:getChildByName("Text_4"),
        self:getChildByName("Text_5"),
        self:getChildByName("Text_6"),
        self:getChildByName("Text_7"),
        self:getChildByName("Text_8"),
        self:getChildByName("Text_9"),
        self:getChildByName("Text_10")
    })
    
--    if device.platform ~= "ios" then
--        self:getChildByName("Text_5"):setTextColor(cc.c4b(91,89,89,255))
--    end
    
    local n  = 0
    for key, var in pairs(self.param.data) do
        n = n + 1
        local frame = nil
        local text = self:getChildByName("Text_" .. var.index)
        local image = self:getChildByName("Sprite_" .. var.index)
        if key == "monster" then
            image:setScale(0.7)
            frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(Picture.RES_MONSTER_PNG)
        else
            local goods = GoodsData[key]
            frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(Prefix.PREBATTLE_PICTURE .. goods.picture .. PNG)
        end
        image:setSpriteFrame(frame)    
        if var.num <= 0 then
            self:getChildByName("guo_" .. var.index):setVisible(true)
            text:setVisible(false)
        end
        text:setString(tostring(var.num))
    end
    
    for i = n + 1, 3, 1 do
        self:getChildByName("guo_" .. i):setVisible(false)
        self:getChildByName("Sprite_" .. i):setVisible(false)
        self:getChildByName("Text_" .. i):setVisible(false)
    end
    
    self:getChildByName("Button_1"):onClick(function(parameters)
        local _diamond = SharedManager:readData(Config.DIAMOND)
        local _Relive = SharedManager:readData(Config.Relive)
        self:stopAllActions()
        local ConsumeDiamonds = 0
        local rId = 0
        local var = self.toolShopData[tostring(ItemIndex.Relive_ID)]
        ConsumeDiamonds = var.price
        rId = ItemIndex.Relive_ID
    
        if _Relive > 0 then
            self:updateData()
            rId = ItemIndex.Relive_ID
            self:getChildByName("Text_5"):setString("1" .. " (" .. _Relive .. ")")
            self:dipatchGlobalEvent(BattleEvent.OnUpDataMoves)self:close()
            _Relive = _Relive - 1
            SharedManager:saveData(Config.Relive, _Relive, true)
            print("复活石 ---= ".._Relive)
        elseif _Relive == 0 then 
            self:updateData()
            if _diamond >= ConsumeDiamonds then
                rId = ItemIndex.Diamond
                self:getChildByName("Text_5"):setString(tostring(ConsumeDiamonds))
                self:dipatchGlobalEvent(BattleEvent.OnUpDataMoves)self:close()
                _diamond  = _diamond - ConsumeDiamonds
                SharedManager:saveData(Config.DIAMOND, _diamond, true)
                TalkingData.onPurchase("复活石",1,ConsumeDiamonds,_diamond)
                -- print("钻石---= ".._diamond)
        	else
                DialogManager:open(Dialog.Diamond)
            end
        end
        print("钻石    复活石---= ".._diamond,_Relive)
    end, true)

--    self:getChildByName("Button_1"):onClick(function(parameters)
--        local _diamond = SharedManager:readData(Config.DIAMOND)
--        local _Relive = SharedManager:readData(Config.Relive)
--        self:stopAllActions()
--        local ConsumeDiamonds = 0
--        local rId = 0
--        
--        for key, var in pairs(self.toolShopData) do
--            if var.productId == Config.Relive_ID then
--                ConsumeDiamonds = var.price
--                rId = var.productId
--            end
--        end
--
--        if _Relive > 0 then   --如果复活石足够
--            self:dipatchGlobalEvent(BattleEvent.OnUpDataMoves,1) --在监听判断,1复活石购买, 2钻石购买,以及修改数据更新数据
--            self:close()
--        else   --否则钻石购买步数
--            if _diamond>=ConsumeDiamonds then --钻石购买
--                self:dipatchGlobalEvent(BattleEvent.OnUpDataMoves,2)
--                self:close()
--        else
--            --打开购买钻石
--            DialogManager:open(Dialog.Diamond)
--        end
--        end
--    end,true)
    
    self:getChildByName("Button_2"):onClick(function(parameters)
        self:stopAllActions()
        DPayCenter.pay(Config.PLAY_ID6, function()self:close()end, function()self:startSchedule()end)
    end,true)

    self:getChildByName("closeButton"):onClick(function(parameters)
        SceneManager.changeScene(Scene.CollectedFailure, {id = self.param.id, getGoods = self.param.getGoods})
    end, true)
    
    self:updateData()
    self:startSchedule()
end

function OutOfMovesDialog:updateData()
    local _diamond = SharedManager:readData(Config.DIAMOND)
    local _Relive = SharedManager:readData(Config.Relive)
    local ConsumeDiamonds = 0
    local rId = 0
    local var = self.toolShopData[tostring(ItemIndex.Relive_ID)]
    ConsumeDiamonds = var.price
    rId = ItemIndex.Relive_ID
    
    if _Relive > 0 then
        rId = ItemIndex.Relive_ID
        self:getChildByName("Text_5"):setString("1" .. " (" .. _Relive .. ")")
        self:getChildByName("Text_10"):setString(Language.Use_Stone)
        SharedManager:saveData(Config.Relive, _Relive)
        print("刷新后的复活石----= ".._Relive)
    elseif _Relive == 0 then 
        rId = ItemIndex.Diamond
        self:getChildByName("Text_5"):setString(ConsumeDiamonds.."")
        self:getChildByName("Text_10"):setString(Language.Use_Diamonds)
        SharedManager:saveData(Config.DIAMOND, _diamond)
        print("刷新后的钻石----= ".._diamond)
    end
    
    local goods = GoodsData[tostring(rId)]
    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(Prefix.PREBATTLE_PICTURE .. goods.picture .. PNG)
    self:getChildByName("Sprite_4"):setSpriteFrame(frame)
    self:getChildByName("Sprite_5"):setSpriteFrame(frame)
end

function OutOfMovesDialog:startSchedule()
    --倒计时
    schedule(self,function()
        self.time = self.time - 1
        if self.time < 0 then
            self.time = 0
            self:getChildByName("Text_9"):setString(tostring(self.time))
            SceneManager.changeScene(Scene.CollectedFailure, {id=self.param.id, getGoods=self.param.getGoods})
            return
        end
        self:getChildByName("Text_9"):setString(tostring(self.time))
    end,1)
end

return OutOfMovesDialog