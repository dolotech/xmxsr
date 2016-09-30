-- 游戏战斗格子 路径

local ElementPath = class("ElementPath")


function ElementPath:create()
    local instance = ElementPath.new()
    
    instance.path = {}
    instance.index = 1
    return instance
end

--  回退
function ElementPath:isBack(data)
     if data ~= nil then
            local lashData = self.path[self.index - 2]
            if data == lashData then
               return  self:pop()
            end
      end
      return nil
end

-- 判定是否已经在队列
function ElementPath:isExist(data)
    if self.path[self.index - 1] == data then
        return true
    end
    local bool = false
    if data ~= nil then
        for k,v in pairs(self.path) do
            if v == data then
                bool = true
                break
            end
        end
    end
    return bool
end

-- 添加数据到队列
function ElementPath:push(data)
    if data ~= nil then
        self.path[self.index] = data
        self.index = self.index + 1
    end
end

-- 最后一个数据从队列中弹出
function ElementPath:pop()
    local data = self.path[self.index - 1]
    self.path[self.index - 1] = nil
    self.index = self.index - 1
    return data
end

-- 判定队列是否为空
function ElementPath:enpty()
    return self.index == 1
end

-- 获取整个队列数据
function ElementPath:getPath()
    return self.path
end

-- 清空队列
function ElementPath:clear()
    self.path = {}
    self.index = 1
end

--  获取队列最后一个元素
function ElementPath:getLastOne()
    return self.path[self.index - 1]
end


return ElementPath