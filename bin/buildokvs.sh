#!/bin/bash

# run from project root directory

# make temp file with just the key/value pairs (strip blank lines, comments, eof marker)
records=$(mktemp)
grep -v "^$" < "$1" | grep -v "^#" | grep -v "^\[" > "$records"

# make temp assembly source file that represents the binary OKVS data structure
source=$(mktemp)
(echo "*=0"                            # dummy program counter for assembler
 echo "!le16 $(wc -l <"$records"), 0"  # OKVS header
 while IFS="=" read -r key value; do
     echo "!byte ${#key}+${#value}+3"  # OKVS record length
     echo "!byte ${#key}"              # OKVS key length
     echo "!text \"$key\""             # OKVS key
     echo "!byte ${#value}"            # OKVS value length
     echo "!text \"$value\""           # OKVS value
 done < "$records") > "$source"

# assemble temp source file to create binary OKVS data structure
acme -o "$2" "$source"

# clean up
rm "$source"
rm "$records"
