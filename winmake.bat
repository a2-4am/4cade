@echo off
rem
rem 4cade Makefile for Windows
rem assembles source code, optionally builds a disk image
rem
rem a qkumba monstrosity from 2018-10-29
rem

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
2>nul md build\HGR
2>nul md build\DHGR
2>nul md build\SS
2>nul md build\DEMO
2>nul md build\FX

%ACME% -r build\4cade.lst src\4cade.a
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
%CADIUS% CREATEVOLUME "build\%DISK%" "%VOLUME%" 32766KB >>build\log
1>nul copy /y res\_FileInformation.txt build\ >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "build\LAUNCHER.SYSTEM" >>build\log
%CADIUS% CREATEFOLDER "build\%DISK%" "/%VOLUME%/X/" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\GAMES.CONF" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\ATTRACT.CONF" >>build\log
%CADIUS% ADDFILE "build\%DISK%" "/%VOLUME%/" "res\FX.CONF" >>build\log
1>nul copy /y res\hgr\* build\HGR >>build\log
cscript /nologo bin/buildfileinfo.js build\HGR >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/HGR" "build/HGR" >>build/log
1>nul copy /y res\dhgr\* build\DHGR >>build\log
cscript /nologo bin/buildfileinfo.js build\DHGR >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/DHGR" "build/DHGR" >>build\log
1>nul copy /y res\ss\* build\SS >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/SS" "build/SS" >>build\log
1>nul copy /y res\demo\* build\DEMO >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/DEMO" "build/DEMO" >>build\log
1>nul copy /y res\fx\* build\FX >>build\log
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/FX" "build/FX" >>build\log
cscript /nologo bin/do2po.js res\dsk\ build\po\
%CADIUS% ADDFOLDER "build\%DISK%" "/%VOLUME%/X" "build/X" >>build\log
cscript /nologo bin/changebootloader.js "build\%DISK%" res\proboothd
goto :EOF
)

echo usage: %0 clean / asm / dsk
