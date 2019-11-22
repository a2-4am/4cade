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

dsk: md asm
	cp res/blank.2mg build/"$(DISK)" >>build/log
	cp res/_FileInformation.txt build/ >>build/log
	$(CADIUS) ADDFILE build/"$(DISK)" "/$(VOLUME)/" "build/LAUNCHER.SYSTEM" >>build/log
	for f in res/*.conf; do rsync -aP "$$f" build/$$(basename $$f | tr '[:lower:]' '[:upper:]') >>build/log; done
	rsync -aP res/credits.txt build/CREDITS >>build/log
	bin/padto.sh 512 build/PREFS.CONF >>build/log
	for f in res/TITLE res/COVER res/HELP build/*.CONF build/CREDITS; do $(CADIUS) ADDFILE build/"$(DISK)" "/$(VOLUME)/" "$$f" >>build/log; done
	for f in res/title.hgr res/title.dhgr res/action.hgr res/action.dhgr res/action.gr res/artwork.shr res/attract res/ss res/demo res/title.animated; do rsync -aP "$$f"/* build/$$(basename $$f | tr '[:lower:]' '[:upper:]') >>build/log; done
	bin/buildfileinfo.sh build/TITLE.HGR "06" "4000" >>build/log
	bin/buildfileinfo.sh build/TITLE.DHGR "06" "4000" >>build/log
	bin/buildfileinfo.sh build/ACTION.HGR "06" "4000" >>build/log
	bin/buildfileinfo.sh build/ACTION.DHGR "06" "4000" >>build/log
	bin/buildfileinfo.sh build/ACTION.GR "06" "6000" >>build/log
	bin/buildfileinfo.sh build/ARTWORK.SHR "C1" "2000" >>build/log
	bin/buildfileinfo.sh build/ATTRACT "04" "8000" >>build/log
	bin/buildfileinfo.sh build/SS "04" "4000" >>build/log
	rsync -aP res/fx/* build/FX >>build/log
	bin/buildfileinfo.sh build/FX "06" "6000" >>build/log
	for f in build/TITLE.* build/ACTION.* build/ARTWORK.* build/ATTRACT build/SS build/DEMO build/TITLE.ANIMATED; do $(CADIUS) ADDFOLDER build/"$(DISK)" "/$(VOLUME)/$$(basename $$f)" "$$f" >>build/log; done
	for i in 1 2 3 4 5 6; do $(CADIUS) RENAMEFILE build/"$(DISK)" "/$(VOLUME)/DEMO/SPCARTOON.$${i}$${i}" "SPCARTOON.$${i}." >>build/log; done
	$(CADIUS) ADDFOLDER build/"$(DISK)" "/$(VOLUME)/FX" "build/FX" >>build/log
	$(CADIUS) CREATEFOLDER build/"$(DISK)" "/$(VOLUME)/X/" >>build/log
	for f in res/dsk/*.po; do $(CADIUS) EXTRACTVOLUME "$${f}" build/X/ >> build/log; done
	rm -f build/X/**/.DS_Store build/X/**/PRODOS* build/X/**/LOADER.SYSTEM*
	$(CADIUS) ADDFOLDER build/"$(DISK)" "/$(VOLUME)/X" "build/X" >>build/log
	bin/buildfileinfo.sh build/PRELAUNCH "06" "0106" >>build/log
	$(CADIUS) ADDFOLDER build/"$(DISK)" "/$(VOLUME)/PRELAUNCH" "build/PRELAUNCH" >>build/log
	bin/changebootloader.sh build/"$(DISK)" res/proboothd

asm: md asmlauncher asmfx asmprelaunch

asmlauncher:
	$(ACME) -DBUILDNUMBER=`git rev-list --count HEAD` src/4cade.a 2>build/relbase.log
	$(ACME) -r build/4cade.lst -DBUILDNUMBER=`git rev-list --count HEAD` -DRELBASE=`cat build/relbase.log | grep "RELBASE =" | cut -d"=" -f2 | cut -d"(" -f2 | cut -d")" -f1` src/4cade.a

asmfx:
	for f in src/fx/*.a; do grep "^\!to" $${f} >/dev/null && $(ACME) $${f} >> build/log || true; done

asmprelaunch:
	for f in src/prelaunch/*.a; do grep "^\!to" $${f} >/dev/null && $(ACME) $${f} >> build/log; done
	for f in res/title.hgr/*; do rsync --ignore-existing build/PRELAUNCH/STANDARD build/PRELAUNCH/$$(basename $$f); done

chd:	dsk
	chdman createhd -c none -isb 64 -i build/"$(DISK)" -o build/"$(DISK)".chd >>build/log

mount: dsk
	osascript bin/V2Make.scpt "`pwd`" bin/4cade.vii build/"$(DISK)"

md:
	mkdir -p build/po
	mkdir -p build/X
	mkdir -p build/TITLE.HGR
	mkdir -p build/TITLE.DHGR
	mkdir -p build/ACTION.HGR
	mkdir -p build/ACTION.DHGR
	mkdir -p build/ACTION.GR
	mkdir -p build/ARTWORK.SHR
	mkdir -p build/TITLE.ANIMATED
	mkdir -p build/ATTRACT
	mkdir -p build/SS
	mkdir -p build/DEMO
	mkdir -p build/FX
	mkdir -p build/PRELAUNCH

clean:
	rm -rf build/ || rm -rf build

all: clean asm dsk mount
