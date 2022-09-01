TEST=DLRMOFFICIALPLOT_120
OMPS="120"
LOOP="16 32 60 120"
echo "########################"
echo "Starting DLRM OFFICIAL Testing"
echo "########################"
for j in $OMPS;do
        export OMP_NUM_THREADS=$j
        x=$(expr $j - 1)
        export GOMP_CPU_AFFINITY=0-59
        echo "thread# is $OMP_NUM_THREADS"
        echo "cpu number is $GOMP_CPU_AFFINITY"
   for i in $LOOP; do
        ts=$(date '+%Y%m%d%H%M%S')
        logfile=$TEST-$ts-$i-$j.log
        iostatfile=$TEST-$ts-$i-$j-iostat.log
        vmstatfile=$TEST-$ts-$i-$j-vmstat.log
        iostat -mdx 5 | sudo tee $iostatfile >/dev/null &
        vmstat 5 | sudo tee $vmstatfile >/dev/null &
        cmd="./run_local.sh pytorch dlrm terabyte cpu --scenario Offline --max-ind-range=40000000 --samples-to-aggregate-quantile-file=./tools/dist_quantile.txt --max-batchsize=$i --samples-per-query-offline ${i}00 --mlperf-bin-loader --output=/home/luojchen/dlrm_results --target-qps 250 2>&1 | sudo tee -a $logfile "
        echo $cmd
        echo $cmd | sudo tee -a $logfile
        eval $cmd
        killall -9 iostat
        killall -9 vmstat
        cp -r /home/luojchen/dlrm_results /home/luojchen/dlrmofficial_batch_results_${i}_OPM_120_2
        echo "-------------------------------Loop: $i of batch in OMP_Thread $j done.------------------"

   done
echo "Done OPM thread $j"
done
echo "Done test"
