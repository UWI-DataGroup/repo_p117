** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          15a_clean criccs.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      04-NOV-2021
    // 	date last modified      04-NOV-2021
    //  algorithm task          Preparing 2016-2018 CRICCS cancer dataset for cleaning (age<20); Preparing previous years for combined dataset
    //  status                  Completed
    //  objective               To have one dataset with cleaned and grouped 2013-2018 data for inclusion in the CRICCS submission.
    //  methods                 Clean and update all years' data using IARCcrgTools Check and Multiple Primary

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
    log using "`logpath'\15_clean cancer.smcl", replace
** HEADER -----------------------------------------------------

** Import cancer incidence data from main CR5db
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
 
 All extra sources and duplicate tumours were removed.
 
 All data run in IARCcrgTools - 20150093 is a MP but T1 already in Stata dataset for 16_final clean.do so will exclude it here for now.
*/
import excel using "`datapath'\version02\1-input\2021-11-04_Source+Tumour+Patient_CRICCSformatted_JC_excel.xlsx", firstrow

** Format incidence date to create tumour year
nsplit IncidenceDate, digits(4 2 2) gen(dotyear dotmonth dotday)
gen dot=mdy(dotmonth, dotday, dotyear)
format dot %dD_m_CY
gen dotyear2 = year(dot)
label var dot "IncidenceDate"
label var dotyear "Incidence year"
drop IncidenceDate

count //24

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
rename TNMCatStage tnmcat
rename TNMAntStage tnmant
rename EssTNMCatStage esstnmcat
rename EssTNMAntStage esstnmant
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
** contains a nonnumeric character so field needs correcting!
label var ptda "PTDataAbstractor"
** contains a nonnumeric character so field needs correcting!
generate byte non_numeric_ptda = indexnot(ptda, "0123456789.-")
count if non_numeric_ptda //0
//list pid ptda cr5id if non_numeric_ptda
destring ptda,replace
count if ptda==. //0
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
nsplit birthdate, digits(4 2 2) gen(dobyear dobmonth dobday)
gen dob=mdy(dobmonth, dobday, dobyear)
format dob %dD_m_CY
label var dob "BirthDate"
tostring birthdate ,replace

** Sex
label var sex "Sex"
label define sex_lab 1 "Male" 2 "Female" 9 "Unknown", modify
label values sex sex_lab

** National Reg. No.
replace natregno=subinstr(natregno,"-","",.) if regexm(natregno,"-")
label var natregno "NRN"

** Hospital Number
tostring hospnum ,replace
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
** contains a nonnumeric character so field needs correcting!
generate byte non_numeric_ptrv = indexnot(ptreviewer, "0123456789.-")
count if non_numeric_ptrv //0
//list pid ptreviewer cr5id if non_numeric_ptrv
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
** DOES NOT contain a nonnumeric character so no correction needed
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
gen top = topography
destring topography, replace

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

** TNM Anatomical Stage
label var tnmant "Staging"
label define tnmantstage_lab 0 "0" 1 "I" 2 "II" 3 "III" 4 "IV", modify
label values tnmant tnmantstage_lab

** Essential TNM Anatomical Stage
label var esstnmant "Staging"
label define esstnmantstage_lab 0 "0" 1 "I" 2 "II" 3 "III" 4 "IV", modify
label values esstnmant esstnmantstage_lab

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

** Treatments 3- 5 has no observations so had to slightly adjust code
replace Treatment3Date=99999999 if Treatment3Date==.
replace Treatment3Date=20000101 if Treatment3Date==99999999
if Treatment3Date !=. nsplit Treatment3Date, digits(4 2 2) gen(rx3year rx3month rx3day)
if Treatment3Date !=. gen rx3d=mdy(rx3month, rx3day, rx3year)
if Treatment3Date !=. format rx3d %dD_m_CY
drop Treatment3Date
label var rx3d "Treatment3Date"

replace Treatment4Date=99999999 if Treatment4Date==.
replace Treatment4Date=20000101 if Treatment4Date==99999999
if Treatment4Date !=. nsplit Treatment4Date, digits(4 2 2) gen(rx4year rx4month rx4day)
if Treatment4Date !=. gen rx4d=mdy(rx4month, rx4day, rx4year)
if Treatment4Date !=. format rx4d %dD_m_CY
drop Treatment4Date
label var rx4d "Treatment4Date"

replace Treatment5Date=99999999 if Treatment5Date==.
replace Treatment5Date=20000101 if Treatment5Date==99999999
if Treatment5Date !=. nsplit Treatment5Date, digits(4 2 2) gen(rx5year rx5month rx5day)
if Treatment5Date !=. gen rx5d=mdy(rx5month, rx5day, rx5year)
if Treatment5Date !=. format rx5d %dD_m_CY
drop Treatment5Date
label var rx5d "Treatment5Date"

** Other Treatment 1
label var orx1 "OtherTreatment1"
label define orx_lab 1 "Cryotherapy" 2 "Laser therapy" 3 "Treated Abroad" ///
					 4 "Palliative therapy" 9 "Unknown" ,modify
label values orx1 orx_lab

** Other Treatment 2
tostring orx2 ,replace
label var orx2 "OtherTreatment2"

** No Treatments 1 and 2
label var norx1 "NoTreatment1"
label var norx2 "NoTreatment2"
label define norx_lab 1 "Alternative rx" 2 "Symptomatic rx" 3 "Died before rx" ///
					  4 "Refused rx" 5 "Postponed rx"  6 "Watchful waiting" ///
					  7 "Defaulted from care" 8 "NA" 9 "Unknown" ,modify
label values norx1 norx2 norx_lab

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
** contains a nonnumeric character so field needs correcting!
generate byte non_numeric_stda = indexnot(stda, "0123456789.-")
count if non_numeric_stda //0
//list pid stda cr5id if non_numeric_stda
destring stda,replace
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
						11 "Haem NF" 12 "Bay View Bk" 13 "Other" 14 "Unknown" 15 "NFs" 16 "Phone Call" 17 "MEDDATA" , modify
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
tostring labnum ,replace
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
tostring cytofinds ,replace
label var cytofinds "CytologicalFindings"

** Microscopic Description
label var md "MicroscopicDescription"

** Consultation Report
label var consrpt "ConsultationReport"

** Cause(s) of Death
label var cr5cod "CausesOfDeath"

** Duration of Illness
tostring duration ,replace
label var duration "DurationOfIllness"

** Onset to Death Interval
tostring onsetint ,replace
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

count //23

drop non_numeric*

***********************
*  Consistency Check  *
*	  Categories      *
***********************
** Create categories for topography according to groupings in ICD-O-3 book
gen topcat=.
replace topcat=1 if topography>-1 & topography<19
replace topcat=2 if topography==19
replace topcat=3 if topography>19 & topography<30
replace topcat=4 if topography>29 & topography<40
replace topcat=5 if topography>39 & topography<50
replace topcat=6 if topography>49 & topography<60
replace topcat=7 if topography>59 & topography<79
replace topcat=8 if topography==79
replace topcat=9 if topography>79 & topography<90
replace topcat=10 if topography>89 & topography<100
replace topcat=11 if topography>99 & topography<110
replace topcat=12 if topography>109 & topography<129
replace topcat=13 if topography==129
replace topcat=14 if topography>129 & topography<140
replace topcat=15 if topography>139 & topography<150
replace topcat=16 if topography>149 & topography<160
replace topcat=17 if topography>159 & topography<170
replace topcat=18 if topography>169 & topography<180
replace topcat=19 if topography>179 & topography<199
replace topcat=20 if topography==199
replace topcat=21 if topography==209
replace topcat=22 if topography>209 & topography<220
replace topcat=23 if topography>219 & topography<239
replace topcat=24 if topography==239
replace topcat=25 if topography>239 & topography<250
replace topcat=26 if topography>249 & topography<260
replace topcat=27 if topography>259 & topography<300
replace topcat=28 if topography>299 & topography<310
replace topcat=29 if topography>309 & topography<320
replace topcat=30 if topography>319 & topography<339
replace topcat=31 if topography==339
replace topcat=32 if topography>339 & topography<379
replace topcat=33 if topography==379
replace topcat=34 if topography>379 & topography<390
replace topcat=35 if topography>389 & topography<400
replace topcat=36 if topography>399 & topography<410
replace topcat=37 if topography>409 & topography<420
replace topcat=38 if topography>419 & topography<440
replace topcat=39 if topography>439 & topography<470
replace topcat=40 if topography>469 & topography<480
replace topcat=41 if topography>479 & topography<490
replace topcat=42 if topography>489 & topography<500
replace topcat=43 if topography>499 & topography<510
replace topcat=44 if topography>509 & topography<529
replace topcat=45 if topography==529
replace topcat=46 if topography>529 & topography<540
replace topcat=47 if topography>539 & topography<559
replace topcat=48 if topography==559
replace topcat=49 if topography==569
replace topcat=50 if topography>569 & topography<589
replace topcat=51 if topography==589
replace topcat=52 if topography>599 & topography<619
replace topcat=53 if topography==619
replace topcat=54 if topography>619 & topography<630
replace topcat=55 if topography>629 & topography<649
replace topcat=56 if topography==649
replace topcat=57 if topography==659
replace topcat=58 if topography==669
replace topcat=59 if topography>669 & topography<680
replace topcat=60 if topography>679 & topography<690
replace topcat=61 if topography>689 & topography<700
replace topcat=62 if topography>699 & topography<710
replace topcat=63 if topography>709 & topography<720
replace topcat=64 if topography>719 & topography<739
replace topcat=65 if topography==739
replace topcat=66 if topography>739 & topography<750
replace topcat=67 if topography>749 & topography<760
replace topcat=68 if topography>759 & topography<770
replace topcat=69 if topography>769 & topography<809
replace topcat=70 if topography==809
label var topcat "Topography Category"
label define topcat_lab 1 "Lip" 2 "Tongue-Base" 3 "Tongue-Other" 4 "Gum" 5 "Mouth-Floor" 6 "Palate" 7 "Mouth-Other" 8 "Parotid Gland" 9 "Major Saliva. Glands" ///
						10 "Tonsil" 11 "Oropharynx" 12 "Nasopharynx" 13 "Pyriform Sinus" 14 "Hypopharynx" 15 "Lip/Orocavity/Pharynx" 16 "Esophagus" 17 "Stomach" ///
						18 "Small Intestine" 19 "Colon" 20 "Rectosigmoid" 21 "Rectum" 22 "Anus" 23 "Liver/intrahep.ducts" 24 "Gallbladder" 25 "Biliary Tract-Other" ///
						26 "Pancreas" 27 "Digestive-Other" 28 "Nasocavity/Ear" 29 "Accessory Sinuses" 30 "Larynx" 31 "Trachea" 32 "Bronchus/Lung" 33 "Thymus" ///
						34 "Heart/Mediastinum/Pleura" 35 "Resp.System-Other" 36 "Bone/Joints/Cartilage-Limbs" 37 "Bone/Joints/Cartilage-Other" 38 "Heme/Reticulo." ///
						39 "Skin" 40 "Peripheral Nerves/ANS" 41 "Retro./Peritoneum" 42 "Connect./Subcutan.Soft Tissues" 43 "Breast" 44 "Vulva" 45 "Vagina" 46 "Cervix" ///
						47 "Corpus" 48 "Uterus,NOS" 49 "Ovary" 50 "FGS-Other" 51 "Placenta" 52 "Penis" 53 "Prostate Gland" 54 "Testis" 55 "MSG-Other" 56 "Kidney" ///
						57 "Renal Pelvis" 58 "Ureter" 59 "Bladder" 60 "Urinary-Other" 61 "Eye" 62 "Meninges" 63 "Brain" 64 "Spinal Cord/CNS" 65 "Thyroid" 66 "Adrenal Gland" ///
						67 "Endocrine-Other" 68 "Other/Ill defined" 69 "LNs" 70 "PSU" ,modify
label values topcat topcat_lab

** Create category for primarysite/topography check
gen topcheckcat=.
replace topcheckcat=1 if regexm(primarysite, "LIP") & !(strmatch(strupper(primarysite), "*SKIN*")|strmatch(strupper(primarysite), "*CERVIX*")) & (topography>9&topography!=148)
replace topcheckcat=2 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==8
replace topcheckcat=3 if regexm(primarysite, "TONGUE") & (topography<19|topography>29)
replace topcheckcat=4 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==28
replace topcheckcat=5 if regexm(primarysite, "GUM") & (topography<30|topography>39) & !(strmatch(strupper(primarysite), "*SKIN*"))
replace topcheckcat=6 if regexm(primarysite, "PALATE") & (topography<40|topography>69)
replace topcheckcat=7 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==48
replace topcheckcat=8 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==58
replace topcheckcat=9 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==68
replace topcheckcat=10 if regexm(primarysite, "GLAND") & (topography<79|topography>89) & !(strmatch(strupper(primarysite), "*MINOR*")|strmatch(strupper(primarysite), "*PROSTATE*")|strmatch(strupper(primarysite), "*THYROID*")|strmatch(strupper(primarysite), "*PINEAL*")|strmatch(strupper(primarysite), "*PITUITARY*"))
replace topcheckcat=11 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==88
replace topcheckcat=12 if regexm(primarysite, "TONSIL") & (topography<90|topography>99)
replace topcheckcat=13 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==98
replace topcheckcat=14 if regexm(primarysite, "OROPHARYNX") & (topography<100|topography>109)
replace topcheckcat=15 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==108
replace topcheckcat=16 if regexm(primarysite, "NASOPHARYNX") & (topography<110|topography>119)
replace topcheckcat=17 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==118
replace topcheckcat=18 if regexm(primarysite, "PYRIFORM") & (topography!=129&topography!=148)
replace topcheckcat=19 if regexm(primarysite, "HYPOPHARYNX") & (topography<130|topography>139)
replace topcheckcat=20 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==138
replace topcheckcat=21 if (regexm(primarysite, "PHARYNX") & regexm(primarysite, "OVERLAP")) & (topography!=140&topography!=148)
replace topcheckcat=22 if regexm(primarysite, "WALDEYER") & topography!=142
replace topcheckcat=23 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==148
replace topcheckcat=24 if regexm(primarysite, "PHAGUS") & !(strmatch(strupper(primarysite), "*JUNCT*")) & (topography<150|topography>159)
replace topcheckcat=25 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==158
replace topcheckcat=26 if (regexm(primarysite, "GASTR") | regexm(primarysite, "STOMACH")) & !(strmatch(strupper(primarysite), "*GASTROINTESTINAL*")|strmatch(strupper(primarysite), "*ABDOMEN*")) & (topography<160|topography>169)
replace topcheckcat=27 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==168
replace topcheckcat=28 if (regexm(primarysite, "NUM") | regexm(primarysite, "SMALL")) & !(strmatch(strupper(primarysite), "*STERNUM*")|strmatch(strupper(primarysite), "*MEDIA*")|strmatch(strupper(primarysite), "*POSITION*")) & (topography<170|topography>179)
replace topcheckcat=29 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==178
replace topcheckcat=30 if regexm(primarysite, "COLON") & !(strmatch(strupper(primarysite), "*RECT*")) & (topography<180|topography>189)
replace topcheckcat=31 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==188
replace topcheckcat=32 if regexm(primarysite, "RECTO") & topography!=199
replace topcheckcat=33 if regexm(primarysite, "RECTUM") & !(strmatch(strupper(primarysite), "*AN*")) & topography!=209
replace topcheckcat=34 if regexm(primarysite, "ANUS") & !(strmatch(strupper(primarysite), "*RECT*")) & (topography<210|topography>212)
replace topcheckcat=35 if !(strmatch(strupper(primarysite), "*OVERLAP*")|strmatch(strupper(primarysite), "*RECT*")|strmatch(strupper(primarysite), "*AN*")|strmatch(strupper(primarysite), "*JUNCT*")) & topography==218
replace topcheckcat=36 if (regexm(primarysite, "LIVER")|regexm(primarysite, "HEPTO")) & !(strmatch(strupper(primarysite), "*GLAND*")) & (topography<220|topography>221)
replace topcheckcat=37 if regexm(primarysite, "GALL") & topography!=239
replace topcheckcat=38 if (regexm(primarysite, "BILI")|regexm(primarysite, "VATER")) & !(strmatch(strupper(primarysite), "*INTRAHEP*")) & (topography<240|topography>241&topography!=249)
replace topcheckcat=39 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==248
replace topcheckcat=40 if regexm(primarysite, "PANCREA") & !(strmatch(strupper(primarysite), "*ABDOMEN*")) & (topography<250|topography>259)
replace topcheckcat=41 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==258
replace topcheckcat=42 if (regexm(primarysite, "BOWEL") | regexm(primarysite, "INTESTIN")) & !(strmatch(strupper(primarysite), "*SMALL*")|strmatch(strupper(primarysite), "*GASTRO*")) & (topography!=260&topography!=269)
replace topcheckcat=43 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==268
replace topcheckcat=44 if regexm(primarysite, "NASAL") & !(strmatch(strupper(primarysite), "*SIN*")) & topography!=300
replace topcheckcat=45 if regexm(primarysite, "EAR") & !(strmatch(strupper(primarysite), "*SKIN*")|strmatch(strupper(primarysite), "*FOREARM*")) & topography!=301
replace topcheckcat=46 if regexm(primarysite, "SINUS") & !(strmatch(strupper(primarysite), "*INTRA*")|strmatch(strupper(primarysite), "*PHARYN*")) & (topography<310|topography>319)
replace topcheckcat=47 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==318
replace topcheckcat=48 if (regexm(primarysite, "GLOTT") | regexm(primarysite, "CORD")) & !(strmatch(strupper(primarysite), "*TRANS*")|strmatch(strupper(primarysite), "*CNS*")|strmatch(strupper(primarysite), "*SPINAL*")) & (topography<320|topography>329)
replace topcheckcat=49 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==328
replace topcheckcat=50 if regexm(primarysite, "TRACH") & topography!=339
replace topcheckcat=51 if (regexm(primarysite, "LUNG") | regexm(primarysite, "BRONCH")) & (topography<340|topography>349)
replace topcheckcat=52 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==348
replace topcheckcat=53 if regexm(primarysite, "THYMUS") & topography!=379
replace topcheckcat=54 if (regexm(primarysite, "HEART")|regexm(primarysite, "CARD")|regexm(primarysite, "STINUM")|regexm(primarysite, "PLEURA")) & !(strmatch(strupper(primarysite), "*GASTR*")|strmatch(strupper(primarysite), "*STOMACH*")) & (topography<380|topography>384)
replace topcheckcat=55 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==388
replace topcheckcat=56 if regexm(primarysite, "RESP") & topography!=390
replace topcheckcat=57 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==398
replace topcheckcat=58 if regexm(primarysite, "RESP") & topography!=399
replace topcheckcat=59 if regexm(primarysite, "BONE") & !(strmatch(strupper(primarysite), "*MARROW*")) & (topography<400|topography>419)
replace topcheckcat=60 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==408
replace topcheckcat=61 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==418
replace topcheckcat=62 if regexm(primarysite, "BLOOD") & !(strmatch(strupper(primarysite), "*MARROW*")) & topography!=420
replace topcheckcat=63 if regexm(primarysite, "MARROW") & topography!=421
replace topcheckcat=64 if regexm(primarysite, "SPLEEN") & topography!=422
replace topcheckcat=65 if regexm(primarysite, "RETICU") & topography!=423
replace topcheckcat=66 if regexm(primarysite, "POIETIC") & topography!=424
replace topcheckcat=67 if regexm(primarysite, "SKIN") & (topography<440|topography>449)
replace topcheckcat=68 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==448
replace topcheckcat=69 if regexm(primarysite, "NERV") & (topography<470|topography>479)
replace topcheckcat=70 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==478
replace topcheckcat=71 if regexm(primarysite, "PERITON") & !(strmatch(strupper(primarysite), "*NODE*")) & (topography<480|topography>482)
replace topcheckcat=72 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==488
replace topcheckcat=73 if regexm(primarysite, "TISSUE") & (topography<490|topography>499)
replace topcheckcat=74 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==498
replace topcheckcat=75 if regexm(primarysite, "BREAST") & !(strmatch(strupper(primarysite), "*SKIN*")) & (topography<500|topography>509)
replace topcheckcat=76 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==508
replace topcheckcat=77 if regexm(primarysite, "VULVA") & (topography<510|topography>519)
replace topcheckcat=78 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==518
replace topcheckcat=79 if regexm(primarysite, "VAGINA") & topography!=529
replace topcheckcat=80 if regexm(primarysite, "CERVIX") & (topography<530|topography>539)
replace topcheckcat=81 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==538
replace topcheckcat=82 if (regexm(primarysite, "UTERI")|regexm(primarysite, "METRIUM")) & !(strmatch(strupper(primarysite), "*CERVIX*")|strmatch(strupper(primarysite), "*UTERINE*")|strmatch(strupper(primarysite), "*OVARY*")) & (topography<540|topography>549)
replace topcheckcat=83 if regexm(primarysite, "UTERINE") & !(strmatch(strupper(primarysite), "*CERVIX*")|strmatch(strupper(primarysite), "*CORPUS*")) & topography!=559
replace topcheckcat=84 if regexm(primarysite, "OVARY") & topography!=569
replace topcheckcat=85 if (regexm(primarysite, "FALLOPIAN")|regexm(primarysite, "LIGAMENT")|regexm(primarysite, "ADNEXA")|regexm(primarysite, "FEMALE")) & (topography<570|topography>579)
replace topcheckcat=86 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==578
replace topcheckcat=87 if regexm(primarysite, "PLACENTA") & topography!=589
replace topcheckcat=88 if (regexm(primarysite, "PENIS")|regexm(primarysite, "FORESKIN")) & (topography<600|topography>609)
replace topcheckcat=89 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==608
replace topcheckcat=90 if regexm(primarysite, "PROSTATE") & topography!=619
replace topcheckcat=91 if regexm(primarysite, "TESTIS") & (topography<620|topography>629)
replace topcheckcat=92 if (regexm(primarysite, "EPI")|regexm(primarysite, "SPERM")|regexm(primarysite, "SCROT")|regexm(primarysite, "MALE")) & !(strmatch(strupper(primarysite), "*FEMALE*")) & (topography<630|topography>639)
replace topcheckcat=93 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==638
replace topcheckcat=94 if regexm(primarysite, "KIDNEY") & topography!=649
replace topcheckcat=95 if regexm(primarysite, "RENAL") & topography!=659
replace topcheckcat=96 if regexm(primarysite, "URETER") & !(strmatch(strupper(primarysite), "*BLADDER*")) & topography!=669
replace topcheckcat=97 if regexm(primarysite, "BLADDER") & !(strmatch(strupper(primarysite), "*GALL*")) & (topography<670|topography>679)
replace topcheckcat=98 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==678
replace topcheckcat=99 if (regexm(primarysite, "URETHRA")|regexm(primarysite, "URINARY")) & !(strmatch(strupper(primarysite), "*BLADDER*")) & (topography<680|topography>689)
replace topcheckcat=100 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==688
replace topcheckcat=101 if (regexm(primarysite, "EYE")|regexm(primarysite, "RETINA")|regexm(primarysite, "CORNEA")|regexm(primarysite, "LACRIMAL")|regexm(primarysite, "CILIARY")|regexm(primarysite, "CHOROID")|regexm(primarysite, "ORBIT")|regexm(primarysite, "CONJUNCTIVA")) & !(strmatch(strupper(primarysite), "*SKIN*")) & (topography<690|topography>699)
replace topcheckcat=102 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==698
replace topcheckcat=103 if regexm(primarysite, "MENINGE") & (topography<700|topography>709)
replace topcheckcat=104 if regexm(primarysite, "BRAIN") & !strmatch(strupper(primarysite), "*MENINGE*") & (topography<710|topography>719)
replace topcheckcat=105 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==718
replace topcheckcat=106 if (regexm(primarysite, "SPIN")|regexm(primarysite, "CAUDA")|regexm(primarysite, "NERV")) & (topography<720|topography>729)
replace topcheckcat=107 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==728
replace topcheckcat=108 if regexm(primarysite, "THYROID") & topography!=739
replace topcheckcat=109 if regexm(primarysite, "ADRENAL") & (topography<740|topography>749)
replace topcheckcat=110 if (regexm(primarysite, "PARATHYROID")|regexm(primarysite, "PITUITARY")|regexm(primarysite, "CRANIOPHARYNGEAL")|regexm(primarysite, "CAROTID")|regexm(primarysite, "ENDOCRINE")) & (topography<750|topography>759)
replace topcheckcat=111 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==758 
replace topcheckcat=112 if (regexm(primarysite, "NOS")|regexm(primarysite, "DEFINED")) & !(strmatch(strupper(primarysite), "*SKIN*")|strmatch(strupper(primarysite), "*NOSE*")|strmatch(strupper(primarysite), "*NOSTRIL*")|strmatch(strupper(primarysite), "*STOMACH*")|strmatch(strupper(primarysite), "*GENITAL*")|strmatch(strupper(primarysite), "*PENIS*")) & (topography<760|topography>767)
replace topcheckcat=113 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==768
replace topcheckcat=114 if regexm(primarysite, "NODE") & (topography<770|topography>779)
replace topcheckcat=115 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==778
replace topcheckcat=116 if regexm(primarysite, "UNKNOWN") & topography!=809
label var topcheckcat "PrimSite<>Top Check Category"
label define topcheckcat_lab 	1 "Check 1: Lip" 2 "Check 2: Lip-Overlap" 3 "Check 3: Tongue" 4 "Check 4: Tongue-Overlap" 5 "Check 5: Gum" 6 "Check 6: Mouth" ///
								7 "Check 7: Mouth-Overlap" 8 "Check 8: Palate-Overlap" 9 "Check 9: Mouth Other-Overlap" 10 "Check 10: Glands" 11 "Check 11: Glands-Overlap" ///
							   12 "Check 12: Tonsil" 13 "Check 13: Tonsil-Overlap" 14 "Check 14: Oropharynx" 15 "Check 15: Oropharynx-Overlap" 16 "Check 16: Nasopharynx" ///
							   17 "Check 17: Nasopharynx-Overlap" 18 "Check 18: Pyriform Sinus" 19 "Check 19: Hypopharynx" 20 "Check 20: Hypopharynx-Overlap" ///
							   21 "Check 21: Pharynx" 22 "Check 22: Waldeyer" 23 "Check 23: Lip/Orocavity/Pharynx-Overlap" 24 "Check 24: Esophagus" ///
							   25 "Check 25: Esophagus-Overlap" 26 "Check 26: Stomach" 27 "Check 27: Stomach-Overlap" 28 "Check 28: Small Intestine" ///
							   29 "Check 29: Small Intestine-Overlap" 30 "Check 30: Colon" 31 "Check 31: Colon-Overlap" 32 "Check 32: Rectosigmoid" 33 "Check 33: Rectum" ///
							   34 "Check 34: Anus" 35 "Check 35: Rectum/Anus-Overlap" 36 "Check 36: Liver/intrahep.ducts" 37 "Check 37: Gallbladder" ///
							   38 "Check 38: Biliary Tract-Other" 39 "Check 39: Biliary Tract-Overlap" 40 "Check 40: Pancreas" 41 "Check 41: Pancreas-Overlap" ///
							   42 "Check 42: Digestive-Other" 43 "Check 43: Digestive-Overlap" 44 "Check 44: Nasocavity/Ear" 45 "Check 45: Ear" ///
							   46 "Check 46: Accessory Sinuses" 47 "Check 47: Acc. Sinuses-Overlap" 48 "Check 48: Larynx" 49 "Check 49: Larynx-Overlap" ///
							   50 "Check 50: Trachea" 51 "Check 51: Bronchus/Lung" 53 "Check 52: Lung-Overlap" 53 "Check 53: Thymus" 54 "Check 54: Heart/Mediastinum/Pleura" ///
							   55 "Check 55: Heart/Mediastinum/Pleura-Overlap" 56 "Check 56: Resp.System-Other" 57 "Check 57: Resp.System-Overlap" ///
							   58 "Check 58: Resp.System-Ill defined" 59 "Check 59: Bone/Joints/Cartilage-Limbs" 60 "Check 60: Bone Limbs-Overlap" ///
							   61 "Check 61: Bone Other-Overlap" 62 "Check 62: Blood" 63 "Check 63: Bone Marrow" 64 "Check 64: Spleen" ///
							   65 "Check 65: Reticulo. System" 66 "Check 66: Haem. System" 67 "Check 67: Skin" 68 "Check 68: Skin-Overlap" ///
							   69 "Check 69: Peripheral Nerves/ANS" 70 "Check 70: Peri.Nerves/ANS-Overlap" 71 "Check 71: Retro./Peritoneum" ///
							   72 "Check 72: Retro/Peritoneum-Overlap" 73 "Check 73: Connect./Subcutan.Soft Tissues" ///
							   74 "Check 74: Con/Sub/Soft Tissue-Overlap" 75 "Check 75: Breast" 76 "Check 76: Breast-Overlap" 77 "Check 77: Vulva" ///
							   78 "Check 78: Vulva-Overlap" 79 "Check 79: Vagina" 80 "Check 80: Cervix" 81 "Check 81: Cervix-Overlap" ///
							   82 "Check 82: Corpus" 83 "Check 83: Uterus,NOS" 84 "Check 84: Ovary" 85 "Check 85: FGS-Other" ///
							   86 "Check 86: FGS-Overlap" 87 "Check 87: Placenta" 88 "Check 88: Penis" 89 "Check 89: Penis-Overlap" ///
							   90 "Check 90: Prostate Gland" 91 "Check 91: Testis" 92 "Check 92: MSG-Other" 93 "Check 93: MGS-Overlap" ///
							   94 "Check 94: Kidney" 95 "Check 95: Renal Pelvis" 96 "Check 96: Ureter" 97 "Check 97: Bladder" ///
							   98 "Check 98: Bladder-Overlap" 99 "Check 99: Urinary-Other" 100 "Check 100: Urinary-Overlap" 101 "Check 101: Eye" ///
							   102 "Check 102: Eye-Overlap" 103 "Check 103: Meninges" 104 "Check 104: Brain" 105 "Check 105: Brain-Overlap" ///
							   106 "Check 106: Spinal Cord/CNS" 107 "Check 107: Brain/CNS-Overlap" 108 "Check 108: Thyroid" ///
							   109 "Check 109: Adrenal Gland" 110 "Check 110: Endocrine-Other" 111 "Check 111: Endocrine-Overalp" ///
							   112 "Check 112: Other/Ill defined" 113 "Check 113: Ill-defined-Overlap" 114 "Check 114: LNs" ///
							   115 "Check 115: LNs-Overlap" 116 "Check 116: PSU" ,modify
label values topcheckcat topcheckcat_lab

** Create category for morphology according to groupings in ICD-O-3 book
gen morphcat=.
replace morphcat=1 if morph>7999 & morph<8006
replace morphcat=2 if morph>8009 & morph<8050
replace morphcat=3 if morph>8049 & morph<8090
replace morphcat=4 if morph>8089 & morph<8120
replace morphcat=5 if morph>8119 & morph<8140
replace morphcat=6 if morph>8139 & morph<8390
replace morphcat=7 if morph>8389 & morph<8430
replace morphcat=8 if morph>8429 & morph<8440
replace morphcat=9 if morph>8439 & morph<8500
replace morphcat=10 if morph>8499 & morph<8550
replace morphcat=11 if morph>8549 & morph<8560
replace morphcat=12 if morph>8559 & morph<8580
replace morphcat=13 if morph>8579 & morph<8590
replace morphcat=14 if morph>8589 & morph<8680
replace morphcat=15 if morph>8679 & morph<8720
replace morphcat=16 if morph>8719 & morph<8800
replace morphcat=17 if morph>8799 & morph<8810
replace morphcat=18 if morph>8809 & morph<8840
replace morphcat=19 if morph>8839 & morph<8850
replace morphcat=20 if morph>8849 & morph<8890
replace morphcat=21 if morph>8889 & morph<8930
replace morphcat=22 if morph>8929 & morph<9000
replace morphcat=23 if morph>8999 & morph<9040
replace morphcat=24 if morph>9039 & morph<9050
replace morphcat=25 if morph>9049 & morph<9060
replace morphcat=26 if morph>9059 & morph<9100
replace morphcat=27 if morph>9099 & morph<9110
replace morphcat=28 if morph>9109 & morph<9120
replace morphcat=29 if morph>9119 & morph<9170
replace morphcat=30 if morph>9169 & morph<9180
replace morphcat=31 if morph>9179 & morph<9250
replace morphcat=32 if morph>9249 & morph<9260
replace morphcat=33 if morph>9259 & morph<9270
replace morphcat=34 if morph>9269 & morph<9350
replace morphcat=35 if morph>9349 & morph<9380
replace morphcat=36 if morph>9379 & morph<9490
replace morphcat=37 if morph>9489 & morph<9530
replace morphcat=38 if morph>9529 & morph<9540
replace morphcat=39 if morph>9539 & morph<9580
replace morphcat=40 if morph>9579 & morph<9590
replace morphcat=41 if morph>9589 & morph<9650
replace morphcat=42 if morph>9649 & morph<9670
replace morphcat=43 if morph>9669 & morph<9700
replace morphcat=44 if morph>9699 & morph<9727
replace morphcat=45 if morph>9726 & morph<9731
replace morphcat=46 if morph>9730 & morph<9740
replace morphcat=47 if morph>9739 & morph<9750
replace morphcat=48 if morph>9749 & morph<9760
replace morphcat=49 if morph>9759 & morph<9800
replace morphcat=50 if morph>9799 & morph<9820
replace morphcat=51 if morph>9819 & morph<9840
replace morphcat=52 if morph>9839 & morph<9940
replace morphcat=53 if morph>9939 & morph<9950
replace morphcat=54 if morph>9949 & morph<9970
replace morphcat=55 if morph>9969 & morph<9980
replace morphcat=56 if morph>9979 & morph<9999
label var morphcat "Morphology Category"
label define morphcat_lab 1 "Neoplasms,NOS" 2 "Epithelial Neo.,NOS" 3 "Squamous C. Neo." 4 "Basal C. Neo." 5 "Transitional C. Ca" 6 "Adenoca." 7 "Adnex./Skin Appendage Neoplasms" ///
						  8 "Mucoepidermoid Neo." 9 "Cystic/Mucinous/Serous Neo." 10 "Ductal/Lobular Neo." 11 "Acinar C. Neo." 12 "Complex Epithelial Neo." ///
						  13 "Thymic Epithelial Neo." 14 "Specialized Gonadal Neo." 15 "Paragangliomas/Glomus Tum." 16 "Nevi/Melanomas" 17 "Soft Tissue Tum./Sar.,NOS" ///
						  18 "Fibromatous Neo." 19 "Myxomatous Neo." 20 "Lipmatous Neo." 21 "Myomatous Neo." 22 "Complex Mixed/Stromal Neo." 23 "Fibroepithelial Neo." ///
						  24 "Synovial-like Neo." 25 "Mesothelial Neo." 26 "Germ C. Neo." 27 "Trophoblastic Neo." 28 "Mesonephromas" 29 "Blood Vessel Tum." ///
						  30 "Lymphatic Vessel Tum." 31 "Osseous/Chondromatous Neo." 32 "Giant C. Tum." 33 "Misc. Bone Tum." 34 "Odontogenic Tum." 35 "Misc. Tum." ///
						  36 "Gliomas" 37 "Neuroepitheliomatous Neo." 38 "Meningiomas" 39 "Nerve Sheath Tum." 40 "Granular C. Tum/Alveolar Soft Part Sar." ///
						  41 "Malig. Lymphomas,NOS/Diffuse/Non-Hodgkin Lym." 42 "Hodgkin Lymph." 43 "Mature B-C. Lymph." 44 "Mature T/NK-C. Lymph." ///
						  45 "Precursor C. Lymphoblastic Lymph." 46 "Plasma C. Tum." 47 "Mast C. Tum." 48 "Neo.-Histiocytes/Accessory Lymph. C." 49 "Immunoproliferative Dis." ///
						  50 "Leukemias" 51 "Lymphoid Leukemias" 52 "Myeloid Leukemias" 53 "Leukemias-Other" 54 "Chronic Myeloproliferative Dis." 55 "Heme. Dis.-Other" ///
						  56 "Myelodysplastic Syndromes" ,modify
label values morphcat morphcat_lab

** Create category for histology/morphology check
gen morphcheckcat=.
replace morphcheckcat=1 if (regexm(hx, "UNDIFF")&regexm(hx, "CARCIN")) & morph!=8020
replace morphcheckcat=2 if !strmatch(strupper(hx), "*DIFF*") & morph==8020
replace morphcheckcat=3 if regexm(hx, "PAPIL") & (!strmatch(strupper(hx), "*ADENO*")&!strmatch(strupper(hx), "*SEROUS*")&!strmatch(strupper(hx), "*HURTHLE*")&!strmatch(strupper(hx), "*RENAL*")&!strmatch(strupper(hx), "*UROTHE*")&!strmatch(strupper(hx), "*FOLLIC*")) & morph!=8050
replace morphcheckcat=4 if regexm(hx, "PAPILLARY SEROUS") & (topcat!=49 & topcat!=41) & morph!=8460
replace morphcheckcat=5 if (regexm(hx, "PAPIL")&regexm(hx, "INTRA")) & morph!=8503
replace morphcheckcat=6 if regexm(hx, "KERATO") & morph!=8070
replace morphcheckcat=7 if (regexm(hx, "SQUAMOUS")&regexm(hx, "MICROINVAS")) & morph!=8076
replace morphcheckcat=8 if regexm(hx, "BOWEN") & !strmatch(strupper(hx), "*CLINICAL*") & (basis==6|basis==7|basis==8) & morph!=8081
replace morphcheckcat=9 if (regexm(hx, "ADENOID")&regexm(hx, "BASAL")) & morph!=8098
replace morphcheckcat=10 if (regexm(hx, "INFIL")&regexm(hx, "BASAL")) & !strmatch(strupper(hx), "*NODU*") & morph!=8092
replace morphcheckcat=11 if (regexm(hx, "SUPER")&regexm(hx, "BASAL")) & !strmatch(strupper(hx), "*NODU*") & (basis==6|basis==7|basis==8) & morph!=8091
replace morphcheckcat=12 if (regexm(hx, "SCLER")&regexm(hx, "BASAL")) & !strmatch(strupper(hx), "*NODU*") & morph!=8092
replace morphcheckcat=13 if (regexm(hx, "NODU")&regexm(hx, "BASAL")) & !strmatch(strupper(hx), "*CLINICAL*") & morph!=8097
replace morphcheckcat=14 if regexm(hx, "BASAL") & !strmatch(strupper(hx), "*NODU*") & morph==8097 
replace morphcheckcat=15 if (regexm(hx, "SQUA")&regexm(hx, "BASAL")) & !strmatch(strupper(hx), "*BASALOID*") & morph!=8094
replace morphcheckcat=16 if regexm(hx, "BASAL") & !strmatch(strupper(hx), "*SQUA*") & morph==8094
replace morphcheckcat=17 if (!strmatch(strupper(hx), "*TRANS*")&!strmatch(strupper(hx), "*UROTHE*")) & morph==8120
replace morphcheckcat=18 if (regexm(hx, "TRANSITION")|regexm(hx, "UROTHE")) & !strmatch(strupper(hx), "*PAPIL*") & morph!=8120
replace morphcheckcat=19 if (regexm(hx, "TRANS")|regexm(hx, "UROTHE")) & regexm(hx, "PAPIL") & morph!=8130
replace morphcheckcat=20 if (regexm(hx, "VILL")&regexm(hx, "ADENOM")) & !strmatch(strupper(hx), "*TUBUL*") & morph!=8261
replace morphcheckcat=21 if regexm(hx, "INTESTINAL") & !strmatch(strupper(hx), "*STROMA*") & morph!=8144
replace morphcheckcat=22 if regexm(hx, "VILLOGLANDULAR") & morph!=8263
replace morphcheckcat=23 if !strmatch(strupper(hx), "*CLEAR*") & morph==8310
replace morphcheckcat=24 if regexm(hx, "CLEAR") & !strmatch(strupper(hx), "*RENAL*") & morph!=8310
replace morphcheckcat=25 if (regexm(hx, "CYST")&regexm(hx, "RENAL")) & morph!=8316
replace morphcheckcat=26 if (regexm(hx, "CHROMO")&regexm(hx, "RENAL")) & morph!=8317
replace morphcheckcat=27 if (regexm(hx, "SARCO")&regexm(hx, "RENAL")) & morph!=8318
replace morphcheckcat=28 if regexm(hx, "FOLLIC") & (!strmatch(strupper(hx), "*MINIMAL*")&!strmatch(strupper(hx), "*PAPIL*")) & morph!=8330
replace morphcheckcat=29 if (regexm(hx, "FOLLIC")&regexm(hx, "MINIMAL")) & morph!=8335
replace morphcheckcat=30 if regexm(hx, "MICROCARCINOMA") & morph!=8341
replace morphcheckcat=31 if (!strmatch(strupper(hx), "*OID*")&!strmatch(strupper(hx), "*IOD*")) & morph==8380
replace morphcheckcat=32 if regexm(hx, "POROMA") & morph!=8409 & mptot<2
replace morphcheckcat=33 if regexm(hx, "SEROUS") & !strmatch(strupper(hx), "*PAPIL*") & morph!=8441
replace morphcheckcat=34 if regexm(hx, "MUCIN") & (!strmatch(strupper(hx), "*CERVI*")&!strmatch(strupper(hx), "*PROD*")&!strmatch(strupper(hx), "*SECRE*")&!strmatch(strupper(hx), "*DUCT*")) & morph!=8480
replace morphcheckcat=35 if (!strmatch(strupper(hx), "*MUCIN*")&!strmatch(strupper(hx), "*PERITONEI*")) & morph==8480
replace morphcheckcat=36 if (regexm(hx, "ACIN")&regexm(hx, "DUCT")) & morph!=8552
replace morphcheckcat=37 if ((regexm(hx, "INTRADUCT")&regexm(hx, "MICROPAP")) | (regexm(hx, "INTRADUCT")&regexm(hx, "CLING"))) & morph!=8507
replace morphcheckcat=38 if (!strmatch(strupper(hx), "*MICROPAP*")|!strmatch(strupper(hx), "*CLING*")) & morph==8507
replace morphcheckcat=39 if !strmatch(strupper(hx), "*DUCTULAR*") & morph==8521
replace morphcheckcat=40 if regexm(hx, "LOBUL") & !strmatch(strupper(hx), "*DUCT*") & morph!=8520
replace morphcheckcat=41 if (regexm(hx, "DUCT")&regexm(hx, "LOB")) & morph!=8522
replace morphcheckcat=42 if !strmatch(strupper(hx), "*ACIN*") & morph==8550
replace morphcheckcat=43 if !strmatch(strupper(hx), "*ADENOSQUA*") & morph==8560
replace morphcheckcat=44 if !strmatch(strupper(hx), "*THECOMA*") & morph==8600
replace morphcheckcat=45 if !strmatch(strupper(hx), "*SARCOMA*") & morph==8800
replace morphcheckcat=46 if (regexm(hx, "SPIN")&regexm(hx, "SARCOMA")) & morph!=8801
replace morphcheckcat=47 if (regexm(hx, "UNDIFF")&regexm(hx, "SARCOMA")) & morph!=8805
replace morphcheckcat=48 if regexm(hx, "FIBROSARCOMA") & (!strmatch(strupper(hx), "*MYXO*")&!strmatch(strupper(hx), "*DERMA*")&!strmatch(strupper(hx), "*MESOTHE*")) & morph!=8810
replace morphcheckcat=49 if (regexm(hx, "FIBROSARCOMA")&regexm(hx, "MYXO")) & morph!=8811
replace morphcheckcat=50 if (regexm(hx, "FIBRO")&regexm(hx, "HISTIOCYTOMA")) & morph!=8830
replace morphcheckcat=51 if (!strmatch(strupper(hx), "*DERMA*")&!strmatch(strupper(hx), "*FIBRO*")&!strmatch(strupper(hx), "*SARCOMA*")) & morph==8832
replace morphcheckcat=52 if (regexm(hx, "STROMAL")&regexm(hx, "SARCOMA")&regexm(hx, "HIGH")) & morph!=8930
replace morphcheckcat=53 if (regexm(hx, "STROMAL")&regexm(hx, "SARCOMA")&regexm(hx, "LOW")) & morph!=8931
replace morphcheckcat=54 if (regexm(hx, "GASTRO")&regexm(hx, "STROMAL")|regexm(hx, "GIST")) & morph!=8936
replace morphcheckcat=55 if (regexm(hx, "MIXED")&regexm(hx, "MULLER")) & !strmatch(strupper(hx), "*MESO*") & morph!=8950
replace morphcheckcat=56 if (regexm(hx, "MIXED")&regexm(hx, "MESO")) & morph!=8951
replace morphcheckcat=57 if (regexm(hx, "WILM")|regexm(hx, "NEPHR")) & morph!=8960
replace morphcheckcat=58 if regexm(hx, "MESOTHE") & (!strmatch(strupper(hx), "*FIBR*")&!strmatch(strupper(hx), "*SARC*")&!strmatch(strupper(hx), "*EPITHE*")&!strmatch(strupper(hx), "*PAPIL*")&!strmatch(strupper(hx), "*CYST*")) & morph!=9050
replace morphcheckcat=59 if (regexm(hx, "MESOTHE")&regexm(hx, "FIBR")|regexm(hx, "MESOTHE")&regexm(hx, "SARC")) & (!strmatch(strupper(hx), "*EPITHE*")&!strmatch(strupper(hx), "*PAPIL*")&!strmatch(strupper(hx), "*CYST*")) & morph!=9051
replace morphcheckcat=60 if (regexm(hx, "MESOTHE")&regexm(hx, "EPITHE")|regexm(hx, "MESOTHE")&regexm(hx, "PAPIL")) & (!strmatch(strupper(hx), "*FIBR*")&!strmatch(strupper(hx), "*SARC*")&!strmatch(strupper(hx), "*CYST*")) & morph!=9052
replace morphcheckcat=61 if (regexm(hx, "MESOTHE")&regexm(hx, "BIPHAS")) & morph!=9053
replace morphcheckcat=62 if regexm(hx, "ADENOMATOID") & morph!=9054
replace morphcheckcat=63 if (regexm(hx, "MESOTHE")&regexm(hx, "CYST")) & morph!=9055
replace morphcheckcat=64 if regexm(hx, "YOLK") & morph!=9071
replace morphcheckcat=65 if regexm(hx, "TERATOMA") & morph!=9080
replace morphcheckcat=66 if regexm(hx, "TERATOMA") & (!strmatch(strupper(hx), "*METAS*")&!strmatch(strupper(hx), "*MALIG*")&!strmatch(strupper(hx), "*EMBRY*")&!strmatch(strupper(hx), "*BLAST*")&!strmatch(strupper(hx), "*IMMAT*")) & morph==9080
replace morphcheckcat=67 if regexm(hx, "MOLE") & !strmatch(strupper(hx), "*CHORIO*") & beh==3 & morph==9100
replace morphcheckcat=68 if regexm(hx, "CHORIO") & morph!=9100
replace morphcheckcat=69 if (regexm(hx, "EPITHE")&regexm(hx, "HEMANGIOENDOTHELIOMA")) & !strmatch(strupper(hx), "*MALIG*") & morph==9133
replace morphcheckcat=70 if regexm(hx, "OSTEOSARC") & morph!=9180
replace morphcheckcat=71 if regexm(hx, "CHONDROSARC") & morph!=9220
replace morphcheckcat=72 if regexm(hx, "MYXOID") & !strmatch(strupper(hx), "*CHONDROSARC*") & morph==9231
replace morphcheckcat=73 if regexm(hx, "RETINOBLASTOMA") & (regexm(hx, "POORLY")|regexm(hx, "UNDIFF")) & morph==9511
replace morphcheckcat=74 if regexm(hx, "MENINGIOMA") & (!strmatch(strupper(hx), "*THELI*")&!strmatch(strupper(hx), "*SYN*")) & morph==9531
replace morphcheckcat=75 if (regexm(hx, "MANTLE")&regexm(hx, "LYMPH")) & morph!=9673
replace morphcheckcat=76 if (regexm(hx, "T CELL")&regexm(hx, "LYMPH")|regexm(hx, "T-CELL")&regexm(hx, "LYMPH")) & (!strmatch(strupper(hx), "*LEU*")&!strmatch(strupper(hx), "*HTLV*")&!strmatch(strupper(hx), "*CUTANE*")) & morph!=9702
replace morphcheckcat=77 if (regexm(hx, "NON")&regexm(hx, "HODGKIN")&regexm(hx, "LYMPH")) & !strmatch(strupper(hx), "*CELL*") & morph!=9591
replace morphcheckcat=78 if (regexm(hx, "PRE")&regexm(hx, "T CELL")&regexm(hx, "LYMPH")&regexm(hx, "LEU")|regexm(hx, "PRE")&regexm(hx, "T-CELL")&regexm(hx, "LYMPH")&regexm(hx, "LEU")) & morph!=9837
replace morphcheckcat=79 if (hx=="CHRONIC MYELOGENOUS LEUKAEMIA"|hx=="CHRONIC MYELOGENOUS LEUKEMIA"|hx=="CHRONIC MYELOID LEUKAEMIA"|hx=="CHRONIC MYELOID LEUKEMIA"|hx=="CML") & morph!=9863
replace morphcheckcat=80 if (regexm(hx, "CHRON")&regexm(hx, "MYELO")&regexm(hx, "LEU")) & (!strmatch(strupper(hx), "*BCR*")|!strmatch(strupper(hx), "*ABL1*")) & morph==9875
replace morphcheckcat=81 if (regexm(hx, "ACUTE")&regexm(hx, "MYELOID")&regexm(hx, "LEU")) & (!strmatch(strupper(hx), "*DYSPLAST*")&!strmatch(strupper(hx), "*DOWN*")) & (basis>4&basis<9) & morph!=9861
replace morphcheckcat=82 if (regexm(hx, "DOWN")&regexm(hx, "MYELOID")&regexm(hx, "LEU")) & morph!=9898
replace morphcheckcat=83 if (regexm(hx, "SECOND")&regexm(hx, "MYELOFIBR")) & recstatus!=3 & (morph==9931|morph==9961)
replace morphcheckcat=84 if regexm(hx, "POLYCYTHEMIA") & (!strmatch(strupper(hx), "*VERA*")&!strmatch(strupper(hx), "*PROLIF*")&!strmatch(strupper(hx), "*PRIMARY*")) & morph==9950
replace morphcheckcat=85 if regexm(hx, "MYELOPROLIFERATIVE") & !strmatch(strupper(hx), "*ESSENTIAL*") & dxyr<2010 & morph==9975
replace morphcheckcat=86 if regexm(hx, "MYELOPROLIFERATIVE") & !strmatch(strupper(hx), "*ESSENTIAL*") & dxyr>2009 & morph==9960
replace morphcheckcat=87 if (regexm(hx, "REFRACTORY")&regexm(hx, "AN")) & (!strmatch(strupper(hx), "*SIDERO*")&!strmatch(strupper(hx), "*BLAST*")) & morph!=9980
replace morphcheckcat=88 if (regexm(hx, "REFRACTORY")&regexm(hx, "AN")&regexm(hx, "SIDERO")) & !strmatch(strupper(hx), "*EXCESS*") & morph!=9982
replace morphcheckcat=89 if (regexm(hx, "REFRACTORY")&regexm(hx, "AN")&regexm(hx, "EXCESS")) & !strmatch(strupper(hx), "*SIDERO*") & morph!=9983
replace morphcheckcat=90 if regexm(hx, "MYELODYSPLASIA") & !strmatch(strupper(hx), "*SYNDROME*") & recstatus!=3 & morph==9989
replace morphcheckcat=91 if regexm(hx, "ACIN") & topography!=619 & morph!=8550
replace morphcheckcat=92 if (!strmatch(strupper(hx), "*FIBRO*")|!strmatch(strupper(hx), "*HISTIOCYTOMA*")) & morph==8830
replace morphcheckcat=93 if regexm(hx, "ACIN") & topography==619 & morph!=8140
replace morphcheckcat=94 if (morph>9582 & morph<9650) & !strmatch(strupper(hx), "*NON*") & regexm(hx, "HODGKIN")
replace morphcheckcat=95 if morph==9729 & regexm(hx,"LEU")
replace morphcheckcat=96 if morph==9837 & regexm(hx,"OMA")

label var morphcheckcat "Hx<>Morph Check Category"
label define morphcheckcat_lab 	1 "Check 1: Hx=Undifferentiated Ca & Morph!=8020" 2 "Check 2: Hx!=Undifferentiated Ca & Morph==8020" 3 "Check 3: Hx=Papillary ca & Morph!=8050" ///
								4 "Check 4: Hx=Papillary serous adenoca & Morph!=8460" 5 "Check 5: Hx=Papillary & intraduct/intracyst & Morph!=8503" ///
								6 "Check 6: Hx=Keratoacanthoma & Morph!=8070" 7 "Check 7: Hx=Squamous & microinvasive & Morph!=8076" ///
								8 "Check 8: Hx=Bowen & morph!=8081" 9 "Check 9: Hx=adenoid BCC & morph!=8098" 10 "Check 10: Hx=infiltrating BCC excluding nodular & morph!=8092" ///
								11 "Check 11: Hx=superficial BCC excluding nodular & basis=6/7/8 & morph!=8091" 12 "Check 12: Hx=sclerotic/sclerosing BCC excluding nodular & morph!=8091" ///
								13 "Check 13: Hx=nodular BCC excluding clinical & morph!=8097" 14 "Check 14: Hx!=nodular BCC & morph==8097" ///
								15 "Check 15: Hx=BCC & SCC excluding basaloid & morph!=8094" 16 "Check 16: Hx!=BCC & SCC & morph==8094" 17 "Check 17: Hx!=transitional/urothelial & morph==8120" ///
								18 "Check 18: Hx=transitional/urothelial excluding papillary & morph!=8120" 19 "Check 19: Hx=transitional/urothelial & papillary & morph!=8130" ///
								20 "Check 20: Hx=villous & adenoma excl. tubulo & morph!=8261" 21 "Check 21: Hx=intestinal excl. stromal(GISTs) & morph!=8144" ///
								22 "Check 22: Hx=villoglandular & morph!=8263" 23 "Check 23: Hx!=clear cell & morph==8310" 24 "Check 24: Hx==clear cell & morph!=8310" ///
								25 "Check 25: Hx==cyst & renal & morph!=8316" 26 "Check 26: Hx==chromophobe & renal & morph!=8317" ///
								27 "Check 27: Hx==sarcomatoid & renal & morph!=8318" 28 "Check 28: Hx==follicular excl.minimally invasive & morph!=8330" ///
								29 "Check 29: Hx==follicular & minimally invasive & morph!=8335" 30 "Check 30: Hx==microcarcinoma & morph!=8341" ///
								31 "Check 31: Hx!=endometrioid & morph==8380" 32 "Check 32: Hx==poroma & morph!=8409 & mptot<2" ///
								33 "Check 33: Hx==serous excl. papillary & morph!=8441" 34 "Check 34: Hx=mucinous excl. endocervical,producing,secreting,infil.duct & morph!=8480" ///
								35 "Check 35: Hx!=mucinous & morph==8480" 36 "Check 36: Hx==acinar & duct & morph!=8552" ///
								37 "Check 37: Hx==intraduct & micropapillary or intraduct & clinging & morph!=8507" ///
								38 "Check 28: Hx!=intraduct & micropapillary or intraduct & clinging & morph==8507" 39 "Check 39: Hx!=ductular & morph==8521" ///
								40 "Check 40: Hx!=duct & Hx==lobular & morph!=8520" 41 "Check 41: Hx==duct & lobular & morph!=8522" ///
								42 "Check 42: Hx!=acinar & morph==8550" 43 "Check 43: Hx!=adenosquamous & morph==8560" 44 "Check 44: Hx!=thecoma & morph==8600" ///
								45 "Check 45: Hx!=sarcoma & morph==8800" 46 "Check 46: Hx=spindle & sarcoma & morph!=8801" ///
								47 "Check 47: Hx=undifferentiated & sarcoma & morph!=8805" 48 "Check 48: Hx=fibrosarcoma & Hx!=myxo or dermato & morph!=8810" ///
								49 "Check 49: Hx=fibrosarcoma & Hx=myxo & morph!=8811" 50 "Check 50: Hx=fibro & histiocytoma & morph!=8830" ///
								51 "Check 51: Hx!=dermatofibrosarcoma & morph==8832" 52 "Check 52: Hx==stromal sarcoma high grade & morph!=8930" ///
								53 "Check 53: Hx==stromal sarcoma low grade & morph!=8931" 54 "Check 54: Hx==gastrointestinal stromal tumour & morph!=8936" ///
								55 "Check 55: Hx==mixed mullerian tumour & Hx!=mesodermal & morph!=8950" 56 "Check 56: Hx==mesodermal mixed & morph!=8951" ///
								57 "Check 57: Hx==wilms or nephro & morph!=8960" ///
								58 "Check 58: Hx==mesothelioma & Hx!=fibrous or sarcoma or epithelioid/papillary or cystic & morph!=9050" ///
								59 "Check 59: Hx==fibrous or sarcomatoid mesothelioma & Hx!=epithelioid/papillary or cystic & morph!=9051" ///
								60 "Check 60: Hx==epitheliaoid or papillary mesothelioma & Hx!=fibrous or sarcomatoid or cystic & morph!=9052" ///
								61 "Check 61: Hx==biphasic mesothelioma & morph!=9053" 62 "Check 62: Hx==adenomatoid tumour & morph!=9054" ///
								63 "Check 63: Hx==cystic mesothelioma & morph!=9055" 64 "Check 64: Hx==yolk & morph!=9071" 65 "Check 65: Hx==teratoma & morph!=9080" ///
								66 "Check 66: Hx==teratoma & Hx!=metastatic or malignant or embryonal or teratoblastoma or immature & morph==9080" ///
								67 "Check 67: Hx==complete hydatidiform mole & Hx!=choriocarcinoma & beh==3 & morph==9100" ///
								68 "Check 68: Hx==choriocarcinoma & morph!=9100" 69 "Check 69: Hx==epithelioid hemangioendothelioma & Hx!=malignant & morph==9133" ///
								70 "Check 70: Hx==osteosarcoma & morph!=9180" 71 "Check 71: Hx==chondrosarcoma & morph!=9220" ///
								72 "Check 72: Hx=myxoid and Hx!=chondrosarcoma & morph==9231" ///
								73 "Check 73: Hx=retinoblastoma and poorly or undifferentiated & morph==9511" ///
								74 "Check 74: Hx=meningioma & Hx!=meningothelial/endotheliomatous/syncytial & morph==9531" ///
								75 "Check 75: Hx=mantle cell lymphoma & morph!=9673" 76 "Check 76: Hx=T-cell lymphoma & Hx!=leukemia & morph!=9702" ///
								77 "Check 77: Hx=non-hodgkin lymphoma & Hx!=cell & morph!=9591" 78 "Check 78: Hx=precursor t-cell ALL & morph!=9837" ///
								79 "Check 79: Hx=CML (chronic myeloid/myelogenous leukemia) & Hx!=genetic studies & morph==9863" ///
								80 "Check 80: Hx=CML (chronic myeloid/myelogenous leukemia) & Hx!=BCR/ABL1 & morph==9875" ///
								81 "Check 81: Hx=acute myeloid leukemia & Hx!=myelodysplastic/down syndrome & basis==cyto/heme/histology... & morph!=9861" ///
								82 "Check 82: Hx=acute myeloid leukemia & down syndrome & morph!=9898" ///
								83 "Check 83: Hx=secondary myelofibrosis & recstatus!=3 & morph==9931 or 9961" ///
								84 "Check 84: Hx=polycythemia & Hx!=vera/proliferative/primary & morph==9950" ///
								85 "Check 85: Hx=myeloproliferative & Hx!=essential & dxyr<2010 & morph==9975" ///
								86 "Check 86: Hx=myeloproliferative & Hx!=essential & dxyr>2009 & morph==9960" ///
								87 "Check 87: Hx=refractory anemia & Hx!=sideroblast or blast & morph!=9980" ///
								88 "Check 88: Hx=refractory anemia & sideroblast & Hx!=excess blasts & morph!=9982" ///
								89 "Check 89: Hx=refractory anemia & excess blasts &  Hx!=sidero & morph!=9983" ///
								90 "Check 90: Hx=myelodysplasia & Hx!=syndrome & recstatus!=inelig. & morph==9989" 91 "Check 91: Hx=acinar & morph!=8550" ///
								92 "Check 92: Hx!=fibro & histiocytoma & morph=8830" 93 "Check 93: Hx=acinar & top=prostate & morph!=8140" ///
								94 "Check 94: Hx=hodgkin & morph=non-hodgkin" 95 "Check 95: Hx=leukaemia & morph=9729" 96 "Check 96: Hx=lymphoma & morph=9837" ,modify
label values morphcheckcat morphcheckcat_lab

** Create category for histology/primarysite check
gen hxcheckcat=.
replace hxcheckcat=1 if topcat==38 & (morphcat>40 & morphcat<46)
replace hxcheckcat=2 if topcat==33 & morphcat!=13 & !strmatch(strupper(hx), "*CARCINOMA*")
replace hxcheckcat=3 if topography!=421 & morphcat==56
replace hxcheckcat=4 if (regexm(hx, "PAPIL")&regexm(hx, "RENAL")) & topography!=739 & morph!=8260
replace hxcheckcat=5 if (regexm(hx, "PAPIL")&regexm(hx, "ADENO")) & !strmatch(strupper(hx), "*RENAL*") & topography==739 & morph!=8260
replace hxcheckcat=6 if (regexm(hx, "PAPILLARY")&regexm(hx, "SEROUS")) & (topcat==41|topcat==49) & morph!=8461
replace hxcheckcat=7 if (regexm(hx, "PAPILLARY")&regexm(hx, "SEROUS")) & topography==541 & morph!=8460
replace hxcheckcat=8 if regexm(hx, "PLASMA") & (topcat!=36&topcat!=37) & morph==9731
replace hxcheckcat=9 if regexm(hx, "PLASMA") & (topcat==36|topcat==37) & morph==9734
replace hxcheckcat=10 if topcat!=62 & morphcat==38
replace hxcheckcat=11 if topcat==38 & morph==9827
label var hxcheckcat "Hx<>PrimSite Check Category"
label define hxcheckcat_lab	1 "Check 1: PrimSite=Blood/Bone Marrow & Hx=Lymphoma" 2 "Check 2: PrimSite=Thymus & MorphCat!=Thymic epi.neo. & Hx!=carcinoma" ///
							3 "Check 3: PrimSite!=Bone Marrow & MorphCat==Myelodys." 4 "Check 4: PrimSite!=thyroid & Hx=Renal & Hx=Papillary ca & Morph!=8260" ///
							5 "Check 5: PrimSite==thyroid & Hx!=Renal & Hx=Papillary ca & adenoca & Morph!=8260" 6 "Check 6: PrimSite!=ovary/peritoneum & Hx=Papillary & Serous & Morph!=8461" ///
							7 "Check 7: PrimSite!=endometrium & Hx=Papillary & Serous & Morph!=8460" 8 "Check 8: PrimSite!=bone; Hx=plasmacytoma & Morph==9731(bone)" ///
							9 "Check 9: PrimSite==bone; Hx=plasmacytoma & Morph==9734(not bone)" 10 "Check 10: PrimSite!=meninges; Hx=meningioma" ///
							11 "Check 11: PrimSite=Blood/Bone Marrow & Hx=HTLV+T-cell Lymphoma" ,modify
label values hxcheckcat hxcheckcat_lab

** Create category for age/site/histology check: IARCcrgTools pg 6
gen agecheckcat=.
replace agecheckcat=1 if morphcat==42 & age<3
replace agecheckcat=2 if (morph==9490|morph==9500|morph==9522) & (age>9 & age<15)
replace agecheckcat=3 if (morph>9509 & morph<9515) & (age>5 & age<15)
replace agecheckcat=4 if (morph==8959|morph==8960) & (age>8 & age<15)
replace agecheckcat=5 if ((morph==8260 | morph==8361 | morph==8312 | morph>8315 & morph<8320) & age<9) | (topcat==56 & (morphcat!=4 & morphcat>1 & morphcat<13) & age<9)
replace agecheckcat=6 if morph==8970 & (age>5 & age<15)
replace agecheckcat=7 if ((morph>8159 & morph<8181) & age<9) | (topcat==23 & morph & (morphcat!=4 & morphcat>1 & morphcat<13) & age<9)
replace agecheckcat=8 if (morph>9179 & morph<9201) & (topcat==36|topcat==37|topcat==68|topcat==70) & age<6
replace agecheckcat=9 if ((morph>9220 & morph<9244) & age<6) | ((morph==9210|morph==9220|morph==9240) & (topcat==36|topcat==37|topcat==68|topcat==70) & age<6)
replace agecheckcat=10 if morph==9260 & age<4
replace agecheckcat=11 if (morphcat==26 | morphcat==27) & (topcat!=49 & topcat!=54) & (age>7 & age<15)
replace agecheckcat=12 if ((morph>8440 & morph<8445 | morph>8449 & morph<8452 | morph>8459 & morph<8474) & age<5) | ((topcat==54|topcat==55) & (morphcat!=4 & morphcat==23 & morphcat>1 & morphcat<13) & age<5)
replace agecheckcat=13 if ((morph>8329 & morph<8338 | morph>8339 & morph<8348 | morph==8350) & age<6) | (topcat==65 & (morphcat!=4 & morphcat>1 & morphcat<13) & age<6)
replace agecheckcat=14 if topcat==12 & (morphcat!=4 & morphcat>1 & morphcat<13) & age<6
replace agecheckcat=15 if topcat==39 & (morphcat>1 & morphcat<13 |morph==8940|morph==8941) & age<5
replace agecheckcat=16 if (morphcat==1|morphcat==2) & (topcat!=23 & topcat!=36 & topcat!=37 & topcat!=49 & topcat!=54 & topcat!=56 & topcat!=62 & topcat>64) & age<5
replace agecheckcat=17 if morphcat==25 & age<15
replace agecheckcat=18 if topcat==53 & morphcat==6 & age<40
replace agecheckcat=19 if ((topcat==16 | topcat>19 & topcat<23 | topcat==24 | topcat==25 | topcat==43 | topcat>45 & topcat<49) & age<20)  | (topography==384 & age<20)
replace agecheckcat=20 if topcat==18 & morph<9590 & age<20
replace agecheckcat=21 if (topcat==19 | topcat==31 | topcat==32) & (morph<8240 & morph>8249) & age<20
replace agecheckcat=22 if topcat==51 & morph==9100 & age>45
replace agecheckcat=23 if (morph==9732|morph==9823) & age<26
replace agecheckcat=24 if (morph==8910|morph==8960|morph==8970|morph==8981|morph==8991|morph==9072|morph==9470|morph==9490|morph==9500|morph==9687|morph>9509&morph<9520) & age>15
replace agecheckcat=25 if morph==9724 & age<15
label var agecheckcat "Age/Site/Hx Check Category"
label define agecheckcat_lab 1 "Check 1: Age<3 & Hx=Hodgkin Lymphoma" 2 "Check 2: Age 10-14 & Hx=Neuroblastoma" 3 "Check 3: Age 6-14 & Hx=Retinoblastoma" ///
							 4 "Check 4: Age 9-14 & Hx=Wilm's Tumour" 5 "Check 5: Age 0-8 & Hx=Renal carcinoma" 6 "Check 6: Age 6-14 & Hx=Hepatoblastoma" ///
							 7 "Check 7: Age 0-8 & Hx=Hepatic carcinoma" 8 "Check 8: Age 0-5 & Hx=Osteosarcoma" 9 "Check 9: Age 0-5 & Hx=Chondrosarcoma" ///
							 10 "Check 10: Age 0-3 & Hx=Ewing sarcoma" 11 "Check 11: Age 8-14 & Hx=Non-gonadal germ cell" 12 "Check 12: Age 0-4 & Hx=Gonadal carcinoma" ///
							 13 "Check 13: Age 0-5 & Hx=Thyroid carcinoma" 14 "Check 14: Age 0-5 & Hx=Nasopharyngeal carcinoma" 15 "Check 15: Age 0-4 & Hx=Skin carcinoma" ///
							 16 "Check 16: Age 0-4 & Hx=Carcinoma, NOS" 17 "Check 17: Age 0-14 & Hx=Mesothelial neoplasms" 18 "Check 18: Age <40 & Hx=814_ & Top=61_" ///
							 19 "Check 19: Age <20 & Top=15._,19._,20._,21._,23._,24._,38.4,50._53._,54._,55._" 20 "Check 20: Age <20 & Top=17._ & Morph<9590(ie.not lymphoma)" ///
							 21 "Check 21: Age <20 & Top=33._ or 34._ or 18._ & Morph!=824_(ie.not carcinoid)" 22 "Check 22: Age >45 & Top=58._ & Morph==9100(chorioca.)" ///
							 23 "Check 23: Age <26 & Morph==9732(myeloma) or 9823(BCLL)" 24 "Check 24: Age >15 & Morph==8910/8960/8970/8981/8991/9072/9470/9490/9500/951_/9687" ///
							 25 "Check 25: Age <15 & Morph==9724" ,modify
label values agecheckcat agecheckcat_lab

** Create category for histological family groups according to family number in IARCcrgTools Check Program Appendix 1 pgs 11-31
gen hxfamcat=.
** Group 1 - Tumours with non-specific site-profile
replace hxfamcat=1 if (morph>7999 & morph<8005) | (morphcat==41 & morph!=9597) | morphcat==42 | (morphcat==43 & morph!=9679 & morph!=9689) ///
					   | (morphcat==44 & morph!=9700 & morph!=9708 & morph!=9709 & morph!=9717 & morph!=9718 & morph!=9726) | morphcat==45 ///
					   | (morphcat==46 & morph!=9732 & morph!=9733 & morph!=9734) | (morphcat==47 & morph!=9742) | morphcat==48 ///
					   | (morphcat==49 & morph!=9761 & morph!=9764 & morph!=9765) | morph==9930 | morphcat==55				
** Group 2 - Tumours with specific site-profile
replace hxfamcat=2 if (morph==8561|morph==8974) & (topcat==8|topcat==9)
replace hxfamcat=3 if (morph==8142|morph==8214) & topcat==17
replace hxfamcat=4 if (morph==8683|morph==9764) & topcat==18
replace hxfamcat=5 if (morph==8213|morph==8220|morph==8261|morph==8265) & (topcat==19|topcat==20|topcat==21|topcat==27|topcat==70|topography==762|topography==763|topography==767|topography==768)
replace hxfamcat=6 if (morph==8124|morph==8215) & (topcat==21|topcat==22)
replace hxfamcat=7 if (morph==8144|morph==8145|morph==8221|morph==8936|morph==9717) & (topcat>15 & topcat<22|topcat==27|topcat==70|topography==762|topography==763|topography==767|topography==768)
replace hxfamcat=8 if (morph>8169 & morph<8176|morph==8970|morph==8975|morph==9124) & topcat==23
replace hxfamcat=9 if (morph>8159 & morph<8164|morph==8180|morph==8264) & (topcat>22 & topcat<26)
replace hxfamcat=10 if (morph>8149 & morph<8156 & morph!=8153|morph==8202|morph==8452|morph==8453|morph==8971) & topcat==26 
replace hxfamcat=11 if (morph>9519 & morph<9524) & (topcat==28|topcat==29) 
replace hxfamcat=12 if (morph>8039 & morph<8047|morph>8249 & morph<8256 & morph!=8251|morph==8012|morph==8827|morph==8972) & (topcat==32|topcat==35 & topography!=390|topography==761|topography==767|topography==768|topcat==70)
replace hxfamcat=13 if (morphcat==25 & morph!=9054|morph==8973) & (topcat==32|topography==483|topcat==35 & topography!=390|topcat==68 & topography!=760 & topography!=764 & topography!=765|topcat==70) 
replace hxfamcat=14 if (morphcat==13|morph==9679) & (topcat==33|topcat==34)
replace hxfamcat=15 if morph==8454 & topography==380
replace hxfamcat=16 if morph==9365 & (topcat>34 & topcat<38|topcat==42|topography==761|topography==767|topography==768|topcat==70)
replace hxfamcat=17 if morph==9261 & (topcat==36 & topography!=401 & topography!=403)
replace hxfamcat=18 if (morph>9179 & morph<9211|morph==8812|morph==9250|morph==9262|morphcat==34) & (topcat==36|topcat==37)
replace hxfamcat=19 if (morphcat>49 & morphcat<55 & morph!=9807 & morph!=9930|morph==9689|morph==9732|morph==9733|morph==9742|morph==9761|morph==9765|morphcat==56) & topcat==38
replace hxfamcat=20 if (morphcat==4 & morph!=8098|morphcat==7|morph==8081|morph==8542|morph==8790|morph==9597|morph==9700|morph==9709|morph==9718|morph==9726) & (topcat==1|topcat==39|topcat==44|topcat==52|topography==632|topcat==68|topcat==70)
replace hxfamcat=21 if (morph==8247|morph==8832|morph==8833|morph==9507|morph==9708) & (topcat==1|topcat==39|topcat==42|topcat==44|topcat==52|topography==632|topography==638|topography==639|topcat==68|topcat==70)
replace hxfamcat=22 if (morph>8504 & morph<8544 & morph!=8510 & morph!=8514 & morph!=8525 & morph!=8542 | morph>9009 & morph<9013 | morph>9015 & morph<9031|morph==8204|morph==8314|morph==8315|morph==8501|morph==8502|morph==8983) & (topcat==43|topography==761|topography==767|topography==768|topcat==70)
replace hxfamcat=23 if morph==8905 & (topcat==44|topcat==45|topography==578|topography==579)
replace hxfamcat=24 if (morph==8930|morph==8931) & (topcat==47|topcat==48|topography==578|topography==579)
replace hxfamcat=25 if (morph>8440 & morph<8445 | morph>8459 & morph<8474 & morph!=8461 | morph>8594 & morph<8624 | morph>9012 & morph<9016 |morph==8313|morph==8451|morph==8632|morph==8641|morph==8660|morph==8670|morph==9000|morph==9090|morph==9091) & (topcat==49|topcat==50|topography==762|topography==763|topography==767|topography==768|topcat==70)
replace hxfamcat=26 if (morph==9103|morph==9104) & topcat==51
replace hxfamcat=27 if (morph>8379 & morph<8385|morph==8482|morph==8934|morph==8950|morph==8951) & (topcat==41|topography>493 & topography<500|topcat>45 & topcat<51|topography==762|topography==763|topography==767|topography==768|topcat==70)
replace hxfamcat=28 if morph==8080 & topcat==52
replace hxfamcat=29 if (morph>9060 & morph<9064 |morph==9102) & (topcat==54|topcat==55)
replace hxfamcat=30 if (morph>8315 & morph<8320 | morph>8958 & morph<8968 & morph!=8963|morph==8312|morph==8325|morph==8361) & (topcat==56|topography==688|topography==689)
replace hxfamcat=31 if (morph>9509 & morph<9515) & (topography==692|topography==698|topography==699)
replace hxfamcat=32 if (morph==8726|morph==8773|morph==8774) & topcat==61
replace hxfamcat=33 if (morphcat==38|morph==8728) & (topcat>61 & topcat<65)
replace hxfamcat=34 if (morph>9469 & morph<9481 & morph!=9473|morph==9493) & (topography==716|topography==718|topography==719|topography==728|topography==729)
replace hxfamcat=35 if (morph==9381|morph==9390|morph==9444) & (topcat==63|topography==728|topography==729)
replace hxfamcat=36 if (morph>9120 & morph<9124 | morphcat==36 & morph!=9381 & morph!=9390 & morph!=9395 & morph!=9444 & morph!=9470 & morph!=9471 & morph!=9472 & morph!=9474 & morph!=9480|morph==9131|morph==9505|morph==9506|morph==9508|morph==9509) & (topcat>61 & topcat<65|topography==753)
replace hxfamcat=37 if (morph>8329 & morph<8351) & topcat==65
replace hxfamcat=38 if (morph>8369 & morph<8376|morph==8700) & topcat==66
replace hxfamcat=39 if (morph==8321|morph==8322) & topography==750
replace hxfamcat=40 if (morph>8269 & morph<8282 | morph>9349 & morph<9353|morph==8300|morph==9582) & (topography==751|topography==752)
replace hxfamcat=41 if (morph>9359 & morph<9363|morph==9395) & topography==753
replace hxfamcat=42 if morph==8692 & topography==754
replace hxfamcat=43 if (morph==8690|morph==8691) & topography==755
replace hxfamcat=44 if morph==8098 & (topcat==39|topcat==46|topography==578|topography==579)
replace hxfamcat=45 if (morph==8153|morph==8156|morph==8157|morph==8158) & (topcat==17|topcat==18|topcat==26|topcat==27|topography==762|topography==767|topography==768|topcat==70)
replace hxfamcat=46 if morph==8290 & (topcat==8|topcat==9|topcat==56|topography==688|topography==689|topcat==65|topography==758|topography==759|topography==760|topography==762|topography==767|topography==768|topcat==70)
replace hxfamcat=47 if morph==8450 & (topcat==26|topcat==27|topcat==49|topcat==50)
replace hxfamcat=48 if morph==8461 & (topcat==41|topcat==49)
replace hxfamcat=49 if (morph>8589 & morph<8593 | morph>8629 & morph<8651 & morph!=8632 & morph!=8641|morph==9054) & (topcat==49|topography==578|topography==579|topcat==54|topography==638|topography==639|topography==762|topography==763|topography==767|topography==768|topcat==70)
replace hxfamcat=50 if (morphcat==16 & morph!=8726 & morph!=8728 & morph!=8773 & morph!=8774 & morph!=8790) & (topcat==21|topcat==22|topcat==28|topcat==39|topcat==44|topcat==52|topography==632|topcat==61|topcat==62|topcat==68|topcat==70) 
replace hxfamcat=51 if (morph==8932|morph==8933|morphcat==28) & (topcat>43 & topcat<51 | topcat>55 & topcat<61|topography==762|topography==763|topography==767|topography==768|topcat==70)
replace hxfamcat=52 if morph==8935 & (topcat>45 & topcat<51|topcat==68 & topography!=760 & topography!=764 & topography!=765|topcat==43|topcat==70)
replace hxfamcat=53 if (morphcat==24|morphcat==32 & morph!=9250|morph==9260) & (topcat==36|topcat==37|topcat==42|topcat==68|topcat==70)
replace hxfamcat=54 if (morph>9219 & morph<9244) & (topography==300|topcat==29|topography>322 & topography<330|topcat==31|topcat>34 & topcat<38|topcat==42|topcat==68|topcat==70)
replace hxfamcat=55 if (morph==8077|morph==8148) & (topcat==22|topcat>43 & topcat<47|topcat==53)
replace hxfamcat=56 if (morphcat==5 & morph!=8123 & morph!=8124) & (topcat==12|topcat==15|topcat==21|topcat==22|topcat>26 & topcat<30|topcat==35|topcat==46|topcat==53|topcat>55 & topcat<61|topcat==68 & topography!=764 & topography!=765|topcat==70)
replace hxfamcat=57 if (morph>8239 & morph<8250 & morph!=8247) & (topcat>15 & topcat<28|topcat==32|topcat==33|topography>380 & topography<384|topcat==35 & topography!=390|topcat==49|topography==578|topography==579|topcat==65|topcat==68 & topography!=764 & topography!=765|topcat==70)
replace hxfamcat=58 if (morph==8500|morph==8503|morph==8504|morph==8514|morph==8525) & (topography==69|topcat==8|topcat==9|topcat>21 & topcat<27|topography==268|topography==269|topcat==43|topcat==53|topography==638|topography==639|topography==758|topography==759|topcat==68 & topography!=761 & topography!=764 & topography!=765|topcat==70)
replace hxfamcat=59 if (morphcat==15 & morph!=8683 & morph!=8690 & morph!=8691 & morph!=8692 & morph!=8700) & (topcat==34|topcat==35 & topography!=390|topcat>39 & topcat<43|topcat==59|topcat==60|topcat>62 & topcat<69|topcat==70)
replace hxfamcat=60 if (morphcat==26 & morph!=9061 & morph!=9062 & morph!=9063 & morph!=9090 & morph!=9091|morph==9105) & (topcat==34|topcat==35 & topography!=390|topcat==41|topcat==42|topcat==49|topcat==50|topcat==54|topcat==55|topcat==63|topcat==64|topcat==67|topcat==68 & topography!=764 & topography!=765|topcat==70)
replace hxfamcat=61 if (morph==9100|morph==9101) & (topcat==34|topcat>48 & topcat<52|topcat==54|topcat==68 & topography!=760 & topography!=764 & topography!=765|topcat==70)
replace hxfamcat=62 if (morph>9369 & morph<9374) & (topcat==12|topcat==15|topcat==28|topcat==29|topcat>34 & topcat<38|topcat==42|topcat==63|topcat==64|topcat==67|topcat==68|topcat==70)
replace hxfamcat=63 if (morph>9489 & morph<9505 & morph!=9493) & (topcat==34|topcat==35 & topography!=390|topcat>39 & topcat<43|topcat>60 & topcat<65|topcat==66|topography==758|topography==759|topcat==68|topcat==70)
replace hxfamcat=64 if morphcat==39 & (topcat==34|topcat==35 & topography!=390|topcat>39 & topcat<43|topcat>60 & topcat<65|topcat==68|topcat==70)
** Group 3 - Tumours with inverse site-profile
replace hxfamcat=65 if (morph>8833 & morph<8837|morph==8004|morph==8005|morph==8831|morphcat==30) & topcat==38
replace hxfamcat=66 if (morph>8009 & morph<8036 & morph!=8012|morphcat==3 & morph!=8077 & morph!=8080 & morph!=8081|morph>8139 & morph<8150 & morph!=8142 & morph!=8144 & morph!=8145 & morph!=8148|morph>8189 & morph<8213 & morph!=8202 & morph!=8204|morphcat==11|morphcat==12 & morph!=8561|morph>8979 & morph<8983|morph==8123|morph==8230|morph==8231|morph==8251|morph==8260|morph==8262|morph==8263|morph==8310|morph==8311|morph==8320|morph==8323|morph==8324|morph==8360|morph==8430|morph==8440|morph==8480|morph==8481|morph==8490|morph==8510|morph==8940|morph==8941) & (topcat>35 & topcat<39|topcat>39 & topcat<43|topcat>61 & topcat<65 | topcat==69)
replace hxfamcat=67 if (morphcat==17 & morph!=8802|morphcat==29 & morph!=9121 & morph!=9122 & morph!=9123 & morph!=9124 & morph!=9131 & morph!=9132 & morph!=9140|morphcat==40 & morph!=9582|morph==8671|morph==8963|morph==9363|morph==9364) & (topcat==38 & topography!=422|topcat==69)
replace hxfamcat=68 if morph==8802 & (topcat==36|topcat==37|topcat==38 & topography!=422|topcat==69)
replace hxfamcat=69 if (morphcat>17 & morphcat<22 & morph!=8812 & morph!=8827 & morph!=8831 & morph!=8832 & morph!=8833 & morph!=8834 & morph!=8835 & morph!=8836 & morph!=8905|morph==8990|morph==8991|morph==9132) & (topcat==38 & topography!=422|topcat>61 & topcat<65|topcat==69)
replace hxfamcat=70 if morph==9140 & (topcat==8|topcat==9|topcat>22 & topcat<27|topcat>35 & topcat<39|topcat==40|topcat==41|topcat>42 & topcat<52|topcat==53|topcat==54|topcat>55 & topcat<61|topcat>61 & topcat<68)
replace hxfamcat=71 if morph==9734 & (topcat==36|topcat==37)
label var hxfamcat "Hx Family Category(IARCcrgTools)"
label define hxfamcat_lab 1 "Tumours accepted with any site code" 2 "Salivary Gland tumours" 3 "Stomach tumours" 4 "Small Intestine tumours" 5 "Colorectal tumours" ///
						  6 "Anal tumours" 7 "Gastrointestinal tumours" 8 "Liver tumours" 9 "Biliary tumours" 10 "Pancreatic tumours" 11 "Olfactory tumours" ///
						  12 "Lung tumours" 13 "Mesotheliomas & pleuropulmonary Blastomas" 14 "Thymus tumours" 15 "Cystic tumours of atrio-ventricular node" ///
						  16 "Askin tumours" 17 "Adamantinomas of long bones" 18 "Bone tumours" 19 "Haematopoietic tumours" 20 "Skin tumours" ///
						  21 "Tumours of skin & subcutaneous tissue" 22 "Breast tumours" 23 "Genital rhabdomyomas" 24 "Endometrial stromal sarcomas" ///
						  25 "Ovarian tumours" 26 "Placental tumours" 27 "Tumours of female genital organs" 28 "Queyrat erythroplasias" 29 "Testicular tumours" ///
						  30 "Renal tumours" 31 "Retinoblastomas" 32 "Naevi & melanomas of eye" 33 "Meningeal tumours" 34 "Cerebellar tumours" 35 "Cerebral tumours" ///
						  36 "CNS tumours" 37 "Thyroid tumours" 38 "Adrenal tumours" 39 "Parathyroid tumours" 40 "Pituitary tumours" 41 "Pineal tumours" ///
						  42 "Carotid body tumours" 43 "Tumours of glomus jugulare/aortic body" 44 "Adenoid basal carcinomas" ///
						  45 "Gastrinomas/Somatostatinomas/Enteroglucagonomas" 46 "Oxyphilic adenocarcinomas" 47 "Papillary (cyst)adenocarcinomas" ///
						  48 "Serous surface papillary carcinomas" 49 "Gonadal tumours" 50 "Naevi & Melanomas" 51 "Adenosarcomas & Mesonephromas" 52 "Stromal sarcomas" ///
						  53 "Tumours of bone & connective tissue" 54 "Chondromatous tumours" 55 "Intraepithelial tumours" 56 "Transitional cell tumours" ///
						  57 "Carcinoid tumours" 58 "Ductal and lobular tumours" 59 "Paragangliomas" 60 "Germ cell & trophoblastic tumours" 61 "Choriocarcinomas" ///
						  62 "Chordomas" 63 "Neuroepitheliomatous tumours" 64 "Nerve sheath tumours" 65 "NOT haematopoietic tumours" 66 "NOT site-specific carcinomas" ///
						  67 "NOT site-specific sarcomas" 68 "NOT Bone-Giant cell sarcomas" 69 "NOT CNS affecting sarcomas" 70 "NOT sites of Kaposi sarcoma" ///
						  71 "NOT Bone-Plasmacytomas, extramedullary" ///
						  ,modify
label values hxfamcat hxfamcat_lab

** Create category for sex/histology check: IARCcrgTools pg 7
gen sexcheckcat=.
replace sexcheckcat=1 if sex==1 & (hxfamcat>22 & hxfamcat<28)
replace sexcheckcat=2 if sex==2 & (hxfamcat==28|hxfamcat==29)
label var sexcheckcat "Sex/Hx Check Category"
label define sexcheckcat_lab 1 "Check 1: Sex=male & HxFam=23,24,25,26,27" 2 "Check 2: Sex=female & Hx family=28,29" ///
							 ,modify
label values sexcheckcat sexcheckcat_lab

** Create category for site/histology check: IARCcrgTools pg 7
gen sitecheckcat=.
replace sitecheckcat=1 if hxfamcat==65
replace sitecheckcat=2 if hxfamcat==66
replace sitecheckcat=3 if hxfamcat==67
replace sitecheckcat=4 if hxfamcat==68
replace sitecheckcat=5 if hxfamcat==69
replace sitecheckcat=6 if hxfamcat==70
replace sitecheckcat=7 if hxfamcat==71
label var sitecheckcat "Site/Hx Check Category"
label define sexcheckcat_lab 1 "Check 1: NOT haem. tumours" 2 "Check 2: NOT site-specific ca." 3 "Check 3: NOT site-specific sarcomas" ///
							 4 "Check 4: Top=Bone; Hx=Giant cell sarc.except bone" 5 "Check 5: NOT sarcomas affecting CNS" 6 "Check 6: NOT sites for Kaposi sarcoma" ///
							 7 "Check 7: Top=Bone; Hx=extramedullary plasmacytoma" ,modify
label values sexcheckcat sexcheckcat_lab

** Create category for CODs as needed in LATERALITY category so non-cancer CODs with the terms 'left' & 'right' are not flagged
gen codcat=.
replace codcat=1 if cr5cod!="99" & cr5cod!="" & cr5cod!="NIL." & cr5cod!="Not Stated." & !strmatch(strupper(cr5cod), "*CANCER*") & !strmatch(strupper(cr5cod), "*OMA*") ///
		 & !strmatch(strupper(cr5cod), "*MALIG*") & !strmatch(strupper(cr5cod), "*TUM*") & !strmatch(strupper(cr5cod), "*LYMPH*") ///
		 & !strmatch(strupper(cr5cod), "*LEU*") & !strmatch(strupper(cr5cod), "*MYELO*") & !strmatch(strupper(cr5cod), "*METASTA*")
label var codcat "Laterality Category"
label define codcat_lab 1 "Non-cancer COD" ,modify
label values codcat codcat_lab

** Create category for laterality so can perform checks on this category
** Category determined using SEER Program Coding Staging Manual 2016 pgs 82-84
gen latcat=.
replace latcat=0 if latcat==.
replace latcat=1 if topography==79
replace latcat=2 if topography==80
replace latcat=3 if topography==81
replace latcat=4 if topography==90
replace latcat=5 if topography==91
replace latcat=6 if topography==98
replace latcat=7 if topography==99
replace latcat=8 if topography==300
replace latcat=9 if topography==301
replace latcat=10 if topography==310
replace latcat=11 if topography==312
replace latcat=12 if topography==340
replace latcat=13 if topography>340 & topography<350
replace latcat=14 if topography==384
replace latcat=15 if topography==400
replace latcat=16 if topography==401
replace latcat=17 if topography==402
replace latcat=18 if topography==403
replace latcat=19 if topography==413
replace latcat=20 if topography==414
replace latcat=21 if topography==441
replace latcat=22 if topography==442
replace latcat=23 if topography==443
replace latcat=24 if topography==445
replace latcat=25 if topography==446
replace latcat=26 if topography==447
replace latcat=27 if topography==471
replace latcat=28 if topography==472
replace latcat=29 if topography==491
replace latcat=30 if topography==492
replace latcat=31 if topography>499 & topography<510
replace latcat=32 if topography==569
replace latcat=33 if topography==570
replace latcat=34 if topography>619 & topography<630
replace latcat=35 if topography==630
replace latcat=36 if topography==631
replace latcat=37 if topography==649
replace latcat=38 if topography==659
replace latcat=39 if topography==669
replace latcat=40 if topography>689 & topography<700
replace latcat=41 if topography==700
replace latcat=42 if topography==710
replace latcat=43 if topography==711
replace latcat=44 if topography==712
replace latcat=45 if topography==713
replace latcat=46 if topography==714
replace latcat=47 if topography==722
replace latcat=48 if topography==723
replace latcat=49 if topography==724
replace latcat=50 if topography==725
replace latcat=51 if topography>739 & topography<750
replace latcat=52 if topography==754
label var latcat "Laterality Category(SEER)"
label define latcat_lab   0 "No lat cat" 1 "Lat-Parotid gland" 2 "Lat-Submandibular gland" 3 "Lat-Sublingual gland" 4 "Lat-Tonsillar fossa" 5 "Lat-Tonsillar pillar" ///
						  6 "Lat-Overlapping lesion: tonsil" 7 "Lat-Tonsil, NOS" 8 "Lat-Nasal cavity(excl. nasal cartilage,nasal septum)" 9 "Lat-Middle ear" ///
						  10 "Lat-Maxillary sinus" 11 "Lat-Frontal sinus" 12 "Lat-Main bronchus (excl. carina)" 13 "Lat-Lung" 14 "Lat-Pleura" ///
						  15 "Lat-Long bones:upper limb,scapula,associated joints" 16 "Lat-Short bones:upper limb,associated joints" ///
						  17 "Lat-Long bones:lower limb,associated joints" 18 "Lat-Short bones:lower limb,associated joints" 19 "Lat-Rib,clavicle(excl.sternum)" ///
						  20 "Lat-Pelvic bones(excl.sacrum,coccyx,symphysis pubis)" 21 "Lat-Skin:eyelid" 22 "Lat-Skin:external ear" 23 "Lat-Skin:face" ///
						  24 "Lat-Skin:trunk" 25 "Lat-Skin:upper limb,shoulder" 26 "Lat-Skin:lower limb,hip" 27 "Lat-ANS:upper limb,shoulder" 28 "Lat-ANS:lower limb,hip" ///
						  29 "Lat-Tissues:upper limb,shoulder" 30 "Lat-Tissues:lower limb,hip" 31 "Lat-Breast" 32 "Lat-Ovary" 33 "Lat-Fallopian tube" 34 "Lat-Testis" ///
						  35 "Lat-Epididymis" 36 "Lat-Spermatic cord" 37 "Lat-Kidney,NOS" 38 "Lat-Renal pelvis" 39 "Lat-Ureter" 40 "Lat-Eye,adnexa" ///
						  41 "Lat-Cerebral meninges" 42 "Lat-Cerebrum" 43 "Lat-Frontal lobe" 44 "Lat-Temporal lobe" 45 "Lat-Parietal lobe" 46 "Lat-Occipital lobe" ///
						  47 "Lat-Olfactory nerve" 48 "Lat-Optic nerve" 49 "Lat-Acoustic nerve" 50 "Lat-Cranial nerve" 51 "Lat-Adrenal gland" 52 "Lat-Carotid body" ,modify
label values latcat latcat_lab


** Create category for laterality checks
** Checks 5-10 are taken from SEER Program Coding Staging manual pgs 82-84
gen latcheckcat=.
replace latcheckcat=1 if (regexm(cr5cod, "LEFT")|regexm(cr5cod, "left")) & codcat!=1 & latcat>0 & (lat!=. & lat!=2)
replace latcheckcat=2 if (regexm(cr5cod, "RIGHT")|regexm(cr5cod, "right")) & codcat!=1 & latcat>0 & (lat!=. & lat!=1)
replace latcheckcat=3 if (regexm(cfdx, "LEFT")|regexm(cfdx, "left")) & latcat>0 & (lat!=. & lat!=2)
replace latcheckcat=4 if (regexm(cfdx, "RIGHT")|regexm(cfdx, "right")) & latcat>0 & (lat!=. & lat!=1)
replace latcheckcat=5 if topography==809 & (lat!=. & lat!=0)
replace latcheckcat=6 if latcat>0 & (lat==0|lat==8)
replace latcheckcat=7 if (latcat!=13 & latcat!=32 & latcat!=37 & latcat!=40) & lat==4
replace latcheckcat=8 if (latcat>40 & latcat<51|latcat==23|latcat==24) & dxyr>2009 & (lat!=. & lat!=5 & lat==8)
replace latcheckcat=9 if (latcat<41 & latcat>50 & latcat!=23 & latcat!=24) & dxyr>2009 & lat==5
replace latcheckcat=10 if (latcat!=0 & latcat!=8 & latcat!=12 & latcat!=19 & latcat!=20) & basis==0 & (lat!=. & lat==8)
replace latcheckcat=11 if topcat==65 & lat!=0
replace latcheckcat=12 if latcat==0 & topography!=809 & (lat!=0 & lat!=. & lat!=8) & latcheckcat==.
replace latcheckcat=13 if lat==8 & dxyr>2013
replace latcheckcat=14 if lat==8 & latcat!=0
replace latcheckcat=15 if latcat!=0 & lat==9
replace latcheckcat=16 if lat==9 & topography==569
//replace latcheckcat=16 if lat!=4 & topography==569 & morph>7999 & morph<9800
label var latcheckcat "Laterality Check Category"
label define latcheckcat_lab 1 "Check 1: COD='left'; COD=cancer (codcat!=1); lat!=left" 2 "Check 2: COD='right'; COD=cancer (codcat!=1); lat!=right" ///
							 3 "Check 3: CFdx='left'; lat!=left"  4 "Check 4: CFdx='right'; lat!=right" 5 "Check 5: topog==809 & lat!=0-paired site" ///
							 6 "Check 6: latcat>0 & lat==0 or 8" 7 "Check 7: latcat!=ovary,lung,eye,kidney & lat==4" ///
							 8 "Check 8: latcat=meninges/brain/CNS/skin-face,trunk & dxyr>2009 & lat!=5 & lat=NA" ///
							 9 "Check 9: latcat!=meninges/brain/CNS/skin-face,trunk & dxyr>2009 & lat==5" 10 "Check 10: latcat!=0,8,12,19,20 & basis==0 & lat=NA" ///
							 11 "Check 11: primsite=thyroid and lat!=NA" 12 "Check 12: latcat=no lat cat; topog!=809; lat!=N/A; latcheckcat==." ///
							 13 "Check 13: laterality=N/A & dxyr>2013" 14 "Check 14: lat=N/A and latcat!=no lat cat" ///
							 15 "Check 15: lat=unk for paired site" 16 "Check 16: lat=unk & top=ovary" ,modify
label values latcheckcat latcheckcat_lab


** Create category for behaviour/morphology check
** Check 7 is taken from IARCcrgTools pg 8 (behaviour/histology)
gen behcheckcat=.
replace behcheckcat=1 if beh!=2 & morph==8503
replace behcheckcat=2 if beh!=2 & morph==8077
replace behcheckcat=3 if (regexm(hx, "SQUAMOUS")&regexm(hx, "MICROINVAS")) & beh!=3 & morph!=8076
replace behcheckcat=4 if regexm(hx, "BOWEN") & beh!=2
replace behcheckcat=5 if topography==181 & morph==8240 & beh!=1
replace behcheckcat=6 if regexm(hx, "ADENOMA") & (!strmatch(strupper(hx), "*ADENOCARCINOMA*")&!strmatch(strupper(hx), "*INVASION*")) & beh!=2 & morph==8263
replace behcheckcat=7 if morphcat==. & morph!=.
replace behcheckcat=8 if beh>1 & (hx=="TUMOUR"|hx=="TUMOR")
label var behcheckcat "Beh<>Morph Check Category"
label define behcheckcat_lab 1 "Check 1: Beh!=2 & Morph==8503" 2 "Check 2: Beh!=2 & Morph==8077" 3 "Check 3: Hx=Squamous & microinvasive & Beh=2 & Morph!=8076" ///
							 4 "Check 4: Hx=Bowen & Beh!=2" 5 "Check 5: Prim=appendix, Morph=carcinoid & Beh!=uncertain" ///
							 6 "Check 6: Hx=adenoma excl. adenoca. & invasion & Morph==8263 & Beh!=2" 7 "Check 7: Morph not listed in ICD-O-3" ///
							 8 "Check 8: Hx=tumour & beh>1" ,modify
label values behcheckcat behcheckcat_lab

** Create category for behaviour/site check: IARCcrgTools pg 8
gen behsitecheckcat=.
replace behsitecheckcat=1 if beh==2 & topcat==36
replace behsitecheckcat=2 if beh==2 & topcat==37
replace behsitecheckcat=3 if beh==2 & topcat==38
replace behsitecheckcat=4 if beh==2 & topcat==40
replace behsitecheckcat=5 if beh==2 & topcat==42
replace behsitecheckcat=6 if beh==2 & topcat==62
replace behsitecheckcat=7 if beh==2 & topcat==63
replace behsitecheckcat=8 if beh==2 & topcat==64
label var behsitecheckcat "Beh/Site Check Category"
label define behsitecheckcat_lab 1 "Check 1: Beh==2 & Top==C40._(bone)" 2 "Check 2: Beh==2 & Top==C41._(bone,NOS)" 3 "Check 3: Beh==2 & Top==C42._(haem)" ///
								 4 "Check 4: Beh==2 & Top==C47._(ANS)" 5 "Check 5: Beh==2 & Top==C49._(tissues)" 6 "Check 6: Beh==2 & Top==C70._(meninges)" ///
								 7 "Check 7: Beh==2 & Top==C71._(brain)" 8 "Check 8: Beh==2 & Top==C72._(CNS)" ,modify
label values behsitecheckcat behsitecheckcat_lab

** Create category for grade/histology check: IARCcrgTools pg 9
gen gradecheckcat=.
replace gradecheckcat=1 if beh<3 & grade<9 & dxyr>2013
replace gradecheckcat=2 if (grade>4 & grade<9) & morph<9590 & dxyr>2013
replace gradecheckcat=3 if (grade>0 & grade<5) & morph>9589 & dxyr>2013
replace gradecheckcat=4 if grade!=5 & (morph>9701 & morph<9710 | morph>9715 & morph <9727 & morph!=9719 | morph==9729 | morph==9827 | morph==9834 | morph==9837) & dxyr>2013
replace gradecheckcat=5 if (grade!=5|grade!=7) & morph==9714 & dxyr>2013
replace gradecheckcat=6 if (grade!=5|grade!=8) & (morph==9700 | morph==9701 | morph==9719 | morph==9831) & dxyr>2013
replace gradecheckcat=7 if grade!=6 & (morph>9669 & morph<9700|morph==9712|morph==9728|morph==9737|morph==9738|morph>9810 & morph<9819|morph==9823|morph==9826|morph==9833|morph==9836) & dxyr>2013
replace gradecheckcat=8 if grade!=8 & morph==9948 & dxyr>2013
replace gradecheckcat=9 if grade!=1 & (morph==8331 | morph==8851 | morph==9187 | morph==9511) & dxyr>2013
replace gradecheckcat=10 if grade!=2 & (morph==8249 | morph==8332 | morph==8858 | morph==9083 | morph==9243 | morph==9372) & dxyr>2013
replace gradecheckcat=11 if grade!=3 & (morph==8631|morph==8634) & dxyr>2013
replace gradecheckcat=12 if grade!=4 & (morph==8020|morph==8021|morph==8805|morph==9062|morph==9082|morph==9392|morph==9401|morph==9451|morph==9505|morph==9512) & dxyr>2013
replace gradecheckcat=13 if grade==9 & (regexm(cfdx, "GLEASON")|regexm(cfdx, "Gleason")|regexm(md, "GLEASON")|regexm(md, "Gleason")|regexm(consrpt, "GLEASON")|regexm(consrpt, "Gleason")) & dxyr>2013
replace gradecheckcat=14 if grade==9 & (regexm(cfdx, "NOTTINGHAM")|regexm(cfdx, "Nottingham")|regexm(md, "NOTTINGHAM")|regexm(md, "Nottingham")|regexm(consrpt, "NOTTINGHAM")|regexm(consrpt, "Nottingham") ///
							|regexm(cfdx, "BLOOM")|regexm(cfdx, "Bloom")|regexm(md, "BLOOM")|regexm(md, "Bloom")|regexm(consrpt, "BLOOM")|regexm(consrpt, "Bloom")) & dxyr>2013
replace gradecheckcat=15 if grade==9 & (regexm(cfdx, "FUHRMAN")|regexm(cfdx, "Fuhrman")|regexm(md, "FUHRMAN")|regexm(md, "Fuhrman")|regexm(consrpt, "FUHRMAN")|regexm(consrpt, "Fuhrman")) & dxyr>2013
replace gradecheckcat=16 if grade!=6 & morph==9732 & dxyr>2013
label var gradecheckcat "Grade/Hx Check Category"
label define gradecheckcat_lab 	 1 "Check 1: Beh<3 & Grade<9 & DxYr>2013" 2 "Check 2: Grade>=5 & <=8 & Hx<9590 & DxYr>2013" ///
								 3 "Check 3: Grade>=1 & <=4 & Hx>=9590 & DxYr>2013" ///
								 4 "Check 4: Grade!=5 & Hx=9702-9709,9716-9726(!=9719),9729,9827,9834,9837 & DxYr>2013" 5 "Check 5: Grade!=5 or 7 & Hx=9714 & DxYr>2013" ///
								 6 "Check 6: Grade!=5 or 8 & Hx=9700/9701/9719/9831 & DxYr>2013" ///
								 7 "Check 7: Grade!=6 & Hx=>=9670,<=9699,9712,9728,9737,9738,>=9811,<=9818,9823,9826,9833,9836 & DxYr>2013" ///
								 8 "Check 8: Grade!=8 & Hx=9948 & DxYr>2013" 9 "Check 9: Grade!=1 & Hx=8331/8851/9187/9511 & DxYr>2013" ///
								 10 "Check 10: Grade!=2 & Hx=8249/8332/8858/9083/9243/9372 & DxYr>2013" 11 "Check 11: Grade!=3 & HX=8631/8634 & DxYr>2013" ///
								 12 "Check 12: Grade!=4 & Hx=8020/8021/8805/9062/9082/9392/9401/9451/9505/9512 & DxYr>2013" ///
								 13 "Check 13: Grade=9 & cfdx/md/consrpt=Gleason & DxYr>2013" 14 "Check 14: Grade=9 & cfdx/md/consrpt=Nottingham/Bloom & DxYr>2013" ///
								 15 "Check 15: Grade=9 & cfdx/md/consrpt=Fuhrman & DxYr>2013" 16 "Check 16: Grade!=6 & Hx=9732(MM) & DxYr>2013" ,modify
label values gradecheckcat gradecheckcat_lab

** Create category for basis/morphology check
gen bascheckcat=.
replace bascheckcat=1 if morph==8000 & (basis>5 & basis<9)
replace bascheckcat=2 if regexm(hx, "OMA") & (basis<6 & basis>8)
replace bascheckcat=3 if basis!=. & morph!=8000 & (basis<5 & basis>8) & (morph<8150 & morph>8154) & morph!=8170 & (morph<8270 & morph>8281) ///
						& (morph!=8800 & morph!=8960 & morph!=9100 & morph!=9140 & morph!=9350 & morph!=9380 & morph!=9384 & morph!=9500 & morph!=9510) ///
						& (morph!=9590 & morph!=9732 & morph!=9761 & morph!=9800)
replace bascheckcat=4 if basis==0 & morph==8000 & regexm(hx, "MASS") & recstatus!=3
replace bascheckcat=5 if basis==0 & regexm(comments, "Notes seen")
replace bascheckcat=6 if basis!=4 & basis!=7 & topography==619 & regexm(comments, "PSA")
replace bascheckcat=7 if basis==9 & regexm(comments, "Notes seen")
replace bascheckcat=8 if basis!=7 & topography==421 & nftype==3 //see IARC manual pg.20
replace bascheckcat=9 if basis!=5 & basis!=7 & topography==421 & (regexm(comments, "blood")|regexm(comments, "Blood")) //see IARC manual pg. 19/20
label var bascheckcat "Basis<>Morph Check Category"
label define bascheckcat_lab 1 "Check 1: morph==8000 & (basis==6|basis==7|basis==8)" 2 "Check 2: hx=...OMA & basis!=6/7/8" ///
							 3 "Check 3: Basis not missing & basis!=cyto/heme/hist & morph on BOD/Hx Control IARCcrgTools" 4 "Check 4: Hx=mass; Basis=DCO; Morph==8000" ///
							 5 "Check 5: Basis=DCO; Comments=Notes seen" 6 "Check 6: Prostate: Basis!=lab test/hx of prim; Comments=PSA" ///
							 7 "Check 7: Basis=Unk; Comments=Notes seen" 8 "Check 8: Haem: Basis!=hx of prim; NFtype=BM" ///
							 9 "Check 9: Haem: Basis!=haem/hx of prim; Comments=Blood",modify
label values bascheckcat bascheckcat_lab


** Create category for staging check
gen stagecheckcat=.
replace stagecheckcat=1 if (basis!=0 & basis!=9) & staging==9
replace stagecheckcat=2 if beh!=2 & staging==0
replace stagecheckcat=3 if topography==778 & staging==1
replace stagecheckcat=4 if (staging!=. & staging!=8) & dxyr!=2013
replace stagecheckcat=5 if (staging!=. & staging!=9) & topography==809 & dxyr==2013
replace stagecheckcat=6 if (basis==0|basis==9) & staging!=9 & dxyr==2013
replace stagecheckcat=7 if beh==2 & staging!=0 & dxyr==2013
label var stagecheckcat "Staging Check Category"
label define stagecheckcat_lab 1 "Check 1: basis!=0(DCO) or 9(unk) & staging=9(DCO)" 2 "Check 2: beh!=2(in-situ) & staging=0(in-situ)" ///
							   3 "Check 3: topog=778(overlap LNs) & staging=1(local.)" 4 "Check 4: staging!=8(NA) & dxyr!=2013" ///
							   5 "Check 5: staging!=9(NK) & topog=809 & dxyr=2013" 6 "Check 6: basis=0(DCO)/9(unk) & staging!=9(DCO) & dxyr=2013" ///
							   7 "Check 7: beh==2(in-situ) & staging!=0(in-situ) & dxyr=2013" ,modify
label values stagecheckcat stagecheckcat_lab

** Create category for incidence date check
gen dotcheckcat=.
replace dotcheckcat=1 if dot!=. & dob!=. & dot<dob
replace dotcheckcat=2 if dot!=. & dlc!=. & dot>dlc
replace dotcheckcat=3 if dot!=. & dlc!=. & basis==0 & dot!=dlc
replace dotcheckcat=4 if dot!=. & dxyr>2013 & dfc!=d(01jan2000) & admdate!=d(01jan2000) & rtdate!=d(01jan2000) & sampledate!=d(01jan2000) & recvdate!=d(01jan2000) & rptdate!=d(01jan2000) & (dot!=dfc & dot!=admdate & dot!=rtdate & dot!=sampledate & dot!=recvdate & dot!=rptdate & dot!=dlc) & regexm(cr5id, "S1")
replace dotcheckcat=5 if dot!=. & dxyr>2013 & admdate!=d(01jan2000) & rtdate!=d(01jan2000) & sampledate!=d(01jan2000) & recvdate!=d(01jan2000) & rptdate!=d(01jan2000) & dot==dfc & (dfc>admdate|dfc>rtdate|dfc>sampledate|dfc>recvdate|dfc>rptdate)
replace dotcheckcat=6 if dot!=. & dxyr>2013 & dfc!=d(01jan2000) & rtdate!=d(01jan2000) & sampledate!=d(01jan2000) & recvdate!=d(01jan2000) & rptdate!=d(01jan2000) & dot==admdate & (admdate>dfc|admdate>rtdate|admdate>sampledate|admdate>recvdate|admdate>rptdate)
replace dotcheckcat=7 if dot!=. & dxyr>2013 & dfc!=d(01jan2000) & admdate!=d(01jan2000) & sampledate!=d(01jan2000) & recvdate!=d(01jan2000) & rptdate!=d(01jan2000) & dot==rtdate & (rtdate>dfc|rtdate>admdate|rtdate>sampledate|rtdate>recvdate|rtdate>rptdate)
replace dotcheckcat=8 if dot!=. & dxyr>2013 & dfc!=d(01jan2000) & admdate!=d(01jan2000) & rtdate!=d(01jan2000) & recvdate!=d(01jan2000) & rptdate!=d(01jan2000) & dot==sampledate & (sampledate>dfc|sampledate>admdate|sampledate>rtdate|sampledate>recvdate|sampledate>rptdate)
replace dotcheckcat=9 if dot!=. & dxyr>2013 & dfc!=d(01jan2000) & admdate!=d(01jan2000) & rtdate!=d(01jan2000) & sampledate!=d(01jan2000) & rptdate!=d(01jan2000) & dot==recvdate & (recvdate>dfc|recvdate>admdate|recvdate>rtdate|recvdate>sampledate|recvdate>rptdate)
replace dotcheckcat=10 if dot!=. & dxyr>2013 & dfc!=d(01jan2000) & admdate!=d(01jan2000) & rtdate!=d(01jan2000) & sampledate!=d(01jan2000) & recvdate!=d(01jan2000) & dot==rptdate & (rptdate>dfc|rptdate>admdate|rptdate>rtdate|rptdate>sampledate|rptdate>recvdate)
label var dotcheckcat "InciDate Check Category"
label define dotcheckcat_lab 1 "Check 1: InciDate before DOB" ///
							 2 "Check 2: InciDate after DLC" 3 "Check 3: Basis=DCO & InciDate!=DLC" ///
							 4 "Check 4: InciDate<>DFC/AdmDate/RTdate/SampleDate/ReceiveDate/RptDate/DLC(2014 onwards)" ///
							 5 "Check 5: InciDate=DFC; DFC after AdmDate/RTdate/SampleDate/ReceiveDate/RptDate(2014 onwards)" ///
							 6 "Check 6: InciDate=AdmDate; AdmDate after DFC/RTdate/SampleDate/ReceiveDate/RptDate(2014 onwards)" ///
							 7 "Check 7: InciDate=RTdate; RTdate after DFC/AdmDate/SampleDate/ReceiveDate/RptDate(2014 onwards)" ///
							 8 "Check 8: InciDate=SampleDate; SampleDate after DFC/AdmDate/RTdate/ReceiveDate/RptDate(2014 onwards)" ///
							 9 "Check 9: InciDate=ReceiveDate; ReceiveDate after DFC/AdmDate/RTdate/SampleDate/RptDate(2014 onwards)" ///
							 10 "Check 10: InciDate=RptDate; RptDate after DFC/AdmDate/RTdate/SampleDate/ReceiveDate(2014 onwards)" ///
							 ,modify
label values dotcheckcat dotcheckcat_lab

** Create category for DxYr check
gen dxyrcheckcat=.
replace dxyrcheckcat=1 if dotyear!=. & dxyr!=. & dotyear!=dxyr
replace dxyrcheckcat=2 if (admyear!=. & admyear!=2000) & dxyr!=. & dxyr>2013 & admyear!=dxyr
replace dxyrcheckcat=3 if (dfcyear!=. & dfcyear!=2000) & dxyr!=. & dxyr>2013 & dfcyear!=dxyr
replace dxyrcheckcat=4 if (rtyear!=. & rtyear!=2000) & dxyr!=. & dxyr>2013 & rtyear!=dxyr
label var dxyrcheckcat "DxYr Check Category"
label define dxyrcheckcat_lab 1 "Check 1: dotyear!=dxyr" 2 "Check 2: admyear!=dxyr & dxyr>2013" 3 "Check 3: dfcyear!=dxyr & dxyr>2013" ///
							  4 "Check 4: rtyear!=dxyr & dxyr>2013" ///
							 ,modify
label values dxyrcheckcat dxyrcheckcat_lab

** Create category for Treatments 1-5 check
gen rxcheckcat=.
replace rxcheckcat=1 if rx1==0 & (rx1d!=. & rx1d!=d(01jan2000))
replace rxcheckcat=2 if rx1==9 & (rx1d!=. & rx1d!=d(01jan2000))
replace rxcheckcat=3 if rx1!=. & rx1!=0 & rx1!=9 & (rx1d==.|rx1d==d(01jan2000))
replace rxcheckcat=4 if rx1d > rx2d
replace rxcheckcat=5 if rx1d > rx3d
replace rxcheckcat=6 if rx1d > rx4d
replace rxcheckcat=7 if rx1d > rx5d
replace rxcheckcat=8 if rx2==0|rx2==9
replace rxcheckcat=9 if rx2==. & (rx2d!=. & rx2d!=d(01jan2000))
replace rxcheckcat=10 if rx2!=. & rx2!=0 & rx2!=9 & (rx2d==.|rx2d==d(01jan2000))
replace rxcheckcat=11 if rx2d > rx3d
replace rxcheckcat=12 if rx2d > rx4d
replace rxcheckcat=13 if rx2d > rx5d
replace rxcheckcat=14 if rx3==0|rx3==9
replace rxcheckcat=15 if rx3==. & (rx3d!=. & rx3d!=d(01jan2000))
replace rxcheckcat=16 if rx3!=. & rx3!=0 & rx3!=9 & (rx3d==.|rx3d==d(01jan2000))
replace rxcheckcat=17 if rx3d > rx4d
replace rxcheckcat=18 if rx3d > rx5d
replace rxcheckcat=19 if rx4==0|rx4==9
replace rxcheckcat=20 if rx4==. & (rx4d!=. & rx4d!=d(01jan2000))
replace rxcheckcat=21 if rx4!=. & rx4!=0 & rx4!=9 & (rx4d==.|rx4d==d(01jan2000))
replace rxcheckcat=22 if rx4d > rx5d
replace rxcheckcat=23 if rx5==0|rx5==9
replace rxcheckcat=24 if rx5==. & (rx5d!=. & rx5d!=d(01jan2000))
replace rxcheckcat=25 if rx5!=. & rx5!=0 & rx5!=9 & (rx5d==.|rx5d==d(01jan2000))
replace rxcheckcat=26 if dot!=. & rx1d!=. & rx1d!=d(01jan2000) & rx1d<dot
replace rxcheckcat=27 if dot!=. & rx2d!=. & rx2d!=d(01jan2000) & rx2d<dot
replace rxcheckcat=28 if dot!=. & rx3d!=. & rx3d!=d(01jan2000) & rx3d<dot
replace rxcheckcat=29 if dot!=. & rx4d!=. & rx4d!=d(01jan2000) & rx4d<dot
replace rxcheckcat=30 if dot!=. & rx5d!=. & rx5d!=d(01jan2000) & rx5d<dot
replace rxcheckcat=31 if dlc!=. & rx1d!=. & rx1d!=d(01jan2000) & rx1d>dlc
replace rxcheckcat=32 if dlc!=. & rx2d!=. & rx2d!=d(01jan2000) & rx2d>dlc
replace rxcheckcat=33 if dlc!=. & rx3d!=. & rx3d!=d(01jan2000) & rx3d>dlc
replace rxcheckcat=34 if dlc!=. & rx4d!=. & rx4d!=d(01jan2000) & rx4d>dlc
replace rxcheckcat=35 if dlc!=. & rx5d!=. & rx5d!=d(01jan2000) & rx5d>dlc
replace rxcheckcat=36 if regexm(comments, "proterone") & primarysite!="" & (rx1!=5 & rx2!=5 & rx3!=5 & rx4!=5 & rx5!=5)
replace rxcheckcat=37 if regexm(comments, "alidomide") & primarysite!="" & (rx1!=4 & rx2!=4 & rx3!=4 & rx4!=4 & rx5!=4)
replace rxcheckcat=38 if regexm(comments, "ximab") & primarysite!="" & (rx1!=4 & rx2!=4 & rx3!=4 & rx4!=4 & rx5!=4)
replace rxcheckcat=39 if regexm(comments, "xametha") & primarysite!="" & (rx1!=5 & rx2!=5 & rx3!=5 & rx4!=5 & rx5!=5)
replace rxcheckcat=40 if regexm(comments, "rednisone") & primarysite!="" & (rx1!=5 & rx2!=5 & rx3!=5 & rx4!=5 & rx5!=5)
replace rxcheckcat=41 if regexm(comments, "cortisone") & primarysite!="" & (rx1!=5 & rx2!=5 & rx3!=5 & rx4!=5 & rx5!=5)
replace rxcheckcat=42 if regexm(comments, "rimid") & primarysite!="" & (rx1!=5 & rx2!=5 & rx3!=5 & rx4!=5 & rx5!=5)
replace rxcheckcat=43 if rx1==0 & (rx2!=.|rx3!=.|rx4!=.|rx5!=.)
/*
replace rxcheckcat=36 if regexm(comments, "proterone") & ((rx1!=. & rx1!=5) & (rx2!=. & rx2!=5) & (rx3!=. & rx3!=5) & (rx4!=. & rx4!=5) & (rx5!=. & rx5!=5))
replace rxcheckcat=37 if regexm(comments, "alidomide") & ((rx1!=. & rx1!=4) & (rx2!=. & rx2!=4) & (rx3!=. & rx3!=4) & (rx4!=. & rx4!=4) & (rx5!=. & rx5!=4))
replace rxcheckcat=38 if regexm(comments, "ximab") & ((rx1!=. & rx1!=4) & (rx2!=. & rx2!=4) & (rx3!=. & rx3!=4) & (rx4!=. & rx4!=4) & (rx5!=. & rx5!=4))
*/
label var rxcheckcat "Rx1-5 Check Category"
label define rxcheckcat_lab 1 "Check 1: rx1=0-no rx & rx1d!=./01jan00" 2 "Check 2: rx1=9-unk & rx1d!=./01jan00" ///
							3 "Check 3: rx1!=. & rx1!=0-no rx & rx1!=9-unk & rx1d==./01jan00" 4 "Check 4: rx1d after rx2d" 5 "Check 5: rx1d after rx3d" ///
							6 "Check 6: rx1d after rx4d" 7 "Check 7: rx1d after rx5d" 8 "Check 8: rx2=0-no rx or 9-unk" 9 "Check 9: rx2==. & rx2d!=./01jan00" ///
							10 "Check 10: rx2!=. & rx2!=0-no rx & rx2!=9-unk & rx2d==./01jan00" 11 "Check 11: rx2d after rx3d" 12 "Check 12: rx2d after rx4d" ///
							13 "Check 13: rx2d after rx5d" 14 "Check 14: rx3=0-no rx or 9-unk" 15 "Check 15: rx3==. & rx3d!=./01jan00" ///
							16 "Check 16: rx3!=. & rx3!=0-no rx & rx3!=9-unk & rx3d==./01jan00" 17 "Check 17: rx3d after rx4d" 18 "Check 18: rx3d after rx5d" ///
							19 "Check 19: rx4=0-no rx or 9-unk" 20 "Check 20: rx4==. & rx4d!=./01jan00" ///
							21 "Check 21: rx4!=. & rx4!=0-no rx & rx4!=9-unk & rx4d==./01jan00" 22 "Check 22: rx4d after rx5d" 23 "Check 23: rx5=0-no rx or 9-unk" ///
							24 "Check 24: rx5==. & rx5d!=./01jan00" 25 "Check 25: rx5!=. & rx5!=0-no rx & rx5!=9-unk & rx5d==./01jan00" ///
							26 "Check 26: Rx1 before InciD" 27 "Check 27: Rx2 before InciD" 28 "Check 28: Rx3 before InciD" 29 "Check 29: Rx4 before InciD" ///
							30 "Check 30: Rx5 before InciD" 31 "Check 31: Rx1 after DLC" 32 "Check 32: Rx2 after DLC" 33 "Check 33: Rx3 after DLC" ///
							34 "Check 34: Rx4 after DLC" 35 "Check 35: Rx5 after DLC" 36 "Check 36: Rx1-5!=hormono & Comments=Cyproterone" ///
							37 "Check 37: Rx1-5!=immuno & Comments=Thalidomide" 38 "Check 38: Rx1-5!=immuno & Comments=Rituximab" ///
							39 "Check 39: Rx1-5!=hormono & Comments=Dexamethasone" 40 "Check 40: Rx1-5!=hormono & Comments=Prednisone" ///
							41 "Check 41: Rx1-5!=hormono & Comments=Hydrocortisone" 42 "Check 42: Rx1-5!=hormono & Comments=Arimidex" ///
							43 "Check 43: Rx1=no rx & Rx2-5!=." ///
							,modify
label values rxcheckcat rxcheckcat_lab

** Create category for Other Treatments 1 & 2 check
** Need to create string variable for OtherRx1
** Need to change all othtreat1=="." to othtreat1==""
gen othtreat1=orx1
tostring othtreat1, replace
replace othtreat1="" if othtreat1=="." //23 changes
gen orxcheckcat=.
replace orxcheckcat=1 if orx1==. & (rx1==8|rx2==8|rx3==8|rx4==8|rx5==8)
replace orxcheckcat=2 if orx1!=. & orx2==""
replace orxcheckcat=3 if othtreat1!="" & length(othtreat1)!=1
//replace orxcheckcat=4 if regexm(orx2, "UNK")
label var orxcheckcat "OthRx1&2 Check Category"
label define orxcheckcat_lab 1 "Check 1: OtherRx 1 missing" 2 "Check 2: OtherRx 2 missing" 3 "Check 3: OtherRx1 invalid length" 4 "Check 4: orx2=UNKNOWN" ///
							,modify
label values orxcheckcat orxcheckcat_lab

** Create category for No Treatments 1 & 2 check
** Need to create string variable for NoRx1 & NoRx2
** Need to change all notreat1=="." to notreat1==""
** Need to change all notreat2=="." to notreat2==""
gen notreat1=norx1
tostring notreat1, replace
gen notreat2=norx2
tostring notreat2, replace
replace notreat1="" if notreat1=="." //23 changes
replace notreat2="" if notreat2=="." //23 changes
gen norxcheckcat=.
replace norxcheckcat=1 if norx1==. & (rx1==0|rx2==0|rx3==0|rx4==0|rx5==0)
replace norxcheckcat=2 if norx1!=. & (rx1!=0 & rx2!=0 & rx3!=0 & rx4!=0 & rx5!=0)
replace norxcheckcat=3 if norx1==. & norx2!=.
replace norxcheckcat=4 if notreat1!="" & length(notreat1)!=1
replace norxcheckcat=5 if notreat2!="" & length(notreat2)!=1
label var norxcheckcat "NoRx1&2 Check Category"
label define norxcheckcat_lab 1 "Check 1: NoRx 1 missing" 2 "Check 2: rx1-5!=0 & norx1!=." 3 "Check 3: norx1==. & norx2!=." 4 "Check 4: NoRx1 invalid length" ///
							  5 "Check 5: NoRx2 invalid length" ,modify
label values norxcheckcat norxcheckcat_lab

** Create category for Source Name check
** Need to create string variable for sourcename
** Need to change all sname=="." to sname==""
gen sname=sourcename
tostring sname, replace
replace sname="" if sname=="." //45 24apr18
gen sourcecheckcat=.
replace sourcecheckcat=1 if sname!="" & length(sname)!=1
replace sourcecheckcat=2 if (sourcename!=1 & sourcename!=2) & nftype==1 & dxyr>2013
replace sourcecheckcat=3 if sourcename==4 & nftype!=3 & dxyr>2013
replace sourcecheckcat=4 if sourcename==5 & nftype!=8 & dxyr>2013
replace sourcecheckcat=5 if sourcename!=1 & (nftype==9|nftype==10) & dxyr>2013
replace sourcecheckcat=6 if sourcename!=2 & nftype==12 & dxyr>2013
replace sourcecheckcat=7 if sourcename!=6 & nftype==2 & dxyr>2013
replace sourcecheckcat=8 if sourcename==8
label var sourcecheckcat "SourceName Check Category"
label define sourcecheckcat_lab 1 "Check 1: SourceName invalid length" 2 "Check 2: SourceName!=QEH/BVH; NFType=Hospital; dxyr>2013" ///
								3 "Check 3: SourceName=IPS-ARS; NFType!=Pathology; dxyr>2013" 4 "Check 4: SourceName=DeathRegistry; NFType!=Death Certif/PM; dxyr>2013" ///
								5 "Check 5: SourceName!=QEH; NFType=QEH Death Rec/RT bk; dxyr>2013" 6 "Check 6: SourceName!=BVH; NFType=BVH bk; dxyr>2013" ///
								7 "Check 7: SourceName!=Polyclinic; NFType=Poly/Dist.Hosp; dxyr>2013" 8 "Check 8: SourceName=Other(possibly invalid)" ///
								,modify
label values sourcecheckcat sourcecheckcat_lab

** Create category for Doctor check
gen doccheckcat=.
replace doccheckcat=1 if doctor=="Not Stated"
label var doccheckcat "Doctor Check Category"
label define doccheckcat_lab 1 "Check 1: Doctor invalid entry" ///
								,modify
label values doccheckcat doccheckcat_lab

** Create category for Doctor's Address check
gen docaddrcheckcat=.
replace docaddrcheckcat=1 if docaddr=="Not Stated"|docaddr=="NONE"
label var docaddrcheckcat "Doc Address Check Category"
label define docaddrcheckcat_lab 1 "Check 1: Doc Address invalid entry" ///
								,modify
label values docaddrcheckcat docaddrcheckcat_lab

** Create category for Sample Taken, Received and Report Dates check
gen rptcheckcat=.
replace rptcheckcat=1 if sampledate==. & (nftype>2 & nftype<6)
replace rptcheckcat=2 if recvdate==. & (nftype>2 & nftype<6)
replace rptcheckcat=3 if rptdate==. & (nftype>2 & nftype<6)
replace rptcheckcat=4 if (recvdate!=. & recvdate!=d(01jan2000)) & sampledate > recvdate
replace rptcheckcat=5 if (rptdate!=. & rptdate!=d(01jan2000)) & sampledate > rptdate
replace rptcheckcat=6 if (rptdate!=. & rptdate!=d(01jan2000)) & recvdate > rptdate
replace rptcheckcat=7 if dot!=. & sampledate!=. & sampledate!=d(01jan2000) & sampledate<dot
replace rptcheckcat=8 if dot!=. & recvdate!=. & recvdate!=d(01jan2000) & recvdate<dot
replace rptcheckcat=9 if dot!=. & rptdate!=. & rptdate!=d(01jan2000) & rptdate<dot
replace rptcheckcat=10 if dlc!=. & sampledate!=. & sampledate!=d(01jan2000) & sampledate>dlc
replace rptcheckcat=11 if sampledate!=. & sampledate!=d(01jan2000) & (nftype!=3 & nftype!=4 & nftype!=5) & (labnum==""|labnum=="99")
replace rptcheckcat=12 if recvdate!=. & recvdate!=d(01jan2000) & (nftype!=3 & nftype!=4 & nftype!=5) & (labnum==""|labnum=="99")
replace rptcheckcat=13 if rptdate!=. & rptdate!=d(01jan2000) & (nftype!=3 & nftype!=4 & nftype!=5) & (labnum==""|labnum=="99")
label var rptcheckcat "Rpt Dates Check Category"
label define rptcheckcat_lab 1 "Check 1: Sample Date missing" 2 "Check 2: Received Date missing" 3 "Check 3: Report Date missing" 4 "Check 4: sampledate after recvdate" ///
							 5 "Check 5: sampledate after rptdate" 6 "Check 6: recvdate after rptdate" 7 "Check 7: sampledate before InciD" ///
							 8 "Check 8: recvdate before InciD" 9 "Check 9: rptdate before InciD" 10 "Check 10: sampledate after DLC" ///
							 11 "Check 11: sampledate!=. & nftype!=lab~" 12 "Check 12: recvdate!=. & nftype!=lab~" 13 "Check 13: rptdate!=. & nftype!=lab~" ///
							 ,modify
label values rptcheckcat rptcheckcat_lab

** Create category for Admission, DFC and RT Dates check
gen datescheckcat=.
replace datescheckcat=1 if admdate==. & sourcename<3
replace datescheckcat=2 if dfc==. & (sourcename==3|sourcename==4)
replace datescheckcat=3 if rtdate==. & nftype==10
replace datescheckcat=4 if ((admdate!=. & admdate!=d(01jan2000)) & (dfc!=. & dfc!=d(01jan2000)) & (rtdate!=. & rtdate!=d(01jan2000))) & (dot!=.) & (admdate<dot|dfc<dot|rtdate<dot)
replace datescheckcat=5 if ((admdate!=. & admdate!=d(01jan2000)) & (dfc!=. & dfc!=d(01jan2000)) & (rtdate!=. & rtdate!=d(01jan2000))) & (dlc!=.) & (admdate>dlc|dfc>dlc|rtdate>dlc)
replace datescheckcat=6 if (admdate!=. & admdate!=d(01jan2000)) & (sourcename!=1 & sourcename!=2)
replace datescheckcat=7 if (dfc!=. & dfc!=d(01jan2000)) & (sourcename!=3 & sourcename!=4)
replace datescheckcat=8 if (rtdate!=. & rtdate!=d(01jan2000)) & nftype!=10
label var datescheckcat "Rpt Dates Check Category"
label define datescheckcat_lab 1 "Check 1: Admission Date missing" 2 "Check 2: DFC missing" 3 "Check 3: RT Date missing" 4 "Check 4: admdate/dfc/rtdate BEFORE InciD" ///
							 5 "Check 5: admdate/dfc/rtdate after DLC" 6 "Check 6: admdate!=. & sourcename!=hosp" 7 "Check 7: dfc!=. & sourcename!=PrivPhys/IPS" ///
							 8 "Check 8: rtdate!=. & nftype!=RT" ///
							 ,modify
label values datescheckcat datescheckcat_lab

	
** Put variables in order they are to appear	  
order pid fname lname init age sex dob natregno resident slc dlc /// 
	  parish cr5cod primarysite morph top lat beh hx

count //24


*************************************************
/*
BLANK & INCONSISTENCY CHECKS - PATIENT TABLE
CHECKS 1 - 46
IDENTIFY, REVIEW & CORRECT ERRORS
Note: Checks not always in sequential order due
	  to previous review format
*/
*************************************************

********************** 
** Unique PatientID **
**********************
count if pid=="" //0

** Person Search
count if persearch==0 //20
replace persearch=1 if pid!="20150093" //22 changes
replace persearch=2 if pid=="20150093" //1 change
count if persearch==3 //0
count if persearch==4 //0

** Create IARC Check Flag for CRICCS submission
gen iarcflag=1 if pid!="20181178"
replace iarcflag=2 if pid=="20181178"

** Patient record updated by
** Auto-generated by CR5 but may be needed when assigning who last accessed record.

** Date patient record updated
** Auto-generated by CR5 but may be needed when assigning who last accessed record.

************************
** PT Data Abstractor **
************************
** Check 1 - missing
count if ptda==. //0

** Check 2 - nonnumeric characters in numeric field
** contains a nonnumeric character so field needs correcting!

** Check 3 - length
count if ptda>14 & ptda<22 //0

**********************
** Casefinding Date **
**********************
** Check 4 - missing/ptdoa!=stdoa
count if ptdoa==. //0
count if ptdoa!=stdoa & ptdoa!=d(01jan2000) & stdoa!=d(01jan2000) //& (tumourtot<2 & sourcetot<2) //2 - no correction necessary
//list pid eid sid ptdoa stdoa dxyr cr5id if ptdoa!=stdoa & ptdoa!=d(01jan2000) & stdoa!=d(01jan2000) & (tumourtot<2 & sourcetot<2)

** Check 5 - invalid (future date)
** Need to create a variable with current date - to be used when cleaning dates
gen currentd=c(current_date)
gen double currentdatept=date(currentd, "DMY", 2017)
drop currentd
format currentdatept %dD_m_CY
label var currentdate "Current date PT"
count if ptdoa!=. & ptdoa>currentdatept //0

*****************
** Case Status **
*****************
** Check 6 - missing
count if cstatus==. //0

** Check 7 - invalid (case status=ABS, rec status!=Dup but TT DA is missing)
count if cstatus==1 & recstatus!=4 & ttda==. //0
//list pid cstatus ttda ttdoa dxyr cr5id if cstatus==1 & recstatus!=4 & ttda==.

** Check 8 - possibly invalid (patient record listed as duplicate)
count if cstatus==4 //0

** Check 9 - possibly invalid (patient record listed as deleted)
count if cstatus==2 //0

** Check 10 - possibly invalid (patient record listed as ineligible but tumour record status not ineligible/duplicate)
count if cstatus==3 & recstatus<3 //
//list pid cstatus recstatus resident beh dxyr cr5id if cstatus==3 & recstatus<3
//replace cstatus=1 if cstatus==3 & recstatus<3 //12 changes

** Check 11 - invalid (record status for all tumours in a patient record=duplicate)
count if cstatus==1 & recstatus==4 //108 - no review needed as already done
//list pid cstatus dxyr cr5id if cstatus==1 & recstatus==4

****************
** Notes Seen **
****************
** Added after these checks were sequentially written
** Additional check for PT variable
** Check 174 - Notes Seen (check for missed 2015 cases that were abstracted in this dofile) 
count if notesseen==0 & dxyr==2015 //0
//list pid cr5id if notesseen==0 & dxyr==2015
** Check main CR5db then correct
//replace notesseen=2 if notesseen==0 & dxyr==2015 //49 changes

** Check 175 - Notes Seen=pending retrieval; dxyr>2013 (for 2018 data collection this check will be revised)
count if notesseen==0 & dxyr>2013 //4 - cases found in MEDData
//list pid dxyr cr5id if notesseen==0 & dxyr>2013
** Check main CRdb or add to above code: (regexm(comments, "Notes seen")|comments, "Notes seen"))
//replace notesseen=4 if notesseen==0 & dxyr>2013 //0 changes

** Check 176 - Notes Seen=Yes but NS date=blank; dxyr=2015
count if notesseen==1 & nsdate==. & dxyr==2015 //0 - unnecessary to check each case for data cleaning but will flag in data review code
//list pid comments cr5id if notesseen==1 & nsdate==. & dxyr==2015
//replace nsdate=d(01jan2000) if notesseen==1 & nsdate==. & dxyr==2015 //81 changes
/*
** Check 177 - Notes Seen=No; recstatus!=dup; dxyr==2013
count if notesseen==3 & recstatus!=4 & dxyr==2013 //25
list pid recstatus cr5id if notesseen==3 & recstatus!=4 & dxyr==2013 
replace notesseen=4 if notesseen==3 & recstatus!=4 & dxyr==2013 //25 changes

** Check 178 - Eligibility (missed 2013 & 2014 cases)
** Check all recstatus=ineligible (may need to whittle down list by including only T1?) - checking for cases (esp. deaths) where DA listed as ineligible due to 
** onset interval/duration of illness being outside registration year.
count if recstatus==3 & dxyr==2014 & (nftype==8|nftype==9) //367
list pid cr5id dlc duration onsetint if recstatus==3 & dxyr==2014 & (nftype==8|nftype==9)
list comments if recstatus==3 & dxyr==2014 & (nftype==8|nftype==9)
list cr5cod if recstatus==3 & dxyr==2014 & (nftype==8|nftype==9)
*/
********************************
** First, Middle & Last Names **
********************************
** Check 23 - missing
count if fname=="" //0

** Check 24 - missing 
count if init=="" //0
//list pid dxyr cr5id if init==""

** Check 25 - missing 
count if lname=="" //0

*******************
** Date of Birth **
*******************
** Check 26 - missing (use birthdate var as partial dates are dropped when dob was formatted to a date var)
count if birthdate=="" & primarysite!="" //0
//list pid dobyear dobmonth dobday if birthdate==. & primarysite!=""

** Check 27 - missing but full NRN available
gen nrnday = substr(natregno,5,2)
count if dob==. & natregno!="" & natregno!="9999999999" & natregno!="999999-9999" & natregno!="99" & nrnday!="99" //0
//list pid cr5id dob natregno cstatus recstatus dxyr if dob==. & natregno!="" & natregno!="9999999999" & natregno!="999999-9999" & natregno!="99" & nrnday!="99"

** Check 28 - invalid (dob has future year)
gen dob_yr = year(dob)
count if dob!=. & dob_yr>2014 //0 - expected as this is a child ds
//list pid dob dob_yr if dob!=. & dob_yr>2014

** Check 29 - invalid (dob does not match natregno) - done visually as only 24 cases to be checked
/*
gen dob_year = year(dob) if natregno!="" & natregno!="9999999999" & natregno!="999999-9999" & nrnday!="99" & length(natregno)==11
gen yr1=.
replace yr1 = 20 if dob_year>1999
replace yr1 = 19 if dob_year<2000
replace yr1 = 19 if dob_year==.
replace yr1 = 99 if natregno=="99"
list pid dob_year dob natregno yr yr1 if dob_year!=. & dob_year > 1999
gen nrn = substr(natregno,1,6) if natregno!="" & natregno!="9999999999" & natregno!="999999-9999" & nrnday!="99" & length(natregno)==11
destring nrn, replace
format nrn %06.0f
nsplit nrn, digits(2 2 2) gen(year month day)
format year month day %02.0f
tostring yr1, replace
gen year2 = string(year,"%02.0f")
gen nrnyr = substr(yr1,1,2) + substr(year2,1,2)
destring nrnyr, replace
sort nrn
gen dobchk=mdy(month, day, nrnyr)
format dobchk %dD_m_CY
count if dob!=dobchk & dobchk!=. //13
list pid age natregno dob dobchk dob_year dot if dob!=dobchk & dobchk!=.
drop day month year nrnyr yr yr1 nrn
** Correct dob, where applicable
replace natregno=subinstr(natregno,"45","49",.) if pid=="20151250" //3 changes
replace natregno=subinstr(natregno,"48","49",.) if pid=="20150521" //2 changes
replace natregno=subinstr(natregno,"61","91",.) if pid=="20150294" //2 changes
replace dob=dobchk if dob!=dobchk & dobchk!=. & pid!="20151250" & pid!="20150521" & pid!="20150294" //6 changes
*/

***********************
** National Reg. No. **
***********************
sort pid
** Check 30 - missing 
count if natregno=="" & dob!=. //0
//list pid cr5id dob natregno cstatus recstatus dxyr if natregno=="" & dob!=.

** Check 31 - invalid length
count if length(natregno)<11 & natregno!="" //0
//list pid natregno if length(natregno)<11 & natregno!=""

*********
** Sex **
*********
** Check 32 - missing
count if sex==. | sex==9 //0
//list pid sex fname primarysite top if sex==.|sex==9
//replace sex=2 if sex==.|sex==9 //7 changes

** Check 33 - possibly invalid (first name, NRN and sex check: MALES)
gen nrnid=substr(natregno, -4,4)
count if sex==2 & nrnid!="9999" & regex(substr(natregno,-2,1), "[1,3,5,7,9]") //1
//list pid fname lname sex natregno primarysite top cr5id if sex==2 & nrnid!="9999" & regex(substr(natregno,-2,1), "[1,3,5,7,9]")
replace sex=1 if pid=="20172026" //1 change

** Check 34 - possibly invalid (sex=M; site=breast)
count if sex==1 & (regexm(cr5cod, "BREAST") | regexm(top, "^50")) //0 - no changes; all correct
//list pid fname lname natregno sex top cr5cod cr5id if sex==1 & (regexm(cr5cod, "BREAST") | regexm(top, "^50"))

** Check 35 - invalid (sex=M; site=FGS)
count if sex==1 & topcat>43 & topcat<52	& (regexm(cr5cod, "VULVA") | regexm(cr5cod, "VAGINA") | regexm(cr5cod, "CERVIX") | regexm(cr5cod, "CERVICAL") ///
								| regexm(cr5cod, "UTER") | regexm(cr5cod, "OVAR") | regexm(cr5cod, "PLACENTA")) //0
//list pid fname lname natregno sex top cr5cod cr5id if sex==1 & topcat>43 & topcat<52 & (regexm(cr5cod, "VULVA") | regexm(cr5cod, "VAGINA") ///
//								| regexm(cr5cod, "CERVIX") | regexm(cr5cod, "CERVICAL") | regexm(cr5cod, "UTER") | regexm(cr5cod, "OVAR") | regexm(cr5cod, "PLACENTA"))
								
** Check 36 - possibly invalid (first name, NRN and sex check: FEMALES)
count if sex==1 & nrnid!="9999" & regex(substr(natregno,-2,1), "[0,2,4,6,8]") //0
//list pid fname lname sex natregno primarysite top cr5id if sex==1 & nrnid!="9999" & regex(substr(natregno,-2,1), "[0,2,4,6,8]")
//replace sex=2 if pid=="20150537" //3 changes

** Check 37 - invalid (sex=F; site=MGS)
count if sex==2 & topcat>51 & topcat<56 & (regexm(cr5cod, "PENIS")|regexm(cr5cod, "PROSTAT")|regexm(cr5cod, "TESTIS")|regexm(cr5cod, "TESTIC")) //0
//list pid fname lname natregno sex top cr5cod cr5id if sex==2 & topcat>51 & topcat<56 & (regexm(cr5cod, "PENIS")|regexm(cr5cod, "PROSTAT") ///
//													  |regexm(cr5cod, "TESTIS")|regexm(cr5cod, "TESTIC"))


*********************
** Hospital Number **
*********************
** Check 38 - missing
count if hospnum=="" & retsource<8 //0
//list pid hospnum retsource cr5id if hospnum=="" & retsource<8

*********************
** Resident Status **
*********************
** Check 39 - missing
count if resident==. //0
//list pid resident recstatus cr5id if resident==.

*************************
** Status Last Contact **
*************************
** Check 40 - missing
count if slc==. & recstatus<3 //0
//list pid slc recstatus cr5id if slc==. & recstatus<3
tab slc recstatus,m


** Check 41 - invalid (slc=died;dlc=blank)
count if slc==2 & dlc==. //0
//list pid slc dlc cr5id if slc==2 & dlc==.

** Check 42 - invalid (slc=alive;dlc=blank)
count if slc==1 & dlc==. //1
//list pid slc dlc recstatus cr5id if slc==1 & dlc==.

** Check 43 - invalid (slc=alive;nftype=death info)
count if slc==1 & (nftype==8 | nftype==9) //0
//list pid slc nftype cr5id if slc==1 & (nftype==8 | nftype==9)


***********************
** Date Last Contact **
***********************
** Check 44 - missing
count if dlc==. & cstatus==1 & slc!=9 //0
//list pid slc dlc cr5id if dlc==. & cstatus==1 & slc!=9

** Check 45 - invalid (future date)
** Use already created variable called 'currentdatept';
** to be used when cleaning dates
count if dlc!=. & dlc>currentdatept //0

**************
** Comments **
**************
** Check 46 - missing
count if comments=="" & cstatus==1 //0
//list pid cstatus comments cr5id if comments=="" & cstatus==1
//replace comments="99" if comments=="" & cstatus==1 //7 changes


**********************************************************
/*
BLANK & INCONSISTENCY CHECKS - TUMOUR TABLE
CHECKS 47 - 119
IDENTIFY, REVIEW & CORRECT ERRORS
Note: Checks not always in sequential order due
	  to previous review format
*/
**********************************************************

*********************
** Unique TumourID **
*********************
count if eid=="" //0

**********************
** TT Record Status **
**********************
** This is auto-generated by CR5 while simultaneously allowing for manual input so
** there will never be any records with missing recstatus

** Check 47 - invalid (recstatus=pending)
count if recstatus==0 & dxyr!=. //0
//list pid dxyr cr5id resident age if recstatus==0 & dxyr!=.
//replace recstatus=1 if recstatus==0 & dxyr!=. //3 changes

** Check 48 - invalid(cstatus=CF;recstatus<>Pending)
count if recstatus!=0 & cstatus==0 & ttdoa!=. //3 - no changes needed
//list pid cstatus recstatus dxyr ttdoa pid2 cr5id if recstatus!=0 & cstatus==0 & ttdoa!=.
replace cstatus=1 if recstatus!=0 & cstatus==0 & ttdoa!=. //3 changes

** Check 49a - possibly invalid (tumour record listed as deleted)
count if recstatus==2 //0

** REVIEW ALL dxyr>2013 CASES FLAGGED AS INELIGIBLE SINCE SOME DISCOVERED IN 2014 AS INELIGIBLE WHICH ARE ELIGIBLE FOR REGISTRATION
** Points to note: (1) reason for ineligibility should be recorded by DA in Comments field; (2) dxyr should be updated with correct year.
count if recstatus==3 //0
//list pid cr5id dxyr ttda recstatus if recstatus==3

** Check 49b - review all cases flagged as ineligible to check for missed 2013 cases
** JC 30oct18: In later checks I incidentally discovered missed 2013 cases so added in this new check
count if recstatus==3 & cr5id=="T1S1" //0

*********************
** TT Check Status **
*********************
** This is auto-generated by CR5 while simultaneously allowing for manual input so
** there will never be any records with missing recstatus

** Check 50 - invalid (checkstatus=notdone;recstatus=pend/confirm;primarysite<>blank)
count if checkstatus==0 & recstatus<2 & primarysite!="" //0
//list pid dxyr checkstatus recstatus cr5id if checkstatus==0 & recstatus<2 & primarysite!=""

** Check 51 - invalid (checkstatus=invalid;recstatus=pend/confirm;primarysite<>blank)
count if checkstatus==3 & recstatus<2 & primarysite!="" //0
//list pid dxyr checkstatus recstatus cr5id if checkstatus==3 & recstatus<2 & primarysite!=""

** MP Sequence
** Auto-generated by CR5 but may be need later on.

** MP Total
** Auto-generated by CR5 but may be need later on.

** Tumour record updated by
** Auto-generated by CR5 but may be needed when assigning who last accessed record.

** Date tumour record updated
** Auto-generated by CR5 but may be needed when assigning who last accessed record.

************************
** TT Data Abstractor **
************************
** Check 52 - missing
count if ttda==. & primarysite!="" //0

** Length check not needed as this field is numeric
** Check 53 - invalid code
count if ttda!=. & ttda>14 & (ttda!=22 & ttda!=88 & ttda!=98 & ttda!=99) //0
//list pid ttda cr5id if ttda!=. & ttda>14 & (ttda!=22 & ttda!=88 & ttda!=98 & ttda!=99)

**********************
** Abstraction Date **
**********************
** Check 54 - missing
count if ttdoa==. & primarysite!="" //0

** Check 55 - invalid (future date)
gen currentd=c(current_date)
gen double currentdatett=date(currentd, "DMY", 2017)
drop currentd
format currentdatett %dD_m_CY
label var currentdatett "Current date TT"
count if ttdoa!=. & ttdoa>currentdatett //0
//list pid eid ttdoa currentdatett cr5id if ttdoa!=. & ttdoa>currentdatett

************
** Parish **
************
** Check 56 - missing
count if parish==. & addr!="" //0
//list pid parish addr cr5id if parish==. & addr!=""

*************
** Address **
*************
** Check 57 - missing
count if addr=="" & parish!=. & cstatus!=0 & cr5id=="T1S1" //0
//list pid parish addr sourcename recstatus cr5id if addr=="" & parish!=. & cstatus!=0 & cr5id=="T1S1"
//replace addr="99" if addr=="" & parish!=. & cstatus!=0 & cr5id=="T1S1" //7 changes - all ineligibles
* addr=="" & parish!=. & cstatus!=0 & cr5id=="T1S1" & recstatus==3 //7 changes

**********	
**	Age **
**********
** Check 58 - missing
count if (age==-1 | age==.) & dot!=. //0
//list pid cr5id if (age==-1 | age==.) & dot!=.
count if age==-1 //0
//replace age=999 if age==-1 //18 changes

** Check 59 - invalid (age<>incidencedate-dob); checked no errors
** Age (at INCIDENCE - to nearest year)
gen ageyrs = (dot - dob)/365.25 //
gen checkage=int(ageyrs)
drop ageyrs
label var checkage "Age in years at INCIDENCE"
count if dob!=. & dot!=. & age!=checkage //0
//list pid dot dob dotday dobday dotmonth dobmonth age checkage cr5id if dob!=. & dot!=. & age!=checkage
count if (dobday!=dotday & dobmonth!=dotmonth) & dob!=. & dot!=. & age!=checkage //0
//list pid dotday dobday dotmonth dobmonth if (dobday!=dotday & dobmonth!=dotmonth) & dob!=. & dot!=. & age!=checkage


******************
** Primary Site **
******************
** Check 61 - missing
count if primarysite=="" & topography!=. //2 - ineligibles
//list pid primarysite topography recstatus cr5id if primarysite=="" & topography!=.

** Check 63 - invalid(primarysite<>top)
sort topography pid
count if topcheckcat!=. //1 - all correct
//list pid primarysite topography topcat cr5id if topcheckcat!=.

/* 
Below cases are incorrect data that have been cleaned in Stata or MPs that were missed by cancer team at abstraction and should have been abstracted.
JC 25sep2018 corrected below as NS instructed for 2014 data cleaning I will clean data but for the future SDA to clean data:
*/
** List #1
/*
list pid primarysite topography cr5id if ///
		regexm(primarysite, "LIP") & !(strmatch(strupper(primarysite), "*SKIN*")|strmatch(strupper(primarysite), "*CERVIX*")) & (topography>9&topography!=148) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==8 ///
		| regexm(primarysite, "TONGUE") & (topography<19|topography>29) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==28 ///
		| regexm(primarysite, "GUM") & (topography<30|topography>39) & !(strmatch(strupper(primarysite), "*SKIN*")) ///
		| regexm(primarysite, "MOUTH") & (topography<40|topography>69) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==48 ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==58 ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==68 ///
		| regexm(primarysite, "GLAND") & (topography<79|topography>89) & !(strmatch(strupper(primarysite), "*MINOR*")|strmatch(strupper(primarysite), "*PROSTATE*")|strmatch(strupper(primarysite), "*THYROID*")|strmatch(strupper(primarysite), "*PINEAL*")|strmatch(strupper(primarysite), "*PITUITARY*")) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==88 ///
		| regexm(primarysite, "TONSIL") & (topography<90|topography>99) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==98 ///
		| regexm(primarysite, "OROPHARYNX") & (topography<100|topography>109) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==108 ///
		| regexm(primarysite, "NASOPHARYNX") & (topography<110|topography>119) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==118 ///
		| regexm(primarysite, "PYRIFORM") & (topography!=129&topography!=148) ///
		| regexm(primarysite, "HYPOPHARYNX") & (topography<130|topography>139) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==138 ///
		| (regexm(primarysite, "PHARYNX") & regexm(primarysite, "OVERLAP")) & (topography!=140&topography!=148) ///		
		| regexm(primarysite, "WALDEYER") & topography!=142 ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==148 ///
		| regexm(primarysite, "PHAGUS") & !(strmatch(strupper(primarysite), "*JUNCT*")) & (topography<150|topography>159) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==158 ///
		| (regexm(primarysite, "GASTR") | regexm(primarysite, "STOMACH")) & !(strmatch(strupper(primarysite), "*GASTROINTESTINAL*")|strmatch(strupper(primarysite), "*ABDOMEN*")) & (topography<160|topography>169) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==168 ///
		| (regexm(primarysite, "NUM") | regexm(primarysite, "SMALL")) & !(strmatch(strupper(primarysite), "*STERNUM*")|strmatch(strupper(primarysite), "*MEDIA*")|strmatch(strupper(primarysite), "*POSITION*")) & (topography<170|topography>179) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==178 ///
		| regexm(primarysite, "COLON") & !(strmatch(strupper(primarysite), "*RECT*")) & (topography<180|topography>189) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==188 ///
		| regexm(primarysite, "RECTO") & topography!=199 ///
		| regexm(primarysite, "RECTUM") & !(strmatch(strupper(primarysite), "*AN*")) & topography!=209 ///
		| regexm(primarysite, "ANUS") & !(strmatch(strupper(primarysite), "*RECT*")) & (topography<210|topography>212) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")|strmatch(strupper(primarysite), "*RECT*")|strmatch(strupper(primarysite), "*AN*")|strmatch(strupper(primarysite), "*JUNCT*")) & topography==218 ///
		| (regexm(primarysite, "LIVER")|regexm(primarysite, "HEPTO")) & !(strmatch(strupper(primarysite), "*GLAND*")) & (topography<220|topography>221) ///
		| regexm(primarysite, "GALL") & topography!=239 ///
		| (regexm(primarysite, "BILI")|regexm(primarysite, "VATER")) & !(strmatch(strupper(primarysite), "*INTRAHEP*")) & (topography<240|topography>241&topography!=249) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==248 ///
		| regexm(primarysite, "PANCREA") & !(strmatch(strupper(primarysite), "*ABDOMEN*")) & (topography<250|topography>259) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==258 ///
		| (regexm(primarysite, "BOWEL") | regexm(primarysite, "INTESTIN")) & !(strmatch(strupper(primarysite), "*SMALL*")|strmatch(strupper(primarysite), "*GASTRO*")) & (topography!=260&topography!=269) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==268 ///
		| regexm(primarysite, "NASAL") & !(strmatch(strupper(primarysite), "*SIN*")) & topography!=300 ///
		| regexm(primarysite, "EAR") & !(strmatch(strupper(primarysite), "*SKIN*")|strmatch(strupper(primarysite), "*FOREARM*")) & topography!=301 ///
		| regexm(primarysite, "SINUS") & !(strmatch(strupper(primarysite), "*INTRA*")|strmatch(strupper(primarysite), "*PHARYN*")) & (topography<310|topography>319) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==318 ///
		| (regexm(primarysite, "GLOTT") | regexm(primarysite, "CORD")) & !(strmatch(strupper(primarysite), "*TRANS*")|strmatch(strupper(primarysite), "*CNS*")|strmatch(strupper(primarysite), "*SPINAL*")) & (topography<320|topography>329) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==328 ///
		| regexm(primarysite, "TRACH") & topography!=339 ///
		| (regexm(primarysite, "LUNG") | regexm(primarysite, "BRONCH")) & (topography<340|topography>349) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==348 ///
		| regexm(primarysite, "THYMUS") & topography!=379 
*/
** All correct

** List #2
sort topography pid
/*
list pid primarysite topography cr5id if ///
		(regexm(primarysite, "HEART")|regexm(primarysite, "CARD")|regexm(primarysite, "STINUM")|regexm(primarysite, "PLEURA")) & !(strmatch(strupper(primarysite), "*GASTR*")|strmatch(strupper(primarysite), "*STOMACH*")) & (topography<380|topography>384) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==388 ///
		| regexm(primarysite, "RESP") & topography!=390 ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==398 ///
		| regexm(primarysite, "RESP") & topography!=399 ///
		| regexm(primarysite, "BONE") & !(strmatch(strupper(primarysite), "*MARROW*")) & (topography<400|topography>419) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==408 ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==418 ///
		| regexm(primarysite, "BLOOD") & !(strmatch(strupper(primarysite), "*MARROW*")) & topography!=420 ///
		| regexm(primarysite, "MARROW") & topography!=421 ///
		| regexm(primarysite, "SPLEEN") & topography!=422 ///
		| regexm(primarysite, "RETICU") & topography!=423 ///
		| regexm(primarysite, "POIETIC") & topography!=424 ///
		| regexm(primarysite, "SKIN") & (topography<440|topography>449) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==448 ///
		| regexm(primarysite, "NERV") & (topography<470|topography>479) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==478 ///
		| regexm(primarysite, "PERITON") & !(strmatch(strupper(primarysite), "*NODE*")) & (topography<480|topography>482) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==488 ///
		| regexm(primarysite, "TISSUE") & (topography<490|topography>499) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==498 ///
		| regexm(primarysite, "BREAST") & !(strmatch(strupper(primarysite), "*SKIN*")) & (topography<500|topography>509) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==508 ///
		| regexm(primarysite, "VULVA") & (topography<510|topography>519) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==518 ///
		| regexm(primarysite, "VAGINA") & topography!=529 ///
		| regexm(primarysite, "CERVIX") & (topography<530|topography>539) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==538 ///
		| (regexm(primarysite, "UTERI")|regexm(primarysite, "METRIUM")) & !(strmatch(strupper(primarysite), "*CERVIX*")|strmatch(strupper(primarysite), "*UTERINE*")|strmatch(strupper(primarysite), "*OVARY*")) & (topography<540|topography>549) ///
		| regexm(primarysite, "UTERINE") & !(strmatch(strupper(primarysite), "*CERVIX*")|strmatch(strupper(primarysite), "*CORPUS*")) & topography!=559 ///
		| regexm(primarysite, "OVARY") & topography!=569 ///
		| (regexm(primarysite, "FALLOPIAN")|regexm(primarysite, "LIGAMENT")|regexm(primarysite, "ADNEXA")|regexm(primarysite, "FEMALE")) & (topography<570|topography>579) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==578 ///
		| regexm(primarysite, "PLACENTA") & topography!=589 ///
		| (regexm(primarysite, "PENIS")|regexm(primarysite, "FORESKIN")) & (topography<600|topography>609) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==608 ///
		| regexm(primarysite, "PROSTATE") & topography!=619 ///
		| regexm(primarysite, "TESTIS") & (topography<620|topography>629) ///
		| (regexm(primarysite, "EPI")|regexm(primarysite, "SPERM")|regexm(primarysite, "SCROT")|regexm(primarysite, "MALE")) & !(strmatch(strupper(primarysite), "*FEMALE*")) & (topography<630|topography>639) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==638 ///
		| regexm(primarysite, "KIDNEY") & topography!=649 ///
		| regexm(primarysite, "RENAL") & topography!=659 ///
		| regexm(primarysite, "URETER") & !(strmatch(strupper(primarysite), "*BLADDER*")) & topography!=669 ///
		| regexm(primarysite, "BLADDER") & !(strmatch(strupper(primarysite), "*GALL*")) & (topography<670|topography>679) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==678 ///
		| (regexm(primarysite, "URETHRA")|regexm(primarysite, "URINARY")) & !(strmatch(strupper(primarysite), "*BLADDER*")) & (topography<680|topography>689) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==688 ///
		| (regexm(primarysite, "EYE")|regexm(primarysite, "RETINA")|regexm(primarysite, "CORNEA")|regexm(primarysite, "LACRIMAL")|regexm(primarysite, "CILIARY")|regexm(primarysite, "CHOROID")|regexm(primarysite, "ORBIT")|regexm(primarysite, "CONJUNCTIVA")) & !(strmatch(strupper(primarysite), "*SKIN*")) & (topography<690|topography>699) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==698 ///
		| regexm(primarysite, "MENINGE") & (topography<700|topography>709) ///
		| regexm(primarysite, "BRAIN") & !strmatch(strupper(primarysite), "*MENINGE*") & (topography<710|topography>719) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==718 ///
		| (regexm(primarysite, "SPIN")|regexm(primarysite, "CAUDA")|regexm(primarysite, "NERV")) & (topography<720|topography>729) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==728 ///
		| regexm(primarysite, "THYROID") & topography!=739 ///
		| regexm(primarysite, "ADRENAL") & (topography<740|topography>749)
*/
** All correct

** List #3
/*
list pid ttda primarysite topography cr5id if ///
		(regexm(primarysite, "PARATHYROID")|regexm(primarysite, "PITUITARY")|regexm(primarysite, "CRANIOPHARYNGEAL")|regexm(primarysite, "CAROTID")|regexm(primarysite, "ENDOCRINE")) & (topography<750|topography>759) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==758 ///
		| (regexm(primarysite, "NOS")|regexm(primarysite, "DEFINED")) & !(strmatch(strupper(primarysite), "*SKIN*")|strmatch(strupper(primarysite), "*NOSE*")|strmatch(strupper(primarysite), "*NOSTRIL*")|strmatch(strupper(primarysite), "*STOMACH*")|strmatch(strupper(primarysite), "*GENITAL*")|strmatch(strupper(primarysite), "*PENIS*")) & (topography<760|topography>767) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==768 ////
		| regexm(primarysite, "NODE") & (topography<770|topography>779) ///
		| !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==778 ///
		| regexm(primarysite, "UNKNOWN") & topography!=809
*/
** All correct

****************
** Topography **
****************
** Check 64 - missing
count if topography==. & primarysite!=""  //0
//list pid primarysite topography cr5id if topography==. & primarysite!=""

** Check 65 - length
** Need to change all top=="." to top==""
replace top="" if top=="." //0 changes
count if top!="" & length(top)!=3 //0
//list pid top topography cr5id if top!="" & length(top)!=3

** No other checks needed as covered in primarysite checks 62 & 63

****************************
** Histology & Morphology **
****************************
** Check 66 - Histology missing
count if (hx==""|hx=="99"|hx=="9999"|regexm(hx, "UNK")) & morph!=. //0
//list pid hx morph cr5id if (hx==""|hx=="99"|hx=="9999"|regexm(hx, "UNK")) & morph!=.

** Check 67 - Morphology missing
count if (morph==.|morph==99|morph==9999) & hx!="" //0
//list pid hx morph cr5id if (morph==.|morph==99|morph==9999) & hx!=""

** Check 68 - Morphology length
** Need to create string variable for morphology
gen morphology=morph
tostring morphology, replace
** Need to change all morphology=="." to morphology==""
replace morphology="" if morphology=="." //0 changes
count if morphology!="" & length(morphology)!=4 //0
//list pid morphology morph cr5id if morphology!="" & length(morphology)!=4

** Check 70 - possibly invalid (hx vs beh)
sort pid	
count if (beh==2|beh==3) & !(strmatch(strupper(hx), "*MALIG*")|strmatch(strupper(hx), "*CANCER*")|strmatch(strupper(hx), "*OMA*") ///
		 |strmatch(strupper(hx), "*SUSPICIOUS*")|strmatch(strupper(hx), "*CIN*")|strmatch(strupper(hx), "*LEU*")|strmatch(strupper(hx), "*META*") ///
		 |strmatch(strupper(hx), "*INVAS*")|strmatch(strupper(hx), "*CARC*")|strmatch(strupper(hx), "*HIGH GRADE*")|strmatch(strupper(hx), "*ESSENTIAL*") ///
		 |strmatch(strupper(hx), "*KLATSKIN*")|strmatch(strupper(hx), "*MYELODYSPLAS*")|strmatch(strupper(hx), "*MYELOPROLIFER*") ///
		 |strmatch(strupper(hx), "*CHRONIC IDIOPATHIC*")|strmatch(strupper(hx), "*BOWEN*")|strmatch(strupper(hx), "*POLYCYTHEMIA*") ///
		 |strmatch(strupper(hx), "*WILMS*")|strmatch(strupper(hx), "*MULLERIAN*")|strmatch(strupper(hx), "*YOLK*")|strmatch(strupper(hx), "*REFRACTORY*") ///
		 |strmatch(strupper(hx), "*ACUTE MYELOID*")|strmatch(strupper(hx), "*PAGET*")|strmatch(strupper(hx), "*PLASMA CELL*") ///
		 |strmatch(strupper(hx), "*PIN III*")|strmatch(strupper(hx), "*NEUROENDOCRINE*")|strmatch(strupper(hx), "*TERATOID/RHABOID*") ///
		 |strmatch(strupper(hx), "*INTRA-EPITHELIAL NEOPLASIA*")) & hx!="CLL" & hx!="PIN" & hx!="HGCGIN /  AIS" //1
/*
list pid hx beh cr5id if (beh==2|beh==3) & !(strmatch(strupper(hx), "*MALIG*")|strmatch(strupper(hx), "*CANCER*")|strmatch(strupper(hx), "*OMA*") ///
						 |strmatch(strupper(hx), "*SUSPICIOUS*")|strmatch(strupper(hx), "*CIN*")|strmatch(strupper(hx), "*LEU*")|strmatch(strupper(hx), "*META*") ///
						 |strmatch(strupper(hx), "*INVAS*")|strmatch(strupper(hx), "*CARC*")|strmatch(strupper(hx), "*HIGH GRADE*") ///
						 |strmatch(strupper(hx), "*ESSENTIAL*")|strmatch(strupper(hx), "*KLATSKIN*")|strmatch(strupper(hx), "*MYELODYSPLAS*") ///
						 |strmatch(strupper(hx), "*MYELOPROLIFER*")|strmatch(strupper(hx), "*CHRONIC IDIOPATHIC*")|strmatch(strupper(hx), "*BOWEN*") ///
						 |strmatch(strupper(hx), "*POLYCYTHEMIA*")|strmatch(strupper(hx), "*WILMS*")|strmatch(strupper(hx), "*MULLERIAN*") ///
						 |strmatch(strupper(hx), "*YOLK*")|strmatch(strupper(hx), "*REFRACTORY*")|strmatch(strupper(hx), "*ACUTE MYELOID*") ///
						 |strmatch(strupper(hx), "*PAGET*")|strmatch(strupper(hx), "*PLASMA CELL*")|strmatch(strupper(hx), "*PIN III*") ///
						 |strmatch(strupper(hx), "*NEUROENDOCRINE*")|strmatch(strupper(hx), "*TERATOID/RHABOID*") ///
						 |strmatch(strupper(hx), "*INTRA-EPITHELIAL NEOPLASIA*")) & hx!="CLL" & hx!="PIN" & hx!="HGCGIN /  AIS"
*/
						 **All correct

** Check 72 - invalid (morph vs basis)
count if morph==8000 & (basis==6|basis==7|basis==8) //0
//list pid hx basis cr5id if morph==8000 & (basis==6|basis==7|basis==8)

** Check 74 - invalid(hx<>morph)
sort pid

** morphcheckcat 1: Hx=Undifferentiated Ca & Morph!=8020
count if morphcheckcat==1 //0
//list pid hx morph basis cfdx cr5id if morphcheckcat==1, string(100)

** morphcheckcat 2: Hx!=Undifferentiated Ca & Morph==8020
count if morphcheckcat==2 //0
//list pid hx morph basis cfdx cr5id if morphcheckcat==2

** morphcheckcat 3: Hx=Papillary ca & Morph!=8050
count if morphcheckcat==3 //0
//list pid hx morph top basis beh cr5id if morphcheckcat==3

** morphcheckcat 4: Hx=Papillary serous adenoca & Morph!=8460 & Top!=ovary/peritoneum
count if morphcheckcat==4 //0 (thyroid/renal=M8260 & ovary/peritoneum=M8461 & endometrium=M8460)
//list pid top hx morph top basis beh cr5id if morphcheckcat==4

** morphcheckcat 5: Hx=Papillary & intraduct/intracyst & Morph!=8503
count if morphcheckcat==5 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==5

** morphcheckcat 6: Hx=Keratoacanthoma & Morph!=8070
count if morphcheckcat==6 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==6

** morphcheckcat 7: Hx=Squamous & microinvasive & Morph!=8076
count if morphcheckcat==7 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==7

** morphcheckcat 8: Hx=Bowen excluding clinical & basis==6/7/8 & morph!=8081 (want to check skin SCCs that have bowen disease is coded to M8081) 
count if morphcheckcat==8 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==8

** morphcheckcat 9: Hx=adenoid BCC & morph!=8098
count if morphcheckcat==9 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==9

** morphcheckcat 10: Hx=infiltrating BCC excluding nodular & morph!=8092
count if morphcheckcat==10 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==10

** morphcheckcat 11: Hx=superficial BCC excluding nodular & basis=6/7/8 & morph!=8091
count if morphcheckcat==11 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==11

** morphcheckcat 12: Hx=sclerotic/sclerosing BCC excluding nodular & morph!=8091
count if morphcheckcat==12 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==12

** morphcheckcat 13: Hx=nodular BCC excluding clinical & morph!=8097
count if morphcheckcat==13 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==13

** morphcheckcat 14: Hx!=nodular BCC excluding clinical & morph==8097
count if morphcheckcat==14 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==14

** morphcheckcat 15: Hx=BCC & SCC excluding basaloid & morph!=8094
count if morphcheckcat==15 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==15

** morphcheckcat 16: Hx!=BCC & SCC & morph==8094
count if morphcheckcat==16 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==16

** morphcheckcat 17: Hx!=transitional/urothelial & morph==8120
count if morphcheckcat==17 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==17

** morphcheckcat 18: Hx=transitional/urothelial excluding papillary & morph!=8120
count if morphcheckcat==18 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==18

** morphcheckcat 19: Hx=transitional/urothelial & papillary & morph!=8130
count if morphcheckcat==19 //0
//list pid primarysite hx morph basis beh  cr5id if morphcheckcat==19

** morphcheckcat 20: Hx=villous & adenoma excluding tubulo & morph!=8261
count if morphcheckcat==20 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==20

** morphcheckcat 21: Hx=intestinal excl. stromal (GISTs) & morph!=8144
count if morphcheckcat==21 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==21

** morphcheckcat 22: Hx=villoglandular & morph!=8263
count if morphcheckcat==22 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==22

** morphcheckcat 23: Hx!=clear cell & morph==8310
count if morphcheckcat==23 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==23

** morphcheckcat 24: Hx==clear cell & morph!=8310
count if morphcheckcat==24 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==24

** morphcheckcat 25: Hx==cyst & renal & morph!=8316
count if morphcheckcat==25 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==25

** morphcheckcat 26: Hx==chromophobe & renal & morph!=8317
count if morphcheckcat==26 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==26

** morphcheckcat 27: Hx==sarcomatoid & renal & morph!=8318
count if morphcheckcat==27 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==27

** morphcheckcat 28: Hx==follicular excl.minimally invasive & morph!=8330
count if morphcheckcat==28 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==28

** morphcheckcat 29: Hx==follicular & minimally invasive & morph!=8335
count if morphcheckcat==29 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==29

** morphcheckcat 30: Hx==microcarcinoma & morph!=8341
count if morphcheckcat==30 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==30

** morphcheckcat 31: Hx!=endometrioid & morph==8380
count if morphcheckcat==31 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==31

** morphcheckcat 32: Hx==poroma & morph!=8409 & mptot<2
count if morphcheckcat==32 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==32

** morphcheckcat 33: Hx==serous excl. papillary & morph!=8441
count if morphcheckcat==33 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==33

** morphcheckcat 34: Hx==mucinous excl. endocervical,producing,secreting,infiltrating duct & morph!=8480
count if morphcheckcat==34 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==34

** morphcheckcat 35: Hx!=mucinous/pseudomyxoma peritonei & morph==8480
count if morphcheckcat==35 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==35

** morphcheckcat 36: Hx==acinar & duct & morph!=8552
count if morphcheckcat==36 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==36

** morphcheckcat 37: Hx==intraduct & micropapillary or intraduct & clinging & morph!=8507
count if morphcheckcat==37 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==37

** morphcheckcat 38: Hx!=intraduct & micropapillary or intraduct & clinging & morph==8507
count if morphcheckcat==38 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==38

** morphcheckcat 39: Hx!=ductular & morph==8521
count if morphcheckcat==39 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==39

** morphcheckcat 40: Hx!=duct & Hx==lobular & morph!=8520
count if morphcheckcat==40 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==40

** morphcheckcat 41: Hx==duct & lobular & morph!=8522
count if morphcheckcat==41 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==41

** morphcheckcat 42: Hx!=acinar & morph==8550
count if morphcheckcat==42 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==42

** morphcheckcat 43: Hx!=adenosquamous & morph==8560
count if morphcheckcat==43 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==43

** morphcheckcat 44: Hx!=thecoma & morph==8600
count if morphcheckcat==44 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==44

** morphcheckcat 45: Hx!=sarcoma & morph==8800
count if morphcheckcat==45 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==45

** morphcheckcat 46: Hx=spindle & sarcoma & morph!=8801
count if morphcheckcat==46 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==46

** morphcheckcat 47: Hx=undifferentiated & sarcoma & morph!=8805
count if morphcheckcat==47 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==47

** morphcheckcat 48: Hx=fibrosarcoma & Hx!=myxo/dermato/mesothelioma & morph!=8810
count if morphcheckcat==48 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==48

** morphcheckcat 49: Hx=fibrosarcoma & Hx=myxo & morph!=8811
count if morphcheckcat==49 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==49

** morphcheckcat 50: Hx=fibro & histiocytoma & morph!=8830 (see morphcheckcat=92 also!)
count if morphcheckcat==50 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==50

** morphcheckcat 51: Hx!=dermatofibrosarcoma & morph==8832
count if morphcheckcat==51 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==51

** morphcheckcat 52: Hx==stromal sarcoma high grade & morph!=8930
count if morphcheckcat==52 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==52

** morphcheckcat 53: Hx==stromal sarcoma low grade & morph!=8931
count if morphcheckcat==53 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==53

** morphcheckcat 54: Hx==gastrointestinal stromal tumour & morph!=8936
count if morphcheckcat==54 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==54

** morphcheckcat 55: Hx==mixed mullerian tumour & Hx!=mesodermal & morph!=8950
count if morphcheckcat==55 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==55

** morphcheckcat 56: Hx==mesodermal mixed & morph!=8951
count if morphcheckcat==56 //0 20mar18; 0 04jul18
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==56

** morphcheckcat 57: Hx==wilms or nephro & morph!=8960
count if morphcheckcat==57 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==57

** morphcheckcat 58: Hx==mesothelioma & Hx!=fibrous or sarcoma or epithelioid/papillary or cystic & morph!=9050
count if morphcheckcat==58 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==58

** morphcheckcat 59: Hx==fibrous or sarcomatoid mesothelioma & Hx!=epithelioid/papillary or cystic & morph!=9051
count if morphcheckcat==59 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==59

** morphcheckcat 60: Hx==epitheliaoid or papillary mesothelioma & Hx!=fibrous or sarcomatoid or cystic & morph!=9052
count if morphcheckcat==60 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==60

** morphcheckcat 61: Hx==biphasic mesothelioma & morph!=9053
count if morphcheckcat==61 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==61

** morphcheckcat 62: Hx==adenomatoid tumour & morph!=9054
count if morphcheckcat==62 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==62

** morphcheckcat 63: Hx==cystic mesothelioma & morph!=9055
count if morphcheckcat==63 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==63

** morphcheckcat 64: Hx==yolk & morph!=9071
count if morphcheckcat==64 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==64

** morphcheckcat 65: Hx==teratoma & morph!=9080
count if morphcheckcat==65 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==65

** morphcheckcat 66: Hx==teratoma & Hx!=metastatic or malignant or embryonal or teratoblastoma or immature & morph==9080
count if morphcheckcat==66 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==66

** morphcheckcat 67: Hx==complete hydatidiform mole & Hx!=choriocarcinoma & beh==3 & morph==9100
count if morphcheckcat==67 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==67

** morphcheckcat 68: Hx==choriocarcinoma & morph!=9100
count if morphcheckcat==68 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==68

** morphcheckcat 69: Hx==epithelioid hemangioendothelioma & Hx!=malignant & morph==9133
count if morphcheckcat==69 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==69

** morphcheckcat 70: Hx==osteosarcoma & morph!=9180
count if morphcheckcat==70 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==70

** morphcheckcat 71: Hx==chondrosarcoma & morph!=9220
count if morphcheckcat==71 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==71

** morphcheckcat 72: Hx=myxoid and Hx!=chondrosarcoma & morph==9231
count if morphcheckcat==72 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==72

** morphcheckcat 73: Hx=retinoblastoma and poorly or undifferentiated & morph==9511
count if morphcheckcat==73 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==73

** morphcheckcat 74: Hx=meningioma & Hx!=meningothelial/endotheliomatous/syncytial & morph==9531
count if morphcheckcat==74 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==74

** morphcheckcat 75: Hx=mantle cell lymphoma & morph!=9673
count if morphcheckcat==75 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==75

** morphcheckcat 76: Hx=T-cell lymphoma & Hx!=leukemia & morph!=9702
count if morphcheckcat==76 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==76

** morphcheckcat 77: Hx=non-hodgkin lymphoma & Hx!=cell (to excl. mantle, large, cleaved, small, etc) & morph!=9591
count if morphcheckcat==77 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==77

** morphcheckcat 78: Hx=precursor t-cell acute lymphoblastic leukemia & morph!=9837
** note: ICD-O-3 has another matching code (M9729) but WHO Classification notes that M9837 more accurate
count if morphcheckcat==78 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==78

** morphcheckcat 79: Hx=CML (chronic myeloid/myelogenous leukemia) & Hx!=genetic studies & morph==9863
** note: HemeDb under CML, NOS notes 'Presumably myelogenous leukemia without genetic studies done would be coded to M9863.'
count if morphcheckcat==79 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==79

** morphcheckcat 80: Hx=CML (chronic myeloid/myelogenous leukemia) & Hx!=BCR/ABL1 & morph==9875
** note: HemeDb under CML, NOS notes 'Presumably myelogenous leukemia without genetic studies done would be coded to M9863.'
count if morphcheckcat==80 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==80

** morphcheckcat 81: Hx=acute myeloid leukemia & Hx!=myelodysplastic/down syndrome & basis==cyto/heme/histology... & morph!=9861
count if morphcheckcat==81 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==81

** morphcheckcat 82: Hx=acute myeloid leukemia & down syndrome & morph!=9898
count if morphcheckcat==82 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==82

** morphcheckcat 83: Hx=secondary myelofibrosis & recstatus!=3 & morph==9931 or 9961
count if morphcheckcat==83 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==83

** morphcheckcat 84: Hx=polycythemia & Hx!=vera/proliferative/primary & morph==9950
count if morphcheckcat==84 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==84

** morphcheckcat 85: Hx=myeloproliferative & Hx!=essential & dxyr<2010 & morph==9975
count if morphcheckcat==85 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==85

** morphcheckcat 86: Hx=myeloproliferative & Hx!=essential & dxyr>2009 & morph==9960
count if morphcheckcat==86 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==86

** morphcheckcat 87: Hx=refractory anemia & Hx!=sideroblast or blast & morph!=9980
count if morphcheckcat==87 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==87

** morphcheckcat 88: Hx=refractory anemia & sideroblast & Hx!=excess blasts & morph!=9982
count if morphcheckcat==88 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==88

** morphcheckcat 89: Hx=refractory anemia & excess blasts &  Hx!=sidero & morph!=9983
count if morphcheckcat==89 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==89

** morphcheckcat 90: Hx=myelodysplasia & Hx!=syndrome & recstatus!=inelig. & morph==9989
count if morphcheckcat==90 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==90

** morphcheckcat 91: Hx=acinar & top!=619 & morph!=8550
count if morphcheckcat==91 //0
//list pid primarysite hx morph cr5id if morphcheckcat==91

** morphcheckcat 92: Hx!=fibro & histiocytoma & morph=8830 (see morphcheckcat=50 also!)
count if morphcheckcat==92 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==92

** morphcheckcat 93: Hx=acinar & top=619 & morph!=8140
/*
This check added on 22oct18 after update re morphcheckcat 91 above.  
*/
count if morphcheckcat==93 //0
//list pid primarysite hx morph cr5id if morphcheckcat==93
//replace morph=8140 if morphcheckcat==93 //1 change

** morphcheckcat 94: Hx=hodgkin & morph=non-hodgkin
count if morphcheckcat==94 //0
//list pid hx morph cr5id if morphcheckcat==94

** morphcheckcat 95: Hx=leukaemia & morph=9729
count if morphcheckcat==95 //0
//list pid hx morph cr5id if morphcheckcat==95

** morphcheckcat 96: Hx=lymphoma & morph=9837
count if morphcheckcat==96 //0
//list pid hx morph cr5id if morphcheckcat==96

** Check 76 - invalid(primarysite vs hx)
** hxcheckcat 1: PrimSite=Blood/Bone Marrow & Hx=Lymphoma 
count if hxcheckcat==1 //0
//list pid top hx morph cr5id if hxcheckcat==1

** hxcheckcat 2: PrimSite=Thymus & MorphCat!=13 (Thymic epithe. neo.) & Hx!=carcinoma
count if hxcheckcat==2 //0
//list pid primarysite top hx morph cr5id if hxcheckcat==2

** hxcheckcat 3: PrimSite!=Bone Marrow & MorphCat==56 (Myelodysplastic Syn.)
count if hxcheckcat==3 //0
//list pid primarysite top hx morph cr5id if hxcheckcat==3

** hxcheckcat 4: PrimSite!=thyroid & Hx=Renal & Hx=Papillary ca & Morph!=8260
count if hxcheckcat==4 //0
//list pid primarysite hx morph cr5id if hxcheckcat==4

** hxcheckcat 5: PrimSite==thyroid & Hx!=Renal & Hx=Papillary ca & adenoca & Morph!=8260
count if hxcheckcat==5 //0
//list pid primarysite hx morph cr5id if hxcheckcat==5

** hxcheckcat 6: PrimSite==ovary or peritoneum & Hx=Papillary & Serous & Morph!=8461
count if hxcheckcat==6 //0
//list pid hx morph cr5id if hxcheckcat==6

** hxcheckcat 7: PrimSite==endometrium & Hx=Papillary & Serous & Morph!=8460
count if hxcheckcat==7 //0
//list pid primarysite hx morph cr5id if hxcheckcat==7

** hxcheckcat 8: PrimSite!=bone; Hx=plasmacytoma & Morph==9731(bone)
count if hxcheckcat==8 //0
//list pid primarysite hx morph cr5id if hxcheckcat==8

** hxcheckcat 9: PrimSite==bone; Hx=plasmacytoma & Morph==9734(not bone)
count if hxcheckcat==9 //0
//list pid primarysite hx morph cr5id if hxcheckcat==9

** hxcheckcat 10: PrimSite!=meninges; Hx=meningioma
count if hxcheckcat==10 //0
//list pid primarysite top hx morph cr5id if hxcheckcat==10

** hxcheckcat 11: PrimSite=Blood/Bone Marrow & Hx=HTLV+T-cell Lymphoma 
count if hxcheckcat==11 //0
//list pid top hx morph cr5id if hxcheckcat==11

** Check 78 - invalid(age/site/histology)
** agecheckcat 1: Age<3 & Hx=Hodgkin Lymphoma
count if agecheckcat==1 //0
//list pid cr5id age hx morph dxyr if agecheckcat==1

** agecheckcat 2: Age 10-14 & Hx=Neuroblastoma
count if agecheckcat==2 //0
//list pid cr5id age hx morph dxyr if agecheckcat==2

** agecheckcat 3: Age 6-14 & Hx=Retinoblastoma
count if agecheckcat==3 //0
//list pid cr5id age hx morph dxyr if agecheckcat==3

** agecheckcat 4: Age 9-14 & Hx=Wilm's Tumour
count if agecheckcat==4 //0
//list pid cr5id age hx morph dxyr if agecheckcat==4

** agecheckcat 5: Age 0-8 & Hx=Renal carcinoma
count if agecheckcat==5 //0
//list pid cr5id age hx morph dxyr if agecheckcat==5

** agecheckcat 6: Age 6-14 & Hx=Hepatoblastoma
count if agecheckcat==6 //0
//list pid cr5id age hx morph dxyr if agecheckcat==6

** agecheckcat 7: Age 0-8 & Hx=Hepatic carcinoma
count if agecheckcat==7 //0
//list pid cr5id age hx morph dxyr if agecheckcat==7

** agecheckcat 8: Age 0-5 & Hx=Osteosarcoma
count if agecheckcat==8 //0
//list pid cr5id age hx morph dxyr if agecheckcat==8

** agecheckcat 9: Age 0-5 & Hx=Chondrosarcoma
count if agecheckcat==9 //0
//list pid cr5id age hx morph dxyr if agecheckcat==9

** agecheckcat 10: Age 0-3 & Hx=Ewing sarcoma
count if agecheckcat==10 //0
//list pid cr5id age hx morph dxyr if agecheckcat==10

** agecheckcat 11: Age 8-14 & Hx=Non-gonadal germ cell
count if agecheckcat==11 //0
//list pid cr5id age hx morph dxyr if agecheckcat==11

** agecheckcat 12: Age 0-4 & Hx=Gonadal carcinoma
count if agecheckcat==12 //0
//list pid cr5id age hx morph dxyr if agecheckcat==12

** agecheckcat 13: Age 0-5 & Hx=Thyroid carcinoma
count if agecheckcat==13 //0
//list pid cr5id age hx morph dxyr if agecheckcat==13

** agecheckcat 14: Age 0-5 & Hx=Nasopharyngeal carcinoma
count if agecheckcat==14 //0
//list pid cr5id age hx morph dxyr if agecheckcat==14

** agecheckcat 15: Age 0-4 & Hx=Skin carcinoma
count if agecheckcat==15 //0
//list pid cr5id age hx morph dxyr if agecheckcat==15

** agecheckcat 16: Age 0-4 & Hx=Carcinoma, NOS
count if agecheckcat==16 //0
//list pid cr5id age hx morph dxyr if agecheckcat==16

** agecheckcat 17: Age 0-14 & Hx=Mesothelial neoplasms
count if agecheckcat==17 //0
//list pid cr5id age hx morph dxyr if agecheckcat==17

** agecheckcat 18: Age <40 & Hx=814_ & Top=61_
count if agecheckcat==18 //0
//list pid cr5id age hx morph dxyr if agecheckcat==18

** agecheckcat 19: Age <20 & Top=15._,19._,20._,21._,23._,24._,38.4,50._53._,54._,55._
count if agecheckcat==19 //0
//list pid cr5id age primarysite top hx morph dxyr if agecheckcat==19

** agecheckcat 20: Age <20 & Top=17._ & Morph<9590(ie.not lymphoma)
count if agecheckcat==20 //0
//list pid cr5id age hx morph dxyr if agecheckcat==20

** agecheckcat 21: Age <20 & Top=33._ or 34._ or 18._ & Morph!=824_(ie.not carcinoid)
count if agecheckcat==21 //0
//list pid cr5id age hx morph dxyr if agecheckcat==21

** agecheckcat 22: Age >45 & Top=58._ & Morph==9100(chorioca.)
count if agecheckcat==22 //0
//list pid cr5id age hx morph dxyr if agecheckcat==22

** agecheckcat 23: Age <26 & Morph==9732(myeloma) or 9823(BCLL)
count if agecheckcat==23 //0
//list pid cr5id age hx morph dxyr if agecheckcat==23

** agecheckcat 24: Age >15 & Morph==8910/8960/8970/8981/8991/9072/9470/9490/9500/951_/9687
count if agecheckcat==24 //0
//list pid cr5id age hx morph dxyr if agecheckcat==24

** agecheckcat 25: Age <15 & Morph==9724
count if agecheckcat==25 //0
//list pid cr5id age hx morph dxyr if agecheckcat==25


** Check 80 - invalid(sex/histology)
** sexcheckcat 1: Sex=male & Hx family=23,24,25,26,27
count if sexcheckcat==1 //0
//list pid cr5id age hx morph hxfamcat dxyr if sexcheckcat==1

** sexcheckcat 2: Sex=female & Hx family=28 or 29
count if sexcheckcat==2 //0
//list pid cr5id age hx morph hxfamcat dxyr if sexcheckcat==2


** Check 82 - invalid(site/histology)
** sitecheckcat 1: NOT haem. tumours
count if sitecheckcat==1 //0
//list pid cr5id age hx morph dxyr if sitecheckcat==1

** sitecheckcat 2: NOT site-specific carcinomas
count if sitecheckcat==2 //0
//list pid cr5id age hx morph dxyr if sitecheckcat==2

** sitecheckcat 3: NOT site-specific sarcomas
count if sitecheckcat==3 //0
//list pid cr5id age hx morph dxyr if sitecheckcat==3

** sitecheckcat 4: Top=Bone; Hx=Giant cell sarc. except bone
count if sitecheckcat==4 //0
//list pid cr5id age hx morph dxyr if sitecheckcat==4

** sitecheckcat 5: NOT sarcomas affecting CNS
count if sitecheckcat==5 //0
//list pid cr5id age hx morph dxyr if sitecheckcat==5

** sitecheckcat 6: NOT sites for Kaposi sarcoma
count if sitecheckcat==6 //0
//list pid cr5id age hx morph dxyr if sitecheckcat==6

** sitecheckcat 7: Top=Bone; Hx=extramedullary plasmacytoma
count if sitecheckcat==7 //0
//list pid cr5id age hx morph dxyr if sitecheckcat==7


****************
** Laterality **
****************
** Check 83 - Laterality missing
count if lat==. & primarysite!="" //0
//list pid lat primarysite cr5id if lat==. & primarysite!=""
count if latcat==. & lat!=. //0 - some latcats may change due to corrections in clean dofile being run after prep dofile
//list pid lat primarysite cr5id if latcat==. & lat!=.
count if lat==8 //0 - lat should=0(not paired site) if latcat=0 or blank
//list pid lat primarysite latcat cr5id if lat==8
count if lat==8 & (latcat==0|latcat==.) //0
//list pid lat top latcat cr5id if lat==8 & (latcat==0|latcat==.)
//replace lat=0 if lat==8 & (latcat==0|latcat==.) //40 changes

** Check 84 - Laterality length
** Need to create string variable for laterality
gen laterality=lat
tostring laterality, replace
** Need to change all laterality=="." to laterality==""
replace laterality="" if laterality=="." //778 changes made
count if laterality!="" & length(laterality)!=1 //0
//list pid laterality lat cr5id if laterality!="" & length(laterality)!=1
 

** Check 86 - invalid(laterality)
sort pid

** latcheckcat 1: COD='left'; COD=cancer (codcat!=1); latcat>0; lat!=left
count if latcheckcat==1 //0
//list pid cr5id primarysite lat cr5cod dxyr if latcheckcat==1

** latcheckcat 2: COD='right'; COD=cancer (codcat!=1); latcat>0; lat!=right
count if latcheckcat==2 //0
//list pid cr5id primarysite lat cr5cod dxyr if latcheckcat==2

** latcheckcat 3: CFdx='left'; latcat>0; lat!=left
count if latcheckcat==3 //0
//list pid cr5id primarysite lat cfdx dxyr if latcheckcat==3 ,string(100)

** latcheckcat 4: CFdx='right'; latcat>0; lat!=right
count if latcheckcat==4 //0
//list pid cr5id primarysite lat cfdx dxyr if latcheckcat==4 ,string(100)

** latcheckcat 5: topog==809 & lat!=0-paired site (in accord with SEER Prog. Coding manual 2016 pg 82 #1.a.)
count if latcheckcat==5 //0
//list pid cr5id primarysite topography lat dxyr if latcheckcat==5
//replace lat=0 if latcheckcat==5 & topography==809 //6 changes
count if lat!=0 & topography==809 //0
//list pid cr5id primarysite topography lat dxyr if lat!=0 & topography==809

** latcheckcat 6: latcat>0 & lat==0 or 8 (in accord with SEER Prog. Coding manual 2016 pg 82 #2)
count if latcheckcat==6 //0
//list pid cr5id topography lat latcat dxyr if latcheckcat==6

** latcheckcat 7: latcat!=ovary,lung,eye,kidney & lat==4 (in accord with SEER Prog. Coding manual 2016 pg 82 #4 & IARC MP recommendations for recording #1)
count if latcheckcat==7 //0
//list pid cr5id primarysite topography lat latcat dxyr if latcheckcat==7

** latcheckcat 8: latcat=meninges/brain/CNS/skin-face,trunk & dxyr>2009 & lat!=5 & lat=NA (in accord with SEER Prog. Coding manual 2016 pg 83 #5) (lat 5-midline only for 2010 onwards dx)
count if latcheckcat==8 //0
//list pid cr5id primarysite topography lat latcat dxyr if latcheckcat==8

** latcheckcat 9: latcat!=meninges/brain/CNS/skin-face,trunk & dxyr>2009 & lat==5 (in accord with SEER Prog. Coding manual 2016 pg 83 #5.a.i.) (lat 5-midline only for 2010 onwards dx)
count if latcheckcat==9 //0
//list pid cr5id primarysite topography lat latcat dxyr if latcheckcat==9

** latcheckcat 10: latcat!=0,8,12,19,20 & basis==0 & lat=NA (in accord with SEER Prog. Coding manual 2016 pg 83 #6.b.)
count if latcheckcat==10 //0
//list pid cr5id primarysite topography lat latcat dxyr if latcheckcat==10

** latcheckcat 11: primsite=thyroid and lat!=NA
count if latcheckcat==11 //0
//list pid cr5id primarysite topography lat latcat dxyr if latcheckcat==11

** latcheckcat 12: latcat=no lat cat (i.e. laterality n/a); topog!=809; lat!=N/A; latcheckcat==. (this can capture any that have not already been corrected in above latcheckcats)
count if latcheckcat==12 //2
list pid cr5id topography lat latcat dxyr if latcheckcat==12
replace lat=0 if latcheckcat==12 //2 changes

** latcheckcat 13: lat=N/A & dxyr>2013 (cases dx>2013 should use code '0-not paired site')
count if latcheckcat==13 //0
//list pid cr5id topography lat latcat if latcheckcat==13
count if lat==8 & dxyr>2012 //0 - flagged and corrected in below latcheckcat 14
//list pid cr5id topography lat latcat if lat==8 & dxyr>2013

** latcheckcat 14: lat=N/A & latcat!=0
count if latcheckcat==14 //0
//list pid cr5id topography lat latcat if latcheckcat==14

** latcheckcat 15: lat=unk for a paired site
count if latcheckcat==15 //0
//list pid cr5id topography lat latcat cfdx if latcheckcat==15, string(100)

** latcheckcat 16: lat=9 & top=ovary
count if latcheckcat==16 //0
//list pid cr5id topography lat latcat cfdx if latcheckcat==16, string(100)


***************
** Behaviour **
***************
** Check 87 - Behaviour missing
count if beh==. & primarysite!="" //0
//list pid beh primarysite cr5id if beh==. & primarysite!=""

** Check 88 - Behaviour length
** Need to create string variable for behaviour
gen behaviour=beh
tostring behaviour, replace
** Need to change all behaviour=="." to behaviour==""
replace behaviour="" if behaviour=="." //779 changes made
count if behaviour!="" & length(behaviour)!=1 //0
//list pid behaviour beh cr5id if behaviour!="" & length(behaviour)!=1
  
** Check 90 - invalid(behaviour)
** behcheckcat 1: Beh!=2 & Morph==8503
count if behcheckcat==5 //0
//list pid hx morph basis beh cr5id if behcheckcat==5

** behcheckcat 2: Beh!=2 & Morph==8077
count if behcheckcat==2 //0
//list pid primarysite hx morph basis beh cr5id if behcheckcat==2

** behcheckcat 3: Hx=Squamous & microinvasive & Beh=2 & Morph!=8076
count if behcheckcat==3 //0
//list pid primarysite hx morph basis beh cr5id if behcheckcat==3

** behcheckcat 4: Hx=Bowen & Beh!=2 (want to check skin SCCs that have bowen disease is coded to beh=in-situ)
count if behcheckcat==4 //0
//list pid primarysite hx morph basis beh cr5id if behcheckcat==4

** behcheckcat 5: PrimSite==appendix & Morph==8240 & Beh!=1
count if behcheckcat==5 //0
//list pid primarysite hx morph basis beh cr5id if behcheckcat==5

** behcheckcat 6: Hx=adenoma excl. adenocarcinoma & invasion & Morph==8263 & Beh!=2
count if behcheckcat==6 //0
//list pid hx morph beh cr5id if behcheckcat==6

** behcheckcat 7: Morph not listed in ICD-O-3 (IARCcrgTools Check pg 8)
count if behcheckcat==7 //0
//list pid hx morph beh cr5id if behcheckcat==7

** behcheckcat 8: Hx=tumour & beh>1
count if behcheckcat==8 //0
//list pid hx morph beh recstatus cr5id if behcheckcat==8

** Below checks taken from IARCcrgTools pg 8.
** behsitecheckcat 1: Beh==2 & Top==C40._(bone)
count if behsitecheckcat==1 //0
//list pid primarysite topography beh cr5id if behsitecheckcat==1

** behsitecheckcat 2: Beh==2 & Top==C41._(bone,NOS)
count if behsitecheckcat==2 //0
//list pid primarysite topography beh cr5id if behsitecheckcat==2

** behsitecheckcat 3: Beh==2 & Top==C42._(haem)
count if behsitecheckcat==3 //0
//list pid primarysite topography beh cr5id if behsitecheckcat==3

** behsitecheckcat 4: Beh==2 & Top==C47._(ANS)
count if behsitecheckcat==4 //0
//list pid primarysite topography beh cr5id if behsitecheckcat==4

** behsitecheckcat 5: Beh==2 & Top==C49._(tissues)
count if behsitecheckcat==5 //0
//list pid primarysite topography beh cr5id if behsitecheckcat==5

** behsitecheckcat 6: Beh==2 & Top==C70._(meninges)
count if behsitecheckcat==6 //0
//list pid primarysite topography beh cr5id if behsitecheckcat==6

** behsitecheckcat 7: Beh==2 & Top==C71._(brain)
count if behsitecheckcat==7 //0
//list pid primarysite topography beh cr5id if behsitecheckcat==7

** behsitecheckcat 8: Beh==2 & Top==C72._(CNS)
count if behsitecheckcat==8 //0
//list pid primarysite topography beh cr5id if behsitecheckcat==8

***********
** Grade **
***********
** Check 91 - Grade missing
count if grade==. & primarysite!="" //0
//list pid grade primarysite cr5id if grade==. & primarysite!=""

** Check 92 - Grade length
** Need to create string variable for grade
gen str_grade=grade
tostring str_grade, replace
** Need to change all grade=="." to grade==""
replace str_grade="" if str_grade=="." //779 changes made
count if str_grade!="" & length(str_grade)!=1 //0
//list pid str_grade grade cr5id if str_grade!="" & length(str_grade)!=1
 

** Check 94 - invalid(grade)

** Below code only applies to 2014 data as 2008 & 2013 data did not collect grade.
** Taken from IACRcrgTools pg 9
** gradecheckcat 1: Beh<3 & Grade<9 & DxYr>2013
count if gradecheckcat==1 //0
//list pid grade beh morph cr5id if gradecheckcat==1

** gradecheckcat 2: Grade>=5 & <=8 & Hx<9590 & DxYr>2013
count if gradecheckcat==2 //0
//list pid grade beh morph cr5id if gradecheckcat==2

** gradecheckcat 3: Grade>=1 & <=4 & Hx>=9590 & DxYr>2013
count if gradecheckcat==3 //0
//list pid hx morph grade beh morph cr5id if gradecheckcat==3 ,string(100)

** gradecheckcat 4: Grade!=5 & Hx=9702-9709,9716-9726(!=9719),9729,9827,9834,9837 & DxYr>2013
count if gradecheckcat==4 //0
//list pid grade beh morph cr5id if gradecheckcat==4

** gradecheckcat 5: Grade!=5 or 7 & Hx=9714 & DxYr>2013
count if gradecheckcat==5 //0
//list pid grade beh morph cr5id if gradecheckcat==5

** gradecheckcat 6: Grade!=5 or 8 & Hx=9700/9701/9719/9831 & DxYr>2013
count if gradecheckcat==6 //0
//list pid grade beh morph cr5id if gradecheckcat==6

** gradecheckcat 7: Grade!=6 & Hx=>=9670,<=9699,9712,9728,9737,9738,>=9811,<=9818,9823,9826,9833,9836 & DxYr>2013
count if gradecheckcat==7 //0
//list pid hx grade beh morph cr5id if gradecheckcat==7 ,string(100)
//replace grade=6 if gradecheckcat==7 //10 changes

** gradecheckcat 8: Grade!=8 & Hx=9948 & DxYr>2013
count if gradecheckcat==8 //0
//list pid grade beh morph cr5id if gradecheckcat==8

** gradecheckcat 9: Grade!=1 & Hx=8331/8851/9187/9511 & DxYr>2013
count if gradecheckcat==9 //0
//list pid grade beh morph cr5id if gradecheckcat==9

** gradecheckcat 10: Grade!=2 & Hx=8249/8332/8858/9083/9243/9372 & DxYr>2013
count if gradecheckcat==10 //0
//list pid grade beh morph cr5id if gradecheckcat==10

** gradecheckcat 11: Grade!=3 & HX=8631/8634 & DxYr>2013
count if gradecheckcat==11 //0
//list pid grade beh morph cr5id if gradecheckcat==11

** gradecheckcat 12: Grade!=4 & Hx=8020/8021/8805/9062/9082/9392/9401/9451/9505/9512 & DxYr>2013
count if gradecheckcat==12 //0
//list pid grade beh morph cr5id if gradecheckcat==12

** gradecheckcat 13: Grade=9 & cfdx/md/consrpt=Gleason & DxYr>2013
count if gradecheckcat==13 //0
** list pid grade cfdx md consrpt cr5id if gradecheckcat==13
//list pid grade cr5id if gradecheckcat==13

** gradecheckcat 14: Grade=9 & cfdx/md/consrpt=Nottingham/Bloom & DxYr>2013
count if gradecheckcat==14 //0
//list pid grade cfdx md consrpt cr5id if gradecheckcat==14

** gradecheckcat 15: Grade=9 & cfdx/md/consrpt=Fuhrman & DxYr>2013
count if gradecheckcat==15 //0
//list pid grade cfdx md consrpt cr5id if gradecheckcat==15

** gradecheckcat 16: Grade!=6 & Hx=9732 & DxYr>2013 (see MM in HemeDb for grade)
count if gradecheckcat==16 //0
//list pid grade beh morph cr5id if gradecheckcat==16

** gradecheckcat 17: Grade!=9/blank & DxYr<2014
count if (grade!=9 & grade!=.) & dxyr<2014 //0
//list pid grade dxyr cr5id if (grade!=9 & grade!=.) & dxyr<2014
//replace grade=9 if (grade!=9 & grade!=.) & dxyr<2014 //7 changes

************************
** Basis of Diagnosis **
************************
** Check 95 - Basis missing
count if basis==. & primarysite!="" //0
//list pid basis primarysite cr5id if basis==. & primarysite!=""

** Check 96 - Basis length
** Need to create string variable for basis
gen bas=basis
tostring bas, replace
** Need to change all bas=="." to bas==""
replace bas="" if bas=="." //779 changes made
count if bas!="" & length(bas)!=1 //0
//list pid bas basis cr5id if bas!="" & length(bas)!=1

** Check 98 - invalid(basis)

** bascheckcat 1: morph==8000 & (basis==6|basis==7|basis==8)
count if bascheckcat==1 //0
//list pid cr5id hx basis dxyr if bascheckcat==1

** bascheckcat 2: hx=...OMA & basis!=6/7/8
count if bascheckcat==2 //0
//list pid cr5id hx basis dxyr if bascheckcat==2

** bascheckcat 3: Basis not missing & basis!=cyto/heme/histology... & Hx!=...see BOD/Hx Control pg 47,48 of IARCcrgTools Check Program
count if bascheckcat==3 //0
//list pid primarysite hx morph basis cr5id if bascheckcat==3

** bascheckcat 4: Hx=mass; Basis=DCO; Morph==8000 - If topog=CNS then terms such as neoplasm & tumour eligible criteria (see Eligibility SOP)
count if bascheckcat==4 //0
//list pid cr5id primarysite hx morph basis dxyr if bascheckcat==4

** bascheckcat 5: Basis=DCO; Comments='Notes seen'
count if bascheckcat==5 //1 - correct
//list pid basis dxyr cr5id comment if bascheckcat==5 ,string(100)
** Check in main CR5 db to see if true DCO then dot=dlc or if to correct basis,dot,dxyr (e.g. if notes seen by DA etc.)

** bascheckcat 6: Basis!=lab test; Comments=PSA; top=prostate
count if bascheckcat==6 //0
//list pid basis dxyr cr5id comment if bascheckcat==6 ,string(100)

** bascheckcat 7: Basis=unk; Comments=Notes seen
count if bascheckcat==7 //1
//list pid basis dxyr cr5id comment if bascheckcat==7 ,string(100)
//replace basis=1 if pid=="20155203"|pid=="20155226" //2 changes

** bascheckcat 8: Basis!=hx of prim; top=haem; nftype=BM
count if bascheckcat==8 //0
//list pid basis dxyr cr5id comment if bascheckcat==8 ,string(100)

** bascheckcat 9: Basis!=haem/hx of prim; top=haem; Comments=blood
count if bascheckcat==9 //0
//list pid basis dxyr cr5id comment if bascheckcat==9 ,string(100)


*********************
** Summary Staging **
*********************
** NOTE 1: Staging only done at 5 year intervals so staging done on 2013 data then 2018 and so on;
** NOTE 2: In upcoming years of data collection (2018 dc year), more stagecheckcat checks will be compiled based on site in SEER Summary Staging manual.

** Check 99 - For 2014 data, replace blank and non-blank stage with code 'NA'
count if staging==. & dot!=. & dxyr!=2013 //17 - all correct
//list pid cr5id recstatus dxyr if staging==. & dot!=. & dxyr!=2013
//replace staging=8 if staging==. & dot!=. & dxyr!=2013 //108 changes
count if staging!=8 & dot!=. & dxyr==2015 //8
//list pid cr5id staging recstatus dxyr if staging!=8 & dot!=. & dxyr==2015
replace staging=8 if staging!=8 & dot!=. & dxyr==2015 //2 changes

********************
** Incidence Date **
********************
** Check 103 - InciDate missing
count if dot==. & primarysite!="" //0
//list pid primarysite dotyear dotmonth dotday cr5id if dot==. & primarysite!=""
** replace missing incidence dates using dotyear, dotmonth, dotday and
** checking main CR5 to ensure missing day and month (30jun) is logical
** in terms of CR5 comments and other dates e.g. admdate, dlc, treatment dates, etc.

** Check 104 - InciDate (future date)
count if dot!=. & dot>currentdatett //0

** Check 106 - invalid(InciDate)

** dotcheckcat 1: InciDate before DOB
count if dotcheckcat==1 //0
//list pid cr5id dot dob ttda dxyr if dotcheckcat==1

** dotcheckcat 2: InciDate after DLC
count if dotcheckcat==2 //0
//list pid cr5id dot dlc ttda dxyr if dotcheckcat==2

** dotcheckcat 3: Basis=DCO & InciDate!=DLC
/* Since errors corrected in bascheckcat 5 above then to get true list for dotcheckcat 3 need to write code
count if dotcheckcat==3 //112
list pid cr5id dot dlc basis ttda cstatus recstatus dxyr if dotcheckcat==3
*/
count if dot!=. & dlc!=. & basis==0 & dot!=dlc //0
//list pid dot dlc basis ttda cstatus recstatus cr5id if dot!=. & dlc!=. & basis==0 & dot!=dlc

** dotcheckcat 4: InciDate<>DFC/AdmDate/RTdate/SampleDate/ReceiveDate/RptDate/DLC (2014 onwards)
count if dotcheckcat==4 //4 - all correct
//list pid dot dfc admdate rtdate sampledate recvdate rptdate cr5id if dotcheckcat==4

** dotcheckcat 5: InciDate=DFC; DFC after AdmDate/RTdate/SampleDate/ReceiveDate/RptDate (2014 onwards)
count if dotcheckcat==5 //0
//list pid cr5id dot dfc admdate rtdate sampledate recvdate rptdate ttda dxyr if dotcheckcat==5

** dotcheckcat 6: InciDate=AdmDate; AdmDate after DFC/RTdate/SampleDate/ReceiveDate/RptDate (2014 onwards)
count if dotcheckcat==6 //0
//list pid cr5id dot dfc admdate rtdate sampledate recvdate rptdate ttda dxyr if dotcheckcat==6

** dotcheckcat 7: InciDate=RTdate; RTdate after DFC/AdmDate/SampleDate/ReceiveDate/RptDate (2014 onwards)
count if dotcheckcat==7 //0
//list pid cr5id dot dfc admdate rtdate sampledate recvdate rptdate ttda dxyr if dotcheckcat==7

** dotcheckcat 8: InciDate=SampleDate; SampleDate after DFC/AdmDate/RTdate/ReceiveDate/RptDate (2014 onwards)
count if dotcheckcat==8 //0
//list pid cr5id dot dfc admdate rtdate sampledate recvdate rptdate ttda dxyr if dotcheckcat==8

** dotcheckcat 9: InciDate=ReceiveDate; ReceiveDate after DFC/AdmDate/RTdate/SampleDate/RptDate (2014 onwards)
count if dotcheckcat==9 //0
//list pid cr5id dot dfc admdate rtdate sampledate recvdate rptdate ttda dxyr if dotcheckcat==9

** dotcheckcat 10: InciDate=RptDate; RptDate after DFC/AdmDate/RTdate/SampleDate/ReceiveDate (2014 onwards)
count if dotcheckcat==10 //0
//list pid cr5id dot dfc admdate rtdate sampledate recvdate rptdate ttda dxyr if dotcheckcat==10


********************
** Diagnosis Year **
********************
** Check 107 - DxYr missing
count if dxyr==. //0 - already corrected in 1_prep_cancer_dc.do
//list pid ptdoa stdoa dot dxyr cr5id if dxyr==.

** Check 108 - DxYr length
** Need to create string variable for DxYr
gen diagyr=dxyr
tostring diagyr, replace
** Need to change all diagyr=="." to diagyr==""
replace diagyr="" if diagyr=="." //0 changes made
count if diagyr!="" & length(diagyr)!=4 //0
//list pid diagyr dxyr cr5id if diagyr!="" & length(diagyr)!=4
 

** Check 110 - invalid(dxyr)

** dxyrcheckcat 1: dotyear!=dxyr
** 20080706 T4: JC 11JUL2018 changed dxyr from 2011 to 2010
count if dxyrcheckcat==1 //0
//list pid cr5id dot dotyear dxyr ttda if dxyrcheckcat==1

** dxyrcheckcat 2: admyear!=dxyr & dxyr>2013
count if dxyrcheckcat==2 //0
//list pid cr5id admdate admyear dxyr ttda if dxyrcheckcat==2

** dxyrcheckcat 3: dfcyear!=dxyr & dxyr>2013
count if dxyrcheckcat==3 //0
//list pid cr5id dfc dfcyear dxyr ttda if dxyrcheckcat==3

** dxyrcheckcat 4: rtyear!=dxyr & dxyr>2013
count if dxyrcheckcat==4 //0
//list pid cr5id rtdate rtyear dxyr ttda if dxyrcheckcat==4


****************
** Consultant **
****************
** No checks on this as checks done under 'Doctor' variable


********************
** Treatments 1-5 **
********************
** NOTE 1: Treatment only collected at 5 year intervals so treatment collected on 2013 data then 2018 and so on;
** NOTE 2: In upcoming years of data collection (2018 dc year), more rxcheckcat checks will be compiled based on data.

** Check 111 - For 2014 data, replace blank and non-blank treatment with code 'ND'
count if rx1==. //& dxyr==2014 //10
//list pid cr5id if rx1==. & dxyr==2014
//replace rx1=9 if rx1==. & dxyr==2014 //1,658 changes
count if (rx1!=. & rx1!=9) //& dxyr==2014 //14
//list pid rx1 dxyr cr5id if (rx1!=. & rx1!=9) & dxyr==2014
//replace rx1=9 if (rx1!=. & rx1!=9) & dxyr==2014 //814 changes

count if rx2!=. // dxyr==2014 //2
//list pid rx2 cr5id if rx2!=. & dxyr==2014
//replace rx2=. if rx2!=. & dxyr==2014 //249 changes

count if rx3!=. //1
count if rx4!=. //0
count if rx5!=. //0

*************************
** Treatments 1-5 Date **
*************************
** Missing dates already captured in checkflags in Rx1-5

** Check 115 - For 2014 data, replace non-blank treatment dates with missing value
count if rx1d!=. //& dxyr==2014 //14
//replace rx1d=. if rx1d!=. & dxyr==2014 //796 changes

count if rx2d!=. //& dxyr==2014 //2
//list pid rx2d cr5id if rx2d!=. & dxyr==2014
//replace rx2d=. if rx2d!=. & dxyr==2014 //246 changes

count if rx3d!=. //& dxyr==2014 //24
count if rx4d!=. //& dxyr==2014 //24
count if rx5d!=. //& dxyr==2014 //24

***************************
** Other Treatment 1 & 2 **
***************************
** NOTE 1: Treatment only collected at 5 year intervals so treatment collected on 2013 data then 2018 and so on;
** NOTE 2: In upcoming years of data collection (2018 dc year), more rxcheckcat checks will be compiled based on data.

** Check 116 - For 2014 data, replace non-blank other treatment with missing value
count if orx1!=. //& dxyr==2014 //1

count if orx2!="" //& dxyr==2014 //1
//list pid orx2 dxyr cr5id if orx2!="" & dxyr==2014
//replace orx2="" if orx2!="" & dxyr==2014 //3 changes


***************************
** No Treatments 1 and 2 **
***************************
** NOTE 1: Treatment only collected at 5 year intervals so treatment collected on 2013 data then 2018 and so on;
** NOTE 2: In upcoming years of data collection (2018 dc year), more rxcheckcat checks will be compiled based on data.


** Check 119 - For 2014 data, replace non-blank no treatment with missing value
count if norx1!=. //& dxyr==2014 //0
//list pid norx1 dxyr cr5id if norx1!=. & dxyr==2014
//replace norx1=. if norx1!=. & dxyr==2014 //5 changes

count if norx2!=. //& dxyr==2014 //0




**********************************************************
** BLANK & INCONSISTENCY CHECKS - SOURCE TABLE
** CHECKS 120 - 173
** (1) FLAG POSSIBLE INCONSISTENCIES 
** (2) EXPORT TO EXCEL FOR CANCER TEAM TO CORRECT
**********************************************************

*********************
** Unique SourceID **
*********************
count if sid=="" //0

************************
** ST Data Abstractor **
************************
** Check 120 - missing
count if stda==. //0
//list pid cr5id if stda==.

** Length check not needed as this field is numeric
** Check 121 - invalid code
count if stda!=. & stda>14 & (stda!=22 & stda!=88 & stda!=98 & stda!=99) //0
//list pid stda cr5id if stda!=. & stda>14 & (stda!=22 & stda!=88 & stda!=98 & stda!=99)

*****************
** Source Date **
*****************
** Check 122 - missing
count if stdoa==. //0
//list pid cr5id if stdoa==.

** Check 123 - invalid (future date)
** Need to create a variable with current date;
** to be used when cleaning dates
gen currentdst=c(current_date)
gen double currentdatest=date(currentdst, "DMY", 2017)
drop currentdst
format currentdatest %dD_m_CY
label var currentdatest "Current date ST"
count if stdoa!=. & stdoa>currentdatest //0

*************
** NF Type **
*************
** Check 124 - NFtype missing
count if nftype==. //4 - leave blank as source is blank
//list pid nftype dxyr cr5id if nftype==.

** Check 125 - NFtype length
** Need to create string variable for nftype
gen notiftype=nftype
tostring notiftype, replace
** Need to change all notiftype"." to notiftype""
replace notiftype="" if notiftype=="." //4 changes made
count if notiftype!="" & length(notiftype)>2 //0
//list pid notiftype nftype dxyr cr5id if notiftype!="" & length(notiftype)>2

** Check 126 - NFtype=Other(possibly invalid)
count if nftype==13 //0
//list pid nftype dxyr cr5id if nftype==13


*****************
** Source Name **
*****************
** NOTE 1: Patient notes only to be seen at 5 year intervals so e.g. notes seen on 2013 data then 2018 and so on;
** NOTE 2: In upcoming years of data collection (2018 dc year), more checks may be compiled based on data.

** Check 127 - Source Name missing (NB: some may have been since corrected in main CR5 by cancer team as this was first run on 24apr18 using 05mar2018 data)
count if sourcename==. //0
//list pid nftype sourcename dxyr cr5id if sourcename==.

** Check 129 - invalid(sourcename)

** sourcecheckcat 1: SourceName invalid length
count if sourcecheckcat==1 //0
//list pid cr5id sname sourcename dxyr stda if sourcecheckcat==1

** sourcecheckcat 2: SourceName!=QEH/BVH; NFType=Hospital; dxyr>2013
count if sourcecheckcat==2 //0
//list pid cr5id nftype sourcename dxyr stda if sourcecheckcat==2

** sourcecheckcat 3: SourceName=IPS-ARS; NFType!=Pathology; dxyr>2013
count if sourcecheckcat==3 //0
//list pid cr5id nftype sourcename dxyr stda if sourcecheckcat==3

** sourcecheckcat 4: SourceName=DeathRegistry; NFType!=Death Certif/PM; dxyr>2013
count if sourcecheckcat==4 //0
//list pid cr5id nftype sourcename dxyr stda if sourcecheckcat==4

** sourcecheckcat 5: SourceName!=QEH; NFType=QEH Death Rec/RT bk; dxyr>2013
count if sourcecheckcat==5 //0
//list pid cr5id nftype sourcename dxyr stda if sourcecheckcat==5

** sourcecheckcat 6: SourceName!=BVH; NFType=BVH bk; dxyr>2013
count if sourcecheckcat==6 //0
//list pid cr5id nftype sourcename dxyr stda if sourcecheckcat==6

** sourcecheckcat 7: SourceName!=Polyclinic; NFType=Poly/Dist.Hosp; dxyr>2013
count if sourcecheckcat==7 //0
//list pid cr5id nftype sourcename dxyr stda if sourcecheckcat==7

** sourcecheckcat 8: SourceName=Other(possibly invalid)
count if sourcecheckcat==8 //0
//list pid cr5id nftype sourcename dxyr stda if sourcecheckcat==8


************
** Doctor **
************
** NOTE 1: Patient notes only to be seen at 5 year intervals so e.g. notes seen on 2013 data then 2018 and so on;
** NOTE 2: In upcoming years of data collection (2018 dc year), more checks may be compiled based on data.

** Check 130 - Doctor missing
count if doctor=="" //0
//list pid consultant doctor dxyr cr5id if doctor==""
							
** Check 132 - invalid(doctor)

** doccheckcat 1: Doctor invalid ND code
count if doccheckcat==1 //0
//list pid cr5id doctor dxyr stda if doccheckcat==1
//replace doctor="99" if doccheckcat==1 //1 change

**********************
** Doctor's Address **
**********************
** NOTE 1: Patient notes only to be seen at 5 year intervals so e.g. notes seen on 2013 data then 2018 and so on;
** NOTE 2: In upcoming years of data collection (2018 dc year), more checks may be compiled based on data.

** Check 133 - Doctor's Address missing
count if docaddr=="" //0
//list pid consultant doctor docaddr dxyr cr5id if docaddr==""
				
** Check 135 - invalid(docaddr)

** docaddrcheckcat 1: Doc Address invalid ND code
count if docaddrcheckcat==1 //0
//list pid cr5id doctor docaddr dxyr stda if docaddrcheckcat==1
//replace docaddr="99" if docaddrcheckcat==1 //1 change


******************
** CF Diagnosis **
******************
** NOTE 1: Patient notes only to be seen at 5 year intervals so e.g. notes seen on 2013 data then 2018 and so on;
** NOTE 2: In upcoming years of data collection (2018 dc year), more checks may be compiled based on data.

** Check 138 - CF Dx missing / CF Dx missing if nftype!=death~/cyto
** 20130361 JC 24MAY18 T2S1: Changed in main CR5 added 'BREAST, RIGHT, CORE BIOPSY : INVASIVE DUCTAL CARCINOMA'.
** Discussed with SAF & KWG on 22may2018 and determined that CFDx to change from blank to 99 if CFDiagnosis=''(total of 314 records changed);
** IMPORTANT: WHEN IMPORTING BATCH CORRECTIONS - UNTICK 'Do Checks' IN MAIN CR5! WHEN CHECKS ARE RUN THE RECORD STATUS CHANGES.
** saving excel workbook as .txt and then importing into main CR5
count if cfdx=="" //0
//list pid cfdx doctor dxyr cr5id if cfdx==""
count if cfdx=="" & (nftype!=8 & nftype!=9) //0
//list pid cfdx doctor dxyr cr5id if cfdx=="" & (nftype!=8 & nftype!=9)
count if cfdx=="" & (nftype!=4 & nftype!=8 & nftype!=9) //0
//list pid nftype cfdx doctor dxyr cr5id if cfdx=="" & (nftype!=4 & nftype!=8 & nftype!=9)

** Check 139 - CF Dx invalid ND code
** (Checked data in main CR5 to determine invalid ND values by filtering in CR5 Browse/Edit by Source table, sorted by field, looking at all variables and scrolling through entire field column.)
count if cfdx=="Not Stated"|cfdx=="9" //0
//list pid cfdx dxyr cr5id if cfdx=="Not Stated"|cfdx=="9"
//replace cfdx="99" if pid=="20160018" & cr5id=="T1S1" //1 change

** No more checks as difficult to perform standardized checks on this field as sometimes it has topographic info and sometimes has morphologic info so
** no consistency to perform a set of checks
** See visual lists in 'Specimen' category below

****************
** Lab Number **
****************

** Check 140 - Lab # missing / Lab # missing if nftype=Lab~
count if labnum=="" //0
//list pid nftype labnum dxyr cr5id if labnum==""
count if labnum=="" & (nftype>2 & nftype<6) //0
//list pid nftype labnum dxyr cr5id if labnum=="" & (nftype>2 & nftype<6)
//replace labnum="99" if labnum=="" & (nftype>2 & nftype<6) //3 changes

** Check 141 - Lab # invalid ND code
** (Checked data in main CR5 to determine invalid ND values by filtering in CR5 Browse/Edit by Source table, sorted by field, looking at all variables and scrolling through entire field column.)
count if labnum=="Not Stated"|labnum=="9" //0
//list pid labnum dxyr cr5id if labnum=="Not Stated"|labnum=="9"

** No more checks as difficult to perform standardized checks on this field as sometimes it has topographic info and sometimes has morphologic info so
** no consistency to perform a set of checks
** See visual lists in 'Specimen' category below

**************
** Specimen **
**************

** Check 142 - Specimen missing / Specimen missing if nftype=Lab~
count if specimen=="" //8 - all correct
//list pid nftype specimen dxyr cr5id if specimen==""
count if specimen=="" & (nftype>2 & nftype<6) //0
//list pid nftype specimen dxyr cr5id if specimen=="" & (nftype>2 & nftype<6)
//replace specimen="99" if specimen=="" & (nftype>2 & nftype<6) //8 changes

** Check 143 - Specimen invalid ND code
** (Checked data in main CR5 to determine invalid ND values by filtering in CR5 Browse/Edit by Source table, sorted by field, looking at all variables and scrolling through entire field column.)
count if specimen=="Not Stated"|specimen=="9" //0
//list pid specimen dxyr cr5id if specimen=="Not Stated"|specimen=="9"


*******************************************
** Sample Taken, Received & Report Dates **
*******************************************
** Check 144 - Sample Date invalid(future date)
count if sampledate!=. & sampledate>currentdatest //0
//list pid cr5id sampledate dxyr stda if sampledate!=. & sampledate>currentdatest

** Check 145 - Received Date invalid (future date)
count if recvdate!=. & recvdate>currentdatest //0
//list pid cr5id recvdate dxyr stda if recvdate!=. & recvdate>currentdatest

** Check 146 - Report Date invalid (future date)
count if rptdate!=. & rptdate>currentdatest //0
//list pid cr5id rptdate dxyr stda if rptdate!=. & rptdate>currentdatest

				
** Check 148 - invalid(sampledate,recvdate,rptdate)

** rptcheckcat 1: Sample Date missing
count if rptcheckcat==1 //0
//list pid cr5id nftype sampledate recvdate rptdate dxyr stda if rptcheckcat==1

** rptcheckcat 2: Received Date missing
count if rptcheckcat==2 //0
//list pid cr5id nftype sampledate recvdate rptdate dxyr stda if rptcheckcat==2

** rptcheckcat 3: Report Date missing
count if rptcheckcat==3 //1
//list pid cr5id nftype sampledate recvdate rptdate dxyr stda if rptcheckcat==3
//replace rptdate=d(01jan2000) if rptcheckcat==3 //19 changes

** rptcheckcat 4: sampledate after recvdate
count if rptcheckcat==4 //0
//list pid cr5id sampledate recvdate rptdate dxyr stda if rptcheckcat==4
//replace sampledate=d(01jan2000) if rptcheckcat==4 //1 change

** rptcheckcat 5: sampledate after rptdate
count if rptcheckcat==5 //0
//list pid cr5id sampledate recvdate rptdate dxyr stda if rptcheckcat==5
//list pid cr5id sampledate if rptcheckcat==5
//replace sampledate=d(01jan2000) if rptcheckcat==5 //5 changes

** rptcheckcat 6: recvdate after rptdate
count if rptcheckcat==6 //0
//list pid cr5id sampledate recvdate rptdate dxyr stda if rptcheckcat==6

** rptcheckcat 7: sampledate before InciD
count if rptcheckcat==7 //0
//list pid cr5id dot sampledate recvdate rptdate dxyr stda if rptcheckcat==7

** rptcheckcat 8: recvdate before InciD
count if rptcheckcat==8 //0
//list pid cr5id dot sampledate recvdate rptdate dxyr stda if rptcheckcat==8

** rptcheckcat 9: rptdate before InciD
count if rptcheckcat==9 //0
//list pid cr5id dot sampledate recvdate rptdate dxyr stda if rptcheckcat==9

** rptcheckcat 10: sampledate after DLC
count if rptcheckcat==10 //0
//list pid cr5id dlc sampledate recvdate rptdate dxyr stda if rptcheckcat==10

** rptcheckcat 11: sampledate!=. & nftype!=lab~ & labnum=. (to filter out autopsies with hx)
count if rptcheckcat==11 //0
//list pid cr5id nftype sampledate dxyr stda if rptcheckcat==11

** rptcheckcat 12: recvdate!=. & nftype!=lab~ & labnum=. (to filter out autopsies with hx)
count if rptcheckcat==12 //0
//list pid cr5id nftype recvdate dxyr stda if rptcheckcat==12

** rptcheckcat 13: rptdate!=. & nftype!=lab~ & labnum=. (to filter out autopsies with hx)
count if rptcheckcat==13 //0
//list pid cr5id nftype rptdate dxyr stda if rptcheckcat==13


**********************
** Clinical Details **
**********************
** Check 149 - Clinical Details missing / Clinical Details missing if nftype=Lab~
count if clindets=="" //8
//list pid nftype clindets dxyr cr5id if clindets==""
count if clindets=="" & (nftype>2 & nftype<6) //0
//list pid nftype clindets dxyr cr5id if clindets=="" & (nftype>2 & nftype<6)
//replace clindets="99" if clindets=="" & (nftype>2 & nftype<6) //16 changes

** Check 150 - Clinical Details invalid ND code
** (Checked data in main CR5 to determine invalid ND values by filtering in CR5 Browse/Edit by Source table, sorted by field, looking at all variables and scrolling through entire field column.)
count if clindets=="Not Stated"|clindets=="NIL"|regexm(clindets, "NONE")|clindets=="9" //0
//list pid clindets dxyr cr5id if clindets=="Not Stated"|clindets=="NIL"|regexm(clindets, "NONE")|clindets=="9"
//replace clindets="99" if clindets=="Not Stated"|clindets=="NIL"|regexm(clindets, "NONE")|clindets=="9" //5 changes


**************************
** Cytological Findings **
**************************
** Check 151 - Cytological Findings missing / Cytological Findings missing if nftype=Lab-Cyto
count if cytofinds=="" //0
count if cytofinds=="" & (nftype>2 & nftype<6) //0
count if cytofinds=="" & nftype==4 //0
//list pid nftype cytofinds dxyr cr5id if cytofinds=="" & nftype==4
//replace cytofinds="99" if cytofinds=="" & nftype==4 //4 changes

** Check 152 - Cytological Findings invalid ND code
** (Checked data in main CR5 to determine invalid ND values by filtering in CR5 Browse/Edit by Source table, sorted by field, looking at all variables and scrolling through entire field column.)
count if cytofinds=="Not Stated"|cytofinds=="9" //0
//list pid cytofinds dxyr cr5id if cytofinds=="Not Stated"|cytofinds=="9"


*****************************
** Microscopic Description **
*****************************
** Check 153 - MD missing / MD missing if nftype=Lab~
count if md=="" //8
count if md=="" & (nftype>2 & nftype<6) //0
count if md=="" & (nftype==3|nftype==5) //0
//list pid nftype md dxyr cr5id if md=="" & (nftype==3|nftype==5)
//replace md="99" if  md=="" & (nftype==3|nftype==5) //11 changes

** Check 154 - MD invalid ND code
** (Checked data in main CR5 to determine invalid ND values by filtering in CR5 Browse/Edit by Source table, sorted by field, looking at all variables and scrolling through entire field column.)
count if md=="Not Stated."|md=="Not Stated"|md=="9" //0
//list pid md dxyr cr5id if md=="Not Stated."|md=="Not Stated"|md=="9"


*************************
** Consultation Report **
*************************
** NOTE 1: Met with SAF and KWG on 22may18 and decision made to remove checks for this variable; also removed checkflags from excel export code below.

** Check 155 - Consult.Rpt missing / Consult.Rpt missing if nftype=Lab~
count if consrpt=="" & (nftype==3|nftype==5) //9
//list pid nftype consrpt dxyr cr5id if consrpt=="" & (nftype==3|nftype==5)
replace consrpt="99" if consrpt=="" & (nftype==3|nftype==5) //9 changes

** Check 156 - Consult.Rpt invalid ND code
** (Checked data in main CR5 to determine invalid ND values by filtering in CR5 Browse/Edit by Source table, sorted by field, looking at all variables and scrolling through entire field column.)
count if consrpt=="Not Stated"|consrpt=="Not Stated."|consrpt=="9" //0
//list pid consrpt dxyr cr5id if consrpt=="Not Stated"|consrpt=="Not Stated."|consrpt=="9"
//replace consrpt="99" if consrpt=="Not Stated"|consrpt=="Not Stated."|consrpt=="9" //2 changes


***********************
** Cause(s) of Death **
***********************

** Check 157a - Check below list if pid occurs more than once then check main CR5 db to see if sources have same/different CODs
/* 
JC 25oct18: I created below Check 157a as I incidentally found pid 20140047 has 2 source records with differing CODs (see T1S3 vs T1S4) 
possibly due to incorrect merging?
To quickly identify duplicates: 
(1) copy results list into excel sheet then 
(2) higlight column with pid in it and convert text to columns in data tab of excel using fixed width
(3) highlight pid column then using conditional formatting identify duplicates by clicking-->Highlight Cell Rules-->Duplicate Values
(4) all duplicate pids will be highlighted in red
(5) repeat above steps in different excel sheet for cr5cod list then copy next to pid column
(6) filter pid column by colour
(7) check each duplicate pid's COD and indicate if CODs match or do not match
(8) for those that do not  match then double check in main CR5 db and then email cancer team
*/
count if (cr5cod!="" & cr5cod!="99") //& dxyr==2015 //4
//list pid cr5id cr5cod if (cr5cod!="" & cr5cod!="99") & dxyr==2015
//list cr5cod if (cr5cod!="" & cr5cod!="99") & dxyr==2015

** Check 157b - COD missing / COD missing if nftype=Death~
count if cr5cod=="" //17
//list pid nftype cr5cod dxyr cr5id if cr5cod==""
count if cr5cod=="" & (nftype==8|nftype==9) //0
//list pid nftype cr5cod dxyr cr5id if cr5cod=="" & (nftype==8|nftype==9)

** Check 158 - COD invalid ND code
** (Checked data in main CR5 to determine invalid ND values by filtering in CR5 Browse/Edit by Source table, sorted by field, looking at all variables and scrolling through entire field column.)
count if regexm(cr5cod, "Not")|regexm(cr5cod, "not")|cr5cod=="NIL."|cr5cod=="Not Stated"|cr5cod=="9" //0
//list pid cr5cod dxyr cr5id if regexm(cr5cod, "Not")|regexm(cr5cod, "not")|cr5cod=="NIL."|cr5cod=="Not Stated"|cr5cod=="9"

** Check 159 - COD invalid entry(lowercase)
count if cr5cod!="99" & cr5cod!="" & regexm(cr5cod, "[a-z]") //3
//list pid cr5cod dxyr cr5id if cr5cod!="99" & cr5cod!="" & regexm(cr5cod, "[a-z]")
replace cr5cod=upper(cr5cod) if cr5cod!="99" & cr5cod!="" & regexm(cr5cod, "[a-z]") //3 changes


*************************
** Duration of Illness **
*************************
** Check 160 - Duration of Illness missing / Duration of Illness missing if nftype=Death~
count if duration=="" & nftype==8 //0
//list pid nftype duration onsetint dxyr cr5id if duration=="" & nftype==8
//replace duration="99" if duration=="" & nftype==8 //239 changes

** Check 161 - Duration of Illness invalid ND code
** (Checked data in main CR5 to determine invalid ND values by filtering in CR5 Browse/Edit by Source table, sorted by field, looking at all variables and scrolling through entire field column.)
count if regexm(duration, "UNKNOWN")|regexm(duration, "Not")|regexm(duration, "not")|duration=="NIL."|duration=="Not Stated"|duration=="9" //0
//list pid duration dxyr cr5id if regexm(duration, "UNKNOWN")|regexm(duration, "Not")|regexm(duration, "not")|duration=="NIL."|duration=="Not Stated"|duration=="9"

** Check 162 - Duration of Illness invalid entry(lowercase)
count if duration!="99" & duration!="" & regexm(duration, "[a-z]") //0
//list pid duration dxyr cr5id if duration!="99" & duration!="" & regexm(duration, "[a-z]")
//replace duration=upper(duration) if duration!="99" & duration!="" & regexm(duration, "[a-z]") //3 changes


*****************************
** Onset to Death Interval **
*****************************
** Check 163 - Onset to Death Interval missing / Onset to Death Interval missing if nftype=Death~
count if onsetint=="" & nftype==8 //0
//list pid nftype onsetint dxyr cr5id if onsetint=="" & nftype==8
//replace onsetint="99" if onsetint=="" & nftype==8 //239 changes

** Check 164 - Onset to Death Interval invalid ND code
** (Checked data in main CR5 to determine invalid ND values by filtering in CR5 Browse/Edit by Source table, sorted by field, looking at all variables and scrolling through entire field column.)
count if regexm(onsetint, "UNKNOWN")|regexm(onsetint, "Not")|regexm(onsetint, "not")|onsetint=="NIL."|onsetint=="Not Stated"|onsetint=="9" //0
//list pid onsetint dxyr cr5id if regexm(onsetint, "UNKNOWN")|regexm(onsetint, "Not")|regexm(onsetint, "not")|onsetint=="NIL."|onsetint=="Not Stated"|onsetint=="9"

** Check 165 - Onset to Death Interval invalid entry(lowercase)
count if onsetint!="99" & onsetint!="" & regexm(onsetint, "[a-z]") //0
//list pid onsetint dxyr cr5id if onsetint!="99" & onsetint!="" & regexm(onsetint, "[a-z]")
//replace onsetint=upper(onsetint) if onsetint!="99" & onsetint!="" & regexm(onsetint, "[a-z]") //1 change

***************
** Certifier **
***************
** NOTE 1: Met with SAF and KWG on 22may18 and decision made to remove checks for this variable from review/corrections code; also removed checkflags from excel export code below.

** Check 166 - Certifier missing / Certifier missing if nftype=Death~
count if certifier=="" & (nftype==8|nftype==9) //0
//list pid nftype certifier dxyr cr5id if certifier=="" & (nftype==8|nftype==9)
//replace certifier="99" if certifier=="" & (nftype==8|nftype==9) //233 changes

** Check 167 - Certifier invalid ND code
** (Checked data in main CR5 to determine invalid ND values by filtering in CR5 Browse/Edit by Source table, sorted by field, looking at all variables and scrolling through entire field column.)
count if regexm(certifier, "UNKNOWN")|regexm(certifier, "Not")|regexm(certifier, "not")|certifier=="NIL."|certifier=="Not Stated"|certifier=="9" //0
//list pid certifier dxyr cr5id if regexm(certifier, "UNKNOWN")|regexm(certifier, "Not")|regexm(certifier, "not")|certifier=="NIL."|certifier=="Not Stated"|certifier=="9"

** Check 168 - Certifier invalid entry(lowercase)
count if certifier!="99" & certifier!="" & regexm(certifier, "[a-z]") //0
//list pid certifier dxyr cr5id if certifier!="99" & certifier!="" & regexm(certifier, "[a-z]")
//replace certifier=upper(certifier) if certifier!="99" & certifier!="" & regexm(certifier, "[a-z]") //1 change

***********************************
** Admission, DFC & RT Reg Dates **
***********************************
** Check 169 - Admission Date invalid(future date)
count if admdate!=. & admdate>currentdatest //0
//list pid cr5id admdate dxyr stda if admdate!=. & admdate>currentdatest

** Check 170 - DFC Date invalid (future date)
count if dfc!=. & dfc>currentdatest //0
//list pid cr5id dfc dxyr stda if dfc!=. & dfc>currentdatest

** Check 171 - RT Date invalid (future date)
count if rtdate!=. & rtdate>currentdatest //0
//list pid cr5id rtdate dxyr stda if rtdate!=. & rtdate>currentdatest


** Check 173 - invalid(admdate,dfc,rtdate)

** datescheckcat 1: Admission Date missing
count if datescheckcat==1 //15
//list pid cr5id sourcename nftype admdate dfc rtdate dxyr stda if datescheckcat==1

** datescheckcat 2: DFC missing
count if datescheckcat==2 //1
//list pid cr5id sourcename nftype admdate dfc rtdate dxyr stda if datescheckcat==2

** datescheckcat 3: RT Date missing
count if datescheckcat==3 //0
//list pid cr5id sourcename nftype admdate dfc rtdate dxyr stda if datescheckcat==3

** datescheckcat 4: admdate/dfc/rtdate BEFORE InciD
count if datescheckcat==4 //0
//list pid cr5id dot admdate dfc rtdate dxyr stda if datescheckcat==4

** datescheckcat 5: admdate/dfc/rtdate after DLC
count if datescheckcat==5 //0
//list pid cr5id dlc admdate dfc rtdate dxyr stda if datescheckcat==5

** datescheckcat 6: admdate!=. & sourcename!=hosp
count if datescheckcat==6 //0
//list pid cr5id sourcename nftype admdate dfc rtdate dxyr stda if datescheckcat==6

** datescheckcat 7: dfc!=. & sourcename!=PrivPhys/IPS
count if datescheckcat==7 //0
//list pid cr5id sourcename nftype admdate dfc rtdate dxyr stda if datescheckcat==7

** datescheckcat 8: rtdate!=. & nftype!=RT
count if datescheckcat==8 //0
//list pid cr5id sourcename nftype admdate dfc rtdate dxyr stda if datescheckcat==8


sort pid
quietly by pid :  gen duppid = cond(_N==1,0,_n)
count if duppid==0 //24
count if duppid>0
drop duppid

tab sex ,m
labelbook sex_lab
label drop sex_lab

rename sex sex_old
gen sex=1 if sex_old==2
replace sex=2 if sex_old==1
drop sex_old
label define sex_lab 1 "Female" 2 "Male" 99 "ND", modify
label values sex sex_lab
label var sex "Sex"

tab sex ,m

** Convert names to lower case and strip possible leading/trailing blanks
replace fname = lower(rtrim(ltrim(itrim(fname))))
replace lname = lower(rtrim(ltrim(itrim(lname))))


//natregno ==9 dead
//list dd6yrs_record_id if dd6yrs_natregno=="0505110080"|dd6yrs_natregno=="1502030081"|dd6yrs_natregno=="0103050092"|dd6yrs_natregno=="0008190100"|dd6yrs_natregno=="9808120068"|dd6yrs_natregno=="0411250079"|dd6yrs_natregno=="1609130115"|dd6yrs_natregno=="9904160018"|dd6yrs_natregno=="0903290161"

*****************************
**   Final Clean and Prep  **
*****************************
preserve
clear
use "`datapath'\version02\3-output\2015-2020_deaths_for_matching" ,clear
drop if dd6yrs_record_id!=24293 & dd6yrs_record_id!=26175 & dd6yrs_record_id!=23702 & dd6yrs_record_id!=25129 ///
		& dd6yrs_record_id!=22552 & dd6yrs_record_id!=21416 & dd6yrs_record_id!=20629 & dd6yrs_record_id!=19933 & dd6yrs_record_id!=30043

rename dd6yrs* dd*
format dd_dddoa %tcCCYY-NN-DD_HH:MM:SS
format dd_nrn %15.0g
format dd_dod %dD_m_CY
format dd_regdate %dD_m_CY
drop dob
gen natregno=dd_natregno
save "`datapath'\version02\2-working\criccs_deaths_for_matching" ,replace
restore

merge 1:1 natregno using "`datapath'\version02\2-working\criccs_deaths_for_matching"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                            15
        from master                        15  (_merge==1)
        from using                          0  (_merge==2)

    Matched                                 9  (_merge==3)
    -----------------------------------------
*/

replace natregno = lower(rtrim(ltrim(itrim(natregno))))
replace dd_natregno = lower(rtrim(ltrim(itrim(dd_natregno))))

** Create dod variable
gen dod=dd_dod
format dod %dD_m_CY
label var dod "Date of Death"

** Create dodyear variable
gen int dodyear=year(dod)
label var dodyear "Year of Death"
count if dod!=dlc & dod!=. //0
count if dd_natregno!=natregno & dod!=. //0


** Create variable called "deceased" - same as AR's 2008 dofile called '3_merge_cancer_deaths.do'
tab slc ,m
count if slc!=2 & dod!=. //0
gen deceased=1 if slc==2 //627 changes
label var deceased "whether patient is deceased"
label define deceased_lab 1 "dead" 2 "alive at last contact" , modify
label values deceased deceased_lab
replace deceased=2 if slc==1 //493 changes

tab slc deceased ,m

** Create MP variable
gen eidmp=1 if persearch==1
replace eidmp=2 if persearch==2
label var eidmp "CR5 tumour events"
label define eidmp_lab 1 "single tumour" 2 "multiple tumour" ,modify
label values eidmp eidmp_lab
tab eidmp ,m

** Create the "patient" variable - same as AR's 2008 dofile called '3_merge_cancer_deaths.do'
gen patient=.  
label var patient "cancer patient"
label define pt_lab 1 "patient" 2 "separate event",modify
label values patient pt_lab
replace patient=1 if eidmp==1 //12 changes
replace patient=2 if eidmp==2 //1 change
tab patient ,m

** Convert names to lower case and strip possible leading/trailing blanks
replace fname = lower(rtrim(ltrim(itrim(fname)))) //0 changes
replace init = lower(rtrim(ltrim(itrim(init)))) //24 changes
replace lname = lower(rtrim(ltrim(itrim(lname)))) //0 changes
	  
** Ensure death date is correct IF PATIENT IS DEAD
count if dlc!=dod & slc==2 //0
//replace dlc=dod if dlc!=dod & slc==2 //48 changes

count if dodyear==. & dod!=. //0
//replace dodyear=year(dod) if dodyear==. & dod!=. //70 changes
count if dod==. & slc==2 //0
//list pid cr5id fname lname nftype dlc if dod==. & slc==2

count if slc==2 & recstatus==3 //0


** Now generate a new variable which will select out all the potential cancers
gen cancer=. if slc==2
label define cancer_lab 1 "cancer" 2 "not cancer", modify
label values cancer cancer_lab
label var cancer "cancer diagnoses"
rename dd_record_id deathid
label var deathid "Event identifier for registry deaths"

** searching cod1a for these terms
replace dd_cod1a="99" if dd_cod1a=="999" //0 changes
replace dd_cod1b="99" if dd_cod1b=="999" //28 changes
replace dd_cod1c="99" if dd_cod1c=="999" //45 changes
replace dd_cod1d="99" if dd_cod1d=="999" //56 changes
replace dd_cod2a="99" if dd_cod2a=="999" //45 changes
replace dd_cod2b="99" if dd_cod2b=="999" //54 changes
count if dd_cod1c!="99" //567
count if dd_cod1d!="99" //132
count if dd_cod2a!="99" //1005
count if dd_cod2b!="99" //462
//ssc install unique
//ssc install distinct
** Create variable with combined CODs
//gen dd_coddeath=dd_cod1a+" "+dd_cod1b+" "+dd_cod1c+" "+dd_cod1d+" "+dd_cod2a+" "+dd_cod2b
//replace dd_coddeath=subinstr(dd_coddeath,"99 ","",.) //4990
//replace dd_coddeath=subinstr(dd_coddeath," 99","",.) //4591
** Identify cancer deaths using variable called 'cancer'
replace cancer=1 if regexm(dd_coddeath, "CANCER") & cancer==. //719 changes
replace cancer=1 if regexm(dd_coddeath, "TUMOUR") &  cancer==. //25 changes
replace cancer=1 if regexm(dd_coddeath, "TUMOR") &  cancer==. //21 changes
replace cancer=1 if regexm(dd_coddeath, "MALIGNANT") &  cancer==. //16 changes
replace cancer=1 if regexm(dd_coddeath, "MALIGNANCY") &  cancer==. //65 changes
replace cancer=1 if regexm(dd_coddeath, "NEOPLASM") &  cancer==. //3 changes
replace cancer=1 if regexm(dd_coddeath, "CARCINOMA") &  cancer==. //333 changes
replace cancer=1 if regexm(dd_coddeath, "CARCIMONA") &  cancer==. //0 changes
replace cancer=1 if regexm(dd_coddeath, "CARINOMA") &  cancer==. //0 changes
replace cancer=1 if regexm(dd_coddeath, "MYELOMA") &  cancer==. //43 changes
replace cancer=1 if regexm(dd_coddeath, "LYMPHOMA") &  cancer==. //24 changes
replace cancer=1 if regexm(dd_coddeath, "LYMPHOMIA") &  cancer==. //0 changes
replace cancer=1 if regexm(dd_coddeath, "LYMPHONA") &  cancer==. //0 changes
replace cancer=1 if regexm(dd_coddeath, "SARCOMA") &  cancer==. //20 changes
replace cancer=1 if regexm(dd_coddeath, "TERATOMA") &  cancer==. //0 changes
replace cancer=1 if regexm(dd_coddeath, "LEUKEMIA") &  cancer==. //24 changes
replace cancer=1 if regexm(dd_coddeath, "LEUKAEMIA") &  cancer==. //5 changes
replace cancer=1 if regexm(dd_coddeath, "HEPATOMA") &  cancer==. //0 changes
replace cancer=1 if regexm(dd_coddeath, "CARANOMA PROSTATE") &  cancer==. //0 changes
replace cancer=1 if regexm(dd_coddeath, "MENINGIOMA") &  cancer==. //3 changes
replace cancer=1 if regexm(dd_coddeath, "MYELOSIS") &  cancer==. //0 changes
replace cancer=1 if regexm(dd_coddeath, "MYELOFIBROSIS") &  cancer==. //1 change
replace cancer=1 if regexm(dd_coddeath, "CYTHEMIA") &  cancer==. //0 changes
replace cancer=1 if regexm(dd_coddeath, "CYTOSIS") &  cancer==. //1 change
replace cancer=1 if regexm(dd_coddeath, "BLASTOMA") &  cancer==. //5 changes
replace cancer=1 if regexm(dd_coddeath, "METASTATIC") &  cancer==. //10 changes
replace cancer=1 if regexm(dd_coddeath, "MASS") &  cancer==. //40 changes
replace cancer=1 if regexm(dd_coddeath, "METASTASES") &  cancer==. //2 changes
replace cancer=1 if regexm(dd_coddeath, "METASTASIS") &  cancer==. //0 changes
replace cancer=1 if regexm(dd_coddeath, "REFRACTORY") &  cancer==. //0 changes
replace cancer=1 if regexm(dd_coddeath, "FUNGOIDES") &  cancer==. //2 change
replace cancer=1 if regexm(dd_coddeath, "HODGKIN") &  cancer==. //0 changes
replace cancer=1 if regexm(dd_coddeath, "MELANOMA") &  cancer==. //1 change
replace cancer=1 if regexm(dd_coddeath,"MYELODYS") &  cancer==. //3 changes
//replace cancer=1 if regexm(coddeath,"GLIOMA") &  cancer==. //add in for next dc year

** Strip possible leading/trailing blanks in cod1a
replace dd_coddeath = rtrim(ltrim(itrim(dd_coddeath))) //0 changes

tab cancer, missing

** Check for cases where cancer=2-not cancer but it has been abstracted
list pid dd_coddeath cancer, string(80)
replace cancer=2 if cancer==.

** Create cod variable 
gen cod=.
label define cod_lab 1 "Dead of cancer" 2 "Dead of other cause" 3 "Not known" 4 "NA", modify
label values cod cod_lab
label var cod "COD categories"
replace cod=1 if cancer==1 //9 changes
replace cod=2 if cancer==2 //15 changes
** one unknown causes of death in 2014 data - record_id 12323
replace cod=3 if dd_coddeath=="99"|(regexm(dd_coddeath,"INDETERMINATE")|regexm(dd_coddeath,"UNDETERMINED")) //0 changes



** Only report non-duplicate MPs (see IARC MP rules on recording and reporting)
display `"{browse "http://www.iacr.com.fr/images/doc/MPrules_july2004.pdf":IARC-MP}"'
tab persearch ,m
//list pid cr5id if persearch==3 //3

** Updates from multiple primary report (define which is the MP so can remove in survival dataset):
//no updates needed as none to exclude

** Updates from MP exclusion report (excludes in-situ/unreportable cancers)
label drop persearch_lab
label define persearch_lab 0 "Not done" 1 "Done: OK" 2 "Done: MP" 3 "Done: Duplicate" 4 "Done: Non-IARC MP" 5 "Done: IARCcrgTools Excluded", modify
label values persearch persearch_lab
tab beh ,m
replace persearch=5 if beh<3 //0 changes

tab persearch ,m
//list pid cr5id if persearch==2

** Check DCOs
tab basis ,m

** Create variable to identify DCI/DCN vs DCO
gen dcostatus=.
label define dcostatus_lab ///
1 "Eligible DCI/DCN-cancer,in CR5db" ///
2 "DCO" ///
3 "Ineligible DCI/DCN" ///
4 "NA-not cancer,not in CR5db" ///
5 "NA-dead,CR5db no death source" ///
6 "NA-alive" ///
7 "NA-not alive/dead" , modify
label values dcostatus dcostatus_lab
label var dcostatus "death certificate status"

** Create dupsource variable
gen dupsource=0 //
label var dupsource "Multiple Sources"
label define dupsource_lab  1 "MS-Conf Tumour Rec" 2 "MS-Conf Source Rec" ///
							3 "MS-Dup Tumour Rec" 4 "MS-Dup Tumour & Source Rec" ///
							5 "MS-Ineligible Tumour 1 Rec" 6 "MS-Ineligible Tumour 2~ & Source Rec" , modify
label values dupsource dupsource_lab

replace dupsource=1 if recstatus==1 & regexm(cr5id,"S1") //24 confirmed - this is the # eligible non-duplicate tumours
replace dupsource=2 if recstatus==1 & !strmatch(strupper(cr5id), "*S1") //0 - confirmed
replace dupsource=3 if recstatus==4 & regexm(cr5id,"S1") //0 - duplicate
replace dupsource=4 if recstatus==4 & !strmatch(strupper(cr5id), "*S1") //0 - duplicate
replace dupsource=5 if recstatus==3 & cr5id=="T1S1" //0 - ineligible
replace dupsource=6 if recstatus==3 & cr5id!="T1S1" //0 - duplicate

** Create variable to identify patient records
gen ptrectot=.
replace ptrectot=1 if eidmp==1 //971; 1119 changes
replace ptrectot=3 if eidmp==2 //13; 15 changes
label define ptrectot_lab 1 "CR5 pt with single event" 2 "DC with single event" 3 "CR5 pt with multiple events" ///
						  4 "DC with multiple events" 5 "CR5 pt: single event but multiple DC events" , modify
label values ptrectot ptrectot_lab
tab ptrectot ,m //0 missing

order pid deathid cr5id eidmp dupsource ptrectot dcostatus primarysite

** Assign DCO Status=NA for all events that are not cancer 
replace dcostatus=1 if slc==2 & basis!=0 //8
replace dcostatus=2 if basis==0 //1
replace dcostatus=7 if slc!=2 //15 changes

** Re-assign dcostatus for cases with updated death trace-back: still pending as of 19feb2020 TBD by NS
tab dcostatus ,m
count if dcostatus==2 & basis!=0
//list pid basis if dcostatus==2 & basis!=0 - autopsy w/ hx


** Remove non-residents (see IARC validity presentation)
tab resident ,m //0 missing
label drop resident_lab
label define resident_lab 1 "Yes" 2 "No" 99 "Unknown", modify
label values resident resident_lab
replace resident=99 if resident==9 //45 changes
//list pid natregno nrn addr dd_address if resident==99
replace resident=1 if resident==99 & addr!="99" & addr!="" //29 changes
replace resident=1 if resident==99 & dd_address!="99" & dd_address!="" //0
//replace natregno=nrn if natregno=="" & nrn!="" & resident==99 //3 changes
replace resident=1 if natregno!="" & !(strmatch(strupper(natregno), "*9999*")) //1 change
** Check electoral list and CR5db for those resident=99
//list pid fname lname nrn natregno dob if resident==99
//list pid fname lname addr if resident==99
tab resident ,m //0 unknown

** Check parish
count if parish!=. & parish!=99 & addr=="" //0
count if parish==. & addr!="" & addr!="99" //0
//list pid fname lname natregno parish addr if parish!=. & parish!=99 & addr==""
//bysort pid (cr5id) : replace addr = addr[_n-1] if missing(addr) //1 change - 20140566/

** Check missing sex
tab sex ,m //none missing

** Check for missing age & 100+
tab age ,m //0 missing - none are 100+: f/u was done but age not found
//list pid natregno dd_natregno if age==999

** Check for missing follow-up
label drop slc_lab
label define slc_lab 1 "Alive" 2 "Deceased" 3 "Emigrated" 99 "Unknown", modify
label values slc slc_lab
replace slc=99 if slc==9 //0 changes
tab slc ,m 
** Check missing in CR5db
//list pid if slc==99
count if dlc==. //0
//tab dlc ,m

** Check for non-malignant
tab beh ,m //all malignant
tab morph if beh!=3 //0

** Check for ineligibles
tab recstatus ,m
drop if recstatus==3 //0 deleted

** Check for duplicate tumours
tab persearch ,m //0 excluded

** Check dob
count if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*9999*")) //0
//list pid natregno if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*-9999*"))

** Check age
gen age2 = (dot - dob)/365.25
gen checkage2=int(age2)
drop age2
count if dob!=. & dot!=. & age!=checkage2 //0
//list pid dot dob age checkage2 cr5id if dob!=. & dot!=. & age!=checkage2
replace age=checkage2 if dob!=. & dot!=. & age!=checkage2 //0 changes

** Check no missing dxyr so this can be used in analysis
tab dxyr ,m //0 missing
/*
DiagnosisYe |
         ar |      Freq.     Percent        Cum.
------------+-----------------------------------
       2015 |          3       12.50       12.50
       2016 |          8       33.33       45.83
       2017 |          5       20.83       66.67
       2018 |          8       33.33      100.00
------------+-----------------------------------
      Total |         24      100.00
*/

** To match with 2014 format, convert names to lower case and strip possible leading/trailing blanks
replace fname = lower(rtrim(ltrim(itrim(fname)))) //0 changes
replace init = lower(rtrim(ltrim(itrim(init)))) //0 changes
//replace mname = lower(rtrim(ltrim(itrim(mname)))) //0 changes
replace lname = lower(rtrim(ltrim(itrim(lname)))) //0 changes

count //24

** Create new site variable with CI5-XI incidence classifications (see chapter 3 Table 3.1. of that volume) based on icd10
display `"{browse "http://ci5.iarc.fr/CI5-XI/Pages/Chapter3.aspx":IARC-CI5-XI-3}"'

rename ICCCcode iccc
rename ICD10 icd10

gen siteiarc=.
label define siteiarc_lab ///
1 "Lip (C00)" 2 "Tongue (C01-02)" 3 "Mouth (C03-06)" ///
4 "Salivary gland (C07-08)" 5 "Tonsil (C09)" 6 "Other oropharynx (C10)" ///
7 "Nasopharynx (C11)" 8 "Hypopharynx (C12-13)" 9 "Pharynx unspecified (C14)" ///
10 "Oesophagus (C15)" 11 "Stomach (C16)" 12 "Small intestine (C17)" ///
13 "Colon (C18)" 14 "Rectum (C19-20)" 15 "Anus (C21)" ///
16 "Liver (C22)" 17 "Gallbladder etc. (C23-24)" 18 "Pancreas (C25)" ///
19 "Nose, sinuses etc. (C30-31)" 20 "Larynx (C32)" ///
21 "Lung (incl. trachea and bronchus) (C33-34)" 22 "Other thoracic organs (C37-38)" ///
23 "Bone (C40-41)" 24 "Melanoma of skin (C43)" 25 "Other skin (C44)" ///
26 "Mesothelioma (C45)" 27 "Kaposi sarcoma (C46)" 28 "Connective and soft tissue (C47+C49)" ///
29 "Breast (C50)" 30 "Vulva (C51)" 31 "Vagina (C52)" 32 "Cervix uteri (C53)" ///
33 "Corpus uteri (C54)" 34 "Uterus unspecified (C55)" 35 "Ovary (C56)" ///
36 "Other female genital organs (C57)" 37 "Placenta (C58)" ///
38 "Penis (C60)" 39 "Prostate (C61)" 40 "Testis (C62)" 41 "Other male genital organs (C63)" ///
42 "Kidney (C64)" 43 "Renal pelvis (C65)" 44 "Ureter (C66)" 45 "Bladder (C67)" ///
46 "Other urinary organs (C68)" 47 "Eye (C69)" 48 "Brain, nervous system (C70-72)" ///
49 "Thyroid (C73)" 50 "Adrenal gland (C74)" 51 "Other endocrine (C75)" ///
52 "Hodgkin lymphoma (C81)" 53 "Non-Hodgkin lymphoma (C82-86,C96)" ///
54 "Immunoproliferative diseases (C88)" 55 "Multiple myeloma (C90)" ///
56 "Lymphoid leukaemia (C91)" 57 "Myeloid leukaemia (C92-94)" 58 "Leukaemia unspecified (C95)" ///
59 "Myeloproliferative disorders (MPD)" 60 "Myelodysplastic syndromes (MDS)" ///
61 "Other and unspecified (O&U)" ///
62 "All sites(ALL)" 63 "All sites but skin (ALLbC44)" ///
64 "D069: CIN 3"
label var siteiarc "IARC CI5-XI sites"
label values siteiarc siteiarc_lab

replace siteiarc=1 if regexm(icd10,"C00") //0 changes
replace siteiarc=2 if (regexm(icd10,"C01")|regexm(icd10,"C02")) //7 changes
replace siteiarc=3 if (regexm(icd10,"C03")|regexm(icd10,"C04")|regexm(icd10,"C05")|regexm(icd10,"C06")) //4 changes
replace siteiarc=4 if (regexm(icd10,"C07")|regexm(icd10,"C08")) //2 changes
replace siteiarc=5 if regexm(icd10,"C09") //4 changes
replace siteiarc=6 if regexm(icd10,"C10") //2 changes
replace siteiarc=7 if regexm(icd10,"C11") //5 changes
replace siteiarc=8 if (regexm(icd10,"C12")|regexm(icd10,"C13")) //0 changes
replace siteiarc=9 if regexm(icd10,"C14") //1 change
replace siteiarc=10 if regexm(icd10,"C15") //12 changes
replace siteiarc=11 if regexm(icd10,"C16") //37 changes
replace siteiarc=12 if regexm(icd10,"C17") //8 changes
replace siteiarc=13 if regexm(icd10,"C18") //117 changes
replace siteiarc=14 if (regexm(icd10,"C19")|regexm(icd10,"C20")) //49 changes
replace siteiarc=15 if regexm(icd10,"C21") //6 changes
replace siteiarc=16 if regexm(icd10,"C22") //7 changes
replace siteiarc=17 if (regexm(icd10,"C23")|regexm(icd10,"C24")) //12 changes
replace siteiarc=18 if regexm(icd10,"C25") //27 changes
replace siteiarc=19 if (regexm(icd10,"C30")|regexm(icd10,"C31")) //2 changes
replace siteiarc=20 if regexm(icd10,"C32") //7 changes
replace siteiarc=21 if (regexm(icd10,"C33")|regexm(icd10,"C34")) //32 changes
replace siteiarc=22 if (regexm(icd10,"C37")|regexm(icd10,"C38")) //1 change
replace siteiarc=23 if (regexm(icd10,"C40")|regexm(icd10,"C41")) //2 changes
replace siteiarc=24 if regexm(icd10,"C43") //10 changes
replace siteiarc=25 if regexm(icd10,"C44") //0 changes
replace siteiarc=26 if regexm(icd10,"C45") //0 changes
replace siteiarc=27 if regexm(icd10,"C46") //0 changes
replace siteiarc=28 if (regexm(icd10,"C47")|regexm(icd10,"C49")) //5 changes
replace siteiarc=29 if regexm(icd10,"C50") //209 changes
replace siteiarc=30 if regexm(icd10,"C51") //2 changes
replace siteiarc=31 if regexm(icd10,"C52") //4 changes
replace siteiarc=32 if regexm(icd10,"C53") //19 changes
replace siteiarc=33 if regexm(icd10,"C54") //46 changes
replace siteiarc=34 if regexm(icd10,"C55") //7 changes
replace siteiarc=35 if regexm(icd10,"C56") //19 changes
replace siteiarc=36 if regexm(icd10,"C57") //2 changes
replace siteiarc=37 if regexm(icd10,"C58") //0 changes
replace siteiarc=38 if regexm(icd10,"C60") //1 change
replace siteiarc=39 if regexm(icd10,"C61") //228 changes
replace siteiarc=40 if regexm(icd10,"C62") //2 changes
replace siteiarc=41 if regexm(icd10,"C63") //0 changes
replace siteiarc=42 if regexm(icd10,"C64") //17 changes
replace siteiarc=43 if regexm(icd10,"C65") //0 changes
replace siteiarc=44 if regexm(icd10,"C66") //1 change
replace siteiarc=45 if regexm(icd10,"C67") //17 changes
replace siteiarc=46 if regexm(icd10,"C68") //1 change
replace siteiarc=47 if regexm(icd10,"C69") //2 changes
replace siteiarc=48 if (regexm(icd10,"C70")|regexm(icd10,"C71")|regexm(icd10,"C72")) //11 changes
replace siteiarc=49 if regexm(icd10,"C73") //12 changes
replace siteiarc=50 if regexm(icd10,"C74") //0 changes
replace siteiarc=51 if regexm(icd10,"C75") //0 changes
replace siteiarc=52 if regexm(icd10,"C81") //6 changes
replace siteiarc=53 if (regexm(icd10,"C82")|regexm(icd10,"C83")|regexm(icd10,"C84")|regexm(icd10,"C85")|regexm(icd10,"C86")|regexm(icd10,"C96")) //30 changes
replace siteiarc=54 if regexm(icd10,"C88") //0 changes
replace siteiarc=55 if regexm(icd10,"C90") //32 changes
replace siteiarc=56 if regexm(icd10,"C91") //5 changes
replace siteiarc=57 if (regexm(icd10,"C92")|regexm(icd10,"C93")|regexm(icd10,"C94")) //6 changes
replace siteiarc=58 if regexm(icd10,"C95") //4 changes
replace siteiarc=59 if morphcat==54|morphcat==55 //6 changes
replace siteiarc=60 if morphcat==56 //6 changes
replace siteiarc=61 if (regexm(icd10,"C26")|regexm(icd10,"C39")|regexm(icd10,"C48")|regexm(icd10,"C76")|regexm(icd10,"C80")) //40 changes
**replace siteiarc=62 if siteiarc<62
**replace siteiarc=63 if siteiarc<62 & siteiarc!=25
replace siteiarc=64 if morph==8077 //18 changes

tab siteiarc ,m //0 missing
//list pid cr5id primarysite top hx morph icd10 if siteiarc==.

gen allsites=1 if siteiarc<62 //951 changes - 18 missing values=CIN 3
label var allsites "All sites (ALL)"

gen allsitesbC44=1 if siteiarc<62 & siteiarc!=25
//0 changes - 0 missing values=CIN 3
label var allsitesbC44 "All sites but skin (ALLbC44)"

** Create site variable for lymphoid and haematopoietic diseases for conversion of these from ICD-O-3 1st edition (M9590-M9992)
** (see chapter 3 Table 3.2 of CI5-XI)
gen siteiarchaem=.
label define siteiarchaem_lab ///
1 "Malignant lymphomas,NOS or diffuse" ///
2 "Hodgkin lymphoma" ///
3 "Mature B-cell lymphomas" ///
4 "Mature T- and NK-cell lymphomas" ///
5 "Precursor cell lymphoblastic lymphoma" ///
6 "Plasma cell tumours" ///
7 "Mast cell tumours" ///
8 "Neoplasms of histiocytes and accessory lymphoid cells" ///
9 "Immunoproliferative diseases" ///
10 "Leukemias, NOS" ///
11 "Lymphoid leukemias" ///
12 "Myeloid leukemias" ///
13 "Other leukemias" ///
14 "Chronic myeloproliferative disorders" ///
15 "Other hematologic disorders" ///
16 "Myelodysplastic syndromes"
label var siteiarchaem "IARC CI5-XI lymphoid & haem diseases"
label values siteiarchaem siteiarchaem_lab

** Note that morphcat is based on ICD-O-3 edition 3.1. so e.g. morphcat54
replace siteiarchaem=1 if morphcat==41 //7 changes
replace siteiarchaem=2 if morphcat==42 //6 changes
replace siteiarchaem=3 if morphcat==43 //16 changes
replace siteiarchaem=4 if morphcat==44 //5 changes
replace siteiarchaem=5 if morphcat==45 //1 change
replace siteiarchaem=6 if morphcat==46 //32 changes
replace siteiarchaem=7 if morphcat==47 //0 changes
replace siteiarchaem=8 if morphcat==48 //0 changes
replace siteiarchaem=9 if morphcat==49 //0 changes
replace siteiarchaem=10 if morphcat==50 //4 changes
replace siteiarchaem=11 if morphcat==51 //5 changes
replace siteiarchaem=12 if morphcat==52 //6 changes
replace siteiarchaem=13 if morphcat==53 //0 changes
replace siteiarchaem=14 if morphcat==54 //5 changes
replace siteiarchaem=15 if morphcat==55 //1 change
replace siteiarchaem=16 if morphcat==56 //6 changes

tab siteiarchaem ,m //15 missing - correct!
count if (siteiarc>51 & siteiarc<59) & siteiarchaem==. //0
//list pid cr5id primarysite top hx morph morphcat iccc icd10 if (siteiarc>51 & siteiarc<59) & siteiarchaem==.


** Create ICD-10 groups according to analysis tables in CR5 db (added after analysis dofiles 4,6)
gen sitecr5db=.
label define sitecr5db_lab ///
1 "Mouth & pharynx (C00-14)" ///
2 "Oesophagus (C15)" ///
3 "Stomach (C16)" ///
4 "Colon, rectum, anus (C18-21)" ///
5 "Liver (C22)" ///
6 "Pancreas (C25)" ///
7 "Larynx (C32)" ///
8 "Lung, trachea, bronchus (C33-34)" ///
9 "Melanoma of skin (C43)" ///
10 "Breast (C50)" ///
11 "Cervix (C53)" ///
12 "Corpus & Uterus NOS (C54-55)" ///
13 "Ovary & adnexa (C56)" ///
14 "Prostate (C61)" ///
15 "Testis (C62)" ///
16 "Kidney & urinary NOS (C64-66,68)" ///
17 "Bladder (C67)" ///
18 "Brain, nervous system (C70-72)" ///
19 "Thyroid (C73)" ///
20 "O&U (C26,39,48,76,80)" ///
21 "Lymphoma (C81-85,88,90,96)" ///
22 "Leukaemia (C91-95)" ///
23 "Other digestive (C17,23-24)" ///
24 "Nose, sinuses (C30-31)" ///
25 "Bone, cartilage, etc (C40-41,45,47,49)" ///
26 "Other skin (C44)" ///
27 "Other female organs (C51-52,57-58)" ///
28 "Other male organs (C60,63)" ///
29 "Other endocrine (C74-75)" ///
30 "Myeloproliferative disorders (MPD)" ///
31 "Myelodysplastic syndromes (MDS)" ///
32 "D069: CIN 3" ///
33 "Eye,Heart,etc (C69,C38)" ///
34 "All sites but C44"
label var sitecr5db "CR5db sites"
label values sitecr5db sitecr5db_lab

replace sitecr5db=1 if (regexm(icd10,"C00")|regexm(icd10,"C01")|regexm(icd10,"C02") ///
					 |regexm(icd10,"C03")|regexm(icd10,"C04")|regexm(icd10,"C05") ///
					 |regexm(icd10,"C06")|regexm(icd10,"C07")|regexm(icd10,"C08") ///
					 |regexm(icd10,"C09")|regexm(icd10,"C10")|regexm(icd10,"C11") ///
					 |regexm(icd10,"C12")|regexm(icd10,"C13")|regexm(icd10,"C14")) //26 changes
replace sitecr5db=2 if regexm(icd10,"C15") //12 changes
replace sitecr5db=3 if regexm(icd10,"C16") //37 changes
replace sitecr5db=4 if (regexm(icd10,"C18")|regexm(icd10,"C19")|regexm(icd10,"C20")|regexm(icd10,"C21")) //172 changes
replace sitecr5db=5 if regexm(icd10,"C22") //7 changes
replace sitecr5db=6 if regexm(icd10,"C25") //27 changes
replace sitecr5db=7 if regexm(icd10,"C32") //7 changes
replace sitecr5db=8 if (regexm(icd10,"C33")|regexm(icd10,"C34")) //32 changes
replace sitecr5db=9 if regexm(icd10,"C43") //10 changes
replace sitecr5db=10 if regexm(icd10,"C50") //209 changes
replace sitecr5db=11 if regexm(icd10,"C53") //19 changes
replace sitecr5db=12 if (regexm(icd10,"C54")|regexm(icd10,"C55")) //53 changes
replace sitecr5db=13 if regexm(icd10,"C56") //19 changes
replace sitecr5db=14 if regexm(icd10,"C61") //228 changes
replace sitecr5db=15 if regexm(icd10,"C62") //2 changes
replace sitecr5db=16 if (regexm(icd10,"C64")|regexm(icd10,"C65")|regexm(icd10,"C66")|regexm(icd10,"C68")) //19 changes
replace sitecr5db=17 if regexm(icd10,"C67") //17 changes
replace sitecr5db=18 if (regexm(icd10,"C70")|regexm(icd10,"C71")|regexm(icd10,"C72")) //11 changes
replace sitecr5db=19 if regexm(icd10,"C73") //12 changes
replace sitecr5db=20 if siteiarc==61 //40 changes
replace sitecr5db=21 if (regexm(icd10,"C81")|regexm(icd10,"C82")|regexm(icd10,"C83")|regexm(icd10,"C84")|regexm(icd10,"C85")|regexm(icd10,"C88")|regexm(icd10,"C90")|regexm(icd10,"C96")) //67 changes
replace sitecr5db=22 if (regexm(icd10,"C91")|regexm(icd10,"C92")|regexm(icd10,"C93")|regexm(icd10,"C94")|regexm(icd10,"C95")) //15 changes
replace sitecr5db=23 if (regexm(icd10,"C17")|regexm(icd10,"C23")|regexm(icd10,"C24")) //20 changes
replace sitecr5db=24 if (regexm(icd10,"C30")|regexm(icd10,"C31")) //2 changes
replace sitecr5db=25 if (regexm(icd10,"C40")|regexm(icd10,"C41")|regexm(icd10,"C45")|regexm(icd10,"C47")|regexm(icd10,"C49")) //7 changes
replace sitecr5db=26 if siteiarc==25 //0 changes
replace sitecr5db=27 if (regexm(icd10,"C51")|regexm(icd10,"C52")|regexm(icd10,"C57")|regexm(icd10,"C58")) //8 changes
replace sitecr5db=28 if (regexm(icd10,"C60")|regexm(icd10,"C63")) //1 change
replace sitecr5db=29 if (regexm(icd10,"C74")|regexm(icd10,"C75")) //0 changes
replace sitecr5db=30 if siteiarc==59 //6 changes
replace sitecr5db=31 if siteiarc==60 //6 changes
replace sitecr5db=32 if siteiarc==64 //18 changes
replace sitecr5db=33 if (regexm(icd10,"C38")|regexm(icd10,"C69")) //3 changes

tab sitecr5db ,m //0 missing
//list pid cr5id top morph icd10 if sitecr5db==.


***********************
** Create ICD10 site **
***********************
** Create variable based on ICD-10 2010 version to use in graphs (dofile 12) - may not use
gen siteicd10=.
label define siteicd10_lab ///
1 "C00-C14: lip,oral cavity & pharynx" ///
2 "C15-C26: digestive organs" ///
3 "C30-C39: respiratory & intrathoracic organs" ///
4 "C40-C41: bone & articular cartilage" ///
5 "C43: melanoma" ///
6 "C44: other skin" ///
7 "C45-C49: mesothelial & soft tissue" ///
8 "C50: breast" ///
9 "C51-C58: female genital organs" ///
10 "C61: prostate" ///
11 "C60-C62,C63: male genital organs" ///
12 "C64-C68: urinary tract" ///
13 "C69-C72: eye,brain,other CNS" ///
14 "C73-C75: thyroid & other endocrine glands" ///
15 "C76-C79: ill-defined sites" ///
16 "C80: primary site unknown" ///
17 "C81-C96: lymphoid & haem"
label var siteicd10 "ICD-10 site of tumour"
label values siteicd10 siteicd10_lab


replace siteicd10=1 if (regexm(icd10,"C00")|regexm(icd10,"C01")|regexm(icd10,"C02") ///
					 |regexm(icd10,"C03")|regexm(icd10,"C04")|regexm(icd10,"C05") ///
					 |regexm(icd10,"C06")|regexm(icd10,"C07")|regexm(icd10,"C08") ///
					 |regexm(icd10,"C09")|regexm(icd10,"C10")|regexm(icd10,"C11") ///
					 |regexm(icd10,"C12")|regexm(icd10,"C13")|regexm(icd10,"C14")) //26 changes
replace siteicd10=2 if (regexm(icd10,"C15")|regexm(icd10,"C16")|regexm(icd10,"C17") ///
					 |regexm(icd10,"C18")|regexm(icd10,"C19")|regexm(icd10,"C20") ///
					 |regexm(icd10,"C21")|regexm(icd10,"C22")|regexm(icd10,"C23") ///
					 |regexm(icd10,"C24")|regexm(icd10,"C25")|regexm(icd10,"C26")) //280 changes
replace siteicd10=3 if (regexm(icd10,"C30")|regexm(icd10,"C31")|regexm(icd10,"C32")|regexm(icd10,"C33")|regexm(icd10,"C34")|regexm(icd10,"C37")|regexm(icd10,"C38")|regexm(icd10,"C39")) //42 changes
replace siteicd10=4 if (regexm(icd10,"C40")|regexm(icd10,"C41")) //2 changes
replace siteicd10=5 if siteiarc==24 //10 changes
replace siteicd10=6 if siteiarc==25 //0 changes
replace siteicd10=7 if (regexm(icd10,"C45")|regexm(icd10,"C46")|regexm(icd10,"C47")|regexm(icd10,"C48")|regexm(icd10,"C49")) //6 changes
replace siteicd10=8 if regexm(icd10,"C50") //209 changes
replace siteicd10=9 if (regexm(icd10,"C51")|regexm(icd10,"C52")|regexm(icd10,"C53")|regexm(icd10,"C54")|regexm(icd10,"C55")|regexm(icd10,"C56")|regexm(icd10,"C57")|regexm(icd10,"C58")) //99 changes
replace siteicd10=10 if regexm(icd10,"C61") //228 changes
replace siteicd10=11 if (regexm(icd10,"C60")|regexm(icd10,"C62")|regexm(icd10,"C63")) //3 changes
replace siteicd10=12 if (regexm(icd10,"C64")|regexm(icd10,"C65")|regexm(icd10,"C66")|regexm(icd10,"C67")|regexm(icd10,"C68")) //36 changes
replace siteicd10=13 if (regexm(icd10,"C69")|regexm(icd10,"C70")|regexm(icd10,"C71")|regexm(icd10,"C72")) //13 changes
replace siteicd10=14 if (regexm(icd10,"C73")|regexm(icd10,"C74")|regexm(icd10,"C75")) //12 changes
replace siteicd10=15 if (regexm(icd10,"C76")|regexm(icd10,"C77")|regexm(icd10,"C78")|regexm(icd10,"C79")) //0 changess
replace siteicd10=16 if regexm(icd10,"C80") //35 changes
replace siteicd10=17 if (regexm(icd10,"C81")|regexm(icd10,"C82")|regexm(icd10,"C83") ///
					 |regexm(icd10,"C84")|regexm(icd10,"C85")|regexm(icd10,"C86") ///
					 |regexm(icd10,"C87")|regexm(icd10,"C88")|regexm(icd10,"C89") ///
					 |regexm(icd10,"C90")|regexm(icd10,"C91")|regexm(icd10,"C92") ///
					 |regexm(icd10,"C93")|regexm(icd10,"C94")|regexm(icd10,"C95")|regexm(icd10,"C96")) //82 changes


tab siteicd10 ,m //1 missing - CIN3, beh /0,/1,/2 and MPDs
//list pid cr5id hx top morph beh icd10 if siteicd10==.

** Check non-2015 dxyrs are reportable
count if resident==2 //0
count if resident==99 //0
count if recstatus==3 //0
count if sex==9 //0
count if beh!=3 //0
count if persearch>2 //0
count if siteiarc==25 //0
** Remove non-reportable dx
//none to be removed

tab dxyr ,m

count //24

label data "BNR-C data - CRICCS submission"
notes _dta :These data prepared from MAIN CanReg5 (BNR-C) database
save "`datapath'\version02\2-working\criccs_preappend" ,replace
note: TS This dataset can be used for appending to 2013-2015 incidence data
