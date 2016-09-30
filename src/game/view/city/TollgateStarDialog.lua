--关卡解锁-星星
--Samuel
local TollgateStarDialog = class("TollgateStarDialog", function()
    return cc.CSLoader:createNode("TollgateDialog02.csb")
end)

--进入
function TollgateStarDialog:onEnter()
    local data = SharedManager:readData(tostring(self.param.point), Config.POINT_DATA_DUALFT)
    if data.isOpen then
        DialogManager:open(Dialog.Embattle, self.param.chapter)
        self:close()
        return
    end
    
    Config.OPEN_LOCK_ID = 0
    self:getChildByName("closeButton"):onClick(function()self:close()end)
    self:getChildByName("Button_1"):onClick(function()self:openHandler()end) -- 解锁
    Color.setLableShadows({self:getChildByName("Text_1"), self:getChildByName("Text_2"), self:getChildByName("Text_3"), self:getChildByName("Text_4")})
    local str = ""
    self:getChildByName("Text_2"):setString("x ".. self.param.num)
    str = Language.Star_Ower .. self.param.num .. Language.Star_Tollgate
    self:getChildByName("Text_3"):setString(str)
    self:getChildByName("Image_3"):setVisible(not self.param.bool)
    self:getChildByName("Image_4"):setVisible(self.param.bool)
    self:getChildByName("Text_4"):setVisible(not self.param.bool)
    
    if self.param.bool then
        self:getChildByName("Button_1"):setTitleText(Language.Game_Free_Unlock)
    else
        self:getChildByName("Text_4"):setString(Language.Two_Money)
        self:getChildByName("Button_1"):setTitleText(Language.Game_Unlock)
    end

    self:addEventListener(Event.UPDATA_POINT_UNLOCK, handler(self, self.updatePointUnlock))
end

function TollgateStarDialog:updatePointUnlock()
    TipsManager:ShowText(Language.Unlock_Success, nil, 28)
    local data = SharedManager:readData(tostring(self.param.point), Config.POINT_DATA_DUALFT)
    data.isOpen = true
    SharedManager:saveData(tostring(self.param.point), data, true)
    Config.OPEN_LOCK_ID = tonumber(self.param.point)
    DialogManager:open(Dialog.Embattle, self.param.chapter)
    self.param.image:setVisible(false)
    self:close()
end

--打开操作
function TollgateStarDialog:openHandler()
    local data = SharedManager:readData(tostring(self.param.point), Config.POINT_DATA_DUALFT)
    if not self.param.bool and not data.isOpen then
--        DialogManager:open(Dialog.Diamond)
--      local diamond = SharedManager:readData(Config.DIAMOND)
--        if diamond < 50 then
--            DialogManager:open(Dialog.Diamond)
--          return
--      else
--            SharedManager:saveData(Config.DIAMOND, diamond - 50, true)
--            self:dipatchGlobalEvent(Event.UPDATA_DIAMOND)
--      end
        DPayCenter.pay(301)
        return
    end

    data.isOpen = true
    SharedManager:saveData(tostring(self.param.point), data, true)
    Config.OPEN_LOCK_ID = tonumber(self.param.point)
    DialogManager:open(Dialog.Embattle, self.param.chapter)
    self.param.image:setVisible(false)
    self:close()
end

return TollgateStarDialog
