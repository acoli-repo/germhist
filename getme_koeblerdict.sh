#!/bin/bash
datF=./res/sh/mhd.htm;
ndatF=./res/data/mhd-koebler.tsv;

if [ ! -e $ndatF ]
  then 
  echo "Attempt to download the Köbler Middle High German dictionary and convert the data into a TSV file (xmllint and saxon required)"
  if [ ! -e $datF ]
    then 
    echo "downloading Köbler dictionary from http://www.koeblergerhard.de/mhd/mhd.html";
    wget -O $datF http://www.koeblergerhard.de/mhd/mhd.html;
  fi;
  echo "htm to tsv conversion ... --> $ndatF";
  (cd ./res/sh/
  bash -i koebler2tsv.sh $(basename $datF)
  ) > $ndatF;
fi;
echo "all done";