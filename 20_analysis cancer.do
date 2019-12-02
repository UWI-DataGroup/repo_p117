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

**********************************************************************************
** ASIR and 95% CI for Table 1 using AR's site groupings - using WHO World popn **
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
tab siteiarc ,m

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

tab pop_bss age_10  if sex==1 & dxyr==2013 //female
tab pop_bss age_10  if sex==2 & dxyr==2013 //male

STOP - change pop to pop_bss
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

distrate case pop_bss using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR2013_bss_all,replace) format(%8.2f)
** THIS IS FOR ALL SITES (INVASIVE TUMOURS ONLY) - STD TO WHO WORLD POPN 
/*

*/
** JC update: Save these results as a dataset for reporting
use ASR2013_bss_all.dta ,clear
gen population="BSS"
gen site="all"
gen year="2013"
rename rateadj asir
rename lb_gam ci1
rename ub_gam ci2
collapse population site year asir ci1 ci2
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
	replace pop_bss=(28005) in 6
	sort age_10	
	
	expand 2 in 1
	replace sex=2 in 7
	replace age_10=2 in 7
	replace case=0 in 7
	replace pop_bss=(18510)  in 7
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=3 in 8
	replace case=0 in 8
	replace pop_bss=(18465) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=4 in 9
	replace case=0 in 9
	replace pop_bss=(19550) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bss

distrate case pop_bss using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR2013_bss_prost,replace) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD POPN 
/*

*/
restore

** BREAST
tab pop age_10  if siteiarc==29 & sex==1 & dxyr==2013 //female
tab pop age_10  if siteiarc==29 & sex==2 & dxyr==2013 //male

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
	replace pop_bss=(26755) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_bss=(28005) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bss=(18530) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_bss=(18510) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bss=(18465) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_bss=(19550) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=6 in 17
	replace case=0 in 17
	replace pop_bss=(14195) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_bss=(1666) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command
sort age_10
total pop_bss


distrate case pop_bss using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR2013_bss_breast,replace) format(%8.2f)
** THIS IS FOR BC (M&F) - STD TO WHO WORLD POPN 
/*

*/
restore

** COLON 
tab pop age_10  if siteiarc==13 & sex==1 & dxyr==2013 //female
tab pop age_10  if siteiarc==13 & sex==2 & dxyr==2013 //male

preserve
	drop if dxyr!=2013
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_bss, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24,25-34
	** M 85+
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_bss=(26755) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 13
	replace age_10=1 in 13
	replace case=0 in 13
	replace pop_bss=(28005) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_bss=(18530) in 14
	sort age_10

	expand 2 in 1
	replace sex=2 in 15
	replace age_10=2 in 15
	replace case=0 in 15
	replace pop_bss=(18510) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_bss=(19410) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=3 in 17
	replace case=0 in 17
	replace pop_bss=(18465) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_bss=(1666) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bss

distrate case pop_bss using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR2013_bss_colon,replace) format(%8.2f)
** THIS IS FOR COLON CANCER (M&F)- STD TO WHO WORLD POPN

/*

*/
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
	replace sex=1 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_bss=(26755) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=2 in 9
	replace case=0 in 9
	replace pop_bss=(18530) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bss

distrate case pop_bss using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR2013_bss_cervix,replace) format(%8.2f)
** THIS IS FOR CERVICAL CANCER WITHOUT CIN 3 - STD TO WHO WORLD POPN 
/*

*/
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
	replace pop_bss=(26755) in 5
	sort age_10	
	
	expand 2 in 1
	replace sex=1 in 6
	replace age_10=2 in 6
	replace case=0 in 6
	replace pop_bss=(18530) in 6
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=3 in 7
	replace case=0 in 7
	replace pop_bss=(19410) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=4 in 8
	replace case=0 in 8
	replace pop_bss=(21080) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=9 in 9
	replace case=0 in 9
	replace pop_bss=(3388) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bss

distrate case pop_bss using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR2013_bss_corpus,replace) format(%8.2f)
** THIS IS FOR CORPUS UTERI - STD TO WHO WORLD POPN 
/*

*/
restore

REPEAT ABOVE USING WPP POP


********************************************************************
* (2.4c) IR age-standardised to WHO world popn - ALL TUMOURS: 2014
********************************************************************
** Using WHO World Standard Population
tab siteiarc ,m

drop _merge
merge m:m sex age_10 using "`datapath'\version02\2-working\pop_bss_2014-10"
drop if _merge==2
** There are 2 unmatched records (_merge==2) since 2013 data doesn't have any cases of males with age range 0-14 or 15-24
**	age_10	site  dup	sex	 pfu	age45	age55	pop_bb	_merge
**  0-14	  .     .	male   .	0-44	0-54	28005	using only (2)
** 15-24	  .     .	male   .	0-44	0-54	18510	using only (2)

tab pop age_10  if sex==1 & dxyr==2014 //female
tab pop age_10  if sex==2 & dxyr==2014 //male


** Next, IRs for invasive tumours only
preserve
    drop if dxyr!=2014
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: F 15-24
	** JC: I had to change the obsID so that the replacements could take place as the
	** dataset stopped at obsID when the above code was run
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=2 in 18
	replace case=0 in 18
	replace pop_bb=(18530) in 18
	sort age_10	
		
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR2014_bss_all,replace) format(%8.2f)
** THIS IS FOR ALL SITES (INVASIVE TUMOURS ONLY) - STD TO WHO WORLD POPN 
/*

*/
restore

*******************************
** Next, IRs by site and year **
*******************************

** PROSTATE
tab pop_bb age_10 if siteiarc==39 & dxyr==2014 //male

preserve
    drop if dxyr!=2014
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==39 // prostate only
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: M 0-14, 15-24, 25-34
	** JC: I had to change the obsID so that the replacements could take place as the
	** dataset stopped at obsID when the above code was run
	expand 2 in 1
	replace sex=2 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_bb=(28005) in 7
	sort age_10	
	
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_bb=(18510)  in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_bb=(18465) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR2014_bss_prost,replace) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD POPN 
/*

*/
restore

** BREAST
tab pop age_10  if siteiarc==29 & sex==1 & dxyr==2014 //female
tab pop age_10  if siteiarc==29 & sex==2 & dxyr==2014 //male

preserve
    drop if dxyr!=2014
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==29 // breast only
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14, 15-24
	** M 25-34, 35-44, 55-64, 75-84, 85+
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_bb=(26755) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_bb=(18530) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_bb=(28005) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bb=(18510) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_bb=(18465) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_bb=(19550) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=7 in 16
	replace case=0 in 16
	replace pop_bb=(14195) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=8 in 17
	replace case=0 in 17
	replace pop_bb=(4835) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_bb=(1666) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command
sort age_10
total pop_bb

** for both female & male breast cancer; JC: added for 2013
** but may not use in ann rpt as total <10 cases (=4)
** AR to JC: yes you can use this, as it's a single rate for the whole population 
** and we don't say #M, #F just overall IR (M+F)
** the thing is though, we won't use it as it really lowers the IR - there are so
** few M cases but you then have to use the whole population
distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR2014_bss_breast,replace) format(%8.2f)
** THIS IS FOR BC (M&F) - STD TO WHO WORLD POPN 
/*

*/
restore

** COLON 
tab pop age_10  if siteiarc==13 & sex==1 & dxyr==2014 //female
tab pop age_10  if siteiarc==13 & sex==2 & dxyr==2014 //male

preserve
    drop if dxyr!=2014
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: M&F 0-14, M&F 15-24
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_bb=(28005) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=1 in 16
	replace case=0 in 16
	replace pop_bb=(26755) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=2 in 17
	replace case=0 in 17
	replace pop_bb=(18530) in 17
	sort age_10

	expand 2 in 1
	replace sex=2 in 18
	replace age_10=2 in 18
	replace case=0 in 18
	replace pop_bb=(18510) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR2014_bss_colon,replace) format(%8.2f)
** THIS IS FOR COLON CANCER (M&F)- STD TO WHO WORLD POPN

/*

*/
restore


** CERVIX UTERI - excl. CIN 3
tab pop_bb age_10 if siteiarc==32 & dxyr==2014 //female

preserve
    drop if dxyr!=2014
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==32 // corpus uteri only
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: F 0-14, 15-24
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_bb=(26755) in 8
	sort age_10	
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=2 in 9
	replace case=0 in 9
	replace pop_bb=(18530)  in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR2014_bss_cervix,replace) format(%8.2f)
** THIS IS FOR CERVICAL CANCER - STD TO WHO WORLD POPN 
/*

*/
restore


** CORPUS UTERI
tab pop_bb age_10 if siteiarc==33 & dxyr==2014 //female

preserve
    drop if dxyr!=2014
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==33 // corpus uteri only
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: F 0-14, 15-24, 25-34
	** JC: I had to change the obsID so that the replacements could take place as the
	** dataset stopped at obsID when the above code was run
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_bb=(26755) in 7
	sort age_10	
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_bb=(18530)  in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_bb=(19410) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR2014_bss_corpus,replace) format(%8.2f)
** THIS IS FOR CORPUS UTERI(BOTH) - STD TO WHO WORLD POPN 
/*

*/
restore

clear

use "`datapath'\version02\2-working\ASIRs_BSS_WPP", clear
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
Generated using Dofile: 20_analysis cancer.do
putdocx textblock end
//putdocx pagebreak
putdocx table tbl1 = data(title results_2014 results_2013 results_2008), halign(center)
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(3,2), nformat(%04.2f)
putdocx table tbl1(3,3), nformat(%04.2f)
putdocx table tbl1(3,4), nformat(%04.2f)
putdocx table tbl1(7,2), nformat(%2.1f)
putdocx table tbl1(7,3), nformat(%2.1f)
putdocx table tbl1(7,4), nformat(%2.1f)
putdocx table tbl1(8,2), nformat(%2.1f)
putdocx table tbl1(8,3), nformat(%2.1f)
putdocx table tbl1(8,4), nformat(%2.1f)
putdocx table tbl1(9,2), nformat(%2.1f)
putdocx table tbl1(9,3), nformat(%2.1f)
putdocx table tbl1(9,4), nformat(%2.1f)
putdocx table tbl1(10,2), nformat(%2.1f)
putdocx table tbl1(10,3), nformat(%2.1f)
putdocx table tbl1(10,4), nformat(%2.1f)

putdocx save "`datapath'\version02\3-output\2019-12-02_annual_report_stats.docx", replace
putdocx clear

save "`datapath'\version02\3-output\2008_2013_2014_summstats" ,replace
clear
