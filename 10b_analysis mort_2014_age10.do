** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          10b_analysis mort_2014_age10.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      24-AUG-2022
    // 	date last modified      24-AUG-2022
    //  algorithm task          Analyzing combined cancer dataset: (1) Numbers (2) ASMRs
    //  status                  Completed
    //  objective               To have one dataset with cleaned and grouped 2014 death data for the 2022 BNR-CME webinar & inclusion in 2016-2018 cancer report.
	//	methods					(1) Using 5-year age groups instead of 10-year (NOT DONE YET!)
	//							(2) Using female population for breast instead of total population
	//							(3) Using WPP population instead of BSS population
    
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
    local datapath "X:/The University of the West Indies/DataGroup - repo_data/data_p117"
    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath X:/OneDrive - The University of the West Indies/repo_datagroup/repo_p117

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\10b_analysis mort_2014_age10.smcl", replace
** HEADER -----------------------------------------------------

****************
** 2014 ASMRs **
****************

** Load the dataset
/* 
	JC 24aug2022: When checking SF's presentation for the 2022 BNR CME webinar, NS queried whether 2013-2015 ASMRs had used
	female pop for breast then I noted that those years used BSS pop instead of WPP so re-calculating 2013-2018 ASMRs 
	using WPP pop, female pop for breast and 5-year age groups so the methods are standardised with 
	those for the ASIRs calculations.
*/
use "`datapath'\version09\1-input\2014_cancer_mort_dc", clear

count // 651 cancer deaths in 2014
tab age_10 sex ,m
tab site ,m //2014 data has AR's site + icd10
labelbook site_lab //2014 data has AR's site + icd10

count if icd10=="" //0 missing

** JC 24aug2022: create siteiarc since CODs are ICD-10 coded
** Create new site variable with CI5-XI incidence classifications (see chapter 3 Table 3.1. of that volume) based on icd10
display `"{browse "http://ci5.iarc.fr/CI5-XI/Pages/Chapter3.aspx":IARC-CI5-XI-3}"'

drop siteiarc
label drop siteiarc_lab

gen siteiarc=.
label define siteiarc_lab ///
1 "Lip (C00)" 2 "Tongue (C01-02)" 3 "Mouth (C03-06)" ///
4 "Salivary gland (C07-08)" 5 "Tonsil (C09)" 6 "Other oropharynx (C10)" ///
7 "Nasopharynx (C11)" 8 "Hypopharynx (C12-13)" 9 "Pharynx unspecified (C14)" ///
10 "Oesophagus (C15)" 11 "Stomach (C16)" 12 "Small intestine (C17)" ///
13 "Colon (C18)" 14 "Rectum (C19-20)" 15 "Anus (C21)" ///
16 "Liver (C22)" 17 "Gallbladder etc. (C23-24)" 18 "Pancreas (C25)" ///
19 "Nose, sinuses etc. (C30-31)" 20 "Larynx (C32)" ///
21 "Lung (incl. trachea and bronchus) (C33-34)" 22 "Other thoracic organs (C37-38)" ///
23 "Bone (C40-41)" 24 "Melanoma of skin (C43)" 25 "Other skin (C44)" ///
26 "Mesothelioma (C45)" 27 "Kaposi sarcoma (C46)" 28 "Connective and soft tissue (C47+C49)" ///
29 "Breast (C50)" 30 "Vulva (C51)" 31 "Vagina (C52)" 32 "Cervix uteri (C53)" ///
33 "Corpus uteri (C54)" 34 "Uterus unspecified (C55)" 35 "Ovary (C56)" ///
36 "Other female genital organs (C57)" 37 "Placenta (C58)" ///
38 "Penis (C60)" 39 "Prostate (C61)" 40 "Testis (C62)" 41 "Other male genital organs (C63)" ///
42 "Kidney (C64)" 43 "Renal pelvis (C65)" 44 "Ureter (C66)" 45 "Bladder (C67)" ///
46 "Other urinary organs (C68)" 47 "Eye (C69)" 48 "Brain, nervous system (C70-72)" ///
49 "Thyroid (C73)" 50 "Adrenal gland (C74)" 51 "Other endocrine (C75)" ///
52 "Hodgkin lymphoma (C81)" 53 "Non-Hodgkin lymphoma (C82-86,C96)" ///
54 "Immunoproliferative diseases (C88)" 55 "Multiple myeloma (C90)" ///
56 "Lymphoid leukaemia (C91)" 57 "Myeloid leukaemia (C92-94)" 58 "Leukaemia unspecified (C95)" ///
59 "Myeloproliferative disorders (MPD)" 60 "Myselodysplastic syndromes (MDS)" ///
61 "Other and unspecified (O&U)" ///
62 "All sites(ALL)" 63 "All sites but skin (ALLbC44)" ///
64 "D069: CIN 3"
label var siteiarc "IARC CI5-XI sites"
label values siteiarc siteiarc_lab

replace siteiarc=1 if regexm(icd10,"C00") //0 changes
replace siteiarc=2 if (regexm(icd10,"C01")|regexm(icd10,"C02")) //4 changes
replace siteiarc=3 if (regexm(icd10,"C03")|regexm(icd10,"C04")|regexm(icd10,"C05")|regexm(icd10,"C06")) //2 changes
replace siteiarc=4 if (regexm(icd10,"C07")|regexm(icd10,"C08")) //1 change
replace siteiarc=5 if regexm(icd10,"C09") //1 change
replace siteiarc=6 if regexm(icd10,"C10") //5 changes
replace siteiarc=7 if regexm(icd10,"C11") //3 changes
replace siteiarc=8 if (regexm(icd10,"C12")|regexm(icd10,"C13")) //4 changes
replace siteiarc=9 if regexm(icd10,"C14") //1 change
replace siteiarc=10 if regexm(icd10,"C15") //10 changes
replace siteiarc=11 if regexm(icd10,"C16") //20 changes
replace siteiarc=12 if regexm(icd10,"C17") //2 changes
replace siteiarc=13 if regexm(icd10,"C18") //71 changes
replace siteiarc=14 if (regexm(icd10,"C19")|regexm(icd10,"C20")) //20 changes
replace siteiarc=15 if regexm(icd10,"C21") //1 change
replace siteiarc=16 if regexm(icd10,"C22") //9 changes
replace siteiarc=17 if (regexm(icd10,"C23")|regexm(icd10,"C24")) //9 changes
replace siteiarc=18 if regexm(icd10,"C25") //29 changes
replace siteiarc=19 if (regexm(icd10,"C30")|regexm(icd10,"C31")) //1 change
replace siteiarc=20 if regexm(icd10,"C32") //1 change
replace siteiarc=21 if (regexm(icd10,"C33")|regexm(icd10,"C34")) //41 changes
replace siteiarc=22 if (regexm(icd10,"C37")|regexm(icd10,"C38")) //0 changes
replace siteiarc=23 if (regexm(icd10,"C40")|regexm(icd10,"C41")) //2 changes
replace siteiarc=24 if regexm(icd10,"C43") //1 change
replace siteiarc=25 if regexm(icd10,"C44") //7 changes
replace siteiarc=26 if regexm(icd10,"C45") //1 change
replace siteiarc=27 if regexm(icd10,"C46") //1 change
replace siteiarc=28 if (regexm(icd10,"C47")|regexm(icd10,"C49")) //0 changes
replace siteiarc=29 if regexm(icd10,"C50") //72 changes
replace siteiarc=30 if regexm(icd10,"C51") //0 changes
replace siteiarc=31 if regexm(icd10,"C52") //2 changes
replace siteiarc=32 if regexm(icd10,"C53") //12 changes
replace siteiarc=33 if regexm(icd10,"C54") //21 changes
replace siteiarc=34 if regexm(icd10,"C55") //3 changes
replace siteiarc=35 if regexm(icd10,"C56") //1 change
replace siteiarc=36 if regexm(icd10,"C57") //0 changes
replace siteiarc=37 if regexm(icd10,"C58") //0 changes
replace siteiarc=38 if regexm(icd10,"C60") //2 changes
replace siteiarc=39 if regexm(icd10,"C61") //150 changes
replace siteiarc=40 if regexm(icd10,"C62") //0 changes
replace siteiarc=41 if regexm(icd10,"C63") //0 changes
replace siteiarc=42 if regexm(icd10,"C64") //11 changes
replace siteiarc=43 if regexm(icd10,"C65") //0 changes
replace siteiarc=44 if regexm(icd10,"C66") //0 changes
replace siteiarc=45 if regexm(icd10,"C67") //13 changes
replace siteiarc=46 if regexm(icd10,"C68") //0 changes
replace siteiarc=47 if regexm(icd10,"C69") //0 changes
replace siteiarc=48 if (regexm(icd10,"C70")|regexm(icd10,"C71")|regexm(icd10,"C72")) //0 changes
replace siteiarc=49 if regexm(icd10,"C73") //3 changes
replace siteiarc=50 if regexm(icd10,"C74") //0 changes
replace siteiarc=51 if regexm(icd10,"C75") //0 changes
replace siteiarc=52 if regexm(icd10,"C81") //2 changes
replace siteiarc=53 if (regexm(icd10,"C82")|regexm(icd10,"C83")|regexm(icd10,"C84")|regexm(icd10,"C85")|regexm(icd10,"C86")|regexm(icd10,"C96")) //18 changes
replace siteiarc=54 if regexm(icd10,"C88") //1 change
replace siteiarc=55 if regexm(icd10,"C90") //22 changes
replace siteiarc=56 if regexm(icd10,"C91") //5 changes
replace siteiarc=57 if (regexm(icd10,"C92")|regexm(icd10,"C93")|regexm(icd10,"C94")) //4 changes
replace siteiarc=58 if regexm(icd10,"C95") //3 changes
replace siteiarc=59 if regexm(icd10,"D47") //2 changes
replace siteiarc=60 if regexm(icd10,"D46") //1 change
replace siteiarc=61 if (regexm(icd10,"C26")|regexm(icd10,"C39")|regexm(icd10,"C48")|regexm(icd10,"C76")|regexm(icd10,"C80")) //57 changes
**replace siteiarc=62 if siteiarc<62
**replace siteiarc=63 if siteiarc<62 & siteiarc!=25
replace siteiarc=64 if regexm(icd10,"D06") //0 changes - no CIN 3 in death data

tab siteiarc ,m //none missing

** JC 24aug2022: compare site and siteiarc to ensure siteiarc is correct
count if site==19 //145 - some deaths whose primary=prostate have been coded to bone/lung (the prostate met site); JC checked 2013 death ds to ensure this error wasn't on there and it was not.
count if siteiarc==39 //150



//tab age_10 sex ,m
//tab siteiarc ,m //2013 data only has AR's siteiarc
//labelbook siteiarc_lab //2013 data only has AR's siteiarc

** proportions for Table 7 using IARC's siteiarc groupings
//tab siteiarc sex ,m
//tab siteiarc , m
//tab siteiarc if sex==2 ,m // female
//tab siteiarc if sex==1 ,m // male


** For annual report - Section 4: Mortality - Table 7a
** Below top 10 code added by JC for 2014
** All siteiarcs excl. O&U, insitu, non-reportable skin cancers - using IARC CI5's siteiarc groupings
preserve
drop if siteiarc==25|siteiarc==61|siteiarc==64 //64 deleted
bysort siteiarc: gen n=_N
bysort n siteiarc: gen tag=(_n==1)
replace tag = sum(tag)
sum tag , meanonly
gen top10 = (tag>=(`r(max)'-9))
sum n if tag==(`r(max)'-9), meanonly
replace top10 = 1 if n==`r(max)'
tab siteiarc top10 if top10!=0
contract siteiarc top10 if top10!=0, freq(count) percent(percentage)
gsort -count
drop top10
/*
siteiarc									count	percentage
Prostate (C61)								150		32.33
Breast (C50)								 72		15.52
Colon (C18)									 71		15.30
Lung (incl. trachea and bronchus) (C33-34)	 41		 8.84
Pancreas (C25)								 29		 6.25
Multiple myeloma (C90)						 22		 4.74
Corpus uteri (C54)							 21		 4.53
Rectum (C19-20)								 20		 4.31
Stomach (C16)								 20		 4.31
Non-Hodgkin lymphoma (C82-86,C96)			 18		 3.88
*/
total count //464

** JC update: Save these results as a dataset for reporting
replace siteiarc=2 if siteiarc==39
replace siteiarc=3 if siteiarc==29
replace siteiarc=4 if siteiarc==13
replace siteiarc=5 if siteiarc==21
replace siteiarc=6 if siteiarc==18
replace siteiarc=7 if siteiarc==55
replace siteiarc=8 if siteiarc==33
replace siteiarc=9 if siteiarc==14
replace siteiarc=10 if siteiarc==11
replace siteiarc=11 if siteiarc==53
rename siteiarc cancer_siteiarc
gen year=1
rename count number
	expand 2 in 1
	replace cancer_siteiarc=1 in 11
	replace number=651 in 11
	replace percentage=100 in 11

label define cancer_siteiarc_lab 1 "all" 2 "prostate" 3 "female breast" 4 "colon" 5 "lung" 6 "pancreas" 7 "multiple myeloma" 8 "corpus uteri" 9 "rectum" 10 "stomach" 11 "NHL" ,modify
label values cancer_siteiarc cancer_siteiarc_lab
label define year_lab 1 "2014" ,modify
label values year year_lab
sort cancer_siteiarc
gen rpt_id = _n
save "`datapath'\version09\2-working\ASMRs_wpp_2014" ,replace
restore

** proportions for Table 1 using IARC's siteiarc groupings
//tab siteiarc sex ,m
//tab siteiarc , m
//tab siteiarc if sex==2 ,m // female
//tab siteiarc if sex==1 ,m // male

************************************************************
* 4.3 MR age-standardised to WHO world pop_wppn - ALL siteiarcs
************************************************************

**********************************************************************************
** ASMR and 95% CI for Table 1 using AR's siteiarc groupings - using WHO World pop_wppn **
**********************************************************************************

** No need to recode sex as already 1=female; 2=male

********************************************************************
* (2.4c) MR age-standardised to WHO world pop_wppn - ALL TUMOURS
********************************************************************
** Using WHO World Standard pop_wppulation
//tab siteiarc ,m
//JC 19may2022: use age5 population and groupings for distrate per IH's + NS' recommendation
//JC 13jun2022: Above correction not performed - will perform in a separate dofile when using IH's rate calculation method
drop _merge
merge m:m sex age_10 using "`datapath'\version09\2-working\pop_wpp_2014-10"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                             2
        from master                         0  (_merge==1)
        from using                          2  (_merge==2)

    Matched                               651  (_merge==3)
    -----------------------------------------
*/
**drop if _merge==2 //do not drop these age groups as it skews pop_wpp 
** There are 2 unmatched records (_merge==2) since 2014 data doesn't have any cases of males + females with age range 0-14

tab age_10 ,m //none missing

gen case=1 if deathid!=. //do not generate case for missing age group 0-14 as it skews case total
gen pfu=1 // for % year if not whole year collected; not done for cancer

list deathid sex age_10 if _merge==2

list deathid sex age_10 if age_10==1 & (sex==1|sex==2) // age range 0-14 for female + male: change case=0 for age_10=1
replace case=0 if age_10==1 & (sex==1|sex==2) //2 changes

** SF requested by email & WhatsApp on 07-Jan-2020 age and sex specific rates for top 10 cancers
/*
What is age-specific mortality rate? 
Age-specific rates provide information on the mortality of a particular event in an age group relative to the total number of people at risk of that event in the same age group.

What is age-standardised mortality rate?
The age-standardized mortality rate is the summary rate that would have been observed, given the schedule of age-specific rates, in a population with the age composition of some reference population, often called the standard population.
*/
** AGE + SEX
preserve
collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex siteiarc)
gen mortrate=case/pop_wpp*100000
drop if siteiarc!=39 & siteiarc!=29 & siteiarc!=13 & siteiarc!=21 ///
		& siteiarc!=18 & siteiarc!=55 & siteiarc!=33 ///
		& siteiarc!=14 & siteiarc!=11 & siteiarc!=53
//by sex,sort: tab age_10 mortrate ,m
sort siteiarc age_10 sex
//list mortrate age_10 sex
//list mortrate age_10 sex if siteiarc==13

format mortrate %04.2f
gen year=2014
rename siteiarc cancer_siteiarc
rename mortrate age_specific_rate
drop pfu case pop_wpp
order year cancer_siteiarc sex age_10 age_specific_rate
save "`datapath'\version09\2-working\2014_top10mort_age+sex_rates" ,replace
restore

** AGE
preserve
collapse (sum) case (mean) pop_wpp, by(pfu age_10 siteiarc)
gen mortrate=case/pop_wpp*100000
drop if siteiarc!=39 & siteiarc!=29 & siteiarc!=13 & siteiarc!=21 ///
		& siteiarc!=18 & siteiarc!=55 & siteiarc!=33 ///
		& siteiarc!=14 & siteiarc!=11 & siteiarc!=53
//by sex,sort: tab age_10 mortrate ,m
sort siteiarc age_10
//list mortrate age_10 sex
//list mortrate age_10 sex if siteiarc==13

format mortrate %04.2f
gen year=2014
rename siteiarc cancer_siteiarc
rename mortrate age_specific_rate
drop pfu case pop_wpp
order year cancer_siteiarc age_10 age_specific_rate
save "`datapath'\version09\2-working\2014_top10mort_age_rates" ,replace
restore

** Check for missing age as these would need to be added to the median group for that siteiarc when assessing ASMRs to prevent creating an outlier
count if age==.|age==999 //2

list siteiarc age age_10 if age==.|age==999 //these are missing age_10: 0-14 so no change needed

tab pop_wpp age_10  if sex==1 //female
tab pop_wpp age_10  if sex==2 //male

** Next, MRs for all tumours
tab pop_wpp age_10
tab age_10 ,m //none missing

preserve
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
		
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR ALL TUMOURS - STD TO WHO WORLD pop_wppN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  651   284825   228.56    134.35   123.65   145.80     5.58 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(NDeath)
matrix number = r(NDeath)
matrix list r(adj)
matrix asmr = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asmr
svmat ci_lower
svmat ci_upper

collapse number asmr ci_lower ci_upper
rename number1 number 
rename asmr1 asmr 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asmr=round(asmr,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/651*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2014"
replace cancer_site=1 if cancer_site==.
replace year=1 if year==.
gen asmr_id="all" if rpt_id==.
replace rpt_id=1 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==1 & asmr_id==""
drop asmr_id
save "`datapath'\version09\2-working\ASMRs_wpp_2014" ,replace
restore

** PROSTATE
tab pop_wpp age_10 if siteiarc==39 //male

preserve
	drop if age_10==.
	keep if siteiarc==39 // 
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings: 
	** M 0-14,15-24,25-34,35-44
	
	expand 2 in 1
	replace sex=2 in 6
	replace age_10=1 in 6
	replace case=0 in 6
	replace pop_wpp=(27062) in 6
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 7
	replace age_10=2 in 7
	replace case=0 in 7
	replace pop_wpp=(19032) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=3 in 8
	replace case=0 in 8
	replace pop_wpp=(18491) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=4 in 9
	replace case=0 in 9
	replace pop_wpp=(19352) in 9
	sort age_10
			
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD pop_wppN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  150   137169   109.35     61.38    51.59    72.73     5.25 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(NDeath)
matrix number = r(NDeath)
matrix asmr = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asmr
svmat ci_lower
svmat ci_upper

collapse number asmr ci_lower ci_upper
rename number1 number 
rename asmr1 asmr 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asmr=round(asmr,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/651*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2014"
replace cancer_site=2 if cancer_site==.
replace year=1 if year==.
gen asmr_id="prost" if rpt_id==.
replace rpt_id=2 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==2 & asmr_id==""
drop asmr_id
save "`datapath'\version09\2-working\ASMRs_wpp_2014" ,replace
restore


** BREAST
tab pop_wpp age_10 if siteiarc==29 & sex==1 //female
tab pop_wpp age_10 if siteiarc==29 & sex==2 //male

preserve
//JC 19may2022: remove male breast cancers so rate calculated only based on female pop
//JC 13jun2022: above correction performed
	drop if sex==2
	drop if age_10==.
	keep if siteiarc==29 // breast only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex

	** now we have to add in the cases and pop_wppns for the missings: 
	** F 0-14,15-24
	
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

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BC (F) - STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   71   147656   48.08     29.56    22.69    38.02     3.79 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(NDeath)
matrix number = r(NDeath)
matrix asmr = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asmr
svmat ci_lower
svmat ci_upper

collapse number asmr ci_lower ci_upper
rename number1 number 
rename asmr1 asmr 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asmr=round(asmr,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/651*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2014"
replace cancer_site=3 if cancer_site==.
replace year=1 if year==.
gen asmr_id="fem.breast" if rpt_id==.
replace rpt_id=3 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==3 & asmr_id==""
drop asmr_id
save "`datapath'\version09\2-working\ASMRs_wpp_2014" ,replace
restore

** COLON 
tab pop_wpp age_10 if siteiarc==13 & sex==1 //female
tab pop_wpp age_10 if siteiarc==13 & sex==2 //male

preserve
	drop if age_10==.
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings: 
	** M&F 0-14,15-24,25-34
	** F 35-44
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_wpp=(25929) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 13
	replace age_10=1 in 13
	replace case=0 in 13
	replace pop_wpp=(27062) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_wpp=(18771) in 14
	sort age_10

	expand 2 in 1
	replace sex=2 in 15
	replace age_10=2 in 15
	replace case=0 in 15
	replace pop_wpp=(19032) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_wpp=(19088) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=3 in 17
	replace case=0 in 17
	replace pop_wpp=(18491) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=4 in 18
	replace case=0 in 18
	replace pop_wpp=(20526) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (M&F)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   71   284825   24.93     14.63    11.29    18.76     1.85 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(NDeath)
matrix number = r(NDeath)
matrix asmr = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asmr
svmat ci_lower
svmat ci_upper

collapse number asmr ci_lower ci_upper
rename number1 number 
rename asmr1 asmr 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asmr=round(asmr,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/651*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2014"
replace cancer_site=4 if cancer_site==.
replace year=1 if year==.
gen asmr_id="colon" if rpt_id==.
replace rpt_id=4 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==4 & asmr_id==""
drop asmr_id
save "`datapath'\version09\2-working\ASMRs_wpp_2014" ,replace
restore

** LUNG
tab pop_wpp age_10 if siteiarc==21 & sex==1 //female
tab pop_wpp age_10 if siteiarc==21 & sex==2 //male

preserve
	drop if age_10==.
	keep if siteiarc==21
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and pops for the missings: 
	** M&F 0-14,15-24
	** M 25-34,35-44
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=1 in 13
	replace case=0 in 13
	replace pop_wpp=(25929) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(27062) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=2 in 15
	replace case=0 in 15
	replace pop_wpp=(18771) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_wpp=(19032) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=3 in 17
	replace case=0 in 17
	replace pop_wpp=(18491) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=4 in 18
	replace case=0 in 18
	replace pop_wpp=(19352) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR LUNG CANCER (M&F)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   41   284825   14.39      9.13     6.46    12.64     1.52 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(NDeath)
matrix number = r(NDeath)
matrix asmr = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asmr
svmat ci_lower
svmat ci_upper

collapse number asmr ci_lower ci_upper
rename number1 number 
rename asmr1 asmr 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asmr=round(asmr,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/651*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2014"
replace cancer_site=5 if cancer_site==.
replace year=1 if year==.
gen asmr_id="lung" if rpt_id==.
replace rpt_id=5 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==5 & asmr_id==""
drop asmr_id
save "`datapath'\version09\2-working\ASMRs_wpp_2014" ,replace
restore

** PANCREAS
tab pop_wpp age_10 if siteiarc==18 & sex==1 //female
tab pop_wpp age_10 if siteiarc==18 & sex==2 //male

preserve
	drop if age_10==.
	keep if siteiarc==18
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings: 
	** M&F 0-14,25-34,45-54
	** M 15-24
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_wpp=(25929) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 13
	replace age_10=1 in 13
	replace case=0 in 13
	replace pop_wpp=(27062) in 13
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

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PANCREATIC CANCER (M&F)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   29   284825   10.18      6.20     4.04     9.20     1.26 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(NDeath)
matrix number = r(NDeath)
matrix asmr = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asmr
svmat ci_lower
svmat ci_upper

collapse number asmr ci_lower ci_upper
rename number1 number 
rename asmr1 asmr 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asmr=round(asmr,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/651*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2014"
replace cancer_site=6 if cancer_site==.
replace year=1 if year==.
gen asmr_id="panc" if rpt_id==.
replace rpt_id=6 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==6 & asmr_id==""
drop asmr_id
save "`datapath'\version09\2-working\ASMRs_wpp_2014" ,replace
restore

** MULTIPLE MYELOMA
tab pop_wpp age_10 if siteiarc==55 & sex==1 //female
tab pop_wpp age_10 if siteiarc==55 & sex==2 //male

preserve
	drop if age_10==.
	keep if siteiarc==55
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings: 
	** M&F 0-14,15-24,25-34,35-44
	
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
	replace sex=1 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_wpp=(20526) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=4 in 18
	replace case=0 in 18
	replace pop_wpp=(19352) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR MULTIPLE MYELOMA (M&F)- STD TO WHO WORLD pop_wppN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   22   284825    7.72      4.76     2.95     7.42     1.09 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(NDeath)
matrix number = r(NDeath)
matrix asmr = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asmr
svmat ci_lower
svmat ci_upper

collapse number asmr ci_lower ci_upper
rename number1 number 
rename asmr1 asmr 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asmr=round(asmr,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/651*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2014"
replace cancer_site=7 if cancer_site==.
replace year=1 if year==.
gen asmr_id="MM" if rpt_id==.
replace rpt_id=7 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==7 & asmr_id==""
drop asmr_id
save "`datapath'\version09\2-working\ASMRs_wpp_2014" ,replace
restore

** CORPUS UTERI
tab pop_wpp age_10 if siteiarc==33

preserve
	drop if age_10==.
	keep if siteiarc==33
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings: 
	** F 0-14,15-24,25-34,45-54
	
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
	replace age_10=3 in 8
	replace case=0 in 8
	replace pop_wpp=(19088) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=5 in 9
	replace case=0 in 9
	replace pop_wpp=(21757) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CORPUS UTERI (WOMEN)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   21   147656   14.22      8.62     5.21    13.67     2.06 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(NDeath)
matrix number = r(NDeath)
matrix asmr = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asmr
svmat ci_lower
svmat ci_upper

collapse number asmr ci_lower ci_upper
rename number1 number 
rename asmr1 asmr 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asmr=round(asmr,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/651*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2014"
replace cancer_site=8 if cancer_site==.
replace year=1 if year==.
gen asmr_id="corpus" if rpt_id==.
replace rpt_id=8 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==8 & asmr_id==""
drop asmr_id
save "`datapath'\version09\2-working\ASMRs_wpp_2014" ,replace
restore

** RECTUM
tab pop_wpp age_10 if siteiarc==14 & sex==1 //female
tab pop_wpp age_10 if siteiarc==14 & sex==2 //male

preserve
	drop if age_10==.
	keep if siteiarc==14
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings: 
	** M&F 0-14,15-24,35-44
	** F   25-34,65-74
	** M   45-54,85+
	
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
	replace age_10=7 in 17
	replace case=0 in 17
	replace pop_wpp=(11723) in 17
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

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RECTAL CANCER (M&F)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   20   284825    7.02      4.30     2.54     6.91     1.07 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(NDeath)
matrix number = r(NDeath)
matrix asmr = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asmr
svmat ci_lower
svmat ci_upper

collapse number asmr ci_lower ci_upper
rename number1 number 
rename asmr1 asmr 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asmr=round(asmr,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/651*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2014"
replace cancer_site=9 if cancer_site==.
replace year=1 if year==.
gen asmr_id="rect" if rpt_id==.
replace rpt_id=9 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==9 & asmr_id==""
drop asmr_id
save "`datapath'\version09\2-working\ASMRs_wpp_2014" ,replace
restore

** STOMACH
tab pop_wpp age_10 if siteiarc==11 & sex==1 //female
tab pop_wpp age_10 if siteiarc==11 & sex==2 //male

preserve
	drop if age_10==.
	keep if siteiarc==11
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings: 
	** M&F 0-14,15-24,25-34,35-44,45-54
	** M   55-64
	** F   65-74
	
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
	replace age_10=5 in 16
	replace case=0 in 16
	replace pop_wpp=(19547) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=6 in 17
	replace case=0 in 17
	replace pop_wpp=(16091) in 17
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

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR STOMACH CANCER (M&F)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   20   284825    7.02      3.53     2.10     5.77     0.89 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(NDeath)
matrix number = r(NDeath)
matrix asmr = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asmr
svmat ci_lower
svmat ci_upper

collapse number asmr ci_lower ci_upper
rename number1 number 
rename asmr1 asmr 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asmr=round(asmr,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/651*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2014"
replace cancer_site=10 if cancer_site==.
replace year=1 if year==.
gen asmr_id="stom" if rpt_id==.
replace rpt_id=10 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==10 & asmr_id==""
drop asmr_id
save "`datapath'\version09\2-working\ASMRs_wpp_2014" ,replace
restore


** NON-HODGKIN LYMPHOMA
tab pop_wpp age_10 if siteiarc==53 & sex==1 //female
tab pop_wpp age_10 if siteiarc==53 & sex==2 //male

preserve
	drop if age_10==.
	keep if siteiarc==53
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings: 
	** M&F 0-14,25-34
	** F 15-24,35-44,45-54,55-64,65-74
	
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
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_wpp=(20526) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=5 in 16
	replace case=0 in 16
	replace pop_wpp=(21757) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=6 in 17
	replace case=0 in 17
	replace pop_wpp=(18343) in 17
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

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR NHL (M&F)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   18   284825    6.32      4.25     2.40     7.03     1.13 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(NDeath)
matrix number = r(NDeath)
matrix asmr = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asmr
svmat ci_lower
svmat ci_upper

collapse number asmr ci_lower ci_upper
rename number1 number 
rename asmr1 asmr 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asmr=round(asmr,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/651*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2014"
replace cancer_site=11 if cancer_site==.
replace year=1 if year==.
gen asmr_id="nhl" if rpt_id==.
replace rpt_id=11 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==11 & asmr_id==""
drop asmr_id rpt_id
format asmr %04.2f
format percentage %04.1f
save "`datapath'\version09\2-working\ASMRs_wpp_2014" ,replace
restore

label data "BNR MORTALITY rates 2014"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version09\3-output\2014_analysis mort_wpp" ,replace
note: TS This dataset includes patients with multiple eligible cancer causes of death; used WPP population
