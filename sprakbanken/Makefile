all: data

data:
	mkdir data
	cd data;
	wget -nc https://spraakbanken.gu.se/lb/resurser/meningsmangder/fsv-aldrelagar.xml.bz2;\
	wget -nc https://spraakbanken.gu.se/lb/resurser/meningsmangder/fsv-aldrereligiosprosa.xml.bz2;\
	wget -nc https://spraakbanken.gu.se/lb/resurser/meningsmangder/fsv-profanprosa.xml.bz2; \
	wget -nc https://spraakbanken.gu.se/lb/resurser/meningsmangder/fsv-verser.xml.bz2; \
	for file in *.bz2; do bunzip2 $$file; done
	#for file in *.xml; do python3 fsv2conll.py $$file > $$file.conll; done
