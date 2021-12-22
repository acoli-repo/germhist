# Syntactically annotated corpora of historical German

At the moment, we provide the following corpora. All of these build on existing corpora, with a layer of syntactic annotation added.

- [`ReM/full_corpus/`](ReM): ReM Treebank / Baumbank Mittelhochdeutsch
  - Middle High German, 1050-1350
  - 2.2 million tokens
  - annotation layers:
    - POS/LEMMA/FEATS: manually annotation from Referenzkorpus Mittelhochdeutsch v.1.0
    - PARSE: phrase structure parse automatically produced by ACoLi (QuantQual project, 2017)
    - ANIMACY: automatically annotated by ACoLi (Quant)
    - TODO: EDGE/HEAD: UD-style dependency parse extrapolated from PARSE

- ReF: ReF Treebank
  - Early Modern High German, 1350-1650
  - annotation layers:
    - POS/LEMMA/FEATS: manual annotation in ReF
    - PARSE: phrase structure parse automatically produced by the ReF project
    - TODO: EDGE/HEAD: UD-style dependency parse extrapolated from PARSE

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
