# Syntactic analysis of historical German

In this repository, we provide a number of corpora of historical German as well as example workflows for their evaluation for designated research questions.
To compensate the lack of annotated data for Old High German, corpora from other older Germanic languages (Old English, Old Saxon, Gothic, Old Norse) are included here, too.

Primary contributions are:
- Annotations provided by the ACoLi Lab, natively distributed from this repository (e.g., for Middle High German)
- Build and retrieval script to acquire and preprocess external data into a unified RDF representation (see [`analyses/`](analyses))
- Evaluation scripts for a large-scale study of scrambling in historical German ([`analyses/scrambling`](analyses/scrambling))

## Table of Contents

  * [ACoLi corpora](#acoli-corpora)
    + [ReM Treebank / Baumbank Mittelhochdeutsch](#--rem-full-corpus----rem---rem-treebank---baumbank-mittelhochdeutsch)
  * [External corpora](#external-corpora)
    + [Tatian Corpus of Deviating Examples](#--tcodex----tcodex---tatian-corpus-of-deviating-examples)
    + [Deutsche Diachrone Baumbank](#--ddb----ddb---deutsche-diachrone-baumbank)
    + [ReF Treebank / Referenzkorpus Frühneuhochdeutsch](#--ref----ref---ref-treebank---referenzkorpus-fr-hneuhochdeutsch)
    + [Early New High German Treebank](#--enhg----enhg---early-new-high-german-treebank-by-caitlin-light)
    + [Mercurius](#--mercurius----mercurius---mercurius-treebank)
    + [Fuerstinnenkorrespondenz 1.1](#--fuerstinnen----fuestinnen---fuerstinnenkorrespondenz-11)
    + [GerManC](#--germanc----germanc---germanc-corpus)
    + [German UD corpora](#--ud----ud---ud-corpora)
  * [Corpora of other older Germanic languages](#corpora-of-other-older-germanic-languages)
    + [HeliPaD (Old Saxon)](#--helipad----helipad---helipad-corpus)
    + [YCOE (Old English)](#--ycoe----ycoe---the-york-toronto-helsinki-parsed-corpus-of-old-english-prose--ycoe-)
    + [ISWOC (Old English subcorpus)](#--iswoc----iswoc---iswoc-corpus--old-english-subcorpus)
    + [IcePaHC (Old Icelandic subcorpus)](#--icepahc----icepahc---icepahc-v09)
    + [PROIEL (Gothic subcorpus)](#--proiel----proiel---proiel--gothic-subcorpus)
  * [Analyses](#analyses)
  * [Other candidate corpora](#other-candidate-corpora)

## ACoLi corpora

### [`ReM/full_corpus/`](ReM): ReM Treebank / Baumbank Mittelhochdeutsch

  - Middle High German, 1050-1350
  - 2.2 million tokens (balanced)
  - annotation layers:
    - POS/LEMMA/FEATS: manually annotation from Referenzkorpus Mittelhochdeutsch v.1.0 (external)
    - PARSE: phrase structure parse automatically produced by ACoLi (QuantQual project, 2017)

## External corpora

### [`TCodex/`](TCodex): Tatian Corpus of Deviating Examples

  - Old High German, 830 (presumably literal translation from Latin, filtered for sentences with deviations in word order)
  - 13.000 tokens (Latin and Old High German)
  - annotation layers:
    - POS, MORPH, LEMMA:  manually
    - PARSE: shallow (non-recursive) phrase structure parse, manually

### [`DDB/`](DDB): Deutsche Diachrone Baumbank
    - Old High German (9th c.), Middle High German (13th c.), Early Modern High German (16th c.)
    - 8500 tokens *in total*
    - annotation layers:
      - POS, PARSE, MORPH: manually
      - LEMMA: manually (OHG only)
    - note: the data is marginal in size and the technical quality is poor (TIGER export for MHG and ENHG is broken -- instead, this is an Exmaralda file without syntax annotation; PAULA export is ok for original TIGER data [all languages], but merging failed [original Exmaralda files point to inexistent token file, however, these contain lemmatization only])
    - from the scrambling evaluation, the data is excluded as it contains only two examples of ditransitive verbs with postverbal nominal arguments

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

### [`fuerstinnen/`](fuerstinnen): Fuerstinnenkorrespondenz 1.1

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

### [`tuebadz/`](tuebadz): Tueba-D/Z

  - Modern High German, late 20th c.
  - 1.4 million tokens (news)
  - relevant annotation layers:
    - POS/LEMMA/FEATS
    - PARSE: phrase structure grammar plus topological fields plus syntactic heads
  - Corpus access requires registration, so we do not provide the data, but retrieval and build instructions as well as the result table `analysis/scrambling`.

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

We provide the workflow for Gothic in `analysis/scrambling`, but we excluded its results: Its word order preferences are identical to that of the Greek NT (that we studied for comparison). For postverbal nominal accusative and dative arguments, both show exactly the same preference for ACC>DAT (75.6%=34:11 Greek NT, 76.9%=20:6 Gothic NT; difference may be because the Gothic NT is incomplete).

## Analyses

[`analyses/`](analyses): Case studies over that data

We demonstrate the application of [Fintan](https://github.com/Pret-a-LLOD/Fintan)
(resp., [CoNLL-RDF](https://github.com/acoli-repo/conll-rdf) and related technologies integrated in Fintan)
for complex search and retrieval tasks in real-world research questions in linguistics and the philologies.

- [`analyses/scrambling`](analyses/scrambling): Study diachronic word order of post-verbal oblique arguments

## Other candidate corpora

- [HIPKON: Historisches Predigtenkorpus zum Nachfeld](https://www.laudatio-repository.org/browse/corpus/yiTKCnMB7CArCQ9CxLhJ/corpora)
  - annotations similar to Fuerstinnenkorpus and TCodex, i.e., shallow, span-based annotations, but with marking for grammatical roles
  - 92.500 tokens, Old High German, Middle High German, Early Modern High German, Modern High German
  - annotation is incomplete, covering only main clauses with complex verbal complex and post-field

- [Muspilli](https://www.laudatio-repository.org/browse/corpus/HiTACXMB7CArCQ9CDy3m/corpora)
  - Old High German, annotations corresponding to TCodex, but only 900 tokens

- [Historische Syntax des Jiddischen, Version 1.0](https://www.laudatio-repository.org/browse/corpus/8CRGCnMB7CArCQ9CUXL0/corpora)
  - Old and Middle Yiddish, shallow, span-based annotations in accordance with DDD plus marking of grammatical roles
  - 40k tokens
  - Except for the writing system, Old Yiddish was very similar to Middle High German, with increasing divergencies after the mid-14th c. only.

- Old Saxon corpus
  - Old Saxon (Old Low German), 750-1150
  - corpus is upcoming and built in-house
  - annotation layers:
    - POS/LEMMA/FEATS: manual annotation from DDD corpus and HeliPaD corpus
    - EDGE/HEAD: UD-style dependency parse extrapolated from DDD (partial, phrasal, manual) and HeliPaD (complete, phrasal, semiautomated)

- [Old Swedish Corpora of Sprakbanken](sprakbanken)
  - Old Swedish, 13th - 16th c.
  - We began processing these corpora, but at the moment, their annotation with dependency syntax has not been concluded yet (all files of the older strata have `deprel=""` or `deprel="__UNDEF__"`). To be revisited.
