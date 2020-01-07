#!/bin/bash

#test commit

#fileToMerge=dstAnalysisHistograms.root
#fileToMerge=AnalysisHistograms_jpsi2ee_XeXe_MC.root
#fileToMerge=AnalysisHistograms_jpsi2ee_XeXe.root
#fileToMerge=AnalysisHistograms_testTask.root
#fileToMerge=AnalysisHistograms_jpsi2ee_MC.root
#fileToMerge=AnalysisHistograms_jpsi2ee_pp2017_MC.root
#fileToMerge=AnalysisHistograms_jpsi2ee_pp2017.root

runs=`cat $1`
inputDir=$2
deletePartialOutputs=$3
fileToMerge=$4

runMergedFiles=""
for run in $runs; do
   echo "Merging run $run --------------------------------"
   chunks=`find $inputDir/runOutput/$run/ -name $fileToMerge`
   hadd $inputDir/runOutput/$run/$fileToMerge $chunks
   if [ "$deletePartialOutputs" = "yes"  ]; then
      rm -r $inputDir/runOutput/$run/job*/$fileToMerge
   fi
   runMergedFiles=`printf "$runMergedFiles $inputDir/runOutput/$run/$fileToMerge"`
done

echo "Perform full period merging ----------------------------"
hadd $inputDir/$fileToMerge $runMergedFiles
