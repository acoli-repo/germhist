SHELL=bash

all: structured

orig: 
	if [ ! -e orig ]; then make update_orig; fi

update_orig:
	if [ ! -e orig ]; then mkdir orig; fi
	cd orig;\
	wget -nc https://ipchg.iu.edu/_php/feeds/corpora/download-zip.php -O corpora.zip;\
	unzip -u corpora.zip;\
	rm corpora.zip;

structured: orig
	ood="austria|bavaria|vienna";\
	wod="swabia|switzerland|alsace";\
	omd="saxony|thuringia";\
	wmd="cologne|hesse|historia|moselfr|srhfrk";\
	for dir in wod ood wmd omd; do \
		if [ ! -e structured/$$dir ] ; then mkdir -p structured/$$dir; fi;\
	done;\
	for file in orig/*.txt; do \
		if echo $$file | egrep $$ood >& /dev/null; then \
			cp $$file structured/ood;\
		else if echo $$file | egrep $$wod >& /dev/null; then \
			cp $$file structured/wod;\
		else if echo $$file | egrep $$omd >& /dev/null; then \
			cp $$file structured/omd/;\
		else if echo $$file | egrep $$wmd >& /dev/null; then \
			cp $$file structured/wmd/;\
		else \
			echo WARNING: file $$file cannot be assigned to a region 1>&2;\
			cp $$file structured/;\
		fi; fi; fi; fi; \
	done;


