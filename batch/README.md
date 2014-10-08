BATCH PROCESSING OF ACTIGRAPHY DATA

Actiwatch (.awd) and Geneactiv (.bin) files can be batch processed to extract sleep variables. 
Awd files need no further processing, but .bin files need to be converted to .mat files before they can be analysed. Conversion to .mat files only has to be performed once using 'batchConversion.m'. Subsequent analyses are done with the .mat files as input.
See batchBin.m and batchAwd.m for examples.

For the sleep variables to be estimated, the scoring algorithm needs sleep diaries in a specific format and saved to a csv file. The separator can be , or , but make sure you modify the batch file accordingly.

| Column | Format          | Requested data                                                     | Compulsory? |  
| :-----:| :-------------- | :----------------------------------------------------------------- | :---------: |    
| 1      | dd-mm-yyyy      | Date of the morning (after the reported night).                    | yes         | 
| 2      | HHMM            | What time did you get into bed?                                    | yes         |
| 3      | HHMM            | What time did you try to fall asleep?                              | yes         |
| 4      | integer minutes | How long did it take you to fall asleep?                           |             |
| 5      | integer         | How many times did you wake up, not counting your final awakening? |             |
| 6      | integer minutes | In total, how long did these awakenings last (minutes)?            |             |
| 7      | HHMM            | What time was your final awakening?                                | yes         |
| 8      | HHMM            | What time did you get out of bed for the day?                      | yes         |

So an example csv would look like this:

Date, inBedTime, lightsOffTime, sol, awakenings, awakeningsDuration, wakeTime, outOfBedTime     
16-10-2009, 2230, 2345,  45, 1,  30, 0700, 0730    

17-10-2009, 2330, 2355,  30, 1,  10, 0730, 0830    

18-10-2009, 2300, 2310, 240, 1, 255, 0800, 0830    

19-10-2009, 2330, 2340,  30, 2,  85, 0800, 0800    return 

20-10-2009, 2245, 2245,  30, 0,  30, 0800, 0830     

21-10-2009, 2315, 2320, 240, 0, 240, 0830, 0850    

22-10-2009, 2345, 0000, 120, 0, 120, 0830, 0845    
 
 