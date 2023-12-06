#!/bin/tcsh

#BSUB -P UMCP0006                # project code
#BSUB -W 12:00                   # wall-clock time (hrs:mins)
#BSUB -n 1                       # number of tasks in job         
##BSUB -R "span[ptile=16]"       # run 16 MPI tasks per node
#BSUB -J sst_noaa2soda           # job name
#BSUB -o sst_noaa2soda.%J.out    # output file name in which %J is replaced by the job ID
#BSUB -e sst_noaa2soda.%J.err    # error file name in which %J is replaced by the job ID
#BSUB -q premium                 # queue
#BSUB -N                         # sends report to you by e-mail when the job finishes

ncl noaa_nsst2soda_3.3.1_2003.ncl >&! ncl_bsub_3.3.1_2003.log

exit 0
