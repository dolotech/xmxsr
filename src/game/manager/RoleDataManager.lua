-- 角色数据管理器

local RoleDataManager = class("RoleDataManager")
RoleDataManager.hash = {}

--创建角色宠物数据信息(基本在进入游戏时已经创建)
function RoleDataManager.createRoleData(id,type,embattle)
    local roleData = clone(RoleData[tostring(id)])
    roleData.type = type
    roleData.embattle = embattle
    RoleDataManager.hash[tostring(id)] = roleData
end

--获取宠物数据
function RoleDataManager.getRoleDataByID(id)
    return RoleDataManager.hash[tostring(id)]
end


--获取自己宠物类型列表数据type 1,2..5
function RoleDataManager.getPetsDataBuyType(type)
    local pets = nil
    local petTable = SharedManager:readData("pet" .. tostring(type))
    if table.nums(petTable)>0 then
        pets = {}
        for key, var in pairs(petTable) do
            local role = RoleDataManager.getRoleDataByID(var.id)
            role.embattle = var.embattle
            pets[var.id] = role
        end
    end
    return pets
end

--获取宠物升级状况 能升级的宠物出现标志
function RoleDataManager.getPetTrainState()
    local tPets,tCount = {},{0,0,0,0,0}
    local yellow = SharedManager:readData(Config.YELLOW)
    local blue = SharedManager:readData(Config.BLUE)

    for i=1,Config.DATA_PETTYPE_COUNT do
        local petTable = SharedManager:readData("pet" .. tostring(i))
        for key, var in pairs(petTable) do
            local role = RoleData[tostring(var.id)]
            local bool = (yellow >= role.yellow and blue >= role.blue)
            tPets[var.id] = bool
            if(bool)then tCount[i] = tCount[i] + 1 end
        end
    end
    return tPets,tCount
end
--宠物是否达到升级条件
function RoleDataManager.isPetTrainState(_idx)
    local yellow = SharedManager:readData(Config.YELLOW)
    local blue = SharedManager:readData(Config.BLUE)
    local role = RoleData[tostring(_idx)]
    return (yellow >= role.yellow and blue >= role.blue)
end

--改变宠物布阵状态id,embattle是否上阵flush立刻刷新本地缓存
function RoleDataManager.savePetEmbattle(id,type,embattle,flush)
    
    --修改当前缓存
    local roles =  RoleDataManager.getPetsDataBuyType(type)
    for key, var in pairs(roles) do
        if key==id then
            var.embattle = embattle
    	else
            var.embattle = not embattle
    	end
    end
    
    
    --修改本地存储
    local table = SharedManager:readData("pet" .. tostring(type))
    for key, var in pairs(table) do
        if var.id==id then
           var.embattle = embattle
        else
            var.embattle = not embattle
        end
    end
    SharedManager:saveData("pet" .. tostring(type),table,flush)
end

--是否缓存有宠物数据
function RoleDataManager.hasCacheRoleDataByID(id)
    if RoleDataManager.hash[tostring(id)] then
    	return true
    end
    return false
end

--升级宠物
function RoleDataManager.upgrade(type,petid,upgradeId)
    --修改当前缓存
    local roles =  RoleDataManager.getPetsDataBuyType(type)
    for key, var in pairs(roles) do
        if key==petid then
            RoleDataManager.hash[tostring(key)] = nil
            local roleData = clone(RoleData[tostring(upgradeId)])
            roleData.type = type
            roleData.embattle = var.embattle
            RoleDataManager.hash[tostring(upgradeId)] =roleData
        end
    end

    --修改本地存储
    local table = SharedManager:readData("pet" .. tostring(type))
    for key, var in pairs(table) do
        if var.id==petid then
            var.id = upgradeId
        end
    end
    SharedManager:saveData("pet" .. tostring(type),table,true)

end

--添加宠物角色
function RoleDataManager.addRole(id)
    --修改当前缓存
    local roleData = clone(RoleData[tostring(id)])
    RoleDataManager.hash[tostring(id)] = roleData
    --修改本地存储
    local table = SharedManager:readData("pet" .. tostring(roleData.type))
    local index = 0
    if table~=nil then
        for key, var in pairs(table) do
            index = index+1
        end
    else
        table = {}
    end
    if index==0 then
        roleData.embattle = true
    end
    table[tostring(index+1)] = {type=roleData.type,id = id,embattle = roleData.embattle}
    SharedManager:saveData("pet" .. tostring(roleData.type),table,true)
end

--宠物关卡解锁
function RoleDataManager:getRoleCondition(condition)
    if not condition then
        return true
    end
    local num = 0
    for key, var in pairs(RoleDataManager.hash) do
        if var.level>= condition[2] then
            num = num +1
            if num >= condition[1] then
                return true
            end
        end
	end
    return false
end

return RoleDataManager


