      program date

c      jdate=jday(1,31,1985)      
c      print *, jdate
c      idate=jday(12,1,1984)      
c      jdate=jday(1,31,1990)      
c      print *, idate, jdate
c      idate=jday(12,1,1989)
c      jdate=jday(1,31,1995)
c      print *, idate, jdate
c      idate=jday(12,1,1994)      
c      jdate=jday(1,31,2000)      
c      print *, idate, jdate
c      idate=jday(12,1,1999)
c      jdate=jday(1,31,2005)
c      print *, idate, jdate
c
       idate = jday(1,1,1982)
       print *, idate

c
      stop
      end
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
