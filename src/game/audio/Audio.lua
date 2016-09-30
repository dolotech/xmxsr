--------------------------------
-- @module Audio

--[[--
播放音乐、音效
]]

local Audio = {}

local sharedEngine = cc.SimpleAudioEngine:getInstance()

Audio.sound = 1                     -- 音效开关    1:开  0：关
Audio.bgm = 1                       -- 背景音乐开关    1:开    0:关
Audio.currentBGM = nil              -- 当前正在播放的背景音乐文件名
--------------------------------
-- 返回音乐的音量值
-- @function [parent=#Audio] getMusicVolume
-- @return number#number  返回值在 0.0 到 1.0 之间，0.0 表示完全静音，1.0 表示 100% 音量

function Audio.getMusicVolume()
    local volume = sharedEngine:getMusicVolume()

    return volume
end

--------------------------------
-- 设置音乐的音量
-- @function [parent=#Audio] setMusicVolume
-- @param number volume 音量在 0.0 到 1.0 之间, 0.0 表示完全静音，1.0 表示 100% 音量

function Audio.setMusicVolume(volume)

    sharedEngine:setMusicVolume(volume)
end

--------------------------------
-- 返回音效的音量值
-- @function [parent=#Audio] getSoundsVolume
-- @return number#number  返回值在 0.0 到 1.0 之间, 0.0 表示完全静音，1.0 表示 100% 音量

function Audio.getSoundsVolume()
    local volume = sharedEngine:getEffectsVolume()

    return volume
end

--------------------------------
-- 设置音效的音量
-- @function [parent=#Audio] setSoundsVolume
-- @param number volume 音量在 0.0 到 1.0 之间, 0.0 表示完全静音，1.0 表示 100% 音量

function Audio.setSoundsVolume(volume)
    sharedEngine:setEffectsVolume(volume)
end

--------------------------------
-- 预载入一个音乐文件
-- @function [parent=#Audio] preloadMusic
-- @param string filename 音乐文件名

function Audio.preloadMusic(filename)
    if not filename then
        print("Audio.preloadMusic() - invalid filename")
        return
    end

    sharedEngine:preloadMusic(filename)
end

--------------------------------
-- 播放音乐
-- @function [parent=#Audio] playMusic
-- @param string filename 音乐文件名
-- @param boolean isLoop 是否循环播放，默认为 true

function Audio.playMusic(filename, isLoop)
    if Audio.bgm == 1 then
        if not filename then
            print("Audio.playMusic() - invalid filename")
            return
        end
        if type(isLoop) ~= "boolean" then isLoop = true end
    
        Audio.stopMusic()
       
        sharedEngine:playMusic(filename, isLoop)
    end
    Audio.currentBGM = filename
end

--------------------------------
-- 停止播放音乐
-- @function [parent=#Audio] stopMusic
-- @param boolean isReleaseData 是否释放音乐数据，默认为 true

function Audio.stopMusic(isReleaseData)
    if Audio.bgm == 1 then
        isReleaseData = checkbool(isReleaseData)
        sharedEngine:stopMusic(isReleaseData)
        -- Audio.currentBGM = ""
    end
end

--------------------------------
-- 暂停音乐的播放
-- @function [parent=#Audio] pauseMusic
function Audio.pauseMusic()
     if Audio.bgm == 1 then
        sharedEngine:pauseMusic()
    end
end

--------------------------------
-- 恢复暂停的音乐
-- @function [parent=#Audio] resumeMusic
function Audio.resumeMusic()
    if Audio.bgm == 1 then
        sharedEngine:resumeMusic()
    end
end

--------------------------------
-- 从头开始重新播放当前音乐
-- @function [parent=#Audio] rewindMusic
function Audio.rewindMusic()
    if Audio.bgm == 1 then
        sharedEngine:rewindMusic()
    end
end

--------------------------------
-- 检查是否可以开始播放音乐
-- 如果可以则返回 true。
-- 如果尚未载入音乐，或者载入的音乐格式不被设备所支持，该方法将返回 false。
-- @function [parent=#Audio] willPlayMusic
-- @return boolean#boolean 

function Audio.willPlayMusic()
    if Audio.bgm == 0 then
        return false
    end
    local ret = sharedEngine:willPlayMusic()

    return ret
end

--------------------------------
-- 检查当前是否正在播放音乐
-- @function [parent=#Audio] isMusicPlaying
-- @return boolean#boolean 

function Audio.isMusicPlaying()
    local ret = sharedEngine:isMusicPlaying()

    return ret
end

--------------------------------
-- 播放音效，并返回音效句柄
-- 如果音效尚未载入，则会载入后开始播放。
-- 该方法返回的音效句柄用于 Audio.stopSound()、Audio.pauseSound() 等方法。
-- @function [parent=#Audio] playSound
-- @param string filename 音效文件名
-- @param boolean isLoop 是否重复播放，默认为 false
-- @return integer#integer  音效句柄

function Audio.playSound(filename, isLoop)
    if Audio.sound == 1 then
        if not filename then
            print("Audio.playSound() - invalid filename")
            return
        end
        if type(isLoop) ~= "boolean" then isLoop = false end
        return sharedEngine:playEffect(filename, isLoop)
    end
    return nil
end

--------------------------------
-- 暂停指定的音效
-- @function [parent=#Audio] pauseSound
-- @param integer 音效句柄

function Audio.pauseSound(handle)
    if Audio.sound == 1 then
        if not handle then
            print("Audio.pauseSound() - invalid handle")
            return
        end

        sharedEngine:pauseEffect(handle)
    end
end

--------------------------------
-- 暂停所有音效
-- @function [parent=#Audio] pauseAllSounds

function Audio.pauseAllSounds()
    if Audio.sound == 1 then
        sharedEngine:pauseAllEffects()
    end
end

--------------------------------
-- 恢复暂停的音效
-- @function [parent=#Audio] resumeSound
-- @param integer 音效句柄

function Audio.resumeSound(handle)
    if Audio.sound == 1 then
        if not handle then
            print("Audio.resumeSound() - invalid handle")
            return
        end
    
        sharedEngine:resumeEffect(handle)
    end
end

--------------------------------
-- 恢复所有的音效
-- @function [parent=#Audio] resumeAllSounds

function Audio.resumeAllSounds()
    if Audio.sound == 1 then
        sharedEngine:resumeAllEffects()
    end
end

--------------------------------
-- 停止指定的音效
-- @function [parent=#Audio] stopSound
-- @param integer 音效句柄

function Audio.stopSound(handle)
    if Audio.sound == 1 then
        if not handle then
            print("Audio.stopSound() - invalid handle")
            return
        end
    
        sharedEngine:stopEffect(handle)
    end
end

--------------------------------
-- 停止所有音效
-- @function [parent=#Audio] stopAllSounds

function Audio.stopAllSounds()
    if Audio.sound == 1 then
        sharedEngine:stopAllEffects()
    end
end

--------------------------------
-- 预载入一个音效文件
-- @function [parent=#Audio] preloadSound
-- @param string 音效文件名

function Audio.preloadSound(filename)
    if not filename then
        print("Audio.preloadSound() - invalid filename")
        return
    end

    sharedEngine:preloadEffect(filename)
end

--------------------------------
-- 从内存卸载一个音效
-- @function [parent=#Audio] unloadSound
-- @param string 音效文件名

function Audio.unloadSound(filename)
    if not filename then
        print("Audio.unloadSound() - invalid filename")
        return
    end

    sharedEngine:unloadEffect(filename)
end

return Audio