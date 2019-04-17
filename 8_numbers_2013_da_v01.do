** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name        8_numbers_2013_da_v01.do
    //  project:              BNR
    //  analysts:             Jacqueline CAMPBELL
    //  date first created    17-APR-2019
    //  date last modified    17-APR-2019
    //  algorithm task        Generate numbers for (1) multiple events, (2) DCOs (3) tumours by month (4) tumours by parish
    //  status                Completed
    //  objectve              To have one dataset with cleaned, grouped and analysed 2013 data for 2014 cancer report.

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
    log using "`logpath'\8_numbers_2013_da_v01.smcl", replace
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

** Only want to analyse 2013 cases
drop if dxyr!=2013 //1,209 deleted

count //845

** CASE variable
gen case=1
label var case "cancer patient (tumour)"
 
*************************************************
** (1.1) Total number of events & multiple events
*************************************************


tab patient ,m
/*
cancer patient |      Freq.     Percent        Cum.
---------------+-----------------------------------
       patient |        831       98.34       98.34
separate event |         14        1.66      100.00
---------------+-----------------------------------
         Total |        845      100.00
*/

** JC updated AR's 2008 code for identifying MPs
** (see 2_section1.do for old code)
tab ptrectot ,m
tab ptrectot patient ,m
/*
                               ptrectot |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
               CR5 pt with single event |        831       98.34       98.34
            CR5 pt with multiple events |         14        1.66      100.00
----------------------------------------+-----------------------------------
                                  Total |        845      100.00
*/

tab eidmp ,m
/*
     CR5 tumour |
         events |      Freq.     Percent        Cum.
----------------+-----------------------------------
  single tumour |        831       98.34       98.34
multiple tumour |         14        1.66      100.00
----------------+-----------------------------------
          Total |        845      100.00
*/

duplicates list pid, nolabel sepby(pid) 
duplicates tag pid, gen(mppid)
sort pid cr5id
count if mppid>0 //22
//list pid topography morph ptrectot eidmp cr5id icd10 if mppid>0 ,sepby(pid)
 
/* 
Of 831 patients, 11 pts had >1 tumour: 
    11 pts have 2 tumours (=1 MP)
MP=multiple primary/tumour
*/
** note: remember to check in situ vs malignant from behaviour (beh)
tab beh ,m
/*
  Behaviour |      Freq.     Percent        Cum.
------------+-----------------------------------
    In situ |          9        1.07        1.07
  Malignant |        836       98.93      100.00
------------+-----------------------------------
      Total |        845      100.00
*/

*************************************************
** (1.2) DCOs - patients identified only at death
*************************************************
tab basis beh ,m
/*
                      |       Behaviour
     BasisOfDiagnosis |   In situ  Malignant |     Total
----------------------+----------------------+----------
                  DCO |         0         43 |        43 
        Clinical only |         0         18 |        18 
Clinical Invest./Ult  |         0         46 |        46 
Exploratory surg./aut |         0         11 |        11 
        Cytology/Haem |         0         30 |        30 
           Hx of mets |         0         14 |        14 
        Hx of primary |         9        645 |       654 
        Autopsy w/ Hx |         0          5 |         5 
              Unknown |         0         24 |        24 
----------------------+----------------------+----------
                Total |         9        836 |       845
*/

tab basis ,m
/*
          BasisOfDiagnosis |      Freq.     Percent        Cum.
---------------------------+-----------------------------------
                       DCO |         43        5.09        5.09
             Clinical only |         18        2.13        7.22
Clinical Invest./Ult Sound |         46        5.44       12.66
 Exploratory surg./autopsy |         11        1.30       13.96
             Cytology/Haem |         30        3.55       17.51
                Hx of mets |         14        1.66       19.17
             Hx of primary |        654       77.40       96.57
             Autopsy w/ Hx |          5        0.59       97.16
                   Unknown |         24        2.84      100.00
---------------------------+-----------------------------------
                     Total |        845      100.00
*/

** As a percentage of all events: 5.10%
cii proportions 845 43

** As a percentage of all events with known basis: 5.24%
cii proportions 821 43
 
** As a percentage of all patients: 5.17%
cii proportions 831 43

** As a percentage for all those which were non-malignant: 0%
cii proportions 9 0
 
** As a percentage of all malignant tumours: 5.14%
cii proportions 836 43 

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
display 845/12 //70.42

** average number of tumours; N=845 - 71 per month

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
          1 |          1        0.12        0.12
          . |        847       99.88      100.00
------------+-----------------------------------
      Total |        848      100.00
*/

count if siteiarc==25 //1
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
save "`datapath'\version01\2-working\2013_cancer_numbers_da_v01", replace
label data "2013 BNR-Cancer analysed data - Numbers"
note: TS This dataset does NOT include population data
