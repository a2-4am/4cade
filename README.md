# Is this page for you?

[Download the latest Total Replay disk image](https://archive.org/details/TotalReplay) at the archive.org home page if you just want to play hundreds of Apple II games. The rest of this page is for developers who want to work with the source code and assemble it themselves.

# Building the code

## Mac OS X

You will need
 - [Xcode command line tools](https://www.google.com/search?q=xcode+command+line+tools)
 - [ACME](https://sourceforge.net/projects/acme-crossass/)
 - [sicklittlemonkey's Cadius fork](https://github.com/sicklittlemonkey/cadius)
 - [Exomizer](https://bitbucket.org/magli143/exomizer/wiki/Home)

Then open a terminal window and type

```
$ cd 4cade/
$ make
```

If all goes well, the `build/` subdirectory will contain a `4cade.hdv` image which can be mounted in emulators like [OpenEmulator](https://archive.org/details/OpenEmulatorSnapshots) or [Virtual II](http://virtualii.com/).

## Windows

You will need
 - [ACME](https://sourceforge.net/projects/acme-crossass/)
 - [Cadius for Windows](https://www.brutaldeluxe.fr/products/crossdevtools/cadius/)
 - [Exomizer](https://bitbucket.org/magli143/exomizer/wiki/Home)

(Those tools will need to be added to your command-line PATH.)

Then open a `CMD.EXE` window and type

```
C:\> CD 4CADE
C:\4cade> WINMAKE
```
If all goes well, the `BUILD\` subdirectory will contain a `4CADE.HDV` image which can be mounted in emulators like [AppleWin](https://github.com/AppleWin/AppleWin).

# Navigating the code

## Initialization

[`4cade.a`](https://github.com/a2-4am/4cade/blob/master/src/4cade.a) is the main assembler target. It builds the launcher itself. Launcher code is split into code that can be run once from main memory then discarded, and code which is relocated to the language card and persists throughout the lifetime of the launcher. As the language card is only 16KB and will also need to store some persistent data structures, memory is precious and tightly managed.

[`4cade.init.a`](https://github.com/a2-4am/4cade/blob/master/src/4cade.init.a) contains the code that is run once at program startup. First, we do some hardware detection, like how much memory you have, whether you have a joystick, and whether you have a IIgs. Then we relocate selected code to the language card. [`constants.a`](https://github.com/a2-4am/4cade/blob/master/src/constants.a) has a rough map of what ends up where, within the language card and its overlapping memory regions. Then we load and parse the global preferences file ([`PREFS.CONF`](https://github.com/a2-4am/4cade/blob/master/res/prefs.conf)) and master game list ([`GAMES.CONF`](https://github.com/a2-4am/4cade/blob/master/res/games.conf)) and store the results in the language card. Finally, we jump to the main entry point (`Reenter`). The launcher is initialized; anything left in main memory is discarded.

## Search mode

There are three major modes in the launcher: search mode, browse mode, and mega-attract mode. Search mode is the default, and it is always the first mode you enter when launching the program. [`ui.search.mode.a`](https://github.com/a2-4am/4cade/blob/master/src/ui.search.mode.a) tracks your keystrokes to determine the best match within the game list for the keys you have typed, then loads the game's title screenshot and displays the game name and other information at the bottom of the screen. If you have not yet typed any keys, it displays the title page and welcome message instead. The `InputKeys` table documents all other recognized keys.

The text ranking algorithm is in [`textrank.a`](https://github.com/a2-4am/4cade/blob/master/src/textrank.a). It was inspired by [Quicksilver](https://github.com/quicksilver/Quicksilver) but is an independent implementation.

## Browse mode

The user enters browse mode by pressing the right or down arrow key. [`ui.browse.mode.a`](https://github.com/a2-4am/4cade/blob/master/src/ui.browse.mode.a) then watches for other arrow keys and displays the next or previous game in the game list. The `BrowseKeys` table documents all other recognized keys.

## Mega-Attract mode

If the user presses `Esc` from any other mode, or does not type anything for 30 seconds, the launcher goes into Mega-Attract mode, a.k.a. screensaver mode. [`ui.attract.mode.a`](https://github.com/a2-4am/4cade/blob/master/src/ui.attract.mode.a) manages loading and executing attract mode modules. An attract mode module can be a short slideshow, a self-running demo, or just a single screenshot. Modules are listed in [`ATTRACT.CONF`](https://github.com/a2-4am/4cade/blob/master/res/attract.conf) and are run in order until end-of-file, then it starts over from the beginning. The entire cycle is quite long (several hours), and some screenshots appear in multiple slideshows, but there is no actual randomness in selecting the next attract mode module.

# Navigating the configuration files

## `GAMES.CONF`

[`GAMES.CONF`](https://github.com/a2-4am/4cade/blob/master/res/GAMES.CONF) is the master games list. It contains 1 record for every game in Total Replay. However, not every game is playable on every device, so each record also contains metadata, e.g. "this game requires a joystick," or "this game requires 128K," or "this game has a double hi-res title screen" (which is not identical to "this game requires 128K").

The format of the `GAMES.CONF` file has changed as new requirements have appeared, and it may change again in the future. There is up-to-date format information at the bottom of the file itself, which I will not duplicate here. However, in general, each record is 1 line and contains the name and flags for 1 game. The file is parsed once at program startup, and the (possibly filtered) list of available games is stored persistently in the language card.

Many records in `GAMES.CONF` do not list the game's display name, i.e. the mixed-case, human-readable name displayed in search mode, browse mode, and slideshows. Wherever possible, display names are calculated from a game's filename, so `WAVY.NAVY` is displayed as `Wavy Navy`, while `SUMMER.GAMES.II` is displayed as `Summer Games II`, and so on.

Each game's filename is used as a "foreign key" (in database terms) to build directory paths, to locate files in subdirectories, and to reference the game in other configuration files.

- A game's main executable is always `X/FILENAME/FILENAME`
- A game's HGR title screenshot is always `TITLE.HGR/FILENAME`
- A game's super hi-res box art is always `ARTWORk.SHR/FILENAME`
- A game's mini-attract mode configuration file is always `ATTRACT/FILENAME`
- Games are included in other attract mode configuration files by `FILENAME`
- The source disk image of a game (in [`res/dsk`](https://github.com/a2-4am/4cade/tree/master/res/dsk)) must have a volume name of `FILENAME`, and there must be a file in the disk image's root directory also named `FILENAME` which is the game's main executable

## `ATTRACT.CONF`

TODO

## `FX.CONF`, `DFX.CONF`

[`FX.CONF`](https://github.com/a2-4am/4cade/blob/master/res/FX.CONF) and its sister [`DFX.CONF`](https://github.com/a2-4am/4cade/blob/master/res/DFX.CONF) list the HGR and DHGR transition effects used in hi-res and double hi-res slideshows. Each record is a filename of a transition effect file, which is an executable file [assembled at build time](https://github.com/a2-4am/4cade/tree/master/src/fx) and stored in the `FX/` subdirectory. At the beginning of each slideshow, we query the global preferences to find the filename of the FX or DFX file, then update the global preferences with the next filename (wrapping around to the beginning of the list). If you watch the Mega-Attract mode long enough, you will eventually see all the transition effects, and since the cycle of transition effects is separate from the cycle of slideshows, you will eventually see the same slideshow with different transition effects.

These files are read from disk and parsed every time they are needed. Due to memory restrictions, the parsed data is not persisted.

## `PREFS.CONF`

[`PREFS.CONF`](https://github.com/a2-4am/4cade/blob/master/res/PREFS.CONF) contains persistent global state, including Mega-Attract mode state and whether cheats are enabled. There is up-to-date format information in the file itself.

This file is read and parsed once at program startup, and the parsed data is stored persistently in the language card. It is written to disk every time global state changes, which is often during Mega-Attract mode, or if the user toggles cheat mode.
