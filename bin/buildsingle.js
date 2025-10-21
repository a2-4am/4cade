a = new ActiveXObject("scripting.filesystemobject")
x = new ActiveXObject("wscript.shell")
b = x.exec('findstr /b \".....1\" build\\DISPLAY.CONF')

entries = []

while (!b.stdout.atendofstream)
{
  c = b.stdout.readline()
  c = c.substr(c.indexOf(",") + 1)
  c = c.substr(0, c.indexOf("="))
  entries.push(c)
}

entries.sort()

for (i = 0; i < entries.length; i++)
{
  x.run('cmd /c move /y build\\X\\' + entries[i] + ' ' + WScript.Arguments(0), 0, 1)
}

groups = "*=0\n" + "!le16 " + entries.length + ", 0\n"
sng_off = a.getfile(WScript.Arguments(2)).size
b = a.createtextfile("build\\sng.lst")

for (i = 0; i < entries.length; i++)
{
  c = sng_off
  item = (new Enumerator(a.GetFolder(WScript.Arguments(0) + "\\" + entries[i]).files)).item()
  name = a.GetFileName(item)
  key = name.substr(0,name.indexOf("#"))
  addr = name.substr(name.indexOf("#") + 3)
  b.writeline(key + "\\" + name)
  size = item.size
  sng_off += size

  if (WScript.Arguments.length == 4)
  {
    // if offset+size does not cross a block boundary, use the size
    // otherwise adjust size until it ends at the next block boundary to avoid a partial copy on the last block
    size = ((Math.floor(c / 512) == Math.floor((c + size) / 512)) ? size : (((c + size + 511) & -512) - c))
  }

  groups += "!byte " + (1 + 1 + key.length + 3 + 2 + 2) + "\n" + "!byte " + key.length + "\n" + "!text \"" + key + "\"\n" + "!be24 " + c + "\n" + "!le16 " + size + "\n" + "!le16 $" + addr + "\n"
}

b.close()

f = a.createtextfile("build\\sng.tmp")
f.write(groups)
f.close()
x = new ActiveXObject("wscript.shell")
x.run('cmd /c %acme% -o ' + WScript.Arguments(1) + ' build\\sng.tmp', 0, 1)
x.run('cmd /c bin\\buildsngall.bat ' + WScript.Arguments(0) + ' ' + WScript.Arguments(2), 0, 1)
