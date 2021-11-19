a = new ActiveXObject("scripting.filesystemobject")
b = a.opentextfile("res\\GAMES.CONF")
f00 = a.createtextfile("build\\filter00.txt")
f01 = a.createtextfile("build\\filter01.txt")
f10 = a.createtextfile("build\\filter10.txt")
f11 = a.createtextfile("build\\filter11.txt")

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

  if (c.length == 0)
  {
    continue
  }

  if (c.substr(0, 2) == "00")
  {
    f00.writeline(c.substr(c.indexOf("=") + 1))
  }

  if (c.substr(0, 1) == "0")
  {
    f01.writeline(c.substr(c.indexOf("=") + 1))
  }

  if (c.substr(1, 1) == "0")
  {
    f10.writeline(c.substr(c.indexOf("=") + 1))
  }

  f11.writeline(c.substr(c.indexOf("=") + 1))
}

f11.close()
f10.close()
f01.close()
f00.close()

x = new ActiveXObject("wscript.shell")
x.run('cmd /c %python% bin\\buildcache.py < build\\filter00.txt > build\\cache00.a', 0, 1)
x.run('cmd /c %python% bin\\buildcache.py < build\\filter01.txt > build\\cache01.a', 0, 1)
x.run('cmd /c %python% bin\\buildcache.py < build\\filter10.txt > build\\cache10.a', 0, 1)
x.run('cmd /c %python% bin\\buildcache.py < build\\filter11.txt > build\\cache11.a', 0, 1)
x.run('cmd /c %acme% -o res\\CACHE00.IDX build\\cache00.a', 0, 1)
x.run('cmd /c %acme% -o res\\CACHE01.IDX build\\cache01.a', 0, 1)
x.run('cmd /c %acme% -o res\\CACHE10.IDX build\\cache10.a', 0, 1)
x.run('cmd /c %acme% -o res\\CACHE11.IDX build\\cache11.a', 0, 1)
