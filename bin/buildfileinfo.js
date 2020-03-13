a = new ActiveXObject("scripting.filesystemobject")
fileinfo = ""
for (b = new Enumerator(a.GetFolder(WScript.Arguments(0)).files); !b.atEnd(); b.moveNext())
{
    if (b.item().Name.toUpperCase() != "_FILEINFORMATION.TXT")
    {
        fileinfo += "\r\n" + b.item().Name.toUpperCase() + "=Type(" + WScript.Arguments(1) + "),AuxType(" + WScript.Arguments(2) + "),Access(C3)"
    }
}
fileinfo += "\r\n" + "_FileInformation.txt=Type(" + WScript.Arguments(1) + "),AuxType(" + WScript.Arguments(2) + "),Access(C3)\r\n"
a.createtextfile(WScript.Arguments(0)+"\\_FILEINFORMATION.TXT", 1).write(fileinfo.substring(2))
