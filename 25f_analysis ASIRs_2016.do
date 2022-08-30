
cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          25f_analysis ASIRs_2016.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      29-AUG-2022
    // 	date last modified      29-AUG-2022
    //  algorithm task          Analyzing combined cancer dataset: (1) Numbers (2) ASIRs for 2016-2018 annual report
    //  status                  Completed
    //  objective               To have one dataset with cleaned and grouped 2016 incidence data for inclusion in 2016-2018 cancer report.
	//	methods					(1) Using 5-year age groups instead of 10-year
	//							(2) Using female population for breast instead of total population
	//							(3) Using WPP population instead of BSS population
    //  methods                 See 30_report cancer.do for detailed methods of each statistic

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
    log using "`logpath'/25f_analysis ASIRs_2016.smcl", replace
** HEADER -----------------------------------------------------

* *********************************************
* ANALYSIS: SECTION 3 - cancer sites
* Covering:
* 	- ASIRs by site; overall, men and women
* *********************************************
** NOTE: bb popn and WHO popn data prepared by IH are ALL coded M=2 and F=1
** Above note by AR from 2008 dofile

** Load the dataset
use "`datapath'\version09\2-working\2013-2018_cancer_numbers", clear

**********
** 2016 **
**********
drop if dxyr!=2016 // deleted

count //1070

tab beh ,m //all malignant

tab siteiarc ,m
labelbook siteiarc_lab

**********************************************************************************
** ASIR and 95% CI for Table 1 using AR's site groupings - using WHO World popn **
**					WORLD POPULATION PROSPECTS (WPP): 2018						**
*drop pfu
//gen pfu=1 // for % year if not whole year collected; not done for cancer        **
**********************************************************************************
** NSobers confirmed use of WPP populations
labelbook sex_lab

********************************************************************
* (2.4c) IR age-standardised to WHO world popn - ALL TUMOURS: 2018
********************************************************************
** Using WHO World Standard Population
//tab siteiarc ,m

*drop _merge
merge m:m sex age5 using "`datapath'\version09\2-working\pop_wpp_2016-5"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                             5
        from master                         0  (_merge==1)
        from using                          5  (_merge==2)

    Matched                             1,070  (_merge==3)
    -----------------------------------------
*/

**drop if _merge==2 //do not drop these age groups as it skews pop_wpp 
** There are 5 unmatched records (_merge==2) since 2016 data doesn't have any cases of 5-9 female + male; 10-14 male; 15-19 male; 25-29 male

tab age5 ,m //none missing

drop case
gen case=1 if pid!="" //do not generate case for missing age group 0-14 as it skews case total
gen pfu=1 // for % year if not whole year collected; not done for cancer

list pid sex age5 if _merge==2 //missing are 5-9 male; 10-14 female + male; 20-24 female; 25-29 male
list pid sex age5 if _merge==2 ,nolabel

list pid sex age5 if age5==2 & (sex==1|sex==2)|age5==3 & sex==2|age5==4 & sex==2|age5==6 & sex==2 
replace case=0 if age5==2 & (sex==1|sex==2)|age5==3 & sex==2|age5==4 & sex==2|age5==6 & sex==2 //5 changes


** SF requested by email on 16-Oct-2020 age and sex specific rates for top 10 cancers
/*
What is age-specific incidence rate? 
Age-specific rates provide information on the incidence of a particular event in an age group relative to the total number of people at risk of that event in the same age group.

What is age-standardised incidence rate?
The age-standardized incidence rate is the summary rate that would have been observed, given the schedule of age-specific rates, in a population with the age composition of some reference population, often called the standard population.
*/
preserve
collapse (sum) case (mean) pop_wpp, by(pfu age5 sex siteiarc)
gen incirate=case/pop_wpp*100000
drop if siteiarc!=39 & siteiarc!=29 & siteiarc!=13 & siteiarc!=33 ///
		 & siteiarc!=21 & siteiarc!=14 & siteiarc!=55 & siteiarc!=11 ///
		 & siteiarc!=18 & siteiarc!=32
		
//by sex,sort: tab age5 incirate ,m
sort siteiarc age5 sex
//list incirate age5 sex
//list incirate age5 sex if siteiarc==13

format incirate %04.2f
gen year=2016
rename siteiarc cancer_site
rename incirate age_specific_rate
drop pfu case pop_wpp
order year cancer_site sex age5 age_specific_rate
save "`datapath'\version09\2-working\2016_top10_age+sex_rates" ,replace
restore

** NOTE: JC 29aug2022: For 2016-2018 annual report you need to perform age-specific rates not only on the top 10 according to 2018's top 10 but also according to 2016's top 10 as the age-specific rates are used based on the report year for the annual report.
preserve
collapse (sum) case (mean) pop_wpp, by(pfu age5 sex siteiarc)
gen incirate=case/pop_wpp*100000
drop if siteiarc!=39 & siteiarc!=29 & siteiarc!=13 & siteiarc!=33 ///
		& siteiarc!=55 & siteiarc!=18 & siteiarc!=14 & siteiarc!=21 ///
		& siteiarc!=53 & siteiarc!=11
		
//by sex,sort: tab age5 incirate ,m
sort siteiarc age5 sex
//list incirate age5 sex
//list incirate age5 sex if siteiarc==13

format incirate %04.2f
gen year=2016
rename siteiarc cancer_site
rename incirate age_specific_rate
drop pfu case pop_wpp
order year cancer_site sex age5 age_specific_rate
save "`datapath'\version09\2-working\2016_2018top10_age+sex_rates" ,replace
restore

** NOTE: JC 29aug2022: For 2016-2018 annual report you need to perform ASIRs not only on the top 10 according to 2018's top 10 but also according to 2016's top 10 as the ASIRs are used in different tables in the annual report.

** Check for missing age as these would need to be added to the median group for that site when assessing ASIRs to prevent creating an outlier
count if age==.|age==999 //5 - missing cases from pop ds

** Below saved in pathway: 
tab pop_wpp age5  if sex==1 //female
tab pop_wpp age5  if sex==2 //male

** Need an easier method for referencing population totals by sex instead of using Notepad as age5 has more groupings than using age_10 so can create the below ds and save to Notepad
preserve
contract sex pop_wpp age5
gen age5_id=age5
order sex age5_id age5 pop_wpp
drop _freq
sort sex age5_id
total pop_wpp
//method: run this code separately and save output in Notepad then re-run dofile
restore


*************************
** 2016 ASIRs based on **
**  2018 top 10 sites  **
*************************
** Next, IRs for invasive tumours only
preserve
	drop if age5==.
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** No missing age groups
		
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR ALL SITES (INVASIVE TUMOURS ONLY) - STD TO WHO WORLD POPN

/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  | 1070   285798   374.39    232.97   218.66   248.07     7.42 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
gen cancer_site=1
gen year=3
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse cancer_site year number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1070*100
replace percent=round(percent,0.01)

 
//JC 19may2022: rename breast to female breast as drop males in distrate breast section so ASMR for breast is calculated using female population
label define cancer_site_lab 1 "all" 2 "prostate" 3 "female breast" 4 "colon" 5 "corpus uteri" 6 "multiple myeloma" 7 "pancreas" ///
							 8 "rectum" 9 "lung" 10 "non-hodgkin lymphoma" 11 "stomach" ,modify
label values cancer_site cancer_site_lab
label define year_lab 1 "2018" 2 "2017" 3 "2016" 4 "2015" 5 "2014" 6 "2013" ,modify
label values year year_lab
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\2018ASIRs_2016" ,replace
restore

********************************
** Next, IRs by site and year **
********************************
** PROSTATE
tab pop_wpp age5 if siteiarc==39 //male

preserve
	drop if age5==. //0 deleted
	keep if siteiarc==39 // prostate only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39
	
	expand 2 in 1
	replace sex=2 in 11
	replace age5=1 in 11
	replace case=0 in 11
	replace pop_wpp=(7767) in 11
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 12
	replace age5=2 in 12
	replace case=0 in 12
	replace pop_wpp=(8720) in 12
	sort age5
	
	expand 2 in 1
	replace sex=2 in 13
	replace age5=3 in 13
	replace case=0 in 13
	replace pop_wpp=(9699) in 13
	sort age5
	
	expand 2 in 1
	replace sex=2 in 14
	replace age5=4 in 14
	replace case=0 in 14
	replace pop_wpp=(9660) in 14
	sort age5
	
	expand 2 in 1
	replace sex=2 in 15
	replace age5=5 in 15
	replace case=0 in 15
	replace pop_wpp=(9530) in 15
	sort age5
	
	expand 2 in 1
	replace sex=2 in 16
	replace age5=6 in 16
	replace case=0 in 16
	replace pop_wpp=(9113) in 16
	sort age5
	
	expand 2 in 1
	replace sex=2 in 17
	replace age5=7 in 17
	replace case=0 in 17
	replace pop_wpp=(9303) in 17
	sort age5
	
	expand 2 in 1
	replace sex=2 in 18
	replace age5=8 in 18
	replace case=0 in 18
	replace pop_wpp=(9265) in 18
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  287   137902   208.12    134.82   119.48   151.80     8.09 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1070*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\2018ASIRs_2016" 
replace cancer_site=2 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\2018ASIRs_2016" ,replace
restore


** BREAST - excluded male breast cancer
tab pop_wpp age5  if siteiarc==29 & sex==1 //female
tab pop_wpp age5  if siteiarc==29 & sex==2 //male

//JC 19may2022: remove male breast cancers so rate calculated only based on female pop
preserve
	drop if age5==.
	keep if siteiarc==29 //200 breast only 
	drop if sex==2 //1 deleted
	//excluded the 1 male as it would be potential confidential breach if reported separately
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-4,5-9,10-14,15-19,25-29
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=1 in 14
	replace case=0 in 14
	replace pop_wpp=(7473) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=2 in 15
	replace case=0 in 15
	replace pop_wpp=(8461) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=3 in 16
	replace case=0 in 16
	replace pop_wpp=(9184) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=4 in 17
	replace case=0 in 17
	replace pop_wpp=(9275) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=6 in 18
	replace case=0 in 18
	replace pop_wpp=(9133) in 18
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command
sort age5
total pop_wpp


distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BC (FEMALE) - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  149   147896   100.75     67.65    56.80    80.17     5.82 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1070*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\2018ASIRs_2016" 
replace cancer_site=3 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\2018ASIRs_2016" ,replace
restore


** COLON 
tab pop_wpp age5  if siteiarc==13 & sex==1 //female
tab pop_wpp age5  if siteiarc==13 & sex==2 //male

preserve
	drop if age5==.
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,40-44
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=1 in 19
	replace case=0 in 19
	replace pop_wpp=(7473) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=2 in 20
	replace case=0 in 20
	replace pop_wpp=(8461) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=3 in 21
	replace case=0 in 21
	replace pop_wpp=(9184) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=4 in 22
	replace case=0 in 22
	replace pop_wpp=(9275) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=5 in 23
	replace case=0 in 23
	replace pop_wpp=(9470) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=6 in 24
	replace case=0 in 24
	replace pop_wpp=(9133) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=7 in 25
	replace case=0 in 25
	replace pop_wpp=(9725) in 25
	sort age5
	
	expand 2 in 1
	replace sex=1 in 26
	replace age5=8 in 26
	replace case=0 in 26
	replace pop_wpp=(9612) in 26
	sort age5
	
	expand 2 in 1
	replace sex=1 in 27
	replace age5=9 in 27
	replace case=0 in 27
	replace pop_wpp=(10504) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=1 in 28
	replace case=0 in 28
	replace pop_wpp=(7767) in 28
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=2 in 29
	replace case=0 in 29
	replace pop_wpp=(8720) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=3 in 30
	replace case=0 in 30
	replace pop_wpp=(9699) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=4 in 31
	replace case=0 in 31
	replace pop_wpp=(9660) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=5 in 32
	replace case=0 in 32
	replace pop_wpp=(9530) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=6 in 33
	replace case=0 in 33
	replace pop_wpp=(9113) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=7 in 34
	replace case=0 in 34
	replace pop_wpp=(9303) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=8 in 35
	replace case=0 in 35
	replace pop_wpp=(9265) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=9 in 36
	replace case=0 in 36
	replace pop_wpp=(9814) in 36
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  112   285798   39.19     22.92    18.76    27.88     2.26 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1070*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\2018ASIRs_2016" 
replace cancer_site=4 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\2018ASIRs_2016" ,replace
restore


** CORPUS UTERI
tab pop_wpp age5 if siteiarc==33

preserve
	drop if age5==.
	keep if siteiarc==33 // corpus uteri only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,45-49
	
	expand 2 in 1
	replace sex=1 in 10
	replace age5=1 in 10
	replace case=0 in 10
	replace pop_wpp=(7473) in 10
	sort age5
	
	expand 2 in 1
	replace sex=1 in 11
	replace age5=2 in 11
	replace case=0 in 11
	replace pop_wpp=(8461) in 11
	sort age5
	
	expand 2 in 1
	replace sex=1 in 12
	replace age5=3 in 12
	replace case=0 in 12
	replace pop_wpp=(9184) in 12
	sort age5
	
	expand 2 in 1
	replace sex=1 in 13
	replace age5=4 in 13
	replace case=0 in 13
	replace pop_wpp=(9275) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=5 in 14
	replace case=0 in 14
	replace pop_wpp=(9470) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=6 in 15
	replace case=0 in 15
	replace pop_wpp=(9133) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=7 in 16
	replace case=0 in 16
	replace pop_wpp=(9725) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=8 in 17
	replace case=0 in 17
	replace pop_wpp=(9612) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=10 in 18
	replace case=0 in 18
	replace pop_wpp=(10388) in 18
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CORPUS UTERI - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   48   147896   32.46     18.38    13.43    24.92     2.81 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1070*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\2018ASIRs_2016" 
replace cancer_site=5 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\2018ASIRs_2016" ,replace
restore


** MULTIPLE MYELOMA
tab pop_wpp age5 if siteiarc==55 & sex==1 //female
tab pop_wpp age5 if siteiarc==55 & sex==2 //male

preserve
	drop if age5==.
	keep if siteiarc==55
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,40-44
	** F   45-49,85+
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=1 in 17
	replace case=0 in 17
	replace pop_wpp=(7473) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=2 in 18
	replace case=0 in 18
	replace pop_wpp=(8461) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=3 in 19
	replace case=0 in 19
	replace pop_wpp=(9184) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=4 in 20
	replace case=0 in 20
	replace pop_wpp=(9275) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=5 in 21
	replace case=0 in 21
	replace pop_wpp=(9470) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=6 in 22
	replace case=0 in 22
	replace pop_wpp=(9133) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=7 in 23
	replace case=0 in 23
	replace pop_wpp=(9725) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=8 in 24
	replace case=0 in 24
	replace pop_wpp=(9612) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=9 in 25
	replace case=0 in 25
	replace pop_wpp=(10504) in 25
	sort age5
	
	expand 2 in 1
	replace sex=1 in 26
	replace age5=10 in 26
	replace case=0 in 26
	replace pop_wpp=(10388) in 26
	sort age5
	
	expand 2 in 1
	replace sex=1 in 27
	replace age5=18 in 27
	replace case=0 in 27
	replace pop_wpp=(4047) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=1 in 28
	replace case=0 in 28
	replace pop_wpp=(7767) in 28
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=2 in 29
	replace case=0 in 29
	replace pop_wpp=(8720) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=3 in 30
	replace case=0 in 30
	replace pop_wpp=(9699) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=4 in 31
	replace case=0 in 31
	replace pop_wpp=(9660) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=5 in 32
	replace case=0 in 32
	replace pop_wpp=(9530) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=6 in 33
	replace case=0 in 33
	replace pop_wpp=(9113) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=7 in 34
	replace case=0 in 34
	replace pop_wpp=(9303) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=8 in 35
	replace case=0 in 35
	replace pop_wpp=(9265) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=9 in 36
	replace case=0 in 36
	replace pop_wpp=(9814) in 36
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR MULTIPLE MYELOMA CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   35   285798   12.25      7.38     5.10    10.50     1.32 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1070*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\2018ASIRs_2016" 
replace cancer_site=6 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\2018ASIRs_2016" ,replace
restore


** PANCREAS 
tab pop_wpp age5  if siteiarc==18 & sex==1 //female
tab pop_wpp age5  if siteiarc==18 & sex==2 //male

preserve
	drop if age5==.
	keep if siteiarc==18
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,40-44,45-49
	** F   55-59,70-74
	** M   85+

	expand 2 in 1
	replace sex=1 in 14
	replace age5=1 in 14
	replace case=0 in 14
	replace pop_wpp=(7473) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=2 in 15
	replace case=0 in 15
	replace pop_wpp=(8461) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=3 in 16
	replace case=0 in 16
	replace pop_wpp=(9184) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=4 in 17
	replace case=0 in 17
	replace pop_wpp=(9275) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=5 in 18
	replace case=0 in 18
	replace pop_wpp=(9470) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=6 in 19
	replace case=0 in 19
	replace pop_wpp=(9133) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=7 in 20
	replace case=0 in 20
	replace pop_wpp=(9725) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=8 in 21
	replace case=0 in 21
	replace pop_wpp=(9612) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=9 in 22
	replace case=0 in 22
	replace pop_wpp=(10504) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=10 in 23
	replace case=0 in 23
	replace pop_wpp=(10388) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=12 in 24
	replace case=0 in 24
	replace pop_wpp=(10593) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=15 in 25
	replace case=0 in 25
	replace pop_wpp=(5433) in 25
	sort age5
	
	expand 2 in 1
	replace sex=2 in 26
	replace age5=1 in 26
	replace case=0 in 26
	replace pop_wpp=(7767) in 26
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 27
	replace age5=2 in 27
	replace case=0 in 27
	replace pop_wpp=(8720) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=3 in 28
	replace case=0 in 28
	replace pop_wpp=(9699) in 28
	sort age5
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=4 in 29
	replace case=0 in 29
	replace pop_wpp=(9660) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=5 in 30
	replace case=0 in 30
	replace pop_wpp=(9530) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=6 in 31
	replace case=0 in 31
	replace pop_wpp=(9113) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=7 in 32
	replace case=0 in 32
	replace pop_wpp=(9303) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=8 in 33
	replace case=0 in 33
	replace pop_wpp=(9265) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=9 in 34
	replace case=0 in 34
	replace pop_wpp=(9814) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=10 in 35
	replace case=0 in 35
	replace pop_wpp=(9620) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=18 in 36
	replace case=0 in 36
	replace pop_wpp=(2553) in 36
	sort age5
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PANCREATIC CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   29   285798   10.15      5.85     3.88     8.67     1.17 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1070*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\2018ASIRs_2016" 
replace cancer_site=7 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\2018ASIRs_2016" ,replace
restore


** RECTUM 
tab pop_wpp age5  if siteiarc==14 & sex==1 //female
tab pop_wpp age5  if siteiarc==14 & sex==2 //male

preserve
	drop if age5==.
	keep if siteiarc==14
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34
	** F   35-39,40-44,70-74
	** M   55-59

	expand 2 in 1
	replace sex=1 in 19
	replace age5=1 in 19
	replace case=0 in 19
	replace pop_wpp=(7473) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=2 in 20
	replace case=0 in 20
	replace pop_wpp=(8461) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=3 in 21
	replace case=0 in 21
	replace pop_wpp=(9184) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=4 in 22
	replace case=0 in 22
	replace pop_wpp=(9275) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=5 in 23
	replace case=0 in 23
	replace pop_wpp=(9470) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=6 in 24
	replace case=0 in 24
	replace pop_wpp=(9133) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=7 in 25
	replace case=0 in 25
	replace pop_wpp=(9725) in 25
	sort age5
	
	expand 2 in 1
	replace sex=1 in 26
	replace age5=8 in 26
	replace case=0 in 26
	replace pop_wpp=(9612) in 26
	sort age5
	
	expand 2 in 1
	replace sex=1 in 27
	replace age5=9 in 27
	replace case=0 in 27
	replace pop_wpp=(10504) in 27
	sort age5
	
	expand 2 in 1
	replace sex=1 in 28
	replace age5=15 in 28
	replace case=0 in 28
	replace pop_wpp=(5433) in 28
	sort age5
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=1 in 29
	replace case=0 in 29
	replace pop_wpp=(7767) in 29
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=2 in 30
	replace case=0 in 30
	replace pop_wpp=(8720) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=3 in 31
	replace case=0 in 31
	replace pop_wpp=(9699) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=4 in 32
	replace case=0 in 32
	replace pop_wpp=(9660) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=5 in 33
	replace case=0 in 33
	replace pop_wpp=(9530) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=6 in 34
	replace case=0 in 34
	replace pop_wpp=(9113) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=7 in 35
	replace case=0 in 35
	replace pop_wpp=(9303) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=12 in 36
	replace case=0 in 36
	replace pop_wpp=(9205) in 36
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RECTAL CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   42   285798   14.70      8.97     6.37    12.42     1.48 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1070*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\2018ASIRs_2016" 
replace cancer_site=8 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\2018ASIRs_2016" ,replace
restore


** LUNG
tab pop_wpp age5 if siteiarc==21 & sex==1 //female
tab pop_wpp age5 if siteiarc==21 & sex==2 //male

preserve
	drop if age5==.
	keep if siteiarc==21
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,40-44,45-49
	** F   50-54,55-59,60-64
	** M   35-39
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=1 in 16
	replace case=0 in 16
	replace pop_wpp=(7473) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=2 in 17
	replace case=0 in 17
	replace pop_wpp=(8461) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=3 in 18
	replace case=0 in 18
	replace pop_wpp=(9184) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=4 in 19
	replace case=0 in 19
	replace pop_wpp=(9275) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=5 in 20
	replace case=0 in 20
	replace pop_wpp=(9470) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=6 in 21
	replace case=0 in 21
	replace pop_wpp=(9133) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=7 in 22
	replace case=0 in 22
	replace pop_wpp=(9725) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=9 in 23
	replace case=0 in 23
	replace pop_wpp=(10504) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=10 in 24
	replace case=0 in 24
	replace pop_wpp=(10388) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=11 in 25
	replace case=0 in 25
	replace pop_wpp=(11029) in 25
	sort age5
	
	expand 2 in 1
	replace sex=1 in 26
	replace age5=12 in 26
	replace case=0 in 26
	replace pop_wpp=(10593) in 26
	sort age5
	
	expand 2 in 1
	replace sex=1 in 27
	replace age5=13 in 27
	replace case=0 in 27
	replace pop_wpp=(8802) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=1 in 28
	replace case=0 in 28
	replace pop_wpp=(7767) in 28
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=2 in 29
	replace case=0 in 29
	replace pop_wpp=(8720) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=3 in 30
	replace case=0 in 30
	replace pop_wpp=(9699) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=4 in 31
	replace case=0 in 31
	replace pop_wpp=(9660) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=5 in 32
	replace case=0 in 32
	replace pop_wpp=(9530) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=6 in 33
	replace case=0 in 33
	replace pop_wpp=(9113) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=7 in 34
	replace case=0 in 34
	replace pop_wpp=(9303) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=8 in 35
	replace case=0 in 35
	replace pop_wpp=(9265) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=10 in 36
	replace case=0 in 36
	replace pop_wpp=(9620) in 36
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR LUNG CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   42   285798   14.70      8.74     6.21    12.11     1.45 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1070*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\2018ASIRs_2016" 
replace cancer_site=9 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\2018ASIRs_2016" ,replace
restore


** NON-HODGKIN LYMPHOMA 
tab pop_wpp age5  if siteiarc==53 & sex==1 //female
tab pop_wpp age5  if siteiarc==53 & sex==2 //male

preserve
	drop if age5==.
	keep if siteiarc==53
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-4,5-9,10-14,15-19,30-34,35-39,40-44,45-49,80-84
	** F   20-24,50-54,60-64
	** M   25-29,85+
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=1 in 14
	replace case=0 in 14
	replace pop_wpp=(7473) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=2 in 15
	replace case=0 in 15
	replace pop_wpp=(8461) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=3 in 16
	replace case=0 in 16
	replace pop_wpp=(9184) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=4 in 17
	replace case=0 in 17
	replace pop_wpp=(9275) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=5 in 18
	replace case=0 in 18
	replace pop_wpp=(9470) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=7 in 19
	replace case=0 in 19
	replace pop_wpp=(9725) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=8 in 20
	replace case=0 in 20
	replace pop_wpp=(9612) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=9 in 21
	replace case=0 in 21
	replace pop_wpp=(10504) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=10 in 22
	replace case=0 in 22
	replace pop_wpp=(10388) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=11 in 23
	replace case=0 in 23
	replace pop_wpp=(11029) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=13 in 24
	replace case=0 in 24
	replace pop_wpp=(8802) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=17 in 25
	replace case=0 in 25
	replace pop_wpp=(3295) in 25
	sort age5
	
	expand 2 in 1
	replace sex=2 in 26
	replace age5=1 in 26
	replace case=0 in 26
	replace pop_wpp=(7767) in 26
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 27
	replace age5=2 in 27
	replace case=0 in 27
	replace pop_wpp=(8720) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=3 in 28
	replace case=0 in 28
	replace pop_wpp=(9699) in 28
	sort age5
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=4 in 29
	replace case=0 in 29
	replace pop_wpp=(9660) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=6 in 30
	replace case=0 in 30
	replace pop_wpp=(9113) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=7 in 31
	replace case=0 in 31
	replace pop_wpp=(9303) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=8 in 32
	replace case=0 in 32
	replace pop_wpp=(9265) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=9 in 33
	replace case=0 in 33
	replace pop_wpp=(9814) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=10 in 34
	replace case=0 in 34
	replace pop_wpp=(9620) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=17 in 35
	replace case=0 in 35
	replace pop_wpp=(2311) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=18 in 36
	replace case=0 in 36
	replace pop_wpp=(2553) in 36
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR NHL (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   19   285798    6.65      4.45     2.59     7.24     1.13 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1070*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\2018ASIRs_2016" 
replace cancer_site=10 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\2018ASIRs_2016" ,replace
restore


** STOMACH 
tab pop_wpp age5  if siteiarc==11 & sex==1 //female
tab pop_wpp age5  if siteiarc==11 & sex==2 //male

preserve
	drop if age5==.
	keep if siteiarc==11
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F  0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,40-44,45-49,50-54,60-64
	** F 	55-59,70-74
	
	expand 2 in 1
	replace sex=1 in 11
	replace age5=1 in 11
	replace case=0 in 11
	replace pop_wpp=(7473) in 11
	sort age5
	
	expand 2 in 1
	replace sex=1 in 12
	replace age5=2 in 12
	replace case=0 in 12
	replace pop_wpp=(8461) in 12
	sort age5
	
	expand 2 in 1
	replace sex=1 in 13
	replace age5=3 in 13
	replace case=0 in 13
	replace pop_wpp=(9184) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=4 in 14
	replace case=0 in 14
	replace pop_wpp=(9275) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=5 in 15
	replace case=0 in 15
	replace pop_wpp=(9470) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=6 in 16
	replace case=0 in 16
	replace pop_wpp=(9133) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=7 in 17
	replace case=0 in 17
	replace pop_wpp=(9725) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=8 in 18
	replace case=0 in 18
	replace pop_wpp=(9612) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=9 in 19
	replace case=0 in 19
	replace pop_wpp=(10504) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=10 in 20
	replace case=0 in 20
	replace pop_wpp=(10388) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=11 in 21
	replace case=0 in 21
	replace pop_wpp=(11029) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=12 in 22
	replace case=0 in 22
	replace pop_wpp=(10593) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=13 in 23
	replace case=0 in 23
	replace pop_wpp=(8802) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=15 in 24
	replace case=0 in 24
	replace pop_wpp=(5433) in 24
	sort age5
	
	expand 2 in 1
	replace sex=2 in 25
	replace age5=1 in 25
	replace case=0 in 25
	replace pop_wpp=(7767) in 25
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 26
	replace age5=2 in 26
	replace case=0 in 26
	replace pop_wpp=(8720) in 26
	sort age5
	
	expand 2 in 1
	replace sex=2 in 27
	replace age5=3 in 27
	replace case=0 in 27
	replace pop_wpp=(9699) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=4 in 28
	replace case=0 in 28
	replace pop_wpp=(9660) in 28
	sort age5
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=5 in 29
	replace case=0 in 29
	replace pop_wpp=(9530) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=6 in 30
	replace case=0 in 30
	replace pop_wpp=(9113) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=7 in 31
	replace case=0 in 31
	replace pop_wpp=(9303) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=8 in 32
	replace case=0 in 32
	replace pop_wpp=(9265) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=9 in 33
	replace case=0 in 33
	replace pop_wpp=(9814) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=10 in 34
	replace case=0 in 34
	replace pop_wpp=(9620) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=11 in 35
	replace case=0 in 35
	replace pop_wpp=(9795) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=13 in 36
	replace case=0 in 36
	replace pop_wpp=(7664) in 36
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR STOMACH CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   30   285798   10.50      5.00     3.31     7.49     1.02 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1070*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\2018ASIRs_2016" 
replace cancer_site=11 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\2018ASIRs_2016" ,replace
restore

*************************
** 2016 ASIRs based on **
**  2016 top 10 sites  **
*************************
** Next, IRs for invasive tumours only
preserve
	drop if age5==.
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** No missing age groups
		
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR ALL SITES (INVASIVE TUMOURS ONLY) - STD TO WHO WORLD POPN

/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  | 1070   285798   374.39    232.97   218.66   248.07     7.42 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
gen cancer_site=1
gen year=3
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse cancer_site year number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1070*100
replace percent=round(percent,0.01)

 
//JC 19may2022: rename breast to female breast as drop males in distrate breast section so ASMR for breast is calculated using female population
label define cancer_site_lab 1 "all" 2 "prostate" 3 "female breast" 4 "colon" 5 "corpus uteri" 6 "lung" 7 "rectum" ///
							 8 "multiple myeloma" 9 "stomach" 10 "pancreas" 11 "cervix uteri" ,modify
label values cancer_site cancer_site_lab
label define year_lab 1 "2018" 2 "2017" 3 "2016" 4 "2015" 5 "2014" 6 "2013" ,modify
label values year year_lab
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_2016" ,replace
restore


** Next, IRs for invasive tumours FEMALE only
preserve
	drop if age5==.
	drop if sex==2 //579 deleted
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** No missing age groups
		
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR ALL SITES (INVASIVE TUMOURS ONLY-FEMALE) - STD TO WHO WORLD POPN

/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  491   147896   331.99    201.85   183.24   222.03     9.75 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
gen cancer_site=1
gen year=3
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse cancer_site year number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1070*100
replace percent=round(percent,0.01)

label define cancer_site_lab 1 "all" 2 "female breast" 3 "colon" 4 "corpus uteri" 5 "cervix uteri" 6 "ovary" ,modify
label values cancer_site cancer_site_lab
label define year_lab 1 "2018" 2 "2017" 3 "2016" ,modify
label values year year_lab
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_2016_female" ,replace
restore


** Next, IRs for invasive tumours MALE only
preserve
	drop if age5==.
	drop if sex==1 //491 deleted
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** No missing age groups
		
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR ALL SITES (INVASIVE TUMOURS ONLY-MALE) - STD TO WHO WORLD POPN

/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  579   137902   419.86    273.78   251.49   297.73    11.64 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
gen cancer_site=1
gen year=3
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse cancer_site year number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1070*100
replace percent=round(percent,0.01)

label define cancer_site_lab 1 "all" 2 "prostate" 3 "colon" 4 "lung" 5 "rectum" 6 "stomach" 7 "multiple myeloma" ,modify
label values cancer_site cancer_site_lab
label define year_lab 1 "2018" 2 "2017" 3 "2016" ,modify
label values year year_lab
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_2016_male" ,replace
restore


********************************
** Next, IRs by site and year **
********************************
** PROSTATE
tab pop_wpp age5 if siteiarc==39 //male

preserve
	drop if age5==. //0 deleted
	keep if siteiarc==39 // prostate only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39
	
	expand 2 in 1
	replace sex=2 in 11
	replace age5=1 in 11
	replace case=0 in 11
	replace pop_wpp=(7767) in 11
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 12
	replace age5=2 in 12
	replace case=0 in 12
	replace pop_wpp=(8720) in 12
	sort age5
	
	expand 2 in 1
	replace sex=2 in 13
	replace age5=3 in 13
	replace case=0 in 13
	replace pop_wpp=(9699) in 13
	sort age5
	
	expand 2 in 1
	replace sex=2 in 14
	replace age5=4 in 14
	replace case=0 in 14
	replace pop_wpp=(9660) in 14
	sort age5
	
	expand 2 in 1
	replace sex=2 in 15
	replace age5=5 in 15
	replace case=0 in 15
	replace pop_wpp=(9530) in 15
	sort age5
	
	expand 2 in 1
	replace sex=2 in 16
	replace age5=6 in 16
	replace case=0 in 16
	replace pop_wpp=(9113) in 16
	sort age5
	
	expand 2 in 1
	replace sex=2 in 17
	replace age5=7 in 17
	replace case=0 in 17
	replace pop_wpp=(9303) in 17
	sort age5
	
	expand 2 in 1
	replace sex=2 in 18
	replace age5=8 in 18
	replace case=0 in 18
	replace pop_wpp=(9265) in 18
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  287   137902   208.12    134.82   119.48   151.80     8.09 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1070*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_2016" 
replace cancer_site=2 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_2016" ,replace
restore

** PROSTATE - for male top5 table
tab pop_wpp age5 if siteiarc==39 //male

preserve
	drop if age5==. //0 deleted
	keep if siteiarc==39 // prostate only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39
	
	expand 2 in 1
	replace sex=2 in 11
	replace age5=1 in 11
	replace case=0 in 11
	replace pop_wpp=(7767) in 11
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 12
	replace age5=2 in 12
	replace case=0 in 12
	replace pop_wpp=(8720) in 12
	sort age5
	
	expand 2 in 1
	replace sex=2 in 13
	replace age5=3 in 13
	replace case=0 in 13
	replace pop_wpp=(9699) in 13
	sort age5
	
	expand 2 in 1
	replace sex=2 in 14
	replace age5=4 in 14
	replace case=0 in 14
	replace pop_wpp=(9660) in 14
	sort age5
	
	expand 2 in 1
	replace sex=2 in 15
	replace age5=5 in 15
	replace case=0 in 15
	replace pop_wpp=(9530) in 15
	sort age5
	
	expand 2 in 1
	replace sex=2 in 16
	replace age5=6 in 16
	replace case=0 in 16
	replace pop_wpp=(9113) in 16
	sort age5
	
	expand 2 in 1
	replace sex=2 in 17
	replace age5=7 in 17
	replace case=0 in 17
	replace pop_wpp=(9303) in 17
	sort age5
	
	expand 2 in 1
	replace sex=2 in 18
	replace age5=8 in 18
	replace case=0 in 18
	replace pop_wpp=(9265) in 18
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  287   137902   208.12    134.82   119.48   151.80     8.09 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/579*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_2016_male" 
replace cancer_site=2 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_2016_male" ,replace
restore


** BREAST - excluded male breast cancer
tab pop_wpp age5  if siteiarc==29 & sex==1 //female
tab pop_wpp age5  if siteiarc==29 & sex==2 //male

//JC 19may2022: remove male breast cancers so rate calculated only based on female pop
preserve
	drop if age5==.
	keep if siteiarc==29 //200 breast only 
	drop if sex==2 //1 deleted
	//excluded the 1 male as it would be potential confidential breach if reported separately
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-4,5-9,10-14,15-19,25-29
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=1 in 14
	replace case=0 in 14
	replace pop_wpp=(7473) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=2 in 15
	replace case=0 in 15
	replace pop_wpp=(8461) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=3 in 16
	replace case=0 in 16
	replace pop_wpp=(9184) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=4 in 17
	replace case=0 in 17
	replace pop_wpp=(9275) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=6 in 18
	replace case=0 in 18
	replace pop_wpp=(9133) in 18
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command
sort age5
total pop_wpp


distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BC (FEMALE) - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  149   147896   100.75     67.65    56.80    80.17     5.82 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1070*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_2016" 
replace cancer_site=3 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_2016" ,replace
restore

** BREAST - for female top5 table
tab pop_wpp age5  if siteiarc==29 & sex==1 //female
tab pop_wpp age5  if siteiarc==29 & sex==2 //male

preserve
	drop if age5==.
	keep if siteiarc==29 //200 breast only 
	drop if sex==2 //1 deleted
	//excluded the 1 male as it would be potential confidential breach if reported separately
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-4,5-9,10-14,15-19,25-29
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=1 in 14
	replace case=0 in 14
	replace pop_wpp=(7473) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=2 in 15
	replace case=0 in 15
	replace pop_wpp=(8461) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=3 in 16
	replace case=0 in 16
	replace pop_wpp=(9184) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=4 in 17
	replace case=0 in 17
	replace pop_wpp=(9275) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=6 in 18
	replace case=0 in 18
	replace pop_wpp=(9133) in 18
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command
sort age5
total pop_wpp


distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BC (FEMALE) - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  149   147896   100.75     67.65    56.80    80.17     5.82 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/491*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_2016_female" 
replace cancer_site=2 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_2016_female" ,replace
restore


** COLON 
tab pop_wpp age5  if siteiarc==13 & sex==1 //female
tab pop_wpp age5  if siteiarc==13 & sex==2 //male

preserve
	drop if age5==.
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,40-44
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=1 in 19
	replace case=0 in 19
	replace pop_wpp=(7473) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=2 in 20
	replace case=0 in 20
	replace pop_wpp=(8461) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=3 in 21
	replace case=0 in 21
	replace pop_wpp=(9184) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=4 in 22
	replace case=0 in 22
	replace pop_wpp=(9275) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=5 in 23
	replace case=0 in 23
	replace pop_wpp=(9470) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=6 in 24
	replace case=0 in 24
	replace pop_wpp=(9133) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=7 in 25
	replace case=0 in 25
	replace pop_wpp=(9725) in 25
	sort age5
	
	expand 2 in 1
	replace sex=1 in 26
	replace age5=8 in 26
	replace case=0 in 26
	replace pop_wpp=(9612) in 26
	sort age5
	
	expand 2 in 1
	replace sex=1 in 27
	replace age5=9 in 27
	replace case=0 in 27
	replace pop_wpp=(10504) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=1 in 28
	replace case=0 in 28
	replace pop_wpp=(7767) in 28
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=2 in 29
	replace case=0 in 29
	replace pop_wpp=(8720) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=3 in 30
	replace case=0 in 30
	replace pop_wpp=(9699) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=4 in 31
	replace case=0 in 31
	replace pop_wpp=(9660) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=5 in 32
	replace case=0 in 32
	replace pop_wpp=(9530) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=6 in 33
	replace case=0 in 33
	replace pop_wpp=(9113) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=7 in 34
	replace case=0 in 34
	replace pop_wpp=(9303) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=8 in 35
	replace case=0 in 35
	replace pop_wpp=(9265) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=9 in 36
	replace case=0 in 36
	replace pop_wpp=(9814) in 36
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  112   285798   39.19     22.92    18.76    27.88     2.26 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1070*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_2016" 
replace cancer_site=4 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_2016" ,replace
restore

** COLON - female only for top5 table
preserve
	drop if age5==.
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,40-44
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=1 in 19
	replace case=0 in 19
	replace pop_wpp=(7473) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=2 in 20
	replace case=0 in 20
	replace pop_wpp=(8461) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=3 in 21
	replace case=0 in 21
	replace pop_wpp=(9184) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=4 in 22
	replace case=0 in 22
	replace pop_wpp=(9275) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=5 in 23
	replace case=0 in 23
	replace pop_wpp=(9470) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=6 in 24
	replace case=0 in 24
	replace pop_wpp=(9133) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=7 in 25
	replace case=0 in 25
	replace pop_wpp=(9725) in 25
	sort age5
	
	expand 2 in 1
	replace sex=1 in 26
	replace age5=8 in 26
	replace case=0 in 26
	replace pop_wpp=(9612) in 26
	sort age5
	
	expand 2 in 1
	replace sex=1 in 27
	replace age5=9 in 27
	replace case=0 in 27
	replace pop_wpp=(10504) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=1 in 28
	replace case=0 in 28
	replace pop_wpp=(7767) in 28
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=2 in 29
	replace case=0 in 29
	replace pop_wpp=(8720) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=3 in 30
	replace case=0 in 30
	replace pop_wpp=(9699) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=4 in 31
	replace case=0 in 31
	replace pop_wpp=(9660) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=5 in 32
	replace case=0 in 32
	replace pop_wpp=(9530) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=6 in 33
	replace case=0 in 33
	replace pop_wpp=(9113) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=7 in 34
	replace case=0 in 34
	replace pop_wpp=(9303) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=8 in 35
	replace case=0 in 35
	replace pop_wpp=(9265) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=9 in 36
	replace case=0 in 36
	replace pop_wpp=(9814) in 36
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

drop if sex==2 //female ONLY

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (FEMALE)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   60   147896   40.57     22.88    17.27    30.07     3.15 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/491*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_2016_female" 
replace cancer_site=3 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_2016_female" ,replace
restore

** COLON - male only for top5 table
preserve
	drop if age5==.
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,40-44
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=1 in 19
	replace case=0 in 19
	replace pop_wpp=(7473) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=2 in 20
	replace case=0 in 20
	replace pop_wpp=(8461) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=3 in 21
	replace case=0 in 21
	replace pop_wpp=(9184) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=4 in 22
	replace case=0 in 22
	replace pop_wpp=(9275) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=5 in 23
	replace case=0 in 23
	replace pop_wpp=(9470) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=6 in 24
	replace case=0 in 24
	replace pop_wpp=(9133) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=7 in 25
	replace case=0 in 25
	replace pop_wpp=(9725) in 25
	sort age5
	
	expand 2 in 1
	replace sex=1 in 26
	replace age5=8 in 26
	replace case=0 in 26
	replace pop_wpp=(9612) in 26
	sort age5
	
	expand 2 in 1
	replace sex=1 in 27
	replace age5=9 in 27
	replace case=0 in 27
	replace pop_wpp=(10504) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=1 in 28
	replace case=0 in 28
	replace pop_wpp=(7767) in 28
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=2 in 29
	replace case=0 in 29
	replace pop_wpp=(8720) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=3 in 30
	replace case=0 in 30
	replace pop_wpp=(9699) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=4 in 31
	replace case=0 in 31
	replace pop_wpp=(9660) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=5 in 32
	replace case=0 in 32
	replace pop_wpp=(9530) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=6 in 33
	replace case=0 in 33
	replace pop_wpp=(9113) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=7 in 34
	replace case=0 in 34
	replace pop_wpp=(9303) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=8 in 35
	replace case=0 in 35
	replace pop_wpp=(9265) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=9 in 36
	replace case=0 in 36
	replace pop_wpp=(9814) in 36
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

drop if sex==1 //male ONLY

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (MALE)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   52   137902   37.71     23.39    17.36    31.15     3.39 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/579*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_2016_male" 
replace cancer_site=3 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_2016_male" ,replace
restore


** CORPUS UTERI
tab pop_wpp age5 if siteiarc==33

preserve
	drop if age5==.
	keep if siteiarc==33 // corpus uteri only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,45-49
	
	expand 2 in 1
	replace sex=1 in 10
	replace age5=1 in 10
	replace case=0 in 10
	replace pop_wpp=(7473) in 10
	sort age5
	
	expand 2 in 1
	replace sex=1 in 11
	replace age5=2 in 11
	replace case=0 in 11
	replace pop_wpp=(8461) in 11
	sort age5
	
	expand 2 in 1
	replace sex=1 in 12
	replace age5=3 in 12
	replace case=0 in 12
	replace pop_wpp=(9184) in 12
	sort age5
	
	expand 2 in 1
	replace sex=1 in 13
	replace age5=4 in 13
	replace case=0 in 13
	replace pop_wpp=(9275) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=5 in 14
	replace case=0 in 14
	replace pop_wpp=(9470) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=6 in 15
	replace case=0 in 15
	replace pop_wpp=(9133) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=7 in 16
	replace case=0 in 16
	replace pop_wpp=(9725) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=8 in 17
	replace case=0 in 17
	replace pop_wpp=(9612) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=10 in 18
	replace case=0 in 18
	replace pop_wpp=(10388) in 18
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CORPUS UTERI - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   48   147896   32.46     18.38    13.43    24.92     2.81 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1070*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_2016" 
replace cancer_site=5 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_2016" ,replace
restore

** CORPUS UTERI - for female top 5 table
preserve
	drop if age5==.
	keep if siteiarc==33 // corpus uteri only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,45-49
	
	expand 2 in 1
	replace sex=1 in 10
	replace age5=1 in 10
	replace case=0 in 10
	replace pop_wpp=(7473) in 10
	sort age5
	
	expand 2 in 1
	replace sex=1 in 11
	replace age5=2 in 11
	replace case=0 in 11
	replace pop_wpp=(8461) in 11
	sort age5
	
	expand 2 in 1
	replace sex=1 in 12
	replace age5=3 in 12
	replace case=0 in 12
	replace pop_wpp=(9184) in 12
	sort age5
	
	expand 2 in 1
	replace sex=1 in 13
	replace age5=4 in 13
	replace case=0 in 13
	replace pop_wpp=(9275) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=5 in 14
	replace case=0 in 14
	replace pop_wpp=(9470) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=6 in 15
	replace case=0 in 15
	replace pop_wpp=(9133) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=7 in 16
	replace case=0 in 16
	replace pop_wpp=(9725) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=8 in 17
	replace case=0 in 17
	replace pop_wpp=(9612) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=10 in 18
	replace case=0 in 18
	replace pop_wpp=(10388) in 18
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CORPUS UTERI - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   48   147896   32.46     18.38    13.43    24.92     2.81 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/491*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_2016_female" 
replace cancer_site=4 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_2016_female" ,replace
restore


** LUNG
tab pop_wpp age5 if siteiarc==21 & sex==1 //female
tab pop_wpp age5 if siteiarc==21 & sex==2 //male

preserve
	drop if age5==.
	keep if siteiarc==21
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,40-44,45-49
	** F   50-54,55-59,60-64
	** M   35-39
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=1 in 16
	replace case=0 in 16
	replace pop_wpp=(7473) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=2 in 17
	replace case=0 in 17
	replace pop_wpp=(8461) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=3 in 18
	replace case=0 in 18
	replace pop_wpp=(9184) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=4 in 19
	replace case=0 in 19
	replace pop_wpp=(9275) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=5 in 20
	replace case=0 in 20
	replace pop_wpp=(9470) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=6 in 21
	replace case=0 in 21
	replace pop_wpp=(9133) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=7 in 22
	replace case=0 in 22
	replace pop_wpp=(9725) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=9 in 23
	replace case=0 in 23
	replace pop_wpp=(10504) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=10 in 24
	replace case=0 in 24
	replace pop_wpp=(10388) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=11 in 25
	replace case=0 in 25
	replace pop_wpp=(11029) in 25
	sort age5
	
	expand 2 in 1
	replace sex=1 in 26
	replace age5=12 in 26
	replace case=0 in 26
	replace pop_wpp=(10593) in 26
	sort age5
	
	expand 2 in 1
	replace sex=1 in 27
	replace age5=13 in 27
	replace case=0 in 27
	replace pop_wpp=(8802) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=1 in 28
	replace case=0 in 28
	replace pop_wpp=(7767) in 28
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=2 in 29
	replace case=0 in 29
	replace pop_wpp=(8720) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=3 in 30
	replace case=0 in 30
	replace pop_wpp=(9699) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=4 in 31
	replace case=0 in 31
	replace pop_wpp=(9660) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=5 in 32
	replace case=0 in 32
	replace pop_wpp=(9530) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=6 in 33
	replace case=0 in 33
	replace pop_wpp=(9113) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=7 in 34
	replace case=0 in 34
	replace pop_wpp=(9303) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=8 in 35
	replace case=0 in 35
	replace pop_wpp=(9265) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=10 in 36
	replace case=0 in 36
	replace pop_wpp=(9620) in 36
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR LUNG CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   42   285798   14.70      8.74     6.21    12.11     1.45 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1070*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_2016" 
replace cancer_site=6 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_2016" ,replace
restore

** LUNG - male only for top5 table
preserve
	drop if age5==.
	keep if siteiarc==21
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,40-44,45-49
	** F   50-54,55-59,60-64
	** M   35-39
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=1 in 16
	replace case=0 in 16
	replace pop_wpp=(7473) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=2 in 17
	replace case=0 in 17
	replace pop_wpp=(8461) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=3 in 18
	replace case=0 in 18
	replace pop_wpp=(9184) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=4 in 19
	replace case=0 in 19
	replace pop_wpp=(9275) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=5 in 20
	replace case=0 in 20
	replace pop_wpp=(9470) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=6 in 21
	replace case=0 in 21
	replace pop_wpp=(9133) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=7 in 22
	replace case=0 in 22
	replace pop_wpp=(9725) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=9 in 23
	replace case=0 in 23
	replace pop_wpp=(10504) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=10 in 24
	replace case=0 in 24
	replace pop_wpp=(10388) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=11 in 25
	replace case=0 in 25
	replace pop_wpp=(11029) in 25
	sort age5
	
	expand 2 in 1
	replace sex=1 in 26
	replace age5=12 in 26
	replace case=0 in 26
	replace pop_wpp=(10593) in 26
	sort age5
	
	expand 2 in 1
	replace sex=1 in 27
	replace age5=13 in 27
	replace case=0 in 27
	replace pop_wpp=(8802) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=1 in 28
	replace case=0 in 28
	replace pop_wpp=(7767) in 28
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=2 in 29
	replace case=0 in 29
	replace pop_wpp=(8720) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=3 in 30
	replace case=0 in 30
	replace pop_wpp=(9699) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=4 in 31
	replace case=0 in 31
	replace pop_wpp=(9660) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=5 in 32
	replace case=0 in 32
	replace pop_wpp=(9530) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=6 in 33
	replace case=0 in 33
	replace pop_wpp=(9113) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=7 in 34
	replace case=0 in 34
	replace pop_wpp=(9303) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=8 in 35
	replace case=0 in 35
	replace pop_wpp=(9265) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=10 in 36
	replace case=0 in 36
	replace pop_wpp=(9620) in 36
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

drop if sex==1 //male ONLY

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR LUNG CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   31   137902   22.48     14.92    10.07    21.56     2.81 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/579*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_2016_male" 
replace cancer_site=4 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_2016_male" ,replace
restore


** RECTUM 
tab pop_wpp age5  if siteiarc==14 & sex==1 //female
tab pop_wpp age5  if siteiarc==14 & sex==2 //male

preserve
	drop if age5==.
	keep if siteiarc==14
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34
	** F   35-39,40-44,70-74
	** M   55-59

	expand 2 in 1
	replace sex=1 in 19
	replace age5=1 in 19
	replace case=0 in 19
	replace pop_wpp=(7473) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=2 in 20
	replace case=0 in 20
	replace pop_wpp=(8461) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=3 in 21
	replace case=0 in 21
	replace pop_wpp=(9184) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=4 in 22
	replace case=0 in 22
	replace pop_wpp=(9275) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=5 in 23
	replace case=0 in 23
	replace pop_wpp=(9470) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=6 in 24
	replace case=0 in 24
	replace pop_wpp=(9133) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=7 in 25
	replace case=0 in 25
	replace pop_wpp=(9725) in 25
	sort age5
	
	expand 2 in 1
	replace sex=1 in 26
	replace age5=8 in 26
	replace case=0 in 26
	replace pop_wpp=(9612) in 26
	sort age5
	
	expand 2 in 1
	replace sex=1 in 27
	replace age5=9 in 27
	replace case=0 in 27
	replace pop_wpp=(10504) in 27
	sort age5
	
	expand 2 in 1
	replace sex=1 in 28
	replace age5=15 in 28
	replace case=0 in 28
	replace pop_wpp=(5433) in 28
	sort age5
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=1 in 29
	replace case=0 in 29
	replace pop_wpp=(7767) in 29
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=2 in 30
	replace case=0 in 30
	replace pop_wpp=(8720) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=3 in 31
	replace case=0 in 31
	replace pop_wpp=(9699) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=4 in 32
	replace case=0 in 32
	replace pop_wpp=(9660) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=5 in 33
	replace case=0 in 33
	replace pop_wpp=(9530) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=6 in 34
	replace case=0 in 34
	replace pop_wpp=(9113) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=7 in 35
	replace case=0 in 35
	replace pop_wpp=(9303) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=12 in 36
	replace case=0 in 36
	replace pop_wpp=(9205) in 36
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RECTAL CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   42   285798   14.70      8.97     6.37    12.42     1.48 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1070*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_2016" 
replace cancer_site=7 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_2016" ,replace
restore


** RECTUM - male only for top5 table
preserve
	drop if age5==.
	keep if siteiarc==14
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34
	** F   35-39,40-44,70-74
	** M   55-59

	expand 2 in 1
	replace sex=1 in 19
	replace age5=1 in 19
	replace case=0 in 19
	replace pop_wpp=(7473) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=2 in 20
	replace case=0 in 20
	replace pop_wpp=(8461) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=3 in 21
	replace case=0 in 21
	replace pop_wpp=(9184) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=4 in 22
	replace case=0 in 22
	replace pop_wpp=(9275) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=5 in 23
	replace case=0 in 23
	replace pop_wpp=(9470) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=6 in 24
	replace case=0 in 24
	replace pop_wpp=(9133) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=7 in 25
	replace case=0 in 25
	replace pop_wpp=(9725) in 25
	sort age5
	
	expand 2 in 1
	replace sex=1 in 26
	replace age5=8 in 26
	replace case=0 in 26
	replace pop_wpp=(9612) in 26
	sort age5
	
	expand 2 in 1
	replace sex=1 in 27
	replace age5=9 in 27
	replace case=0 in 27
	replace pop_wpp=(10504) in 27
	sort age5
	
	expand 2 in 1
	replace sex=1 in 28
	replace age5=15 in 28
	replace case=0 in 28
	replace pop_wpp=(5433) in 28
	sort age5
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=1 in 29
	replace case=0 in 29
	replace pop_wpp=(7767) in 29
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=2 in 30
	replace case=0 in 30
	replace pop_wpp=(8720) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=3 in 31
	replace case=0 in 31
	replace pop_wpp=(9699) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=4 in 32
	replace case=0 in 32
	replace pop_wpp=(9660) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=5 in 33
	replace case=0 in 33
	replace pop_wpp=(9530) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=6 in 34
	replace case=0 in 34
	replace pop_wpp=(9113) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=7 in 35
	replace case=0 in 35
	replace pop_wpp=(9303) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=12 in 36
	replace case=0 in 36
	replace pop_wpp=(9205) in 36
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

drop if sex==1 //male ONLY

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RECTAL CANCER (MALE)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   22   137902   15.95     10.96     6.78    17.02     2.50 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/579*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_2016_male" 
replace cancer_site=5 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_2016_male" ,replace
restore


** MULTIPLE MYELOMA
tab pop_wpp age5 if siteiarc==55 & sex==1 //female
tab pop_wpp age5 if siteiarc==55 & sex==2 //male

preserve
	drop if age5==.
	keep if siteiarc==55
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,40-44
	** F   45-49,85+
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=1 in 17
	replace case=0 in 17
	replace pop_wpp=(7473) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=2 in 18
	replace case=0 in 18
	replace pop_wpp=(8461) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=3 in 19
	replace case=0 in 19
	replace pop_wpp=(9184) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=4 in 20
	replace case=0 in 20
	replace pop_wpp=(9275) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=5 in 21
	replace case=0 in 21
	replace pop_wpp=(9470) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=6 in 22
	replace case=0 in 22
	replace pop_wpp=(9133) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=7 in 23
	replace case=0 in 23
	replace pop_wpp=(9725) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=8 in 24
	replace case=0 in 24
	replace pop_wpp=(9612) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=9 in 25
	replace case=0 in 25
	replace pop_wpp=(10504) in 25
	sort age5
	
	expand 2 in 1
	replace sex=1 in 26
	replace age5=10 in 26
	replace case=0 in 26
	replace pop_wpp=(10388) in 26
	sort age5
	
	expand 2 in 1
	replace sex=1 in 27
	replace age5=18 in 27
	replace case=0 in 27
	replace pop_wpp=(4047) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=1 in 28
	replace case=0 in 28
	replace pop_wpp=(7767) in 28
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=2 in 29
	replace case=0 in 29
	replace pop_wpp=(8720) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=3 in 30
	replace case=0 in 30
	replace pop_wpp=(9699) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=4 in 31
	replace case=0 in 31
	replace pop_wpp=(9660) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=5 in 32
	replace case=0 in 32
	replace pop_wpp=(9530) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=6 in 33
	replace case=0 in 33
	replace pop_wpp=(9113) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=7 in 34
	replace case=0 in 34
	replace pop_wpp=(9303) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=8 in 35
	replace case=0 in 35
	replace pop_wpp=(9265) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=9 in 36
	replace case=0 in 36
	replace pop_wpp=(9814) in 36
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR MULTIPLE MYELOMA CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   35   285798   12.25      7.38     5.10    10.50     1.32 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1070*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_2016" 
replace cancer_site=8 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_2016" ,replace
restore


** MULTIPLE MYELOMA - male only for top5 table
preserve
	drop if age5==.
	keep if siteiarc==55
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,40-44
	** F   45-49,85+
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=1 in 17
	replace case=0 in 17
	replace pop_wpp=(7473) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=2 in 18
	replace case=0 in 18
	replace pop_wpp=(8461) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=3 in 19
	replace case=0 in 19
	replace pop_wpp=(9184) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=4 in 20
	replace case=0 in 20
	replace pop_wpp=(9275) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=5 in 21
	replace case=0 in 21
	replace pop_wpp=(9470) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=6 in 22
	replace case=0 in 22
	replace pop_wpp=(9133) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=7 in 23
	replace case=0 in 23
	replace pop_wpp=(9725) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=8 in 24
	replace case=0 in 24
	replace pop_wpp=(9612) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=9 in 25
	replace case=0 in 25
	replace pop_wpp=(10504) in 25
	sort age5
	
	expand 2 in 1
	replace sex=1 in 26
	replace age5=10 in 26
	replace case=0 in 26
	replace pop_wpp=(10388) in 26
	sort age5
	
	expand 2 in 1
	replace sex=1 in 27
	replace age5=18 in 27
	replace case=0 in 27
	replace pop_wpp=(4047) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=1 in 28
	replace case=0 in 28
	replace pop_wpp=(7767) in 28
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=2 in 29
	replace case=0 in 29
	replace pop_wpp=(8720) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=3 in 30
	replace case=0 in 30
	replace pop_wpp=(9699) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=4 in 31
	replace case=0 in 31
	replace pop_wpp=(9660) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=5 in 32
	replace case=0 in 32
	replace pop_wpp=(9530) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=6 in 33
	replace case=0 in 33
	replace pop_wpp=(9113) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=7 in 34
	replace case=0 in 34
	replace pop_wpp=(9303) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=8 in 35
	replace case=0 in 35
	replace pop_wpp=(9265) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=9 in 36
	replace case=0 in 36
	replace pop_wpp=(9814) in 36
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

drop if sex==1 //male ONLY

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR MM (MALE)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   17   137902   12.33      7.77     4.46    12.93     2.06 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/579*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_2016_male" 
replace cancer_site=7 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_2016_male" ,replace
restore


** STOMACH 
tab pop_wpp age5  if siteiarc==11 & sex==1 //female
tab pop_wpp age5  if siteiarc==11 & sex==2 //male

preserve
	drop if age5==.
	keep if siteiarc==11
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F  0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,40-44,45-49,50-54,60-64
	** F 	55-59,70-74
	
	expand 2 in 1
	replace sex=1 in 11
	replace age5=1 in 11
	replace case=0 in 11
	replace pop_wpp=(7473) in 11
	sort age5
	
	expand 2 in 1
	replace sex=1 in 12
	replace age5=2 in 12
	replace case=0 in 12
	replace pop_wpp=(8461) in 12
	sort age5
	
	expand 2 in 1
	replace sex=1 in 13
	replace age5=3 in 13
	replace case=0 in 13
	replace pop_wpp=(9184) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=4 in 14
	replace case=0 in 14
	replace pop_wpp=(9275) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=5 in 15
	replace case=0 in 15
	replace pop_wpp=(9470) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=6 in 16
	replace case=0 in 16
	replace pop_wpp=(9133) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=7 in 17
	replace case=0 in 17
	replace pop_wpp=(9725) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=8 in 18
	replace case=0 in 18
	replace pop_wpp=(9612) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=9 in 19
	replace case=0 in 19
	replace pop_wpp=(10504) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=10 in 20
	replace case=0 in 20
	replace pop_wpp=(10388) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=11 in 21
	replace case=0 in 21
	replace pop_wpp=(11029) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=12 in 22
	replace case=0 in 22
	replace pop_wpp=(10593) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=13 in 23
	replace case=0 in 23
	replace pop_wpp=(8802) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=15 in 24
	replace case=0 in 24
	replace pop_wpp=(5433) in 24
	sort age5
	
	expand 2 in 1
	replace sex=2 in 25
	replace age5=1 in 25
	replace case=0 in 25
	replace pop_wpp=(7767) in 25
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 26
	replace age5=2 in 26
	replace case=0 in 26
	replace pop_wpp=(8720) in 26
	sort age5
	
	expand 2 in 1
	replace sex=2 in 27
	replace age5=3 in 27
	replace case=0 in 27
	replace pop_wpp=(9699) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=4 in 28
	replace case=0 in 28
	replace pop_wpp=(9660) in 28
	sort age5
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=5 in 29
	replace case=0 in 29
	replace pop_wpp=(9530) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=6 in 30
	replace case=0 in 30
	replace pop_wpp=(9113) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=7 in 31
	replace case=0 in 31
	replace pop_wpp=(9303) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=8 in 32
	replace case=0 in 32
	replace pop_wpp=(9265) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=9 in 33
	replace case=0 in 33
	replace pop_wpp=(9814) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=10 in 34
	replace case=0 in 34
	replace pop_wpp=(9620) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=11 in 35
	replace case=0 in 35
	replace pop_wpp=(9795) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=13 in 36
	replace case=0 in 36
	replace pop_wpp=(7664) in 36
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR STOMACH CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   30   285798   10.50      5.00     3.31     7.49     1.02 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1070*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_2016" 
replace cancer_site=9 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_2016" ,replace
restore

** STOMACH - male only for top5 table
preserve
	drop if age5==.
	keep if siteiarc==11
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F  0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,40-44,45-49,50-54,60-64
	** F 	55-59,70-74
	
	expand 2 in 1
	replace sex=1 in 11
	replace age5=1 in 11
	replace case=0 in 11
	replace pop_wpp=(7473) in 11
	sort age5
	
	expand 2 in 1
	replace sex=1 in 12
	replace age5=2 in 12
	replace case=0 in 12
	replace pop_wpp=(8461) in 12
	sort age5
	
	expand 2 in 1
	replace sex=1 in 13
	replace age5=3 in 13
	replace case=0 in 13
	replace pop_wpp=(9184) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=4 in 14
	replace case=0 in 14
	replace pop_wpp=(9275) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=5 in 15
	replace case=0 in 15
	replace pop_wpp=(9470) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=6 in 16
	replace case=0 in 16
	replace pop_wpp=(9133) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=7 in 17
	replace case=0 in 17
	replace pop_wpp=(9725) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=8 in 18
	replace case=0 in 18
	replace pop_wpp=(9612) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=9 in 19
	replace case=0 in 19
	replace pop_wpp=(10504) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=10 in 20
	replace case=0 in 20
	replace pop_wpp=(10388) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=11 in 21
	replace case=0 in 21
	replace pop_wpp=(11029) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=12 in 22
	replace case=0 in 22
	replace pop_wpp=(10593) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=13 in 23
	replace case=0 in 23
	replace pop_wpp=(8802) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=15 in 24
	replace case=0 in 24
	replace pop_wpp=(5433) in 24
	sort age5
	
	expand 2 in 1
	replace sex=2 in 25
	replace age5=1 in 25
	replace case=0 in 25
	replace pop_wpp=(7767) in 25
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 26
	replace age5=2 in 26
	replace case=0 in 26
	replace pop_wpp=(8720) in 26
	sort age5
	
	expand 2 in 1
	replace sex=2 in 27
	replace age5=3 in 27
	replace case=0 in 27
	replace pop_wpp=(9699) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=4 in 28
	replace case=0 in 28
	replace pop_wpp=(9660) in 28
	sort age5
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=5 in 29
	replace case=0 in 29
	replace pop_wpp=(9530) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=6 in 30
	replace case=0 in 30
	replace pop_wpp=(9113) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=7 in 31
	replace case=0 in 31
	replace pop_wpp=(9303) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=8 in 32
	replace case=0 in 32
	replace pop_wpp=(9265) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=9 in 33
	replace case=0 in 33
	replace pop_wpp=(9814) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=10 in 34
	replace case=0 in 34
	replace pop_wpp=(9620) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=11 in 35
	replace case=0 in 35
	replace pop_wpp=(9795) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=13 in 36
	replace case=0 in 36
	replace pop_wpp=(7664) in 36
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

drop if sex==1 // for stomach cancer - male ONLY

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR STOMACH CANCER (MALE)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   17   137902   12.33      7.09     4.08    11.89     1.89 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/579*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_2016_male" 
replace cancer_site=6 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_2016_male" ,replace
restore


** PANCREAS 
tab pop_wpp age5  if siteiarc==18 & sex==1 //female
tab pop_wpp age5  if siteiarc==18 & sex==2 //male

preserve
	drop if age5==.
	keep if siteiarc==18
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,40-44,45-49
	** F   55-59,70-74
	** M   85+

	expand 2 in 1
	replace sex=1 in 14
	replace age5=1 in 14
	replace case=0 in 14
	replace pop_wpp=(7473) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=2 in 15
	replace case=0 in 15
	replace pop_wpp=(8461) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=3 in 16
	replace case=0 in 16
	replace pop_wpp=(9184) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=4 in 17
	replace case=0 in 17
	replace pop_wpp=(9275) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=5 in 18
	replace case=0 in 18
	replace pop_wpp=(9470) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=6 in 19
	replace case=0 in 19
	replace pop_wpp=(9133) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=7 in 20
	replace case=0 in 20
	replace pop_wpp=(9725) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=8 in 21
	replace case=0 in 21
	replace pop_wpp=(9612) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=9 in 22
	replace case=0 in 22
	replace pop_wpp=(10504) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=10 in 23
	replace case=0 in 23
	replace pop_wpp=(10388) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=12 in 24
	replace case=0 in 24
	replace pop_wpp=(10593) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=15 in 25
	replace case=0 in 25
	replace pop_wpp=(5433) in 25
	sort age5
	
	expand 2 in 1
	replace sex=2 in 26
	replace age5=1 in 26
	replace case=0 in 26
	replace pop_wpp=(7767) in 26
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 27
	replace age5=2 in 27
	replace case=0 in 27
	replace pop_wpp=(8720) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=3 in 28
	replace case=0 in 28
	replace pop_wpp=(9699) in 28
	sort age5
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=4 in 29
	replace case=0 in 29
	replace pop_wpp=(9660) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=5 in 30
	replace case=0 in 30
	replace pop_wpp=(9530) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=6 in 31
	replace case=0 in 31
	replace pop_wpp=(9113) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=7 in 32
	replace case=0 in 32
	replace pop_wpp=(9303) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=8 in 33
	replace case=0 in 33
	replace pop_wpp=(9265) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=9 in 34
	replace case=0 in 34
	replace pop_wpp=(9814) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=10 in 35
	replace case=0 in 35
	replace pop_wpp=(9620) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=18 in 36
	replace case=0 in 36
	replace pop_wpp=(2553) in 36
	sort age5
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PANCREATIC CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   29   285798   10.15      5.85     3.88     8.67     1.17 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1070*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_2016" 
replace cancer_site=10 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_2016" ,replace
restore


** CERVIX 
tab pop_wpp age5  if siteiarc==32 & sex==1 //female

preserve
	drop if age5==.
	keep if siteiarc==32
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** F  0-4,5-9,10-14,15-19,20-24,25-29,45-49
	
	expand 2 in 1
	replace sex=1 in 12
	replace age5=1 in 12
	replace case=0 in 12
	replace pop_wpp=(7473) in 12
	sort age5
	
	expand 2 in 1
	replace sex=1 in 13
	replace age5=2 in 13
	replace case=0 in 13
	replace pop_wpp=(8461) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=3 in 14
	replace case=0 in 14
	replace pop_wpp=(9184) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=4 in 15
	replace case=0 in 15
	replace pop_wpp=(9275) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=5 in 16
	replace case=0 in 16
	replace pop_wpp=(9470) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=6 in 17
	replace case=0 in 17
	replace pop_wpp=(9133) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=10 in 18
	replace case=0 in 18
	replace pop_wpp=(10388) in 18
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CERVICAL CANCER - STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   25   147896   16.90     11.26     7.08    17.26     2.49 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
format asir %04.2f
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/1070*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_2016" 
replace cancer_site=11 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_2016" ,replace
restore

** CERVIX - for female top 5 table
preserve
	drop if age5==.
	keep if siteiarc==32 // cervix uteri only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F  0-4,5-9,10-14,15-19,20-24,25-29,45-49
	
	expand 2 in 1
	replace sex=1 in 12
	replace age5=1 in 12
	replace case=0 in 12
	replace pop_wpp=(7473) in 12
	sort age5
	
	expand 2 in 1
	replace sex=1 in 13
	replace age5=2 in 13
	replace case=0 in 13
	replace pop_wpp=(8461) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=3 in 14
	replace case=0 in 14
	replace pop_wpp=(9184) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=4 in 15
	replace case=0 in 15
	replace pop_wpp=(9275) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=5 in 16
	replace case=0 in 16
	replace pop_wpp=(9470) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=6 in 17
	replace case=0 in 17
	replace pop_wpp=(9133) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=10 in 18
	replace case=0 in 18
	replace pop_wpp=(10388) in 18
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CERVICAL CANCER - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   25   147896   16.90     11.26     7.08    17.26     2.49 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/491*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_2016_female" 
replace cancer_site=5 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_2016_female" ,replace
restore


** OVARY - for female top 5 table
tab pop_wpp age5  if siteiarc==35 & sex==1 //female

preserve
	drop if age5==.
	keep if siteiarc==35 // ovary only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-4,5-9,10-14,15-19,20-24,30-34,35-39,40-44,70-74,80-84
	
	expand 2 in 1
	replace sex=1 in 9
	replace age5=1 in 9
	replace case=0 in 9
	replace pop_wpp=(7473) in 9
	sort age5
	
	expand 2 in 1
	replace sex=1 in 10
	replace age5=2 in 10
	replace case=0 in 10
	replace pop_wpp=(8461) in 10
	sort age5
	
	expand 2 in 1
	replace sex=1 in 11
	replace age5=3 in 11
	replace case=0 in 11
	replace pop_wpp=(9184) in 11
	sort age5
	
	expand 2 in 1
	replace sex=1 in 12
	replace age5=4 in 12
	replace case=0 in 12
	replace pop_wpp=(9275) in 12
	sort age5
	
	expand 2 in 1
	replace sex=1 in 13
	replace age5=5 in 13
	replace case=0 in 13
	replace pop_wpp=(9470) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=7 in 14
	replace case=0 in 14
	replace pop_wpp=(9725) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=8 in 15
	replace case=0 in 15
	replace pop_wpp=(9612) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=9 in 16
	replace case=0 in 16
	replace pop_wpp=(10504) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=15 in 17
	replace case=0 in 17
	replace pop_wpp=(5433) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=17 in 18
	replace case=0 in 18
	replace pop_wpp=(3295) in 18
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR OVARIAN CANCER - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   21   147896   14.20      9.47     5.73    15.00     2.26 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/491*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_2016_female" 
replace cancer_site=6 if cancer_site==.
replace year=3 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_2016_female" ,replace
restore