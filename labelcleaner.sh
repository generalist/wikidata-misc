#!/bin/bash

# this is the labelcleaner tool for wikidata, a wrapper around wikibase-cli
# it takes a set of items in source.tsv (one column of QIDs) and a language code
# and then systematically blanks *all* labels, descriptions, and aliases which exist
# for those languages on those items
#
# https://github.com/generalist/wikidata-misc/blob/master/labelcleaner.sh
#
# to just do any one of the three, comment out the relevant bits


echo "Items for cleanup should be in cleanup.tsv"
echo "The first column must be QIDs eg Q12345; any other columns are ignored"

echo "What language would you like to clean up?"
echo "Give the standard code in lowercase - en English, fr French, sco Scots, etc."

read LANG

echo "Language "$LANG" set"

echo "There are "`cut -f 1 cleanup.tsv | grep Q | sort | uniq | wc -l`" distinct Q-items in the list"

echo "echo '" > batch-$LANG-labels
echo "echo '" > batch-$LANG-aliases
echo "echo '" > batch-$LANG-descriptions

cut -f 1 cleanup.tsv | grep Q | sort | uniq | sed 's/^/[ "/g' | sed 's/$/", "sco", " " ]/g' >> batch-$LANG-labels
cut -f 1 cleanup.tsv | grep Q | sort | uniq | sed 's/^/[ "/g' | sed 's/$/", "sco", " " ]/g' >> batch-$LANG-aliases
cut -f 1 cleanup.tsv | grep Q | sort | uniq | sed 's/^/[ "/g' | sed 's/$/", "sco", " " ]/g' >> batch-$LANG-descriptions


echo "' | wd set-label --batch -s \"label cleanup in $LANG\" --no-exit-on-error > log-$LANG-labels 2> log-$LANG-labels-errors" >> batch-$LANG-labels
echo "' | wd set-description --batch -s \"description cleanup in $LANG\" --no-exit-on-error > log-$LANG-descriptions 2> log-$LANG-descriptions-errors" >> batch-$LANG-descriptions
echo "' | wd set-alias --batch -s \"alias cleanup in $LANG\" --no-exit-on-error > log-$LANG-aliases 2> log-$LANG-aliases-errors" >> batch-$LANG-aliases

echo "Running labels..."
bash batch-$LANG-labels
echo "Labels done!"
rm  batch-$LANG-labels
echo "Running descriptions..."
bash batch-$LANG-descriptions
echo "Descriptions done!"
rm batch-$LANG-descriptions
echo "Running aliases..."
bash batch-$LANG-aliases
echo "Aliases done!"
rm batch-$LANG-aliases
echo "Logs are in log-$LANG-labels, and log-$LANG-labels-errors, etc. These can be deleted."

