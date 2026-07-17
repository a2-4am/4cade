local replay = {}

local apple2 = require("apple2")
local test = require("test")
local util = require("util")

local GameDisplayNameAddr = 0x01fd9
local GameCountAddr = 0x01ff7
local AttractCounter = 0x0ffe4

mem = manager.machine.devices[':maincpu'].spaces['program']
a2 = { text = true, mixed = false, page2 = false, hires = false }

function handle_softsw(offset, data, mask)
    local addr = offset
    if     addr == 0xC050 then a2.text  = false
    elseif addr == 0xC051 then a2.text  = true
    elseif addr == 0xC052 then a2.mixed = false
    elseif addr == 0xC053 then a2.mixed = true
    elseif addr == 0xC054 then a2.page2 = false
    elseif addr == 0xC055 then a2.page2 = true
    elseif addr == 0xC056 then a2.hires = false
    elseif addr == 0xC057 then a2.hires = true
    end
end

read_tap  = mem:install_read_tap(0xC050, 0xC057, "a2_softsw_r", handle_softsw)
write_tap = mem:install_write_tap(0xC050, 0xC057, "a2_softsw_w", handle_softsw)

function is_in_graphics_mode()
    return not a2.text
end

function is_in_text_mode()
    return a2.text
end

function replay.ScreenContains(s)
  return apple2.GrabTextScreen():upper():find(s)
end

function replay.WaitForScreenContains(s, options)
  util.WaitFor(
    s,
    function()
      return replay.ScreenContains(s)
    end,
    options)
end

function replay.WaitForGraphicsMode(options, level)
  if options == nil then options = {} end
  if level == nil then level = 0 end
  util.WaitFor("gfxmode", is_in_graphics_mode, options, level+1)
end

function replay.WaitForTextMode(options, level)
  if options == nil then options = {} end
  if level == nil then level = 0 end
  util.WaitFor("textmode", is_in_text_mode, options, level+1)
end

function replay.WaitForAddressEquals(addr, val, options)
  util.WaitFor(
    "address",
    function()
      return apple2.ReadRAMDevice(addr) == val
    end,
    options)
end

function replay.GetGameCount()
  local val = (apple2.ReadRAMDevice(GameCountAddr) - 0x30) * 100
  val = val + (apple2.ReadRAMDevice(GameCountAddr+1) - 0x30) * 10
  val = val + apple2.ReadRAMDevice(GameCountAddr+2) - 0x30
  return val
end

function replay.GetSelectedGameDisplayName()
  local addr = GameDisplayNameAddr
  local len = 27
  local str = ""
  local c
  for i = 1,len do
    c = apple2.ReadRAMDevice(addr)
    if c == 0x7f then break end
    str = str .. string.char(c)
    addr = addr + 1
  end
  return str:match'^()%s*$' and '' or str:match'^%s*(.*%S)'

end

-- Launch Total Replay, type to search, launch game, Ctrl-Reset
function replay.allgames(flagmask)
  local games_f = assert(io.open(debug.getinfo(2, 'S').source:sub(2):match('(.*/)') .. "../res/GAMES.CONF", "r"))
  local allgame_input = {}
  local allgame_display = {}
  io.input(games_f)
  for line in io.lines() do
    if not line:match("^#") then  -- skip lines beginning with "#"
      local flags, directory, display_name, year = line:match("([^,]+),([^=]+)=([^/]+)/?(.*)")
      local include = true
      if not flags then
        include = false
      else
        if flagmask then
          include = flags:match(flagmask)
        end
      end
      if include then
        -- Remove punctuation and spaces, and convert the remaining text to all uppercase letters
        local input_name = display_name:gsub("%p", ""):gsub("%s", ""):upper()
        allgame_input[#allgame_input + 1] = input_name
        allgame_display[#allgame_display + 1] = (#allgame_display + 1) .. "/" .. display_name
      end
    end
  end
  assert(games_f:close())
  --for k,v in pairs(allgame_display) do
  --  print(k,v)
  --end
  local allgame_script = require("allgames-script")
  test.Variants(
    allgame_display,
    function(idx, name)
      name = name:gsub(idx .. "/", "")
      replay.WaitForGraphicsMode()
      local str = allgame_input[idx]
      for i = 1, #str do
        local c = str:sub(i, i)
        apple2.Type(c)
        emu.wait(1)
        if replay.GetSelectedGameDisplayName() == name then break end
      end
      test.ExpectEquals(replay.GetSelectedGameDisplayName(), name, "display name")
      apple2.ReturnKey()
      replay.WaitForTextMode()
      local game_script = allgame_script[name]
      if game_script then
        game_script()
      else
        emu.wait(1)
        replay.WaitForGraphicsMode()
      end
      apple2.ControlReset()
      emu.wait(1)
      replay.WaitForGraphicsMode()
      local display_name_after_reset = replay.GetSelectedGameDisplayName()
      if display_name_after_reset ~= "Type to search, ? for help" then
        test.ExpectEquals(display_name_after_reset, name, "display name after reset")
        apple2.LeftArrowKey()
        apple2.LeftArrowKey()
        apple2.LeftArrowKey()
        apple2.LeftArrowKey()
        apple2.LeftArrowKey()
        apple2.LeftArrowKey()
        apple2.LeftArrowKey()
        apple2.LeftArrowKey()
        apple2.LeftArrowKey()
        apple2.LeftArrowKey()
        apple2.LeftArrowKey()
        apple2.LeftArrowKey()
        apple2.LeftArrowKey()
        apple2.LeftArrowKey()
        apple2.LeftArrowKey()
        apple2.LeftArrowKey()
        apple2.LeftArrowKey()
        apple2.LeftArrowKey()
        apple2.LeftArrowKey()
        apple2.LeftArrowKey()
        apple2.LeftArrowKey()
        apple2.LeftArrowKey()
        apple2.LeftArrowKey()
        apple2.LeftArrowKey()
        apple2.LeftArrowKey()
        apple2.LeftArrowKey()
        apple2.LeftArrowKey()
      end
  end)
end

return replay
