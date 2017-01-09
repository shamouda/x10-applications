#!/bin/bash

LULESH_DIR=$HOME/x10-applications/lulesh2_resilient

SIZE=35
CPFREQ=38
export GC_LARGE_ALLOC_WARN_INTERVAL=1000000
export DISABLE_ULFM_AGREEMENT=1

for run in `seq 1 1`;
do
    # date
    # echo "start run $run Native X10"
    # X10_NPLACES=8 X10_NTHREADS=4 X10_RESILIENT_MODE=0 $LULESH_DIR/bin/lulesh2.0 -s $SIZE -k $CPFREQ >& lulesh.8x4.s$SIZE.mode0.run$run.txt

    # date
    # echo "start run $run Resilient Native X10"
    # X10_NPLACES=8 X10_NTHREADS=4 X10_RESILIENT_MODE=1 $LULESH_DIR/bin/lulesh2.0 -s $SIZE -k $CPFREQ >& lulesh.8x4.s$SIZE.cp$CPFREQ.mode1.run$run.txt

    date
    echo "start run $run Resilient Native X10 with 3 failures"
    X10_NPLACES=11 X10_NTHREADS=4 KILL_STEPS=10,50,100 KILL_PLACES=3,5,6 X10_RESILIENT_MODE=1 bin/lulesh2.0 -i 300 -p -s $SIZE -k $CPFREQ -e 3 >& lulesh.8x4.s$SIZE.cp$CPFREQ.mode1.3failures.run$run.txt
#    X10_NPLACES=11 X10_NTHREADS=4 KILL_TIMES=60,120,180 KILL_PLACES=3,5,6 X10_RESILIENT_MODE=1 $LULESH_DIR/bin/lulesh2.0 -s $SIZE -k $CPFREQ -e 3 >& lulesh.8x4.s$SIZE.cp$CPFREQ.mode1.3failures.run$run.txt
done








