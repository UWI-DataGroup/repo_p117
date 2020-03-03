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
    *log using "`logpath'/20_analysis cancer.smcl", replace
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

putdocx save "`datapath'\version02\3-output\2020-03-03_DQI.docx", append
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

putdocx save "`datapath'\version02\3-output\2020-03-03_DQI.docx", append
putdocx clear

save "`datapath'\version02\2-working\2015_cancer_dqi_siteage.dta" ,replace
label data "BNR-Cancer 2015 Data Quality Index - Site,Age"
notes _dta :These data prepared for Natasha Sobers - 2015 annual report
restore
** Missing sex %
** Missing age %

stop
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

**********************************************************************************
** ASIR and 95% CI for Table 1 using AR's site groupings - using WHO World popn **
**					BARBADOS STATISTICAL SERVICES (BSS): 2013					**
*drop pfu
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

*drop _merge
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
*drop pfu
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

*drop _merge
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
*drop pfu
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

*drop _merge
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
	drop if sex==2
	
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
	drop if sex==2
	
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
*drop pfu
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

*drop _merge
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
replace year=2014 if year==.
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
replace year=2014 if year==.
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
replace year=2014 if year==.
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
replace year=2014 if year==.
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
replace year=2014 if year==.
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
replace year=2014 if year==.
order population cancer_site year asir ci_lower ci_upper
sort cancer_site asir
format asir 
save "`datapath'\version02\2-working\ASIRs_BSS_WPP" ,replace
restore

clear

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
** Load the dataset
use "`datapath'\version02\2-working\2008_2013_2014_2015_cancer_numbers", replace
**********************************************************************************
** ASIR and 95% CI for Table 1 using AR's site groupings - using WHO World popn **
**					WORLD POPULATION PROSPECTS (WPP): 2015						**
*drop pfu
gen pfu=1 // for % year if not whole year collected; not done for cancer        **
**********************************************************************************
** JCampbell 02-Dec-2019 performing ASIRs on BSS vs UN WPP populations for 
** NS to conduct sensitivity analysis to determine if to use BSS or WPP populations for rates
** Using top 5 cancer sites from 2015 annual rpt
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
    matched                             2,417  (_merge==3)
    -----------------------------------------
*/
** No unmatched records

** Below saved in pathway: 
//X:\The University of the West Indies\DataGroup - repo_data\data_p117\version02\2-working\WPP_population by sex_2015.txt
tab pop_wpp age_10 if sex==1 //female
tab pop_wpp age_10 if sex==2 //male

** Next, IRs for invasive tumours only
preserve
    drop if dxyr!=2015
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
	replace pop_wpp=(18761) in 18
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
replace year=2015 if year==.
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
    drop if dxyr!=2015
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
replace year=2015 if year==.
order population cancer_site year asir ci_lower ci_upper
sort cancer_site asir
format asir 
save "`datapath'\version02\2-working\ASIRs_BSS_WPP" ,replace
restore


** BREAST
tab pop_wpp age_10  if siteiarc==29 & sex==1 & dxyr==2015 //female
tab pop_wpp age_10  if siteiarc==29 & sex==2 & dxyr==2015 //male

preserve
    drop if dxyr!=2015
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==29 // breast only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14, 15-24
	** M 25-34, 35-44, 65-74, 75-84, 85+
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_wpp=(25537) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=2 in 10
	replace case=0 in 10
	replace pop_wpp=(18761) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(26626) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(19111) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_wpp=(18440) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=4 in 14
	replace case=0 in 14
	replace pop_wpp=(19218) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=7 in 15
	replace case=0 in 15
	replace pop_wpp=(10117) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=8 in 16
	replace case=0 in 16
	replace pop_wpp=(5564) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=9 in 17
	replace case=0 in 17
	replace pop_wpp=(2487) in 17
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command
sort age_10
total pop_wpp

** for both female & male breast cancer; JC: added for 2015
** but may not use in ann rpt as total <10 cases (=4)
** AR to JC: yes you can use this, as it's a single rate for the whole population 
** and we don't say #M, #F just overall IR (M+F)
** the thing is though, we won't use it as it really lowers the IR - there are so
** few M cases but you then have to use the whole population
distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
				 
distrate case pop_wpp using "`datapath'\version02\2-working\who2000_10-2" if sex==1, 	///	
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
replace year=2015 if year==.
order population cancer_site year asir ci_lower ci_upper
sort cancer_site asir
format asir 
save "`datapath'\version02\2-working\ASIRs_BSS_WPP" ,replace
restore

** COLON 
tab pop_wpp age_10  if siteiarc==13 & sex==1 & dxyr==2015 //female
tab pop_wpp age_10  if siteiarc==13 & sex==2 & dxyr==2015 //male

preserve
    drop if dxyr!=2015
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: M&F 0-14, M&F 15-24
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(26626) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_wpp=(25537) in 15
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
replace year=2015 if year==.
order population cancer_site year asir ci_lower ci_upper
sort cancer_site asir
format asir 
save "`datapath'\version02\2-working\ASIRs_BSS_WPP" ,replace
restore


** CERVIX UTERI - excl. CIN 3
tab pop_wpp age_10 if siteiarc==32 & dxyr==2015 //female

preserve // without the preserve the command runs (KR)
    drop if dxyr!=2015
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==32 // corpus uteri only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: F 0-14, 15-24  
	
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_wpp=(25537) in 7
	sort age_10	
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=8 in 8
	replace case=0 in 8
	replace pop_wpp=(7635)  in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=2 in 9
	replace case=0 in 9
	replace pop_wpp=(18761)  in 9
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
replace year=2015 if year==.
order population cancer_site year asir ci_lower ci_upper
sort cancer_site asir
format asir 
save "`datapath'\version02\2-working\ASIRs_BSS_WPP" ,replace
restore


** CORPUS UTERI
tab pop_wpp age_10 if siteiarc==33 & dxyr==2015 //female

preserve
    drop if dxyr!=2015
	drop if age_10==.
	drop if beh!=3 //24 obs deleted
	keep if siteiarc==33 // corpus uteri only
	drop if sex==2
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: F 0-14, 15-24, 25-34
	** JC: I had to change the obsID so that the replacements could take place as the
	** dataset stopped at obsID when the above code was run
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
	replace pop_wpp=(18761)  in 8
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
replace year=2015 if year==.
order population cancer_site year asir ci_lower ci_upper
sort cancer_site asir
format asir 
save "`datapath'\version02\2-working\ASIRs_BSS_WPP" ,replace
restore

clear

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

