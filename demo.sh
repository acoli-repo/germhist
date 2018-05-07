#!/bin/bash
# read ReM CoNLL, transliterate using lexer, annotate animacy, transform to RDF and apply chunking update scripts -> write to stdout

#
######################
# config and compile #
######################
#
dataDir=./res/data/
srcDir=./src/
outDir=./res/data/demo
remFiles=${dataDir}/samples.conll
conll2rdfDir=./conll-rdf.git/trunk
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
#
#############################
# create output directories #
#############################
#
if [ ! -d $outDir ]
  then mkdir $outDir
fi;
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
if [ ! -d $outDir/ttlchunked ]
  then mkdir $outDir/ttlchunked
fi;

for f in $remFiles ; do \
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
  java -cp $srcDir org.acoli.conll.quantqual.Transliterator $dataDirAbs/lexerlemmas_1_to_1.tsv 2 5 4 | \
  java -cp $srcDir org.acoli.conll.quantqual.Transliterator $dataDirAbs/manual_translit.tsv 1 2 4 | \
  tee $outDir/transliterated/$bare | \
  java -cp $srcDir org.acoli.conll.quantqual.AniImp $dataDirAbs/animacy-de_manual.csv 4 8 9 | \
  tee $outDir/animacyannotated/$bare | \
  #
  ######################################
  # aux: fix URIs to original file name#
  ######################################
  #
  $conll2rdfDir/run.sh CoNLLStreamExtractor http://ignore.me ID TID WORD LEMMA POS INFL SB BASE LEXERLEMMA MANUALLEMMA ANIMACY | \
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
  tee $outDir/ttlbare/$ttlfile | \
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
  tee $outDir/ttlfin/$ttlfile | \
  # conversion to POWLA (interoperable data structures)
  $conll2rdfDir/run.sh CoNLLRDFUpdater -custom -updates \
    $chunkingPipelineAbs/chunk2powla.sparql 	\
    $chunkingPipelineAbs/powla2word.sparql 		| \
  tee >($conll2rdfDir/run.sh CoNLLRDFFormatter > $outDir/ttlchunked/$ttlfile) | $conll2rdfDir/run.sh CoNLLRDFFormatter -grammar;
done

