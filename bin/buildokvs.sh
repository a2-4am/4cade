#!/bin/bash

# run from project root directory

records=$(mktemp)
grep -v "^$" < "$1" | grep -v "^#" | grep -v "^\[" > "$records"
source=$(mktemp)
(echo "*=0"
 echo "!le16 $(wc -l <"$records"), 0"
 while IFS="=" read -r key value; do
     echo "!byte ${#key}+${#value}+3"
     echo "!byte ${#key}"
     echo "!text \"$key\""
     echo "!byte ${#value}"
     echo "!text \"$value\""
 done < "$records") > "$source"
acme -o "$2" "$source"
rm "$source"
rm "$records"
