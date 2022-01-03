# Syntactic analysis of historical German

In this repository, we provide a number of corpora of historical German as well as example workflows for their evaluation for designated research questions.
To compensate the lack of annotated data for Old High German, corpora from other older Germanic languages (Old English, Old Saxon, Gothic, Old Norse) are included here, too.

Data directly provided via this repository (e.g., for Middle High German), includes annotations produced by the ACoLi lab.
For external data, we provide build scripts to retrieve the necessary data.

## ACoLi corpora

### [`ReM/full_corpus/`](ReM): ReM Treebank / Baumbank Mittelhochdeutsch

  - Middle High German, 1050-1350
  - 2.2 million tokens (balanced)
  - annotation layers:
    - POS/LEMMA/FEATS: manually annotation from Referenzkorpus Mittelhochdeutsch v.1.0 (external)
    - PARSE: phrase structure parse automatically produced by ACoLi (QuantQual project, 2017)

## External corpora of historical German

### [`TCodex/`](TCodex): Tatian Corpus of Deviating Examples

  - Old High German, 830 (presumably literal translation from Latin, filtered for sentences with deviations in word order)
  - 13.000 tokens (Latin and Old High German)
  - annotation layers:
    - POS, MORPH, LEMMA:  manually
    - PARSE: shallow (non-recursive) phrase structure parse, manually

### [`ReF/`](ReF): ReF Treebank / Referenzkorpus Frühneuhochdeutsch

  - Early Modern High German, 1350-1650
  - 3.6 million tokens (0.6 million tokens with syntax) (balanced)
  - annotation layers:
    - POS: manual annotation (no LEMMA)
    - PARSE: automatically produced phrase structure parse ([600.000 token subcorpus](ReF/ReF-v1.0.2/ref-up))

### [`ENHG/`](ENHG): Early New High German Treebank by Caitlin Light

  - Early Modern High German (Saxonian), 1522
  - 0.1 million tokens
  - annotation layers:
    - POS, PARSE: semiautomatically (no LEMMA)

### [`Mercurius/`](Mercurius): Mercurius Treebank

  - Early Modern High German, 1597/1667
  - 0.2 million tokens
  - annotation layers:
    - POS, PARSE: semiautomatically (no LEMMA, no MORPH)
  - note: the schema is supposed to be identical to ReF, but it uses VP instead of CL. As VP excludes the pre-field, this allows us to skip tests for word order. This means that we also retrieve results from middle fields of relative clauses, so the total number of matches is higher than from ReF.

### [`fuerstinnen/`](fuestinnen): Fuerstinnenkorrespondenz 1.1

  - Early Modern High German/Modern High German, 1546-1756
  - 0.2 million tokens (letters)
  - annotation layers:
    - POS/LEMMA/FEATS: manual annotation
    - shallow (non-recursive) phrase structure parse, manually

### [`GerManC/`](GerManC): GerManC corpus

  - Modern High German, 1650-1800
  - 0.8 million tokens (balanced)
  - annotation layers:
    - POS/LEMMA/FEATS: manual annotation
    - HEAD/EDGE: MATE/TIGER-style (not UD-style!) dependencies

### [`UD/`](UD): UD corpora

  Note that none of these corpora are balanced.

  - HDT: Hamburg Dependency Treebank
    - Modern High German, 1996-2001
    - 3.8 million tokens (news)
    - annotation layers:
      - POS/LEMMA/FEATS: tbc: manual or automated?
      - HEAD/EDGE: CoNLL-U dependencies, automatically converted

  - GSD: German legacy treebank
    - Modern High German, 1990s-2010s
    - 0.3 million tokens (news + online reviews)
    - annotation layers:
      - POS/LEMMA/FEATS: automated
      - HEAD/EDGE: CoNLL-U dependencies, automatically converted

  - LIT: German literary history
    - Modern High German, end of 18th c.
    - 40.000 tokens
    - provenance of annotation is unclear. semiautomated?

## Corpora of other older Germanic languages

This is external data that helps to illuminate the syntax of older West Germanic. Unfortunately, syntactically annotated corpora for Old High German are too sparse, and the witnesses themselves are heavily influenced by (i.e., often literal translations of) Latin, so that external evidence from related language varieties is needed to confirm observations over the sparse OHG data.

### [`helipad/`](helipad): HeliPaD corpus

This is a corpus of Old Saxon (Old Low German), based on a single text, only, the Heliand, main witness of the Old Saxon language.

  - Old Saxon (830), poetry
  - 48.000 tokens (BIB)
  - annotation layers:
    - POS: semiautomated
    - PARSE: semiautomated, annotations and extraction corresponds to those of ENHG and YCOE, but uses OB1 (instead of ACC) for direct object and OB2 (instead of DAT) for indirect object.

### [`YCOE/`](YCOE): The York-Toronto-Helsinki Parsed Corpus of Old English prose (YCOE)

Note that for legal reasons, we provide neither the corpus nor a build script, but an analysis workflow only, as well as its results. For replication, please acquire the corpus.

  - Old English (600-1150), prose
  - 1.5 million tokens (multiple genres)
  - annotation layers:
    - POS: semiautomated (?)
    - PARSE: semiautomated (?), annotations and extraction corresponds to those of ENHG

### [`iswoc/`](iswoc): ISWOC corpus, Old English subcorpus

Syntactically annotated open source edition of 5 major OE texts. Overlaps with YCOE, but uses a different schema. Pipeline and query identical to PROIEL.

    - Old English
    - 28.000 tokens (different genres)
    - annotation layers:
      - POS, INFL, LEMMA: semiautomated (?)
      - HEAD/EDGE: semiautomated, according to the PROIEL/ISWOC schema

### [`icepahc/`](icepahc): IcePaHC v.0.9

A corpus of historical Icelandic, in analysis, we operate with the Old Icelandic subset (texts prior to 1500):

    - Old Norse (Old Icelandic), (12th-16th c.)
    - 0.4 million tokens (balanced)
    - annotation layers:
      - POS: semiautomated (?)
      - PARSE: semiautomated (?), annotations and extraction corresponds to those of ENHG

### [`proiel/`](proiel): PROIEL, Gothic subcorpus

Syntactically annotated edition of the Wulfila Bible.

    - Gothic (second half of the 4th c.)
    - 56.000 tokens (biblical, but translated from Greek)
    - annotation layers:
      - POS, INFL, LEMMA: semiautomated (?)
      - HEAD/EDGE: semiautomated, according to the PROIEL/ISWOC schema

## Analyses

[`analyses/`](analyses): Case studies over that data

We demonstrate the application of [Fintan](https://github.com/Pret-a-LLOD/Fintan)
(resp., [CoNLL-RDF](https://github.com/acoli-repo/conll-rdf) and related technologies integrated in Fintan)
for complex search and retrieval tasks in real-world research questions in linguistics and the philologies.

- [`analyses/scrambling`](analyses/scrambling): Study diachronic word order of post-verbal oblique arguments

## Other candidate corpora

- Old Saxon corpus
  - Old Saxon (Old Low German), 750-1150
  - corpus is upcoming and built in-house
  - annotation layers:
    - POS/LEMMA/FEATS: manual annotation from DDD corpus and HeliPaD corpus
    - EDGE/HEAD: UD-style dependency parse extrapolated from DDD (partial, phrasal, manual) and HeliPaD (complete, phrasal, semiautomated)

- DDB corpus, see [`DDB/`](DDB)
  - Old High German (TIGER), only 2800 tokens
  - Early Modern High German and Middle High German data are corrupt. Instead of TIGER, this contains partially annotated Exmaralda, only
  - MHG and ENHG data lacks provenance and dating information. Not usable for our purposes.
