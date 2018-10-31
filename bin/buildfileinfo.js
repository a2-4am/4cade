a = new ActiveXObject("scripting.filesystemobject")
fileinfo = ""
for (b = new Enumerator(a.GetFolder(WScript.Arguments(0)).files); !b.atEnd(); b.moveNext())
{
    fileinfo += "\r\n" + b.item().Name.toUpperCase() + "=Type(06),AuxType(4000),Access(C3)"
}
a.createtextfile(WScript.Arguments(0)+"\\_FileInformation.txt", 1).write(fileinfo.substring(2))
