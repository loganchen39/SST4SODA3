'''
Description: Compute binned/average result on SODA 1-degree grid from 0.02-degree ACSPO L3S daily SST.
Author: Ligang Chen
Date created: 05/08/2024
Date last modified: 05/08/2024 
'''

import numpy as np
import xarray as xr

import datetime
import glob
import os

import sys
sys.path.append('/glade/u/home/lgchen/lgchen_work/lib/mylib_repo/f2py')
import fort


# To print all numpy array elements.
np.set_printoptions(threshold=np.inf)

DIR_AC = '/glade/u/home/lgchen/lgchen_scratch_derecho/data/SST4SODA/acspo_l3s_leo_daily'
FN_AC_TEST = DIR_AC + "/test/20230101120000-STAR-L3S_GHRSST-SSTsubskin-LEO_Daily-ACSPO_V2.81-v02.0-fv01.0.nc"
ds_ac_test = xr.open_dataset(filename_or_obj=FN_AC_TEST)
ds_ac_test.coords['lon'] = xr.where(ds_ac_test.coords['lon']<0, 360+ds_ac_test.coords['lon'], ds_ac_test.coords['lon'])
ds_ac_test.sortby(ds_ac_test.coords['lon'])
#  9000: 89.99, 89.97, ..., -89.97, -89.99;
lat_ac = ds_ac_test.coords['lat'] 
# 18000: (initially) -179.99, -179.97, ..., 179.97, 179.99;
# 18000: after sorted: 180.01, 180.03, ..., 359.97, 359.99, 0.01, 0.03, ..., 179.97, 179.99
lon_ac = ds_ac_test.coords['lon']  

lat_so = np.zeros((180), dtype=np.float32, order='F')
lon_so = np.zeros((360), dtype=np.float32, order='F')
for i in range(1, 181):
    lat_so[i-1] = -89.5 + (i - 1)*1.0  # -89.5, -88.5, ..., 88.5, 89.5
for i in range(1, 361):
    lon_so[i-1] = i*1.0  # 1.0, 2.0, ..., 359.0, 360.0

# formula, lat_so = -89.5 + i*1.0 = lat_ac => i = lat_ac + 89.5
# lon_so = 1.0 + i*1.0 = lon_ac => i = lon_ac - 1.0

# lat: 9000 : 179, 179, ..., 178, 178, ..., 1, 1, ... 0 0; 
idx_lat_ac2so = np.around(1*(ds_ac_test.coords['lat'].values+89.5)).astype(np.int32) 
# lon: 18000: 179, 179, ... (here 25 of 179), 180, 180, ..., 359, 359, ...
#     , -1, -1, ..., 0, 0, ..., 1, 1, ..., 178, 178, ..., 179 179 (here: 25, correspond to SODA 180.-degree).
#     the -1 indices correspond to 0.01, 0.03, ..., 0.47, 0.49, (total 25), which should be changed to 359 (i.e. 360.-degree) 
idx_lon_ac2so = np.around(1*(ds_ac_test.coords['lon'].values-1.0 )).astype(np.int32)
idx_lon_ac2so = xr.where(idx_lon_ac2so == -1, 359, idx_lon_ac2so)

# print(idx_lat_ac2so)
# print(idx_lon_ac2so)
# exit()

# the index should still start with 0?
idx_lat_so2ac = np.zeros((2, 180), dtype=np.int32, order='F') 
idx_lon_so2ac = np.zeros((2, 360), dtype=np.int32, order='F')

# For each SODA lat point, calculate its corresponding start and end indices in ACSPO_L3C
# result, [[8950 8999], [8900 8949], ..., [  50   99], [   0   49]]
idx_lat_so_curr = idx_lat_ac2so[0]
idx_lat_so2ac[0, idx_lat_so_curr] = 0
for i_lat_ac in range(1, 9000): 
    if idx_lat_ac2so[i_lat_ac] != idx_lat_so_curr:
        idx_lat_so2ac[1, idx_lat_so_curr] = i_lat_ac - 1
        idx_lat_so_curr = idx_lat_ac2so[i_lat_ac]
        idx_lat_so2ac[0, idx_lat_so_curr] = i_lat_ac
else:
    idx_lat_so2ac[1, idx_lat_so_curr] = 9000 - 1

# For each SODA lon point, calculate its corresponding start and end indices in ACSPO_L3C
# result, [[9025 9074], [9075 9124],...,[17925 17974], [17975, 17999], [25 74], [75 124], ..., [8925 8974], [8975 9024]]
# so for 179 (i.e. SODA 180.-degree), the corresponding lon indices should be: [0-24 & 17975-17999], can it 
#     be calculated as 1D using python negative indices? 
idx_lon_so_curr = idx_lon_ac2so[0]
idx_lon_so2ac[0, idx_lon_so_curr] = 0
for i_lon_ac in range(1, 18000): 
    if idx_lon_ac2so[i_lon_ac] != idx_lon_so_curr:
        idx_lon_so2ac[1, idx_lon_so_curr] = i_lon_ac - 1
        idx_lon_so_curr = idx_lon_ac2so[i_lon_ac]
        idx_lon_so2ac[0, idx_lon_so_curr] = i_lon_ac
else:
    idx_lon_so2ac[1, idx_lon_so_curr] = 18000 - 1

# print(idx_lat_so2ac)
# print(idx_lon_so2ac)
# exit()

# for fortran index convention, maybe not here
idx_lat_so2ac += 1
idx_lon_so2ac += 1




# SAT_NM = [('noaa15', 'N15'), ('noaa18', 'N18'), ('noaa19', 'N19')]

sst_soda_5day_avg = np.zeros((360, 180), dtype=np.float32, order='F') 
num_sst_soda_5day = np.zeros((360, 180), dtype=np.int32  , order='F')

sst_soda_1rec_avg = np.zeros((360, 180), dtype=np.float32, order='F')  # here 1rec corresponds to 1day
num_sst_soda_1rec = np.zeros((360, 180), dtype=np.int32  , order='F')  # for binned to avg

jday_20230103 = datetime.date(2023, 1 , 3 )
# jday_20230110 = datetime.date(2023, 1 , 10)
jday_20231231 = datetime.date(2023, 12, 31)

jday = jday_20230103
while jday <= jday_20231231:
    str_jday = jday.strftime('%Y%m%d')
    print('\n\n current jday: ', str_jday)
    curr_jul_day = jday.toordinal() + 1721425

    sst_soda_5day_avg.fill(0)
    num_sst_soda_5day.fill(0)

    idy = jday - datetime.timedelta(days=2)
    while idy <= jday + datetime.timedelta(days=2):
        str_date = idy.strftime('%Y%m%d')
        print('\n current date: ', str_date)

      # for (sat_dir, sat_fn) in SAT_NM: 
        fn = DIR_AC + '/' + str_date + '120000-STAR-L3S_GHRSST-SSTsubskin-LEO_Daily-ACSPO_V2.81-v02.0-fv01.0.nc'
        if not os.path.exists(fn): 
            print("Warning file not exist: " + fn)
            idy += datetime.timedelta(days=1)
            continue

        print('current file: ', fn)

        sst_soda_1rec_avg.fill(0)  # In-place operation
        num_sst_soda_1rec.fill(0)

        ds = xr.open_dataset(filename_or_obj=fn, mask_and_scale=True, decode_times=True  \
            , drop_variables=['sst_dtime', 'sses_standard_deviation'  \
            , 'dt_analysis', 'sst_count', 'sst_source', 'satellite_zenith_angle', 'wind_speed'  \
            , 'crs']).isel(time=0)

        ds['quality_level'] = ds.quality_level.astype(np.int8)  # convert back to type byte.
        ds['sea_surface_temperature'] = xr.where(ds.quality_level==5, ds.sea_surface_temperature, np.nan)
        ds['sea_surface_temperature'] = ds['sea_surface_temperature'] - ds['sses_bias']  # actual sst
        ds['sea_surface_temperature'] = xr.where(ds['sea_surface_temperature'] < 250, 0, ds['sea_surface_temperature'])
        ds['sea_surface_temperature'] = xr.where(ds['sea_surface_temperature'] > 350, 0, ds['sea_surface_temperature'])
        # HAVE TO use assignment! DataArray.fillna() itself is NOT an in-place operation!
        ds['sea_surface_temperature'] = ds['sea_surface_temperature'].fillna(0)

        ds.coords['lon'] = xr.where(ds.coords['lon']<0, 360+ds.coords['lon'], ds.coords['lon'])
        ds.sortby(ds.coords['lon'])
      # ds['l2p_flags'] = ds.l2p_flags.astype(np.int16)  # no need for this.

      # print('Start processing SST, current time: ', datetime.datetime.now().strftime('%H:%M:%S'))
        sst_fort = ds['sea_surface_temperature'].values.T
        (sst_soda_1rec_avg, num_sst_soda_1rec) = fort.sst_acspo2soda_1rec(sst_fort, idx_lat_so2ac, idx_lon_so2ac)
      # print('End processing SST, current time: ', datetime.datetime.now().strftime('%H:%M:%S'))

        sst_soda_5day_avg[:, :] += sst_soda_1rec_avg
        num_sst_soda_5day[:, :] += num_sst_soda_1rec

        idy += datetime.timedelta(days=1)


    sst_soda_5day_avg = np.divide(sst_soda_5day_avg, num_sst_soda_5day, where=(num_sst_soda_5day != 0))  # or use '!=0'
    sst_soda_5day_avg = xr.where(num_sst_soda_5day ==0, -999, sst_soda_5day_avg)

    # write out to netCDF, for check only, not necessary
    da_sst_soda_5day_avg = xr.DataArray(data=np.float32(sst_soda_5day_avg[:, :].T)  \
        , dims=['lat', 'lon'], coords={'lat': lat_so, 'lon': lon_so}, name='sst_soda_5day_avg'  \
        , attrs={'units':'Kelvin', '_FillValue':-999})
    da_num_sst_soda_5day = xr.DataArray(data=np.int32  (num_sst_soda_5day[:, :].T)  \
        , dims=['lat', 'lon'], coords={'lat': lat_so, 'lon': lon_so}, name='num_sst_soda_5day'  \
        , attrs=dict(_FillValue=0))

    ds_sst_soda_5day = xr.merge([da_sst_soda_5day_avg, da_num_sst_soda_5day])
    fn_sst_soda_5day = str_jday+'_sst_soda_5day_avg_ACSPO_L3S.nc'
    ds_sst_soda_5day.to_netcdf(DIR_AC+'/l3s2soda/'+fn_sst_soda_5day)

    # write out to text file for SODA use
    fn_sst = DIR_AC + '/l3s2soda/' + '2023_sst_soda_5day_avg_ACSPO_L3S.bin'
    
    fort.write_sst_noaa2soda_5day_avg(fn_sst, curr_jul_day-2440000, sst_soda_5day_avg)

    jday += datetime.timedelta(days=5)
