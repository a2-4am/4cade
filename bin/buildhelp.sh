#!/bin/bash

# run from project root directory

# parameters
# 1 - input filename of text file containing list of games (probably GAMES.CONF)
# 2 - output filename for index file
# 3 - output filename for merged-gamehelp file

# make temp file with list of game filenames
records=$(mktemp)
grep "," < "$1" | grep -v "^#" | cut -d"," -f2 | cut -d"=" -f1 | sort > "$records"

# first help text is the 'TODO' placeholder screen
cp res/GAMEHELP/STANDARD "$3"

# make temp assembly source file that represents the binary OKVS data structure
source=$(mktemp)
(echo "*=0"                            # dummy program counter for assembler
 echo "!le16 $(wc -l <"$records"), 0"  # OKVS header
 while read -r key; do
     echo "!byte ${#key}+5"            # OKVS record length
     echo "!byte ${#key}"              # OKVS key length
     echo "!text \"$key\""             # OKVS key (effect name)
     if [ -f "res/GAMEHELP/$key" ]; then
         echo "!be24 $(wc -c <"$3")"   # value (3-byte big-endian offset into merged-gamehelp file)
         cat res/GAMEHELP/"$key" >> "$3"
     else
         echo "!be24 0"                # if game has no help, reuse placeholder at offset 0
     fi
 done < "$records") > "$source"

# assemble temp source file to create binary OKVS data structure
acme -o "$2" "$source"

# clean up
rm "$source"
rm "$records"
