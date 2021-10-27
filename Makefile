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

dsk: asm index
	cp res/blank.hdv build/"$(DISK)"
	cp res/_FileInformation.txt build/
	$(CADIUS) ADDFILE build/"$(DISK)" "/$(VOLUME)/" build/LAUNCHER.SYSTEM >>build/log
	cp res/PREFS.CONF build/PREFS.CONF
	bin/padto.sh build/PREFS.CONF
#
# create _FileInformation.txt files for subdirectories
#
	bin/buildfileinfo.sh res/TITLE.HGR "06" "4000"
	bin/buildfileinfo.sh res/TITLE.DHGR "06" "4000"
	bin/buildfileinfo.sh res/ACTION.GR "06" "6000"
	bin/buildfileinfo.sh res/ICONS "CA" "0000"
	bin/buildfileinfo.sh build/FX "06" "6000"
	bin/buildfileinfo.sh build/PRELAUNCH "06" "0106"
#
# add everything to the disk
#
	for f in \
		build/TOTAL.DATA \
		res/TITLE \
		res/COVER \
		res/HELP \
		build/GAMES.CONF \
		build/PREFS.CONF \
		build/CREDITS \
		build/HELPTEXT \
		build/ATTRACT.IDX \
		build/SEARCH00.IDX \
		build/SEARCH01.IDX \
		build/SEARCH10.IDX \
		build/SEARCH11.IDX \
		build/FX.IDX \
		build/DFX.IDX \
		build/GAMEHELP.IDX \
		build/SLIDESHOW.IDX \
		build/MINIATTRACT.IDX \
		build/PRELAUNCH.IDX \
		build/ARTWORK.IDX \
		build/HGR0.IDX \
		build/HGR1.IDX \
		build/HGR2.IDX \
		build/HGR3.IDX \
		build/HGR4.IDX \
		build/HGR5.IDX \
		build/HGR6.IDX \
		build/DHGR.IDX \
		res/DECRUNCH \
		res/JOYSTICK \
		res/Finder.Data \
		res/Finder.Root; do \
	    $(CADIUS) ADDFILE build/"$(DISK)" "/$(VOLUME)/" "$$f" >>build/log; \
	done
	for f in \
		res/TITLE.HGR \
		res/TITLE.DHGR \
		res/ACTION.GR \
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

index: md asmfx asmprelaunch
# note: even though individual lines check individual files, you really want
# to re-run this with a clean build/ directory if anything changes, because
# everything is interconnected within TOTAL.DATA
#
# precompute binary data structure for mega-attract mode configuration file
#
	[ -f build/ATTRACT.IDX ] || (bin/buildokvs.sh < res/ATTRACT.CONF > build/ATTRACT.IDX)
#
# precompute binary data structure and substitute special characters
# in game help and other all-text pages
#
	[ -f build/HELPTEXT ] || (bin/converthelp.sh res/HELPTEXT build/HELPTEXT)
	[ -f build/CREDITS ] || (bin/converthelp.sh res/CREDITS build/CREDITS)
	for f in res/GAMEHELP/*; do \
	    [ -f build/GAMEHELP/"$$(basename $$f)" ] || (bin/converthelp.sh "$$f" build/GAMEHELP/"$$(basename $$f)"); \
	done
#
# create distribution version of GAMES.CONF without comments or blank lines
#
	[ -f build/GAMES.CONF ] || (awk '!/^$$|^#/' < res/GAMES.CONF > build/GAMES.CONF)
#
# create gGamesListStore indexes
#
#	grep "^00" < build/GAMES.CONF | bin/buildgamesstore.sh > build/GAMES00.IDX
#	grep "^0" < build/GAMES.CONF | bin/buildgamesstore.sh > build/GAMES01.IDX
#	grep "^.0" < build/GAMES.CONF | bin/buildgamesstore.sh > build/GAMES10.IDX
#	cat build/GAMES.CONF | bin/buildgamesstore.sh > build/GAMES11.IDX
#
# create gSearchStore indexes
#
	[ -f build/DISPLAY.CONF ] || (bin/builddisplaynames.py < build/GAMES.CONF > build/DISPLAY.CONF)
	[ -f build/SEARCH00.IDX ] || (grep "^00" < build/DISPLAY.CONF | cut -d"," -f2 | bin/buildokvs.sh > build/SEARCH00.IDX)
	[ -f build/SEARCH01.IDX ] || (grep "^0" < build/DISPLAY.CONF | cut -d"," -f2 | bin/buildokvs.sh > build/SEARCH01.IDX)
	[ -f build/SEARCH10.IDX ] || (grep "^.0" < build/DISPLAY.CONF | cut -d"," -f2 | bin/buildokvs.sh > build/SEARCH10.IDX)
	[ -f build/SEARCH11.IDX ] || (cat build/DISPLAY.CONF | cut -d"," -f2 | bin/buildokvs.sh > build/SEARCH11.IDX)
#
# create a sorted list of game filenames, without metadata or display names
#
	[ -f build/GAMES.SORTED ] || (awk -F, '/,/ { print $$2 }' < build/GAMES.CONF | awk -F= '{ print $$1 }' | sort > build/GAMES.SORTED)
#
# precompute indexed files for prelaunch
# note: prelaunch must be first in TOTAL.DATA due to a hack in LoadStandardPrelaunch
# note 2: these can not be padded because they are loaded at $0106 and padding would clobber the stack
#
	[ -f build/PRELAUNCH.IDX ] || (bin/buildindexedfile.sh build/TOTAL.DATA build/PRELAUNCH.INDEXED < build/GAMES.SORTED > build/PRELAUNCH.IDX)
#
# precompute indexed files for game help
#
	[ -f build/GAMEHELP.IDX ] || (bin/buildindexedfile.sh -p -a build/TOTAL.DATA build/GAMEHELP < build/GAMES.SORTED > build/GAMEHELP.IDX)
#
# precompute indexed files for slideshows
#
	[ -f build/SLIDESHOW.IDX ] || ((for f in res/SS/*; do \
	    [ $$(echo "$$(basename $$f)" | cut -c-3) = "ACT" ] && \
	        bin/buildaction.sh build/DISPLAY.CONF < "$$f" > "build/SS/$$(basename $$f)" || \
	        bin/buildokvs.sh < "$$f" > "build/SS/$$(basename $$f)"; \
	    echo "$$(basename $$f)"; \
	done) | bin/buildindexedfile.sh -p -a build/TOTAL.DATA build/SS > build/SLIDESHOW.IDX)
	[ -f build/MINIATTRACT.IDX ] || ((for f in res/ATTRACT/*; do \
	    bin/buildokvs.sh < "$$f" > "build/ATTRACT/$$(basename $$f)"; \
	    echo "$$(basename $$f)"; \
	done) | bin/buildindexedfile.sh -p -a build/TOTAL.DATA build/ATTRACT > build/MINIATTRACT.IDX)
#
# precompute indexed files for graphic effects
#
	[ -f build/FX.IDX ] || (bin/buildindexedfile.sh -p -a build/TOTAL.DATA build/FX.INDEXED < res/FX.CONF > build/FX.IDX)
	[ -f build/DFX.IDX ] || (bin/buildindexedfile.sh -p -a build/TOTAL.DATA build/FX.INDEXED < res/DFX.CONF > build/DFX.IDX)
#
# precompute indexed files for HGR & DHGR action screenshots
# note: these can not be padded because they are compressed and the decompressor needs the exact size
#
	[ -f build/HGR0.IDX ] || ((for f in res/ACTION.HGR/[ABCD]*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.sh -a build/TOTAL.DATA res/ACTION.HGR > build/HGR0.IDX)
	[ -f build/HGR1.IDX ] || ((for f in res/ACTION.HGR/[EFGH]*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.sh -a build/TOTAL.DATA res/ACTION.HGR > build/HGR1.IDX)
	[ -f build/HGR2.IDX ] || ((for f in res/ACTION.HGR/[IJKL]*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.sh -a build/TOTAL.DATA res/ACTION.HGR > build/HGR2.IDX)
	[ -f build/HGR3.IDX ] || ((for f in res/ACTION.HGR/[MNOP]*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.sh -a build/TOTAL.DATA res/ACTION.HGR > build/HGR3.IDX)
	[ -f build/HGR4.IDX ] || ((for f in res/ACTION.HGR/[QRST]*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.sh -a build/TOTAL.DATA res/ACTION.HGR > build/HGR4.IDX)
	[ -f build/HGR5.IDX ] || ((for f in res/ACTION.HGR/[UVWX]*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.sh -a build/TOTAL.DATA res/ACTION.HGR > build/HGR5.IDX)
	[ -f build/HGR6.IDX ] || ((for f in res/ACTION.HGR/[YZ]*;   do echo "$$(basename $$f)"; done) | bin/buildindexedfile.sh -a build/TOTAL.DATA res/ACTION.HGR > build/HGR6.IDX)
	[ -f build/DHGR.IDX ] || ((for f in res/ACTION.DHGR/*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.sh -a build/TOTAL.DATA res/ACTION.DHGR > build/DHGR.IDX)
#
# precompute indexed files for SHR artwork
# note: these can not be padded because they are compressed and the decompressor needs the exact size
#
	[ -f build/ARTWORK.IDX ] || ((for f in res/ARTWORK.SHR/*; do \
	    echo "$$(basename $$f)"; \
	done) | bin/buildindexedfile.sh -a build/TOTAL.DATA res/ARTWORK.SHR > build/ARTWORK.IDX)

asm: asmlauncher asmfx asmprelaunch asmproboot

asmlauncher: md
	$(ACME) -DBUILDNUMBER=`git rev-list --count HEAD` src/4cade.a 2>build/relbase.log
	$(ACME) -r build/4cade.lst -DBUILDNUMBER=`git rev-list --count HEAD` -DRELBASE=`cat build/relbase.log | grep "RELBASE =" | cut -d"=" -f2 | cut -d"(" -f2 | cut -d")" -f1` src/4cade.a

asmfx: md
	for f in src/fx/*.a; do \
	    grep "^\!to" $${f} >/dev/null && $(ACME) $${f} || true; \
	done

asmprelaunch: md
	for f in src/prelaunch/*.a; do \
	    grep "^\!to" $${f} >/dev/null && $(ACME) $${f}; \
	done

asmproboot: md
	$(ACME) -r build/proboothd.lst src/proboothd/proboothd.a

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
