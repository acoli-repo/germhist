#!/bin/bash
# retrieve metadata about all files
echo '[ '
for file in full_corpus/orig/*/*xml; do
  id=`basename $file | sed s/'\.xml$'//`;
  echo '{ "'$id'": {'
  sed -e s/'<'/'\n<'/g $file | egrep '<(language-|genre|time|date)' | sed -e s/'"'//g -e s/'<'/'"'/g -e s/'>'/'":"'/g -e s/'$'/'",'/g;
  echo '"language": "MHG" }},'
done;
echo '{}]'
