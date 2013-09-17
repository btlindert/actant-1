function ts = load_geneactiv(file)
% LOAD_GENEACTIV Load activity data from GENEActiv CSV file
%
% Description:
%   The function takes a GENEActiv CSV file with activity data and loads it
%   into a timeseries object.
%
% Arguments:
%   file - CSV file name
%
% Results:
%   ts - Timeseries object with 'ACC' name and 'm/s^2' units
%
% Copyright (C) 2011-2013, Maxim Osipov
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
%  - Neither the name of the University of Oxford nor the names of its
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
%

fid = fopen(file, 'r');
if (fid == -1)
    error('Could not open file %s', file);
end

% read activity data
frewind(fid);
for i=1:101,
    string = fgetl(fid);
end
tmp = textscan(fid, '%s%f%f%f%f%f%f', 'Delimiter', ',');
fclose(fid);
time = datenum(tmp{1}, 'yyyy-mm-dd HH:MM:SS:FFF');
acc_x = tmp{2};
acc_y = tmp{3};
acc_z = tmp{4};

% create timeseries
ts = timeseries([acc_x, acc_y, acc_z], time, 'Name', 'ACC');
ts.DataInfo.Unit = 'm/s^2';
ts.TimeInfo.Units = 'days';
ts.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';
