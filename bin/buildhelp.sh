#!/bin/bash

# run from project root directory

games=`cat res/GAMES.CONF | grep "," | grep -v "^#" | cut -d"," -f2 | cut -d"=" -f1 | sort`
cat res/GAMEHELP/STANDARD > "$1"
for c in {A..Z}; do
    echo -e "group$c"
    echo "$games" | grep "^$c" | while read game; do
        echo "!byte ${#game}"
        echo "!text \"$game\""
        if [ -f "res/GAMEHELP/$game" ]; then
            offset=$(wc -c <"$1")
            echo "!be24 $offset"
            cat res/GAMEHELP/"$game" >> "$1"
        else
            echo "!be24 0"
        fi
    done
done > "$2"
