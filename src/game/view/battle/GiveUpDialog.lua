-- 战斗中退出提示对话框
local BattleEvent = require("game.view.battle.BattleEvent")

local GiveUpDialog = class("GiveUpDialog",function()
    return display.createUI("GiveUpDialog.csb")
end)

function GiveUpDialog:onExit()
    self:dipatchGlobalEvent(BattleEvent.RESUME)
end
function GiveUpDialog:onEnter()
    self.FlyToModel =  require("game.view.comm.FlyToModel"):create()

    self:dipatchGlobalEvent(BattleEvent.PAUSE)
    self.tollgateData = clone(TollgateData[tostring(self.param.id)])
    self.tollgateData.id = self.param.id
    
    self:getChildByName("Button_1"):setTitleText(Language.Continue)
    self:getChildByName("Button_2"):setTitleText(Language.Again)
    self:getChildByName("Button_3"):setTitleText(Language.Give_Up)
    
    self:getChildByName("Text_1"):setString(Language.Time_out)
    self:getChildByName("Text_2"):setString(self.tollgateData.pointName)
    self:getChildByName("Text_3"):setString(tostring(self.tollgateData.power))

    Color.setLableShadows({self:getChildByName("Text_1"),self:getChildByName("Text_2"),self:getChildByName("Text_3")})
    
    self:getChildByName("closeButton"):onClick(function()Audio.playSound(Sound.SOUND_UI_READY_BACK, false)self:close()end, true, false)
    self:getChildByName("Button_1"):onClick(function()Audio.playSound(Sound.SOUND_UI_READY_BACK, false)self:close()end, true, false)

    self:getChildByName("Button_2"):onClick(function(parameters)
        local power = SharedManager:readData(Config.POWER)
        if power < self.tollgateData.power then
            DialogManager:open("game.view.power.PowerDialog")
            return
        end
        self:starBattle()
    end, true, false)

    self:getChildByName("Button_3"):onClick(function(parameters)
        TalkingData.onTaskFailed(Language.Statistics_Task..Global.selChapterId,"放弃任务")
        Audio.playSound(Sound.SOUND_BATTLE_GIVEUP,false)
        SceneManager.changeScene("game.view.scene.CollectedFailureScene",{data = self.param.data, id = self.tollgateData.id, getGoods = self.param.getGoods})
    end, true, false)
    
    self:statueVisibleMusic()
    self:statueVisibleSound()
    
    self:getChildByName("Button_4"):onClick(function(parameters) 
        if Audio.bgm == 1 then 
            Audio.stopMusic() 
            Audio.bgm = 0
        else     
            Audio.bgm = 1   
            print("Audio.currentBGM",Audio.currentBGM)
            Audio.playMusic(Audio.currentBGM)        
        end
        self:statueVisibleMusic()
        SharedManager:saveData("bgm",Audio.bgm,true)
    end, true)
    
    self:getChildByName("Button_5"):onClick(function(parameters)
        if Audio.sound == 1 then 
            Audio.stopAllSounds() 
            Audio.sound = 0
        else     
            Audio.sound = 1        
        end
        self:statueVisibleSound()
        SharedManager:saveData("sound",Audio.sound,true)
    end, true)
end

function GiveUpDialog:starBattle()
    Audio.playSound(Sound.SOUND_BATTLE_GIVEUP)
    self:getChildByName("Button_1"):setEnabled(false)
    self:getChildByName("Button_2"):setEnabled(false)
    self:getChildByName("Button_3"):setEnabled(false)
    self.FlyToModel:flyDropModel(Picture.RES_POWER_IOCN_PNG, cc.p(47, stageHeight - 58), cc.p(offSetX + 400, 391), 0.8, 1, 0.5, nil, function()
        SceneManager.changeScene(Scene.Battle,{tollgate = self.tollgateData})
    end, 5, 0.3, 1)
end

function GiveUpDialog:statueVisibleMusic()
    if Audio.bgm == 0 then 
        self:getChildByName("music_2"):setVisible(true)
    else     
        self:getChildByName("music_2"):setVisible(false)
    end
end

function GiveUpDialog:statueVisibleSound()
    if Audio.sound == 0 then 
        self:getChildByName("sound_2"):setVisible(true)
    else     
        self:getChildByName("sound_2"):setVisible(false)
    end
end

return GiveUpDialog
