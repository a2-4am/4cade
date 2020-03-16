#!/bin/sh

# run from project root directory

fatal_error() {
    echo "$1" "$2"
    exit 1
}

check_title_slideshow() {
    [ -f "$1" ] ||
        fatal_error "Can't find HGR title slideshow" "$1"
    cat "$1" |
        tr "\r" "\n" |
        grep -v "^#" |
        grep -v "^\[" |
        grep -v "^$" |
        while read ssline; do
            [ -f "$2"/"$ssline" ] ||
                fatal_error "Can't find HGR title screenshot" "$ssline"
        done
}

check_action_slideshow() {
    [ -f "$1" ] ||
        fatal_error "Can't find HGR action slideshow" "$1"
    cat "$1" |
        tr "\r" "\n" |
        grep -v "^#" |
        grep -v "^\[" |
        grep -v "^$" |
        while read ssline; do
            IFS="=" read -r filename gamename <<< "$ssline"
            if [ -z "$gamename" ]; then
                gamename=$filename
            fi
            [ -f "$2"/"$filename" ] ||
                fatal_error "Can't find HGR action screenshot" "$filename"
            grep "^$gamename$" /tmp/games >/dev/null ||
                fatal_error "HGR action screenshot links to non-existent game" "$gamename"
        done
}

cat res/GAMES.CONF |
    tr "\r" "\n" |
    grep -v "^#" |
    grep -v "^\[" |
    grep -v "^$" |
    cut -d"," -f2 |
    cut -d"=" -f1 > /tmp/games

cat res/ATTRACT.CONF |
    tr "\r" "\n" |
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
            check_title_slideshow res/SS/"$module_name" res/TITLE.HGR/
        elif [ "$module_type" = "2" ]; then
            check_action_slideshow res/SS/"$module_name" res/ACTION.HGR/
        elif [ "$module_type" = "3" ]; then
            check_title_slideshow res/SS/"$module_name" res/TITLE.DHGR/
        elif [ "$module_type" = "4" ]; then
            check_action_slideshow res/SS/"$module_name" res/ACTION.DHGR/
        elif [ "$module_type" = "5" ]; then
            check_title_slideshow res/SS/"$module_name" res/ARTWORK.SHR/
        elif [ "$module_type" = "6" ]; then
            check_action_slideshow res/SS/"$module_name" res/ACTION.GR/
        else
            fatal_error "Unknown module type" $module_type
        fi
    done

#rm -f /tmp/games
