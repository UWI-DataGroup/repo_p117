** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          002_prep prev lists.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL & Kern ROCKE
    //  date first created      13-MAR-2024
    // 	date last modified      13-MAR-2024
    //  algorithm task          Flagging previously-checked duplicates from CanReg5 dataset in prep for comparison with newly-generated lists (see dofile '2c_dup cancer')
    //  status                  Completed
    //  objective               (1) To have a dataset with previously-checked duplicates to flag these and append the DA's comments to new duplicates list where applicable.
	//							(2) To have the SOP for this process written into the dofile.
    //  methods                 Importing previously-checked duplicates list
	//							This dofile is also saved in the path: L:/Sync/Cancer/CanReg5/DA Duplicates

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
  ** Set working directories: this is for DATASET and LOGFILE import and export
    ** DATASETS to encrypted SharePoint folder
    local datapath "/Volumes/Drive 2/BNR Consultancy/Sync/Sync/DM/Data/BNR-Cancer/data_p117_decrypted"
	
** HEADER -----------------------------------------------------

/* 
STEP #1
(1) Copy previously-checked duplicates list from L:/Sync/Cancer/CanReg5/DA Duplicates/yyyy/yyyy_Month
(2) Paste previously-checked duplicates list into `datapath'/version04/1-input
*/


** STEP #2
** Remove any previously-generated datasets from this dofile
/* 
	This prevents previously-checked lists, that didn't have a particular dataset generated in the last run, 
	to be appended to the newly-generated lists in dofiles 003a-003d
*/
capture erase "`datapath'/version15/2-working/prevNRN_dups.dta"
capture erase "`datapath'/version15/2-working/prevDOB_dups.dta"
capture erase "`datapath'/version15/2-working/prevHOSP_dups.dta"
capture erase "`datapath'/version15/2-working/prevNAMES_dups.dta"

** STEP #3
** LOAD, SAVE previously-checked duplicates list as separate datasets, labelling each sheet using a new variable to indicate which list they were on and that they were previously checked

** NRN list
capture import excel using "`datapath'/version15/1-input/CancerDuplicates20240313.xlsx" , sheet(NRN) firstrow case(lower)
capture replace nrnlist="1"
capture destring nrnlist ,replace
capture gen checked=1
capture drop previouslychecked
capture rename no str_no
capture rename reg registrynumber
//rename dob birthdate
capture rename hospital hospitalnumber
capture rename dxyear diagnosisyear
capture rename datotakeaction str_da
capture rename datedatookaction str_dadate
capture rename actiontaken str_action
//destring birthdate ,replace
capture order str_no registrynumber lastname firstname sex nrn birthdate hospitalnumber diagnosisyear str_da str_dadate str_action nrnlist checked
count //0
capture save "`datapath'/version15/2-working/prevNRN_dups" ,replace
clear

** DOB list
capture import excel using "`datapath'/version15/1-input/CancerDuplicates20240313.xlsx" , sheet(DOB) firstrow case(lower)
capture replace doblist="1"
capture destring doblist ,replace
capture gen checked=1
capture drop previouslychecked
capture rename no str_no
capture rename reg registrynumber
capture rename dob birthdate
capture rename hospital hospitalnumber
capture rename dxyear diagnosisyear
capture rename datotakeaction str_da
capture rename datedatookaction str_dadate
capture rename actiontaken str_action
capture order str_no registrynumber lastname firstname sex nrn birthdate hospitalnumber diagnosisyear str_da str_dadate str_action doblist checked
count //0
capture save "`datapath'/version15/2-working/prevDOB_dups" ,replace
clear

** Hosp# list
capture import excel using "`datapath'/version15/1-input/CancerDuplicates20240313.xlsx" , sheet(Hosp#) firstrow case(lower)
capture replace hosplist="1"
capture destring hosplist ,replace
capture gen checked=1
capture drop previouslychecked
capture rename no str_no
capture rename reg registrynumber
//rename dob birthdate
capture rename hospital hospitalnumber
capture rename dxyear diagnosisyear
capture rename datotakeaction str_da
capture rename datedatookaction str_dadate
capture rename actiontaken str_action
capture order str_no registrynumber lastname firstname sex nrn birthdate hospitalnumber diagnosisyear str_da str_dadate str_action hosplist checked
count //0
capture save "`datapath'/version15/2-working/prevHOSP_dups" ,replace
clear

** Names list
capture import excel using "`datapath'/version15/1-input/CancerDuplicates20240313.xlsx" , sheet(Names) firstrow case(lower)
capture replace nameslist="1"
capture destring nameslist ,replace
capture gen checked=1
capture drop previouslychecked
capture rename no str_no
capture rename reg registrynumber
//rename dob birthdate
capture rename hospital hospitalnumber
capture rename dxyear diagnosisyear
capture rename datotakeaction str_da
capture rename datedatookaction str_dadate
capture rename actiontaken str_action
//destring birthdate ,replace
capture order str_no registrynumber lastname firstname sex nrn birthdate hospitalnumber diagnosisyear str_da str_dadate str_action nameslist checked
count //66
capture save "`datapath'/version15/2-working/prevNAMES_dups" ,replace
//gen checked29jun21=1
//save "`datapath'/version15/2-working/29jun21NAMES_dups" ,replace
clear

/* 
	Each list will be kept as a separate dataset so comparisons with newly-generated lists would be between lists
	and not all the lists as one dataset, i.e. comparing previous NRN list with new NRN list, etc.
*/

** STEP #4
** Run the other dofiles associated with this process. NOTE: You will need to update the file names in this dofile and in dofile 2b
