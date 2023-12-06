	PROGRAM read_hdf
c
       integer sd_id,sds_index,file_id
       integer sds_id
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
       integer data_type, n_values        
       integer n_set_attributes, attr_index        
       integer sfginfo        
       integer sd_read_status
       integer sds_end_status
       integer sd_end_status
       character*56 sd_set_name
       character*1 qual(8192,4096)
       integer*2 nqual(8192,4096)
       integer*2 value 
       parameter(DFACC_RDONLY  = 1)
c
        character*20 attr_name
	real buffer
	integer*2 nsst(8192,4096)
        real  scale_factor, scale_factor_err
        real  add_offset, add_offset_err
	real*8 lat(4096), lon(8192)
	real sst(8192,4096)
	character*60 qfname, dfname
c
        qfname='DATA/2005001-2005005.m0454pfrt-qual.hdf'
        dfname='DATA/2005001-2005005.s0454pfrt-sst.hdf'
c
c--- read file with quality flags
c
	write(6,*) 'open file => ', qfname
	sd_id=sfstart(qfname, DFACC_RDONLY)
	write(6,*) 'sd_id=',sd_id
c
	file_info_status=sffinfo(sd_id,n_datasets,
     &                           n_file_attributes)
	write(6,*) 'file_info_status=',file_info_status
c
c--- read quality flag
c
        sds_id=sfselect(sd_id,0)
	write(6,*) 'data set #0,  sds_id=',sds_id
c
        set_info_status=sfginfo(sds_id,sd_set_name,
     &                  	rank,dim_sizes,
     &                          data_type,n_set_attributes)
c
	write(6,*) 'sd_set_name=',sd_set_name 
c
        start(1)=0
        start(2)=0
        stride(1)=1
        stride(2)=1
        edges(1)=dim_sizes(1)
        edges(2)=dim_sizes(2)
c
        sd_read_status=sfrdata(sds_id,start,stride,edges,qual)
c
        do j=1,4096
          do i=1,8192
            value=ichar(qual(i,j))
            if(value .lt. 0) value=value+256
            nqual(i,j)=value
          enddo
        enddo
c 
	sd_read_status=sfendacc(sds_id)
	write(6,*) 'data set #1 is closed, status =',
     &              sd_read_status
c
        write(6,*) '---=> quality falgs are readed'
c
c--- read latitude
c
        sds_id=sfselect(sd_id,1)
	write(6,*) 'data set #1,  sds_id=',sds_id
c
        set_info_status=sfginfo(sds_id,sd_set_name,
     &                          rank,dim_sizes,
     &                          data_type,n_set_attributes)
c
	write(6,*) 'sd_set_name=',sd_set_name 
c
        start(1)=0
        start(2)=0
        stride(1)=1
        stride(2)=1
        edges(1)=dim_sizes(1)
        edges(2)=dim_sizes(2)
c
        sd_read_status=sfrdata(sds_id,start,stride,edges,lat)
c
c	write(6,*) lat
c
	sd_read_status=sfendacc(sds_id)
	write(6,*) 'data set #2 is closed, status =',
     &              sd_read_status
c
        write(6,*) '---=> latitudes are readed'
c
c--- read longitude
c
        sds_id=sfselect(sd_id,2)
	write(6,*) 'data set #1,  sds_id=',sds_id
c
        set_info_status=sfginfo(sds_id,sd_set_name,
     &                          rank,dim_sizes,
     &                          data_type,n_set_attributes)
c
	write(6,*) 'sd_set_name=',sd_set_name 
c
        start(1)=0
        start(2)=0
        stride(1)=1
        stride(2)=1
        edges(1)=dim_sizes(1)
        edges(2)=dim_sizes(2)
c
        sd_read_status=sfrdata(sds_id,start,stride,edges,lon)
c
c	write(6,*) lon
c
        write(6,*) '---=> longitudes are readed'
c
	sd_read_status=sfendacc(sds_id)
	write(6,*) 'data set #3 is closed, status =',
     &              sd_read_status
c
        sd_end_status=sfend(sd_id)
	write(6,*) 'file with quality flags is closed, 
     &  status=', sd_end_status
c
c
c--- read file with SST data
c
        write(6,*) ''
	write(6,*) 'open file => ', dfname
	sd_id=sfstart(dfname, DFACC_RDONLY)
	write(6,*) 'sd_id=',sd_id
c
	file_info_status=sffinfo(sd_id,n_datasets,
     &                           n_file_attributes)
	write(6,*) 'file_info_status=', file_info_status
c
c--- read SST data
c
        sds_id=sfselect(sd_id,0)
	write(6,*) 'data set #0,  sds_id=',sds_id
c
        set_info_status=sfginfo(sds_id,sd_set_name,
     &                  	rank,dim_sizes,
     &                          data_type,n_set_attributes)
c
      write(*,*) "-----------------------------------"
      write(*,*) " Dataset name: ", sd_set_name
      write(*,*) "   Number of dimensions = ", rank
      write(*,*) "     dim_sizes(1) = ", dim_sizes(1)
      write(*,*) "     dim_sizes(2) = ", dim_sizes(2)
      write(*,*) "   Number of attributes = ", n_set_attributes
      write(*,*) " "
      write(*,*) "-------------------------------"
      write(*,*) "   Attribute Name      Length"
      write(*,*) "-------------------------------"
      do 20 attr_index = 0, n_set_attributes-1
        status = sfgainfo(sds_id, attr_index, 
     &                    attr_name, data_type, 
     &                    n_values)
        write(*,*) " ",attr_name, n_values, data_type
20    continue
      write(*,*) "-----------------------------------"
      write(*,*) " "
c
        status=sfrcatt(sd_id, 10, buffer)
	write(*,*) 'scale factor = ', buffer
c
      status = sfgcal(sds_id, scale_factor, scale_factor_err, 
     &                add_offset, add_offset_err, data_type) 
      write(*,*) " scale_factor = ", scale_factor
      write(*,*) " add_offset   = ", add_offset
      write(*,*) " "
      write(*,*) " Remember to multiply by scale_factor and "
      write(*,*) " add add_offset to convert from pixel to deg C!"
      write(*,*) " "
	write(6,*) 'sd_set_name=',sd_set_name 
c
        start(1)=0
        start(2)=0
        stride(1)=1
        stride(2)=1
        edges(1)=dim_sizes(1)
        edges(2)=dim_sizes(2)
c
        sd_read_status=sfrdata(sds_id,start,stride,edges,nsst)
c
        do j=1,4096
          do i=1,8192
	    if(nsst(i,j).gt.0) then
	      if(nqual(i,j).ge.7) then
                sst(i,j) = 0.075*nsst(i,j)-3.0
		write(*,*) lon(i),lat(j),sst(i,j)
	      else
	        sst(i,j) = 0.
	      endif
	    endif
c            value=ichar(qual(i,j))
c            if(value .lt. 0) value=value+256
c            nqual(i,j)=value
          enddo
        enddo
c
c        write(6,*) sst

	stop
	end
	
