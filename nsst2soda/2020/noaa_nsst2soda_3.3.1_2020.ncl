load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 

; external LIBCLG "/glade/u/home/lgchen/lib/fortran/sst_2015/libclg.so"
external LIBCLG "/glade/u/home/lgchen/lib/fortran/libclg/libclg.so"


begin
    DIR_ROOT_NOAA_SST = "/glade/scratch/lgchen/data/SST_obs_forSODA"
    STR_FN_N20 = "00-OSPO-L3U_GHRSST-SSTsubskin-VIIRS_N20-ACSPO_V2.61-v02.0-fv01.0.nc"
    STR_FN_NPP = "00-OSPO-L3U_GHRSST-SSTsubskin-VIIRS_NPP-ACSPO_V2.61-v02.0-fv01.0.nc"

    lat_soda            = new((/180/)     , "float"  , 1e20)
    lon_soda            = new((/360/)     , "float"  , 1e20)

    sst_soda_5day_avg   = new((/180, 360/), "float"  , 1e20)
    n_sst_soda_5day_avg = new((/180, 360/), "integer", -999)

    sst_soda_1hr_avg    = new((/180, 360/), "float"  , 1e20)  ; should be 10min
    n_sst_soda_1hr_avg  = new((/180, 360/), "integer", -999)

    jul_day_20200103 = greg2jul(2020, 1 , 3 , -1)
    jul_day_20201231 = greg2jul(2020, 12, 31, -1)
    
    i_jul_day = jul_day_20200103

    do while (i_jul_day .le. jul_day_20201231)
        sst_soda_5day_avg   = 0.0
        n_sst_soda_5day_avg = 0

        do j_jul_day = i_jul_day - 2, i_jul_day + 2
            greg  = jul2greg(j_jul_day)
            i_yr  = greg(0)
            i_mon = greg(1)
            i_day = greg(2)

            str_curr_date = sprinti("%0.4i", i_yr) + sprinti("%0.2i", i_mon) + sprinti("%0.2i", i_day)
            print("current date: " + str_curr_date)

            ; N20 
            print("processing N20 files ...")
            do i_hr = 0, 23
                do i_min = 0, 5  ; every 10 minute
                    str_hr        = sprinti("%0.2i", i_hr)
                    str_min       = sprinti("%0.2i", i_min*10)
                    str_curr_time = str_curr_date + str_hr + str_min

                    fn_nc_sst_obs     = str_curr_time + STR_FN_N20
                    abs_fn_nc_sst_obs = DIR_ROOT_NOAA_SST + "/N20/2020/" + fn_nc_sst_obs
                    if (.not. isfilepresent(abs_fn_nc_sst_obs)) then
                        print("N20 file not present: " + fn_nc_sst_obs)
                        continue
                    end if

                    fl_nc_sst_obs = addfile(abs_fn_nc_sst_obs, "r")
                    dim_names     = getvardims(fl_nc_sst_obs)
                    dim_sizes     = getfiledimsizes(fl_nc_sst_obs)
                  ; ni            = dim_sizes(0)  ; 409 lon
                  ; nj            = dim_sizes(1)  ; 7200 lat
                  ; time          = dim_sizes(2)

                    time = dim_sizes(0)
                    lat  = dim_sizes(1)
                    lon  = dim_sizes(2)
                    if (time .ne. 1) then
                        print("ERROR: time .ne. 1, str_curr_time = " + str_curr_time)
                        exit()
                    end if
                    if (lat .ne. 9000) then
                        print("WARNING: lat .ne. 9000, str_curr_time = " + str_curr_time)
                    end if
                    if (lon .ne. 18000) then
                        print("WARNING: lon .ne. 18000, str_curr_time = " + str_curr_time)
                    end if

                    lat_noaa      = fl_nc_sst_obs->lat
                    lon_noaa      = fl_nc_sst_obs->lon
                    sst_noaa      = short2flt(fl_nc_sst_obs->sea_surface_temperature(0, :, :))
                    sses_bias     = byte2flt(fl_nc_sst_obs->sses_bias(0, :, :))
                    l2p_flags     = fl_nc_sst_obs->l2p_flags(0, :, :)      ; short
                    quality_level = fl_nc_sst_obs->quality_level(0, :, :)  ; byte

              ;     printVarSummary(sst_noaa     )
              ;     printVarSummary(sses_bias    )
              ;     printVarSummary(l2p_flags    )
              ;     printVarSummary(quality_level)

              ;     LIBCLG::sst_noaa2soda_1hr(ni, nj, time, lon_noaa, lat_noaa, sst_noaa, sses_bias, l2p_flags  \
              ;         , quality_level, sst_soda_1hr_avg, n_sst_soda_1hr_avg)

                    LIBCLG::sst_noaa2soda_10min(lon, lat, time, lon_noaa, lat_noaa, sst_noaa, sses_bias, l2p_flags  \
                        , quality_level, sst_soda_1hr_avg, n_sst_soda_1hr_avg)

                    sst_soda_5day_avg   = sst_soda_5day_avg   + sst_soda_1hr_avg
                    n_sst_soda_5day_avg = n_sst_soda_5day_avg + n_sst_soda_1hr_avg

                    delete(lat_noaa     )
                    delete(lon_noaa     )
                    delete(sst_noaa     )
                    delete(sses_bias    )
                    delete(l2p_flags    )
                    delete(quality_level)
                end do  ; end of "do i_min = 0, 5"
            end do  ; end of "do i_hr = 0, 23" 


            ; NPP file
            print("processing NOAA19 files ...")
            do i_hr = 0, 23
                do i_min = 0, 5  ; every 10-minute
                    str_hr        = sprinti("%0.2i", i_hr)
                    str_min       = sprinti("%0.2i", i_min*10)
                    str_curr_time = str_curr_date + str_hr + str_min

                    fn_nc_sst_obs     = str_curr_time + STR_FN_NPP
                    abs_fn_nc_sst_obs = DIR_ROOT_NOAA_SST + "/NPP/2020/" + fn_nc_sst_obs
                    if (.not. isfilepresent(abs_fn_nc_sst_obs)) then
                        print("NPP file not present: " + fn_nc_sst_obs)
                        continue
                    end if

                    fl_nc_sst_obs = addfile(abs_fn_nc_sst_obs, "r")
                    dim_names     = getvardims(fl_nc_sst_obs)
                    dim_sizes     = getfiledimsizes(fl_nc_sst_obs)
                  ; ni            = dim_sizes(0)  ; lon
                  ; nj            = dim_sizes(1)  ; lat
                  ; time          = dim_sizes(2)

                    time = dim_sizes(0)
                    lat  = dim_sizes(1)
                    lon  = dim_sizes(2)
                    if (time .ne. 1) then
                        print("ERROR: time .ne. 1, str_curr_time = " + str_curr_time)
                        exit()
                    end if
                    if (lat .ne. 9000) then
                        print("WARNING: lat .ne. 9000, str_curr_time = " + str_curr_time)
                    end if
                    if (lon .ne. 18000) then
                        print("WARNING: lon .ne. 18000, str_curr_time = " + str_curr_time)
                    end if

                    lat_noaa      = fl_nc_sst_obs->lat
                    lon_noaa      = fl_nc_sst_obs->lon
                    sst_noaa      = short2flt(fl_nc_sst_obs->sea_surface_temperature(0, :, :))
                    sses_bias     = byte2flt(fl_nc_sst_obs->sses_bias(0, :, :))
                    l2p_flags     = fl_nc_sst_obs->l2p_flags(0, :, :)      ; short
                    quality_level = fl_nc_sst_obs->quality_level(0, :, :)  ; byte

                  ; printVarSummary(sst_noaa     )
                  ; printVarSummary(sses_bias    )
                  ; printVarSummary(l2p_flags    )
                  ; printVarSummary(quality_level)

                  ; LIBCLG::sst_noaa2soda_1hr(ni, nj, time, lon_noaa, lat_noaa, sst_noaa, sses_bias, l2p_flags  \
                  ;     , quality_level, sst_soda_1hr_avg, n_sst_soda_1hr_avg)

                    LIBCLG::sst_noaa2soda_10min(lon, lat, time, lon_noaa, lat_noaa, sst_noaa, sses_bias, l2p_flags  \
                        , quality_level, sst_soda_1hr_avg, n_sst_soda_1hr_avg)

                    sst_soda_5day_avg   = sst_soda_5day_avg   + sst_soda_1hr_avg
                    n_sst_soda_5day_avg = n_sst_soda_5day_avg + n_sst_soda_1hr_avg

                    delete(lat_noaa     )
                    delete(lon_noaa     )
                    delete(sst_noaa     )
                    delete(sses_bias    )
                    delete(l2p_flags    )
                    delete(quality_level)
                end do  ; end of "do i_min = 0, 5"
            end do  ; end of "do i_hr = 0, 23" 
        end do  ; end of "do j_jul_day = i_jul_day - 2, i_jul_day + 2"


        print("get 5day avg to output ...")
        n_sst_soda_5day_avg = where(1 .le. n_sst_soda_5day_avg, n_sst_soda_5day_avg, n_sst_soda_5day_avg@_FillValue)
        sst_soda_5day_avg = where(1 .le. n_sst_soda_5day_avg, sst_soda_5day_avg/(1.0*n_sst_soda_5day_avg), 0.0)

        print("before subroutine LIBCLG::write_sst_noaa2soda_5day_avg ...")
        LIBCLG::write_sst_noaa2soda_5day_avg(i_jul_day-2440000, sst_soda_5day_avg)

        i_jul_day = i_jul_day + 5
    end do  ; end of "do while (i_jul_day .lt. jul_day_20141231)"
end
