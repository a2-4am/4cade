a = new ActiveXObject("scripting.filesystemobject")

entries = []

for (b = new Enumerator(a.GetFolder(WScript.Arguments(0)).files); !b.atEnd(); b.moveNext())
{
  entries.push(b.item().name)
}

entries.sort()
a.createtextfile("build\\games.lst").write(entries.toString().replace(/,/g, "\n"))
ss_off = 0
groups = "*=0\n" + "!le16 " + entries.length.toString() + ", 0\n"

for (i = 0; i < entries.length; i++)
{
  groups += "!byte " + (1 + 1 + entries[i].length + 5).toString() + "\n" + "!byte " + entries[i].length.toString() + "\n" + "!text \"" + entries[i] + "\"\n" + "!be24 " + ss_off.toString() + "\n"
  size = a.getfile(WScript.Arguments(0) + "\\" + entries[i]).size
  // if offset+size does not cross a block boundary, use the size
  // otherwise adjust size until it ends at the next block boundary to avoid a partial copy on the last block
  groups += "!le16 " + ((Math.floor(ss_off / 512) == Math.floor((ss_off + size) / 512)) ? size : (((ss_off + size + 511) & -512) - ss_off)).toString()  + "\n"
  ss_off += size
}

f = a.createtextfile(WScript.Arguments(1))
f.write(groups)
f.close()
new ActiveXObject("wscript.shell").run('cmd /c %acme% -o ' + WScript.Arguments(2) + " " + WScript.Arguments(1), 0, 1)
