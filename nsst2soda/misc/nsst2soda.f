	PROGRAM nsst2soda
c
c run on the pacific.umd.edu 
c with
c ifort nsst2soda.f -L/usr/lib -lmfhdf -ldf -ljpeg -lz
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
       integer data_type        
       integer n_set_attributes        
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
	integer*2 nsst(8192,4096)
	real*8 lat(4096), lon(8192)
	real sst(8192,4096)
	character*60 qfname, dfname, fout
	real xla(180), xlo(360), xsst(360,180)
	integer ndat, ksst(360,180), p
	character*4 yr
	character*3 d1, d2
c
c --- start date for the year 2005
c	parameter (ndat0=13372)
c	parameter (yr='2005')
c --- start date for the year 2006
c	parameter (ndat0=13737)
c	parameter (yr='2006')
c --- start date for the year 2007
c	parameter (ndat0=14102)
c	parameter (yr='2007')
c --- start date for the year 2008
	parameter (ndat0=14467)
	parameter (yr='2008')
c 
        do l=1,180
          xla(l)=-89.5+(l-1)*1.0
        enddo
c
        do i=1,360
          xlo(i)=float(i)
        enddo
c
	do i=1,360
	  do j=1,180
	    xsst(i,j)=0.0
	    ksst(i,j)=0
	  enddo
	enddo
c
	fout='nst_sst_'//yr//'.bi'
	open(30, file=fout,status='unknown')
c
	ndat= ndat0
c
      do k = 1,365,5
	p=k
	if(p.le.9) write(d1,'(a,i1)') '00',p
	if(p.ge.10.and.p.le.99) write(d1,'(a,i2)') '0',p
	if(p.ge.100.and.p.le.999) write(d1,'(i3)') p
	p=p+4
	if(p.le.9) write(d2,'(a,i1)') '00',p
	if(p.ge.10.and.p.le.99) write(d2,'(a,i2)') '0',p
	if(p.ge.100.and.p.le.999) write(d2,'(i3)') p
c	
        qfname='DATA/'//yr//d1//'-'//yr//d2//'.m0451pfrt-qual.hdf'
        dfname='DATA/'//yr//d1//'-'//yr//d2//'.s0451pfrt-sst.hdf'
c
c--- read file with quality flags
c
	write(*,*) ''
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
	write(6,*) 'data set #0 is closed, status =',
     &              sd_read_status
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
	sd_read_status=sfendacc(sds_id)
	write(6,*) 'data set #1 is closed, status =',
     &              sd_read_status
c
c--- read longitude
c
        sds_id=sfselect(sd_id,2)
	write(6,*) 'data set #2,  sds_id=',sds_id
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
	sd_read_status=sfendacc(sds_id)
	write(6,*) 'data set #2 is closed, status =',
     &              sd_read_status
c
        sd_end_status=sfend(sd_id)
	write(6,*) 'file with quality flags is closed, 
     &  status=', sd_end_status
c
c--- read file with SST data
c
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
	  j1=floor(lat(j))+91
          do i=1,8192
	    if(nsst(i,j).gt.0) then
	      if(nqual(i,j).ge.7) then
	        if(lon(i).le.0.0) then
		  i1=floor(lon(i)+360.)
		else
       	          i1=floor(lon(i))
		endif
c       	 i1=floor(lon(i))+181
                xsst(i1,j1)=xsst(i1,j1)+0.075*nsst(i,j)-3.0
		ksst(i1,j1)=ksst(i1,j1)+1
	      endif
	    endif
          enddo
        enddo
c
        sd_end_status=sfend(sd_id)
	write(6,*) 'file with SST data is closed, 
     &  status=', sd_end_status
c
	do i=1,360
	  do j=1,180
	    if(ksst(i,j).ne.0) then
	      if(xsst(i,j)/ksst(i,j).ge.-2.0.and.
     &           xsst(i,j)/ksst(i,j).le.32.0) then
	        write(30,111) ndat, xla(j), xlo(i),
     &                xsst(i,j)/ksst(i,j)
	      endif
	    endif
	  enddo
	enddo
c
	ndat = ndat + 5
c
      enddo
c
      close (30)
c
111   format(1x,i5,1x,f5.1,1x,f5.1,2x,f5.2)
c
      stop
      end
	
