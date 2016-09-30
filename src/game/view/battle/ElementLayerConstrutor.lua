-- 根据关卡编辑器数据，重现游戏关卡
local Element = require("game.view.battle.Element")
local Widget = require("game.view.battle.Widget")
local PacMan = require("game.view.battle.element.PacMan")
local Chimney = require("game.view.battle.element.Chimney")

--[[--
    layerDatas elementLayerData 元素层数据
]]
local function ElementLayerConstrutor(elementLayer,widgetLayer,layerDatas,getDataByGridXY)
    local elements = {}
    local widgets = {}
    for k,elementData in pairs(layerDatas) do
    
       
        local element = Element:create(elementData)
        element:setPosition(elementData.x * Config.Grid_MAX_Pix_Width,elementData.y * Config.Grid_MAX_Pix_Height)
        elementLayer:addChild(element)
        if elementData.widget ~= nil then
            local widgetData = elementData.widget
            local widget = nil
            if widgetData.eliminate and widgetData.eliminate.widgetID == 28 then--烟囱
                widget = Chimney:create(widgetData,getDataByGridXY)
            else
                widget = Widget:create(widgetData)
            end
            widget:setPosition(elementData.x * Config.Grid_MAX_Pix_Width,elementData.y * Config.Grid_MAX_Pix_Height)
            widgets[widgetData] = widget
            widgetLayer:addChild(widget)
        end
        -- 游戏是7X8矩阵,去掉边缘的修饰物，让后面只在这个矩阵里的运算，掉落引擎包括了最少层只用于掉落的第8层
        if elementData.x > 1 and elementData.x < 9 and elementData.y > 0 and elementData.y <= 8 then
            elements[elementData.id] = element  
        end
    end     
      
    return elements,widgets
end

return ElementLayerConstrutor