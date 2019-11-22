#!/bin/sh

indir=$1
intype=$2
inaddress=$3
cd "$indir"
touch _FileInformation.txt
(for f in *; do
    echo "$f=Type($intype),AuxType($inaddress),Access(C3)"
 done) >> _FileInformation.txt
