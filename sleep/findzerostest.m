clear all; close all; clc;

vec = [0 0 0 0 0 0 1 1 1 0 0 0 1 1 0 1 1 0 0 0 0 0 1 0 0];
minlength = 3;
maxlength = 7;

% exclude all ones
pos = find(vec < 1);

% calculate diff between successive values
posDiff = diff([-1 pos]);

% onsets
onsets = pos(posDiff > 1);
numel(onsets)

% exclude all ones
pos = find(vec > 0);

% calculate diff between successive values
posDiff = diff([-1 pos]);

% onsets
offsets = pos(posDiff > 1);
numel(offsets)

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

% merge
new = [onsets' offsets' offsets'-onsets'];

% clear duration greater than maxlength
new(new(:,3) > maxlength, :) = [];

% clear duration less than minlength
new(new(:,3) < minlength, :) = [];


