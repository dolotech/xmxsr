
Color = {}

--窗体颜色
Color.BgColor1 = {
    [1] = {[1]=cc.c3b(84,21,87),[2]=cc.c3b(179,62,175),[3]=cc.c3b(255,104,233)},
    [2] = {[1]=cc.c3b(114,16,13),[2]=cc.c3b(209,29,17),[3]=cc.c3b(234,69,46)},
    [3] = {[1]=cc.c3b(50,109,35),[2]=cc.c3b(38,192,29),[3]=cc.c3b(159,255,0)},
    [4] = {[1]=cc.c3b(15,87,150),[2]=cc.c3b(17,187,209),[3]=cc.c3b(70,233,255)},
    [5] = {[1]=cc.c3b(150,97,15),[2]=cc.c3b(209,134,17),[3]=cc.c3b(255,232,70)}
}


--宠物升级背景颜色
Color.BgColor2 = {
    [1] = {[1]=cc.c4b(255,115,235,255),[2]=cc.c4b(255,90,213,255)},
    [2] = {[1]=cc.c4b(251,157,138,255),[2]=cc.c4b(255,94,78,255)},
    [3] = {[1]=cc.c4b(160,251,138,255),[2]=cc.c4b(84,251,138,255)},
    [4] = {[1]=cc.c4b(90,170,255,255),[2]=cc.c4b(90,170,255,255)},
    [5] = {[1]=cc.c4b(251,218,55,255),[2]=cc.c4b(251,215,138,255)},
}

--hp颜色变化
Color.hpColor = {
    [1]=cc.c4b(255,255,255,255),
    [1.2]=cc.c4b(123,241,17,255),
    [1.5]=cc.c4b(21,107,244,255),
    [2]=cc.c4b(241,119,31,255)
}

--hp颜色变化 1当前关，2通关 3未通关
Color.pointColor = {
    [1]=cc.c4b(217,167,38,255),
    [2]=cc.c4b(110,143,57,255),
    [3]=cc.c4b(104,59,59,255),
}
-- 暗灰色
Color.chapterColor = cc.c4b(80,80  ,80,0)

--设置多个描边
Color.setLableShadows  = function(lales,shadow,outline)
    for key, var in ipairs(lales) do
        var:enableShadow(cc.c4b(20,20,20,150),cc.size(3,-3),shadow or 5)
        var:enableOutline(cc.c4b(20,20,20,150),outline or 1)
    end
end


--设置单个描边
Color.setLableShadow  = function(lale,shadow,outline)
    lale:enableShadow(cc.c4b(20,20,20,150),cc.size(3,-3),shadow or 5)
    lale:enableOutline(cc.c4b(20,20,20,150),outline or 1)
end



