c readPFV5_Reynolds.f - Read Pathfinder V5 SST and write some values to ASCII
c ----------------------------------------------------------------------------
c
c Example fortran program for using the fortran HDF API to read in 
c AVHRR Pathfinder Version 5 files that were created for Dick Reynolds,
c NOAA/NCDC.  These files differ from the original Pathfinder V5 files
c in that quality flags of 4-7 and 7 have already been applied, and
c Latitde and Longitude are included as explicit layers in the HDF-SDS
c file as well.  So, each Reynolds file contains:
c
c      SST7
c      Latitude
c      Longitude
c      SST4
c
c compile with: 
c   f77 -o readPFV5_reynolds readPFV5_reynolds.f -L/home/kcasey/HDF4/lib -lmfhdf -ldf -ljpeg -lz
c
c Then, run simply with:
c
c   read_PFV5_reynolds
c
c There is a lot of output to the screen, so you may wish to run with:
c
c   read_PFV5_reynolds > out.txt
c
c In either case, three ASCII text files will be created showing a
c subset of the data contained in the HDF file. These three files are:
c       example_output_pixval.txt - contains every 512th pixel value
c                                   from the dataset "SST7", which is
c                                   the SST field after setting to 0
c                                   any pixel with a quality flag < 7.
c       example_output_sstdegc.txt - Same as above, but converted to 
c                                    SST in degrees see using 
c                                    scale_factor and add_offset
c       example_output_pixval_qf4.txt - Same as first, but for "SST4"
c                                       in which pixels of quality
c                                       flag < 4 ihave been masked.
c
c
c The assistance of Takaya Namba is gratefully acknowledged, 
c along with the the example HDF code found at:
c         http://hdf.ncsa.uiuc.edu/training/UG_Examples/SD 
c
c By:
c Kenneth S. Casey, NOAA National Oceanographic Data Center.
c Kenneth.Casey@noaa.gov
c March 2005
c
c
c ----------------------------------------------------------------------------
       program readPFV5_reynolds
c Variable declarations:
       integer sd_id,sds_id,sds_index,file_id
       integer sfselect, sfendacc, sffinfo
       integer sfginfo, sfstart, sfend, sfrdata, sfrcdata
       integer sfgainfo, sfgcal, sfrcatt, sfrnatt
       integer start(2),edges(2),stride(2)
       integer status
       integer n_file_attributes
       integer n_datasets
       integer dim_sizes(2)        
       integer rank        
       integer data_type, n_values
       integer n_set_attributes, attr_index
       integer n_dim_attributes
       integer dataset_number
       character*56 sd_set_name
       character*20 attr_name
       character*900 attr_val_char
       real*8 attr_val_num(20)
       character*20 dim_name
       integer*2 sst7(8192,4096)
       integer*2 sst4(8192,4096)
       real*8 latitude(4096)
       real*8 longitude(8192)
       integer*2 value 
       real*8  scale_factor, scale_factor_err
       real*8  add_offset, add_offset_err
c Parameter declarations:
       character*30 FILE_NAME
       character*30 OUTPUT_FILE_PIXVAL
       character*30 OUTPUT_FILE_SSTDEGC
       character*30 OUTPUT_FILE_PIXVAL4
       parameter(FILE_NAME ='1999001.pfv50-nitsst.hdf')
       parameter(OUTPUT_FILE_PIXVAL ='example_output_pixval.txt')
       parameter(OUTPUT_FILE_SSTDEGC='example_output_sstdegc.txt')
       parameter(OUTPUT_FILE_PIXVAL4='example_output_pixval_qf4.txt')
       parameter(DFACC_RDONLY  = 1)
       parameter(DFNT_CHAR = 4)
       parameter(DFNT_NUM = 6)

c Open access to the HDF-SDS file.  After starting acces, print
c the sd_id value to the screen.  
c If it opened properly, the value will be a positve integer.
c If it failed to open properly, the value will be -1.
       write(*,*) " "
       write(*,*) "===================================================="
       sd_id=sfstart(FILE_NAME,DFACC_RDONLY)
       if (sd_id .eq. -1) then
         write(*,*) "Failed to open access to  ", FILE_NAME
         write(*,*) "  File may not exist.  Exiting..."
         stop
       else
         write(*,*) "Successfully opened ", FILE_NAME
       endif

c Now get some information from the HDF file: n_datasets is the 
c number of datasets in this HDF file, and n_file_attributes 
c indicates how many global metadata attributes are in the file.  After
c getting this information, print the status of the get information
c request. A status value of 0 indicates success, while -1 is failure.
       status=sffinfo(sd_id,n_datasets,n_file_attributes)
       write(*,*) "Number of datasets in this file = ", n_datasets
       write(*,*) "Number of global attributes = ", n_file_attributes

c Now print out global attributes of the HDF-SDS file:
      write(*,*) " "
      write(*,*) "-------------------------------------------------"
      write(*,*) " Attribute Name     Length    Value"
      write(*,*) "-------------------------------------------------"
      do 10 attr_index = 0, n_file_attributes-1
        status = sfgainfo(sd_id, attr_index, attr_name, data_type, 
     +          n_values)
        if (data_type .eq. DFNT_CHAR) then
          attr_val_char=""
          status = sfrcatt(sd_id, attr_index, attr_val_char)
          if (n_values .LE. 30) then
            write(*,*) " ", attr_name, n_values, 
     +                      "  ", attr_val_char(1:30)
          else
            write(*,*) " ", attr_name, n_values, 
     +                      "  ", attr_val_char(1:30), "..."
          endif
        else
          status = sfrnatt(sd_id, attr_index, attr_val_num)
c        I know all these have integer values, even though some are
c        stored as real, so it is ok to convert to int for display:
          write(*,111) attr_name, n_values, 
     +      (int(attr_val_num(i)),i=1,n_values)
111       format (2X,A,1X,I2,4X,20I4)
        endif
10    continue
      write(*,*) "-------------------------------------------------"
      write(*,*) " "

c Now select the dataset we want to work with. HDF numbering  begins 
c with 0, so the you can select a value from 0 to n_datasets.  A positive value
c of sds_id indicates the selection was successful, while -1 indicates failure.
c Note that at this stage we are only pointing to the dataset... we
c have not actually read it in yet.  In the data files for Reyolds:
c
c SST7 = 0
c Latitude = 1
c Longitude = 2
c SST4 = 3
c
c First, we use 0 to select the SST7 array, which contains only SST
c values passing the quality flag==7 test (this is the highest flag)
       dataset_number=0
       sds_id=sfselect(sd_id,dataset_number)

c Now we get information on the selected dataset.
c  sd_set_name = the name of the dataset
c  rank = number of dimensions in the dataset
c  dim_sizes = the number of elements in each dimension
c  data_type = the type of data stored in the dataset (integer, etc.)
c  n_set_attributes = the number of metadata attributes associated 
c                     with this dataset (this is different than the
c                     number of global attributes identified above)
c After getting this information, print some of it to the screen.
      status=sfginfo(sds_id,sd_set_name,rank,dim_sizes,
     +               data_type,n_set_attributes)
      write(*,*) "-----------------------------------"
      write(*,*) " Dataset name: ", sd_set_name
      write(*,*) "   Dataset number = ", dataset_number
      write(*,*) "   Number of dimensions = ", rank
      write(*,*) "     dim_sizes(1) = ", dim_sizes(1)
      write(*,*) "     dim_sizes(2) = ", dim_sizes(2)
      write(*,*) "   Number of attributes = ", n_set_attributes
      write(*,*) " "
      write(*,*) "-------------------------------"
      write(*,*) "   Attribute Name      Length"
      write(*,*) "-------------------------------"
      do 20 attr_index = 0, n_set_attributes-1
        status = sfgainfo(sds_id, attr_index, attr_name, data_type, 
     +          n_values)
        write(*,*) " ",attr_name, n_values
20    continue
      write(*,*) "-----------------------------------"
      write(*,*) " "

c Although the scale and offset needed to convert the pixel
c values into degrees are contained as attributes for this
c dataset, they are also included in a special HDF-defined
c attribute which has its own access function. Let's use
c this to get the scale and offset for this dataset:
      status = sfgcal(sds_id, scale_factor, scale_factor_err, 
     +                     add_offset, add_offset_err, data_type) 
      write(*,*) " scale_factor = ", scale_factor
      write(*,"(A,F4.1)") "  add_offset = ", add_offset
      write(*,*) " "
      write(*,*) " Remember to multiply by scale_factor and "
      write(*,*) " add add_offset to convert from pixel to deg C!"
      write(*,*) " "

c Now prepare to do the reading of the data.
c       xl=number of elements in x  [dim_sizes(1)]
c       yl=number of elements in y  [dim_sizes(2)]
c       start(1)=where in x to start reading the array (0 based)
c       start(2)=where in y to start reading the array (0 based)
c       stride(1)=whether to read all values in x (stride(1)=1) or to skip
c         and read only a subsampling of all the values (for example, a
c         stride(1)=2 will skip and read only every other value)
c       stride(2)=same as above, but for y
c       edges(1)=how far to read in x
c       edges(2)=how far to read in y
c These elements are all much better explained in the HDF 4 Users Guide.
       xl = dim_sizes(1)
       yl = dim_sizes(2)
       start(1)=0
       start(2)=0
       stride(1)=1
       stride(2)=1
       edges(1)=xl
       edges(2)=yl

c Here we do the actual reading of the data, using the above parameters.
c As in previous steps, status is 0 for success -1 for failure.  Note
c that here we use sfrcdata since sst7 is integer*2 type data.  Below,
c when reading real*8 data, we'll use sfrdata.  (in C, the same function
c is used for both)
       write(*,*) "    Reading data... "
       status=sfrcdata(sds_id,start,stride,edges,sst7)

c Now, print out the values to an ascii file so you can be confident in 
c the values you have read in.  In this example, we are writing out only
c every 512th value, even though all values were read in. First write
c out the unconverted pixel valuesL
       write(*,*) "    Example output (every 512th pixel value) has "
       write(*,*) "    been written to ", OUTPUT_FILE_PIXVAL
       write(*,*) " "
       open(99,file=OUTPUT_FILE_PIXVAL)
       write(99,"(16(i3,2x))")((sst7(i,j),i=1,8192,512),j=1,4096,512)
c Now write out every 512th value after converting to deg C:
       write(*,*) "    Example output (every 512th SST value) has "
       write(*,*) "    been written to ", OUTPUT_FILE_SSTDEGC
       write(*,*) " "
       open(98,file=OUTPUT_FILE_SSTDEGC)
       write(98,"(16(f6.3,1x))")((sst7(i,j)*scale_factor+add_offset,
     +                          i=1,8192,512),j=1,4096,512)

c Now, end access to the data set we have been working with (sds_id).  Since
c this HDF file has more data sets in it, we can end access to this 
c data set and begin working with the others.  So, we will now end access
c to the current data set.
       status=sfendacc(sds_id)

c  Ok, if all of the above looks rather confusing, this time we will 
c  simply select the latitude and longitude datasets, read them in,
c  print a few values to the screen, then end access to them without
c  any further commentary.  Note to read these data sets, we will use
c  sfrdata, since they are real*8. Note that having Latitude and Longitude
c  included as distinct data sets in an HDF file is not really
c  necessary, since you can give names and values to the dimensions 
c  of datasets HDF (as I have done here for both SST7 and SST4).
c  However, some people find it easier to have them as separate
c  datasets, so I have included them as well. So, without further 
c  commentary, select, read, display, and close:
       do 30 dataset_number = 1,2
         sds_id=sfselect(sd_id,dataset_number)
         status=sfginfo(sds_id,sd_set_name,rank,dim_sizes,
     +                           data_type,n_set_attributes)
         write(*,*) "-----------------------------------"
         write(*,*) " "
         write(*,*) " Dataset name = ", sd_set_name 
         write(*,*) "    dataset number = ", dataset_number
         write(*,*) "    dim_sizes(1) = ", dim_sizes(1)
         write(*,*) "    Example output (every 512th value):"
         start(1)=0
         stride(1)=1
         edges(1)=dim_sizes(1)
         write(*,*) "    Reading data... "
         if (dataset_number .eq. 1) then
           status=sfrdata(sds_id,start,stride,edges,latitude)
           write(*," (8(F8.3,x))")(latitude(i),i=1,dim_sizes(1),512)
         else
          status=sfrdata(sds_id,start,stride,edges,longitude)
           write(*," (16(F8.3,x))")(longitude(i),i=1,dim_sizes(1),512)
         endif
         write(*,*) " "
         status=sfendacc(sds_id)
30     continue
       write(*,*) "-----------------------------------"

c Now also read in the SST4 field, and send output to one text file:
       dataset_number=3
       sds_id=sfselect(sd_id,dataset_number)
       status=sfginfo(sds_id,sd_set_name,rank,dim_sizes,
     +                         data_type,n_set_attributes)
       write(*,*) " "
       write(*,*) " Dataset name = ", sd_set_name
       write(*,*) "    dataset number = ", dataset_number
       write(*,*) "    dim_sizes(1) = ", dim_sizes(1)
       write(*,*) "    dim_sizes(2) = ", dim_sizes(2)
       start(1)=0
       start(2)=0
       stride(1)=1
       stride(2)=1
       edges(1)=dim_sizes(1)
       edges(2)=dim_sizes(2)
       write(*,*) "    Reading data... "
       status=sfrcdata(sds_id,start,stride,edges,sst4)
       write(*,*) "    Example output (every 512th pixel value) has "
       write(*,*) "    been written to ", OUTPUT_FILE_PIXVAL4
       write(*,*) " "
       open(97,file=OUTPUT_FILE_PIXVAL4)
       write(97,"(16(i3,2x))")
     +      ((sst4(i,j),i=1,dim_sizes(1),512),j=1,dim_sizes(2),512)
       status=sfendacc(sds_id)

c Now terminate access to the entire HDF file, and print the status:
       status=sfend(sd_id)
       write(*,*) "-----------------------------------"
       write(*,*) " Done. Goodbye. "
       write(*,*) " "
       write(*,*) "===================================================="
       write(*,*) " "

       stop
       end
