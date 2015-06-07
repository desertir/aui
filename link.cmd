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
    echo rename xrLua
    ren "%GAMEBIN%\xrLua.dll" xrLua_GSC.dll
)
if not exist "%GAMEBIN%\xrLua.dll" mklink /H "%GAMEBIN%"\xrLua.dll .\bin\xrLua.dll
if not exist "%GAMEBIN%\lua51.dll" mklink /H "%GAMEBIN%"\lua51.dll .\bin\lua51.dll
if not exist "%GAMEBIN%\LuaXML_lib.dll" mklink /H "%GAMEBIN%"\LuaXML_lib.dll .\bin\LuaXML_lib.dll
mklink /J /D "%GAMEDATA%" .\gamedata