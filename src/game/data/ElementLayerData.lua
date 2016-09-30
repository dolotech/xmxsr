--游戏战斗层数据
local ElementLayerData = class("ElementLayerData")
local AutoBubble  = require("game.view.battle.algorithm.AutoBubble")
local WidgetData = require("game.data.WidgetData")
local ElementData = require("game.data.ElementData")
local Element = require("game.view.battle.Element")
local SkillData = require("game.data.SkillData")

function ElementLayerData:create(tollgateData)
    local instance = ElementLayerData.new(tollgateData)
    return instance
end
function ElementLayerData:generateGoodsData()
    local totalProbability = 0
    local generateArr = {}
        
    local j = 1
    for i=1,#self.generateArr do
        local generateData = self.generateArr[i]

        if generateData.minCondition > 0 or generateData.maxCondition > 0 then
            if #self.data > 0 then
                local countOnDesk = 0
                for k,elementData in pairs(self.data) do
                    if elementData.widget then
                        if tonumber(elementData.widget.eliminate.id) == tonumber(generateData.widgetID) then
                            countOnDesk = countOnDesk +1
                        end
                    end
                end
               
                if generateData.minCondition > 0 and countOnDesk < generateData.minCondition then 
                    local type = tostring(generateData.widgetID)
                    local goodsData = clone(GoodsData[type])
                    goodsData.id = type
                    return  goodsData
                end
                if generateData.maxCondition == 0 or countOnDesk < generateData.maxCondition then 
                    generateArr[j] = generateData
                    totalProbability = totalProbability + generateData.probability
                    j = j +1
                end 
             end
        else
            generateArr[j] = generateData
            totalProbability = totalProbability + generateData.probability
            j = j +1
        end  
    end
    
    local random = math.random(1,totalProbability)
    
    --重权计算
    local widgetGenerateData = nil
    local count = 0
    for i=1,#generateArr do
        local data = generateArr[i]
        count = count + data.probability
        if random <= count then
            widgetGenerateData = data
            break
        end
    end

    local type = tostring(widgetGenerateData.widgetID)
    local goodsData = clone(GoodsData[type])
    goodsData.id = type
    -- 用于标识该道具为游戏过中生成包括问号道具生成，而不是关卡编辑器设定
    goodsData.generate = true
    return  goodsData
end

function ElementLayerData:ctor(tollgateData)
    local mapData = require("game.map." .. tollgateData.mapID)
    self.tollgateData = tollgateData --关卡数据
    self.tollgateData.scoreVar = 0 --关卡分数
    self.generateArr = {} --
    self.totalProbability = 0 --总概率?
   local index = 1
   for k,v in pairs(WidgetGenerate) do
        if v.type == tollgateData.generate then
            self.generateArr[index] = clone(v)--每个元素的概率表
            index = index + 1
            self.totalProbability = self.totalProbability + v.probability
            
        end
   end

    ----元素数据表
    local gameElementDataList = {}
    self.data = gameElementDataList
    local layers = mapData.layers
    local LAYER_NAMBER = 2      -- 第一层为游戏背景，第二层开始为游戏元素
    local data = layers[LAYER_NAMBER].data
    self.firstLine = {}
        
    -- 解析新手引导数据
     self.guide = {}
    -- if layers[2].properties then
        for name,v in pairs(layers[2].properties) do
            local guide = {}
            self.guide[tonumber(string.gmatch(name,"%d+")())] = guide
            for k in string.gmatch(v,"%d+") do
                local x = (k-1) %Config.Element_Grid_Width
                local y =Config.Element_Grid_Height - 1 - math.floor((k-1) / Config.Element_Grid_Width)
                guide[#guide+1] = {["x"] = x,["y"] = y}
            end
        end
    -- dump(self.guide)

    local ranArr = {}
    -- 根据关卡编辑器，重现关卡显示
    local index = 1
    for i = 0 ,#data-1 do
        local x =i %Config.Element_Grid_Width
       
        local y =Config.Element_Grid_Height - 1 - math.floor(i / Config.Element_Grid_Width)
        
        if x > 1 and x < 9 and y > 0 then
            local elementData =  ElementData:create()
            elementData.x = x
            elementData.y =  y
            -- 保证遍历棋盘的时候能从底部遍历
            elementData.id = #data - index
--        1 - 5: 是基础消除道具
--        6：横向格挡
--        7：纵向格挡
--        8：可以被触发的道具
--        9：附着物
--        10：障碍物（占用元素格不可被清除）
--        11:未知元素 ,由关卡表概率解决
            ----------元素层生成
            local typeValue = layers[2].data[i+1]
            if typeValue > 0 then
                local goodsData = self:getGoods(typeValue)
                -- 随机产生元素
                if goodsData.type == 11 then
                    -- goodsData = self:generateGoodsData()
                    ranArr[#ranArr + 1] = elementData
                end
                if goodsData.type == 10 then
                    elementData.block = goodsData
                else
                    local widgetData = WidgetData:create()
                    elementData.widget = widgetData 
                    widgetData.eliminate = goodsData
                    widgetData.x = x
                    widgetData.y = y         
                    widgetData.element = elementData
                
                    -- 技能判定
                    if goodsData.skill > 0 then
                    local skillData = clone(SkillData[tostring(goodsData.skill)])
                        widgetData.skill = skillData
                    end
                    
                    -- 添加附着物
                    typeValue = layers[5].data[i+1]
                    if(typeValue > 0) then
                        goodsData = self:getGoods(typeValue)
                        if goodsData.type == 9 then
                            widgetData.pang = goodsData
                        end
                    end
                end   
            end
            
            -- 横挡板
            local typeValue = layers[3].data[i+1]
            if typeValue > 0 then
            local goodsData = self:getGoods(typeValue)
                if goodsData.type == 6 then
                    elementData.hBlock = goodsData
                end
                
            end
            -- 纵挡板
            local typeValue = layers[4].data[i+1]
            if typeValue > 0 then
            local goodsData = self:getGoods(typeValue)
                if goodsData.type ==7 then
                    elementData.vBlock = goodsData
                end
            end
            
            -- 构建每个格子可点击矩形范围
        elementData.startPoint.x = Config.Grid_MAX_Pix_Width * x + 12
        elementData.startPoint.y= Config.Grid_MAX_Pix_Height * y + 10
        
        elementData.endPoint.x= Config.Grid_MAX_Pix_Width *( x +1) - 12
        elementData.endPoint.y= Config.Grid_MAX_Pix_Height * (y +1)- 10
            gameElementDataList[index] = elementData
        if elementData.y == 8 then
            self.firstLine[elementData.id] = elementData   
        end  
        index = index +1
        end
    end 

    if #ranArr > 0 then
        for i=1,#ranArr do
           local elementData =  ranArr[i]
            local widgetData = elementData.widget
            local goodsData = self:generateGoodsData()
            widgetData.eliminate = goodsData
        end
    end
    -- goodsData = self:generateGoodsData()
                    -- ranArr[#ranArr + 1] = elementData
end

-- 智能生成道具
function ElementLayerData:generateForFirstLine()
    self.generateElementDatas = {}
    for k,elementData in pairs(self.firstLine) do
        if elementData.widget == nil and elementData.hBlock == nil and elementData.block == nil  then
            local down = self:getDataByGridXY(elementData.x,elementData.y-1)
            if down.widget == nil and down.block == nil then
                local widgetData = WidgetData:create()
                local goodsData = self:generateGoodsData()
                elementData.widget = widgetData 
                widgetData.eliminate = goodsData
                widgetData.x = elementData.x
                widgetData.y = elementData.y
                widgetData.element = elementData
                self.generateElementDatas[elementData.id] = elementData
            end
        end
    end
end

--  根据触摸点xy位置获取，棋盘上的格子显示对象 
function ElementLayerData:getElementByXY(layer,x,y)
    local selfX,selfY = layer:getPosition()
    x = x - selfX
    y = y - selfY
    x = (Config.Grid_MAX_Pix_Width/2 + x)
    y = (Config.Grid_MAX_Pix_Height/2 + y)
    local gridX = math.floor(x/Config.Grid_MAX_Pix_Width)
    local gridY = math.floor(y/Config.Grid_MAX_Pix_Height)
    local elementData = self:getDataByGridXY(gridX,gridY)
    if elementData~= nil then
        if x < elementData.startPoint.x or  y < elementData.startPoint.y or  x > elementData.endPoint.x or  y > elementData.endPoint.y then
            return nil
        end   
    end 
    return elementData
end

function ElementLayerData:getGoods(type)
    local goodsData = clone(GoodsData[tostring(type)])
    goodsData.id = type
    if goodsData == nil then
        printError("道具表内，不存在物品: " ,type)
    end
    return goodsData
end

function ElementLayerData:getDataByGridXY(x,y)
    if x > 8 or x < 2 or y < 1 or y > 8 then
        return nil
    end 
    
    local gridX = x - 2 
    local gridY = 7 - (y - 1)
   
    
    local id = gridY * 7 + gridX + 1
    return self.data[id]
end
return ElementLayerData