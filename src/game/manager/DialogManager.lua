-- 对话框管理器
local DialogManager = class("DialogManager")

--打开窗口dialog为Node显示对象
function DialogManager:open(dialogName,param,layerOpacity)
    if self.dialog==nil then self.dialog = {} end
    if self.mask==nil then self.mask = {} end

    local dialog  = self.dialog[dialogName]

    if dialog == nil then
    --当前场景
        local layer =  SceneManager.currentScene.pLayer
        --生成遮罩层
        local maskLayer = self.mask[dialogName]
        if maskLayer==nil then
            local rect = cc.rect(0,0,stageWidth,stageHeight)
            local has = false
            for key, var in pairs(self.mask) do
           	    has = true
           	    break
            end
            if has then
                maskLayer  = display.createMaskLayer(rect,0,0,nil)
            else
                maskLayer  = display.createMaskLayer(rect,layerOpacity or 255,0.5,nil)
            end
            self.mask[dialogName] = maskLayer
        end
        layer:addChild(maskLayer)
        self.mask[dialogName] = maskLayer
        if(param ~= nil)then param.maskLayer = maskLayer end

    --生成窗口模块层
        dialog = require(dialogName):new()      
        self.dialog[dialogName] = dialog         
        local function closeDialg(dialogN)
            self.curDialogName = ""
            local instanDialog = self.dialog[dialogN]
            if  instanDialog ~= nil and instanDialog:getParent() ~= nil then
                instanDialog:removeFromParent(true)
            end
            
            local mask =  self.mask[dialogName]
            if mask~=nil then
                mask:removeFromParent(true)
                self.mask[dialogName] = nil
            end
        end
        
        local function onNodeEvent(dialogN,event)
            local instanDialog = self.dialog[dialogN]
            if  instanDialog ~= nil then
                if "enter" == event then
                   instanDialog:onEnter()
                elseif "exit" == event then
                    instanDialog:unregisterScriptHandler()
                    self.dialog[dialogN] = nil          
                    instanDialog:onExit()             
                end
            end 
        end
        dialog:registerScriptHandler(handler(dialogName,onNodeEvent))  
        
        local function closeEventListener(dialogN,event) 
            local dia = event._userdata
            if dia==dialog then
                closeDialg(dialogN)
            end
        end
        dialog:addEventListener(EVENT_CLOSE_DIALOG, handler(dialogName,closeEventListener))
        self.isActionNotRun = false--打开窗口动画是否完成
        dialog:open(layer,param, function() self.isActionNotRun = true end)
    end
    self.curDialog = dialog
    self.curDialogName = string.splitEnd(dialogName,".")
end

--关闭窗口bdialog为Node显示对象
function DialogManager:close(dialogName)
    local dig = self.dialog[dialogName]
    if dig ~=nil then
        dig:close()
    end
    self.curDialogName = ""
end

function DialogManager:isOpen(dialogName)
    return self.dialog[dialogName] ~= nil
end

function DialogManager:getDialogByName(dialogName)
    return self.dialog[dialogName]
end

return DialogManager
