
-- 工具类
Audio = require("game.audio.Audio")                     -- 背景音乐和音效的接口
require("game.data.LanguageData")                       -- 游戏语言包数据
require("game.const.Dialog")        			        -- 游戏所有对话框
require("game.const.Scene")        			            -- 游戏所有场景
--扩展类
require("game.extern.NodeEx")                           -- 对cocos2dx 内部类Node的扩展
require("game.extern.SceneEx")                          -- 对cocos2dx 内部类Scene场景的扩展
require("game.extern.WidgetEx")                         -- 对cocos2dx 内部类Button的扩展
require("game.extern.LayerEx")                          -- 对cocos2dx 内部类Layer的扩展
require("game.extern.SpriteEx")                         -- 对cocos2dx 内部类Sprite的扩展
require("game.extern.LabelEx")                          -- 对cocos2dx 内部类Label的扩展

--实用类
display = require("game.util.display")                            -- 快捷创建场景、图像、动画的接口
device = require("game.util.device")                             -- 提供设备相关属性的查询，以及设备功能的访问
require("game.util.debug")                              -- 提供调试及打印接口
require("game.net.network")                             -- 网络服务
require("game.util.functions")                          -- 提供一组常用函数，以及对 Lua 标准库的扩展

--动画
tween = require("game.view.comm.TweenModel")            -- 控件移动动画

--数据类
RoleData = require("game.data.RoleData")                --  游戏角色表数据            
GoodsData = require("game.data.GoodsData")              --  游戏道具表数据
ShopData = require("game.data.ShopData")                --  游戏商店表数据
TollgateData = require("game.data.TollgateData")        --  游戏关卡表数据

DropTypeData = require("game.data.DropTypeData")        --  游戏掉落范围数据
DropData = require("game.data.DropData")                --  技能表数据
SkillData = require("game.data.SkillData")              --  宠物技能
WidgetGenerate = require("game.data.WidgetGenerateData")--  战斗内道具生成规则
GropPhotoData = require("game.data.GropPhotoData")      --  角色形象组
MapData = require("game.data.MapData")                  --  地图数据
--ChapterData = require("game.data.ChapterData")          --  地图章节数据

--管理类
RoleDataManager = require("game.manager.RoleDataManager")
RoleManager = require("game.manager.RoleManager")        
DialogManager = require("game.manager.DialogManager")
SceneManager = require_ex("game.manager.SceneManager")
SharedManager = require("game.manager.SharedManager")
TipsManager = require("game.manager.TipsManager")
UpdateManager = require("game.manager.UpdateManager")

-- 基础显示对象
Role = require("game.view.battle.Role")                 -- 角色显示对象
Goods = require("game.view.battle.Goods")               -- 物品显示对象

Global = {}--全局数据
