all: annis-export.conll annis-export.tree.tsv annis-export.roles.tsv

annis-export.csv.gz:
	if [ ! -e annis-export.csv.gz ]; then \
		echo "retrieve Gieskane v.0.3 manually from ANNIS" 1>&2;\
		echo "- access via https://annis.germanistik.uni-giessen.de/#_q=b3J0aHNhdHo&ql=aql&_c=R2llc0thTmVfdjAuMw&cl=5&cr=5&s=0&l=10" 1>&2;\
		echo "- search for `node & tok & #1 _i_ #2`, CSVExporter. Note that this is incomplete, but still provides a *HUGE* dump ..." 1>&2;\
		echo "- gzip and store as "`pwd`"annis-export.csv.gz" 1>&2;\
		exit 1;\
	fi;

annis-export.tree.csv.gz:
	if [ ! -e annis-export.tree.csv.gz ]; then \
		echo "retrieve Gieskane v.0.3 tree structures manually from ANNIS" 1>&2;\
		echo "- access via https://annis.germanistik.uni-giessen.de/#_q=b3J0aHNhdHo&ql=aql&_c=R2llc0thTmVfdjAuMw&cl=5&cr=5&s=0&l=10" 1>&2;\
		echo "- search for `node > node`, CSVExporter. Note that we loose function labels" 1>&2;\
		echo "- gzip and store as "`pwd`"annis-export.tree.csv.gz" 1>&2;\
		exit 1;\
	fi;

# token-level annotations
annis-export.conll: annis-export.csv.gz
	@gunzip -c annis-export.csv.gz \
	| python3 tsv2jsonl.py -g 2_id -s 1_id \
	| tee annis-export.jsonl \
	| python3 jsonl2conll.py conll-config.jsonl -s 'POS=$$.' 'LEMMA=\.' -n \
	> annis-export.conll

# tree annotations
annis-export.tree.tsv: annis-export.tree.csv.gz
	@gunzip -c annis-export.tree.csv.gz \
	| python3 tsv2jsonl.py -g 2_id  \
	| tee annis-export.tree.jsonl \
	| python3 jsonl2conll.py tree-config.jsonl \
	> annis-export.tree.tsv

# grammatical role annotations
annis-export.roles.tsv:
	for file in *.csv.gz; do \
		if [ -e $$file ]; then \
			if basename $$file | grep -v annis-export >/dev/null; then \
				label=`basename $$file | cut -f 1 -d '.'`;\
				echo $$label 1>&2;\
				gunzip -c $$file \
				| sed s/"'NULL'"//g \
				| sed s/'\t.*\(salt:\)'/'\t\1'/g \
				| cut -f 1,2 \
				| sed s/'$$'/'\t'$$label/;\
			fi;\
		fi;\
	done\
	> annis-export.roles.tsv
