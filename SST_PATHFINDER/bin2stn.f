      program bin2stn

C This program takes SST binned *.dat files
C and writes its in a GRADS station data file.

     
      character*8 STATION_ID
      real :: rlat, rlon, sst, tim
      integer :: year, iyear, month, day , nlev, iyrold, imnold
      integer :: nflag, iflag, id, nn
      integer :: forever, ms
      integer, dimension(12) ::  ids, idd
c      
      parameter(forever = 9999999)
c
c***********************************************************************
c
      iyrs = 2005
      iyrf = 2005
c
      nn = 0
      id = 0
      tim = 0.0
      nflag = 1
      iflag = 0
c
      open(10,file='/data/pacific3/chepurin/SST_PATHFINDER/GRADS/
c     &test.stn',
     &nst_corrected_2005.stn',
     &     form='unformatted',
     &     status='unknown',
     &     recordtype='stream')
c     
      open(20,file='/data/pacific3/chepurin/SST_PATHFINDER/BIN/
     &nst_corrected_2005.bin',
     &     form='formatted',
     $     status='old')
c     
      do iyear = iyrs, iyrf
c
        do m=1,12
          ms=31
          if(m.eq.4.or.m.eq.6.or.m.eq.9.or.m.eq.11) ms=30
          if(m.eq.2) ms=28
          if(m.eq.2 .and. mod(real(iyear),4.) .eq. 0.)ms=29
          ids(m)=jday(m,1,iyear)
          idd(m)=jday(m,ms,iyear)
          print *, ids(m), idd(m)
        enddo
c     
        do 10 I = 1, forever
          read(20,111,end=30) idat, rlat, rlon, sst
111   format(1x,i5,1x,f5.1,1x,f5.1,2x,f5.2)
c
        if(idat.gt.idd(12)) go to 30
	if(idat.lt.ids(1))  go to 10
C                                                                       
        do m=1,12
          if(idat.ge.ids(m).and.idat.le.idd(m).and.sst.gt.-5.0) then
	    year = iyear
	    month = m
            go to 123
          endif
        enddo
c
 123    continue
c
        if (iflag.eq.0) then
	  iflag = 1
          iyrold = year
	  imnold = month
	endif
c
        id = id +1
        write(station_id,('(i7)')) id
c
c Write this station report
c
        nn = 0
        if (iyrold.ne.year.or.imnold.ne.month) then
          nlev = 0
	  if (iyrold.eq.year) then
            nn = month-imnold
	  else
	    nn = (year-iyrold-1)*12+(12-imnold)+month
	  endif
	  do imn=1,nn
            write(10) station_id,rlat,rlon,tim,nlev,nflag
          enddo
c
          print *, year, iyrold, month, imnold, nn
	endif
c
        nlev = 1
        iyrold = year
	imnold = month
c
        write(10) station_id,rlat,rlon,tim,nlev,nflag
        write(10) sst
c	write(6,*) station_id,year,month,rlat,rlon
c
10    continue
30    continue
c
      enddo
c
c Write the final time group terminator
c
      nlev = 0
      write(10) station_id,rlat,rlon,rts,nlev,nflag
c
      print *, id
c
      stop
      end
c
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
      
