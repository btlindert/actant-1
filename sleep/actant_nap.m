function [dataWake times naps] = actant_nap(act, args1, args2)
% ACTANT_NAP finds naps based on the criteria set in args1
% within the time frames specified in args2
%
% Arguments:
%   data  - Input data timeseries (ACT or ACCZ)
%   args1 - {5 x 1} Cell array of algorithm arguments
%           Min         - 10     (can be set to any integer less than 'max')
%           Max         - 180    (can be set to any interger greater than
%                                'min')
%           Sensitivity - 'l'    (low, 20)
%                         'm'    (medium, 40) - DEFAULT
%                         'h'    (high, 80)
%   args2 - {DAYS x 4} Cell array of analysis period data
%           {'Start date', 'Start time', 'End date', 'End time'};
%
% Results (all optional):
%   naps  - Cell array of nap periods {onset, offset, duration}
%
% Copyright (c) 2011-2014 Bart te Lindert
%
% See also: Based on method used in Actiwatch Activity & Sleep Analysis 5, v5.08
%           Max duration, min duration and sensivity are set.
%
%           Thoughts and comments:
%           - Although a threshold is set, the raw counts are being used
%             when applying the threshold. Setting the threshold to zero, means
%             you'll be selecting periods of immobility.
%           - How many epochs with a value above the threshold  are allowed?
%             Currently we allow none.
%           - The algorithm differs from the Respironics Actiware software. 
%             It automagically selects minor rest periods.  It finds periods
%             of minimal 40 minutes with activity below a given threshold. 
%             However, in Actiware software, it's unclear how many epochs 
%             above the threshold are accepted, but it appears more > 1.
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

    %% FIRST CHECK FOR SUFFICIENT INPUT ARGUMENTS
    vals = {};

    if nargin < 3
        errordlg('Not enough input arguments', 'Error', 'modal')
        return
    end

    %% THEN CHECK IF NONE OF THE ARGUMENTS IS EMPTY
    if isempty(act)
        errordlg('Not enough input arguments', 'Error', 'modal')
        return
    elseif isempty(args1)
        errordlg('No method selected', 'Error', 'modal')
        return
    elseif isempty(args2)
        errordlg('Please provide analysis period data', 'Error', 'modal')
        return
    end


    %% CHECK DATA INPUT FORMAT
    if strcmpi(act.Name, 'ACT')
        % data is counts data
        data = act.Data;
        time = act.Time;

        % get sampling/epoch duration
        % assume increment in minutes and seconds
        increment = datestr(time(2)-time(1), 'MM:SS');

        if strcmpi(increment, '00:15')
            sampling = 15;
        elseif strcmpi(increment, '00:30')
            sampling = 30;
        elseif strcmpi(increment, '01:30')
            sampling = 60;
        elseif strcmpi(increment, '02:00')
            sampling = 120;
        else
            % display error message
            errordlg('Epoch duration not recognized. It can be 15s, 30s, 1min, 2min ONLY!', 'Error', 'modal');
            return
        end
    elseif strcmpi(act.Name, 'ACCZ')
        % data is raw z-axis accelerometry of Geneactiv
        % data needs to be converted to counts using function awd (bottom of this
        % script)
        act = awd(act);
        data = act.Data;
        time = act.Time;
        sampling = 15;
    else
        % display error message
        errordlg('Algorithm can only be applied to ACT or ACCZ data!', 'Error', 'modal');
        return
    end

    if nargin == 1
        errordlg('No algorithm and time periods set!', 'Error', 'modal');
        return;
    elseif nargin == 2
        errordlg('No time periods set!', 'Error', 'modal');
        return;
    end

    %% INITIALIZE VARIABLES 
    days        = size(args2, 1);
    lower       = args1{2,2};
    upper       = args1{3,2};
    sensitivity = args1{4,2};

    %% GET THRESHOLD
    % convert sensitivity to threshold
    if strcmpi(sensitivity, 'l')
        thres = 80;
    elseif strcmpi(sensitivity, 'm')
        thres = 40;
    elseif strcmpi(sensitivity, 'h')
        thres = 20;
    end

    % score as wake if > threshold
    % score as sleep <= threshold
    wake = zeros(size(data));
    
    % The Actiwatch Sleep & Activity software uses the raw counts, not the
    % rescored values to set a threshold
    wake(data > thres) = 1;
    
    %% FIND ANALYSIS START AND ANALYSIS END
    % create time series WAKE to allow data selection based on time 
    wake = timeseries(wake, time, 'Name', 'WAKE');
    wake.DataInfo.Unit = 'binary';

    % convert 'lower' and 'upper' from minutes to epochs 
    lower = lower*(60/sampling);
    upper = upper*(60/sampling);
    naps  = [];
    
    idx = 1;

    for day = 1:days
        % extract the correct date and time from args2
        startTime = dateconversion(args2{day, 1}, args2{day, 2});
        endTime   = dateconversion(args2{day, 3}, args2{day, 4});

        % select the period of interest in the (binary) wake series     
        tsWake   = getsampleusingtime(wake, startTime, endTime);
        dataWake = tsWake.Data;
        
        % calculate naps
        times    = find_nap_blocks(dataWake', lower, upper);
        
        % number of naps
        nnaps    = size(times, 1);
        
        % paste times into naps
        onsets   = tsWake.Time(times(:,1));
        offsets  = tsWake.Time(times(:,2));
        duration = (times(:,3).*sampling)/60;
        naps(idx:idx+nnaps-1, 1:3) = [onsets offsets duration];
        
        % iterate, because there can be multiple naps per period of
        % interest
        idx = idx + nnaps;
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUB FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function date = dateconversion(date, time)
%   DATECONVERSION merges date and time strings into a datenum

    time = num2str(time);
    MM   = str2double(time(end-1:end));
    HH   = str2double(time(1:end-2));
    date = datevec(date, 'dd-mm-yy');
    
    if isempty(HH)
        HH = 0;
    end
    
    if isempty(MM)
        MM = 0;
    end

    date = [date(1:3), HH, MM, 00];
    date = datenum(date);
    
end

function times = find_nap_blocks(vec, minlength, maxlength)
    % vec is a binary vector with wake = 1 and sleep = 0
    % find indices of zeros
    pos = find(vec < 1);
    
    % calculate diff between successive indices
    posDiff = diff([-1 pos]);

    % find onsets of new series of zeros if difference between successive 
    % zeros is more than 1
    onsets = pos(posDiff > 1);

    % find indices of ones
    pos = find(vec > 0);

    % calculate diff between successive values
    posDiff = diff([-1 pos]);

    % find onsets of ones, i.e. offsets of zeros
    offsets = pos(posDiff > 1);

    % if series ends with 0, add numel to offset
    if (vec(1) == 0 && numel(onsets) ~= numel(offsets))
        offsets = [offsets, numel(vec)+1];
    elseif vec(1) == 1
        if numel(onsets) ~= numel(offsets)
            offsets = offsets(2:end);
        else
            offsets = [offsets(2:end) numel(vec)+1];
        end
    end

    % merge onsets, offsets and duration into one matrix
    times = [onsets' offsets' offsets'-onsets'];
     
    % clear naps with duration greater than maxlength
    times(times(:,3) > maxlength, :) = [];

    % clear naps with duration less than minlength
    times(times(:,3) < minlength, :) = [];

end