-- 游戏战斗下落判定

local Algorithm = class("AlgorithmFall")


-- 下方可否掉落判定
function Algorithm.isFallDown(widgetData,layerData)
    if  widgetData.pang or widgetData.eliminate.fall == 0 then
        return nil
    end
    local elementData = widgetData.element

    if elementData.hBlock == nil then               -- 下挡板挡住不可掉落
        if widgetData.eliminate.fall == 1 then      -- 道具表设置不可掉落
            -- 下一个格子为空才可以掉落
            local nextElementData = layerData:getDataByGridXY(widgetData.x,widgetData.y - 1)
            if nextElementData and nextElementData.widget == nil and nextElementData.block == nil then
               
                return nextElementData
            end 
        end  
    end
    return nil
end

-- 左下角可否掉落判定
function Algorithm.isFallDownLeft(widgetData,layerData)
    if widgetData.pang or widgetData.eliminate.fall == 0 then
        return nil
    end

    local originalElementData = widgetData.element
    local targetElementData = layerData:getDataByGridXY(originalElementData.x - 1,originalElementData.y - 1)

    -- 目标点不能有道具
    if targetElementData == nil or targetElementData.widget ~= nil or targetElementData.block ~= nil then 
        return nil
    end
    
    -- 最上层只能往下掉
    if targetElementData.y == 8 then
        return nil
    end
    
    -- 上层的道具不能再往下掉才允许左右侧的道具填补
    local bool = false
    for ty = targetElementData.y+1,7 do
        local tElementData =  layerData:getDataByGridXY(targetElementData.x ,ty)
        if tElementData.block ~= nil or tElementData.hBlock ~= nil then
            bool = true
            break
        end
        if tElementData.widget ~= nil and tElementData.widget.pang ~= nil then
            bool = true
            break
        end
        
        if tElementData.widget ~= nil and tElementData.widget.eliminate.fall == 0 then
            bool = true
            break
        end
        
        if  tElementData.widget ~= nil then
            return nil 
        end
    end
    
    if not bool then return nil end

    local rightElementData = layerData:getDataByGridXY(targetElementData.x + 1,targetElementData.y)
    local upElementData = layerData:getDataByGridXY(targetElementData.x ,targetElementData.y + 1)
    
    local block1 = upElementData:isHBlock() or upElementData:isVBlock()
    local block2  = targetElementData:isVBlock() or originalElementData:isHBlock()
    if block1 and block2 then

        return nil
    end
    return targetElementData
end

-- 右下角可否掉落判定
function Algorithm.isFallDownRight(widgetData,layerData)
    if widgetData.pang or widgetData.eliminate.fall == 0 then
        return nil
    end

    local originalElementData = widgetData.element

    local targetElementData = layerData:getDataByGridXY(originalElementData.x + 1,originalElementData.y - 1)

    -- 目标点不能有道具
    if targetElementData == nil or targetElementData.widget ~= nil or targetElementData.block ~= nil then 
        return nil
    end

    -- 最上层只能往下掉
    if targetElementData.y == 8 then
        return nil
    end
    -- 上层的道具不能再往下掉才允许左右侧的道具填补
    local bool = false
    for ty = targetElementData.y+1,7 do
        local tElementData =  layerData:getDataByGridXY(targetElementData.x ,ty)
        if tElementData.block ~= nil or tElementData.hBlock ~= nil then
            bool = true
            break
        end
        if tElementData.widget ~= nil and tElementData.widget.pang ~= nil then
            bool = true
            break
        end
        if tElementData.widget ~= nil and tElementData.widget.eliminate.fall == 0 then
            bool = true
            break
        end
        
        if  tElementData.widget ~= nil then
            return nil
        end
    end

    if not bool then return nil end
    
    local leftElementData = layerData:getDataByGridXY(targetElementData.x - 1,targetElementData.y)
    local upElementData = layerData:getDataByGridXY(targetElementData.x ,targetElementData.y + 1)

    local block1 = originalElementData:isVBlock() or upElementData:isHBlock()
    local block2  = originalElementData:isHBlock() or leftElementData:isVBlock()

    if block1 and block2 then
        return nil
    end 
    return targetElementData
end

return Algorithm