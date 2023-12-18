load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"


begin
    DATA_DIR = "/glade/p/work/lgchen/data/SODA/OBS4SODA/SST/SST_PATHFINDER/BIN/NOAA_SST_for_SODA_3.3.1"


    N_REG      = 3  ; (46, 300), (46, 139), (5, 110)
    START_YEAR = 2003
    END_YEAR   = 2015
    N_YEAR     = END_YEAR - START_YEAR + 1
    N_DAY      = 75  ; 365/5 = 73
    N_MONTH    = 12

    REG_NAME = (/"45N-47N, 58W-62W", "45N-47N, 138E-140E", "4N-6N, 105E-115E"/)

    nst_ts = new((/N_REG, N_YEAR, N_DAY/), "float", 1e20)
    nst_ts = 0.0

    nst_record = new((/N_REG, N_YEAR/), "integer")
    nst_record = 0

    nst_avg_tmp = new((/N_REG/), "float")
    nst_avg_tmp = 0.0

    nst_rec_tmp = new((/N_REG/), "integer")
    nst_rec_tmp = 0

    N_COL   = 4
    N_FL_LN = (/2796975, 2793880, 2813922, 2825543, 2825404, 2813060, 2817117, 2825644, 2839878, 2847977  \
            ,   2846663, 2814300, 2861532/)
    START_JDAY = (/12643, 13008, 13374, 13739, 14104, 14469, 14835, 15200, 15565, 15930, 16296, 16661, 17026/)

;   do i_yr = 2003, 2015
;       str_year = sprinti("%0.4i", i_yr)
;       print("processing year " + str_year)

;       fn = "nst_sst_" + str_year + ".bin"
;       nst = asciiread(DATA_DIR + "/" + fn, (/N_FL_LN(i_yr-START_YEAR), N_COL/), "float")

;       i_curr_jday = START_JDAY(i_yr-START_YEAR)
;       do i_ln = 0, N_FL_LN(i_yr-START_YEAR) - 1
;           if (floattoint(nst(i_ln, 0)) .ne. i_curr_jday) then
;             ; print("nst(i_ln, 0) .ne. i_curr_jday")

;               do i_reg = 0, N_REG - 1
;                   if (nst_rec_tmp(i_reg) .gt. 0) then
;                       nst_ts(i_reg, i_yr-START_YEAR, nst_record(i_reg, i_yr-START_YEAR)) = nst_avg_tmp(i_reg) / nst_rec_tmp(i_reg)
;                   end if
;               end do

;               nst_avg_tmp = 0.0
;               nst_rec_tmp = 0
;               nst_record(:, i_yr-START_YEAR) = nst_record(:, i_yr-START_YEAR) + 1
;               i_curr_jday = floattoint(nst(i_ln, 0))
;           end if


;           if (45 .lt. nst(i_ln, 1) .and. nst(i_ln, 1) .lt. 47 .and. 298 .le. nst(i_ln, 2) .and. nst(i_ln, 2) .le. 302) then
;             ; print("Averaging region 1")

;               nst_rec_tmp(0) = nst_rec_tmp(0) + 1
;               nst_avg_tmp(0) = nst_avg_tmp(0) +  nst(i_ln, 3)
;           else if (45 .lt. nst(i_ln, 1) .and. nst(i_ln, 1) .lt. 47 .and. 138 .le. nst(i_ln, 2) .and. nst(i_ln, 2) .le. 140) then
;             ; print("Averaging region 2")

;               nst_rec_tmp(1) = nst_rec_tmp(1) + 1
;               nst_avg_tmp(1) = nst_avg_tmp(1) +  nst(i_ln, 3)
;           else if (4 .lt. nst(i_ln, 1) .and. nst(i_ln, 1) .lt. 6 .and. 105 .le. nst(i_ln, 2) .and. nst(i_ln, 2) .le. 115) then
;             ; print("Averaging region 3")

;               nst_rec_tmp(2) = nst_rec_tmp(2) + 1
;               nst_avg_tmp(2) = nst_avg_tmp(2) +  nst(i_ln, 3)
;           end if
;           end if
;           end if
;       end do

;       delete(nst)
;       print(nst_ts(0, i_yr-START_YEAR, :))
;   end do
;   
;   opt = True
;   do i_reg = 0, N_REG - 1
;       opt@fout = "region_" + sprinti("%0.2i", i_reg) + ".txt"
;       write_matrix(nst_ts(i_reg, :, :), "75f8.3", opt)
;   end do

    do i_reg = 0, N_REG - 1
        fn = "region_" + sprinti("%0.2i", i_reg) + ".txt"
        nst_ts(i_reg, :, :) = asciiread(fn, (/N_YEAR, N_DAY/), "float")
    end do 

 


    ; PLOTING
               
    wks_pdf      = gsn_open_wks("pdf", "./NST_TS")
;   plot_pdf     = new (2, graphic)
    plot_pdf     = new (1, graphic)
  
    res          = True
    res@gsnDraw  = False  ; don't draw
    res@gsnFrame = False  ; don't advance frame
    res@trXMinF  = 1
    res@trXMaxF  = 74  ; t(dimsizes(t) - 1)

    res@vpHeightF = 0.4              ; change aspect ratio of plot
    res@vpWidthF  = 0.8                  
    
    res@txFont = "Helvetica"
    ; res@pmTickMarkDisplayMode = "Never"
  
    ; res@tmXBMode   = "Explicit"
    ; res@tmXBValues =(/122, 153, 183, 214, 275/)
    ; res@tmXBLabels =(/"Apr", "May", "Jun", "Jul", "Oct"/)
    ; res@tmXBMode   = "Explicit"
    ; res@tmXBValues = (/tb, te, 182/) + 1993*1000
    ; res@tmXBLabels = (/930501, 930601, 930701/)
  
    res@tmLabelAutoStride = True  

    ; res@tmYLFormat = "0@*+^sg"

    res@xyDashPattern     = 0
    res@xyLineThicknesses = (/1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0/)  ; last 2015
    res@xyLineColors      = (/"red", "blue", "green", "brown", "red", "blue", "green", "brown", "red", "blue", "green", "brown", "black"/)

  ; res@xyLineThicknesses = (/1.0, 1.0, 2.0/)  ; last 2015
  ; res@xyLineColors      = (/"red", "blue", "black"/)

    res_panel          = True
    res_panel@txString = "BLACK-2015"

  ; time_x = ispan(1, N_DAY, 1)
    time_x = ispan(1, 71, 1)
  ; data_y = new ((/N_YEAR, N_DAY/), "float")

    do i_reg = 0, N_REG - 1
        res@tiMainString   = "Time series of NST region avg over " + REG_NAME(i_reg)

      ; res@gsnLeftString  = "PR"
      ; res@tiYAxisString = "PR mm/day"

      ; data_y(0, :) = obs_pr(i, :)
      ; data_y(1, :) = mdl_pr(i,              0, :)
      ; data_y(2, :) = mdl_pr(i,              1, :)
      ; data_y(3, :) = mdl_pr(i, pr_rms_best(i), :)
      ; data_y(4, :) = mdl_pr(i, pr_cc_best (i), :)

      ; print(time_x)
      ; print(nst_ts(i_reg, :, :))
        print("i_reg = " + sprinti("%0.2i", i_reg))
      ; plot_pdf(0)  = gsn_csm_xy(wks_pdf, time_x(:), nst_ts(i_reg, 10:12, 0:70), res)
        plot_pdf(0)  = gsn_csm_xy(wks_pdf, time_x(:), nst_ts(i_reg, :, 0:70), res)

        gsn_panel(wks_pdf, plot_pdf, (/1, 1/), res_panel)
    end do



;   delete(res@xyLineThicknesses)
;   delete(res@xyLineColors)
;   delete(res_panel@txString)
end
