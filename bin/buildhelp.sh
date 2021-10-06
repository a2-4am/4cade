#!/bin/bash

# run from project root directory

games=$(grep "," res/GAMES.CONF | grep -v "^#" | cut -d"," -f2 | cut -d"=" -f1 | sort)
cp res/GAMEHELP/STANDARD "$1"
for c in {A..Z}; do
    echo "group$c"
    echo "$games" | grep "^$c" | while read -r game; do
        echo "!byte ${#game}"
        echo "!text \"$game\""
        if [ -f "res/GAMEHELP/$game" ]; then
            echo "!be24 $(wc -c <"$1")"
            cat res/GAMEHELP/"$game" >> "$1"
        else
            echo "!be24 0"
        fi
    done
done > "$2"
