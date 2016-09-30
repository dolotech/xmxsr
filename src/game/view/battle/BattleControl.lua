--创建战斗打斗控制器

local BattleControl = class("BattleControl")
BattleControl.__index = BattleControl

local MonsterData = require("game.data.MonsterData")
local Monster = require("game.view.battle.Monster")
local BattleEvent = require("game.view.battle.BattleEvent")
local RatioHash = {["1.2"] = "1",["1.5"] = "2",["2"] = "3"}

function BattleControl:create(data)
    local instance = BattleControl.new(data)
    return instance
end

local battleScene_, elementLayer_
function BattleControl:ctor(data)
    --存储数据
    self.pets = data.pets
    self.monsters = data.monsters 
    self.monster = self.monsters[1]
    self.goalsUi = data.leftTopBtn
    self.movesUi = data.rigthTopBtn
    self.tollgate = data.tollgate

    self.petSkillInfo = data.petSkillInfo
    self.updateScore = data.updateScore
    battleScene_ = data.battleScene
    elementLayer_ = data.elementLayer
   
    --飞行模型
    self.FlyToModel =  require("game.view.comm.FlyToModel"):create()
    --目标控制器
    self.GoalsControl = require("game.view.battle.GoalsControl"):create(self.goalsUi ,self.movesUi, self.tollgate, data.updateScore)
    
    --连线类型(元素类型？)
    self.pathType = 0
    --总共攻击力
    self.tallAttack = 0
    --当前怪物个数
    self.monsterIndex = 1
    --当前怪物防御类型
    if self.monster~=nil and self.monster.data.immunity~=nil and self.monster.data.immunity>0 then
        self.defType = self.monster.data.immunity
    else
        self.defType = 0
    end
    --攻击怪物的终点
    local x,y = 0,0
    if self.monster~=nil then
        x,y = self.monster:getPosition()
    end
    self.endPoint = cc.p(x,y)
end

--初始化监听
function BattleControl:initListner(parameters)
    SceneManager.currentScene:addEventListener(BattleEvent.OnDropMonsterSkill,handler(self,self.OnDropMonsterSkill))
end

-- 攻击怪物 连接列表dataArr[1]
-- 爆炸列表dataArr[2]
-- deleteOne data
-- OnTouchEndDelete bool
function BattleControl:battleMonster(type,dataArr)
    if type == BattleEvent.OnTouchBegan then 
        self:resset(dataArr)
        self:updateData(dataArr) 
        self:onTouchBegan()
    elseif type== BattleEvent.OnTouchEnd then
        self:onTouchEnd(false)
    elseif type==BattleEvent.OnTouchEndDelete then
        self:onTouchEndDelete(dataArr)
    elseif type==BattleEvent.OnConnected then
        self:setPathType(dataArr)
        self:updateData(dataArr) 
        self:connected()
    elseif type==BattleEvent.OnDeleteOne then
        self:deleteOne(dataArr)
    elseif type==BattleEvent.OnDeleteComplete then  
        self:deleteComplete() 
        elementLayer_:showMaskLayer()
    elseif type==BattleEvent.OnConnectBack then 
        self:updateData(dataArr)  
        self:connectBack()
    elseif type== BattleEvent.UPDATE_DATA then
        self:resset(dataArr)
        self:updateData(dataArr) 
        --设置技能CD
        self:setSkillCDMask(1)
        -- self.updateScore({len = #dataArr[1] + #dataArr[2]})
        -- self:deleteComplete() 
    end
end

--重置
function BattleControl:resset(dataArr)
    self.FlyToModel.flyArrs = nil
    self.FlyToModel.attackArr = nil
    self.pathType = 0  
    self:setPathType(dataArr)
end

function BattleControl:setPathType(dataArr)
    if self.pathType==0 then
        for key, var in pairs(dataArr[1]) do
            local widgetData = var.widget
            if widgetData and widgetData.eliminate.type <= Config.DATA_PETTYPE_COUNT then
                self.pathType = widgetData.eliminate.type --选中类型
                break
            end
        end
    end
end

--更新保存数据
function BattleControl:updateData(dataArr)
    self.pathArr = dataArr[1]
    self.bomArr = dataArr[2]
    self:getArrLen()
    self:attackValue()
end

--开始连接第一个
function BattleControl:onTouchBegan()
	self:checkMonsterHp(1)
    local pet = self.pets[self.pathType]
    if pet then
        --设置当前cd技能隐藏与显示
        self:setSkillCDVisible()
    end
    --更新技能CD
    self:setSkillCDMask(1)
    --播放连线动作
    self:playConnectedEffect()
end

--连接最后一个
function BattleControl:onTouchEnd(bool)
    if self.pathType<1 then return end

    --设置当前cd技能隐藏与显示
    for type=1, Config.DATA_PETTYPE_COUNT, 1 do--集体宠物
        self.petSkillInfo:setSkillVisible(type,false,true)
    end
    if bool or (self.arrLen and self.arrLen[3]<3) then --连接的元素小于3个时
        local pet = self.pets[self.pathType]
        if pet then --播放闲置动画
            pet:playIdle()
        end

        --设置技能CD
        self:setSkillCDMask(4)
        --设置当前cd技能隐藏与显示
        -- for type=1, Config.DATA_PETTYPE_COUNT, 1 do--集体宠物
        --     self.petSkillInfo:setSkillVisible(type,false)
        -- end
        self.pathType = 0  
        self.arrLen[3] = 0
        self.arrLen[5] = 0

        self:checkMonsterHp(0)
        --隐藏遮罩
        -- elementLayer_:activateFallEngine(true)

        Audio.playSound(Sound.SOUND_BATTLE_CANCEL,false)
        
        --隐藏特效
        for type=1, Config.DATA_PETTYPE_COUNT, 1 do--集体宠物
            local pet = self.pets[type]
            if pet then
                pet:setPowerEffect(false)--显示特效
            end
        end
    end
end

--可以刪除
function BattleControl:onTouchEndDelete(bool)
    if  bool then
        self:onTouchEnd(bool)
    	return
    end
    --更新步数
    self.GoalsControl:updataMoves()
    --第一次消除连线消耗体力
    self:downPower()
    Audio.playSound(Sound.SOUND_BATTLE_CHOSE,false)
end

--连线
function BattleControl:connected()
    --播放连线动作特效
    self:playConnectedEffect()
    --检测怪物的血和文字
    self:checkMonsterHp(1)
    --是否隐藏cd技能
    self:setSkillCDVisible()
    --更新技能CD
    self:setSkillCDMask(2)
     --检测提示攻击力倍数
    self:checkRatioPower(self.arrLen[3])

end

--回退
function BattleControl:connectBack()
    --播放连线动作特效
    self:playConnectedEffect()
    --检测怪物的血和文字
    self:checkMonsterHp(2)
    --是否隐藏cd技能
    self:setSkillCDVisible()
    --更新技能CD
    self:setSkillCDMask(3)
    --检测提示攻击力倍数
    self:checkRatioPower(self.arrLen[3])
end

--删除一个 生成元素飞行效果
function BattleControl:deleteOne(elementData)
    if elementData==nil then
        return
    end
    if self:checkGetWinGoods(elementData)==true then --检测结算掉落道具
        self.updateScore({len = 1, eleData = elementData})
        return
    end
    if self:checkGetGoods(elementData)==true then --检测掉落道具
        return
    end
    if self.GoalsControl.win then --赢了
    	return
    end
    local type = elementData.widget.eliminate.type --类型
    if type>Config.DATA_PETTYPE_COUNT then --类型不为元素时
        self.GoalsControl:updataGolas(elementData.widget.eliminate.widgetID)--可能是收集木箱
        return
    end
    local pet = self.pets[type]
    local widgetData = elementData.widget
    --更新目标收集的个数
    if widgetData then
        local id = widgetData.eliminate.widgetID
        if widgetData.eliminate.type <=5 then
            id  = widgetData.eliminate.type
        end
        self.GoalsControl:updataGolas(id)
    end

    --分数点移动
    self.updateScore({len = self.attackArr[type].len, eleData = elementData})

    --没怪物 没宠物
    if self.monster==nil and  pet==nil then
        local attData = self.attackArr[type]
        --个数减减
        attData.len = attData.len-1
        --检测是否打开遮罩
        self:checkOpenMask()
        return
    end
    
    --有怪物 有宠物
    if pet~=nil and  self.monster~=nil then 
        local args = {}
        args.elementData = elementData
        --宠物位置
        args.toPoint = cc.p(pet:getPositionX(),pet:getPositionY()+30)
        --怪物位置
        args.endPoint = cc.p(self.endPoint.x,self.endPoint.y+80)
        args.attackArr = self.attackArr
        args.defType = self.defType
        args.powerCompleteHandler = handler(self,self.powerCompleteHandler)
        args.flyMonstModel = handler(self,self.flyMonstModel)
        self.FlyToModel:flyPetMonsterModel(args)
        return
    end
    
    --没怪物 有宠物
    if pet~=nil and  self.monster==nil then 
        self.FlyToModel:flyPetModel(elementData,cc.p(pet:getPositionX(),pet:getPositionY()+30),handler(self,self.flyPetModel),true,self.defType)
        return
    end
    
    --有怪物 没宠物
    if self.monster~=nil and pet==nil then 
        self.FlyToModel:flyMonstModel(elementData,cc.p(self.endPoint.x,self.endPoint.y+150),handler(self,self.flyMonstModel),self.defType)
        return
    end
end

--攻击怪物每次回调
function BattleControl:flyMonstModel(data)
    local isDef = self.defType>0 and self.defType==data.type
    local attData = self.attackArr[data.type]
    attData.len = attData.len-1--个数减减
    if not isDef then
        if self.monster~=nil and self.monster.data~=nil then
            self.monster.data.hp = self.monster.data.hp-attData.oneAttack
            --更新怪物的实际血
            self.monster:updataHp(true)
        end
        --怪物受击
        self:monsterCompetleUnderAttack()
    else
        if  self.monster~=nil and self.monster.data~=nil then
            local defBtn = self.monster:getDefBtn()
            defBtn:getChildByName("Sprite_1"):setVisible(true)
            defBtn:setScale(1.1)
            tween.scaleBock(defBtn,0.15,1.3,0.65)
        end
        --检测是否打开遮罩
        self:checkOpenMask()
	end
end

--飞到宠物每次回调
function BattleControl:flyPetModel(data)

    local attData = self.attackArr[data.type]
    --个数减减
    attData.len = attData.len-1
    --检测是否打开遮罩
    self:checkOpenMask()
end

--飞到宠物积累全部能量攻击
function BattleControl:powerCompleteHandler(type)
    local pet = self.pets[type]
    if pet then
        pet:playAttack(nil)--攻击动作
    end
end

--检测是否打开遮罩
function BattleControl:checkOpenMask()
    self.attackLen = self.attackLen - 1

--    print(">>>checkOpenMask:",self.attackLen)
    local bool = self.attackLen < 1
    -- for key, var in pairs(self.attackArr) do
    --     if var.len>0 then
    --         bool = false
    -- 		break;
    -- 	end
    -- end
    if bool then
        --设置当前cd技能隐藏
        self:setSkillCDVisible()
        --检测提示攻击力倍数隐藏
        self:checkRatioPower(0)
        --更新怪物的实际血
        if self.monster~=nil then
            self.monster:updataHp(false)
        end
        --隐藏防御血
        self:checkMonsterHp(0)
        --隐藏技能
        for type=1, Config.DATA_PETTYPE_COUNT, 1 do--集体宠物
            self.petSkillInfo:setSkillVisible(type,false)
            local pet = self.pets[type]
            if pet then
                pet:setPowerEffect(false)--显示特效
            end
        end
        --处理怪物
        self:showMonster()
        
        self.FlyToModel.flyArrs = nil
        
        self.FlyToModel.attackArr = nil
	end
end

--元素全部删除完成
function BattleControl:deleteComplete()
    local ratio  = 0
    if self.defType ~= self.pathType then
        ratio = self:ratio(self.arrLen[4])
    else--被怪物防御了没伤害
        ratio = self:ratio(0)
    end
    if ratio>1 then
        local id = RatioHash[tostring(ratio)]+3
        local sound = Sound["SOUND_BATTLE_CLICK_ADDTION"..(id-3)]
        Audio.playSound(sound,false)
        local path = Prefix.PREWORD_PICTURE..id..PNG
        local sprte = cc.Sprite:createWithSpriteFrameName(path)
        TipsManager:ShowSprte(sprte,nil)
    end
    if self.arrLen[2]<=0 then --没有可以飞行的元素时
	    --隐藏罩着
        elementLayer_:activateFallEngine()
    end
    
    self.arrLen[3] = 0
    self.arrLen[5] = 0
    self.pathType = 0  
end

--设置技能cd
--type 1直接增量 2差值增量    3差值减量  4直接减量
function BattleControl:setSkillCDMask(type)

    -- print("--------setSkillCDMask]petType] addType",type)
    for petType=1, Config.DATA_PETTYPE_COUNT, 1 do--集体宠物
        local len = 0
        if self.bomArr then
            for key, var in pairs(self.bomArr) do --爆炸的
                local widgetData = var.widget
                if widgetData and widgetData.eliminate.type==petType then--宠物类型
                    if widgetData.pang==nil then --不是消除附着物
                        len = len+1
                    end
                end
            end
        end
        if petType == self.pathType then
        	 len = len+self.arrLen[4]
        end
        -- printf(">>petType",petType,"pathType",self.pathType,"bomArr",#self.bomArr,"len",len)
        -- if len~=0 then
            self.petSkillInfo:setKillTypePercentage(type,petType,len)
        -- end
    end
end

--设置隐藏技能cd
function BattleControl:setSkillCDVisible()
    if  self.arrLen[5]<=0 then--单单连线攻击力
        self.petSkillInfo:setSkillVisible(self.pathType,true)
        for type=1, Config.DATA_PETTYPE_COUNT, 1 do--集体宠物
            if type~= self.pathType then
        	   self.petSkillInfo:setSkillVisible(type,false)
            end
        end
    else--集体技能CD
        for type=1, Config.DATA_PETTYPE_COUNT, 1 do--集体宠物
            local visible = false
            for key, var in pairs(self.bomArr) do
                local widgetData = var.widget
                if widgetData and widgetData.eliminate.type==type then--宠物类型
                    if widgetData.pang==nil then --不是消除附着物
                        visible = true
                        break 
                    end
                end
            end
            self.petSkillInfo:setSkillVisible(type,visible)
        end
        self.petSkillInfo:setSkillVisible(self.pathType,true)
    end
end

--怪物受击完成
function BattleControl:monsterCompetleUnderAttack()
    if self.monster~=nil then
        local function monsterCommplete()
            if self.monster~=nil then
                if self.monster.data.hp<=0 then
                	self.defType  = 0
                    if self.monster.data.drop~=nil then
                        local drop = self.monster.data.drop
                        for key, var in pairs(drop) do
                            self.GoalsControl:updataGolas(var.id)
                            self.GoalsControl:updataGetGoods(var)
                            self.FlyToModel:flyGetModel(GoodsData[tostring(var.id)],self.endPoint,cc.p(self.endPoint.x,self.endPoint.y+380),var.count,nil)
                        end
                    end
                    --更新怪物个数
                    self.GoalsControl:updataMoster()                   
                    --创建怪物
                    self:createMonster()
                end
            end
        end
        self.monster:playUnderAttack()--怪物受攻击
        monsterCommplete()
    else
        self.defType  = 0
    end
    --检测是否打开遮罩
    self:checkOpenMask()
end

--创建下个怪物
function BattleControl:createMonster()
    self.monsterIndex = self.monsterIndex + 1
    self.monster = self.monsters[self.monsterIndex]
    if self.monster ~= nil then
        self.monster:setPosition(self.endPoint.x, self.endPoint.y + 140)
        self.monster:playIdle()
        if self.monster.data.immunity ~= nil and self.monster.data.immunity > 0 then
            self.defType = self.monster.data.immunity
        else
            self.defType = 0
        end
        --更新怪物的实际血
        self.monster:updataHp(false)
    else
        self.defType  = 0
    end
    --隐藏显示血
    self:checkMonsterHp(0)
end

function BattleControl:showMonster()
    local index, monster = 0, nil
    for key, var in pairs(self.monsters) do
        if var.data.hp<=0 then
            if(monster==nil)then
                monster = var
                index = key
            else --有可能出现同时死两个怪的情况
                self.monsters[key]:removeFromParent()
                self.monsters[key] = nil
            end
    	end
    end
    if monster~=nil then
        monster.hpBar:setVisible(false)
        monster:playDie(function()
            monster:removeFromParent()
            self.monsters[index] = nil
            -- print("-----showMonster]",self.monsterIndex,table.nums(self.monsters),#self.monsters)
            if(table.nums(self.monsters)<1)then 
                elementLayer_:activateFallEngine()--隐藏遮罩启动掉落
            else
                self:showBgAni()
            end
        end)
    else
        elementLayer_:activateFallEngine()--隐藏遮罩启动掉落
    end
end

--怪物出现过场动画
function BattleControl:showBgAni()
    local imgBgAni = battleScene_.imgBgAni
    imgBgAni:setVisible(true)
    -- imgBgAni:setGLProgram(cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor_noMVP"));
    imgBgAni:setScale(1.0)
    local x,y = imgBgAni.loc.x,imgBgAni.loc.y
    imgBgAni:setOpacity(200)
    local i,list = 0,{}
    local delay = 0.15
    i=i+1 list[i] = cc.Spawn:create(cc.FadeTo:create(delay,190),cc.ScaleTo:create(delay,1.1),cc.MoveTo:create(delay,cc.p(x,y-20)))
    i=i+1 list[i] = cc.Spawn:create(cc.FadeTo:create(delay,160),cc.ScaleTo:create(delay,1.2),cc.MoveTo:create(delay,cc.p(x,y)))
    i=i+1 list[i] = cc.Spawn:create(cc.FadeTo:create(delay,130),cc.ScaleTo:create(delay,1.3),cc.MoveTo:create(delay,cc.p(x,y-20)))
    i=i+1 list[i] = cc.Spawn:create(cc.FadeTo:create(delay,100),cc.ScaleTo:create(delay,1.4),cc.MoveTo:create(delay,cc.p(x,y-5)))
    i=i+1 list[i] = cc.Spawn:create(cc.FadeTo:create(delay,70),cc.ScaleTo:create(delay,1.5),cc.MoveTo:create(delay,cc.p(x,y-30)))
    i=i+1 list[i] = cc.Spawn:create(cc.FadeTo:create(delay,10),cc.ScaleTo:create(delay,1.6),cc.MoveTo:create(delay,cc.p(x,y-20)))
    i=i+1 list[i] = cc.DelayTime:create(0.1)

    i=i+1 list[i] = cc.CallFunc:create(function() 
            imgBgAni:setPosition(cc.p(x,y))
            imgBgAni:setVisible(false) 
            self:callPlayDeadCompelete()
            elementLayer_.fallEngine.isSendStop = false
        end)
    imgBgAni:runAction(cc.Sequence:create(list))
    elementLayer_:activateFallEngine(nil,true)--隐藏遮罩启动掉落
end

function BattleControl:callPlayDeadCompelete(parameters)
    local function callback()
        self.monster.hpBar:setVisible(true)
        self.monster:dropEffect()
        battleScene_:shakeScreen()
    end
    
    if self.monster~=nil and not self.monster:isVisible() then
        self.monster.hpBar:setVisible(false)
        self.monster:setVisible(true)
        local scale = self.monster:getScale()
        tween.monsterDrop(self.monster,cc.p(self.endPoint.x,self.endPoint.y),scale,callback)
    end
end

--宠物播放连线动作
function BattleControl:playConnectedEffect()
    if  self.arrLen[5]<=0 then--单单连线攻击力
        local pet = self.pets[self.pathType]
        if pet then
            pet:setPowerEffect(true)
        end
    else--集体技能CD
        for type=1, Config.DATA_PETTYPE_COUNT, 1 do--集体宠物
            local visible = false
            
            for key, var in pairs(self.bomArr) do
                local widgetData = var.widget
                if widgetData and widgetData.eliminate.type==type then--宠物类型
                    visible = true
                    break 
                end
            end
            
            local pet = self.pets[type]
            if pet then
                pet:setPowerEffect(visible)--显示特效
            end
        end
    end
end

--消耗体力
function BattleControl:downPower()
    if self.isDownPower==nil then
        self.isDownPower = true
        local power = SharedManager:readData(Config.POWER)
        power = power-self.tollgate.power
        SharedManager:saveData(Config.POWER,power,true)
    end
end

--获取长度arrLen index
--1连线和爆炸总长度 
--2连线和爆炸实际总长度 
--3连线长度 
--4连线实际长度 
--5爆炸长度
--6爆炸实际长度 
function BattleControl:getArrLen()
    local arrLen = {[1]=0,[2]=0,[3]=0,[4]=0,[5]=0,[6]=0}
    for key, var in pairs(self.pathArr) do
        local widgetData = var.widget
        if widgetData and widgetData.eliminate.type<=Config.DATA_PETTYPE_COUNT then
            if widgetData.pang == nil then--带有攻击力类型除去附着物
            	 arrLen[4] = arrLen[4]+1
            end
            arrLen[3] = arrLen[3]+1
        end
    end

    if self.bomArr~=nil then
        for key, var in pairs(self.bomArr) do
            local widgetData = var.widget
            if widgetData and widgetData.eliminate.type<=Config.DATA_PETTYPE_COUNT then
                if widgetData.pang == nil then--带有攻击力类型除去附着物
                    arrLen[6] = arrLen[6]+1
                end
                arrLen[5] = arrLen[5]+1
            end
        end
    end
    arrLen[1] =  arrLen[3] + arrLen[5] 
    arrLen[2] =  arrLen[4] + arrLen[6] 
    self.arrLen =  arrLen
    self.attackLen = arrLen[2]-1
end

--获取当前的攻击力
function BattleControl:attackValue()
    self.attackArr = {
        [1]={len=0, allLen=0, attack=0, oneAttack=0,allAttack=0,skillLen=0,skillAtt=0},
        [2]={len=0, allLen=0, attack=0, oneAttack=0,allAttack=0,skillLen=0,skillAtt=0},
        [3]={len=0, allLen=0, attack=0, oneAttack=0,allAttack=0,skillLen=0,skillAtt=0},
        [4]={len=0, allLen=0, attack=0, oneAttack=0,allAttack=0,skillLen=0,skillAtt=0},
        [5]={len=0, allLen=0, attack=0, oneAttack=0,allAttack=0,skillLen=0,skillAtt=0}
     }
    local allAttack = 0
    -- self.attackLen = 0
    for type = 1, Config.DATA_PETTYPE_COUNT, 1 do--集体宠物
        local len = 0--实际总共长度
        local allLen = 0--总共长度包括防御
        local skillLen = 0--技能长度
        local att = Config.BASE_ATTACK--宠物基本攻击力没宠物50攻击力
        local skillAtt = 0--宠物技能攻击力
        
        --连线攻击力
        if self.pathType == type then
            for key, var in pairs(self.pathArr) do
                local widgetData = var.widget
                if widgetData and widgetData.eliminate.type <= Config.DATA_PETTYPE_COUNT then--带有攻击力类型
                    if widgetData.pang == nil then --除去附着物
                        allLen = allLen + 1
                        if self.defType ~= type then
                            len =len + 1
                            if widgetData.skill ~= nil then
                                skillLen = skillLen + 1
                            end
                        end
                    end
                end
            end
        end
        
        --爆炸攻击力
        for key, var in pairs(self.bomArr) do
            local widgetData = var.widget
            if widgetData and widgetData.eliminate.type == type then--带有攻击力类型
                if widgetData.pang == nil then --不是附着物
                    allLen = allLen + 1
                    if self.defType~=type then--有防御情况不计算
                        len = len+1
                        if widgetData.skill ~= nil then
                            skillLen = skillLen + 1
                        end
                    end
                end
            end
        end

        --是否有宠物
        local pet = self.pets[type]
        --宠物攻击力
        if pet~=nil then
            att = pet.data.attack
            if pet.data.skill then--宠物技能攻击力
                local skillData  = SkillData[tostring(pet.data.skill)]
                skillAtt = att*skillData.attack
            end
        end
        
        --是否怪物对这元素有防御
        if type == self.defType then
        	att = 0
        	skillAtt = 0
        end
        -- self.attackLen = self.attackLen + len
        self.attackArr[type].len = len
        self.attackArr[type].allLen = allLen
        self.attackArr[type].attack = att
        self.attackArr[type].skillLen = skillLen
        self.attackArr[type].skillAtt = skillAtt
    end
    
    --累计所有攻击力 计算每个分的的攻击力
    for key, var in pairs(self.attackArr) do
        local attValue = (var.attack * (var.len - var.skillLen) + var.skillAtt * var.skillLen) * self:ratio(var.len)
        local oneAttack = 0
        if var.len > 0 then
            oneAttack = attValue / var.len
        end
        var.oneAttack = oneAttack
        var.allAttack = attValue
        allAttack = allAttack+attValue
    end
    self.tallAttack = allAttack
    -- print("==================attackLen:",self.attackLen,allAttack)
end

--提示攻击力倍数
function BattleControl:checkRatioPower(len)
    local ratio = 0
    if self.defType ~= self.pathType and self.pathType > 0 then
        ratio = self:ratio(len)
    else
        ratio = self:ratio(0)
    end
    
    local id = RatioHash[tostring(ratio)]
    if id~=nil then
        local path = Prefix.PREWORD_PICTURE..id..PNG
        if not self.ratioSprite then
            self.ratioSprite = cc.Sprite:createWithSpriteFrameName(path)
            SceneManager.currentScene:addToEffectLayer(self.ratioSprite)
            self.ratioSprite:setAnchorPoint(0.5,0.5)
            self.ratioSprite:stageLeftTop(20, -190)
        else
            local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(path)
            self.ratioSprite:setSpriteFrame(frame)
        end
        self.ratioSprite:setScale(0.95)
        self.ratioSprite:setVisible(true)
        self.ratioSprite:stopAllActions()
        tween.RepeatScale(self.ratioSprite, 1, 1.05, 0.95)
    else
        if self.ratioSprite ~= nil then
            self.ratioSprite:setVisible(false)
            self.ratioSprite:stopAllActions()
        end  
    end
    
    if self.monster~=nil then
        local lable = self.monster:getHpLable()
        if  self.defType == self.pathType and self.pathType > 0 then --有防御情况不计算
            lable:setTextColor(Color.hpColor[1])
        else
            if Color.hpColor[ratio] == nil then
                lable:setTextColor(Color.hpColor[1])
            else
                lable:setTextColor(Color.hpColor[ratio])
            end
        end
    end
    
    if len == 3 then
        Audio.playSound(Sound["SOUND_BATTLE_COMBO1"])
    elseif len == 6 then
        Audio.playSound(Sound["SOUND_BATTLE_COMBO2"])
    elseif len == 10 then
        Audio.playSound(Sound["SOUND_BATTLE_COMBO3"])
    elseif len == 15 then
        Audio.playSound(Sound["SOUND_BATTLE_COMBO4"])
    end
end

--检测怪物hp的显示效果
--@param type 0隐藏 1增加连接个数 2回退减少个数 
function BattleControl:checkMonsterHp(type)
    if self.monster~=nil then
        local lable = self.monster:getHpLable()
        local progress = self.monster:getHpProgress2()
        lable:stopAllActions()
        progress:stopAllActions()
        lable:setString(self.tallAttack .. "/" .. math.floor(self.monster.data.hp))
        if type==1 or type==2 then
            local value  = self.monster.data.hp - self.tallAttack
            if value <= 0 then
                value = 0
            end
            lable:setVisible(true)
            progress:runAction(cc.ProgressTo:create(0.05, (value / self.monster.data.maxHp) * 100))
            lable:stopAllActions()
            lable:setScale(1.3)
            tween.scaleBock(lable,0.5,1.2,1)
            if  self.defType == self.pathType and self.defType > 0 then--有防御情况不计算
                local defBtn = self.monster:getDefBtn()
                defBtn:stopAllActions()
                defBtn:getChildByName("Sprite_1"):setVisible(true)
                defBtn:setScale(1.1)
                tween.scaleBock(defBtn, 0.3, 1+self.arrLen[4] * 0.08, 0.65)
            end
        elseif type==0 then
            progress:runAction(cc.ProgressTo:create(0.03,(self.monster.data.hp/self.monster.data.maxHp)*100))
            local callBack = cc.CallFunc:create(function()
                lable:setScale(1)
                lable:setVisible(false)
                lable:setTextColor(Color.hpColor[1])
                if self.monster then
                    local defBtn = self.monster:getDefBtn()
                    defBtn:getChildByName("Sprite_1"):setVisible(false)
                end
            end)
            local scaleTo = cc.EaseBackOut:create(cc.ScaleTo:create(0.8,1))
            local seq = cc.Sequence:create(scaleTo, callBack)
            lable:runAction(seq) 
        end   
    end
end

--可以获得结算奖励物品
function BattleControl:checkGetWinGoods(elementData)
    local widgetData = elementData.widget
    local rewards = widgetData.gameoverRewards --结算奖励
    if rewards~=nil then
        for key, drop in pairs(rewards) do
            local goodsData = GoodsData[tostring(drop.id)]
            self.GoalsControl:updataGetGoods(drop)
            self.FlyToModel:battleDropGoods(elementData,goodsData,drop.count,function()end)
        end
        return true
    end
    return false
end

--可以获得物品
function BattleControl:checkGetGoods(elementData)
    local widgetData = elementData.widget
    local rewards =  widgetData.rewards-- 奖励道具
    if rewards~=nil then
        for key, drop in pairs(rewards) do
            self.GoalsControl:updataGolas(widgetData.eliminate.sort)
            self.GoalsControl:updataGetGoods(drop)
            local goodsData = GoodsData[tostring(drop.id)]
            self.FlyToModel:battleDropGoods(elementData, goodsData, drop.count,function()end)
        end
        return true
    end
    return false
end

--检测怪物技能
function BattleControl:checkSkill()
    if self.monster == nil then
        SceneManager.currentScene:dispatchEvent(BattleEvent.OnDropMonsterSkill,{})
        return false
    end
    return self.monster:checkKills()
end

--检测胜利
function BattleControl:checkBattleWin()
    local bool = self.GoalsControl:chenkGoadls(0)
    return bool
end

--检测超出步数
function BattleControl:checkMoves()
    local bool = self.GoalsControl:chenkGoadls(1)
    return bool
end

--检测宠物技能
function BattleControl:chenkKillAuotDrop(parameters)
    --确定检测掉落技能
    return self.petSkillInfo:chenkKillAuotDrop()
end

--获取攻击力倍率
function BattleControl:ratio(len)
    if len >= 15 then
        return 2
    elseif len >= 10 then
        return 1.5
    elseif len >= 6 then
        return 1.2
    else
        return 1
    end
end

return BattleControl

