** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          003d_compare lists_NAMES.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL and Kern ROCKE
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
**	  NAMES		**
******************
******************

** STEP #2
** LOAD corrected dataset from dofile 001_flag errors for each list
use "`datapath'/version15/2-working/corrected_cancer_dups.dta" , clear

count //10,300


** STEP #3
** Identify possible duplicates using NAMES 
drop if lastname==""
sort lastname firstname
quietly by lastname firstname:  gen dup = cond(_N==1,0,_n)
sort lastname firstname registrynumber
count if dup>0 //561


** STEP #4 
/* 
	Create same additional variables as found in previously-checked NRN list but the variable 'checked' should = No (code 2)
	as this allows us to differentiate between the 2 NRN datasets
 */
gen nameslist=1
gen checked=2


** STEP #5
drop if dup==0 //remove all the Names non-duplicates - 9,187 deleted
count //561

** STEP #6
/* 
	(1) Format DOB and 'Date DA Took Action' to match the previously-checked DOB dataset
	(2)	Add previously-checked DOB dataset to this newly-generated DOB dataset
*/
//destring birthdate ,replace
capture append using "`datapath'/version15/2-working/prevNAMES_dups" ,force
format str_dadate %tdnn/dd/CCYY
count //327
/*
** ADD IN EXTRA STEP TO CREATE A STATIC NAMES TAB DATASET FROM THIS 20210629 LIST FOR FUTURE MATCHING IN ADDITION TO THE USUAL PREVIOUS LIST DATASET
capture append using "`datapath'/version15/2-working/29jun21NAMES_dups" ,force
format str_dadate %tdnn/dd/CCYY
count //1,015
*/


** STEP #7
** Compare these newly-generated duplicates with the previously-checked NRN list by checking for duplicates PIDs/Reg #s
sort registrynumber
quietly by registrynumber:  gen duppid = cond(_N==1,0,_n)
count if duppid>0 //120
order registrynumber lastname firstname str_no str_da str_dadate str_action duppid checked
//list registrynumber lastname firstname str_no str_da str_dadate str_action duppid checked if duppid>0 , string(50)

sort lastname firstname registrynumber
quietly by lastname firstname registrynumber:  gen dupnmpid = cond(_N==1,0,_n)
count if dupnmpid>0 //120
order registrynumber lastname firstname checked dupnmpid str_no str_da str_dadate str_action

count if checked==2 & dupnmpid>0 //60 - so all 60 don't have a corresponding pid that's from previously-checked list so no new dups found in this list
count if checked==1 & duppid==0 //6 - check these in Stata Browse/Edit window: previously-checked and merged cases


** STEP #8
/* 
	(1) Manually review list above for duppid>0
	(2) Remove previously-checked records according to review
*/
drop if checked==1 & duppid==0 //3 deleted
drop if duppid>0 //120 deleted
//drop if checked==2 & dupnmpid>0 //0 deleted
//drop if duppid==0 //446 deleted
//all observations deleted as no new duplicates for this list
count //501


** ADD IN EXTRA STEP TO CREATE A STATIC NAMES TAB DATASET FROM THIS 20210629 LIST FOR FUTURE MATCHING IN ADDITION TO THE USUAL PREVIOUS LIST DATASET
capture append using "`datapath'/version15/2-working/29jun21NAMES_dups" ,force
format str_dadate %tdnn/dd/CCYY
count //981

drop dupnmpid
sort lastname firstname registrynumber
quietly by lastname firstname registrynumber:  gen dupnmpid = cond(_N==1,0,_n)
count if dupnmpid>0 //908
order registrynumber lastname firstname checked dupnmpid str_no str_da str_dadate str_action

count if checked==2 & dupnmpid>0 //454 - so all 29 have a corresponding pid that's from previously-checked list so can no new dups found in this list
count if checked==1 & duppid==0 //0 - check these in Stata Browse/Edit window: previously-checked and merged cases
count if dupnmpid>0 //908 - check these in Stata Browse/Edit window: previously-checked and merged cases + new duplicate cases for those with 2 records; those with 4 records are previously-checked ones
count if dupnmpid==0 //73 - check these in Stata Browse/Edit window: previously-checked and merged cases + new duplicate cases for those with 2 records

/*

drop if dupnmpid>0 & registrynumber!= & registrynumber!= & registrynumber!= & registrynumber!= ///
				   & registrynumber!= & registrynumber!= & registrynumber!= & registrynumber!= ///
				   & registrynumber!= & registrynumber!= & registrynumber!= & registrynumber!= ///
				   & registrynumber!= & registrynumber!= & registrynumber!= & registrynumber!= ///
				   & registrynumber!= & registrynumber!= & registrynumber!= & registrynumber!= ///
				   & registrynumber!= & registrynumber!= & registrynumber!= & registrynumber!= ///
				   & registrynumber!= & registrynumber!= & registrynumber!= & registrynumber!= ///
				   & registrynumber!= & registrynumber!= & registrynumber!= & registrynumber!= ///
				   & registrynumber!= & registrynumber!= & registrynumber!= & registrynumber!= ///
				   & registrynumber!= & registrynumber!= & registrynumber!= & registrynumber!= ///
				   & registrynumber!= & registrynumber!= & registrynumber!= & registrynumber!= ///
				   & registrynumber!= & registrynumber!= & registrynumber!= & registrynumber!= ///
				   & registrynumber!= & registrynumber!= & registrynumber!= & registrynumber!= ///
				   & registrynumber!= & registrynumber!= & registrynumber!= & registrynumber!= ///
				   & registrynumber!= & registrynumber!= & registrynumber!= & registrynumber!= ///
				   & registrynumber!= & registrynumber!= & registrynumber!= & registrynumber!=
*/
drop if dupnmpid>0 & registrynumber!=20200361 & registrynumber!=20200749 & registrynumber!=20100003 & registrynumber!=20190765 ///
				   & registrynumber!=20170904 & registrynumber!=20200595 & registrynumber!=20190536 & registrynumber!=20200604 ///
				   & registrynumber!=20160282 & registrynumber!=20200164 & registrynumber!=20080324 & registrynumber!=20190751 ///
				   & registrynumber!=20190426 & registrynumber!=20200768 & registrynumber!=20191263 & registrynumber!=20200766 ///
				   & registrynumber!=20140998 & registrynumber!=20200750 & registrynumber!=20200131 & registrynumber!=20200747 ///
				   & registrynumber!=20200057 & registrynumber!=20200745 & registrynumber!=20141310 & registrynumber!=20190747 ///
				   & registrynumber!=20080362 & registrynumber!=20200734 & registrynumber!=20190500 & registrynumber!=20200471 ///
				   & registrynumber!=20200503 & registrynumber!=20080125 & registrynumber!=20150575 & registrynumber!=20130868 ///
				   & registrynumber!=20170404 & registrynumber!=20150364 & registrynumber!=20200607 & registrynumber!=20141295 ///
				   & registrynumber!=20170405 & registrynumber!=20182316 & registrynumber!=20200694 & registrynumber!=20170021 ///
				   & registrynumber!=20200609 & registrynumber!=20170406 & registrynumber!=20180855 & registrynumber!=20160758 ///
				   & registrynumber!=20200484 & registrynumber!=20170407 & registrynumber!=20191035
//908 deleted
drop if dupnmpid==0 & registrynumber!=20200361 & registrynumber!=20200749 & registrynumber!=20100003 & registrynumber!=20190765 ///
				   & registrynumber!=20170904 & registrynumber!=20200595 & registrynumber!=20190536 & registrynumber!=20200604 ///
				   & registrynumber!=20160282 & registrynumber!=20200164 & registrynumber!=20080324 & registrynumber!=20190751 ///
				   & registrynumber!=20190426 & registrynumber!=20200768 & registrynumber!=20191263 & registrynumber!=20200766 ///
				   & registrynumber!=20140998 & registrynumber!=20200750 & registrynumber!=20200131 & registrynumber!=20200747 ///
				   & registrynumber!=20200057 & registrynumber!=20200745 & registrynumber!=20141310 & registrynumber!=20190747 ///
				   & registrynumber!=20080362 & registrynumber!=20200734 & registrynumber!=20190500 & registrynumber!=20200471 ///
				   & registrynumber!=20200503 & registrynumber!=20080125 & registrynumber!=20150575 & registrynumber!=20130868 ///
				   & registrynumber!=20170404 & registrynumber!=20150364 & registrynumber!=20200607 & registrynumber!=20141295 ///
				   & registrynumber!=20170405 & registrynumber!=20182316 & registrynumber!=20200694 & registrynumber!=20170021 ///
				   & registrynumber!=20200609 & registrynumber!=20170406 & registrynumber!=20180855 & registrynumber!=20160758 ///
				   & registrynumber!=20200484 & registrynumber!=20170407 & registrynumber!=20191035
//26 deleted
count //47

** STEP #9
** Prepare this dataset for export to excel
drop sourcerecordid surgicalfindings surgicalfindingsdate imagingresults imagingresultsdate physicalexam physicalexamdate ///
     cr5id middleinitials mptot tumourid duplicatecheck dup duppid flag*

label var checked "Previously Checked?"
label define checked_lab 1 "Yes" 2 "No",modify
label values checked checked_lab
label var nameslist "Names List?"
label define nameslist_lab 1 "Yes" 2 "No",modify
label values nameslist nameslist_lab

sort lastname firstname

drop str_no
gen str_no= _n
label var str_no "No."

order str_no registrynumber lastname firstname sex nrn birthdate hospitalnumber diagnosisyear checked str_da str_dadate str_action nameslist


** STEP #10
** Save this dataset for export to excel (see dofile 004_export new lists)
save "`datapath'/version15/3-output/NAMES_dups" ,replace
