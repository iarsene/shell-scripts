#!/bin/bash

fileToMerge=dstAnalysisHistograms.root

runs=`cat $1`
inputDir=$2
deletePartialOutputs=$3

runMergedFiles=""
for run in $runs; do
   echo "Merging run $run --------------------------------"
   chunks=`find $inputDir/$run/ -name $fileToMerge`
   hadd $inputDir/$run/$fileToMerge $chunks
   if [ "$deletePartialOutputs" = "yes"  ]; then
      rm -r $inputDir/$run/job*
   fi
   runMergedFiles=`printf "$runMergedFiles $inputDir/$run/$fileToMerge"`
done

echo "Perform full period merging ----------------------------"
hadd $inputDir/$fileToMerge $runMergedFiles
