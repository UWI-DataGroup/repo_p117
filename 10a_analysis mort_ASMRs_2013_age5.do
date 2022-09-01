** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          10a_analysis mort_ASMRs_2013_age5.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      31-AUG-2022
    // 	date last modified      31-AUG-2022
    //  algorithm task          Analyzing combined cancer dataset: (1) Numbers (2) ASMRs
    //  status                  Completed
    //  objective               To have one dataset with cleaned and grouped 2013 death data for inclusion in 2016-2018 cancer report.
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
    log using "`logpath'\10a_analysis mort_ASMRs_2013_age5.smcl", replace
** HEADER -----------------------------------------------------

****************
** 2013 ASMRs **
****************

** Load the dataset
/* 
	JC 24aug2022: When checking SF's presentation for the 2022 BNR CME webinar, NS queried whether 2013-2015 ASMRs had used
	female pop for breast then I noted that those years used BSS pop instead of WPP so re-calculating 2013-2018 ASMRs 
	using WPP pop, female pop for breast and 5-year age groups so the methods are standardised with 
	those for the ASIRs calculations.
*/
use "`datapath'\version09\1-input\2013_cancer_for_MR_only", clear

count // 577 cancer deaths in 2013
tab age5 sex ,m
tab site ,m //2013 data only has AR's site
labelbook site_lab //2013 data only has AR's site


** JC 24aug2022: Move the anal cancers (C21) to its own category so rectum and anus categories match site_lab in later years (cannot create site since CODs are not ICD-10 coded and do not have the time to do so now)
count if site==4|site==5 //25
list deathid causeofdeath site if site==4|site==5 ,nolabel
list deathid causeofdeath site if site==4 ,nolabel
count if site==5 //18
list deathid causeofdeath site if site==5 ,nolabel
list deathid causeofdeath site if site==3 ,nolabel

replace site=4 if deathid==5106|deathid==5301|deathid==5475|deathid==5783|deathid==5888 ///
				 |deathid==5983|deathid==6001|deathid==6188|deathid==6368|deathid==6580 ///
				 |deathid==6630|deathid==6870|deathid==6941|deathid==7113|deathid==7202 ///
				 |deathid==7293 //16 changes

label drop site_lab
label define site_lab 1 "C00-C14: lip, oral cavity & pharynx" 2 "C16: stomach"  3 "C18: colon" /// 
  					  4 "C19-20: rectum"  5 "C21: anus" 6 "C25: pancreas" ///
					  7 "C15, C17, C21-C24, C26: other digestive organs" ///
					  8 "C30-C39: respiratory and intrathoracic organs" 9 "C40-41: bone and articular cartilage" ///
					  10 "C42: haematopoietic & reticuloendothelial systems" ///
					  11 "C43: melanoma" 12 "C44: skin (non-reportable cancers)" ///
					  13 "C45-C49: mesothelial and soft tissue" 14 "C50: breast" 15 "C53: cervix" ///
					  16 "C54: uterus" 17 "C51-C52, C55-58: other female genital organs" ///
					  18 "C60, C62, C63: male genital organs" 19 "C61: prostate" ///
					  20 "C64-C68: urinary tract" 21 "C69-C72: eye, brain, other CNS" ///
					  22 "C73-C75: thyroid and other endocrine glands"  /// 
					  23 "C76: other and ill-defined sites" ///
					  24 "C77: lymph nodes" 25 "C80: unknown primary site"
label var site "site of tumour"
label values site site_lab

//tab age5 sex ,m
//tab site ,m //2013 data only has AR's site
//labelbook site_lab //2013 data only has AR's site

** proportions for Table 7 using IARC's site groupings
//tab site sex ,m
//tab site , m
//tab site if sex==2 ,m // female
//tab site if sex==1 ,m // male


** For annual report - Section 4: Mortality - Table 7a
** Below top 10 code added by JC for 2014
** All sites excl. O&U, insitu, non-reportable skin cancers - using IARC CI5's site groupings
preserve
drop if site==12|site==23|site==25 //45 deleted
bysort site: gen n=_N
bysort n site: gen tag=(_n==1)
replace tag = sum(tag)
sum tag , meanonly
gen top10 = (tag>=(`r(max)'-9))
sum n if tag==(`r(max)'-9), meanonly
replace top10 = 1 if n==`r(max)'
tab site top10 if top10!=0
contract site top10 if top10!=0, freq(count) percent(percentage)
gsort -count
drop top10
/*
site												count	percentage
C61: prostate										108		22.59
C18: colon											 63		13.18
C42: haematopoietic & reticuloendothelial systems	 60		12.55
C50: breast											 59		12.34
C15, C17, C21-C24, C26: other digestive organs		 45		 9.41
C30-C39: respiratory and intrathoracic organs		 36		 7.53
C25: pancreas										 34		 7.11
C53: cervix											 30		 6.28
C19-20: rectum										 23		 4.81
C54: uterus											 20		 4.18
*/
total count //478

** JC update: Save these results as a dataset for reporting
replace site=2 if site==19
replace site=3 if site==3
replace site=4 if site==10
replace site=5 if site==14
replace site=6 if site==7
replace site=7 if site==8
replace site=8 if site==6
replace site=9 if site==15
replace site=10 if site==4
replace site=11 if site==16
rename site cancer_site
gen year=1
rename count number
	expand 2 in 1
	replace cancer_site=1 in 11
	replace number=577 in 11
	replace percentage=100 in 11

label define cancer_site_lab 1 "all" 2 "prostate" 3 "colon" 4 "haem" 5 "female breast" 6 "stomach & other digest." 7 "lung & other resp." 8 "pancreas" 9 "cervix" 10 "rectum" 11 "uterus" ,modify
label values cancer_site cancer_site_lab
label define year_lab 1 "2013" 2 "2014" 3 "2015" 4 "2016" 5 "2017" 6 "2018" 7 "2019" 8 "2020" 9 "2021" ,modify
label values year year_lab
sort cancer_site
gen rpt_id = _n
save "`datapath'\version09\2-working\ASMRs_wpp_2013" ,replace
restore

** proportions for Table 1 using IARC's site groupings
//tab site sex ,m
//tab site , m
//tab site if sex==2 ,m // female
//tab site if sex==1 ,m // male

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
//tab site ,m
//JC 19may2022: use age5 population and groupings for distrate per IH's + NS' recommendation
//JC 13jun2022: Above correction not performed - will perform in a separate dofile when using IH's rate calculation method
merge m:m sex age5 using "`datapath'\version09\2-working\pop_wpp_2013-5"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                             6
        from master                         0  (_merge==1)
        from using                          6  (_merge==2)

    Matched                               577  (_merge==3)
    -----------------------------------------
*/
**drop if _merge==2 //do not drop these age groups as it skews pop_wpp 
** There are 6 unmatched records (_merge==2) since 2013 data doesn't have any cases of 0-4 male; 5-9 female; 15-19 female + male; 20-24 female + male


tab age5 ,m //none missing

gen case=1 if deathid!=. //do not generate case for missing age group 15-24 as it skews case total
gen pfu=1 // for % year if not whole year collected; not done for cancer

list deathid sex age5 if _merge==2
list deathid sex age5 if _merge==2 ,nolabel

list deathid sex age5 if age5==1 & sex==2|age5==2 & sex==1|age5==4 & (sex==1|sex==2)|age5==5 & (sex==1|sex==2)
replace case=0 if age5==1 & sex==2|age5==2 & sex==1|age5==4 & (sex==1|sex==2)|age5==5 & (sex==1|sex==2) //6 changes

** SF requested by email & WhatsApp on 07-Jan-2020 age and sex specific rates for top 10 cancers
/*
What is age-specific mortality rate? 
Age-specific rates provide information on the mortality of a particular event in an age group relative to the total number of people at risk of that event in the same age group.

What is age-standardised mortality rate?
The age-standardized mortality rate is the summary rate that would have been observed, given the schedule of age-specific rates, in a population with the age composition of some reference population, often called the standard population.
*/
** AGE + SEX
preserve
collapse (sum) case (mean) pop_wpp, by(pfu age5 sex site)
gen mortrate=case/pop_wpp*100000
drop if site!=19 & site!=3 & site!=10 & site!=14 ///
		& site!=7 & site!=8 & site!=6 ///
		& site!=15 & site!=4 & site!=16
//by sex,sort: tab age5 mortrate ,m
sort site age5 sex
//list mortrate age5 sex
//list mortrate age5 sex if site==13

format mortrate %04.2f
gen year=2013
rename site cancer_site
rename mortrate age_specific_rate
drop pfu case pop_wpp
order year cancer_site sex age5 age_specific_rate
save "`datapath'\version09\2-working\2013_top10mort_age+sex_rates" ,replace
restore

** AGE
preserve
collapse (sum) case (mean) pop_wpp, by(pfu age5 site)
gen mortrate=case/pop_wpp*100000
drop if site!=19 & site!=3 & site!=10 & site!=14 ///
		& site!=7 & site!=8 & site!=6 ///
		& site!=15 & site!=4 & site!=16
//by sex,sort: tab age5 mortrate ,m
sort site age5
//list mortrate age5 sex
//list mortrate age5 sex if site==13

format mortrate %04.2f
gen year=2013
rename site cancer_site
rename mortrate age_specific_rate
drop pfu case pop_wpp
order year cancer_site age5 age_specific_rate
save "`datapath'\version09\2-working\2013_top10mort_age_rates" ,replace
restore

** Check for missing age as these would need to be added to the median group for that site when assessing ASMRs to prevent creating an outlier
count if age==.|age==999 //6

list site age age5 if age==.|age==999 //these are missing age5 so no change needed

** Below saved in pathway: 
//X:\The University of the West Indies\DataGroup - repo_data\data_p117\version09\2-working\WPP_population by sex_2013.txt
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
//save "`datapath'\version09\2-working\2013 wpp_pop_age5" ,replace
//export delimited pop_wpp age5 if sex==1 using "`datapath'\version09\2-working\2013 wpp_pop_age5.txt", nolabel replace
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
  |  577   284294   202.96    124.60   114.09   135.91     5.49 |
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
gen percent=number/577*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2013"
replace cancer_site=1 if cancer_site==.
replace year=1 if year==.
gen asmr_id="all" if rpt_id==.
replace rpt_id=1 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==1 & asmr_id==""
drop asmr_id
save "`datapath'\version09\2-working\ASMRs_wpp_2013" ,replace
restore

** PROSTATE
tab pop_wpp age5 if site==19 //male

preserve
	drop if age5==.
	keep if site==19 // 
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings:  
	** M 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,40-44
	expand 2 in 1
	replace sex=2 in 11
	replace age5=1 in 11
	replace case=0 in 11
	replace pop_wpp=(8231) in 11
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 12
	replace age5=2 in 12
	replace case=0 in 12
	replace pop_wpp=(9416) in 12
	sort age5
	
	expand 2 in 1
	replace sex=2 in 13
	replace age5=3 in 13
	replace case=0 in 13
	replace pop_wpp=(9805) in 13
	sort age5
	
	expand 2 in 1
	replace sex=2 in 14
	replace age5=4 in 14
	replace case=0 in 14
	replace pop_wpp=(9599) in 14
	sort age5
	
	expand 2 in 1
	replace sex=2 in 15
	replace age5=5 in 15
	replace case=0 in 15
	replace pop_wpp=(9351) in 15
	sort age5
	
	expand 2 in 1
	replace sex=2 in 16
	replace age5=6 in 16
	replace case=0 in 16
	replace pop_wpp=(9190) in 16
	sort age5
	
	expand 2 in 1
	replace sex=2 in 17
	replace age5=7 in 17
	replace case=0 in 17
	replace pop_wpp=(9365) in 17
	sort age5
	
	expand 2 in 1
	replace sex=2 in 18
	replace age5=8 in 18
	replace case=0 in 18
	replace pop_wpp=(9585) in 18
	sort age5
			
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD pop_wppN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  108   136769   78.97     46.33    37.69    56.64     4.69 |
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
gen percent=number/577*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2013"
replace cancer_site=2 if cancer_site==.
replace year=1 if year==.
gen asmr_id="prost" if rpt_id==.
replace rpt_id=2 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==2 & asmr_id==""
drop asmr_id
save "`datapath'\version09\2-working\ASMRs_wpp_2013" ,replace
restore


** COLON 
tab pop_wpp age5 if site==3 & sex==1 //female
tab pop_wpp age5 if site==3 & sex==2 //male

preserve
	drop if age5==.
	keep if site==3
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings: 
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39
	** F   40-44
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=1 in 20
	replace case=0 in 20
	replace pop_wpp=(8008) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=2 in 21
	replace case=0 in 21
	replace pop_wpp=(8984) in 21
	sort age5

	expand 2 in 1
	replace sex=1 in 22
	replace age5=3 in 22
	replace case=0 in 22
	replace pop_wpp=(9315) in 22
	sort age5

	expand 2 in 1
	replace sex=1 in 23
	replace age5=4 in 23
	replace case=0 in 23
	replace pop_wpp=(9409) in 23
	sort age5

	expand 2 in 1
	replace sex=1 in 24
	replace age5=5 in 24
	replace case=0 in 24
	replace pop_wpp=(9354) in 24
	sort age5

	expand 2 in 1
	replace sex=1 in 25
	replace age5=6 in 25
	replace case=0 in 25
	replace pop_wpp=(9413) in 25
	sort age5

	expand 2 in 1
	replace sex=1 in 26
	replace age5=7 in 26
	replace case=0 in 26
	replace pop_wpp=(9800) in 26
	sort age5

	expand 2 in 1
	replace sex=1 in 27
	replace age5=8 in 27
	replace case=0 in 27
	replace pop_wpp=(10067) in 27
	sort age5

	expand 2 in 1
	replace sex=1 in 28
	replace age5=9 in 28
	replace case=0 in 28
	replace pop_wpp=(10665) in 28
	sort age5
		
	expand 2 in 1
	replace sex=2 in 29
	replace age5=1 in 29
	replace case=0 in 29
	replace pop_wpp=(8231) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=2 in 30
	replace case=0 in 30
	replace pop_wpp=(9416) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=3 in 31
	replace case=0 in 31
	replace pop_wpp=(9805) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=4 in 32
	replace case=0 in 32
	replace pop_wpp=(9599) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=5 in 33
	replace case=0 in 33
	replace pop_wpp=(9351) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=6 in 34
	replace case=0 in 34
	replace pop_wpp=(9190) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=7 in 35
	replace case=0 in 35
	replace pop_wpp=(9365) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=8 in 36
	replace case=0 in 36
	replace pop_wpp=(9585) in 36
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
  |   63   284294   22.16     12.98     9.86    16.93     1.74 |
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
gen percent=number/577*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2013"
replace cancer_site=3 if cancer_site==.
replace year=1 if year==.
gen asmr_id="colon" if rpt_id==.
replace rpt_id=3 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==3 & asmr_id==""
drop asmr_id
save "`datapath'\version09\2-working\ASMRs_wpp_2013" ,replace
restore

** HAEM.
tab pop_wpp age5 if site==10 & sex==1 //female
tab pop_wpp age5 if site==10 & sex==2 //male

preserve
	drop if age5==.
	keep if site==10
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings: 
	** M&F 5-9,15-19,20-24
	** M   0-4,10-14,30-34
	
	expand 2 in 1
	replace sex=1 in 28
	replace age5=2 in 28
	replace case=0 in 28
	replace pop_wpp=(8984) in 28
	sort age5
	
	expand 2 in 1
	replace sex=1 in 29
	replace age5=4 in 29
	replace case=0 in 29
	replace pop_wpp=(9409) in 29
	sort age5
	
	expand 2 in 1
	replace sex=1 in 30
	replace age5=5 in 30
	replace case=0 in 30
	replace pop_wpp=(9354) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=1 in 31
	replace case=0 in 31
	replace pop_wpp=(8231) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=2 in 32
	replace case=0 in 32
	replace pop_wpp=(9416) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=3 in 33
	replace case=0 in 33
	replace pop_wpp=(9805) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=4 in 34
	replace case=0 in 34
	replace pop_wpp=(9599) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=5 in 35
	replace case=0 in 35
	replace pop_wpp=(9351) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=7 in 36
	replace case=0 in 36
	replace pop_wpp=(9365) in 36
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR ALL HAEM. CANCERS (M&F)- STD TO WHO WORLD pop_wppN 
/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   60   284294   21.10     15.13    11.33    19.85     2.11 |
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
gen percent=number/577*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2013"
replace cancer_site=4 if cancer_site==.
replace year=1 if year==.
gen asmr_id="Haem." if rpt_id==.
replace rpt_id=4 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==4 & asmr_id==""
drop asmr_id
save "`datapath'\version09\2-working\ASMRs_wpp_2013" ,replace
restore

** BREAST
tab pop_wpp age5 if site==14 & sex==1 //female
tab pop_wpp age5 if site==14 & sex==2 //male

preserve
	drop if sex==2
	drop if age5==.
	keep if site==14 // breast only
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex

	** now we have to add in the cases and pop_wppns for the missings:  
	** F 0-4,5-9,10-14,15-19,20-24,25-29
	expand 2 in 1
	replace sex=1 in 13
	replace age5=1 in 13
	replace case=0 in 13
	replace pop_wpp=(8008) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=2 in 14
	replace case=0 in 14
	replace pop_wpp=(8984) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=3 in 15
	replace case=0 in 15
	replace pop_wpp=(9315) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=4 in 16
	replace case=0 in 16
	replace pop_wpp=(9409) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=5 in 17
	replace case=0 in 17
	replace pop_wpp=(9354) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=6 in 18
	replace case=0 in 18
	replace pop_wpp=(9413) in 18
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
  |   57   147525   38.64     25.12    18.64    33.31     3.62 |
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
gen percent=number/577*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2013"
replace cancer_site=5 if cancer_site==.
replace year=1 if year==.
gen asmr_id="fem.breast" if rpt_id==.
replace rpt_id=5 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==5 & asmr_id==""
drop asmr_id
save "`datapath'\version09\2-working\ASMRs_wpp_2013" ,replace
restore

** STOMACH + OTH.DIGEST.
tab pop_wpp age5 if site==7 & sex==1 //female
tab pop_wpp age5 if site==7 & sex==2 //male

preserve
	drop if age5==.
	keep if site==7
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings: 
	** M&F  0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39,40-44
	** F 	50-54,55-59,70-74
	** M	75-79,85+
	expand 2 in 1
	replace sex=1 in 17
	replace age5=1 in 17
	replace case=0 in 17
	replace pop_wpp=(8008) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=2 in 18
	replace case=0 in 18
	replace pop_wpp=(8984) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=3 in 19
	replace case=0 in 19
	replace pop_wpp=(9315) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=4 in 20
	replace case=0 in 20
	replace pop_wpp=(9409) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=5 in 21
	replace case=0 in 21
	replace pop_wpp=(9354) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=6 in 22
	replace case=0 in 22
	replace pop_wpp=(9413) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=7 in 23
	replace case=0 in 23
	replace pop_wpp=(9800) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=8 in 24
	replace case=0 in 24
	replace pop_wpp=(10067) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=9 in 25
	replace case=0 in 25
	replace pop_wpp=(10665) in 25
	sort age5
	
	expand 2 in 1
	replace sex=1 in 26
	replace age5=11 in 26
	replace case=0 in 26
	replace pop_wpp=(11165) in 26
	sort age5
	
	expand 2 in 1
	replace sex=1 in 27
	replace age5=12 in 27
	replace case=0 in 27
	replace pop_wpp=(9830) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=1 in 28
	replace case=0 in 28
	replace pop_wpp=(8231) in 28
	sort age5
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=2 in 29
	replace case=0 in 29
	replace pop_wpp=(9416) in 29
	sort age5

	expand 2 in 1
	replace sex=2 in 30
	replace age5=3 in 30
	replace case=0 in 30
	replace pop_wpp=(9805) in 30
	sort age5

	expand 2 in 1
	replace sex=2 in 31
	replace age5=4 in 31
	replace case=0 in 31
	replace pop_wpp=(9599) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=5 in 32
	replace case=0 in 32
	replace pop_wpp=(9351) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=6 in 33
	replace case=0 in 33
	replace pop_wpp=(9190) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=7 in 34
	replace case=0 in 34
	replace pop_wpp=(9365) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=8 in 35
	replace case=0 in 35
	replace pop_wpp=(9585) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=9 in 36
	replace case=0 in 36
	replace pop_wpp=(9888) in 36
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR STOMACH+OTH. CANCER (M&F)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   45   284294   15.83      9.32     6.70    12.76     1.48 |
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
gen percent=number/577*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2013"
replace cancer_site=6 if cancer_site==.
replace year=1 if year==.
gen asmr_id="stom+oth" if rpt_id==.
replace rpt_id=6 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==6 & asmr_id==""
drop asmr_id
save "`datapath'\version09\2-working\ASMRs_wpp_2013" ,replace
restore

** LUNG + OTH.THORA.
tab pop_wpp age5 if site==8 & sex==1 //female
tab pop_wpp age5 if site==8 & sex==2 //male

preserve
	drop if age5==.
	keep if site==8
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and pops for the missings: 
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,35-39,45-49
	** F   40-44,50-54,60-64
	** M   30-34
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=1 in 17
	replace case=0 in 17
	replace pop_wpp=(8008) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=2 in 18
	replace case=0 in 18
	replace pop_wpp=(8984) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=3 in 19
	replace case=0 in 19
	replace pop_wpp=(9315) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=4 in 20
	replace case=0 in 20
	replace pop_wpp=(9409) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=5 in 21
	replace case=0 in 21
	replace pop_wpp=(9354) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=6 in 22
	replace case=0 in 22
	replace pop_wpp=(9413) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=8 in 23
	replace case=0 in 23
	replace pop_wpp=(10067) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=9 in 24
	replace case=0 in 24
	replace pop_wpp=(10665) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=10 in 25
	replace case=0 in 25
	replace pop_wpp=(10773) in 25
	sort age5
	
	expand 2 in 1
	replace sex=1 in 26
	replace age5=11 in 26
	replace case=0 in 26
	replace pop_wpp=(11165) in 26
	sort age5
	
	expand 2 in 1
	replace sex=1 in 27
	replace age5=13 in 27
	replace case=0 in 27
	replace pop_wpp=(7947) in 27
	sort age5	
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=1 in 28
	replace case=0 in 28
	replace pop_wpp=(8231) in 28
	sort age5
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=2 in 29
	replace case=0 in 29
	replace pop_wpp=(9416) in 29
	sort age5

	expand 2 in 1
	replace sex=2 in 30
	replace age5=3 in 30
	replace case=0 in 30
	replace pop_wpp=(9805) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=4 in 31
	replace case=0 in 31
	replace pop_wpp=(9599) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=5 in 32
	replace case=0 in 32
	replace pop_wpp=(9351) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=6 in 33
	replace case=0 in 33
	replace pop_wpp=(9190) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=7 in 34
	replace case=0 in 34
	replace pop_wpp=(9365) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=8 in 35
	replace case=0 in 35
	replace pop_wpp=(9585) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=10 in 36
	replace case=0 in 36
	replace pop_wpp=(9801) in 36
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
  |   36   284294   12.66      8.12     5.62    11.49     1.44 |
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
gen percent=number/577*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2013"
replace cancer_site=7 if cancer_site==.
replace year=1 if year==.
gen asmr_id="lung+oth" if rpt_id==.
replace rpt_id=7 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==7 & asmr_id==""
drop asmr_id
save "`datapath'\version09\2-working\ASMRs_wpp_2013" ,replace
restore


** PANCREAS
tab pop_wpp age5 if site==6 & sex==1 //female
tab pop_wpp age5 if site==6 & sex==2 //male

preserve
	drop if age5==.
	keep if site==6
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings:
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,40-44
	** M   35-39,45-49,65-69

	expand 2 in 1
	replace sex=1 in 18
	replace age5=1 in 18
	replace case=0 in 18
	replace pop_wpp=(8008) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=2 in 19
	replace case=0 in 19
	replace pop_wpp=(8984) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=3 in 20
	replace case=0 in 20
	replace pop_wpp=(9315) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=4 in 21
	replace case=0 in 21
	replace pop_wpp=(9409) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=5 in 22
	replace case=0 in 22
	replace pop_wpp=(9354) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=6 in 23
	replace case=0 in 23
	replace pop_wpp=(9413) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=7 in 24
	replace case=0 in 24
	replace pop_wpp=(9800) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=9 in 25
	replace case=0 in 25
	replace pop_wpp=(10665) in 25
	sort age5
	
	expand 2 in 1
	replace sex=2 in 26
	replace age5=1 in 26
	replace case=0 in 26
	replace pop_wpp=(8231) in 26
	sort age5
	
	expand 2 in 1
	replace sex=2 in 27
	replace age5=2 in 27
	replace case=0 in 27
	replace pop_wpp=(9416) in 27
	sort age5

	expand 2 in 1
	replace sex=2 in 28
	replace age5=3 in 28
	replace case=0 in 28
	replace pop_wpp=(9805) in 28
	sort age5
	
	expand 2 in 1
	replace sex=2 in 29
	replace age5=4 in 29
	replace case=0 in 29
	replace pop_wpp=(9599) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=5 in 30
	replace case=0 in 30
	replace pop_wpp=(9351) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=6 in 31
	replace case=0 in 31
	replace pop_wpp=(9190) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=7 in 32
	replace case=0 in 32
	replace pop_wpp=(9365) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=8 in 33
	replace case=0 in 33
	replace pop_wpp=(9585) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=9 in 34
	replace case=0 in 34
	replace pop_wpp=(9888) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=10 in 35
	replace case=0 in 35
	replace pop_wpp=(9801) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=14 in 36
	replace case=0 in 36
	replace pop_wpp=(5388) in 36
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
  |   34   284294   11.96      7.44     5.08    10.65     1.36 |
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
gen percent=number/577*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2013"
replace cancer_site=8 if cancer_site==.
replace year=1 if year==.
gen asmr_id="panc" if rpt_id==.
replace rpt_id=8 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==8 & asmr_id==""
drop asmr_id
save "`datapath'\version09\2-working\ASMRs_wpp_2013" ,replace
restore

** CERVIX
tab pop_wpp age5 if site==15

preserve
	drop if age5==.
	keep if site==15
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings: 
	** F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39
	
	expand 2 in 1
	replace sex=1 in 11
	replace age5=1 in 11
	replace case=0 in 11
	replace pop_wpp=(8008) in 11
	sort age5
	
	expand 2 in 1
	replace sex=1 in 12
	replace age5=2 in 12
	replace case=0 in 12
	replace pop_wpp=(8984) in 12
	sort age5
	
	expand 2 in 1
	replace sex=1 in 13
	replace age5=3 in 13
	replace case=0 in 13
	replace pop_wpp=(9315) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=4 in 14
	replace case=0 in 14
	replace pop_wpp=(9409) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=5 in 15
	replace case=0 in 15
	replace pop_wpp=(9354) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=6 in 16
	replace case=0 in 16
	replace pop_wpp=(9413) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=7 in 17
	replace case=0 in 17
	replace pop_wpp=(9800) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=8 in 18
	replace case=0 in 18
	replace pop_wpp=(10067) in 18
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CERVIX (F)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   30   147525   20.34     12.20     8.07    18.01     2.43 |
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
gen percent=number/577*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2013"
replace cancer_site=9 if cancer_site==.
replace year=1 if year==.
gen asmr_id="cervix" if rpt_id==.
replace rpt_id=9 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==9 & asmr_id==""
drop asmr_id
save "`datapath'\version09\2-working\ASMRs_wpp_2013" ,replace
restore

** RECTUM
tab pop_wpp age5 if site==4 & sex==1 //female
tab pop_wpp age5 if site==4 & sex==2 //male

preserve
	drop if age5==.
	keep if site==4
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings: 
	** M&F 0-4,5-9,10-14,15-19,20-24,25-29,35-39,40-44,45-49
	** F   30-34,50-54,55-59,65-69
	** M   75-79
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=1 in 14
	replace case=0 in 14
	replace pop_wpp=(8008) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=2 in 15
	replace case=0 in 15
	replace pop_wpp=(8984) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=3 in 16
	replace case=0 in 16
	replace pop_wpp=(9315) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=4 in 17
	replace case=0 in 17
	replace pop_wpp=(9409) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=5 in 18
	replace case=0 in 18
	replace pop_wpp=(9354) in 18
	sort age5
	
	expand 2 in 1
	replace sex=1 in 19
	replace age5=6 in 19
	replace case=0 in 19
	replace pop_wpp=(9413) in 19
	sort age5
	
	expand 2 in 1
	replace sex=1 in 20
	replace age5=7 in 20
	replace case=0 in 20
	replace pop_wpp=(9800) in 20
	sort age5
	
	expand 2 in 1
	replace sex=1 in 21
	replace age5=8 in 21
	replace case=0 in 21
	replace pop_wpp=(10067) in 21
	sort age5
	
	expand 2 in 1
	replace sex=1 in 22
	replace age5=9 in 22
	replace case=0 in 22
	replace pop_wpp=(10665) in 22
	sort age5
	
	expand 2 in 1
	replace sex=1 in 23
	replace age5=10 in 23
	replace case=0 in 23
	replace pop_wpp=(10773) in 23
	sort age5
	
	expand 2 in 1
	replace sex=1 in 24
	replace age5=11 in 24
	replace case=0 in 24
	replace pop_wpp=(11165) in 24
	sort age5
	
	expand 2 in 1
	replace sex=1 in 25
	replace age5=12 in 25
	replace case=0 in 25
	replace pop_wpp=(9830) in 25
	sort age5
	
	expand 2 in 1
	replace sex=1 in 26
	replace age5=14 in 26
	replace case=0 in 26
	replace pop_wpp=(6329) in 26
	sort age5
	
	expand 2 in 1
	replace sex=2 in 27
	replace age5=1 in 27
	replace case=0 in 27
	replace pop_wpp=(8231) in 27
	sort age5
	
	expand 2 in 1
	replace sex=2 in 28
	replace age5=2 in 28
	replace case=0 in 28
	replace pop_wpp=(9416) in 28
	sort age5

	expand 2 in 1
	replace sex=2 in 29
	replace age5=3 in 29
	replace case=0 in 29
	replace pop_wpp=(9805) in 29
	sort age5
	
	expand 2 in 1
	replace sex=2 in 30
	replace age5=4 in 30
	replace case=0 in 30
	replace pop_wpp=(9599) in 30
	sort age5
	
	expand 2 in 1
	replace sex=2 in 31
	replace age5=5 in 31
	replace case=0 in 31
	replace pop_wpp=(9351) in 31
	sort age5
	
	expand 2 in 1
	replace sex=2 in 32
	replace age5=6 in 32
	replace case=0 in 32
	replace pop_wpp=(9190) in 32
	sort age5
	
	expand 2 in 1
	replace sex=2 in 33
	replace age5=8 in 33
	replace case=0 in 33
	replace pop_wpp=(9585) in 33
	sort age5
	
	expand 2 in 1
	replace sex=2 in 34
	replace age5=9 in 34
	replace case=0 in 34
	replace pop_wpp=(9888) in 34
	sort age5
	
	expand 2 in 1
	replace sex=2 in 35
	replace age5=10 in 35
	replace case=0 in 35
	replace pop_wpp=(9801) in 35
	sort age5
	
	expand 2 in 1
	replace sex=2 in 36
	replace age5=16 in 36
	replace case=0 in 36
	replace pop_wpp=(3138) in 36
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
  |   23   284294    8.09      4.53     2.76     7.18     1.07 |
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
gen percent=number/577*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2013"
replace cancer_site=10 if cancer_site==.
replace year=1 if year==.
gen asmr_id="rect" if rpt_id==.
replace rpt_id=10 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==10 & asmr_id==""
drop asmr_id
save "`datapath'\version09\2-working\ASMRs_wpp_2013" ,replace
restore


** UTERUS
tab pop_wpp age5 if site==16

preserve
	drop if age5==.
	keep if site==16
	
	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	sort age sex
	** now we have to add in the cases and pop_wppns for the missings: 
	** F 0-4,5-9,10-14,15-19,20-24,25-29,30-34,35-39
	expand 2 in 1
	replace sex=1 in 11
	replace age5=1 in 11
	replace case=0 in 11
	replace pop_wpp=(8008) in 11
	sort age5
	
	expand 2 in 1
	replace sex=1 in 12
	replace age5=2 in 12
	replace case=0 in 12
	replace pop_wpp=(8984) in 12
	sort age5
	
	expand 2 in 1
	replace sex=1 in 13
	replace age5=3 in 13
	replace case=0 in 13
	replace pop_wpp=(9315) in 13
	sort age5
	
	expand 2 in 1
	replace sex=1 in 14
	replace age5=4 in 14
	replace case=0 in 14
	replace pop_wpp=(9409) in 14
	sort age5
	
	expand 2 in 1
	replace sex=1 in 15
	replace age5=5 in 15
	replace case=0 in 15
	replace pop_wpp=(9354) in 15
	sort age5
	
	expand 2 in 1
	replace sex=1 in 16
	replace age5=6 in 16
	replace case=0 in 16
	replace pop_wpp=(9413) in 16
	sort age5
	
	expand 2 in 1
	replace sex=1 in 17
	replace age5=7 in 17
	replace case=0 in 17
	replace pop_wpp=(9800) in 17
	sort age5
	
	expand 2 in 1
	replace sex=1 in 18
	replace age5=8 in 18
	replace case=0 in 18
	replace pop_wpp=(10067) in 18
	sort age5
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
total pop_wpp

distrate case pop_wpp using "`datapath'\version09\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR UTERUS (F)- STD TO WHO WORLD pop_wppN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   20   147525   13.56      8.53     5.12    13.68     2.08 |
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
gen percent=number/577*100
replace percent=round(percent,0.01)

append using "`datapath'\version09\2-working\ASMRs_wpp_2013"
replace cancer_site=11 if cancer_site==.
replace year=1 if year==.
gen asmr_id="uterus" if rpt_id==.
replace rpt_id=11 if rpt_id==.
bysort rpt_id (asmr_id): replace percentage = percentage[_n-1] if missing(percentage)
order cancer_site number percent asmr ci_lower ci_upper year
sort cancer_site asmr
drop if cancer_site==11 & asmr_id==""
drop asmr_id rpt_id
format asmr %04.2f
format percentage %04.1f
save "`datapath'\version09\2-working\ASMRs_wpp_2013" ,replace
restore

label data "BNR MORTALITY rates 2013"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version09\3-output\2013_analysis mort_wpp" ,replace
note: TS This dataset includes patients with multiple eligible cancer causes of death; used WPP population
