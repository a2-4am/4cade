a = new ActiveXObject("scripting.filesystemobject")
b = a.opentextfile("build\\GAMES.CONF")
c = a.createtextfile("build\\DISPLAY.CONF")

while (!b.atendofstream)
{
  d = b.readline()

  if (d.indexOf("[eof]") >= 0)
  {
    break
  }

  if (d.indexOf("=") == -1)
  {
    e = d.indexOf(",") + 1
    f = d.substr(e).split(".")

    for (g = 0; g < f.length; g++)
    {
      f[g] = f[g].charAt(0) + f[g].substr(1).toLowerCase()
    }

    d += "=" + f.join(" ").replace(" Ii", " II")
  }

  c.writeline(d)
}
