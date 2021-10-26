a = new ActiveXObject("scripting.filesystemobject")
b = a.opentextfile("res\\GAMES.CONF")
c = []
q = a.createtextfile("build\\GAMES.CONF")

while (!b.atendofstream)
{
  d = b.readline()
  e = d.indexOf("#")

  if (e >= 0)
  {
    d = d.substr(0, e)
  }

  e = d.indexOf("[eof]")

  if (e > -1)
  {
    break
  }

  e = d.indexOf("=")

  if (e == -1)
  {
    e = d.length
  }

  if (d.length > 0)
  {
    q.write(d + "\n")
    f = d.indexOf(",") + 1
    c.push(d.substr(f, e - f))
  }
}

q.write(d + "\n")
a.createtextfile("build\\GAMES.SORTED").write(c.sort().toString().replace(/,/g, "\n"))
