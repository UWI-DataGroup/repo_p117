** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          50_death match.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      27-JUL-2021
    // 	date last modified      27-JUL-2021
    //  algorithm task          Matching cleaned, current cancer dataset with cleaned death 2015-2020 dataset
    //  status                  Completed
    //  objective               To have a cleaned and matched dataset with updated vital status
    //  methods                 Using same prep code from 15_clean cancer.do

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
