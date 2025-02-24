# GiesKaNe corpus

Modern High German, 1650-1900

- see https://www.uni-giessen.de/de/fbz/gieskane/korpus/zugang
- corpus composition: https://www.uni-giessen.de/de/fbz/gieskane/korpus/korpustexte
  - source urls are provided and can be used for automated alignment
- doesn't seem to be properly released yet
- ANNIS access https://annis.germanistik.uni-giessen.de/#_q=b3J0aHNhdHo&ql=aql&_c=R2llc0thTmVfdjAuMw&cl=5&cr=5&s=0&l=10
- strategies for retrieval
   - **FAILED** search for "orthsatz", then "export" and export via GridExporter (set preceding and following context to 0) results in file with sentence numbers, only
   - **FAILED** search for "tok", GridExporter, +-1 token, results in list of numbers (no annotations whatsoever)
   - **FAILED** search for "tok", CSVExporter, nur plain text export
   - search for `node & tok & #1 _i_ #2`, CSVExporter. we loose the function labels ... and this is a **huge** dump, from which most parts of the annotation can be recovered
