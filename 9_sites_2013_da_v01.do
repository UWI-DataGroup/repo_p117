** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          9_sites_2013_da_v01.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      17-APR-2019
    // 	date last modified      18-APR-2019
    //  algorithm task          Generate Incidence Rates by (IARC) site: (1) identification of top sites (2) crude: by sex (3) crude: by site (4) ASR(ASIR): all sites, world & US(2000) pop (5) ASR(ASIR): all sites, by sex (world & US)
    //  status                  Completed
    //  objectve                To have one dataset with cleaned, grouped and analysed 2013 data for 2014 cancer report.


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
    log using "`logpath'\9_sites_2013_da_v01.smcl", replace
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
use "`datapath'\version01\2-working\2013_cancer_numbers_da_v01", replace

***********************
** 3.1 CANCERS BY SITE
***********************
tab icd10 if beh<3 ,m //24 in-situ

tab icd10 ,m //0 missing

tab siteiarc ,m //0 missing


** Below top 10 code added by JC for 2014 DQIs and instead of visually 
** determining top ten as done for 2008 & 2013
** Note NMSCs (non-reportable skin cancers) and in-situ tumours excluded from top ten analysis
tab siteiarc if siteiarc!=25 & siteiarc<62
tab siteiarc ,m //
/*

*/
tab siteiarc patient

** NS decided on 18march2019 to use IARC site groupings so variable siteiarc will be used instead of sitear
** IARC site variable created based on CI5-XI incidence classifications (see chapter 3 Table 3.1. of that volume) based on icd10
display `"{browse "http://ci5.iarc.fr/CI5-XI/Pages/Chapter3.aspx":IARC-CI5-XI-3}"'

** For annual report - Section 1: Incidence - Table 2a (NOT USING IN TABLE AS USING 2014 TOP 10)
** Below top 10 code added by JC for 2014
** All sites excl. O&U, non-reportable skin cancers - using IARC CI5's site groupings COMBINE cervix & CIN 3
** THIS USED IN ANNUAL REPORT TABLE 1
preserve
drop if (siteiarc==25|siteiarc>60) & siteiarc!=64 //34 deleted
tab siteiarc ,m
replace siteiarc=32 if siteiarc==32|siteiarc==64 //9 changes
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
siteiarc																		count	percentage
Prostate (C61)															171		27.19
Breast (C50)																137		21.78
Colon (C18)																	107		17.01
Rectum (C19-20)															44		7.00
Cervix uteri (C53)													44		7.00
Corpus uteri (C54)													31		4.93
Lung (incl. trachea and bronchus) (C33-34)	27		4.29
Non-Hodgkin lymphoma (C82-86,C96)						23		3.66
Kidney (C64)																23		3.66
Pancreas (C25)															22		3.50
*/
total count //629
restore

** All sites excl. O&U, non-reportable skin cancers - using IARC CI5's site groupings COMBINE cervix & CIN 3
** THIS USED IN ANNUAL REPORT TABLE 1 - CHECKING WHERE IN LIST 2014 TOP 10 APPEARS IN LIST FOR 2008
** This list requested by NS in similar format to CMO's report for top 10 comparisons with current & previous years
** Screenshot this data from Stata data editor into annual report tables document.
preserve
drop if (siteiarc==25|siteiarc>60) & siteiarc!=64 //
replace siteiarc=32 if siteiarc==32|siteiarc==64 // changes
tab siteiarc ,m
contract siteiarc, freq(count) percent(percentage)
gsort -count
/*
siteiarc	count	percentage
Prostate (C61)	171	21.09
Breast (C50)	137	16.89
Colon (C18)	107	13.19
Cervix uteri (C53)	44	5.43
Rectum (C19-20)	44	5.43
Corpus uteri (C54)	31	3.82
Lung (incl. trachea and bronchus) (C33-34)	27	3.33
Non-Hodgkin lymphoma (C82-86,C96)	23	2.84
Kidney (C64)	23	2.84
Pancreas (C25)	22	2.71
Stomach (C16)	16	1.97
Thyroid (C73)	15	1.85
Multiple myeloma (C90)	13	1.60
Ovary (C56)	12	1.48
Myeloid leukaemia (C92-94)	12	1.48
Bladder (C67)	11	1.36
Gallbladder etc. (C23-24)	10	1.23
Anus (C21)	10	1.23
Liver (C22)	7	0.86
Oesophagus (C15)	6	0.74
Lymphoid leukaemia (C91)	5	0.62
Brain, nervous system (C70-72)	5	0.62
Hodgkin lymphoma (C81)	5	0.62
Mouth (C03-06)	5	0.62
Uterus unspecified (C55)	4	0.49
Larynx (C32)	4	0.49
Myeloproliferative disorders (MPD)	4	0.49
Vagina (C52)	3	0.37
Connective and soft tissue (C47+C49)	3	0.37
Melanoma of skin (C43)	3	0.37
Small intestine (C17)	3	0.37
Other oropharynx (C10)	3	0.37
Leukaemia unspecified (C95)	2	0.25
Pharynx unspecified (C14)	2	0.25
Penis (C60)	2	0.25
Tongue (C01-02)	2	0.25
Nasopharynx (C11)	2	0.25
Nose, sinuses etc. (C30-31)	2	0.25
Other female genital organs (C57)	2	0.25
Salivary gland (C07-08)	2	0.25
Hypopharynx (C12-13)	1	0.12
Other thoracic organs (C37-38)	1	0.12
Eye (C69)	1	0.12
Tonsil (C09)	1	0.12
Mesothelioma (C45)	1	0.12
Vulva (C51)	1	0.12
Bone (C40-41)	1	0.12
*/
total count //811
restore

** All sites excl. O&U, non-reportable (skin) cancers - using IARC CI5's site groupings
preserve
drop if (siteiarc==25|siteiarc>60) & siteiarc!=64 //34 deleted
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
siteiarc	count	percentage
Prostate (C61)	171	27.58
Breast (C50)	137	22.10
Colon (C18)	107	17.26
Rectum (C19-20)	44	7.10
Cervix uteri (C53)	35	5.65
Corpus uteri (C54)	31	5.00
Lung (incl. trachea and bronchus) (C33-34)	27	4.35
Kidney (C64)	23	3.71
Non-Hodgkin lymphoma (C82-86,C96)	23	3.71
Pancreas (C25)	22	3.55
*/
total count //620
restore

** proportions for Table 1 using IARC's site groupings (NOT USING IN TABLE AS USING 2014)
tab siteiarc sex ,m
tab siteiarc , m
tab siteiarc if sex==2 ,m // female
/*
                      IARC CI5-XI sites |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                Salivary gland (C07-08) |          1        0.24        0.24
                   Hypopharynx (C12-13) |          1        0.24        0.47
                       Oesophagus (C15) |          3        0.71        1.18
                          Stomach (C16) |          4        0.95        2.13
                  Small intestine (C17) |          2        0.47        2.61
                            Colon (C18) |         53       12.56       15.17
                        Rectum (C19-20) |         19        4.50       19.67
                             Anus (C21) |          5        1.18       20.85
                            Liver (C22) |          3        0.71       21.56
              Gallbladder etc. (C23-24) |          6        1.42       22.99
                         Pancreas (C25) |         10        2.37       25.36
            Nose, sinuses etc. (C30-31) |          1        0.24       25.59
Lung (incl. trachea and bronchus) (C33- |          7        1.66       27.25
                 Melanoma of skin (C43) |          1        0.24       27.49
   Connective and soft tissue (C47+C49) |          1        0.24       27.73
                           Breast (C50) |        134       31.75       59.48
                            Vulva (C51) |          1        0.24       59.72
                           Vagina (C52) |          3        0.71       60.43
                     Cervix uteri (C53) |         35        8.29       68.72
                     Corpus uteri (C54) |         31        7.35       76.07
               Uterus unspecified (C55) |          4        0.95       77.01
                            Ovary (C56) |         12        2.84       79.86
      Other female genital organs (C57) |          2        0.47       80.33
                           Kidney (C64) |          9        2.13       82.46
                          Bladder (C67) |          3        0.71       83.18
                              Eye (C69) |          1        0.24       83.41
         Brain, nervous system (C70-72) |          2        0.47       83.89
                          Thyroid (C73) |         12        2.84       86.73
                 Hodgkin lymphoma (C81) |          3        0.71       87.44
      Non-Hodgkin lymphoma (C82-86,C96) |          8        1.90       89.34
                 Multiple myeloma (C90) |          4        0.95       90.28
               Lymphoid leukaemia (C91) |          3        0.71       91.00
             Myeloid leukaemia (C92-94) |          9        2.13       93.13
            Leukaemia unspecified (C95) |          1        0.24       93.36
     Myeloproliferative disorders (MPD) |          2        0.47       93.84
            Other and unspecified (O&U) |         17        4.03       97.87
                            D069: CIN 3 |          9        2.13      100.00
----------------------------------------+-----------------------------------
                                  Total |        422      100.00
*/
tab siteiarc if sex==1 ,m // male
/*
                      IARC CI5-XI sites |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                        Tongue (C01-02) |          2        0.47        0.47
                         Mouth (C03-06) |          5        1.18        1.65
                Salivary gland (C07-08) |          1        0.24        1.89
                           Tonsil (C09) |          1        0.24        2.13
                 Other oropharynx (C10) |          3        0.71        2.84
                      Nasopharynx (C11) |          2        0.47        3.31
              Pharynx unspecified (C14) |          2        0.47        3.78
                       Oesophagus (C15) |          3        0.71        4.49
                          Stomach (C16) |         12        2.84        7.33
                  Small intestine (C17) |          1        0.24        7.57
                            Colon (C18) |         54       12.77       20.33
                        Rectum (C19-20) |         25        5.91       26.24
                             Anus (C21) |          5        1.18       27.42
                            Liver (C22) |          4        0.95       28.37
              Gallbladder etc. (C23-24) |          4        0.95       29.31
                         Pancreas (C25) |         12        2.84       32.15
            Nose, sinuses etc. (C30-31) |          1        0.24       32.39
                           Larynx (C32) |          4        0.95       33.33
Lung (incl. trachea and bronchus) (C33- |         20        4.73       38.06
         Other thoracic organs (C37-38) |          1        0.24       38.30
                          Bone (C40-41) |          1        0.24       38.53
                 Melanoma of skin (C43) |          2        0.47       39.01
                     Mesothelioma (C45) |          1        0.24       39.24
   Connective and soft tissue (C47+C49) |          2        0.47       39.72
                           Breast (C50) |          3        0.71       40.43
                            Penis (C60) |          2        0.47       40.90
                         Prostate (C61) |        171       40.43       81.32
                           Kidney (C64) |         14        3.31       84.63
                          Bladder (C67) |          8        1.89       86.52
         Brain, nervous system (C70-72) |          3        0.71       87.23
                          Thyroid (C73) |          3        0.71       87.94
                 Hodgkin lymphoma (C81) |          2        0.47       88.42
      Non-Hodgkin lymphoma (C82-86,C96) |         15        3.55       91.96
                 Multiple myeloma (C90) |          9        2.13       94.09
               Lymphoid leukaemia (C91) |          2        0.47       94.56
             Myeloid leukaemia (C92-94) |          3        0.71       95.27
            Leukaemia unspecified (C95) |          1        0.24       95.51
     Myeloproliferative disorders (MPD) |          2        0.47       95.98
            Other and unspecified (O&U) |         17        4.02      100.00
----------------------------------------+-----------------------------------
                                  Total |        423      100.00
*/
** sites by behaviour
tab siteiarc beh ,m
tab beh ,m
tab sex ,m
/*
        Sex |      Freq.     Percent        Cum.
------------+-----------------------------------
       Male |        423       50.06       50.06
     Female |        422       49.94      100.00
------------+-----------------------------------
      Total |        845      100.00
*/

** For annual report - Section 1: Incidence - Table 1 (NOT USING IN TABLE AS USING 2014 TOP 5)
** FEMALE - using IARC's site groupings (excl. in-situ) COMBINE cervix & CIN 3
** Not used IN ANNUAL REPORT TABLE 1
preserve
drop if sex==1 //423 deleted
drop if (siteiarc==25|siteiarc>60) & siteiarc!=64 //17 deleted
replace siteiarc=32 if siteiarc==32|siteiarc==64 //9 changes
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

gen totpercent=(count/422)*100 //all cancers excl. male(423)
gen alltotpercent=(count/845)*100 //all cancers
/*
siteiarc	count	percentage	totpercent	alltotpercent
Breast (C50)	134	47.69	31.75356	15.85799
Colon (C18)	53	18.86	12.55924	6.272189
Cervix uteri (C53)	44	15.66	10.42654	5.2071
Corpus uteri (C54)	31	11.03	7.345972	3.668639
Rectum (C19-20)	19	6.76	4.50237	2.248521
*/
total count //281
restore

** FEMALE - using IARC's site groupings (excl. in-situ)
preserve
drop if sex==1 //423 deleted
drop if siteiarc==25|siteiarc>60 //26 deleted
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

gen totpercent=(count/422)*100 //all cancers excl. male(423)
gen alltotpercent=(count/845)*100 //all cancers
/*
siteiarc	count	percentage	totpercent	alltotpercent
Breast (C50)	134	49.26	31.75356	15.85799
Colon (C18)	53	19.49	12.55924	6.272189
Cervix uteri (C53)	35	12.87	8.293839	4.142012
Corpus uteri (C54)	31	11.40	7.345972	3.668639
Rectum (C19-20)	19	6.99	4.50237	2.248521
*/
total count //
restore

** FEMALE - using IARC's site groupings (incl. in-situ)
preserve
drop if sex==1 //423 deleted
drop if (siteiarc==25|siteiarc>60) & siteiarc!=64 //17 deleted
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

gen totpercent=(count/422)*100 //all cancers excl. male(423)
gen alltotpercent=(count/845)*100 //all cancers
/*
siteiarc	count	percentage	totpercent	alltotpercent
Breast (C50)	134	49.26	31.75356	15.85799
Colon (C18)	53	19.49	12.55924	6.272189
Cervix uteri (C53)	35	12.87	8.293839	4.142012
Corpus uteri (C54)	31	11.40	7.345972	3.668639
Rectum (C19-20)	19	6.99	4.50237	2.248521
*/
total count //272
restore

** For annual report - Section 1: Incidence - Table 1 (NOT USING IN TABLE AS USING 2014 TOP 5)
** Below top 5 code added by JC for 2014
** MALE - using IARC's site groupings
preserve
drop if sex==2 //422 deleted
drop if siteiarc==25|siteiarc>60 //17 deleted
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

gen totpercent=(count/423)*100 //all cancers excl. female(422)
gen alltotpercent=(count/845)*100 //all cancers
/*
siteiarc	count	percentage	totpercent	alltotpercent
Prostate (C61)	171	60.00	40.42553	20.23669
Colon (C18)	54	18.95	12.76596	6.390532
Rectum (C19-20)	25	8.77	5.910165	2.95858
Lung (incl. trachea and bronchus) (C33-34)	20	7.02	4.728132	2.366864
Non-Hodgkin lymphoma (C82-86,C96)	15	5.26	3.546099	1.775148
*/
total count //285
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
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                               845  (_merge==3)
    -----------------------------------------
*/
** No unmatched records

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
  |  845   277814   304.16    219.59   204.68   235.35     7.75 |
  +-------------------------------------------------------------+
*/
restore

** Next, IRs for invasive tumours only
preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** No missing age groups
		
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
  |  836   277814   300.92    216.59   201.81   232.22     7.68 |
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
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  422   144803   291.43    202.55   182.79   223.95    10.36 |
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
  |  423   133011   318.02    244.80   221.86   269.57    12.01 |
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
	drop if beh!=3 //9 deleted
	keep if siteiarc==39 // prostate only
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M 0-14,15-24,25-34,35-44
	expand 2 in 1
	replace sex=2 in 6
	replace age_10=1 in 6
	replace case=0 in 6
	replace pop_bb=(28005) in 6
	sort age_10	
	
	expand 2 in 1
	replace sex=2 in 7
	replace age_10=2 in 7
	replace case=0 in 7
	replace pop_bb=(18510)  in 7
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=3 in 8
	replace case=0 in 8
	replace pop_bb=(18465) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=4 in 9
	replace case=0 in 9
	replace pop_bb=(19550) in 9
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
  |  171   133011   128.56     98.40    84.12   114.51     7.60 |
  +-------------------------------------------------------------+
*/
restore


** BREAST
tab pop age_10  if siteiarc==29 & sex==1 //female
tab pop age_10  if siteiarc==29 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==29 // breast only
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24
	** M 25-34,35-44,55-64,85+
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
	replace sex=2 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bb=(18465) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_bb=(19550) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=6 in 17
	replace case=0 in 17
	replace pop_bb=(14195) in 17
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
** THIS IS FOR BC (M&F) - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  137   277814   49.31     36.13    30.18    42.97     3.19 |
  +------------------------------------------------------------+
*/
restore


** COLON 
tab pop age_10  if siteiarc==13 & sex==1 //female
tab pop age_10  if siteiarc==13 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24,25-34
	** M 85+
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_bb=(26755) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 13
	replace age_10=1 in 13
	replace case=0 in 13
	replace pop_bb=(28005) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_bb=(18530) in 14
	sort age_10

	expand 2 in 1
	replace sex=2 in 15
	replace age_10=2 in 15
	replace case=0 in 15
	replace pop_bb=(18510) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_bb=(19410) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=3 in 17
	replace case=0 in 17
	replace pop_bb=(18465) in 17
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
** THIS IS FOR COLON CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  107   277814   38.51     26.03    21.24    31.66     2.59 |
  +------------------------------------------------------------+
*/
restore


** CERVIX UTERI - incl. CIN 3 (THIS USED IN ANN RPT TABLE 2b)
tab pop_bb age_10 if siteiarc==32|siteiarc==64 //female

preserve
	drop if age_10==.
	drop if beh!=3 & siteiarc!=64 //0 deleted
	keep if siteiarc==32|siteiarc==64 // cervix uteri with CIN 3
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-14,15-24
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
	replace pop_bb=(18530) in 9
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
  |   44   144803   30.39     23.30    16.77    31.61     3.67 |
  +------------------------------------------------------------+
*/
restore

** CORPUS UTERI
tab pop_bb age_10 if siteiarc==33

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==33 // corpus uteri only
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-14,15-24,25-34,35-44,85+
	expand 2 in 1
	replace sex=1 in 5
	replace age_10=1 in 5
	replace case=0 in 5
	replace pop_bb=(26755) in 5
	sort age_10	
	
	expand 2 in 1
	replace sex=1 in 6
	replace age_10=2 in 6
	replace case=0 in 6
	replace pop_bb=(18530) in 6
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=3 in 7
	replace case=0 in 7
	replace pop_bb=(19410) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=4 in 8
	replace case=0 in 8
	replace pop_bb=(21080) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=9 in 9
	replace case=0 in 9
	replace pop_bb=(3388) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CORPUS UTERI - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   31   144803   21.41     14.77     9.99    21.22     2.76 |
  +------------------------------------------------------------+
*/
restore

** LUNG
tab pop age_10 if siteiarc==21 & sex==1 //female
tab pop age_10 if siteiarc==21 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==21
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24,25-34,35-44
	** F   85+
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
** THIS IS FOR LUNG CANCER (M&F)- STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   27   277814    9.72      6.83     4.47    10.06     1.37 |
  +------------------------------------------------------------+
*/
restore


** RECTUM 
tab pop age_10  if siteiarc==14 & sex==1 //female
tab pop age_10  if siteiarc==14 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==14
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24
	** F 25-34,35-44
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=1 in 13
	replace case=0 in 13
	replace pop_bb=(26755) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_bb=(28005) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=2 in 15
	replace case=0 in 15
	replace pop_bb=(18530) in 15
	sort age_10

	expand 2 in 1
	replace sex=2 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_bb=(18510) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=3 in 17
	replace case=0 in 17
	replace pop_bb=(19410) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=4 in 18
	replace case=0 in 18
	replace pop_bb=(21080) in 18
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
  |   44   277814   15.84     10.88     7.83    14.80     1.72 |
  +------------------------------------------------------------+
*/
restore


** MULTIPLE MYELOMA
tab pop age_10 if siteiarc==55 & sex==1 //female
tab pop age_10 if siteiarc==55 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==55
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,25-44,75-64
	** F 55-64
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
	replace sex=1 in 16
	replace age_10=6 in 16
	replace case=0 in 16
	replace pop_bb=(15940) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=8 in 17
	replace case=0 in 17
	replace pop_bb=(7240) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=8 in 18
	replace case=0 in 18
	replace pop_bb=(4835) in 18
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
  |   13   277814    4.68      3.27     1.71     5.76     0.99 |
  +------------------------------------------------------------+
*/
restore


** BLADDER 
tab pop age_10  if siteiarc==45 & sex==1 //female
tab pop age_10  if siteiarc==45 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==45
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44,45-54,85+
	** F 75-84
	expand 2 in 1
	replace sex=1 in 6
	replace age_10=1 in 6
	replace case=0 in 6
	replace pop_bb=(26755) in 6
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_bb=(28005) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_bb=(18530) in 8
	sort age_10

	expand 2 in 1
	replace sex=2 in 9
	replace age_10=2 in 9
	replace case=0 in 9
	replace pop_bb=(18510) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=3 in 10
	replace case=0 in 10
	replace pop_bb=(19410) in 10
	sort age_10

	expand 2 in 1
	replace sex=2 in 11
	replace age_10=3 in 11
	replace case=0 in 11
	replace pop_bb=(18465) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=4 in 12
	replace case=0 in 12
	replace pop_bb=(21080) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 13
	replace age_10=4 in 13
	replace case=0 in 13
	replace pop_bb=(19550) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=5 in 14
	replace case=0 in 14
	replace pop_bb=(21945) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=5 in 15
	replace case=0 in 15
	replace pop_bb=(19470) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=8 in 16
	replace case=0 in 16
	replace pop_bb=(7240) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=9 in 17
	replace case=0 in 17
	replace pop_bb=(3388) in 17
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
** THIS IS FOR BLADDER CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   11   277814    3.96      2.80     1.39     5.14     0.91 |
  +------------------------------------------------------------+
*/
restore


** PANCREAS 
tab pop age_10  if siteiarc==18 & sex==1 //female
tab pop age_10  if siteiarc==18 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==18
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=1 in 13
	replace case=0 in 13
	replace pop_bb=(26755) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_bb=(28005) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=2 in 15
	replace case=0 in 15
	replace pop_bb=(18530) in 15
	sort age_10

	expand 2 in 1
	replace sex=2 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_bb=(18510) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=3 in 17
	replace case=0 in 17
	replace pop_bb=(19410) in 17
	sort age_10

	expand 2 in 1
	replace sex=2 in 18
	replace age_10=3 in 18
	replace case=0 in 18
	replace pop_bb=(18465) in 18
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
  |   22   277814    7.92      5.43     3.36     8.40     1.23 |
  +------------------------------------------------------------+
*/
restore


** STOMACH 
tab pop age_10  if siteiarc==11 & sex==1 //female
tab pop age_10  if siteiarc==11 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==11
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,45-54,85+
	** F 35-44
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
	replace sex=1 in 15
	replace age_10=5 in 15
	replace case=0 in 15
	replace pop_bb=(21945) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=5 in 16
	replace case=0 in 16
	replace pop_bb=(19470) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=9 in 17
	replace case=0 in 17
	replace pop_bb=(3388) in 17
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
** THIS IS FOR STOMACH CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   16   277814    5.76      4.09     2.32     6.77     1.09 |
  +------------------------------------------------------------+
*/
restore

** NON-HODGKIN LYMPHOMA 
tab pop age_10  if siteiarc==53 & sex==1 //female
tab pop age_10  if siteiarc==53 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==53
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14
	** F 15-24,35-44,45-54
	** M 25-34
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=1 in 13
	replace case=0 in 13
	replace pop_bb=(26755) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_bb=(28005) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=2 in 15
	replace case=0 in 15
	replace pop_bb=(18530) in 15
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
** THIS IS FOR NHL (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   23   277814    8.28      6.24     3.89     9.53     1.39 |
  +------------------------------------------------------------+
*/
restore


** KIDNEY 
tab pop age_10  if siteiarc==42 & sex==1 //female
tab pop age_10  if siteiarc==42 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //9 deleted
	keep if siteiarc==42
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 15-24,25-34,85+
	** F 45-54
	** M 0-14
	
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
	replace pop_bb=(18510)  in 13
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
	replace sex=2 in 17
	replace age_10=9 in 17
	replace case=0 in 17
	replace pop_bb=(1666) in 17
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
** THIS IS FOR KIDNEY CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   23   277814    8.28      6.20     3.88     9.45     1.37 |
  +------------------------------------------------------------+
*/
restore


***********************************************
** Info for first table (summary state ES1): **
***********************************************
tab beh ,m
** proportion registrations per popn
dis (845/277814)*100 // all cancers
dis (836/277814)*100 // malignant only
dis (9/277814)*100 // in-situ only


** number of multiple tumours
tab patient ,m //831 pts;14 multiple events
tab siteiarc patient,m

dis 14/845 //% MPs for all cancers
dis 3/14 //site(s) with highest %MPs breast, kidney: both each have 3


** No., % deaths by end 2013
tab beh if patient==1 ,m //822 malignant, 9 in-situ

tab deceased if patient==1 & (dod>d(31dec2012) & dod<d(01jan2014)) ,m

tab beh deceased if patient==1 & (dod>d(31dec2012) & dod<d(01jan2014)) ,m

dis 212/831 //% deaths for all cancers
dis 0/9 //% deaths for in-situ cancers
dis 212/822 //% deaths for malignant cancers

tab basis ,m
tab basis if beh<3 ,m

tab basis if beh==3 ,m

tab basis beh ,m
dis 43/845 //% DCOs for all cancers
dis 0/9 //% DCOs for in-situ cancers
dis 43/836 //% DCOs for malignant cancers


** number of colorectal (ICD-10 C18-C21)
count if siteiarc>12 & siteiarc<16 //161


** Save this new dataset without population data 
save "`datapath'\version01\2-working\2013_cancer_sites_da_v01", replace
label data "2013 BNR-Cancer analysed data - Sites"
note: TS This dataset does NOT include population data
