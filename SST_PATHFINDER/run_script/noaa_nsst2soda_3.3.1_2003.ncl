load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 

external LIBCLG "/glade/u/home/lgchen/lib/fortran/sst_2003/libclg.so"


begin
    DIR_ROOT_NOAA_SST = "/glade/p/umcp0006/lgchen/data/NOAA_SST_ForSODA_3.3.1"
    STR_FN_METOPA     = "0000-STAR-L2P_GHRSST-SSTskin-AVHRRMTA_G-ACSPO_V2.40-v02.0-fv01.0.nc"
    STR_FN_METOPB     = "0000-STAR-L2P_GHRSST-SSTskin-AVHRRMTB_G-ACSPO_V2.40-v02.0-fv01.0.nc"
    STR_FN_NOAA16     = "0000-STAR-L2P_GHRSST-SSTskin-AVHRR16_G-ACSPO_V2.40-v02.0-fv01.0.nc"
    STR_FN_NOAA17     = "0000-STAR-L2P_GHRSST-SSTskin-AVHRR17_G-ACSPO_V2.40-v02.0-fv01.0.nc"
    STR_FN_NOAA18     = "0000-STAR-L2P_GHRSST-SSTskin-AVHRR18_G-ACSPO_V2.40-v02.0-fv01.0.nc"
    STR_FN_NOAA19     = "0000-STAR-L2P_GHRSST-SSTskin-AVHRR19_G-ACSPO_V2.40-v02.0-fv01.0.nc"


    lon_soda            = new((/360/)     , "float"  , 1e20)
    lat_soda            = new((/180/)     , "float"  , 1e20)

    sst_soda_5day_avg   = new((/180, 360/), "float"  , 1e20)
    n_sst_soda_5day_avg = new((/180, 360/), "integer", -999)

    sst_soda_1hr_avg    = new((/180, 360/), "float"  , 1e20)
    n_sst_soda_1hr_avg  = new((/180, 360/), "integer", -999)


    jul_day_20030103 = greg2jul(2003, 1 , 3 , -1)
    jul_day_20031231 = greg2jul(2003, 12, 31, -1)
  ; jul_day_20150730 = greg2jul(2015, 7 , 30, -1)
    
    i_jul_day = jul_day_20030103

    do while (i_jul_day .lt. jul_day_20031231)
        sst_soda_5day_avg   = 0.0
        n_sst_soda_5day_avg = 0

        do j_jul_day = i_jul_day - 2, i_jul_day + 2
            greg  = jul2greg(j_jul_day)
            i_yr  = greg(0)
            i_mon = greg(1)
            i_day = greg(2)

            str_curr_date = sprinti("%0.4i", i_yr) + sprinti("%0.2i", i_mon) + sprinti("%0.2i", i_day)
            print("current date: " + str_curr_date)

            ; METOPA file
            print("processing METOPA files ...")
            do i_hr = 0, 23
                str_hr        = sprinti("%0.2i", i_hr)
                str_curr_time = str_curr_date + str_hr

                fn_nc_sst_obs     = str_curr_date + str_hr + STR_FN_METOPA
                abs_fn_nc_sst_obs = DIR_ROOT_NOAA_SST + "/METOPA_done/downloaded/" + fn_nc_sst_obs
                if (.not. isfilepresent(abs_fn_nc_sst_obs)) then
                    print("METOPA file not present: " + fn_nc_sst_obs)
                    continue
                end if

                fl_nc_sst_obs = addfile(abs_fn_nc_sst_obs, "r")
                dim_names     = getvardims(fl_nc_sst_obs)
                dim_sizes     = getfiledimsizes(fl_nc_sst_obs)
                ni            = dim_sizes(0)
                nj            = dim_sizes(1)
                time          = dim_sizes(2)
                if (time .ne. 1) then
                    print("ERROR: time .ne. 1, str_curr_time = " + str_curr_time)
                    exit()
                end if
                if (nj .ne. 7200) then
                    print("WARNING: nj .ne. 7200, str_curr_time = " + str_curr_time)
                end if
                if (ni .ne. 409) then
                    print("WARNING: ni .ne. 409, str_curr_time = " + str_curr_time)
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

                LIBCLG::sst_noaa2soda_1hr(ni, nj, time, lon_noaa, lat_noaa, sst_noaa, sses_bias, l2p_flags  \
                    , quality_level, sst_soda_1hr_avg, n_sst_soda_1hr_avg)

                sst_soda_5day_avg   = sst_soda_5day_avg   + sst_soda_1hr_avg
                n_sst_soda_5day_avg = n_sst_soda_5day_avg + n_sst_soda_1hr_avg

                delete(lat_noaa     )
                delete(lon_noaa     )
                delete(sst_noaa     )
                delete(sses_bias    )
                delete(l2p_flags    )
                delete(quality_level)
            end do  ; end of "do i_hr = 0, 23" 


            ; NOAA16 file
            print("processing NOAA16 files ...")
            do i_hr = 0, 23
                str_hr        = sprinti("%0.2i", i_hr)
                str_curr_time = str_curr_date + str_hr

                fn_nc_sst_obs     = str_curr_date + str_hr + STR_FN_NOAA16
                abs_fn_nc_sst_obs = DIR_ROOT_NOAA_SST + "/NOAA16_done/downloaded/" + fn_nc_sst_obs
                if (.not. isfilepresent(abs_fn_nc_sst_obs)) then
                    print("NOAA16 file not present: " + fn_nc_sst_obs)
                    continue
                end if

                fl_nc_sst_obs = addfile(abs_fn_nc_sst_obs, "r")
                dim_names     = getvardims(fl_nc_sst_obs)
                dim_sizes     = getfiledimsizes(fl_nc_sst_obs)
                ni            = dim_sizes(0)
                nj            = dim_sizes(1)
                time          = dim_sizes(2)
                if (time .ne. 1) then
                    print("ERROR: time .ne. 1, str_curr_time = " + str_curr_time)
                    exit()
                end if
                if (nj .ne. 7200) then
                    print("WARNING: nj .ne. 7200, str_curr_time = " + str_curr_time)
                end if
                if (ni .ne. 409) then
                    print("WARNING: ni .ne. 409, str_curr_time = " + str_curr_time)
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

                LIBCLG::sst_noaa2soda_1hr(ni, nj, time, lon_noaa, lat_noaa, sst_noaa, sses_bias, l2p_flags  \
                    , quality_level, sst_soda_1hr_avg, n_sst_soda_1hr_avg)

                sst_soda_5day_avg   = sst_soda_5day_avg   + sst_soda_1hr_avg
                n_sst_soda_5day_avg = n_sst_soda_5day_avg + n_sst_soda_1hr_avg

                delete(lat_noaa     )
                delete(lon_noaa     )
                delete(sst_noaa     )
                delete(sses_bias    )
                delete(l2p_flags    )
                delete(quality_level)
            end do  ; end of "do i_hr = 0, 23" 


            ; NOAA17 file
            print("processing NOAA17 files ...")
            do i_hr = 0, 23
                str_hr        = sprinti("%0.2i", i_hr)
                str_curr_time = str_curr_date + str_hr

                fn_nc_sst_obs     = str_curr_date + str_hr + STR_FN_NOAA17
                abs_fn_nc_sst_obs = DIR_ROOT_NOAA_SST + "/NOAA17_done/downloaded/" + fn_nc_sst_obs
                if (.not. isfilepresent(abs_fn_nc_sst_obs)) then
                    print("METOPB file not present: " + fn_nc_sst_obs)
                    continue
                end if

                fl_nc_sst_obs = addfile(abs_fn_nc_sst_obs, "r")
                dim_names     = getvardims(fl_nc_sst_obs)
                dim_sizes     = getfiledimsizes(fl_nc_sst_obs)
                ni            = dim_sizes(0)
                nj            = dim_sizes(1)
                time          = dim_sizes(2)
                if (time .ne. 1) then
                    print("ERROR: time .ne. 1, str_curr_time = " + str_curr_time)
                    exit()
                end if
                if (nj .ne. 7200) then
                    print("WARNING: nj .ne. 7200, str_curr_time = " + str_curr_time)
                end if
                if (ni .ne. 409) then
                    print("WARNING: ni .ne. 409, str_curr_time = " + str_curr_time)
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

                LIBCLG::sst_noaa2soda_1hr(ni, nj, time, lon_noaa, lat_noaa, sst_noaa, sses_bias, l2p_flags  \
                    , quality_level, sst_soda_1hr_avg, n_sst_soda_1hr_avg)

                sst_soda_5day_avg   = sst_soda_5day_avg   + sst_soda_1hr_avg
                n_sst_soda_5day_avg = n_sst_soda_5day_avg + n_sst_soda_1hr_avg

                delete(lat_noaa     )
                delete(lon_noaa     )
                delete(sst_noaa     )
                delete(sses_bias    )
                delete(l2p_flags    )
                delete(quality_level)
            end do  ; end of "do i_hr = 0, 23" 


            ; NOAA18 file
            print("processing NOAA18 files ...")
            do i_hr = 0, 23
                str_hr        = sprinti("%0.2i", i_hr)
                str_curr_time = str_curr_date + str_hr

                fn_nc_sst_obs     = str_curr_date + str_hr + STR_FN_NOAA18
                abs_fn_nc_sst_obs = DIR_ROOT_NOAA_SST + "/NOAA18_done/downloaded/" + fn_nc_sst_obs
                if (.not. isfilepresent(abs_fn_nc_sst_obs)) then
                    print("NOAA18 file not present: " + fn_nc_sst_obs)
                    continue
                end if

                fl_nc_sst_obs = addfile(abs_fn_nc_sst_obs, "r")
                dim_names     = getvardims(fl_nc_sst_obs)
                dim_sizes     = getfiledimsizes(fl_nc_sst_obs)
                ni            = dim_sizes(0)
                nj            = dim_sizes(1)
                time          = dim_sizes(2)
                if (time .ne. 1) then
                    print("ERROR: time .ne. 1, str_curr_time = " + str_curr_time)
                    exit()
                end if
                if (nj .ne. 7200) then
                    print("WARNING: nj .ne. 7200, str_curr_time = " + str_curr_time)
                end if
                if (ni .ne. 409) then
                    print("WARNING: ni .ne. 409, str_curr_time = " + str_curr_time)
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

                LIBCLG::sst_noaa2soda_1hr(ni, nj, time, lon_noaa, lat_noaa, sst_noaa, sses_bias, l2p_flags  \
                    , quality_level, sst_soda_1hr_avg, n_sst_soda_1hr_avg)

                sst_soda_5day_avg   = sst_soda_5day_avg   + sst_soda_1hr_avg
                n_sst_soda_5day_avg = n_sst_soda_5day_avg + n_sst_soda_1hr_avg

                delete(lat_noaa     )
                delete(lon_noaa     )
                delete(sst_noaa     )
                delete(sses_bias    )
                delete(l2p_flags    )
                delete(quality_level)
            end do  ; end of "do i_hr = 0, 23" 

            ; NOAA19 file
            print("processing NOAA19 files ...")
            do i_hr = 0, 23
                str_hr        = sprinti("%0.2i", i_hr)
                str_curr_time = str_curr_date + str_hr

                fn_nc_sst_obs     = str_curr_date + str_hr + STR_FN_NOAA19
                abs_fn_nc_sst_obs = DIR_ROOT_NOAA_SST + "/NOAA19_done/downloaded/" + fn_nc_sst_obs
                if (.not. isfilepresent(abs_fn_nc_sst_obs)) then
                    print("NOAA19 file not present: " + fn_nc_sst_obs)
                    continue
                end if

                fl_nc_sst_obs = addfile(abs_fn_nc_sst_obs, "r")
                dim_names     = getvardims(fl_nc_sst_obs)
                dim_sizes     = getfiledimsizes(fl_nc_sst_obs)
                ni            = dim_sizes(0)
                nj            = dim_sizes(1)
                time          = dim_sizes(2)
                if (time .ne. 1) then
                    print("ERROR: time .ne. 1, str_curr_time = " + str_curr_time)
                    exit()
                end if
                if (nj .ne. 7200) then
                    print("WARNING: nj .ne. 7200, str_curr_time = " + str_curr_time)
                end if
                if (ni .ne. 409) then
                    print("WARNING: ni .ne. 409, str_curr_time = " + str_curr_time)
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

                LIBCLG::sst_noaa2soda_1hr(ni, nj, time, lon_noaa, lat_noaa, sst_noaa, sses_bias, l2p_flags  \
                    , quality_level, sst_soda_1hr_avg, n_sst_soda_1hr_avg)

                sst_soda_5day_avg   = sst_soda_5day_avg   + sst_soda_1hr_avg
                n_sst_soda_5day_avg = n_sst_soda_5day_avg + n_sst_soda_1hr_avg

                delete(lat_noaa     )
                delete(lon_noaa     )
                delete(sst_noaa     )
                delete(sses_bias    )
                delete(l2p_flags    )
                delete(quality_level)
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
