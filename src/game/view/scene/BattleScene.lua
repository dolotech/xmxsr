-- 战斗场景

local MonsterData = require("game.data.MonsterData")
local Monster = require("game.view.battle.Monster")
local BattleEvent = require("game.view.battle.BattleEvent")
--战斗场景
local battleScene = class("BattleScene",function()
	return require("game.view.base.BaseScene"):create()
end)

--创建
function battleScene:create(param)
    local scene = battleScene.new(param)
    scene:setNodeEventEnabled()
    return scene
end

--初始化
function battleScene:ctor(param)   
    self.param = param
    self.eventHandle = require("game.event.EventHandle").new(self)
end

--清除
function battleScene:onCleanup()
    -- SceneManager.renmoveCache()
    -- unschedulerUpdate(self)
end
function battleScene:onExit()
    SceneManager.renmoveCache()
end

--进入
function battleScene:onEnter()   
    self.FlyToModel  = require("game.view.comm.FlyToModel"):create()
   
    if Audio.currentBGM~=Sound.MUSIC_BATTLE_BGM then
        Audio.playMusic(Sound.MUSIC_BATTLE_BGM ,true)   
    end

    self:crateUI()
    self:createRole()
    self:createMonster()
    self:createMap(self.param)
    
    self:createControl()
    self.elementLayer.eliminateWidget:setUpdateScoreL(handler(self, self.updateScore))
    self.clsToolBar.autoBubble = self.elementLayer.autoBubble

    self:battleStart() 
    self.eventHandle:itEventData("battle",Global.selChapterId-1001)

    TalkingData.onTaskBegin(Language.Statistics_Task..Global.selChapterId)
end

function battleScene:update( _delta )
    self.eventHandle:runEvent(_delta)
end

--事件
function battleScene:GetChildByScene( _tStrs )
    local originalName = table.remove(_tStrs,1)
    local name = originalName..".csb"
    local node = nil
    if(name == Csbs.NODE_GOALS_CSB)then
        node = self.leftTopBtn:getChildByNameFo(_tStrs)
    elseif(name==Csbs.NODE_MOVES_CSB)then
        node = self.rigthTopBtn:getChildByNameFo(_tStrs)
    elseif(name==Csbs.NODE_BATTLE_TOOL_CSB)then
        node = self.clsToolBar:getChildByNameFo(_tStrs)
    elseif(name==Csbs.NODE_BATTLE_STAR_CSB)then
        node = self.starbar:getChildByNameFo(_tStrs)
    else
        node = self.ui:getChildByNameFo(_tStrs)
    end
    -- print("-------battleScene.GetChildByScene]",originalName,node)
    return node
end

----------------------------------------------------------
--建立控制层
function battleScene:createControl()
    local data = {}
    data.pets = self.pets
    data.monsters = self.monsters

    data.leftTopBtn = self.leftTopBtn
    data.rigthTopBtn = self.rigthTopBtn
    data.petSkillInfo = self.petSkillInfo

    data.tollgate = self.param.tollgate

    data.elementLayer = self.elementLayer
    -- data.hideMaskLayer = handler(self.elementLayer,self.elementLayer.activateFallEngine)
    -- data.touchEnabled = handler(self.elementLayer,self.elementLayer.touchEnabled)

    data.updateScore = handler(self,self.updateScore)
    data.battleScene = self
    
    self.BattleControl = require("game.view.battle.BattleControl"):create(data) 
    self.isfall = false
end
--创建UI
function battleScene:crateUI()
    -- 创建游戏UI
    local ui = display.createUI(Prefix.PRES_SCENE_PICTURE..self.param.tollgate.sceneID..CSB)
    ui:stageBottom(-Config.DATA_DESIGN_WIDTH/2,Config.BATTLE_SCENE_OFFSET_HEIGHT)
    self:addToBgLayer(ui)
    local bar = cc.Sprite:create(Prefix.PRES_SCENE_PICTURE.."res/"..self.param.tollgate.barID..PNG)
    bar:setAnchorPoint(0,0.5)
    bar:setPosition(offSetX,625 + Config.BATTLE_SCENE_OFFSET_HEIGHT)
    self:addToRoleLayer(bar)
    self.ui = ui

    self.imgBgAni = self.ui:getChildByName("imgBg2")
    self.imgBgAni.loc = cc.p(self.imgBgAni:getPosition())
    self.imgBgAni:setVisible(false)
    self:addEventListener(BattleEvent.BgAni, handler(self, self.BgAni))
    ---------------------------------------------------------------------------------------------------------------------------------
    
    --收集任务条件
    local leftTopBtn = display.createUI(Csbs.NODE_GOALS_CSB)
    leftTopBtn:stageLeftTop()
    self:addToUILayer(leftTopBtn)
    self.leftTopBtn = leftTopBtn
    Color.setLableShadows({leftTopBtn:getChildByName("Text_0"),leftTopBtn:getChildByName("Text_1"),leftTopBtn:getChildByName("Text_2")})

    --剩余步数
    local rigthTopBtn = display.createUI(Csbs.NODE_MOVES_CSB)
    rigthTopBtn:stageRightTop()
    self:addToUILayer(rigthTopBtn)
    self.rigthTopBtn = rigthTopBtn
    Color.setLableShadows({rigthTopBtn:getChildByName("Text_0"), rigthTopBtn:getChildByName("Text_1")})
    self.rigthTopBtn:getChildByName("Button_1"):addEventListener(BattleEvent.HideSkillInfoLayer, function()
        self.petSkillInfo:setInfoVisible(false)
        self:isBDGamePauses()
    end)
    
    --战斗道具工具条
    local toolbar = require("game.view.battle.ToolBarLayer").new(self.param.tollgate)
    self.clsToolBar = toolbar
    toolbar:stageBottom()
    self:addToUILayer(toolbar) 

    --评星条
    local starbar = display.createUI(Csbs.NODE_BATTLE_STAR_CSB)
    starbar:stageTop()
    self:addToBgLayer(starbar)
    self.starbar = starbar
    self.loadStarBar = starbar:getChildByName("LoadingBar")
    self:setStarLoc()
    self.starBarLight = self.loadStarBar:getChildByName("imgLight")
end

function battleScene:isBDGamePauses()
    if(DPayCenter.platform == "baidu" and device.platform == "android") then
        local luaj = require("cocos.cocos2d.luaj")
        local javaClassName = "org.cocos2dx.lua.AppActivity"
        local javaMethodName = "isBDGamePause"
        local sig = "()V"
        local args ={}
        luaj.callStaticMethod(javaClassName, javaMethodName, args, sig)
    end
end

--改变星星位置
function battleScene:setStarLoc()
    local starArr = self.param.tollgate.score.star
    local scoreMax = starArr[3]
    local size = self.loadStarBar:getContentSize()
    local x,y = self.loadStarBar:getPosition()
    local imgStar = self.starbar:getChildByName("imgStar1")
    local var = starArr[1]*size.width/scoreMax
    imgStar:setPositionX(x+5+var)
    imgStar = self.starbar:getChildByName("imgStar2")
    var = starArr[2]*size.width/scoreMax
    imgStar:setPositionX(x+var)
end

--更新分数
function battleScene:updateScore(dataArr)
    local array = self.param.tollgate.score
    --fun
    local function animationStar( _imgStar )
            local effect = display.createEffect(Prefix.PREOPE_STAR_NAME,"Animation1",nil,true,false)
            effect:setPosition(_imgStar:getPosition())
            _imgStar:addChildWithAnchor(effect)
            Audio.playSound(Sound.SOUND_STARLEVEL)
            tween.scaleBock(_imgStar,0.1,1.5,1)
    end 
    local function updates(_param)
        self.param.tollgate.scoreVar = self.param.tollgate.scoreVar + _param.value
        -- self.param.tollgate.scoreVar = self.param.tollgate.scoreVar/2
        if _param.winend ~= nil then 
            local starNum = self:getStar(self.param.tollgate)
            if(starNum == 0)then 
                self.param.tollgate.scoreVar = array.star[1]
            end
        end

        local percent = self.param.tollgate.scoreVar/array.star[3]
        percent = math.min(percent,0.96)
        local size = self.loadStarBar:getContentSize()
        self.loadStarBar:setPercent(percent*100)
        self.starBarLight:setPositionX(size.width*percent)
        if(percent>0.5)then percent = 1-percent end
        self.starBarLight:setScaleY(0.6+percent)

        --更新星星
        -- print(">>updateScore:"..scoreVar.." / "..scoreMax.."  percent:"..(scoreVar/scoreMax*100).." starNum:"..starNum)
        -- printf(">>>>>dataArr:", dataArr.len, dataArr.moves, dataArr.winend)
        local starNum = self:getStar(self.param.tollgate)
        for i=1,starNum do
            local imgStar = self.starbar:getChildByName("imgStar"..i)
            if(imgStar:getOpacity()~=255)then --播动画
                imgStar:setOpacity(255)
                animationStar(imgStar)
                -- for n=1,i-1 do
                --     animationStar(imgStar:getChildByTag(n))
                -- end
            end
        end
    end
    
    if dataArr.moves ~= nil and dataArr.moves > 0 then 
        local point = self.rigthTopBtn:getChildByName("Sprite_1"):convertToWorldSpaceAR(cc.p(self:getPosition()))
        for i=1,dataArr.moves do
            local rand,winend_ = math.random(50,100)/100,nil
            if(i == dataArr.moves)then winend_ = true end
            self.FlyToModel:spriteMoveEaseOut(Picture.RES_PARTICLE_STAR_PNG, point, self:getStarBarPoint(),
                0.5, 1, Config.Grid_MAX_Pix_Width, 0, rand + 0.3, rand, nil, handler({value = array.step, winend = winend_}, updates), 0.2*(i-1))
        end
    end
    
    if dataArr.eleData ~= nil then
        local rand = math.random(50, 100) / 100
        local type = dataArr.eleData.widget.eliminate.type
        local color = cc.c3b(255, 243, 175)
        if(type == 1)then color = cc.c3b(255, 175, 243)
        elseif(type == 2)then color = cc.c3b(255, 186, 175)
        elseif(type == 3)then color = cc.c3b(175, 255, 179)
        elseif(type == 4)then color = cc.c3b(175, 230, 255)
        end
        self.FlyToModel:spriteMoveEaseOut(Picture.RES_PARTICLE_STAR_PNG, dataArr.eleData:offSetPoint(), self:getStarBarPoint(),
            0.5, 1, Config.Grid_MAX_Pix_Width, 0, rand + 0.3, rand, color, handler({value = array.base * self:ScoreRatio(dataArr.len)}, updates))
    end
end

function battleScene:getStar(tollgate)  
    local star, array, scorevar = 0, tollgate.score, tollgate.scoreVar
    if scorevar >= array.star[3] then star = 3
    elseif scorevar >= array.star[2] then star = 2
    elseif scorevar >= array.star[1] then star = 1
    end
    return star
end
--获取分数倍率
function battleScene:ScoreRatio(len)
    local multiple = self.param.tollgate.score.multiple
    if len <= multiple[1] then return 1
    elseif len <= multiple[2] then return 1.2
    elseif len <= multiple[3] then return 1.5
    else return 2
    end
end

--星条比例位置
function battleScene:getStarBarPoint()
    local p = self.starBarLight:convertToWorldSpaceAR(cc.p(self:getPosition()))
    return p
end

function battleScene:getDefType()
    return self.BattleControl.defType
end

-- 连线完成，攻击怪物
function battleScene:onLayerEvent(event)
    local dataArr = event._userdata
    self.BattleControl:battleMonster(event._eventName,dataArr)
end

--从关卡编辑器复原游戏关卡,关卡编辑器导出的关卡文件是Lua程序文件，可以直接读取
function battleScene:createMap(param)

    local mapData = require("game.map." .. param.tollgate.mapID)
    local width = Config.Element_Grid_Width * Config.Grid_MAX_Pix_Width
    local height = Config.Element_Grid_Height * Config.Grid_MAX_Pix_Height

    -- 背景层,设定为关卡编辑器的底层。背景层不参与游戏逻辑的计算
    local bameBackgroundLayer =  require("game.view.battle.GameBackgroundLayer"):create(mapData.layers[1].data,mapData.layers[2].data)
    bameBackgroundLayer:setPosition((stageWidth-width + Config.Grid_MAX_Pix_Width) * 0.5 ,-Config.Grid_MAX_Pix_Height*0.3 + Config.BATTLE_SCENE_OFFSET_HEIGHT)
    self:addToGameLayer(bameBackgroundLayer)

    -- 游戏格子层
    local elementLayerData = require("game.data.ElementLayerData"):create(param.tollgate)
    local elementLayer =  require("game.view.battle.ElementLayer"):create(elementLayerData, {clsToolBar = self.clsToolBar})
    elementLayer:setPosition((stageWidth-width +Config.Grid_MAX_Pix_Width) * 0.5 ,-Config.Grid_MAX_Pix_Height * 0.3 + Config.BATTLE_SCENE_OFFSET_HEIGHT)
    self:addToGameLayer(elementLayer)
    self.elementLayer = elementLayer
    elementLayer:setDefTypeFun(handler(self,self.getDefType))

    self.petSkillInfo  = require("game.view.battle.SkillInfoLayer"):create()
    self.petSkillInfo:setInfoVisible(false)
    self:addToUILayer(self.petSkillInfo)

    SceneManager.currentScene:addEventListener(BattleEvent.OnDropMonsterSkill,handler(self,self.OnDropMonsterSkill))
    self.petSkillInfo:addEventListener(BattleEvent.OnDropPetSkill,handler(self,self.OnDropPetSkill))

    self.elementLayer:addEventListener(BattleEvent.OnConnectBack,handler(self,self.onLayerEvent))
    self.elementLayer:addEventListener(BattleEvent.OnConnected,handler(self,self.onLayerEvent))
    self.elementLayer:addEventListener(BattleEvent.OnDeleteComplete,handler(self,self.onLayerEvent))
    self.elementLayer:addEventListener(BattleEvent.OnDeleteOne,handler(self,self.onLayerEvent))
    self.elementLayer:addEventListener(BattleEvent.OnTouchBegan,handler(self,self.onLayerEvent))
    self.elementLayer:addEventListener(BattleEvent.OnTouchEnd,handler(self,self.onLayerEvent))
    self.elementLayer:addEventListener(BattleEvent.OnTouchEndDelete,handler(self,self.onLayerEvent))
    self.elementLayer:addEventListener(BattleEvent.UPDATE_DATA,handler(self,self.onLayerEvent))

    self.elementLayer:addEventListener(BattleEvent.NEWBIE_EVENT,handler(self,self.newbieEvent))

    self.elementLayer:addEventListener(BattleEvent.NON_THREE_IN_ALL,handler(self,self.nonThree))
    self.elementLayer:addEventListener(BattleEvent.FALL_COMPLETE,handler(self,self.fallComlete))

    self:addEventListener(BattleEvent.OnUpDataMoves,handler(self,self.OnUpDataMoves))
    self:addEventListener(BattleEvent.OnBattleWin,handler(self,self.OnBattleWin))
end

-- 新手教程完成事件
function battleScene:newbieEvent()
    self.eventHandle.newbiestate = 2
end

-- 所以道具下落完成
function battleScene:fallComlete()
    if self.isfall==false then
        self.isfall = true
        self.BattleControl:checkSkill()--检测怪物技能 -->检测宠物技能-->是否胜利-->是否没步数
    end
end

--掉落怪物技能
function battleScene:OnDropMonsterSkill(event)
    local skills = event._userdata
    if(skills == nil)then 
        self.BattleControl:chenkKillAuotDrop()--再检测宠物技能
        return 
    end
    
    local count = 0
    local function complete(arr)
        self.elementLayer:dropGoods(arr[1],arr[2])
        --再检测宠物技能 
        count = count - 1
        if count<1 then self:checkPacman() end
    end
    
    local len = #skills
    if len > 0 then --长度>0时是怪物技能释放(怪物放完技能后宠物才放技能)
        local tElements = self.elementLayer.autoBubble:searchMonstetGoods()
        count = math.min(len, #tElements)
        local x, y = self.ui:getChildByName("monster"):getPosition()
        local starPoint, eleLen = cc.p(x+offSetX,y), 0
        for i = 1,len do
            eleLen = #tElements
            if(eleLen < 1)then break end
            local goodsData = skills[i]
            local rand = random_range(1, eleLen)
            local elementData = table.remove(tElements, rand)
            self.FlyToModel:battleMonsterSkilModel(elementData,goodsData,starPoint,handler({elementData,goodsData},complete))
        end
    else --怪物没有技能，检查宠物技能
        self:checkPacman()
    end
end

--检测蝙蝠移动
function battleScene:checkPacman()
    local list = self.elementLayer.autoBubble:searchPacman(self.elementLayer.widgets)
    if(list)then --有能够移动的蝙蝠
        local count = #list
        function finishCallBack()
            count = count - 1
            if(count<1)then 
                self.elementLayer:onEngineStart()
            end
        end

        for i,v in ipairs(list) do
            v[1]:pacmanAction(v[2], finishCallBack)
        end
    else
        self.BattleControl:chenkKillAuotDrop()--再检测宠物技能
    end
end

--掉落宠物技能
function battleScene:OnDropPetSkill(event)
    if event._userdata==nil then
        self.BattleControl:checkBattleWin()
        return
    end

    local list = event._userdata
    local tElements = self.elementLayer.autoBubble:searchRoleSkill()
    local function getElement()
        local index, result = 0, nil
        for i,v in ipairs(tElements) do
            if result == nil or result.y < v.y then
                result = v
                index = i
            end
        end
        if(index > 0)then table.remove(tElements, index) end
        return result
    end

    local count = math.min(#list, #tElements)
    for i,v in ipairs(list) do
        local elementData = getElement()
        if(elementData == nil)then break end
        self.pets[v.index]:playTrump()--扔法宝
        local starPoint = cc.p(v.skill:getPositionX(),v.skill:getPositionY())
        self.FlyToModel:battlePetSkilModel(elementData,v.skillData,starPoint,function()
            v.skill:setVisible(false)
            self.elementLayer:dropSkill(elementData,v.skillData)
            count = count - 1
            if count<1 then self.BattleControl:checkBattleWin() end
        end)
    end
end

--战斗胜利
function battleScene:OnBattleWin(event)
    if event._userdata==nil then --没有数据进入可行动的下一轮
        self.isfall = false
        local bool = self.BattleControl:checkMoves()
        if bool==false then
            self.elementLayer:checkThreeWidgetInAll()
        end
        -- print("=========================OnBattleWin  event._userdata==nil")
    else --有数据 处理胜利
        -- print("=========================OnBattleWin")
        self.getWinData = event._userdata
        local point = SharedManager:readData(Config.POINT)
        -- self.star = self:saveStar(self.getWinData)
        if point<tonumber(self.getWinData.tollgate.id)+1 then--首次通关
            point = point+1
            Config.OPEN_LOCK_ID = point
            SharedManager:saveData(Config.POINT,point,true)
        end
        self.elementLayer:hideMaskLayer()
        TalkingData.onTaskCompleted(Language.Statistics_Task..point)
        performWithDelay(self,function()

            for key, role in pairs(self.pets) do  --播放2秒胜利动作
                role:playWin()--胜利动作
            end
            Audio.playSound(Sound.SOUND_WIN)
            self:playWinEffect()

            -- if Config.OPEN_LOCK_ID~=0 and tonumber(self.getWinData.tollgate.id) > Config.OPEN_KEY_POINT then--正常关卡
            --     self:starRewad()
            --     self:addEventListener(BattleEvent.OnDeleteComplete, function() self:starRewad() end)
            -- else --新手关卡
            --     for key, role in pairs(self.pets) do  --播放2秒胜利动作
            --         role:playWin()--胜利动作
            --     end
            --     self:playWinEffect()
            -- end
        end,1)
    end
end

--保存评星
function battleScene:saveStar(windata)
    local tollgate = windata.tollgate
    local star = self:getStar(tollgate)
    local index = tollgate.id
    local data = SharedManager:readData(tostring(index),Config.POINT_DATA_DUALFT)
    if star > data.star then
        local starData = SharedManager:readData(Config.Star)
        if(starData.count == nil)then starData.count = 0 end
        starData.count = starData.count + (star - data.star)
        SharedManager:saveData(Config.Star,starData,true)
        --self:dipatchGlobalEvent(Event.UPDATA_STARCOUNT)
        data.star = star
        SharedManager:saveData(tostring(index),data,true)
    end
    return star
end

--播放胜利动画
function battleScene:playWinEffect()
    -- if self.starBar==nil then
    --     self.starBar = require("game.view.embattle.StarEvaluation"):create()
    --     self.starBar:playStar(self.star)
    --     self.starBar:stageCenter(offSetX-105,300)
    --     self:addToEffectLayer(self.starBar)
    -- end

    self.effect = display.createEffect(Prefix.PREOPE_WIN_NAME,Prefix.PREOPE_WIN_NAME,function()
        local bRewad = Config.OPEN_LOCK_ID~=0 and tonumber(self.getWinData.tollgate.id) > Config.OPEN_KEY_POINT
        self:starRewad(bRewad)
        self:removeEventListener(BattleEvent.OnDeleteComplete)
        self:addEventListener(BattleEvent.OnDeleteComplete, function() self:starRewad(bRewad) end)
    end,true,true)
    self.effect:stageCenter(0,340)
    self:addToEffectLayer(self.effect)
end

--奖励技能完成
function battleScene:starRewad(_bRewad)
    local elementData = self.elementLayer.gameoverToRewards:getSkill()
    local function trigger(_elementData, _bRewad)
        Audio.playSound(Sound.SOUND_BATTLE_CHOSE)
        self.elementLayer.gameoverToRewards:triggerSkill(_elementData, _bRewad)
    end
    -- printy("-------starRewad] elementData:",elementData)
    if elementData then--地图有技能元素时，触发技能
        trigger(elementData, _bRewad)
        -- schedulerWithDelay(handler(elementData,trigger), 0.1+Config.MOVW_WIN_INTERVAL)
        -- printy(">>schedulerWithDelay: ",elementData)
        -- self.FlyToModel:flyDropModel(Picture.RES_STEPS_PNG,cc.p(740+offSetX,990),elementData:offSetPoint(),1,1,1,nil,handler(elementData,trigger),2,0.1,Config.MOVW_WIN_INTERVAL)
    else
        -- self.elementLayer:hideMaskLayer()
        self.elementLayer:onEngineStart(nil, true)
        -- self:randRewardCompetele(_bRewad) 
        self:removeEventListener(BattleEvent.OnDeleteComplete)
        self:addEventListener(BattleEvent.OnDeleteComplete, function() self:randRewardCompetele(_bRewad) end)
    end
end

--更新步数
function battleScene:OnUpDataMoves()
    self.elementLayer:activateFallEngine(false)--隐藏遮罩可以掉落
    self.elementLayer:touchEnabled(false)--可以点击
end

--随机步数奖励完成
function battleScene:randRewardCompetele(_bRewad)
    self:removeEventListener(BattleEvent.OnDeleteComplete)
    self:addEventListener(BattleEvent.OnDeleteComplete, function() self:randRewardCompeteleFinal() end)

    local elementDatas = self.elementLayer.gameoverToRewards:getRandElement(self.BattleControl.GoalsControl.moves)
    if elementDatas then
        self.rewardLen = 0
        local len, n, tList = 0, 0, {}
        local function trigger(_elementData)
            Audio.playSound(Sound.SOUND_BATTLE_CHOSE)
            -- self:updateScore({len = 1, eleData = _elementData})
            --创建炸弹动画
            local goods = self.clsToolBar:createBombSprite(_elementData)
            goods:setScale(0)
            goods:scaleTo(0.2,1)
            self:addToEffectLayer(goods)
            n=n+1 tList[n] = {eleData = _elementData, sprite = goods}
            len = len - 1
            if(len < 1)then 
                self.elementLayer.gameoverToRewards:triggerElement(tList, self.clsToolBar, _bRewad)
            end
        end

        local starPoint = self.rigthTopBtn:getChildByName("Sprite_1"):convertToWorldSpaceAR(cc.p(self.uiLayer:getPosition()))
        for k,v in pairs(elementDatas) do
            self:performWithDelay(function()
                self.BattleControl.GoalsControl:updataMoves(true)
                self.FlyToModel:flyDropModelParticle(Picture.PARTICLE_XINGXING, starPoint, v:offSetPoint(), 1, 1.5, 0.5, nil,
                    handler(v, trigger), 2, 0.1, Config.MOVW_WIN_INTERVAL)
            end, 0.3 * len)
            len = len + 1
            self.rewardLen = self.rewardLen + 1
        end
    else 
        self:changeSceneForCollectedWin()
    end
end
function battleScene:changeSceneForCollectedWin()
    self:performWithDelay(function()
        self.star = self:saveStar(self.getWinData)
        SceneManager.changeScene(Scene.CollectedWin, {winData = self.getWinData, starNum = self.star}, 
            function(scene)
                return cc.TransitionFade:create(0.6, scene)
            end)
    end,1.6)
end
function battleScene:randRewardCompeteleFinal()
    self.rewardLen = self.rewardLen - 1
    if(self.rewardLen < 1)then self:changeSceneForCollectedWin() end
end

--战斗失败
function battleScene:nonThree()
    local function delay()
        SceneManager.changeScene("game.view.scene.CollectedFailureScene",{id=self.param.tollgate.id})
    end
    performWithDelay(self,delay,1)
end

--创建怪物血量
function battleScene:createMonster()
    self.monsters = {}
    if self.param.tollgate.monsterID~=nil then
        local index = 0
        for key, var in pairs(self.param.tollgate.monsterID) do
            local monster = Monster:create(clone(MonsterData[tostring(var)]))
            local role1Pos = self.ui:getChildByName("monster")
            monster:setPosition(offSetX+role1Pos:getPositionX(),role1Pos:getPositionY()+20)--适配宽度位置
            monster:playIdle()
            self:addToRoleLayer(monster,1)
            index = index+1
            self.monsters[index] = monster
            if index>1 then
            	monster:setVisible(false)
            end
        end
    end
end

-- 创建战斗内角色形象
function battleScene:createRole()
    self.pets = {}
    for i=1, Config.DATA_PETTYPE_COUNT, 1 do
        local table = RoleDataManager.getPetsDataBuyType(i)
        if table~=nil then
            for key, var in pairs(table) do
                if var.embattle then --出战状态
                    local role1Pos = self.ui:getChildByName("role_" .. i)
                    local v = Role:create(var)
                    v:setPosition(offSetX+role1Pos:getPositionX(),role1Pos:getPositionY()+Config.BATTLE_SCENE_OFFSET_HEIGHT)--适配宽度位置
                    self:addToRoleLayer(v,1001+i)
                    v:playIdle()
                    v:setTouchEnded(function()
                        self.petSkillInfo:setInfoVisible(true)
                    end)
                    self.pets[i] = v
                    break 
                end
            end
        end
     end
end

--开战收集提示
function battleScene:battleStart() 
    local maskLayer = display.createMaskLayer(cc.rect(0,0,stageWidth,stageHeight),0,0)
    self:addToUILayer(maskLayer)
    local startLayer = display.createUI(Csbs.NODE_STARTBATTLE_CSB)
    startLayer:setPosition(-stageWidth*0.5, stageHeight*0.5)
    self:addToUILayer(startLayer)
    local function battleEnd()
        maskLayer:removeFromParent()
        startLayer:removeFromParent()
        self:schedule(self.update,0.1)
        -- schedulerUpdate(self, handler(self, self.update))
    end
    ------ 创建目标 
    local panel = startLayer:getChildByNameFo("imgBg","panel")
    local cell = panel:getChildByName("cellTarget")
    local locCell = cc.p(cell:getPosition())
    local sizePanel = panel:getContentSize()
    local offx,count,len,interval = 0,0,0,100
    if(self.param.tollgate.targetmonster and self.param.tollgate.targetmonster > 0)then len = len + 1 end
    if(self.param.tollgate.target)then len = len + table.nums(self.param.tollgate.target) end
    offx = (sizePanel.width - interval * (len - 1)) * 0.5

    local function setTarget( _strPath, _nCount, _nScale )
        _nScale = _nScale or 1
        count = count + 1
        local u = cell
        if(count~=1)then 
            u = cell:clone()
            panel:addChild(u)
        end
        u:setTag(count)
        u:setPosition(cc.p(offx+(count-1)*interval,locCell.y))
        u:getChildByName("label"):setString("x".._nCount)
        u.path = _strPath
        u.scalebase = _nScale
        local image = u:getChildByName("image")
        image:loadTexture(_strPath,1)
        image:setScale(_nScale) 
    end
    if(self.param.tollgate.targetmonster and self.param.tollgate.targetmonster > 0)then
        setTarget(Picture.RES_MONSTER_PNG, self.param.tollgate.targetmonster, 0.75)
    end
    if self.param.tollgate.target then
        for id, var in pairs(self.param.tollgate.target) do
            local goods = GoodsData[id] 
            setTarget(Prefix.PREBATTLE_PICTURE .. goods.picture .. PNG, var)
        end
    end

    ------ 动画
    local function startAni()
        Audio.playSound(Sound.SOUND_BATTLE_ACTION,false)
        local function itCellAni()
            for i=1,len do
                local cell = panel:getChildByTag(i)
                cell:getChildByName("image"):setVisible(false)
                local label = cell:getChildByName("label")
                label:runAction(cc.Sequence:create(
                    cc.FadeOut:create(0.3)
                ))
                local image = ccui.ImageView:create()
                image:loadTexture(cell.path, 1)
                self:addToEffectLayer(image)
                local viewSprite = self.leftTopBtn:getChildByName("Sprite_"..i)
                local endPoint = viewSprite:convertToWSAR(self)
                image:setPosition(cell:convertToWSAR(self))
                image:setScale(cell.scalebase)
                image:runAction(cc.Sequence:create(
                    cc.DelayTime:create(0.2*i),
                    cc.ScaleTo:create(0.3,cell.scalebase+0.2),
                    cc.ScaleTo:create(0.3,cell.scalebase),
                    cc.Spawn:create(cc.EaseIn:create(cc.MoveTo:create(1,endPoint),5),cc.ScaleTo:create(1,0.5)),
                    cc.CallFunc:create(function()
                        self.leftTopBtn:getChildByName("Text_"..i):setVisible(true)
                        local scale = viewSprite:getScale()
                        viewSprite:setScale(scale+0.2)
                        viewSprite:scaleTo(0.3,scale)
                        image:removeFromParent()
                    end)    
                ))
            end
        end
        
        startLayer:setOpacity(0)
        startLayer:runAction(cc.Sequence:create(
            cc.Spawn:create(cc.FadeIn:create(0.3),cc.EaseIn:create(cc.MoveTo:create(0.3, cc.p(stageWidth*0.5+50, stageHeight*0.5)),2)),
            cc.MoveTo:create(0.1, cc.p(stageWidth*0.5, stageHeight*0.5)),
            cc.DelayTime:create(0.8),
            cc.CallFunc:create(itCellAni),
            cc.DelayTime:create(1),
            cc.Spawn:create(cc.FadeOut:create(0.5),cc.MoveTo:create(0.4, cc.p(stageWidth*1.5, stageHeight*0.5))),
            cc.CallFunc:create(battleEnd)
        ))
    end
    local seq = cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(startAni))
    self:runAction(seq)
end

return battleScene
