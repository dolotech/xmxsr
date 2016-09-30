--宠物场景
--author:chenkaixi
local Postion = {["1"]=cc.p(stageWidth*0.5-165,670),["2"]=cc.p(stageWidth*0.5+165,670),["3"]=cc.p(stageWidth*0.5-165,350),["4"]=cc.p(stageWidth*0.5+165,350)}

local PetScene = class("PetScene",function()
    return require("game.view.base.BaseScene"):create()
end)

function PetScene:create()
    local scene = PetScene.new()
    scene:setNodeEventEnabled()
    return scene
end

function PetScene:onCleanup()
    -- unschedulerUpdate(self)
end

--进入
function PetScene:onEnter()
    self.eventHandle = require("game.event.EventHandle").new(self)
    self:initColorLayer()
    self:initPageView()
    self:initMenu()
    self:initButtonHandler()
    self:updateTrainState()
    self:addEventListener(Event.UPDATA_PETUI,handler(self,self.updataUI))

    self.eventHandle:itEventData("hero")
    -- schedulerUpdate(self, handler(self, self.update))
    self:schedule(self.update,0.1)
end

function PetScene:update( _delta )
    self.eventHandle:runEvent(_delta)
end

--事件
function PetScene:GetChildByScene( _tStrs )
    local originalName = table.remove(_tStrs,1)
    local name = originalName..".csb"
    local node = nil
    if(name == "node_colorbg_base.csb")then
        node = self.layerColor:getChildByNameFo(_tStrs)
    elseif(name==Csbs.NODE_MATERIAL_CSB)then
        node = self.meteril:getChildByNameFo(_tStrs)
    elseif(name==Csbs.NODE_DIAMOND_CSB)then
        node = self.rigthTopBtn:getChildByName("Panel_5"):getChildByNameFo(_tStrs)
    elseif(name==Csbs.NODE_RETURN_CSB)then
        node = self.returnBtn:getChildByNameFo(_tStrs)
    elseif(name==Csbs.NODE_POWER_CSB)then
        node = self.leftTopBtn:getChildByNameFo(_tStrs)
    else
        -- node = self.ui:getChildByNameFo(_tStrs)
    end
    print("-------battleScene.GetChildByScene]",originalName,node)
    return node
end

--初始化颜色页面
function PetScene:initColorLayer()
    local layerColor = display.createUI("node_colorbg_base.csb")
    layerColor:stageCenter()
    self:addToBgLayer(layerColor)
    self.layerColor = layerColor
end

--刷新宠物升级条件提示
function PetScene:updateTrainState()
    local tPets,tCount =  RoleDataManager.getPetTrainState(type)
    for k,v in pairs(tPets) do
        local item = self.roleItem[k]
        local node = item:getChildByNameFo("Node_1","Image_3")
        node:setVisible(v)
    end
    --翻页条 
    for i,v in ipairs(tCount) do
        local itemSprite = self.menu:getChildByTag(i)
        local sprite = itemSprite:getNormalImage():getChildByName("sprite")
        sprite:setVisible(v>0)
        local label = sprite:getChildByName("label")
        label:setString(v==0 and "" or tostring(v))
        sprite = itemSprite:getSelectedImage():getChildByName("sprite")
        sprite:setVisible(v>0)
        label = sprite:getChildByName("label")
        label:setString(v==0 and "" or tostring(v))
    end
end

--初始化翻页组件
function PetScene:initPageView(parameters)
    local pageView = ccui.PageView:create()
    pageView:setTouchEnabled(true)
    pageView:setContentSize(cc.size(stageWidth, stageHeight))
    pageView:setAnchorPoint(0,0)
    pageView:setPosition(0,0)
    pageView:setCustomScrollThreshold(cc.Device:getDPI()/3)--翻译灵敏度，设置半英寸(2.54/2 厘米(cm) )
    pageView:setLayoutType(ccui.LayoutType.HORIZONTAL)
    self.pageView = pageView
    self.pageIndex = pageView:getCurPageIndex()
    self.roleItem = {}
    for type=1, Config.DATA_PETTYPE_COUNT do
        self:createItemPage(type)
    end            
    
    local function pageViewEvent(sender, eventType)
        if eventType == ccui.PageViewEventType.turning then
            local index = sender:getCurPageIndex()+1
            for j=1, 5, 1 do
                local itemSprite = self.menu:getChildByTag(j)
                if j==index then
                    itemSprite:selected()
                else
                    itemSprite:unselected()
                end
            end
            
            if pageView:getCurPageIndex()~=self.pageIndex then
                if pageView:getCurPageIndex()>self.pageIndex then
                	self:changePetBg(pageView:getCurPageIndex()+1,1)
                else
                    self:changePetBg(pageView:getCurPageIndex()+1,2)
                end
                self.pageIndex = pageView:getCurPageIndex()
                Audio.playSound(Sound.SOUND_UI_HERO_SLIDE,false)
            end
        end
    end 
    pageView:addEventListener(pageViewEvent)
    self:addToGameLayer(pageView)
    pageView:scrollToPage(self.pageIndex)
    self:changePetBg(self.pageIndex+1,1)
end
--创建page内容
function PetScene:createItemPage(type)
    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(stageWidth, stageHeight))
    layout:setAnchorPoint(0,0)
    layout:setPosition(0,0)
    self.pageView:addPage(layout)

    local pets = RoleDataManager.getPetsDataBuyType(type)
    function getPetForSort( _pets, _sort )
        if(_pets == nil)then return nil end
        for k,v in pairs(_pets) do
            if(v.sort == _sort)then return k,v end
        end
        return 0,nil
    end
    function getPetForRole( _grop )
        for k,v in pairs(RoleData) do
            if(v.grop == _grop and v.level == 1)then return k,v end
        end
        return 0,nil
    end

    local list = self:getPohtoList(type)
    for k,v in pairs(list) do
        local point = Postion[tostring(v.pos)]
        local item = display.createUI(Csbs.NODE_PET_UPLEVEL_CSB)
        item:setName("item")
        item:setPosition(point.x,point.y)
        layout:addChild(item)

        local photo = item:getChildByName("role")
        path = Prefix.PRES_PHOTO .. v.initPhoto ..PNG
        photo:loadTextures(path,path,path,0)

        local node = item:getChildByName("Node_1")
        local btn = node:getChildByName("Button_1")
        Color.setLableShadows({node:getChildByName("Text_1"),node:getChildByName("Text_2")})

        local imgPetBg = item:getChildByName("Image_1")

        local petkey,pet = getPetForSort(pets, v.pos)
        if(pet ~= nil)then--有宠物时
            node:getChildByName("Text_1"):setString(tostring(pet.level))
            node:getChildByName("Text_2"):setString(tostring(pet.name))
            imgPetBg:setColor(cc.c3b(255, 255, 255))
            -- local framName = Prefix.PRECOMM_NNG..pet.type .. PNG
            -- local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(framName)
            if self.pageIndex==0 then self.pageIndex = pet.type-1 end
            self.roleItem[petkey] = item

            local roledata = clone(pet)
            roledata.id = petkey
            
            btn:setTitleColor(cc.c3b(17, 97, 0))
            btn:onClick(function()
                local param = clone(roledata)
                param.funCloseCallBack = function() self:updateTrainState() end
                DialogManager:open(Dialog.drowth,param)
            end,true)
            photo:onClick(function()
                DialogManager:open(Dialog.petInfo,clone(roledata))
            end)
        else--没宠物时
            imgPetBg:setColor(cc.c3b(98, 103, 98))
            petkey,pet = getPetForRole(tonumber(k))
            photo:setColor(cc.c3b(0,0,0))
            node:getChildByName("Text_1"):setString("1")
            node:getChildByName("Text_2"):setString(tostring(pet.name))
            path = Prefix.PRECOMM_NNG .. "5" .. PNG
            btn:loadTextures(path,path,path,1)
            btn:setTitleText(Language.BuyPet_Get)
            self.roleItem[petkey] = item
            local roledata = clone(pet)
            roledata.id = petkey
            btn:setTitleColor(cc.c3b(120, 43, 0))
            btn:onClick(function()
                DialogManager:open(Dialog.buyPet,clone(roledata))
            end,true)
            photo:onClick(function()
                DialogManager:open(Dialog.buyPet,clone(roledata))
            end)
        end
    end
end

--获取默认
function PetScene:getPohtoList(type)
    local list = {}
    for key, var in pairs(GropPhotoData) do
        if type==var.type then
            list[key]=var
    	end
    end
    return list
end

--初始化翻译按钮
function PetScene:initMenu()
    local  menu = cc.Menu:create()
    menu:alignItemsHorizontally()
    menu:stageLeftBottom(0,70)
    self.menu = menu
    local function handlerItem(index,param)
        local idx = 1
        for i=1, 5, 1 do
            local itemSprite = menu:getChildByTag(i)
            if itemSprite==param then
                itemSprite:selected()
                idx = i
            else
                itemSprite:unselected()
            end
        end
        self.pageView:scrollToPage(idx-1)

        if self.pageView:getCurPageIndex()~=self.pageIndex then
            if self.pageView:getCurPageIndex()>self.pageIndex then
                self:changePetBg(self.pageView:getCurPageIndex()+1,1)
            else
                self:changePetBg(self.pageView:getCurPageIndex()+1,2)
            end
            self.pageIndex =  self.pageView:getCurPageIndex()
            Audio.playSound(Sound.SOUND_UI_HERO_SLIDE,false)
        end
    end
    
    for i=1, Config.DATA_PETTYPE_COUNT, 1 do
        
        local  spriteNormal = self:createMenuItem(i)
        local  spriteSelected = self:createMenuItem(i)
        spriteSelected:getChildByName("Mask_1"):setVisible(false)
        
        local  item = cc.MenuItemSprite:create(spriteNormal, spriteSelected)
        if i==1 then
            item:selected()
        end
        item:setPosition((i-1)*90+190+offSetX,0)--适配宽
        item:setTag(i)
        menu:addChild(item)
        item:registerScriptTapHandler(handlerItem)
    end
    self:addToUILayer(menu)
end

function PetScene:createMenuItem(type)
    local  item = ccui.Scale9Sprite:createWithSpriteFrameName(Prefix.PRECOMM_NNG..type..PNG)
    item:setContentSize(80,80)
    
    local iamge = cc.Sprite:createWithSpriteFrameName(Prefix.PREGET_PET_PATH..type..PNG)
    iamge:setScale(0.8)
    iamge:setPosition(40,40)
    iamge:setName("role")
    item:addChild(iamge)
    
    local mask = ccui.Scale9Sprite:createWithSpriteFrameName(Picture.RES_UI_BG_PNG)
    mask:setContentSize(80,80)
    mask:setName("Mask_1")
    mask:setPosition(40,40)
    item:addChild(mask)

    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(Prefix.PREMOVES_NNG .. 1 .. PNG)
    local sp = cc.Sprite:create()
    sp:setSpriteFrame(frame)
    sp:setName("sprite")
    sp:setScale(0.5)
    sp:setVisible(false)
    sp:setPosition(40, 80)
    item:addChild(sp)

    local ttfConfig = {}
    ttfConfig.fontFilePath =FONT_FZZT_TTF
    ttfConfig.fontSize = 70
    ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
    ttfConfig.customGlyphs = nil
    ttfConfig.distanceFieldEnabled = true
    ttfConfig.color = cc.c3b(66 , 95, 0)
    local textLable = cc.Label:createWithTTF(ttfConfig,"",cc.TEXT_ALIGNMENT_CENTER)
    -- textLable:enableShadow()
    textLable:setName("label")
    textLable:setTextColor(cc.c4b(66 , 95, 0, 255))
    textLable:setAnchorPoint(cc.p(0.5,0.5))
    textLable:setPosition(30, 31)
    sp:addChild(textLable)

   return item
end

--改变宠物背景
--type 1右边 2左边
function PetScene:changePetBg(index,type)

    self.layerColor:stopAllActions()
    local color1,color2 = nil,nil
    color1 = Color.BgColor2[index]
    if type==1 then
         color2 = Color.BgColor2[index-1]
    else
         color2 = Color.BgColor2[index+1]
    end
    if(color2 == nil)then color2 = color1 end
    
    self.layerColor:getChildByName("imgBg1"):setColor(color1[1])
    self.layerColor:getChildByName("imgBg2"):setColor(color2[1])

    self.layerColor:getChildByName("imgBg2"):setOpacity(255)
    self.layerColor:getChildByName("imgBg2"):fadeTo(0.4,0)
end

--更新UI
function PetScene:updataUI(event)
    local id = event._userdata.id
    local roleData = event._userdata.roleData
    local item = self.roleItem[id]
    self.roleItem[id] = nil
    self.roleItem[roleData.id] = item
    
    local photo = item:getChildByName("role")
    local path = Prefix.PRES_PHOTO .. roleData.photo ..PNG
    photo:loadTextures(path,path,path,0)
    
    --更新信息
    local node = item:getChildByName("Node_1")
    node:getChildByName("Button_1"):onClick(function()
        DialogManager:open(Dialog.drowth,clone(roleData))
    end,true)
    photo:onClick(function()
        DialogManager:open(Dialog.petInfo,clone(roleData))
    end)
    
    node:getChildByName("Text_1"):setString(tostring(roleData.level))
    node:getChildByName("Text_2"):setString(tostring(roleData.name))
    photo:setColor(cc.c3b(255,255,255))
    path = Prefix.PRECOMM_NNG .. "3" .. PNG
    node:getChildByName("Button_1"):loadTextures(path, path, path, 1)
    node:getChildByName("Button_1"):setTitleText(Language.Level_Up)
    node:getChildByName("Button_1"):setTitleColor(cc.c3b(17, 97, 0))
    item:getChildByName("Image_1"):setColor(cc.c3b(255, 255, 255))

    self:updateTrainState()
end

--按钮事件操作
function PetScene:initButtonHandler()

    --体力
    local leftTopBtn = require("game.view.comm.PowerBar"):create()
    leftTopBtn:stageLeftTop()
    self:addToUILayer(leftTopBtn)
    self.leftTopBtn = leftTopBtn
    
    --升级材料
    local meteril = display.createUI(Csbs.NODE_MATERIAL_CSB)
    meteril:stageTop()
    self:addToUILayer(meteril)
    self.meteril = meteril
    meteril:getChildByName("Text_1"):setString(tostring(SharedManager:readData(Config.YELLOW)))
    meteril:getChildByName("Text_2"):setString(tostring(SharedManager:readData(Config.BLUE)))

    local rigthTopBtn = display.createUI(Csbs.NODE_DIAMOND_CSB)
    rigthTopBtn:stageRightTop()
    self:addToUILayer(rigthTopBtn)
    self.rigthTopBtn = rigthTopBtn
    
    --钻石
    rigthTopBtn:getChildByNameFo("Panel_5","Text_1"):setString(tostring(SharedManager:readData(Config.DIAMOND)))
    rigthTopBtn:getChildByNameFo("Panel_5","Button_1"):onClick(function() DialogManager:open(Dialog.Diamond)end, true)
--    rigthTopBtn:getChildByName("Button_2"):onClick(function() DialogManager:open(Dialog.Diamond)end, true)
    
    --返回
    local returnBtn = display.createUI(Csbs.NODE_RETURN_CSB)
    returnBtn:stageRightBottom(-70,70)
    returnBtn:getChildByName("Button_1"):onClick(function()SceneManager.changeScene(Scene.City)end, true, true,Sound.SOUND_UI_MAP_BACK)
    self:addToDialogLayer(returnBtn)
    self.returnBtn = returnBtn
    
   --监听更新数据
    
    self:addEventListener(Event.UPDATA_DIAMOND,function() 
        rigthTopBtn:getChildByNameFo("Panel_5","Text_1"):setString(tostring(SharedManager:readData(Config.DIAMOND)))
    end)

    self:addEventListener(Event.UPDATA_YELLOW,function() 
        meteril:getChildByName("Text_1"):setString(tostring(SharedManager:readData(Config.YELLOW)))
    end)

    self:addEventListener(Event.UPDATA_BLUE,function() 
        meteril:getChildByName("Text_2"):setString(tostring(SharedManager:readData(Config.BLUE)))
    end)
    
    Color.setLableShadows({
        meteril:getChildByName("Text_1"),
        meteril:getChildByName("Text_2"),
        rigthTopBtn:getChildByNameFo("Panel_5","Text_1"),
    })
end

return PetScene
