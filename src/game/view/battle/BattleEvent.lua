-- 游戏战斗事件

local BattleEvent =  class("BattleEvent")

BattleEvent.OnTouchBegan = "onTouchBegan"               -- 选中道具
BattleEvent.OnTouchEnd = "onTouchEnd"                   -- 释放选中
BattleEvent.OnConnected = "connected"                   -- 连线选中一个道具
BattleEvent.OnDeleteOne = "deleteOne"                   -- 删除一个道具
BattleEvent.OnTouchEndDelete = "OnTouchEndDelete"        -- 放开手指开始删除元素

BattleEvent.OnCONVER = "conver one"                   -- 转换道具
BattleEvent.ONPACMAN_ACTION = "PacMan action"          -- 吃豆人吃道具
BattleEvent.OnDeleteComplete = "deleteComplete"         -- 所有选中的道具删除完成
BattleEvent.OnConnectBack = "connectBack"               -- 回退选中
BattleEvent.FALL_COMPLETE = "fall complete"             -- 战斗道具掉落完成

BattleEvent.NEWBIE_EVENT = "newbie event"             -- 新手教程完成事件

BattleEvent.UPDATE_DATA = "updata data"             -- 更新路径信息


BattleEvent.START_ENGINE = "start engine"             -- 启动掉落引擎

BattleEvent.OnUpDataMoves = "updDataMoves"              -- 更新步数
BattleEvent.HideSkillInfoLayer = "hideSkillInfoLayer"   -- 隐藏技能信息层
BattleEvent.OnDropPetSkill = "OnDropPetSkill"           -- 掉落宠物技能
BattleEvent.OnDropMonsterSkill = "OnDropMonsterSkill"   -- 掉落怪物技能
BattleEvent.NON_THREN = "non three"                     -- 全盘没有3个相同的可删除道具

BattleEvent.RESUME = "resume"                           -- 继续
BattleEvent.PAUSE = "pause"                             -- 暂停
BattleEvent.ENGINE_STOP = "engine stop"                 -- 下落引擎停止
BattleEvent.OnBattleWin = "OnBattleWin"                 -- 战斗胜利
BattleEvent.OnBattleSpeak = "OnBattleSpeak"             -- 说话

BattleEvent.UpdateScore = "updateScore"             -- 更新分数
BattleEvent.BgAni = "bgAni"             -- 怪物出现过场动画

BattleEvent.ShowMaskLayer = "showMaskLayer"         -- 显示遮罩成

return BattleEvent


