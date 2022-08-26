
cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          25h_analysis ASIRs_2018.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      25-AUG-2022
    // 	date last modified      25-AUG-2022
    //  algorithm task          Analyzing combined cancer dataset: (1) Numbers (2) ASIRs for 2016-2018 annual report
    //  status                  Completed
    //  objective               To have one dataset with cleaned and grouped 2018 incidence data for inclusion in 2016-2018 cancer report.
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
    log using "`logpath'/25h_analysis ASIRs_2018.smcl", replace
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
** 2018 **
**********
drop if dxyr!=2018 // deleted

count //960

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
merge m:m sex age5 using "`datapath'\version09\2-working\pop_wpp_2018-5"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                               949  (_merge==3)
    -----------------------------------------
*/

**drop if _merge==2 //do not drop these age groups as it skews pop_wpp 
** There is 6 unmatched records (_merge==2) since 2013 data doesn't have any cases of 0-4 male; 5-9 female + male; 15-19 female; 20-24 male; 25-29 male

tab age5 ,m //none missing

drop case
gen case=1 if pid!="" //do not generate case for missing age group 0-14 as it skews case total
gen pfu=1 // for % year if not whole year collected; not done for cancer

list pid sex age5 if _merge==2 //missing are 0-4 male; 5-9 female + male; 15-19 female; 20-24 male; 25-29 male

list pid sex age5 if age5==1 & sex==2|age5==2 & (sex==1|sex==2)|age5==4 & sex==1|age5==5 & sex==2|age5==6 & sex==2 
replace case=0 if age5==1 & sex==2|age5==2 & (sex==1|sex==2)|age5==4 & sex==1|age5==5 & sex==2|age5==6 & sex==2 //6 changes


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
		& siteiarc!=55 & siteiarc!=18 & siteiarc!=14 & siteiarc!=21 ///
		& siteiarc!=53 & siteiarc!=11
		
//by sex,sort: tab age5 incirate ,m
sort siteiarc age5 sex
//list incirate age5 sex
//list incirate age5 sex if siteiarc==13

format incirate %04.2f
gen year=2018
rename siteiarc cancer_site
rename incirate age_specific_rate
drop pfu case pop_wpp
order year cancer_site sex age5 age_specific_rate
save "`datapath'\version09\2-working\2018_top10_age+sex_rates" ,replace
restore

** Check for missing age as these would need to be added to the median group for that site when assessing ASIRs to prevent creating an outlier
count if age==.|age==999 //0

** Below saved in pathway: 
//X:\The University of the West Indies\DataGroup - repo_data\data_p117\version09\2-working\WPP_population by sex_2013.txt
tab pop_wpp age5  if sex==1 //female
tab pop_wpp age5  if sex==2 //male

** Need an easier method for referencing population totals by sex instead of using Notepad as age5 has more groupings than using age_10 so can create the below ds and save to Notepad
preserve
contract sex pop_wpp age5
gen age5_id=age5
order sex age5_id pop_wpp age5
drop _freq
sort sex age5_id
total pop_wpp
//method: run this code separately and save output in Notepad then re-run dofile
restore

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
  |  949   286640   331.08    207.16   193.64   221.45     7.02 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
gen cancer_site=1
gen year=1
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
gen percent=number/949*100
replace percent=round(percent,0.01)

 
//JC 19may2022: rename breast to female breast as drop males in distrate breast section so ASMR for breast is calculated using female population
label define cancer_site_lab 1 "all" 2 "prostate" 3 "female breast" 4 "colon" 5 "corpus uteri" 6 "multiple myeloma" 7 "pancreas" ///
							 8 "rectum" 9 "lung" 10 "non-hodgkin lymphoma" 11 "stomach" ,modify
label values cancer_site cancer_site_lab
label define year_lab 1 "2018" 2 "2017" 3 "2016" 4 "2015" 5 "2014" 6 "2013" ,modify
label values year year_lab
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs" ,replace
restore


** Next, IRs for invasive tumours FEMALE only
preserve
	drop if age5==.
	drop if sex==2 //477 deleted
	
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
  |  472   148115   318.67    199.50   180.74   219.81     9.83 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
gen cancer_site=1
gen year=1
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse cancer_site number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/949*100
replace percent=round(percent,0.01)

label define cancer_site_lab 1 "all" 2 "female breast" 3 "colon" 4 "corpus uteri" 5 "rectum" 6 "multiple myeloma" ,modify
label values cancer_site cancer_site_lab
label define year_lab 1 "2018" 2 "2017" 3 "2016" ,modify
label values year year_lab
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_female" ,replace
restore

** Next, IRs for invasive tumours MALE only
preserve
	drop if age5==.
	drop if sex==1 //472 deleted
	
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
  |  477   138525   344.34    219.25   199.64   240.45    10.26 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
gen cancer_site=1
gen year=1
matrix list r(adj)
matrix number = r(NDeath)
matrix asir = r(adj)
matrix ci_lower = r(lb_G)
matrix ci_upper = r(ub_G)
svmat number
svmat asir
svmat ci_lower
svmat ci_upper

collapse cancer_site number asir ci_lower ci_upper
rename number1 number
rename asir1 asir 
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper
replace asir=round(asir,0.01)
replace ci_lower=round(ci_lower,0.01)
replace ci_upper=round(ci_upper,0.01)
gen percent=number/949*100
replace percent=round(percent,0.01)

label define cancer_site_lab 1 "all" 2 "prostate" 3 "colon" 4 "rectum" 5 "lung" 6 "stomach" ,modify
label values cancer_site cancer_site_lab
label define year_lab 1 "2018" 2 "2017" 3 "2016" ,modify
label values year year_lab
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_male" ,replace
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
	** M 0-14,15-24,25-34
	expand 2 in 1
	replace sex=2 in 7
	replace age5=1 in 7
	replace case=0 in 7
	replace pop_wpp=(25316) in 7
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 8
	replace age5=2 in 8
	replace case=0 in 8
	replace pop_wpp=(19294)  in 8
	sort age5
	
	expand 2 in 1
	replace sex=2 in 9
	replace age5=3 in 9
	replace case=0 in 9
	replace pop_wpp=(18385) in 9
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
  |  221   138525   159.54    100.95    87.96   115.51     6.89 |
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
gen percent=number/949*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs" 
replace cancer_site=2 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs" ,replace
restore

** PROSTATE - for male top5 table
tab pop_wpp age5 if siteiarc==39 //male

preserve
	drop if age5==. //0 deleted
	keep if siteiarc==39 // prostate only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M 0-14,15-24,25-34
	expand 2 in 1
	replace sex=2 in 7
	replace age5=1 in 7
	replace case=0 in 7
	replace pop_wpp=(25316) in 7
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 8
	replace age5=2 in 8
	replace case=0 in 8
	replace pop_wpp=(19294)  in 8
	sort age5
	
	expand 2 in 1
	replace sex=2 in 9
	replace age5=3 in 9
	replace case=0 in 9
	replace pop_wpp=(18385) in 9
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
  |  221   138525   159.54    100.95    87.96   115.51     6.89 |
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
gen percent=number/477*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_male" 
replace cancer_site=2 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_male" ,replace
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
	** M&F 0-14,15-24
	expand 2 in 1
	replace sex=1 in 8
	replace age5=1 in 8
	replace case=0 in 8
	replace pop_wpp=(24395) in 8
	sort age5
	
	expand 2 in 1
	replace sex=1 in 9
	replace age5=2 in 9
	replace case=0 in 9
	replace pop_wpp=(18623) in 9
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
  |  171   148115   115.45     79.90    67.73    93.72     6.50 |
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
gen percent=number/949*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs" 
replace cancer_site=3 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs" ,replace
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
	** M&F 0-14,15-24
	expand 2 in 1
	replace sex=1 in 8
	replace age5=1 in 8
	replace case=0 in 8
	replace pop_wpp=(24395) in 8
	sort age5
	
	expand 2 in 1
	replace sex=1 in 9
	replace age5=2 in 9
	replace case=0 in 9
	replace pop_wpp=(18623) in 9
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
  |  171   148115   115.45     79.90    67.73    93.72     6.50 |
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
gen percent=number/472*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_female" 
replace cancer_site=2 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_female" ,replace
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
	** M&F 0-14,25-34
	** F   15-24
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=1 in 14
	replace case=0 in 14
	replace pop_wpp=(24395) in 14
	sort age5
	
	expand 2 in 1
	replace sex=2 in 15
	replace age5=1 in 15
	replace case=0 in 15
	replace pop_wpp=(25316) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=2 in 16
	replace case=0 in 16
	replace pop_wpp=(18623) in 16
	sort age5

	expand 2 in 1
	replace sex=1 in 17
	replace age5=3 in 17
	replace case=0 in 17
	replace pop_wpp=(18632) in 17
	sort age5
	
	expand 2 in 1
	replace sex=2 in 18
	replace age5=3 in 18
	replace case=0 in 18
	replace pop_wpp=(18385) in 18
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
  |  114   286640   39.77     24.53    20.06    29.78     2.42 |
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
gen percent=number/949*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs" 
replace cancer_site=4 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs" ,replace
restore

** COLON - female only for top5 table
preserve
	drop if age5==.
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,25-34
	** F   15-24
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=1 in 14
	replace case=0 in 14
	replace pop_wpp=(24395) in 14
	sort age5
	
	expand 2 in 1
	replace sex=2 in 15
	replace age5=1 in 15
	replace case=0 in 15
	replace pop_wpp=(25316) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=2 in 16
	replace case=0 in 16
	replace pop_wpp=(18623) in 16
	sort age5

	expand 2 in 1
	replace sex=1 in 17
	replace age5=3 in 17
	replace case=0 in 17
	replace pop_wpp=(18632) in 17
	sort age5
	
	expand 2 in 1
	replace sex=2 in 18
	replace age5=3 in 18
	replace case=0 in 18
	replace pop_wpp=(18385) in 18
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
  |   58   148115   39.16     22.40    16.75    29.59     3.16 |
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
gen percent=number/472*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_female" 
replace cancer_site=3 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_female" ,replace
restore

** COLON - male only for top5 table
preserve
	drop if age5==.
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,25-34
	** F   15-24
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=1 in 14
	replace case=0 in 14
	replace pop_wpp=(24395) in 14
	sort age5
	
	expand 2 in 1
	replace sex=2 in 15
	replace age5=1 in 15
	replace case=0 in 15
	replace pop_wpp=(25316) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=2 in 16
	replace case=0 in 16
	replace pop_wpp=(18623) in 16
	sort age5

	expand 2 in 1
	replace sex=1 in 17
	replace age5=3 in 17
	replace case=0 in 17
	replace pop_wpp=(18632) in 17
	sort age5
	
	expand 2 in 1
	replace sex=2 in 18
	replace age5=3 in 18
	replace case=0 in 18
	replace pop_wpp=(18385) in 18
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
  |   56   138525   40.43     26.84    20.10    35.30     3.75 |
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
gen percent=number/477*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_male" 
replace cancer_site=3 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_male" ,replace
restore


** CORPUS UTERI
tab pop_wpp age5 if siteiarc==33

preserve
	drop if age5==.
	keep if siteiarc==33 // corpus uteri only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-14,15-24,25-34,35-44
	
	expand 2 in 1
	replace sex=1 in 6
	replace age5=1 in 6
	replace case=0 in 6
	replace pop_wpp=(24395) in 6
	sort age5	
	
	expand 2 in 1
	replace sex=1 in 7
	replace age5=2 in 7
	replace case=0 in 7
	replace pop_wpp=(18623) in 7
	sort age5
	
	expand 2 in 1
	replace sex=1 in 8
	replace age5=3 in 8
	replace case=0 in 8
	replace pop_wpp=(18632) in 8
	sort age5
	
	expand 2 in 1
	replace sex=1 in 9
	replace age5=4 in 9
	replace case=0 in 9
	replace pop_wpp=(19702) in 9
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
  |   50   148115   33.76     18.87    13.91    25.33     2.80 |
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
gen percent=number/949*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs" 
replace cancer_site=5 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs" ,replace
restore

** CORPUS UTERI - for female top 5 table
preserve
	drop if age5==.
	keep if siteiarc==33 // corpus uteri only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-14,15-24,25-34,35-44
	
	expand 2 in 1
	replace sex=1 in 6
	replace age5=1 in 6
	replace case=0 in 6
	replace pop_wpp=(24395) in 6
	sort age5	
	
	expand 2 in 1
	replace sex=1 in 7
	replace age5=2 in 7
	replace case=0 in 7
	replace pop_wpp=(18623) in 7
	sort age5
	
	expand 2 in 1
	replace sex=1 in 8
	replace age5=3 in 8
	replace case=0 in 8
	replace pop_wpp=(18632) in 8
	sort age5
	
	expand 2 in 1
	replace sex=1 in 9
	replace age5=4 in 9
	replace case=0 in 9
	replace pop_wpp=(19702) in 9
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
  |   50   148115   33.76     18.87    13.91    25.33     2.80 |
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
gen percent=number/472*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_female" 
replace cancer_site=4 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_female" ,replace
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
	** M&F 0-14,15-24,25-34
	** M 35-44,75-84
	
	expand 2 in 1
	replace sex=1 in 11
	replace age5=1 in 11
	replace case=0 in 11
	replace pop_wpp=(24395) in 11
	sort age5
	
	expand 2 in 1
	replace sex=2 in 12
	replace age5=1 in 12
	replace case=0 in 12
	replace pop_wpp=(25316) in 12
	sort age5
	
	expand 2 in 1
	replace sex=1 in 13
	replace age5=2 in 13
	replace case=0 in 13
	replace pop_wpp=(18623) in 13
	sort age5

	expand 2 in 1
	replace sex=2 in 14
	replace age5=2 in 14
	replace case=0 in 14
	replace pop_wpp=(19294) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18632) in 15
	sort age5
	
	expand 2 in 1
	replace sex=2 in 16
	replace age5=3 in 16
	replace case=0 in 16
	replace pop_wpp=(18385) in 16
	sort age5
	
	expand 2 in 1
	replace sex=2 in 17
	replace age5=4 in 17
	replace case=0 in 17
	replace pop_wpp=(18767) in 17
	sort age5
	
	expand 2 in 1
	replace sex=2 in 18
	replace age5=8 in 18
	replace case=0 in 18
	replace pop_wpp=(5824) in 18
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
  |   29   286640   10.12      6.39     4.20     9.43     1.28 |
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
gen percent=number/949*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs" 
replace cancer_site=6 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs" ,replace
restore

** MULTIPLE MYELOMA - female only for top5 table
preserve
	drop if age5==.
	keep if siteiarc==55
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34
	** M 35-44,75-84
	
	expand 2 in 1
	replace sex=1 in 11
	replace age5=1 in 11
	replace case=0 in 11
	replace pop_wpp=(24395) in 11
	sort age5
	
	expand 2 in 1
	replace sex=2 in 12
	replace age5=1 in 12
	replace case=0 in 12
	replace pop_wpp=(25316) in 12
	sort age5
	
	expand 2 in 1
	replace sex=1 in 13
	replace age5=2 in 13
	replace case=0 in 13
	replace pop_wpp=(18623) in 13
	sort age5

	expand 2 in 1
	replace sex=2 in 14
	replace age5=2 in 14
	replace case=0 in 14
	replace pop_wpp=(19294) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18632) in 15
	sort age5
	
	expand 2 in 1
	replace sex=2 in 16
	replace age5=3 in 16
	replace case=0 in 16
	replace pop_wpp=(18385) in 16
	sort age5
	
	expand 2 in 1
	replace sex=2 in 17
	replace age5=4 in 17
	replace case=0 in 17
	replace pop_wpp=(18767) in 17
	sort age5
	
	expand 2 in 1
	replace sex=2 in 18
	replace age5=8 in 18
	replace case=0 in 18
	replace pop_wpp=(5824) in 18
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

drop if sex==2 //female ONLY

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR MM CANCER (FEMALE)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   14   148115    9.45      6.07     3.17    10.74     1.85 |
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
gen percent=number/472*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_female" 
replace cancer_site=6 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_female" ,replace
restore

** MULTIPLE MYELOMA - male only for top5 table
preserve
	drop if age5==.
	keep if siteiarc==55
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34
	** M 35-44,75-84
	
	expand 2 in 1
	replace sex=1 in 11
	replace age5=1 in 11
	replace case=0 in 11
	replace pop_wpp=(24395) in 11
	sort age5
	
	expand 2 in 1
	replace sex=2 in 12
	replace age5=1 in 12
	replace case=0 in 12
	replace pop_wpp=(25316) in 12
	sort age5
	
	expand 2 in 1
	replace sex=1 in 13
	replace age5=2 in 13
	replace case=0 in 13
	replace pop_wpp=(18623) in 13
	sort age5

	expand 2 in 1
	replace sex=2 in 14
	replace age5=2 in 14
	replace case=0 in 14
	replace pop_wpp=(19294) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18632) in 15
	sort age5
	
	expand 2 in 1
	replace sex=2 in 16
	replace age5=3 in 16
	replace case=0 in 16
	replace pop_wpp=(18385) in 16
	sort age5
	
	expand 2 in 1
	replace sex=2 in 17
	replace age5=4 in 17
	replace case=0 in 17
	replace pop_wpp=(18767) in 17
	sort age5
	
	expand 2 in 1
	replace sex=2 in 18
	replace age5=8 in 18
	replace case=0 in 18
	replace pop_wpp=(5824) in 18
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
  |   15   138525   10.83      6.82     3.76    11.67     1.92 |
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
gen percent=number/477*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_male" 
replace cancer_site=6 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_male" ,replace
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
	** M&F 0-14,15-24,25-34,35-44
	** M   45-54
	expand 2 in 1
	replace sex=1 in 10
	replace age5=1 in 10
	replace case=0 in 10
	replace pop_wpp=(24395) in 10
	sort age5
	
	expand 2 in 1
	replace sex=2 in 11
	replace age5=1 in 11
	replace case=0 in 11
	replace pop_wpp=(25316) in 11
	sort age5
	
	expand 2 in 1
	replace sex=1 in 12
	replace age5=2 in 12
	replace case=0 in 12
	replace pop_wpp=(18623) in 12
	sort age5
	
	expand 2 in 1
	replace sex=2 in 13
	replace age5=2 in 13
	replace case=0 in 13
	replace pop_wpp=(19294) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=3 in 14
	replace case=0 in 14
	replace pop_wpp=(18632) in 14
	sort age5

	expand 2 in 1
	replace sex=2 in 15
	replace age5=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18385) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=4 in 16
	replace case=0 in 16
	replace pop_wpp=(19702) in 16
	sort age5
	
	expand 2 in 1
	replace sex=2 in 17
	replace age5=4 in 17
	replace case=0 in 17
	replace pop_wpp=(18767) in 17
	sort age5
	
	expand 2 in 1
	replace sex=2 in 18
	replace age5=5 in 18
	replace case=0 in 18
	replace pop_wpp=(19280) in 18
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
  |   31   286640   10.81      5.65     3.78     8.29     1.10 |
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
gen percent=number/949*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs" 
replace cancer_site=7 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs" ,replace
restore

** PANCREAS - female only for top5 table
preserve
	drop if age5==.
	keep if siteiarc==18
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	** M   45-54
	expand 2 in 1
	replace sex=1 in 10
	replace age5=1 in 10
	replace case=0 in 10
	replace pop_wpp=(24395) in 10
	sort age5
	
	expand 2 in 1
	replace sex=2 in 11
	replace age5=1 in 11
	replace case=0 in 11
	replace pop_wpp=(25316) in 11
	sort age5
	
	expand 2 in 1
	replace sex=1 in 12
	replace age5=2 in 12
	replace case=0 in 12
	replace pop_wpp=(18623) in 12
	sort age5
	
	expand 2 in 1
	replace sex=2 in 13
	replace age5=2 in 13
	replace case=0 in 13
	replace pop_wpp=(19294) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=3 in 14
	replace case=0 in 14
	replace pop_wpp=(18632) in 14
	sort age5

	expand 2 in 1
	replace sex=2 in 15
	replace age5=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18385) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=4 in 16
	replace case=0 in 16
	replace pop_wpp=(19702) in 16
	sort age5
	
	expand 2 in 1
	replace sex=2 in 17
	replace age5=4 in 17
	replace case=0 in 17
	replace pop_wpp=(18767) in 17
	sort age5
	
	expand 2 in 1
	replace sex=2 in 18
	replace age5=5 in 18
	replace case=0 in 18
	replace pop_wpp=(19280) in 18
	sort age5
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

drop if sex==2 //female ONLY

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PANCREATIC CANCER (FEMALE)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   18   148115   12.15      5.68     3.25     9.68     1.56 |
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
gen percent=number/472*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_female" 
replace cancer_site=5 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_female" ,replace
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
	** M&F 0-14,15-24,25-34,35-44

	expand 2 in 1
	replace sex=1 in 11
	replace age5=1 in 11
	replace case=0 in 11
	replace pop_wpp=(24395) in 11
	sort age5
	
	expand 2 in 1
	replace sex=2 in 12
	replace age5=1 in 12
	replace case=0 in 12
	replace pop_wpp=(25316) in 12
	sort age5
	
	expand 2 in 1
	replace sex=1 in 13
	replace age5=2 in 13
	replace case=0 in 13
	replace pop_wpp=(18623) in 13
	sort age5

	expand 2 in 1
	replace sex=2 in 14
	replace age5=2 in 14
	replace case=0 in 14
	replace pop_wpp=(19294) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18632) in 15
	sort age5
	
	expand 2 in 1
	replace sex=2 in 16
	replace age5=3 in 16
	replace case=0 in 16
	replace pop_wpp=(18385) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=4 in 17
	replace case=0 in 17
	replace pop_wpp=(19702) in 17
	sort age5
	
	expand 2 in 1
	replace sex=2 in 18
	replace age5=4 in 18
	replace case=0 in 18
	replace pop_wpp=(18767) in 18
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
  |   33   286640   11.51      6.83     4.67     9.79     1.25 |
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
gen percent=number/949*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs" 
replace cancer_site=8 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs" ,replace
restore

/*
** RECTUM - female only for top5 table
preserve
	drop if age5==.
	keep if siteiarc==14
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24
	** M 85+
	expand 2 in 1
	replace sex=1 in 14
	replace age5=1 in 14
	replace case=0 in 14
	replace pop_wpp=(25537) in 14
	sort age5
	
	expand 2 in 1
	replace sex=2 in 15
	replace age5=1 in 15
	replace case=0 in 15
	replace pop_wpp=(26626) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=2 in 16
	replace case=0 in 16
	replace pop_wpp=(18761) in 16
	sort age5

	expand 2 in 1
	replace sex=2 in 17
	replace age5=2 in 17
	replace case=0 in 17
	replace pop_wpp=(19111) in 17
	sort age5
	
	expand 2 in 1
	replace sex=2 in 18
	replace age5=9 in 18
	replace case=0 in 18
	replace pop_wpp=(2487) in 18
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

drop if sex==2 // for rectal cancer - female ONLY

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RECTAL CANCER (FEMALE)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   26   147779   17.59     10.27     6.42    15.78     2.29 |
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
gen percent=number/472*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_female" 
replace cancer_site=5 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_female" ,replace
restore
*/

** RECTUM - male only for top5 table
preserve
	drop if age5==.
	keep if siteiarc==14
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44

	expand 2 in 1
	replace sex=1 in 11
	replace age5=1 in 11
	replace case=0 in 11
	replace pop_wpp=(24395) in 11
	sort age5
	
	expand 2 in 1
	replace sex=2 in 12
	replace age5=1 in 12
	replace case=0 in 12
	replace pop_wpp=(25316) in 12
	sort age5
	
	expand 2 in 1
	replace sex=1 in 13
	replace age5=2 in 13
	replace case=0 in 13
	replace pop_wpp=(18623) in 13
	sort age5

	expand 2 in 1
	replace sex=2 in 14
	replace age5=2 in 14
	replace case=0 in 14
	replace pop_wpp=(19294) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18632) in 15
	sort age5
	
	expand 2 in 1
	replace sex=2 in 16
	replace age5=3 in 16
	replace case=0 in 16
	replace pop_wpp=(18385) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=4 in 17
	replace case=0 in 17
	replace pop_wpp=(19702) in 17
	sort age5
	
	expand 2 in 1
	replace sex=2 in 18
	replace age5=4 in 18
	replace case=0 in 18
	replace pop_wpp=(18767) in 18
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
  |   25   138525   18.05     11.42     7.36    17.18     2.40 |
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
gen percent=number/477*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_male" 
replace cancer_site=4 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_male" ,replace
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
	** M&F 0-14,15-24,25-34,35-44
	** F   45-54
	expand 2 in 1
	replace sex=1 in 10
	replace age5=1 in 10
	replace case=0 in 10
	replace pop_wpp=(24395) in 10
	sort age5
	
	expand 2 in 1
	replace sex=2 in 11
	replace age5=1 in 11
	replace case=0 in 11
	replace pop_wpp=(25316) in 11
	sort age5
	
	expand 2 in 1
	replace sex=1 in 12
	replace age5=2 in 12
	replace case=0 in 12
	replace pop_wpp=(18623) in 12
	sort age5

	expand 2 in 1
	replace sex=2 in 13
	replace age5=2 in 13
	replace case=0 in 13
	replace pop_wpp=(19294) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=3 in 14
	replace case=0 in 14
	replace pop_wpp=(18632) in 14
	sort age5
	
	expand 2 in 1
	replace sex=2 in 15
	replace age5=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18385) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=4 in 16
	replace case=0 in 16
	replace pop_wpp=(19702) in 16
	sort age5
	
	expand 2 in 1
	replace sex=2 in 17
	replace age5=4 in 17
	replace case=0 in 17
	replace pop_wpp=(18767) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=5 in 18
	replace case=0 in 18
	replace pop_wpp=(21092) in 18
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
  |   28   286640    9.77      5.31     3.47     7.94     1.09 |
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
gen percent=number/949*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs" 
replace cancer_site=9 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs" ,replace
restore

** LUNG - male only for top5 table
preserve
	drop if age5==.
	keep if siteiarc==21
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24,25-34,35-44
	** F   45-54
	expand 2 in 1
	replace sex=1 in 10
	replace age5=1 in 10
	replace case=0 in 10
	replace pop_wpp=(24395) in 10
	sort age5
	
	expand 2 in 1
	replace sex=2 in 11
	replace age5=1 in 11
	replace case=0 in 11
	replace pop_wpp=(25316) in 11
	sort age5
	
	expand 2 in 1
	replace sex=1 in 12
	replace age5=2 in 12
	replace case=0 in 12
	replace pop_wpp=(18623) in 12
	sort age5

	expand 2 in 1
	replace sex=2 in 13
	replace age5=2 in 13
	replace case=0 in 13
	replace pop_wpp=(19294) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=3 in 14
	replace case=0 in 14
	replace pop_wpp=(18632) in 14
	sort age5
	
	expand 2 in 1
	replace sex=2 in 15
	replace age5=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18385) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=4 in 16
	replace case=0 in 16
	replace pop_wpp=(19702) in 16
	sort age5
	
	expand 2 in 1
	replace sex=2 in 17
	replace age5=4 in 17
	replace case=0 in 17
	replace pop_wpp=(18767) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=5 in 18
	replace case=0 in 18
	replace pop_wpp=(21092) in 18
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
  |   21   138525   15.16      8.91     5.43    14.08     2.11 |
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
gen percent=number/477*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_male" 
replace cancer_site=5 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_male" ,replace
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
	** M&F 0-14,15-24,25-34
	** M   35-44,85+
	expand 2 in 1
	replace sex=1 in 11
	replace age5=1 in 11
	replace case=0 in 11
	replace pop_wpp=(24395) in 11
	sort age5
	
	expand 2 in 1
	replace sex=2 in 12
	replace age5=1 in 12
	replace case=0 in 12
	replace pop_wpp=(25316) in 12
	sort age5
	
	expand 2 in 1
	replace sex=1 in 13
	replace age5=2 in 13
	replace case=0 in 13
	replace pop_wpp=(18623) in 13
	sort age5
	
	expand 2 in 1
	replace sex=2 in 14
	replace age5=2 in 14
	replace case=0 in 14
	replace pop_wpp=(19294) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18632) in 15
	sort age5
	
	expand 2 in 1
	replace sex=2 in 16
	replace age5=3 in 16
	replace case=0 in 16
	replace pop_wpp=(18385) in 16
	sort age5
	
	expand 2 in 1
	replace sex=2 in 17
	replace age5=4 in 17
	replace case=0 in 17
	replace pop_wpp=(18767) in 17
	sort age5
	
	expand 2 in 1
	replace sex=2 in 18
	replace age5=9 in 18
	replace case=0 in 18
	replace pop_wpp=(2624) in 18
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
  |   23   286640    8.02      5.03     3.15     7.76     1.12 |
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
gen percent=number/949*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs" 
replace cancer_site=10 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs" ,replace
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
	** M&F  0-14,15-24,25-34
	** M	35-44
	** F 	45-54
	expand 2 in 1
	replace sex=1 in 11
	replace age5=1 in 11
	replace case=0 in 11
	replace pop_wpp=(24395) in 11
	sort age5
	
	expand 2 in 1
	replace sex=2 in 12
	replace age5=1 in 12
	replace case=0 in 12
	replace pop_wpp=(25316) in 12
	sort age5
	
	expand 2 in 1
	replace sex=1 in 13
	replace age5=2 in 13
	replace case=0 in 13
	replace pop_wpp=(18623) in 13
	sort age5

	expand 2 in 1
	replace sex=2 in 14
	replace age5=2 in 14
	replace case=0 in 14
	replace pop_wpp=(19294) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18632) in 15
	sort age5

	expand 2 in 1
	replace sex=2 in 16
	replace age5=3 in 16
	replace case=0 in 16
	replace pop_wpp=(18385) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=5 in 17
	replace case=0 in 17
	replace pop_wpp=(21092) in 17
	sort age5
	
	expand 2 in 1
	replace sex=2 in 18
	replace age5=4 in 18
	replace case=0 in 18
	replace pop_wpp=(18767) in 18
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
  |   19   286640    6.63      3.88     2.29     6.30     0.98 |
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
gen percent=number/949*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs" 
replace cancer_site=11 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs" ,replace
restore

/*
** STOMACH - male only for top5 table
preserve
	drop if age5==.
	keep if siteiarc==11
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-14,15-24,25-34,35-44
	expand 2 in 1
	replace sex=1 in 11
	replace age5=1 in 11
	replace case=0 in 11
	replace pop_wpp=(25537) in 11
	sort age5
	
	expand 2 in 1
	replace sex=2 in 12
	replace age5=1 in 12
	replace case=0 in 12
	replace pop_wpp=(26626) in 12
	sort age5
	
	expand 2 in 1
	replace sex=1 in 13
	replace age5=2 in 13
	replace case=0 in 13
	replace pop_wpp=(18761) in 13
	sort age5

	expand 2 in 1
	replace sex=2 in 14
	replace age5=2 in 14
	replace case=0 in 14
	replace pop_wpp=(19111) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18963) in 15
	sort age5

	expand 2 in 1
	replace sex=2 in 16
	replace age5=3 in 16
	replace case=0 in 16
	replace pop_wpp=(18440) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=4 in 17
	replace case=0 in 17
	replace pop_wpp=(20315) in 17
	sort age5
	
	expand 2 in 1
	replace sex=2 in 18
	replace age5=4 in 18
	replace case=0 in 18
	replace pop_wpp=(19218) in 18
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
  |   17   137548   12.36      7.68     4.41    12.71     2.02 |
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
gen percent=number/477*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs_male" 
replace cancer_site=6 if cancer_site==.
replace year=1 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs_male" ,replace
restore
*/
