all: prep
	rem.tsv

prep:
	@# replace with symlink if already installed
	for component in conll-rdf; do # conll-merge tiger-rdf LLODifier powla; do \
		if [ ! -e $$component ]; then \
			if [ ! -e ../scrambling/$$component ]; then \
				cd ../scrambling/; make $$component; cd -; \
			fi;\
			ln -s ../scrambling/$$component .;\
		fi;\
	done;

rem.tsv: prep ../scrambling/rem2tiger.sparql
	@cd ../../ReM;\
	if [ ! -e full_corpus/ttlchunked ]; then make; fi; 
	@# these for loops below are actually costly
	@for c in 11 12 13 14 xx; do \
		for h in 1 2 x; do \
			for genre in P PV V P; do \
				echo ReM $$c $$h $$genre 1>&2;\
				for file in ../../ReM/full_corpus/ttlchunked/*_$${c}-$${h}_$${genre}*ttl; do \
					if [ -e $$file ]; then \
						echo $$file 1>&2;\
						id=`basename $$file | sed s/'_.*'//`;\
						# the following line is fairly slow \
						orig_region=`cat ../../ReM/metadata.json | jq '.[] | ."'$$id'" | ."language-region"' | grep -m 1 '"' | sed s/'"'//g`;\
						region=`echo $$orig_region | \
								sed -e s/'westmitteldeutsch'/'WMD'/g \
										-e s/'o[st]*mitteldeutsch'/'OMD'/g \
										-e s/'[a-z]*mitteldeutsch'/'MD'/g \
										-e s/'ostoberdeutsch'/'OOD'/g \
										-e s/'westoberdeutsch'/'WOD'/g \
										-e s/'[a-z]*oberdeutsch'/'OD'/g \
										-e s/'[a-z]*niederdeutsch'/'ND'/g \
										-e s/'[a-z][a-z]*'/'_'/g`;\
						#echo ReM $$id $$c $$h $$genre $$orig_region $$region 1>&2;\
						# echo '# '$$file;\
						cat $$file | \
						conll-rdf/run.sh CoNLLRDFFormatter -query remquery.sparql | \
						egrep '.' | grep -v '^#' | \
						sed s/'$$'/'\t'$$c'\t'$$h'\t'$$genre'\t'$$region/;\
						# echo;\
					fi;\
				done;\
			done;\
		done;\
	done | \
	grep -v '^#' | \
	grep . | \
	tee rem.tsv

