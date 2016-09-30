-- 爆炸技能周边触发算法
local AlgorithmSkill = class("AlgorithmSkill")
local Array9 = {{-1,1},{0,1},{1,1},{1,0},{1,-1},{0,-1},{-1,-1},{-1,0}}
local hArray = {{1,0},{-1,0}}
local vArray = {{0,1},{0,-1}}
     
function AlgorithmSkill:create(widgets,getDataByGridXY)
    local instance = AlgorithmSkill.new(widgets,getDataByGridXY)
    instance.getDataByGridXY = getDataByGridXY
    instance.widgets = widgets
    instance.bombPath = {}
    return instance
end

-- 
-- 消除所以爆破技能鼠标跟随和横纵向技能的转换
function AlgorithmSkill:clearAllConver()
    for i=1,#self.bombPath do
        local bomb = self.bombPath[i]
        if bomb.widget then 
            if bomb.widget.orginalSkillEliminate then
                bomb.widget.eliminate = bomb.widget.orginalSkillEliminate
                bomb.widget.orginalSkillEliminate = nil
            end
    
            if bomb.widget.orginalSkillType > 0 then
                bomb.widget.skill.type = bomb.widget.orginalSkillType
                bomb.widget.orginalSkillType =0
            end
        end
        
        local replace = bomb.replace
        if replace then
            if replace.widget then
                replace.widget.skill,bomb.widget.skill = bomb.widget.skill,replace.widget.skill
                replace.widget.eliminate,bomb.widget.eliminate = bomb.widget.eliminate,replace.widget.eliminate
            end
            bomb.replace = nil
        end
    end
end

--[[ 爆炸技能计算
 pathArr --当前连线路径
 _bool 技能位置变化 true 不变技能位置
]]
function AlgorithmSkill:bombAlgorithm( pathArr, _bool )
    self:clearAllConver()   -- 重置爆破所有标识
    local elementData = pathArr[#pathArr]
    -- 爆炸
    local skillDataArr = {}
    for i = #pathArr,1,-1 do
        local elementData = pathArr[i]
        local skill = elementData.widget.skill
        if skill ~= nil and skill.type ~= 2 then --除了转换技能外
            skillDataArr[#skillDataArr +1] = elementData
        end
    end       
    
    local path = {}
    if #skillDataArr > 0 then-- 替换路径上已有的技能（技能道具跟随鼠标移动）
        self.bombPath = path
        local lastSkillElementData = skillDataArr[1]
        -- 元素最后一个不为技能
        if not _bool and lastSkillElementData ~= elementData then
            elementData.widget.skill,lastSkillElementData.widget.skill = lastSkillElementData.widget.skill,elementData.widget.skill
            elementData.widget.eliminate,lastSkillElementData.widget.eliminate = lastSkillElementData.widget.eliminate,elementData.widget.eliminate
            elementData.replace = lastSkillElementData--用于取消用
        end
        
        -- 计算爆炸触及范围
        for i = #pathArr,1,-1 do
            local elementData = pathArr[i]
            local skillData = elementData.widget.skill
            if skillData then
                -- 已经在爆破队列的格子避免重复添加
                if not table.indexof(path,elementData) then
                    path[#path+1] = elementData
                end
                self:bomb(skillData,elementData,path)
            end
        end
    end
    return path
end

function AlgorithmSkill:bomb(skillData,elementData,path)
    self:hbomb(skillData,elementData,path)
    self:vbomb(skillData,elementData,path)
    self:rangeBomb(skillData,elementData,path)
end

--  1：范围爆炸
function AlgorithmSkill:rangeBomb(skillData,elementData,path) 
    if skillData.type == 1 then
        if skillData.power > 0 then
            local powerRadius = math.sqrt(skillData.power)
            local radiusIndex = math.ceil(powerRadius)
            for i = 1,#Array9 do
                for k = 1,radiusIndex do
                    for m = 1,radiusIndex do
                        local pos = Array9[i]
                        local gapx = pos[1] * k
                        local gapy = pos[2] * m

                        local dist = gapx * gapx + gapy * gapy

                        local targetElementData = self.getDataByGridXY(gapx +elementData.x,gapy + elementData.y)
                        if targetElementData and targetElementData.y < 8 then
                            if dist <= skillData.power then
                                if not table.indexof(path,targetElementData) then
                                    path[#path+1] = targetElementData
                                    if targetElementData.widget ~= nil and targetElementData.widget.pang == nil  and targetElementData.widget.skill ~= nil then
                                        self:bomb(targetElementData.widget.skill,targetElementData,path)
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

--    3.横向爆炸
function AlgorithmSkill:hbomb(skillData,elementData,path)
    if skillData.type ~= 3 or skillData.power < 1 then return end
    local powerRadius = math.sqrt(skillData.power)
    local radiusIndex = math.ceil(powerRadius)
    for i = 1,#hArray do
        for k = 1,radiusIndex do
            local pos = hArray[i]
            local gapx = pos[1] * k
            local dist = gapx * gapx
            local targetElementData = self.getDataByGridXY(gapx +elementData.x,elementData.y)
            if targetElementData and  targetElementData.y < 8 
            and dist <= skillData.power and  not table.indexof(path,targetElementData)
            then
                path[#path+1] = targetElementData
                --爆炸范围里有元素为技能时
                if targetElementData.widget ~= nil and targetElementData.widget.pang == nil and targetElementData.widget.skill ~= nil then
                    if targetElementData.widget.skill.type == 3 then
                        targetElementData.widget.orginalSkillEliminate = targetElementData.widget.eliminate
                        targetElementData.widget.orginalSkillType = targetElementData.widget.skill.type
                        
                        local c = clone(GoodsData[tostring(targetElementData.widget.eliminate.bombConver)])
                        targetElementData.widget.eliminate = c
                        
                        -- targetElementData.widget.skill = clone(skillData)
                        targetElementData.widget.skill.type = 4
                    end
                    self:bomb(targetElementData.widget.skill,targetElementData,path)
                end
            end
        end
    end
end

--  4.纵向爆炸
function AlgorithmSkill:vbomb(skillData,elementData,path)
    if skillData.type == 4 then
        if skillData.power > 0 then
            local powerRadius = math.sqrt(skillData.power)
            local radiusIndex = math.ceil(powerRadius)
            for i = 1,#vArray do
                for m = 1,radiusIndex do
                    local pos = vArray[i]
                    local gapy = pos[2] * m
                    local dist = gapy * gapy
                    local targetElementData = self.getDataByGridXY(elementData.x,gapy + elementData.y)
                    if targetElementData and  targetElementData.y < 8 then
                        if dist <= skillData.power then
                            if not table.indexof(path,targetElementData) then
                                path[#path+1] = targetElementData
                                if targetElementData.widget ~= nil and targetElementData.widget.pang == nil  and targetElementData.widget.skill ~= nil then
                                    if targetElementData.widget.skill.type == 4 then
                                    
                                        targetElementData.widget.orginalSkillEliminate = targetElementData.widget.eliminate
                                        targetElementData.widget.orginalSkillType = targetElementData.widget.skill.type
                                        
                                        local c = clone(GoodsData[tostring(targetElementData.widget.eliminate.bombConver)])
                                        targetElementData.widget.eliminate = c
                                        
--                                        targetElementData.widget.skill = clone(skillData)
                                        targetElementData.widget.skill.type = 3
                                    end
                                    self:bomb(targetElementData.widget.skill,targetElementData,path)
                                end
                            end
                        end
                    end
                end
            end
        end
    end 
end

return AlgorithmSkill