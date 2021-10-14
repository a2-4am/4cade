#!/bin/bash

# run from project root directory

# parameters
# 1 - input filename of text file containing list of effects (probably FX.CONF or DFX.CONF)
# 2 - output filename for index file
# 3 - output filename for merged-effects file
# 4 - input directory of (previously assembled) effects files

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
     echo "!byte ${#key}+7"            # OKVS record length
     echo "!byte ${#key}"              # OKVS key length
     echo "!text \"$key\""             # OKVS key (effect name)
     offset=$(wc -c < "$3")
     echo "!be24 $offset"              # offset into merged-effects file
     echo -n "!le16 "
     # If offset+size does not cross a block boundary, use the size.
     # Otherwise, round up size to the next block boundary.
     # This padding does not get added to the file; it is just an
     # optimization to avoid a partial copy on the last block read.
     size=$(wc -c < "$4/$key")
     if [ $(($offset / 512)) -eq $((($offset + $size) / 512)) ]; then
         echo "$size"
     else
         echo "$(((($offset + $size + 511) & -512) - $offset))"
     fi
     cat "$4/$key" >> "$3"             # add effect code into merged-effects file
                                       # (all effects were previously assembled)
 done < "$records") > "$source"

# assemble temp source file to create binary OKVS data structure
acme -o "$2" "$source"

# clean up
rm "$source"
rm "$records"
