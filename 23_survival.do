** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          23_survival.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      22-AUG-2022
    // 	date last modified      22-AUG-2022
    //  algorithm task          Creating survival dataset using cleaned, current cancer dataset post death matching
    //  status                  Completed
    //  objective               To have a cleaned and matched survival dataset
    //  methods                 Removing cases not used by IARC in standard survival analysis

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
    log using "`logpath'\23_survival.smcl", replace
** HEADER -----------------------------------------------------

* ************************************************************************
* PREP AND FORMAT
**************************************************************************

************************
**   2008, 2013-2018  **
**  Survival Datasets **
************************
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
* Survival analysis to 1 year, 3 years, 5 years and 10 years
**************************************************************************
** Load the dataset
use "`datapath'\version09\3-output\2008_2013-2018_cancer_reportable_nonsurvival_deidentified" ,clear

** Update dataset to meet IARC standards for calculating survival
tab patient ,m 
tab persearch ,m 
tab eidmp ,m 
count if patient==2 & persearch==1 //0
//list pid fname lname if patient==2 & persearch==1

count //6682

drop if basis==0 //469 deleted - DCO 
drop if age>100 //3 deleted - age 100+
drop if slc==99 //0 deleted - status at last contact unknown
drop if patient!=1 //127 deleted - MP
drop if resident==2 //0 deleted - nonresident
drop if resident==99 //0 deleted - resident unknown
drop if recstatus==3 //0 deleted - ineligible case definition
drop if sex==9 //0 deleted - sex unknown
drop if beh!=3 //0 deleted - nonmalignant
drop if persearch>2 //0 to be deleted
drop if siteiarc==25 & morph!=8832 & morph!=8247 & morph!=9700 & morph!=8410 //0 deleted - nonreportable skin cancers: 7 are non-melanoma skin cancers but they don't fall into the non-reportable skin cancer category; 1 is missed 2008 NMSC to be included in 2008,2013-2015 nonreportable ds

count //6083

** now ensure everyone has a unique id
count if pid=="" //0

recode deceased 2=0 //2434 changes

gen deceased_1yr=deceased
gen deceased_3yr=deceased
gen deceased_5yr=deceased
gen deceased_10yr=deceased
label drop deceased_lab
label define deceased_lab 0 "censored" 1 "dead", modify
label values deceased deceased_1yr deceased_3yr deceased_5yr deceased_10yr deceased_lab
label var deceased "Survival identifer"
label var deceased_1yr "Survival identifer at 1yr"
label var deceased_3yr "Survival identifer at 3yrs"
label var deceased_5yr "Survival identifer at 5yrs"
label var deceased_10yr "Survival identifer at 10yrs"

tab deceased ,m //3649 dead; 2434 censored
tab deceased_1yr ,m //3649 dead; 2434 censored
tab deceased_3yr ,m //3649 dead; 2434 censored
tab deceased_5yr ,m //3649 dead; 2434 censored
tab deceased_10yr ,m //3649 dead; 2434 censored
count if dlc==. //0
count if dod==. //2434

** check for all patients who are deceased but missing dod
count if deceased==1 & dod==. //0
count if deceased_1yr==1 & dod==. //0
count if deceased_3yr==1 & dod==. //0
count if deceased_5yr==1 & dod==. //0
count if deceased_10yr==1 & dod==. //0

count if dot==. //0

** Create end_date variables: 1 year, 3 years, 5 years and 10 years from incidence
gen enddate_1yr=(dot+(365.25*1)) if dot!=.
gen enddate_3yr=(dot+(365.25*3)) if dot!=.
gen enddate_5yr=(dot+(365.25*5)) if dot!=. & dxyr<2017 //2021 death data added so 2015 now included in 5yr
gen enddate_10yr=(dot+(365.25*10)) if dot!=. & dxyr==2008

format enddate* %dD_m_CY

count if enddate_1yr==. //0
count if enddate_3yr==. //0
count if enddate_5yr==. & dxyr<2017 //0
count if enddate_10yr==. & dxyr==2008 //0

** Since end_date is 1, 3, 5, 10 years from incidence, reset deceased from dead to censored if pt died after end_date
count if dod!=. & dod>dot+(365.25*1) //1579
//list pid deceased_1yr dot dod dlc enddate_1yr if dod!=. & dod>dot+(365.25*1)
count if dod!=. & dod>dot+(365.25*3) //667
//list pid deceased_3yr dot dod dlc enddate_3yr if dod!=. & dod>dot+(365.25*3)
count if dod!=. & dod>dot+(365.25*5) & dxyr<2017 //292
//list pid deceased_5yr dot dod dlc enddate_5yr if dod!=. & dod>dot+(365.25*5)
count if dod!=. & dod>dot+(365.25*10) & dxyr==2008 //42
//list pid deceased_10yr dot dod dlc enddate_10yr if dod!=. & dod>dot+(365.25*10)

replace deceased_1yr=0 if dod!=. & dod>dot+(365.25*1) //1579 changes
replace deceased_3yr=0 if dod!=. & dod>dot+(365.25*3) //667 changes
replace deceased_5yr=0 if dod!=. & dod>dot+(365.25*5) & dxyr<2017 //292 changes
replace deceased_10yr=0 if dod!=. & dod>dot+(365.25*10) & dxyr==2008 //42 changes

** set to missing those who have dod>1 year from incidence date - but
** first create new variable for time to death/date last seen, called "time"
** (1) use dod to define time to death if died within 1, 3, 5, 10 yrs
gen time_1yr=dod-dot if (dod!=. & deceased_1yr==1 & dod<dot+(365.25*1))
gen time_3yr=dod-dot if (dod!=. & deceased_3yr==1 & dod<dot+(365.25*3))
gen time_5yr=dod-dot if (dod!=. & deceased_5yr==1 & dod<dot+(365.25*5) & dxyr<2017)
gen time_10yr=dod-dot if (dod!=. & deceased_10yr==1 & dod<dot+(365.25*10) & dxyr==2008)

** For IARC-CRICCS submission 31-oct-2021, create time variable for time from:
** (1) incidence date to death
** (2) incidence date to 31-dec-2021 (death data being included in submission)
gen time_criccs=dod-dot if dod!=.
replace time_criccs=d(31dec2021)-dot if dod==.
label var time_criccs "Survival Time in Days"

** (2) next use 1, 3, 5 yrs as time, if died >1, >3, >5, >10 yrs from incidence
count if (enddate_1yr<dod & dod!=. & deceased_1yr==1) //0
replace time_1yr=enddate_1yr-dot if (enddate_1yr<dod & dod!=. & deceased_1yr==1) //0 changes
count if (enddate_3yr<dod & dod!=. & deceased_3yr==1) //0
replace time_3yr=enddate_3yr-dot if (enddate_3yr<dod & dod!=. & deceased_3yr==1) //0 changes
count if (enddate_5yr<dod & dod!=. & deceased_5yr==1 & dxyr<2017) //0
replace time_5yr=enddate_5yr-dot if (enddate_5yr<dod & dod!=. & deceased_5yr==1 & dxyr<2017) //0 changes
count if (enddate_10yr<dod & dod!=. & deceased_10yr==1 & dxyr==2008) //0
replace time_10yr=enddate_10yr-dot if (enddate_10yr<dod & dod!=. & deceased_10yr==1 & dxyr==2008) //0 changes

** (2) next use dlc as end date, if alive and have date last seen (dlc)
count if (dlc<enddate_1yr & deceased_1yr==0) //1952
replace time_1yr=dlc-dot if (dlc<enddate_1yr & deceased_1yr==0) //1952 changes
count if (dlc<enddate_3yr & deceased_3yr==0) //2237
replace time_3yr=dlc-dot if (dlc<enddate_3yr & deceased_3yr==0) //2237 changes
count if (dlc<enddate_5yr & deceased_5yr==0 & dxyr<2017) //1576
replace time_5yr=dlc-dot if (dlc<enddate_5yr & deceased_5yr==0 & dxyr<2017) //1576 changes
count if (dlc<enddate_10yr & deceased_10yr==0 & dxyr==2008) //200
replace time_10yr=dlc-dot if (dlc<enddate_10yr & deceased_10yr==0 & dxyr==2008) //200 changes

//tab time_1yr ,m //875=missing; 298=0; 1060=missing; 546=0
//tab time_3yr ,m //292=missing; 298=0; 336=missing; 535=0
//tab time_5yr ,m //48=missing; 86=0; 58=missing; 273=0
//tab time_10yr if dxyr==2008 ,m //5=missing; 17=0; 6=missing; 16=0
//list time_1yr dot dlc enddate_1yr dod deceased_1yr if time_1yr==.
replace time_1yr=enddate_1yr-dot if (enddate_1yr<dlc & deceased_1yr==0) & time_1yr==. & dlc!=. //2061 changes
replace time_3yr=enddate_3yr-dot if (enddate_3yr<dlc & deceased_3yr==0) & time_3yr==. & dlc!=. //864 changes
replace time_5yr=enddate_5yr-dot if (enddate_5yr<dlc & deceased_5yr==0) & time_5yr==. & dlc!=. & dxyr<2017 //289 changes
replace time_10yr=enddate_10yr-dot if (enddate_10yr<dlc & deceased_10yr==0) & time_10yr==. & dlc!=. & dxyr==2008 //38 changes

count if time_1yr==. //0
count if time_3yr==. //0
count if time_5yr==. & dxyr<2017 //0
count if time_10yr==. & dxyr==2008 //0

replace time_1yr=dlc-dot if deceased_1yr==0 & time_1yr==. //0 changes
replace time_3yr=dlc-dot if deceased_3yr==0 & time_3yr==. //0 changes
replace time_5yr=dlc-dot if deceased_5yr==0 & time_5yr==. & dxyr<2017 //0 changes
replace time_10yr=dlc-dot if deceased_10yr==0 & time_10yr==. & dxyr==2008 //0 changes

** these are from above - change dod to missing (deceased already
** set to 0 above) as they did not die within 1, 3, 5, 10 years
gen dod_1yr=dod
gen dod_3yr=dod
gen dod_5yr=dod 
gen dod_10yr=dod 
format dod_* %tdCCYY-NN-DD

replace dod_1yr=. if enddate_1yr<dod_1yr & dod_1yr!=. //1579 changes
replace dod_3yr=. if enddate_3yr<dod_3yr & dod_3yr!=. //667 changes
replace dod_5yr=. if enddate_5yr<dod_5yr & dod_5yr!=. & dxyr<2017 //292 changes
replace dod_10yr=. if enddate_10yr<dod_10yr & dod_10yr!=. & dxyr==2008 //42 changes

sort enddate_*
tab enddate_1yr ,m 
tab enddate_3yr ,m 
tab enddate_5yr if dxyr<2017 ,m
tab enddate_10yr if dxyr==2008 ,m

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
//list deceased_10yr dot newenddate_10yr if deceased_10yr!=1
count if dlc>d(31dec2021) & deceased_1yr!=1 //59-dlc in 2022
count if dlc>d(31dec2021) & deceased_3yr!=1 //59-dlc in 2022
count if dlc>d(31dec2021) & deceased_5yr!=1 //57-dlc in 2022
count if dlc>d(31dec2021) & deceased_10yr!=1 //57-dlc in 2022
//list pid dot dlc deceased_1yr if dlc>d(31dec2021) & deceased_1yr!=1
//list pid dot dlc deceased_1yr if dlc>d(31dec2021) & deceased_3yr!=1
//list pid dot dlc deceased_1yr if dlc>d(31dec2021) & deceased_5yr!=1
//list pid dot dlc deceased_1yr if dlc>d(31dec2021) & deceased_10yr!=1

** Create new end_date based on fixed censored date of 31dec2018 (last date of current death data)
//list pid dot deceased_1yr dod dlc end_date
count if (enddate_1yr>dod_1yr & dod_1yr!=. & deceased_1yr==1) //2070
count if (enddate_3yr>dod_3yr & dod_3yr!=. & deceased_3yr==1) //2982
count if (enddate_5yr>dod_5yr & dod_5yr!=. & deceased_5yr==1 & dxyr<2017) //2452
count if (enddate_10yr>dod_10yr & dod_10yr!=. & deceased_10yr==1 & dxyr==2008) //518
gen newenddate_1yr=d(31dec2021) if deceased_1yr!=1
gen newenddate_3yr=d(31dec2021) if deceased_3yr!=1
gen newenddate_5yr=d(31dec2021) if deceased_5yr!=1
gen newenddate_10yr=d(31dec2021) if deceased_10yr!=1

/* old method
gen newenddate_1yr=dod_1yr if (enddate_1yr>dod_1yr & dod_1yr!=. & deceased_1yr==1)
gen newenddate_3yr=dod_3yr if (enddate_3yr>dod_3yr & dod_3yr!=. & deceased_3yr==1)
gen newenddate_5yr=dod_5yr if (enddate_5yr>dod_5yr & dod_5yr!=. & deceased_5yr==1 & dxyr<2014)
gen newenddate_10yr=dod_10yr if (enddate_10yr>dod_10yr & dod_10yr!=. & deceased_10yr==1 & dxyr==2008)

count if (dlc<enddate_1yr) & dod_1yr==. & deceased_1yr==0 //1034
count if (dlc<enddate_3yr) & dod_3yr==. & deceased_3yr==0 //1263
count if (dlc<enddate_5yr) & dod_5yr==. & deceased_5yr==0 & dxyr<2014 //571
count if (dlc<enddate_10yr) & dod_10yr==. & deceased_10yr==0 & dxyr==2008 //230
replace newenddate_1yr=dlc if (dlc<enddate_1yr) & dod_1yr==. & deceased_1yr==0 //588 changes
replace newenddate_3yr=dlc if (dlc<enddate_3yr) & dod_3yr==. & deceased_3yr==0 //808 changes
replace newenddate_5yr=dlc if (dlc<enddate_5yr) & dod_5yr==. & deceased_5yr==0 & dxyr<2014 //572 changes
replace newenddate_10yr=dlc if (dlc<enddate_10yr) & dod_10yr==. & deceased_10yr==0 & dxyr==2008 //229 changes
*/
count if newenddate_1yr==. //2070
count if newenddate_3yr==. //2982
count if newenddate_5yr==. & dxyr<2017 //2452
count if newenddate_10yr==. & dxyr==2008 //518

//list dot deceased_1yr dod_1yr dlc enddate_1yr if newenddate_1yr==.
replace newenddate_1yr=enddate_1yr if newenddate_1yr==. //2070 changes
replace newenddate_3yr=enddate_3yr if newenddate_3yr==. //2982 changes
replace newenddate_5yr=enddate_5yr if newenddate_5yr==. & dxyr<2017 //2452 changes
replace newenddate_10yr=enddate_10yr if newenddate_10yr==. & dxyr==2008 //518 changes
format newenddate_* %dD_m_CY

sort dot
tab time_1yr ,m //2061=365.25
tab time_3yr ,m //864=1095.75
tab time_5yr if dxyr<2017 ,m //289=1826.25
tab time_10yr if dxyr==2008 ,m //38=3652.5

replace time_1yr=365 if time_1yr==365.25 //2061 changes
replace time_3yr=1095 if time_3yr==1095.75 //864 changes
replace time_5yr=1826 if time_5yr==1826.25 //289 changes
replace time_10yr=3652 if time_10yr==3652.5 //38 changes

count if time_1yr==0 //1004
count if time_3yr==0 //990
count if time_5yr==0 //666
count if time_10yr==0 //15
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
replace newenddate_1yr=newenddate_1yr+1 if time_1yr==0 //1004
replace time_1yr=1 if time_1yr==0 //1004 changes
replace newenddate_3yr=newenddate_3yr+1 if time_3yr==0 //990 changes
replace time_3yr=1 if time_3yr==0 //990 changes
replace newenddate_5yr=newenddate_5yr+1 if time_5yr==0 //666 changes
replace time_5yr=1 if time_5yr==0 //666 changes
replace newenddate_10yr=newenddate_10yr+1 if time_10yr==0 //15 changes
replace time_10yr=1 if time_10yr==0 //15 changes

tab deceased ,m 
tab deceased_1yr ,m
tab deceased_3yr ,m 
tab deceased_5yr ,m 
tab deceased_10yr ,m 

count //6083


tab deceased_1yr dxyr ,m
tab deceased_3yr dxyr ,m
tab deceased_5yr dxyr if dxyr<2017 ,m
tab deceased_10yr dxyr if dxyr==2008 ,m


** Create survival variables by dxyr
gen surv1yr_2008=1 if deceased_1yr==1 & dxyr==2008
replace surv1yr_2008=0 if deceased_1yr==0 & dxyr==2008
gen surv3yr_2008=1 if deceased_3yr==1 & dxyr==2008
replace surv3yr_2008=0 if deceased_3yr==0 & dxyr==2008
gen surv5yr_2008=1 if deceased_5yr==1 & dxyr==2008
replace surv5yr_2008=0 if deceased_5yr==0 & dxyr==2008
gen surv10yr_2008=1 if deceased_10yr==1 & dxyr==2008
replace surv10yr_2008=0 if deceased_10yr==0 & dxyr==2008
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
gen surv5yr_2015=1 if deceased_5yr==1 & dxyr==2015
replace surv5yr_2015=0 if deceased_5yr==0 & dxyr==2015
gen surv1yr_2016=1 if deceased_1yr==1 & dxyr==2016
replace surv1yr_2016=0 if deceased_1yr==0 & dxyr==2016
gen surv3yr_2016=1 if deceased_3yr==1 & dxyr==2016
replace surv3yr_2016=0 if deceased_3yr==0 & dxyr==2016
gen surv5yr_2016=1 if deceased_5yr==1 & dxyr==2016
replace surv5yr_2016=0 if deceased_5yr==0 & dxyr==2016
gen surv1yr_2017=1 if deceased_1yr==1 & dxyr==2017
replace surv1yr_2017=0 if deceased_1yr==0 & dxyr==2017
gen surv3yr_2017=1 if deceased_3yr==1 & dxyr==2017
replace surv3yr_2017=0 if deceased_3yr==0 & dxyr==2017
gen surv1yr_2018=1 if deceased_1yr==1 & dxyr==2018
replace surv1yr_2018=0 if deceased_1yr==0 & dxyr==2018
gen surv3yr_2018=1 if deceased_3yr==1 & dxyr==2018
replace surv3yr_2018=0 if deceased_3yr==0 & dxyr==2018

label define surv_lab 0 "censored" 1 "dead", modify
label values surv1yr_2008 surv3yr_2008 surv5yr_2008 surv10yr_2008 surv1yr_2013 surv3yr_2013 surv5yr_2013 surv1yr_2014 surv3yr_2014 surv5yr_2014 surv1yr_2015 surv3yr_2015 surv5yr_2015 surv1yr_2016 surv3yr_2016 surv5yr_2016 surv1yr_2017 surv3yr_2017 surv1yr_2018 surv3yr_2018 surv_lab
label var surv1yr_2008 "Survival at 1yr - 2008"
label var surv3yr_2008 "Survival at 3yrs - 2008"
label var surv5yr_2008 "Survival at 5yrs - 2008"
label var surv10yr_2008 "Survival at 10yrs - 2008"
label var surv1yr_2013 "Survival at 1yr - 2013"
label var surv3yr_2013 "Survival at 3yrs - 2013"
label var surv5yr_2013 "Survival at 5yrs - 2013"
label var surv1yr_2014 "Survival at 1yr - 2014"
label var surv3yr_2014 "Survival at 3yrs - 2014"
label var surv5yr_2014 "Survival at 5yrs - 2014"
label var surv1yr_2015 "Survival at 1yr - 2015"
label var surv3yr_2015 "Survival at 3yrs - 2015"
label var surv5yr_2015 "Survival at 5yrs - 2015"
label var surv1yr_2016 "Survival at 1yr - 2016"
label var surv3yr_2016 "Survival at 3yrs - 2016"
label var surv5yr_2016 "Survival at 5yrs - 2016"
label var surv1yr_2017 "Survival at 1yr - 2017"
label var surv3yr_2017 "Survival at 3yrs - 2017"
label var surv1yr_2018 "Survival at 1yr - 2018"
label var surv3yr_2018 "Survival at 3yrs - 2018"


tab dxyr ,m
tab surv1yr_2008 if dxyr==2008 ,m
tab surv3yr_2008 if dxyr==2008 ,m
tab surv5yr_2008 if dxyr==2008 ,m
tab surv10yr_2008 if dxyr==2008 ,m
tab surv1yr_2013 if dxyr==2013 ,m
tab surv3yr_2013 if dxyr==2013 ,m
tab surv5yr_2013 if dxyr==2013 ,m
tab surv1yr_2014 if dxyr==2014 ,m
tab surv3yr_2014 if dxyr==2014 ,m
tab surv5yr_2014 if dxyr==2014 ,m
tab surv1yr_2015 if dxyr==2015 ,m
tab surv3yr_2015 if dxyr==2015 ,m
tab surv5yr_2015 if dxyr==2015 ,m
tab surv1yr_2016 if dxyr==2016 ,m
tab surv3yr_2016 if dxyr==2016 ,m
tab surv5yr_2016 if dxyr==2016 ,m
tab surv1yr_2017 if dxyr==2017 ,m
tab surv3yr_2017 if dxyr==2017 ,m
tab surv1yr_2018 if dxyr==2018 ,m
tab surv3yr_2018 if dxyr==2018 ,m


** Top 10 survival at 1, 3, 5 years by diagnosis year
**********
** 2008 **
**********
** PROSTATE
tab surv1yr_2008 if siteiarc==39 //prostate 1-yr survival
tab surv3yr_2008 if siteiarc==39 //prostate 3-yr survival
tab surv5yr_2008 if siteiarc==39 //prostate 5-yr survival
tab surv10yr_2008 if siteiarc==39 //prostate 10-yr survival
** BREAST
tab surv1yr_2008 if siteiarc==29 //breast 1-yr survival
tab surv3yr_2008 if siteiarc==29 //breast 3-yr survival
tab surv5yr_2008 if siteiarc==29 //breast 5-yr survival
tab surv10yr_2008 if siteiarc==29 //breast 10-yr survival
** COLON
tab surv1yr_2008 if siteiarc==13 //colon 1-yr survival
tab surv3yr_2008 if siteiarc==13 //colon 3-yr survival
tab surv5yr_2008 if siteiarc==13 //colon 5-yr survival
tab surv10yr_2008 if siteiarc==13 //colon 10-yr survival
** CORPUS UTERI
tab surv1yr_2008 if siteiarc==33 //corpus uteri 1-yr survival
tab surv3yr_2008 if siteiarc==33 //corpus uteri 3-yr survival
tab surv5yr_2008 if siteiarc==33 //corpus uteri 5-yr survival
tab surv10yr_2008 if siteiarc==33 //corpus uteri 10-yr survival
** MULTIPLE MYELOMA 
tab surv1yr_2008 if siteiarc==55 //mm  1-yr survival
tab surv3yr_2008 if siteiarc==55 //mm  3-yr survival
tab surv5yr_2008 if siteiarc==55 //mm  5-yr survival
tab surv10yr_2008 if siteiarc==55 //mm  10-yr survival
** PANCREAS
tab surv1yr_2008 if siteiarc==18 //pancreas 1-yr survival
tab surv3yr_2008 if siteiarc==18 //pancreas 3-yr survival
tab surv5yr_2008 if siteiarc==18 //pancreas 5-yr survival
tab surv10yr_2008 if siteiarc==18 //pancreas 10-yr survival
** RECTUM
tab surv1yr_2008 if siteiarc==14 //rectum 1-yr survival
tab surv3yr_2008 if siteiarc==14 //rectum 3-yr survival
tab surv5yr_2008 if siteiarc==14 //rectum 5-yr survival
tab surv10yr_2008 if siteiarc==14 //rectum 10-yr survival
** LUNG
tab surv1yr_2008 if siteiarc==21 //lung 1-yr survival
tab surv3yr_2008 if siteiarc==21 //lung 3-yr survival
tab surv5yr_2008 if siteiarc==21 //lung 5-yr survival
tab surv10yr_2008 if siteiarc==21 //lung 10-yr survival
** NON-HODGKIN LYMPHOMA
tab surv1yr_2008 if siteiarc==53 //nhl  1-yr survival
tab surv3yr_2008 if siteiarc==53 //nhl  3-yr survival
tab surv5yr_2008 if siteiarc==53 //nhl  5-yr survival
tab surv10yr_2008 if siteiarc==53 //nhl  10-yr survival
** STOMACH
tab surv1yr_2008 if siteiarc==11 //stomach 1-yr survival
tab surv3yr_2008 if siteiarc==11 //stomach 3-yr survival
tab surv5yr_2008 if siteiarc==11 //stomach 5-yr survival
tab surv10yr_2008 if siteiarc==11 //stomach 10-yr survival

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
** MULTIPLE MYELOMA 
tab surv1yr_2013 if siteiarc==55 //mm  1-yr survival
tab surv3yr_2013 if siteiarc==55 //mm  3-yr survival
tab surv5yr_2013 if siteiarc==55 //mm  5-yr survival
** PANCREAS
tab surv1yr_2013 if siteiarc==18 //pancreas 1-yr survival
tab surv3yr_2013 if siteiarc==18 //pancreas 3-yr survival
tab surv5yr_2013 if siteiarc==18 //pancreas 5-yr survival
** RECTUM
tab surv1yr_2013 if siteiarc==14 //rectum 1-yr survival
tab surv3yr_2013 if siteiarc==14 //rectum 3-yr survival
tab surv5yr_2013 if siteiarc==14 //rectum 5-yr survival
** LUNG
tab surv1yr_2013 if siteiarc==21 //lung 1-yr survival
tab surv3yr_2013 if siteiarc==21 //lung 3-yr survival
tab surv5yr_2013 if siteiarc==21 //lung 5-yr survival
** NON-HODGKIN LYMPHOMA
tab surv1yr_2013 if siteiarc==53 //nhl  1-yr survival
tab surv3yr_2013 if siteiarc==53 //nhl  3-yr survival
tab surv5yr_2013 if siteiarc==53 //nhl  5-yr survival
** STOMACH
tab surv1yr_2013 if siteiarc==11 //stomach 1-yr survival
tab surv3yr_2013 if siteiarc==11 //stomach 3-yr survival
tab surv5yr_2013 if siteiarc==11 //stomach 5-yr survival

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
** MULTIPLE MYELOMA 
tab surv1yr_2014 if siteiarc==55 //mm  1-yr survival
tab surv3yr_2014 if siteiarc==55 //mm  3-yr survival
tab surv5yr_2014 if siteiarc==55 //mm  5-yr survival
** PANCREAS
tab surv1yr_2014 if siteiarc==18 //pancreas 1-yr survival
tab surv3yr_2014 if siteiarc==18 //pancreas 3-yr survival
tab surv5yr_2014 if siteiarc==18 //pancreas 5-yr survival
** RECTUM
tab surv1yr_2014 if siteiarc==14 //rectum 1-yr survival
tab surv3yr_2014 if siteiarc==14 //rectum 3-yr survival
tab surv5yr_2014 if siteiarc==14 //rectum 5-yr survival
** LUNG
tab surv1yr_2014 if siteiarc==21 //lung 1-yr survival
tab surv3yr_2014 if siteiarc==21 //lung 3-yr survival
tab surv5yr_2014 if siteiarc==21 //lung 5-yr survival
** NON-HODGKIN LYMPHOMA
tab surv1yr_2014 if siteiarc==53 //nhl  1-yr survival
tab surv3yr_2014 if siteiarc==53 //nhl  3-yr survival
tab surv5yr_2014 if siteiarc==53 //nhl  5-yr survival
** STOMACH
tab surv1yr_2014 if siteiarc==11 //stomach 1-yr survival
tab surv3yr_2014 if siteiarc==11 //stomach 3-yr survival
tab surv5yr_2014 if siteiarc==11 //stomach 5-yr survival


**********
** 2015 **
**********
** PROSTATE
tab surv1yr_2015 if siteiarc==39 //prostate 1-yr survival
tab surv3yr_2015 if siteiarc==39 //prostate 3-yr survival
tab surv5yr_2015 if siteiarc==39 //prostate 5-yr survival
** BREAST
tab surv1yr_2015 if siteiarc==29 //breast 1-yr survival
tab surv3yr_2015 if siteiarc==29 //breast 3-yr survival
tab surv5yr_2015 if siteiarc==29 //breast 5-yr survival
** COLON
tab surv1yr_2015 if siteiarc==13 //colon 1-yr survival
tab surv3yr_2015 if siteiarc==13 //colon 3-yr survival
tab surv5yr_2015 if siteiarc==13 //colon 5-yr survival
** CORPUS UTERI
tab surv1yr_2015 if siteiarc==33 //corpus uteri 1-yr survival
tab surv3yr_2015 if siteiarc==33 //corpus uteri 3-yr survival
tab surv5yr_2015 if siteiarc==33 //corpus uteri 5-yr survival
** MULTIPLE MYELOMA 
tab surv1yr_2015 if siteiarc==55 //mm  1-yr survival
tab surv3yr_2015 if siteiarc==55 //mm  3-yr survival
tab surv5yr_2015 if siteiarc==55 //mm  5-yr survival
** PANCREAS
tab surv1yr_2015 if siteiarc==18 //pancreas 1-yr survival
tab surv3yr_2015 if siteiarc==18 //pancreas 3-yr survival
tab surv5yr_2015 if siteiarc==18 //pancreas 5-yr survival
** RECTUM
tab surv1yr_2015 if siteiarc==14 //rectum 1-yr survival
tab surv3yr_2015 if siteiarc==14 //rectum 3-yr survival
tab surv5yr_2015 if siteiarc==14 //rectum 5-yr survival
** LUNG
tab surv1yr_2015 if siteiarc==21 //lung 1-yr survival
tab surv3yr_2015 if siteiarc==21 //lung 3-yr survival
tab surv5yr_2015 if siteiarc==21 //lung 5-yr survival
** NON-HODGKIN LYMPHOMA
tab surv1yr_2015 if siteiarc==53 //nhl  1-yr survival
tab surv3yr_2015 if siteiarc==53 //nhl  3-yr survival
tab surv5yr_2015 if siteiarc==53 //nhl  5-yr survival
** STOMACH
tab surv1yr_2015 if siteiarc==11 //stomach 1-yr survival
tab surv3yr_2015 if siteiarc==11 //stomach 3-yr survival
tab surv5yr_2015 if siteiarc==11 //stomach 5-yr survival

**********
** 2016 **
**********
** PROSTATE
tab surv1yr_2016 if siteiarc==39 //prostate 1-yr survival
tab surv3yr_2016 if siteiarc==39 //prostate 3-yr survival
tab surv5yr_2016 if siteiarc==39 //prostate 5-yr survival
** BREAST
tab surv1yr_2016 if siteiarc==29 //breast 1-yr survival
tab surv3yr_2016 if siteiarc==29 //breast 3-yr survival
tab surv5yr_2016 if siteiarc==29 //breast 5-yr survival
** COLON
tab surv1yr_2016 if siteiarc==13 //colon 1-yr survival
tab surv3yr_2016 if siteiarc==13 //colon 3-yr survival
tab surv5yr_2016 if siteiarc==13 //colon 5-yr survival
** CORPUS UTERI
tab surv1yr_2016 if siteiarc==33 //corpus uteri 1-yr survival
tab surv3yr_2016 if siteiarc==33 //corpus uteri 3-yr survival
tab surv5yr_2016 if siteiarc==33 //corpus uteri 5-yr survival
** MULTIPLE MYELOMA 
tab surv1yr_2016 if siteiarc==55 //mm  1-yr survival
tab surv3yr_2016 if siteiarc==55 //mm  3-yr survival
tab surv5yr_2016 if siteiarc==55 //mm  5-yr survival
** PANCREAS
tab surv1yr_2016 if siteiarc==18 //pancreas 1-yr survival
tab surv3yr_2016 if siteiarc==18 //pancreas 3-yr survival
tab surv5yr_2016 if siteiarc==18 //pancreas 5-yr survival
** RECTUM
tab surv1yr_2016 if siteiarc==14 //rectum 1-yr survival
tab surv3yr_2016 if siteiarc==14 //rectum 3-yr survival
tab surv5yr_2016 if siteiarc==14 //rectum 5-yr survival
** LUNG
tab surv1yr_2016 if siteiarc==21 //lung 1-yr survival
tab surv3yr_2016 if siteiarc==21 //lung 3-yr survival
tab surv5yr_2016 if siteiarc==21 //lung 5-yr survival
** NON-HODGKIN LYMPHOMA
tab surv1yr_2016 if siteiarc==53 //nhl  1-yr survival
tab surv3yr_2016 if siteiarc==53 //nhl  3-yr survival
tab surv5yr_2016 if siteiarc==53 //nhl  5-yr survival
** STOMACH
tab surv1yr_2016 if siteiarc==11 //stomach 1-yr survival
tab surv3yr_2016 if siteiarc==11 //stomach 3-yr survival
tab surv5yr_2016 if siteiarc==11 //stomach 5-yr survival


**********
** 2017 **
**********
** PROSTATE
tab surv1yr_2017 if siteiarc==39 //prostate 1-yr survival
tab surv3yr_2017 if siteiarc==39 //prostate 3-yr survival
** BREAST
tab surv1yr_2017 if siteiarc==29 //breast 1-yr survival
tab surv3yr_2017 if siteiarc==29 //breast 3-yr survival
** COLON
tab surv1yr_2017 if siteiarc==13 //colon 1-yr survival
tab surv3yr_2017 if siteiarc==13 //colon 3-yr survival
** CORPUS UTERI
tab surv1yr_2017 if siteiarc==33 //corpus uteri 1-yr survival
tab surv3yr_2017 if siteiarc==33 //corpus uteri 3-yr survival
** MULTIPLE MYELOMA 
tab surv1yr_2017 if siteiarc==55 //mm  1-yr survival
tab surv3yr_2017 if siteiarc==55 //mm  3-yr survival
** PANCREAS
tab surv1yr_2017 if siteiarc==18 //pancreas 1-yr survival
tab surv3yr_2017 if siteiarc==18 //pancreas 3-yr survival
** RECTUM
tab surv1yr_2017 if siteiarc==14 //rectum 1-yr survival
tab surv3yr_2017 if siteiarc==14 //rectum 3-yr survival
** LUNG
tab surv1yr_2017 if siteiarc==21 //lung 1-yr survival
tab surv3yr_2017 if siteiarc==21 //lung 3-yr survival
** NON-HODGKIN LYMPHOMA
tab surv1yr_2017 if siteiarc==53 //nhl  1-yr survival
tab surv3yr_2017 if siteiarc==53 //nhl  3-yr survival
** STOMACH
tab surv1yr_2017 if siteiarc==11 //stomach 1-yr survival
tab surv3yr_2017 if siteiarc==11 //stomach 3-yr survival


**********
** 2018 **
**********
** PROSTATE
tab surv1yr_2018 if siteiarc==39 //prostate 1-yr survival
tab surv3yr_2018 if siteiarc==39 //prostate 3-yr survival
** BREAST
tab surv1yr_2018 if siteiarc==29 //breast 1-yr survival
tab surv3yr_2018 if siteiarc==29 //breast 3-yr survival
** COLON
tab surv1yr_2018 if siteiarc==13 //colon 1-yr survival
tab surv3yr_2018 if siteiarc==13 //colon 3-yr survival
** CORPUS UTERI
tab surv1yr_2018 if siteiarc==33 //corpus uteri 1-yr survival
tab surv3yr_2018 if siteiarc==33 //corpus uteri 3-yr survival
** MULTIPLE MYELOMA 
tab surv1yr_2018 if siteiarc==55 //mm  1-yr survival
tab surv3yr_2018 if siteiarc==55 //mm  3-yr survival
** PANCREAS
tab surv1yr_2018 if siteiarc==18 //pancreas 1-yr survival
tab surv3yr_2018 if siteiarc==18 //pancreas 3-yr survival
** RECTUM
tab surv1yr_2018 if siteiarc==14 //rectum 1-yr survival
tab surv3yr_2018 if siteiarc==14 //rectum 3-yr survival
** LUNG
tab surv1yr_2018 if siteiarc==21 //lung 1-yr survival
tab surv3yr_2018 if siteiarc==21 //lung 3-yr survival
** NON-HODGKIN LYMPHOMA
tab surv1yr_2018 if siteiarc==53 //nhl  1-yr survival
tab surv3yr_2018 if siteiarc==53 //nhl  3-yr survival
** STOMACH
tab surv1yr_2018 if siteiarc==11 //stomach 1-yr survival
tab surv3yr_2018 if siteiarc==11 //stomach 3-yr survival


** Create patient total variables to use in 30_report cancer.do
tab patient dxyr ,m
egen pttotsurv_2018=count(patient) if patient==1 & dxyr==2018
egen pttotsurv_2017=count(patient) if patient==1 & dxyr==2017
egen pttotsurv_2016=count(patient) if patient==1 & dxyr==2016
egen pttotsurv_2015=count(patient) if patient==1 & dxyr==2015
egen pttotsurv_2014=count(patient) if patient==1 & dxyr==2014
egen pttotsurv_2013=count(patient) if patient==1 & dxyr==2013
egen pttotsurv_2008=count(patient) if patient==1 & dxyr==2008

count //6083

** Create 2008, 2013-2018 survival dataset
save "`datapath'\version09\3-output\2008_2013-2018_cancer_survival_deidentified", replace
label data "2008 2013-2018 BNR-Cancer analysed data - Survival BNR Reportable Dataset"
note: TS This dataset was NOT used for 2016-2018 annual report
note: TS For survival analysis, use variables surv1yr_2008, surv1yr_2013, surv1yr_2014, surv1yr_2015, surv1yr_2016, surv1yr_2017, surv1yr_2018, surv3yr_2008, surv3yr_2013, surv3yr_2014, surv3yr_2015, surv3yr_2016, surv3yr_2017, surv3yr_2018, surv5yr_2008, surv5yr_2013, surv5yr_2014, surv5yr_2015, surv5yr_2016, surv10yr_2008

** Create 2013-2018 survival dataset
drop if dxyr==2008 //756 deleted

drop deceased_10yr enddate_10yr time_10yr dod_10yr newenddate_10yr surv1yr_2008 surv3yr_2008 surv5yr_2008 surv10yr_2008 pttotsurv_2008

count //5327

save "`datapath'\version09\3-output\2013-2018_cancer_survival_deidentified", replace
label data "2013-2018 BNR-Cancer analysed data - Survival BNR Reportable Dataset"
note: TS This dataset was used for 2016-2018 annual report
note: TS For survival analysis, use variables surv1yr_2013, surv1yr_2014, surv1yr_2015, surv1yr_2016, surv1yr_2017, surv1yr_2018, surv3yr_2013, surv3yr_2014, surv3yr_2015, surv3yr_2016, surv3yr_2017, surv3yr_2018, surv5yr_2013, surv5yr_2014, surv5yr_2015, surv5yr_2016
