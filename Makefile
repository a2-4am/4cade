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
FX=$(BUILDDIR)/FX
PRELAUNCH=$(BUILDDIR)/PRELAUNCH
LAUNCHER.SYSTEM=$(BUILDDIR)/LAUNCHER.SYSTEM
ATTRACT=$(BUILDDIR)/ATTRACT
ATTRACT.IDX=$(BUILDDIR)/ATTRACT.IDX
HELPTEXT=$(BUILDDIR)/HELPTEXT
CREDITS=$(BUILDDIR)/CREDITS
GAMEHELP=$(BUILDDIR)/GAMEHELP
GAMES.CONF=$(BUILDDIR)/GAMES.CONF
GAMES.SORTED=$(BUILDDIR)/GAMES.SORTED
SS=$(BUILDDIR)/SS
TOTAL.DATA=$(BUILDDIR)/TOTAL.DATA
X=$(BUILDDIR)/X
ACTION.DGR=$(wildcard res/ACTION.DGR/*)
ACTION.DHGR=$(wildcard res/ACTION.DHGR/*)
ACTION.GR=$(wildcard res/ACTION.GR/*)
ACTION.HGR=$(wildcard res/ACTION.HGR/*)
ARTWORK.SHR=$(wildcard res/ARTWORK.SHR/*)
ATTRACT.SOURCES=$(wildcard res/ATTRACT/*)
GAMEHELP.SOURCES=$(wildcard res/GAMEHELP/*)
SS.SOURCES=$(wildcard res/SS/*)
TITLE.ANIMATED=$(wildcard res/TITLE.ANIMATED/*)
TITLE.DHGR=$(wildcard res/TITLE.DHGR/*)
TITLE.HGR=$(wildcard res/TITLE.HGR/*)
CACHE.IDX=$(wildcard res/CACHE*.IDX)
ICONS=$(wildcard res/ICONS/*)
ATTRACT.CONF=res/ATTRACT.CONF
DFX.CONF=res/DFX.CONF
FX.CONF=res/FX.CONF
SFX.CONF=res/SFX.CONF
PREFS.CONF=res/PREFS.CONF
COVER=res/COVER
DECRUNCH=res/DECRUNCH
FINDER.DATA=res/Finder.Data
FINDER.ROOT=res/Finder.Root
HELP=res/HELP
JOYSTICK=res/JOYSTICK
TITLE=res/TITLE

.PHONY: preconditions compress attract cache clean mount all al

$(HDV): $(PROBOOTHD) $(LAUNCHER.SYSTEM) $(PRELAUNCH) $(X) $(TOTAL.DATA) $(TITLE.ANIMATED) $(ICONS) $(FINDER.DATA) $(FINDER.ROOT)
	cp res/blank.hdv "$@"
	cp res/_FileInformation.txt "$(BUILDDIR)"/
	$(CADIUS) ADDFILE "$@" "/$(VOLUME)/" "$(BUILDDIR)"/LAUNCHER.SYSTEM -C >>"$(BUILDDIR)"/log
	cp res/PREFS.CONF "$(BUILDDIR)"/PREFS.CONF
	bin/padto.sh "$(BUILDDIR)"/PREFS.CONF
#
# create _FileInformation.txt files for subdirectories
#
	bin/buildfileinfo.sh res/ICONS "CA" "0000"
	cp src/prelaunch/_FileInformation.txt "$(BUILDDIR)"/PRELAUNCH/
#
# add everything to the disk
#
	for f in \
		$(TOTAL.DATA) \
		"$(BUILDDIR)"/PREFS.CONF \
		$(FINDER.DATA) \
		$(FINDER.ROOT); do \
	    $(CADIUS) ADDFILE "$@" "/$(VOLUME)/" "$$f" -C >>"$(BUILDDIR)"/log; \
	done
	for f in \
		res/TITLE.ANIMATED \
		res/ICONS \
		"$(BUILDDIR)"/PRELAUNCH \
		$(X); do \
            rm -f "$$f"/.DS_Store; \
            $(CADIUS) ADDFOLDER "$@" "/$(VOLUME)/$$(basename $$f)" "$$f" -C >>"$(BUILDDIR)"/log; \
        done
	bin/changebootloader.sh "$@" $(PROBOOTHD)
	@touch "$@"

# create a version of GAMES.CONF without comments or blank lines or anything after display titles
$(GAMES.CONF): $(MD)
	awk '!/^$$|^#/' < res/GAMES.CONF | awk -F'/' '{ print $$1 }' > "$@"

# create a list of all game filenames, without metadata or display names, sorted by game filename
$(GAMES.SORTED): $(GAMES.CONF)
	awk -F, '/,/ { print $$2 }' < "$(GAMES.CONF)" | awk -F= '{ print $$1 }' | sort > "$@"

$(X): $(GAMES.CONF)
	mkdir -p "$@" "$(BUILDDIR)"/X.INDEXED
	$(PARALLEL) '$(CADIUS) EXTRACTVOLUME {} "$@"/ >>"$(BUILDDIR)"/log' ::: res/dsk/*.po
	rm -f "$@"/**/.DS_Store "$@"/**/PRODOS* "$@"/**/LOADER.SYSTEM* "$@"/**/_FileInformation.txt
	for f in $$(grep '^....1' "$(GAMES.CONF)" | awk '!/^$$|^#/' | awk -F, '/,/ { print $$2 }' | awk -F= '{ print $$1 }'); do mv "$@"/"$$(basename $$f)"/"$$(basename $$f)"* "$(BUILDDIR)"/X.INDEXED/; rm -rf "$@"/"$$(basename $$f)"; done
	for d in "$@"/*; do mv "$$d"/* "$@"/; rmdir "$$d"; done
	@touch "$@"

# precompute binary data structure for mega-attract mode configuration file
$(ATTRACT.IDX): $(MD)
	bin/buildokvs.sh < res/ATTRACT.CONF > "$@"

$(HELPTEXT): $(MD)
	bin/converthelp.sh res/HELPTEXT "$@"

$(CREDITS): $(MD)
	bin/converthelp.sh res/CREDITS "$@"

$(GAMEHELP): $(GAMEHELP.SOURCES) | $(MD)
	mkdir -p "$@"
	$(PARALLEL) 'bin/converthelp.sh "{}" "$@/{/}"' ::: res/GAMEHELP/*
	@touch "$@"

$(SS): $(SS.SOURCES) | $(MD)
	mkdir -p "$@"
	$(PARALLEL) '[ $$(echo "{/}" | cut -c-3) = "ACT" ] && bin/buildslideshow.sh -d "$(GAMES.CONF)" < "{}" > "$@/{/}" || bin/buildslideshow.sh "$(GAMES.CONF)" < "{}" > "$@/{/}"' ::: res/SS/*
	@touch "$@"

$(ATTRACT): $(ATTRACT.SOURCES) | $(MD)
	mkdir -p "$@"
	$(PARALLEL) 'bin/buildokvs.sh < "{}" > "$@/{/}"' ::: res/ATTRACT/*
	@touch "$@"

$(TOTAL.DATA): $(FX) $(PRELAUNCH) $(DEMO) $(SS) $(X) $(ATTRACT.IDX) $(HELPTEXT) $(CREDITS) $(GAMEHELP) $(GAMES.CONF) $(GAMES.SORTED) $(ACTION.DGR) $(ACTION.DHGR) $(ACTION.GR) $(ACTION.HGR) $(ARTWORK.SHR) $(ATTRACT) $(TITLE.DHGR) $(TITLE.HGR) $(CACHE.IDX) $(ATTRACT.CONF) $(DFX.CONF) $(FX.CONF) $(SFX.CONF) $(PREFS.CONF) $(COVER) $(DECRUNCH) $(HELP) $(JOYSTICK) $(TITLE)
#
# precompute indexed files for prelaunch
# note: prelaunch must be first in TOTAL.DATA due to a hack in LoadStandardPrelaunch
# note 2: these can not be padded because they are loaded at $0106 and padding would clobber the stack
#
	bin/buildindexedfile.py $(TOTAL.DATA) "$(BUILDDIR)"/PRELAUNCH.INDEXED "" < $(GAMES.SORTED) > "$(BUILDDIR)"/PRELAUNCH.IDX
#
# precompute indexed files for HGR & DHGR titles
# note: these are not padded because they are all an exact block-multiple anyway
#
	bin/padto.sh $(TOTAL.DATA)
	(for f in res/TITLE.HGR/*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a $(TOTAL.DATA) res/TITLE.HGR "$(BUILDDIR)"/HGR.TITLES.LOG > "$(BUILDDIR)"/TITLE.IDX
	(for f in res/TITLE.DHGR/*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a $(TOTAL.DATA) res/TITLE.DHGR "$(BUILDDIR)"/DHGR.TITLES.LOG > "$(BUILDDIR)"/DTITLE.IDX
	bin/addfile.sh "$(COVER)" $(TOTAL.DATA) > src/index/res.cover.idx.a
	bin/addfile.sh "$(TITLE)" $(TOTAL.DATA) > src/index/res.title.idx.a
	bin/addfile.sh "$(HELP)" $(TOTAL.DATA) > src/index/res.help.idx.a
#
# precompute indexed files for game help
# note: these can be padded because they're loaded into $800 at a time when $800..$1FFF is clobber-able
#
	bin/buildindexedfile.py -p -a $(TOTAL.DATA) $(GAMEHELP) "" < $(GAMES.SORTED) > "$(BUILDDIR)"/GAMEHELP.IDX
#
# precompute indexed files for slideshows
# note: these can be padded because they're loaded into $800 at a time when $800..$1FFF is clobber-able
#
	(for f in "$(BUILDDIR)"/SS/*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -p -a $(TOTAL.DATA) "$(BUILDDIR)"/SS "" > "$(BUILDDIR)"/SLIDESHOW.IDX
	(for f in "$(BUILDDIR)"/ATTRACT/[ABCDEFGHIJKLMNOP]*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -p -a $(TOTAL.DATA) "$(BUILDDIR)"/ATTRACT "" > "$(BUILDDIR)"/MINIATTRACT0.IDX
	(for f in "$(BUILDDIR)"/ATTRACT/[QRSTUVWXYZ]*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -p -a $(TOTAL.DATA) "$(BUILDDIR)"/ATTRACT "" > "$(BUILDDIR)"/MINIATTRACT1.IDX
#
# precompute indexed files for graphic effects
# note: these can be padded because they're loaded into $6000 at a time when $6000..$BEFF is clobber-able
#
	bin/buildindexedfile.py -p -a $(TOTAL.DATA) "$(BUILDDIR)"/FX.INDEXED "" < res/FX.CONF > "$(BUILDDIR)"/FX.IDX
	bin/buildindexedfile.py -p -a $(TOTAL.DATA) "$(BUILDDIR)"/FX.INDEXED "" < res/DFX.CONF > "$(BUILDDIR)"/DFX.IDX
	bin/buildindexedfile.py -p -a $(TOTAL.DATA) "$(BUILDDIR)"/FX.INDEXED "" < res/SFX.CONF > "$(BUILDDIR)"/SFX.IDX
	(for f in "$(BUILDDIR)"/FXCODE/*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -p -a $(TOTAL.DATA) "$(BUILDDIR)"/FXCODE "" > "$(BUILDDIR)"/FXCODE.IDX
#
# precompute indexed files for coordinates files loaded by graphic effects
# note: these can not be padded because some of them are loaded into tight spaces near the unclobberable top of main memory
#
	(for f in "$(BUILDDIR)"/FXDATA/*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a $(TOTAL.DATA) "$(BUILDDIR)"/FXDATA "" > "$(BUILDDIR)"/FXDATA.IDX
#
# precompute indexed files for HGR & DHGR action screenshots
# note: these can not be padded because they are compressed and the decompressor needs the exact size
#
	(for f in res/ACTION.HGR/[ABCD]*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a $(TOTAL.DATA) res/ACTION.HGR "" > "$(BUILDDIR)"/HGR0.IDX
	(for f in res/ACTION.HGR/[EFGH]*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a $(TOTAL.DATA) res/ACTION.HGR "" > "$(BUILDDIR)"/HGR1.IDX
	(for f in res/ACTION.HGR/[IJKL]*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a $(TOTAL.DATA) res/ACTION.HGR "" > "$(BUILDDIR)"/HGR2.IDX
	(for f in res/ACTION.HGR/[MNOP]*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a $(TOTAL.DATA) res/ACTION.HGR "" > "$(BUILDDIR)"/HGR3.IDX
	(for f in res/ACTION.HGR/[QRST]*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a $(TOTAL.DATA) res/ACTION.HGR "" > "$(BUILDDIR)"/HGR4.IDX
	(for f in res/ACTION.HGR/[UVWX]*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a $(TOTAL.DATA) res/ACTION.HGR "" > "$(BUILDDIR)"/HGR5.IDX
	(for f in res/ACTION.HGR/[YZ]*;   do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a $(TOTAL.DATA) res/ACTION.HGR "" > "$(BUILDDIR)"/HGR6.IDX
	(for f in res/ACTION.DHGR/*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a $(TOTAL.DATA) res/ACTION.DHGR "" > "$(BUILDDIR)"/DHGR.IDX
#
# precompute indexed files for GR and DGR action screenshots
# note: these can be padded because they are not compressed
#
	(for f in res/ACTION.GR/*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a -p $(TOTAL.DATA) res/ACTION.GR "" > "$(BUILDDIR)"/GR.IDX
	(for f in res/ACTION.DGR/*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a -p $(TOTAL.DATA) res/ACTION.DGR "" > "$(BUILDDIR)"/DGR.IDX
#
# precompute indexed files for SHR artwork
# note: these can not be padded because they are compressed and the decompressor needs the exact size
#
	(for f in res/ARTWORK.SHR/*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a $(TOTAL.DATA) res/ARTWORK.SHR "" > "$(BUILDDIR)"/ARTWORK.IDX
#
# precompute indexed files for demo launchers
# note: these can not be padded because some of them are loaded too close to $C000
#
	(for f in $(DEMO)/*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a $(TOTAL.DATA) $(DEMO) "" > "$(BUILDDIR)"/DEMO.IDX
	bin/addfile.sh "$(BUILDDIR)"/DEMO.IDX $(TOTAL.DATA) > src/index/demo.idx.a

#
# precompute indexed files for single-load game binaries
# note: these can be padded because they are loaded at a time when all of main memory is clobber-able
#
	(for f in "$(BUILDDIR)"/X.INDEXED/*; do echo "$$(basename $$f)"; done) | bin/buildindexedfile.py -a -p $(TOTAL.DATA) "$(BUILDDIR)"/X.INDEXED "" > "$(BUILDDIR)"/XSINGLE.IDX
	bin/addfile.sh "$(BUILDDIR)"/XSINGLE.IDX $(TOTAL.DATA) > src/index/xsingle.idx.a
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
	bin/addfile.sh "$(BUILDDIR)"/SEARCH00.IDX $(TOTAL.DATA) > src/index/search00.idx.a
	bin/addfile.sh res/CACHE00.IDX $(TOTAL.DATA) > src/index/cache00.idx.a
	bin/addfile.sh "$(BUILDDIR)"/SEARCH01.IDX $(TOTAL.DATA) > src/index/search01.idx.a
	bin/addfile.sh res/CACHE01.IDX $(TOTAL.DATA) > src/index/cache01.idx.a
	bin/addfile.sh "$(BUILDDIR)"/SEARCH10.IDX $(TOTAL.DATA) > src/index/search10.idx.a
	bin/addfile.sh res/CACHE10.IDX $(TOTAL.DATA) > src/index/cache10.idx.a
	bin/addfile.sh "$(BUILDDIR)"/SEARCH11.IDX $(TOTAL.DATA) > src/index/search11.idx.a
	bin/addfile.sh res/CACHE11.IDX $(TOTAL.DATA) > src/index/cache11.idx.a
	bin/addfile.sh "$(BUILDDIR)"/PRELAUNCH.IDX $(TOTAL.DATA) > src/index/prelaunch.idx.a
	bin/addfile.sh $(ATTRACT.IDX) $(TOTAL.DATA) > src/index/attract.idx.a
	bin/addfile.sh "$(BUILDDIR)"/FX.IDX $(TOTAL.DATA) > src/index/fx.idx.a
	bin/addfile.sh "$(BUILDDIR)"/DFX.IDX $(TOTAL.DATA) > src/index/dfx.idx.a
	bin/addfile.sh "$(BUILDDIR)"/SFX.IDX $(TOTAL.DATA) > src/index/sfx.idx.a
	bin/addfile.sh "$(BUILDDIR)"/FXCODE.IDX $(TOTAL.DATA) > src/index/fxcode.idx.a
	bin/addfile.sh "$(BUILDDIR)"/FXDATA.IDX $(TOTAL.DATA) > src/index/fxdata.idx.a
	bin/addfile.sh "$(BUILDDIR)"/GAMEHELP.IDX $(TOTAL.DATA) > src/index/gamehelp.idx.a
	bin/addfile.sh "$(BUILDDIR)"/SLIDESHOW.IDX $(TOTAL.DATA) > src/index/slideshow.idx.a
	bin/addfile.sh "$(BUILDDIR)"/MINIATTRACT0.IDX $(TOTAL.DATA) > src/index/miniattract0.idx.a
	bin/addfile.sh "$(BUILDDIR)"/MINIATTRACT1.IDX $(TOTAL.DATA) > src/index/miniattract1.idx.a
	bin/addfile.sh "$(BUILDDIR)"/TITLE.IDX $(TOTAL.DATA) > src/index/title.idx.a
	bin/addfile.sh "$(BUILDDIR)"/DTITLE.IDX $(TOTAL.DATA) > src/index/dtitle.idx.a
	bin/addfile.sh "$(BUILDDIR)"/HGR0.IDX $(TOTAL.DATA) > src/index/hgr0.idx.a
	bin/addfile.sh "$(BUILDDIR)"/HGR1.IDX $(TOTAL.DATA) > src/index/hgr1.idx.a
	bin/addfile.sh "$(BUILDDIR)"/HGR2.IDX $(TOTAL.DATA) > src/index/hgr2.idx.a
	bin/addfile.sh "$(BUILDDIR)"/HGR3.IDX $(TOTAL.DATA) > src/index/hgr3.idx.a
	bin/addfile.sh "$(BUILDDIR)"/HGR4.IDX $(TOTAL.DATA) > src/index/hgr4.idx.a
	bin/addfile.sh "$(BUILDDIR)"/HGR5.IDX $(TOTAL.DATA) > src/index/hgr5.idx.a
	bin/addfile.sh "$(BUILDDIR)"/HGR6.IDX $(TOTAL.DATA) > src/index/hgr6.idx.a
	bin/addfile.sh "$(BUILDDIR)"/DHGR.IDX $(TOTAL.DATA) > src/index/dhgr.idx.a
	bin/addfile.sh "$(BUILDDIR)"/GR.IDX $(TOTAL.DATA) > src/index/gr.idx.a
	bin/addfile.sh "$(BUILDDIR)"/DGR.IDX $(TOTAL.DATA) > src/index/dgr.idx.a
	bin/addfile.sh "$(BUILDDIR)"/ARTWORK.IDX $(TOTAL.DATA) > src/index/artwork.idx.a
#
# add additional miscellaneous files
#
	bin/addfile.sh "$(BUILDDIR)"/COVERFADE $(TOTAL.DATA) > src/index/coverfade.idx.a
	bin/addfile.sh "$(BUILDDIR)"/GR.FIZZLE $(TOTAL.DATA) > src/index/gr.fizzle.idx.a
	bin/addfile.sh "$(BUILDDIR)"/DGR.FIZZLE $(TOTAL.DATA) > src/index/dgr.fizzle.idx.a
	bin/addfile.sh "$(BUILDDIR)"/HELPTEXT $(TOTAL.DATA) > src/index/helptext.idx.a
	bin/addfile.sh "$(BUILDDIR)"/CREDITS $(TOTAL.DATA) > src/index/credits.idx.a
	bin/addfile.sh res/DECRUNCH $(TOTAL.DATA) > src/index/decrunch.idx.a
	bin/addfile.sh res/JOYSTICK $(TOTAL.DATA) > src/index/joystick.idx.a
	@touch "$@"

$(LAUNCHER.SYSTEM): $(LAUNCHER.SOURCES) | $(MD)
	$(ACME) -DBUILDNUMBER=`git rev-list --count HEAD` src/4cade.a 2>"$(BUILDDIR)"/relbase.log
	$(ACME) -r "$(BUILDDIR)"/4cade.lst -DBUILDNUMBER=`git rev-list --count HEAD` -DRELBASE=`cat "$(BUILDDIR)"/relbase.log | grep "RELBASE =" | cut -d"=" -f2 | cut -d"(" -f2 | cut -d")" -f1` src/4cade.a
	@touch "$@"

$(DEMO): $(DEMO.SOURCES) | $(MD)
	mkdir -p "$@"
	$(PARALLEL) 'if grep -q "^!to" "{}"; then $(ACME) "{}"; fi' ::: src/demo/*.a
	@touch "$@"

$(FX): $(FX.SOURCES) | $(MD)
	mkdir -p "$@" "$(BUILDDIR)"/FX.INDEXED "$(BUILDDIR)"/FXDATA "$(BUILDDIR)"/FXCODE
	$(PARALLEL) 'if grep -q "^!to" "{}"; then $(ACME) "{}"; fi' ::: src/fx/*.a
	@touch "$@"

$(PRELAUNCH): $(PRELAUNCH.SOURCES) | $(MD)
	mkdir -p "$@" "$(BUILDDIR)"/PRELAUNCH.INDEXED
	$(PARALLEL) 'if grep -q "^!to" "{}"; then $(ACME) "{}"; fi' ::: src/prelaunch/*.a
	@touch "$@"

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
