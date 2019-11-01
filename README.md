# Is this page for you?

[Download the latest Total Replay disk image](https://archive.org/details/TotalReplay) at the archive.org home page if you just want to play hundreds of Apple II games. The rest of this page is for developers who want to work with the source code and assemble it themselves.

# Building the code

## Mac OS X

You will need
 - [Xcode command line tools](https://www.google.com/search?q=xcode+command+line+tools)
 - [ACME](https://sourceforge.net/projects/acme-crossass/)
 - [sicklittlemonkey's Cadius fork](https://github.com/sicklittlemonkey/cadius)

Then open a terminal window and type

```
$ cd 4cade/
$ make
```

If all goes well, the `build/` subdirectory will contain a `4cade.2mg` image which can be mounted in emulators like [OpenEmulator](https://archive.org/details/OpenEmulatorSnapshots) or [Virtual II](http://virtualii.com/).

## Windows

You will need
 - [ACME](https://sourceforge.net/projects/acme-crossass/)
 - [Cadius for Windows](https://www.brutaldeluxe.fr/products/crossdevtools/cadius/)

(Those tools will need to be added to your command-line PATH.)

Then open a `CMD.EXE` window and type

```
C:\> CD 4CADE
C:\4cade> WINMAKE
```
If all goes well, the `BUILD\` subdirectory will contain a `4CADE.2MG` image which can be mounted in emulators like [AppleWin](https://github.com/AppleWin/AppleWin).

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

If the user presses <Esc> from any other mode, or does not type anything for 30 seconds, the launcher goes into Mega-Attract mode, a.k.a. screensaver mode. [`ui.attract.mode.a`](https://github.com/a2-4am/4cade/blob/master/src/ui.attract.mode.a) manages loading and executing attract mode modules. An attract mode module can be a short slideshow, a self-running demo, or just a single screenshot. Modules are listed in [`ATTRACT.CONF`](https://github.com/a2-4am/4cade/blob/master/res/attract.conf) and are run in order until end-of-file, then it starts over from the beginning. The entire cycle is quite long (several hours), and some screenshots appear in multiple slideshows, but there is no actual randomness in selecting the next attract mode module.
