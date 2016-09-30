--宠物信息
local PetInfoDialog = class("PetInfoDialog",function()
    return display.createUI("PetInfoDialog.csb")
end)

function PetInfoDialog:create()
    local dialog = PetInfoDialog.new()
    return dialog
end

function PetInfoDialog:onEnter()
    self:getChildByName("closeButton"):onClick(function()Audio.playSound(Sound.SOUND_UI_READY_BACK,false)self:close()end,false,false)
    
    local textTrue = cc.Director:getInstance():getTextureCache():addImage(Prefix.PREPET_BG..self.param.type..PNG)
    self:getChildByName("bg"):setTexture(textTrue)
    
    self:updataUI()
    self:playWin()
    Audio.playSound(Sound[self.param.voice])
end

function PetInfoDialog:updataUI()
    self:getChildByName("Text_Name"):setString(self.param.name)
    self:getChildByName("Text_1"):setString(self.param.level)
    self:getChildByName("Text_2"):setString(Language.POWER)
    self:getChildByName("Text_3"):setString(self.param.attack)
    self:getChildByName("Text_4"):setString(Language.Game_Skill)
    self:getChildByName("Text_5"):setString(self.param.skilldetail)
    self:getChildByName("Text_6"):setString(self.param.detail)
    
    Color.setLableShadows({
        self:getChildByName("Text_1"),
        self:getChildByName("Text_2"),
        self:getChildByName("Text_3"),
        self:getChildByName("Text_4"),
        self:getChildByName("Text_5"),
        self:getChildByName("Text_6")})

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


    local role = self:getChildByName("role")
    if role~=nil then
        self:removeChild(role,true)
        role = nil
    end
    local role = Role:create(self.param)
    role:setScale(1.5)
    role:setPosition(5,30) 
    role:playIdle()
    role:setName("role")
    self:addChild(role)
end

--播放胜利动作
function PetInfoDialog:playWin()
    local role = self:getChildByName("role")
    local function petEventCallBack(role,armatureBack,movementType,movementID)
        if movementType == ccs.MovementEventType.loopComplete and movementID==Action.PLAY_WIN then
            role:playIdle()--待机
        end   
    end
    role:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)petEventCallBack(role,armatureBack,movementType,movementID)end)
    role:playWin()--胜利动作
end

return PetInfoDialog
