--设置
local SettingDialog = class("SettingDialog", function()
    return display.createUI("SettingDialog.csb")
end)

local editor = nil
--require("game.view.serverInterface.serverInterface")
require("game.view.dataCenter.UserAccountDataCenter")
require("game.view.dataCenter.FriendDataCenter")
require("game.data.DirtyWord")

function SettingDialog:onEnter()
    self:getChildByName("Text_1"):setString(Language.SETTING)
    Color.setLableShadows({self:getChildByName("Text_1")})
    self:getChildByName("closeButton"):onClick(function(parameters)Audio.playSound(Sound.SOUND_UI_READY_BACK, false)self:close()end, true, false)
    self:statueVisibleMusic()
    self:statueVisibleSound()

    self:getChildByName("Button_5"):onClick(function(parameters)
        if Audio.bgm == 1 then 
            Audio.stopMusic()
            Audio.bgm = 0
        else     
            Audio.bgm = 1             
            Audio.playMusic(Audio.currentBGM)        
        end
        self:statueVisibleMusic()
        SharedManager:saveData("bgm", Audio.bgm, true)
    end, true)
    
    self:getChildByName("Button_6"):onClick(function(parameters)
        if Audio.sound == 1 then 
            Audio.stopAllSounds()
            Audio.sound = 0
            if device.platform == "windows"  or device.platform == "mac" then
                self:Test()
            end
        else     
            Audio.sound = 1
        end
        self:statueVisibleSound()
        SharedManager:saveData("sound", Audio.sound, true)
    end, true) 

    self:getChildByName("Text_4"):setString(Language.gm_Account)
    local user_id = SharedManager:readData("name")
    if user_id ~= "nil" then
        self:getChildByName("Text_2"):setString(user_id)
    else
        self:getChildByName("Text_2"):setString("")
    end
    
    UserAccountDataCenter.settingSureClick = handler(self, self.sureBtnClick)
    UserAccountDataCenter.settingCanelClick = handler(self, self.canelBtnClick)
    
    local visibleOrigin = cc.Director:getInstance():getVisibleOrigin()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local editBoxSize = cc.size(visibleSize.width  - 100, 60)
    local image2 = self:getChildByName("Image_2")
    local size1 = image2:getContentSize()
    
    EditName = ccui.EditBox:create(editBoxSize, "ui/black.png")
    EditName:setName("editorName")
    editor = EditName 
    EditName:setPosition(cc.p(size1.width/2, size1.height/2))
    EditName:setContentSize(size1)
    EditName:setFontName("fonts/font.TTF")
    EditName:setFontSize(42)
    EditName:setFontColor(cc.c3b(255, 255, 255))
    EditName:setPlaceHolder("")
    EditName:setPlaceholderFontColor(cc.c3b(255, 255, 255))
    EditName:setMaxLength(9)
    EditName:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    EditName.textAlign = cc.TEXT_ALIGNMENT_CENTER
    EditName:registerScriptEditBoxHandler(function() 
        -- local text = editor:getText()
        --     if string.len(text) > 9 then
        --         editor:setText(string.sub(text,1,9))
        --     end
        self:getChildByName("Button_sure"):setVisible(true)
        self:getChildByName("Button_motify"):setVisible(false)
    end)
    self:getChildByName("Image_base"):addChild(EditName)

    local playName = SharedManager:readData(Config.playName)
    if playName ~= "nil" then
        EditName:setText(playName)
        EditName:setEnabled(false)
        self:getChildByName("Button_sure"):setVisible(false)
        self:getChildByName("Button_motify"):setVisible(false)
    else
        EditName:setEnabled(true)
        EditName:setText(self:getChildByName("Text_name"):getString())
    end

    self:getChildByName("Text_name"):setString("")
    self:getChildByName("Button_sure"):setVisible(false)
    self:getChildByName("Button_sure"):onClick(function(parameters) 
        DialogManager:open(Dialog.messageBox)
        end)

    self:getChildByName("Button_motify"):onClick(function(parameters)  
            self:getChildByName("Button_sure"):setVisible(true)
            self:getChildByName("Button_motify"):setVisible(false)
            editor:touchDownAction(self,2)
            end)
end

function SettingDialog:sureBtnClick()
    local text = self:getChildByName("Image_base"):getChildByName("editorName"):getText()
    if text == "" then
        TipsManager:ShowText(Language.gm_NameNil)
    else
        local bDirty = DirtyWord:isDirtyWord(text)
        if bDirty then
            TipsManager:ShowText(Language.gm_DirtyWord)
        else
            serverinterface.MsgDoneById(serverinterface.MOTIFYNAME,handler(self, self.motifyCallBack),handler(self, self.getCurInputName))
        end
    end
end

function SettingDialog:canelBtnClick()
    self:getChildByName("Button_sure"):setVisible(false)
    self:getChildByName("Button_motify"):setVisible(true)
end

function SettingDialog:getCurInputName()
    return editor:getText()
end

function SettingDialog:motifyCallBack(_sType)
    if _sType == 1 then
        TipsManager:ShowText(Language.gm_motifyNameSucceed)
        print("name: "  .. EditName:getText())
        SharedManager:readData(Config.playName,EditName:getText(),true)
        EditName:setEnabled(false)
        self:getChildByName("Button_motify"):setVisible(false)
        self:getChildByName("Button_sure"):setVisible(false)
        SharedManager:saveData(Config.playName,EditName:getText(),true)
        --self:getChildByName("Image_2"):setVisible(false)
        --数据同步到server
        UserAccountDataCenter.saveAllUserDataToServer()
    elseif _sType == 2 then
--        print("服务器连接失败")
    elseif _sType == 3 then
--        print("用户userid为空")
    end
end

function SettingDialog:statueVisibleMusic()
    if Audio.bgm == 0 then 
        self:getChildByName("music_2"):setVisible(true)
    else     
        self:getChildByName("music_2"):setVisible(false)
    end
end

function SettingDialog:statueVisibleSound()
    if Audio.sound == 0 then 
        self:getChildByName("sound_2"):setVisible(true)
    else     
        self:getChildByName("sound_2"):setVisible(false)
    end
end

--test处理数据ios
function SettingDialog:Test(productsData)
    local products = 
    {
        [1] = {productIdentifier="com.turbotech.xmxsrft.diamond250", price=1.9999, priceLocale="abcac@asd=CNY"},
        [2] = {productIdentifier="com.turbotech.xmxsrft.diamond750", price=4.9999, priceLocale="abcac@asd=CNY"},
        [3] = {productIdentifier="com.turbotech.xmxsrft.diamond1800", price=9.9999, priceLocale="abcac@asd=CNY"},
        [4] = {productIdentifier="com.turbotech.xmxsrft.diamond4500", price=19.9999, priceLocale="abcac@asd=CNY"},
        [5] = {productIdentifier="com.turbotech.xmxsrft.diamond10000",price=39.9999, priceLocale="abcac@asd=CNY"},
        [6] = {productIdentifier="com.turbotech.xmxsrft.diamond5", price=0.9999, priceLocale="abcac@asd=CNY"},
        [7] = {productIdentifier="com.turbotech.xmxsrft.diamond6", price=0.9999, priceLocale="abcac@asd=CNY"},
        [8] = {productIdentifier="com.turbotech.xmxsrft.diamond1001", price=0.9999, priceLocale="abcac@asd=CNY"},
        [9] = {productIdentifier="com.turbotech.xmxsrft.diamond1002", price=0.9999, priceLocale="abcac@asd=CNY"},
        [10] = {productIdentifier="com.turbotech.xmxsrft.diamond1003", price=0.9999, priceLocale="abcac@asd=CNY"},
        [11] = {productIdentifier="com.turbotech.xmxsrft.diamond1004", price=0.9999, priceLocale="abcac@asd=CNY"},
        [12] = {productIdentifier="com.turbotech.xmxsrft.diamond1005", price=0.9999, priceLocale="abcac@asd=CNY"},
        [13] = {productIdentifier="com.turbotech.xmxsrft.diamond1006", price=0.9999, priceLocale="abcac@asd=CNY"},
        [14] = {productIdentifier="com.turbotech.xmxsrft.diamond1007", price=0.9999, priceLocale="abcac@asd=CNY"},
        [15] = {productIdentifier="com.turbotech.xmxsrft.diamond1009", price=0.9999, priceLocale="abcac@asd=CNY"},
    }
    for key1, var1 in pairs(products) do
        for key2, var2 in pairs(ShopData) do
            if var2.platform == DPayCenter.platform then--是否是ios
                if tostring(var2.payCode)==var1.productIdentifier then--是否对应商品ID
                    --修改价格显示
                    local price = tostring(var1.price)+"00"
                    local split = string.split(price,".")
                    local f1 = tonumber(string.sub(split[2],1,1))
                    local f2 = tonumber(string.sub(split[2],2,2))
                    price = split[1] .. "." .. f1 .. f2
                    var2.price = tonumber(price)
                    --修改货币标识符
                    var2.pay = string.split(var1.priceLocale,"=")[2]
                end
            end
        end
    end     
end

return SettingDialog
