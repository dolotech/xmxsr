
--主场景(关卡展示)
--author:chenkaixi
require("socket")
local cityScene = class("CityScene",function()
    return require("game.view.base.BaseScene"):create()
end)
local umengInterFace = require("src.sdk.umengInterFace")
local shareBtn = nil
require("game.view.dataCenter.UserAccountDataCenter")
require("game.view.dataCenter.FriendDataCenter")
function cityScene:create(param)
    local scene = cityScene.new(param)
    scene:setNodeEventEnabled()
    return scene
end
function cityScene:onCleanup()
--  SceneManager.renmoveCache()
    -- unschedulerUpdate(self)
end

function cityScene:onEnter()
    self.eventHandle = require("game.event.EventHandle").new(self)
    self:initMapView()
    self:initTableView()
    self:initButtonHandler()
    self:initMueuButton()
    
--    self:addEventListener(Event.UPDATA_DIAMOND,function() 
    --        self.mueuBtn1:getChildByName("Text_1"):setString(SharedManager:readData(Config.Star).count .. "/" .. (SharedManager:readData(Config.POINT) * 3))
--    end)
    self.mueu_Btn1:getChildByName("Text_1"):setString(SharedManager:readData(Config.Star).count .. "/" .. ((SharedManager:readData(Config.POINT) - 1001) * 3))
    self.mueu_Btn1:onClick(function() DialogManager:open(Dialog.showPoint) end)
    
    if Audio.currentBGM ~= Sound.MUSIC_MAP_BGM then
        Audio.playMusic(Sound.MUSIC_MAP_BGM ,true)   
    end
    
    local power = SharedManager:readData(Config.POWER)
    if power <= 3 then
        TipsManager:ShowText(Language.Game_Cattle_X, nil, 26) --你目前的体力很少了
        self:performWithDelay(function() DialogManager:open(Dialog.power) end, 1.2)
    end

    local _isNo1 = SharedManager:readData(Config.isNo)
    if self.curPoint > 1005 and _isNo1 < 1 then
        TipsManager:ShowText(Language.Come_Buy_Packs, nil, 26) --快来购买个新手礼包吧...
        self:performWithDelay(function()DialogManager:open(Dialog.fristGift)end, 0.6)
        SharedManager:saveData(Config.isNo, 1, true)
    elseif self.curPoint > 1006 and _isNo1 < 2 then
        TipsManager:ShowText(Language.Cong_Samsung_buy, nil, 26) --恭喜获得“三星礼包”购买权...
        self:performWithDelay(function()DialogManager:open(Dialog.fristGiftStar)end, 0.6)
        SharedManager:saveData(Config.isNo, 2, true)
    end
    
    self.eventHandle:itEventData("city")
    self:schedule(self.update,0.1)

    -- schedulerUpdate(self, handler(self, self.update))

    -- print("-------seri:",seri,type(seri))
end

function cityScene:update( _delta )
    self.eventHandle:runEvent(_delta)
end

--事件
function cityScene:event( _event )
    if(_event.name == "finger")then
        self.fingerSprite:setVisible(_event.visible==1 and true or false)
    end
end

local tMapList = {}
function cityScene:GetChildByScene( _tStrs )
    local originalName = table.remove(_tStrs,1)
    local name = originalName..".csb"
    if(name == "node_menu1_base.csb")then
        return self.mueuBtn1:getChildByNameFo(_tStrs)
    elseif(name=="node_menu2_base.csb")then
        return self.mueuBtn2:getChildByNameFo(_tStrs)
    elseif(name==Csbs.NODE_LEFT_CSB)then
        return self.leftBtn:getChildByNameFo(_tStrs)
    elseif(name==Csbs.NODE_RIGHT_CSB)then
        return self.rightBtn:getChildByNameFo(_tStrs)
    else
        local strs = string.split(originalName, "_")
        if(strs[1]=="map")then
            for k,v in pairs(tMapList) do
                if(k == strs[2])then
                    return v:getChildByNameFo(_tStrs)
                end
            end
        end
    end
end

--构建函数
function cityScene:ctor(param)
    -- self.eventHandle = require("game.event.EventHandle").new(self)
    -- self:initMapView()
    -- self:initTableView()
    -- self:initButtonHandler()
    -- self:initMueuButton()
end

--初始化地图csb
function cityScene:initMapView()
    for k,v in pairs(MapData) do
        if(v.point == nil)then 
            v.point = {}
            local mapId = "10" .. string.format("%02d", tonumber(k))
            local node = display.createUI(Prefix.PREMAP_CSB .. mapId .. CSB)
            for chapterId = v.scope.a, v.scope.b do
                local x,y = node:getChildByName("chapter_" .. chapterId):getPosition()
                v.point[chapterId] = cc.p(x,y)
            end
        end
    end
end

--初始化功能按钮
function cityScene:initMueuButton()
    local mueuBtn1 = display.createUI("node_menu1_base.csb")
    mueuBtn1:stageRightTop(-5, -300)
    self:addToUILayer(mueuBtn1)
    self.mueu_Btn1 = mueuBtn1:getChildByName("Panel_1")
    self.mueuBtn1 = mueuBtn1
    
    local mueuBtn2 = display.createUI("node_menu2_base.csb")
    mueuBtn2:stageLeftTop(3, -220)
    self:addToUILayer(mueuBtn2)
    self.mueuBtn2 = mueuBtn2
       	
    --签到
    local from = os.time()
    local data = SharedManager:readData(Config.Sign)
    local to = os.time(data.date)
    local bool = false  --判断是否禁用按钮
    if (from - to) >= 0 then
        tween.RepeatScale(mueuBtn1:getChildByName("Button_1"),1,1,1.15)
        tween.RepeatScale(mueuBtn1:getChildByName("Button_4"),1,1,1.15)
    else
        mueuBtn1:getChildByName("Button_1"):stopAllActions()
        mueuBtn1:getChildByName("Button_1"):setScale(1)
        mueuBtn1:getChildByName("Button_4"):stopAllActions()
        mueuBtn1:getChildByName("Button_4"):setScale(1)
    end
    
    mueuBtn1:getChildByName("Button_1"):onClick(function()
        DialogManager:open(Dialog.sign)
    end)
    
    mueuBtn1:getChildByName("Button_4"):onClick(function()
        DialogManager:open(Dialog.star)
    end)

    --免费钻石广告
    local from = os.time()
    local data = SharedManager:readData(Config.PingCoo)
    local to = os.time(data.date)
    local bool = false  --判断是否禁用按钮
    if (from - to) >= 0 then --另一天
        local from = os.time()
        local curTab = os.date("*t")
        local toDate = os.date("*t")
        toDate.year = curTab.year
        toDate.month = curTab.month
        toDate.day = curTab.day
        toDate.hour = 24
        toDate.min = 0
        toDate.sec = 0
        local to = os.time(toDate) 
        local date = os.date("*t",to)
        local time = from - to

        data.date = date
        data.time = time
        data.times = 8
        --保存更新信息
        SharedManager:saveData(Config.PingCoo,data,true)
        tween.RepeatScale(mueuBtn1:getChildByName("Button_2"), 1, 1, 1.15)
    else
        if data.times > 0 then
            tween.RepeatScale(mueuBtn1:getChildByName("Button_2"), 1 ,1, 1.15)
        else
            mueuBtn1:getChildByName("Button_2"):stopAllActions()
            mueuBtn1:getChildByName("Button_2"):setScale(1)
        end
    end

    mueuBtn1:getChildByName("Button_2"):onClick(function()
        DialogManager:open(Dialog.pingcoo)
    end)
   -- mueuBtn1:getChildByName("Button_2"):setVisible(device.platform ~= "ios")
    mueuBtn1:getChildByName("Button_2"):setVisible(false)
    
    --首次特惠礼包
    local fristData = SharedManager:readData(Config.isFrist)
    local isfristTopData = SharedManager:readData(Config.isfristTop)
    if fristData.frist == 0 then
        mueuBtn2:getChildByName("Button_3"):setVisible(true)
        tween.RepeatScale(mueuBtn2:getChildByName("Button_1"), 1, 1, 1.15)
     else
        mueuBtn2:getChildByName("Button_3"):setVisible(false)
     end  
        
    if fristData.fristStar == 0 then
        mueuBtn2:getChildByName("Button_2"):setVisible(true)
        tween.RepeatScale(mueuBtn2:getChildByName("Button_2"), 1, 1, 1.15)
    else
        mueuBtn2:getChildByName("Button_2"):setVisible(false)
    end
    
    if isfristTopData == 0 then 
        mueuBtn2:getChildByName("Button_1"):setVisible(true)
        tween.RepeatScale(mueuBtn2:getChildByName("Button_3"), 1, 1, 1.15)
    else
        mueuBtn2:getChildByName("Button_1"):setVisible(false)
    end
    
    mueuBtn2:getChildByName("Button_4"):setVisible(true)
    tween.RepeatScale(mueuBtn2:getChildByName("Button_4"), 1, 1, 1.15)
        
    --首冲礼包
    mueuBtn2:getChildByName("Button_1"):onClick(function()
        DialogManager:open(Dialog.fristGiftTop)
    end)

    --三星礼包
    mueuBtn2:getChildByName("Button_2"):onClick(function()
        DialogManager:open(Dialog.fristGiftStar)
    end)
    
    --新手礼包
    mueuBtn2:getChildByName("Button_3"):onClick(function()
        DialogManager:open(Dialog.fristGift)
    end)
    
    --测试礼包
    mueuBtn2:getChildByName("Button_4"):onClick(function()
        DPayCenter.pay(10086)
    end)
    mueuBtn2:getChildByName("Button_4"):setVisible(false) --隐藏价格

    self.mueuBtn1 = mueuBtn1
    self.mueuBtn2 = mueuBtn2

    self:addEventListener(Event.UPDATA_SGIN_UI, handler(self, self.stopmueuBtn1Handler))
    self:addEventListener(Event.UPDATA_FRISTGIFT_UI, handler(self, self.stopMueuFristGiftHandler))
    self:addEventListener(Event.UPDATA_FRISTGIFT_UI_Star, handler(self, self.stopMueuFristGiftStarHandler))
    self:addEventListener(Event.UPDATA_FRISTGIFT_UI_Top, handler(self, self.stopMueuFristGiftTopHandler))
    self:addEventListener(Event.UPDATA_PINGCOO_UI, handler(self, self.updatePingCooHandler))
end

--通知提示Button_1
function cityScene:stopmueuBtn1Handler()
    self.mueuBtn1:getChildByName("Button_1"):stopAllActions()
    self.mueuBtn1:getChildByName("Button_1"):setScale(1)
end

--通知提示Button_2
function cityScene:updatePingCooHandler()
    local data = SharedManager:readData(Config.PingCoo)
    if data.times > 0 then
        tween.RepeatScale(self.mueuBtn1:getChildByName("Button_2"), 1, 1, 1.15)
    else
        self.mueuBtn1:getChildByName("Button_2"):stopAllActions()
        self.mueuBtn1:getChildByName("Button_2"):setScale(1)
    end
end

--通知提示Button_1  首冲礼包
function cityScene:stopMueuFristGiftHandler()
    self.mueuBtn2:getChildByName("Button_3"):stopAllActions()
    self.mueuBtn2:getChildByName("Button_3"):setScale(1)
    self.mueuBtn2:getChildByName("Button_3"):setVisible(false)
end

--通知提示Button_2  三星礼包按钮
function cityScene:stopMueuFristGiftStarHandler()
    self.mueuBtn2:getChildByName("Button_2"):stopAllActions()
    self.mueuBtn2:getChildByName("Button_2"):setScale(1)
    self.mueuBtn2:getChildByName("Button_2"):setVisible(false)
end

--通知提示Button_2  首冲礼包按钮
function cityScene:stopMueuFristGiftTopHandler()
    self.mueuBtn2:getChildByName("Button_1"):stopAllActions()
    self.mueuBtn2:getChildByName("Button_1"):setScale(1)
    self.mueuBtn2:getChildByName("Button_1"):setVisible(false)
end

-- 滚动时禁止拖动到尽头
local iSpringback_ = 0
function cityScene:scrollViewDidScroll(view)
    local off = view:getContentOffset()
    if (off.y < view:minContainerOffset().y) then
        view:setContentOffset(cc.p(off.x, view:minContainerOffset().y))
    end

    if (off.y > view:maxContainerOffset().y) then
        view:setContentOffset(cc.p(off.x, view:maxContainerOffset().y))
    end

    -- if(off.y < iSpringback_)
end

--初始化滚动容器
function cityScene:initTableView()
    local function scrollViewDidZoom(view)
    end
    
    --选项大小正方形
    local function cellSizeForTable(view, idx)
        return Config.DATA_MAP_LAYER_HEIGHT, Config.DATA_MAP_LAYER_HEIGHT
    end
    
    --创建 Map个数
    local len = table.nums(MapData)
    local function numberOfCellsInTableView(view)
        return len
    end
    self.curPoint = SharedManager:readData(Config.POINT)
    local tableView = cc.TableView:create(cc.size(stageWidth, stageHeight))
    tableView:setBounceable(true)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_BOTTOMUP)
    tableView:setPosition(0,0)
    tableView:setDelegate()
    
    self:addToUILayer(tableView)
    self.tableView = tableView
    tableView:registerScriptHandler(handler(self, self.scrollViewDidScroll), cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    local off = tableView:getContentOffset()
    tableView:setContentOffset(cc.p(off.x, self:mapIndexOffsetY()))
    -- off = tableView:getContentOffset()

    --添加左右两边的黑边
    local image = ccui.ImageView:create()
    image:stageRight()
    image:loadTexture("ui/picture/bg_heibianzezhao.png")
    local size = image:getContentSize()
    image:setScaleY(stageHeight/size.height)
    self:addToUILayer(image)
    
    image = image:clone()
    image:setFlippedX(true)
    image:stageLeft(size.width)
    
    self:addToUILayer(image)
end

--获取地图index
function cityScene:mapIndexOffsetY()
    local selChapter = Global.selChapterId == nil and self.curPoint or Global.selChapterId
    for key, var in pairs(MapData) do
        for chapter = var.scope.a, var.scope.b, 1 do
            if chapter == selChapter then
                local offY = - (key - 1) * Config.DATA_MAP_LAYER_HEIGHT - var.point[chapter].y + stageHeight/2
                iSpringback_ = offY 
                return offY
            end
        end
    end
    return 0
end

--创建选项方法
function cityScene:tableCellAtIndex(view, idx)
    local mapId = "10" .. string.format("%02d", idx + 1)
    local node = display.createUI(Prefix.PREMAP_CSB .. mapId .. CSB)
    self:tableViewCellHandler(node, tostring(idx + 1))
    node:stageBottom()

    local cell = view:dequeueCell()
    if nil == cell then 
        cell = cc.TableViewCell:create()
    else
        tMapList[cell.mapId] = nil
        cell:removeAllChildren()
    end
    tMapList[mapId] = node
    cell.mapId = mapId
    cell:addChild(node)
    return cell
end

--解释每一张地图
function cityScene:tableViewCellHandler( ui, key )
    -- Global.lastPoint = self.curPoint - 1
    if ui == nil then return end
    local mapdata = MapData[key]
    for chapterId = mapdata.scope.a, mapdata.scope.b do
        local tollgateData = TollgateData[tostring(chapterId)]
        local chapter = ui:getChildByName("chapter_" .. chapterId)
        local tVar= {
            btn = chapter:getChildByName("Button_1"),
            label = chapter:getChildByName("Text_1"),
            imgHead = chapter:getChildByName("Image_1"):getChildByName("Sprite_1"),
            imgLock = chapter:getChildByName("Image_lock")
        }
        Color.setLableShadow(tVar.label)
        tVar.label:setString(tollgateData.pointNum)

        if self.curPoint > chapterId then --可以进入关卡
            self:tableViewCell_enterble(tVar,chapter,chapterId)
        elseif self.curPoint == chapterId then --当前开启的关卡
            self:tableViewCell_current(tVar,chapter,chapterId)
        else --没有开启的关卡 
            self:tableViewCell_notEnter(tVar,chapter,chapterId)
        end
        tVar = nil
    end
end

function cityScene:tableViewCell_enterble( _tVar, _chapter, _iChapterId )
    local function _setStarVisible( _idx, _bool )
        _chapter:getChildByName("Image_star".._idx):setVisible(_bool)
        _chapter:getChildByName("Image_starBg".._idx):setVisible(_bool)
    end
    local iStar = SharedManager:readData(tostring(_iChapterId), Config.POINT_DATA_DUALFT).star
    if(_iChapterId == Global.lastPoint)then --过关动画设置
        local finger = self.eventHandle:getFinger(_chapter)
        self.eventHandle:setFinger(finger, cc.pAdd(cc.p(finger:getPosition()), cc.p(0,50)), 0)

        local spr = cc.Sprite:create()
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("ui/map_dian_03.png")
        spr:setSpriteFrame(frame)
        _tVar.btn:addChildWithAnchor(spr)
        finger:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3,0),cc.CallFunc:create(function()
            finger:removeFromParent()
            spr:runAction(cc.Sequence:create(cc.FadeOut:create(0.5),cc.CallFunc:create(function()
                spr:removeFromParent()
            end)))
            local n,tlist = 0,{}
            for i = 1, iStar do
                n=n+1 tlist[n] = cc.DelayTime:create(0.2 * i)
                n=n+1 tlist[n] = cc.CallFunc:create(function()
                    local starEff = display.createEffect(Prefix.PREOPE_COMPLETE_NAME, "effect_complete_02", function()
                        _setStarVisible(i, true)
                    end, true, true)
                    starEff:setPosition(_chapter:getChildByName("Image_star"..i):getPosition())
                    starEff:setScale(0.25)
                    _chapter:addChild(starEff)
                end)
            end
            _chapter:runAction(cc.Sequence:create(tlist))
        end)))
    else--显示星星
        for i = 1, iStar do _setStarVisible(i, true) end
    end
    _tVar.btn:onClick(function() 
        Global.selChapterId = _iChapterId
        DialogManager:open(Dialog.Embattle,{Id = _iChapterId, isTween = true}) 
    end)
    -- self:onClickHandler(_tVar.btn, self.clickTollgate)
end

function cityScene:tableViewCell_current( _tVar, _chapter, _iChapterId )
    _tVar.btn:loadTextureNormal("ui/map_dian_03.png", ccui.TextureResType.plistType)
    self.fingerSprite = self.eventHandle:getFinger(_chapter)
    -- tween.RepeatRotate(self.fingerSprite, 1, 0, 720)
    self.eventHandle:setFinger(self.fingerSprite, cc.pAdd(cc.p(self.fingerSprite:getPosition()), cc.p(0,50)), 0)
    -- self.fingerSprite:setVisible(false)

    if(self.curPoint ~= Global.lastPoint)then --过关动画设置
        local spr = cc.Sprite:create()
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("ui/map_dian_02.png")
        spr:setSpriteFrame(frame)
        _tVar.btn:addChildWithAnchor(spr)

        local iStar = SharedManager:readData(tostring(_iChapterId), Config.POINT_DATA_DUALFT).star
        self.fingerSprite:setScale(0)
        
        spr:runAction(cc.Sequence:create(
            cc.DelayTime:create(2+(iStar*0.3)),
            cc.FadeOut:create(0.5),
            cc.CallFunc:create(function()
                spr:removeFromParent()       
                self.fingerSprite:runAction(cc.Sequence:create(
                    cc.ScaleTo:create(0.3,1)
                ))
            end)
        ))
    end

    --检测关卡是否解锁了 锁的图标
    local bool = SharedManager:readData(tostring(_iChapterId), Config.POINT_DATA_DUALFT).isOpen
    local tollgate = TollgateData[tostring(_iChapterId)]
    if not bool and tollgate.condition then
        _tVar.imgLock:setVisible(true)
        _tVar.btn:onClick(function()
            Global.selChapterId = _iChapterId
            local data = {
                point = self.curPoint,
                bool = RoleDataManager:getRoleCondition(tollgate.condition),
                num = tollgate.condition[1],
                lv = tollgate.condition[2],
                image = _chapter:getChildByName("Image_lock"),
                chapter = {Id = _iChapterId, isTween = true}
            }
            DialogManager:open(Dialog.tollgate, data)
        end)
    elseif not bool and tollgate.star then
        _tVar.imgLock:setVisible(true)
        _tVar.btn:onClick(function()
            Global.selChapterId = _iChapterId
            local b = false
            if tollgate.star <= SharedManager:readData(Config.Star).count then b = true  end
            local data = {
                point = self.curPoint,
                bool = b,
                num = tollgate.star,--tollgate.condition[1],
                image = _chapter:getChildByName("Image_lock"),
                _chapter = {Id = _iChapterId, isTween = true}
            }
            DialogManager:open(Dialog.tollgatestar, data)
        end)
    else
        _tVar.btn:onClick(function()
            Global.selChapterId = _iChapterId
            UserAccountDataCenter.isNewBattle = true
            DialogManager:open(Dialog.Embattle,{Id = _iChapterId, isTween = true}) 
        end)
    end
    Global.lastPoint = self.curPoint
end

function cityScene:tableViewCell_notEnter( _tVar, _chapter, _iChapterId )
    _tVar.btn:setBright(false)
    _tVar.btn:setTouchEnabled(true)
    -- _tVar.label:setColor(Color.chapterColor) --设置节点颜色
    _tVar.label:setVisible(false)
    -- _tVar.btn:loadTextureNormal("ui/map_dian_01.png", ccui.TextureResType.plistType)

    -- self:onClickHandler(_tVar.btn, function() TipsManager:ShowText(Language.Chapter_No_Open) end)
    _tVar.btn:onClick(function()
        TipsManager:ShowText(Language.Chapter_No_Open) 
    end)
end

--点击操作
function cityScene:onClickHandler(button,touchEndedHandler)
    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        
        if cc.rectContainsPoint(rect, locationInNode) then
            self.target = target
             Audio.playSound(Sound.SOUND_UI_MAP_CLICK)
             self.offset = self.tableView:getContentOffset().y
              target:runAction(cc.ScaleTo:create(0.05,0.8))
            return true
        end
        return false
    end

    local function onTouchMoved(touch, event)
        local target = event:getCurrentTarget()
         if math.abs(self.offset - self.tableView:getContentOffset().y) > 12 then
                target:runAction(cc.ScaleTo:create(0.05,1))
                self.moved = true
         end
    end

    local function touchHandler()
        if touchEndedHandler ~= nil then
            touchEndedHandler(target)
        end
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        if touchEndedHandler~=nil then
            if self.target == target  then
                if not self.moved then
                    button:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05, 1),cc.CallFunc:create(touchHandler)))
                end
            end
        end
      self.moved = false
    end
    
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = button:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener:clone(), button)
end

--创建文本
function cityScene:createText(text)
    local ttfConfig = {}
    ttfConfig.fontFilePath =FONT_FZZT_TTF
    ttfConfig.fontSize = 20
    ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
    ttfConfig.customGlyphs = nil
    ttfConfig.distanceFieldEnabled = true
    ttfConfig.outlineSize = 2
    local textLable = cc.Label:createWithTTF(ttfConfig,text,cc.TEXT_ALIGNMENT_CENTER)
    textLable:setTextColor(cc.c4b(255,255,255,255))
    return textLable
end

--按钮事件操作
function cityScene:initButtonHandler()
    local bgSprite = cc.Sprite:create(Picture.RES_CITY_BG_PNG)
    bgSprite:stageTop()
    self:addToUILayer(bgSprite)
    
    local leftBtn = display.createUI(Csbs.NODE_LEFT_CSB)
    leftBtn:stageLeftBottom()
    self:addToUILayer(leftBtn)
    self.leftBtn = leftBtn
    --设置
    leftBtn:getChildByName("Button_1"):onClick(function() DialogManager:open(Dialog.Setting) end, true)
    --好友
    leftBtn:getChildByName("Button_3"):onClick(function() serverinterface.MsgDoneById(serverinterface.GETFRIEND,FriendDataCenter.msgDone,FriendDataCenter.msgDone1) end, true)
    --umeng
    shareBtn = leftBtn:getChildByName("Button_2")
    self:showumengBtn()
    
    local rigthBtn = display.createUI(Csbs.NODE_RIGHT_CSB)
    self:addToUILayer(rigthBtn)
    rigthBtn:stageRightBottom()
    self.rightBtn = rigthBtn

    --宠物
    rigthBtn:getChildByName("Button_1"):onClick(function()SceneManager.changeScene("game.view.scene.PetScene")end, true, true, Sound.SOUND_UI_HERO_SLIDE)
    --key  
    rigthBtn:getChildByName("Button_2"):onClick(function()SceneManager.changeScene("game.view.scene.KeyScene")end, true, true, Sound.SOUND_UI_LOTTERY_POPUP)
    --背包
    rigthBtn:getChildByName("Button_3"):onClick(function() DialogManager:open(Dialog.playPack) end)
   
    local key,count = SharedManager:readData(Config.KEY),0
    local tpets,tcount = RoleDataManager.getPetTrainState()
    for i,v in ipairs(tcount) do count = count + v end
    rigthBtn:getChildByName("Node_1"):getChildByName("Text"):setString(tostring(count))
    rigthBtn:getChildByName("Node_1"):setVisible(self.curPoint > 1003 and count > 0)
    rigthBtn:getChildByName("Button_1"):setVisible(self.curPoint > 1003)

    rigthBtn:getChildByName("Node_2"):getChildByName("Text"):setString(tostring(key))
    rigthBtn:getChildByName("Node_2"):setVisible(self.curPoint > Config.OPEN_KEY_POINT and key > 0)
    rigthBtn:getChildByName("Button_2"):setVisible(self.curPoint > Config.OPEN_KEY_POINT)
    -------------------------------------------------------------------------------------------------------------------------------
  
    --体力
    local leftTopBtn = require("game.view.comm.PowerBar"):create()
    leftTopBtn:stageLeftTop()
    self:addToUILayer(leftTopBtn)

    local rigthTopBtn = display.createUI(Csbs.NODE_DIAMOND_CSB)
    rigthTopBtn:stageRightTop()
    self:addToUILayer(rigthTopBtn)
 --钻石
    rigthTopBtn = rigthTopBtn:getChildByName("Panel_5")
    rigthTopBtn:getChildByName("Text_1"):setString(tostring(SharedManager:readData(Config.DIAMOND)))
    Color.setLableShadow(rigthTopBtn:getChildByName("Text_1"))
    rigthTopBtn:onClick(function() DialogManager:open(Dialog.shop,{["num"] = 1})end, true)
    --rigthTopBtn:getChildByName("Button_2"):onClick(function() DialogManager:open(Dialog.Diamond)end, true)
    self:addEventListener(Event.UPDATA_DIAMOND,function() 
        rigthTopBtn:getChildByName("Text_1"):setString(tostring(SharedManager:readData(Config.DIAMOND)))
    end)
end

function cityScene:showumengBtn()
    if DPayCenter.isOpenUmeng == false then 
        shareBtn:setVisible(false)
    else
        local isMainShare = SharedManager:readData(Config.isMainShare)
        shareBtn:setVisible(true)
        if isMainShare == 0 then
            shareBtn:onClick(function() 
                umengInterFace:setShareContent("mainShareImage",handler(self,self.javaCall_HideShareBtn))
                umengInterFace:openUmeng()
            end, true)
            shareBtn:setVisible(true)
        else
            shareBtn:setVisible(false)
        end
    end
end

function cityScene:javaCall_HideShareBtn(value)
    shareBtn:setVisible(false)
    SharedManager:saveData(Config.isMainShare,1,true)
end


return cityScene


