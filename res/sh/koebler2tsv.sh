#!/bin/bash
# convert koebler html dictionary (2014) to tsv list, containing (first) source word and (first) nhd. gloss
# other target languages can be specified as XSL parameters

#
# config
##########

# set to your local saxon installation or get it from https://sourceforge.net/projects/saxon/ (Open Source) or https://www.saxonica.com/download/java.xml (commercial edition)
SAXON_JAR=~/tools/saxon/saxon-he-10.6.jar

JAVA=java

#
# init
########

MYHOME=`dirname $0`
SAXON=$JAVA' -classpath '`dirname $SAXON_JAR`/jline-*.jar' -jar '$SAXON_JAR' '

#
# processing
##############

cat $* | \
sed s/'<br>'/'<br\/>'/g | \
xmllint --recover - 2>/dev/null | \
$SAXON -s:- -xsl:$MYHOME/koebler2tsv.xsl | \
grep -v ' '	| 		# keep 1:1 correspondences only
grep -v '\.\.\.' |	# remove morphemes
grep -v '\-'		# remove DW2- (???)
