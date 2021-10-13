#!/bin/bash

# run from project root directory

# parameters
# 1 - input filename of text file containing list of games (probably GAMES.CONF)
# 2 - output filename for index file
# 3 - output filename for merged-gamehelp file
# 4 - input directory of gamehelp files

# make temp file with list of game filenames
records=$(mktemp)
grep "," < "$1" | grep -v "^#" | cut -d"," -f2 | cut -d"=" -f1 | sort > "$records"

# first help text is the 'TODO' placeholder screen
cp "$4"/STANDARD "$3"
standardsize=$(wc -c < "$3")

# make temp assembly source file that represents the binary OKVS data structure
source=$(mktemp)
(echo "*=0"                            # dummy program counter for assembler
 echo "!le16 $(wc -l <"$records"), 0"  # OKVS header
 while read -r key; do
     echo "!byte ${#key}+7"            # OKVS record length
     echo "!byte ${#key}"              # OKVS key length
     echo "!text \"$key\""             # OKVS key (effect name)
     if [ -f "$4/$key" ]; then
         offset=$(wc -c < "$3")
         echo "!be24 $offset"          # offset into merged-gamehelp file (3-byte big-endian)
         # If offset+size does not cross a block boundary, use the size.
         # Otherwise, round up size to the next block boundary.
         # This padding does not get added to the file; it is just an
         # optimization to avoid a partial copy on the last block read.
         echo -n "!le16 "
         size=$(wc -c < "$4/$key")
         if [ $(($offset / 512)) -eq $((($offset + $size) / 512)) ]; then
             echo "$size"
         else
             echo "$(((($offset + $size + 511) & -512) - $offset))"
         fi
         cat "$4/$key" >> "$3"         # add this gamehelp to the merged-gamehelp file
     else
         echo "!be24 0"                # if game has no help, reuse placeholder at offset 0
         echo "!le16 $standardsize"    # and the size of the placeholder text
     fi
 done < "$records") > "$source"

# assemble temp source file to create binary OKVS data structure
acme -o "$2" "$source"

# clean up
rm "$source"
rm "$records"
