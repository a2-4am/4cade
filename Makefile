#
# 4cade Makefile
# assembles source code, optionally builds a disk image and mounts it
# note: Windows users should probably use winmake.bat instead
#
# original by Quinn Dunki on 2014-08-15
# One Girl, One Laptop Productions
# http://www.quinndunki.com/blondihacks
#
# adapted by 4am on 2018-08-19
#

DISK=4cade.hdv
VOLUME=TOTAL.REPLAY

# third-party tools required to build

# https://sourceforge.net/projects/acme-crossass/
# version 0.96.3 or later
ACME=acme

# https://github.com/mach-kernel/cadius
# version 1.4.0 or later
CADIUS=cadius

# https://bitbucket.org/magli143/exomizer/wiki/Home
# version 3.1.0 or later
EXOMIZER=exomizer mem -q -P23 -lnone

dsk: asm
	cp res/blank.hdv build/"$(DISK)" >>build/log
	cp res/_FileInformation.txt build/ >>build/log
	$(CADIUS) ADDFILE build/"$(DISK)" "/$(VOLUME)/" "build/LAUNCHER.SYSTEM" >>build/log
	rsync -aP res/PREFS.CONF build/PREFS.CONF >> build/log
	bin/padto.sh 512 build/PREFS.CONF >>build/log
	bin/buildokvs.sh "res/ATTRACT.CONF" "build/ATTRACT.IDX" >>build/log
	bin/buildfx.sh "res/FX.CONF" "build/FX.IDX" "build/FX.ALL" "build/FX" >>build/log
	bin/buildfx.sh "res/DFX.CONF" "build/DFX.IDX" "build/DFX.ALL" "build/FX" >>build/log
	bin/converthelp.sh res/HELPTEXT build/HELPTEXT >>build/log
	bin/converthelp.sh res/CREDITS build/CREDITS >>build/log
	for f in res/GAMEHELP/*; do bin/converthelp.sh "$$f" build/GAMEHELP/"$$(basename $$f)"; done >>build/log
	bin/buildhelp.sh "res/GAMES.CONF" "build/GAMEHELP.IDX" "build/GAMEHELP.ALL" "build/GAMEHELP" >>build/log
	rm -f build/SSDIR.CONF && touch build/SSDIR.CONF >>build/log
	for f in res/SS/*; do bin/buildokvs.sh "$$f" "build/SS/$$(basename $$f)" && echo "$$(basename $$f)" >> build/SSDIR.CONF; done >>build/log
	bin/buildfx.sh "build/SSDIR.CONF" "build/SLIDESHOW.IDX" "build/SLIDESHOW.ALL" "build/SS" >>build/log
	rm -f build/ATTRACTDIR.CONF && touch build/ATTRACTDIR.CONF >>build/log
	for f in res/ATTRACT/*; do bin/buildokvs.sh "$$f" "build/ATTRACT/$$(basename $$f)" && echo "$$(basename $$f)" >> build/ATTRACTDIR.CONF; done >>build/log
	bin/buildfx.sh "build/ATTRACTDIR.CONF" "build/MINIATTRACT.IDX" "build/MINIATTRACT.ALL" "build/ATTRACT" >>build/log
	bin/buildhelp.sh "res/GAMES.CONF" "build/PRELAUNCH.IDX" "build/PRELAUNCH.ALL" "build/PRELAUNCH" >>build/log
	for f in res/TITLE res/COVER res/HELP res/GAMES.CONF build/PREFS.CONF build/CREDITS build/HELPTEXT build/ATTRACT.IDX build/FX.IDX build/FX.ALL build/DFX.IDX build/DFX.ALL build/GAMEHELP.IDX build/GAMEHELP.ALL build/SLIDESHOW.IDX build/SLIDESHOW.ALL build/MINIATTRACT.IDX build/MINIATTRACT.ALL build/PRELAUNCH.IDX build/PRELAUNCH.ALL res/DECRUNCH res/JOYSTICK res/Finder.Data res/Finder.Root; do $(CADIUS) ADDFILE build/"$(DISK)" "/$(VOLUME)/" "$$f" >>build/log; done
	bin/buildfileinfo.sh res/TITLE.HGR "06" "4000" >>build/log
	bin/buildfileinfo.sh res/TITLE.DHGR "06" "4000" >>build/log
	bin/buildfileinfo.sh res/ACTION.HGR "06" "3FF8" >>build/log
	bin/buildfileinfo.sh res/ACTION.DHGR "06" "3FF8" >>build/log
	bin/buildfileinfo.sh res/ACTION.GR "06" "6000" >>build/log
	bin/buildfileinfo.sh res/ARTWORK.SHR "06" "1FF8" >>build/log
	bin/buildfileinfo.sh res/ICONS "CA" "0000" >>build/log
	for f in res/TITLE.HGR res/TITLE.DHGR res/ACTION.HGR res/ACTION.DHGR res/ACTION.GR res/ARTWORK.SHR res/DEMO res/TITLE.ANIMATED res/ICONS; do rm -f "$$f"/.DS_Store; $(CADIUS) ADDFOLDER build/"$(DISK)" "/$(VOLUME)/$$(basename $$f)" "$$f" >>build/log; done
	for i in 1 2 3 4 5 6; do $(CADIUS) RENAMEFILE build/"$(DISK)" "/$(VOLUME)/DEMO/SPCARTOON.$${i}$${i}" "SPCARTOON.$${i}." >>build/log; done
	$(CADIUS) CREATEFOLDER build/"$(DISK)" "/$(VOLUME)/FX/" >>build/log
	for f in build/FX/COVERFADE build/FX/GR.FIZZLE build/FX/SHR.FIZZLE build/FX/*.DATA; do $(CADIUS) ADDFILE "build/$(DISK)" "/$(VOLUME)/FX/" "$$f"; done >>build/log
	for f in res/dsk/*.po; do $(CADIUS) EXTRACTVOLUME "$${f}" build/X/ >> build/log; done
	rm -f build/X/**/.DS_Store build/X/**/PRODOS* build/X/**/LOADER.SYSTEM*
	$(CADIUS) CREATEFOLDER build/"$(DISK)" "/$(VOLUME)/X/" >>build/log
	for f in build/X/*; do $(CADIUS) ADDFOLDER build/"$(DISK)" "/$(VOLUME)/X/$$(basename $$f)" "$$f"; done >>build/log
	bin/changebootloader.sh build/"$(DISK)" build/proboothd

asm: asmlauncher asmfx asmprelaunch asmproboot

asmlauncher: md
	$(ACME) -DBUILDNUMBER=`git rev-list --count HEAD` src/4cade.a 2>build/relbase.log
	$(ACME) -r build/4cade.lst -DBUILDNUMBER=`git rev-list --count HEAD` -DRELBASE=`cat build/relbase.log | grep "RELBASE =" | cut -d"=" -f2 | cut -d"(" -f2 | cut -d")" -f1` src/4cade.a

asmfx: md
	for f in src/fx/*.a; do grep "^\!to" $${f} >/dev/null && $(ACME) $${f} >> build/log || true; done
	bin/buildfileinfo.sh build/FX "06" "6000" >>build/log

asmprelaunch: md
	for f in src/prelaunch/*.a; do grep "^\!to" $${f} >/dev/null && $(ACME) $${f} >> build/log; done

asmproboot: md
	$(ACME) -r build/proboothd.lst src/proboothd/proboothd.a >> build/log

compress: md
	for f in res/ACTION.HGR.UNCOMPRESSED/*; do  o=res/ACTION.HGR/$$(basename $$f);  [ -f "$$o" ] || ${EXOMIZER} "$$f"@0x4000 -o "$$o" >>build/log; done
	for f in res/ACTION.DHGR.UNCOMPRESSED/*; do o=res/ACTION.DHGR/$$(basename $$f); [ -f "$$o" ] || ${EXOMIZER} "$$f"@0x4000 -o "$$o" >>build/log; done
	for f in res/ARTWORK.SHR.UNCOMPRESSED/*; do o=res/ARTWORK.SHR/$$(basename $$f); [ -f "$$o" ] || ${EXOMIZER} "$$f"@0x2000 -o "$$o" >>build/log; done

attract: compress
	bin/check-attract-mode.sh
	bin/generate-mini-attract-mode.sh

mount: dsk
	osascript bin/V2Make.scpt "`pwd`" bin/4cade.vii build/"$(DISK)"

md:
	mkdir -p build/X build/FX build/PRELAUNCH build/ATTRACT build/SS build/GAMEHELP
	touch build/log

clean:
	rm -rf build/ || rm -rf build

all: clean dsk mount

al: all
