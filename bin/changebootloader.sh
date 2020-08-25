#!/bin/sh

dd of="$1" bs=1 count=512 conv=notrunc < "$2"
