** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          20_analysis cancer.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      02-DEC-2019
    // 	date last modified      02-DEC-2019
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
    log using "`logpath'\20_analysis cancer.smcl", replace
** HEADER -----------------------------------------------------

************************************************************************* 
* SECTION 1: NUMBERS 
*        (1.1) total number & number of multiple events
*        (1.2) DCOs
*    	 (1.3) tumours by age-group
**************************************************************************
 
** LOAD cancer incidence dataset INCLUDING DCOs
use "`datapath'\version02\3-output\2008_2013_2014_cancer_nonsurvival" ,clear

** CASE variable
drop case
gen case=1
label var case "cancer patient (tumour)"
 
*************************************************
** (1.1) Total number of events & multiple events
*************************************************
count //2417
tab dxyr ,m
/*
DiagnosisYe |
         ar |      Freq.     Percent        Cum.
------------+-----------------------------------
       2008 |        803       33.22       33.22
       2013 |        786       32.52       65.74
       2014 |        828       34.26      100.00
------------+-----------------------------------
      Total |      2,417      100.00
*/
tab patient dxyr ,m //1,025; 912 patients & 15 MPs
/*
               |          DiagnosisYear
cancer patient |      2008       2013       2014 |     Total
---------------+---------------------------------+----------
       patient |       796        773        813 |     2,382 
separate event |         7         13         15 |        35 
---------------+---------------------------------+----------
         Total |       803        786        828 |     2,417 
*/

** JC updated AR's 2008 code for identifying MPs
tab ptrectot ,m
tab ptrectot patient ,m
tab ptrectot dxyr ,m

tab eidmp dxyr,m

duplicates list pid, nolabel sepby(pid) 
duplicates tag pid, gen(mppid_analysis)
sort pid cr5id
count if mppid_analysis>0 //70
//list pid topography morph ptrectot eidmp cr5id icd10 dxyr if mppid_analysis>0 ,sepby(pid)
 
** Of 2382 patients, 35 had >1 tumour

** note: remember to check in situ vs malignant from behaviour (beh)
tab beh ,m // 2417 malignant; 0 in-situ (excluded from this dataset)
/*
STOP - below applies to current data year only (2015)
*************************************************
** (1.2) DCOs - patients identified only at death
*************************************************
tab basis beh ,m
/*
                      |       Behaviour
     BasisOfDiagnosis |   In situ  Malignant |     Total
----------------------+----------------------+----------
                  DCO |         0        132 |       132 
        Clinical only |         0         29 |        29 
Clinical Invest./Ult  |         0         17 |        17 
Exploratory surg./aut |         0          4 |         4 
Lab test (biochem/imm |         0          2 |         2 
        Cytology/Haem |         1         42 |        43 
           Hx of mets |         0         14 |        14 
        Hx of primary |        23        631 |       654 
        Autopsy w/ Hx |         0          9 |         9 
              Unknown |         0         23 |        23 
----------------------+----------------------+----------
                Total |        24        903 |       927 
*/

tab basis ,m
/*
          BasisOfDiagnosis |      Freq.     Percent        Cum.
---------------------------+-----------------------------------
                       DCO |        132       14.24       14.24
             Clinical only |         29        3.13       17.37
Clinical Invest./Ult Sound |         17        1.83       19.20
 Exploratory surg./autopsy |          4        0.43       19.63
Lab test (biochem/immuno.) |          2        0.22       19.85
             Cytology/Haem |         43        4.64       24.49
                Hx of mets |         14        1.51       26.00
             Hx of primary |        654       70.55       96.55
             Autopsy w/ Hx |          9        0.97       97.52
                   Unknown |         23        2.48      100.00
---------------------------+-----------------------------------
                     Total |        927      100.00
*/

** As a percentage of all events: 14.24%
cii proportions 927 132

** As a percentage of all events with known basis: 14.6%
cii proportions 904 132
 
** As a percentage of all patients: 14.47%
cii proportions 912 132

** As a percentage for all those which were non-malignant - JC: there were none for 2014 // 0%
cii proportions 24 0
 
** As a percentage of all malignant tumours: 14.62%
cii proportions 903 132 

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
use "`datapath'\version02\2-working\2008_2013_2014_2015_cancer_numbers", replace
/*
***********************
** 3.1 CANCERS BY SITE
***********************
tab icd10 if beh<3 ,m //0 in-situ

tab icd10 ,m //0 missing

tab siteiarc ,m //0 missing


** Note: O&U, NMSCs (non-reportable skin cancers) and in-situ tumours excluded from top ten analysis
tab siteiarc if siteiarc!=25 & siteiarc!=64
tab siteiarc ,m //927 - 24 insitu; 45 O&U
tab siteiarc patient

** NS decided on 18march2019 to use IARC site groupings so variable siteiarc will be used instead of sitear
** IARC site variable created based on CI5-XI incidence classifications (see chapter 3 Table 3.1. of that volume) based on icd10
display `"{browse "http://ci5.iarc.fr/CI5-XI/Pages/Chapter3.aspx":IARC-CI5-XI-3}"'


** For annual report - Section 1: Incidence - Table 2a
** Below top 10 code added by JC for 2014
** All sites excl. O&U, non-reportable skin cancers - using IARC CI5's site groupings COMBINE cervix & CIN 3
** THIS USED IN ANNUAL REPORT TABLE 1
preserve
drop if siteiarc==25|siteiarc==61 //45 obs deleted
replace siteiarc=32 if siteiarc==32|siteiarc==64 //24 changes
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
siteiarc																	count	percentage
Prostate (C61)															198	28.09
Breast (C50)																159	22.55
Colon (C18)																	114	16.17
Cervix uteri (C53)													41	5.82
Corpus uteri (C54)													39	5.53
Lung (incl. trachea and bronchus) (C33-34)	32	4.54
Rectum (C19-20)															28	3.97
Multiple myeloma (C90)											28	3.97
Bladder (C67)																24	3.40
Pancreas (C25)															21	2.98
Stomach (C16)																21	2.98
(NS TO CHOOSE BETWEEN PANCREAS AND STOMACH AS THIS IS TOP 11)
*/
total count //705
restore

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
use "`datapath'\version02\2-working\2008_2013_2014_2015_cancer_numbers", replace

**********************************************************************************
** ASIR and 95% CI for Table 1 using AR's site groupings - using WHO World popn **
**					BARBADOS STATISTICAL SERVICES (BSS): 2013					**
drop pfu
gen pfu=1 // for % year if not whole year collected; not done for cancer        **
**********************************************************************************
** JCampbell 02-Dec-2019 performing ASIRs on BSS vs UN WPP populations for 
** NS to conduct sensitivity analysis to determine if to use BSS or WPP populations for rates
** Using top 5 cancer sites from 2014 annual rpt
labelbook sex_lab

********************************************************************
* (2.4c) IR age-standardised to WHO world popn - ALL TUMOURS: 2013
********************************************************************
** Using WHO World Standard Population
//tab siteiarc ,m

drop _merge
merge m:m sex age_10 using "`datapath'\version02\2-working\pop_bss_2013-10"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                             2,417  (_merge==3)
    -----------------------------------------
*/
** No unmatched records

** Below saved in pathway: 
//X:\The University of the West Indies\DataGroup - repo_data\data_p117\version02\2-working\BSS_population by sex_2013.txt
tab pop_bss age_10  if sex==1 //female
tab pop_bss age_10  if sex==2 //male

** Next, IRs for invasive tumours only
preserve
	drop if dxyr!=2013
	drop if age_10==.
	drop if beh!=3 //9 deleted
	
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
  |  786   277493   283.25    201.11   186.93   216.14     7.38 |
  +-------------------------------------------------------------+ 
*/
** JC update: Save these results as a dataset for reporting
gen population=1
gen cancer_site=1
gen year=1
matrix list r(adj)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat asir
svmat ci_lower
svmat ci_upper

collapse population cancer_site year asir ci_lower ci_upper
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
label define population_lab 1 "BSS" 2 "WPP",modify
label values population population_lab
label define cancer_site_lab 1 "all" 2 "prostate" 3"breast" 4 "colon" 5 "cervix uteri" 6 "corpus uteri" ,modify
label values cancer_site cancer_site_lab
label define year_lab 1 "2013" 2 "2014",modify
label values year year_lab
save "`datapath'\version02\2-working\ASIRs_BSS_WPP" ,replace
restore

********************************
** Next, IRs by site and year **
********************************

** PROSTATE
tab pop_bss age_10 if siteiarc==39 & dxyr==2013 //male

preserve
	drop if dxyr!=2013
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==39 // prostate only
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M 0-14,15-24,25-34,35-44
	expand 2 in 1
	replace sex=2 in 6
	replace age_10=1 in 6
	replace case=0 in 6
	replace pop_bss=(28075) in 6
	sort age_10	
	
	expand 2 in 1
	replace sex=2 in 7
	replace age_10=2 in 7
	replace case=0 in 7
	replace pop_bss=(18562)  in 7
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=3 in 8
	replace case=0 in 8
	replace pop_bss=(18512) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=4 in 9
	replace case=0 in 9
	replace pop_bss=(19598) in 9
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
  |  135   133370   101.22     75.40    63.11    89.51     6.58 |
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

append using "`datapath'\version02\2-working\ASIRs_BSS_WPP" 
replace population=1 if population==.
replace cancer_site=2 if cancer_site==.
replace year=1 if year==.
order population cancer_site year asir ci_lower ci_upper
sort cancer_site asir
save "`datapath'\version02\2-working\ASIRs_BSS_WPP" ,replace
restore

** BREAST
tab pop_bss age_10  if siteiarc==29 & sex==1 & dxyr==2013 //female
tab pop_bss age_10  if siteiarc==29 & sex==2 & dxyr==2013 //male

preserve
	drop if dxyr!=2013
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==29 // breast only
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24
	** M 25-34,35-44,55-64,85+
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_bss=(26630) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_bss=(28075) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bss=(18439) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_bss=(18562) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bss=(18512) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_bss=(19598) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=6 in 17
	replace case=0 in 17
	replace pop_bss=(14235) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_bss=(1664) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command
sort age_10
total pop_bss


distrate case pop_bss using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BC (M&F) - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  131   277493   47.21     34.61    28.79    41.32     3.13 |
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

append using "`datapath'\version02\2-working\ASIRs_BSS_WPP" 
replace population=1 if population==.
replace cancer_site=3 if cancer_site==.
replace year=1 if year==.
order population cancer_site year asir ci_lower ci_upper
sort cancer_site asir
save "`datapath'\version02\2-working\ASIRs_BSS_WPP" ,replace
restore

** COLON 
tab pop_bss age_10  if siteiarc==13 & sex==1 & dxyr==2013 //female
tab pop_bss age_10  if siteiarc==13 & sex==2 & dxyr==2013 //male

preserve
	drop if dxyr!=2013
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24,25-34
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=1 in 13
	replace case=0 in 13
	replace pop_bss=(26630) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_bss=(28075) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=2 in 15
	replace case=0 in 15
	replace pop_bss=(18439) in 15
	sort age_10

	expand 2 in 1
	replace sex=2 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_bss=(18562) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=3 in 17
	replace case=0 in 17
	replace pop_bss=(19319) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=3 in 18
	replace case=0 in 18
	replace pop_bss=(18512) in 18
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
  |  109   277493   39.28     26.24    21.44    31.87     2.60 |
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

append using "`datapath'\version02\2-working\ASIRs_BSS_WPP" 
replace population=1 if population==.
replace cancer_site=4 if cancer_site==.
replace year=1 if year==.
order population cancer_site year asir ci_lower ci_upper
sort cancer_site asir
save "`datapath'\version02\2-working\ASIRs_BSS_WPP" ,replace
restore


** CERVIX UTERI - excl. CIN 3
tab pop_bss age_10 if siteiarc==32 & dxyr==2013 //female

preserve
	drop if dxyr!=2013
	drop if age_10==.
	drop if beh!=3 & siteiarc!=64 //0 deleted
	keep if siteiarc==32|siteiarc==64 // cervix uteri with CIN 3
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-14,15-24
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_bss=(26630) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_bss=(18439) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_bss=(19319) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bss

distrate case pop_bss using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CERVICAL CANCER WITHOUT CIN 3 - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   35   144123   24.28     17.62    12.14    24.83     3.12 |
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

append using "`datapath'\version02\2-working\ASIRs_BSS_WPP" 
replace population=1 if population==.
replace cancer_site=5 if cancer_site==.
replace year=1 if year==.
order population cancer_site year asir ci_lower ci_upper
sort cancer_site asir
save "`datapath'\version02\2-working\ASIRs_BSS_WPP" ,replace
restore


** CORPUS UTERI
tab pop_bss age_10 if siteiarc==33 & dxyr==2013

preserve
	drop if dxyr!=2013
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==33 // corpus uteri only
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-14,15-24,25-34,35-44,85+
	expand 2 in 1
	replace sex=1 in 5
	replace age_10=1 in 5
	replace case=0 in 5
	replace pop_bss=(26630) in 5
	sort age_10	
	
	expand 2 in 1
	replace sex=1 in 6
	replace age_10=2 in 6
	replace case=0 in 6
	replace pop_bss=(18439) in 6
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=3 in 7
	replace case=0 in 7
	replace pop_bss=(19319) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=4 in 8
	replace case=0 in 8
	replace pop_bss=(20983) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=9 in 9
	replace case=0 in 9
	replace pop_bss=(3372) in 9
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
  |   30   144123   20.82     14.32     9.61    20.70     2.72 |
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

append using "`datapath'\version02\2-working\ASIRs_BSS_WPP" 
replace population=1 if population==.
replace cancer_site=6 if cancer_site==.
replace year=1 if year==.
order population cancer_site year asir ci_lower ci_upper
sort cancer_site asir
format asir 
save "`datapath'\version02\2-working\ASIRs_BSS_WPP" ,replace
restore

clear


** Load the dataset
use "`datapath'\version02\2-working\2008_2013_2014_2015_cancer_numbers", replace

**********************************************************************************
** ASIR and 95% CI for Table 1 using AR's site groupings - using WHO World popn **
**					WORLD POPULATION PROSPECTS (WPP): 2013						**
drop pfu
gen pfu=1 // for % year if not whole year collected; not done for cancer        **
**********************************************************************************
** JCampbell 02-Dec-2019 performing ASIRs on BSS vs UN WPP populations for 
** NS to conduct sensitivity analysis to determine if to use BSS or WPP populations for rates
** Using top 5 cancer sites from 2014 annual rpt
labelbook sex_lab

********************************************************************
* (2.4c) IR age-standardised to WHO world popn - ALL TUMOURS: 2013
********************************************************************
** Using WHO World Standard Population
//tab siteiarc ,m

drop _merge
merge m:m sex age_10 using "`datapath'\version02\2-working\pop_wpp_2013-10"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                             2,417  (_merge==3)
    -----------------------------------------
*/
** No unmatched records

** Below saved in pathway: 
//X:\The University of the West Indies\DataGroup - repo_data\data_p117\version02\2-working\WPP_population by sex_2013.txt
tab pop_wpp age_10  if sex==1 //female
tab pop_wpp age_10  if sex==2 //male

** Next, IRs for invasive tumours only
preserve
	drop if dxyr!=2013
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
  |  786   284294   276.47    187.30   173.98   201.42     6.93 |
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

append using "`datapath'\version02\2-working\ASIRs_BSS_WPP" 
replace population=2 if population==.
replace cancer_site=1 if cancer_site==.
replace year=1 if year==.
order population cancer_site year asir ci_lower ci_upper
sort cancer_site asir
format asir 
save "`datapath'\version02\2-working\ASIRs_BSS_WPP" ,replace
restore

********************************
** Next, IRs by site and year **
********************************

** PROSTATE
tab pop_wpp age_10 if siteiarc==39 & dxyr==2013 //male

preserve
	drop if dxyr!=2013
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
	replace pop_wpp=(18950)  in 7
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
  |  135   136769   98.71     67.40    56.34    80.15     5.93 |
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

append using "`datapath'\version02\2-working\ASIRs_BSS_WPP" 
replace population=2 if population==.
replace cancer_site=2 if cancer_site==.
replace year=1 if year==.
order population cancer_site year asir ci_lower ci_upper
sort cancer_site asir
save "`datapath'\version02\2-working\ASIRs_BSS_WPP" ,replace
restore

** BREAST
tab pop_wpp age_10  if siteiarc==29 & sex==1 & dxyr==2013 //female
tab pop_wpp age_10  if siteiarc==29 & sex==2 & dxyr==2013 //male

preserve
	drop if dxyr!=2013
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==29 // breast only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24
	** M 25-34,35-44,55-64,85+
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(26307) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_wpp=(27452) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(18763) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_wpp=(18950) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18555) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_wpp=(19473) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=6 in 17
	replace case=0 in 17
	replace pop_wpp=(15683) in 17
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
** THIS IS FOR BC (M&F) - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  131   284294   46.08     32.58    27.05    38.97     2.97 |
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

append using "`datapath'\version02\2-working\ASIRs_BSS_WPP" 
replace population=2 if population==.
replace cancer_site=3 if cancer_site==.
replace year=1 if year==.
order population cancer_site year asir ci_lower ci_upper
sort cancer_site asir
save "`datapath'\version02\2-working\ASIRs_BSS_WPP" ,replace
restore

** COLON 
tab pop_wpp age_10  if siteiarc==13 & sex==1 & dxyr==2013 //female
tab pop_wpp age_10  if siteiarc==13 & sex==2 & dxyr==2013 //male

preserve
	drop if dxyr!=2013
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

append using "`datapath'\version02\2-working\ASIRs_BSS_WPP" 
replace population=2 if population==.
replace cancer_site=4 if cancer_site==.
replace year=1 if year==.
order population cancer_site year asir ci_lower ci_upper
sort cancer_site asir
save "`datapath'\version02\2-working\ASIRs_BSS_WPP" ,replace
restore


** CERVIX UTERI - excl. CIN 3
tab pop_wpp age_10 if siteiarc==32 & dxyr==2013 //female

preserve
	drop if dxyr!=2013
	drop if age_10==.
	drop if beh!=3 & siteiarc!=64 //0 deleted
	keep if siteiarc==32|siteiarc==64 // cervix uteri with CIN 3
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-14,15-24
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_wpp=(26307) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_wpp=(18763) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_wpp=(19213) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CERVICAL CANCER WITHOUT CIN 3 - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   35   147525   23.72     16.92    11.63    23.91     3.02 |
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

append using "`datapath'\version02\2-working\ASIRs_BSS_WPP" 
replace population=2 if population==.
replace cancer_site=5 if cancer_site==.
replace year=1 if year==.
order population cancer_site year asir ci_lower ci_upper
sort cancer_site asir
save "`datapath'\version02\2-working\ASIRs_BSS_WPP" ,replace
restore


** CORPUS UTERI
tab pop_wpp age_10 if siteiarc==33 & dxyr==2013

preserve
	drop if dxyr!=2013
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
  |   30   147525   20.34     13.30     8.93    19.28     2.54 |
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

append using "`datapath'\version02\2-working\ASIRs_BSS_WPP" 
replace population=2 if population==.
replace cancer_site=6 if cancer_site==.
replace year=1 if year==.
order population cancer_site year asir ci_lower ci_upper
sort cancer_site asir
format asir 
save "`datapath'\version02\2-working\ASIRs_BSS_WPP" ,replace
restore

clear



** Load the dataset
use "`datapath'\version02\2-working\2008_2013_2014_2015_cancer_numbers", replace

**********************************************************************************
** ASIR and 95% CI for Table 1 using AR's site groupings - using WHO World popn **
**					BARBADOS STATISTICAL SERVICES (BSS): 2014					**
drop pfu
gen pfu=1 // for % year if not whole year collected; not done for cancer        **
**********************************************************************************
** JCampbell 02-Dec-2019 performing ASIRs on BSS vs UN WPP populations for 
** NS to conduct sensitivity analysis to determine if to use BSS or WPP populations for rates
** Using top 5 cancer sites from 2014 annual rpt
labelbook sex_lab

********************************************************************
* (2.4c) IR age-standardised to WHO world popn - ALL TUMOURS: 2014
********************************************************************
** Using WHO World Standard Population
//tab siteiarc ,m

drop _merge
merge m:m sex age_10 using "`datapath'\version02\2-working\pop_bss_2014-10"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                             2,417  (_merge==3)
    -----------------------------------------
*/
** No unmatched records

** Below saved in pathway: 
//X:\The University of the West Indies\DataGroup - repo_data\data_p117\version02\2-working\BSS_population by sex_2014.txt
tab pop_bss age_10 if sex==1 //female
tab pop_bss age_10 if sex==2 //male

** Next, IRs for invasive tumours only
preserve
    drop if dxyr!=2014
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: F 15-24
	** JC: I had to change the obsID so that the replacements could take place as the
	** dataset stopped at obsID when the above code was run
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=2 in 18
	replace case=0 in 18
	replace pop_bss=(18404) in 18
	sort age_10	
		
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
  |  828   277197   298.70    212.16   197.56   227.60     7.59 |
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

append using "`datapath'\version02\2-working\ASIRs_BSS_WPP" 
replace population=1 if population==.
replace cancer_site=1 if cancer_site==.
replace year=2 if year==.
order population cancer_site year asir ci_lower ci_upper
sort cancer_site asir
format asir 
save "`datapath'\version02\2-working\ASIRs_BSS_WPP" ,replace
restore

*******************************
** Next, IRs by site and year **
*******************************

** PROSTATE
tab pop_bss age_10 if siteiarc==39 //male

preserve
    drop if dxyr!=2014
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==39 // prostate only
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: M 0-14, 15-24, 25-34
	** JC: I had to change the obsID so that the replacements could take place as the
	** dataset stopped at obsID when the above code was run
	expand 2 in 1
	replace sex=2 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_bss=(28070) in 7
	sort age_10	
	
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_bss=(18558)  in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_bss=(18508) in 9
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
  |  165   133343   123.74     93.52    79.70   109.17     7.37 |
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

append using "`datapath'\version02\2-working\ASIRs_BSS_WPP" 
replace population=1 if population==.
replace cancer_site=2 if cancer_site==.
replace year=2 if year==.
order population cancer_site year asir ci_lower ci_upper
sort cancer_site asir
format asir 
save "`datapath'\version02\2-working\ASIRs_BSS_WPP" ,replace
restore


** BREAST
tab pop_bss age_10  if siteiarc==29 & sex==1 & dxyr==2014 //female
tab pop_bss age_10  if siteiarc==29 & sex==2 & dxyr==2014 //male

preserve
    drop if dxyr!=2014
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==29 // breast only
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14, 15-24
	** M 25-34, 35-44, 65-74, 75-84, 85+
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_bss=(26581) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_bss=(18404) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_bss=(28070) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bss=(18558) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_bss=(18508) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_bss=(19595) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=7 in 16
	replace case=0 in 16
	replace pop_bss=(8335) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=8 in 17
	replace case=0 in 17
	replace pop_bss=(4861) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_bss=(1664) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command
sort age_10
total pop_bss

** for both female & male breast cancer; JC: added for 2013
** but may not use in ann rpt as total <10 cases (=4)
** AR to JC: yes you can use this, as it's a single rate for the whole population 
** and we don't say #M, #F just overall IR (M+F)
** the thing is though, we won't use it as it really lowers the IR - there are so
** few M cases but you then have to use the whole population
distrate case pop_bss using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BC (M&F) - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  154   277197   55.56     40.33    34.09    47.44     3.34 |
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

append using "`datapath'\version02\2-working\ASIRs_BSS_WPP" 
replace population=1 if population==.
replace cancer_site=3 if cancer_site==.
replace year=2 if year==.
order population cancer_site year asir ci_lower ci_upper
sort cancer_site asir
format asir 
save "`datapath'\version02\2-working\ASIRs_BSS_WPP" ,replace
restore

** COLON 
tab pop_bss age_10  if siteiarc==13 & sex==1 & dxyr==2014 //female
tab pop_bss age_10  if siteiarc==13 & sex==2 & dxyr==2014 //male

preserve
    drop if dxyr!=2014
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: M&F 0-14, M&F 15-24
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_bss=(28070) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=1 in 16
	replace case=0 in 16
	replace pop_bss=(26581) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=2 in 17
	replace case=0 in 17
	replace pop_bss=(18404) in 17
	sort age_10

	expand 2 in 1
	replace sex=2 in 18
	replace age_10=2 in 18
	replace case=0 in 18
	replace pop_bss=(18558) in 18
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
  |  102   277197   36.80     25.57    20.75    31.24     2.61 |
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

append using "`datapath'\version02\2-working\ASIRs_BSS_WPP" 
replace population=1 if population==.
replace cancer_site=4 if cancer_site==.
replace year=2 if year==.
order population cancer_site year asir ci_lower ci_upper
sort cancer_site asir
format asir 
save "`datapath'\version02\2-working\ASIRs_BSS_WPP" ,replace
restore


** CERVIX UTERI - excl. CIN 3
tab pop_bss age_10 if siteiarc==32 & dxyr==2014 //female

preserve
    drop if dxyr!=2014
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==32 // corpus uteri only
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: F 0-14, 15-24
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_bss=(26581) in 8
	sort age_10	
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=2 in 9
	replace case=0 in 9
	replace pop_bss=(18404)  in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bss

distrate case pop_bss using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CERVICAL CANCER - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   16   143854   11.12      9.43     5.27    15.57     2.53 |
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

append using "`datapath'\version02\2-working\ASIRs_BSS_WPP" 
replace population=1 if population==.
replace cancer_site=5 if cancer_site==.
replace year=2 if year==.
order population cancer_site year asir ci_lower ci_upper
sort cancer_site asir
format asir 
save "`datapath'\version02\2-working\ASIRs_BSS_WPP" ,replace
restore


** CORPUS UTERI
tab pop_bss age_10 if siteiarc==33 & dxyr==2014 //female

preserve
    drop if dxyr!=2014
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==33 // corpus uteri only
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: F 0-14, 15-24, 25-34
	** JC: I had to change the obsID so that the replacements could take place as the
	** dataset stopped at obsID when the above code was run
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_bss=(26581) in 7
	sort age_10	
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_bss=(18404)  in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_bss=(19283) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bss

distrate case pop_bss using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CORPUS UTERI(BOTH) - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   37   143854   25.72     17.42    12.18    24.32     2.98 |
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

append using "`datapath'\version02\2-working\ASIRs_BSS_WPP" 
replace population=1 if population==.
replace cancer_site=6 if cancer_site==.
replace year=2 if year==.
order population cancer_site year asir ci_lower ci_upper
sort cancer_site asir
format asir 
save "`datapath'\version02\2-working\ASIRs_BSS_WPP" ,replace
restore

clear

** Load the dataset
use "`datapath'\version02\2-working\2008_2013_2014_2015_cancer_numbers", replace
**********************************************************************************
** ASIR and 95% CI for Table 1 using AR's site groupings - using WHO World popn **
**					WORLD POPULATION PROSPECTS (WPP): 2014						**
drop pfu
gen pfu=1 // for % year if not whole year collected; not done for cancer        **
**********************************************************************************
** JCampbell 02-Dec-2019 performing ASIRs on BSS vs UN WPP populations for 
** NS to conduct sensitivity analysis to determine if to use BSS or WPP populations for rates
** Using top 5 cancer sites from 2014 annual rpt
labelbook sex_lab

********************************************************************
* (2.4c) IR age-standardised to WHO world popn - ALL TUMOURS: 2014
********************************************************************
** Using WHO World Standard Population
//tab siteiarc ,m

drop _merge
merge m:m sex age_10 using "`datapath'\version02\2-working\pop_wpp_2014-10"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                             2,417  (_merge==3)
    -----------------------------------------
*/
** No unmatched records

** Below saved in pathway: 
//X:\The University of the West Indies\DataGroup - repo_data\data_p117\version02\2-working\WPP_population by sex_2014.txt
tab pop_wpp age_10 if sex==1 //female
tab pop_wpp age_10 if sex==2 //male

** Next, IRs for invasive tumours only
preserve
    drop if dxyr!=2014
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: F 15-24
	** JC: I had to change the obsID so that the replacements could take place as the
	** dataset stopped at obsID when the above code was run
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
  |  828   284825   290.70    194.11   180.61   208.40     7.02 |
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

append using "`datapath'\version02\2-working\ASIRs_BSS_WPP" 
replace population=2 if population==.
replace cancer_site=1 if cancer_site==.
replace year=2 if year==.
order population cancer_site year asir ci_lower ci_upper
sort cancer_site asir
format asir 
save "`datapath'\version02\2-working\ASIRs_BSS_WPP" ,replace
restore

*******************************
** Next, IRs by site and year **
*******************************

** PROSTATE
tab pop_wpp age_10 if siteiarc==39 //male

preserve
    drop if dxyr!=2014
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==39 // prostate only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: M 0-14, 15-24, 25-34
	** JC: I had to change the obsID so that the replacements could take place as the
	** dataset stopped at obsID when the above code was run
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
	replace pop_wpp=(19032)  in 8
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
  |  165   137169   120.29     81.65    69.51    95.45     6.48 |
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

append using "`datapath'\version02\2-working\ASIRs_BSS_WPP" 
replace population=2 if population==.
replace cancer_site=2 if cancer_site==.
replace year=2 if year==.
order population cancer_site year asir ci_lower ci_upper
sort cancer_site asir
format asir 
save "`datapath'\version02\2-working\ASIRs_BSS_WPP" ,replace
restore


** BREAST
tab pop_wpp age_10  if siteiarc==29 & sex==1 & dxyr==2014 //female
tab pop_wpp age_10  if siteiarc==29 & sex==2 & dxyr==2014 //male

preserve
    drop if dxyr!=2014
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==29 // breast only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14, 15-24
	** M 25-34, 35-44, 65-74, 75-84, 85+
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_wpp=(25929) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_wpp=(18771) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_wpp=(27062) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(19032) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_wpp=(18491) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_wpp=(19352) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=7 in 16
	replace case=0 in 16
	replace pop_wpp=(9680) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=8 in 17
	replace case=0 in 17
	replace pop_wpp=(5431) in 17
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

** for both female & male breast cancer; JC: added for 2013
** but may not use in ann rpt as total <10 cases (=4)
** AR to JC: yes you can use this, as it's a single rate for the whole population 
** and we don't say #M, #F just overall IR (M+F)
** the thing is though, we won't use it as it really lowers the IR - there are so
** few M cases but you then have to use the whole population
distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BC (M&F) - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  154   284825   54.07     37.48    31.62    44.16     3.13 |
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

append using "`datapath'\version02\2-working\ASIRs_BSS_WPP" 
replace population=2 if population==.
replace cancer_site=3 if cancer_site==.
replace year=2 if year==.
order population cancer_site year asir ci_lower ci_upper
sort cancer_site asir
format asir 
save "`datapath'\version02\2-working\ASIRs_BSS_WPP" ,replace
restore

** COLON 
tab pop_wpp age_10  if siteiarc==13 & sex==1 & dxyr==2014 //female
tab pop_wpp age_10  if siteiarc==13 & sex==2 & dxyr==2014 //male

preserve
    drop if dxyr!=2014
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: M&F 0-14, M&F 15-24
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_wpp=(27062) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=1 in 16
	replace case=0 in 16
	replace pop_wpp=(25929) in 16
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
  |  102   284825   35.81     23.37    18.94    28.61     2.40 |
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

append using "`datapath'\version02\2-working\ASIRs_BSS_WPP" 
replace population=2 if population==.
replace cancer_site=4 if cancer_site==.
replace year=2 if year==.
order population cancer_site year asir ci_lower ci_upper
sort cancer_site asir
format asir 
save "`datapath'\version02\2-working\ASIRs_BSS_WPP" ,replace
restore


** CERVIX UTERI - excl. CIN 3
tab pop_wpp age_10 if siteiarc==32 & dxyr==2014 //female

preserve
    drop if dxyr!=2014
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==32 // corpus uteri only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: F 0-14, 15-24
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
	replace pop_wpp=(18771)  in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CERVICAL CANCER - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   16   147656   10.84      9.25     5.12    15.32     2.51 |
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

append using "`datapath'\version02\2-working\ASIRs_BSS_WPP" 
replace population=2 if population==.
replace cancer_site=5 if cancer_site==.
replace year=2 if year==.
order population cancer_site year asir ci_lower ci_upper
sort cancer_site asir
format asir 
save "`datapath'\version02\2-working\ASIRs_BSS_WPP" ,replace
restore


** CORPUS UTERI
tab pop_wpp age_10 if siteiarc==33 & dxyr==2014 //female

preserve
    drop if dxyr!=2014
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==33 // corpus uteri only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: F 0-14, 15-24, 25-34
	** JC: I had to change the obsID so that the replacements could take place as the
	** dataset stopped at obsID when the above code was run
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
	replace pop_wpp=(18771)  in 8
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
** THIS IS FOR CORPUS UTERI(BOTH) - STD TO WHO WORLD POPN 
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

append using "`datapath'\version02\2-working\ASIRs_BSS_WPP" 
replace population=2 if population==.
replace cancer_site=6 if cancer_site==.
replace year=2 if year==.
order population cancer_site year asir ci_lower ci_upper
sort cancer_site asir
format asir 
save "`datapath'\version02\2-working\ASIRs_BSS_WPP" ,replace
restore

clear

** Output for above ASIRs comparison using BSS vs WPP populations
use "`datapath'\version02\2-working\ASIRs_BSS_WPP", clear
format asir %04.2f
sort cancer_site year asir

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
				****************************
putdocx clear
putdocx begin, footer(foot1)
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER Population Report: BSS vs WPP"), bold
putdocx textblock begin
Date Prepared: 02-Dec-2019. 
Prepared by: JC using Stata & Redcap data release date: 14-Nov-2019. 
Generated using Dofile: repo_p117\20_analysis cancer.do
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) Dataset: Excludes ineligible case definition, non-residents, non-malignant tumours, IARC non-reportable MPs; cancer dataset used: "`datapath'\version02\3-output\2008_2013_2014_cancer_nonsurvival")
putdocx textblock end
putdocx textblock begin
(2) ASIR (BSS_2013): stata command distrate used with pop_bss_2013-10 for 2013 cancer incidence and world population dataset: who2000_10-2; population datasets used: "`datapath'\version02\2-working\pop_bss_2013-10")
putdocx textblock end
putdocx textblock begin
(3) ASIR (WPP_2013): stata command distrate used with pop_wpp_2013-10 for 2013 cancer incidence and world population dataset: who2000_10-2; population datasets used: "`datapath'\version02\2-working\pop_wpp_2013-10")
putdocx textblock end
putdocx textblock begin
(4) ASIR (BSS_2014): stata command distrate used with pop_bss_2014-10 for 2014 cancer incidence and world population dataset: who2000_10-2; population datasets used: "`datapath'\version02\2-working\pop_bss_2014-10")
putdocx textblock end
putdocx textblock begin
(5) ASIR (WPP_2014): stata command distrate used with pop_wpp_2014-10 for 2014 cancer incidence and world population dataset: who2000_10-2; population datasets used: "`datapath'\version02\2-working\pop_wpp_2014-10")
putdocx textblock end
putdocx textblock begin
(6) Population text files (BSS): saved in: "`datapath'\version02\2-working\BSS_population by sex_yyyy"
putdocx textblock end
putdocx textblock begin
(7) Population text files (WPP): saved in: "`datapath'\version02\2-working\WPP_population by sex_yyyy"
putdocx textblock end
putdocx textblock begin
(8) Population files (BSS): emailed to JCampbell from BSS' Socio-and-Demographic Statistics Division by Statistical Assistant on 29-Nov-2019.
putdocx textblock end
putdocx textblock begin
(9) Population files (WPP): generated from "https://population.un.org/wpp/Download/Standard/Population/" on 27-Nov-2019.
putdocx textblock end
putdocx pagebreak
putdocx table tbl1 = data(population cancer_site year asir ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx save "`datapath'\version02\3-output\2019-12-02_population_comparison.docx", replace
putdocx clear

save "`datapath'\version02\3-output\population_comparison_BSS_WPP" ,replace
