
cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          25_analysis cancer.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL & Kern ROCKE
    //  date first created      25-SEPT-2023
    // 	date last modified      22-OCT-2023
    //  algorithm task          Analyzing combined cancer dataset: (1) Numbers (2) ASIRs for PAB 07-Jun-2022
    //  status                  Completed
    //  objective               To have one dataset with cleaned and grouped 2019 data for inclusion in PAB presentation.
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
    *local datapath "X:/The University of the West Indies/DataGroup - repo_data/data_p117"
		local datapath "/Volumes/Drive 2/BNR Consultancy/Sync/Sync/DM/Data/BNR-Cancer/data_p117_decrypted" // Kern encrypted local machine
    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    *local logpath X:/OneDrive - The University of the West Indies/repo_datagroup/repo_p117

    ** Close any open log file and open a new log file
    *capture log close
    *log using "`logpath'/25_analysis cancer.smcl", replace
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
use "`datapath'/version13/3-output/2019_cancer_nonsurvival_deidentified" ,clear

** CASE variable
*drop case
gen case=1
label var case "cancer patient (tumour)"
 
*************************************************
** (1.1) Total number of events & multiple events
*************************************************
count //949
tab dxyr ,m

** For 2016-2018 annual report, check 2015 annual report for the full version of this dofile as code not needed for PAB was removed 
** Analysis point to look for raised at cancer mtg on 25jan2022
//CHECK FOR BOD=CLINICAL AND TIME BETWEEN DOT AND DOD as KWG noticed alot of cases where pts sought medical attention late and seemed like an increase from previous yrs.

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
label data "2019 BNR-Cancer analysed data - Numbers"
note: TS This dataset does NOT include population data 
save "`datapath'/version13/2-working/2019_cancer_numbers", replace

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
use "`datapath'/version13/2-working/2019_cancer_numbers", clear

****************************************************************************** 2015 ****************************************************************************************

drop if dxyr!=2019 //0 deleted
count //900

***********************
** 3.1 CANCERS BY SITE
***********************
tab icd10 if beh<3 ,m //18 in-situ

tab icd10 ,m //0 missing

tab siteiarc ,m //0 missing

tab sex ,m

** Note: O&U, NMSCs (non-reportable skin cancers) and in-situ tumours excluded from top ten analysis
tab siteiarc if siteiarc!=25 & siteiarc!=64
//for 2018 don't remove non-melanoma skin cancers as these are not SCC or any of the non-reportable morph categories for skin
tab siteiarc if siteiarc!=64
tab siteiarc ,m //949 - 36 O&U 
tab siteiarc patient

tab siteiarc ,sort

** NS decided on 18march2019 to use IARC site groupings so variable siteiarc will be used instead of sitear
** IARC site variable created based on CI5-XI incidence classifications (see chapter 3 Table 3.1. of that volume) based on icd10
display `"{browse "http://ci5.iarc.fr/CI5-XI/Pages/Chapter3.aspx":IARC-CI5-XI-3}"'


** For annual report - Section 1: Incidence - Table 2a
** Below top 10 code added by JC for 2015
** All sites excl. in-situ, O&U, non-reportable skin cancers
** THIS USED IN ANNUAL REPORT TABLE 1
preserve
drop if siteiarc>60 //| siteiarc==25 //38 deleted - for 2018 don't remove non-melanoma skin cancers as these are not SCC or any of the non-reportable morph categories for skin
tab siteiarc ,m
bysort siteiarc: gen n=_N
bysort n siteiarc: gen tag=(_n==1)
replace tag = sum(tag)
sum tag , meanonly
gen top10 = (tag>=(`r(max)'-9))
sum n if tag==(`r(max)'-9), meanonly
replace top10 = 1 if n==`r(max)'
tab siteiarc top10 if top10!=0

tab siteiarc if top10!=0, sort 

contract siteiarc top10 if top10!=0, freq(count) percent(percentage)
summ
describe
gsort -count
drop top10
/*
. tab siteiarc if top10!=0, sort

                      IARC CI5-XI sites |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                         Prostate (C61) |        238       33.81       33.81
                           Breast (C50) |        181       25.71       59.52
                            Colon (C18) |        105       14.91       74.43
                     Corpus uteri (C54) |         51        7.24       81.68
Lung (incl. trachea and bronchus) (C33- |         30        4.26       85.94
                        Rectum (C19-20) |         27        3.84       89.77
                          Stomach (C16) |         20        2.84       92.61
                           Kidney (C64) |         18        2.56       95.17
                         Pancreas (C25) |         17        2.41       97.59
      Non-Hodgkin lymphoma (C82-86,C96) |         17        2.41      100.00
----------------------------------------+-----------------------------------
                                  Total |        704      100.00

*/
total count //704
restore

labelbook sex_lab
tab sex ,m


** For annual report - unsure which section of report to be used in
** Below top 10 code added by JC for 2015
** All sites excl. in-situ, O&U, non-reportable skin cancers
** Requested by SF on 16-Oct-2020: Numbers of top 10 by sex
preserve
drop if siteiarc>60 //| siteiarc==25 //38 deleted
tab siteiarc ,m
bysort siteiarc: gen n=_N
bysort n siteiarc: gen tag=(_n==1)
replace tag = sum(tag)
sum tag , meanonly
gen top10 = (tag>=(`r(max)'-9))
sum n if tag==(`r(max)'-9), meanonly
replace top10 = 1 if n==`r(max)'
gsort -top10
tab siteiarc if top10!=0
tab siteiarc if top10!=0 & sex==1, sort //female
tab siteiarc if top10!=0 & sex==2, sort //male
contract siteiarc top10 sex if top10!=0, freq(count) percent(percentage)
summ
describe
gsort -count
drop top10

/*
FEMALE
                      IARC CI5-XI sites |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                           Breast (C50) |        174       53.05       53.05
                            Colon (C18) |         58       17.68       70.73
                     Corpus uteri (C54) |         51       15.55       86.28
Lung (incl. trachea and bronchus) (C33- |         11        3.35       89.63
                        Rectum (C19-20) |          9        2.74       92.38
                         Pancreas (C25) |          8        2.44       94.82
                          Stomach (C16) |          6        1.83       96.65
      Non-Hodgkin lymphoma (C82-86,C96) |          6        1.83       98.48
                           Kidney (C64) |          5        1.52      100.00
----------------------------------------+-----------------------------------
                                  Total |        328      100.00

								  
MALE
                      IARC CI5-XI sites |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                         Prostate (C61) |        238       63.30       63.30
                            Colon (C18) |         47       12.50       75.80
Lung (incl. trachea and bronchus) (C33- |         19        5.05       80.85
                        Rectum (C19-20) |         18        4.79       85.64
                          Stomach (C16) |         14        3.72       89.36
                           Kidney (C64) |         13        3.46       92.82
      Non-Hodgkin lymphoma (C82-86,C96) |         11        2.93       95.74
                         Pancreas (C25) |          9        2.39       98.14
                           Breast (C50) |          7        1.86      100.00
----------------------------------------+-----------------------------------
                                  Total |        376      100.00
								  
*/
total count //704
drop percentage
gen year=2019
rename count number
rename siteiarc cancer_site
sort cancer_site sex
order year cancer_site number
save "`datapath'/version13/2-working/2019_top10_sex" ,replace
restore

labelbook sex_lab
tab sex ,m

** For annual report - Section 1: Incidence - Table 1
** FEMALE - using IARC's site groupings (excl. in-situ)
preserve
drop if sex==2 //462 deleted
drop if siteiarc>60 //26 deleted
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

gen totpercent=(count/438)*100 //all cancers excl. male(477)
gen alltotpercent=(count/900)*100 //all cancers
/*
siteiarc				count	percentage	totpercent	alltotpercent
Breast (C50)			171		54.98		31.37615	16.52174
Colon (C18)				 58		18.65		10.6422		 5.603865
Corpus uteri (C54)		 50		16.08		 9.174312	 4.830918
Pancreas (C25)			 18		 5.79		 3.302752	 1.73913
Multiple myeloma (C90)	 14		 4.50		 2.568807	 1.352657
*/
total count //321
restore

** For annual report - Section 1: Incidence - Table 1
** Below top 5 code added by JC for 2015
** MALE - using IARC's site groupings
preserve
drop if sex==1 //438 deleted
drop if siteiarc>60 //| siteiarc==25 //19 deleted
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

gen totpercent=(count/462)*100 //all cancers excl. female(472)
gen alltotpercent=(count/900)*100 //all cancers
/*
siteiarc									count	percentage	totpercent	alltotpercent
Prostate (C61)								221		65.38		46.33124	23.28767
Colon (C18)									 56		16.57		11.74004	 5.900949
Rectum (C19-20)								 25		 7.40		 5.24109	 2.634352
Lung (incl. trachea and bronchus) (C33-34)	 21		 6.21		 4.402516	 2.212856
Multiple myeloma (C90)						 15		 4.44		 3.144654	 1.580611
*/
total count //336
restore


* *********************************************
* ANALYSIS: SECTION 3 - cancer sites
* Covering:
*  3.1  Classification of cancer by site
*  3.2 	ASIRs by site; overall, men and women
* *********************************************
** NOTE: bb popn and WHO popn data prepared by IH are ALL coded M=2 and F=1
** Above note by AR from 2008 dofile

** Load the dataset
use "`datapath'/version13/2-working/2019_cancer_numbers", clear

****************************************************************************** 2015 ****************************************************************************************
drop if dxyr!=2019 //0 deleted

count //949


tab siteiarc ,m
labelbook siteiarc_lab

**********************************************************************************
** ASIR and 95% CI for Table 1 using AR's site groupings - using WHO World popn **
**					WORLD POPULATION PROSPECTS (WPP): 2018						**
*drop pfu
gen pfu=1 // for % year if not whole year collected; not done for cancer        **
**********************************************************************************
** NSobers confirmed use of WPP populations
labelbook sex_lab

********************************************************************
* (2.4c) IR age-standardised to WHO world popn - ALL TUMOURS: 2018
********************************************************************
** Using WHO World Standard Population
//tab siteiarc ,m

*drop _merge
merge m:m sex age_10 using "`datapath'/version13/2-working/pop_wpp_2019-10"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                               949  (_merge==3)
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
		& siteiarc!=14 & siteiarc!=18 & siteiarc!=18 & siteiarc!=21 ///
		& siteiarc!=53 & siteiarc!=11
		
//by sex,sort: tab age_10 incirate ,m
sort siteiarc age_10 sex
//list incirate age_10 sex
//list incirate age_10 sex if siteiarc==13

format incirate %04.2f
gen year=2019
rename siteiarc cancer_site
rename incirate age_specific_rate
drop pfu case pop_wpp
order year cancer_site sex age_10 age_specific_rate
save "`datapath'/version13/2-working/2019_top10_age+sex_rates" ,replace
restore


** Check for missing age as these would need to be added to the median group for that site when assessing ASIRs to prevent creating an outlier
count if age==.|age==999 //0

** Below saved in pathway: 
//X:/The University of the West Indies/DataGroup - repo_data/data_p117/version13/2-working/WPP_population by sex_2013.txt
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

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

** THIS IS FOR ALL SITES (INVASIVE TUMOURS ONLY) - STD TO WHO WORLD POPN

/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  949   286640   331.08    207.16   193.64   221.45     7.02 |
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
gen percent=number/900*100
replace percent=round(percent,0.01)

 
//JC 19may2022: rename breast to female breast as drop males in distrate breast section so ASMR for breast is calculated using female population
label define cancer_site_lab 1 "all" 2 "prostate" 3 "female breast" 4 "colon" 5 "corpus uteri" 6 "lung" 7 "rectum" ///
							 8 "stomach" 9 "kidney" 10 "pancreas" 11 "non-hodgkin lymphoma" ,modify
label values cancer_site cancer_site_lab
label define year_lab 1 "2019" 2 "2018" 3 "2015" 4 "2014" 5 "2013" ,modify
label values year year_lab
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'/version13/2-working/ASIRs" ,replace
restore


** Next, IRs for invasive tumours FEMALE only
preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	drop if sex==2 //477 deleted
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	
	** No missing age groups
		
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR ALL SITES (INVASIVE TUMOURS ONLY-FEMALE) - STD TO WHO WORLD POPN

/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  472   148115   318.67    199.50   180.74   219.81     9.83 |
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
gen percent=number/900*100
replace percent=round(percent,0.01)

label define cancer_site_lab 1 "all" 2 "female breast" 3 "colon" 4 "corpus uteri" 5 "lung" 6 "rectum" ,modify
label values cancer_site cancer_site_lab
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'/version13/2-working/ASIRs_female" ,replace
restore


** Next, IRs for invasive tumours MALE only
preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	drop if sex==1 //472 deleted
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	
	*Missing age groups
	*M 0-14, 15-24
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_wpp=(25316) in 8
	sort age_10	
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=2 in 9
	replace case=0 in 9
	replace pop_wpp=(19294)  in 9
	sort age_10
	
		
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR ALL SITES (INVASIVE TUMOURS ONLY-MALE) - STD TO WHO WORLD POPN

/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  477   138525   344.34    219.25   199.64   240.45    10.26 |
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
gen percent=number/900*100
replace percent=round(percent,0.01)

label define cancer_site_lab 1 "all" 2 "prostate" 3 "colon" 4 "lung" 5 "rectum" 6 "stomach" ,modify
label values cancer_site cancer_site_lab
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'/version13/2-working/ASIRs_male" ,replace
restore

*-------------------------------------------------------------------------------

********************************
** Next, IRs by site and year **
********************************
** PROSTATE
tab pop_wpp age_10 if siteiarc==39 //male

preserve
	drop if age_10==. //0 deleted
	drop if beh!=3 //0 deleted
	keep if siteiarc==39 // prostate only
	keep if sex==2
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	
	** now we have to add in the cases and popns for the missings: 
	** M 0-14,15-24,25-34
	expand 2 in 1
	replace sex=2 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_wpp=(25316) in 7
	sort age_10	
	
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_wpp=(19294)  in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_wpp=(18385) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  221   138525   159.54    100.95    87.96   115.51     6.89 |
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
gen percent=number/900*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASIRs" 
replace cancer_site=2 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'/version13/2-working/ASIRs" ,replace
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
	replace pop_wpp=(25316) in 7
	sort age_10	
	
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_wpp=(19294)  in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_wpp=(18385) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  221   138525   159.54    100.95    87.96   115.51     6.89 |
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
gen percent=number/438*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASIRs_male" 
replace cancer_site=2 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'/version13/2-working/ASIRs_male" ,replace
restore

*-------------------------------------------------------------------------------

** BREAST - excluded male breast cancer
tab pop_wpp age_10  if siteiarc==29 & sex==1 //female
tab pop_wpp age_10  if siteiarc==29 & sex==2 //male

//JC 19may2022: remove male breast cancers so rate calculated only based on female pop
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
	replace pop_wpp=(24395) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=2 in 9
	replace case=0 in 9
	replace pop_wpp=(18623) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command
sort age_10
total pop_wpp


distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BC (FEMALE) - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  171   148115   115.45     79.90    67.73    93.72     6.50 |
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
gen percent=number/900*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASIRs" 
replace cancer_site=3 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'/version13/2-working/ASIRs" ,replace
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
	replace pop_wpp=(24395) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=2 in 9
	replace case=0 in 9
	replace pop_wpp=(18623) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command
sort age_10
total pop_wpp


distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BC (FEMALE) - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  171   148115   115.45     79.90    67.73    93.72     6.50 |
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
gen percent=number/462*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASIRs_female" 
replace cancer_site=2 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'/version13/2-working/ASIRs_female" ,replace
restore

*-------------------------------------------------------------------------------

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
	** M&F 0-14,25-34
	** F   15-24
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(24395) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_wpp=(25316) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_wpp=(18623) in 16
	sort age_10

	expand 2 in 1
	replace sex=1 in 17
	replace age_10=3 in 17
	replace case=0 in 17
	replace pop_wpp=(18632) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=3 in 18
	replace case=0 in 18
	replace pop_wpp=(18385) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  114   286640   39.77     24.53    20.06    29.78     2.42 |
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
gen percent=number/900*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASIRs" 
replace cancer_site=4 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'/version13/2-working/ASIRs" ,replace
restore

** COLON - female only for top5 table
preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,25-34
	** F   15-24
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(24395) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_wpp=(25316) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_wpp=(18623) in 16
	sort age_10

	expand 2 in 1
	replace sex=1 in 17
	replace age_10=3 in 17
	replace case=0 in 17
	replace pop_wpp=(18632) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=3 in 18
	replace case=0 in 18
	replace pop_wpp=(18385) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

drop if sex==2 //female ONLY

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (FEMALE)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   58   148115   39.16     22.40    16.75    29.59     3.16 |
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
gen percent=number/462*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASIRs_female" 
replace cancer_site=3 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'/version13/2-working/ASIRs_female" ,replace
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
	** M 35-44
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(24395) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_wpp=(25316) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_wpp=(18623) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=2 in 17
	replace case=0 in 17
	replace pop_wpp=(19294)  in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=4 in 18
	replace case=0 in 18
	replace pop_wpp=(18494) in 18
	sort age_10

	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

drop if sex==1 //male ONLY

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (MALE)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   56   138525   40.43     26.84    20.10    35.30     3.75 |
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
gen percent=number/438*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASIRs_male" 
replace cancer_site=3 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'/version13/2-working/ASIRs_male" ,replace
restore

*-------------------------------------------------------------------------------

** CORPUS UTERI
tab pop_wpp age_10 if siteiarc==33

preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==33 // corpus uteri only
	keep if sex==1
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	
	** now we have to add in the cases and popns for the missings: 
	** F 0-14,15-24,25-34,35-44
	
	expand 2 in 1
	replace sex=1 in 6
	replace age_10=1 in 6
	replace case=0 in 6
	replace pop_wpp=(24395) in 6
	sort age_10	
	
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=2 in 7
	replace case=0 in 7
	replace pop_wpp=(18623) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=3 in 8
	replace case=0 in 8
	replace pop_wpp=(18632) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=4 in 9
	replace case=0 in 9
	replace pop_wpp=(19702) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CORPUS UTERI - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   50   148115   33.76     18.87    13.91    25.33     2.80 |
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
gen percent=number/900*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASIRs" 
replace cancer_site=5 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'/version13/2-working/ASIRs" ,replace
restore

** CORPUS UTERI - for female top 5 table
preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==33 // corpus uteri only
	keep if sex==1
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	
	** now we have to add in the cases and popns for the missings: 
	** F 0-14,15-24,25-34,35-44
	
	expand 2 in 1
	replace sex=1 in 6
	replace age_10=1 in 6
	replace case=0 in 6
	replace pop_wpp=(24395) in 6
	sort age_10	
	
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=2 in 7
	replace case=0 in 7
	replace pop_wpp=(18623) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=3 in 8
	replace case=0 in 8
	replace pop_wpp=(18632) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=4 in 9
	replace case=0 in 9
	replace pop_wpp=(19702) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CORPUS UTERI - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   50   148115   33.76     18.87    13.91    25.33     2.80 |
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
gen percent=number/462*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASIRs_female" 
replace cancer_site=4 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'/version13/2-working/ASIRs_female" ,replace
restore

*-------------------------------------------------------------------------------

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
	** M&F 0-14,15-24,25-34,35-44
	** F 75-84
	** M 85+
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=8 in 9
	replace case=0 in 9
	replace pop_wpp=(7985) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 10
	replace age_10=9 in 10
	replace case=0 in 10
	replace pop_wpp=(2596) in 10
	sort age_10

	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(24395) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_wpp=(25316) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(18623) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_wpp=(19294) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18632) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_wpp=(18385) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_wpp=(19702) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=4 in 18
	replace case=0 in 18
	replace pop_wpp=(18767) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RECTAL CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   33   286640   11.51      6.83     4.67     9.79     1.25 |
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
gen percent=number/900*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASIRs" 
replace cancer_site=7 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'/version13/2-working/ASIRs" ,replace
restore


** RECTUM - female only for top5 table
preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==14
	keep if sex==1
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24
	expand 2 in 1
	replace sex=1 in 5
	replace age_10=8 in 5
	replace case=0 in 5
	replace pop_wpp=(7985) in 5
	sort age_10

	expand 2 in 1
	replace sex=1 in 6
	replace age_10=1 in 6
	replace case=0 in 6
	replace pop_wpp=(24395) in 6
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=2 in 7
	replace case=0 in 7
	replace pop_wpp=(18623) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=3 in 8
	replace case=0 in 8
	replace pop_wpp=(18632) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=4 in 9
	replace case=0 in 9
	replace pop_wpp=(19702) in 9
	sort age_10
	

	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

drop if sex==2 // for rectal cancer - female ONLY

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
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
gen percent=number/462*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASIRs_female" 
replace cancer_site=6 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'/version13/2-working/ASIRs_female" ,replace
restore


** RECTUM - male only for top5 table
preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==14
	keep if sex==2
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	
	expand 2 in 1
	replace sex=2 in 5
	replace age_10=9 in 5
	replace case=0 in 5
	replace pop_wpp=(2596) in 5
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 6
	replace age_10=1 in 6
	replace case=0 in 6
	replace pop_wpp=(25316) in 6
	sort age_10

	expand 2 in 1
	replace sex=2 in 7
	replace age_10=2 in 7
	replace case=0 in 7
	replace pop_wpp=(19294) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=3 in 8
	replace case=0 in 8
	replace pop_wpp=(18385) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=4 in 9
	replace case=0 in 9
	replace pop_wpp=(18767) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

drop if sex==1 //male ONLY

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RECTAL CANCER (MALE)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   25   138525   18.05     11.42     7.36    17.18     2.40 |
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
gen percent=number/438*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASIRs_male" 
replace cancer_site=5 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'/version13/2-working/ASIRs_male" ,replace
restore

*-------------------------------------------------------------------------------

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
	** M&F 0-14,15-24
	** M   25-34,35-44,45-54
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_wpp=(24395) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 13
	replace age_10=1 in 13
	replace case=0 in 13
	replace pop_wpp=(25316) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_wpp=(18623) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=2 in 15
	replace case=0 in 15
	replace pop_wpp=(19294) in 15
	sort age_10

	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_wpp=(18385) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_wpp=(18767) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=5 in 18
	replace case=0 in 18
	replace pop_wpp=(19280) in 18
	sort age_10
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PANCREATIC CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   31   286640   10.81      5.65     3.78     8.29     1.10 |
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
gen percent=number/900*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASIRs" 
replace cancer_site=10 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'/version13/2-working/ASIRs" ,replace
restore

*-------------------------------------------------------------------------------

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

	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(24395) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_wpp=(25316) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(18623) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_wpp=(19294) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18632) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_wpp=(18385) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_wpp=(19702) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=4 in 18
	replace case=0 in 18
	replace pop_wpp=(18767) in 18
	sort age_10
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR LUNG CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   28   286640    9.77      5.31     3.47     7.94     1.09 |
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
gen percent=number/900*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASIRs" 
replace cancer_site=6 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'/version13/2-working/ASIRs" ,replace
restore

** LUNG - female only for top5 table
preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==21
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24,25-34,35-44

	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(24395) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_wpp=(25316) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(18623) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_wpp=(19294) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18632) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_wpp=(18385) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_wpp=(19702) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=4 in 18
	replace case=0 in 18
	replace pop_wpp=(18767) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

drop if sex==2 //female ONLY

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR LUNG CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   21   138525   15.16      8.91     5.43    14.08     2.11 |
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
gen percent=number/462*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASIRs_female" 
replace cancer_site=5 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'/version13/2-working/ASIRs_female" ,replace
restore


** LUNG - male only for top5 table
preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==21
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24,25-34,35-44

	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(24395) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_wpp=(25316) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(18623) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_wpp=(19294) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18632) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_wpp=(18385) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_wpp=(19702) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=4 in 18
	replace case=0 in 18
	replace pop_wpp=(18767) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

drop if sex==1 //male ONLY

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR LUNG CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   21   138525   15.16      8.91     5.43    14.08     2.11 |
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
gen percent=number/438*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASIRs_male" 
replace cancer_site=4 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'/version13/2-working/ASIRs_male" ,replace
restore

*-------------------------------------------------------------------------------

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
	** M&F 0-14,15-24,25-34,85+ 
	** F   75-84
	** M   25-34,35-44,45-54
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_wpp=(24395) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_wpp=(25316) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_wpp=(18623) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(19294) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_wpp=(18385) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=4 in 14
	replace case=0 in 14
	replace pop_wpp=(18767) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=5 in 15
	replace case=0 in 15
	replace pop_wpp=(19214) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=9 in 16
	replace case=0 in 16
	replace pop_wpp=(2646) in 16
	sort age_10

	expand 2 in 1
	replace sex=1 in 17
	replace age_10=8 in 17
	replace case=0 in 17
	replace pop_wpp=(7985) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(4063) in 18
	sort age_10
	
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR NHL (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   23   286640    8.02      5.03     3.15     7.76     1.12 |
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
gen percent=number/900*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASIRs" 
replace cancer_site=11 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'/version13/2-working/ASIRs" ,replace
restore

*-------------------------------------------------------------------------------

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
	** M&F  0-14,15-24,25-34,35-44
	** F	65-74,75-84
	** M 	45-54
	
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_wpp=(24395) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_wpp=(25316) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=2 in 10
	replace case=0 in 10
	replace pop_wpp=(18623) in 10
	sort age_10

	expand 2 in 1
	replace sex=2 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_wpp=(19294) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=3 in 12
	replace case=0 in 12
	replace pop_wpp=(18632) in 12
	sort age_10

	expand 2 in 1
	replace sex=2 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_wpp=(18385) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=4 in 14
	replace case=0 in 14
	replace pop_wpp=(19702) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_wpp=(18767) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=5 in 16
	replace case=0 in 16
	replace pop_wpp=(19214) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=7 in 17
	replace case=0 in 17
	replace pop_wpp=(13961) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=8 in 18
	replace case=0 in 18
	replace pop_wpp=(7985) in 18
	sort age_10
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR STOMACH CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   19   286640    6.63      3.88     2.29     6.30     0.98 |
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
gen percent=number/900*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASIRs" 
replace cancer_site=8 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'/version13/2-working/ASIRs" ,replace
restore


** STOMACH - male only for top5 table
preserve
	drop if age_10==.
	drop if beh!=3 //0 deleted
	keep if siteiarc==11
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
** now we have to add in the cases and popns for the missings:
	** M&F  0-14,15-24,25-34,35-44
	** F	65-74,75-84
	** M 	45-54
	
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_wpp=(24395) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_wpp=(25316) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=2 in 10
	replace case=0 in 10
	replace pop_wpp=(18623) in 10
	sort age_10

	expand 2 in 1
	replace sex=2 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_wpp=(19294) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=3 in 12
	replace case=0 in 12
	replace pop_wpp=(18632) in 12
	sort age_10

	expand 2 in 1
	replace sex=2 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_wpp=(18385) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=4 in 14
	replace case=0 in 14
	replace pop_wpp=(19702) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_wpp=(18767) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=5 in 16
	replace case=0 in 16
	replace pop_wpp=(19214) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=7 in 17
	replace case=0 in 17
	replace pop_wpp=(13961) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=8 in 18
	replace case=0 in 18
	replace pop_wpp=(7985) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

drop if sex==1 // for stomach cancer - male ONLY

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
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
gen percent=number/438*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASIRs_male" 
replace cancer_site=6 if cancer_site==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'/version13/2-working/ASIRs_male" ,replace
restore

*-------------------------------------------------------------------------------

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
	** M&F  0-14,15-24,25-34,35-44
	** F	65-74
	
	
	
	expand 2 in 1
	replace sex=2 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_wpp=(25316) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_wpp=(18623) in 11
	sort age_10

	expand 2 in 1
	replace sex=2 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(19294) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_wpp=(18632) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_wpp=(18385) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_wpp=(19702) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_wpp=(18767) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=1 in 17
	replace case=0 in 17
	replace pop_wpp=(24395) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=7 in 18
	replace case=0 in 18
	replace pop_wpp=(13961) in 18
	sort age_10
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR STOMACH CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   19   286640    6.63      3.88     2.29     6.30     0.98 |
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
gen percent=number/900*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASIRs" 
replace cancer_site=9 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'/version13/2-working/ASIRs" ,replace
restore

