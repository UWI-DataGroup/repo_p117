cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          003c_compare lists_Hosp#.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL & Kern ROCKE
    //  date first created      13-MAR-2024
    // 	date last modified      13-MAR-2024
    //  algorithm task          Identifying duplicates and comparing with previously-checked duplicates (see dofile '002_prep prev lists')
    //  status                  Completed
    //  objective               (1) To have a dataset with newly-generated duplicates, comparing these with previously-checked duplicates and
	//								flagging repeated records on these newly-generated lists to differentiate previously-checked from newly-generated and
	//								appending the DA's comments to new duplicates list where applicable.
	//							(2) To have the SOP for this process written into the dofile.
    //  methods                 Importing current CR5db dataset, identifying duplicates and using quietly sort to compare with previously-checked duplicates list
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
        (1) The preceeding dofiles need to be run, i.e. 001_flag errors and 002_prep prev lists.
	    (2) Records with blank/missing values for the variable being checked need to be removed 
		    as these will be flagged as duplicates of each other so the Preserve/Restore combo is used 
            when creating the duplicate lists so the next duplicate check can be done on the full dataset.
*/

******************
******************
**	  Hosp#		**
******************
******************

** STEP #2
** LOAD corrected dataset from dofile 001_flag errors for each list
use "`datapath'/version15/2-working/corrected_cancer_dups.dta" , clear

count //10,300


** STEP #3
** Identify possible duplicates using Hosp#
drop if hospitalnumber=="" | hospitalnumber=="99" //remove blank/missing Hosp #s as these will be flagged as duplicates of each other
//4273 deleted
sort hospitalnumber lastname firstname
quietly by hospitalnumber :  gen dup = cond(_N==1,0,_n)
sort hospitalnumber
count if dup>0 //2


** STEP #4 
/* 
	Create same additional variables as found in previously-checked NRN list but the variable 'checked' should = No (code 2)
	as this allows us to differentiate between the 2 NRN datasets
 */
gen hosplist=1
gen checked=2


** STEP #5
drop if dup==0 //remove all the Hosp# non-duplicates - 5,288 deleted
count //2


** STEP #6
/* 
	(1) Format DOB and 'Date DA Took Action' to match the previously-checked DOB dataset
	(2)	Add previously-checked DOB dataset to this newly-generated DOB dataset
*/
//destring birthdate ,replace
capture append using "`datapath'/version15/2-working/prevHOSP_dups" ,force
format str_dadate %tdnn/dd/CCYY
count //2


** STEP #7
** Compare these newly-generated duplicates with the previously-checked NRN list by checking for duplicates PIDs/Reg #s
//drop if registrynumber==20141171 //2 deleted - this was already merged with 20130865but it's still coming into exported file and can't open record in CR5db to delete it
sort registrynumber
quietly by registrynumber:  gen duppid = cond(_N==1,0,_n)
count if duppid>0 //0
sort hospitalnumber lastname firstname
//list registrynumber lastname firstname hospitalnumber str_no str_da str_dadate str_action dup checked if duppid>0 , string(50)


** STEP #8
/* 
	(1) Manually review list above for duppid>0
	(2) Remove previously-checked records according to review
*/
//drop if registrynumber!=20130865 & registrynumber!=20141171
** Remove previously-checked records
drop if checked==1 & duppid==0 //0 deleted
//drop if checked==1 //6 deleted these are from 21oct2021 list as CR5db wasn't updated properly from the list before that one
//drop if registrynumber==20130865 //2 deleted - these were matched to each other and came from the previously-checked list
//drop if registrynumber==20161021|registrynumber==20150164 //2 deleted - these were matched to each other and came from the previously-checked list

** STEP #9
** Prepare this dataset for export to excel
drop sourcerecordid surgicalfindings surgicalfindingsdate imagingresults imagingresultsdate physicalexam physicalexamdate ///
     cr5id middleinitials mptot tumourid duplicatecheck dup duppid flag*

label var checked "Previously Checked?"
label define checked_lab 1 "Yes" 2 "No",modify
label values checked checked_lab
label var hosplist "Hosp# List?"
label define hosplist_lab 1 "Yes" 2 "No",modify
label values hosplist hosplist_lab

sort hospitalnumber lastname firstname

drop str_no
gen str_no= _n
label var str_no "No."

order str_no registrynumber lastname firstname sex nrn birthdate hospitalnumber diagnosisyear checked str_da str_dadate str_action hosplist


** STEP #10
** Save this dataset for export to excel (see dofile 004_export new lists)
save "`datapath'/version15/3-output/HOSP_dups" ,replace
