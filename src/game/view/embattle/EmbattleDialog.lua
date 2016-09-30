-- 战斗前布阵

local EmbattleDialog = class("EmbattleDialog",function(tollgateData)
    return display.createUI("EmbattleDialog.csb")
end)

function EmbattleDialog:onEnter()
    self.FlyToModel =  require("game.view.comm.FlyToModel"):create()
    
    self.curPoint = SharedManager:readData(Config.POINT)
    self:getChildByName("Node_btn"):getChildByName("Button_1"):setTitleText(Language.START)
    self:getChildByName("Text_8"):setString(Language.Select_Pet_Figth)
    self:getChildByName("Node_des"):setVisible(false)
    self:getChildByName("Node_mask"):setLocalZOrder(100)
--    self:getChildByName("nextBtn"):setLocalZOrder(100)
--    self:getChildByName("lastBtn"):setLocalZOrder(100)
    self:initChpterPageView()
    self:initPetPageView()

    self:getChildByName("closeButton"):onClick(function()Audio.playSound(Sound.SOUND_UI_READY_BACK, false)self:close()end, false, false)
    self:getChildByName("Node_btn"):getChildByName("Button_1"):onClick(function()
        local power = SharedManager:readData(Config.POWER)
        if power < self.tollgate.power then
        	DialogManager:open("game.view.power.PowerDialog")
        	return
        end
        if self.curPoint < self.tollgate.id then
            local page = self.pageView:getPage(self.pageIndex):getChildByName("page")
--            page:getChildByName("lock"):getAnimation():play("unlock")--关卡解锁动画
            Audio.playSound(Sound.SOUND_UI_MAP_CLICK)
            TipsManager:ShowText(Language.no_open_point)
            return
        end
       self:starBattle()
    end, true, false)
--   local lastBtn = self:getChildByName("lastBtn")
--   local nextBtn = self:getChildByName("nextBtn")
    tween.RepeatScale(self:getChildByName("Node_btn"), 1.2, 1, 1.2)

    Color.setLableShadows({self:getChildByName("Text_title"), self:getChildByName("Node_btn"):getChildByName("Text_1"), self:getChildByName("Text_8"), self:getChildByName("Node_des"):getChildByName("Text_des")})
end

--开始战斗
function EmbattleDialog:starBattle()
    Audio.playSound(Sound.SOUND_UI_READY_CLICK)
    self:getChildByName("Node_btn"):stopAllActions()
    self:getChildByName("Node_btn"):setScale(1)
    self.pageView:setTouchEnabled(false)
    self:getChildByName("Node_btn"):getChildByName("Button_1"):setEnabled(false)
    self.FlyToModel:flyDropModel(Picture.RES_POWER_IOCN_PNG,cc.p(47,stageHeight-58),cc.p(offSetX + 384,67),0.5,1,0.4,nil,function()
        self:performWithDelay(function()
            SceneManager.changeScene(Scene.Battle,{tollgate =  self.tollgate})
        end, 0.01)
    end, 5, 0.5, 0.8)  
end

--章节页
function EmbattleDialog:initChpterPageView()
    local pageView = ccui.PageView:create()
    pageView:setTouchEnabled(true)
    pageView:setContentSize(cc.size(514, 250))
    pageView:setPosition(-512 / 2, 160)
    pageView:setCustomScrollThreshold(cc.Device:getDPI() / 3)--翻译灵敏度，设置半英寸(2.54/2 厘米(cm) )
    pageView:setLayoutType(ccui.LayoutType.HORIZONTAL)
    self.pageView = pageView
    
--    local pointTable = MapData[tostring(self.param.Id)]
--    local index = 0
--    local type = 0
--    local curSelect = {page = 0,point = 0}
--    for key = pointTable.scope.a, pointTable.scope.b, 1 do
--        if self.curPoint == key then--当前达到关卡
--            type = 1
--            curSelect.point = key
--            curSelect.index = index
--        elseif self.curPoint > key then--已经通过关卡
--            type = 2
--        elseif self.curPoint < key then--没通过关卡
--            type = 3
--        end
--        index = index + 1
--        self:createItemPage(key, index, type)
--    end

    local key = self.param.Id
    local index = 0
    local type = 0
    local curSelect = {page = 0, point = 0}
    if self.curPoint == key then--当前达到关卡
        type = 1
        curSelect.point = key
        curSelect.index = index
    elseif self.curPoint > key then--已经通过关卡
        type = 2
    elseif self.curPoint < key then--没通过关卡
        type = 3
    end
    index = index + 1
    self:createItemPage(key, index, type)
    
    if curSelect.point > 0 then
       self.pageIndex = curSelect.index
        self:updataTollgateData(curSelect.point)
    else
        self.pageIndex = index - 1
        self:updataTollgateData(self.param.Id)
    end
 
    local function pageViewEvent(sender, eventType)
        if eventType == ccui.PageViewEventType.turning then
            local index = sender:getCurPageIndex() + 1
            if pageView:getCurPageIndex() ~= self.pageIndex then
                self.pageIndex = pageView:getCurPageIndex()
                Audio.playSound(Sound.SOUND_UI_READY_SLIDE, false)
                local point = pageView:getPage(self.pageIndex).point
                self:updataTollgateData(point)
            end
        end
    end 

    pageView:addEventListener(pageViewEvent)
    self:addChild(pageView, 0)
    
    pageView:scrollToPage(self.pageIndex)
    if Config.OPEN_LOCK_ID ~= 0 then
       Config.OPEN_LOCK_ID = 0
--       self:openEffect()
    end
end

--开锁特效
function EmbattleDialog:openEffect()
    self.pageView:setTouchEnabled(false)
    local function eventCallFunc(effect, armatureBack, movementType, movementID)
        local page = self.pageView:getPage(self.pageIndex):getChildByName("page")
        page:getChildByName("Node_golas"):setVisible(true)
        page:getChildByName("lock"):setVisible(false)
        page:getChildByName("lock"):getAnimation():stop()
        page:getChildByName("Sprite_bg"):setColor(cc.c4b(255, 255, 255, 255))
        self.pageView:setTouchEnabled(true)
    end
    local boxEffect = display.createEffect(Prefix.PREOPE_LOCK_NAME, "open", eventCallFunc, true, false)
    boxEffect:setPositionY(300)
    self:addChild(boxEffect)
end

--创建page内容
function EmbattleDialog:createItemPage(point, pIndex, type)
    local tollgate = TollgateData[tostring(point)]
    
    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(512, 250))
    layout:setPosition(0,0)
    layout:setTag(pIndex)
    layout.point = point
    
    local page = display.createUI("node_chapter_page.csb")
    local lock = display.createEffect(Prefix.PREOPE_LOCK_NAME, "unlock", nil, false, false)
--    lock:setName("lock")
--    lock:getAnimation():stop()
--    lock:setPosition(248, 123)
--    page:addChild(lock)
--    page:setName("page")
    local golas = page:getChildByName("Node_golas")
    local index = 0 
    if tollgate.targetmonster ~= nil and tollgate.targetmonster > 0 then
        index = index + 1
        local image = golas:getChildByName("Sprite_" .. index)
        local text = golas:getChildByName("Text_" .. index)
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(Picture.RES_MONSTER_PNG)
        image:setScale(0.8)
        image:setSpriteFrame(frame)
        text:setString(tostring(tollgate.targetmonster))
    end

    local target = tollgate.target
    if tollgate.target ~= nil then
        target = tollgate.target
        for id, var in pairs(target) do
            index = index + 1
            local image = golas:getChildByName("Sprite_" .. index)
            local text = golas:getChildByName("Text_" .. index)
            Color.setLableShadow(text)
            local goods = GoodsData[tostring(id)]
            local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(Prefix.PREBATTLE_PICTURE .. goods.picture .. PNG)
            image:setSpriteFrame(frame)
            text:setString(tostring(var))
        end
     end
         
    for i = index + 1, 3, 1 do
        golas:getChildByName("Sprite_" .. i):setVisible(false)
        golas:getChildByName("Text_" .. i):setVisible(false)
    end
    
    if type==1 then--第一次开启关卡
--        page:getChildByName("lock"):setVisible(false)
        if Config.OPEN_LOCK_ID == 0 then
            page:getChildByName("Sprite_bg"):setColor(cc.c4b(255,255,255,255))
        else
--            golas:setVisible(false)
        end
    elseif type == 2 then--已经开启关卡
--        page:getChildByName("lock"):setVisible(false)
        page:getChildByName("Sprite_bg"):setColor(cc.c4b(255,255,255,255))
    else--锁定的关卡
        golas:setVisible(false) 
    end
    
    if type == 1 or type == 2 then
--        self:setPointStar(page, point)
    end
    
    golas:getChildByName("Text_4"):setString(tostring(tollgate.moves))
    local texture = cc.Director:getInstance():getTextureCache():addImage(Prefix.PRES_SCENE_PICTURE .. "res/"..tollgate.sceneID.."_3".. PNG)
    page:getChildByName("Sprite_bg"):setTexture(texture)
    golas:getChildByName("Text_5"):setString(Language.Gloas_Task)
    golas:getChildByName("Text_6"):setString(Language.Moves)
    Color.setLableShadows({golas:getChildByName("Text_4"), golas:getChildByName("Text_5"), golas:getChildByName("Text_6")})
    layout:addChild(page)
    self.pageView:addPage(layout)
end

--更新当前选中关卡数据
function EmbattleDialog:updataTollgateData(point)
    self.tollgate = clone(TollgateData[tostring(point)])
    self.tollgate.id = point
    self:getChildByName("Node_btn"):getChildByName("Text_1"):setString(self.tollgate.power)
    self:getChildByName("Text_title"):setString(tostring(self.tollgate.pointName))
    
--    local pointTable = ChapterData[tostring(self.param.Id)]
--    local type = 0
--    if self.curPoint == point then--当前达到关卡
--        type = 1
--    elseif self.curPoint > point then--已经通过关卡
--        type = 2
--    elseif self.curPoint < point then--没通过关卡
--        type = 3
--    end
--    self:setPageBtn(type)
end

--设置3星评价
function EmbattleDialog:setPointStar(page,point)
    local data = SharedManager:readData(tostring(point), Config.POINT_DATA_DUALFT)
    local starBar = require("game.view.embattle.StarEvaluation"):create()
    starBar:setStar(data.star)
    starBar:setScale(0.7)
    page:addChild(starBar)
end

--设置按钮翻页提示
function EmbattleDialog:setPageBtn(type)
    local lastBtn = self:getChildByName("lastBtn")
    local nextBtn = self:getChildByName("nextBtn")
    local lastBtn1 = self:getChildByName("lastBtn1")
    local nextBtn1 = self:getChildByName("nextBtn1")
    
    if type == 1 then --当前到达
        lastBtn:setVisible(true)
        nextBtn:setVisible(true)
        lastBtn1:setVisible(false)
        nextBtn1:setVisible(false)
    elseif type == 2 then --当前通过
        lastBtn:setVisible(true)
        nextBtn:setVisible(false)
        lastBtn1:setVisible(false)
        nextBtn1:setVisible(true)
    elseif type == 3 then --当前没通过
        lastBtn:setVisible(false)
        nextBtn:setVisible(true)
        lastBtn1:setVisible(true)
        nextBtn1:setVisible(false)
    end

    if self.pageIndex == 0 then
        lastBtn:setVisible(false)
        lastBtn1:setVisible(false)
    end

    if self.pageIndex == self.pageView:getChildrenCount() - 1 then
        nextBtn:setVisible(false)
        nextBtn1:setVisible(false)
    end
end

--宠物滚动页-------------------------------------------------------------------------------------------------
function EmbattleDialog:initPetPageView()
    self.data = {}
    for i = 1, Config.DATA_PETTYPE_COUNT, 1 do
        local clipper= cc.ClippingNode:create()
        clipper:setContentSize(cc.size(Config.DATA_EMBATTLE_PET_WIDTH, Config.DATA_EMBATTLE_PET_HEIGHT))
        clipper:setAnchorPoint(cc.p(0,0))
        clipper:setPosition(cc.p(107 * (i - 1) - (340 + offSetX), -270))
        --创建“裁减模板”
        local stencil = cc.DrawNode:create()
        stencil:setAnchorPoint(0, 0)
        stencil:setPosition(0, 0)
        stencil:drawRect(cc.p(offSetX, 0),cc.p(offSetX, Config.DATA_EMBATTLE_PET_HEIGHT), cc.p(Config.DATA_EMBATTLE_PET_WIDTH * 2 + offSetX, Config.DATA_EMBATTLE_PET_HEIGHT), cc.p(Config.DATA_EMBATTLE_PET_WIDTH * 2 + offSetX, 0), cc.c4f(1, 1, 0, 1))
        --为设置裁减节点类设置“裁减模板”
        clipper:setStencil(stencil)
        self:addChild(clipper, 1)
        
        local itemHeight = Config.DATA_EMBATTLE_PET_HEIGHT * 0.5
        --设置裁减节点类所放的内容
        local layer = cc.Layer:create()
        layer:setTag(i)
        layer:setContentSize(cc.size(Config.DATA_EMBATTLE_PET_WIDTH, Config.DATA_EMBATTLE_PET_HEIGHT))
        layer:setAnchorPoint(0, 0)
        layer:setPosition(0,itemHeight * 0.5)
        clipper:addChild(layer)
        
        local list = RoleDataManager.getPetsDataBuyType(i)
        local j = 0
        if list ~= nil then
            for key, roleData in pairs(list) do
            	j = j + 1
                local photo = roleData.photo
            	local item = cc.Layer:create()
                item:setName("item_" .. j)
                item:setTag(j)
                item:setContentSize(cc.size(Config.DATA_EMBATTLE_PET_WIDTH, itemHeight))
                item:setPosition(0, itemHeight * (j - 1))
                layer:addChild(item)
                
                local image = cc.Director:getInstance():getTextureCache():addImage(Prefix.PRES_PHOTO .. photo ..PNG)
                local rolePhoto =  cc.Sprite:createWithTexture(image)
                rolePhoto:setPosition(127 + offSetX,(itemHeight - rolePhoto:getContentSize().height) * 0.5 + 95)
                rolePhoto:setName("rolePhoto")
                item:addChild(rolePhoto)
                
                local skillData  = SkillData[tostring(roleData.skill)]
                local goodsData = GoodsData[tostring(skillData.wigetID)]
                local framName = Prefix.PREBATTLE_PICTURE..goodsData.picture .. PNG
                local skill = cc.Sprite:createWithSpriteFrameName(framName)
                skill:setName("skill")
                skill:setScale(0.8)
                skill:setPosition(55, -20)
                rolePhoto:addChild(skill)
                
                if roleData.embattle and j > 1 then--出战状态设置位置
                    layer:setPosition(0,(- itemHeight * (j - 1)) + itemHeight * 0.5)
                else
                end
                --i,j -->type,index---{宠物id，是否出战}
                self.data[i .. "_" .. j] = {id = key, embattle = roleData.embattle, role = roleData}
            end
        else
            --英雄解锁动画
            local lock = display.createEffect("effect_ui_003", "unlock", nil, false)
            lock:setName("lock")
            lock:getAnimation():stop()
            lock:setScale(0.5)
            lock:setPosition(127 + offSetX, itemHeight * 0.5)
            layer:addChild(lock)
        end
        
        layer:setContentSize(cc.size(Config.DATA_EMBATTLE_PET_WIDTH, itemHeight*j))
        layer.data = {oldY = 0,isBegan = false,isSclling = false,count = j}
        self["layer" .. i] = layer
        self:stopEnterFrame(layer)
        self:setVisiblePage(i)
    end
    self:setDragLayerItem()
end

--更新Alpha
function EmbattleDialog:updateSkillIconAlpha(layer)
    local sizeLayer = layer:getContentSize()
    local layerY = layer:getPositionY()
    local itemHeight = Config.DATA_EMBATTLE_PET_HEIGHT
    for i = 1,layer.data.count do 
        local item = layer:getChildByName("item_" .. tostring(i))
        local skilIcon = item:getChildByName("rolePhoto"):getChildByName("skill")
        local itemY = item:getPositionY()
        local opa = itemY + (layerY - itemHeight * 0.5 + 65)
        opa = math.abs(opa*1.6)
        if opa<0 then
        	opa = 0
        elseif opa> 255 then
            opa = 255
        end
        opa = 255 - opa
        skilIcon:setOpacity(opa)
    end
end

function EmbattleDialog:onEnterFrame()
    if self.currentItemLayer then
        self:updateSkillIconAlpha(self.currentItemLayer)
    end
end

function EmbattleDialog:startEnterFrame()
    if self.entryID == nil then
        self.entryID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
        function () 
            if self.onEnterFrame~=nil then
               self:onEnterFrame() 
            end
        end, 0, false)
    end
end

function EmbattleDialog:stopEnterFrame(layer)
    if self.entryID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.entryID)
        self.entryID = nil
    end
    
    local sizeLayer = layer:getContentSize()
    local layerY = layer:getPositionY()
    local itemHeight = Config.DATA_EMBATTLE_PET_HEIGHT
    for i = 1,layer.data.count do 
        local item = layer:getChildByName("item_" .. tostring(i))
        local skilIcon = item:getChildByName("rolePhoto"):getChildByName("skill")
        local itemY = item:getPositionY()
        local opa = itemY + (layerY - itemHeight * 0.5 + 65)
        opa = math.abs(opa*1.6)
        if opa<0 then
            opa = 0
        elseif opa> 255 then
            opa = 255
        end
        opa = 255 - opa
        if opa < 100 then
            opa = 0
        end
--        skilIcon:setOpacity(opa)
        skilIcon:runAction(cc.FadeTo:create(0.05, opa))
    end
end


function EmbattleDialog:setDragLayerItem(layer)
    --触摸开始
    local function touchBeganHandler(touch, event)
        local location = touch:getLocation()
        local bIndex  = self:getTouchType(location.x, location.y)
        if bIndex==0 then
            return true
        end
        local blayer = self["layer".. tostring(bIndex)]
        --先还原Began
        self:setBeganFalse()
        --取出数据
        if blayer.data.isSclling == false then
           blayer.data.oldY = location.y
           blayer.data.isBegan = true
           if blayer.data.count <= 0 then
           	blayer:getChildByName("lock"):getAnimation():play("unlock")
           end
           local index = math.round(self:getScollIndex(blayer:getPositionY()))
           local roleData = self.data[bIndex .."_"..index]
           if roleData~=nil then
               self:setRoleDes(roleData.role)
               self.currentItemLayer = blayer
               self:startEnterFrame()
           end
        end
        return true
    end

    --触摸移动
    local function touchMocveHandler(touch, event)
        local eIndex  = self:getBeganIdnex()
        if eIndex == 0 then
            return true
        end
        local elayer = self["layer" .. tostring(eIndex)]
        if elayer.data.isBegan ==false or elayer.data.count<=0 then
        	return true
        end
        local location = touch:getLocation()
        local gap = location.y - elayer.data.oldY
        elayer.data.oldY = location.y
        local x, y = elayer:getPosition()
        if gap < 0 then --往下
            self.data.dir = "down"
            elayer:setPosition(x,y - 6)
        elseif gap > 0 then --往上
            self.data.dir = "up"
            elayer:setPosition(x, y + 6)
        end
        return true
    end
    
    --触摸结束
    local function touchEndedHandler(touch, event)
        local eIndex  = self:getBeganIdnex()
        if eIndex == 0 then
            return true
        end
        local elayer = self["layer".. tostring(eIndex)]
        elayer.data.isBegan = false
        if elayer.data.isSclling == false then
            local x,y = elayer:getPosition()
            local saveIndex = self:getScollIndex(y)
            if self.data.dir == "down" then --往下
                saveIndex = math.ceil(saveIndex)
                if saveIndex <= 1 then
                   saveIndex = 1
                elseif saveIndex >= elayer.data.count then
                    saveIndex=elayer.data.count
                end
                self:scollItemHandler(elayer,saveIndex,eIndex,x)
            elseif self.data.dir == "up" then --往上
                saveIndex = math.floor(saveIndex)
                if saveIndex <= 1 then
                    saveIndex = 1
                elseif saveIndex >= elayer.data.count then
                    saveIndex=elayer.data.count
                end
                self:scollItemHandler(elayer, saveIndex, eIndex,x)
            end
        end
        return true
    end
    
    --注册事件
    local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:registerScriptHandler(touchBeganHandler, cc.Handler.EVENT_TOUCH_BEGAN)
    listenner:registerScriptHandler(touchMocveHandler, cc.Handler.EVENT_TOUCH_MOVED)
    listenner:registerScriptHandler(touchEndedHandler, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self)
end

--滚动
function EmbattleDialog:scollItemHandler(elayer,saveIndex,eIndex,x)
    local itemHeight = Config.DATA_EMBATTLE_PET_HEIGHT * 0.5--显示一半
    local offsetY = -(saveIndex - 1.5) * itemHeight
    tween.EaseBack(elayer, 0.3, cc.p(x, offsetY), function()self:saveRoleEmbattle(elayer, saveIndex, eIndex)end)
end

--保存数据
function EmbattleDialog:saveRoleEmbattle(elayer, saveIndex, eIndex)
    local saveData, curData = nil,nil
    elayer.data.isSclling = false 
    self.data.dir = ""
    self:stopEnterFrame(self.currentItemLayer)
    for key, var in pairs(self.data) do
        local type = tonumber(string.split(key, "_")[1])
        if type == eIndex then
            local index = tonumber(string.split(key, "_")[2])
            if var.embattle ~= nil and  var.embattle then
                if index == saveIndex then
                    return
                end
                curData = var
            end
        end
    end
    
    if curData ~= nil then 
        curData.embattle = false
        RoleDataManager.savePetEmbattle(curData.id,eIndex,curData.embattle,false)
    end
    
    saveData = self.data[eIndex .."_"..saveIndex]
    if saveData ~= nil then
        saveData.embattle = true
        RoleDataManager.savePetEmbattle(saveData.id,eIndex,saveData.embattle,true)
        self:setRoleDes(saveData.role)
    end
    
    Audio.playSound(Sound.SOUND_UI_READY_CHOSE,false)
    self:setVisiblePage(eIndex)
end

--设置显示于隐藏可以上下转页
function EmbattleDialog:setVisiblePage(pType)
    local index = -1
    for key, var in pairs(self.data) do
        local type = tonumber(string.split(key, "_")[1])
        if type == pType then
            if var.embattle ~= nil and  var.embattle then
                index = tonumber(string.split(key, "_")[2])
                break
            end
        end
    end
    local lastData = self.data[pType.."_"..(index+1)]
    local nextData = self.data[pType.."_"..(index-1)]
    local lastPage = self:getChildByName("Node_page"):getChildByName("page_last_"..pType)
    local nextPage = self:getChildByName("Node_page"):getChildByName("page_next_"..pType)
    if lastData ~= nil then
    	lastPage:setVisible(true)
    else
        lastPage:setVisible(false)
    end
    if nextData ~= nil then
        nextPage:setVisible(true)
    else
        nextPage:setVisible(false)
    end
end

--获取唯一开始触碰的一个下标
function EmbattleDialog:getBeganIdnex()
    for i = 1, 5, 1 do
        local layer = self["layer" .. i]
        if layer.data.isBegan then
        	return i
        end
    end
    return 0
end

--还原开始触碰
function EmbattleDialog:setBeganFalse()
    for i = 1, 5, 1 do
        local layer = self["layer" .. i]
        layer.data.isBegan = false
    end
end

--点显示区域获取下标选项
function EmbattleDialog:getScollIndex(y)
    local itemHeight = Config.DATA_EMBATTLE_PET_HEIGHT*0.5
    local m = y / itemHeight
    local n = -(m - 1.5)
    return n
end

--获取说明
function EmbattleDialog:setRoleDes(roleData)
    if roleData ~= nil then
        local node = self:getChildByName("Node_des")
        local sprite = node:getChildByName("Sprite_des")
        local text = node:getChildByName("Text_des")
        local framName = Prefix.PREGET_PET_PATH..roleData.type .. PNG
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(framName)
        sprite:setSpriteFrame(frame)
        text:setString(roleData.name .." - " ..  Language.LV .. ":" .. roleData.level .." - " .. Language.POWER.. ":" .. roleData.attack)
        node:stopAllActions()
        node:setOpacity(255)
        node:setVisible(true)
        node:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function()
            node:fadeTo(1.5,0)
        end)))
    end
end

--点显示区域获取类型宠物
function EmbattleDialog:getTouchType(x,y)
    for i = 1, 5, 1 do
        local offsetX1 = 100*(i - 1) + (160 + offSetX)
        local offsetX2 = 100*(i - 1) + (160 + offSetX) + Config.DATA_EMBATTLE_PET_WIDTH
        local offsetY1 = 290
        local offsetY2 = 290+Config.DATA_EMBATTLE_PET_HEIGHT
        if x > offsetX1 and x < offsetX2 then
            if  y > offsetY1 and  y < offsetY2 then
                return i
            end
        end
    end
   return 0
end

return EmbattleDialog
