-- 物品显示对象

local StarEvaluation = class("StarEvaluation",function(data)
    return cc.Node:create()
end)

function StarEvaluation:create(star)
    local instance = StarEvaluation.new(star)
    return instance
end

function StarEvaluation:ctor(star)
    self.star = star
end

function StarEvaluation:setStar(star)
    self.star = star
    local starEff = nil
    for i=1, 3, 1 do
        if i<=self.star then
            starEff = display.createEffect(Prefix.PREOPE_COMPLETE_NAME,"effect_complete_03",nil,false,false)
        else
            starEff = display.createEffect(Prefix.PREOPE_COMPLETE_NAME,"effect_complete_01",nil,false,false)
        end
        starEff:setName("star" .. i)
        local y = 250
        if i==1 or i==3 then
            y = y-10
        end
        starEff:setPosition(220+(i-1)*135,y)
        self:addChild(starEff)
    end
end


--播放星级效果
function StarEvaluation:playStar(star,complete)
    self.star = star
    
    local starEff = nil
    for i=1, 3, 1 do
        if i<=self.star then
            starEff = display.createEffect(Prefix.PREOPE_COMPLETE_NAME,"effect_complete_02",nil,false,false)
        else
            starEff = display.createEffect(Prefix.PREOPE_COMPLETE_NAME,"effect_complete_01",nil,false,false)
        end
        starEff:setName("star" .. i)
        local y = 125
        if i==1 or i==3 then
            y = y-20
        end
        starEff:setPosition((i-1)*160,y)
        self:addChild(starEff)
    end
    
end

return StarEvaluation