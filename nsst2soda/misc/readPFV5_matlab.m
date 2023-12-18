% This example Matlab m-file demonstrates how to read in Pathfinder
% Version 5 data from NODC.  http://pathfinder.nodc.noaa.gov
%
% Created by: Kenneth S. Casey, NOAA National Oceanographic Data Center
%             Kenneth.Casey@noaa.gov
%
% Date: August 17, 2005
%
% Note:  this example code is rather simple in that it does not use
% the full HDF API found in Matlab.  To take advantage of its capabilities,
% including doing things like reading in subsets, striding the data,
% extracting more metadata from the file, etc., look at the help pages 
% on "hdfsd".

% Define the overall quality flag file name:
fname1 = '200112.m04m3pfv50-qual.hdf';

% Now read the quality data using hdfread.  You could also use full HDF API
% with matlab's "hdfsd" functions, but this is simpler. 
qual=hdfread(fname1, 'qual', 'index', {[1.0 1.0],[1.0 1.0], [4096 8192]});

% Now get the information about the hdf file and its contents. Again,
% you could use the "hdfsd" function, but this is simpler:
fileinfo = hdfinfo(fname1);  
lat=fileinfo.SDS.Dims(1).Scale; % Get the latitudes
lon=fileinfo.SDS.Dims(2).Scale; % Get the longitudes

% Now display it:
figure(1)
imagesc(lon,lat,qual); % Display the data
set(gca,'ydir','normal'); % Simply puts the display with positive lats up
title('Overall Quality Levels (0 worst to 7 best)')
caxis([0 7])
colorbar

% NOTE: The overall quality flags do not need any conversion from pixel
% values.  They are stored simply as values from 0 to 7 (in other words,
% the scale is 1 and the offset is 0).  However, if you were reading in one
% of the Pathfinder SST files, you would need to apply a scale and offset
% after reading in the data. For example:
fname2 = '200112.s04m3pfv50-sst-16b.hdf';  

% Read the data in as 16-bit unsigned integers:
sst=hdfread(fname2, 'sst', 'index', {[1.0 1.0],[1.0 1.0], [4096 8192]});

% Get the scale and offset:
fileinfo2 = hdfinfo(fname2);  
scale_factor = double(fileinfo2.SDS.Attributes(11).Value);  % = 0.075;
add_offset= double(fileinfo2.SDS.Attributes(12).Value);     % = -3.0;

% Now apply them to turn SST pixel values into deg C:
sst = double(sst)*scale_factor + add_offset;

% Now, let's subset these data to a particular region,
% apply the quality flag to the data and display it:

lonmin = -100;  % Set lon and lat limts.  Note that if you
                % want to subset across the dateline
                % to create a map of the Pacific, for example,
                % you have to be a little more clever and subset the map
                % into two pieces, one from, for example, 100E to 180E,
                % then another from -180W to 100W.  Then piece
                % the two together.
lonmax = 0;
latmin = 0;
latmax = 45;
goodlons = lon>=lonmin & lon<=lonmax;  % Find matching longitudes
goodlats = lat>=latmin & lat<=latmax; % Find matching latitudes
subset_qual = qual(goodlats,goodlons);  % Subset the quality data
subset_sst = sst(goodlats,goodlons);  % Subset the SST data
cloudypixels = subset_qual<4; % Finds all pixels with quality level < 4
masked_sst = subset_sst;
masked_sst(cloudypixels) = -3;  % Sets the cloud pixels to -3 deg C 
                                % (colder than physically possible)
sublons = lon(goodlons);  % Subset the longitudes
sublats = lat(goodlats); % Subset the latitudes
figure(2)
imagesc(sublons,sublats,masked_sst);  % Display it
set(gca,'ydir','normal'); % Simply puts the display with positive lats up
title('SST in DegC, Quality Levels 4-7 Only')
colorbar; % Add a color scale

% If you like to use the Mapping Toolbox,  do something like 
% this.  Here, we will plot the global SST field with cloudy pixels
% unmasked. Note that this step can take a while depending on the
% memory, CPU, and graphics capability of your computer:
figure(3)
ml = [8192/360 90 -180];  % Sets up the map legend
axesm('robinson');  % or whatever projection you want
sst = flipud(sst); % Puts the array into a more workable orientation
lat2 = fliplr(lat);   % Makes sure you flip the lats around too, in case
                      % you wish to use these later along with "sst"
m=meshm(sst,ml); % Display it
ll = coast;  % Load coarse resolution global coastlines
p=plotm(ll(:,1),ll(:,2),'w');  % Display coastlines on map
caxis([-3 35])
colorbar('horiz')
title('SST in Deg C, All Quality Levels')

