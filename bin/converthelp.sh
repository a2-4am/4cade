#!/bin/sh

tr "\*\~\<\>\$$\%" "\020\021\010\025\016\017" < "$1" | sed '/^\[/d' > "$2"
dd if=/dev/zero bs=1 count=1 2>/dev/null >> "$2"
