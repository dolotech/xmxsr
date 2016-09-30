Config = {}
--帧蘋
Config.FRAME_RATE = 60
--游戏设计高度 
Config.DATA_DESIGN_HEIGHT = 1136
--游戏设计宽度 
Config.DATA_DESIGN_WIDTH = 852
--宠物类型数
Config.DATA_PETTYPE_COUNT = 5
--游戏元素格子宽度
Config.Grid_MAX_Pix_Width = 88
--游戏元素格子高度
Config.Grid_MAX_Pix_Height = 80
--游戏内格子列数
Config.Element_Grid_Width = 11
--游戏内格子行数
Config.Element_Grid_Height = 9
--掉落加速度-每帧速度叠加值，分母是帧蘋(加速度代表指定了速度放心，值不能为0)
Config.FALL_GRAVITY = 30
--掉落初始，分母是帧蘋
Config.FALL_VELOCITY = 300
--每页地图的高度
Config.DATA_MAP_LAYER_HEIGHT = 980
--布阵宠物滚动的宽度
Config.DATA_EMBATTLE_PET_WIDTH = 100
--布阵宠物滚动的高度
Config.DATA_EMBATTLE_PET_HEIGHT = 320
--体力倒计时时间分钟
Config.POWER_CD_TIME = 10
--开启角色
Config.OPEN_ROLE_POINT = 1001
--开启抽奖
Config.OPEN_KEY_POINT = 1006
--抽奖买多少钥匙
Config.BUY_KEY_NUM = 3
--元素基本攻击力
Config.BASE_ATTACK = 50
--钥匙常用ID
Config.KEY_ID = 7
--体力常用ID
Config.POWER_ID = 122
--123
Config.POWER_LIMIT_ID = 123
--钻石小
Config.DIANMOND_ID1 = 6
--钻石中包
Config.DIANMOND_ID2 = 120
--钻石大包
Config.DIANMOND_ID3 = 121
--蓝色材料小
Config.BULE_ID1 = 117
--蓝色材料中包
Config.BULE_ID2 = 118
--蓝色材料大包
Config.BULE_ID3 = 119
--黄色材料小
Config.YELLOW_ID1 = 114
--黄色材料中包
Config.YELLOW_ID2 = 115
--黄色材料大包
Config.YELLOW_ID3 = 116
--复活石常用ID
Config.Relive_ID = 124
--第一次打开主城
Config.CITY_INIT_ONEC = 0
--0是标识没新关卡开启否则是
Config.OPEN_LOCK_ID = 0
--彩虹球
Config.TOOL_RAINBOW_BALL = 63
--魔法球
Config.TOOL_MAGIC_BALL = 64
--刷子
Config.TOOL_BRUSH = 65
--炸弹
Config.TOOL_BOMB = 29
--用户关卡
Config.POINT = "point"
--用户体力
Config.POWER = "power"
--用户体力上限
Config.LIMITPOWER = "limitPower"
--用户钻石
Config.DIAMOND = "diamond"
--用户体力时间
Config.POWERTIME = "powerTime"
--首冲礼包领取倒计时
Config.fristTime = "fristTime"
--用户黄色材料
Config.YELLOW = "yellow"
--用户蓝色材料
Config.BLUE = "blue"
--用户钥匙
Config.KEY = "key"
--用户签到key
Config.Sign = "sign"
--星星兑换key
Config.Star = "star"
--复活石
Config.Relive = "relive"
--用户背包
Config.Storage = "items"
--事件数据
Config.Events = "events"
--记录玩家是否购买礼包
Config.isFrist = "isFrist"
--记录玩家是否领取首冲礼包
Config.isfristTop = "isfristTop"
--用户首冲钻石
Config.isDiamond = "isDiamond"
--用户宾谷广告key
Config.PingCoo = "pingcoo"
--支付购买商品钻石后缀ID250
Config.PLAY_ID250 = 250
--支付购买商品钻石后缀ID750
Config.PLAY_ID750 = 750
--支付购买商品钻石后缀ID1800
Config.PLAY_ID1800 = 1800
--支付购买商品钻石后缀ID4500
Config.PLAY_ID4500 = 4500
--支付购买商品钻石后缀ID10000
Config.PLAY_ID10000 = 10000
--支付购买商品钻石后缀ID15000
Config.PLAY_ID15000 = 15000
--支付购买体力商品后缀ID5
Config.PLAY_ID5 = 5
--支付购买步数商品后缀ID6
Config.PLAY_ID6 = 6
--购买体力上限需要的钻石5点一次
Config.BUY_LIMIT_POWER_DIAMOND = 500
--体力上限购买一次加5个
Config.BUY_LIMIT_POWER_ADD = 5
--消除普通道具间隔
Config.DELETE_WIDGET_INTERVAL = .03
--爆炸技能消除间隔
Config.DELETE_BOMB_INTERVAL = .06
--结算丢步数移动时间
Config.MOVW_WIN_INTERVAL = .55
--游戏最高体力上限值
Config.Maximum_physical_limit = 99
--新手引导手指移动时间间隔
Config.Newbie_Move_Delay = .4
--8秒钟不支付关闭窗口
Config.MOVE_FAIL_INTERVAL = 8
--关卡默认数据
Config.POINT_DATA_DUALFT = {star=0,isOpen=false}
--战斗场景偏移高度
Config.BATTLE_SCENE_OFFSET_HEIGHT = 80
--是否记录通过第一关
Config.isNo = "isNo"
--记录主地图的分享是否点击
Config.isMainShare = "isMainShare"
--玩家昵称
Config.playName = "playName"
--机器人好友
Config.friendInfo = "friendInfo"
