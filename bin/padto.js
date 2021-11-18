a = new ActiveXObject("scripting.filesystemobject")

if (WScript.Arguments(1) == "build\\PREFS.CONF")
{
  b = a.opentextfile(WScript.Arguments(1))
  c = b.readall().replace(/\r\n/g, "\n")
  b.close()
  b = a.createtextfile(WScript.Arguments(1))
  b.write(c)
  b.close()
}

c = a.getfile(WScript.Arguments(1)).size
b = a.opentextfile(WScript.Arguments(1), 8).write(Array((Math.floor((c + 511) / 512) * 512) - c + 1).join(String.fromCharCode(0)))
