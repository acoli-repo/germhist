# Syntactic analysis of historical German

In this repository, we provide a number of corpora of historical German as well as example workflows
for their evaluation for designated research questions.

Data directly provided via this repository (e.g., for Middle High German), includes annotations produced by the ACoLi lab.
For external data, we provide build scripts to retrieve the necessary data.

## ACoLi corpora

### [`ReM/full_corpus/`](ReM): ReM Treebank / Baumbank Mittelhochdeutsch

  - Middle High German, 1050-1350
  - 2.2 million tokens
  - annotation layers:
    - POS/LEMMA/FEATS: manually annotation from Referenzkorpus Mittelhochdeutsch v.1.0 (external)
    - PARSE: phrase structure parse automatically produced by ACoLi (QuantQual project, 2017)

## External corpora

### [`ReF/`](ReF): ReF Treebank / Referenzkorpus Frühneuhochdeutsch

  - Early Modern High German, 1350-1650
  - 3.6 million tokens (0.6 million tokens with syntax)
  - annotation layers:
    - POS: manual annotation (no LEMMA)
    - PARSE: automatically produced phrase structure parse ([600.000 token subcorpus](ReF/ReF-v1.0.2/ref-up))

### [`GerManC/`](GerManC): GerManC corpus

  - Modern High German, 1650-1800
  - 0.8 million tokens
  - annotation layers:
    - POS/LEMMA/FEATS: manual annotation
    - HEAD/EDGE: MATE/TIGER-style (not UD-style!) dependencies

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
