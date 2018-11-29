temp=$(tty)
currentTTY=${temp:5}

workDir=/home/iarsene/work/ALICE/pp2017Analysis/

runList_LHC15n=$workDir/RunLists/RunList_LHC15n_pass3_CentralBarrelTracking_20161212_v0.txt
runList_LHC17p=$workDir/RunLists/RunList_LHC17p_pass1_CentralBarrelTracking_20180110_v0.txt
runList_LHC17p_fast=$workDir/RunLists/RunList_LHC17p_FAST_CentralBarrelTracking_20180110_v0.txt
runList_LHC17q=$workDir/RunLists/RunList_LHC17q_pass1_CentralBarrelTracking_20180110_v0.txt
runList_LHC17pq=$workDir/RunLists/RunList_LHC17pq_pass1_CentralBarrelTracking_20180110_v0.txt
runList_LHC17pq_fast=$workDir/RunLists/RunList_LHC17pq_FAST_CentralBarrelTracking_20180110_v0.txt

inputDir_LHC15n_data=/home/iarsene/data/2015/LHC15n/dstTrees_1192_20180627/
inputDir_LHC15n_MC=/home/iarsene/data/2017/LHC17c2/dstTrees_818_20180627/
inputDir_LHC17pq_data=/home/iarsene/data/2017/LHC17pq/dstTrees_20180608_LEGO1162_1163_1164_1165/
inputDir_LHC17pq_data_fast=/home/iarsene/data/2017/LHC17pq/dstTrees_20180608_LEGO1162_1164_FAST/
inputDir_LHC17pq_data_woSDD=/home/iarsene/data/2017/LHC17pq/dstTrees_20180608_LEGO1163_1165_CENT_woSDD/
inputDir_LHC17pq_MC_woSDD=/home/iarsene/data/2018/LHC18a11_woSDD/dstTrees20180609_LEGO817/
inputDir_LHC17pq_MC_fast=/home/iarsene/data/2018/LHC18a11_fast/dstTrees20180609_LEGO816/

fileToMerge_data=AnalysisHistograms_jpsi2ee_pp2017.root
fileToMerge_mc=AnalysisHistograms_jpsi2ee_pp2017_MC.root
deletePartialOutputs=yes

outputDir=$workDir/analysisOutputs/$1
type=$2
tasks=$3
runSeparate=$4

waitTilReady () {
   sleep 1
   nMasterJobs="8"
   nSubJobs="8"
   while [ $nMasterJobs -gt $1 ] || [ $nSubJobs -gt $1 ]
   do
      nMasterJobs=`ps -u iarsene | grep runAnalysis.sh | grep $currentTTY | wc -l`
      nSubJobs=`ps -u iarsene | grep aliroot | grep $currentTTY | wc -l`
      echo `date` >> $outputDir/status.log
      echo $nMasterJobs master jobs and $nSubJobs sub-jobs still running for $2 ...  >> $outputDir/status.log
      sleep $3
   done
}

bell() {
  ( \speaker-test --frequency $1 --test sine )&
  pid=$!
  sleep 0.$2s
  kill -9 $pid
}


mkdir -p $outputDir
startingTime=`date`

if [ "$type" = "data" ] || [ "$type" = "all" ] ; then
   steerAnalysis.sh $runList_LHC15n $inputDir_LHC15n_data $outputDir/LHC15n/ 8 1 kFALSE LHC15n $tasks
   waitTilReady 6 LHC15n_data 30
   bell 1500 2
   bell 3500 1
   bell 1500 2
   if [ "$runSeparate" = "yes" ] ; then
      steerAnalysis.sh $runList_LHC17p_fast $inputDir_LHC17pq_data_fast $outputDir/LHC17p_fast 8 1 kFALSE LHC17p $tasks
      waitTilReady 6 LHC17p_data_fast 10
      bell 1500 2
      bell 3500 1
      bell 1500 2
      
      steerAnalysis.sh $runList_LHC17p $inputDir_LHC17pq_data_woSDD $outputDir/LHC17p_woSDD 8 1 kFALSE LHC17p $tasks
      waitTilReady 6 LHC17p_data_woSDD 10
      bell 1500 2
      bell 3500 1
      bell 1500 2
      
      steerAnalysis.sh $runList_LHC17q $inputDir_LHC17pq_data_fast $outputDir/LHC17q_fast 3 1 kFALSE LHC17q $tasks
      steerAnalysis.sh $runList_LHC17q $inputDir_LHC17pq_data_woSDD $outputDir/LHC17q_woSDD 3 1 kFALSE LHC17q $tasks
      waitTilReady 0 LHC17q_data 10
      bell 1500 2
      bell 3500 1
      bell 1500 2
      
      mergeResults.sh $runList_LHC15n $outputDir/LHC15n/ $deletePartialOutputs $fileToMerge_data
      mergeResults.sh $runList_LHC17p_fast $outputDir/LHC17p_fast/ $deletePartialOutputs $fileToMerge_data
      mergeResults.sh $runList_LHC17p $outputDir/LHC17p_woSDD/ $deletePartialOutputs $fileToMerge_data
      mergeResults.sh $runList_LHC17q $outputDir/LHC17q_fast/ $deletePartialOutputs $fileToMerge_data
      mergeResults.sh $runList_LHC17q $outputDir/LHC17q_woSDD/ $deletePartialOutputs $fileToMerge_data
      mkdir -p $outputDir/LHC17pq_woSDD/
      hadd $outputDir/LHC17pq_woSDD/$fileToMerge_data $outputDir/LHC17p_woSDD/$fileToMerge_data $outputDir/LHC17q_woSDD/$fileToMerge_data
      mkdir -p $outputDir/LHC17pq_fast/
      hadd $outputDir/LHC17pq_fast/$fileToMerge_data $outputDir/LHC17p_fast/$fileToMerge_data $outputDir/LHC17q_fast/$fileToMerge_data
      mkdir -p $outputDir/LHC17p/
      hadd $outputDir/LHC17p/$fileToMerge_data $outputDir/LHC17p_fast/$fileToMerge_data $outputDir/LHC17p_woSDD/$fileToMerge_data
      mkdir -p $outputDir/LHC17q/
      hadd $outputDir/LHC17q/$fileToMerge_data $outputDir/LHC17q_fast/$fileToMerge_data $outputDir/LHC17q_woSDD/$fileToMerge_data
      mkdir -p $outputDir/LHC17pq/
      hadd $outputDir/LHC17pq/$fileToMerge_data $outputDir/LHC17p/$fileToMerge_data $outputDir/LHC17q/$fileToMerge_data
      hadd $outputDir/$fileToMerge_data $outputDir/LHC15n/$fileToMerge_data $outputDir/LHC17pq_fast/$fileToMerge_data $outputDir/LHC17pq_woSDD/$fileToMerge_data
   fi
   
   if [ "$runSeparate" = "no" ] ; then
      steerAnalysis.sh $runList_LHC17p $inputDir_LHC17pq_data $outputDir/LHC17p 8 1 kFALSE LHC17p $tasks
      waitTilReady 6 LHC17p_data 10
      bell 1500 2
      bell 3500 1
      bell 1500 2
      steerAnalysis.sh $runList_LHC17q $inputDir_LHC17pq_data $outputDir/LHC17q 3 1 kFALSE LHC17q $tasks
      waitTilReady 0 LHC17q_data 10
      bell 1500 2
      bell 3500 1
      bell 1500 2
      
      mergeResults.sh $runList_LHC15n $outputDir/LHC15n/ $deletePartialOutputs $fileToMerge_data
      mergeResults.sh $runList_LHC17p $outputDir/LHC17p $deletePartialOutputs $fileToMerge_data
      mergeResults.sh $runList_LHC17q $outputDir/LHC17q $deletePartialOutputs $fileToMerge_data
      mkdir -p $outputDir/LHC17pq/
      hadd $outputDir/LHC17pq/$fileToMerge_data $outputDir/LHC17p/$fileToMerge_data $outputDir/LHC17q/$fileToMerge_data
      hadd $outputDir/$fileToMerge_data $outputDir/LHC15n/$fileToMerge_data $outputDir/LHC17p/$fileToMerge_data $outputDir/LHC17q/$fileToMerge_data
   fi

fi

if [ "$type" = "mc" ] || [ "$type" = "all" ] ; then
   steerAnalysis.sh $runList_LHC15n $inputDir_LHC15n_MC $outputDir/LHC15n/ 8 1 kTRUE LHC15n $tasks
   waitTilReady 4 LHC15n_mc 10
   bell 1500 2
   bell 3500 1
   bell 1500 2
   
   if [ "$runSeparate" = "yes" ] ; then
      steerAnalysis.sh $runList_LHC17pq $inputDir_LHC17pq_MC_woSDD $outputDir/LHC17pq_woSDD 8 1 kTRUE LHC17p $tasks
      waitTilReady 3 LHC17pq_woSDD_mc 10
      bell 1500 2
      bell 3500 1
      bell 1500 2
      steerAnalysis.sh $runList_LHC17pq_fast $inputDir_LHC17pq_MC_fast $outputDir/LHC17pq_fast 8 1 kTRUE LHC17p $tasks
      waitTilReady 0 LHC17pq_fast_mc 10
      bell 1500 2
      bell 3500 1
      bell 1500 2
      mergeResults.sh $runList_LHC15n $outputDir/LHC15n/ $deletePartialOutputs $fileToMerge_mc
      mergeResults.sh $runList_LHC17pq $outputDir/LHC17pq_woSDD $deletePartialOutputs $fileToMerge_mc
      mergeResults.sh $runList_LHC17pq_fast $outputDir/LHC17pq_fast $deletePartialOutputs $fileToMerge_mc
      mkdir -p $outputDir/LHC17pq/
      hadd $outputDir/LHC17pq/$fileToMerge_mc $outputDir/LHC17pq_woSDD/$fileToMerge_mc $outputDir/LHC17pq_fast/$fileToMerge_mc
      hadd $outputDir/$fileToMerge_mc $outputDir/LHC15n/$fileToMerge_mc $outputDir/LHC17pq/$fileToMerge_mc
   fi
   
   if [ "$runSeparate" = "no" ] ; then
      # in this case, run just on the CENT_woSDD sample (the efficiencies are the same)
      steerAnalysis.sh $runList_LHC17pq $inputDir_LHC17pq_MC_woSDD $outputDir/LHC17pq 8 1 kTRUE LHC17p $tasks
      waitTilReady 0 LHC17pq_mc 10
      bell 1500 2
      bell 3500 1
      bell 1500 2
      mergeResults.sh $runList_LHC15n $outputDir/LHC15n/ $deletePartialOutputs $fileToMerge_mc
      mergeResults.sh $runList_LHC17pq $outputDir/LHC17pq/ $deletePartialOutputs $fileToMerge_mc
      hadd $outputDir/$fileToMerge_mc $outputDir/LHC15n/$fileToMerge_mc $outputDir/LHC17pq/$fileToMerge_mc
   fi
fi

echo Started running at $startingTime >> $outputDir/status.log
echo Finished running at `date` >> $outputDir/status.log
bell 7000 2
bell 6000 1
bell 5000 2
bell 4000 1
bell 5000 2
bell 6000 1
bell 7000 2
bell 8000 1
bell 7000 2
bell 6000 1
bell 5000 2
bell 4000 1
bell 5000 2
bell 6000 1
bell 7000 2
