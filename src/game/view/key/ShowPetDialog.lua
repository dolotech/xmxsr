
--展示宠物
local ShowPetDialog = class("ShowPetDialog",function()
    return display.createUI("ShowPetDialog.csb")
end)
local umengInterFace = require("src.sdk.umengInterFace")
function ShowPetDialog:create()
    local dialog = ShowPetDialog.new()
    return dialog
end

--初始化设置
function ShowPetDialog:onEnter()
    local imgbg = self:getChildByName("bg")
    Color.setLableShadows({
        imgbg:getChildByName("Text_Name"),
        imgbg:getChildByName("Text_1"),
        imgbg:getChildByName("Text_2"),
        imgbg:getChildByName("Text_3"),
        imgbg:getChildByName("Text_6"),
        imgbg:getChildByName("Text_des")
    })
    local btn1 = imgbg:getChildByName("Button_1")
    btn1:setTitleText(Language.Game_Great)
    btn1:onClick(function(parameters)
        if(self.param.funCloseCallBack ~= nil)then self.param.funCloseCallBack() end
        Audio.playSound(Sound.SOUND_UI_READY_BACK,false)
        self:close()
    end,true)
    
    imgbg:getChildByName("Button_2"):onClick(function(parameters) 
        umengInterFace:screen()
       end,true)
    if DPayCenter.isOpenUmeng == false then
        imgbg:getChildByName("Button_2"):setVisible(false)
        btn1:setPositionX(imgbg:getPositionX()+imgbg:getContentSize().width/2)-- + (imgbg:getContentSize().width - btn1:getContentSize().width)/2)
    end
    local textTrue = cc.Director:getInstance():getTextureCache():addImage(Prefix.PREPET_BG..self.param.type..PNG)
    imgbg:setTexture(textTrue)
    
    self:updataUI()
    if(self.param.isTween == false)then 
        imgbg:setVisible(false)
        local point = cc.pSub(self.param.startPoint,cc.p(stageWidth/2,stageHeight/2))
        self.role:setPosition(point)
        self.role:setScale(0)
        local sequ = cc.Sequence:create(
            cc.ScaleTo:create(0.5, 0.8),
            cc.Spawn:create(cc.ScaleTo:create(0.8, 1.5),cc.EaseIn:create(cc.MoveTo:create(0.8,cc.p(0,0)),2)),
            cc.CallFunc:create(function()
                self.param.maskLayer.sprite:fadeTo(0.3, 255)
                imgbg:setVisible(true)
                self:openAni(imgbg)
                self:playWin()
                Audio.playSound(Sound[self.param.voice])
            end)
        )
        self.role:runAction(sequ)
    else
        self:playWin()
        Audio.playSound(Sound[self.param.voice])
    end
end

--更新UI
function ShowPetDialog:updataUI()
    local imgbg = self:getChildByName("bg")
    imgbg:getChildByName("Text_Name"):setString(self.param.name)
    imgbg:getChildByName("Text_1"):setString(self.param.level)
    imgbg:getChildByName("Text_2"):setString(Language.Game_Attack) 
    imgbg:getChildByName("Text_3"):setString(Language.Game_Skill) 
    imgbg:getChildByName("Text_6"):setString(self.param.attack) 
    imgbg:getChildByName("Text_des"):setString(self.param.detail) 
    

    local framName = Prefix.PREGET_PET_PATH..self.param.type..PNG
    local  frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(framName)
    imgbg:getChildByName("Sprite_1"):setSpriteFrame(frame)    

    local skillData  = SkillData[tostring(self.param.skill)]
    local goodsData = GoodsData[tostring(skillData.wigetID)]
    framName = Prefix.PREBATTLE_PICTURE..goodsData.picture .. PNG
    frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(framName)
    imgbg:getChildByName("Sprite_2"):setSpriteFrame(frame)    

    framName = Prefix.PRECOMM_NNG..self.param.type .. PNG
    frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(framName)
    imgbg:getChildByName("Sprite_3"):setSpriteFrame(frame)  

    local role = Role:create(self.param)
    role:setScale(1.5)
    role:playIdle()
    self:getChildByName("nodePetLoc"):addChild(role)
    self.role = role
end

--播放胜利动作
function ShowPetDialog:playWin()
    local role = self.role
    local function petEventCallBack(role,armatureBack,movementType,movementID)
        if movementType == ccs.MovementEventType.loopComplete and movementID==Action.PLAY_WIN then
            role:playIdle()--待机
        end   
    end
    role:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)petEventCallBack(role,armatureBack,movementType,movementID)end)
    role:playWin()--胜利动作
end

return ShowPetDialog
