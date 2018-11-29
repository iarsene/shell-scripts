#!/bin/bash

alienHomeDir=/alice/data/2018/LHC18a/
inputDir=$1
outDir=$2
runList=`cat $3`

for run in $runList; do
   mkdir -p $outDir/$run
   alien_ls $alienHomeDir/$run/$inputDir | grep 18000 > $outDir/$run/chunkList.txt
   nchunks=`cat $outDir/$run/chunkList.txt | wc -l`
   echo "Copying $nchunks files for run $run from grid"
   chunkList=`cat $outDir/$run/chunkList.txt`
   for chunk in $chunkList; do
      mkdir -p $outDir/$run/$inputDir/$chunk
      echo "Copy chunk $chunk"
      if [ -s $outDir/$run/$inputDir/$chunk/root_archive.zip ]
      then
         echo "    -->  Chunk exists already"
      else
         alien_cp alien://$alienHomeDir/$run/$inputDir/$chunk/root_archive.zip $outDir/$run/$inputDir/$chunk/
      fi
   done
done
   