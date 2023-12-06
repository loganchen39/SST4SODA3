      program wksatr  
c
      dimension sst(360,180), xla(180), xlo(360)
c
      undef = -9999.0
c
c -- 11/8/1981 - 12/31/1989, total 426 weeks, centered on Sunday
c
      open(11, file='weekly-1d80.nsat',
     &        form='unformatted', convert='big_endian',
     &        status='old', readonly)
c
c -- 1/3/1990 - 12/29/2004, total 783 weeks, centered on Wednesday
c
      open(12, file='weekly-1deg.nsat',
     &        form='unformatted', convert='big_endian',
     &        status='old', readonly)
c
c -- SODA format, 11/15/1981 - 12/29/2004
c
      open(30, file='nst_wknsat_8104.dat', 
     &         status='unknown')
c
      do l=1,180
        xla(l)=-89.5+(l-1)*1.0
      enddo
c
      do i=1,360
        xlo(i)=float(i)
      enddo
c
      do 100 iu=11,12
        ict = 0
   10   read (iu,end=123) iyrmid,imomid,idamid,sst
c
        in=0
        ndat = jday(imomid,idamid,iyrmid)
c
        do 200 i=1,360
        do 200 j=1,180
c
          if(sst(i,j).ge.-2.0.and.sst(i,j).le.32.0) then
            in=in+1
            write(30, 111) ndat, xla(j), xlo(i), sst(i,j)
          endif
c
 200    continue
        print *, 'week', iyrmid,imomid,idamid,ndat,in,sst(200,90)
c
        ict = ict + 1
        go to 10
c
  123 print *, 'total weeks ', ict
  100 continue
c
111   format(1x,i5,1x,f5.1,1x,f5.1,2x,f5.2)
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
