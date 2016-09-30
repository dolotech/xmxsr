-- 战斗内的连线特效
local Line = class("Line")
local hash = {["2"] = "1",["3"] = "2",["4"] = "3",["5"] = "3",["6"] = "3",["7"] = "4"}
local Vector2D = require("game.util.Vector2D")

local Line = class("Line",function()
    return cc.Node:create()
end)

function Line:create()
    local instance = Line.new()
   instance.lines = {}
    return instance
end

-- 添加连线特效
function Line:addLine(pathArr)  
    if #pathArr <= 1 then
        return
    end
    
    local elementData = pathArr[#pathArr-1]
    local nextElementData = pathArr[#pathArr]
        local vecoty = Vector2D.new((nextElementData.x - elementData.x) * Config.Grid_MAX_Pix_Width,Config.Grid_MAX_Pix_Height* (nextElementData.y - elementData.y))
    local angle =360 -  math.radian2angle(vecoty:getAngle() )
    local id = elementData.id
    local line = self.lines[id]
    local length = #pathArr

    if length > 7 then
        length = 7
    end

    if line == nil then
        line = display.createArmature({path="effect/effect_001/effect_001"},"effect_001_" .. hash[tostring(length)])
        self.lines[id] = line 
        self:addChild(line)
        line:setPosition(elementData.x * Config.Grid_MAX_Pix_Width,elementData.y * Config.Grid_MAX_Pix_Height)
    end
    
    line:getAnimation():resume()
    line:setRotation(angle)
   
    line:setVisible(true)

    if #pathArr <= 7 then
        for i = 1,#pathArr -1  do
            local elementData = pathArr[i]
            local line = self.lines[elementData.id]
            if line ~= nil then 
                local n = "effect_001_" .. hash[tostring(length)]
                if line:getAnimation():getCurrentMovementID() ~= n then
                    line:getAnimation(): play(n)
                end
            end  
        end 
    end
end


function Line:removeLine(id,pathArr)
    local line = self.lines[id]
    if line ~= nil then
        line:setVisible(false)
        line:getAnimation():pause()
        
    end

    if pathArr ~= nil then
        local length = #pathArr
    
        if #pathArr < 7 then
            for i = 1,#pathArr -1  do
                local elementData = pathArr[i]
                local line = self.lines[elementData.id]
                if line ~= nil then 
                    local n = "effect_001_" .. hash[tostring(length)]
                    if line:getAnimation():getCurrentMovementID() ~= n then
                        line:getAnimation(): play(n)
                    end
                end  
            end 
        end
    
    end
end


return Line