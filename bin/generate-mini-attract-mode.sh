#!/bin/sh

# run from project root directory

cat res/GAMES.CONF |
    grep "," |
    grep -v "^#" |
    cut -d"," -f2 |
    cut -d"=" -f1 | \
    while read game; do
        # if I knew how to use awk, this could be O(N) instead of O(N^2)
        name=`cat res/GAMES.CONF | grep ",$game=" | cut -d"=" -f2`

        # initialize attract mode configuration file for this game
        echo "#\r# Attract mode for $name\r#\r" > /tmp/g

        # add box art, if any
        [ -f res/ARTWORK.SHR/"$game" ] &&
            echo "ARTWORK.SHR/$game=C" >> /tmp/g

        # add DHGR action screenshots, if any
        cat res/SS/ACTDHGR*.CONF |
            egrep "(^|=)""$game""$" |
            cut -d"=" -f1 |
            sed -e "s/^/ACTION.DHGR\//g" |
            sed -e "s/$/=B/g" |
            sort |
            uniq >> /tmp/g

        # add HGR action screenshots, if any
        cat res/SS/ACTION*.CONF |
            egrep "(^|=)""$game""$" |
            cut -d"=" -f1 |
            sed -e "s/^/ACTION.HGR\//g" |
            sed -e "s/$/=A/g" |
            sort |
            uniq >> /tmp/g

        # add GR action screenshots, if any
        cat res/SS/ACTGR*.CONF |
            egrep "(^|=)""$game""$" |
            cut -d"=" -f1 |
            sed -e "s/^/ACTION.GR\//g" |
            sed -e "s/$/=D/g" |
            sort |
            uniq >> /tmp/g

        # add self-running demo, if any
        cat res/ATTRACT.CONF |
            grep "^$game=0" >> /tmp/g

        if [ "$game" == "SPARE.CHANGE" ]; then
            echo "SPCARTOON.1=0" >> /tmp/g
            echo "SPCARTOON.2=0" >> /tmp/g
            echo "SPCARTOON.3=0" >> /tmp/g
            echo "SPCARTOON.4=0" >> /tmp/g
            echo "SPCARTOON.5=0" >> /tmp/g
            echo "SPCARTOON.6=0" >> /tmp/g
        fi

        if [ "$game" == "PRINCEUNP" ]; then
            echo "ARTWORK.SHR/POP.END=C" >> /tmp/g
        fi

        # add eof
        echo "\r[eof]" >> /tmp/g

        cat /tmp/g > res/ATTRACT/"$game"

        # clean up
        rm /tmp/g
    done
