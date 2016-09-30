-- 怪物显示对象

local BattleEvent = require("game.view.battle.BattleEvent")


local Monster = class("Monster",function(data)
    return display.createArmature({path="role/"..data.avatar.."/"..data.avatar})
end)


function Monster:create(data)
    local instance = Monster.new(data)
    instance:setScale(data.scale)
    return instance
end

function Monster:ctor(data)
    self.data = data
    self.data.times = {}
    local p = self:getOffsetPoints()
    
    --受击特效
    self.underEffect = display.createArmature({path=Prefix.PREMONSTER_UNDERATTACK,bool=true})
    self.underEffect:setScale(5)
    self:addChild(self.underEffect,100)
    self.underEffect:setPosition(0,math.abs(p.y)+70)
    
   --创建血条 
    self.hpBar = display.createUI(Csbs.NODE_HPBAR_CSB)
    self:addChild(self.hpBar,100)
    self.hpBar:setPosition(0,self.data.hpy)
    self.data.maxHp = self.data.hp
    local defBtn = self:getDefBtn()
    defBtn:setLocalZOrder(100)
    self.hpBar:setScale(1/data.scale)
    local sprite1 =  self.hpBar:getChildByName("Sprite_1") 
    sprite1:setVisible(false)
    self.progressTimer1 = cc.ProgressTimer:create(sprite1)
    self.progressTimer1:setPosition(0,28)
    self.progressTimer1:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self.progressTimer1:setMidpoint(cc.p(0, 0.5))
    self.progressTimer1:setBarChangeRate(cc.p(1, 0))
    self.progressTimer1:setPercentage(100)
    self.progressTimer1:setName("progressTimer1")
    self.hpBar:addChild(self.progressTimer1,1)
    
    local sprite2 =  self.hpBar:getChildByName("Sprite_2") 
    sprite2:setVisible(false)
    self.progressTimer2 = cc.ProgressTimer:create(sprite2)
    self.progressTimer2:setPosition(0,28)
    self.progressTimer2:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self.progressTimer2:setMidpoint(cc.p(0, 0.5))
    self.progressTimer2:setBarChangeRate(cc.p(1, 0))
    self.progressTimer2:setPercentage(100)
    self.progressTimer2:setName("progressTimer2")
    self.hpBar:addChild(self.progressTimer2,1)
    
    if self.data.immunity~=nil and self.data.immunity>0 then
        local framName = Prefix.PREGET_PET_PATH.. self.data.immunity .. PNG
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(framName)
        defBtn:getChildByName("Sprite_3"):setSpriteFrame(frame)
        
        framName = Prefix.PREGET_DEF_PATH.. self.data.immunity .. PNG
        frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(framName)
        defBtn:getChildByName("Sprite_2"):setSpriteFrame(frame)
        
        defBtn:setVisible(true)
        defBtn:getChildByName("Sprite_1"):setVisible(false)
    else
        defBtn:setVisible(false)
    end
    
    if self.data.skill then
        for key, var in pairs(self.data.skill) do
            self.data.times[key] = 0
        end
    end
  
    local  lable = self:getHpLable()
    Color.setLableShadow(lable)
    lable:setVisible(false)
    lable:setString(self.data.hp .."/" .. self.data.maxHp)
    
    self:addEventListener(BattleEvent.RESUME ,handler(self,self.onPlaye))
    self:addEventListener(BattleEvent.PAUSE ,handler(self,self.onPause))
end

function Monster:onPlaye()
    self:getAnimation():resume()
end

function Monster:onPause()
    self:getAnimation():pause()
end

--获取血条显示文本
function Monster:getHpLable()
    return self.hpBar:getChildByName("Text_1")
end

--获取防御按钮
function Monster:getDefBtn()
    return self.hpBar:getChildByName("Node_def")
end

--获取血条对象1
function Monster:getHpProgress1()
    return self.progressTimer1
end
--获取血条对象2
function Monster:getHpProgress2()
    return self.progressTimer2
end

--更新血量
function Monster:updataHp(bool)
    if self.data.hp<=0 then
    	self.data.hp = 0
    end
    if not bool then
        local  lable = self:getHpLable()
        lable:setString(self.data.hp .."/" .. self.data.hp)
    end
    self.progressTimer1:stopAllActions()
    self.progressTimer1:runAction(cc.ProgressTo:create(0.5,(self.data.hp/self.data.maxHp)*100))
    if self.progressTimer1:getPercentage()<=0 then
    	
    end
end

--道具下落完成才可以丢技能
function Monster:checkKills()
   local skills = {}
   local bool = false
   if  self.data.skill~=nil then
        for key, var in pairs(self.data.times) do
            self.data.times[key] = self.data.times[key] +1
            local rawd = self.data.skill[key]
            if self.data.times[key]>=rawd.times then
                if self.data.hp>0 then
                    self.data.times[key] = 0
                    local goodsData = GoodsData[tostring(rawd.id)]
                    skills[#skills +1] = goodsData
                    bool = true
                end 
            end
        end
    end
    SceneManager.currentScene:dispatchEvent(BattleEvent.OnDropMonsterSkill,skills)
    if bool then
       self:playAttack()
       Audio.playSound(Sound.SOUND_BATTLE_BOSS_SKILL,false)
    end
    return bool
end

--待机
function Monster:playIdle()
    if self:getAnimation():getCurrentMovementID()~=Action.PLAY_IDLE then
        self:getAnimation():play(Action.PLAY_IDLE)
    end
end

--攻击
function Monster:playAttack(commpelete)
    self:getAnimation():setMovementEventCallFunc(
        function(armatureBack,movementType,movementID)
            if movementType == ccs.MovementEventType.complete and movementID==Action.PLAY_ATTACK then
                self:playIdle()
                if commpelete~=nil then
                	commpelete()
                end
            end
        end)
    if self:getAnimation():getCurrentMovementID()~=Action.PLAY_ATTACK then
        self:getAnimation():play(Action.PLAY_ATTACK)
    end
end

--受击
function Monster:playUnderAttack(commpelete)    

    if self.underEffect:getAnimation():getCurrentMovementID()~="effect_003" then
        self.underEffect:getAnimation():play("effect_003")
    end
   
    self:getAnimation():setMovementEventCallFunc(
        function(armatureBack,movementType,movementID)
            if movementType == ccs.MovementEventType.complete and movementID==Action.PLAY_UNDERATTACK then
                self:playIdle()
                if commpelete~=nil then
                    commpelete()
                end
            end
    end)
    
    if self:getAnimation():getCurrentMovementID()~=Action.PLAY_UNDERATTACK then
        self:getAnimation():play(Action.PLAY_UNDERATTACK)
    end
end

--死亡
function Monster:playDie(commpelete)
    -- if self:getAnimation():getCurrentMovementID()~=Action.PLAY_DIE then
        self:getAnimation():play(Action.PLAY_DIE)
    -- end
    self:getAnimation():setMovementEventCallFunc(
    function(armatureBack,movementType,movementID)
        if movementType == ccs.MovementEventType.complete and movementID==Action.PLAY_DIE then
            if commpelete~=nil then
                commpelete()
            end
        end
    end)
end


--boos 掉落特效
function Monster:dropEffect(complete)
    local effect = display.createEffect(Prefix.PREOPE_DROP_NAME,Prefix.PREOPE_DROP_NAME,complete,true,true)
    self:addChild(effect)
    effect:setScale(3)
    effect:setPosition(0,math.abs(self:getOffsetPoints().y))
end

function Monster:onEnter()
    
end

function Monster:onExit()

end

return Monster