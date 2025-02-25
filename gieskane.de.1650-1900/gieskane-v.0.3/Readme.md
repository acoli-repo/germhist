# GiesKaNe corpus

Modern High German, 1650-1900

Unfortunately, the corpus is **not available as a dataset**. We can retrieve parts of the annotation from a corpus management system, but this does not include annotations for syntax. In the context of GermHist, the corpus is thus currently unusable.

For building the corpus and storing it in `annis-export.conll`, run

    $> make

The corpus is built over DTA, the added value in comparison to DTA is marginal. Apparently, the morphosyntactic annotations have been manually corrected.

## Corpus information

- see https://www.uni-giessen.de/de/fbz/gieskane/korpus/zugang
- corpus composition: https://www.uni-giessen.de/de/fbz/gieskane/korpus/korpustexte
  - source urls are provided and can be used for automated alignment
- doesn't seem to be properly released yet
- ANNIS access https://annis.germanistik.uni-giessen.de/#_q=b3J0aHNhdHo&ql=aql&_c=R2llc0thTmVfdjAuMw&cl=5&cr=5&s=0&l=10
- strategies for retrieval
   - **FAILED** search for "orthsatz", then "export" and export via GridExporter (set preceding and following context to 0) results in file with sentence numbers, only
   - **FAILED** search for "tok", GridExporter, +-1 token, results in list of numbers (no annotations whatsoever)
   - **FAILED** search for "tok", CSVExporter, nur plain text export
   - search for `node & tok & #1 _i_ #2`, CSVExporter. we loose the function labels ... and this is a **huge** dump (650MB), from which word-level annotation can be recovered
- note that this export is limited to token-level annotations, so we loose all span annotations

TODO:
- check whether `node & tok & #2 _i_ #1` retrieves a larger dump. Then, the order of `_i_` was incorrectly documented.