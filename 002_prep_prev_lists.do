** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          002_prep prev lists.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      03-MAY-2021
    // 	date last modified      10-MAY-2021
    //  algorithm task          Flagging previously-checked duplicates from CanReg5 dataset in prep for comparison with newly-generated lists (see dofile '2c_dup cancer')
    //  status                  Completed
    //  objective               (1) To have a dataset with previously-checked duplicates to flag these and append the DA's comments to new duplicates list where applicable.
	//							(2) To have the SOP for this process written into the dofile.
    //  methods                 Importing previously-checked duplicates list
	//							This dofile is also saved in the path: L:\Sync\Cancer\CanReg5\DA Duplicates

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
    log using "`logpath'\002_prep prev lists.smcl", replace
** HEADER -----------------------------------------------------

/* 
STEP #1
(1) Copy previously-checked duplicates list from L:\Sync\Cancer\CanReg5\DA Duplicates\yyyy\yyyy_Month
(2) Paste previously-checked duplicates list into `datapath'\version04\1-input
*/

** STEP #2
** LOAD, SAVE previously-checked duplicates list as separate datasets, labelling each sheet using a new variable to indicate which list they were on and that they were previously checked
** NRN list
import excel using "`datapath'\version04\1-input\20210311CancerDuplicates.xlsx" , sheet(NRN) firstrow case(lower)
gen nrnlist=1
gen checked=1
rename no str_no
rename reg registrynumber
rename dob birthdate
rename hospital hospitalnumber
rename dxyear diagnosisyear
rename datotakeaction str_da
rename datedatookaction str_dadate
rename actiontaken str_action
destring birthdate ,replace
order str_no registrynumber lastname firstname sex nrn birthdate hospitalnumber diagnosisyear str_da str_dadate str_action nrnlist checked
count //229
save "`datapath'\version04\2-working\prevNRN_dups" ,replace
clear
** DOB list
import excel using "`datapath'\version04\1-input\20210311CancerDuplicates.xlsx" , sheet(DOB) firstrow case(lower)
gen doblist=1
gen checked=1
rename no str_no
rename reg registrynumber
rename dob birthdate
rename hospital hospitalnumber
rename dxyear diagnosisyear
rename datotakeaction str_da
rename datedatookaction str_dadate
rename actiontaken str_action
order str_no registrynumber lastname firstname sex nrn birthdate hospitalnumber diagnosisyear str_da str_dadate str_action doblist checked
count //271
save "`datapath'\version04\2-working\prevDOB_dups" ,replace
clear
** Hosp# list
import excel using "`datapath'\version04\1-input\20210311CancerDuplicates.xlsx" , sheet(Hosp#) firstrow case(lower)
gen hosplist=1
gen checked=1
rename no str_no
rename reg registrynumber
rename dob birthdate
rename hospital hospitalnumber
rename dxyear diagnosisyear
rename datotakeaction str_da
rename datedatookaction str_dadate
rename actiontaken str_action
order str_no registrynumber lastname firstname sex nrn birthdate hospitalnumber diagnosisyear str_da str_dadate str_action hosplist checked
count //153
save "`datapath'\version04\2-working\prevHOSP_dups" ,replace
clear
** Names list
import excel using "`datapath'\version04\1-input\20210311CancerDuplicates.xlsx" , sheet(Names) firstrow case(lower)
gen nameslist=1
gen checked=1
rename no str_no
rename reg registrynumber
rename dob birthdate
rename hospital hospitalnumber
rename dxyear diagnosisyear
rename datotakeaction str_da
rename datedatookaction str_dadate
rename actiontaken str_action
destring birthdate ,replace
order str_no registrynumber lastname firstname sex nrn birthdate hospitalnumber diagnosisyear str_da str_dadate str_action nameslist checked
count //702
save "`datapath'\version04\2-working\prevNAMES_dups" ,replace
clear

/* 
	Each list will be kept as a separate dataset so comparisons with newly-generated lists would be between lists
	and not all the lists as one dataset, i.e. comparing previous NRN list with new NRN list, etc.
*/

** STEP #3
** Run the other dofiles associated with this process. NOTE: You will need to update the file names in this dofile and in dofile 2b