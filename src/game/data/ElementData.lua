-- 游戏战斗格子数据
local ElementData = class("ElementData")

--1 - 5: 是基础消除道具
--6：横向格挡
--7：纵向格挡
--8：可以被触发的道具
--10：障碍物（占用元素格不可被清除）

ElementData.VBlock = 7
ElementData.HBlock = 6

ElementData.Connect = 1
ElementData.Deconnect = 2

function ElementData:create()
    local instance = ElementData.new()
    --    instance.avatar = ""     -- 纹理名字 比如：xxx.png
    instance.x = 0           -- 列  下标从0开始
    instance.y = 0           -- 行 下标从0开始
--    instance.elementArr = {}
    instance.vBlock = nil           --纵向格挡
    instance.hBlock = nil           -- 横向格挡
    instance.block = nil            -- 障碍物（占用元素格不可被清除）
    instance.widget = nil
    instance.startPoint = cc.p(0,0)
    instance.endPoint = cc.p(0,0)
    instance.id = 0
    instance.skillTriggle = nil     -- 转换技能促发的列表
    
    instance.replace = nil

    
    return instance
end


function ElementData:isVBlock()
    return self.vBlock ~= nil
end 

function ElementData:isHBlock()
    return self.hBlock ~= nil
end

function ElementData:ctor()

end

function ElementData:offSetPoint()
    local p = cc.p(0,0)
    if self.widget then     
        local width = Config.Element_Grid_Width * Config.Grid_MAX_Pix_Width
        local height = Config.Element_Grid_Height * Config.Grid_MAX_Pix_Height
        p.x = self.x*Config.Grid_MAX_Pix_Width + (stageWidth-width +Config.Grid_MAX_Pix_Width) * 0.5 
        p.y = self.y*Config.Grid_MAX_Pix_Height -Config.Grid_MAX_Pix_Height * 0.3 + Config.BATTLE_SCENE_OFFSET_HEIGHT
    end
   return p
end

-- 消除
--function ElementData:eliminate()
--    self.widget = nil
--end
  

return ElementData