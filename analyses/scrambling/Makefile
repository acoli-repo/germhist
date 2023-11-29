all: ppchy.tsv ipchg.tsv rem.tsv ref.tsv germanc.tsv ud.tsv enhg.tsv mercurius.tsv tcodex.tsv fuerstinnen.tsv ycoe.tsv helipad.tsv icepahc.tsv proiel.tsv greek.tsv tuebadz.tsv ddb.tsv

ppchy.tsv: conll-rdf
	cd ../../ppchy; \
	make;
	genre=P; region=YID;\
	for file in `find ../../ppchy | grep 'psd$$'`; do \
		c=`basename $$file | perl -pe 's/^(..).*/\1 + 1/g;' | bc`;\
		if echo $$c | egrep '^..$$' > /dev/null; then \
			h=2;\
			if [ `basename $$file | perl -pe 's/^..(.).*/\1/g;'` -lt 5 ]; then h=1; fi;\
	 		cat $$file | \
	 		# one line per sentence \
			perl -pe 's/\s+/ /g; s/\(ID[^\)]*\)\)\s*/)\n/;' |\
			# one line per token \
			perl -pe 's/\n/\n\n/; s/([^\n]*)\((ID[^\)]+)\)/# \2\n\1/; s/(\)[ \)]*)([^\)\s])/\1\n\2/g; ' | \
			# split into columns WORD POS PARSE \
			perl -pe 's/^(.*)\(([^\(\) ]+) +([^\(\)]+)\)/\3\t\2\t\1*/;' | \
			# convert to CoNLL-RDF with tree extensions \
			#tee ppchy.1.tmp| \
			conll-rdf/run.sh CoNLLBrackets2RDF file:`realpath $$file`'#' WORD POS PARSE | \
			#tee ppchy.2.ttl| \
			# extrapolate edge labels \
			conll-rdf/run.sh CoNLLRDFUpdater -custom -updates enhgprep.sparql |\
			#tee ppchy.3.ttl| \
			conll-rdf/run.sh CoNLLRDFFormatter -query enhgquery.sparql | \
			egrep '.' | grep -v '^#' | \
			sed s/'$$'/'\t'$$c'\t'$$h'\t'$$genre'\t'$$region/; \
		fi;\
	done > ppchy.tsv;


ipchg.tsv: conll-rdf
	cd ../../ipchg;\
	make;
	c=16; h=1; genre=P; region=OMD;\
	for dir in ../../ipchg/structured/*; do \
		region=`basename $$dir | sed s/'.*'/'\U&'/g;	`;\
		for file in $$dir/*.txt; do \
			c=`basename $$file | perl -pe 's/^(..).*/\1 + 1/g;' | bc`;\
			h=2;\
			if [ `basename $$file | perl -pe 's/^..(.).*/\1/g;'` -lt 5 ]; then h=1; fi;\
	 		cat $$file | \
	 		# one line per sentence \
	 		perl -pe 's/\s+/ /g; s/\(ID[^\)]*\)\)\s*/)\n/;' |\
	 		# one line per token \
	 		perl -pe 's/\n/\n\n/; s/([^\n]*)\((ID[^\)]+)\)/# \2\n\1/; s/(\)[ \)]*)([^\)\s])/\1\n\2/g; ' | \
	 		# split into columns WORD POS PARSE \
	 		perl -pe 's/^(.*)\(([^\(\) ]+) +([^\(\)]+)\)/\3\t\2\t\1*/;' | \
	 		# convert to CoNLL-RDF with tree extensions \
	 		conll-rdf/run.sh CoNLLBrackets2RDF file:`realpath $$file`'#' WORD POS PARSE | \
	 		# extrapolate edge labels \
	 		conll-rdf/run.sh CoNLLRDFUpdater -custom -updates enhgprep.sparql |\
	 		conll-rdf/run.sh CoNLLRDFFormatter -query enhgquery.sparql | \
	 		egrep '.' | grep -v '^#' | \
	 		sed s/'$$'/'\t'$$c'\t'$$h'\t'$$genre'\t'$$region/; \
	 	done;\
	 done | tee ipchg.tsv; \

conll-rdf:
	@# replace with symlink if already installed
	git clone https://github.com/acoli-repo/conll-rdf
	cd conll-rdf;\
	bash -e ./compile.sh

conll-merge:
	@# replace with symlink if already installed
	git clone https://github.com/acoli-repo/conll-merge

tiger-rdf:
	@# replace with symlink if already installed
	git clone https://github.com/acoli-repo/tiger-rdf

LLODifier:
	@# replace with symlink if already installed
	git clone https://github.com/acoli-repo/LLODifier

powla:
	@# replace with symlink if already installed
	git clone https://github.com/acoli-repo/powla

rem.tsv: conll-rdf
	cd ../../ReM;\
	make;
	for c in 11 12 13 14 xx; do \
		for h in 1 2 x; do \
			for genre in P PV V P; do \
				echo ReM $$c $$h $$genre 1>&2;\
				for file in ../../ReM/full_corpus/conll/*_$${c}-$${h}_$${genre}*conll; do \
					if [ -e $$file ]; then \
						id=`basename $$file | sed s/'_.*'//`;\
						orig_region=`cat ../../ReM/metadata.json | jq '.[] | ."'$$id'>" | ."language-region"' | grep -m 1 '"' | sed s/'"'//g`;\
						region=`echo $$orig_region | \
								sed -e s/'westmitteldeutsch'/'WMD'/g \
										-e s/'o[st]*mitteldeutsch'/'OMD'/g \
										-e s/'[a-z]*mitteldeutsch'/'MD'/g \
										-e s/'ostoberdeutsch'/'OOD'/g \
										-e s/'westoberdeutsch'/'WOD'/g \
										-e s/'[a-z]*oberdeutsch'/'OD'/g \
										-e s/'[a-z]*niederdeutsch'/'ND'/g \
										-e s/'[a-z][a-z]*'/'_'/g`;\
						echo ReM $$c $$h $$genre $$orig_region $$region 1>&2;\
						echo '# '$$file;\
						cat $$file | \
						timeout 30 conll-rdf/run.sh CoNLLBrackets2RDF file:`realpath $$file`'#' ID TID WORD POS LEMMA INFL PARSE ANIMACY | \
						timeout 30 conll-rdf/run.sh CoNLLRDFUpdater -custom -updates rem2tiger.sparql | \
						timeout 30 conll-rdf/run.sh CoNLLRDFFormatter -query remquery.sparql | \
						egrep '.' | grep -v '^#' | \
						sed s/'$$'/'\t'$$c'\t'$$h'\t'$$genre'\t'$$region/;\
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
		id=`basename $$file | sed s/'\..*'//`;\
		orig_region=`cat ../../ReF/metadata.json | jq '.[] | ."'$$id'" | ."language-region"' | grep -m 1 '"' | sed s/'"'//g`;\
		region=`echo $$orig_region | \
				sed -e s/'westmitteldeutsch'/'WMD'/g \
						-e s/'o[st]*mitteldeutsch'/'OMD'/g \
						-e s/'[a-z]*mitteldeutsch'/'MD'/g \
						-e s/'ostoberdeutsch'/'OOD'/g \
						-e s/'westoberdeutsch'/'WOD'/g \
						-e s/'[a-z]*oberdeutsch'/'OD'/g \
						-e s/'[a-z]*niederdeutsch'/'ND'/g \
						-e s/'[a-z][a-z]*'/'_'/g`;\
		time=`egrep -m 1 '<time>' $$file | sed -e s/'<[^>]*>'//g -e s/'\s'//g -e s/','/'\\t'/;`;\
		c=`echo $$time | sed s/'\s.*'//;`;\
		h=`echo $$time | sed s/'.*\s'//;`;\
		genre=`egrep -m 1 '<genre>' $$file | sed -e s/'<[^>]*>'//g -e s/'\s'//g -e s/','/'\t'/;`;\
		echo ReF $$id $$c $$h $$genre $$orig_region $$region 1>&2;\
		timeout 180 python3 -u tiger-rdf/tiger/tiger2rdf.py $$file | \
		# some errors in the following arise from " in WORD \
		timeout 180 conll-rdf/run.sh CoNLLRDFUpdater -custom -updates refprep.sparql 2>/dev/null | \
		timeout 180 conll-rdf/run.sh CoNLLRDFFormatter -query refquery.sparql |\
		egrep '.' | grep -v '^#' | \
		sed s/'$$'/'\t'$$c'\t'$$h'\t'$$genre'\t'$$region/;\
		echo;\
	done |  tee ref.tsv

mercurius.tsv: tiger-rdf conll-rdf
		cd ../../Mercurius;\
		make;
		for file in ../../Mercurius/tiger-xml/*.xml; do \
			genre=NEWS;\
			year=1667;\
			region=WOD;\
			if echo $$file | grep 'Annus' >/dev/null; then year=1597; region=ND; fi; \
			c=`echo $$year / 100 + 1 | bc`;\
			h=`echo $$year % 100 / 50 + 1 | bc`;\
			# echo $$file $$year $$c $$h $$genre; \
			python3 -u tiger-rdf/tiger/tiger2rdf.py $$file | \
			timeout 600 conll-rdf/run.sh CoNLLRDFUpdater -custom -updates refprep.sparql 2>/dev/null | \
			#timeout 600 conll-rdf/run.sh CoNLLRDFFormatter -query tigerXplore.sparql | # to get the schema \
			timeout 600 conll-rdf/run.sh CoNLLRDFFormatter -query mercquery.sparql |\
#			cat; echo | \
			egrep '.' | grep -v '^#' | \
			sed s/'$$'/'\t'$$c'\t'$$h'\t'$$genre'\t'$$region/;\
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
			region=`basename $$file | cut -f 3 -d '_' | sed s/'NoD'/'ND'/g;`;\
			#echo $$file $$year $$c $$h $$genre;\
			cat $$file | \
			conll-rdf/run.sh CoNLLStreamExtractor file:`realpath $$file`'#' ID WORD NORM POS LEMMA INFL EDGE HEAD 2>/dev/null| \
			conll-rdf/run.sh CoNLLRDFFormatter -query germanc.sparql 2>/dev/null|\
			egrep '.' | grep -v '^#' | \
			sed s/'$$'/'\t'$$c'\t'$$h'\t'$$genre'\t'$$region/;\
			echo;\
		done | tee germanc.tsv

ud.tsv: conll-rdf
	cd ../../UD;\
	make;
	for dir in ../../UD/*/; do \
		genre=`basename $$dir | sed s/'.*[\-_]'//g;`;\
		c=xx; h=x;\
		region=SD;\
		if echo $$dir | egrep 'HDT' 1>&2; then c=20; h=2; fi; \
		if echo $$dir | egrep 'GSD' 1>&2; then c=21; h=1; fi; \
		if echo $$dir | egrep 'LIT' 1>&2; then c=18; h=2; fi; \
		echo $$dir $$c $$h; \
		for file in $$dir/*conllu; do cat $$file; echo; echo; done | \
		# skip multi-word expressions\
		egrep '^\s*$|^[0-9][0-9]*\s' | sed s/'^1\s'/'\n&'/g | \
		#cat; echo | \
		conll-rdf/run.sh CoNLLStreamExtractor file:`realpath $$dir`'#' ID WORD LEMMA UPOS XPOS FEATS HEAD EDGE | \
		conll-rdf/run.sh CoNLLRDFFormatter -query ud.sparql |\
		egrep '.' | grep -v '^#' | \
		sed s/'$$'/'\t'$$c'\t'$$h'\t'$$genre'\t'$$region/;\
		echo;\
	done | tee ud.tsv

enhg.tsv: conll-rdf
	cd ../../ENHG;\
	make;
	c=16; h=1; genre=BIB; region=OMD;\
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
		tee enhg.`basename $$file`.conll | \
		# convert to CoNLL-RDF with tree extensions \
		conll-rdf/run.sh CoNLLBrackets2RDF file:`realpath $$file`'#' WORD POS PARSE | \
		# extrapolate edge labels \
		conll-rdf/run.sh CoNLLRDFUpdater -custom -updates enhgprep.sparql 2>/dev/null |\
		conll-rdf/run.sh CoNLLRDFFormatter -query enhgquery.sparql | \
		egrep '.' | grep -v '^#' | \
		sed s/'$$'/'\t'$$c'\t'$$h'\t'$$genre'\t'$$region/; \
		echo;\
	done | tee enhg.tsv;

tcodex.tsv: conll-merge conll-rdf
	cd ../../TCodex;\
	make;
	c=9; h=1; genre=BIB; region=WMD; # franconian \
	(for file in ../../TCodex/*/*xml; do \
		echo '# doc: '$$file;\
		xsltproc conll-merge/cmd/exm2conll.xsl $$file;\
		echo ; \
	done | \
	tee tcodex.conll | \
	conll-rdf/run.sh CoNLLStreamExtractor '#' ID LAT WORD ALIGN POS CAT CLAUSE GF _ GIVEN TOPIC ABOUTNESS POSITION _ DEFINITENESS FOCUS _ _ _ _ | \
	# cat; echo | \
	conll-rdf/run.sh CoNLLRDFUpdater -custom -updates exmprep.sparql |\
	conll-rdf/run.sh CoNLLRDFFormatter -query exmquery.sparql | \
	egrep '.' | grep -v '^#' | \
	sed s/'$$'/'\t'$$c'\t'$$h'\t'$$genre'\t'$$region/;) | tee tcodex.tsv

fuerstinnen.tsv: conll-merge conll-rdf
	cd ../../fuerstinnen;\
	make;
	-(for file in ../../fuerstinnen/exb/*.exb; do \
		year=`basename $$file | sed s/'.*\([0-9x][0-9x][0-9x][0-9x]\).*'/'\1'/g;`;\
		c=`echo $$year | sed s/'^\(..\).*'/'\1 + 1'/ | bc`;\
		h=`echo $$year | sed s/'^..\(..\)$$'/'\1 \/ 50 + 1 '/ | bc`;\
		genre=LET;\
		region=OMD;\
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
		sed s/'$$'/'\t'$$c'\t'$$h'\t'$$genre'\t'$$region/;\
	done) | tee fuerstinnen.tsv

ycoe.tsv: conll-rdf
	@# note that this is just a copy of the ENHG workflow
	c=xx; h=x; region=OE;\
	for file in `find ../../YCOE/*/ | grep '.psd$$'`; do \
		cat $$file | \
		# one line per sentence \
		perl -pe 's/^\(/\n\n\(/g; s/^[ \t]+/ /g; s/([^\n])\n/\1 /;' |\
		# keep proper sentences only \
		egrep '^[(]' | \
		# one line per token \
		perl -pe 's/\n/\n\n/; s/([^\n]*)\((ID[^\)]+)\)/# \2\n\1/; s/(\)[ \)]*)([^\)\s])/\1\n\2/g; ' | \
		# split into columns WORD POS PARSE \
		perl -pe 's/^(.*)\(([^\(\) ]+) +([^\(\)]+)\)/\3\t\2\t\1*/;' | \
		# convert to CoNLL-RDF with tree extensions \
		timeout 600 conll-rdf/run.sh CoNLLBrackets2RDF file:`realpath $$file`'#' WORD POS PARSE | \
		# extrapolate edge labels \
		timeout 600 conll-rdf/run.sh CoNLLRDFUpdater -custom -updates enhgprep.sparql 2>/dev/null |\
		timeout 600 conll-rdf/run.sh CoNLLRDFFormatter -query enhgquery.sparql 2>/dev/null| \
		#cat; echo | \
		egrep '.' | grep -v '^#' | \
		sed s/'$$'/'\t'$$c'\t'$$h'\t'$$genre'\t'$$region/; \
		echo;\
	done | tee ycoe.tsv

helipad.tsv: conll-rdf
	@# slightly extended ENHG workflow: LEMMA and MORPH columns
	cd ../../helipad;\
	make;
	c=9; h=1; genre=BIB; region=ND;\
	for file in `find ../../helipad/ | grep '.psd$$'`; do \
		cat $$file | \
		# one line per sentence \
		perl -pe 's/^\(/\n\n\(/g; s/^[ \t]+/ /g; s/([^\n])\n/\1 /;' |\
		# keep proper sentences only \
		egrep '^[(]' | \
		# one line per token \
		perl -pe 's/\n/\n\n/; s/([^\n]*)\((ID[^\)]+)\)/# \2\n\1/; s/(\)[ \)]*)([^\)\s])/\1\n\2/g; ' | \
		# split into columns WORD LEMMA POS MORPH PARSE \
		perl -pe 's/^(.*)\(([^\(\) ]+) +([^\(\)]+)\)/\3\t\2\t\1*/; 			# initial columns: WORD POS PARSE \
							s/^([^\t]+)\t(([^\t\^]+)(\^[^\t]*)?)\t/\1\t\3\t\2\t/; # split POS => columns WORD POS MORPH PARSE \
							# split WORD => columns WORD LEMMA POS MORPH PARSE \
						  s/^([^\s\-]+)\t/\1\t_\t/g; 				# for rows without lemma, add an empty lemma \
							s/^([^\s\-]*)\-([^\s]*)/\1\t\2/g; # split WORD and LEMMA at - \
		' | \
		tee helipad.conll | # for debugging \
		# convert to CoNLL-RDF with tree extensions \
		timeout 600 conll-rdf/run.sh CoNLLBrackets2RDF file:`realpath $$file`'#' WORD LEMMA POS MORPH PARSE | \
		# extrapolate edge labels \
		timeout 600 conll-rdf/run.sh CoNLLRDFUpdater -custom -updates enhgprep.sparql 2>/dev/null |\
		timeout 600 conll-rdf/run.sh CoNLLRDFFormatter -query enhgquery.sparql 2>/dev/null| \
		egrep '.' | grep -v '^#' | \
		sed s/'$$'/'\t'$$c'\t'$$h'\t'$$genre'\t'$$region/; \
		echo;\
	done | tee helipad.tsv

icepahc.tsv: conll-rdf
	@# slightly extended HeliPaD workflow, note that we exclude material from 16th c. onwards, so that our subset represents Old Icelandic
	cd ../../icepahc;\
	make;
	for file in `find ../../icepahc/ | grep '\.psd$$'`; do \
		year=`basename $$file | sed s/'\..*'//;`;\
		c=`echo $$year | sed s/'^\(..\).*'/'\1 + 1'/ | bc`;\
		h=`echo $$year | sed s/'^..\(..\)$$'/'\1 \/ 50 + 1 '/ | bc`;\
		region=IS;\
		\
		# only texts before 1500 \
		if test $$c -lt 16  ; then \
			echo '# doc: '$$file;\
			cat $$file | \
			# one line per sentence \
			perl -pe 's/^\(/\n\n\(/g; s/^[ \t]+/ /g; s/([^\n])\n/\1 /;' |\
			# keep proper sentences only \
			egrep '^[(]' | \
			# one line per token \
			perl -pe 's/\n/\n\n/; s/([^\n]*)\((ID[^\)]+)\)/# \2\n\1/; s/(\)[ \)]*)([^\)\s])/\1\n\2/g; ' | \
			# split into columns WORD LEMMA POS MORPH PARSE \
			perl -pe 's/^(.*)\(([^\(\) ]+) +([^\(\)]+)\)/\3\t\2\t\1*/; 			# initial columns: WORD POS PARSE \
								s/^([^\t]+)\t(([^\t\^\-]+)([\^\-][^\t]*)?)\t/\1\t\3\t\2\t/; # split POS => columns WORD POS MORPH PARSE \
								# we preserve the HeliPaD splitter symbol ^ but also support the IcePaHC splitter symbol - \
								# split WORD => columns WORD LEMMA POS MORPH PARSE \
							  s/^([^\s\-]+)\t/\1\t_\t/g; 				# for rows without lemma, add an empty lemma \
								s/^([^\s\-]*)\-([^\s]*)/\1\t\2/g; # split WORD and LEMMA at - \
			' | \
			# tee icepahc.conll | # for debugging \
			# convert to CoNLL-RDF with tree extensions \
			timeout 600 conll-rdf/run.sh CoNLLBrackets2RDF file:`realpath $$file`'#' WORD LEMMA POS MORPH PARSE | \
			# extrapolate edge labels \
			timeout 600 conll-rdf/run.sh CoNLLRDFUpdater -custom -updates enhgprep.sparql 2>/dev/null |\
			timeout 600 conll-rdf/run.sh CoNLLRDFFormatter -query enhgquery.sparql 2>/dev/null| \
			egrep '.' | grep -v '^#' | \
			sed s/'$$'/'\t'$$c'\t'$$h'\t'$$genre'\t'$$region/; \
			echo;\
		fi;\
	done | tee icepahc.tsv

proiel.tsv: conll-rdf
		cd ../../proiel;\
		make;
		for file in ../../proiel/*gothic*conll; do \
			genre=BIB;\
			c=4; h=2;\
			region=GOTH;\
			cat $$file | \
			sed s/'([^\t]*)'//g | # occurs in dependency labels, this can break the extractor \
			conll-rdf/run.sh CoNLLStreamExtractor file:`realpath $$file`'#' ID WORD LEMMA POS FINE_POS INFL HEAD EDGE | \
			conll-rdf/run.sh CoNLLRDFFormatter -query proiel.sparql |\
			egrep '.' | grep -v '^#' | \
			sed s/'$$'/'\t'$$c'\t'$$h'\t'$$genre'\t'$$region/;\
			echo;\
		done | tee proiel.tsv

greek.tsv: conll-rdf
		@# identical with proiel, for comparison with Greek NT
		cd ../../proiel;\
		make;
		for file in ../../proiel/*greek*conll; do \
			genre=BIB;\
			c=Greek;\
			cat $$file | \
			sed s/'([^\t]*)'//g | # occurs in dependency labels, this can break the extractor \
			conll-rdf/run.sh CoNLLStreamExtractor file:`realpath $$file`'#' ID WORD LEMMA POS FINE_POS INFL HEAD EDGE | \
			conll-rdf/run.sh CoNLLRDFFormatter -query proiel.sparql |\
			egrep '.' | grep -v '^#' | \
			sed s/'$$'/'\t'$$c'\t'$$h'\t'$$genre'\t'GK/;\
			echo;\
		done | tee greek.tsv


iswoc.tsv: conll-rdf
	@# identical to proiel workflow
	cd ../../iswoc;\
	make;
	# we use þ to identify OE data \
	for file in `egrep -i 'þ' -l $$(find ../../iswoc/ | grep '\.conll$$')`; do \
		echo $$file; \
		c=xx; h=x;\
		cat $$file | \
		sed s/'([^\t]*)'//g | # occurs in dependency labels, this can break the extractor \
		conll-rdf/run.sh CoNLLStreamExtractor file:`realpath $$file`'#' ID WORD LEMMA POS FINE_POS INFL HEAD EDGE | \
		conll-rdf/run.sh CoNLLRDFFormatter -query proiel.sparql |\
		egrep '.' | grep -v '^#' | \
		sed s/'$$'/'\t'$$c'\t'$$h'\t'$$genre'\t'OE/;\
		echo;\
	done | tee iswoc.tsv

tuebadz.tsv: tiger-rdf conll-rdf
	@# same preprocessing as ReF
	# see ../../tuebadz/Readme.md for instructions how to acquire and build ../../tuebadz/tiger.xml
	c=20;\
	h=2;\
	genre=NEWS;\
	region=SD;\
	python3 -u tiger-rdf/tiger/tiger2rdf.py ../../tuebadz/tiger.xml | \
	# some malformed sentences \
		conll-rdf/run.sh CoNLLRDFUpdater -custom -updates refprep.sparql  2>/dev/null | \
		conll-rdf/run.sh CoNLLRDFFormatter -query tueba.sparql |\
		egrep '.' | grep -v '^#' | \
		sed s/'$$'/'\t'$$c'\t'$$h'\t'$$genre'\ŧ'$$region/ | \
	tee tuebadz.tsv

ddb.tsv: powla conll-rdf
	cd ../../DDB;\
	make;
	for dir in ../../DDB/paula/*/; do # ../../DDB/paula/HenchI/; do \
		tgt=`basename $$dir`; \
		c=`egrep -m 1 $$tgt ../../DDB/meta.tsv | cut -f 2 `;\
		h=`egrep -m 1 $$tgt ../../DDB/meta.tsv | cut -f 3 `;\
		region=`egrep -m 1 $$tgt ../../DDB/meta.tsv | cut -f 4`;\
		cols="ID WORD MORPH POS PARSE";\
		if [ $$c -eq 9 ]; then \
			cols="ID WORD LEMMA MORPH POS PARSE";\
		fi;\
		echo '#' ddb.$$tgt.conll; \
		if [ ! -e ddb.$$tgt.conll ]; then \
			echo $$dir '>' ddb.$$tgt.conll 1>&2;\
			powla/experimental/paula/paula2conll.sh -split `dirname $$dir`/`basename $$dir` | \
			 tee ddb.$$tgt.conll;\
		else \
			cat ddb.$$tgt.conll; \
		fi | \
		grep -v '^#' | \
		sed s/'^\([0-9].*[^\s\t ]\)[\s\t ]*$$'/'\1\t'$$c'\t'$$h'\t'$$region/ | \
		conll-rdf/run.sh CoNLLBrackets2RDF '#' $$cols CENT HALF REGION 2>/dev/null ;\
		echo; \
	done | \
	conll-rdf/run.sh CoNLLRDFUpdater -custom -updates paulaprep.sparql 2>/dev/null | \
	tee ddb.ttl | \
	conll-rdf/run.sh CoNLLRDFFormatter -query ddbquery.sparql 2>/dev/null|\
#			cat; echo | \
	egrep '.' | grep -v '^#' | \
	sed s/'$$'/'\t'$$c'\t'$$h'\t'$$genre'\t'OOD/ | \
	tee ddb.tsv
