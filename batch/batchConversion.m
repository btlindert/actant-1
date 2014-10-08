% BATCH CONVERSION OF BIN FILES

% Converts all .bin files in a folder and converts them to .mat files.
% The timeseries of the bin files (xyz, light, temperature, light, button
% press) are read into matlab, converted to timeseries objects and stored 
% in a mat file. Conversion can take a long time depending on the specs of 
% your pc (processor speed, ram availability).

% Specify input and output folder.
INPUT_FOLDER  = 'path/to/some/folder/';
OUTPUT_FOLDER = 'path/to/some/other/folder/';

% Create list of bin filenames the input folder.
binFiles = dir([INPUT_FOLDER '*.bin']);

% Loop through the list of filenames.
for iFile = 1:numel(binFiles)
    
    % Read variables from bin file.
    [header, time, xyz, light, button, prop_val] = read_bin(binFiles(iFile).name);
    
    % Convert variables to timeseries objects.
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

    % Save file to output folder, using filename of input.
    outputFile = [OUTPUT_FOLDER binFiles(iFile).name(1:end-4) '.mat'];
    save(outputFile, 'acc_x', 'acc_y', 'acc_z', 'light',...
                     'temp', 'button', 'header', '-v7.3');
   
    % Clear variables.
    clearvars -except binFiles INPUT_FOLDER OUTPUT_FOLDER
    
end