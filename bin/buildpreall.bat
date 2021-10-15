@echo off
setlocal enabledelayedexpansion
1>nul copy /y %1\STANDARD %2
for /f "tokens=*" %%a in (build\games.lst) do 1>nul copy /b /y %2+%1\%%a %2
