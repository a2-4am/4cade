a = new ActiveXObject("scripting.filesystemobject")
x = new ActiveXObject("wscript.shell")
b = x.exec('findstr /b \"' + WScript.Arguments(0) + '\" build\\DISPLAY.CONF')
c = a.createtextfile("build\\search.txt")

while (!b.stdout.atendofstream)
{
  d = b.stdout.readline()
  c.writeline(d.substr(d.indexOf(",") + 1))
}

c.close()
x.run('cscript /nologo bin\\buildokvs.js build\\search.txt ' + WScript.Arguments(1), 0, 1)
