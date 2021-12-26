# Syntactic analysis of historical German

In this repository, we provide a number of corpora of historical German as well as example workflows
for their evaluation for designated research questions.

Data directly provided via this repository (e.g., for Middle High German), includes annotations produced by the ACoLi lab.
For external data, we provide build scripts to retrieve the necessary data.

## ACoLi corpora

### [`ReM/full_corpus/`](ReM): ReM Treebank / Baumbank Mittelhochdeutsch

  - Middle High German, 1050-1350
  - 2.2 million tokens (balanced)
  - annotation layers:
    - POS/LEMMA/FEATS: manually annotation from Referenzkorpus Mittelhochdeutsch v.1.0 (external)
    - PARSE: phrase structure parse automatically produced by ACoLi (QuantQual project, 2017)

## External corpora

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

## Analyses

[`analyses/`](analyses): Case studies over that data

We demonstrate the application of [Fintan](https://github.com/Pret-a-LLOD/Fintan)
(resp., [CoNLL-RDF](https://github.com/acoli-repo/conll-rdf) and related technologies integrated in Fintan)
for complex search and retrieval tasks in real-world research questions in linguistics and the philologies.

- [`analyses/scrambling`](analyses/scrambling): Study diachronic word order of post-verbal oblique arguments

## Upcoming attractions

- ENHG Treebank
  - Early Modern High German, Eastern Central (Saxonian), 1522
  - annotation layers:
    - POS/LEMMA/FEATS: manual annotation by Caitlin Light
    - PARSE: semiautomate (?) annotation by Caitlin Light
    - TODO: EDGE/HEAD: UD-style dependency parse extrapolated from PARSE

- Old Saxon corpus
  - Old Saxon (Old Low German), 750-1150
  - annotation layers:
    - POS/LEMMA/FEATS: manual annotation from DDD corpus and HeliPaD corpus
    - EDGE/HEAD: UD-style dependency parse extrapolated from DDD (partial, phrasal, manual) and HeliPaD (complete, phrasal, semiautomated)
