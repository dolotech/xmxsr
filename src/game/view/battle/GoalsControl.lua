-- 战斗内更新战斗目标任务数据显示

local GoalsControl = class("GoalsControl")
GoalsControl.__index = GoalsControl
local BattleEvent = require("game.view.battle.BattleEvent")

function GoalsControl:create(goalsUi, movesUi, tollgate, updateScore)
    local instance = GoalsControl.new(goalsUi, movesUi, tollgate, updateScore)
    return instance
end

function GoalsControl:ctor(goalsUi, movesUi, tollgate, updateScore)
    self.goalsUi = goalsUi
    self.movesUi = movesUi
    self.tollgate = tollgate
    self.win = false
    self.faiule = false
    self.updateScore = updateScore
    
    --获取有用物品
    self.getGoods = {}
    self.moves = self.tollgate.moves
    self:initView()
    
    self.moveSpeakBool = false
end

--初始化
function GoalsControl:initView()
    local index = 0
    self.data = {}
    
    if self.tollgate.targetmonster ~= nil and self.tollgate.targetmonster > 0 then
        index = index + 1
        local image = self.goalsUi:getChildByName("Sprite_" ..index)
        image:setScale(0.5)
        local text = self.goalsUi:getChildByName("Text_" ..index)
        local guo = self.goalsUi:getChildByName("guo_" ..index)
        self.data["monster"] = {num=self.tollgate.targetmonster, index = index, text = text, guo = guo}
        local  frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(Picture.RES_MONSTER_PNG)
        image:setSpriteFrame(frame)
        text:setString(tostring(self.tollgate.targetmonster))
        text:setVisible(false)
    end
    
    if self.tollgate.target ~= nil then
        local target = self.tollgate.target
        for id, var in pairs(target) do
            index = index + 1
            local image = self.goalsUi:getChildByName("Sprite_" ..index)
            local text = self.goalsUi:getChildByName("Text_" ..index)
            local guo = self.goalsUi:getChildByName("guo_" ..index)
            local goods = GoodsData[id]
            self.data[tostring(id)] = {num = var, index = index, text = text, guo = guo}
            local  frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(Prefix.PREBATTLE_PICTURE .. goods.picture .. PNG)
            image:setSpriteFrame(frame)
            text:setString(tostring(var))
            text:setVisible(false)
    	end
    end
    
    self.movesUi:getChildByName("Button_1"):onClick(function()
            self.goalsUi:dispatchEvent(BattleEvent.HideSkillInfoLayer)
            DialogManager:open("game.view.battle.GiveUpDialog",{data = self.data, id = self.tollgate.id, getGoods = self.getGoods})
        end,
    true)
    
    self.movesUi:getChildByName("Text_1"):setString(tostring(self.moves))
    for i = index + 1, 3, 1 do
        self.goalsUi:getChildByName("Sprite_" ..i):setVisible(false)
        self.goalsUi:getChildByName("Text_" ..i):setVisible(false)
    end
    self.movesUi:addEventListener(BattleEvent.OnUpDataMoves, handler(self, self.OnUpDataMoves))
    self.movesUi:addEventListener(BattleEvent.OnBattleSpeak, handler(self, self.speakHandler))
    
    self.speakElves = require("game.view.comm.SpeakElves"):create()
    
    SceneManager.currentScene:addToEffectLayer(self.speakElves)
end

--购买成功步数+5
function GoalsControl:OnUpDataMoves(event, data)
    self.faiule = false
    self.moves = self.moves+DPayCenter.getShopDataById(Config.PLAY_ID6).num
    self.movesUi:getChildByName("Sprite_1"):setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(Prefix.PREMOVES_NNG .. 3 .. PNG))
    self.movesUi:getChildByName("Text_1"):setString(tostring(self.moves))
end

--获取可得物品(钻石，钥匙，黄色材料，蓝色材料)
function GoalsControl:updataGetGoods(drop)
    if self.getGoods[tostring(drop.id)] == nil then
        self.getGoods[tostring(drop.id)] = drop.count
    else
        local value = self.getGoods[tostring(drop.id)]
        self.getGoods[tostring(drop.id)] = value + drop.count
    end
end

--更新收集
function GoalsControl:updataGolas(id)
    local bool = false
    local data = self.data[tostring(id)]
    if data ~= nil then
        data.num = data.num - 1
        if data.num <= 0 then
            data.num = 0
            bool = true
            data.text:setVisible(false)
            self:showGuo(data.guo)
        else
            data.text:setString(tostring(data.num))
            data.text:setScale(1.15)
            tween.scaleBock(data.text, 0.15, 1.5, 1)
        end
    end
    return bool
end

--更新怪物个数
function GoalsControl:updataMoster()
    local data = self.data["monster"]
    if data ~= nil then
        data.num = data.num - 1
        if data.num <= 0 then
            data.num = 0
            data.text:setVisible(false)
            self:showGuo(data.guo)
        else
            data.text:setString(tostring(data.num))
            data.text:setScale(1.15)
            tween.scaleBock(data.text, 0.15, 1.5, 1)
        end
    end
end

--显示打钩
function GoalsControl:showGuo(guo)
    if guo:isVisible()== false then
        guo:setVisible(true)
        guo:setScale(0.05, 0.05)
        local qequence = cc.Sequence:create(
           cc.EaseBackOut:create(cc.ScaleTo:create(0.85,0.5,0.5)),
           cc.EaseBackOut:create(cc.ScaleTo:create(0.1,0.45,0.45)),
           cc.EaseBackOut:create(cc.ScaleTo:create(0.1,0.55, 0.55)))
        guo:runAction(qequence)
    end
end

--更新步数
function GoalsControl:updataMoves(bool)
    self.moves = self.moves - 1
    if self.moves <= 0 then
    	self.moves = 0
        self.movesUi:getChildByName("Text_1"):setString(tostring(self.moves))
        if(self.moveuiAni)then self.movesUi:getChildByName("Sprite_1"):stopAction(self.moveuiAni) end
        return
    end
    
    local sp = self.movesUi:getChildByName("Sprite_1")
    self.movesUi:getChildByName("Text_1"):setString(tostring(self.moves))
    if bool==true then
        sp:setScale(1)
        if(self.moveuiAni)then sp:stopAction(self.moveuiAni) end
    	return
    end
    
    local frame = nil
    if self.moves <= 3 then
        frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(Prefix.PREMOVES_NNG .. 2 .. PNG)
        sp:setSpriteFrame(frame)
        
        sp:setScale(0.7)
        local scaleTo1 = cc.ScaleTo:create(1, 1, 1)
        local scaleTo2 = cc.ScaleTo:create(1, 0.7, 0.7)
        local seq = cc.Sequence:create(scaleTo1, scaleTo2)
        seq = cc.RepeatForever:create(seq)
        self.moveuiAni = sp:runAction(seq)
    elseif self.moves <= 5 then
        frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(Prefix.PREMOVES_NNG .. 3 .. PNG)
        sp:setSpriteFrame(frame)
    end
end

--检测任务目标是否完成
function GoalsControl:chenkGoadls(type)
    local bool = false
    if type == 0 then --完成全部目标条件
        bool = true
        for key, var in pairs(self.data) do
            if var.num > 0 then bool = false break end
    	end
        if bool == true then
            self:collectedWin()
        else
            self.movesUi:dispatchEvent(Event.zhadan,{moves = self.moves, data = self.data, speakElves = self.speakElves})
            self.movesUi:dispatchEvent(BattleEvent.OnBattleWin)
            if self.moves == 5 
            and self.faiule == false 
            and self.win == false 
            and not self.moveSpeakBool
            then
                self.moveSpeakBool = true
                self.speakElves:speak(Language.Speak_Moves_Out)
            end
    	end
    elseif type == 1 then--使用完步数
        if self.moves <= 0 then
            bool = true
            self:collectedFailure()
        else
        
        end
	elseif type == 2 then--打败全部怪物
	 
    elseif type == 3 then--完成任务目标1 
     
    elseif type == 4 then--完成任务目标2
    
    elseif type == 5 then--完成任务目标3
    
	end
    return bool
end

--说话提示
function GoalsControl:speakHandler(event)
    local text = event._userdata
    self.speakElves:speak(text)
end

--收集成功
function GoalsControl:collectedWin()
    if self.win == true then return end
    self.win = true
    self.updateScore({moves = self.moves, winend = true})
    self.movesUi:dispatchEvent(BattleEvent.OnBattleWin, {tollgate = self.tollgate, getGoods = self.getGoods})
    -- Audio.stopMusic()   
end

--收集失败
function GoalsControl:collectedFailure()
    if self.faiule == false then
        self.faiule = true
        self.movesUi:runAction(cc.Sequence:create(cc.DelayTime:create(1.2), cc.CallFunc:create(function()
            DialogManager:open("game.view.battle.OutOfMovesDialog", {data = self.data, id = self.tollgate.id, getGoods = self.getGoods} )
        end)))

        local strFailed = "材料"
        if(self.data["monster"]~=nil and self.data["monster"].num>0)then
            strFailed = "怪物"
        elseif((self.data["1"]~=nil and self.data["1"].num>0) 
            or (self.data["2"]~=nil and self.data["2"].num>0) 
            or (self.data["3"]~=nil and self.data["3"].num>0) 
            or (self.data["4"]~=nil and self.data["4"].num>0) 
            or (self.data["5"]~=nil and self.data["5"].num>0))then
            strFailed = "元素"
        end
        TalkingData.onTaskFailed(Language.Statistics_Task..Global.selChapterId,strFailed)
   end
end

return GoalsControl