a = new ActiveXObject("scripting.filesystemobject")
b = WScript.Arguments(0).lastIndexOf('\\') + 1
c = WScript.Arguments(0).substr(0, b)
d = WScript.Arguments(0).substr(b)
if (d.substr(0, 2) == '*.')
{
    d = d.substr(2)
}
for (b = new Enumerator(a.GetFolder(c).files); !b.atEnd(); b.moveNext())
{
    if ((d == '*') || (d == b.item().name) || (d == a.getextensionname(b.item().name)))
    {
        e = a.opentextfile(c + b.item().name).readall()
        e = e.replace(/\r\n/g, "\n")
        a.createtextfile(c + b.item().name).write(e)
    }
}
