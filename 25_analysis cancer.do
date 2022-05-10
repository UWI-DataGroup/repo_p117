
cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          20_analysis cancer.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL / Kern ROCKE
    //  date first created      02-DEC-2019
    // 	date last modified      12-AUG-2021
    //  algorithm task          Analyzing combined cancer dataset: (1) Numbers (2) ASIRs (3) Survival
    //  status                  Completed
    //  objective               To have one dataset with cleaned and grouped 2013, 2014 data for inclusion in 2015 cancer report.
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
use "`datapath'\version02\3-output\2013_2014_2015_cancer_nonsurvival" ,clear

** CASE variable
*drop case
gen case=1
label var case "cancer patient (tumour)"
 
*************************************************
** (1.1) Total number of events & multiple events
*************************************************
count //2750
tab dxyr ,m
/*
DiagnosisYe |
         ar |      Freq.     Percent        Cum.
------------+-----------------------------------
       2013 |        859       31.24       31.24
       2014 |        861       31.31       62.55
       2015 |      1,030       37.45      100.00
------------+-----------------------------------
      Total |      2,750      100.00
*/
tab patient dxyr ,m
/*
               |          DiagnosisYear
cancer patient |      2013       2014       2015 |     Total
---------------+---------------------------------+----------
       patient |       849        847      1,012 |     2,708 
separate event |        10         14         18 |        42 
---------------+---------------------------------+----------
         Total |       859        861      1,030 |     2,750
*/

** JC updated AR's 2008 code for identifying MPs
tab ptrectot ,m
tab ptrectot patient ,m
tab ptrectot dxyr ,m

tab eidmp dxyr,m

duplicates list pid, nolabel sepby(pid) 
duplicates tag pid, gen(mppid_analysis)
sort pid cr5id
count if mppid_analysis>0 //84
//list pid topography morph ptrectot eidmp cr5id icd10 dxyr if mppid_analysis>0 ,sepby(pid)
drop mppid_analysis
** Of 2750 patients, 84 had >1 tumour

** note: remember to check in situ vs malignant from behaviour (beh)
tab beh ,m
/*
  Behaviour |      Freq.     Percent        Cum.
------------+-----------------------------------
  Malignant |      2,750      100.00      100.00
------------+-----------------------------------
      Total |      2,750      100.00
*/

** Breakdown of in-situ for SF (taken from dofile 16_final clean)
//tab beh dxyr ,m
/*
           |                DiagnosisYear
 Behaviour |      2008       2013       2014       2015 |     Total
-----------+--------------------------------------------+----------
    Benign |         8          0          0          0 |         8 
 Uncertain |        10          0          0          0 |        10 
   In situ |        83          9         24         19 |       135 
 Malignant |     1,054        876        877      1,038 |     3,845 
-----------+--------------------------------------------+----------
     Total |     1,155        885        901      1,057 |     3,998
*/

*************************************************
** (1.2) DCOs - patients identified only at death
*************************************************
tab basis beh ,m
/*
                      | Behaviour
     BasisOfDiagnosis | Malignant |     Total
----------------------+-----------+----------
                  DCO |       179 |       179 
        Clinical only |       124 |       124 
Clinical Invest./Ult  |       121 |       121 
Exploratory surg./aut |        20 |        20 
Lab test (biochem/imm |        13 |        13 
        Cytology/Haem |       104 |       104 
           Hx of mets |        44 |        44 
        Hx of primary |     2,005 |     2,005 
        Autopsy w/ Hx |        19 |        19 
              Unknown |       121 |       121 
----------------------+-----------+----------
                Total |     2,750 |     2,750  
*/

tab basis dxyr ,m
/*
                      |          DiagnosisYear
     BasisOfDiagnosis |      2013       2014       2015 |     Total
----------------------+---------------------------------+----------
                  DCO |        43         40         96 |       179 
        Clinical only |        21         38         65 |       124 
Clinical Invest./Ult  |        50         27         44 |       121 
Exploratory surg./aut |        10          5          5 |        20 
Lab test (biochem/imm |         5          5          3 |        13 
        Cytology/Haem |        31         45         28 |       104 
           Hx of mets |        13         13         18 |        44 
        Hx of primary |       638        626        741 |     2,005 
        Autopsy w/ Hx |         6          9          4 |        19 
              Unknown |        42         53         26 |       121 
----------------------+---------------------------------+----------
                Total |       859        861      1,030 |     2,750 
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
                      |          DiagnosisYear
     BasisOfDiagnosis |      2013       2014       2015 |     Total
----------------------+---------------------------------+----------
                  DCO |        43         37         95 |       175 
        Clinical only |        20         36         65 |       121 
Clinical Invest./Ult  |        50         26         43 |       119 
Exploratory surg./aut |        10          5          5 |        20 
Lab test (biochem/imm |         5          5          3 |        13 
        Cytology/Haem |        30         45         28 |       103 
           Hx of mets |        13         13         18 |        44 
        Hx of primary |       630        620        725 |     1,975 
        Autopsy w/ Hx |         6          9          4 |        19 
              Unknown |        42         51         26 |       119 
----------------------+---------------------------------+----------
                Total |       849        847      1,012 |     2,708 
*/

//This section assesses DCO % in relation to tumour, patient and behaviour totals
**********
** 2015 **
**********
** As a percentage of all events: 9.32%
cii proportions 1030 96

** As a percentage of all events with known basis: 9.56%
cii proportions 1004 96

** As a percentage of all patients: 9.39%
cii proportions 1012 95

tab basis beh if dxyr==2015 ,m
/*
                      | Behaviour
     BasisOfDiagnosis | Malignant |     Total
----------------------+-----------+----------
                  DCO |        96 |        96 
        Clinical only |        65 |        65 
Clinical Invest./Ult  |        44 |        44 
Exploratory surg./aut |         5 |         5 
Lab test (biochem/imm |         3 |         3 
        Cytology/Haem |        28 |        28 
           Hx of mets |        18 |        18 
        Hx of primary |       741 |       741 
        Autopsy w/ Hx |         4 |         4 
              Unknown |        26 |        26 
----------------------+-----------+----------
                Total |     1,030 |     1,030 
*/
** Below no longer applicable as non-malignant dx were removed from ds (23-Oct-2020)
** As a percentage for all those which were non-malignant: 0%
//cii proportions 18 0
 
** As a percentage of all malignant tumours: 12.95%
//cii proportions 1035 134

**********
** 2014 **
**********
** As a percentage of all events: 4.65%
cii proportions 861 40

** As a percentage of all events with known basis: 4.95%
cii proportions 808 40
 
** As a percentage of all patients: 4.37%
cii proportions 847 37

tab basis beh if dxyr==2014 ,m
/*
                      | Behaviour
     BasisOfDiagnosis | Malignant |     Total
----------------------+-----------+----------
                  DCO |        40 |        40 
        Clinical only |        38 |        38 
Clinical Invest./Ult  |        27 |        27 
Exploratory surg./aut |         5 |         5 
Lab test (biochem/imm |         5 |         5 
        Cytology/Haem |        45 |        45 
           Hx of mets |        13 |        13 
        Hx of primary |       626 |       626 
        Autopsy w/ Hx |         9 |         9 
              Unknown |        53 |        53 
----------------------+-----------+----------
                Total |       861 |       861
*/
** Below no longer applicable as non-malignant dx were removed from ds (23-Oct-2020)
** As a percentage for all those which were non-malignant: 0%
//cii proportions 23 0
 
** As a percentage of all malignant tumours: 4.58%
//cii proportions 874 40

**********
** 2013 **
**********
** As a percentage of all events: 5.01%
cii proportions 859 43

** As a percentage of all events with known basis: 5.26%
cii proportions 817 43
 
** As a percentage of all patients: 5.06%
cii proportions 849 43

tab basis beh if dxyr==2013 ,m
/*
                      | Behaviour
     BasisOfDiagnosis | Malignant |     Total
----------------------+-----------+----------
                  DCO |        43 |        43 
        Clinical only |        21 |        21 
Clinical Invest./Ult  |        50 |        50 
Exploratory surg./aut |        10 |        10 
Lab test (biochem/imm |         5 |         5 
        Cytology/Haem |        31 |        31 
           Hx of mets |        13 |        13 
        Hx of primary |       638 |       638 
        Autopsy w/ Hx |         6 |         6 
              Unknown |        42 |        42 
----------------------+-----------+----------
                Total |       859 |       859
*/
** Below no longer applicable as non-malignant dx were removed from ds (23-Oct-2020)
** As a percentage for all those which were non-malignant: 0%
//cii proportions 9 0
 
** As a percentage of all malignant tumours: 4.92%
//cii proportions 874 43


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
label data "2013-2015 BNR-Cancer analysed data - Numbers"
note: TS This dataset does NOT include population data 
save "`datapath'\version02\2-working\2013_2014_2015_cancer_numbers", replace


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
use "`datapath'\version02\2-working\2013_2014_2015_cancer_numbers", clear

****************************************************************************** 2015 ****************************************************************************************

drop if dxyr!=2015 //1709 deleted
count //1035

***********************
** 3.1 CANCERS BY SITE
***********************
tab icd10 if beh<3 ,m //18 in-situ

tab icd10 ,m //0 missing

tab siteiarc ,m //0 missing

tab sex ,m

** Note: O&U, NMSCs (non-reportable skin cancers) and in-situ tumours excluded from top ten analysis
tab siteiarc if siteiarc!=25 & siteiarc!=64
tab siteiarc ,m //1030 - 38 O&U
tab siteiarc patient

** NS decided on 18march2019 to use IARC site groupings so variable siteiarc will be used instead of sitear
** IARC site variable created based on CI5-XI incidence classifications (see chapter 3 Table 3.1. of that volume) based on icd10
display `"{browse "http://ci5.iarc.fr/CI5-XI/Pages/Chapter3.aspx":IARC-CI5-XI-3}"'


** For annual report - Section 1: Incidence - Table 2a
** Below top 10 code added by JC for 2015
** All sites excl. in-situ, O&U, non-reportable skin cancers
** THIS USED IN ANNUAL REPORT TABLE 1
preserve
drop if siteiarc==25 | siteiarc>60 //38 deleted
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
Prostate (C61)								216		28.24
Breast (C50)								198		25.88
Colon (C18)									112		14.64
Rectum (C19-20)								 48		 6.27
Corpus uteri (C54)							 44		 5.75
Stomach (C16)								 36		 4.71
Lung (incl. trachea and bronchus) (C33-34)	 30		 3.92
Multiple myeloma (C90)						 29		 3.79
Non-Hodgkin lymphoma (C82-86,C96)			 26		 3.40
Pancreas (C25)								 26		 3.40
*/
total count //765
restore

labelbook sex_lab
tab sex ,m

** For annual report - unsure which section of report to be used in
** Below top 10 code added by JC for 2015
** All sites excl. in-situ, O&U, non-reportable skin cancers
** Requested by SF on 16-Oct-2020: Numbers of top 10 by sex
preserve
drop if siteiarc==25 | siteiarc>60 //38 deleted
tab siteiarc ,m
bysort siteiarc: gen n=_N
bysort n siteiarc: gen tag=(_n==1)
replace tag = sum(tag)
sum tag , meanonly
gen top10 = (tag>=(`r(max)'-9))
sum n if tag==(`r(max)'-9), meanonly
replace top10 = 1 if n==`r(max)'
gsort -top10
tab siteiarc top10 if top10!=0
tab siteiarc top10 if top10!=0 & sex==1 //female
tab siteiarc top10 if top10!=0 & sex==2 //male
contract siteiarc top10 sex if top10!=0, freq(count) percent(percentage)
summ
describe
gsort -count
drop top10
/*
year	cancer_site									number	sex
2015	Stomach (C16)								19		female
2015	Stomach (C16)								17		male
2015	Colon (C18)									53		female
2015	Colon (C18)									59		male
2015	Rectum (C19-20)								26		female
2015	Rectum (C19-20)								22		male
2015	Pancreas (C25)								14		female
2015	Pancreas (C25)								12		male
2015	Lung (incl. trachea and bronchus) (C33-34)	 9		female
2015	Lung (incl. trachea and bronchus) (C33-34)	21		male
2015	Breast (C50)								197		female
2015	Breast (C50)								  1		male
2015	Corpus uteri (C54)							 44		female
2015	Prostate (C61)								216		male
2015	Non-Hodgkin lymphoma (C82-86,C96)			 14		female
2015	Non-Hodgkin lymphoma (C82-86,C96)			 12		male
2015	Multiple myeloma (C90)						 21		female
2015	Multiple myeloma (C90)						  8		male
*/
total count //765
drop percentage
gen year=2015
rename count number
rename siteiarc cancer_site
sort cancer_site sex
order year cancer_site number
save "`datapath'\version02\2-working\2015_top10_sex" ,replace
restore

labelbook sex_lab
tab sex ,m

** For annual report - Section 1: Incidence - Table 1
** FEMALE - using IARC's site groupings (excl. in-situ)
preserve
drop if sex==2 //486 deleted
drop if siteiarc>60 //21 deleted
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

gen totpercent=(count/545)*100 //all cancers excl. male(490)
gen alltotpercent=(count/1035)*100 //all cancers
/*
siteiarc				count	percentage	totpercent	alltotpercent
Breast (C50)			197		57.77		36.14679	19.03382
Colon (C18)				 53		15.54		 9.724771	 5.120773
Corpus uteri (C54)		 44		12.90		 8.073395	 4.251208
Rectum (C19-20)			 26		 7.62		 4.770642	 2.512077
Multiple myeloma (C90)	 21		 6.16		 3.853211	 2.028986

*/
total count //341
restore

** For annual report - Section 1: Incidence - Table 1
** Below top 5 code added by JC for 2015
** MALE - using IARC's site groupings
preserve
drop if sex==1 //544 deleted
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

gen totpercent=(count/490)*100 //all cancers excl. female(545)
gen alltotpercent=(count/1035)*100 //all cancers
/*
siteiarc									count	percentage	totpercent	alltotpercent
Prostate (C61)								216		64.48		44.08163	20.86957
Colon (C18)									 59		17.61		12.04082	 5.700483
Rectum (C19-20)								 22		 6.57		 4.489796	 2.125604
Lung (incl. trachea and bronchus) (C33-34)	 21		 6.27		 4.285714	 2.028986
Stomach (C16)								 17		 5.07		 3.469388	 1.642512
*/
total count //335
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


** Create variables for table by basis (DCO% + MV%) in Data Quality section of annual report
** This was done manually in excel for 2014 annual report so the above code has now been updated to be automated in Stata
tab sitecr5db boddqi if boddqi!=. & sitecr5db!=. & sitecr5db<23 & sitecr5db!=2 & sitecr5db!=5 & sitecr5db!=7 & sitecr5db!=9 & sitecr5db!=13 & sitecr5db!=15 & sitecr5db!=16 & sitecr5db!=17 & sitecr5db!=18 & sitecr5db!=19 & sitecr5db!=20
/*
                      |                  basis DQI
          CR5db sites |        MV        DCO       CLIN  UNK.BASIS |     Total
----------------------+--------------------------------------------+----------
Mouth & pharynx (C00- |        23          0          0          0 |        23 
        Stomach (C16) |        23          7          6          0 |        36 
Colon, rectum, anus ( |       143         12          9          2 |       166 
       Pancreas (C25) |         7          7         11          1 |        26 
Lung, trachea, bronch |        13          6         11          0 |        30 
         Breast (C50) |       179         11          5          3 |       198 
         Cervix (C53) |        14          2          0          0 |        16 
Corpus & Uterus NOS ( |        43          2          6          0 |        51 
       Prostate (C61) |       169         25         16          6 |       216 
Lymphoma (C81-85,88,9 |        44          6          5          5 |        60 
   Leukaemia (C91-95) |        11          2          1          2 |        16 
----------------------+--------------------------------------------+----------
                Total |       669         80         70         19 |       838
*/
** All BOD options
preserve
drop if boddqi==. | sitecr5db==. | sitecr5db>22 | sitecr5db==20 | sitecr5db==2 | sitecr5db==5 | sitecr5db==7 | sitecr5db==9 | sitecr5db==13 | (sitecr5db>14 & sitecr5db<21) //260 deleted
contract sitecr5db boddqi, freq(count) percent(percentage)
input
40	1	669	0
40	2	 80	0
40	3	 70 0
40	4	 19 0
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
40 "All sites (in this table)" , modify
label var sitecr5db "CR5db sites"
label values sitecr5db sitecr5db_lab
drop percentage
gen percentage=(count/23)*100 if sitecr5db==1 & boddqi==1
replace percentage=(count/23)*100 if sitecr5db==1 & boddqi==2
replace percentage=(count/23)*100 if sitecr5db==1 & boddqi==3
replace percentage=(count/23)*100 if sitecr5db==1 & boddqi==4
replace percentage=(count/36)*100 if sitecr5db==3 & boddqi==1
replace percentage=(count/36)*100 if sitecr5db==3 & boddqi==2
replace percentage=(count/36)*100 if sitecr5db==3 & boddqi==3
replace percentage=(count/36)*100 if sitecr5db==3 & boddqi==4
replace percentage=(count/166)*100 if sitecr5db==4 & boddqi==1
replace percentage=(count/166)*100 if sitecr5db==4 & boddqi==2
replace percentage=(count/166)*100 if sitecr5db==4 & boddqi==3
replace percentage=(count/166)*100 if sitecr5db==4 & boddqi==4
replace percentage=(count/26)*100 if sitecr5db==6 & boddqi==1
replace percentage=(count/26)*100 if sitecr5db==6 & boddqi==2
replace percentage=(count/26)*100 if sitecr5db==6 & boddqi==3
replace percentage=(count/26)*100 if sitecr5db==6 & boddqi==4
replace percentage=(count/30)*100 if sitecr5db==8 & boddqi==1
replace percentage=(count/30)*100 if sitecr5db==8 & boddqi==2
replace percentage=(count/30)*100 if sitecr5db==8 & boddqi==3
replace percentage=(count/30)*100 if sitecr5db==8 & boddqi==4
replace percentage=(count/198)*100 if sitecr5db==10 & boddqi==1
replace percentage=(count/198)*100 if sitecr5db==10 & boddqi==2
replace percentage=(count/198)*100 if sitecr5db==10 & boddqi==3
replace percentage=(count/198)*100 if sitecr5db==10 & boddqi==4
replace percentage=(count/16)*100 if sitecr5db==11 & boddqi==1
replace percentage=(count/16)*100 if sitecr5db==11 & boddqi==2
replace percentage=(count/16)*100 if sitecr5db==11 & boddqi==3
replace percentage=(count/16)*100 if sitecr5db==11 & boddqi==4
replace percentage=(count/51)*100 if sitecr5db==12 & boddqi==1
replace percentage=(count/51)*100 if sitecr5db==12 & boddqi==2
replace percentage=(count/51)*100 if sitecr5db==12 & boddqi==3
replace percentage=(count/51)*100 if sitecr5db==12 & boddqi==4
replace percentage=(count/216)*100 if sitecr5db==14 & boddqi==1
replace percentage=(count/216)*100 if sitecr5db==14 & boddqi==2
replace percentage=(count/216)*100 if sitecr5db==14 & boddqi==3
replace percentage=(count/216)*100 if sitecr5db==14 & boddqi==4
replace percentage=(count/60)*100 if sitecr5db==21 & boddqi==1
replace percentage=(count/60)*100 if sitecr5db==21 & boddqi==2
replace percentage=(count/60)*100 if sitecr5db==21 & boddqi==3
replace percentage=(count/60)*100 if sitecr5db==21 & boddqi==4
replace percentage=(count/16)*100 if sitecr5db==22 & boddqi==1
replace percentage=(count/16)*100 if sitecr5db==22 & boddqi==2
replace percentage=(count/16)*100 if sitecr5db==22 & boddqi==3
replace percentage=(count/16)*100 if sitecr5db==22 & boddqi==4
replace percentage=(count/838)*100 if sitecr5db==40 & boddqi==1
replace percentage=(count/838)*100 if sitecr5db==40 & boddqi==2
replace percentage=(count/838)*100 if sitecr5db==40 & boddqi==3
replace percentage=(count/838)*100 if sitecr5db==40 & boddqi==4
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
replace icd10dqi="All" if sitecr5db==40

putdocx clear
putdocx begin

// Create a paragraph
putdocx pagebreak
putdocx paragraph, style(Title)
putdocx text ("CANCER 2015 Annual Report: DQI"), bold
putdocx textblock begin
Date Prepared: 12-AUG-2021. 
Prepared by: JC using Stata & Redcap data release date: 21-May-2021. 
Generated using Dofiles: 15_clean cancer.do and 20_analysis cancer.do
putdocx textblock end
putdocx paragraph, style(Heading1)
putdocx text ("Basis - MV%, DCO%, CLIN%, UNK%"), bold
putdocx paragraph, halign(center)
putdocx text ("Basis (# tumours/n=1,030)"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename sitecr5db Cancer_Site
rename boddqi Total_DQI
rename count Cases
rename percentage Pct_DQI
rename icd10dqi ICD10
putdocx table tbl_bod = data("Cancer_Site Total_DQI Cases Pct_DQI ICD10"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_bod(1,.), bold

putdocx save "`datapath'\version02\3-output\2021-08-12_DQI.docx", append
putdocx clear

save "`datapath'\version02\2-working\2015_cancer_dqi_basis.dta" ,replace
label data "BNR-Cancer 2015 Data Quality Index - Basis"
notes _dta :These data prepared for Natasha Sobers - 2015 annual report
restore
/*
tab sitecr5db boddqi if boddqi!=. & boddqi<3 & sitecr5db!=. & sitecr5db<23 & sitecr5db!=2 & sitecr5db!=5 & sitecr5db!=7 & sitecr5db!=9 & sitecr5db!=13 & sitecr5db!=15 & sitecr5db!=16 & sitecr5db!=17 & sitecr5db!=18 & sitecr5db!=19 & sitecr5db!=20
/*
                      |       basis DQI
          CR5db sites |        MV        DCO |     Total
----------------------+----------------------+----------
Mouth & pharynx (C00- |        23          0 |        23 
        Stomach (C16) |        23          7 |        30 
Colon, rectum, anus ( |       143         12 |       155 
       Pancreas (C25) |         7          7 |        14 
Lung, trachea, bronch |        13          6 |        19 
         Breast (C50) |       179         11 |       190 
         Cervix (C53) |        14          2 |        16 
Corpus & Uterus NOS ( |        43          2 |        45 
       Prostate (C61) |       169         25 |       194 
Lymphoma (C81-85,88,9 |        44          6 |        50 
   Leukaemia (C91-95) |        11          2 |        13 
----------------------+----------------------+----------
                Total |       669         80 |       749
*/
labelbook sitecr5db_lab

** MV + DCO %
preserve
drop if boddqi==. | boddqi>2 | sitecr5db==. | sitecr5db>22 | sitecr5db==20 | sitecr5db==2 | sitecr5db==5 | sitecr5db==7 | sitecr5db==9 | sitecr5db==13 | (sitecr5db>14 & sitecr5db<21) //260 deleted
contract sitecr5db boddqi, freq(count) percent(percentage)
input
34	1	669	0
34	2	 80	0
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
gen percentage=(count/23)*100 if sitecr5db==1 & boddqi==1
replace percentage=(count/23)*100 if sitecr5db==1 & boddqi==2
replace percentage=(count/30)*100 if sitecr5db==3 & boddqi==1
replace percentage=(count/30)*100 if sitecr5db==3 & boddqi==2
replace percentage=(count/155)*100 if sitecr5db==4 & boddqi==1
replace percentage=(count/155)*100 if sitecr5db==4 & boddqi==2
replace percentage=(count/14)*100 if sitecr5db==6 & boddqi==1
replace percentage=(count/14)*100 if sitecr5db==6 & boddqi==2
replace percentage=(count/19)*100 if sitecr5db==8 & boddqi==1
replace percentage=(count/19)*100 if sitecr5db==8 & boddqi==2
replace percentage=(count/190)*100 if sitecr5db==10 & boddqi==1
replace percentage=(count/190)*100 if sitecr5db==10 & boddqi==2
replace percentage=(count/16)*100 if sitecr5db==11 & boddqi==1
replace percentage=(count/16)*100 if sitecr5db==11 & boddqi==2
replace percentage=(count/45)*100 if sitecr5db==12 & boddqi==1
replace percentage=(count/45)*100 if sitecr5db==12 & boddqi==2
replace percentage=(count/194)*100 if sitecr5db==14 & boddqi==1
replace percentage=(count/194)*100 if sitecr5db==14 & boddqi==2
replace percentage=(count/50)*100 if sitecr5db==21 & boddqi==1
replace percentage=(count/50)*100 if sitecr5db==21 & boddqi==2
replace percentage=(count/13)*100 if sitecr5db==22 & boddqi==1
replace percentage=(count/13)*100 if sitecr5db==22 & boddqi==2
replace percentage=(count/749)*100 if sitecr5db==34 & boddqi==1
replace percentage=(count/749)*100 if sitecr5db==34 & boddqi==2
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
putdocx paragraph, style(Title)
putdocx text ("CANCER 2015 Annual Report: DQI"), bold
putdocx textblock begin
Date Prepared: 12-AUG-2021. 
Prepared by: JC using Stata & Redcap data release date: 21-May-2021. 
Generated using Dofiles: 15_clean cancer.do and 20_analysis cancer.do
putdocx textblock end
putdocx paragraph, style(Heading1)
putdocx text ("Basis - MV% + DCO%"), bold
putdocx paragraph, halign(center)
putdocx text ("Basis (# tumours/n=1,030)"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename sitecr5db Cancer_Site
rename boddqi Total_DQI
rename count Cases
rename percentage Pct_DQI
rename icd10dqi ICD10
putdocx table tbl_bod = data("Cancer_Site Total_DQI Cases Pct_DQI ICD10"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_bod(1,.), bold

putdocx save "`datapath'\version02\3-output\2021-08-12_DQI.docx", append
putdocx clear

save "`datapath'\version02\2-working\2015_cancer_dqi_basis_mvdco.dta" ,replace
label data "BNR-Cancer 2015 Data Quality Index - Basis"
notes _dta :These data prepared for Natasha Sobers - 2015 annual report
restore


tab sitecr5db boddqi if boddqi!=. & boddqi>2 & sitecr5db!=. & sitecr5db<23 & sitecr5db!=2 & sitecr5db!=5 & sitecr5db!=7 & sitecr5db!=9 & sitecr5db!=13 & sitecr5db!=15 & sitecr5db!=16 & sitecr5db!=17 & sitecr5db!=18 & sitecr5db!=19 & sitecr5db!=20
/*
                      |       basis DQI
          CR5db sites |      CLIN  UNK.BASIS |     Total
----------------------+----------------------+----------
        Stomach (C16) |         6          0 |         6 
Colon, rectum, anus ( |         9          2 |        11 
       Pancreas (C25) |        11          1 |        12 
Lung, trachea, bronch |        11          0 |        11 
         Breast (C50) |         5          3 |         8 
Corpus & Uterus NOS ( |         6          0 |         6 
       Prostate (C61) |        16          6 |        22 
Lymphoma (C81-85,88,9 |         5          5 |        10 
   Leukaemia (C91-95) |         1          2 |         3 
----------------------+----------------------+----------
                Total |        70         19 |        89
*/
** CLIN + UNK %
preserve
drop if boddqi==. | boddqi<3 | sitecr5db==. | sitecr5db>22 | sitecr5db==20 | sitecr5db==2 | sitecr5db==5 | sitecr5db==7 | sitecr5db==9 | sitecr5db==13 | (sitecr5db>14 & sitecr5db<21) //260 deleted
contract sitecr5db boddqi, freq(count) percent(percentage)
input
34	3	70	0
34	4	19	0
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
gen percentage=(count/23)*100 if sitecr5db==1 & boddqi==3
replace percentage=(count/23)*100 if sitecr5db==1 & boddqi==4
replace percentage=(count/30)*100 if sitecr5db==3 & boddqi==3
replace percentage=(count/30)*100 if sitecr5db==3 & boddqi==4
replace percentage=(count/155)*100 if sitecr5db==4 & boddqi==3
replace percentage=(count/155)*100 if sitecr5db==4 & boddqi==4
replace percentage=(count/14)*100 if sitecr5db==6 & boddqi==3
replace percentage=(count/14)*100 if sitecr5db==6 & boddqi==4
replace percentage=(count/19)*100 if sitecr5db==8 & boddqi==3
replace percentage=(count/19)*100 if sitecr5db==8 & boddqi==4
replace percentage=(count/190)*100 if sitecr5db==10 & boddqi==3
replace percentage=(count/190)*100 if sitecr5db==10 & boddqi==4
replace percentage=(count/16)*100 if sitecr5db==11 & boddqi==3
replace percentage=(count/16)*100 if sitecr5db==11 & boddqi==4
replace percentage=(count/45)*100 if sitecr5db==12 & boddqi==3
replace percentage=(count/45)*100 if sitecr5db==12 & boddqi==4
replace percentage=(count/194)*100 if sitecr5db==14 & boddqi==3
replace percentage=(count/194)*100 if sitecr5db==14 & boddqi==4
replace percentage=(count/50)*100 if sitecr5db==21 & boddqi==3
replace percentage=(count/50)*100 if sitecr5db==21 & boddqi==4
replace percentage=(count/13)*100 if sitecr5db==22 & boddqi==3
replace percentage=(count/13)*100 if sitecr5db==22 & boddqi==4
replace percentage=(count/749)*100 if sitecr5db==34 & boddqi==3
replace percentage=(count/749)*100 if sitecr5db==34 & boddqi==4
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
putdocx paragraph, style(Title)
putdocx text ("CANCER 2015 Annual Report: DQI"), bold
putdocx textblock begin
Date Prepared: 12-AUG-2021. 
Prepared by: JC using Stata & Redcap data release date: 21-May-2021. 
Generated using Dofiles: 15_clean cancer.do and 20_analysis cancer.do
putdocx textblock end
putdocx paragraph, style(Heading1)
putdocx text ("Basis - CLIN% + UNK%"), bold
putdocx paragraph, halign(center)
putdocx text ("Basis (# tumours/n=1,030)"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename sitecr5db Cancer_Site
rename boddqi Total_DQI
rename count Cases
rename percentage Pct_DQI
rename icd10dqi ICD10
putdocx table tbl_bod = data("Cancer_Site Total_DQI Cases Pct_DQI ICD10"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_bod(1,.), bold

putdocx save "`datapath'\version02\3-output\2021-08-12_DQI.docx", append
putdocx clear

save "`datapath'\version02\2-working\2015_cancer_dqi_basis_clinunk.dta" ,replace
label data "BNR-Cancer 2015 Data Quality Index - Basis"
notes _dta :These data prepared for Natasha Sobers - 2015 annual report
restore
*/

preserve
** % tumours - site,age
tab siteagedqi
contract siteagedqi, freq(count) percent(percentage)

putdocx clear
putdocx begin

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Unknown - Site, DOB & Age"), bold
putdocx paragraph, halign(center)
putdocx text ("Site,DOB,Age (# tumours/n=1,030)"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename siteagedqi Total_DQI
rename count Total_Records
rename percentage Pct_DQI
putdocx table tbl_site = data("Total_DQI Total_Records Pct_DQI"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_site(1,.), bold

putdocx save "`datapath'\version02\3-output\2021-08-12_DQI.docx", append
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
use "`datapath'\version02\2-working\2013_2014_2015_cancer_numbers", clear

****************************************************************************** 2015 ****************************************************************************************
drop if dxyr!=2015 //1720 deleted

count //1030

** Determine sequential order of 2014 sites from 2015 top 10
tab siteiarc ,m

preserve
drop if siteiarc==25 | siteiarc>60 //38 deleted
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
  5. |        5                           Corpus uteri (C54) |
     |-------------------------------------------------------|
  6. |        6                                Stomach (C16) |
  7. |        7   Lung (incl. trachea and bronchus) (C33-34) |
  8. |        8                       Multiple myeloma (C90) |
  9. |        9                               Pancreas (C25) |
 10. |       10            Non-Hodgkin lymphoma (C82-86,C96) |
     |-------------------------------------------------------|
 11. |       11                                 Kidney (C64) |
 12. |       12                                  Ovary (C56) |
 13. |       13                           Cervix uteri (C53) |
 14. |       14                                Bladder (C67) |
 15. |       15                                Thyroid (C73) |
     |-------------------------------------------------------|
 16. |       16                    Gallbladder etc. (C23-24) |
 17. |       17                             Oesophagus (C15) |
 18. |       18               Brain, nervous system (C70-72) |
 19. |       19                        Small intestine (C17) |
 20. |       20                       Melanoma of skin (C43) |
     |-------------------------------------------------------|
 21. |       21                     Uterus unspecified (C55) |
 22. |       22                                 Larynx (C32) |
 23. |       23                     Lymphoid leukaemia (C91) |
 24. |       24                                   Anus (C21) |
 25. |       25                                  Liver (C22) |
     |-------------------------------------------------------|
 26. |       26                              Tongue (C01-02) |
 27. |       27                   Myeloid leukaemia (C92-94) |
 28. |       28           Myeloproliferative disorders (MPD) |
 29. |       29                       Hodgkin lymphoma (C81) |
 30. |       30              Myelodysplastic syndromes (MDS) |
     |-------------------------------------------------------|
 31. |       31         Connective and soft tissue (C47+C49) |
 32. |       32                  Leukaemia unspecified (C95) |
 33. |       33                               Mouth (C03-06) |
 34. |       34                                 Tonsil (C09) |
 35. |       35                            Nasopharynx (C11) |
     |-------------------------------------------------------|
 36. |       36                                 Vagina (C52) |
 37. |       37                                 Testis (C62) |
 38. |       38                  Nose, sinuses etc. (C30-31) |
 39. |       39            Other female genital organs (C57) |
 40. |       40                                  Vulva (C51) |
     |-------------------------------------------------------|
 41. |       41                                Bone (C40-41) |
 42. |       42                      Salivary gland (C07-08) |
 43. |       43                                    Eye (C69) |
 44. |       44                       Other oropharynx (C10) |
 45. |       45                                 Ureter (C66) |
     |-------------------------------------------------------|
 46. |       46                   Other urinary organs (C68) |
 47. |       47                                  Penis (C60) |
 48. |       48               Other thoracic organs (C37-38) |
 49. |       49                    Pharynx unspecified (C14) |
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
    matched                             1,035  (_merge==3)
    -----------------------------------------
*/
** No unmatched records

** SF requested by email on 16-Oct-2020 age and sex specific rates for top 10 cancers
/*
What is age-specific incidence rate? 
Age-specific rates provide information on the incidence of a particular event in an age group relative to the total number of people at risk of that event in the same age group.

What is age-standardised incidence rate?
The age-standardized incidence rate is the summary rate that would have been observed, given the schedule of age-specific rates, in a population with the age composition of some reference population, often called the standard population.
*/
preserve
collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex siteiarc)
gen incirate=case/pop_wpp*100000
drop if siteiarc!=39 & siteiarc!=29 & siteiarc!=13 & siteiarc!=33 ///
		& siteiarc!=14 & siteiarc!=21 & siteiarc!=53 & siteiarc!=11 ///
		& siteiarc!=18 & siteiarc!=55
//by sex,sort: tab age_10 incirate ,m
sort siteiarc age_10 sex
//list incirate age_10 sex
//list incirate age_10 sex if siteiarc==13

format incirate %04.2f
gen year=2015
rename siteiarc cancer_site
rename incirate age_specific_rate
drop pfu case pop_wpp
order year cancer_site sex age_10 age_specific_rate
save "`datapath'\version02\2-working\2015_top10_age+sex_rates" ,replace
restore

** Check for missing age as these would need to be added to the median group for that site when assessing ASIRs to prevent creating an outlier
count if age==.|age==999 //0

** Below saved in pathway: 
//X:\The University of the West Indies\DataGroup - repo_data\data_p117\version02\2-working\WPP_population by sex_2013.txt
tab pop_wpp age_10  if sex==1 //female
tab pop_wpp age_10  if sex==2 //male

** Next, IRs for invasive tumours only
preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	
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
  | 1030   285327   360.99    231.46   216.88   246.83     7.57 |
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
gen percent=number/1035*100
replace percent=round(percent,0.01)

label define cancer_site_lab 1 "all" 2 "prostate" 3 "breast" 4 "colon" 5 "rectum" 6 "corpus uteri" 7 "stomach" ///
							 8 "lung" 9 "multiple myeloma" 10 "non-hodgkin lymphoma" 11 "pancreas" ,modify
label values cancer_site cancer_site_lab
label define year_lab 1 "2015" 2 "2014" 3 "2013" ,modify
label values year year_lab
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** Next, IRs for invasive tumours FEMALE only
preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	drop if sex==2 //490 deleted
	
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
  |  544   147779   368.12    228.21   208.13   249.81    10.50 |
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
gen percent=number/1035*100
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
	drop if sex==1 //545 deleted
	
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
  |  486   137548   353.33    238.14   216.89   261.05    11.12 |
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
gen percent=number/1035*100
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
	drop if age_10==. //0 deleted
	drop if beh!=3 //0 deleted
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
  |  216   137548   157.04    102.42    89.02   117.44     7.11 |
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
gen percent=number/1035*100
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
	drop if age_10==. //0 deleted
	drop if beh!=3 //0 deleted
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
  |  216   137548   157.04    102.42    89.02   117.44     7.11 |
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
gen percent=number/490*100
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
	drop if beh!=3 //0 deleted
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
  |  197   147779   133.31     89.54    76.79   103.90     6.78 |
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
gen percent=number/1035*100
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
	drop if beh!=3 //0 deleted
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
  |  197   147779   133.31     89.54    76.79   103.90     6.78 |
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
gen percent=number/545*100
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
	drop if beh!=3 //0 deleted
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
  |  112   285327   39.25     23.96    19.60    29.11     2.36 |
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
gen percent=number/1035*100
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
	drop if beh!=3 //0 deleted
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
  |   53   147779   35.86     21.99    16.27    29.27     3.20 |
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
gen percent=number/545*100
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
	drop if beh!=3 //0 deleted
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
  |   59   137548   42.89     26.91    20.34    35.13     3.65 |
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
gen percent=number/490*100
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
	drop if beh!=3 //0 deleted
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
gen percent=number/1035*100
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
	drop if beh!=3 //0 deleted
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
gen percent=number/545*100
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
	drop if beh!=3 //0 deleted
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
  |   22   137548   15.99     11.80     7.33    18.12     2.64 |
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
gen percent=number/490*100
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
	drop if beh!=3 //0 deleted
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
gen percent=number/1035*100
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
	drop if beh!=3 //0 deleted
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
gen percent=number/545*100
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
	drop if beh!=3 //0 deleted
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
gen percent=number/1035*100
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
	drop if beh!=3 //0 deleted
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
gen percent=number/490*100
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
	drop if beh!=3 //0 deleted
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
gen percent=number/1035*100
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
	drop if beh!=3 //0 deleted
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
gen percent=number/490*100
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
	drop if beh!=3 //0 deleted
	keep if siteiarc==55
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	** F 45-54
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
** THIS IS FOR MULTIPLE MYELOMA CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   29   285327   10.16      6.01     3.97     8.86     1.19 |
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
gen percent=number/1035*100
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
	drop if beh!=3 //0 deleted
	keep if siteiarc==55
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	** F 45-54
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
gen percent=number/545*100
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
	drop if beh!=3 //0 deleted
	keep if siteiarc==53
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24
	** F   85+
	** M   55-64
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=1 in 13
	replace case=0 in 13
	replace pop_wpp=(25537) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(26626) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=2 in 15
	replace case=0 in 15
	replace pop_wpp=(18761) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_wpp=(19111) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=6 in 17
	replace case=0 in 17
	replace pop_wpp=(16493) in 17
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
  |   26   285327    9.11      6.70     4.27    10.05     1.42 |
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
gen percent=number/1035*100
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
	drop if beh!=3 //0 deleted
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
gen percent=number/1035*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=11 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

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
use "`datapath'\version02\2-working\2013_2014_2015_cancer_numbers", clear

****************************************************************************** 2014 ****************************************************************************************
drop if dxyr!=2014 //1889 deleted
count //861

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
 11. |       11            Non-Hodgkin lymphoma (C82-86,C96) |
 12. |       12                           Cervix uteri (C53) |
 13. |       13                                  Liver (C22) |
 14. |       14                                Thyroid (C73) |
 15. |       15                                 Kidney (C64) |
     |-------------------------------------------------------|
 16. |       16                    Gallbladder etc. (C23-24) |
 17. |       17                                  Ovary (C56) |
 18. |       18                             Oesophagus (C15) |
 19. |       19                       Melanoma of skin (C43) |
 20. |       20                                 Larynx (C32) |
     |-------------------------------------------------------|
 21. |       21                     Lymphoid leukaemia (C91) |
 22. |       22         Connective and soft tissue (C47+C49) |
 23. |       23               Brain, nervous system (C70-72) |
 24. |       24                        Small intestine (C17) |
 25. |       25                                 Tonsil (C09) |
     |-------------------------------------------------------|
 26. |       26                   Myeloid leukaemia (C92-94) |
 27. |       27                  Nose, sinuses etc. (C30-31) |
 28. |       28                              Tongue (C01-02) |
 29. |       29                         Hypopharynx (C12-13) |
 30. |       30           Myeloproliferative disorders (MPD) |
     |-------------------------------------------------------|
 31. |       31                       Other oropharynx (C10) |
 32. |       32                                  Penis (C60) |
 33. |       33                            Nasopharynx (C11) |
 34. |       34                       Hodgkin lymphoma (C81) |
 35. |       35                  Leukaemia unspecified (C95) |
     |-------------------------------------------------------|
 36. |       36                                Bone (C40-41) |
 37. |       37                                   Anus (C21) |
 38. |       38                               Mouth (C03-06) |
 39. |       39                                  Vulva (C51) |
 40. |       40                                 Vagina (C52) |
     |-------------------------------------------------------|
 41. |       41                           Mesothelioma (C45) |
 42. |       42                                 Testis (C62) |
 43. |       43           Immunoproliferative diseases (C88) |
 44. |       44                      Salivary gland (C07-08) |
 45. |       45                        Other endocrine (C75) |
     |-------------------------------------------------------|
 46. |       46              Myelodysplastic syndromes (MDS) |
     +-------------------------------------------------------+
*/
drop if order_id>20
save "`datapath'\version02\2-working\siteorder_2014" ,replace
restore


** For annual report - unsure which section of report to be used in
** Below top 10 code added by JC for 2014
** All sites excl. in-situ, O&U, non-reportable skin cancers
** Requested by SF on 16-Oct-2020: Numbers of top 10 by sex
tab siteiarc ,m

preserve
drop if siteiarc==25 | siteiarc>60 //39 deleted
tab siteiarc sex ,m
contract siteiarc sex, freq(count) percent(percentage)
summ 
describe
gsort -count
gen order_id=_n
list order_id siteiarc sex
/*
     +----------------------------------------------------------------+
     | order_id                                     siteiarc      sex |
     |----------------------------------------------------------------|
  1. |        1                               Prostate (C61)     male |
  2. |        2                                 Breast (C50)   female |
  3. |        3                                  Colon (C18)   female |
  4. |        4                                  Colon (C18)     male |
  5. |        5                           Corpus uteri (C54)   female |
     |----------------------------------------------------------------|
  6. |        6   Lung (incl. trachea and bronchus) (C33-34)     male |
  7. |        7                           Cervix uteri (C53)   female |
  8. |        8                                Bladder (C67)     male |
  9. |        9                       Multiple myeloma (C90)     male |
 10. |       10                       Multiple myeloma (C90)   female |
     |----------------------------------------------------------------|
 11. |       11                                Stomach (C16)     male |
 12. |       12                              Rectum (C19-20)   female |
 13. |       13   Lung (incl. trachea and bronchus) (C33-34)   female |
 14. |       14            Non-Hodgkin lymphoma (C82-86,C96)     male |
 15. |       15                              Rectum (C19-20)     male |
     |----------------------------------------------------------------|
 16. |       16                               Pancreas (C25)     male |
 17. |       17                                Bladder (C67)   female |
 18. |       18                                  Ovary (C56)   female |
 19. |       19                                Thyroid (C73)   female |
 20. |       20                               Pancreas (C25)   female |
     |----------------------------------------------------------------|
 21. |       21                                Stomach (C16)   female |
 22. |       22                                  Liver (C22)     male |
 23. |       23                    Gallbladder etc. (C23-24)     male |
 24. |       24                                 Larynx (C32)     male |
 25. |       25                             Oesophagus (C15)     male |
     |----------------------------------------------------------------|
 26. |       26                                 Kidney (C64)   female |
 27. |       27                                  Liver (C22)   female |
 28. |       28               Brain, nervous system (C70-72)     male |
 29. |       29                                 Tonsil (C09)     male |
 30. |       30                       Melanoma of skin (C43)     male |
     |----------------------------------------------------------------|
 31. |       31                                 Breast (C50)     male |
 32. |       32                  Nose, sinuses etc. (C30-31)     male |
 33. |       33                                 Kidney (C64)     male |
 34. |       34                     Lymphoid leukaemia (C91)     male |
 35. |       35         Connective and soft tissue (C47+C49)     male |
     |----------------------------------------------------------------|
 36. |       36                       Melanoma of skin (C43)   female |
 37. |       37                    Gallbladder etc. (C23-24)   female |
 38. |       38                         Hypopharynx (C12-13)     male |
 39. |       39                                  Penis (C60)     male |
 40. |       40                        Small intestine (C17)     male |
     |----------------------------------------------------------------|
 41. |       41            Non-Hodgkin lymphoma (C82-86,C96)   female |
 42. |       42                             Oesophagus (C15)   female |
 43. |       43                              Tongue (C01-02)     male |
 44. |       44         Connective and soft tissue (C47+C49)   female |
 45. |       45                       Other oropharynx (C10)     male |
     |----------------------------------------------------------------|
 46. |       46                     Lymphoid leukaemia (C91)   female |
 47. |       47                   Myeloid leukaemia (C92-94)   female |
 48. |       48                       Hodgkin lymphoma (C81)     male |
 49. |       49                            Nasopharynx (C11)   female |
 50. |       50           Myeloproliferative disorders (MPD)     male |
     |----------------------------------------------------------------|
 51. |       51                                 Testis (C62)     male |
 52. |       52                        Small intestine (C17)   female |
 53. |       53                   Myeloid leukaemia (C92-94)     male |
 54. |       54                                 Vagina (C52)   female |
 55. |       55                                  Vulva (C51)   female |
     |----------------------------------------------------------------|
 56. |       56                                 Larynx (C32)   female |
 57. |       57                           Mesothelioma (C45)     male |
 58. |       58                                Bone (C40-41)     male |
 59. |       59                  Leukaemia unspecified (C95)     male |
 60. |       60               Brain, nervous system (C70-72)   female |
     |----------------------------------------------------------------|
 61. |       61                                   Anus (C21)   female |
 62. |       62                               Mouth (C03-06)     male |
 63. |       63                            Nasopharynx (C11)     male |
 64. |       64                               Mouth (C03-06)   female |
 65. |       65                  Leukaemia unspecified (C95)   female |
     |----------------------------------------------------------------|
 66. |       66                                Thyroid (C73)     male |
 67. |       67                              Tongue (C01-02)   female |
 68. |       68                      Salivary gland (C07-08)     male |
 69. |       69                         Hypopharynx (C12-13)   female |
 70. |       70           Myeloproliferative disorders (MPD)   female |
     |----------------------------------------------------------------|
 71. |       71                                 Tonsil (C09)   female |
 72. |       72                        Other endocrine (C75)     male |
 73. |       73           Immunoproliferative diseases (C88)   female |
 74. |       74                  Nose, sinuses etc. (C30-31)   female |
 75. |       75              Myelodysplastic syndromes (MDS)     male |
     |----------------------------------------------------------------|
 76. |       76                       Hodgkin lymphoma (C81)   female |
 77. |       77                                   Anus (C21)     male |
     +----------------------------------------------------------------+
*/
drop if siteiarc!=39 & siteiarc!=29 & siteiarc!=13 & siteiarc!=33 ///
		& siteiarc!=14 & siteiarc!=21 & siteiarc!=53 & siteiarc!=11 ///
		& siteiarc!=18 & siteiarc!=55
drop percentage order_id
gen year=2014
rename count number
rename siteiarc cancer_site
sort cancer_site sex
order year cancer_site number
save "`datapath'\version02\2-working\2014_top10_sex" ,replace
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

    matched                               861  (_merge==3)
    -----------------------------------------
*/

** SF requested by email on 16-Oct-2020 age and sex specific rates for top 10 cancers
/*
What is age-specific incidence rate? 
Age-specific rates provide information on the incidence of a particular event in an age group relative to the total number of people at risk of that event in the same age group.

What is age-standardised incidence rate?
The age-standardized incidence rate is the summary rate that would have been observed, given the schedule of age-specific rates, in a population with the age composition of some reference population, often called the standard population.
*/
preserve
collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex siteiarc)
gen incirate=case/pop_wpp*100000
drop if siteiarc!=39 & siteiarc!=29 & siteiarc!=13 & siteiarc!=33 ///
		& siteiarc!=14 & siteiarc!=21 & siteiarc!=53 & siteiarc!=11 ///
		& siteiarc!=18 & siteiarc!=55
//by sex,sort: tab age_10 incirate ,m
sort siteiarc age_10 sex
//list incirate age_10 sex
//list incirate age_10 sex if siteiarc==13

format incirate %04.2f
gen year=2014
rename siteiarc cancer_site
rename incirate age_specific_rate
drop pfu case pop_wpp
order year cancer_site sex age_10 age_specific_rate
save "`datapath'\version02\2-working\2014_top10_age+sex_rates" ,replace
restore


** Check for missing age as these would need to be added to the median group for that site when assessing ASIRs to prevent creating an outlier
count if age==.|age==999 //1 - missing age_10 from merge as noted below
//list pid cr5id siteiarc if age==.|age==999


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
  |  861   284825   302.29    201.83   188.07   216.38     7.15 |
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
gen percent=number/857*100
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
  |  177   137169   129.04     87.78    75.17   102.07     6.72 |
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
gen percent=number/857*100
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
  |  151   147656   102.26     68.54    57.64    81.03     5.84 |
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
gen percent=number/857*100
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
  |  104   284825   36.51     23.66    19.21    28.92     2.41 |
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
gen percent=number/857*100
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
  |   26   284825    9.13      5.95     3.84     8.91     1.24 |
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
gen percent=number/857*100
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
  |   37   147656   25.06     15.78    11.03    22.10     2.72 |
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
gen percent=number/857*100
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
gen percent=number/857*100
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
gen percent=number/857*100
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
  |   30   284825   10.53      6.93     4.65    10.05     1.32 |
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
gen percent=number/857*100
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
gen percent=number/857*100
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
gen percent=number/857*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=11 if cancer_site==.
replace year=2 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

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
use "`datapath'\version02\2-working\2013_2014_2015_cancer_numbers", clear


****************************************************************************** 2013 ****************************************************************************************
drop if dxyr!=2013 //1892 deleted
count //852

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
 12. |       12                       Multiple myeloma (C90) |
 13. |       13                                Thyroid (C73) |
 14. |       14                                Bladder (C67) |
 15. |       15                                  Ovary (C56) |
     |-------------------------------------------------------|
 16. |       16                   Myeloid leukaemia (C92-94) |
 17. |       17                                   Anus (C21) |
 18. |       18                    Gallbladder etc. (C23-24) |
 19. |       19                             Oesophagus (C15) |
 20. |       20                                  Liver (C22) |
     |-------------------------------------------------------|
 21. |       21                     Lymphoid leukaemia (C91) |
 22. |       22                               Mouth (C03-06) |
 23. |       23                     Uterus unspecified (C55) |
 24. |       24                       Hodgkin lymphoma (C81) |
 25. |       25                                 Larynx (C32) |
     |-------------------------------------------------------|
 26. |       26               Brain, nervous system (C70-72) |
 27. |       27           Myeloproliferative disorders (MPD) |
 28. |       28                       Melanoma of skin (C43) |
 29. |       29                        Small intestine (C17) |
 30. |       30         Connective and soft tissue (C47+C49) |
     |-------------------------------------------------------|
 31. |       31                              Tongue (C01-02) |
 32. |       32                                 Vagina (C52) |
 33. |       33                       Other oropharynx (C10) |
 34. |       34                                  Penis (C60) |
 35. |       35                    Pharynx unspecified (C14) |
     |-------------------------------------------------------|
 36. |       36                      Salivary gland (C07-08) |
 37. |       37                  Nose, sinuses etc. (C30-31) |
 38. |       38                  Leukaemia unspecified (C95) |
 39. |       39                            Nasopharynx (C11) |
 40. |       40            Other female genital organs (C57) |
     |-------------------------------------------------------|
 41. |       41                                Bone (C40-41) |
 42. |       42                           Mesothelioma (C45) |
 43. |       43                                  Vulva (C51) |
 44. |       44               Other thoracic organs (C37-38) |
 45. |       45                         Hypopharynx (C12-13) |
     |-------------------------------------------------------|
 46. |       46                                 Tonsil (C09) |
     +-------------------------------------------------------+
*/
drop if order_id>20
save "`datapath'\version02\2-working\siteorder_2013" ,replace
restore


** For annual report - unsure which section of report to be used in
** Below top 10 code added by JC for 2013
** All sites excl. in-situ, O&U, non-reportable skin cancers
** Requested by SF on 16-Oct-2020: Numbers of top 10 by sex
tab siteiarc ,m

preserve
drop if siteiarc==25 | siteiarc>60 //38 deleted
tab siteiarc sex ,m
contract siteiarc sex, freq(count) percent(percentage)
summ 
describe
gsort -count
gen order_id=_n
list order_id siteiarc sex
/*
     +----------------------------------------------------------------+
     | order_id                                     siteiarc      sex |
     |----------------------------------------------------------------|
  1. |        1                               Prostate (C61)     male |
  2. |        2                                 Breast (C50)   female |
  3. |        3                                  Colon (C18)   female |
  4. |        4                                  Colon (C18)     male |
  5. |        5                           Cervix uteri (C53)   female |
     |----------------------------------------------------------------|
  6. |        6                           Corpus uteri (C54)   female |
  7. |        7                              Rectum (C19-20)     male |
  8. |        8   Lung (incl. trachea and bronchus) (C33-34)     male |
  9. |        9                              Rectum (C19-20)   female |
 10. |       10            Non-Hodgkin lymphoma (C82-86,C96)     male |
     |----------------------------------------------------------------|
 11. |       11                                 Kidney (C64)     male |
 12. |       12                                  Ovary (C56)   female |
 13. |       13                                Stomach (C16)     male |
 14. |       14                                Thyroid (C73)   female |
 15. |       15                               Pancreas (C25)     male |
     |----------------------------------------------------------------|
 16. |       16                                Bladder (C67)     male |
 17. |       17                       Multiple myeloma (C90)     male |
 18. |       18            Non-Hodgkin lymphoma (C82-86,C96)   female |
 19. |       19                               Pancreas (C25)   female |
 20. |       20                                 Kidney (C64)   female |
     |----------------------------------------------------------------|
 21. |       21                   Myeloid leukaemia (C92-94)   female |
 22. |       22   Lung (incl. trachea and bronchus) (C33-34)   female |
 23. |       23                    Gallbladder etc. (C23-24)   female |
 24. |       24                               Mouth (C03-06)     male |
 25. |       25                                Stomach (C16)   female |
     |----------------------------------------------------------------|
 26. |       26                                   Anus (C21)     male |
 27. |       27                     Uterus unspecified (C55)   female |
 28. |       28                                   Anus (C21)   female |
 29. |       29                    Gallbladder etc. (C23-24)     male |
 30. |       30                       Multiple myeloma (C90)   female |
     |----------------------------------------------------------------|
 31. |       31                                  Liver (C22)     male |
 32. |       32                                 Larynx (C32)     male |
 33. |       33                     Lymphoid leukaemia (C91)   female |
 34. |       34                     Lymphoid leukaemia (C91)     male |
 35. |       35                             Oesophagus (C15)     male |
     |----------------------------------------------------------------|
 36. |       36                                Thyroid (C73)     male |
 37. |       37                                 Breast (C50)     male |
 38. |       38                   Myeloid leukaemia (C92-94)     male |
 39. |       39                                Bladder (C67)   female |
 40. |       40                       Hodgkin lymphoma (C81)   female |
     |----------------------------------------------------------------|
 41. |       41                       Other oropharynx (C10)     male |
 42. |       42                              Tongue (C01-02)     male |
 43. |       43                                 Vagina (C52)   female |
 44. |       44                             Oesophagus (C15)   female |
 45. |       45           Myeloproliferative disorders (MPD)     male |
     |----------------------------------------------------------------|
 46. |       46           Myeloproliferative disorders (MPD)   female |
 47. |       47            Other female genital organs (C57)   female |
 48. |       48         Connective and soft tissue (C47+C49)     male |
 49. |       49                       Melanoma of skin (C43)     male |
 50. |       50                    Pharynx unspecified (C14)     male |
     |----------------------------------------------------------------|
 51. |       51                                  Liver (C22)   female |
 52. |       52                            Nasopharynx (C11)     male |
 53. |       53               Brain, nervous system (C70-72)     male |
 54. |       54                                  Penis (C60)     male |
 55. |       55               Brain, nervous system (C70-72)   female |
     |----------------------------------------------------------------|
 56. |       56                        Small intestine (C17)   female |
 57. |       57                       Hodgkin lymphoma (C81)     male |
 58. |       58                         Hypopharynx (C12-13)   female |
 59. |       59                                 Tonsil (C09)     male |
 60. |       60                        Small intestine (C17)     male |
     |----------------------------------------------------------------|
 61. |       61                  Nose, sinuses etc. (C30-31)     male |
 62. |       62                  Nose, sinuses etc. (C30-31)   female |
 63. |       63                           Mesothelioma (C45)     male |
 64. |       64                       Melanoma of skin (C43)   female |
 65. |       65                      Salivary gland (C07-08)   female |
     |----------------------------------------------------------------|
 66. |       66                                  Vulva (C51)   female |
 67. |       67         Connective and soft tissue (C47+C49)   female |
 68. |       68                  Leukaemia unspecified (C95)   female |
 69. |       69               Other thoracic organs (C37-38)     male |
 70. |       70                  Leukaemia unspecified (C95)     male |
     |----------------------------------------------------------------|
 71. |       71                                Bone (C40-41)     male |
 72. |       72                      Salivary gland (C07-08)     male |
     +----------------------------------------------------------------+
*/
drop if siteiarc!=39 & siteiarc!=29 & siteiarc!=13 & siteiarc!=33 ///
		& siteiarc!=14 & siteiarc!=21 & siteiarc!=53 & siteiarc!=11 ///
		& siteiarc!=18 & siteiarc!=55
drop percentage order_id
gen year=2013
rename count number
rename siteiarc cancer_site
sort cancer_site sex
order year cancer_site number
save "`datapath'\version02\2-working\2013_top10_sex" ,replace
restore

**********************************************************************************
** ASIR and 95% CI for Table 1 using AR's site groupings - using WHO World popn **
**					WORLD POPULATION PROSPECTS (WPP): 2013						**
*drop pfu
gen pfu=1 // for % year if not whole year collected; not done for cancer        **
**********************************************************************************
** NSobers confirmed use of WPP populations
labelbook sex_lab

********************************************************************
* (2.4c) IR age-standardised to WHO world popn - ALL TUMOURS: 2013
********************************************************************
** Using WHO World Standard Population
//tab siteiarc ,m

*drop _merge
merge m:m sex age_10 using "`datapath'\version02\2-working\pop_wpp_2013-10"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                               859  (_merge==3)
    -----------------------------------------
*/
** None unmatched

** SF requested by email on 16-Oct-2020 age and sex specific rates for top 10 cancers
/*
What is age-specific incidence rate? 
Age-specific rates provide information on the incidence of a particular event in an age group relative to the total number of people at risk of that event in the same age group.

What is age-standardised incidence rate?
The age-standardized incidence rate is the summary rate that would have been observed, given the schedule of age-specific rates, in a population with the age composition of some reference population, often called the standard population.
*/
preserve
collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex siteiarc)
gen incirate=case/pop_wpp*100000
drop if siteiarc!=39 & siteiarc!=29 & siteiarc!=13 & siteiarc!=33 ///
		& siteiarc!=14 & siteiarc!=21 & siteiarc!=53 & siteiarc!=11 ///
		& siteiarc!=18 & siteiarc!=55
//by sex,sort: tab age_10 incirate ,m
sort siteiarc age_10 sex
//list incirate age_10 sex
//list incirate age_10 sex if siteiarc==13

format incirate %04.2f
gen year=2013
rename siteiarc cancer_site
rename incirate age_specific_rate
drop pfu case pop_wpp
order year cancer_site sex age_10 age_specific_rate
save "`datapath'\version02\2-working\2013_top10_age+sex_rates" ,replace
restore


** Check for missing age as these would need to be added to the median group for that site when assessing ASIRs to prevent creating an outlier
count if age==.|age==999 //0

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
  |  859   284294   302.15    205.13   191.20   219.88     7.24 |
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
gen percent=number/852*100
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
  |  178   136769   130.15     90.99    77.97   105.70     6.93 |
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
gen percent=number/852*100
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
  |  134   147525   90.83     61.58    51.13    73.66     5.62 |
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
gen percent=number/852*100
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
  |  109   284294   38.34     24.25    19.79    29.51     2.41 |
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
gen percent=number/852*100
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
gen percent=number/852*100
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
gen percent=number/852*100
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
gen percent=number/852*100
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
  |   28   284294    9.85      6.50     4.29     9.54     1.29 |
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
gen percent=number/852*100
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
gen percent=number/852*100
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
  |   24   284294    8.44      6.12     3.81     9.36     1.36 |
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
gen percent=number/852*100
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
gen percent=number/852*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=11 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

/*
clear

*************************************************************** 2015 BSS pop *******************************************************

/* 
	08jan21 NS requested an excel workbook to compare BSS vs WPP ASIRs and ASMRs for 2015.
	Background: when SF requested age-specific mortality rates, JC noticed she generated the ASMRs using BSS pop instead of WPP pop,
				as agreed upon. JC unsure if this was a mistake or intentional so that our ASMRs would be similar to MoHW's,
				who use BSS pop for their mortality rates.
	Methods: JC manually compiled stats into excel workbook using below Stata datasets from version02\2-working
				- ASIRs
				- ASIRs_bss
				- ASMRs
				- ASMRs_wpp
			 Excel workbook stored in path: 
			 X:\The University of the West Indies\FORDE, Shelly-Ann - BNR\REPORTS\Annual Reports\2015 Cancer Report\BSS vs WPP comparison 2015 ASIRs ASMRs.xlsx
*/

* *********************************************
* ANALYSIS: SECTION 3 - cancer sites
* Covering:
*  3.1  Classification of cancer by site
*  3.2 	ASIRs by site; overall, men and women
* *********************************************
** NOTE: bb popn and WHO popn data prepared by IH are ALL coded M=2 and F=1
** Above note by AR from 2008 dofile

** Load the dataset
use "`datapath'\version02\2-working\2013_2014_2015_cancer_numbers", clear

****************************************************************************** 2015 BSS pop ****************************************************************************************
drop if dxyr!=2015 //1709 deleted

count //1035



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
merge m:m sex age_10 using "`datapath'\version02\2-working\pop_bss_2015-10"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                             1,035  (_merge==3)
    -----------------------------------------
*/
** No unmatched records

** Check for missing age as these would need to be added to the median group for that site when assessing ASIRs to prevent creating an outlier
count if age==.|age==999 //0

** Below saved in pathway: 
//X:\The University of the West Indies\DataGroup - repo_data\data_p117\version02\2-working\WPP_population by sex_2013.txt
tab pop_bss age_10  if sex==1 //female
tab pop_bss age_10  if sex==2 //male

** Next, IRs for invasive tumours only
preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** No missing age groups
		
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bss

distrate case pop_bss using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR ALL SITES (INVASIVE TUMOURS ONLY) - STD TO WHO WORLD POPN

/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  | 1035   276633   374.14    260.10   243.97   277.07     8.37 |
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
gen percent=number/1035*100
replace percent=round(percent,0.01)

label define cancer_site_lab 1 "all" 2 "prostate" 3 "breast" 4 "colon" 5 "rectum" 6 "corpus uteri" 7 "stomach" ///
							 8 "lung" 9 "multiple myeloma" 10 "non-hodgkin lymphoma" 11 "pancreas" ,modify
label values cancer_site cancer_site_lab
label define year_lab 1 "2015" 2 "2014" 3 "2013" ,modify
label values year year_lab
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_bss" ,replace
restore


** Next, IRs for invasive tumours FEMALE only
preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	drop if sex==2 //490 deleted
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** No missing age groups
		
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bss

distrate case pop_bss using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR ALL SITES (INVASIVE TUMOURS ONLY-FEMALE) - STD TO WHO WORLD POPN

/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  545   143485   379.83    249.80   228.15   273.05    11.31 |
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
gen percent=number/1035*100
replace percent=round(percent,0.01)

label define cancer_site_lab 1 "all" 2 "breast" 3 "colon" 4 "corpus uteri" 5 "rectum" 6 "multiple myeloma" ,modify
label values cancer_site cancer_site_lab
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_bss_female" ,replace
restore

** Next, IRs for invasive tumours MALE only
preserve
	drop if age_10==.
	drop if beh!=3 //18 deleted
	drop if sex==1 //545 deleted
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** No missing age groups
		
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bss

distrate case pop_bss using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR ALL SITES (INVASIVE TUMOURS ONLY-FEMALE) - STD TO WHO WORLD POPN

/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  490   133148   368.01    277.61   253.25   303.79    12.73 |
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
gen percent=number/1035*100
replace percent=round(percent,0.01)

label define cancer_site_lab 1 "all" 2 "prostate" 3 "colon" 4 "rectum" 5 "lung" 6 "stomach" ,modify
label values cancer_site cancer_site_lab
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_bss_male" ,replace
restore


********************************
** Next, IRs by site and year **
********************************
** PROSTATE
tab pop_bss age_10 if siteiarc==39 //male

preserve
	drop if age_10==. //0 deleted
	drop if beh!=3 //0 deleted
	keep if siteiarc==39 // prostate only
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M 0-14,15-24,25-34
	expand 2 in 1
	replace sex=2 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_bss=(26626) in 7
	sort age_10	
	
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_bss=(19111)  in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_bss=(18440) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bss

distrate case pop_bss using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  217   132285   164.04    121.24   105.51   138.78     8.34 |
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
gen percent=number/1035*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_bss" 
replace cancer_site=2 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_bss" ,replace
restore

** PROSTATE - for male top5 table
tab pop_bss age_10 if siteiarc==39 //male

preserve
	drop if age_10==. //0 deleted
	drop if beh!=3 //0 deleted
	keep if siteiarc==39 // prostate only
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M 0-14,15-24,25-34
	expand 2 in 1
	replace sex=2 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_bss=(26626) in 7
	sort age_10	
	
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_bss=(19111)  in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_bss=(18440) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bss

distrate case pop_bss using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  217   132285   164.04    121.24   105.51   138.78     8.34 |
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
gen percent=number/490*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_bss_male" 
replace cancer_site=2 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_bss_male" ,replace
restore

** BREAST - excluded male breast cancer
tab pop_bss age_10  if siteiarc==29 & sex==1 //female
tab pop_bss age_10  if siteiarc==29 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==29 //200 breast only 
	drop if sex==2 //1 deleted
	//excluded the 1 male as it would be potential confidential breach if reported separately
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_bss=(25537) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=2 in 9
	replace case=0 in 9
	replace pop_bss=(18761) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command
sort age_10
total pop_bss


distrate case pop_bss using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BC (FEMALE) - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  197   142913   137.85     96.28    82.77   111.47     7.19 |
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
gen percent=number/1035*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_bss" 
replace cancer_site=3 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_bss" ,replace
restore

** BREAST - for female top5 table
tab pop_bss age_10  if siteiarc==29 & sex==1 //female
tab pop_bss age_10  if siteiarc==29 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==29 //200 breast only 
	drop if sex==2 //1 deleted
	//excluded the 1 male as it would be potential confidential breach if reported separately
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_bss=(25537) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=2 in 9
	replace case=0 in 9
	replace pop_bss=(18761) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command
sort age_10
total pop_bss


distrate case pop_bss using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BC (FEMALE) - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  197   142913   137.85     96.28    82.77   111.47     7.19 |
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
gen percent=number/545*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_bss_female" 
replace cancer_site=2 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_bss_female" ,replace
restore

** COLON 
tab pop_bss age_10  if siteiarc==13 & sex==1 //female
tab pop_bss age_10  if siteiarc==13 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24
	** M   25-34
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_bss=(25537) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_bss=(26626) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_bss=(18761) in 16
	sort age_10

	expand 2 in 1
	replace sex=2 in 17
	replace age_10=2 in 17
	replace case=0 in 17
	replace pop_bss=(19111) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=3 in 18
	replace case=0 in 18
	replace pop_bss=(18440) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bss

distrate case pop_bss using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  114   275198   41.42     27.45    22.51    33.22     2.66 |
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
gen percent=number/1035*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_bss" 
replace cancer_site=4 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_bss" ,replace
restore

** COLON - female only for top5 table
preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24
	** M   25-34
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_bss=(25537) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_bss=(26626) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_bss=(18761) in 16
	sort age_10

	expand 2 in 1
	replace sex=2 in 17
	replace age_10=2 in 17
	replace case=0 in 17
	replace pop_bss=(19111) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=3 in 18
	replace case=0 in 18
	replace pop_bss=(18440) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bss

drop if sex==2 //9 deleted: for breast cancer - female ONLY

distrate case pop_bss using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (FEMALE)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   54   142913   37.79     24.75    18.39    32.76     3.55 |
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
gen percent=number/545*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_bss_female" 
replace cancer_site=3 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_bss_female" ,replace
restore

** COLON - male only for top5 table
preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24
	** M   25-34
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_bss=(25537) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_bss=(26626) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_bss=(18761) in 16
	sort age_10

	expand 2 in 1
	replace sex=2 in 17
	replace age_10=2 in 17
	replace case=0 in 17
	replace pop_bss=(19111) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=3 in 18
	replace case=0 in 18
	replace pop_bss=(18440) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bss

drop if sex==1 //9 deleted: for breast cancer - male ONLY

distrate case pop_bss using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (MALE)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   60   132285   45.36     31.89    24.26    41.35     4.22 |
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
gen percent=number/490*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_bss_male" 
replace cancer_site=3 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_bss_male" ,replace
restore


** RECTUM 
tab pop_bss age_10  if siteiarc==14 & sex==1 //female
tab pop_bss age_10  if siteiarc==14 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==14
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24
	** M 85+
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_bss=(25537) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_bss=(26626) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_bss=(18761) in 16
	sort age_10

	expand 2 in 1
	replace sex=2 in 17
	replace age_10=2 in 17
	replace case=0 in 17
	replace pop_bss=(19111) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_bss=(2487) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bss

distrate case pop_bss using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RECTAL CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   47   276064   17.03     11.97     8.68    16.15     1.84 |
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
gen percent=number/1035*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_bss" 
replace cancer_site=5 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_bss" ,replace
restore

** RECTUM - female only for top5 table
preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==14
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24
	** M 85+
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_bss=(25537) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_bss=(26626) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_bss=(18761) in 16
	sort age_10

	expand 2 in 1
	replace sex=2 in 17
	replace age_10=2 in 17
	replace case=0 in 17
	replace pop_bss=(19111) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_bss=(2487) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bss

drop if sex==2 // for rectal cancer - female ONLY

distrate case pop_bss using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RECTAL CANCER (FEMALE)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   26   142913   18.19     11.07     6.98    16.88     2.42 |
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
gen percent=number/545*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_bss_female" 
replace cancer_site=5 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_bss_female" ,replace
restore

** RECTUM - male only for top5 table
preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==14
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24
	** M 85+
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_bss=(25537) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_bss=(26626) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_bss=(18761) in 16
	sort age_10

	expand 2 in 1
	replace sex=2 in 17
	replace age_10=2 in 17
	replace case=0 in 17
	replace pop_bss=(19111) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_bss=(2487) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bss

drop if sex==1 // for rectal cancer - male ONLY

distrate case pop_bss using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RECTAL CANCER (MALE)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   21   133151   15.77     12.75     7.87    19.63     2.89 |
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
gen percent=number/490*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_bss_male" 
replace cancer_site=4 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_bss_male" ,replace
restore


** CORPUS UTERI
tab pop_bss age_10 if siteiarc==33

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==33 // corpus uteri only
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-14,15-24,25-34
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_bss=(25537) in 7
	sort age_10	
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_bss=(18761) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_bss=(18963) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bss

distrate case pop_bss using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CORPUS UTERI - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   44   142643   30.85     20.74    14.96    28.20     3.26 |
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
gen percent=number/1035*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_bss" 
replace cancer_site=6 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_bss" ,replace
restore

** CORPUS UTERI - for female top 5 table
preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==33 // corpus uteri only
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-14,15-24,25-34
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_bss=(25537) in 7
	sort age_10	
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_bss=(18761) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_bss=(18963) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bss

distrate case pop_bss using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CORPUS UTERI - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   44   142643   30.85     20.74    14.96    28.20     3.26 |
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
gen percent=number/545*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_bss_female" 
replace cancer_site=4 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_bss_female" ,replace
restore


** STOMACH 
tab pop_bss age_10  if siteiarc==11 & sex==1 //female
tab pop_bss age_10  if siteiarc==11 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==11
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_bss=(25537) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_bss=(26626) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bss=(18761) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_bss=(19111) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bss=(18963) in 15
	sort age_10

	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_bss=(18440) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_bss=(20315) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=4 in 18
	replace case=0 in 18
	replace pop_bss=(19218) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bss

distrate case pop_bss using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR STOMACH CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   36   274005   13.14      7.62     5.25    10.83     1.36 |
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
gen percent=number/1035*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_bss" 
replace cancer_site=7 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_bss" ,replace
restore

** STOMACH - male only for top5 table
preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==11
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_bss=(25537) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_bss=(26626) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bss=(18761) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_bss=(19111) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bss=(18963) in 15
	sort age_10

	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_bss=(18440) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_bss=(20315) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=4 in 18
	replace case=0 in 18
	replace pop_bss=(19218) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bss

drop if sex==1 // for stomach cancer - male ONLY

distrate case pop_bss using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR STOMACH CANCER (MALE)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   17   131937   12.88      9.24     5.34    15.09     2.38 |
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
gen percent=number/490*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_bss_male" 
replace cancer_site=6 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_bss_male" ,replace
restore


** LUNG
tab pop_bss age_10 if siteiarc==21 & sex==1 //female
tab pop_bss age_10 if siteiarc==21 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==21
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24,25-34
	** F   35-44,45-54
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_bss=(25537) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_bss=(26626) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bss=(18761) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_bss=(19111) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bss=(18963) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_bss=(18440) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_bss=(20315) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=5 in 18
	replace case=0 in 18
	replace pop_bss=(21585) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bss

distrate case pop_bss using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR LUNG CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   30   274196   10.94      7.46     4.98    10.82     1.43 |
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
gen percent=number/1035*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_bss" 
replace cancer_site=8 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_bss" ,replace
restore

** LUNG - male only for top5 table
preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==21
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24,25-34
	** F   35-44,45-54
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_bss=(25537) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_bss=(26626) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bss=(18761) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_bss=(19111) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bss=(18963) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_bss=(18440) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_bss=(20315) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=5 in 18
	replace case=0 in 18
	replace pop_bss=(21585) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bss

drop if sex==1 // for lung cancer - male ONLY

distrate case pop_bss using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR LUNG CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   21   132285   15.87     12.06     7.44    18.64     2.74 |
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
gen percent=number/490*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_bss_male" 
replace cancer_site=5 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_bss_male" ,replace
restore


** MULTIPLE MYELOMA
tab pop_bss age_10 if siteiarc==55 & sex==1 //female
tab pop_bss age_10 if siteiarc==55 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==55
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	** F 45-54
	** M 75-84
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_bss=(25537) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_bss=(26626) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_bss=(18761) in 11
	sort age_10

	expand 2 in 1
	replace sex=2 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_bss=(19111) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_bss=(18963) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_bss=(18440) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_bss=(20315) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_bss=(19218) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=5 in 17
	replace case=0 in 17
	replace pop_bss=(21585) in 17
	sort age_10
		
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=8 in 18
	replace case=0 in 18
	replace pop_bss=(5564) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bss

distrate case pop_bss using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR MULTIPLE MYELOMA CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   28   274558   10.20      6.70     4.40     9.89     1.34 |
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
gen percent=number/1035*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_bss" 
replace cancer_site=9 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_bss" ,replace
restore

** MULTIPLE MYELOMA - female only for top5 table
preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==55
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	** F 45-54
	** M 75-84
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_bss=(25537) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_bss=(26626) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_bss=(18761) in 11
	sort age_10

	expand 2 in 1
	replace sex=2 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_bss=(19111) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_bss=(18963) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_bss=(18440) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_bss=(20315) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_bss=(19218) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=5 in 17
	replace case=0 in 17
	replace pop_bss=(21585) in 17
	sort age_10
		
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=8 in 18
	replace case=0 in 18
	replace pop_bss=(5564) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bss

drop if sex==2 // for MM - female ONLY

distrate case pop_bss using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR MM CANCER (FEMALE)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   21   141911   14.80      8.82     5.35    13.97     2.10 |
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
gen percent=number/545*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_bss_female" 
replace cancer_site=6 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_bss_female" ,replace
restore


** NON-HODGKIN LYMPHOMA 
tab pop_bss age_10  if siteiarc==53 & sex==1 //female
tab pop_bss age_10  if siteiarc==53 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==53
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24
	** F   85+
	** M   55-64
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=1 in 13
	replace case=0 in 13
	replace pop_bss=(25537) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_bss=(26626) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=2 in 15
	replace case=0 in 15
	replace pop_bss=(18761) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_bss=(19111) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=6 in 17
	replace case=0 in 17
	replace pop_bss=(16493) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_bss=(3975) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bss

distrate case pop_bss using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR NHL (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   26   278139    9.35      7.06     4.53    10.53     1.48 |
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
gen percent=number/1035*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_bss" 
replace cancer_site=10 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_bss" ,replace
restore


** PANCREAS 
tab pop_bss age_10  if siteiarc==18 & sex==1 //female
tab pop_bss age_10  if siteiarc==18 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==18
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	** F   45-54
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_bss=(25537) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_bss=(26626) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_bss=(18761) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bss=(19111) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_bss=(18963) in 14
	sort age_10

	expand 2 in 1
	replace sex=2 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bss=(18440) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_bss=(20315) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_bss=(19218) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=5 in 18
	replace case=0 in 18
	replace pop_bss=(21585) in 18
	sort age_10
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bss

distrate case pop_bss using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PANCREATIC CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   26   273848    9.49      5.61     3.61     8.47     1.19 |
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
gen percent=number/1035*100
replace percent=round(percent,0.01)

append using "`datapath'\version02\2-working\ASIRs_bss" 
replace cancer_site=11 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version02\2-working\ASIRs_bss" ,replace
restore
*/