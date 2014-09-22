function out = nonwear(ts)
% NONWEAR searches the data for 30-min non-wear periods.
% A 30-min block was classified as non-wear time if the standard deviation 
% is less than 3.0 mg (1 mg = 0.00981 m/s^2) for at least two out of the 
% three axes OR if the value range, for at least two out of three axes, 
% was less than 50 mg. 
%
% Results:
%   ts -   Cell array of timeseries containing acc_x, acc_y, acc_z
%
% Copyright (c) 2011-2014 Bart te Lindert
%
% See also:     Estimation of Daily Energy Expenditure in Pregnant and 
%               Non-Pregnant Women Using a Wrist-Worn Tri-Axial Accelerometer 
%               van Hees VT, Renstro F, Wright A, Gradmark A, Catt M,
%               Chen KY, Lo M, Bluck L, Pomeroy J, Wareham NJ, Ekelund U, Brage S,
%               Franks PW. Plos ONE 2011 6(7):e22922
% 
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without modification,
% are permitted provided that the following conditions are met:
%
%  - Redistributions of source code must retain the above copyright notice, this
%    list of conditions and the following disclaimer.
%  - Redistributions in binary form must reproduce the above copyright notice,
%    this list of conditions and the following disclaimer in the documentation
%    and/or other materials provided with the distribution.
%  - Neither the name of the Netherlands Institute for Neuroscience nor the names of its
%    contributors may be used to endorse or promote products derived from this
%    software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
% ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
% IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
% INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
% BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
% DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
% OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
% OF THE POSSIBILITY OF SUCH DAMAGE.

%% THEN CHECK IF NONE OF THE ARGUMENTS IS EMPTY

if isempty(ts)
    errordlg('Not enough input arguments', 'Error', 'modal')
end

%% CHECK DATA INPUT FORMAT
if ~(isfield(ts, acc_x) && isfield(ts, acc_y) && isfield(ts, acc_z))
    % display error message
    errordlg('X, Y, Z data not all present. Check your input timeseries', 'Error', 'modal');
    return
end

%% START DATA PROCESSING
% extract the data from each of the time series objects
x = ts.acc_x.Data;
y = ts.acc_y.Data;
z = ts.acc_z.Data;

% combine x,y,z data into matrix
xyz = [x', y', z'];

%% CLASSIFY NONWEAR DATA
% split data in 30 minute block
%%%%%%%%% data should be redundant, get smapling for timediff(time(1)-time(2));
fs           = args{1};
blockSamples = fs*60*30;
nBlocks      = floor(numel(x)/blockSamples);
xyzSD        = zeros(nBlocks, 3);
xyzRange     = zeros(nBlocks, 3);

for ii = 1:3    
    % reshape data per axis to blockSamples-by-nBlocks matrix
    blocks  = reshape(xyz(1:nBlocks*blockSamples, ii), blockSamples, nBlocks);

    % calculate standard deviation and range per block (column)
    % and add to column vector corresponding to axis
    xyzSD(:,ii)    = std(blocks, 1);
    xyzRange(:,ii) = range(blocks, 1);
end

% recall the criteria for non-wear:
% 2 out of 3 axes should have SD less than 3.0 mg = 0.003 g
% OR if range for 2 out 3 axes is less than 50 mg = 0.050 g

% create matrices for SD and range
tmp                   = zeros(size(xyzSD));
tmp(xyzSD < 0.003)    = 1; % find cells with SD less than threshold
xyzSdSum              = sum(tmp, 2); % sum across rows

tmp                   = zeros(size(xyzRange));
tmp(xyzRange < 0.050) = 1; % find cells with range less than threshold
xyzRangeSum           = sum(tmp, 2); % sum across rows

% define non-wear blocks
nonwear = zeros(size(xyzRangeSum));
nonwear(xyzSdSum >= 2 || xyzRangeSum >= 2) = 1; % find rows/blocks that have at least one of the two criteria 

% replace old data with new
out.acc_x.Data = XYZ(1,:);
out.acc_y.Data = XYZ(2,:);
out.acc_z.Data = XYZ(3,:);


%% CREATE NONWEAR TIME SERIES
% create nonwear matrix consisting of zeros
tsnonwear = zeros(size(blocks));

% fill nonwear periods with ones, then reshape to vector
tsnonwear(:, allNonWearCols) = 1;
nw = reshape(tsnonwear, numel(tsnonwear), 1);

% copy original time series to include the trailing samples that were 
% rejected by the reshape function
finaltsnonwear = zeros(size(x));

% add the nonwear vector
finaltsnonwear(1:numel(nw)) = nw; 

% create time series object
out.nonwear = timeseries(finaltsnonwear, out.acc_x.Time, 'Name', 'NONWEAR');
out.nonwear.DataInfo.Unit = 'binary';
out.nonwear.TimeInfo.Units = 'seconds';


%% this is part of the imputation and calculating energy expenditure

%% FILTER XYZ DATA
% bandpass filter wear data with 4th order Butterworth filter (0.2-15 Hz)
cf_low  = 0.2;             % lower cut-off frequency (Hz)
cf_hi   = 15;              % high cut-off frequency (Hz)
order   = 4;               % filter order
pass    = 'bandpass';      % filter type
w1      = cf_low/(fs/2);   % normalized frequency low
w2      = cf_hi/(fs/2);    % normalized frequency high
[b, a]  = butter(order, [w1 w2], pass); 

% filter data
xyzFilt = filtfilt(b, a, xyz); 

%% CALCULATE SVM FOR IMPUTATION
xyzFilt = xyzFilt.^2;
svm     = sqrt(sum(xyzFilt, 2));

% average over 1 sec intervals
seconds = floor(svm/fs);
data    = reshape(svm(1:fs*seconds), fs, seconds);

% average across columns and convert to column vec
svm     = mean(data, 1)';

% reshape to secs-by-nBlocks
nBlocks = floor(svm/(30*60));
svm     = reshape(svm(1:nBlocks*30*60), 30*60, nBlocks);

%% impute using data from other days at the same time, excluding additional
% missing data (30 min blocks are always identical across days)
% fill non-wear (missing) data with average svm of data in the same 
% time frame on other days
% there are 30 minute block, i.e 24*2 = 48 blocks in a day
% i.e. 1, 1+48, 1+2*48, 1+3*48 blocks are matched on daytime 

% get set of nonwear blocks:
allNonWearCols = find(nonwear == 1); 

% for all unique time of day blocks...
for jj = 1:48
    % select time-of-day blocks across days
    cols = jj:48:nBlocks; 

    % get non-empty (i.e. wearing columns)
    wearCols = setdiff(cols, allNonWearCols);

    % get the nonwear cols for this time of day
    nonWearCols = setdiff(cols, wearCols);

    % fill nonwear columns with mean of wear columns     
    svm(:, nonWearCols) = mean(svm(:,wearCols),2);        
end

% reshape back to original time series
%svm = reshape(svm, numel(svm), 1);

% average data per subject per day
% average across 48 blocks
for jj = 1:48:size(svm,2)
    ACC2(jj) = sum(svm(:, jj:jj-1));
end

    % PAEE (MJ day^-1) - model 2, Body weight (kg), ACC2 (g)
    PAEEnonPregnant = ACC2*22.553 + 0.019*BW;

    % PAEE (J min^-1 kg^-1) (see appendix S1, van Hees 2011) ACC2 (g):
    PAEEnonPregnant = ACC2*248.584 + 0.192;
    PAEEpregnant = ACC2*157.565 + 12.287; 

end

% split non-wear from imputation. Imputation is done on 1 sec data epochs
% instead of raw data. Imputation can therefore only be used for this
% algorithm (van Hees).
