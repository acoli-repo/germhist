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

##########
# config #
##########

MYHOME=`dirname $0`
source $MYHOME/config

##############
# use config #
##############

if echo $* | egrep '^(.* )?\-[\-]?[h?]' >&/dev/null; then
  echo synopsis: $0 "[-h|-?] [-data=dataDir] [-out=outDir]" 1>&2
  echo '  -h, -?  print this dialog and exit' 1>&2
  echo '  dataDir directory to read Cora XML files from, defaults to '$dataDirAbs 1>&2
  echo '  outDir  directory to write CoNLL and TTL files to, defaults to '$outDirAbs 1>&2
  exit
fi

if echo $* | egrep '(.* )?\-data[^ ]*=' >&/dev/null ; then
  remDir=`echo $* | sed s/' '/'\n'/g | egrep -m 1 '^\-data.*=' | sed s/'.*='//`
  remDirAbs=$(realpath $remDir)
  remFiles=${remDir}/*
else
  remDir=$dataDirAbs
fi

if echo $* | egrep '^(.* )*\-out[^ ]*=' >&/dev/null; then
  outDir=`echo $* | sed s/' '/'\n'/g | egrep -m 1 '^\-out.*=' | sed s/'.*='//`
  outDirAbs=$(realpath $outDir)
fi

echo running $0 -data $remDirAbs -out $outDirAbs 1>&2

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
if [ ! -d $outDir/conll ]
  then mkdir $outDir/conll
fi;
if [ ! -d $outDir/log ]
  then mkdir $outDir/log
fi;

function cols {
  out="";
  b=$((${1}+1));
  for i in $(seq $b $2); do
    out="$out $i";
  done;
  echo $out;
}
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

for f in $remFiles ; do \
  bare=$(basename $f);
  ttlfile=${bare%.conll}.ttl;
  if [ -s $outDir/conll/$ttlfile.conll ]; then
    echo $f skipped", found " $outDir/conll/$ttlfile.conll 1>&2
  else
      echo -n $f '..' 1>&2
      (
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
        if $DEBUG; then
          $conll2rdfDir/run.sh CoNLLRDFFormatter -grammar;
        else
          $conll2rdfDir/run.sh CoNLLRDFFormatter | tee $outDir/ttlchunked/$ttlfile | \
          $shDir/ttl2conll.sh > $outDir/conll/$ttlfile.conll; fi;
        ) >& $outDir/log/$ttlfile.log &

        # after (up to) 10 min shut it down
        for iteration in {1..60}; do
            if [ ! -s $outDir/conll/$ttlfile.conll ]; then
              sleep 10s
            fi
        done

        if [ ! -s $outDir/conll/$ttlfile.conll ]; then
          kill -9 $!
        fi;

        if [ ! -s $outDir/conll/$ttlfile.conll ]; then
          echo failed', see '$outDir/log/$ttlfile.log 1>&2
          cat $outDir/log/$ttlfile.log | sed s/'^'/'^\t'/g 1>&2
          echo 1>&2
        else
          echo ok 1>&2
          rm $outDir/log/$ttlfile.log
        fi;
      fi;
done
