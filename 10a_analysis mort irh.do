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

** ------------------------------------------
** PART 1: World Standard Population
** ------------------------------------------
** IRH: 19-MAY-2022
** ------------------------------------------
input str5 atext spop
"0-4"	88569
"5-9" 86870
"10-14"	85970
"15-19"	84670
"20-24"	82171
"25-29"	79272
"30-34"	76073
"35-39"	71475
"40-44"	65877
"45-49"	60379
"50-54"	53681
"55-59"	45484
"60-64"	37187
"65-69"	29590
"70-74"	22092
"75-79"	15195
"80-84"	9097
"85-89"	4398
"90-94"	1500
"95-99"	400
"100+"	50
end

** Collapse to 18 age groups in 5 year bands, and 85+
gen age21 = 1 if atext=="0-4"
replace age21 = 2 if atext=="5-9"
replace age21 = 3 if atext=="10-14"
replace age21 = 4 if atext=="15-19"
replace age21 = 5 if atext=="20-24"
replace age21 = 6 if atext=="25-29"
replace age21 = 7 if atext=="30-34"
replace age21 = 8 if atext=="35-39"
replace age21 = 9 if atext=="40-44"
replace age21 = 10 if atext=="45-49"
replace age21 = 11 if atext=="50-54"
replace age21 = 12 if atext=="55-59"
replace age21 = 13 if atext=="60-64"
replace age21 = 14 if atext=="65-69"
replace age21 = 15 if atext=="70-74"
replace age21 = 16 if atext=="75-79"
replace age21 = 17 if atext=="80-84"
replace age21 = 18 if atext=="85-89"
replace age21 = 19 if atext=="90-94"
replace age21 = 20 if atext=="95-99"
replace age21 = 21 if atext=="100+"
gen age5 = age21
recode age5 (18 19 20 21 = 18) 
collapse (sum) spop , by(age5) 
rename spop pop_std 
tempfile who_std5
save `who_std5', replace


** ------------------------------------------
** PART 2: Barbados Cancer Deaths
** EXAMPLE: Breast Cancer
** 		- We use BC from both sexes 
** 		- and we use full BRB population 
** ------------------------------------------
** IRH: 19-MAY-2022
** ------------------------------------------
** Load the BRB cancer deaths dataset
use "`datapath'\version04\3-output\2018_prep mort", replace
keep record_id age age5 age_10 sex siteiarc 
** Restrict to Breast cancer only - before merging with any population files
keep if siteiarc==29
** Merge with BRB population (WPP 2018)
merge m:m sex age5 using "`datapath'\version04\2-working\pop_wpp_2018-5"
** Single age group has no cancers (men 25-34)
gen case = 1 if record_id!=. 
replace case = 0 if record_id==.  
drop _merge
drop age_10 
rename pop_wpp pop_brb
** Fillin cause for rectangularized dataset
egen cause  = min(siteiarc) 
label define cause_ 29 "breast (c50)" 
label values cause cause_ 
drop siteiarc
** Collapse to 5-year intervals
collapse (sum) case (mean) pop_brb , by(age5 sex cause)

** ------------------------------------------
** PART 3: RATES from FIRST PRINCIPLES
** ------------------------------------------
** IRH: 19-MAY-2022
** ------------------------------------------
preserve
** Add the World Reference population (5-year intervals, 18 groups)
qui {
    merge m:m age5 using `who_std5'
    drop _merge

** Standardize variable names and LABEL
** Leave in cause - will allow generalisation to > 1 cancer in same cade
** Add year - again to allow for generalisation
	rename pop_brb lpop
	rename pop_std rpop
	gen year = 2018
	label var age "Age to nearest year"
	label var age5 "Age in 5-year groups (18 groups)"
	label var lpop "Local population"
	label var rpop "Standard population"
	label var case "Case identifier 1=case"
	label var year "Year of death"
	label var cause "Cause of death"
	order age age5 sex year cause case lpop rpop  

** Crude rate
    bysort sex year cause : egen num = sum(case)
    bysort sex year cause : egen denom = sum(lpop)
    gen crude = num / denom

** (Ref Pop)/(Local Pop) * (Local Observed Events)
    gen srate1 = rpop / lpop * case 
    bysort sex year cause : egen tsrate1 = sum(srate1)
    bysort sex year cause : egen trpop = sum(rpop)
    bysort sex year cause : egen tlpop = sum(lpop)
    sort age5
    ** Per 10,000
    gen rate = tsrate1 / trpop

** Method
** DSR: 1 / sum(refpop) * sum(refpop*case/localpop) 
    bysort sex year cause : egen t1a = sum(rpop)
    gen  t1b = 1/t1a
    gen t2a = rpop * case / lpop
    bysort sex year cause : egen t2b = sum(t2a)
    gen dsr = t1b * t2b

** DSR 95%CI
    **  DSR
    gen ci1 = dsr 
    **  Case(lower)
    bysort sex year cause : egen ol1 = sum(case)
    gen ol2 = 1 / (9*ol1)
    gen ol3 = 1.96 / (3 * sqrt(ol1))
    gen ol4 = ol1 * (1- ol2 - ol3)^3
    **  Case(upper)
    bysort sex year cause : egen ou1 = sum(case)
    gen ou2 = 1 / (9*(ou1 + 1))
    gen ou3 = 1.96 / (3 * sqrt(ou1 + 1))
    gen ou4 = (ou1+1) * (1 - ou2 + ou3)^3
    **  Var(DSR)
    gen var1 = rpop^2 * case / lpop^2
    bysort sex year cause : egen var2 = sum(var1)
    bysort sex year cause : egen var3 = sum(rpop)
    gen var4 = var2 / (var3 ^2)
    **  DSR(lower)
    gen cl1 = dsr
    gen cl = cl1 + sqrt(var4/ol1) * (ol4 - ol1)
    **  DSR(upper)
    gen cu = cl1 + sqrt(var4/ol1) * (ou4 - ol1)
    ** Clear intermediate variables
    drop t1a t1b t2a t2b ci1 ol1 ol2 ol3 ol4 ou1 ou2 ou3 ou4 var1 var2 var3 var4 cl1 
    rename case cases 

    ** Collapse out the local population
    collapse (sum) cases lpop (mean) crate=crude arate=dsr aupp=cu alow=cl, by(sex year cause )  

    ** Reformat variables
    ** rename case daly 
    rename lpop pop 
    gen ase = .  

    ** Variable re-naming and dropping unwanted variables
	foreach var in crate arate alow aupp {
		replace `var' = `var' * 100000
		format `var' %9.2f
	}
    keep cases crate arate alow aupp pop sex year cause  
    order cause year sex cases pop crate arate alow aupp 
	label var cases "Number of cases"
	label var pop "Local population"
	label var crate "Crude rate"
	label var arate "Adjusted rate"
	label var alow  "Adjusted rate: 95% lower limit "
	label var aupp  "Adjusted rate: 95% upper limit "
}
	** First Principles: Rate Table
	list cause year sex pop cases crate arate alow aupp
restore
** ------- rate code ends ---------------------- 

** Implement Stata's -dstdize- direct standardization
qui {
	tempfile brb
	rename pop_brb pop
	save `brb', replace

	** For -dstdize-: same population variable name needed in local and standard population
	use `who_std5', clear
	tempfile who2_std5 
	rename pop_std pop
	save `who2_std5', replace

	use `brb' , clear
	dstdize case pop age5, by(sex) using(`who2_std5')
	matrix m`x'_`y'_`z' = r(crude) \ r(adj) \r(ub_adj) \ r(lb_adj) \  r(se) \ r(Nobs)
	matrix m`x'_`y'_`z' = m`x'_`y'_`z''
	svmat double m`x'_`y'_`z', name(col)
	keep cause sex Nobs Crude Adjusted Left Right 
	keep if Crude<.
		foreach var in Crude Adjusted Left Right {
			replace `var' = `var' * 100000
			format `var' %9.2f
		}
}
** -dstdize-: Rate Table
list cause sex Nobs Crude Adjusted Left Right

** ---------------------------------------------------------------------
** 19-May-2022
** IRH NOTES
** ---------------------------------------------------------------------
** (1) WHO 2000 population has been heavily rounded - check whether / to what extend this affects results
** (2) -distrate- has been deprecated, use new solution for rates - see below for 2 options
** (3) What BB population data are being used. UN, IARC and others probably will be using UN WPP - explore diffs
** ---------------------------------------------------------------------

