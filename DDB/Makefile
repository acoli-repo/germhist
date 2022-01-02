all: tiger-negra

tiger-negra:
	if [ ! -e DDB.zip ]; then wget https://www.laudatio-repository.org/download/format/22/43/1.0 -O DDB.zip; fi
	unzip DDB.zip
	cd tiger-negra;\
	unzip *.zip;\
	mv TIGER-Negra/*/ .;\
	rmdir TIGER-Negra
