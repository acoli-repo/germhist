all:
	@echo check installation and convert demo corpus
	@echo for testing and human-readable output, run "make demo"
	@echo for converting the full corpus, run "make corpus"
	@bash -e ./rem_pipe.sh

demo:
	bash -e ./demo.sh

corpus:
	# tba
