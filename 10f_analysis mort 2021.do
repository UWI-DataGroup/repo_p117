cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          10f_analysis_mort 2021.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL & Kern ROCKE
    //  date first created      15-SEPT-2023
    // 	date last modified      15-SEPT-2023
    //  algorithm task          Analyzing combined cancer dataset: (1) Numbers (2) ASMRs
    //  status                  Completed
    //  objective               To have one dataset with cleaned and grouped 2021 death data for inclusion in 2019 cancer report/for Globocan comparison.
    
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
    *local datapath "X:/The University of the West Indies/DataGroup - repo_data/data_p117"
	local datapath "/Volumes/Drive 2/BNR Consultancy/Sync/Sync/DM/Data/BNR-Cancer/data_p117_decrypted" // Kern encrypted local machine
	
    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath X:/OneDrive - The University of the West Indies/repo_datagroup/repo_p117

    ** Close any open log file and open a new log file
    *capture log close
    *log using "`logpath'/10e_analysis_mort 2021.smcl", replace
** HEADER -----------------------------------------------------

** Load the dataset
use "`datapath'/version13/3-output/2021_prep mort_deidentified", replace

count // 733 cancer deaths in 2021

tab age_10 sex ,m
tab siteiarc ,m
labelbook siteiarc_lab

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
tab siteiarc top10 if top10!=0, rowsort

tab siteiarc if top10!=0, sort nolabel

contract siteiarc top10 if top10!=0, freq(count) percent(percentage)
gsort -count
drop top10


/*
                      IARC CI5-XI sites |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                         Prostate (C61) |        133       26.60       26.60
                            Colon (C18) |         90       18.00       44.60
                           Breast (C50) |         77       15.40       60.00
Lung (incl. trachea and bronchus) (C33- |         47        9.40       69.40
                         Pancreas (C25) |         30        6.00       75.40
                        Rectum (C19-20) |         28        5.60       81.00
                           Kidney (C64) |         28        5.60       86.60
                          Stomach (C16) |         23        4.60       91.20
                     Corpus uteri (C54) |         22        4.40       95.60
                 Multiple myeloma (C90) |         22        4.40      100.00
----------------------------------------+-----------------------------------
                                  Total |        500      100.00


*/
total count //500

** JC update: Save these results as a dataset for reporting
replace siteiarc=2 if siteiarc==39
replace siteiarc=3 if siteiarc==13
replace siteiarc=4 if siteiarc==29
replace siteiarc=5 if siteiarc==21
replace siteiarc=6 if siteiarc==18
replace siteiarc=7 if siteiarc==14
replace siteiarc=8 if siteiarc==42
replace siteiarc=9 if siteiarc==11
replace siteiarc=10 if siteiarc==33
replace siteiarc=11 if siteiarc==55
rename siteiarc cancer_site
gen year=1
rename count number

	expand 2 in 1
	replace cancer_site=1 in 11
	replace number=733 in 11
	replace percentage=100 in 11

//JC 19may2022: rename breast to female breast as drop males in distrate breast section so ASMR for breast is calculated using female population
//JC 13jun2022: performed above correction
label define cancer_site_lab 1 "all" 2 "prostate" 3 "colon" 4 "female breast" 5 "lung" 6 "pancreas" 7 "rectum" 8 "kidney" 9 "stomach" 10 "corpus uteri" 11 "multiple myeloma" ,modify
label values cancer_site cancer_site_lab
label define year_lab 1 "2021" ,modify
label values year year_lab
sort cancer_site
gen rpt_id = _n
save "`datapath'/version13/2-working/ASMRs_wpp_2021" ,replace
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
merge m:m sex age_10 using "`datapath'/version13/2-working/pop_wpp_2021-10"

/*
     Result                      Number of obs
    -----------------------------------------
    Not matched                             3
        from master                         0  (_merge==1)
        from using                          3  (_merge==2)

    Matched                               700  (_merge==3)
    -----------------------------------------

*/
**drop if _merge==2 //do not drop these age groups as it skews pop_wpp 
list age_10 sex if _merge==2
** There are 2 unmatched record (_merge==2) since 2020 data doesn't have any cases of females + males with age range 0-14

tab age_10 ,m //none missing

gen case=1 if record_id!=. //do not generate case for missing age group 25-34 as it skews case total
gen pfu=1 // for % year if not whole year collected; not done for cancer

list record_id sex age_10 if case==.
list record_id sex age_10 if age_10==1 //& sex==2 // age range 25-34 for male: change case=0 for age_10=1
replace case=0 if age_10==1 //& sex==2 //2 changes

** SF requested by email & WhatsApp on 07-Jan-2020 age and sex specific rates for top 10 cancers
/*
What is age-specific mortality rate? 
Age-specific rates provide information on the mortality of a particular event in an age group relative to the total number of people at risk of that event in the same age group.

What is age-standardised mortality rate?
The age-standardized mortality rate is the summary rate that would have been observed, given the schedule of age-specific rates, in a population with the age composition of some reference population, often called the standard population.
*/
** AGE + SEX
preserve
collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex siteiarc)
gen mortrate=case/pop_wpp*100000
drop if siteiarc!=39 & siteiarc!=29 & siteiarc!=13 & siteiarc!=21 ///
		& siteiarc!=14 & siteiarc!=18 & siteiarc!=42 ///
		& siteiarc!=11 & siteiarc!=33 & siteiarc!=55
//by sex,sort: tab age_10 mortrate ,m
sort siteiarc age_10 sex
//list mortrate age_10 sex
//list mortrate age_10 sex if siteiarc==13

format mortrate %04.2f
gen year=2021
rename siteiarc cancer_site
rename mortrate age_specific_rate
drop pfu case pop_wpp
order year cancer_site sex age_10 age_specific_rate
save "`datapath'/version13/2-working/2021_top10mort_age+sex_rates" ,replace
restore

** AGE
preserve
collapse (sum) case (mean) pop_wpp, by(pfu age_10 siteiarc)
gen mortrate=case/pop_wpp*100000
drop if siteiarc!=39 & siteiarc!=29 & siteiarc!=13 & siteiarc!=21 ///
		& siteiarc!=14 & siteiarc!=18 & siteiarc!=42 ///
		& siteiarc!=11 & siteiarc!=33 & siteiarc!=55
//by sex,sort: tab age_10 mortrate ,m
sort siteiarc age_10
//list mortrate age_10 sex
//list mortrate age_10 sex if siteiarc==13

format mortrate %04.2f
gen year=2021
rename siteiarc cancer_site
rename mortrate age_specific_rate
drop pfu case pop_wpp
order year cancer_site age_10 age_specific_rate
save "`datapath'/version13/2-working/2021_top10mort_age_rates" ,replace
restore

** Check for missing age as these would need to be added to the median group for that site when assessing ASMRs to prevent creating an outlier
count if age==.|age==999 //2

list siteiarc age sex age_10 case if age==.|age==999 //this is missing age_10: 0-14 so no change needed

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

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR ALL TUMOURS - STD TO WHO WORLD pop_wppN 
/*
   +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  733   281207   248.57    146.23   135.32   157.90     5.69 |
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
gen percent=number/733*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASMRs_wpp_2021"
replace cancer_site=1 if cancer_site==.
replace year=1 if year==.
gen asmr_id="all" if rpt_id==.
replace rpt_id=1 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==1 & asmr_id==""
drop asmr_id
save "`datapath'/version13/2-working/ASMRs_wpp_2021" ,replace
restore

** PROSTATE
tab pop_wpp age_10 if siteiarc==39 //male

preserve
	drop if age_10==.
	keep if siteiarc==39 // 
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings: 
	** M 0-14,15-24,25-34,35-44
	
	expand 2 in 1
	replace sex=2 in 6
	replace age_10=1 in 6
	replace case=0 in 6
	replace pop_wpp=(24484)  in 6
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 7
	replace age_10=2 in 7
	replace case=0 in 7
	replace pop_wpp=(19286)  in 7
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=3 in 8
	replace case=0 in 8
	replace pop_wpp=(18422) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=4 in 9
	replace case=0 in 9
	replace pop_wpp=(18494) in 9
	sort age_10
			
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD pop_wppN 
/*
   +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  144   136168   105.75     66.57    56.08    78.69     5.62 |
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
gen percent=number/733*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASMRs_wpp_2021"
replace cancer_site=2 if cancer_site==.
replace year=1 if year==.
gen asmr_id="prost" if rpt_id==.
replace rpt_id=2 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==2 & asmr_id==""
drop asmr_id
save "`datapath'/version13/2-working/ASMRs_wpp_2021" ,replace
restore


** BREAST
tab pop_wpp age_10 if siteiarc==29 & sex==1 //female
tab pop_wpp age_10 if siteiarc==29 & sex==2 //male

preserve
//JC 19may2022: remove male breast cancers so rate calculated only based on female pop
//JC 13jun2022: above correction performed
	drop if sex==2
	drop if sex==. 
	drop if age_10==.
	keep if siteiarc==29 // breast only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex

	** now we have to add in the cases and pop_wppns for the missings: 
	** F 0-14,15-24
	** M 0-14,15-24,25-34,35-44,45-54,55-64,85+
		
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_wpp=(23681) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=2 in 9
	replace case=0 in 9
	replace pop_wpp=(18448) in 9
	sort age_10
	
/*	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(25750) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(19254) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_wpp=(18395) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=4 in 14
	replace case=0 in 14
	replace pop_wpp=(18924) in 14
	sort age_10
		
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=5 in 15
	replace case=0 in 15
	replace pop_wpp=(19347) in 15
	sort age_10
		
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=6 in 16
	replace case=0 in 16
	replace pop_wpp=(17226) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=8 in 17
	replace case=0 in 17
	replace pop_wpp=(5724) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(2596) in 18
	sort age_10
*/
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BC (M&F) - STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   86   148287   58.00     33.05    25.94    41.71     3.90 |
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
gen percent=number/733*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASMRs_wpp_2021"
replace cancer_site=3 if cancer_site==.
replace year=1 if year==.
gen asmr_id="fem.breast" if rpt_id==.
replace rpt_id=3 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==3 & asmr_id==""
drop asmr_id
save "`datapath'/version13/2-working/ASMRs_wpp_2021" ,replace
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
	** M   35-44
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(23681) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=1 in 15
	replace case=0 in 15
	replace pop_wpp=(24484) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_wpp=(18448) in 16
	sort age_10

	expand 2 in 1
	replace sex=2 in 17
	replace age_10=2 in 17
	replace case=0 in 17
	replace pop_wpp=(19286) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=4 in 18
	replace case=0 in 18
	replace pop_wpp=(18924) in 18
	sort age_10
	
	

	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

total pop_wpp

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (M&F)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   81   287371   28.19     14.57    11.45    18.43     1.72 |
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
gen percent=number/733*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASMRs_wpp_2021"
replace cancer_site=4 if cancer_site==.
replace year=1 if year==.
gen asmr_id="colon" if rpt_id==.
replace rpt_id=4 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==4 & asmr_id==""
drop asmr_id
save "`datapath'/version13/2-working/ASMRs_wpp_2021" ,replace
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
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=4 in 12
	replace case=0 in 12
	replace pop_wpp=(19333) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=1 in 13
	replace case=0 in 13
	replace pop_wpp=(23681) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(24484) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=2 in 15
	replace case=0 in 15
	replace pop_wpp=(18448) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_wpp=(19286) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=3 in 17
	replace case=0 in 17
	replace pop_wpp=(18488) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=3 in 18
	replace case=0 in 18
	replace pop_wpp=(18422) in 18
	sort age_10
	


	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR LUNG CANCER (M&F)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   32   287371   11.14      5.56     3.75     8.15     1.07 |
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
gen percent=number/733*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASMRs_wpp_2021"
replace cancer_site=5 if cancer_site==.
replace year=1 if year==.
gen asmr_id="lung" if rpt_id==.
replace rpt_id=5 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==5 & asmr_id==""
drop asmr_id
save "`datapath'/version13/2-working/ASMRs_wpp_2021" ,replace
restore


** CORPUS UTERI
tab pop_wpp age_10 if siteiarc==33

preserve
	drop if age_10==.
	keep if siteiarc==33
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings: 
	** F 0-14,15-24,25-34,35-44, 85 and over
	
	
	expand 2 in 1
	replace sex=1 in 5
	replace age_10=9 in 5
	replace case=0 in 5
	replace pop_wpp=(4036) in 5
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 6
	replace age_10=1 in 6
	replace case=0 in 6
	replace pop_wpp=(23681) in 6
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=2 in 7
	replace case=0 in 7
	replace pop_wpp=(18448) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=3 in 8
	replace case=0 in 8
	replace pop_wpp=(18488) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=4 in 9
	replace case=0 in 9
	replace pop_wpp=(19333) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CORPUS UTERI (WOMEN)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   32   148287   21.58     11.81     8.01    17.13     2.23 |
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
gen percent=number/733*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASMRs_wpp_2021"
replace cancer_site=6 if cancer_site==.
replace year=1 if year==.
gen asmr_id="corpus" if rpt_id==.
replace rpt_id=6 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==6 & asmr_id==""
drop asmr_id
save "`datapath'/version13/2-working/ASMRs_wpp_2021" ,replace
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
	** F 45-54, 85 & over
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_wpp=(23681) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_wpp=(24484) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_wpp=(18448) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(19286) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_wpp=(18488) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_wpp=(18422) in 14
	sort age_10	
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_wpp=(19333) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_wpp=(18494) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=5 in 17
	replace case=0 in 17
	replace pop_wpp=(20756) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_wpp=(4036) in 18
	sort age_10
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PANCREATIC CANCER (M&F)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   26   287371    9.05      4.80     3.09     7.31     1.03 |
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
gen percent=number/733*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASMRs_wpp_2021"
replace cancer_site=7 if cancer_site==.
replace year=1 if year==.
gen asmr_id="panc" if rpt_id==.
replace rpt_id=7 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==7 & asmr_id==""
drop asmr_id
save "`datapath'/version13/2-working/ASMRs_wpp_2021" ,replace
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
	** M&F 0-14,15-24,25-34
	** M   35-44, 45-54
	** F   45-54
	
	expand 2 in 1
	replace sex=2 in 10
	replace age_10=5 in 10
	replace case=0 in 10
	replace pop_wpp=(19347) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(23681) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_wpp=(24484) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(18448) in 13
	sort age_10
		
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_wpp=(19286) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18488) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_wpp=(18422) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_wpp=(18494) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=5 in 18
	replace case=0 in 18
	replace pop_wpp=(20756) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR MULTIPLE MYELOMA (M&F)- STD TO WHO WORLD pop_wppN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   25   287371    8.70      4.72     2.98     7.26     1.04 |
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
gen percent=number/733*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASMRs_wpp_2021"
replace cancer_site=8 if cancer_site==.
replace year=1 if year==.
gen asmr_id="MM" if rpt_id==.
replace rpt_id=8 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==8 & asmr_id==""
drop asmr_id
save "`datapath'/version13/2-working/ASMRs_wpp_2021" ,replace
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
	** F 35-44
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=4 in 11
	replace case=0 in 11
	replace pop_wpp=(18494) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_wpp=(24043) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 13
	replace age_10=1 in 13
	replace case=0 in 13
	replace pop_wpp=(24894) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_wpp=(18537) in 14
	sort age_10
		
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=2 in 15
	replace case=0 in 15
	replace pop_wpp=(19306) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_wpp=(18544) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=3 in 17
	replace case=0 in 17
	replace pop_wpp=(18394) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=4 in 18
	replace case=0 in 18
	replace pop_wpp=(19508) in 18
	sort age_10
	
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR STOMACH CANCER (M&F)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   22   288581    7.62      3.80     2.32     6.08     0.91 |
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
gen percent=number/733*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASMRs_wpp_2021"
replace cancer_site=9 if cancer_site==.
replace year=1 if year==.
gen asmr_id="stom" if rpt_id==.
replace rpt_id=9 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==9 & asmr_id==""
drop asmr_id
save "`datapath'/version13/2-working/ASMRs_wpp_2021" ,replace
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
	** M 35-44
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_wpp=(24484) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_wpp=(18448) in 12
	sort age_10
		
	expand 2 in 1
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_wpp=(19286) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_wpp=(18488) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_wpp=(18422) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_wpp=(18494) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=5 in 17
	replace case=0 in 17
	replace pop_wpp=(20756) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=1 in 18
	replace case=0 in 18
	replace pop_wpp=(23681) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RECTAL CANCER (M&F)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   16   287371    5.57      3.45     1.94     5.83     0.95 |
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
gen percent=number/733*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASMRs_wpp_2021"
replace cancer_site=10 if cancer_site==.
replace year=1 if year==.
gen asmr_id="rect" if rpt_id==.
replace rpt_id=10 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==10 & asmr_id==""
drop asmr_id
save "`datapath'/version13/2-working/ASMRs_wpp_2021" ,replace
restore


** KIDNEY
tab pop_wpp age_10 if siteiarc==42 & sex==1 //female
tab pop_wpp age_10 if siteiarc==42 & sex==2 //male

preserve
	drop if age_10==.
	keep if siteiarc==42
	
	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	sort age sex
	
	** now we have to add in the cases and pop_wppns for the missings: 
	** M&F 0-14,15-24
	** F 25-34
	** M 35-44
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=4 in 9
	replace case=0 in 9
	replace pop_wpp=(18924) in 9
	sort age_10
		
	expand 2 in 1
	replace sex=2 in 10
	replace age_10=5 in 10
	replace case=0 in 10
	replace pop_wpp=(19347) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=5 in 11
	replace case=0 in 11
	replace pop_wpp=(20756) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=6 in 12
	replace case=0 in 12
	replace pop_wpp=(20932) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=1 in 13
	replace case=0 in 13
	replace pop_wpp=(23681) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_wpp=(24484) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=2 in 15
	replace case=0 in 15
	replace pop_wpp=(18448) in 15
	sort age_10
		
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_wpp=(19286) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=3 in 17
	replace case=0 in 17
	replace pop_wpp=(18488) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=4 in 18
	replace case=0 in 18
	replace pop_wpp=(18494) in 18
	sort age_10
	
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_wpp

distrate case pop_wpp using "`datapath'/version13/2-working/who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR NHL (M&F)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   16   287371    5.57      3.19     1.76     5.47     0.90 |
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
gen percent=number/733*100
replace percent=round(percent,0.01)

append using "`datapath'/version13/2-working/ASMRs_wpp_2021"
replace cancer_site=11 if cancer_site==.
replace year=1 if year==.
gen asmr_id="NHL" if rpt_id==.
replace rpt_id=11 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==11 & asmr_id==""
drop asmr_id rpt_id
format asmr %04.2f
format percentage %04.1f
save "`datapath'/version13/2-working/ASMRs_wpp_2021" ,replace
restore


label data "BNR MORTALITY rates 2021"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'/version13/3-output/2021_analysis mort_wpp" ,replace
note: TS This dataset includes patients with multiple eligible cancer causes of death; used WPP population
