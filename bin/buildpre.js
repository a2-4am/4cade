a = new ActiveXObject("scripting.filesystemobject")
b = a.opentextfile("build\\GAMES.SORTED")

entries = []

while (!b.atendofstream)
{
  entries.push(b.readline())
}

pre_off = a.getfile(WScript.Arguments(2)).size + a.getfile(WScript.Arguments(0) + "\\STANDARD").size
osize = pre_off

groups = "*=0\n" + "!le16 " + entries.length + ", 0\n"

for (i = 0; i < entries.length; i++)
{
  c = 0
  size = osize

  if (a.fileexists(WScript.Arguments(0) + "\\" + entries[i]))
  {
    c = pre_off
    size = a.getfile(WScript.Arguments(0) + "\\" + entries[i]).size
    pre_off += size
  }

  if (WScript.Arguments.length == 4)
  {
    // if offset+size does not cross a block boundary, use the size
    // otherwise adjust size until it ends at the next block boundary to avoid a partial copy on the last block
    size = ((Math.floor(c / 512) == Math.floor((c + size) / 512)) ? size : (((c + size + 511) & -512) - c))
  }

  groups += "!byte " + (1 + 1 + entries[i].length + 5) + "\n" + "!byte " + entries[i].length + "\n" + "!text \"" + entries[i] + "\"\n" + "!be24 " + c + "\n" + "!le16 " + size + "\n"
}

f = a.createtextfile("build\\pre.tmp")
f.write(groups)
f.close()
x = new ActiveXObject("wscript.shell")
x.run('cmd /c %acme% -o ' + WScript.Arguments(1) + ' build\\pre.tmp', 0, 1)
x.run('cmd /c bin\\buildpreall.bat ' + WScript.Arguments(0) + ' ' + WScript.Arguments(2) + ' ' + WScript.Arguments(0) + '\\STANDARD', 0, 1)
