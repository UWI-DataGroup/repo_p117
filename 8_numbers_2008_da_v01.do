** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			8_numbers_2008_2013_da_v01.do
    //  project:				BNR
    //  analysts:				Jacqueline CAMPBELL
    //  date first created      16-APR-2019
    // 	date last modified	    16-APR-2019
    //  algorithm task			Generate numbers for (1) multiple events, (2) DCOs (3) tumours by month (4) tumours by parish
    //  status                  Completed
    //  objectve                To have one dataset with cleaned, grouped and analysed 2008 & 2013 data for 2014 cancer report.

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
    log using "`logpath'\8_numbers_2008_2013_da_v01.smcl", replace
** HEADER -----------------------------------------------------


************************************************************************* 
* SECTION 1: NUMBERS 
*        (1.1) total number & number of multiple events
*        (1.2) DCOs
*        (1.3) tumours by month
*    	 (1.4) tumours by age-group
**************************************************************************
 
** LOAD cancer incidence dataset INCLUDING DCOs
use "`datapath'\version01\2-working\2008_2013_cancer_dc_v01" ,clear


** CASE variable
gen case=1
label var case "cancer patient (tumour)"
 
*************************************************
** (1.1) Total number of events & multiple events
*************************************************
count //2,057

tab patient ,m //2,057; 1,947 patients & 110 MPs
/*
cancer patient |      Freq.     Percent        Cum.
---------------+-----------------------------------
       patient |      1,947       94.65       94.65
separate event |        110        5.35      100.00
---------------+-----------------------------------
         Total |      2,057      100.00
*/

** JC updated AR's 2008 code for identifying MPs
** (see 2_section1.do for old code)
tab ptrectot ,m
tab ptrectot patient ,m
/*

                               ptrectot |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
               CR5 pt with single event |      1,947       94.65       94.65
            CR5 pt with multiple events |        110        5.35      100.00
----------------------------------------+-----------------------------------
                                  Total |      2,057      100.00
*/

tab eidmp ,m

duplicates list pid, nolabel sepby(pid) 
duplicates tag pid, gen(mppid)
sort pid cr5id
count if mppid>0
//list pid topography morph ptrectot eidmp cr5id icd10 if mppid>0 ,sepby(pid)
 
/* 
Of 1,947 patients, 77 pts had >1 tumour: 
    60 pts have 2 tumours (=1 MP)
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
     Benign |          8        0.39        0.39
  Uncertain |         12        0.58        0.97
    In situ |         93        4.52        5.49
  Malignant |      1,944       94.51      100.00
------------+-----------------------------------
      Total |      2,057      100.00
*/

*************************************************
** (1.2) DCOs - patients identified only at death
*************************************************
tab basis beh ,m
/*
                       |                  Behaviour
     BasisOfDiagnosis |    Benign  Uncertain    In situ  Malignant |     Total
----------------------+--------------------------------------------+----------
                  DCO |         0          3          0         94 |        97 
        Clinical only |         0          0          1         41 |        42 
Clinical Invest./Ult  |         0          6          0         84 |        90 
Exploratory surg./aut |         0          1          0         18 |        19 
Lab test (biochem/imm |         0          0          0          6 |         6 
        Cytology/Haem |         0          0          2         60 |        62 
           Hx of mets |         0          0          0         37 |        37 
        Hx of primary |         8          2         90      1,570 |     1,670 
        Autopsy w/ Hx |         0          0          0          9 |         9 
              Unknown |         0          0          0         25 |        25 
----------------------+--------------------------------------------+----------
                Total |         8         12         93      1,944 |     2,057
*/

tab basis ,m
/*
          BasisOfDiagnosis |      Freq.     Percent        Cum.
---------------------------+-----------------------------------
                       DCO |         97        4.72        4.72
             Clinical only |         42        2.04        6.76
Clinical Invest./Ult Sound |         90        4.38       11.13
 Exploratory surg./autopsy |         19        0.92       12.06
Lab test (biochem/immuno.) |          6        0.29       12.35
             Cytology/Haem |         62        3.01       15.36
                Hx of mets |         37        1.80       17.16
             Hx of primary |      1,670       81.19       98.35
             Autopsy w/ Hx |          9        0.44       98.78
                   Unknown |         25        1.22      100.00
---------------------------+-----------------------------------
                     Total |      2,057      100.00
*/

** As a percentage of all events: 4.72%
cii proportions 2057 97

** As a percentage of all events with known basis: 4.77%
cii proportions 2032 97
 
** As a percentage of all patients: 4.98%
cii proportions 1947 97

** As a percentage for all those which were non-malignant: 2.65%
cii proportions 113 3
 
** As a percentage of all malignant tumours: 4.84%
cii proportions 1944 94 

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
display 2057/12 // 171.42

** average number of tumours; N=2057 - 172 per month

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
          1 |        304       14.78       14.78
          . |      1,753       85.22      100.00
------------+-----------------------------------
      Total |      2,057      100.00
*/

count if siteiarc==25 //304
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
save "`datapath'\version01\2-working\2008_2013_cancer_numbers_da_v01", replace
label data "2008 and 2013 BNR-Cancer analysed data - Numbers"
note: TS This dataset does NOT include population data
