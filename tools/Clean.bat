
@echo off
set DIR=%~dp0
set ROOT = %DIR%
echo - cleanup
del "%ROOT%assets\complie_luac.exe"
del "%ROOT%assets\luac.exe"
del "%ROOT%assets\res\RGBA8888.bat"