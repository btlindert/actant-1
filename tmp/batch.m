%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEMO BATCH SCRIPT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% specify path to folder here. This folder should contain 4 subfolders,
% called bin, mat, csd and txt.
%   - /bin contains all the raw data files
%   - /mat will store all the converted mat files
%   - /csd contains all the sleep consensus diaries (according to supplied
%     format)
%   - /txt will save all the sleep results from the every scd file

% CHANGE: data folder
bin_filepath = 'G:/actant/';

cd(bin_filepath) 

addpath('./bin');
addpath('./mat');
addpath('./scd');
addpath('./txt');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BATCH CONVERT ALL BIN FILES TO MAT FILES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create list of filenames in the .bin folder
bin_files = dir('./bin/*.bin');


for i = 1:numel(bin_files)
    tic
    % read variables from bin
    [header, time, xyz, light, button, prop_val] = read_bin(bin_files(i).name);
    
    % convert variables to timeseries objects
    acc_x = timeseries(xyz(:,1), time, 'Name', 'ACCX');
    acc_x.DataInfo.Unit = 'g';
    acc_y = timeseries(xyz(:,2), time, 'Name', 'ACCY');
    acc_y.DataInfo.Unit = 'g';
    acc_z = timeseries(xyz(:,3), time, 'Name', 'ACCZ');
    acc_z.DataInfo.Unit = 'g';
    light = timeseries(light, time, 'Name', 'LIGHT');
    light.DataInfo.Unit = 'lux';
    temp = timeseries(prop_val(:,2), time, 'Name', 'TEMP');
    temp.DataInfo.Unit = 'degC';
    button = timeseries(button, time, 'Name', 'BUTTON');
    button.DataInfo.Unit = 'binary';

    % save file
    % specify filename/filepath
    fout = ['./mat/' bin_files(i).name(1:end-4) '.mat'];
    save(fout, 'acc_x', 'acc_y', 'acc_z', 'light',...
        'temp', 'button', 'header', '-v7.3');
   
    % clear memory for new round, keeping filenames and path
    clearvars -except bin_files bin_filepath
    toc
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BATCH PROCESS ALL MAT FILES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% specify algorithm properties
args1{1,1} = 'Algorithm';   args1{1, 2} = 'oakley';
args1{2,1} = 'Method';      args1{2, 2} = 'i';
args1{3,1} = 'Sensitivity'; args1{3, 2} = 'm';
args1{4,1} = 'Snooze';      args1{4, 2} = 'on';
args1{5,1} = 'Time window'; args1{5, 2} = 10; 

% create list with .mat files
mat_files = dir('./mat/*.mat');

% create list with sleep consensus diaries (.csv, COMMA seperated, not TAB or SEMICOLON) files
scd_files = dir('./scd/*.csv');

% check the number of files in the SCD folder, which will be limiting
% factor

% here write regular expression to load all files with subject ID format of
% 4 digits; e.g. 0001 OR keep file names consistent.
% for now I assume that file 1 the cds_files list, corresponds with file 1
% in the mat_files list. This works if both folders contain incremental
% numbering e.g. 0001.csv, 0002.csv,... and 0001.mat, 0002.mat,...


% loop through all files, loading the mat and csv file for each subject and
% then processing the data, and storing the results (output called vals) to
% a csv file

for day = 1:numel(scd_files)
    
    % load only the acc_z variable from the data file
    load(mat_files(day).name, 'acc_z')
    
    % load SCD file
    % this should be a .csv file (comma seperated) with 8 columns 
    % columns 1 (date), 3 (sleep onset) and 7 (out of bed) are used  
    fid = fopen(scd_files(day).name, 'r');
    tmp = textscan(fid, '%s%s%s%s%s%s%s%s',...
            'Headerlines', 1,...
            'Delimiter', ',');
    fclose(fid);
    
    args2 = {};

    % restructure cell to daysx8 instead of tmp(1:8)(daysx1)
    for ndays = 1:numel(tmp{1})
        for column = 1:8
            args2(ndays,column) = tmp{column}(ndays);
        end
    end
   
    % pass the acc_z, args1 and args2 to the algorithm
    [~, vals] = actant_oakley(acc_z, args1, args2);
    
    % open file to write data to 
    fid = fopen(['./txt/' scd_files(day).name(1:end-4) '.txt'], 'w');
    
    % write to faile all the headers, all strings
    fprintf(fid, '%s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %f\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\n',...
        vals{:,1});
    
    % load columns from vals and store as rows in txt, both strings and numbers
    for i = 2:size(vals, 2)
        fprintf(fid, '%s\t %s\t %s\t %s\t %f\t %s\t %f\t %s\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\n',...
            vals{:,i});
    end
    fclose(fid);
    
    % save workspace variable
    clear acc_z args1 args2
    
end