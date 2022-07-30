#!/bin/bash

# flags
# -a  append to data file (default off = truncate)
# -p  pad sizes within data file to next block size (default off)

# parameters
# stdin - input containing list of effects (probably FX.CONF or DFX.CONF)
# stdout - binary OKVS data structure
# 1 - output filename for data file
# 2 - input directory of files to merge into data file
# 3 - (optional) output filename for log of key,offset,size

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

if [ "${#3}" -ne "0" ]; then
    rm -f "$3"
    touch "$3"
fi

# if there is a file called "STANDARD" in the input directory, add it now
# because we will reuse it for any files that don't exist
if [ -f "$2"/STANDARD ]; then
    standardoffset=$(wc -c < "$1")
    standardsize=$(wc -c < "$2/STANDARD")
    cat "$2"/STANDARD >> "$1"
fi

# make temp file with list of lines that contain keys
records=$(mktemp)
tr -d "\r" | awk '!/^$|^#|^\[/' > "$records"

# make temp assembly source file that represents the binary OKVS data structure
source=$(mktemp)
(echo "*=0"                            # dummy program counter for assembler
 echo "!le16 $(wc -l <"$records"), 0"  # OKVS header
 while IFS="=" read -r key value; do
     echo "!byte ${#key}+7"            # OKVS record length
     echo "!byte ${#key}"              # OKVS key length
     echo "!text \"$key\""             # OKVS key
     if [ ! -e "$2/$key" ]; then       # if file does not exist, use standard offset and size
         offset="$standardoffset"
         size="$standardsize"
     else                              # otherwise calculate offset and size from file and options
         offset=$(wc -c < "$1")
         size=$(wc -c < "$2/$key")
         if [ "$pad" = true ]; then
             # If offset+size does not cross a block boundary, use file's true size.
             # Otherwise, round up size to the next block boundary.
             # This padding does not get added to the file; it is just an
             # optimization to avoid a partial copy on the last block read.
             if [ $(($offset / 512)) -ne $((($offset + $size) / 512)) ]; then
                 size=$(((($offset + $size + 511) & -512) - $offset))
             fi
         fi
         cat "$2/$key" >> "$1"         # append this file to the end of the merged data file
     fi
     echo "!be24 $offset"
     echo "!le16 $size"
     [ "${#3}" -ne "0" ] && echo "$key,$offset,$size" >> "$3"
 done < "$records") > "$source"

# assemble temp source file into binary OKVS data structure, then output that
out=$(mktemp)
acme -o "$out" "$source"
cat "$out"

# clean up
rm "$out"
rm "$source"
rm "$records"
