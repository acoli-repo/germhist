all: paula meta.tsv

meta.tsv:
	mkdir meta
	cd meta; \
	if [ ! -e DDB_tei.zip ]; then wget https://www.laudatio-repository.org/download/tei/43/1.0/deutsche-diachrone-baumbank--projekt/deutsche-diachrone-baumbank_1-0 -O DDB_tei.zip; fi; \
	unzip -j -o DDB_tei.zip -x *annotation* 2>/dev/null;\
	for file in *.xml; do \
		id=`basename $$file | sed s/'\.xml$$'//`;\
		# year is median of all 3-4 number numerals \
		year=`xmllint --xpath "//*[name()='origin']/*[name()='origDate'][1]" $$file | sed s/'[^0-9][^0-9]*'/'\n'/g | egrep '^....*$$' | sort -n | \
		awk '{arr[NR]=$$1}\
    END { if (NR%2==1) print arr[(NR+1)/2]; else print (arr[NR/2]+arr[NR/2+1])/2}'`; \
		area=`xmllint --xpath "//*[name()='language'][@style='LanguageArea'][1]/text()" $$file`;\
		if echo $$file | grep FNHD > /dev/null; then \
			year=1546;\
		fi;\
		c=`echo "1 +" $$year | sed s/'..$$'// | bc`;\
		h=`echo $$year | sed s/'.*\(..\)$$'/'\1 \/ 50 +1/;' | bc`;\
		echo $$id'\t'$$c'\t'$$h'\t'$$area;\
	done 1> ../meta.tsv 2>/dev/null;

paula:
	if [ ! -e DDB_paula.zip ]; then wget https://www.laudatio-repository.org/download/format/5/43/1.0 -O DDB_paula.zip; fi
	unzip DDB_paula.zip
	cd paula;\
	unzip *zip;\
	mv PAULA/* .;\
	rmdir PAULA;\
	# DDB exmaralda files point to inexisting tok file, removed \
	rm `find | grep 'exmaralda'`

tiger-negra:
	@# left as future reference, the data is skrewed, only OHG is TIGER format, but too marginal to be seriously considered
	if [ ! -e DDB.zip ]; then wget https://www.laudatio-repository.org/download/format/22/43/1.0 -O DDB.zip; fi
	unzip DDB.zip
	cd tiger-negra;\
	unzip *.zip;\
	mv TIGER-Negra/*/ .;\
	rmdir TIGER-Negra
