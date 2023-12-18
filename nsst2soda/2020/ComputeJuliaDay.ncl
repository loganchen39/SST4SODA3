load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 

external LIBCLG "/glade/u/home/lgchen/lib/fortran/libclg/libclg01/libclg.so"


begin
    jul_day_20200103 = greg2jul(2020, 1 , 3 , -1)
    jul_day_20200128 = greg2jul(2020, 1 , 28, -1)
 
    jul_day_20200202 = greg2jul(2020, 2 , 2 , -1)
    jul_day_20200227 = greg2jul(2020, 2 , 27, -1)   

    jul_day_20200303 = greg2jul(2020, 3 , 3 , -1)
    jul_day_20200328 = greg2jul(2020, 3 , 28, -1)

    jul_day_20200402 = greg2jul(2020, 4 , 2 , -1)
    jul_day_20200427 = greg2jul(2020, 4 , 27, -1)

    jul_day_20200502 = greg2jul(2020, 5 , 2 , -1)
    jul_day_20200527 = greg2jul(2020, 5 , 27, -1)

    jul_day_20200601 = greg2jul(2020, 6 , 1 , -1)
    jul_day_20200626 = greg2jul(2020, 6 , 26, -1)

    jul_day_20200701 = greg2jul(2020, 7 , 1 , -1)
    jul_day_20200731 = greg2jul(2020, 7 , 31, -1)

    jul_day_20200805 = greg2jul(2020, 8 , 5 , -1)
    jul_day_20200830 = greg2jul(2020, 8 , 30, -1)

    jul_day_20200904 = greg2jul(2020, 9 , 4 , -1)
    jul_day_20200929 = greg2jul(2020, 9 , 29, -1)

    jul_day_20201004 = greg2jul(2020, 10, 4 , -1)
    jul_day_20201029 = greg2jul(2020, 10, 29, -1)

    jul_day_20201103 = greg2jul(2020, 11, 3 , -1)
    jul_day_20201128 = greg2jul(2020, 11, 28, -1)

    jul_day_20201203 = greg2jul(2020, 12, 3 , -1)
    jul_day_20201228 = greg2jul(2020, 12, 28, -1)

    i_jul_day = jul_day_20201203

    do while (i_jul_day .le. jul_day_20201228)
        greg  = jul2greg(i_jul_day)
        i_yr  = greg(0)
        i_mon = greg(1)
        i_day = greg(2)

        str_curr_date = sprinti("%0.4i", i_yr) + sprinti("%0.2i", i_mon) + sprinti("%0.2i", i_day)
        print("current date: " + str_curr_date + ", current julia day: " + sprinti("%0.9i", i_jul_day-2440000) )

        i_jul_day = i_jul_day + 5
    end do  ; end of "do while (i_jul_day .lt. jul_day_20141231)"
end
