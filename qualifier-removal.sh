#!/bin/bash

# https://github.com/generalist/wikidata-misc/blob/master/qualifier-removal.sh

# this script is a wrapper for wikibase-cli to remove a set of qualifiers
# (made available because it can be quite tricky to handle hashes)

# takes list of statement IDs and writes a script to remove qualifiers
# statement IDs are as pulled down from WDQS, eg wds:Q1827902-6706334E-D27E-4F4B-B6DA-ABE7544DF11C
# and located in file quallist

# P582 is hardcoded as this is the expected use case

cat quallist | sed 's/wds:\(Q[0-9]*\)-/\1$/g' > qualtemp

echo -e "echo '" > qualbatch

for p in `cat qualtemp` ; do

hash=`wb data $p | jq -r '.qualifiers.P582[0].hash'`

echo -e $p " - " $hash

echo -e "[\""$p"\", \""$hash"\"]" >> qualbatch

done

echo -e "' | wd remove-qualifier --batch -s \"removing P582 qualifiers\"" >>qualbatch

rm qualtemp

echo "ready! now run qualbatch manually"

# bash qualbatch
# commented out to allow human review
