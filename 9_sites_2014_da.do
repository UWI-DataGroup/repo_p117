** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					9_sites_2014_da.do
    //  project:								BNR
    //  analysts:								Jacqueline CAMPBELL
    //  date first created      27-MAR-2019
    // 	date last modified	    27-MAR-2019
    //  algorithm task					Generate Incidence Rates by (IARC) site: (1) identification of top sites (2) crude: by sex (3) crude: by site (4) ASR(ASIR): all sites, world & US(2000) pop (5) ASR(ASIR): all sites, by sex (world & US)
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
use "`datapath'\version01\2-working\2014_cancer_numbers_da", replace

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

** All sites excl. O&U, non-reportable skin cancers - using IARC CI5's site groupings COMBINE cervix & CIN 3
** THIS USED IN ANNUAL REPORT TABLE 1 - CHECKING WHERE IN LIST 2014 TOP 10 APPEARS IN LIST FOR 2008
** This list requested by NS in similar format to CMO's report for top 10 comparisons with current & previous years
** Screenshot this data from Stata data editor into annual report tables document.
preserve
drop if (siteiarc==25|siteiarc>60) & siteiarc!=64 //45 deleted
replace siteiarc=32 if siteiarc==32|siteiarc==64 //24 changes
tab siteiarc ,m
contract siteiarc, freq(count) percent(percentage)
gsort -count
/*
siteiarc	count	percentage
Prostate (C61)	198	22.45
Breast (C50)	159	18.03
Colon (C18)	114	12.93
Cervix uteri (C53)	41	4.65
Corpus uteri (C54)	39	4.42
Lung (incl. trachea and bronchus) (C33-34)	32	3.63
Rectum (C19-20)	28	3.17
Multiple myeloma (C90)	28	3.17
Bladder (C67)	24	2.72
Stomach (C16)	21	2.38
Pancreas (C25)	21	2.38
Non-Hodgkin lymphoma (C82-86,C96)	16	1.81
Liver (C22)	13	1.47
Thyroid (C73)	11	1.25
Kidney (C64)	11	1.25
Oesophagus (C15)	9	1.02
Larynx (C32)	9	1.02
Gallbladder etc. (C23-24)	9	1.02
Ovary (C56)	8	0.91
Melanoma of skin (C43)	7	0.79
Connective and soft tissue (C47+C49)	7	0.79
Lymphoid leukaemia (C91)	7	0.79
Brain, nervous system (C70-72)	6	0.68
Tonsil (C09)	5	0.57
Small intestine (C17)	5	0.57
Nose, sinuses etc. (C30-31)	5	0.57
Myeloid leukaemia (C92-94)	5	0.57
Tongue (C01-02)	4	0.45
Hypopharynx (C12-13)	4	0.45
Myeloproliferative disorders (MPD)	3	0.34
Nasopharynx (C11)	3	0.34
Leukaemia unspecified (C95)	3	0.34
Penis (C60)	3	0.34
Other oropharynx (C10)	3	0.34
Anus (C21)	2	0.23
Testis (C62)	2	0.23
Mouth (C03-06)	2	0.23
Vagina (C52)	2	0.23
Vulva (C51)	2	0.23
Hodgkin lymphoma (C81)	2	0.23
Bone (C40-41)	2	0.23
Mesothelioma (C45)	2	0.23
Myelodysplastic syndromes (MDS)	1	0.11
Salivary gland (C07-08)	1	0.11
Other endocrine (C75)	1	0.11
Uterus unspecified (C55)	1	0.11
Immunoproliferative diseases (C88)	1	0.11
*/
total count //882
restore

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
siteiarc	                                	count		percentage
Prostate (C61)	                            198	    29.82
Breast (C50)	                            	159	    23.95
Colon (C18)	                                114	    17.17
Corpus uteri (C54)	                        39	    5.87
Lung (incl. trachea and bronchus) (C33-34)	32	    4.82
Rectum (C19-20)	                            28	    4.22
Multiple myeloma (C90)	                    28	    4.22
Bladder (C67)	                            	24	    3.61
Pancreas (C25)	                            21	    3.16
Stomach (C16)	                            	21	    3.16
*/
total count //664
restore

** All sites excl. O&U, non-reportable skin cancers - using IARC CI5's site groupings
preserve
drop if siteiarc==25|siteiarc==61 //45 obs deleted
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
siteiarc																		count	percentage
Prostate (C61)															198		28.78
Breast (C50)																159		23.11
Colon (C18)																	114		16.57
Corpus uteri (C54)													39		5.67
Lung (incl. trachea and bronchus) (C33-34)	32		4.65
Multiple myeloma (C90)											28		4.07
Rectum (C19-20)															28		4.07
D069: CIN 3																	24		3.49
Bladder (C67)																24		3.49
Pancreas (C25)															21		3.05
Stomach (C16)																21		3.05
*/
total count //688
restore

** proportions for Table 1 using IARC's site groupings
tab siteiarc sex ,m
tab siteiarc , m
tab siteiarc if sex==2 ,m // female
tab siteiarc if sex==1 ,m // male							  
** sites by behaviour
tab siteiarc beh ,m
tab beh ,m

** For annual report - Section 1: Incidence - Table 1
** FEMALE - using IARC's site groupings (excl. in-situ) COMBINE cervix & CIN 3
** THIS USED IN ANNUAL REPORT TABLE 1
preserve
drop if sex==1 //465 obs deleted
drop if siteiarc==25|siteiarc==61 //22 obs deleted
replace siteiarc=32 if siteiarc==32|siteiarc==64 //24 changes
tab siteiarc ,m
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
siteiarc						count	percentage	totpercent	alltotpercent
Breast (C50)				155		49.21				33.54978		16.7206
Colon (C18)					65		20.63				14.06926		7.011866
Cervix uteri (C53)	41		13.02				8.874459		4.42287
Corpus uteri (C54)	39		12.38				8.441559		4.20712
Rectum (C19-20)			15		4.76				3.246753		1.618123
*/
total count //315
restore

** For annual report - Section 1: Incidence - Table 1
** FEMALE - using IARC's site groupings (excl. in-situ)
preserve
drop if sex==1 //465 obs deleted
drop if siteiarc==61|siteiarc==64 //46 obs deleted
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
siteiarc	        	count	percentage	totpercent	alltotpercent
Breast (C50)	    	155	  53.26	    	33.54978		16.7206
Colon (C18)	        65	  22.34	    	14.06926		7.011866
Corpus uteri (C54)	39	  13.40	    	8.441559		4.20712
Cervix uteri (C53)	17	  5.84	    	3.679654		1.833873
Rectum (C19-20)	    15	  5.15	    	3.246753		1.618123

*/
total count //291
restore

** FEMALE - using IARC's site groupings (incl. in-situ)
preserve
drop if sex==1 //465 obs deleted
drop if siteiarc==61 //22 obs deleted
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
siteiarc						count	percentage	totpercent	alltotpercent
Breast (C50)				155		51.67				33.54978		16.7206
Colon (C18)					65		21.67				14.06926		7.011866
Corpus uteri (C54)	39		13.00				8.441559		4.20712
D069: CIN 3					24		8.00				5.194805		2.588997
Cervix uteri (C53)	17		5.67				3.679654		1.833873
*/
total count //300
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
siteiarc	                                	count	percentage	totpercent	alltotpercent
Prostate (C61)	                            198	  66.89	    	42.58065		21.35922
Colon (C18)	                                49	  16.55	    	10.53763		5.285868
Lung (incl. trachea and bronchus) (C33-34)	19	  6.42	    	4.086021		2.049623
Multiple myeloma (C90)	                    15	  5.07	    	3.225806		1.618123
Bladder (C67)	                            	15	  5.07	    	3.225806		1.618123
*/
total count //296
restore


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
merge m:m sex age_10 using "`datapath'\version01\2-working\bb2010_10-2"
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
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

** Next, IRs for invasive tumours only
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) saving(ASR63,replace) format(%8.2f)
** THIS IS FOR ALL SITES (INVASIVE TUMOURS ONLY) - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  903   277814   325.04    228.51   213.42   244.44     7.84 |
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
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

*******************************
** Next, IRs by sex and site **
*******************************

** PROSTATE
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
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
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BC (M&F) - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  159   283694   56.05     39.52    33.47    46.41     3.23 |
  +------------------------------------------------------------+
*/
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BC (FEMALE ONLY) - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  155   144803   107.04     74.54    62.94    87.78     6.20 |
  +-------------------------------------------------------------+
*/
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BC (MALE ONLY) - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |    4   138891    2.88      2.34     0.64     6.15     1.35 |
  +------------------------------------------------------------+
*/
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
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


** CORPUS UTERI
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CORPUS UTERI(BOTH) - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   39   144803   26.93     18.16    12.83    25.14     3.03 |
  +------------------------------------------------------------+
*/
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR LUNG CANCER (M&F)- STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   32   277814   11.52      7.38     4.98    10.63     1.39 |
  +------------------------------------------------------------+
*/
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR LUNG CANCER (WOMEN) - STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   13   144803    8.98      5.11     2.63     9.28     1.62 |
  +------------------------------------------------------------+
*/
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR LUNG CANCER (MEN) - STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   19   133011   14.28     10.41     6.22    16.55     2.52 |
  +------------------------------------------------------------+
*/
restore


** CERVIX UTERI - excl. CIN 3
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CERVICAL CANCER - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   17   144803   11.74      9.56     5.40    15.67     2.52 |
  +------------------------------------------------------------+
*/
restore


** CERVIX UTERI - incl. CIN 3 (THIS USED IN ANN RPT TABLE 2b)
tab pop_bb age_10 if siteiarc==32|siteiarc==64 //female

preserve
	drop if age_10==.
	drop if beh!=3 & siteiarc!=64 //0 obs deleted
	keep if siteiarc==32|siteiarc==64 // cervix uteri with CIN 3
	
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CERVICAL CANCER WITH CIN 3 - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   41   144803   28.31     25.37    17.98    34.72     4.15 |
  +------------------------------------------------------------+
*/
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RECTAL CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   28   277814   10.08      6.94     4.56    10.20     1.38 |
  +------------------------------------------------------------+
*/
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RECTAL CANCER (WOMEN)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   15   144803   10.36      6.35     3.42    11.01     1.85 |
  +------------------------------------------------------------+
*/
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RECTAL CANCER (MEN)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   13   133011    9.77      7.65     4.07    13.25     2.24 |
  +------------------------------------------------------------+
*/
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR MULTIPLE MYELOMA CANCER (M&F)- STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   28   277814   10.08      6.94     4.58    10.19     1.37 |
  +------------------------------------------------------------+
*/
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR MULTIPLE MYELOMA CANCER (WOMEN)- STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   13   144803    8.98      5.75     3.00    10.24     1.76 |
  +------------------------------------------------------------+
*/
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR MULTIPLE MYELOMA CANCER (MEN)- STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   15   133011   11.28      8.46     4.72    14.18     2.30 |
  +------------------------------------------------------------+
*/
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BLADDER CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   24   277814    8.64      5.48     3.45     8.38     1.20 |
  +------------------------------------------------------------+
*/
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BLADDER CANCER (WOMEN)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |    9   144803    6.22      3.25     1.39     6.86     1.33 |
  +------------------------------------------------------------+
*/
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BLADDER CANCER (MEN)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   15   133011   11.28      8.30     4.61    13.95     2.27 |
  +------------------------------------------------------------+
*/
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PANCREATIC CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   21   277814    7.56      4.88     2.99     7.65     1.14 |
  +------------------------------------------------------------+
*/
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PANCREATIC CANCER (WOMEN)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |    7   144803    4.83      3.19     1.26     6.93     1.38 |
  +------------------------------------------------------------+
*/
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PANCREATIC CANCER (MEN)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   14   133011   10.53      7.43     4.03    12.76     2.12 |
  +------------------------------------------------------------+
*/
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR STOMACH CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   21   277814    7.56      4.50     2.72     7.14     1.07 |
  +------------------------------------------------------------+
*/
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR STOMACH CANCER (WOMEN)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |    8   144803    5.52      2.75     1.12     6.12     1.21 |
  +------------------------------------------------------------+
*/
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR STOMACH CANCER (MEN)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   13   133011    9.77      6.89     3.62    12.11     2.06 |
  +------------------------------------------------------------+
*/
restore

** NON-HODGKIN LYMPHOMA 
tab pop age_10  if siteiarc==53 & sex==1 //female
tab pop age_10  if siteiarc==53 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==53
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,25-34
	** F 	 15-24,45-54,55-64,65-74
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
	replace age_10=5 in 16
	replace case=0 in 16
	replace pop_bb=(21945) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=6 in 17
	replace case=0 in 17
	replace pop_bb=(15940) in 17
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR NHL (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   16   277814    5.76      4.11     2.28     6.88     1.12 |
  +------------------------------------------------------------+
*/
restore

** KIDNEY 
tab pop age_10  if siteiarc==42 & sex==1 //female
tab pop age_10  if siteiarc==42 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==42
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	** F 	 45-54
	** M	 75-84,85+
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
	replace pop_bb=(18510)  in 11
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
	replace sex=1 in 16
	replace age_10=5 in 16
	replace case=0 in 16
	replace pop_bb=(21945) in 16
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR KIDNEY CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   11   277814    3.96      2.80     1.38     5.16     0.92 |
  +------------------------------------------------------------+
*/
restore


**********************************************
** Info for first table (summary state E1): **
**********************************************
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

** number of colorectal (ICD-10 C18-C21)
count if siteiarc>12 & siteiarc<16 //144


** Save this new dataset without population data
label data "2014 BNR-Cancer analysed data - Sites"
note: TS This dataset does NOT include population data 
save "`datapath'\version01\2-working\2014_cancer_sites_da", replace
