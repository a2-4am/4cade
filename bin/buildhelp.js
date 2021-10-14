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
osize = help_off

groups = "*=0\n" + "!le16 " + entries.length.toString() + ", 0\n"

for (i = 0; i < entries.length; i++)
{
  c = 0
  size = osize

  if (a.fileexists(y + entries[i]))
  {
    c = help_off
    f.write(entry = a.opentextfile(y + entries[i]).readall().replace(/\r\n/g, "\n"))
    size = entry.length
    help_off += size
  }

  groups += "!byte " + (1 + 1 + entries[i].length + 5).toString() + "\n" + "!byte " + entries[i].length + "\n" + "!text \"" + entries[i] + "\"\n" + "!be24 " + c + "\n"
  // if offset+size does not cross a block boundary, use the size
  // otherwise adjust size until it ends at the next block boundary to avoid a partial copy on the last block
  groups += "!le16 " + ((Math.floor(c / 512) == Math.floor((c + size) / 512)) ? size : (((c + size + 511) & -512) - c)).toString()  + "\n"
}

f = a.createtextfile(WScript.Arguments(1))
f.write(groups)
f.close()
new ActiveXObject("wscript.shell").run('cmd /c %acme% -o ' + WScript.Arguments(2) + " " + WScript.Arguments(1))
