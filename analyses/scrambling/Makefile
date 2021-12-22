all: rem.tsv ref.tsv germanc.tsv

conll-rdf:
	@# replace with symlink if already installed
	git clone https://github.com/acoli-repo/conll-rdf

tiger-rdf:
	@# replace with symlink if already installed
	git clone https://github.com/acoli-repo/tiger-rdf

rem.tsv: conll-rdf
	cd ../../ReM;\
	make;
	for c in 11 12 13 14 xx; do \
		for h in 1 2 x; do \
			for genre in P PV V P; do \
				echo ReM $$c $$h $$genre 1>&2;\
				cat ../../ReM/full_corpus/conll/*_$${c}-$${h}_$${genre}*conll | \
				conll-rdf/run.sh CoNLLBrackets2RDF '#' ID TID WORD POS LEMMA INFL PARSE ANIMACY | \
				conll-rdf/run.sh CoNLLRDFUpdater -custom -updates rem2tiger.sparql | \
				conll-rdf/run.sh CoNLLRDFFormatter -query remquery.sparql | \
				egrep '.' | grep -v '^#' | \
				sed s/'$$'/'\t'$$c'\t'$$h'\t'$$genre/;\
				echo;\
			done;\
		done;\
	done | tee rem.tsv

ref.tsv: tiger-rdf conll-rdf
	cd ../../ReF;\
	make;
	for file in ../../ReF/*/ref-up/*.xml; do \
		time=`egrep -m 1 '<time>' $$file | sed -e s/'<[^>]*>'//g -e s/'\s'//g -e s/','/'\\t'/;`;\
		c=`echo $$time | sed s/'\s.*'//;`;\
		h=`echo $$time | sed s/'.*\s'//;`;\
		genre=`egrep -m 1 '<genre>' $$file | sed -e s/'<[^>]*>'//g -e s/'\s'//g -e s/','/'\t'/;`;\
		python3 -u tiger-rdf/tiger/tiger2rdf.py $$file | \
		# some errors in the following arise from " in WORD \
		conll-rdf/run.sh CoNLLRDFUpdater -custom -updates refprep.sparql 2>/dev/null | \
		conll-rdf/run.sh CoNLLRDFFormatter -query refquery.sparql |\
		egrep '.' | grep -v '^#' | \
		sed s/'$$'/'\t'$$c'\t'$$h'\t'$$genre/;\
		echo;\
	done | tee ref.tsv

germanc.tsv: conll-rdf
		cd ../../GerManC;\
		make;
		for file in ../../GerManC/LING-COL/*txt; do \
			genre=`basename $$file | sed s/'_.*'//;`;\
			year=`basename $$file |  sed s/'.*\([0-9][0-9][0-9][0-9]\)_[A-Z][^_]*.txt'/'\1'/g;`;\
			c=`echo $$year / 100 + 1 | bc`;\
			h=`echo $$year % 100 / 50 + 1 | bc`;\
			#echo $$file $$year $$c $$h $$genre;\
			cat $$file | \
			conll-rdf/run.sh CoNLLStreamExtractor '#' ID WORD NORM POS LEMMA INFL EDGE HEAD 2>/dev/null| \
			conll-rdf/run.sh CoNLLRDFFormatter -query germanc.sparql 2>/dev/null|\
			egrep '.' | grep -v '^#' | \
			sed s/'$$'/'\t'$$c'\t'$$h'\t'$$genre/;\
			echo;\
		done | tee germanc.tsv
