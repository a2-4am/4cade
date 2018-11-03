#
# 4cade Makefile
# assembles source code, optionally builds a disk image and mounts it
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

asm: md
	$(ACME) -r build/4cade.lst src/4cade.a
	$(ACME) src/fx/fx.hgr.diagonal.a
	$(ACME) src/fx/fx.hgr.interlock.ud.a
	$(ACME) src/fx/fx.hgr.interlock.lr.a
	$(ACME) src/fx/fx.hgr.spiral.a
	$(ACME) src/fx/fx.hgr.fizzle.a
	$(ACME) src/fx/fx.hgr.bar.dissolve.a
	$(ACME) src/fx/fx.hgr.block.fizzle.a
	$(ACME) src/fx/fx.hgr.block.fizzle.white.a
	$(ACME) src/fx/fx.hgr.2pass.lr.a
	$(ACME) src/fx/fx.hgr.crystal.a
	$(ACME) src/fx/fx.hgr.foursquare.white.a
	$(ACME) src/fx/fx.hgr.onesquare.white.a
	$(ACME) src/fx/fx.hgr.diamond.a
	$(ACME) src/fx/fx.hgr.checkerboard.white.a
	$(ACME) src/fx/fx.hgr.halfblock.fizzle.a
	$(ACME) src/fx/fx.hgr.halfblock.fizzle.white.a
	$(ACME) src/fx/fx.hgr.stagger.ud.a
	$(ACME) src/fx/fx.hgr.stagger.ud.white.a
	$(ACME) src/fx/fx.hgr.stagger.lr.a
	$(ACME) src/fx/fx.hgr.stagger.lr.white.a
	$(ACME) src/fx/fx.hgr.corner.circle.a
	$(ACME) src/fx/fx.hgr.sunrise.a
	$(ACME) src/fx/fx.hgr.radial.a
	$(ACME) src/fx/fx.hgr.split.ud.intro.a
	$(ACME) src/fx/fx.hgr.iris.a

dsk: md asm
	$(CADIUS) CREATEVOLUME build/"$(DISK)" "${VOLUME}" 32766KB >>build/log
	cp res/_FileInformation.txt build/ >>build/log
	$(CADIUS) ADDFILE build/"$(DISK)" "/${VOLUME}/" "build/LAUNCHER.SYSTEM" >>build/log
	$(CADIUS) CREATEFOLDER build/"$(DISK)" "/${VOLUME}/X/" >>build/log
	$(CADIUS) ADDFILE build/"$(DISK)" "/${VOLUME}/" "res/GAMES.CONF" >>build/log
	$(CADIUS) ADDFILE build/"$(DISK)" "/${VOLUME}/" "res/ATTRACT.CONF" >>build/log
	$(CADIUS) ADDFILE build/"$(DISK)" "/${VOLUME}/" "res/FX.CONF" >>build/log
	rsync -aP res/hgr/* build/HGR >>build/log
	bin/buildfileinfo.py build/HGR >>build/log
	$(CADIUS) ADDFOLDER build/"$(DISK)" "/${VOLUME}/HGR" "build/HGR" >>build/log
	rsync -aP res/dhgr/* build/DHGR >>build/log
	bin/buildfileinfo.py build/DHGR >>build/log
	$(CADIUS) ADDFOLDER build/"$(DISK)" "/${VOLUME}/DHGR" "build/DHGR" >>build/log
	rsync -aP res/ss/* build/SS >>build/log
	$(CADIUS) ADDFOLDER build/"$(DISK)" "/${VOLUME}/SS" "build/SS" >>build/log
	rsync -aP res/demo/* build/DEMO >>build/log
	$(CADIUS) ADDFOLDER build/"$(DISK)" "/${VOLUME}/DEMO" "build/DEMO" >>build/log
	rsync -aP res/fx/* build/FX >>build/log
	$(CADIUS) ADDFOLDER build/"$(DISK)" "/${VOLUME}/FX" "build/FX" >>build/log
#	bin/do2po.py res/dsk/ build/po/
#	rsync -a res/dsk/*.po build/po/
#	bin/extract.py build/po/ | sh >build/log
	rm -f build/X/**/.DS_Store
	rm -f build/X/**/PRODOS
	rm -f build/X/**/LOADER.SYSTEM
	$(CADIUS) ADDFOLDER build/"$(DISK)" "/${VOLUME}/X" "build/X" >build/log
	bin/changebootloader.py build/"$(DISK)" res/proboothd

mount: dsk
	osascript bin/V2Make.scpt "`pwd`" bin/4cade.vii build/"$(DISK)"

md:
	mkdir -p build/po
	mkdir -p build/X
	mkdir -p build/HGR
	mkdir -p build/DHGR
	mkdir -p build/SS
	mkdir -p build/DEMO
	mkdir -p build/FX

clean:
	rm -rf build/

all: clean asm dsk mount
