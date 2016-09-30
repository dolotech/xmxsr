-- 礼包
local GiftDialog = class("GiftDialog",function()
    return cc.CSLoader:createNode("GiftDialog.csb")
end)

function GiftDialog:create()
    local dialog = GiftDialog.new()
    return dialog
end

function GiftDialog:onEnter()
    Color.setLableShadow(self:getChildByName("Text_1"))

    self.giftData = {}
    for key, var in pairs(ShopData) do
        if var.type==4 and DPayCenter.platform==var.platform then
            self.giftData[#self.giftData+1] = var
        end
    end

    self:getChildByName("closeButton"):onClick(function()self:close()end)

    local function scrollViewDidZoom(view)
    end

    --选项大小正方形
    local function cellSizeForTable(view, idx)
        return 260,260
    end

    --创建个数
    local function numberOfCellsInTableView(view)
        return #self.giftData
    end

    local tableView = cc.TableView:create(cc.size(650,780))
    tableView:setBounceable(true)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_BOTTOMUP)
    tableView:setPosition(-285, -420)
    tableView:setDelegate()

    self:addChild(tableView)
    self.tableView = tableView

    tableView:registerScriptHandler(handler(self, self.scrollViewDidScroll), cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
end

function GiftDialog:scrollViewDidScroll(view)

end

function GiftDialog:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local sprite = display.createUI(Csbs.NODE_PACKAGE_CSB)
    sprite:setContentSize(560,240)
    if nil == cell then 
        cell = cc.TableViewCell:create()
    else
        cell:removeAllChildren()
    end
    cell:addChild(sprite)
    self:tableViewCellHandler(sprite,idx+1) 
    return cell
end

--解释礼包数据
function GiftDialog:tableViewCellHandler(ui,idx)  
    if ui==nil then
        return
    end
    local data = self.giftData[idx]
    local button =  ui:getChildByName("Button_1")
    ui:getChildByName("Text_1"):setString(data.des)
    ui:getChildByName("Text_2"):setString(data.title)
    Color.setLableShadows({ui:getChildByName("Text_1"),ui:getChildByName("Text_2")})
    button:setTitleText(data.pay .." "..data.price)

    button:onClick(function()
        DPayCenter.pay(data.productId, function()end, function()end)
    end)

end


return GiftDialog