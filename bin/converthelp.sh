#!/bin/sh

tr "\*\~\<\>\$\%" "\020\021\010\025\016\017" < "$1" | \
    awk '!/^\[/ { printf "%c%s", length, $0 } END { printf "\xFF" }' > "$2"
