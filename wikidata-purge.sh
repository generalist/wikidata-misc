#!/bin/bash

# https://github.com/generalist/wikidata-misc/blob/master/wikidata-purge.sh

# under no server lag, this script purges ~5 items/minute; if maxlag increases, it starts slowing down.
# if maxlag is severe, requests will time out and items will *not* be purged and these are not yet logged.
# under testing at low-moderate maxlag, it purges 3-4/minute and no more than ~2% of items timed out

clear
echo "This script is designed to purge all Wikidata items using a certain property, after the formatter URL has been changed."
echo ""
echo "It uses pywikibot, which should be in ~/pywikibot"
echo ""
echo "--//--"
echo ""
echo "What property has been updated? Enter as Pxxxx."
read PROP
echo "Property "$PROP" set."
echo ""
echo "NOTE: The edit to the formatter URL must be at least 24 hours ago, otherwise the internal cache will still have the old data and formatting will not achieve anything."
echo ""
echo "--//--"
echo ""
echo "What date was it changed on? Enter as eg 2020-01-20."
read DATE1
echo "Date set as $DATE1 - all pages edited before this will be purged"
echo ""

DATE2=$DATE1"T23:59:59Z"

echo $DATE2

# clear the working files

rm ~/scripts/working/purgescript*

# now download the list

curl --header "Accept: text/tab-separated-values" https://query.wikidata.org/sparql?query=select%20distinct%20%3Fitem%20%3Fedited%20where%20%7B%20%3Fitem%20wdt%3A$PROP%20%3Fid%20.%20%3Fitem%20schema%3AdateModified%20%3Fedited%20.%20filter%20%28%3Fedited%20%3C%3D%20%22$DATE2%22%5E%5Exsd%3AdateTime%29%20%7D%20order%20by%20asc%28%3Fedited%29 > ~/scripts/working/purgescript-input.tsv

cat ~/scripts/working/purgescript-input.tsv | cut -d T -f 1 | sed 's/\"//g' | sed "s/<http:\/\/www.wikidata.org\/entity\///g" | sed "s/>//g" > scripts/working/purgescript-cleaned.tsv



cut -f 1 ~/scripts/working/purgescript-cleaned.tsv | grep Q > ~/scripts/working/purgescript-upload.tsv

TOTAL=`cat ~/scripts/working/purgescript-upload.tsv | wc -l`

echo "Purging items for $PROP - $TOTAL to be processed. Oldest is from `head -n 2 ~/scripts/working/purgescript-cleaned.tsv | tail -n 1 | cut -f 2`"
echo "We don't recommend this if there are lots of values..."

read -p "Do you want to go ahead? " -n 1 -r
echo
echo

if [[ $REPLY =~ ^[Yy]$ ]]
then

echo "Here we go!"

python3 ~/pywikibot/pwb.py touch -page:Property:$PROP -purge

echo "Property purged (to be safe)"

for i in `cat ~/scripts/working/purgescript-upload.tsv` ;

do echo "$i to be purged"

python3 ~/pywikibot/pwb.py touch -page:$i -purge

echo "$i purged" >> ~/scripts/working/purgescript-log-$PROP

done

else

echo "Okay - nothing done"

fi
