#!/bin/bash

games=$(cat "$1")

# make temp file with just the key/value pairs (strip blank lines, comments, eof marker)
records=$(mktemp)
awk '!/^$|^#|^\[/' > "$records"

# make temp assembly source file that represents the binary OKVS data structure
source=$(mktemp)
(echo "*=0"                            # dummy program counter for assembler
 echo "!le16 $(wc -l <"$records"), 0"  # OKVS header
 while read -r filename; do
     line=$(echo "$games" | awk '/,'"$filename"'=/')
     needsjoystick=$(echo "$line" | cut -c1) # 'requires joystick' flag (0 or 1)
     needs128k=$(echo "$line" | cut -c2)    # 'requires 128K' flag (0 or 1)
     echo "!byte ${#filename}+3"       # OKVS record length
     echo "!byte ${#filename}"         # OKVS key length
     echo "!text \"$filename\""        # OKVS key
     [ -z "$line" ] && \
         echo "!byte 0" || \
         echo "!byte $((needsjoystick*128))+$((needs128k*64))"
 done < "$records") > "$source"

# assemble temp source file into binary OKVS data structure, then output that
out=$(mktemp)
acme -o "$out" "$source"
cat "$out"

# clean up
rm "$out"
rm "$source"
rm "$records"
