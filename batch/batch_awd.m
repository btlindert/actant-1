%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BAHAR BATCH SCRIPT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% specify path to folder here. This folder should contain 4 subfolders,
% called bin, mat, csd and txt.
%   - ./raw contains all the raw data files (bin, awd, aw5 etc.)
%   - ./mat will store mat files containing the time series
%   - ./csd contains all the sleep consensus diaries (according to supplied
%     format)
%   - ./txt will save all the sleep results from the every scd file
clear all
close all
clc

% subject IDs to include
SUBJECTS = [1 3 5 7 10 11 19 21 22 24 26];

% add path to actant
addpath(genpath('d:\tresorit\matlab\actant-2'));

% CHANGE THIS: data folder
datapath = 'd:\data\recordings\bahar';
%mkdir(datapath, 'mat');
%mkdir(datapath, 'txt');

addpath(genpath(datapath));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BATCH CONVERT ALL BIN FILES TO MAT FILES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create list of filenames in the .bin folder
raw_files = dir([datapath filesep 'raw' filesep '*.csv']);


for i = 1:numel(raw_files)
    % read variables from bin
    data = load_actiware(raw_files(i).name);
    
    act    = data.act;
    button = data.button;
    light  = data.light;
    
    % save file
    % specify filename/filepath
    fout = [datapath filesep 'mat' filesep raw_files(i).name(1:end-4) '.mat'];
    save(fout, 'act', 'button', 'light', '-v7.3');
   
    % scrap all for new round
    clearvars -except raw_files datapath
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BATCH PROCESS ALL MAT FILES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% specify algorithm properties
args1{1,1} = 'Algorithm';   args1{1, 2} = 'oakley';
args1{2,1} = 'Method';      args1{2, 2} = 'i';
args1{3,1} = 'Sensitivity'; args1{3, 2} = 'h';
args1{4,1} = 'Snooze';      args1{4, 2} = 'on';
args1{5,1} = 'Time window'; args1{5, 2} = 10; 

% create list with .mat files
mat_files = dir([datapath filesep 'mat' filesep '*.mat']);

% create list with sleep consensus diaries (.csv, COMMA seperated, not TAB or SEMICOLON) files
scd_files = dir([datapath filesep 'scd' filesep '*.csv']);

% check the number of files in the SCD folder, which will be limiting
% factor

% IMPORTANT NOTICE:here write regular expression to load all files with subject ID format of
% 4 digits; e.g. 0001 OR keep file names consistent.
% for now I assume that file 1 in the cds_files list, corresponds with file 1
% in the mat_files list. This works if both folders contain incremental
% numbering e.g. 0001.csv, 0002.csv,... and 0001.mat, 0002.mat,...


% loop through all files, loading the mat and csv file for each subject and
% then processing the data, and storing the results (output called vals) to
% a csv file

for file = 1:numel(scd_files)
    disp(num2str(file))
    % load only the acc_z variable from the data file
    load(mat_files(file).name, 'act')
  
    % load SCD file
    % this should be a .csv file (comma seperated) with 8 columns 
    % columns 1 (date), 3 (sleep onset) and 7 (out of bed) are used  
    fid = fopen(scd_files(file).name, 'r');
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
    [~, vals] = actant_oakley(act, args1, args2);
    
    % open file to write data to 
    fid = fopen([datapath filesep 'txt' filesep scd_files(file).name(1:end-4) '.txt'], 'w');
    
    % put in headers, all strings
    fprintf(fid, '%s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\n',...
        vals{:,1});
    
    % load columns from vals and store as rows in txt, both strings and numbers
    for i = 2:size(vals, 2)
        fprintf(fid, '%s\t %s\t %s\t %s\t %f\t %s\t %f\t %s\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\n',...
            vals{:,i});
    end
    fclose(fid);
    
    % clear workspace variable
    clear acc_z args2
    
end

% files 2, 9, 10, 17, 18, 19, 20 fail
%akg001_week6
%akg010_week1
%akg024_week1
% 2,9,19 miss values in scd 