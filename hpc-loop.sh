#!/bin/bash -l
source switch_to_2015a
module load worker/1.6.4-intel-2015a


submit_node='login1.hpc.kuleuven.be'
pbs_script_name='hpc-loop.pbs'
pbs_file="${pbs_script_name}"
output_file="${pbs_script_name}.o${jobid}" 
error_file="${pbs_script_name}.e${jobid}" 
jobid=$(echo ${PBS_JOBID} | cut -d. -f1)

counter=$2

if [[ $counter > 0 ]]
then
    wsub -l nodes=1:ppn=20:ivybridge \
	 -batch hpc-loop.pbs \
         -data args.txt \
         -o ${output_file} \
         -e ${error_file} \                    
         -l depend=afterok:${PBS_JOBID} \
         ${pbs_file} > /dev/null
    source marsdOneIter.sh $1
    counter=$(( ${counter} - 1 ))
fi

