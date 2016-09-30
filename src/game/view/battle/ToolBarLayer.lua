-- 
-- Author: dmi
-- Date: 2015-03-30 10:03:04
-- 战斗工具条 1刷子 2同色消除 3炸弹 4彩虹珠（连接任意颜色）

local ToolBarLayer = class("ToolBarLayer", function() 
		return display.createUI(Csbs.NODE_BATTLE_TOOL_CSB)
	end)
-------------------------------------------------------------------------------------
-- function ToolBarLayer:create( _tollgate )
--     local layer = ToolBarLayer.new(_tollgate)
--     return layer
-- end
--构建函数
function ToolBarLayer:ctor( _tollgate )
	self.icoMove = nil
	self.itemIdx = 0
	self.btnLast = nil
	self.tollgate = _tollgate
	self.autoBubble = nil
	local function setIcoMove( sender, index )
		local label = sender:getChildByName("Text")
		if(label:getTag() < 1)then 
			self:openBuyItem(sender, index)
			self:cancelItem() 
			return
		end
		if(self.btnLast==sender)then 
			self:cancelItem() 
			return 
		end

		self:cancelItem()
		self.btnLast = sender
		if(index==nil or index<1)then return end
		Global.touchStateTool = 1
		Global.touchStateToolUse = 2
		local data = GoodsData[tostring(index)]
		self.icoMove = Goods:create(data)
		self.icoMove:light()
		self:addChild(self.icoMove)
		self.itemIdx = index
		-- local loc = self:convertToNodeSpace(cc.p(sender:getPosition()))
		self.icoMove:setPosition(sender:getPosition())
		tween.RepeatScale(self.icoMove, 0.5, 1.1, 1)
		self:openHint(Language[string.format("ToolItem%d", index)], sender)
	end

    local curPoint = SharedManager:readData(Config.POINT)
    local tollNum = 1004
    if(curPoint < tollNum)then self:setVisible(false) end

	local items = SharedManager:readData(Config.Storage)
	--刷子
	local btn = self:getChildByName("item1")
	local label = btn:getChildByName("Text")
	self:setItemLabel(label, ItemIndex.Brush)
	-- label:setTag(items[tostring(ItemIndex.Brush)])
	-- label:setString("x"..label:getTag())
	if(curPoint >= tollNum)then 
		btn:onClick(function(sender) setIcoMove(sender, ItemIndex.Brush) end, false)
	end

	--同色消除
	btn = self:getChildByName("item2")
	label = btn:getChildByName("Text")
	self:setItemLabel(label, ItemIndex.Eliminate)
	-- label:setTag(items[tostring(ItemIndex.Eliminate)])
	-- label:setString("x"..label:getTag())
	if(curPoint >= tollNum)then 
		btn:onClick(function(sender) setIcoMove(sender, ItemIndex.Eliminate) end, false)
	end

	--炸弹
	btn = self:getChildByName("item3")
	label = btn:getChildByName("Text")
	self:setItemLabel(label, ItemIndex.Bomb)
	-- label:setTag(items[tostring(ItemIndex.Bomb)])
	-- label:setString("x"..label:getTag())
	if(curPoint >= tollNum)then 
		btn:onClick(function(sender) setIcoMove(sender, ItemIndex.Bomb) end, false)
	end

	--彩虹珠(连接任意颜色)
	-- btn = self:getChildByName("item4")
	-- label = btn:getChildByName("Text")
	-- self:setItemLabel(label, ItemIndex.Interchange)
	-- label:setTag(items[tostring(ItemIndex.Interchange)])
	-- label:setString("x"..label:getTag())
	-- if(curPoint >= tollNum)then 
	-- 	btn:onClick(function(sender) setIcoMove(sender, ItemIndex.Interchange) end, false)
	-- end

	--文字提示
	self.hintLayer = self:getChildByName("imgSpeak")
	self:closeHint()
	
    self:addEventListener(Event.zhadan, handler(self, self.checkHintEvent))

    --常提醒动画提示
    self.hintAni = display.createArmature({path=Prefix.PRES_EFFECT.."tishiguangquan/tishiguangquan"}, 0)
    self:addChild(self.hintAni)
    self.hintAni:setScale(0.5)
    self:setHintAni(false)
end

function ToolBarLayer:setItemLabel( _label, _idx )
	local items = SharedManager:readData(Config.Storage)
	local countOut = self.tollgate.tool[tostring(_idx)]
	local count = items[tostring(_idx)] + countOut

	_label:setTag(count)
	_label:setString("x"..count)
	_label:setColor(countOut>0 and cc.c3b(0, 255, 19) or cc.c3b(255, 255, 255))
end
--删减道具
function ToolBarLayer:delItem()
	local items = SharedManager:readData(Config.Storage)
	local key = tostring(self.itemIdx)
	if(self.tollgate.tool[key]>0)then
		self.tollgate.tool[key] = self.tollgate.tool[key] - 1
	else
		items[key] = math.max(0, items[key] - 1)
		SharedManager:saveData(Config.Storage, items)
	end
	self:setItemLabel(self.btnLast:getChildByName("Text"), self.itemIdx)
	self:setHintAni(false)
	Global.touchStateToolUse = 1
end
function ToolBarLayer:addItem( _sender, _index, _count )
	local items = SharedManager:readData(Config.Storage)
	local key = tostring(_index)
	items[key] = math.max(0, items[key] + _count)
	SharedManager:saveData(Config.Storage, items, true)
	self:setItemLabel(_sender:getChildByName("Text"), _index)
end

--使用道具
function ToolBarLayer:useItem( _elementData, _widgets, _eliminateWidget, _autoBubble, _funAddPath, _funUpdatePath, _funEngineStart )
	local function dropSkill( _elementData, _widgets )
		local goodsdata = GoodsData[tostring(self.itemIdx)]
		local skilldata = SkillData[tostring(goodsdata.skill)]
	    _elementData.widget.eliminate = clone(goodsdata)
	    _elementData.widget.skill = clone(skilldata)
	    local widget = _widgets[_elementData.widget]
	    widget:updateEliminate()
	    self:delItem()
	end

	--是障碍物时 或 不是元素时
	if(_elementData.widget == nil)then 
		self:cancelItem()
		return
	end

    local type = _elementData.widget.eliminate.type
	if(self.itemIdx == ItemIndex.Bomb
		-- and type <= Config.DATA_PETTYPE_COUNT
	)then
		-- dropSkill( _elementData, _widgets )
		local tList = self:getBombPath(_elementData, 2, _eliminateWidget.getDataByGridXY)
		for i,v in ipairs(tList) do
			_funAddPath(v)
		end
		local bombArr = _funUpdatePath()
		for k,v in pairs(bombArr) do
			if(not table.indexof(tList,v))then
				tList[#tList+1] = v
			end
		end
		_funAddPath(nil)
		_funUpdatePath(tList)
		-- _funAddPath(_elementData)
        -- _eliminateWidget:deleteWidgetOne( _elementData )

        if tList and #tList > 0 then
    		local goods = self:createBombSprite(_elementData)
			SceneManager.currentScene:addToEffectLayer(goods)
			self:playBombAni(goods, _eliminateWidget, tList)
		    self:delItem()
        end
	elseif(self.itemIdx == ItemIndex.Brush)then
		if(type<=Config.DATA_PETTYPE_COUNT)then 
			_funAddPath(_elementData)
			local bombArr = _funUpdatePath()
			if(_eliminateWidget:deleteWidgetOne( _elementData ))then
                if bombArr and #bombArr > 0 then
                    _eliminateWidget:delSkillReady(bombArr, false)
                end
			else 
               	_funEngineStart()
            end
		    self:delItem()
		elseif(type ~= 13 or (type == 13 and _elementData.widget.pang ~= nil))then--不是炸弹
			_eliminateWidget:deleteAroundOne( _elementData, _elementData.widget )
			_funEngineStart()
		    self:delItem()
		end

	elseif(self.itemIdx == ItemIndex.Eliminate and type <= Config.DATA_PETTYPE_COUNT)then
        local list = _autoBubble:getWidgetInAllFor(type)
        if(#list>0)then
	        for k,v in pairs(list) do
	        	_funAddPath(v)
	        end
	        local bombArr = _funUpdatePath()
	        if bombArr and #bombArr > 0 then
	            _eliminateWidget:delSkillReady(bombArr, false)
	        end

	        for i, v in ipairs(list) do
	        	-- self:performWithDelay(handler(v, _eliminateWidget:deleteWidgetOne), 0.05*i)
	        	self:performWithDelay(handler(self,function()
	        		_eliminateWidget:deleteWidgetOne(v)
	        	end), 0.05 * i)
	        end
	        
			-- dropSkill( _elementData, _widgets )
		    self:delItem()
		end

	elseif(self.itemIdx == ItemIndex.Interchange)then
		dropSkill( _elementData, _widgets )
	end
	
	self:cancelItem()
end

--取消道具模式
function ToolBarLayer:cancelItem( )
	if(self.icoMove)then
		self.icoMove:removeFromParent()
		self.icoMove = nil
		self.itemIdx = 0
	end
	self.btnLast = nil
	self:closeHint()
	Global.touchStateTool = 0
	if(Global.touchStateToolUse == 2)then 
		Global.touchStateToolUse = 0
	end
end
-----------------------
function ToolBarLayer:createBombSprite( _elementData )
	local goodsData = GoodsData[tostring(ItemIndex.Bomb)]
	local goods = cc.Sprite:createWithSpriteFrameName(Prefix.PREBATTLE_PICTURE.. goodsData.picture .. PNG)
    local grid = _elementData:offSetPoint()
    goods:setPosition(grid)
    return goods
end
function ToolBarLayer:playBombAni( _goods, _eliminateWidget, _tBombArr, _bool )
	if(not _bool)then
		_goods:setScale(0.75)
		_goods:stopAllActions()
		_goods:runAction(cc.Sequence:create(
			cc.ScaleTo:create(0.1,1),
			cc.ScaleTo:create(0.2,1.2),
			cc.ScaleTo:create(0.3,1),
	        cc.ScaleTo:create(0.4,1.5),
	        cc.ScaleTo:create(0.05,2),             
			cc.CallFunc:create(function()
				_goods:removeFromParent()
	            _eliminateWidget:delSkillReady(_tBombArr, true, {})
			end)
		))
	else 
		_goods:stopAllActions()
		_goods:runAction(cc.Sequence:create(
			-- cc.ScaleTo:create(0.1,0.75),
			cc.MoveBy:create(0.05,cc.p(-5,0)),
			cc.MoveBy:create(0.05,cc.p(5,0)),
			cc.MoveBy:create(0.05,cc.p(-5,0)),
			cc.MoveBy:create(0.05,cc.p(5,0)),
			cc.CallFunc:create(function()
				_goods:removeFromParent()
	            _eliminateWidget:delSkillReady(_tBombArr, true, {})
			end)
		))
	end
end


-----------------------
--提示
function ToolBarLayer:openHint( _strHint, _sender )
	self.hintLayer:setVisible(true)
	self.hintLayer:getChildByName("Text"):setString(_strHint)
	local rect = _sender:rectLT()
	self.hintLayer:setPosition(cc.p(rect.x + rect.width / 2, rect.y))

	self.hintLayer:setScale(0.2)
	local sequence = cc.Sequence:create(
		cc.ScaleTo:create(0.15, 0.6, 1.5),
		cc.ScaleTo:create(0.1, 1.2, 0.6),
		cc.ScaleTo:create(0.1, 0.8, 1.2),
		cc.ScaleTo:create(0.1, 1.0, 1.0),
		cc.DelayTime:create(1.5),
		cc.ScaleTo:create(0.1,0.2),
		cc.CallFunc:create(function()
			self.hintLayer:setVisible(false)
		end)
		)
	self.hintLayer:runAction(sequence)
end

function ToolBarLayer:closeHint( )
	self.hintLayer:setVisible(false)
	self.hintLayer:stopAllActions()
end

--购买商店
function ToolBarLayer:openBuyItem( _sender, _index )
	if(_index == ItemIndex.Brush)then
        TalkingData.onPageStart("购买刷子")
	elseif(_index == ItemIndex.Bomb)then
        TalkingData.onPageStart("购买炸弹")
	elseif(_index == ItemIndex.Interchange)then
        TalkingData.onPageStart("购买转换")
	elseif(_index == ItemIndex.Eliminate)then
        TalkingData.onPageStart("购买同色消")
	end
	DialogManager:open("game.view.battle.BuyToolItemDialog", {addItem = handler(self, self.addItem), sender = _sender, index = _index})
end

-----------------------
--常提醒 
local bHintAni = true
function ToolBarLayer:setHintAni( _bEnable, _node )
	self.hintAni:setVisible(_bEnable)
	if(not _bEnable or _node == nil)then return end
	self.hintAni:setPosition(_node:getPosition())
	bHintAni = false
end
function ToolBarLayer:checkHintEvent( _event )
	local moves = _event._userdata.moves
	local data = _event._userdata.data
	local speakElves = _event._userdata.speakElves
	if(not bHintAni or self.hintAni:isVisible() or moves>3)then return end
	
	if(data["monster"]~=nil and data["monster"].num>0
		and self.autoBubble:isSkillElementSearch()
	)then --炸弹 
		self:setHintAni(true,self:getChildByName("item3"))
	elseif((data["1"]~=nil and data["1"].num>0) 
		or (data["2"]~=nil and data["2"].num>0) 
		or (data["3"]~=nil and data["3"].num>0) 
		or (data["4"]~=nil and data["4"].num>0) 
		or (data["5"]~=nil and data["5"].num>0) 
	)then --同色消
		self:setHintAni(true,self:getChildByName("item2"))
	else --刷子
		self:setHintAni(true,self:getChildByName("item1"))
	end
	speakElves:speak(Language.ToolSpeakHint)
end

-----------------------
--炸弹范围计算
function ToolBarLayer:getBombPath( _elementData, _range, _funGetDataByGrid )
	-- local tPath={cc.p(-1,0),cc.p(-1,-1),cc.p(0,-1),cc.p(1,-1),cc.p(1,0),cc.p(1,1),cc.p(0,1),cc.p(-1,1)}
	-- local x, y = _elementData.x, _elementData.y
	-- local n, tList = 0, {}
	-- n=n+1 tList[n] = _elementData
	-- for i=1,_range do
	-- 	for key,var in ipairs(tPath) do
	-- 		local element = _funGetDataByGrid(x + var.x*i,y + var.y*i)
	-- 		if(element and element.widget)then 
	-- 			n=n+1 tList[n] = element
	-- 		end
	-- 	end
	-- end

	local x, y = _elementData.x, _elementData.y
	local n, tList = 0, {}
	n=n+1 tList[n] = _elementData
	for h = -_range,_range do
		for v = -_range,_range do
			local r = math.abs(h) + math.abs(v)
			if(r ~= 0 and r <= _range)then
				local element = _funGetDataByGrid(x+h,y+v)
				if(element and element.widget)then 
					n=n+1 tList[n] = element
				end
			end
		end
	end

	return tList
end


return ToolBarLayer

