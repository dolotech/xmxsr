-- 游戏背景层和左右两个底部一个的装饰道具

local GameBackground = class("GameBackground" ,function () return cc.Node:create() end)


function GameBackground:create(data,data2)
    local instance = GameBackground.new(data,data2)
    instance:registerScriptHandler(function(event)
        if "enter" == event then
            instance:onEnter()
        elseif "exit" == event then

        end
    end
    )
    return instance
end

function GameBackground:ctor(data,data2)
 
    self.data = data
    self.data2 = data2
end


function GameBackground:onEnter()
    local layerDatas = self.data
    local layerDatas2 = self.data2 
    local mgr = cc.Director:getInstance():getTextureCache()  
    for i = 0,#layerDatas-1 do
        local type = layerDatas[i+1]
        local x = i %Config.Element_Grid_Width
        local y =  Config.Element_Grid_Height - 1 - math.floor(i / Config.Element_Grid_Width)
        if type > 0 then
            local picture = GoodsData[tostring(type)].picture
            local sprite = cc.Sprite:createWithSpriteFrameName(Prefix.PREBATTLE_PICTURE .. picture .. PNG)
            sprite:setPosition(x * Config.Grid_MAX_Pix_Width,y * Config.Grid_MAX_Pix_Height)
            self:addChild(sprite )
        end
        if x > 8 or x < 2 or y < 1 then
            type = layerDatas2[i+1]
            if type > 0 then
                local picture = GoodsData[tostring(type)].picture
                local sprite = cc.Sprite:createWithSpriteFrameName(Prefix.PREBATTLE_PICTURE .. picture .. PNG)
                sprite:setPosition(x * Config.Grid_MAX_Pix_Width,y * Config.Grid_MAX_Pix_Height)
                self:addChild(sprite )
            end
        end
    end 
    
end

return GameBackground