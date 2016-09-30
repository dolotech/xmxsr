--升级购买
local BuyLevelDialog = class("BuyLevelDialog",function()
    return display.createUI("BuyLevelDialog.csb")
end)

function BuyLevelDialog:create()
    local dialog = BuyLevelDialog.new()
    return dialog
end

function BuyLevelDialog:onEnter()
    self:getChildByName("closeButton"):onClick(function()Audio.playSound(Sound.SOUND_UI_READY_BACK,false)self:close()end,false,false)
    self:getChildByName("Text_1"):setString(self.param.yellow)    
    self:getChildByName("Text_2"):setString(self.param.blue)
    self:getChildByName("Text_3"):setString(self.param.diamond)
    self:getChildByName("Text_title"):setString(Language.Complement_runes)
    self:getChildByName("Button_1"):setTitleText(Language.Complement)
    self:getChildByName("Button_1"):onClick(function()self:upgradeHandler()end,true)
    
    Color.setLableShadows({
        self:getChildByName("Text_1"),
        self:getChildByName("Text_2"),
        self:getChildByName("Text_3"),
        self:getChildByName("Text_title")})
end


--操作升级
function BuyLevelDialog:upgradeHandler()
    local money = self.param.diamond
    local diamond = SharedManager:readData(Config.DIAMOND)
    if diamond>=money then
        TalkingData.onPurchase("购买升级",1,money,diamond-money)
        SharedManager:saveData(Config.DIAMOND,diamond-money)

        self:dipatchGlobalEvent(Event.UPDATA_DIAMOND)

        local upgradeID = self.param.upgradeID
        local attack =  self.param.attack
        local curId = self.param.id 
        RoleDataManager.upgrade(self.param.type,self.param.id,self.param.upgradeID)
        self.param = clone(RoleDataManager.getRoleDataByID(self.param.upgradeID))
        self.param.id = upgradeID
        
        attack = self.param.attack-attack
        TipsManager:ShowText(Language.Level_Up)
        performWithDelay(SceneManager.currentScene,function()TipsManager:ShowText(Language.POWER.. "+" ..attack)end,0.5)
        if self.param.level%5==0 then
            performWithDelay(SceneManager.currentScene,function()TipsManager:ShowText(Language.Game_Skill .. Language.Level_Up)end,1)
        end
        
        self:dipatchGlobalEvent(Event.UPDATA_PETUI,{id=curId ,roleData=self.param})
        self:dipatchGlobalEvent(Event.UPDATA_PETBUY_UI,self.param)
        Audio.playSound(Sound.SOUND_UI_HERO_LVUP,false)
        self:close()
    else
        DialogManager:open(Dialog.Diamond)
        TalkingData.onPageStart("购买升级")
        return
    end
end

return BuyLevelDialog
