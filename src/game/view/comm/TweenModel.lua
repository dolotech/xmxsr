--缓动模型
local TweenModel = {}

--创建抖动 
--param target node 
--param times 抖动次数
function TweenModel.starRock(target,times,complete)
  local x,y = target:getPosition()
  target.x = x
  target.y = y
  target.times = times
  local moveTo1 = cc.EaseBackOut:create(cc.MoveTo:create(0.08,cc.p(x-2,y)))
  local moveTo2 = cc.EaseBackOut:create(cc.MoveTo:create(0.08,cc.p(x,y-2)))
  local moveTo3 = cc.EaseBackOut:create(cc.MoveTo:create(0.08,cc.p(x+2,y)))
  local moveTo4 = cc.EaseBackOut:create(cc.MoveTo:create(0.08,cc.p(x,y+2)))
  
  local rateTo1 = cc.EaseBackOut:create(cc.RotateTo:create(0.08,0.5))
  local rateTo2 = cc.EaseBackOut:create(cc.RotateTo:create(0.08,0))
  local rateTo3 = cc.EaseBackOut:create(cc.RotateTo:create(0.08,0))
  local rateTo4 = cc.EaseBackOut:create(cc.RotateTo:create(0.08,-0.5))
  
  local spawn1 = cc.Spawn:create(moveTo1,rateTo1)
  local spawn2 = cc.Spawn:create(moveTo2,rateTo1)
  local spawn3 = cc.Spawn:create(moveTo3,rateTo3)
  local spawn4 = cc.Spawn:create(moveTo4,rateTo4)
  
  local scaleTo1 = cc.EaseBackOut:create(cc.ScaleTo:create(0.05,0.9))
  local scaleTo2 = cc.EaseBackOut:create(cc.ScaleTo:create(0.05,1))
  
    local seq = cc.Sequence:create(spawn1,spawn2,spawn3,spawn4,scaleTo1,scaleTo2,cc.CallFunc:create(function()
        target.times =  target.times-1
        if target.times<=0 then
            if complete~=nil then
                complete()
            end
            target:setRotation(0)
            target:setPosition(target.x,target.y)
        else
            self:starRock(target,target.times,complete)
        end
  end))
  target:runAction(seq)
  return target     
end

--重复缩放
function TweenModel.RepeatScale(target,time,satrScale,endSacle)
    local scaleTo1 = cc.ScaleTo:create(time,satrScale)
    local scaleTo2 = cc.ScaleTo:create(time,endSacle)
    local seq = cc.Sequence:create(scaleTo1, scaleTo2)
    seq = cc.RepeatForever:create(seq)
    return target:runAction(seq)
end

--重复上下左右
function TweenModel.RepeatMove( _node, _time, _disX, _disY)
    local x,y = _node:getPosition()
    local moveTo1 = cc.MoveTo:create(_time, cc.p(x + _disX, y + _disY))
    local moveTo2 = cc.MoveTo:create(_time, cc.p(x, y))
    local seq = cc.Sequence:create(moveTo1, moveTo2)
    return _node:runAction(cc.RepeatForever:create(seq))
end
--[[ 重复绕圈运动 顺时针转
  _x,_y 起始位置 
  _pIndex 起始点 1左下 2左上 3右上 4右下
]]
function TweenModel.RepeatMoveForCircle( _node, _speed, _x, _y, _w, _h, _pIndex)
  if(_pIndex == nil)then _pIndex = 1 end
  local tw,th = (_w/_speed)*0.1, (_h/_speed)*0.1
  local pos = { {t=tw,x=_x,y=_y}, {t=th,x=_x,y=_y+_h}, 
                {t=tw,x=_x+_w,y=_y+_h}, {t=th,x=_x+_w,y=_y} }

  local p = pos[_pIndex]
  _node:setPosition(p.x,p.y)
  local n,list = 0,{}
  for i=1,4 do
    _pIndex = _pIndex+1>4 and 1 or _pIndex+1
    p = pos[_pIndex]
    n = n+1 list[n] = cc.MoveTo:create(p.t, cc.p(p.x,p.y))
  end
  return _node:runAction(cc.RepeatForever:create(cc.Sequence:create(list)))
end

--重复旋转
function TweenModel.RepeatRotate( _node, _time, _dirX, _dirY)
    local RotateTo1 = cc.RotateTo:create(_time, _dirX or 0, _dirY or 0)
    local seq = cc.Sequence:create(RotateTo1)
    local repeatForever= cc.RepeatForever:create(seq)
    _node:runAction(repeatForever)
end

--缓动来弹回
function TweenModel.EaseBack(target,time,endPoint,complete,updataFu)
   local moveOut = cc.EaseBackOut:create(cc.MoveTo:create(time,endPoint))
   local callBack = cc.CallFunc:create(function()
        if complete~=nil then
        	complete()
        end
   end)
   target:runAction(cc.Sequence:create(moveOut,callBack))
end

--放大缩小
function TweenModel.scaleBock(target,time,satrScale,endScale,complete)
    local scaleTo1 = cc.EaseSineInOut:create(cc.ScaleTo:create(time,satrScale))
    local scaleTo2 = cc.EaseSineInOut:create(cc.ScaleTo:create(time,endScale))
    local callBack = cc.CallFunc:create(function()
        if complete~=nil then
            complete()
        end
    end)
    local seq = cc.Sequence:create(scaleTo1,scaleTo2,callBack)
    target:runAction(seq)
end

--怪物掉落重力
function TweenModel.monsterDrop(target,endPoint,endScale,callback)
    local moveto = cc.MoveTo:create(0.2,endPoint)
    local callFunc = cc.CallFunc:create(callback)
    local scale1 = cc.ScaleTo:create(0.1,endScale+0.2,endScale-0.2)
    local scale2 = cc.ScaleTo:create(0.08,endScale-0.05,endScale+0.1)
    local scaleTo = cc.ScaleTo:create(0.08,endScale,endScale)
    local seq = cc.Sequence:create(moveto,callFunc,scale1,scale2,scaleTo)
    target:runAction(seq)
end

return TweenModel