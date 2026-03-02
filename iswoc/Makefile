all: iswoc-ang doc

iswoc-ang: 
	@if [ ! -e iswoc-ang ]; then \
		make iswoc-treebank;\
		mkdir iswoc-ang;\
		FILES=`cat iswoc-treebank/README.md \
				| egrep 'Old English' \
				| egrep '\|' \
				| cut -f 3 -d '|';`;\
		for file in README.md $$FILES; do \
			cp iswoc-treebank/$$file* iswoc-ang/;\
		done;\
	fi;

iswoc-treebank:
	@if [ ! -e iswoc-treebank ]; then \
		git clone https://github.com/iswoc/iswoc-treebank.git;\
	fi;

doc:
	@if [ ! -e doc ]; then mkdir doc; fi;\
	 wget -nc https://dev.syntacticus.org/annotation-guide -O doc/annotation-guide.html;\
	 imgs=`cat doc/annotation-guide.html \
		 | perl -pe 's/\s+/ /g; s/>/>\n/g; s/</\n</g;'\
		 | grep '<img' \
		 | sed s/' '/'\n'/g \
		 | grep src= \
		 | cut -f 2 -d '"';`;\
	 cd doc;\
	 for img in $$imgs; do \
	 	wget -nc https://dev.syntacticus.org/$$img;\
	 done;\
	 cp annotation-guide.html annotation-guide.html.bak;\
	 cat annotation-guide.html.bak \
	 | perl -pe 's/src="\/[^"]*\//src="/g' \
	 > annotation-guide.html;\


