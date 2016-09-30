-- 游戏战斗挡板判定

-- 判定是否可以连接
local  connected = function (elementData,last,getDataByGridXY,sameColor,widget)
    
    -- 相同元素才可以连接 
    if widget == nil and sameColor == nil and elementData.widget.eliminate.type ~= last.widget.eliminate.type  then
        return false
    end
    
    if widget == nil and (last.widget.eliminate.type > 5 or elementData.widget.eliminate.type > 5) then
        return false
    end
    
    -- 以下判定格挡 
    local elementDataIsHBlock = elementData:isHBlock()
    local lastElementDataIsHBlock = last:isHBlock()

    local elementDataIsVBlock = elementData:isVBlock()
    local lastElementDataIsVBlock = last:isVBlock()

    if elementData.x == last.x and elementData.y < last.y then      --  下边
        if lastElementDataIsHBlock then
            return false
    end
    elseif elementData.x == last.x and elementData.y > last.y then  -- 上边
        if elementDataIsHBlock then
            return false
    end
    elseif elementData.y == last.y and elementData.x < last.x then  -- 左边
        if elementDataIsVBlock then
            return false
    end
    elseif elementData.y == last.y and elementData.x > last.x then      -- 右边
        if lastElementDataIsVBlock then
            return false
    end 
    end


    -- 左上角
    if(last.x - 1 == elementData.x and last.y + 1 == elementData.y) then
        local downData =getDataByGridXY(elementData.x,elementData.y - 1)
        local rightData = getDataByGridXY(elementData.x + 1,elementData.y )
        local downBlock = false
        local rightBlock = false

        downBlock = elementDataIsVBlock or rightData:isHBlock()
        rightBlock =  elementDataIsHBlock or downData:isVBlock()

        if downBlock and rightBlock then
            return false
        end
    end


    -- 右上角
    if(last.x + 1 == elementData.x and last.y + 1 == elementData.y) then
        local downData = getDataByGridXY(elementData.x,elementData.y - 1)
        local leftData = getDataByGridXY(elementData.x - 1,elementData.y )
        local downBlock = false
        local leftBlock = false
        downBlock = elementDataIsHBlock or lastElementDataIsVBlock
        leftBlock = leftData:isVBlock() or leftData:isHBlock()

        if downBlock and leftBlock then
            return false
        end
    end


    -- 右下角
    if(last.x + 1 == elementData.x and last.y - 1 == elementData.y) then
        local downData = getDataByGridXY(elementData.x - 1,elementData.y)
        local rightData = getDataByGridXY(elementData.x ,elementData.y +1 )

        local rightBlock = lastElementDataIsHBlock or downData:isVBlock()
        local downBlock = lastElementDataIsVBlock or  rightData:isHBlock()

        if downBlock and rightBlock then
            return false
        end
    end

    -- 左下角
    if(last.x - 1 == elementData.x and last.y - 1 == elementData.y) then
        local downData = getDataByGridXY(elementData.x + 1,elementData.y)
        local leftData = getDataByGridXY(elementData.x ,elementData.y + 1)

        local leftBlock = false
        local downBlock = false

        leftBlock = leftData:isVBlock() or leftData:isHBlock()
        downBlock = elementDataIsVBlock or lastElementDataIsHBlock

        if downBlock and leftBlock then
            return false
        end
    end

    return true
end

return connected