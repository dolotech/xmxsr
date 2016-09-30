
--author:chenkaixi
--胜利结算CollectedFailureScene类
local CollectedWinScene = class("CollectedWinScene",function()
    return require("game.view.base.BaseScene"):create()
end)
require("game.view.dataCenter.UserAccountDataCenter")
require("game.view.dataCenter.FriendDataCenter")
local umengInterFace = require("src.sdk.umengInterFace")
function CollectedWinScene:create(param)
    self.param = param.winData
    self.star = param.starNum
    local scene = CollectedWinScene.new()
    return scene
end

--构建函数
function CollectedWinScene:ctor()
    self:setNodeEventEnabled()
    --飞行模型
    self.FlyToModel =  require("game.view.comm.FlyToModel"):create()
    Config.CITY_INIT_ONEC  = 1
    Audio.stopMusic()
end


--进入
function CollectedWinScene:onEnter()
    self:initButtonHandler()
    self:collecteGetGoods()
    self:showStar()
    --数据同步到server
    UserAccountDataCenter.saveAllUserDataToServer()
    --推送好友
    -- print("sdfsfsdfsdfsdf")
    serverinterface.MsgDoneById(serverinterface.WARMADDFRIEND)
    -- Audio.playSound(Sound.SOUND_WIN)
end

--按钮事件操作
function CollectedWinScene:initButtonHandler()

    local ui = display.createUI(Csbs.NODE_COLLECTEDWIN_CSB)
    ui:stageBottom(-Config.DATA_DESIGN_WIDTH / 2, 0)
    self:addToGameLayer(ui)
    self.ui = ui
    
    for var = 1, 5 do
        Color.setLableShadow(ui:getChildByName("Text_" .. var))
    end
    ui:getChildByName("Text_5"):setString(Language.Gloas_Goods)
    
    --体力
    local leftTopBtn = require("game.view.comm.PowerBar"):create()
    leftTopBtn:stageLeftTop()
    self:addToUILayer(leftTopBtn)
    
    --升级材料
    local meteril = display.createUI(Csbs.NODE_MATERIAL_CSB)
    meteril:stageTop()
    self:addToUILayer(meteril)
    meteril:getChildByName("Text_1"):setString(tostring(SharedManager:readData(Config.YELLOW)))
    meteril:getChildByName("Text_2"):setString(tostring(SharedManager:readData(Config.BLUE)))

    self.ui:getChildByName("Button_Share"):onClick(function() 
            umengInterFace:screen()  
    end, true)
    
    if DPayCenter.isOpenUmeng == false then
        self.ui:getChildByName("Button_Share"):setVisible(false)
        local btn1 = self.ui:getChildByName("Button_1")
        btn1:setPositionX(self.ui:getChildByName("Image_1"):getPositionX())-- + (self.ui:getChildByName("Image_1"):getContentSize().width - btn1:getContentSize().width)/2)
    end
    
    local rigthTopBtn = display.createUI(Csbs.NODE_DIAMOND_CSB)
    rigthTopBtn:stageRightTop()
    self:addToUILayer(rigthTopBtn)

    --钻石
    rigthTopBtn:getChildByNameFo("Panel_5","Text_1"):setString(tostring(SharedManager:readData(Config.DIAMOND)))
    rigthTopBtn:getChildByNameFo("Panel_5","Button_1"):onClick(function() DialogManager:open(Dialog.Diamond)end, true)
    --rigthTopBtn:getChildByName("Button_2"):onClick(function() DialogManager:open(Dialog.Diamond)end, true)

    self:createRole()
    ----------------------------------------------------------------------------------------------------------------

    self:addEventListener(Event.UPDATA_DIAMOND,function() 
        rigthTopBtn:getChildByNameFo("Panel_5","Text_1"):setString(tostring(SharedManager:readData(Config.DIAMOND)))
    end)

    self:addEventListener(Event.UPDATA_YELLOW,function() 
        meteril:getChildByName("Text_1"):setString(tostring(SharedManager:readData(Config.YELLOW)))
    end)

    self:addEventListener(Event.UPDATA_BLUE,function() 
        meteril:getChildByName("Text_2"):setString(tostring(SharedManager:readData(Config.BLUE)))
    end)
    
    local poitData = TollgateData[tostring(self.param.tollgate.id)]
    self.poitData = poitData
    
    Color.setLableShadows({
        meteril:getChildByName("Text_1"),
        meteril:getChildByName("Text_2"),
        rigthTopBtn:getChildByNameFo("Panel_5","Text_1")
    })
    ---------------------------------------------------------------------------------------------------------------- 
end

--星星出现
function CollectedWinScene:showStar()
    local node = self.ui:getChildByName("nodeStar")
    local interval, delay = 130, 0.2
    local offx = -((interval / 2) * (self.star - 1))
    local actlist={}
    actlist[#actlist+1] = cc.DelayTime:create(0.5)
    for i = 1, self.star do
        actlist[#actlist+1] = cc.DelayTime:create(delay * i)
        actlist[#actlist+1] = cc.CallFunc:create(function()
            local starEff = display.createEffect(Prefix.PREOPE_COMPLETE_NAME, "effect_complete_02", function( _sender )
                _sender:getAnimation():play("effect_complete_03")
            end, false, true)
            starEff:setPositionX(offx + (i - 1) * interval)
            if(self.star == 3 and i == 2)then starEff:setPositionY(20) end
            node:addChild(starEff)
            Audio.playSound(Sound["SOUND_STAR"..i])
        end)
    end

    actlist[#actlist+1] = cc.DelayTime:create(0.3)
    actlist[#actlist+1] = cc.CallFunc:create(function() 
        Audio.playSound(Sound.SOUND_LASTSTAR) 
        self:flyGoods() 
    end)
    self:runAction(cc.Sequence:create(actlist))
end

--显示获取物品
function CollectedWinScene:collecteGetGoods()
    local getGoods = self.param.getGoods
    if getGoods ~= nil then
        for key, var in pairs(getGoods) do
            if key == tostring(Config.DIANMOND_ID1) then--钻石
                self.ui:getChildByName("Text_1"):setString(tostring(var))
            elseif key == tostring(Config.KEY_ID) then--钥匙
                if Config.OPEN_LOCK_ID~=0 then --首次通关奖励钥匙
                    var = var + self.poitData.key
                end
                self.ui:getChildByName("Text_2"):setString(tostring(var))
            elseif key == tostring(Config.YELLOW_ID1) then--黄色材料
                self.ui:getChildByName("Text_3"):setString(tostring(var))
            elseif key == tostring(Config.BULE_ID1) then--蓝色材料
                self.ui:getChildByName("Text_4"):setString(tostring(var))
            end
        end
    end
end

--飞动物品
function CollectedWinScene:flyGoods()
    local getGoods = self.param.getGoods
    local fristKey = 0
    if Config.OPEN_LOCK_ID ~= 0 then --首次通关奖励钥匙
        fristKey = self.poitData.key
    end
    
    if getGoods then
        for key, var in pairs(getGoods) do
            local endPoint = cc.p(0, 0)
            local startPoint = cc.p(0 ,0)
            local image = nil
            local endScale = 1
            if key==tostring(Config.DIANMOND_ID1) then--钻石
                image =self.ui:getChildByName("goods_1")
                endPoint.x = stageWidth - 200
                endPoint.y =  stageHeight - 45
                startPoint.x = image:getPositionX() + offSetX
                startPoint.y = image:getPositionY()
                SharedManager:saveData(Config.DIAMOND,SharedManager:readData(Config.DIAMOND) + var, true)
            elseif key == tostring(Config.KEY_ID) then--钥匙
                image =self.ui:getChildByName("goods_2")
                SharedManager:saveData(Config.KEY, SharedManager:readData(Config.KEY) + var+fristKey, true)
                if fristKey > 0 then
                    endPoint.x = image:getPositionX() + offSetX
                    endPoint.y = image:getPositionY()
                    startPoint.x = self.ui:getChildByName("role_3"):getPositionX() + offSetX
                    startPoint.y = self.ui:getChildByName("role_3"):getPositionY()
                    fristKey = 0
                end
            elseif key==tostring(Config.YELLOW_ID1) then--黄色材料
                image =self.ui:getChildByName("goods_3")
                endPoint.x = stageWidth / 2 - 25
                endPoint.y = stageHeight - 25
                startPoint.x = image:getPositionX() + offSetX
                startPoint.y = image:getPositionY()
                endScale = 0.5
                SharedManager:saveData(Config.YELLOW,SharedManager:readData(Config.YELLOW)+var,true)
            elseif key == tostring(Config.BULE_ID1) then--蓝色材料
                image = self.ui:getChildByName("goods_4")
                endPoint.x =  stageWidth / 2 - 25
                endPoint.y =  stageHeight - 55
                startPoint.x = image:getPositionX() + offSetX
                startPoint.y = image:getPositionY()
                endScale = 0.5
                SharedManager:saveData(Config.BLUE,SharedManager:readData(Config.BLUE)+var,true)
            end
            
            local goodsData = GoodsData[key]
            local drop = {id = tonumber(key), count = var}
            local picturePath = Prefix.PREBATTLE_PICTURE .. goodsData.picture .. PNG
            
            self.FlyToModel:flyDropModel(picturePath, startPoint, endPoint,0.3, 1, endScale, var, function()
                self:updateData(drop)
            end, 35, 1, 1)   
        end
    end
    
    if fristKey > 0 then
        local image =self.ui:getChildByName("goods_2")
        local endPoint = cc.p(0,0)
        local startPoint = cc.p(0,0)
        SharedManager:saveData(Config.KEY,SharedManager:readData(Config.KEY) + fristKey, true)
        endPoint.x = image:getPositionX() + offSetX
        endPoint.y = image:getPositionY()
        startPoint.x = self.ui:getChildByName("role_3"):getPositionX() + offSetX
        startPoint.y = self.ui:getChildByName("role_3"):getPositionY()
        local drop = {id = tonumber(7), count = fristKey}
        local goodsData = GoodsData[tostring(drop.id)]
        local picturePath = Prefix.PREBATTLE_PICTURE .. goodsData.picture .. PNG
        self.FlyToModel:flyDropModel(picturePath, startPoint, endPoint,0.3, 1, 1, fristKey, function()
            self.ui:getChildByName("Text_2"):setString(tostring(fristKey))
            self:updateData(drop)
        end, 35, 1, 1)   
    end

    if SharedManager:readData(Config.KEY) > 0 then
        self.ui:getChildByName("Button_1"):setTitleText(Language.Rward_Key_Scene)
    else
        self.ui:getChildByName("Button_1"):setTitleText(Language.Continue)
    end

    self.ui:getChildByName("Button_1"):onClick(function(parameters)
        if SharedManager:readData(Config.KEY) > 0 then
            SceneManager.changeScene(Scene.Key)
        else
            SceneManager.changeScene(Scene.City)
        end
    end, true)
end

function CollectedWinScene:updateData(drop)
    if drop.id == Config.DIANMOND_ID1 then--钻石
        self:dipatchGlobalEvent(Event.UPDATA_DIAMOND)
        Audio.playSound(Sound.SOUND_DIOMOND)
    elseif drop.id == Config.KEY_ID then--钥匙  
        Audio.playSound(Sound.SOUND_KEY)
        self:dipatchGlobalEvent(Event.UPDATA_KEY)
    elseif drop.id == Config.YELLOW_ID1 then--黄色材料
        Audio.playSound(Sound.SOUND_RUNE1)
        self:dipatchGlobalEvent(Event.UPDATA_YELLOW)
    elseif drop.id == Config.BULE_ID1 then--蓝色材料 
        Audio.playSound(Sound.SOUND_RUNE2)
        self:dipatchGlobalEvent(Event.UPDATA_BLUE)
    end
end

-- 创建战斗内角色形象
function CollectedWinScene:createRole()
    self.pets = {}
    for i = 1, 5, 1 do
        local table = RoleDataManager.getPetsDataBuyType(i)
        if table ~= nil then
            for key, var in pairs(table) do
                if var.embattle then --出战状态
                    local role1Pos = self.ui:getChildByName("role_" .. i)
                    local v = Role:create(var)
                    self:addToRoleLayer(v)
                    v:setPosition(role1Pos:getPositionX() + offSetX, role1Pos:getPositionY())
                    v:playWin()
                    self.pets[i] = v
                    break 
                end
            end
        end
    end
end

return CollectedWinScene
