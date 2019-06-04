function ts = load_geneactiv_bin(file)
% LOAD_GENEACTIV_BIN Load activity data from GENEActiv BIN file
%
% Description:
%   The function takes a GENEActiv BIN file with activity data and loads it
%   into timeseries objects.
%
% Arguments:
%   file - BIN file name
%
% Results:
%   ts - Structure of timeseries
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

[~, time, xyz, light, button, ~] = read_bin(file);

% create timeseries
ts.acc_x = timeseries(xyz(:,1), time, 'Name', 'ACCX');
ts.acc_x.DataInfo.Unit = 'g';
ts.acc_x.TimeInfo.Units = 'days';
ts.acc_x.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

ts.acc_y = timeseries(xyz(:,2), time, 'Name', 'ACCY');
ts.acc_y.DataInfo.Unit = 'g';
ts.acc_y.TimeInfo.Units = 'days';
ts.acc_y.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

ts.acc_z = timeseries(xyz(:,3), time, 'Name', 'ACCZ');
ts.acc_z.DataInfo.Unit = 'g';
ts.acc_z.TimeInfo.Units = 'days';
ts.acc_z.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

ts.light = timeseries(light, time, 'Name', 'LIGHT');
ts.light.DataInfo.Unit = 'lux';
ts.light.TimeInfo.Units = 'days';
ts.light.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

ts.button = timeseries(button, time, 'Name', 'BUTTON');
ts.button.DataInfo.Unit = 'binary';
ts.button.TimeInfo.Units = 'days';
ts.button.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';
