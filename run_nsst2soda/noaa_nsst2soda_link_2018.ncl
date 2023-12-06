load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 


begin
    DIR_ROOT_NOAA_SST = "/gpfs/fs1/p/univ/umcp0009/lgchen/data/NOAA_SST_ForSODA_3.3.1"
    STR_FN_METOPA     = "0000-STAR-L2P_GHRSST-SSTskin-AVHRRMTA_G-ACSPO_V2.40-v02.0-fv01.0.nc"
    STR_FN_METOPA_OSPO= "0000-OSPO-L2P_GHRSST-SSTsubskin-AVHRRMTA_G-ACSPO_V2.41-v02.0-fv01.0.nc"
    STR_FN_NOAA19     = "0000-STAR-L2P_GHRSST-SSTskin-AVHRR19_G-ACSPO_V2.40-v02.0-fv01.0.nc"
    STR_FN_NOAA19_OSPO= "0000-OSPO-L2P_GHRSST-SSTsubskin-AVHRR19_G-ACSPO_V2.41-v02.0-fv01.0.nc"

    jul_day_20181111 = greg2jul(2018, 11, 11, -1)
    jul_day_20181231 = greg2jul(2018, 12, 31, -1)
    
    i_jul_day = jul_day_20181111

    do while (i_jul_day .lt. jul_day_20181231)
        greg  = jul2greg(i_jul_day)
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
            abs_fn_nc_sst_obs = DIR_ROOT_NOAA_SST + "/METOPA_done/2018/" + fn_nc_sst_obs

            fn_nc_sst_obs_ospo = str_curr_date + str_hr + STR_FN_METOPA_OSPO
            abs_fn_nc_sst_obs_ospo = DIR_ROOT_NOAA_SST + "/OSPO/METOPA/" + fn_nc_sst_obs_ospo

            str_cmd = "ln -sf " + abs_fn_nc_sst_obs_ospo + " " + abs_fn_nc_sst_obs
            system(str_cmd)
        end do  ; end of "do i_hr = 0, 23" 


        ; NOAA19 file
        print("processing NOAA19 files ...")
        do i_hr = 0, 23
            str_hr        = sprinti("%0.2i", i_hr)
            str_curr_time = str_curr_date + str_hr

            fn_nc_sst_obs     = str_curr_date + str_hr + STR_FN_NOAA19
            abs_fn_nc_sst_obs = DIR_ROOT_NOAA_SST + "/NOAA19_done/2018/" + fn_nc_sst_obs

            fn_nc_sst_obs_ospo = str_curr_date + str_hr + STR_FN_NOAA19_OSPO
            abs_fn_nc_sst_obs_ospo = DIR_ROOT_NOAA_SST + "/OSPO/NOAA19/" + fn_nc_sst_obs_ospo

            str_cmd = "ln -sf " + abs_fn_nc_sst_obs_ospo + " " + abs_fn_nc_sst_obs
            system(str_cmd)
        end do  ; end of "do i_hr = 0, 23" 

        i_jul_day = i_jul_day + 1
    end do  ; end of "do while (i_jul_day .lt. jul_day_20141231)"

end
