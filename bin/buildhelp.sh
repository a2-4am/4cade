#!/bin/bash

# run from project root directory

# make in-memory array of game filenames
games=$(grep "," res/GAMES.CONF | grep -v "^#" | cut -d"," -f2 | cut -d"=" -f1 | sort)

# first help text is the 'TODO' placeholder screen
cp res/GAMEHELP/STANDARD "$1"
for c in {A..Z}; do
    echo "group$c"                                  # group games by first letter
    for game in $(echo "$games" | grep "^$c"); do
        echo "!byte ${#game}"                       # key length
        echo "!text \"$game\""                      # key (game filename)
        if [ -f "res/GAMEHELP/$game" ]; then
            echo "!be24 $(wc -c <"$1")"             # value (3-byte big-endian offset into merged help file)
            cat res/GAMEHELP/"$game" >> "$1"
        else
            echo "!be24 0"                          # if game has no help, reuse placeholder at offset 0
        fi
    done
done > "$2"
