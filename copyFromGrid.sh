#!/bin/bash

alienHomeDir=/alice/cern.ch/user/i/iarsene/
inputDir=$1
outDir=$2
runList=`cat $3`

for run in $runList; do
   mkdir -p $outDir/$run
   alien_ls $alienHomeDir/$inputDir/$run/ > $outDir/$run/chunkList.txt
   nchunks=`cat $outDir/$run/chunkList.txt | wc -l`
   echo "Copying $nchunks files for run $run from grid"
   chunkList=`cat $outDir/$run/chunkList.txt`
   for chunk in $chunkList; do
   
      while [ $(ps -ef | grep alien_cp | wc -l) -gt 30 ]; do
        sleep 5s;
      done
    
      mkdir -p $outDir/$run/$chunk
      echo "Copy chunk $chunk"
      if [ -s $outDir/$run/$chunk/dstTree.root ]
      then
         echo "    -->  Chunk exists already"
      else
         alien_cp alien://$alienHomeDir/$inputDir/$run/$chunk/dstTree.root $outDir/$run/$chunk/  &
      fi
   done
done
   
