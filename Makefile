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

# https://www.gnu.org/software/parallel/
PARALLEL=parallel

# https://python.org/
PYTHON=python3

# https://bitbucket.org/magli143/exomizer/wiki/Home
# version 3.1.0 or later
EXOMIZER=exomizer mem -q -P23 -lnone

dsk: index asmproboot asmlauncher extract
	cp res/blank.hdv build/"$(DISK)"
	cp res/_FileInformation.txt build/
	$(CADIUS) ADDFILE build/"$(DISK)" "/$(VOLUME)/" build/LAUNCHER.SYSTEM -C >>build/log
	cp res/PREFS.CONF build/PREFS.CONF
	bin/padto.sh build/PREFS.CONF
#
# create _FileInformation.txt files for subdirectories
#
	bin/buildfileinfo.sh res/ICONS "CA" "0000"
	cp src/prelaunch/_FileInformation.txt build/PRELAUNCH/
#
# add everything to the disk
#
	for f in \
		build/TOTAL.DATA \
		build/PREFS.CONF \
		res/Finder.Data \
		res/Finder.Root; do \
	    $(CADIUS) ADDFILE build/"$(DISK)" "/$(VOLUME)/" "$$f" -C >>build/log; \
	done
	for f in \
		res/TITLE.ANIMATED \
		res/ICONS \
		build/PRELAUNCH \
		build/X; do \
            rm -f "$$f"/.DS_Store; \
            $(CADIUS) ADDFOLDER build/"$(DISK)" "/$(VOLUME)/$$(basename $$f)" "$$f" -C >>build/log; \
        done
	bin/changebootloader.sh build/"$(DISK)" build/proboothd

gamesconf: preconditions md
#
# create a version of GAMES.CONF without comments or blank lines or anything after display titles
#
	[ -f build/index ] || (awk '!/^$$|^#/' < res/GAMES.CONF | awk -F'/' '{ print $$1 }' > build/GAMES.CONF)
#
# create a list of all game filenames, without metadata or display names, sorted by game filename
#
	[ -f build/index ] || (awk -F, '/,/ { print $$2 }' < build/GAMES.CONF | awk -F= '{ print $$1 }' | sort > build/GAMES.SORTED)

extract: preconditions md gamesconf
	$(PARALLEL) '$(CADIUS) EXTRACTVOLUME {} build/X/ >>build/log' ::: res/dsk/*.po
	rm -f build/X/**/.DS_Store build/X/**/PRODOS* build/X/**/LOADER.SYSTEM* build/X/**/_FileInformation.txt
	for f in $$(grep '^....1' build/GAMES.CONF | awk '!/^$$|^#/' | awk -F, '/,/ { print $$2 }' | awk -F= '{ print $$1 }'); do mv build/X/"$$(basename $$f)"/"$$(basename $$f)"* build/X.INDEXED/; rm -rf build/X/"$$(basename $$f)"; done
	for d in build/X/*; do mv "$$d"/* build/X/; rmdir "$$d"; done

index: preconditions md asmfx asmprelaunch asmdemo compress extract
#
# precompute binary data structure for mega-attract mode configuration file
#
	[ -f build/index ] || (bin/buildokvs.sh < res/ATTRACT.CONF > build/ATTRACT.IDX)
#
# precompute binary data structure and substitute special characters
# in game help and other all-text pages
#
	[ -f build/index ] || (bin/converthelp.sh res/HELPTEXT build/HELPTEXT)
	[ -f build/index ] || (bin/converthelp.sh res/CREDITS build/CREDITS)
	[ -f build/index ] || $(PARALLEL) 'bin/converthelp.sh "{}" "build/GAMEHELP/{/}"' ::: res/GAMEHELP/*
#
# precompute indexed files for prelaunch
# note: prelaunch must be first in TOTAL.DATA due to a hack in LoadStandardPrelaunch
# note 2: these can not be padded because they are loaded at $0106 and padding would clobber the stack
#
	[ -f build/index ] || (bin/buildindexedfile.py build/TOTAL.DATA build/PRELAUNCH.INDEXED "" < build/GAMES.SORTED > build/PRELAUNCH.IDX)
#
# precompute indexed files for HGR & DHGR titles
# note: these are not padded because they are all an exact block-multiple anyway
#
	[ -f build/index ] || bin/padto.sh build/TOTAL.DATA
	[ -f build/index ] || ((for f in res/TITLE.HGR/*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a build/TOTAL.DATA res/TITLE.HGR build/HGR.TITLES.LOG > build/TITLE.IDX)
	[ -f build/index ] || ((for f in res/TITLE.DHGR/*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a build/TOTAL.DATA res/TITLE.DHGR build/DHGR.TITLES.LOG > build/DTITLE.IDX)
	[ -f build/index ] || bin/addfile.sh res/COVER build/TOTAL.DATA > src/index/res.cover.idx.a
	[ -f build/index ] || bin/addfile.sh res/TITLE build/TOTAL.DATA > src/index/res.title.idx.a
	[ -f build/index ] || bin/addfile.sh res/HELP build/TOTAL.DATA > src/index/res.help.idx.a
#
# precompute indexed files for game help
# note: these can be padded because they're loaded into $800 at a time when $800..$1FFF is clobber-able
#
	[ -f build/index ] || (bin/buildindexedfile.py -p -a build/TOTAL.DATA build/GAMEHELP "" < build/GAMES.SORTED > build/GAMEHELP.IDX)
#
# precompute indexed files for slideshows
# note: these can be padded because they're loaded into $800 at a time when $800..$1FFF is clobber-able
#
	[ -f build/index ] || $(PARALLEL) '[ $$(echo "{/}" | cut -c-3) = "ACT" ] && bin/buildslideshow.sh -d build/GAMES.CONF < "{}" > "build/SS/{/}" || bin/buildslideshow.sh build/GAMES.CONF < "{}" > "build/SS/{/}"' ::: res/SS/*
	[ -f build/index ] || ((for f in build/SS/*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -p -a build/TOTAL.DATA build/SS "" > build/SLIDESHOW.IDX)
	[ -f build/index ] || $(PARALLEL) 'bin/buildokvs.sh < "{}" > "build/ATTRACT/{/}"' ::: res/ATTRACT/*
	[ -f build/index ] || ((for f in build/ATTRACT/[ABCDEFGHIJKLMNOP]*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -p -a build/TOTAL.DATA build/ATTRACT "" > build/MINIATTRACT0.IDX)
	[ -f build/index ] || ((for f in build/ATTRACT/[QRSTUVWXYZ]*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -p -a build/TOTAL.DATA build/ATTRACT "" > build/MINIATTRACT1.IDX)
#
# precompute indexed files for graphic effects
# note: these can be padded because they're loaded into $6000 at a time when $6000..$BEFF is clobber-able
#
	[ -f build/index ] || (bin/buildindexedfile.py -p -a build/TOTAL.DATA build/FX.INDEXED "" < res/FX.CONF > build/FX.IDX)
	[ -f build/index ] || (bin/buildindexedfile.py -p -a build/TOTAL.DATA build/FX.INDEXED "" < res/DFX.CONF > build/DFX.IDX)
	[ -f build/index ] || (bin/buildindexedfile.py -p -a build/TOTAL.DATA build/FX.INDEXED "" < res/SFX.CONF > build/SFX.IDX)
	[ -f build/index ] || ((for f in build/FXCODE/*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -p -a build/TOTAL.DATA build/FXCODE "" > build/FXCODE.IDX)
#
# precompute indexed files for coordinates files loaded by graphic effects
# note: these can not be padded because some of them are loaded into tight spaces near the unclobberable top of main memory
#
	[ -f build/index ] || ((for f in build/FXDATA/*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a build/TOTAL.DATA build/FXDATA "" > build/FXDATA.IDX)
#
# precompute indexed files for HGR & DHGR action screenshots
# note: these can not be padded because they are compressed and the decompressor needs the exact size
#
	[ -f build/index ] || ((for f in res/ACTION.HGR/[ABCD]*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a build/TOTAL.DATA res/ACTION.HGR "" > build/HGR0.IDX)
	[ -f build/index ] || ((for f in res/ACTION.HGR/[EFGH]*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a build/TOTAL.DATA res/ACTION.HGR "" > build/HGR1.IDX)
	[ -f build/index ] || ((for f in res/ACTION.HGR/[IJKL]*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a build/TOTAL.DATA res/ACTION.HGR "" > build/HGR2.IDX)
	[ -f build/index ] || ((for f in res/ACTION.HGR/[MNOP]*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a build/TOTAL.DATA res/ACTION.HGR "" > build/HGR3.IDX)
	[ -f build/index ] || ((for f in res/ACTION.HGR/[QRST]*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a build/TOTAL.DATA res/ACTION.HGR "" > build/HGR4.IDX)
	[ -f build/index ] || ((for f in res/ACTION.HGR/[UVWX]*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a build/TOTAL.DATA res/ACTION.HGR "" > build/HGR5.IDX)
	[ -f build/index ] || ((for f in res/ACTION.HGR/[YZ]*;   do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a build/TOTAL.DATA res/ACTION.HGR "" > build/HGR6.IDX)
	[ -f build/index ] || ((for f in res/ACTION.DHGR/*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a build/TOTAL.DATA res/ACTION.DHGR "" > build/DHGR.IDX)
#
# precompute indexed files for GR and DGR action screenshots
# note: these can be padded because they are not compressed
#
	[ -f build/index ] || ((for f in res/ACTION.GR/*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a -p build/TOTAL.DATA res/ACTION.GR "" > build/GR.IDX)
	[ -f build/index ] || ((for f in res/ACTION.DGR/*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a -p build/TOTAL.DATA res/ACTION.DGR "" > build/DGR.IDX)
#
# precompute indexed files for SHR artwork
# note: these can not be padded because they are compressed and the decompressor needs the exact size
#
	[ -f build/index ] || ((for f in res/ARTWORK.SHR/*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a build/TOTAL.DATA res/ARTWORK.SHR "" > build/ARTWORK.IDX)
#
# precompute indexed files for demo launchers
# note: these can not be padded because some of them are loaded too close to $C000
#
	[ -f build/index ] || ((for f in build/DEMO/*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a build/TOTAL.DATA build/DEMO "" > build/DEMO.IDX)
	[ -f build/index ] || bin/addfile.sh build/DEMO.IDX build/TOTAL.DATA > src/index/demo.idx.a

#
# precompute indexed files for single-load game binaries
# note: these can be padded because they are loaded at a time when all of main memory is clobber-able
#
	[ -f build/index ] || ((for f in build/X.INDEXED/*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a -p build/TOTAL.DATA build/X.INDEXED "" > build/XSINGLE.IDX)
	[ -f build/index ] || bin/addfile.sh build/XSINGLE.IDX build/TOTAL.DATA > src/index/xsingle.idx.a
#
# create search indexes for each variation of (game-requires-joystick) X (game-requires-128K)
# in the form of OKVS data structures, plus game counts in the form of source files
#
	[ -f build/index ] || $(PARALLEL) ::: \
	    '(grep "^00" < build/GAMES.CONF | bin/buildsearch.sh src/index/count00.a build/HGR.TITLES.LOG /dev/null > build/SEARCH00.IDX)' \
	    '(grep "^0" < build/GAMES.CONF | bin/buildsearch.sh src/index/count01.a build/HGR.TITLES.LOG build/DHGR.TITLES.LOG > build/SEARCH01.IDX)' \
	    '(grep "^.0" < build/GAMES.CONF | bin/buildsearch.sh src/index/count10.a build/HGR.TITLES.LOG /dev/null > build/SEARCH10.IDX)' \
	    '(bin/buildsearch.sh src/index/count11.a build/HGR.TITLES.LOG build/DHGR.TITLES.LOG < build/GAMES.CONF > build/SEARCH11.IDX)'
#
# add IDX files to the combined index file and generate
# the index records that callers use to reference them
#
	[ -f build/index ] || bin/addfile.sh build/SEARCH00.IDX build/TOTAL.DATA > src/index/search00.idx.a
	[ -f build/index ] || bin/addfile.sh res/CACHE00.IDX build/TOTAL.DATA > src/index/cache00.idx.a
	[ -f build/index ] || bin/addfile.sh build/SEARCH01.IDX build/TOTAL.DATA > src/index/search01.idx.a
	[ -f build/index ] || bin/addfile.sh res/CACHE01.IDX build/TOTAL.DATA > src/index/cache01.idx.a
	[ -f build/index ] || bin/addfile.sh build/SEARCH10.IDX build/TOTAL.DATA > src/index/search10.idx.a
	[ -f build/index ] || bin/addfile.sh res/CACHE10.IDX build/TOTAL.DATA > src/index/cache10.idx.a
	[ -f build/index ] || bin/addfile.sh build/SEARCH11.IDX build/TOTAL.DATA > src/index/search11.idx.a
	[ -f build/index ] || bin/addfile.sh res/CACHE11.IDX build/TOTAL.DATA > src/index/cache11.idx.a
	[ -f build/index ] || bin/addfile.sh build/PRELAUNCH.IDX build/TOTAL.DATA > src/index/prelaunch.idx.a
	[ -f build/index ] || bin/addfile.sh build/ATTRACT.IDX build/TOTAL.DATA > src/index/attract.idx.a
	[ -f build/index ] || bin/addfile.sh build/FX.IDX build/TOTAL.DATA > src/index/fx.idx.a
	[ -f build/index ] || bin/addfile.sh build/DFX.IDX build/TOTAL.DATA > src/index/dfx.idx.a
	[ -f build/index ] || bin/addfile.sh build/SFX.IDX build/TOTAL.DATA > src/index/sfx.idx.a
	[ -f build/index ] || bin/addfile.sh build/FXCODE.IDX build/TOTAL.DATA > src/index/fxcode.idx.a
	[ -f build/index ] || bin/addfile.sh build/FXDATA.IDX build/TOTAL.DATA > src/index/fxdata.idx.a
	[ -f build/index ] || bin/addfile.sh build/GAMEHELP.IDX build/TOTAL.DATA > src/index/gamehelp.idx.a
	[ -f build/index ] || bin/addfile.sh build/SLIDESHOW.IDX build/TOTAL.DATA > src/index/slideshow.idx.a
	[ -f build/index ] || bin/addfile.sh build/MINIATTRACT0.IDX build/TOTAL.DATA > src/index/miniattract0.idx.a
	[ -f build/index ] || bin/addfile.sh build/MINIATTRACT1.IDX build/TOTAL.DATA > src/index/miniattract1.idx.a
	[ -f build/index ] || bin/addfile.sh build/TITLE.IDX build/TOTAL.DATA > src/index/title.idx.a
	[ -f build/index ] || bin/addfile.sh build/DTITLE.IDX build/TOTAL.DATA > src/index/dtitle.idx.a
	[ -f build/index ] || bin/addfile.sh build/HGR0.IDX build/TOTAL.DATA > src/index/hgr0.idx.a
	[ -f build/index ] || bin/addfile.sh build/HGR1.IDX build/TOTAL.DATA > src/index/hgr1.idx.a
	[ -f build/index ] || bin/addfile.sh build/HGR2.IDX build/TOTAL.DATA > src/index/hgr2.idx.a
	[ -f build/index ] || bin/addfile.sh build/HGR3.IDX build/TOTAL.DATA > src/index/hgr3.idx.a
	[ -f build/index ] || bin/addfile.sh build/HGR4.IDX build/TOTAL.DATA > src/index/hgr4.idx.a
	[ -f build/index ] || bin/addfile.sh build/HGR5.IDX build/TOTAL.DATA > src/index/hgr5.idx.a
	[ -f build/index ] || bin/addfile.sh build/HGR6.IDX build/TOTAL.DATA > src/index/hgr6.idx.a
	[ -f build/index ] || bin/addfile.sh build/DHGR.IDX build/TOTAL.DATA > src/index/dhgr.idx.a
	[ -f build/index ] || bin/addfile.sh build/GR.IDX build/TOTAL.DATA > src/index/gr.idx.a
	[ -f build/index ] || bin/addfile.sh build/DGR.IDX build/TOTAL.DATA > src/index/dgr.idx.a
	[ -f build/index ] || bin/addfile.sh build/ARTWORK.IDX build/TOTAL.DATA > src/index/artwork.idx.a
#
# add additional miscellaneous files
#
	[ -f build/index ] || bin/addfile.sh build/COVERFADE build/TOTAL.DATA > src/index/coverfade.idx.a
	[ -f build/index ] || bin/addfile.sh build/GR.FIZZLE build/TOTAL.DATA > src/index/gr.fizzle.idx.a
	[ -f build/index ] || bin/addfile.sh build/DGR.FIZZLE build/TOTAL.DATA > src/index/dgr.fizzle.idx.a
	[ -f build/index ] || bin/addfile.sh build/HELPTEXT build/TOTAL.DATA > src/index/helptext.idx.a
	[ -f build/index ] || bin/addfile.sh build/CREDITS build/TOTAL.DATA > src/index/credits.idx.a
	[ -f build/index ] || bin/addfile.sh res/DECRUNCH build/TOTAL.DATA > src/index/decrunch.idx.a
	[ -f build/index ] || bin/addfile.sh res/JOYSTICK build/TOTAL.DATA > src/index/joystick.idx.a
	touch build/index

asmlauncher: preconditions md
	$(ACME) -DBUILDNUMBER=`git rev-list --count HEAD` src/4cade.a 2>build/relbase.log
	$(ACME) -r build/4cade.lst -DBUILDNUMBER=`git rev-list --count HEAD` -DRELBASE=`cat build/relbase.log | grep "RELBASE =" | cut -d"=" -f2 | cut -d"(" -f2 | cut -d")" -f1` src/4cade.a

asmdemo: preconditions md
	$(PARALLEL) 'if grep -q "^!to" "{}"; then $(ACME) "{}"; fi' ::: src/demo/*.a

asmfx: preconditions md
	$(PARALLEL) 'if grep -q "^!to" "{}"; then $(ACME) "{}"; fi' ::: src/fx/*.a

asmprelaunch: preconditions md
	$(PARALLEL) 'if grep -q "^!to" "{}"; then $(ACME) "{}"; fi' ::: src/prelaunch/*.a

asmproboot: md
	$(ACME) -r build/proboothd.lst src/proboothd/proboothd.a

compress: preconditions md
	$(PARALLEL) '[ -f "res/ACTION.HGR/{/}" ] || ${EXOMIZER} "{}"@0x4000 -o "res/ACTION.HGR/{/}"' ::: res/ACTION.HGR.UNCOMPRESSED/*
	$(PARALLEL) '[ -f "res/ACTION.DHGR/{/}" ] || ${EXOMIZER} "{}"@0x4000 -o "res/ACTION.DHGR/{/}"' ::: res/ACTION.DHGR.UNCOMPRESSED/*
	$(PARALLEL) '[ -f "res/ARTWORK.SHR/{/}" ] || ${EXOMIZER} "{}"@0x2000 -o "res/ARTWORK.SHR/{/}"' ::: res/ARTWORK.SHR.UNCOMPRESSED/*
	$(PARALLEL) '[ -f "res/TITLE.HGR/{/}" ] || bin/packhgrfile.py "{}" "res/TITLE.HGR/{/}"' ::: res/TITLE.HGR.UNPACKED/*

#
# |attract| must be called separately because it is slow and
# only needs to be run when a new game or demo is added.
# It create files in the repository which can then be checked in.
#
attract: compress
	bin/check-attract-mode.sh
	bin/generate-mini-attract-mode.sh

cache: preconditions md gamesconf
	$(PARALLEL) ::: \
	    'awk -F= '"'"'/^00/ { print $$2 }'"'"' < build/GAMES.CONF | bin/buildcache.py > build/cache00.a' \
	    'awk -F= '"'"'/^0/ { print $$2 }'"'"' < build/GAMES.CONF | bin/buildcache.py > build/cache01.a' \
	    'awk -F= '"'"'/^.0/ { print $$2 }'"'"' < build/GAMES.CONF | bin/buildcache.py > build/cache10.a' \
	    'awk -F= '"'"'!/^$$|^#/ { print $$2 }'"'"' < build/GAMES.CONF | bin/buildcache.py > build/cache11.a'
	$(PARALLEL) ::: \
	    '$(ACME) -o res/CACHE00.IDX build/cache00.a' \
	    '$(ACME) -o res/CACHE01.IDX build/cache01.a' \
	    '$(ACME) -o res/CACHE10.IDX build/cache10.a' \
	    '$(ACME) -o res/CACHE11.IDX build/cache11.a'

mount: dsk
	osascript bin/V2Make.scpt "`pwd`" bin/4cade.vii build/"$(DISK)"

md:
	mkdir -p build/X build/X.INDEXED build/FX.INDEXED build/FXDATA build/FXCODE build/PRELAUNCH build/PRELAUNCH.INDEXED build/ATTRACT build/SS build/GAMEHELP build/DEMO
	touch build/log

clean:
	rm -rf build/ || rm -rf build

preconditions:
	@$(ACME) --version | grep -q "ACME, release" || (echo "ACME is not installed" && exit 1)
	@$(CADIUS) | grep -q "cadius v" || (echo "Cadius is not installed" && exit 1)
	@$(PARALLEL) --version | grep -q "GNU" || (echo "GNU Parallel is not installed" && exit 1)
	@$(PYTHON) --version | grep -q "Python 3" || (echo "Python 3 is not installed" && exit 1)

all: clean dsk mount

al: all
