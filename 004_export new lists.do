** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          004_export new lists.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      29-JUN-2021
    // 	date last modified      29-JUN-2021
    //  algorithm task          Exporting newly-generated duplicates lists (see dofiles '003a, 003b, 003c, 003d...')
    //  status                  Completed
    //  objective               (1) To have one excel workbook with 5 tabs - ERRORS, NRN, DOB, HOSP#, NAMES.
	//							(2) To have the SOP for this process written into the dofile.
    //  methods                 Importing newly-generated datasets and exporting to excel
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
    log using "`logpath'\004_export new lists.smcl", replace
** HEADER -----------------------------------------------------

/* 
	STEP #1
	When running a new duplicates list, please note below:
        The preceeding dofiles need to be run, i.e. 001_flag errors, 002_prep prev lists, 003_compare lists (a, b, d, d).
*/

******************
******************
**		NRN		**
******************
******************
** STEP #2
** LOAD newly-generated dataset from dofile 003a_compare lists_NRN
preserve
use "`datapath'\version07\3-output\NRN_dups.dta" , clear

count //16

** Use below example code to automate file names using current date
local listdate = string( d(`c(current_date)'), "%dCYND" )
capture export_excel str_no registrynumber lastname firstname sex nrn birthdate hospitalnumber diagnosisyear checked str_da str_dadate str_action nrnlist using "`datapath'\version07\3-output\CancerDuplicates`listdate'.xlsx", sheet("NRN") firstrow(varlabels)
restore



******************
******************
**		DOB		**
******************
******************
** STEP #3
** LOAD newly-generated dataset from dofile 003b_compare lists_DOB
preserve
use "`datapath'\version07\3-output\DOB_dups.dta" , clear

count //6

** Use below example code to automate file names using current date
local listdate = string( d(`c(current_date)'), "%dCYND" )
capture export_excel str_no registrynumber lastname firstname sex nrn birthdate hospitalnumber diagnosisyear checked str_da str_dadate str_action doblist using "`datapath'\version07\3-output\CancerDuplicates`listdate'.xlsx", sheet("DOB") firstrow(varlabels)
restore



******************
******************
**	   HOSP#	**
******************
******************
** STEP #4
** LOAD newly-generated dataset from dofile 003c_compare lists_HOSP
preserve
use "`datapath'\version07\3-output\HOSP_dups.dta" , clear

count //6

** Use below example code to automate file names using current date
local listdate = string( d(`c(current_date)'), "%dCYND" )
capture export_excel str_no registrynumber lastname firstname sex nrn birthdate hospitalnumber diagnosisyear checked str_da str_dadate str_action hosplist using "`datapath'\version07\3-output\CancerDuplicates`listdate'.xlsx", sheet("Hosp#") firstrow(varlabels)
restore



******************
******************
**	   NAMES	**
******************
******************
** STEP #5
** LOAD newly-generated dataset from dofile 003d_compare lists_NAMES
preserve
use "`datapath'\version07\3-output\NAMES_dups.dta" , clear

count //480

** Use below example code to automate file names using current date
local listdate = string( d(`c(current_date)'), "%dCYND" )
capture export_excel str_no registrynumber lastname firstname sex nrn birthdate hospitalnumber diagnosisyear checked str_da str_dadate str_action nameslist using "`datapath'\version07\3-output\CancerDuplicates`listdate'.xlsx", sheet("Names") firstrow(varlabels)
restore
