a = new ActiveXObject("scripting.filesystemobject")
b = a.opentextfile("res\\GAMES.CONF")

entries = []

while (!b.atendofstream)
{
  c = b.readline()
  d = c.indexOf("#")

  if (d >= 0)
  {
    c = c.substr(0, d)
  }

  d = c.indexOf("=")

  if (d >= 0)
  {
    c = c.substr(0, d)
  }

  if (c.indexOf("[") >= 0)
  {
    break
  }

  c = c.substr(5)

  if (c.length > 0)
  {
    entries.push(c)
  }
}

entries.sort()
y = "res\\GAMEHELP\\"
s = y + "STANDARD"
f = a.createtextfile(WScript.Arguments(0))
f.write(entry = a.opentextfile(s).readall().replace(/\r\n/g, "\n"))
help_off = entry.length

letter = "@" //"A" - 1
groups = ""
first = true
i = 0

while (i < entries.length)
{
  if (first)
  {
    letter = String.fromCharCode(letter.charCodeAt(0) + 1)
    group = "group" + letter

    groups += group + "\n"
    first = false
  }

  if (entries[i].charAt(0) == letter)
  {
    c = 0

    if (a.fileexists(y + entries[i]))
    {
      c = help_off
      f.write(entry = a.opentextfile(y + entries[i]).readall().replace(/\r\n/g, "\n"))
      help_off += entry.length
    }

    groups += "!byte " + format8(entries[i].length) + "\n" + "!text \"" + entries[i] + "\"\n" + "!byte " + format24(c) + "\n\n"
    ++i
  }
  else
  {
    first = true
  }
}

f = a.createtextfile(WScript.Arguments(1))
f.write(groups)

function format8(str)
{
  val8 = parseInt(str)
  return "$" + ((val8 < 16) ? "0" : "") + val8.toString(16)
}

function format24(str)
{
  val24 = parseInt(str)
  return format8(Math.floor(val24 / (256*256))) + ", " + format8(Math.floor(val24 / 256) % 256) + ", " + format8(val24 % 256)
}
