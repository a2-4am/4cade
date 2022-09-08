@echo off
for /f "tokens=*" %%a in (build\sng.lst) do 1>nul copy /b /y %2+%1\%%a %2
