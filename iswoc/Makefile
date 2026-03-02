all: iswoc-ang

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

