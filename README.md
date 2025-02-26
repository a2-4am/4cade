# Is this page for you?

[Download the latest Total Replay disk image](https://archive.org/details/TotalReplay) at the archive.org home page if you just want to play hundreds of Apple II games. The rest of this page is for developers who want to work with the source code and assemble it themselves.

# Building the code

## Mac OS X

You will need
 - [Xcode command line tools](https://developer.apple.com/library/archive/technotes/tn2339/_index.html)
 - [ACME](https://sourceforge.net/projects/acme-crossass/)
 - [Parallel](https://www.gnu.org/software/parallel/)
 - [Cadius](https://github.com/mach-kernel/cadius)
 - [Exomizer](https://bitbucket.org/magli143/exomizer/wiki/Home)

As of this writing, all of the non-Xcode programs are installable via [Homebrew](https://brew.sh/).

``` shell
$ brew tap lifepillar/appleii
$ brew install acme parallel mach-kernel-cadius exomizer
```

Then open a terminal window and type

``` shell
$ cd 4cade/
$ make
```

If all goes well, the `build/` subdirectory will contain a `4cade.hdv` image which can be mounted in emulators like [OpenEmulator](https://archive.org/details/OpenEmulatorSnapshots), [Ample](https://github.com/ksherlock/ample), or [Virtual II](http://virtualii.com/).

If all does not go well, try doing a clean build (`makeg clean && make`)

If that fails, perhaps you have out-of-date versions of one of the required tools? The [Makefile](https://github.com/a2-4am/4cade/blob/main/Makefile) lists, but does not enforce, the minimum version requirements of each third-party tool.

If that fails, please [file a bug](https://github.com/a2-4am/4cade/issues/new).

## Windows

You will need
 - [ACME](https://sourceforge.net/projects/acme-crossass/)
 - [Cadius for Windows](https://github.com/mach-kernel/cadius)
 - [Exomizer](https://bitbucket.org/magli143/exomizer/wiki/Home)

(Those tools will need to be added to your command-line PATH.)

Then open a `CMD.EXE` window and type

```
C:\> cd 4cade
C:\4cade> winmake dsk
```
If all goes well, the `build\` subdirectory will contain a `4cade.hdv` image which can be mounted in emulators like [AppleWin](https://github.com/AppleWin/AppleWin) or [MAME](http://www.mamedev.org).

If all does not go well, try doing a clean build (`winmake clean`, `winmake dsk`)

If that fails, perhaps you have out-of-date versions of one of the required tools? The [winmake](https://github.com/a2-4am/4cade/blob/main/winmake.bat) lists, but does not enforce, the minimum version requirements of each third-party tool.

If that fails, please [file a bug](https://github.com/a2-4am/4cade/issues/new).

## Linux

You will need
 - [Cadius](https://github.com/mach-kernel/cadius)
 - [Exomizer](https://bitbucket.org/magli143/exomizer/wiki/Home)

Most of the packages are already available pre-compiled and can be installed with the following

``` shell
$ sudo apt-get install git parallel acme
```

To compile Cadius enter the following

``` shell
$ git clone https://github.com/mach-kernel/cadius.git
$ cd cadius
$ make
$ cd bin/release
$ sudo cp cadius /usr/bin
```

Then open a terminal window and type

``` shell
$ git clone https://github.com/a2-4am/4cade.git
$ cd 4cade/
$ make
```

If all goes well, the `build/` subdirectory will contain a `4cade.hdv` image which can be mounted in emulators like [MAME](http://www.mamedev.org).

If all does not go well, try doing a clean build (`make clean && make`)

If that fails, perhaps you have out-of-date versions of one of the required tools? The [Makefile](https://github.com/a2-4am/4cade/blob/main/Makefile) lists, but does not enforce, the minimum version requirements of each third-party tool.

If that fails, please [file a bug](https://github.com/a2-4am/4cade/issues/new).

# Navigating the code

## Initialization

[`4cade.a`](https://github.com/a2-4am/4cade/blob/main/src/4cade.a) is the main assembler target. It builds the launcher itself. Launcher code is split into code that can be run once from main memory then discarded, and code which is relocated to the language card and persists throughout the lifetime of the launcher. As the language card is only 16KB and will also need to store some persistent data structures, memory is precious and tightly managed.

[`4cade.init.a`](https://github.com/a2-4am/4cade/blob/main/src/4cade.init.a) contains the code that is run once at program startup. First, we do some hardware detection, like how much memory you have, whether you have a joystick, and whether you have a IIgs. Then we relocate selected code to the language card and load the appropriate search index. (For example, if you do not have a joystick, games that require a joystick will not appear in search results.) [`constants.a`](https://github.com/a2-4am/4cade/blob/main/src/constants.a) has a rough map of what ends up where, within the language card and its overlapping memory regions. Then we load and parse the global preferences file ([`PREFS.CONF`](https://github.com/a2-4am/4cade/blob/main/res/prefs.conf)) and store the results in the language card. Finally, we jump to the main entry point (`Reenter`). The launcher is initialized; anything left in main memory is discarded.

## Search mode

There are three major modes in the launcher: search mode, browse mode, and mega-attract mode. Search mode is the default, and it is always the first mode you enter when launching the program. [`ui.search.mode.a`](https://github.com/a2-4am/4cade/blob/main/src/ui.search.mode.a) tracks your keystrokes to determine the best match within the game list for the keys you have typed, then loads the game's title screenshot and displays the game name and other information at the bottom of the screen. If you have not yet typed any keys, it displays the title page and welcome message instead. The `InputKeys` table documents all other recognized keys.

The text ranking algorithm is in [`textrank.a`](https://github.com/a2-4am/4cade/blob/main/src/textrank.a). It was inspired by [Quicksilver](https://github.com/quicksilver/Quicksilver) but is an independent implementation.

## Browse mode

The user enters browse mode by pressing the right or down arrow key. [`ui.browse.mode.a`](https://github.com/a2-4am/4cade/blob/main/src/ui.browse.mode.a) then watches for other arrow keys and displays the next or previous game in the game list. The `BrowseKeys` table documents all other recognized keys.

## Mega-Attract mode

If the user presses `Esc` from any other mode, or does not type anything for 30 seconds, the launcher goes into Mega-Attract mode, a.k.a. screensaver mode. [`ui.attract.mode.a`](https://github.com/a2-4am/4cade/blob/main/src/ui.attract.mode.a) manages loading and executing attract mode modules. An attract mode module can be a short slideshow, a self-running demo, or just a single screenshot. Modules are listed in [`ATTRACT.CONF`](https://github.com/a2-4am/4cade/blob/main/res/attract.conf) and are run in order until end-of-file, then it starts over from the beginning. The entire cycle is quite long (several hours), and some screenshots appear in multiple slideshows, but there is no actual randomness in selecting the next attract mode module.

# Navigating the configuration files

## `GAMES.CONF`

[`GAMES.CONF`](https://github.com/a2-4am/4cade/blob/main/res/GAMES.CONF) is the master games list. It contains 1 record for every game in Total Replay. However, not every game is playable on every device, so each record also contains metadata, e.g. "this game requires a joystick," or "this game requires 128K," or "this game has a double hi-res title screen" (which is not identical to "this game requires 128K").

The format of the `GAMES.CONF` file has changed as new requirements have appeared, and it may change again in the future. There is up-to-date format information in comments in the file itself, which I will not duplicate here. However, in general, each record is 1 line and contains the name and flags for 1 game. The file is parsed during build and used to create the search indexes and other files which are stored on the final disk image.

Each game's filename is used as a "foreign key" (in database terms) to build directory paths, to locate files in subdirectories, and to reference the game in other configuration files.

- A game's HGR title screenshot is always `TITLE.HGR/FILENAME`
- A game's super hi-res box art is always `ARTWORK.SHR/FILENAME` (not all games have artwork)
- A games's help page is always `GAMEHELP/FILENAME` (not all games have help)
- A game's mini-attract mode configuration file is always `ATTRACT/FILENAME`
- Games are included in other attract mode configuration files by `FILENAME`
- The source disk image of a game (in [`res/dsk`](https://github.com/a2-4am/4cade/tree/main/res/dsk)) must have a volume name of `FILENAME`, and there must be a file in the disk image's root directory also named `FILENAME` which is the game's main executable

## `ATTRACT.CONF`

[`ATTRACT.CONF`](https://github.com/a2-4am/4cade/blob/main/res/ATTRACT.CONF) is the master configuration file for Mega-Attract mode. There is up-to-date format information in comments in the file itself, which I will not duplicate here. In general, each record is the name of an attract module, which can be a slideshow, self-running demo, or even a single screenshot. Each attract module corresponds to a file in a separate directory; see format information for details. So the record `FAVORITES2.CONF=1` corresponds to [`a real file`](https://github.com/a2-4am/4cade/blob/main/res/SS/FAVORITES2.CONF) that contains details about that particular hi-res slideshow. `ATTRACT.CONF` and the linked slideshow configuration files are parsed at build time and stored in a custom format on the final disk image.

Attract modules are loosely divided into sets that have a loosely similar mix of hi-res, double hi-res, super hi-res, and self-running demos. The `ATTRACT.CONF` file is maintained by hand and changes frequently as we add games, split up slideshows, or reorder things on a whim.

Since everything is so loosely associated by filename, it is easy to end up with attract modules that aren't listed in `ATTRACT.CONF` (will use disk space but never run), duplicate modules (will loop incorrectly), or modules that refer to non-existent files (will crash and burn). If you make any changes to `ATTRACT.CONF` or any of the files that it references, or any of the files that those files reference, or even sneeze in their general direction, you should run the attract mode consistency check:

``` shell
$ cd 4cade/
$ make attract
```

## `FX.CONF`, `DFX.CONF`

[`FX.CONF`](https://github.com/a2-4am/4cade/blob/main/res/FX.CONF) and its sister [`DFX.CONF`](https://github.com/a2-4am/4cade/blob/main/res/DFX.CONF) list the HGR and DHGR transition effects used in hi-res and double hi-res slideshows. Each record is a filename of a transition effect file, which is an executable file [assembled at build time](https://github.com/a2-4am/4cade/tree/main/src/fx) and stored on final disk image in a custom format. At the beginning of each slideshow, we query the global preferences to find the filename of the FX or DFX file, then update the global preferences with the next filename (wrapping around to the beginning of the list). If you watch the Mega-Attract mode long enough, you will eventually see all the transition effects, and since the cycle of transition effects is separate from the cycle of slideshows, you will eventually see the same slideshow with different transition effects.

These files are parsed at build time and stored on the final disk image in a binary format, then read from disk every time they are needed. Due to memory restrictions, the parsed data is not persisted.

## `PREFS.CONF`

[`PREFS.CONF`](https://github.com/a2-4am/4cade/blob/main/res/PREFS.CONF) contains persistent global state, including Mega-Attract mode state and whether cheats are enabled. There is up-to-date format information in comments in the file itself.

This file is read and parsed once at program startup, and the parsed data is stored persistently in the language card. It is written to disk every time global state changes, which is often during Mega-Attract mode, or if the user toggles cheat mode.

# Compression

Many graphic files in Total Replay are stored in a compressed format, then decompressed at run-time. The compression and decompression is handled by [Exomizer](https://bitbucket.org/magli143/exomizer/wiki/Home), which targets 8-bit platforms. Compressed files include

- [hi-res action screenshots](https://github.com/a2-4am/4cade/tree/main/res/ACTION.HGR)
- [double hi-res action screenshots](https://github.com/a2-4am/4cade/tree/main/res/ACTION.DHGR)
- [super hi-res box art](https://github.com/a2-4am/4cade/tree/main/res/ARTWORK.SHR)

To add a new compressed graphic file, add the uncompressed original file to the appropriate directory ([`ACTION.HGR.UNCOMPRESSED`](https://github.com/a2-4am/4cade/tree/main/res/ACTION.HGR.UNCOMPRESSED), [`ACTION.DHGR.UNCOMPRESSED`](https://github.com/a2-4am/4cade/tree/main/res/ACTION.DHGR.UNCOMPRESSED), or [`ARTWORK.SHR.UNCOMPRESSED`](https://github.com/a2-4am/4cade/tree/main/res/ARTWORK.SHR.UNCOMPRESSED) respectively), then run

``` shell
$ cd 4cade/
$ make compress
```

Then add and commit the compressed files to the repository.
