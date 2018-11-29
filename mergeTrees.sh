#!/bin/bash

fileToMerge=dstTree.root

runs=`cat $1`
inputDir=$2
deletePartialOutputs=$3

for run in $runs; do
   echo "Merging run $run --------------------------------"
   chunks=`find $inputDir/$run/ -name $fileToMerge`
   echo "Chunks: $chunks"
   if [ -s $inputDir/$run/$fileToMerge ]
      then
         echo "    --> Already merged"
      else
         hadd $inputDir/$run/$fileToMerge $chunks
   fi
   
   mkdir -p $inputDir/$run/chunk1
   mv $inputDir/$run/$fileToMerge $inputDir/$run/chunk1/
   
   if [ "$deletePartialOutputs" = "yes"  ]; then
      rm -r $inputDir/$run/[0-9][0-9][0-9]/
   fi
done
