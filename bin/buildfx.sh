#!/bin/bash

:>| "$3"
records=$(mktemp)
grep -v "^$" < "$1" | grep -v "^#" | grep -v "^\[" > "$records"
source=$(mktemp)
(echo "*=0"
 echo "!le16 $(wc -l <"$records"), 0"
 while read -r key; do
     echo "!byte ${#key}+5"
     echo "!byte ${#key}"
     echo "!text \"$key\""
     echo "!be24 $(wc -c <"$3")"
     cat "build/FX/$key" >> "$3"
 done < "$records") > "$source"
acme -o "$2" "$source"
rm "$source"
rm "$records"
