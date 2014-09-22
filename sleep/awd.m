function act = awd(ts)
% AWD converts an accelerometry time series to counts epochs of 15 seconds   
%
% Arguments:
%   ts    - Input data timeseries (ACCZ)
%
% Results:
%   act   - Timeseries of counts (ACT)  
%
% Copyright (c) 2011-2014 Bart te Lindert
%
% See also: te Lindert BHW; Van Someren EJW. Sleep estimates using
%           microelectromechanical systems (MEMS). SLEEP 2013;
%           36(5):781-789
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

    % get ts data
    data = get(ts, 'Data');
    time = get(ts, 'Time');

    % assume increment in milliseconds
    increment = str2double(datestr(time(2)-time(1), 'FFF'));

    % sampling frequency in Hz
    fs = (1/increment)*1000;

    if isnan(fs)
        errordlg('Samplig rate is NaN!');
        return
    end

    % set filter specifications
    cf_low = 3;               % lower cut off frequency (Hz)
    cf_hi  = 11;              % high cut off frequency (Hz)
    order  = 5;               % filter order
    pass   = 'bandpass';      % filter type
    w1     = cf_low/(fs/2);   % normalized frequency low
    w2     = cf_hi/(fs/2);    % normalized frequency high
    [b, a] = butter(order, [w1 w2], pass); 

    % filter data (can only be Z-axis data of Geneactiv, see input)
    z_filt = filtfilt(b, a, data); 

    % convert data to 128 bins between 0 and 5
    z_filt = abs(z_filt);
    topEdge = 5;
    botEdge = 0; 
    numBins = 128; 

    binEdges = linspace(botEdge, topEdge, numBins+1);
    [~, binned] = histc(z_filt, binEdges);

    % convert to counts/epoch
    epoch = 15;
    counts = max2epochs(binned, fs, epoch);

    % NOTE: Please be aware that the algorithm used here has only been
    % validated for 15 sec epochs and 50 Hz raw accelerometery (palmar-dorsal
    % z-axis data. The formula (1) used below
    % is based on these settings. The longer the epoch, the higher the
    % constant offset/residual noise will be(18 in this case). Sampling frequencies 
    % will probably affect the constant offset less. However, due 
    % to the band-pass of 3-11 Hz used above and human movement frequencies 
    % of up to 10 Hz, a sampling of less than 25 Hz is considered unreliable.

    % subtract constant offset and multiply with factor for distal location
    counts = (counts-18).*3.07;                   % ---> formula (1)

    % set any negative values to 0
    indices = counts < 0;
    counts(indices) = 0;

    % create a new time series for the epoch data
    timeNum = zeros(size(counts));
    timeNum(1) = datenum(time(1));
    for i = 2:numel(timeNum)
        timeNum(i) = datenum(addtodate(timeNum(i-1), 15, 'second'));
    end

    % create timeseries
    act = timeseries(counts, 'Name', 'ACT');
    act.DataInfo.Unit  = 'counts';
    act.TimeInfo.Units = 'seconds';

    % create a uniform timeseries based on the start time and the epoch duration
    % make sure the TimeInfo.Units of ts1 has already been set to seconds 
    act = set(act, 'Time', timeNum);
    
end