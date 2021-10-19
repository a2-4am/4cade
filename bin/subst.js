a = new ActiveXObject("scripting.filesystemobject")

if (!a.fileexists(WScript.Arguments(1)) || a.getfile(WScript.Arguments(1)).datelastmodified < a.getFile(WScript.Arguments(0)).datelastmodified)
{
  z = a.opentextfile(WScript.Arguments(0))
  d = a.createtextfile(WScript.Arguments(1))

  String.prototype.replaceWith = function(q)
  {
    return this.substr(0, c) + String.fromCharCode(q) + this.substr(c + 1)
  }

  while (!z.atendofstream)
  {
    b = z.readline()

    c = b.search(/\[eof\]/)

    if (c > -1)
    {
      break
    }

    c = b.search(/\r\n/)

    if (c > -1)
    {
      b = b.substr(0, c)
    }

    for (c = 0; c < b.length; c++)
    {
      if (b.charAt(c) == '*')
      {
        b = b.replaceWith(16)
      }
      else if (b.charAt(c) == '~')
      {
        b = b.replaceWith(17)
      }
      else if (b.charAt(c) == '<')
      {
        b = b.replaceWith(8)
      }
      else if (b.charAt(c) == '>')
      {
        b = b.replaceWith(21)
      }
      else if (b.charAt(c) == '$')
      {
        b = b.replaceWith(14)
      }
      else if (b.charAt(c) == '%')
      {
        b = b.replaceWith(15)
      }
    }

    d.write(String.fromCharCode(b.length) + b)
  }

  d.write(String.fromCharCode(255))
}
