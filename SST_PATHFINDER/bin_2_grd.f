      PROGRAM  DATA_BIN                                                    
C                                                                       
c read in binned data to array and write our grads file
c
      PARAMETER (IMAX=360,JMAX=127)                              
      DIMENSION IBIN(IMAX,JMAX,12), TBIN(IMAX,JMAX,12) 
      DIMENSION tt(imax,jmax), ids(12), idd(12)
C
      OPEN(21, file='../data_bin/sst.ncep_9905.bin',
     *       FORM='FORMATTED', STATUS='old')
c
      open(22, file='sst_2000.dat',
     *       FORM='UNFORMATTED', access='direct', recl=imax*jmax,
     *        STATUS='unknown')
c
      do m=1,12
       ms=31
       if(m.eq.4.or.m.eq.6.or.m.eq.9.or.m.eq.11) ms=30
       if(m.eq.2) ms=28
      ma=jday(m,1,2000)
      md=jday(m,ms,2000)
      ids(m)=ma
      idd(m)=md
      print *, ids(m), idd(m)
      enddo
c
      do m=1,12
      do i=1,imax
      do j=1,jmax
        ibin(i,j,m)=0
        tbin(i,j,m)=0.0
      enddo
      enddo
      enddo
c
      do 100 l=1,99999999
c
        read(21,111) IDAT,XLA,XLO,T                        
c
        if(idat.gt.idd(12)) go to 234
C                                                                       
        do m=1,12
          if(idat.ge.ids(m).and.idat.le.idd(m).and.t.gt.-5.0) then
            ii=int(xlo)
            jj=int(xla+64.0)
            ibin(ii,jj,m)=ibin(ii,jj,m)+1
            tbin(ii,jj,m)=tbin(ii,jj,m)+t
            go to 123
          endif
        enddo
c
 123    continue
c
 100  CONTINUE                                                          
 234  continue
C
      do m=1,12
c
        do i=1,imax
        do j=1,jmax
          if(ibin(i,j,m).gt.1) tbin(i,j,m)=tbin(i,j,m)/ibin(i,j,m)
          tt(i,j)=tbin(i,j,m)
        enddo
        enddo
c
        write(22,rec=m) tt
      enddo
c
111   format(1x,i5,1x,f5.1,1x,f5.1,2x,f5.2)
c
      STOP                                                              
      END                                                               
c
      function jday(mon,iday,iyr)
c
c=======================================================================
c
c     compute the julian day corresponding to the
c     day on the gregorian calender
c
c=======================================================================
c
	dimension dpm(12)
	data dpm /31.0, 28.0, 31.0, 30.0, 31.0, 30.0, 31.0, 31.0, 30.0,
     $          31.0, 30.0, 31.0/

        dpm(2) = 28.0
        if(mod(real(iyr),4.) .eq. 0.)dpm(2) = 29.0
c
c first calculate days without leap years
c
ccao??11/8/95  for 1950 XXX
ccao    iyrs = iyr-1950
ccao    days = 3282.0+real(iyrs)*365.0
c
        iyrs = iyr-1970
        days = 587.0+real(iyrs)*365.0
ccao?? need to think about iyrs+?? e.x.: iyr-1950, should iyrs+1
ccaojday num_leap = int(real(iyrs+1)/4.)
        num_leap = floor(real(iyrs+1)/4.)
        days = days + real(num_leap)
c
c now sum up for days this year
c
        sum = 0.
        if(mon .gt. 1)then
        do l = 1, mon-1
        sum = sum + dpm(l)
        end do
        days = days + sum
        end if
c
	jday = int(days) + iday
cassim
      return
      end
