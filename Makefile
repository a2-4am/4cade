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
VOLUME=A.4AM.PACK

# third-party tools required to build
# https://sourceforge.net/projects/acme-crossass/
ACME=acme
# https://www.brutaldeluxe.fr/products/crossdevtools/cadius/
# https://github.com/mach-kernel/cadius
CADIUS=cadius

asm: md asmfx asmprelaunch
	$(ACME) src/4cade.a 2>build/relbase.log
	$(ACME) -r build/4cade.lst -DRELBASE=`cat build/relbase.log | grep "RELBASE =" | cut -d"=" -f2 | cut -d"(" -f2 | cut -d")" -f1` src/4cade.a

asmfx:
	@for f in $(shell ls src/fx/*.a); do grep "^\!to" $${f} >/dev/null && $(ACME) $${f} >> build/log; done

asmprelaunch:
	@for f in $(shell ls src/prelaunch/*.a); do grep "^\!to" $${f} >/dev/null && $(ACME) $${f} >> build/log; done

dsk: md asm
	cp res/blank.2mg build/"$(DISK)" >>build/log
	cp res/_FileInformation.txt build/ >>build/log
	$(CADIUS) ADDFILE build/"$(DISK)" "/$(VOLUME)/" "build/LAUNCHER.SYSTEM" >>build/log
	cp res/attract.conf build/ATTRACT.CONF >>build/log
	cp res/dfx.conf build/DFX.CONF >>build/log
	cp res/fx.conf build/FX.CONF >>build/log
	cp res/games.conf build/GAMES.CONF >>build/log
	cp res/prefs.conf build/PREFS.CONF >>build/log
	cp res/credits.txt build/CREDITS >>build/log
	bin/padto 512 build/PREFS.CONF
	$(CADIUS) ADDFILE build/"$(DISK)" "/$(VOLUME)/" "res/TITLE" >>build/log
	$(CADIUS) ADDFILE build/"$(DISK)" "/$(VOLUME)/" "res/COVER" >>build/log
	$(CADIUS) ADDFILE build/"$(DISK)" "/$(VOLUME)/" "build/PREFS.CONF" >>build/log
	$(CADIUS) ADDFILE build/"$(DISK)" "/$(VOLUME)/" "build/GAMES.CONF" >>build/log
	$(CADIUS) ADDFILE build/"$(DISK)" "/$(VOLUME)/" "build/ATTRACT.CONF" >>build/log
	$(CADIUS) ADDFILE build/"$(DISK)" "/$(VOLUME)/" "build/FX.CONF" >>build/log
	$(CADIUS) ADDFILE build/"$(DISK)" "/$(VOLUME)/" "build/DFX.CONF" >>build/log
	$(CADIUS) ADDFILE build/"$(DISK)" "/$(VOLUME)/" "build/CREDITS" >>build/log
	rsync -aP res/title.hgr/* build/TITLE.HGR >>build/log
	bin/buildfileinfo.py build/TITLE.HGR "06" "4000" >>build/log
	$(CADIUS) ADDFOLDER build/"$(DISK)" "/$(VOLUME)/TITLE.HGR" "build/TITLE.HGR" >>build/log
	rsync -aP res/title.dhgr/* build/TITLE.DHGR >>build/log
	bin/buildfileinfo.py build/TITLE.DHGR "06" "4000" >>build/log
	$(CADIUS) ADDFOLDER build/"$(DISK)" "/$(VOLUME)/TITLE.DHGR" "build/TITLE.DHGR" >>build/log
	rsync -aP res/action.hgr/* build/ACTION.HGR >>build/log
	bin/buildfileinfo.py build/ACTION.HGR "06" "4000" >>build/log
	$(CADIUS) ADDFOLDER build/"$(DISK)" "/$(VOLUME)/ACTION.HGR" "build/ACTION.HGR" >>build/log
	rsync -aP res/action.dhgr/* build/ACTION.DHGR >>build/log
	bin/buildfileinfo.py build/ACTION.DHGR "06" "4000" >>build/log
	$(CADIUS) ADDFOLDER build/"$(DISK)" "/$(VOLUME)/ACTION.DHGR" "build/ACTION.DHGR" >>build/log
	rsync -aP res/action.gr/* build/ACTION.GR >>build/log
	bin/buildfileinfo.py build/ACTION.GR "06" "6000" >>build/log
	$(CADIUS) ADDFOLDER build/"$(DISK)" "/$(VOLUME)/ACTION.GR" "build/ACTION.GR" >>build/log
	rsync -aP res/artwork.shr/* build/ARTWORK.SHR >>build/log
	bin/buildfileinfo.py build/ARTWORK.SHR "C1" "2000" >>build/log
	$(CADIUS) ADDFOLDER build/"$(DISK)" "/$(VOLUME)/ARTWORK.SHR" "build/ARTWORK.SHR" >>build/log
	rsync -aP res/attract/* build/ATTRACT >>build/log
	bin/buildfileinfo.py build/ATTRACT "04" "8000" >>build/log
	$(CADIUS) ADDFOLDER build/"$(DISK)" "/$(VOLUME)/ATTRACT" "build/ATTRACT" >>build/log
	rsync -aP res/ss/* build/SS >>build/log
	bin/buildfileinfo.py build/SS "04" "4000" >>build/log
	$(CADIUS) ADDFOLDER build/"$(DISK)" "/$(VOLUME)/SS" "build/SS" >>build/log
	rsync -aP res/demo/* build/DEMO >>build/log
	$(CADIUS) ADDFOLDER build/"$(DISK)" "/$(VOLUME)/DEMO" "build/DEMO" >>build/log
	$(CADIUS) RENAMEFILE build/"$(DISK)" "/$(VOLUME)/DEMO/SPCARTOON.11" "SPCARTOON.1." >>build/log
	$(CADIUS) RENAMEFILE build/"$(DISK)" "/$(VOLUME)/DEMO/SPCARTOON.22" "SPCARTOON.2." >>build/log
	$(CADIUS) RENAMEFILE build/"$(DISK)" "/$(VOLUME)/DEMO/SPCARTOON.33" "SPCARTOON.3." >>build/log
	$(CADIUS) RENAMEFILE build/"$(DISK)" "/$(VOLUME)/DEMO/SPCARTOON.44" "SPCARTOON.4." >>build/log
	$(CADIUS) RENAMEFILE build/"$(DISK)" "/$(VOLUME)/DEMO/SPCARTOON.55" "SPCARTOON.5." >>build/log
	$(CADIUS) RENAMEFILE build/"$(DISK)" "/$(VOLUME)/DEMO/SPCARTOON.66" "SPCARTOON.6." >>build/log
	rsync -aP res/fx/* build/FX >>build/log
	$(CADIUS) ADDFOLDER build/"$(DISK)" "/$(VOLUME)/FX" "build/FX" >>build/log
	$(CADIUS) CREATEFOLDER build/"$(DISK)" "/$(VOLUME)/X/" >>build/log
	bin/do2po.py res/dsk/ build/po/
	rsync -a res/dsk/*.po build/po/
	bin/extract.py build/po/ | sh >>build/log
	rm -f build/X/**/.DS_Store
	rm -f build/X/**/PRODOS
	rm -f build/X/**/LOADER.SYSTEM
	$(CADIUS) ADDFOLDER build/"$(DISK)" "/$(VOLUME)/X" "build/X" >>build/log
	bin/buildfileinfo.py build/PRELAUNCH "06" "0106" >>build/log
	$(CADIUS) ADDFOLDER build/"$(DISK)" "/$(VOLUME)/PRELAUNCH" "build/PRELAUNCH" >>build/log
	bin/changebootloader.py build/"$(DISK)" res/proboothd

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
	mkdir -p build/ATTRACT
	mkdir -p build/SS
	mkdir -p build/DEMO
	mkdir -p build/FX
	mkdir -p build/PRELAUNCH

clean:
	rm -rf build/ || rm -rf build

all: clean asm dsk mount
