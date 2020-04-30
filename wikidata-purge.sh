#!/bin/bash

# https://github.com/generalist/wikidata-misc/blob/master/wikidata-purge.sh

clear
echo "This script is designed to purge all Wikidata items using a certain property, after the formatter URL has been changed."
echo ""
echo "It uses pywikibot, which should be in ~/pywikibot"
echo ""
echo "What property has been updated? Enter as Pxxxx."
read PROP
echo "Property "$PROP" set."

# clear the working files

rm ~/scripts/working/purgescript*

# now download the list

curl --header "Accept: text/tab-separated-values" https://query.wikidata.org/sparql?query=select%20%3Fitem%20%3Fedited%20where%20%7B%20%3Fitem%20wdt%3A$PROP%20%3Fid.%20%3Fitem%20schema%3AdateModified%20%3Fedited%20%7D%20order%20by%20desc%28%3Fedited%29 > ~/scripts/working/purgescript-input.tsv

cat ~/scripts/working/purgescript-input.tsv | cut -d T -f 1 | sed 's/\"//g' | sed "s/<http:\/\/www.wikidata.org\/entity\///g" | sed "s/>//g" > scripts/working/purgescript-cleaned.tsv

# work on this bit later

# echo "What day was this updated? Give it as eg 2019-10-01."
# read DATE
# echo "Date set as "$DATE" - all pages last edited before this will be purged."

# work on this bit later

# for i in `cut -f 2 ~/scripts/working/purgescript-cleaned.tsv`
# do echo $i
# echo $DATE
#   if [ "$i" \> "$DATE" ]
#     then echo "$i greater than $DATE"
#     else echo "$i less than $DATE"
#   fi
# done


cut -f 1 ~/scripts/working/purgescript-cleaned.tsv | grep Q > ~/scripts/working/purgescript-upload.tsv

TOTAL=`cat ~/scripts/working/purgescript-upload.tsv | wc -l`

echo "Purging items for $PROP - $TOTAL to be processed. Oldest is from `tail -n 1 ~/scripts/working/purgescript-cleaned.tsv | cut -f 2`"
echo "We don't recommend this if there are lots of values..."

read -p "Do you want to go ahead? " -n 1 -r
echo
echo

if [[ $REPLY =~ ^[Yy]$ ]]
then

echo "Here we go!"

for i in `cat ~/scripts/working/purgescript-upload.tsv` ;

do echo "$i to be purged"

python3 ~/pywikibot/pwb.py touch -page:$i -purge

done

else

echo "Okay - nothing done"

fi
