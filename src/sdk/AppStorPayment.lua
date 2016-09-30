
--[[   
  
  苹果商店支付
]]


local AppStorPayment = class("AppStorPayment")
local Store = import("framework.cc.sdk.Store")
productsData = {}

function AppStorPayment:init()
    dump("AppStorPayment:init")
     --初始化商店
    if table.nums(productsData) == 0 then
      Store.init(handler(self, self.storeCallback))
    end
    local getData = {}
    for key, var in pairs(ShopData) do
        if var.platform == DPayCenter.platform then--是否是ios iosft
           getData[#getData+1] = var.payCode
        end
    end 
    --载入商品
    Store.loadProducts(getData, handler(self, self.loadCallback))
end

 --处理购买中的事件回调，如购买成功
function AppStorPayment:storeCallback(transaction)
    dump(transaction.transaction)
    if transaction.transaction.state == "purchased" then
      Store.finishTransaction(transaction.transaction)
    elseif transaction.transaction.state == "cancelled" or transaction.transaction.state == "failed" then
    end
    if self.callBack then
        self.callBack(transaction.transaction.state)
    end
end
 
---载入商品的回调
function AppStorPayment:loadCallback(productsData)
    --返回商品列表
    productsData = productsData
    self:handlerProducts(productsData)
    dump(productsData)
end

--处理数据
function AppStorPayment:handlerProducts(productsData)
   local products = productsData.products
   for key1, var1 in pairs(products) do
       for key2, var2 in pairs(ShopData) do
           if var2.platform == DPayCenter.platform then--是否是ios iosft
               if tostring(var2.payCode)==var1.productIdentifier then--是否对应商品ID
                    --修改价格显示
                    local price = tostring(var1.price)+"00"
                    local split = string.split(price,".")
                    local f1 = tonumber(string.sub(split[2],1,1))
                    local f2 = tonumber(string.sub(split[2],2,2))
                    local f3 = tonumber(string.sub(split[2],3,3))
                    if f3>=5 and f2<9 then
                       f2 = f2+1
                    end
                    price = split[1] .. "." .. f1 .. f2
                    var2.price = tonumber(price)
                    --修改货币标识符
                    var2.pay = string.split(var1.priceLocale,"=")[2]
               end
           end
       end
   end	   
end

--平台支付
function AppStorPayment:payment(payCode,callBack)
    Store.purchase(payCode)
    self.callBack = callBack
    dump(orderId)
end

return AppStorPayment