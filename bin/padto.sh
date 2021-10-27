#!/bin/bash

# zero-pads $1 to a multiple of 512 bytes, in place

dd if=/dev/null of="$1" bs=1 count=1 seek="$((($(wc -c < "$1") + 511) & -512))" 2>/dev/null
