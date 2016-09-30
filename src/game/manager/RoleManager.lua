
-- 角色显示对象管理器

local RoleManager = class("RoleManager")
RoleManager.hash = {}

--创建显示角色
function RoleManager.createRole(id)
    if not RoleManager.hasCacheRoleByID(id) then
        local role = Role:create(RoleDataManager.getRoleDataByID(id))
        RoleManager.hash[tostring(id)] = role
    end
end

--获取自己宠物类型列表type 1,2..5
function RoleManager:getPetsBuyType(type)
    local pets = {}
    local table = SharedManager:readData("pet" .. tostring(type))
    for key, var in pairs(table) do
        local role = RoleManager.getRoleByID(var)
        pets[var] = role
    end
    return pets
end

--通过角色id获取显示对象
function RoleManager.getRoleByID(Id)
    return RoleManager.hash[tostring(Id)]
end

--是否缓存有宠物
function RoleManager.hasCacheRoleByID(id)
    if RoleManager.hash[tostring(id)] then
        return true
    end
    return false
end

return RoleManager