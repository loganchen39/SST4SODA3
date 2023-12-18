#!/bin/tcsh

#PBS  -A UMCP0009   
#PBS  -l walltime=12:00:00              
# #PBS  -l select=1:ncpus=36:mpiprocs=36
#PBS  -l select=1:ncpus=1:mpiprocs=1 
#PBS  -N nst_2018
#PBS  -j oe
#PBS  -q economy
 
ncl noaa_nsst2soda_3.3.1_2020.ncl >&! ncl_qsub_005.log
 
exit 0
