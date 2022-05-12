** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          10a_analysis_mort.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      10-MAY-2022
    // 	date last modified      10-MAY-2022
    //  algorithm task          Analyzing combined cancer dataset: (1) Numbers (2) ASIRs (3) Survival
    //  status                  Completed
    //  objective               To have one dataset with cleaned and grouped 2015 death data for inclusion in 2018 cancer report.
    
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
    log using "`logpath'\10_analysis_mort.smcl", replace
** HEADER -----------------------------------------------------

** Load the dataset
use "`datapath'\version04\3-output\2018_prep mort", replace


count // 659 cancer deaths in 2018
tab age_10 sex ,m
//tab siteiarc ,m
//labelbook siteiarc_lab

** proportions for Table 7 using IARC's site groupings
//tab siteiarc sex ,m
//tab siteiarc , m
//tab siteiarc if sex==2 ,m // female
//tab siteiarc if sex==1 ,m // male


** For annual report - Section 4: Mortality - Table 7a
** Below top 10 code added by JC for 2014
** All sites excl. O&U, insitu, non-reportable skin cancers - using IARC CI5's site groupings
preserve
drop if siteiarc==25|siteiarc==61|siteiarc==64 //54 obs deleted
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
Prostate (C61)								135		28.54
Breast (C50)								102		21.56
Colon (C18)									61		12.90
Lung (incl. trachea and bronchus) (C33-34)	33		6.98
Pancreas (C25)								32		6.77
Stomach (C16)								27		5.71
Rectum (C19-20)								26		5.50
Corpus uteri (C54)							22		4.65
Multiple myeloma (C90)						20		4.23
Ovary (C56)									15		3.17
*/
total count //473

** JC update: Save these results as a dataset for reporting
replace siteiarc=2 if siteiarc==39
replace siteiarc=3 if siteiarc==29
replace siteiarc=4 if siteiarc==13
replace siteiarc=5 if siteiarc==21
replace siteiarc=6 if siteiarc==18
replace siteiarc=7 if siteiarc==11
replace siteiarc=8 if siteiarc==14
replace siteiarc=9 if siteiarc==33
replace siteiarc=10 if siteiarc==55
replace siteiarc=11 if siteiarc==35
rename siteiarc cancer_site
gen year=1
rename count number
	expand 2 in 1
	replace cancer_site=1 in 11
	replace number=659 in 11
	replace percentage=100 in 11

label define cancer_site_lab 1 "all" 2 "prostate" 3 "breast" 4 "colon" 5 "lung" 6 "pancreas" 7 "stomach" 8 "rectum" 9 "corpus uteri" 10 "multiple myeloma" 11 "ovary" ,modify
label values cancer_site cancer_site_lab
label define year_lab 1 "2018" 2 "2015" 3 "2014" 4 "2013" 5 "2008",modify
label values year year_lab
sort cancer_site
gen rpt_id = _n
save "`datapath'\version04\2-working\ASMRs_wpp" ,replace
restore

** proportions for Table 1 using IARC's site groupings
//tab siteiarc sex ,m
//tab siteiarc , m
//tab siteiarc if sex==2 ,m // female
//tab siteiarc if sex==1 ,m // male

************************************************************
* 4.3 MR age-standardised to WHO world pop_wppn - ALL sites
************************************************************

**********************************************************************************
** ASMR and 95% CI for Table 1 using AR's site groupings - using WHO World pop_wppn **
**********************************************************************************

** No need to recode sex as already 1=female; 2=male

********************************************************************
* (2.4c) MR age-standardised to WHO world pop_wppn - ALL TUMOURS
********************************************************************
** Using WHO World Standard pop_wppulation
//tab siteiarc ,m

merge m:m sex age_10 using "`datapath'\version04\2-working\pop_wpp_2018-10"
/*
    Result                           # of obs.
    Result                      Number of obs
    -----------------------------------------
    Not matched                             1
        from master                         0  (_merge==1)
        from using                          1  (_merge==2)

    Matched                               659  (_merge==3)
    -----------------------------------------
*/
**drop if _merge==2 //do not drop these age groups as it skews pop_wppulation 
** There is 1 unmatched records (_merge==2) since 2018 data doesn't have any cases of males with age range 25-34
** age_10	site  dup	sex	 pfu	pop_wpp	_merge
** 25-34	  .     .	male   .	18385	using only (2)

tab age_10 ,m //none missing

gen case=1 if record_id!=. //do not generate case for missing age group 0-14 as it skews case total
gen pfu=1 // for % year if not whole year collected; not done for cancer

list record_id sex age_10 if age_10==3 & sex==2 // age range 0-14 for male: change case=0 for age_10=1
replace case=0 if age_10==3 & sex==2 //1 change

** SF requested by email & WhatsApp on 07-Jan-2020 age and sex specific rates for top 10 cancers
/*
What is age-specific incidence rate? 
Age-specific rates provide information on the incidence of a particular event in an age group relative to the total number of people at risk of that event in the same age group.

What is age-standardised incidence rate?
The age-standardized incidence rate is the summary rate that would have been observed, given the schedule of age-specific rates, in a population with the age composition of some reference population, often called the standard population.
*/
** AGE + SEX
preserve
collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex siteiarc)
gen incirate=case/pop_wpp*100000
drop if siteiarc!=39 & siteiarc!=29 & siteiarc!=13 & siteiarc!=21 ///
		& siteiarc!=18 & siteiarc!=11 & siteiarc!=14 ///
		& siteiarc!=33 & siteiarc!=55 & siteiarc!=35
//by sex,sort: tab age_10 incirate ,m
sort siteiarc age_10 sex
//list incirate age_10 sex
//list incirate age_10 sex if siteiarc==13

format incirate %04.2f
gen year=2018
rename siteiarc cancer_site
rename incirate age_specific_rate
drop pfu case pop_wpp
order year cancer_site sex age_10 age_specific_rate
save "`datapath'\version04\2-working\2018_top10mort_age+sex_rates" ,replace
restore

** AGE
preserve
collapse (sum) case (mean) pop_wpp, by(pfu age_10 siteiarc)
gen incirate=case/pop_wpp*100000
drop if siteiarc!=39 & siteiarc!=29 & siteiarc!=13 & siteiarc!=21 ///
		& siteiarc!=18 & siteiarc!=11 & siteiarc!=14 ///
		& siteiarc!=33 & siteiarc!=55 & siteiarc!=35
//by sex,sort: tab age_10 incirate ,m
sort siteiarc age_10
//list incirate age_10 sex
//list incirate age_10 sex if siteiarc==13

format incirate %04.2f
gen year=2018
rename siteiarc cancer_site
rename incirate age_specific_rate
drop pfu case pop_wpp
order year cancer_site age_10 age_specific_rate
save "`datapath'\version04\2-working\2018_top10mort_age_rates" ,replace
restore

** Check for missing age as these would need to be added to the median group for that site when assessing ASIRs to prevent creating an outlier
count if age==.|age==999 //1

list siteiarc age if age==.|age==999 //this is missing age_10: 25-34 so no change needed

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

distrate case pop_wpp using "`datapath'\version04\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR ALL TUMOURS - STD TO WHO WORLD pop_wppN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  631   285327   221.15    126.41   116.22   137.35     5.32 |
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
gen percent=number/659*100
replace percent=round(percent,0.01)

append using "`datapath'\version04\2-working\ASMRs_wpp"
replace cancer_site=1 if cancer_site==.
replace year=1 if year==.
gen asmr_id="all" if rpt_id==.
replace rpt_id=1 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==1 & asmr_id==""
drop asmr_id
save "`datapath'\version04\2-working\ASMRs_wpp" ,replace
restore

** PROSTATE
tab pop_wpp age_10 if siteiarc==39 //male

preserve
	drop if age_10==.
	keep if siteiarc==39 // 
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings: M 0-14,15-24,25-34,35-44
	
	expand 2 in 1
	replace sex=2 in 6
	replace age_10=1 in 6
	replace case=0 in 6
	replace pop_wpp=(25316)  in 6
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 7
	replace age_10=2 in 7
	replace case=0 in 7
	replace pop_wpp=(19294)  in 7
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

distrate case pop_wpp using "`datapath'\version04\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD pop_wppN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  135   138525   97.46     51.93    43.33    62.03     4.64 |
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
gen percent=number/659*100
replace percent=round(percent,0.01)

append using "`datapath'\version04\2-working\ASMRs_wpp"
replace cancer_site=2 if cancer_site==.
replace year=1 if year==.
gen asmr_id="prost" if rpt_id==.
replace rpt_id=2 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==2 & asmr_id==""
drop asmr_id
save "`datapath'\version04\2-working\ASMRs_wpp" ,replace
restore

** BREAST
tab pop_wpp age_10 if siteiarc==29 & sex==1 //female
tab pop_wpp age_10 if siteiarc==29 & sex==2 //male

preserve
	drop if age_10==.
	keep if siteiarc==29 // breast only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex

	** now we have to add in the cases and pop_wppns for the missings: 
	** F 0-14,15-24
	** M 0-14,15-24,25-34,35-44,55-64,65-74,85+
	
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_wpp=(24395) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_wpp=(18623) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_wpp=(25316) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(19294) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_wpp=(18385) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_wpp=(18767) in 15
	sort age_10
		
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=6 in 16
	replace case=0 in 16
	replace pop_wpp=(17550) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=7 in 17
	replace case=0 in 17
	replace pop_wpp=(11485) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=8 in 18
	replace case=0 in 18
	replace pop_wpp=(5824) in 18
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 19
	replace age_10=9 in 19
	replace case=0 in 19
	replace pop_wpp=(2624) in 19
	sort age_10

	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version04\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BC (M&F) - STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  102   292464   34.88     21.83    17.59    26.87     2.31 |
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
gen percent=number/659*100
replace percent=round(percent,0.01)

append using "`datapath'\version04\2-working\ASMRs_wpp"
replace cancer_site=3 if cancer_site==.
replace year=1 if year==.
gen asmr_id="breast" if rpt_id==.
replace rpt_id=3 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==3 & asmr_id==""
drop asmr_id
save "`datapath'\version04\2-working\ASMRs_wpp" ,replace
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
	** M 35-44
	
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
	replace sex=1 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_wpp=(18632) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=3 in 17
	replace case=0 in 17
	replace pop_wpp=(18385) in 17
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

distrate case pop_wpp using "`datapath'\version04\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (M&F)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   61   286640   21.28     11.24     8.45    14.80     1.56 |
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
gen percent=number/659*100
replace percent=round(percent,0.01)

append using "`datapath'\version04\2-working\ASMRs_wpp"
replace cancer_site=4 if cancer_site==.
replace year=1 if year==.
gen asmr_id="colon" if rpt_id==.
replace rpt_id=4 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==4 & asmr_id==""
drop asmr_id
save "`datapath'\version04\2-working\ASMRs_wpp" ,replace
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
	** M&F 0-14,15-24,25-34
	** F 35-44
	
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
	replace sex=1 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_wpp=(18632) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=3 in 17
	replace case=0 in 17
	replace pop_wpp=(18385) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=4 in 18
	replace case=0 in 18
	replace pop_wpp=(19702) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version04\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR LUNG CANCER (M&F)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   33   286640   11.51      6.62     4.46     9.59     1.26 |
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
gen percent=number/659*100
replace percent=round(percent,0.01)

append using "`datapath'\version04\2-working\ASMRs_wpp"
replace cancer_site=5 if cancer_site==.
replace year=1 if year==.
gen asmr_id="lung" if rpt_id==.
replace rpt_id=5 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==5 & asmr_id==""
drop asmr_id
save "`datapath'\version04\2-working\ASMRs_wpp" ,replace
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
	** M&F 0-14,15-24,25-34,35-44
	** F 45-54
	
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_wpp=(24395) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(25316) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(18623) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(19294) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_wpp=(18632) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18385) in 15
	sort age_10	
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_wpp=(19702) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_wpp=(18767) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=5 in 18
	replace case=0 in 18
	replace pop_wpp=(21092) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version04\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PANCREATIC CANCER (M&F)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   32   286640   11.16      5.85     3.95     8.53     1.12 |
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
gen percent=number/659*100
replace percent=round(percent,0.01)

append using "`datapath'\version04\2-working\ASMRs_wpp"
replace cancer_site=6 if cancer_site==.
replace year=1 if year==.
gen asmr_id="panc" if rpt_id==.
replace rpt_id=6 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==6 & asmr_id==""
drop asmr_id
save "`datapath'\version04\2-working\ASMRs_wpp" ,replace
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
	** M&F 0-14,15-24,25-34
	** F 45-54
	** M 
	
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
	replace sex=1 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_wpp=(18632) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=3 in 17
	replace case=0 in 17
	replace pop_wpp=(18385) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=5 in 18
	replace case=0 in 18
	replace pop_wpp=(21092) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version04\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR STOMACH CANCER (M&F)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   27   286640    9.42      5.25     3.37     7.94     1.12 |
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
gen percent=number/659*100
replace percent=round(percent,0.01)

append using "`datapath'\version04\2-working\ASMRs_wpp"
replace cancer_site=7 if cancer_site==.
replace year=1 if year==.
gen asmr_id="stom" if rpt_id==.
replace rpt_id=7 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==7 & asmr_id==""
drop asmr_id
save "`datapath'\version04\2-working\ASMRs_wpp" ,replace
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
	** M&F 0-14,15-24,25-34
	** F 45-54,85+
	** M 25-44
	
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_wpp=(24395) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(25316) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(18623) in 12
	sort age_10
		
	expand 2 in 1
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(19294) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_wpp=(18632) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18385) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_wpp=(18767) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=5 in 17
	replace case=0 in 17
	replace pop_wpp=(21092) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(4080) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version04\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RECTAL CANCER (M&F)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   26   286640    9.07      5.48     3.52     8.26     1.16 |
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
gen percent=number/659*100
replace percent=round(percent,0.01)

append using "`datapath'\version04\2-working\ASMRs_wpp"
replace cancer_site=8 if cancer_site==.
replace year=1 if year==.
gen asmr_id="rect" if rpt_id==.
replace rpt_id=8 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==8 & asmr_id==""
drop asmr_id
save "`datapath'\version04\2-working\ASMRs_wpp" ,replace
restore

** CORPUS UTERI
tab pop_wpp age_10 if siteiarc==33

preserve
	drop if age_10==.
	keep if siteiarc==33
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings: 
	** F 0-14,15-24,25-34,35-44,85+
	
	expand 2 in 1
	replace sex=1 in 5
	replace age_10=1 in 5
	replace case=0 in 5
	replace pop_wpp=(24395) in 5
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 6
	replace age_10=2 in 6
	replace case=0 in 6
	replace pop_wpp=(18623) in 6
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=3 in 7
	replace case=0 in 7
	replace pop_wpp=(18632) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=4 in 8
	replace case=0 in 8
	replace pop_wpp=(19702) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=9 in 9
	replace case=0 in 9
	replace pop_wpp=(4080) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version04\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CORPUS UTERI (WOMEN)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   22   148115   14.85      8.54     5.32    13.33     1.95 |
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
gen percent=number/659*100
replace percent=round(percent,0.01)

append using "`datapath'\version04\2-working\ASMRs_wpp"
replace cancer_site=9 if cancer_site==.
replace year=1 if year==.
gen asmr_id="corpus" if rpt_id==.
replace rpt_id=9 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==9 & asmr_id==""
drop asmr_id
save "`datapath'\version04\2-working\ASMRs_wpp" ,replace
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
	** F 45-54
	** M 75-84
	
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
	replace age_10=5 in 17
	replace case=0 in 17
	replace pop_wpp=(21092) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=8 in 18
	replace case=0 in 18
	replace pop_wpp=(5824) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'\version04\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR MULTIPLE MYELOMA (M&F)- STD TO WHO WORLD pop_wppN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   20   286640    6.98      4.00     2.41     6.41     0.97 |
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
gen percent=number/659*100
replace percent=round(percent,0.01)

append using "`datapath'\version04\2-working\ASMRs_wpp"
replace cancer_site=10 if cancer_site==.
replace year=1 if year==.
gen asmr_id="MM" if rpt_id==.
replace rpt_id=10 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==10 & asmr_id==""
drop asmr_id
save "`datapath'\version04\2-working\ASMRs_wpp" ,replace
restore


** OVARY
tab pop_wpp age_10 if siteiarc==35 & sex==1 //female

preserve
	drop if age_10==.
	keep if siteiarc==35
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings: 
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

distrate case pop_wpp using "`datapath'\version04\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR OVARY (F)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   15   148115   10.13      6.19     3.35    10.73     1.80 |
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
gen percent=number/659*100
replace percent=round(percent,0.01)

append using "`datapath'\version04\2-working\ASMRs_wpp"
replace cancer_site=11 if cancer_site==.
replace year=1 if year==.
gen asmr_id="ovary" if rpt_id==.
replace rpt_id=11 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==11 & asmr_id==""
drop asmr_id rpt_id
format asmr %04.2f
format percentage %04.1f
save "`datapath'\version04\2-working\ASMRs_wpp" ,replace
restore

label data "BNR MORTALITY rates 2018"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version04\3-output\2018_analysis mort_wpp" ,replace
note: TS This dataset includes patients with multiple eligible cancer causes of death; used WPP population
