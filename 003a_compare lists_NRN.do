** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          003a_compare lists_NRN.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      12-JAN-2022
    // 	date last modified      01-MAR-2022
    //  algorithm task          Identifying duplicates and comparing with previously-checked duplicates (see dofile '002_prep prev lists')
    //  status                  Completed
    //  objective               (1) To have a dataset with newly-generated duplicates, comparing these with previously-checked duplicates and
	//								flagging repeated records on these newly-generated lists to differentiate previously-checked from newly-generated and
	//								appending the DA's comments to new duplicates list where applicable.
	//							(2) To have the SOP for this process written into the dofile.
    //  methods                 Importing current CR5db dataset, identifying duplicates and using quietly sort to compare with previously-checked duplicates list
	//							This dofile is also saved in the path: L:\Sync\Cancer\CanReg5\DA Duplicates

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
    log using "`logpath'\003a_compare lists_NRN.smcl", replace
** HEADER -----------------------------------------------------

/* 
	STEP #1
	When running a new duplicates list, please note below:
        (1) The preceeding dofiles need to be run, i.e. 001_flag errors and 002_prep prev lists.
	    (2) Records with blank/missing values for the variable being checked need to be removed 
		    as these will be flagged as duplicates of each other so the Preserve/Restore combo is used 
            when creating the duplicate lists so the next duplicate check can be done on the full dataset.
*/

******************
******************
**		NRN		**
******************
******************

** STEP #2
** LOAD corrected dataset from dofile 001_flag errors for each list
use "`datapath'\version07\2-working\corrected_cancer_dups.dta" , clear

count //10,400


** STEP #3
** Identify possible duplicates using NRN 
drop if nrn==""|nrn=="999999-9999"|regexm(nrn,"9999") //remove blank/missing NRNs as these will be flagged as duplicates of each other
//1,883 deleted
sort nrn 
quietly by nrn : gen dup = cond(_N==1,0,_n)
sort nrn registrynumber lastname firstname
count if dup>0 //0


** STEP #4 
/* 
	Create same additional variables as found in previously-checked NRN list but the variable 'checked' should = No (code 2)
	as this allows us to differentiate between the 2 NRN datasets
 */
gen nrnlist=1
gen checked=2


** STEP #5
drop if dup==0 //remove all the NRN non-duplicates - 8,115 deleted
count //0

** STEP #6
/* 
	(1) Format DOB and 'Date DA Took Action' to match the previously-checked DOB dataset
	(2)	Add previously-checked DOB dataset to this newly-generated DOB dataset
*/
//destring birthdate ,replace
capture append using "`datapath'\version07\2-working\prevNRN_dups" ,force
format str_dadate %tdnn/dd/CCYY
count //0


** STEP #7
** Compare these newly-generated duplicates with the previously-checked NRN list by checking for duplicates PIDs/Reg #s
sort registrynumber
capture quietly by registrynumber:  gen duppid = cond(_N==1,0,_n)
capture count if duppid>0 //0


** STEP #8
** Remove previously-checked records
capture drop if checked==1 & duppid==0 //4 deleted
//drop if duppid!=0 //4 deleted the cases pulled in from the last list

** STEP #9
** Prepare this dataset for export to excel
capture drop sourcerecordid surgicalfindings surgicalfindingsdate imagingresults imagingresultsdate physicalexam physicalexamdate ///
     cr5id middleinitials mptot tumourid duplicatecheck dup duppid flag*

label var checked "Previously Checked?"
label define checked_lab 1 "Yes" 2 "No",modify
label values checked checked_lab
label var nrnlist "NRN List?"
label define nrnlist_lab 1 "Yes" 2 "No",modify
label values nrnlist nrnlist_lab

sort nrn

drop str_no
gen str_no= _n
label var str_no "No."

capture order str_no registrynumber lastname firstname sex nrn birthdate hospitalnumber diagnosisyear checked str_da str_dadate str_action nrnlist


** STEP #10
** Save this dataset for export to excel (see dofile 004_export new lists)
save "`datapath'\version07\3-output\NRN_dups" ,replace

