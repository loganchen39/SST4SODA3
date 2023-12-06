program nsst2soda
    use netcdf
    implicit none

    ! target SODA regular grid
    real         xla(180), xlo(360), xsst(360, 180)
    integer      ndat, ksst(360, 180), p    

    ! time flag for obs sst file name
    character(len=*) :: DIR_ROOT_DATA_SST = "/glade/p/umcp0006/pub/data/SST"
    character(len=*) :: STR_FN_METOPA     = "0000-STAR-L2P_GHRSST-SSTskin-AVHRRMTA_G-ACSPO_V2.40-v02.0-fv01.0.nc"
    character(len=*) :: STR_FN_METOPB     = "0000-STAR-L2P_GHRSST-SSTskin-AVHRRMTB_G-ACSPO_V2.40-v02.0-fv01.0.nc"
    character(len=*) :: STR_FN_NOAA19     = "0000-STAR-L2P_GHRSST-SSTskin-AVHRR19_G-ACSPO_V2.40-v02.0-fv01.0.nc"

    character(len=4) :: str_yr
    character(len=2) :: str_mon, str_day, str_hr
    
    ! netCDF id
    integer :: ncid_sst_noaa, varid_lat, varid_lon, varid_sst, varid_sses_bias, varid_12p_flags  &
        , varid_quality_level, ni, nj

    ! vars to receive data
    real(kind=4), allocatable :: lat(:, :), lon(:, :), sst(:, :), sses_bias(:, :), 12p_flags(:, :)  &
        , quality_level(:, :)


    





    integer      sd_id, sds_index, file_id
    integer      sds_id
    integer      sfselect
    integer      sfendacc
    integer      sfend
    integer      mgstart, sfstart
    integer      start(2), edges(2), stride(2)
    integer      retn, sfrdata
    integer      file_info_status
    integer      set_info_status
    integer      n_file_attributes
    integer      n_datasets
    integer      sffinfo
    integer      dim_sizes(2)        
    integer      rank        
    integer      data_type        
    integer      n_set_attributes        
    integer      sfginfo        
    integer      sd_read_status
    integer      sds_end_status
    integer      sd_end_status
    character*56 sd_set_name
    character*1  qual (8192, 4096)
    integer*2    nqual(8192, 4096)
    integer*2    value 
    parameter    (DFACC_RDONLY = 1)
 
    integer*2    nsst(8192, 4096)
    real*8       lat(4096), lon(8192)
    real         sst(8192, 4096)
    character*60 qfname, dfname, fout

    character*4  yr
    character*3  d1, d2
     
    ! --- start date for the year 2005
    !	parameter (ndat0=13372)
    !	parameter (yr='2005')
    ! --- start date for the year 2006
    !	parameter (ndat0=13737)
    !	parameter (yr='2006')
    ! --- start date for the year 2007
    !	parameter (ndat0=14102)
    !	parameter (yr='2007')
    ! --- start date for the year 2008
    parameter (ndat0 = 14467 )  ! 14467 = 14102 + 365
    parameter (yr    = '2008')
  
    do l = 1, 180
        xla(l) = -89.5 + (l - 1)*1.0  ! latitude for target regular grid
    end do
 
    do i = 1, 360
      xlo(i) = float(i)  ! longitude for target regular grid
    end do
 
    do i = 1, 360
        do j = 1, 180
            xsst(i, j) = 0.0  ! final result sst on target regular grid
            ksst(i, j) = 0
        end do
    end do
     
    fout = 'nst_sst_' // yr // '.bi'  ! final result sst output file
    open(30, file = fout, status = 'unknown')
     
    ndat = ndat0  ! start julian day
 
    do k = 1, 365, 5  ! for each 5-day, compute the average sst
        p = k
        if(p .le. 9)                    write(d1, '(a, i1)') '00', p  ! e.g. d1 = "001"
        if(p .ge. 10  .and. p .le. 99 ) write(d1, '(a, i2)') '0' , p  ! e.g. d1 = "011"
        if(p .ge. 100 .and. p .le. 999) write(d1, '(i3)'   ) p        ! e.g. d1 = "121", start of current 5-day
        p = p + 4
        if(p .le. 9)                    write(d2, '(a, i1)') '00', p  ! e.g. d2 = "005"
        if(p .ge. 10  .and. p .le. 99 ) write(d2, '(a, i2)') '0' , p  ! e.g. d2 = "015"
        if(p .ge. 100 .and. p .le. 999) write(d2, '(i3)'   ) p        ! end of current 5-day period
 
        qfname = 'DATA/' // yr // d1 // '-' // yr // d2 // '.m0451pfrt-qual.hdf'  ! quality flag file
        dfname = 'DATA/' // yr // d1 // '-' // yr // d2 // '.s0451pfrt-sst.hdf'
 
        !--- read file with quality flags
        write(*, *) ''
        write(6, *) 'open file => ', qfname
        sd_id = sfstart(qfname, DFACC_RDONLY)  ! open read only
        write(6, *) 'sd_id=', sd_id
         
        file_info_status = sffinfo(sd_id, n_datasets, n_file_attributes)
        write(6, *) 'file_info_status=', file_info_status

         
        !--- read quality flag
        sds_id = sfselect(sd_id, 0)
        write(6, *) 'data set #0,  sds_id=', sds_id
 
        set_info_status = sfginfo(sds_id, sd_set_name, rank, dim_sizes, data_type, n_set_attributes)
        write(6, *) 'sd_set_name=', sd_set_name 
 
        start (1) = 0
        start (2) = 0
        stride(1) = 1
        stride(2) = 1
        edges (1) = dim_sizes(1)
        edges (2) = dim_sizes(2)

        sd_read_status = sfrdata(sds_id, start, stride, edges, qual)  ! character*1  qual (8192, 4096)
 
        do j = 1, 4096
            do i = 1, 8192
                value = ichar(qual(i, j))
                if(value .lt. 0) value = value + 256
                nqual(i, j) = value
            end do
        end do
  
        sd_read_status = sfendacc(sds_id)
        write(6, *) 'data set #0 is closed, status =', sd_read_status

 
        !--- read latitude
        sds_id = sfselect(sd_id, 1)
        write(6, *) 'data set #1,  sds_id=', sds_id
 
        set_info_status = sfginfo(sds_id, sd_set_name, rank, dim_sizes, data_type, n_set_attributes)
        write(6, *) 'sd_set_name=', sd_set_name 
 
        start (1) = 0
        start (2) = 0
        stride(1) = 1
        stride(2) = 1
        edges (1) = dim_sizes(1)
        edges (2) = dim_sizes(2)
 
        sd_read_status = sfrdata(sds_id, start, stride, edges, lat)  ! real*8 lat(4096), lon(8192)
 
        sd_read_status = sfendacc(sds_id)
        write(6, *) 'data set #1 is closed, status =', sd_read_status

 
        !--- read longitude
        sds_id = sfselect(sd_id, 2)
        write(6, *) 'data set #2,  sds_id=', sds_id
 
        set_info_status = sfginfo(sds_id, sd_set_name, rank, dim_sizes, data_type, n_set_attributes)
        write(6, *) 'sd_set_name=', sd_set_name 
 
        start (1) = 0
        start (2) = 0
        stride(1) = 1
        stride(2) = 1
        edges (1) = dim_sizes(1)
        edges (2) = dim_sizes(2)
 
        sd_read_status = sfrdata(sds_id, start, stride, edges, lon)
 
        sd_read_status = sfendacc(sds_id)  ! sds_id: var id
        write(6,*) 'data set #2 is closed, status =', sd_read_status
 
        sd_end_status = sfend(sd_id)  ! sd_id: file id
        write(6,*) 'file with quality flags is closed, status=', sd_end_status

 
        !--- read file with SST data
        write(6, *) 'open file => ', dfname
        sd_id = sfstart(dfname, DFACC_RDONLY)
        write(6, *) 'sd_id=', sd_id
         
        file_info_status = sffinfo(sd_id, n_datasets, n_file_attributes)
        write(6, *) 'file_info_status=', file_info_status
         
        !--- read SST data
        sds_id = sfselect(sd_id, 0)
        write(6, *) 'data set #0,  sds_id=', sds_id
 
        set_info_status = sfginfo(sds_id, sd_set_name, rank, dim_sizes, data_type, n_set_attributes)
        write(6, *) 'sd_set_name=', sd_set_name 
 
        start (1) = 0
        start (2) = 0
        stride(1) = 1
        stride(2) = 1
        edges (1) = dim_sizes(1)
        edges (2) = dim_sizes(2)
 
        sd_read_status = sfrdata(sds_id, start, stride, edges, nsst)  ! integer*2 nsst(8192, 4096)
 
        do j = 1, 4096
            j1 = floor(lat(j)) + 91
            do i = 1, 8192
                if(nsst(i, j) .gt. 0) then
                    if(nqual(i, j) .ge. 7) then
                        if(lon(i) .le. 0.0) then
                            i1 = floor(lon(i) + 360.)
                        else
                            i1 = floor(lon(i))
                        end if
                        ! i1 = floor(lon(i)) + 181
                        xsst(i1, j1) = xsst(i1, j1) + 0.075*nsst(i, j) - 3.0  ! lgchen: ?
                        ksst(i1, j1) = ksst(i1, j1) + 1  ! counter
                    end if
                end if
            end do
        end do
 
        sd_end_status = sfend(sd_id)
        write(6, *) 'file with SST data is closed, status=', sd_end_status

        ! write out final SST to the ascii file 
        do i = 1, 360
            do j = 1, 180
                if(ksst(i, j) .ne. 0) then
                  if(xsst(i, j)/ksst(i, j) .ge. -2.0 .and. xsst(i, j)/ksst(i, j) .le. 32.0) then
                      write(30, 111) ndat, xla(j), xlo(i), xsst(i, j)/ksst(i, j)
                  end if
                end if
            end do
        end do
 
        ndat = ndat + 5
    end do  ! of "do k = 1, 365, 5"
 
    close(30)
 
111 format(1x, i5, 1x, f5.1, 1x, f5.1, 2x, f5.2)
 
    stop
end program nsst2soda
