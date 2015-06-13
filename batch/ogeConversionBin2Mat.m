function ogeConversionBin2Mat(filename)
% ogeConversionBin2Mat converts all files in the input folder in parallel 
% using Open Grid Engine on our server.

% Specify input and output folder.
INPUT_FOLDER  = '/path/to/some/folder/';
OUTPUT_FOLDER = '/path/to/some/other/folder';

% Force filename in char.
filename = char(filename);

% Specify path to sleep scoring scripts.
addpath(genpath('/data2/projects/btmn/scripts/actant/'));
    
% Read variables from bin file.
[header, time, xyz, light, button, prop_val] = read_bin(...
    strcat(INPUT_FOLDER, filename));

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
outputFile = [OUTPUT_FOLDER filename(1:end-4) '.mat'];
save(outputFile, 'acc_x', 'acc_y', 'acc_z', 'light',...
                 'temp', 'button', 'header', '-v7.3');
    
end