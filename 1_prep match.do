** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          1_prep match.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      25-MAY-2021
    // 	date last modified      25-MAY-2021
    //  algorithm task          Matching uncleaned 2016 cancer dataset with REDCap's 2016 deaths
    //  status                  Completed
    //  objective               To have a complete list of DCOs for the cancer team to use in trace-back in prep for 2016 cancer report.
    //  methods                 Merging CR5 2016 dataset with the prepared 2016 death dataset from 10_prep mort.do

    ** General algorithm set-up
    version 16.1
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
    log using "`logpath'\1_prep match_2016.smcl", replace
** HEADER -----------------------------------------------------

/* 
	Since 2016 deaths were already prepared for death matching in
	10_prep mort.do from 2015AnnualReportV02 branch,
	we will use that dataset but need to prep NRN before preparing the CR5db dataset
*/
** LOAD the 2016 death dataset from 2015 branch
use "`datapath'\version02\3-output\2016_deaths_for_matching" ,clear

** Prep NRN field for merging with cancer dataset
//nsplit nrn, digits(6 4) gen(nrndob nrnnum)
gen double nrn2=nrn
format nrn2 %15.0g
tostring nrn2 ,replace
gen nrndob=substr(nrn2,1,6) if length(nrn2)==10
gen nrnnum=substr(nrn2,7,4) if length(nrn2)==10
gen natregno=nrndob+"-"+nrnnum if length(nrn2)==10
drop nrn2 nrndob nrnnum

save "`datapath'\version05\3-output\2016_deaths_for_matching" ,replace

clear

* ************************************************************************
* PREP AND FORMAT
**************************************************************************

/*
 To prepare cancer dataset:
 (1) import into excel the .txt files exported from CanReg5 and change the format from General to Text for the below fields in excel:
		- TumourIDSourceTable
		- SourceRecordID
		- STDataAbstractor
		- NFType
		- STReviewer
		- TumourID
		- PatientIDTumourTable
		- TTDataAbstractor
		- Parish
		- Topography
		- TTReviewer
		- RegistryNumber
		- PTDataAbstractor
		- PatientRecordID
		- RetrievalSource
		- FurtherRetrievalSource
		- PTReviewer
 (2) import the .xlsx file into Stata and save dataset in Stata
*/
import excel using "`datapath'\version05\1-input\2021-05-21_MAIN Source+Tumour+Patient_JC_excel.xlsx", firstrow
save "`datapath'\version05\2-working\2008-2020_cancer_import_dp" ,replace

count //16,022

** Format incidence date to create tumour year
nsplit IncidenceDate, digits(4 2 2) gen(dotyear dotmonth dotday)
gen dot=mdy(dotmonth, dotday, dotyear)
format dot %dD_m_CY
gen dotyear2 = year(dot)
label var dot "IncidenceDate"
label var dotyear "Incidence year"
drop IncidenceDate

count //16,022

** Renaming CanReg5 variables
rename Personsearch persearch
rename PTDataAbstractor ptda
rename TTDataAbstractor ttda
rename STDataAbstractor stda
rename CaseStatus cstatus
rename RetrievalSource retsource
rename FurtherRetrievalSource fretsource
rename NotesSeen notesseen
rename BirthDate birthdate
rename Sex sex
rename MiddleInitials init
rename FirstName fname
rename LastName lname
rename NRN natregno
rename ResidentStatus resident
rename Comments comments
rename PTReviewer ptreviewer
rename TTReviewer ttreviewer
rename STReviewer streviewer
rename MPTot mptot
rename MPSeq mpseq
rename PatientIDTumourTable patientidtumourtable
rename PatientRecordID pid2
rename RegistryNumber pid
rename TumourID eid2
rename Recordstatus recstatus
rename Checkstatus checkstatus
rename TumourUpdatedBy tumourupdatedby
rename PatientUpdatedBy patientupdatedby
rename SourceRecordID sid2
rename StatusLastContact slc
rename Parish parish
rename Address addr
rename Age age
rename PrimarySite primarysite
rename Topography topography
rename BasisOfDiagnosis basis
rename Histology hx
rename Morphology morph
rename Laterality lat
rename Behaviour beh
rename Grade grade
rename TNMCatStage tnmcatstage
rename TNMAntStage tnmantstage
rename EssTNMCatStage esstnmcatstage
rename EssTNMAntStage esstnmantstage
rename SummaryStaging staging
rename Consultant consultant
rename HospitalNumber hospnum
rename CausesOfDeath cr5cod
rename DiagnosisYear dxyr
rename Treat*1 rx1
rename Treat*2 rx2
rename Treat*3 rx3
rename Treat*4 rx4
rename Treat*5 rx5
rename Oth*Treat*1 orx1
rename Oth*Treat*2 orx2
rename NoTreat*1 norx1
rename NoTreat*2 norx2
rename NFType nftype
rename SourceName sourcename
rename Doctor doctor
rename DoctorAddress docaddr
rename RecordNumber recnum
rename CFDiagnosis cfdx
rename LabNumber labnum
rename Specimen specimen
rename ClinicalDetails clindets
rename CytologicalFindings cytofinds
rename MicroscopicDescription md
rename ConsultationReport consrpt
rename DurationOfIllness duration
rename OnsetDeathInterval onsetint
rename Certifier certifier
rename TumourIDSourceTable tumouridsourcetable

/*
Creating and formatting various record IDs auto-generated by CanReg5 which uniquely identify patients (pid), tumours (eid) and sources (sid)
Note: When records are merged in CanReg5, the following can take place:
1) the pid can be kept so in these cases patientrecordid will differentiate between the 2 patient records for the same patient and/or
2) the first 8 digits in tumourid remains the same as the defunct (i.e. no longer used) pid while the new pid will be the pid into which
   that tumour was merged e.g. 20130303 has 2 tumours with different tumourids - 201303030102 and 201407170101.
*/
gen top = topography
destring topography, replace

gen str_sourcerecordid=sid2
gen sourcetotal = substr(str_sourcerecordid,-1,1)
destring sourcetot, gen (sourcetot)

gen str_pid2 = pid2
gen patienttotal = substr(str_pid2,-1,1)
destring patienttot, gen (patienttot)
gen str_patientidtumourtable=patientidtumourtable

gen mpseq2=mpseq
replace mpseq2=1 if mpseq2==0
tostring mpseq2, replace
gen eid = str_patientidtumourtable + "010" + mpseq2

gen sourceseq = substr(str_sourcerecordid,13,2)
gen sid = eid + sourceseq


**********************************************************
** NAMING & FORMATTING - PATIENT TABLE
** Note:
** (1)Label as they appear in CR5 record
** (2)Don't clean where possible as
**    corrections to be flagged in 2_flag_cancer.do
**********************************************************

** Unique PatientID
label var pid "Registry Number"

** Person Search
label var persearch "Person Search"
label define persearch_lab 0 "Not done" 1 "Done: OK" 2 "Done: MP" 3 "Done: Duplicate" 4 "Done: Non-IARC MP", modify
label values persearch persearch_lab

** Patient record updated by
label var patientupdatedby "PT updated by"

** Date patient record updated
nsplit PatientUpdateDate, digits(4 2 2) gen(year month day)
gen ptupdate=mdy(month, day, year)
format ptupdate %dD_m_CY
drop day month year PatientUpdateDate
label var ptupdate "Date PT updated"

** PT Data Abstractor
** contains non-numeric character so need to find and correct
generate byte non_numeric_ptda = indexnot(ptda, "0123456789.-")
count if non_numeric_ptda //2
//list pid ptda cr5id if non_numeric_ptda
replace ptda="09" if pid=="20145017"
destring ptda,replace
count if ptda==. //1
//list pid ptda cr5id if ptda==.
replace ptda=9 if ptda==.
label var ptda "PTDataAbstractor"
label define ptda_lab 1 "JC" 2 "RH" 3 "PM" 4 "WB" 5 "LM" 6 "NE" 7 "TD" 8 "TM" 9 "SAF" 10 "PP" 11 "LC" 12 "AJB" ///
					  13 "KWG" 14 "TH" 22 "MC" 88 "Doctor" 98 "Intern" 99 "Unknown", modify
label values ptda ptda_lab

** Casefinding Date
replace PTCasefindingDate=20000101 if PTCasefindingDate==99999999
nsplit PTCasefindingDate, digits(4 2 2) gen(year month day)
gen ptdoa=mdy(month, day, year)
format ptdoa %dD_m_CY
drop day month year PTCasefindingDate
label var ptdoa "PTCasefindingDate"

** Case Status
label var cstatus "CaseStatus"
label define cstatus_lab 0 "CF" 1 "ABS" 2 "Deleted" 3 "Ineligible" 4 "Duplicate" 5 "Pending CD Review", modify
label values cstatus cstatus_lab

** Retrieval Source
destring retsource, replace
label var retsource "RetrievalSource"
label define retsource_lab 1 "QEH Medical Records" 2 "QEH Death Records" 3 "QEH Radiotherapy Dept" 4 "QEH Colposcopy Clinic" ///
						   5 "QEH Haematology Dept" 6 "QEH Private Consulting" 7 "QEH Respiratory Unit" 8 "Bay View" ///
						   9 "Barbados Cancer Society" 10 "Private Physician" 11 "PP-I Lewis" 12 "PP-J Emtage" 13 "PP-B Lynch" ///
						   14 "PP-D Greaves" 15 "PP-S Smith Connell" 16 "PP-R Shenoy" 17 "PP-S Ferdinand" 18 "PP-T Shepherd" ///
						   19 "PP-G S Griffith" 20 "PP-J Nebhnani" 21 "PP-J Ramesh" 22 "PP-J Clarke" 23 "PP-T Laurent" ///
						   24 "PP-S Jackman" 25 "PP-W Crookendale" 26 "PP-C Warner" 27 "PP-H Thani" 28 "Polyclinic" ///
						   29 "Emergency Clinic" 30 "Nursing Home" 31 "None" 32 "Other", modify
label values retsource retsource_lab

** Notes Seen
label var notesseen "NotesSeen"
label define notesseen_lab 0 "Pending Retrieval" 1 "Yes" 2 "Yes-Pending Further Retrieval" 3 "No" 4 "Cannot retrieve-Year Closed" ///
						   5 "Cannot retrieve-3 attempts" 6 "Cannot retrieve-Permission not granted" 7 "Cannot retrieve-Not found by Clerk", modify
label values notesseen notesseen_lab

** Notes Seen Date
replace NotesSeenDate=20000101 if NotesSeenDate==99999999
nsplit NotesSeenDate, digits(4 2 2) gen(year month day)
gen nsdate=mdy(month, day, year)
format nsdate %dD_m_CY
drop day month year NotesSeenDate
label var nsdate "NotesSeenDate"

** Further Retrieval Source
destring fretsource, replace
label var fretsource "RetrievalSource"
label define fretsource_lab 1 "QEH Medical Records" 2 "QEH Death Records" 3 "QEH Radiotherapy Dept" 4 "QEH Colposcopy Clinic" ///
						   5 "QEH Haematology Dept" 6 "QEH Private Consulting" 7 "QEH Respiratory Unit" 8 "Bay View" ///
						   9 "Barbados Cancer Society" 10 "Private Physician" 11 "PP-I Lewis" 12 "PP-J Emtage" 13 "PP-B Lynch" ///
						   14 "PP-D Greaves" 15 "PP-S Smith Connell" 16 "PP-R Shenoy" 17 "PP-S Ferdinand" 18 "PP-T Shepherd" ///
						   19 "PP-G S Griffith" 20 "PP-J Nebhnani" 21 "PP-J Ramesh" 22 "PP-J Clarke" 23 "PP-T Laurent" ///
						   24 "PP-S Jackman" 25 "PP-W Crookendale" 26 "PP-C Warner" 27 "PP-H Thani" 28 "Polyclinic" ///
						   29 "Emergency Clinic" 30 "Nursing Home" 31 "None" 32 "Other", modify
label values fretsource fretsource_lab

** First, Middle & Last Names
label var fname "FirstName"
label var init "MiddleInitials"
label var lname "LastName"

** Birth Date
** Some errors in the data are preventing this date to be formatted so correct first
** Instead of using below code to correct, I manually did so 
** (removed all with unk code 99/9999/99999999, etc.) in the import excel file so this variable will import as long data type not string
/*
count if length(birthdate)<8 //22
list pid birthdate natregno if length(birthdate)<8
replace birthdate=subinstr(birthdate,"8","18",.) if pid=="20160465" & birthdate!=""
replace birthdate="" if length(birthdate)<8 //10 changes
count if birthdate=="99999999" //716
replace birthdate="" if birthdate=="99999999" //716 changes
replace birthdate = lower(rtrim(ltrim(itrim(birthdate)))) //0 changes
*/
nsplit birthdate, digits(4 2 2) gen(dobyear dobmonth dobday)
gen dob=mdy(dobmonth, dobday, dobyear)
format dob %dD_m_CY
label var dob "BirthDate"

** Sex
label var sex "Sex"
label define sex_lab 1 "Male" 2 "Female" 9 "Unknown", modify
label values sex sex_lab

** National Reg. No.
label var natregno "NRN"

** Hospital Number
label var hospnum "HospitalNumber"

** Resident Status
label var resident "ResidentStatus"
label define resident_lab 1 "Yes" 2 "No" 9 "Unknown", modify
label values resident resident_lab

** Status Last Contact
label var slc "StatusLastContact"
label define slc_lab 1 "Alive" 2 "Deceased" 3 "Emigrated" 9 "Unknown", modify
label values slc slc_lab

** Date Last Contact
replace DateLastContact=20000101 if DateLastContact==99999999
nsplit DateLastContact, digits(4 2 2) gen(year month day)
gen dlc=mdy(month, day, year)
format dlc %dD_m_CY
drop day month year DateLastContact
label var dlc "DateLastContact"

** Comments
label var comments "Comments"

** PT Reviewer
destring ptreviewer, replace
label var ptreviewer "PTReviewer"
label define ptreviewer_lab 0 "Pending" 1 "JC" 2 "LM" 3 "PP" 4 "AR" 5 "AH" 6 "JK" 7 "TM" 8 "SAW" 9 "SAF" 99 "Unknown", modify
label values ptreviewer ptreviewer_lab


**********************************************************
** NAMING & FORMATTING - TUMOUR TABLE
** Note:
** (1)Label as they appear in CR5 record
** (2)Don't clean where possible as
**    corrections to be flagged in 3_cancer_corrections.do
**********************************************************

** Unique TumourID
label var eid "TumourID"

** TT Record Status
label var recstatus "TTRecordStatus"
label define recstatus_lab 0 "Pending" 1 "Confirmed" 2 "Deleted" 3 "Ineligible" 4 "Duplicate" , modify
label values recstatus recstatus_lab

** TT Check Status
label var checkstatus "TTCheckStatus"
label define checkstatus_lab 0 "Not done" 1 "Done: OK" 2 "Done: Rare" 3 "Done: Invalid" , modify
label values checkstatus checkstatus_lab

** MP Sequence
label var mpseq "MP Sequence"

** MP Total
label var mptot "MP Total"

** Tumour record updated by
label var tumourupdatedby "TT updated by"

** Date tumour record updated
nsplit UpdateDate, digits(4 2 2) gen(year month day)
gen ttupdate=mdy(month, day, year)
format ttupdate %dD_m_CY
drop day month year UpdateDate
label var ttupdate "Date TT updated"

** TT Data Abstractor
destring ttda, replace
label var ttda "TTDataAbstractor"
label define ttda_lab 1 "JC" 2 "RH" 3 "PM" 4 "WB" 5 "LM" 6 "NE" 7 "TD" 8 "TM" 9 "SAF" 10 "PP" 11 "LC" 12 "AJB" ///
					  13 "KWG" 14 "TH" 22 "MC" 88 "Doctor" 98 "Intern" 99 "Unknown", modify
label values ttda ttda_lab

** Abstraction Date
replace TTAbstractionDate=20000101 if TTAbstractionDate==99999999
nsplit TTAbstractionDate, digits(4 2 2) gen(year month day)
gen ttdoa=mdy(month, day, year)
format ttdoa %dD_m_CY
drop day month year TTAbstractionDate
label var ttdoa "TTAbstractionDate"

** Parish
destring parish, replace
label var parish "Parish"
label define parish_lab 1 "Christ Church" 2 "St. Andrew" 3 "St. George" 4 "St. James" 5 "St. John" 6 "St. Joseph" ///
						7 "St. Lucy" 8 "St. Michael" 9 "St. Peter" 10 "St. Philip" 11 "St. Thomas" 99 "Unknown", modify
label values parish parish_lab

** Address
label var addr "Address"

**	Age
label var age "Age"

** Primary Site
label var primarysite "PrimarySite"

** Topography
label var topography "Topography"

** Histology
label var hx "Histology"

** Morphology
label var morph "Morphology"

** Laterality
label var lat "Laterality"
label define lat_lab 0 "Not a paired site" 1 "Right" 2 "Left" 3 "Only one side, origin unspecified" 4 "Bilateral" ///
					 5 "Midline tumour" 8 "NA" 9 "Unknown", modify
label values lat lat_lab

** Behaviour
label var beh "Behaviour"
label define beh_lab 0 "Benign" 1 "Uncertain" 2 "In situ" 3 "Malignant", modify
label values beh beh_lab

** Grade
label var grade "Grade"
label define grade_lab 1 "(well) differentiated" 2 "(mod.) differentiated" 3 "(poor.) differentiated" ///
					   4 "undifferentiated" 5 "T-cell" 6 "B-cell" 7 "Null cell (non-T/B)" 8 "NK cell" ///
					   9 "Undetermined; NA; Not stated", modify
label values grade grade_lab

** Basis of Diagnosis
label var basis "BasisOfDiagnosis"
label define basis_lab 0 "DCO" 1 "Clinical only" 2 "Clinical Invest./Ult Sound" 3 "Exploratory surg./autopsy" ///
					   4 "Lab test (biochem/immuno.)" 5 "Cytology/Haem" 6 "Hx of mets" 7 "Hx of primary" ///
					   8 "Autopsy w/ Hx" 9 "Unknown", modify
label values basis basis_lab

** TNM Categorical Stage
label var tnmcatstage "TNM Cat Stage"

** TNM Anatomical Stage
label var tnmantstage "TNM Ant Stage"

** Essential TNM Categorical Stage
label var esstnmcatstage "Essential TNM Cat Stage"

** Essential TNM Anatomical Stage
label var esstnmantstage "Essential TNM Ant Stage"

** Summary Staging
label var staging "Staging"
label define staging_lab 0 "In situ" 1 "Localised only" 2 "Regional: direct ext." 3 "Regional: LNs only" ///
						 4 "Regional: both dir. ext & LNs" 5 "Regional: NOS" 7 "Distant site(s)/LNs" ///
						 8 "NA" 9 "Unknown; DCO case", modify
label values staging staging_lab

** Incidence Date
** already formatted above

** Diagnosis Year
label var dxyr "DiagnosisYear"
** Check for blanks as may accidentally drop 2014 cases in 2nd dofile
count if dxyr==. //3
list pid dot ttda stda cr5id if dxyr==.
replace dxyr=2015 if dxyr==. //3 changes

** Consultant
label var consultant "Consultant"

** Treatments 1-5
label var rx1 "Treatment1"
label define rx_lab 0 "No treatment" 1 "Surgery" 2 "Radiotherapy" 3 "Chemotherapy" 4 "Immunotherapy" ///
					5 "Hormonotherapy" 8 "Other relevant therapy" 9 "Unknown" ,modify
label values rx1 rx2 rx3 rx4 rx5 rx_lab

label var rx2 "Treatment2"
label var rx3 "Treatment3"
label var rx4 "Treatment4"
label var rx5 "Treatment5"

** Treatments 1-5 Date
replace Treatment1Date=20000101 if Treatment1Date==99999999
nsplit Treatment1Date, digits(4 2 2) gen(rx1year rx1month rx1day)
gen rx1d=mdy(rx1month, rx1day, rx1year)
format rx1d %dD_m_CY
drop Treatment1Date
label var rx1d "Treatment1Date"

replace Treatment2Date=20000101 if Treatment2Date==99999999
nsplit Treatment2Date, digits(4 2 2) gen(rx2year rx2month rx2day)
gen rx2d=mdy(rx2month, rx2day, rx2year)
format rx2d %dD_m_CY
drop Treatment2Date
label var rx2d "Treatment2Date"

replace Treatment3Date=20000101 if Treatment3Date==99999999
nsplit Treatment3Date, digits(4 2 2) gen(rx3year rx3month rx3day)
gen rx3d=mdy(rx3month, rx3day, rx3year)
format rx3d %dD_m_CY
drop Treatment3Date
label var rx3d "Treatment3Date"

replace Treatment4Date=20000101 if Treatment4Date==99999999
nsplit Treatment4Date, digits(4 2 2) gen(rx4year rx4month rx4day)
gen rx4d=mdy(rx4month, rx4day, rx4year)
format rx4d %dD_m_CY
drop Treatment4Date
label var rx4d "Treatment4Date"

** Treatment 5 has no observations so had to slightly adjust code
replace Treatment5Date=20000101 if Treatment5Date==99999999
if Treatment5Date !=. nsplit Treatment5Date, digits(4 2 2) gen(rx5year rx5month rx5day)
if Treatment5Date !=. gen rx5d=mdy(rx5month, rx5day, rx5year)
if Treatment5Date !=. format rx5d %dD_m_CY
if Treatment5Date==. rename Treatment5Date rx5d
label var rx5d "Treatment5Date"

** Other Treatment 1
label var orx1 "OtherTreatment1"
label define orx_lab 1 "Cryotherapy" 2 "Laser therapy" 3 "Treated Abroad" ///
					 4 "Palliative therapy" 9 "Unknown" ,modify
label values orx1 orx_lab

** Other Treatment 2
label var orx2 "OtherTreatment2"

** No Treatments 1 and 2
label var norx1 "NoTreatment1"
label define norx_lab 1 "Alternative rx" 2 "Symptomatic rx" 3 "Died before rx" ///
					  4 "Refused rx" 5 "Postponed rx"  6 "Watchful waiting" ///
					  7 "Defaulted from care" 8 "NA" 9 "Unknown" ,modify
label values norx1 norx_lab

** No Treatment 2
** contains a nonnumeric character so field needs correcting!
label var norx2 "NoTreatment2"

** TT Reviewer
destring ttreviewer, replace
label var ttreviewer "TTReviewer"
label define ttreviewer_lab 0 "Pending" 1 "JC" 2 "LM" 3 "PP" 4 "AR" 5 "AH" 6 "JK" 7 "TM" 8 "SAW" 9 "SAF" 99 "Unknown", modify
label values ttreviewer ttreviewer_lab


**********************************************************
** NAMING & FORMATTING - SOURCE TABLE
** Note:
** (1)Label as they appear in CR5 record
** (2)Don't clean where possible as
**    corrections to be flagged in 3_cancer_corrections.do
**********************************************************

** Unique SourceID
label var sid "SourceRecordID"

** ST Data Abstractor
destring stda, replace
** DOES NOT contain a nonnumeric character so no correction needed
label var stda "STDataAbstractor"
label define stda_lab 1 "JC" 2 "RH" 3 "PM" 4 "WB" 5 "LM" 6 "NE" 7 "TD" 8 "TM" 9 "SAF" 10 "PP" 11 "LC" 12 "AJB" ///
					  13 "KWG" 14 "TH" 22 "MC" 88 "Doctor" 98 "Intern" 99 "Unknown", modify
label values stda stda_lab

** Source Date
replace STSourceDate=20000101 if STSourceDate==99999999
nsplit STSourceDate, digits(4 2 2) gen(year month day)
gen stdoa=mdy(month, day, year)
format stdoa %dD_m_CY
drop day month year STSourceDate
label var stdoa "STSourceDate"

** NF Type
destring nftype, replace
label var nftype "NFType"
label define nftype_lab 1 "Hospital" 2 "Polyclinic/Dist.Hosp." 3 "Lab-Path" 4 "Lab-Cyto" 5 "Lab-Haem" 6 "Imaging" ///
						7 "Private Physician" 8 "Death Certif./Post Mort." 9 "QEH Death Rec Bks" 10 "RT Reg. Bk" ///
						11 "Haem NF" 12 "Bay View Bk" 13 "Other" 14 "Unknown" 15 "NFs", modify
label values nftype nftype_lab

** Source Name
label var sourcename "SourceName"
label define sourcename_lab 1 "QEH" 2 "Bay View" 3 "Private Physician" 4 "IPS-ARS" 5 "Death Registry" ///
							6 "Polyclinic" 7 "BNR Database" 8 "Other" 9 "Unknown", modify
label values sourcename sourcename_lab

** Doctor
label var doctor "Doctor"

** Doctor's Address
label var docaddr "DoctorAddress"

** Record Number
label var recnum "RecordNumber"

** CF Diagnosis
label var cfdx "CFDiagnosis"

** Lab Number
label var labnum "LabNumber"

** Specimen
label var specimen "Specimen"

** Sample Taken Date
replace SampleTakenDate=20000101 if SampleTakenDate==99999999
nsplit SampleTakenDate, digits(4 2 2) gen(stdyear stdmonth stdday)
gen sampledate=mdy(stdmonth, stdday, stdyear)
format sampledate %dD_m_CY
drop SampleTakenDate
label var sampledate "SampleTakenDate"

** Received Date
replace ReceivedDate=20000101 if ReceivedDate==99999999 | ReceivedDate==.
nsplit ReceivedDate, digits(4 2 2) gen(rdyear rdmonth rdday)
gen recvdate=mdy(rdmonth, rdday, rdyear)
format recvdate %dD_m_CY
replace recvdate=d(01jan2000) if recvdate==.
drop ReceivedDate
label var recvdate "ReceivedDate"

** Report Date
replace ReportDate=20000101 if ReportDate==99999999
nsplit ReportDate, digits(4 2 2) gen(rptyear rptmonth rptday)
gen rptdate=mdy(rptmonth, rptday, rptyear)
format rptdate %dD_m_CY
drop ReportDate
label var rptdate "ReportDate"

** Clinical Details
label var clindets "ClinicalDetails"

** Cytological Findings
label var cytofinds "CytologicalFindings"

** Microscopic Description
label var md "MicroscopicDescription"

** Consultation Report
label var consrpt "ConsultationReport"

** Cause(s) of Death
label var cr5cod "CausesOfDeath"

** Duration of Illness
label var duration "DurationOfIllness"

** Onset to Death Interval
label var onsetint "OnsetDeathInterval"

** Certifier
label var certifier "Certifier"

** Admission Date
replace AdmissionDate=20000101 if AdmissionDate==99999999
nsplit AdmissionDate, digits(4 2 2) gen(admyear admmonth admday)
gen admdate=mdy(admmonth, admday, admyear)
format admdate %dD_m_CY
drop AdmissionDate
label var admdate "AdmissionDate"

** Date First Consultation
replace DateFirstConsultation=20000101 if DateFirstConsultation==99999999
nsplit DateFirstConsultation, digits(4 2 2) gen(dfcyear dfcmonth dfcday)
gen dfc=mdy(dfcmonth, dfcday, dfcyear)
format dfc %dD_m_CY
drop DateFirstConsultation
label var dfc "DateFirstConsultation"

** RT Registration Date
replace RTRegDate=20000101 if RTRegDate==99999999
nsplit RTRegDate, digits(4 2 2) gen(rtyear rtmonth rtday)
gen rtdate=mdy(rtmonth, rtday, rtyear)
format rtdate %dD_m_CY
drop RTRegDate
label var rtdate "RTRegDate"

** ST Reviewer
destring streviewer, replace
label var streviewer "STReviewer"
label define streviewer_lab 0 "Pending" 1 "JC" 2 "LM" 3 "PP" 4 "AR" 5 "AH" 6 "JK" 7 "TM" 8 "SAW" 9 "SAF" 99 "Unknown", modify
label values streviewer streviewer_lab

** CanReg5 ID
label var cr5id "CanReg5 ID"

count //16,022

save "`datapath'\version05\2-working\2008-2020_cancer_dp" ,replace
label data "BNR-Cancer prepared 2008-2020 data"
notes _dta :These data prepared for 2016 pre-cleaning death matching for further retrieval and DCO trace-back (2016 annual report)

** Change name format to match death data
replace fname=lower(fname) //16,022 changes
replace fname = lower(rtrim(ltrim(itrim(fname)))) //424 changes
replace lname=lower(lname) //16,022 changes
replace lname = lower(rtrim(ltrim(itrim(lname)))) //598 changes

** Look for matches
sort lname fname pid
quietly by lname fname : gen dupname = cond(_N==1,0,_n)
sort lname fname pid
count if dupname>0 //11,218

order pid fname lname natregno
drop if dupname>1 //7,052 deleted

** Merge 2016 death dataset from 10_prep mort.do from 2015AnnualReportV02 branch
merge m:1 lname fname natregno using "`datapath'\version05\3-output\2016_deaths_for_matching"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                        10,785
        from master                     8,633  (_merge==1)
        from using                      2,152  (_merge==2)

    matched                               337  (_merge==3)
    -----------------------------------------
*/
** Check the merges

** Look for matches
drop dupname 
sort lname fname record_id
quietly by lname fname : gen dupname = cond(_N==1,0,_n)
sort lname fname record_id
count if dupname>0 //550

order pid record_id fname lname natregno namematch primarysite hx coddeath cr5cod

** Remove non-cancer CODs from death data
drop if cancer!=1 & pid=="" //1,819 deleted

** Check for cancer deaths that didn't merge
count if _merge==2 //331
count if _merge==2 & dupname==0 //170

** Flag cases that didn't merge but should have but first
** repeat name matching code above; if not the non-cancer deaths that were dropped will still be flagged in this list
drop dupname 
sort lname fname record_id
quietly by lname fname : gen dupname = cond(_N==1,0,_n)
sort lname fname record_id
count if dupname>0 //319

list pid record_id fname lname natregno if dupname>0 //319

** Visually check the list above in Stata Browse/Editor to see if name matches don't have a corresponding pid and record_id
** These will be classified as possible missed DCO matches
/*
gen notdco=1 if record_id==26147|record_id==25207|record_id==25932|record_id==24781|record_id==25410| ///
				record_id==24547|record_id==26907|record_id==24191|record_id==24446|record_id==26013| ///
				record_id==24820|record_id==26772|record_id==25045|record_id==26156|record_id==26517| ///
				record_id==24587|record_id==25461|record_id==24773|record_id==25858|record_id==25332| ///
				record_id==25323|record_id==26216|record_id==25174|record_id==25960|record_id==26043| ///
				record_id==24887|record_id==26175|record_id==26156
replace notdco=1 if pid=="20180391"|pid=="20180697"|pid=="20151150"|pid=="20180039"|pid=="20180218"| ///
				pid=="20181066"|pid=="20140911"|pid=="20080728"|pid=="20140975"|pid=="20182135"| ///
				pid=="20181096"|pid=="20180377"|pid=="20180577"|pid=="20155016"|pid=="20180789"| ///
				pid=="20180107"|pid=="20180741"|pid=="20181082"|pid=="20141059"|pid=="20180588"| ///
				pid=="20141176"|pid=="20180596"|pid=="20180159"|pid=="20180227"|pid=="20150020"| ///
				pid=="20180570"|pid=="20181178"|pid=="20155016" 
				//27 changes
*/
gen missedmatch=1 if dupname>0 //319 changes
** check those that merged that they're correct - added pid=20155016 (record_id=25083; record_id=26156) which seems to have merged to wrong pt based on CODs so I think NRN in CR5db for that pid is incorrect

** Check for ones that merged but are noted as not deceased in CR5db
** These will be classified as matched but alive
count if _merge==3 & slc!=2
gen alivematch=1 if _merge==3 & slc!=2 //38 changes

** Check for ones that did not merge but have cancer COD
gen dco=1 if record_id!=. & missedmatch!=1 & pid=="" // changes

** Check for matches using natregno
preserve
drop if natregno==""|natregno=="999999-9999"|regexm(natregno,"9999")
sort natregno 
quietly by natregno : gen dupnrn = cond(_N==1,0,_n)
sort natregno record_id lname fname
count if dupnrn>0 //61
list pid record_id fname lname natregno missedmatch dco if dupnrn>0
restore

** After reviewing above list, classify the NRN matches as possible missed DCO matches
replace missedmatch=1 if record_id==19831|record_id==19517|record_id==21074|record_id==21763|record_id==19515| ///
					record_id==20843|record_id==19966|record_id==20749|record_id==20845|record_id==20497| ///
					record_id==19783|record_id==20051|record_id==20093|record_id==20211|record_id==19596| ///
					record_id==20531|record_id==20575|record_id==19866|record_id==21628|record_id==20006| ///
					record_id==21560|record_id==20107|record_id==21004|record_id==20760|record_id==19729| ///
					record_id==20758|record_id==20249
					//25 changes
replace missedmatch=1 if pid=="20151323"|pid=="20161083"|pid=="20080295"|pid=="20162038"|pid=="20190249"| ///
					pid=="20190331"|pid=="20141398"|pid=="20151134"|pid=="20160525"|pid=="20155214"| ///
					pid=="20160197"|pid=="20141477"|pid=="20161090"|pid=="20130395"|pid=="20150031"| ///
					pid=="20161101"|pid=="20160118"|pid=="20160092"|pid=="20151365"|pid=="20160731"| ///
					pid=="20151274"|pid=="20141283"|pid=="20160880"|pid=="20160917"|pid=="20160091"| ///
					pid=="20160977"|pid=="20160662"|pid=="20155213"|pid=="20160127"|pid=="20200267"| ///
					pid=="20200248"|pid=="20151321"
					//32 changes
**replace missedmatch=1 if dupnrn>0

**drop if pid=="20080667" //2 deleted - these are patient records that were merged in CR5db so there are 2 CR5db patient records for this same person

replace dco=. if missedmatch==1 //25 changes

gen dcotxt="possible DCOs: Check CR5db (all years) if this case definitely has not been previously captured." if dco==1
gen missedmatchtxt="possible missed DCO match: (1) Check CR5db (all years) and REDCapdb 2008-2020 db if this is definitely the same patient - Note that the list is sorted by LastName, FirstName, NRN so if the name appears to be alone, check by NRN to find the corresponding possible match. (2) Update any CR5db fields based on the death data, e.g. SLC, DLC, NRN, Address, etc. (3) Check for any possible missed merges in CR5db (first and last names maybe switched) and merge these cases and update the records accordingly." if missedmatch==1
gen alivematchtxt="alive match: Cases merged with death data but SLC in CR5db not = deceased: (1) Check CR5db (all years) and REDCapdb 2008-2020 db if this is definitely the same patient. (2) Update any CR5db fields based on the death data, e.g. SLC, DLC, NRN, Address, etc." if alivematch==1

/* 
	Create 3 lists for KWG:
	 (1) those that are possible missed DCO matches but didn't merge so he can check the death fields are correct in CR5db (export natregno slc dlc fields); 
	 (2) those for DCOs (i.e. cancer CODs) not found in CR5db
	 (3) those that merged but are not listed as deceased in CR5db
*/
sort lname fname natregno 
** Change version for below lists before re-running this dofile!
** Use below code to automate file names using current date
local listdate = string( d(`c(current_date)'), "%dCYND" )
/*
capture export_excel dcotxt missedmatchtxt alivematchtxt if dco==1|missedmatch==1|alivematch==1 using "`datapath'\version05\3-output\precleanDCO2016V01_`listdate'.xlsx", sheet("Instructions") firstrow(variables)
capture export_excel pid record_id fname lname natregno slc dlc dod if dco==1 using "`datapath'\version05\3-output\precleanDCO2016V01_`listdate'.xlsx", sheet("2016 possible DCOs") firstrow(variables)
capture export_excel pid record_id fname lname natregno slc dlc dod if missedmatch==1 using "`datapath'\version05\3-output\precleanDCO2016V01_`listdate'.xlsx", sheet("2016 missed DCO match") firstrow(variables)
capture export_excel pid record_id fname lname natregno slc dlc dod if alivematch==1 using "`datapath'\version05\3-output\precleanDCO2016V01_`listdate'.xlsx", sheet("2016 alive match") firstrow(variables)
*/
