#!/bin/bash

inputType=ReducedEvent
eventType=AliAnalysisTaskReducedTreeMaker::kFullEventsWithFullTracks
runs=`cat $1`
inputDir=$2
outputDir=$3
nworkers=$4
nChunksPerJob=$5
hasMC=$6
period=$7
tasks=$8

# create the output directory and copy the input run list there
mkdir -p $outputDir
cp $1 $outputDir

# copy the macros used to configure the analysis in the output directory
# these will be used by the steering scripts and macros and kept for future reference 
mkdir -p $outputDir/macros
cp $PWD/AddTask_iarsene* $outputDir/macros

# loop over all runs and create the input lists for individual jobs (relative paths only)
# and count the number of jobs
mkdir -p $outputDir/jobInputs
jobCounter=0
for run in $runs; do
   chunks=`find $inputDir/$run -name dstTree.root | grep chunk`
   #chunks=`find $inputDir/$run -name dstTree.root`
   currentNfiles=0
   chunksForJob=''
   for chunk in $chunks; do
      tempChunk=${chunk#$inputDir/}
      tempChunk=${tempChunk%/dstTree.root}
      let currentNfiles=currentNfiles+1
      if [ $currentNfiles -lt $nChunksPerJob ]; then
         chunksForJob=`printf "$chunksForJob\n$tempChunk"`
      fi
      if [ $currentNfiles -eq $nChunksPerJob ]; then
         chunksForJob=`printf "$chunksForJob\n$tempChunk"`
         let jobCounter=jobCounter+1
         printf "$chunksForJob\n" > $outputDir/jobInputs/jobInput.$jobCounter.txt
         chunksForJob=''
         currentNfiles=0
      fi
   done
   if [ $currentNfiles -gt 0 ]; then
      let jobCounter=jobCounter+1
      printf "$chunksForJob\n" > $outputDir/jobInputs/jobInput.$jobCounter.txt
      chunksForJob=''
      currentNfiles=0
   fi
done

# create the lists of files to be assigned to each worker node
for i in `seq 1 $nworkers`; do
   > $outputDir/jobInputs/jobList.wn$i.txt
done

# divide the jobs equally to all worker nodes
currentNode=1
for i in `seq 1 $jobCounter`; do
   content=`cat $outputDir/jobInputs/jobList.wn$currentNode.txt`
   printf "$content\n jobInput.$i.txt" > $outputDir/jobInputs/jobList.wn$currentNode.txt
   let currentNode=currentNode+1
   if [ $currentNode -gt $nworkers ]; then
      currentNode=1
   fi
done

# submit processes using nohup to all the desired worker nodes
workDir=$PWD
mkdir -p $outputDir/nohupOutput
for i in `seq 1 $nworkers`; do
#   nohup $workDir/runAnalysis.sh $outputDir/jobInputs/jobList.wn$i.txt $inputDir $outputDir $nChunksPerJob $hasMC > $outputDir/nohupOutput/worker$i.out &
   nohup runAnalysis.sh $outputDir/jobInputs/jobList.wn$i.txt $inputDir $outputDir $nChunksPerJob $hasMC $inputType $eventType $period $tasks > $outputDir/nohupOutput/worker$i.out $nworkers &
done
