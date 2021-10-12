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

  c = c.substr(c.indexOf(",") + 1)

  if (c.length > 0)
  {
    entries.push(c)
  }
}

entries.sort()
y = "res\\GAMEHELP\\"
f = a.createtextfile(WScript.Arguments(0))
f.write(entry = a.opentextfile(y + "STANDARD").readall().replace(/\r\n/g, "\n"))
help_off = entry.length

groups = "*=0\n" + "!le16 " + entries.length.toString() + ", 0\n"
i = 0

while (i < entries.length)
{
  c = 0

  if (a.fileexists(y + entries[i]))
  {
    c = help_off
    f.write(entry = a.opentextfile(y + entries[i]).readall().replace(/\r\n/g, "\n"))
    help_off += entry.length
  }

  groups += "!byte " + (1 + 1 + entries[i].length + 3).toString() + "\n" + "!byte " + entries[i].length + "\n" + "!text \"" + entries[i] + "\"\n" + "!be24 " + c + "\n\n"
  ++i
}

f = a.createtextfile(WScript.Arguments(1))
f.write(groups)
f.close()
new ActiveXObject("wscript.shell").run('cmd /c %acme% -o ' + WScript.Arguments(2) + " " + WScript.Arguments(1))
