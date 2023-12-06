#!/bin/tcsh

#BSUB -P UMCP0006                # project code
#BSUB -W 12:00                   # wall-clock time (hrs:mins)
#BSUB -n 1                       # number of tasks in job         
##BSUB -R "span[ptile=16]"       # run 16 MPI tasks per node
#BSUB -J 2015           # job name
#BSUB -o 2015.%J.out    # output file name in which %J is replaced by the job ID
#BSUB -e 2015.%J.err    # error file name in which %J is replaced by the job ID
#BSUB -q premium                 # queue
#BSUB -N                         # sends report to you by e-mail when the job finishes

ncl noaa_nsst2soda_3.3.1_2015_moreSat.ncl >&! ncl_bsub_3.3.1_2015_2.log

exit 0
