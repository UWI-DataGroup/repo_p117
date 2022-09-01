** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          10b_analysis mort_ASMRs_2014_age5.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      31-AUG-2022
    // 	date last modified      31-AUG-2022
    //  algorithm task          Analyzing combined cancer dataset: (1) Numbers (2) ASMRs
    //  status                  Completed
    //  objective               To have one dataset with cleaned and grouped 2014 death data for inclusion in 2016-2018 cancer report.
	//	methods					(1) Using 5-year age groups instead of 10-year
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
    log using "`logpath'\10b_analysis mort_ASMRs_2014_age5.smcl", replace
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
tab age5 sex ,m
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



//tab age5 sex ,m
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
rename siteiarc cancer_site
gen year=2
rename count number
	expand 2 in 1
	replace cancer_site=1 in 11
	replace number=651 in 11
	replace percentage=100 in 11

label define cancer_site_lab 1 "all" 2 "prostate" 3 "female breast" 4 "colon" 5 "lung" 6 "pancreas" 7 "multiple myeloma" 8 "corpus uteri" 9 "rectum" 10 "stomach" 11 "non-hodgkin lymphoma" ,modify
label values cancer_site cancer_site_lab
label define year_lab 1 "2013" 2 "2014" 3 "2015" 4 "2016" 5 "2017" 6 "2018" 7 "2019" 8 "2020" 9 "2021" ,modify
label values year year_lab
sort cancer_site
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
merge m:m sex age5 using "`datapath'\version09\2-working\pop_wpp_2014-5"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                             6
        from master                         0  (_merge==1)
        from using                          6  (_merge==2)

    Matched                               651  (_merge==3)
    -----------------------------------------
*/
**drop if _merge==2 //do not drop these age groups as it skews pop_wpp 
** There are 6 unmatched records (_merge==2) since 2014 data doesn't have any cases of 0-4 female + male; 5-9 female + male; 10-14 female + male

tab age5 ,m //none missing

gen case=1 if deathid!=. //do not generate case for missing age group 0-14 as it skews case total
gen pfu=1 // for % year if not whole year collected; not done for cancer

list deathid sex age5 if _merge==2
list deathid sex age5 if _merge==2 ,nolabel

list deathid sex age5 if age5==1 & (sex==1|sex==2)|age5==2 & (sex==1|sex==2)|age5==3 & (sex==1|sex==2)
replace case=0 if age5==1 & (sex==1|sex==2)|age5==2 & (sex==1|sex==2)|age5==3 & (sex==1|sex==2) //6 changes

** SF requested by email & WhatsApp on 07-Jan-2020 age and sex specific rates for top 10 cancers
/*
What is age-specific mortality rate? 
Age-specific rates provide information on the mortality of a particular event in an age group relative to the total number of people at risk of that event in the same age group.

What is age-standardised mortality rate?
The age-standardized mortality rate is the summary rate that would have been observed, given the schedule of age-specific rates, in a population with the age composition of some reference population, often called the standard population.
*/
** AGE + SEX
preserve
collapse (sum) case (mean) pop_wpp, by(pfu age5 sex siteiarc)
gen mortrate=case/pop_wpp*100000
drop if siteiarc!=39 & siteiarc!=29 & siteiarc!=13 & siteiarc!=21 ///
		& siteiarc!=18 & siteiarc!=55 & siteiarc!=33 ///
		& siteiarc!=14 & siteiarc!=11 & siteiarc!=53
//by sex,sort: tab age5 mortrate ,m
sort siteiarc age5 sex
//list mortrate age5 sex
//list mortrate age5 sex if siteiarc==13

format mortrate %04.2f
gen year=2014
rename siteiarc cancer_site
rename mortrate age_specific_rate
drop pfu case pop_wpp
order year cancer_site sex age5 age_specific_rate
save "`datapath'\version09\2-working\2014_top10mort_age+sex_rates" ,replace
restore

** AGE
preserve
collapse (sum) case (mean) pop_wpp, by(pfu age5 siteiarc)
gen mortrate=case/pop_wpp*100000
drop if siteiarc!=39 & siteiarc!=29 & siteiarc!=13 & siteiarc!=21 ///
		& siteiarc!=18 & siteiarc!=55 & siteiarc!=33 ///
		& siteiarc!=14 & siteiarc!=11 & siteiarc!=53
//by sex,sort: tab age5 mortrate ,m
sort siteiarc age5
//list mortrate age5 sex
//list mortrate age5 sex if siteiarc==13

format mortrate %04.2f
gen year=2014
rename siteiarc cancer_site
rename mortrate age_specific_rate
drop pfu case pop_wpp
order year cancer_site age5 age_specific_rate
save "`datapath'\version09\2-working\2014_top10mort_age_rates" ,replace
restore

** Check for missing age as these would need to be added to the median group for that siteiarc when assessing ASMRs to prevent creating an outlier
count if age==.|age==999 //6

list siteiarc age age5 if age==.|age==999 //these are missing age5 so no change needed

tab pop_wpp age5  if sex==1 //female
tab pop_wpp age5  if sex==2 //male

** Need an easier method for referencing population totals by sex instead of using Notepad as age5 has more groupings than using age5 so can create the below ds and save to Notepad
preserve
contract sex pop_wpp age5
gen age5_id=age5
order sex age5_id age5 pop_wpp
drop _freq
sort sex age5_id
total pop_wpp
restore


** Next, MRs for all tumours
tab pop_wpp age5
tab age5 ,m //none missing

preserve
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
		
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR ALL TUMOURS - STD TO WHO WORLD pop_wppN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  651   284825   228.56    132.89   122.29   144.26     5.53 |
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
replace year=2 if year==.
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
tab pop_wpp age5 if siteiarc==39 //male

preserve
	drop if age5==.
	keep if siteiarc==39 // 
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings: 
	** M 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39
	expand 2 in 1
	replace sex=2 in 10
	replace age5=1 in 10
	replace case=0 in 10
	replace pop_wpp=(8055) in 10
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 11
	replace age5=2 in 11
	replace case=0 in 11
	replace pop_wpp=(9178) in 11
	sort age5
	
	expand 2 in 1
	replace sex=2 in 12
	replace age5=3 in 12
	replace case=0 in 12
	replace pop_wpp=(9829) in 12
	sort age5
	
	expand 2 in 1
	replace sex=2 in 13
	replace age5=4 in 13
	replace case=0 in 13
	replace pop_wpp=(9598) in 13
	sort age5
	
	expand 2 in 1
	replace sex=2 in 14
	replace age5=5 in 14
	replace case=0 in 14
	replace pop_wpp=(9434) in 14
	sort age5
	
	expand 2 in 1
	replace sex=2 in 15
	replace age5=6 in 15
	replace case=0 in 15
	replace pop_wpp=(9115) in 15
	sort age5
	
	expand 2 in 1
	replace sex=2 in 16
	replace age5=7 in 16
	replace case=0 in 16
	replace pop_wpp=(9376) in 16
	sort age5
	
	expand 2 in 1
	replace sex=2 in 17
	replace age5=8 in 17
	replace case=0 in 17
	replace pop_wpp=(9425) in 17
	sort age5
	
	expand 2 in 1
	replace sex=2 in 18
	replace age5=9 in 18
	replace case=0 in 18
	replace pop_wpp=(9927) in 18
	sort age5
			
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD pop_wppN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  150   137169   109.35     60.61    50.94    71.89     5.20 |
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
replace year=2 if year==.
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
tab pop_wpp age5 if siteiarc==29 & sex==1 //female
tab pop_wpp age5 if siteiarc==29 & sex==2 //male

preserve
//JC 19may2022: remove male breast cancers so rate calculated only based on female pop
//JC 13jun2022: above correction performed
	drop if sex==2
	drop if age5==.
	keep if siteiarc==29 // breast only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex

	** now we have to add in the cases and pop_wppns for the missings:  
	** F 0-4,5-9,10-14,15-19,20-24
	expand 2 in 1
	replace sex=1 in 14
	replace age5=1 in 14
	replace case=0 in 14
	replace pop_wpp=(7807) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=2 in 15
	replace case=0 in 15
	replace pop_wpp=(8818) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=3 in 16
	replace case=0 in 16
	replace pop_wpp=(9304) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=4 in 17
	replace case=0 in 17
	replace pop_wpp=(9336) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=5 in 18
	replace case=0 in 18
	replace pop_wpp=(9435) in 18
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BC (F) - STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   71   147656   48.08     29.43    22.61    37.90     3.77 |
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
replace year=2 if year==.
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
tab pop_wpp age5 if siteiarc==13 & sex==1 //female
tab pop_wpp age5 if siteiarc==13 & sex==2 //male

preserve
	drop if age5==.
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings:
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34
	** F   35-39,40-44,45-49
	** M   45-49
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=1 in 19
	replace case=0 in 19
	replace pop_wpp=(7807) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=2 in 20
	replace case=0 in 20
	replace pop_wpp=(8818) in 20
	sort age5

	expand 2 in 1
	replace sex=1 in 21
	replace age5=3 in 21
	replace case=0 in 21
	replace pop_wpp=(9304) in 21
	sort age5

	expand 2 in 1
	replace sex=1 in 22
	replace age5=4 in 22
	replace case=0 in 22
	replace pop_wpp=(9336) in 22
	sort age5

	expand 2 in 1
	replace sex=1 in 23
	replace age5=5 in 23
	replace case=0 in 23
	replace pop_wpp=(9435) in 23
	sort age5

	expand 2 in 1
	replace sex=1 in 24
	replace age5=6 in 24
	replace case=0 in 24
	replace pop_wpp=(9240) in 24
	sort age5

	expand 2 in 1
	replace sex=1 in 25
	replace age5=7 in 25
	replace case=0 in 25
	replace pop_wpp=(9848) in 25
	sort age5
	
	expand 2 in 1
	replace sex=1 in 26
	replace age5=8 in 26
	replace case=0 in 26
	replace pop_wpp=(9820) in 26
	sort age5
	
	expand 2 in 1
	replace sex=1 in 27
	replace age5=9 in 27
	replace case=0 in 27
	replace pop_wpp=(10706) in 27
	sort age5
	
	expand 2 in 1
	replace sex=1 in 28
	replace age5=10 in 28
	replace case=0 in 28
	replace pop_wpp=(10559) in 28
	sort age5
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=1 in 29
	replace case=0 in 29
	replace pop_wpp=(8055) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=2 in 30
	replace case=0 in 30
	replace pop_wpp=(9178) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=3 in 31
	replace case=0 in 31
	replace pop_wpp=(9829) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=4 in 32
	replace case=0 in 32
	replace pop_wpp=(9598) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=5 in 33
	replace case=0 in 33
	replace pop_wpp=(9434) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=6 in 34
	replace case=0 in 34
	replace pop_wpp=(9115) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=7 in 35
	replace case=0 in 35
	replace pop_wpp=(9376) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=10 in 36
	replace case=0 in 36
	replace pop_wpp=(9690) in 36
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (M&F)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   71   284825   24.93     14.53    11.22    18.67     1.84 |
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
replace year=2 if year==.
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
tab pop_wpp age5 if siteiarc==21 & sex==1 //female
tab pop_wpp age5 if siteiarc==21 & sex==2 //male

preserve
	drop if age5==.
	keep if siteiarc==21
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and pops for the missings: 
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,35-39,75-79
	** F   50-54
	** M   30-34,40-44
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=1 in 18
	replace case=0 in 18
	replace pop_wpp=(7807) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=2 in 19
	replace case=0 in 19
	replace pop_wpp=(8818) in 19
	sort age5

	expand 2 in 1
	replace sex=1 in 20
	replace age5=3 in 20
	replace case=0 in 20
	replace pop_wpp=(9304) in 20
	sort age5

	expand 2 in 1
	replace sex=1 in 21
	replace age5=4 in 21
	replace case=0 in 21
	replace pop_wpp=(9336) in 21
	sort age5

	expand 2 in 1
	replace sex=1 in 22
	replace age5=5 in 22
	replace case=0 in 22
	replace pop_wpp=(9435) in 22
	sort age5

	expand 2 in 1
	replace sex=1 in 23
	replace age5=6 in 23
	replace case=0 in 23
	replace pop_wpp=(9240) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=8 in 24
	replace case=0 in 24
	replace pop_wpp=(9820) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=11 in 25
	replace case=0 in 25
	replace pop_wpp=(11198) in 25
	sort age5
	
	expand 2 in 1
	replace sex=1 in 26
	replace age5=16 in 26
	replace case=0 in 26
	replace pop_wpp=(4273) in 26
	sort age5
	
	expand 2 in 1
	replace sex=2 in 27
	replace age5=1 in 27
	replace case=0 in 27
	replace pop_wpp=(8055) in 27
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=2 in 28
	replace case=0 in 28
	replace pop_wpp=(9178) in 28
	sort age5
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=3 in 29
	replace case=0 in 29
	replace pop_wpp=(9829) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=4 in 30
	replace case=0 in 30
	replace pop_wpp=(9598) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=5 in 31
	replace case=0 in 31
	replace pop_wpp=(9434) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=6 in 32
	replace case=0 in 32
	replace pop_wpp=(9115) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=7 in 33
	replace case=0 in 33
	replace pop_wpp=(9376) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=8 in 34
	replace case=0 in 34
	replace pop_wpp=(9425) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=9 in 35
	replace case=0 in 35
	replace pop_wpp=(9927) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=16 in 36
	replace case=0 in 36
	replace pop_wpp=(3233) in 36
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR LUNG CANCER (M&F)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   41   284825   14.39      9.00     6.36    12.50     1.51 |
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
replace year=2 if year==.
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
tab pop_wpp age5 if siteiarc==18 & sex==1 //female
tab pop_wpp age5 if siteiarc==18 & sex==2 //male

preserve
	drop if age5==.
	keep if siteiarc==18
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings:
	** M&F 0-4,5-9,10-14,20-24,25-29,30-34,45-49
	** F   40-44,50-54,60-64
	** M   15-19,35-39,50-54
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=1 in 17
	replace case=0 in 17
	replace pop_wpp=(7807) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=2 in 18
	replace case=0 in 18
	replace pop_wpp=(8818) in 18
	sort age5

	expand 2 in 1
	replace sex=1 in 19
	replace age5=3 in 19
	replace case=0 in 19
	replace pop_wpp=(9304) in 19
	sort age5

	expand 2 in 1
	replace sex=1 in 20
	replace age5=5 in 20
	replace case=0 in 20
	replace pop_wpp=(9435) in 20
	sort age5

	expand 2 in 1
	replace sex=1 in 21
	replace age5=6 in 21
	replace case=0 in 21
	replace pop_wpp=(9240) in 21
	sort age5

	expand 2 in 1
	replace sex=1 in 22
	replace age5=7 in 22
	replace case=0 in 22
	replace pop_wpp=(9848) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=9 in 23
	replace case=0 in 23
	replace pop_wpp=(10706) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=10 in 24
	replace case=0 in 24
	replace pop_wpp=(10559) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=11 in 25
	replace case=0 in 25
	replace pop_wpp=(11198) in 25
	sort age5
	
	expand 2 in 1
	replace sex=1 in 26
	replace age5=13 in 26
	replace case=0 in 26
	replace pop_wpp=(8207) in 26
	sort age5
	
	expand 2 in 1
	replace sex=2 in 27
	replace age5=1 in 27
	replace case=0 in 27
	replace pop_wpp=(8055) in 27
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=2 in 28
	replace case=0 in 28
	replace pop_wpp=(9178) in 28
	sort age5
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=3 in 29
	replace case=0 in 29
	replace pop_wpp=(9829) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=4 in 30
	replace case=0 in 30
	replace pop_wpp=(9598) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=5 in 31
	replace case=0 in 31
	replace pop_wpp=(9434) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=6 in 32
	replace case=0 in 32
	replace pop_wpp=(9115) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=7 in 33
	replace case=0 in 33
	replace pop_wpp=(9376) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=8 in 34
	replace case=0 in 34
	replace pop_wpp=(9425) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=10 in 35
	replace case=0 in 35
	replace pop_wpp=(9690) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=11 in 36
	replace case=0 in 36
	replace pop_wpp=(9857) in 36
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PANCREATIC CANCER (M&F)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   29   284825   10.18      6.16     4.01     9.20     1.27 |
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
replace year=2 if year==.
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
tab pop_wpp age5 if siteiarc==55 & sex==1 //female
tab pop_wpp age5 if siteiarc==55 & sex==2 //male

preserve
	drop if age5==.
	keep if siteiarc==55
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings:
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,40-44,45-49
	** F   
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=1 in 16
	replace case=0 in 16
	replace pop_wpp=(7807) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=2 in 17
	replace case=0 in 17
	replace pop_wpp=(8818) in 17
	sort age5

	expand 2 in 1
	replace sex=1 in 18
	replace age5=3 in 18
	replace case=0 in 18
	replace pop_wpp=(9304) in 18
	sort age5

	expand 2 in 1
	replace sex=1 in 19
	replace age5=4 in 19
	replace case=0 in 19
	replace pop_wpp=(9336) in 19
	sort age5

	expand 2 in 1
	replace sex=1 in 20
	replace age5=5 in 20
	replace case=0 in 20
	replace pop_wpp=(9435) in 20
	sort age5

	expand 2 in 1
	replace sex=1 in 21
	replace age5=6 in 21
	replace case=0 in 21
	replace pop_wpp=(9240) in 21
	sort age5

	expand 2 in 1
	replace sex=1 in 22
	replace age5=7 in 22
	replace case=0 in 22
	replace pop_wpp=(9848) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=8 in 23
	replace case=0 in 23
	replace pop_wpp=(9820) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=9 in 24
	replace case=0 in 24
	replace pop_wpp=(10706) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=10 in 25
	replace case=0 in 25
	replace pop_wpp=(10559) in 25
	sort age5
	
	expand 2 in 1
	replace sex=2 in 26
	replace age5=1 in 26
	replace case=0 in 26
	replace pop_wpp=(8055) in 26
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 27
	replace age5=2 in 27
	replace case=0 in 27
	replace pop_wpp=(9178) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=3 in 28
	replace case=0 in 28
	replace pop_wpp=(9829) in 28
	sort age5
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=4 in 29
	replace case=0 in 29
	replace pop_wpp=(9598) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=5 in 30
	replace case=0 in 30
	replace pop_wpp=(9434) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=6 in 31
	replace case=0 in 31
	replace pop_wpp=(9115) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=7 in 32
	replace case=0 in 32
	replace pop_wpp=(9376) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=8 in 33
	replace case=0 in 33
	replace pop_wpp=(9425) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=9 in 34
	replace case=0 in 34
	replace pop_wpp=(9927) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=10 in 35
	replace case=0 in 35
	replace pop_wpp=(9690) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=17 in 36
	replace case=0 in 36
	replace pop_wpp=(2198) in 36
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR MULTIPLE MYELOMA (M&F)- STD TO WHO WORLD pop_wppN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   22   284825    7.72      4.78     2.97     7.48     1.10 |
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
replace year=2 if year==.
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
tab pop_wpp age5 if siteiarc==33

preserve
	drop if age5==.
	keep if siteiarc==33
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings: 
	** F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,45-49
	
	expand 2 in 1
	replace sex=1 in 9
	replace age5=1 in 9
	replace case=0 in 9
	replace pop_wpp=(7807) in 9
	sort age5
	
	expand 2 in 1
	replace sex=1 in 10
	replace age5=2 in 10
	replace case=0 in 10
	replace pop_wpp=(8818) in 10
	sort age5

	expand 2 in 1
	replace sex=1 in 11
	replace age5=3 in 11
	replace case=0 in 11
	replace pop_wpp=(9304) in 11
	sort age5

	expand 2 in 1
	replace sex=1 in 12
	replace age5=4 in 12
	replace case=0 in 12
	replace pop_wpp=(9336) in 12
	sort age5

	expand 2 in 1
	replace sex=1 in 13
	replace age5=5 in 13
	replace case=0 in 13
	replace pop_wpp=(9435) in 13
	sort age5

	expand 2 in 1
	replace sex=1 in 14
	replace age5=6 in 14
	replace case=0 in 14
	replace pop_wpp=(9240) in 14
	sort age5

	expand 2 in 1
	replace sex=1 in 15
	replace age5=7 in 15
	replace case=0 in 15
	replace pop_wpp=(9848) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=8 in 16
	replace case=0 in 16
	replace pop_wpp=(9820) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=10 in 17
	replace case=0 in 17
	replace pop_wpp=(10559) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=11 in 18
	replace case=0 in 18
	replace pop_wpp=(11198) in 18
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CORPUS UTERI (WOMEN)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   21   147656   14.22      8.38     5.07    13.40     2.03 |
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
replace year=2 if year==.
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
tab pop_wpp age5 if siteiarc==14 & sex==1 //female
tab pop_wpp age5 if siteiarc==14 & sex==2 //male

preserve
	drop if age5==.
	keep if siteiarc==14
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings:
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,35-39,40-44,50-54
	** F   30-34,65-69,70-74,80-84
	** M   45-49,75-79,85+
	
	expand 2 in 1
	replace sex=1 in 11
	replace age5=1 in 11
	replace case=0 in 11
	replace pop_wpp=(7807) in 11
	sort age5
	
	expand 2 in 1
	replace sex=1 in 12
	replace age5=2 in 12
	replace case=0 in 12
	replace pop_wpp=(8818) in 12
	sort age5

	expand 2 in 1
	replace sex=1 in 13
	replace age5=3 in 13
	replace case=0 in 13
	replace pop_wpp=(9304) in 13
	sort age5

	expand 2 in 1
	replace sex=1 in 14
	replace age5=4 in 14
	replace case=0 in 14
	replace pop_wpp=(9336) in 14
	sort age5

	expand 2 in 1
	replace sex=1 in 15
	replace age5=5 in 15
	replace case=0 in 15
	replace pop_wpp=(9435) in 15
	sort age5

	expand 2 in 1
	replace sex=1 in 16
	replace age5=6 in 16
	replace case=0 in 16
	replace pop_wpp=(9240) in 16
	sort age5

	expand 2 in 1
	replace sex=1 in 17
	replace age5=7 in 17
	replace case=0 in 17
	replace pop_wpp=(9848) in 17
	sort age5

	expand 2 in 1
	replace sex=1 in 18
	replace age5=8 in 18
	replace case=0 in 18
	replace pop_wpp=(9820) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=9 in 19
	replace case=0 in 19
	replace pop_wpp=(10706) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=11 in 20
	replace case=0 in 20
	replace pop_wpp=(11198) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=14 in 21
	replace case=0 in 21
	replace pop_wpp=(6598) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=15 in 22
	replace case=0 in 22
	replace pop_wpp=(5125) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=17 in 23
	replace case=0 in 23
	replace pop_wpp=(3272) in 23
	sort age5
	
	expand 2 in 1
	replace sex=2 in 24
	replace age5=1 in 24
	replace case=0 in 24
	replace pop_wpp=(8055) in 24
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 25
	replace age5=2 in 25
	replace case=0 in 25
	replace pop_wpp=(9178) in 25
	sort age5
	
	expand 2 in 1
	replace sex=2 in 26
	replace age5=3 in 26
	replace case=0 in 26
	replace pop_wpp=(9829) in 26
	sort age5
	
	expand 2 in 1
	replace sex=2 in 27
	replace age5=4 in 27
	replace case=0 in 27
	replace pop_wpp=(9598) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=5 in 28
	replace case=0 in 28
	replace pop_wpp=(9434) in 28
	sort age5
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=6 in 29
	replace case=0 in 29
	replace pop_wpp=(9115) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=8 in 30
	replace case=0 in 30
	replace pop_wpp=(9425) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=9 in 31
	replace case=0 in 31
	replace pop_wpp=(9927) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=10 in 32
	replace case=0 in 32
	replace pop_wpp=(9690) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=11 in 33
	replace case=0 in 33
	replace pop_wpp=(9857) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=13 in 34
	replace case=0 in 34
	replace pop_wpp=(7232) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=16 in 35
	replace case=0 in 35
	replace pop_wpp=(3233) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=18 in 36
	replace case=0 in 36
	replace pop_wpp=(2483) in 36
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RECTAL CANCER (M&F)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   20   284825    7.02      4.31     2.55     6.96     1.07 |
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
replace year=2 if year==.
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
tab pop_wpp age5 if siteiarc==11 & sex==1 //female
tab pop_wpp age5 if siteiarc==11 & sex==2 //male

preserve
	drop if age5==.
	keep if siteiarc==11
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings:
	** M&F  0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,40-44,45-49,50-54,55-59
	** F 	65-69,70-74
	** M	60-64
	
	expand 2 in 1
	replace sex=1 in 10
	replace age5=1 in 10
	replace case=0 in 10
	replace pop_wpp=(7807) in 10
	sort age5
	
	expand 2 in 1
	replace sex=1 in 11
	replace age5=2 in 11
	replace case=0 in 11
	replace pop_wpp=(8818) in 11
	sort age5

	expand 2 in 1
	replace sex=1 in 12
	replace age5=3 in 12
	replace case=0 in 12
	replace pop_wpp=(9304) in 12
	sort age5

	expand 2 in 1
	replace sex=1 in 13
	replace age5=4 in 13
	replace case=0 in 13
	replace pop_wpp=(9336) in 13
	sort age5

	expand 2 in 1
	replace sex=1 in 14
	replace age5=5 in 14
	replace case=0 in 14
	replace pop_wpp=(9435) in 14
	sort age5

	expand 2 in 1
	replace sex=1 in 15
	replace age5=6 in 15
	replace case=0 in 15
	replace pop_wpp=(9240) in 15
	sort age5

	expand 2 in 1
	replace sex=1 in 16
	replace age5=7 in 16
	replace case=0 in 16
	replace pop_wpp=(9848) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=8 in 17
	replace case=0 in 17
	replace pop_wpp=(9820) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=9 in 18
	replace case=0 in 18
	replace pop_wpp=(10706) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=10 in 19
	replace case=0 in 19
	replace pop_wpp=(10559) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=11 in 20
	replace case=0 in 20
	replace pop_wpp=(11198) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=12 in 21
	replace case=0 in 21
	replace pop_wpp=(10136) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=14 in 22
	replace case=0 in 22
	replace pop_wpp=(6598) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=15 in 23
	replace case=0 in 23
	replace pop_wpp=(5125) in 23
	sort age5
	
	expand 2 in 1
	replace sex=2 in 24
	replace age5=1 in 24
	replace case=0 in 24
	replace pop_wpp=(8055) in 24
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 25
	replace age5=2 in 25
	replace case=0 in 25
	replace pop_wpp=(9178) in 25
	sort age5
	
	expand 2 in 1
	replace sex=2 in 26
	replace age5=3 in 26
	replace case=0 in 26
	replace pop_wpp=(9829) in 26
	sort age5
	
	expand 2 in 1
	replace sex=2 in 27
	replace age5=4 in 27
	replace case=0 in 27
	replace pop_wpp=(9598) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=5 in 28
	replace case=0 in 28
	replace pop_wpp=(9434) in 28
	sort age5
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=6 in 29
	replace case=0 in 29
	replace pop_wpp=(9115) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=7 in 30
	replace case=0 in 30
	replace pop_wpp=(9376) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=8 in 31
	replace case=0 in 31
	replace pop_wpp=(9425) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=9 in 32
	replace case=0 in 32
	replace pop_wpp=(9927) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=10 in 33
	replace case=0 in 33
	replace pop_wpp=(9690) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=11 in 34
	replace case=0 in 34
	replace pop_wpp=(9857) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=12 in 35
	replace case=0 in 35
	replace pop_wpp=(8859) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=13 in 36
	replace case=0 in 36
	replace pop_wpp=(7232) in 36
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR STOMACH CANCER (M&F)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   20   284825    7.02      3.51     2.08     5.78     0.90 |
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
replace year=2 if year==.
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
tab pop_wpp age5 if siteiarc==53 & sex==1 //female
tab pop_wpp age5 if siteiarc==53 & sex==2 //male

preserve
	drop if age5==.
	keep if siteiarc==53
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings:
	** M&F 0-4,5-9,10-14,25-29,30-34,55-59
	** F   15-19,20-24,35-39,40-44,45-49,50-54,60-64,65-69,70-74,80-84
	** M   40-44
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=1 in 14
	replace case=0 in 14
	replace pop_wpp=(7807) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=2 in 15
	replace case=0 in 15
	replace pop_wpp=(8818) in 15
	sort age5

	expand 2 in 1
	replace sex=1 in 16
	replace age5=3 in 16
	replace case=0 in 16
	replace pop_wpp=(9304) in 16
	sort age5

	expand 2 in 1
	replace sex=1 in 17
	replace age5=4 in 17
	replace case=0 in 17
	replace pop_wpp=(9336) in 17
	sort age5

	expand 2 in 1
	replace sex=1 in 18
	replace age5=5 in 18
	replace case=0 in 18
	replace pop_wpp=(9435) in 18
	sort age5

	expand 2 in 1
	replace sex=1 in 19
	replace age5=6 in 19
	replace case=0 in 19
	replace pop_wpp=(9240) in 19
	sort age5

	expand 2 in 1
	replace sex=1 in 20
	replace age5=7 in 20
	replace case=0 in 20
	replace pop_wpp=(9848) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=8 in 21
	replace case=0 in 21
	replace pop_wpp=(9820) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=9 in 22
	replace case=0 in 22
	replace pop_wpp=(10706) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=10 in 23
	replace case=0 in 23
	replace pop_wpp=(10559) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=11 in 24
	replace case=0 in 24
	replace pop_wpp=(11198) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=12 in 25
	replace case=0 in 25
	replace pop_wpp=(10136) in 25
	sort age5
	
	expand 2 in 1
	replace sex=1 in 26
	replace age5=13 in 26
	replace case=0 in 26
	replace pop_wpp=(8207) in 26
	sort age5
	
	expand 2 in 1
	replace sex=1 in 27
	replace age5=14 in 27
	replace case=0 in 27
	replace pop_wpp=(6598) in 27
	sort age5
	
	expand 2 in 1
	replace sex=1 in 28
	replace age5=15 in 28
	replace case=0 in 28
	replace pop_wpp=(5125) in 28
	sort age5
	
	expand 2 in 1
	replace sex=1 in 29
	replace age5=17 in 29
	replace case=0 in 29
	replace pop_wpp=(3272) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=1 in 30
	replace case=0 in 30
	replace pop_wpp=(8055) in 30
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=2 in 31
	replace case=0 in 31
	replace pop_wpp=(9178) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=3 in 32
	replace case=0 in 32
	replace pop_wpp=(9829) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=6 in 33
	replace case=0 in 33
	replace pop_wpp=(9115) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=7 in 34
	replace case=0 in 34
	replace pop_wpp=(9376) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=9 in 35
	replace case=0 in 35
	replace pop_wpp=(9927) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=12 in 36
	replace case=0 in 36
	replace pop_wpp=(8859) in 36
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR NHL (M&F)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   18   284825    6.32      4.30     2.43     7.13     1.15 |
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
replace year=2 if year==.
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
