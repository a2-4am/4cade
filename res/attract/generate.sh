#!/bin/sh

# run from project root directory

cat res/games.conf | tr "\r" "\n" | grep "=" | grep -v "^#" | cut -d"," -f2 | cut -d"=" -f1 | \
    while read game; do
        # if I knew how to use awk, this could be O(N) instead of O(N^2)
        name=`cat res/games.conf | tr "\r" "\n" | grep "$game=" | cut -d"=" -f2`
        # initialize attract mode configuration file for this game
        echo "#\n# Attract mode for $name\n#\n" > res/attract/"$game"
        # add title screenshot for DHGR games only
        [ -f res/title.dhgr/"$game" ] && echo "TITLE.DHGR/$game=8" >> res/attract/"$game"
        # add box art, if any
        [ -f res/artwork.shr/"$game" ] && echo "ARTWORK.SHR/$game=9" >> res/attract/"$game"
        # TODO add DHGR action screenshots, if any
        # add action screenshots, if any
        cat res/ss/ACTION*.CONF | tr "\r" "\n" | grep "$game""$" | cut -d"=" -f1 | sed -e "s/^/ACTION.HGR\//g" | sed -e "s/$/=7/g" | sort >> res/attract/"$game"
        # add self-running demo, if any
        cat res/attract.conf | tr "\r" "\n" | grep "^$game=0" >> res/attract/"$game"
        # add eof
        echo "\n[eof]" >> res/attract/"$game"
    done
