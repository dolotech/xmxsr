-- 提示对话框

local alert = class("AlertDialog",function()
    return display.createUI("AlertDialog.csb")
end)

function alert:onEnter()
    
    self:getChildByName("Text_1"):setString(self.param.title or Language.Game_Tips)
    self:getChildByName("Text_2"):setString(self.param.text or "")
    self:getChildByName("Button_1"):setTitleText(self.param.okText or Language.Game_OK)
    
    self:getChildByName("closeButton"):onClick(
    function()
        if self.param and self.param["closeFun"]~=nil then
           self.param.closeFun()
        end
        self:close()
    end, 
    false)
    
    self:getChildByName("Button_1"):onClick(
        function()
            if self.param and self.param["okFun"]~=nil then
                self.param.okFun()
            end
            self:close()
        end, 
     true)
end

return alert
