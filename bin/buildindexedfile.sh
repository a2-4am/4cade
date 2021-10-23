#!/bin/bash

# flags
# -a  append to data file (default off = truncate)
# -p  pad sizes within data file to next block size (default off)

# parameters
# stdin - input containing list of effects (probably FX.CONF or DFX.CONF)
# stdout - binary OKVS data structure
# 1 - output filename for data file
# 2 - input directory of files to merge into data file

pad=false
append=false
standardoffset=0
standardsize=0
while getopts ":ap" opt; do
    case $opt in
        a) append=true
           ;;
        p) pad=true
           ;;
    esac
done
shift $((OPTIND-1))

if [ "$append" = false ]; then
    rm -f "$1"
fi
touch "$1"

# if there is a file called "STANDARD" in the input directory, add it now
# because we will reuse it for any files that don't exist
if [ -f "$2"/STANDARD ]; then
    standardoffset=$(wc -c < "$1")
    standardsize=$(wc -c < "$2/STANDARD")
    cat "$2"/STANDARD >> "$1"
fi

# make temp file with list of lines that contain keys
records=$(mktemp)
awk '!/^$|^#|^\[/' > "$records"

# make temp assembly source file that represents the binary OKVS data structure
source=$(mktemp)
(echo "*=0"                            # dummy program counter for assembler
 echo "!le16 $(wc -l <"$records"), 0"  # OKVS header
 while IFS="=" read -r key value; do
     echo "!byte ${#key}+7"            # OKVS record length
     echo "!byte ${#key}"              # OKVS key length
     echo "!text \"$key\""             # OKVS key
     if [ -f "$2/$key" ]; then         # if file exists, determine offset and size
         offset=$(wc -c < "$1")
         echo "!be24 $offset"          # offset into merged data file
         echo -n "!le16 "
         size=$(wc -c < "$2/$key")
         if [ "$pad" = true ]; then
             # If offset+size does not cross a block boundary, use file's true size.
             # Otherwise, round up size to the next block boundary.
             # This padding does not get added to the file; it is just an
             # optimization to avoid a partial copy on the last block read.
             if [ $(($offset / 512)) -eq $((($offset + $size) / 512)) ]; then
                 echo "$size"
             else
                 echo "$(((($offset + $size + 511) & -512) - $offset))"
             fi
         else
             # Caller said never pad, so always use file's true size.
             echo "$size"
         fi
         cat "$2/$key" >> "$1"         # append this file to the end of the merged data file
     else                              # if file does not exist, reuse STANDARD file
         echo "!be24 $standardoffset"
         echo "!le16 $standardsize"
     fi
 done < "$records") > "$source"

# assemble temp source file into binary OKVS data structure, then output that
out=$(mktemp)
acme -o "$out" "$source"
cat "$out"

# clean up
rm "$out"
rm "$source"
rm "$records"
