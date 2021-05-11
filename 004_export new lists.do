** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          2c_dup cancer.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      05-MAY-2021
    // 	date last modified      05-MAY-2021
    //  algorithm task          Identifying duplicates and comparing with previously-checked duplicates (see dofile '2a_dup cancer')
    //  status                  Completed
    //  objective               (1) To have a dataset with newly-generated duplicates, comparing these with previously-checked duplicates and
	//								flagging repeated records on these newly-generated lists to differentiate previously-checked from newly-generated and
	//								appending the DA's comments to new duplicates list where applicable.
	//							(2) To have the SOP for this process written into the dofile.
    //  methods                 Importing current CR5db dataset, identifying duplicates and using frames to compare with previously-checked duplicates list
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
    log using "`logpath'\2c_dup cancer.smcl", replace
** HEADER -----------------------------------------------------

/* 
	STEP #1
	When running a new duplicates list, please note the below:
	(1) Duplicates list should be run on all data in CR5db, not by individual years.
	(2) Update the CR5db export file name in this dofile.
	(3) Update the excel file names under each duplicate check in this dofile.
	(4) Update any 'replace' code if running this dofile after KWG has updated previously-identified incorrect data.
	(5) Records with blank/missing values for the variable being checked need to be removed 
		as these will be flagged as duplicates of each other so the Preserve/Resore combo is used when creating the duplicate lists 
		so the next duplicate check can be done on the full dataset: see STEP #8 below.
*/

** STEP #3
** LOAD and SAVE the SOURCE+TUMOUR+PATIENT dataset from above (Source_+Tumour+Patient tables)
insheet using "`datapath'\version04\1-input\2021-05-04_MAIN Source+Tumour+Patient_JC.txt"

** Use below example code to automate file names using current date
local listdate = string( d(`c(current_date)'), "%dCYND" )
capture export_excel str_no registrynumber flag1 flag5 flag2 flag6 flag3 flag7 flag4 flag8 str_da str_dadate str_action if flag1!=.|flag2!=.|flag3!=.|flag4!=. using "`datapath'\version04\3-output\CancerDuplicates`listdate'.xlsx", sheet("ERRORS") firstrow(varlabels)


** STEP #9
** Email KWG re any errors found so he can update main CR5db
** Check for matches using natregno
preserve
drop if nrn==""|nrn=="999999-9999"|regexm(nrn,"9999") //remove blank/missing NRNs as these will be flagged as duplicates of each other
sort nrn 
quietly by nrn : gen dup = cond(_N==1,0,_n)
sort nrn registrynumber lastname firstname
count if dup>0 //229
capture export_excel str_no registrynumber lastname firstname sex nrn birthdate hospitalnumber diagnosisyear str_da str_dadate str_action if dup>0 using "`datapath'\version04\3-output\20210426CancerDuplicates.xlsx", sheet("NRN") firstrow(varlabels)
drop dup
restore


** STEP #10
** Create var to identify DOBs with unknown month day and then to drop any that=99
** DOB duplicate check
** Since there are errors in DOB field, need to correct before proceeding - checked against electoral list
** Email KWG re any errors found so he can update main CR5db
count if length(birthdate)<8|length(birthdate)>8 //22
replace birthdate=subinstr(birthdate,"8","18",.) if registrynumber==20160465 & birthdate!=""
replace birthdate="" if length(birthdate)<8 //10 changes
count if birthdate=="99999999" //617
replace birthdate="" if birthdate=="99999999" //619 changes
replace birthdate = lower(rtrim(ltrim(itrim(birthdate)))) //0 changes
count if birthdate!="" & (length(birthdate)<8|length(birthdate)>8) //0
count if regexm(birthdate, "99") & !(strmatch(strupper(birthdate), "*19*")) //722
gen birthd=substr(birthdate,-2,2)
replace birthdate="" if birthd=="99" //669 changes
drop birthd
count if regexm(birthdate,"-") //1
replace birthdate=subinstr(birthdate,"3","193",.) if registrynumber==20201091 & birthdate!=""
replace birthdate=subinstr(birthdate,"-0","",.) if registrynumber==20201091 & birthdate!=""

gen str_dob=birthdate
destring birthdate ,replace

** STEP #11
/* 
Flagging duplicates based on DOB poses a few challenges, e.g. 
(1) different patients can have same DOB resulting in an unnecessarily large list so need to add in code to identify 'true' duplicates; 
(2) same patient can have different spelling of their names so when flagging DOB duplicates using name + DOB then duplicates can be missed;
(3) different patients with same name but different DOB

26apr2021 - Based on JC's comparisons of the different outputs for 3 methods below, METHOD #1 is best option for flagging DOB duplicates.
*/
preserve
** Remove blank/missing DOBs
gen dobyear = substr(str_dob,1,4)
gen dobmonth = substr(str_dob,5,2)
gen dobday = substr(str_dob,7,2)
drop if dobyear=="9999" | dobmonth=="99" | dobday=="99"
drop dobday dobmonth dobyear
drop if birthdate==. | birthdate==99999999


** Look for duplicates - METHOD #1
sort lastname firstname str_dob
quietly by lastname firstname str_dob : gen dup = cond(_N==1,0,_n)
sort lastname firstname str_dob registrynumber
count if dup>0 //155 - true DOB duplicates
count if dup==0 //7665
drop if dup==0 //7665 deleted

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
capture export_excel str_no registrynumber lastname firstname birthdate sex hospitalnumber diagnosisyear str_da str_dadate str_action if dup>0 using "`datapath'\version04\3-output\20210426CancerDuplicates.xlsx", sheet("DOB") firstrow(varlabels)
drop dup
restore


** STEP #12
** Hospital Number duplicate check
preserve
drop if hospitalnumber=="" | hospitalnumber=="99"
sort hospitalnumber lastname firstname
quietly by hospitalnumber :  gen dup = cond(_N==1,0,_n)
sort hospitalnumber
count if dup>0 //153
capture export_excel str_no registrynumber lastname firstname birthdate sex hospitalnumber diagnosisyear str_da str_dadate str_action if dup>0 using "`datapath'\version04\3-output\20210426CancerDuplicates.xlsx", sheet("Hosp#") firstrow(varlabels)
drop dup
restore


** STEP #13
** Patient Names duplicate check
/*
Names tab should be the last to be reviewed as often there are misspellings and name swaps in the data;
The other tabs are more definitive and reliable so the Names tab is used for "sweeping up" those duplicates that do not have DOB, NRN, Hosp#.
*/
preserve
drop if lastname==""
sort lastname firstname
quietly by lastname firstname:  gen dup = cond(_N==1,0,_n)
sort lastname firstname registrynumber
count if dup>0 //702
capture export_excel str_no registrynumber lastname firstname sex birthdate hospitalnumber diagnosisyear str_da str_dadate str_action if dup>0 using "`datapath'\version04\3-output\20210426CancerDuplicates.xlsx", sheet("Names") firstrow(varlabels)
drop dup 
restore


** STEP #14
** Save this dataset
save "`datapath'\version04\3-output\2008-2020_duplicates_cancer.dta" ,replace
label data "BNR-Cancer Duplicates"
notes _dta :These data prepared for SDA to use in prep for 2018 annual report
