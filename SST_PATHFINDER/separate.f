
      open(30, file='nst_wknsat_8104.dat', status='old', readonly)
c
c 11/81-1/85
c     open(31, file='nst_wknsat_8185.dat', status='unknown')
c     open(32, file='nst_wknsat_8490.dat', status='unknown')
      open(33, file='nst_wknsat_8995.dat', status='unknown')
      open(34, file='nst_wknsat_9400.dat', status='unknown')
c 12/99-12/04
      open(35, file='nst_wknsat_9904.dat', status='unknown')
c
      do l=1,999999999
        read(30,111,end=123) nd, xla, xlo, sst
c
c       if(nd.le.6097) write(31,111) nd, xla, xlo, sst
c
c       if(nd.ge.6036.and.nd.le.7923) write(32,111) nd, xla, xlo, sst

        if(nd.ge.7862.and.nd.le.9749) write(33,111) nd, xla, xlo, sst

        if(nd.ge.9688.and.nd.le.11575) write(34,111) nd, xla, xlo, sst

        if(nd.ge.11514) write(35,111) nd, xla, xlo, sst

      enddo
123   continue
c
111   format(1x,i5,1x,f5.1,1x,f5.1,2x,f5.2)
c
      stop
      end
