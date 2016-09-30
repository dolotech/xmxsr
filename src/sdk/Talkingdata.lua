--第3方数据
TalkingData = {}

--第3方数据统计任务taskId可以不写
-- TalkingData.onCompletedTask = function(taskdes,taskId)
--     if device.platform=="android" then --目前只接android
--         local luaj = require("cocos.cocos2d.luaj")
--         local javaClassName = "org.cocos2dx.lua.AppActivity"
--         local javaMethodName = "onCompletedTask"
--         local sig = "(Ljava/lang/String;I)I"
--         if taskId==nil then
--         	taskId = 0
--         end
--         local args ={tostring(taskdes),tonumber(taskId)}
--         luaj.callStaticMethod(javaClassName, javaMethodName, args, sig)
--     end
-- end

--[[ 数据统计
    _strEvent: 事件名
        task_begin 任务开始
        task_completed 任务结束
        task_failed 任务失败
        charge_request 充值请求
        charge_success 充值成功
        page_start 进入页面
        page_end 离开页面
        on_event 自定义事件
        on_reward 跟踪获赠的虚拟币
        on_purchase 虚拟币消费
        on_use 虚拟道具使用
    _strData: 数据
]]
TalkingData.eventStatistics = function( _strEvent, _strData )
    if(DPayCenter.platform == "google")then return end
    if device.platform=="android" then --目前只接android
        local luaj = require("cocos.cocos2d.luaj")
        local javaClassName = "org.cocos2dx.lua.AppActivity"
        local javaMethodName = "eventStatistics"
        local args ={_strEvent, _strData}
        luaj.callStaticMethod(javaClassName, javaMethodName, args)
    end
end

TalkingData.onTaskBegin = function( _strData )
    TalkingData.eventStatistics("task_begin", _strData)
end
TalkingData.onTaskCompleted = function( _strData )
    TalkingData.eventStatistics("task_completed", _strData)
end
TalkingData.onTaskFailed = function( _strData, _strFailed )
    TalkingData.eventStatistics("task_failed", _strData.."_".._strFailed)
end

TalkingData.onChargeRequest = function( _orderId, _commodityId, _nPrice, _virtualPrice, _paymentType )
    local str = _orderId.."_".._commodityId.."_".._nPrice.."_".."CNY".."_".._virtualPrice.."_".._paymentType
    TalkingData.eventStatistics("charge_request", str)
end
TalkingData.onChargeSuccess = function( _orderId, _nPrice, _paymentType )
    local str = _orderId.."_".._nPrice.."_".."CNY".."_".._paymentType
    TalkingData.eventStatistics("charge_success", str)
end

TalkingData.onPageStart = function( _strPage )
    TalkingData.eventStatistics("on_event", _strPage.."_state".."_进入")
end
TalkingData.onPageEnd = function( _strPage )
    TalkingData.eventStatistics("on_event", _strPage.."_state".."_成功离开")
end

TalkingData.onEvent = function( _strData )
    TalkingData.eventStatistics("on_event", _strData)
end

TalkingData.onReward = function( _nPrice, _nAllDiamond, _strDes )
    TalkingData.eventStatistics("on_reward", _nPrice.."_".._strDes.."_".._nAllDiamond)
end

TalkingData.onPurchase = function( _strItem, _nCount, _nPrice, _nAllDiamond )
    TalkingData.eventStatistics("on_purchase", _strItem.."_".._nCount.."_".._nPrice.."_".._nAllDiamond)
end

TalkingData.onUse = function( _strItem, _nCount )
    TalkingData.eventStatistics("on_use", _strItem.."_".._nCount)
end

