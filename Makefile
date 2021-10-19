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
	cp res/PREFS.CONF build/PREFS.CONF >>build/log
	bin/padto.sh 512 build/PREFS.CONF >>build/log
#
# precompute OKVS data structure for mega-attract mode configuration file
#
	bin/buildokvs.sh "res/ATTRACT.CONF" "build/ATTRACT.IDX" >>build/log
#
# precompute FX and DFX indexes and merged data files containing multiple
# graphic effects in a single file (loaded at runtime by LoadIndexedFile())
#
	bin/buildindexedfile.sh -p "res/FX.CONF" "build/FX.IDX" "build/FX.ALL" "build/FX.INDEXED" >>build/log
	bin/buildindexedfile.sh -a -p "res/DFX.CONF" "build/DFX.IDX" "build/FX.ALL" "build/FX.INDEXED" >>build/log
#
# substitute special characters in help text and other pages that will be
# drawn with DrawPage()
#
	bin/converthelp.sh res/HELPTEXT build/HELPTEXT >>build/log
	bin/converthelp.sh res/CREDITS build/CREDITS >>build/log
	for f in res/GAMEHELP/*; do \
            bin/converthelp.sh "$$f" build/GAMEHELP/"$$(basename $$f)" >>build/log; \
	done
#
# precompute indexed files for game help, slideshow configuration,
# mini-attract mode configuration, and prelaunch files
#
	awk -F "," '!/^#/ { print $$2 }' < res/GAMES.CONF | awk -F "=" '{ print $$1 }' | sort > build/GAMES.SORTED
	bin/buildindexedfile.sh -p "build/GAMES.SORTED" "build/GAMEHELP.IDX" "build/GAMEHELP.ALL" "build/GAMEHELP" >>build/log
	(for f in res/SS/*; do \
	    bin/buildokvs.sh "$$f" "build/SS/$$(basename $$f)"; \
	    echo "$$(basename $$f)"; \
	done) > build/SSDIR
	bin/buildindexedfile.sh -p "build/SSDIR" "build/SLIDESHOW.IDX" "build/SLIDESHOW.ALL" "build/SS" >>build/log
	(for f in res/ATTRACT/*; do \
	    bin/buildokvs.sh "$$f" "build/ATTRACT/$$(basename $$f)"; \
	    echo "$$(basename $$f)"; \
	done) > build/ATTRACTDIR
	bin/buildindexedfile.sh -p "build/ATTRACTDIR" "build/MINIATTRACT.IDX" "build/MINIATTRACT.ALL" "build/ATTRACT" >>build/log
	bin/buildindexedfile.sh "build/GAMES.SORTED" "build/PRELAUNCH.IDX" "build/PRELAUNCH.ALL" "build/PRELAUNCH.INDEXED" >>build/log
#
# create _FileInformation.txt files for subdirectories
#
	bin/buildfileinfo.sh res/TITLE.HGR "06" "4000" >>build/log
	bin/buildfileinfo.sh res/TITLE.DHGR "06" "4000" >>build/log
	bin/buildfileinfo.sh res/ACTION.HGR "06" "3FF8" >>build/log
	bin/buildfileinfo.sh res/ACTION.DHGR "06" "3FF8" >>build/log
	bin/buildfileinfo.sh res/ACTION.GR "06" "6000" >>build/log
	bin/buildfileinfo.sh res/ARTWORK.SHR "06" "1FF8" >>build/log
	bin/buildfileinfo.sh res/ICONS "CA" "0000" >>build/log
	bin/buildfileinfo.sh build/FX "06" "6000" >>build/log
	bin/buildfileinfo.sh build/PRELAUNCH "06" "0106" >>build/log
#
# add everything to the disk
#
	for f in \
		res/TITLE \
		res/COVER \
		res/HELP \
		res/GAMES.CONF \
		build/PREFS.CONF \
		build/CREDITS \
		build/HELPTEXT \
		build/ATTRACT.IDX \
		build/FX.IDX \
		build/DFX.IDX \
		build/FX.ALL \
		build/GAMEHELP.IDX \
		build/GAMEHELP.ALL \
		build/SLIDESHOW.IDX \
		build/SLIDESHOW.ALL \
		build/MINIATTRACT.IDX \
		build/MINIATTRACT.ALL \
		build/PRELAUNCH.IDX \
		build/PRELAUNCH.ALL \
		res/DECRUNCH \
		res/JOYSTICK \
		res/Finder.Data \
		res/Finder.Root; do \
	    $(CADIUS) ADDFILE build/"$(DISK)" "/$(VOLUME)/" "$$f" >>build/log; \
	done
	for f in \
		res/TITLE.HGR \
		res/TITLE.DHGR \
		res/ACTION.HGR \
		res/ACTION.DHGR \
		res/ACTION.GR \
		res/ARTWORK.SHR \
                res/DEMO \
                res/TITLE.ANIMATED \
                res/ICONS \
		build/FX \
		build/PRELAUNCH; do \
            rm -f "$$f"/.DS_Store; \
            $(CADIUS) ADDFOLDER build/"$(DISK)" "/$(VOLUME)/$$(basename $$f)" "$$f" >>build/log; \
        done
	for i in 1 2 3 4 5 6; do \
		$(CADIUS) RENAMEFILE build/"$(DISK)" "/$(VOLUME)/DEMO/SPCARTOON.$${i}$${i}" "SPCARTOON.$${i}." >>build/log; \
	done
	for f in res/dsk/*.po; do \
	    $(CADIUS) EXTRACTVOLUME "$${f}" build/X/ >>build/log; \
	done
	rm -f build/X/**/.DS_Store build/X/**/PRODOS* build/X/**/LOADER.SYSTEM*
	$(CADIUS) CREATEFOLDER build/"$(DISK)" "/$(VOLUME)/X/" >>build/log
	for f in build/X/*; do \
	    $(CADIUS) ADDFOLDER build/"$(DISK)" "/$(VOLUME)/X/$$(basename $$f)" "$$f" >>build/log; \
	done
	bin/changebootloader.sh build/"$(DISK)" build/proboothd

asm: asmlauncher asmfx asmprelaunch asmproboot

asmlauncher: md
	$(ACME) -DBUILDNUMBER=`git rev-list --count HEAD` src/4cade.a 2>build/relbase.log
	$(ACME) -r build/4cade.lst -DBUILDNUMBER=`git rev-list --count HEAD` -DRELBASE=`cat build/relbase.log | grep "RELBASE =" | cut -d"=" -f2 | cut -d"(" -f2 | cut -d")" -f1` src/4cade.a

asmfx: md
	for f in src/fx/*.a; do \
	    grep "^\!to" $${f} >/dev/null && $(ACME) $${f} >> build/log || true; \
	done

asmprelaunch: md
	for f in src/prelaunch/*.a; do \
	    grep "^\!to" $${f} >/dev/null && $(ACME) $${f} >> build/log; \
	done

asmproboot: md
	$(ACME) -r build/proboothd.lst src/proboothd/proboothd.a >> build/log

#
# |compress| and |attract| must be called separately because they are slow.
# They create files in the repository which can then be checked in.
#
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
	mkdir -p build/X build/FX.INDEXED build/FX build/PRELAUNCH.INDEXED build/PRELAUNCH build/ATTRACT build/SS build/GAMEHELP
	touch build/log

clean:
	rm -rf build/ || rm -rf build

all: clean dsk mount

al: all
