#!/bin/bash

# run from project root directory

fatal_error() {
    echo "$1" "$2"
    exit 1
}

check_slideshow() {
    [ -f "$1" ] ||
        fatal_error "Can't find slideshow" "$1"
    cat "$1" |
        grep -v "^#" |
        grep -v "^\[" |
        grep -v "^$" |
        while read ssline; do
            IFS="=" read -r filename gamename <<< "$ssline"
            if [ -z "$gamename" ]; then
                gamename=$filename
            fi
            [ -f "$2"/"$filename" ] ||
                fatal_error "Can't find screenshot" "$filename"
            grep "^$gamename$" /tmp/games >/dev/null ||
                fatal_error "Screenshot links to non-existent game" "$gamename"
        done
}

# fatal error if an attract mode module is listed more than once
dupes=$(cat res/ATTRACT.CONF |
    grep -v "^#" |
    grep -v "^$" |
    sort |
    uniq -d)
if [[ $dupes ]]; then
    fatal_error "Duplicate ATTRACT.CONF module:" "$dupes"
fi

cat res/GAMES.CONF |
    grep -v "^#" |
    grep -v "^\[" |
    grep -v "^$" |
    cut -d"," -f2 |
    cut -d"=" -f1 > /tmp/games

# warn about unused self-running demos
cat res/DEMO/_FileInformation.txt |
    grep "Type(06)" |
    grep -v "SPCARTOON" |
    cut -d"=" -f1 |
    while read f; do
        grep "$f=0" res/ATTRACT.CONF >/dev/null || echo "unused demo: $f";
    done

# warn about unused slideshows
cd res/SS
for f in *.CONF; do
    grep "$f" ../ATTRACT.CONF >/dev/null || echo "unused slideshow: $f";
done
cd ../..

cat res/ATTRACT.CONF |
    grep "=" |
    grep -v "^#" |
    while read line; do
        IFS="=" read -r module_name module_type <<< "$line"
#        echo "$module_name" "$module_type"
        if [ "$module_type" = "0" ]; then
            [ -f res/DEMO/"$module_name" ] ||
                [ "${module_name%???}" = "SPCARTOON" ] ||
                fatal_error "Can't find demo" $module_name
        elif [ "$module_type" = "1" ]; then
            check_slideshow res/SS/"$module_name" res/TITLE.HGR/
        elif [ "$module_type" = "2" ]; then
            check_slideshow res/SS/"$module_name" res/ACTION.HGR/
        elif [ "$module_type" = "3" ]; then
            check_slideshow res/SS/"$module_name" res/TITLE.DHGR/
        elif [ "$module_type" = "4" ]; then
            check_slideshow res/SS/"$module_name" res/ACTION.DHGR/
        elif [ "$module_type" = "5" ]; then
            check_slideshow res/SS/"$module_name" res/ARTWORK.SHR/
        elif [ "$module_type" = "6" ]; then
            check_slideshow res/SS/"$module_name" res/ACTION.GR/
        else
            fatal_error "Unknown module type" $module_type
        fi
    done

#rm -f /tmp/games
