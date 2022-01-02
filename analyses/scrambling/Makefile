all: rem.tsv ref.tsv germanc.tsv ud.tsv enhg.tsv mercurius.tsv tcodex.tsv fuerstinnen.tsv

conll-rdf:
	@# replace with symlink if already installed
	git clone https://github.com/acoli-repo/conll-rdf

conll-merge:
	@# replace with symlink if already installed
	git clone https://github.com/acoli-repo/conll-merge

tiger-rdf:
	@# replace with symlink if already installed
	git clone https://github.com/acoli-repo/tiger-rdf

LLODifier:
	@# replace with symlink if already installed
	git clone https://github.com/acoli-repo/LLODifier

rem.tsv: conll-rdf
	cd ../../ReM;\
	make;
	for c in 11 12 13 14 xx; do \
		for h in 1 2 x; do \
			for genre in P PV V P; do \
				echo ReM $$c $$h $$genre 1>&2;\
				for file in ../../ReM/full_corpus/conll/*_$${c}-$${h}_$${genre}*conll; do \
					if [ -e $$file ]; then \
						echo '# '$$file;\
						cat $$file | \
						timeout 30 conll-rdf/run.sh CoNLLBrackets2RDF '#' ID TID WORD POS LEMMA INFL PARSE ANIMACY | \
						timeout 30 conll-rdf/run.sh CoNLLRDFUpdater -custom -updates rem2tiger.sparql | \
						timeout 30 conll-rdf/run.sh CoNLLRDFFormatter -query remquery.sparql | \
						egrep '.' | grep -v '^#' | \
						sed s/'$$'/'\t'$$c'\t'$$h'\t'$$genre/;\
						echo;\
					fi;\
				done;\
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
		timeout 180 python3 -u tiger-rdf/tiger/tiger2rdf.py $$file | \
		# some errors in the following arise from " in WORD \
		timeout 180 conll-rdf/run.sh CoNLLRDFUpdater -custom -updates refprep.sparql 2>/dev/null | \
		timeout 180 CoNLLRDFFormatter -query refquery.sparql |\
		egrep '.' | grep -v '^#' | \
		sed s/'$$'/'\t'$$c'\t'$$h'\t'$$genre/;\
		echo;\
	done |  tee ref.tsv

mercurius.tsv: tiger-rdf conll-rdf
		cd ../../Mercurius;\
		make;
		for file in ../../Mercurius/tiger-xml/*.xml; do \
			genre=NEWS;\
			year=1667;\
			if echo $$file | grep 'Annus' >/dev/null; then year=1597; fi; \
			c=`echo $$year / 100 + 1 | bc`;\
			h=`echo $$year % 100 / 50 + 1 | bc`;\
			# echo $$file $$year $$c $$h $$genre; \
			python3 -u tiger-rdf/tiger/tiger2rdf.py $$file | \
			timeout 600 conll-rdf/run.sh CoNLLRDFUpdater -custom -updates refprep.sparql 2>/dev/null | \
			#timeout 600 conll-rdf/run.sh CoNLLRDFFormatter -query tigerXplore.sparql | # to get the schema \
			timeout 600 conll-rdf/run.sh CoNLLRDFFormatter -query mercquery.sparql |\
#			cat; echo | \
			egrep '.' | grep -v '^#' | \
			sed s/'$$'/'\t'$$c'\t'$$h'\t'$$genre/;\
			echo;\
		done | tee mercurius.tsv

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

ud.tsv: conll-rdf
	cd ../../UD;\
	make;
	for dir in ../../UD/*/; do \
		genre=`basename $$dir | sed s/'.*[\-_]'//g;`;\
		c=xx; h=x;\
		if echo $$dir | egrep 'HDT' 1>&2; then c=20; h=2; fi; \
		if echo $$dir | egrep 'GSD' 1>&2; then c=21; h=1; fi; \
		if echo $$dir | egrep 'LIT' 1>&2; then c=18; h=2; fi; \
		echo $$dir $$c $$h; \
		for file in $$dir/*conllu; do cat $$file; echo; echo; done | \
		# skip multi-word expressions\
		egrep '^\s*$|^[0-9][0-9]*\s' | sed s/'^1\s'/'\n&'/g | \
		#cat; echo | \
		conll-rdf/run.sh CoNLLStreamExtractor '#' ID WORD LEMMA UPOS XPOS FEATS HEAD EDGE | \
		conll-rdf/run.sh CoNLLRDFFormatter -query ud.sparql |\
		egrep '.' | grep -v '^#' | \
		sed s/'$$'/'\t'$$c'\t'$$h'\t'$$genre/;\
		echo;\
	done | tee ud.tsv

enhg.tsv: conll-rdf
	cd ../../ENHG;\
	make;
	c=16; h=1; genre=BIB; \
	for file in ../../ENHG/*ref; do \
		cat $$file | \
		# one line per sentence \
		perl -pe 's/[ \t]+/ /g; s/([^\n])\n/\1 /;' |\
		# keep proper sentences only \
		egrep '^[(]' | \
		# one line per token \
		perl -pe 's/\n/\n\n/; s/([^\n]*)\((ID[^\)]+)\)/# \2\n\1/; s/(\)[ \)]*)([^\)\s])/\1\n\2/g; ' | \
		# split into columns WORD POS PARSE \
		perl -pe 's/^(.*)\(([^\(\) ]+) +([^\(\)]+)\)/\3\t\2\t\1*/;' | \
		# convert to CoNLL-RDF with tree extensions \
		conll-rdf/run.sh CoNLLBrackets2RDF '#' WORD POS PARSE | \
		# extrapolate edge labels \
		conll-rdf/run.sh CoNLLRDFUpdater -custom -updates enhgprep.sparql 2>/dev/null |\
		conll-rdf/run.sh CoNLLRDFFormatter -query enhgquery.sparql | \
		egrep '.' | grep -v '^#' | \
		sed s/'$$'/'\t'$$c'\t'$$h'\t'$$genre/; \
		echo;\
	done | tee enhg.tsv;

tcodex.tsv: conll-merge conll-rdf
	cd ../../TCodex;\
	make;
	c=9; h=1; genre=BIB;\
	(for file in ../../TCodex/*/*xml; do \
		echo '# doc: '$$file;\
		xsltproc conll-merge/cmd/exm2conll.xsl $$file;\
		echo ; \
	done | \
	conll-rdf/run.sh CoNLLStreamExtractor '#' ID LAT WORD ALIGN POS CAT CLAUSE GF _ GIVEN TOPIC ABOUTNESS POSITION _ DEFINITENESS FOCUS _ _ _ _ | \
	# cat; echo | \
	conll-rdf/run.sh CoNLLRDFUpdater -custom -updates exmprep.sparql |\
	conll-rdf/run.sh CoNLLRDFFormatter -query exmquery.sparql | \
	egrep '.' | grep -v '^#' | \
	sed s/'$$'/'\t'$$c'\t'$$h'\t'$$genre/;) | tee tcodex.tsv

fuerstinnen.tsv: conll-merge conll-rdf
	cd ../../fuerstinnen;\
	make;
	-(for file in ../../fuerstinnen/exb/*.exb; do \
		year=`basename $$file | sed s/'.*\([0-9x][0-9x][0-9x][0-9x]\).*'/'\1'/g;`;\
		c=`echo $$year | sed s/'^\(..\).*'/'\1 + 1'/ | bc`;\
		h=`echo $$year | sed s/'^..'/'\1 \/ 50 + 1 '/ | bc`;\
		genre=LET;\
		(echo '# doc: '$$file;\
		xsltproc conll-merge/cmd/exm2conll.xsl $$file;\
		echo ) | \
		# extract columns: id text    lemma   pos     morph   grfunct s_grfunct       clause-st \
		# note that we skip original IDs, as these follow creation order, but not chronological or otherwise \
		grep -v '^#' | cut -f 1,2,5-10 | \
		\
		# clause splitting (before and after annotated clauses -- annotation is incomplete!)\
		# note that we split for clauses instead of sentences because sentences from this time can be exceedingly long \
		sed -e s/'.*\s[BS]-[^_\-]*$$'/'\n&'/ \
			  -e s/'.*\s[ES]-[^_\-]*$$'/'&\n'/ | \
		# # ALTERNATIVE, SLOW: sentence splitting, using $$. \
		# sed -e s/'.*\$$\..*$$/&\n/g;' | \
		\
		#tee fuerstinnen.conll | # for debugging \
		# conversion to tiger-rdf, not clear what the difference between grfunct and s_grfunct is, only the first are being processed \
		timeout 600 conll-rdf/run.sh CoNLLStreamExtractor file:`realpath $$file`'#' ID WORD LEMMA POS MORPH GF S_GF CLAUSE 2>/dev/null| \
		timeout 600 conll-rdf/run.sh CoNLLRDFUpdater -custom -updates fstprep.sparql 2>/dev/null |\
		timeout 600 conll-rdf/run.sh CoNLLRDFFormatter -query fstquery.sparql | \
		egrep '.' | grep -v '^#' | \
		sed s/'$$'/'\t'$$c'\t'$$h'\t'$$genre/;\
	done) | tee fuerstinnen.tsv
