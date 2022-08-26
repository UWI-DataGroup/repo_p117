
cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          25d_analysis ASIRs_2014.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      25-AUG-2022
    // 	date last modified      25-AUG-2022
    //  algorithm task          Analyzing combined cancer dataset: (1) Numbers (2) ASIRs for 2016-2018 annual report
    //  status                  Completed
    //  objective               To have one dataset with cleaned and grouped 2014 incidence data for inclusion in 2016-2018 cancer report.
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
    log using "`logpath'/25d_analysis ASIRs_2014.smcl", replace
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
** 2014 **
**********
drop if dxyr!=2014 //0 deleted

count //884

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
merge m:m sex age5 using "`datapath'\version09\2-working\pop_wpp_2014-5"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                             1
        from master                         0  (_merge==1)
        from using                          1  (_merge==2)

    Matched                               884  (_merge==3)
    -----------------------------------------
*/

**drop if _merge==2 //do not drop these age groups as it skews pop_wpp 
** There is 1 unmatched record (_merge==2) since 2013 data doesn't have any cases of 15-19 female

tab age5 ,m //none missing

drop case
gen case=1 if pid!="" //do not generate case for missing age group as it skews case total
gen pfu=1 // for % year if not whole year collected; not done for cancer

list pid sex age5 if _merge==2 //missing are 0-4 male; 5-9 female + male; 15-19 female; 20-24 male; 25-29 male

list pid sex age5 if age5==4 & sex==1
replace case=0 if age5==4 & sex==1 //1 change


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
gen year=2014
rename siteiarc cancer_site
rename incirate age_specific_rate
drop pfu case pop_wpp
order year cancer_site sex age5 age_specific_rate
save "`datapath'\version09\2-working\2014_top10_age+sex_rates" ,replace
restore

** Check for missing age as these would need to be added to the median group for that site when assessing ASIRs to prevent creating an outlier
count if age==.|age==999 //1 - don't change as this is the missing 15-19 female group

** Below saved in pathway: 
//X:\The University of the West Indies\DataGroup - repo_data\data_p117\version09\2-working\WPP_population by sex_2013.txt
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
restore


** Next, IRs for invasive tumours only
preserve
	drop if age5==.
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** Check for missing age groups for total invasive tumours
	** now we have to add in the cases and popns for the missings: none missing
		
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
  |  884   284825   310.37    206.18   192.30   220.88     7.21 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
gen cancer_site=1
gen year=5
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
gen percent=number/884*100
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
	replace pop_wpp=(8055) in 11
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 12
	replace age5=2 in 12
	replace case=0 in 12
	replace pop_wpp=(9178) in 12
	sort age5
	
	expand 2 in 1
	replace sex=2 in 13
	replace age5=3 in 13
	replace case=0 in 13
	replace pop_wpp=(9829) in 13
	sort age5
	
	expand 2 in 1
	replace sex=2 in 14
	replace age5=4 in 14
	replace case=0 in 14
	replace pop_wpp=(9598) in 14
	sort age5
	
	expand 2 in 1
	replace sex=2 in 15
	replace age5=5 in 15
	replace case=0 in 15
	replace pop_wpp=(9434) in 15
	sort age5
	
	expand 2 in 1
	replace sex=2 in 16
	replace age5=6 in 16
	replace case=0 in 16
	replace pop_wpp=(9115) in 16
	sort age5
	
	expand 2 in 1
	replace sex=2 in 17
	replace age5=7 in 17
	replace case=0 in 17
	replace pop_wpp=(9376) in 17
	sort age5
	
	expand 2 in 1
	replace sex=2 in 18
	replace age5=8 in 18
	replace case=0 in 18
	replace pop_wpp=(9425) in 18
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
  |  185   137169   134.87     90.90    78.10   105.41     6.81 |
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
gen percent=number/884*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs" 
replace cancer_site=2 if cancer_site==.
replace year=5 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs" ,replace
restore


** BREAST
tab pop_wpp age5  if siteiarc==29 & sex==1 //female
tab pop_wpp age5  if siteiarc==29 & sex==2 //male

//JC 19may2022: remove male breast cancers so rate calculated only based on female pop
preserve
	drop if age5==.
	keep if siteiarc==29
	drop if sex==2
		
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
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
** THIS IS FOR BC (FEMALE) - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  152   147656   102.94     68.73    57.83    81.26     5.84 |
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
gen percent=number/884*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs" 
replace cancer_site=3 if cancer_site==.
replace year=5 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs" ,replace
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
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34
	** F   35-39
	** M   50-54
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=1 in 23
	replace case=0 in 23
	replace pop_wpp=(7807) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=2 in 24
	replace case=0 in 24
	replace pop_wpp=(8818) in 24
	sort age5

	expand 2 in 1
	replace sex=1 in 25
	replace age5=3 in 25
	replace case=0 in 25
	replace pop_wpp=(9304) in 25
	sort age5

	expand 2 in 1
	replace sex=1 in 26
	replace age5=4 in 26
	replace case=0 in 26
	replace pop_wpp=(9336) in 26
	sort age5

	expand 2 in 1
	replace sex=1 in 27
	replace age5=5 in 27
	replace case=0 in 27
	replace pop_wpp=(9435) in 27
	sort age5

	expand 2 in 1
	replace sex=1 in 28
	replace age5=7 in 28
	replace case=0 in 28
	replace pop_wpp=(9848) in 28
	sort age5
	
	expand 2 in 1
	replace sex=1 in 29
	replace age5=8 in 29
	replace case=0 in 29
	replace pop_wpp=(9820) in 29
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
	replace age5=4 in 33
	replace case=0 in 33
	replace pop_wpp=(9598) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=5 in 34
	replace case=0 in 34
	replace pop_wpp=(9434) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=7 in 35
	replace case=0 in 35
	replace pop_wpp=(9376) in 35
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
** THIS IS FOR COLON CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  104   284825   36.51     23.77    19.30    29.07     2.42 |
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
gen percent=number/884*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs" 
replace cancer_site=4 if cancer_site==.
replace year=5 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs" ,replace
restore


** CORPUS UTERI
tab pop_wpp age5 if siteiarc==33

preserve
	drop if age5==.
	keep if siteiarc==33 // corpus uteri only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,40-44
	
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
  |   38   147656   25.74     16.27    11.45    22.75     2.77 |
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
gen percent=number/884*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs" 
replace cancer_site=5 if cancer_site==.
replace year=5 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs" ,replace
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
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,45-49,85+
	** F   40-44
	
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
	replace sex=1 in 26
	replace age5=18 in 26
	replace case=0 in 26
	replace pop_wpp=(3974) in 26
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
** THIS IS FOR MULTIPLE MYELOMA CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   31   284825   10.88      7.07     4.78    10.22     1.33 |
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
gen percent=number/884*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs" 
replace cancer_site=6 if cancer_site==.
replace year=5 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs" ,replace
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
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,40-44
	** F   55-59,60-64,85+
	** M   45-49,50-54
	
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
	replace age5=12 in 23
	replace case=0 in 23
	replace pop_wpp=(10136) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=13 in 24
	replace case=0 in 24
	replace pop_wpp=(8207) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=18 in 25
	replace case=0 in 25
	replace pop_wpp=(3974) in 25
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
** THIS IS FOR PANCREATIC CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   22   284825    7.72      4.53     2.80     7.13     1.05 |
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
gen percent=number/884*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs" 
replace cancer_site=7 if cancer_site==.
replace year=5 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs" ,replace
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
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,40-44,45-49,80-84
	** F   65-69
	** M   35-39,85+
	
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
	replace age5=9 in 21
	replace case=0 in 21
	replace pop_wpp=(10706) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=10 in 22
	replace case=0 in 22
	replace pop_wpp=(10559) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=14 in 23
	replace case=0 in 23
	replace pop_wpp=(6598) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=17 in 24
	replace case=0 in 24
	replace pop_wpp=(3272) in 24
	sort age5
	
	expand 2 in 1
	replace sex=2 in 25
	replace age5=1 in 25
	replace case=0 in 25
	replace pop_wpp=(8055) in 25
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 26
	replace age5=2 in 26
	replace case=0 in 26
	replace pop_wpp=(9178) in 26
	sort age5
	
	expand 2 in 1
	replace sex=2 in 27
	replace age5=3 in 27
	replace case=0 in 27
	replace pop_wpp=(9829) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=4 in 28
	replace case=0 in 28
	replace pop_wpp=(9598) in 28
	sort age5
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=5 in 29
	replace case=0 in 29
	replace pop_wpp=(9434) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=6 in 30
	replace case=0 in 30
	replace pop_wpp=(9115) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=7 in 31
	replace case=0 in 31
	replace pop_wpp=(9376) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=8 in 32
	replace case=0 in 32
	replace pop_wpp=(9425) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=9 in 33
	replace case=0 in 33
	replace pop_wpp=(9927) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=10 in 34
	replace case=0 in 34
	replace pop_wpp=(9690) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=17 in 35
	replace case=0 in 35
	replace pop_wpp=(2198) in 35
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
** THIS IS FOR RECTAL CANCER (M&F)- STD TO WHO WORLD POPN

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   26   284825    9.13      5.97     3.86     8.96     1.25 |
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
gen percent=number/884*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs" 
replace cancer_site=8 if cancer_site==.
replace year=5 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs" ,replace
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
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,40-44,45-49,50-54
	** M   75-79
	
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
	replace sex=2 in 25
	replace age5=1 in 25
	replace case=0 in 25
	replace pop_wpp=(8055) in 25
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 26
	replace age5=2 in 26
	replace case=0 in 26
	replace pop_wpp=(9178) in 26
	sort age5
	
	expand 2 in 1
	replace sex=2 in 27
	replace age5=3 in 27
	replace case=0 in 27
	replace pop_wpp=(9829) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=4 in 28
	replace case=0 in 28
	replace pop_wpp=(9598) in 28
	sort age5
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=5 in 29
	replace case=0 in 29
	replace pop_wpp=(9434) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=6 in 30
	replace case=0 in 30
	replace pop_wpp=(9115) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=7 in 31
	replace case=0 in 31
	replace pop_wpp=(9376) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=8 in 32
	replace case=0 in 32
	replace pop_wpp=(9425) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=9 in 33
	replace case=0 in 33
	replace pop_wpp=(9927) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=10 in 34
	replace case=0 in 34
	replace pop_wpp=(9690) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=11 in 35
	replace case=0 in 35
	replace pop_wpp=(9857) in 35
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
** THIS IS FOR LUNG CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   33   284825   11.59      6.64     4.50     9.61     1.25 |
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
gen percent=number/884*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs" 
replace cancer_site=9 if cancer_site==.
replace year=5 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs" ,replace
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
	** M&F 0-4,5-9,10-14,15-19,25-29,30-34
	** F   20-24,35-39,45-49,50-54,55-59,60-64,65-69,70-74,80-84,85+
	** M   40-44,75-79
	
	expand 2 in 1
	replace sex=1 in 13
	replace age5=1 in 13
	replace case=0 in 13
	replace pop_wpp=(7807) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=2 in 14
	replace case=0 in 14
	replace pop_wpp=(8818) in 14
	sort age5

	expand 2 in 1
	replace sex=1 in 15
	replace age5=3 in 15
	replace case=0 in 15
	replace pop_wpp=(9304) in 15
	sort age5

	expand 2 in 1
	replace sex=1 in 16
	replace age5=4 in 16
	replace case=0 in 16
	replace pop_wpp=(9336) in 16
	sort age5

	expand 2 in 1
	replace sex=1 in 17
	replace age5=5 in 17
	replace case=0 in 17
	replace pop_wpp=(9435) in 17
	sort age5

	expand 2 in 1
	replace sex=1 in 18
	replace age5=6 in 18
	replace case=0 in 18
	replace pop_wpp=(9240) in 18
	sort age5

	expand 2 in 1
	replace sex=1 in 19
	replace age5=7 in 19
	replace case=0 in 19
	replace pop_wpp=(9848) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=8 in 20
	replace case=0 in 20
	replace pop_wpp=(9820) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=10 in 21
	replace case=0 in 21
	replace pop_wpp=(10559) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=11 in 22
	replace case=0 in 22
	replace pop_wpp=(11198) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=12 in 23
	replace case=0 in 23
	replace pop_wpp=(10136) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=13 in 24
	replace case=0 in 24
	replace pop_wpp=(8207) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=14 in 25
	replace case=0 in 25
	replace pop_wpp=(6598) in 25
	sort age5
	
	expand 2 in 1
	replace sex=1 in 26
	replace age5=15 in 26
	replace case=0 in 26
	replace pop_wpp=(5125) in 26
	sort age5
	
	expand 2 in 1
	replace sex=1 in 27
	replace age5=17 in 27
	replace case=0 in 27
	replace pop_wpp=(3272) in 27
	sort age5
	
	expand 2 in 1
	replace sex=1 in 28
	replace age5=18 in 28
	replace case=0 in 28
	replace pop_wpp=(3974) in 28
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
** THIS IS FOR NHL (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   16   284825    5.62      3.89     2.15     6.58     1.08 |
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
gen percent=number/884*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs" 
replace cancer_site=10 if cancer_site==.
replace year=5 if year==.
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
	** M&F  0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,45-49
	** F 	40-44,50-54,55-59,65-69,70-74
	** M	60-64,80-84
	
	expand 2 in 1
	replace sex=1 in 12
	replace age5=1 in 12
	replace case=0 in 12
	replace pop_wpp=(7807) in 12
	sort age5
	
	expand 2 in 1
	replace sex=1 in 13
	replace age5=2 in 13
	replace case=0 in 13
	replace pop_wpp=(8818) in 13
	sort age5

	expand 2 in 1
	replace sex=1 in 14
	replace age5=3 in 14
	replace case=0 in 14
	replace pop_wpp=(9304) in 14
	sort age5

	expand 2 in 1
	replace sex=1 in 15
	replace age5=4 in 15
	replace case=0 in 15
	replace pop_wpp=(9336) in 15
	sort age5

	expand 2 in 1
	replace sex=1 in 16
	replace age5=5 in 16
	replace case=0 in 16
	replace pop_wpp=(9435) in 16
	sort age5

	expand 2 in 1
	replace sex=1 in 17
	replace age5=6 in 17
	replace case=0 in 17
	replace pop_wpp=(9240) in 17
	sort age5

	expand 2 in 1
	replace sex=1 in 18
	replace age5=7 in 18
	replace case=0 in 18
	replace pop_wpp=(9848) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=8 in 19
	replace case=0 in 19
	replace pop_wpp=(9820) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=9 in 20
	replace case=0 in 20
	replace pop_wpp=(10706) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=10 in 21
	replace case=0 in 21
	replace pop_wpp=(10559) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=11 in 22
	replace case=0 in 22
	replace pop_wpp=(11198) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=12 in 23
	replace case=0 in 23
	replace pop_wpp=(10136) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=14 in 24
	replace case=0 in 24
	replace pop_wpp=(6598) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=15 in 25
	replace case=0 in 25
	replace pop_wpp=(5125) in 25
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
	replace age5=10 in 34
	replace case=0 in 34
	replace pop_wpp=(9690) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=13 in 35
	replace case=0 in 35
	replace pop_wpp=(7232) in 35
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
** THIS IS FOR STOMACH CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   21   284825    7.37      4.13     2.49     6.64     1.01 |
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
gen percent=number/884*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASIRs" 
replace cancer_site=11 if cancer_site==.
replace year=5 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\ASIRs" ,replace
restore
