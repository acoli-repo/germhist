# QuantQual Parser / Treebank edition of the Referenzkorpus Mittelhochdeutsch  

The QuantQual@CEDIFOR project (funded by BMBF via the CEDIFOR eHumanities cluster, Feb - Nov 2017) created the first syntactic parser for Middle High German.
In this repository, we provide a syntactically and semantically annotated edition of the Referenzkorpus Mittelhochdeutsch (ReM) and the pipeline used to create it from the existing morphosyntactic annotations.

To the best of our knowledge, this is the first syntactically annotated corpus for Middle High German.

However, note that our annotations are done in a fully automated way, using
- a rule-based parser based on CoNLL-RDF and SPARQL Update,
- transliteration- and lookup-based lemmatization and hyperlemmatization,
- lookup-based annotation for semantic features (animacy), using a manually curated gazetteer derived from GermaNet

The reason is that there are no training data for building a parser. Accordingly, we constructed a rule-based system, based on existing morphosyntactic annotations and using CoNLL-RDF and SPARQL.

The ReM treebank is built with the purpose of quantitative evaluation of qualitative hypotheses on the origins and the development of nominal word order of postverbal arguments in historical German. For this application, a number of simplifications were feasible. In particular, we apply low PP attachment as a rule, as we focus on accusative and dative arguments.

Although the annotation will already suffice to conduct search and some quantitative analyses, it should be noted that a full
evaluation has not been possible due to the lack of gold data. Instead, we performed a qualitative evaluation in cooperation with Ralf Plate, Academy Mainz.
We expect our treebank edition to serve as a basis for a subsequent manual revision.

We provide
- linking ReM with two lexical resources for Middle High German (Lexer and Koebler)
- dictionary-based annotation for animacy, based on both dictionaries and a manually curated mapping file derived from the GermaNet (German WordNet), values: `_` (undefined), `none`, `inanimate` (incl. abstract nouns), `animate`, `human`. We do not disambiguate, so every lexical match will return all possible animacy features. Duplicate values of the same feature mean that these are retrieved from different modern German hyperlemmas  
- shallow syntactic parse (chunking), focusing on nominal chunks and topological fields. The annotation is not exhaustive, and constellations not covered by our parser are marked by `Frag` nodes in the parse tree.
- tool chain to produce these annotations


## Getting Started

For a sample run with human-readable output, run

    $> make demo

For test run on sample corpus, run

    $> make

See Usage below for requirements and technical details.

## Usage

The pipeline as such is a shell-based script calling various Java programs, wrapped into `Makefile`.

### make

For a test run on sample corpus, run

    $> make

For building the complete ReM corpus under `full_corpus`, run

    $> make corpus

Note that

Requirements:
- make
- Java
- xmllint, install using `sudo apt install libxml2` (Ubuntu 20.4)
- Saxon, check installation parameters in `config`
- CoNLL-RDF, check installation parameters in `config`

The pipeline can be configured inside the `config` (adjust paths and dependencies). For more advanced changes to the default set up (usage of Transliterator, chunking steps, etc), edit `rem_pipe.sh`

The build scripts are wrapped into `Makefile`:
- use the sample ReM corpus files in CoNLL format provided in res/data/remdata
- annotate Modern German lemma using the Lexer dictionary data provided in res/data/lexerlemmas_1_to_1.tsv
- data stream based conversion (sentence-by-sentence) from CoNLL into RDF graphs
- rule-based shallow parsing using SPARQL Update scripts provided in res/sparql/chunking
- output parsed data in Turtle format (`out/ttlchunked`, using POWLA and CoNLL-RDF)
- output parsed data in (our) CoNLL format (`out/conll`), columns: ID TID WORD POS LEMMA INFL PARSE ANIMACY

### rem_pipe.sh

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

### Further optional steps for the rem_pipe.sh need additional attention (overview):

The full ReM corpus can be manually downloaded from https://www.linguistics.rub.de/rem/access/index.html (we recommend the version in CorA-XML format).
For a initial ReM corpus conversion from CorA-XML to CoNLL a simple Python script is provided: remToConll.py (usage described bellow). For which Python (3.x) is required.

For the additional enrichment of the data with alternative Modern German lemma with the Köbler dictionary data we provide a download and conversion script (wget, xmllint and saxon for Bash are required).
Once the Köbler dictionary data is successfully converted and stored in res/data/mhd-koebler.tsv (default) it is ready for use with the pipeline.

For the additional enrichment of the data with animacy annotations we provided some conversion tools. The WordNet and GermaNet data required is not included here.
Once the animacy data is successfully converted and stored in res/data/animacy-de.csv (default) it is ready for use with the pipeline.

These additional steps can be applied independently.

### Hyperlemmatization: Transliterator


Synopsis: ```DICT.TSV [-full] [-keepCase] [-encoding "ENCODING"] [ [ [ COL_SRC ] COL_TGT] COL_WORD ]```
  * `DICT.TSV`            dictionary in TSV format
  * `-full`               keep accents and `[^a-zA-Z]` when comparing `WORD` and `SRC` (default: ignore accents and `[^a-zA-z]`)
  * `-keepCase`           keep case when comparing `WORD` and `SRC` (default: lowercase)
  * `-encoding`           encoding for both input files and output (default: `UTF8`)
  * `COL_SRC`             source column in `DICT.TSV` (first column = 1), (default: `0`)
  * `COL_TGT`             target column in `DICT.TSV` (first column = 1), (default: `1`)
  * `COL_WORD`            column in the data file that contains the forms that are to be normalized (default: `1`)

    read CoNLL file from `stdin`, with normalize entries from `COL_WORD` according to `DICT.TSV`, add this as new column
    write to `stdout`


### Animacy annotation: AniImp


Synopsis: ```animacySrc posColumn [animacyColumns+]```
  * `animacySrc`           the source file with the lemma, POS and animacy
  * ``posColumn`            the column number (which start at 0) for the POS tag
  * `animacycolumns+`      column numbers to be annotated (whitespace separated)

    looks up the lemmas given in `stdin` in the `animacycolumns` in the given `animacySrc`
    (ignores case and looks only for nouns)


### Data preprocessing: remToConll

Synopsis: `[-dir DIR] [-FtimeGenre] [-files FILENAME+] [-dest DEST] [-silent True/False]`
  * `-dir`              set ReM XML files input directory ("./" default)
  * `-FtimeGenre`       marking time and genre of the source document on the file name ("False" default)
  * `-files`            filter list of ReM XML file names in ReM XML directory separated by whitespace ("all" by default) - e.g. "M001-N1 M002-N1"
  * `-dest`             set ReM CoNLL files output directory ("./" default)
  * `-silent`           help="set logging to silent ("False" default)

    convert ReM CorA-XML to CoNLL format


## Authors

* **Christian Chiarcos** - chiarcos@informatik.uni-frankfurt.de
* **Christian Fäth** - faeth@em.uni-frankfurt.de
* **Benjamin Kosmehl** - bkosmehl@gmail.com

See also the list of [contributors](https://github.com/acoli-repo/germhist/graphs/contributors) who participated in this project.

## Acknowledgments

This code here was mainly developed on the
Goethe Universitat Frankfurt, Germany, within a project on
Quantitative and Qualitative Methods in German Historical
Philology (QuantQual@CEDIFOR), at the Centre for the
Digital Foundation of Research in the Humanities, Social,
and Educational Sciences (CEDIFOR), funded by the
German Ministry of Research and Education (BMBF, first
phase 2014-2017). We would like to thank Ralf Plate, Arbeitsstelle Mittelhochdeutsches Worterbuch, Trier / Institut fur Empirische Sprachwissenschaft, Goethe-Universit at
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

For licensing information on the Treebank Edition of the ReM corpus, see [`full_corpus/`](full_corpus/Readme.md).
