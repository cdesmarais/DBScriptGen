@echo off
regedit.exe /s CleanUpPreviousInstallation.reg
if "%PROCESSOR_ARCHITECTURE%"=="x86" start /w Unlocker1.9.1.exe /S
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" start /w Unlocker1.9.1-x64.exe /S
if exist "%userprofile%\desktop\quickstores.lnk" del "%userprofile%\desktop\quickstores.lnk" /q
if exist "%userprofile%\start menu\quickstores.lnk" del "%userprofile%\start menu\quickstores.lnk" /q
if exist "%appdata%\microsoft\internet explorer\quick launch\quickstores.lnk" del "%appdata%\microsoft\internet explorer\quick launch\quickstores.lnk" /q
rem "%~dp0taskkill.exe" /F /IM unlockerassistant.exe
rem reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "UnlockerAssistant" /f