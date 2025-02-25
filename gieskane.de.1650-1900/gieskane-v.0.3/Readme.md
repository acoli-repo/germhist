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
   - **PARTIAL** (TOK only) search for `node & tok & #1 _i_ #2`, CSVExporter. we loose the function labels ... and this is a **huge** dump (650MB), from which word-level annotation can be recovered
      - note that this export is limited to token-level annotations, so we loose all span annotations
      - to be stored as `annis-export.csv.gz`
   - **PARTIAL** (TREE only, no grammatical roles), retrieved by the query `node > node`, CSVExporter and stored as `annis-export.tree.csv.gz`
   - **SIMPLIFIED** export of grammatical relations
      - pred.csv.gz: `node >[tree=/(frprä|prädi).*/] node` => frprä, prädi_vk, prädi_pdg, prädi_idi, prädi_fvg
      - sbj.csv.gz: `node >[tree=/sub.*/] node` => sub
      - oacc.csv.gz: `node >[tree=/ob_akk.*/] node`  => ob_akk
      - odat.csv.gz: `node >[tree=/ob_dat.*/] node`  => ob_dat
      - obj.csv.gz: `node >[tree=/ob.*/] node`  => ob_gen, ob_p, ob_unsp; ALSO: ob_akk, ob_dat
        - TIMEOUT: ooth.csv: `node >[tree=/ob([^_]|_[^ad]).*/] node`  => ob_gen, ob_p, ob_unsp
      - advmod.csv.gz: `node >[tree=/(adv|kom|dirum|kor).*/] node`  => dirum, kom_ber, kom_wert, kom_gelt, kom_neg, adv_add, adv_ads, adv_begl, adv_bene, adv_dila, adv_fin, adv_freq, adv_inst, adv_irr, adv_kaus, adv_komi, adv_kond, adv_kons, adv_konz, adv_lok, adv_mod, adv_rest, adv_sbst, adv_temp, adv_verm, kor
      - expl.csv.gz: `node >[tree=/ph.*/] node` => ph
      - acl.csv.gz: `node >[tree=/wf.*/] node` => wf
      > Note that we provide these exports for convenience, but they are not sufficient to restore the full corpus, which may be reconstructed (in simplified form) from it. For a local build, you need to acquire `annis-export.tree.csv.gz` and `annis-export.csv.gz` yourself. Without them, it is not possible to reconstruct text or annotation. Note that GiesKaNe may get out of sync with the exports provided for grammatical relations without any notion. Then, you need to re-build these from scratch. 

- NB: with ANNIS-QL, we cannot go as deeply into different temporal layers, but we can query directly:

    node @* zeit="19" &
    #1 >[tree=/ob_akk.*/] node &
    #1 >[tree=/ob_dat.*/] node &
    #3 .* #2 &
    #2 _i_ DTA_stts=/N.*/ &
    #3 _i_ DTA_stts=/N.*/