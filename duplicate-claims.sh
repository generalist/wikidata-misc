#!/bin/bash

#this tool finds items with duplicate claims, and then merges them together

# eg for P40
# https://w.wiki/Dhg
# simpler approach - only items with one claim having a ref, not the other
# https://w.wiki/DiM

# this current version finds all items with:
# two claims for the same P22 value ("father")
# one claim having a reference and the other not
# and neither claim having any qualifiers *at all*
# it then deletes the extra claim using wd-cli


# first download the list
curl --header "Accept: text/tab-separated-values" https://query.wikidata.org/sparql?query=SELECT%20DISTINCT%20%20%3Fitem%20%3Ffather%20%3Fps1%20%3Fps2%20%3Fref1%20%3Fref2%20%3Fq1%20%3Fq2%0AWHERE%0A%7B%0A%09%3Fitem%20p%3AP22%20%3Fps1%20.%20%3Fps1%20ps%3AP22%20%3Ffather%20.%20%3Fps1%20prov%3AwasDerivedFrom%20%3Fref1%20.%0A%20%20%20%20%3Fitem%20p%3AP22%20%3Fps2%20.%20%3Fps2%20ps%3AP22%20%3Ffather%20.%20minus%20%7B%20%3Fps2%20prov%3AwasDerivedFrom%20%3Fref2%20%7D%0A%20%20%20%20filter%20%28str%28%3Fps1%29%20%21%3D%20str%28%3Fps2%29%29%0A%09bind%28exists%20%7B%20%3Fps1%20%3Fpq1%20%3Fqualifier1%20.%20%3Fproperty1%20wikibase%3Aqualifier%20%3Fpq1%20.%20%7D%20as%20%3Fq1%29%20%0A%09bind%28exists%20%7B%20%3Fps2%20%3Fpq2%20%3Fqualifier2%20.%20%3Fproperty2%20wikibase%3Aqualifier%20%3Fpq2%20.%20%7D%20as%20%3Fq2%29%0A%7D%0A > working/output.tsv

# now check no fields are "true" (ie there is no field with references) and then cut out all the claim2's, the ones with no references, and header line

grep -v "true" working/output.tsv | grep -v "?" | cut -f 4 > working/removable-claims.tsv

# tidy up into a form wd-cli will like

cat working/removable-claims.tsv | sed "s/<http:\/\/www.wikidata.org\/entity\/statement\///g" | sed "s/>//g" | sed "s/-/$/" > working/removal-commands

# now run wd-cli for each of these

echo -e "there are "`cat working/removal-commands | wc -l` " duplicate claims with no qualifiers or references."

read -p "Do you want to remove them? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then

echo "Here we go!"

  for i in `cat working/removal-commands` ; do wd remove-claim "$i" ; done

else

echo "Okay - the list is at working/removal-commands"

fi
