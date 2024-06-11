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

BUILDDIR=build
MD=$(BUILDDIR)/make.touch
DEMO.SOURCES=$(wildcard src/demo/*.a)
FX.SOURCES=$(wildcard src/fx/*.a)
PRELAUNCH.SOURCES=$(wildcard src/prelaunch/*.a)
PROBOOT.SOURCES=$(wildcard src/proboot/*.a)
LAUNCHER.SOURCES=$(wildcard src/*.a)
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
ICONS=$(wildcard res/ICONS/*)
ATTRACT.CONF=res/ATTRACT.CONF
DFX.CONF=res/DFX.CONF
FX.CONF=res/FX.CONF
SFX.CONF=res/SFX.CONF
PREFS.CONF.SOURCE=res/PREFS.CONF
COVER=res/COVER
DECRUNCH=res/DECRUNCH
FINDER.DATA=res/Finder.Data
FINDER.ROOT=res/Finder.Root
HELP=res/HELP
JOYSTICK=res/JOYSTICK
TITLE=res/TITLE

.PHONY: compress attract cache clean mount all al

$(HDV): $(PROBOOTHD) $(LAUNCHER.SYSTEM) $(PRELAUNCH) $(X) $(TOTAL.DATA) $(TITLE.ANIMATED.SOURCES) $(ICONS) $(FINDER.DATA) $(FINDER.ROOT) $(PREFS.CONF)
	cp res/blank.hdv "$@"
	cp res/_FileInformation.txt "$(BUILDDIR)"/
	$(CADIUS) ADDFILE "$@" "/$(VOLUME)/" "$(BUILDDIR)"/LAUNCHER.SYSTEM -C >>"$(BUILDDIR)"/log
	for f in "$(TOTAL.DATA)" "$(PREFS.CONF)" "$(FINDER.DATA)" "$(FINDER.ROOT)"; do \
	    $(CADIUS) ADDFILE "$@" "/$(VOLUME)/" "$$f" -C >>"$(BUILDDIR)"/log; \
	done
	cp src/prelaunch/_FileInformation.txt "$(BUILDDIR)"/PRELAUNCH/
	for f in res/TITLE.ANIMATED res/ICONS "$(PRELAUNCH)" "$(X)"; do \
            rm -f "$$f"/.DS_Store; \
            $(CADIUS) ADDFOLDER "$@" "/$(VOLUME)/$$(basename $$f)" "$$f" -C >>"$(BUILDDIR)"/log; \
        done
	bin/changebootloader.sh "$@" $(PROBOOTHD)
	@touch "$@"

$(PREFS.CONF): $(PREFS.CONF.SOURCE) | $(MD)
	cp "$(PREFS.CONF.SOURCE)" "$@"
	bin/padto.sh "$@"

# create a version of GAMES.CONF without comments or blank lines or anything after display titles
$(GAMES.CONF): $(MD)
	awk '!/^$$|^#/' < res/GAMES.CONF | awk -F'/' '{ print $$1 }' > "$@"

# create a list of all game filenames, without metadata or display names, sorted by game filename
$(GAMES.SORTED): $(GAMES.CONF)
	awk -F, '/,/ { print $$2 }' < "$(GAMES.CONF)" | awk -F= '{ print $$1 }' | sort > "$@"

# extract files from original disk images and move them to their final directories
$(X): $(GAMES.CONF)
	mkdir -p "$@" "$(BUILDDIR)"/X.INDEXED
	$(PARALLEL) '$(CADIUS) EXTRACTVOLUME {} "$@"/ >>"$(BUILDDIR)"/log' ::: res/dsk/*.po
	rm -f "$@"/**/.DS_Store "$@"/**/PRODOS* "$@"/**/LOADER.SYSTEM* "$@"/**/_FileInformation.txt
	for f in $$(grep '^....1' "$(GAMES.CONF)" | awk '!/^$$|^#/' | awk -F, '/,/ { print $$2 }' | awk -F= '{ print $$1 }'); do mv "$@"/"$$f"/"$$f"* "$(BUILDDIR)"/X.INDEXED/; rm -rf "$@"/"$$f"; done
	(cd "$(BUILDDIR)"/X.INDEXED/ && for f in *; do echo "$$f"; done) > "$(XSINGLE.LIST)"
	for d in "$@"/*; do mv "$$d"/* "$@"/; rmdir "$$d"; done
	@touch "$@"

# precompute binary data structure for mega-attract mode configuration file
$(ATTRACT.IDX): $(MD)
	bin/buildokvs.sh < res/ATTRACT.CONF > "$@"

# precompute binary data structure and substitute special characters in global help
$(HELPTEXT): $(MD)
	bin/converthelp.sh res/HELPTEXT "$@"

# precompute binary data structure and substitute special characters in credits
$(CREDITS): $(MD)
	bin/converthelp.sh res/CREDITS "$@"

# precompute binary data structures and substitute special characters for each game's help
$(GAMEHELP): $(GAMEHELP.SOURCES) | $(MD)
	mkdir -p "$@"
	$(PARALLEL) 'bin/converthelp.sh "{}" "$@/{/}"' ::: res/GAMEHELP/*
	@touch "$@"

# precompute binary data structures for slideshow configuration files
$(SS): $(SS.SOURCES) | $(MD)
	mkdir -p "$@"
	$(PARALLEL) '[ $$(echo "{/}" | cut -c-3) = "ACT" ] && bin/buildslideshow.py -d "$(GAMES.CONF)" < "{}" > "$@/{/}" || bin/buildslideshow.py "$(GAMES.CONF)" < "{}" > "$@/{/}"' ::: res/SS/*
	(cd "$(BUILDDIR)"/SS/ && for f in *; do echo "$$f"; done) > "$(SS.LIST)"
	@touch "$@"

# precompute binary data structures for each game's mini-attract configuration file
$(ATTRACT): $(ATTRACT.SOURCES) | $(MD)
	mkdir -p "$@"
	$(PARALLEL) 'bin/buildokvs.sh < "{}" > "$@/{/}"' ::: res/ATTRACT/*
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

$(TOTAL.DATA): $(FX) $(PRELAUNCH) $(DEMO) $(SS) $(X) $(ATTRACT) $(ATTRACT.IDX) $(HELPTEXT) $(CREDITS) $(GAMEHELP) $(GAMES.CONF) $(GAMES.SORTED) $(ACTION.HGR0.LIST) $(ACTION.HGR1.LIST) $(ACTION.HGR2.LIST) $(ACTION.HGR3.LIST) $(ACTION.HGR4.LIST) $(ACTION.HGR5.LIST) $(ACTION.HGR6.LIST) $(ACTION.DGR.LIST) $(ACTION.DHGR.LIST) $(ACTION.GR.LIST) $(ARTWORK.SHR.LIST) $(TITLE.DHGR.LIST) $(TITLE.HGR.LIST) $(CACHE.SOURCES) $(ATTRACT.CONF) $(DFX.CONF) $(FX.CONF) $(SFX.CONF) $(COVER) $(DECRUNCH) $(HELP) $(JOYSTICK) $(TITLE)
#
# precompute indexed files for prelaunch
# note: prelaunch must be first in TOTAL.DATA due to a hack in LoadStandardPrelaunch
# note 2: these can not be padded because they are loaded at $0106 and padding would clobber the stack
#
	bin/buildindexedfile.py "$(TOTAL.DATA)" "$(BUILDDIR)"/PRELAUNCH.INDEXED "" < "$(GAMES.SORTED)" > "$(BUILDDIR)"/PRELAUNCH.IDX
#
# precompute indexed files for HGR & DHGR titles
# note: these are not padded because they are all an exact block-multiple anyway
#
	bin/padto.sh "$(TOTAL.DATA)"
	bin/buildindexedfile.py -a "$(TOTAL.DATA)" res/TITLE.HGR "$(BUILDDIR)"/HGR.TITLES.LOG < "$(TITLE.HGR.LIST)" > "$(BUILDDIR)"/TITLE.IDX
	bin/buildindexedfile.py -a "$(TOTAL.DATA)" res/TITLE.DHGR "$(BUILDDIR)"/DHGR.TITLES.LOG < "$(TITLE.DHGR.LIST)" > "$(BUILDDIR)"/DTITLE.IDX
	bin/addfile.sh "$(COVER)" "$(TOTAL.DATA)" > src/index/res.cover.idx.a
	bin/addfile.sh "$(TITLE)" "$(TOTAL.DATA)" > src/index/res.title.idx.a
	bin/addfile.sh "$(HELP)" "$(TOTAL.DATA)" > src/index/res.help.idx.a
#
# precompute indexed files for game help
# note: these can be padded because they're loaded into $800 at a time when $800..$1FFF is clobber-able
#
	bin/buildindexedfile.py -p -a "$(TOTAL.DATA)" "$(GAMEHELP)" "" < "$(GAMES.SORTED)" > "$(BUILDDIR)"/GAMEHELP.IDX
#
# precompute indexed files for slideshows
# note: these can be padded because they're loaded into $800 at a time when $800..$1FFF is clobber-able
#
	bin/buildindexedfile.py -p -a "$(TOTAL.DATA)" "$(SS)" "" < "$(SS.LIST)" > "$(BUILDDIR)"/SLIDESHOW.IDX
	bin/buildindexedfile.py -p -a "$(TOTAL.DATA)" "$(ATTRACT)" "" < "$(MINI.ATTRACT0.LIST)" > "$(BUILDDIR)"/MINIATTRACT0.IDX
	bin/buildindexedfile.py -p -a "$(TOTAL.DATA)" "$(ATTRACT)" "" < "$(MINI.ATTRACT1.LIST)" > "$(BUILDDIR)"/MINIATTRACT1.IDX
#
# precompute indexed files for graphic effects
# note: these can be padded because they're loaded into $6000 at a time when $6000..$BEFF is clobber-able
#
	bin/buildindexedfile.py -p -a "$(TOTAL.DATA)" "$(BUILDDIR)"/FX.INDEXED "" < "$(FX.CONF)" > "$(BUILDDIR)"/FX.IDX
	bin/buildindexedfile.py -p -a "$(TOTAL.DATA)" "$(BUILDDIR)"/FX.INDEXED "" < "$(DFX.CONF)" > "$(BUILDDIR)"/DFX.IDX
	bin/buildindexedfile.py -p -a "$(TOTAL.DATA)" "$(BUILDDIR)"/FX.INDEXED "" < "$(SFX.CONF)" > "$(BUILDDIR)"/SFX.IDX
	bin/buildindexedfile.py -p -a "$(TOTAL.DATA)" "$(BUILDDIR)"/FXCODE "" < "$(FXCODE.LIST)" > "$(BUILDDIR)"/FXCODE.IDX
#
# precompute indexed files for coordinates files loaded by graphic effects
# note: these can not be padded because some of them are loaded into tight spaces near the unclobberable top of main memory
#
	bin/buildindexedfile.py -a "$(TOTAL.DATA)" "$(BUILDDIR)"/FXDATA "" < "$(FXDATA.LIST)" > "$(BUILDDIR)"/FXDATA.IDX
#
# precompute indexed files for HGR & DHGR action screenshots
# note: these can not be padded because they are compressed and the decompressor needs the exact size
#
	bin/buildindexedfile.py -a "$(TOTAL.DATA)" res/ACTION.HGR "" < "$(ACTION.HGR0.LIST)" > "$(BUILDDIR)"/HGR0.IDX
	bin/buildindexedfile.py -a "$(TOTAL.DATA)" res/ACTION.HGR "" < "$(ACTION.HGR1.LIST)" > "$(BUILDDIR)"/HGR1.IDX
	bin/buildindexedfile.py -a "$(TOTAL.DATA)" res/ACTION.HGR "" < "$(ACTION.HGR2.LIST)" > "$(BUILDDIR)"/HGR2.IDX
	bin/buildindexedfile.py -a "$(TOTAL.DATA)" res/ACTION.HGR "" < "$(ACTION.HGR3.LIST)" > "$(BUILDDIR)"/HGR3.IDX
	bin/buildindexedfile.py -a "$(TOTAL.DATA)" res/ACTION.HGR "" < "$(ACTION.HGR4.LIST)" > "$(BUILDDIR)"/HGR4.IDX
	bin/buildindexedfile.py -a "$(TOTAL.DATA)" res/ACTION.HGR "" < "$(ACTION.HGR5.LIST)" > "$(BUILDDIR)"/HGR5.IDX
	bin/buildindexedfile.py -a "$(TOTAL.DATA)" res/ACTION.HGR "" < "$(ACTION.HGR6.LIST)" > "$(BUILDDIR)"/HGR6.IDX
	bin/buildindexedfile.py -a "$(TOTAL.DATA)" res/ACTION.DHGR "" < "$(ACTION.DHGR.LIST)" > "$(BUILDDIR)"/DHGR.IDX
#
# precompute indexed files for GR and DGR action screenshots
# note: these can be padded because they are not compressed
#
	bin/buildindexedfile.py -a -p "$(TOTAL.DATA)" res/ACTION.GR "" < "$(ACTION.GR.LIST)" > "$(BUILDDIR)"/GR.IDX
	bin/buildindexedfile.py -a -p "$(TOTAL.DATA)" res/ACTION.DGR "" < "$(ACTION.DGR.LIST)" > "$(BUILDDIR)"/DGR.IDX
#
# precompute indexed files for SHR artwork
# note: these can not be padded because they are compressed and the decompressor needs the exact size
#
	bin/buildindexedfile.py -a "$(TOTAL.DATA)" res/ARTWORK.SHR "" < "$(ARTWORK.SHR.LIST)" > "$(BUILDDIR)"/ARTWORK.IDX
#
# precompute indexed files for demo launchers
# note: these can not be padded because some of them are loaded too close to $C000
#
	bin/buildindexedfile.py -a "$(TOTAL.DATA)" "$(DEMO)" "" < "$(DEMO.LIST)" > "$(BUILDDIR)"/DEMO.IDX
	bin/addfile.sh "$(BUILDDIR)"/DEMO.IDX "$(TOTAL.DATA)" > src/index/demo.idx.a

#
# precompute indexed files for single-load game binaries
# note: these can be padded because they are loaded at a time when all of main memory is clobber-able
#
	bin/buildindexedfile.py -a -p "$(TOTAL.DATA)" "$(BUILDDIR)"/X.INDEXED "" < "$(XSINGLE.LIST)" > "$(BUILDDIR)"/XSINGLE.IDX
	bin/addfile.sh "$(BUILDDIR)"/XSINGLE.IDX "$(TOTAL.DATA)" > src/index/xsingle.idx.a
#
# create search indexes for each variation of (game-requires-joystick) X (game-requires-128K)
# in the form of OKVS data structures, plus game counts in the form of source files
#
	$(PARALLEL) ::: \
	    '(grep "^00" < "$(GAMES.CONF)" | bin/buildsearch.py src/index/count00.a "$(BUILDDIR)"/HGR.TITLES.LOG "" > "$(BUILDDIR)"/SEARCH00.IDX)' \
	    '(grep "^0" < "$(GAMES.CONF)" | bin/buildsearch.py src/index/count01.a "$(BUILDDIR)"/HGR.TITLES.LOG "$(BUILDDIR)"/DHGR.TITLES.LOG > "$(BUILDDIR)"/SEARCH01.IDX)' \
	    '(grep "^.0" < "$(GAMES.CONF)" | bin/buildsearch.py src/index/count10.a "$(BUILDDIR)"/HGR.TITLES.LOG "" > "$(BUILDDIR)"/SEARCH10.IDX)' \
	    '(bin/buildsearch.py src/index/count11.a "$(BUILDDIR)"/HGR.TITLES.LOG "$(BUILDDIR)"/DHGR.TITLES.LOG < "$(GAMES.CONF)" > "$(BUILDDIR)"/SEARCH11.IDX)'
#
# add IDX files to the combined index file and generate
# the index records that callers use to reference them
#
	bin/addfile.sh "$(BUILDDIR)"/SEARCH00.IDX "$(TOTAL.DATA)" > src/index/search00.idx.a
	bin/addfile.sh res/CACHE00.IDX "$(TOTAL.DATA)" > src/index/cache00.idx.a
	bin/addfile.sh "$(BUILDDIR)"/SEARCH01.IDX "$(TOTAL.DATA)" > src/index/search01.idx.a
	bin/addfile.sh res/CACHE01.IDX "$(TOTAL.DATA)" > src/index/cache01.idx.a
	bin/addfile.sh "$(BUILDDIR)"/SEARCH10.IDX "$(TOTAL.DATA)" > src/index/search10.idx.a
	bin/addfile.sh res/CACHE10.IDX "$(TOTAL.DATA)" > src/index/cache10.idx.a
	bin/addfile.sh "$(BUILDDIR)"/SEARCH11.IDX "$(TOTAL.DATA)" > src/index/search11.idx.a
	bin/addfile.sh res/CACHE11.IDX "$(TOTAL.DATA)" > src/index/cache11.idx.a
	bin/addfile.sh "$(BUILDDIR)"/PRELAUNCH.IDX "$(TOTAL.DATA)" > src/index/prelaunch.idx.a
	bin/addfile.sh "$(ATTRACT.IDX)" "$(TOTAL.DATA)" > src/index/attract.idx.a
	bin/addfile.sh "$(BUILDDIR)"/FX.IDX "$(TOTAL.DATA)" > src/index/fx.idx.a
	bin/addfile.sh "$(BUILDDIR)"/DFX.IDX "$(TOTAL.DATA)" > src/index/dfx.idx.a
	bin/addfile.sh "$(BUILDDIR)"/SFX.IDX "$(TOTAL.DATA)" > src/index/sfx.idx.a
	bin/addfile.sh "$(BUILDDIR)"/FXCODE.IDX "$(TOTAL.DATA)" > src/index/fxcode.idx.a
	bin/addfile.sh "$(BUILDDIR)"/FXDATA.IDX "$(TOTAL.DATA)" > src/index/fxdata.idx.a
	bin/addfile.sh "$(BUILDDIR)"/GAMEHELP.IDX "$(TOTAL.DATA)" > src/index/gamehelp.idx.a
	bin/addfile.sh "$(BUILDDIR)"/SLIDESHOW.IDX "$(TOTAL.DATA)" > src/index/slideshow.idx.a
	bin/addfile.sh "$(BUILDDIR)"/MINIATTRACT0.IDX "$(TOTAL.DATA)" > src/index/miniattract0.idx.a
	bin/addfile.sh "$(BUILDDIR)"/MINIATTRACT1.IDX "$(TOTAL.DATA)" > src/index/miniattract1.idx.a
	bin/addfile.sh "$(BUILDDIR)"/TITLE.IDX "$(TOTAL.DATA)" > src/index/title.idx.a
	bin/addfile.sh "$(BUILDDIR)"/DTITLE.IDX "$(TOTAL.DATA)" > src/index/dtitle.idx.a
	bin/addfile.sh "$(BUILDDIR)"/HGR0.IDX "$(TOTAL.DATA)" > src/index/hgr0.idx.a
	bin/addfile.sh "$(BUILDDIR)"/HGR1.IDX "$(TOTAL.DATA)" > src/index/hgr1.idx.a
	bin/addfile.sh "$(BUILDDIR)"/HGR2.IDX "$(TOTAL.DATA)" > src/index/hgr2.idx.a
	bin/addfile.sh "$(BUILDDIR)"/HGR3.IDX "$(TOTAL.DATA)" > src/index/hgr3.idx.a
	bin/addfile.sh "$(BUILDDIR)"/HGR4.IDX "$(TOTAL.DATA)" > src/index/hgr4.idx.a
	bin/addfile.sh "$(BUILDDIR)"/HGR5.IDX "$(TOTAL.DATA)" > src/index/hgr5.idx.a
	bin/addfile.sh "$(BUILDDIR)"/HGR6.IDX "$(TOTAL.DATA)" > src/index/hgr6.idx.a
	bin/addfile.sh "$(BUILDDIR)"/DHGR.IDX "$(TOTAL.DATA)" > src/index/dhgr.idx.a
	bin/addfile.sh "$(BUILDDIR)"/GR.IDX "$(TOTAL.DATA)" > src/index/gr.idx.a
	bin/addfile.sh "$(BUILDDIR)"/DGR.IDX "$(TOTAL.DATA)" > src/index/dgr.idx.a
	bin/addfile.sh "$(BUILDDIR)"/ARTWORK.IDX "$(TOTAL.DATA)" > src/index/artwork.idx.a
#
# add additional miscellaneous files
#
	bin/addfile.sh "$(BUILDDIR)"/COVERFADE "$(TOTAL.DATA)" > src/index/coverfade.idx.a
	bin/addfile.sh "$(BUILDDIR)"/GR.FIZZLE "$(TOTAL.DATA)" > src/index/gr.fizzle.idx.a
	bin/addfile.sh "$(BUILDDIR)"/DGR.FIZZLE "$(TOTAL.DATA)" > src/index/dgr.fizzle.idx.a
	bin/addfile.sh "$(HELPTEXT)" "$(TOTAL.DATA)" > src/index/helptext.idx.a
	bin/addfile.sh "$(CREDITS)" "$(TOTAL.DATA)" > src/index/credits.idx.a
	bin/addfile.sh "$(DECRUNCH)" "$(TOTAL.DATA)" > src/index/decrunch.idx.a
	bin/addfile.sh "$(JOYSTICK)" "$(TOTAL.DATA)" > src/index/joystick.idx.a
	@touch "$@"

# assemble main program
$(LAUNCHER.SYSTEM): $(LAUNCHER.SOURCES) | $(MD)
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
	mkdir -p "$@" "$(BUILDDIR)"/FX.INDEXED "$(BUILDDIR)"/FXDATA "$(BUILDDIR)"/FXCODE
	$(PARALLEL) 'if grep -q "^!to" "{}"; then $(ACME) "{}"; fi' ::: src/fx/*.a
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
compress: $(MD)
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
	touch "$(BUILDDIR)"/log
	@touch "$@"

clean:
	rm -rf "$(BUILDDIR)"/ || rm -rf "$(BUILDDIR)"

all: clean dsk mount

al: all

.NOTPARALLEL:
