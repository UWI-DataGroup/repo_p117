** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          9_sites_2008_da_v01.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      17-APR-2019
    // 	date last modified      18-APR-2019
    //  algorithm task          Generate Incidence Rates by (IARC) site: (1) identification of top sites (2) crude: by sex (3) crude: by site (4) ASR(ASIR): all sites, world & US(2000) pop (5) ASR(ASIR): all sites, by sex (world & US)
    //  status                  Completed
    //  objectve                To have one dataset with cleaned, grouped and analysed 2008 data for 2014 cancer report.
    //  note                    2008 case definition differs from 2009 onwards diagnoses i.e. includes all beh=2 and non-reportable skin cancers

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
    log using "`logpath'\9_sites_2008_da_v01.smcl", replace
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
use "`datapath'\version01\2-working\2008_cancer_numbers_da_v01", replace

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
tab siteiarc ,m //1209 - 10 uncertain beh; 8 benign; 84 insitu; 33 O&U
/*
                      IARC CI5-XI sites |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                        Tongue (C01-02) |          7        0.58        0.58
                         Mouth (C03-06) |          4        0.33        0.91
                           Tonsil (C09) |          3        0.25        1.16
                      Nasopharynx (C11) |          3        0.25        1.41
                   Hypopharynx (C12-13) |          3        0.25        1.65
              Pharynx unspecified (C14) |          1        0.08        1.74
                       Oesophagus (C15) |          8        0.66        2.40
                          Stomach (C16) |         32        2.65        5.05
                  Small intestine (C17) |          2        0.17        5.21
                            Colon (C18) |         94        7.78       12.99
                        Rectum (C19-20) |         29        2.40       15.38
                             Anus (C21) |          3        0.25       15.63
                            Liver (C22) |          5        0.41       16.05
              Gallbladder etc. (C23-24) |          3        0.25       16.29
                         Pancreas (C25) |         15        1.24       17.54
            Nose, sinuses etc. (C30-31) |          4        0.33       17.87
                           Larynx (C32) |          5        0.41       18.28
Lung (incl. trachea and bronchus) (C33- |         29        2.40       20.68
         Other thoracic organs (C37-38) |          1        0.08       20.76
                          Bone (C40-41) |          4        0.33       21.09
                 Melanoma of skin (C43) |          5        0.41       21.51
                       Other skin (C44) |        303       25.06       46.57
   Connective and soft tissue (C47+C49) |          5        0.41       46.98
                           Breast (C50) |        133       11.00       57.98
                            Vulva (C51) |          1        0.08       58.06
                     Cervix uteri (C53) |         19        1.57       59.64
                     Corpus uteri (C54) |         39        3.23       62.86
               Uterus unspecified (C55) |          2        0.17       63.03
                            Ovary (C56) |         10        0.83       63.85
      Other female genital organs (C57) |          2        0.17       64.02
                         Placenta (C58) |          2        0.17       64.19
                            Penis (C60) |          2        0.17       64.35
                         Prostate (C61) |        204       16.87       81.22
                           Testis (C62) |          1        0.08       81.31
                           Kidney (C64) |         12        0.99       82.30
                          Bladder (C67) |          8        0.66       82.96
             Other urinary organs (C68) |          1        0.08       83.04
                              Eye (C69) |          3        0.25       83.29
         Brain, nervous system (C70-72) |          2        0.17       83.46
                          Thyroid (C73) |         10        0.83       84.28
                  Other endocrine (C75) |          2        0.17       84.45
                 Hodgkin lymphoma (C81) |          3        0.25       84.70
      Non-Hodgkin lymphoma (C82-86,C96) |         13        1.08       85.77
     Immunoproliferative diseases (C88) |          1        0.08       85.86
                 Multiple myeloma (C90) |         17        1.41       87.26
               Lymphoid leukaemia (C91) |          3        0.25       87.51
             Myeloid leukaemia (C92-94) |          9        0.74       88.25
            Leukaemia unspecified (C95) |          2        0.17       88.42
     Myeloproliferative disorders (MPD) |          3        0.25       88.67
        Myelodysplastic syndromes (MDS) |          2        0.17       88.83
            Other and unspecified (O&U) |         33        2.73       91.56
                            D069: CIN 3 |         34        2.81       94.38
                   All in-situ but CIN3 |         50        4.14       98.51
                All uncertain behaviour |         10        0.83       99.34
                             All benign |          8        0.66      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,209      100.00
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
drop if (siteiarc==25|siteiarc>60) & siteiarc!=64 //404 deleted
tab siteiarc ,m
replace siteiarc=32 if siteiarc==32|siteiarc==64 //34 changes
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
siteiarc	                                count	percentage
Prostate (C61)	                            204	    31.63
Breast (C50)	                            	133	    20.62
Colon (C18)	                                94	    14.57
Cervix uteri (C53)	                        53	    8.22
Corpus uteri (C54)	                        39	    6.05
Stomach (C16)	                            	32	    4.96
Lung (incl. trachea and bronchus) (C33-34)	29	    4.50
Rectum (C19-20)	                            29	    4.50
Multiple myeloma (C90)	                    17	    2.64
Pancreas (C25)	                            15  	2.33
*/
total count //645
restore

** All sites excl. O&U, non-reportable skin cancers - using IARC CI5's site groupings COMBINE cervix & CIN 3
** THIS USED IN ANNUAL REPORT TABLE 1 - CHECKING WHERE IN LIST 2014 TOP 10 APPEARS IN LIST FOR 2008
** This list requested by NS in similar format to CMO's report for top 10 comparisons with current & previous years
** Screenshot this data from Stata data editor into annual report tables document.
preserve
drop if (siteiarc==25|siteiarc>60) & siteiarc!=64 //
replace siteiarc=32 if siteiarc==32|siteiarc==64 //34 changes
tab siteiarc ,m
contract siteiarc, freq(count) percent(percentage)
gsort -count
/*
siteiarc	                                count	percentage
Prostate (C61)	                            204	    25.34
Breast (C50)	                            133	    16.52
Colon (C18)	                                94	    11.68
Cervix uteri (C53)	                        53	    6.58
Corpus uteri (C54)	                        39	    4.84
Stomach (C16)	                            32	    3.98
Lung (incl. trachea and bronchus) (C33-34)	29	    3.60
Rectum (C19-20)	                            29	    3.60
Multiple myeloma (C90)	                    17	    2.11
Pancreas (C25)	                            15	    1.86
Non-Hodgkin lymphoma (C82-86,C96)	        13	    1.61
Kidney (C64)	                            12	    1.49
Thyroid (C73)	                            10	    1.24
Ovary (C56)	                                10	    1.24
Myeloid leukaemia (C92-94)	                9	    1.12
Oesophagus (C15)	                        8	    0.99
Bladder (C67)	                            8	    0.99
Tongue (C01-02)	                            7	    0.87
Larynx (C32)	                            5	    0.62
Melanoma of skin (C43)	                    5	    0.62
Connective and soft tissue (C47+C49)	    5	    0.62
Liver (C22)	                                5	    0.62
Bone (C40-41)	                            4	    0.50
Nose, sinuses etc. (C30-31)	                4	    0.50
Mouth (C03-06)	                            4	    0.50
Hodgkin lymphoma (C81)	                    3	    0.37
Nasopharynx (C11)	                        3	    0.37
Hypopharynx (C12-13)	                    3	    0.37
Eye (C69)	                                3	    0.37
Myeloproliferative disorders (MPD)	        3	    0.37
Anus (C21)	                                3	    0.37
Lymphoid leukaemia (C91)	                3	    0.37
Tonsil (C09)	                            3	    0.37
Gallbladder etc. (C23-24)	                3	    0.37
Other endocrine (C75)	                    2	    0.25
Placenta (C58)	                            2	    0.25
Small intestine (C17)	                    2	    0.25
Myelodysplastic syndromes (MDS)	            2	    0.25
Leukaemia unspecified (C95)	                2	    0.25
Other female genital organs (C57)	        2	    0.25
Uterus unspecified (C55)	                2	    0.25
Penis (C60)	                                2	    0.25
Brain, nervous system (C70-72)	            2	    0.25
Other thoracic organs (C37-38)	            1	    0.12
Other urinary organs (C68)	                1	    0.12
Vulva (C51)	                                1	    0.12
Immunoproliferative diseases (C88)	        1	    0.12
Pharynx unspecified (C14)	                1	    0.12
Testis (C62)	                            1	    0.12
*/
total count //805 (O&U=33)
restore


** All sites excl. O&U, non-malignant, non-reportable skin cancers - using IARC CI5's site groupings
preserve
drop if siteiarc==25|siteiarc>60 //438 obs deleted
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
Prostate (C61)	                            204	    33.39
Breast (C50)	                            133	    21.77
Colon (C18)	                                94	    15.38
Corpus uteri (C54)	                        39	    6.38
Stomach (C16)	                            32	    5.24
Rectum (C19-20)	                            29	    4.75
Lung (incl. trachea and bronchus) (C33-34)	29	    4.75
Cervix uteri (C53)	                        19	    3.11
Multiple myeloma (C90)	                    17	    2.78
Pancreas (C25)	                            15	    2.45
*/
total count //611
restore

** All sites excl. O&U, non-reportable (skin) cancers - using IARC CI5's site groupings
preserve
drop if (siteiarc==25|siteiarc>60) & siteiarc!=64 //404 obs deleted
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
Prostate (C61)	                            204	    32.38
Breast (C50)	                            	133	    21.11
Colon (C18)	                                94	    14.92
Corpus uteri (C54)	                        39	    6.19
D069: CIN 3	                                34	    5.40
Stomach (C16)	                            	32	    5.08
Lung (incl. trachea and bronchus) (C33-34)	29	    4.60
Rectum (C19-20)	                            29	    4.60
Cervix uteri (C53)	                        19	    3.02
Multiple myeloma (C90)	                    17	    2.70
*/
total count //630
restore

** proportions for Table 1 using IARC's site groupings (NOT USING IN TABLE AS USING 2014)
tab siteiarc sex ,m
tab siteiarc , m
tab siteiarc if sex==2 ,m // female
/*
                      IARC CI5-XI sites |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                         Mouth (C03-06) |          1        0.17        0.17
                           Tonsil (C09) |          1        0.17        0.34
                   Hypopharynx (C12-13) |          2        0.34        0.68
                          Stomach (C16) |         13        2.22        2.91
                  Small intestine (C17) |          1        0.17        3.08
                            Colon (C18) |         45        7.69       10.77
                        Rectum (C19-20) |         16        2.74       13.50
                            Liver (C22) |          3        0.51       14.02
              Gallbladder etc. (C23-24) |          2        0.34       14.36
                         Pancreas (C25) |          3        0.51       14.87
            Nose, sinuses etc. (C30-31) |          2        0.34       15.21
Lung (incl. trachea and bronchus) (C33- |          7        1.20       16.41
         Other thoracic organs (C37-38) |          1        0.17       16.58
                          Bone (C40-41) |          1        0.17       16.75
                 Melanoma of skin (C43) |          1        0.17       16.92
                       Other skin (C44) |        123       21.03       37.95
   Connective and soft tissue (C47+C49) |          4        0.68       38.63
                           Breast (C50) |        133       22.74       61.37
                            Vulva (C51) |          1        0.17       61.54
                     Cervix uteri (C53) |         19        3.25       64.79
                     Corpus uteri (C54) |         39        6.67       71.45
               Uterus unspecified (C55) |          2        0.34       71.79
                            Ovary (C56) |         10        1.71       73.50
      Other female genital organs (C57) |          2        0.34       73.85
                         Placenta (C58) |          2        0.34       74.19
                           Kidney (C64) |          5        0.85       75.04
                          Bladder (C67) |          4        0.68       75.73
             Other urinary organs (C68) |          1        0.17       75.90
                              Eye (C69) |          1        0.17       76.07
         Brain, nervous system (C70-72) |          1        0.17       76.24
                          Thyroid (C73) |         10        1.71       77.95
                  Other endocrine (C75) |          1        0.17       78.12
                 Hodgkin lymphoma (C81) |          1        0.17       78.29
      Non-Hodgkin lymphoma (C82-86,C96) |         10        1.71       80.00
                 Multiple myeloma (C90) |         14        2.39       82.39
               Lymphoid leukaemia (C91) |          2        0.34       82.74
             Myeloid leukaemia (C92-94) |          4        0.68       83.42
     Myeloproliferative disorders (MPD) |          1        0.17       83.59
        Myelodysplastic syndromes (MDS) |          1        0.17       83.76
            Other and unspecified (O&U) |         18        3.08       86.84
                            D069: CIN 3 |         34        5.81       92.65
                   All in-situ but CIN3 |         32        5.47       98.12
                All uncertain behaviour |          7        1.20       99.32
                             All benign |          4        0.68      100.00
----------------------------------------+-----------------------------------
                                  Total |        585      100.00
*/
tab siteiarc if sex==1 ,m // male
/*
                      IARC CI5-XI sites |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                        Tongue (C01-02) |          7        1.12        1.12
                         Mouth (C03-06) |          3        0.48        1.60
                           Tonsil (C09) |          2        0.32        1.92
                      Nasopharynx (C11) |          3        0.48        2.40
                   Hypopharynx (C12-13) |          1        0.16        2.56
              Pharynx unspecified (C14) |          1        0.16        2.72
                       Oesophagus (C15) |          8        1.28        4.01
                          Stomach (C16) |         19        3.04        7.05
                  Small intestine (C17) |          1        0.16        7.21
                            Colon (C18) |         49        7.85       15.06
                        Rectum (C19-20) |         13        2.08       17.15
                             Anus (C21) |          3        0.48       17.63
                            Liver (C22) |          2        0.32       17.95
              Gallbladder etc. (C23-24) |          1        0.16       18.11
                         Pancreas (C25) |         12        1.92       20.03
            Nose, sinuses etc. (C30-31) |          2        0.32       20.35
                           Larynx (C32) |          5        0.80       21.15
Lung (incl. trachea and bronchus) (C33- |         22        3.53       24.68
                          Bone (C40-41) |          3        0.48       25.16
                 Melanoma of skin (C43) |          4        0.64       25.80
                       Other skin (C44) |        180       28.85       54.65
   Connective and soft tissue (C47+C49) |          1        0.16       54.81
                            Penis (C60) |          2        0.32       55.13
                         Prostate (C61) |        204       32.69       87.82
                           Testis (C62) |          1        0.16       87.98
                           Kidney (C64) |          7        1.12       89.10
                          Bladder (C67) |          4        0.64       89.74
                              Eye (C69) |          2        0.32       90.06
         Brain, nervous system (C70-72) |          1        0.16       90.22
                  Other endocrine (C75) |          1        0.16       90.38
                 Hodgkin lymphoma (C81) |          2        0.32       90.71
      Non-Hodgkin lymphoma (C82-86,C96) |          3        0.48       91.19
     Immunoproliferative diseases (C88) |          1        0.16       91.35
                 Multiple myeloma (C90) |          3        0.48       91.83
               Lymphoid leukaemia (C91) |          1        0.16       91.99
             Myeloid leukaemia (C92-94) |          5        0.80       92.79
            Leukaemia unspecified (C95) |          2        0.32       93.11
     Myeloproliferative disorders (MPD) |          2        0.32       93.43
        Myelodysplastic syndromes (MDS) |          1        0.16       93.59
            Other and unspecified (O&U) |         15        2.40       95.99
                   All in-situ but CIN3 |         18        2.88       98.88
                All uncertain behaviour |          3        0.48       99.36
                             All benign |          4        0.64      100.00
----------------------------------------+-----------------------------------
                                  Total |        624      100.00
*/
** sites by behaviour
tab siteiarc beh ,m
tab beh ,m
tab sex ,m
/*
        Sex |      Freq.     Percent        Cum.
------------+-----------------------------------
       Male |        624       51.61       51.61
     Female |        585       48.39      100.00
------------+-----------------------------------
      Total |      1,209      100.00
*/

** For annual report - Section 1: Incidence - Table 1 (NOT USING IN TABLE AS USING 2014 TOP 5)
** FEMALE - using IARC's site groupings (excl. in-situ) COMBINE cervix & CIN 3
** Not used IN ANNUAL REPORT TABLE 1
preserve
drop if sex==1 //624 obs deleted
drop if (siteiarc==25|siteiarc>60) & siteiarc!=64 //184 obs deleted
replace siteiarc=32 if siteiarc==32|siteiarc==64 //34 changes
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
siteiarc	        count	percentage	totpercent	alltotpercent
Breast (C50)	    133	    46.50	    28.78788	14.34736
Cervix uteri (C53)	53	    18.53	    11.47186	5.717368
Colon (C18)	        45	    15.73	    9.74026	    4.854369
Corpus uteri (C54)	39	    13.64	    8.441559	4.20712
Rectum (C19-20)	    16	    5.59	    3.463203	1.725998

*/
total count //286
restore

** FEMALE - using IARC's site groupings (excl. in-situ)
preserve
drop if sex==1 //624 obs deleted
drop if siteiarc==25|siteiarc>60 //218 obs deleted
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

gen totpercent=(count/585)*100 //all cancers excl. male(624)
gen alltotpercent=(count/1209)*100 //all cancers
/*
siteiarc	        count	percentage	totpercent	alltotpercent
Breast (C50)	    133	    52.78	    22.73504	11.00083
Colon (C18)	        45	    17.86	    7.692307    3.722084
Corpus uteri (C54)	39	    15.48	    6.666667	3.225806
Cervix uteri (C53)	19	    7.54	    3.247863	1.571547
Rectum (C19-20)	    16	    6.35	    2.735043	1.323408
*/
total count //252
restore

** FEMALE - using IARC's site groupings (incl. in-situ)
preserve
drop if sex==1 //624 obs deleted
drop if (siteiarc==25|siteiarc>60) & siteiarc!=64 //184 obs deleted
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

gen totpercent=(count/585)*100 //all cancers excl. male(624)
gen alltotpercent=(count/1209)*100 //all cancers
/*
siteiarc	        count	percentage	totpercent	alltotpercent
Breast (C50)	    133	    49.26	    22.73504	11.00083
Colon (C18)	        45	    16.67	    7.692307    3.722084
Corpus uteri (C54)	39	    14.44	    6.666667	3.225806
D069: CIN 3	        34	    12.59	    5.811966	2.812242
Cervix uteri (C53)	19	    7.04	    3.247863	1.571547
*/
total count //270
restore

** For annual report - Section 1: Incidence - Table 1 (NOT USING IN TABLE AS USING 2014 TOP 5)
** Below top 5 code added by JC for 2014
** MALE - using IARC's site groupings
preserve
drop if sex==2 //585 obs deleted
drop if siteiarc==25|siteiarc>60 //220 obs deleted
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

gen totpercent=(count/624)*100 //all cancers excl. female(585)
gen alltotpercent=(count/1209)*100 //all cancers
/*
siteiarc	                                count	percentage	totpercent	alltotpercent
Prostate (C61)	                            204	    66.45	    32.69231	16.87345
Colon (C18)	                                49	    15.96	    7.852564	4.052936
Lung (incl. trachea and bronchus) (C33-34)	22	    7.17	    3.525641	1.819686
Stomach (C16)	                            19	    6.19	    3.044872	1.571547
Rectum (C19-20)	                            13	    4.23	    2.083333	1.075269
*/
total count //307
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
    matched                             1,209  (_merge==3)
    -----------------------------------------
*/
** No unmatched records

tab pop age_10  if sex==1 //female
tab pop age_10  if sex==2 //male


** Next, IRs for all tumours excl. non-reportable skin cancers but include CIN 3 to match 2014 case definition
** THIS USED FOR 2014 ANNUAL REPORT TABLE ES1.
preserve
	drop if age_10==.
	drop if beh!=3 & siteiarc!=64 //68 deleted
    drop if siteiarc==25 //303 deleted
	
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
  |  838   277814   301.64    214.59   199.83   230.19     7.67 |
  +-------------------------------------------------------------+
*/
restore


** Next, IRs for all tumours
** Not used for 2014 ANNUAL REPORT TABLE ES1.
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
  | 1209   277814   435.18    305.87   288.33   324.24     9.08 |
  +-------------------------------------------------------------+
*/
restore


** Next, IRs for invasive tumours only
** Not used for 2014 ANNUAL REPORT TABLE ES1.
preserve
	drop if age_10==.
	drop if beh!=3 //102 deleted
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** No missing age groups/cases
		
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
  | 1107   277814   398.47    276.87   260.31   294.26     8.58 |
  +-------------------------------------------------------------+
*/
restore

** Next, IRs by sex excl. non-reportable skin cancers but include CIN 3 to match 2014 case definition
** Not used for 2014 ANNUAL REPORT TABLE ES1.
** for all women
tab pop age_10
tab pop age_10 if sex==1 //female
preserve
	drop if age_10==.
    drop if beh!=3 & siteiarc!=64 //68 deleted
    drop if siteiarc==25 //303 deleted
    tab sex ,m
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
  |  419   144803   289.36    201.30   181.47   222.77    10.39 |
  +-------------------------------------------------------------+
*/
restore

** for all men excl. non-reportable skin cancers but include CIN 3 to match 2014 case definition
** Not used for 2014 ANNUAL REPORT TABLE ES1.
tab pop age_10
tab pop age_10 if sex==2 //male
preserve
	drop if age_10==.
    drop if beh!=3 & siteiarc!=64 //68 deleted
    drop if siteiarc==25 //303 deleted
    tab sex ,m
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
  |  419   133011   315.01    238.04   215.51   262.39    11.80 |
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
	drop if beh!=3 //102 deleted
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
  |  204   133011   153.37    113.22    98.08   130.15     8.03 |
  +-------------------------------------------------------------+
*/
restore


** BREAST
tab pop age_10  if siteiarc==29 & sex==1 //female
tab pop age_10  if siteiarc==29 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //102 deleted
	keep if siteiarc==29 // breast only
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-14, 15-24
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
** THIS IS FOR BC (M&F) - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  133   144803   91.85     63.87    53.09    76.29     5.79 |
  +------------------------------------------------------------+
*/
restore


** COLON 
tab pop age_10  if siteiarc==13 & sex==1 //female
tab pop age_10  if siteiarc==13 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //102 deleted
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24
	** F 25-34
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_bb=(26755) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_bb=(28005) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_bb=(18530) in 16
	sort age_10

	expand 2 in 1
	replace sex=2 in 17
	replace age_10=2 in 17
	replace case=0 in 17
	replace pop_bb=(18510) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=3 in 18
	replace case=0 in 18
	replace pop_bb=(19410) in 18
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
  |   94   277814   33.84     23.39    18.80    28.82     2.49 |
  +------------------------------------------------------------+
*/
restore


** CERVIX UTERI - incl. CIN 3
tab pop_bb age_10 if siteiarc==32|siteiarc==64 //female

preserve
	drop if age_10==.
	drop if beh!=3 & siteiarc!=64 //68 deleted
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
  |   53   144803   36.60     32.04    23.70    42.32     4.63 |
  +------------------------------------------------------------+
*/
restore


** CORPUS UTERI
tab pop_bb age_10 if siteiarc==33 //female

preserve
	drop if age_10==.
	drop if beh!=3 //102 deleted
	keep if siteiarc==33 // corpus uteri only
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-14,15-24,25-34
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
  |   39   144803   26.93     17.70    12.48    24.57     2.97 |
  +------------------------------------------------------------+
*/
restore

** LUNG
tab pop age_10 if siteiarc==21 & sex==1 //female
tab pop age_10 if siteiarc==21 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //102 deleted
	keep if siteiarc==21
	
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
** THIS IS FOR LUNG CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   29   277814   10.44      7.28     4.82    10.63     1.42 |
  +------------------------------------------------------------+
*/
restore


** RECTUM 
tab pop age_10  if siteiarc==14 & sex==1 //female
tab pop age_10  if siteiarc==14 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //102 deleted
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
  |   29   277814   10.44      7.29     4.85    10.62     1.41 |
  +------------------------------------------------------------+
*/
restore

** MULTIPLE MYELOMA
tab pop age_10 if siteiarc==55 & sex==1 //female
tab pop age_10 if siteiarc==55 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //102 deleted
	keep if siteiarc==55
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	** M 55-64,65-74,85+
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
	replace age_10=6 in 16
	replace case=0 in 16
	replace pop_bb=(14195) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=7 in 17
	replace case=0 in 17
	replace pop_bb=(8315) in 17
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
  |   17   277814    6.12      3.78     2.16     6.28     1.00 |
  +------------------------------------------------------------+
*/
restore


** BLADDER 
tab pop age_10  if siteiarc==45 & sex==1 //female
tab pop age_10  if siteiarc==45 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //102 deleted
	keep if siteiarc==45
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44,45-54
	** F 55-64,65-74,85+
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
	replace age_10=6 in 16
	replace case=0 in 16
	replace pop_bb=(15940) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=7 in 17
	replace case=0 in 17
	replace pop_bb=(10515) in 17
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
** THIS IS FOR BLADDER CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |    8   277814    2.88      1.68     0.71     3.56     0.69 |
  +------------------------------------------------------------+
*/
restore


** PANCREAS 
tab pop age_10  if siteiarc==18 & sex==1 //female
tab pop age_10  if siteiarc==18 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //102 deleted
	keep if siteiarc==18
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,35-44
	** F 25-34,45-54,55-64
	** M 85+
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
	replace sex=1 in 17
	replace age_10=6 in 17
	replace case=0 in 17
	replace pop_bb=(15940) in 17
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
** THIS IS FOR PANCREATIC CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   15   277814    5.40      3.81     2.09     6.46     1.07 |
  +------------------------------------------------------------+
*/
restore


** STOMACH 
tab pop age_10  if siteiarc==11 & sex==1 //female
tab pop age_10  if siteiarc==11 & sex==2 //male

preserve
	drop if age_10==.
	drop if beh!=3 //102 deleted
	keep if siteiarc==11
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,45-54
	** F 35-44,55-64
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
	replace sex=1 in 16
	replace age_10=5 in 16
	replace case=0 in 16
	replace pop_bb=(21945) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=5 in 17
	replace case=0 in 17
	replace pop_bb=(19470) in 17
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

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR STOMACH CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   32   277814   11.52      6.85     4.62     9.92     1.30 |
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
	** M&F 0-14,15-24,35-44,45-54
	** M 25-34,75-84,85+
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
	replace sex=2 in 12
	replace age_10=3 in 12
	replace case=0 in 12
	replace pop_bb=(18465) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=4 in 13
	replace case=0 in 13
	replace pop_bb=(21080) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=4 in 14
	replace case=0 in 14
	replace pop_bb=(19550) in 14
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
** THIS IS FOR NHL (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   13   277814    4.68      3.39     1.74     6.01     1.04 |
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
	** M&F 0-14,15-24,25-34
	** F 35-44,85+
	** M 45-54,65-74
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
	replace age_10=5 in 16
	replace case=0 in 16
	replace pop_bb=(19470) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=7 in 17
	replace case=0 in 17
	replace pop_bb=(8315) in 17
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
  |   12   277814    4.32      2.84     1.43     5.17     0.91 |
  +------------------------------------------------------------+
*/
restore


***********************************************
** Info for first table (summary state ES1): **
***********************************************
** Exclude non-reportable skin cancers but include CIN 3 to match 2014 case definition
** THIS USED FOR 2014 ANNUAL REPORT TABLE ES1.
preserve
drop if beh!=3 & siteiarc!=64 //68 deleted
drop if siteiarc==25 //303 deleted

** proportion registrations per popn
tab beh ,m
** proportion registrations per popn
dis (838/277814)*100 // all cancers
dis (804/277814)*100 // malignant only
dis (34/277814)*100 // in-situ only


** number of multiple tumours
tab patient ,m //829 pts; 9 multiple events
tab siteiarc patient,m

dis 9/838 //% MPs for all cancers
dis 1/9 //site(s) with highest %MPs tongue,oesophagus,rectum,melanoma(skin),breast,corpus uteri,ovary,prostate,kidney: all have 1 each

** No., % deaths by end 2008
tab beh if patient==1 ,m //795 malignant, 34 in-situ

tab deceased if patient==1 & (dod>d(31dec2007) & dod<d(01jan2009)) ,m

tab beh deceased if patient==1 & (dod>d(31dec2007) & dod<d(01jan2009)) ,m

dis 232/829 //% deaths for all cancers
dis 0/34 //% deaths for in-situ cancers
dis 232/795 //% deaths for malignant cancers

tab basis ,m
tab basis if beh<3 ,m

tab basis if beh==3 ,m

tab basis beh ,m
dis 51/845 //% DCOs for all cancers
dis 0/34 //% DCOs for in-situ cancers
dis 51/804 //% DCOs for malignant cancers
restore


** number of colorectal (ICD-10 C18-C21)
count if siteiarc>12 & siteiarc<16 //126


** Save this new dataset without population data 
save "`datapath'\version01\2-working\2008_cancer_sites_da_v01", replace
label data "2008 BNR-Cancer analysed data - Sites"
note: TS This dataset does NOT include population data
