# quantqual pipeline
toolset for a rule-based shallow parser based on CoNLL-RDF and SPARQL Update for parsing and an enrichment pipeline with the purpose of quantitative evaluation of a qualitative hypothesis on the corpus Referenzkorpus Mittelhochdeutsch (ReM) of Middle High German (MHG) syntax.
## Getting Started

The pipeline as such is a Bash based script calling various Java programs.
The pipeline is dependent on the CoNLL-RDF package: https://github.com/acoli-repo/conll-rdf (submodule linking included). 

Calling the quantqual pipeline contained in the rem_pipe.sh script out of the box will (CoNLL-RDF and Java required):
- use the sample ReM corpus files in CoNLL format provided in res/data/remdata
- annotate Modern German lemma using the Lexer dictionary data provided in res/data/lexerlemmas_1_to_1.tsv
- data stream based conversion (sentence-by-sentence) from CoNLL into RDF graphs
- ruled-based shallow parsing using SPARQL Update scripts provided in res/sparql/chunking
- output linguistically structured data in accordance with the POWLA formalism in the Turle format

### Further optional steps for the rem_pipe.sh need additional attention (overview):
The full ReM corpus can be manually downloaded from https://www.linguistics.rub.de/rem/access/index.html (we recommend the version in CorA-XML format).
For a initial ReM corpus conversion from CorA-XML to CoNLL a simple Python script is provided: remToConll.py (usage described bellow). For which Python (3.x) is required.

For the additional enrichment of the data with alternative Modern German lemma with the Köbler dictionary data we provide a download and conversion script (wget, xmllint and saxon for Bash are required).
Once the Köbler dictionary data is successfully converted and stored in res/data/mhd-koebler.tsv (default) it is ready for use with the pipeline.

For the additional enrichment of the data with animacy annotations we provided some conversion tools. The WordNet and GermaNet data required is not included here.
Once the animacy data is successfully converted and stored in res/data/animacy-de.csv (default) it is ready for use with the pipeline.

All these additional steps can be applied independently.

## Description

### Usage
