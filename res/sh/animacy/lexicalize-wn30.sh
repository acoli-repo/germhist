#!/bin/bash
# echo synopsis: $0 "[GermaNet.DIR]" 1>&2
# echo '  GermaNet.DIR directory of GermaNet installation, by default .' 1>&2
# echo 'create a TTL file that assigns GermaNet lexemes and their Wiktionary paraphrases to WordNet 3.1 URIs' 1>&2
# # for assigning German labels to WordNet 3.1 glosses, using the ILI
# # (1) qualified TSV file: lexUnit/@id<TAB>orthForm/text() (from adj.*.xml nomen.*.xml verb.*.xml), sort for lexUnit/@id
# # (2) qualified TSV file: iliRecord/@lexUnitId<TAB>iliRecord/@pwn30Id (from interLingualIndex_DE-EN.xml), sort for @lexUnitId
# # (3) qualified TSV file: wiktionaryParaphrase/@lexUnitId<TAB>wiktionaryParaphrase@wiktionarySense (from wiktionaryParaphrases-*.xml
# # (4) sort and merge files
# # (5) write TTL for integration with WordNet 3.1 (http://wordnet-rdf.princeton.edu)
# # output to stdout

echo "@prefix owl: <http://www.w3.org/2002/07/owl#> .";
echo "@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .";
echo "@prefix wno: <http://wordnet-rdf.princeton.edu/ontology#> .";
echo "@prefix : <http://wordnet-rdf.princeton.edu/wn30/> .";			# these are mapped to wn31 ids, but not in the offline data

GERMANET_DIR=$*;
if echo $GERMANET_DIR | egrep '^$' >/dev/null; then GERMANET_DIR=.; fi;

(
	# (1) qualified TSV file: lexUnit/@id<TAB>orthForm/text() (from *.xml), sort for lexUnit/@id
	#     assume that orthForms are unique (as in GermaNet v.11) 
	for file in $GERMANET_DIR/nomen.*.xml $GERMANET_DIR/adj.*.xml $GERMANET_DIR/verb*.xml ; do
		sed -e s/'<'/'\n<'/g $file | \
		egrep '<lexUnit|<orthForm' | \
		perl -pe 's/\n//gs; s/(<lexUnit)/\n$1/g;' |\
		sed -e s/'<lexUnit.*id="\([^"]*\)".*<orthForm>'/'\1\torthForm='/g;
	done;

	# (2) qualified TSV file: iliRecord/@lexUnitId<TAB>iliRecord/@pwn30Id (from interLingualIndex_DE-EN.xml), sort for @lexUnitId
	sed s/'<'/'\n<'/g $GERMANET_DIR/interLingualIndex_DE-EN.xml | \
	grep '<iliRecord' | \
	sed -e s/'.*lexUnitId="\([^"]*\)".*pwn30Id="\(ENG30-[^"]*\)".*'/'\1\tpwn30Id=\2'/g;

	# (3) qualified TSV file: wiktionaryParaphrase/@lexUnitId<TAB>wiktionaryParaphrase@wiktionarySense (from wiktionaryParaphrases-*.xml
	for file in $GERMANET_DIR/wiktionaryParaphrases*.xml; do
		sed s/'<'/'\n<'/g $file | \
		grep '<wiktionaryParaphrase ' | \
		sed -e s/'.*lexUnitId="\([^"]*\)".*wiktionarySense="\([^"]*\)".*'/'\1\twiktionarySense=\2'/g;
	done;
) | \
# 
# (4) sort and merge files
sort -u | \
perl -e '				# line *after* a new lexUnitId occurs, i.e., last entry has a different lexUnitId
	my $lexUnitId="";
	while(<>) {
		if(m/^$lexUnitId\t.*/) {
			s/\n/<BR>/gs;
			print;
		}
		$lexUnitId=$_;
		$lexUnitId=~s/\t.*//gs;
		print;
	};' | \
perl -pe '				# move last lexUnitId and its annotation into next line
	s/(<BR>)?([^<\n]*)\n/\n$2<BR>/g;
' | \
grep pwn30Id | 			# reduce search space to relevant lexemes, only
grep orthForm | \
perl -pe '				# split lines such that one entry per pwn30Id and wiktionarySense
	s/<BR>[^\t\n]*/<BR>/g;
	s/<BR>//g;
	while(m/wiktionarySense=[^\n]*wiktionarySense=/) {
		s/([^\n]*)(wiktionarySense=[^\t\n]*)\t(wiktionarySense=)/$1$2\n$1$3/g;
	}
	while(m/pwn30Id=[^\n]*pwn30Id=/) {
		s/([^\n]*)(pwn30Id=[^\t\n]*)\t(pwn30Id=[^\t\n]*)(\t[^\n]*)?/$1$2$4\n$1$3$4/g;
	}
' |\
uniq | 					# removes many duplicates, but not all
# 
#######################
# intermediate result #
#######################
# TSV file with GermaNet lexids, GermaNet lexemes, their Wiktionary paraphrase (optional), and WordNet 3.0 links
# 
# (5) conversion to TTL, following the Wordnet 3.1 schema
perl -e '
	while(<>) {
		if(m/orthForm=/) {
			if(m/pwn30Id=/) {
				$pwn30=$_; $pwn30=~s/.*pwn30Id=ENG30-([^\t\n]+).*\n/$1/gs;				

				$form=$_; 
				$form=~s/.*orthForm=([^\t\n]+).*\n/$1/gs;

				print ":" . $pwn30;												# we (can) assume that PWN 3.0 remain valid in PWN 3.1
				print " wno:translation \"" . $form . "\"\@de ";	# as in WN3.1 for other languages
				
				$lu=$_; 	
				$lu =~ s/\t.*\n$//gs;				# GN lexUnitId
				print "; owl:versionInfo \"GermaNet lexUnitId=" . $lu . "\" ";	# approximative modelling for lexicalUnits

				if(m/wiktionarySense=/) {
					$sense=$_; $sense=~s/.*wiktionarySense=([^\t\n]+).*/$1/gs;
					print "; wno:gloss \"" . $sense . "\"\@de ";		# this modelling is approximative, but 
					# follows the existing WN3.1 data model.
					# In PWN 3.1, translations are datatype properties, so this needs to modify the PWN URI
					# Note that we use @de as language identifier, but PWN 3.1 would have used @deu. According to BCP-47, the PWN practice is incorrect.
				}
				
				print ".\n";
			}
		}
	}' | \
sort -u; 			# removes all duplicates, takes time