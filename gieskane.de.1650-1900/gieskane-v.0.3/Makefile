annis-export.csv.gz:
	if [ ! -e annis-export.csv.gz ]; then \
		echo "retrieve Gieskane v.0.3 manually from ANNIS" 1>&2;\
		echo "- access via https://annis.germanistik.uni-giessen.de/#_q=b3J0aHNhdHo&ql=aql&_c=R2llc0thTmVfdjAuMw&cl=5&cr=5&s=0&l=10" 1>&2;\
		echo "- search for `node & tok & #1 _i_ #2`, CSVExporter. Note that we loose function labels and that this is a *HUGE* dump ..." 1>&2;\
		echo "- gzip and store as "`pwd`"annis-export.csv.gz" 1>&2;\
	fi;
