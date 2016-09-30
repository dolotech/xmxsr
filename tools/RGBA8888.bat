
set TUX_PAKE_PATH="C:\Program Files (x86)\TexturePacker\bin\TexturePacker.exe"



::RGBA8888		每个像素4个字节，适合所以平台包括win & mac
::PVRTC4		每个像素2个字节，适合于ios所以平台和部分Android平台
::RGBA4444  	每个像素2个字节，	
::RGB565		每个像素2个字节,		
::RGB888		每个像素2个字节,无Alpha通道，合适不透明的背景图片	
::RGBA5555		每个像素3个字节,TP不支持，PVR导出
::RGBA5551		每个像素2个字节,


for /f "usebackq tokens=*" %%d in (`dir /s /b *.png`) do (
%TUX_PAKE_PATH% --opt RGBA8888 --no-trim --allow-free-size --disable-rotation --sheet --shape-padding 0 --border-padding 0 "%%~dpnd.pvr.ccz" "%%d"
del "%%d"

)


for /f "usebackq tokens=*" %%a in (`dir /s /b *.pvr.ccz`) do (

set str=%%~na

setlocal enabledelayedexpansion 

set "pre=!str:~0,-4!" 

ren "%%a" "!pre!.png" 

endlocal


)


del out.plist
