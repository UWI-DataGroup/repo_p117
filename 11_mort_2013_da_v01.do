** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					11_mort_2013_da_v01.do
    //  project:						BNR
    //  analysts:						Jacqueline CAMPBELL
    //  date first created              25-APR-2019
    // 	date last modified	            25-APR-2019
    //  algorithm task					Generate stats for:
    //                                  Mortality Rates by (IARC) site:
    //							  						- ASR(ASMR): all sites, world
    // 							  						- ASR(ASMR): by site, by sex (world)
    //													(correct survival in dofile 8)
    //  status                          Completed
    //  objectve                        To have one dataset with cleaned, grouped and analysed 2013 data for 2014 cancer report.

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
    log using "`logpath'\11_mort_2013_da_v01.smcl", replace
** HEADER -----------------------------------------------------

** Load the dataset
use "`datapath'\version01\2-working\2008_2013_mort_dc_v01", replace

count //1,068

** Keep 2013 deaths only
tab dodyear ,m
drop if dodyear!=2013 //487 deleted

count // 581 cancer deaths in 2013
tab age_10 sex ,m //only 15-24 female and male missing
/*
           |      Patient sex
    age_10 |    female       male |     Total
-----------+----------------------+----------
      0-14 |         3          2 |         5 
     25-34 |         7          2 |         9 
     35-44 |        16          7 |        23 
     45-54 |        30         27 |        57 
     55-64 |        51         56 |       107 
     65-74 |        55         67 |       122 
     75-84 |        68         84 |       152 
 85 & over |        52         54 |       106 
-----------+----------------------+----------
     Total |       282        299 |       581
*/
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
drop if siteiarc==25|siteiarc==61|siteiarc==64 //51 deleted
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
siteiarc	count	percentage
Prostate (C61)	108	26.21
Colon (C18)	63	15.29
Breast (C50)	59	14.32
Pancreas (C25)	34	8.25
Cervix uteri (C53)	30	7.28
Lung (incl. trachea and bronchus) (C33-34)	27	6.55
Rectum (C19-20)	25	6.07
Multiple myeloma (C90)	17	4.13
Stomach (C16)	17	4.13
Non-Hodgkin lymphoma (C82-86,C96)	16	3.88
Myeloid leukaemia (C92-94)	16	3.88
*/
total count //412
restore

** All sites excl. O&U, non-reportable skin cancers - using IARC CI5's site groupings COMBINE cervix & CIN 3
** THIS USED IN ANNUAL REPORT TABLE 1 - CHECKING WHERE IN LIST 2014 TOP 10 APPEARS IN LIST FOR 2008
** This list requested by NS in similar format to CMO's report for top 10 comparisons with current & previous years
** Screenshot this data from Stata data editor into annual report tables document.
preserve
drop if (siteiarc==25|siteiarc>60) & siteiarc!=64 //51 deleted
replace siteiarc=32 if siteiarc==32|siteiarc==64 //0 changes
tab siteiarc ,m
contract siteiarc, freq(count) percent(percentage)
gsort -count
/*
                      IARC CI5-XI sites |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                        Tongue (C01-02) |          1        0.17        0.17
                         Mouth (C03-06) |          1        0.17        0.34
                Salivary gland (C07-08) |          3        0.52        0.86
                           Tonsil (C09) |          1        0.17        1.03
                 Other oropharynx (C10) |          1        0.17        1.20
              Pharynx unspecified (C14) |          2        0.34        1.55
                       Oesophagus (C15) |          5        0.86        2.41
                          Stomach (C16) |         17        2.93        5.34
                  Small intestine (C17) |          2        0.34        5.68
                            Colon (C18) |         63       10.84       16.52
                        Rectum (C19-20) |         25        4.30       20.83
                             Anus (C21) |          3        0.52       21.34
                            Liver (C22) |          8        1.38       22.72
              Gallbladder etc. (C23-24) |         12        2.07       24.78
                         Pancreas (C25) |         34        5.85       30.64
            Nose, sinuses etc. (C30-31) |          1        0.17       30.81
                           Larynx (C32) |          7        1.20       32.01
Lung (incl. trachea and bronchus) (C33- |         27        4.65       36.66
                 Melanoma of skin (C43) |          1        0.17       36.83
                       Other skin (C44) |          2        0.34       37.18
                           Breast (C50) |         59       10.15       47.33
                            Vulva (C51) |          2        0.34       47.68
                           Vagina (C52) |          1        0.17       47.85
                     Cervix uteri (C53) |         30        5.16       53.01
                     Corpus uteri (C54) |         14        2.41       55.42
               Uterus unspecified (C55) |          2        0.34       55.77
                            Ovary (C56) |         11        1.89       57.66
      Other female genital organs (C57) |          2        0.34       58.00
                            Penis (C60) |          1        0.17       58.18
                         Prostate (C61) |        108       18.59       76.76
                           Kidney (C64) |          5        0.86       77.62
                          Bladder (C67) |         10        1.72       79.35
         Brain, nervous system (C70-72) |          4        0.69       80.03
                          Thyroid (C73) |          4        0.69       80.72
      Non-Hodgkin lymphoma (C82-86,C96) |         16        2.75       83.48
                 Multiple myeloma (C90) |         17        2.93       86.40
               Lymphoid leukaemia (C91) |          6        1.03       87.44
             Myeloid leukaemia (C92-94) |         16        2.75       90.19
            Leukaemia unspecified (C95) |          6        1.03       91.22
     Myeloproliferative disorders (MPD) |          2        0.34       91.57
            Other and unspecified (O&U) |         49        8.43      100.00
----------------------------------------+-----------------------------------
                                  Total |        581      100.00
*/
total count //530 (O&U=49; NMSCs=2)
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

    matched                               581  (_merge==3)
    -----------------------------------------
    */
** There are 2 unmatched records (_merge==2) since 2013 data doesn't have any cases of females and males with age range 15-24
**	age_10	site  dup	sex	 pfu	age45	age55	pop_bb	_merge
** 15-24	  .     .	female .	0-44	0-54	18530	using only (2)
** 15-24	  .     .	male   .	0-44	0-54	18510	using only (2)
**drop if _merge==2 //do not drop these age groups as it skews population 

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
  |  581   240774   241.31   10.01   222.08   261.75 |
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
  |  581   277814   209.13    136.28   124.98   148.39     5.90 |
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
	** now we have to add in the cases and popns for the missings: 
	** M 0-14,15-24,25-34
		
	expand 2 in 1
	replace sex=2 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_bb=(28005) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_bb=(18510) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_bb=(18465) in 9
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
  |  108   133011   81.20     54.60    44.63    66.33     5.39 |
  +------------------------------------------------------------+
*/
restore

** PROSTATE - added in female population to check ASMR against IARC rate as large difference in rates
tab pop age_10 if siteiarc==39 //male

preserve
	drop if age_10==.
	keep if siteiarc==39 // 
	
	collapse (sum) case (mean) pop_bb, by(pfu age_10 sex)
	sort age sex
	** now we have to add in the cases and popns for the missings: 
	** M 0-14,15-24,25-34
		
	expand 2 in 1
	replace sex=2 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_bb=(28005) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_bb=(18510) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_bb=(18465) in 9
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
  |  108   277814   38.87     22.23    18.07    27.18     2.26 |
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
	** now we have to add in the cases and popns for the missings: 
	** M 0-14,15-24,25-34
		
	expand 2 in 1
	replace sex=2 in 7
	replace age_10=1 in 7
	replace case=0 in 7
	replace pop_bb=(28005) in 7
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 8
	replace age_10=2 in 8
	replace case=0 in 8
	replace pop_bb=(18510) in 8
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 9
	replace age_10=3 in 9
	replace case=0 in 9
	replace pop_bb=(18465) in 9
	sort age_10
			
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
total pop_bb

distrate case pop_bb using "`datapath'\version01\2-working\whosegi2000_10-2", 	///	
		         stand(age_10) popstand(pop_segi) mult(100000) format(%8.2f)
** THIS IS FOR PC - STD TO WHO WORLD POPN: SEGI 1960

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |  108   133011   81.20     44.06    35.73    53.99     4.52 |
  +------------------------------------------------------------+
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
	** M&F 0-14,15-24
	** M 25-34,35-44,45-54,55-64,65-74
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
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bb=(18510) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_bb=(18465) in 14
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
	replace sex=2 in 17
	replace age_10=6 in 17
	replace case=0 in 17
	replace pop_bb=(14195) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=7 in 18
	replace case=0 in 18
	replace pop_bb=(8315) in 18
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
  |   59   277814   21.24     14.91    11.22    19.48     2.04 |
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
  |   63   277814   22.68     14.33    10.91    18.57     1.89 |
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
	** M&F 0-14,15-24,25-34,35-44
	** F 45-54
	
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
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bb=(18510) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_bb=(19410) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bb=(18465) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_bb=(21080) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=4 in 17
	replace case=0 in 17
	replace pop_bb=(19550) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=5 in 18
	replace case=0 in 18
	replace pop_bb=(21945) in 18
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
  |   27   277814    9.72      6.23     4.05     9.27     1.28 |
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
	** M&F 0-14,15-24,25-34
	** M 35-44
	
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
** THIS IS FOR PANCREATIC CANCER (M&F)- STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   34   277814   12.24      8.07     5.53    11.47     1.46 |
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
	** M&F 0-14,15-24,25-34
	** F 45-54
	** M 55-64,85+
	
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
	replace sex=2 in 13
	replace age_10=2 in 13
	replace case=0 in 13
	replace pop_bb=(18510) in 13
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 14
	replace age_10=3 in 14
	replace case=0 in 14
	replace pop_bb=(19410) in 14
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 15
	replace age_10=3 in 15
	replace case=0 in 15
	replace pop_bb=(18465) in 15
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 16
	replace age_10=5 in 16
	replace case=0 in 16
	replace pop_bb=(21945) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=6 in 17
	replace case=0 in 17
	replace pop_bb=(14195) in 17
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
** THIS IS FOR MULTIPLE MYELOMA (M&F)- STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   17   277814    6.12      4.28     2.46     7.02     1.11 |
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
	** F 0-14,15-24,25-34,35-44
	
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
	replace age_10=4 in 9
	replace case=0 in 9
	replace pop_bb=(21080) in 9
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
  |   14   144803    9.67      5.94     3.18    10.40     1.76 |
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
	** F 25-34
	
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
** THIS IS FOR RECTAL CANCER (M&F)- STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   25   277814    9.00      5.52     3.47     8.44     1.21 |
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
	** F 55-64
	
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
	replace sex=1 in 16
	replace age_10=5 in 16
	replace case=0 in 16
	replace pop_bb=(21945) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 17
	replace age_10=5 in 17
	replace case=0 in 17
	replace pop_bb=(19470) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 18
	replace age_10=6 in 18
	replace case=0 in 18
	replace pop_bb=(15940) in 18
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
  |   17   277814    6.12      3.78     2.16     6.28     1.00 |
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
	** M&F 0-14,15-24,65-74
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
	replace age_10=4 in 16
	replace case=0 in 16
	replace pop_bb=(21080) in 16
	sort age_10
	
	expand 2 in 1
	replace sex=1 in 17
	replace age_10=7 in 17
	replace case=0 in 17
	replace pop_bb=(10515) in 17
	sort age_10
	
	expand 2 in 1
	replace sex=2 in 18
	replace age_10=7 in 18
	replace case=0 in 18
	replace pop_bb=(8315) in 18
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
  |   16   277814    5.76      4.35     2.41     7.26     1.19 |
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
	** M&F 0-14,15-24,25-34,35-44,55-64
	** F 45-54
	** M 85+
	
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
** THIS IS FOR BLADDER (M&F)- STD TO WHO WORLD POPN 

/*
  +------------------------------------------------------------+
  | case        N   crude   rateadj   lb_gam   ub_gam   se_gam |
  |------------------------------------------------------------|
  |   10   277814    3.60      2.38     1.12     4.56     0.84 |
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
  |   30   144803   20.72     13.26     8.80    19.39     2.60 |
  +------------------------------------------------------------+
*/
restore
