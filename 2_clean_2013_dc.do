** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    2_clean_2013.do
    //  project:				        BNR
    //  analysts:				       	Jacqueline CAMPBELL
    //  date first created      12-MAR-2019
    // 	date last modified	    12-MAR-2019
    //  algorithm task			    Cleaning 2013 cancer dataset, Creating site groupings
    //  status                  Completed
    //  objectve               To have one dataset with cleaned and grouped 2013 data for inclusion in 2014 cancer report.


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
    log using "`logpath'\2_clean_2013_dc.smcl", replace
** HEADER -----------------------------------------------------

* ************************************************************************
* CLEANING
* Using version02 dofiles created in 2014 data review folder (Sync)
**************************************************************************

** Load the dataset with recently matched death data
use "`datapath'\version01\2-working\2013_cancer_prep_dc.dta", clear

count //

** Append missed 2013 cases (6_clean_cancer_2013.do in 2014 data cleaning folder)

* ************************************************************************
* SITE GROUPINGS
* Using ...?
**************************************************************************
count if icd10==""
