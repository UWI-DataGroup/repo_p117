** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			9_sites_2014_da.do
    //  project:				BNR
    //  analysts:				Jacqueline CAMPBELL
    //  date first created      27-MAR-2019
    // 	date last modified	    27-MAR-2019
    //  algorithm task			Generate Incidence Rates by (IARC) site: (1) identification of top sites (2) crude: by sex (3) crude: by site (4) ASR(ASIR): all sites, world & US(2000) pop (5) ASR(ASIR): all sites, by sex (world & US)
    //  status                  Completed
    //  objectve                To have one dataset with cleaned, grouped and analysed 2014 data for 2014 cancer report.

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
    log using "`logpath'\9_sites_2014_da.smcl", replace
** HEADER -----------------------------------------------------


* *********************************************
* ANALYSIS: SECTION 3 - cancer sites
* Covering:
*  3.1  Classification of cancer by site
*  3.2 	ASIRs by site; overall, men and women
* *********************************************
** NOTE: bb popn and WHO popn data prepared by IH are ALL coded M=2 and F=1
** Above note by AR from 2008 dofile

** Load the dataset
use "`datapath'\version01\2-working\2014_cancer_numbers_da.dta", replace

***********************
** 3.1 CANCERS BY SITE
***********************
tab icd10 if beh<3 ,m //24 in-situ

tab icd10 ,m //0 missing

tab siteiarc ,m //0 missing

** top 10 sites are: prostate (172), colon & rectum (107+18+37=162), breast (132) lymphoid/haem (68) cervix (43)
** uterus (35) respiratory (34) urinary (32) other digestive (27) pancreas (21)- look at top sites by sex

** Below top 10 code added by JC for 2014 DQIs and instead of visually 
** determining top ten as done for 2008 & 2013
** Note NMSCs (non-reportable skin cancers) and in-situ tumours excluded from top ten analysis
tab siteiarc if siteiarc!=25 & siteiarc!=64
tab siteiarc ,m //927 - 24 insitu; 45 O&U
tab siteiarc patient

** NS decided on 18march2019 to use IARC site groupings so variable siteiarc will be used instead of sitear
** IARC site variable created based on CI5-XI incidence classifications (see chapter 3 Table 3.1. of that volume) based on icd10
display `"{browse "http://ci5.iarc.fr/CI5-XI/Pages/Chapter3.aspx":IARC-CI5-XI-3}"'


** For annual report - Section 1: Incidence - Table 2a
** Below top 10 code added by JC for 2014
** All sites excl. O&U, insitu, non-reportable skin cancers - using IARC CI5's site groupings
preserve
drop if siteiarc==25|siteiarc==61|siteiarc==64 //69 obs deleted
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
siteiarc	                                count	percentage
Prostate (C61)	                            198	    29.82
Breast (C50)	                            159	    23.95
Colon (C18)	                                114	    17.17
Corpus uteri (C54)	                        39	    5.87
Lung (incl. trachea and bronchus) (C33-34)	32	    4.82
Rectum (C19-20)	                            28	    4.22
Multiple myeloma (C90)	                    28	    4.22
Bladder (C67)	                            24	    3.61
Pancreas (C25)	                            21	    3.16
Stomach (C16)	                            21	    3.16
*/
total count //664
restore

** proportions for Table 1 using AR's site groupings
tab siteiarc sex ,m
tab siteiarc , m
tab siteiarc if sex==2 ,m // female
tab siteiarc if sex==1 ,m // male							  
** sites by behaviour
tab siteiarc beh ,m
tab beh ,m

** For annual report - Section 1: Incidence - Table 1
** FEMALE - using IARC's site groupings
preserve
drop if sex==1 //465 obs deleted
drop if siteiarc==61|siteiarc==64 //75 obs deleted
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

gen totpercent=(count/462)*100 //all cancers excl. male(465)
gen alltotpercent=(count/927)*100 //all cancers
/*
siteiarc	        count	percentage	totpercent	alltotpercent
Breast (C50)	    155	    53.26	    33.54978	16.7206
Colon (C18)	        65	    22.34	    14.06926	7.011866
Corpus uteri (C54)	39	    13.40	    8.441559	4.20712
Cervix uteri (C53)	17	    5.84	    3.679654	1.833873
Rectum (C19-20)	    15	    5.15	    3.246753	1.618123

*/
total count //291
restore

** For annual report - Section 1: Incidence - Table 1
** Below top 5 code added by JC for 2014
** MALE - using IARC's site groupings
preserve
drop if sex==2 //462 obs deleted
drop if siteiarc==61|siteiarc==64 //23 obs deleted
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

gen totpercent=(count/465)*100 //all cancers excl. female(462)
gen alltotpercent=(count/927)*100 //all cancers
/*
siteiarc	                                count	percentage	totpercent	alltotpercent
Prostate (C61)	                            198	    66.89	    42.58065	21.35922
Colon (C18)	                                49	    16.55	    10.53763	5.285868
Lung (incl. trachea and bronchus) (C33-34)	19	    6.42	    4.086021	2.049623
Multiple myeloma (C90)	                    15	    5.07	    3.225806	1.618123
Bladder (C67)	                            15	    5.07	    3.225806	1.618123
*/
total count //296
restore


/*
** For annual report - Section 1: Incidence - Table 1
** Below top 10 code added by JC for 2014
** All sites - using Angie's site groupings
preserve
bysort sitear: gen n=_N
bysort n sitear: gen tag=(_n==1)
replace tag = sum(tag)
sum tag , meanonly
gen top10 = (tag>=(`r(max)'-9))
sum n if tag==(`r(max)'-9), meanonly
replace top10 = 1 if n==`r(max)'
tab sitear top10 if top10!=0
contract sitear top10 if top10!=0, freq(count) percent(percentage)
summ
describe
gsort -count
drop top10
/*
sitear											count	percentage
C61: prostate									198		25.55
C50: breast										159		20.52
C18: colon										114		14.71
C42,C77: haem & lymph systems					66		8.52
C30-C39: respiratory and intrathoracic organs	46		5.94
C53: cervix										41		5.29
C54,55: uterus									40		5.16
C80: unknown primary site						38		4.90
C15, C17, C22-C24, C26: other digestive organs	38		4.90
C64-C68: urinary tract							35		4.52
*/
total count
restore

** For annual report - Section 1: Incidence - Table 1
** Below top 10 code added by JC for 2014
** All sites - using CR5's site groupings
preserve
drop if sitecr5db==20|sitecr5db==26|sitecr5db==32 //69 obs deleted
bysort sitecr5db: gen n=_N
bysort n sitecr5db: gen tag=(_n==1)
replace tag = sum(tag)
sum tag , meanonly
gen top10 = (tag>=(`r(max)'-9))
sum n if tag==(`r(max)'-9), meanonly
replace top10 = 1 if n==`r(max)'
tab sitecr5db top10 if top10!=0
contract sitecr5db top10 if top10!=0, freq(count) percent(percentage)
summ
describe
gsort -count
drop top10
/*
sitecr5db	count	percentage
Prostate (C61)	198	27.97
Breast (C50)	159	22.46
Colon, rectum, anus (C18-21)	144	20.34
Lymphoma (C81-85,88,90,96)	47	6.64
Corpus & Uterus NOS (C54-55)	40	5.65
Lung, trachea, bronchus (C33-34)	32	4.52
Bladder (C67)	24	3.39
Mouth & pharynx (C00-14)	22	3.11
Stomach (C16)	21	2.97
Pancreas (C25)	21	2.97
*/
total count
restore
*/
**********************************************************************************
** ASIR and 95% CI for Table 1 using AR's site groupings - using WHO World popn **
gen pfu=1 // for % year if not whole year collected; not done for cancer        **
**********************************************************************************
***********************************************************
** First, recode sex to match with the IR data
tab sex ,m
rename sex sex_old
gen sex=1 if sex_old==2
replace sex=2 if sex_old==1
drop sex_old
label drop sex_lab
label define sex_lab 1 "female" 2 "male"
label values sex sex_lab
tab sex ,m

********************************************************************
* (2.4c) IR age-standardised to WHO world popn - ALL TUMOURS
********************************************************************
** Using WHO World Standard Population
tab siteiarc ,m

drop _merge
merge m:m sex age_10 using "`datapath'\version01\2-working\bb2010_10-2.dta"
drop if _merge==2
** There are 2 unmatched records (_merge==2) since 2013 data doesn't have any cases of males with age range 0-14 or 15-24
**	age_10	site  dup	sex	 pfu	age45	age55	pop_bb	_merge
**  0-14	  .     .	male   .	0-44	0-54	28005	using only (2)
** 15-24	  .     .	male   .	0-44	0-54	18510	using only (2)

tab pop age_10  if sex==1 //female
tab pop age_10  if sex==2 //male


** Next, IRs for all tumours
tab pop age_10
tab age_10 ,m //none missing
preserve
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
		
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR ALL TUMOURS - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  927   277814   333.68    236.74   221.29   253.03     8.02 |
  +-------------------------------------------------------------+
*/
restore


** Next, IRs by sex
** for all women
tab pop age_10
tab pop age_10 if sex==1 //female
preserve
	drop if age_10==.
	keep if (sex==1) // women only
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
		
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR ALL TUMOURS (WOMEN) - STD TO WHO WORLD POPN 
/*  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  462   144803   319.05    218.45   198.06   240.45    10.67 |
  +-------------------------------------------------------------+
*/
restore

** for all men
tab pop age_10
tab pop age_10 if sex==2 //male
preserve
	drop if age_10==.
	keep if (sex==2) // men only
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
		
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR ALL TUMOURS (MEN) - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  465   133011   349.60    265.72   241.81   291.44    12.50 |
  +-------------------------------------------------------------+
*/
restore

STOPPED HERE - disable sitear and re-enable siteiarc (chk top10 & top5)
** Next, IRs by sex
** BREAST - female only
preserve
	drop if age_10==.
	keep if sitear==14 // breast only
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: M&F 0-14, 15-24
	** M 25-34, 35-44, 55-74, 75-84, 85+
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

drop if sex==2 // for breast cancer - female ONLY

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BREAST (FEMALE ONLY) - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  155   144803   107.04     74.54    62.94    87.78     6.20 |
  +-------------------------------------------------------------+
*/
restore


** COLON 
tab pop age_10  if sitear==3 & sex==1 //female
tab pop age_10  if sitear==3 & sex==2 //male

preserve
	drop if age_10==.
	keep if sitear==3
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: M&F 0-14, 15-24
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

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  114   277814   41.03     27.98    22.95    33.85     2.71 |
  +------------------------------------------------------------+
*/
restore

** COLON - female only
preserve
	drop if age_10==.
	keep if sitear==3
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: M&F 0-14, 15-24
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

drop if sex==2 // for colon cancer in WOMEN

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (WOMEN) - STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   65   144803   44.89     28.37    21.63    36.74     3.73 |
  +------------------------------------------------------------+
*/
restore

** COLON - male only
preserve
	drop if age_10==.
	keep if sitear==3
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: M&F 0-14, 15-24
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

drop if sex==1 // for colon cancer in MEN

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (MEN) - STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   49   133011   36.84     27.95    20.61    37.18     4.09 |
  +------------------------------------------------------------+
*/
restore

** CERVIX UTERI - female only
tab pop_bb age_10 if sitear==15 //female

preserve
	drop if age_10==.
	keep if sitear==15 // cervix uteri
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: F 0-14
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_bb=(26755) in 9
	sort age_10	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CERVIX - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   41   144803   28.31     25.37    17.98    34.72     4.15 |
  +------------------------------------------------------------+
*/
restore


** CORPUS UTERI - female only
tab pop_bb age_10 if sitear==16 //female

preserve
	drop if age_10==.
	keep if sitear==16 // corpus uteri, uterus NOS
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: F 0-14, 15-24, 25-34
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

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR UTERUS - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   40   144803   27.62     18.50    13.13    25.51     3.05 |
  +------------------------------------------------------------+
*/
restore

** BLOOD & LYMPH
tab pop age_10 if sitear==10 & sex==1 //female
tab pop age_10 if sitear==10 & sex==2 //male

preserve
	drop if age_10==.
	keep if sitear==10
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** F 15-24
	
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

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BLOOD/LYMPH (M&F)- STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   66   277814   23.76     18.56    14.17    23.90     2.42 |
  +------------------------------------------------------------+
*/
restore

** BLOOD & LYMPH - female only
preserve
	drop if age_10==.
	keep if sitear==10
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** F 15-24
	
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

drop if sex==2 // for  blood & lymph in WOMEN

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BLOOD/LYMPH (WOMEN)- STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   27   144803   18.65     14.13     8.96    21.20     3.02 |
  +------------------------------------------------------------+
*/
restore

** BLOOD & LYMPH - male only
preserve
	drop if age_10==.
	keep if sitear==10
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** F 15-24
	
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

drop if sex==1 // for blood & lymph in MEN

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BLOOD/LYMPH (MEN)- STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   39   133011   29.32     24.04    16.95    33.13     3.99 |
  +------------------------------------------------------------+
*/
restore


** PROSTATE - male only
tab pop age_10 if sitear==19
preserve
	drop if age_10==.
	keep if sitear==19 // prostate only
	
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

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  198   133011   148.86    111.54    96.42   128.48     8.03 |
  +-------------------------------------------------------------+
*/
restore


** RESPIRATORY
tab pop age_10 if sitear==8 & sex==1 //female
tab pop age_10 if sitear==8 & sex==2 //male

preserve
	drop if age_10==.
	keep if sitear==8
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24,25-34,35-44
	** F 45-54
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_bb=(26755) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_bb=(28005) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_bb=(18530) in 12
	sort age_10

	expand 2 in 1
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bb=(18510) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_bb=(19410) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bb=(18465) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_bb=(21080) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_bb=(19550) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=5 in 18
	replace case=0 in 18
	replace pop_bb=(21945) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RESPIRATORY (M&F)- STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   46   277814   16.56     10.85     7.87    14.68     1.68 |
  +------------------------------------------------------------+
*/
restore

** RESPIRATORY - male only
preserve
	drop if age_10==.
	keep if sitear==8
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24,25-34,35-44
	** F 45-54
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_bb=(26755) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_bb=(28005) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_bb=(18530) in 12
	sort age_10

	expand 2 in 1
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bb=(18510) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_bb=(19410) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bb=(18465) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_bb=(21080) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_bb=(19550) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=5 in 18
	replace case=0 in 18
	replace pop_bb=(21945) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

drop if sex==1 // for lung cancer in MEN

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RESPIRATORY (MEN) - STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   30   133011   22.55     16.59    11.13    23.94     3.14 |
  +------------------------------------------------------------+
*/
restore


** OTHER DIGESTIVE
tab pop age_10 if sitear==7 & sex==1 //female
tab pop age_10 if sitear==7 & sex==2 //male

preserve
	drop if age_10==.
	keep if sitear==7
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 15-24, 25-34
	** M 0-14
	** F 45-54, 55-64

	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_bb=(28005) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bb=(18530) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_bb=(18510) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bb=(19410) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_bb=(18465) in 16
	sort age_10
		
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=5 in 17
	replace case=0 in 17
	replace pop_bb=(21945) in 17
	sort age_10
		
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=6 in 18
	replace case=0 in 18
	replace pop_bb=(15940) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR OTHER DIGESTIVE (M&F)- STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   38   277814   13.68      9.47     6.60    13.24     1.64 |
  +------------------------------------------------------------+
*/
restore

** OTHER DIGESTIVE - male only
preserve
	drop if age_10==.
	keep if sitear==7
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 15-24, 25-34
	** M 0-14
	** F 45-54, 55-64

	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_bb=(28005) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bb=(18530) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_bb=(18510) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bb=(19410) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_bb=(18465) in 16
	sort age_10
		
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=5 in 17
	replace case=0 in 17
	replace pop_bb=(21945) in 17
	sort age_10
		
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=6 in 18
	replace case=0 in 18
	replace pop_bb=(15940) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

drop if sex==1 // for other digestive in MEN

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR OTHER DIGESTIVE (MEN)- STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   25   133011   18.80     14.23     9.15    21.26     2.97 |
  +------------------------------------------------------------+
*/
restore


** URINARY TRACT 
tab pop age_10  if sitear==20 & sex==1 //female
tab pop age_10  if sitear==20 & sex==2 //male

preserve
	drop if age_10==.
	keep if sitear==20
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	** F 45-54
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_bb=(26755) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_bb=(28005) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_bb=(18530) in 12
	sort age_10

	expand 2 in 1
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bb=(18510) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_bb=(19410) in 14
	sort age_10

	expand 2 in 1
	replace sex=2 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bb=(18465) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_bb=(21080) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_bb=(19550) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=5 in 18
	replace case=0 in 18
	replace pop_bb=(21945) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR URINARY TRACT (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   35   277814   12.60      8.28     5.70    11.72     1.48 |
  +------------------------------------------------------------+
*/
restore

** URINARY TRACT - male only
preserve
	drop if age_10==.
	keep if sitear==20
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	** F 45-54
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_bb=(26755) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_bb=(28005) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_bb=(18530) in 12
	sort age_10

	expand 2 in 1
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bb=(18510) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_bb=(19410) in 14
	sort age_10

	expand 2 in 1
	replace sex=2 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bb=(18465) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_bb=(21080) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_bb=(19550) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=5 in 18
	replace case=0 in 18
	replace pop_bb=(21945) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

drop if sex==1 // for bladder cancer in MEN

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR URINARY TRACT (MEN)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   19   133011   14.28     10.67     6.40    16.90     2.57 |
  +------------------------------------------------------------+
*/
restore


** RECTUM 
tab pop age_10  if sitear==5 & sex==1 //female
tab pop age_10  if sitear==5 & sex==2 //male

preserve
	drop if age_10==.
	keep if sitear==5
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34
	** M   35-44,65-74,75-84,85+
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_bb=(26755) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_bb=(28005) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bb=(18530) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_bb=(18510) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bb=(19410) in 15
	sort age_10

	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_bb=(18465) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_bb=(19550) in 17
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

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RECTUM/ANUS (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   26   277814    9.36      6.46     4.18     9.64     1.34 |
  +------------------------------------------------------------+
*/
restore


** PSU (primary site unknown)
tab pop age_10  if sitear==25 & sex==1 //female
tab pop age_10  if sitear==25 & sex==2 //male

preserve
	drop if age_10==.
	keep if sitear==25
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_bb=(26755) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_bb=(28005) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bb=(18530) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_bb=(18510) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bb=(19410) in 15
	sort age_10

	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_bb=(18465) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_bb=(21080) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=4 in 18
	replace case=0 in 18
	replace pop_bb=(19550) in 18
	sort age_10
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PSU (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   38   277814   13.68      8.59     6.01    12.01     1.47 |
  +------------------------------------------------------------+
*/
restore

/*
tab siteiarc sex ,m 

tab siteiarc ,m

** proportions for Table 1
tab siteiarc if sex==2 ,m // female

tab siteiarc if sex==1 ,m // male
								  
** sites by behaviour
tab siteiarc beh ,m

tab beh ,m
*/

** Info for first table (summary state E1):
** proportion registrations per popn
dis (927/277814)*100 // all cancers
dis (903/277814)*100 // malignant only
dis (24/277814)*100 // in-situ only

** No., % deaths
tab slc ,m
tab slc if beh<3 ,m
tab slc if beh==3 ,m

tab deceased if patient==1 ,m

tab beh deceased if patient==1 ,m

dis 488/912 //% deaths for all cancers
dis 0/23 //% deaths for in-situ cancers
dis 488/889 //% deaths for malignant cancers

** No., % deaths by end 2014
tab deceased if patient==1 & (dod>d(31dec2013) & dod<d(01jan2015)) ,m

tab beh deceased if patient==1 & (dod>d(31dec2013) & dod<d(01jan2015)) ,m

dis 303/912 //% deaths for all cancers
dis 0/23 //% deaths for in-situ cancers
dis 303/889 //% deaths for malignant cancers

tab basis ,m
tab basis if beh<3 ,m

tab basis if beh==3 ,m

tab basis beh ,m
dis 132/927 //% DCOs for all cancers
dis 0/24 //% DCOs for in-situ cancers
dis 132/903 //% DCOs for malignant cancers


** number of multiple tumours
tab patient ,m //15 multiple events

dis 15/927 //% MPs for all cancers
dis 3/15 //site(s) with highest %MPs prostate, colon: both each have 3

tab beh if patient==1 ,m

** now save dataset with site included
save "`datapath'\version01\2-working\2014_cancer_sites_da.dta", replace

/*
********************************************************************************
** 3.2 Now we want to do IR by site - first overall, then by sex: use TUMOURS not pts
********************************************************************************
** First, recode sex to match with the IR data
tab sex ,m
rename sex sex_old
gen sex=1 if sex_old==2
replace sex=2 if sex_old==1
drop sex_old
label drop sex_lab
label define sex_lab 1 "female" 2 "male"
label values sex sex_lab
tab sex ,m

** JC updated below code for 2014 to be based on IARC sites,
** not 2008 & 2013 site variable
** ALL TUMOURS (incl.non-invasive)
preserve
	collapse (sum) case, by(siteiarc)

	/*
	collapse (sum) case , by(pfu site)
	
	** Weighting for incidence calculation IF period is NOT exactly one year
	rename pop_bb fpop_bb
	gen pop_bb = fpop_bb * pfu
	*/
	gen pop_bb=277814
	label var pop_bb "Barbados population"
	gen ir = (case / pop_bb) * (10^5)
	label var ir "Incidence Rate by (IARC) site"

	* Standard Error
	gen se = ( (case^(1/2)) / pop_bb) * (10^5)

	* Lower 95% CI
	gen lower = ( (0.5 * invchi2(2*case, (0.05/2))) / pop_bb ) * (10^5)
	replace lower = 0 if ir==0
	* Upper 95% CI
	gen upper = ( (0.5 * invchi2(2*(case+1), (1-(0.05/2)))) / pop_bb ) * (10^5)

	* Display the results
	label var ir "IR"
	label var se "SE"
	label var lower "95% lo"
	label var upper "95% hi"
	foreach var in ir se lower upper {
			format `var' %8.2f
			}
	sort case 
	list siteiarc case pop_bb ir se lower upper , noobs table sum(case pop_bb)
** FOR ALL TUMOURS	: NOTE IGNORE BC AND PC AS THEY NEED DIFFERENT DENOMINATORS!!
** Above note done by AR - unsure why they are to have different denominators
	sort siteiarc
	list siteiarc case pop_bb ir se lower upper , noobs table sum(case pop_bb)
restore

** ALL TUMOURS (invasive only)
preserve
	drop if siteiarc==64 //24 obs deleted
	collapse (sum) case, by(siteiarc)

	/*
	collapse (sum) case , by(pfu site)
	
	** Weighting for incidence calculation IF period is NOT exactly one year
	rename pop_bb fpop_bb
	gen pop_bb = fpop_bb * pfu
	*/
	gen pop_bb=277814
	label var pop_bb "Barbados population"
	gen ir = (case / pop_bb) * (10^5)
	label var ir "Incidence Rate by (IARC) site"

	* Standard Error
	gen se = ( (case^(1/2)) / pop_bb) * (10^5)

	* Lower 95% CI
	gen lower = ( (0.5 * invchi2(2*case, (0.05/2))) / pop_bb ) * (10^5)
	replace lower = 0 if ir==0
	* Upper 95% CI
	gen upper = ( (0.5 * invchi2(2*(case+1), (1-(0.05/2)))) / pop_bb ) * (10^5)

	* Display the results
	label var ir "IR"
	label var se "SE"
	label var lower "95% lo"
	label var upper "95% hi"
	foreach var in ir se lower upper {
			format `var' %8.2f
			}
	sort case 
	list siteiarc case pop_bb ir se lower upper , noobs table sum(case pop_bb)
** FOR ALL INVASIVE TUMOURS	: NOTE IGNORE BC AND PC AS THEY NEED DIFFERENT DENOMINATORS!!
** Above note done by AR - unsure why they are to have different denominators
	sort siteiarc
	list siteiarc case pop_bb ir se lower upper , noobs table sum(case pop_bb)

** JC update: Save these results as a dataset to use for DQI
rename ir crude_siteiarc
rename se crudese_siteiarc
**gen crudese_allsites=crude_siteiarc+""+"("+crudese_siteiarc+")"
drop lower upper
save "data\dqi\2014_cancer_dqi_crude_siteiarc.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - All IARC Sites: Crude Rate"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore


** Next, IRs by site and by sex
** First, for all men
preserve
	collapse (sum) case , by(siteiarc sex)
	drop if sex==1 //40 obs deleted
	/*
	collapse (sum) case , by(pfu site sex)
	
	** Weighting for incidence calculation IF period is NOT exactly one year
	rename pop_bb fpop_bb
	gen pop_bb = fpop_bb * pfu
	*/
	gen pop_bb=133011
	** JC: replaced above total  '3_section2.do' WHO pop_bb men total
	** 2008 total=144803
    ** 2013 total=133011
	** JC: male & female totals seem to be switched for 2008? 
	** AR: yes! But luckily only once... and that table (crude rates by sex) was never presented - phew!
	** well spotted JC :-)
		
	label var pop_bb "Barbados population"
	gen ir = (case / pop_bb) * (10^5)
	label var ir "Incidence Rate by site"

	* Standard Error
	gen se = ( (case^(1/2)) / pop_bb) * (10^5)

	* Lower 95% CI
	gen lower = ( (0.5 * invchi2(2*case, (0.05/2))) / pop_bb ) * (10^5)
	replace lower = 0 if ir==0
	* Upper 95% CI
	gen upper = ( (0.5 * invchi2(2*(case+1), (1-(0.05/2)))) / pop_bb ) * (10^5)

	* Display the results
	label var ir "IR"
	label var se "SE"
	label var lower "95% lo"
	label var upper "95% hi"
	foreach var in ir se lower upper {
			format `var' %8.2f
			}
	sort case 
	list siteiarc case pop_bb ir se lower upper , noobs table sum(case pop_bb)
** FOR ALL TUMOURS

** JC update: Save these results as a dataset to use for DQI
** In-situ already removed because they are all female
rename ir crudem_siteiarc
rename se crudesem_siteiarc
**gen crudese_allsites=crude_siteiarc+""+"("+crudese_siteiarc+")"
drop pop_bb lower upper
save "data\dqi\2014_cancer_dqi_crude_siteiarc_male.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - All IARC Sites: Crude Rate - MEN"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore


** Next, for all women
preserve
	collapse (sum) case , by(siteiarc sex)
	drop if sex==2 //42; 41 obs deleted
	/*
	collapse (sum) case , by(pfu site sex)
	
	** Weighting for incidence calculation IF period is NOT exactly one year
	rename pop_bb fpop_bb
	gen pop_bb = fpop_bb * pfu
	*/
	gen pop_bb=144803
	** JC: replaced above total using '3_section2.do' WHO pop_bb women total
	** 2008 total=133011
	** 2013 total=144803
	** JC: male & female totals seem to be switched for 2008?
	label var pop_bb "Barbados population"
	gen ir = (case / pop_bb) * (10^5)
	label var ir "Incidence Rate by site"

	* Standard Error
	gen se = ( (case^(1/2)) / pop_bb) * (10^5)

	* Lower 95% CI
	gen lower = ( (0.5 * invchi2(2*case, (0.05/2))) / pop_bb ) * (10^5)
	replace lower = 0 if ir==0
	* Upper 95% CI
	gen upper = ( (0.5 * invchi2(2*(case+1), (1-(0.05/2)))) / pop_bb ) * (10^5)

	* Display the results
	label var ir "IR"
	label var se "SE"
	label var lower "95% lo"
	label var upper "95% hi"
	foreach var in ir se lower upper {
			format `var' %8.2f
			}
	sort case 
	list siteiarc case pop_bb ir se lower upper , noobs table sum(case pop_bb)
** FOR ALL TUMOURS	
restore

** JC added below code for 2014 to match how IARC CI5-XI
** reports (see below link) - they exclude non-invasive tumours
** Next, for all women
preserve
	drop if siteiarc==64 //24 obs deleted
	collapse (sum) case , by(siteiarc sex)
	drop if sex==2 //42; 41 obs deleted
	/*
	collapse (sum) case , by(pfu site sex)
	
	** Weighting for incidence calculation IF period is NOT exactly one year
	rename pop_bb fpop_bb
	gen pop_bb = fpop_bb * pfu
	*/
	gen pop_bb=144803
	** JC: replaced above total using '3_section2.do' WHO pop_bb women total
	** 2008 total=133011
	** 2013 total=144803
	** JC: male & female totals seem to be switched for 2008?
	label var pop_bb "Barbados population"
	gen ir = (case / pop_bb) * (10^5)
	label var ir "Incidence Rate by site"

	* Standard Error
	gen se = ( (case^(1/2)) / pop_bb) * (10^5)

	* Lower 95% CI
	gen lower = ( (0.5 * invchi2(2*case, (0.05/2))) / pop_bb ) * (10^5)
	replace lower = 0 if ir==0
	* Upper 95% CI
	gen upper = ( (0.5 * invchi2(2*(case+1), (1-(0.05/2)))) / pop_bb ) * (10^5)

	* Display the results
	label var ir "IR"
	label var se "SE"
	label var lower "95% lo"
	label var upper "95% hi"
	foreach var in ir se lower upper {
			format `var' %8.2f
			}
	sort case 
	list siteiarc case pop_bb ir se lower upper , noobs table sum(case pop_bb)
** FOR ALL TUMOURS

** JC update: Save these results as a dataset to use for DQI
rename ir crudef_siteiarc
rename se crudesef_siteiarc
**gen crudese_allsites=crude_siteiarc+""+"("+crudese_siteiarc+")"
drop pop_bb lower upper
save "data\dqi\2014_cancer_dqi_crude_siteiarc_female.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - All IARC Sites: Crude Rate - WOMEN"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report
	
restore


********************************************************************************
** Next, we want ASIR (age-standardised IR) by site - using WHO World popn
gen pfu=1 // for % year if not whole year collected; not done for cancer
********************************************************************************

********************************************************************
* (2.4c) IR age-standardised to WHO world popn - ALL TUMOURS
********************************************************************
** Using WHO World Standard Population
tab siteiarc ,m
tab siteiarc if siteiarc!=64

drop _merge
merge m:m sex age_10 using "L:\BNR_data\DM\data_analysis\2014\cancer\versions\version01\data\population\bb2010_10-2.dta"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                               927  (_merge==3)
    -----------------------------------------
*/
tab pop age_10  if sex==1 //female

tab pop age_10  if sex==2 //male

** JC: FYI-for below it's good to print out tab pop age_10 if sex==1 and tab pop age_10 if sex==2 tables to reference pop_bb

**JC - ONLY DO TOP10 SITES FOR ASR BY SITE AND TOP5 BY SEX

** ALL SITES
tab pop_bb age_10

preserve
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

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR63,replace) format(%8.2f)
** THIS IS FOR ALL SITES - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  903   277814   325.04    228.51   213.42   244.44     7.84 |
  +-------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR63.dta ,clear
gen siteiarc=63
gen sex=3
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_63all.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: ALL SITES"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore

** ALL SITES - female only
preserve
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

drop if sex==2 // all sites - female ONLY

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR63F,replace) format(%8.2f)
** THIS IS FOR ALL SITES (WOMEN) - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  438   144803   302.48    202.64   183.27   223.61    10.15 |
  +-------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR63F.dta ,clear
gen siteiarc=63
gen sex=1
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_63allf.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: ALL SITES - F"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore

** ALL SITES - male only
preserve
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

drop if sex==1 // all sites - male ONLY

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR63M,replace) format(%8.2f)
** THIS IS FOR ALL SITES (MEN) - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  465   133011   349.60    265.72   241.81   291.44    12.50 |
  +-------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR63M.dta ,clear
gen siteiarc=63
gen sex=2
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_63allm.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: ALL SITES - M"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore


** PROSTATE - both (to be used in dofile 9)
tab pop_bb age_10 if siteiarc==39 //male

preserve
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

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR39,replace) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  198   133011   148.86    111.54    96.42   128.48     8.03 |
  +-------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR39.dta ,clear
gen siteiarc=39
gen sex=3
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_39prostate.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: PROSTATE - BOTH"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore

** PROSTATE - male only
preserve
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

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR39M,replace) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  198   133011   148.86    111.54    96.42   128.48     8.03 |
  +-------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR39M.dta ,clear
gen siteiarc=39
gen sex=2
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_39prostatem.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: PROSTATE - M"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore


** BREAST
tab pop age_10  if siteiarc==29 & sex==1 //female
tab pop age_10  if siteiarc==29 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==29 // breast only
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14, 15-24
	** M 25-34, 35-44, 55-74, 75-84, 85+
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
distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR29,replace) format(%8.2f)
** THIS IS FOR BC (M&F) - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  159   283694   56.05     39.52    33.47    46.41     3.23 |
  +------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR29.dta ,clear
gen siteiarc=29
gen sex=3
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_29breast.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: BREAST - M&F"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore

** BREAST - female only
preserve
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==29 // breast only
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: M&F 0-14, 15-24
	** M 25-34, 35-44, 55-74, 75-84, 85+
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

drop if sex==2 // for breast cancer - female ONLY

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR29F,replace) format(%8.2f)
** THIS IS FOR BC (FEMALE ONLY) - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  155   144803   107.04     74.54    62.94    87.78     6.20 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset to use for DQI
use ASR29F.dta ,clear
gen siteiarc=29
gen sex=1
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_29breastf.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: BREAST - F"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore

** BREAST - male only
preserve
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==29 // breast only
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: M&F 0-14, 15-24
	** M 25-34, 35-44, 55-74, 75-84, 85+
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
** but may not use in ann rpt as total <10 cases (=5)

drop if sex==1 // for breast cancer - male ONLY

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR29M,replace) format(%8.2f)
** THIS IS FOR BC (MALE ONLY) - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |    4   138891    2.88      2.34     0.64     6.15     1.35 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset to use for DQI
use ASR29M.dta ,clear
gen siteiarc=29
gen sex=2
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_29breastm.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: BREAST - M"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore


** COLON 
tab pop age_10  if siteiarc==13 & sex==1 //female
tab pop age_10  if siteiarc==13 & sex==2 //male

preserve
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

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR13,replace) format(%8.2f)
** THIS IS FOR COLON CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  114   277814   41.03     27.98    22.95    33.85     2.71 |
  +------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR13.dta ,clear
gen siteiarc=13
gen sex=3
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_13colon.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: COLON - M&F"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore

** COLON - female only
preserve
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

drop if sex==2 // for colon cancer in WOMEN

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR13F,replace) format(%8.2f)
** THIS IS FOR COLON CANCER (WOMEN) - STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   65   144803   44.89     28.37    21.63    36.74     3.73 |
  +------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR13F.dta ,clear
gen siteiarc=13
gen sex=1
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_13colonf.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: COLON - F"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report
 
restore

** COLON - male only
preserve
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

drop if sex==1 // for colon cancer in MEN

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR13M,replace) format(%8.2f)
** THIS IS FOR COLON CANCER (MEN) - STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   49   133011   36.84     27.95    20.61    37.18     4.09 |
  +------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR13M.dta ,clear
gen siteiarc=13
gen sex=2
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_13colonm.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: COLON - M"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report
 
restore


** CORPUS UTERI - both (to be used in dofile 9)
tab pop_bb age_10 if siteiarc==33 //female

preserve
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

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR33,replace) format(%8.2f)
** THIS IS FOR CORPUS UTERI(BOTH) - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   39   144803   26.93     18.16    12.83    25.14     3.03 |
  +------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR33.dta ,clear
gen siteiarc=33
gen sex=3
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_33corpus.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: CORPUS UTERI - BOTH"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore

** CORPUS UTERI - female only
preserve
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

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR33F,replace) format(%8.2f)
** THIS IS FOR CORPUS UTERI(WOMEN) - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   39   144803   26.93     18.16    12.83    25.14     3.03 |
  +------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR33F.dta ,clear
gen siteiarc=33
gen sex=1
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_33corpusf.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: CORPUS UTERI - F"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore


** LUNG
tab pop age_10 if siteiarc==21 & sex==1 //female
tab pop age_10 if siteiarc==21 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==21
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24,25-34,35-44,45-54
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_bb=(26755) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_bb=(28005) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_bb=(18530) in 11
	sort age_10

	expand 2 in 1
	replace sex=2 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_bb=(18510) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_bb=(19410) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_bb=(18465) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_bb=(21080) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_bb=(19550) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=5 in 17
	replace case=0 in 17
	replace pop_bb=(21945) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=5 in 18
	replace case=0 in 18
	replace pop_bb=(19470) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR21,replace) format(%8.2f)
** THIS IS FOR LUNG CANCER (M&F)- STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   32   277814   11.52      7.38     4.98    10.63     1.39 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset to use for DQI
use ASR21.dta ,clear
gen siteiarc=21
gen sex=3
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_21lung.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: LUNG - M&F"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore

** LUNG - female only
preserve
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==21
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44,45-54
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_bb=(26755) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_bb=(28005) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_bb=(18530) in 11
	sort age_10

	expand 2 in 1
	replace sex=2 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_bb=(18510) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_bb=(19410) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_bb=(18465) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_bb=(21080) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_bb=(19550) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=5 in 17
	replace case=0 in 17
	replace pop_bb=(21945) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=5 in 18
	replace case=0 in 18
	replace pop_bb=(19470) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

drop if sex==2 // for lung cancer in WOMEN

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR21F,replace) format(%8.2f)
** THIS IS FOR LUNG CANCER (WOMEN) - STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   13   144803    8.98      5.11     2.63     9.28     1.62 |
  +------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR21F.dta ,clear
gen siteiarc=21
gen sex=1
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_21lungf.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: LUNG - F"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore

** LUNG - male only
preserve
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==21
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44,45-54
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_bb=(26755) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_bb=(28005) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_bb=(18530) in 11
	sort age_10

	expand 2 in 1
	replace sex=2 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_bb=(18510) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_bb=(19410) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_bb=(18465) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_bb=(21080) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_bb=(19550) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=5 in 17
	replace case=0 in 17
	replace pop_bb=(21945) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=5 in 18
	replace case=0 in 18
	replace pop_bb=(19470) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

drop if sex==1 // for lung cancer in MEN

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR21M,replace) format(%8.2f)
** THIS IS FOR LUNG CANCER (MEN) - STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   19   133011   14.28     10.41     6.22    16.55     2.52 |
  +------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR21M.dta ,clear
gen siteiarc=21
gen sex=2
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_21lungm.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: LUNG - M"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore


** MULTIPLE MYELOMA
tab pop age_10 if siteiarc==55 & sex==1 //female
tab pop age_10 if siteiarc==55 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==55
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34
	** F 35-44
	** M 85+
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_bb=(26755) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_bb=(28005) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bb=(18530) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_bb=(18510) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bb=(19410) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_bb=(18465) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_bb=(21080) in 17
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

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR55,replace) format(%8.2f)
** THIS IS FOR MULTIPLE MYELOMA CANCER (M&F)- STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   28   277814   10.08      6.94     4.58    10.19     1.37 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset to use for DQI
use ASR55.dta ,clear
gen siteiarc=55
gen sex=3
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_55MM.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: MULTIPLE MYELOMA - M&F"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore

** MULTIPLE MYELOMA - female only
preserve
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==55
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34
	** F 35-44
	** M 85+
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_bb=(26755) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_bb=(28005) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bb=(18530) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_bb=(18510) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bb=(19410) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_bb=(18465) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_bb=(21080) in 17
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

drop if sex==2 // for MM in WOMEN

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR55F,replace) format(%8.2f)
** THIS IS FOR MULTIPLE MYELOMA CANCER (WOMEN)- STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   13   144803    8.98      5.75     3.00    10.24     1.76 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset to use for DQI
use ASR55F.dta ,clear
gen siteiarc=55
gen sex=1
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_55MMf.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: MULTIPLE MYELOMA - F"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore

** MULTIPLE MYELOMA - male only
preserve
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==55
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34
	** F 35-44
	** M 85+
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_bb=(26755) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_bb=(28005) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bb=(18530) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_bb=(18510) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bb=(19410) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_bb=(18465) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_bb=(21080) in 17
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

drop if sex==1 // for MM in MEN

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR55M,replace) format(%8.2f)
** THIS IS FOR MULTIPLE MYELOMA CANCER (MEN)- STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   15   133011   11.28      8.46     4.72    14.18     2.30 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset to use for DQI
use ASR55M.dta ,clear
gen siteiarc=55
gen sex=2
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_55MMm.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: MULTIPLE MYELOMA - M"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore

** RECTUM 
tab pop age_10  if siteiarc==14 & sex==1 //female
tab pop age_10  if siteiarc==14 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==14
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34
	** M 35-44,85+
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_bb=(26755) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_bb=(28005) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bb=(18530) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_bb=(18510) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bb=(19410) in 15
	sort age_10

	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_bb=(18465) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_bb=(19550) in 17
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

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR14,replace) format(%8.2f)
** THIS IS FOR RECTAL CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   28   277814   10.08      6.94     4.56    10.20     1.38 |
  +------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR14.dta ,clear
gen siteiarc=14
gen sex=3
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_14rectum.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: RECTUM - M&F"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore

** RECTUM - female only
preserve
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==14
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34
	** M 35-44,85+
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_bb=(26755) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_bb=(28005) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bb=(18530) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_bb=(18510) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bb=(19410) in 15
	sort age_10

	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_bb=(18465) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_bb=(19550) in 17
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

drop if sex==2 // for rectal cancer in WOMEN

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR14F,replace) format(%8.2f)
** THIS IS FOR RECTAL CANCER (WOMEN)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   15   144803   10.36      6.35     3.42    11.01     1.85 |
  +------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR14F.dta ,clear
gen siteiarc=14
gen sex=1
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_14rectumf.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: RECTUM - F"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore

** RECTUM - male only
preserve
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==14
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34
	** M 35-44,85+
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_bb=(26755) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_bb=(28005) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bb=(18530) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_bb=(18510) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bb=(19410) in 15
	sort age_10

	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_bb=(18465) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_bb=(19550) in 17
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

drop if sex==1 // for rectal cancer in MEN

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR14M,replace) format(%8.2f)
** THIS IS FOR RECTAL CANCER (MEN)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   13   133011    9.77      7.65     4.07    13.25     2.24 |
  +------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR14M.dta ,clear
gen siteiarc=14
gen sex=2
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_14rectumm.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: RECTUM - M"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore

** BLADDER 
tab pop age_10  if siteiarc==45 & sex==1 //female
tab pop age_10  if siteiarc==45 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==45
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	** F 45-54
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_bb=(26755) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_bb=(28005) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_bb=(18530) in 12
	sort age_10

	expand 2 in 1
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bb=(18510) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_bb=(19410) in 14
	sort age_10

	expand 2 in 1
	replace sex=2 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bb=(18465) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_bb=(21080) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_bb=(19550) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=5 in 18
	replace case=0 in 18
	replace pop_bb=(21945) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR45,replace) format(%8.2f)
** THIS IS FOR BLADDER CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   24   277814    8.64      5.48     3.45     8.38     1.20 |
  +------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR45.dta ,clear
gen siteiarc=45
gen sex=3
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_45bladder.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: BLADDER - M&F"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore

** BLADDER - female only
preserve
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==45
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	** F 45-54
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_bb=(26755) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_bb=(28005) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_bb=(18530) in 12
	sort age_10

	expand 2 in 1
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bb=(18510) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_bb=(19410) in 14
	sort age_10

	expand 2 in 1
	replace sex=2 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bb=(18465) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_bb=(21080) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_bb=(19550) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=5 in 18
	replace case=0 in 18
	replace pop_bb=(21945) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

drop if sex==2 // for bladder cancer in WOMEN

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR45F,replace) format(%8.2f)
** THIS IS FOR BLADDER CANCER (WOMEN)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |    9   144803    6.22      3.25     1.39     6.86     1.33 |
  +------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR45F.dta ,clear
gen siteiarc=45
gen sex=1
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_45bladderf.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: BLADDER - F"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore

** BLADDER - male only
preserve
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==45
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	** F 45-54
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_bb=(26755) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_bb=(28005) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_bb=(18530) in 12
	sort age_10

	expand 2 in 1
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bb=(18510) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_bb=(19410) in 14
	sort age_10

	expand 2 in 1
	replace sex=2 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bb=(18465) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_bb=(21080) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_bb=(19550) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=5 in 18
	replace case=0 in 18
	replace pop_bb=(21945) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

drop if sex==1 // for bladder cancer in MEN

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR45M,replace) format(%8.2f)
** THIS IS FOR BLADDER CANCER (MEN)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   15   133011   11.28      8.30     4.61    13.95     2.27 |
  +------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR45M.dta ,clear
gen siteiarc=45
gen sex=2
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_45bladderm.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: BLADDER - M"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore

** STOMACH 
tab pop age_10  if siteiarc==11 & sex==1 //female
tab pop age_10  if siteiarc==11 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==11
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34
	** F 35-44,45-54,65-74
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_bb=(26755) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_bb=(28005) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_bb=(18530) in 12
	sort age_10

	expand 2 in 1
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bb=(18510) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_bb=(19410) in 14
	sort age_10

	expand 2 in 1
	replace sex=2 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bb=(18465) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_bb=(21080) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=5 in 17
	replace case=0 in 17
	replace pop_bb=(21945) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=7 in 18
	replace case=0 in 18
	replace pop_bb=(10515) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR11,replace) format(%8.2f)
** THIS IS FOR STOMACH CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   21   277814    7.56      4.50     2.72     7.14     1.07 |
  +------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR11.dta ,clear
gen siteiarc=11
gen sex=3
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_11stomach.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: STOMACH - M&F"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore

** STOMACH - female only
preserve
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==11
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34
	** F 35-44,45-54,65-74
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_bb=(26755) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_bb=(28005) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_bb=(18530) in 12
	sort age_10

	expand 2 in 1
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bb=(18510) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_bb=(19410) in 14
	sort age_10

	expand 2 in 1
	replace sex=2 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bb=(18465) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_bb=(21080) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=5 in 17
	replace case=0 in 17
	replace pop_bb=(21945) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=7 in 18
	replace case=0 in 18
	replace pop_bb=(10515) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

drop if sex==2 // for stomach cancer in WOMEN

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR11F,replace) format(%8.2f)
** THIS IS FOR STOMACH CANCER (WOMEN)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |    8   144803    5.52      2.75     1.12     6.12     1.21 |
  +------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR11F.dta ,clear
gen siteiarc=11
gen sex=1
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_11stomachf.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: STOMACH - F"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore

** STOMACH - male only
preserve
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==11
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34
	** F 35-44,45-54,65-74
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_bb=(26755) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_bb=(28005) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_bb=(18530) in 12
	sort age_10

	expand 2 in 1
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bb=(18510) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_bb=(19410) in 14
	sort age_10

	expand 2 in 1
	replace sex=2 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bb=(18465) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_bb=(21080) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=5 in 17
	replace case=0 in 17
	replace pop_bb=(21945) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=7 in 18
	replace case=0 in 18
	replace pop_bb=(10515) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

drop if sex==1 // for stomach cancer in MEN

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR11M,replace) format(%8.2f)
** THIS IS FOR STOMACH CANCER (MEN)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   13   133011    9.77      6.89     3.62    12.11     2.06 |
  +------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR11M.dta ,clear
gen siteiarc=11
gen sex=2
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_11stomachm.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: STOMACH - M"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore

** PANCREAS 
tab pop age_10  if siteiarc==18 & sex==1 //female
tab pop age_10  if siteiarc==18 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==18
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	** F 55-64,85+
	** M 45-54
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_bb=(26755) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_bb=(28005) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=2 in 10
	replace case=0 in 10
	replace pop_bb=(18530) in 10
	sort age_10

	expand 2 in 1
	replace sex=2 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_bb=(18510) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=3 in 12
	replace case=0 in 12
	replace pop_bb=(19410) in 12
	sort age_10

	expand 2 in 1
	replace sex=2 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_bb=(18465) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=4 in 14
	replace case=0 in 14
	replace pop_bb=(21080) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_bb=(19550) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=5 in 16
	replace case=0 in 16
	replace pop_bb=(19470) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=6 in 17
	replace case=0 in 17
	replace pop_bb=(15940) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_bb=(3388) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR18,replace) format(%8.2f)
** THIS IS FOR PANCREATIC CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   21   258264    8.13      4.88     2.99     7.72     1.15 |
  +------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR18.dta ,clear
gen siteiarc=18
gen sex=3
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_18pancreas.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: PANCREAS - M&F"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore

** PANCREAS - female only
preserve
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==18
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	** F 55-64,85+
	** M 45-54
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_bb=(26755) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_bb=(28005) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=2 in 10
	replace case=0 in 10
	replace pop_bb=(18530) in 10
	sort age_10

	expand 2 in 1
	replace sex=2 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_bb=(18510) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=3 in 12
	replace case=0 in 12
	replace pop_bb=(19410) in 12
	sort age_10

	expand 2 in 1
	replace sex=2 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_bb=(18465) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=4 in 14
	replace case=0 in 14
	replace pop_bb=(21080) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_bb=(19550) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=5 in 16
	replace case=0 in 16
	replace pop_bb=(19470) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=6 in 17
	replace case=0 in 17
	replace pop_bb=(15940) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_bb=(3388) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

drop if sex==2 // for pancreatic cancer in WOMEN

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR18F,replace) format(%8.2f)
** THIS IS FOR PANCREATIC CANCER (WOMEN)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |    7   144803    4.83      3.19     1.26     6.93     1.38 |
  +------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR18F.dta ,clear
gen siteiarc=18
gen sex=1
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_18pancreasf.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: PANCREAS - F"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore

** PANCREAS - male only
preserve
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==18
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	** F 55-64,85+
	** M 45-54
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_bb=(26755) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_bb=(28005) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=2 in 10
	replace case=0 in 10
	replace pop_bb=(18530) in 10
	sort age_10

	expand 2 in 1
	replace sex=2 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_bb=(18510) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=3 in 12
	replace case=0 in 12
	replace pop_bb=(19410) in 12
	sort age_10

	expand 2 in 1
	replace sex=2 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_bb=(18465) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=4 in 14
	replace case=0 in 14
	replace pop_bb=(21080) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_bb=(19550) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=5 in 16
	replace case=0 in 16
	replace pop_bb=(19470) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=6 in 17
	replace case=0 in 17
	replace pop_bb=(15940) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_bb=(3388) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

drop if sex==1 // for pancreatic cancer in MEN

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR18M,replace) format(%8.2f)
** THIS IS FOR PANCREATIC CANCER (MEN)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   14   133011   10.53      7.43     4.03    12.76     2.12 |
  +------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR18M.dta ,clear
gen siteiarc=18
gen sex=2
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_18pancreasm.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: PANCREAS - M"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore


** CERVIX UTERI - both (to be used in dofile 9)
tab pop_bb age_10 if siteiarc==32 //female

preserve
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

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR32,replace) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   17   144803   11.74      9.56     5.40    15.67     2.52 |
  +------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR32.dta ,clear
gen siteiarc=32
gen sex=3
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_32cervix.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: CERVIX UTERI - BOTH"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore


** CERVIX UTERI - female only
tab pop_bb age_10 if siteiarc==32 //female

preserve
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

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR32F,replace) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   17   144803   11.74      9.56     5.40    15.67     2.52 |
  +------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR32F.dta ,clear
gen siteiarc=32
gen sex=1
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_32cervixf.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: CERVIX UTERI - F"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore

** JC 18dec2018: unsure why AR wanted crude rate at this point but kept in for 2014
preserve
	* crude rate: point estimate for CERVICAL CA IN WOMEN
	gen cancerpop = 1
	label define crude 1 "cancer events" ,modify
	label values cancerpop crude
	keep if siteiarc==32 & sex==1
	collapse (sum) case (mean) pop_bb , by(pfu cancerpop age_10 sex)
	collapse (sum) case pop_bb , by(pfu cancerpop)
	
	** Weighting for incidence calculation IF period is NOT exactly one year
	** (where it is 1 year, pfu=1)
	drop pop_bb 
	gen pop_bb = 144803
	
	gen ir = (case / pop_bb) * (10^5)
	label var ir "Crude Incidence Rate"

	* Standard Error
	gen se = ( (case^(1/2)) / pop_bb) * (10^5)

	* Lower 95% CI
	gen lower = ( (0.5 * invchi2(2*case, (0.05/2))) / pop_bb ) * (10^5)
	* Upper 95% CI
	gen upper = ( (0.5 * invchi2(2*(case+1), (1-(0.05/2)))) / pop_bb ) * (10^5)

	* Display the results
	label var pop_bb "P-Y"
	label var case "Cases"
	label var ir "IR"
	label var se "SE"
	label var lower "95% lo"
	label var upper "95% hi"
	foreach var in ir se lower upper {
			format `var' %8.2f
			}
	list case pop_bb ir se lower upper , noobs table
** THIS IS FOR CERVICAL CA IN WOMEN - CRUDE ONLY with 95%CI

/*
  +----------------------------------------------+
  | case   pop_bb      ir     se   lower   upper |
  |----------------------------------------------|
  |   17   144803   11.74   2.85    6.84   18.80 |
  +----------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
rename ir crudef_cervix
rename se crudesef_cervix
**gen crudese_allsites=crude_siteiarc+""+"("+crudese_siteiarc+")"
drop pop_bb lower upper
save "data\dqi\2014_cancer_dqi_crude_cervix_female.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - All IARC Sites: Crude Rate - CERVICAL CANCER"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report
	
restore


** O&U (other,ill-defined,unknown) 
tab pop age_10  if siteiarc==61 & sex==1 //female
tab pop age_10  if siteiarc==61 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==61
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 15-24,25-34,35-44
	** F 0-14
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_bb=(26755) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bb=(18530) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_bb=(18510) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bb=(19410) in 15
	sort age_10

	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_bb=(18465) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_bb=(21080) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=4 in 18
	replace case=0 in 18
	replace pop_bb=(19550) in 18
	sort age_10
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR61,replace) format(%8.2f)
** THIS IS FOR O&U CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   45   277814   16.20     10.40     7.44    14.22     1.67 |
  +------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR61.dta ,clear
gen siteiarc=61
gen sex=3
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_61o&u.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: O&U - M&F"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore

** O&U (other,ill-defined,unknown) - female only
preserve
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==61
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 15-24,25-34,35-44
	** F 0-14
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_bb=(26755) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bb=(18530) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_bb=(18510) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bb=(19410) in 15
	sort age_10

	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_bb=(18465) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_bb=(21080) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=4 in 18
	replace case=0 in 18
	replace pop_bb=(19550) in 18
	sort age_10
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

drop if sex==2 // for o&u cancer in WOMEN

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR61F,replace) format(%8.2f)
** THIS IS FOR O&U CANCER (WOMEN)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   22   144803   15.19      8.39     5.11    13.31     2.00 |
  +------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR61F.dta ,clear
gen siteiarc=61
gen sex=1
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_61o&uf.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: O&U - F"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore

** O&U (other,ill-defined,unknown) - male only
preserve
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==61
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 15-24,25-34,35-44
	** F 0-14
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_bb=(26755) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bb=(18530) in 13
	sort age_10

	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_bb=(18510) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bb=(19410) in 15
	sort age_10

	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_bb=(18465) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_bb=(21080) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=4 in 18
	replace case=0 in 18
	replace pop_bb=(19550) in 18
	sort age_10
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

drop if sex==1 // for o&u cancer in MEN

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR61M,replace) format(%8.2f)
** THIS IS FOR O&U CANCER (MEN)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   23   133011   17.29     12.83     8.01    19.62     2.84 |
  +------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR61M.dta ,clear
gen siteiarc=61
gen sex=2
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse siteiarc case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_61o&um.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: O&U - M"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore



** Ask NS which to use 'siteiarc'(CI5) vs 'sitecr5db'(CR5db).

/*
************************************************************
* (2.4c) IR age-standardised to WHO world popn - ALL TUMOURS
************************************************************

** Now let's estimate MR by top sites 
tab sitecr5db ,m //2 missing are 0-14 pop records

** Check for top 10 deaths by CR5db site
** include O&U; exclude in-situ
preserve
drop if sitecr5db==32 //24 obs deleted
bysort sitecr5db: gen n=_N
bysort n sitecr5db: gen tag=(_n==1)
replace tag = sum(tag)
sum tag , meanonly
gen top10 = (tag>=(`r(max)'-9))
sum n if tag==(`r(max)'-9), meanonly
replace top10 = 1 if n==`r(max)'
tab sitecr5db top10 if top10!=0
contract sitecr5db top10 if top10!=0, freq(count) percent(percentage)
gsort -count
drop top10 percentage
/*
sitecr5db							count
Prostate (C61)						198
Breast (C50)						159
Colon, rectum, anus (C18-21)		144
Lymphoma (C81-85,88,90,96)			47
O&U (C26,39,48,76,80)				45
Corpus & Uterus NOS (C54-55)		40
Lung, trachea, bronchus (C33-34)	32
Bladder (C67)						24
Mouth & pharynx (C00-14)			22
Pancreas (C25)						21
Stomach (C16)						21
*/
restore

** exclude O&U and in-situ
preserve
drop if sitecr5db==20|sitecr5db==32 //69 obs deleted
bysort sitecr5db: gen n=_N
bysort n sitecr5db: gen tag=(_n==1)
replace tag = sum(tag)
sum tag , meanonly
gen top10 = (tag>=(`r(max)'-9))
sum n if tag==(`r(max)'-9), meanonly
replace top10 = 1 if n==`r(max)'
tab sitecr5db top10 if top10!=0
contract sitecr5db top10 if top10!=0, freq(count) percent(percentage)
gsort -count
drop top10 percentage
/*
sitecr5db							count
Prostate (C61)						198
Breast (C50)						159
Colon, rectum, anus (C18-21)		144
Lymphoma (C81-85,88,90,96)			47
Corpus & Uterus NOS (C54-55)		40
Lung, trachea, bronchus (C33-34)	32
Bladder (C67)						24
Mouth & pharynx (C00-14)			22
Stomach (C16)						21
Pancreas (C25)						21
*/
restore


tab pop age_10 if sex==1 ,m
tab pop age_10 if sex==2 ,m

** Using WHO World Standard Population

** PROSTATE - both (to be used in dofile 9)
tab pop_bb age_10 if sitecr5db==14 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if sitecr5db==14 // prostate only
	
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

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR14P,replace) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  198   133011   148.86    111.54    96.42   128.48     8.03 |
  +-------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR14P.dta ,clear
gen sitecr5db=14
gen sex=3
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse sitecr5db case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_14prostate.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: PROSTATE - BOTH"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore

** PROSTATE - male only
preserve
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if sitecr5db==14 // prostate only
	
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

distrate case pop_bb using "data\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR14PM,replace) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  198   133011   148.86    111.54    96.42   128.48     8.03 |
  +-------------------------------------------------------------+
*/

** JC update: Save these results as a dataset to use for DQI
use ASR14PM.dta ,clear
gen sitecr5db=14
gen sex=2
rename rateadj asr
rename se_gam asr_se
rename N pop_bb
collapse sitecr5db case pop_bb crude asr asr_se sex
save "data\dqi\2014_cancer_dqi_asr_14prostatem.dta" ,replace
label data "BNR-Cancer 2014 Data Quality Index - Age-Std Incidence Rate: PROSTATE - M"
notes _dta :These data prepared for Natasha Sobers - 2014 annual report

restore


********************************************************************************
** ASR for all sites as grouped in CR5db - to be used in dofile 9 (DQIs)
********************************************************************************

** JC 19dec2018: Not sure if there's any point to this as CR5db can produce these stats
** Ask NS re using CR5db analysis tables instead of Stata analysis dofiles.
