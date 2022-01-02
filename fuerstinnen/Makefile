all: exb

exb:
	if [ ! -e fuerstinnen.exb.zip ] ; then wget -nc https://www.laudatio-repository.org/download/format/23/46/1.1 -O fuerstinnen.exb.zip; fi
	unzip -u fuerstinnen.exb.zip
	cd exb;\
	for file in *zip; do \
		unzip -o -j $$file;\
	done;\
	rm *zip
