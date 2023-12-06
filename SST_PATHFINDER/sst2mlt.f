      program sst2mlt
      
      parameter (nx=180,ny=90)
      
      integer :: ndat, nla, nlo, nyr
      real :: xla, xlo, sst, sstc, cor, pi, om, day
      real, dimension(nx,ny) :: a0,a1,a2,b1,b2
c
      pi = 4.*atan(1.0)
      om = 2.*pi/365.
c      
c*** read correction's harmonics coeficients 
c
      open(10, file=
     &    '/data/arctic1/chepurin/SST_PATHFINDER/MIX_T_DIF/harm.grd',
     &    form='unformatted',
     &    access='direct',
     &    status='old',
     &    recl=nx*ny)         
c
      read(10,rec=1) a0
      read(10,rec=2) a1
      read(10,rec=4) a2
      read(10,rec=3) b1
      read(10,rec=5) b2
      close(10)
c
c*** read uncorrected satellite SST, corrects it and write into new file
c
      open(20, file=
     &    'BIN/nst_sst_2008.bin',
     &    form='formatted',
     &    status='old')
c
      open(30, file=
     &    'BIN/nst_corrected_2008.bi',
     &    form='formatted',
     &    status='unknown')
c
      do i=1,100000000
c
c*** read uncorrected data
c
        read(20,111,end=999) ndat, xla, xlo, sst
	
	nla = floor((xla+90)/2)+1
	nlo = floor(xlo)
	if (a0(nlo,nla).lt.-5.0) then  
	  a0(nlo,nla) = 0.0
	  a1(nlo,nla) = 0.0
	  a2(nlo,nla) = 0.0
	  b1(nlo,nla) = 0.0
	  b2(nlo,nla) = 0.0
	endif
c	nd = jday(2,1,1999)
	n_leap=(real(ndat-587)/(365.*4.))
	nshift=587+n_leap
        nyr = (ndat-nshift)/365
	day = real(ndat-nshift-365*nyr)
	sstc = sst + a0(nlo,nla)+
     &               a1(nlo,nla)*cos(om*day)+
     &               b1(nlo,nla)*sin(om*day)+
     &               a2(nlo,nla)*cos(2.*om*day)+
     &               b2(nlo,nla)*sin(2.*om*day)
c        write(*,*) i, ndat, xla, xlo, sst, sstc
         write(30,111) ndat, xla, xlo, sstc
	
      end do	
c
c*** close all files
c	
999   close(20)
      close(30)	     
c
111   format(1x,i5,1x,f5.1,1x,f5.1,2x,f5.2)
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
      
