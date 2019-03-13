** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    2_clean_2014.do
    //  project:				        BNR
    //  analysts:				       	Jacqueline CAMPBELL
    //  date first created      12-MAR-2019
    // 	date last modified	    12-MAR-2019
    //  algorithm task			    Cleaning 2014 cancer dataset, Creating site groupings
    //  status                  Completed
    //  objectve               To have one dataset with cleaned and grouped 2014 data for 2014 cancer report.


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
    log using "`logpath'\2_clean_2014_dc.smcl", replace
** HEADER -----------------------------------------------------

* ************************************************************************
* CLEANING
* Using NAACCR-IACR_1b_cancer_Deaths_2014 dofile
**************************************************************************

** Load the dataset with recently matched death data
use "`datapath'\version01\1-input\2014_cancer_merge_dc.dta", clear

count //

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

count //927

count if icd10==""
