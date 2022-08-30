
cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          25a_analysis numbers.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      18-AUG-2022
    // 	date last modified      18-AUG-2022
    //  algorithm task          Analyzing combined cancer dataset: (1) Numbers (dofile 25a) (2) Sites (dofile 25b) (3) ASIRs (dofile 25c) for 2016-2018 annual report
    //  status                  Completed
    //  objective               To have one dataset with cleaned and grouped 2018 data for inclusion in the 2016-2018 annual report.
    //  methods                 See 30_report cancer.do for detailed methods of each statistic

    ** General algorithm set-up
    version 17.0
    clear all
    macro drop _all
    set more off

    ** Initialising the STATA log and allow automatic page scrolling
    capture {
            program drop _all
    	drop _all
    	log close
    	}

    ** Set working directories: this is for DATASET and LOGFILE import and export
    ** DATASETS to encrypted SharePoint folder
    local datapath "X:/The University of the West Indies/DataGroup - repo_data/data_p117"
    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath X:/OneDrive - The University of the West Indies/repo_datagroup/repo_p117

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'/25a_analysis numbers.smcl", replace
** HEADER -----------------------------------------------------


***************************************************************************
* SECTION 1: NUMBERS 
*        (1.1) total number & number of multiple events
*        (1.2) DCOs
*    	 (1.3) tumours by age-group: 
*				NOTE: missing/unknown age (code 999) are 
*				to be included in the age group that has a median total if 
*			  	total number of unk age is small, i.e. 5 cases with unk age; 
*			  	if larger then they would be distributed amongst more than
*			  	one age groups with median totals (NS update on 14-Oct-2020)
****************************************************************************
 
** LOAD cancer incidence dataset INCLUDING DCOs
use "`datapath'\version09\3-output\2008_2013-2018_cancer_reportable_nonsurvival_deidentified" ,clear

** CASE variable
*drop case
gen case=1
label var case "cancer patient (tumour)"

** Analysis point to look for raised at cancer mtg on 25jan2022
//CHECK FOR BOD=CLINICAL AND TIME BETWEEN DOT AND DOD as KWG noticed alot of cases where pts sought medical attention late and seemed like an increase from previous yrs.

*************************************************
** (1.1) Total number of events & multiple events
*************************************************
count //6682
tab dxyr ,m
/*
  Diagnosis |
       Year |      Freq.     Percent        Cum.
------------+-----------------------------------
       2008 |        815       12.20       12.20
       2013 |        884       13.23       25.43
       2014 |        884       13.23       38.66
       2015 |      1,092       16.34       55.00
       2016 |      1,070       16.01       71.01
       2017 |        977       14.62       85.63
       2018 |        960       14.37      100.00
------------+-----------------------------------
      Total |      6,682      100.00
*/
tab patient dxyr ,m
/*
               |                                Diagnosis Year
cancer patient |      2008       2013       2014       2015       2016       2017       2018 |     Total
---------------+-----------------------------------------------------------------------------+----------
       patient |       808        868        865      1,070      1,034        959        934 |     6,538 
separate event |         7         16         19         22         36         18         26 |       144 
---------------+-----------------------------------------------------------------------------+----------
         Total |       815        884        884      1,092      1,070        977        960 |     6,682
*/

** JC updated AR's 2008 code for identifying MPs
tab ptrectot ,m
tab ptrectot patient ,m
tab ptrectot dxyr ,m

tab eidmp dxyr,m

duplicates list pid, nolabel sepby(pid) 
duplicates tag pid, gen(mppid_analysis)
sort pid cr5id
count if mppid_analysis>0 //282
//list pid topography morph ptrectot eidmp cr5id icd10 dxyr if mppid_analysis>0 ,sepby(pid)
drop mppid_analysis
** Of 6538 patients, 282 had >1 tumour

** note: remember to check in situ vs malignant from behaviour (beh)
tab beh ,m
/*
  Behaviour |      Freq.     Percent        Cum.
------------+-----------------------------------
  Malignant |      6,682      100.00      100.00
------------+-----------------------------------
      Total |      6,682      100.00
*/

** Breakdown of in-situ for SF (taken from dofile 20d_final clean before creation of nonreportable ds)
//tab beh dxyr ,m
/*
           |                                Diagnosis Year
 Behaviour |      2008       2013       2014       2015       2016       2017       2018 |     Total
-----------+-----------------------------------------------------------------------------+----------
    Benign |         8          0          0          0          0          0          0 |         8 
 Uncertain |        10          0          0          0          0          0          0 |        10 
   In situ |        83          9         24         19         38         33         35 |       241 
 Malignant |     1,057        901        901      1,101      1,075        979        964 |     6,978 
         . |         0          0          0          0         18         22         11 |        51 
-----------+-----------------------------------------------------------------------------+----------
     Total |     1,158        910        925      1,120      1,131      1,034      1,010 |     7,288
*/

*************************************************
** (1.2) DCOs - patients identified only at death
*************************************************
tab basis beh ,m
/*
                      | Behaviour
   Basis Of Diagnosis | Malignant |     Total
----------------------+-----------+----------
                  DCO |       469 |       469 
        Clinical only |       369 |       369 
Clinical Invest./Ult  |       359 |       359 
Lab test (biochem/imm |        97 |        97 
        Cytology/Haem |       204 |       204 
Hx of mets/Autopsy wi |       130 |       130 
Hx of primary/Autopsy |     4,837 |     4,837 
              Unknown |       217 |       217 
----------------------+-----------+----------
                Total |     6,682 |     6,682 
*/

tab basis dxyr ,m
/*
                      |                                Diagnosis Year
   Basis Of Diagnosis |      2008       2013       2014       2015       2016       2017       2018 |     Total
----------------------+-----------------------------------------------------------------------------+----------
                  DCO |        52         59         41        101         82         79         55 |       469 
        Clinical only |        16         21         38         67        101         83         43 |       369 
Clinical Invest./Ult  |        45         60         36         62         55         58         43 |       359 
Lab test (biochem/imm |         7          5         10         14         31         13         17 |        97 
        Cytology/Haem |        31         31         45         28         23         19         27 |       204 
Hx of mets/Autopsy wi |        24         16         13         19         13         24         21 |       130 
Hx of primary/Autopsy |       635        646        638        754        729        683        752 |     4,837 
              Unknown |         5         46         63         47         36         18          2 |       217 
----------------------+-----------------------------------------------------------------------------+----------
                Total |       815        884        884      1,092      1,070        977        960 |     6,682 
*/

tab basis dxyr if patient==1
/*
                      |                                Diagnosis Year
   Basis Of Diagnosis |      2008       2013       2014       2015       2016       2017       2018 |     Total
----------------------+-----------------------------------------------------------------------------+----------
                  DCO |        52         57         38        100         78         75         52 |       452 
        Clinical only |        16         20         36         67         99         82         41 |       361 
Clinical Invest./Ult  |        45         59         35         62         55         58         42 |       356 
Lab test (biochem/imm |         7          5         10         14         31         13         16 |        96 
        Cytology/Haem |        31         30         45         28         23         19         27 |       203 
Hx of mets/Autopsy wi |        24         16         13         19         13         24         21 |       130 
Hx of primary/Autopsy |       628        635        628        733        706        673        733 |     4,736 
              Unknown |         5         46         60         47         29         15          2 |       204 
----------------------+-----------------------------------------------------------------------------+----------
                Total |       808        868        865      1,070      1,034        959        934 |     6,538 
*/

//This section assesses DCO % in relation to tumour, patient and behaviour totals
**********
** 2018 **
**********
** As a percentage of all events: 5.73%
tab basis if dxyr==2018 ,m
/*
                     Basis Of Diagnosis |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                    DCO |         55        5.73        5.73
                          Clinical only |         43        4.48       10.21
Clinical Invest./Ult Sound/Exploratory  |         43        4.48       14.69
             Lab test (biochem/immuno.) |         17        1.77       16.46
                          Cytology/Haem |         27        2.81       19.27
     Hx of mets/Autopsy with Hx of mets |         21        2.19       21.46
Hx of primary/Autopsy with Hx of primar |        752       78.33       99.79
                                Unknown |          2        0.21      100.00
----------------------------------------+-----------------------------------
                                  Total |        960      100.00
*/

** As a percentage of all events with known basis: 5.74%
tab basis if dxyr==2018 & basis!=9
/*
                     Basis Of Diagnosis |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                    DCO |         55        5.74        5.74
                          Clinical only |         43        4.49       10.23
Clinical Invest./Ult Sound/Exploratory  |         43        4.49       14.72
             Lab test (biochem/immuno.) |         17        1.77       16.49
                          Cytology/Haem |         27        2.82       19.31
     Hx of mets/Autopsy with Hx of mets |         21        2.19       21.50
Hx of primary/Autopsy with Hx of primar |        752       78.50      100.00
----------------------------------------+-----------------------------------
                                  Total |        958      100.00
*/

** As a percentage of all patients: 5.57%
tab basis if dxyr==2018 & patient==1 ,m
/*
                     Basis Of Diagnosis |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                    DCO |         52        5.57        5.57
                          Clinical only |         41        4.39        9.96
Clinical Invest./Ult Sound/Exploratory  |         42        4.50       14.45
             Lab test (biochem/immuno.) |         16        1.71       16.17
                          Cytology/Haem |         27        2.89       19.06
     Hx of mets/Autopsy with Hx of mets |         21        2.25       21.31
Hx of primary/Autopsy with Hx of primar |        733       78.48       99.79
                                Unknown |          2        0.21      100.00
----------------------------------------+-----------------------------------
                                  Total |        934      100.00
*/

**********
** 2017 **
**********
** As a percentage of all events: 8.09%
tab basis if dxyr==2017 ,m
/*
                     Basis Of Diagnosis |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                    DCO |         79        8.09        8.09
                          Clinical only |         83        8.50       16.58
Clinical Invest./Ult Sound/Exploratory  |         58        5.94       22.52
             Lab test (biochem/immuno.) |         13        1.33       23.85
                          Cytology/Haem |         19        1.94       25.79
     Hx of mets/Autopsy with Hx of mets |         24        2.46       28.25
Hx of primary/Autopsy with Hx of primar |        683       69.91       98.16
                                Unknown |         18        1.84      100.00
----------------------------------------+-----------------------------------
                                  Total |        977      100.00
*/

** As a percentage of all events with known basis: 8.24%
tab basis if dxyr==2017 & basis!=9
/*
                     Basis Of Diagnosis |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                    DCO |         79        8.24        8.24
                          Clinical only |         83        8.65       16.89
Clinical Invest./Ult Sound/Exploratory  |         58        6.05       22.94
             Lab test (biochem/immuno.) |         13        1.36       24.30
                          Cytology/Haem |         19        1.98       26.28
     Hx of mets/Autopsy with Hx of mets |         24        2.50       28.78
Hx of primary/Autopsy with Hx of primar |        683       71.22      100.00
----------------------------------------+-----------------------------------
                                  Total |        959      100.00
*/

** As a percentage of all patients: 7.82%
tab basis if dxyr==2017 & patient==1 ,m
/*
                     Basis Of Diagnosis |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                    DCO |         75        7.82        7.82
                          Clinical only |         82        8.55       16.37
Clinical Invest./Ult Sound/Exploratory  |         58        6.05       22.42
             Lab test (biochem/immuno.) |         13        1.36       23.77
                          Cytology/Haem |         19        1.98       25.76
     Hx of mets/Autopsy with Hx of mets |         24        2.50       28.26
Hx of primary/Autopsy with Hx of primar |        673       70.18       98.44
                                Unknown |         15        1.56      100.00
----------------------------------------+-----------------------------------
                                  Total |        959      100.00
*/

**********
** 2016 **
**********
** As a percentage of all events: 7.66%
tab basis if dxyr==2016 ,m
/*
                     Basis Of Diagnosis |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                    DCO |         82        7.66        7.66
                          Clinical only |        101        9.44       17.10
Clinical Invest./Ult Sound/Exploratory  |         55        5.14       22.24
             Lab test (biochem/immuno.) |         31        2.90       25.14
                          Cytology/Haem |         23        2.15       27.29
     Hx of mets/Autopsy with Hx of mets |         13        1.21       28.50
Hx of primary/Autopsy with Hx of primar |        729       68.13       96.64
                                Unknown |         36        3.36      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,070      100.00
*/

** As a percentage of all events with known basis: 7.93%
tab basis if dxyr==2016 & basis!=9
/*
                     Basis Of Diagnosis |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                    DCO |         82        7.93        7.93
                          Clinical only |        101        9.77       17.70
Clinical Invest./Ult Sound/Exploratory  |         55        5.32       23.02
             Lab test (biochem/immuno.) |         31        3.00       26.02
                          Cytology/Haem |         23        2.22       28.24
     Hx of mets/Autopsy with Hx of mets |         13        1.26       29.50
Hx of primary/Autopsy with Hx of primar |        729       70.50      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,034      100.00
*/

** As a percentage of all patients: 7.54%
tab basis if dxyr==2016 & patient==1 ,m
/*
                     Basis Of Diagnosis |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                    DCO |         78        7.54        7.54
                          Clinical only |         99        9.57       17.12
Clinical Invest./Ult Sound/Exploratory  |         55        5.32       22.44
             Lab test (biochem/immuno.) |         31        3.00       25.44
                          Cytology/Haem |         23        2.22       27.66
     Hx of mets/Autopsy with Hx of mets |         13        1.26       28.92
Hx of primary/Autopsy with Hx of primar |        706       68.28       97.20
                                Unknown |         29        2.80      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,034      100.00
*/

**********
** 2015 **
**********
** As a percentage of all events: 9.25%
tab basis if dxyr==2015 ,m
/*
                     Basis Of Diagnosis |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                    DCO |        101        9.25        9.25
                          Clinical only |         67        6.14       15.38
Clinical Invest./Ult Sound/Exploratory  |         62        5.68       21.06
             Lab test (biochem/immuno.) |         14        1.28       22.34
                          Cytology/Haem |         28        2.56       24.91
     Hx of mets/Autopsy with Hx of mets |         19        1.74       26.65
Hx of primary/Autopsy with Hx of primar |        754       69.05       95.70
                                Unknown |         47        4.30      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,092      100.00
*/

** As a percentage of all events with known basis: 9.67%
tab basis if dxyr==2015 & basis!=9
/*
                     Basis Of Diagnosis |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                    DCO |        101        9.67        9.67
                          Clinical only |         67        6.41       16.08
Clinical Invest./Ult Sound/Exploratory  |         62        5.93       22.01
             Lab test (biochem/immuno.) |         14        1.34       23.35
                          Cytology/Haem |         28        2.68       26.03
     Hx of mets/Autopsy with Hx of mets |         19        1.82       27.85
Hx of primary/Autopsy with Hx of primar |        754       72.15      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,045      100.00
*/

** As a percentage of all patients: 9.35%
tab basis if dxyr==2015 & patient==1 ,m
/*
                     Basis Of Diagnosis |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                    DCO |        100        9.35        9.35
                          Clinical only |         67        6.26       15.61
Clinical Invest./Ult Sound/Exploratory  |         62        5.79       21.40
             Lab test (biochem/immuno.) |         14        1.31       22.71
                          Cytology/Haem |         28        2.62       25.33
     Hx of mets/Autopsy with Hx of mets |         19        1.78       27.10
Hx of primary/Autopsy with Hx of primar |        733       68.50       95.61
                                Unknown |         47        4.39      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,070      100.00
*/

**********
** 2014 **
**********
** As a percentage of all events: 4.64%
tab basis if dxyr==2014 ,m
/*
                     Basis Of Diagnosis |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                    DCO |         41        4.64        4.64
                          Clinical only |         38        4.30        8.94
Clinical Invest./Ult Sound/Exploratory  |         36        4.07       13.01
             Lab test (biochem/immuno.) |         10        1.13       14.14
                          Cytology/Haem |         45        5.09       19.23
     Hx of mets/Autopsy with Hx of mets |         13        1.47       20.70
Hx of primary/Autopsy with Hx of primar |        638       72.17       92.87
                                Unknown |         63        7.13      100.00
----------------------------------------+-----------------------------------
                                  Total |        884      100.00
*/

** As a percentage of all events with known basis: 4.99%
tab basis if dxyr==2014 & basis!=9
/*
                     Basis Of Diagnosis |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                    DCO |         41        4.99        4.99
                          Clinical only |         38        4.63        9.62
Clinical Invest./Ult Sound/Exploratory  |         36        4.38       14.01
             Lab test (biochem/immuno.) |         10        1.22       15.23
                          Cytology/Haem |         45        5.48       20.71
     Hx of mets/Autopsy with Hx of mets |         13        1.58       22.29
Hx of primary/Autopsy with Hx of primar |        638       77.71      100.00
----------------------------------------+-----------------------------------
                                  Total |        821      100.00
*/

** As a percentage of all patients: 4.39%
tab basis if dxyr==2014 & patient==1 ,m
/*
                     Basis Of Diagnosis |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                    DCO |         38        4.39        4.39
                          Clinical only |         36        4.16        8.55
Clinical Invest./Ult Sound/Exploratory  |         35        4.05       12.60
             Lab test (biochem/immuno.) |         10        1.16       13.76
                          Cytology/Haem |         45        5.20       18.96
     Hx of mets/Autopsy with Hx of mets |         13        1.50       20.46
Hx of primary/Autopsy with Hx of primar |        628       72.60       93.06
                                Unknown |         60        6.94      100.00
----------------------------------------+-----------------------------------
                                  Total |        865      100.00
*/

**********
** 2013 **
**********
** As a percentage of all events: 6.67%
tab basis if dxyr==2013 ,m
/*
                     Basis Of Diagnosis |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                    DCO |         59        6.67        6.67
                          Clinical only |         21        2.38        9.05
Clinical Invest./Ult Sound/Exploratory  |         60        6.79       15.84
             Lab test (biochem/immuno.) |          5        0.57       16.40
                          Cytology/Haem |         31        3.51       19.91
     Hx of mets/Autopsy with Hx of mets |         16        1.81       21.72
Hx of primary/Autopsy with Hx of primar |        646       73.08       94.80
                                Unknown |         46        5.20      100.00
----------------------------------------+-----------------------------------
                                  Total |        884      100.00
*/

** As a percentage of all events with known basis: 7.04%
tab basis if dxyr==2013 & basis!=9
/*
                     Basis Of Diagnosis |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                    DCO |         59        7.04        7.04
                          Clinical only |         21        2.51        9.55
Clinical Invest./Ult Sound/Exploratory  |         60        7.16       16.71
             Lab test (biochem/immuno.) |          5        0.60       17.30
                          Cytology/Haem |         31        3.70       21.00
     Hx of mets/Autopsy with Hx of mets |         16        1.91       22.91
Hx of primary/Autopsy with Hx of primar |        646       77.09      100.00
----------------------------------------+-----------------------------------
                                  Total |        838      100.00
*/

** As a percentage of all patients: 6.57%
tab basis if dxyr==2013 & patient==1 ,m
/*
                     Basis Of Diagnosis |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                    DCO |         57        6.57        6.57
                          Clinical only |         20        2.30        8.87
Clinical Invest./Ult Sound/Exploratory  |         59        6.80       15.67
             Lab test (biochem/immuno.) |          5        0.58       16.24
                          Cytology/Haem |         30        3.46       19.70
     Hx of mets/Autopsy with Hx of mets |         16        1.84       21.54
Hx of primary/Autopsy with Hx of primar |        635       73.16       94.70
                                Unknown |         46        5.30      100.00
----------------------------------------+-----------------------------------
                                  Total |        868      100.00
*/


** Analysis point to look for raised at cancer mtg on 25jan2022 (see 20d_final clean.do)
//CHECK FOR BOD=CLINICAL AND TIME BETWEEN DOT AND DOD as KWG noticed alot of cases where pts sought medical attention late and seemed like an increase from previous yrs.


** Remove 2008 cases as cumulative numbers for 2013-2018 are to be used in 2016-2018 annual report
drop if dxyr==2008 // deleted

count //

*************************
** Number of cases by sex
*************************
tab sex ,m

tab sex patient,m

** Mean age by sex overall (where sex: male=1, female=2)... BY TUMOUR
ameans age
ameans age if sex==1
ameans age if sex==2

 
** Mean age by sex overall (where sex: male=1, female=2)... BY PATIENT
preserve
keep if patient==1 //42 obs deleted
ameans age
ameans age if sex==1
ameans age if sex==2
restore
 
***********************************
** 1.4 Number of cases by age-group
***********************************
** Age labelling
gen age5 = recode(age,4,9,14,19,24,29,34,39,44,49,54,59,64,69,74,79,84,200)

recode age5 4=1 9=2 14=3 19=4 24=5 29=6 34=7 39=8 44=9 49=10 54=11 59=12 64=13 /// 
                        69=14 74=15 79=16 84=17 200=18

label define age5_lab 1 "0-4" 	 2 "5-9"    3 "10-14" ///
					  4 "15-19"  5 "20-24"  6 "25-29" ///
					  7 "30-34"  8 "35-39"  9 "40-44" ///
					 10 "45-49" 11 "50-54" 12 "55-59" ///
					 13 "60-64" 14 "65-69" 15 "70-74" ///
					 16 "75-79" 17 "80-84" 18 "85 & over", modify
label values age5 age5_lab
gen age_10 = recode(age5,3,5,7,9,11,13,15,17,200)
recode age_10 3=1 5=2 7=3 9=4 11=5 13=6 15=7 17=8 200=9

label define age_10_lab 1 "0-14"   2 "15-24"  3 "25-34" ///
                        4 "35-44"  5 "45-54"  6 "55-64" ///
                        7 "65-74"  8 "75-84"  9 "85 & over" , modify

label values age_10 age_10_lab

sort sex age_10

tab age_10 ,m

** Save this new dataset without population data
label data "2013-2018 BNR-Cancer analysed data - Numbers"
note: TS This dataset does NOT include population data 
save "`datapath'\version09\2-working\2013-2018_cancer_numbers", replace
