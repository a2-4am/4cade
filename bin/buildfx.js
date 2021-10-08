a = new ActiveXObject("scripting.filesystemobject")
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

  if (c.indexOf("[") >= 0)
  {
    break
  }

  if (c.length > 0)
  {
    entries.push(c)
  }
}

y = "build\\FX\\"

fx_off = 0
groups = "*=0\n" + "!le16 " + entries.length.toString() + ", 0\n"

for (i = 0; i < entries.length; i++)
{
  groups += "!byte " + (1 + 1 + entries[i].length + 1 + 3).toString() + "\n" + "!byte " + entries[i].length.toString() + "\n" + "!text \"" + entries[i] + "\"\n" + "!byte 3"+ "\n" + "!be24 " + fx_off.toString() + "\n"
  fx_off += a.getfile(y + entries[i]).size
}

f = a.createtextfile(WScript.Arguments(1))
f.write(groups)
f.close()
new ActiveXObject("wscript.shell").run('cmd /c %acme% -o ' + WScript.Arguments(2) + " " + WScript.Arguments(1))
