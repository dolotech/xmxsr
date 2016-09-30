-- 开宝箱奖励掉落演算

local DropDataCtrl = class("DropDataCtrl")
DropDataCtrl.__index = DropDataCtrl

--获取一条掉落数据point=1001...,timesTable={id,times}
function DropDataCtrl:getPointDropData(point,timesTable)
    local scopeType = 0
    for key, var in pairs(DropTypeData) do
        local pointTable= var.point
        if point>=pointTable.a and point<pointTable.b then
            scopeType = var.scopeType
    		break
    	end
    end

    --计算总共重权
    local totalWeight = 0
	local pointData = {}
    for key, var in pairs(DropData) do --当前关卡掉落
        if var.scopeType==scopeType then --掉落类型范围相同
            if self:excessDropData(var)==false then
                if self:timesDropData(key,var.times,timesTable)==false then
                    local data = clone(var)
                    pointData[#pointData+1] = data
                    data.id = key
                    totalWeight = totalWeight + data.weight
                end
            end
		end
	end
	
	if #pointData  == 0 then
        TipsManager:ShowText(Language.List_is_Null)
	   return {}
	end
	
    --产生掉落地段
    local random =  math.random(1,totalWeight)
    --计算掉落地段
	local dropData = nil
     --重权计算
    local count = 0
    for i=1,#pointData do
        local data = pointData[i]
        count = count + data.weight
        if random <= count then
            dropData = data
            break
        end
    end
    
    return dropData
end

--判断是否资源过剩
function DropDataCtrl:excessDropData(dropData)
    local bool = false
    if dropData.rwardType==1 then--道具类型
        if dropData.excess>0 then
            if dropData.type==Config.YELLOW_ID1 or dropData.type==Config.YELLOW_ID2 or dropData.type==Config.YELLOW_ID3 then --黄色元素小中大
                if SharedManager:readData(Config.YELLOW)>=dropData.excess then
                    bool = true
                end
            elseif dropData.type==Config.BULE_ID1 or dropData.type==Config.BULE_ID2 or dropData.type==Config.BULE_ID3 then --蓝色元素小中大
                if SharedManager:readData(Config.BLUE)>=dropData.excess then
                    bool = true
                end
            elseif dropData.type==Config.DIANMOND_ID2 or dropData.type==Config.DIANMOND_ID3 then --钻石 ，打包钻石
                if SharedManager:readData(Config.DIAMOND)>=dropData.excess then
                    bool = true
                end
            elseif dropData.type==Config.POWER_ID then --体力
                if SharedManager:readData(Config.POWER)>=dropData.excess then
                    bool = true
                end
            elseif dropData.type==Config.POWER_LIMIT_ID then --体力上限
                if SharedManager:readData(Config.LIMITPOWER)>=dropData.excess then
                    bool = true
                end
            end
        end
    elseif dropData.rwardType==2 then --角色类型
    	local roleData = RoleData[tostring(dropData.type)]
    	--获取当前颜色品种的宠物
    	local pets = RoleDataManager.getPetsDataBuyType(roleData.type)
        local petArr = {}
        if pets~=nil then
            for key, var in pairs(pets) do
                --是否同一个站位
                if var.sort == roleData.sort then
                    petArr[#petArr + 1] = var
                end
            end
    	end
    	--判断资源过剩
         if #petArr>=dropData.excess then
            bool = true
        end
    end
    return bool
end

--判断是否超出次数
function DropDataCtrl:timesDropData(id,times,timesTable)
   if timesTable~=nil then --有记录次数表
       local tab = nil
       local roleTimes = 0
       local dropData = DropData[tostring(id)]
       for i, t in pairs(timesTable) do --找出相同id
           if id == t.id then
                tab = t
           end
       end
       if tab~=nil then --判断资源次数
            if tab.times>=times then
                return true
           end
       end
    end
    return false
end

--购买钥匙价格
function DropDataCtrl:getBuyDianomd(point)
    for key, var in pairs(DropTypeData) do
        local pointTable= var.point
        if point>=pointTable.a and point<pointTable.b then
            return  var.diamond
        end
    end
    return 25
end



return DropDataCtrl