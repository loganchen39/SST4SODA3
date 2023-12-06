#!/bin/tcsh

#PBS  -A UMCP0009   
#PBS  -l walltime=12:00:00
#PBS  -l select=1:ncpus=1:mpiprocs=1 
#PBS  -N sst2017
#PBS  -j oe
#PBS  -q regular

ncl noaa_nsst2soda_3.3.1_2017.ncl >&! ncl_bsub_3.3.1_2017_2.log

exit 0
