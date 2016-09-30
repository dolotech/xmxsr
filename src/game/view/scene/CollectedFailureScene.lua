
--author:chenkaixi
--失败结算CollectedFailureScene
local CollectedFailureScene = class("CollectedFailureScene",function()
    return require("game.view.base.BaseScene"):create()
end)

function CollectedFailureScene:create(param)
    self.param = param
    local scene = CollectedFailureScene.new()
    return scene
end

--构建函数
function CollectedFailureScene:ctor()
    self:setNodeEventEnabled()
    --飞行模型
    self.FlyToModel =  require("game.view.comm.FlyToModel"):create()
    Audio.stopMusic()
    Audio.currentBGM = ""
end

--进入
function CollectedFailureScene:onEnter()
    self:initButtonHandler()

    -- self:collecteGetGoods()

    -- self:flyGoods()

    Audio.playSound(Sound.SOUND_LOSE)
    Config.CITY_INIT_ONEC  = 2
end


--按钮事件操作
function CollectedFailureScene:initButtonHandler()

    local ui= display.createUI(Csbs.NODE_COLLECTEDFAILURE_CSB)
    ui:stageBottom(-Config.DATA_DESIGN_WIDTH/2,0)
    self:addToGameLayer(ui)
    self.ui = ui
    --重新来
    -- ui:getChildByName("Text_6"):setString(Language.Fingth_Failure)
    -- ui:getChildByName("Text_8"):setString(Language.Gloas_Goods)
    self.ui:getChildByNameFo("Node_btn","Button_1"):setTitleText(Language.Again)
    self.ui:getChildByNameFo("Node_btn","Button_1"):onClick(function(parameters)
        local tollgateData = clone(TollgateData[tostring(self.param.id)])
        tollgateData.id = tostring(self.param.id)
        local power = SharedManager:readData(Config.POWER)
        if power<tollgateData.power then
            DialogManager:open(Dialog.power)
            return
        end
        self:starBattle(tollgateData)
    end,true)

    --购买道具礼包
    local btn = self.ui:getChildByName("Button_5")
    local size = btn:getContentSize()
    local particle = cc.ParticleSystemQuad:create("particle/particle_kuang.plist")
    tween.RepeatMoveForCircle(particle,20,0,0,size.width,size.height)
    btn:addChild(particle)
    particle = cc.ParticleSystemQuad:create("particle/particle_kuang.plist")
    tween.RepeatMoveForCircle(particle,20,0,0,size.width,size.height,3)
    btn:addChild(particle)
    btn:onClick(function(parameters)
        DialogManager:open(Dialog.fristGiftTool)
    end, true)
    
    --进入英雄界面
    local btn = self.ui:getChildByName("Button_6")
    local size = btn:getContentSize()
    local particle = cc.ParticleSystemQuad:create("particle/particle_kuang.plist")
    tween.RepeatMoveForCircle(particle,20,0,0,size.width,size.height)
    btn:addChild(particle)
    particle = cc.ParticleSystemQuad:create("particle/particle_kuang.plist")
    tween.RepeatMoveForCircle(particle,20,0,0,size.width,size.height,3)
    btn:addChild(particle)
    btn:onClick(function()SceneManager.changeScene(Scene.Pet)end, true, true, Sound.SOUND_UI_HERO_SLIDE)
    
    --体力
    local leftTopBtn = require("game.view.comm.PowerBar"):create()
    leftTopBtn:stageLeftTop()
    self:addToUILayer(leftTopBtn)

    --升级材料
    -- local meteril = display.createUI(Csbs.NODE_MATERIAL_CSB)
    -- meteril:stageTop()
    -- self:addToUILayer(meteril)
    -- meteril:getChildByName("Text_1"):setString(tostring(SharedManager:readData(Config.YELLOW)))
    -- meteril:getChildByName("Text_2"):setString(tostring(SharedManager:readData(Config.BLUE)))

    local rigthTopBtn = display.createUI(Csbs.NODE_DIAMOND_CSB)
    rigthTopBtn:stageRightTop()
    self:addToUILayer(rigthTopBtn)
    
    -- local leftBtn = display.createUI(Csbs.NODE_FAILURE_CSB)
    -- leftBtn:stageLeftBottom()
    -- self:addToUILayer(leftBtn)
    -- self.leftBtn = leftBtn
    
    -- leftBtn:getChildByName("Node_2"):setVisible(false)
    -- leftBtn:getChildByName("Button_2"):setVisible(false)
    -- leftBtn:getChildByName("Node_1"):setVisible(false)
    -- leftBtn:getChildByName("Button_1"):setVisible(false)
    -- self:battleButton(false)
   
    --key
    -- leftBtn:getChildByName("Button_1"):onClick(function()SceneManager.changeScene(Scene.Pet)end, true, true, Sound.SOUND_UI_HERO_SLIDE)
    --宠物
    -- leftBtn:getChildByName("Button_2"):onClick(function()SceneManager.changeScene(Scene.Key)end, true, true, Sound.SOUND_UI_LOTTERY_POPUP)
    
    --钻石
    rigthTopBtn:getChildByNameFo("Panel_5","Text_1"):setString(tostring(SharedManager:readData(Config.DIAMOND)))
    rigthTopBtn:getChildByNameFo("Panel_5","Button_1"):onClick(function() DialogManager:open(Dialog.Diamond)end, true)
--    rigthTopBtn:getChildByName("Button_2"):onClick(function() DialogManager:open(Dialog.Diamond)end, true)
    
    --返回
    local returnBtn = display.createUI(Csbs.NODE_RETURN_CSB)
    returnBtn:stageRightBottom(-70,70)
    returnBtn:getChildByName("Button_1"):onClick(function()SceneManager.changeScene(Scene.City)end, true)
    self:addToUILayer(returnBtn)
    self.returnBtn = returnBtn
    
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
    
    local poitData = TollgateData[tostring(self.param.id)]
    -- self.ui:getChildByName("Text_5"):setString(poitData.pointName)
    self.ui:getChildByName("Node_btn"):getChildByName("Text_1"):setString(tostring(poitData.power))
    local tips = Language["Tips" .. math.round(math.random(1,5))]
    self.ui:getChildByName("Text_7"):setString(tips)
    
    Color.setLableShadows({
        -- meteril:getChildByName("Text_1"),
        -- meteril:getChildByName("Text_2"),
        self.ui:getChildByName("Node_btn"):getChildByName("Text_1"),
        rigthTopBtn:getChildByNameFo("Panel_5","Text_1")
    })
    
    -- tween.RepeatScale(self.ui:getChildByName("Node_btn"),1.2,1,1.2)
end

--按钮显示
function CollectedFailureScene:battleButton(bool)
    local key = SharedManager:readData(Config.KEY)
    if key>0 or bool==true then
        self.leftBtn:getChildByName("Node_1"):setVisible(false)
        self.leftBtn:getChildByName("Button_1"):setVisible(false)

        self.leftBtn:getChildByName("Node_2"):getChildByName("Text"):setString(tostring(key))
        self.leftBtn:getChildByName("Node_2"):setVisible(true)
        self.leftBtn:getChildByName("Button_2"):setVisible(true)
        self.leftBtn:getChildByName("Button_2"):setVisible(tonumber(self.param.id) > Config.OPEN_KEY_POINT)
        self.leftBtn:getChildByName("Node_2"):setVisible(tonumber(self.param.id) > Config.OPEN_KEY_POINT)
    else
        -- self.leftBtn:getChildByName("Node_1"):getChildByName("Text"):setString(tostring(0))
        -- self.leftBtn:getChildByName("Node_1"):setVisible(true)
        self.leftBtn:getChildByName("Button_1"):setVisible(true)
        self.leftBtn:getChildByName("Button_1"):setVisible(tonumber(self.param.id) > Config.OPEN_ROLE_POINT)

        self.leftBtn:getChildByName("Node_2"):setVisible(false)
        self.leftBtn:getChildByName("Button_2"):setVisible(false)
    end
end

--开始战斗
function CollectedFailureScene:starBattle(tollgateData)
    -- Audio.playSound(Sound.SOUND_UI_READY_CLICK)
    self.ui:getChildByName("Node_btn"):stopAllActions()
    self.ui:getChildByName("Node_btn"):setScale(1)
    -- self.leftBtn:getChildByName("Button_1"):setEnabled(false)
    -- self.leftBtn:getChildByName("Button_2"):setEnabled(false)
    self.returnBtn:getChildByName("Button_1"):setEnabled(false)
    self.ui:getChildByName("Node_btn"):getChildByName("Button_1"):setEnabled(false)
    self.FlyToModel:flyDropModel(Picture.RES_POWER_IOCN_PNG,cc.p(47, stageHeight - 58), cc.p(offSetX + 395, 63), 0.8, 1, 0.5, nil, function()
        SceneManager.changeScene(Scene.Battle,{tollgate=tollgateData})
    end, 5, 0.3, 0.5)  
end


--显示获取物品
function CollectedFailureScene:collecteGetGoods()
    local getGoods = self.param.getGoods
    if getGoods then
        for key, var in pairs(getGoods) do
            if key == tostring(Config.DIANMOND_ID1) then--钻石
                self.ui:getChildByName("Text_1"):setString(tostring(var))
            elseif key == tostring(Config.KEY_ID) then--钥匙
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
function CollectedFailureScene:flyGoods()
    local getGoods = self.param.getGoods
    if getGoods then
        for key, var in pairs(getGoods) do
            local endPoint = cc.p(0,0)
            local startPoint = cc.p(0,0)
            local image = nil
            local endScale = 1
            if key == tostring(Config.DIANMOND_ID1) then--钻石
                image =self.ui:getChildByName("goods_1")
                endPoint.x = stageWidth-200
                endPoint.y =  stageHeight-45
                local diamond = SharedManager:readData(Config.DIAMOND)+var
                TalkingData.onReward(var,diamond,"过关奖励")
                SharedManager:saveData(Config.DIAMOND,diamond,true)
            elseif key == tostring(Config.KEY_ID) then--钥匙
                image =self.ui:getChildByName("goods_2")
                endPoint.x =  50
                endPoint.y =  50
                self:battleButton(true)
                SharedManager:saveData(Config.KEY,SharedManager:readData(Config.KEY)+var,true)
            elseif key==tostring(Config.YELLOW_ID1) then--黄色材料
                image =self.ui:getChildByName("goods_3")
                endPoint.x = stageWidth / 2 - 25
                endPoint.y = stageHeight - 25
                endScale  = 0.5
                SharedManager:saveData(Config.YELLOW,SharedManager:readData(Config.YELLOW)+var,true)
            elseif key==tostring(Config.BULE_ID1) then--蓝色材料
                image =self.ui:getChildByName("goods_4")
                endPoint.x =  stageWidth / 2 - 25
                endPoint.y =  stageHeight - 55
                endScale  = 0.5
                SharedManager:saveData(Config.BLUE,SharedManager:readData(Config.BLUE)+var,true)
            end
            startPoint.x = image:getPositionX()+offSetX
            startPoint.y = image:getPositionY()
            local goodsData = GoodsData[key]
            local drop = {id=tonumber(key),count=var}
            
            local picturePath = Prefix.PREBATTLE_PICTURE.. goodsData.picture .. PNG
            self.FlyToModel:flyDropModel(picturePath,startPoint,endPoint,0.3,1,endScale,var,function()
                self:updateData(drop)
            end,35,1,1)   
        end
    end
    
end

function CollectedFailureScene:updateData(drop)
    if drop.id==Config.DIANMOND_ID1 then--钻石
        self:dipatchGlobalEvent(Event.UPDATA_DIAMOND)
        Audio.playSound(Sound.SOUND_DIOMOND)
    elseif drop.id==Config.KEY_ID then--钥匙  
        Audio.playSound(Sound.SOUND_KEY)
        self:dipatchGlobalEvent(Event.UPDATA_KEY)
        self:battleButton(true)
    elseif drop.id==Config.YELLOW_ID1 then--黄色材料
        Audio.playSound(Sound.SOUND_RUNE1)
        self:dipatchGlobalEvent(Event.UPDATA_YELLOW)
    elseif drop.id==Config.BULE_ID1 then--蓝色材料 
        Audio.playSound(Sound.SOUND_RUNE2)
        self:dipatchGlobalEvent(Event.UPDATA_BLUE)
    end
end

return CollectedFailureScene
