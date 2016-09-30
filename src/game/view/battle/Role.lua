-- 角色显示对象
local BattleEvent = require("game.view.battle.BattleEvent")
local Role = class("Role",function(data)
    return display.createArmature({path="role/"..data.avatar.."/"..data.avatar})
end)


function Role:create(data)
    local instance = Role.new(data)
    return instance
end

function Role:ctor(data)
    --添加动画
    self.data = data
    self:addEventListener(BattleEvent.RESUME ,handler(self,self.onPlaye))
    self:addEventListener(BattleEvent.PAUSE ,handler(self,self.onPause))
    self:changeWeapon(data.wepon)
    self:setScale(data.scale)
end

--换装
function Role:changeWeapon(weapon)
    local path = Prefix.PRES_WEAPON .. weapon .. PNG
    local displayData = ccs.Skin:create(path)
    local bone = self:getBone("weapon")
    bone:addDisplay(displayData,1) 
    bone:changeDisplayWithIndex(1, true)
end

function Role:onPlaye()
    self:getAnimation():resume()
end

function Role:onPause()
    self:getAnimation():pause()
end

--待机
function Role:playIdle()
    self:getAnimation():play(Action.PLAY_IDLE)
end

--选中
function Role:setPowerEffect(bool)
    if self.powerEffect==nil then
        if bool then
            self.powerEffect = display.createEffect(Prefix.PREOPE_ROLE_NAME,"effect_0"..self.data.type,nil,false,true)
            self.powerEffect:setPosition(0,-100) 
            self.powerEffect:setScale(2*1/self.data.scale)
            self:addChild(self.powerEffect,-1)
        end
    else
        self.powerEffect:setVisible(bool)
    end
end


--攻击
function Role:playAttack(commpelete)
    self:getAnimation():setMovementEventCallFunc(
        function(armatureBack,movementType,movementID)
            if movementType == ccs.MovementEventType.complete and  movementID==Action.PLAY_ATTACK then
                self:playIdle()
                if commpelete~=nil then
                    commpelete()
                end
            end
    end)
    Audio.playSound(Sound[self.data.attackSound])
    self:getAnimation():play(Action.PLAY_ATTACK)
end


--扔法宝
function Role:playTrump(commpelete)
    
    self:getAnimation():setMovementEventCallFunc(
    function(armatureBack,movementType,movementID)
            if movementType == ccs.MovementEventType.complete and movementID==Action.PLAY_TRUMP then
                self:playIdle()
                if commpelete~=nil then
                	commpelete()
                end
            end
    end)
    Audio.playSound(Sound[self.data.skillSound])
    self:getAnimation():play(Action.PLAY_TRUMP)
end

--胜利
function Role:playWin()
    self:getAnimation():play(Action.PLAY_WIN)
end


function Role:onEnter()

end

function Role:onExit()

end


return Role






    