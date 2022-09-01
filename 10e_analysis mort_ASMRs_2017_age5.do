** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          10e_analysis mort_ASMRs_2017_age5.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      31-AUG-2022
    // 	date last modified      31-AUG-2022
    //  algorithm task          Analyzing combined cancer dataset: (1) Numbers (2) ASMRs
    //  status                  Completed
    //  objective               To have one dataset with cleaned and grouped 2017 death data for inclusion in 2016-2018 cancer report.
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
    log using "`logpath'\10e_analysis mort_ASMRs_2017_age5.smcl", replace
** HEADER -----------------------------------------------------

** Load the dataset
** JC 22aug2022: mortality analyses was done in p117/version04 for the Globocan comparison requested by NS + the 2022 BNR CME webinar so using the dofiles and ds from that version (version04/3-output)
use "`datapath'\version09\3-output\2017_prep mort_deidentified", clear

count // 670 cancer deaths in 2017
tab age5 sex ,m
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
Prostate (C61)								157		34.66
Breast (C50)								 73		16.11
Colon (C18)									 65		14.35
Pancreas (C25)								 30		 6.62
Rectum (C19-20)								 26		 5.74
Lung (incl. trachea and bronchus) (C33-34)	 25		 5.52
Multiple myeloma (C90)						 25		 5.52
Corpus uteri (C54)							 20		 4.42
Cervix uteri (C53)							 16		 3.53
Stomach (C16)								 16		 3.53
*/
total count //453

** JC update: Save these results as a dataset for reporting
replace siteiarc=2 if siteiarc==39
replace siteiarc=3 if siteiarc==29
replace siteiarc=4 if siteiarc==13
replace siteiarc=5 if siteiarc==18
replace siteiarc=6 if siteiarc==14
replace siteiarc=7 if siteiarc==21
replace siteiarc=8 if siteiarc==55
replace siteiarc=9 if siteiarc==33
replace siteiarc=10 if siteiarc==32
replace siteiarc=11 if siteiarc==11
rename siteiarc cancer_site
gen year=5
rename count number
	expand 2 in 1
	replace cancer_site=1 in 11
	replace number=670 in 11
	replace percentage=100 in 11

//JC 19may2022: rename breast to female breast as drop males in distrate breast section so ASMR for breast is calculated using female population
//JC 13jun2022: performed above correction
label define cancer_site_lab 1 "all" 2 "prostate" 3 "female breast" 4 "colon" 5 "pancreas" 6 "rectum" 7 "lung" 8 "multiple myeloma" 9 "corpus uteri" 10 "cervix uteri" 11 "stomach" ,modify
label values cancer_site cancer_site_lab
label define year_lab 1 "2013" 2 "2014" 3 "2015" 4 "2016" 5 "2017" 6 "2018" 7 "2019" 8 "2020" 9 "2021" ,modify
label values year year_lab
sort cancer_site
gen rpt_id = _n
save "`datapath'\version09\2-working\ASMRs_wpp_2017" ,replace
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
//JC 19may2022: use age5 population and groupings for distrate per IH's + NS' recommendation
//JC 13jun2022: Above correction not performed - will perform in a separate dofile when using IH's rate calculation method
merge m:m sex age5 using "`datapath'\version09\2-working\pop_wpp_2017-5"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                             8
        from master                         0  (_merge==1)
        from using                          8  (_merge==2)

    Matched                               670  (_merge==3)
    -----------------------------------------
*/
**drop if _merge==2 //do not drop these age groups as it skews pop_wpp 
** There are 8 unmatched records (_merge==2) since 2017 data doesn't have any cases of 0-4 female + male; 5-9 female + male; 15-19 female; 20-24 male; 25-29 female + male

tab age5 ,m //none missing

gen case=1 if record_id!=. //do not generate case for missing age group 0-14 as it skews case total
gen pfu=1 // for % year if not whole year collected; not done for cancer

list record_id sex age5 if _merge==2
list record_id sex age5 if _merge==2 ,nolabel

list record_id sex age5 if age5==1 & (sex==1|sex==2)|age5==2 & (sex==1|sex==2)|age5==4 & sex==1|age5==5 & sex==2|age5==6 & (sex==1|sex==2)
replace case=0 if age5==1 & (sex==1|sex==2)|age5==2 & (sex==1|sex==2)|age5==4 & sex==1|age5==5 & sex==2|age5==6 & (sex==1|sex==2) //8 changes

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
		& siteiarc!=18 & siteiarc!=11 & siteiarc!=14 ///
		& siteiarc!=33 & siteiarc!=55 & siteiarc!=32
//by sex,sort: tab age5 mortrate ,m
sort siteiarc age5 sex
//list mortrate age5 sex
//list mortrate age5 sex if siteiarc==13

format mortrate %04.2f
gen year=2017
rename siteiarc cancer_site
rename mortrate age_specific_rate
drop pfu case pop_wpp
order year cancer_site sex age5 age_specific_rate
save "`datapath'\version09\2-working\2017_top10mort_age+sex_rates" ,replace
restore

** AGE
preserve
collapse (sum) case (mean) pop_wpp, by(pfu age5 siteiarc)
gen mortrate=case/pop_wpp*100000
drop if siteiarc!=39 & siteiarc!=29 & siteiarc!=13 & siteiarc!=21 ///
		& siteiarc!=18 & siteiarc!=11 & siteiarc!=14 ///
		& siteiarc!=33 & siteiarc!=55 & siteiarc!=32
//by sex,sort: tab age5 mortrate ,m
sort siteiarc age5
//list mortrate age5 sex
//list mortrate age5 sex if siteiarc==13

format mortrate %04.2f
gen year=2017
rename siteiarc cancer_site
rename mortrate age_specific_rate
drop pfu case pop_wpp
order year cancer_site age5 age_specific_rate
save "`datapath'\version09\2-working\2017_top10mort_age_rates" ,replace
restore

** Check for missing age as these would need to be added to the median group for that site when assessing ASMRs to prevent creating an outlier
count if age==.|age==999 //1

list siteiarc age if age==.|age==999 //this is missing age5: 25-34 so no change needed

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
  |  670   286229   234.08    129.74   119.57   140.66     5.30 |
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
gen percent=number/670*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2017"
replace cancer_site=1 if cancer_site==.
replace year=5 if year==.
gen asmr_id="all" if rpt_id==.
replace rpt_id=1 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==1 & asmr_id==""
drop asmr_id
save "`datapath'\version09\2-working\ASMRs_wpp_2017" ,replace
restore

** PROSTATE
tab pop_wpp age5 if siteiarc==39 //male

preserve
	drop if age5==.
	keep if siteiarc==39 // 
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings: 
	** M 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,40-44,45-49
	
	expand 2 in 1
	replace sex=2 in 9
	replace age5=1 in 9
	replace case=0 in 9
	replace pop_wpp=(7706) in 9
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 10
	replace age5=2 in 10
	replace case=0 in 10
	replace pop_wpp=(8493) in 10
	sort age5
	
	expand 2 in 1
	replace sex=2 in 11
	replace age5=3 in 11
	replace case=0 in 11
	replace pop_wpp=(9551) in 11
	sort age5
	
	expand 2 in 1
	replace sex=2 in 12
	replace age5=4 in 12
	replace case=0 in 12
	replace pop_wpp=(9717) in 12
	sort age5
	
	expand 2 in 1
	replace sex=2 in 13
	replace age5=5 in 13
	replace case=0 in 13
	replace pop_wpp=(9537) in 13
	sort age5
	
	expand 2 in 1
	replace sex=2 in 14
	replace age5=6 in 14
	replace case=0 in 14
	replace pop_wpp=(9179) in 14
	sort age5
	
	expand 2 in 1
	replace sex=2 in 15
	replace age5=7 in 15
	replace case=0 in 15
	replace pop_wpp=(9216) in 15
	sort age5
	
	expand 2 in 1
	replace sex=2 in 16
	replace age5=8 in 16
	replace case=0 in 16
	replace pop_wpp=(9261) in 16
	sort age5
	
	expand 2 in 1
	replace sex=2 in 17
	replace age5=9 in 17
	replace case=0 in 17
	replace pop_wpp=(9663) in 17
	sort age5
	
	expand 2 in 1
	replace sex=2 in 18
	replace age5=10 in 18
	replace case=0 in 18
	replace pop_wpp=(9666) in 18
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
  |  157   138223   113.58     61.23    51.77    72.26     5.08 |
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
gen percent=number/670*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2017"
replace cancer_site=2 if cancer_site==.
replace year=5 if year==.
gen asmr_id="prost" if rpt_id==.
replace rpt_id=2 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==2 & asmr_id==""
drop asmr_id
save "`datapath'\version09\2-working\ASMRs_wpp_2017" ,replace
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
	** F 0-4,5-9,10-14,15-19,20-24,25-29
	
	expand 2 in 1
	replace sex=1 in 13
	replace age5=1 in 13
	replace case=0 in 13
	replace pop_wpp=(7407) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=2 in 14
	replace case=0 in 14
	replace pop_wpp=(8258) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=3 in 15
	replace case=0 in 15
	replace pop_wpp=(9079) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=4 in 16
	replace case=0 in 16
	replace pop_wpp=(9274) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=5 in 17
	replace case=0 in 17
	replace pop_wpp=(9422) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=6 in 18
	replace case=0 in 18
	replace pop_wpp=(9191) in 18
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
  |   72   148006   48.65     29.67    22.85    38.13     3.77 |
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
gen percent=number/670*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2017"
replace cancer_site=3 if cancer_site==.
replace year=5 if year==.
gen asmr_id="fem.breast" if rpt_id==.
replace rpt_id=3 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==3 & asmr_id==""
drop asmr_id
save "`datapath'\version09\2-working\ASMRs_wpp_2017" ,replace
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
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,40-44
	** F   45-49
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=1 in 18
	replace case=0 in 18
	replace pop_wpp=(7407) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=2 in 19
	replace case=0 in 19
	replace pop_wpp=(8258) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=3 in 20
	replace case=0 in 20
	replace pop_wpp=(9079) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=4 in 21
	replace case=0 in 21
	replace pop_wpp=(9274) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=5 in 22
	replace case=0 in 22
	replace pop_wpp=(9422) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=6 in 23
	replace case=0 in 23
	replace pop_wpp=(9191) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=7 in 24
	replace case=0 in 24
	replace pop_wpp=(9554) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=8 in 25
	replace case=0 in 25
	replace pop_wpp=(9646) in 25
	sort age5
	
	expand 2 in 1
	replace sex=1 in 26
	replace age5=9 in 26
	replace case=0 in 26
	replace pop_wpp=(10261) in 26
	sort age5
	
	expand 2 in 1
	replace sex=1 in 27
	replace age5=10 in 27
	replace case=0 in 27
	replace pop_wpp=(10436) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=1 in 28
	replace case=0 in 28
	replace pop_wpp=(7706) in 28
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=2 in 29
	replace case=0 in 29
	replace pop_wpp=(8493) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=3 in 30
	replace case=0 in 30
	replace pop_wpp=(9551) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=4 in 31
	replace case=0 in 31
	replace pop_wpp=(9717) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=5 in 32
	replace case=0 in 32
	replace pop_wpp=(9537) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=6 in 33
	replace case=0 in 33
	replace pop_wpp=(9179) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=7 in 34
	replace case=0 in 34
	replace pop_wpp=(9216) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=8 in 35
	replace case=0 in 35
	replace pop_wpp=(9261) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=9 in 36
	replace case=0 in 36
	replace pop_wpp=(9663) in 36
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
  |   65   286229   22.71     11.78     8.98    15.36     1.57 |
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
gen percent=number/670*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2017"
replace cancer_site=4 if cancer_site==.
replace year=5 if year==.
gen asmr_id="colon" if rpt_id==.
replace rpt_id=4 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==4 & asmr_id==""
drop asmr_id
save "`datapath'\version09\2-working\ASMRs_wpp_2017" ,replace
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
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39
	** F   45-49,75-79
	** M   40-44

	expand 2 in 1
	replace sex=1 in 18
	replace age5=1 in 18
	replace case=0 in 18
	replace pop_wpp=(7407) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=2 in 19
	replace case=0 in 19
	replace pop_wpp=(8258) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=3 in 20
	replace case=0 in 20
	replace pop_wpp=(9079) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=4 in 21
	replace case=0 in 21
	replace pop_wpp=(9274) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=5 in 22
	replace case=0 in 22
	replace pop_wpp=(9422) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=6 in 23
	replace case=0 in 23
	replace pop_wpp=(9191) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=7 in 24
	replace case=0 in 24
	replace pop_wpp=(9554) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=8 in 25
	replace case=0 in 25
	replace pop_wpp=(9646) in 25
	sort age5
	
	expand 2 in 1
	replace sex=1 in 26
	replace age5=10 in 26
	replace case=0 in 26
	replace pop_wpp=(10436) in 26
	sort age5
	
	expand 2 in 1
	replace sex=1 in 27
	replace age5=16 in 27
	replace case=0 in 27
	replace pop_wpp=(4402) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=1 in 28
	replace case=0 in 28
	replace pop_wpp=(7706) in 28
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=2 in 29
	replace case=0 in 29
	replace pop_wpp=(8493) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=3 in 30
	replace case=0 in 30
	replace pop_wpp=(9551) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=4 in 31
	replace case=0 in 31
	replace pop_wpp=(9717) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=5 in 32
	replace case=0 in 32
	replace pop_wpp=(9537) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=6 in 33
	replace case=0 in 33
	replace pop_wpp=(9179) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=7 in 34
	replace case=0 in 34
	replace pop_wpp=(9216) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=8 in 35
	replace case=0 in 35
	replace pop_wpp=(9261) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=9 in 36
	replace case=0 in 36
	replace pop_wpp=(9663) in 36
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
  |   30   286229   10.48      6.10     4.04     9.00     1.21 |
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
gen percent=number/670*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2017"
replace cancer_site=5 if cancer_site==.
replace year=5 if year==.
gen asmr_id="panc" if rpt_id==.
replace rpt_id=5 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==5 & asmr_id==""
drop asmr_id
save "`datapath'\version09\2-working\ASMRs_wpp_2017" ,replace
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
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,40-44,45-49
	** F   35-39,60-64,65-69,75-79
	** M   50-54,55-59

	expand 2 in 1
	replace sex=1 in 13
	replace age5=1 in 13
	replace case=0 in 13
	replace pop_wpp=(7407) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=2 in 14
	replace case=0 in 14
	replace pop_wpp=(8258) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=3 in 15
	replace case=0 in 15
	replace pop_wpp=(9079) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=4 in 16
	replace case=0 in 16
	replace pop_wpp=(9274) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=5 in 17
	replace case=0 in 17
	replace pop_wpp=(9422) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=6 in 18
	replace case=0 in 18
	replace pop_wpp=(9191) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=7 in 19
	replace case=0 in 19
	replace pop_wpp=(9554) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=8 in 20
	replace case=0 in 20
	replace pop_wpp=(9646) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=9 in 21
	replace case=0 in 21
	replace pop_wpp=(10261) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=10 in 22
	replace case=0 in 22
	replace pop_wpp=(10436) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=13 in 23
	replace case=0 in 23
	replace pop_wpp=(9132) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=14 in 24
	replace case=0 in 24
	replace pop_wpp=(7328) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=16 in 25
	replace case=0 in 25
	replace pop_wpp=(4402) in 25
	sort age5
	
	expand 2 in 1
	replace sex=2 in 26
	replace age5=1 in 26
	replace case=0 in 26
	replace pop_wpp=(7706) in 26
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 27
	replace age5=2 in 27
	replace case=0 in 27
	replace pop_wpp=(8493) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=3 in 28
	replace case=0 in 28
	replace pop_wpp=(9551) in 28
	sort age5
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=4 in 29
	replace case=0 in 29
	replace pop_wpp=(9717) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=5 in 30
	replace case=0 in 30
	replace pop_wpp=(9537) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=6 in 31
	replace case=0 in 31
	replace pop_wpp=(9179) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=7 in 32
	replace case=0 in 32
	replace pop_wpp=(9216) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=9 in 33
	replace case=0 in 33
	replace pop_wpp=(9663) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=10 in 34
	replace case=0 in 34
	replace pop_wpp=(9666) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=11 in 35
	replace case=0 in 35
	replace pop_wpp=(9681) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=12 in 36
	replace case=0 in 36
	replace pop_wpp=(9322) in 36
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
  |   26   286229    9.08      5.03     3.22     7.70     1.09 |
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
gen percent=number/670*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2017"
replace cancer_site=6 if cancer_site==.
replace year=5 if year==.
gen asmr_id="rect" if rpt_id==.
replace rpt_id=6 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==6 & asmr_id==""
drop asmr_id
save "`datapath'\version09\2-working\ASMRs_wpp_2017" ,replace
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
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,70-74
	** F   40-44,45-49,50-54
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=1 in 16
	replace case=0 in 16
	replace pop_wpp=(7407) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=2 in 17
	replace case=0 in 17
	replace pop_wpp=(8258) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=3 in 18
	replace case=0 in 18
	replace pop_wpp=(9079) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=4 in 19
	replace case=0 in 19
	replace pop_wpp=(9274) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=5 in 20
	replace case=0 in 20
	replace pop_wpp=(9422) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=6 in 21
	replace case=0 in 21
	replace pop_wpp=(9191) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=7 in 22
	replace case=0 in 22
	replace pop_wpp=(9554) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=8 in 23
	replace case=0 in 23
	replace pop_wpp=(9646) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=9 in 24
	replace case=0 in 24
	replace pop_wpp=(10261) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=10 in 25
	replace case=0 in 25
	replace pop_wpp=(10436) in 25
	sort age5
	
	expand 2 in 1
	replace sex=1 in 26
	replace age5=11 in 26
	replace case=0 in 26
	replace pop_wpp=(10815) in 26
	sort age5
	
	expand 2 in 1
	replace sex=1 in 27
	replace age5=15 in 27
	replace case=0 in 27
	replace pop_wpp=(5645) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=1 in 28
	replace case=0 in 28
	replace pop_wpp=(7706) in 28
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=2 in 29
	replace case=0 in 29
	replace pop_wpp=(8493) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=3 in 30
	replace case=0 in 30
	replace pop_wpp=(9551) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=4 in 31
	replace case=0 in 31
	replace pop_wpp=(9717) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=5 in 32
	replace case=0 in 32
	replace pop_wpp=(9537) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=6 in 33
	replace case=0 in 33
	replace pop_wpp=(9179) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=7 in 34
	replace case=0 in 34
	replace pop_wpp=(9216) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=8 in 35
	replace case=0 in 35
	replace pop_wpp=(9261) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=15 in 36
	replace case=0 in 36
	replace pop_wpp=(4598) in 36
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
  |   25   286229    8.73      4.61     2.89     7.17     1.04 |
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
gen percent=number/670*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2017"
replace cancer_site=7 if cancer_site==.
replace year=5 if year==.
gen asmr_id="lung" if rpt_id==.
replace rpt_id=7 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==7 & asmr_id==""
drop asmr_id
save "`datapath'\version09\2-working\ASMRs_wpp_2017" ,replace
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
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39
	** F   40-44,45-49
	** M   50-54,75-79,85+
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=1 in 16
	replace case=0 in 16
	replace pop_wpp=(7407) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=2 in 17
	replace case=0 in 17
	replace pop_wpp=(8258) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=3 in 18
	replace case=0 in 18
	replace pop_wpp=(9079) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=4 in 19
	replace case=0 in 19
	replace pop_wpp=(9274) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=5 in 20
	replace case=0 in 20
	replace pop_wpp=(9422) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=6 in 21
	replace case=0 in 21
	replace pop_wpp=(9191) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=7 in 22
	replace case=0 in 22
	replace pop_wpp=(9554) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=8 in 23
	replace case=0 in 23
	replace pop_wpp=(9646) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=9 in 24
	replace case=0 in 24
	replace pop_wpp=(10261) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=10 in 25
	replace case=0 in 25
	replace pop_wpp=(10436) in 25
	sort age5
	
	expand 2 in 1
	replace sex=2 in 26
	replace age5=1 in 26
	replace case=0 in 26
	replace pop_wpp=(7706) in 26
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 27
	replace age5=2 in 27
	replace case=0 in 27
	replace pop_wpp=(8493) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=3 in 28
	replace case=0 in 28
	replace pop_wpp=(9551) in 28
	sort age5
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=4 in 29
	replace case=0 in 29
	replace pop_wpp=(9717) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=5 in 30
	replace case=0 in 30
	replace pop_wpp=(9537) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=6 in 31
	replace case=0 in 31
	replace pop_wpp=(9179) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=7 in 32
	replace case=0 in 32
	replace pop_wpp=(9216) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=8 in 33
	replace case=0 in 33
	replace pop_wpp=(9261) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=11 in 34
	replace case=0 in 34
	replace pop_wpp=(9681) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=16 in 35
	replace case=0 in 35
	replace pop_wpp=(3337) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=18 in 36
	replace case=0 in 36
	replace pop_wpp=(2596) in 36
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
  |   25   286229    8.73      5.35     3.42     8.15     1.15 |
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
gen percent=number/670*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2017"
replace cancer_site=8 if cancer_site==.
replace year=5 if year==.
gen asmr_id="MM" if rpt_id==.
replace rpt_id=8 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==8 & asmr_id==""
drop asmr_id
save "`datapath'\version09\2-working\ASMRs_wpp_2017" ,replace
restore


** CORPUS UTERI
tab pop_wpp age5 if siteiarc==33

preserve
	drop if age5==.
	keep if siteiarc==33
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings: 
	** F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,40-44,45-49,50-54
	
	expand 2 in 1
	replace sex=1 in 8
	replace age5=1 in 8
	replace case=0 in 8
	replace pop_wpp=(7407) in 8
	sort age5
	
	expand 2 in 1
	replace sex=1 in 9
	replace age5=2 in 9
	replace case=0 in 9
	replace pop_wpp=(8258) in 9
	sort age5
	
	expand 2 in 1
	replace sex=1 in 10
	replace age5=3 in 10
	replace case=0 in 10
	replace pop_wpp=(9079) in 10
	sort age5
	
	expand 2 in 1
	replace sex=1 in 11
	replace age5=4 in 11
	replace case=0 in 11
	replace pop_wpp=(9274) in 11
	sort age5
	
	expand 2 in 1
	replace sex=1 in 12
	replace age5=5 in 12
	replace case=0 in 12
	replace pop_wpp=(9422) in 12
	sort age5
	
	expand 2 in 1
	replace sex=1 in 13
	replace age5=6 in 13
	replace case=0 in 13
	replace pop_wpp=(9191) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=7 in 14
	replace case=0 in 14
	replace pop_wpp=(9554) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=8 in 15
	replace case=0 in 15
	replace pop_wpp=(9646) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=9 in 16
	replace case=0 in 16
	replace pop_wpp=(10261) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=10 in 17
	replace case=0 in 17
	replace pop_wpp=(10436) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=11 in 18
	replace case=0 in 18
	replace pop_wpp=(10815) in 18
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
  |   20   148006   13.51      6.77     4.06    11.13     1.72 |
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
gen percent=number/670*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2017"
replace cancer_site=9 if cancer_site==.
replace year=5 if year==.
gen asmr_id="corpus" if rpt_id==.
replace rpt_id=9 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==9 & asmr_id==""
drop asmr_id
save "`datapath'\version09\2-working\ASMRs_wpp_2017" ,replace
restore


** CERVIX
tab pop_wpp age5 if siteiarc==32 & sex==1 //female

preserve
	drop if age5==.
	keep if siteiarc==32
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings: 
	** F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,40-44
	
	expand 2 in 1
	replace sex=1 in 11
	replace age5=1 in 11
	replace case=0 in 11
	replace pop_wpp=(7407) in 11
	sort age5
	
	expand 2 in 1
	replace sex=1 in 12
	replace age5=2 in 12
	replace case=0 in 12
	replace pop_wpp=(8258) in 12
	sort age5
	
	expand 2 in 1
	replace sex=1 in 13
	replace age5=3 in 13
	replace case=0 in 13
	replace pop_wpp=(9079) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=4 in 14
	replace case=0 in 14
	replace pop_wpp=(9274) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=5 in 15
	replace case=0 in 15
	replace pop_wpp=(9422) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=6 in 16
	replace case=0 in 16
	replace pop_wpp=(9191) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=7 in 17
	replace case=0 in 17
	replace pop_wpp=(9554) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=9 in 18
	replace case=0 in 18
	replace pop_wpp=(10261) in 18
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CERVICAL CANCER (F)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   16   148006   10.81      6.62     3.61    11.46     1.91 |
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
gen percent=number/670*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2017"
replace cancer_site=10 if cancer_site==.
replace year=5 if year==.
gen asmr_id="cervix" if rpt_id==.
replace rpt_id=10 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==10 & asmr_id==""
drop asmr_id
save "`datapath'\version09\2-working\ASMRs_wpp_2017" ,replace
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
	** M&F  0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,40-44,75-79
	** F 	45-49,50-54,55-59,60-64,65-69,70-74,80-84
	
	expand 2 in 1
	replace sex=1 in 10
	replace age5=1 in 10
	replace case=0 in 10
	replace pop_wpp=(7407) in 10
	sort age5
	
	expand 2 in 1
	replace sex=1 in 11
	replace age5=2 in 11
	replace case=0 in 11
	replace pop_wpp=(8258) in 11
	sort age5
	
	expand 2 in 1
	replace sex=1 in 12
	replace age5=3 in 12
	replace case=0 in 12
	replace pop_wpp=(9079) in 12
	sort age5
	
	expand 2 in 1
	replace sex=1 in 13
	replace age5=4 in 13
	replace case=0 in 13
	replace pop_wpp=(9274) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=5 in 14
	replace case=0 in 14
	replace pop_wpp=(9422) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=6 in 15
	replace case=0 in 15
	replace pop_wpp=(9191) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=7 in 16
	replace case=0 in 16
	replace pop_wpp=(9554) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=8 in 17
	replace case=0 in 17
	replace pop_wpp=(9646) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=9 in 18
	replace case=0 in 18
	replace pop_wpp=(10261) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=10 in 19
	replace case=0 in 19
	replace pop_wpp=(10436) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=11 in 20
	replace case=0 in 20
	replace pop_wpp=(10815) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=12 in 21
	replace case=0 in 21
	replace pop_wpp=(10749) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=13 in 22
	replace case=0 in 22
	replace pop_wpp=(9132) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=14 in 23
	replace case=0 in 23
	replace pop_wpp=(7328) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=15 in 24
	replace case=0 in 24
	replace pop_wpp=(5645) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=16 in 25
	replace case=0 in 25
	replace pop_wpp=(4402) in 25
	sort age5
	
	expand 2 in 1
	replace sex=1 in 26
	replace age5=17 in 26
	replace case=0 in 26
	replace pop_wpp=(3327) in 26
	sort age5
	
	expand 2 in 1
	replace sex=2 in 27
	replace age5=1 in 27
	replace case=0 in 27
	replace pop_wpp=(7706) in 27
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=2 in 28
	replace case=0 in 28
	replace pop_wpp=(8493) in 28
	sort age5
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=3 in 29
	replace case=0 in 29
	replace pop_wpp=(9551) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=4 in 30
	replace case=0 in 30
	replace pop_wpp=(9717) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=5 in 31
	replace case=0 in 31
	replace pop_wpp=(9537) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=6 in 32
	replace case=0 in 32
	replace pop_wpp=(9179) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=7 in 33
	replace case=0 in 33
	replace pop_wpp=(9216) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=8 in 34
	replace case=0 in 34
	replace pop_wpp=(9261) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=9 in 35
	replace case=0 in 35
	replace pop_wpp=(9663) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=16 in 36
	replace case=0 in 36
	replace pop_wpp=(3337) in 36
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
  |   16   286229    5.59      2.83     1.56     4.98     0.83 |
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
gen percent=number/670*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2017"
replace cancer_site=11 if cancer_site==.
replace year=5 if year==.
gen asmr_id="stom" if rpt_id==.
replace rpt_id=11 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==11 & asmr_id==""
drop asmr_id rpt_id
format asmr %04.2f
format percentage %04.1f
save "`datapath'\version09\2-working\ASMRs_wpp_2017" ,replace
restore


label data "BNR MORTALITY rates 2017"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version09\3-output\2017_analysis mort_wpp" ,replace
note: TS This dataset includes patients with multiple eligible cancer causes of death; used WPP population
