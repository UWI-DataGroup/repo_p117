cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          20_analysis cancer.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL / Kern ROCKE
    //  date first created      02-DEC-2019
    // 	date last modified      02-OCT-2020
    //  algorithm task          Analyzing combined cancer dataset: (1) Numbers (2) ASIRs (3) Survival
    //  status                  Completed
    //  objective               To have one dataset with cleaned and grouped 2008, 2013, 2014 data for inclusion in 2015 cancer report.
    //  methods                 See 30_report cancer.do for detailed methods of each statistic

    ** General algorithm set-up
    version 16.0
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
    log using "`logpath'/20_analysis cancer.smcl", replace
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
use "`datapath'\version02\3-output\2008_2013_2014_2015_cancer_nonsurvival_bnr_reportable" ,clear

** CASE variable
*drop case
gen case=1
label var case "cancer patient (tumour)"
 
*************************************************
** (1.1) Total number of events & multiple events
*************************************************
count //3335; 3516; 4060
tab dxyr ,m
/*
DiagnosisYe |
         ar |      Freq.     Percent        Cum.
------------+-----------------------------------
       2008 |      1,217       29.98       29.98
       2013 |        883       21.75       51.72
       2014 |        898       22.12       73.84
       2015 |      1,062       26.16      100.00
------------+-----------------------------------
      Total |      4,060      100.00
*/
tab patient dxyr ,m //3909 patients & 151 MPs; 2015: 1038 patients & 24 MPs (Checked this)
/*
               |                DiagnosisYear
cancer patient |      2008       2013       2014       2015 |     Total
---------------+--------------------------------------------+----------
       patient |     1,122        869        880      1,038 |     3,909 
separate event |        95         14         18         24 |       151 
---------------+--------------------------------------------+----------
         Total |     1,217        883        898      1,062 |     4,060 
*/

** JC updated AR's 2008 code for identifying MPs
tab ptrectot ,m
tab ptrectot patient ,m
tab ptrectot dxyr ,m

tab eidmp dxyr,m

duplicates list pid, nolabel sepby(pid) 
duplicates tag pid, gen(mppid_analysis)
sort pid cr5id
count if mppid_analysis>0 //115; 119; 281
//list pid topography morph ptrectot eidmp cr5id icd10 dxyr if mppid_analysis>0 ,sepby(pid)
 
** Of 3909 patients, 151 had >1 tumour

** note: remember to check in situ vs malignant from behaviour (beh)
tab beh ,m // 3908 malignant; 134 in-situ; 18 uncertain/benign
/*
  Behaviour |      Freq.     Percent        Cum.
------------+-----------------------------------
     Benign |          8        0.20        0.20
  Uncertain |         10        0.25        0.44
    In situ |        134        3.30        3.74
  Malignant |      3,908       96.26      100.00
------------+-----------------------------------
      Total |      4,060      100.00
*/

*************************************************
** (1.2) DCOs - patients identified only at death
*************************************************
tab basis beh ,m
/*
                      |                  Behaviour
     BasisOfDiagnosis |    Benign  Uncertain    In situ  Malignant |     Total
----------------------+--------------------------------------------+----------
                  DCO |         0          3          0        269 |       272 
        Clinical only |         0          0          1        126 |       127 
Clinical Invest./Ult  |         0          4          0        153 |       157 
Exploratory surg./aut |         0          1          0         27 |        28 
Lab test (biochem/imm |         0          0          0         15 |        15 
        Cytology/Haem |         0          0          3        134 |       137 
           Hx of mets |         0          0          0         70 |        70 
        Hx of primary |         8          2        130      2,965 |     3,105 
        Autopsy w/ Hx |         0          0          0         23 |        23 
              Unknown |         0          0          0        126 |       126 
----------------------+--------------------------------------------+----------
                Total |         8         10        134      3,908 |     4,060 
*/

tab basis dxyr ,m
/*

                      |                DiagnosisYear
     BasisOfDiagnosis |      2008       2013       2014       2015 |     Total
----------------------+--------------------------------------------+----------
                  DCO |        51         43         38         13 |       145 
        Clinical only |        16         18         35         37 |       106 
Clinical Invest./Ult  |        38         50         29         32 |       149 
Exploratory surg./aut |         7          9          5          5 |        26 
Lab test (biochem/imm |         6          3          3          3 |        15 
        Cytology/Haem |        31         30         43         27 |       131 
           Hx of mets |        24         13         13         18 |        68 
        Hx of primary |       629        582        613        734 |     2,558 
        Autopsy w/ Hx |         4          6          9          4 |        23 
              Unknown |         1         43         52         19 |       115 
----------------------+--------------------------------------------+----------
                Total |       807        797        840        892 |     3,336
//total for hx of prim changed after I ran the dofile a 2nd time after running 15_clean cancer.do
                      |                DiagnosisYear
     BasisOfDiagnosis |      2008       2013       2014       2015 |     Total
----------------------+--------------------------------------------+----------
                  DCO |        55         43         40        134 |       272 
        Clinical only |        27         20         38         42 |       127 
Clinical Invest./Ult  |        42         50         29         36 |       157 
Exploratory surg./aut |         8         10          5          5 |        28 
Lab test (biochem/imm |         6          3          3          3 |        15 
        Cytology/Haem |        34         31         44         28 |       137 
           Hx of mets |        24         14         14         18 |        70 
        Hx of primary |     1,015        662        661        767 |     3,105 
        Autopsy w/ Hx |         4          6          9          4 |        23 
              Unknown |         2         44         55         25 |       126 
----------------------+--------------------------------------------+----------
                Total |     1,217        883        898      1,062 |     4,060
*/
/* JC 03mar20 checked to see if any duplicated observations occurred but no, seems like a legitimate new prostate case
preserve
drop if dxyr!=2015 & siteiarc!=39
sort pid cr5id
quietly by pid cr5id :  gen duppidcr5id = cond(_N==1,0,_n)
sort pid cr5id
count if duppidcr5id>0 //0
list pid cr5id deathid eidmp ptrectot primarysite duppidcr5id if duppidcr5id>0
restore
*/
tab basis dxyr if patient==1
/*
                      |                DiagnosisYear
     BasisOfDiagnosis |      2008       2013       2014       2015 |     Total
----------------------+--------------------------------------------+----------
                  DCO |        51         43         35         12 |       141 
        Clinical only |        16         18         33         37 |       104 
Clinical Invest./Ult  |        38         49         28         31 |       146 
Exploratory surg./aut |         7          9          5          5 |        26 
Lab test (biochem/imm |         6          3          3          3 |        15 
        Cytology/Haem |        31         29         43         27 |       130 
           Hx of mets |        24         13         13         18 |        68 
        Hx of primary |       622        572        604        716 |     2,514 
        Autopsy w/ Hx |         4          6          9          4 |        23 
              Unknown |         1         43         50         19 |       113 
----------------------+--------------------------------------------+----------
                Total |       800        785        823        872 |     3,280 

Re-ran dofiles 5 and 15 as switched non-reportable vs reportable datasets
                      |                DiagnosisYear
     BasisOfDiagnosis |      2008       2013       2014       2015 |     Total
----------------------+--------------------------------------------+----------
                  DCO |        55         43         37        132 |       267 
        Clinical only |        19         20         36         41 |       116 
Clinical Invest./Ult  |        42         49         28         35 |       154 
Exploratory surg./aut |         8         10          5          5 |        28 
Lab test (biochem/imm |         6          3          3          3 |        15 
        Cytology/Haem |        34         30         44         28 |       136 
           Hx of mets |        24         14         14         18 |        70 
        Hx of primary |       928        650        651        747 |     2,976 
        Autopsy w/ Hx |         4          6          9          4 |        23 
              Unknown |         2         44         53         25 |       124 
----------------------+--------------------------------------------+----------
                Total |     1,122        869        880      1,038 |     3,909
*/

//This section assesses DCO % in relation to tumour, patient and behaviour totals
**********
** 2015 **
**********
** As a percentage of all events: 12.62%
cii proportions 1062 134

** As a percentage of all events with known basis: 12.92%
cii proportions 1037 134

** As a percentage of all patients: 12.72%
cii proportions 1038 132

tab basis beh if dxyr==2015 ,m
/*
                      |       Behaviour
     BasisOfDiagnosis |   In situ  Malignant |     Total
----------------------+----------------------+----------
                  DCO |         0        134 |       134 
        Clinical only |         0         42 |        42 
Clinical Invest./Ult  |         0         36 |        36 
Exploratory surg./aut |         0          5 |         5 
Lab test (biochem/imm |         0          3 |         3 
        Cytology/Haem |         0         28 |        28 
           Hx of mets |         0         18 |        18 
        Hx of primary |        18        749 |       767 
        Autopsy w/ Hx |         0          4 |         4 
              Unknown |         0         25 |        25 
----------------------+----------------------+----------
                Total |        18      1,044 |     1,062
*/
** As a percentage for all those which were non-malignant: 0%
cii proportions 18 0
 
** As a percentage of all malignant tumours: 12.84%
cii proportions 1044 134

**********
** 2014 **
**********
** As a percentage of all events: 4.45%
cii proportions 898 40

** As a percentage of all events with known basis: 4.74%
cii proportions 843 40
 
** As a percentage of all patients: 4.20%
cii proportions 880 37

tab basis beh if dxyr==2014 ,m
/*
                      |       Behaviour
     BasisOfDiagnosis |   In situ  Malignant |     Total
----------------------+----------------------+----------
                  DCO |         0         40 |        40 
        Clinical only |         0         38 |        38 
Clinical Invest./Ult  |         0         29 |        29 
Exploratory surg./aut |         0          5 |         5 
Lab test (biochem/imm |         0          3 |         3 
        Cytology/Haem |         1         43 |        44 
           Hx of mets |         0         14 |        14 
        Hx of primary |        23        638 |       661 
        Autopsy w/ Hx |         0          9 |         9 
              Unknown |         0         55 |        55 
----------------------+----------------------+----------
                Total |        24        874 |       898
*/
** As a percentage for all those which were non-malignant: 0%
cii proportions 23 0
 
** As a percentage of all malignant tumours: 4.58%
cii proportions 874 40

**********
** 2013 **
**********
** As a percentage of all events: 4.87%
cii proportions 883 43

** As a percentage of all events with known basis: 5.13%
cii proportions 839 43
 
** As a percentage of all patients: 4.95%
cii proportions 869 43

tab basis beh if dxyr==2013 ,m
/*
                      |       Behaviour
     BasisOfDiagnosis |   In situ  Malignant |     Total
----------------------+----------------------+----------
                  DCO |         0         43 |        43 
        Clinical only |         0         20 |        20 
Clinical Invest./Ult  |         0         50 |        50 
Exploratory surg./aut |         0         10 |        10 
Lab test (biochem/imm |         0          3 |         3 
        Cytology/Haem |         0         31 |        31 
           Hx of mets |         0         14 |        14 
        Hx of primary |         9        653 |       662 
        Autopsy w/ Hx |         0          6 |         6 
              Unknown |         0         44 |        44 
----------------------+----------------------+----------
                Total |         9        874 |       883
*/
** As a percentage for all those which were non-malignant: 0%
cii proportions 9 0
 
** As a percentage of all malignant tumours: 4.92%
cii proportions 874 43

**********
** 2008 **
**********
** As a percentage of all events: 4.52%
cii proportions 1217 55

** As a percentage of all events with known basis: 4.53%
cii proportions 1215 55
 
** As a percentage of all patients: 4.90%
cii proportions 1122 55

tab basis beh if dxyr==2008 ,m
/*
                      |                  Behaviour
     BasisOfDiagnosis |    Benign  Uncertain    In situ  Malignant |     Total
----------------------+--------------------------------------------+----------
                  DCO |         0          3          0         52 |        55 
        Clinical only |         0          0          1         26 |        27 
Clinical Invest./Ult  |         0          4          0         38 |        42 
Exploratory surg./aut |         0          1          0          7 |         8 
Lab test (biochem/imm |         0          0          0          6 |         6 
        Cytology/Haem |         0          0          2         32 |        34 
           Hx of mets |         0          0          0         24 |        24 
        Hx of primary |         8          2         80        925 |     1,015 
        Autopsy w/ Hx |         0          0          0          4 |         4 
              Unknown |         0          0          0          2 |         2 
----------------------+--------------------------------------------+----------
                Total |         8         10         83      1,116 |     1,217
*/
** As a percentage for all those which were non-malignant: 2.97%
cii proportions 101 3
 
** As a percentage of all malignant tumours: 4.66%
cii proportions 1116 52


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
*/
** Save this new dataset without population data
label data "2008-2015 BNR-Cancer analysed data - Numbers"
note: TS This dataset does NOT include population data 
save "`datapath'\version02\2-working\2008_2013_2014_2015_cancer_numbers", replace

*******************************************************************************************************************
* *********************************************
* ANALYSIS: SECTION 3 - cancer sites
* Covering:
*  3.1  Classification of cancer by site
*  3.2 	ASIRs by site; overall, men and women
* *********************************************
** NOTE: bb popn and WHO popn data prepared by IH are ALL coded M=2 and F=1
** Above note by AR from 2008 dofile

** Load the dataset
use "`datapath'\version02\2-working\2008_2013_2014_2015_cancer_numbers", clear

****************************************************************************** 2015 ****************************************************************************************
drop if dxyr!=2015 //2998 deleted
count //

***********************
** 3.1 CANCERS BY SITE
***********************
tab icd10 if beh<3 ,m //18 in-situ

tab icd10 ,m //0 missing

tab siteiarc ,m //0 missing

tab sex ,m

** Note: O&U, NMSCs (non-reportable skin cancers) and in-situ tumours excluded from top ten analysis
tab siteiarc if siteiarc!=25 & siteiarc!=64
tab siteiarc ,m //1044 - 18 in-situ; 38 O&U [check this - the last bit]
tab siteiarc patient

** NS decided on 18march2019 to use IARC site groupings so variable siteiarc will be used instead of sitear
** IARC site variable created based on CI5-XI incidence classifications (see chapter 3 Table 3.1. of that volume) based on icd10
display `"{browse "http://ci5.iarc.fr/CI5-XI/Pages/Chapter3.aspx":IARC-CI5-XI-3}"'


** For annual report - Section 1: Incidence - Table 2a
** Below top 10 code added by JC for 2015
** All sites excl. in-situ, O&U, non-reportable skin cancers
** THIS USED IN ANNUAL REPORT TABLE 1
preserve
drop if siteiarc==25 | siteiarc>60 //56 deleted
tab siteiarc ,m
bysort siteiarc: gen n=_N
bysort n siteiarc: gen tag=(_n==1)
replace tag = sum(tag)
sum tag , meanonly
gen top10 = (tag>=(`r(max)'-9))
sum n if tag==(`r(max)'-9), meanonly
replace top10 = 1 if n==`r(max)'
tab siteiarc top10 if top10!=0
contract siteiarc top10 if top10!=0, freq(count) percent(percentage)
summ
describe
gsort -count
drop top10
/*
siteiarc									count	percentage
Breast (C50)								182		27.00
Prostate (C61)								180		26.71
Colon (C18)									 98		14.54
Rectum (C19-20)								 43		6.38
Corpus uteri (C54)							 42		6.23
Stomach (C16)								 28		4.15
Lung (incl. trachea and bronchus) (C33-34)	 24		3.56
Non-Hodgkin lymphoma (C82-86,C96)			 23		3.41
Multiple myeloma (C90)						 22		3.26
Kidney (C64)								 16		2.37
Ovary (C56)									 16		2.37

siteiarc									count	percentage
Prostate (C61)								219		28.33
Breast (C50)								200		25.87
Colon (C18)									115		14.88
Rectum (C19-20)								 48		 6.21
Corpus uteri (C54)							 44		 5.69
Stomach (C16)								 36		 4.66
Lung (incl. trachea and bronchus) (C33-34)	 30		 3.88
Multiple myeloma (C90)						 28		 3.62
Non-Hodgkin lymphoma (C82-86,C96)			 27		 3.49
Pancreas (C25)								 26		 3.36
*/
total count //773
restore

labelbook sex_lab
tab sex ,m

** For annual report - Section 1: Incidence - Table 1
** FEMALE - using IARC's site groupings (excl. in-situ)
preserve
drop if sex==2 //496 deleted
drop if siteiarc>60 //39 deleted
bysort siteiarc: gen n=_N
bysort n siteiarc: gen tag5=(_n==1)
replace tag5 = sum(tag5)
sum tag5 , meanonly
gen top5 = (tag5>=(`r(max)'-4))
sum n if tag5==(`r(max)'-4), meanonly
replace top5 = 1 if n==`r(max)'
gsort -top5
tab siteiarc top5 if top5!=0
contract siteiarc top5 if top5!=0, freq(count) percent(percentage)
gsort -count
drop top5

gen totpercent=(count/566)*100 //all cancers excl. male(496)
gen alltotpercent=(count/1062)*100 //all cancers
/*
siteiarc			count	percentage	totpercent	alltotpercent
Breast (C50)		181		58.96		38.42887	20.31425
Colon (C18)			 44		14.33		9.341825	4.938272
Corpus uteri (C54)	 42		13.68		8.917197	4.713805
Rectum (C19-20)		 24		7.82		5.095541	2.693603
Ovary (C56)			 16		5.21		3.397027	1.795735

siteiarc				count	percentage	totpercent	alltotpercent
Breast (C50)			199		57.85		35.15901	18.73823
Colon (C18)				 54		15.70		 9.540636	5.084746
Corpus uteri (C54)		 44		12.79		 7.773851	4.143126
Rectum (C19-20)			 26		 7.56		 4.593639	2.448211
Multiple myeloma (C90)	 21		 6.10		 3.710247	1.977401
*/
total count //344
restore

** For annual report - Section 1: Incidence - Table 1
** Below top 5 code added by JC for 2015
** MALE - using IARC's site groupings
preserve
drop if sex==1 //566 deleted
drop if siteiarc==25 | siteiarc>60 //17 deleted
bysort siteiarc: gen n=_N
bysort n siteiarc: gen tag5=(_n==1)
replace tag5 = sum(tag5)
sum tag5 , meanonly
gen top5 = (tag5>=(`r(max)'-4))
sum n if tag5==(`r(max)'-4), meanonly
replace top5 = 1 if n==`r(max)'
gsort -top5
tab siteiarc top5 if top5!=0
contract siteiarc top5 if top5!=0, freq(count) percent(percentage)
gsort -count
drop top5

gen totpercent=(count/496)*100 //all cancers excl. female(566)
gen alltotpercent=(count/1062)*100 //all cancers
/*
siteiarc									count	percentage	totpercent	alltotpercent
Prostate (C61)								180		63.60		42.75534	20.17937
Colon (C18)									 54		19.08		12.8266		 6.053812
Rectum (C19-20)								 19		6.71		4.513064	 2.130045
Lung (incl. trachea and bronchus) (C33-34)	 16		5.65		3.800475	 1.793722
Stomach (C16)								 14		4.95		3.325416	 1.569507

siteiarc									count	percentage	totpercent	alltotpercent
Prostate (C61)								219		64.41		44.15322	20.62147
Colon (C18)									 61		17.94		12.29839	 5.743879
Rectum (C19-20)								 22		 6.47		 4.435484	 2.071563
Lung (incl. trachea and bronchus) (C33-34)	 21		 6.18		 4.233871	 1.977401
Stomach (C16)								 17		 5.00		 3.427419	 1.600753
*/
total count //340
restore

*****************************
**   Data Quality Indices  **
*****************************
** Added on 04-June-2019 by JC as requested by NS for 2014 cancer annual report

*****************************
** Identifying & Reporting **
** 	 Data Quality Index	   **
** MV,DCO,O+U,UnkAge,CLIN  **
*****************************

tab basis ,m
tab siteicd10 basis ,m 
tab sex ,m //0 missing
tab age ,m //3 missing=999
tab sex age if age==.|age==999 //used this table in annual report (see excel 2014 data quality indicators in BNR OneDrive)
tab sex if sitecr5db==20 //site=O&U; used this table in annual report (see excel 2014 data quality indicators in BNR OneDrive)
/*
gen boddqi=1 if basis>4 & basis <9 //782 changes; 
replace boddqi=2 if basis==0 //13 changes
replace boddqi=3 if basis>0 & basis<5 //77 changes
replace boddqi=4 if basis==9 //19 changes
label define boddqi_lab 1 "MV" 2 "DCO"  3 "CLIN" 4 "UNK.BASIS" , modify
label var boddqi "basis DQI"
label values boddqi boddqi_lab

tab boddqi ,m
tab siteicd10 boddqi ,m
tab siteicd10 ,m //9 missing site - MPDs/MDS
//list pid top morph beh basis siteiarc icd10 if siteicd10==. //these are MPDs/MDS so exclude
tab siteicd10 boddqi if siteicd10!=.
** Use CanReg5 site groupings for basis DQI
tab sitecr5db ,m
tab sitecr5db boddqi if sex==1 & boddqi!=. & boddqi<3 & sitecr5db!=. & sitecr5db<23 & sitecr5db!=20 //male: used this table in annual report (see excel 2014 data quality indicators in BNR OneDrive)
tab sitecr5db boddqi if sex==2 & boddqi!=. & boddqi<3 & sitecr5db!=. & sitecr5db<23 & sitecr5db!=20 //female: used this table in annual report (see excel 2014 data quality indicators in BNR OneDrive)
tab sitecr5db boddqi if boddqi!=. & boddqi<3 & sitecr5db!=. & sitecr5db<23 & sitecr5db!=20
*/

tab basis ,m
gen boddqi=1 if basis>4 & basis <9 //245 changes; 
replace boddqi=2 if basis==0 //134 changes
replace boddqi=3 if basis>0 & basis<5 //86 changes
replace boddqi=4 if basis==9 //25 changes
label define boddqi_lab 1 "MV" 2 "DCO"  3 "CLIN" 4 "UNK.BASIS" , modify
label var boddqi "basis DQI"
label values boddqi boddqi_lab

gen siteagedqi=1 if siteiarc==61 //38 changes
replace siteagedqi=2 if age==.|age==999 //1 change
replace siteagedqi=3 if dob==. & siteagedqi!=2 //11 changes
replace siteagedqi=4 if siteiarc==61 & siteagedqi!=1 //0 changes
replace siteagedqi=5 if sex==.|sex==99 //0 changes
label define siteagedqi_lab 1 "O&U SITE" 2 "UNK.AGE" 3 "UNK.DOB" 4 "O&U+UNK.AGE/DOB" 5 "UNK.SEX", modify
label var siteagedqi "site/age DQI"
label values siteagedqi siteagedqi_lab

tab boddqi ,m
generate rectot=_N //1062
tab boddqi rectot,m

tab siteagedqi ,m
tab siteagedqi rectot,m

/*
preserve
** Append to above .docx for NS of basis,site,age but want to retain this dataset
** % tumours - basis by siteicd10
tab boddqi
contract boddqi siteicd10, freq(count) percent(percentage)

putdocx clear
putdocx begin

// Create a paragraph
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Basis"), bold
putdocx paragraph, halign(center)
putdocx text ("Basis (# tumours/n=1,062)"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename siteicd10 Site
rename boddqi Total_DQI
rename count Total_Records
rename percentage Pct_DQI
putdocx table tbl_bod = data("Site Total_DQI Total_Records Pct_DQI"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_bod(1,.), bold

putdocx save "`datapath'\version02\3-output\2020-10-05_DQI.docx", append
putdocx clear

save "`datapath'\version02\2-working\2015_cancer_dqi_basis.dta" ,replace
label data "BNR-Cancer 2015 Data Quality Index - Basis"
notes _dta :These data prepared for Natasha Sobers - 2015 annual report
restore
*/


** Create variables for table by basis (DCO% + MV%) in Data Quality section of annual report
** This was done manually in excel for 2014 annual report so the above code has now been updated to be automated in Stata
tab sitecr5db boddqi if boddqi!=. & boddqi<3 & sitecr5db!=. & sitecr5db<23 & sitecr5db!=2 & sitecr5db!=5 & sitecr5db!=7 & sitecr5db!=9 & sitecr5db!=13 & sitecr5db!=15 & sitecr5db!=16 & sitecr5db!=17 & sitecr5db!=18 & sitecr5db!=19 & sitecr5db!=20
/*
                      |       basis DQI
          CR5db sites |        MV        DCO |     Total
----------------------+----------------------+----------
Mouth & pharynx (C00- |        25          0 |        25 
        Stomach (C16) |        23          9 |        32 
Colon, rectum, anus ( |       144         19 |       163 
       Pancreas (C25) |         7         10 |        17 
Lung, trachea, bronch |        13          7 |        20 
         Breast (C50) |       181         14 |       195 
         Cervix (C53) |        14          2 |        16 
Corpus & Uterus NOS ( |        43          4 |        47 
       Prostate (C61) |       170         33 |       203 
Lymphoma (C81-85,88,9 |        45          7 |        52 
   Leukaemia (C91-95) |        11          2 |        13 
----------------------+----------------------+----------
                Total |       676        107 |       783
*/
labelbook sitecr5db_lab

preserve
drop if boddqi==. | boddqi>2 | sitecr5db==. | sitecr5db>22 | sitecr5db==20 | sitecr5db==2 | sitecr5db==5 | sitecr5db==7 | sitecr5db==9 | sitecr5db==13 | (sitecr5db>14 & sitecr5db<21) //279 deleted
contract sitecr5db boddqi, freq(count) percent(percentage)
input
34	1	676	0
34	2	107	0
end

label define sitecr5db_lab ///
1 "Mouth & pharynx" ///
2 "Oesophagus" ///
3 "Stomach" ///
4 "Colon, rectum, anus" ///
5 "Liver" ///
6 "Pancreas" ///
7 "Larynx" ///
8 "Lung, trachea, bronchus" ///
9 "Melanoma of skin" ///
10 "Breast" ///
11 "Cervix" ///
12 "Corpus & Uterus NOS" ///
13 "Ovary & adnexa" ///
14 "Prostate" ///
15 "Testis" ///
16 "Kidney & urinary NOS" ///
17 "Bladder" ///
18 "Brain, nervous system" ///
19 "Thyroid" ///
20 "O&U" ///
21 "Lymphoma" ///
22 "Leukaemia" ///
23 "Other digestive" ///
24 "Nose, sinuses" ///
25 "Bone, cartilage, etc" ///
26 "Other skin" ///
27 "Other female organs" ///
28 "Other male organs" ///
29 "Other endocrine" ///
30 "Myeloproliferative disorders (MPD)" ///
31 "Myelodysplastic syndromes (MDS)" ///
32 "D069: CIN 3" ///
33 "Eye,Heart,etc" ///
34 "All sites (in this table)" , modify
label var sitecr5db "CR5db sites"
label values sitecr5db sitecr5db_lab
drop percentage
gen percentage=(count/25)*100 if sitecr5db==1 & boddqi==1
replace percentage=(count/25)*100 if sitecr5db==1 & boddqi==2
replace percentage=(count/32)*100 if sitecr5db==3 & boddqi==1
replace percentage=(count/32)*100 if sitecr5db==3 & boddqi==2
replace percentage=(count/163)*100 if sitecr5db==4 & boddqi==1
replace percentage=(count/163)*100 if sitecr5db==4 & boddqi==2
replace percentage=(count/17)*100 if sitecr5db==6 & boddqi==1
replace percentage=(count/17)*100 if sitecr5db==6 & boddqi==2
replace percentage=(count/20)*100 if sitecr5db==8 & boddqi==1
replace percentage=(count/20)*100 if sitecr5db==8 & boddqi==2
replace percentage=(count/195)*100 if sitecr5db==10 & boddqi==1
replace percentage=(count/195)*100 if sitecr5db==10 & boddqi==2
replace percentage=(count/16)*100 if sitecr5db==11 & boddqi==1
replace percentage=(count/16)*100 if sitecr5db==11 & boddqi==2
replace percentage=(count/47)*100 if sitecr5db==12 & boddqi==1
replace percentage=(count/47)*100 if sitecr5db==12 & boddqi==2
replace percentage=(count/203)*100 if sitecr5db==14 & boddqi==1
replace percentage=(count/203)*100 if sitecr5db==14 & boddqi==2
replace percentage=(count/52)*100 if sitecr5db==21 & boddqi==1
replace percentage=(count/52)*100 if sitecr5db==21 & boddqi==2
replace percentage=(count/13)*100 if sitecr5db==22 & boddqi==1
replace percentage=(count/13)*100 if sitecr5db==22 & boddqi==2
replace percentage=(count/783)*100 if sitecr5db==34 & boddqi==1
replace percentage=(count/783)*100 if sitecr5db==34 & boddqi==2
format percentage %04.1f

gen icd10dqi="C00-14" if sitecr5db==1
replace icd10dqi="C16" if sitecr5db==3
replace icd10dqi="C18-21" if sitecr5db==4
replace icd10dqi="C25" if sitecr5db==6
replace icd10dqi="C33-34" if sitecr5db==8
replace icd10dqi="C50" if sitecr5db==10
replace icd10dqi="C53" if sitecr5db==11
replace icd10dqi="C54-55" if sitecr5db==12
replace icd10dqi="C61" if sitecr5db==14
replace icd10dqi="C81-85,88,90,96" if sitecr5db==21
replace icd10dqi="C91-95" if sitecr5db==22
replace icd10dqi="All" if sitecr5db==34

putdocx clear
putdocx begin

// Create a paragraph
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Basis"), bold
putdocx paragraph, halign(center)
putdocx text ("Basis (# tumours/n=1,062)"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename sitecr5db Cancer_Site
rename boddqi Total_DQI
rename count Cases
rename percentage Pct_DQI
rename icd10dqi ICD10
putdocx table tbl_bod = data("Cancer_Site Total_DQI Cases Pct_DQI ICD10"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_bod(1,.), bold

putdocx save "`datapath'\version02\3-output\2020-10-12_DQI.docx", append
putdocx clear

save "`datapath'\version02\2-working\2015_cancer_dqi_basis.dta" ,replace
label data "BNR-Cancer 2015 Data Quality Index - Basis"
notes _dta :These data prepared for Natasha Sobers - 2015 annual report
restore

preserve
** % tumours - site,age
tab siteagedqi
contract siteagedqi, freq(count) percent(percentage)

putdocx clear
putdocx begin

// Create a paragraph
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Unknown - Site, DOB & Age"), bold
putdocx paragraph, halign(center)
putdocx text ("Site,DOB,Age (# tumours/n=1,062)"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename siteagedqi Total_DQI
rename count Total_Records
rename percentage Pct_DQI
putdocx table tbl_site = data("Total_DQI Total_Records Pct_DQI"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_site(1,.), bold

putdocx save "`datapath'\version02\3-output\2020-10-05_DQI.docx", append
putdocx clear

save "`datapath'\version02\2-working\2015_cancer_dqi_siteage.dta" ,replace
label data "BNR-Cancer 2015 Data Quality Index - Site,Age"
notes _dta :These data prepared for Natasha Sobers - 2015 annual report
restore
** Missing sex %
** Missing age %


* *********************************************
* ANALYSIS: SECTION 3 - cancer sites
* Covering:
*  3.1  Classification of cancer by site
*  3.2 	ASIRs by site; overall, men and women
* *********************************************
** NOTE: bb popn and WHO popn data prepared by IH are ALL coded M=2 and F=1
** Above note by AR from 2008 dofile

** Load the dataset
use "`datapath'\version02\2-working\2008_2013_2014_2015_cancer_numbers", clear

****************************************************************************** 2015 ****************************************************************************************
drop if dxyr!=2015 //2998 deleted

** Determine sequential order of 2014 sites from 2015 top 10
tab siteiarc ,m

preserve
drop if siteiarc==25 | siteiarc>60 //56 deleted
contract siteiarc, freq(count) percent(percentage)
summ 
describe
gsort -count
gen order_id=_n
list order_id siteiarc
/*
     +-------------------------------------------------------+
     | order_id                                     siteiarc |
     |-------------------------------------------------------|
  1. |        1                                 Breast (C50) |
  2. |        2                               Prostate (C61) |
  3. |        3                                  Colon (C18) |
  4. |        4                              Rectum (C19-20) |
  5. |        5                           Corpus uteri (C54) |
     |-------------------------------------------------------|
  6. |        6                                Stomach (C16) |
  7. |        7   Lung (incl. trachea and bronchus) (C33-34) |
  8. |        8            Non-Hodgkin lymphoma (C82-86,C96) |
  9. |        9                       Multiple myeloma (C90) |
 10. |       10                                 Kidney (C64) |
     |-------------------------------------------------------|
 11. |       11                                  Ovary (C56) |
 12. |       12                               Pancreas (C25) |
 13. |       13                           Cervix uteri (C53) |
 14. |       14                                Bladder (C67) |
 15. |       15                                Thyroid (C73) |
     |-------------------------------------------------------|
 16. |       16                             Oesophagus (C15) |
 17. |       17                       Melanoma of skin (C43) |
 18. |       18                    Gallbladder etc. (C23-24) |
 19. |       19               Brain, nervous system (C70-72) |
 20. |       20                        Small intestine (C17) |
     |-------------------------------------------------------|
 21. |       21                                 Larynx (C32) |
 22. |       22                   Myeloid leukaemia (C92-94) |
 23. |       23                                   Anus (C21) |
 24. |       24                              Tongue (C01-02) |
 25. |       25                     Lymphoid leukaemia (C91) |
     |-------------------------------------------------------|
 26. |       26                     Uterus unspecified (C55) |
 27. |       27                            Nasopharynx (C11) |
 28. |       28           Myeloproliferative disorders (MPD) |
 29. |       29                       Hodgkin lymphoma (C81) |
 30. |       30                               Mouth (C03-06) |
     |-------------------------------------------------------|
 31. |       31                                 Tonsil (C09) |
 32. |       32         Connective and soft tissue (C47+C49) |
 33. |       33              Myelodysplastic syndromes (MDS) |
 34. |       34                                  Liver (C22) |
 35. |       35                                 Vagina (C52) |
     |-------------------------------------------------------|
 36. |       36                  Leukaemia unspecified (C95) |
 37. |       37                       Other oropharynx (C10) |
 38. |       38                      Salivary gland (C07-08) |
 39. |       39            Other female genital organs (C57) |
 40. |       40                                  Vulva (C51) |
     |-------------------------------------------------------|
 41. |       41                                Bone (C40-41) |
 42. |       42                  Nose, sinuses etc. (C30-31) |
 43. |       43                                 Testis (C62) |
 44. |       44               Other thoracic organs (C37-38) |
 45. |       45                                  Penis (C60) |
     |-------------------------------------------------------|
 46. |       46                    Pharynx unspecified (C14) |
 47. |       47                                    Eye (C69) |
 48. |       48                   Other urinary organs (C68) |
 49. |       49                                 Ureter (C66) |
     +-------------------------------------------------------+
Re-ran code after DCO list was traced-back
     +-------------------------------------------------------+
     | order_id                                     siteiarc |
     |-------------------------------------------------------|
  1. |        1                               Prostate (C61) |
  2. |        2                                 Breast (C50) |
  3. |        3                                  Colon (C18) |
  4. |        4                              Rectum (C19-20) |
  5. |        5                           Corpus uteri (C54) |
     |-------------------------------------------------------|
  6. |        6                                Stomach (C16) |
  7. |        7   Lung (incl. trachea and bronchus) (C33-34) |
  8. |        8                       Multiple myeloma (C90) |
  9. |        9            Non-Hodgkin lymphoma (C82-86,C96) |
 10. |       10                               Pancreas (C25) |
     |-------------------------------------------------------|
 11. |       11                                  Ovary (C56) |
 12. |       12                                 Kidney (C64) |
 13. |       13                           Cervix uteri (C53) |
 14. |       14                                Bladder (C67) |
 15. |       15                             Oesophagus (C15) |
     |-------------------------------------------------------|
 16. |       16                                Thyroid (C73) |
 17. |       17                    Gallbladder etc. (C23-24) |
 18. |       18               Brain, nervous system (C70-72) |
 19. |       19                       Melanoma of skin (C43) |
 20. |       20                        Small intestine (C17) |
     |-------------------------------------------------------|
 21. |       21                     Uterus unspecified (C55) |
 22. |       22                              Tongue (C01-02) |
 23. |       23                                 Larynx (C32) |
 24. |       24                   Myeloid leukaemia (C92-94) |
 25. |       25                                   Anus (C21) |
     |-------------------------------------------------------|
 26. |       26                     Lymphoid leukaemia (C91) |
 27. |       27                                  Liver (C22) |
 28. |       28         Connective and soft tissue (C47+C49) |
 29. |       29                       Hodgkin lymphoma (C81) |
 30. |       30           Myeloproliferative disorders (MPD) |
     |-------------------------------------------------------|
 31. |       31              Myelodysplastic syndromes (MDS) |
 32. |       32                               Mouth (C03-06) |
 33. |       33                            Nasopharynx (C11) |
 34. |       34                                 Vagina (C52) |
 35. |       35                  Leukaemia unspecified (C95) |
     |-------------------------------------------------------|
 36. |       36                                 Tonsil (C09) |
 37. |       37                                Bone (C40-41) |
 38. |       38                      Salivary gland (C07-08) |
 39. |       39                                 Testis (C62) |
 40. |       40                       Other oropharynx (C10) |
     |-------------------------------------------------------|
 41. |       41            Other female genital organs (C57) |
 42. |       42                                    Eye (C69) |
 43. |       43                  Nose, sinuses etc. (C30-31) |
 44. |       44                                  Vulva (C51) |
 45. |       45               Other thoracic organs (C37-38) |
     |-------------------------------------------------------|
 46. |       46                   Other urinary organs (C68) |
 47. |       47                    Pharynx unspecified (C14) |
 48. |       48                                 Ureter (C66) |
 49. |       49                                  Penis (C60) |
     +-------------------------------------------------------+
*/
drop if order_id>20 //29 deleted
save "`datapath'\version02\2-working\siteorder_2015" ,replace
restore

**********************************************************************************
** ASIR and 95% CI for Table 1 using AR's site groupings - using WHO World popn **
**					WORLD POPULATION PROSPECTS (WPP): 2015						**
*drop pfu
gen pfu=1 // for % year if not whole year collected; not done for cancer        **
**********************************************************************************
** NSobers confirmed use of WPP populations
labelbook sex_lab

********************************************************************
* (2.4c) IR age-standardised to WHO world popn - ALL TUMOURS: 2015
********************************************************************
** Using WHO World Standard Population
//tab siteiarc ,m

*drop _merge
merge m:m sex age_10 using "`datapath'\version02\2-working\pop_wpp_2015-10"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                               892  (_merge==3)
    -----------------------------------------
Re-ran after DCO list trace-back completed:
	
    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                             1,062  (_merge==3)
    -----------------------------------------
*/
** No unmatched records

** Below saved in pathway: 
//X:\The University of the West Indies\DataGroup - repo_data\data_p117\version02\2-working\WPP_population by sex_2013.txt
tab pop_wpp age_10  if sex==1 //female
tab pop_wpp age_10  if sex==2 //male

** Next, IRs for invasive tumours only
preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** No missing age groups
		
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR ALL SITES (INVASIVE TUMOURS ONLY) - STD TO WHO WORLD POPN

/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  | 1044   285327   365.90    233.91   219.26   249.34     7.60 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
gen cancer_site=1
gen year=1
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse cancer_site year number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1044*100
replace percent=round(percent,0.01)

label define cancer_site_lab 1 "all" 2 "prostate" 3 "breast" 4 "colon" 5 "rectum" 6 "corpus uteri" 7 "stomach" ///
							 8 "lung" 9 "multiple myeloma" 10 "non-hodgkin lymphoma" 11 "pancreas" ,modify
label values cancer_site cancer_site_lab
label define year_lab 1 "2015" 2 "2014" 3 "2013" 4 "2008" ,modify
label values year year_lab
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** Next, IRs for invasive tumours FEMALE only
preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	drop if sex==2 //496 deleted
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** No missing age groups
		
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR ALL SITES (INVASIVE TUMOURS ONLY-FEMALE) - STD TO WHO WORLD POPN

/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  548   147779   370.82    229.37   209.26   251.02    10.52 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
gen cancer_site=1
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse cancer_site number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1044*100
replace percent=round(percent,0.01)

label define cancer_site_lab 1 "all" 2 "breast" 3 "colon" 4 "corpus uteri" 5 "rectum" 6 "multiple myeloma" ,modify
label values cancer_site cancer_site_lab
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_female" ,replace
restore

** Next, IRs for invasive tumours MALE only
preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	drop if sex==1 //548 deleted
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** No missing age groups
		
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR ALL SITES (INVASIVE TUMOURS ONLY-FEMALE) - STD TO WHO WORLD POPN

/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  496   137548   360.60    242.20   220.79   265.26    11.20 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
gen cancer_site=1
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse cancer_site number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1044*100
replace percent=round(percent,0.01)

label define cancer_site_lab 1 "all" 2 "prostate" 3 "colon" 4 "rectum" 5 "lung" 6 "stomach" ,modify
label values cancer_site cancer_site_lab
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_male" ,replace
restore

********************************
** Next, IRs by site and year **
********************************
** PROSTATE
tab pop_wpp age_10 if siteiarc==39 //male

preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	keep if siteiarc==39 // prostate only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M 0-14,15-24,25-34
	expand 2 in 1
	replace sex=2 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_wpp=(26626) in 7
	sort age_10	
	
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_wpp=(19111)  in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_wpp=(18440) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  219   137548   159.22    103.36    89.91   118.42     7.13 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1044*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=2 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

** PROSTATE - for male top5 table
tab pop_wpp age_10 if siteiarc==39 //male

preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	keep if siteiarc==39 // prostate only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M 0-14,15-24,25-34
	expand 2 in 1
	replace sex=2 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_wpp=(26626) in 7
	sort age_10	
	
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_wpp=(19111)  in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_wpp=(18440) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  219   137548   159.22    103.36    89.91   118.42     7.13 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/496*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_male" 
replace cancer_site=2 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_male" ,replace
restore



** BREAST - excluded male breast cancer
tab pop_wpp age_10  if siteiarc==29 & sex==1 //female
tab pop_wpp age_10  if siteiarc==29 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	keep if siteiarc==29 //200 breast only 
	drop if sex==2 //1 deleted
	//excluded the 1 male as it would be potential confidential breach if reported separately
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_wpp=(25537) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=2 in 9
	replace case=0 in 9
	replace pop_wpp=(18761) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command
sort age_10
total pop_wpp


distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BC (FEMALE) - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  199   147779   134.66     90.39    77.58   104.80     6.81 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1044*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=3 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

** BREAST - for female top5 table
tab pop_wpp age_10  if siteiarc==29 & sex==1 //female
tab pop_wpp age_10  if siteiarc==29 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	keep if siteiarc==29 //200 breast only 
	drop if sex==2 //1 deleted
	//excluded the 1 male as it would be potential confidential breach if reported separately
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_wpp=(25537) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=2 in 9
	replace case=0 in 9
	replace pop_wpp=(18761) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command
sort age_10
total pop_wpp


distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BC (FEMALE) - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  199   147779   134.66     90.39    77.58   104.80     6.81 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/548*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_female" 
replace cancer_site=2 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_female" ,replace
restore


** COLON 
tab pop_wpp age_10  if siteiarc==13 & sex==1 //female
tab pop_wpp age_10  if siteiarc==13 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24
	** M   25-34
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(25537) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_wpp=(26626) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_wpp=(18761) in 16
	sort age_10

	expand 2 in 1
	replace sex=2 in 17
	replace age_10=2 in 17
	replace case=0 in 17
	replace pop_wpp=(19111) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=3 in 18
	replace case=0 in 18
	replace pop_wpp=(18440) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  115   285327   40.30     24.39    19.99    29.57     2.38 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1044*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=4 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

** COLON - female only for top5 table
preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24
	** M   25-34
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(25537) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_wpp=(26626) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_wpp=(18761) in 16
	sort age_10

	expand 2 in 1
	replace sex=2 in 17
	replace age_10=2 in 17
	replace case=0 in 17
	replace pop_wpp=(19111) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=3 in 18
	replace case=0 in 18
	replace pop_wpp=(18440) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

drop if sex==2 //9 deleted: for breast cancer - female ONLY

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (FEMALE)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   54   147779   36.54     22.15    16.42    29.44     3.21 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/548*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_female" 
replace cancer_site=3 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_female" ,replace
restore

** COLON - male only for top5 table
preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24
	** M   25-34
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(25537) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_wpp=(26626) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_wpp=(18761) in 16
	sort age_10

	expand 2 in 1
	replace sex=2 in 17
	replace age_10=2 in 17
	replace case=0 in 17
	replace pop_wpp=(19111) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=3 in 18
	replace case=0 in 18
	replace pop_wpp=(18440) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

drop if sex==1 //9 deleted: for breast cancer - male ONLY

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (MALE)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   61   137548   44.35     27.66    21.01    35.97     3.69 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/496*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_male" 
replace cancer_site=3 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_male" ,replace
restore


** RECTUM 
tab pop_wpp age_10  if siteiarc==14 & sex==1 //female
tab pop_wpp age_10  if siteiarc==14 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	keep if siteiarc==14
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24
	** M 85+
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(25537) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_wpp=(26626) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_wpp=(18761) in 16
	sort age_10

	expand 2 in 1
	replace sex=2 in 17
	replace age_10=2 in 17
	replace case=0 in 17
	replace pop_wpp=(19111) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(2487) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RECTAL CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   48   285327   16.82     11.08     8.04    14.97     1.71 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1044*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=5 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

** RECTUM - female only for top5 table
preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	keep if siteiarc==14
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24
	** M 85+
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(25537) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_wpp=(26626) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_wpp=(18761) in 16
	sort age_10

	expand 2 in 1
	replace sex=2 in 17
	replace age_10=2 in 17
	replace case=0 in 17
	replace pop_wpp=(19111) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(2487) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

drop if sex==2 // for rectal cancer - female ONLY

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RECTAL CANCER (FEMALE)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   26   147779   17.59     10.27     6.42    15.78     2.29 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/548*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_female" 
replace cancer_site=5 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_female" ,replace
restore

** RECTUM - male only for top5 table
preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	keep if siteiarc==14
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24
	** M 85+
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(25537) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_wpp=(26626) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_wpp=(18761) in 16
	sort age_10

	expand 2 in 1
	replace sex=2 in 17
	replace age_10=2 in 17
	replace case=0 in 17
	replace pop_wpp=(19111) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(2487) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

drop if sex==1 // for rectal cancer - male ONLY

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RECTAL CANCER (MALE)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   22   137548   15.99     11.81     7.34    18.13     2.64 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/496*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_male" 
replace cancer_site=4 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_male" ,replace
restore


** CORPUS UTERI
tab pop_wpp age_10 if siteiarc==33

preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	keep if siteiarc==33 // corpus uteri only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-14,15-24,25-34
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_wpp=(25537) in 7
	sort age_10	
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_wpp=(18761) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_wpp=(18963) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CORPUS UTERI - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   44   147779   29.77     18.13    13.07    24.75     2.87 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1044*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=6 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

** CORPUS UTERI - for female top 5 table
preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	keep if siteiarc==33 // corpus uteri only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-14,15-24,25-34
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_wpp=(25537) in 7
	sort age_10	
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_wpp=(18761) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_wpp=(18963) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CORPUS UTERI - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   44   147779   29.77     18.13    13.07    24.75     2.87 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/548*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_female" 
replace cancer_site=4 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_female" ,replace
restore


** STOMACH 
tab pop_wpp age_10  if siteiarc==11 & sex==1 //female
tab pop_wpp age_10  if siteiarc==11 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	keep if siteiarc==11
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(25537) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_wpp=(26626) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(18761) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_wpp=(19111) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18963) in 15
	sort age_10

	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_wpp=(18440) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_wpp=(20315) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=4 in 18
	replace case=0 in 18
	replace pop_wpp=(19218) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR STOMACH CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   36   285327   12.62      6.59     4.53     9.43     1.20 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1044*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=7 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

** STOMACH - male only for top5 table
preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	keep if siteiarc==11
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(25537) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_wpp=(26626) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(18761) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_wpp=(19111) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18963) in 15
	sort age_10

	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_wpp=(18440) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_wpp=(20315) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=4 in 18
	replace case=0 in 18
	replace pop_wpp=(19218) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

drop if sex==1 // for stomach cancer - male ONLY

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR STOMACH CANCER (MALE)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   17   137548   12.36      7.68     4.41    12.71     2.02 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/496*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_male" 
replace cancer_site=6 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_male" ,replace
restore


** LUNG
tab pop_wpp age_10 if siteiarc==21 & sex==1 //female
tab pop_wpp age_10 if siteiarc==21 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	keep if siteiarc==21
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24,25-34
	** F   35-44,45-54
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(25537) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_wpp=(26626) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(18761) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_wpp=(19111) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18963) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_wpp=(18440) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_wpp=(20315) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=5 in 18
	replace case=0 in 18
	replace pop_wpp=(21585) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR LUNG CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   30   285327   10.51      6.63     4.42     9.68     1.29 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1044*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=8 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

** LUNG - male only for top5 table
preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	keep if siteiarc==21
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24,25-34
	** F   35-44,45-54
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(25537) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_wpp=(26626) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(18761) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_wpp=(19111) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18963) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_wpp=(18440) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_wpp=(20315) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=5 in 18
	replace case=0 in 18
	replace pop_wpp=(21585) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

drop if sex==1 // for lung cancer - male ONLY

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR LUNG CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   21   137548   15.27     10.71     6.58    16.66     2.46 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/496*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_male" 
replace cancer_site=5 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_male" ,replace
restore


** MULTIPLE MYELOMA
tab pop_wpp age_10 if siteiarc==55 & sex==1 //female
tab pop_wpp age_10 if siteiarc==55 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	keep if siteiarc==55
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	** F 45-54
	** M 75-84
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_wpp=(25537) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_wpp=(26626) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_wpp=(18761) in 11
	sort age_10

	expand 2 in 1
	replace sex=2 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(19111) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_wpp=(18963) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_wpp=(18440) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_wpp=(20315) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_wpp=(19218) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=5 in 17
	replace case=0 in 17
	replace pop_wpp=(21585) in 17
	sort age_10
		
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=8 in 18
	replace case=0 in 18
	replace pop_wpp=(5564) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR MULTIPLE MYELOMA CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   28   285327    9.81      5.83     3.82     8.65     1.18 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1044*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=9 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

** MULTIPLE MYELOMA - female only for top5 table
preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	keep if siteiarc==55
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	** F 45-54
	** M 75-84
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_wpp=(25537) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_wpp=(26626) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_wpp=(18761) in 11
	sort age_10

	expand 2 in 1
	replace sex=2 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(19111) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_wpp=(18963) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_wpp=(18440) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_wpp=(20315) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_wpp=(19218) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=5 in 17
	replace case=0 in 17
	replace pop_wpp=(21585) in 17
	sort age_10
		
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=8 in 18
	replace case=0 in 18
	replace pop_wpp=(5564) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

drop if sex==2 // for MM - female ONLY

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR MM CANCER (FEMALE)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   21   147779   14.21      7.66     4.65    12.23     1.84 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/548*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_female" 
replace cancer_site=6 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_female" ,replace
restore


** NON-HODGKIN LYMPHOMA 
tab pop_wpp age_10  if siteiarc==53 & sex==1 //female
tab pop_wpp age_10  if siteiarc==53 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	keep if siteiarc==53
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24
	** F   85+
	** M   55-64
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(25537) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_wpp=(26626) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_wpp=(18761) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=2 in 17
	replace case=0 in 17
	replace pop_wpp=(19111) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(3975) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR NHL (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   27   285327    9.46      6.93     4.46    10.32     1.44 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1044*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=10 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** PANCREAS 
tab pop_wpp age_10  if siteiarc==18 & sex==1 //female
tab pop_wpp age_10  if siteiarc==18 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	keep if siteiarc==18
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	** F   45-54
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_wpp=(25537) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(26626) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(18761) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(19111) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_wpp=(18963) in 14
	sort age_10

	expand 2 in 1
	replace sex=2 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18440) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_wpp=(20315) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_wpp=(19218) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=5 in 18
	replace case=0 in 18
	replace pop_wpp=(21585) in 18
	sort age_10
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PANCREATIC CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   26   285327    9.11      4.93     3.17     7.50     1.06 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1044*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=11 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

/* Previously in top 10 before DCO trace-back completed
** OVARY 
tab pop_wpp age_10  if siteiarc==35

preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	keep if siteiarc==35
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** F 0-14,15-24,25-34,35-44
	expand 2 in 1
	replace sex=1 in 6
	replace age_10=1 in 6
	replace case=0 in 6
	replace pop_wpp=(25537) in 6
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=2 in 7
	replace case=0 in 7
	replace pop_wpp=(18761) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=3 in 8
	replace case=0 in 8
	replace pop_wpp=(18963) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=9 in 9
	replace case=0 in 9
	replace pop_wpp=(3975) in 9
	sort age_10
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR OVARIAN CANCER - STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   16   147779   10.83      7.03     3.98    11.75     1.90 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat asir
svmat ci_lower
svmat ci_upper

collapse asir ci_lower ci_upper
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=11 if cancer_site==.
replace year=1 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

** OVARY - for female top 5 table
preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	keep if siteiarc==35
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** F 0-14,15-24,25-34,35-44
	expand 2 in 1
	replace sex=1 in 6
	replace age_10=1 in 6
	replace case=0 in 6
	replace pop_wpp=(25537) in 6
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=2 in 7
	replace case=0 in 7
	replace pop_wpp=(18761) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=3 in 8
	replace case=0 in 8
	replace pop_wpp=(18963) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=9 in 9
	replace case=0 in 9
	replace pop_wpp=(3975) in 9
	sort age_10
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR OVARIAN CANCER - STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   16   147779   10.83      7.03     3.98    11.75     1.90 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat asir
svmat ci_lower
svmat ci_upper

collapse asir ci_lower ci_upper
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)

append using "`datapath'\version02\2-working\ASIRs_female" 
replace cancer_site=6 if cancer_site==.
order cancer_site asir ci_lower ci_upper
sort cancer_site asir
save "`datapath'\version02\2-working\ASIRs_female" ,replace
restore


** KIDNEY 
tab pop_wpp age_10  if siteiarc==42 & sex==1 //female
tab pop_wpp age_10  if siteiarc==42 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	keep if siteiarc==42
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,25-34,35-44,85+
	** F   15-24
	** M   45-54
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_wpp=(25537) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_wpp=(26626) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_wpp=(18761) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=3 in 12
	replace case=0 in 12
	replace pop_wpp=(18963) in 12
	sort age_10

	expand 2 in 1
	replace sex=2 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_wpp=(18440) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=4 in 14
	replace case=0 in 14
	replace pop_wpp=(20315) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_wpp=(19218) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=5 in 16
	replace case=0 in 16
	replace pop_wpp=(19492) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=9 in 17
	replace case=0 in 17
	replace pop_wpp=(3975) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(2487) in 18
	sort age_10
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR KIDNEY CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   16   285327    5.61      3.78     2.12     6.33     1.03 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat asir
svmat ci_lower
svmat ci_upper

collapse asir ci_lower ci_upper
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=12 if cancer_site==.
replace year=1 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore
*/
clear


* *********************************************
* ANALYSIS: SECTION 3 - cancer sites
* Covering:
*  3.1  Classification of cancer by site
*  3.2 	ASIRs by site; overall, men and women
* *********************************************
** NOTE: bb popn and WHO popn data prepared by IH are ALL coded M=2 and F=1
** Above note by AR from 2008 dofile

** Load the dataset
use "`datapath'\version02\2-working\2008_2013_2014_2015_cancer_numbers", clear

****************************************************************************** 2014 ****************************************************************************************
drop if dxyr!=2014 //3162 deleted
count //

** Determine sequential order of 2014 sites from 2015 top 10
tab siteiarc ,m

preserve
drop if siteiarc==25 | siteiarc>60 // deleted
contract siteiarc, freq(count) percent(percentage)
summ 
describe
gsort -count
gen order_id=_n
list order_id siteiarc
/*
     +-------------------------------------------------------+
     | order_id                                     siteiarc |
     |-------------------------------------------------------|
  1. |        1                               Prostate (C61) |
  2. |        2                                 Breast (C50) |
  3. |        3                                  Colon (C18) |
  4. |        4                           Corpus uteri (C54) |
  5. |        5   Lung (incl. trachea and bronchus) (C33-34) |
     |-------------------------------------------------------|
  6. |        6                       Multiple myeloma (C90) |
  7. |        7                              Rectum (C19-20) |
  8. |        8                                Bladder (C67) |
  9. |        9                                Stomach (C16) |
 10. |       10                               Pancreas (C25) |
     |-------------------------------------------------------|
 11. |       11                           Cervix uteri (C53) |
 12. |       12            Non-Hodgkin lymphoma (C82-86,C96) |
 13. |       13                                Thyroid (C73) |
 14. |       14                                  Liver (C22) |
 15. |       15                                 Kidney (C64) |
     |-------------------------------------------------------|
 16. |       16                                  Ovary (C56) |
 17. |       17                    Gallbladder etc. (C23-24) |
 18. |       18                             Oesophagus (C15) |
 19. |       19                                 Larynx (C32) |
 20. |       20                       Melanoma of skin (C43) |
     |-------------------------------------------------------|
 21. |       21         Connective and soft tissue (C47+C49) |
 22. |       22                     Lymphoid leukaemia (C91) |
 23. |       23                        Small intestine (C17) |
 24. |       24                  Nose, sinuses etc. (C30-31) |
 25. |       25                                 Tonsil (C09) |
     |-------------------------------------------------------|
 26. |       26               Brain, nervous system (C70-72) |
 27. |       27                   Myeloid leukaemia (C92-94) |
 28. |       28                         Hypopharynx (C12-13) |
 29. |       29                              Tongue (C01-02) |
 30. |       30                                  Penis (C60) |
     |-------------------------------------------------------|
 31. |       31                  Leukaemia unspecified (C95) |
 32. |       32           Myeloproliferative disorders (MPD) |
 33. |       33                       Hodgkin lymphoma (C81) |
 34. |       34                            Nasopharynx (C11) |
 35. |       35                       Other oropharynx (C10) |
     |-------------------------------------------------------|
 36. |       36                               Mouth (C03-06) |
 37. |       37                                 Testis (C62) |
 38. |       38                           Mesothelioma (C45) |
 39. |       39                                  Vulva (C51) |
 40. |       40                                 Vagina (C52) |
     |-------------------------------------------------------|
 41. |       41                                Bone (C40-41) |
 42. |       42                                   Anus (C21) |
 43. |       43              Myelodysplastic syndromes (MDS) |
 44. |       44                      Salivary gland (C07-08) |
 45. |       45           Immunoproliferative diseases (C88) |
     |-------------------------------------------------------|
 46. |       46                        Other endocrine (C75) |
     +-------------------------------------------------------+
Re-ran below after DCO trace-back completed (02oct2020)
     +-------------------------------------------------------+
     | order_id                                     siteiarc |
     |-------------------------------------------------------|
  1. |        1                               Prostate (C61) |
  2. |        2                                 Breast (C50) |
  3. |        3                                  Colon (C18) |
  4. |        4                           Corpus uteri (C54) |
  5. |        5   Lung (incl. trachea and bronchus) (C33-34) |
     |-------------------------------------------------------|
  6. |        6                       Multiple myeloma (C90) |
  7. |        7                              Rectum (C19-20) |
  8. |        8                                Bladder (C67) |
  9. |        9                                Stomach (C16) |
 10. |       10                               Pancreas (C25) |
     |-------------------------------------------------------|
 11. |       11                           Cervix uteri (C53) |
 12. |       12            Non-Hodgkin lymphoma (C82-86,C96) |
 13. |       13                                  Liver (C22) |
 14. |       14                                Thyroid (C73) |
 15. |       15                                 Kidney (C64) |
     |-------------------------------------------------------|
 16. |       16                                  Ovary (C56) |
 17. |       17                    Gallbladder etc. (C23-24) |
 18. |       18                             Oesophagus (C15) |
 19. |       19                       Melanoma of skin (C43) |
 20. |       20                                 Larynx (C32) |
     |-------------------------------------------------------|
 21. |       21         Connective and soft tissue (C47+C49) |
 22. |       22                     Lymphoid leukaemia (C91) |
 23. |       23               Brain, nervous system (C70-72) |
 24. |       24                  Nose, sinuses etc. (C30-31) |
 25. |       25                                 Tonsil (C09) |
     |-------------------------------------------------------|
 26. |       26                   Myeloid leukaemia (C92-94) |
 27. |       27                        Small intestine (C17) |
 28. |       28                              Tongue (C01-02) |
 29. |       29                         Hypopharynx (C12-13) |
 30. |       30                                  Penis (C60) |
     |-------------------------------------------------------|
 31. |       31                  Leukaemia unspecified (C95) |
 32. |       32                       Other oropharynx (C10) |
 33. |       33                            Nasopharynx (C11) |
 34. |       34           Myeloproliferative disorders (MPD) |
 35. |       35                       Hodgkin lymphoma (C81) |
     |-------------------------------------------------------|
 36. |       36                           Mesothelioma (C45) |
 37. |       37                                Bone (C40-41) |
 38. |       38                                 Vagina (C52) |
 39. |       39                                  Vulva (C51) |
 40. |       40                               Mouth (C03-06) |
     |-------------------------------------------------------|
 41. |       41                                 Testis (C62) |
 42. |       42                                   Anus (C21) |
 43. |       43              Myelodysplastic syndromes (MDS) |
 44. |       44                        Other endocrine (C75) |
 45. |       45           Immunoproliferative diseases (C88) |
     |-------------------------------------------------------|
 46. |       46                      Salivary gland (C07-08) |
     +-------------------------------------------------------+
*/
drop if order_id>20
save "`datapath'\version02\2-working\siteorder_2014" ,replace
restore

**********************************************************************************
** ASIR and 95% CI for Table 1 using AR's site groupings - using WHO World popn **
**					WORLD POPULATION PROSPECTS (WPP): 2014						**
*drop pfu
gen pfu=1 // for % year if not whole year collected; not done for cancer        **
**********************************************************************************
** NSobers confirmed use of WPP populations
labelbook sex_lab

********************************************************************
* (2.4c) IR age-standardised to WHO world popn - ALL TUMOURS: 2014
********************************************************************
** Using WHO World Standard Population
//tab siteiarc ,m

*drop _merge
merge m:m sex age_10 using "`datapath'\version02\2-working\pop_wpp_2014-10"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                             1
        from master                         0  (_merge==1)
        from using                          1  (_merge==2)

    matched                               840  (_merge==3)
    -----------------------------------------
Re-ran after 2015 DCO trace-back completed (02oct2020)
    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                               898  (_merge==3)
    -----------------------------------------
*/
** Below saved in pathway: 
//X:\The University of the West Indies\DataGroup - repo_data\data_p117\version02\2-working\WPP_population by sex_2013.txt
tab pop_wpp age_10  if sex==1 //female
tab pop_wpp age_10  if sex==2 //male

//drop if _merge==2 //1 deleted - no, doing so will change population totals
** There is 1 unmatched record (_merge==2) since 2014 data doesn't have any cases of females with age range 15-24
** age_10	site  dup	sex	 	pfu	pop_wpp	_merge
** 15-24	  .     .	female   .	18771	using only (2)
** The above age group will get dropped as the only case with this age group is in-situ

** Next, IRs for invasive tumours only
preserve
	drop if age_10==.
	drop if beh!=3 //24 deleted
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** F: 15-24
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=2 in 18
	replace case=0 in 18
	replace pop_wpp=(18771) in 18
	sort age_10
		
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR ALL SITES (INVASIVE TUMOURS ONLY) - STD TO WHO WORLD POPN

/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  874   284825   306.86    204.80   190.95   219.45     7.20 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/874*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=1 if cancer_site==.
replace year=2 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


********************************
** Next, IRs by site and year **
********************************
** PROSTATE
tab pop_wpp age_10 if siteiarc==39 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 deleted
	keep if siteiarc==39 // prostate only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M 0-14,15-24,25-34
	expand 2 in 1
	replace sex=2 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_wpp=(27062) in 7
	sort age_10	
	
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_wpp=(19032) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_wpp=(18491) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  183   137169   133.41     90.76    77.92   105.26     6.83 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/874*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=2 if cancer_site==.
replace year=2 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** BREAST - excluded male breast cancer
tab pop_wpp age_10  if siteiarc==29 & sex==1 //female
tab pop_wpp age_10  if siteiarc==29 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 deleted
	keep if siteiarc==29 // breast only 
	drop if sex==2
	//excluded the 4 males as it would be potential confidential breach if reported separately
		
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_wpp=(25929) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=2 in 9
	replace case=0 in 9
	replace pop_wpp=(18771) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command
sort age_10
total pop_wpp


distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BC (FEMALE) - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  153   147656   103.62     69.43    58.46    81.99     5.87 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/874*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=3 if cancer_site==.
replace year=2 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** COLON 
tab pop_wpp age_10  if siteiarc==13 & sex==1 //female
tab pop_wpp age_10  if siteiarc==13 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 deleted
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_wpp=(25929) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=1 in 16
	replace case=0 in 16
	replace pop_wpp=(27062) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=2 in 17
	replace case=0 in 17
	replace pop_wpp=(18771) in 17
	sort age_10

	expand 2 in 1
	replace sex=2 in 18
	replace age_10=2 in 18
	replace case=0 in 18
	replace pop_wpp=(19032) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  105   284825   36.86     23.95    19.47    29.24     2.43 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/874*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=4 if cancer_site==.
replace year=2 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** RECTUM 
tab pop_wpp age_10  if siteiarc==14 & sex==1 //female
tab pop_wpp age_10  if siteiarc==14 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 deleted
	keep if siteiarc==14
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34
	** M 35-44,85+
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(25929) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_wpp=(27062) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(18771) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_wpp=(19032) in 14
	sort age_10

	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_wpp=(19088) in 15
	sort age_10

	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_wpp=(18491) in 16
	sort age_10

	expand 2 in 1
	replace sex=2 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_wpp=(19352) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(2483) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RECTAL CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   27   284825    9.48      6.19     4.04     9.20     1.26 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/874*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=5 if cancer_site==.
replace year=2 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** CORPUS UTERI
tab pop_wpp age_10 if siteiarc==33

preserve
	drop if age_10==.
	drop if beh!=3 //24 deleted
	keep if siteiarc==33 // corpus uteri only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-14,15-24,25-34
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_wpp=(25929) in 7
	sort age_10	
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_wpp=(18771) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_wpp=(19088) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CORPUS UTERI - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   38   147656   25.74     16.10    11.31    22.46     2.74 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/874*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=6 if cancer_site==.
replace year=2 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** STOMACH 
tab pop_wpp age_10  if siteiarc==11 & sex==1 //female
tab pop_wpp age_10  if siteiarc==11 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 deleted
	keep if siteiarc==11
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34
	** F   35-44,45-54,65-74
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_wpp=(25929) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(27062) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(18771) in 12
	sort age_10

	expand 2 in 1
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(19032) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_wpp=(19088) in 14
	sort age_10

	expand 2 in 1
	replace sex=2 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18491) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_wpp=(20526) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=5 in 17
	replace case=0 in 17
	replace pop_wpp=(21757) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=7 in 18
	replace case=0 in 18
	replace pop_wpp=(11723) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR STOMACH CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   20   284825    7.02      3.87     2.29     6.28     0.97 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/874*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=7 if cancer_site==.
replace year=2 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** LUNG
tab pop_wpp age_10 if siteiarc==21 & sex==1 //female
tab pop_wpp age_10 if siteiarc==21 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 deleted
	keep if siteiarc==21
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24,25-34,35-44,45-54
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_wpp=(25929) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_wpp=(27062) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_wpp=(18771) in 11
	sort age_10

	expand 2 in 1
	replace sex=2 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(19032) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_wpp=(19088) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_wpp=(18491) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_wpp=(20526) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_wpp=(19352) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=5 in 17
	replace case=0 in 17
	replace pop_wpp=(21757) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=5 in 18
	replace case=0 in 18
	replace pop_wpp=(19547) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR LUNG CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   33   284825   11.59      6.71     4.56     9.68     1.25 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/874*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=8 if cancer_site==.
replace year=2 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** MULTIPLE MYELOMA
tab pop_wpp age_10 if siteiarc==55 & sex==1 //female
tab pop_wpp age_10 if siteiarc==55 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 deleted
	keep if siteiarc==55
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,85+
	** F   35-44
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_wpp=(25929) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(27062) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(18771) in 12
	sort age_10

	expand 2 in 1
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(19032) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_wpp=(19088) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18491) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_wpp=(20526) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=9 in 17
	replace case=0 in 17
	replace pop_wpp=(3974) in 17
	sort age_10
		
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(2483) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR MULTIPLE MYELOMA CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   29   284825   10.18      6.69     4.46     9.77     1.30 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/874*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=9 if cancer_site==.
replace year=2 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** NON-HODGKIN LYMPHOMA 
tab pop_wpp age_10  if siteiarc==53 & sex==1 //female
tab pop_wpp age_10  if siteiarc==53 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 deleted
	keep if siteiarc==53
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,25-34
	** F   15-24,45-54,55-64,65-74,85+
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_wpp=(25929) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(27062) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(18771) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_wpp=(19088) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_wpp=(18491) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=5 in 15
	replace case=0 in 15
	replace pop_wpp=(21757) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=6 in 16
	replace case=0 in 16
	replace pop_wpp=(18343) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=7 in 17
	replace case=0 in 17
	replace pop_wpp=(11723) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(3974) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR NHL (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   16   284825    5.62      3.92     2.17     6.59     1.08 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/874*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=10 if cancer_site==.
replace year=2 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** PANCREAS 
tab pop_wpp age_10  if siteiarc==18 & sex==1 //female
tab pop_wpp age_10  if siteiarc==18 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 deleted
	keep if siteiarc==18
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	** F   55-64,85+
	** M   45-54
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_wpp=(25929) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_wpp=(27062) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=2 in 10
	replace case=0 in 10
	replace pop_wpp=(18771) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_wpp=(19032) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=3 in 12
	replace case=0 in 12
	replace pop_wpp=(19088) in 12
	sort age_10

	expand 2 in 1
	replace sex=2 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_wpp=(18491) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=4 in 14
	replace case=0 in 14
	replace pop_wpp=(20526) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_wpp=(19352) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=5 in 16
	replace case=0 in 16
	replace pop_wpp=(19547) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=6 in 17
	replace case=0 in 17
	replace pop_wpp=(18343) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(3974) in 18
	sort age_10	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PANCREATIC CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   20   284825    7.02      4.12     2.48     6.59     1.00 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/874*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=11 if cancer_site==.
replace year=2 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

/* No longer in top 10 after 2015 DCO trace-back completed
** OVARY 
tab pop_wpp age_10  if siteiarc==35

preserve
	drop if age_10==.
	drop if beh!=3 //24 deleted
	keep if siteiarc==35
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** F 0-14,15-24,35-44,85+
	expand 2 in 1
	replace sex=1 in 6
	replace age_10=1 in 6
	replace case=0 in 6
	replace pop_wpp=(25929) in 6
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=2 in 7
	replace case=0 in 7
	replace pop_wpp=(18771) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=4 in 8
	replace case=0 in 8
	replace pop_wpp=(20526) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=9 in 9
	replace case=0 in 9
	replace pop_wpp=(3974) in 9
	sort age_10
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR OVARIAN CANCER - STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   10   147656    6.77      4.90     2.28     9.35     1.73 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat asir
svmat ci_lower
svmat ci_upper

collapse asir ci_lower ci_upper
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=11 if cancer_site==.
replace year=2 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** KIDNEY 
tab pop_wpp age_10  if siteiarc==42 & sex==1 //female
tab pop_wpp age_10  if siteiarc==42 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 deleted
	keep if siteiarc==42
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44,85+
	** F   45-54
	** M   75-84
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_wpp=(25929) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_wpp=(27062) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=2 in 9
	replace case=0 in 9
	replace pop_wpp=(18771) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 10
	replace age_10=2 in 10
	replace case=0 in 10
	replace pop_wpp=(19032) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=3 in 11
	replace case=0 in 11
	replace pop_wpp=(19088) in 11
	sort age_10

	expand 2 in 1
	replace sex=2 in 12
	replace age_10=3 in 12
	replace case=0 in 12
	replace pop_wpp=(18491) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=4 in 13
	replace case=0 in 13
	replace pop_wpp=(20526) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=4 in 14
	replace case=0 in 14
	replace pop_wpp=(19352) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=5 in 15
	replace case=0 in 15
	replace pop_wpp=(21757) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=8 in 16
	replace case=0 in 16
	replace pop_wpp=(5431) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=9 in 17
	replace case=0 in 17
	replace pop_wpp=(3974) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(2483) in 18
	sort age_10
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR KIDNEY CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   10   284825    3.51      2.42     1.16     4.60     0.84 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat asir
svmat ci_lower
svmat ci_upper

collapse asir ci_lower ci_upper
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=12 if cancer_site==.
replace year=2 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore
*/
clear


* *********************************************
* ANALYSIS: SECTION 3 - cancer sites
* Covering:
*  3.1  Classification of cancer by site
*  3.2 	ASIRs by site; overall, men and women
* *********************************************
** NOTE: bb popn and WHO popn data prepared by IH are ALL coded M=2 and F=1
** Above note by AR from 2008 dofile

** Load the dataset
use "`datapath'\version02\2-working\2008_2013_2014_2015_cancer_numbers", clear

****************************************************************************** 2013 ****************************************************************************************
drop if dxyr!=2013 //3177 deleted
count //

** Determine sequential order of 2013 sites from 2015 top 10
tab siteiarc ,m

preserve
drop if siteiarc==25 | siteiarc>60 //37 deleted
contract siteiarc, freq(count) percent(percentage)
summ 
describe
gsort -count
gen order_id=_n
list order_id siteiarc
/*
     +-------------------------------------------------------+
     | order_id                                     siteiarc |
     |-------------------------------------------------------|
  1. |        1                               Prostate (C61) |
  2. |        2                                 Breast (C50) |
  3. |        3                                  Colon (C18) |
  4. |        4                              Rectum (C19-20) |
  5. |        5                           Cervix uteri (C53) |
     |-------------------------------------------------------|
  6. |        6                           Corpus uteri (C54) |
  7. |        7   Lung (incl. trachea and bronchus) (C33-34) |
  8. |        8            Non-Hodgkin lymphoma (C82-86,C96) |
  9. |        9                                 Kidney (C64) |
 10. |       10                               Pancreas (C25) |
     |-------------------------------------------------------|
 11. |       11                                Stomach (C16) |
 12. |       12                                Thyroid (C73) |
 13. |       13                       Multiple myeloma (C90) |
 14. |       14                   Myeloid leukaemia (C92-94) |
 15. |       15                                  Ovary (C56) |
     |-------------------------------------------------------|
 16. |       16                    Gallbladder etc. (C23-24) |
 17. |       17                                   Anus (C21) |
 18. |       18                                Bladder (C67) |
 19. |       19                                  Liver (C22) |
 20. |       20                             Oesophagus (C15) |
     |-------------------------------------------------------|
 21. |       21                     Uterus unspecified (C55) |
 22. |       22                     Lymphoid leukaemia (C91) |
 23. |       23                       Hodgkin lymphoma (C81) |
 24. |       24                               Mouth (C03-06) |
 25. |       25           Myeloproliferative disorders (MPD) |
     |-------------------------------------------------------|
 26. |       26                                 Larynx (C32) |
 27. |       27               Brain, nervous system (C70-72) |
 28. |       28                                 Vagina (C52) |
 29. |       29                       Other oropharynx (C10) |
 30. |       30                        Small intestine (C17) |
     |-------------------------------------------------------|
 31. |       31                      Salivary gland (C07-08) |
 32. |       32                    Pharynx unspecified (C14) |
 33. |       33                  Leukaemia unspecified (C95) |
 34. |       34            Other female genital organs (C57) |
 35. |       35                       Melanoma of skin (C43) |
     |-------------------------------------------------------|
 36. |       36                  Nose, sinuses etc. (C30-31) |
 37. |       37                            Nasopharynx (C11) |
 38. |       38                                  Penis (C60) |
 39. |       39         Connective and soft tissue (C47+C49) |
 40. |       40                              Tongue (C01-02) |
     |-------------------------------------------------------|
 41. |       41                                  Vulva (C51) |
 42. |       42                                 Tonsil (C09) |
 43. |       43                                Bone (C40-41) |
 44. |       44                         Hypopharynx (C12-13) |
 45. |       45               Other thoracic organs (C37-38) |
     |-------------------------------------------------------|
 46. |       46                           Mesothelioma (C45) |
     +-------------------------------------------------------+
Re-ran code after 2015 DCO trace-back completed
     +-------------------------------------------------------+
     | order_id                                     siteiarc |
     |-------------------------------------------------------|
  1. |        1                               Prostate (C61) |
  2. |        2                                 Breast (C50) |
  3. |        3                                  Colon (C18) |
  4. |        4                              Rectum (C19-20) |
  5. |        5                           Cervix uteri (C53) |
     |-------------------------------------------------------|
  6. |        6                           Corpus uteri (C54) |
  7. |        7   Lung (incl. trachea and bronchus) (C33-34) |
  8. |        8            Non-Hodgkin lymphoma (C82-86,C96) |
  9. |        9                                 Kidney (C64) |
 10. |       10                               Pancreas (C25) |
     |-------------------------------------------------------|
 11. |       11                                Stomach (C16) |
 12. |       12                                Thyroid (C73) |
 13. |       13                       Multiple myeloma (C90) |
 14. |       14                                  Ovary (C56) |
 15. |       15                                Bladder (C67) |
     |-------------------------------------------------------|
 16. |       16                   Myeloid leukaemia (C92-94) |
 17. |       17                                   Anus (C21) |
 18. |       18                    Gallbladder etc. (C23-24) |
 19. |       19                                  Liver (C22) |
 20. |       20                     Uterus unspecified (C55) |
     |-------------------------------------------------------|
 21. |       21                             Oesophagus (C15) |
 22. |       22                     Lymphoid leukaemia (C91) |
 23. |       23               Brain, nervous system (C70-72) |
 24. |       24                       Hodgkin lymphoma (C81) |
 25. |       25                               Mouth (C03-06) |
     |-------------------------------------------------------|
 26. |       26                                 Larynx (C32) |
 27. |       27           Myeloproliferative disorders (MPD) |
 28. |       28                        Small intestine (C17) |
 29. |       29                                 Vagina (C52) |
 30. |       30         Connective and soft tissue (C47+C49) |
     |-------------------------------------------------------|
 31. |       31                       Melanoma of skin (C43) |
 32. |       32                       Other oropharynx (C10) |
 33. |       33                              Tongue (C01-02) |
 34. |       34                    Pharynx unspecified (C14) |
 35. |       35                      Salivary gland (C07-08) |
     |-------------------------------------------------------|
 36. |       36                                  Penis (C60) |
 37. |       37                  Nose, sinuses etc. (C30-31) |
 38. |       38                  Leukaemia unspecified (C95) |
 39. |       39                            Nasopharynx (C11) |
 40. |       40            Other female genital organs (C57) |
     |-------------------------------------------------------|
 41. |       41                         Hypopharynx (C12-13) |
 42. |       42                                 Tonsil (C09) |
 43. |       43                                  Vulva (C51) |
 44. |       44                                    Eye (C69) |
 45. |       45               Other thoracic organs (C37-38) |
     |-------------------------------------------------------|
 46. |       46                                Bone (C40-41) |
 47. |       47                           Mesothelioma (C45) |
     +-------------------------------------------------------+
*/
drop if order_id>20
save "`datapath'\version02\2-working\siteorder_2013" ,replace
restore

**********************************************************************************
** ASIR and 95% CI for Table 1 using AR's site groupings - using WHO World popn **
**					WORLD POPULATION PROSPECTS (WPP): 2014						**
*drop pfu
gen pfu=1 // for % year if not whole year collected; not done for cancer        **
**********************************************************************************
** NSobers confirmed use of WPP populations
labelbook sex_lab

********************************************************************
* (2.4c) IR age-standardised to WHO world popn - ALL TUMOURS: 2014
********************************************************************
** Using WHO World Standard Population
//tab siteiarc ,m

*drop _merge
merge m:m sex age_10 using "`datapath'\version02\2-working\pop_wpp_2013-10"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                               796  (_merge==3)
    -----------------------------------------

	    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                               883  (_merge==3)
    -----------------------------------------
*/
** None unmatched

** Below saved in pathway: 
//X:\The University of the West Indies\DataGroup - repo_data\data_p117\version02\2-working\WPP_population by sex_2013.txt
tab pop_wpp age_10  if sex==1 //female
tab pop_wpp age_10  if sex==2 //male


** Next, IRs for invasive tumours only
preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** No missing age groups
		
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR ALL SITES (INVASIVE TUMOURS ONLY) - STD TO WHO WORLD POPN

/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  874   284294   307.43    209.82   195.68   224.76     7.34 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/874*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=1 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


********************************
** Next, IRs by site and year **
********************************
** PROSTATE
tab pop_wpp age_10 if siteiarc==39 //male

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==39 // prostate only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M 0-14,15-24,25-34,35-44
	expand 2 in 1
	replace sex=2 in 6
	replace age_10=1 in 6
	replace case=0 in 6
	replace pop_wpp=(27452) in 6
	sort age_10	
	
	expand 2 in 1
	replace sex=2 in 7
	replace age_10=2 in 7
	replace case=0 in 7
	replace pop_wpp=(18950) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=3 in 8
	replace case=0 in 8
	replace pop_wpp=(18555) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=4 in 9
	replace case=0 in 9
	replace pop_wpp=(19473) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  184   136769   134.53     94.40    81.11   109.39     7.07 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/874*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=2 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** BREAST - excluded male breast cancer
tab pop_wpp age_10  if siteiarc==29 & sex==1 //female
tab pop_wpp age_10  if siteiarc==29 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==29 // breast only 
	drop if sex==2
	//excluded the 3 males as it would be potential confidential breach if reported separately
		
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_wpp=(26307) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=2 in 9
	replace case=0 in 9
	replace pop_wpp=(18763) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command
sort age_10
total pop_wpp


distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BC (FEMALE) - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  137   147525   92.87     63.18    52.56    75.43     5.71 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/874*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=3 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** COLON 
tab pop_wpp age_10  if siteiarc==13 & sex==1 //female
tab pop_wpp age_10  if siteiarc==13 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24,25-34	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=1 in 13
	replace case=0 in 13
	replace pop_wpp=(26307) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(27452) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=2 in 15
	replace case=0 in 15
	replace pop_wpp=(18763) in 15
	sort age_10

	expand 2 in 1
	replace sex=2 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_wpp=(18950) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=3 in 17
	replace case=0 in 17
	replace pop_wpp=(19213) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=3 in 18
	replace case=0 in 18
	replace pop_wpp=(18555) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  111   284294   39.04     24.69    20.19    29.99     2.43 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/874*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=4 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** RECTUM 
tab pop_wpp age_10  if siteiarc==14 & sex==1 //female
tab pop_wpp age_10  if siteiarc==14 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==14
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24
	** F   25-34,35-44
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=1 in 13
	replace case=0 in 13
	replace pop_wpp=(26307) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(27452) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=2 in 15
	replace case=0 in 15
	replace pop_wpp=(18763) in 15
	sort age_10

	expand 2 in 1
	replace sex=2 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_wpp=(18950) in 16
	sort age_10

	expand 2 in 1
	replace sex=1 in 17
	replace age_10=3 in 17
	replace case=0 in 17
	replace pop_wpp=(19213) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=4 in 18
	replace case=0 in 18
	replace pop_wpp=(20732) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RECTAL CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   44   284294   15.48     10.12     7.26    13.81     1.61 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/874*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=5 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** CORPUS UTERI
tab pop_wpp age_10 if siteiarc==33

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==33 // corpus uteri only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-14,15-24,25-34,35-44,85+
	expand 2 in 1
	replace sex=1 in 5
	replace age_10=1 in 5
	replace case=0 in 5
	replace pop_wpp=(26307) in 5
	sort age_10	
	
	expand 2 in 1
	replace sex=1 in 6
	replace age_10=2 in 6
	replace case=0 in 6
	replace pop_wpp=(18763) in 6
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=3 in 7
	replace case=0 in 7
	replace pop_wpp=(19213) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=4 in 8
	replace case=0 in 8
	replace pop_wpp=(20732) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=9 in 9
	replace case=0 in 9
	replace pop_wpp=(3942) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CORPUS UTERI - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   32   147525   21.69     14.28     9.73    20.45     2.63 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/874*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=6 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** STOMACH 
tab pop_wpp age_10  if siteiarc==11 & sex==1 //female
tab pop_wpp age_10  if siteiarc==11 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==11
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,45-54,85+
	** F   35-44
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_wpp=(26307) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_wpp=(27452) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=2 in 10
	replace case=0 in 10
	replace pop_wpp=(18763) in 10
	sort age_10

	expand 2 in 1
	replace sex=2 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_wpp=(18950) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=3 in 12
	replace case=0 in 12
	replace pop_wpp=(19213) in 12
	sort age_10

	expand 2 in 1
	replace sex=2 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_wpp=(18555) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=4 in 14
	replace case=0 in 14
	replace pop_wpp=(20732) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=5 in 15
	replace case=0 in 15
	replace pop_wpp=(21938) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=5 in 16
	replace case=0 in 16
	replace pop_wpp=(19611) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=9 in 17
	replace case=0 in 17
	replace pop_wpp=(3942) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(2466) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR STOMACH CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   17   284294    5.98      3.97     2.29     6.51     1.03 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/874*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=7 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** LUNG
tab pop_wpp age_10 if siteiarc==21 & sex==1 //female
tab pop_wpp age_10 if siteiarc==21 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==21
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24,25-34,35-44
	** F   85+
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_wpp=(26307) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(27452) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(18763) in 12
	sort age_10

	expand 2 in 1
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(18950) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_wpp=(19213) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18555) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_wpp=(20732) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_wpp=(19473) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(3942) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR LUNG CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   29   284294   10.20      6.77     4.51     9.88     1.32 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/874*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=8 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** MULTIPLE MYELOMA
tab pop_wpp age_10 if siteiarc==55 & sex==1 //female
tab pop_wpp age_10 if siteiarc==55 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==55
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	** F   55-64,75-84
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_wpp=(26307) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_wpp=(27452) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_wpp=(18763) in 11
	sort age_10

	expand 2 in 1
	replace sex=2 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(18950) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_wpp=(19213) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_wpp=(18555) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_wpp=(20732) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_wpp=(19473) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=6 in 17
	replace case=0 in 17
	replace pop_wpp=(17777) in 17
	sort age_10
		
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=8 in 18
	replace case=0 in 18
	replace pop_wpp=(7493) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR MULTIPLE MYELOMA CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   15   284294    5.28      3.46     1.90     5.91     0.98 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/874*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=9 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** NON-HODGKIN LYMPHOMA 
tab pop_wpp age_10  if siteiarc==53 & sex==1 //female
tab pop_wpp age_10  if siteiarc==53 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==53
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14
	** F   15-24,35-44,45-54
	** M   25-34
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=1 in 13
	replace case=0 in 13
	replace pop_wpp=(26307) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(27452) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=2 in 15
	replace case=0 in 15
	replace pop_wpp=(18763) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_wpp=(18555) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_wpp=(20732) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=5 in 18
	replace case=0 in 18
	replace pop_wpp=(21938) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR NHL (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   25   284294    8.79      6.40     4.03     9.69     1.39 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/874*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=10 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** PANCREAS 
tab pop_wpp age_10  if siteiarc==18 & sex==1 //female
tab pop_wpp age_10  if siteiarc==18 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==18
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=1 in 13
	replace case=0 in 13
	replace pop_wpp=(26307) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(27452) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=2 in 15
	replace case=0 in 15
	replace pop_wpp=(18763) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_wpp=(18950) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=3 in 17
	replace case=0 in 17
	replace pop_wpp=(19213) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=3 in 18
	replace case=0 in 18
	replace pop_wpp=(18555) in 18
	sort age_10
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PANCREATIC CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   22   284294    7.74      5.05     3.11     7.85     1.16 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/874*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=11 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

/* No longer in top 10 after 2015 DCO trace-back completed
** OVARY 
tab pop_wpp age_10  if siteiarc==35

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==35
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** F 15-24,45-54
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_wpp=(18763) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=5 in 9
	replace case=0 in 9
	replace pop_wpp=(21938) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR OVARIAN CANCER - STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   12   147525    8.13      6.51     3.16    11.84     2.13 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat asir
svmat ci_lower
svmat ci_upper

collapse asir ci_lower ci_upper
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=11 if cancer_site==.
replace year=3 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** KIDNEY 
tab pop_wpp age_10  if siteiarc==42 & sex==1 //female
tab pop_wpp age_10  if siteiarc==42 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==42
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 15-24,25-34,85+
	** F   45-54
	** M   0-14
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(27452) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(18763) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(18950) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_wpp=(19213) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18555) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=5 in 16
	replace case=0 in 16
	replace pop_wpp=(21938) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=9 in 17
	replace case=0 in 17
	replace pop_wpp=(3942) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(2466) in 18
	sort age_10
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR KIDNEY CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   21   284294    7.39      5.38     3.27     8.40     1.26 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat asir
svmat ci_lower
svmat ci_upper

collapse asir ci_lower ci_upper
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=12 if cancer_site==.
replace year=3 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore
*/
clear


* *********************************************
* ANALYSIS: SECTION 3 - cancer sites
* Covering:
*  3.1  Classification of cancer by site
*  3.2 	ASIRs by site; overall, men and women
* *********************************************
** NOTE: bb popn and WHO popn data prepared by IH are ALL coded M=2 and F=1
** Above note by AR from 2008 dofile

** Load the dataset
use "`datapath'\version02\2-working\2008_2013_2014_2015_cancer_numbers", clear

****************************************************************************** 2008 ****************************************************************************************
drop if dxyr!=2008 //2843 deleted
count //

** Determine sequential order of 2008 sites from 2015 top 10
tab siteiarc ,m

preserve
drop if siteiarc==25 | siteiarc>60 //34 deleted
contract siteiarc, freq(count) percent(percentage)
summ 
describe
gsort -count
gen order_id=_n
list order_id siteiarc
/*
     +-------------------------------------------------------+
     | order_id                                     siteiarc |
     |-------------------------------------------------------|
  1. |        1                               Prostate (C61) |
  2. |        2                                 Breast (C50) |
  3. |        3                                  Colon (C18) |
  4. |        4                           Corpus uteri (C54) |
  5. |        5                                Stomach (C16) |
     |-------------------------------------------------------|
  6. |        6                              Rectum (C19-20) |
  7. |        7   Lung (incl. trachea and bronchus) (C33-34) |
  8. |        8                           Cervix uteri (C53) |
  9. |        9                       Multiple myeloma (C90) |
 10. |       10                               Pancreas (C25) |
     |-------------------------------------------------------|
 11. |       11            Non-Hodgkin lymphoma (C82-86,C96) |
 12. |       12                                 Kidney (C64) |
 13. |       13                                  Ovary (C56) |
 14. |       14                                Thyroid (C73) |
 15. |       15                                Bladder (C67) |
     |-------------------------------------------------------|
 16. |       16                             Oesophagus (C15) |
 17. |       17                   Myeloid leukaemia (C92-94) |
 18. |       18                              Tongue (C01-02) |
 19. |       19                                 Larynx (C32) |
 20. |       20                                  Liver (C22) |
     |-------------------------------------------------------|
 21. |       21                       Melanoma of skin (C43) |
 22. |       22         Connective and soft tissue (C47+C49) |
 23. |       23           Myeloproliferative disorders (MPD) |
 24. |       24                                Bone (C40-41) |
 25. |       25                               Mouth (C03-06) |
     |-------------------------------------------------------|
 26. |       26                       Hodgkin lymphoma (C81) |
 27. |       27                            Nasopharynx (C11) |
 28. |       28                                 Tonsil (C09) |
 29. |       29                                   Anus (C21) |
 30. |       30                    Gallbladder etc. (C23-24) |
     |-------------------------------------------------------|
 31. |       31                     Lymphoid leukaemia (C91) |
 32. |       32                  Nose, sinuses etc. (C30-31) |
 33. |       33                                    Eye (C69) |
 34. |       34                         Hypopharynx (C12-13) |
 35. |       35                                  Penis (C60) |
     |-------------------------------------------------------|
 36. |       36              Myelodysplastic syndromes (MDS) |
 37. |       37                        Other endocrine (C75) |
 38. |       38                        Small intestine (C17) |
 39. |       39                  Leukaemia unspecified (C95) |
 40. |       40               Brain, nervous system (C70-72) |
     |-------------------------------------------------------|
 41. |       41            Other female genital organs (C57) |
 42. |       42                               Placenta (C58) |
 43. |       43                     Uterus unspecified (C55) |
 44. |       44                   Other urinary organs (C68) |
 45. |       45               Other thoracic organs (C37-38) |
     |-------------------------------------------------------|
 46. |       46           Immunoproliferative diseases (C88) |
 47. |       47                                  Vulva (C51) |
 48. |       48                                 Testis (C62) |
 49. |       49                    Pharynx unspecified (C14) |
     +-------------------------------------------------------+
Re-ran code after 2015 DCO trace-back completed
     +-------------------------------------------------------+
     | order_id                                     siteiarc |
     |-------------------------------------------------------|
  1. |        1                               Prostate (C61) |
  2. |        2                                 Breast (C50) |
  3. |        3                                  Colon (C18) |
  4. |        4                           Corpus uteri (C54) |
  5. |        5                                Stomach (C16) |
     |-------------------------------------------------------|
  6. |        6   Lung (incl. trachea and bronchus) (C33-34) |
  7. |        7                              Rectum (C19-20) |
  8. |        8                           Cervix uteri (C53) |
  9. |        9                       Multiple myeloma (C90) |
 10. |       10                               Pancreas (C25) |
     |-------------------------------------------------------|
 11. |       11            Non-Hodgkin lymphoma (C82-86,C96) |
 12. |       12                                 Kidney (C64) |
 13. |       13                                  Ovary (C56) |
 14. |       14                                Thyroid (C73) |
 15. |       15                                Bladder (C67) |
     |-------------------------------------------------------|
 16. |       16                   Myeloid leukaemia (C92-94) |
 17. |       17                             Oesophagus (C15) |
 18. |       18                              Tongue (C01-02) |
 19. |       19                                 Larynx (C32) |
 20. |       20                                  Liver (C22) |
     |-------------------------------------------------------|
 21. |       21         Connective and soft tissue (C47+C49) |
 22. |       22                       Melanoma of skin (C43) |
 23. |       23           Myeloproliferative disorders (MPD) |
 24. |       24                               Mouth (C03-06) |
 25. |       25                  Nose, sinuses etc. (C30-31) |
     |-------------------------------------------------------|
 26. |       26                                Bone (C40-41) |
 27. |       27                                    Eye (C69) |
 28. |       28               Brain, nervous system (C70-72) |
 29. |       29                       Hodgkin lymphoma (C81) |
 30. |       30                     Lymphoid leukaemia (C91) |
     |-------------------------------------------------------|
 31. |       31                         Hypopharynx (C12-13) |
 32. |       32                                 Tonsil (C09) |
 33. |       33                    Gallbladder etc. (C23-24) |
 34. |       34              Myelodysplastic syndromes (MDS) |
 35. |       35                                   Anus (C21) |
     |-------------------------------------------------------|
 36. |       36                            Nasopharynx (C11) |
 37. |       37                                  Penis (C60) |
 38. |       38                  Leukaemia unspecified (C95) |
 39. |       39                        Other endocrine (C75) |
 40. |       40                        Small intestine (C17) |
     |-------------------------------------------------------|
 41. |       41                     Uterus unspecified (C55) |
 42. |       42                               Placenta (C58) |
 43. |       43            Other female genital organs (C57) |
 44. |       44                                 Testis (C62) |
 45. |       45                                  Vulva (C51) |
     |-------------------------------------------------------|
 46. |       46           Immunoproliferative diseases (C88) |
 47. |       47                   Other urinary organs (C68) |
 48. |       48               Other thoracic organs (C37-38) |
 49. |       49                    Pharynx unspecified (C14) |
     +-------------------------------------------------------+
*/
drop if order_id>20
save "`datapath'\version02\2-working\siteorder_2008" ,replace
restore

**********************************************************************************
** ASIR and 95% CI for Table 1 using AR's site groupings - using WHO World popn **
**					WORLD POPULATION PROSPECTS (WPP): 2014						**
*drop pfu
gen pfu=1 // for % year if not whole year collected; not done for cancer        **
**********************************************************************************
** NSobers confirmed use of WPP populations
labelbook sex_lab

********************************************************************
* (2.4c) IR age-standardised to WHO world popn - ALL TUMOURS: 2014
********************************************************************
** Using WHO World Standard Population
//tab siteiarc ,m

*drop _merge
merge m:m sex age_10 using "`datapath'\version02\2-working\pop_wpp_2008-10"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                               807  (_merge==3)
    -----------------------------------------

	    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                             1,217  (_merge==3)
    -----------------------------------------
*/
** None unmatched

** Below saved in pathway: 
//X:\The University of the West Indies\DataGroup - repo_data\data_p117\version02\2-working\WPP_population by sex_2013.txt
tab pop_wpp age_10  if sex==1 //female
tab pop_wpp age_10  if sex==2 //male


** Next, IRs for invasive tumours only
preserve
	drop if age_10==.
	drop if beh!=3 //101 deleted
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** No missing age groups
		
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR ALL SITES (INVASIVE TUMOURS ONLY) - STD TO WHO WORLD POPN

/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  | 1116   279946   398.65    285.24   268.18   303.14     8.84 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1116*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=1 if cancer_site==.
replace year=4 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


********************************
** Next, IRs by site and year **
********************************
** PROSTATE
tab pop_wpp age_10 if siteiarc==39 //male

preserve
	drop if age_10==.
	drop if beh!=3 //101 deleted
	keep if siteiarc==39 // prostate only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M 0-14,15-24,25-34
	expand 2 in 1
	replace sex=2 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_wpp=(28519) in 7
	sort age_10	
	
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_wpp=(19022) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_wpp=(19256) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  207   134295   154.14    117.92   102.11   135.57     8.38 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1116*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=2 if cancer_site==.
replace year=4 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** BREAST - excluded male breast cancer
tab pop_wpp age_10  if siteiarc==29 & sex==1 //female
tab pop_wpp age_10  if siteiarc==29 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //101 deleted
	keep if siteiarc==29 // breast only 
	drop if sex==2
	//no males to exclude
		
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_wpp=(27544) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=2 in 9
	replace case=0 in 9
	replace pop_wpp=(19087) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command
sort age_10
total pop_wpp


distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BC (FEMALE) - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  132   145651   90.63     64.59    53.65    77.20     5.88 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1116*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=3 if cancer_site==.
replace year=4 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** COLON 
tab pop_wpp age_10  if siteiarc==13 & sex==1 //female
tab pop_wpp age_10  if siteiarc==13 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //101 deleted
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24
	** F   25-34	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(27544) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_wpp=(28519) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_wpp=(19087) in 16
	sort age_10

	expand 2 in 1
	replace sex=2 in 17
	replace age_10=2 in 17
	replace case=0 in 17
	replace pop_wpp=(19022) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=3 in 18
	replace case=0 in 18
	replace pop_wpp=(19925) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   95   279946   33.94     24.30    19.54    29.92     2.58 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1116*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=4 if cancer_site==.
replace year=4 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** RECTUM 
tab pop_wpp age_10  if siteiarc==14 & sex==1 //female
tab pop_wpp age_10  if siteiarc==14 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //101 deleted
	keep if siteiarc==14
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34
	** M   35-44,85+
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(27544) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_wpp=(28519) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(19087) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_wpp=(19022) in 14
	sort age_10

	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_wpp=(19925) in 15
	sort age_10

	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_wpp=(19256) in 16
	sort age_10

	expand 2 in 1
	replace sex=2 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_wpp=(20130) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(2276) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RECTAL CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   29   279946   10.36      7.48     4.97    10.88     1.45 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1116*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=5 if cancer_site==.
replace year=4 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** CORPUS UTERI
tab pop_wpp age_10 if siteiarc==33

preserve
	drop if age_10==.
	drop if beh!=3 //101 deleted
	keep if siteiarc==33 // corpus uteri only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-14,15-24,25-34
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_wpp=(27544) in 7
	sort age_10	
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_wpp=(19087) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_wpp=(19925) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CORPUS UTERI - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   39   145651   26.78     18.33    12.90    25.43     3.08 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1116*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=6 if cancer_site==.
replace year=4 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** STOMACH 
tab pop_wpp age_10  if siteiarc==11 & sex==1 //female
tab pop_wpp age_10  if siteiarc==11 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //101 deleted
	keep if siteiarc==11
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,45-54
	** F   35-44,55-64
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_wpp=(27544) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_wpp=(28519) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_wpp=(19087) in 11
	sort age_10

	expand 2 in 1
	replace sex=2 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(19022) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_wpp=(19925) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_wpp=(19256) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_wpp=(21711) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=5 in 16
	replace case=0 in 16
	replace pop_wpp=(21592) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=5 in 17
	replace case=0 in 17
	replace pop_wpp=(19220) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=6 in 18
	replace case=0 in 18
	replace pop_wpp=(14849) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR STOMACH CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   32   279946   11.43      6.88     4.61     9.99     1.32 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1116*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=7 if cancer_site==.
replace year=4 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** LUNG
tab pop_wpp age_10 if siteiarc==21 & sex==1 //female
tab pop_wpp age_10 if siteiarc==21 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //101 deleted
	keep if siteiarc==21
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24
	** F   25-34,35-44
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=1 in 13
	replace case=0 in 13
	replace pop_wpp=(27544) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(28519) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=2 in 15
	replace case=0 in 15
	replace pop_wpp=(19087) in 15
	sort age_10

	expand 2 in 1
	replace sex=2 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_wpp=(19022) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=3 in 17
	replace case=0 in 17
	replace pop_wpp=(19925) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=4 in 18
	replace case=0 in 18
	replace pop_wpp=(21711) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR LUNG CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   29   279946   10.36      7.46     4.93    10.89     1.46 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1116*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=8 if cancer_site==.
replace year=4 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** MULTIPLE MYELOMA
tab pop_wpp age_10 if siteiarc==55 & sex==1 //female
tab pop_wpp age_10 if siteiarc==55 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //101 deleted
	keep if siteiarc==55
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	** M   55-64,65-74,85+
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_wpp=(27544) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_wpp=(28519) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=2 in 10
	replace case=0 in 10
	replace pop_wpp=(19087) in 10
	sort age_10

	expand 2 in 1
	replace sex=2 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_wpp=(19022) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=3 in 12
	replace case=0 in 12
	replace pop_wpp=(19925) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_wpp=(19256) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=4 in 14
	replace case=0 in 14
	replace pop_wpp=(21711) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_wpp=(20130) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=6 in 16
	replace case=0 in 16
	replace pop_wpp=(13225) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=7 in 17
	replace case=0 in 17
	replace pop_wpp=(7795) in 17
	sort age_10
		
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(2276) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR MULTIPLE MYELOMA CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   17   279946    6.07      3.81     2.16     6.35     1.02 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1116*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=9 if cancer_site==.
replace year=4 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** NON-HODGKIN LYMPHOMA 
tab pop_wpp age_10  if siteiarc==53 & sex==1 //female
tab pop_wpp age_10  if siteiarc==53 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //101 deleted
	keep if siteiarc==53
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,35-44,45-54
	** M   25-34,75-84,85+
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_wpp=(27544) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_wpp=(28519) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=2 in 10
	replace case=0 in 10
	replace pop_wpp=(19087) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_wpp=(19022) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=3 in 12
	replace case=0 in 12
	replace pop_wpp=(19256) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=4 in 13
	replace case=0 in 13
	replace pop_wpp=(21711) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=4 in 14
	replace case=0 in 14
	replace pop_wpp=(20130) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=5 in 15
	replace case=0 in 15
	replace pop_wpp=(21592) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=5 in 16
	replace case=0 in 16
	replace pop_wpp=(19220) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=8 in 17
	replace case=0 in 17
	replace pop_wpp=(4852) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(2276) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR NHL (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   13   279946    4.64      3.46     1.77     6.11     1.06 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1116*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=10 if cancer_site==.
replace year=4 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** PANCREAS 
tab pop_wpp age_10  if siteiarc==18 & sex==1 //female
tab pop_wpp age_10  if siteiarc==18 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //101 deleted
	keep if siteiarc==18
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,35-44
	** F   25-34,45-54,55-64
	** M   85+
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_wpp=(27544) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_wpp=(28519) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_wpp=(19087) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(19022) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_wpp=(19925) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=4 in 14
	replace case=0 in 14
	replace pop_wpp=(21711) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_wpp=(20130) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=5 in 16
	replace case=0 in 16
	replace pop_wpp=(21592) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=6 in 17
	replace case=0 in 17
	replace pop_wpp=(14849) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(2276) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PANCREATIC CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   15   279946    5.36      3.93     2.15     6.64     1.10 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1116*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=11 if cancer_site==.
replace year=4 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

/* No longer in top 10 after 2015 DCO trace-back completed
** OVARY 
tab pop_wpp age_10  if siteiarc==35

preserve
	drop if age_10==.
	drop if beh!=3 //101 deleted
	keep if siteiarc==35
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** F 0-14,25-34,55-64,85+
	expand 2 in 1
	replace sex=1 in 6
	replace age_10=1 in 6
	replace case=0 in 6
	replace pop_wpp=(27544) in 6
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=3 in 7
	replace case=0 in 7
	replace pop_wpp=(19925) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=6 in 8
	replace case=0 in 8
	replace pop_wpp=(14849) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=9 in 9
	replace case=0 in 9
	replace pop_wpp=(3617) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR OVARIAN CANCER - STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   10   145651    6.87      5.21     2.40     9.93     1.84 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat asir
svmat ci_lower
svmat ci_upper

collapse asir ci_lower ci_upper
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=11 if cancer_site==.
replace year=4 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** KIDNEY 
tab pop_wpp age_10  if siteiarc==42 & sex==1 //female
tab pop_wpp age_10  if siteiarc==42 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //101 deleted
	keep if siteiarc==42
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34
	** F   35-44,85+
	** M   45-54,65-74
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_wpp=(27544) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_wpp=(28519) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_wpp=(19087) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(19022) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_wpp=(19925) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_wpp=(19256) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_wpp=(21711) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=5 in 16
	replace case=0 in 16
	replace pop_wpp=(19220) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=7 in 17
	replace case=0 in 17
	replace pop_wpp=(7795) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(3617) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR KIDNEY CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   12   279946    4.29      2.89     1.44     5.27     0.93 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat asir
svmat ci_lower
svmat ci_upper

collapse asir ci_lower ci_upper
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=12 if cancer_site==.
replace year=4 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore
*/