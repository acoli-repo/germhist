#!/bin/bash
# given a TTL file with POWLA annotations, produce a conll file with bracket notation

MYHOME=`dirname "${BASH_SOURCE[0]}"`

#
# config
#########
SPARQL=$MYHOME/../sparql
# echo $SPARQL

# note: this overrides MYHOME!
source $MYHOME/../../config

#
# read from stdin or args
###########################
cat $* | \
iconv -f utf-8 -t utf-8 -c | \
$TRANSFORM -updates $SPARQL/powla2brackets.sparql | \
$WRITE -conll ID TID WORD POS LEMMA INFL PARSE ANIMACY
# $WRITE -grammar
