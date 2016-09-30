
-- 首冲礼包
local FristGiftDialogTop = class("FristGiftDialogTop",function()
    return cc.CSLoader:createNode("FristGiftDialogTop.csb")
end)

function FristGiftDialogTop:create()
    local dialog = FristGiftDialogTop.new()
    return dialog
end

function FristGiftDialogTop:onEnter()
    self:getChildByName("closeButton"):onClick(function()self:close()end)
    self:getChildByName("Button_1"):onClick(function()self:getHandler()end)
    self:getChildByName("Text_1"):setString(Language.Game_TimeReciprocal .. ":") --倒计时
    
    local saveTime  = SharedManager:readData(Config.fristTime)
    if saveTime == 0 then --如果没记录时间
        saveTime =  math.floor(socket.gettime()+ 24 * 3600)--保存一下时间
        SharedManager:saveData(Config.fristTime, saveTime, true)
    end
    
    local function VisibleText()
        self:getChildByName("Image_2"):setVisible(false)
        self:getChildByName("Text_1"):setVisible(false)
        self:getChildByName("Text_2"):setVisible(false)
    end
    
    self._Time = 0
    local function scheduleTime()
        local time = os.difftime(saveTime, math.floor(socket.gettime()))
        self:getChildByName("Text_2"):setString(getTimeStringH(time))
        self._Time = time
        if self._Time <= 0 then
            VisibleText()
        end
    end
    
    scheduleTime()
    self:schedule(function()
        scheduleTime()
    end, 1)
    
    local isFrist = SharedManager:readData(Config.isFrist)
    local isDiamond = SharedManager:readData(Config.isDiamond)
    if isFrist.frist == 1 or isFrist.fristStar == 1 or isDiamond == 1 then
        self:getChildByName("Button_1"):setTitleText(Language.Receive_Gifts)
        VisibleText()
        self._Time = 1
    else
        if self._Time <= 0 then
            VisibleText()
        end
        self:getChildByName("Button_1"):setTitleText(Language.Game_StoredValue)
    end
end

--获取礼包
function FristGiftDialogTop:getHandler()
    local isFrist = SharedManager:readData(Config.isFrist)
    local isDiamond = SharedManager:readData(Config.isDiamond)
    if isFrist.frist == 1 or isFrist.fristStar == 1 or isDiamond == 1 then
        local text = ""
        if self._Time <= 0 then
            --刷子
            local items = SharedManager:readData(Config.Storage)
            items[tostring(Config.TOOL_BRUSH)] = items[tostring(Config.TOOL_BRUSH)] + 5
            SharedManager:saveData(Config.Storage, items)
            --复活石
            local _Relive = SharedManager:readData(Config.Relive)
            _Relive = _Relive + 3
            SharedManager:saveData(Config.Relive, _Relive)
            text = "刷子x5, 复活石x2"
         else
            --伊利丹英雄
            RoleDataManager.addRole(1101)
            --刷子
            local items = SharedManager:readData(Config.Storage)
            items[tostring(Config.TOOL_BRUSH)] = items[tostring(Config.TOOL_BRUSH)] + 5
            SharedManager:saveData(Config.Storage, items)
            --复活石
            local _Relive = SharedManager:readData(Config.Relive)
            _Relive = _Relive + 3
            SharedManager:saveData(Config.Relive, _Relive)
            text = "伊利丹英雄x1, 刷子x5, 复活石x2"
        end
            TipsManager:ShowText(text, nil, 28)
            self:paySuccesHandler()
   else
        DialogManager:open(Dialog.Diamond)
        self:close()
    end
end

function FristGiftDialogTop:paySuccesHandler()
    SharedManager:saveData(Config.isfristTop, 1, true)
    self:dipatchGlobalEvent(Event.UPDATA_FRISTGIFT_UI_Top)
    performWithDelay(self, function()
        self:close()
    end, 0.5)
end

return FristGiftDialogTop
