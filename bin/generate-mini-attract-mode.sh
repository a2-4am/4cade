#!/bin/sh

# run from project root directory

cat res/games.conf | tr "\r" "\n" | grep "=" | grep -v "^#" | cut -d"," -f2 | cut -d"=" -f1 | \
    while read game; do
        # if I knew how to use awk, this could be O(N) instead of O(N^2)
        name=`cat res/games.conf | tr "\r" "\n" | grep "$game=" | cut -d"=" -f2`
        # initialize attract mode configuration file for this game
        echo "#\n# Attract mode for $name\n#\n" > /tmp/g
        # add title screenshot for DHGR games only
        [ -f res/title.dhgr/"$game" ] && echo "TITLE.DHGR/$game=8" >> /tmp/g
        # add box art, if any
        [ -f res/artwork.shr/"$game" ] && echo "ARTWORK.SHR/$game=9" >> /tmp/g
        # TODO add DHGR action screenshots, if any
        # add action screenshots, if any
        cat res/ss/ACTION*.CONF | tr "\r" "\n" | grep "$game""$" | cut -d"=" -f1 | sed -e "s/^/ACTION.HGR\//g" | sed -e "s/$/=7/g" | sort | uniq >> /tmp/g
        # add self-running demo, if any
        cat res/attract.conf | tr "\r" "\n" | grep "^$game=0" >> /tmp/g
        # add eof
        echo "\n[eof]" >> /tmp/g
        cat /tmp/g | tr "\n" "\r" > res/attract/"$game"
        rm /tmp/g
    done
