--提示滚动文字

local TipsManager = class("TipsManager")


--text 文本
--color cc.c4f(0xff,0xff,0xff,0xff)
--size 大小
--onComplete 完成函数
function TipsManager:ShowText(text,color,size,onComplete)
    
    if size==nil then
    	size = 48
    end
    
    if color==nil then
        color = cc.c4f(0xff,0xff,0xff,0xff) 
    end
    
    
    local ttfConfig = {}
    ttfConfig.fontFilePath =FONT_FZZT_TTF
    ttfConfig.fontSize = size
    ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
    ttfConfig.customGlyphs = nil
    ttfConfig.distanceFieldEnabled = true
    ttfConfig.outlineSize = 2
    
    local textLable = cc.Label:createWithTTF(ttfConfig,text,cc.TEXT_ALIGNMENT_CENTER)
    textLable:setWidth(350)
    textLable:setHeight(200)
    textLable:enableShadow()
    textLable:setString(text)
    textLable:setScale(0.8)
    textLable:setTextColor(color)
    textLable:stageCenter()
    SceneManager.currentScene:addToEffectLayer(textLable)
    
    
    local function removeHandler(textLable)
        textLable:removeFromParent(true)
        if onComplete~=nil then
            onComplete()
        end
    end

    textLable:setOpacity(0) -- 开始透明度
    local x,y = textLable:getPosition()
    local moveTo1 = cc.EaseOut:create(cc.MoveTo:create(0.1,cc.p(x,y+80)),1)
    local scaleTo1 = cc.ScaleTo:create(0.1,0.9,0.9)
    local fadeTo1 = cc.FadeTo:create(0.1, 80)
    
    local moveTo2 =  cc.EaseOut:create(cc.MoveTo:create(1,cc.p(x,y+150)),1)
    local scaleTo2 = cc.ScaleTo:create(0.8,1,1)
    local fadeTo2 = cc.FadeTo:create(0.1, 255)
    
    local moveTo3 = cc.EaseOut:create(cc.MoveTo:create(0.8,cc.p(x,y+200)),1)
    local scaleTo3 = cc.ScaleTo:create(0.5,1,1)
    local fadeTo3 = cc.FadeTo:create(0.2, 0)
    
    local spa1 = cc.Spawn:create(moveTo1,scaleTo1,fadeTo1)
    local spa2 = cc.Spawn:create(moveTo2,scaleTo2,fadeTo2)
    local spa3 = cc.Spawn:create(moveTo3,scaleTo3,fadeTo3)
    
    textLable:runAction(cc.Sequence:create(spa1,spa2,spa3,cc.CallFunc:create(removeHandler)))
end


--提示sprite
--color cc.c4f(0xff,0xff,0xff,0xff)
--size 大小
--onComplete 完成函数
function TipsManager:ShowSprte(sprte,onComplete)

    sprte:stageCenter()
    SceneManager.currentScene:addToEffectLayer(sprte)

    local function removeHandler(sprte)
        sprte:removeFromParent(true)
        if onComplete~=nil then
            onComplete()
        end
    end

    local x,y = sprte:getPosition()
    local moveTo1 = cc.EaseOut:create(cc.MoveTo:create(0.1,cc.p(x,y+30)),2)
    local scaleTo1 = cc.ScaleTo:create(0.1,1,1)

    local moveTo2 = cc.EaseOut:create(cc.MoveTo:create(0.8,cc.p(x,y+170)),2)
    local scaleTo2 = cc.ScaleTo:create(0.8,1,1)

    local moveTo3 = cc.EaseOut:create(cc.MoveTo:create(0.5,cc.p(x,y+240)),2)
    local scaleTo3 = cc.ScaleTo:create(0.5,0.8,0.8)

    local spa1 = cc.Spawn:create(moveTo1,scaleTo1)
    local spa2 = cc.Spawn:create(moveTo2,scaleTo2)
    local spa3 = cc.Spawn:create(moveTo3,scaleTo3)

    sprte:runAction(cc.Sequence:create(spa1,spa2,spa3,cc.CallFunc:create(removeHandler)))
end


return TipsManager