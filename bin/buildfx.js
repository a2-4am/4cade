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
  groups += "!byte " + (1 + 1 + entries[i].length + 5).toString() + "\n" + "!byte " + entries[i].length.toString() + "\n" + "!text \"" + entries[i] + "\"\n" + "!be24 " + fx_off.toString() + "\n"
  size = a.getfile(y + entries[i]).size
  // if offset+size does not cross a block boundary, use the size
  // otherwise adjust size until it ends at the next block boundary to avoid a partial copy on the last block
  groups += "!le16 " + ((Math.floor(fx_off / 512) == Math.floor((fx_off + size) / 512)) ? size : (((fx_off + size + 511) & -512) - fx_off)).toString()  + "\n"
  fx_off += size
}

f = a.createtextfile(WScript.Arguments(1))
f.write(groups)
f.close()
new ActiveXObject("wscript.shell").run('cmd /c %acme% -o ' + WScript.Arguments(2) + " " + WScript.Arguments(1))
