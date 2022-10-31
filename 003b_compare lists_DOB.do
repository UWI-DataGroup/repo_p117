** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          003b_compare lists_DOB.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      31-OCT-2022
    // 	date last modified      31-OCT-2022
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
    log using "`logpath'\003_compare lists_DOB.smcl", replace
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
**		DOB		**
******************
******************

** STEP #2
** LOAD corrected dataset from dofile 001_flag errors for each list
use "`datapath'\version07\2-working\corrected_cancer_dups.dta" , clear

count //11,287


** STEP #3
/* 
	Create variables to identify DOBs with unknown day, month, year and then to drop any that = 99/9999, respectively, 
	as need to remove blank/missing DOBs as these will be flagged as duplicates of each other
*/
count if birthdate=="99999999" //695
replace birthdate="" if birthdate=="99999999" //695 changes
replace birthdate = lower(rtrim(ltrim(itrim(birthdate)))) //0 changes
gen dobyear = substr(birthdate,1,4)
gen dobmonth = substr(birthdate,5,2)
gen dobday = substr(birthdate,7,2)
drop if dobyear=="9999" | dobmonth=="99" | dobday=="99" //332 deleted
drop dobday dobmonth dobyear
drop if birthdate=="" | birthdate=="99999999" //695 deleted


** STEP #4
** Identify possible duplicates using NRN 
/* 
Flagging duplicates based on DOB poses a few challenges, e.g. 
(1) different patients can have same DOB resulting in an unnecessarily large list so need to add in code to identify 'true' duplicates; 
(2) same patient can have different spelling of their names so when flagging DOB duplicates using name + DOB then duplicates can be missed;
(3) different patients with same name but different DOB

JC 26apr2021 - Based on JC's comparisons of the different outputs for 3 methods below, METHOD #1 is best option for flagging DOB duplicates.
JC 10may2021 - Note: if using METHOD #3 at any point in the future then birthdate needs to be a non-string variable using this previous code:

count if birthdate!="" & (length(birthdate)<8|length(birthdate)>8) //0
count if regexm(birthdate, "99") & !(strmatch(strupper(birthdate), "*19*")) //722
gen birthd=substr(birthdate,-2,2)
replace birthdate="" if birthd=="99" //592 changes
drop birthd

gen str_dob=birthdate
destring birthdate ,replace

gen dobyear = substr(str_dob,1,4)
gen dobmonth = substr(str_dob,5,2)
gen dobday = substr(str_dob,7,2)
drop if dobyear=="9999" | dobmonth=="99" | dobday=="99"
drop dobday dobmonth dobyear
drop if birthdate==. | birthdate==99999999
*/


** Look for duplicates - METHOD #1
sort lastname firstname birthdate
quietly by lastname firstname birthdate : gen dup = cond(_N==1,0,_n)
sort lastname firstname birthdate registrynumber
count if dup>0 //14 - true DOB duplicates

/*
** Look for duplicates - METHOD #2
sort lastname firstname
quietly by lastname firstname:  gen dupname = cond(_N==1,0,_n)
drop if dupname==0 //7333 deleted
** now continue with flagging DOB duplicates
sort birthdate lastname firstname
quietly by birthdate:  gen dup = cond(_N==1,0,_n)
sort birthdate
count if dup>0 //164

** Look for duplicates - METHOD #3
sort birthdate lastname firstname
quietly by birthdate:  gen dup = cond(_N==1,0,_n)
sort lastname firstname
quietly by lastname firstname:  gen dupname = cond(_N==1,0,_n)
drop if dupname==0
sort birthdate
count if dup>0 //271
*/


** STEP #5 
/* 
	Create same additional variables as found in previously-checked DOB list but the variable 'checked' should = No (code 2)
	as this allows us to differentiate between the 2 DOB datasets
 */
gen doblist=1
gen checked=2


** STEP #6
count if dup==0 //9,282
drop if dup==0 //remove all the DOB non-duplicates - 8700 deleted
count //14

** STEP #7
/* 
	(1) Format DOB and 'Date DA Took Action' to match the previously-checked DOB dataset
	(2)	Add previously-checked DOB dataset to this newly-generated DOB dataset
*/
//destring birthdate ,replace
capture append using "`datapath'\version07\2-working\prevDOB_dups" ,force
format str_dadate %tdnn/dd/CCYY
count //16

** STEP #8
** Compare these newly-generated duplicates with the previously-checked NRN list by checking for duplicates PIDs/Reg #s
//drop if registrynumber==20201053 //2 deleted - this was already merged with 20151033 but it's still coming into exported file and can't open record in CR5db to delete it
sort registrynumber
quietly by registrynumber:  gen duppid = cond(_N==1,0,_n)
count if duppid>0 //0


** STEP #9
** Remove previously-checked records
drop if checked==1 & duppid==0 //2 deleted
drop if duppid>0 //0 deleted
//drop if registrynumber==20151033 //2 deleted - these were matched to each other and came from the previously-checked list

** STEP #10
** Prepare this dataset for export to excel
drop sourcerecordid surgicalfindings surgicalfindingsdate imagingresults imagingresultsdate physicalexam physicalexamdate ///
     cr5id middleinitials mptot tumourid duplicatecheck dup flag* //duppid

label var checked "Previously Checked?"
label define checked_lab 1 "Yes" 2 "No",modify
label values checked checked_lab
label var doblist "DOB List?"
label define doblist_lab 1 "Yes" 2 "No",modify
label values doblist doblist_lab

sort birthdate

drop str_no
gen str_no= _n
label var str_no "No."
label var birthdate DOB

order str_no registrynumber lastname firstname sex nrn birthdate hospitalnumber diagnosisyear checked str_da str_dadate str_action doblist

count //14

** STEP #11
** Save this dataset for export to excel (see dofile 004_export new lists)
save "`datapath'\version07\3-output\DOB_dups" ,replace

