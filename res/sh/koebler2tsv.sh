#!/bin/bash
# convert koebler html dictionary (2014) to tsv list, containing (first) source word and (first) nhd. gloss
# other target languages can be specified as XSL parameters
cat $* | \
sed s/'<br>'/'<br\/>'/g | \
xmllint --recover - 2>/dev/null | \
saxon -s:- -xsl:C:/Users/Frans/Documents/workspace/quantqual_release/res/sh/koebler2tsv.xsl | \
grep -v ' '	| 		# keep 1:1 correspondences only
grep -v '\.\.\.' |	# remove morphemes
grep -v '\-'		# remove DW2- (???)