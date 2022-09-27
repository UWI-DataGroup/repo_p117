
cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          25m_analysis ASIRs_top5sex_2013-2018.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      27-SEP-2022
    // 	date last modified      27-SEP-2022
    //  algorithm task          Analyzing combined cancer dataset: (1) 2013-2018 ASIRs by sex based on 2018's top 5 for each sex for 2016-2018 annual report
    //  status                  Completed
    //  objective               To have one dataset with cleaned and grouped 2013-2018 incidence data for inclusion in 2016-2018 cancer report.
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
    log using "`logpath'/25m_analysis ASIRs_top5sex_2013-2018.smcl", replace
** HEADER -----------------------------------------------------

**********
** 2018 **
**********
** MALE
** Re-arrange 2018 top 5 male ASIR dataset to format SF needs for generating graph in Excel (see OneDrive\FORDE, Shelly-Ann - BNR\REPORTS\Annual Reports\2016-2018 Cancer Report\20220913_Cancer Data 2016-2018_Graphs_JCreview.xlsx)
use "`datapath'\version09\2-working\ASIRs_2018_male", clear

gen id=_n
gen prostate=asir if cancer_site==2
gen colon=asir if cancer_site==3
gen rectum=asir if cancer_site==4
gen lung=asir if cancer_site==5
gen multiple_myeloma=asir if cancer_site==6

drop cancer_site number percent asir ci_lower ci_upper
//ssc install fillmissing
fillmissing prostate colon rectum lung multiple_myeloma
drop if id>1
drop id

save "`datapath'\version09\2-working\ASIRs_2013-2018_male", replace

** FEMALE
** Re-arrange 2018 top 5 male ASIR dataset to format SF needs for generating graph in Excel (see OneDrive\FORDE, Shelly-Ann - BNR\REPORTS\Annual Reports\2016-2018 Cancer Report\20220913_Cancer Data 2016-2018_Graphs_JCreview.xlsx)
use "`datapath'\version09\2-working\ASIRs_2018_female", clear

gen id=_n
gen female_breast=asir if cancer_site==2
gen colon=asir if cancer_site==3
gen corpus_uteri=asir if cancer_site==4
gen pancreas=asir if cancer_site==5
gen multiple_myeloma=asir if cancer_site==6

drop cancer_site number percent asir ci_lower ci_upper
//ssc install fillmissing
fillmissing female_breast colon corpus_uteri pancreas multiple_myeloma
drop if id>1
drop id

save "`datapath'\version09\2-working\ASIRs_2013-2018_female", replace


**********
** 2017 **
**********
** MALE
use "`datapath'\version09\2-working\ASIRs_2017_male", clear

gen id=_n
gen prostate=asir if cancer_site==2
gen colon=asir if cancer_site==3
gen rectum=asir if cancer_site==4
//gen lung=asir if cancer_site==5
//gen multiple_myeloma=asir if cancer_site==6

drop cancer_site number percent asir ci_lower ci_upper
//ssc install fillmissing
fillmissing prostate colon rectum //lung multiple_myeloma
drop if id>1
drop id

append using "`datapath'\version09\2-working\ASIRs_2013-2018_male"
save "`datapath'\version09\2-working\ASIRs_2013-2018_male", replace

** FEMALE
use "`datapath'\version09\2-working\ASIRs_2017_female", clear

gen id=_n
gen female_breast=asir if cancer_site==2
gen colon=asir if cancer_site==3
gen corpus_uteri=asir if cancer_site==4
gen pancreas=asir if cancer_site==6
//gen multiple_myeloma=asir if cancer_site==6

drop if cancer_site==5
drop cancer_site number percent asir ci_lower ci_upper
//ssc install fillmissing
fillmissing female_breast colon corpus_uteri pancreas //multiple_myeloma
drop if id>1
drop id

append using "`datapath'\version09\2-working\ASIRs_2013-2018_female"
save "`datapath'\version09\2-working\ASIRs_2013-2018_female", replace

** Lung and MM not previously calculated for MALES exclusively so will add in now using incidence-pop ds created in 25g_analysis ASIRs_2017.do
use "`datapath'\version09\2-working\2017_cancer_dataset_popn", clear


** LUNG - male only for 2018top5 table
tab pop_wpp age5 if siteiarc==21 & sex==1 //female
tab pop_wpp age5 if siteiarc==21 & sex==2 //male

preserve
	drop if age5==.
	keep if siteiarc==21
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,40-44,45-49
	** F   35-39
	** M   55-59,80-84
	
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
	replace age5=12 in 35
	replace case=0 in 35
	replace pop_wpp=(9322) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=17 in 36
	replace case=0 in 36
	replace pop_wpp=(2387) in 36
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

drop if sex==1 //male ONLY

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR LUNG CANCER (MALE)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   12   138223    8.68      5.34     2.65     9.95     1.77 |
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
gen percent=number/527*100
replace percent=round(percent,0.01)

rename asir lung
gen year=2
label define year_lab 1 "2018" 2 "2017" 3 "2016" 4 "2015" 5 "2014" 6 "2013" ,modify
label values year year_lab
keep year lung

append using "`datapath'\version09\2-working\ASIRs_2013-2018_male"
order year prostate colon rectum lung multiple_myeloma
gen id=_n
fillmissing lung
drop if id!=2 & year==2
drop id
save "`datapath'\version09\2-working\ASIRs_2013-2018_male" ,replace
restore


** MULTIPLE MYELOMA - male only for 2018top5 table
tab pop_wpp age5 if siteiarc==55 & sex==1 //female
tab pop_wpp age5 if siteiarc==55 & sex==2 //male

preserve
	drop if age5==.
	keep if siteiarc==55
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,40-44,45-49
	** F   75-79
	** M   50-54,85+
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=1 in 14
	replace case=0 in 14
	replace pop_wpp=(7407) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=2 in 15
	replace case=0 in 15
	replace pop_wpp=(8258) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=3 in 16
	replace case=0 in 16
	replace pop_wpp=(9079) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=4 in 17
	replace case=0 in 17
	replace pop_wpp=(9274) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=5 in 18
	replace case=0 in 18
	replace pop_wpp=(9422) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=6 in 19
	replace case=0 in 19
	replace pop_wpp=(9191) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=7 in 20
	replace case=0 in 20
	replace pop_wpp=(9554) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=8 in 21
	replace case=0 in 21
	replace pop_wpp=(9646) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=9 in 22
	replace case=0 in 22
	replace pop_wpp=(10261) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=10 in 23
	replace case=0 in 23
	replace pop_wpp=(10436) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=16 in 24
	replace case=0 in 24
	replace pop_wpp=(4402) in 24
	sort age5
	
	expand 2 in 1
	replace sex=2 in 25
	replace age5=1 in 25
	replace case=0 in 25
	replace pop_wpp=(7706) in 25
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 26
	replace age5=2 in 26
	replace case=0 in 26
	replace pop_wpp=(8493) in 26
	sort age5
	
	expand 2 in 1
	replace sex=2 in 27
	replace age5=3 in 27
	replace case=0 in 27
	replace pop_wpp=(9551) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=4 in 28
	replace case=0 in 28
	replace pop_wpp=(9717) in 28
	sort age5
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=5 in 29
	replace case=0 in 29
	replace pop_wpp=(9537) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=6 in 30
	replace case=0 in 30
	replace pop_wpp=(9179) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=7 in 31
	replace case=0 in 31
	replace pop_wpp=(9216) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=8 in 32
	replace case=0 in 32
	replace pop_wpp=(9261) in 32
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
	replace age5=18 in 36
	replace case=0 in 36
	replace pop_wpp=(2596) in 36
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

drop if sex==1 //male ONLY

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR MULTIPLE MYELOMA CANCER (MALE)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |    7   138223    5.06      3.22     1.29     7.12     1.42 |
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
gen percent=number/527*100
replace percent=round(percent,0.01)

rename asir multiple_myeloma
gen year=2
label define year_lab 1 "2018" 2 "2017" 3 "2016" 4 "2015" 5 "2014" 6 "2013" ,modify
label values year year_lab
keep year multiple_myeloma

append using "`datapath'\version09\2-working\ASIRs_2013-2018_male"
order year prostate colon rectum lung multiple_myeloma
gen id=_n
fillmissing multiple_myeloma
drop if id!=2 & year==2
drop id
save "`datapath'\version09\2-working\ASIRs_2013-2018_male" ,replace
restore

** MM not previously calculated for FEMALES exclusively so will add in now using incidence-pop ds created in 25g_analysis ASIRs_2017.do

** MULTIPLE MYELOMA - female only for 2018top5 table
tab pop_wpp age5 if siteiarc==55 & sex==1 //female
tab pop_wpp age5 if siteiarc==55 & sex==2 //male

preserve
	drop if age5==.
	keep if siteiarc==55
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,40-44,45-49
	** F   75-79
	** M   50-54,85+
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=1 in 14
	replace case=0 in 14
	replace pop_wpp=(7407) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=2 in 15
	replace case=0 in 15
	replace pop_wpp=(8258) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=3 in 16
	replace case=0 in 16
	replace pop_wpp=(9079) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=4 in 17
	replace case=0 in 17
	replace pop_wpp=(9274) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=5 in 18
	replace case=0 in 18
	replace pop_wpp=(9422) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=6 in 19
	replace case=0 in 19
	replace pop_wpp=(9191) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=7 in 20
	replace case=0 in 20
	replace pop_wpp=(9554) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=8 in 21
	replace case=0 in 21
	replace pop_wpp=(9646) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=9 in 22
	replace case=0 in 22
	replace pop_wpp=(10261) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=10 in 23
	replace case=0 in 23
	replace pop_wpp=(10436) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=16 in 24
	replace case=0 in 24
	replace pop_wpp=(4402) in 24
	sort age5
	
	expand 2 in 1
	replace sex=2 in 25
	replace age5=1 in 25
	replace case=0 in 25
	replace pop_wpp=(7706) in 25
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 26
	replace age5=2 in 26
	replace case=0 in 26
	replace pop_wpp=(8493) in 26
	sort age5
	
	expand 2 in 1
	replace sex=2 in 27
	replace age5=3 in 27
	replace case=0 in 27
	replace pop_wpp=(9551) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=4 in 28
	replace case=0 in 28
	replace pop_wpp=(9717) in 28
	sort age5
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=5 in 29
	replace case=0 in 29
	replace pop_wpp=(9537) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=6 in 30
	replace case=0 in 30
	replace pop_wpp=(9179) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=7 in 31
	replace case=0 in 31
	replace pop_wpp=(9216) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=8 in 32
	replace case=0 in 32
	replace pop_wpp=(9261) in 32
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
	replace age5=18 in 36
	replace case=0 in 36
	replace pop_wpp=(2596) in 36
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

drop if sex==2 //female ONLY

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR MULTIPLE MYELOMA CANCER (FEMALE)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |    9   148006    6.08      3.22     1.42     6.82     1.31 |
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
gen percent=number/450*100
replace percent=round(percent,0.01)

rename asir multiple_myeloma
gen year=2
label define year_lab 1 "2018" 2 "2017" 3 "2016" 4 "2015" 5 "2014" 6 "2013" ,modify
label values year year_lab
keep year multiple_myeloma

append using "`datapath'\version09\2-working\ASIRs_2013-2018_female"
order year female_breast colon corpus_uteri pancreas multiple_myeloma
gen id=_n
fillmissing multiple_myeloma
drop if id!=2 & year==2
drop id
save "`datapath'\version09\2-working\ASIRs_2013-2018_female" ,replace
restore



**********
** 2016 **
**********
** MALE
use "`datapath'\version09\2-working\ASIRs_2016_male", clear

gen id=_n
gen prostate=asir if cancer_site==2
gen colon=asir if cancer_site==3
gen rectum=asir if cancer_site==5
gen lung=asir if cancer_site==4
gen multiple_myeloma=asir if cancer_site==7

drop cancer_site number percent asir ci_lower ci_upper
//ssc install fillmissing
fillmissing prostate colon rectum lung multiple_myeloma
drop if id>1
drop id

append using "`datapath'\version09\2-working\ASIRs_2013-2018_male"
save "`datapath'\version09\2-working\ASIRs_2013-2018_male", replace

** FEMALE
use "`datapath'\version09\2-working\ASIRs_2016_female", clear

gen id=_n
gen female_breast=asir if cancer_site==2
gen colon=asir if cancer_site==3
gen corpus_uteri=asir if cancer_site==4
//gen pancreas=asir if cancer_site==6
//gen multiple_myeloma=asir if cancer_site==6

drop if cancer_site==5
drop cancer_site number percent asir ci_lower ci_upper
//ssc install fillmissing
fillmissing female_breast colon corpus_uteri //pancreas multiple_myeloma
drop if id>1
drop id

append using "`datapath'\version09\2-working\ASIRs_2013-2018_female"
save "`datapath'\version09\2-working\ASIRs_2013-2018_female", replace

** Pancreas and MM not previously calculated for FEMALES exclusively so will add in now using incidence-pop ds created in 25g_analysis ASIRs_2017.do
use "`datapath'\version09\2-working\2016_cancer_dataset_popn", clear


** PANCREAS - female only for 2018top5 table
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

drop if sex==2 //female ONLY

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PANCREATIC CANCER (F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   15   147896   10.14      5.06     2.74     9.09     1.54 |
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
gen percent=number/491*100
replace percent=round(percent,0.01)

rename asir pancreas
gen year=3
label define year_lab 1 "2018" 2 "2017" 3 "2016" 4 "2015" 5 "2014" 6 "2013" ,modify
label values year year_lab
keep year pancreas

append using "`datapath'\version09\2-working\ASIRs_2013-2018_female"
order year female_breast colon corpus_uteri pancreas multiple_myeloma
gen id=_n
fillmissing pancreas
drop if id!=2 & year==3
drop id
save "`datapath'\version09\2-working\ASIRs_2013-2018_female" ,replace
restore



** MULTIPLE MYELOMA - female only for 2018top5 table
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

drop if sex==2 //female ONLY

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR MULTIPLE MYELOMA CANCER (F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   18   147896   12.17      7.12     4.20    11.75     1.83 |
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
gen percent=number/491*100
replace percent=round(percent,0.01)

rename asir multiple_myeloma
gen year=3
label define year_lab 1 "2018" 2 "2017" 3 "2016" 4 "2015" 5 "2014" 6 "2013" ,modify
label values year year_lab
keep year multiple_myeloma

append using "`datapath'\version09\2-working\ASIRs_2013-2018_female"
order year female_breast colon corpus_uteri pancreas multiple_myeloma
gen id=_n
replace multiple_myeloma=multiple_myeloma[_n-1] if multiple_myeloma==.
//fillmissing multiple_myeloma

drop if id!=2 & year==3
drop id
save "`datapath'\version09\2-working\ASIRs_2013-2018_female" ,replace
restore



** All sites were not previously calculated for MALES / FEMALES exclusively so will calculate in 25e_analysis ASIRs_2015.do and add them in here
**********
** 2015 **
**********
** MALE
use "`datapath'\version09\2-working\ASIRs_2015_male", clear

gen id=_n
gen prostate=asir if cancer_site==2
gen colon=asir if cancer_site==3
gen rectum=asir if cancer_site==4
gen lung=asir if cancer_site==5
gen multiple_myeloma=asir if cancer_site==6

drop cancer_site number percent asir ci_lower ci_upper
//ssc install fillmissing
fillmissing prostate colon rectum lung multiple_myeloma
drop if id>1
drop id

append using "`datapath'\version09\2-working\ASIRs_2013-2018_male"
save "`datapath'\version09\2-working\ASIRs_2013-2018_male", replace

** FEMALE
use "`datapath'\version09\2-working\ASIRs_2015_female", clear

gen id=_n
gen female_breast=asir if cancer_site==2
gen colon=asir if cancer_site==3
gen corpus_uteri=asir if cancer_site==4
gen pancreas=asir if cancer_site==5
gen multiple_myeloma=asir if cancer_site==6

drop cancer_site number percent asir ci_lower ci_upper
//ssc install fillmissing
fillmissing female_breast colon corpus_uteri pancreas multiple_myeloma
drop if id>1
drop id

append using "`datapath'\version09\2-working\ASIRs_2013-2018_female"
save "`datapath'\version09\2-working\ASIRs_2013-2018_female", replace



** All sites were not previously calculated for MALES / FEMALES exclusively so will calculate in 25d_analysis ASIRs_2014.do and add them in here
**********
** 2014 **
**********
** MALE
use "`datapath'\version09\2-working\ASIRs_2014_male", clear

gen id=_n
gen prostate=asir if cancer_site==2
gen colon=asir if cancer_site==3
gen rectum=asir if cancer_site==4
gen lung=asir if cancer_site==5
gen multiple_myeloma=asir if cancer_site==6

drop cancer_site number percent asir ci_lower ci_upper
//ssc install fillmissing
fillmissing prostate colon rectum lung multiple_myeloma
drop if id>1
drop id

append using "`datapath'\version09\2-working\ASIRs_2013-2018_male"
save "`datapath'\version09\2-working\ASIRs_2013-2018_male", replace

** FEMALE
use "`datapath'\version09\2-working\ASIRs_2014_female", clear

gen id=_n
gen female_breast=asir if cancer_site==2
gen colon=asir if cancer_site==3
gen corpus_uteri=asir if cancer_site==4
gen pancreas=asir if cancer_site==5
gen multiple_myeloma=asir if cancer_site==6

drop cancer_site number percent asir ci_lower ci_upper
//ssc install fillmissing
fillmissing female_breast colon corpus_uteri pancreas multiple_myeloma
drop if id>1
drop id

append using "`datapath'\version09\2-working\ASIRs_2013-2018_female"
save "`datapath'\version09\2-working\ASIRs_2013-2018_female", replace



** All sites were not previously calculated for MALES / FEMALES exclusively so will calculate in 25c_analysis ASIRs_2013.do and add them in here
**********
** 2013 **
**********
** MALE
use "`datapath'\version09\2-working\ASIRs_2013_male", clear

gen id=_n
gen prostate=asir if cancer_site==2
gen colon=asir if cancer_site==3
gen rectum=asir if cancer_site==4
gen lung=asir if cancer_site==5
gen multiple_myeloma=asir if cancer_site==6

drop cancer_site number percent asir ci_lower ci_upper
//ssc install fillmissing
fillmissing prostate colon rectum lung multiple_myeloma
drop if id>1
drop id

append using "`datapath'\version09\2-working\ASIRs_2013-2018_male"
save "`datapath'\version09\2-working\ASIRs_2013-2018_male", replace

** FEMALE
use "`datapath'\version09\2-working\ASIRs_2013_female", clear

gen id=_n
gen female_breast=asir if cancer_site==2
gen colon=asir if cancer_site==3
gen corpus_uteri=asir if cancer_site==4
gen pancreas=asir if cancer_site==5
gen multiple_myeloma=asir if cancer_site==6

drop cancer_site number percent asir ci_lower ci_upper
//ssc install fillmissing
fillmissing female_breast colon corpus_uteri pancreas multiple_myeloma
drop if id>1
drop id

append using "`datapath'\version09\2-working\ASIRs_2013-2018_female"
save "`datapath'\version09\2-working\ASIRs_2013-2018_female", replace

