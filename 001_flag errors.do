** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          001_flag errors.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      16-SEP-2021
    // 	date last modified      16-SEP-2021
    //  algorithm task          Formatting the CanReg5 dataset, identifying, flagging and correcting errors (see dofile '2c_dup cancer')
    //  status                  Completed
    //  objective               (1) To have list of any errors identified during this process so DAs can correct in CR5db.
	//							(2) To have a corrected dataset for generating new duplicates lists (see dofiles '2b_dup cancer' + '2c_dup cancer')
	//							(3)	To have the SOP for this process written into the dofile.
    //  methods                 Importing current CR5db dataset and flagging errors.
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
		 e.g. L:\Sync\Cancer\CanReg5\DA Duplicates\2021\2021_March\2021-03-11_MAIN Source+Tumour+Patient_JC.txt
*/

** STEP #3
** LOAD and SAVE the SOURCE+TUMOUR+PATIENT dataset from above (Source_+Tumour+Patient tables)
insheet using "`datapath'\version07\1-input\2021-09-16_MAIN Source+Tumour+Patient_JC.txt"

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
	 comments ptdataabstractor ptcasefindingdate casestatus obsoleteflagpatienttable patientrecordid patientupdatedby patientupdatedate patientrecordstatus ///
	 patientcheckstatus retrievalsource notesseen notesseendate furtherretrievalsource ptreviewer 

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


************************************** FIRST, run the code above this line then run the 3 different duplicate check lists **********************************************
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
count if length(nrn)<11 & nrn!="" //3
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


** STEP #13
** Correct NRN errors flagged above for specific incorrect NRNs, i.e. checked against electoral list
//replace nrn=subinstr(nrn,"BO","9999",.) //1 change
//replace nrn=subinstr(nrn,"LP","9999",.) //1 change
//replace nrn=subinstr(nrn,"12","012",.) if registrynumber==20150215 //1 change
//replace nrn=subinstr(nrn,"-","",.) + "-9999" if registrynumber==20155048 //1 change
//replace nrn=substr(birthdate, -6,6) + "-9999" if registrynumber==20160062 //1 change
//replace nrn="999999-9999" if registrynumber==20190385 //1 change


** STEP #14
/* 
	Correct NRN errors flagged for specific incorrect NRNs using this method: 
	electoral list - filter in NRN using 'Begins with' and enter dob part of NRN. 
	Check if for 2 entries for same person and using NRN in below list determine which is the one to update.
*/
count if length(nrn)<11 & nrn!="" //0
list registrynumber firstname lastname nrn birthdate nftype sourcename doctor if length(nrn)<11 & nrn!=""
/*
replace nrn=nrn + "0" if registrynumber==20190556|registrynumber==20190592|registrynumber==20200181|registrynumber==20201038|registrynumber==20201039|registrynumber==20201090|registrynumber==20201101
replace nrn=nrn + "1" if registrynumber==20190530|registrynumber==20190542|registrynumber==20190573|registrynumber==20190602|registrynumber==20200208|registrynumber==20200218|registrynumber==20200220|registrynumber==20200232|registrynumber==20201049|registrynumber==20201068|registrynumber==20201096
replace nrn=nrn + "2" if registrynumber==20190537|registrynumber==20190572|registrynumber==20190603|registrynumber==20200222|registrynumber==20201041|registrynumber==20201043|registrynumber==20201099
replace nrn=nrn + "3" if registrynumber==20190558|registrynumber==20190606|registrynumber==20200105|registrynumber==20200217|registrynumber==20201047|registrynumber==20201091|registrynumber==20201092
replace nrn=nrn + "4" if registrynumber==20190531|registrynumber==20190570|registrynumber==20200186|registrynumber==20200188|registrynumber==20200205|registrynumber==20200206|registrynumber==20201046|registrynumber==20201069|registrynumber==20201097|registrynumber==20201201
replace nrn=nrn + "5" if registrynumber==20190500|registrynumber==20190501|registrynumber==20190571|registrynumber==20200182|registrynumber==20200204|registrynumber==20200219|registrynumber==20201032|registrynumber==20201066|registrynumber==20201094
replace nrn=nrn + "6" if registrynumber==20172010|registrynumber==20181101|registrynumber==20190499|registrynumber==20190508|registrynumber==20190543|registrynumber==20190560|registrynumber==20200187|registrynumber==20200221|registrynumber==20201045|registrynumber==20201100|registrynumber==20201108
replace nrn=nrn + "7" if registrynumber==20190534|registrynumber==20190535|registrynumber==20190544|registrynumber==20190546|registrynumber==20190591|registrynumber==20200184|registrynumber==20201062|registrynumber==20201093|registrynumber==20201107|registrynumber==20201204
replace nrn=nrn + "8" if registrynumber==20190507|registrynumber==20190536|registrynumber==20190541|registrynumber==20190545|registrynumber==20190597|registrynumber==20190605|registrynumber==20191248|registrynumber==20200202|registrynumber==20200203|registrynumber==20200216|registrynumber==20201026|registrynumber==20201040|registrynumber==20201050|registrynumber==20201102|registrynumber==20201106
replace nrn=nrn + "9" if registrynumber==20190398|registrynumber==20190503|registrynumber==20190533|registrynumber==20190557|registrynumber==20201048|registrynumber==20201105|registrynumber==20201203
replace nrn=subinstr(nrn,"-000","",.) if registrynumber==20200183
replace nrn=nrn + "-9999" if registrynumber==20200183
replace nrn=subinstr(nrn,"7","1",.) if registrynumber==20200219
replace nrn=subinstr(nrn,"80","90",.) if registrynumber==20201108
replace nrn=subinstr(nrn,"-","-0",.) if registrynumber==20201108
replace nrn=subinstr(nrn,"36","39",.) if registrynumber==20201204
//99 changes
*/

** STEP #15
** Identify corrected NRNs in prep for export to excel ERRORS list
replace flag8=nrn if flag3!="" //0 changes


** STEP #16
** Check for invalid length DOB
gen str8 dob = string(birthdate,"%08.0f")
rename birthdate birthdate2
rename dob birthdate
count if length(birthdate)<8|length(birthdate)>8 //0 - check against electoral list using 'Contains' filter in the Names fields on electoral list
list registrynumber firstname lastname nrn birthdate if length(birthdate)<8|length(birthdate)>8
replace flag4=birthdate if length(birthdate)<8|length(birthdate)>8 //0 changes
replace flag4="missing" if birthdate=="" //0 changes


** STEP #17
** Check for invalid characters in DOB
count if regexm(birthdate,"-") //0
replace flag4=birthdate if regexm(birthdate,"-") //0 changes


** STEP #18
** Correct DOB errors using below method as these won't lead to de-identifying the dofile
//replace birthdate=subinstr(birthdate,"-0","",.) if registrynumber==20201091 & birthdate!=""
//replace birthdate=subinstr(birthdate,"3","193",.) if registrynumber==20201091 & birthdate!=""


** STEP #19
** Correct DOB errors flagged by merging with list of corrections manually created using electoral list (this ensures dofile remains de-identified)
/*
preserve
clear
import excel using "`datapath'\version07\2-working\DOBNRNelectoral_dups.xlsx" , firstrow case(lower)
tostring elec_dob ,replace
save "`datapath'\version07\2-working\electoral_dobnrn_dups" ,replace
restore
merge 1:1 registrynumber using "`datapath'\version07\2-working\electoral_dobnrn_dups" ,force
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

** STEP #20
** Correct DOB errors using below method as these won't lead to de-identifying the dofile
//replace birthdate=subinstr(birthdate,"8","18",.) if registrynumber==20160465 //1 change
//replace birthdate="99999999" if birthdate==""|birthdate=="99" //7 changes


** STEP #21
** Identify corrected DOBs in prep for export to excel ERRORS list 
replace flag9=birthdate if flag4!="" //0 changes - this will store the corrected DOBs in this variable in prep for export to the error excel list
replace flag9="delete blank record" if registrynumber==20159999 //0 changes


** STEP #23
** Check for invalid length Hosp#
count if length(hospitalnumber)==1 //0
list registrynumber firstname lastname hospitalnumber if length(hospitalnumber)==1
replace flag5=hospitalnumber if length(hospitalnumber)==1 //0 changes


** STEP #24
** Correct Hosp# errors using below method as these won't lead to de-identifying the dofile
replace hospitalnumber="99" if length(hospitalnumber)==1 //0 changes


** STEP #25
** Identify corrected Hosp#s in prep for export to excel ERRORS list
replace flag10=hospitalnumber if flag5!="" //0 changes


** STEP #26
** Prepare this dataset for export to excel
preserve
sort registrynumber

drop if  flag1=="" & flag2=="" & flag3=="" & flag4=="" & flag5=="" //8,930 deleted

drop str_no
gen str_no= _n
label var str_no "No."


** STEP #27
** Create excel errors list before deleting incorrect records
** Use below code to automate file names using current date
local listdate = string( d(`c(current_date)'), "%dCYND" )
capture export_excel str_no registrynumber flag1 flag6 flag2 flag7 flag3 flag8 flag4 flag9 flag5 flag10 str_da str_dadate str_action if flag1!=""|flag2!=""|flag3!=""|flag4!=""|flag5!="" using "`datapath'\version07\3-output\CancerDuplicates`listdate'.xlsx", sheet("ERRORS") firstrow(varlabels)
restore


** STEP #28
** Correct errors flagged from Names check (STEP #9 above)
//drop if registrynumber==20159999 //1 deleted


** STEP #29
** Remove variables not needed for exel lists
drop stdataabstractor stsourcedate nftype sourcename doctor doctoraddress recordstatus

count //10,058


** STEP #30
** Save this dataset
save "`datapath'\version07\2-working\corrected_cancer_dups.dta" ,replace
label data "BNR-Cancer Duplicates"
notes _dta :These data prepared for SDA to use for identifying duplicates and possible missed merges

/*
** STEP #31
** Run all of the dofiles from this dofile
do "`logpath'\002_prep_prev_lists"
do 003a_compare lists_NRN
do 003b_compare lists_DOB
do 003c_compare lists_HOSP
do 003d_compare lists_NAMES
do 004_export new lists