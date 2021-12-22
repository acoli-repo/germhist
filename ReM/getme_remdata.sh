#!/bin/bash
# converts CoraXML to CoNLL as input for the Quantqual pipeline
# 
# ReM corpus data should be downloaded manually!
#if [ ! -e ./res/data/remdata.tar.xz ]
#  then wget -O ./res/data/remdata.tar.xz "https://solera.linguistics.rub.de/fsdownload/EWkiTjl4o/rem-coraxml-20161222.tar.xz"
#fi;

##########
# config #
##########
remarchive=./res/data/rem-coraxml-20161222.tar.xz;
all=false;
refCorpus="M242-G1 M242Y-N0 M214-G1 M214y-N1 M113-G1 M113y-N1 M329-G1 M161-N1 M403-G1 M403y-N0 M405-G1 M405y-N1 M407-G1 M407y-N0 M402-G1 M402y-N1 M406-G1 M406y-N0";
output=$(realpath ./res/data/remdata/);
acbare=$(basename $remarchive);
acbare=${acbare%.tar.xz};
set LANG=C.UTF-8;
if [ $OSTYPE = "cygwin" ]; then
  output=$(cygpath -ma $output);
fi;
if [ ! -d ./temp ]
  then mkdir ./temp
fi;
###############################################################################################
# iterate over files in archive, extract them one by one and convert into CoNLL               #
# extracts and converts only the reference corpus for syntax analysis if $all is set to false #
###############################################################################################
if [ ! -e $remarchive ]; then
  echo "missing data file: $remarchive";
  exit 1;
fi;
list=`tar --list --file=$remarchive`;
if $all; then
  echo "converting all - this may take a while ...";
else
  echo "extraction and conversion limited to the reference corpus for syntax analysis ...";
fi;
for f in $list; do \
  f=${f#$acbare};
  f=${f#/};
  if ! $all && [[ ! $refCorpus =~ (^|[[:space:]])${f%.xml}($|[[:space:]]) ]]; then
    continue;
  fi;
  echo "processing $f";
  tar xC ./temp -f $remarchive $acbare/$f --strip-components=1;
  python -m src.org.acoli.conll.quantqual.remToConll -dir ./temp -dest $output -files "$f" -silent True;
  rm ./temp/$f
done;
rm -r ./temp;
