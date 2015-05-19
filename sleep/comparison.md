# How do the calculated variables from Actant compare to Actiware?

The results below are an example of how similar the results from `actant` are compared to `Respironics Actiware v6.0.4`.

`Actiware` uses automatic detection of rest periods, `actant` does not. However, in order to be able to compare the performance of the algorithm, the sleep diary/rest period input should be the same for both packages.
This can be accomplished in 2 ways. Either, the sleep diary of the participant is used to generate manual `Rest periods` in `Actiware` and the sleep diary in `actant`. Or the automatically estimated rest periods of `Actiware` are used as
input to the sleep diary in `actant`. For this example I randomly opted for the latter.

Below are variables calculated by `actant` (top of table) and `Respironics Actiware 6.0.4` (bottom of table). Only variables that are calculated by both software packages are shown.  
In `Actiware` the variables of interest are spread out across the `Rest`, `Sleep` and `Clinicians Report` tabs in the `Statistics table`. 

 
| CSD: Lights off time | CSD: Wake time     | Time in bed | Sleep onset time   | Sleep onset latency     | Final wake time    | Assumed sleep time | Wake after sleep onset | Actual sleep time | Sleep efficiency 2 | Number of wake bouts   |
|                      |                    | (min)       |                    | (min)                   |                    | (min)              | (min)                  | (min)             | (%)                |                        |
|:--------------------:|:------------------:|:-----------:|:------------------:|:-----------------------:|:------------------:|:------------------:|:----------------------:|:-----------------:|:------------------:|:----------------------:|
| 03-Mar-10 22:52:00   | 04-Mar-10 07:58:00	| 546	      | 03-Mar-10 22:57:00 | 5	                     | 04-Mar-10 07:58:00 |	541	               | 35	                    | 506	            | 92.67	             | 20                     |
| 04-Mar-10 23:41:00   | 05-Mar-10 05:58:00	| 377	      | 04-Mar-10 23:46:00 | 5	                     | 05-Mar-10 05:49:00 |	363	               | 30	                    | 334           	| 88.59	             | 18                     |
| 06-Mar-10 00:01:00   | 06-Mar-10 10:08:00	| 607	      | 06-Mar-10 00:01:00 | 0		                 | 06-Mar-10 10:08:00 |	607	               | 78	                    | 529               | 87.15	             | 41                     |
| 06-Mar-10 22:56:00   | 07-Mar-10 09:20:00	| 624	      | 06-Mar-10 23:04:00 | 8		                 | 07-Mar-10 09:19:00 |	615		           | 50	                    | 565	            | 90.54         	 | 34                     |
| 07-Mar-10 20:57:00   | 08-Mar-10 06:03:00	| 546	      | 07-Mar-10 21:03:00 | 6	                     | 08-Mar-10 06:03:00 |	540	               | 60	                    | 480	            | 87.91	             | 40                     |
| 08-Mar-10 21:09:00   | 09-Mar-10 06:03:00	| 534	      | 08-Mar-10 21:09:00 | 0	                     | 09-Mar-10 06:03:00 |	534		           | 64		                | 470	            | 88.01	             | 31                     |
| 09-Mar-10 21:48:00   | 10-Mar-10 06:02:00	| 494	      | 09-Mar-10 21:48:00 | 0	                     | 10-Mar-10 06:00:00 |	492	               | 50		                | 442	            | 89.47	             | 27                     |
| 10-Mar-10 22:04:00   | 11-Mar-10 09:05:00	| 661	      | 10-Mar-10 22:05:00 | 1	                     | 11-Mar-10 09:05:00 |	660		           | 72		                | 588	            | 88.96	             | 39                     |
| 11-Mar-10 21:47:00   | 12-Mar-10 08:23:00	| 636	      | 11-Mar-10 21:48:00 | 1	                     | 12-Mar-10 08:23:00 |	635		           | 3		                | 632	            | 99.37	             | 1                      |
|:--------------------:|:------------------:|:-----------:|:------------------:|:-----------------------:|:------------------:|:------------------:|:----------------------:|:-----------------:|:------------------:|:----------------------:|
| TAB - Rest           | TAB - Rest         | TAB - Rest  | TAB - Sleep        | TAB - Clinicians report | TAB - Sleep        | TAB - Sleep        | TAB - Sleep            | TAB - Sleep       | TAB - Sleep        | TAB - Clinicians Report|
| Start date & time    | End date & time    | Duration    | Start date & time  | Onset latency           | End date & time    | Duration           | Wake time              | Sleep time        | Efficiency         | #Awakenings            |								
|:--------------------:|:------------------:|:-----------:|:------------------:|:-----------------------:|:------------------:|:------------------:|:----------------------:|:-----------------:|:------------------:|:----------------------:|							
| 03-Mar-10 22:52:00   | 04-Mar-10 07:58:00	| 546	      | 03-Mar-10 22:57:00 | 5	                     | 04-Mar-10 07:57:00 |	540	               | 35		                | 505	            | 92.49	             | 20                     |
| 04-Mar-10 23:41:00   | 05-Mar-10 05:58:00	| 377	      | 04-Mar-10 23:46:00 | 5	                     | 05-Mar-10 05:49:00 |	363		           | 29		                | 334	            | 88.59	             | 18                     |
| 06-Mar-10 00:01:00   | 06-Mar-10 10:08:00	| 607	      | 06-Mar-10 00:01:00 | 0	                     | 06-Mar-10 09:55:00 |	594		           | 74		                | 520	            | 85.67	             | 40                     |
| 06-Mar-10 22:56:00   | 07-Mar-10 09:20:00	| 624	      | 06-Mar-10 23:04:00 | 8	                     | 07-Mar-10 09:19:00 |	615		           | 50		                | 565	            | 90.54	             | 34                     |
| 07-Mar-10 20:57:00   | 08-Mar-10 06:03:00	| 546	      | 07-Mar-10 21:03:00 | 6	                     | 08-Mar-10 06:02:00 |	539		           | 60		                | 479	            | 87.73	             | 40                     |
| 08-Mar-10 21:09:00   | 09-Mar-10 06:03:00	| 534	      | 08-Mar-10 21:09:00 | 0	                     | 09-Mar-10 06:02:00 |	533		           | 64		                | 469	            | 87.83	             | 31                     |
| 09-Mar-10 21:48:00   | 10-Mar-10 06:02:00	| 494	      | 09-Mar-10 21:48:00 | 0	                     | 10-Mar-10 06:00:00 |	492		           | 50		                | 442	            | 89.47	             | 27                     |
| 10-Mar-10 22:04:00   | 11-Mar-10 09:05:00	| 661	      | 10-Mar-10 22:04:00 | 0	                     | 11-Mar-10 09:04:00 |	660		           | 72		                | 588	            | 88.96	             | 39                     |
| 11-Mar-10 21:47:00   | 12-Mar-10 08:23:00	| 636	      | 11-Mar-10 21:47:00 | 0	                     | 12-Mar-10 08:22:00 |	635		           | 3		                | 632	            | 99.37	             | 1                      |

As you can see, the results are very similar but not identical. Unfortunately, we can't check the `Actiware` code to find the cause of these differences...

To reproduce these results, perform the following steps.

 1. Load the `example_actiwatch_file.awd` into `Respironics Actiware` and run an analysis in which the `Rest periods` are automatically generated. 
 2. Use `Start time` and `End time` in the `Rest` tab as columns 3 and 7 of the sleep diary in `actant` (see `example_sleep_diary.csv`).
 3. Run the algorithm in `actant` and using the same file and sleep diary.
 4. Compare the results. 