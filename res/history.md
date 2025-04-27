# Total Replay changelog

## Revision 5.3 / unreleased

### Games added in v5.3

- Crossbow
- Deathbounce
- Electroarena
- Glider
- Helicopter Rescue
- Kaboom!
- Mieyen
- Shoot Out
- Spud and Mug Shot

### Games removed in v5.3 (moved to [Total Replay II: Instant Replay](https://github.com/a2-4am/4sports))

- Bejeweled
- Video Vegas

### Enhancements & bug fixes in v5.3

- Show game's super hi-res artwork on launch (on Apple IIgs or other supported hardware)
- Remove visible instructions from title screens shown in search and browse modes, to reduce confusion before game launch (e.g. Mario Bros title says "Press space to start" but that's not true until you launch it). Actual in-game title screens are not affected by this change. Thanks Andrew R. for the idea.
- Fix crash in Black Magic on Apple //c+ (closes [633](https://github.com/a2-4am/4cade/issues/633))
- Fix crash in Hyper Head On on Apple IIgs (closes [667](https://github.com/a2-4am/4cade/issues/667))
- Fix quit option in Angry Birds (closes [636](https://github.com/a2-4am/4cade/issues/636))
- Fix uninitialized value in Apple Cider Spider and its self-running demo
- Swap buttons by default in Lode Runner and Championship Lode Runner (closes [663](https://github.com/a2-4am/4cade/issues/663))
- Improve joystick handling in Frogger II (closes [658](https://github.com/a2-4am/4cade/issues/658))
- Fix Mockingboard issues in Willy Byte (closes [665](https://github.com/a2-4am/4cade/issues/665), [666](https://github.com/a2-4am/4cade/issues/666))
- Properly reset Mockingboard speech chip on Ctrl-Reset (closes [660](https://github.com/a2-4am/4cade/issues/660))
- Improve Mockingboard speech detection algorithm (closes [661](https://github.com/a2-4am/4cade/issues/661))
- Improve Mockingboard mono/stereo detection
- Remove false positive on A2FPGA which made it look like it supported Mockingboard speech even though it doesn't (closes [664](https://github.com/a2-4am/4cade/issues/664))
- Reduce color fringing, especially visible on game help pages (PR [645](https://github.com/a2-4am/4cade/pull/645), thanks xotmatrix)
- Mark Mapple and Crime Wave as having in-game cheats
- Remove debugging code from Mapple
- Improve compatibility on machines running ROMx custom ROM and booting from BOOTi mass storage device
- Add more game help (thanks Brendan R., Andrew R., cybernesto)
- Add more box art (thanks Alex R., Andrew R., Lunar, Ernst Krogtoft)

## Revision 5.2 / serial number 20240909

### Games added in v5.2

- Aeronaut
- AntiAir
- Colorix
- Ether Quest
- Fido
- Hopman
- Millennium Leaper
- Mutant (Steve Waldo)
- Osotos
- Panic Button
- Pick 'n' Pile
- Run For The Money
- SnakeBYTE Remix
- The Rocky Horror Show
- Tron
- Yewdow

### Demos added in v5.2

- Creepy Corridors
- Minit Man
- Pentapus
- Pollywog
- Star Maze
- Tharolian Tunnels

### Enhancements & bug fixes in v5.2

- Press asterisk to select a random game (closes [226](https://github.com/a2-4am/4cade/issues/226))
- Update Pollywog to release version
- Fix launch issues in Angry Birds, Mazeblox, Pegasus II, Spy Hunter, Super Zaxxon, The Space Ark (issues [567](https://github.com/a2-4am/4cade/issues/567), [568](https://github.com/a2-4am/4cade/issues/568), [565](https://github.com/a2-4am/4cade/issues/565), [572](https://github.com/a2-4am/4cade/issues/572))
- Fix reset issues in Agent USA, Death Sword, Impossible Mission II, Lethal Labyrinth, Pegasus II, Rescue Raiders, Starglider, Time Pilot (issues [577](https://github.com/a2-4am/4cade/issues/577), [575](https://github.com/a2-4am/4cade/issues/575), [579](https://github.com/a2-4am/4cade/issues/579), [582](https://github.com/a2-4am/4cade/issues/582), [584](https://github.com/a2-4am/4cade/issues/584), [569](https://github.com/a2-4am/4cade/issues/569), [570](https://github.com/a2-4am/4cade/issues/570))
- Properly restore language card reset and IRQ vectors on re-entry (fixes multiple long-standing issues, including reset issues in Bejeweled)
- Properly reset zero page and stack after some 128K games that use the ones in auxiliary memory
- Fix keyboard handling in Red Alert (issue [617](https://github.com/a2-4am/4cade/issues/617)) and Wings of Fury (issue [564](https://github.com/a2-4am/4cade/issues/564), thanks xotmatrix)
- Fix compatibility issue in H.E.R.O which assumed that a card in slot 4 of a //c must be a mouse
- Fix latent floppy drive access in Axis Assassin, Ballblazer, Force 7, Galactic Attack, Roadblock, Situation Critical, Spellweilder (issues [618](https://github.com/a2-4am/4cade/issues/618), [578](https://github.com/a2-4am/4cade/issues/578), [585](https://github.com/a2-4am/4cade/issues/585), [586](https://github.com/a2-4am/4cade/issues/586), [587](https://github.com/a2-4am/4cade/issues/587))
- Rename "A City Dies" to "Night Falls" to match original packaging
- Add more game help

## Revision 5.1 / serial number 20240216

### Games added in v5.1

- Angry Birds
- Applz

### Enhancements & bug fixes in v5.1

- Upgrade Aztec to retail version
- Fix crash in Serpentine ([issue 559](https://github.com/a2-4am/4cade/issues/559), thanks audetto)
- Fix reset issues in Battle Cruiser
- Fix Mockingboard issues in Berzap, Crime Wave, Mapple
- Fix compatibility issues in Deathsword ([issue 556](https://github.com/a2-4am/4cade/issues/556), thanks JDW1)
- Fix compatibility issues in Flapple Bird
- Fix text display issues during boot

## Revision 5.0.1 / serial number 20231113

- Fix display issue after quitting DGR games ([PR 549](https://github.com/a2-4am/4cade/pull/549), thanks Tom G.)
- Fix off-by-1 bug in several transition effects ([issue 553](https://github.com/a2-4am/4cade/issues/553), thanks xotmatrix)
- Mark Galaxian as requiring a joystick, which it does

## Revision 5 / serial number 20230517

### Games added in v5

- A City Dies Whenever Night Falls
- Aerial
- Alf: The First Adventure
- Alien Lander
- Angel-1
- Ape Escape
- Apple Invader
- Apple Zap
- Apple-Oids
- Arena
- Artesians
- Ascend
- Bats in the Belfry
- Battlot
- Beach Landing
- Bezare
- Bezoff
- Blitzkrieg
- Bloodsuckers
- Bongo's Bash
- Bootskell
- Boulder Dash II
- Bubble Head
- Bug Battle
- ButcherBob '86
- C'est La Vie
- Cacorm
- California Raisins
- Captain Power
- Catacombs
- Cavern Creatures
- Cavit
- Chip Out
- Chivalry
- Chrono Warrior
- Collect
- Conquering Worlds
- Cosmic Combat
- Cracky
- Creepy Corridors
- Crickateer
- Cross City
- Cyclotron
- Dangerous Dave Goes Nutz
- Dangerous Dave Returns
- Dawn Treader
- Deep Space
- Defender (Joe Holt)
- Demonic Decks
- Depth Charge
- Dragonfire
- Early Bird
- Escape
- Federation
- Fire and Ice
- Firebug
- Flak
- Flobynoid
- Floppy
- Fly Wars
- Gadgetz
- Galactic Attack
- Game Boy Tetris
- Gemini
- Glutton
- Grapple
- Guntus
- Handy Dandy
- Hardhat
- Hellstorm
- Impetus
- Infiltrator
- Infiltrator 2
- Invasion Force
- It's The Pits
- J-Bird
- Jellyfish
- Jouster
- Jovian Attack
- Jump Jet
- Lamb Chops!
- Lemmings (Sirius)
- Lemmings (deater's demake)
- Lethal Labyrinth
- Lift
- Little Brick Out
- Lunar Explorer
- Lunar Leepers
- M.I.R.V
- Mapple
- Marauder
- Mazeblox
- Mazy
- Mine Sweep
- Mouskattack
- Mutant
- Narnia
- Neon
- Neuras
- Neut Tower
- Neutrons
- Night Crawler
- Oil's Well
- Paipec
- Peeping Tom
- Pegasus ][
- Pengo
- People Pong
- Pig Pen
- Pill Box
- Planet Protector
- Planetoids
- Puyo Puyo
- Quasar
- Raiders of the Lost Ring
- Rainbow Zone
- Rear Guard
- Retro Fever
- Retro-Ball
- Roach Hotel
- Robot Battle
- Robotics
- Ruptus
- Sabotage II
- Sadar's Revenge
- Sanitron
- Sheila
- Shooting Gallery
- Shuttle Intercept
- Sigma Seven
- Smooth Max
- Space Kadet
- Space Race
- Space Rescue
- Space Spikes
- Space Warrior
- Spellwielder
- Sputnik Attack
- Spy vs Spy
- Spy vs Spy II
- Spy vs Spy III
- Star Avenger
- Star Clones
- Star Dance
- Star Maze
- Starball
- Starmines
- Super Puckman
- Super Taxman 2
- Sword of Sheol
- Syzygy
- Talon
- Teleport
- Teritory
- The Caverns of Freitag
- The Chase on Tom Sawyer's Island
- The Human Fly
- The Movie Monster Game
- The Snapper
- The Space Ark
- The Voyage of the Valkyrie
- Thunderbird GX
- Time Pilot
- Time Tunnels
- Titan Cronus
- Torax
- Torpedo Terror
- Track Attack
- Treasure Dive
- Trolls and Tribulations
- Trompers
- Tsunami
- Video Vegas
- Viper Patrol
- Vortex
- Wall Defence
- Wargle
- Whomper Stomper
- Willy Byte in the Digital Dimension
- Zero Gravity Pinball
- Zoo Master

### Games removed in v5 (moved to [Total Replay II: Instant Replay](https://github.com/a2-4am/4sports))

- 8-bit Slicks
- Battle Chess
- Bop'n Wrestle
- California Games
- Fight Night
- Flight Simulator II
- Formula 1 Racer
- Fuji Crowded Speedway
- Hardball
- International Gran Prix
- Karate Champ
- One on One
- Pitstop II
- Shuffleboard
- Ski Crazed
- Solo Flight
- Speedway Classic
- Street Sports Baseball
- Street Sports Basketball
- Street Sports Football
- Street Sports Soccer
- Summer Games
- Summer Games II
- Tag Team Wrestling
- Test Drive
- The Dam Busters
- The Games: Summer Edition
- The Games: Winter Edition
- Tomahawk
- Track & Field
- Winter Games
- World Games
- World Karate Championship

### Enhancements & bug fixes in v5

- Upgrade Bejeweled to v2.7 (thanks Jeremy R.)
- Upgrade Columns (thanks Tom G.)
- Upgrade Genius 1 and 2 to r18
- Upgrade Manic Miner to v1.1
- Fix Mockingboard issues in 8-Bit Slicks, Apple Cider Spider, Bouncing
  Kamungas, Rescue Raiders, Skyfox, Thunder Bombs
- Display "mono" or "stereo" on start if a Mockingboard was detected
- Add more game help (thanks Andrew R.)
- Add even more super hi-res artwork for IIgs users (thanks Alex L., Frank M.,
  Brian Wiser, mr_breaddoughrising, Antoine V., Andrew R., Tony D., cosmoza,
  A2Canada, John K M)
- Better-looking SHR graphics thanks to a new conversion tool by Kris Kennaway
- Retries on read for better compatibility with network-backed mass storage
  devices
- Faster searching
- Faster browsing
- Faster booting
- Faster everything, really

## Revision 4.01 / serial number 20210218

### Bug fixes in v4.01

- Fix screensaver looping so all modules display in the proper order

## Revision 4 / serial number 20210212

### Games added in v4

- 8bit-Slicks
- A.E.
- Aliens
- Arcade Boot Camp
- Archon
- Archon II
- Arctic Fox
- Ardy the Aardvark
- Bandits
- Battle Chess
- Battle Cruiser
- Beach-Head
- Beach-Head II
- Bejeweled
- Boa
- Bop'n Wrestle
- Borg
- Boulder Dash
- Bug Attack
- California Games
- Castle Smurfenstein
- Caverns of Callisto
- Columns
- Congo
- Congo Bongo
- Copts and Robbers
- County Fair
- Crystal Castles
- Dangerous Dave
- Darkstar Unhinged
- Dino Smurf
- Dogfight II
- Double Trouble
- Evolution
- Exterminator
- Fat City
- Fight Night
- Flapple Bird
- Force 7
- Frazzle
- Fuji Speed Way
- G.I. Joe
- Galaxian
- Gauntlet
- Genesis
- Genius
- Genius 2
- Genius 3
- Ghostbusters
- Hardball
- I.O. Silver
- Impossible Mission II
- Into The Eagle's Nest
- Jawbreaker
- Jawbreaker II
- Karate Champ
- Kung Fu Master
- Little Computer People
- Lock 'n' Chase
- Mad Rat
- Manic Miner
- Mars Cars
- Mating Zone
- Matterhorn Screamer
- Maxwell Manor
- Megabots
- Micro Invaders
- Microwave
- Miner 2049er II
- Ming's Challenge
- Minit Man
- Minotaur
- Mission on Thunderhead
- Monster Mash
- Neptune
- Oid Zone
- One on One
- Outworld
- Pandora's Box
- Penetrator
- Pentapus
- Pulsar II
- Pharaoh's Revenge
- Raid Over Moscow
- Randamn
- Realm of Impossibility
- Roundabout
- Run For It
- Saracen
- Ski Crazed
- Soko-Ban
- Solo Flight
- Spectre
- Spindizzy
- Star Cruiser
- Starglider
- Station 5
- Street Sports Baseball
- Street Sports Basketball
- Street Sports Football
- Street Sports Soccer
- Summer Games
- Summer Games II
- Super Bunny
- Super Zaxxon
- TechnoCop
- Test Drive
- Tharolian Tunnels
- The Asteroid Field
- The Dam Busters
- The Heist
- The Last Gladiator
- The Last Ninja
- Triad
- Wayout
- Who Framed Roger Rabbit
- Wings of Fury
- Winter Games
- World Games
- World Karate Championship
- Zargs

### Games removed in v4

- Alien Rain (play Alien Typhoon instead)
- Apple Galaxian (play Alien Typhoon instead)
- Puck Man (play Snoggle instead)

### Demos added in v4

- Cannonball Blitz
- Crime Wave
- Laser Bounce
- Lazer Silk
- Night Stalker
- Nightmare Gallery
- N.O.R.A.D
- Phaser Fire
- Space Quarks
- Tunnel Terror

### Enhancements & bug fixes in v4

- Per-game help screens (select a game and press `?`)
- Display double hi-res title screens in search and browse modes
- Added more game cheats
- Upgrade Bejeweled to latest version (thanks Jeremy R.)
- Upgrade Berzap to latest version
- Upgrade Flapple Bird to latest version (thanks Dagen B.)
- Combined Thexder 64K and Thexder 128K; just launch Thexder and it'll figure it
  out
- Lots of new super hi-res artwork for IIgs users (thanks Alex L, Andrew R.)
- New slideshows for Ankh, Bruce Lee, Dig Dug, H.E.R.O, Kid Niki, Montezuma's
  Revenge, Mr. Robot (thanks Frank M., Tom G., qkumba)
- Auto-detect Mockingboard in any slot and auto-configure support in supported
  games (e.g. Berzap, Lady Tut, Lancaster, Pitfall II) (thanks Andrew R.)
- Fixed IRQ vectors causing hangs with certain demos on ][+ with Super Serial
  Card and/or Videx 80-column card installed (thanks Frank M.)
- Fixed acceleration on Laser 128 (thanks Tom G.)
- New GS/OS Finder icon (thanks fatdog projects)
- `Ctrl-Q` quits to GS/OS if possible, otherwise reboots
- Fixed CFFA3000 incompatibility on IIgs
- Fixed VidHD incompatibility on non-IIgs (thanks John B., Tom G.)
- Support Spectrum ED (Brazilian //e clone)
- Support Apple High-Speed SCSI card

## Revision 3 / serial number 20200121

### New games in v3

- Added Flight Simulator II
- Added Guardian
- Added Short Circuit
- Added Skyfox
- Removed Flight Simulator I
- Updated Rescue Raiders to version 1.5 (fixes Mockingboard and other issues)
- Combined Tetris 48K and Tetris 128K; just launch Tetris and it'll figure it out

### Enhancements & bug fixes in v3

- Added help screen (press `?` in search or browse mode to show)
- Added global cheat mode (press `Ctrl-C` in search or browse mode to toggle)
- Added 80 game cheats
- New and updated graphic effects in screensaver mode
- Ctrl-Reset quits to launcher from most games, and reboots cleanly from the
  rest (thanks Frank M.)
- Fixed corrupted graphics in Asteroid Blaster
- Fixed corrupted graphics in Sneakers game, demo, and screenshots, and now we
  are entirely done with this I promise
- Fixed Axis Assassin demo hanging on Apple IIgs
- Fixed a crash in Agent USA
- Fixed a crash in Spy Hunter at the boat house
- Added missing levels in Out Of This World
- Removed latent copy protection in BurgerTime, Sea Dragon, and Spider Raid
  (sneaky sneaky)
- Enable fast machine speed or accelerator (if available) to speed up searching,
  browsing, and game launching
- Prevent flashes of other game screenshots while loading a demo or game
- Fixed a freeze on startup with certain accelerators
- Fixed multiple crashes on Apple ][+, //c, //c+, and IIgs
- Fixed choppy sound in some games on Apple IIgs
- Fixed sound with FastChip accelerator (thanks Frank M.)
- Fixed crash with RGB card when entering double hi-res mode
- Fixed launching from MicroDrive partition 3+
- Fixed launching from CFFA 3000 partition 5+
- Fixed launching from RamFAST "GS/OS partitions"
- Fixed launching from ProDOS 2.5

## Revision 2 / serial number 190914

### Games added in v2

- Asteroid Blaster
- Aztec
- Beyond Castle Wolfenstein
- Buck Rogers: Planet of Zoom
- Diamond Mine
- Free Fall
- Hyper Head-On
- Indiana Jones
- Out Of This World
- Sea Dragon
- Seafox
- Situation Critical
- Star Thief
- The Spy Strikes Back

### Demos added in v2

- Alien Munchies
- Alien Typhoon
- Axis Assassin
- Battlezone
- Beer Run
- Bellhop
- Brainteaser Blvd
- Cyclod
- Dig Dug
- Falcons
- Labyrinth
- Space Eggs
- Star Blazer

### Enhancements & bug fixes in v2

- Pressing Space will now show a game's screenshots, as well as Tab
- Pressing right arrow will now progress through a slideshow without waiting
- Startup is noticeably faster
- Castle Wolfenstein has been upgraded to the 1984 re-release with updated graphics
- Mr. Do now shows its own in-game attract mode
- Mr. Do no longer crashes on level 8
- Prince of Persia no longer crashes on startup
- Zaxxon no longer crashes after a game ends
- Several games no longer crash on the //c
- Sneakers demo has corrected graphics
- Plasmania demo has corrected graphics
- Properly detect VidHD in slot 3
- Properly set alternate display mode on IIgs (fixes Centipede, Mr. Do)
- No longer crashes after loading a double hi-res screenshot from a SCSI hard drive
- Small high score files are saved (fixes Apple Cider Spider, Lancaster)
- Some double hi-res screenshots were being skipped even if the game was available
- Disk image is now exactly 32 MB

## Revision 1 / serial number 190720

- Initial release

### Games included in v1.0

- Agent U.S.A.
- Airheart
- Alcazar
- Alien Ambush
- Alien Downpour
- Alien Rain
- Alien Typhoon
- Alien Munchies
- Ankh
- Apple Cider Spider
- Apple Panic
- Aquatron
- Argos
- Arkanoid
- Axis Assassin
- Bad Dudes
- Ballblazer
- Batman
- Battlezone
- BC's Quest For Tires
- Beer Run
- Bellhop
- Berzap
- Bill Budge's Trilogy
- Black Magic
- Blister Ball
- BlockChain
- Bolo
- Bouncing Kamungas
- Brainteaser Boulevard
- Bruce Lee
- Bubble Bobble
- BurgerTime
- Buzzard Bait
- Cannonball Blitz
- Canyon Climber
- Captain Goodnight
- Castle Wolfenstein
- Ceiling Zero
- Centipede
- Championship Lode Runner
- Choplifter
- Commando
- Conan
- Crazy Mazey
- Crime Wave
- Crisis Mountain
- Crossfire
- Cubit
- Cyber Strike
- Cyclod
- D-Generation
- David's Midnight Magic
- Death Sword
- Defender
- Dig Dug
- Dino Eggs
- Donkey Kong
- Drelbs
- Drol
- Dung Beetles
- Eggs-It
- Epoch
- Falcons
- Flight Simulator I
- Flip Out
- Firebird
- Formula 1 Racer
- Frogger
- Frogger II
- Galaxian
- Galaxy Gates
- Gamma Goblins
- Genetic Drift
- Gold Rush
- Gorgon
- Gremlins
- Gumball
- Hadron
- H.E.R.O
- Hard Hat Mack
- Head On
- Heavy Barrel
- High Rise
- Horizon V
- Hungry Boy
- Ikari Warriors
- Impossible Mission
- International Gran Prix
- Joust
- Juggler
- Jumpman
- Jungle Hunt
- Kamikaze
- Karateka
- Kid Niki
- Labyrinth
- Lady Tut
- Lancaster
- Laser Bounce
- Lazer Silk
- Lode Runner
- Lost Tomb
- Mad Bomber
- Marble Madness
- Mario Bros
- Miner 2049er
- Montezuma's Revenge
- Moon Patrol
- Mr. Cool
- Mr. Do
- Mr. Robot
- Ms. Pacman
- Nibbler
- Night Mission Pinball
- Night Stalker
- Nightmare Gallery
- NORAD
- O'Riley's Mine
- Orbitron
- Outpost
- Pac-Man
- Paperboy
- Pest Patrol
- Phantoms Five
- Phaser Fire
- Photar
- Picnic Paranoia
- Pie-Man
- Pipe Dream
- Pit Stop II
- Pitfall II
- Plasmania
- Platoon
- Pollywog
- Pooyan
- Prince of Persia
- Puckman
- Qix
- Quadrant 6112
- Radwarrior
- Rampage
- Raster Blaster
- Red Alert
- Renegade
- Repton
- Rescue Raiders
- Ribbit
- Roadblock
- Robocop
- Robotron 2084
- Russki Duck
- Sabotage
- Sammy Lightfoot
- Serpentine
- Shamus
- Shuffleboard
- Snack Attack
- Snake Byte
- Sneakers
- Snoggle
- Space Eggs
- Space Quarks
- Space Raiders
- Spare Change
- Speedway Classic
- Spider Raid
- Spiderbot
- Spy Hunter
- Spy's Demise
- Starblaster
- Stargate
- Star Blazer
- Stellar 7
- Succession
- Suicide!
- Swashbuckler
- Tag Team Wrestling
- Tapper
- Tetris
- Tetris (DHGR)
- The Bilestoad
- The Games: Summer Edition
- The Games: Winter Edition
- The Goonies
- Thexder
- Thexder (DHGR)
- Thief
- Threshold
- Thunder Bombs
- Tomahawk
- Track & Field
- Tubeway ][
- Tunnel Terror
- Twerps
- Up'n Down
- Victory Road
- Vindicator
- Warp Destroyer
- Wavy Navy
- Xevious
- Zaxxon
- Zenith
