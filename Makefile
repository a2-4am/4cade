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

# third-party tools required to build
# https://sourceforge.net/projects/acme-crossass/
ACME=acme
# https://www.brutaldeluxe.fr/products/crossdevtools/cadius/
# https://github.com/mach-kernel/cadius
CADIUS=cadius

asm: md
	$(ACME) -r build/prorwts2.lst src/PRORWTS2.S

dsk: md asm
	cadius CREATEVOLUME build/"$(DISK)" "A.4AM.PACK" 32MB
#	cp res/_FileInformation.txt build/
#	bin/fixFileInformation.sh build/_FileInformation.txt
#	$(CADIUS) ADDFILE build/"$(DISK)" "/A.4AM.PACK/" "res/CREDITS.TXT"
#	$(CADIUS) CREATEFOLDER build/"$(DISK)" "/A.4AM.PACK/LIB/"
#	$(CADIUS) ADDFILE build/"$(DISK)" "/A.4AM.PACK/LIB/" "build/ONBEYONDZ1"

artwork: dsk
	$(CADIUS) ADDFOLDER build/"$(DISK)" "/A.4AM.PACK/ARTWORK" "res/artwork"
#	$(CADIUS) ADDFILE build/"$(DISK)" "/A.4AM.PACK/ARTWORK/" "res/DHRSLIDE.SYSTEM"
#	$(CADIUS) ADDFOLDER build/"$(DISK)" "/A.4AM.PACK/ARTWORKGS" "res/artworkgs"

mount: dsk
	osascript bin/V2Make.scpt "`pwd`" bin/4cade.vii build/"$(DISK)"

md:
	mkdir -p build

clean:
	rm -rf build/

all: clean asm dsk artwork mount
