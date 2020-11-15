# wikidata-misc
Various Wikidata maintenance/upload scripts

### duplicate-claims.sh

Finds items with two identical claims for the same property (intended for father/mother/child), checks there are no qualifiers or references, and removes one. Uses wikibase-cli.

### labelcleaner.sh

Removes all labels, descriptions, and aliases for a specific language from a set of items. Uses wikibase-cli.

### wikidata-purge.sh

Forces a purge on all items using a certain property, in order to update formatter URLs (as a workaround for [phab:T112081](https://phabricator.wikimedia.org/T112081)). Uses pywikibot.

### crossref-parser

Parses a list of DOIs, runs them against the crossref DOI endpoint, and formats the results for QuickStatements. Not tested since 2018 so do not rely on this working! Kept for historic reference.
