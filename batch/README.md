BATCH PROCESSING OF ACTIGRAPHY DATA

Actiwatch (.awd) and Geneactiv (.bin) files can be batch processed to extract sleep variables. 
Awd files need no further processing, but .bin files need to be converted to .mat files before they can be analysed. Conversion to .mat files only has to be performed once using 'batchConversion.m'. Subsequent analyses are done with the .mat files as input.

See xx.m and xx.m for an example.

For the sleep variables to be estimated, the scoring algorithm needs sleep diaries in a specific format.

| 1| 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|——|—| 

Date ;What time did you get into bed?;What time did you try to fall asleep?;How long did it take you to fall asleep?;How many times did you wake up, not counting your final awakening?;In total, how long did these awakenings last (minutes)?;What time was your final awakening?;What time did you get out of bed for the day?
16-10-2009;2230;2345;45;1;30;0700;0730
17-10-2009;2330;2355;30;1;10;0730;0830
18-10-2009;2300;2310;240;1;255;0800;0830
19-10-2009;2330;2340;30;2;85;0800;0800
20-10-2009;2245;2245;30;0;30;0800;0830
21-10-2009;2315;2320;240;0;240;0830;0850
22-10-2009;2345;0000;120;0;120;0830;0845

Some notes on the sleep diary: 
- Columns 1,2,3,7 and 8 are compulsory, i.e. the date and all 4 times! If one of these is missing you’ll have to remove the entire row from the file and no sleep parameters will be calculated for that night. Or you can come up with a strategy to fill the missing data; e.g. make missing lights off times equal to reported bed times, or take the average of the other days, etc.
- The date refers to the date of the morning (after the night that is being reported).
- The date needs to be dd-mm-yyyy format.
- The times need to be in HHMM format.
- Columns 4,5,6 can be empty.
- The separator can be , or ; but make sure you modify the batch file accordingly.


Next, each actigraphy file needs to be matched with the corresponding sleep diary file. How you go about this is up to you, but if file naming has been consistent you can batch process all files at once.. In the batch files attached, the file names are assumed to be: 

ssmd_0001_actigraphy_week.mat
ssmd_0001_diary_week.csv


The example uses a single file to write all data to. Feel free to modify it to your needs.
 
 