#!/bin/tcsh

#PBS  -A UMCP0009   
#PBS  -l walltime=12:00:00              
# #PBS  -l select=1:ncpus=36:mpiprocs=36
#PBS  -l select=1:ncpus=1:mpiprocs=1 
#PBS  -N sst_12  
#PBS  -j oe
#PBS  -q economy
#PBS  -M lchen2@umd.edu
 
ncl noaa_nsst2soda_3.3.1_2020_12.ncl >&! ncl_qsub_012.log
 
exit 0
