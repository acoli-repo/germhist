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
Synopsis: `DICT.TSV [-full] [-keepCase] [-encoding "ENCODING"] [ [ [ COL_SRC ] COL_TGT] COL_WORD ]`
				  `DICT.TSV`            dictionary in TSV format
				  `-full`               keep accents and `[^a-zA-Z]` when comparing `WORD` and `SRC` (default: ignore accents and `[^a-zA-z]`)
				  `-keepCase`           keep case when comparing `WORD` and `SRC` (default: lowercase)
				  `-encoding`           encoding for both input files and output (default: `UTF8`)
				  `COL_SRC`             source column in `DICT.TSV` (first column = 1), (default: `0`)
				  `COL_TGT`             target column in `DICT.TSV` (first column = 1), (default: `1`)
				  `COL_WORD`            column in the data file that contains the forms that are to be normalized (default: `1`)
				read CoNLL file from `stdin`, with normalize entries from `COL_WORD` according to `DICT.TSV`, add this as new column
				write to `stdout`

### AniImp
Synopsis: `animacySrc posColumn [animacyColumns+]`
				`animacySrc`           the source file with the lemma, POS and animacy
				`posColumn`            the column number (which start at 0) for the POS tag
				`animacycolumns+`      column numbers to be annotated (whitespace separated)
				looks up the lemmas given in `stdin` in the `animacycolumns` in the given `animacySrc`
				(ignores case and looks only for nouns)
				

### remToConll
Synopsis: `[-dir DIR] [-FtimeGenre] [-files FILENAME+] [-dest DEST] [-silent True/False]`
				`-dir`              set ReM XML files input directory ("./" default)
				`-FtimeGenre`       marking time and genre of the source document on the file name ("False" default)
				`-files`            filter list of ReM XML file names in ReM XML directory separated by whitespace 
				                   ("all" by default) - e.g. "M001-N1 M002-N1"
				`-dest`             set ReM CoNLL files output directory ("./" default)
				`-silent`           help="set logging to silent ("False" default)
				convert ReM CorA-XML to CoNLL format

## Authors

* **Christian Chiarcos** - chiarcos@informatik.uni-frankfurt.de
* **Christian Fäth** - faeth@em.uni-frankfurt.de
* **Benjamin Kosmehl** - bkosmehl@gmail.com

See also the list of [contributors](https://github.com/acoli-repo/germhist/graphs/contributors) who participated in this project.

## Reference

## Acknowledgments

This code here was mainly developed on the 
Goethe Universitat Frankfurt, Germany, within a project on ¨
Quantitative and Qualitative Methods in German Historical
Philology (QuantQual@CEDIFOR), at the Centre for the
Digital Foundation of Research in the Humanities, Social,
and Educational Sciences (CEDIFOR), funded by the
German Ministry of Research and Education (BMBF, first
phase 2014-2017). We would like to thank Ralf Plate, Arbeitsstelle Mittelhochdeutsches Worterbuch, Trier / Insti- ¨
tut fur Empirische Sprachwissenschaft, Goethe-Universit ¨ at ¨
Frankfurt, for the fruitful collaboration within this project.
Furthermore, we would like to thank Thomas Klein and
Claudia Wich-Reif for providing us with an access to the
ReM corpus even before its ultimate publication, as well as
Thomas Burch and the Trier Center for Digital Humanities, 
for the access to the digital Lexer dictionary data. We
would like to thank Margarete Springeth for access to the
Middle High German Conceptual Database (MHDBDB)
at the Universitat Salzburg. 

* Applied Computational Linguistics ([ACoLi](http://acoli.cs.uni-frankfurt.de))
* Linked Open Dictionaries ([LiODi](http://www.acoli.informatik.uni-frankfurt.de/liodi/)) - 01UG1631
* QuantQual@CEDIFOR ([QuantQual](http://acoli.cs.uni-frankfurt.de/projects.html#quantqual)) - 01UG1416A
* Trier Center for Digital Humanities ([TCDH](http://kompetenzzentrum.uni-trier.de/de/))
* Lexer by Trier Center for Digital Humanities ([Lexer](http://woerterbuchnetz.de/Lexer/))
* Middle High German Conceptual Database ([MHDBDB](http://mhdbdb.sbg.ac.at/))
* Reference Corpus of Middle High German ([ReM](https://www.linguistics.rub.de/rem/))  
  
## Licenses


This repository is being published under two licenses. 
Apache 2.0 is used for code, see [LICENSE.main](LICENSE.main.txt). 
CC-BY-SA 4.0 for all data from the ReM corpus and SPARQL scripts, see [LICENSE.data](LICENSE.data.txt).
  
### LICENCE.main (Apache 2.0)
```
├── src/  
```
### LICENCE.data (CC-BY 4.0)
```
├── res/  
│	├── data
│	├── sh
│	└── sparql
```

