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

    if (c.indexOf("[eof]") >= 0)
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
  q = a.opentextfile("build\\DISPLAY.CONF").readall().replace(/\r\n/g, "\n")

  for (i = 0; i < entries.length; i++)
  {
    val = entries[i].indexOf("=")
    name = ((val >= 0) ? entries[i].substr(val + 1) : entries[i])
    bits = q.indexOf("," + name + "=") + 1
    name = q.substr(bits + name.length + 1)
    name = name.substr(0, name.indexOf("\n"))
    needsjoystick = q.substr(bits - 5, 1)
    needs128k = q.substr(bits - 4, 1)
    displayname = ((WScript.Arguments.length == 3) ? name : "")
    source.writeline("!byte " + (entries[i].length - ((val >= 0) ? 1 : 0) + displayname.length + 5))
    source.writeline("!byte " + ((val >= 0) ? val : entries[i].length))
    source.writeline("!text \"" + ((val >= 0) ? entries[i].substr(0, val) : entries[i]) + "\"")
    source.writeline("!byte " + ((val >= 0) ? (entries[i].length - (val + 1)) : 0))
    source.writeline("!text \"" + ((val >= 0) ? (entries[i].substr(val + 1)) : "") + "\"")
    source.writeline("!byte " + displayname.length)
    source.writeline("!text \"" + displayname + "\"")
    source.writeline("!byte " + ((needsjoystick * 128) + (Number(needs128k) * 64)))
  }

  source.close()
  new ActiveXObject("wscript.shell").run('cmd /c %acme% -o ' + WScript.Arguments(1) + ' build\\okvs.tmp', 0, 1)
}
