program date
    ! jdate = jday(1, 31, 1985)      
    ! print *, jdate
    ! idate = jday(12, 1, 1984)      
    ! jdate = jday(1, 31, 1990)      
    ! print *, idate, jdate
    ! idate = jday(12, 1, 1989)
    ! jdate = jday(1, 31, 1995)
    ! print *, idate, jdate
    ! idate = jday(12, 1, 1994)      
    ! jdate = jday(1, 31, 2000)      
    ! print *, idate, jdate
    ! idate = jday(12, 1, 1999)
    ! jdate = jday(1, 31, 2005)
    ! print *, idate, jdate
 
    idate = jday(1, 1, 2009)
    print *, idate
 
    stop
end

 
function jday(mon, iday, iyr)
 
!=======================================================================
!
!     compute the julian day corresponding to the
!     day on the gregorian calender
!
!=======================================================================
 
    dimension dpm(12)
    data dpm /31.0, 28.0, 31.0, 30.0, 31.0, 30.0, 31.0, 31.0, 30.0, 31.0, 30.0, 31.0/

    dpm(2) = 28.0
    if(mod(real(iyr), 4.) .eq. 0.) dpm(2) = 29.0
 
    ! first calculate days without leap years
 
    !cao??11/8/95  for 1950 XXX
    !cao    iyrs = iyr-1950
    !cao    days = 3282.0+real(iyrs)*365.0
     
    iyrs = iyr - 1970
    days = 587.0 + real(iyrs)*365.0
    !cao?? need to think about iyrs+?? e.x.: iyr-1950, should iyrs+1
    !caojday num_leap = int(real(iyrs+1)/4.)
    num_leap = floor(real(iyrs+1)/4.)
    days     = days + real(num_leap)
 
    ! now sum up for days this year
    sum = 0.
    if(mon .gt. 1)then
        do l = 1, mon-1
            sum = sum + dpm(l)
        end do
        days = days + sum
    end if
 
    jday = int(days) + iday

    !assim
    return
end
