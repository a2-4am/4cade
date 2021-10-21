@echo off
1>nul copy /y /b %2+%3 %2
for /f "tokens=*" %%a in (build\GAMES.SORTED) do 1>nul copy /b /y %2+%1\%%a %2
