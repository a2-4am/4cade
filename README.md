# Is this page for you?

[Download the latest Total Replay disk image](https://archive.org/details/TotalReplay) at the archive.org home page if you just want to play hundreds of Apple II games. The rest of this page is for developers who want to work with the source code and assemble it themselves.

# Building the code

## Mac OS X

You will need
 - [Xcode command line tools](https://www.google.com/search?q=xcode+command+line+tools)
 - [ACME](https://sourceforge.net/projects/acme-crossass/)
 - [sicklittlemonkey's Cadius fork](https://github.com/sicklittlemonkey/cadius)
 - [Python 3](https://www.python.org)

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

## Navigating the code

