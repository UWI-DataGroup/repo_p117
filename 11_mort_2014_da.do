** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			11_mort_2014_da.do
    //  project:				BNR
    //  analysts:				Jacqueline CAMPBELL
    //  date first created      28-MAR-2019
    // 	date last modified	    28-MAR-2019
    //  algorithm task			Generate stats for:
    //                          Mortality Rates by (IARC) site:
    //							  - ASR(ASMR): all sites, world
    // 							  - ASR(ASMR): by site, by sex (world)
    //								(correct survival in dofile 8)
    //  status                  Completed
    //  objectve                To have one dataset with cleaned, grouped and analysed 2014 data for 2014 cancer report.

    ** DO FILE BASED ON
    * AMC Rose code for BNR Cancer 2008 annual report

    ** General algorithm set-up
    version 15
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
    log using "`logpath'\11_mort_2014_da.smcl", replace
** HEADER -----------------------------------------------------

** Load the dataset
use "`datapath'\version01\2-working\2014_mort_dc", replace


count // 651 cancer deaths in 2014
tab age_10 sex ,m
tab siteiarc ,m

** proportions for Table 7 using IARC's site groupings
tab siteiarc sex ,m
tab siteiarc , m
tab siteiarc if sex==2 ,m // female
tab siteiarc if sex==1 ,m // male


** For annual report - Section 4: Mortality - Table 7a
** Below top 10 code added by JC for 2014
** All sites excl. O&U, insitu, non-reportable skin cancers - using IARC CI5's site groupings
preserve
drop if siteiarc==25|siteiarc==61|siteiarc==64 //64 obs deleted
bysort siteiarc: gen n=_N
bysort n siteiarc: gen tag=(_n==1)
replace tag = sum(tag)
sum tag , meanonly
gen top10 = (tag>=(`r(max)'-9))
sum n if tag==(`r(max)'-9), meanonly
replace top10 = 1 if n==`r(max)'
tab siteiarc top10 if top10!=0
contract siteiarc top10 if top10!=0, freq(count) percent(percentage)
gsort -count
drop top10
/*
siteiarc	                                count	percentage
Prostate (C61)	                            150	    32.33
Breast (C50)	                            72	    15.52
Colon (C18)	                                71	    15.30
Lung (incl. trachea and bronchus) (C33-34)	41	    8.84
Pancreas (C25)	                            29	    6.25
Multiple myeloma (C90)	                    22	    4.74
Corpus uteri (C54)	                        21	    4.53
Stomach (C16)	                            20	    4.31
Rectum (C19-20)	                            20	    4.31
Non-Hodgkin lymphoma (C82-86,C96)	        18	    3.88
*/
total count //464
restore


** All sites excl. O&U, non-reportable skin cancers - using IARC CI5's site groupings COMBINE cervix & CIN 3
** THIS USED IN ANNUAL REPORT TABLE 1 - CHECKING WHERE IN LIST 2014 TOP 10 APPEARS IN LIST FOR 2008
** This list requested by NS in similar format to CMO's report for top 10 comparisons with current & previous years
** Screenshot this data from Stata data editor into annual report tables document.
preserve
drop if (siteiarc==25|siteiarc>60) & siteiarc!=64 //64 deleted
replace siteiarc=32 if siteiarc==32|siteiarc==64 //0 changes
tab siteiarc ,m
contract siteiarc, freq(count) percent(percentage)
gsort -count
/*

                      IARC CI5-XI sites |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                        Tongue (C01-02) |          4        0.68        0.68
                         Mouth (C03-06) |          2        0.34        1.02
                Salivary gland (C07-08) |          1        0.17        1.19
                           Tonsil (C09) |          1        0.17        1.36
                 Other oropharynx (C10) |          5        0.85        2.21
                      Nasopharynx (C11) |          3        0.51        2.73
                   Hypopharynx (C12-13) |          4        0.68        3.41
              Pharynx unspecified (C14) |          1        0.17        3.58
                       Oesophagus (C15) |         10        1.70        5.28
                          Stomach (C16) |         20        3.41        8.69
                  Small intestine (C17) |          2        0.34        9.03
                            Colon (C18) |         71       12.10       21.12
                        Rectum (C19-20) |         20        3.41       24.53
                             Anus (C21) |          1        0.17       24.70
                            Liver (C22) |          9        1.53       26.24
              Gallbladder etc. (C23-24) |          9        1.53       27.77
                         Pancreas (C25) |         29        4.94       32.71
            Nose, sinuses etc. (C30-31) |          1        0.17       32.88
                           Larynx (C32) |          1        0.17       33.05
Lung (incl. trachea and bronchus) (C33- |         41        6.98       40.03
                          Bone (C40-41) |          2        0.34       40.37
                 Melanoma of skin (C43) |          1        0.17       40.55
                     Mesothelioma (C45) |          1        0.17       40.72
                           Breast (C50) |         72       12.27       52.98
                           Vagina (C52) |          2        0.34       53.32
                     Cervix uteri (C53) |         12        2.04       55.37
                     Corpus uteri (C54) |         21        3.58       58.94
               Uterus unspecified (C55) |          3        0.51       59.45
                            Ovary (C56) |          1        0.17       59.63
                            Penis (C60) |          2        0.34       59.97
                         Prostate (C61) |        150       25.55       85.52
                           Kidney (C64) |         11        1.87       87.39
                          Bladder (C67) |         13        2.21       89.61
                          Thyroid (C73) |          3        0.51       90.12
                 Hodgkin lymphoma (C81) |          2        0.34       90.46
      Non-Hodgkin lymphoma (C82-86,C96) |         18        3.07       93.53
     Immunoproliferative diseases (C88) |          1        0.17       93.70
                 Multiple myeloma (C90) |         22        3.75       97.44
               Lymphoid leukaemia (C91) |          5        0.85       98.30
             Myeloid leukaemia (C92-94) |          4        0.68       98.98
            Leukaemia unspecified (C95) |          3        0.51       99.49
     Myeloproliferative disorders (MPD) |          2        0.34       99.83
       Myselodysplastic syndromes (MDS) |          1        0.17      100.00
----------------------------------------+-----------------------------------
                                  Total |        587      100.00
*/
total count //587 (O&U=57; NMSCs=7)
restore

** proportions for Table 1 using IARC's site groupings
tab siteiarc sex ,m
tab siteiarc , m
tab siteiarc if sex==2 ,m // female
tab siteiarc if sex==1 ,m // male

************************************************************
* 4.3 MR age-standardised to WHO world popn - ALL sites
************************************************************

**********************************************************************************
** ASMR and 95% CI for Table 1 using AR's site groupings - using WHO World popn **
**********************************************************************************

** No need to recode sex as already 1=female; 2=male

********************************************************************
* (2.4c) MR age-standardised to WHO world popn - ALL TUMOURS
********************************************************************
** Using WHO World Standard Population
tab siteiarc ,m

drop _merge
merge m:m sex age_10 using "`datapath'\version01\2-working\bb2010_10-2"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                             2
        from master                         0  (_merge==1)
        from using                          2  (_merge==2)

    matched                               651  (_merge==3)
    -----------------------------------------
*/
**drop if _merge==2 //do not drop these age groups as it skews population 
** There are 2 unmatched records (_merge==2) since 2014 data doesn't have any cases of females and males with age range 15-24
**	age_10	site  dup	sex	 pfu	age45	age55	pop_bb	_merge
** 0-14	  .     .	female .	0-44	0-54	26755	using only (2)
** 0-14	  .     .	male   .	0-44	0-54	28005	using only (2)

tab age_10 ,m //none missing

gen case=1 if deathid!=. //do not generate case for missing age group 0-14 as it skews case total
gen pfu=1 // for % year if not whole year collected; not done for cancer

list deathid sex age_10 if age_10==1 // age range 0-14 for female & male: change case=0 for age_10=1

tab pop age_10  if sex==1 //female
tab pop age_10  if sex==2 //male

/*
** Next, MRs for all tumours
preserve
	* crude rate: point estimate
	gen cancerpop = 1
	label define crude 1 "cancer events" ,modify
	label values cancerpop crude
	collapse (sum) case (mean) pop_bb , by(pfu cancerpop age_10 sex)
	collapse (sum) case pop_bb , by(pfu cancerpop)
	
	** Weighting for incidence calculation IF period is NOT exactly one year
	** (where it is 1 year, pfu=1)
	rename pop_bb fpop_bb
	gen pop_bb = fpop_bb * pfu
	
	gen mr = (case / pop_bb) * (10^5)
	label var mr "Crude Mortality Rate"

	* Standard Error
	gen se = ( (case^(1/2)) / pop_bb) * (10^5)

	* Lower 95% CI
	gen lower = ( (0.5 * invchi2(2*case, (0.05/2))) / pop_bb ) * (10^5)
	* Upper 95% CI
	gen upper = ( (0.5 * invchi2(2*(case+1), (1-(0.05/2)))) / pop_bb ) * (10^5)

	* Display the results
	label var pop_bb "P-Y"
	label var case "Cases"
	label var mr "MR"
	label var se "SE"
	label var lower "95% lo"
	label var upper "95% hi"
	foreach var in mr se lower upper {
			format `var' %8.2f
			}
	list case pop_bb mr se lower upper , noobs table
** THIS IS FOR ALL TUMOURS - CRUDE MR
/*
  +--------------------------------------------------+
  | case   pop_bb       mr      se    lower    upper |
  |--------------------------------------------------|
  |  651   223054   291.86   11.44   269.87   315.16 |
  +--------------------------------------------------+
*/
restore
*/

** Next, IRs for all tumours
tab pop age_10
tab age_10 ,m //none missing
preserve
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
		
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR ALL TUMOURS - STD TO WHO WORLD POPN 
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  651   277814   234.33    148.85   137.16   161.35     6.10 |
  +-------------------------------------------------------------+
*/
restore

** PROSTATE
tab pop age_10 if siteiarc==39 //male

preserve
	drop if age_10==.
	keep if siteiarc==39 // 
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: M 0-14,15-24,25-34,35-44
		
	expand 2 in 1
	replace sex=2 in 6
	replace age_10=1 in 6
	replace case=0 in 6
	replace pop_bb=(28005)  in 6
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 7
	replace age_10=2 in 7
	replace case=0 in 7
	replace pop_bb=(18510)  in 7
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=3 in 8
	replace case=0 in 8
	replace pop_bb=(18465) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=4 in 9
	replace case=0 in 9
	replace pop_bb=(19550) in 9
	sort age_10
			
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD POPN 

/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  150   133011   112.77     74.01    62.45    87.28     6.19 |
  +-------------------------------------------------------------+
*/
restore


** PROSTATE - added in female population to check ASMR against IARC rate as large difference in rates
tab pop age_10 if siteiarc==39 //male

preserve
	drop if age_10==.
	keep if siteiarc==39 // 
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: M 0-14,15-24,25-34,35-44
		
	expand 2 in 1
	replace sex=2 in 6
	replace age_10=1 in 6
	replace case=0 in 6
	replace pop_bb=(28005)  in 6
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 7
	replace age_10=2 in 7
	replace case=0 in 7
	replace pop_bb=(18510)  in 7
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=3 in 8
	replace case=0 in 8
	replace pop_bb=(18465) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=4 in 9
	replace case=0 in 9
	replace pop_bb=(19550) in 9
	sort age_10

	expand 2 in 1
	replace sex=1 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_bb=(26755) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_bb=(18530) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=3 in 12
	replace case=0 in 12
	replace pop_bb=(19410) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=4 in 13
	replace case=0 in 13
	replace pop_bb=(21080) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=5 in 14
	replace case=0 in 14
	replace pop_bb=(21945) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=6 in 15
	replace case=0 in 15
	replace pop_bb=(15940) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=7 in 16
	replace case=0 in 16
	replace pop_bb=(10515) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=8 in 17
	replace case=0 in 17
	replace pop_bb=(7240) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_bb=(3388) in 18
	sort age_10

	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  150   277814   53.99     29.70    24.94    35.22     2.55 |
  +------------------------------------------------------------+
*/
restore


** PROSTATE - used Segi's WHO population (1960) to check ASMR against IARC rate as large difference in rates
** Create different world stnd pop based on Segi 1960 to re-calculate prostate ASMR due to difference in rate reported for B'dos by WHO
display `"{browse "http://www-dep.iarc.fr/WHOdb/WHOdb.htm":WHO Cancer Mortality Database-Glossary of Terms}"'
tab pop age_10 if siteiarc==39 //male

preserve
	drop if age_10==.
	keep if siteiarc==39 // 
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: M 0-14,15-24,25-34,35-44
		
	expand 2 in 1
	replace sex=2 in 6
	replace age_10=1 in 6
	replace case=0 in 6
	replace pop_bb=(28005)  in 6
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 7
	replace age_10=2 in 7
	replace case=0 in 7
	replace pop_bb=(18510)  in 7
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=3 in 8
	replace case=0 in 8
	replace pop_bb=(18465) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=4 in 9
	replace case=0 in 9
	replace pop_bb=(19550) in 9
	sort age_10
			
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "`datapath'\version01\2-working\whosegi2000_10-2", 	///	
		         stand(age_10) popstand(pop_segi) mult(100000) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD POPN: SEGI 1960 

/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  150   133011   112.77     58.78    49.28    69.83     5.10 |
  +-------------------------------------------------------------+
*/
restore


** BREAST
tab pop age_10 if siteiarc==29 & sex==1 //female
tab pop age_10 if siteiarc==29 & sex==2 //male

preserve
	drop if age_10==.
	keep if siteiarc==29 // breast only
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex

	** now we have to add in the cases and popns for the missings: 
	** F 0-14,15-24
	** M 0-14,15-24,25-34,35-44,45-54,55-64,65-74,85+
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_bb=(26755) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=2 in 10
	replace case=0 in 10
	replace pop_bb=(18530) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_bb=(28005) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_bb=(18510) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_bb=(18465) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=4 in 14
	replace case=0 in 14
	replace pop_bb=(19550) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=5 in 15
	replace case=0 in 15
	replace pop_bb=(19470) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=6 in 16
	replace case=0 in 16
	replace pop_bb=(14195) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=7 in 17
	replace case=0 in 17
	replace pop_bb=(8315) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_bb=(1666) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BC (M&F) - STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   72   277814   25.92     17.68    13.70    22.53     2.19 |
  +------------------------------------------------------------+

*/
restore


** COLON 
tab pop age_10 if siteiarc==13 & sex==1 //female
tab pop age_10 if siteiarc==13 & sex==2 //male

preserve
	drop if age_10==.
	keep if siteiarc==13
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24,25-34
	** F 35-44
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_bb=(26755) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 13
	replace age_10=1 in 13
	replace case=0 in 13
	replace pop_bb=(28005) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_bb=(18530) in 14
	sort age_10

	expand 2 in 1
	replace sex=2 in 15
	replace age_10=2 in 15
	replace case=0 in 15
	replace pop_bb=(18510) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_bb=(19410) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=3 in 17
	replace case=0 in 17
	replace pop_bb=(18465) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=4 in 18
	replace case=0 in 18
	replace pop_bb=(21080) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR COLON CANCER (M&F)- STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   71   277814   25.56     16.28    12.59    20.80     2.03 |
  +------------------------------------------------------------+
*/
restore


** LUNG
tab pop age_10 if siteiarc==21 & sex==1 //female
tab pop age_10 if siteiarc==21 & sex==2 //male

preserve
	drop if age_10==.
	keep if siteiarc==21
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24
	** M 25-34,35-44
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=1 in 13
	replace case=0 in 13
	replace pop_bb=(26755) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=1 in 14
	replace case=0 in 14
	replace pop_bb=(28005) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=2 in 15
	replace case=0 in 15
	replace pop_bb=(18530) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=2 in 16
	replace case=0 in 16
	replace pop_bb=(18510) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=3 in 17
	replace case=0 in 17
	replace pop_bb=(18465) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=4 in 18
	replace case=0 in 18
	replace pop_bb=(19550) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR LUNG CANCER (M&F)- STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   41   277814   14.76     10.19     7.24    14.03     1.67 |
  +------------------------------------------------------------+
*/
restore

** PANCREAS
tab pop age_10 if siteiarc==18 & sex==1 //female
tab pop age_10 if siteiarc==18 & sex==2 //male

preserve
	drop if age_10==.
	keep if siteiarc==18
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,25-34,45-54
	** M 15-24
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_bb=(26755) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 13
	replace age_10=1 in 13
	replace case=0 in 13
	replace pop_bb=(28005) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_bb=(18510) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bb=(19410) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_bb=(18465) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=5 in 17
	replace case=0 in 17
	replace pop_bb=(21945) in 17
	sort age_10
	
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=5 in 18
	replace case=0 in 18
	replace pop_bb=(19470) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR PANCREATIC CANCER (M&F)- STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   29   277814   10.44      6.86     4.50    10.11     1.37 |
  +------------------------------------------------------------+
*/
restore

** MULTIPLE MYELOMA
tab pop age_10 if siteiarc==55 & sex==1 //female
tab pop age_10 if siteiarc==55 & sex==2 //male

preserve
	drop if age_10==.
	keep if siteiarc==55
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24,25-34,35-44
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_bb=(26755) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=1 in 12
	replace case=0 in 12
	replace pop_bb=(28005) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bb=(18530) in 13
	sort age_10
		
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=2 in 14
	replace case=0 in 14
	replace pop_bb=(18510) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bb=(19410) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=3 in 16
	replace case=0 in 16
	replace pop_bb=(18465) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_bb=(21080) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=4 in 18
	replace case=0 in 18
	replace pop_bb=(19550) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR MULTIPLE MYELOMA (M&F)- STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   22   277814    7.92      5.30     3.29     8.20     1.20 |
  +------------------------------------------------------------+
*/
restore


** CORPUS UTERI
tab pop age_10 if siteiarc==33

preserve
	drop if age_10==.
	keep if siteiarc==33
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-14,15-24,25-34,45-54
	
	expand 2 in 1
	replace sex=1 in 6
	replace age_10=1 in 6
	replace case=0 in 6
	replace pop_bb=(26755) in 6
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=2 in 7
	replace case=0 in 7
	replace pop_bb=(18530) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=3 in 8
	replace case=0 in 8
	replace pop_bb=(19410) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=5 in 9
	replace case=0 in 9
	replace pop_bb=(21945) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CORPUS UTERI (WOMEN)- STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   21   144803   14.50      9.42     5.71    14.83     2.23 |
  +------------------------------------------------------------+
*/
restore


** RECTUM
tab pop age_10 if siteiarc==14 & sex==1 //female
tab pop age_10 if siteiarc==14 & sex==2 //male

preserve
	drop if age_10==.
	keep if siteiarc==14
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24,35-44
	** F 25-34,65-74
	** M 45-54,85+
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_bb=(26755) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_bb=(28005) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_bb=(18530) in 11
	sort age_10
		
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_bb=(18510) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_bb=(19410) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=4 in 14
	replace case=0 in 14
	replace pop_bb=(21080) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_bb=(19550) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=5 in 16
	replace case=0 in 16
	replace pop_bb=(19470) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=7 in 17
	replace case=0 in 17
	replace pop_bb=(10515) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=9 in 18
	replace case=0 in 18
	replace pop_bb=(1666) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR RECTAL CANCER (M&F)- STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   20   277814    7.20      4.81     2.87     7.66     1.17 |
  +------------------------------------------------------------+
*/
restore


** STOMACH
tab pop age_10 if siteiarc==11 & sex==1 //female
tab pop age_10 if siteiarc==11 & sex==2 //male

preserve
	drop if age_10==.
	keep if siteiarc==11
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24,25-34,35-44,45-54
	** F 65-74
	** M 55-64
	
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_bb=(26755) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_bb=(28005) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=2 in 9
	replace case=0 in 9
	replace pop_bb=(18530) in 9
	sort age_10
		
	expand 2 in 1
	replace sex=2 in 10
	replace age_10=2 in 10
	replace case=0 in 10
	replace pop_bb=(18510) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 11
	replace age_10=3 in 11
	replace case=0 in 11
	replace pop_bb=(19410) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 12
	replace age_10=3 in 12
	replace case=0 in 12
	replace pop_bb=(18465) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=4 in 13
	replace case=0 in 13
	replace pop_bb=(21080) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=4 in 14
	replace case=0 in 14
	replace pop_bb=(19550) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=5 in 15
	replace case=0 in 15
	replace pop_bb=(21945) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 16
	replace age_10=5 in 16
	replace case=0 in 16
	replace pop_bb=(19470) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=6 in 17
	replace case=0 in 17
	replace pop_bb=(14195) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=7 in 18
	replace case=0 in 18
	replace pop_bb=(10515) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR STOMACH CANCER (M&F)- STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   20   277814    7.20      4.01     2.39     6.47     0.99 |
  +------------------------------------------------------------+
*/
restore


** NON-HODGKIN LYMPHOMA
tab pop age_10 if siteiarc==53 & sex==1 //female
tab pop age_10 if siteiarc==53 & sex==2 //male

preserve
	drop if age_10==.
	keep if siteiarc==53
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,25-34
	** F 15-24,35-44,45-54,55-64,65-74
	
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=1 in 10
	replace case=0 in 10
	replace pop_bb=(26755) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=1 in 11
	replace case=0 in 11
	replace pop_bb=(28005) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=2 in 12
	replace case=0 in 12
	replace pop_bb=(18530) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_bb=(19410) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_bb=(18465) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=4 in 15
	replace case=0 in 15
	replace pop_bb=(21080) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=5 in 16
	replace case=0 in 16
	replace pop_bb=(21945) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=6 in 17
	replace case=0 in 17
	replace pop_bb=(15940) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=7 in 18
	replace case=0 in 18
	replace pop_bb=(10515) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR NHL (M&F)- STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   18   277814    6.48      4.55     2.59     7.45     1.19 |
  +------------------------------------------------------------+
*/
restore


** BLADDER
tab pop age_10 if siteiarc==45 & sex==1 //female
tab pop age_10 if siteiarc==45 & sex==2 //male

preserve
	drop if age_10==.
	keep if siteiarc==45
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M&F 0-14,15-24,25-34,55-64
	** F 45-54,65-74
	** M 35-44
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=1 in 8
	replace case=0 in 8
	replace pop_bb=(26755) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=1 in 9
	replace case=0 in 9
	replace pop_bb=(28005) in 9
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 10
	replace age_10=2 in 10
	replace case=0 in 10
	replace pop_bb=(18530) in 10
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 11
	replace age_10=2 in 11
	replace case=0 in 11
	replace pop_bb=(18510) in 11
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 12
	replace age_10=3 in 12
	replace case=0 in 12
	replace pop_bb=(19410) in 12
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 13
	replace age_10=3 in 13
	replace case=0 in 13
	replace pop_bb=(18465) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=4 in 14
	replace case=0 in 14
	replace pop_bb=(19550) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 15
	replace age_10=5 in 15
	replace case=0 in 15
	replace pop_bb=(21945) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=6 in 16
	replace case=0 in 16
	replace pop_bb=(15940) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=6 in 17
	replace case=0 in 17
	replace pop_bb=(14195) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=7 in 18
	replace case=0 in 18
	replace pop_bb=(10515) in 18
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR BLADDER (M&F)- STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   13   277814    4.68      2.67     1.36     4.87     0.85 |
  +------------------------------------------------------------+
*/
restore


** CERVIX UTERI
tab pop age_10 if siteiarc==32 & sex==1 //female
tab pop age_10 if siteiarc==32 & sex==2 //male

preserve
	drop if age_10==.
	keep if siteiarc==32
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** F 0-14,15-24,25-34
		
	expand 2 in 1
	replace sex=1 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_bb=(26755) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_bb=(18530) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_bb=(19410) in 9
	sort age_10
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "`datapath'\version01\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
** THIS IS FOR CERVIX UTERI (F)- STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   12   144803    8.29      5.06     2.51     9.37     1.67 |
  +------------------------------------------------------------+
*/
restore
