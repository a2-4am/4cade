#!/bin/sh

# run from project root directory

cat res/games.conf |
    tr "\r" "\n" |
    grep "=" |
    grep -v "^#" |
    cut -d"," -f2 |
    cut -d"=" -f1 | \
    while read game; do
        # if I knew how to use awk, this could be O(N) instead of O(N^2)
        name=`cat res/games.conf | tr "\r" "\n" | grep "$game=" | cut -d"=" -f2`

        # initialize attract mode configuration file for this game
        echo "#\n# Attract mode for $name\n#\n" > /tmp/g

        # add DHGR title screenshot, if any
        [ -f res/title.dhgr/"$game" ] &&
            echo "TITLE.DHGR/$game=8" >> /tmp/g

        # add box art, if any
        [ -f res/artwork.shr/"$game" ] &&
            echo "ARTWORK.SHR/$game=9" >> /tmp/g

        # add DHGR action screenshots, if any
        cat res/ss/ACTDHGR*.CONF |
            tr "\r" "\n" |
            grep "$game""$" |
            cut -d"=" -f1 |
            sed -e "s/^/ACTION.DHGR\//g" |
            sed -e "s/$/=8/g" |
            sort |
            uniq >> /tmp/g

        # add HGR action screenshots, if any
        cat res/ss/ACTION*.CONF |
            tr "\r" "\n" |
            grep "$game""$" |
            cut -d"=" -f1 |
            sed -e "s/^/ACTION.HGR\//g" |
            sed -e "s/$/=7/g" |
            sort |
            uniq >> /tmp/g

        if [ "$game" == "CAPTN.GOODNIGHT" ]; then
            cat res/ss/ACTIONCAPT.CONF |
                tr "\r" "\n" |
                grep "^CAPT" |
                sed -e "s/^/ACTION.HGR\//g" |
                sed -e "s/$/=7/g" >> /tmp/g
        fi

        # add self-running demo, if any
        cat res/attract.conf |
            tr "\r" "\n" |
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
            echo "ARTWORK.SHR/POP.END=9" >> /tmp/g
        fi

        # add eof
        echo "\n[eof]" >> /tmp/g

        # change line endings
        cat /tmp/g | tr "\n" "\r" > res/attract/"$game"

        # clean up
        rm /tmp/g
    done
