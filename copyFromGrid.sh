#!/bin/bash

runList=`cat $3`

for run in $runList; do
   mkdir -p $2/000$run
   alien_ls /alice/cern.ch/user/i/iarsene/$1/000$run/ > $2/000$run/chunkList.txt
   nchunks=`cat $2/000$run/chunkList.txt | wc -l`
   echo "Copying $nchunks files for run $run from grid"
   chunkList=`cat $2/000$run/chunkList.txt`
   for chunk in $chunkList; do
      mkdir -p $2/000$run/$chunk
      alien_cp alien:///alice/cern.ch/user/i/iarsene/$1/000$run/$chunk/dstTree.root $2/000$run/$chunk/
   done
done
   