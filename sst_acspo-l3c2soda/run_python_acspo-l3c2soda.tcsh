#!/bin/tcsh

# #PBS  -A UMCP0009   
#PBS  -A UMCP0014   
#PBS  -l walltime=12:00:00              
# #PBS  -l select=1:ncpus=36:mpiprocs=36
#PBS  -l select=1:ncpus=1:mpiprocs=1 
#PBS  -N sst_l3c2soda
#PBS  -j oe
#PBS  -q regular
# #PBS  -q economy
#PBS  -M lchen2@umd.edu

# module load conda/latest
# conda activate npl
 
python SST_ACSPO-L3C2SODA.py >&! py_qsub_2022_003.log
 
exit 0
