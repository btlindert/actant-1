# Sleep scoring algorithm for actigraphy

Copyright (C) 2013-2015, Bart te Lindert <b.te.lindert@nin.knaw.nl>

The original version of these sleep scripts have been used in `te Lindert & van Someren, 2013`. They were rewritten to a format
compatible with this `actant` toolbox. 

Currently, there are no validated algorithms that use raw 3D accelerometry to estimate sleep(stages). Most devices/algorithms reduce the data to counts. 
Therefore, the study's aim was to estimate Actiwatch-like activity counts from 3D accelerometry. This would allow applying the Actiwach/Oakley algorithm and extract the sleep features. 
 
In a nutshell the study did the following:
 - Simultaneously record 3D accelerometry and Actiwach counts.
 - Convert 3D data to counts based on the onboard processing of the Actiwatch.
  - Use only the palmar-dorsal axis (z-axis).
  - Bandpass filter (3-11 Hz).
  - Divide amplitude into 128 bins.
  - Remove residual baseline noise.
  - Set any negative values to 0.
 - The magnitude of 3D-derived counts was substantially smaller than the Actiwatch counts, so it was scaled by 3.07.
 - Apply the Actiwatch algorithm to both counts time series, extracted the sleep features and compared the results.

## Analysing data files

Files can be analysed individually using the graphical user interface or in a batch 
using batch scripts. A description of how to batch process files can be found [here](/batch/README.md) 

## Graphical user interface (gui)

To start the gui, run `actant.m`. An empty graphical user interface (GUI) will open.

## File conversion

For Matlab to be able to process data files efficiently, data needs to be stored in the `.mat` file format.
Therefore, any files that have another file extension than `.mat` need to be converted to `.mat` first.
This process can be very time consuming for large files, but fortunately only needs to be done once. If you have many files, use the batch scripts.

To convert a single file in the gui, open `File -> Convert dataset`.
Select the input (`.bin`) file and the output (`.mat`) file name and destination. You’ll get a message saying that conversion might take a while. Press `Ok` and wait.

## Loading data

Files that have been converted to `.mat` can be loaded by `File -> Open dataset`. The file is being loaded and the time series contained in the data file are displayed in the lower left window.
These time series can be plotted in the main window. To display a time series, in the `Show` column select `Main` in front of the time series that you wish to display and press `Update` (see Figure 1) .
You can use the additional options (Main, Top, Markup) in the ‘Show’ dropdown to plot multiple time series (Figure 2). The options `Plots`, `Days`, `Overlap`, `Main`, `Top` can be used to adjust 
the plot to e.g. double plots which are common in sleep research by centering the night (days = 2, overlap = 1).

![Main](/img/main.png "Main plot")

![Main and top](/img/maintop.png "Main and top plot")

## Sleep analysis

To estimate sleep parameters open `Sleep -> Sleep analysis`. A window will open that allows you to fill out a sleep diary (Figure 3). Fill out the sleep diary for the nights you're interested in. Press `Save`.
Select time series `ACCZ` or `ACT` by selecting the row number (usually 3 or 7) in the `Analysis` dropdown. The algorithm is only validated for these 2 time series (see te Lindert & van Someren 2013 for details). 
If you accidentally select a different time series that's incompatible with the algorithm, you'll get a warning. If you wish, you can adjust the algorithm parameters in the bottom middle window, although the 
default settings should be sufficient for most and press `Go`.
The estimated sleep parameters will be displayed in the lower right window. You’ll also see a counts (`ACT`) time series being added to the list of time series. To plot the actogram, select `Main` in 
front of the counts time series and update the plot. The bed times, sleep times, wake times, and out of bed times will be plotted with a line.

![Consensus sleep diary](/img/csd.png "Consensus sleep diary") 

## Estimated sleep variables

A description of each of the calculated sleep variables is given below. The actual formulas for calculating the sleep variables can be found at the end of the `actant_oakley.m` script. 


![Sleep variables](/img/sleepvars.png "Sleep variables") 

### CSD: In bed time
The time the subject gets into bed, as filled out in the consensus sleep diary. 
  
### CSD: Lights off time
The time the subject switches off the lights or starts to try to fall asleep, as filled out in the consensus sleep diary.

### CSD: Final wake time
The time the subject woke up, as filled out in the consensus sleep diary.
    
### CSD: Out of bed time
The time the subject got out of bed as filled out in the consensus sleep diary. 

### Time in bed
Time (in minutes) between `In bed time` and `Out of bed time`. 

### Sleep onset time
Time the subject fell asleep as calculated by the algorithm.

### Sleep onset latency (SOL)
Time (in minutes) between `Lights off time` and `Sleep onset time`, i.e. the time it took the subject to fall asleep.
    
### Final wake time
Time the subject woke up in the morning as calculated by the algorithm, if `SNOOZE = ON`. If `SNOOZE=OFF`, time is equal to `CSD: Final wake time`.

### Assumed sleep time
Time between `Sleep onset time` and `Final wake time`.
    
### Snooze time 1
Time between the calculated `Final wake time` and `CSD: Final wake time`.
    
### Snooze time 2
Time between the calculated `Final wake time` and `CSD: Out of bed time`.

### Wake after sleep onset (WASO)
The number of epochs scored as WAKE between `Sleep onset time` and `Final wake time` multiplied by the epoch length.    
An epoch is scored as `WAKE` if the weighted activity counts is greater than the wake threshold (set in the algorithm parameters).

### Actual sleep time
The number of epochs scored as `SLEEP` between 'Sleep onset time' and 'Final wake time' multiplied by the epoch length.
An epoch is scored as `SLEEP` if the weighted activity counts is equal to or less than the wake threshold (set in the algorithm parameters).

### Analysis period
Time between `CSD: Lights off time` and `CSD: Final wake time`.
    
### Sleep efficiency 1
The `Actual sleep time` divided by `Analysis period` multiplied by 100. 
    
### Sleep efficiency 2
The `Actual sleep time` divided by `Time in bed` multiplied by 100.

### Number of wake bouts
Number of continuous blocks, one or more epochs in duration, with each epoch of each block scored as `WAKE` 
in the `Assumed sleep time`.

### Mean wake bout time
The `Wake after sleep onset` divided by the `Number of wake bouts`.

### Number of sleep bouts
Number of continuous blocks, one or more epochs in duration, with each epoch of each block scored as `SLEEP` 
in the `Assumed sleep time`.
    
### Mean sleep bout time
The `Actual sleep time` divided by the `Number of sleep bouts`.

### Mobile time
Total duration of epochs with activity (>0) in the `Assumed sleep time` period.

### Immobile time
Total duration of epochs with no activity (=0) in the `Assumed sleep time` period.


## How do the calculated variables compare to other software?
The results are identical (or 1 epoch off) to recent versions of Respironics' Actiware. You can verify it yourself by analysing a `.awd` counts file using the Actiware software and these scripts and using the the same sleep diary.
Actiware has an automatic feature that automatically selects the major rest periods in the absence of sleep diaries. This is extremely handy, but I haven't been able to reproduce their results. If you have suggentions on how to estimate these, please let me know.

The results are usuallly slightly, but can be very, different for Cambridge Neurotechnology Ltd's Sleep Analysis software. First of all, it has no snooze option. But it also seems that they accept 2 instead of 1 mobile epochs in a 10 min window during the estimation of sleep onset, which can lead to very different results. 


## References

 - Oakley NR. "Validation with polysomnography of the Sleepwatch 
   sleep/wake scoring algorithm used by the Actiwatch activity 
   monitor system: Technical Report to Mini-Mitter Co., Inc., 1997.
    
 - Kushida CA, Chang A, Gadkary C, Guilleminault C, Carrillo O, Dement
   WC. "Comparison of actigraphic, polysomnographic, and subjective assessment
   of sleep parameters in sleep-disordered patients." Sleep Medicine
   2001; 2:389-96.

 - te Lindert BHW, Van Someren EJW. "Sleep estimates using microelectro-
   mechanical systems (MEMS)." SLEEP 2013;36(5):781-789


## Contributions

Authors would appreciate your contributions to the Actant project (code can
be found at https://github.com/maximosipov/actant). Also, you are invited
to contrubute your datasets to Physionet (http://www.physionet.org/). 