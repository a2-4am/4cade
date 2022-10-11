a = new ActiveXObject("scripting.filesystemobject")

entries = []
p = WScript.Arguments(0)

if (p.charAt(p.length - 1) == "*")
{
  b = a.opentextfile(p.substr(0, p.length - 1))

  while (!b.atendofstream)
  {
    c = b.readline()
    entries.push(c.substr(c.lastIndexOf("\\") + 1))
  }

  p = c.substr(0, c.lastIndexOf("\\"))
}
else
{
  for (b = new Enumerator(a.GetFolder(p).files); !b.atEnd(); b.moveNext())
  {
    entries.push(b.item().name)
  }
}

entries.sort()

f = a.createtextfile("build\\GAMES.SORTED")
f.write(entries.toString().replace(/,/g, "\n"))
f.close()
ss_off = a.fileexists(WScript.Arguments(3)) ? a.getFile(WScript.Arguments(3)).size : 0
groups = "*=0\n" + "!le16 " + entries.length + ", 0\n"

q = 0

if (WScript.Arguments(2) != "nul")
{
  q = a.createtextfile(WScript.Arguments(2))
  q.writeline()
}

for (i = 0; i < entries.length; i++)
{
  size = a.getfile(p + "\\" + entries[i]).size
  c = ss_off
  ss_off += size

  if (WScript.Arguments.length == 6)
  {
    // if offset+size does not cross a block boundary, use the size
    // otherwise adjust size until it ends at the next block boundary to avoid a partial copy on the last block
    size = ((Math.floor(c / 512) == Math.floor((c + size) / 512)) ? size : (((c + size + 511) & -512) - c))
  }

  r = entries[i].indexOf("#06")

  if (r == -1)
  {
    groups += "!byte " + (entries[i].length + 7) + "\n" + "!byte " + entries[i].length + "\n" + "!text \"" + entries[i] + "\"\n" + "!be24 " + c + "\n" + "!le16 " + size  + "\n"
  }
  else
  {
    groups += "!byte " + (entries[i].substr(0, r).length + 9) + "\n" + "!byte " + entries[i].substr(0, r).length + "\n" + "!text \"" + entries[i].substr(0, r) + "\"\n" + "!be24 " + c + "\n" + "!le16 " + size  + "\n" + "!le16 $" + entries[i].substr(r + 3)  + "\n"
  }

  if (typeof(q) == "object")
  {
    q.writeline(entries[i] + "," + c + "," + size)
  }
}

if (typeof(q) == "object")
{
  q.close()
}

f = a.createtextfile("build\\ss.tmp")
f.write(groups)
f.close()
x = new ActiveXObject("wscript.shell")
x.run('cmd /c %acme% -o ' + WScript.Arguments(1) + ' build\\ss.tmp', 0, 1)
x.run('cmd /c bin\\buildpreall.bat ' + p + ' ' + WScript.Arguments(3) + ' ' + WScript.Arguments(4), 0, 1)
