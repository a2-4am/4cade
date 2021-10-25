#!/bin/bash

# make temp file with just the key/value pairs (strip blank lines, comments, eof marker)
records=$(mktemp)
awk '!/^$|^#|^\[/' > "$records"

# make temp assembly source file that represents the binary OKVS data structure
source=$(mktemp)
(echo "*=0"                            # dummy program counter for assembler
 echo "!le16 $(wc -l <"$records"), 0"  # OKVS header
 while IFS="=" read -r key value; do
     dhgr=$(echo "$key" | cut -c3)     # 'has DHGR title screen' flag (0 or 1)
     cheat=$(echo "$key" | cut -c4)    # 'cheat category' (0..5)
     key=$(echo "$key" | cut -d"," -f2)
     echo "!byte ${#key}+${#value}+4"  # OKVS record length
     echo "!byte ${#key}"              # OKVS key length
     echo "!text \"$key\""             # OKVS key
     echo "!byte ${#value}+1"          # OKVS value length
     echo "!text \"$value\""           # OKVS value
     echo "!byte $((dhgr*128))+$cheat"
 done < "$records") > "$source"

# assemble temp source file into binary OKVS data structure, then output that
out=$(mktemp)
acme -o "$out" "$source"
cat "$out"

# clean up
rm "$out"
rm "$source"
rm "$records"
