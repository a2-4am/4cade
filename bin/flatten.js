a = new ActiveXObject("scripting.filesystemobject")
x = new ActiveXObject("wscript.shell")

for (b = new Enumerator(a.GetFolder("build\\X").subfolders); !b.atEnd(); b.moveNext())
{
  for (c = new Enumerator(b.item().subfolders); !c.atEnd(); c.moveNext())
  {
    x.run('cmd /c move build\\X\\' + b.item().name + '\\' + c.item().name + ' build\\X', 0, 1)
  }

  x.run('cmd /c move build\\X\\' + b.item().name + '\\* build\\X', 0, 1)
  x.run('cmd /c rd build\\X\\' + b.item().name, 0, 1)
}
