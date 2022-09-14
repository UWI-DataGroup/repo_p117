
cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          25k_analysis ASIRs_top15_2017.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      14-SEP-2022
    // 	date last modified      14-SEP-2022
    //  algorithm task          Analyzing combined cancer dataset: (1) 2018's top 15 ASIRs for 2016-2018 annual report as requested by NS on 13sep2022.
    //  status                  Completed
    //  objective               To have one dataset with cleaned and grouped 2017 incidence data for inclusion in 2016-2018 cancer report.
	//	methods					(1) Using 5-year age groups instead of 10-year
	//							(2) Using female population for breast instead of total population
	//							(3) Using WPP population instead of BSS population
	//							(4) Using abbreviated dofile from 25h_analysis ASIRs_2018.do to include 11-15 sites of 2018's top 15.
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
    log using "`logpath'/25k_analysis ASIRs_top15_2017.smcl", replace
** HEADER -----------------------------------------------------

* *********************************************
* ANALYSIS: SECTION 3 - cancer sites
* Covering:
* 	- ASIRs by site for last 5 of the top 15
* *********************************************
** NOTE: bb popn and WHO popn data prepared by IH are ALL coded M=2 and F=1
** Above note by AR from 2008 dofile

** Load the dataset: use the one created in other ASIRs_2018 dofile for generating age + gender stratified graphs
use "`datapath'\version09\2-working\2017_cancer_dataset_popn", clear

** Comments from site order table code in dofile 25b_analysis sites.do.
/*
     +-------------------------------------------------------+
     | order_id                                     siteiarc |
     |-------------------------------------------------------|
  1. |        1                               Prostate (C61) |
  2. |        2                                 Breast (C50) |
  3. |        3                                  Colon (C18) |
  4. |        4                           Corpus uteri (C54) |
  5. |        5                       Multiple myeloma (C90) |
     |-------------------------------------------------------|
  6. |        6                               Pancreas (C25) |
  7. |        7                              Rectum (C19-20) |
  8. |        8   Lung (incl. trachea and bronchus) (C33-34) |
  9. |        9            Non-Hodgkin lymphoma (C82-86,C96) |
 10. |       10                                Stomach (C16) |
     |-------------------------------------------------------|
 11. |       11                                 Kidney (C64) | siteiarc==42
 12. |       12                                Bladder (C67) | siteiarc==45
 13. |       13                           Cervix uteri (C53) | siteiarc==32
 14. |       14                                Thyroid (C73) | siteiarc==49
 15. |       15                                 Larynx (C32) | siteiarc==20
     |-------------------------------------------------------| 
*/

********************************
** Next, IRs by site and year **
********************************
** KIDNEY
tab pop_wpp age5 if siteiarc==42 & sex==1 //female
tab pop_wpp age5 if siteiarc==42 & sex==2 //male

preserve
	drop if age5==. //0 deleted
	keep if siteiarc==42 // kidney only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,35-39,40-44,45-49,75-79,85+
	** F   60-64,65-69,70-74,80-84
	** M   30-34,55-59
	
	expand 2 in 1
	replace sex=1 in 9
	replace age5=1 in 9
	replace case=0 in 9
	replace pop_wpp=(7407) in 9
	sort age5
	
	expand 2 in 1
	replace sex=1 in 10
	replace age5=2 in 10
	replace case=0 in 10
	replace pop_wpp=(8258) in 10
	sort age5
	
	expand 2 in 1
	replace sex=1 in 11
	replace age5=3 in 11
	replace case=0 in 11
	replace pop_wpp=(9079) in 11
	sort age5
	
	expand 2 in 1
	replace sex=1 in 12
	replace age5=4 in 12
	replace case=0 in 12
	replace pop_wpp=(9274) in 12
	sort age5
	
	expand 2 in 1
	replace sex=1 in 13
	replace age5=5 in 13
	replace case=0 in 13
	replace pop_wpp=(9422) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=6 in 14
	replace case=0 in 14
	replace pop_wpp=(9191) in 14
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
	replace age5=13 in 18
	replace case=0 in 18
	replace pop_wpp=(9132) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=14 in 19
	replace case=0 in 19
	replace pop_wpp=(7328) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=15 in 20
	replace case=0 in 20
	replace pop_wpp=(5645) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=16 in 21
	replace case=0 in 21
	replace pop_wpp=(4402) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=17 in 22
	replace case=0 in 22
	replace pop_wpp=(3327) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=18 in 23
	replace case=0 in 23
	replace pop_wpp=(4080) in 23
	sort age5
	
	expand 2 in 1
	replace sex=2 in 24
	replace age5=1 in 24
	replace case=0 in 24
	replace pop_wpp=(7706) in 24
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 25
	replace age5=2 in 25
	replace case=0 in 25
	replace pop_wpp=(8493) in 25
	sort age5
	
	expand 2 in 1
	replace sex=2 in 26
	replace age5=3 in 26
	replace case=0 in 26
	replace pop_wpp=(9551) in 26
	sort age5
	
	expand 2 in 1
	replace sex=2 in 27
	replace age5=4 in 27
	replace case=0 in 27
	replace pop_wpp=(9717) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=5 in 28
	replace case=0 in 28
	replace pop_wpp=(9537) in 28
	sort age5
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=6 in 29
	replace case=0 in 29
	replace pop_wpp=(9179) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=7 in 30
	replace case=0 in 30
	replace pop_wpp=(9216) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=8 in 31
	replace case=0 in 31
	replace pop_wpp=(9261) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=9 in 32
	replace case=0 in 32
	replace pop_wpp=(9663) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=10 in 33
	replace case=0 in 33
	replace pop_wpp=(9666) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=12 in 34
	replace case=0 in 34
	replace pop_wpp=(9322) in 34
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
** THIS IS FOR KIDNEY CANCER (M&F) - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   12   286229    4.19      2.83     1.43     5.18     0.91 |
  +------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting
gen cancer_site=12
gen year=2
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
gen percent=number/977*100
replace percent=round(percent,0.01)

 
//JC 19may2022: rename breast to female breast as drop males in distrate breast section so ASIR for breast is calculated using female population
label define cancer_site_lab 1 "all" 2 "prostate" 3 "female breast" 4 "colon" 5 "corpus uteri" 6 "multiple myeloma" 7 "pancreas" ///
							 8 "rectum" 9 "lung" 10 "non-hodgkin lymphoma" 11 "stomach" 12 "kidney" 13 "bladder" ///
							 14 "cervix uteri" 15 "thyroid" 16 "larynx" ,modify
label values cancer_site cancer_site_lab
label define year_lab 1 "2018" 2 "2017" 3 "2016" 4 "2015" 5 "2014" 6 "2013" ,modify
label values year year_lab
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\2018ASIRs_top15_2017" ,replace
restore

** BLADDER
tab pop_wpp age5  if siteiarc==45 & sex==1 //female
tab pop_wpp age5  if siteiarc==45 & sex==2 //male

preserve
	drop if age5==.
	keep if siteiarc==45 //bladder only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F  0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,40-44,60-64,75-79
	** F 	45-49,50-54,55-59
	
	expand 2 in 1
	replace sex=1 in 12
	replace age5=1 in 12
	replace case=0 in 12
	replace pop_wpp=(7407) in 12
	sort age5
	
	expand 2 in 1
	replace sex=1 in 13
	replace age5=2 in 13
	replace case=0 in 13
	replace pop_wpp=(8258) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=3 in 14
	replace case=0 in 14
	replace pop_wpp=(9079) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=4 in 15
	replace case=0 in 15
	replace pop_wpp=(9274) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=5 in 16
	replace case=0 in 16
	replace pop_wpp=(9422) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=6 in 17
	replace case=0 in 17
	replace pop_wpp=(9191) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=7 in 18
	replace case=0 in 18
	replace pop_wpp=(9554) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=8 in 19
	replace case=0 in 19
	replace pop_wpp=(9646) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=9 in 20
	replace case=0 in 20
	replace pop_wpp=(10261) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=10 in 21
	replace case=0 in 21
	replace pop_wpp=(10436) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=11 in 22
	replace case=0 in 22
	replace pop_wpp=(10815) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=12 in 23
	replace case=0 in 23
	replace pop_wpp=(10749) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=13 in 24
	replace case=0 in 24
	replace pop_wpp=(9132) in 24
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
	replace age5=8 in 33
	replace case=0 in 33
	replace pop_wpp=(9261) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=9 in 34
	replace case=0 in 34
	replace pop_wpp=(9663) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=13 in 35
	replace case=0 in 35
	replace pop_wpp=(7904) in 35
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
** THIS IS FOR BLADDER CANCER (M&F) - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   17   286229    5.94      3.23     1.83     5.50     0.89 |
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
gen percent=number/977*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\2018ASIRs_top15_2017" 
replace cancer_site=13 if cancer_site==.
replace year=2 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\2018ASIRs_top15_2017" ,replace
restore


** CERVIX UTERI
tab pop_wpp age5 if siteiarc==32

preserve
	drop if age5==.
	keep if siteiarc==32 // cervix uteri only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-4,5-9,10-14,15-19,20-24,25-29,35-39,50-54,75-79,85+
	
	expand 2 in 1
	replace sex=1 in 9
	replace age5=1 in 9
	replace case=0 in 9
	replace pop_wpp=(7407) in 9
	sort age5
	
	expand 2 in 1
	replace sex=1 in 10
	replace age5=2 in 10
	replace case=0 in 10
	replace pop_wpp=(8258) in 10
	sort age5
	
	expand 2 in 1
	replace sex=1 in 11
	replace age5=3 in 11
	replace case=0 in 11
	replace pop_wpp=(9079) in 11
	sort age5
	
	expand 2 in 1
	replace sex=1 in 12
	replace age5=4 in 12
	replace case=0 in 12
	replace pop_wpp=(9274) in 12
	sort age5
	
	expand 2 in 1
	replace sex=1 in 13
	replace age5=5 in 13
	replace case=0 in 13
	replace pop_wpp=(9422) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=6 in 14
	replace case=0 in 14
	replace pop_wpp=(9191) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=8 in 15
	replace case=0 in 15
	replace pop_wpp=(9646) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=11 in 16
	replace case=0 in 16
	replace pop_wpp=(10815) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=16 in 17
	replace case=0 in 17
	replace pop_wpp=(4402) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=18 in 18
	replace case=0 in 18
	replace pop_wpp=(4080) in 18
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CERVIX UTERI - STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   12   148006    8.11      6.10     3.03    11.13     1.98 |
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
gen percent=number/977*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\2018ASIRs_top15_2017" 
replace cancer_site=14 if cancer_site==.
replace year=2 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\2018ASIRs_top15_2017" ,replace
restore


** THYROID
tab pop_wpp age5 if siteiarc==49 & sex==1 //female
tab pop_wpp age5 if siteiarc==49 & sex==2 //male

preserve
	drop if age5==.
	keep if siteiarc==49
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-4,5-9,10-14,15-19,20-24,50-54
	** F   30-34,70-74
	** M   25-29,35-39,40-44,45-49,60-64,65-69,75-79,80-84,85+
	
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
	replace age5=7 in 18
	replace case=0 in 18
	replace pop_wpp=(9554) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=11 in 19
	replace case=0 in 19
	replace pop_wpp=(10815) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=15 in 20
	replace case=0 in 20
	replace pop_wpp=(5645) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=16 in 21
	replace case=0 in 21
	replace pop_wpp=(4402) in 21
	sort age5
	
	expand 2 in 1
	replace sex=2 in 22
	replace age5=1 in 22
	replace case=0 in 22
	replace pop_wpp=(7706) in 22
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 23
	replace age5=2 in 23
	replace case=0 in 23
	replace pop_wpp=(8493) in 23
	sort age5
	
	expand 2 in 1
	replace sex=2 in 24
	replace age5=3 in 24
	replace case=0 in 24
	replace pop_wpp=(9551) in 24
	sort age5
	
	expand 2 in 1
	replace sex=2 in 25
	replace age5=4 in 25
	replace case=0 in 25
	replace pop_wpp=(9717) in 25
	sort age5
	
	expand 2 in 1
	replace sex=2 in 26
	replace age5=5 in 26
	replace case=0 in 26
	replace pop_wpp=(9537) in 26
	sort age5
	
	expand 2 in 1
	replace sex=2 in 27
	replace age5=6 in 27
	replace case=0 in 27
	replace pop_wpp=(9179) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=8 in 28
	replace case=0 in 28
	replace pop_wpp=(9261) in 28
	sort age5
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=9 in 29
	replace case=0 in 29
	replace pop_wpp=(9663) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=10 in 30
	replace case=0 in 30
	replace pop_wpp=(9666) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=11 in 31
	replace case=0 in 31
	replace pop_wpp=(9681) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=13 in 32
	replace case=0 in 32
	replace pop_wpp=(7904) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=14 in 33
	replace case=0 in 33
	replace pop_wpp=(6409) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=16 in 34
	replace case=0 in 34
	replace pop_wpp=(3337) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=17 in 35
	replace case=0 in 35
	replace pop_wpp=(2387) in 35
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
** THIS IS FOR THYROID CANCER (M&F)- STD TO WHO WORLD POPN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   14   286229    4.89      4.01     2.10     6.97     1.19 |
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
gen percent=number/977*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\2018ASIRs_top15_2017" 
replace cancer_site=15 if cancer_site==.
replace year=2 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\2018ASIRs_top15_2017" ,replace
restore


** LARYNX 
tab pop_wpp age5  if siteiarc==20 & sex==1 //female
tab pop_wpp age5  if siteiarc==20 & sex==2 //male

preserve
	drop if age5==.
	keep if siteiarc==20
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings:
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,40-44,45-49,50-54,55-59,60-64,85+
	** F   65-69,70-74,75-79,80-84
	
	expand 2 in 1
	replace sex=1 in 5
	replace age5=1 in 5
	replace case=0 in 5
	replace pop_wpp=(7407) in 5
	sort age5
	
	expand 2 in 1
	replace sex=1 in 6
	replace age5=2 in 6
	replace case=0 in 6
	replace pop_wpp=(8258) in 6
	sort age5
	
	expand 2 in 1
	replace sex=1 in 7
	replace age5=3 in 7
	replace case=0 in 7
	replace pop_wpp=(9079) in 7
	sort age5
	
	expand 2 in 1
	replace sex=1 in 8
	replace age5=4 in 8
	replace case=0 in 8
	replace pop_wpp=(9274) in 8
	sort age5
	
	expand 2 in 1
	replace sex=1 in 9
	replace age5=5 in 9
	replace case=0 in 9
	replace pop_wpp=(9422) in 9
	sort age5
	
	expand 2 in 1
	replace sex=1 in 10
	replace age5=6 in 10
	replace case=0 in 10
	replace pop_wpp=(9191) in 10
	sort age5
	
	expand 2 in 1
	replace sex=1 in 11
	replace age5=7 in 11
	replace case=0 in 11
	replace pop_wpp=(9554) in 11
	sort age5
	
	expand 2 in 1
	replace sex=1 in 12
	replace age5=8 in 12
	replace case=0 in 12
	replace pop_wpp=(9646) in 12
	sort age5
	
	expand 2 in 1
	replace sex=1 in 13
	replace age5=9 in 13
	replace case=0 in 13
	replace pop_wpp=(10261) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=10 in 14
	replace case=0 in 14
	replace pop_wpp=(10436) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=11 in 15
	replace case=0 in 15
	replace pop_wpp=(10815) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=12 in 16
	replace case=0 in 16
	replace pop_wpp=(10749) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=13 in 17
	replace case=0 in 17
	replace pop_wpp=(9132) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=14 in 18
	replace case=0 in 18
	replace pop_wpp=(7328) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=15 in 19
	replace case=0 in 19
	replace pop_wpp=(5645) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=16 in 20
	replace case=0 in 20
	replace pop_wpp=(4402) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=17 in 21
	replace case=0 in 21
	replace pop_wpp=(3327) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=18 in 22
	replace case=0 in 22
	replace pop_wpp=(4080) in 22
	sort age5
	
	expand 2 in 1
	replace sex=2 in 23
	replace age5=1 in 23
	replace case=0 in 23
	replace pop_wpp=(7706) in 23
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 24
	replace age5=2 in 24
	replace case=0 in 24
	replace pop_wpp=(8493) in 24
	sort age5
	
	expand 2 in 1
	replace sex=2 in 25
	replace age5=3 in 25
	replace case=0 in 25
	replace pop_wpp=(9551) in 25
	sort age5
	
	expand 2 in 1
	replace sex=2 in 26
	replace age5=4 in 26
	replace case=0 in 26
	replace pop_wpp=(9717) in 26
	sort age5
	
	expand 2 in 1
	replace sex=2 in 27
	replace age5=5 in 27
	replace case=0 in 27
	replace pop_wpp=(9537) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=6 in 28
	replace case=0 in 28
	replace pop_wpp=(9179) in 28
	sort age5
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=7 in 29
	replace case=0 in 29
	replace pop_wpp=(9216) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=8 in 30
	replace case=0 in 30
	replace pop_wpp=(9261) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=9 in 31
	replace case=0 in 31
	replace pop_wpp=(9663) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=10 in 32
	replace case=0 in 32
	replace pop_wpp=(9666) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=11 in 33
	replace case=0 in 33
	replace pop_wpp=(9681) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=12 in 34
	replace case=0 in 34
	replace pop_wpp=(9322) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=13 in 35
	replace case=0 in 35
	replace pop_wpp=(7904) in 35
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
** THIS IS FOR LARYNGEAL CANCER (M&F)- STD TO WHO WORLD POPN
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |    6   286229    2.10      1.22     0.44     2.95     0.61 |
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
gen percent=number/977*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\2018ASIRs_top15_2017" 
replace cancer_site=16 if cancer_site==.
replace year=2 if year==.
order cancer_site number percent asir ci_lower ci_upper
sort cancer_site number
save "`datapath'\version09\2-working\2018ASIRs_top15_2017" ,replace
restore


** Append this top 15 ASIRs dataset to the 2017 top 10
use "`datapath'\version09\2-working\2018ASIRs_top15_2017" ,clear
append using "`datapath'\version09\2-working\2018ASIRs_2017"
sort cancer_site
replace ci_lower=round(ci_lower,0.1)
replace ci_upper=round(ci_upper,0.1)
format ci_lower %8.1f
format ci_upper %8.1f
gen ci_lower1=string(ci_lower, "%02.1f")
gen ci_upper1=string(ci_upper, "%02.1f")

gen ci_range=ci_lower1+" "+"-"+" "+ci_upper1
replace ci_range = lower(rtrim(ltrim(itrim(ci_range)))) //0 changes
drop ci_lower* ci_upper*
** JC 14sep2022: don't need 'all' sites on table as noted in email from NS on 13sep2022
//expand 2 in 1, gen(dupobs) //need to create this for excel output as 'all' sites was hidden when outputting to excel
//replace cancer_site=0 if dupobs==1
sort cancer_site
drop year //dupobs
save "`datapath'\version09\2-working\ASIRs_top15_2017" ,replace