clear all; close all; clc;

% napping variables
args1{2,2} = 15;
args1{3,2} = 180;
args1{4,2} = 'm';

% 
args2{1,1} = '20-07-11';
args2{1,2} = 1800;
args2{1,3} = '21-07-11';
args2{1,4} = 0800;

% run algorithm on example dataset
ts = load_actiwatch('D:\tresorit\data\001_622347-prox.awd');
act = ts.act;

tic
[dataWake times naps] = actant_nap(act, args1, args2);
toc

% for i = 1:size(naps,1)
%     [datestr(naps{i,1}) datestr(naps{i,2})];
% end
plot(act.Data);
hold on;

m = max(act.Data);
x = find(dataWake == 1);
y = ones(1, 1:numel(x));

plot(x, y*600, 'r+');

%bar(dataWake);
%hold on;

for i = 1:size(times,1)
    patch([times(i,1); times(i,1); times(i,2); times(i,2)], [0; 500; 500; 0], 'r');
    %plot([times(i,2) times(i,2)], [0, 2], 'm');
end
hold off
