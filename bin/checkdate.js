a = new ActiveXObject("scripting.filesystemobject")
WScript.quit(Math.abs(!a.fileexists(WScript.Arguments(0)) || a.getfile(WScript.Arguments(0)).datelastmodified < a.getFile(WScript.Arguments(1)).datelastmodified))
