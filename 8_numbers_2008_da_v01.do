** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name        8_numbers_2008_da_v01.do
    //  project:              BNR
    //  analysts:             Jacqueline CAMPBELL
    //  date first created    16-APR-2019
    //  date last modified    16-APR-2019
    //  algorithm task        Generate numbers for (1) multiple events, (2) DCOs (3) tumours by month (4) tumours by parish
    //  status                Completed
    //  objectve              To have one dataset with cleaned, grouped and analysed 2008 data for 2014 cancer report.

    ** DO FILE BASED ON
    * AMC Rose code for BNR Cancer 2008 annual report

    ** General algorithm set-up
    version 15
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
    log using "`logpath'\8_numbers_2008_da_v01.smcl", replace
** HEADER -----------------------------------------------------


************************************************************************* 
* SECTION 1: NUMBERS 
*        (1.1) total number & number of multiple events
*        (1.2) DCOs
*        (1.3) tumours by month
*    	   (1.4) tumours by age-group
**************************************************************************
 
** LOAD cancer incidence dataset INCLUDING DCOs
use "`datapath'\version01\2-working\2008_2013_cancer_dc_v01" ,clear

count //2,054

** Only want to analyse 2008 cases
drop if dxyr!=2008 //845 deleted

count //1,209

** CASE variable
gen case=1
label var case "cancer patient (tumour)"
 
*************************************************
** (1.1) Total number of events & multiple events
*************************************************


tab patient ,m //1,209; 1,113 patients & 96 MPs
/*
cancer patient |      Freq.     Percent        Cum.
---------------+-----------------------------------
       patient |      1,113       92.06       92.06
separate event |         96        7.94      100.00
---------------+-----------------------------------
         Total |      1,209      100.00
*/

** JC updated AR's 2008 code for identifying MPs
** (see 2_section1.do for old code)
tab ptrectot ,m
tab ptrectot patient ,m
/*
                               ptrectot |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
               CR5 pt with single event |      1,113       92.06       92.06
            CR5 pt with multiple events |         96        7.94      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,209      100.00
*/

tab eidmp ,m
/*
     CR5 tumour |
         events |      Freq.     Percent        Cum.
----------------+-----------------------------------
  single tumour |      1,113       92.06       92.06
multiple tumour |         96        7.94      100.00
----------------+-----------------------------------
          Total |      1,209      100.00
*/

duplicates list pid, nolabel sepby(pid) 
duplicates tag pid, gen(mppid)
sort pid cr5id
count if mppid>0 //159
//list pid topography morph ptrectot eidmp cr5id icd10 if mppid>0 ,sepby(pid)
 
/* 
Of 1,113 patients, 63 pts had >1 tumour: 
    46 pts have 2 tumours (=1 MP)
    6 pts have 3 tumours (=2 MPs)
    8 pts have 4 tumours (=3 MPs)
    1 pt has 5 tumours (=4 MPs)
    2 pts have 6 tumours (=5 MPs)
MP=multiple primary/tumour
*/
** note: remember to check in situ vs malignant from behaviour (beh)
tab beh ,m // 1,944 malignant; 93 in-situ
/*
  Behaviour |      Freq.     Percent        Cum.
------------+-----------------------------------
     Benign |          8        0.66        0.66
  Uncertain |         10        0.83        1.49
    In situ |         84        6.95        8.44
  Malignant |      1,107       91.56      100.00
------------+-----------------------------------
      Total |      1,209      100.00
*/

*************************************************
** (1.2) DCOs - patients identified only at death
*************************************************
tab basis beh ,m
/*
     BasisOfDiagnosis |    Benign  Uncertain    In situ  Malignant |     Total
----------------------+--------------------------------------------+----------
                  DCO |         0          3          0         51 |        54 
        Clinical only |         0          0          1         23 |        24 
Clinical Invest./Ult  |         0          4          0         38 |        42 
Exploratory surg./aut |         0          1          0          7 |         8 
Lab test (biochem/imm |         0          0          0          6 |         6 
        Cytology/Haem |         0          0          2         30 |        32 
           Hx of mets |         0          0          0         23 |        23 
        Hx of primary |         8          2         81        924 |     1,015 
        Autopsy w/ Hx |         0          0          0          4 |         4 
              Unknown |         0          0          0          1 |         1 
----------------------+--------------------------------------------+----------
                Total |         8         10         84      1,107 |     1,209
*/

tab basis ,m
/*
          BasisOfDiagnosis |      Freq.     Percent        Cum.
---------------------------+-----------------------------------
                       DCO |         54        4.47        4.47
             Clinical only |         24        1.99        6.45
Clinical Invest./Ult Sound |         42        3.47        9.93
 Exploratory surg./autopsy |          8        0.66       10.59
Lab test (biochem/immuno.) |          6        0.50       11.08
             Cytology/Haem |         32        2.65       13.73
                Hx of mets |         23        1.90       15.63
             Hx of primary |      1,015       83.95       99.59
             Autopsy w/ Hx |          4        0.33       99.92
                   Unknown |          1        0.08      100.00
---------------------------+-----------------------------------
                     Total |      1,209      100.00
*/

** To match 2014 case definition (beh=3 and CIN 3 only) we need to adjust the % proportions - TO BE USED IN 2014 ANNUAL REPORT TABLE ES1.
preserve
drop if beh!=3 & siteiarc!=64 //68 deleted - 34 CIN 3
drop if siteiarc==25 // deleted

tab siteiarc ,m
tab sex ,m
/*
        Sex |      Freq.     Percent        Cum.
------------+-----------------------------------
       Male |        419       50.00       50.00
     Female |        419       50.00      100.00
------------+-----------------------------------
      Total |        838      100.00
*/
tab patient ,m
/*
cancer patient |      Freq.     Percent        Cum.
---------------+-----------------------------------
       patient |        829       98.93       98.93
separate event |          9        1.07      100.00
---------------+-----------------------------------
         Total |        838      100.00
*/
tab beh ,m
/*
  Behaviour |      Freq.     Percent        Cum.
------------+-----------------------------------
    In situ |         34        4.06        4.06
  Malignant |        804       95.94      100.00
------------+-----------------------------------
      Total |        838      100.00
*/
tab basis beh ,m
/*
                      |       Behaviour
     BasisOfDiagnosis |   In situ  Malignant |     Total
----------------------+----------------------+----------
                  DCO |         0         51 |        51 
        Clinical only |         0         13 |        13 
Clinical Invest./Ult  |         0         38 |        38 
Exploratory surg./aut |         0          7 |         7 
Lab test (biochem/imm |         0          6 |         6 
        Cytology/Haem |         2         30 |        32 
           Hx of mets |         0         23 |        23 
        Hx of primary |        32        631 |       663 
        Autopsy w/ Hx |         0          4 |         4 
              Unknown |         0          1 |         1 
----------------------+----------------------+----------
                Total |        34        804 |       838
*/
tab basis ,m
/*
          BasisOfDiagnosis |      Freq.     Percent        Cum.
---------------------------+-----------------------------------
                       DCO |         51        6.09        6.09
             Clinical only |         13        1.55        7.64
Clinical Invest./Ult Sound |         38        4.53       12.17
 Exploratory surg./autopsy |          7        0.84       13.01
Lab test (biochem/immuno.) |          6        0.72       13.72
             Cytology/Haem |         32        3.82       17.54
                Hx of mets |         23        2.74       20.29
             Hx of primary |        663       79.12       99.40
             Autopsy w/ Hx |          4        0.48       99.88
                   Unknown |          1        0.12      100.00
---------------------------+-----------------------------------
                     Total |        838      100.00
*/

** As a percentage of all events: 6.09%
cii proportions 838 51

** As a percentage of all events with known basis: 6.09%
cii proportions 837 51
 
** As a percentage of all patients: 6.15%
cii proportions 829 51

** As a percentage for all those which were non-malignant: 0%
cii proportions 34 0
 
** As a percentage of all malignant tumours: 6.34%
cii proportions 804 51 
restore


** As a percentage of all events: 4.47%
cii proportions 1209 54

** As a percentage of all events with known basis: 4.47%
cii proportions 1208 54
 
** As a percentage of all patients: 4.85%
cii proportions 1113 54

** As a percentage for all those which were non-malignant: 2.94%
cii proportions 102 3
 
** As a percentage of all malignant tumours: 4.61%
cii proportions 1107 51 

*************************************************
** (1.3) Tumours by month
*************************************************
** Number and % by month of onset
gen monset=0

label define monset_lab 1 "January" 2 "February" 3 "March" 4 "April" ///
						5 "May" 6 "June" 7 "July" 8 "August" 9 "September" ///
						10 "October" 11 "November" 12 "December" , modify
label values monset monset_lab                           

label var monset "Month of onset of event"
recode monset 0=. if  (dot==.)
replace monset=month(dot) if monset==0
replace dot=dod if monset==.
replace monset=month(dod) if monset==.

tab monset ,miss


*******************************************
* INFO. FOR FIRST KEY POINTS BOX
*******************************************
** average number of tumours per month - 100
display 1209/12 // 100.75

** average number of tumours; N=1209 - 101 per month

/* 
 skin cancers (C44*) of NON-GENITAL areas with a morphology of squamous cell carcinoma and/or
 basal cell carcinoma are not reportable according to 2009 BNR-C case definition
 Let's call these "non-melanoma skin cancers": NMSC
 Of note, 2013 data does not contain any NMSCs - only 3 melanomas
 Also, melanomas can have a topography of skin so changed up below code from
 original 2008 code which is kept here as a reference:
		gen skin=1 if regexm(icd, "^C44") | regexm(icd, "^D04")
 Will also disuse 2013 skin code as for 2014 we can use siteiarc variable to identify
 melanomas, below is code from 2013:
 gen skin=1 if regexm(top, "44") & (morph <8720 | morph >8790)

count if skin==1
replace skin=0 if skin==.
*/
tab skin ,m
/*
       skin |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |        303       25.06       25.06
          . |        906       74.94      100.00
------------+-----------------------------------
      Total |      1,209      100.00
*/

count if siteiarc==25 //303
/*
gen skin=1 if siteiarc==25
count if skin==1 //0 NMSCs
replace skin=0 if skin==.

tab skin ,m
*/

** number of events by month and sex
tab monset sex ,miss

tab monset sex , col 

** number of events by month and sex EXCLUDING NMSCs
tab monset sex if skin==0 ,miss
tab monset sex if skin==0 , col
tab monset if skin==0 ,m
tab monset if skin==1 ,m

** SEE 12_graphs_da.do for graphical display of cancer by month and sex

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
keep if patient==1 //15 obs deleted
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

****************************
** Number of cases by parish
****************************

** number of events by parish
tab parish ,m

** number of events by parish and sex
tab parish sex ,miss

tab parish sex , col 

** SEE 12_graphs_da.do for graphical display of cancer by parish and sex


** Save this new dataset without population data 
save "`datapath'\version01\2-working\2008_cancer_numbers_da_v01", replace
label data "2008 BNR-Cancer analysed data - Numbers"
note: TS This dataset does NOT include population data
