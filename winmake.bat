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
1>nul copy nul build\log
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
1>nul copy /y res\blank.hdv "build\%DISK%" >>build\log
1>nul copy /y res\_FileInformation.txt build\ >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\LAUNCHER.SYSTEM" >>build\log
1>nul copy /y "res\PREFS.CONF" "build" >>build\log
cscript /nologo bin\padto.js 512 build\PREFS.CONF
rem
rem precompute OKVS data structure for mega-attract mode configuration file
rem
cscript /nologo bin\buildokvs.js res\ATTRACT.CONF build\ATTRACT.IDX >>build\log
rem
rem precompute FX and DFX indexes and merged data files containing multiple
rem graphic effects in a single file (loaded at runtime by LoadIndexedFile())
rem
cscript /nologo bin\buildfx.js res\FX.CONF build\FX.IDX build\FX.ALL build\FX.INDEXED >>build\log
cscript /nologo bin\buildfx.js res\DFX.CONF build\DFX.IDX build\DFX.ALL build\FX.INDEXED >>build\log
rem
rem substitute special characters in help text and other pages that will be
rem drawn with DrawPage()
rem
cscript /nologo bin\subst.js res\HELPTEXT build\HELPTEXT >>build\log
cscript /nologo bin\subst.js res\CREDITS build\CREDITS >>build\log
for %%q in (res\GAMEHELP\*) do cscript /nologo bin\subst.js %%q build\GAMEHELP\%%~nxq >>build\log
rem
rem precompute indexed files for game help, slideshow configuration,
rem mini-attract mode configuration, and prelaunch files
rem
cscript /nologo bin\buildpre.js build\GAMEHELP build\GAMEHELP.IDX build\GAMEHELP.ALL build\GAMEHELP\STANDARD >>build\log
for %%q in (res\SS\*) do cscript /nologo bin\buildokvs.js "%%q" "build\SS\%%~nxq" >>build\log
cscript /nologo bin\buildss.js build\SS build\SLIDESHOW.IDX build\SLIDESHOW.ALL nul >>build\log
for %%q in (res\ATTRACT\*) do cscript /nologo bin\buildokvs.js "%%q" "build\ATTRACT\%%~nxq" >>build\log
cscript /nologo bin\buildss.js build\ATTRACT build\MINIATTRACT.IDX build\MINIATTRACT.ALL nul >>build\log
cscript /nologo bin\buildpre.js build\PRELAUNCH.INDEXED build\PRELAUNCH.IDX build\PRELAUNCH.ALL build\PRELAUNCH.INDEXED\STANDARD >>build\log
rem
rem create _FileInformation.txt files for subdirectories
rem
cscript /nologo bin\buildfileinfo.js res\TITLE.HGR "06" "4000" >>build/log
cscript /nologo bin\buildfileinfo.js res\TITLE.DHGR "06" "4000" >>build/log
cscript /nologo bin\buildfileinfo.js res\ACTION.HGR "06" "3FF8" >>build/log
cscript /nologo bin\buildfileinfo.js res\ACTION.DHGR "06" "3FF8" >>build/log
cscript /nologo bin\buildfileinfo.js res\ACTION.GR "06" "6000" >>build/log
cscript /nologo bin\buildfileinfo.js res\ARTWORK.SHR "06" "1FF8" >>build/log
cscript /nologo bin\buildfileinfo.js res\ICONS "CA" "0000" >>build/log
cscript /nologo bin\buildfileinfo.js build\FX "06" "6000" >>build/log
cscript /nologo bin\buildfileinfo.js build\PRELAUNCH "06" "0106" >>build/log
rem
rem add everything to the disk
rem
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\TITLE" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\COVER" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\HELP" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\GAMES.CONF" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\PREFS.CONF" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\CREDITS" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\HELPTEXT" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\ATTRACT.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\FX.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\FX.ALL" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\DFX.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\DFX.ALL" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\GAMEHELP.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\GAMEHELP.ALL" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\SLIDESHOW.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\SLIDESHOW.ALL" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\MINIATTRACT.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\MINIATTRACT.ALL" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\PRELAUNCH.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\PRELAUNCH.ALL" >>build\log
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
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/DEMO" "res\DEMO" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/TITLE.ANIMATED" "res\TITLE.ANIMATED" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/ICONS" "res\ICONS" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/FX/" "build\FX" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/PRELAUNCH/" "build\PRELAUNCH" >>build\log
%CADIUS% RENAMEFILE "build\%DISK%" "/%VOLUME%/DEMO/SPCARTOON.11" "SPCARTOON.1." >>build\log
%CADIUS% RENAMEFILE "build\%DISK%" "/%VOLUME%/DEMO/SPCARTOON.22" "SPCARTOON.2." >>build\log
%CADIUS% RENAMEFILE "build\%DISK%" "/%VOLUME%/DEMO/SPCARTOON.33" "SPCARTOON.3." >>build\log
%CADIUS% RENAMEFILE "build\%DISK%" "/%VOLUME%/DEMO/SPCARTOON.44" "SPCARTOON.4." >>build\log
%CADIUS% RENAMEFILE "build\%DISK%" "/%VOLUME%/DEMO/SPCARTOON.55" "SPCARTOON.5." >>build\log
%CADIUS% RENAMEFILE "build\%DISK%" "/%VOLUME%/DEMO/SPCARTOON.66" "SPCARTOON.6." >>build\log
for %%q in (res\dsk\*.po) do %CADIUS% EXTRACTVOLUME "%%q" build\X\ >>build\log
1>nul 2>nul del /s build\X\.DS_Store build\X\PRODOS build\X\LOADER.SYSTEM
%CADIUS% CREATEFOLDER "build\%DISK%" "/%VOLUME%/X/" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/X" "build\X" >>build\log
cscript /nologo bin\changebootloader.js "build\%DISK%" build\proboothd
goto :EOF
)

if "%1" equ "demo" (
for %%q in (src\demo\*) do %acme% %%q
goto :EOF
)

echo usage: %0 clean / asm / dsk
goto :EOF

:md
2>nul md build
2>nul md build\X
2>nul md build\FX.INDEXED
2>nul md build\FX
2>nul md build\PRELAUNCH.INDEXED
2>nul md build\PRELAUNCH
2>nul md build\ATTRACT
2>nul md build\SS
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
goto :EOF

:asmprelaunch
for %%q in (src\prelaunch\*.a) do (
  for /f "tokens=* usebackq" %%k in (`find "^!to" %%q`) do set _to=%%k
  set _to=!_to:~0,1!
  if !_to!==t %ACME% %%q
)
goto :EOF

:asmproboot
%ACME% -r build\proboothd.lst src\proboothd\proboothd.a >> build\log

:compress
for %%q in (res\action.dhgr.uncompressed\*) do if not exist res\action.dhgr\%%~nxq %EXOMIZER% res\action.dhgr.uncompressed\%%~nxq@0x4000 -o res\action.hgr\%%~nxq
for %%q in (res\action.hgr.uncompressed\*) do if not exist res\action.hgr\%%~nxq %EXOMIZER% res\action.hgr.uncompressed\%%~nxq@0x4000 -o res\action.hgr\%%~nxq
for %%q in (res\artwork.shr.uncompressed\*) do if not exist res\artwork.shr\%%~nxq %EXOMIZER% res\artwork.shr.uncompressed\%%~nxq@0x2000 -o res\artwork.shr\%%~nxq
