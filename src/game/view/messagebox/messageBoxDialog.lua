--添加好友
local messageBox = class("messageBox", function()
    return display.createUI("AlertMsgDialog.csb")
end)

require("game.view.dataCenter.UserAccountDataCenter")

function messageBox:onEnter()
    self:getChildByName("Button_sure"):onClick(function() 
        Audio.playSound(Sound.SOUND_UI_READY_BACK, false)
        UserAccountDataCenter.settingSureClick()
        self:close()
    end, true)
    
    self:getChildByName("Button_canel"):onClick(function() 
        Audio.playSound(Sound.SOUND_UI_READY_BACK, false)
        UserAccountDataCenter.settingCanelClick()
        self:close()
    end, true)
    
end

return messageBox