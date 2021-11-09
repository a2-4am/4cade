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


if "%1" equ "dsk" (
call :asm
call :index
1>nul copy /y res\blank.hdv "build\%DISK%" >>build\log
1>nul copy /y res\_FileInformation.txt build\ >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\LAUNCHER.SYSTEM" >>build\log
1>nul copy /y "res\PREFS.CONF" "build" >>build\log
cscript /nologo bin\padto.js 512 build\PREFS.CONF
rem
rem create _FileInformation.txt files for subdirectories
rem
cscript /nologo bin\buildfileinfo.js res\TITLE.HGR "06" "4000" >>build/log
cscript /nologo bin\buildfileinfo.js res\TITLE.DHGR "06" "4000" >>build/log
cscript /nologo bin\buildfileinfo.js res\ACTION.GR "06" "6000" >>build/log
cscript /nologo bin\buildfileinfo.js res\ICONS "CA" "0000" >>build/log
cscript /nologo bin\buildfileinfo.js build\FX "06" "6000" >>build/log
cscript /nologo bin\buildfileinfo.js build\PRELAUNCH "06" "0106" >>build/log
rem
rem add everything to the disk
rem
echo|set/p="adding files..."
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\TOTAL.DATA" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\TITLE" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\COVER" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\HELP" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\PREFS.CONF" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\CREDITS" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\HELPTEXT" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\ATTRACT.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\SEARCH00.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\SEARCH01.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\SEARCH10.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\SEARCH11.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\CACHE00.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\CACHE01.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\CACHE10.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\CACHE11.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\FX.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\DFX.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\GAMEHELP.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\SLIDESHOW.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\MINIATTRACT.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\PRELAUNCH.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build/ARTWORK.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build/HGR0.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build/HGR1.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build/HGR2.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build/HGR3.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build/HGR4.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build/HGR5.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build/HGR6.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build/DHGR.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build/GR.IDX" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\DECRUNCH" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\JOYSTICK" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\Finder.Data" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\Finder.Root" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/TITLE.HGR" "res\TITLE.HGR" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/TITLE.DHGR" "res\TITLE.DHGR" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/ACTION.GR" "res\ACTION.GR" >>build\log
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
echo done
goto :EOF
)

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
echo y|1>nul 2>nul rd build /s
goto :EOF
)

if "%1" equ "compress" (
call :compress
goto :EOF
)

echo usage: %0 clean / asm / dsk
goto :EOF

:index
rem
rem precompute binary data structure for mega-attract mode configuration file
rem
cscript /nologo bin\buildokvs.js res\ATTRACT.CONF build\ATTRACT.IDX >>build\log
rem
rem precompute binary data structure and substitute special characters
rem in game help and other all-text pages
rem
cscript /nologo bin\converthelp.js res\HELPTEXT build\HELPTEXT >>build\log
cscript /nologo bin\converthelp.js res\CREDITS build\CREDITS >>build\log
echo|set/p="converting gamehelp..."
for %%q in (res\GAMEHELP\*) do cscript /nologo bin\converthelp.js %%q build\GAMEHELP\%%~nxq >>build\log
echo done
rem
rem create a sorted list of game filenames, without metadata or display names
rem
cscript /nologo bin\makesorted.js
rem
rem create search indexes: (game-requires-joystick) X (game-requires-128K)
rem
echo|set/p="indexing search..."
cscript /nologo bin\builddisplaynames.js
cscript /nologo bin\buildsearch.js "00" build\SEARCH00.IDX
cscript /nologo bin\buildsearch.js "0" build\SEARCH01.IDX
cscript /nologo bin\buildsearch.js ".0" build\SEARCH10.IDX
cscript /nologo bin\buildsearch.js "." build\SEARCH11.IDX
echo done
rem
rem precompute indexed files for prelaunch
rem note: prelaunch must be first in TOTAL.DATA due to a hack in LoadStandardPrelaunch
rem note 2: these can not be padded because they are loaded at $0106 and padding would clobber the stack
rem
echo|set/p="indexing prelaunch..."
1>nul copy /y nul build\TOTAL.DATA
cscript /nologo bin\buildpre.js build\PRELAUNCH.INDEXED build\PRELAUNCH.IDX build\TOTAL.DATA >>build\log
echo done
rem
rem precompute indexed files for game help
rem
echo|set/p="indexing gamehelp..."
cscript /nologo bin\buildpre.js build\GAMEHELP build\GAMEHELP.IDX build\TOTAL.DATA pad >>build\log
echo done
rem
rem precompute indexed files for slideshows
rem
echo|set/p="indexing slideshows..."
for %%q in (res\SS\*) do (
  set _ss=%%~nxq
  set _ss=!_ss:~0,3!
  if !_ss!==ACT (
    cscript /nologo bin\buildaction.js %%q build\SS\%%~nxq >>build\log
  ) else (
    cscript /nologo bin\buildtitle.js %%q build\SS\%%~nxq >>build\log
  )
)
cscript /nologo bin\buildss.js build\SS build\SLIDESHOW.IDX build\TOTAL.DATA nul pad >>build\log
for %%q in (res\ATTRACT\*) do cscript /nologo bin\buildokvs.js %%q build\ATTRACT\%%~nxq >>build\log
cscript /nologo bin\buildss.js build\ATTRACT build\MINIATTRACT.IDX build\TOTAL.DATA nul pad >>build\log
echo done
rem
rem precompute indexed files for graphic effects
rem
echo|set/p="indexing fx..."
cscript /nologo bin\buildfx.js res\FX.CONF build\FX.IDX build\TOTAL.DATA build\FX.INDEXED >>build\log
cscript /nologo bin\buildfx.js res\DFX.CONF build\DFX.IDX build\TOTAL.DATA build\FX.INDEXED >>build\log
echo done
rem
rem precompute indexed files for HGR & DHGR action screenshots
rem note: these can not be padded because they are compressed and the decompressor needs the exact size
rem
echo|set/p="indexing (D)HGR action..."
1>nul copy /y nul build\ACTIONHGR0
1>nul copy /y nul build\ACTIONHGR1
1>nul copy /y nul build\ACTIONHGR2
1>nul copy /y nul build\ACTIONHGR3
1>nul copy /y nul build\ACTIONHGR4
1>nul copy /y nul build\ACTIONHGR5
1>nul copy /y nul build\ACTIONHGR6
1>nul copy /y nul build\ACTIONDHGR
for %%q in (res\ACTION.HGR\A* res\ACTION.HGR\B* res\ACTION.HGR\C* res\ACTION.HGR\D*) do 1>nul >>build\ACTIONHGR0 echo %%q
for %%q in (res\ACTION.HGR\E* res\ACTION.HGR\F* res\ACTION.HGR\G* res\ACTION.HGR\H*) do 1>nul >>build\ACTIONHGR1 echo %%q
for %%q in (res\ACTION.HGR\I* res\ACTION.HGR\J* res\ACTION.HGR\K* res\ACTION.HGR\L*) do 1>nul >>build\ACTIONHGR2 echo %%q
for %%q in (res\ACTION.HGR\M* res\ACTION.HGR\N* res\ACTION.HGR\O* res\ACTION.HGR\P*) do 1>nul >>build\ACTIONHGR3 echo %%q
for %%q in (res\ACTION.HGR\Q* res\ACTION.HGR\R* res\ACTION.HGR\S* res\ACTION.HGR\T*) do 1>nul >>build\ACTIONHGR4 echo %%q
for %%q in (res\ACTION.HGR\U* res\ACTION.HGR\V* res\ACTION.HGR\W* res\ACTION.HGR\X*) do 1>nul >>build\ACTIONHGR5 echo %%q
for %%q in (res\ACTION.HGR\Y* res\ACTION.HGR\Z*) do 1>nul >>build\ACTIONHGR6 echo %%q
for %%q in (res\ACTION.DHGR\*) do 1>nul >>build\ACTIONDHGR echo %%q
cscript /nologo bin\buildss.js build\ACTIONHGR0* build\HGR0.IDX build\TOTAL.DATA nul >>build\log
cscript /nologo bin\buildss.js build\ACTIONHGR1* build\HGR1.IDX build\TOTAL.DATA build\TOTAL.DATA >>build\log
cscript /nologo bin\buildss.js build\ACTIONHGR2* build\HGR2.IDX build\TOTAL.DATA build\TOTAL.DATA >>build\log
cscript /nologo bin\buildss.js build\ACTIONHGR3* build\HGR3.IDX build\TOTAL.DATA build\TOTAL.DATA >>build\log
cscript /nologo bin\buildss.js build\ACTIONHGR4* build\HGR4.IDX build\TOTAL.DATA build\TOTAL.DATA >>build\log
cscript /nologo bin\buildss.js build\ACTIONHGR5* build\HGR5.IDX build\TOTAL.DATA build\TOTAL.DATA >>build\log
cscript /nologo bin\buildss.js build\ACTIONHGR6* build\HGR6.IDX build\TOTAL.DATA build\TOTAL.DATA >>build\log
cscript /nologo bin\buildss.js build\ACTIONDHGR* build\DHGR.IDX build\TOTAL.DATA build\TOTAL.DATA >>build\log
echo done
rem precompute indexed files for GR action screenshots
rem note: these can be padded because they are not compressed
rem
echo|set/p="indexing GR action..."
1>nul copy /y nul build\ACTIONGR
for %%q in (res\ACTION.GR\*) do 1>nul >>build\ACTIONGR echo %%q
cscript /nologo bin\buildss.js build\ACTIONGR* build\GR.IDX build\TOTAL.DATA build\TOTAL.DATA pad >>build\log
echo done
rem
rem precompute indexed files for SHR artwork
rem note: these can not be padded because they are compressed and the decompressor needs the exact size
rem
echo|set/p="indexing shr..."
cscript /nologo bin\buildss.js res\ARTWORK.SHR build\ARTWORK.IDX build\TOTAL.DATA nul >>build\log
echo done
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
1>nul copy nul build\log
goto :EOF

:asmlauncher
1>build\buildnum.log git rev-list --count HEAD
for /f "tokens=*" %%q in (build\buildnum.log) do set _build=%%q
2>build\relbase.log %ACME% -DBUILDNUMBER=%_build% src\4cade.a
for /f "tokens=*" %%q in (build\relbase.log) do set _make=%%q
%ACME% -DBUILDNUMBER=%_build% -DRELBASE=$!_make:~-5,4! -r build\4cade.lst src\4cade.a
goto :EOF

:asmfx
echo|set/p="building fx..."
for %%q in (src\fx\*.a) do (
  for /f "tokens=* usebackq" %%k in (`find "^!to" %%q`) do set _to=%%k
  set _to=!_to:~0,1!
  if !_to!==t %ACME% %%q
)
echo done
goto :EOF

:asmprelaunch
echo|set/p="building prelaunch..."
for %%q in (src\prelaunch\*.a) do (
  for /f "tokens=* usebackq" %%k in (`find "^!to" %%q`) do set _to=%%k
  set _to=!_to:~0,1!
  if !_to!==t %ACME% %%q
)
echo done
goto :EOF

:asmproboot
%ACME% -r build\proboothd.lst src\proboothd\proboothd.a >> build\log
goto :EOF

:compress
for %%q in (res\action.dhgr.uncompressed\*) do if not exist res\action.dhgr\%%~nxq %EXOMIZER% res\action.dhgr.uncompressed\%%~nxq@0x4000 -o res\action.hgr\%%~nxq
for %%q in (res\action.hgr.uncompressed\*) do if not exist res\action.hgr\%%~nxq %EXOMIZER% res\action.hgr.uncompressed\%%~nxq@0x4000 -o res\action.hgr\%%~nxq
for %%q in (res\artwork.shr.uncompressed\*) do if not exist res\artwork.shr\%%~nxq %EXOMIZER% res\artwork.shr.uncompressed\%%~nxq@0x2000 -o res\artwork.shr\%%~nxq
