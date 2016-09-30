
--升级宠物
local DrowthDialog = class("DrowthDialog", function()
    return display.createUI("DrowthDialog.csb")
end)

function DrowthDialog:create()
    local dialog = DrowthDialog.new()
    return dialog
end

--初始化设置
function DrowthDialog:onEnter()
    self:getChildByName("Button_1"):setTitleText(Language.Level_Up)
    self:getChildByName("Button_2"):setTitleText(Language.Rose_To_Lv10)
    self:getChildByName("Text_2"):setString(Language.Game_Attack)
    self:getChildByName("Text_3"):setString(Language.Game_Skill)
    
    self:getChildByName("closeButton"):onClick(function(parameters)
        Audio.playSound(Sound.SOUND_UI_READY_BACK,false)
        if(self.param.funCloseCallBack ~= nil)then self.param.funCloseCallBack() end
        self:close()
    end,false,false)
    self:getChildByName("Button_1"):onClick(function(parameters)self:upgradeHandler()end, true)
    self:getChildByName("Button_2"):onClick(function(parameters)self:upgradeHandlers()end, true)
    
    Color.setLableShadows({
        self:getChildByName("Text_1"),
        self:getChildByName("Text_2"),
        self:getChildByName("Text_3"),
        self:getChildByName("Text_4"),
        self:getChildByName("Text_5"),
        self:getChildByName("Text_6"),
        self:getChildByName("Text_7"),
        self:getChildByName("Text_Name"),
        self:getChildByName("Text_max"),
        self:getChildByName("Text_level_1"),
        self:getChildByName("Text_level_2"),
        self:getChildByName("Text_level_3"),
        self:getChildByName("Text_level_4"),
        self:getChildByName("Text_level_5")
    })
        
    local textTrue = cc.Director:getInstance():getTextureCache():addImage(Prefix.PREPET_BG..self.param.type..PNG)
    self:getChildByName("bg"):setTexture(textTrue)
        
    self:updataUI()
    self:playWin()
    Audio.playSound(Sound[self.param.voice])
    
    self:addEventListener(Event.UPDATA_RAPID_ESCALATION, handler(self, self.updateRaoidEscalation))
end

--操作升级
function DrowthDialog:upgradeHandler()
    local yellow = SharedManager:readData(Config.YELLOW)
    local blue = SharedManager:readData(Config.BLUE)
    if yellow >= self.param.yellow and blue >= self.param.blue then
    
        SharedManager:saveData(Config.YELLOW,yellow-self.param.yellow,false)
        SharedManager:saveData(Config.BLUE,blue-self.param.blue,true)
        self:dipatchGlobalEvent(Event.UPDATA_YELLOW)
        self:dipatchGlobalEvent(Event.UPDATA_BLUE)
        
        local upgradeID = self.param.upgradeID
        local attack =  self.param.attack
        local curId = self.param.id 
        RoleDataManager.upgrade(self.param.type,self.param.id,self.param.upgradeID)
        self.param = clone(RoleDataManager.getRoleDataByID(self.param.upgradeID))
        self.param.id = upgradeID
        self:updataUI()
        
        self:playWin()
        attack = self.param.attack - attack
        TipsManager:ShowText(Language.Level_Up)
        performWithDelay(SceneManager.currentScene,function()TipsManager:ShowText(Language.POWER.."+"..attack)end, 0.5)
        if self.param.level % 5 == 0 then
            performWithDelay(SceneManager.currentScene,function()TipsManager:ShowText(Language.Game_Skill..Language.Level_Up)end, 1)
        end
        self:dipatchGlobalEvent(Event.UPDATA_PETUI,{id=curId ,roleData=self.param})
        Audio.playSound(Sound.SOUND_UI_HERO_LVUP, false)
        
        local effect = display.createEffect(Prefix.PREOPE_LEVELUP_NAME, "effect_0"..self.param.type, nil, true, false)
        effect:setScale(3)
        effect:setPosition(25, -15) 
        self:addChild(effect, 100)
    else
        DialogManager:open(Dialog.buyLevel, self.param)
        self:addEventListener(Event.UPDATA_PETUI,handler(self, self.updataUI))
        return
    end
end

--操作  快速升级 
function DrowthDialog:upgradeHandlers()
    if self.param.level <= 10 then
        self:getChildByName("Button_2"):setEnabled(true)
        self:getChildByName("Button_2"):setColor(cc.c4b(255, 255, 255, 255))
        DPayCenter.pay(304)
        TalkingData.onPageStart("升到10级")
    else
        self:getChildByName("Button_2"):setEnabled(false)
        self:getChildByName("Button_2"):setColor(cc.c4b(117, 117, 117, 255))
    end
end

function DrowthDialog:upgradeHeroLv()
    local lv = 10 - self.param.level
    for var = 1, lv do
        self:updateRaoidEscalation()
    end
end

function DrowthDialog:updateRaoidEscalation()
    if self.param.level < 10 then
        local upgradeID = self.param.upgradeID
        local attack =  self.param.attack
        local curId = self.param.id
        RoleDataManager.upgrade(self.param.type, self.param.id, self.param.upgradeID)
        self.param = clone(RoleDataManager.getRoleDataByID(self.param.upgradeID))
        self.param.id = upgradeID
        self:updataUI()
        self:playWin()
        attack = self.param.attack - attack
        TipsManager:ShowText(Language.Level_Up)
        performWithDelay(SceneManager.currentScene, function()TipsManager:ShowText(Language.POWER.. "+" ..attack)end, 0.5)
        if self.param.level % 5 == 0 then
            performWithDelay(SceneManager.currentScene, function()TipsManager:ShowText(Language.Game_Skill .. Language.Level_Up)end, 1)
        end

        self:dipatchGlobalEvent(Event.UPDATA_PETUI,{id = curId, roleData = self.param})
        Audio.playSound(Sound.SOUND_UI_HERO_LVUP, false)

        local effect = display.createEffect(Prefix.PREOPE_LEVELUP_NAME, "effect_0" .. self.param.type, nil, true, false)
        effect:setScale(3)
        effect:setPosition(25, -15) 
        self:addChild(effect, 100)
        self:upgradeHeroLv() --回调 执行升级 
    end
end

--播放胜利动作
function DrowthDialog:playWin()
    local role = self:getChildByName("role")
    local function petEventCallBack(role,armatureBack,movementType,movementID)
        if movementType == ccs.MovementEventType.loopComplete and movementID==Action.PLAY_WIN then
            role:playIdle()--待机
        end   
    end
    role:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)petEventCallBack(role,armatureBack,movementType,movementID)end)
    role:playWin()--胜利动作
end

--更新UI
function DrowthDialog:updataUI(event)
    if event~=nil then
        local id = event._userdata.id
        local roleData = event._userdata.roleData
        self.param = roleData
            local bar = self:getChildByName("Bar_1")
            local cper = self:getPer(self.param.level)
            bar:schedule(function()
                local per = bar:getPercent()
                per = per + 0.05
                if per >= cper then
                    bar:stopAllActions()
                    per = cper
                    self:playWin()
                    Audio.playSound(Sound[self.param.voice])
                end
                bar:setPercent(per)
            end,0.03)
        
        local effect = display.createEffect(Prefix.PREOPE_LEVELUP_NAME,"effect_0"..self.param.type,nil,true,false)
        effect:setScale(3)
        effect:setPosition(25, -15) 
        self:addChild(effect, 100)
    else
        self:getChildByName("Bar_1"):setPercent(self:getPer(self.param.level))
    end

    self:getChildByName("Text_Name"):setString(self.param.name)
    self:getChildByName("Text_1"):setString(self.param.level)
    self:getChildByName("Text_2"):setString(Language.Game_Attack) 
    self:getChildByName("Text_3"):setString(Language.Game_Skill) 
    self:getChildByName("Text_4"):setString(self.param.yellow)    
    self:getChildByName("Text_5"):setString(self.param.blue)
    self:getChildByName("Text_6"):setString(self.param.attack)
    
    if self.param.level >= 10 then
        self:getChildByName("Button_2"):setEnabled(false)
        self:getChildByName("Button_2"):setColor(cc.c4b(117, 117, 117, 255))
    else
        self:getChildByName("Button_2"):setEnabled(true)
        self:getChildByName("Button_2"):setColor(cc.c4b(255, 255, 255, 255))
    end

    if self.param.level >= 20 then
        self:getChildByName("Text_max"):setVisible(true)
        self:getChildByName("Text_max"):setString(Language.Your_hero_rating)
        self:getChildByName("Text_4"):setVisible(false) 
        self:getChildByName("Text_5"):setVisible(false)
        self:getChildByName("Text_7"):setVisible(false) 
        self:getChildByName("Button_1"):setVisible(false)
        self:getChildByName("Button_2"):setVisible(false) 
        self:getChildByName("icon_lvup_1"):setVisible(false) 
        self:getChildByName("icon_lvup_2"):setVisible(false) 
        self:getChildByName("Image_11"):setVisible(false) 
        self:getChildByName("Image_12"):setVisible(false)
        self:getChildByName("Image_13"):setVisible(false)
    else
        self:getChildByName("Text_max"):setVisible(false) 
        self:getChildByName("Text_4"):setVisible(true) 
        self:getChildByName("Text_5"):setVisible(true) 
        self:getChildByName("Text_7"):setVisible(true)
        self:getChildByName("Button_1"):setVisible(true)
        self:getChildByName("Button_2"):setVisible(true)
        self:getChildByName("icon_lvup_1"):setVisible(true) 
        self:getChildByName("icon_lvup_2"):setVisible(true) 
        self:getChildByName("Image_11"):setVisible(true) 
        self:getChildByName("Image_12"):setVisible(true)
        self:getChildByName("Image_13"):setVisible(true)
    end
    
    self:getChildByName("Image_13"):setVisible(false) --隐藏价格
    self:getChildByName("Text_7"):setVisible(false)
    
    local framName = Prefix.PREGET_PET_PATH..self.param.type..PNG
    local  frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(framName)
    self:getChildByName("Sprite_1"):setSpriteFrame(frame)    
    
    local skillData  = SkillData[tostring(self.param.skill)]
    local goodsData = GoodsData[tostring(skillData.wigetID)]
    framName = Prefix.PREBATTLE_PICTURE..goodsData.picture .. PNG
    frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(framName)
    self:getChildByName("Sprite_2"):setSpriteFrame(frame)    
    
    framName = Prefix.PRECOMM_NNG..self.param.type .. PNG
    frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(framName)
    self:getChildByName("Sprite_3"):setSpriteFrame(frame)  
    
    local gropTable = GropPhotoData[tostring(self.param.grop)].grops
    for var = 1, 5, 1 do
        local photo = Prefix.PRES_PHOTO .. gropTable[var] .. PNG
        local texture = cc.Director:getInstance():getTextureCache():addImage(photo)
        self:getChildByName("Sprite_pet_"..var):setTexture(texture)
        self:getChildByName("Sprite_level_"..var):setSpriteFrame(frame) 
        if self.param.level >= (var - 1) * 5 then
            self:getChildByName("Text_level_"..var):setVisible(false)
            self:getChildByName("icon_"..var):setVisible(true)
            self:getChildByName("Sprite_level_"..var):setColor(cc.c3b(255, 255, 255))
            self:getChildByName("Sprite_pet_"..var):setColor(cc.c3b(255, 255, 255))
        else
            self:getChildByName("icon_"..var):setVisible(false)
            self:getChildByName("Text_level_"..var):setVisible(true)
        end
    end

    local role = self:getChildByName("role")
    if role~=nil then
        self:removeChild(role,true)
        role = nil
    end
    local role = Role:create(self.param)
    role:setPosition(25, 30) 
    role:setScale(1.5)
    role:playIdle()
    role:setName("role")
    self:addChild(role,101)
end

function DrowthDialog:getPer(lv)
--    local per = 0
--    if self.param.level>=20 then
--        per = 100
--    elseif self.param.level>=15 then
--        per = 80
--    elseif self.param.level>=10 then
--        per = 60
--    elseif self.param.level>=5 then
--        per = 40
--    else
--        per = 15
--    end
    return (lv / 20) * 100
end

return DrowthDialog
