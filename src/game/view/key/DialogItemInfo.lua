--[[
	显示物品的弹出框
]]

local DialogItemInfo = class("DialogItemInfo",function()
    return display.createUI("node_item_info.csb")
end)
-----------------------------------------------------------------------

--初始化设置
function DialogItemInfo:onEnter()
	local imgBg = self:getChildByName("imgBg")
	imgBg.loc = cc.p(imgBg:getPosition())
	imgBg:setVisible(false)

	--设置属性
	imgBg:getChildByName("labelName"):setString(self.param.goods.des)
	imgBg:getChildByName("labelHint"):setString(string.format(Language.Get_ItemHint, self.param.num,self.param.goods.des))

	--设置动画
	local nodeItem = imgBg:getChildByName("nodeItem")
	imgBg:getChildByName("closeButton"):onClick(
		function()
			self.param.funCloseCallBack(cc.p(nodeItem:convertToWSAR(self:getParent())))
			Audio.playSound(Sound.SOUND_UI_READY_BACK,false)
			self:close()
		end, 
	true, false)

	local endPoint = cc.p(nodeItem:convertToWS(self))
	local path = Prefix.PREBATTLE_PICTURE..self.param.goods.picture ..PNG
	local spr = cc.Sprite:createWithSpriteFrameName(path)
	self:addChild(spr)

    spr:setPosition(cc.pSub(self.param.starPoint,cc.p(stageWidth/2,stageHeight/2)))
    spr:setScale(0)
    local sequ = cc.Sequence:create(
    	cc.ScaleTo:create(0.5, 1),
    	cc.Spawn:create(cc.ScaleTo:create(0.8, 2),cc.EaseIn:create(cc.MoveTo:create(0.8,endPoint),2)),
    	cc.CallFunc:create(function()
    		self.param.maskLayer.sprite:fadeTo(0.3, 255)
    		-- imgBg:setPosition(imgBg.loc.x+100, imgBg.loc.y)
    		-- imgBg:runAction(cc.Sequence:create(
    		-- 	cc.Spawn:create(cc.MoveTo:create(0.3,imgBg.loc),cc.FadeIn:create(0.3))
    		-- ))
	    	imgBg:setVisible(true)
    		self:openAni(imgBg)
    		imgBg:getChildByName("imgLight"):runAction(cc.RepeatForever:create(cc.RotateTo:create(5,720)))
    	end)
    )
    spr:runAction(sequ)
end


-----------------------------------------------------------------------
return DialogItemInfo
	

