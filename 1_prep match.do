** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          1_prep match.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      02-MAR-2021
    // 	date last modified      02-MAR-2021
    //  algorithm task          Matching uncleaned 2018 cancer dataset with REDCap's 2018 deaths
    //  status                  Completed
    //  objective               To have a complete list of DCOs for the cancer team to use in trace-back in prep for 2018 cancer report.
    //  methods                 Merging CR5 2018 dataset with the prepared 2018 death dataset from 10_prep mort.do

    ** General algorithm set-up
    version 16.0
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
    log using "`logpath'\1_prep match.smcl", replace
** HEADER -----------------------------------------------------