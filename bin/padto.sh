#!/bin/bash

totalsize=$1
outfile=$2

[[ "$OSTYPE" == "linux-gnu" ]] \
    && filesize=$(stat -c "%s" "$outfile") \
    || filesize=$(stat -f "%z" "$outfile")

padsize=$((512-$filesize))
dd if=/dev/zero bs=1 count=$padsize >> "$outfile"
