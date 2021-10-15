@echo off
1>nul copy /y %3 %2
for /f "tokens=*" %%a in (build\games.lst) do 1>nul copy /b /y %2+%1\%%a %2
