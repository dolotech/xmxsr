--添加好友
local FriendAdd = class("FriendAdd", function()
    return display.createUI("Node_tianjiahaoyou.csb")
end)

require("game.view.serverInterface.serverInterface")

local inputId = ""
local editor = nil
function FriendAdd:onEnter()
    self:getChildByName("Button_1"):onClick(function() 
        self:close()
    end, true)

    local btn = self:getChildByName("Button_2")
    btn:onClick(function() 
        if btn:getTitleText() == Language.gm_sureAdd then
            -- 添加好友
            btn:setTitleText(Language.gm_add)
            local userid = SharedManager:readData("name")
            if userid ~= self.inputId then
                serverinterface.MsgDoneById(serverinterface.ADDFRIEND,handler(self, self.AddInfoCallBack),handler(self, self.getCurInputName))
            else
                btn:setTitleText(Language.gm_sureAdd)
                TipsManager:ShowText(Language.gm_cannotAddSelf)
            end
        else
            self.editor:touchDownAction(self,2)
        end
    end, true)
    
    local userid = SharedManager:readData("name")
    if userid then
        self:getChildByName("Text_3"):setString(Language.gm_selfAccount .. userid)
    else
        self:getChildByName("Text_3"):setString("")
    end

    self:createEditorBox()
end

function FriendAdd:AddInfoCallBack(typeInfo)
    if typeInfo == 1 then
        TipsManager:ShowText(Language.gm_AddSucceed)
        self.editor:setText("")
        serverinterface.MsgDoneById(serverinterface.GETFRIEND,FriendDataCenter.msgDone,FriendDataCenter.msgDone1)
    elseif typeInfo == 5 then
        TipsManager:ShowText(Language.gm_FriendExist)
    elseif typeInfo == 7 then
        TipsManager:ShowText(Language.gm_PlayNil)
    else
        TipsManager:ShowText(Language.gm_RequstError .. tostring(typeInfo))
    end

end

function FriendAdd:getCurInputName()
    return self.inputId
end

function FriendAdd:createEditorBox()
    local visibleOrigin = cc.Director:getInstance():getVisibleOrigin()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local editBoxSize = cc.size(visibleSize.width - 100, 60)
    local image2 = self:getChildByName("Image_3")
    local size1 = image2:getContentSize()
    
    EditName = ccui.EditBox:create(editBoxSize, "ui/black.png")
    EditName:setPosition(cc.p(size1.width/2,size1.height/2)) 
    EditName:setContentSize(size1)
    EditName:setFontName("fonts/font.TTF")
    EditName:setFontSize(48)
    EditName:setFontColor(cc.c3b(255,255,255))
    EditName:setPlaceHolder("")
    EditName:setPlaceholderFontColor(cc.c3b(255,255,255))
    EditName:setMaxLength(20)
    EditName:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    EditName.textAlign = ccui.VERTICAL_TEXT_ALIGNMENT_CENTER
    EditName:registerScriptEditBoxHandler(function()
        self:getChildByName("Button_2"):setTitleText(Language.gm_sureAdd)
        self.inputId = EditName:getText()
        if string.len(self.inputId) > 21 then
            EditName:setText(string.sub(self.inputId,1,21))
        end
    end)
    self:getChildByName("Image_3"):addChild(EditName)
    self.editor = EditName
end

return FriendAdd
