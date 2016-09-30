-- 游戏战斗上下左右四方触发消除判定

local AlgorithmTrigger = class("AlgorithmTrigger")
function AlgorithmTrigger:create()
    local instance = AlgorithmTrigger.new()
    instance.triggerList = {}
    return instance
end

function AlgorithmTrigger:add(elementData,layerData,excludeList)
    if self.triggerList[elementData] ~= nil then
        return
    end
    -- 自身有夹子，，先把自身的夹子消除才能关联周围道具
    if elementData.widget.pang and elementData.widget.pang.connect == 1 then
        return 
    end
    
    local triggers = {}
     
    local function addToList(list,element,data)
        local bool = false
        
        for k,v in pairs(self.triggerList) do
            if v[data] then
                bool = true
                break
            end
        end
        
        if bool == false then
            list[data] = element
        end
     end
     
    self.triggerList[elementData] = triggers

    local function addElement( _elementData )
        if _elementData.widget ~= nil then
            if _elementData.widget.eliminate.type > 5 then
                if _elementData.widget.eliminate.eliminable == 1 
                or (_elementData.widget.eliminate.type == 13 and _elementData.widget.pang ~= nil) 
                then
                    addToList(triggers,_elementData,_elementData.widget)
                end
            else
                -- 污染物才可以被消除，夹子不能被关联消除
                if _elementData.widget.pang and _elementData.widget.pang.connect == 2 then        
                    addToList(triggers,_elementData,_elementData.widget)
                end
            end
        end 
    end
    
    local leftElementData = layerData:getDataByGridXY(elementData.x - 1,elementData.y)
    if leftElementData and table.indexof(excludeList,leftElementData) == false then
        if leftElementData.vBlock ~= nil then
            if leftElementData.vBlock.eliminable == 1 then
                addToList(triggers,leftElementData,leftElementData.vBlock)
            end
        else
            addElement(leftElementData)
        end
    end

    local rightElementData = layerData:getDataByGridXY(elementData.x + 1,elementData.y) 
    if rightElementData and table.indexof(excludeList,rightElementData) == false then
        if elementData.vBlock ~= nil then
            if elementData.vBlock.eliminable == 1 then
                addToList(triggers,elementData,elementData.vBlock)
            end
        else
            addElement(rightElementData)
        end
    end
    
    if elementData.y < 8 then 
        local upElementData = layerData:getDataByGridXY(elementData.x ,elementData.y+1)
        if upElementData and table.indexof(excludeList,upElementData) == false then
            if upElementData.hBlock ~= nil then
                if upElementData.hBlock.eliminable == 1 then
                    addToList(triggers,upElementData,upElementData.hBlock)
                end
            else
                addElement(upElementData)
            end
        end
    end

    local downElementData = layerData:getDataByGridXY(elementData.x ,elementData.y-1)
    if downElementData and table.indexof(excludeList,downElementData) == false then
        if elementData.hBlock ~= nil then
            if elementData.hBlock.eliminable == 1 then
                addToList(triggers,elementData,elementData.hBlock)
            end
        else
            addElement(downElementData)
        end
    end
end

function AlgorithmTrigger:remove(elementData)
    self.triggerList[elementData] = nil
end

return AlgorithmTrigger


    