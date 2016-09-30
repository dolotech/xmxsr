--主城场景

local FaceBookDialog = class("FaceBookDialog",function()
    return display.createUI("FaceBookDialog.csb")
end)

function FaceBookDialog:create()
    local dialog = FaceBookDialog.new()
    return dialog
end

function FaceBookDialog:onEnter()
    
    self:getChildByName("Button_1"):setTitleText(Language.To_FaceBook_sign)
    self:getChildByName("Button_2"):setTitleText(Language.Recovery_Archive)
    self:getChildByName("Button_3"):setTitleText(Language.Upload_Archive)
    
    self:getChildByName("Text_1"):setString(Language.Social)
    self:getChildByName("Text_2"):setString(Language.Log_Receive_Diamonds)
    
    self:getChildByName("closeButton"):onClick(function(parameters)Audio.playSound(Sound.SOUND_UI_READY_BACK,false)self:close()end,false)
    
    self:getChildByName("Button_1"):onClick(function(parameters)  TipsManager:ShowText(Language.Log_Receive_Diamonds) end,true)
    
    self:getChildByName("Button_2"):onClick(function(parameters)end,true)
    
    self:getChildByName("Button_3"):onClick(function(parameters)end,true)
end

return FaceBookDialog
