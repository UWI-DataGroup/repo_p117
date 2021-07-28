** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          55_prep survival.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      28-JUL-2021
    // 	date last modified      28-JUL-2021
    //  algorithm task          Creating survival dataset using cleaned, current cancer dataset post death matching
    //  status                  Completed
    //  objective               To have a cleaned and matched survival dataset
    //  methods                 Using same prep code that was previously in 15_clean cancer.do

    ** General algorithm set-up
    version 16.1
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
    log using "`logpath'\50_death match.smcl", replace
** HEADER -----------------------------------------------------

* ************************************************************************
* PREP AND FORMAT
**************************************************************************

***********************
**   2013 2014 2015  **
** Survival Datasets **
***********************
/*
Data ineligible/excluded from survival analysis - taken from IARC 2012 summer school presented by Manuela Quaresma
Ineligible Criteria:
- Incomplete data
- Beh not=/3
- Not resident
- Inappropriate morph code

Excluded Criteria:
- Age 100+
- SLC unknown
- Duplicate
- Synchronous tumour
- Sex incompatible with site
- Dates invalid
- Inconsistency between dob, dot and dlc
- Multiple primary
- DCO / zero survival (true zero survival included i.e. dot=dod but not a DCO)
*/

**************************************************************************
* SURVIVAL ANALYSIS
* Survival analysis to 1 year, 3 years and 5 years
**************************************************************************
** 2008 cases to be dropped for 2015 annual report, as decided by NS on 06-Oct-2020, email subject: BNR-C: 2015 cancer stats tables completed
** Load the dataset
use "`datapath'\version02\3-output\2013_2014_2015_cancer_nonsurvival_bnr_reportable", clear

** Update dataset to meet IARC standards for calculating survival
tab patient ,m 
tab persearch ,m 
tab eidmp ,m 
count if patient==2 & persearch==1 //0
//list pid fname lname if patient==2 & persearch==1

** Note: most below figures will be less one(1) as found one(1) ineligible during 2015 reviews (pid=20141523)
count //2843

drop if basis==0 //217 deleted - DCO 
drop if age>100 //6 deleted - age 100+
drop if slc==99 //0 deleted - status at last contact unknown
drop if patient!=1 //51 deleted - MP
drop if resident==2 //0 deleted - nonresident
drop if resident==99 //109 deleted - resident unknown
drop if recstatus==3 //0 deleted - ineligible case definition
drop if sex==9 //0 deleted - sex unknown
drop if beh!=3 //48 deleted - nonmalignant
drop if persearch>2 //1 to be deleted
drop if siteiarc==25 //0 deleted - nonreportable skin cancers

count //2411

** now ensure everyone has a unique id
count if pid=="" //0

recode deceased 2=0 //1058 changes

gen deceased_1yr=deceased
gen deceased_3yr=deceased
gen deceased_5yr=deceased
label drop deceased_lab
label define deceased_lab 0 "censored" 1 "dead", modify
label values deceased deceased_1yr deceased_3yr deceased_5yr deceased_lab
label var deceased "Survival identifer"
label var deceased_1yr "Survival identifer at 1yr"
label var deceased_3yr "Survival identifer at 3yrs"
label var deceased_5yr "Survival identifer at 5yrs"

tab deceased ,m //1353 dead; 1058 censored
tab deceased_1yr ,m //1353 dead; 1058 censored
tab deceased_3yr ,m //1353 dead; 1058 censored
tab deceased_5yr ,m //1353 dead; 1058 censored
count if dlc==. //0
count if dod==. //1058

** check for all patients who are deceased but missing dod
count if deceased==1 & dod==. //0
count if deceased_1yr==1 & dod==. //0
count if deceased_3yr==1 & dod==. //0
count if deceased_5yr==1 & dod==. //0

count if dot==. //0

** Create end_date variables: 1 year, 3 years and 5 years from incidence
gen enddate_1yr=(dot+(365.25*1)) if dot!=.
gen enddate_3yr=(dot+(365.25*3)) if dot!=.
gen enddate_5yr=(dot+(365.25*5)) if dot!=. & dxyr<2015 //2019 death data not available as of 17nov2019; 2019 deaths now added 30-Sep-2020 so code updated from dxyr<2014

format enddate* %dD_m_CY

count if enddate_1yr==. //0
count if enddate_3yr==. //0
count if enddate_5yr==. & dxyr<2015 //0

** Since end_date is 1, 3, 5 years from incidence, reset deceased from dead to censored if pt died after end_date
count if dod!=. & dod>dot+(365.25*1) //517
//list pid deceased_1yr dot dod dlc enddate_1yr if dod!=. & dod>dot+(365.25*1)
count if dod!=. & dod>dot+(365.25*3) //151
//list pid deceased_3yr dot dod dlc enddate_3yr if dod!=. & dod>dot+(365.25*3)
count if dod!=. & dod>dot+(365.25*5) & dxyr<2015 //14
//list pid deceased_5yr dot dod dlc enddate_5yr if dod!=. & dod>dot+(365.25*5)

replace deceased_1yr=0 if dod!=. & dod>dot+(365.25*1) //517 changes
replace deceased_3yr=0 if dod!=. & dod>dot+(365.25*3) //151 changes
replace deceased_5yr=0 if dod!=. & dod>dot+(365.25*5) & dxyr<2015 //14 changes

** set to missing those who have dod>1 year from incidence date - but
** first create new variable for time to death/date last seen, called "time"
** (1) use dod to define time to death if died within 1, 3, 5 yrs
gen time_1yr=dod-dot if (dod!=. & deceased_1yr==1 & dod<dot+(365.25*1))
gen time_3yr=dod-dot if (dod!=. & deceased_3yr==1 & dod<dot+(365.25*3))
gen time_5yr=dod-dot if (dod!=. & deceased_5yr==1 & dod<dot+(365.25*5) & dxyr<2015)

** (2) next use 1, 3, 5 yrs as time, if died >1, >3, >5 yrs from incidence
count if (enddate_1yr<dod & dod!=. & deceased_1yr==1) //0
replace time_1yr=enddate_1yr-dot if (enddate_1yr<dod & dod!=. & deceased_1yr==1) //0 changes
count if (enddate_3yr<dod & dod!=. & deceased_3yr==1) //0
replace time_3yr=enddate_3yr-dot if (enddate_3yr<dod & dod!=. & deceased_3yr==1) //0 changes
count if (enddate_5yr<dod & dod!=. & deceased_5yr==1 & dxyr<2015) //0
replace time_5yr=enddate_5yr-dot if (enddate_5yr<dod & dod!=. & deceased_5yr==1 & dxyr<2015) //0 changes

** (2) next use dlc as end date, if alive and have date last seen (dlc)
count if (dlc<enddate_1yr & deceased_1yr==0) //916
replace time_1yr=dlc-dot if (dlc<enddate_1yr & deceased_1yr==0) //916 changes
count if (dlc<enddate_3yr & deceased_3yr==0) //1054
replace time_3yr=dlc-dot if (dlc<enddate_3yr & deceased_3yr==0) //1054 changes
count if (dlc<enddate_5yr & deceased_5yr==0 & dxyr<2015) //620
replace time_5yr=dlc-dot if (dlc<enddate_5yr & deceased_5yr==0 & dxyr<2015) //620 changes

//tab time_1yr ,m //875=missing; 298=0; 1060=missing; 546=0
//tab time_3yr ,m //292=missing; 298=0; 336=missing; 535=0
//tab time_5yr if dxyr<2015 ,m //48=missing; 86=0; 58=missing; 273=0
//list time_1yr dot dlc enddate_1yr dod deceased_1yr if time_1yr==.
replace time_1yr=enddate_1yr-dot if (enddate_1yr<dlc & deceased_1yr==0) & time_1yr==. & dlc!=. //659 changes
replace time_3yr=enddate_3yr-dot if (enddate_3yr<dlc & deceased_3yr==0) & time_3yr==. & dlc!=. //155 changes
replace time_5yr=enddate_5yr-dot if (enddate_5yr<dlc & deceased_5yr==0) & time_5yr==. & dlc!=. & dxyr<2015 //15 changes

count if time_1yr==. //0
count if time_3yr==. //0
count if time_5yr==. & dxyr<2015 //0

replace time_1yr=dlc-dot if deceased_1yr==0 & time_1yr==. //0 changes
replace time_3yr=dlc-dot if deceased_3yr==0 & time_3yr==. //0 changes
replace time_5yr=dlc-dot if deceased_5yr==0 & time_5yr==. & dxyr<2015 //0 changes

** these are from above - change dod to missing (deceased already
** set to 0 above) as they did not die within 1, 3, 5, 10 years
gen dod_1yr=dod
gen dod_3yr=dod
gen dod_5yr=dod 
format dod_* %tdCCYY-NN-DD

replace dod_1yr=. if enddate_1yr<dod_1yr & dod_1yr!=. //517 changes
replace dod_3yr=. if enddate_3yr<dod_3yr & dod_3yr!=. //151 changes
replace dod_5yr=. if enddate_5yr<dod_5yr & dod_5yr!=. & dxyr<2015 //14 changes

sort enddate_*
tab enddate_1yr ,m 
tab enddate_3yr ,m 
tab enddate_5yr if dxyr<2015 ,m

** Now to set up dataset for survival analysis, we need each patient's date of
** entry to study (incidence date, or dot), and exit date from study which is end_date
** UNLESS they died before end_date or were last seen before end_date in which case
** they should be censored... so now we create a NEW end_date as a combination of
** the above

** Below code added so that all 'censored' cases should have 
** newenddate = 31-dec-2018 if newenddate < 31-dec-2018
sort dot
sort pid
//list deceased_1yr dot newenddate_1yr if deceased_1yr!=1
//list deceased_3yr dot newenddate_3yr if deceased_3yr!=1
//list deceased_5yr dot dlc newenddate_5yr if deceased_5yr!=1
count if dlc>d(31dec2019) & deceased_1yr!=1 //4-dlc in 2019; 0
count if dlc>d(31dec2019) & deceased_3yr!=1 //4; 0
count if dlc>d(31dec2019) & deceased_5yr!=1 //4; 0
//list pid dot dlc deceased_1yr if dlc>d(31dec2019) & deceased_1yr!=1

** Create new end_date based on fixed censored date of 31dec2018 (last date of current death data)
//list pid dot deceased_1yr dod dlc end_date
count if (enddate_1yr>dod_1yr & dod_1yr!=. & deceased_1yr==1) //836
count if (enddate_3yr>dod_3yr & dod_3yr!=. & deceased_3yr==1) //1202
count if (enddate_5yr>dod_5yr & dod_5yr!=. & deceased_5yr==1 & dxyr<2015) //902
gen newenddate_1yr=d(31dec2019) if deceased_1yr!=1
gen newenddate_3yr=d(31dec2019) if deceased_3yr!=1
gen newenddate_5yr=d(31dec2019) if deceased_5yr!=1

/* old method
gen newenddate_1yr=dod_1yr if (enddate_1yr>dod_1yr & dod_1yr!=. & deceased_1yr==1)
gen newenddate_3yr=dod_3yr if (enddate_3yr>dod_3yr & dod_3yr!=. & deceased_3yr==1)
gen newenddate_5yr=dod_5yr if (enddate_5yr>dod_5yr & dod_5yr!=. & deceased_5yr==1 & dxyr<2014)

count if (dlc<enddate_1yr) & dod_1yr==. & deceased_1yr==0 //1034
count if (dlc<enddate_3yr) & dod_3yr==. & deceased_3yr==0 //1263
count if (dlc<enddate_5yr) & dod_5yr==. & deceased_5yr==0 & dxyr<2014 //571
replace newenddate_1yr=dlc if (dlc<enddate_1yr) & dod_1yr==. & deceased_1yr==0 //588 changes
replace newenddate_3yr=dlc if (dlc<enddate_3yr) & dod_3yr==. & deceased_3yr==0 //808 changes
replace newenddate_5yr=dlc if (dlc<enddate_5yr) & dod_5yr==. & deceased_5yr==0 & dxyr<2014 //572 changes
*/
count if newenddate_1yr==. //836
count if newenddate_3yr==. //1202
count if newenddate_5yr==. & dxyr<2015 //902

//list dot deceased_1yr dod_1yr dlc enddate_1yr if newenddate_1yr==.
replace newenddate_1yr=enddate_1yr if newenddate_1yr==. //836 changes
replace newenddate_3yr=enddate_3yr if newenddate_3yr==. //1202 changes
replace newenddate_5yr=enddate_5yr if newenddate_5yr==. & dxyr<2015 //902 changes
format newenddate_* %dD_m_CY

sort dot
tab time_1yr ,m //659=365.25
tab time_3yr ,m //155=1095.75
tab time_5yr if dxyr<2015 ,m //15=1826.25

replace time_1yr=365 if time_1yr==365.25 //659 changes
replace time_3yr=1095 if time_3yr==1095.75 //155 changes
replace time_5yr=1826 if time_5yr==1826.25 //15 changes

count if time_1yr==0 //520
count if time_3yr==0 //510
count if time_5yr==0 //257
//list basis deceased_1yr dot dod_1yr dlc enddate_1yr newenddate_1yr if time_1yr==0 ,noobs
//list basis deceased_3yr dot dod_3yr dlc enddate_3yr newenddate_3yr if time_3yr==0 ,noobs
//list basis deceased_5yr dot dod_5yr dlc enddate_5yr newenddate_5yr if time_5yr==0 ,noobs
//list basis deceased_10yr dot dod_10yr dlc enddate_10yr newenddate_10yr if time_10yr==0 ,noobs

** Since DCOs have been removed from this dataset, all cases whether dead or censored
** should have at least a value of 1 day
/* old method when DCOs were in ds
replace newend_date=newend_date+1 if (time==0 & deceased==0)
replace time=1 if (time==0 & deceased==0) //241 changes
*/
replace newenddate_1yr=newenddate_1yr+1 if time_1yr==0 //520 changes
replace time_1yr=1 if time_1yr==0 //520 changes
replace newenddate_3yr=newenddate_3yr+1 if time_3yr==0 //510 changes
replace time_3yr=1 if time_3yr==0 //510 changes
replace newenddate_5yr=newenddate_5yr+1 if time_5yr==0 //257 changes
replace time_5yr=1 if time_5yr==0 //257 changes

tab deceased ,m 
tab deceased_1yr ,m
tab deceased_3yr ,m 
tab deceased_5yr ,m 

count //2411


tab deceased_1yr dxyr ,m
tab deceased_3yr dxyr ,m
tab deceased_5yr dxyr if dxyr<2015 ,m


** Create survival variables by dxyr
gen surv1yr_2013=1 if deceased_1yr==1 & dxyr==2013
replace surv1yr_2013=0 if deceased_1yr==0 & dxyr==2013
gen surv3yr_2013=1 if deceased_3yr==1 & dxyr==2013
replace surv3yr_2013=0 if deceased_3yr==0 & dxyr==2013
gen surv5yr_2013=1 if deceased_5yr==1 & dxyr==2013
replace surv5yr_2013=0 if deceased_5yr==0 & dxyr==2013
gen surv1yr_2014=1 if deceased_1yr==1 & dxyr==2014
replace surv1yr_2014=0 if deceased_1yr==0 & dxyr==2014
gen surv3yr_2014=1 if deceased_3yr==1 & dxyr==2014
replace surv3yr_2014=0 if deceased_3yr==0 & dxyr==2014
gen surv5yr_2014=1 if deceased_5yr==1 & dxyr==2014
replace surv5yr_2014=0 if deceased_5yr==0 & dxyr==2014
gen surv1yr_2015=1 if deceased_1yr==1 & dxyr==2015
replace surv1yr_2015=0 if deceased_1yr==0 & dxyr==2015
gen surv3yr_2015=1 if deceased_3yr==1 & dxyr==2015
replace surv3yr_2015=0 if deceased_3yr==0 & dxyr==2015
label define surv_lab 0 "censored" 1 "dead", modify
label values surv1yr_2013 surv3yr_2013 surv5yr_2013 surv1yr_2014 surv3yr_2014 surv5yr_2014 surv1yr_2015 surv3yr_2015 surv_lab
label var surv1yr_2013 "Survival at 1yr - 2013"
label var surv3yr_2013 "Survival at 3yrs - 2013"
label var surv5yr_2013 "Survival at 5yrs - 2013"
label var surv1yr_2014 "Survival at 1yr - 2014"
label var surv3yr_2014 "Survival at 3yrs - 2014"
label var surv5yr_2014 "Survival at 5yrs - 2014"
label var surv1yr_2015 "Survival at 1yr - 2015"
label var surv3yr_2015 "Survival at 3yrs - 2015"

tab dxyr ,m
tab surv1yr_2013 if dxyr==2013 ,m
tab surv3yr_2013 if dxyr==2013 ,m
tab surv5yr_2013 if dxyr==2013 ,m
tab surv1yr_2014 if dxyr==2014 ,m
tab surv3yr_2014 if dxyr==2014 ,m
tab surv5yr_2014 if dxyr==2014 ,m
tab surv1yr_2015 if dxyr==2015 ,m
tab surv3yr_2015 if dxyr==2015 ,m


** Top 10 survival at 1, 3, 5 years by diagnosis year
**********
** 2013 **
**********
** PROSTATE
tab surv1yr_2013 if siteiarc==39 //prostate 1-yr survival
tab surv3yr_2013 if siteiarc==39 //prostate 3-yr survival
tab surv5yr_2013 if siteiarc==39 //prostate 5-yr survival
** BREAST
tab surv1yr_2013 if siteiarc==29 //breast 1-yr survival
tab surv3yr_2013 if siteiarc==29 //breast 3-yr survival
tab surv5yr_2013 if siteiarc==29 //breast 5-yr survival
** COLON
tab surv1yr_2013 if siteiarc==13 //colon 1-yr survival
tab surv3yr_2013 if siteiarc==13 //colon 3-yr survival
tab surv5yr_2013 if siteiarc==13 //colon 5-yr survival
** CORPUS UTERI
tab surv1yr_2013 if siteiarc==33 //corpus uteri 1-yr survival
tab surv3yr_2013 if siteiarc==33 //corpus uteri 3-yr survival
tab surv5yr_2013 if siteiarc==33 //corpus uteri 5-yr survival
** RECTUM
tab surv1yr_2013 if siteiarc==14 //rectum 1-yr survival
tab surv3yr_2013 if siteiarc==14 //rectum 3-yr survival
tab surv5yr_2013 if siteiarc==14 //rectum 5-yr survival
** LUNG
tab surv1yr_2013 if siteiarc==21 //lung 1-yr survival
tab surv3yr_2013 if siteiarc==21 //lung 3-yr survival
tab surv5yr_2013 if siteiarc==21 //lung 5-yr survival
** CERVIX
tab surv1yr_2013 if siteiarc==32 //cervix 1-yr survival
tab surv3yr_2013 if siteiarc==32 //cervix 3-yr survival
tab surv5yr_2013 if siteiarc==32 //cervix 5-yr survival
** STOMACH
tab surv1yr_2013 if siteiarc==11 //stomach 1-yr survival
tab surv3yr_2013 if siteiarc==11 //stomach 3-yr survival
tab surv5yr_2013 if siteiarc==11 //stomach 5-yr survival
** MULTIPLE MYELOMA 
tab surv1yr_2013 if siteiarc==55 //mm  1-yr survival
tab surv3yr_2013 if siteiarc==55 //mm  3-yr survival
tab surv5yr_2013 if siteiarc==55 //mm  5-yr survival
** NON-HODGKIN LYMPHOMA
tab surv1yr_2013 if siteiarc==53 //nhl  1-yr survival
tab surv3yr_2013 if siteiarc==53 //nhl  3-yr survival
tab surv5yr_2013 if siteiarc==53 //nhl  5-yr survival

**********
** 2014 **
**********
** PROSTATE
tab surv1yr_2014 if siteiarc==39 //prostate 1-yr survival
tab surv3yr_2014 if siteiarc==39 //prostate 3-yr survival
tab surv5yr_2014 if siteiarc==39 //prostate 5-yr survival
** BREAST
tab surv1yr_2014 if siteiarc==29 //breast 1-yr survival
tab surv3yr_2014 if siteiarc==29 //breast 3-yr survival
tab surv5yr_2014 if siteiarc==29 //breast 5-yr survival
** COLON
tab surv1yr_2014 if siteiarc==13 //colon 1-yr survival
tab surv3yr_2014 if siteiarc==13 //colon 3-yr survival
tab surv5yr_2014 if siteiarc==13 //colon 5-yr survival
** CORPUS UTERI
tab surv1yr_2014 if siteiarc==33 //corpus uteri 1-yr survival
tab surv3yr_2014 if siteiarc==33 //corpus uteri 3-yr survival
tab surv5yr_2014 if siteiarc==33 //corpus uteri 5-yr survival
** RECTUM
tab surv1yr_2014 if siteiarc==14 //rectum 1-yr survival
tab surv3yr_2014 if siteiarc==14 //rectum 3-yr survival
tab surv5yr_2014 if siteiarc==14 //rectum 5-yr survival
** LUNG
tab surv1yr_2014 if siteiarc==21 //lung 1-yr survival
tab surv3yr_2014 if siteiarc==21 //lung 3-yr survival
tab surv5yr_2014 if siteiarc==21 //lung 5-yr survival
** CERVIX
tab surv1yr_2014 if siteiarc==32 //cervix 1-yr survival
tab surv3yr_2014 if siteiarc==32 //cervix 3-yr survival
tab surv5yr_2014 if siteiarc==32 //cervix 5-yr survival
** STOMACH
tab surv1yr_2014 if siteiarc==11 //stomach 1-yr survival
tab surv3yr_2014 if siteiarc==11 //stomach 3-yr survival
tab surv5yr_2014 if siteiarc==11 //stomach 5-yr survival
** MULTIPLE MYELOMA 
tab surv1yr_2014 if siteiarc==55 //mm  1-yr survival
tab surv3yr_2014 if siteiarc==55 //mm  3-yr survival
tab surv5yr_2014 if siteiarc==55 //mm  5-yr survival
** NON-HODGKIN LYMPHOMA
tab surv1yr_2014 if siteiarc==53 //nhl  1-yr survival
tab surv3yr_2014 if siteiarc==53 //nhl  3-yr survival
tab surv5yr_2014 if siteiarc==53 //nhl  5-yr survival


**********
** 2015 **
**********
** PROSTATE
tab surv1yr_2015 if siteiarc==39 //prostate 1-yr survival
tab surv3yr_2015 if siteiarc==39 //prostate 3-yr survival
** BREAST
tab surv1yr_2015 if siteiarc==29 //breast 1-yr survival
tab surv3yr_2015 if siteiarc==29 //breast 3-yr survival
** COLON
tab surv1yr_2015 if siteiarc==13 //colon 1-yr survival
tab surv3yr_2015 if siteiarc==13 //colon 3-yr survival
** CORPUS UTERI
tab surv1yr_2015 if siteiarc==33 //corpus uteri 1-yr survival
tab surv3yr_2015 if siteiarc==33 //corpus uteri 3-yr survival
** RECTUM
tab surv1yr_2015 if siteiarc==14 //rectum 1-yr survival
tab surv3yr_2015 if siteiarc==14 //rectum 3-yr survival
** LUNG
tab surv1yr_2015 if siteiarc==21 //lung 1-yr survival
tab surv3yr_2015 if siteiarc==21 //lung 3-yr survival
** CERVIX
tab surv1yr_2015 if siteiarc==32 //cervix 1-yr survival
tab surv3yr_2015 if siteiarc==32 //cervix 3-yr survival
** STOMACH
tab surv1yr_2015 if siteiarc==11 //stomach 1-yr survival
tab surv3yr_2015 if siteiarc==11 //stomach 3-yr survival
** MULTIPLE MYELOMA 
tab surv1yr_2015 if siteiarc==55 //mm  1-yr survival
tab surv3yr_2015 if siteiarc==55 //mm  3-yr survival
** NON-HODGKIN LYMPHOMA
tab surv1yr_2015 if siteiarc==53 //nhl  1-yr survival
tab surv3yr_2015 if siteiarc==53 //nhl  3-yr survival


** Create patient total variables to use in 30_report cancer.do
tab patient dxyr ,m
egen pttotsurv_2015=count(patient) if patient==1 & dxyr==2015
egen pttotsurv_2014=count(patient) if patient==1 & dxyr==2014
egen pttotsurv_2013=count(patient) if patient==1 & dxyr==2013
egen pttotsurv_2008=count(patient) if patient==1 & dxyr==2008

count //2411

** Save this corrected dataset with only reportable cases
save "`datapath'\version02\3-output\2013_2014_2015_cancer_survival", replace
label data "2013 2014 2015 BNR-Cancer analysed data - Survival BNR Reportable Dataset"
note: TS This dataset was used for 2015 annual report
note: TS For survival analysis, use variables surv1yr_2013, surv1yr_2014, surv1yr_2015, surv3yr_2013, surv3yr_2014, surv3yr_2015, surv5yr_2013, surv5yr_2014


