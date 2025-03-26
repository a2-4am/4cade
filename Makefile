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
SHELL=/bin/bash

# third-party tools required to build

# https://sourceforge.net/projects/acme-crossass/
# version 0.97 or later
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

BUILDDIR=build
MD=$(BUILDDIR)/make.touch
CADIUS.LOG=$(BUILDDIR)/log
DEMO.SOURCES=$(wildcard src/demo/*.a)
FX.SOURCES=$(wildcard src/fx/*.a)
PRELAUNCH.SOURCES=$(wildcard src/prelaunch/*.a)
PROBOOT.SOURCES=$(wildcard src/proboot/*.a)
LAUNCHER.SOURCES=$(wildcard src/*.a src/index/*.a)
HDV=$(BUILDDIR)/$(DISK)
PROBOOTHD=$(BUILDDIR)/proboothd
DEMO=$(BUILDDIR)/DEMO
DEMO.LIST=$(BUILDDIR)/demo.list
FX=$(BUILDDIR)/FX
FXCODE.LIST=$(BUILDDIR)/fxcode.list
FXDATA.LIST=$(BUILDDIR)/fxdata.list
PRELAUNCH=$(BUILDDIR)/PRELAUNCH
LAUNCHER.SYSTEM=$(BUILDDIR)/LAUNCHER.SYSTEM
ATTRACT=$(BUILDDIR)/ATTRACT
MINI.ATTRACT0.LIST=$(BUILDDIR)/mini.attract0.list
MINI.ATTRACT1.LIST=$(BUILDDIR)/mini.attract1.list
ATTRACT.IDX=$(BUILDDIR)/ATTRACT.IDX
HELPTEXT=$(BUILDDIR)/HELPTEXT
CREDITS=$(BUILDDIR)/CREDITS
GAMEHELP=$(BUILDDIR)/GAMEHELP
GAMEHELP.COMPRESSED=$(BUILDDIR)/GAMEHELP.COMPRESSED
GAMES.CONF=$(BUILDDIR)/GAMES.CONF
GAMES.SORTED=$(BUILDDIR)/GAMES.SORTED
PREFS.CONF=$(BUILDDIR)/PREFS.CONF
SS=$(BUILDDIR)/SS
SS.LIST=$(BUILDDIR)/ss.list
ACTION.DGR.LIST=$(BUILDDIR)/action.dgr.list
ACTION.DHGR.LIST=$(BUILDDIR)/action.dhgr.list
ACTION.GR.LIST=$(BUILDDIR)/action.gr.list
ACTION.HGR0.LIST=$(BUILDDIR)/action.hgr0.list
ACTION.HGR1.LIST=$(BUILDDIR)/action.hgr1.list
ACTION.HGR2.LIST=$(BUILDDIR)/action.hgr2.list
ACTION.HGR3.LIST=$(BUILDDIR)/action.hgr3.list
ACTION.HGR4.LIST=$(BUILDDIR)/action.hgr4.list
ACTION.HGR5.LIST=$(BUILDDIR)/action.hgr5.list
ACTION.HGR6.LIST=$(BUILDDIR)/action.hgr6.list
ARTWORK.SHR.LIST=$(BUILDDIR)/artwork.shr.list
TITLE.HGR.LIST=$(BUILDDIR)/title.hgr.list
TITLE.DHGR.LIST=$(BUILDDIR)/title.dhgr.list
TOTAL.DATA=$(BUILDDIR)/TOTAL.DATA
X=$(BUILDDIR)/X
XSINGLE.LIST=$(BUILDDIR)/xsingle.list
ACTION.DGR.SOURCES=$(wildcard res/ACTION.DGR/*)
ACTION.DHGR.SOURCES=$(wildcard res/ACTION.DHGR/*)
ACTION.GR.SOURCES=$(wildcard res/ACTION.GR/*)
ACTION.HGR.SOURCES=$(wildcard res/ACTION.HGR/*)
ARTWORK.SHR.SOURCES=$(wildcard res/ARTWORK.SHR/*)
ATTRACT.SOURCES=$(wildcard res/ATTRACT/*)
GAMEHELP.SOURCES=$(wildcard res/GAMEHELP/*)
SS.SOURCES=$(wildcard res/SS/*)
TITLE.ANIMATED.SOURCES=$(wildcard res/TITLE.ANIMATED/*)
TITLE.DHGR.SOURCES=$(wildcard res/TITLE.DHGR/*)
TITLE.HGR.SOURCES=$(wildcard res/TITLE.HGR/*)
CACHE.SOURCES=$(wildcard res/CACHE*.IDX)
ICONS.SOURCE.DIR=res/ICONS
ICONS=$(wildcard $(ICONS.SOURCE.DIR)/*)
ATTRACT.CONF.SOURCE=res/ATTRACT.CONF
DFX.CONF=res/DFX.CONF
FX.CONF=res/FX.CONF
SFX.CONF=res/SFX.CONF
PREFS.CONF.SOURCE=res/PREFS.CONF
GAMES.CONF.SOURCE=res/GAMES.CONF
CREDITS.SOURCE=res/CREDITS
HELPTEXT.SOURCE=res/HELPTEXT
COVER=res/COVER
FINDER.DATA=res/Finder.Data
FINDER.ROOT=res/Finder.Root
HELP=res/HELP
JOYSTICK=res/JOYSTICK
TITLE=res/TITLE

.PHONY: compress attract cache clean mount all al

# build final disk image
$(HDV): $(PROBOOTHD) $(LAUNCHER.SYSTEM) $(PRELAUNCH) $(X) $(TOTAL.DATA) $(TITLE.ANIMATED.SOURCES) $(ICONS) $(FINDER.DATA) $(FINDER.ROOT) $(PREFS.CONF)
	cp res/blank.hdv "$@"
	cp res/_FileInformation.txt "$(BUILDDIR)"/
	$(CADIUS) ADDFILE "$@" "/$(VOLUME)/" "$(LAUNCHER.SYSTEM)" -C >> "$(CADIUS.LOG)"
	for f in "$(TOTAL.DATA)" "$(PREFS.CONF)" "$(FINDER.DATA)" "$(FINDER.ROOT)"; do \
	    $(CADIUS) ADDFILE "$@" "/$(VOLUME)/" "$$f" -C >> "$(CADIUS.LOG)"; \
	done
	cp src/prelaunch/_FileInformation.txt "$(PRELAUNCH)"/
	for f in res/TITLE.ANIMATED "$(ICONS.SOURCE.DIR)" "$(PRELAUNCH)" "$(X)"; do \
            rm -f "$$f"/.DS_Store; \
            $(CADIUS) ADDFOLDER "$@" "/$(VOLUME)/$$(basename $$f)" "$$f" -C >> "$(CADIUS.LOG)"; \
        done
	[[ $$(grep -c "Error(s) : [^0]" "$(CADIUS.LOG)") == 0 ]] || exit 1
	bin/changebootloader.sh "$@" $(PROBOOTHD)
	@touch "$@"

# build padded prefs file (padding is required for writing by ProRWTS)
$(PREFS.CONF): $(PREFS.CONF.SOURCE) | $(MD)
	cp "$(PREFS.CONF.SOURCE)" "$@"
	bin/padto.sh "$@"

# create a version of GAMES.CONF without comments or blank lines or anything after display titles
$(GAMES.CONF): $(MD) $(GAMES.CONF.SOURCE)
	awk '!/^$$|^#/' < "$(GAMES.CONF.SOURCE)" | awk -F'/' '{ print $$1 }' > "$@"

# create a list of all game filenames, without metadata or display names, sorted by game filename
$(GAMES.SORTED): | $(MD) $(GAMES.CONF)
	awk -F, '/,/ { print $$2 }' < "$(GAMES.CONF)" | awk -F= '{ print $$1 }' | sort > "$@"

# extract files from original disk images and move them to their final directories
$(X): | $(MD) $(GAMES.CONF)
	mkdir -p "$@" "$(BUILDDIR)"/X.INDEXED
	$(PARALLEL) '$(CADIUS) EXTRACTVOLUME {} "$@"/ >> "$(CADIUS.LOG)"' ::: res/dsk/*.po
	rm -f "$@"/**/.DS_Store "$@"/**/PRODOS* "$@"/**/LOADER.SYSTEM* "$@"/**/_FileInformation.txt
	for f in $$(grep '^....1' "$(GAMES.CONF)" | awk '!/^$$|^#/' | awk -F, '/,/ { print $$2 }' | awk -F= '{ print $$1 }'); do mv "$@"/"$$f"/"$$f"* "$(BUILDDIR)"/X.INDEXED/; rm -rf "$@"/"$$f"; done
	(cd "$(BUILDDIR)"/X.INDEXED/ && for f in *; do echo "$$f"; done) > "$(XSINGLE.LIST)"
	for d in "$@"/*; do mv "$$d"/* "$@"/; rmdir "$$d"; done
	@touch "$@"

# precompute binary data structure for mega-attract mode configuration file
$(ATTRACT.IDX): $(ATTRACT.CONF.SOURCE) | $(MD)
	bin/buildokvs.py < "$(ATTRACT.CONF.SOURCE)" > "$@"

# precompute binary data structure and substitute special characters in global help
$(HELPTEXT): $(HELPTEXT.SOURCE) | $(MD)
	bin/converthelp.sh "$(HELPTEXT.SOURCE)" "$@"

# precompute binary data structure and substitute special characters in credits
$(CREDITS): $(CREDITS.SOURCE) | $(MD)
	bin/converthelp.sh "$(CREDITS.SOURCE)" "$@"

# precompute binary data structures and substitute special characters for each game's help
$(GAMEHELP): $(GAMEHELP.SOURCES) | $(MD)
	mkdir -p "$@"
	$(PARALLEL) 'bin/converthelp.sh "{}" "$@/{/}"' ::: res/GAMEHELP/*
	@touch "$@"

$(GAMEHELP.COMPRESSED): $(GAMEHELP) | $(MD)
	mkdir -p "$@"
	$(PARALLEL) '[ -f "$@/{/}" ] || ${EXOMIZER} "{}"@0x0900 -o "$@/{/}"' ::: "$(GAMEHELP)"/*
	@touch "$@"

# precompute binary data structures for slideshow configuration files
$(SS): $(SS.SOURCES) | $(MD) $(GAMES.CONF)
	mkdir -p "$@"
	$(PARALLEL) 'bin/buildslideshow.py "{}" "$(GAMES.CONF)" < "{}" > "$@/{/}"' ::: res/SS/*
	(cd "$(SS)"/ && for f in *; do echo "$$f"; done) > "$(SS.LIST)"
	@touch "$@"

# precompute binary data structures for each game's mini-attract configuration file
$(ATTRACT): $(ATTRACT.SOURCES) | $(MD)
	mkdir -p "$@"
	$(PARALLEL) 'bin/buildokvs.py < "{}" > "$@/{/}"' ::: res/ATTRACT/*
	(cd "$(ATTRACT)"/ && for f in [ABCDEFGHIJKLMNOP]*; do echo "$$f"; done) > "$(MINI.ATTRACT0.LIST)"
	(cd "$(ATTRACT)"/ && for f in [QRSTUVWXYZ]*; do echo "$$f"; done) > "$(MINI.ATTRACT1.LIST)"
	@touch "$@"

# create lists of specific files used to build data structures later
$(ACTION.HGR0.LIST): $(ACTION.HGR.SOURCES) | $(MD)
	(cd res/ACTION.HGR/ && for f in [ABCD]*; do echo "$$f"; done) > "$@"

$(ACTION.HGR1.LIST): $(ACTION.HGR.SOURCES) | $(MD)
	(cd res/ACTION.HGR/ && for f in [EFGH]*; do echo "$$f"; done) > "$@"

$(ACTION.HGR2.LIST): $(ACTION.HGR.SOURCES) | $(MD)
	(cd res/ACTION.HGR/ && for f in [IJKL]*; do echo "$$f"; done) > "$@"

$(ACTION.HGR3.LIST): $(ACTION.HGR.SOURCES) | $(MD)
	(cd res/ACTION.HGR/ && for f in [MNOP]*; do echo "$$f"; done) > "$@"

$(ACTION.HGR4.LIST): $(ACTION.HGR.SOURCES) | $(MD)
	(cd res/ACTION.HGR/ && for f in [QRST]*; do echo "$$f"; done) > "$@"

$(ACTION.HGR5.LIST): $(ACTION.HGR.SOURCES) | $(MD)
	(cd res/ACTION.HGR/ && for f in [UVWX]*; do echo "$$f"; done) > "$@"

$(ACTION.HGR6.LIST): $(ACTION.HGR.SOURCES) | $(MD)
	(cd res/ACTION.HGR/ && for f in [YZ]*; do echo "$$f"; done) > "$@"

$(ACTION.DHGR.LIST): $(ACTION.DHGR.SOURCES) | $(MD)
	(cd res/ACTION.DHGR/ && for f in *; do echo "$$f"; done) > "$@"

$(ACTION.GR.LIST): $(ACTION.GR.SOURCES) | $(MD)
	(cd res/ACTION.GR/ && for f in *; do echo "$$f"; done) > "$@"

$(ACTION.DGR.LIST): $(ACTION.DGR.SOURCES) | $(MD)
	(cd res/ACTION.DGR/ && for f in *; do echo "$$f"; done) > "$@"

$(ARTWORK.SHR.LIST): $(ARTWORK.SHR.SOURCES) | $(MD)
	(cd res/ARTWORK.SHR/ && for f in *; do echo "$$f"; done) > "$@"

$(TITLE.HGR.LIST): $(TITLE.HGR.SOURCES) | $(MD)
	(cd res/TITLE.HGR/ && for f in *; do echo "$$f"; done) > "$@"

$(TITLE.DHGR.LIST): $(TITLE.DHGR.SOURCES) | $(MD)
	(cd res/TITLE.DHGR/ && for f in *; do echo "$$f"; done) > "$@"

$(TOTAL.DATA): $(FX) $(PRELAUNCH) $(DEMO) $(SS) $(X) $(ATTRACT) $(ATTRACT.IDX) $(HELPTEXT) $(CREDITS) $(GAMEHELP.COMPRESSED) $(GAMES.CONF) $(GAMES.SORTED) $(ACTION.HGR0.LIST) $(ACTION.HGR1.LIST) $(ACTION.HGR2.LIST) $(ACTION.HGR3.LIST) $(ACTION.HGR4.LIST) $(ACTION.HGR5.LIST) $(ACTION.HGR6.LIST) $(ACTION.DGR.LIST) $(ACTION.DHGR.LIST) $(ACTION.GR.LIST) $(ARTWORK.SHR.LIST) $(TITLE.DHGR.LIST) $(TITLE.HGR.LIST) $(CACHE.SOURCES) $(DFX.CONF) $(FX.CONF) $(SFX.CONF) $(COVER) $(HELP) $(JOYSTICK) $(TITLE)
#
# precompute indexed files for prelaunch
# note: prelaunch must be first in TOTAL.DATA due to a hack in LoadStandardPrelaunch
# note 2: these can not be padded because they are loaded at $0106 and padding would clobber the stack
#
	rm -f "$@"
	touch "$@"
	bin/buildindexedfile.py "$@" "$(BUILDDIR)"/PRELAUNCH.INDEXED < "$(GAMES.SORTED)" > "$(BUILDDIR)"/PRELAUNCH.IDX
#
# precompute indexed files for HGR & DHGR titles
# note: these are not padded because they are all an exact block-multiple anyway
#
	bin/padto.sh "$@"
	bin/buildindexedfile.py "$@" res/TITLE.HGR "$(BUILDDIR)"/HGR.TITLES.LOG < "$(TITLE.HGR.LIST)" > "$(BUILDDIR)"/TITLE.IDX
	bin/buildindexedfile.py "$@" res/TITLE.DHGR "$(BUILDDIR)"/DHGR.TITLES.LOG < "$(TITLE.DHGR.LIST)" > "$(BUILDDIR)"/DTITLE.IDX
	mkdir -p "$(BUILDDIR)"/index/
	bin/addfiles.py "$@" \
		"$(COVER)" "$(BUILDDIR)"/index/res.cover.idx.a \
		"$(TITLE)" "$(BUILDDIR)"/index/res.title.idx.a \
		"$(HELP)" "$(BUILDDIR)"/index/res.help.idx.a
#
# precompute indexed files for game help
# note: these can not be padded because they are compressed and the decompressor needs the exact size
#
	bin/buildindexedfile.py "$@" "$(GAMEHELP.COMPRESSED)" < "$(GAMES.SORTED)" > "$(BUILDDIR)"/GAMEHELP.IDX
#
# precompute indexed files for slideshows
# note: these can be padded because they're loaded into $800 at a time when $800..$1FFF is clobber-able
#
	bin/buildindexedfile.py -p "$@" "$(SS)" < "$(SS.LIST)" > "$(BUILDDIR)"/SLIDESHOW.IDX
	bin/buildindexedfile.py -p "$@" "$(ATTRACT)" < "$(MINI.ATTRACT0.LIST)" > "$(BUILDDIR)"/MINIATTRACT0.IDX
	bin/buildindexedfile.py -p "$@" "$(ATTRACT)" < "$(MINI.ATTRACT1.LIST)" > "$(BUILDDIR)"/MINIATTRACT1.IDX
#
# precompute indexed files for graphic effects
# note: these can be padded because they're loaded into $6000 at a time when $6000..$BEFF is clobber-able
#
	bin/buildindexedfile.py -p "$@" "$(BUILDDIR)"/FX.INDEXED < "$(FX.CONF)" > "$(BUILDDIR)"/FX.IDX
	bin/buildindexedfile.py -p "$@" "$(BUILDDIR)"/FX.INDEXED < "$(DFX.CONF)" > "$(BUILDDIR)"/DFX.IDX
	bin/buildindexedfile.py -p "$@" "$(BUILDDIR)"/FX.INDEXED < "$(SFX.CONF)" > "$(BUILDDIR)"/SFX.IDX
	bin/buildindexedfile.py -p "$@" "$(BUILDDIR)"/FXCODE < "$(FXCODE.LIST)" > "$(BUILDDIR)"/FXCODE.IDX
#
# precompute indexed files for coordinates files loaded by graphic effects
# note: these can not be padded because some of them are loaded into tight spaces near the unclobberable top of main memory
#
	bin/buildindexedfile.py "$@" "$(BUILDDIR)"/FXDATA < "$(FXDATA.LIST)" > "$(BUILDDIR)"/FXDATA.IDX
#
# precompute indexed files for HGR & DHGR action screenshots
# note: these can not be padded because they are compressed and the decompressor needs the exact size
#
	bin/buildindexedfile.py "$@" res/ACTION.HGR < "$(ACTION.HGR0.LIST)" > "$(BUILDDIR)"/HGR0.IDX
	bin/buildindexedfile.py "$@" res/ACTION.HGR < "$(ACTION.HGR1.LIST)" > "$(BUILDDIR)"/HGR1.IDX
	bin/buildindexedfile.py "$@" res/ACTION.HGR < "$(ACTION.HGR2.LIST)" > "$(BUILDDIR)"/HGR2.IDX
	bin/buildindexedfile.py "$@" res/ACTION.HGR < "$(ACTION.HGR3.LIST)" > "$(BUILDDIR)"/HGR3.IDX
	bin/buildindexedfile.py "$@" res/ACTION.HGR < "$(ACTION.HGR4.LIST)" > "$(BUILDDIR)"/HGR4.IDX
	bin/buildindexedfile.py "$@" res/ACTION.HGR < "$(ACTION.HGR5.LIST)" > "$(BUILDDIR)"/HGR5.IDX
	bin/buildindexedfile.py "$@" res/ACTION.HGR < "$(ACTION.HGR6.LIST)" > "$(BUILDDIR)"/HGR6.IDX
	bin/buildindexedfile.py "$@" res/ACTION.DHGR < "$(ACTION.DHGR.LIST)" > "$(BUILDDIR)"/DHGR.IDX
#
# precompute indexed files for GR and DGR action screenshots
# note: these can be padded because they are not compressed
#
	bin/buildindexedfile.py -p "$@" res/ACTION.GR < "$(ACTION.GR.LIST)" > "$(BUILDDIR)"/GR.IDX
	bin/buildindexedfile.py -p "$@" res/ACTION.DGR < "$(ACTION.DGR.LIST)" > "$(BUILDDIR)"/DGR.IDX
#
# precompute indexed files for SHR artwork
# note: these can not be padded because they are compressed and the decompressor needs the exact size
#
	bin/buildindexedfile.py "$@" res/ARTWORK.SHR < "$(ARTWORK.SHR.LIST)" > "$(BUILDDIR)"/ARTWORK.IDX
#
# precompute indexed files for demo launchers
# note: these can not be padded because some of them are loaded too close to $C000
#
	bin/buildindexedfile.py "$@" "$(DEMO)" < "$(DEMO.LIST)" > "$(BUILDDIR)"/DEMO.IDX

#
# precompute indexed files for single-load game binaries
# note: these can be padded because they are loaded at a time when all of main memory is clobber-able
#
	bin/buildindexedfile.py -p "$@" "$(BUILDDIR)"/X.INDEXED < "$(XSINGLE.LIST)" > "$(BUILDDIR)"/XSINGLE.IDX
#
# create search indexes for each variation of (game-requires-joystick) X (game-requires-128K)
# in the form of OKVS data structures, plus game counts in the form of source files
#
	$(PARALLEL) ::: \
	    '(grep "^00" < "$(GAMES.CONF)" | bin/buildsearch.py "$(BUILDDIR)"/index/count00.a "$(BUILDDIR)"/HGR.TITLES.LOG "" > "$(BUILDDIR)"/SEARCH00.IDX)' \
	    '(grep "^0" < "$(GAMES.CONF)" | bin/buildsearch.py "$(BUILDDIR)"/index/count01.a "$(BUILDDIR)"/HGR.TITLES.LOG "$(BUILDDIR)"/DHGR.TITLES.LOG > "$(BUILDDIR)"/SEARCH01.IDX)' \
	    '(grep "^.0" < "$(GAMES.CONF)" | bin/buildsearch.py "$(BUILDDIR)"/index/count10.a "$(BUILDDIR)"/HGR.TITLES.LOG "" > "$(BUILDDIR)"/SEARCH10.IDX)' \
	    '(bin/buildsearch.py "$(BUILDDIR)"/index/count11.a "$(BUILDDIR)"/HGR.TITLES.LOG "$(BUILDDIR)"/DHGR.TITLES.LOG < "$(GAMES.CONF)" > "$(BUILDDIR)"/SEARCH11.IDX)'
#
# add IDX files to the combined index file and generate
# the index records that callers use to reference them,
# plus additional miscellaneous files
#
	bin/addfiles.py "$@" \
		"$(BUILDDIR)"/SEARCH00.IDX "$(BUILDDIR)"/index/search00.idx.a \
		res/CACHE00.IDX "$(BUILDDIR)"/index/cache00.idx.a \
		"$(BUILDDIR)"/SEARCH01.IDX "$(BUILDDIR)"/index/search01.idx.a \
		res/CACHE01.IDX "$(BUILDDIR)"/index/cache01.idx.a \
		"$(BUILDDIR)"/SEARCH10.IDX "$(BUILDDIR)"/index/search10.idx.a \
		res/CACHE10.IDX "$(BUILDDIR)"/index/cache10.idx.a \
		"$(BUILDDIR)"/SEARCH11.IDX "$(BUILDDIR)"/index/search11.idx.a \
		res/CACHE11.IDX "$(BUILDDIR)"/index/cache11.idx.a \
		"$(BUILDDIR)"/PRELAUNCH.IDX "$(BUILDDIR)"/index/prelaunch.idx.a \
		"$(ATTRACT.IDX)" "$(BUILDDIR)"/index/attract.idx.a \
		"$(BUILDDIR)"/DEMO.IDX "$(BUILDDIR)"/index/demo.idx.a \
		"$(BUILDDIR)"/XSINGLE.IDX "$(BUILDDIR)"/index/xsingle.idx.a \
		"$(BUILDDIR)"/FX.IDX "$(BUILDDIR)"/index/fx.idx.a \
		"$(BUILDDIR)"/DFX.IDX "$(BUILDDIR)"/index/dfx.idx.a \
		"$(BUILDDIR)"/SFX.IDX "$(BUILDDIR)"/index/sfx.idx.a \
		"$(BUILDDIR)"/FXCODE.IDX "$(BUILDDIR)"/index/fxcode.idx.a \
		"$(BUILDDIR)"/FXDATA.IDX "$(BUILDDIR)"/index/fxdata.idx.a \
		"$(BUILDDIR)"/GAMEHELP.IDX "$(BUILDDIR)"/index/gamehelp.idx.a \
		"$(BUILDDIR)"/SLIDESHOW.IDX "$(BUILDDIR)"/index/slideshow.idx.a \
		"$(BUILDDIR)"/MINIATTRACT0.IDX "$(BUILDDIR)"/index/miniattract0.idx.a \
		"$(BUILDDIR)"/MINIATTRACT1.IDX "$(BUILDDIR)"/index/miniattract1.idx.a \
		"$(BUILDDIR)"/TITLE.IDX "$(BUILDDIR)"/index/title.idx.a \
		"$(BUILDDIR)"/DTITLE.IDX "$(BUILDDIR)"/index/dtitle.idx.a \
		"$(BUILDDIR)"/HGR0.IDX "$(BUILDDIR)"/index/hgr0.idx.a \
		"$(BUILDDIR)"/HGR1.IDX "$(BUILDDIR)"/index/hgr1.idx.a \
		"$(BUILDDIR)"/HGR2.IDX "$(BUILDDIR)"/index/hgr2.idx.a \
		"$(BUILDDIR)"/HGR3.IDX "$(BUILDDIR)"/index/hgr3.idx.a \
		"$(BUILDDIR)"/HGR4.IDX "$(BUILDDIR)"/index/hgr4.idx.a \
		"$(BUILDDIR)"/HGR5.IDX "$(BUILDDIR)"/index/hgr5.idx.a \
		"$(BUILDDIR)"/HGR6.IDX "$(BUILDDIR)"/index/hgr6.idx.a \
		"$(BUILDDIR)"/DHGR.IDX "$(BUILDDIR)"/index/dhgr.idx.a \
		"$(BUILDDIR)"/GR.IDX "$(BUILDDIR)"/index/gr.idx.a \
		"$(BUILDDIR)"/DGR.IDX "$(BUILDDIR)"/index/dgr.idx.a \
		"$(BUILDDIR)"/ARTWORK.IDX "$(BUILDDIR)"/index/artwork.idx.a \
		"$(BUILDDIR)"/COVERFADE "$(BUILDDIR)"/index/coverfade.idx.a \
		"$(BUILDDIR)"/GR.FIZZLE "$(BUILDDIR)"/index/gr.fizzle.idx.a \
		"$(BUILDDIR)"/DGR.FIZZLE "$(BUILDDIR)"/index/dgr.fizzle.idx.a \
		"$(HELPTEXT)" "$(BUILDDIR)"/index/helptext.idx.a \
		"$(CREDITS)" "$(BUILDDIR)"/index/credits.idx.a \
		"$(JOYSTICK)" "$(BUILDDIR)"/index/joystick.idx.a
	@touch "$@"

# assemble main program
$(LAUNCHER.SYSTEM): $(LAUNCHER.SOURCES) | $(MD) $(TOTAL.DATA)
	$(ACME) -DBUILDNUMBER=`git rev-list --count HEAD` src/4cade.a 2>"$(BUILDDIR)"/relbase.log
	$(ACME) -r "$(BUILDDIR)"/4cade.lst -DBUILDNUMBER=`git rev-list --count HEAD` -DRELBASE=`cat "$(BUILDDIR)"/relbase.log | grep "RELBASE =" | cut -d"=" -f2 | cut -d"(" -f2 | cut -d")" -f1` src/4cade.a
	@touch "$@"

# assemble launchers for self-running demos
$(DEMO): $(DEMO.SOURCES) | $(MD)
	mkdir -p "$@"
	$(PARALLEL) 'if grep -q "^!to" "{}"; then $(ACME) "{}"; fi' ::: src/demo/*.a
	(cd "$(DEMO)"/ && for f in *; do echo "$$f"; done) > "$(DEMO.LIST)"
	@touch "$@"

# assemble graphic effects
$(FX): $(FX.SOURCES) | $(MD)
	mkdir -p "$@" "$(BUILDDIR)"/FX.INDEXED "$(BUILDDIR)"/FXDATA "$(BUILDDIR)"/FXDATA.UNCOMPRESSED "$(BUILDDIR)"/FXCODE
	$(PARALLEL) 'if grep -q "^!to" "{}"; then $(ACME) "{}"; fi' ::: src/fx/*.a
	$(PARALLEL) '${EXOMIZER} {}@0x$$(echo {/}|cut -d, -f2) -o "$(BUILDDIR)/FXDATA/"$$(echo {/}|cut -d, -f1)' ::: "$(BUILDDIR)"/FXDATA.UNCOMPRESSED/*
	(cd "$(BUILDDIR)"/FXCODE/ && for f in *; do echo "$$f"; done) > "$(FXCODE.LIST)"
	(cd "$(BUILDDIR)"/FXDATA/ && for f in *; do echo "$$f"; done) > "$(FXDATA.LIST)"
	@touch "$@"

# assemble launchers for games
$(PRELAUNCH): $(PRELAUNCH.SOURCES) | $(MD)
	mkdir -p "$@" "$(BUILDDIR)"/PRELAUNCH.INDEXED
	$(PARALLEL) 'if grep -q "^!to" "{}"; then $(ACME) "{}"; fi' ::: src/prelaunch/*.a
	@touch "$@"

# assemble bootloader
$(PROBOOTHD): $(PROBOOT.SOURCES) | $(MD)
	$(ACME) -r "$(BUILDDIR)"/proboothd.lst src/proboothd/proboothd.a
	@touch "$@"

#
# |compress| must be called separately because it is slow and
# only needs to be run when a new graphic file is added.
# It create files in the repository which can then be checked in.
#
# Most of these files are a known size (enforced by truncate command)
# so we do not include the target address in the compressed data.
# The launcher will set the target address at runtime before
# decompressing. This saves 2 bytes per file.
#
compress: $(MD)
	$(PARALLEL) '[ -f "res/ACTION.HGR/{/}" ] || (truncate -s 8192 "{}" && ${EXOMIZER} "{}"@0x0000 -o "res/ACTION.HGR/{/}" && truncate -s -2 "res/ACTION.HGR/{/}")' ::: res/ACTION.HGR.UNCOMPRESSED/*
	$(PARALLEL) '[ -f "res/ACTION.DHGR/{/}" ] || (truncate -s 16384 "{}" && ${EXOMIZER} "{}"@0x0000 -o "res/ACTION.DHGR/{/}" && truncate -s -2 "res/ACTION.DHGR/{/}")' ::: res/ACTION.DHGR.UNCOMPRESSED/*
	$(PARALLEL) '[ -f "res/ARTWORK.SHR/{/}" ] || (truncate -s 32768 "{}" && ${EXOMIZER} "{}"@0x0000 -o "res/ARTWORK.SHR/{/}" && truncate -s -2 "res/ARTWORK.SHR/{/}")' ::: res/ARTWORK.SHR.UNCOMPRESSED/*
	$(PARALLEL) '[ -f "res/TITLE.HGR/{/}" ] || bin/packhgrfile.py "{}" "res/TITLE.HGR/{/}"' ::: res/TITLE.HGR.UNPACKED/*
	$(PARALLEL) '[ -f "res/TITLE.DHGR/{/}" ] || bin/packdhgrfile.py "{}" "res/TITLE.DHGR/{/}"' ::: res/TITLE.DHGR.UNPACKED/*

#
# |attract| must be called separately because it is slow and
# only needs to be run when a new game or demo is added.
# It create files in the repository which can then be checked in.
#
attract: compress
	bin/check-attract-mode.sh
	bin/generate-mini-attract-mode.sh

#
# |cache| must be called separately because it is slow and
# only needs to be run when a new game is added.
# It create files in the repository which can then be checked in.
#
cache: $(GAMES.CONF)
	$(PARALLEL) ::: \
	    'awk -F= '"'"'/^00/ { print $$2 }'"'"' < "$(GAMES.CONF)" | bin/buildcache.py > "$(BUILDDIR)"/cache00.a' \
	    'awk -F= '"'"'/^0/ { print $$2 }'"'"' < "$(GAMES.CONF)" | bin/buildcache.py > "$(BUILDDIR)"/cache01.a' \
	    'awk -F= '"'"'/^.0/ { print $$2 }'"'"' < "$(GAMES.CONF)" | bin/buildcache.py > "$(BUILDDIR)"/cache10.a' \
	    'awk -F= '"'"'!/^$$|^#/ { print $$2 }'"'"' < "$(GAMES.CONF)" | bin/buildcache.py > "$(BUILDDIR)"/cache11.a'
	$(PARALLEL) ::: \
	    '$(ACME) -o res/CACHE00.IDX "$(BUILDDIR)"/cache00.a' \
	    '$(ACME) -o res/CACHE01.IDX "$(BUILDDIR)"/cache01.a' \
	    '$(ACME) -o res/CACHE10.IDX "$(BUILDDIR)"/cache10.a' \
	    '$(ACME) -o res/CACHE11.IDX "$(BUILDDIR)"/cache11.a'

mount: $(HDV)
	osascript bin/V2Make.scpt "`pwd`" bin/4cade.vii "$(HDV)"

$(MD):
	@$(ACME) --version | grep -q "ACME, release" || (echo "ACME is not installed" && exit 1)
	@$(CADIUS) | grep -q "cadius v" || (echo "Cadius is not installed" && exit 1)
	@$(PARALLEL) --version | grep -q "GNU" || (echo "GNU Parallel is not installed" && exit 1)
	@$(PYTHON) --version | grep -q "Python 3" || (echo "Python 3 is not installed" && exit 1)
	mkdir -p "$(BUILDDIR)"
	touch "$(CADIUS.LOG)"
	@touch "$@"

clean:
	rm -rf "$(BUILDDIR)"/ || rm -rf "$(BUILDDIR)"

all: clean $(HDV) mount

al: all

.NOTPARALLEL:
