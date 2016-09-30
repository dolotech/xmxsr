-- 游戏战斗技能显示信息
local BattleEvent = require("game.view.battle.BattleEvent")

local SkillInfoLayer = class("SkillInfoLayer" ,function ()
    return cc.Node:create()
  end)

function SkillInfoLayer:create()
    local instance = SkillInfoLayer.new()
    instance:setNodeEventEnabled()
    return instance
end

--构建
function SkillInfoLayer:ctor()
    self.list = {}
    self.data = {}

    local rect = cc.rect(0,0,stageWidth,595 + Config.BATTLE_SCENE_OFFSET_HEIGHT)
    self.maskLayer = display.createMaskLayer(rect,255,0.3,function(x,y)
            self:setInfoVisible(false)
    end,Picture.RES_YIN_BG_PNG)
    
    self:addChild(self.maskLayer)
    
    self.skillLayer = cc.Layer:create()
    self:addChild(self.skillLayer)
    
    self.infoLayer = cc.Layer:create()
    self:addChild(self.infoLayer)

    for i=1, Config.DATA_PETTYPE_COUNT, 1 do
        local table = RoleDataManager.getPetsDataBuyType(i)
        if table~=nil then
            for key, var in pairs(table) do
                if var.embattle then --出战状态
                    local skillData  = SkillData[tostring(var.skill)]
                    local goodsData = GoodsData[tostring(skillData.wigetID)]
                    local framName = Prefix.PREBATTLE_PICTURE..goodsData.picture .. PNG
                    local grid = cc.Sprite:createWithSpriteFrameName(framName)
                    grid:setScale(0.8)
                    grid:setPosition((i-1)*130+((175+offSetX)),rect.height+35)
                    grid:setVisible(false)
                    
                    local mask = cc.Sprite:createWithSpriteFrameName(Picture.RES_MASK_PNG)
                    grid:addChildWithAnchor(mask)
                    mask:setVisible(false)
                    local progressTimer1 = cc.ProgressTimer:create(mask)
                    progressTimer1:setReverseDirection(true)
                    progressTimer1:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
                    progressTimer1:setPercentage(100)
                    progressTimer1:setName("ProgressTimer")
                    grid:addChildWithAnchor(progressTimer1)
                    self.skillLayer:addChild(grid)
                    self.list["skill_"..i] = grid
                   
                    local item = display.createUI(Prefix.PREPETSKILL_CSB..i..CSB)
                    item:getChildByName("Text_1"):setString(tostring(var.level))
                    item:getChildByName("Text_2"):setString(tostring(var.name))
                    item:getChildByName("Text_3"):setString(tostring(var.attack))
                    Color.setLableShadows({item:getChildByName("Text_1"),item:getChildByName("Text_2"),item:getChildByName("Text_3")})
                    item:setPosition((i-1)*130+(175+offSetX),rect.height-235)
                    self.infoLayer:addChild(item)
                   
                    local image1 = item:getChildByName("Sprite_1")
                    local image2 = item:getChildByName("Sprite_2")
                    
                    local  frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(framName)
                    image1:setSpriteFrame(frame)
                    
                    local progressSprite2 = item:getChildByName("Sprite_2")
                    progressSprite2:setVisible(false)
                    local progressTimer2 = cc.ProgressTimer:create(progressSprite2)
                    progressTimer2:setReverseDirection(true)
                    progressTimer2:setPosition(0,228)
                    progressTimer2:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
                    progressTimer2:setName("ProgressTimer")
                    progressTimer2:setPercentage(100)
                    item:addChild(progressTimer2)
                    self.list["item_"..i] = item
                    
                    self.data["skillData_"..i] = {cur=0,inrc=0,original=0,max=skillData.condition,skillData = skillData}
                    break 
                end
            end
        end
    end
end


--是否隐藏技能信息层
function SkillInfoLayer:setInfoVisible(bool)
    self.infoLayer:setVisible(bool)
    self.maskLayer:setVisible(bool)
    self.maskLayer:setTouchEnabled(bool)
    if bool==true then
        for i=1, Config.DATA_PETTYPE_COUNT, 1 do
            local item = self.list["item_"..i]
            if item~=nil then
                local grid = self.list["skill_"..i]
                item:getChildByName("ProgressTimer"):setPercentage(grid:getChildByName("ProgressTimer"):getPercentage())
            end
        end
    end
end


--隐藏或者显示某个宠物技能
function SkillInfoLayer:setSkillVisible(type,bool,force)
    local grid = self.list["skill_"..type]
    local data = self.data["skillData_"..type]
    if grid~=nil then
        if force==nil and self:skillIsDrop(type)==true and bool ==false then
            grid:setVisible(true)
        else
            grid:setVisible(bool)
        end
        data.original = data.cur
    end
end

--设置更新技能cd 
--type 1直接增量 2差值增量    3差值减量  4直接减量
--petType 宠物类型
function SkillInfoLayer:setKillTypePercentage(type,petType,num)
    local grid = self.list["skill_"..petType]
    if grid~=nil then
        local data = self.data["skillData_"..petType]
        if data~=nil then
            if type==1 then--直接增量
                data.original = data.cur
                data.inrc = num
                data.cur =data.cur + num
            elseif type==2 then--差值增量
                local n = num - data.inrc
                data.cur =data.original + n
                data.inrc = num
            elseif type==3 then--差值减量
                local n = num - data.inrc
                data.cur =data.original + n
                data.inrc = num
            elseif type==4 then--直接减量
                data.inrc = num
                data.cur =data.cur - num
                data.original = data.cur
            end
              
            if data.cur>=data.max then
                data.cur = data.max
            elseif data.cur<=0 then
                data.cur = 0
            end
            
            local percentage =  1-(data.cur/data.max)
            grid:getChildByName("ProgressTimer"):setPercentage(percentage*100)
        end
    end
end

--检测哪些技能可以掉落
function SkillInfoLayer:chenkKillAuotDrop()
    local n,tList = 0,{}
    for i=1, Config.DATA_PETTYPE_COUNT, 1 do
        local item = self.list["item_"..i]
        if item~=nil then
            local grid = self.list["skill_"..i]
            local data = self.data["skillData_"..i]
            local percent =  (1-(data.cur/data.max))*100
            if  data~=nil and percent<=0 then--技能可以掉落
                data.cur = 0
                data.inrc = 0
                data.original = 0
                grid:setVisible(true)
                --注意时间要和丢技能的一样
                grid:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
                    item:getChildByName("ProgressTimer"):setPercentage(100)
                    grid:getChildByName("ProgressTimer"):setPercentage(100)
                    grid:setVisible(false)
                end)))
                n=n+1 tList[n] = {skillData=data.skillData, skill=grid, index = i}  
            end
        end
    end
    if(#tList<1)then 
        self:dispatchEvent(BattleEvent.OnDropPetSkill)
    else
        self:dispatchEvent(BattleEvent.OnDropPetSkill,tList)
    end
end

--是否可以掉落
function SkillInfoLayer:skillIsDrop(petType)
    local grid = self.list["skill_"..petType]
    if grid==nil then
        return false
    end
    local percent = grid:getChildByName("ProgressTimer"):getPercentage()
    if percent<=0 then--技能可以掉落
        return true
    end
    return false
end

return SkillInfoLayer