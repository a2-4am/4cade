@echo off
rem
rem 4cade Makefile for Windows
rem assembles source code, optionally builds a disk image
rem
rem a qkumba monstrosity from 2018-10-29
rem

setlocal enabledelayedexpansion
set DISK=4cade.hdv
set VOLUME=TOTAL.REPLAY

rem third-party tools required to build (must be in path)
rem https://sourceforge.net/projects/acme-crossass/
set ACME=acme
rem https://bitbucket.org/magli143/exomizer/wiki/Home
set EXOMIZER=exomizer mem -q -P23 -lnone
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
call :asmproboot
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
call :compress
2>nul del build\log
1>nul copy /y res\blank.hdv "build\%DISK%" >>build\log
1>nul copy /y res\_FileInformation.txt build\ >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\LAUNCHER.SYSTEM" >>build\log
1>nul copy /y res\PREFS.CONF build\ >>build\log
cscript /nologo bin\padto.js 512 build\PREFS.CONF
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\TITLE" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\COVER" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\HELP" >>build\log
for %%q in (res\*.CONF) do if "%%q" neq "res\PREFS.CONF" %CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "%%q" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\PREFS.CONF" >>build\log
cscript /nologo bin\rsync.js "res\CREDITS" "build\" >>build\log
cscript /nologo bin\dumpcr.js "build\CREDITS"
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\CREDITS" >>build\log
cscript /nologo bin\rsync.js "res\HELPTEXT" "build\" >>build\log
cscript /nologo bin\dumpcr.js "build\HELPTEXT"
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\HELPTEXT" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\DECRUNCH" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\JOYSTICK" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\Finder.Data" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\Finder.Root" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/TITLE.HGR" "res\TITLE.HGR" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/TITLE.DHGR" "res\TITLE.DHGR" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/ACTION.HGR" "res\ACTION.HGR" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/ACTION.DHGR" "res\ACTION.DHGR" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/ACTION.GR" "res\ACTION.GR" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/ARTWORK.SHR" "res\ARTWORK.SHR" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/ATTRACT" "res\ATTRACT" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/SS" "res\SS" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/ICONS" "res\ICONS" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/DEMO" "res\DEMO" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/TITLE.ANIMATED" "res\TITLE.ANIMATED" >>build\log
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
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/PRELAUNCH" "build\PRELAUNCH" >>build\log
cscript /nologo bin\rsync.js "res\GAMEHELP\*" "build\GAMEHELP" >>build\log
for %%q in (res\title.hgr\*) do if not exist build\GAMEHELP\%%~nxq 1>nul copy build\GAMEHELP\STANDARD build\GAMEHELP\%%~nxq
for %%q in (res\title.dhgr\*) do if not exist build\GAMEHELP\%%~nxq 1>nul copy build\GAMEHELP\STANDARD build\GAMEHELP\%%~nxq
1>nul 2>nul del /s build\GAMEHELP\STANDARD
cscript /nologo bin\dumpcr.js "build\GAMEHELP\*"
cscript /nologo bin\buildfileinfo.js build\GAMEHELP "06" "6000" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/GAMEHELP" "build\GAMEHELP" >>build\log
cscript /nologo bin\changebootloader.js "build\%DISK%" build\proboothd
goto :EOF
)

echo usage: %0 clean / asm / dsk
goto :EOF

:md
2>nul md build
2>nul md build\X
2>nul md build\FX
2>nul md build\PRELAUNCH
2>nul md build\GAMEHELP
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
cscript /nologo bin\buildfileinfo.js build\FX "06" "6000"
goto :EOF

:asmprelaunch
for %%q in (src\prelaunch\*.a) do (
  for /f "tokens=* usebackq" %%k in (`find "^!to" %%q`) do set _to=%%k
  set _to=!_to:~0,1!
  if !_to!==t %ACME% %%q
)
for %%q in (res\title.hgr\*) do if not exist build\PRELAUNCH\%%~nxq 1>nul copy build\PRELAUNCH\STANDARD build\PRELAUNCH\%%~nxq
for %%q in (res\title.dhgr\*) do if not exist build\PRELAUNCH\%%~nxq 1>nul copy build\PRELAUNCH\STANDARD build\PRELAUNCH\%%~nxq
cscript /nologo bin\buildfileinfo.js build\PRELAUNCH "06" "0106" >>build\log
goto :EOF

:asmproboot
%ACME% -r build\proboothd.lst src\proboothd\proboothd.a >> build\log

:compress
for %%q in (res\action.dhgr.uncompressed\*) do if not exist res\action.dhgr\%%~nxq %EXOMIZER% res\action.dhgr.uncompressed\%%~nxq@0x4000 -o res\action.hgr\%%~nxq
for %%q in (res\action.hgr.uncompressed\*) do if not exist res\action.hgr\%%~nxq %EXOMIZER% res\action.hgr.uncompressed\%%~nxq@0x4000 -o res\action.hgr\%%~nxq
for %%q in (res\artwork.shr.uncompressed\*) do if not exist res\artwork.shr\%%~nxq %EXOMIZER% res\artwork.shr.uncompressed\%%~nxq@0x2000 -o res\artwork.shr\%%~nxq
cscript /nologo bin\buildfileinfo.js res\TITLE.HGR "06" "4000"
cscript /nologo bin\buildfileinfo.js res\TITLE.DHGR "06" "4000"
cscript /nologo bin\buildfileinfo.js res\ACTION.HGR "06" "3FF8"
cscript /nologo bin\buildfileinfo.js res\ACTION.DHGR "06" "3FF8"
cscript /nologo bin\buildfileinfo.js res\ACTION.GR "06" "6000"
cscript /nologo bin\buildfileinfo.js res\ARTWORK.SHR "06" "1FF8"
cscript /nologo bin\buildfileinfo.js res\ATTRACT "04" "8000"
cscript /nologo bin\buildfileinfo.js res\SS "04" "4000"
