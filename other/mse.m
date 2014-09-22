function [entropy, conf95] = mse(data, m, r, s, cb)
% MSE Calculate multi scale entropy using SampEn algorithm
%
% Description:
%   The function takes a column vector of data and calculates Multi-Scale
%   Entropy of order m, similarity r and for scales from the s vector.
%
% Arguments:
%   data - column vector with data
%   m - pattern length
%   r - similarity criteria (% of std)
%   s - scales vector
%   cb - callback function to be called after each scale processing
%
% Results:
%   entropy - vector with entropy (length of scales)
%
% See also SAMPEN.
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

    R = r*std(data);
    len_orig = length(data);
    entropy = zeros(1, length(s));
    conf95 = zeros(1, length(s));
    for i = 1:length(s),
        len_coarse = floor(len_orig/s(i));
        % coarse grain
        coarse = sum(reshape(...
            data(1:(len_orig-rem(len_orig,s(i)))),...
            s(i), len_coarse), 1)'./s(i);
        % calculate sample entropy
        [entropy(i), conf95(i)] = sampen(coarse, m, R);
        if exist('cb', 'var'),
            cb(length(s),i);
        end
    end
end
