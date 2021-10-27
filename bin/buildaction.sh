#!/bin/bash

# make temp file with just the key/value pairs (strip blank lines, comments, eof marker)
records=$(mktemp)
awk '!/^$|^#|^\[/' > "$records"

# make temp assembly source file that represents the binary OKVS data structure
source=$(mktemp)
(echo "*=0"                            # dummy program counter for assembler
 echo "!le16 $(wc -l <"$records"), 0"  # OKVS header
 while IFS="=" read -r key value; do
     [ -n "$value" ] && filename="$value" || filename="$key"
     displayname=$(awk -F= '/,'"$filename"'=/ { print $2 }' "$1")
     echo "!byte ${#key}+${#value}+${#displayname}+4"  # OKVS record length
     echo "!byte ${#key}"              # OKVS key length
     echo "!text \"$key\""             # OKVS key
     echo "!byte ${#value}"            # OKVS value length
     echo "!text \"$value\""           # OKVS value
     echo "!byte ${#displayname}"
     echo "!text \"$displayname\""
 done < "$records") > "$source"

# assemble temp source file into binary OKVS data structure, then output that
out=$(mktemp)
acme -o "$out" "$source"
cat "$out"

# clean up
rm "$out"
rm "$source"
rm "$records"
