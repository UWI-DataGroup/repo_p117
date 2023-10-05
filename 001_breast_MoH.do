clear
capture log close
cls

**  GENERAL DO-FILE COMMENTS
**  Program:		001_breast_MoH.do
**  Project:      	Barbados National Registry
**	Sub-Project:	Cancer
**  Analyst:        Kern Rocke 
**	Date Created:	15/08/2023
**	Date Modified: 	05/10/2023
**  Algorithm Task: Fullfilling data request by Natioanl Cancer Society on breast cancer by parish for the period 2015-2018


** DO-FILE SET UP COMMANDS
version 13
clear all
macro drop _all
set more 1
set linesize 150

*Set working directories (Set you working directory to match your OS)
local datapath "/Volumes/Drive 2/BNR Consultancy/Sync/Sync/DM/Data/BNR-Cancer/data_p117_decrypted"

/*

1) Create dataset of female population by parish for Barbados using 2010 national 
	census data
	
2) Estimate	Age-standardized incidence rate for the period 2015-2018 of female breast cancer
	by parish in Barbados
	
3) Estimate Age-standarized mortality rate for the period 2015-2021 of female breast cancer	

*/

*-------------------------------------------------------------------------------
*Population census by parish for Barbados dataset creation.

*Import excel dataset to STATA for analysis
import excel "`datapath'/version14/1-input/Census-Tables-2010.xlsx", sheet("01.02") cellrange(A5:D255) clear

*Minor data cleaning 
drop if A=="Not stated"
gen parish = .
gen age5 = .
rename B total_pop
rename C female_pop
rename D male_pop

*Create parish categories
label define parish 1"Christ Church" 2"St. Andrew" 3"St.George" 4"St. James" 5"St. John" 6"St. Joseph" 7"St. Lucy" 8"St. Michael" 9"St. Peter" 10"St. Philip" 11"St. Thomas"
label value parish parish
replace parish = 8 in 22/39 
replace parish = 1 in 42/59
replace parish = 3 in 62/79
replace parish = 10 in 82/99
replace parish = 5 in 102/119
replace parish = 4 in 122/139
replace parish = 11 in 142/159
replace parish = 6 in 162/179
replace parish = 2 in 182/199
replace parish = 9 in 202/219
replace parish = 7 in 222/239
drop if parish == .


*Create 5-year and 10-year age groups
encode A, gen(age5_cat)

replace age5 = 1 if age5_cat == 18
replace age5 = 2 if age5_cat == 1
replace age5 = 3 if age5_cat == 2
replace age5 = 4 if age5_cat == 3
replace age5 = 5 if age5_cat == 4
replace age5 = 6 if age5_cat == 5
replace age5 = 7 if age5_cat == 6
replace age5 = 8 if age5_cat == 7
replace age5 = 9 if age5_cat == 8
replace age5 = 10 if age5_cat == 9
replace age5 = 11 if age5_cat == 10
replace age5 = 12 if age5_cat == 11
replace age5 = 13 if age5_cat == 12
replace age5 = 14 if age5_cat == 13
replace age5 = 15 if age5_cat == 14
replace age5 = 16 if age5_cat == 15
replace age5 = 17 if age5_cat == 16
replace age5 = 18 if age5_cat == 17

label define age5_lab 1 "0-4" 	 2 "5-9"    3 "10-14" ///
					  4 "15-19"  5 "20-24"  6 "25-29" ///
					  7 "30-34"  8 "35-39"  9 "40-44" ///
					 10 "45-49" 11 "50-54" 12 "55-59" ///
					 13 "60-64" 14 "65-69" 15 "70-74" ///
					 16 "75-79" 17 "80-84" 18 "85 & over", modify
label values age5 age5_lab

gen age_10 = recode(age5,3,5,7,9,11,13,15,17,200)
recode age_10 3=1 5=2 7=3 9=4 11=5 13=6 15=7 17=8 200=9

label define age_10_lab 1 "0-14"   2 "15-24"  3 "25-34" ///
                        4 "35-44"  5 "45-54"  6 "55-64" ///
                        7 "65-74"  8 "75-84"  9 "85 & over" , modify

label values age_10 age_10_lab

*Remove variables not to be used in analysis
drop age5_cat A total_pop male_pop


*Shrink dataset to population counts by 10-year age bands and parish
collapse (sum) female_pop, by(age5 age_10 parish)

*Save dataset
save "`datapath'/version14/2-working/female_parish_bb_pop", replace

*-------------------------------------------------------------------------------
*Load in dataset with incident cancer cases from the period 2008 - 2018
use "`datapath'/version14/1-input/2008_2013-2018_cancer_reportable_nonsurvival_deidentified.dta", clear
drop if dxyr<2015
*keep if siteicd10==8
drop if sex!=1

gen case = .
replace case = 1 if siteicd10==8
replace case = 0 if siteicd10!=8

keep if case == 1
*drop if parish == 99

** Age labelling
gen age5 = recode(age,4,9,14,19,24,29,34,39,44,49,54,59,64,69,74,79,84,200)

recode age5 4=1 9=2 14=3 19=4 24=5 29=6 34=7 39=8 44=9 49=10 54=11 59=12 64=13 /// 
                        69=14 74=15 79=16 84=17 200=18

label define age5_lab 1 "0-4" 	 2 "5-9"    3 "10-14" ///
					  4 "15-19"  5 "20-24"  6 "25-29" ///
					  7 "30-34"  8 "35-39"  9 "40-44" ///
					 10 "45-49" 11 "50-54" 12 "55-59" ///
					 13 "60-64" 14 "65-69" 15 "70-74" ///
					 16 "75-79" 17 "80-84" 18 "85 & over", modify
label values age5 age5_lab
gen age_10 = recode(age5,3,5,7,9,11,13,15,17,200)
recode age_10 3=1 5=2 7=3 9=4 11=5 13=6 15=7 17=8 200=9

label define age_10_lab 1 "0-14"   2 "15-24"  3 "25-34" ///
                        4 "35-44"  5 "45-54"  6 "55-64" ///
                        7 "65-74"  8 "75-84"  9 "85 & over" , modify

label values age_10 age_10_lab

drop if parish==99
count



merge m:m parish age5 using "`datapath'/version14/2-working/female_parish_bb_pop.dta"
duplicates drop pid dd_natregno if _merge ==3, force

replace case = 0 if _merge==2
sort age_10
*drop if dxyr ==.
drop _merge


*******
/*
fillin age5 age_10 parish dxyr
merge m:m parish age5 using "`datapath'/version14/2-working/female_parish_bb_pop.dta"
*duplicates drop pid dd_natregno if _merge ==3, force
count
replace case = 0 if case ==.

drop _merge female_pop
merge m:m parish age5 using "`datapath'/version14/2-working/female_parish_bb_pop.dta"
*/
drop if dxyr == .
collapse (sum) case (mean) female_pop, by(parish age5 age_10 dxyr)


preserve
keep if dxyr == 2015
set obs 85

replace dxyr = 2015 if dxyr == .
replace age5 = 1 in 81
replace age5 = 2 in 82
replace age5 = 3 in 83
replace age5 = 4 in 84
replace age5 = 5 in 85



tsset parish age5
tsfill, full

replace case = 0 if case == .
replace dxyr = 2015 if dxyr == .
drop age_10
rename female_pop pop

drop if parish == .

do "`datapath'/version14/2-working/bb_census_age5"


save "`datapath'/version14/2-working/breast_incident_2015", replace
restore
*-------------------------------------------------------------------------------
preserve
keep if dxyr == 2016
set obs 71

replace dxyr = 2016 if dxyr == .
replace age5 = 1 in 67
replace age5 = 2 in 68
replace age5 = 3 in 69
replace age5 = 4 in 70
replace age5 = 6 in 71

tsset parish age5
tsfill, full

replace case = 0 if case == .
replace dxyr = 2016 if dxyr == .
drop age_10
rename female_pop pop

drop if parish == .

do "`datapath'/version14/2-working/bb_census_age5"

save "`datapath'/version14/2-working/breast_incident_2016", replace
restore

*-------------------------------------------------------------------------------
preserve
keep if dxyr == 2017

set obs 80

replace dxyr = 2017 if dxyr == .
replace age5 = 1 in 75
replace age5 = 2 in 76
replace age5 = 3 in 77
replace age5 = 4 in 78
replace age5 = 5 in 79
replace age5 = 6 in 80


tsset parish age5
tsfill, full

replace case = 0 if case == .
replace dxyr = 2017 if dxyr == .
drop age_10
rename female_pop pop

drop if parish == .

do "`datapath'/version14/2-working/bb_census_age5"

save "`datapath'/version14/2-working/breast_incident_2017", replace
restore

*-------------------------------------------------------------------------------
preserve
keep if dxyr == 2018
set obs 84

replace dxyr = 2018 if dxyr == .
replace age5 = 1 in 80
replace age5 = 2 in 81
replace age5 = 3 in 82
replace age5 = 4 in 83
replace age5 = 5 in 84



tsset parish age5
tsfill, full

replace case = 0 if case == .
replace dxyr = 2018 if dxyr == .
drop age_10
rename female_pop pop

drop if parish == .

do "`datapath'/version14/2-working/bb_census_age5"

save "`datapath'/version14/2-working/breast_incident_2018", replace
restore
*gen pop = female_pop

use "`datapath'/version14/2-working/breast_incident_2015", clear
append using "`datapath'/version14/2-working/breast_incident_2016"
append using "`datapath'/version14/2-working/breast_incident_2017"
append using "`datapath'/version14/2-working/breast_incident_2018"


sort parish age5
total case
total pop


tabstat case , by(parish) stat(sum) save

matrix number = (r(Stat1) \ r(Stat2) \ r(Stat3) \ r(Stat4) \ r(Stat5) \ r(Stat6) \ r(Stat7) \ r(Stat8) \ r(Stat9) \ r(Stat10) \ r(Stat11))
svmat number

dstdize case pop age5, by(parish) using ("`datapath'/version14/1-input/who2000_5") format(%9.8f)

matrix asir = (r(adj)[1,1] \ r(adj)[1,2] \ r(adj)[1,3] \ r(adj)[1,4] \ r(adj)[1,5] \ r(adj)[1,6] \ r(adj)[1,7] \ r(adj)[1,8] \ r(adj)[1,9] \ r(adj)[1,10] \ r(adj)[1,11])
svmat asir			
				
matrix ci_lower = (r(lb)[1,1] \ r(lb)[1,2] \ r(lb)[1,3] \ r(lb)[1,4] \ r(lb)[1,5] \ r(lb)[1,6] \ r(lb)[1,7] \ r(lb)[1,8] \ r(lb)[1,9] \ r(lb)[1,10] \ r(lb)[1,11])
svmat ci_lower		

matrix ci_upper = (r(ub)[1,1] \ r(ub)[1,2] \ r(ub)[1,3] \ r(ub)[1,4] \ r(ub)[1,5] \ r(ub)[1,6] \ r(ub)[1,7] \ r(ub)[1,8] \ r(ub)[1,9] \ r(ub)[1,10] \ r(ub)[1,11])
svmat ci_upper	

keep number* asir* ci_lower* ci_upper*
keep if number1!=.

egen parish = seq()
label value parish parish
order parish, first

rename number1 number
rename asir1 asir
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper

replace asir = asir*100000
replace ci_lower = ci_lower*100000
replace ci_upper = ci_upper*100000

label define parish 1"Christ Church" 2"St. Andrew" 3"St.George" 4"St. James" 5"St. John" 6"St. Joseph" 7"St. Lucy" 8"St. Michael" 9"St. Peter" 10"St. Philip" 11"St. Thomas"
label value parish parish

*Save dataset with ASIR
save "`datapath'/version14/3-output/breast_cancer_incidence_2015_2018", replace

*Creating bar graph of age standardized incidence rate of female breast cancer. 
#delimit ;

		graph bar (mean) asir, 
		
		over(parish, label(angle(forty_five))) 
		
		blabel(bar, format(%9.1f)) 
		bar(1, fcolor(pink) fintensity(inten50))
		
		ytitle("Rate (per 100,000 person years)") 
		ylabel(0(25)150, angle(horizontal) nogrid)
		
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
		graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
		plotregion(style(none))
		
		title("Age-Standardized Female Breast Cancer" "Incidence Rate (per 100,000)" "2015-2018", c(black))
		name(asir, replace)
;

#delimit cr

graph save "`datapath'/version14/3-output/breast_cancer_incidence_2015_2018", replace
graph export "`datapath'/version14/3-output/breast_cancer_incidence_2015_2018.png", as(png) replace

*-------------------------------------------------------------------------------

*Creating bar graph of number of incident female breast cancer cases. 
#delimit ;

		graph bar (mean) number, 
		
		over(parish, label(angle(forty_five))) 
		
		blabel(bar, format(%9.0f)) 
		bar(1, fcolor(purple) fintensity(inten50))
		
		ytitle("Number of cases") 
		ylabel(0(25)200, angle(horizontal) nogrid)
		
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
		graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
		plotregion(style(none))
		
		title("Number of Female Breast Cancer Cases" "2015-2018", c(black))
		name(case, replace)
;

#delimit cr

graph save "`datapath'/version14/3-output/breast_cancer_numbers_2015_2018", replace
graph export "`datapath'/version14/3-output/breast_cancer_numbers_2015_2018.png", as(png) replace

*-------------------------------------------------------------------------------


*Load in death data 
use "`datapath'/version14/1-input/2015_prep mort", clear
merge m:m sex age5 using "`datapath'/version14/1-input/pop_wpp_2015-5"

keep sex age age5 age_10 siteicd10 dodyear pop_wpp

save "`datapath'/version14/2-working/2015_prep mort_analysis", replace

forvalues x = 2016/2021{

	use "`datapath'/version14/1-input/`x'_prep mort_deidentified", clear
	merge m:m sex age5 using "`datapath'/version14/1-input/pop_wpp_`x'-5"
	keep sex age age5 age_10 siteicd10 dodyear pop_wpp
	save "`datapath'/version14/2-working/`x'_prep mort_analysis", replace

}

clear

use "`datapath'/version14/2-working/2015_prep mort_analysis", clear
append using "`datapath'/version14/2-working/2016_prep mort_analysis"
append using "`datapath'/version14/2-working/2017_prep mort_analysis"
append using "`datapath'/version14/2-working/2018_prep mort_analysis"
append using "`datapath'/version14/2-working/2019_prep mort_analysis"
append using "`datapath'/version14/2-working/2020_prep mort_analysis"
append using "`datapath'/version14/2-working/2021_prep mort_analysis"

keep if sex == 1
keep if siteicd10 == 8

gen case = 1

tab dodyear

forvalues x = 2015/2021{
	preserve
keep if dodyear == `x'

collapse (sum) case (mean) pop_wpp, by(age5 sex dodyear)
sort age sex

tab age5

save "`datapath'/version14/2-working/`x'_collapse_mort_analysis", replace

restore
}

use "`datapath'/version14/2-working/2015_collapse_mort_analysis", clear

expand 2 in 1
	replace sex=1 in 12
	replace age5=1 in 12
	replace case=0 in 12
	replace pop_wpp=(7411) in 12
	sort age5
	
	expand 2 in 1
	replace sex=1 in 13
	replace age5=2 in 13
	replace case=0 in 13
	replace pop_wpp=(8034) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=3 in 14
	replace case=0 in 14
	replace pop_wpp=(8950) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=4 in 15
	replace case=0 in 15
	replace pop_wpp=(9278) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=5 in 16
	replace case=0 in 16
	replace pop_wpp=(9345) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=6 in 17
	replace case=0 in 17
	replace pop_wpp=(9286) in 17
	sort age5

	expand 2 in 1
	replace sex=1 in 18
	replace age5=9 in 18
	replace case=0 in 18
	replace pop_wpp=(10504) in 18
	sort age5

save "`datapath'/version14/2-working/2015_collapse_mort_analysis", replace


use "`datapath'/version14/2-working/2016_collapse_mort_analysis", clear

expand 2 in 1
	replace sex=1 in 13
	replace age5=1 in 13
	replace case=0 in 13
	replace pop_wpp=(7411) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=2 in 14
	replace case=0 in 14
	replace pop_wpp=(8034) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=3 in 15
	replace case=0 in 15
	replace pop_wpp=(8950) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=4 in 16
	replace case=0 in 16
	replace pop_wpp=(9278) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=5 in 17
	replace case=0 in 17
	replace pop_wpp=(9345) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=6 in 18
	replace case=0 in 18
	replace pop_wpp=(9286) in 18
	sort age5


save "`datapath'/version14/2-working/2016_collapse_mort_analysis", replace


use "`datapath'/version14/2-working/2017_collapse_mort_analysis", clear

expand 2 in 1
	replace sex=1 in 13
	replace age5=1 in 13
	replace case=0 in 13
	replace pop_wpp=(7411) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=2 in 14
	replace case=0 in 14
	replace pop_wpp=(8034) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=3 in 15
	replace case=0 in 15
	replace pop_wpp=(8950) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=4 in 16
	replace case=0 in 16
	replace pop_wpp=(9278) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=5 in 17
	replace case=0 in 17
	replace pop_wpp=(9345) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=6 in 18
	replace case=0 in 18
	replace pop_wpp=(9286) in 18
	sort age5


save "`datapath'/version14/2-working/2017_collapse_mort_analysis", replace


use "`datapath'/version14/2-working/2018_collapse_mort_analysis", clear

expand 2 in 1
	replace sex=1 in 13
	replace age5=1 in 13
	replace case=0 in 13
	replace pop_wpp=(7411) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=2 in 14
	replace case=0 in 14
	replace pop_wpp=(8034) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=3 in 15
	replace case=0 in 15
	replace pop_wpp=(8950) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=4 in 16
	replace case=0 in 16
	replace pop_wpp=(9278) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=5 in 17
	replace case=0 in 17
	replace pop_wpp=(9345) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=6 in 18
	replace case=0 in 18
	replace pop_wpp=(9286) in 18
	sort age5


save "`datapath'/version14/2-working/2018_collapse_mort_analysis", replace


use "`datapath'/version14/2-working/2019_collapse_mort_analysis", clear

expand 2 in 1
	replace sex=1 in 12
	replace age5=7 in 12
	replace case=0 in 12
	replace pop_wpp=(9346) in 12
	sort age5

expand 2 in 1
	replace sex=1 in 13
	replace age5=1 in 13
	replace case=0 in 13
	replace pop_wpp=(7411) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=2 in 14
	replace case=0 in 14
	replace pop_wpp=(8034) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=3 in 15
	replace case=0 in 15
	replace pop_wpp=(8950) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=4 in 16
	replace case=0 in 16
	replace pop_wpp=(9278) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=5 in 17
	replace case=0 in 17
	replace pop_wpp=(9345) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=6 in 18
	replace case=0 in 18
	replace pop_wpp=(9286) in 18
	sort age5


save "`datapath'/version14/2-working/2019_collapse_mort_analysis", replace


use "`datapath'/version14/2-working/2020_collapse_mort_analysis", clear

expand 2 in 1
	replace sex=1 in 14
	replace age5=1 in 14
	replace case=0 in 14
	replace pop_wpp=(7411) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=2 in 15
	replace case=0 in 15
	replace pop_wpp=(8034) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=3 in 16
	replace case=0 in 16
	replace pop_wpp=(8950) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=4 in 17
	replace case=0 in 17
	replace pop_wpp=(9278) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=5 in 18
	replace case=0 in 18
	replace pop_wpp=(9345) in 18
	sort age5
	


save "`datapath'/version14/2-working/2020_collapse_mort_analysis", replace


use "`datapath'/version14/2-working/2021_collapse_mort_analysis", clear

expand 2 in 1
	replace sex=1 in 14
	replace age5=1 in 14
	replace case=0 in 14
	replace pop_wpp=(7411) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=2 in 15
	replace case=0 in 15
	replace pop_wpp=(8034) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=3 in 16
	replace case=0 in 16
	replace pop_wpp=(8950) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=4 in 17
	replace case=0 in 17
	replace pop_wpp=(9278) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=5 in 18
	replace case=0 in 18
	replace pop_wpp=(9345) in 18
	sort age5
	


save "`datapath'/version14/2-working/2021_collapse_mort_analysis", replace


use "`datapath'/version14/2-working/2015_collapse_mort_analysis", clear
append using "`datapath'/version14/2-working/2016_collapse_mort_analysis"
append using "`datapath'/version14/2-working/2017_collapse_mort_analysis"
append using "`datapath'/version14/2-working/2018_collapse_mort_analysis"
append using "`datapath'/version14/2-working/2019_collapse_mort_analysis"
append using "`datapath'/version14/2-working/2020_collapse_mort_analysis"
append using "`datapath'/version14/2-working/2021_collapse_mort_analysis"

distrate case pop_wpp using "`datapath'/version14/1-input/who2000_5", stand(age5) popstand(pop) mult(100000) format(%8.2f) by(dodyear)


gen pop = pop_wpp



tabstat case , by(dodyear) stat(sum) save

matrix number = (r(Stat1) \ r(Stat2) \ r(Stat3) \ r(Stat4) \ r(Stat5) \ r(Stat6) \ r(Stat7) )
svmat number

dstdize case pop age5, by(dodyear) using ("`datapath'/version14/1-input/who2000_5") format(%9.8f)

matrix asir = (r(adj)[1,1] \ r(adj)[1,2] \ r(adj)[1,3] \ r(adj)[1,4] \ r(adj)[1,5] \ r(adj)[1,6] \ r(adj)[1,7] )
svmat asir			
				
matrix ci_lower = (r(lb)[1,1] \ r(lb)[1,2] \ r(lb)[1,3] \ r(lb)[1,4] \ r(lb)[1,5] \ r(lb)[1,6] \ r(lb)[1,7])
svmat ci_lower		

matrix ci_upper = (r(ub)[1,1] \ r(ub)[1,2] \ r(ub)[1,3] \ r(ub)[1,4] \ r(ub)[1,5] \ r(ub)[1,6] \ r(ub)[1,7])
svmat ci_upper	

keep number* asir* ci_lower* ci_upper* dodyear
keep if number1!=.


rename number1 number
rename asir1 asir
rename ci_lower1 ci_lower
rename ci_upper1 ci_upper

replace asir = asir*100000
replace ci_lower = ci_lower*100000
replace ci_upper = ci_upper*100000

rename asir asmr

replace dodyear = 2016 in 2
replace dodyear = 2017 in 3
replace dodyear = 2018 in 4
replace dodyear = 2019 in 5
replace dodyear = 2020 in 6
replace dodyear = 2021 in 7

*Save dataset with ASIR
save "`datapath'/version14/3-output/breast_cancer_mortality_2015_2021", replace


*Creating bar graph of age standardized mortality rate of female breast cancer. 
#delimit ;

		graph bar (mean) asmr, 
		
		over(dodyear, label(angle(forty_five))) 
		
		blabel(bar, format(%9.2f)) 
		bar(1, fcolor(red) fintensity(inten50))
		
		ytitle("Rate (per 100,000 person years)") 
		ylabel(0(5)45, angle(horizontal) nogrid)
		
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
		graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
		plotregion(style(none))
		
		title("Age-Standardized Female Breast Cancer" "Mortality Rate (per 100,000)" "2015-2021", c(black))
		name(asmr, replace)
;

#delimit cr

graph save "`datapath'/version14/3-output/breast_cancer_mortality_2015_2021", replace
graph export "`datapath'/version14/3-output/breast_cancer_mortality_2015_2021.png", as(png) replace

*-------------------------------------------------------------------------------

*Creating bar graph of number of mortality female breast cancer cases. 
#delimit ;

		graph bar (mean) number, 
		
		over(dodyear, label(angle(forty_five))) 
		
		blabel(bar, format(%9.0f)) 
		bar(1, fcolor(brown) fintensity(inten50))
		
		ytitle("Number of deaths") 
		ylabel(0(25)125, angle(horizontal) nogrid)
		
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
		graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
		plotregion(style(none))
		
		title("Number of Female Breast Cancer Deaths" "2015-2021", c(black))
		name(death, replace)
;

#delimit cr

graph save "`datapath'/version14/3-output/breast_cancer_deaths_2015_2021", replace
graph export "`datapath'/version14/3-output/breast_cancer_deaths_2015_2021.png", as(png) replace

*-------------------------END---------------------------------------------------
