--[[--

针对 cc.Scene 的扩展

]]

local Scene = cc.Scene

--function Scene:setAutoCleanupEnabled()
--    self:registerScriptHandler(function(event)
--        if "exit" == event then
--            if self.autoCleanupImages_ then
--                for imageName, v in pairs(self.autoCleanupImages_) do
--                    cc.SpriteFrameCache:getInstance():removeSpriteFrameByName(imageName)
--                    cc.Director:getInstance():getTextureCache():removeTextureForKey(imageName)
--                end
--                self.autoCleanupImages_ = nil
--            end
--        end
--    end
--    )
--end
--
--
--function Scene:markAutoCleanupImage(imageName)
--    if not self.autoCleanupImages_ then self.autoCleanupImages_ = {} end
--    self.autoCleanupImages_[imageName] = true
--    return self
--end
