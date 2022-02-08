all:
	@echo check installation and convert demo corpus
	@echo for testing and human-readable output, run "make demo"
	@echo for converting the full corpus, run "make corpus"
	@bash -e ./rem_pipe.sh

demo:
	bash -e ./demo.sh

corpus:
	@if [ ! -e full_corpus/orig/rem-corralled-20161222 ]; then \
		echo retrieve original ReM corpus;\
		if [ ! -d full_corpus/orig ]; then mkdir -p full_corpus/orig; fi;\
		if [ ! -e full_corpus/orig/index.html ]; then wget https://www.linguistics.rub.de/rem/access/index.html -O full_corpus/orig/index.html; fi;\
		wget -nc "https://zenodo.org/record/3624693/files/rem-corralled-20161222.tar.xz?download=1" -O full_corpus/orig/rem-corralled-20161222.tar.xz; \
		cd full_corpus/orig/; \
		tar -xvf rem-corralled-20161222.tar.xz; \
	fi
	@if [ ! -e metadata.json ]; then bash -e ./get_metadata.sh > metadata.json; fi;
	@if [ ! -d full_corpus/conll ]; then mkdir full_corpus/conll; fi
	@if [ ! -d full_corpus/ttlchunked ]; then mkdir full_corpus/ttlchunked; fi

	@if [ ! -d full_corpus/orig/conll ]; then \
		mkdir full_corpus/orig/conll; \
		pip3 install lxml; \
		python3 src/org/acoli/conll/quantqual/remToConll.py -dir full_corpus/orig/rem-corralled-20161222 -dest full_corpus/orig/conll -silent True; \
	fi;

	./rem_pipe.sh -data=full_corpus/orig/conll/ -out=full_corpus/
