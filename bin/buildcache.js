a = new ActiveXObject("scripting.filesystemobject")
b = a.opentextfile("res\\GAMES.CONF")
f000 = a.createtextfile("build\\filter000.txt")
f001 = a.createtextfile("build\\filter001.txt")
f010 = a.createtextfile("build\\filter010.txt")
f011 = a.createtextfile("build\\filter011.txt")
f100 = a.createtextfile("build\\filter100.txt")
f101 = a.createtextfile("build\\filter101.txt")
f110 = a.createtextfile("build\\filter110.txt")
f111 = a.createtextfile("build\\filter111.txt")

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

  if (c.substr(0, 3) == "000")
  {
    f000.writeline(c.substr(c.indexOf("=") + 1))
  }

  if (c.substr(0, 2) == "00")
  {
    f001.writeline(c.substr(c.indexOf("=") + 1))
  }

  if ((c.substr(0, 1) == "0") && c.substr(2, 1) == "0"))
  {
    f010.writeline(c.substr(c.indexOf("=") + 1))
  }

  if (c.substr(0, 1) == "0")
  {
    f011.writeline(c.substr(c.indexOf("=") + 1))
  }

  if (c.substr(1, 2) == "00")
  {
    f100.writeline(c.substr(c.indexOf("=") + 1))
  }

  if (c.substr(1, 1) == "0")
  {
    f101.writeline(c.substr(c.indexOf("=") + 1))
  }

  if (c.substr(2, 1) == "0")
  {
    f110.writeline(c.substr(c.indexOf("=") + 1))
  }

  f111.writeline(c.substr(c.indexOf("=") + 1))
}

f111.close()
f110.close()
f101.close()
f100.close()
f011.close()
f010.close()
f001.close()
f000.close()

x = new ActiveXObject("wscript.shell")
x.run('cmd /c %python% bin\\buildcache.py < build\\filter000.txt > build\\cache000.a', 0, 1)
x.run('cmd /c %python% bin\\buildcache.py < build\\filter001.txt > build\\cache001.a', 0, 1)
x.run('cmd /c %python% bin\\buildcache.py < build\\filter010.txt > build\\cache010.a', 0, 1)
x.run('cmd /c %python% bin\\buildcache.py < build\\filter011.txt > build\\cache011.a', 0, 1)
x.run('cmd /c %python% bin\\buildcache.py < build\\filter110.txt > build\\cache100.a', 0, 1)
x.run('cmd /c %python% bin\\buildcache.py < build\\filter111.txt > build\\cache101.a', 0, 1)
x.run('cmd /c %python% bin\\buildcache.py < build\\filter110.txt > build\\cache110.a', 0, 1)
x.run('cmd /c %python% bin\\buildcache.py < build\\filter111.txt > build\\cache111.a', 0, 1)
x.run('cmd /c %acme% -o res\\CACHE000.IDX build\\cache000.a', 0, 1)
x.run('cmd /c %acme% -o res\\CACHE001.IDX build\\cache001.a', 0, 1)
x.run('cmd /c %acme% -o res\\CACHE010.IDX build\\cache010.a', 0, 1)
x.run('cmd /c %acme% -o res\\CACHE011.IDX build\\cache011.a', 0, 1)
x.run('cmd /c %acme% -o res\\CACHE100.IDX build\\cache100.a', 0, 1)
x.run('cmd /c %acme% -o res\\CACHE101.IDX build\\cache101.a', 0, 1)
x.run('cmd /c %acme% -o res\\CACHE110.IDX build\\cache110.a', 0, 1)
x.run('cmd /c %acme% -o res\\CACHE111.IDX build\\cache111.a', 0, 1)
