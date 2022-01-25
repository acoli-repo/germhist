# Scrambling in historical German

We extracted post-verbal (or, if defined, middle field) accusative (direct object) and dative (indirect object) arguments.
The goal is to evaluate Augustin Speyer's (2011) claim that scrambling is a modern phenomenon.
He found that for nominal dative and accusative arguments in the middle-field, DAT>ACC was the predominant word order in the 14th, and subsequently, ACC>DAT became more acceptable.

To verify this claim, we extract all cases of postverbal/middle field ACC and DAT arguments (nominal and pronominal) from syntactically annotated historical German (and related language varieties),
as well as various factors (genre, period, determiner, part of speech, clause type, verbal predicate) and a backlink into the corpus (sentence URI and context [clause/middle-field/verb] URI).

To reproduce table generation, run

  $> make

The resulting TSV tables can be statistically evaluated processed with external tools, e.g., statistics software or R.
(You might want to filter out comments that we kept to preserve document metadata)

As an example, counting and filtering can be done with common command line tools:

  $> cat ycoe.tsv |   # for some Old English data \
     egrep -v '\tP' | # no pronouns \
     cut -f 4,11 |    # get columns with order and century  \
     sort | uniq -c   # count all combinations of orders and centuries

Column structure of TSV files:

1. sentence URI
2. verb (form or lemma)
3. context (the phrase that contains the arguments)
4. order
5. accusative determiner (POS; for articles also form or lemma)
6. accusative POS (of head word)
7. dative determiner
8. dative POS
9. clause linking/embedding (main, dep, mainOrDep, ?)
10. empty
11. century
12. first or second half of century
