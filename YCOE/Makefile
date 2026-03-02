all: ycoe

conll: ycoe
	@for file in `find ycoe | grep '\.psd$$'`; do \
		echo $$file;\
		tgt=conll/`basename $$file | sed s/'\.psd$$'//`.conll;\
		if [ ! -e $$tgt ]; then \
			echo $$file '>' $$tgt 1>&2;\
			if [ ! -e `dirname $$tgt` ]; then mkdir -p $$tgt; fi;\
			cat $$file \
			| perl -pe 's/\s+/ /g;' \
			| perl -pe 's/\((ID\s+[^\n)]*)\s*\)\s*\)'/'\)# \1\n\n'/g \
			| perl -pe 's/(( *\) *)+)/\1\n/g;' \
			| perl -pe 's/^(\(ID[^\n]*)\n/\1\n\n/g;' \
					-e 's/(\(CODE[^\n]*)\n/\1 /g;' \
					-e 's/([\*0][^\n]*\)[^\n]*)\n/\1 /g;' \
			| perl -pe 's/ +/ /g; s/^ //; s/ $$//;' \
			| perl -pe 's/(.*\()([^\(\) ]+) ([^\)\( ]+)(\)[^\(]*)\n/\3\t\2\t\1*\4\n/g;' \
			> $$tgt;\
		fi;\
	done

ycoe: 
	@if [ ! -e 2462.zip ]; then make 2462.zip; fi;\
	 unzip 2462.zip

2462.zip:
	@if [ ! -e 2462.zip ]; then \
		wget "https://llds.ling-phil.ox.ac.uk/llds/xmlui/bitstream/handle/20.500.14106/2462/2462.zip?sequence=4&isAllowed=y" -O 2462.zip;\
	fi || \
	(echo 'retrieval failed, please download manually from http://hdl.handle.net/20.500.14106/2462' 1>&2;\
	 exit 1;)
