function ts = load_actiware(file)
% LOAD_ACTIWARE Load activity data from exported Actiware .txt file
%
% Description:
%   The function loads the data and adds it to a timeseries object.
%
% Arguments:
%   file - file name
%
% Results:
%   ts - Structure of timeseries
%
% Copyright (C) 2011-2013, Bart te Lindert
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

% The number of headerlines of this type of file can vary, fortunately
% the following line (and an empty line) always precedes the data we need:
% "Date","Time","Off-Wrist Status","Activity","Marker","White Light",...
% "Red Light","Green Light","Blue Light","Sleep/Wake","Mobility",...
% "Interval Status","S/W Status"

% Here we open the file and search for the line above
% open file
out = fopen(file);

% line counter
lineCounter = 0;

% infinite loop
while 1         
    % read a line
    lineText = fgetl(out);
    % iterate line to proceed
    lineCounter = lineCounter + 1;
    % if the line is a string
    if ischar(lineText)
        % find the line containing the string
        U = strfind(lineText, ['"Date","Time","Off-Wrist Status","Activity"',...
            ',"Marker","White Light","Red Light","Green Light","Blue Light"',...
            ',"Sleep/Wake","Mobility","Interval Status","S/W Status"']);
        % if found, break the loop
        if isfinite(U) == 1;
            break
        end
    end
end

% the line is followed by an empty headerline
headerlines = lineCounter + 1;

% read comma delimited data as string with "" indicating text to keep together
data = textscan(out, '%q%q%q%q%q%q%q%q%q%q%q%q%q',...
    'headerlines', headerlines,...
    'delimiter', ',',...
    'expchars', 'E-');

%% offwrist data!!!

% convert data to double
% offWrist       = str2double(data{3});
activity       = str2double(data{4});
marker         = str2double(data{5});
whiteLight     = str2double(data{6});
% redLight       = str2double(data{6});
% greenLight     = str2double(data{8});
% blueLight      = str2double(data{9});
% sleepWake      = str2double(data{10});
% mobility       = str2double(data{11});
% intervalStatus = str2double(data{12});
% swStatus       = str2double(data{13});

% create time stamps
date = datevec(data{1}, 'mm/dd/yyyy');
time = datevec(data{2}, 'HH:MM:SS PM');
time = datenum([date(:,1:3) time(:,4:6)]);

% save data to actant compatible data format: time series object
% create timeseries
ts.act                    = timeseries(activity, time, 'Name', 'ACT');
ts.act.DataInfo.Unit      = 'counts';
ts.act.TimeInfo.Units     = 'seconds';
ts.act.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

ts.button                    = timeseries(marker, time, 'Name', 'BUTTON');
ts.button.DataInfo.Unit      = 'binary';
ts.button.TimeInfo.Units     = 'seconds';
ts.button.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

ts.light                    = timeseries(whiteLight, time, 'Name', 'LIGHT');
ts.light.DataInfo.Unit      = 'lux';
ts.light.TimeInfo.Units     = 'seconds';
ts.light.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

% THE FOLLOWING VARIABLES ARE NOT CURRENTLY SUPPORTED IN ACTANT 
% ts.offWrist                    = timeseries(offWrist, time, 'Name', 'OFFWRIST');
% ts.offWrist.DataInfo.Unit      = 'binary';
% ts.offWrist.TimeInfo.Units     = 'seconds';
% ts.offWrist.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

% ts.redLight                    = timeseries(redLight, time, 'Name', 'RED LIGHT');
% ts.redLight.DataInfo.Unit      = 'microwatts per squared centimeter';
% ts.redLight.TimeInfo.Units     = 'seconds';
% ts.redLight.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

% ts.greenLight                    = timeseries(greenLight, time, 'Name', 'GREEN LIGHT');
% ts.greenLight.DataInfo.Unit      = 'microwatts per squared centimeter';
% ts.greenLight.TimeInfo.Units     = 'seconds';
% ts.greenLight.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

% ts.blueLight                    = timeseries(blueLight, time, 'Name', 'BLUE LIGHT');
% ts.blueLight.DataInfo.Unit      = 'microwatts per squared centimeter';
% ts.blueLight.TimeInfo.Units     = 'seconds';
% ts.blueLight.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

% ts.sleepWake                    = timeseries(blueLight, time, 'Name', 'SLEEP WAKE');
% ts.sleepWake.DataInfo.Unit      = 'microwatts per squared centimeter';
% ts.sleepWake.TimeInfo.Units     = 'binary';
% ts.sleepWake.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

% ts.mobility                    = timeseries(mobility, time, 'Name', 'MOBILITY');
% ts.mobility.DataInfo.Unit      = 'binary';
% ts.mobility.TimeInfo.Units     = 'seconds';
% ts.mobility.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

% ts.intervalStatus                    = timeseries(intervalStatus, time, 'Name', 'INTERVAL STATUS');
% ts.intervalStatus.DataInfo.Unit      = 'text';
% ts.intervalStatus.TimeInfo.Units     = 'seconds';
% ts.intervalStatus.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

% ts.swStatus                    = timeseries(swStatus, time, 'Name', 'SLEEP WAKE STATUS');
% ts.swStatus.DataInfo.Unit      = '?';
% ts.swStatus.TimeInfo.Units     = 'seconds';
% ts.swStatus.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

end