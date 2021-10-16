@echo off
setlocal enabledelayedexpansion
1>nul copy /y nul %2
for /f "tokens=*" %%a in (%1) do (
set f=0
call :x %%a
if !f!==2 goto:eof
if !f!==0 1>nul copy /b /y %2+%3\%%a %2
)
goto:eof

:x
set a=%1
if not x%a:#=%==x%a% set/a f=1
if not x%a:[=%==x%a% set/a f=2
