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

DISK=4cade.2mg
VOLUME=TOTAL.REPLAY

# third-party tools required to build

# https://sourceforge.net/projects/acme-crossass/
ACME=acme

# https://github.com/sicklittlemonkey/cadius
# version 1.4.0 or later
CADIUS=cadius

# https://bitbucket.org/magli143/exomizer/wiki/Home
EXOMIZER=exomizer mem -q -P23 -lnone

dsk: md asm
	cp res/blank.2mg build/"$(DISK)" >>build/log
	cp res/_FileInformation.txt build/ >>build/log
	$(CADIUS) ADDFILE build/"$(DISK)" "/$(VOLUME)/" "build/LAUNCHER.SYSTEM" >>build/log
	rsync -aP res/PREFS.CONF build/PREFS.CONF >> build/log
	bin/padto.sh 512 build/PREFS.CONF >>build/log
	for f in res/TITLE res/COVER res/HELP res/GAMES.CONF res/ATTRACT.CONF res/FX.CONF res/DFX.CONF build/PREFS.CONF res/CREDITS res/HELPTEXT res/DECRUNCH; do $(CADIUS) ADDFILE build/"$(DISK)" "/$(VOLUME)/" "$$f" >>build/log; done
	bin/buildfileinfo.sh res/TITLE.HGR "06" "4000" >>build/log
	bin/buildfileinfo.sh res/TITLE.DHGR "06" "4000" >>build/log
	bin/buildfileinfo.sh res/ACTION.HGR "06" "3FF8" >>build/log
	bin/buildfileinfo.sh res/ACTION.DHGR "06" "3FF8" >>build/log
	bin/buildfileinfo.sh res/ACTION.GR "06" "6000" >>build/log
	bin/buildfileinfo.sh res/ARTWORK.SHR "06" "1FF8" >>build/log
	bin/buildfileinfo.sh res/ATTRACT "04" "8000" >>build/log
	bin/buildfileinfo.sh res/SS "04" "4000" >>build/log
	for f in res/TITLE.* res/ACTION.* res/ARTWORK.* res/ATTRACT res/SS res/DEMO res/TITLE.ANIMATED; do $(CADIUS) ADDFOLDER build/"$(DISK)" "/$(VOLUME)/$$(basename $$f)" "$$f" >>build/log; done
	for i in 1 2 3 4 5 6; do $(CADIUS) RENAMEFILE build/"$(DISK)" "/$(VOLUME)/DEMO/SPCARTOON.$${i}$${i}" "SPCARTOON.$${i}." >>build/log; done
	$(CADIUS) ADDFOLDER build/"$(DISK)" "/$(VOLUME)/FX" "build/FX" >>build/log
	for f in res/dsk/*.po; do $(CADIUS) EXTRACTVOLUME "$${f}" build/X/ >> build/log; done
	rm -f build/X/**/.DS_Store build/X/**/PRODOS* build/X/**/LOADER.SYSTEM*
	$(CADIUS) CREATEFOLDER build/"$(DISK)" "/$(VOLUME)/X/" >>build/log
	for f in build/X/*; do $(CADIUS) ADDFOLDER build/"$(DISK)" "/$(VOLUME)/X/$$(basename $$f)" "$$f"; done >>build/log
	bin/buildfileinfo.sh build/PRELAUNCH "06" "0106" >>build/log
	$(CADIUS) ADDFOLDER build/"$(DISK)" "/$(VOLUME)/PRELAUNCH" "build/PRELAUNCH" >>build/log
	bin/changebootloader.sh build/"$(DISK)" res/proboothd

asm: md asmlauncher asmfx asmprelaunch

asmlauncher:
	$(ACME) -DBUILDNUMBER=`git rev-list --count HEAD` src/4cade.a 2>build/relbase.log
	$(ACME) -r build/4cade.lst -DBUILDNUMBER=`git rev-list --count HEAD` -DRELBASE=`cat build/relbase.log | grep "RELBASE =" | cut -d"=" -f2 | cut -d"(" -f2 | cut -d")" -f1` src/4cade.a

asmfx:
	for f in src/fx/*.a; do grep "^\!to" $${f} >/dev/null && $(ACME) $${f} >> build/log || true; done
	bin/buildfileinfo.sh build/FX "06" "6000" >>build/log

asmprelaunch:
	for f in src/prelaunch/*.a; do grep "^\!to" $${f} >/dev/null && $(ACME) $${f} >> build/log; done
	for f in res/TITLE.HGR/* res/TITLE.DHGR/*; do rsync --ignore-existing build/PRELAUNCH/STANDARD build/PRELAUNCH/$$(basename $$f); done

chd:	dsk
	chdman createhd -c none -isb 64 -i build/"$(DISK)" -o build/"$(DISK)".chd >>build/log

compress:
	for f in res/ACTION.HGR.UNCOMPRESSED/*; do  o=res/ACTION.HGR/$$(basename $$f);  [ -f "$$o" ] || ${EXOMIZER} "$$f"@0x4000 -o "$$o" >>build/log; done
	for f in res/ACTION.DHGR.UNCOMPRESSED/*; do o=res/ACTION.DHGR/$$(basename $$f); [ -f "$$o" ] || ${EXOMIZER} "$$f"@0x4000 -o "$$o" >>build/log; done
	for f in res/ARTWORK.SHR.UNCOMPRESSED/*; do o=res/ARTWORK.SHR/$$(basename $$f); [ -f "$$o" ] || ${EXOMIZER} "$$f"@0x2000 -o "$$o" >>build/log; done

attract: compress
	bin/check-attract-mode.sh
	bin/generate-mini-attract-mode.sh

mount: dsk
	osascript bin/V2Make.scpt "`pwd`" bin/4cade.vii build/"$(DISK)"

md:
	mkdir -p build/X
	mkdir -p build/FX
	mkdir -p build/PRELAUNCH

clean:
	rm -rf build/ || rm -rf build

all: clean dsk mount
