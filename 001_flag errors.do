** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          001_flag errors.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      07-JULY-2022
    // 	date last modified      07-JULY-2022
    //  algorithm task          Formatting the CanReg5 dataset, identifying, flagging and correcting errors (see dofile '2c_dup cancer')
    //  status                  Completed
    //  objective               (1) To have list of any errors identified during this process so DAs can correct in CR5db.
	//							(2) To have a corrected dataset for generating new duplicates lists (see dofiles '2b_dup cancer' + '2c_dup cancer')
	//							(3)	To have the SOP for this process written into the dofile.
    //  methods                 Importing current CR5db dataset and flagging errors.
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
    log using "`logpath'\001_flag errors.smcl", replace
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

** STEP #2
/*
** Export from latest CR5db backup (check with KWG for latest backup)
	(1) Restore latest CR5db backup onto your CR5db system
	(2) Once logged in, click 'Analysis'
	(3) Click 'Export Data/Reports'
	(4) In 'Table' section, select 'Source+Tumour+Patient'
	(5) In 'Sort by' section, select 'Registry Number'
	(6) Tick 'Select all variables'
	(7) Click 'Refresh Table'
	(8) Click into the 'Export' tab, under 'Options' section select 'Full'
	(9) Under 'File format'section, select 'Tab Separated Values'
	(10) Click 'Export'
	(11) Save export with current date onto:
		 e.g. `datapath'\version07version07\1-input\yyyy-mm-dd_MAIN Source+Tumour+Patient_JC.txt
*/

** STEP #3
** LOAD and SAVE the SOURCE+TUMOUR+PATIENT dataset from above (Source_+Tumour+Patient tables)
insheet using "`datapath'\version07\1-input\2022-07-07_MAIN Source+Tumour+Patient_KWG.txt"

** STEP #4
** Format the IDs from the CR5db dataset
format tumourid %14.0g
format tumouridsourcetable %14.0g
format sourcerecordid %16.0g

** STEP #5
** Delete unused variables as it will reduce time spent when exporting results in excel
drop tumouridsourcetable recordnumber cfdiagnosis labnumber specimen sampletakendate receiveddate ///
	 reportdate clinicaldetails cytologicalfindings microscopicdescription consultationreport causesofdeath durationofillness onsetdeathinterval certifier admissiondate ///
	 datefirstconsultation rtregdate streviewer checkstatus multipleprimary mpseq updatedate obsoleteflagtumourtable patientidtumourtable ///
	 patientrecordidtumourtable tumourupdatedby tumourunduplicationstatus ttdataabstractor ttabstractiondate parish address age primarysite topography histology ///
	 morphology laterality behaviour grade basisofdiagnosis tnmcatstage tnmantstage esstnmcatstage esstnmantstage summarystaging incidencedate consultant ///
	 iccccode icd10 treatment1 treatment1date treatment2 treatment2date treatment3 treatment3date treatment4 treatment4date treatment5 treatment5date ///
	 othertreatment1 othertreatment2 notreatment1 notreatment2 ttreviewer personsearch residentstatus statuslastcontact datelastcontact ///
	 comments ptdataabstractor ptcasefindingdate obsoleteflagpatienttable patientrecordid patientupdatedby patientupdatedate patientrecordstatus ///
	 patientcheckstatus retrievalsource notesseen notesseendate furtherretrievalsource ptreviewer rfalcohol alcoholamount alcoholfreq ///
	 rfsmoking smokingamount smokingfreq smokingduration smokingdurationfreq

** STEP #6
** Create variables for the excel duplicate lists that the SDA will update and label already exisiting variables that will appear in list
gen str_no=.
gen str_da=.
gen str_dadate=.
gen str_action=""
label var registrynumber "Reg #"
label var lastname "Last Name"
label var firstname "First Name"
label var birthdate "DOB"
label var hospitalnumber "Hospital #"
label var diagnosisyear "Dx Year"
label var str_no "No."
label var str_da "DA to Take Action"
label var str_dadate "Date DA Took Action"
label var str_action "Action Taken"


** STEP #7
** Remove cases where there are 2 tumours that have already been merged under 1 registry number and/or cases with multiple source records or multiple tumour records
sort registrynumber
quietly by registrynumber:  gen dup = cond(_N==1,0,_n)
count if dup>1
drop if dup>1
drop dup


** STEP #8 
** NOTE: correct all records whether eligible or not since records maybe matched to other records that are eligible
** Create flags for errors within found in First Name, Last Name, NRN, DOB variables
** Create error list to be included in duplicates excel workbook for DA to correct in CR5db
forvalues j=1/5 {
	gen flag`j'=""
}

label var flag1 "Error: Missing FirstName"
label var flag2 "Error: Missing LastName"
label var flag3 "Error: Invalid Length NRN"
label var flag4 "Error: Invalid Length DOB"
label var flag5 "Error: Invalid Length Hosp#"

forvalues j=6/10 {
	gen flag`j'=""
}
label var flag6 "Correction: Missing FirstName"
label var flag7 "Correction: Missing LastName"
label var flag8 "Correction: Invalid Length NRN"
label var flag9 "Correction: Invalid Length DOB"
label var flag10 "Correction: Invalid Length Hosp#"


** STEP #9
** Check for if first or last name is missing 
** Flag errors for DA to correct in CR5db
count if firstname=="" //0
replace flag1="missing" if firstname=="" //0 change
replace flag6="delete blank record" if firstname==""
count if lastname=="" //0
replace flag2="missing" if lastname=="" //0 change
replace flag7="delete blank record" if lastname==""

** STEP #10
** Correct Names errors flagged above
//drop if registrynumber==20159999 //1 deleted - do not delete incorrect records until you have created the error excel list


** STEP #11
** Check for invalid length NRN
count if length(nrn)<11 & nrn!="" //20
list registrynumber firstname lastname nrn birthdate if length(nrn)<11 & nrn!=""
replace flag3=nrn if length(nrn)<11 & nrn!="" //0 changes


** STEP #12
** Correct NRN errors flagged above for non-specific incorrect NRNs
replace nrn="999999-9999" if nrn=="99" //0 changes
replace nrn="999999-9999" if nrn=="9999-9999" //0 changes
//replace nrn="999999-9999" if nrn=="999999"
gen nrn2 = substr(nrn, 1,6) + "-" + substr(nrn, -4,4) if length(nrn)==10 & !(strmatch(strupper(nrn), "*-*"))
replace nrn=nrn2 if nrn2!="" //0 changes
drop nrn2
gen nrn2 = nrn + "-9999" if length(nrn)==6
replace nrn=nrn2 if nrn2!="" //0 changes
drop nrn2
replace nrn=subinstr(nrn,"9999999","9999-9999",.) if length(nrn)==9 & regexm(nrn,"9999999") //0 changes

replace nrn="" if length(nrn)==1
replace nrn="" if registrynumber==20210143
/*
preserve
clear
import excel using "`datapath'\version07\2-working\NRNelectoral_dups.xlsx" , firstrow case(lower)
save "`datapath'\version07\2-working\electoral_nrn_dups" ,replace
restore

merge 1:1 registrynumber using "`datapath'\version07\2-working\electoral_nrn_dups" ,force
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                        10,625
        from master                    10,625  (_merge==1)
        from using                          0  (_merge==2)

    Matched                                 2  (_merge==3)
    -----------------------------------------
*/
replace nrn=elec_nrn if _merge==3 //2 changes
drop elec_* _merge
erase "`datapath'\version07\2-working\electoral_nrn_dups.dta"
*/
** STEP #13
** Identify corrected NRNs in prep for export to excel ERRORS list
replace flag8=nrn if flag3!="" //0 changes


** STEP #14
** Check for invalid length DOB
gen str8 dob = string(birthdate,"%08.0f")
rename birthdate birthdate2
rename dob birthdate
count if length(birthdate)<8|length(birthdate)>8 //22 - check against electoral list using 'Contains' filter in the Names fields on electoral list
list registrynumber firstname lastname nrn birthdate if length(birthdate)<8|length(birthdate)>8
replace flag4=birthdate if length(birthdate)<8|length(birthdate)>8 //22 changes
replace flag4="missing" if birthdate=="" //0 changes


** STEP #15
** Check for invalid characters in DOB
count if regexm(birthdate,"-") //0
replace flag4=birthdate if regexm(birthdate,"-") //0 changes


** STEP #16
** Correct DOB errors flagged by merging with list of corrections manually created using electoral list (this ensures dofile remains de-identified)
/*
preserve
clear
import excel using "`datapath'\version07version07\2-working\DOBNRNelectoral_dups.xlsx" , firstrow case(lower)
tostring elec_dob ,replace
save "`datapath'\version07version07\2-working\electoral_dobnrn_dups" ,replace
restore
merge 1:1 registrynumber using "`datapath'\version07version07\2-working\electoral_dobnrn_dups" ,force
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         9,106
        from master                     9,106  (_merge==1)
        from using                          0  (_merge==2)

    matched                                11  (_merge==3)
    -----------------------------------------
*/
replace nrn=elec_nrn if _merge==3 //11 changes
replace birthdate=elec_dob if _merge==3 //11 changes
replace firstname=elec_fname if _merge==3 //2 changes
replace middleinitials=elec_mname if _merge==3 //1 changes
replace lastname=elec_lname if _merge==3 //0 changes
drop elec_* _merge
*/


** STEP #17
** Identify corrected DOBs in prep for export to excel ERRORS list 
replace flag9=birthdate if flag4!="" //0 changes - this will store the corrected DOBs in this variable in prep for export to the error excel list
replace flag9="delete blank record" if registrynumber==20159999 //0 changes


** STEP #18
** Check for invalid length Hosp#
count if length(hospitalnumber)==1 //35
list registrynumber firstname lastname hospitalnumber if length(hospitalnumber)==1
count if hospitalnumber=="NYR" //0
replace flag5=hospitalnumber if length(hospitalnumber)==1|hospitalnumber=="NYR" //2 changes


** STEP #19
** Correct Hosp# errors using below method as these won't lead to de-identifying the dofile
replace hospitalnumber="99" if length(hospitalnumber)==1|hospitalnumber=="NYR" //35 changes


** STEP #20
** Identify corrected Hosp#s in prep for export to excel ERRORS list
replace flag10=hospitalnumber if flag5!="" //35 changes


** STEP #21
** Prepare this dataset for export to excel
preserve
sort registrynumber

drop if  flag1=="" & flag2=="" & flag3=="" & flag4=="" & flag5=="" //8,930 deleted

drop str_no
gen str_no= _n
label var str_no "No."


** STEP #22
** Create excel errors list before deleting incorrect records
** Use below code to automate file names using current date
local listdate = string( d(`c(current_date)'), "%dCYND" )
capture export_excel str_no registrynumber flag1 flag6 flag2 flag7 flag3 flag8 flag4 flag9 flag5 flag10 str_da str_dadate str_action if flag1!=""|flag2!=""|flag3!=""|flag4!=""|flag5!="" using "`datapath'\version07\3-output\CancerDuplicates`listdate'.xlsx", sheet("ERRORS") firstrow(varlabels)
restore


** STEP #23
** Remove variables not needed for excel lists
drop stdataabstractor stsourcedate nftype sourcename doctor doctoraddress recordstatus

count //12,154


** STEP #24
** Save this dataset
save "`datapath'\version07\2-working\corrected_cancer_dups.dta" ,replace
label data "BNR-Cancer Duplicates"
notes _dta :These data prepared for SDA to use for identifying duplicates and possible missed merges
