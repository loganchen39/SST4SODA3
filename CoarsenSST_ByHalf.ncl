load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"


begin
  ; DIR_OBS_ORG = "/glade2/h2/umcp0009/OBS4SODA/SST"
    DIR_OBS_ORG = "/glade2/h2/umcp0009/OBS4SODA"
    DIR_OBS_CUT = "/glade2/h2/umcp0009/OBS4SODA/SST_CutByHalf"

  ; START_YEAR = 1970
    START_YEAR = 2016
    END_YEAR   = 2016

;   STR_YR_NST_CORRECTED = (/"8185", "8490", "8995", "9400", "9904"/)
    START_YR_IGNTV = 2016
    END_YR_IGNTV   = 2016

;   STR_YR_SST_NCAR = (/"4955", "5460", "5965", "6470", "6975", "7480", "7985", "8490", "8995", "9400"/)
;   STR_YR_SST_NCEP = (/"0505", "0606", "0707", "0808", "9905"/)

;   ; first nst_corrected
;   print("Coarsening nst_corrected ...")
;   do i_yr = 0, dimsizes(STR_YR_NST_CORRECTED) - 1
;       print("i_yr = " + i_yr)

;       fn_nst = "nst_corrected_" + STR_YR_NST_CORRECTED(i_yr) + ".bin"

;       str_nst = asciiread(DIR_OBS_ORG + "/" + fn_nst, -1, "string")
;       n_line = dimsizes(str_nst)
;       str_nst_cut = str_nst(0:n_line-1:2)
;       n_line_cut = dimsizes(str_nst_cut)

;     ; print("n_line = " + n_line)
;     ; print("n_line_cut = " + n_line_cut)

;       fn_nst_cut = "nst_corrected_" + STR_YR_NST_CORRECTED(i_yr) + "_cut.bin"
;       asciiwrite(DIR_OBS_CUT + "/" + fn_nst_cut, str_nst_cut)

;       delete(str_nst)
;       delete(str_nst_cut)
;   end do


    ; second nst_igntv  
    print("Coarsening nst_igntv ...")
    do i_yr = START_YR_IGNTV, END_YR_IGNTV
        str_yr = sprinti("%0.4i", i_yr)
        print("i_yr = " + str_yr)

        fn_nst_igntv = "nst_igntv_" + str_yr + ".bin"

        str_nst_igntv = asciiread(DIR_OBS_ORG + "/" + fn_nst_igntv, -1, "string")
        n_line = dimsizes(str_nst_igntv)
        str_nst_igntv_cut = str_nst_igntv(0:n_line-1:2)
        n_line_cut = dimsizes(str_nst_igntv_cut)

        fn_nst_igntv_cut = "nst_igntv_" + str_yr + "_cut.bin"
        asciiwrite(DIR_OBS_CUT + "/" + fn_nst_igntv_cut, str_nst_igntv_cut)

        delete(str_nst_igntv)
        delete(str_nst_igntv_cut)
    end do


;   ; third sst.ncar
;   print("Coarsening sst.ncar ...")
;   do i_yr = 0, dimsizes(STR_YR_SST_NCAR) - 1
;       print("i_yr = " + i_yr)

;       if (i_yr .eq. 9) then
;           fn_sst = "sst.ncar-ncep_" + STR_YR_SST_NCAR(i_yr) + ".bin"
;       else
;           fn_sst = "sst.ncar_" + STR_YR_SST_NCAR(i_yr) + ".bin"
;       end if

;       str_sst = asciiread(DIR_OBS_ORG + "/" + fn_sst, -1, "string")
;       n_line = dimsizes(str_sst)
;       str_sst_cut = str_sst(0:n_line-1:2)
;       n_line_cut = dimsizes(str_sst_cut)

;       fn_sst_cut = "sst.ncar_" + STR_YR_SST_NCAR(i_yr) + "_cut.bin"
;       asciiwrite(DIR_OBS_CUT + "/" + fn_sst_cut, str_sst_cut)

;       delete(str_sst)
;       delete(str_sst_cut)
;   end do


;   ; fourth sst.ncep
;   print("Coarsening sst.ncep ...")
;   do i_yr = 0, dimsizes(STR_YR_SST_NCEP) - 1
;       print("i_yr = " + i_yr)

;       fn_sst = "sst.ncep_" + STR_YR_SST_NCEP(i_yr) + ".bin"

;       str_sst = asciiread(DIR_OBS_ORG + "/" + fn_sst, -1, "string")
;       n_line = dimsizes(str_sst)
;       str_sst_cut = str_sst(0:n_line-1:2)
;       n_line_cut = dimsizes(str_sst_cut)

;       fn_sst_cut = "sst.ncep_" + STR_YR_SST_NCEP(i_yr) + "_cut.bin"
;       asciiwrite(DIR_OBS_CUT + "/" + fn_sst_cut, str_sst_cut)

;       delete(str_sst)
;       delete(str_sst_cut)
;   end do

end
