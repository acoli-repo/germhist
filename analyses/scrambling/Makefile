all: rem.tsv

conll-rdf:
	@# replace with symlink if already installed
	git clone https://github.com/acoli-repo/conll-rdf

rem.tsv: conll-rdf
	for c in 11; do # 12 13 14 xx; do \
		for h in 1 2 x; do \
			for genre in P PV V P; do \
				echo ReM $$c $$h $$genre 1>&2;\
				cat ../../ReM/full_corpus/conll/*_$${c}-$${h}_$${genre}*conll | \
				conll-rdf/run.sh CoNLLBrackets2RDF '#' ID TID WORD POS LEMMA INFL PARSE ANIMACY | \
				conll-rdf/run.sh CoNLLRDFUpdater -custom -updates rem2tiger.sparql | \
				conll-rdf/run.sh CoNLLRDFFormatter -query remquery.sparql | egrep '.' | grep -v '^#' | \
				sed s/'$$'/'\t'$$c'\t'$$h'\t'$$genre/;\
				echo;\
			done;\
		done;\
	done | tee rem.tsv
