a = new ActiveXObject("scripting.filesystemobject")
for (b = new Enumerator(a.GetFolder(WScript.Arguments(0)).files); !b.atEnd(); b.moveNext())
{
    if (a.GetExtensionName(b.item()).toLowerCase() == "po")
    {
        new ActiveXObject("WScript.Shell").run("cadius EXTRACTVOLUME " + '"' + b.item() + '"' + " build/X/", 0)
    }
}
