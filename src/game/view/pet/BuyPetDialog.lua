--升级购买
local BuyPetDialog = class("BuyPetDialog",function()
    return display.createUI("BuyPetDialog.csb")
end)

function BuyPetDialog:create()
    local dialog = BuyPetDialog.new()
    return dialog
end

function BuyPetDialog:onEnter()
    self:getChildByName("closeButton"):onClick(handler(self, self.closeDialog), false, false)
    self:getChildByName("labelName"):setString(self.param.name)
    self:getChildByName("sprBg"):setTexture(Prefix.PREPET_BG..self.param.type..PNG)
    self:getChildByName("labelHint"):setString(string.format(Language.BuyPet_Hint, self.param.tollgate))
    self:getChildByName("labelMoney"):setString(tostring(self.param.buyPet))

    self:getChildByName("sprPet"):setTexture(Prefix.PRES_PHOTO .. self.param.photo ..PNG)
    self:getChildByName("btnBuy"):onClick(handler(self, self.buyPet))

    Color.setLableShadows({
        self:getChildByName("labelName"),
        self:getChildByName("Text_19"),
        self:getChildByName("labelHint"),
        self:getChildByName("labelMoney")})

    Audio.playSound(Sound[self.param.voice])
end

function BuyPetDialog:closeDialog()
    Audio.playSound(Sound.SOUND_UI_READY_BACK, false)
    self:close()
end

function BuyPetDialog:buyPet()
    local diamond = SharedManager:readData(Config.DIAMOND)
    if(diamond >= self.param.buyPet)then 
        local data = clone(self.param)
        TalkingData.onPurchase("购买英雄",1,self.param.buyPet,diamond - self.param.buyPet)
        SharedManager:saveData(Config.DIAMOND, diamond - self.param.buyPet)
        RoleDataManager.addRole(self.param.id)
        self:dipatchGlobalEvent(Event.UPDATA_PETUI,{id=self.param.id ,roleData=self.param})
        self:dipatchGlobalEvent(Event.UPDATA_DIAMOND)
        self:closeDialog()
        DialogManager:open("game.view.key.ShowPetDialog", data)
    else
        DialogManager:open(Dialog.Diamond)
        TalkingData.onPageStart("购买英雄")
    end
end

return BuyPetDialog
