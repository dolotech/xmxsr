--[[
	事件类
]]

local EventHandle = class("EventHandle")
-----------------------------------------------------------------------
local data, eventLen, idx, state, eventName, 
assignFunc -- -2等待 -1正常 >-1执行指定事件 
function EventHandle:ctor( _curScene )
	self.curScene = _curScene
	self:itMaskLayer()
    self:setMaskVisible(false)    

    self.speakElves = require("game.view.comm.SpeakElves"):create()
    self.curScene:addToEffectLayer(self.speakElves)
end

function EventHandle:itEventData( _strFile, _index )
	eventName = _strFile
	-- print("------itEventData]"..eventName)
	if(data ~= nil)then data = nil end
	if(_index == nil)then 
		local events = SharedManager:readData(Config.Events)
		_index = events[eventName] or 0
	end
	eventLen = 0

	-- _index = 1

	_strFile = "game.event."..eventName.."_".._index
	-- local fullPath = cc.FileUtils:getInstance():fullPathForFilename("game/event/"..eventName.."_".._index..".lua")
	if(io.exists_for_path("game/event/"..eventName.."_".._index..".lua"))then 
		data = require(_strFile)
		eventLen = #data
	end
	self:resetEvent()
end

-- 0下1上 2左3右
function EventHandle:getFinger( _node )
	-- local fingerSprite = cc.Sprite:create("ui/jiantou" .. PNG)
    local fingerSprite = cc.Sprite:create()
    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("ui/jiantou.png")
    fingerSprite:setSpriteFrame(frame)
	_node:addChildWithAnchor(fingerSprite)
	return fingerSprite
end
function EventHandle:setFinger(_node, _loc, _dir)
	local angle = 0
	if(_dir == 0)then angle = 0
	elseif(_dir == 1)then angle = 180
	elseif(_dir == 2)then angle = 90
	elseif(_dir == 3)then angle = 270
	else 
		_node:setVisible(false)
		return
	end
	_node:setVisible(true)
	_node:setRotation(angle)
    _node:setPosition(_loc)

	local x,y = 0,0
	if(_dir<2)then y = 10
	else x = 10
	end
	_node:stopAllActions()
	tween.RepeatMove(_node, 0.5, x, y)
	-- tween.RepeatRotate(_node, 1, 720, 0)
end

---------------[[   遮罩处理   ]]-----------------

function EventHandle:itMaskLayer()
	self.layerMask = cc.ClippingNode:create()
	self.layerMask:setInverted(true)
	self.layerMask:stageLeftBottom()
	self.layerMask:setPosition(cc.p(0,0))
	self.curScene:addToEffectLayer(self.layerMask)

	local node = cc.Node:create()
	self.layerMask:setStencil(node)
	local layer = cc.LayerColor:create(cc.c4b(255,255,255,255))
	layer:setAnchorPoint(0.5,0.5)
	layer:setName("node")
	node:addChild(layer)
	self.layerMask.layerStencil = node
	self.layerMask.layerStencil.layerT = layer

	layer = cc.LayerColor:create(cc.c4b(0,0,0,200))
	layer:setTouchEnabled(true)
	self.layerMask:addChild(layer)
	self.layerMask.layerTouch = layer

	self.layerMaskTop = cc.Node:create()
	self.curScene:addToEffectLayer(self.layerMaskTop)

	local image = ccui.ImageView:create()
	image:setAnchorPoint(0.5,0.5)
	image:setScale9Enabled(true)
	image:setCapInsets(cc.rect(10, 10, 42, 42))
	image:loadTexture("ui/xinshouyindaokuang02.png", ccui.TextureResType.plistType)
	self.layerMaskTop:addChild(image)
	self.layerMask.imagek = image
	self.layerMask.finger = self:getFinger(self.layerMaskTop)
	self.layerMask.touchstate = 0
	self.layerMask.touchmode = 0--0指定范围 1全屏
    layer:setTouchHandler( function( _eventType, _touchX, _touchY )
    	local bool = self.MaskRect and cc.rectContainsPoint(self.MaskRect, cc.p(_touchX, _touchY))
		if(self.layerMask.touchmode==0 and bool)then 
			self.layerMask.touchstate = 2
		 	return false
		elseif(self.layerMask.touchmode==1)then
			self.layerMask.touchstate = 2
			if(bool)then return false end
		end
		return true 
	end)

end
function EventHandle:setMaskVisible( _bool, _bOpacityAct, _rect )

	self.layerMask:setVisible(_bool)
	self.layerMaskTop:setVisible(_bool)
	self.layerMask.layerTouch:setTouchEnabled(_bool)

	self.MaskRect = _rect
	if(_rect==nil or not _bool)then
		--删掉多余的层
		local layer = self.layerMask.layerStencil
		for k,v in pairs(layer:getChildren()) do
			if(v:getName()~="node")then 
				v.imageAdd:removeFromParent()
				v:removeFromParent()
			end
		end
		return 
	end

	self.layerMask.layerStencil.layerT:setPosition(cc.p(_rect.x,_rect.y))
	self.layerMask.layerStencil.layerT:setContentSize(cc.size(_rect.width,_rect.height))
	self.layerMask.imagek:setPosition(cc.p(_rect.x+_rect.width/2,_rect.y+_rect.height/2))
	self.layerMask.imagek:setContentSize(cc.size(_rect.width+24,_rect.height+24))

	self.layerMask.layerTouch:setOpacity(0)
	if(not checkbool(_bOpacityAct))then 
		self.layerMask.layerTouch:stopAllActions()
		self.layerMask.layerTouch:runAction(cc.FadeTo:create(0.8, 200))
	end

	self:setMaskAction(self.layerMask.imagek)
	-- self:setMaskAction(self.layerMask.layerStencil.layerT)
	-- print("--------setMaskVisible] rect:",_rect.x,_rect.y,_rect.width,_rect.height)
end
function EventHandle:setMaskAction( _node )
	_node:setScale(0.1)
	_node:stopAllActions()
	_node:runAction(cc.Sequence:create(
		cc.ScaleTo:create(0.3,1),
		cc.CallFunc:create(function() 
			_node:runAction(cc.RepeatForever:create(cc.Sequence:create(
				cc.ScaleTo:create(1,1.05),
				cc.ScaleTo:create(1,1)
			)))
		end)
	))
end
function EventHandle:openMask( _event, _func )
	if(self.layerMask.touchstate==0)then
		self.layerMask.touchstate = 1
		local strs = string.split(_event[2],"+")
		local node = _func(strs)
		if(node == nil)then 
			self.touchstate = 0
			self:setMaskVisible(false)
			self:nextEvent()
			return
		end
			
		local p = node:convertToWS(self.curScene)
		self:setMaskVisible(true, _event[8]==-1,cc.rect(p.x,p.y,_event[3],_event[4]))
		self:setFinger(self.layerMask.finger, cc.p(p.x+_event[6],p.y+_event[7]), _event[5])
		self.layerMask.touchmode = 0
		if(_event[8]==-1)then--点击屏幕隐藏遮罩
			self.layerMask.touchmode = 1
		elseif(_event[8]==-2)then--只能手动关闭遮罩
			self:nextEvent() 
		elseif(_event[8]>0)then 
			state, assignFunc = 0, -2
			self.curScene:performWithDelay(function() 
				self:setMaskVisible(false)
				self:nextEvent() 
			end, _event[8])
		end
		
	elseif(self.layerMask.touchstate==2)then
		self:setMaskVisible(false)
		self:nextEvent()
	else 
		state = 0
	end
end
function EventHandle:addMask( _event, _func )
	local strs = string.split(_event[2],"+")
	local node = _func(strs)
	if(node ~= nil)then 
		local p = node:convertToWS(self.curScene)
		local size = cc.size(_event[3],_event[4])
		local node = self.layerMask.layerStencil
		layer = cc.LayerColor:create(cc.c4b(255,255,255,255))
		layer:setAnchorPoint(0.5,0.5)
		layer:setName("layerAdd")
		layer:setPosition(p)
		layer:setContentSize(size)
		node:addChild(layer)
		self:setMaskAction(layer)

		local image = ccui.ImageView:create()
		image:setAnchorPoint(0.5,0.5)
		image:setScale9Enabled(true)
		image:setCapInsets(cc.rect(10, 10, 42, 42))
		image:loadTexture("ui/xinshouyindaokuang02.png", ccui.TextureResType.plistType)
		self.layerMaskTop:addChild(image)
		layer.imageAdd = image
		image:setPosition(cc.p(p.x+size.width/2,p.y+size.height/2))
		image:setContentSize(cc.size(size.width+24,size.height+24))
		self:setMaskAction(image)
	end
	self:nextEvent()
end

---------------[[   事件处理的方法   ]]-----------------

local EventFunc = {}
--事件跳转goto
function EventFunc.func_0( self, _event )
	self:gotoEvent(_event[2])
end
--延时事件
function EventFunc.func_1( self, _event )
	state, assignFunc = 0, -2
	self.curScene:performWithDelay(function() self:nextEvent() end, _event[2])
end
--事件结束 0存储,载入下个大事件 1存储,不载入下个大事件 2不存储,载入下个大事件 3不存储,不载入下个大事件
function EventFunc.func_2( self, _event )
	if(_event[2]==0 or _event[2]==1)then
		local events = SharedManager:readData(Config.Events,{})
		local _index = events[eventName] or 0
		events[eventName] = _index + 1
		SharedManager:saveData(Config.Events, events, true)
	end
	if(_event[2]==0 or _event[2]==2)then
		self:itEventData(eventName)
		state = 1
	else
		self:nextEvent() 
	end
end
--指定关卡是否完成
function EventFunc.func_3( self, _event )
	local point = SharedManager:readData(Config.POINT)
	if(point > _event[2])then--完成跳转
		self:gotoEvent(_event[3])
	else --完成跳转
		self:gotoEvent(_event[4])
	end
end
--是否显示当前关卡手指
function EventFunc.func_4( self, _event )
	self.curScene:event({name = "finger", visible = _event[2]})
	self:nextEvent() 
end
--文字提醒
function EventFunc.func_5( self, _event )

	local anchor = _event[4]
	local x,y=_event[5],_event[6]
	if(anchor==1 or anchor==8 or anchor==5)then
		x = stageWidth/2 + _event[5]
	elseif(anchor==2 or anchor==3 or anchor==4)then
		x = stageWidth + _event[5]
	end

	if(anchor==7 or anchor==8 or anchor==3)then
		y = stageHeight/2 + _event[6]
	elseif(anchor==6 or anchor==5 or anchor==4)then
		y = stageHeight + _event[6]
	end

	self.speakElves:openHint(_event[2], cc.p(x,y), _event[7], _event[8])
	if(_event[3]>0)then 
		assignFunc = -2
		self.curScene:performWithDelay(function() 
		self.speakElves:closeHint()
		end, _event[3]) 
	end
	self:nextEvent() 
end
--是否点击指定关卡
function EventFunc.func_6( self, _event )
--	print("--------func6]",Global.selChapterId,_event[2])
	if(Global.selChapterId==_event[2])then 
		self:nextEvent()
	else 
		state = 0
	end
end
--打开遮罩－绑定弹出框控件
function EventFunc.func_7( self, _event )
	self:openMask(_event, function( _strs ) 
		return DialogManager.curDialog:getChildByNameFo(_strs)
	end)
end
--战斗元素教学是否完成
function EventFunc.func_8( self, _event )
	if(self.newbiestate == 2)then 
		self:nextEvent()
	else
		state = 0
	end
end
--关闭提示
function EventFunc.func_9( self, _event )
	if(_event[2]==0)then self.speakElves:closeHint()
	elseif(_event[2]==1)then self:setMaskVisible(false) 
	elseif(_event[2]==2)then DialogManager.curDialog:close() 
	end

	self:nextEvent()
end
--是否打开指定提示框(包括动画完成)
function EventFunc.func_10( self, _event )
	-- print("func_10]",_event[2],DialogManager.curDialogName)
	if(_event[2]==DialogManager.curDialogName and DialogManager.isActionNotRun)then 
		self:nextEvent()
	else 
		state = 0
	end
end
--打开遮罩－绑定场景控件
function EventFunc.func_11( self, _event )
	self:openMask(_event, function( _tStrs ) 
		return self.curScene:GetChildByScene(_tStrs)
	end)
end
--是否签到完成
function EventFunc.func_12( self, _event )
	local data = SharedManager:readData(Config.Sign)
    local from = os.time()
    local to = os.time(data.date)
    if (from - to) >= 0 then --还没签到
    	self:gotoEvent(_event[2])
	else --已经签到
		self:gotoEvent(_event[3])
	end
end
--弹窗框是否关闭
function EventFunc.func_13( self, _event )
	print("------EventFunc.func_13]",DialogManager.curDialogName)
    if(DialogManager.curDialogName == nil or DialogManager.curDialogName == "")then --已经关闭
    	self:gotoEvent(_event[3])
	else --没关闭
		self:gotoEvent(_event[2])
	end
end
--添加遮罩框
function EventFunc.func_14( self, _event )
	print("------EventFunc.func_14]")
	self:addMask(_event, function( _tStrs ) 
		return self.curScene:GetChildByScene(_tStrs)
	end)
end
--是否点击了元素
function EventFunc.func_15( self, _event )
	if(Global.touchStateElement == 1)then 
    	self:gotoEvent(_event[3])
	else --没关闭
		self:gotoEvent(_event[2])
	end
end
--是否点击了道具
function EventFunc.func_16( self, _event )
	if(Global.touchStateTool == 1)then 
    	self:gotoEvent(_event[3])
	else --没关闭
		self:gotoEvent(_event[2])
	end
end
--是否使用道具成功
function EventFunc.func_17( self, _event )
	if(Global.touchStateToolUse == 1)then 
    	self:gotoEvent(_event[3])
	elseif(Global.touchStateToolUse==0)then
		self:gotoEvent(_event[2])
	else 
		state = 0
	end
end
---------------[[   事件处理的方法   ]]-----------------

function EventHandle:gotoEvent( _eventId )
	---print("------gotoEvent]",_eventId)
	if(_eventId==-2)then 
		state = 0
		return
	end
	idx = _eventId
	if(idx>-1)then idx = idx + 1 end
end

---------------[[   事件处理   ]]-----------------

function EventHandle:nextEvent()
	assignFunc = -1
	self.tstate = 0
	self.layerMask.touchstate = 0
	self.newbiestate = 0
	idx = idx + 1
end
function EventHandle:resetEvent()
	idx = 1
	state = 0
	assignFunc = -1
	self.tstate = 0
	self.layerMask.touchstate = 0
	self.newbiestate = 0
end
function EventHandle:runEvent( _delta )
	if(data==nil or idx==-1)then
		state = -1
		return true
	end

	state = 1
	while state==1 and idx>-1 do
		if(idx>eventLen)then 
			state, idx = -1, -1
			return true
		end
		local event = data[idx]
		if(assignFunc==-1)then 
			local func = EventFunc["func_"..event[1]]
			if(func~=nil)then func(self,event) end
		elseif(assignFunc>-1)then
			local func = EventFunc["func_"..assignFunc]
			if(func~=nil)then func(self,event) end
		else
			state = 0
		end
		-- print("----runEvent]event:"..event[1].."  assignFunc:"..assignFunc)
	end
end

-----------------------------------------------------------------------
return EventHandle

