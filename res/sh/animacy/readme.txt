retrieve animacy from WordNet 3.1 and GermaNet 11.0 linking
- this covers only the portion linked with Princeton wordnet
- animacy deduced from PWN alone
- categories: human (incl. organizations), animate (incl. plants), inanimate (incl. abstract concepts, animal/plant products)
- annotation: annotate animacy as deduced from all synsets per form, no morphological disambiguation (e.g., between Single m.sg. "single man", but Single f.sg. "record; single woman")
- coverage: 10022 nouns (3485 h, 1415 a, 4953 i; 18 h/a, 64 a/i, 84 h/i, 1 all), 16 adjectives (mostly incorrect)

approach (get-german-animacy.sh):
1. WordNet 3.1 (PWN 3.1, RDF)
2. SPARQL-based animacy inference: default inanimate, seed of animate, human and inanimate concepts, down-propagation to hyponyms and adjectives
3. generate German PWN 3.0 lexicalization from GermaNet (see lexicalize-wn30.sh)
4. use the interlingual index of the Global WordNet Association to map PWN 3.0 URIs to PWN 3.1 URIs
5. run animacy extraction and retrieve German "translations"

except for (3), which involves legacy XML, all of this is SPARQL-based