#!/bin/bash

baseGridDir=/alice/data/2015/LHC15o
#baseGridDir=/alice/sim/2018/LHC18a11_cent_woSDD/
#baseGridDir=/alice/data/2018/LHC18l
#recoPass=pass3_lowIR_pidfix
#recoPass=pass1_pidfix
recoPass=pass1
#trainType=DQ_pp_MC_ESD
#trainType=DQ_pp_ESD
trainType=PWGDQ/DQ_PbPb_ESD
#trainType=DQ_PbPb_MC_ESD
#trainType=DQ_pPb
#trainType=PWGPP/DPG_ESD
isMC=no
fileToCopy=dstTree.root
#fileToCopy=AnalysisResults.root

legoTrainNumber=$1
outputDir=$2
runList=`cat $3`
isLEGOoutputMerged=$4


for run in $runList; do
   mkdir -p $outputDir/$run
   #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   # Copying UNMERGED LEGO train output
   if [ "$isLEGOoutputMerged" = "unmerged" ]; then
   
   
      if [ "$isMC" = "yes" ]; then
        alien_ls $baseGridDir/${run:3}/$trainType/$legoTrainNumber | grep [0-9][0-9] > $outputDir/$run/chunkList.txt
      fi
      if [ "$isMC" = "no" ]; then
         alien_ls $baseGridDir/$run/$recoPass/$trainType/$legoTrainNumber | grep [0-9][0-9] > $outputDir/$run/chunkList.txt
      fi
      nchunks=`cat $outputDir/$run/chunkList.txt | wc -l`
      echo "Copying $nchunks files for run $run from grid"
      chunkList=`cat $outputDir/$run/chunkList.txt`
      for chunk in $chunkList; do
      
         while [ $(ps -ef | grep alien_cp | wc -l) -gt 20 ]; do
            sleep 10s;
         done
      
         sourceFile="alien://$baseGridDir/$run/$recoPass/$trainType/$legoTrainNumber/$chunk/$fileToCopy"
         destinationDir="$outputDir/$run/$chunk/"
      
         if [ "$isMC" = "yes" ]; then
            sourceFile="alien://$baseGridDir/${run:3}/$trainType/$legoTrainNumber/$chunk/$fileToCopy"
         fi
      
         echo "         Copying file $sourceFile to $destinationDir"
         
         mkdir -p $outputDir/$run/$chunk
         if [ -s $outputDir/$run/$chunk/$fileToCopy ]
         then
            echo "    -->  Chunk exists already"
         else
            alien_cp $sourceFile $destinationDir &
         fi
      done
   fi
   
   #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   # Copying MERGED LEGO train output
   if [ "$isLEGOoutputMerged" = "merged" ]; then
   
      while [ $(ps -ef | grep alien_cp | wc -l) -gt 20 ]; do
        sleep 10s;
      done
   
      echo "Copying merged file for run $run from grid"
      mkdir -p $outputDir/$run/chunk1
      
      if [ -s $outputDir/$run/chunk1/$fileToCopy ]
      then
         echo "    -->  File exists already"
      else
         if [ "$isMC" = "no" ]; then
            alien_cp alien://$baseGridDir/$run/$recoPass/$trainType/$legoTrainNumber/$fileToCopy $outputDir/$run/chunk1/ &
         fi
         if [ "$isMC" = "yes" ]; then
            alien_cp alien://$baseGridDir/${run:3}/$trainType/$legoTrainNumber/$fileToCopy $outputDir/$run/chunk1/ &
         fi
      fi
   fi
   
done
   
