
@echo off
set JDK_PATH=C:\Program Files\Java\jre6\bin
set TUX_PAKE_PATH="C:\Program Files (x86)\TexturePacker\bin\TexturePacker.exe"
set DIR=%~dp0
set ROOT = %DIR%
set APP_ROOT=%DIR%..\

echo - cleanup
if exist "%ROOT%assets" rmdir /s /q "%ROOT%assets"
mkdir "%ROOT%assets"
echo - copy scripts
mkdir "%ROOT%assets\src"
xcopy /s /q "%APP_ROOT%src\*.*" "%ROOT%assets\src\"
echo - copy resources
mkdir "%APP_ANDROID_ROOT%assets\res"
xcopy /s /q "%APP_ROOT%res\*.*" "%ROOT%assets\res\"
echo - copy config.json
copy "%APP_ROOT%config.json" "%ROOT%assets\config.json"

echo - copy complie_luac.exe
copy "%ROOT%complie_luac.exe" "%ROOT%assets\complie_luac.exe"
echo - copy luac.exe
copy "%ROOT%luac.exe" "%ROOT%assets\luac.exe"
echo - copy %RGBA8888.bat
copy "%ROOT%RGBA8888.bat" "%ROOT%assets\res\RGBA8888.bat"


call "%ROOT%assets\res\RGBA8888.bat"

start "%ROOT%assets\complie_luac.exe" /d "%ROOT%assets" /w "complie_luac.exe"

call "%ROOT%Clean.bat"

pause