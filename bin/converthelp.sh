#!/bin/sh

tr "\*\~\<\>\$\%" "\020\021\010\025\016\017" < "$1" | \
    tr -d "\r" | awk '!/^\[/ { printf "%c%s", length, $0 } END { printf "\xFF" }' > "$2"
