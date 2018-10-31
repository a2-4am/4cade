kMap = [0x00,
        0x0E,
        0x0D,
        0x0C,
        0x0B,
        0x0A,
        0x09,
        0x08,
        0x07,
        0x06,
        0x05,
        0x04,
        0x03,
        0x02,
        0x01,
        0x0F
       ]

a = new ActiveXObject("scripting.filesystemobject")
for (b = new Enumerator(a.GetFolder(WScript.Arguments(0)).files); !b.atEnd(); b.moveNext())
{
    if (a.GetExtensionName(b.item()).toLowerCase() == "dsk")
    {
        fi = a.opentextfile(b.item())
        fo = a.createtextfile(WScript.Arguments(1)+"\\"+a.GetBaseName(b.item())+".po", 1)
        for (track = 0; track < 0x23; ++track)
        {
            sectors = new Array(0x10)
            for (dos_sector = 0; dos_sector < 0x10; ++dos_sector)
            {
                sectors[kMap[dos_sector]] = fi.read(256)
            }
            for (dos_sector = 0; dos_sector < 0x10; ++dos_sector)
            {
                fo.write(sectors[dos_sector])
            }
        }
    }
}
