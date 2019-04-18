** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			10_rx_outcomes_2008_da_v01.do
    //  project:				BNR
    //  analysts:				Jacqueline CAMPBELL
    //  date first created         18-APR-2019
    // 	date last modified	     18-APR-2019
    //  algorithm task			Generate stats for:
    //                             Routine medication (not applicable to 2014 data)
    //						    Outcomes
    //							  - % deaths - overall deaths as % and by year
    // 							  - Survival analysis to 3 years
    //								(correct survival in dofile 8)
    //							  - % deaths by main sites & cancer vs non-cancer deaths
    //  status                     Completed
    //  objectve                   To have one dataset with cleaned, grouped and analysed 2008 data for 2014 cancer report.

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
    log using "`logpath'\10_rx_outcomes_2008_da_v01.smcl", replace
** HEADER -----------------------------------------------------

** Load the dataset
use "`datapath'\version01\2-working\2008_cancer_numbers_da_v01", replace

************************************************
** 4.2 overall deaths as % and by year
************************************************
** Note that we cannot here estimate MR or ASMR, as we do not have this information
** (i.e. TOTAL deaths from cancer in 2008 - even those that were not dx in that year)
** so if we did an MR or ASMR it would be an underestimate; that will come after
** several years of the registry

count //1,209

** Remove non-reportable skin cancers but include CIN 3 to match 2014 case definition
drop if beh!=3 & siteiarc!=64 //68 deleted
drop if siteiarc==25 //303 deleted

count //838

tab slc ,m
/*
StatusLastC |
     ontact |      Freq.     Percent        Cum.
------------+-----------------------------------
      Alive |        281       33.53       33.53
   Deceased |        557       66.47      100.00
------------+-----------------------------------
      Total |        838      100.00
*/
tab deceased ,m
/*
   whether patient is |
             deceased |      Freq.     Percent        Cum.
----------------------+-----------------------------------
                 dead |        557       66.47       66.47
alive at last contact |        281       33.53      100.00
----------------------+-----------------------------------
                Total |        838      100.00
*/

** Now we restrict to patients only (as we are dealing with deaths)
drop if patient==2 //9 deleted
count //829

sort dot dod
//list dot dod basis
tab dod ,m // missing
count if dod!=. //552

tab deceased ,m
/*
  whether patient is |
             deceased |      Freq.     Percent        Cum.
----------------------+-----------------------------------
                 dead |        552       66.59       66.59
alive at last contact |        277       33.41      100.00
----------------------+-----------------------------------
                Total |        829      100.00
*/

tab beh  deceased  ,m
/*
           |  whether patient is
           |       deceased
 Behaviour |      dead  alive at  |     Total
-----------+----------------------+----------
   In situ |         2         32 |        34 
 Malignant |       550        245 |       795 
-----------+----------------------+----------
     Total |       552        277 |       829
*/

rename deathyear dodyear
tab dodyear ,m

tab dodyear beh ,m
/*
           |       Behaviour
   dodyear |   In situ  Malignant |     Total
-----------+----------------------+----------
      2008 |         0        232 |       232 
      2009 |         0        104 |       104 
      2010 |         0         54 |        54 
      2011 |         1         37 |        38 
      2012 |         0         27 |        27 
      2013 |         0         26 |        26 
      2014 |         0         20 |        20 
      2015 |         1         19 |        20 
      2016 |         0         17 |        17 
      2017 |         0         14 |        14 
         . |        32        245 |       277 
-----------+----------------------+----------
     Total |        34        795 |       829
*/

tab dodyear deceased ,m
tab dodyear deceased if siteiarc!=25 ,m
/*
           |  whether patient is
           |       deceased
   dodyear |      dead  alive at  |     Total
-----------+----------------------+----------
      2008 |       232          0 |       232 
      2009 |       104          0 |       104 
      2010 |        54          0 |        54 
      2011 |        38          0 |        38 
      2012 |        27          0 |        27 
      2013 |        26          0 |        26 
      2014 |        20          0 |        20 
      2015 |        20          0 |        20 
      2016 |        17          0 |        17 
      2017 |        14          0 |        14 
         . |         0        277 |       277 
-----------+----------------------+----------
     Total |       552        277 |       829
*/


** 232 died in 2008 - JC: only do 2014-2017 as 2018 was incomplete
cii proportions 829 232
dis 829-(428+1) // by 3yrs from dx (i.e. up to 31dec2011) 428 had died
cii proportions 829 104
cii proportions 829 54
cii proportions 829 38

count if dodyear!=. //552
//list dod slc pid if dodyear==. & deceased!=. & slc==2
** none missing dod
 
tab siteiarc deceased ,m


*********************************************
** Death Info for Top Deaths - Totals by site
*********************************************

** Check for top 10 deaths by IARC site
** exclude O&U and in-situ
preserve
drop if (siteiarc==25|siteiarc>60)|deceased!=1 //311 deleted
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
drop top10 percentage
/*
siteiarc	count
Prostate (C61)	117
Colon (C18)	76
Breast (C50)	67
Lung (incl. trachea and bronchus) (C33-34)	29
Stomach (C16)	27
Corpus uteri (C54)	25
Rectum (C19-20)	19
Multiple myeloma (C90)	16
Pancreas (C25)	15
Cervix uteri (C53)	13
*/
total count //404
restore


** include O&U; exclude in-situ
preserve
drop if siteiarc==64|deceased!=1 //279 deleted
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
drop top10 percentage
/*
siteiarc	count
Prostate (C61)	117
Colon (C18)	76
Breast (C50)	67
Other and unspecified (O&U)	32
Lung (incl. trachea and bronchus) (C33-34)	29
Stomach (C16)	27
Corpus uteri (C54)	25
Rectum (C19-20)	19
Multiple myeloma (C90)	16
Pancreas (C25)	15
*/
total count //423
restore
		
		
** DEATHS OF THOSE WITH PROSTATE CANCER - #1
tab deceased if siteiarc==39 ,m
sort dod
//tab dod if deceased==1 & siteiarc==39 ,m
cii proportions 203 117


** DEATHS OF THOSE WITH COLON CANCER - #2
tab deceased if siteiarc==13 ,m
sort dod
//tab dod if deceased==1 & siteiarc==13 ,m
cii proportions 94 76

** DEATHS OF THOSE WITH BREAST CANCER - #3
tab deceased if siteiarc==29 ,m
sort dod
//tab dod if deceased==1 & siteiarc==29 ,m
cii proportions 132 67


** DEATHS OF THOSE WITH LUNG CANCER - #4
tab deceased if siteiarc==21 ,m
sort dod
//tab dod if deceased==1 & siteiarc==21 ,m
cii proportions 29 29


** DEATHS OF THOSE WITH O&U (ill-defined;unk siteiarc) - #4
tab deceased if siteiarc==61 ,m
sort dod
//tab dod if deceased==1 & siteiarc==61 ,m
cii proportions 33 32


** DEATHS OF THOSE WITH STOMACH CANCER - #5
tab deceased if siteiarc==11 ,m
sort dod
//tab dod if deceased==1 & siteiarc==11 ,m
cii proportions 32 27


** DEATHS OF THOSE WITH CORPUS UTERI CANCER - #6
tab deceased if siteiarc==33 ,m
sort dod
//tab dod if deceased==1 & siteiarc==33 ,m
cii proportions 38 25


** DEATHS OF THOSE WITH RECTAL CANCER - #7
tab deceased if siteiarc==14 ,m
sort dod
//tab dod if deceased==1 & siteiarc==14 ,m
cii proportions 28 19


** DEATHS OF THOSE WITH MULTIPLE MYELOMA - #8
tab deceased if siteiarc==55 ,m
sort dod
//tab dod if deceased==1 & siteiarc==55 ,m
cii proportions 17 16

			 
** DEATHS OF THOSE WITH PANCREATIC CANCER - #9
tab deceased if siteiarc==18 ,m
sort dod
//tab dod if deceased==1 & siteiarc==18 ,m
cii proportions 15 15


** DEATHS OF THOSE WITH CERVIX UTERI CANCER - #10
tab deceased if siteiarc==32 ,m
sort dod
//tab dod if deceased==1 & siteiarc==32 ,m
cii proportions 19 13


********************************************************************************
** 4.4 Deaths - numbers and % by site and whether CoD cancer or not
********************************************************************************
tab cod ,m
/*
     COD categories |      Freq.     Percent        Cum.
--------------------+-----------------------------------
     Dead of cancer |        440       53.08       53.08
Dead of other cause |        107       12.91       65.98
          Not known |          5        0.60       66.59
                  . |        277       33.41      100.00
--------------------+-----------------------------------
              Total |        829      100.00
*/
tab cod if deceased==1 & patient==1 ,m
/*
     COD categories |      Freq.     Percent        Cum.
--------------------+-----------------------------------
     Dead of cancer |        440       79.71       79.71
Dead of other cause |        107       19.38       99.09
          Not known |          5        0.91      100.00
--------------------+-----------------------------------
              Total |        552      100.00
*/
sort cod1a
tab cod1a if deceased==1 & cod==. ,m
tab cod if deceased==1,m

tab cod if deceased==1 & patient==1 & dodyear<2009 ,m
/*
     COD categories |      Freq.     Percent        Cum.
--------------------+-----------------------------------
     Dead of cancer |        194       83.62       83.62
Dead of other cause |         36       15.52       99.14
          Not known |          2        0.86      100.00
--------------------+-----------------------------------
              Total |        232      100.00
*/
tab siteiarc if deceased==1 & patient==1 & dodyear<2009 & cod==1 ,m


** Save this new dataset for graphs in dofile 12 
save "`datapath'\version01\2-working\2008_cancer_rx_outcomes_da_v01", replace
label data "2008 BNR-Cancer analysed data - Rx and Outcomes"
note: TS This dataset does NOT include population data
	

/*
********************************************************************************
** 4.3 Survival analysis - using the DIRECT METHOD
********************************************************************************
** JC 20dec2018: correct method for survival analysis done in 8_survival_da.do
** I didn't update below comments but updated the code to extend to end of 2017
** as it only went up to end of 2016 deaths for 2013 data analysis.

** STEP 1: define a "time to death" variable and keep those with dod in
** 2018 out of the equation
tab dodyear ,m
tab deceased ,m
gen time2death=(dod-dot) if dodyear<2018 //424 missing values generated

tab time2death if deceased==1 & dodyear<2018 ,m
list pid dot dod dodyear if time2death==-5 //JC 20dec18: corrected in dofile 5 of cleaning dofiles
tab basis if time2death==0 ,m
tab basis if time2death==1 ,m
** Note that all those with time2death=0 are those diagnosed at death

sort dod 
tab dod if deceased==1 ,m

** STEP 2: choose date for "end of study" - your interval max being "5 years
** from dx" - get this from a review of date of last contact for living cases:
** JC: for 2013 data interval max would be "3 years from dx" as only have
** death data up to end of 2016
sort dod
list dod deceased 

** Now: all pts seen in 2017 we know were alive on 31-dec-2016 but we do not know 
** if they were still alive on 31-dec-2017. So 31-dec-2016 is selected as the 
** "end date" for the survival analysis. So all patients first seen (dot) before
** (31-dec-2016 - 3), i.e. from 01-jan-2014, should be excluded. As this is a 2013
** dataset, they are indeed excluded.
** The dataset now included people who were AT RISK OF DYING for at least 3 years
** by the end date of the study, which is 31-dec-2016

** STEP 3: estimate the NUMBER AND % of patients who were STILL ALIVE at last
** contact and the number and % who had died by 31-dec-2016
sort dot
list dot dod deceased 

** JC: side note - one (1) pt died in 2017 for 2013 data but pt total remains 
** same at 831
preserve
replace deceased=2 if dod>d(31-dec-2017) //0 changes
count if deceased==2 // 424 survived to 3 years
count if deceased==1 // 488 died within 3 years of dx
count if deceased==1 & ((dod-dot)>((3*365)+1)) // 14
list fname lname dot dod deceased if deceased==1 & ((dod-dot)>((3*365)+1))
** one (1) person who died lived for more than 3 years from their cancer dx
** she only lived 3 yrs + 25 days more from their cancer dx as shown below
** BUT this pt who died lived already 3 years from their cancer dx before death
** Hence the % still alive 3 years from dx was 450/831=54%
** and the % who had died was 381/831=46%

** For 2014, 424/912=46.5% lived already 3yrs from cancer dx before they died
** For 2014, 488/912=53.5% died within 3yrs of cancer dx
restore


** Now looking at 1 year and 2 year survival:
preserve
** for 2 year survival: our end-date will be 31-dec-2015
replace deceased=2 if dod>d(31-dec-2016)
count if deceased==2 // 454 survived to 2 years
count if deceased==1 // 458 died within 2 years of dx
count if deceased==1 & ((dod-dot)>((2*365)+1)) // 24
list fname lname dot dod deceased if deceased==1 & ((dod-dot)>((2*365)+1))
** BUT 12 pts who died lived already 2 years from their cancer dx before death
** Hence the % still alive 2 years from dx was (453+12)/831=56%
** and the % who had died was (378-12)/831=44%

** For 2014, 454/912=49.8% lived already 2yrs from cancer dx before they died
** For 2014, 458/912=50.2% died within 2yrs of cancer dx
restore

preserve
** for 1 year survival: our end-date will be 31-dec-2014
replace deceased=2 if dod>d(31-dec-2015)
count if deceased==2 // 508 survived to 1 year
count if deceased==1 // 404 died within 1 year of dx
count if deceased==1 & ((dod-dot)>((365)+1)) // 34
list fname lname dot dod deceased if deceased==1 & ((dod-dot)>((365)+1))
** BUT 36 pts who died lived already 1 year from their cancer dx before death
** Hence the % still alive 1 year from dx was (490+36)/831=63%
** and the % who had died was (341-36)/831=37%

** For 2014, 508/912=55.7% lived already 1yr from cancer dx before they died
** For 2014, 404/912=44.3% died within 1yr of cancer dx
restore

*/

**************************************
** 4.1 Treatment (all types)
**************************************
** JC 20dec2018: below treatment code disused for 2014 data as rx was not collected and 
** since this 2008 info for inclusion 2014 annual report - treatment not done.

/*
save "data\2013_updated_cancer_dataset_site", replace

list eid treatment2 date_rx2 if treatment2==0 & date_rx2!=. //none as of 09oct2017
list eid treatment3 date_rx3 if treatment3==0 & date_rx3!=. //none as of 09oct2017
list eid treatment4 date_rx4 if treatment4==0 & date_rx4!=. //none as of 09oct2017

tab treatment1 ,m
tab treatment1 if site==14 ,m // BC treatment

tab treatment1 if (treatment1<9)

tab treatment1 if (treatment1<9 & treatment1!=0)

** AR to JC: better to use 581 as denominator as those are all for whom we have
** Rx info. - the rest we don't know if they had Rx or not, so hard to tell and
** therefore we exclude from denominator
dis 581/846 // Rx info. available
dis 458/581 //had treatment (of all those with info. available) 
dis 265/846 //unknown if had treatment 
dis 123/846 //had no treatment 

** other treatment received from usual list above (choices)
tab othertreatment1 if treatment1==8 ,m

dis 32/458 //palliative 7.0% as of 09oct2017
dis 6/458 //treated abroad 1.3% as of 09oct2017

** other treatment received from usual list above (text)
tab othertreatment2 ,m

sort treatment1 othertreatment1 treatment2 treatment3 treatment4 othertreatment2
list treatment1 othertreatment1 treatment2 treatment3 treatment4 othertreatment2 ///
	 if (treatment1!=9 & treatment1!=0)


** reasons for having no treatment
tab notreatment1 notreatment2 if treatment1==0 ,m

** reasons for having no treatment
tab notreatment2 ,m

** other treatments
tab treatment2 if (treatment2<9 & treatment2!=0)

tab treatment3 if (treatment3<9 & treatment3!=0)

tab treatment4 if (treatment4<9 & treatment4!=0)

** No-one in this dataset had 5 rounds of treatment
tab treatment5 ,m

** to find the frequency of any number of treatments (1-4)
gen any_surg=1 if (treatment1==1 | treatment2==1 | treatment3==1 | treatment4==1)
tab any_surg 

gen any_rt=1 if (treatment1==2 | treatment2==2 | treatment3==2 | treatment4==2)
tab any_rt

gen any_chemo=1 if (treatment1==3 | treatment2==3 | treatment3==3 | treatment4==3)
tab any_chemo

gen any_it=1 if (treatment1==4 | treatment2==4 | treatment3==4 | treatment4==4) 
tab any_it

gen any_ht=1 if (treatment1==5 | treatment2==5 | treatment3==5 | treatment4==5)
tab any_ht

gen any_oth=1 if (treatment1==8 | treatment2==8 | treatment3==8 | treatment4==8)
tab any_oth

tab othertreatment1 if any_oth==1 ,m

tab1 any* if (treatment1 !=0 & treatment1!=. & treatment1!=9)

** # with 4 treatments
count if ((treatment1>0 & treatment1<9) & (treatment2>0 & treatment2<9) & ///
		 (treatment3>0 & treatment3<9) & (treatment4>0 & treatment4<9))
		 
** # with 3 treatments		 
count if ((treatment1>0 & treatment1<9) & (treatment2>0 & treatment2<9) & ///
		 (treatment3>0 & treatment3<9) & (treatment4==.))

** # with 2 treatments		 
count if ((treatment1>0 & treatment1<9) & (treatment2>0 & treatment2<9) & ///
		 (treatment3==.) & (treatment4==.))	 
		 
sort treatment*		 
list treatment*		 
		 
		 
*************************************************
** The % of pts who had Rx1 within 4 months of dx
*************************************************

gen rx1_time=date_rx1-dot if (treatment1!=. & treatment1!=9 & treatment1!=0) //389 missing values generated as of 09oct2017
tab rx1_time if (treatment1!=. & treatment1!=9 & treatment1!=0) ,m

** Note that we have some negative values... need to be checked:
sort eid dot
count if rx1_time<0 //19 as of 09oct2017; corrections done in '2_section1.do'
list eid date_rx1 date_rx2 date_rx3 date_rx4 dot dod if rx1_time<0
** 55 of these are incidental so rx1_time==0

** First check how many were DCOs
sort basis
list  eid date_rx1 basis histol treatment1 dot dod if rx1_time<0
tab date_rx1 ,m
** Now just exclude the incidentals from the analyses
tab rx1_time ,m

** NOTE: IARC rules state that DCOs without further info should take incidence date
** as deathdate NOT histology report date...
sort basis
count if rx1_time==0 //55 as of 09oct2017
list eid dot treatment1 date_rx1 treatment2 date_rx2 dod basis if rx1_time==0
** Good - none of these 55 are DCOs

replace rx1_time=date_rx1-dot if (treatment1!=. & treatment1!=9 & treatment1!=0 & rx1_time==.)


save "data\2013_updated_cancer_dataset_site_cod", replace

use "data\2013_updated_cancer_dataset_site_cod",clear


** OK here is the plan:
** (1) exclude all those with rx1_time<0 
** (2) also exclude all those with rx1_time=0 and estimate
**	   median time to Rx1 for all
** all below figures are as of 09oct2017

preserve
** (1) exclude all with time<0
count if rx1_time!=. // 458
drop if (rx1_time==. & treatment1>0 & treatment1<9) 
drop if rx1_time<0 

** (2) also drop if time==0
drop if rx1_time==0 

** now drop all missing times
drop if rx1_time==. 
count // 403

** For ALL cancers
count // 403
tab site ,m
ameans rx1_time
gen k=1
table k, c(p50 rx1_time p25 rx1_time p75 rx1_time min rx1_time max rx1_time) // 50 days

** For BC
drop if site!=14 
count // 95
ameans rx1_time
table k, c(p50 rx1_time p25 rx1_time p75 rx1_time min rx1_time max rx1_time) // 50 days

** Now for % being treated within first 4 months:
count if rx1_time<(30*4) // 76
count // 95
dis 76/95 
cii 95 76

** Now for % being treated within first 4 weeks:
count if rx1_time<(7*4) // 24
count // 95
dis 24/95 
cii 95 24
restore


preserve
** (1) exclude all with time<0
count if rx1_time!=. // 458
drop if (rx1_time==. & treatment1>0 & treatment1<9) 
drop if rx1_time<0 

** (2) also drop if time==0
drop if rx1_time==0 

** now drop all missing times
drop if rx1_time==. 
count // 403

** For PC
drop if site!=19
count // 52
ameans rx1_time
gen k=1
table k, c(p50 rx1_time p25 rx1_time p75 rx1_time min rx1_time max rx1_time) 

** Now for % being treated within first 4 months:
count if rx1_time<(30*4) // 32
count // 52
dis 32/52 
cii 52 32
restore


preserve
** (1) exclude all with time<0
count if rx1_time!=. // 458
drop if (rx1_time==. & treatment1>0 & treatment1<9) 
drop if rx1_time<0 

** (2) also drop if time==0 
drop if rx1_time==0 

** now drop all missing times
drop if rx1_time==. 
count // 403

** For Colorectal (site=3 & 4 & 5)
drop if (site<3  | site>5)
count // 100
ameans rx1_time 
gen k=1
table k, c(p50 rx1_time p25 rx1_time p75 rx1_time min rx1_time max rx1_time)

** Now for % being treated within first 4 months:
count if rx1_time<(30*4) // 91
count // 100
dis 91/100 
cii 100 91

** Now for % being treated within first 4 weeks colorectal:
/*count if rx1_time<(30) // 53
count // 100
dis 53/100 // 53%!!!
cii 100 53
** Now for % being treated within first 4 weeks just colon:
drop if site==5
count if rx1_time<(30) // 51
count // 83
dis 51/83 // 61%!!!
cii 83 51
*/
restore


preserve
** (1) exclude all with time<0
count if rx1_time!=. // 458
drop if (rx1_time==. & treatment1>0 & treatment1<9) 
drop if rx1_time<0 

** (2) also drop if time==0 
drop if rx1_time==0 

** now drop all missing times
drop if rx1_time==. 
count // 403

** For lymphoid & blood (site=10)
drop if (site!=10)
count // 30
ameans rx1_time
gen k=1
table k, c(p50 rx1_time p25 rx1_time p75 rx1_time min rx1_time max rx1_time)

** Now for % being treated within first 4 months:
count if rx1_time<(30*4) // 27
count // 30
dis 27/30 
cii 30 27
restore


preserve
** (1) exclude all with time<0
count if rx1_time!=. // 458
drop if (rx1_time==. & treatment1>0 & treatment1<9) 
drop if rx1_time<0 

** (2) also drop if time==0 
drop if rx1_time==0 

** now drop all missing times
drop if rx1_time==. 
count // 403

** For urinary (site=20)
drop if (site!=20)
count // 13
ameans rx1_time
gen k=1
table k, c(p50 rx1_time p25 rx1_time p75 rx1_time min rx1_time max rx1_time)

** Now for % being treated within first 4 months:
count if rx1_time<(30*4) // 10
count // 13
dis 10/13 
cii 13 10
restore


preserve
** (1) exclude all with time<0
count if rx1_time!=. // 458
drop if (rx1_time==. & treatment1>0 & treatment1<9) 
drop if rx1_time<0 

** (2) also drop if time==0 
drop if rx1_time==0 

** now drop all missing times
drop if rx1_time==. 
count // 403

** For  cervix & uterus (site=15 & 16)
drop if (site<15 | site>16)
count // 49
ameans rx1_time
gen k=1
table k, c(p50 rx1_time p25 rx1_time p75 rx1_time min rx1_time max rx1_time)

** Now for % being treated within first 4 months:
count if rx1_time<(30*4) // 30
count // 49
dis 30/49
cii 49 30

** now just cervix
drop if (site<15 | site>15)
count // 30
ameans rx1_time
table k, c(p50 rx1_time p25 rx1_time p75 rx1_time min rx1_time max rx1_time)

** Now for % being treated within first 4 months:
count if rx1_time<(30*4) // 14
count // 30
dis 14/30 
cii 30 14
restore

preserve
** now just uterus
** (1) exclude all with time<0
count if rx1_time!=. // 458
drop if (rx1_time==. & treatment1>0 & treatment1<9) 
drop if rx1_time<0 

** (2) also drop if time==0 
drop if rx1_time==0 

** now drop all missing times
drop if rx1_time==. 
count // 403

** For  uterus (site=16)
drop if (site<16 | site>16)
count // 19
ameans rx1_time 
gen k=1
table k, c(p50 rx1_time p25 rx1_time p75 rx1_time min rx1_time max rx1_time) 

** Now for % being treated within first 4 months:
count if rx1_time<(30*4) // 16
count // 19
dis 16/19 
cii 19 16
restore


preserve
** (1) exclude all with time<0
count if rx1_time!=. // 458
drop if (rx1_time==. & treatment1>0 & treatment1<9) 
drop if rx1_time<0 

** (2) also drop if time==0 
drop if rx1_time==0 

** now drop all missing times
drop if rx1_time==. 
count // 403

** For respiratory (site=8)
drop if (site!=8)
count // 10
ameans rx1_time
gen k=1
table k, c(p50 rx1_time p25 rx1_time p75 rx1_time min rx1_time max rx1_time)

** Now for % being treated within first 4 months:
count if rx1_time<(30*4) // 8
count // 10
dis 8/10
cii 10 8
restore


preserve
** (1) exclude all with time<0
count if rx1_time!=. // 458
drop if (rx1_time==. & treatment1>0 & treatment1<9) 
drop if rx1_time<0 

** (2) also drop if time==0
drop if rx1_time==0 

** now drop all missing times
drop if rx1_time==. 
count // 403

** For lip, oral cavity & pharynx (site==1)
drop if site!=1
count // 52
ameans rx1_time
gen k=1
table k, c(p50 rx1_time p25 rx1_time p75 rx1_time min rx1_time max rx1_time) 

restore


preserve
** (1) exclude all with time<0
count if rx1_time!=. // 458
drop if (rx1_time==. & treatment1>0 & treatment1<9) 
drop if rx1_time<0 

** (2) also drop if time==0 
drop if rx1_time==0

** now drop all missing times
drop if rx1_time==. 
count // 403

** For all other sites
drop if (site==1 | (site>2 & site<6) | site==8 | site==10 | (site>13 & site<17) | site==19 | site==20)
count // 54
ameans rx1_time
gen k=1
table k, c(p50 rx1_time p25 rx1_time p75 rx1_time min rx1_time max rx1_time)

** Now for % being treated within first 4 months:
count if rx1_time<(30*4) // 43
count // 54
dis 43/54
cii 54 43
restore

** JC: I added in the below 'save' and 'use' as the next set of code deletes the 15 MPs
save "data\2013_updated_cancer_dataset_site_rx", replace

use "data\2013_updated_cancer_dataset_site_rx",clear
*/
