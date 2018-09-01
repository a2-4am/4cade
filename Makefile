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

dsk: md asm
	$(CADIUS) CREATEVOLUME build/"$(DISK)" "${VOLUME}" 32766KB >/dev/null
	cp res/_FileInformation.txt build/
	$(CADIUS) ADDFILE build/"$(DISK)" "/${VOLUME}/" "res/PRODOS" >/dev/null
	$(CADIUS) ADDFILE build/"$(DISK)" "/${VOLUME}/" "build/LAUNCHER.SYSTEM" >/dev/null
	$(CADIUS) CREATEFOLDER build/"$(DISK)" "/${VOLUME}/X/" >/dev/null
	$(CADIUS) ADDFILE build/"$(DISK)" "/${VOLUME}/" "res/GAMES.CONF" >/dev/null
	$(CADIUS) ADDFILE build/"$(DISK)" "/${VOLUME}/" "res/COVER" >/dev/null
	$(CADIUS) ADDFILE build/"$(DISK)" "/${VOLUME}/" "res/COVER.A2FC" >/dev/null
#	bin/do2po.py res/dsk/ build/po/
#	rsync -a res/dsk/*.po build/po/
#	bin/extract.py build/po/ | sh >/dev/null
#	rm -f build/X/**/.DS_Store
#	rm -f build/X/**/PRODOS
#	rm -f build/X/**/LOADER.SYSTEM
#	$(CADIUS) ADDFOLDER build/"$(DISK)" "/${VOLUME}/X" "build/X" >/dev/null

artwork: dsk
#	$(CADIUS) ADDFOLDER build/"$(DISK)" "/${VOLUME}/ARTWORK" "res/artwork"
#	$(CADIUS) ADDFILE build/"$(DISK)" "/${VOLUME}/ARTWORK/" "res/DHRSLIDE.SYSTEM"
#	$(CADIUS) ADDFOLDER build/"$(DISK)" "/${VOLUME}/ARTWORKGS" "res/artworkgs"

mount: dsk
	osascript bin/V2Make.scpt "`pwd`" bin/4cade.vii build/"$(DISK)"

md:
	mkdir -p build/po
	mkdir -p build/X

clean:
	rm -rf build/

all: clean asm dsk artwork mount
