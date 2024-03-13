** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          004_export new lists.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL & Kern ROCKE
    //  date first created      13-MAR-2024
    // 	date last modified      13-MAR-2024
    //  algorithm task          Exporting newly-generated duplicates lists (see dofiles '003a, 003b, 003c, 003d...')
    //  status                  Completed
    //  objective               (1) To have one excel workbook with 5 tabs - ERRORS, NRN, DOB, HOSP#, NAMES.
	//							(2) To have the SOP for this process written into the dofile.
    //  methods                 Importing newly-generated datasets and exporting to excel
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
use "`datapath'/version15/3-output/NRN_dups.dta" , clear

count //0

** Use below example code to automate file names using current date
local listdate = string( d(`c(current_date)'), "%dCYND" )
capture export_excel str_no registrynumber lastname firstname sex nrn birthdate hospitalnumber diagnosisyear checked str_da str_dadate str_action nrnlist using "`datapath'/version15/3-output/CancerDuplicates`listdate'.xlsx", sheet("NRN") firstrow(varlabels)
restore



******************
******************
**		DOB		**
******************
******************
** STEP #3
** LOAD newly-generated dataset from dofile 003b_compare lists_DOB
preserve
use "`datapath'/version15/3-output/DOB_dups.dta" , clear

count //2

** Use below example code to automate file names using current date
local listdate = string( d(`c(current_date)'), "%dCYND" )
capture export_excel str_no registrynumber lastname firstname sex nrn birthdate hospitalnumber diagnosisyear checked str_da str_dadate str_action doblist using "`datapath'/version15/3-output/CancerDuplicates`listdate'.xlsx", sheet("DOB") firstrow(varlabels)
restore



******************
******************
**	   HOSP#	**
******************
******************
** STEP #4
** LOAD newly-generated dataset from dofile 003c_compare lists_HOSP
preserve
use "`datapath'/version15/3-output/HOSP_dups.dta" , clear

count //2

** Use below example code to automate file names using current date
local listdate = string( d(`c(current_date)'), "%dCYND" )
capture export_excel str_no registrynumber lastname firstname sex nrn birthdate hospitalnumber diagnosisyear checked str_da str_dadate str_action hosplist using "`datapath'/version15/3-output/CancerDuplicates`listdate'.xlsx", sheet("Hosp#") firstrow(varlabels)
restore



******************
******************
**	   NAMES	**
******************
******************
** STEP #5
** LOAD newly-generated dataset from dofile 003d_compare lists_NAMES
preserve
use "`datapath'/version15/3-output/NAMES_dups.dta" , clear

count //47

** Use below example code to automate file names using current date
local listdate = string( d(`c(current_date)'), "%dCYND" )
capture export_excel str_no registrynumber lastname firstname sex nrn birthdate hospitalnumber diagnosisyear checked str_da str_dadate str_action nameslist using "`datapath'/version15/3-output/CancerDuplicates`listdate'.xlsx", sheet("Names") firstrow(varlabels)
restore
