# wikidata-misc
Various Wikidata maintenance/upload scripts

### duplicate-claims.sh

Finds items with two identical claims for the same property (intended for father/mother/child), checks there are no qualifiers on either, and removes one. Uses wikibase-cli.

This script will at some point be adapted to merge references on the two claims, but for the moment it backs off if any references are present.

### labelcleaner.sh

Removes *all* labels, descriptions, and aliases for a specific language from a set of items. Uses wikibase-cli.

### qualifier-removal.sh

Removes all qualifiers of a set type (example given is P582) from a set of statements. Uses wikibase-cli and jq.

### wikidata-purge.sh

Forces a purge on all items using a certain property, in order to update formatter URLs (as a workaround for [phab:T112081](https://phabricator.wikimedia.org/T112081)). Uses pywikibot. 

It is important before using this to confirm that the property has itself been purged, and that a manual purge of an item brings up the correct formatter URL links. This can sometimes be a bit delayed so it is best to wait a little while after editing the formatter URL and confirm the system has caught up. Otherwise the script may purge the items without any useful effect.

At maximum speed the pywikibot script makes about five or six purges per minute, so a maximum of about seven to eight thousand per day. This script is thus not suitable for properties with tens of thousands of items unless you are very patient, or most of those items are recently edited anyway and do not need purging.

It is also sensitive to maxlag, which will cause it to back off and try again after a short delay. However, pywikibot will eventually give up after a few delayed attempts; as a result, when the query servers are lagged, it will not reliably purge every item. Testing at low-moderate lag, it purges 3-4 times/minute and no more than ~2% of items timed out. It may be most effective to run it a second time a while later, to ensure all items are caught.

### crossref-parser

Parses a list of DOIs, runs them against the crossref DOI endpoint, and formats the results for QuickStatements. Not tested since 2018 so do not rely on this working! Kept for historic reference.
