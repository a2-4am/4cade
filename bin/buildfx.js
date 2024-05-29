a = new ActiveXObject("scripting.filesystemobject")
x = new ActiveXObject("wscript.shell")
fx_off = a.fileexists(WScript.Arguments(2)) ? a.getFile(WScript.Arguments(2)).size : 0
x.run('cmd /c bin\\buildfxful.bat ' + WScript.Arguments(0) + ' ' + WScript.Arguments(2) + ' ' + WScript.Arguments(3), 0, 1)

b = a.opentextfile(WScript.Arguments(0))

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

  if (c.indexOf("[eof]") >= 0)
  {
    break
  }

  if (c.length > 0)
  {
    entries.push(c)
  }
}

groups = "*=0\n" + "!le16 " + entries.length.toString() + ", 0\n"

for (i = 0; i < entries.length; i++)
{
  groups += "!byte " + (1 + 1 + entries[i].length + 5).toString() + "\n" + "!byte " + entries[i].length.toString() + "\n" + "!text \"" + entries[i] + "\"\n" + "!be24 " + fx_off.toString() + "\n"
  size = a.getfile(WScript.Arguments(3) + "\\" + entries[i]).size
  groups += "!le16 " + size + "\n"
  fx_off += size
}

f = a.createtextfile("build\\fx.tmp")
f.write(groups)
f.close()
x.run('cmd /c %acme% -o ' + WScript.Arguments(1) + ' build\\fx.tmp', 0, 1)
