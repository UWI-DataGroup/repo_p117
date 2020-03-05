cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          20_analysis cancer.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL / Kern ROCKE
    //  date first created      02-DEC-2019
    // 	date last modified      26-FEB-2020
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


************************************************************************* 
* SECTION 1: NUMBERS 
*        (1.1) total number & number of multiple events
*        (1.2) DCOs
*    	 (1.3) tumours by age-group
**************************************************************************
 
** LOAD cancer incidence dataset INCLUDING DCOs
use "`datapath'\version02\3-output\2008_2013_2014_2015_cancer_nonsurvival" ,clear

** CASE variable
*drop case
gen case=1
label var case "cancer patient (tumour)"
 
*************************************************
** (1.1) Total number of events & multiple events
*************************************************
count //3335
tab dxyr ,m
/*
DiagnosisYe |
         ar |      Freq.     Percent        Cum.
------------+-----------------------------------
       2008 |        807       24.20       24.20
       2013 |        797       23.90       48.10
       2014 |        840       25.19       73.28
       2015 |        891       26.72      100.00
------------+-----------------------------------
      Total |      3,335      100.00

*/
tab patient dxyr ,m //1,025; 912 patients & 15 MPs (Check this)
/*
              |                DiagnosisYear
cancer patient |      2008       2013       2014       2015 |     Total
---------------+--------------------------------------------+----------
       patient |       800        785        823        871 |     3,279 
separate event |         7         12         17         20 |        56 
---------------+--------------------------------------------+----------
         Total |       807        797        840        891 |     3,335 

*/

** JC updated AR's 2008 code for identifying MPs
tab ptrectot ,m
tab ptrectot patient ,m
tab ptrectot dxyr ,m

tab eidmp dxyr,m

duplicates list pid, nolabel sepby(pid) 
duplicates tag pid, gen(mppid_analysis)
sort pid cr5id
count if mppid_analysis>0 //115
//list pid topography morph ptrectot eidmp cr5id icd10 dxyr if mppid_analysis>0 ,sepby(pid)
 
** Of 3335 patients, 56 had >1 tumour

** note: remember to check in situ vs malignant from behaviour (beh)
tab beh ,m // 2417 malignant; 0 in-situ (excluded from this dataset) [Check this]


*************************************************
** (1.2) DCOs - patients identified only at death
*************************************************
tab basis beh ,m // Note there is no in-situ in the new dataset [check this]
/*
                      | Behaviour
     BasisOfDiagnosis | Malignant |     Total
----------------------+-----------+----------
                  DCO |       145 |       145 
        Clinical only |       106 |       106 
Clinical Invest./Ult  |       149 |       149 
Exploratory surg./aut |        26 |        26 
Lab test (biochem/imm |        15 |        15 
        Cytology/Haem |       131 |       131 
           Hx of mets |        68 |        68 
        Hx of primary |     2,557 |     2,557 
        Autopsy w/ Hx |        23 |        23 
              Unknown |       115 |       115 
----------------------+-----------+----------
                Total |     3,335 |     3,335 


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
                  DCO |        51         43         38         13 |       145 
        Clinical only |        16         18         35         37 |       106 
Clinical Invest./Ult  |        38         50         29         32 |       149 
Exploratory surg./aut |         7          9          5          5 |        26 
Lab test (biochem/imm |         6          3          3          3 |        15 
        Cytology/Haem |        31         30         43         27 |       131 
           Hx of mets |        24         13         13         18 |        68 
        Hx of primary |       629        582        613        733 |     2,557 
        Autopsy w/ Hx |         4          6          9          4 |        23 
              Unknown |         1         43         52         19 |       115 
----------------------+--------------------------------------------+----------
                Total |       807        797        840        891 |     3,335
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
        Hx of primary |       622        572        604        715 |     2,513 
        Autopsy w/ Hx |         4          6          9          4 |        23 
              Unknown |         1         43         50         19 |       113 
----------------------+--------------------------------------------+----------
                Total |       800        785        823        871 |     3,279
*/

//CHECK THIS section with Jacqui
**********
** 2015 **
**********
** As a percentage of all events: 1.46%
//cii proportions 891 13
cii proportions 892 13

** As a percentage of all events with known basis: 1.49%
//cii proportions 872 13
cii proportions 873 13

** As a percentage of all patients: 1.38%
//cii proportions 871 12
cii proportions 872 12

** As a percentage for all those which were non-malignant - JC: there were none for 2014 // 0%
//cii proportions 24 0
 
** As a percentage of all malignant tumours: 14.62%
//cii proportions 891 13 
**********
** 2014 **
**********
** As a percentage of all events: 4.52%
cii proportions 840 38

** As a percentage of all events with known basis: 4.82%
cii proportions 788 38
 
** As a percentage of all patients: 4.25%
cii proportions 823 35
**********
** 2013 **
**********
** As a percentage of all events: 5.40%
cii proportions 797 43

** As a percentage of all events with known basis: 5.70%
cii proportions 754 43
 
** As a percentage of all patients: 5.48%
cii proportions 785 43
**********
** 2008 **
**********
** As a percentage of all events: 6.32%
cii proportions 807 51

** As a percentage of all events with known basis: 6.33%
cii proportions 806 51
 
** As a percentage of all patients: 6.38%
cii proportions 800 51


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
drop if dxyr!=2015 //2444 deleted

***********************
** 3.1 CANCERS BY SITE
***********************
tab icd10 if beh<3 ,m //0 in-situ

tab icd10 ,m //0 missing

tab siteiarc ,m //0 missing

tab sex ,m

** Note: O&U, NMSCs (non-reportable skin cancers) and in-situ tumours excluded from top ten analysis
tab siteiarc if siteiarc!=25 & siteiarc!=64
tab siteiarc ,m //927 - 0 insitu; 45 O&U [check this - the last bit]
tab siteiarc patient

** NS decided on 18march2019 to use IARC site groupings so variable siteiarc will be used instead of sitear
** IARC site variable created based on CI5-XI incidence classifications (see chapter 3 Table 3.1. of that volume) based on icd10
display `"{browse "http://ci5.iarc.fr/CI5-XI/Pages/Chapter3.aspx":IARC-CI5-XI-3}"'


** For annual report - Section 1: Incidence - Table 2a
** Below top 10 code added by JC for 2015
** All sites excl. in-situ, O&U, non-reportable skin cancers
** THIS USED IN ANNUAL REPORT TABLE 1
preserve
drop if siteiarc==25 | siteiarc>60 //30 deleted
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
*/
total count //673; 674
restore

labelbook sex_lab
tab sex ,m

** For annual report - Section 1: Incidence - Table 1
** FEMALE - using IARC's site groupings (excl. in-situ)
preserve
drop if sex==2 //421 deleted
drop if siteiarc>60 //14 deleted
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

gen totpercent=(count/471)*100 //all cancers excl. male(421)
gen alltotpercent=(count/892)*100 //all cancers
/*
siteiarc			count	percentage	totpercent	alltotpercent
Breast (C50)		181		58.96		38.42887	20.31425
Colon (C18)			 44		14.33		9.341825	4.938272
Corpus uteri (C54)	 42		13.68		8.917197	4.713805
Rectum (C19-20)		 24		7.82		5.095541	2.693603
Ovary (C56)			 16		5.21		3.397027	1.795735
*/
total count //307
restore

** For annual report - Section 1: Incidence - Table 1
** Below top 5 code added by JC for 2015
** MALE - using IARC's site groupings
preserve
drop if sex==1 //471 deleted
drop if siteiarc==25 | siteiarc>60 //16 deleted
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

gen totpercent=(count/421)*100 //all cancers excl. female(471)
gen alltotpercent=(count/892)*100 //all cancers
/*
siteiarc									count	percentage	totpercent	alltotpercent
Prostate (C61)								180		63.60		42.75534	20.17937
Colon (C18)									 54		19.08		12.8266		6.053812
Rectum (C19-20)								 19		6.71		4.513064	2.130045
Lung (incl. trachea and bronchus) (C33-34)	 16		5.65		3.800475	1.793722
Stomach (C16)								 14		4.95		3.325416	1.569507
*/
total count //283
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
tab sex if sitecr5db==20 //used this table in annual report (see excel 2014 data quality indicators in BNR OneDrive)
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
gen boddqi=1 if basis>4 & basis <9 //782 changes; 
replace boddqi=2 if basis==0 //13 changes
replace boddqi=3 if basis>0 & basis<5 //77 changes
replace boddqi=4 if basis==9 //19 changes
label define boddqi_lab 1 "MV" 2 "DCO"  3 "CLIN" 4 "UNK.BASIS" , modify
label var boddqi "basis DQI"
label values boddqi boddqi_lab

gen siteagedqi=1 if siteiarc==61 //30 changes
replace siteagedqi=2 if age==.|age==999 //0 changes
replace siteagedqi=3 if dob==. & siteagedqi!=2 //2 changes
replace siteagedqi=4 if siteiarc==61 & siteagedqi!=1 //0 changes
replace siteagedqi=5 if sex==.|sex==99 //0 changes
label define siteagedqi_lab 1 "O&U SITE" 2 "UNK.AGE" 3 "UNK.DOB" 4 "O&U+UNK.AGE/DOB" 5 "UNK.SEX", modify
label var siteagedqi "site/age DQI"
label values siteagedqi siteagedqi_lab

tab boddqi ,m
generate rectot=_N //892
tab boddqi rectot,m

tab siteagedqi ,m
tab siteagedqi rectot,m

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
putdocx text ("Basis (# tumours/n=892)"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename siteicd10 Site
rename boddqi Total_DQI
rename count Total_Records
rename percentage Pct_DQI
putdocx table tbl_bod = data("Site Total_DQI Total_Records Pct_DQI"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_bod(1,.), bold

putdocx save "`datapath'\version02\3-output\2020-03-05_DQI.docx", append
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
putdocx paragraph, style(Heading1)
putdocx text ("Unknown - Site, DOB & Age"), bold
putdocx paragraph, halign(center)
putdocx text ("Site,DOB,Age (# tumours/n=892)"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename siteagedqi Total_DQI
rename count Total_Records
rename percentage Pct_DQI
putdocx table tbl_site = data("Total_DQI Total_Records Pct_DQI"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_site(1,.), bold

putdocx save "`datapath'\version02\3-output\2020-03-05_DQI.docx", append
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
drop if dxyr!=2015 //2444 deleted

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
*/
drop if order_id>20
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
*/
** No unmatched records

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
  |  892   285327   312.62    208.24   194.25   223.03     7.27 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
gen cancer_site=1
gen year=1
matrix list r(adj)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat asir
svmat ci_lower
svmat ci_upper

collapse cancer_site year asir ci_lower ci_upper
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
label define cancer_site_lab 1 "all" 2 "breast" 3 "prostate" 4 "colon" 5 "rectum" 6 "corpus uteri" 7 "stomach" ///
							 8 "lung" 9 "non-hodgkin lymphoma" 10 "multiple myeloma" 11 "ovary" 12 "kidney" ,modify
label values cancer_site cancer_site_lab
label define year_lab 1 "2015" 2 "2014" 3 "2013" 4 "2008" ,modify
label values year year_lab
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** Next, IRs for invasive tumours FEMALE only
preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	drop if sex==2 //421 deleted
	
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
  |  471   147779   318.72    207.57   188.19   228.53    10.15 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
gen cancer_site=1
matrix list r(adj)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat asir
svmat ci_lower
svmat ci_upper

collapse cancer_site asir ci_lower ci_upper
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
label define cancer_site_lab 1 "all" 2 "breast" 3 "colon" 4 "corpus uteri" 5 "rectum" 6 "ovary" ,modify
label values cancer_site cancer_site_lab
save "`datapath'\version02\2-working\ASIRs_female" ,replace
restore

** Next, IRs for invasive tumours MALE only
preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	drop if sex==1 //471 deleted
	
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
  |  421   137548   306.07    211.51   191.33   233.37    10.58 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
gen cancer_site=1
matrix list r(adj)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat asir
svmat ci_lower
svmat ci_upper

collapse cancer_site asir ci_lower ci_upper
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
label define cancer_site_lab 1 "all" 2 "prostate" 3 "colon" 4 "rectum" 5 "lung" 6 "stomach" ,modify
label values cancer_site cancer_site_lab
save "`datapath'\version02\2-working\ASIRs_male" ,replace
restore

********************************
** Next, IRs by site and year **
********************************
** BREAST - excluded male breast cancer
tab pop_wpp age_10  if siteiarc==29 & sex==1 //female
tab pop_wpp age_10  if siteiarc==29 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==29 //182 breast only 
	drop if sex==2
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
  |  181   147779   122.48     84.18    71.75    98.23     6.62 |
  +-------------------------------------------------------------+
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
replace cancer_site=2 if cancer_site==.
replace year=1 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

** BREAST - for female top5 table
tab pop_wpp age_10  if siteiarc==29 & sex==1 //female
tab pop_wpp age_10  if siteiarc==29 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==29 //182 breast only 
	drop if sex==2
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
  |  181   147779   122.48     84.18    71.75    98.23     6.62 |
  +-------------------------------------------------------------+
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
replace cancer_site=2 if cancer_site==.
order cancer_site asir ci_lower ci_upper
sort cancer_site asir
save "`datapath'\version02\2-working\ASIRs_female" ,replace
restore


** PROSTATE
tab pop_wpp age_10 if siteiarc==39 //male

preserve
	drop if age_10==.
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
  |  180   137548   130.86     88.32    75.77   102.52     6.68 |
  +-------------------------------------------------------------+
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
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=3 if cancer_site==.
replace year=1 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

** PROSTATE - for male top5 table
tab pop_wpp age_10 if siteiarc==39 //male

preserve
	drop if age_10==.
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
  |  180   137548   130.86     88.32    75.77   102.52     6.68 |
  +-------------------------------------------------------------+
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

append using "`datapath'\version02\2-working\ASIRs_male" 
replace cancer_site=2 if cancer_site==.
order cancer_site asir ci_lower ci_upper
sort cancer_site asir
save "`datapath'\version02\2-working\ASIRs_male" ,replace
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
  |   98   285327   34.35     21.41    17.28    26.33     2.25 |
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
replace cancer_site=4 if cancer_site==.
replace year=1 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
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

drop if sex==2 // for breast cancer - female ONLY

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (FEMALE)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   44   147779   29.77     18.64    13.39    25.47     2.97 |
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
replace cancer_site=3 if cancer_site==.
order cancer_site asir ci_lower ci_upper
sort cancer_site asir
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

drop if sex==1 // for breast cancer - male ONLY

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (MALE)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   54   137548   39.26     25.20    18.82    33.26     3.56 |
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

append using "`datapath'\version02\2-working\ASIRs_male" 
replace cancer_site=3 if cancer_site==.
order cancer_site asir ci_lower ci_upper
sort cancer_site asir
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
  |   43   285327   15.07      9.98     7.11    13.71     1.63 |
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
replace cancer_site=5 if cancer_site==.
replace year=1 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
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
  |   24   147779   16.24      9.79     6.01    15.26     2.26 |
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
replace cancer_site=5 if cancer_site==.
order cancer_site asir ci_lower ci_upper
sort cancer_site asir
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
  |   19   137548   13.81     10.08     6.02    16.00     2.44 |
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

append using "`datapath'\version02\2-working\ASIRs_male" 
replace cancer_site=4 if cancer_site==.
order cancer_site asir ci_lower ci_upper
sort cancer_site asir
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
	** F 0-14,15-24,25-34,35-44
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
  |   42   147779   28.42     17.55    12.56    24.10     2.84 |
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
replace cancer_site=6 if cancer_site==.
replace year=1 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
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
	** F 0-14,15-24,25-34,35-44,85+
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
  |   42   147779   28.42     17.55    12.56    24.10     2.84 |
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
replace cancer_site=4 if cancer_site==.
order cancer_site asir ci_lower ci_upper
sort cancer_site asir
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
  |   28   285327    9.81      5.50     3.59     8.20     1.12 |
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
replace cancer_site=7 if cancer_site==.
replace year=1 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
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
  |   14   137548   10.18      6.73     3.65    11.62     1.94 |
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

append using "`datapath'\version02\2-working\ASIRs_male" 
replace cancer_site=6 if cancer_site==.
order cancer_site asir ci_lower ci_upper
sort cancer_site asir
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
  |   24   285327    8.41      5.33     3.37     8.13     1.16 |
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
replace cancer_site=8 if cancer_site==.
replace year=1 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
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
  |   16   137548   11.63      8.09     4.58    13.45     2.16 |
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

append using "`datapath'\version02\2-working\ASIRs_male" 
replace cancer_site=5 if cancer_site==.
order cancer_site asir ci_lower ci_upper
sort cancer_site asir
save "`datapath'\version02\2-working\ASIRs_male" ,replace
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
  |   23   285327    8.06      6.18     3.83     9.47     1.39 |
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
replace cancer_site=9 if cancer_site==.
replace year=1 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
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
  |   22   285327    7.71      4.80     2.97     7.46     1.09 |
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
replace cancer_site=10 if cancer_site==.
replace year=1 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** OVARY 
tab pop_wpp age_10  if siteiarc==35

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
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
	drop if beh!=3 //0 deleted
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
	drop if beh!=3 //0 deleted
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
drop if dxyr!=2014 //2495 deleted

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
*/
** Below saved in pathway: 
//X:\The University of the West Indies\DataGroup - repo_data\data_p117\version02\2-working\WPP_population by sex_2013.txt
tab pop_wpp age_10  if sex==1 //female
tab pop_wpp age_10  if sex==2 //male

//drop if _merge==2 //1 deleted - no, doing so will change population totals
** There is 1 unmatched record (_merge==2) since 2014 data doesn't have any cases of females with age range 15-24
** age_10	site  dup	sex	 	pfu	pop_wpp	_merge
** 15-24	  .     .	female   .	18771	using only (2)


** Next, IRs for invasive tumours only
preserve
	drop if age_10==.
	//tab beh ,m
	drop if beh!=3 & beh!=. //0 deleted
	
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
  |  840   284825   294.92    196.92   183.34   211.31     7.06 |
  +-------------------------------------------------------------+
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
replace cancer_site=1 if cancer_site==.
replace year=2 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


********************************
** Next, IRs by site and year **
********************************
** BREAST - excluded male breast cancer
tab pop_wpp age_10  if siteiarc==29 & sex==1 //female
tab pop_wpp age_10  if siteiarc==29 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 & beh!=. //0 deleted
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
replace cancer_site=2 if cancer_site==.
replace year=2 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** PROSTATE
tab pop_wpp age_10 if siteiarc==39 //male

preserve
	drop if age_10==.
	drop if beh!=3 & beh!=. //0 deleted
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
  |  166   137169   121.02     82.29    70.10    96.14     6.50 |
  +-------------------------------------------------------------+
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
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=3 if cancer_site==.
replace year=2 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore

** COLON 
tab pop_wpp age_10  if siteiarc==13 & sex==1 //female
tab pop_wpp age_10  if siteiarc==13 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 & beh!=. //0 deleted
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24
	** M   25-34
	
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
  |  103   284825   36.16     23.47    19.04    28.71     2.40 |
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
replace cancer_site=4 if cancer_site==.
replace year=2 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** RECTUM 
tab pop_wpp age_10  if siteiarc==14 & sex==1 //female
tab pop_wpp age_10  if siteiarc==14 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 & beh!=. //0 deleted
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
replace cancer_site=5 if cancer_site==.
replace year=2 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** CORPUS UTERI
tab pop_wpp age_10 if siteiarc==33

preserve
	drop if age_10==.
	drop if beh!=3 & beh!=. //0 deleted
	keep if siteiarc==33 // corpus uteri only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-14,15-24,25-34,35-44
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
replace cancer_site=6 if cancer_site==.
replace year=2 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** STOMACH 
tab pop_wpp age_10  if siteiarc==11 & sex==1 //female
tab pop_wpp age_10  if siteiarc==11 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 & beh!=. //0 deleted
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
replace cancer_site=7 if cancer_site==.
replace year=2 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** LUNG
tab pop_wpp age_10 if siteiarc==21 & sex==1 //female
tab pop_wpp age_10 if siteiarc==21 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 & beh!=. //0 deleted
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
replace cancer_site=8 if cancer_site==.
replace year=2 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** NON-HODGKIN LYMPHOMA 
tab pop_wpp age_10  if siteiarc==53 & sex==1 //female
tab pop_wpp age_10  if siteiarc==53 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 & beh!=. //0 deleted
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
replace cancer_site=9 if cancer_site==.
replace year=2 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** MULTIPLE MYELOMA
tab pop_wpp age_10 if siteiarc==55 & sex==1 //female
tab pop_wpp age_10 if siteiarc==55 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 & beh!=. //0 deleted
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
replace cancer_site=10 if cancer_site==.
replace year=2 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** OVARY 
tab pop_wpp age_10  if siteiarc==35

preserve
	drop if age_10==.
	drop if beh!=3 & beh!=. //0 deleted
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
	drop if beh!=3 & beh!=. //0 deleted
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
drop if dxyr!=2013 //2539 deleted

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
*/
** None unmatched

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
  |  796   284294   279.99    190.02   176.60   204.25     6.98 |
  +-------------------------------------------------------------+
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
replace cancer_site=1 if cancer_site==.
replace year=3 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


********************************
** Next, IRs by site and year **
********************************
** BREAST - excluded male breast cancer
tab pop_wpp age_10  if siteiarc==29 & sex==1 //female
tab pop_wpp age_10  if siteiarc==29 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
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
  |  131   147525   88.80     60.48    50.10    72.48     5.58 |
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
replace cancer_site=2 if cancer_site==.
replace year=3 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** PROSTATE
tab pop_wpp age_10 if siteiarc==39 //male

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
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
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  136   136769   99.44     68.19    57.06    81.01     5.97 |
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
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=3 if cancer_site==.
replace year=3 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
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
replace cancer_site=4 if cancer_site==.
replace year=3 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
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
  |   42   284294   14.77      9.68     6.89    13.32     1.58 |
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
replace cancer_site=5 if cancer_site==.
replace year=3 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
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
  |   30   147525   20.34     13.35     8.97    19.36     2.55 |
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
replace cancer_site=6 if cancer_site==.
replace year=3 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
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
replace cancer_site=7 if cancer_site==.
replace year=3 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
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
replace cancer_site=8 if cancer_site==.
replace year=3 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
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
replace cancer_site=9 if cancer_site==.
replace year=3 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
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
replace cancer_site=10 if cancer_site==.
replace year=3 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** OVARY 
tab pop_wpp age_10  if siteiarc==35

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
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
	drop if beh!=3 //0 deleted
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
drop if dxyr!=2008 //2528 deleted


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
*/
** None unmatched

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
  |  807   279946   288.27    207.72   193.14   223.16     7.58 |
  +-------------------------------------------------------------+
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
replace cancer_site=1 if cancer_site==.
replace year=4 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


********************************
** Next, IRs by site and year **
********************************
** BREAST - excluded male breast cancer
tab pop_wpp age_10  if siteiarc==29 & sex==1 //female
tab pop_wpp age_10  if siteiarc==29 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==29 // breast only 
	drop if sex==2 //0 deleted
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
  |  131   145651   89.94     64.06    53.17    76.62     5.85 |
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
replace cancer_site=2 if cancer_site==.
replace year=4 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** PROSTATE
tab pop_wpp age_10 if siteiarc==39 //male

preserve
	drop if age_10==.
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
  |  206   134295   153.39    117.26   101.50   134.86     8.36 |
  +-------------------------------------------------------------+
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
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)

append using "`datapath'\version02\2-working\ASIRs" 
replace cancer_site=3 if cancer_site==.
replace year=4 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
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
replace cancer_site=4 if cancer_site==.
replace year=4 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
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
replace cancer_site=5 if cancer_site==.
replace year=4 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
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
replace cancer_site=6 if cancer_site==.
replace year=4 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
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
replace cancer_site=7 if cancer_site==.
replace year=4 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
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
replace cancer_site=8 if cancer_site==.
replace year=4 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
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
replace cancer_site=9 if cancer_site==.
replace year=4 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
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
	** F   55-64,65-74,85+
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
replace cancer_site=10 if cancer_site==.
replace year=4 if year==.
order cancer_site year asir ci_lower ci_upper
sort cancer_site year asir
save "`datapath'\version02\2-working\ASIRs" ,replace
restore


** OVARY 
tab pop_wpp age_10  if siteiarc==35

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
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
	drop if beh!=3 //0 deleted
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
