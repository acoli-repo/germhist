#!/bin/bash
# read ReM CoNLL, transliterate using koebler and lexer, transform to RDF and apply chunking update scripts -> write to stdout

# the Middle High German chunker actually represents a deterministic parser, with application-specific requirements/simplifications, i.e., 
# - we rely on an existing markup of clause breaks
# - we rely on the ReM/HITS POS annotations (https://www.linguistics.rub.de/rem/documentation/pos.html)
# - relative clauses attach to the left
# - low attachment for relative clauses and PPs: these are irrelevant for studying NP word order and in this way, we can query for immediate adjacency
# - topological fields, where these cannot be reliably identified, a clause will be marked as a Frag
# 
# n/v/p chunking implemented in the spirit of a simple SHIFT-REDUCE parser (adjacent pairs only, connecting parse fragments, operate between clause boundaries only)
# - unattached words/parse fragments are connected by mi:next
# - mi:next is initialized from nif:nextWord, but then "moved up" when CHUNKS are introduced
# - attachment is represented by mi:CHUNK
# - if an element has a mi:CHUNK, its parent node takes over its mi:next, within a mi:CHUNK, there is no mi:next
# 
# SPARQL allows to extend beyond these data structures, occasionally, we look further in the context (insertMFChunks: LB/RB, beyond clause boundaries, actually) deeper into previously parsed structures (addCl) or we connect separated clause fragments (addMF)
# for clausal junction, transitions within the sentence are re-initialized (keep transitions across clause boundaries), and for attachment, we look deeply into parsed fragments
# 
# after chunking, the data is transformed to create a human-readable representation using the CoNLL dependency (!) visualization, i.e., pseudo nodes

# this pipeline is primarily intended for rule development
# suggested methodology:
# - add a critical example ("from the field") to samples.conll, mark its source
# - if an example from samples.conll is properly analyzed, comment it out
# - after rules had to be adjusted to accomodate a new example, uncomment all previous analyses from samples.conll and reanalyze their performance
# - if a parsing error cannot be fixed (e.g., because two deterministic rules would be in conflict), add 
# - production mode: copy this pipeline to rem_pipe.sh to run it on the full corpus or set DEBUG=false (below) for stream processing

# TODO
# - introduce data structures that can be navigated, following the POWLA vocabulary, with powla:next between siblings, powla:hasParent between child and parent
# - update test scripts
# - check if all resources exist before running pipeline

##########
# config #
##########

# meta parameter
DEBUG=false;			# set to false for production mode

dataDir=./res/data/
srcDir=./src/
outDir=./out
remFiles=${dataDir}remdata/*
conll2rdfDir=../conll-rdf.git/trunk
chunkingPipeline=./res/sparql/chunking/
dataDirAbs=$(realpath $dataDir)
chunkingPipelineAbs=$(realpath $chunkingPipeline)

set LANG=C.UTF-8;
if [ $OSTYPE = "cygwin" ]; then
  srcDir=$(cygpath -ma $srcDir);
  dataDirAbs=$(cygpath -ma $dataDirAbs);
  chunkingPipelineAbs=$(cygpath -ma $chunkingPipelineAbs);
fi;
(cd $srcDir && \
  javac -encoding "utf-8" org/acoli/conll/quantqual/Transliterator.java; 
  javac -encoding "utf-8" org/acoli/conll/quantqual/AniImp.java; 
)
if [ ! -d $outDir ]
  then mkdir $outDir
fi;
if $DEBUG; then
  remFiles=${dataDir}samples.conll;
  if [ ! -d $outDir/transliterated ]
    then mkdir $outDir/transliterated
  fi;
  if [ ! -d $outDir/animacyannotated ]
    then mkdir $outDir/animacyannotated
  fi;
  if [ ! -d $outDir/ttlbare ]
    then mkdir $outDir/ttlbare
  fi;
  if [ ! -d $outDir/ttlfin ]
    then mkdir $outDir/ttlfin
  fi;
fi;
if [ ! -d $outDir/ttlchunked ]
  then mkdir $outDir/ttlchunked
fi;
function cols {
  out="";
  b=$((${1}+1));
  for i in $(seq $b $2); do
    out="$out $i";
  done;
  echo $out;
} 

for f in $remFiles ; do \
  colCount=7;
  colCountAnnotated=${colCount};
  if [ -e $dataDirAbs/mhd-koebler.tsv ]; then
    ((colCountAnnotated++));
  fi;
  if [ -e $dataDirAbs/lexerlemmas_1_to_1.tsv ]; then
    ((colCountAnnotated++));
  fi;
  if [ -e $dataDirAbs/manual_translit.tsv ]; then
    ((colCountAnnotated++));
  fi;
  bare=$(basename $f);
  ttlfile=${bare%.conll}.ttl;
  tuttl=file:///${ttlfile}'/';
  tuttl=`echo $tuttl | sed s/'\/'/'\\\\\/'/g`;
  sed s/'^\(.*[^\S].*\)$'/'\1\t'$tuttl/g $f | \
  #
  ############################
  # hyperlemmata and animacy #
  ############################
  #
  if [ -e $dataDirAbs/mhd-koebler.tsv ]; then
    java -cp $srcDir org.acoli.conll.quantqual.Transliterator $dataDirAbs/mhd-koebler.tsv 1 2 4;
  else
    cat;
  fi | \
  if [ -e $dataDirAbs/lexerlemmas_1_to_1.tsv ]; then
    java -cp $srcDir org.acoli.conll.quantqual.Transliterator $dataDirAbs/lexerlemmas_1_to_1.tsv 2 5 4;
  else
    cat;
  fi | \
  if [ -e $dataDirAbs/manual_translit.tsv ]; then
    java -cp $srcDir org.acoli.conll.quantqual.Transliterator $dataDirAbs/manual_translit.tsv 1 2 4;
  else
    cat;
  fi | \
  if $DEBUG; then tee $outDir/transliterated/$bare; else cat; fi | \
  if [ -e $dataDirAbs/animacy-de.csv ]; then
    java -cp $srcDir org.acoli.conll.quantqual.AniImp $dataDirAbs/animacy-de.csv 4 $(cols $colCount $colCountAnnotated);
  else
    java -cp $srcDir org.acoli.conll.quantqual.AniImp $dataDirAbs/animacy-de_manual.csv 4 $(cols $colCount $colCountAnnotated);
  fi | \
  if $DEBUG; then tee $outDir/animacyannotated/$bare; else cat; fi | \
  #
  ######################################
  # aux: fix URIs to original file name#
  ######################################
  #
  $conll2rdfDir/run.sh CoNLLStreamExtractor http://ignore.me ID TID WORD LEMMA POS INFL SB BASE KOEBLERLEMMA LEXERLEMMA MANUALLEMMA ANIMACY | \
  $conll2rdfDir/run.sh CoNLLRDFFormatter | \
  perl -e '
	$secondLastLine="";
	$lastline="";
	while(<>) {
		if($_=~m/conll:BASE /) {
			if(! ($lastline=~m/conll:BASE/)) {
				if(! ($secondListLine=~m/conll:BASE/)) {
					my $base=$_;
					$base=~s/.*conll:BASE "([^"]*)".*/$1/gs;
					print "\@prefix : <".$base."> .\n";
				}
			}
		}
		$secondLastLine=~s/; conll:BASE "[^"]*"//g;
		print $secondLastLine;
		$secondLastLine=$lastline;
		$lastline=$_;
	};
	$secondLastLine=~s/; conll:BASE "[^"]*"//g;
	print $secondLastLine;
	$lastline=~s/; conll:BASE "[^"]*"//g;
	print $lastline;
	' | \
  grep -v 'http://ignore.me' | \
  if $DEBUG; then tee $outDir/ttlbare/$ttlfile; else cat; fi | \
  #
  ############
  # chunking #
  ############
  #
  # CC: modifications
  # - FIXED: {*} doesn't seem to work properly => replaced by {10} or higher
  # - FIXED: step1 didn't work with / URIs
  # - CHANGED: mi:next *within clauses*, no explicit clauses
  #            mi:next shall connect only adjacent parse fragments that are otherwise unattached (cf. SHIFT)
  #            mi:next updates are implemented in stepAUX; BUT for iterative operations, it must be included
  # - CHANGED: PXs attach to NXs only
  # - FIXED: removed verb from middle field / revised middle field detection
  #   alternatively: use "CORE": this term follows Role and Reference Grammar, see
  #     Van Valin Jr, R. D., & LaPolla, R. J. (1997). Syntax: Structure, meaning, and function. Cambridge University Press, p.500
  #     we must not claim a firm foundation in RRG, note that Diederich's analysis of German syntax is different, as the CORE there includes the VF, too
  # - ADDED: prefield, postfield, clausal junction
  # - CHANGED: during parsing, CHUNKs do not contain a conll:HEAD, added in chunk2word, only
  # - CHANGED: MFChunk => MF, NChunk => NX, PChunk => PX, VChunk => VX
  # - CHANGED: map data structures to (modified) POWLA (powla:next between *all* siblings, powla:hasParent for mi:CHUNK)
  # - TODO: update eval scripts to POWLA
  # - NOTE: after step 15, we reinitialize mi:next, but now we keep transitions across clause boundaries
  # - NOTE: regular shift-reduce parsing until 15, clausal attachment requires more heavy machinery (i.e., attach within established phrases)
  # - TODO: update chunk2word for POWLA data structures
  # - TODO: rename mi:next => conll:SHIFT and mi:CHUNK => conll:REDUCE
  # - TODO: coordination, improve fragment resolution, include more samples
  (
  $conll2rdfDir/run.sh CoNLLRDFUpdater -custom -updates 																		\
	  \
	  $chunkingPipelineAbs/step0_initializeNext.sparql 																			\
	  $chunkingPipelineAbs/step1_insertClauseBoundaries.sparql 																	\
      \
	  $chunkingPipelineAbs/step2_insertNChunkHeads.sparql	 				$chunkingPipelineAbs/stepAUX_repairNext.sparql{u}	\
      $chunkingPipelineAbs/step3_extendNChunksITERATE.sparql{u} 																\
	  $chunkingPipelineAbs/step3.a_attachGenitive.sparql 					$chunkingPipelineAbs/stepAUX_repairNext.sparql{u}	\
      $chunkingPipelineAbs/step3_extendNChunksITERATE.sparql{u} 																\
      $chunkingPipelineAbs/step4_extendNChunksToPPChunks.sparql 			$chunkingPipelineAbs/stepAUX_repairNext.sparql{u}	\
      $chunkingPipelineAbs/step5_insertVChunks.sparql	 					$chunkingPipelineAbs/stepAUX_repairNext.sparql{u}	\
      $chunkingPipelineAbs/step6_extendVChunksByParticles.sparql	 		$chunkingPipelineAbs/stepAUX_repairNext.sparql{u}	\
      $chunkingPipelineAbs/step7_extendVChunksByPronominalAdverbs.sparql{u} 													\
      $chunkingPipelineAbs/step8_mergeVChunkComplexes.sparql 				$chunkingPipelineAbs/stepAUX_repairNext.sparql{u}	\
      $chunkingPipelineAbs/step9_mergePPChunksToXChunks.sparql	 			$chunkingPipelineAbs/stepAUX_repairNext.sparql{u}	\
      $chunkingPipelineAbs/step10_joinVChunksOnKONITERATE.sparql{u} 															\
      \
	  $chunkingPipelineAbs/step11_addMFBrackets.sparql	 					$chunkingPipelineAbs/stepAUX_repairNext.sparql{u}	\
      $chunkingPipelineAbs/step12_addMF.sparql								$chunkingPipelineAbs/stepAUX_repairNext.sparql{u}	\
	  $chunkingPipelineAbs/step13_addPreF.sparql							$chunkingPipelineAbs/stepAUX_repairNext.sparql{u}	\
	  $chunkingPipelineAbs/step14_addPostF.sparql							$chunkingPipelineAbs/stepAUX_repairNext.sparql{u}	\
	  $chunkingPipelineAbs/step15_addClause.sparql							$chunkingPipelineAbs/stepAUX_repairNext.sparql{u}	\
	  \
	  $chunkingPipelineAbs/step0_initializeNext.sparql						$chunkingPipelineAbs/stepAUX_repairNext.sparql{u}	\
	  $chunkingPipelineAbs/step16_attachRelClauses.sparql					$chunkingPipelineAbs/stepAUX_repairNext.sparql{u}	\
	  $chunkingPipelineAbs/step17_attachNonClausalFragments.sparql{u} 															\
	  \
	  $chunkingPipelineAbs/step0_initializeNext.sparql						$chunkingPipelineAbs/stepAUX_repairNext.sparql{u}	\
	  $chunkingPipelineAbs/step18_addS.sparql 																					\
  ) | \
  #
  #####################################################
  # output (RDF formatted, POWLA RDF, human-readable) #
  #####################################################
  #
  # write formatted (original) CoNLL-RDF to stderr
  $conll2rdfDir/run.sh CoNLLRDFFormatter | \
  if $DEBUG; then tee $outDir/ttlfin/$ttlfile; else cat; fi | \
  # conversion to POWLA (interoperable data structures)
  $conll2rdfDir/run.sh CoNLLRDFUpdater -custom -updates \
    $chunkingPipelineAbs/chunk2powla.sparql 	| \
    #$chunkingPipelineAbs/powla2word.sparql 		| \#
  if $DEBUG; then $conll2rdfDir/run.sh CoNLLRDFFormatter -grammar; else $conll2rdfDir/run.sh CoNLLRDFFormatter > $outDir/ttlchunked/$ttlfile; fi;
done

