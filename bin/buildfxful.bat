@echo off
setlocal enabledelayedexpansion
1>nul copy /y nul %2
set f=0
for /f "tokens=*" %%a in (%1) do (
call :x %%a %2
)
goto:eof

:x
call :check %1
if !f!==2 goto:eof
if !f!==0 1>nul copy /b /y %2+build\FX\%1 %2
)
goto:eof

:check
set a=%1
if not x%a:#=%==x%a% set/a f=1
if not x%a:[=%==x%a% set/a f=2
