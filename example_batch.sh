#!/bin/bash -l

source switch_to_2015a
module load worker/1.6.4-intel-2015a

wsub -l nodes=1:ppn=20 -threaded 10 \
     -v nf=$1 \
     -batch submit_test.pbs -data args.txt

