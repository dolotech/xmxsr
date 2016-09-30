
-- 首冲礼包
local PingCooDialog = class("PingCooDialog",function()
    return cc.CSLoader:createNode("PingCooDialog.csb")
end)

function PingCooDialog:create()
    local dialog = PingCooDialog.new()
    return dialog
end

function PingCooDialog:onEnter()
    Color.setLableShadows({self:getChildByName("Text_1"),self:getChildByName("Text_2"),self:getChildByName("Text_3")})
    self:getChildByName("closeButton"):onClick(function()self:close()end)
    self:getChildByName("Button_1"):onClick(function()self:getHandler()end)
    
    self:addEventListener(Event.UPDATA_PINGCOO_UI,handler(self,self.updateHandler))
    
    local data = SharedManager:readData(Config.PingCoo)
    if data.times<=0 then
        self:getChildByName("Button_1"):setEnabled(false)
        self:getChildByName("Button_1"):setTitleText(Language.Game_Been_Exhausted)
        self:getChildByName("Button_1"):setColor(cc.c4b(117,117,117,255))
    else
        self:getChildByName("Button_1"):setEnabled(true)
        self:getChildByName("Button_1"):setColor(cc.c4b(255,255,255,255))
        self:getChildByName("Button_1"):setTitleText(Language.Gmae_Receive_free .. "(" .. data.times .. ")")
    end

end

function PingCooDialog:updateHandler()
    local data = SharedManager:readData(Config.PingCoo)
    
    if data.times<=0 then
        self:getChildByName("Button_1"):setEnabled(false)
        self:getChildByName("Button_1"):setTitleText(Language.Game_Been_Exhausted)
        self:getChildByName("Button_1"):setColor(cc.c4b(117,117,117,255))
    else
        self:getChildByName("Button_1"):setEnabled(true)
        self:getChildByName("Button_1"):setColor(cc.c4b(255,255,255,255))
        self:getChildByName("Button_1"):setTitleText(Language.Gmae_Receive_free .. "(" .. data.times ..")")
    end
end

function PingCooDialog:getHandler()
    self:getChildByName("Button_1"):setEnabled(false)
    DPayCenter.pingcooHandler()
end

return PingCooDialog
