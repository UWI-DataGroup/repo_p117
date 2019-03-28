** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			4_2014_dc.do
    //  project:				BNR
    //  analysts:				Jacqueline CAMPBELL
    //  date first created      12-MAR-2019
    // 	date last modified	    12-MAR-2019
    //  algorithm task			Cleaning 2014 cancer dataset, Creating site groupings
    //  status                  Completed
    //  objectve                To have one dataset with cleaned and grouped 2014 data for 2014 cancer report.


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
    log using "`logpath'\4_2014_dc.smcl", replace
** HEADER -----------------------------------------------------

* ************************************************************************
* CLEANING
* Using Sync 2014 data cleaning dofile (version02\5_merge_cancer_dc.do)
**************************************************************************

** Load the dataset with recently matched death data
use "`datapath'\version01\1-input\2014_cancer_merge_dc", clear

count //


** Re-assign deathid values to match BNR-DeathDataALL redcap database
count if deathid==. & slc==2 //4 - checked and not found in redcap death data
**list pid deathid fname lname dob natregno nrn if deathid==. & slc==2

** Cleaning cod field based on death data & CR5db
count if cod1a=="" & (cr5cod!="99" & cr5cod!="") //4
replace cod1a=cr5cod if cod1a=="" & (cr5cod!="99" & cr5cod!="") //4 changes

** Updated cod field based on primarysite/hx vs cod1a
count if slc==2 & cod==. //0
count if deceased==1 & cod==. //0

** Check for DCOs to ensure date of tumour = death of date (dot=dod)
count if basis==0 & dot!=dod //0
count if slc==2 & dod==. //0
count if patient==. //0
count if deceased==1 & dod==. //0

** Check for missing date(s) at last contact
count if dlc==. //3
list pid fname lname deceased dod if dlc==.
replace dlc=dod if dlc==. //3 changes

** Check for missing ICD-10 codes
count if icd10=="" //0

count //927


** Put variables in order you want them to appear
order pid fname lname init age sex dob natregno resident slc dlc ///
	    parish cr5cod primarysite morph top lat beh hx

save "`datapath'\version01\2-working\2014_cancer_dc" ,replace
label data "BNR-Cancer prepared 2014 data"
notes _dta :These data prepared for 2014 cancer report
