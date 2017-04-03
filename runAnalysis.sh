#!/bin/bash

# This bash script runs the runAnalysisTrain.C macro
# Here set the parameters for the macro
inputType=ReducedEvent
eventType=AliAnalysisTaskReducedTreeMaker::kFullEventsWithFullTracks
tasks=iarsene_jpsi2ee
#period=LHC15o_lowIR
#period=LHC15o_highIR
#period=LHC15o_pidfix
#period=mcPbPb
period=LHC16r

jobs=`cat $1`
inputDir=$2
outputDir=$3
nchunksPerJob=$4
hasMC=$5

workingDir=$PWD
mkdir -p $outputDir

for job in $jobs; do
   jobId=${job#jobInput.}
   jobId=${jobId%.txt}
   chunks=`cat $outputDir/jobInputs/$job`
   run=0
   inputFileList=''
   for chunk in $chunks; do
      idx=`expr index "chunk" /chunk`
      let idx=idx-1
      run=${chunk:$idx:9}
      inputFileList=`printf "$inputFileList\n$inputDir/$chunk/dstTree.root"`
   done
   mkdir -p $outputDir/$run/job$jobId
   printf "$inputFileList\n" > $outputDir/$run/job$jobId/inputFileList.txt
   cd $outputDir/$run/job$jobId
   aliroot -b -q $ALICE_PHYSICS/PWGDQ/reducedTree/macros/runAnalysisTrain.C\(\"inputFileList.txt\",\"local\",\"$inputType\",$hasMC,$eventType,kFALSE,\"$tasks\",\"$period\",1234567890,0,\"$outputDir/macros\"\)
   cd $workingDir
done