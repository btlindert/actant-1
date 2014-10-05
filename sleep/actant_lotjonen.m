function ts = actant_lotjonen(act)
% LOTJONEN scores an actigraphy time series as sleep/wake 
%   
% Arguments:
%   counts  - Input data timeseries (ACT)
%
% Results:
%   ts -   Cell array of timeseries
%
% Copyright (c) 2011-2014 Bart te Lindert
%
% See also: Lötjönen J, et al. Automatic sleep-wake and nap analysis with a 
%           new wrist worn online activity monitoring device Vivago Wristcare.
%           SLEEP 2003; 1:86-90.
%
%           Paquet J, et al. Wake detection capactity of actigraphy during
%           sleep. SLEEP 2007; 30(10):1362-1369
%
%           Sadeh A, et al. Activity-based sleep-wake identification: an
%           empirical test of methodological issues.
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
    if isempty(act)
        errordlg('Not enough input arguments', 'Error', 'modal')
        return
    end

    %% CHECK DATA INPUT FORMAT
    if strcmpi(act.Name, 'ACT')
        % data is counts data
        counts = act.Data;
        time = act.Time;

        % get sampling/epoch duration
        % assume increment in minutes and seconds
        increment = datestr(time(2)-time(1), 'MM:SS');

        if strcmpi(increment, '00:30')
            sampling = 30;
        else
            % display error message
            errordlg('Algorithm can only be applied to 1-min epochs!', 'Error', 'modal');
            return
        end
    else
        % display error message
        errordlg('Algorithm can only be applied to ACT data!', 'Error', 'modal');
        return
    end

    %% CALCULATE VARIABLES
    mn  = zeros(numel(counts), 1);
    sd  = zeros(numel(counts), 1);
    nat = zeros(numel(counts), 1);
    ln  = zeros(numel(counts), 1);
   
    for i = 8:numel(x)-5
        
        % mean activity in a window of 7 epochs around the scored epoch
        mn(i) = mean(counts(i-3:i+3));

        % standard deviation of the activity in a window of 8 epochs around the
        % scored epoch;
        % it's unclear which epochs are being used: 4 preceding and 4 following, or 7
        % preceding, including the scored epoch? Paquet and Lötjönen base 
        % their method on Sadeh (1993) who uses the scored and preceding 
        % epochs, hence:  
        sd(i) = std(counts(i-7:i)); 

        % number of activity counts above 10 in a window of 11 epochs around the
        % scored epoch
        nat(i) = sum(counts(i-5:i+5))-10;
        % if negative set to zero 
        nat(nat < 0) = 0;
    end

    % natural logarithm of the activity in the scored epoch
    % ln(x)+1 according to Sadeh (1993)
    natlog = ln(counts)+1; 

    %%  CLASSIFY SLEEP/WAKE EPOCHS
    % negative (< 0) scores are wake
    % positive (>= 0) scores are sleep 

    lotjonen = 1.687 + 0.003.*s - 0.034.*mn - 0.419.*nat + 0.007.*sd - 0.127.*natlog;
    lotjonen_sw = ones(numel(lotjonen), 1);
    lotjonen_sw(lotjonen >= 0) = 0;

    paquet = 2.457 - 0.004.*s - 0.689.*nat - 0.007.*sd - 0.108.*natlog;
    paquet_sw = ones(numel(paquet), 1);
    paquet_sw(paquet >= 0) = 0;

    %% EXPORT TO TIME SERIES CELL ARRAY 
    ts.lotjonen = timeseries(lotjonen(:, 1), count.Time, 'Name', 'LOTJONEN');
    ts.act.DataInfo.Unit = 'counts';

    ts.lotjonen_sw = timeseries(lotjonen_sw(:, 1), count.Time, 'Name', 'LOTJONEN_SW');
    ts.act.DataInfo.Unit = 'binary';

    ts.paquet = timeseries(paquet(:, 1), count.Time, 'Name', 'PAQUET');
    ts.act.DataInfo.Unit = 'counts';

    ts.paquet_sw = timeseries(paquet_sw(:, 1), count.Time, 'Name', 'PAQUET_SW');
    ts.act.DataInfo.Unit = 'binary';

end