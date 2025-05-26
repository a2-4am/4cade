@echo off
rem
rem 4cade Makefile for Windows
rem assembles source code, optionally builds a disk image
rem note: non-Windows users should probably use Makefile instead
rem
rem a qkumba monstrosity from 2018-10-29
rem

setlocal enabledelayedexpansion
set DISK=4cade.hdv
set VOLUME=TOTAL.REPLAY

rem third-party tools required to build (must be in path)

rem https://sourceforge.net/projects/acme-crossass/
rem version 0.97 or later
set ACME=acme

rem https://github.com/mach-kernel/cadius
rem version 1.4.6 or later
set CADIUS=cadius

rem https://github.com/
set GIT=git

rem https://bitbucket.org/magli143/exomizer/wiki/Home
rem version 3.1.0 or later
set EXOMIZER=exomizer mem -q -P23 -lnone

if "%1" equ "dsk" (
call :clean
call :index
if "%2". equ "". (
  call :asmproboot
  call :asmlauncher
  1>nul copy /y res\blank.hdv "build\%DISK%" >>build\log
  1>nul copy /y res\_FileInformation.txt build\ >>build\log
  %CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\LAUNCHER.SYSTEM" -C >>build\log
  1>nul copy /y "res\PREFS.CONF" "build" >>build\log
  cscript /nologo bin\padto.js 512 build\PREFS.CONF
  rem
  rem create _FileInformation.txt files for subdirectories
  rem
  1>nul copy /y src\prelaunch\_FileInformation.txt build\PRELAUNCH >>build/log
  rem
  rem add everything to the disk
  rem
)
echo|set/p="adding files..."
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\TOTAL.DATA" -C >>build\log
if "%2". equ "". (
  for %%q in (build\PREFS.CONF res\Finder.Data res\Finder.Root) do %CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "%%q" -C >>build\log
  for %%q in (res\TITLE.ANIMATED res\ICONS build\PRELAUNCH build\X) do (
    1>nul 2>nul del /s "%%q\.DS_Store"
    %CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/%%~nxq" %%q -C >>build\log
  )
  cscript /nologo bin\changebootloader.js "build\%DISK%" build\proboothd
)
echo done
goto :EOF
)

if "%1" equ "index" (
call :index
goto :EOF
)

if "%1" equ "clean" (
if "%2". neq "". (
1>nul move build\%DISK%
)
:clean
echo y|1>nul 2>nul rd build /s
if "%2". neq "". (
md build
1>nul move %DISK% build\%DISK%
%CADIUS% DELETEFILE "build\%DISK%" "/%VOLUME%/TOTAL.DATA" >>build\log
)
goto :EOF
)

if "%1" equ "compress" (
call :compress
goto :EOF
)

echo usage: %0 clean / dsk
goto :EOF

:index
call :md
call :asmfx
call :asmprelaunch
call :asmdemo
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
for %%q in (build\GAMEHELP\*) do %EXOMIZER% %%q@0x900 -o build\GAMEHELP.COMPRESSED\%%~nxq
echo done
rem
rem create a list of all game filenames, without metadata or display names, sorted by game filename
rem
cscript /nologo bin\makesorted.js
cscript /nologo bin\builddisplaynames.js
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
rem precompute indexed files for HGR & DHGR titles
rem note: these are not padded because they are all an exact block-multiple anyway
rem
echo|set/p="indexing titles..."
cscript /nologo bin\padto.js 512 build\TOTAL.DATA
cscript /nologo bin\buildss.js res\TITLE.HGR build\TITLE.IDX build\HGR.TITLES.LOG build\TOTAL.DATA build\TOTAL.DATA >>build\log
cscript /nologo bin\buildss.js res\TITLE.DHGR build\DTITLE.IDX build\DHGR.TITLES.LOG build\TOTAL.DATA build\TOTAL.DATA >>build\log
cscript /nologo bin\addfile.js res\COVER build\index\res.cover.idx.a
cscript /nologo bin\addfile.js res\TITLE build\index\res.title.idx.a
cscript /nologo bin\addfile.js res\HELP build\index\res.help.idx.a
echo done
rem
rem precompute indexed files for game help
rem note: these can not be padded because they are compressed and the decompressor needs the exact size
rem
echo|set/p="indexing gamehelp..."
cscript /nologo bin\makesorted.js
cscript /nologo bin\buildpre.js build\GAMEHELP.COMPRESSED build\GAMEHELP.IDX build\TOTAL.DATA >>build\log
echo done
rem
rem precompute indexed files for slideshows
rem note: these can be padded because they're loaded into $800 at a time when $800..$1FFF is clobber-able
rem
echo|set/p="indexing slideshows..."
for %%q in (res\SS\*) do (
  set _ss=%%~nxq
  set _ss=!_ss:~0,3!
  if !_ss!==ACT (
    cscript /nologo bin\buildslideshow.js %%q build\SS\%%~nxq -d >>build\log
  ) else (
    cscript /nologo bin\buildslideshow.js %%q build\SS\%%~nxq >>build\log
  )
)
cscript /nologo bin\buildss.js build\SS build\SLIDESHOW.IDX nul build\TOTAL.DATA nul pad >>build\log
for %%q in (A B C D E F G H I J K L M N O P) do for %%k in (res\ATTRACT\%%q*) do cscript /nologo bin\buildokvs.js %%k build\ATTRACT0\%%~nxk >>build\log
for %%q in (Q R S T U V W X Y Z) do for %%k in (res\ATTRACT\%%q*) do cscript /nologo bin\buildokvs.js %%k build\ATTRACT1\%%~nxk >>build\log
cscript /nologo bin\buildss.js build\ATTRACT0 build\MINIATTRACT0.IDX nul build\TOTAL.DATA nul pad >>build\log
cscript /nologo bin\buildss.js build\ATTRACT1 build\MINIATTRACT1.IDX nul build\TOTAL.DATA nul pad >>build\log
echo done
rem
rem precompute indexed files for graphic effects
rem note: these can be padded because they're loaded into $6000 at a time when $6000..$BEFF is clobber-able
rem
echo|set/p="indexing fx..."
cscript /nologo bin\buildfx.js res\FX.CONF build\FX.IDX build\TOTAL.DATA build\FX.INDEXED >>build\log
cscript /nologo bin\buildfx.js res\DFX.CONF build\DFX.IDX build\TOTAL.DATA build\FX.INDEXED >>build\log
cscript /nologo bin\buildfx.js res\SFX.CONF build\SFX.IDX build\TOTAL.DATA build\FX.INDEXED >>build\log
dir /b build\FXCODE >build\fxcode.lst
cscript /nologo bin\buildfx.js build\fxcode.lst build\FXCODE.IDX build\TOTAL.DATA build\FXCODE >>build\log
rem
rem precompute indexed files for coordinates files loaded by graphic effects
rem note: these can not be padded because some of them are loaded into tight spaces near the unclobberable top of main memory
rem
dir /b build\FXDATA >build\fxdata.lst
cscript /nologo bin\buildfx.js build\fxdata.lst build\FXDATA.IDX build\TOTAL.DATA build\FXDATA >>build\log
echo done
rem
rem precompute indexed files for HGR & DHGR action screenshots
rem note: these can not be padded because they are compressed and the decompressor needs the exact size
rem
echo|set/p="indexing (d)hgr action..."
1>nul copy /y nul build\ACTIONHGR0
1>nul copy /y nul build\ACTIONHGR1
1>nul copy /y nul build\ACTIONHGR2
1>nul copy /y nul build\ACTIONHGR3
1>nul copy /y nul build\ACTIONHGR4
1>nul copy /y nul build\ACTIONHGR5
1>nul copy /y nul build\ACTIONHGR6
1>nul copy /y nul build\ACTIONDHGR
for %%q in (A B C D) do for %%k in (res\ACTION.HGR\%%q*) do 1>nul >>build\ACTIONHGR0 echo %%k
for %%q in (E F G H) do for %%k in (res\ACTION.HGR\%%q*) do 1>nul >>build\ACTIONHGR1 echo %%k
for %%q in (I J K L) do for %%k in (res\ACTION.HGR\%%q*) do 1>nul >>build\ACTIONHGR2 echo %%k
for %%q in (M N O P) do for %%k in (res\ACTION.HGR\%%q*) do 1>nul >>build\ACTIONHGR3 echo %%k
for %%q in (Q R S T) do for %%k in (res\ACTION.HGR\%%q*) do 1>nul >>build\ACTIONHGR4 echo %%k
for %%q in (U V W X) do for %%k in (res\ACTION.HGR\%%q*) do 1>nul >>build\ACTIONHGR5 echo %%k
for %%q in (Y Z) do for %%k in (res\ACTION.HGR\%%q*) do 1>nul >>build\ACTIONHGR6 echo %%k
for %%q in (res\ACTION.DHGR\*) do 1>nul >>build\ACTIONDHGR echo %%q
cscript /nologo bin\buildss.js build\ACTIONHGR0* build\HGR0.IDX nul build\TOTAL.DATA nul >>build\log
cscript /nologo bin\buildss.js build\ACTIONHGR1* build\HGR1.IDX nul build\TOTAL.DATA build\TOTAL.DATA >>build\log
cscript /nologo bin\buildss.js build\ACTIONHGR2* build\HGR2.IDX nul build\TOTAL.DATA build\TOTAL.DATA >>build\log
cscript /nologo bin\buildss.js build\ACTIONHGR3* build\HGR3.IDX nul build\TOTAL.DATA build\TOTAL.DATA >>build\log
cscript /nologo bin\buildss.js build\ACTIONHGR4* build\HGR4.IDX nul build\TOTAL.DATA build\TOTAL.DATA >>build\log
cscript /nologo bin\buildss.js build\ACTIONHGR5* build\HGR5.IDX nul build\TOTAL.DATA build\TOTAL.DATA >>build\log
cscript /nologo bin\buildss.js build\ACTIONHGR6* build\HGR6.IDX nul build\TOTAL.DATA build\TOTAL.DATA >>build\log
cscript /nologo bin\buildss.js build\ACTIONDHGR* build\DHGR.IDX nul build\TOTAL.DATA build\TOTAL.DATA >>build\log
echo done
rem precompute indexed files for GR and DGR action screenshots
rem note: these can be padded because they are not compressed
rem
echo|set/p="indexing (d)gr action..."
1>nul copy /y nul build\ACTIONGR
1>nul copy /y nul build\ACTIONDGR
for %%q in (res\ACTION.GR\*) do 1>nul >>build\ACTIONGR echo %%q
for %%q in (res\ACTION.DGR\*) do 1>nul >>build\ACTIONDGR echo %%q
cscript /nologo bin\buildss.js build\ACTIONGR* build\GR.IDX nul build\TOTAL.DATA build\TOTAL.DATA pad >>build\log
cscript /nologo bin\buildss.js build\ACTIONDGR* build\DGR.IDX nul build\TOTAL.DATA build\TOTAL.DATA pad >>build\log
echo done
rem
rem precompute indexed files for SHR artwork
rem note: these can not be padded because they are compressed and the decompressor needs the exact size
rem
echo|set/p="indexing shr..."
cscript /nologo bin\buildss.js res\ARTWORK.SHR build\ARTWORK.IDX nul build\TOTAL.DATA nul >>build\log
echo done
rem
rem precompute indexed files for demo launchers
rem note: these can not be padded because some of them are loaded too close to $C000
rem
echo|set/p="indexing demos..."
cscript /nologo bin\buildss.js build\DEMO build\DEMO.IDX nul build\TOTAL.DATA nul >>build\log
echo done
rem
rem precompute indexed files for single-load game binaries
rem note: these can be padded because they are loaded at a time when all of main memory is clobber-able
rem
echo|set/p="indexing single-loaders..."
for %%q in (res\dsk\*.po) do %CADIUS% EXTRACTVOLUME "%%q" build\X\ >>build\log
1>nul 2>nul del /s build\X\.DS_Store build\X\PRODOS* build\X\LOADER.SYSTEM* build\X\_FileInformation.txt
1>nul copy /y nul build\XSINGLE.IDX
cscript /nologo bin\buildsingle.js build\X.INDEXED build\XSINGLE.IDX build\TOTAL.DATA pad >>build\log
cscript /nologo bin\flatten.js
echo done
rem
rem create search indexes for each variation of (game-requires-joystick) X (game-requires-128K)
rem in the form of OKVS data structures, plus game counts in the form of source files
rem
echo|set/p="indexing search..."
cscript /nologo bin\buildsearch.js "00" build\index\count00.a build\SEARCH00.IDX
cscript /nologo bin\buildsearch.js "0" build\index\count01.a build\SEARCH01.IDX
cscript /nologo bin\buildsearch.js ".0" build\index\count10.a build\SEARCH10.IDX
cscript /nologo bin\buildsearch.js "." build\index\count11.a build\SEARCH11.IDX
echo done
rem
rem add IDX files to the combined index file and generate
rem the index records that callers use to reference them
rem
echo|set/p="preparing index file..."
cscript /nologo bin\addfile.js build\SEARCH00.IDX build\index\search00.idx.a
cscript /nologo bin\addfile.js res\CACHE00.IDX build\index\cache00.idx.a
cscript /nologo bin\addfile.js build\SEARCH01.IDX build\index\search01.idx.a
cscript /nologo bin\addfile.js res\CACHE01.IDX build\index\cache01.idx.a
cscript /nologo bin\addfile.js build\SEARCH10.IDX build\index\search10.idx.a
cscript /nologo bin\addfile.js res\CACHE10.IDX build\index\cache10.idx.a
cscript /nologo bin\addfile.js build\SEARCH11.IDX build\index\search11.idx.a
cscript /nologo bin\addfile.js res\CACHE11.IDX build\index\cache11.idx.a
cscript /nologo bin\addfile.js build\PRELAUNCH.IDX build\index\prelaunch.idx.a
cscript /nologo bin\addfile.js build\ATTRACT.IDX build\index\attract.idx.a
cscript /nologo bin\addfile.js build\DEMO.IDX build\index\demo.idx.a
cscript /nologo bin\addfile.js build\XSINGLE.IDX build\index\xsingle.idx.a
cscript /nologo bin\addfile.js build\FX.IDX build\index\fx.idx.a
cscript /nologo bin\addfile.js build\DFX.IDX build\index\dfx.idx.a
cscript /nologo bin\addfile.js build\SFX.IDX build\index\sfx.idx.a
cscript /nologo bin\addfile.js build\FXCODE.IDX build\index\fxcode.idx.a
cscript /nologo bin\addfile.js build\FXDATA.IDX build\index\fxdata.idx.a
cscript /nologo bin\addfile.js build\GAMEHELP.IDX build\index\gamehelp.idx.a
cscript /nologo bin\addfile.js build\SLIDESHOW.IDX build\index\slideshow.idx.a
cscript /nologo bin\addfile.js build\MINIATTRACT0.IDX build\index\miniattract0.idx.a
cscript /nologo bin\addfile.js build\MINIATTRACT1.IDX build\index\miniattract1.idx.a
cscript /nologo bin\addfile.js build\TITLE.IDX build\index\title.idx.a
cscript /nologo bin\addfile.js build\DTITLE.IDX build\index\dtitle.idx.a
cscript /nologo bin\addfile.js build\HGR0.IDX build\index\hgr0.idx.a
cscript /nologo bin\addfile.js build\HGR1.IDX build\index\hgr1.idx.a
cscript /nologo bin\addfile.js build\HGR2.IDX build\index\hgr2.idx.a
cscript /nologo bin\addfile.js build\HGR3.IDX build\index\hgr3.idx.a
cscript /nologo bin\addfile.js build\HGR4.IDX build\index\hgr4.idx.a
cscript /nologo bin\addfile.js build\HGR5.IDX build\index\hgr5.idx.a
cscript /nologo bin\addfile.js build\HGR6.IDX build\index\hgr6.idx.a
cscript /nologo bin\addfile.js build\DHGR.IDX build\index\dhgr.idx.a
cscript /nologo bin\addfile.js build\GR.IDX build\index\gr.idx.a
cscript /nologo bin\addfile.js build\DGR.IDX build\index\dgr.idx.a
cscript /nologo bin\addfile.js build\ARTWORK.IDX build\index\artwork.idx.a
rem
rem add additional miscellaneous files
rem
cscript /nologo bin\addfile.js build\COVERFADE build\index\coverfade.idx.a
cscript /nologo bin\addfile.js build\GR.FIZZLE build\index\gr.fizzle.idx.a
cscript /nologo bin\addfile.js build\DGR.FIZZLE build\index\dgr.fizzle.idx.a
cscript /nologo bin\addfile.js build\HELPTEXT build\index\helptext.idx.a
cscript /nologo bin\addfile.js build\CREDITS build\index\credits.idx.a
cscript /nologo bin\addfile.js res\JOYSTICK build\index\joystick.idx.a
echo done
goto :EOF

:md
2>nul md build
2>nul md build\index
2>nul md build\X.INDEXED
2>nul md build\FX.INDEXED
2>nul md build\FXDATA
2>nul md build\FXDATA.UNCOMPRESSED
2>nul md build\FXCODE
2>nul md build\PRELAUNCH
2>nul md build\PRELAUNCH.INDEXED
2>nul md build\ATTRACT0
2>nul md build\ATTRACT1
2>nul md build\SS
2>nul md build\GAMEHELP
2>nul md build\GAMEHELP.COMPRESSED
2>nul md build\DEMO
1>nul copy nul build\log
goto :EOF

:asmlauncher
2>nul 1>build\buildnum.log %GIT% rev-list --count HEAD
if errorlevel 1 (set _build=0) else for /f "tokens=*" %%q in (build\buildnum.log) do set _build=%%q
2>build\relbase.log %ACME% -DBUILDNUMBER=%_build% src/4cade.a
for /f "tokens=*" %%q in (build\relbase.log) do set _make=%%q
%ACME% -DBUILDNUMBER=%_build% -DRELBASE=$!_make:~-5,4! -r build/4cade.lst src/4cade.a
goto :EOF

:asmdemo
echo|set/p="building demos..."
for %%q in (src\demo\*.a) do (
  for /f "tokens=* usebackq" %%k in (`find "^!to" %%q`) do set _to=%%k
  set _to=!_to:~0,1!
  if !_to!==t %ACME% %%q
)
echo done
goto :EOF

:asmfx
echo|set/p="building fx..."
for %%q in (src\fx\*.a) do (
  for /f "tokens=* usebackq" %%k in (`find "^!to" %%q`) do set _to=%%k
  set _to=!_to:~0,1!
  if !_to!==t %ACME% %%q
)
for %%q in (build\FXDATA.UNCOMPRESSED\*) do (
  set _fx=%%~nxq
  set _fy=!_fx:~-4!
  set _fz=!_fx:~0,-5!
  %EXOMIZER% %%q@0x!_fy! -o build\FXDATA\!_fz!
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
%ACME% -r build/proboothd.lst src/proboothd/proboothd.a >> build\log
goto :EOF

:compress
for %%q in (res\action.dhgr.uncompressed\*) do if not exist res\action.dhgr\%%~nxq %EXOMIZER% res\action.dhgr.uncompressed\%%~nxq@0x4000 -o res\action.hgr\%%~nxq
for %%q in (res\action.hgr.uncompressed\*) do if not exist res\action.hgr\%%~nxq %EXOMIZER% res\action.hgr.uncompressed\%%~nxq@0x4000 -o res\action.hgr\%%~nxq
for %%q in (res\artwork.shr.uncompressed\*) do if not exist res\artwork.shr\%%~nxq %EXOMIZER% res\artwork.shr.uncompressed\%%~nxq@0x2000 -o res\artwork.shr\%%~nxq
for %%q in (res\title.hgr.uncompressed\*) do if not exist res\title.hgr\%%~nxq %EXOMIZER% res\title.hgr.uncompressed\%%~nxq@0x2000 -o res\title.hgr\%%~nxq
