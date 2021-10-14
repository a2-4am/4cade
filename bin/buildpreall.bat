@echo off
setlocal enabledelayedexpansion
1>nul copy /y build\PRELAUNCH\STANDARD %1
for /f "tokens=*" %%a in (build\games.lst) do 1>nul copy /b /y %1+build\PRELAUNCH\%%a %1
