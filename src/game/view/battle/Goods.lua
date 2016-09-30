-- 物品显示对象

local Goods = class("Goods",function(data)
    return cc.Sprite:createWithSpriteFrameName(Prefix.PREBATTLE_PICTURE .. data.picture .. PNG)
end)


function Goods:create(data)
    local instance = Goods.new(data)
    instance.lightState = false
    return instance
end

function Goods:ctor(data)
    self.data = data
end

-- 重置数据
function Goods:reset(data)
    if data.picture == self.data.picture then return end
    self.data = data
    self.lightState = false
    local picturName = Prefix.PREBATTLE_PICTURE .. self.data.picture .. PNG
    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(picturName)
    self:setSpriteFrame(frame)
end

-- 高亮
function Goods:light()
    if not self.lightState then
        if self.data.pictureLight ~= nil and self.data.pictureLight ~= "" then
            local picturName = Prefix.PREBATTLE_PICTURE .. self.data.pictureLight .. PNG
            local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(picturName)
            self.lightState = true
            self:setSpriteFrame(frame)
        end
    end
end

-- 回复非高亮状态
function Goods:unLight()
    if self.lightState then
        local picturName = Prefix.PREBATTLE_PICTURE .. self.data.picture .. PNG
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(picturName)
        self.lightState = false
        self:setSpriteFrame(frame)
    end
end

return Goods
