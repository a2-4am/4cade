#!/bin/bash

# create or truncate merged-effects file
:>| "$3"

# make temp file with list of effect names
records=$(mktemp)
grep -v "^$" < "$1" | grep -v "^#" | grep -v "^\[" > "$records"

# make temp assembly source file that represents the binary OKVS data structure
source=$(mktemp)
(echo "*=0"                            # dummy program counter for assembler
 echo "!le16 $(wc -l <"$records"), 0"  # OKVS header
 while read -r key; do
     echo "!byte ${#key}+5"            # OKVS record length
     echo "!byte ${#key}"              # OKVS key length
     echo "!text \"$key\""             # OKVS key (effect name)
     echo "!be24 $(wc -c <"$3")"       # offset into merged-effects file
     cat "build/FX/$key" >> "$3"       # add effect code into merged-effects file
                                       # (all effects were previously assembled)
 done < "$records") > "$source"

# assemble temp source file to create binary OKVS data structure
acme -o "$2" "$source"

# clean up
rm "$source"
rm "$records"
