#!/bin/bash

#baseGridDir=/alice/data/2016/LHC16l
#baseGridDir=/alice/data/2015/LHC15o
#baseGridDir=/alice/sim/2016/LHC16j1
baseGridDir=/alice/data/2016/LHC16r
recoPass=pass1_CENT_wSDD
#trainType=DQ_pp_ESD
#trainType=DQ_PbPb
#trainType=DQ_PbPb_MC_ESD
trainType=DQ_pPb
isMC=no

legoTrainNumber=$1
outputDir=$2
runList=`cat $3`
isLEGOoutputMerged=$4

for run in $runList; do
   mkdir -p $outputDir/000$run
   #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   # Copying UNMERGED LEGO train output
   if [ "$isLEGOoutputMerged" = "unmerged" ]; then
      if [ "$isMC" = "yes" ]; then
        alien_ls $baseGridDir/$run/PWGDQ/$trainType/$legoTrainNumber | grep [0-9][0-9] > $outputDir/000$run/chunkList.txt
      fi
      if [ "$isMC" = "no" ]; then
         alien_ls $baseGridDir/000$run/$recoPass/PWGDQ/$trainType/$legoTrainNumber | grep [0-9][0-9] > $outputDir/000$run/chunkList.txt
      fi
      nchunks=`cat $outputDir/000$run/chunkList.txt | wc -l`
      echo "Copying $nchunks files for run $run from grid"
      chunkList=`cat $outputDir/000$run/chunkList.txt`
      for chunk in $chunkList; do
         echo "         Copying chunk $chunk out of $nchunks"
         mkdir -p $outputDir/000$run/$chunk
         if [ -s $outputDir/000$run/$chunk/dstTree.root ]
         then
            echo "    -->  Chunk exists already"
         else
            if [ "$isMC" = "yes" ]; then
               alien_cp alien://$baseGridDir/$run/PWGDQ/$trainType/$legoTrainNumber/$chunk/dstTree.root $outputDir/000$run/$chunk/
            fi
            if [ "$isMC" = "no" ]; then
               alien_cp alien://$baseGridDir/000$run/$recoPass/PWGDQ/$trainType/$legoTrainNumber/$chunk/dstTree.root $outputDir/000$run/$chunk/
            fi
         fi
      done
   fi
   
   #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   # Copying MERGED LEGO train output
   if [ "$isLEGOoutputMerged" = "merged" ]; then
      echo "Copying merged file for run $run from grid"
      mkdir -p $outputDir/000$run/chunk1
      
      if [ -s $outputDir/000$run/chunk1/dstTree.root ]
      then
         echo "    -->  File exists already"
      else
         if [ "$isMC" = "no" ]; then
            alien_cp alien://$baseGridDir/000$run/$recoPass/PWGDQ/$trainType/$legoTrainNumber/dstTree.root $outputDir/000$run/chunk1/
         fi
         if [ "$isMC" = "yes" ]; then
            alien_cp alien://$baseGridDir/$run/PWGDQ/$trainType/$legoTrainNumber/dstTree.root $outputDir/000$run/chunk1/
         fi
      fi
   fi
   
done
   