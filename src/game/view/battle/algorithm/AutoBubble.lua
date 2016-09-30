-- 智能提醒玩家可连接的格子

local AutoBubble = class("AutoBubble")
local AlgorithmConneted = require("game.view.battle.algorithm.AlgorithmConneted")

    AutoBubble.Array9 = {{-1,1},{0,1},{1,1},{1,0},{1,-1},{0,-1},{-1,-1},{-1,0}}
    AutoBubble.Array4 = {{0,1},{1,0},{0,-1},{-1,0}}
function AutoBubble:create(elementArr,getDataByGridXY)
    local instance = AutoBubble.new(elementArr,getDataByGridXY)
    instance.getDataByGridXY = getDataByGridXY
    instance.elementArr = elementArr
    return instance
end

-- 是否是死地，（不可以向外连接的格子）
function AutoBubble:isDeadGrid(elementData,sameColor)
    
    if self:isAlive(elementData) then
        local Array9 = AutoBubble.Array9
        for i = 1,#Array9 do
            local pos = Array9[i]
            local target = self.getDataByGridXY(elementData.x + pos[1],elementData.y + pos[2])
            
            if target and target.widget ~= nil and AlgorithmConneted(target,elementData,self.getDataByGridXY,sameColor) then
                return false
            end
        end
     end

    return true
end


function AutoBubble:isAlive(elementData)
    if elementData == nil then
        return false   
    end
    -- 障碍物不可连接
    if elementData.block ~= nil  then
        return false
    end

    -- 空格子不可连接
    if elementData.widget == nil  then
        return false
    end

    -- 有附着物不可连接,且附着物为夹子

    if elementData.widget.pang ~= nil and  elementData.widget.pang.connect == 2 then
        return false
    end

    -- 道具表内物品属性为不可连接物品 
    if elementData.widget.eliminate.eliminable ==  2  then
        return false
    end
    
    return true
end

--  是否九宫格内
function AutoBubble:is9Scale(original,elementData)
    return math.abs(original.x - elementData.x) <= 1 and math.abs(original.y - elementData.y) <= 1
end

-- 判定是否可以连接
function AutoBubble:connected(elementData,path)
    if self:isAlive(elementData) then 
        --空队列，  非转换技能可以任意添加
        if path:enpty() then
            if nil ~= elementData.widget.skill and 2 == elementData.widget.skill.type then
                return false
            else
                return true
            end
        end 
        -- 队列中已经存在
        if path:isExist(elementData) then
            return false
        end
        local last = path:getLastOne()
        --  大于九宫格不可以连接 
        if self:is9Scale(last,elementData) then    
            return AlgorithmConneted(elementData,last,self.getDataByGridXY)
        end
    end
    return false
end


-- 判定两个格子之间是否可以连接
function AutoBubble:connectedBetweenTwo(original,elementData,sameColor)
    
    if self:isAlive(original) and self:isAlive(elementData) then
        return AlgorithmConneted(elementData,original,self.getDataByGridXY,sameColor)
    end

    return false
end

-- 递归搜索算法，搜索跟指定格子相连的所以格子
function AutoBubble:search(path,searched,sameColor)
    local origial = path[#path]
    for i = 1,#AutoBubble.Array9 do
        local pos = AutoBubble.Array9[i]
        local elementData = self.getDataByGridXY(origial.x + pos[1],origial.y + pos[2])
        if elementData ~= nil then
            if searched[elementData] == nil  then
                -- 防止循环获取
                if table.indexof(path,elementData) == false then
                    if self:connectedBetweenTwo(origial,elementData,sameColor) then
                        path[#path + 1] = elementData
                        self:search(path,searched,sameColor)
                    end
                end
--                searched[elementData] = true
            end
        end
    end
    return path
end

-- 全盘搜索是否有可爆炸技能的可用元素
function AutoBubble:isSkillElementSearch()
    local sameColor = true
    for i,v in ipairs(self.elementArr) do
        if(v.y<8 and not self:isDeadGrid(v,sameColor)
            and v.skill ~= nil and v.skill.type < 5 and v.skill.type ~= 2
        )then
            local path = self:search({v},{},sameColor)
            if(#path >= 3)then return true end
        end
    end
    return false
end

-- 全盘搜索3个及以上可以连接的道具
function AutoBubble:findPath(sameColor)  
    local len = #self.elementArr
    local searched = {}
    for i = 1,len do
        local elementData = self.elementArr[i]
        if  elementData.y < 8 then
            if not self:isDeadGrid(elementData,sameColor) then
                local path = self:search({elementData},searched,sameColor)
                if #path >= 3 then
                    local tArr = {}
                    for j = 1,3 do
                        tArr[j] = path[j]
                    end
                    
                    if math.abs(tArr[2].x - tArr[3].x) > 1 or math.abs(tArr[2].y - tArr[3].y) > 1 then
                        tArr[2],tArr[1] = tArr[1],tArr[2]
                    end
                    return tArr
                end
            end  
            searched[elementData] = true 
        end
    end 
    return nil
end


--[[ 全盘随机换位
    炸弹不参与换位
    非关卡编辑器设定的钻石和
]]
function AutoBubble:transposition()
    local usableList = {}
    local index = 1
    local len = #self.elementArr
    for i = 1,len do
        local elementData = self.elementArr[i]
        if elementData.block == nil and elementData.y < 8 then
            if elementData.widget ~= nil then
                if  elementData.widget.eliminate.fall == 1 then     -- 掉落的奖励可以换位
                    -- 夹子可以换位 ,29炸弹不可换位
                    if elementData.widget.pang == nil
                        and (elementData.widget.eliminate.generate  or (elementData.widget.eliminate.generate == nil and elementData.widget.eliminate.type <= 5))
                        and elementData.widget.eliminate.widgetID ~= 29 then 
                        usableList[index] = elementData
                        index = index + 1
                    end
                end
            end  
        end    
    end 
    
    -- 循环检测换位，直到有3个相连的道具
    local list = {}
    while true do
        local e = math.random(1,#usableList)
        local r = math.random(1,#usableList)
        
    	if e ~= r then
            if not table.indexof(list,usableList[e]) then
                list[#list+1] = usableList[e]
        	end
        	
            if not table.indexof(list,usableList[r]) then
                list[#list+1] = usableList[r]
            end
            
            usableList[e].widget,usableList[r].widget = usableList[r].widget,usableList[e].widget  
            if self:findPath() then
                break
            end
        end
    end
    
    return list
end


-- 判定给定的格子九宫格内是否有两个可以相连的道具
function AutoBubble:twoWidgetIn9(origial)

    for i = 1,#AutoBubble.Array9 do
        local pos = AutoBubble.Array9[i]
        local eData = self.getDataByGridXY(origial.x + pos[1],origial.y + pos[2])
        if eData ~= nil then
            if self:connectedBetweenTwo(origial,eData) then
                return true
            end
        end
    end

    return false
end

-- 全盘搜索是否有三个相同的可消除元素(不一定相连)
function AutoBubble:isThreeWidgetInAll()
    local hash = {}
    local len = #self.elementArr
    for i = 1,len do
        local elementData = self.elementArr[i]
        if elementData.y < 8 then
            if elementData.widget then
                local pang = elementData.widget.pang
                if pang == nil or pang.connect == 1 then
                    local type = elementData.widget.eliminate.type
                    if type <= 5 then
                        if hash[type] then
                            hash[type] = hash[type] + 1
                            if hash[type] >= 3 then
                                return true
                            end
                        else
                            hash[type] = 1
                        end
                    end
                end
             end
         end
    end
    return false
end

-- 搜索全部没有遮挡的指定颜色的元素
function AutoBubble:getWidgetInAllFor(_iType)
    local list = {}
    local len = #self.elementArr
    for i = 1,len do
        local elementData = self.elementArr[i]
        if self:isAlive(elementData) and elementData.widget.pang == nil and elementData.y < 8 then 
            local type = elementData.widget.eliminate.type
            if type == _iType then list[#list + 1] = elementData end
        end
    end
    return list
end

--淤泥感染周边格子
function AutoBubble:searchInfection()
    local len = #self.elementArr
    local index = 1
    local usableList = {}
    for i = 1,len do
        local elementData = self.elementArr[i]
        if elementData.block == nil and elementData.y < 8  
        and elementData.widget and elementData.widget.eliminate.widgetID == 35
        then
            for i = 1,#AutoBubble.Array4 do
                local pos = AutoBubble.Array4[i]
                local target = self.getDataByGridXY(elementData.x + pos[1],elementData.y + pos[2])
                if target and target.block == nil then
                    if AlgorithmConneted(target,elementData,self.getDataByGridXY,true,true) then
                        if target.widget and target.widget.pang == nil and (target.widget.eliminate.type <= 5 or target.widget.eliminate.widgetID == 29)then
                            if table.indexof(usableList,target) == false then
                                usableList[index] = target
                                index = index + 1
                            end
                        end
                    end
                end
            end
        end
    end 
    
    if #usableList > 0 then
        return usableList[math.random(1,#usableList)]
    end
    return nil
end

-- 烟囱吐出淤泥到周边格子
function AutoBubble:searchChimneyDrop()
    local len = #self.elementArr
    local index = 1
    local usableList = {}
    for i = 1,len do
        local elementData = self.elementArr[i]
        if elementData.block == nil and elementData.y < 8 
        and elementData.widget and elementData.widget.eliminate.widgetID == 28
        then
            for i = 1,#AutoBubble.Array9 do
                local pos = AutoBubble.Array9[i]
                local target = self.getDataByGridXY(elementData.x + pos[1],elementData.y + pos[2])
                if target and target.blcok == nil then
                    if target.widget then
                        if target.widget.pang == nil and (target.widget.eliminate.type <= 5 or target.widget.eliminate.widgetID == 29) then
                            if table.indexof(usableList,target) == false then
                                usableList[index] = {target,elementData}
                                index = index + 1
                            end
                        end
                    else
                        if table.indexof(usableList,target) == false then
                            usableList[index] = {target,elementData}
                            index = index + 1
                        end
                    end
                end
            end
        end
    end 

    if #usableList > 0 then
        local obj = usableList[math.random(1,#usableList)]
        return obj[1],obj[2]
    end
    return nil
end



-- 搜索怪物扔道具的格子,返回nil表示没有适合的位置
function AutoBubble:searchMonstetGoods()
    local usableList = {}
    local index = 1
    local len = #self.elementArr
    for i = 1,len do
        local elementData = self.elementArr[i]
        if elementData.block == nil and elementData.y < 8  
        and elementData.widget and elementData.widget.pang == nil
        and elementData.widget.eliminate.type <= 5
        then
            usableList[index] = elementData
            index = index + 1
        end
    end 
    return usableList
end

-- 搜索宠物扔技能的格子, 优先搜索上层的格子,返回nil表示没有适合的位置
function AutoBubble:searchRoleSkill()
    local usableList = {}
    local index = 1
    local len = #self.elementArr
    for i = 1,len do
        local elementData = self.elementArr[i]
        if elementData.widget and elementData.y < 8 
            and elementData.widget.pang == nil  
            and elementData.widget.skill == nil
            and elementData.widget.eliminate.widgetID <= 5 then
            usableList[index] = elementData
            index = index + 1
        end
    end 
    len = #usableList
    if len < 1 then return nil end
    for i = 1, len do
        local ran = random_range(1, len)
        if ran ~= i then
            usableList[i],usableList[ran] = usableList[ran],usableList[i]
        end
    end
    return usableList
end

-- function AutoBubble:searchPacman()
--     local len = #self.elementArr
--     local index = 1
--     for i = 1,len do
--         local elementData = self.elementArr[i]
--         if elementData.widget then
--             if elementData.widget.eliminate.widgetID == 36 then
--                 return true
--             end
--         end
--     end
--     return false      
-- end

--随机获得蝙蝠飞行目标
function AutoBubble:searchPacman( _widgets )
    local list,elements, pacmans = {}, {}, {}
    local n1,n2,n3 = 0, 0, 0
    for i,v in ipairs(self.elementArr) do
        if v.widget and v.widget.eliminate.widgetID == 36 then --蝙蝠
            local pacman = _widgets[v.widget]
            if(pacman.isNewPacman)then pacman.isNewPacman=false
            else n3=n3+1 pacmans[n3] = pacman end
        elseif v.block == nil and v.y < 8  
        and v.widget and v.widget.pang == nil
        and v.widget.eliminate.type <= 5
        then --元素
            n2=n2+1 elements[n2] = v
        end
    end

    if(n3>0)then 
       for i,v in ipairs(pacmans) do
            local len = #elements
            if(len>0)then 
                local rand = table.remove(elements, random_range(1, len))
                n1=n1+1 list[n1]={v,rand}
            else break end
       end
    end
    return #list>0 and list or nil
end

return AutoBubble
