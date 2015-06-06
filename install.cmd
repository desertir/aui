@echo off
if defined PROCESSOR_ARCHITEW6432 (
    set SHOCGAME="HKLM\SOFTWARE\GSC Game World\STALKER-SHOC"
) else (
    set SHOCGAME="HKLM\SOFTWARE\Wow6432Node\GSC Game World\STALKER-SHOC" 
)
for /f "skip=2 tokens=2*" %%x in ('reg query %SHOCGAME% /v "InstallPath"') do set GAMEPATH=%%y
:setgamepath
if not exist "%GAMEPATH%" set /p GAMEPATH=Enter game path:
if not exist "%GAMEPATH%" goto setgamepath
set GAMEBIN=%GAMEPATH%\bin
set GAMEDATA=%GAMEPATH%\gamedata
if not exist "%GAMEBIN%\xrLua_GSC.dll" (
    ren "%GAMEBIN%\xrLua.dll" xrLua_GSC.dll
    copy .\bin\xrLua.dll "%GAMEBIN%"
)
if not exist "%GAMEBIN%\lua51.dll" copy .\bin\lua51.dll "%GAMEBIN%"
if not exist "%GAMEBIN%\LuaXML_lib.dll" copy .\bin\LuaXML_lib.dll "%GAMEBIN%"
xcopy /S /I /Y .\gamedata "%GAMEDATA%"