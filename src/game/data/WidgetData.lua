-- 游戏战斗道具数据
local WidgetData = class("WidgetData")

function WidgetData:create()
    local instance = WidgetData.new()
    instance.eliminate = nil            -- 消除道具对象
    instance.orginal = nil              -- 原始消除道具对象(用于被技能转换后再转回来)
    instance.pang = nil                 -- 附着物道具对象
    instance.skill = nil                -- 如果该道具是技能，这个对象就是技能数据对象
    instance.x = 0
    instance.y = 0
    instance.element = nil
    
    instance.orginalSkillType = 0
    instance.orginalSkillEliminate = nil
    
    --    {{id=1000,count=20},{id=114,count=21}}
    instance.rewards = nil
    
    return instance
end


function WidgetData:ctor()
    
end


return WidgetData