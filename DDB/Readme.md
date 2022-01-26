# Deutsche Diachrone Baumbank 1.0

See `Makefile` for source URL and there for provenance.

    - Old High German (9th c.), Middle High German (13th c.), Early Modern High German (16th c.)
    - 8500 tokens *in total*
    - annotation layers:
      - POS, PARSE, MORPH: manually
      - LEMMA: manually (OHG only)

Note that this corpus is less a stand-alone resource than an experiment in applying the TIGER annotation scheme to historical German.
In this regard, it is a success and has influenced the subsequent Mercurius and ReF annotations, however, as a corpus resource, the data is marginal in size and the released data is poor in technical quality:

- TIGER export for MHG and ENHG is broken -- instead, this is Exmaralda, but without syntax annotation
- PAULA export is ok for original TIGER data [all languages], but merging failed [original Exmaralda files point to inexistent token file, however, these contain lemmatization only]

The TIGER data can be processed using the ReF/Mercurius workflow, but this is applicable to OHG only. For the PAULA data, we use the (experimental) PAULA2CoNLL converter from the [POWLA repository](https://github.com/acoli-repo/powla), with conversion and extraction included in [the scrambling analysis](../../analysis/scrambling).

Overall, the data contains only two clauses with post-verbal nominal accusative and dative arguments (13th c.: *zarten* with ACC>DAT, 16th c.: *geben* with DAT>ACC). As it makes no substantial contribution, it has been excluded from further analysis.
