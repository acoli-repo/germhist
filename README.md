# quantqual pipeline
toolset for a rule-based shallow parser based on CoNLL-RDF and SPARQL Update for parsing and an enrichment pipeline with the purpose of quantitative evaluation of a qualitative hypothesis on the corpus Referenzkorpus Mittelhochdeutsch (ReM) of Middle High German (MHG) syntax.
## Getting Started

The pipeline as such is a shell-based script calling various Java programs.
The pipeline is dependent on the CoNLL-RDF package: https://github.com/acoli-repo/conll-rdf (submodule linking included). 

Calling the quantqual pipeline contained in the rem_pipe.sh script out of the box will (CoNLL-RDF and Java required):
- use the sample ReM corpus files in CoNLL format provided in res/data/remdata
- annotate Modern German lemma using the Lexer dictionary data provided in res/data/lexerlemmas_1_to_1.tsv
- data stream based conversion (sentence-by-sentence) from CoNLL into RDF graphs
- rule-based shallow parsing using SPARQL Update scripts provided in res/sparql/chunking
- output linguistically structured data in accordance with the POWLA formalism in the Turle format

### Further optional steps for the rem_pipe.sh need additional attention (overview):
The full ReM corpus can be manually downloaded from https://www.linguistics.rub.de/rem/access/index.html (we recommend the version in CorA-XML format).
For a initial ReM corpus conversion from CorA-XML to CoNLL a simple Python script is provided: remToConll.py (usage described bellow). For which Python (3.x) is required.

For the additional enrichment of the data with alternative Modern German lemma with the Köbler dictionary data we provide a download and conversion script (wget, xmllint and saxon for Bash are required).
Once the Köbler dictionary data is successfully converted and stored in res/data/mhd-koebler.tsv (default) it is ready for use with the pipeline.

For the additional enrichment of the data with animacy annotations we provided some conversion tools. The WordNet and GermaNet data required is not included here.
Once the animacy data is successfully converted and stored in res/data/animacy-de.csv (default) it is ready for use with the pipeline.

These additional steps can be applied independently.

## Description

The main file is the rem_pipe.sh containing the pipeline for annotating, converting and parsing the ReM corpus data. 
Input for the pipeline are files in the CoNLL format.
Output are linguistically structured RDF graph data in the Turtle file format.
The structure of the pipeline is as follows:
```
*.conll files
├── Lexer, Köbler dictionary data in *.csv
├── animacy data in *.tsv
conversion conll into rdf
├── rule based shallow parsing through *.sparql
*.ttl files
```

In addition we provide some convenience scripts and tools to get and convert additional data not provided here into formats used in the pipeline.

### Usage
The pipeline can be configured inside the rem_pipe.sh file (adjust paths, usage of Transliterator, chunking steps, etc).

### Transliterator
Synopsis: DICT.TSV [-full] [-keepCase] [-encoding \"ENCODING\"] [ [ [ COL_SRC ] COL_TGT] COL_WORD ]
				  DICT.TSV            dictionary in tsv format
				  -full               keep accents and [^a-zA-Z] when comparing WORD and SRC (default: ignore accents and [^a-zA-z]]
				  -keepCase           keep case when comparing WORD and SRC (default: lowercase)
				  -encoding \"UTF8\"  encoding for both input files and output - default is UTF8
				  COL_SRC             source column in DICT.TSV (first column = 1), by default 0
				  COL_TGT             target column in DICT.TSV (first column = 1), by default 1
				  COL_WORD            column in the data file that contains the forms that are to be normalized, by default 1
				read CoNLL file from stdin, with normalize entries from COL_WORD according to DICT.TSV, add this as new column
				write to stdout

### AniImp
Synopsis: animacySrc posColumn [animacyColumns+]
				animacySrc the source file with the lemma, pos and animacy
				posColumn the column number (which start at 0) for the POS tag
				animacycolumns+ column numbers to be annotated (whitespace separated)
				looks up the lemmas given in stdin in the animacycolumns in the given animacySrc
				(ignores case and looks only for nouns)
				

### remToConll
Synopsis: [-mode MODE] [-dir DIR] [-filename FILENAME] [-files FILENAME+] [-dest DEST] [-silent True/False]
    -mode", default="dirdir", help="set mode for input and output ("dirdir" default) - combination of "stdin" "stdout" or "dir" in order input>output
    -dir", default="./", help="set ReM XML files input directory ("./" default)
    -filename", default="stdin", help="set file name for input via stdin for output into a specific file
    -files", default="all", help="filter list of ReM XML file names in ReM XML directory separated by whitespace ("all" by default) - e.g. "M001-N1 M002-N1"
    -dest", default="./", help="set ReM CoNLL files output directory ("./" default)
    -silent", default="False", help="set logging to silent ("false" default)
  convert ReM CorA-XML to CoNLL format

## Authors

* **Christian Chiarcos** - chiarcos@informatik.uni-frankfurt.de
* **Christian Fäth** - faeth@em.uni-frankfurt.de
* **Benjamin Kosmehl** - bkosmehl@gmail.com

See also the list of [contributors](https://github.com/acoli-repo/conll-rdf/graphs/contributors) who participated in this project.

## Reference

## Acknowledgments

  
## Licenses


This repository is being published under two licenses. Apache 2.0 is used for code, see [LICENSE.main](LICENSE.main.txt). CC-BY 4.0 for all data from universal dependencies and SPARQL scripts, see [LICENSE.data](LICENSE.data.txt).
  
### LICENCE.main (Apache 2.0)
```
├── src/  
```
### LICENCE.data (CC-BY 4.0)
  
  