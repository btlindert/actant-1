function out = welch(xyz, args, args1, args2, args3, args4)
% WELCH 
%

% Arguments: 
%   xyz - 
%
% Results:
%   ts -   Cell array of timeseries containing acc_x, acc_y, acc_z
%
% Copyright (c) 2011-2014 Bart te Lindert
%
% See also:     Welch et al. Classification accuracy of the wrist-worn 
%               gravity estimator of normal everyday activity accelerometer. 
%               Med. Sci. Sports Exerc. 45(10) pp. 2012-2019, 2013.
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

% Esliger DW, Rowlands AV, Hurst TL, CattM, Murray P, Eston RG. Validation 
% of the GENEA accelerometer. Med Sci Sports Exerc. 2011;43(6):1085–93.
% 
% This study provide cut-off criteria for calssifying activity as
% sedentary, light, moderate or vigorous. However, the cut-offs were not 
% cross-validated.

% Welch et al. Classification accuracy of the wrist-worn gravity estimator 
% of normal everyday activity accelerometer. Med. Sci. Sports Exerc. 45(10)
% pp. 2012-2019, 2013.
%
% The authors cross-validated the cut-offs of Esliger et al. (2011). 
% Performance was worse than the 80% suggested by Esliger. After 
% cross-validation ~50-60% of activities was correctly classified.

% Zhang et al. Physcial activity classification using the GENEA wrist-worn 
% accelerometer. Med. Sci. Sports Exerc. 44 (4) pp. 742-748, 2012
%
% The authos do not report any specs of the classification or cut-offs for 
% the decision tree used to generate the results for this study. Data was 
% collected at 80 Hz and 55 out of 60 particpants were right-handed and 
% right hand data was used (i.e. activity of the dominant hand!).


%% do checks for input

x = ts.acc_x.Data;
y = ts.acc_y.Data;
z = ts.acc_z.Data;

xyz = [x', y', z'];

% First, calculate SVMgs using the genea software per 3 minutes
% per sample
svm   = sqrt(sum(xyz.^2, 2));
SVMgs = abs(svm - 1); % per sample, mean, no subtraction of g

% per second, multiply by 60 for 1-minute estimate
fs      = args{1};
seconds = floor(numel(SVMgs)/fs);
SVMgs   = reshape(SVMgs(1:seconds*fs), seconds, fs);
SVMgs   = mean(SVMgs, 1).*60;

% average 1-minute estimates per 3 minute interval
intervals = floor(numel(SVMgs)/180);
SVMgs     = reshape(SVMgs(1:intervals*180), intervals, 180);
activity  = mean(SVMgs, 1);

% use the following cut-offs
% sedentary = <217 counts/minute
% light     = 217-644 counts/minute
% moderate  = 645-1810 counts/minute
% vigorous  = >1810 counts/minute

out = NaN(size(activity));

out(activity < 217)                   = 0; % sedentary
out(activity >=217 && activity <645)  = 1; % light
out(activity >=645 && activity <1810) = 2; % moderate
out(activity >1810)                   = 3; % vigorous

end

