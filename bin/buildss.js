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

a.createtextfile("build\\games.lst").write(entries.toString().replace(/,/g, "\n"))
ss_off = a.fileexists(WScript.Arguments(2)) ? a.getFile(WScript.Arguments(2)).size : 0
groups = "*=0\n" + "!le16 " + entries.length + ", 0\n"

for (i = 0; i < entries.length; i++)
{
  size = a.getfile(p + "\\" + entries[i]).size
  c = ss_off
  ss_off += size

  if (WScript.Arguments.length == 5)
  {
    // if offset+size does not cross a block boundary, use the size
    // otherwise adjust size until it ends at the next block boundary to avoid a partial copy on the last block
    size = ((Math.floor(c / 512) == Math.floor((c + size) / 512)) ? size : (((c + size + 511) & -512) - c))
  }

  groups += "!byte " + (1 + 1 + entries[i].length + 5) + "\n" + "!byte " + entries[i].length + "\n" + "!text \"" + entries[i] + "\"\n" + "!be24 " + c + "\n" + "!le16 " + size  + "\n"
}

f = a.createtextfile("build\\ss.tmp")
f.write(groups)
f.close()
x = new ActiveXObject("wscript.shell")
x.run('cmd /c %acme% -o ' + WScript.Arguments(1) + ' build\\ss.tmp', 0, 1)
x.run('cmd /c bin\\buildpreall.bat ' + p + ' ' + WScript.Arguments(2) + ' ' + WScript.Arguments(3), 0, 1)
