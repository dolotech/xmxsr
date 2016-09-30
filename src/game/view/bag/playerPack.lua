--背包
local playPack = class("playPack", function()
    return display.createUI("bagDialog.csb")
end)
require("game.view.dataCenter.UserAccountDataCenter")
local panelShow = nil
local nameTable = {}

local tData = {} --{["count"] = 34},{["count"] = 5},{["count"] = 90},{["count"] = 78}

function playPack:onEnter()
    self:getChildByName("Panel_0"):setVisible(false)
    panelShow = self:getChildByName("Panel_show")
    panelShow:setVisible(false)
    self:getChildByName("ListView_1"):removeAllChildren()
    self:getChildByName("Button_close"):onClick(function() self:close() end)
    self:onClickHandler()
    
    self:showAllItem() 
end

function playPack:showAllItem()
    local panel = nil
    local count = 1
    local index = 1
    local i = 1
    local result = false
    local listChildCount = self:getChildByName("ListView_1"):getChildrenCount()
    if listChildCount > 0 then
        result = true
    end
    UserAccountDataCenter.getAllUserDataTable()
    self:unpack()
    for i = 1, table.nums(tData) do
        local btn = nil
        if count == 1 then
            if result then
                panel = self:getChildByName("ListView_1"):getChildByName(nameTable[index])
            else
                panel = self:getChildByName("Panel_0"):clone()
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
        
        btn:getChildByName("Text_count"):setString(tostring(tData[i].count))
        btn:getChildByName("Image_icon"):loadTexture(tData[i].image, ccui.TextureResType.plistType)
        
        btn:onClick(function() self:showItemDisCrible(i) end)
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

function playPack:unpack()
    local localData = require("game.data.GoodsData")
    local count = 1
    if UserAccountDataCenter.bagData == nil then
        print("bagData is nil")
        return
    end
    if UserAccountDataCenter.bagData.relive ~= nil and UserAccountDataCenter.bagData.relive ~= 0 then
        tData[count] = {}
        tData[count].count = UserAccountDataCenter.bagData.relive
        tData[count].name = localData["124"].des
        tData[count].image = "battle/" .. localData["124"].picture .. ".png"
        tData[count].use = ""
        if localData["124"].Description ~= nil then
            tData[count].use = localData["124"].Description
        end
        count = count + 1
    end
    
    if UserAccountDataCenter.bagData.key ~= nil  and UserAccountDataCenter.bagData.key ~= 0 then
        tData[count] = {}
        tData[count].count = UserAccountDataCenter.bagData.key
        tData[count].name = "宝箱钥匙"
        tData[count].image = "battle/icon_kay.png"
        tData[count].use = "开箱子获取物品"
        tData[count].callfunc = function() SceneManager.changeScene("game.view.scene.KeyScene")  self:close() end
        count = count + 1
    end
    
    if UserAccountDataCenter.bagData.brush ~= nil  and UserAccountDataCenter.bagData.brush ~= 0 then
        tData[count] = {}
        tData[count].count = UserAccountDataCenter.bagData.brush
        tData[count].name = localData["65"].des
        tData[count].image = "battle/" .. localData["65"].picture .. ".png"
        tData[count].use = ""
        if localData["65"].Description ~= nil then
            tData[count].use = localData["65"].Description
        end
        count = count + 1
    end
    
    if UserAccountDataCenter.bagData.bebbled ~= nil  and UserAccountDataCenter.bagData.bebbled ~= 0 then
        tData[count] = {}
        tData[count].count = UserAccountDataCenter.bagData.bebbled
        tData[count].name = localData["64"].des
        tData[count].image = "battle/" .. localData["64"].picture .. ".png"
        tData[count].use = ""
        if localData["64"].Description ~= nil then
            tData[count].use = localData["64"].Description
        end
        count = count + 1
    end
    
    if UserAccountDataCenter.bagData.bomb ~= nil  and UserAccountDataCenter.bagData.bomb ~= 0 then
        tData[count] = {}
        tData[count].count = UserAccountDataCenter.bagData.bomb
        tData[count].name = localData["66"].des
        tData[count].image = "battle/" .. localData["66"].picture .. ".png"
        tData[count].use = ""
        if localData["66"].Description ~= nil then
            tData[count].use = localData["66"].Description
        end
        count = count + 1
    end
    
--    if UserAccountDataCenter.bagData.rune ~= nil  and UserAccountDataCenter.bagData.rune[1] ~= 0 then
--        tData[count] = {}
--        tData[count].count = UserAccountDataCenter.bagData.rune[1]
--        tData[count].name = localData["114"].des
--        tData[count].image = "battle/" .. localData["114"].picture .. ".png"
--        tData[count].use = ""
--        if localData["114"].Description ~= nil then
--            tData[count].use = localData["114"].Description
--        end
--        tData[count].callfunc = function() SceneManager.changeScene("game.view.scene.PetScene")  self:close() end
--        count = count + 1
--    end
--    
--    if UserAccountDataCenter.bagData.rune ~= nil  and UserAccountDataCenter.bagData.rune[2] ~= 0 then
--        tData[count] = {}
--        tData[count].count = UserAccountDataCenter.bagData.rune[2]
--        tData[count].name = localData["117"].des
--        tData[count].image = "battle/" .. localData["117"].picture .. ".png"
--        tData[count].use = ""
--        if localData["117"].Description ~= nil then
--            tData[count].use = localData["117"].Description
--        end
--        tData[count].callfunc = function() SceneManager.changeScene("game.view.scene.PetScene") self:close() end
--        count = count + 1
--    end
    
    if UserAccountDataCenter.bagData.medicine1 ~= nil  and UserAccountDataCenter.bagData.medicine1 ~= 0 then
        tData[count] = {}
        tData[count].count = UserAccountDataCenter.bagData.medicine1
        tData[count].name = localData["67"].des
        tData[count].image = "ui/" .. localData["67"].picture .. ".png"
        tData[count].use = ""
        if localData["67"].Description ~= nil then
            tData[count].use = localData["67"].Description
        end
        tData[count].callfunc = function() 
            local power = SharedManager:readData(Config.POWER)
            local powerLimete = SharedManager:readData(Config.LIMITPOWER)
            if power >= powerLimete then
                TipsManager:ShowText(Language.gm_PowerMax)
            else
                local num = power + localData["67"].EffectAddition
                if num > powerLimete then
                    num = powerLimete
                end
                local items = SharedManager:readData(Config.Storage)
                items["67"] = items["67"] - 1
                SharedManager:readData(Config.Storage,items,true)
                SharedManager:saveData(Config.POWER,num,true)
                TipsManager:ShowText(Language.gm_powerAdd)
                self:showAllItem()
            end
         end
        count = count + 1
    end
    
    if UserAccountDataCenter.bagData.medicine2 ~= nil  and UserAccountDataCenter.bagData.medicine2 ~= 0 then
        tData[count] = {}
        tData[count].count = UserAccountDataCenter.bagData.medicine2
        tData[count].name = localData["68"].des
        tData[count].image = "ui/" .. localData["68"].picture .. ".png"
        tData[count].use = ""
        if localData["68"].Description ~= nil then
            tData[count].use = localData["68"].Description
        end
        tData[count].callfunc = function()  
            local power = SharedManager:readData(Config.POWER)
            local powerLimete = SharedManager:readData(Config.LIMITPOWER)
            if power >= powerLimete then
                TipsManager:ShowText(Language.gm_PowerMax)
            else
                local num = power + localData["68"].EffectAddition
                if num > powerLimete then
                    num = powerLimete
                end
                local items = SharedManager:readData(Config.Storage)
                items["68"] = items["68"] - 1
                SharedManager:readData(Config.Storage,items,true)
                SharedManager:saveData(Config.POWER,num,true)
                TipsManager:ShowText(Language.gm_powerAdd)
                self:showAllItem()
            end
        end
        count = count + 1
    end
    
    if UserAccountDataCenter.bagData.medicine3 ~= nil  and UserAccountDataCenter.bagData.medicine3 ~= 0 then
        tData[count] = {}
        tData[count].count = UserAccountDataCenter.bagData.medicine3
        tData[count].name = localData["69"].des
        tData[count].image = "ui/" .. localData["69"].picture .. ".png"
        tData[count].use = ""
        if localData["69"].Description ~= nil then
            tData[count].use = localData["69"].Description
        end
        tData[count].callfunc = function()  
            local power = SharedManager:readData(Config.POWER)
            local powerLimete = SharedManager:readData(Config.LIMITPOWER)
            if power >= powerLimete then
                TipsManager:ShowText(Language.gm_PowerMax)
            else
                local num = power + localData["69"].EffectAddition
                if num > powerLimete then
                    num = powerLimete
                end
                local items = SharedManager:readData(Config.Storage)
                items["69"] = items["69"] - 1
                SharedManager:readData(Config.Storage,items,true)
                SharedManager:saveData(Config.POWER,num,true)
                TipsManager:ShowText(Language.gm_powerAdd)
                self:showAllItem()
            end
        end
        count = count + 1
    end
end


function playPack:showItemDisCrible(index)
    panelShow:getChildByName("Text_itemName"):setString(tData[index].name)
    panelShow:getChildByName("Text_itemUse"):setString(tData[index].use)
    if tData[index].callfunc == nil then
        panelShow:getChildByName("Button_use"):setVisible(false)
    else
        panelShow:getChildByName("Button_use"):setVisible(true)
        panelShow:getChildByName("Button_use"):onClick(tData[index].callfunc)
    end
    
    local posx,posy = self:getChildByName("Image_102"):getPosition()
    local x = posx + (stageWidth + panelShow:getContentSize().width) / 2
    panelShow:setPositionX(x)
    local inMoveTo = cc.EaseBackIn:create(cc.MoveTo:create(0.3,cc.p(posx,posy)))
    local inSqe = cc.Sequence:create(inMoveTo,cc.DelayTime:create(10),cc.CallFunc:create(function() self:backSpeak() end))
    panelShow:stopAllActions()
    panelShow:runAction(inSqe)
    
    panelShow:setVisible(true)
end

function playPack:backSpeak()
    local posx,posy = self:getChildByName("Image_102"):getPosition()
    local x = posx - (stageWidth + panelShow:getContentSize().width) / 2
    local backMoveTo = cc.EaseBackIn:create(cc.MoveTo:create(0.5,cc.p(x,posy)))
    local backSqe = cc.Sequence:create(backMoveTo,cc.CallFunc:create(function()panelShow:setVisible(false)end))
    panelShow:runAction(backSqe)
end

function playPack:onClickHandler()
    local mask = panelShow:getChildByName("Image_mask")
    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        
        if cc.rectContainsPoint(rect, locationInNode) then
            panelShow:stopAllActions()
            self:backSpeak() 
            return true
        end
        return false
    end
    
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = mask:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener:clone(), mask)
end

return playPack