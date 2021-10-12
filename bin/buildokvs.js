a = new ActiveXObject("scripting.filesystemobject")

if (!a.fileexists(WScript.Arguments(1)) || a.getfile(WScript.Arguments(1)).datelastmodified < a.getFile(WScript.Arguments(0)).datelastmodified)
{
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

    if (c.indexOf("[") >= 0)
    {
      break
    }

    if (c.length > 0)
    {
      entries.push(c)
    }
  }

  source = a.createtextfile("build\\okvs.tmp")
  source.writeline("*=0")
  source.writeline("!le16 " + entries.length + ", 0")

  for (i = 0; i < entries.length; i++)
  {
    val = entries[i].indexOf("=")
    source.writeline("!byte " + (entries[i].length - ((val >= 0) ? 1 : 0) + 3).toString())
    source.writeline("!byte " + ((val >= 0) ? val : entries[i].length).toString())
    source.writeline("!text \"" + ((val >= 0) ? entries[i].substr(0, val) : entries[i]) + "\"")
    source.writeline("!byte " + ((val >= 0) ? (entries[i].length - (val + 1)) : 0).toString())
    source.writeline("!text \"" + ((val >= 0) ? (entries[i].substr(val + 1)) : "") + "\"")
  }

  x = new ActiveXObject("wscript.shell")
  x.run('cmd /c %acme% -o ' + WScript.Arguments(1) + ' build\\okvs.tmp')
}
