%%% Batch processing of .mat (from geneactiv .bin) files
% In this example the files are assumed to be given consistent filenames:
% [projectId]_[subjectId]_[modality]_[session].[extension]
% i.e. for mat:
%   - xxxx_0001_actigraphy_week.awd
% and for the sleep diary:
%   - xxxx_0001_diray_week.csv

% Specify folders.
AWD_FOLDER    = 'path/to/the/mat/files/';
CSD_FOLDER    = 'path/to/the/sleep/diaries/';
OUTPUT_FOLDER = 'path/to/output/';

% Specify path to actant scripts.
addpath(genpath('path/to/actant/scripts/'));

% Specify algorithm properties.
settings{1,1} = 'Algorithm';   settings{1, 2} = 'oakley';
settings{2,1} = 'Method';      settings{2, 2} = 'i';
settings{3,1} = 'Sensitivity'; settings{3, 2} = 'm';
settings{4,1} = 'Snooze';      settings{4, 2} = 'on';
settings{5,1} = 'Time window'; settings{5, 2} = 10; 

% Specify subjects.
nSubjects = 1:10;

for iSubject = nSubjects
    
    % Load only the acc_z variable from the mat file.
    awdFile     = ['xxxx_' sprintf('%04.0f', iSubject) '_actigraphy_week.awd'];
    awdFilePath = [AWD_FOLDER awdFile];
    
    ts = load_actiwatch(awdFilePath);
    
    % Load consensus sleep diary file.
    csdFile     = ['xxxx_' sprintf('%04.0f', iSubject) '_diary_week.csv'];
    csdFilePath = [CSD_FOLDER csdFile];
    
    fid = fopen(csdFilePath, 'r');
    tmp = textscan(fid, '%s%s%s%s%s%s%s%s',...
                        'headerlines', 1,...
                        'delimiter', ','); %%%% CHANGE TO ; IF REQUIRED
    fclose(fid);
    
    % Reshape tmp to nDays-by-8 instead of tmp(1:8)(nDays-by-1)
    csdData = {};
    nDays   = numel(tmp{1});
    
    for iDay = 1:nDays
    
        for iColumn = 1:8
        
            csdData(iDay, iColumn) = tmp{iColumn}(iDay);
        
        end
        
    end
   
    % Pass acc_z, settings and csdData to the sleep scoring algorithm.
    [~, sleepScores] = actant_oakley(ts.act, settings, csdData);
    
    % Open file to write data to. 
    fid = fopen([OUTPUT_FOLDER 'xxxx_' sprintf('%04.0f', iSubject),...
                 '_sleepScores.txt'], 'w');
    
    % Put in the sleep variable headers first.
    fprintf(fid, '%s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\n',...
                  sleepScores{:,1});
    
    % Load columns from vals and store as rows in txt, both strings and numbers
    for iRow = 2:size(sleepScores, 2)
        
        fprintf(fid, '%s\t %s\t %s\t %s\t %f\t %s\t %f\t %s\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\n',...
                      sleepScores{:,iRow});
    
    end
    
    fclose(fid);
    
    % Clear variables.
    clear ts csdData
    
end
