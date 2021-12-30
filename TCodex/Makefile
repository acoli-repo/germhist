all: Tatian2.1

Tatian2.1:
	if [ ! -e tcodex.2.1.exm.zip ]; then \
		wget -nc https://www.laudatio-repository.org/download/format/6/18/2.1 -O tcodex.2.1.exm.zip;\
	fi;\
	for zip in tcodex.2.1.exm.zip exmaralda/EXMARaLDA_2-1.zip; do \
			unzip $$zip; rm $$zip;\
	done;\
	rmdir exmaralda
