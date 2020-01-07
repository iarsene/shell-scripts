#!/bin/bash

fileToMerge=$1
nChunksToMerge=$2
inputDir=$3
runs=`cat $4`

for run in $runs; do
   echo "Merging run $run --------------------------------"
   chunks=`find $inputDir/$run/ -name $fileToMerge`
   currentChunk=1
   currentMergedChunk=1
   buffer=""
   for chunk in $chunks; do
      buffer=`printf "$buffer\n$chunk"`
      let "val=$currentChunk%$nChunksToMerge"
      if [ $val -eq 0 ]; then
         mkdir -p $inputDir/$run/chunk$currentMergedChunk
         hadd $inputDir/$run/chunk$currentMergedChunk/$fileToMerge $buffer
         buffer="" 
         let currentMergedChunk=currentMergedChunk+1
         echo "================================================================="
      fi   
      let currentChunk=currentChunk+1
   done
   if [ "$buffer" != "" ]; then
      mkdir -p $inputDir/$run/chunk$currentMergedChunk
      hadd $inputDir/$run/chunk$currentMergedChunk/$fileToMerge $buffer
   fi
done
