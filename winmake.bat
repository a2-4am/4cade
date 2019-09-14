@echo off
rem
rem 4cade Makefile for Windows
rem assembles source code, optionally builds a disk image
rem
rem a qkumba monstrosity from 2018-10-29
rem

setlocal enabledelayedexpansion
set DISK=4cade.2mg
set VOLUME=A.4AM.PACK

rem third-party tools required to build (must be in path)
rem https://sourceforge.net/projects/acme-crossass/
set ACME=acme
rem https://www.brutaldeluxe.fr/products/crossdevtools/cadius/
rem https://github.com/mach-kernel/cadius
set CADIUS=cadius

if "%1" equ "asm" (
:asm
2>nul md build
2>nul md build\po
2>nul md build\X
2>nul md build\TITLE.HGR
2>nul md build\TITLE.DHGR
2>nul md build\ACTION.HGR
2>nul md build\ACTION.DHGR
2>nul md build\ACTION.GR
2>nul md build\ARTWORK.SHR
2>nul md build\ATTRACT
2>nul md build\SS
2>nul md build\DEMO
2>nul md build\FX
2>nul md build\CHEAT

2>build\out.txt %ACME% -r build\4cade.lst src\4cade.a
for /f "tokens=*" %%q in (build\out.txt) do set _make=%%q
%ACME% -DRELBASE=$!_make:~-5,4! -r build\4cade.lst src\4cade.a
%ACME% src\fx\fx.cover.fade.a
%ACME% src\fx\fx.dhgr.fizzle.a
%ACME% src\fx\fx.dhgr.fizzle.white.a
%ACME% src\fx\fx.dhgr.ripple.a
%ACME% src\fx\fx.dhgr.ripple.white.a
%ACME% src\fx\fx.dhgr.iris.a
%ACME% src\fx\fx.dhgr.iris.white.a
%ACME% src\fx\fx.dhgr.radial.a
%ACME% src\fx\fx.dhgr.radial.white.a
%ACME% src\fx\fx.dhgr.radial2.a
%ACME% src\fx\fx.dhgr.radial2.white.a
%ACME% src\fx\fx.dhgr.radial3.a
%ACME% src\fx\fx.dhgr.radial3.white.a
%ACME% src\fx\fx.dhgr.radial4.a
%ACME% src\fx\fx.dhgr.radial4.white.a
%ACME% src\fx\fx.dhgr.radial5.a
%ACME% src\fx\fx.dhgr.radial5.white.a
%ACME% src\fx\fx.dhgr.star.a
%ACME% src\fx\fx.dhgr.star.white.a
%ACME% src\fx\fx.hgr.diagonal.a
%ACME% src\fx\fx.hgr.interlock.ud.a
%ACME% src\fx\fx.hgr.interlock.lr.a
%ACME% src\fx\fx.hgr.spiral.a
%ACME% src\fx\fx.hgr.fourspiral.a
%ACME% src\fx\fx.hgr.fizzle.a
%ACME% src\fx\fx.hgr.bar.dissolve.a
%ACME% src\fx\fx.hgr.block.fizzle.a
%ACME% src\fx\fx.hgr.block.fizzle.white.a
%ACME% src\fx\fx.hgr.2pass.lr.a
%ACME% src\fx\fx.hgr.crystal.a
%ACME% src\fx\fx.hgr.foursquare.white.a
%ACME% src\fx\fx.hgr.onesquare.white.a
%ACME% src\fx\fx.hgr.diamond.a
%ACME% src\fx\fx.hgr.checkerboard.white.a
%ACME% src\fx\fx.hgr.halfblock.fizzle.a
%ACME% src\fx\fx.hgr.halfblock.fizzle.white.a
%ACME% src\fx\fx.hgr.stagger.ud.a
%ACME% src\fx\fx.hgr.stagger.ud.white.a
%ACME% src\fx\fx.hgr.stagger.lr.a
%ACME% src\fx\fx.hgr.stagger.lr.white.a
%ACME% src\fx\fx.hgr.corner.circle.a
%ACME% src\fx\fx.hgr.sunrise.a
%ACME% src\fx\fx.hgr.sunset.a
%ACME% src\fx\fx.hgr.radial.a
%ACME% src\fx\fx.hgr.radial2.a
%ACME% src\fx\fx.hgr.radial3.a
%ACME% src\fx\fx.hgr.radial4.a
%ACME% src\fx\fx.hgr.radial5.a
%ACME% src\fx\fx.hgr.split.ud.intro.a
%ACME% src\fx\fx.hgr.iris.a
%ACME% src\fx\fx.hgr.ripple.a
%ACME% src\fx\fx.hgr.ripple2.a
%ACME% src\fx\fx.hgr.star.a
%ACME% src\fx\fx.hgr.star.white.a
%ACME% src\fx\fx.shr.fizzle.a
%ACME% src\fx\fx.gr.fizzle.a
for %%q in (src\cheat\*.a) do %ACME% %%q
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
rem %CADIUS% CREATEVOLUME "build\%DISK%" "%VOLUME%" 32766KB >>build\log
1>nul copy /y res\blank.2mg "build\%DISK%" >>build\log
1>nul copy /y res\_FileInformation.txt build\ >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\LAUNCHER.SYSTEM" >>build\log
1>nul copy /y res\attract.conf build\ATTRACT.CONF >>build\log
1>nul copy /y res\dfx.conf build\DFX.CONF >>build\log
1>nul copy /y res\fx.conf build\FX.CONF >>build\log
1>nul copy /y res\games.conf build\GAMES.CONF >>build\log
1>nul copy /y res\prefs.conf build\PREFS.CONF >>build\log
1>nul copy /y res\credits.txt build\CREDITS >>build\log
cscript /nologo bin\padto.js 512 build\PREFS.CONF
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\TITLE" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\COVER" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\PREFS.CONF" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\GAMES.CONF" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\ATTRACT.CONF" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\FX.CONF" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\DFX.CONF" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\CREDITS" >>build\log
cscript /nologo bin\rsync.js res\title.hgr\* build\TITLE.HGR >>build\log
cscript /nologo bin\buildfileinfo.js build\TITLE.HGR "06" "4000" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/TITLE.HGR" "build\TITLE.HGR" >>build\log
cscript /nologo bin\rsync.js res\title.dhgr\* build\TITLE.DHGR >>build\log
cscript /nologo bin\buildfileinfo.js build\TITLE.DHGR "06" "4000" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/TITLE.DHGR" "build\TITLE.DHGR" >>build\log
cscript /nologo bin\rsync.js res\action.hgr\* build\ACTION.HGR >>build\log
cscript /nologo bin\buildfileinfo.js build\ACTION.HGR "06" "4000" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/ACTION.HGR" "build\ACTION.HGR" >>build\log
cscript /nologo bin\rsync.js res\action.dhgr\* build\ACTION.DHGR >>build\log
cscript /nologo bin\buildfileinfo.js build\ACTION.DHGR "06" "4000" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/ACTION.DHGR" "build\ACTION.DHGR" >>build\log
cscript /nologo bin\rsync.js res\action.gr\* build\ACTION.GR >>build\log
cscript /nologo bin\buildfileinfo.js build\ACTION.GR "06" "6000" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/ACTION.GR" "build\ACTION.GR" >>build\log
cscript /nologo bin\rsync.js res\artwork.shr\* build\ARTWORK.SHR >>build\log
cscript /nologo bin\buildfileinfo.js build\ARTWORK.SHR "C1" "2000" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/ARTWORK.SHR" "build\ARTWORK.SHR" >>build\log
cscript /nologo bin\rsync.js res\attract\* build\ATTRACT >>build\log
cscript /nologo bin\buildfileinfo.js build\ATTRACT "04" "8000" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/ATTRACT" "build\ATTRACT" >>build\log
cscript /nologo bin\rsync.js res\ss\* build\SS >>build\log
cscript /nologo bin\buildfileinfo.js build\SS "04" "4000" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/SS" "build\SS" >>build\log
cscript /nologo bin\rsync.js res\demo\* build\DEMO >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/DEMO" "build\DEMO" >>build\log
%CADIUS% RENAMEFILE "build\%DISK%" "/%VOLUME%/DEMO/SPCARTOON.11" "SPCARTOON.1." >>build\log
%CADIUS% RENAMEFILE "build\%DISK%" "/%VOLUME%/DEMO/SPCARTOON.22" "SPCARTOON.2." >>build\log
%CADIUS% RENAMEFILE "build\%DISK%" "/%VOLUME%/DEMO/SPCARTOON.33" "SPCARTOON.3." >>build\log
%CADIUS% RENAMEFILE "build\%DISK%" "/%VOLUME%/DEMO/SPCARTOON.44" "SPCARTOON.4." >>build\log
%CADIUS% RENAMEFILE "build\%DISK%" "/%VOLUME%/DEMO/SPCARTOON.55" "SPCARTOON.5." >>build\log
%CADIUS% RENAMEFILE "build\%DISK%" "/%VOLUME%/DEMO/SPCARTOON.66" "SPCARTOON.6." >>build\log
cscript /nologo bin\rsync.js res\fx\* build\FX >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/FX" "build\FX" >>build\log
%CADIUS% CREATEFOLDER "build\%DISK%" "/%VOLUME%/X/" >>build\log
cscript /nologo bin\do2po.js res\dsk build\po
cscript /nologo bin\rsync.js res\dsk\*.po build\po
cscript /nologo bin\extract.js build\po >>build\log
echo y|1>nul 2>nul del /s build\X\.DS_Store
echo y|1>nul 2>nul del /s build\X\PRODOS
echo y|1>nul 2>nul del /s build\X\LOADER.SYSTEM
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/X" "build\X" >>build\log
cscript /nologo bin\buildfileinfo.js build\CHEAT "06" "014D" >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/CHEAT" "build\CHEAT" >>build\log
cscript /nologo bin\changebootloader.js "build\%DISK%" res\proboothd
goto :EOF
)

if "%1" equ "chd" (
call :dsk
chdman createhd -c none -isb 64 -i "build\%DISK%" -o "build\%DISK%.chd" >>build\log
goto :EOF
)

echo usage: %0 clean / asm / dsk / chd
