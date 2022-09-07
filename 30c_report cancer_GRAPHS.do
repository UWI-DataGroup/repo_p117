
cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          30c_report cancer_GRAPHS.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      30-AUG-2022
    // 	date last modified      30-AUG-2022
    //  algorithm task          Creating age + gender stratified IR graphs (discontinued use); 
	//							Creating age + gender stratified/specific IR graphs with 2013-2018 (removed number of cases)
    //  status                  Completed
    //  objective               To have one line + bar graph for each year, 2013-2018 (discontinued use);
	//							To have one line graph for each year, 2013-2018 for 2016-2018 annual report
    //  methods                 See 30a_report cancer_WORD.do for detailed methods of each statistic
	//							See CVD dofiles: p116/version02/3-output OR VS branch 2020AnnualReport/1.1_heart_Cvd_analysis.do

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
    log using "`logpath'/30c_report cancer_GRAPHS.smcl", replace
** HEADER -----------------------------------------------------
/*
	JC 07sep2022: NS commented on 'Cancer_2016-2018AnnualReportStatsV10_20220905.docx' in OneDrive that:
	"We will not use these graphs. I am also phasing them out for CVD becase they commit one of the cardinal errors
	of data display but using two y-axes. Remove the number of cases by sex and age group and leave the line graphs
	that show age specific incidence. September 6, 2022 at 7:37 PM".
*/

**********
** 2018 **
**********
** Load the dataset
use "`datapath'\version09\2-working\2018_cancer_dataset_popn", clear

keep case pop_wpp pfu age5 sex
collapse (sum) case (mean) pop_wpp , by(pfu age5 sex)

** Weighting for incidence calculation IF period is NOT exactly one year
rename pop_wpp fpop_wpp
gen pop_wpp = fpop_wpp * pfu

label var pop_wpp "Barbados population"
gen asir = (case / pop_wpp) * (10^5)
label var asir "Age-stratified Incidence Rate"

* Standard Error
gen se = ( (case^(1/2)) / pop_wpp) * (10^5)

* Lower 95% CI
gen lower = ( (0.5 * invchi2(2*case, (0.05/2))) / pop_wpp ) * (10^5)
replace lower = 0 if asir==0
* Upper 95% CI
gen upper = ( (0.5 * invchi2(2*(case+1), (1-(0.05/2)))) / pop_wpp ) * (10^5)

* Display the results
label var asir "IR"
label var se "SE"
label var lower "95% lo"
label var upper "95% hi"
foreach var in asir se lower upper {
		format `var' %8.2f
		}
sort sex age5
list sex age5 case pop_wpp asir se lower upper , noobs table sum(case pop_wpp)

** New age variable with shifted columns for men
** Shift is one-half the width of the bars (which has been set at 0.5 in graph code)
gen ageg = age5
replace ageg = age5+0.25 if sex==2
label define ageg 1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" /// 
				  8 "35-39" 9 "40-44" 10 "45-49" 11 "50-54" 12 "55-59" 13 "60-64" ///
				  14 "65-69" 15 "70-74" 16 "75-79" 17 "80-84" 18 "85 & over" ,modify
label values ageg ageg
label define age5 1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" /// 
				  8 "35-39" 9 "40-44" 10 "45-49" 11 "50-54" 12 "55-59" 13 "60-64" ///
				  14 "65-69" 15 "70-74" 16 "75-79" 17 "80-84" 18 "85 & over" ,modify
label values age5 age5

#delimit ;
graph twoway 	(line asir age5 if sex==2, yaxis(2) clw(thick) clc(black) clp("-") cmiss(y))
				(line asir age5 if sex==1, yaxis(2) clw(thick) clc(red) clp("-") cmiss(y))
				,
			/// Making background completely white
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			/// and insist on a long thin graphic
			ysize(2)
			
	       	xlabel(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18, valuelabel
	       	labs(large) nogrid glc(gs12) angle(45))
	       	xtitle("Age-group (years)", size(large) margin(t=3)) 
			xscale(range(1(1)10))
			xmtick(1(1)10)

	       	/// axis1 = LSH y-axis
			/// axis2 = RHS y-axis
			ylab(0(500)2000, axis(2) labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
	       	ytitle("Incidence per 100,000 population", axis(2) size(large) margin(l=3))
			ymtick(0(250)2200, axis(2))
			
			/// Legend information
			legend(size(medlarge) nobox position(11) colf cols(2)
			region(color(gs16) ic(gs16) ilw(thin) lw(thin)) order(1 2)
			lab(1 "Incidence per 100,000 (men)") 
			lab(2 "Incidence per 100,000 (women)")
			);
#delimit cr
graph export "`datapath'\version09\3-output\2018_age-sex graph_nocases_cancer.png" ,replace

**********
** 2017 **
**********
** Load the dataset
use "`datapath'\version09\2-working\2017_cancer_dataset_popn", clear

keep case pop_wpp pfu age5 sex
collapse (sum) case (mean) pop_wpp , by(pfu age5 sex)

** Weighting for incidence calculation IF period is NOT exactly one year
rename pop_wpp fpop_wpp
gen pop_wpp = fpop_wpp * pfu

label var pop_wpp "Barbados population"
gen asir = (case / pop_wpp) * (10^5)
label var asir "Age-stratified Incidence Rate"

* Standard Error
gen se = ( (case^(1/2)) / pop_wpp) * (10^5)

* Lower 95% CI
gen lower = ( (0.5 * invchi2(2*case, (0.05/2))) / pop_wpp ) * (10^5)
replace lower = 0 if asir==0
* Upper 95% CI
gen upper = ( (0.5 * invchi2(2*(case+1), (1-(0.05/2)))) / pop_wpp ) * (10^5)

* Display the results
label var asir "IR"
label var se "SE"
label var lower "95% lo"
label var upper "95% hi"
foreach var in asir se lower upper {
		format `var' %8.2f
		}
sort sex age5
list sex age5 case pop_wpp asir se lower upper , noobs table sum(case pop_wpp)

** New age variable with shifted columns for men
** Shift is one-half the width of the bars (which has been set at 0.5 in graph code)
gen ageg = age5
replace ageg = age5+0.25 if sex==2
label define ageg 1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" /// 
				  8 "35-39" 9 "40-44" 10 "45-49" 11 "50-54" 12 "55-59" 13 "60-64" ///
				  14 "65-69" 15 "70-74" 16 "75-79" 17 "80-84" 18 "85 & over" ,modify
label values ageg ageg
label define age5 1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" /// 
				  8 "35-39" 9 "40-44" 10 "45-49" 11 "50-54" 12 "55-59" 13 "60-64" ///
				  14 "65-69" 15 "70-74" 16 "75-79" 17 "80-84" 18 "85 & over" ,modify
label values age5 age5

#delimit ;
graph twoway 	(line asir age5 if sex==2, yaxis(2) clw(thick) clc(black) clp("-") cmiss(y))
				(line asir age5 if sex==1, yaxis(2) clw(thick) clc(red) clp("-") cmiss(y))
				,
			/// Making background completely white
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			/// and insist on a long thin graphic
			ysize(2)
			
	       	xlabel(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18, valuelabel
	       	labs(large) nogrid glc(gs12) angle(45))
	       	xtitle("Age-group (years)", size(large) margin(t=3)) 
			xscale(range(1(1)10))
			xmtick(1(1)10)

	       	/// axis1 = LSH y-axis
			/// axis2 = RHS y-axis
			ylab(0(500)2000, axis(2) labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
	       	ytitle("Incidence per 100,000 population", axis(2) size(large) margin(l=3))
			ymtick(0(250)2200, axis(2))
			
			/// Legend information
			legend(size(medlarge) nobox position(11) colf cols(2)
			region(color(gs16) ic(gs16) ilw(thin) lw(thin)) order(1 2)
			lab(1 "Incidence per 100,000 (men)") 
			lab(2 "Incidence per 100,000 (women)")
			);
#delimit cr
graph export "`datapath'\version09\3-output\2017_age-sex graph_nocases_cancer.png" ,replace

**********
** 2016 **
**********
** Load the dataset
use "`datapath'\version09\2-working\2016_cancer_dataset_popn", clear

keep case pop_wpp pfu age5 sex
collapse (sum) case (mean) pop_wpp , by(pfu age5 sex)

** Weighting for incidence calculation IF period is NOT exactly one year
rename pop_wpp fpop_wpp
gen pop_wpp = fpop_wpp * pfu

label var pop_wpp "Barbados population"
gen asir = (case / pop_wpp) * (10^5)
label var asir "Age-stratified Incidence Rate"

* Standard Error
gen se = ( (case^(1/2)) / pop_wpp) * (10^5)

* Lower 95% CI
gen lower = ( (0.5 * invchi2(2*case, (0.05/2))) / pop_wpp ) * (10^5)
replace lower = 0 if asir==0
* Upper 95% CI
gen upper = ( (0.5 * invchi2(2*(case+1), (1-(0.05/2)))) / pop_wpp ) * (10^5)

* Display the results
label var asir "IR"
label var se "SE"
label var lower "95% lo"
label var upper "95% hi"
foreach var in asir se lower upper {
		format `var' %8.2f
		}
sort sex age5
list sex age5 case pop_wpp asir se lower upper , noobs table sum(case pop_wpp)

** New age variable with shifted columns for men
** Shift is one-half the width of the bars (which has been set at 0.5 in graph code)
gen ageg = age5
replace ageg = age5+0.25 if sex==2
label define ageg 1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" /// 
				  8 "35-39" 9 "40-44" 10 "45-49" 11 "50-54" 12 "55-59" 13 "60-64" ///
				  14 "65-69" 15 "70-74" 16 "75-79" 17 "80-84" 18 "85 & over" ,modify
label values ageg ageg
label define age5 1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" /// 
				  8 "35-39" 9 "40-44" 10 "45-49" 11 "50-54" 12 "55-59" 13 "60-64" ///
				  14 "65-69" 15 "70-74" 16 "75-79" 17 "80-84" 18 "85 & over" ,modify
label values age5 age5

#delimit ;
graph twoway 	(line asir age5 if sex==2, yaxis(2) clw(thick) clc(black) clp("-") cmiss(y))
				(line asir age5 if sex==1, yaxis(2) clw(thick) clc(red) clp("-") cmiss(y))
				,
			/// Making background completely white
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			/// and insist on a long thin graphic
			ysize(2)
			
	       	xlabel(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18, valuelabel
	       	labs(large) nogrid glc(gs12) angle(45))
	       	xtitle("Age-group (years)", size(large) margin(t=3)) 
			xscale(range(1(1)10))
			xmtick(1(1)10)

	       	/// axis1 = LSH y-axis
			/// axis2 = RHS y-axis
			ylab(0(500)2000, axis(2) labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
	       	ytitle("Incidence per 100,000 population", axis(2) size(large) margin(l=3))
			ymtick(0(250)2200, axis(2))
			
			/// Legend information
			legend(size(medlarge) nobox position(11) colf cols(2)
			region(color(gs16) ic(gs16) ilw(thin) lw(thin)) order(1 2)
			lab(1 "Incidence per 100,000 (men)") 
			lab(2 "Incidence per 100,000 (women)")
			);
#delimit cr
graph export "`datapath'\version09\3-output\2016_age-sex graph_nocases_cancer.png" ,replace

**********
** 2015 **
**********
** Load the dataset
use "`datapath'\version09\2-working\2015_cancer_dataset_popn", clear

keep case pop_wpp pfu age5 sex
collapse (sum) case (mean) pop_wpp , by(pfu age5 sex)

** Weighting for incidence calculation IF period is NOT exactly one year
rename pop_wpp fpop_wpp
gen pop_wpp = fpop_wpp * pfu

label var pop_wpp "Barbados population"
gen asir = (case / pop_wpp) * (10^5)
label var asir "Age-stratified Incidence Rate"

* Standard Error
gen se = ( (case^(1/2)) / pop_wpp) * (10^5)

* Lower 95% CI
gen lower = ( (0.5 * invchi2(2*case, (0.05/2))) / pop_wpp ) * (10^5)
replace lower = 0 if asir==0
* Upper 95% CI
gen upper = ( (0.5 * invchi2(2*(case+1), (1-(0.05/2)))) / pop_wpp ) * (10^5)

* Display the results
label var asir "IR"
label var se "SE"
label var lower "95% lo"
label var upper "95% hi"
foreach var in asir se lower upper {
		format `var' %8.2f
		}
sort sex age5
list sex age5 case pop_wpp asir se lower upper , noobs table sum(case pop_wpp)

** New age variable with shifted columns for men
** Shift is one-half the width of the bars (which has been set at 0.5 in graph code)
gen ageg = age5
replace ageg = age5+0.25 if sex==2
label define ageg 1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" /// 
				  8 "35-39" 9 "40-44" 10 "45-49" 11 "50-54" 12 "55-59" 13 "60-64" ///
				  14 "65-69" 15 "70-74" 16 "75-79" 17 "80-84" 18 "85 & over" ,modify
label values ageg ageg
label define age5 1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" /// 
				  8 "35-39" 9 "40-44" 10 "45-49" 11 "50-54" 12 "55-59" 13 "60-64" ///
				  14 "65-69" 15 "70-74" 16 "75-79" 17 "80-84" 18 "85 & over" ,modify
label values age5 age5

#delimit ;
graph twoway 	(line asir age5 if sex==2, yaxis(2) clw(thick) clc(black) clp("-") cmiss(y))
				(line asir age5 if sex==1, yaxis(2) clw(thick) clc(red) clp("-") cmiss(y))
				,
			/// Making background completely white
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			/// and insist on a long thin graphic
			ysize(2)
			
	       	xlabel(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18, valuelabel
	       	labs(large) nogrid glc(gs12) angle(45))
	       	xtitle("Age-group (years)", size(large) margin(t=3)) 
			xscale(range(1(1)10))
			xmtick(1(1)10)

	       	/// axis1 = LSH y-axis
			/// axis2 = RHS y-axis
			ylab(0(500)2000, axis(2) labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
	       	ytitle("Incidence per 100,000 population", axis(2) size(large) margin(l=3))
			ymtick(0(250)2200, axis(2))
			
			/// Legend information
			legend(size(medlarge) nobox position(11) colf cols(2)
			region(color(gs16) ic(gs16) ilw(thin) lw(thin)) order(1 2)
			lab(1 "Incidence per 100,000 (men)") 
			lab(2 "Incidence per 100,000 (women)")
			);
#delimit cr
graph export "`datapath'\version09\3-output\2015_age-sex graph_nocases_cancer.png" ,replace

**********
** 2014 **
**********
** Load the dataset
use "`datapath'\version09\2-working\2014_cancer_dataset_popn", clear

keep case pop_wpp pfu age5 sex
collapse (sum) case (mean) pop_wpp , by(pfu age5 sex)

** Weighting for incidence calculation IF period is NOT exactly one year
rename pop_wpp fpop_wpp
gen pop_wpp = fpop_wpp * pfu

label var pop_wpp "Barbados population"
gen asir = (case / pop_wpp) * (10^5)
label var asir "Age-stratified Incidence Rate"

* Standard Error
gen se = ( (case^(1/2)) / pop_wpp) * (10^5)

* Lower 95% CI
gen lower = ( (0.5 * invchi2(2*case, (0.05/2))) / pop_wpp ) * (10^5)
replace lower = 0 if asir==0
* Upper 95% CI
gen upper = ( (0.5 * invchi2(2*(case+1), (1-(0.05/2)))) / pop_wpp ) * (10^5)

* Display the results
label var asir "IR"
label var se "SE"
label var lower "95% lo"
label var upper "95% hi"
foreach var in asir se lower upper {
		format `var' %8.2f
		}
sort sex age5
list sex age5 case pop_wpp asir se lower upper , noobs table sum(case pop_wpp)

** New age variable with shifted columns for men
** Shift is one-half the width of the bars (which has been set at 0.5 in graph code)
gen ageg = age5
replace ageg = age5+0.25 if sex==2
label define ageg 1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" /// 
				  8 "35-39" 9 "40-44" 10 "45-49" 11 "50-54" 12 "55-59" 13 "60-64" ///
				  14 "65-69" 15 "70-74" 16 "75-79" 17 "80-84" 18 "85 & over" ,modify
label values ageg ageg
label define age5 1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" /// 
				  8 "35-39" 9 "40-44" 10 "45-49" 11 "50-54" 12 "55-59" 13 "60-64" ///
				  14 "65-69" 15 "70-74" 16 "75-79" 17 "80-84" 18 "85 & over" ,modify
label values age5 age5

#delimit ;
graph twoway 	(line asir age5 if sex==2, yaxis(2) clw(thick) clc(black) clp("-") cmiss(y))
				(line asir age5 if sex==1, yaxis(2) clw(thick) clc(red) clp("-") cmiss(y))
				,
			/// Making background completely white
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			/// and insist on a long thin graphic
			ysize(2)
			
	       	xlabel(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18, valuelabel
	       	labs(large) nogrid glc(gs12) angle(45))
	       	xtitle("Age-group (years)", size(large) margin(t=3)) 
			xscale(range(1(1)10))
			xmtick(1(1)10)

	       	/// axis1 = LSH y-axis
			/// axis2 = RHS y-axis
			ylab(0(500)2000, axis(2) labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
	       	ytitle("Incidence per 100,000 population", axis(2) size(large) margin(l=3))
			ymtick(0(250)2200, axis(2))
			
			/// Legend information
			legend(size(medlarge) nobox position(11) colf cols(2)
			region(color(gs16) ic(gs16) ilw(thin) lw(thin)) order(1 2)
			lab(1 "Incidence per 100,000 (men)") 
			lab(2 "Incidence per 100,000 (women)")
			);
#delimit cr
graph export "`datapath'\version09\3-output\2014_age-sex graph_nocases_cancer.png" ,replace

**********
** 2013 **
**********
** Load the dataset
use "`datapath'\version09\2-working\2013_cancer_dataset_popn", clear

keep case pop_wpp pfu age5 sex
collapse (sum) case (mean) pop_wpp , by(pfu age5 sex)

** Weighting for incidence calculation IF period is NOT exactly one year
rename pop_wpp fpop_wpp
gen pop_wpp = fpop_wpp * pfu

label var pop_wpp "Barbados population"
gen asir = (case / pop_wpp) * (10^5)
label var asir "Age-stratified Incidence Rate"

* Standard Error
gen se = ( (case^(1/2)) / pop_wpp) * (10^5)

* Lower 95% CI
gen lower = ( (0.5 * invchi2(2*case, (0.05/2))) / pop_wpp ) * (10^5)
replace lower = 0 if asir==0
* Upper 95% CI
gen upper = ( (0.5 * invchi2(2*(case+1), (1-(0.05/2)))) / pop_wpp ) * (10^5)

* Display the results
label var asir "IR"
label var se "SE"
label var lower "95% lo"
label var upper "95% hi"
foreach var in asir se lower upper {
		format `var' %8.2f
		}
sort sex age5
list sex age5 case pop_wpp asir se lower upper , noobs table sum(case pop_wpp)

** New age variable with shifted columns for men
** Shift is one-half the width of the bars (which has been set at 0.5 in graph code)
gen ageg = age5
replace ageg = age5+0.25 if sex==2
label define ageg 1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" /// 
				  8 "35-39" 9 "40-44" 10 "45-49" 11 "50-54" 12 "55-59" 13 "60-64" ///
				  14 "65-69" 15 "70-74" 16 "75-79" 17 "80-84" 18 "85 & over" ,modify
label values ageg ageg
label define age5 1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" /// 
				  8 "35-39" 9 "40-44" 10 "45-49" 11 "50-54" 12 "55-59" 13 "60-64" ///
				  14 "65-69" 15 "70-74" 16 "75-79" 17 "80-84" 18 "85 & over" ,modify
label values age5 age5

#delimit ;
graph twoway 	(line asir age5 if sex==2, yaxis(2) clw(thick) clc(black) clp("-") cmiss(y))
				(line asir age5 if sex==1, yaxis(2) clw(thick) clc(red) clp("-") cmiss(y))
				,
			/// Making background completely white
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			/// and insist on a long thin graphic
			ysize(2)
			
	       	xlabel(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18, valuelabel
	       	labs(large) nogrid glc(gs12) angle(45))
	       	xtitle("Age-group (years)", size(large) margin(t=3)) 
			xscale(range(1(1)10))
			xmtick(1(1)10)

	       	/// axis1 = LSH y-axis
			/// axis2 = RHS y-axis
			ylab(0(500)2000, axis(2) labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
	       	ytitle("Incidence per 100,000 population", axis(2) size(large) margin(l=3))
			ymtick(0(250)2200, axis(2))
			
			/// Legend information
			legend(size(medlarge) nobox position(11) colf cols(2)
			region(color(gs16) ic(gs16) ilw(thin) lw(thin)) order(1 2)
			lab(1 "Incidence per 100,000 (men)") 
			lab(2 "Incidence per 100,000 (women)")
			);
#delimit cr
graph export "`datapath'\version09\3-output\2013_age-sex graph_nocases_cancer.png" ,replace


/*
**********
** 2018 **
**********
** Load the dataset
use "`datapath'\version09\2-working\2018_cancer_dataset_popn", clear

keep case pop_wpp pfu age5 sex
collapse (sum) case (mean) pop_wpp , by(pfu age5 sex)

** Weighting for incidence calculation IF period is NOT exactly one year
rename pop_wpp fpop_wpp
gen pop_wpp = fpop_wpp * pfu

label var pop_wpp "Barbados population"
gen asir = (case / pop_wpp) * (10^5)
label var asir "Age-stratified Incidence Rate"

* Standard Error
gen se = ( (case^(1/2)) / pop_wpp) * (10^5)

* Lower 95% CI
gen lower = ( (0.5 * invchi2(2*case, (0.05/2))) / pop_wpp ) * (10^5)
replace lower = 0 if asir==0
* Upper 95% CI
gen upper = ( (0.5 * invchi2(2*(case+1), (1-(0.05/2)))) / pop_wpp ) * (10^5)

* Display the results
label var asir "IR"
label var se "SE"
label var lower "95% lo"
label var upper "95% hi"
foreach var in asir se lower upper {
		format `var' %8.2f
		}
sort sex age5
list sex age5 case pop_wpp asir se lower upper , noobs table sum(case pop_wpp)

** New age variable with shifted columns for men
** Shift is one-half the width of the bars (which has been set at 0.5 in graph code)
gen ageg = age5
replace ageg = age5+0.25 if sex==2
label define ageg 1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" /// 
				  8 "35-39" 9 "40-44" 10 "45-49" 11 "50-54" 12 "55-59" 13 "60-64" ///
				  14 "65-69" 15 "70-74" 16 "75-79" 17 "80-84" 18 "85 & over" ,modify
label values ageg ageg
label define age5 1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" /// 
				  8 "35-39" 9 "40-44" 10 "45-49" 11 "50-54" 12 "55-59" 13 "60-64" ///
				  14 "65-69" 15 "70-74" 16 "75-79" 17 "80-84" 18 "85 & over" ,modify
label values age5 age5

#delimit ;
graph twoway 	(bar case ageg if sex==2, yaxis(1) col(blue*1.5) barw(0.5) )
				(bar case ageg if sex==1, yaxis(1) col(orange)  barw(0.5) )
				(line asir age5 if sex==2, yaxis(2) clw(thick) clc(black) clp("-") cmiss(y))
				(line asir age5 if sex==1, yaxis(2) clw(thick) clc(red) clp("-") cmiss(y))
				,
			/// Making background completely white
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			/// and insist on a long thin graphic
			ysize(2)
			
	       	xlabel(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18, valuelabel
	       	labs(large) nogrid glc(gs12) angle(45))
	       	xtitle("Age-group (years)", size(large) margin(t=3)) 
			xscale(range(1(1)10))
			xmtick(1(1)10)

	       	/// axis1 = LSH y-axis
			/// axis2 = RHS y-axis
			ylab(0(10)80, axis(1) labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
	       	ytitle("Number of cases", axis(1) size(large) margin(r=3)) 
			ymtick(0(5)65)
			
	       	ylab(0(500)2000, axis(2) labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
	       	ytitle("Incidence per 100,000 population", axis(2) size(large) margin(l=3))
			ymtick(0(250)2200, axis(2))
			
			/// Legend information
			legend(size(medlarge) nobox position(11) colf cols(2)
			region(color(gs16) ic(gs16) ilw(thin) lw(thin)) order(1 2 3 4)
			lab(1 "Number of cases (men)") 
			lab(2 "Number of cases (women)")
			lab(3 "Incidence per 100,000 (men)") 
			lab(4 "Incidence per 100,000 (women)")
			);
#delimit cr
graph export "`datapath'\version09\3-output\2018_age-sex graph_cancer.png" ,replace


**********
** 2017 **
**********
** Load the dataset
use "`datapath'\version09\2-working\2017_cancer_dataset_popn", clear

keep case pop_wpp pfu age5 sex
collapse (sum) case (mean) pop_wpp , by(pfu age5 sex)

** Weighting for incidence calculation IF period is NOT exactly one year
rename pop_wpp fpop_wpp
gen pop_wpp = fpop_wpp * pfu

label var pop_wpp "Barbados population"
gen asir = (case / pop_wpp) * (10^5)
label var asir "Age-stratified Incidence Rate"

* Standard Error
gen se = ( (case^(1/2)) / pop_wpp) * (10^5)

* Lower 95% CI
gen lower = ( (0.5 * invchi2(2*case, (0.05/2))) / pop_wpp ) * (10^5)
replace lower = 0 if asir==0
* Upper 95% CI
gen upper = ( (0.5 * invchi2(2*(case+1), (1-(0.05/2)))) / pop_wpp ) * (10^5)

* Display the results
label var asir "IR"
label var se "SE"
label var lower "95% lo"
label var upper "95% hi"
foreach var in asir se lower upper {
		format `var' %8.2f
		}
sort sex age5
list sex age5 case pop_wpp asir se lower upper , noobs table sum(case pop_wpp)

** New age variable with shifted columns for men
** Shift is one-half the width of the bars (which has been set at 0.5 in graph code)
gen ageg = age5
replace ageg = age5+0.25 if sex==2
label define ageg 1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" /// 
				  8 "35-39" 9 "40-44" 10 "45-49" 11 "50-54" 12 "55-59" 13 "60-64" ///
				  14 "65-69" 15 "70-74" 16 "75-79" 17 "80-84" 18 "85 & over" ,modify
label values ageg ageg
label define age5 1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" /// 
				  8 "35-39" 9 "40-44" 10 "45-49" 11 "50-54" 12 "55-59" 13 "60-64" ///
				  14 "65-69" 15 "70-74" 16 "75-79" 17 "80-84" 18 "85 & over" ,modify
label values age5 age5

#delimit ;
graph twoway 	(bar case ageg if sex==2, yaxis(1) col(blue*1.5) barw(0.5) )
				(bar case ageg if sex==1, yaxis(1) col(orange)  barw(0.5) )
				(line asir age5 if sex==2, yaxis(2) clw(thick) clc(black) clp("-") cmiss(y))
				(line asir age5 if sex==1, yaxis(2) clw(thick) clc(red) clp("-") cmiss(y))
				,
			/// Making background completely white
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			/// and insist on a long thin graphic
			ysize(2)
			
	       	xlabel(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18, valuelabel
	       	labs(large) nogrid glc(gs12) angle(45))
	       	xtitle("Age-group (years)", size(large) margin(t=3)) 
			xscale(range(1(1)10))
			xmtick(1(1)10)

	       	/// axis1 = LSH y-axis
			/// axis2 = RHS y-axis
			ylab(0(10)80, axis(1) labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
	       	ytitle("Number of cases", axis(1) size(large) margin(r=3)) 
			ymtick(0(5)65)
			
	       	ylab(0(500)2000, axis(2) labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
	       	ytitle("Incidence per 100,000 population", axis(2) size(large) margin(l=3))
			ymtick(0(250)2200, axis(2))
			
			/// Legend information
			legend(size(medlarge) nobox position(11) colf cols(2)
			region(color(gs16) ic(gs16) ilw(thin) lw(thin)) order(1 2 3 4)
			lab(1 "Number of cases (men)") 
			lab(2 "Number of cases (women)")
			lab(3 "Incidence per 100,000 (men)") 
			lab(4 "Incidence per 100,000 (women)")
			);
#delimit cr
graph export "`datapath'\version09\3-output\2017_age-sex graph_cancer.png" ,replace


**********
** 2016 **
**********
** Load the dataset
use "`datapath'\version09\2-working\2016_cancer_dataset_popn", clear

keep case pop_wpp pfu age5 sex
collapse (sum) case (mean) pop_wpp , by(pfu age5 sex)

** Weighting for incidence calculation IF period is NOT exactly one year
rename pop_wpp fpop_wpp
gen pop_wpp = fpop_wpp * pfu

label var pop_wpp "Barbados population"
gen asir = (case / pop_wpp) * (10^5)
label var asir "Age-stratified Incidence Rate"

* Standard Error
gen se = ( (case^(1/2)) / pop_wpp) * (10^5)

* Lower 95% CI
gen lower = ( (0.5 * invchi2(2*case, (0.05/2))) / pop_wpp ) * (10^5)
replace lower = 0 if asir==0
* Upper 95% CI
gen upper = ( (0.5 * invchi2(2*(case+1), (1-(0.05/2)))) / pop_wpp ) * (10^5)

* Display the results
label var asir "IR"
label var se "SE"
label var lower "95% lo"
label var upper "95% hi"
foreach var in asir se lower upper {
		format `var' %8.2f
		}
sort sex age5
list sex age5 case pop_wpp asir se lower upper , noobs table sum(case pop_wpp)

** New age variable with shifted columns for men
** Shift is one-half the width of the bars (which has been set at 0.5 in graph code)
gen ageg = age5
replace ageg = age5+0.25 if sex==2
label define ageg 1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" /// 
				  8 "35-39" 9 "40-44" 10 "45-49" 11 "50-54" 12 "55-59" 13 "60-64" ///
				  14 "65-69" 15 "70-74" 16 "75-79" 17 "80-84" 18 "85 & over" ,modify
label values ageg ageg
label define age5 1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" /// 
				  8 "35-39" 9 "40-44" 10 "45-49" 11 "50-54" 12 "55-59" 13 "60-64" ///
				  14 "65-69" 15 "70-74" 16 "75-79" 17 "80-84" 18 "85 & over" ,modify
label values age5 age5

#delimit ;
graph twoway 	(bar case ageg if sex==2, yaxis(1) col(blue*1.5) barw(0.5) )
				(bar case ageg if sex==1, yaxis(1) col(orange)  barw(0.5) )
				(line asir age5 if sex==2, yaxis(2) clw(thick) clc(black) clp("-") cmiss(y))
				(line asir age5 if sex==1, yaxis(2) clw(thick) clc(red) clp("-") cmiss(y))
				,
			/// Making background completely white
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			/// and insist on a long thin graphic
			ysize(2)
			
	       	xlabel(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18, valuelabel
	       	labs(large) nogrid glc(gs12) angle(45))
	       	xtitle("Age-group (years)", size(large) margin(t=3)) 
			xscale(range(1(1)10))
			xmtick(1(1)10)

	       	/// axis1 = LSH y-axis
			/// axis2 = RHS y-axis
			ylab(0(10)80, axis(1) labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
	       	ytitle("Number of cases", axis(1) size(large) margin(r=3)) 
			ymtick(0(5)65)
			
	       	ylab(0(500)2000, axis(2) labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
	       	ytitle("Incidence per 100,000 population", axis(2) size(large) margin(l=3))
			ymtick(0(250)2200, axis(2))
			
			/// Legend information
			legend(size(medlarge) nobox position(11) colf cols(2)
			region(color(gs16) ic(gs16) ilw(thin) lw(thin)) order(1 2 3 4)
			lab(1 "Number of cases (men)") 
			lab(2 "Number of cases (women)")
			lab(3 "Incidence per 100,000 (men)") 
			lab(4 "Incidence per 100,000 (women)")
			);
#delimit cr
graph export "`datapath'\version09\3-output\2016_age-sex graph_cancer.png" ,replace


**********
** 2015 **
**********
** Load the dataset
use "`datapath'\version09\2-working\2015_cancer_dataset_popn", clear

keep case pop_wpp pfu age5 sex
collapse (sum) case (mean) pop_wpp , by(pfu age5 sex)

** Weighting for incidence calculation IF period is NOT exactly one year
rename pop_wpp fpop_wpp
gen pop_wpp = fpop_wpp * pfu

label var pop_wpp "Barbados population"
gen asir = (case / pop_wpp) * (10^5)
label var asir "Age-stratified Incidence Rate"

* Standard Error
gen se = ( (case^(1/2)) / pop_wpp) * (10^5)

* Lower 95% CI
gen lower = ( (0.5 * invchi2(2*case, (0.05/2))) / pop_wpp ) * (10^5)
replace lower = 0 if asir==0
* Upper 95% CI
gen upper = ( (0.5 * invchi2(2*(case+1), (1-(0.05/2)))) / pop_wpp ) * (10^5)

* Display the results
label var asir "IR"
label var se "SE"
label var lower "95% lo"
label var upper "95% hi"
foreach var in asir se lower upper {
		format `var' %8.2f
		}
sort sex age5
list sex age5 case pop_wpp asir se lower upper , noobs table sum(case pop_wpp)

** New age variable with shifted columns for men
** Shift is one-half the width of the bars (which has been set at 0.5 in graph code)
gen ageg = age5
replace ageg = age5+0.25 if sex==2
label define ageg 1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" /// 
				  8 "35-39" 9 "40-44" 10 "45-49" 11 "50-54" 12 "55-59" 13 "60-64" ///
				  14 "65-69" 15 "70-74" 16 "75-79" 17 "80-84" 18 "85 & over" ,modify
label values ageg ageg
label define age5 1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" /// 
				  8 "35-39" 9 "40-44" 10 "45-49" 11 "50-54" 12 "55-59" 13 "60-64" ///
				  14 "65-69" 15 "70-74" 16 "75-79" 17 "80-84" 18 "85 & over" ,modify
label values age5 age5

#delimit ;
graph twoway 	(bar case ageg if sex==2, yaxis(1) col(blue*1.5) barw(0.5) )
				(bar case ageg if sex==1, yaxis(1) col(orange)  barw(0.5) )
				(line asir age5 if sex==2, yaxis(2) clw(thick) clc(black) clp("-") cmiss(y))
				(line asir age5 if sex==1, yaxis(2) clw(thick) clc(red) clp("-") cmiss(y))
				,
			/// Making background completely white
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			/// and insist on a long thin graphic
			ysize(2)
			
	       	xlabel(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18, valuelabel
	       	labs(large) nogrid glc(gs12) angle(45))
	       	xtitle("Age-group (years)", size(large) margin(t=3)) 
			xscale(range(1(1)10))
			xmtick(1(1)10)

	       	/// axis1 = LSH y-axis
			/// axis2 = RHS y-axis
			ylab(0(10)80, axis(1) labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
	       	ytitle("Number of cases", axis(1) size(large) margin(r=3)) 
			ymtick(0(5)65)
			
	       	ylab(0(500)2000, axis(2) labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
	       	ytitle("Incidence per 100,000 population", axis(2) size(large) margin(l=3))
			ymtick(0(250)2200, axis(2))
			
			/// Legend information
			legend(size(medlarge) nobox position(11) colf cols(2)
			region(color(gs16) ic(gs16) ilw(thin) lw(thin)) order(1 2 3 4)
			lab(1 "Number of cases (men)") 
			lab(2 "Number of cases (women)")
			lab(3 "Incidence per 100,000 (men)") 
			lab(4 "Incidence per 100,000 (women)")
			);
#delimit cr
graph export "`datapath'\version09\3-output\2015_age-sex graph_cancer.png" ,replace


**********
** 2014 **
**********
** Load the dataset
use "`datapath'\version09\2-working\2014_cancer_dataset_popn", clear

keep case pop_wpp pfu age5 sex
collapse (sum) case (mean) pop_wpp , by(pfu age5 sex)

** Weighting for incidence calculation IF period is NOT exactly one year
rename pop_wpp fpop_wpp
gen pop_wpp = fpop_wpp * pfu

label var pop_wpp "Barbados population"
gen asir = (case / pop_wpp) * (10^5)
label var asir "Age-stratified Incidence Rate"

* Standard Error
gen se = ( (case^(1/2)) / pop_wpp) * (10^5)

* Lower 95% CI
gen lower = ( (0.5 * invchi2(2*case, (0.05/2))) / pop_wpp ) * (10^5)
replace lower = 0 if asir==0
* Upper 95% CI
gen upper = ( (0.5 * invchi2(2*(case+1), (1-(0.05/2)))) / pop_wpp ) * (10^5)

* Display the results
label var asir "IR"
label var se "SE"
label var lower "95% lo"
label var upper "95% hi"
foreach var in asir se lower upper {
		format `var' %8.2f
		}
sort sex age5
list sex age5 case pop_wpp asir se lower upper , noobs table sum(case pop_wpp)

** New age variable with shifted columns for men
** Shift is one-half the width of the bars (which has been set at 0.5 in graph code)
gen ageg = age5
replace ageg = age5+0.25 if sex==2
label define ageg 1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" /// 
				  8 "35-39" 9 "40-44" 10 "45-49" 11 "50-54" 12 "55-59" 13 "60-64" ///
				  14 "65-69" 15 "70-74" 16 "75-79" 17 "80-84" 18 "85 & over" ,modify
label values ageg ageg
label define age5 1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" /// 
				  8 "35-39" 9 "40-44" 10 "45-49" 11 "50-54" 12 "55-59" 13 "60-64" ///
				  14 "65-69" 15 "70-74" 16 "75-79" 17 "80-84" 18 "85 & over" ,modify
label values age5 age5

#delimit ;
graph twoway 	(bar case ageg if sex==2, yaxis(1) col(blue*1.5) barw(0.5) )
				(bar case ageg if sex==1, yaxis(1) col(orange)  barw(0.5) )
				(line asir age5 if sex==2, yaxis(2) clw(thick) clc(black) clp("-") cmiss(y))
				(line asir age5 if sex==1, yaxis(2) clw(thick) clc(red) clp("-") cmiss(y))
				,
			/// Making background completely white
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			/// and insist on a long thin graphic
			ysize(2)
			
	       	xlabel(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18, valuelabel
	       	labs(large) nogrid glc(gs12) angle(45))
	       	xtitle("Age-group (years)", size(large) margin(t=3)) 
			xscale(range(1(1)10))
			xmtick(1(1)10)

	       	/// axis1 = LSH y-axis
			/// axis2 = RHS y-axis
			ylab(0(10)80, axis(1) labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
	       	ytitle("Number of cases", axis(1) size(large) margin(r=3)) 
			ymtick(0(5)65)
			
	       	ylab(0(500)2000, axis(2) labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
	       	ytitle("Incidence per 100,000 population", axis(2) size(large) margin(l=3))
			ymtick(0(250)2200, axis(2))
			
			/// Legend information
			legend(size(medlarge) nobox position(11) colf cols(2)
			region(color(gs16) ic(gs16) ilw(thin) lw(thin)) order(1 2 3 4)
			lab(1 "Number of cases (men)") 
			lab(2 "Number of cases (women)")
			lab(3 "Incidence per 100,000 (men)") 
			lab(4 "Incidence per 100,000 (women)")
			);
#delimit cr
graph export "`datapath'\version09\3-output\2014_age-sex graph_cancer.png" ,replace


**********
** 2013 **
**********
** Load the dataset
use "`datapath'\version09\2-working\2013_cancer_dataset_popn", clear

keep case pop_wpp pfu age5 sex
collapse (sum) case (mean) pop_wpp , by(pfu age5 sex)

** Weighting for incidence calculation IF period is NOT exactly one year
rename pop_wpp fpop_wpp
gen pop_wpp = fpop_wpp * pfu

label var pop_wpp "Barbados population"
gen asir = (case / pop_wpp) * (10^5)
label var asir "Age-stratified Incidence Rate"

* Standard Error
gen se = ( (case^(1/2)) / pop_wpp) * (10^5)

* Lower 95% CI
gen lower = ( (0.5 * invchi2(2*case, (0.05/2))) / pop_wpp ) * (10^5)
replace lower = 0 if asir==0
* Upper 95% CI
gen upper = ( (0.5 * invchi2(2*(case+1), (1-(0.05/2)))) / pop_wpp ) * (10^5)

* Display the results
label var asir "IR"
label var se "SE"
label var lower "95% lo"
label var upper "95% hi"
foreach var in asir se lower upper {
		format `var' %8.2f
		}
sort sex age5
list sex age5 case pop_wpp asir se lower upper , noobs table sum(case pop_wpp)

** New age variable with shifted columns for men
** Shift is one-half the width of the bars (which has been set at 0.5 in graph code)
gen ageg = age5
replace ageg = age5+0.25 if sex==2
label define ageg 1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" /// 
				  8 "35-39" 9 "40-44" 10 "45-49" 11 "50-54" 12 "55-59" 13 "60-64" ///
				  14 "65-69" 15 "70-74" 16 "75-79" 17 "80-84" 18 "85 & over" ,modify
label values ageg ageg
label define age5 1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" /// 
				  8 "35-39" 9 "40-44" 10 "45-49" 11 "50-54" 12 "55-59" 13 "60-64" ///
				  14 "65-69" 15 "70-74" 16 "75-79" 17 "80-84" 18 "85 & over" ,modify
label values age5 age5

#delimit ;
graph twoway 	(bar case ageg if sex==2, yaxis(1) col(blue*1.5) barw(0.5) )
				(bar case ageg if sex==1, yaxis(1) col(orange)  barw(0.5) )
				(line asir age5 if sex==2, yaxis(2) clw(thick) clc(black) clp("-") cmiss(y))
				(line asir age5 if sex==1, yaxis(2) clw(thick) clc(red) clp("-") cmiss(y))
				,
			/// Making background completely white
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			/// and insist on a long thin graphic
			ysize(2)
			
	       	xlabel(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18, valuelabel
	       	labs(large) nogrid glc(gs12) angle(45))
	       	xtitle("Age-group (years)", size(large) margin(t=3)) 
			xscale(range(1(1)10))
			xmtick(1(1)10)

	       	/// axis1 = LSH y-axis
			/// axis2 = RHS y-axis
			ylab(0(10)80, axis(1) labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
	       	ytitle("Number of cases", axis(1) size(large) margin(r=3)) 
			ymtick(0(5)65)
			
	       	ylab(0(500)2000, axis(2) labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
	       	ytitle("Incidence per 100,000 population", axis(2) size(large) margin(l=3))
			ymtick(0(250)2200, axis(2))
			
			/// Legend information
			legend(size(medlarge) nobox position(11) colf cols(2)
			region(color(gs16) ic(gs16) ilw(thin) lw(thin)) order(1 2 3 4)
			lab(1 "Number of cases (men)") 
			lab(2 "Number of cases (women)")
			lab(3 "Incidence per 100,000 (men)") 
			lab(4 "Incidence per 100,000 (women)")
			);
#delimit cr
graph export "`datapath'\version09\3-output\2013_age-sex graph_cancer.png" ,replace
