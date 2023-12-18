;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;NAME: FUNCTION pathfinder_v5_hdf_read, filename, sdsname
;
;AUTHOR:  Andrew D. Barton, andrew.barton@noaa.gov
;
;DATE CREATED:  April 29, 2005

;PURPOSE: This program opens Pathfinder v5.0 hdf file supplied by user and reads an SDS name
;supplied by user.   
;
;INPUT: User specifies the hdf file (filename) to open, as well as the SDS layer to read (sdsname).
;Both inputs must be strings.
;
;OUTPUT:  Returns an array containing the SDS requested in the data type used by the file
;creator.
;
;CONNECTIONS (WITH OTHER PROGRAMS): For information on hdf file attributes and SDS names and 
;attributes, try hdf_info.pro available from RSI, the maker of IDL.  This program is provided when
;IDL is installed on your system.
;
;CALLING SEQUENCE:  x=pathfinder_v5_hdf_read('filename/here','SDSname_here')
;
;COMMENTS (COMMENT + DATE):  Same code can be used to open SeaWiFS, QuikSCAT wind, and other 
;oceanographic data sets in hdf format.  
;
; SDSname = mask1 for files with msk1 in filename
; SDSname = mask2 for files with msk2 in filename
; SDSname = num for files with num in filename
; SDSname = qual for files with qual in filename
; SDSname = bsst for files with bsst in filename
; SDSname = sst for files with sst in filename
; SDSname = sst for files with sdev in filename (yes, sst is the variable name for the standard deviation files)
;
;REFERENCES:  
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
FUNCTION pathfinder_v5_hdf_read, filename, sdsname

;Start HDF interface for given filename
sd_id = hdf_sd_start(filename)

;Locate SDS of interest
index=  hdf_sd_nametoindex(sd_id, sdsname)
sds_id= hdf_sd_select(sd_id, index)

;Open the SDS and read the data into variable arr
hdf_sd_getdata, sds_id, arr

;End access to the SDS
hdf_sd_endaccess, sds_id

;End access to the HDF file
hdf_sd_end, sd_id

RETURN, arr

END
