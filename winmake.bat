@echo off
rem
rem 4cade Makefile for Windows
rem assembles source code, optionally builds a disk image
rem
rem a qkumba monstrosity from 2018-10-29
rem

setlocal enabledelayedexpansion
set DISK=4cade.2mg
set VOLUME=TOTAL.REPLAY

rem third-party tools required to build (must be in path)
rem https://sourceforge.net/projects/acme-crossass/
set ACME=acme
rem https://www.brutaldeluxe.fr/products/crossdevtools/cadius/
rem https://github.com/mach-kernel/cadius
set CADIUS=cadius
rem https://github.com/
set GIT=git


if "%1" equ "asm" (
:asm
call :md
call :asmlauncher
call :asmfx
call :asmprelaunch
goto :EOF
)

if "%1" equ "clean" (
:clean
echo y|1>nul 2>nul rd build /s
goto :EOF
)

if "%1" equ "dsk" (
:dsk
call :asm
2>nul del build\log
1>nul copy /y res\blank.2mg "build\%DISK%" >>build\log
1>nul copy /y res\_FileInformation.txt build\ >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\LAUNCHER.SYSTEM" >>build\log
cscript /nologo bin\rsync.js res\*.conf build >>build\log
1>nul copy /y res\credits.txt build\CREDITS >>build\log
cscript /nologo bin\padto.js 512 build\PREFS.CONF
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\TITLE" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\COVER" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\HELP" >>build\log
for %%q in (build\*.CONF) do %CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "%%q" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\CREDITS" >>build\log
cscript /nologo bin\rsync.js res\title.hgr\* build\TITLE.HGR >>build\log
cscript /nologo bin\rsync.js res\title.dhgr\* build\TITLE.DHGR >>build\log
cscript /nologo bin\rsync.js res\action.hgr\* build\ACTION.HGR >>build\log
cscript /nologo bin\rsync.js res\action.dhgr\* build\ACTION.DHGR >>build\log
cscript /nologo bin\rsync.js res\action.gr\* build\ACTION.GR >>build\log
cscript /nologo bin\rsync.js res\artwork.shr\* build\ARTWORK.SHR >>build\log
cscript /nologo bin\rsync.js res\attract\* build\ATTRACT >>build\log
cscript /nologo bin\rsync.js res\ss\* build\SS >>build\log
cscript /nologo bin\rsync.js res\demo\* build\DEMO >>build\log
cscript /nologo bin\rsync.js res\title.animated\* build\TITLE.ANIMATED >>build\log
cscript /nologo bin\buildfileinfo.js build\TITLE.HGR "06" "4000" >>build\log
cscript /nologo bin\buildfileinfo.js build\TITLE.DHGR "06" "4000" >>build\log
cscript /nologo bin\buildfileinfo.js build\ACTION.HGR "06" "4000" >>build\log
cscript /nologo bin\buildfileinfo.js build\ACTION.DHGR "06" "4000" >>build\log
cscript /nologo bin\buildfileinfo.js build\ACTION.GR "06" "6000" >>build\log
cscript /nologo bin\buildfileinfo.js build\ARTWORK.SHR "C1" "2000" >>build\log
cscript /nologo bin\buildfileinfo.js build\ATTRACT "04" "8000" >>build\log
cscript /nologo bin\buildfileinfo.js build\SS "04" "4000" >>build\log
cscript /nologo bin\rsync.js res\fx\* build\FX >>build\log
cscript /nologo bin\buildfileinfo.js build\FX "06" "6000" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/TITLE.HGR" "build\TITLE.HGR" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/TITLE.DHGR" "build\TITLE.DHGR" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/ACTION.HGR" "build\ACTION.HGR" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/ACTION.DHGR" "build\ACTION.DHGR" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/ACTION.GR" "build\ACTION.GR" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/ARTWORK.SHR" "build\ARTWORK.SHR" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/ATTRACT" "build\ATTRACT" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/SS" "build\SS" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/DEMO" "build\DEMO" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/TITLE.ANIMATED" "build\TITLE.ANIMATED" >>build\log
%CADIUS% RENAMEFILE "build\%DISK%" "/%VOLUME%/DEMO/SPCARTOON.11" "SPCARTOON.1." >>build\log
%CADIUS% RENAMEFILE "build\%DISK%" "/%VOLUME%/DEMO/SPCARTOON.22" "SPCARTOON.2." >>build\log
%CADIUS% RENAMEFILE "build\%DISK%" "/%VOLUME%/DEMO/SPCARTOON.33" "SPCARTOON.3." >>build\log
%CADIUS% RENAMEFILE "build\%DISK%" "/%VOLUME%/DEMO/SPCARTOON.44" "SPCARTOON.4." >>build\log
%CADIUS% RENAMEFILE "build\%DISK%" "/%VOLUME%/DEMO/SPCARTOON.55" "SPCARTOON.5." >>build\log
%CADIUS% RENAMEFILE "build\%DISK%" "/%VOLUME%/DEMO/SPCARTOON.66" "SPCARTOON.6." >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/FX" "build\FX" >>build\log
%CADIUS% CREATEFOLDER "build\%DISK%" "/%VOLUME%/X/" >>build\log
for %%q in (res\dsk\*.po) do %CADIUS% EXTRACTVOLUME "%%q" build\X\ >>build\log
1>nul 2>nul del /s build\X\.DS_Store build\X\PRODOS build\X\LOADER.SYSTEM
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/X" "build\X" >>build\log
cscript /nologo bin\buildfileinfo.js build\PRELAUNCH "06" "0106" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/PRELAUNCH" "build\PRELAUNCH" >>build\log
cscript /nologo bin\changebootloader.js "build\%DISK%" res\proboothd
goto :EOF
)

if "%1" equ "chd" (
call :dsk
chdman createhd -c none -isb 64 -i "build\%DISK%" -o "build\%DISK%.chd" >>build\log
goto :EOF
)

echo usage: %0 clean / asm / dsk / chd
goto :EOF

:md
2>nul md build
2>nul md build\po
2>nul md build\X
2>nul md build\TITLE.HGR
2>nul md build\TITLE.DHGR
2>nul md build\ACTION.HGR
2>nul md build\ACTION.DHGR
2>nul md build\ACTION.GR
2>nul md build\ARTWORK.SHR
2>nul md build\TITLE.ANIMATED
2>nul md build\ATTRACT
2>nul md build\SS
2>nul md build\DEMO
2>nul md build\FX
2>nul md build\PRELAUNCH
goto :EOF

:asmlauncher
1>build\buildnum.log git rev-list --count HEAD
for /f "tokens=*" %%q in (build\buildnum.log) do set _build=%%q
2>build\relbase.log %ACME% -DBUILDNUMBER=%_build% src\4cade.a
for /f "tokens=*" %%q in (build\relbase.log) do set _make=%%q
%ACME% -DBUILDNUMBER=%_build% -DRELBASE=$!_make:~-5,4! -r build\4cade.lst src\4cade.a
goto :EOF

:asmfx
for %%q in (src\fx\*.a) do (
  for /f "tokens=* usebackq" %%k in (`find "^!to" %%q`) do set _to=%%k
  set _to=!_to:~0,1!
  if !_to!==t %ACME% %%q
)
goto :EOF

:asmprelaunch
for %%q in (src\prelaunch\*.a) do (
  for /f "tokens=* usebackq" %%k in (`find "^!to" %%q`) do set _to=%%k
  set _to=!_to:~0,1!
  if !_to!==t %ACME% %%q
for %%q in (res\title.hgr\*) do if not exist build\prelaunch\%%~nxq 1>nul copy build\prelaunch\standard build\prelaunch\%%~nxq
)
