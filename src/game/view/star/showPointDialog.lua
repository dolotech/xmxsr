-- 显示未取得满星关卡
local showPointDialog = class("showPointDialog",function()
    return cc.CSLoader:createNode("guankajiedian.csb")
end)

--进入
function showPointDialog:onEnter()
    self:getChildByName("Button_1"):onClick(function() self:close() end)
    self:getChildByName("Panel_1"):setVisible(false)
    self:initDialog()
end

function showPointDialog:getStarData()
    local tData = {}
    local num = SharedManager:readData(Config.POINT)
    local count = 1
    for index = 1001,num - 1 do
        local data = SharedManager:readData(tostring(index),Config.POINT_DATA_DUALFT)
        if data.star < 3 then
            tData[count] = {}
            tData[count].count = data.star
            tData[count].index = index - 1000
            count = count + 1
        end
    end
    return tData
end

function showPointDialog:initDialog()
    local tData = self:getStarData()
    local panel = nil
    local count = 1
    for index = 1, table.nums(tData) do
        local node = nil
        if count == 1 then
            panel = self:getChildByName("Panel_1"):clone()
            panel:setVisible(true)
            self:getChildByName("ListView_1"):addChild(panel)
            panel:getChildByName("Panel_btn2"):setVisible(false)
            panel:getChildByName("Panel_btn3"):setVisible(false)
            node = panel:getChildByName("Panel_btn1")
        elseif count == 2 then
            node = panel:getChildByName("Panel_btn2")
        else
            node = panel:getChildByName("Panel_btn3")
        end
        
        node:setVisible(true)
        node:getChildByName("Text_point"):setString(tostring(tData[index].index))
        if tData[index].count == 1 then
            node:getChildByName("Image_star1"):setVisible(true)
        elseif tData[index].count == 2 then
            node:getChildByName("Image_star1"):setVisible(true)
            node:getChildByName("Image_star2"):setVisible(true)
        end
        node:getChildByName("Button_dian"):onClick(function() 
            Global.selChapterId = tData[index].index + 1000
            DialogManager:open(Dialog.Embattle,{Id = tData[index].index + 1000, isTween = true}) 
             end)
        count = count + 1
        if count > 3 then
            count = 1
        end
    end
end

return showPointDialog

