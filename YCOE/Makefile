all: ycoe

ycoe: 
	@if [ ! -e 2462.zip ]; then make 2462.zip; fi;\
	 unzip 2462.zip

2462.zip:
	@if [ ! -e 2462.zip ]; then \
		wget "https://llds.ling-phil.ox.ac.uk/llds/xmlui/bitstream/handle/20.500.14106/2462/2462.zip?sequence=4&isAllowed=y" -O 2462.zip;\
	fi || \
	(echo 'retrieval failed, please download manually from http://hdl.handle.net/20.500.14106/2462' 1>&2;\
	 exit 1;)
