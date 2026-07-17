-- Some games need custom scripts to check for a successful launch,
-- generally because they wait for input before switching to
-- graphics mode. The game-specific function here must include all
-- commands, including the appropriate wait-for function(s).
--
-- Games not listed here use the default script, which just waits
-- for graphics mode.

replay = require("replay")
apple2 = require("apple2")

return {
  ["Applz"] = function()
    replay.WaitForScreenContains("APPLZ")
    apple2.Type(" ")
    replay.WaitForScreenContains("CONTROLS")
    apple2.Type(" ")
    replay.WaitForGraphicsMode()
  end,
  ["Airheart"] = function()
    replay.WaitForGraphicsMode()
    emu.wait(10)
  end,
  ["Blister Ball"] = function()
    apple2.Type(" 114")
    replay.WaitForGraphicsMode()
  end,
  ["Bongo's Bash"] = function()
    replay.WaitForScreenContains("HIT A KEY TO CONTINUE")
    apple2.Type(" ")
    replay.WaitForGraphicsMode()
  end,
  ["BurgerTime"] = function()
    replay.WaitForGraphicsMode()
    apple2.Type("J")
    apple2.SetJoy1(127,127)
    apple2.PressJoyButton1()
    apple2.ReleaseJoyButton1()
    apple2.SetJoy1(0,0)
    apple2.PressJoyButton1()
    apple2.ReleaseJoyButton1()
    apple2.SetJoy1(255,255)
    apple2.PressJoyButton1()
    apple2.ReleaseJoyButton1()
    replay.WaitForAddressEquals(0x201E, 0xB8) --egg in corner of demo
  end,
  ["Clam Bake"] = function()
    replay.WaitForScreenContains("CLAM BAKE")
    apple2.Type(" ")
    replay.WaitForGraphicsMode()
  end,
  ["Helicopter Rescue"] = function()
    replay.WaitForScreenContains("DO YOU WANT INSTRUCTIONS")
    apple2.Type("N")
    replay.WaitForScreenContains("CHOOSE A SCENE")
    apple2.Type("1")
    replay.WaitForGraphicsMode()
  end,
  ["I.O. Silver"] = function()
    replay.WaitForGraphicsMode()
    emu.wait(2)
  end,
  ["Jungle Hunt"] = function()
    replay.WaitForGraphicsMode()
    emu.wait(2)
  end,
  ["Kaboom!"] = function()
    replay.WaitForScreenContains("PRESS ANY KEY TO CONTINUE")
    apple2.Type(" ")
    replay.WaitForGraphicsMode()
  end,
  ["Lemmings"] = function()
    replay.WaitForScreenContains("PRESS RETURN TO CONTINUE")
    apple2.ReturnKey()
    replay.WaitForGraphicsMode()
  end,
  ["Little Brick Out"] = function()
    replay.WaitForScreenContains("PRESS THE SPACE BAR")
    apple2.Type(" ")
    replay.WaitForScreenContains("YOUR FIRST NAME")
    apple2.ReturnKey()
    replay.WaitForGraphicsMode()
  end,
  ["Lethal Labyrinth"] = function()
    replay.WaitForScreenContains("INITIALIZING")
  end,
  ["Lunar Explorer"] = function()
    replay.WaitForScreenContains("EYBOARD OR")
    apple2.Type("K")
    replay.WaitForGraphicsMode()
  end,
  ["Mad Bomber"] = function()
    replay.WaitForScreenContains("ONE PLAYER")
    apple2.Type("1")
    replay.WaitForGraphicsMode()
  end,
  ["Marauder"] = function()
    replay.WaitForScreenContains("PLAY COMPLETE GAME")
    apple2.Type("3")
    replay.WaitForGraphicsMode()
  end,
  ["Millennium Leaper"] = function()
    replay.WaitForScreenContains("RETURN TO START DEMO")
    apple2.ReturnKey()
    replay.WaitForGraphicsMode()
  end,
  ["Montezuma's Revenge"] = function()
    replay.WaitForScreenContains("FOR MENU")
    apple2.ReturnKey()
    replay.WaitForScreenContains("TO START")
    apple2.ReturnKey()
    replay.WaitForGraphicsMode()
  end,
  ["Mr. Do!"] = function()   --Uses Text Page 2!
    replay.WaitForAddressEquals(0x83A, 0xD2) --'R'IGHTMOST
    apple2.SetJoy1(255,127)
    apple2.PressJoyButton1()
    apple2.ReleaseJoyButton1()
    replay.WaitForAddressEquals(0x83A, 0xCC) --'L'EFTMOST
    apple2.SetJoy1(0,127)
    apple2.PressJoyButton1()
    apple2.ReleaseJoyButton1()
    replay.WaitForAddressEquals(0x83A, 0xD4) --'T'OPMOST
    apple2.SetJoy1(127,0)
    apple2.PressJoyButton1()
    apple2.ReleaseJoyButton1()
    replay.WaitForAddressEquals(0x83A, 0xC2) --'B'OTTOMMOST
    apple2.SetJoy1(127,255)
    apple2.PressJoyButton1()
    apple2.ReleaseJoyButton1()
    replay.WaitForGraphicsMode()
    emu.wait(2)
  end,
  ["Mutant (Steve Waldo)"] = function()
    replay.WaitForScreenContains("FAST ACTION ARCADE GAME")
    apple2.ReturnKey()
    replay.WaitForScreenContains("MOVING WALLS")
    apple2.ReturnKey()
    replay.WaitForScreenContains("DIFFICULTY LEVELS")
    apple2.ReturnKey()
    replay.WaitForScreenContains("TO MOVE RIGHT")
    apple2.ReturnKey()
    replay.WaitForGraphicsMode()
  end,
  ["Nibbler (B. Iverson)"] = function()
    replay.WaitForScreenContains("PRESS ANY KEY TO BEGIN")
    apple2.Type(" ")
    replay.WaitForGraphicsMode()
  end,
  ["Night Crawler"] = function()
    replay.WaitForScreenContains("EYBOARD")
    apple2.Type("K")
    replay.WaitForGraphicsMode()
  end,
  ["Night Stalker"] = function()
    replay.WaitForGraphicsMode()
    apple2.Type("J")
    apple2.SetJoy1(127,127)
    apple2.PressJoyButton1()
    apple2.ReleaseJoyButton1()
    apple2.SetJoy1(0,0)
    apple2.PressJoyButton1()
    apple2.ReleaseJoyButton1()
    apple2.SetJoy1(255,255)
    apple2.PressJoyButton1()
    apple2.ReleaseJoyButton1()
    replay.WaitForAddressEquals(0x2000, 0xF5) --demo screen
  end,
  ["Out of This World"] = function()
    replay.WaitForScreenContains("START AT CHECKPOINT 1")
    apple2.TypeLine("1")
    replay.WaitForGraphicsMode()
  end,
  ["Pacman"] = function()
    emu.wait(5)
    apple2.Type("1")
    emu.wait(5)
    apple2.Type("N")
    replay.WaitForGraphicsMode()
  end,
  ["Pentapus"] = function()
    replay.WaitForGraphicsMode()
    emu.wait(2)
  end,
  ["Planetoids"] = function()
    replay.WaitForScreenContains("EASY")
    apple2.Type("1")
    replay.WaitForGraphicsMode()
  end,
  ["Spy vs Spy 2"] = function()
    replay.WaitForScreenContains("KEYBOARD")
    apple2.Type("1")
    replay.WaitForGraphicsMode()
  end,
  ["Super Taxman 2"] = function()
    replay.WaitForGraphicsMode()
    emu.wait(2)
  end,
  ["The Goonies"] = function()   --Uses Text Page 2!
    replay.WaitForAddressEquals(0x83A, 0xD2) --'R'IGHTMOST
    apple2.SetJoy1(255,127)
    apple2.PressJoyButton1()
    apple2.ReleaseJoyButton1()
    replay.WaitForAddressEquals(0x83A, 0xCC) --'L'EFTMOST
    apple2.SetJoy1(0,127)
    apple2.PressJoyButton1()
    apple2.ReleaseJoyButton1()
    replay.WaitForAddressEquals(0x83A, 0xD4) --'T'OPMOST
    apple2.SetJoy1(127,0)
    apple2.PressJoyButton1()
    apple2.ReleaseJoyButton1()
    replay.WaitForAddressEquals(0x83A, 0xC2) --'B'OTTOMMOST
    apple2.SetJoy1(127,255)
    apple2.PressJoyButton1()
    apple2.ReleaseJoyButton1()
    replay.WaitForGraphicsMode()
  end,
  ["Titan Cronus"] = function()
    replay.WaitForScreenContains("KEYBOARD")
    apple2.Type("K")
    replay.WaitForGraphicsMode()
  end,
  ["Treasure Dive"] = function()
    replay.WaitForScreenContains("PRESS RETURN TO CONTINUE")
    apple2.ReturnKey()
    replay.WaitForGraphicsMode()
  end,
  ["Trolls and Tribulations"] = function()
    replay.WaitForGraphicsMode()
    emu.wait(2)
  end,
  ["Zoo Master"] = function()
    replay.WaitForScreenContains("SOUND")
  end,
}
