c Example fortran program for using the fortran HDF API to read in 
c AVHRR Pathfinder Version 5 "number of observations" data files. The
c other time series files can also be read with minor
c modifications.
c
c compile with: 
c   f77 -o readPFV5_numobs readPFV5_numobs.f -L/home/kcasey/HDF4/lib -lmfhdf -ldf -ljpeg -lz
c
c where /home/kcasey/HDF4/lib is replaced with the location of your HDF4
c libraries.
c
c This program was originally written by Takaya Namba, and was modified by
c Kenneth S. Casey, NOAA National Oceanographic Data Center
c
c August 2005
c
       program readPFV5_numobs
       integer sd_id,sds_id,sds_index,file_id
       integer sfselect
       integer sfendacc
       integer sfend
       integer mgstart,sfstart
       integer start(2),edges(2),stride(2)
       integer retn,sfrdata
       integer file_info_status
       integer set_info_status
       integer n_file_attributes
       integer n_datasets
       integer sffinfo
       integer dim_sizes(2)        
       integer rank        
       integer data_type        
       integer n_set_attributes        
       integer sfginfo        
       integer sd_read_status
       integer sds_end_status
       integer sd_end_status
       character*56 sd_set_name
       character*1 num(8192,4096)
       integer*2 nnum(8192,4096)
       integer*2 value 
       parameter(DFACC_RDONLY  = 1)

c Open access to the HDF-SDS file.  After starting acces, print
c the sd_id value to the screen.  
c If it opened properly, the value will be a positve integer.
c If it failed to open properly, the value will be -1.
       sd_id=sfstart("./198501.m04m3pfv50-num.hdf",DFACC_RDONLY)
       print 100, sd_id
  100  format ('sd_id = ',i10)

c Now get some information from the HDF file: n_datasets is the 
c number of datasets in this HDF file, and n_file_attributes 
c indicates how many global metadata attributes are in the file.  After
c getting this information, print the status of the get information
c request. A status value of 0 indicates success, while -1 is failure.
       file_info_status=sffinfo(sd_id,n_datasets,n_file_attributes)
       print 101, file_info_status
  101  format ('file_info_status = ',i10)

c Now select the dataset we want to work with. HDF numbering 
c begins with 0, so the you can select a value from 0 to n_datasets.
c After selecting the dataset, print out the sds_id. A positive value
c indicates the selection was successful, while -1 indicates failure.
c Note that at this stage we are only pointing to the dataset... we
c have not actually read it in yet.
       sds_id=sfselect(sd_id,0)
       print 102, sds_id
  102  format ('sds_id = ',i10)

c Now we get information on the selected dataset.
c  sd_set_name = the name of the dataset
c  rank = number of dimensions in the dataset
c  dim_sizes = the number of elements in each dimension
c  data_type = the type of data stored in the dataset (integer, etc.)
c  n_set_attributes = the number of metadata attributes associated 
c                     with this dataset (this is different than the
c                     number of global attributes identified above)
c After getting this information, print the status of the get information
c request. A status value of 0 indicates success, while -1 is failure.
c Also print out the name of the data set we have selected.
       set_info_status=sfginfo(sds_id,sd_set_name,rank,dim_sizes,
     .data_type,n_set_attributes)
       print 103, set_info_status
  103  format ('sset_info_status = ',i5)

       print 104, sd_set_name
  104  format ('bsd_set_name = ',a56)

c Now set up to do the reading of the data.
c       xl=number of elements in x
c       yl=number of elements in y
c       start(1)=where in x to start reading the array (0 based)
c       start(2)=where in y to start reading the array (0 based)
c       stride(1)=whether to read all values in x (stride(1)=1) or to skip
c         and read only a subsampling of all the values (for example, a
c         stride(1)=2 will skip and read only every other value)
c       stride(2)=same as above, but for y
c       edges(1)=how far to read in x
c       edges(2)=how far to read in y
c These elements are all much better explained in the HDF 4 Users Guide
       xl=8192
       yl=4096
       start(1)=0
       start(2)=0
       stride(1)=1
       stride(2)=1
       edges(1)=xl
       edges(2)=yl

c Here we do the actual reading of the data, using the above parameters.
c As in previous steps, print out the status, where 0 is a success, and
c -1 a failure.
       sd_read_status=sfrdata(sds_id,start,stride,edges,num)
       print 105, sd_read_status
  105  format ('sd_read_status = ',i5)

c Now, here is an odd thing we have to do to handle fortran's inability
c to use unsigned integers (all the Pathfinder data are stored as either
c 8-bit or 16-bit unsigned integers, depending on which data you are 
c using).  If your fortran compiler can handle unsigned integers, use
c them when you compile the code and you won't have to do the following
c manipulation, which converts the negative integer values into positive
c values.  When read in as signed integers, the values range from -128 to
c +127, instead of 0 to 255 as they should be.
       do j=1,4096
         do i=1,8192
           value=ichar(num(i,j))
           if(value .lt. 0) value=value+256
           nnum(i,j)=value
         enddo
       enddo 

c Now, print out the values to an ascii file so you can be confident in 
c the values you have read in.  In this example, we are writing out only
c every eigth value, even though all values were read in.
       open(99,file="readPFV5_numobs_output.txt")
       write(99,"(1024(i5,2x))")((nnum(i,j),i=1,8192,8),j=1,4096,8)
c      write(99,"(8192(i5,2x))")((nnum(i,j),i=1,8192),j=1,4096)

c Now, end access to the data set we have been working with (sds_id). If
c this HDF file had more data sets in it, we could end access to this 
c data set and begin working with another.  Since we are done (and indeed
c Version 5 Pathfinder data have only one data set per file), we will simply
c end access to the data set, print the status (0 for success, -1 for failure),
c then in the next step end access to the file entirely.
       sds_end_status=sfendacc(sds_id)
       print 106, sds_end_status
  106  format ('sds_end_status = ',i5)

c Now terminate access to the entire HDF file, and print the status:
       sd_end_status=sfend(sd_id)
       print 107, sd_end_status
  107  format ('sd_end_status = ',i5)

c       stop
       end
