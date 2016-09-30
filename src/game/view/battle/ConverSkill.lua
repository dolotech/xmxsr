-- 转换技能
local ConverSkill = class("ConverSkill")
local Array9 = {{-1,1},{0,1},{1,1},{1,0},{1,-1},{0,-1},{-1,-1},{-1,0}}
function ConverSkill:create(widgets,getDataByGridXY)
    local instance = ConverSkill.new(widgets,getDataByGridXY)
    return instance
end

function ConverSkill:ctor(widgets,getDataByGridXY)

    self.widgets= widgets
    self.getDataByGridXY = getDataByGridXY
end



function ConverSkill:unConver(tElment)
    -- 反转换
--    print(#tElment.skillTriggle)
    if tElment.skillTriggle then
        for i = 1,#tElment.skillTriggle do
            local te = tElment.skillTriggle[i]
            local tWiget = te.widget
            tWiget.eliminate = tWiget.orginal
            local widget = self.widgets[tWiget]
            widget:setOpacity(255)
            widget:updateEliminate()
        end
        tElment.skillTriggle = nil
    end  
end


function ConverSkill:conver(elementData,pathArr)
    -- 转换
    local elementArr = self:converSkill(elementData,pathArr) 
    if elementArr then
        elementData.skillTriggle = elementArr
        for i = 1,#elementArr do
            local tElment = elementArr[i]
            local tWiget = tElment.widget
            tWiget.orginal = tWiget.eliminate
            tWiget.eliminate = clone(GoodsData[tostring(elementData.widget.eliminate.type)])
            local widget = self.widgets[tWiget]
            widget:setOpacity(255)
            widget:updateEliminate()
        end
    end
end


--    2：转换
function ConverSkill:converSkill(elementData,excuArr)
    local elementDataArr = nil
    if elementData.widget ~= nil and elementData.widget.skill ~= nil and elementData.widget.skill.type == 2 then
        local skilData = elementData.widget.skill

        if skilData.power > 0 then
            elementDataArr = {}

            local powerRadius = math.sqrt(skilData.power)
            local radiusIndex = math.ceil(powerRadius)

            for i = 1,#Array9 do
                for k = 1,radiusIndex do
                    for m = 1,radiusIndex do
                        local pos = Array9[i]
                        local gapx = pos[1] * k
                        local gapy = pos[2] * m
                        local targetElementData = self.getDataByGridXY(gapx +elementData.x,gapy + elementData.y)
                        -- 被转换的道具不能是技能
                        if targetElementData and targetElementData.widget and targetElementData.widget.skill == nil then
                            -- 被转换的道具应是可消除的5种元素之一
                            if targetElementData.widget.eliminate.type <= 5 then
                                -- 被转换的道具不能有附着物
                                if targetElementData.widget.pang == nil then
                                    local dist = gapx * gapx + gapy * gapy  
                                    if dist <= skilData.power then
                                        if not table.indexof(excuArr,targetElementData) then
                                            if not table.indexof(elementDataArr,targetElementData) then
                                                elementDataArr[#elementDataArr+1] = targetElementData
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end 
    return elementDataArr
end

return ConverSkill