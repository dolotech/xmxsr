-- 2维向量

local Vector2D = class("Vector2D")

-- 构造函数
function Vector2D:ctor(x,y)
    self.x = x
    self.y = y
end

 
--位置归零
function Vector2D:zero()
    self.x=0
    self.y=0
    return self
end

--是否在零位置
function Vector2D:isZero()
    return self.x==0  and self.y==0
end

--获得向量的角度
function Vector2D:getAngle()
    return math.atan2(self.y,self.x)
end
 
--设置向量的模(即大小)
function Vector2D:setLength(value)
    local a = self:getAngle()
    self.x=math.cos(a)*value
    self.y=math.sin(a)*value
end
 
--获取向量大小的平方
function Vector2D:getLengthSQ()
    return self.x*self.x+self.y*self.y
end

--获取向量的模(即大小)
function Vector2D:getLength()
    return math.sqrt(self:getLengthSQ())
end
 
--设置向量的角度
function Vector2D:setAngle(value)
    local len=self:getLength()
    self.x=math.cos(value)*len
    self.y=math.sin(value)*len
end   

 
--截断向量(设置向量模最大值)
function Vector2D:truncate(max)
    self:setLength(math.min(max,self:getLength()))
    return self
end

--交换x,y坐标
function Vector2D:reverse()
    self.x= - self.x
    self.y= - self.y
    return self
end
 
 
--定义二个向量的加法运算
function Vector2D:add(v2)
    return Vector2D.new(self.x+v2.x,self.y+v2.y)
end

--定义二个向量的减法运算
function Vector2D:subtract(v2) 
    return Vector2D.new(self.x-v2.x,self.y-v2.y)
end

--向量模的乘法运算
function Vector2D:multiply(value)
    return Vector2D.new(self.x*value,self.y*value)
end

--向量模的除法运算
function Vector2D:divide(value)
    return Vector2D.new(self.x/value,self.y/value)
end

--判定二个向量(坐标)是否相等
function Vector2D:equals(v2)
    return self.x==v2.x and self.y==v2.y
end


--单位化向量(即设置向量的模为1，不过这里用了一种更有效率的除法运算，从而避免了lengh=1带来的三角函数运算)
function Vector2D:normalize()
    if self:getLength()==0 then
        self.x=1
        return self
    end
    --建议大家画一个基本的3,4,5勾股定理的直角三角形即可明白下面的代码
    local len=self:getLength()
    self.x = self.x/ len
    self.y = self.y/len
    return self
end       

--判定向量是否为单位向量
function Vector2D:isNormalized() 
    return self:getLength()==1.0
end

--点乘(即向量的点积)
function Vector2D:dotProd(v2)
    return self.x*v2.x+self.y*v2.y
end

--叉乘(即向量的矢量积)
function Vector2D:crossProd(v2)
    return self.x*v2.y-self.y*v2.x
end
 
--返回二个向量之间的夹角
 function Vector2D.angleBetween(v1,v2)
    if not v1:isNormalized() then
        v1 = clone(v1)
        v1=v1:normalize()
    end
    if not v2.isNormalized() then
        v2 = clone(v2)
        v2=v2:normalize()
    end
    return math.acos(v1:dotProd(v2))--建议先回顾一下到夹角公式
end

--判定给定的向量是否在本向量的左侧或右侧，左侧返回-1，右侧返回1
function Vector2D:sign(v2)
    if self:getPerp():dotProd(v2) then
        return -1
    else 
        return 1
    end
end

--返回与本向量垂直的向量(即自身顺时针旋转90度，得到一个新向量)
function Vector2D:getPerp()
    return Vector2D.new(-self.y,self.x)--建议回顾一下"坐标旋转"
end
 
 
--返回二个矢量末端顶点之间的距离平方
function Vector2D:distSQ(v2)
    local dx=v2.x-self.x
    local dy=v2.y-self.y
    return dx*dx+dy*dy
end
 
--返回二个矢量末端顶点之间的距离
function Vector2D.dist(v2)
    return math.sqrt(v2:distSQ())
end

return Vector2D