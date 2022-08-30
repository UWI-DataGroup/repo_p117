cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          30a_report cancer_WORD.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      18-AUG-2022
    // 	date last modified      29-AUG-2022
    //  algorithm task          Preparing 2013-2018 cancer datasets for reporting
    //  status                  In progress
    //  objective               To have one dataset with report outputs for 2013-2018 data for 2016-2018 annual report
	//							that allows the report writer to have text to enable correction interpretation of the data.
    //  methods                 Use putdocx and Stata memory to produce methods in text, data tables and figures

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
    log using "`logpath'\30a_report cancer_WORD.smcl", replace // error r(603)
** HEADER -----------------------------------------------------


*************************
**  SUMMARY STATISTICS **
*************************
** Annual report: Table 1 (executive summary)
** Load the REPORTABLE NON-SURVIVAL DEIDENTIFIED dataset
use "`datapath'\version09\3-output\2008_2013-2018_cancer_reportable_nonsurvival_deidentified" ,clear

** POPULATION
gen poptot_2013=284294
gen poptot_2014=284825
gen poptot_2015=285327
gen poptot_2016=285798
gen poptot_2017=286229
gen poptot_2018=286640
//gen poptot_2019=287021
//gen poptot_2020=287371
//gen poptot_2021=281207

** TUMOURS
egen tumourtot_2013=count(pid) if dxyr==2013
egen tumourtot_2014=count(pid) if dxyr==2014
egen tumourtot_2015=count(pid) if dxyr==2015
egen tumourtot_2016=count(pid) if dxyr==2016
egen tumourtot_2017=count(pid) if dxyr==2017
egen tumourtot_2018=count(pid) if dxyr==2018
gen tumourtotper_2013=tumourtot_2013/poptot_2013*100
gen tumourtotper_2014=tumourtot_2014/poptot_2014*100
gen tumourtotper_2015=tumourtot_2015/poptot_2015*100
gen tumourtotper_2016=tumourtot_2016/poptot_2016*100
gen tumourtotper_2017=tumourtot_2017/poptot_2017*100
gen tumourtotper_2018=tumourtot_2018/poptot_2018*100
format tumourtotper_2013 tumourtotper_2014 tumourtotper_2015 tumourtotper_2016 tumourtotper_2017 tumourtotper_2018 %04.2f
** PATIENTS
egen patienttot_2013=count(pid) if patient==1 & dxyr==2013
egen patienttot_2014=count(pid) if patient==1 & dxyr==2014
egen patienttot_2015=count(pid) if patient==1 & dxyr==2015
egen patienttot_2016=count(pid) if patient==1 & dxyr==2016
egen patienttot_2017=count(pid) if patient==1 & dxyr==2017
egen patienttot_2018=count(pid) if patient==1 & dxyr==2018
** DCOs
egen dco_2013=count(pid) if basis==0 &  dxyr==2013
egen dco_2014=count(pid) if basis==0 &  dxyr==2014
egen dco_2015=count(pid) if basis==0 &  dxyr==2015
egen dco_2016=count(pid) if basis==0 &  dxyr==2016
egen dco_2017=count(pid) if basis==0 &  dxyr==2017
egen dco_2018=count(pid) if basis==0 &  dxyr==2018
gen dcoper_2013=dco_2013/tumourtot_2013*100
gen dcoper_2014=dco_2014/tumourtot_2014*100
gen dcoper_2015=dco_2015/tumourtot_2015*100
gen dcoper_2016=dco_2016/tumourtot_2016*100
gen dcoper_2017=dco_2017/tumourtot_2017*100
gen dcoper_2018=dco_2018/tumourtot_2018*100
format dcoper_2013 dcoper_2014 dcoper_2015 dcoper_2016 dcoper_2017 dcoper_2018 %2.1f


** SURVIVAL
** Create frame for non-survival ds
frame rename default nonsurv
frame create surv 
frame change surv
** Copy patient totals from survival dataset into this dataset by creating new frame for survival dataset
use "`datapath'\version09\3-output\2013-2018_cancer_survival_deidentified", clear
** 1-yr survival
egen surv1yr_2018_censor=count(surv1yr_2018) if surv1yr_2018==0
egen surv1yr_2018_dead=count(surv1yr_2018) if surv1yr_2018==1
drop surv1yr_2018
gen surv1yr_2018=surv1yr_2018_censor/pttotsurv_2018*100
egen surv1yr_2017_censor=count(surv1yr_2017) if surv1yr_2017==0
egen surv1yr_2017_dead=count(surv1yr_2017) if surv1yr_2017==1
drop surv1yr_2017
gen surv1yr_2017=surv1yr_2017_censor/pttotsurv_2017*100
egen surv1yr_2016_censor=count(surv1yr_2016) if surv1yr_2016==0
egen surv1yr_2016_dead=count(surv1yr_2016) if surv1yr_2016==1
drop surv1yr_2016
gen surv1yr_2016=surv1yr_2016_censor/pttotsurv_2016*100
egen surv1yr_2015_censor=count(surv1yr_2015) if surv1yr_2015==0
egen surv1yr_2015_dead=count(surv1yr_2015) if surv1yr_2015==1
drop surv1yr_2015
gen surv1yr_2015=surv1yr_2015_censor/pttotsurv_2015*100
egen surv1yr_2014_censor=count(surv1yr_2014) if surv1yr_2014==0
egen surv1yr_2014_dead=count(surv1yr_2014) if surv1yr_2014==1
drop surv1yr_2014
gen surv1yr_2014=surv1yr_2014_censor/pttotsurv_2014*100
egen surv1yr_2013_censor=count(surv1yr_2013) if surv1yr_2013==0
egen surv1yr_2013_dead=count(surv1yr_2013) if surv1yr_2013==1
drop surv1yr_2013
gen surv1yr_2013=surv1yr_2013_censor/pttotsurv_2013*100
** 3-yr survival
egen surv3yr_2018_censor=count(surv3yr_2018) if surv3yr_2018==0
egen surv3yr_2018_dead=count(surv3yr_2018) if surv3yr_2018==1
drop surv3yr_2018
gen surv3yr_2018=surv3yr_2018_censor/pttotsurv_2018*100
egen surv3yr_2017_censor=count(surv3yr_2017) if surv3yr_2017==0
egen surv3yr_2017_dead=count(surv3yr_2017) if surv3yr_2017==1
drop surv3yr_2017
gen surv3yr_2017=surv3yr_2017_censor/pttotsurv_2017*100
egen surv3yr_2016_censor=count(surv3yr_2016) if surv3yr_2016==0
egen surv3yr_2016_dead=count(surv3yr_2016) if surv3yr_2016==1
drop surv3yr_2016
gen surv3yr_2016=surv3yr_2016_censor/pttotsurv_2016*100
egen surv3yr_2015_censor=count(surv3yr_2015) if surv3yr_2015==0
egen surv3yr_2015_dead=count(surv3yr_2015) if surv3yr_2015==1
drop surv3yr_2015
gen surv3yr_2015=surv3yr_2015_censor/pttotsurv_2015*100
egen surv3yr_2014_censor=count(surv3yr_2014) if surv3yr_2014==0
egen surv3yr_2014_dead=count(surv3yr_2014) if surv3yr_2014==1
drop surv3yr_2014
gen surv3yr_2014=surv3yr_2014_censor/pttotsurv_2014*100
egen surv3yr_2013_censor=count(surv3yr_2013) if surv3yr_2013==0
egen surv3yr_2013_dead=count(surv3yr_2013) if surv3yr_2013==1
drop surv3yr_2013
gen surv3yr_2013=surv3yr_2013_censor/pttotsurv_2013*100
** 5-yr survival
egen surv5yr_2016_censor=count(surv5yr_2016) if surv5yr_2016==0
egen surv5yr_2016_dead=count(surv5yr_2016) if surv5yr_2016==1
egen surv5yr_2015_censor=count(surv5yr_2015) if surv5yr_2015==0
egen surv5yr_2015_dead=count(surv5yr_2015) if surv5yr_2015==1
egen surv5yr_2014_censor=count(surv5yr_2014) if surv5yr_2014==0
egen surv5yr_2014_dead=count(surv5yr_2014) if surv5yr_2014==1
egen surv5yr_2013_censor=count(surv5yr_2013) if surv5yr_2013==0
egen surv5yr_2013_dead=count(surv5yr_2013) if surv5yr_2013==1
drop surv5yr_2013 surv5yr_2014 surv5yr_2015 surv5yr_2016
gen surv5yr_2013=surv5yr_2013_censor/pttotsurv_2013*100
gen surv5yr_2014=surv5yr_2014_censor/pttotsurv_2014*100
gen surv5yr_2015=surv5yr_2015_censor/pttotsurv_2015*100
gen surv5yr_2016=surv5yr_2016_censor/pttotsurv_2016*100
format surv1yr_2018 surv1yr_2017 surv1yr_2016 surv1yr_2015 surv1yr_2014 surv1yr_2013 surv3yr_2018 surv3yr_2017 surv3yr_2016 surv3yr_2015 surv3yr_2014 surv3yr_2013 surv5yr_2016 surv5yr_2015 surv5yr_2014 surv5yr_2013 %2.1f
** Input 1yr, 3yr, 5yr, 10yr survival variables from survival ds to nonsurvival ds
frame change nonsurv
**remove duplicates
frame nonsurv: duplicates drop pid, force
frame surv: duplicates drop pid, force
//frame surv:describe
//frame nonsurv: describe
frlink m:1 pid, frame(surv) //132 unmatched
//list pid fname lname if surv==.
frget surv1yr_2018 = surv1yr_2018, from(surv)
frget surv1yr_2017 = surv1yr_2017, from(surv)
frget surv1yr_2016 = surv1yr_2016, from(surv)
frget surv1yr_2015 = surv1yr_2015, from(surv)
frget surv1yr_2014 = surv1yr_2014, from(surv)
frget surv1yr_2013 = surv1yr_2013, from(surv)
frget surv3yr_2018 = surv3yr_2018, from(surv)
frget surv3yr_2017 = surv3yr_2017, from(surv)
frget surv3yr_2016 = surv3yr_2016, from(surv)
frget surv3yr_2015 = surv3yr_2015, from(surv)
frget surv3yr_2014 = surv3yr_2014, from(surv)
frget surv3yr_2013 = surv3yr_2013, from(surv)
frget surv5yr_2016 = surv5yr_2016, from(surv)
frget surv5yr_2015 = surv5yr_2015, from(surv)
frget surv5yr_2014 = surv5yr_2014, from(surv)
frget surv5yr_2013 = surv5yr_2013, from(surv)

** ASIRs
** Copy ASIR totals from ASIRs dataset into this dataset by creating new frame for ASIRs dataset
append using "`datapath'\version09\2-working\ASIRs"
gen asir_2018=asir if cancer_site==1 & year==1
gen asir_2017=asir if cancer_site==1 & year==2
gen asir_2016=asir if cancer_site==1 & year==3
gen asir_2015=asir if cancer_site==1 & year==4
gen asir_2014=asir if cancer_site==1 & year==5
gen asir_2013=asir if cancer_site==1 & year==6
format asir_* %04.2f

** Re-arrange dataset
gen id=_n
keep id tumourtot_* tumourtotper_* patienttot_* dco_* dcoper_* asir_* surv*yr_*
gen title=1 if id==1
order id title
label define title_lab 1 "Year" 2 "No.registrations(tumours)" 3 "% of entire population" 4 "No.registrations(patients)" 5 "Age-standardized Incidence Rate (ASIR) per 100,000" 6 "No.registered by death certificate only" 7 "% of tumours registered as DCOs" 8 "1-year survival (%)" 9 "3-year survival (%)" 10 "5-year survival (%)" ,modify
label values title title_lab
label var title "Title"

replace title=2 if tumourtot_2018!=.
replace title=2 if tumourtot_2017!=.
replace title=2 if tumourtot_2016!=.
replace title=2 if tumourtot_2015!=.
replace title=2 if tumourtot_2014!=.
replace title=2 if tumourtot_2013!=.
replace title=3 if tumourtotper_2018!=.
replace title=3 if tumourtotper_2017!=.
replace title=3 if tumourtotper_2016!=.
replace title=3 if tumourtotper_2015!=.
replace title=3 if tumourtotper_2014!=.
replace title=3 if tumourtotper_2013!=.
replace title=4 if patienttot_2018!=.
replace title=4 if patienttot_2017!=.
replace title=4 if patienttot_2016!=.
replace title=4 if patienttot_2015!=.
replace title=4 if patienttot_2014!=.
replace title=4 if patienttot_2013!=.
replace title=5 if asir_2018!=.
replace title=5 if asir_2017!=.
replace title=5 if asir_2016!=.
replace title=5 if asir_2015!=.
replace title=5 if asir_2014!=.
replace title=5 if asir_2013!=.
replace title=6 if dco_2018!=.
replace title=6 if dco_2017!=.
replace title=6 if dco_2016!=.
replace title=6 if dco_2015!=.
replace title=6 if dco_2014!=.
replace title=6 if dco_2013!=.
replace title=7 if dcoper_2018!=.
replace title=7 if dcoper_2017!=.
replace title=7 if dcoper_2016!=.
replace title=7 if dcoper_2015!=.
replace title=7 if dcoper_2014!=.
replace title=7 if dcoper_2013!=.
replace title=8 if surv1yr_2018!=.
replace title=8 if surv1yr_2017!=.
replace title=8 if surv1yr_2016!=.
replace title=8 if surv1yr_2015!=.
replace title=8 if surv1yr_2014!=.
replace title=8 if surv1yr_2013!=.
replace title=9 if surv3yr_2018!=.
replace title=9 if surv3yr_2017!=.
replace title=9 if surv3yr_2016!=.
replace title=9 if surv3yr_2015!=.
replace title=9 if surv3yr_2014!=.
replace title=9 if surv3yr_2013!=.
replace title=10 if surv5yr_2016!=.
replace title=10 if surv5yr_2015!=.
replace title=10 if surv5yr_2014!=.
replace title=10 if surv5yr_2013!=.

*-------------------------------------------------------------------------------

tab title ,m //some titles got replaced so add in new obs
** % of entire population needs to be added in
//list id tumourtotper_2013 if tumourtotper_2013!=.
expand=2 in 340, gen (tumtotper_2013)
replace id=9001 if tumtotper_2013==1
replace title=3 if tumtotper_2013!=0
//list id tumourtotper_2014 if tumourtotper_2014!=.
expand=2 in 444, gen (tumtotper_2014)
replace id=9002 if tumtotper_2014==1
replace title=3 if tumtotper_2014!=0
//list id tumourtotper_2015 if tumourtotper_2015!=.
expand=2 in 304, gen (tumtotper_2015) // Note to change the in input
replace id=9003 if tumtotper_2015==1
replace title=3 if tumtotper_2015!=0
//list id tumourtotper_2016 if tumourtotper_2016!=.
expand=2 in 213, gen (tumtotper_2016) // Note to change the in input
replace id=9004 if tumtotper_2016==1
replace title=3 if tumtotper_2016!=0
//list id tumourtotper_2017 if tumourtotper_2017!=.
expand=2 in 806, gen (tumtotper_2017) // Note to change the in input
replace id=9005 if tumtotper_2017==1
replace title=3 if tumtotper_2017!=0
//list id tumourtotper_2018 if tumourtotper_2018!=.
expand=2 in 497, gen (tumtotper_2018) // Note to change the in input
replace id=9006 if tumtotper_2018==1
replace title=3 if tumtotper_2018!=0

/*
** Add in ASIR observations
expand=2 in 1, gen (asir_2008)
replace id=9007 if asirtot_2008!=.
expand=2 in 1, gen (asir_2013)
replace id=9008 if asirtot_2013!=.
expand=2 in 1, gen (asir_2014)
replace id=9009 if asirtot_2014!=.
replace title=5 if asir_2014!=0
replace title=5 if asir_2013!=0
replace title=5 if asir_2008!=0
expand=2 in 1, gen (asir_2015)
replace id=9010 if asirtot_2015!=.
replace title=6 if asir_2015!=0
replace title=6 if asir_2014!=0
replace title=6 if asir_2013!=0
replace title=6 if asir_2008!=0
*/

** No.registered by death certificate only needs to be added in
//list id dco_2013 if dco_2013!=.
expand=2 in 1514, gen (dcotot_2013)
replace id=9007 if dcotot_2013==1
replace title=6 if dcotot_2013!=0
//list id dco_2014 if dco_2014!=.
expand=2 in 1880, gen (dcotot_2014)
replace id=9008 if dcotot_2014==1
replace title=6 if dcotot_2014!=0
//list id dco_2015 if dco_2015!=.
expand=2 in 2856, gen (dcotot_2015) // Note check the in input
replace id=9009 if dcotot_2015==1
replace title=6 if dcotot_2015!=0
//list id dco_2016 if dco_2016!=.
expand=2 in 4325, gen (dcotot_2016) // Note check the in input
replace id=9010 if dcotot_2016==1
replace title=6 if dcotot_2016!=0
//list id dco_2017 if dco_2017!=.
expand=2 in 5161, gen (dcotot_2017) // Note check the in input
replace id=9011 if dcotot_2017==1
replace title=6 if dcotot_2017!=0
//list id dco_2018 if dco_2018!=.
expand=2 in 6017, gen (dcotot_2018) // Note check the in input
replace id=9012 if dcotot_2018==1
replace title=6 if dcotot_2018!=0


** No.registrations(tumours) needs to be added in
//list id tumourtot_2013 if tumourtot_2013!=.
expand=2 in 1031, gen (tumtot_2013)
replace id=9013 if tumtot_2013==1
replace title=2 if tumtot_2013!=0
//list id tumourtot_2014 if tumourtot_2014!=.
expand=2 in 2342, gen (tumtot_2014)
replace id=9014 if tumtot_2014==1
replace title=2 if tumtot_2014!=0
//list id tumourtot_2015 if tumourtot_2015!=.
expand=2 in 2576, gen (tumtot_2015) // Note to change the in input
replace id=9015 if tumtot_2015==1
replace title=2 if tumtot_2015!=0
//list id tumourtot_2016 if tumourtot_2016!=.
expand=2 in 4324, gen (tumtot_2016) // Note to change the in input
replace id=9016 if tumtot_2016==1
replace title=2 if tumtot_2016!=0
//list id tumourtot_2017 if tumourtot_2017!=.
expand=2 in 5069, gen (tumtot_2017) // Note to change the in input
replace id=9017 if tumtot_2017==1
replace title=2 if tumtot_2017!=0
//list id tumourtot_2018 if tumourtot_2018!=.
expand=2 in 5700, gen (tumtot_2018) // Note to change the in input
replace id=9018 if tumtot_2018==1
replace title=2 if tumtot_2018!=0

drop tumtotper_* dcotot_* tumtot_*

tab title ,m //40 missing - remove blank titles as no data in any of the corresponding fields for those blank titles
drop if title==. //40 deleted

** Rearrange summ stats datast
egen tumtot_2018=max(tumourtot_2018)
egen tumtot_2017=max(tumourtot_2017)
egen tumtot_2016=max(tumourtot_2016)
egen tumtot_2015=max(tumourtot_2015)
egen tumtot_2014=max(tumourtot_2014)
egen tumtot_2013=max(tumourtot_2013)

egen tumtotper_2018=max(tumourtotper_2018)
egen tumtotper_2017=max(tumourtotper_2017)
egen tumtotper_2016=max(tumourtotper_2016)
egen tumtotper_2015=max(tumourtotper_2015)
egen tumtotper_2014=max(tumourtotper_2014)
egen tumtotper_2013=max(tumourtotper_2013)
format tumtotper_2013 tumtotper_2014 tumtotper_2015 tumtotper_2016 tumtotper_2017 tumtotper_2018 %04.2f

egen pttot_2018=max(patienttot_2018)
egen pttot_2017=max(patienttot_2017)
egen pttot_2016=max(patienttot_2016)
egen pttot_2015=max(patienttot_2015)
egen pttot_2014=max(patienttot_2014)
egen pttot_2013=max(patienttot_2013)

egen asirtot_2018=max(asir_2018)
egen asirtot_2017=max(asir_2017)
egen asirtot_2016=max(asir_2016)
egen asirtot_2015=max(asir_2015)
egen asirtot_2014=max(asir_2014)
egen asirtot_2013=max(asir_2013)

egen dcotot_2018=max(dco_2018)
egen dcotot_2017=max(dco_2017)
egen dcotot_2016=max(dco_2016)
egen dcotot_2015=max(dco_2015)
egen dcotot_2014=max(dco_2014)
egen dcotot_2013=max(dco_2013)

egen dcototper_2018=max(dcoper_2018)
egen dcototper_2017=max(dcoper_2017)
egen dcototper_2016=max(dcoper_2016)
egen dcototper_2015=max(dcoper_2015)
egen dcototper_2014=max(dcoper_2014)
egen dcototper_2013=max(dcoper_2013)

egen surv1yrtot_2018=max(surv1yr_2018)
egen surv1yrtot_2017=max(surv1yr_2017)
egen surv1yrtot_2016=max(surv1yr_2016)
egen surv1yrtot_2015=max(surv1yr_2015)
egen surv1yrtot_2014=max(surv1yr_2014)
egen surv1yrtot_2013=max(surv1yr_2013)

egen surv3yrtot_2018=max(surv3yr_2018)
egen surv3yrtot_2017=max(surv3yr_2017)
egen surv3yrtot_2016=max(surv3yr_2016)
egen surv3yrtot_2015=max(surv3yr_2015)
egen surv3yrtot_2014=max(surv3yr_2014)
egen surv3yrtot_2013=max(surv3yr_2013)

//egen surv5yrtot_2018=max(surv5yr_2018)
//egen surv5yrtot_2017=max(surv5yr_2017)
egen surv5yrtot_2016=max(surv5yr_2016)
egen surv5yrtot_2015=max(surv5yr_2015)
egen surv5yrtot_2014=max(surv5yr_2014)
egen surv5yrtot_2013=max(surv5yr_2013)


**  Using format below displays all correctly but this one as it need rounding up first
replace dcototper_2013=round(dcototper_2013, 0.15)
replace dcototper_2014=round(dcototper_2014, 0.15)
replace dcototper_2015=round(dcototper_2015, 0.15)
replace dcototper_2016=round(dcototper_2016, 0.15)
replace dcototper_2017=round(dcototper_2017, 0.15)
replace dcototper_2018=round(dcototper_2018, 0.15)
replace surv1yrtot_2018=round(surv1yrtot_2018, 0.15)
replace surv1yrtot_2017=round(surv1yrtot_2017, 0.15)
replace surv1yrtot_2016=round(surv1yrtot_2016, 0.15)
replace surv1yrtot_2015=round(surv1yrtot_2015, 0.15)
replace surv1yrtot_2014=round(surv1yrtot_2014, 0.15)
replace surv1yrtot_2013=round(surv1yrtot_2013, 0.15)
replace surv3yrtot_2018=round(surv3yrtot_2018, 0.15)
replace surv3yrtot_2017=round(surv3yrtot_2017, 0.15)
replace surv3yrtot_2016=round(surv3yrtot_2016, 0.15)
replace surv3yrtot_2015=round(surv3yrtot_2015, 0.15)
replace surv3yrtot_2014=round(surv3yrtot_2014, 0.15)
replace surv3yrtot_2013=round(surv3yrtot_2013, 0.15)
replace surv5yrtot_2016=round(surv5yrtot_2016, 0.15)
replace surv5yrtot_2015=round(surv5yrtot_2015, 0.15)
replace surv5yrtot_2014=round(surv5yrtot_2014, 0.15)
replace surv5yrtot_2013=round(surv5yrtot_2013, 0.15)
format dcototper_2013 dcototper_2014 dcototper_2015 dcototper_2016 dcototper_2017 dcototper_2018 surv1yrtot_2018 surv1yrtot_2017 surv1yrtot_2016 surv1yrtot_2015 surv1yrtot_2014 surv1yrtot_2013 surv3yrtot_2018 surv3yrtot_2017 surv3yrtot_2016 surv3yrtot_2015 surv3yrtot_2014 surv3yrtot_2013 surv5yrtot_2016 surv5yrtot_2015 surv5yrtot_2014 surv5yrtot_2013 %2.1f

*-------------------------------------------------------------------------------

drop tumourtot_* tumourtotper_* patienttot_* dco_* dcoper_* asir_* surv1yr_* surv3yr_* surv5yr_*
order id title tumtot_2018 tumtot_2017 tumtot_2016 tumtot_2015 tumtot_2014 tumtot_2013 tumtotper_2018 tumtotper_2017 tumtotper_2016 tumtotper_2015 tumtotper_2014 tumtotper_2013 pttot_2018 pttot_2017 pttot_2016 pttot_2015 pttot_2014 pttot_2013 asirtot_2018 asirtot_2017 asirtot_2016 asirtot_2015 asirtot_2014 asirtot_2013 dcotot_2018 dcotot_2017 dcotot_2016 dcotot_2015 dcotot_2014 dcotot_2013 dcototper_2018 dcototper_2017 dcototper_2016 dcototper_2015 dcototper_2014 dcototper_2013 surv1yrtot_2018 surv1yrtot_2017 surv1yrtot_2016 surv1yrtot_2015 surv1yrtot_2014 surv1yrtot_2013 surv3yrtot_2018 surv3yrtot_2017 surv3yrtot_2016 surv3yrtot_2015 surv3yrtot_2014 surv3yrtot_2013 surv5yrtot_2016 surv5yrtot_2015 surv5yrtot_2014 surv5yrtot_2013

replace title=1 if id==1
replace title=2 if id==2
replace title=3 if id==3
replace title=4 if id==4
replace title=5 if id==5
replace title=6 if id==6
replace title=7 if id==7
replace title=8 if id==8
replace title=9 if id==9
replace title=10 if id==10

sort title

contract title tumtot_2018 tumtot_2017 tumtot_2016 tumtot_2015 tumtot_2014 tumtot_2013 tumtotper_2018 tumtotper_2017 tumtotper_2016 tumtotper_2015 tumtotper_2014 tumtotper_2013 pttot_2018 pttot_2017 pttot_2016 pttot_2015 pttot_2014 pttot_2013 asirtot_2018 asirtot_2017 asirtot_2016 asirtot_2015 asirtot_2014 asirtot_2013 dcotot_2018 dcotot_2017 dcotot_2016 dcotot_2015 dcotot_2014 dcotot_2013 dcototper_2018 dcototper_2017 dcototper_2016 dcototper_2015 dcototper_2014 dcototper_2013 surv1yrtot_2018 surv1yrtot_2017 surv1yrtot_2016 surv1yrtot_2015 surv1yrtot_2014 surv1yrtot_2013 surv3yrtot_2018 surv3yrtot_2017 surv3yrtot_2016 surv3yrtot_2015 surv3yrtot_2014 surv3yrtot_2013 surv5yrtot_2016 surv5yrtot_2015 surv5yrtot_2014 surv5yrtot_2013

//drop if id>10
rename tumtot_2018 results_2018
rename tumtot_2017 results_2017
rename tumtot_2016 results_2016
rename tumtot_2015 results_2015
rename tumtot_2014 results_2014
rename tumtot_2013 results_2013

format tumtotper_2013 tumtotper_2014 tumtotper_2015 tumtotper_2016 tumtotper_2017 tumtotper_2018 %04.2f
replace results_2018=tumtotper_2018 if title==3
replace results_2017=tumtotper_2017 if title==3
replace results_2016=tumtotper_2016 if title==3
replace results_2015=tumtotper_2015 if title==3
replace results_2014=tumtotper_2014 if title==3
replace results_2013=tumtotper_2013 if title==3
replace results_2013=round(results_2013, 0.01) if title==3
replace results_2014=round(results_2014, 0.01) if title==3
replace results_2015=round(results_2015, 0.01) if title==3
replace results_2016=round(results_2016, 0.01) if title==3
replace results_2017=round(results_2017, 0.01) if title==3
replace results_2018=round(results_2018, 0.01) if title==3
drop tumtotper_*

replace results_2018=pttot_2018 if title==4
replace results_2017=pttot_2017 if title==4
replace results_2016=pttot_2016 if title==4
replace results_2015=pttot_2015 if title==4
replace results_2014=pttot_2014 if title==4
replace results_2013=pttot_2013 if title==4
drop pttot_*

format asirtot_* %04.2f
replace results_2018=asirtot_2018 if title==5
replace results_2017=asirtot_2017 if title==5
replace results_2016=asirtot_2016 if title==5
replace results_2015=asirtot_2015 if title==5
replace results_2014=asirtot_2014 if title==5
replace results_2013=asirtot_2013 if title==5
//if id==5 format results_* %04.2f
//replace results_2014=204.80 if id==5
drop asirtot_*

replace results_2018=dcotot_2018 if title==6
replace results_2017=dcotot_2017 if title==6
replace results_2016=dcotot_2016 if title==6
replace results_2015=dcotot_2015 if title==6
replace results_2014=dcotot_2014 if title==6
replace results_2013=dcotot_2013 if title==6
drop dcotot_*

replace results_2018=dcototper_2018 if title==7
replace results_2017=dcototper_2017 if title==7
replace results_2016=dcototper_2016 if title==7
replace results_2015=dcototper_2015 if title==7
replace results_2014=dcototper_2014 if title==7
replace results_2013=dcototper_2013 if title==7
drop dcototper_*

replace results_2018=surv1yrtot_2018 if title==8
replace results_2017=surv1yrtot_2017 if title==8
replace results_2016=surv1yrtot_2016 if title==8
replace results_2015=surv1yrtot_2015 if title==8
replace results_2014=surv1yrtot_2014 if title==8
replace results_2013=surv1yrtot_2013 if title==8

replace results_2018=surv3yrtot_2018 if title==9
replace results_2017=surv3yrtot_2017 if title==9
replace results_2016=surv3yrtot_2016 if title==9
replace results_2015=surv3yrtot_2015 if title==9
replace results_2014=surv3yrtot_2014 if title==9
replace results_2013=surv3yrtot_2013 if title==9

//replace results_2018=surv5yrtot_2018 if id==10
//replace results_2017=surv5yrtot_2017 if id==10
replace results_2016=surv5yrtot_2016 if title==10
replace results_2015=surv5yrtot_2015 if title==10
replace results_2014=surv5yrtot_2014 if title==10
replace results_2013=surv5yrtot_2013 if title==10

drop surv1yrtot_* surv3yrtot_* surv5yrtot_*

replace results_2018=2018 if title==1
replace results_2017=2017 if title==1
replace results_2016=2016 if title==1
replace results_2015=2015 if title==1
replace results_2014=2014 if title==1
replace results_2013=2013 if title==1

replace results_2018 = . if title==10
replace results_2017 = . if title==10
drop _freq
save "`datapath'\version09\2-working\2013-2018_summstats" ,replace

//JC 10may2022: only 2018 ASMRs and ASIRs initially done
preserve
				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
				****************************
putdocx clear
putdocx begin, footer(foot1)
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER 2016-2018 Annual Report: Stata Results"), bold
putdocx textblock begin
Date Prepared: 25-AUG-2022.
Date Updated: 29-AUG-2022.
Prepared by: JC using Stata v17.0
CanReg5 v5.43 (incidence) data release date: 18-July-2022.
REDCap v12.3.3 (death) data release date: 03-Aug-2022.
Generated using Dofile: 30a_report cancer_WORD.do
putdocx textblock end
putdocx paragraph, halign(center)
putdocx text ("Table 1. Summary Statistics for BNR-Cancer, 2018 (Population=286,640), 2017 (Population=286,229), 2016 (Population=285,798), 2015 (Population=285,327), 2014 (Population=284,825), 2013 (Population=284,294))"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Standards"), bold
putdocx paragraph, halign(center)
putdocx image "`datapath'\version09\1-input\standards.png", width(6.64) height(6.8)
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) No.(tumours): Includes standardized case definition, i.e. includes unk residents, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version09\3-output\2008_2013-2018_cancer_reportable_nonsurvival_deidentified")
putdocx textblock end
putdocx textblock begin
(2) % of population: WPP population for 2013, 2014, 2015, 2016, 2017 and 2018 (see p_117\2016-2018AnnualReport branch\0_population.do)
putdocx textblock end
putdocx textblock begin
(3) No.(patients): Includes standardized case definition, i.e. includes unk residents, non-malignant tumours, IARC non-reportable MPs (variable used: patient; dataset used: "`datapath'\version09\3-output\2008_2013-2018_cancer_reportable_nonsurvival_deidentified")
putdocx textblock end
putdocx textblock begin
(4) ASIR: Includes standardized case definition, i.e. includes unk residents, IARC non-reportable MPs but excludes non-malignant tumours; stata command distrate used with pop_wpp_2018-5,pop_wpp_2017-5,pop_wpp_2016-5,pop_wpp_2015-5, pop_wpp_2014-5, pop_wpp_2013-5 for 2013-2018 cancer incidence and world population dataset: who2000_5; (population datasets used: "`datapath'\version09\2-working\pop_wpp_2018-5;pop_wpp_2017-5;pop_wpp_2016-5;pop_wpp_2015-5;pop_wpp_2014-5;pop_wpp_2013-5"; cancer dataset used: "`datapath'\version09\2-working\2013-2018_cancer_numbers")
putdocx textblock end
putdocx textblock begin
(5) Site Order: These tables show where the order of 2018 top 10 sites in 2013-2018, respectively; site order datasets used: "`datapath'\version09\2-working\siteorder_2018; siteorder_2017; siteorder_2016; siteorder_2015; siteorder_2014; siteorder_2013")
putdocx textblock end
putdocx textblock begin
(6) ASIR by sex: Includes standardized case definition, i.e. includes unk residents, IARC non-reportable MPs but excludes non-malignant tumours; unk/missing ages were included in the median age group; stata command distrate used with pop_wpp_2018-5 for 2018; pop_wpp_2017-5 for 2017 pop_wpp_2016-5 for 2016 cancer incidence, ONLY, and world population dataset: who2000_5; (population datasets used: "`datapath'\version09\2-working\pop_wpp_2018-5;pop_wpp_2017-5;pop_wpp_2016-5"; cancer dataset used: "`datapath'\version09\2-working\2013-2018_cancer_numbers")
putdocx textblock end
putdocx textblock begin
(7) Population text files (WPP): saved in: "`datapath'\version09\2-working\WPP_population by sex_yyyy"
putdocx textblock end
putdocx textblock begin
(8) Population files (WPP): generated from "https://population.un.org/wpp/Download/Standard/Population/" on 27-Nov-2019; re-checked on 10-May-2022 (totals remain the same); 2021 wpp pop generated on 24-Aug-2022.
putdocx textblock end
putdocx textblock begin
(9) No.(DCOs): Includes standardized case definition, i.e. includes unk residents, non-malignant tumours, IARC non-reportable MPs. (variable used: basis. dataset used: "`datapath'\version09\3-output\2008_2013-2018_cancer_reportable_nonsurvival_deidentified")
putdocx textblock end
putdocx textblock begin
(10) % of tumours: Includes standardized case definition, i.e. includes unk residents, non-malignant tumours, IARC non-reportable MPs (variable used: basis; dataset used: "`datapath'\version09\3-output\2008_2013-2018_cancer_reportable_nonsurvival_deidentified")
putdocx textblock end
putdocx textblock begin
(11) 1-yr, 3-yr, 5-yr (%): Excludes dco, unk slc, age 100+, multiple primaries, ineligible case definition, non-residents, REMOVE IF NO unk sex, non-malignant tumours, IARC non-reportable MPs (variable used: surv1yr_2013, surv1yr_2014, surv1yr_2015, surv3yr_2013, surv3yr_2014, surv3yr_2015, surv5yr_2013, surv5yr_2014; dataset used: "`datapath'\version09\3-output\2013-2018_cancer_survival_deidentified")
putdocx textblock end
putdocx textblock begin
putdocx textblock begin
(12) MIRs: For the incidence dataset, the 2013-2018 annual report incidence dataset was used to organize the data into a format to perform the M:I analysis (cancer dataset used: "`datapath'\version09\3-output\2008_2013-2018_cancer_reportable_nonsurvival_identifiable"; Note: 2008 cases were ultimately excluded)
putdocx textblock end
putdocx textblock begin
(13) MIRs: For the mortality dataset, the 2016, 2017 and 2018 annual report mortality datasets were used to organize the data into a format to perform the M:I analysis (cancer dataset used: (2016) "`datapath'\version09\3-output\2016_prep mort_identifiable"; (2017) "`datapath'\version09\3-output\2017_prep mort_identifiable"; (2018) "`datapath'\version09\3-output\2018_prep mort_identifiable").
putdocx textblock end
putdocx textblock begin
(14) MIRs: All the incidence and mortality datasets were checked to ensure the site variable, sitecr5db, was not missing and site codes were assigned if it was missing in the dataset.
putdocx textblock end
putdocx textblock begin
(15) MIRs: The calculation used for the M:I ratio was number of death cases per site per sex / number of incident cases per site per sex.
putdocx textblock end
putdocx textblock begin
(16) MIRs: Sites that had a M:I ratio exceeding a value of 1 (one) or >99% were checked case by case using the Mortality data + the Casefinding database to determine why that death case was excluded from the incidence dataset.  The datasets and database used for this comparison review process are: MORTALITY:"`datapath'\version09\2-working\yyyy_mir_mort_prep"; INCIDENCE:"`datapath'\version09\2-working\yyyy_mir_incid_prep" and "`datapath'\version09\3-output\2008_2013-2018_cancer_reportable_nonsurvival_identifiable"; CASEFINDING DATABASES:"...Sync\Cancer\CF Database\MasterDb\SyncDb\Databases\Master" and CanReg5 database. The outcome of this investigation can be found in the excel workbook saved in the pathway: "...The University of the West Indies\FORDE, Shelly-Ann - BNR\REPORTS\Annual Reports\2016-2018 Cancer Report\2022-08-22_mir_reviews.xlsx" and also in the pathway: "`datapath'\version09\3-output\2022-08-22_mir_reviews.xlsx".
putdocx textblock end
putdocx textblock begin
(17) MIRs: Based on the above review, the deaths that were captured either at casefinding or abstraction were removed from the deaths totals and the MIRs were re-calculated. Note: missed eligible cases were not removed but were sent to BNR-C DAs to abstract for inclusion in the next annual report.
putdocx textblock end
//putdocx pagebreak

putdocx table tbl1 = data(title results_2018 results_2017 results_2016 results_2015 results_2014 results_2013), halign(center)
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)
putdocx table tbl1(3,2), nformat(%04.2f)
putdocx table tbl1(3,3), nformat(%04.2f)
putdocx table tbl1(3,4), nformat(%04.2f)
putdocx table tbl1(3,5), nformat(%04.2f)
putdocx table tbl1(7,2), nformat(%2.1f)
putdocx table tbl1(7,3), nformat(%2.1f)
putdocx table tbl1(7,4), nformat(%2.1f)
putdocx table tbl1(7,5), nformat(%2.1f)
putdocx table tbl1(8,2), nformat(%2.1f)
putdocx table tbl1(8,3), nformat(%2.1f)
putdocx table tbl1(8,4), nformat(%2.1f)
putdocx table tbl1(8,5), nformat(%2.1f)
putdocx table tbl1(9,2), nformat(%2.1f)
putdocx table tbl1(9,3), nformat(%2.1f)
putdocx table tbl1(9,4), nformat(%2.1f)                       
putdocx table tbl1(10,2), nformat(%2.1f)
putdocx table tbl1(10,3), nformat(%2.1f)
putdocx table tbl1(10,4), nformat(%2.1f)
putdocx table tbl1(10,5), nformat(%2.1f)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", replace
putdocx clear

//save "`datapath'\version09\3-output\2013-2015_2018summstats" ,replace
restore

clear

** Output for above ASIRs
preserve
use "`datapath'\version09\2-working\ASIRs", clear
format asir %04.2f
sort cancer_site year number

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *       ASIRs - ALL        *
				****************************

putdocx clear
putdocx begin

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("ASIRs"), bold
putdocx paragraph, halign(center)
putdocx text ("All Sites by Year"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx table tbl1 = data(cancer_site year number percent asir ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)
putdocx table tbl1(1,8), bold shading(lightgray)
putdocx table tbl1(1,9), bold shading(lightgray)
putdocx table tbl1(1,10), bold shading(lightgray)
putdocx table tbl1(1,11), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear



**********
** 2018 **
**********
preserve
use "`datapath'\version09\2-working\siteorder_2018", clear
sort order_id siteiarc

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *     SITE ORDER - 2018    *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak
// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Site Order Tables"), bold
putdocx paragraph, halign(center)
putdocx text ("2018"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx table tbl1 = data(order_id siteiarc count percentage), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(2,.), bold shading("yellow")
putdocx table tbl1(3,.), bold shading("yellow")
putdocx table tbl1(4,.), bold shading("yellow")
putdocx table tbl1(5,.), bold shading("yellow")
putdocx table tbl1(6,.), bold shading("yellow")
putdocx table tbl1(7,.), bold shading("yellow")
putdocx table tbl1(8,.), bold shading("yellow")
putdocx table tbl1(9,.), bold shading("yellow")
putdocx table tbl1(10,.), bold shading("yellow")
putdocx table tbl1(11,.), bold shading("yellow")
//putdocx table tbl1(12,.), bold shading("yellow")

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear

**********
** 2017 **
**********
preserve
use "`datapath'\version09\2-working\siteorder_2017", clear
sort order_id siteiarc

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *     SITE ORDER - 2017    *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak
// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Site Order Tables"), bold
putdocx paragraph, halign(center)
putdocx text ("2017"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx table tbl1 = data(order_id siteiarc count percentage), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(2,.), bold shading("yellow")
putdocx table tbl1(3,.), bold shading("yellow")
putdocx table tbl1(4,.), bold shading("yellow")
putdocx table tbl1(5,.), bold shading("yellow")
putdocx table tbl1(6,.), bold shading("yellow")
putdocx table tbl1(7,.), bold shading("yellow")
putdocx table tbl1(8,.), bold shading("yellow")
putdocx table tbl1(9,.), bold shading("yellow")
//putdocx table tbl1(10,.), bold shading("yellow")
//putdocx table tbl1(11,.), bold shading("yellow")
putdocx table tbl1(12,.), bold shading("yellow")
putdocx table tbl1(13,.), bold shading("yellow")

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear

**********
** 2016 **
**********
preserve
use "`datapath'\version09\2-working\siteorder_2016", clear
sort order_id siteiarc

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *     SITE ORDER - 2016    *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak
// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Site Order Tables"), bold
putdocx paragraph, halign(center)
putdocx text ("2016"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx table tbl1 = data(order_id siteiarc count percentage), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(2,.), bold shading("yellow")
putdocx table tbl1(3,.), bold shading("yellow")
putdocx table tbl1(4,.), bold shading("yellow")
putdocx table tbl1(5,.), bold shading("yellow")
putdocx table tbl1(6,.), bold shading("yellow")
putdocx table tbl1(7,.), bold shading("yellow")
putdocx table tbl1(8,.), bold shading("yellow")
putdocx table tbl1(9,.), bold shading("yellow")
putdocx table tbl1(10,.), bold shading("yellow")
//putdocx table tbl1(11,.), bold shading("yellow")
//putdocx table tbl1(13,.), bold shading("yellow")
putdocx table tbl1(14,.), bold shading("yellow")

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear

**********
** 2015 **
**********
** Output for above Site Order tables
preserve
use "`datapath'\version09\2-working\siteorder_2015", clear
sort order_id siteiarc

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *     SITE ORDER - 2015    *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak
// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Site Order Tables"), bold
putdocx paragraph, halign(center)
putdocx text ("2015"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx table tbl1 = data(order_id siteiarc count percentage), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(2,.), bold shading("yellow")
putdocx table tbl1(3,.), bold shading("yellow")
putdocx table tbl1(4,.), bold shading("yellow")
putdocx table tbl1(5,.), bold shading("yellow")
putdocx table tbl1(6,.), bold shading("yellow")
putdocx table tbl1(7,.), bold shading("yellow")
putdocx table tbl1(8,.), bold shading("yellow")
putdocx table tbl1(9,.), bold shading("yellow")
putdocx table tbl1(10,.), bold shading("yellow")
putdocx table tbl1(11,.), bold shading("yellow")
//putdocx table tbl1(12,.), bold shading("yellow")

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear

**********
** 2014 **
**********
** Output for above Site Order tables
preserve
use "`datapath'\version09\2-working\siteorder_2014", clear
sort order_id siteiarc

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *     SITE ORDER - 2014    *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak
// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Site Order Tables"), bold
putdocx paragraph, halign(center)
putdocx text ("2014"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx table tbl1 = data(order_id siteiarc count percentage), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(2,.), bold shading("yellow")
putdocx table tbl1(3,.), bold shading("yellow")
putdocx table tbl1(4,.), bold shading("yellow")
putdocx table tbl1(5,.), bold shading("yellow")
putdocx table tbl1(6,.), bold shading("yellow")
putdocx table tbl1(7,.), bold shading("yellow")
//putdocx table tbl1(8,.), bold shading("yellow")
putdocx table tbl1(9,.), bold shading("yellow")
putdocx table tbl1(10,.), bold shading("yellow")
putdocx table tbl1(11,.), bold shading("yellow")
//putdocx table tbl1(12,.), bold shading("yellow")
putdocx table tbl1(13,.), bold shading("yellow")
//putdocx table tbl1(17,.), bold shading("yellow")

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear

**********
** 2013 **
**********
** Output for above Site Order tables
preserve
use "`datapath'\version09\2-working\siteorder_2013", clear
sort order_id siteiarc

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *     SITE ORDER - 2013    *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, halign(center)
putdocx text ("2013"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx table tbl1 = data(order_id siteiarc count percentage), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(2,.), bold shading("yellow")
putdocx table tbl1(3,.), bold shading("yellow")
putdocx table tbl1(4,.), bold shading("yellow")
putdocx table tbl1(5,.), bold shading("yellow")
putdocx table tbl1(7,.), bold shading("yellow")
putdocx table tbl1(8,.), bold shading("yellow")
putdocx table tbl1(9,.), bold shading("yellow")
putdocx table tbl1(10,.), bold shading("yellow")
//putdocx table tbl1(11,.), bold shading("yellow")
putdocx table tbl1(12,.), bold shading("yellow")
//putdocx table tbl1(13,.), bold shading("yellow")
putdocx table tbl1(14,.), bold shading("yellow")
//putdocx table tbl1(15,.), bold shading("yellow")

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear

** Output for top10 by sex
preserve
use "`datapath'\version09\2-working\2018_top10_sex", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *    Top 10 by SEX: 2018   *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Number of cases for 2018 Top 10 cancers by Sex: 2018"), bold
putdocx paragraph, halign(center)
putdocx text ("2018 Top 10 - 2018"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex number), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear

** Output for top10 by sex
preserve
use "`datapath'\version09\2-working\2017_top10_sex", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *    Top 10 by SEX: 2017   *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Number of cases for 2017 Top 10 cancers by Sex: 2017"), bold
putdocx paragraph, halign(center)
putdocx text ("2017 Top 10 - 2017"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex number), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear

** Output for top10 by sex
preserve
use "`datapath'\version09\2-working\2016_top10_sex", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *    Top 10 by SEX: 2016   *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Number of cases for 2016 Top 10 cancers by Sex: 2016"), bold
putdocx paragraph, halign(center)
putdocx text ("2016 Top 10 - 2016"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex number), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear

**********
** 2018 **
**********
** Output for above ASIRs by sex
preserve
use "`datapath'\version09\2-working\ASIRs_2018_female", clear
format asir %04.2f
sort cancer_site asir

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *       ASIRs - FEMALE     *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("ASIRs: 2018"), bold
putdocx paragraph, halign(center)
putdocx text ("Top 5 - FEMALE"), bold font(Helvetica,14,"blue")
putdocx paragraph, halign(center)
putdocx text ("Basis (# tumours/n=960)"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx table tbl1 = data(cancer_site number percent asir ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear

** Output for above ASIRs by sex
preserve
use "`datapath'\version09\2-working\ASIRs_2018_male", clear
format asir %04.2f
sort cancer_site asir

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *       ASIRs - MALE       *
				****************************

putdocx clear
putdocx begin

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("ASIRs: 2018"), bold
putdocx paragraph, halign(center)
putdocx text ("Top 5 - MALE"), bold font(Helvetica,14,"blue")
putdocx paragraph, halign(center)
putdocx text ("Basis (# tumours/n=960)"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx table tbl1 = data(cancer_site number percent asir ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear

**********
** 2017 **
**********
** Output for above ASIRs by sex
preserve
use "`datapath'\version09\2-working\ASIRs_2017_female", clear
format asir %04.2f
sort cancer_site asir

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *       ASIRs - FEMALE     *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("ASIRs: 2017"), bold
putdocx paragraph, halign(center)
putdocx text ("Top 5 - FEMALE"), bold font(Helvetica,14,"blue")
putdocx paragraph, halign(center)
putdocx text ("Basis (# tumours/n=977)"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx table tbl1 = data(cancer_site number percent asir ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear

** Output for above ASIRs by sex
preserve
use "`datapath'\version09\2-working\ASIRs_2017_male", clear
format asir %04.2f
sort cancer_site asir

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *       ASIRs - MALE       *
				****************************

putdocx clear
putdocx begin

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("ASIRs: 2017"), bold
putdocx paragraph, halign(center)
putdocx text ("Top 5 - MALE"), bold font(Helvetica,14,"blue")
putdocx paragraph, halign(center)
putdocx text ("Basis (# tumours/n=977)"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx table tbl1 = data(cancer_site number percent asir ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear

**********
** 2016 **
**********
** Output for above ASIRs by sex
preserve
use "`datapath'\version09\2-working\ASIRs_2016_female", clear
format asir %04.2f
sort cancer_site asir

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *       ASIRs - FEMALE     *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("ASIRs: 2016"), bold
putdocx paragraph, halign(center)
putdocx text ("Top 5 - FEMALE"), bold font(Helvetica,14,"blue")
putdocx paragraph, halign(center)
putdocx text ("Basis (# tumours/n=1070)"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx table tbl1 = data(cancer_site number percent asir ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear

** Output for above ASIRs by sex
preserve
use "`datapath'\version09\2-working\ASIRs_2016_male", clear
format asir %04.2f
sort cancer_site asir

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *       ASIRs - MALE       *
				****************************

putdocx clear
putdocx begin

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("ASIRs: 2016"), bold
putdocx paragraph, halign(center)
putdocx text ("Top 5 - MALE"), bold font(Helvetica,14,"blue")
putdocx paragraph, halign(center)
putdocx text ("Basis (# tumours/n=1070)"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx table tbl1 = data(cancer_site number percent asir ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear


**********
** 2018 **
**********
** Output for top10 age-specific rates by sex
preserve
use "`datapath'\version09\2-working\2018_top10_age+sex_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				*       by sex: 2018       *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific rates for 2018 Top 10 cancers by Sex: 2018"), bold
putdocx paragraph, halign(center)
putdocx text ("2018 Top 10 - 2018"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no cases (dataset used: "`datapath'\version09\2-working\2018_top10_age+sex_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex age5 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear


**********
** 2017 **
**********
** Output for top10 age-specific rates by sex
preserve
use "`datapath'\version09\2-working\2017_2018top10_age+sex_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				*       by sex: 2017       *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific rates for 2018 Top 10 cancers by Sex: 2017"), bold
putdocx paragraph, halign(center)
putdocx text ("2018 Top 10 - 2017"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Notes"), bold
putdocx textblock begin
(1) Excludes age groups and sex with no cases (dataset used: "`datapath'\version09\2-working\2017_2018top10_age+sex_rates")
putdocx textblock end
putdocx textblock begin
(2) Based on 2018 top 10 cases (dataset used: "`datapath'\version09\2-working\2017_2018top10_age+sex_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex age5 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear

** Output for top10 age-specific rates by sex
preserve
use "`datapath'\version09\2-working\2017_top10_age+sex_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				*       by sex: 2017       *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific rates for 2017 Top 10 cancers by Sex: 2017"), bold
putdocx paragraph, halign(center)
putdocx text ("2017 Top 10 - 2017"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Notes"), bold
putdocx textblock begin
(1) Excludes age groups and sex with no cases (dataset used: "`datapath'\version09\2-working\2017_top10_age+sex_rates")
putdocx textblock end
putdocx textblock begin
(2) Based on 2017 top 10 cases (dataset used: "`datapath'\version09\2-working\2017_top10_age+sex_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex age5 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear


**********
** 2016 **
**********
** Output for top10 age-specific rates by sex
preserve
use "`datapath'\version09\2-working\2016_2018top10_age+sex_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				*       by sex: 2016       *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific rates for 2018 Top 10 cancers by Sex: 2016"), bold
putdocx paragraph, halign(center)
putdocx text ("2018 Top 10 - 2016"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Notes"), bold
putdocx textblock begin
(1) Excludes age groups and sex with no cases (dataset used: "`datapath'\version09\2-working\2016_2018top10_age+sex_rates")
putdocx textblock end
putdocx textblock begin
(2) Based on 2018 top 10 cases (dataset used: "`datapath'\version09\2-working\2016_2018top10_age+sex_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex age5 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear

** Output for top10 age-specific rates by sex
preserve
use "`datapath'\version09\2-working\2016_top10_age+sex_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				*       by sex: 2016       *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific rates for 2016 Top 10 cancers by Sex: 2016"), bold
putdocx paragraph, halign(center)
putdocx text ("2016 Top 10 - 2016"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Notes"), bold
putdocx textblock begin
(1) Excludes age groups and sex with no cases (dataset used: "`datapath'\version09\2-working\2016_top10_age+sex_rates")
putdocx textblock end
putdocx textblock begin
(2) Based on 2016 top 10 cases (dataset used: "`datapath'\version09\2-working\2016_top10_age+sex_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex age5 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear


**********
** 2015 **
**********
** Output for top10 age-specific rates by sex
preserve
use "`datapath'\version09\2-working\2015_2018top10_age+sex_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				*       by sex: 2015       *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific rates for 2018 Top 10 cancers by Sex: 2015"), bold
putdocx paragraph, halign(center)
putdocx text ("2018 Top 10 - 2015"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no cases (dataset used: "`datapath'\version09\2-working\2015_2018top10_age+sex_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex age5 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear


**********
** 2014 **
**********
** Output for top10 age-specific rates by sex
preserve
use "`datapath'\version09\2-working\2014_2018top10_age+sex_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				*       by sex: 2014       *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific rates for 2018 Top 10 cancers by Sex: 2014"), bold
putdocx paragraph, halign(center)
putdocx text ("2018 Top 10 - 2014"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no cases (dataset used: "`datapath'\version09\2-working\2014_2018top10_age+sex_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex age5 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear


**********
** 2013 **
**********
** Output for top10 age-specific rates by sex
preserve
use "`datapath'\version09\2-working\2013_2018top10_age+sex_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				*       by sex: 2013       *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific rates for 2018 Top 10 cancers by Sex: 2013"), bold
putdocx paragraph, halign(center)
putdocx text ("2018 Top 10 - 2013"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no cases (dataset used: "`datapath'\version09\2-working\2013_2018top10_age+sex_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex age5 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear


/*
*********************
** 2013-2021 ASMRs **
*********************
** JC 26aug2022: Create excel output of death absolute numbers and ASMRs for 2013-2021 and check with NS + SF if they would prefer exel outputs in conjunction with the Word outputs
preserve
** Create a 2013-2021 ASMR dataset
use "`datapath'\version09\2-working\ASMRs_wpp_2021", clear
replace year=9
append using "`datapath'\version09\2-working\ASMRs_wpp_2020"
replace year=8 if year<2
append using "`datapath'\version09\2-working\ASMRs_wpp_2019"
replace year=7 if year<2
append using "`datapath'\version09\2-working\ASMRs_wpp_2018"
replace year=6 if year<2
append using "`datapath'\version09\2-working\ASMRs_wpp_2017"
replace year=5 if year<2
append using "`datapath'\version09\2-working\ASMRs_wpp_2016"
replace year=4 if year<2
append using "`datapath'\version09\2-working\ASMRs_wpp_2015"
replace year=3 if year<2
append using "`datapath'\version09\2-working\ASMRs_wpp_2014"
replace year=2 if year<2
append using "`datapath'\version09\2-working\ASMRs_wpp_2013"
replace year=1 if year<2

label define year_lab 1 "2013" 2 "2014" 3 "2015" 4 "2016" 5 "2017" 6 "2018" 7 "2019" 8 "2020" 9 "2021" ,modify
label values year year_lab

drop percentage
sort cancer_site year asmr
order cancer_site year number percent asmr ci_lower ci_upper

save "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,replace

** Create Sheet1 with Totals
keep if cancer_site==1

local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.xlsx", firstrow(variables) sheet(Totals, replace) 

putexcel set "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.xlsx", sheet(Totals) modify
putexcel A1:G1, bold
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with AllSites
keep if cancer_site!=1

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.xlsx", firstrow(variables) sheet(AllSites, replace) 

putexcel set "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.xlsx", sheet(AllSites) modify
putexcel A1:G1, bold
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with Prostate
keep if cancer_site==2

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.xlsx", firstrow(variables) sheet(Prostate, replace) 

putexcel set "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.xlsx", sheet(Prostate) modify
putexcel A1:G1, bold
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with Prostate
keep if cancer_site==3

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.xlsx", firstrow(variables) sheet(Breast, replace) 

putexcel set "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.xlsx", sheet(Breast) modify
putexcel A1:G1, bold
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with Prostate
keep if cancer_site==4

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.xlsx", firstrow(variables) sheet(Colon, replace) 

putexcel set "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.xlsx", sheet(Colon) modify
putexcel A1:G1, bold
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with Prostate
keep if cancer_site==5

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.xlsx", firstrow(variables) sheet(Lung, replace) 

putexcel set "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.xlsx", sheet(Lung) modify
putexcel A1:G1, bold
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with Prostate
keep if cancer_site==6

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.xlsx", firstrow(variables) sheet(Pancreas, replace) 

putexcel set "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.xlsx", sheet(Pancreas) modify
putexcel A1:G1, bold
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with Prostate
keep if cancer_site==7

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.xlsx", firstrow(variables) sheet(MM, replace) 

putexcel set "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.xlsx", sheet(MM) modify
putexcel A1:G1, bold
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with Prostate
keep if cancer_site==8

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.xlsx", firstrow(variables) sheet(NHL, replace) 

putexcel set "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.xlsx", sheet(NHL) modify
putexcel A1:G1, bold
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with Prostate
keep if cancer_site==9

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.xlsx", firstrow(variables) sheet(Rectum, replace) 

putexcel set "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.xlsx", sheet(Rectum) modify
putexcel A1:G1, bold
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with Prostate
keep if cancer_site==10

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.xlsx", firstrow(variables) sheet(CorpusUteri, replace) 

putexcel set "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.xlsx", sheet(CorpusUteri) modify
putexcel A1:G1, bold
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with Prostate
keep if cancer_site==11

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.xlsx", firstrow(variables) sheet(Stomach, replace) 

putexcel set "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.xlsx", sheet(Stomach) modify
putexcel A1:G1, bold
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel save

restore
*/
****************
** 2021 ASMRs **
****************
** JC 10may2022: NS requested the ASMRs earlier than rest of stats for Globocan comparison process.
				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *       ASMRs - WPP        *
				****************************

** Output for above ASMRs
use "`datapath'\version09\2-working\ASMRs_wpp_2021", clear
//format asmr %04.2f
//format percentage %04.1f
sort cancer_site year asmr

preserve
putdocx clear
putdocx begin, footer(foot1)
putdocx pagebreak
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER 2021 Annual Report: ASMRs - WPP"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 10. Top 10 Cancer Mortality Statistics for BNR-Cancer, 2021 (Population=281,207)"), bold font(Helvetica,10,"blue")
putdocx textblock begin
Date Prepared: 24-Aug-2022.
Prepared by: JC using Stata 
REDCap (death) data release date: 06-May-2022.
Generated using Dofile: 10i_analysis mort_2021_age10.do
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) No.(tumours): Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version09\3-output\2021_prep mort_deidentified")
putdocx textblock end
putdocx textblock begin
(2) ASMR: Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (distrate using WPP population: pop_wpp_2021-10 and world population dataset: who2000_10-2; cancer dataset used: "`datapath'\version09\3-output\2021_prep mort_deidentified")
putdocx textblock end
putdocx textblock begin
(3) ASMR: Includes reportable cancer terms on both parts of the CODs so does not only take into account underlying COD so numbers and rates are an overestimation.
putdocx textblock end
//putdocx pagebreak
putdocx table tbl1 = data(cancer_site year number percent asmr ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

** Output for top10 age-specific rates
preserve
use "`datapath'\version09\2-working\2021_top10mort_age_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				*      MORTALITY: 2021     *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers: 2021"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2021"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2021_top10mort_age_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear

** Output for top10 age-specific rates by sex
preserve
use "`datapath'\version09\2-working\2021_top10mort_age+sex_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				* by sex - MORTALITY: 2020 *
				****************************

putdocx clear
putdocx begin
//putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers by Sex: 2021"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2021"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2021_top10mort_age+sex_rates")
putdocx textblock end
//putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore


****************
** 2020 ASMRs **
****************
** JC 10may2022: NS requested the ASMRs earlier than rest of stats for Globocan comparison process.
				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *       ASMRs - WPP        *
				****************************

** Output for above ASMRs
use "`datapath'\version09\2-working\ASMRs_wpp_2020", clear
//format asmr %04.2f
//format percentage %04.1f
sort cancer_site year asmr

preserve
putdocx clear
putdocx begin, footer(foot1)
putdocx pagebreak
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER 2020 Annual Report: ASMRs - WPP"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 10. Top 10 Cancer Mortality Statistics for BNR-Cancer, 2020 (Population=287,371)"), bold font(Helvetica,10,"blue")
putdocx textblock begin
Date Prepared: 28-Jun-2022.
Prepared by: JC using Stata 
REDCap (death) data release date: 06-May-2022.
Generated using Dofile: 10h_analysis mort_2020_age10.do
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) No.(tumours): Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version09\3-output\2020_prep mort_deidentified")
putdocx textblock end
putdocx textblock begin
(2) ASMR: Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (distrate using WPP population: pop_wpp_2020-10 and world population dataset: who2000_10-2; cancer dataset used: "`datapath'\version09\3-output\2020_prep mort_deidentified")
putdocx textblock end
putdocx textblock begin
(3) ASMR: Includes reportable cancer terms on both parts of the CODs so does not only take into account underlying COD so numbers and rates are an overestimation.
putdocx textblock end
//putdocx pagebreak
putdocx table tbl1 = data(cancer_site year number percent asmr ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

** Output for top10 age-specific rates
preserve
use "`datapath'\version09\2-working\2020_top10mort_age_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				*      MORTALITY: 2020     *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers: 2020"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2020"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2020_top10mort_age_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear

** Output for top10 age-specific rates by sex
preserve
use "`datapath'\version09\2-working\2020_top10mort_age+sex_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				* by sex - MORTALITY: 2020 *
				****************************

putdocx clear
putdocx begin
//putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers by Sex: 2020"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2020"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2020_top10mort_age+sex_rates")
putdocx textblock end
//putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore


****************
** 2019 ASMRs **
****************
** JC 10may2022: NS requested the ASMRs earlier than rest of stats for Globocan comparison process.
				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *       ASMRs - WPP        *
				****************************

** Output for above ASMRs
use "`datapath'\version09\2-working\ASMRs_wpp_2019", clear
//format asmr %04.2f
//format percentage %04.1f
sort cancer_site year asmr

preserve
putdocx clear
putdocx begin, footer(foot1)
//putdocx pagebreak
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER 2019 Annual Report: ASMRs - WPP"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 10. Top 10 Cancer Mortality Statistics for BNR-Cancer, 2019 (Population=287,021)"), bold font(Helvetica,10,"blue")
putdocx textblock begin
Date Prepared: 28-Jun-2022.
Prepared by: JC using Stata 
REDCap (death) data release date: 06-May-2022.
Generated using Dofile: 10g_analysis mort_2019_age10.do
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) No.(tumours): Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version09\3-output\2019_prep mort_deidentified")
putdocx textblock end
putdocx textblock begin
(2) ASMR: Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (distrate using WPP population: pop_wpp_2019-10 and world population dataset: who2000_10-2; cancer dataset used: "`datapath'\version09\3-output\2019_prep mort_deidentified")
putdocx textblock end
putdocx textblock begin
(3) ASMR: Includes reportable cancer terms on both parts of the CODs so does not only take into account underlying COD so numbers and rates are an overestimation.
putdocx textblock end
//putdocx pagebreak
putdocx table tbl1 = data(cancer_site year number percent asmr ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

** Output for top10 age-specific rates
preserve
use "`datapath'\version09\2-working\2019_top10mort_age_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				*      MORTALITY: 2019     *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers: 2019"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2019"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2019_top10mort_age_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear

** Output for top10 age-specific rates by sex
preserve
use "`datapath'\version09\2-working\2019_top10mort_age+sex_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				* by sex - MORTALITY: 2019 *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers by Sex: 2019"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2019"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2019_top10mort_age+sex_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore


****************
** 2018 ASMRs **
****************
** JC 10may2022: NS requested the ASMRs earlier than rest of stats for Globocan comparison process.
				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *       ASMRs - WPP        *
				****************************

** Output for above ASMRs
use "`datapath'\version09\2-working\ASMRs_wpp_2018", clear
//format asmr %04.2f
//format percentage %04.1f
sort cancer_site year asmr

preserve
putdocx clear
putdocx begin, footer(foot1)
putdocx pagebreak
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER 2018 Annual Report: ASMRs - WPP"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 10. Top 10 Cancer Mortality Statistics for BNR-Cancer, 2018 (Population=286,640)"), bold font(Helvetica,10,"blue")
putdocx textblock begin
Date Prepared: 10-May-2022.
Prepared by: JC using Stata 
REDCap (death) data release date: 06-May-2022.
Generated using Dofile: 10f_analysis mort_2018_age10.do
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) No.(tumours): Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version09\3-output\2018_prep mort_deidentified")
putdocx textblock end
putdocx textblock begin
(2) ASMR: Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (distrate using WPP population: pop_wpp_2018-10 and world population dataset: who2000_10-2; cancer dataset used: "`datapath'\version09\3-output\2018 prep mort_deidentified")
putdocx textblock end
putdocx textblock begin
(3) ASMR: Includes reportable cancer terms on both parts of the CODs so does not only take into account underlying COD so numbers and rates are an overestimation.
putdocx textblock end
//putdocx pagebreak
putdocx table tbl1 = data(cancer_site year number percent asmr ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

** Output for top10 age-specific rates
preserve
use "`datapath'\version09\2-working\2018_top10mort_age_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				*      MORTALITY: 2018     *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers: 2018"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2018"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2018_top10mort_age_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear

** Output for top10 age-specific rates by sex
preserve
use "`datapath'\version09\2-working\2018_top10mort_age+sex_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				* by sex - MORTALITY: 2018 *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers by Sex: 2018"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2018"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2018_top10mort_age+sex_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore


****************
** 2017 ASMRs **
****************
** JC 10may2022: NS requested the ASMRs earlier than rest of stats for Globocan comparison process.
				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *       ASMRs - WPP        *
				****************************

** Output for above ASMRs
use "`datapath'\version09\2-working\ASMRs_wpp_2017", clear
//format asmr %04.2f
//format percentage %04.1f
sort cancer_site year asmr

preserve
putdocx clear
putdocx begin, footer(foot1)
putdocx pagebreak
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER 2017 Annual Report: ASMRs - WPP"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 10. Top 10 Cancer Mortality Statistics for BNR-Cancer, 2017 (Population=286,229)"), bold font(Helvetica,10,"blue")
putdocx textblock begin
Date Prepared: 18-May-2022.
Prepared by: JC using Stata 
REDCap (death) data release date: 06-May-2022.
Generated using Dofile: 10e_analysis mort_2017_age10.do
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) No.(tumours): Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version09\3-output\2017_prep mort_deidentified")
putdocx textblock end
putdocx textblock begin
(2) ASMR: Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (distrate using WPP population: pop_wpp_2017-10 and world population dataset: who2000_10-2; cancer dataset used: "`datapath'\version09\3-output\2017_prep mort_deidentified")
putdocx textblock end
putdocx textblock begin
(3) ASMR: Includes reportable cancer terms on both parts of the CODs so does not only take into account underlying COD so numbers and rates are an overestimation.
putdocx textblock end
//putdocx pagebreak
putdocx table tbl1 = data(cancer_site year number percent asmr ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

** Output for top10 age-specific rates
preserve
use "`datapath'\version09\2-working\2017_top10mort_age_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				*      MORTALITY: 2017     *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers: 2017"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2017"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2017_top10mort_age_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear

** Output for top10 age-specific rates by sex
preserve
use "`datapath'\version09\2-working\2017_top10mort_age+sex_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				* by sex - MORTALITY: 2017 *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers by Sex: 2017"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2017"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2017_top10mort_age+sex_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore


****************
** 2016 ASMRs **
****************
** JC 10may2022: NS requested the ASMRs earlier than rest of stats for Globocan comparison process.
				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *       ASMRs - WPP        *
				****************************

** Output for above ASMRs
use "`datapath'\version09\2-working\ASMRs_wpp_2016", clear
//format asmr %04.2f
//format percentage %04.1f
sort cancer_site year asmr

preserve
putdocx clear
putdocx begin, footer(foot1)
putdocx pagebreak
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER 2016 Annual Report: ASMRs - WPP"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 10. Top 10 Cancer Mortality Statistics for BNR-Cancer, 2016 (Population=285,798)"), bold font(Helvetica,10,"blue")
putdocx textblock begin
Date Prepared: 18-May-2022.
Prepared by: JC using Stata 
REDCap (death) data release date: 06-May-2022.
Generated using Dofile: 10d_analysis mort_2016_age10.do
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) No.(tumours): Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version09\3-output\2016_prep mort_deidentified")
putdocx textblock end
putdocx textblock begin
(2) ASMR: Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (distrate using WPP population: pop_wpp_2016-10 and world population dataset: who2000_10-2; cancer dataset used: "`datapath'\version09\3-output\2016_prep mort_deidentified")
putdocx textblock end
putdocx textblock begin
(3) ASMR: Includes reportable cancer terms on both parts of the CODs so does not only take into account underlying COD so numbers and rates are an overestimation.
putdocx textblock end
//putdocx pagebreak
putdocx table tbl1 = data(cancer_site year number percent asmr ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

** Output for top10 age-specific rates
preserve
use "`datapath'\version09\2-working\2016_top10mort_age_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				*      MORTALITY: 2016     *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers: 2016"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2016"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2016_top10mort_age_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear

** Output for top10 age-specific rates by sex
preserve
use "`datapath'\version09\2-working\2016_top10mort_age+sex_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				* by sex - MORTALITY: 2016 *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers by Sex: 2016"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2016"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2016_top10mort_age+sex_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore


****************
** 2015 ASMRs **
****************
** JC 10may2022: NS requested the ASMRs earlier than rest of stats for Globocan comparison process.
				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *       ASMRs - WPP        *
				****************************

** Output for above ASMRs
use "`datapath'\version09\2-working\ASMRs_wpp_2015", clear
//format asmr %04.2f
//format percentage %04.1f
sort cancer_site year asmr

preserve
putdocx clear
putdocx begin, footer(foot1)
putdocx pagebreak
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER 2015 Annual Report: ASMRs - WPP"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 10. Top 10 Cancer Mortality Statistics for BNR-Cancer, 2015 (Population=285,327)"), bold font(Helvetica,10,"blue")
putdocx textblock begin
Date Prepared: 24-Aug-2022.
Prepared by: JC using Stata 
//REDCap (death) data release date: 06-May-2022.
Generated using Dofile: 10c_analysis mort_2015_age10.do
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) No.(tumours): Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version09\1-input\2015_prep mort")
putdocx textblock end
putdocx textblock begin
(2) ASMR: Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (distrate using WPP population: pop_wpp_2016-10 and world population dataset: who2000_10-2; cancer dataset used: "`datapath'\version09\1-input\2015_prep mort")
putdocx textblock end
putdocx textblock begin
(3) ASMR: Includes reportable cancer terms on both parts of the CODs so does not only take into account underlying COD so numbers and rates are an overestimation.
putdocx textblock end
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Althought this cancer death analysis was after the DataGroup SharePoint infrastrucutre (see p117/version02 and VS Code branch '2015AnnualReport V03'), the previous 2015 ASMRs mistakenly used the BSS population totals so these rates have been corrected to the WPP population.
putdocx textblock end
//putdocx pagebreak
putdocx table tbl1 = data(cancer_site year number percent asmr ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

** Output for top10 age-specific rates
preserve
use "`datapath'\version09\2-working\2015_top10mort_age_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				*      MORTALITY: 2015     *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers: 2015"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2015"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2015_top10mort_age_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear

** Output for top10 age-specific rates by sex
preserve
use "`datapath'\version09\2-working\2015_top10mort_age+sex_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				* by sex - MORTALITY: 2016 *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers by Sex: 2015"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2015"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2015_top10mort_age+sex_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore


****************
** 2014 ASMRs **
****************
** JC 10may2022: NS requested the ASMRs earlier than rest of stats for Globocan comparison process.
				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *       ASMRs - WPP        *
				****************************

** Output for above ASMRs
use "`datapath'\version09\2-working\ASMRs_wpp_2014", clear
//format asmr %04.2f
//format percentage %04.1f
sort cancer_site year asmr

preserve
putdocx clear
putdocx begin, footer(foot1)
putdocx pagebreak
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER 2014 Annual Report: ASMRs - WPP"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 10. Top 10 Cancer Mortality Statistics for BNR-Cancer, 2014 (Population=284,825)"), bold font(Helvetica,10,"blue")
putdocx textblock begin
Date Prepared: 24-Aug-2022.
Prepared by: JC using Stata 
//REDCap (death) data release date: 06-May-2022.
Generated using Dofile: 10b_analysis mort_2014_age10.do
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) No.(tumours): Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version09\1-input\2014_cancer_mort_dc")
putdocx textblock end
putdocx textblock begin
(2) ASMR: Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (distrate using WPP population: pop_wpp_2016-10 and world population dataset: who2000_10-2; cancer dataset used: "`datapath'\version09\1-input\2014_cancer_mort_dc")
putdocx textblock end
putdocx textblock begin
(3) ASMR: Includes reportable cancer terms on both parts of the CODs so does not only take into account underlying COD so numbers and rates are an overestimation.
putdocx textblock end
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
This cancer death analysis was before the DataGroup SharePoint infrastrucutre so original files and data can be found in path: "...\Sync\DM\Stata\Stata do files\data_cleaning\2014\cancer\versions\version02\" + "...\Sync\DM\Stata\Stata do files\data_analysis\2014\cancer\versions\version01\".
putdocx textblock end
//putdocx pagebreak
putdocx table tbl1 = data(cancer_site year number percent asmr ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

** Output for top10 age-specific rates
preserve
use "`datapath'\version09\2-working\2014_top10mort_age_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				*      MORTALITY: 2014     *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers: 2014"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2014"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2014_top10mort_age_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear

** Output for top10 age-specific rates by sex
preserve
use "`datapath'\version09\2-working\2014_top10mort_age+sex_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				* by sex - MORTALITY: 2014 *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers by Sex: 2014"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2014"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2014_top10mort_age+sex_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

****************
** 2013 ASMRs **
****************
** JC 10may2022: NS requested the ASMRs earlier than rest of stats for Globocan comparison process.
				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *       ASMRs - WPP        *
				****************************

** Output for above ASMRs
use "`datapath'\version09\2-working\ASMRs_wpp_2013", clear
//format asmr %04.2f
//format percentage %04.1f
sort cancer_site year asmr

preserve
putdocx clear
putdocx begin, footer(foot1)
putdocx pagebreak
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER 2013 Annual Report: ASMRs - WPP"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 10. Top 10 Cancer Mortality Statistics for BNR-Cancer, 2013 (Population=284,294)"), bold font(Helvetica,10,"blue")
putdocx textblock begin
Date Prepared: 24-Aug-2022.
Prepared by: JC using Stata 
//REDCap (death) data release date: 06-May-2022.
Generated using Dofile: 10f_analysis mort_2013+2014_age10.do
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) No.(tumours): Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version09\1-input\2013_cancer_for_MR_only")
putdocx textblock end
putdocx textblock begin
(2) ASMR: Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (distrate using WPP population: pop_wpp_2013-10 and world population dataset: who2000_10-2; cancer death dataset used: "`datapath'\version09\1-input\2013_cancer_for_MR_only")
putdocx textblock end
putdocx textblock begin
(3) ASMR: Includes reportable cancer terms on both parts of the CODs so does not only take into account underlying COD so numbers and rates are an overestimation.
putdocx textblock end
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
This cancer death database was based on A.Rose's method so cancer_site is the site groupings created by AR since the cancer CODs were not ICD-10 coded (original files and data can be found in path: "...\Sync\DM\Stata\Stata do files\data_cleaning\2013\cancer\versions\version03\" + "...\Sync\DM\Stata\Stata do files\data_analysis\2013\cancer\versions\version02\"). Site groupings differ slightly from 2014 onwards as 2014 onwards used ICD-10 coded cancer CODs + IARC's site groupings.
putdocx textblock end
//putdocx pagebreak
putdocx table tbl1 = data(cancer_site year number percent asmr ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

** Output for top10 age-specific rates
preserve
use "`datapath'\version09\2-working\2013_top10mort_age_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				*      MORTALITY: 2013     *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers: 2013"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2013"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2013_top10mort_age_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore

clear

** Output for top10 age-specific rates by sex
preserve
use "`datapath'\version09\2-working\2013_top10mort_age+sex_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				* by sex - MORTALITY: 2013 *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers by Sex: 2013"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2013"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2013_top10mort_age+sex_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore


** Output for cases by PARISH
clear
use "`datapath'\version09\2-working\2013-2018_cancer_numbers", clear
				*******************************
				*	     MS WORD REPORT       *
				*   ANNUAL REPORT STATISTICS  *
                * Cases by parish + yr + site *
				*******************************


** All cases by parish
preserve
tab parish
contract parish, freq(count) percent(percentage)

putdocx clear
putdocx begin

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Cases by Parish"), bold
putdocx paragraph, halign(center)
putdocx text ("Cases by Parish (# tumours/n=5,867)"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename parish Parish
rename count Total_Records
rename percentage Percent
putdocx table tbl_parish = data("Parish Total_Records Percent"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_parish(1,.), bold

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear

save "`datapath'\version09\2-working\2013-2018_cases_parish.dta" ,replace
label data "BNR-Cancer 2013-2018 Cases by Parish"
notes _dta :These data prepared for Natasha Sobers - 2016-2018 annual report
restore


** All cases by parish + dxyr
preserve
tab parish dxyr
contract parish dxyr, freq(count) percent(percentage)

putdocx clear
putdocx begin

// Create a paragraph
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Cases by Parish + Year"), bold
putdocx paragraph, halign(center)
putdocx text ("Cases by Parish (2013: # tumours/n=884)"), bold font(Helvetica,14,"blue")
putdocx paragraph, halign(center)
putdocx text ("Cases by Parish (2014: # tumours/n=884)"), bold font(Helvetica,14,"blue")
putdocx paragraph, halign(center)
putdocx text ("Cases by Parish (2015: # tumours/n=1,092)"), bold font(Helvetica,14,"blue")
putdocx paragraph, halign(center)
putdocx text ("Cases by Parish (2016: # tumours/n=1,070)"), bold font(Helvetica,14,"blue")
putdocx paragraph, halign(center)
putdocx text ("Cases by Parish (2017: # tumours/n=977)"), bold font(Helvetica,14,"blue")
putdocx paragraph, halign(center)
putdocx text ("Cases by Parish (2018: # tumours/n=960)"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename parish Parish
rename dxyr Year
rename count Total_Records
rename percentage Percent
putdocx table tbl_year = data("Parish Year Total_Records Percent"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_year(1,.), bold

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear

save "`datapath'\version09\2-working\2013-2018_cases_parish+dxyr.dta" ,replace
label data "BNR-Cancer 2013-2018 Cases by Parish"
notes _dta :These data prepared for Natasha Sobers - 2016-2018 annual report
restore


** All cases by parish + site
preserve
tab siteiarc parish
contract siteiarc parish, freq(count) percent(percentage)

putdocx clear
putdocx begin

// Create a paragraph
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Cases by Parish + Site"), bold
putdocx paragraph, halign(center)
putdocx text ("Cases by Parish (# tumours/n=5,867)"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename parish Parish
rename siteiarc Site
rename count Total_Records
rename percentage Percent
putdocx table tbl_site = data("Parish Site Total_Records Percent"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_site(1,.), bold

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear

save "`datapath'\version09\2-working\2013-2018_cases_parish+site.dta" ,replace
label data "BNR-Cancer 2013-2018 Cases by Parish"
notes _dta :These data prepared for Natasha Sobers - 2016-2018 annual report
restore


** All cases by parish + site (2013)
preserve
drop if dxyr!=2013
tab siteiarc parish
contract siteiarc parish, freq(count) percent(percentage)

putdocx clear
putdocx begin

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Cases by Parish + Site: 2013"), bold
putdocx paragraph, halign(center)
putdocx text ("Cases by Parish (# tumours/n=884)"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename parish Parish
rename siteiarc Site
rename count Total_Records
rename percentage Percent
putdocx table tbl_site = data("Parish Site Total_Records Percent"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_site(1,.), bold

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear

save "`datapath'\version09\2-working\2013_cases_parish+site.dta" ,replace
label data "BNR-Cancer 2013 Cases by Parish"
notes _dta :These data prepared for Natasha Sobers - 2016-2018 annual report
restore

** All cases by parish + site (2014)
preserve
drop if dxyr!=2014
tab siteiarc parish
contract siteiarc parish, freq(count) percent(percentage)

putdocx clear
putdocx begin

// Create a paragraph
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Cases by Parish + Site: 2014"), bold
putdocx paragraph, halign(center)
putdocx text ("Cases by Parish (# tumours/n=884)"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename parish Parish
rename siteiarc Site
rename count Total_Records
rename percentage Percent
putdocx table tbl_site = data("Parish Site Total_Records Percent"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_site(1,.), bold

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear

save "`datapath'\version09\2-working\2014_cases_parish+site.dta" ,replace
label data "BNR-Cancer 2014 Cases by Parish"
notes _dta :These data prepared for Natasha Sobers - 2016-2018 annual report
restore

** All cases by parish + site (2015)
preserve
drop if dxyr!=2015
tab siteiarc parish
contract siteiarc parish, freq(count) percent(percentage)

putdocx clear
putdocx begin

// Create a paragraph
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Cases by Parish + Site: 2015"), bold
putdocx paragraph, halign(center)
putdocx text ("Cases by Parish (# tumours/n=1,092)"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename parish Parish
rename siteiarc Site
rename count Total_Records
rename percentage Percent
putdocx table tbl_site = data("Parish Site Total_Records Percent"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_site(1,.), bold

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear

save "`datapath'\version09\2-working\2015_cases_parish+site.dta" ,replace
label data "BNR-Cancer 2015 Cases by Parish"
notes _dta :These data prepared for Natasha Sobers - 2016-2018 annual report
restore

** All cases by parish + site (2016)
preserve
drop if dxyr!=2016
tab siteiarc parish
contract siteiarc parish, freq(count) percent(percentage)

putdocx clear
putdocx begin

// Create a paragraph
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Cases by Parish + Site: 2016"), bold
putdocx paragraph, halign(center)
putdocx text ("Cases by Parish (# tumours/n=1,070)"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename parish Parish
rename siteiarc Site
rename count Total_Records
rename percentage Percent
putdocx table tbl_site = data("Parish Site Total_Records Percent"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_site(1,.), bold

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear

save "`datapath'\version09\2-working\2016_cases_parish+site.dta" ,replace
label data "BNR-Cancer 2016 Cases by Parish"
notes _dta :These data prepared for Natasha Sobers - 2016-2018 annual report
restore

** All cases by parish + site (2017)
preserve
drop if dxyr!=2017
tab siteiarc parish
contract siteiarc parish, freq(count) percent(percentage)

putdocx clear
putdocx begin

// Create a paragraph
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Cases by Parish + Site: 2017"), bold
putdocx paragraph, halign(center)
putdocx text ("Cases by Parish (# tumours/n=977)"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename parish Parish
rename siteiarc Site
rename count Total_Records
rename percentage Percent
putdocx table tbl_site = data("Parish Site Total_Records Percent"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_site(1,.), bold

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear

save "`datapath'\version09\2-working\2017_cases_parish+site.dta" ,replace
label data "BNR-Cancer 2017 Cases by Parish"
notes _dta :These data prepared for Natasha Sobers - 2016-2018 annual report
restore

** All cases by parish + site (2018)
preserve
drop if dxyr!=2018
tab siteiarc parish
contract siteiarc parish, freq(count) percent(percentage)

putdocx clear
putdocx begin

// Create a paragraph
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Cases by Parish + Site: 2018"), bold
putdocx paragraph, halign(center)
putdocx text ("Cases by Parish (# tumours/n=960)"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename parish Parish
rename siteiarc Site
rename count Total_Records
rename percentage Percent
putdocx table tbl_site = data("Parish Site Total_Records Percent"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_site(1,.), bold

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear

save "`datapath'\version09\2-working\2018_cases_parish+site.dta" ,replace
label data "BNR-Cancer 2018 Cases by Parish"
notes _dta :These data prepared for Natasha Sobers - 2016-2018 annual report
restore

STOP

				****************************
				* 	    MS WORD REPORT     *
				* ANNUAL REPORT STATISTICS *
				* 	 Mortality:Incidence   * 
				*       Ratio RESULTS      *
				****************************
** Create MS Word results table with absolute case totals + the MIRs for grouped years (2016-2018), by site, by sex 
preserve
use "`datapath'\version09\3-output\2016-2018_mirs_adjusted" ,clear

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Mortality:Incidence Ratios"), bold
putdocx paragraph, style(Heading2)
putdocx text ("MIRs Grouped (Dofile: 22d_MIRs_2016-2018.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table: Case Totals + Mortality:Incidence Ratios for BNR-Cancer Grouped Years (2016-2018)"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Background"), bold
putdocx textblock begin
A data quality assessment performed by the IARC Hub noted large M:I ratios in certain sites. IARC Hub used mortality data from the CARPHA mortality database, which collects data from Ministry of Health and Wellness. This report performs a secondary check using mortality data collected directly from the Barbados Registration Dept. This data quality indicator is one method of assessing completeness.
putdocx textblock end

putdocx paragraph, halign(center)

putdocx table tbl1 = data(sitecr5db sex mir_all mir_iarc cases_mort_all cases_incid_all), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)


local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore
				*******************************
				*	     MS WORD REPORT       *
				*   ANNUAL REPORT STATISTICS  *
                *   Length of Time (DX + DOD) *
				*******************************
preserve
use "`datapath'\version09\2-working\doddotdiff", clear
putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Date Difference"), bold
putdocx paragraph, style(Heading2)
putdocx text ("Date Difference (Dofile: 20d_final clean.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Length of Time Between Diagnosis and Death in MONTHS (Median, Range and Mean), 2008-2018."), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Below table uses the variables [dot] and [dod] to display results for patients by tumour (i.e. MPs not excluded) that have died. It does not include cases where [dod] is missing, i.e. Alive patients.")

putdocx paragraph, halign(center)

putdocx table tbl1 = data(year median_doddotdiff range_lower range_upper mean_doddotdiff), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx", append
putdocx clear
restore
				*******************************
				*	     MS WORD REPORT       *
				*   ANNUAL REPORT STATISTICS  *
                *   Resident Status by DxYr   *
				*******************************

** SF requested via WhatsApp on 23aug2022: table with dxyr and resident status as wants to see those that are nonreportable due to resident status
preserve
use "`datapath'\version09\3-output\2008_2013-2018_nonsurvival_nonreportable" ,clear

table resident dxyr if resident!=1

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Resident Status"), bold
putdocx paragraph, style(Heading2)
putdocx text ("Resident Status (Dofile: 20d_final clean.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Resident Status, 2008-2018."), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Below table uses the variables [resident] and [dxyr] to display results for patients only (i.e. MPs excluded).")

putdocx paragraph, halign(center)
putdocx text ("2008,2013-2018"), bold font(Helvetica,10,"blue")
tab2docx resident if dxyr>2007 & patient==1

putdocx paragraph, halign(center)
putdocx text ("Non-Residents by Diagnosis Year, 2008-2018."), bold font(Helvetica,10,"blue")
putdocx paragraph, halign(center)
putdocx image "`datapath'\version09\2-working\ResidentStatusByYear.png", width(14.98) height(4.36)
putdocx paragraph

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx" ,append
putdocx clear
restore

				*******************************
				*	     MS WORD REPORT       *
				*   ANNUAL REPORT STATISTICS  *
                *  Basis of Diagnosis by DxYr *
				*******************************

** SF requested via Zoom meeting on 18aug2022: table with dxyr and basis
preserve
use "`datapath'\version09\3-output\2008_2013-2018_cancer_reportable_nonsurvival_deidentified" ,clear

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Most Valid Basis Of Diagnosis"), bold
putdocx paragraph, style(Heading2)
putdocx text ("Basis Of Diagnosis (Dofile: 25a_analysis numbers.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Basis Of Diagnosis, 2008-2018."), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Below table uses the variables [basis] and [dxyr] to display results for patients by tumour (i.e. MPs not excluded).")

putdocx paragraph, halign(center)
putdocx text ("2008,2013-2018"), bold font(Helvetica,10,"blue")
tab2docx basis if dxyr>2007

putdocx paragraph, halign(center)
putdocx text ("Basis Of Diagnosis by Diagnosis Year, 2008-2018."), bold font(Helvetica,10,"blue")
putdocx paragraph, halign(center)
putdocx image "`datapath'\version09\2-working\BODbyYear.png", width(17.94) height(5.08)
putdocx paragraph

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx" ,append
putdocx clear
restore

** SF requested via Zoom meeting on 18aug2022: table with dxyr and basis
** For ease, I copied and pasted the below results into the Word doc:

** LOAD 2008, 2013-2018 cleaned cancer incidence dataset from p117/version15/20d_final clean.do
use "`datapath'\version09\3-output\2008_2013-2018_cancer_reportable_nonsurvival_deidentified" ,clear

count //6682

tab basis dxyr
/*
                      |                                Diagnosis Year
   Basis Of Diagnosis |      2008       2013       2014       2015       2016       2017       2018 |     Total
----------------------+-----------------------------------------------------------------------------+----------
                  DCO |        52         59         41        101         82         79         55 |       469 
        Clinical only |        16         21         38         67        101         83         43 |       369 
Clinical Invest./Ult  |        45         60         36         62         55         58         43 |       359 
Lab test (biochem/imm |         7          5         10         14         31         13         17 |        97 
        Cytology/Haem |        31         31         45         28         23         19         27 |       204 
Hx of mets/Autopsy wi |        24         16         13         19         13         24         21 |       130 
Hx of primary/Autopsy |       635        646        638        754        729        683        752 |     4,837 
              Unknown |         5         46         63         47         36         18          2 |       217 
----------------------+-----------------------------------------------------------------------------+----------
                Total |       815        884        884      1,092      1,070        977        960 |     6,682
*/
table basis dxyr
/*
-------------------------------------------------------------------------------------------------------------------------------
                                                                    |                       Diagnosis Year                     
                                                                    |  2008   2013   2014    2015    2016   2017   2018   Total
--------------------------------------------------------------------+----------------------------------------------------------
Basis Of Diagnosis                                                  |                                                          
  DCO                                                               |    52     59     41     101      82     79     55     469
  Clinical only                                                     |    16     21     38      67     101     83     43     369
  Clinical Invest./Ult Sound/Exploratory Surgery/Autopsy without hx |    45     60     36      62      55     58     43     359
  Lab test (biochem/immuno.)                                        |     7      5     10      14      31     13     17      97
  Cytology/Haem                                                     |    31     31     45      28      23     19     27     204
  Hx of mets/Autopsy with Hx of mets                                |    24     16     13      19      13     24     21     130
  Hx of primary/Autopsy with Hx of primary                          |   635    646    638     754     729    683    752   4,837
  Unknown                                                           |     5     46     63      47      36     18      2     217
  Total                                                             |   815    884    884   1,092   1,070    977    960   6,682
-------------------------------------------------------------------------------------------------------------------------------
*/


contract basis dxyr
rename _freq number

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, halign(center)

putdocx table tbl1 = data(dxyr basis number), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.docx" ,append
putdocx clear