#!/bin/bash

# This bash script runs the runAnalysisTrain.C macro
# Here set the parameters for the macro
#inputType=ReducedEvent
#eventType=AliAnalysisTaskReducedTreeMaker::kFullEventsWithFullTracks
#tasks=iarsene_testTask
#tasks=iarsene_jpsi2ee
#period=LHC15o_lowIR
#period=LHC15o_highIR
#period=LHC15o_pidfix
#period=LHC17p
#period=LHC15n
#period=mcPbPb
#period=LHC16r
#period=LHC10b
#period=LHC16r

jobs=`cat $1`
inputDir=$2
outputDir=$3
nchunksPerJob=$4
hasMC=$5
inputType=$6
eventType=$7
period=$8
tasks=$9
nworkers=$10

workingDir=$PWD
mkdir -p $outputDir

for job in $jobs; do

   while [ $(ps -ef | grep aliroot | grep runAnalysisTrain.C | wc -l) -gt $nworkers ]; do
      sleep 10s;
   done

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
   mkdir -p $outputDir/runOutput/$run/job$jobId
   printf "$inputFileList\n" > $outputDir/runOutput/$run/job$jobId/inputFileList.txt
   cd $outputDir/runOutput/$run/job$jobId
   if [ "$hasMC" = "kFALSE"  ]; then
      aliroot -b -q $workingDir/runAnalysisTrain.C\(\"inputFileList.txt\",\"local\",\"$inputType\",$hasMC,$eventType,kFALSE,\"$tasks\",\"$period\",-1,0,\"$outputDir/macros\"\)
   fi
   if [ "$hasMC" = "kTRUE"  ]; then
      aliroot -b -q $workingDir/runAnalysisTrain.C\(\"inputFileList.txt\",\"local\",\"$inputType\",$hasMC,$eventType,kFALSE,\"$tasks\",\"$period\",100000,0,\"$outputDir/macros\"\)
   fi
   cd $workingDir
   
   sleep 0.5
done
