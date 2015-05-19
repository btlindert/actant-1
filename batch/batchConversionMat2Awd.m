function batchConversionMat2Awd()
% BATCH CONVERSION OF MAT FILES TO AWD FILES

% Converts all .mat files in a folder and converts them to .awd files.
% The z-axis timeseries of the mat files is read into matlab, converted to counts
% and written to a text file (.AWD).

% Specify input and output folder.
INPUT_FOLDER  = '/path/to/some/folder/with/mat/files';
OUTPUT_FOLDER = '/path/to/folder/to/store/awd/files';

% Create list of mat filenames the input folder.
matFiles = dir([INPUT_FOLDER '*.mat']);

% Loop through the list of filenames.
for iFile = 1:numel(matFiles)
    
    % Load z-axis data from mat file.
    load([INPUT_FOLDER matFiles(iFile).name], 'acc_z', 'header');
    
    % Convert data to counts.
    counts = awd(acc_z);
    
    %% Save file to output folder, using filename of input.
    % Header info.
    userID    = header{5,1}.Subject_Code; % can be any string
    startDate = datestr(counts.Time(1), 'dd-mmm-yyyy'); % needs dd-mmm-yyyy format
    startTime = datestr(counts.Time(1), 'HH:MM'); % needs HH:MM format
    age       = '99999'; %% can be any digit
    serial    = ['l' header{1,1}.Device_Unique_Serial_Code]; % needs 1 letter followed by numbers
    gender    = header{5,1}.Sex; % needs a string, not empty

    % Gender.
    if strcmpi(gender, 'male');
        gender = 'M';
    elseif strcmpi(gender, 'female');
        gender = 'F';
    else
        gender = 'X';
    end

    % Convert epoch length to number.
    epoch = datestr(counts.Time(2)-counts.Time(1), 'MM:SS');
    if strcmpi(epoch, '00:15')
        epochLength = 1;
    elseif strcmpi(epoch, '00:30')
        epochLength = 2;
    elseif strcmpi(epoch, '01:00')
        epochLength = 4;
    elseif strcmpi(epoch, '02:00')
        epochLength = 8;
    end

    % Open a file for writing.
    [~, fileName, ~] = fileparts(matFiles(iFile).name);
    fid = fopen([OUTPUT_FOLDER fileName '.AWD'], 'w');

    % Write headers to file.
    % For windows machines, '\r\n' can be replaced with '\n\n'.
    fprintf(fid, [userID '\r\n' ... 
        startDate '\r\n' ...
        startTime '\r\n' ...
        ' ' num2str(epochLength) ' \r\n' ... % needs space, number, space
        age '\r\n' ...
        serial '\r\n' ...
        gender '\r\n']);

    % Write counts to file.
    % One value appears on each row of the file
    for i = 1:numel(counts.Data)
        fprintf(fid, '%g , %4.2f\r\n', round(counts.Data(i)), 0); % needs 'CRLF' to mark end of line 
    end
    fclose(fid);
   
    % Clear variables.
    clearvars -except matFiles INPUT_FOLDER OUTPUT_FOLDER
    
end

end

%% Sub-function, conversion of accelerometry to counts
function act = awd(ts)

% get ts data
data = get(ts, 'Data');
time = get(ts, 'Time');

% assume increment in milliseconds
increment = str2double(datestr(time(2)-time(1), 'FFF'));

% sampling frequency
fs = fix((1/increment)*1000);

if isnan(fs)
    errordlg('Samplig rate is NaN!');
    return
end

% set filter specifications
cf_low = 3;               % lower cut off frequency (Hz)
cf_hi  = 11;              % high cut off frequency (Hz)
order  = 5;               % filter order
pass   = 'bandpass';      % filter type
w1     = cf_low/(fs/2);   % normalized frequency low
w2     = cf_hi/(fs/2);    % normalized frequency high
[b, a] = butter(order, [w1 w2], pass); 

% filter z data only
z_filt = filtfilt(b, a, data); 

% convert data to 128 bins between 0 and 5
z_filt = abs(z_filt);
topEdge = 5;
botEdge = 0; 
numBins = 128; 

binEdges = linspace(botEdge, topEdge, numBins+1);
[~, binned] = histc(z_filt, binEdges);

% convert to counts/epoch
epoch = 15;
counts = max2epochs(binned, fs, epoch);

% NOTE: Please be aware that the algorithm used here has only been
% validated for 15 sec epochs and 50 Hz raw accelerometery (palmar-dorsal
% z-axis data. The formula (1) used below
% is based on these settings. The longer the epoch, the higher the
% constant offset/residual noise will be(18 in this case). Sampling frequencies 
% will probably affect the constant offset less. However, due 
% to the band-pass of 3-11 Hz used above and human movement frequencies 
% of up to 10 Hz, a sampling of less than 30 Hz is not reliable.

% subtract constant offset and multiply with factor for distal location
counts = (counts-18).*3.07;                   % ---> formula (1)

% set any negative values to 0
indices = counts < 0;
counts(indices) = 0;

% create a new time series for the epoch data
timeNum = zeros(size(counts));
timeNum(1) = datenum(time(1));
for i = 2:numel(timeNum)
    timeNum(i) = datenum(addtodate(timeNum(i-1), 15, 'second'));
end

% create timeseries
act = timeseries(counts, 'Name', 'ACT');
act.DataInfo.Unit  = 'counts';
act.TimeInfo.Units = 'seconds';

% create a uniform timeseries based on the start time and the epoch duration
% make sure the TimeInfo.Units of ts1 has already been set to seconds 
act = set(act, 'Time', timeNum);

end