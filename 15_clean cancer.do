** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          15_clean cancer.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      02-DEC-2019
    // 	date last modified      30-JUN-2021
    //  algorithm task          Preparing 2015 cancer dataset for cleaning; Preparing previous years for combined dataset
    //  status                  Completed
    //  objective               To have one dataset with cleaned and grouped 2008, 2013, 2014 data for inclusion in 2015 cancer report.
    //  methods                 Clean and update all years' data using IARCcrgTools Check and Multiple Primary

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
    log using "`logpath'\15_clean cancer.smcl", replace
** HEADER -----------------------------------------------------

/*
    The below cases could not be confirmed by cancer team (the reasons noted below)
    as of 13feb2020 so likely will end up being dropped from analysis:
    
    20150268	f/u at Bay View or Dr Lynch or IPS Lab re DOB, NRN, Age, Address, Residency
	20150298	f/u at Dr A Richards (oral surgeon) or Bay View or IPS Lab re DOB, NRN, Age, Residency, Address, SLC, DLC
	20150330	f/u at H Thani or BVH re DOB, NRN, Address, Residency, DLC
	20150334	f/u at M O'Shea or QEH re DOB, NRN, Address, Residency, DLC
	20150418	f/u at M Khan re NRN, Address, Residency, DLC
	20150424	f/u at E Springer-Cyrus (Palm Court) re Final dx; If gene rearrangement studies were done (see Consult. Rpt
	20150426	f/u at C Edwards (Palm Court) re NRN, Address, Residency, DLC
	20150556	f/u at C Nicholls to abstract case - missed eligible abs
	20151151	f/u at M O'Shea or QEH re DOB, NRN, Address, Residency, DLC
	20155059	f/u at I Lewis re NRN, Address, Residency, DLC
	20155094	f/u at QEH re InciDate for Prostate COD, Path Rpt for Prostate COD; possible missed eligible abs
	20155287	f/u at C Nicholls to abstract
*/

** Import cancer incidence data from CLEAN CR5db
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
import excel using "`datapath'\version02\1-input\2020-02-13_Exported Source+Tumour+Patient_JC_CLEAN_excel.xlsx", firstrow

** Format incidence date to create tumour year
nsplit IncidenceDate, digits(4 2 2) gen(dotyear dotmonth dotday)
gen dot=mdy(dotmonth, dotday, dotyear)
format dot %dD_m_CY
gen dotyear2 = year(dot)
label var dot "IncidenceDate"
label var dotyear "Incidence year"
drop IncidenceDate

count //2197

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
rename Staging staging
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

** Remove cases already in 2008 2013 2014 dataset
drop if pid=="20080023"|pid=="20080048" & regexm(cr5id,"T1")|pid=="20080169"|pid=="20080336" & regexm(cr5id,"T1") ///
		|pid=="20080365" & (cr5id=="T1S1"|cr5id=="T2S1")|pid=="20080567" & regexm(cr5id,"T1")|pid=="20080679" & regexm(cr5id,"T1") ///
		|pid=="20081085" & regexm(cr5id,"T1")|pid=="20130410" & regexm(cr5id,"T1")|pid=="20130672" & regexm(cr5id,"T1") ///
		|pid=="20130804"|pid=="20130885" & regexm(cr5id,"T1")|pid=="20140822" & regexm(cr5id,"T1")|pid=="20140872" ///
		|pid=="20140886"|pid=="20140962"|pid=="20140973"|pid=="20141129"|pid=="20141258" & regexm(cr5id,"T1") ///
		|pid=="20141379" & regexm(cr5id,"T1")|pid=="20141434" & regexm(cr5id,"T1")|pid=="20141523" ///
		|pid=="20145070" & regexm(cr5id,"T1")|pid=="20145142"|pid=="20150037"|pid=="20155202"

** Remove cases NOT diagnosed in 2008, 2013, 2014, 2015
tab dxyr ,m
drop if dxyr!=2008 & dxyr!=2013 & dxyr!=2014 & dxyr!=2015 //112 deleted

count //2037

** Create variable to count # of tumour and source records per patient record using cr5id
gen tumourtot=.
gen sourcetot=.
replace tumourtot=1 if regexm(cr5id, "T1") //1872 changes
replace tumourtot=2 if regexm(cr5id, "T2") //150 changes
replace tumourtot=3 if regexm(cr5id, "T3") //12 changes
replace tumourtot=4 if regexm(cr5id, "T4") //1 change
replace tumourtot=5 if regexm(cr5id, "T5") //0 changes
replace tumourtot=6 if regexm(cr5id, "T6") //0 changes
replace tumourtot=7 if regexm(cr5id, "T7") //0 changes
replace tumourtot=8 if regexm(cr5id, "T8") //0 changes
replace sourcetot=1 if regexm(cr5id, "S1") //1177 changes
replace sourcetot=2 if regexm(cr5id, "S2") //593 changes
replace sourcetot=3 if regexm(cr5id, "S3") //213 changes
replace sourcetot=4 if regexm(cr5id, "S4") //41 changes
replace sourcetot=5 if regexm(cr5id, "S5") //5 changes
replace sourcetot=6 if regexm(cr5id, "S6") //1 change
replace sourcetot=7 if regexm(cr5id, "S7") //1 change
replace sourcetot=8 if regexm(cr5id, "S8") //1 change
** Check for missing cr5ids that were not replaced above
count if tumourtot==. //3
count if sourcetot==. //5
//list pid cr5id sid dxyr tumourtot sourcetot if tumourtot==. | sourcetot==.

replace tumourtot=2 if pid=="20130648" & cr5id=="" //1 change
replace sourcetot=1 if pid=="20130648" & cr5id=="" //1 change
replace cr5id="T2S1" if pid=="20130648" & cr5id=="" //1 change

replace tumourtot=1 if pid=="20151026" & cr5id=="T1T3" //1 change
replace sourcetot=3 if pid=="20151026" & cr5id=="T1T3" //1 change
replace cr5id="T1S3" if pid=="20151026" & cr5id=="T1T3" //1 change

replace cr5id="T1S2" if pid=="20151078" & sourcetot==. //1 change
replace sourcetot=2 if pid=="20151078" & sourcetot==. //1 change

replace cr5id=upper(cr5id) if tumourtot==. | sourcetot==. //2 changes
replace tumourtot=1 if tumourtot==. //2 changes
replace sourcetot=1 if sourcetot==. //2 changes

tab tumourtot ,m
tab sourcetot ,m


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
count if non_numeric_ptda //2
//list pid ptda cr5id if non_numeric_ptda
replace ptda="09" if ptda=="2S" //2 changes
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
** contains a nonnumeric character so field needs correcting!
generate byte non_numeric_ptrv = indexnot(ptreviewer, "0123456789.-")
count if non_numeric_ptrv //3
//list pid ptreviewer cr5id if non_numeric_ptrv
replace ptreviewer="09" if ptreviewer=="T1" //3 changes
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

replace Treatment3Date=20000101 if Treatment3Date==99999999
nsplit Treatment3Date, digits(4 2 2) gen(rx3year rx3month rx3day)
gen rx3d=mdy(rx3month, rx3day, rx3year)
format rx3d %dD_m_CY
drop Treatment3Date
label var rx3d "Treatment3Date"

replace Treatment4Date=20000101 if Treatment4Date==99999999
if Treatment4Date !=. nsplit Treatment4Date, digits(4 2 2) gen(rx4year rx4month rx4day)
if Treatment4Date !=. gen rx4d=mdy(rx4month, rx4day, rx4year)
if Treatment4Date !=. format rx4d %dD_m_CY
if Treatment4Date ==. rename Treatment4Date rx4d
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
count if non_numeric_stda //1
//list pid stda cr5id if non_numeric_stda
replace stda="09" if stda=="S2" //1 change
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

count //2037

drop non_numeric*

***********************
*  Consistency Check  *
*	  Categories      *
***********************
** Create categories for topography according to groupings in ICD-O-3 book
gen topcat=. //5150 01mar18
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
gen morphcat=. //5150 01mar18
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
gen hxfamcat=. //5150 26mar18
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
gen latcat=. //5150 04apr18
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
replace othtreat1="" if othtreat1=="." //5021 23apr18
gen orxcheckcat=.
replace orxcheckcat=1 if orx1==. & (rx1==8|rx2==8|rx3==8|rx4==8|rx5==8)
replace orxcheckcat=2 if orx1!=. & orx2==.
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
replace notreat1="" if notreat1=="." //4809 23apr18
replace notreat2="" if notreat2=="." //5139 23apr18
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

count //2037


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
count if persearch==0 //1744 - person serach not done; can ignore as will check duplicates in this dofile
count if persearch==3 //0
count if persearch==4 //0

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
count if ptdoa!=stdoa & ptdoa!=d(01jan2000) & stdoa!=d(01jan2000) & (tumourtot<2 & sourcetot<2) //62 - no correction necessary
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
count if cstatus==3 & recstatus<3 //12
//list pid cstatus recstatus resident beh dxyr cr5id if cstatus==3 & recstatus<3
replace cstatus=1 if cstatus==3 & recstatus<3 //12 changes

** Check 11 - invalid (record status for all tumours in a patient record=duplicate)
count if cstatus==1 & recstatus==4 //108 - no review needed as already done
//list pid cstatus dxyr cr5id if cstatus==1 & recstatus==4

****************
** Notes Seen **
****************
** Added after these checks were sequentially written
** Additional check for PT variable
** Check 174 - Notes Seen (check for missed 2015 cases that were abstracted in this dofile) 
count if notesseen==0 & dxyr==2015 //49
//list pid cr5id if notesseen==0 & dxyr==2015
** Check main CR5db then correct
replace notesseen=2 if notesseen==0 & dxyr==2015 //49 changes

** Check 175 - Notes Seen=pending retrieval; dxyr>2013 (for 2018 data collection this check will be revised)
count if notesseen==0 & dxyr>2013 //0
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
count if birthdate==. & primarysite!="" //0
//list pid dobyear dobmonth dobday if birthdate==. & primarysite!=""

** Check 27 - missing but full NRN available
gen nrnday = substr(natregno,5,2)
count if dob==. & natregno!="" & natregno!="9999999999" & natregno!="999999-9999" & natregno!="99" & nrnday!="99" //0
//list pid cr5id dob natregno cstatus recstatus dxyr if dob==. & natregno!="" & natregno!="9999999999" & natregno!="999999-9999" & natregno!="99" & nrnday!="99"

** Check 28 - invalid (dob has future year)
gen dob_yr = year(dob)
count if dob!=. & dob_yr>2014 //0
//list pid dob dob_yr if dob!=. & dob_yr>2014

** Check 29 - invalid (dob does not match natregno)
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

***********************
** National Reg. No. **
***********************
sort pid
** Check 30 - missing 
count if natregno=="" & dob!=. //1
//list pid cr5id dob natregno cstatus recstatus dxyr if natregno=="" & dob!=.

** Check 31 - invalid length
count if length(natregno)<11 & natregno!="" //3
//list pid natregno if length(natregno)<11 & natregno!=""

*********
** Sex **
*********
** Check 32 - missing
count if sex==. | sex==9 //7
//list pid sex fname primarysite top if sex==.|sex==9
replace sex=2 if sex==.|sex==9 //7 changes

** Check 33 - possibly invalid (first name, NRN and sex check: MALES)
gen nrnid=substr(natregno, -4,4)
count if sex==2 & nrnid!="9999" & regex(substr(natregno,-2,1), "[1,3,5,7,9]") //5
//list pid fname lname sex natregno primarysite top cr5id if sex==2 & nrnid!="9999" & regex(substr(natregno,-2,1), "[1,3,5,7,9]")
replace sex=1 if pid=="20151061"|pid=="20151378" //5 changes

** Check 34 - possibly invalid (sex=M; site=breast)
count if sex==1 & (regexm(cr5cod, "BREAST") | regexm(top, "^50")) //2 - no changes; all correct
//list pid fname lname natregno sex top cr5cod cr5id if sex==1 & (regexm(cr5cod, "BREAST") | regexm(top, "^50"))

** Check 35 - invalid (sex=M; site=FGS)
count if sex==1 & topcat>43 & topcat<52	& (regexm(cr5cod, "VULVA") | regexm(cr5cod, "VAGINA") | regexm(cr5cod, "CERVIX") | regexm(cr5cod, "CERVICAL") ///
								| regexm(cr5cod, "UTER") | regexm(cr5cod, "OVAR") | regexm(cr5cod, "PLACENTA")) //0
//list pid fname lname natregno sex top cr5cod cr5id if sex==1 & topcat>43 & topcat<52 & (regexm(cr5cod, "VULVA") | regexm(cr5cod, "VAGINA") ///
//								| regexm(cr5cod, "CERVIX") | regexm(cr5cod, "CERVICAL") | regexm(cr5cod, "UTER") | regexm(cr5cod, "OVAR") | regexm(cr5cod, "PLACENTA"))
								
** Check 36 - possibly invalid (first name, NRN and sex check: FEMALES)
count if sex==1 & nrnid!="9999" & regex(substr(natregno,-2,1), "[0,2,4,6,8]") //7
//list pid fname lname sex natregno primarysite top cr5id if sex==1 & nrnid!="9999" & regex(substr(natregno,-2,1), "[0,2,4,6,8]")
replace sex=2 if pid=="20150537" //3 changes

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
count if resident==. //41 - all recstatus=ineligible
//list pid resident recstatus cr5id if resident==.

*************************
** Status Last Contact **
*************************
** Check 40 - missing
count if slc==. & recstatus<3 //1
//list pid slc recstatus cr5id if slc==. & recstatus<3
tab slc recstatus,m
replace notesseen=3 if pid=="20151084"
replace slc=1 if pid=="20151084"
replace dlc=d(10feb2015) if pid=="20151084"
replace parish=99 if pid=="20151084"
replace addr="99" if pid=="20151084"

** Check 41 - invalid (slc=died;dlc=blank)
count if slc==2 & dlc==. //0
//list pid slc dlc cr5id if slc==2 & dlc==.

** Check 42 - invalid (slc=alive;dlc=blank)
count if slc==1 & dlc==. //1
//list pid slc dlc recstatus cr5id if slc==1 & dlc==.
replace dlc=d(13aug2015) if pid=="20151310"

** Check 43 - invalid (slc=alive;nftype=death info)
count if slc==1 & (nftype==8 | nftype==9) //4
//list pid slc nftype cr5id if slc==1 & (nftype==8 | nftype==9)
replace slc=2 if pid=="20150420"|pid=="20150435"|pid=="20151229"|pid=="20151249" //10 changes

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
count if comments=="" & cstatus==1 //7
//list pid cstatus comments cr5id if comments=="" & cstatus==1
replace comments="99" if comments=="" & cstatus==1 //7 changes


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
count if recstatus==0 & dxyr!=. //3
//list pid dxyr cr5id resident age if recstatus==0 & dxyr!=.
replace recstatus=1 if recstatus==0 & dxyr!=. //3 changes

** Check 48 - invalid(cstatus=CF;recstatus<>Pending)
count if recstatus!=0 & cstatus==0 & ttdoa!=. //6 - no changes needed
//list pid cstatus recstatus dxyr ttdoa pid2 cr5id if recstatus!=0 & cstatus==0 & ttdoa!=.

** Check 49a - possibly invalid (tumour record listed as deleted)
count if recstatus==2 //0

** REVIEW ALL dxyr>2013 CASES FLAGGED AS INELIGIBLE SINCE SOME DISCOVERED IN 2014 AS INELIGIBLE WHICH ARE ELIGIBLE FOR REGISTRATION
** Points to note: (1) reason for ineligibility should be recorded by DA in Comments field; (2) dxyr should be updated with correct year.
count if recstatus==3 //118 - already reviewed
//list pid cr5id dxyr ttda recstatus if recstatus==3

** Check 49b - review all cases flagged as ineligible to check for missed 2013 cases
** JC 30oct18: In later checks I incidentally discovered missed 2013 cases so added in this new check
count if recstatus==3 & cr5id=="T1S1" //86 - already reviewed

*********************
** TT Check Status **
*********************
** This is auto-generated by CR5 while simultaneously allowing for manual input so
** there will never be any records with missing recstatus

** Check 50 - invalid (checkstatus=notdone;recstatus=pend/confirm;primarysite<>blank)
count if checkstatus==0 & recstatus<2 & primarysite!="" //0
//list pid dxyr checkstatus recstatus cr5id if checkstatus==0 & recstatus<2 & primarysite!=""

** Check 51 - invalid (checkstatus=invalid;recstatus=pend/confirm;primarysite<>blank)
count if checkstatus==3 & recstatus<2 & primarysite!="" //3 - no age/DOB and not in death data so cannot confirm
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
count if addr=="" & parish!=. & cstatus!=0 & cr5id=="T1S1" //7
//list pid parish addr sourcename recstatus cr5id if addr=="" & parish!=. & cstatus!=0 & cr5id=="T1S1"
replace addr="99" if addr=="" & parish!=. & cstatus!=0 & cr5id=="T1S1" //7 changes - all ineligibles
* addr=="" & parish!=. & cstatus!=0 & cr5id=="T1S1" & recstatus==3 //7 changes

**********	
**	Age **
**********
** Check 58 - missing
count if (age==-1 | age==.) & dot!=. //2-no age/DOB and not in death data so cannot confirm (20141167, 20141510, 20145025)
//list pid cr5id if (age==-1 | age==.) & dot!=.
count if age==-1 //18
replace age=999 if age==-1 //18 changes

** Check 59 - invalid (age<>incidencedate-dob); checked no errors
** Age (at INCIDENCE - to nearest year)
gen ageyrs = (dot - dob)/365.25 //
gen checkage=int(ageyrs)
drop ageyrs
label var checkage "Age in years at INCIDENCE"
count if dob!=. & dot!=. & age!=checkage //1 - these correct according to CR5 as same day & month for dob & dot
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
count if topcheckcat!=. //64 - all correct
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
replace morphology="" if morphology=="." //778 changes
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
		 |strmatch(strupper(hx), "*INTRA-EPITHELIAL NEOPLASIA*")) & hx!="CLL" & hx!="PIN" & hx!="HGCGIN /  AIS" //16
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
count if morph==8000 & (basis==6|basis==7|basis==8) //11 - all correct
//list pid hx basis cr5id if morph==8000 & (basis==6|basis==7|basis==8)

** Check 74 - invalid(hx<>morph)
sort pid

** morphcheckcat 1: Hx=Undifferentiated Ca & Morph!=8020
count if morphcheckcat==1 //3 - all correct
//list pid hx morph basis cfdx cr5id if morphcheckcat==1, string(100)

** morphcheckcat 2: Hx!=Undifferentiated Ca & Morph==8020
count if morphcheckcat==2 //0
//list pid hx morph basis cfdx cr5id if morphcheckcat==2

** morphcheckcat 3: Hx=Papillary ca & Morph!=8050
count if morphcheckcat==3 //15 - all correct
//list pid hx morph top basis beh cr5id if morphcheckcat==3

** morphcheckcat 4: Hx=Papillary serous adenoca & Morph!=8460 & Top!=ovary/peritoneum
count if morphcheckcat==4 //0 (thyroid/renal=M8260 & ovary/peritoneum=M8461 & endometrium=M8460)
//list pid top hx morph top basis beh cr5id if morphcheckcat==4

** morphcheckcat 5: Hx=Papillary & intraduct/intracyst & Morph!=8503
count if morphcheckcat==5 //2
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
count if morphcheckcat==17 //1
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
count if morphcheckcat==28 //6 - all correct
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==28

** morphcheckcat 29: Hx==follicular & minimally invasive & morph!=8335
count if morphcheckcat==29 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==29

** morphcheckcat 30: Hx==microcarcinoma & morph!=8341
count if morphcheckcat==30 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==30

** morphcheckcat 31: Hx!=endometrioid & morph==8380
count if morphcheckcat==31 //1 - 20140739 alredy corrected in Check 11 above.
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==31

** morphcheckcat 32: Hx==poroma & morph!=8409 & mptot<2
count if morphcheckcat==32 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==32

** morphcheckcat 33: Hx==serous excl. papillary & morph!=8441
count if morphcheckcat==33 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==33

** morphcheckcat 34: Hx==mucinous excl. endocervical,producing,secreting,infiltrating duct & morph!=8480
count if morphcheckcat==34 //4 - all correct
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
count if morphcheckcat==40 //4 - all correct
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
count if morphcheckcat==76 //1
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==76
replace hx="ADULT T-CELL LEUKAEMIA/LYMPHOMA HTLV-1 ASSOCIATED" if pid=="20155178" //1 change

** morphcheckcat 77: Hx=non-hodgkin lymphoma & Hx!=cell (to excl. mantle, large, cleaved, small, etc) & morph!=9591
count if morphcheckcat==77 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==77

** morphcheckcat 78: Hx=precursor t-cell acute lymphoblastic leukemia & morph!=9837
** note: ICD-O-3 has another matching code (M9729) but WHO Classification notes that M9837 more accurate
count if morphcheckcat==78 //0
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==78

** morphcheckcat 79: Hx=CML (chronic myeloid/myelogenous leukemia) & Hx!=genetic studies & morph==9863
** note: HemeDb under CML, NOS notes 'Presumably myelogenous leukemia without genetic studies done would be coded to M9863.'
count if morphcheckcat==79 //2
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==79

** morphcheckcat 80: Hx=CML (chronic myeloid/myelogenous leukemia) & Hx!=BCR/ABL1 & morph==9875
** note: HemeDb under CML, NOS notes 'Presumably myelogenous leukemia without genetic studies done would be coded to M9863.'
count if morphcheckcat==80 //2 - correct
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
replace morph=9950 if pid=="20155085" & cr5id=="T1S1" //2 changes
replace hx="MYELOPROLIFERATIVE DISEASE LIKELY POLYCYTHEMIA RUBRA VERA" if pid=="20155085" & cr5id=="T1S1" //2 changes

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
count if morphcheckcat==91 //35 - on 22oct18 JC added in top!=619 to this code so now count=0
//list pid primarysite hx morph cr5id if morphcheckcat==91

** morphcheckcat 92: Hx!=fibro & histiocytoma & morph=8830 (see morphcheckcat=50 also!)
count if morphcheckcat==92 //1
//list pid primarysite hx morph basis beh cr5id if morphcheckcat==92

** morphcheckcat 93: Hx=acinar & top=619 & morph!=8140
/*
This check added on 22oct18 after update re morphcheckcat 91 above.  
*/
count if morphcheckcat==93 //1
//list pid primarysite hx morph cr5id if morphcheckcat==93
replace morph=8140 if morphcheckcat==93 //1 change

** morphcheckcat 94: Hx=hodgkin & morph=non-hodgkin
count if morphcheckcat==94 //3 - corrected in Check 76 subcheck 1 below
//list pid hx morph cr5id if morphcheckcat==94

** morphcheckcat 95: Hx=leukaemia & morph=9729
count if morphcheckcat==95 //0
//list pid hx morph cr5id if morphcheckcat==95

** morphcheckcat 96: Hx=lymphoma & morph=9837
count if morphcheckcat==96 //0
//list pid hx morph cr5id if morphcheckcat==96

** Check 76 - invalid(primarysite vs hx)
** hxcheckcat 1: PrimSite=Blood/Bone Marrow & Hx=Lymphoma 
count if hxcheckcat==1 //5
//list pid top hx morph cr5id if hxcheckcat==1
** Correct data for above list
replace primarysite="LYMPH NODE-UNKNOWN" if pid=="20150556" & regexm(cr5id,"T1") //1 change
replace topography=779 if pid=="20150556" & regexm(cr5id,"T1") //1 change
replace top="779" if pid=="20150556" & regexm(cr5id,"T1") //1 change
replace topcat=69 if pid=="20150556" & regexm(cr5id,"T1") //1 change

replace primarysite="LYMPH NODE-UNKNOWN" if pid=="20155197" & regexm(cr5id,"T1") //1 change
replace topography=779 if pid=="20155197" & regexm(cr5id,"T1") //1 change
replace top="779" if pid=="20155197" & regexm(cr5id,"T1") //1 change
replace topcat=69 if pid=="20155197" & regexm(cr5id,"T1") //1 change

replace primarysite="LYMPH NODE-UNKNOWN" if pid=="20155205" & regexm(cr5id,"T1") //1 change
replace topography=779 if pid=="20155205" & regexm(cr5id,"T1") //1 change
replace top="779" if pid=="20155205" & regexm(cr5id,"T1") //1 change
replace topcat=69 if pid=="20155205" & regexm(cr5id,"T1") //1 change

replace primarysite="LYMPH NODE-UNKNOWN" if pid=="20160018" & regexm(cr5id,"T1") //2 changes
replace topography=779 if pid=="20160018" & regexm(cr5id,"T1") //2 changes
replace top="779" if pid=="20160018" & regexm(cr5id,"T1") //2 changes
replace topcat=69 if pid=="20160018" & regexm(cr5id,"T1") //2 changes

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
count if hxcheckcat==10 //5
//list pid primarysite top hx morph cr5id if hxcheckcat==10
replace primarysite="BRAIN-MENINGES PARIETAL LOBE" if pid=="20151058" //1 change
replace topography=700 if pid=="20151058" //1 change
replace top="700" if pid=="20151058" //1 change
replace topcat=62 if pid=="20151058" //1 change

replace primarysite="BRAIN-MENINGES TEMPORAL LOBE" if pid=="20151086" //1 change
replace topography=700 if pid=="20151086" //1 change
replace top="700" if pid=="20151086" //1 change
replace topcat=62 if pid=="20151086" //1 change

replace primarysite="BRAIN-MENINGES TEMPORAL LOBE" if pid=="20151090" //1 change
replace topography=700 if pid=="20151090" //1 change
replace top="700" if pid=="20151090" //1 change
replace topcat=62 if pid=="20151090" //1 change

replace primarysite="SPINE-MENINGES CERVICAL CORD" if pid=="20151167" //1 change
replace topography=701 if pid=="20151167" //1 change
replace top="701" if pid=="20151167" //1 change
replace topcat=62 if pid=="20151167" //1 change

replace primarysite="BRAIN-MENINGES CEREBELLOPONTINE ANGLE" if pid=="20151270" //1 change
replace topography=700 if pid=="20151270" //1 change
replace top="700" if pid=="20151270" //1 change
replace topcat=62 if pid=="20151270" //1 change

** hxcheckcat 11: PrimSite=Blood/Bone Marrow & Hx=HTLV+T-cell Lymphoma 
count if hxcheckcat==11 //1 - correct
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
count if agecheckcat==11 //3 - no corrections needed
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
count if agecheckcat==18 //3 - all correct
//list pid cr5id age hx morph dxyr if agecheckcat==18

** agecheckcat 19: Age <20 & Top=15._,19._,20._,21._,23._,24._,38.4,50._53._,54._,55._
count if agecheckcat==19 //1 - 20145025 missing dob: no correction needed
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
count if sitecheckcat==2 //3 - 20145112 no corrections needed
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
count if lat==8 //40 - lat should=0(not paired site) if latcat=0 or blank
//list pid lat primarysite latcat cr5id if lat==8
count if lat==8 & (latcat==0|latcat==.) //40
//list pid lat top latcat cr5id if lat==8 & (latcat==0|latcat==.)
replace lat=0 if lat==8 & (latcat==0|latcat==.) //40 changes

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
count if latcheckcat==1 //1 - this is not an error as 'left' refers to non-cancer COD
//list pid cr5id primarysite lat cr5cod dxyr if latcheckcat==1

** latcheckcat 2: COD='right'; COD=cancer (codcat!=1); latcat>0; lat!=right
count if latcheckcat==2 //0
//list pid cr5id primarysite lat cr5cod dxyr if latcheckcat==2

** latcheckcat 3: CFdx='left'; latcat>0; lat!=left
count if latcheckcat==3 //4 - all correct
//list pid cr5id primarysite lat cfdx dxyr if latcheckcat==3 ,string(100)

** latcheckcat 4: CFdx='right'; latcat>0; lat!=right
count if latcheckcat==4 //6 - all correct
//list pid cr5id primarysite lat cfdx dxyr if latcheckcat==4 ,string(100)

** latcheckcat 5: topog==809 & lat!=0-paired site (in accord with SEER Prog. Coding manual 2016 pg 82 #1.a.)
count if latcheckcat==5 //6
//list pid cr5id primarysite topography lat dxyr if latcheckcat==5
replace lat=0 if latcheckcat==5 & topography==809 //6 changes
count if lat!=0 & topography==809 //0
//list pid cr5id primarysite topography lat dxyr if lat!=0 & topography==809

** latcheckcat 6: latcat>0 & lat==0 or 8 (in accord with SEER Prog. Coding manual 2016 pg 82 #2)
count if latcheckcat==6 //7
//list pid cr5id topography lat latcat dxyr if latcheckcat==6
replace lat=2 if pid=="20150400" //1 change
replace lat=1 if pid=="20151086" //1 change
replace lat=2 if pid=="20151090" //1 change
replace lat=1 if pid=="20151124" //3 changes
replace lat=2 if pid=="20151140" //1 change

** latcheckcat 7: latcat!=ovary,lung,eye,kidney & lat==4 (in accord with SEER Prog. Coding manual 2016 pg 82 #4 & IARC MP recommendations for recording #1)
count if latcheckcat==7 //2 - 20140555 already corrected above in check 11
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
count if latcheckcat==12 //11
list pid cr5id topography lat latcat dxyr if latcheckcat==12
replace lat=0 if latcheckcat==12 //11 changes

** latcheckcat 13: lat=N/A & dxyr>2013 (cases dx>2013 should use code '0-not paired site')
count if latcheckcat==13 //37 - all correct
//list pid cr5id topography lat latcat if latcheckcat==13
count if lat==8 & dxyr>2013 //0 - flagged and corrected in below latcheckcat 14
//list pid cr5id topography lat latcat if lat==8 & dxyr>2013

** latcheckcat 14: lat=N/A & latcat!=0
count if latcheckcat==14 //19 - 5 already corrected in above checks
//list pid cr5id topography lat latcat if latcheckcat==14

** latcheckcat 15: lat=unk for a paired site
count if latcheckcat==15 //33
//list pid cr5id topography lat latcat cfdx if latcheckcat==15, string(100)
replace lat=3 if pid=="20150320"|pid=="20155191"|pid=="20155237"|pid=="20155265" ///
				 |pid=="20160436" //12 changes
replace lat=1 if pid=="20151308"|pid=="20151309"|pid=="20151319"|pid=="20151322" //8 changes
replace lat=2 if pid=="20151323" //2 changes
replace primarysite="LUNG-UPPER LOBE" if pid=="20151323" //2 changes
replace top="341" if pid=="20151323" //2 changes
replace topography=341 if pid=="20151323" //2 changes

** latcheckcat 16: lat=9 & top=ovary
count if latcheckcat==16 //11
//list pid cr5id topography lat latcat cfdx if latcheckcat==16, string(100)
replace lat=4 if pid=="20151355" //1 change

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
count if behcheckcat==2 //16 - 20140690 already corrected in check 11.
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
count if gradecheckcat==3 //3 - all correct
//list pid hx morph grade beh morph cr5id if gradecheckcat==3 ,string(100)

** gradecheckcat 4: Grade!=5 & Hx=9702-9709,9716-9726(!=9719),9729,9827,9834,9837 & DxYr>2013
count if gradecheckcat==4 //10
//list pid grade beh morph cr5id if gradecheckcat==4

** gradecheckcat 5: Grade!=5 or 7 & Hx=9714 & DxYr>2013
count if gradecheckcat==5 //0
//list pid grade beh morph cr5id if gradecheckcat==5

** gradecheckcat 6: Grade!=5 or 8 & Hx=9700/9701/9719/9831 & DxYr>2013
count if gradecheckcat==6 //0
//list pid grade beh morph cr5id if gradecheckcat==6

** gradecheckcat 7: Grade!=6 & Hx=>=9670,<=9699,9712,9728,9737,9738,>=9811,<=9818,9823,9826,9833,9836 & DxYr>2013
count if gradecheckcat==7 //10
//list pid hx grade beh morph cr5id if gradecheckcat==7 ,string(100)
replace grade=6 if gradecheckcat==7 //10 changes

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
count if gradecheckcat==16 //42 - leave as is
//list pid grade beh morph cr5id if gradecheckcat==16

** gradecheckcat 17: Grade!=9/blank & DxYr<2014
count if (grade!=9 & grade!=.) & dxyr<2014 //7
//list pid grade dxyr cr5id if (grade!=9 & grade!=.) & dxyr<2014
replace grade=9 if (grade!=9 & grade!=.) & dxyr<2014 //7 changes

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
count if bascheckcat==1 //11 - all correct
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
count if bascheckcat==5 //108
//list pid basis dxyr cr5id comment if bascheckcat==5 ,string(100)
** Check in main CR5 db to see if true DCO then dot=dlc or if to correct basis,dot,dxyr (e.g. if notes seen by DA etc.)
replace basis=1 if pid=="20151361"|pid=="20155126" //3 changes
replace basis=5 if pid=="20151372" //3 changes
replace basis=9 if pid=="20155139"|pid=="20155145" //2 changes
replace recstatus=3 if pid=="20155139"|pid=="20155145" //2 changes
replace basis=2 if pid=="20155257" //1 change

** bascheckcat 6: Basis!=lab test; Comments=PSA; top=prostate
count if bascheckcat==6 //0
//list pid basis dxyr cr5id comment if bascheckcat==6 ,string(100)

** bascheckcat 7: Basis=unk; Comments=Notes seen
count if bascheckcat==7 //11
//list pid basis dxyr cr5id comment if bascheckcat==7 ,string(100)
replace basis=1 if pid=="20155203"|pid=="20155226" //2 changes

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
count if staging==. & dot!=. & dxyr!=2013 //108
//list pid cr5id recstatus dxyr if staging==. & dot!=. & dxyr!=2013
replace staging=8 if staging==. & dot!=. & dxyr!=2013 //108 changes
count if staging!=8 & dot!=. & dxyr==2015 //8
//list pid cr5id staging recstatus dxyr if staging!=8 & dot!=. & dxyr==2015
replace staging=8 if staging!=8 & dot!=. & dxyr==2015 //8 changes

********************
** Incidence Date **
********************
** Check 103 - InciDate missing
count if dot==. & primarysite!="" //6
//list pid primarysite dotyear dotmonth dotday cr5id if dot==. & primarysite!=""
** replace missing incidence dates using dotyear, dotmonth, dotday and
** checking main CR5 to ensure missing day and month (30jun) is logical
** in terms of CR5 comments and other dates e.g. admdate, dlc, treatment dates, etc.
replace dot=d(30jun2014) if pid=="20140817" & regexm(cr5id, "T1") //2 changes
replace dot=d(30jun2015) if pid=="20151365" & regexm(cr5id, "T1") //2 changes
replace dot=d(01jul2015) if pid=="20151366" & regexm(cr5id, "T1") //2 changes

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
count if dot!=. & dlc!=. & basis==0 & dot!=dlc //2
//list pid dot dlc basis ttda cstatus recstatus cr5id if dot!=. & dlc!=. & basis==0 & dot!=dlc
replace basis=9 if pid=="20151346" & regexm(cr5id, "T1") //2 changes

** dotcheckcat 4: InciDate<>DFC/AdmDate/RTdate/SampleDate/ReceiveDate/RptDate/DLC (2014 onwards)
count if dotcheckcat==4 //26 - all correct
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
count if dotcheckcat==8 //3
//list pid cr5id dot dfc admdate rtdate sampledate recvdate rptdate ttda dxyr if dotcheckcat==8
replace rptdate=d(21apr2015) if pid=="20151098" & cr5id=="T1S1" //1 change
replace rptdate=d(24apr2015) if pid=="20151100" & cr5id=="T1S1" //1 change
replace rptdate=d(01jan2016) if pid=="20151228" & cr5id=="T1S1" //1 change

** dotcheckcat 9: InciDate=ReceiveDate; ReceiveDate after DFC/AdmDate/RTdate/SampleDate/RptDate (2014 onwards)
count if dotcheckcat==9 //0
//list pid cr5id dot dfc admdate rtdate sampledate recvdate rptdate ttda dxyr if dotcheckcat==9

** dotcheckcat 10: InciDate=RptDate; RptDate after DFC/AdmDate/RTdate/SampleDate/ReceiveDate (2014 onwards)
count if dotcheckcat==10 //2 - leave 20155071 as is since not confirmed
//list pid cr5id dot dfc admdate rtdate sampledate recvdate rptdate ttda dxyr if dotcheckcat==10
replace dot=d(25may2015) if pid=="20151319" //2 changes

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
count if dxyrcheckcat==2 //15 - all correct
//list pid cr5id admdate admyear dxyr ttda if dxyrcheckcat==2

** dxyrcheckcat 3: dfcyear!=dxyr & dxyr>2013
count if dxyrcheckcat==3 //0
//list pid cr5id dfc dfcyear dxyr ttda if dxyrcheckcat==3

** dxyrcheckcat 4: rtyear!=dxyr & dxyr>2013
count if dxyrcheckcat==4 //4 - all correct
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
count if rx1==. & dxyr==2014 //18
//list pid cr5id if rx1==. & dxyr==2014
//replace rx1=9 if rx1==. & dxyr==2014 //1,658 changes
count if (rx1!=. & rx1!=9) & dxyr==2014 //814
//list pid rx1 dxyr cr5id if (rx1!=. & rx1!=9) & dxyr==2014
//replace rx1=9 if (rx1!=. & rx1!=9) & dxyr==2014 //814 changes

count if rx2!=. & dxyr==2014 //249
//list pid rx2 cr5id if rx2!=. & dxyr==2014
//replace rx2=. if rx2!=. & dxyr==2014 //249 changes

count if rx3!=. //0
count if rx4!=. //0
count if rx5!=. //0

*************************
** Treatments 1-5 Date **
*************************
** Missing dates already captured in checkflags in Rx1-5

** Check 115 - For 2014 data, replace non-blank treatment dates with missing value
count if rx1d!=. & dxyr==2014 //796
//replace rx1d=. if rx1d!=. & dxyr==2014 //796 changes

count if rx2d!=. & dxyr==2014 //246
//list pid rx2d cr5id if rx2d!=. & dxyr==2014
//replace rx2d=. if rx2d!=. & dxyr==2014 //246 changes

count if rx3d!=. & dxyr==2014 //0
count if rx4d!=. & dxyr==2014 //0
count if rx5d!=. & dxyr==2014 //0

***************************
** Other Treatment 1 & 2 **
***************************
** NOTE 1: Treatment only collected at 5 year intervals so treatment collected on 2013 data then 2018 and so on;
** NOTE 2: In upcoming years of data collection (2018 dc year), more rxcheckcat checks will be compiled based on data.

** Check 116 - For 2014 data, replace non-blank other treatment with missing value
count if orx1!=. & dxyr==2014 //0

count if orx2!=. & dxyr==2014 //3
//list pid orx2 dxyr cr5id if orx2!="" & dxyr==2014
//replace orx2="" if orx2!="" & dxyr==2014 //3 changes


***************************
** No Treatments 1 and 2 **
***************************
** NOTE 1: Treatment only collected at 5 year intervals so treatment collected on 2013 data then 2018 and so on;
** NOTE 2: In upcoming years of data collection (2018 dc year), more rxcheckcat checks will be compiled based on data.


** Check 119 - For 2014 data, replace non-blank no treatment with missing value
count if norx1!=. & dxyr==2014 //5
//list pid norx1 dxyr cr5id if norx1!=. & dxyr==2014
//replace norx1=. if norx1!=. & dxyr==2014 //5 changes

count if norx2!=. & dxyr==2014 //0




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
count if stda==. //2 - leave blank as source is blank
//list pid cr5id if stda==.

** Length check not needed as this field is numeric
** Check 121 - invalid code
count if stda!=. & stda>14 & (stda!=22 & stda!=88 & stda!=98 & stda!=99) //0
//list pid stda cr5id if stda!=. & stda>14 & (stda!=22 & stda!=88 & stda!=98 & stda!=99)

*****************
** Source Date **
*****************
** Check 122 - missing
count if stdoa==. //3 - leave blank as source is blank
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
count if sourcename==. //4 - one corrected, awaiting email reply from KWG/SAF re 20141529, 20145093 & 20145099
//list pid nftype sourcename dxyr cr5id if sourcename==.

** Check 129 - invalid(sourcename)

** sourcecheckcat 1: SourceName invalid length
count if sourcecheckcat==1 //0
//list pid cr5id sname sourcename dxyr stda if sourcecheckcat==1

** sourcecheckcat 2: SourceName!=QEH/BVH; NFType=Hospital; dxyr>2013
count if sourcecheckcat==2 //0
//list pid cr5id nftype sourcename dxyr stda if sourcecheckcat==2

** sourcecheckcat 3: SourceName=IPS-ARS; NFType!=Pathology; dxyr>2013
count if sourcecheckcat==3 //8 - all correct
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
count if sourcecheckcat==8 //2 - 4 no correction needed
//list pid cr5id nftype sourcename dxyr stda if sourcecheckcat==8
replace sourcename=3 if pid=="20150057" //1 change

************
** Doctor **
************
** NOTE 1: Patient notes only to be seen at 5 year intervals so e.g. notes seen on 2013 data then 2018 and so on;
** NOTE 2: In upcoming years of data collection (2018 dc year), more checks may be compiled based on data.

** Check 130 - Doctor missing
count if doctor=="" //3 - leave blank as source is blank
//list pid consultant doctor dxyr cr5id if doctor==""
							
** Check 132 - invalid(doctor)

** doccheckcat 1: Doctor invalid ND code
count if doccheckcat==1 //1 change
//list pid cr5id doctor dxyr stda if doccheckcat==1
replace doctor="99" if doccheckcat==1 //1 change

**********************
** Doctor's Address **
**********************
** NOTE 1: Patient notes only to be seen at 5 year intervals so e.g. notes seen on 2013 data then 2018 and so on;
** NOTE 2: In upcoming years of data collection (2018 dc year), more checks may be compiled based on data.

** Check 133 - Doctor's Address missing
count if docaddr=="" //3 - leave blank as source is blank
//list pid consultant doctor docaddr dxyr cr5id if docaddr==""
				
** Check 135 - invalid(docaddr)

** docaddrcheckcat 1: Doc Address invalid ND code
count if docaddrcheckcat==1 //1 change
//list pid cr5id doctor docaddr dxyr stda if docaddrcheckcat==1
replace docaddr="99" if docaddrcheckcat==1 //1 change


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
count if cfdx=="" //2 - leave blank as source is blank
//list pid cfdx doctor dxyr cr5id if cfdx==""
count if cfdx=="" & (nftype!=8 & nftype!=9) //2  - leave blank as source is blank
//list pid cfdx doctor dxyr cr5id if cfdx=="" & (nftype!=8 & nftype!=9)
count if cfdx=="" & (nftype!=4 & nftype!=8 & nftype!=9) //2  - leave blank as source is blank
//list pid nftype cfdx doctor dxyr cr5id if cfdx=="" & (nftype!=4 & nftype!=8 & nftype!=9)

** Check 139 - CF Dx invalid ND code
** (Checked data in main CR5 to determine invalid ND values by filtering in CR5 Browse/Edit by Source table, sorted by field, looking at all variables and scrolling through entire field column.)
count if cfdx=="Not Stated"|cfdx=="9" //0
//list pid cfdx dxyr cr5id if cfdx=="Not Stated"|cfdx=="9"
replace cfdx="99" if pid=="20160018" & cr5id=="T1S1" //1 change

** No more checks as difficult to perform standardized checks on this field as sometimes it has topographic info and sometimes has morphologic info so
** no consistency to perform a set of checks
** See visual lists in 'Specimen' category below

****************
** Lab Number **
****************

** Check 140 - Lab # missing / Lab # missing if nftype=Lab~
count if labnum=="" //714
//list pid nftype labnum dxyr cr5id if labnum==""
count if labnum=="" & (nftype>2 & nftype<6) //3
//list pid nftype labnum dxyr cr5id if labnum=="" & (nftype>2 & nftype<6)
replace labnum="99" if labnum=="" & (nftype>2 & nftype<6) //3 changes

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
count if specimen=="" //719
//list pid nftype specimen dxyr cr5id if specimen==""
count if specimen=="" & (nftype>2 & nftype<6) //8
//list pid nftype specimen dxyr cr5id if specimen=="" & (nftype>2 & nftype<6)
replace specimen="99" if specimen=="" & (nftype>2 & nftype<6) //8 changes

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
count if rptcheckcat==3 //19
//list pid cr5id nftype sampledate recvdate rptdate dxyr stda if rptcheckcat==3
replace rptdate=d(01jan2000) if rptcheckcat==3 //19 changes

** rptcheckcat 4: sampledate after recvdate
count if rptcheckcat==4 //1
//list pid cr5id sampledate recvdate rptdate dxyr stda if rptcheckcat==4
replace sampledate=d(01jan2000) if rptcheckcat==4 //1 change

** rptcheckcat 5: sampledate after rptdate
count if rptcheckcat==5 //5 - all sample dates are missing so use missing date value
//list pid cr5id sampledate recvdate rptdate dxyr stda if rptcheckcat==5
//list pid cr5id sampledate if rptcheckcat==5
replace sampledate=d(01jan2000) if rptcheckcat==5 //5 changes

** rptcheckcat 6: recvdate after rptdate
count if rptcheckcat==6 //0
//list pid cr5id sampledate recvdate rptdate dxyr stda if rptcheckcat==6

** rptcheckcat 7: sampledate before InciD
count if rptcheckcat==7 //0
//list pid cr5id dot sampledate recvdate rptdate dxyr stda if rptcheckcat==7

** rptcheckcat 8: recvdate before InciD
count if rptcheckcat==8 //4 - leave 20155071 as is since not confirmed
//list pid cr5id dot sampledate recvdate rptdate dxyr stda if rptcheckcat==8
replace dot=d(17apr2015) if pid=="20151093" //4 changes
replace dot=d(13aug2015) if pid=="20151277" //2 changes
replace dot=d(25may2015) if pid=="20151319" //2 changes

** rptcheckcat 9: rptdate before InciD
count if rptcheckcat==9 //11
//list pid cr5id dot sampledate recvdate rptdate dxyr stda if rptcheckcat==9
replace dot=d(15mar2015) if pid=="20150006" //2 changes
replace sampledate=d(15mar2015) if pid=="20150006" & cr5id=="T1S2" //1 change
replace rptdate=d(16mar2015) if pid=="20150006" & cr5id=="T1S2" //1 change
replace dot=d(06may2015) if pid=="20151169" //3 changes
replace dot=d(22jul2015) if pid=="20151252" //4 changes
replace dot=d(01oct2015) if pid=="20151309" //2 changes
replace dot=d(30may2015) if pid=="20151318" //2 changes
replace dot=d(25mar2015) if pid=="20151325" //2 changes
replace dot=d(22jul2015) if pid=="20151372" //3 changes

** rptcheckcat 10: sampledate after DLC
count if rptcheckcat==10 //3
//list pid cr5id dlc sampledate recvdate rptdate dxyr stda if rptcheckcat==10
replace dlc=d(13oct2015) if pid=="20150021" //3 changes
replace dlc=d(20dec2018) if pid=="20150164" //3 changes
replace dlc=d(24aug2018) if pid=="20155069" //4 changes

** rptcheckcat 11: sampledate!=. & nftype!=lab~ & labnum=. (to filter out autopsies with hx)
count if rptcheckcat==11 //1 - correct no hx seen
//list pid cr5id nftype sampledate dxyr stda if rptcheckcat==11

** rptcheckcat 12: recvdate!=. & nftype!=lab~ & labnum=. (to filter out autopsies with hx)
count if rptcheckcat==12 //0
//list pid cr5id nftype recvdate dxyr stda if rptcheckcat==12

** rptcheckcat 13: rptdate!=. & nftype!=lab~ & labnum=. (to filter out autopsies with hx)
count if rptcheckcat==13 //1 - correct no hx seen
//list pid cr5id nftype rptdate dxyr stda if rptcheckcat==13


**********************
** Clinical Details **
**********************
** Check 149 - Clinical Details missing / Clinical Details missing if nftype=Lab~
count if clindets=="" //728
//list pid nftype clindets dxyr cr5id if clindets==""
count if clindets=="" & (nftype>2 & nftype<6) //16
//list pid nftype clindets dxyr cr5id if clindets=="" & (nftype>2 & nftype<6)
replace clindets="99" if clindets=="" & (nftype>2 & nftype<6) //16 changes

** Check 150 - Clinical Details invalid ND code
** (Checked data in main CR5 to determine invalid ND values by filtering in CR5 Browse/Edit by Source table, sorted by field, looking at all variables and scrolling through entire field column.)
count if clindets=="Not Stated"|clindets=="NIL"|regexm(clindets, "NONE")|clindets=="9" //5
//list pid clindets dxyr cr5id if clindets=="Not Stated"|clindets=="NIL"|regexm(clindets, "NONE")|clindets=="9"
replace clindets="99" if clindets=="Not Stated"|clindets=="NIL"|regexm(clindets, "NONE")|clindets=="9" //5 changes


**************************
** Cytological Findings **
**************************
** Check 151 - Cytological Findings missing / Cytological Findings missing if nftype=Lab-Cyto
count if cytofinds=="" //1767
count if cytofinds=="" & (nftype>2 & nftype<6) //1049
count if cytofinds=="" & nftype==4 //4
//list pid nftype cytofinds dxyr cr5id if cytofinds=="" & nftype==4
replace cytofinds="99" if cytofinds=="" & nftype==4 //4 changes

** Check 152 - Cytological Findings invalid ND code
** (Checked data in main CR5 to determine invalid ND values by filtering in CR5 Browse/Edit by Source table, sorted by field, looking at all variables and scrolling through entire field column.)
count if cytofinds=="Not Stated"|cytofinds=="9" //0
//list pid cytofinds dxyr cr5id if cytofinds=="Not Stated"|cytofinds=="9"


*****************************
** Microscopic Description **
*****************************
** Check 153 - MD missing / MD missing if nftype=Lab~
count if md=="" //788
count if md=="" & (nftype>2 & nftype<6) //78
count if md=="" & (nftype==3|nftype==5) //11
//list pid nftype md dxyr cr5id if md=="" & (nftype==3|nftype==5)
replace md="99" if  md=="" & (nftype==3|nftype==5) //11 changes

** Check 154 - MD invalid ND code
** (Checked data in main CR5 to determine invalid ND values by filtering in CR5 Browse/Edit by Source table, sorted by field, looking at all variables and scrolling through entire field column.)
count if md=="Not Stated."|md=="Not Stated"|md=="9" //0
//list pid md dxyr cr5id if md=="Not Stated."|md=="Not Stated"|md=="9"


*************************
** Consultation Report **
*************************
** NOTE 1: Met with SAF and KWG on 22may18 and decision made to remove checks for this variable; also removed checkflags from excel export code below.

** Check 155 - Consult.Rpt missing / Consult.Rpt missing if nftype=Lab~
count if consrpt=="" & (nftype==3|nftype==5) //816
//list pid nftype consrpt dxyr cr5id if consrpt=="" & (nftype==3|nftype==5)
replace consrpt="99" if consrpt=="" & (nftype==3|nftype==5) //816

** Check 156 - Consult.Rpt invalid ND code
** (Checked data in main CR5 to determine invalid ND values by filtering in CR5 Browse/Edit by Source table, sorted by field, looking at all variables and scrolling through entire field column.)
count if consrpt=="Not Stated"|consrpt=="Not Stated."|consrpt=="9" //2
//list pid consrpt dxyr cr5id if consrpt=="Not Stated"|consrpt=="Not Stated."|consrpt=="9"
replace consrpt="99" if consrpt=="Not Stated"|consrpt=="Not Stated."|consrpt=="9" //2 changes


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
count if (cr5cod!="" & cr5cod!="99") & dxyr==2015 //409
//list pid cr5id cr5cod if (cr5cod!="" & cr5cod!="99") & dxyr==2015
//list cr5cod if (cr5cod!="" & cr5cod!="99") & dxyr==2015

** Check 157b - COD missing / COD missing if nftype=Death~
count if cr5cod=="" //1448
//list pid nftype cr5cod dxyr cr5id if cr5cod==""
count if cr5cod=="" & (nftype==8|nftype==9) //8 - 7 are PMs
//list pid nftype cr5cod dxyr cr5id if cr5cod=="" & (nftype==8|nftype==9)
replace cr5cod=duration if pid=="20155175" //1 change
replace duration="" if pid=="20155175" //1 change

** Check 158 - COD invalid ND code
** (Checked data in main CR5 to determine invalid ND values by filtering in CR5 Browse/Edit by Source table, sorted by field, looking at all variables and scrolling through entire field column.)
count if regexm(cr5cod, "Not")|regexm(cr5cod, "not")|cr5cod=="NIL."|cr5cod=="Not Stated"|cr5cod=="9" //0
//list pid cr5cod dxyr cr5id if regexm(cr5cod, "Not")|regexm(cr5cod, "not")|cr5cod=="NIL."|cr5cod=="Not Stated"|cr5cod=="9"

** Check 159 - COD invalid entry(lowercase)
count if cr5cod!="99" & cr5cod!="" & regexm(cr5cod, "[a-z]") //133
//list pid cr5cod dxyr cr5id if cr5cod!="99" & cr5cod!="" & regexm(cr5cod, "[a-z]")
replace cr5cod=upper(cr5cod) if cr5cod!="99" & cr5cod!="" & regexm(cr5cod, "[a-z]") //133 changes


*************************
** Duration of Illness **
*************************
** Check 160 - Duration of Illness missing / Duration of Illness missing if nftype=Death~
count if duration=="" & nftype==8 //239 - 06nov18 SAF (by email) indicated to run code only on death certificates and not QEH death bks so removed 'nftype==9' from code.
//list pid nftype duration onsetint dxyr cr5id if duration=="" & nftype==8
replace duration="99" if duration=="" & nftype==8 //239 changes

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
count if onsetint=="" & nftype==8 //239 - 06nov18 SAF (by email) indicated to run code only on death certificates and not QEH death bks so removed 'nftype==9' from code.
//list pid nftype onsetint dxyr cr5id if onsetint=="" & nftype==8
replace onsetint="99" if onsetint=="" & nftype==8 //239 changes

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
count if certifier=="" & (nftype==8|nftype==9) //233
//list pid nftype certifier dxyr cr5id if certifier=="" & (nftype==8|nftype==9)
replace certifier="99" if certifier=="" & (nftype==8|nftype==9) //233 changes

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
count if datescheckcat==1 //1034 - leave as is since SAF/KWG to decide if to collect missing dates
//list pid cr5id sourcename nftype admdate dfc rtdate dxyr stda if datescheckcat==1

** datescheckcat 2: DFC missing
count if datescheckcat==2 //406 - leave as is since SAF/KWG to decide if to collect missing dates
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

** Remove 2 tumours (20150310-T2; 20150385-T1) as these and their sources are blank
drop if pid=="20150310" & regexm(cr5id, "T2")
drop if pid=="20150385" & regexm(cr5id, "T1")
replace cr5id="T1S1" if pid=="20150385" & cr5id=="T2S1"
replace cr5id="T1S2" if pid=="20150385" & cr5id=="T2S2"
replace cr5id="T1S3" if pid=="20150385" & cr5id=="T2S3"
replace cr5id="T1S4" if pid=="20150385" & cr5id=="T2S4"

** Identify duplicate pids to assist with death matching
duplicates tag pid, gen(dup_pid)
count if dup_pid>0 //1627
count if dup_pid==0 //408
//list pid cr5id dup_pid if dup_pid>0, nolabel sepby(pid)
//list pid cr5id dup_pid if dup_pid==0, nolabel sepby(pid)

sort pid
quietly by pid :  gen duppid = cond(_N==1,0,_n)
count if duppid==0
count if duppid>0

label data "BNR-C data 2015 prematch"
notes _dta :These data prepared from CanReg5 CLEAN (2015BNR-C) database
save "`datapath'\version02\2-working\2015_cancer_dups_prematch" ,replace
note: TS This dataset can be used for matching 2015-2018 deaths with incidence data
note: TS This dataset can be used for assessing number of sources per record

********************
** Death Matching **
********************
use "`datapath'\version02\2-working\2015_cancer_dups_prematch", clear

count if slc==2 //1017
gen match=1 if slc==2
label define match_lab 1 "Yes" 2 "No" , modify
label values match match_lab
gen dod=dlc if slc==2
format dod %tdCCYY-NN-DD
replace natregno=subinstr(natregno,"-","",.) if regexm(natregno,"-")
count if natregno!="" & natregno!="." & length(natregno)!=10 //0

/* frames won't work unless each obs in current frame cancer links wiht one obs in deaths frame
frame rename default cancer
frame create deaths
frame change deaths
use "`datapath'\version02\3-output\2015-2018_deaths_for_matching", clear
frame change cancer
frame put pid fname lname natregno slc dlc dod, into(deaths)

frlink m:1 fname lname sex natregno, frame(deaths)
gen ddmatch=frval(deaths,natregno)=frval(cancer,natregno)
*/

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
replace fname = lower(rtrim(ltrim(itrim(fname)))) //2035 changes
replace lname = lower(rtrim(ltrim(itrim(lname)))) //2035 changes

count //2035

merge m:m lname fname sex using "`datapath'\version02\3-output\2015-2018_deaths_for_matching"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                        10,563
        from master                     1,023  (_merge==1)
        from using                      9,540  (_merge==2)

    matched                             1,024  (_merge==3)
    -----------------------------------------
*/

count //11587

sort lname fname record_id pid
quietly by lname fname :  gen duppt = cond(_N==1,0,_n)
sort lname fname
count if duppt>0 //2198
count if duppt>0 & duppid<2 //671
count if duppt>0 & duppid<2 & slc!=2 //314
count if duppt>0 & _merge==3 //919
count if slc!=2 & _merge==3 //84
sort lname fname pid
order pid fname lname natregno sex age primarysite dds2coddeath
//list pid record_id fname lname age dds2age natregno dds2natregno addr dds2address slc if slc!=2 & _merge==3, string(20)

** Remove death data from records where pt doesn't match but still had merged
replace _merge=4 if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace match=2 if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2regnum=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace nrn=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2pname="" if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2age=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2dod=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2cancer=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2cod1a="" if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2address="" if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2parish=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2pod="" if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2mname="" if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2namematch=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2event=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2dddoa=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2ddda=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2odda="" if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2certtype=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2district=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2agetxt=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2nrnnd=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2mstatus=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2occu="" if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2durationnum=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2durationtxt=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2onsetnumcod1a=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2onsettxtcod1a=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2cod1b="" if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2onsetnumcod1b=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2onsettxtcod1b=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2cod1c="" if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2onsetnumcod1c=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2onsettxtcod1c=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2cod1d="" if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2onsetnumcod1d=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2onsettxtcod1d=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2cod2a="" if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2onsetnumcod2a=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2onsettxtcod2a=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2cod2b="" if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2onsetnumcod2b=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2onsettxtcod2b=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2deathparish=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2regdate=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2certifier="" if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2certifieraddr="" if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace recstatdc=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace tfdddoa=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace tfddda=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace tfregnumstart=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace tfdistrictstart="" if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace tfregnumend=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace tfdistrictend="" if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace tfddtxt="" if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace recstattf=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2duprec=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2dupname=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2dupdod=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace cod=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2natregno="" if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace nrnyear=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace placeofdeath="" if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace checkage2=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dodyear=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
replace dds2coddeath="" if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
/*
replace record_id=. if record_id==26890|record_id==19718|record_id==21276|record_id==19328|record_id==23267|record_id==21309|record_id==17732|record_id==25688|record_id==19870|record_id==20095|record_id==26048|record_id==18593|record_id==23565|record_id==21664|record_id==18590|record_id==23910|record_id==22616|record_id==21142|record_id==26367|record_id==22039|record_id==20140|record_id==23351|record_id==24616|record_id==21322|record_id==21651|record_id==22987|record_id==25222|record_id==25310|record_id==18207|record_id==23414
*/
sort pid lname fname
count if natregno!=dds2natregno & _merge==3 //95
//list pid record_id fname lname age dds2age natregno dds2natregno addr dds2address slc if natregno!=dds2natregno & _merge==3, string(20)
//replace dds2natregno=subinstr(dds2natregno,"001","601",.) if pid=="20141434" //keep death data nrn as is although it's an error
//replace dds2natregno=subinstr(dds2natregno,"23","03",.) if pid=="20150020" //keep death data nrn as is although it's an error
//replace dds2natregno=subinstr(dds2natregno,"23","03",.) if pid=="20150187" //keep death data nrn as is although it's an error

replace _merge=5 if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace match=2 if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2regnum=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace nrn=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2pname="" if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2age=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2dod=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2cancer=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2cod1a="" if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2address="" if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2parish=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2pod="" if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2mname="" if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2namematch=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2event=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2dddoa=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2ddda=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2odda="" if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2certtype=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2district=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2agetxt=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2nrnnd=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2mstatus=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2occu="" if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2durationnum=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2durationtxt=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2onsetnumcod1a=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2onsettxtcod1a=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2cod1b="" if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2onsetnumcod1b=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2onsettxtcod1b=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2cod1c="" if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2onsetnumcod1c=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2onsettxtcod1c=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2cod1d="" if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2onsetnumcod1d=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2onsettxtcod1d=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2cod2a="" if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2onsetnumcod2a=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2onsettxtcod2a=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2cod2b="" if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2onsetnumcod2b=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2onsettxtcod2b=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2deathparish=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2regdate=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2certifier="" if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2certifieraddr="" if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace recstatdc=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace tfdddoa=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace tfddda=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace tfregnumstart=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace tfdistrictstart="" if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace tfregnumend=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace tfdistrictend="" if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace tfddtxt="" if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace recstattf=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2duprec=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2dupname=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2dupdod=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace cod=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2natregno="" if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace nrnyear=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace placeofdeath="" if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace checkage2=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dodyear=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace dds2coddeath="" if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594
replace record_id=. if pid=="20150188" & record_id==21780|pid=="20150210" & record_id==21994|pid=="20150468" & record_id==19322|pid=="20150481" & (record_id==21376|record_id==26256)|pid=="20150562" & record_id==22983|pid=="20151044" & record_id==26640|pid=="20151054" & record_id==22394|pid=="20151127" & (record_id==18323|record_id==19255)|pid=="20151141" & record_id==20614|pid=="20151151"|pid=="20151180" & record_id==21261|pid=="20151189" & record_id==19223|pid=="20151191" & record_id==24858|pid=="20151253" & record_id==23753|pid=="20151315" & record_id==23655|pid=="20151372" & record_id==19097|pid=="20155016" & record_id==26156|pid=="20155072" & record_id==18793|pid=="20155094" & (record_id==25061|record_id==24287)|pid=="20155142" & (record_id==19461|record_id==19125|record_id==25789|record_id==19415)|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & (record_id==26300|record_id==22825)|pid=="20155204" & record_id==25698|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594

** Update death data for records where pt correctly matched
replace dod=dds2dod if slc!=2 & _merge==3 //41 changes
replace slc=2 if slc!=2 & _merge==3 //41 changes
replace addr=dds2address if pid=="20151151" //1 change

** Check for matches by natregno and pt names
sort natregno lname fname pid
quietly by natregno :  gen dupnrn = cond(_N==1,0,_n)
sort natregno
count if dupnrn>0 //11211
sort lname fname pid record_id
order pid record_id fname lname sex age natregno dds2natregno
count if dupnrn>0 & natregno!="" & natregno!="9999999999" & natregno!=dds2natregno & _merge!=3 //770 - no matches (used data editor and filtered)
//list pid record_id fname lname age dds2age natregno dds2natregno addr dds2address slc if dupnrn>0 & natregno!="" & natregno!="9999999999" & _merge!=3, string(38)

drop duppt
sort lname fname record_id pid
quietly by lname fname :  gen duppt = cond(_N==1,0,_n)
sort lname fname
count if duppt>0 //2198
sort lname fname pid record_id
count if duppt>0 & _merge!=3 //1313 - no matches (used data editor and filtered)

** Remove & change certain death variables
drop tfdddoa tfddda tfregnumstart tfdistrictstart tfregnumend tfdistrictend tfddtxt recstattf nrnyear checkage2
rename dds2cancer cancer
rename dds2* dd_*

** Check for eligible deaths that were not in CR5db
count if cancer==1 & dodyear==2015 & _merge==2 //416 - cancer death certificates not in CR5db
count if recstatus==3 //121 - inelgibles from CR5db
** Check if any of the above match each other
preserve
keep record_id fname lname sex dd_age dd_natregno dd_address dd_coddeath dd_certifier placeofdeath cancer dd_dod dodyear _merge
drop if cancer!=1 | dodyear!=2015 | _merge!=2
count if cancer==1 & dodyear==2015 & _merge==2
count //416
rename dd_natregno natregno
drop _merge
label data "2015 unmatched death certificates"
save "`datapath'\version02\2-working\2015_unmatched death certificates" ,replace
restore

preserve
keep pid fname lname sex age natregno addr primarysite cr5cod recstatus
drop if recstatus!=3
count //121
label data "2015 inelgible CR5 cancers"
save "`datapath'\version02\2-working\2015_ineligible cancers" ,replace
restore

preserve
use "`datapath'\version02\2-working\2015_ineligible cancers" ,clear
merge m:m natregno using "`datapath'\version02\2-working\2015_unmatched death certificates"
sort lname fname record_id pid
quietly by lname fname :  gen duppt = cond(_N==1,0,_n)
sort lname fname
count if duppt>0 //2198
sort lname fname pid record_id
//list pid record_id fname lname natregno if duppt>0 //only CR5 records
restore
** Check all unmatched death certificates against MAIN CR5db cancers to see if captured in previous cancer data collection year
preserve
clear
import excel using "`datapath'\version02\1-input\2020-02-18_Exported Source+Tumour+Patient_JC_MAIN_excel.xlsx", firstrow
count //12,470

nsplit IncidenceDate, digits(4 2 2) gen(dotyear dotmonth dotday)
gen dot=mdy(dotmonth, dotday, dotyear)
format dot %dD_m_CY
gen dotyear2 = year(dot)
label var dot "IncidenceDate"
label var dotyear "Incidence year"
drop IncidenceDate

rename Sex sex
rename FirstName fname
rename LastName lname
rename NRN natregno
rename RegistryNumber pid
rename Recordstatus recstatus
rename Address addr
rename Age age
rename PrimarySite primarysite
rename CausesOfDeath cr5cod
rename DiagnosisYear dxyr

replace fname = lower(rtrim(ltrim(itrim(fname))))
replace lname = lower(rtrim(ltrim(itrim(lname))))
drop dotyear
gen dotyear=year(dot)
//replace dotyear=year(dot) if dotyear==. & dot!=.
keep pid fname lname sex age natregno addr primarysite cr5cod recstatus dot dxyr dotyear2
replace natregno=subinstr(natregno,"-","",.) if regexm(natregno,"-")

** remove duplicate records i.e. pid>1
sort pid
quietly by pid :  gen duppid_main = cond(_N==1,0,_n)
count if duppid_main>0 //7727
//list pid duppid_main if duppid_main>0
count if recstatus==4 & duppid_main<2

replace cr5cod="" if cr5cod=="99" //3171 changes
replace age=. if age==-1 // changes
bysort pid : replace cr5cod = cr5cod[_n-1] if cr5cod==""
bysort pid : replace cr5cod = cr5cod[_n+1] if cr5cod==""
bysort pid : replace cr5cod = cr5cod[_n+2] if cr5cod==""
bysort pid : replace cr5cod = cr5cod[_n+3] if cr5cod==""
bysort pid : replace addr = addr[_n-1] if addr==""
bysort pid : replace addr = addr[_n+1] if addr==""
bysort pid : replace addr = addr[_n+2] if addr==""
bysort pid : replace addr = addr[_n+3] if addr==""
bysort pid : replace age = age[_n-1] if age==.
bysort pid : replace age = age[_n+1] if age==.
bysort pid : replace age = age[_n+2] if age==.
bysort pid : replace age = age[_n+3] if age==.
bysort pid : replace primarysite = primarysite[_n-1] if primarysite==""
bysort pid : replace primarysite = primarysite[_n+1] if primarysite==""
bysort pid : replace primarysite = primarysite[_n+2] if primarysite==""
bysort pid : replace primarysite = primarysite[_n+3] if primarysite==""
bysort pid : replace dot = dot[_n-1] if dot==.
bysort pid : replace dot = dot[_n+1] if dot==.
bysort pid : replace dot = dot[_n+2] if dot==.
bysort pid : replace dot = dot[_n+3] if dot==.
bysort pid : replace dotyear = dotyear[_n-1] if dotyear==.
bysort pid : replace dotyear = dotyear[_n+1] if dotyear==.
bysort pid : replace dotyear = dotyear[_n+2] if dotyear==.
bysort pid : replace dotyear = dotyear[_n+3] if dotyear==.

order pid fname lname natregno sex age
drop if duppid_main>1 //4647
count //7823
label data "MAIN CR5db data"
save "`datapath'\version02\2-working\MAIN CR5db" ,replace

merge m:m natregno using "`datapath'\version02\2-working\2015_unmatched death certificates"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         7,757
        from master                     7,579  (_merge==1)
        from using                        178  (_merge==2)

    matched                               244  (_merge==3)
    -----------------------------------------
*/
order pid record_id fname lname natregno sex age dotyear dodyear

sort lname fname record_id pid
quietly by lname fname :  gen duppt = cond(_N==1,0,_n)
sort lname fname
count if duppt>0 //533
sort lname fname pid record_id
//list pid record_id fname lname natregno dotyear dodyear if duppt>0 //only CR5 records
gen cr5db=1 if record_id==17446|record_id==18012|record_id==19201|record_id==18896|record_id==17648|record_id==17755|record_id==17136|record_id==17042|record_id==18008|record_id==17563|record_id==18188|record_id==16910|record_id==18754|record_id==18075|record_id==16808|record_id==17424|record_id==19185|record_id==18195|record_id==17476|record_id==19289|record_id==19188|record_id==18686|record_id==17854|record_id==16956|record_id==18106|record_id==18064
label var cr5db "Unmatched death certificate found in MAIN CR5db"
label define cr5db_lab 1 "matched" 2 "unmatched", modify
label values cr5db cr5db_lab
replace cr5db=1 if cr5db==. & _merge==3 //231 changes

label data "Matched death certificates and MAIN CR5db data"
save "`datapath'\version02\2-working\matched deaths and MAIN cr5" ,replace

keep record_id cr5db 
drop if cr5db!=1 //7742 deleted
/*
drop if record_id!=17446 & record_id!=18012 & record_id!=19201 & record_id!=18896 & record_id!=17648 & record_id!=17755 & record_id!=17136 & record_id!=17042 & record_id!=18008 & record_id!=17563 & record_id!=18188 & record_id!=16910 & record_id!=18754 & record_id!=18075 & record_id!=16808 & record_id!=17424 & record_id!=19185 & record_id!=18195 & record_id!=17476 & record_id!=19289 & record_id!=19188 & record_id!=18686 & record_id!=17854 & record_id!=16956 & record_id!=18106 & record_id!=18064
*/
count //259

label data "Matched death certificates found in MAIN CR5db"
save "`datapath'\version02\2-working\MAIN CR5db_matched death certificates" ,replace
restore

** Check all unmatched death certificates with cancer CODs
rename _merge _merge_org
merge m:m record_id using "`datapath'\version02\2-working\MAIN CR5db_matched death certificates"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                        11,561
        from master                    11,561  (_merge==1)
        from using                          0  (_merge==2)

    matched                                28  (_merge==3)
    -----------------------------------------
*/
sort record_id lname fname
count if cancer==1 & dodyear==2015 & _merge_org==2 & cr5db!=1 //163 - cancer death certificates not in MAIN CR5db
//list record_id fname lname dd_natregno dd_dod dd_coddeath if cancer==1 & dodyear==2015 & _merge_org==2 & cr5db!=1 ,string(80)
preserve
keep if cancer==1 & dodyear==2015 & _merge_org==2 & cr5db!=1
count //163
save "`datapath'\version02\2-working\2015_death certificates_DCOs" ,replace
restore

preserve
format dd_dod %dD_m_CY
rename dd_natregno nationalID
rename dd_dod deathdate
rename dd_coddeath cods
rename dd_regnum regnum
rename dd_district district
capture export_excel record_id fname lname nationalID deathdate cods dd_certifier placeofdeath regnum district if cancer==1 & dodyear==2015 & _merge_org==2 & cr5db!=1 using "`datapath'\version02\2-working\DCO2015V04.xlsx", sheet("2015 DCOs_deathdata_20200218") firstrow(variables) replace
//JC remember to change V01 to V02 when running list a 2nd time!
restore
**stop - cancer team needs to check these 163 DCOs before continuing with cleaning and analysis
** Then for those pt notes that cannot be found - assign a pid then abstract then check for MP in CODs and expand obs!

** Remove unmatched death data
//drop if _merge==2 //9540
** 31aug20 JC: update for traced-back + true DCOs
drop if pid=="" & (record_id!=16819 & record_id!=16823 & record_id!=16852 & record_id!=16887 & record_id!=16888 ///
		& record_id!=16893 & record_id!=16909 & record_id!=16914 & record_id!=16936 & record_id!=16984 & record_id!=17000 ///
		& record_id!=17024 & record_id!=17029 & record_id!=17046 & record_id!=17069 & record_id!=17099 & record_id!=17101 ///
		& record_id!=17124 & record_id!=17134 & record_id!=17244 & record_id!=17281 & record_id!=17282 & record_id!=17297 ///
		& record_id!=17310 & record_id!=17311 & record_id!=17333 & record_id!=17336 & record_id!=17375 & record_id!=17385 ///
		& record_id!=17461 & record_id!=17473 & record_id!=17477 & record_id!=17489 & record_id!=17503 ///
		& record_id!=17505 & record_id!=17524 & record_id!=17564 & record_id!=17591 & record_id!=17607 & record_id!=17617 ///
		& record_id!=17635 & record_id!=17640 & record_id!=17644 & record_id!=17654 & record_id!=17663 & record_id!=17678 ///
		& record_id!=17699 & record_id!=17714 & record_id!=17728 & record_id!=17729 & record_id!=17741 & record_id!=17761 ///
		& record_id!=17789 & record_id!=17804 & record_id!=17809 & record_id!=17829 & record_id!=17842 ///
		& record_id!=17846 & record_id!=17848 & record_id!=17865 & record_id!=17868 & record_id!=17886 & record_id!=17891 ///
		& record_id!=17894 & record_id!=17915 & record_id!=17930 & record_id!=17942 & record_id!=17945 ///
		& record_id!=17948 & record_id!=17966 & record_id!=17973 & record_id!=17998 & record_id!=17999 ///
		& record_id!=18014 & record_id!=18059 & record_id!=18063 & record_id!=18089 & record_id!=18094 & record_id!=18109 ///
		& record_id!=18116 & record_id!=18119 & record_id!=18129 & record_id!=18132 & record_id!=18149 & record_id!=18172 ///
		& record_id!=18183 & record_id!=18203 & record_id!=18225 & record_id!=18238 & record_id!=18267 & record_id!=18270 ///
		& record_id!=18272 & record_id!=18299 & record_id!=18304 & record_id!=18341 & record_id!=18342 ///
		& record_id!=18375 & record_id!=18381 & record_id!=18399 & record_id!=18451 & record_id!=18468 & record_id!=18472 ///
		& record_id!=18476 & record_id!=18482 & record_id!=18557 & record_id!=18562 & record_id!=18567 & record_id!=18571 ///
		& record_id!=18585 & record_id!=18596 & record_id!=18619 & record_id!=18650 & record_id!=18693 & record_id!=18700 ///
		& record_id!=18707 & record_id!=18710 & record_id!=18730 & record_id!=18744 & record_id!=18746 & record_id!=18801 ///
		& record_id!=18805 & record_id!=18818 & record_id!=18834 & record_id!=18835 & record_id!=18849 & record_id!=18854 ///
		& record_id!=18863 & record_id!=18892 & record_id!=18943 & record_id!=18945 ///
		& record_id!=18950 & record_id!=18963 & record_id!=18987 & record_id!=18989 & record_id!=19018 & record_id!=19023 ///
		& record_id!=19062 & record_id!=19077 & record_id!=19107 & record_id!=19135 & record_id!=19149 & record_id!=19210 ///
		& record_id!=19230 & record_id!=19245 & record_id!=19246 & record_id!=19256 & record_id!=19278)
//9.393 deleted
//record_id 17432, 17989 - ineligible COD so dropped

count //2047 - merge duplicated obs when >1 death record matched cancer record

** Create dataset so you don't have to run entire dofile each time
save "`datapath'\version02\2-working\2015_DCOs" ,replace
clear
use "`datapath'\version02\2-working\2015_DCOs" ,clear

** Update traced-back + true DCOs from death data above
replace natregno=dd_natregno if natregno=="" & dd_natregno!=""
replace age=dd_age if age==. & dd_age!=.
replace slc=2 if pid==""
replace dlc=dd_dod if pid==""
replace dod=dd_dod if pid==""
replace recstatus=1 if pid==""
replace resident=1 if pid==""
replace parish=dd_parish if pid==""
replace mpseq=0 if pid==""
replace mptot=1 if pid==""
replace addr=dd_address if pid==""
replace staging=8 if pid==""
replace cr5id="T1S1" if pid==""

replace pid="20159000" if record_id==16819
replace pid="20159001" if record_id==16823
replace pid="20159002" if record_id==16852
replace pid="20159003" if record_id==16887
replace pid="20159004" if record_id==16888
replace pid="20159005" if record_id==16893
replace pid="20159006" if record_id==16909
replace pid="20159007" if record_id==16914
replace pid="20159008" if record_id==16936
replace pid="20159009" if record_id==16984
replace pid="20159010" if record_id==17000
replace pid="20159011" if record_id==17024
replace pid="20159012" if record_id==17029
replace pid="20159013" if record_id==17046
replace pid="20159014" if record_id==17069
replace pid="20159015" if record_id==17099
replace pid="20159016" if record_id==17101
replace pid="20159017" if record_id==17124
replace pid="20159018" if record_id==17134
replace pid="20159019" if record_id==17244
replace pid="20159020" if record_id==17281
replace pid="20159021" if record_id==17282
replace pid="20159022" if record_id==17297
replace pid="20159023" if record_id==17310
replace pid="20159024" if record_id==17311
replace pid="20159025" if record_id==17333
replace pid="20159026" if record_id==17336
replace pid="20159027" if record_id==17375
replace pid="20159028" if record_id==17385
replace pid="20159029" if record_id==17461
replace pid="20159030" if record_id==17473
replace pid="20159031" if record_id==17477
replace pid="20159032" if record_id==17489
replace pid="20159033" if record_id==17503
replace pid="20159034" if record_id==17505
replace pid="20159035" if record_id==17524
replace pid="20159036" if record_id==17564
replace pid="20159037" if record_id==17591
replace pid="20159038" if record_id==17607
replace pid="20159039" if record_id==17617
replace pid="20159040" if record_id==17635
replace pid="20159041" if record_id==17640
replace pid="20159042" if record_id==17644
replace pid="20159043" if record_id==17654
replace pid="20159044" if record_id==17663
replace pid="20159045" if record_id==17678
replace pid="20159046" if record_id==17699
replace pid="20159047" if record_id==17714
replace pid="20159048" if record_id==17728
replace pid="20159049" if record_id==17729
replace pid="20159050" if record_id==17741
replace pid="20159051" if record_id==17761
//replace pid="20159052" if record_id==17778
replace pid="20159053" if record_id==17789
replace pid="20159054" if record_id==17804
replace pid="20159055" if record_id==17809
replace pid="20159056" if record_id==17829
replace pid="20159057" if record_id==17842
replace pid="20159058" if record_id==17846
replace pid="20159059" if record_id==17848
replace pid="20159060" if record_id==17865
replace pid="20159061" if record_id==17868
replace pid="20159062" if record_id==17886
replace pid="20159063" if record_id==17891
replace pid="20159064" if record_id==17894
replace pid="20159065" if record_id==17915
//replace pid="20159066" if record_id==17916
replace pid="20159067" if record_id==17930
replace pid="20159068" if record_id==17942
replace pid="20159069" if record_id==17945
replace pid="20159070" if record_id==17948
replace pid="20159071" if record_id==17966
replace pid="20159072" if record_id==17973
//replace pid="20159073" if record_id==17989
replace pid="20159074" if record_id==17998
replace pid="20159075" if record_id==17999
replace pid="20159076" if record_id==18014
replace pid="20159077" if record_id==18059
replace pid="20159078" if record_id==18063
replace pid="20159079" if record_id==18089
replace pid="20159080" if record_id==18094
replace pid="20159081" if record_id==18109
replace pid="20159082" if record_id==18116
replace pid="20159083" if record_id==18119
replace pid="20159084" if record_id==18129
replace pid="20159085" if record_id==18132
replace pid="20159086" if record_id==18149
replace pid="20159087" if record_id==18172
replace pid="20159088" if record_id==18183
replace pid="20159089" if record_id==18203
replace pid="20159090" if record_id==18225
replace pid="20159091" if record_id==18238
replace pid="20159092" if record_id==18267
replace pid="20159093" if record_id==18270
replace pid="20159094" if record_id==18272
replace pid="20159095" if record_id==18299
replace pid="20159096" if record_id==18304
replace pid="20159097" if record_id==18341
replace pid="20159098" if record_id==18342
//replace pid="20159099" if record_id==18357
replace pid="20159100" if record_id==18375
replace pid="20159101" if record_id==18381
replace pid="20159102" if record_id==18399
replace pid="20159103" if record_id==18451
replace pid="20159104" if record_id==18468
replace pid="20159105" if record_id==18472
replace pid="20159106" if record_id==18476
replace pid="20159107" if record_id==18482
replace pid="20159108" if record_id==18557
replace pid="20159109" if record_id==18562
replace pid="20159110" if record_id==18567
replace pid="20159111" if record_id==18571
replace pid="20159112" if record_id==18585
replace pid="20159113" if record_id==18596
replace pid="20159114" if record_id==18619
replace pid="20159115" if record_id==18650
replace pid="20159116" if record_id==18693
replace pid="20159117" if record_id==18700
replace pid="20159118" if record_id==18707
replace pid="20159119" if record_id==18710
replace pid="20159120" if record_id==18730
replace pid="20159121" if record_id==18744
replace pid="20159122" if record_id==18746
replace pid="20159123" if record_id==18801
replace pid="20159124" if record_id==18805
replace pid="20159125" if record_id==18818
replace pid="20159126" if record_id==18834
replace pid="20159127" if record_id==18835
replace pid="20159128" if record_id==18849
replace pid="20159129" if record_id==18854
//replace pid="20159130" if record_id==18861
replace pid="20159131" if record_id==18863
replace pid="20159132" if record_id==18892
//replace pid="20159133" if record_id==18893
replace pid="20159134" if record_id==18943
replace pid="20159135" if record_id==18945
replace pid="20159136" if record_id==18950
replace pid="20159137" if record_id==18963
replace pid="20159138" if record_id==18987
replace pid="20159139" if record_id==18989
replace pid="20159140" if record_id==19018
replace pid="20159141" if record_id==19023
replace pid="20159142" if record_id==19062
replace pid="20159143" if record_id==19077
replace pid="20159144" if record_id==19107
replace pid="20159145" if record_id==19135
replace pid="20159146" if record_id==19149
replace pid="20159147" if record_id==19210
replace pid="20159148" if record_id==19230
replace pid="20159149" if record_id==19245
replace pid="20159150" if record_id==19246
replace pid="20159151" if record_id==19256
replace pid="20159152" if record_id==19278

** Abstract traced-back + true DCOs
replace top="809" if record_id==16819
replace topography=809 if record_id==16819
replace topcat=70 if record_id==16819
replace primarysite="99" if record_id==16819
replace morphology="8000" if record_id==16819
replace morph=8000 if record_id==16819
replace morphcat=1 if record_id==16819
replace hx="METASTATIC CANCER" if record_id==16819
replace lat=0 if record_id==16819
replace latcat=0 if record_id==16819
replace beh=3 if record_id==16819
replace grade=9 if record_id==16819
replace basis=0 if record_id==16819
replace dot=dod if record_id==16819
replace dotyear=year(dot) if record_id==16819
replace dxyr=2015 if record_id==16819
replace ICD10="C80" if record_id==16819
replace ICCCcode="12b" if record_id==16819

replace top="259" if record_id==16823
replace topography=259 if record_id==16823
replace topcat=26 if record_id==16823
replace primarysite="PANCREAS" if record_id==16823
replace morphology="8000" if record_id==16823
replace morph=8000 if record_id==16823
replace morphcat=1 if record_id==16823
replace hx="METASTATIC PANCREATIC CARCINOMA" if record_id==16823
replace lat=0 if record_id==16823
replace latcat=0 if record_id==16823
replace beh=3 if record_id==16823
replace grade=9 if record_id==16823
replace basis=0 if record_id==16823
replace dot=dod if record_id==16823
replace dotyear=year(dot) if record_id==16823
replace dxyr=2015 if record_id==16823
replace ICD10="C259" if record_id==16823
replace ICCCcode="12b" if record_id==16823

replace top="189" if record_id==16852
replace topography=189 if record_id==16852
replace topcat=19 if record_id==16852
replace primarysite="COLON" if record_id==16852
replace morphology="8000" if record_id==16852
replace morph=8000 if record_id==16852
replace morphcat=1 if record_id==16852
replace hx="METASTATIC COLON CANCER" if record_id==16852
replace lat=0 if record_id==16852
replace latcat=0 if record_id==16852
replace beh=3 if record_id==16852
replace grade=9 if record_id==16852
replace basis=0 if record_id==16852
replace dot=dod if record_id==16852
replace dotyear=year(dot) if record_id==16852
replace dxyr=2015 if record_id==16852
replace ICD10="C189" if record_id==16852
replace ICCCcode="12b" if record_id==16852

replace top="509" if record_id==16887
replace topography=509 if record_id==16887
replace topcat=43 if record_id==16887
replace primarysite="BREAST" if record_id==16887
replace morphology="8000" if record_id==16887
replace morph=8000 if record_id==16887
replace morphcat=1 if record_id==16887
replace hx="CARCINOMA OF THE BREAST" if record_id==16887
replace lat=3 if record_id==16887
replace latcat=31 if record_id==16887
replace beh=3 if record_id==16887
replace grade=9 if record_id==16887
replace basis=0 if record_id==16887
replace dot=dod if record_id==16887
replace dotyear=year(dot) if record_id==16887
replace dxyr=2015 if record_id==16887
replace ICD10="C509" if record_id==16887
replace ICCCcode="12b" if record_id==16887

replace top="259" if record_id==16888
replace topography=259 if record_id==16888
replace topcat=26 if record_id==16888
replace primarysite="PANCREAS" if record_id==16888
replace morphology="8000" if record_id==16888
replace morph=8000 if record_id==16888
replace morphcat=1 if record_id==16888
replace hx="CARCINOMA OF THE PANCREAS" if record_id==16888
replace lat=0 if record_id==16888
replace latcat=0 if record_id==16888
replace beh=3 if record_id==16888
replace grade=9 if record_id==16888
replace basis=0 if record_id==16888
replace dot=dod if record_id==16888
replace dotyear=year(dot) if record_id==16888
replace dxyr=2015 if record_id==16888
replace ICD10="C259" if record_id==16888
replace ICCCcode="12b" if record_id==16888

replace top="349" if record_id==16893
replace topography=349 if record_id==16893
replace topcat=32 if record_id==16893
replace primarysite="LUNG" if record_id==16893
replace morphology="8000" if record_id==16893
replace morph=8000 if record_id==16893
replace morphcat=1 if record_id==16893
replace hx="METASTATIC LUNG CARCINOMA" if record_id==16893
replace lat=3 if record_id==16893
replace latcat=13 if record_id==16893
replace beh=3 if record_id==16893
replace grade=9 if record_id==16893
replace basis=0 if record_id==16893
replace dot=dod if record_id==16893
replace dotyear=year(dot) if record_id==16893
replace dxyr=2015 if record_id==16893
replace ICD10="C349" if record_id==16893
replace ICCCcode="12b" if record_id==16893

replace top="509" if record_id==16909
replace topography=509 if record_id==16909
replace topcat=43 if record_id==16909
replace primarysite="BREAST" if record_id==16909
replace morphology="8000" if record_id==16909
replace morph=8000 if record_id==16909
replace morphcat=1 if record_id==16909
replace hx="BREAST CANCER" if record_id==16909
replace lat=2 if record_id==16909
replace latcat=31 if record_id==16909
replace beh=3 if record_id==16909
replace grade=9 if record_id==16909
replace basis=0 if record_id==16909
replace dot=dod if record_id==16909
replace dotyear=year(dot) if record_id==16909
replace dxyr=2015 if record_id==16909
replace ICD10="C509" if record_id==16909
replace ICCCcode="12b" if record_id==16909

replace top="809" if record_id==16914
replace topography=809 if record_id==16914
replace topcat=70 if record_id==16914
replace primarysite="99" if record_id==16914
replace morphology="8000" if record_id==16914
replace morph=8000 if record_id==16914
replace morphcat=1 if record_id==16914
replace hx="MALIGNANCY" if record_id==16914
replace lat=0 if record_id==16914
replace latcat=0 if record_id==16914
replace beh=3 if record_id==16914
replace grade=9 if record_id==16914
replace basis=0 if record_id==16914
replace dot=dod if record_id==16914
replace dotyear=year(dot) if record_id==16914
replace dxyr=2015 if record_id==16914
replace ICD10="C80" if record_id==16914
replace ICCCcode="12b" if record_id==16914

replace top="619" if record_id==16936
replace topography=619 if record_id==16936
replace topcat=53 if record_id==16936
replace primarysite="PROSTATE" if record_id==16936
replace morphology="8000" if record_id==16936
replace morph=8000 if record_id==16936
replace morphcat=1 if record_id==16936
replace hx="PROSTATE CARCINOMA" if record_id==16936
replace lat=0 if record_id==16936
replace latcat=0 if record_id==16936
replace beh=3 if record_id==16936
replace grade=9 if record_id==16936
replace basis=0 if record_id==16936
replace dot=dod if record_id==16936
replace dotyear=year(dot) if record_id==16936
replace dxyr=2015 if record_id==16936
replace ICD10="C61" if record_id==16936
replace ICCCcode="12b" if record_id==16936

replace top="421" if record_id==16984
replace topography=421 if record_id==16984
replace topcat=38 if record_id==16984
replace primarysite="BONE MARROW" if record_id==16984
replace morphology="9732" if record_id==16984
replace morph=9732 if record_id==16984
replace morphcat=46 if record_id==16984
replace hx="MULTIPLE MYELOMA" if record_id==16984
replace lat=0 if record_id==16984
replace latcat=0 if record_id==16984
replace beh=3 if record_id==16984
replace grade=9 if record_id==16984
replace basis=0 if record_id==16984
replace dot=dod if record_id==16984
replace dotyear=year(dot) if record_id==16984
replace dxyr=2015 if record_id==16984
replace ICD10="C900" if record_id==16984
replace ICCCcode="2b" if record_id==16984

replace top="421" if record_id==17000
replace topography=421 if record_id==17000
replace topcat=38 if record_id==17000
replace primarysite="BONE MARROW" if record_id==17000
replace morphology="9989" if record_id==17000
replace morph=9989 if record_id==17000
replace morphcat=56 if record_id==17000
replace hx="MYELODYSPLASTIC SYNDROME" if record_id==17000
replace lat=0 if record_id==17000
replace latcat=0 if record_id==17000
replace beh=3 if record_id==17000
replace grade=9 if record_id==17000
replace basis=0 if record_id==17000
replace dot=d(30jun2008) if record_id==17000
replace dotyear=year(dot) if record_id==17000
replace dxyr=2008 if record_id==17000
replace ICD10="D469" if record_id==17000
replace ICCCcode="1d" if record_id==17000
replace comments="Trace back: Dx in 2008." if record_id==17000

replace top="189" if record_id==17024
replace topography=189 if record_id==17024
replace topcat=19 if record_id==17024
replace primarysite="COLON" if record_id==17024
replace morphology="8000" if record_id==17024
replace morph=8000 if record_id==17024
replace morphcat=1 if record_id==17024
replace hx="COLON CANCER" if record_id==17024
replace lat=0 if record_id==17024
replace latcat=0 if record_id==17024
replace beh=3 if record_id==17024
replace grade=9 if record_id==17024
replace basis=0 if record_id==17024
replace dot=dod if record_id==17024
replace dotyear=year(dot) if record_id==17024
replace dxyr=2015 if record_id==17024
replace ICD10="C189" if record_id==17024
replace ICCCcode="12b" if record_id==17024

replace top="239" if record_id==17029
replace topography=239 if record_id==17029
replace topcat=24 if record_id==17029
replace primarysite="GALLBLADDER" if record_id==17029
replace morphology="8000" if record_id==17029
replace morph=8000 if record_id==17029
replace morphcat=1 if record_id==17029
replace hx="GALLBLADDER CANCER" if record_id==17029
replace lat=0 if record_id==17029
replace latcat=0 if record_id==17029
replace beh=3 if record_id==17029
replace grade=9 if record_id==17029
replace basis=2 if record_id==17029
replace dot=d(15jan2015) if record_id==17029
replace dotyear=year(dot) if record_id==17029
replace dxyr=2015 if record_id==17029
replace ICD10="C23" if record_id==17029
replace ICCCcode="12b" if record_id==17029
replace comments="Trace back: Diagnosed January 2015. Clinical diagnosis- CT scan." if record_id==17029

replace top="509" if record_id==17046
replace topography=509 if record_id==17046
replace topcat=43 if record_id==17046
replace primarysite="BREAST" if record_id==17046
replace morphology="8000" if record_id==17046
replace morph=8000 if record_id==17046
replace morphcat=1 if record_id==17046
replace hx="BREAST CANCER" if record_id==17046
replace lat=3 if record_id==17046
replace latcat=31 if record_id==17046
replace beh=3 if record_id==17046
replace grade=9 if record_id==17046
replace basis=1 if record_id==17046
replace dot=dod if record_id==17046
replace dotyear=year(dot) if record_id==17046
replace dxyr=2015 if record_id==17046
replace ICD10="C509" if record_id==17046
replace ICCCcode="12b" if record_id==17046
replace comments="Trace back: No Path Rpt. Pt died at home." if record_id==17046

replace top="220" if record_id==17069
replace topography=220 if record_id==17069
replace topcat=23 if record_id==17069
replace primarysite="LIVER" if record_id==17069
replace morphology="8000" if record_id==17069
replace morph=8000 if record_id==17069
replace morphcat=1 if record_id==17069
replace hx="METASTATIC CANCER LIVER" if record_id==17069
replace lat=0 if record_id==17069
replace latcat=0 if record_id==17069
replace beh=3 if record_id==17069
replace grade=9 if record_id==17069
replace basis=1 if record_id==17069
replace dot=d(15jan2015) if record_id==17069
replace dotyear=year(dot) if record_id==17069
replace dxyr=2015 if record_id==17069
replace ICD10="C229" if record_id==17069
replace ICCCcode="7c" if record_id==17069
replace comments="Trace back: Saw Pt 5-6 weeks before died, so was Dx before that time not sure of date." if record_id==17069

replace top="539" if record_id==17099
replace topography=539 if record_id==17099
replace topcat=46 if record_id==17099
replace primarysite="CERVIX" if record_id==17099
replace morphology="8000" if record_id==17099
replace morph=8000 if record_id==17099
replace morphcat=1 if record_id==17099
replace hx="CERVICAL CARCINOMA METASTATIC" if record_id==17099
replace lat=0 if record_id==17099
replace latcat=0 if record_id==17099
replace beh=3 if record_id==17099
replace grade=9 if record_id==17099
replace basis=0 if record_id==17099
replace dot=dod if record_id==17099
replace dotyear=year(dot) if record_id==17099
replace dxyr=2015 if record_id==17099
replace ICD10="C539" if record_id==17099
replace ICCCcode="12b" if record_id==17099

replace top="559" if record_id==17101
replace topography=559 if record_id==17101
replace topcat=48 if record_id==17101
replace primarysite="UTERUS" if record_id==17101
replace morphology="8000" if record_id==17101
replace morph=8000 if record_id==17101
replace morphcat=1 if record_id==17101
replace hx="UTERINE LEIOMYOSARCOMA METASTATIC" if record_id==17101
replace lat=0 if record_id==17101
replace latcat=0 if record_id==17101
replace beh=3 if record_id==17101
replace grade=9 if record_id==17101
replace basis=0 if record_id==17101
replace dot=dod if record_id==17101
replace dotyear=year(dot) if record_id==17101
replace dxyr=2015 if record_id==17101
replace ICD10="C55" if record_id==17101
replace ICCCcode="12b" if record_id==17101

replace top="619" if record_id==17124
replace topography=619 if record_id==17124
replace topcat=53 if record_id==17124
replace primarysite="PROSTATE" if record_id==17124
replace morphology="8000" if record_id==17124
replace morph=8000 if record_id==17124
replace morphcat=1 if record_id==17124
replace hx="PROSTATE CANCER" if record_id==17124
replace lat=0 if record_id==17124
replace latcat=0 if record_id==17124
replace beh=3 if record_id==17124
replace grade=9 if record_id==17124
replace basis=0 if record_id==17124
replace dot=dod if record_id==17124
replace dotyear=year(dot) if record_id==17124
replace dxyr=2015 if record_id==17124
replace ICD10="C61" if record_id==17124
replace ICCCcode="12b" if record_id==17124

replace top="619" if record_id==17134
replace topography=619 if record_id==17134
replace topcat=53 if record_id==17134
replace primarysite="PROSTATE" if record_id==17134
replace morphology="8000" if record_id==17134
replace morph=8000 if record_id==17134
replace morphcat=1 if record_id==17134
replace hx="PROSTATE CANCER" if record_id==17134
replace lat=0 if record_id==17134
replace latcat=0 if record_id==17134
replace beh=3 if record_id==17134
replace grade=9 if record_id==17134
replace basis=0 if record_id==17134
replace dot=dod if record_id==17134
replace dotyear=year(dot) if record_id==17134
replace dxyr=2015 if record_id==17134
replace ICD10="C61" if record_id==17134
replace ICCCcode="12b" if record_id==17134

replace top="619" if record_id==17244
replace topography=619 if record_id==17244
replace topcat=53 if record_id==17244
replace primarysite="PROSTATE" if record_id==17244
replace morphology="8000" if record_id==17244
replace morph=8000 if record_id==17244
replace morphcat=1 if record_id==17244
replace hx="CARCINOMA OF THE PROSTATE" if record_id==17244
replace lat=0 if record_id==17244
replace latcat=0 if record_id==17244
replace beh=3 if record_id==17244
replace grade=9 if record_id==17244
replace basis=0 if record_id==17244
replace dot=dod if record_id==17244
replace dotyear=year(dot) if record_id==17244
replace dxyr=2015 if record_id==17244
replace ICD10="C61" if record_id==17244
replace ICCCcode="12b" if record_id==17244

replace top="509" if record_id==17281
replace topography=509 if record_id==17281
replace topcat=43 if record_id==17281
replace primarysite="BREAST" if record_id==17281
replace morphology="8000" if record_id==17281
replace morph=8000 if record_id==17281
replace morphcat=1 if record_id==17281
replace hx="CARCINOMA BREAST" if record_id==17281
replace lat=3 if record_id==17281
replace latcat=31 if record_id==17281
replace beh=3 if record_id==17281
replace grade=9 if record_id==17281
replace basis=0 if record_id==17281
replace dot=dod if record_id==17281
replace dotyear=year(dot) if record_id==17281
replace dxyr=2015 if record_id==17281
replace ICD10="C509" if record_id==17281
replace ICCCcode="12b" if record_id==17281

replace top="421" if record_id==17282
replace topography=421 if record_id==17282
replace topcat=38 if record_id==17282
replace primarysite="BONE MARROW" if record_id==17282
replace morphology="9800" if record_id==17282
replace morph=9800 if record_id==17282
replace morphcat=50 if record_id==17282
replace hx="LEUKAEMIA" if record_id==17282
replace lat=0 if record_id==17282
replace latcat=0 if record_id==17282
replace beh=3 if record_id==17282
replace grade=9 if record_id==17282
replace basis=0 if record_id==17282
replace dot=dod if record_id==17282
replace dotyear=year(dot) if record_id==17282
replace dxyr=2015 if record_id==17282
replace ICD10="C959" if record_id==17282
replace ICCCcode="1e" if record_id==17282

replace top="619" if record_id==17297
replace topography=619 if record_id==17297
replace topcat=53 if record_id==17297
replace primarysite="PROSTATE" if record_id==17297
replace morphology="8000" if record_id==17297
replace morph=8000 if record_id==17297
replace morphcat=1 if record_id==17297
replace hx="PROSTATE CANCER" if record_id==17297
replace lat=0 if record_id==17297
replace latcat=0 if record_id==17297
replace beh=3 if record_id==17297
replace grade=9 if record_id==17297
replace basis=0 if record_id==17297
replace dot=dod if record_id==17297
replace dotyear=year(dot) if record_id==17297
replace dxyr=2015 if record_id==17297
replace ICD10="C61" if record_id==17297
replace ICCCcode="12b" if record_id==17297

replace top="172" if record_id==17310
replace topography=172 if record_id==17310
replace topcat=18 if record_id==17310
replace primarysite="SMALL INTESTINE-ILEUM" if record_id==17310
replace morphology="8000" if record_id==17310
replace morph=8000 if record_id==17310
replace morphcat=1 if record_id==17310
replace hx="CARCINOID TUMOUR OF THE ILEUM" if record_id==17310
replace lat=0 if record_id==17310
replace latcat=0 if record_id==17310
replace beh=3 if record_id==17310
replace grade=9 if record_id==17310
replace basis=0 if record_id==17310
replace dot=dod if record_id==17310
replace dotyear=year(dot) if record_id==17310
replace dxyr=2015 if record_id==17310
replace ICD10="C172" if record_id==17310
replace ICCCcode="12b" if record_id==17310

replace top="509" if record_id==17311
replace topography=509 if record_id==17311
replace topcat=43 if record_id==17311
replace primarysite="BREAST" if record_id==17311
replace morphology="8000" if record_id==17311
replace morph=8000 if record_id==17311
replace morphcat=1 if record_id==17311
replace hx="METASTATIC BREAST CANCER" if record_id==17311
replace lat=3 if record_id==17311
replace latcat=31 if record_id==17311
replace beh=3 if record_id==17311
replace grade=9 if record_id==17311
replace basis=9 if record_id==17311
replace dot=d(06mar2015) if record_id==17311
replace dotyear=year(dot) if record_id==17311
replace dxyr=2015 if record_id==17311
replace ICD10="C509" if record_id==17311
replace ICCCcode="12b" if record_id==17311
replace comments="Trace back: Seen at QEH- Mar 6, 2015. Secondary malignant neoplasm of liver and intrahepatic bile duct. Secondary malignant neoplasm of bone and bone marrow. Primary diagnosis- malignant neoplasm breast; unspecified. CHECK RT or Ward C12 seems like patient wa admistted there." if record_id==17311

replace top="719" if record_id==17333
replace topography=719 if record_id==17333
replace topcat=63 if record_id==17333
replace primarysite="BRAIN" if record_id==17333
replace morphology="8000" if record_id==17333
replace morph=8000 if record_id==17333
replace morphcat=1 if record_id==17333
replace hx="CANCER OF BRAIN" if record_id==17333
replace lat=0 if record_id==17333
replace latcat=0 if record_id==17333
replace beh=3 if record_id==17333
replace grade=9 if record_id==17333
replace basis=0 if record_id==17333
replace dot=dod if record_id==17333
replace dotyear=year(dot) if record_id==17333
replace dxyr=2015 if record_id==17333
replace ICD10="C719" if record_id==17333
replace ICCCcode="12b" if record_id==17333

replace top="421" if record_id==17336
replace topography=421 if record_id==17336
replace topcat=38 if record_id==17336
replace primarysite="BONE MARROW" if record_id==17336
replace morphology="9732" if record_id==17336
replace morph=9732 if record_id==17336
replace morphcat=46 if record_id==17336
replace hx="MULTIPLE MYELOMA" if record_id==17336
replace lat=0 if record_id==17336
replace latcat=0 if record_id==17336
replace beh=3 if record_id==17336
replace grade=9 if record_id==17336
replace basis=0 if record_id==17336
replace dot=dod if record_id==17336
replace dotyear=year(dot) if record_id==17336
replace dxyr=2015 if record_id==17336
replace ICD10="C900" if record_id==17336
replace ICCCcode="2b" if record_id==17336

replace top="739" if record_id==17375
replace topography=739 if record_id==17375
replace topcat=65 if record_id==17375
replace primarysite="THYROID GLAND" if record_id==17375
replace morphology="8000" if record_id==17375
replace morph=8000 if record_id==17375
replace morphcat=1 if record_id==17375
replace hx="CARCINOMA OF THE THYROID GLAND" if record_id==17375
replace lat=0 if record_id==17375
replace latcat=0 if record_id==17375
replace beh=3 if record_id==17375
replace grade=9 if record_id==17375
replace basis=0 if record_id==17375
replace dot=dod if record_id==17375
replace dotyear=year(dot) if record_id==17375
replace dxyr=2015 if record_id==17375
replace ICD10="C73" if record_id==17375
replace ICCCcode="12b" if record_id==17375

replace top="349" if record_id==17385
replace topography=349 if record_id==17385
replace topcat=32 if record_id==17385
replace primarysite="LUNG" if record_id==17385
replace morphology="8000" if record_id==17385
replace morph=8000 if record_id==17385
replace morphcat=1 if record_id==17385
replace hx="PULMONARY CANCER" if record_id==17385
replace lat=3 if record_id==17385
replace latcat=13 if record_id==17385
replace beh=3 if record_id==17385
replace grade=9 if record_id==17385
replace basis=0 if record_id==17385
replace dot=dod if record_id==17385
replace dotyear=year(dot) if record_id==17385
replace dxyr=2015 if record_id==17385
replace ICD10="C349" if record_id==17385
replace ICCCcode="12b" if record_id==17385

replace top="421" if record_id==17461
replace topography=421 if record_id==17461
replace topcat=38 if record_id==17461
replace primarysite="BONE MARROW" if record_id==17461
replace morphology="9732" if record_id==17461
replace morph=9732 if record_id==17461
replace morphcat=46 if record_id==17461
replace hx="MULTIPLE MYELOMA" if record_id==17461
replace lat=0 if record_id==17461
replace latcat=0 if record_id==17461
replace beh=3 if record_id==17461
replace grade=9 if record_id==17461
replace basis=0 if record_id==17461
replace dot=dod if record_id==17461
replace dotyear=year(dot) if record_id==17461
replace dxyr=2015 if record_id==17461
replace ICD10="C900" if record_id==17461
replace ICCCcode="2b" if record_id==17461
** Create duplicate observations for MPs in CODs
expand=2 if record_id==17461, gen (dupobs1do15)
replace top="530" if record_id==17461 & dupobs1do15>0
replace topography=530 if record_id==17461 & dupobs1do15>0
replace topcat=46 if record_id==17461 & dupobs1do15>0
replace primarysite="CERVIX" if record_id==17461 & dupobs1do15>0
replace morphology="8000" if record_id==17461 & dupobs1do15>0
replace morph=8000 if record_id==17461 & dupobs1do15>0
replace morphcat=1 if record_id==17461 & dupobs1do15>0
replace hx="CERVICAL CANCER" if record_id==17461 & dupobs1do15>0
replace lat=0 if record_id==17461 & dupobs1do15>0
replace latcat=0 if record_id==17461 & dupobs1do15>0
replace beh=3 if record_id==17461 & dupobs1do15>0
replace grade=9 if record_id==17461 & dupobs1do15>0
replace basis=0 if record_id==17461 & dupobs1do15>0
replace dot=dod if record_id==17461 & dupobs1do15>0
replace dotyear=year(dot) if record_id==17461 & dupobs1do15>0
replace dxyr=2015 if record_id==17461 & dupobs1do15>0
replace ICD10="C530" if record_id==17461 & dupobs1do15>0
replace ICCCcode="12b" if record_id==17461 & dupobs1do15>0
replace cr5id="T2S1" if record_id==17461 & dupobs1do15>0

replace top="619" if record_id==17473
replace topography=619 if record_id==17473
replace topcat=53 if record_id==17473
replace primarysite="PROSTATE" if record_id==17473
replace morphology="8000" if record_id==17473
replace morph=8000 if record_id==17473
replace morphcat=1 if record_id==17473
replace hx="PROSTATE CANCER" if record_id==17473
replace lat=0 if record_id==17473
replace latcat=0 if record_id==17473
replace beh=3 if record_id==17473
replace grade=9 if record_id==17473
replace basis=0 if record_id==17473
replace dot=dod if record_id==17473
replace dotyear=year(dot) if record_id==17473
replace dxyr=2015 if record_id==17473
replace ICD10="C61" if record_id==17473
replace ICCCcode="12b" if record_id==17473

replace top="541" if record_id==17477
replace topography=541 if record_id==17477
replace topcat=47 if record_id==17477
replace primarysite="ENDOMETRIUM" if record_id==17477
replace morphology="8000" if record_id==17477
replace morph=8000 if record_id==17477
replace morphcat=1 if record_id==17477
replace hx="METASTATIC ENDOMETRIAL CARCINOMA" if record_id==17477
replace lat=0 if record_id==17477
replace latcat=0 if record_id==17477
replace beh=3 if record_id==17477
replace grade=9 if record_id==17477
replace basis=0 if record_id==17477
replace dot=dod if record_id==17477
replace dotyear=year(dot) if record_id==17477
replace dxyr=2015 if record_id==17477
replace ICD10="C541" if record_id==17477
replace ICCCcode="12b" if record_id==17477

replace top="719" if record_id==17489
replace topography=719 if record_id==17489
replace topcat=63 if record_id==17489
replace primarysite="BRAIN" if record_id==17489
replace morphology="9382" if record_id==17489
replace morph=9382 if record_id==17489
replace morphcat=36 if record_id==17489
replace hx="ANAPLASTIC MIXED GLIOMA-OLIGOASTROCYTOMA" if record_id==17489
replace lat=0 if record_id==17489
replace latcat=0 if record_id==17489
replace beh=3 if record_id==17489
replace grade=4 if record_id==17489
replace basis=7 if record_id==17489
replace dot=d(30jun2008) if record_id==17489
replace dotyear=year(dot) if record_id==17489
replace dxyr=2008 if record_id==17489
replace ICD10="C719" if record_id==17489
replace ICCCcode="3b" if record_id==17489

replace top="259" if record_id==17503
replace topography=259 if record_id==17503
replace topcat=26 if record_id==17503
replace primarysite="PANCREAS" if record_id==17503
replace morphology="8000" if record_id==17503
replace morph=8000 if record_id==17503
replace morphcat=1 if record_id==17503
replace hx="PANCREATIC CANCER WITH LIVER METASTASES" if record_id==17503
replace lat=0 if record_id==17503
replace latcat=0 if record_id==17503
replace beh=3 if record_id==17503
replace grade=9 if record_id==17503
replace basis=0 if record_id==17503
replace dot=dod if record_id==17503
replace dotyear=year(dot) if record_id==17503
replace dxyr=2015 if record_id==17503
replace ICD10="C259" if record_id==17503
replace ICCCcode="12b" if record_id==17503

replace top="259" if record_id==17505
replace topography=259 if record_id==17505
replace topcat=26 if record_id==17505
replace primarysite="PANCREAS" if record_id==17505
replace morphology="8000" if record_id==17505
replace morph=8000 if record_id==17505
replace morphcat=1 if record_id==17505
replace hx="METASTATIC CARCINOMA OF PANCREAS" if record_id==17505
replace lat=0 if record_id==17505
replace latcat=0 if record_id==17505
replace beh=3 if record_id==17505
replace grade=9 if record_id==17505
replace basis=0 if record_id==17505
replace dot=dod if record_id==17505
replace dotyear=year(dot) if record_id==17505
replace dxyr=2015 if record_id==17505
replace ICD10="C259" if record_id==17505
replace ICCCcode="12b" if record_id==17505

replace top="169" if record_id==17524
replace topography=169 if record_id==17524
replace topcat=17 if record_id==17524
replace primarysite="STOMACH" if record_id==17524
replace morphology="8000" if record_id==17524
replace morph=8000 if record_id==17524
replace morphcat=1 if record_id==17524
replace hx="ADENOCARCINOMA OF THE STOMACH" if record_id==17524
replace lat=0 if record_id==17524
replace latcat=0 if record_id==17524
replace beh=3 if record_id==17524
replace grade=9 if record_id==17524
replace basis=0 if record_id==17524
replace dot=dod if record_id==17524
replace dotyear=year(dot) if record_id==17524
replace dxyr=2015 if record_id==17524
replace ICD10="C169" if record_id==17524
replace ICCCcode="12b" if record_id==17524

replace top="619" if record_id==17564
replace topography=619 if record_id==17564
replace topcat=53 if record_id==17564
replace primarysite="PROSTATE" if record_id==17564
replace morphology="8000" if record_id==17564
replace morph=8000 if record_id==17564
replace morphcat=1 if record_id==17564
replace hx="PROSTATE CANCER" if record_id==17564
replace lat=0 if record_id==17564
replace latcat=0 if record_id==17564
replace beh=3 if record_id==17564
replace grade=9 if record_id==17564
replace basis=0 if record_id==17564
replace dot=dod if record_id==17564
replace dotyear=year(dot) if record_id==17564
replace dxyr=2015 if record_id==17564
replace ICD10="C61" if record_id==17564
replace ICCCcode="12b" if record_id==17564

replace top="220" if record_id==17591
replace topography=220 if record_id==17591
replace topcat=23 if record_id==17591
replace primarysite="LIVER" if record_id==17591
replace morphology="8000" if record_id==17591
replace morph=8000 if record_id==17591
replace morphcat=1 if record_id==17591
replace hx="METASTATIC CARCINOID TUMOR" if record_id==17591
replace lat=0 if record_id==17591
replace latcat=0 if record_id==17591
replace beh=3 if record_id==17591
replace grade=9 if record_id==17591
replace basis=1 if record_id==17591
replace dot=d(05dec2014) if record_id==17591
replace dotyear=year(dot) if record_id==17591
replace dxyr=2014 if record_id==17591
replace ICD10="C229" if record_id==17591
replace ICCCcode="7c" if record_id==17591
replace comments="Trace back: Liver cell carcinoma diagnosed December 5 2014.Clinical." if record_id==17591

replace top="169" if record_id==17607
replace topography=169 if record_id==17607
replace topcat=17 if record_id==17607
replace primarysite="STOMACH" if record_id==17607
replace morphology="8000" if record_id==17607
replace morph=8000 if record_id==17607
replace morphcat=1 if record_id==17607
replace hx="METASTATIC GASTRIC CARCINOMA" if record_id==17607
replace lat=0 if record_id==17607
replace latcat=0 if record_id==17607
replace beh=3 if record_id==17607
replace grade=9 if record_id==17607
replace basis=0 if record_id==17607
replace dot=dod if record_id==17607
replace dotyear=year(dot) if record_id==17607
replace dxyr=2015 if record_id==17607
replace ICD10="C169" if record_id==17607
replace ICCCcode="12b" if record_id==17607

replace top="169" if record_id==17617
replace topography=169 if record_id==17617
replace topcat=17 if record_id==17617
replace primarysite="STOMACH" if record_id==17617
replace morphology="8000" if record_id==17617
replace morph=8000 if record_id==17617
replace morphcat=1 if record_id==17617
replace hx="CARCINOMA OF THE STOMACH" if record_id==17617
replace lat=0 if record_id==17617
replace latcat=0 if record_id==17617
replace beh=3 if record_id==17617
replace grade=9 if record_id==17617
replace basis=0 if record_id==17617
replace dot=dod if record_id==17617
replace dotyear=year(dot) if record_id==17617
replace dxyr=2015 if record_id==17617
replace ICD10="C169" if record_id==17617
replace ICCCcode="12b" if record_id==17617

replace top="421" if record_id==17635
replace topography=421 if record_id==17635
replace topcat=38 if record_id==17635
replace primarysite="BONE MARROW" if record_id==17635
replace morphology="8000" if record_id==17635
replace morph=8000 if record_id==17635
replace morphcat=1 if record_id==17635
replace hx="HAEMATOLOGIC MALIGNANCY" if record_id==17635
replace lat=0 if record_id==17635
replace latcat=0 if record_id==17635
replace beh=3 if record_id==17635
replace grade=9 if record_id==17635
replace basis=5 if record_id==17635
replace dot=d(15mar2015) if record_id==17635
replace dotyear=year(dot) if record_id==17635
replace dxyr=2015 if record_id==17635
replace ICD10="C969" if record_id==17635
replace ICCCcode="12b" if record_id==17635

replace top="619" if record_id==17640
replace topography=619 if record_id==17640
replace topcat=53 if record_id==17640
replace primarysite="PROSTATE" if record_id==17640
replace morphology="8000" if record_id==17640
replace morph=8000 if record_id==17640
replace morphcat=1 if record_id==17640
replace hx="CARCINOMA OF THE PROSTATE GLAND WITH METASTASIS" if record_id==17640
replace lat=0 if record_id==17640
replace latcat=0 if record_id==17640
replace beh=3 if record_id==17640
replace grade=9 if record_id==17640
replace basis=0 if record_id==17640
replace dot=dod if record_id==17640
replace dotyear=year(dot) if record_id==17640
replace dxyr=2015 if record_id==17640
replace ICD10="C61" if record_id==17640
replace ICCCcode="12b" if record_id==17640

replace top="169" if record_id==17644
replace topography=169 if record_id==17644
replace topcat=17 if record_id==17644
replace primarysite="STOMACH" if record_id==17644
replace morphology="8000" if record_id==17644
replace morph=8000 if record_id==17644
replace morphcat=1 if record_id==17644
replace hx="GASTROINTESTINAL TUMOR OF STOMACH" if record_id==17644
replace lat=0 if record_id==17644
replace latcat=0 if record_id==17644
replace beh=3 if record_id==17644
replace grade=9 if record_id==17644
replace basis=0 if record_id==17644
replace dot=dod if record_id==17644
replace dotyear=year(dot) if record_id==17644
replace dxyr=2015 if record_id==17644
replace ICD10="C169" if record_id==17644
replace ICCCcode="12b" if record_id==17644

replace top="809" if record_id==17654
replace topography=809 if record_id==17654
replace topcat=70 if record_id==17654
replace primarysite="99" if record_id==17654
replace morphology="8000" if record_id==17654
replace morph=8000 if record_id==17654
replace morphcat=1 if record_id==17654
replace hx="CARCINOMATOSIS HIGH GRADE SPINDLE CELL SARCOMA" if record_id==17654
replace lat=0 if record_id==17654
replace latcat=0 if record_id==17654
replace beh=3 if record_id==17654
replace grade=9 if record_id==17654
replace basis=0 if record_id==17654
replace dot=dod if record_id==17654
replace dotyear=year(dot) if record_id==17654
replace dxyr=2015 if record_id==17654
replace ICD10="C80" if record_id==17654
replace ICCCcode="12b" if record_id==17654

replace top="029" if record_id==17663
replace topography=29 if record_id==17663
replace topcat=3 if record_id==17663
replace primarysite="TONGUE" if record_id==17663
replace morphology="8000" if record_id==17663
replace morph=8000 if record_id==17663
replace morphcat=1 if record_id==17663
replace hx="METASTATIC TONGUE CANCER" if record_id==17663
replace lat=0 if record_id==17663
replace latcat=0 if record_id==17663
replace beh=3 if record_id==17663
replace grade=9 if record_id==17663
replace basis=1 if record_id==17663
replace dot=d(28apr2013) if record_id==17663
replace dotyear=year(dot) if record_id==17663
replace dxyr=2013 if record_id==17663
replace ICD10="C029" if record_id==17663
replace ICCCcode="12b" if record_id==17663
replace comments="Trace back: Definitely diagnosed well before 2015: First presentation was to Dr A Irvine 28th April 2013 with supraclavicular lymphadenopathy and refered to Dr Jillian Clarke due to suspected ENT malignancy. Was treated for metastatic ca tongue by Dr T Lauret locally in conjunction with a specialist center overseas." if record_id==17663

replace top="239" if record_id==17678
replace topography=239 if record_id==17678
replace topcat=24 if record_id==17678
replace primarysite="GALLBLADDER" if record_id==17678
replace morphology="8000" if record_id==17678
replace morph=8000 if record_id==17678
replace morphcat=1 if record_id==17678
replace hx="METASTATIC CARCINOMA OF THE GALL BLADDER" if record_id==17678
replace lat=0 if record_id==17678
replace latcat=0 if record_id==17678
replace beh=3 if record_id==17678
replace grade=9 if record_id==17678
replace basis=1 if record_id==17678
replace dot=d(30jun2014) if record_id==17678
replace dotyear=year(dot) if record_id==17678
replace dxyr=2014 if record_id==17678
replace ICD10="C23" if record_id==17678
replace ICCCcode="12b" if record_id==17678
replace comments="Trace back: Dx in 2014." if record_id==17678

replace top="421" if record_id==17699
replace topography=421 if record_id==17699
replace topcat=38 if record_id==17699
replace primarysite="BONE MARROW" if record_id==17699
replace morphology="9800" if record_id==17699
replace morph=9800 if record_id==17699
replace morphcat=50 if record_id==17699
replace hx="LEUKAEMIA" if record_id==17699
replace lat=0 if record_id==17699
replace latcat=0 if record_id==17699
replace beh=3 if record_id==17699
replace grade=9 if record_id==17699
replace basis=0 if record_id==17699
replace dot=dod if record_id==17699
replace dotyear=year(dot) if record_id==17699
replace dxyr=2015 if record_id==17699
replace ICD10="C959" if record_id==17699
replace ICCCcode="1e" if record_id==17699

replace top="619" if record_id==17714
replace topography=619 if record_id==17714
replace topcat=53 if record_id==17714
replace primarysite="PROSTATE" if record_id==17714
replace morphology="8000" if record_id==17714
replace morph=8000 if record_id==17714
replace morphcat=1 if record_id==17714
replace hx="METASTATIC PROATATE CARCINOMA" if record_id==17714
replace lat=0 if record_id==17714
replace latcat=0 if record_id==17714
replace beh=3 if record_id==17714
replace grade=9 if record_id==17714
replace basis=0 if record_id==17714
replace dot=dod if record_id==17714
replace dotyear=year(dot) if record_id==17714
replace dxyr=2015 if record_id==17714
replace ICD10="C61" if record_id==17714
replace ICCCcode="12b" if record_id==17714

replace top="619" if record_id==17728
replace topography=619 if record_id==17728
replace topcat=53 if record_id==17728
replace primarysite="PROSTATE" if record_id==17728
replace morphology="8000" if record_id==17728
replace morph=8000 if record_id==17728
replace morphcat=1 if record_id==17728
replace hx="METASTATIC PROATATE CARCINOMA" if record_id==17728
replace lat=0 if record_id==17728
replace latcat=0 if record_id==17728
replace beh=3 if record_id==17728
replace grade=9 if record_id==17728
replace basis=0 if record_id==17728
replace dot=dod if record_id==17728
replace dotyear=year(dot) if record_id==17728
replace dxyr=2015 if record_id==17728
replace ICD10="C61" if record_id==17728
replace ICCCcode="12b" if record_id==17728

replace top="809" if record_id==17729
replace topography=809 if record_id==17729
replace topcat=70 if record_id==17729
replace primarysite="99" if record_id==17729
replace morphology="8000" if record_id==17729
replace morph=8000 if record_id==17729
replace morphcat=1 if record_id==17729
replace hx="METASTATIC CARCINOMA OF UNKNOWN ORIGIN" if record_id==17729
replace lat=0 if record_id==17729
replace latcat=0 if record_id==17729
replace beh=3 if record_id==17729
replace grade=9 if record_id==17729
replace basis=1 if record_id==17729
replace dot=d(30jun2014) if record_id==17729
replace dotyear=year(dot) if record_id==17729
replace dxyr=2014 if record_id==17729
replace ICD10="C80" if record_id==17729
replace ICCCcode="12b" if record_id==17729
replace comments="Trace back: Dx in 2014." if record_id==17729

replace top="619" if record_id==17741
replace topography=619 if record_id==17741
replace topcat=53 if record_id==17741
replace primarysite="PROSTATE" if record_id==17741
replace morphology="8000" if record_id==17741
replace morph=8000 if record_id==17741
replace morphcat=1 if record_id==17741
replace hx="PROSTATE CANCER METASTATIC" if record_id==17741
replace lat=0 if record_id==17741
replace latcat=0 if record_id==17741
replace beh=3 if record_id==17741
replace grade=9 if record_id==17741
replace basis=0 if record_id==17741
replace dot=dod if record_id==17741
replace dotyear=year(dot) if record_id==17741
replace dxyr=2015 if record_id==17741
replace ICD10="C61" if record_id==17741
replace ICCCcode="12b" if record_id==17741

replace top="220" if record_id==17761
replace topography=220 if record_id==17761
replace topcat=23 if record_id==17761
replace primarysite="LIVER" if record_id==17761
replace morphology="8000" if record_id==17761
replace morph=8000 if record_id==17761
replace morphcat=1 if record_id==17761
replace hx="METASTATIC LIVER DISEASE" if record_id==17761
replace lat=0 if record_id==17761
replace latcat=0 if record_id==17761
replace beh=3 if record_id==17761
replace grade=9 if record_id==17761
replace basis=0 if record_id==17761
replace dot=dod if record_id==17761
replace dotyear=year(dot) if record_id==17761
replace dxyr=2015 if record_id==17761
replace ICD10="C229" if record_id==17761
replace ICCCcode="7c" if record_id==17761

replace top="509" if record_id==17789
replace topography=509 if record_id==17789
replace topcat=43 if record_id==17789
replace primarysite="BREAST" if record_id==17789
replace morphology="8000" if record_id==17789
replace morph=8000 if record_id==17789
replace morphcat=1 if record_id==17789
replace hx="CARCINOMATOSIS BREAST CANCER" if record_id==17789
replace lat=3 if record_id==17789
replace latcat=31 if record_id==17789
replace beh=3 if record_id==17789
replace grade=9 if record_id==17789
replace basis=0 if record_id==17789
replace dot=dod if record_id==17789
replace dotyear=year(dot) if record_id==17789
replace dxyr=2015 if record_id==17789
replace ICD10="C509" if record_id==17789
replace ICCCcode="12b" if record_id==17789

replace top="189" if record_id==17804
replace topography=189 if record_id==17804
replace topcat=19 if record_id==17804
replace primarysite="COLON" if record_id==17804
replace morphology="8140" if record_id==17804
replace morph=8140 if record_id==17804
replace morphcat=6 if record_id==17804
replace hx="METASTATIC ADENOCARCINOMA OF THE COLON SPREAD TO THE LIVER" if record_id==17804
replace lat=0 if record_id==17804
replace latcat=0 if record_id==17804
replace beh=3 if record_id==17804
replace grade=9 if record_id==17804
replace basis=7 if record_id==17804
replace dot=d(15jan2015) if record_id==17804
replace dotyear=year(dot) if record_id==17804
replace dxyr=2015 if record_id==17804
replace ICD10="C189" if record_id==17804
replace ICCCcode="11f" if record_id==17804
replace comments="Trace back: Dx in 2015 - hx of primary colonoscopy done by Kwame Connell referred to S Ferdinand then from Wayne Clarke went to QEH. Hx would have been done privately at IPS." if record_id==17804

replace top="250" if record_id==17809
replace topography=250 if record_id==17809
replace topcat=26 if record_id==17809
replace primarysite="PANCREAS-HEAD" if record_id==17809
replace morphology="8000" if record_id==17809
replace morph=8000 if record_id==17809
replace morphcat=1 if record_id==17809
replace hx="CANCER OF THE HEAD OF THE PANCREAS WITH OBSTRUCTIVE JAUNDICE" if record_id==17809
replace lat=0 if record_id==17809
replace latcat=0 if record_id==17809
replace beh=3 if record_id==17809
replace grade=9 if record_id==17809
replace basis=0 if record_id==17809
replace dot=dod if record_id==17809
replace dotyear=year(dot) if record_id==17809
replace dxyr=2015 if record_id==17809
replace ICD10="C250" if record_id==17809
replace ICCCcode="12b" if record_id==17809

replace top="541" if record_id==17829
replace topography=541 if record_id==17829
replace topcat=47 if record_id==17829
replace primarysite="ENDOMETRIUM" if record_id==17829
replace morphology="8000" if record_id==17829
replace morph=8000 if record_id==17829
replace morphcat=1 if record_id==17829
replace hx="ADVANCED ENDOMETRIAL CANCER" if record_id==17829
replace lat=0 if record_id==17829
replace latcat=0 if record_id==17829
replace beh=3 if record_id==17829
replace grade=9 if record_id==17829
replace basis=1 if record_id==17829
replace dot=d(06apr2015) if record_id==17829
replace dotyear=year(dot) if record_id==17829
replace dxyr=2015 if record_id==17829
replace ICD10="C541" if record_id==17829
replace ICCCcode="12b" if record_id==17829
replace comments="Trace back: Last admitted at QEH April 6, 2015. Seen by Rudolph Delice. Malignant neoplasm: endometrium." if record_id==17829

replace top="199" if record_id==17842
replace topography=199 if record_id==17842
replace topcat=20 if record_id==17842
replace primarysite="COLORECTAL" if record_id==17842
replace morphology="8000" if record_id==17842
replace morph=8000 if record_id==17842
replace morphcat=1 if record_id==17842
replace hx="METASTATIC CANCER COLORECTAL CANCER" if record_id==17842
replace lat=0 if record_id==17842
replace latcat=0 if record_id==17842
replace beh=3 if record_id==17842
replace grade=9 if record_id==17842
replace basis=0 if record_id==17842
replace dot=dod if record_id==17842
replace dotyear=year(dot) if record_id==17842
replace dxyr=2015 if record_id==17842
replace ICD10="C19" if record_id==17842
replace ICCCcode="12b" if record_id==17842

replace top="259" if record_id==17846
replace topography=259 if record_id==17846
replace topcat=26 if record_id==17846
replace primarysite="PANCREAS" if record_id==17846
replace morphology="8000" if record_id==17846
replace morph=8000 if record_id==17846
replace morphcat=1 if record_id==17846
replace hx="ADVANCED PANCREATIC CANCER" if record_id==17846
replace lat=0 if record_id==17846
replace latcat=0 if record_id==17846
replace beh=3 if record_id==17846
replace grade=9 if record_id==17846
replace basis=0 if record_id==17846
replace dot=dod if record_id==17846
replace dotyear=year(dot) if record_id==17846
replace dxyr=2015 if record_id==17846
replace ICD10="C259" if record_id==17846
replace ICCCcode="12b" if record_id==17846

replace top="619" if record_id==17848
replace topography=619 if record_id==17848
replace topcat=53 if record_id==17848
replace primarysite="PROSTATE" if record_id==17848
replace morphology="8000" if record_id==17848
replace morph=8000 if record_id==17848
replace morphcat=1 if record_id==17848
replace hx="CARCINOMA PROSTATE WITH BONE METASTASIS" if record_id==17848
replace lat=0 if record_id==17848
replace latcat=0 if record_id==17848
replace beh=3 if record_id==17848
replace grade=9 if record_id==17848
replace basis=0 if record_id==17848
replace dot=dod if record_id==17848
replace dotyear=year(dot) if record_id==17848
replace dxyr=2015 if record_id==17848
replace ICD10="C61" if record_id==17848
replace ICCCcode="12b" if record_id==17848

replace top="349" if record_id==17865
replace topography=349 if record_id==17865
replace topcat=32 if record_id==17865
replace primarysite="LUNG" if record_id==17865
replace morphology="8000" if record_id==17865
replace morph=8000 if record_id==17865
replace morphcat=1 if record_id==17865
replace hx="METASTATIC LUNG CANCER" if record_id==17865
replace lat=3 if record_id==17865
replace latcat=13 if record_id==17865
replace beh=3 if record_id==17865
replace grade=9 if record_id==17865
replace basis=0 if record_id==17865
replace dot=dod if record_id==17865
replace dotyear=year(dot) if record_id==17865
replace dxyr=2015 if record_id==17865
replace ICD10="C349" if record_id==17865
replace ICCCcode="12b" if record_id==17865

replace top="249" if record_id==17868
replace topography=249 if record_id==17868
replace topcat=25 if record_id==17868
replace primarysite="HEPATOBILLARY" if record_id==17868
replace morphology="8000" if record_id==17868
replace morph=8000 if record_id==17868
replace morphcat=1 if record_id==17868
replace hx="HEPATOBILLARY CANCER" if record_id==17868
replace lat=0 if record_id==17868
replace latcat=0 if record_id==17868
replace beh=3 if record_id==17868
replace grade=9 if record_id==17868
replace basis=0 if record_id==17868
replace dot=dod if record_id==17868
replace dotyear=year(dot) if record_id==17868
replace dxyr=2015 if record_id==17868
replace ICD10="C249" if record_id==17868
replace ICCCcode="12b" if record_id==17868

replace top="679" if record_id==17886
replace topography=679 if record_id==17886
replace topcat=59 if record_id==17886
replace primarysite="BLADDER" if record_id==17886
replace morphology="8000" if record_id==17886
replace morph=8000 if record_id==17886
replace morphcat=1 if record_id==17886
replace hx="CANCER BLADDER" if record_id==17886
replace lat=0 if record_id==17886
replace latcat=0 if record_id==17886
replace beh=3 if record_id==17886
replace grade=9 if record_id==17886
replace basis=0 if record_id==17886
replace dot=dod if record_id==17886
replace dotyear=year(dot) if record_id==17886
replace dxyr=2015 if record_id==17886
replace ICD10="C679" if record_id==17886
replace ICCCcode="12b" if record_id==17886

replace top="619" if record_id==17891
replace topography=619 if record_id==17891
replace topcat=53 if record_id==17891
replace primarysite="PROSTATE" if record_id==17891
replace morphology="8000" if record_id==17891
replace morph=8000 if record_id==17891
replace morphcat=1 if record_id==17891
replace hx="CARCINOMA OF THE PROSTATE" if record_id==17891
replace lat=0 if record_id==17891
replace latcat=0 if record_id==17891
replace beh=3 if record_id==17891
replace grade=9 if record_id==17891
replace basis=0 if record_id==17891
replace dot=dod if record_id==17891
replace dotyear=year(dot) if record_id==17891
replace dxyr=2015 if record_id==17891
replace ICD10="C61" if record_id==17891
replace ICCCcode="12b" if record_id==17891

replace top="619" if record_id==17894
replace topography=619 if record_id==17894
replace topcat=53 if record_id==17894
replace primarysite="PROSTATE" if record_id==17894
replace morphology="8000" if record_id==17894
replace morph=8000 if record_id==17894
replace morphcat=1 if record_id==17894
replace hx="PROSTATE CANCER" if record_id==17894
replace lat=0 if record_id==17894
replace latcat=0 if record_id==17894
replace beh=3 if record_id==17894
replace grade=9 if record_id==17894
replace basis=0 if record_id==17894
replace dot=dod if record_id==17894
replace dotyear=year(dot) if record_id==17894
replace dxyr=2015 if record_id==17894
replace ICD10="C61" if record_id==17894
replace ICCCcode="12b" if record_id==17894

replace top="619" if record_id==17915
replace topography=619 if record_id==17915
replace topcat=53 if record_id==17915
replace primarysite="PROSTATE" if record_id==17915
replace morphology="8000" if record_id==17915
replace morph=8000 if record_id==17915
replace morphcat=1 if record_id==17915
replace hx="CARCINOMA OF THE PROSTATE" if record_id==17915
replace lat=0 if record_id==17915
replace latcat=0 if record_id==17915
replace beh=3 if record_id==17915
replace grade=9 if record_id==17915
replace basis=0 if record_id==17915
replace dot=dod if record_id==17915
replace dotyear=year(dot) if record_id==17915
replace dxyr=2015 if record_id==17915
replace ICD10="C61" if record_id==17915
replace ICCCcode="12b" if record_id==17915

replace top="199" if record_id==17930
replace topography=199 if record_id==17930
replace topcat=20 if record_id==17930
replace primarysite="COLORECTAL" if record_id==17930
replace morphology="8000" if record_id==17930
replace morph=8000 if record_id==17930
replace morphcat=1 if record_id==17930
replace hx="COLORECTAL CANCER" if record_id==17930
replace lat=0 if record_id==17930
replace latcat=0 if record_id==17930
replace beh=3 if record_id==17930
replace grade=9 if record_id==17930
replace basis=0 if record_id==17930
replace dot=dod if record_id==17930
replace dotyear=year(dot) if record_id==17930
replace dxyr=2015 if record_id==17930
replace ICD10="C19" if record_id==17930
replace ICCCcode="12b" if record_id==17930

replace top="619" if record_id==17942
replace topography=619 if record_id==17942
replace topcat=53 if record_id==17942
replace primarysite="PROSTATE" if record_id==17942
replace morphology="8000" if record_id==17942
replace morph=8000 if record_id==17942
replace morphcat=1 if record_id==17942
replace hx="ADVANCED PROSTATE CANCER" if record_id==17942
replace lat=0 if record_id==17942
replace latcat=0 if record_id==17942
replace beh=3 if record_id==17942
replace grade=9 if record_id==17942
replace basis=0 if record_id==17942
replace dot=dod if record_id==17942
replace dotyear=year(dot) if record_id==17942
replace dxyr=2015 if record_id==17942
replace ICD10="C61" if record_id==17942
replace ICCCcode="12b" if record_id==17942

replace top="189" if record_id==17945
replace topography=189 if record_id==17945
replace topcat=19 if record_id==17945
replace primarysite="COLON" if record_id==17945
replace morphology="8000" if record_id==17945
replace morph=8000 if record_id==17945
replace morphcat=1 if record_id==17945
replace hx="CANCER OF COLON" if record_id==17945
replace lat=0 if record_id==17945
replace latcat=0 if record_id==17945
replace beh=3 if record_id==17945
replace grade=9 if record_id==17945
replace basis=0 if record_id==17945
replace dot=dod if record_id==17945
replace dotyear=year(dot) if record_id==17945
replace dxyr=2015 if record_id==17945
replace ICD10="C189" if record_id==17945
replace ICCCcode="12b" if record_id==17945

replace top="559" if record_id==17948
replace topography=559 if record_id==17948
replace topcat=48 if record_id==17948
replace primarysite="UTERUS" if record_id==17948
replace morphology="8000" if record_id==17948
replace morph=8000 if record_id==17948
replace morphcat=1 if record_id==17948
replace hx="MALIGNANT NEOPLASM ADENO CARCINOMA OF UTERUS" if record_id==17948
replace lat=0 if record_id==17948
replace latcat=0 if record_id==17948
replace beh=3 if record_id==17948
replace grade=9 if record_id==17948
replace basis=0 if record_id==17948
replace dot=dod if record_id==17948
replace dotyear=year(dot) if record_id==17948
replace dxyr=2015 if record_id==17948
replace ICD10="C55" if record_id==17948
replace ICCCcode="12b" if record_id==17948

replace top="269" if record_id==17966
replace topography=269 if record_id==17966
replace topcat=27 if record_id==17966
replace primarysite="GASTROINTESTINAL TRACT" if record_id==17966
replace morphology="8000" if record_id==17966
replace morph=8000 if record_id==17966
replace morphcat=1 if record_id==17966
replace hx="MESTASTATIC HEPATIC DISEASE GASTROINTESTINAL MALIGNANCY" if record_id==17966
replace lat=0 if record_id==17966
replace latcat=0 if record_id==17966
replace beh=3 if record_id==17966
replace grade=9 if record_id==17966
replace basis=0 if record_id==17966
replace dot=dod if record_id==17966
replace dotyear=year(dot) if record_id==17966
replace dxyr=2015 if record_id==17966
replace ICD10="C269" if record_id==17966
replace ICCCcode="12b" if record_id==17966

replace top="529" if record_id==17973
replace topography=529 if record_id==17973
replace topcat=45 if record_id==17973
replace primarysite="VAGINA" if record_id==17973
replace morphology="8000" if record_id==17973
replace morph=8000 if record_id==17973
replace morphcat=1 if record_id==17973
replace hx="CANCER OF VAGINA, VULVA; WIDESPREAD MEATSTASES" if record_id==17973
replace lat=0 if record_id==17973
replace latcat=0 if record_id==17973
replace beh=3 if record_id==17973
replace grade=9 if record_id==17973
replace basis=0 if record_id==17973
replace dot=dod if record_id==17973
replace dotyear=year(dot) if record_id==17973
replace dxyr=2015 if record_id==17973
replace ICD10="C52" if record_id==17973
replace ICCCcode="12b" if record_id==17973

replace top="779" if record_id==17998
replace topography=779 if record_id==17998
replace topcat=69 if record_id==17998
replace primarysite="LYMPH NODE-99" if record_id==17998
replace morphology="9591" if record_id==17998
replace morph=9591 if record_id==17998
replace morphcat=41 if record_id==17998
replace hx="NON HODGKINS LYMPHOMA" if record_id==17998
replace lat=0 if record_id==17998
replace latcat=0 if record_id==17998
replace beh=3 if record_id==17998
replace grade=9 if record_id==17998
replace basis=0 if record_id==17998
replace dot=dod if record_id==17998
replace dotyear=year(dot) if record_id==17998
replace dxyr=2015 if record_id==17998
replace ICD10="C859" if record_id==17998
replace ICCCcode="2b" if record_id==17998

replace top="719" if record_id==17999
replace topography=719 if record_id==17999
replace topcat=63 if record_id==17999
replace primarysite="BRAIN" if record_id==17999
replace morphology="8000" if record_id==17999
replace morph=8000 if record_id==17999
replace morphcat=1 if record_id==17999
replace hx="BRAIN CANCER" if record_id==17999
replace lat=0 if record_id==17999
replace latcat=0 if record_id==17999
replace beh=3 if record_id==17999
replace grade=9 if record_id==17999
replace basis=0 if record_id==17999
replace dot=dod if record_id==17999
replace dotyear=year(dot) if record_id==17999
replace dxyr=2015 if record_id==17999
replace ICD10="C719" if record_id==17999
replace ICCCcode="12b" if record_id==17999

replace top="509" if record_id==18014
replace topography=509 if record_id==18014
replace topcat=43 if record_id==18014
replace primarysite="BREAST" if record_id==18014
replace morphology="8000" if record_id==18014
replace morph=8000 if record_id==18014
replace morphcat=1 if record_id==18014
replace hx="CARCINOMATOSIS BREAST CANCER" if record_id==18014
replace lat=3 if record_id==18014
replace latcat=31 if record_id==18014
replace beh=3 if record_id==18014
replace grade=9 if record_id==18014
replace basis=9 if record_id==18014
replace dot=d(15may2015) if record_id==18014
replace dotyear=year(dot) if record_id==18014
replace dxyr=2015 if record_id==18014
replace ICD10="C509" if record_id==18014
replace ICCCcode="12b" if record_id==18014
replace comments="Trace back: Admitted May 15, 2015 with malignant neoplasm of breast. Not sure when first diagnosed. Check RT. Was seen by both Shenoy and Smith-connell." if record_id==18014

replace top="421" if record_id==18059
replace topography=421 if record_id==18059
replace topcat=38 if record_id==18059
replace primarysite="BONE MARROW" if record_id==18059
replace morphology="9989" if record_id==18059
replace morph=9989 if record_id==18059
replace morphcat=56 if record_id==18059
replace hx="MYELODYSPLASTIC SYNDROME" if record_id==18059
replace lat=0 if record_id==18059
replace latcat=0 if record_id==18059
replace beh=3 if record_id==18059
replace grade=9 if record_id==18059
replace basis=0 if record_id==18059
replace dot=dod if record_id==18059
replace dotyear=year(dot) if record_id==18059
replace dxyr=2015 if record_id==18059
replace ICD10="D469" if record_id==18059
replace ICCCcode="1d" if record_id==18059

replace top="619" if record_id==18063
replace topography=619 if record_id==18063
replace topcat=53 if record_id==18063
replace primarysite="PROSTATE" if record_id==18063
replace morphology="8000" if record_id==18063
replace morph=8000 if record_id==18063
replace morphcat=1 if record_id==18063
replace hx="PROSTATE CANCER" if record_id==18063
replace lat=0 if record_id==18063
replace latcat=0 if record_id==18063
replace beh=3 if record_id==18063
replace grade=9 if record_id==18063
replace basis=9 if record_id==18063
replace dot=d(08aug2014) if record_id==18063
replace dotyear=year(dot) if record_id==18063
replace dxyr=2014 if record_id==18063
replace ICD10="C61" if record_id==18063
replace ICCCcode="12b" if record_id==18063
replace comments="Trace back: Last seen August 8, 2014 with diagnosis of prostate cancer. Ineligible for 2015." if record_id==18063

replace top="189" if record_id==18089
replace topography=189 if record_id==18089
replace topcat=19 if record_id==18089
replace primarysite="COLON" if record_id==18089
replace morphology="8000" if record_id==18089
replace morph=8000 if record_id==18089
replace morphcat=1 if record_id==18089
replace hx="CARCINOMA OF COLON" if record_id==18089
replace lat=0 if record_id==18089
replace latcat=0 if record_id==18089
replace beh=3 if record_id==18089
replace grade=9 if record_id==18089
replace basis=0 if record_id==18089
replace dot=dod if record_id==18089
replace dotyear=year(dot) if record_id==18089
replace dxyr=2015 if record_id==18089
replace ICD10="C189" if record_id==18089
replace ICCCcode="12b" if record_id==18089

replace top="189" if record_id==18094
replace topography=189 if record_id==18094
replace topcat=19 if record_id==18094
replace primarysite="COLON" if record_id==18094
replace morphology="8000" if record_id==18094
replace morph=8000 if record_id==18094
replace morphcat=1 if record_id==18094
replace hx="CARCINOMA OF COLON" if record_id==18094
replace lat=0 if record_id==18094
replace latcat=0 if record_id==18094
replace beh=3 if record_id==18094
replace grade=9 if record_id==18094
replace basis=0 if record_id==18094
replace dot=dod if record_id==18094
replace dotyear=year(dot) if record_id==18094
replace dxyr=2015 if record_id==18094
replace ICD10="C189" if record_id==18094
replace ICCCcode="12b" if record_id==18094

replace top="199" if record_id==18109
replace topography=199 if record_id==18109
replace topcat=20 if record_id==18109
replace primarysite="COLORECTAL" if record_id==18109
replace morphology="8000" if record_id==18109
replace morph=8000 if record_id==18109
replace morphcat=1 if record_id==18109
replace hx="METASTATIC COLORECTAL CARCINOMA" if record_id==18109
replace lat=0 if record_id==18109
replace latcat=0 if record_id==18109
replace beh=3 if record_id==18109
replace grade=9 if record_id==18109
replace basis=0 if record_id==18109
replace dot=dod if record_id==18109
replace dotyear=year(dot) if record_id==18109
replace dxyr=2015 if record_id==18109
replace ICD10="C19" if record_id==18109
replace ICCCcode="12b" if record_id==18109

replace top="619" if record_id==18116
replace topography=619 if record_id==18116
replace topcat=53 if record_id==18116
replace primarysite="PROSTATE" if record_id==18116
replace morphology="8000" if record_id==18116
replace morph=8000 if record_id==18116
replace morphcat=1 if record_id==18116
replace hx="METASTATIC PROSTATE CANCER" if record_id==18116
replace lat=0 if record_id==18116
replace latcat=0 if record_id==18116
replace beh=3 if record_id==18116
replace grade=9 if record_id==18116
replace basis=0 if record_id==18116
replace dot=dod if record_id==18116
replace dotyear=year(dot) if record_id==18116
replace dxyr=2015 if record_id==18116
replace ICD10="C61" if record_id==18116
replace ICCCcode="12b" if record_id==18116

replace top="189" if record_id==18119
replace topography=189 if record_id==18119
replace topcat=19 if record_id==18119
replace primarysite="COLON" if record_id==18119
replace morphology="8000" if record_id==18119
replace morph=8000 if record_id==18119
replace morphcat=1 if record_id==18119
replace hx="CARCINOMATOSIS OF COLON" if record_id==18119
replace lat=0 if record_id==18119
replace latcat=0 if record_id==18119
replace beh=3 if record_id==18119
replace grade=9 if record_id==18119
replace basis=0 if record_id==18119
replace dot=dod if record_id==18119
replace dotyear=year(dot) if record_id==18119
replace dxyr=2015 if record_id==18119
replace ICD10="C189" if record_id==18119
replace ICCCcode="12b" if record_id==18119

replace top="189" if record_id==18129
replace topography=189 if record_id==18129
replace topcat=19 if record_id==18129
replace primarysite="COLON" if record_id==18129
replace morphology="8000" if record_id==18129
replace morph=8000 if record_id==18129
replace morphcat=1 if record_id==18129
replace hx="LOCALLY ADVANCE COLON CARCINOMA" if record_id==18129
replace lat=0 if record_id==18129
replace latcat=0 if record_id==18129
replace beh=3 if record_id==18129
replace grade=9 if record_id==18129
replace basis=0 if record_id==18129
replace dot=dod if record_id==18129
replace dotyear=year(dot) if record_id==18129
replace dxyr=2015 if record_id==18129
replace ICD10="C189" if record_id==18129
replace ICCCcode="12b" if record_id==18129

replace top="619" if record_id==18132
replace topography=619 if record_id==18132
replace topcat=53 if record_id==18132
replace primarysite="PROSTATE" if record_id==18132
replace morphology="8000" if record_id==18132
replace morph=8000 if record_id==18132
replace morphcat=1 if record_id==18132
replace hx="DISSEMINATED PROSTATE CANCER" if record_id==18132
replace lat=0 if record_id==18132
replace latcat=0 if record_id==18132
replace beh=3 if record_id==18132
replace grade=9 if record_id==18132
replace basis=0 if record_id==18132
replace dot=dod if record_id==18132
replace dotyear=year(dot) if record_id==18132
replace dxyr=2015 if record_id==18132
replace ICD10="C61" if record_id==18132
replace ICCCcode="12b" if record_id==18132

replace top="509" if record_id==18149
replace topography=509 if record_id==18149
replace topcat=43 if record_id==18149
replace primarysite="BREAST" if record_id==18149
replace morphology="8000" if record_id==18149
replace morph=8000 if record_id==18149
replace morphcat=1 if record_id==18149
replace hx="METASTATIC ADENOCARCINOMA OF BREAST" if record_id==18149
replace lat=3 if record_id==18149
replace latcat=31 if record_id==18149
replace beh=3 if record_id==18149
replace grade=9 if record_id==18149
replace basis=0 if record_id==18149
replace dot=dod if record_id==18149
replace dotyear=year(dot) if record_id==18149
replace dxyr=2015 if record_id==18149
replace ICD10="C509" if record_id==18149
replace ICCCcode="12b" if record_id==18149

replace top="619" if record_id==18172
replace topography=619 if record_id==18172
replace topcat=53 if record_id==18172
replace primarysite="PROSTATE" if record_id==18172
replace morphology="8000" if record_id==18172
replace morph=8000 if record_id==18172
replace morphcat=1 if record_id==18172
replace hx="PROSTATE CANCER" if record_id==18172
replace lat=0 if record_id==18172
replace latcat=0 if record_id==18172
replace beh=3 if record_id==18172
replace grade=9 if record_id==18172
replace basis=9 if record_id==18172
replace dot=d(22may2015) if record_id==18172
replace dotyear=year(dot) if record_id==18172
replace dxyr=2015 if record_id==18172
replace ICD10="C61" if record_id==18172
replace ICCCcode="12b" if record_id==18172
replace comments="Trace back: Seen on May 22, 2015 at QEH. Jerry Emtage was physician. Diagnosis of Malignant neoplasm of prostate stated as May 22, 2015. Ward A1- Bed 11." if record_id==18172

replace top="449" if record_id==18183
replace topography=449 if record_id==18183
replace topcat=39 if record_id==18183
replace primarysite="SKIN-99" if record_id==18183
replace morphology="8720" if record_id==18183
replace morph=8720 if record_id==18183
replace morphcat=16 if record_id==18183
replace hx="METASTATIC MALIGNANT MELANOMA" if record_id==18183
replace lat=0 if record_id==18183
replace latcat=0 if record_id==18183
replace beh=3 if record_id==18183
replace grade=9 if record_id==18183
replace basis=7 if record_id==18183
replace dot=d(19aug2014) if record_id==18183
replace dotyear=year(dot) if record_id==18183
replace dxyr=2014 if record_id==18183
replace ICD10="C439" if record_id==18183
replace ICCCcode="11d" if record_id==18183
replace comments="Trace back: Dr M Walrond (general surgery) & Dr S Connell (oncology) QEH. Diagnosis of melanoma was on biopsy performed 19/8/2014 while admitted to ward (QEH histopathology report #14155280) during admission for perforated sigmoid diverticula. Skin lesion was discovered incidentally." if record_id==18183

replace top="169" if record_id==18203
replace topography=169 if record_id==18203
replace topcat=17 if record_id==18203
replace primarysite="STOMACH" if record_id==18203
replace morphology="8000" if record_id==18203
replace morph=8000 if record_id==18203
replace morphcat=1 if record_id==18203
replace hx="CARCINOMA OF STOMACH" if record_id==18203
replace lat=0 if record_id==18203
replace latcat=0 if record_id==18203
replace beh=3 if record_id==18203
replace grade=9 if record_id==18203
replace basis=0 if record_id==18203
replace dot=dod if record_id==18203
replace dotyear=year(dot) if record_id==18203
replace dxyr=2015 if record_id==18203
replace ICD10="C169" if record_id==18203
replace ICCCcode="12b" if record_id==18203

replace top="259" if record_id==18225
replace topography=259 if record_id==18225
replace topcat=26 if record_id==18225
replace primarysite="PANCREAS" if record_id==18225
replace morphology="8000" if record_id==18225
replace morph=8000 if record_id==18225
replace morphcat=1 if record_id==18225
replace hx="METASTATIC PANCREATIC CARCINOMA" if record_id==18225
replace lat=0 if record_id==18225
replace latcat=0 if record_id==18225
replace beh=3 if record_id==18225
replace grade=9 if record_id==18225
replace basis=0 if record_id==18225
replace dot=dod if record_id==18225
replace dotyear=year(dot) if record_id==18225
replace dxyr=2015 if record_id==18225
replace ICD10="C259" if record_id==18225
replace ICCCcode="12b" if record_id==18225

replace top="509" if record_id==18238
replace topography=509 if record_id==18238
replace topcat=43 if record_id==18238
replace primarysite="BREAST" if record_id==18238
replace morphology="8000" if record_id==18238
replace morph=8000 if record_id==18238
replace morphcat=1 if record_id==18238
replace hx="CARCINOMA OF THE BREAST" if record_id==18238
replace lat=3 if record_id==18238
replace latcat=31 if record_id==18238
replace beh=3 if record_id==18238
replace grade=9 if record_id==18238
replace basis=0 if record_id==18238
replace dot=dod if record_id==18238
replace dotyear=year(dot) if record_id==18238
replace dxyr=2015 if record_id==18238
replace ICD10="C509" if record_id==18238
replace ICCCcode="12b" if record_id==18238

replace top="259" if record_id==18267
replace topography=259 if record_id==18267
replace topcat=26 if record_id==18267
replace primarysite="PANCREAS" if record_id==18267
replace morphology="8000" if record_id==18267
replace morph=8000 if record_id==18267
replace morphcat=1 if record_id==18267
replace hx="METASTATIC PANCREATIC CARCINOMA" if record_id==18267
replace lat=0 if record_id==18267
replace latcat=0 if record_id==18267
replace beh=3 if record_id==18267
replace grade=9 if record_id==18267
replace basis=0 if record_id==18267
replace dot=dod if record_id==18267
replace dotyear=year(dot) if record_id==18267
replace dxyr=2015 if record_id==18267
replace ICD10="C259" if record_id==18267
replace ICCCcode="12b" if record_id==18267

replace top="509" if record_id==18270
replace topography=509 if record_id==18270
replace topcat=43 if record_id==18270
replace primarysite="BREAST" if record_id==18270
replace morphology="8000" if record_id==18270
replace morph=8000 if record_id==18270
replace morphcat=1 if record_id==18270
replace hx="ADVANCED METASTATIC CANCER OF THE RIGHT BREAST" if record_id==18270
replace lat=1 if record_id==18270
replace latcat=31 if record_id==18270
replace beh=3 if record_id==18270
replace grade=9 if record_id==18270
replace basis=0 if record_id==18270
replace dot=dod if record_id==18270
replace dotyear=year(dot) if record_id==18270
replace dxyr=2015 if record_id==18270
replace ICD10="C509" if record_id==18270
replace ICCCcode="12b" if record_id==18270

replace top="509" if record_id==18272
replace topography=509 if record_id==18272
replace topcat=43 if record_id==18272
replace primarysite="BREAST" if record_id==18272
replace morphology="8000" if record_id==18272
replace morph=8000 if record_id==18272
replace morphcat=1 if record_id==18272
replace hx="CANCER RIGHT BREAST WITH METASTASTIC SPREAD" if record_id==18272
replace lat=1 if record_id==18272
replace latcat=31 if record_id==18272
replace beh=3 if record_id==18272
replace grade=9 if record_id==18272
replace basis=0 if record_id==18272
replace dot=dod if record_id==18272
replace dotyear=year(dot) if record_id==18272
replace dxyr=2015 if record_id==18272
replace ICD10="C509" if record_id==18272
replace ICCCcode="12b" if record_id==18272

replace top="189" if record_id==18299
replace topography=189 if record_id==18299
replace topcat=19 if record_id==18299
replace primarysite="COLON" if record_id==18299
replace morphology="8000" if record_id==18299
replace morph=8000 if record_id==18299
replace morphcat=1 if record_id==18299
replace hx="METASTATIC CARCINOMA OF THE COLON" if record_id==18299
replace lat=0 if record_id==18299
replace latcat=0 if record_id==18299
replace beh=3 if record_id==18299
replace grade=9 if record_id==18299
replace basis=2 if record_id==18299
replace dot=d(30jun2015) if record_id==18299
replace dotyear=year(dot) if record_id==18299
replace dxyr=2015 if record_id==18299
replace ICD10="C189" if record_id==18299
replace ICCCcode="12b" if record_id==18299
replace comments="Trace back: Dr Oneale called. Stated Pt Dx based on U/S of liver. Not in office to give any evidence." if record_id==18299

replace top="619" if record_id==18304
replace topography=619 if record_id==18304
replace topcat=53 if record_id==18304
replace primarysite="PROSTATE" if record_id==18304
replace morphology="8000" if record_id==18304
replace morph=8000 if record_id==18304
replace morphcat=1 if record_id==18304
replace hx="PROSTATE CANCER" if record_id==18304
replace lat=0 if record_id==18304
replace latcat=0 if record_id==18304
replace beh=3 if record_id==18304
replace grade=9 if record_id==18304
replace basis=0 if record_id==18304
replace dot=dod if record_id==18304
replace dotyear=year(dot) if record_id==18304
replace dxyr=2015 if record_id==18304
replace ICD10="C61" if record_id==18304
replace ICCCcode="12b" if record_id==18304

replace top="169" if record_id==18341
replace topography=169 if record_id==18341
replace topcat=17 if record_id==18341
replace primarysite="STOMACH" if record_id==18341
replace morphology="8000" if record_id==18341
replace morph=8000 if record_id==18341
replace morphcat=1 if record_id==18341
replace hx="CARCINOMA OF STOMACH" if record_id==18341
replace lat=0 if record_id==18341
replace latcat=0 if record_id==18341
replace beh=3 if record_id==18341
replace grade=9 if record_id==18341
replace basis=0 if record_id==18341
replace dot=dod if record_id==18341
replace dotyear=year(dot) if record_id==18341
replace dxyr=2015 if record_id==18341
replace ICD10="C169" if record_id==18341
replace ICCCcode="12b" if record_id==18341

replace top="189" if record_id==18342
replace topography=189 if record_id==18342
replace topcat=19 if record_id==18342
replace primarysite="COLON" if record_id==18342
replace morphology="8000" if record_id==18342
replace morph=8000 if record_id==18342
replace morphcat=1 if record_id==18342
replace hx="ADVANCED METASTATIC COLON CANCER" if record_id==18342
replace lat=0 if record_id==18342
replace latcat=0 if record_id==18342
replace beh=3 if record_id==18342
replace grade=9 if record_id==18342
replace basis=0 if record_id==18342
replace dot=dod if record_id==18342
replace dotyear=year(dot) if record_id==18342
replace dxyr=2015 if record_id==18342
replace ICD10="C189" if record_id==18342
replace ICCCcode="12b" if record_id==18342

replace top="619" if record_id==18375
replace topography=619 if record_id==18375
replace topcat=53 if record_id==18375
replace primarysite="PROSTATE" if record_id==18375
replace morphology="8000" if record_id==18375
replace morph=8000 if record_id==18375
replace morphcat=1 if record_id==18375
replace hx="METASTATIC PROSTATE CANCER" if record_id==18375
replace lat=0 if record_id==18375
replace latcat=0 if record_id==18375
replace beh=3 if record_id==18375
replace grade=9 if record_id==18375
replace basis=9 if record_id==18375
replace dot=d(26jun2015) if record_id==18375
replace dotyear=year(dot) if record_id==18375
replace dxyr=2015 if record_id==18375
replace ICD10="C61" if record_id==18375
replace ICCCcode="12b" if record_id==18375
replace comments="Trace back: June 26, 2015 diagnosis but this seems to have been a endoscopy. He was seen by both surgery and urology. Prostate cancer seems to have been chronic and not the cause for the June admission." if record_id==18375

replace top="220" if record_id==18381
replace topography=220 if record_id==18381
replace topcat=23 if record_id==18381
replace primarysite="LIVER" if record_id==18381
replace morphology="8000" if record_id==18381
replace morph=8000 if record_id==18381
replace morphcat=1 if record_id==18381
replace hx="HEPATOCELLULAR CANCER OF LIVER" if record_id==18381
replace lat=0 if record_id==18381
replace latcat=0 if record_id==18381
replace beh=3 if record_id==18381
replace grade=9 if record_id==18381
replace basis=2 if record_id==18381
replace dot=d(15jul2015) if record_id==18381
replace dotyear=year(dot) if record_id==18381
replace dxyr=2015 if record_id==18381
replace ICD10="C229" if record_id==18381
replace ICCCcode="7c" if record_id==18381
replace comments="Trace back: Have letter from Dr. Dottin. Patient was Dx in 2015. Written copy of CT in July show liver mass. No further investigations seen. Will look for other cases, only case not found was Osward Welch. Dr will provide a copy of information found to be collected at earliest convenience." if record_id==18381

replace top="779" if record_id==18399
replace topography=779 if record_id==18399
replace topcat=69 if record_id==18399
replace primarysite="LYMPH NODE-99" if record_id==18399
replace morphology="9701" if record_id==18399
replace morph=9701 if record_id==18399
replace morphcat=44 if record_id==18399
replace hx="SEZARY SYNDROME" if record_id==18399
replace lat=0 if record_id==18399
replace latcat=0 if record_id==18399
replace beh=3 if record_id==18399
replace grade=5 if record_id==18399
replace basis=0 if record_id==18399
replace dot=dod if record_id==18399
replace dotyear=year(dot) if record_id==18399
replace dxyr=2015 if record_id==18399
replace ICD10="C841" if record_id==18399
replace ICCCcode="2b" if record_id==18399

replace top="180" if record_id==18451
replace topography=180 if record_id==18451
replace topcat=19 if record_id==18451
replace primarysite="COLON-CAECUM" if record_id==18451
replace morphology="8000" if record_id==18451
replace morph=8000 if record_id==18451
replace morphcat=1 if record_id==18451
replace hx="CARCINOMA OF CAECUM" if record_id==18451
replace lat=0 if record_id==18451
replace latcat=0 if record_id==18451
replace beh=3 if record_id==18451
replace grade=9 if record_id==18451
replace basis=0 if record_id==18451
replace dot=dod if record_id==18451
replace dotyear=year(dot) if record_id==18451
replace dxyr=2015 if record_id==18451
replace ICD10="C180" if record_id==18451
replace ICCCcode="12b" if record_id==18451
replace comments="Trace back: Saw Pt for a short while. No info seen. Pt Dx clinically based on lump/ mass noted in (L) right abdomen. Pt too old to be seen for further investigations." if record_id==18451

replace top="349" if record_id==18468
replace topography=349 if record_id==18468
replace topcat=32 if record_id==18468
replace primarysite="LUNG" if record_id==18468
replace morphology="8000" if record_id==18468
replace morph=8000 if record_id==18468
replace morphcat=1 if record_id==18468
replace hx="METASTATIC CANCER PULMONARY" if record_id==18468
replace lat=3 if record_id==18468
replace latcat=13 if record_id==18468
replace beh=3 if record_id==18468
replace grade=9 if record_id==18468
replace basis=0 if record_id==18468
replace dot=dod if record_id==18468
replace dotyear=year(dot) if record_id==18468
replace dxyr=2015 if record_id==18468
replace ICD10="C349" if record_id==18468
replace ICCCcode="12b" if record_id==18468

replace top="259" if record_id==18472
replace topography=259 if record_id==18472
replace topcat=26 if record_id==18472
replace primarysite="PANCREAS" if record_id==18472
replace morphology="8000" if record_id==18472
replace morph=8000 if record_id==18472
replace morphcat=1 if record_id==18472
replace hx="PANCREATIC CARCINOMA" if record_id==18472
replace lat=0 if record_id==18472
replace latcat=0 if record_id==18472
replace beh=3 if record_id==18472
replace grade=9 if record_id==18472
replace basis=0 if record_id==18472
replace dot=dod if record_id==18472
replace dotyear=year(dot) if record_id==18472
replace dxyr=2015 if record_id==18472
replace ICD10="C259" if record_id==18472
replace ICCCcode="12b" if record_id==18472

replace top="189" if record_id==18476
replace topography=189 if record_id==18476
replace topcat=19 if record_id==18476
replace primarysite="COLON" if record_id==18476
replace morphology="8000" if record_id==18476
replace morph=8000 if record_id==18476
replace morphcat=1 if record_id==18476
replace hx="METASTATIC COLON CANCER" if record_id==18476
replace lat=0 if record_id==18476
replace latcat=0 if record_id==18476
replace beh=3 if record_id==18476
replace grade=9 if record_id==18476
replace basis=0 if record_id==18476
replace dot=dod if record_id==18476
replace dotyear=year(dot) if record_id==18476
replace dxyr=2015 if record_id==18476
replace ICD10="C189" if record_id==18476
replace ICCCcode="12b" if record_id==18476

replace top="619" if record_id==18482
replace topography=619 if record_id==18482
replace topcat=53 if record_id==18482
replace primarysite="PROSTATE" if record_id==18482
replace morphology="8000" if record_id==18482
replace morph=8000 if record_id==18482
replace morphcat=1 if record_id==18482
replace hx="CARCINOMA OF THE PROSTATE" if record_id==18482
replace lat=0 if record_id==18482
replace latcat=0 if record_id==18482
replace beh=3 if record_id==18482
replace grade=9 if record_id==18482
replace basis=0 if record_id==18482
replace dot=dod if record_id==18482
replace dotyear=year(dot) if record_id==18482
replace dxyr=2015 if record_id==18482
replace ICD10="C61" if record_id==18482
replace ICCCcode="12b" if record_id==18482

replace top="349" if record_id==18557
replace topography=349 if record_id==18557
replace topcat=32 if record_id==18557
replace primarysite="LUNG" if record_id==18557
replace morphology="8000" if record_id==18557
replace morph=8000 if record_id==18557
replace morphcat=1 if record_id==18557
replace hx="METASTATIC LUNG CARCINOMA" if record_id==18557
replace lat=3 if record_id==18557
replace latcat=13 if record_id==18557
replace beh=3 if record_id==18557
replace grade=9 if record_id==18557
replace basis=0 if record_id==18557
replace dot=dod if record_id==18557
replace dotyear=year(dot) if record_id==18557
replace dxyr=2015 if record_id==18557
replace ICD10="C349" if record_id==18557
replace ICCCcode="12b" if record_id==18557

replace top="509" if record_id==18562
replace topography=509 if record_id==18562
replace topcat=43 if record_id==18562
replace primarysite="BREAST" if record_id==18562
replace morphology="8000" if record_id==18562
replace morph=8000 if record_id==18562
replace morphcat=1 if record_id==18562
replace hx="CANCER OF LEFT BREAST" if record_id==18562
replace lat=2 if record_id==18562
replace latcat=31 if record_id==18562
replace beh=3 if record_id==18562
replace grade=9 if record_id==18562
replace basis=0 if record_id==18562
replace dot=dod if record_id==18562
replace dotyear=year(dot) if record_id==18562
replace dxyr=2015 if record_id==18562
replace ICD10="C509" if record_id==18562
replace ICCCcode="12b" if record_id==18562

replace top="189" if record_id==18567
replace topography=189 if record_id==18567
replace topcat=19 if record_id==18567
replace primarysite="COLON" if record_id==18567
replace morphology="8000" if record_id==18567
replace morph=8000 if record_id==18567
replace morphcat=1 if record_id==18567
replace hx="METASTATIC COLON CANCER" if record_id==18567
replace lat=0 if record_id==18567
replace latcat=0 if record_id==18567
replace beh=3 if record_id==18567
replace grade=9 if record_id==18567
replace basis=0 if record_id==18567
replace dot=dod if record_id==18567
replace dotyear=year(dot) if record_id==18567
replace dxyr=2015 if record_id==18567
replace ICD10="C189" if record_id==18567
replace ICCCcode="12b" if record_id==18567

replace top="699" if record_id==18571
replace topography=699 if record_id==18571
replace topcat=61 if record_id==18571
replace primarysite="RIGHT EYE" if record_id==18571
replace morphology="8000" if record_id==18571
replace morph=8000 if record_id==18571
replace morphcat=1 if record_id==18571
replace hx="CARCINOMA OF RIGHT EYE" if record_id==18571
replace lat=1 if record_id==18571
replace latcat=40 if record_id==18571
replace beh=3 if record_id==18571
replace grade=9 if record_id==18571
replace basis=0 if record_id==18571
replace dot=dod if record_id==18571
replace dotyear=year(dot) if record_id==18571
replace dxyr=2015 if record_id==18571
replace ICD10="C699" if record_id==18571
replace ICCCcode="12b" if record_id==18571

replace top="249" if record_id==18585
replace topography=249 if record_id==18585
replace topcat=25 if record_id==18585
replace primarysite="BILIARY TRACT" if record_id==18585
replace morphology="8000" if record_id==18585
replace morph=8000 if record_id==18585
replace morphcat=1 if record_id==18585
replace hx="CHOLANGIOCARCINOMA" if record_id==18585
replace lat=0 if record_id==18585
replace latcat=0 if record_id==18585
replace beh=3 if record_id==18585
replace grade=9 if record_id==18585
replace basis=0 if record_id==18585
replace dot=dod if record_id==18585
replace dotyear=year(dot) if record_id==18585
replace dxyr=2015 if record_id==18585
replace ICD10="C249" if record_id==18585
replace ICCCcode="12b" if record_id==18585

replace top="619" if record_id==18596
replace topography=619 if record_id==18596
replace topcat=53 if record_id==18596
replace primarysite="PROSTATE" if record_id==18596
replace morphology="8000" if record_id==18596
replace morph=8000 if record_id==18596
replace morphcat=1 if record_id==18596
replace hx="METASTATIC PROSTATE CANCER" if record_id==18596
replace lat=0 if record_id==18596
replace latcat=0 if record_id==18596
replace beh=3 if record_id==18596
replace grade=9 if record_id==18596
replace basis=9 if record_id==18596
replace dot=d(30jun2015) if record_id==18596
replace dotyear=year(dot) if record_id==18596
replace dxyr=2015 if record_id==18596
replace ICD10="C61" if record_id==18596
replace ICCCcode="12b" if record_id==18596
replace comments="Trace back: Provided palliative care for Pt. Pt was referred from GenSurg. Not primary physician, said check notes for primary physician." if record_id==18596

replace top="421" if record_id==18619
replace topography=421 if record_id==18619
replace topcat=38 if record_id==18619
replace primarysite="BONE MARROW" if record_id==18619
replace morphology="9732" if record_id==18619
replace morph=9732 if record_id==18619
replace morphcat=46 if record_id==18619
replace hx="MULTIPLE MYELOMA" if record_id==18619
replace lat=0 if record_id==18619
replace latcat=0 if record_id==18619
replace beh=3 if record_id==18619
replace grade=9 if record_id==18619
replace basis=9 if record_id==18619
replace dot=d(30jun2015) if record_id==18619
replace dotyear=year(dot) if record_id==18619
replace dxyr=2015 if record_id==18619
replace ICD10="C900" if record_id==18619
replace ICCCcode="2b" if record_id==18619
replace comments="Trace back: Dr said the condition was pre-existing, no confimration information given." if record_id==18619

replace top="619" if record_id==18650
replace topography=619 if record_id==18650
replace topcat=53 if record_id==18650
replace primarysite="PROSTATE" if record_id==18650
replace morphology="8000" if record_id==18650
replace morph=8000 if record_id==18650
replace morphcat=1 if record_id==18650
replace hx="METASTATIC PROSTATE CARCINOMA" if record_id==18650
replace lat=0 if record_id==18650
replace latcat=0 if record_id==18650
replace beh=3 if record_id==18650
replace grade=9 if record_id==18650
replace basis=0 if record_id==18650
replace dot=dod if record_id==18650
replace dotyear=year(dot) if record_id==18650
replace dxyr=2015 if record_id==18650
replace ICD10="C61" if record_id==18650
replace ICCCcode="12b" if record_id==18650

replace top="619" if record_id==18693
replace topography=619 if record_id==18693
replace topcat=53 if record_id==18693
replace primarysite="PROSTATE" if record_id==18693
replace morphology="8000" if record_id==18693
replace morph=8000 if record_id==18693
replace morphcat=1 if record_id==18693
replace hx="METASTATIC PROSTATE CARCINOMA" if record_id==18693
replace lat=0 if record_id==18693
replace latcat=0 if record_id==18693
replace beh=3 if record_id==18693
replace grade=9 if record_id==18693
replace basis=0 if record_id==18693
replace dot=dod if record_id==18693
replace dotyear=year(dot) if record_id==18693
replace dxyr=2015 if record_id==18693
replace ICD10="C61" if record_id==18693
replace ICCCcode="12b" if record_id==18693
** Create duplicate observations for MPs in CODs
expand=2 if record_id==18693, gen (dupobs2do15)
replace top="189" if record_id==18693 & dupobs2do15>0
replace topography=189 if record_id==18693 & dupobs2do15>0
replace topcat=19 if record_id==18693 & dupobs2do15>0
replace primarysite="COLON" if record_id==18693 & dupobs2do15>0
replace morphology="8000" if record_id==18693 & dupobs2do15>0
replace morph=8000 if record_id==18693 & dupobs2do15>0
replace morphcat=1 if record_id==18693 & dupobs2do15>0
replace hx="COLON CANCER" if record_id==18693 & dupobs2do15>0
replace lat=0 if record_id==18693 & dupobs2do15>0
replace latcat=0 if record_id==18693 & dupobs2do15>0
replace beh=3 if record_id==18693 & dupobs2do15>0
replace grade=9 if record_id==18693 & dupobs2do15>0
replace basis=1 if record_id==18693 & dupobs2do15>0
replace dot=d(05feb2015) if record_id==18693 & dupobs2do15>0
replace dotyear=year(dot) if record_id==18693 & dupobs2do15>0
replace dxyr=2015 if record_id==18693 & dupobs2do15>0
replace ICD10="C189" if record_id==18693 & dupobs2do15>0
replace ICCCcode="12b" if record_id==18693 & dupobs2do15>0
replace cr5id="T2S1" if record_id==18693 & dupobs2do15>0
replace comments="Trace back: Prostate diagnosis not found. Colon cancer diagnosed seen on Feb 5 2015-clinical." if record_id==18693 & dupobs2do15>0

replace top="169" if record_id==18700
replace topography=169 if record_id==18700
replace topcat=17 if record_id==18700
replace primarysite="STOMACH" if record_id==18700
replace morphology="8000" if record_id==18700
replace morph=8000 if record_id==18700
replace morphcat=1 if record_id==18700
replace hx="METASTATIC GASTRIC CANCER" if record_id==18700
replace lat=0 if record_id==18700
replace latcat=0 if record_id==18700
replace beh=3 if record_id==18700
replace grade=9 if record_id==18700
replace basis=0 if record_id==18700
replace dot=dod if record_id==18700
replace dotyear=year(dot) if record_id==18700
replace dxyr=2015 if record_id==18700
replace ICD10="C169" if record_id==18700
replace ICCCcode="12b" if record_id==18700

replace top="679" if record_id==18707
replace topography=679 if record_id==18707
replace topcat=59 if record_id==18707
replace primarysite="BLADDER" if record_id==18707
replace morphology="8000" if record_id==18707
replace morph=8000 if record_id==18707
replace morphcat=1 if record_id==18707
replace hx="CARCINOMA BLADDER WITH METASTASES TO LIVER" if record_id==18707
replace lat=0 if record_id==18707
replace latcat=0 if record_id==18707
replace beh=3 if record_id==18707
replace grade=9 if record_id==18707
replace basis=0 if record_id==18707
replace dot=dod if record_id==18707
replace dotyear=year(dot) if record_id==18707
replace dxyr=2015 if record_id==18707
replace ICD10="C679" if record_id==18707
replace ICCCcode="12b" if record_id==18707

replace top="269" if record_id==18710
replace topography=269 if record_id==18710
replace topcat=27 if record_id==18710
replace primarysite="GASTROINTESTINAL TRACT" if record_id==18710
replace morphology="8000" if record_id==18710
replace morph=8000 if record_id==18710
replace morphcat=1 if record_id==18710
replace hx="GASTRO INTESTINAL STROMAL TUMOUR WITH METASTASES" if record_id==18710
replace lat=0 if record_id==18710
replace latcat=0 if record_id==18710
replace beh=3 if record_id==18710
replace grade=9 if record_id==18710
replace basis=0 if record_id==18710
replace dot=dod if record_id==18710
replace dotyear=year(dot) if record_id==18710
replace dxyr=2015 if record_id==18710
replace ICD10="C269" if record_id==18710
replace ICCCcode="12b" if record_id==18710

replace top="619" if record_id==18730
replace topography=619 if record_id==18730
replace topcat=53 if record_id==18730
replace primarysite="PROSTATE" if record_id==18730
replace morphology="8000" if record_id==18730
replace morph=8000 if record_id==18730
replace morphcat=1 if record_id==18730
replace hx="CARCINOMA OF THE PROSTATE" if record_id==18730
replace lat=0 if record_id==18730
replace latcat=0 if record_id==18730
replace beh=3 if record_id==18730
replace grade=9 if record_id==18730
replace basis=0 if record_id==18730
replace dot=dod if record_id==18730
replace dotyear=year(dot) if record_id==18730
replace dxyr=2015 if record_id==18730
replace ICD10="C61" if record_id==18730
replace ICCCcode="12b" if record_id==18730

replace top="619" if record_id==18744
replace topography=619 if record_id==18744
replace topcat=53 if record_id==18744
replace primarysite="PROSTATE" if record_id==18744
replace morphology="8000" if record_id==18744
replace morph=8000 if record_id==18744
replace morphcat=1 if record_id==18744
replace hx="PROSTATE CANCER" if record_id==18744
replace lat=0 if record_id==18744
replace latcat=0 if record_id==18744
replace beh=3 if record_id==18744
replace grade=9 if record_id==18744
replace basis=9 if record_id==18744
replace dot=d(30jun2014) if record_id==18744
replace dotyear=year(dot) if record_id==18744
replace dxyr=2014 if record_id==18744
replace ICD10="C61" if record_id==18744
replace ICCCcode="12b" if record_id==18744
replace comments="Trace back: Known to have PC in 2014-being treated for same. Not sure when diagnosed." if record_id==18744

replace top="259" if record_id==18746
replace topography=259 if record_id==18746
replace topcat=26 if record_id==18746
replace primarysite="PANCREAS" if record_id==18746
replace morphology="8000" if record_id==18746
replace morph=8000 if record_id==18746
replace morphcat=1 if record_id==18746
replace hx="PANCREATIC CARCINOMA" if record_id==18746
replace lat=0 if record_id==18746
replace latcat=0 if record_id==18746
replace beh=3 if record_id==18746
replace grade=9 if record_id==18746
replace basis=2 if record_id==18746
replace dot=d(21mar2015) if record_id==18746
replace dotyear=year(dot) if record_id==18746
replace dxyr=2015 if record_id==18746
replace ICD10="C259" if record_id==18746
replace ICCCcode="12b" if record_id==18746
replace comments="Trace back: Dr. M O'Shea QEH. Admitted Ward A2 March 2015 and I believe this is date of diagnosis. Likely a clinical diagnosis but high CA19-9 21st/3/2015 very suggestive of pancreatuc ca. Likely had supportive CT imaging." if record_id==18746

replace top="619" if record_id==18801
replace topography=619 if record_id==18801
replace topcat=53 if record_id==18801
replace primarysite="PROSTATE" if record_id==18801
replace morphology="8000" if record_id==18801
replace morph=8000 if record_id==18801
replace morphcat=1 if record_id==18801
replace hx="METASTATIC CARCINOMA OF THE PROSTATE" if record_id==18801
replace lat=0 if record_id==18801
replace latcat=0 if record_id==18801
replace beh=3 if record_id==18801
replace grade=9 if record_id==18801
replace basis=5 if record_id==18801
replace dot=d(15jul2013) if record_id==18801
replace dotyear=year(dot) if record_id==18801
replace dxyr=2013 if record_id==18801
replace ICD10="C61" if record_id==18801
replace ICCCcode="12b" if record_id==18801
replace rx1=5 if record_id==18801
replace rx1d=d(15jul2013) if record_id==18801
replace comments="Trace back: Pt Dx July 2013. No bx done because of age. Presented with PSA 68.8. Had abnormal LFT. Referred to Dr. Emtage was given Androcur. PSA wen from 68.8 to 2.6 on medication. Dx based on lab results." if record_id==18801

replace top="509" if record_id==18805
replace topography=509 if record_id==18805
replace topcat=43 if record_id==18805
replace primarysite="BREAST" if record_id==18805
replace morphology="8000" if record_id==18805
replace morph=8000 if record_id==18805
replace morphcat=1 if record_id==18805
replace hx="CANCER OF BREAST" if record_id==18805
replace lat=3 if record_id==18805
replace latcat=31 if record_id==18805
replace beh=3 if record_id==18805
replace grade=9 if record_id==18805
replace basis=0 if record_id==18805
replace dot=dod if record_id==18805
replace dotyear=year(dot) if record_id==18805
replace dxyr=2015 if record_id==18805
replace ICD10="C509" if record_id==18805
replace ICCCcode="12b" if record_id==18805

replace top="259" if record_id==18818
replace topography=259 if record_id==18818
replace topcat=26 if record_id==18818
replace primarysite="PANCREAS" if record_id==18818
replace morphology="8000" if record_id==18818
replace morph=8000 if record_id==18818
replace morphcat=1 if record_id==18818
replace hx="CARCINOMA PANCREAS" if record_id==18818
replace lat=0 if record_id==18818
replace latcat=0 if record_id==18818
replace beh=3 if record_id==18818
replace grade=9 if record_id==18818
replace basis=0 if record_id==18818
replace dot=dod if record_id==18818
replace dotyear=year(dot) if record_id==18818
replace dxyr=2015 if record_id==18818
replace ICD10="C259" if record_id==18818
replace ICCCcode="12b" if record_id==18818

replace top="619" if record_id==18834
replace topography=619 if record_id==18834
replace topcat=53 if record_id==18834
replace primarysite="PROSTATE" if record_id==18834
replace morphology="8000" if record_id==18834
replace morph=8000 if record_id==18834
replace morphcat=1 if record_id==18834
replace hx="PROSTATE CANCER" if record_id==18834
replace lat=0 if record_id==18834
replace latcat=0 if record_id==18834
replace beh=3 if record_id==18834
replace grade=9 if record_id==18834
replace basis=0 if record_id==18834
replace dot=dod if record_id==18834
replace dotyear=year(dot) if record_id==18834
replace dxyr=2015 if record_id==18834
replace ICD10="C61" if record_id==18834
replace ICCCcode="12b" if record_id==18834

replace top="509" if record_id==18835
replace topography=509 if record_id==18835
replace topcat=43 if record_id==18835
replace primarysite="BREAST" if record_id==18835
replace morphology="8000" if record_id==18835
replace morph=8000 if record_id==18835
replace morphcat=1 if record_id==18835
replace hx="CARCINOMA OF THE RIGHT BREAST" if record_id==18835
replace lat=1 if record_id==18835
replace latcat=31 if record_id==18835
replace beh=3 if record_id==18835
replace grade=9 if record_id==18835
replace basis=0 if record_id==18835
replace dot=dod if record_id==18835
replace dotyear=year(dot) if record_id==18835
replace dxyr=2015 if record_id==18835
replace ICD10="C509" if record_id==18835
replace ICCCcode="12b" if record_id==18835

replace top="490" if record_id==18849
replace topography=490 if record_id==18849
replace topcat=42 if record_id==18849
replace primarysite="NECK" if record_id==18849
replace morphology="8850" if record_id==18849
replace morph=8850 if record_id==18849
replace morphcat=20 if record_id==18849
replace hx="LIPOSARCOMA OF NECK" if record_id==18849
replace lat=0 if record_id==18849
replace latcat=0 if record_id==18849
replace beh=3 if record_id==18849
replace grade=9 if record_id==18849
replace basis=0 if record_id==18849
replace dot=dod if record_id==18849
replace dotyear=year(dot) if record_id==18849
replace dxyr=2015 if record_id==18849
replace ICD10="C490" if record_id==18849
replace ICCCcode="9d" if record_id==18849

replace top="649" if record_id==18854
replace topography=649 if record_id==18854
replace topcat=56 if record_id==18854
replace primarysite="KIDNEY" if record_id==18854
replace morphology="8312" if record_id==18854
replace morph=8312 if record_id==18854
replace morphcat=6 if record_id==18854
replace hx="METASTATIC RENAL CELL CARCINOMA" if record_id==18854
replace lat=3 if record_id==18854
replace latcat=37 if record_id==18854
replace beh=3 if record_id==18854
replace grade=9 if record_id==18854
replace basis=0 if record_id==18854
replace dot=dod if record_id==18854
replace dotyear=year(dot) if record_id==18854
replace dxyr=2015 if record_id==18854
replace ICD10="C64" if record_id==18854
replace ICCCcode="6b" if record_id==18854

replace top="619" if record_id==18863
replace topography=619 if record_id==18863
replace topcat=53 if record_id==18863
replace primarysite="PROSTATE" if record_id==18863
replace morphology="8000" if record_id==18863
replace morph=8000 if record_id==18863
replace morphcat=1 if record_id==18863
replace hx="PROSTATIC CANCER" if record_id==18863
replace lat=0 if record_id==18863
replace latcat=0 if record_id==18863
replace beh=3 if record_id==18863
replace grade=9 if record_id==18863
replace basis=0 if record_id==18863
replace dot=dod if record_id==18863
replace dotyear=year(dot) if record_id==18863
replace dxyr=2015 if record_id==18863
replace ICD10="C61" if record_id==18863
replace ICCCcode="12b" if record_id==18863

replace top="679" if record_id==18892
replace topography=679 if record_id==18892
replace topcat=59 if record_id==18892
replace primarysite="BLADDER" if record_id==18892
replace morphology="8000" if record_id==18892
replace morph=8000 if record_id==18892
replace morphcat=1 if record_id==18892
replace hx="BLADDER CANCER" if record_id==18892
replace lat=0 if record_id==18892
replace latcat=0 if record_id==18892
replace beh=3 if record_id==18892
replace grade=9 if record_id==18892
replace basis=0 if record_id==18892
replace dot=dod if record_id==18892
replace dotyear=year(dot) if record_id==18892
replace dxyr=2015 if record_id==18892
replace ICD10="C679" if record_id==18892
replace ICCCcode="12b" if record_id==18892

replace top="619" if record_id==18943
replace topography=619 if record_id==18943
replace topcat=53 if record_id==18943
replace primarysite="PROSTATE" if record_id==18943
replace morphology="8000" if record_id==18943
replace morph=8000 if record_id==18943
replace morphcat=1 if record_id==18943
replace hx="PROSTATE CARCINOMA" if record_id==18943
replace lat=0 if record_id==18943
replace latcat=0 if record_id==18943
replace beh=3 if record_id==18943
replace grade=9 if record_id==18943
replace basis=0 if record_id==18943
replace dot=dod if record_id==18943
replace dotyear=year(dot) if record_id==18943
replace dxyr=2015 if record_id==18943
replace ICD10="C61" if record_id==18943
replace ICCCcode="12b" if record_id==18943

replace top="509" if record_id==18945
replace topography=509 if record_id==18945
replace topcat=43 if record_id==18945
replace primarysite="BREAST" if record_id==18945
replace morphology="8000" if record_id==18945
replace morph=8000 if record_id==18945
replace morphcat=1 if record_id==18945
replace hx="STAGE 4 BREAST CANCER" if record_id==18945
replace lat=3 if record_id==18945
replace latcat=31 if record_id==18945
replace beh=3 if record_id==18945
replace grade=9 if record_id==18945
replace basis=0 if record_id==18945
replace dot=dod if record_id==18945
replace dotyear=year(dot) if record_id==18945
replace dxyr=2015 if record_id==18945
replace ICD10="C509" if record_id==18945
replace ICCCcode="12b" if record_id==18945

replace top="189" if record_id==18950
replace topography=189 if record_id==18950
replace topcat=19 if record_id==18950
replace primarysite="COLON" if record_id==18950
replace morphology="8000" if record_id==18950
replace morph=8000 if record_id==18950
replace morphcat=1 if record_id==18950
replace hx="METASTATIC COLONIC CARCINOMA" if record_id==18950
replace lat=0 if record_id==18950
replace latcat=0 if record_id==18950
replace beh=3 if record_id==18950
replace grade=9 if record_id==18950
replace basis=0 if record_id==18950
replace dot=dod if record_id==18950
replace dotyear=year(dot) if record_id==18950
replace dxyr=2015 if record_id==18950
replace ICD10="C189" if record_id==18950
replace ICCCcode="12b" if record_id==18950

replace top="539" if record_id==18963
replace topography=539 if record_id==18963
replace topcat=46 if record_id==18963
replace primarysite="CERVIX" if record_id==18963
replace morphology="8000" if record_id==18963
replace morph=8000 if record_id==18963
replace morphcat=1 if record_id==18963
replace hx="ADVANCED CANCER CERVIX" if record_id==18963
replace lat=0 if record_id==18963
replace latcat=0 if record_id==18963
replace beh=3 if record_id==18963
replace grade=9 if record_id==18963
replace basis=9 if record_id==18963
replace dot=d(06nov2015) if record_id==18963
replace dotyear=year(dot) if record_id==18963
replace dxyr=2015 if record_id==18963
replace ICD10="C539" if record_id==18963
replace ICCCcode="12b" if record_id==18963
replace comments="Trace back: last seen QEH Nov 6, 2015. Malignant neoplasm cervix uteri. CHECK RT." if record_id==18963

replace top="189" if record_id==18987
replace topography=189 if record_id==18987
replace topcat=19 if record_id==18987
replace primarysite="COLON" if record_id==18987
replace morphology="8000" if record_id==18987
replace morph=8000 if record_id==18987
replace morphcat=1 if record_id==18987
replace hx="METASTATIC COLON CANCER" if record_id==18987
replace lat=0 if record_id==18987
replace latcat=0 if record_id==18987
replace beh=3 if record_id==18987
replace grade=9 if record_id==18987
replace basis=0 if record_id==18987
replace dot=dod if record_id==18987
replace dotyear=year(dot) if record_id==18987
replace dxyr=2015 if record_id==18987
replace ICD10="C189" if record_id==18987
replace ICCCcode="12b" if record_id==18987

replace top="809" if record_id==18989
replace topography=809 if record_id==18989
replace topcat=70 if record_id==18989
replace primarysite="99" if record_id==18989
replace morphology="8000" if record_id==18989
replace morph=8000 if record_id==18989
replace morphcat=1 if record_id==18989
replace hx="OCCULT MALIGNANCY" if record_id==18989
replace lat=0 if record_id==18989
replace latcat=0 if record_id==18989
replace beh=3 if record_id==18989
replace grade=9 if record_id==18989
replace basis=0 if record_id==18989
replace dot=dod if record_id==18989
replace dotyear=year(dot) if record_id==18989
replace dxyr=2015 if record_id==18989
replace ICD10="C80" if record_id==18989
replace ICCCcode="12b" if record_id==18989

replace top="809" if record_id==19018
replace topography=809 if record_id==19018
replace topcat=70 if record_id==19018
replace primarysite="99" if record_id==19018
replace morphology="8000" if record_id==19018
replace morph=8000 if record_id==19018
replace morphcat=1 if record_id==19018
replace hx="METASTATIC CANCER PRIMARY UNKNOWN" if record_id==19018
replace lat=0 if record_id==19018
replace latcat=0 if record_id==19018
replace beh=3 if record_id==19018
replace grade=9 if record_id==19018
replace basis=0 if record_id==19018
replace dot=dod if record_id==19018
replace dotyear=year(dot) if record_id==19018
replace dxyr=2015 if record_id==19018
replace ICD10="C80" if record_id==19018
replace ICCCcode="12b" if record_id==19018

replace top="569" if record_id==19023
replace topography=569 if record_id==19023
replace topcat=49 if record_id==19023
replace primarysite="OVARY" if record_id==19023
replace morphology="8000" if record_id==19023
replace morph=8000 if record_id==19023
replace morphcat=1 if record_id==19023
replace hx="METASTATIC OVARIAN CANCER" if record_id==19023
replace lat=9 if record_id==19023
replace latcat=32 if record_id==19023
replace beh=3 if record_id==19023
replace grade=9 if record_id==19023
replace basis=0 if record_id==19023
replace dot=dod if record_id==19023
replace dotyear=year(dot) if record_id==19023
replace dxyr=2015 if record_id==19023
replace ICD10="C56" if record_id==19023
replace ICCCcode="10e" if record_id==19023

replace top="421" if record_id==19062
replace topography=421 if record_id==19062
replace topcat=38 if record_id==19062
replace primarysite="BONE MARROW" if record_id==19062
replace morphology="9732" if record_id==19062
replace morph=9732 if record_id==19062
replace morphcat=46 if record_id==19062
replace hx="MULTIPLE MYELOMA" if record_id==19062
replace lat=0 if record_id==19062
replace latcat=0 if record_id==19062
replace beh=3 if record_id==19062
replace grade=9 if record_id==19062
replace basis=0 if record_id==19062
replace dot=dod if record_id==19062
replace dotyear=year(dot) if record_id==19062
replace dxyr=2015 if record_id==19062
replace ICD10="C900" if record_id==19062
replace ICCCcode="2b" if record_id==19062

replace top="619" if record_id==19077
replace topography=619 if record_id==19077
replace topcat=53 if record_id==19077
replace primarysite="PROSTATE" if record_id==19077
replace morphology="8000" if record_id==19077
replace morph=8000 if record_id==19077
replace morphcat=1 if record_id==19077
replace hx="PROSTATE CANCER" if record_id==19077
replace lat=0 if record_id==19077
replace latcat=0 if record_id==19077
replace beh=3 if record_id==19077
replace grade=9 if record_id==19077
replace basis=0 if record_id==19077
replace dot=dod if record_id==19077
replace dotyear=year(dot) if record_id==19077
replace dxyr=2015 if record_id==19077
replace ICD10="C61" if record_id==19077
replace ICCCcode="12b" if record_id==19077

replace top="809" if record_id==19107
replace topography=809 if record_id==19107
replace topcat=70 if record_id==19107
replace primarysite="99" if record_id==19107
replace morphology="8000" if record_id==19107
replace morph=8000 if record_id==19107
replace morphcat=1 if record_id==19107
replace hx="METASTATIC GASTRO-INTESTINAL, MALIGNANCY-UNKNOWN PRIMARY" if record_id==19107
replace lat=0 if record_id==19107
replace latcat=0 if record_id==19107
replace beh=3 if record_id==19107
replace grade=9 if record_id==19107
replace basis=0 if record_id==19107
replace dot=dod if record_id==19107
replace dotyear=year(dot) if record_id==19107
replace dxyr=2015 if record_id==19107
replace ICD10="C80" if record_id==19107
replace ICCCcode="12b" if record_id==19107

replace top="421" if record_id==19135
replace topography=421 if record_id==19135
replace topcat=38 if record_id==19135
replace primarysite="BONE MARROW" if record_id==19135
replace morphology="9732" if record_id==19135
replace morph=9732 if record_id==19135
replace morphcat=46 if record_id==19135
replace hx="MULTIPLE MYELOMA" if record_id==19135
replace lat=0 if record_id==19135
replace latcat=0 if record_id==19135
replace beh=3 if record_id==19135
replace grade=9 if record_id==19135
replace basis=0 if record_id==19135
replace dot=dod if record_id==19135
replace dotyear=year(dot) if record_id==19135
replace dxyr=2015 if record_id==19135
replace ICD10="C900" if record_id==19135
replace ICCCcode="2b" if record_id==19135

replace top="169" if record_id==19149
replace topography=169 if record_id==19149
replace topcat=17 if record_id==19149
replace primarysite="STOMACH" if record_id==19149
replace morphology="8000" if record_id==19149
replace morph=8000 if record_id==19149
replace morphcat=1 if record_id==19149
replace hx="CANCER OF STOMACH" if record_id==19149
replace lat=0 if record_id==19149
replace latcat=0 if record_id==19149
replace beh=3 if record_id==19149
replace grade=9 if record_id==19149
replace basis=0 if record_id==19149
replace dot=dod if record_id==19149
replace dotyear=year(dot) if record_id==19149
replace dxyr=2015 if record_id==19149
replace ICD10="C169" if record_id==19149
replace ICCCcode="12b" if record_id==19149

replace top="509" if record_id==19210
replace topography=509 if record_id==19210
replace topcat=43 if record_id==19210
replace primarysite="BREAST" if record_id==19210
replace morphology="8000" if record_id==19210
replace morph=8000 if record_id==19210
replace morphcat=1 if record_id==19210
replace hx="BREAST CANCER, RIGHT BREAST" if record_id==19210
replace lat=1 if record_id==19210
replace latcat=31 if record_id==19210
replace beh=3 if record_id==19210
replace grade=9 if record_id==19210
replace basis=0 if record_id==19210
replace dot=dod if record_id==19210
replace dotyear=year(dot) if record_id==19210
replace dxyr=2015 if record_id==19210
replace ICD10="C509" if record_id==19210
replace ICCCcode="12b" if record_id==19210

replace top="619" if record_id==19230
replace topography=619 if record_id==19230
replace topcat=53 if record_id==19230
replace primarysite="PROSTATE" if record_id==19230
replace morphology="8000" if record_id==19230
replace morph=8000 if record_id==19230
replace morphcat=1 if record_id==19230
replace hx="PROSTATE CANCER" if record_id==19230
replace lat=0 if record_id==19230
replace latcat=0 if record_id==19230
replace beh=3 if record_id==19230
replace grade=9 if record_id==19230
replace basis=0 if record_id==19230
replace dot=dod if record_id==19230
replace dotyear=year(dot) if record_id==19230
replace dxyr=2015 if record_id==19230
replace ICD10="C61" if record_id==19230
replace ICCCcode="12b" if record_id==19230

replace top="209" if record_id==19245
replace topography=209 if record_id==19245
replace topcat=21 if record_id==19245
replace primarysite="RECTUM" if record_id==19245
replace morphology="8000" if record_id==19245
replace morph=8000 if record_id==19245
replace morphcat=1 if record_id==19245
replace hx="RECTAL CANCER" if record_id==19245
replace lat=0 if record_id==19245
replace latcat=0 if record_id==19245
replace beh=3 if record_id==19245
replace grade=9 if record_id==19245
replace basis=1 if record_id==19245
replace dot=d(30oct2015) if record_id==19245
replace dotyear=year(dot) if record_id==19245
replace dxyr=2015 if record_id==19245
replace ICD10="C20" if record_id==19245
replace ICCCcode="12b" if record_id==19245
replace comments="Trace back: Clinical diagnosis made by Dr J Herbert 30/10/2015 with discovery of large rectal mass on examination of an elderly lady with constipation, and  rapid & progressive weight loss, cognitive impairment and declining function. She had a normal ultrasound 3 years prior, ordered by Dr R Delice. Her carers suspected vaginal bleeding but its my judgement this was from the low rectal lesion based on her examination findings. No furthe rimaging or biopsy was obtained as her treatmnet was strictly palliative." if record_id==19245

replace top="349" if record_id==19246
replace topography=349 if record_id==19246
replace topcat=32 if record_id==19246
replace primarysite="LUNG" if record_id==19246
replace morphology="8000" if record_id==19246
replace morph=8000 if record_id==19246
replace morphcat=1 if record_id==19246
replace hx="LUNG CANCER" if record_id==19246
replace lat=3 if record_id==19246
replace latcat=13 if record_id==19246
replace beh=3 if record_id==19246
replace grade=9 if record_id==19246
replace basis=0 if record_id==19246
replace dot=dod if record_id==19246
replace dotyear=year(dot) if record_id==19246
replace dxyr=2015 if record_id==19246
replace ICD10="C349" if record_id==19246
replace ICCCcode="12b" if record_id==19246

replace top="619" if record_id==19256
replace topography=619 if record_id==19256
replace topcat=53 if record_id==19256
replace primarysite="PROSTATE" if record_id==19256
replace morphology="8000" if record_id==19256
replace morph=8000 if record_id==19256
replace morphcat=1 if record_id==19256
replace hx="CARCINOMA OF PROSTATE" if record_id==19256
replace lat=0 if record_id==19256
replace latcat=0 if record_id==19256
replace beh=3 if record_id==19256
replace grade=9 if record_id==19256
replace basis=0 if record_id==19256
replace dot=dod if record_id==19256
replace dotyear=year(dot) if record_id==19256
replace dxyr=2015 if record_id==19256
replace ICD10="C61" if record_id==19256
replace ICCCcode="12b" if record_id==19256

replace top="619" if record_id==19278
replace topography=619 if record_id==19278
replace topcat=53 if record_id==19278
replace primarysite="PROSTATE" if record_id==19278
replace morphology="8000" if record_id==19278
replace morph=8000 if record_id==19278
replace morphcat=1 if record_id==19278
replace hx="CARCINOMA OF PROSTATE" if record_id==19278
replace lat=0 if record_id==19278
replace latcat=0 if record_id==19278
replace beh=3 if record_id==19278
replace grade=9 if record_id==19278
replace basis=0 if record_id==19278
replace dot=dod if record_id==19278
replace dotyear=year(dot) if record_id==19278
replace dxyr=2015 if record_id==19278
replace ICD10="C61" if record_id==19278
replace ICCCcode="12b" if record_id==19278


sort pid cr5id lname fname
quietly by pid cr5id :  gen duppidcr5id = cond(_N==1,0,_n)
sort pid cr5id
count if duppidcr5id>0 //31 - incidentally found incorrect cr5ids
sort pid record_id lname fname
//list pid cr5id record_id fname lname age dd_age natregno dd_natregno addr dd_address if duppidcr5id>0, string(30)

** Corrections to cr5id
replace cr5id="T1S2" if pid=="20150136" & nftype==9 //1 change
replace cr5id="T1S2" if pid=="20150322" & nftype==8 //1 change
replace cr5id="T1S2" if pid=="20150502" & stda==99 //1 change
replace cr5id="T1S2" if pid=="20151070" & nftype==10 //1 change
replace cr5id="T1S2" if pid=="20151361" & nftype==9 //1 change

** Remove duplicate obs caused by merge
drop if pid=="20150379" & record_id==22987|pid=="20150481" & record_id==26256|pid=="20155073" & record_id==23565|pid=="20155142" & record_id==19125|pid=="20155142" & record_id==19461|pid=="20155142" & record_id==19415|pid=="20155144" & record_id==24357|pid=="20155152" & record_id==22722|pid=="20155203" & record_id==26300|pid=="20155203" & record_id==22825|pid=="20155226" & record_id==18360|pid=="20155245" & record_id==24594 //12 deleted
count if record_id!=. & dd_dod==. //44
replace record_id=. if record_id!=. & dd_dod==. //44 changes

count //2035

label data "BNR-C data 2015 matched"
notes _dta :These data prepared from CanReg5 CLEAN (2015BNR-C) database
save "`datapath'\version02\2-working\2015_cancer_dups_matched" ,replace
note: TS This dataset can be used for assessing number of sources per record


*****************************
** Identifying & Labelling **
** 		  Duplicate		   **
**	 Tumours and Sources   **
*****************************

sort pid cr5id lname fname
quietly by pid :  gen dupst = cond(_N==1,0,_n)
sort pid cr5id
count if dupst>0 //1627; 1646
sort pid record_id lname fname
//list pid cr5id dupst ,sepby(pid)
//list pid cr5id dupst checkstatus recstatus top if dupst>0

/* 
Each multiple sources from CR5 dataset is imported into Stata as 
a separate observation and some tumour records are multiple sources for the abstracted tumour
so need to differentiate between 
multiple (duplicate) sources (MSs) for same pt vs multiple (primary) tumours (MPs) for same pt:
(1) The MSs will assessed for data quality index then dropped before death merge;
(2) The MPs will be kept throughout datasets.
*/
sort pid cr5id
gen dupsource=0 //
label var dupsource "Multiple Sources"
label define dupsource_lab  1 "MS-Conf Tumour Rec" 2 "MS-Conf Source Rec" ///
							3 "MS-Dup Tumour Rec" 4 "MS-Dup Tumour & Source Rec" ///
							5 "MS-Ineligible Tumour 1 Rec" 6 "MS-Ineligible Tumour 2~ & Source Rec" , modify
label values dupsource dupsource_lab

replace dupsource=1 if recstatus==1 & regexm(cr5id,"S1") //980; 1137 confirmed - this is the # eligible non-duplicate tumours
replace dupsource=2 if recstatus==1 & !strmatch(strupper(cr5id), "*S1") //822; 824 - confirmed
replace dupsource=3 if recstatus==4 & regexm(cr5id,"S1") //106 - duplicate
replace dupsource=4 if recstatus==4 & !strmatch(strupper(cr5id), "*S1") //7 - duplicate
replace dupsource=5 if recstatus==3 & cr5id=="T1S1" //88 - ineligible
replace dupsource=6 if recstatus==3 & cr5id!="T1S1" //32 - duplicate

** Now identify MPs (multiple tumours for same pt) among eligible non-duplicate tumours (978)
//tab pid if dupsource==1

drop duppid
sort pid
bysort pid: gen duppid = _n if dupsource==1 //980 - _n gives sequence id for each pid that appears in dataset

sort pid cr5id
bysort pid: gen duppid_all = _n //_N give total count for each pid that is duplicated in dataset

tab duppid_all ,m
/*
 duppid_all |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |      1,054       51.79       51.79
          2 |        646       31.74       83.54
          3 |        262       12.87       96.41
          4 |         57        2.80       99.21
          5 |         12        0.59       99.80
          6 |          2        0.10       99.90
          7 |          1        0.05       99.95
          8 |          1        0.05      100.00
------------+-----------------------------------
      Total |      2,035      100.00

 duppid_all |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |      1,201       54.74       54.74
          2 |        653       29.76       84.50
          3 |        265       12.08       96.58
          4 |         58        2.64       99.23
          5 |         13        0.59       99.82
          6 |          2        0.09       99.91
          7 |          1        0.05       99.95
          8 |          1        0.05      100.00
------------+-----------------------------------
      Total |      2,194      100.00
*/

count if recstatus==1 & cr5id=="T1S1" //939; 1096
count if recstatus==1 & cr5id=="T2S1" //37; 39
//list pid cr5id fname lname recstatus persearch duppid duppid_all if recstatus==1 & cr5id=="T2S1"

** Update persearch based on above data - note for 2015 single dataset MPs from different years count as single tumours
** For multi-year dataset (2008-2015) persearch will be assigned according to all years so MPs will be included then
** i.e. reporting MPs within single year vs MPs throughout all years
replace persearch=1 if pid=="20080048" & cr5id=="T2S1" //2015 MP; 2008 prim
replace persearch=1 if pid=="20080336" & cr5id=="T2S1" //2015 MP; 2008 prim
replace persearch=1 if pid=="20080567" & cr5id=="T2S1" //2015 MP; 2008 prim
replace persearch=1 if pid=="20080679" & cr5id=="T2S1" //2015 MP; 2008 prim
replace persearch=1 if pid=="20081085" & cr5id=="T2S1" //2015 MP; 2008 prim
replace persearch=1 if pid=="20130410" & cr5id=="T2S1" //2015 MP; 2013 prim
replace persearch=3 if pid=="20130648" & cr5id=="T2S1" //2013 prim with dup 2015 source
replace persearch=1 if pid=="20130885" & cr5id=="T2S1" //2015 MP; 2013 prim
replace persearch=1 if pid=="20140822" & cr5id=="T2S1" //2015 MP; 2014 prim
replace persearch=1 if pid=="20141258" & cr5id=="T2S1" //2015 MP; 2013 ineligible prim
replace persearch=1 if pid=="20141288" & cr5id=="T2S1" //2015 MP; 2014 prim
replace persearch=1 if pid=="20141379" & cr5id=="T2S1" //2015 MP; 2014 prim
replace persearch=1 if pid=="20141409" & cr5id=="T2S1" //2015 prim with T1 dup 2015 source
replace persearch=3 if pid=="20141409" & cr5id=="T1S1" //2015 prim with T1 dup 2015 source
replace dot=d(20aug2014) if pid=="20141409" & cr5id=="T2S1" //2014 path rpt suspicious for invasion
replace dxyr=2014 if pid=="20141409"
replace persearch=1 if pid=="20145070" & cr5id=="T2S1" //2015 MP; 2014 prim
replace persearch=1 if pid=="20150169" & cr5id=="T2S1" //2015 prim with T1 dup 2015 source
replace persearch=3 if pid=="20150169" & cr5id=="T1S1" //2015 prim with T1 dup 2015 source
replace persearch=1 if pid=="20150234" & cr5id=="T2S1" //2015 prim with T1 dup 2015 source
replace persearch=3 if pid=="20150234" & cr5id=="T1S1" //2015 prim with T1 dup 2015 source
replace persearch=2 if pid=="20150238" & cr5id=="T2S1" //2015 prim; 2015 MP
replace persearch=1 if pid=="20150238" & cr5id=="T1S1" //2015 prim; 2015 MP
replace persearch=2 if pid=="20150277" & cr5id=="T2S1" //2015 prim; 2015 MP
replace persearch=1 if pid=="20150277" & cr5id=="T1S1" //2015 prim; 2015 MP
replace persearch=1 if pid=="20150314" & cr5id=="T2S1" //2015 prim with T1 dup 2015 source
replace persearch=3 if pid=="20150314" & cr5id=="T1S1" //2015 prim with T1 dup 2015 source
replace persearch=4 if pid=="20150341" & cr5id=="T2S1" //2015 breast prims
replace persearch=1 if pid=="20150341" & cr5id=="T1S1" //2015 breast prims
replace persearch=1 if pid=="20150350" & cr5id=="T2S1" //2015 prim with T1 dup 2015 source
replace persearch=3 if pid=="20150350" & cr5id=="T1S1" //2015 prim with T1 dup 2015 source
replace persearch=1 if pid=="20150356" & cr5id=="T2S1" //2015 prim with T1 dup 2015 source
replace persearch=3 if pid=="20150356" & cr5id=="T1S1" //2015 prim with T1 dup 2015 source
replace persearch=1 if pid=="20150376" & cr5id=="T2S1" //2015 breast prims; T1=508, T2=504
replace persearch=4 if pid=="20150376" & cr5id=="T1S1" //2015 breast prims; T1=508, T2=504
replace persearch=1 if pid=="20150431" & cr5id=="T2S1" //2015 prim with T1 dup 2015 source
replace persearch=3 if pid=="20150431" & cr5id=="T1S1" //2015 prim with T1 dup 2015 source
replace persearch=2 if pid=="20150468" & cr5id=="T2S1" //2015 prim; 2015 MP
replace persearch=1 if pid=="20150468" & cr5id=="T1S1" //2015 prim; 2015 MP
replace persearch=1 if pid=="20150485" & cr5id=="T2S1" //2015 prim with T1 dup 2015 source
replace persearch=3 if pid=="20150485" & cr5id=="T1S1" //2015 prim with T1 dup 2015 source
replace persearch=2 if pid=="20150506" & cr5id=="T2S1" //2015 prim; 2015 MP
replace persearch=1 if pid=="20150506" & cr5id=="T1S1" //2015 prim; 2015 MP
replace persearch=1 if pid=="20150519" & cr5id=="T2S1" //2015 breast prims; T1=508, T2=504
replace persearch=4 if pid=="20150519" & cr5id=="T1S1" //2015 breast prims; T1=508, T2=504
replace persearch=4 if pid=="20150561" & cr5id=="T2S1" //2015 breast prim; T1=left, T2=right
replace persearch=1 if pid=="20150561" & cr5id=="T1S1" //2015 breast prim; T1=left, T2=right
replace persearch=1 if pid=="20151103" & cr5id=="T2S1" //2015 prim with T1, T3 dup 2015 source
replace persearch=3 if pid=="20151103" & cr5id!="T2S1" //2 changes
replace persearch=2 if pid=="20151200" & cr5id=="T2S1" //2015 prim; 2015 MP
replace persearch=1 if pid=="20151200" & cr5id=="T1S1" //2015 prim; 2015 MP
replace persearch=2 if pid=="20151202" & cr5id=="T2S1" //2015 prim; 2015 MP
replace persearch=1 if pid=="20151202" & cr5id=="T1S1" //2015 prim; 2015 MP
replace persearch=2 if pid=="20151236" & cr5id=="T2S1" //2015 prim; 2015 MP
replace persearch=1 if pid=="20151236" & cr5id=="T1S1" //2015 prim; 2015 MP
replace persearch=2 if pid=="20155043" & cr5id=="T2S1" //2015 prim; 2015 MP
replace persearch=1 if pid=="20155043" & cr5id=="T1S1" //2015 prim; 2015 MP
replace persearch=4 if pid=="20155093" & cr5id=="T2S1" //2015 breast prims; T1=504, T2=506
replace persearch=1 if pid=="20155093" & cr5id=="T1S1" //2015 breast prims; T1=504, T2=506
replace persearch=2 if pid=="20155094" & cr5id=="T2S1" //2015 prim; 2015 MP
replace persearch=1 if pid=="20155094" & cr5id=="T1S1" //2015 prim; 2015 MP
replace persearch=2 if pid=="20155104" & cr5id=="T2S1" //2015 prim; 2015 MP
replace persearch=1 if pid=="20155104" & cr5id=="T1S1" //2015 prim; 2015 MP
replace persearch=2 if pid=="20159029" & cr5id=="T2S1" //2015 prim-DCO; 2015 MP-DCO
replace persearch=1 if pid=="20159029" & cr5id=="T1S1" //2015 prim-DCO; 2015 MP-DCO
replace persearch=2 if pid=="20159116" & cr5id=="T2S1" //2015 prim-DCO; 2015 MP-DCO
replace persearch=1 if pid=="20159116" & cr5id=="T1S1" //2015 prim-DCO; 2015 MP-DCO

sort pid
gen obsid = _n
by pid: generate pidobsid=_n //gives sequence id for each pid that appears in dataset
by pid: generate pidobstot=_N //give total count for each pid that is duplicated in dataset

sort pid obsid
** Now check list of only eligible non-duplicate tumours for 'true' and 'false' MPs by first & last names
count if dupsource==1 //978; 1137
//list pid cr5id fname lname dupsource recstatus duppid duppid_all obsid if inrange(obsid, 0, 700), sepby(pid)
//list pid cr5id fname lname dupsource recstatus duppid duppid_all obsid if inrange(obsid, 701, 1400), sepby(pid)
//list pid cr5id fname lname dupsource recstatus duppid duppid_all obsid if inrange(obsid, 1401, 2035), sepby(pid)

/*
List of 'true' MPs (i.e. same pt, diff. tumour according to IARC MP rules) from above check list:
	Already captured in recstatus==1 & cr5id=="T2S1"
List of 'false' (i.e. same name, diff. pts) MPs from above check list:
	Already captured in recstatus==1 & cr5id=="T2S1"
*/

/*
** Now double-check list of only eligible non-duplicate tumours for MPs but by NRN
preserve
drop if natregno=="" | natregno=="999999-9999" | regexm(natregno, "9999-9999")
drop if dupsource!=1
sort natregno lname fname pid
quietly by natregno :  gen dupnrn = cond(_N==1,0,_n)
sort natregno
count if dupnrn>0 //36; 21 - corrections made to '2_clean_cancer_dc.do' so totals different now - only shows 10 MPs
list pid fname lname natregno sex age dupnrn duppid if dupnrn>0
restore

** Now double-check list of only eligible non-duplicate tumours for MPs but by hospital #
preserve
drop if hospnum=="" | hospnum=="99"
drop if dupsource!=1
sort hospnum lname fname pid
quietly by hospnum :  gen duphosp = cond(_N==1,0,_n)
sort hospnum
count if duphosp>0 //18; 16
list pid fname lname hospnum natregno sex age duphosp duppid if duphosp>0
restore
*/

** Assign person search variable
tab persearch ,m
replace persearch=1 if dupsource==1 & (persearch==0|persearch==.) //927; 1081
replace persearch=3 if (dupsource>1 & dupsource<5) & (persearch==0|persearch==.) //922; 923
count if recstatus==4 & persearch!=3 //1 - correct it's a non-IARC MP
count if recstatus==3 //120
count if recstatus==3 & (persearch==0|persearch==.) //120
replace persearch=0 if recstatus==3 //30 changes

** Based on above list, create variable to identify MPs
/*
gen cr5idtxttum=substr(cr5id,2,1)
replace cr5idtxttum=1 if persearch==1 & cr5idtxttum!=1
gen cr5idtxtsor=substr(cr5id,-1,1)
gen pidcr5id=pid+"-"+cr5idtxt
gen eidmptxt = substr(eid,-1,1)
destring eidmptxt ,replace
gen eidmp=1 if eidmptxt==1 & dupsource==1 //1,659; 1,621; 1,623 missing values generated
replace eidmp=2 if eidmptxt>1 & dupsource==1 //21 changes
*/
gen eidmp=1 if persearch==1
replace eidmp=2 if persearch==2
label var eidmp "CR5 tumour events"
label define eidmp_lab 1 "single tumour" 2 "multiple tumour" ,modify
label values eidmp eidmp_lab
tab eidmp ,m
tab eidmp dxyr
** Check if eidmp below match with MPs identified on hardcopy list
count if dupsource==1 //1137
sort pid lname fname
//list pid eidmp dupsource duppid cr5id fname lname if dupsource==1 
**no corrections needed


count //2035; 2194

************************
**  Copying COD info  **
** into source record **
**  to use for merge  **
************************
** Before dropping duplicates, need to ensure cr5cod is retained in main dataset for when matching with national death data
** Note to self: Need to research for the future if there is a way in Stata to transfer data from one observation to another
count if cr5cod=="" & slc==2 //580
count if eidmp!=. & cr5cod=="" & slc==2 //309
//list pid cr5id dxyr if eidmp!=. & cr5cod=="" & slc==2
count if slc==2 & dd_coddeath=="" //87
count if slc==2 & dd_coddeath=="" & cr5cod!="" //43
replace dd_coddeath=cr5cod if slc==2 & dd_coddeath=="" & cr5cod!="" //43 changes
//list pid cr5id eidmp cr5cod if slc==2 & dd_coddeath=="" ,string(50)
count if cr5cod=="" & dd_coddeath!="" //575
replace cr5cod=dd_coddeath if cr5cod=="" & dd_coddeath!="" //575
count if cr5cod=="99" & (dd_coddeath!=""|dd_coddeath!="99") //158
replace cr5cod=dd_coddeath if cr5cod=="99" & (dd_coddeath!=""|dd_coddeath!="99") //154
count if cr5id=="T1S1" & slc==2 & cr5cod=="" //28
//list pid cr5id cr5cod dd_coddeath if slc==2  & cr5cod=="",sepby(pid) string(50)
sort pid cr5id
bysort pid : replace cr5cod = cr5cod[_n+1] if cr5cod=="" //41 changes
bysort pid : replace cr5cod = cr5cod[_n+2] if cr5cod=="" //16 changes
count if cr5id=="T1S1" & slc==2 & (cr5cod==""|cr5cod=="99") //4
count if cr5id=="T1S1" & slc==2 & cr5cod=="" //0
//list pid cr5cod dd_coddeath if cr5id=="T1S1" & slc==2 & (cr5cod==""|cr5cod=="99")

** Copy death data into T1S1 also using above methods
count if record_id==. & _merge==5 //42
//list pid if record_id==. & _merge==5
bysort pid : replace record_id = record_id[_n-1] if record_id==.
bysort pid : replace record_id = record_id[_n+1] if record_id==.
bysort pid : replace record_id = record_id[_n+2] if record_id==.
count if record_id==. & _merge==5 //1
//list pid if record_id==. & _merge==5 //20151151 - this is correct
count if dd_regnum==. & _merge==5 //42
bysort pid : replace dd_regnum = dd_regnum[_n-1] if dd_regnum==.
bysort pid : replace dd_regnum = dd_regnum[_n+1] if dd_regnum==.
bysort pid : replace dd_regnum = dd_regnum[_n+2] if dd_regnum==.
count if dd_regnum==. & _merge==5 //1
count if nrn==. & _merge==5 //42
bysort pid : replace nrn = nrn[_n-1] if nrn==.
bysort pid : replace nrn = nrn[_n+1] if nrn==.
bysort pid : replace nrn = nrn[_n+2] if nrn==.
count if nrn==. & _merge==5 //1
count if dd_pname=="" & _merge==5 //42
bysort pid : replace dd_pname = dd_pname[_n-1] if dd_pname==""
bysort pid : replace dd_pname = dd_pname[_n+1] if dd_pname==""
bysort pid : replace dd_pname = dd_pname[_n+2] if dd_pname==""
count if dd_pname=="" & _merge==5 //1
count if dd_age==. & _merge==5 //42
bysort pid : replace dd_age = dd_age[_n-1] if dd_age==.
bysort pid : replace dd_age = dd_age[_n+1] if dd_age==.
bysort pid : replace dd_age = dd_age[_n+2] if dd_age==.
count if dd_age==. & _merge==5 //1
count if dd_dod==. & _merge==5 //42
bysort pid : replace dd_dod = dd_dod[_n-1] if dd_dod==.
bysort pid : replace dd_dod = dd_dod[_n+1] if dd_dod==.
bysort pid : replace dd_dod = dd_dod[_n+2] if dd_dod==.
count if dd_dod==. & _merge==5 //1
count if cancer==. & _merge==5 //42
bysort pid : replace cancer = cancer[_n-1] if cancer==.
bysort pid : replace cancer = cancer[_n+1] if cancer==.
bysort pid : replace cancer = cancer[_n+2] if cancer==.
count if cancer==. & _merge==5 //1
count if dd_cod1a=="" & _merge==5 //42
bysort pid : replace dd_cod1a = dd_cod1a[_n-1] if dd_cod1a==""
bysort pid : replace dd_cod1a = dd_cod1a[_n+1] if dd_cod1a==""
bysort pid : replace dd_cod1a = dd_cod1a[_n+2] if dd_cod1a==""
count if dd_cod1a=="" & _merge==5 //1
count if dd_address=="" & _merge==5 //42
bysort pid : replace dd_address = dd_address[_n-1] if dd_address==""
bysort pid : replace dd_address = dd_address[_n+1] if dd_address==""
bysort pid : replace dd_address = dd_address[_n+2] if dd_address==""
count if dd_address=="" & _merge==5 //1
count if dd_parish==. & _merge==5 //42
bysort pid : replace dd_parish = dd_parish[_n-1] if dd_parish==.
bysort pid : replace dd_parish = dd_parish[_n+1] if dd_parish==.
bysort pid : replace dd_parish = dd_parish[_n+2] if dd_parish==.
count if dd_parish==. & _merge==5 //1
count if dd_pod=="" & _merge==5 //42
bysort pid : replace dd_pod = dd_pod[_n-1] if dd_pod==""
bysort pid : replace dd_pod = dd_pod[_n+1] if dd_pod==""
bysort pid : replace dd_pod = dd_pod[_n+2] if dd_pod==""
count if dd_pod=="" & _merge==5 //1
count if dd_mname=="" & _merge==5 //42
bysort pid : replace dd_mname = dd_mname[_n-1] if dd_mname==""
bysort pid : replace dd_mname = dd_mname[_n+1] if dd_mname==""
bysort pid : replace dd_mname = dd_mname[_n+2] if dd_mname==""
count if dd_mname=="" & _merge==5 //1
count if dd_namematch==. & _merge==5 //42
bysort pid : replace dd_namematch = dd_namematch[_n-1] if dd_namematch==.
bysort pid : replace dd_namematch = dd_namematch[_n+1] if dd_namematch==.
bysort pid : replace dd_namematch = dd_namematch[_n+2] if dd_namematch==.
count if dd_namematch==. & _merge==5 //1
count if dd_event==. & _merge==5 //42
bysort pid : replace dd_event = dd_event[_n-1] if dd_event==.
bysort pid : replace dd_event = dd_event[_n+1] if dd_event==.
bysort pid : replace dd_event = dd_event[_n+2] if dd_event==.
count if dd_event==. & _merge==5 //1
count if dd_dddoa==. & _merge==5 //42
bysort pid : replace dd_dddoa = dd_dddoa[_n-1] if dd_dddoa==.
bysort pid : replace dd_dddoa = dd_dddoa[_n+1] if dd_dddoa==.
bysort pid : replace dd_dddoa = dd_dddoa[_n+2] if dd_dddoa==.
count if dd_dddoa==. & _merge==5 //1
count if dd_ddda==. & _merge==5 //42
bysort pid : replace dd_ddda = dd_ddda[_n-1] if dd_ddda==.
bysort pid : replace dd_ddda = dd_ddda[_n+1] if dd_ddda==.
bysort pid : replace dd_ddda = dd_ddda[_n+2] if dd_ddda==.
count if dd_ddda==. & _merge==5 //1
count if dd_odda=="" & _merge==5 //42
bysort pid : replace dd_odda = dd_odda[_n-1] if dd_odda==""
bysort pid : replace dd_odda = dd_odda[_n+1] if dd_odda==""
bysort pid : replace dd_odda = dd_odda[_n+2] if dd_odda==""
count if dd_odda=="" & _merge==5 //1
count if dd_certtype==. & _merge==5 //42
bysort pid : replace dd_certtype = dd_certtype[_n-1] if dd_certtype==.
bysort pid : replace dd_certtype = dd_certtype[_n+1] if dd_certtype==.
bysort pid : replace dd_certtype = dd_certtype[_n+2] if dd_certtype==.
count if dd_certtype==. & _merge==5 //1
count if dd_district==. & _merge==5 //42
bysort pid : replace dd_district = dd_district[_n-1] if dd_district==.
bysort pid : replace dd_district = dd_district[_n+1] if dd_district==.
bysort pid : replace dd_district = dd_district[_n+2] if dd_district==.
count if dd_district==. & _merge==5 //1
count if dd_agetxt==. & _merge==5 //42
bysort pid : replace dd_agetxt = dd_agetxt[_n-1] if dd_agetxt==.
bysort pid : replace dd_agetxt = dd_agetxt[_n+1] if dd_agetxt==.
bysort pid : replace dd_agetxt = dd_agetxt[_n+2] if dd_agetxt==.
count if dd_agetxt==. & _merge==5 //1
count if dd_nrnnd==. & _merge==5 //42
bysort pid : replace dd_nrnnd = dd_nrnnd[_n-1] if dd_nrnnd==.
bysort pid : replace dd_nrnnd = dd_nrnnd[_n+1] if dd_nrnnd==.
bysort pid : replace dd_nrnnd = dd_nrnnd[_n+2] if dd_nrnnd==.
count if dd_nrnnd==. & _merge==5 //1
count if dd_mstatus==. & _merge==5 //42
bysort pid : replace dd_mstatus = dd_mstatus[_n-1] if dd_mstatus==.
bysort pid : replace dd_mstatus = dd_mstatus[_n+1] if dd_mstatus==.
bysort pid : replace dd_mstatus = dd_mstatus[_n+2] if dd_mstatus==.
count if dd_mstatus==. & _merge==5 //1
count if dd_occu=="" & _merge==5 //42
bysort pid : replace dd_occu = dd_occu[_n-1] if dd_occu==""
bysort pid : replace dd_occu = dd_occu[_n+1] if dd_occu==""
bysort pid : replace dd_occu = dd_occu[_n+2] if dd_occu==""
count if dd_occu=="" & _merge==5 //1
count if dd_durationnum==. & _merge==5 //42
bysort pid : replace dd_durationnum = dd_durationnum[_n-1] if dd_durationnum==.
bysort pid : replace dd_durationnum = dd_durationnum[_n+1] if dd_durationnum==.
bysort pid : replace dd_durationnum = dd_durationnum[_n+2] if dd_durationnum==.
count if dd_durationnum==. & _merge==5 //1
count if dd_durationtxt==. & _merge==5 //42
bysort pid : replace dd_durationtxt = dd_durationtxt[_n-1] if dd_durationtxt==.
bysort pid : replace dd_durationtxt = dd_durationtxt[_n+1] if dd_durationtxt==.
bysort pid : replace dd_durationtxt = dd_durationtxt[_n+2] if dd_durationtxt==.
count if dd_durationtxt==. & _merge==5 //1
count if dd_onsetnumcod1a==. & _merge==5 //42
bysort pid : replace dd_onsetnumcod1a = dd_onsetnumcod1a[_n-1] if dd_onsetnumcod1a==.
bysort pid : replace dd_onsetnumcod1a = dd_onsetnumcod1a[_n+1] if dd_onsetnumcod1a==.
bysort pid : replace dd_onsetnumcod1a = dd_onsetnumcod1a[_n+2] if dd_onsetnumcod1a==.
count if dd_onsetnumcod1a==. & _merge==5 //1
count if dd_onsettxtcod1a==. & _merge==5 //42
bysort pid : replace dd_onsettxtcod1a = dd_onsettxtcod1a[_n-1] if dd_onsettxtcod1a==.
bysort pid : replace dd_onsettxtcod1a = dd_onsettxtcod1a[_n+1] if dd_onsettxtcod1a==.
bysort pid : replace dd_onsettxtcod1a = dd_onsettxtcod1a[_n+2] if dd_onsettxtcod1a==.
count if dd_onsettxtcod1a==. & _merge==5 //1
count if dd_cod1b=="" & _merge==5 //42
bysort pid : replace dd_cod1b = dd_cod1b[_n-1] if dd_cod1b==""
bysort pid : replace dd_cod1b = dd_cod1b[_n+1] if dd_cod1b==""
bysort pid : replace dd_cod1b = dd_cod1b[_n+2] if dd_cod1b==""
count if dd_cod1b=="" & _merge==5 //1
count if dd_onsetnumcod1b==. & _merge==5 //42
bysort pid : replace dd_onsetnumcod1b = dd_onsetnumcod1b[_n-1] if dd_onsetnumcod1b==.
bysort pid : replace dd_onsetnumcod1b = dd_onsetnumcod1b[_n+1] if dd_onsetnumcod1b==.
bysort pid : replace dd_onsetnumcod1b = dd_onsetnumcod1b[_n+2] if dd_onsetnumcod1b==.
count if dd_onsetnumcod1b==. & _merge==5 //1
count if dd_onsettxtcod1b==. & _merge==5 //42
bysort pid : replace dd_onsettxtcod1b = dd_onsettxtcod1b[_n-1] if dd_onsettxtcod1b==.
bysort pid : replace dd_onsettxtcod1b = dd_onsettxtcod1b[_n+1] if dd_onsettxtcod1b==.
bysort pid : replace dd_onsettxtcod1b = dd_onsettxtcod1b[_n+2] if dd_onsettxtcod1b==.
count if dd_onsettxtcod1b==. & _merge==5 //1
count if dd_cod1c=="" & _merge==5 //42
bysort pid : replace dd_cod1c = dd_cod1c[_n-1] if dd_cod1c==""
bysort pid : replace dd_cod1c = dd_cod1c[_n+1] if dd_cod1c==""
bysort pid : replace dd_cod1c = dd_cod1c[_n+2] if dd_cod1c==""
count if dd_cod1c=="" & _merge==5 //1
count if dd_onsetnumcod1c==. & _merge==5 //42
bysort pid : replace dd_onsetnumcod1c = dd_onsetnumcod1c[_n-1] if dd_onsetnumcod1c==.
bysort pid : replace dd_onsetnumcod1c = dd_onsetnumcod1c[_n+1] if dd_onsetnumcod1c==.
bysort pid : replace dd_onsetnumcod1c = dd_onsetnumcod1c[_n+2] if dd_onsetnumcod1c==.
count if dd_onsetnumcod1c==. & _merge==5 //1
count if dd_onsettxtcod1c==. & _merge==5 //42
bysort pid : replace dd_onsettxtcod1c = dd_onsettxtcod1c[_n-1] if dd_onsettxtcod1c==.
bysort pid : replace dd_onsettxtcod1c = dd_onsettxtcod1c[_n+1] if dd_onsettxtcod1c==.
bysort pid : replace dd_onsettxtcod1c = dd_onsettxtcod1c[_n+2] if dd_onsettxtcod1c==.
count if dd_onsettxtcod1c==. & _merge==5 //1
count if dd_cod1d=="" & _merge==5 //42
bysort pid : replace dd_cod1d = dd_cod1d[_n-1] if dd_cod1d==""
bysort pid : replace dd_cod1d = dd_cod1d[_n+1] if dd_cod1d==""
bysort pid : replace dd_cod1d = dd_cod1d[_n+2] if dd_cod1d==""
count if dd_cod1d=="" & _merge==5 //1
count if dd_onsetnumcod1d==. & _merge==5 //42
bysort pid : replace dd_onsetnumcod1d = dd_onsetnumcod1d[_n-1] if dd_onsetnumcod1d==.
bysort pid : replace dd_onsetnumcod1d = dd_onsetnumcod1d[_n+1] if dd_onsetnumcod1d==.
bysort pid : replace dd_onsetnumcod1d = dd_onsetnumcod1d[_n+2] if dd_onsetnumcod1d==.
count if dd_onsetnumcod1d==. & _merge==5 //1
count if dd_onsettxtcod1d==. & _merge==5 //42
bysort pid : replace dd_onsettxtcod1d = dd_onsettxtcod1d[_n-1] if dd_onsettxtcod1d==.
bysort pid : replace dd_onsettxtcod1d = dd_onsettxtcod1d[_n+1] if dd_onsettxtcod1d==.
bysort pid : replace dd_onsettxtcod1d = dd_onsettxtcod1d[_n+2] if dd_onsettxtcod1d==.
count if dd_onsettxtcod1d==. & _merge==5 //1
count if dd_cod2a=="" & _merge==5 //42
bysort pid : replace dd_cod2a = dd_cod2a[_n-1] if dd_cod2a==""
bysort pid : replace dd_cod2a = dd_cod2a[_n+1] if dd_cod2a==""
bysort pid : replace dd_cod2a = dd_cod2a[_n+2] if dd_cod2a==""
count if dd_cod2a=="" & _merge==5 //1
count if dd_onsetnumcod2a==. & _merge==5 //42
bysort pid : replace dd_onsetnumcod2a = dd_onsetnumcod2a[_n-1] if dd_onsetnumcod2a==.
bysort pid : replace dd_onsetnumcod2a = dd_onsetnumcod2a[_n+1] if dd_onsetnumcod2a==.
bysort pid : replace dd_onsetnumcod2a = dd_onsetnumcod2a[_n+2] if dd_onsetnumcod2a==.
count if dd_onsetnumcod2a==. & _merge==5 //1
count if dd_onsettxtcod2a==. & _merge==5 //42
bysort pid : replace dd_onsettxtcod2a = dd_onsettxtcod2a[_n-1] if dd_onsettxtcod2a==.
bysort pid : replace dd_onsettxtcod2a = dd_onsettxtcod2a[_n+1] if dd_onsettxtcod2a==.
bysort pid : replace dd_onsettxtcod2a = dd_onsettxtcod2a[_n+2] if dd_onsettxtcod2a==.
count if dd_onsettxtcod2a==. & _merge==5 //1
count if dd_cod2b=="" & _merge==5 //42
bysort pid : replace dd_cod2b = dd_cod2b[_n-1] if dd_cod2b==""
bysort pid : replace dd_cod2b = dd_cod2b[_n+1] if dd_cod2b==""
bysort pid : replace dd_cod2b = dd_cod2b[_n+2] if dd_cod2b==""
count if dd_cod2b=="" & _merge==5 //1
count if dd_onsetnumcod2b==. & _merge==5 //42
bysort pid : replace dd_onsetnumcod2b = dd_onsetnumcod2b[_n-1] if dd_onsetnumcod2b==.
bysort pid : replace dd_onsetnumcod2b = dd_onsetnumcod2b[_n+1] if dd_onsetnumcod2b==.
bysort pid : replace dd_onsetnumcod2b = dd_onsetnumcod2b[_n+2] if dd_onsetnumcod2b==.
count if dd_onsetnumcod2b==. & _merge==5 //1
count if dd_onsettxtcod2b==. & _merge==5 //42
bysort pid : replace dd_onsettxtcod2b = dd_onsettxtcod2b[_n-1] if dd_onsettxtcod2b==.
bysort pid : replace dd_onsettxtcod2b = dd_onsettxtcod2b[_n+1] if dd_onsettxtcod2b==.
bysort pid : replace dd_onsettxtcod2b = dd_onsettxtcod2b[_n+2] if dd_onsettxtcod2b==.
count if dd_onsettxtcod2b==. & _merge==5 //1
count if dd_deathparish==. & _merge==5 //42
bysort pid : replace dd_deathparish = dd_deathparish[_n-1] if dd_deathparish==.
bysort pid : replace dd_deathparish = dd_deathparish[_n+1] if dd_deathparish==.
bysort pid : replace dd_deathparish = dd_deathparish[_n+2] if dd_deathparish==.
count if dd_deathparish==. & _merge==5 //1
count if dd_regdate==. & _merge==5 //42
bysort pid : replace dd_regdate = dd_regdate[_n-1] if dd_regdate==.
bysort pid : replace dd_regdate = dd_regdate[_n+1] if dd_regdate==.
bysort pid : replace dd_regdate = dd_regdate[_n+2] if dd_regdate==.
count if dd_regdate==. & _merge==5 //1
count if dd_certifier=="" & _merge==5 //42
bysort pid : replace dd_certifier = dd_certifier[_n-1] if dd_certifier==""
bysort pid : replace dd_certifier = dd_certifier[_n+1] if dd_certifier==""
bysort pid : replace dd_certifier = dd_certifier[_n+2] if dd_certifier==""
count if dd_certifier=="" & _merge==5 //1
count if dd_certifieraddr=="" & _merge==5 //42
bysort pid : replace dd_certifieraddr = dd_certifieraddr[_n-1] if dd_certifieraddr==""
bysort pid : replace dd_certifieraddr = dd_certifieraddr[_n+1] if dd_certifieraddr==""
bysort pid : replace dd_certifieraddr = dd_certifieraddr[_n+2] if dd_certifieraddr==""
count if dd_certifieraddr=="" & _merge==5 //1
count if recstatdc==. & _merge==5 //42
bysort pid : replace recstatdc = recstatdc[_n-1] if recstatdc==.
bysort pid : replace recstatdc = recstatdc[_n+1] if recstatdc==.
bysort pid : replace recstatdc = recstatdc[_n+2] if recstatdc==.
count if recstatdc==. & _merge==5 //1
count if dd_duprec==. & _merge==5 //42
bysort pid : replace dd_duprec = dd_duprec[_n-1] if dd_duprec==.
bysort pid : replace dd_duprec = dd_duprec[_n+1] if dd_duprec==.
bysort pid : replace dd_duprec = dd_duprec[_n+2] if dd_duprec==.
count if dd_duprec==. & _merge==5 //1
count if dd_dupname==. & _merge==5 //42
bysort pid : replace dd_dupname = dd_dupname[_n-1] if dd_dupname==.
bysort pid : replace dd_dupname = dd_dupname[_n+1] if dd_dupname==.
bysort pid : replace dd_dupname = dd_dupname[_n+2] if dd_dupname==.
count if dd_dupname==. & _merge==5 //1
count if dd_dupdod==. & _merge==5 //42
bysort pid : replace dd_dupdod = dd_dupdod[_n-1] if dd_dupdod==.
bysort pid : replace dd_dupdod = dd_dupdod[_n+1] if dd_dupdod==.
bysort pid : replace dd_dupdod = dd_dupdod[_n+2] if dd_dupdod==.
count if dd_dupdod==. & _merge==5 //1
count if cod==. & _merge==5 //42
bysort pid : replace cod = cod[_n-1] if cod==.
bysort pid : replace cod = cod[_n+1] if cod==.
bysort pid : replace cod = cod[_n+2] if cod==.
count if cod==. & _merge==5 //1
count if placeofdeath=="" & _merge==5 //42
bysort pid : replace placeofdeath = placeofdeath[_n-1] if placeofdeath==""
bysort pid : replace placeofdeath = placeofdeath[_n+1] if placeofdeath==""
bysort pid : replace placeofdeath = placeofdeath[_n+2] if placeofdeath==""
count if placeofdeath=="" & _merge==5 //1
count if dodyear==. & _merge==5 //42
bysort pid : replace dodyear = dodyear[_n-1] if dodyear==.
bysort pid : replace dodyear = dodyear[_n+1] if dodyear==.
bysort pid : replace dodyear = dodyear[_n+2] if dodyear==.
count if dodyear==. & _merge==5 //1

** Create variable to identify patient records
gen ptrectot=.
replace ptrectot=1 if eidmp==1 //971; 1119 changes
replace ptrectot=3 if eidmp==2 //13; 15 changes
replace ptrectot=2 if regexm(pid, "20159") //149 changes
label define ptrectot_lab 1 "CR5 pt with single event" 2 "DC with single event" 3 "CR5 pt with multiple events" ///
						  4 "DC with multiple events" 5 "CR5 pt: single event but multiple DC events" , modify
label values ptrectot ptrectot_lab
/*
Now check:
	(1) patient record with T1 are included in category 3 of ptrectot but leave eidmp=single tumour so this var can be used to count MPs
	(2) patient records with only 1 tumour but maybe labelled as T2 are not included in eidmp and are included in category 1 of ptrectot
*/
count if eidmp==2 & dupsource==1 //11; 13
order pid record_id cr5id eidmp dupsource ptrectot primarysite
//list pid eidmp dupsource duppid cr5id fname lname if eidmp==2 & dupsource==1

replace ptrectot=3 if pid=="20150238" & cr5id=="T1S1" //1 change
replace ptrectot=3 if pid=="20150277" & cr5id=="T1S1" //1 change
replace ptrectot=3 if pid=="20150468" & cr5id=="T1S1" //1 change
replace ptrectot=3 if pid=="20150506" & cr5id=="T1S1" //1 change
replace ptrectot=3 if pid=="20151200" & cr5id=="T1S1" //1 change
replace ptrectot=3 if pid=="20151202" & cr5id=="T1S1" //1 change
replace ptrectot=3 if pid=="20151236" & cr5id=="T1S1" //1 change
replace ptrectot=1 if pid=="20151369" & cr5id=="T1S1" //1 change
replace eidmp=1 if pid=="20151369" & cr5id=="T1S1" //1 change
replace eidmp=. if pid=="20151369" & cr5id=="T1S2" //1 change
replace eidmp=. if pid=="20151369" & cr5id=="T1S3" //1 change
replace ptrectot=3 if pid=="20155043" & cr5id=="T1S1" //1 change
replace ptrectot=3 if pid=="20155094" & cr5id=="T1S1" //1 change
replace ptrectot=3 if pid=="20155104" & cr5id=="T1S1" //1 change
replace ptrectot=4 if pid=="20159029" //2 changes
replace ptrectot=4 if pid=="20159116" //2 changes

count if ptrectot==.

** Count # of patients with eligible non-dup tumours
count if ptrectot==1 //962; 963

** Count # of eligible non-dup tumours
count if eidmp==1 //972; 1120

** Count # of eligible non-dup MPs
count if eidmp==2 //10; 12

** JC 14nov18 - I forgot about missed 2013 cases in dataset so stats for 2014 only:
** Count # of patients with eligible non-dup tumours
count if ptrectot==1 & dxyr==2015 //926; 927

** Count # of eligible non-dup tumours
count if eidmp==1 & dxyr==2015 //936; 1074

** Count # of eligible non-dup MPs
count if eidmp==2 & dxyr==2015 //10; 12

/* 
Count # of multiple source records per tumour:
(1)Create variables based on built-in Stata variables (_n, _N) to calculate obs count:
		(a) _n is Stata notation for the current observation number (varname: pidobsid)
		(b) _N is Stata notation for the total number of observations (varname: pidobstot)
(2)Create variables to store overall obs # and obs total (obsid, obstot) for DQI
*/

tab pidobstot ,m //all tumours - need to drop dup sources records to assess DQI for multiple sources per tumour
/*
  pidobstot |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |        642       25.15       25.15
          2 |        832       32.59       57.74
          3 |        669       26.20       83.94
          4 |        280       10.97       94.91
          5 |        110        4.31       99.22
          6 |         12        0.47       99.69
          8 |          8        0.31      100.00
------------+-----------------------------------
      Total |      2,553      100.00

  pidobstot |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |        548       24.98       24.98
          2 |        776       35.37       60.35
          3 |        621       28.30       88.65
          4 |        180        8.20       96.86
          5 |         55        2.51       99.36
          6 |          6        0.27       99.64
          8 |          8        0.36      100.00
------------+-----------------------------------
      Total |      2,194      100.00
*/

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

order pid record_id cr5id eidmp dupsource ptrectot dcostatus primarysite
** Assign DCO Status=NA for all events that are not cancer 
replace dcostatus=2 if nftype==8 //256; 265
replace dcostatus=2 if basis==0 //14; 136
replace dcostatus=4 if cancer==2 //7463; 85 changes
count if slc!=2 //10524; 978
//list cr5cod if slc!=2
replace dcostatus=6 if slc==1 //962 changes
replace dcostatus=7 if slc==9 //0 changes
count if dcostatus==. & cr5cod!="" //2898; 755
replace dcostatus=1 if cr5cod!="" & dcostatus==. & pid!="" //730; 755 changes
count if dcostatus==. & record_id!=. //2169; 3
count if dcostatus==. & pid!="" & record_id!=. //2-leave as is; it's a multiple source
//list pid cr5id record_id basis recstatus eidmp nftype dcostatus if dcostatus==. & pid!="" & record_id!=. ,nolabel
//replace dcostatus=5 if dcostatus==. & pid!="" & record_id!=.
replace dcostatus=1 if pid=="20150468" & cr5id=="T2S1" //1 change
count if dcostatus==. //2189; 22
count if dcostatus==. & pid=="" //2168; 0
count if dcostatus==. & pid!="" //21; 22
count if dcostatus==. & pid!="" & slc==2 //5; 6
//list pid cr5id record_id basis recstatus eidmp nftype if dcostatus==. & pid!=""
replace dcostatus=1 if pid=="20150031" //2 changes
replace dcostatus=1 if pid=="20150506" //2 changes
replace dcostatus=1 if pid=="20155213" //2 changes

** Remove unmatched death certificates
count if pid=="" //9546 - deaths from all years (2008-2018)
count if _merge==2 & pid=="" //0
drop if pid=="" //9546 deleted; 0 deleted

count //2045; 2194
count if dupsource==. //0
count if eidmp==. //1062
count if cr5id=="" //0

** Additional records have been added so need to drop these as they are duplicates created by Stata bysort/missing
count if eidmp==1 //1120
//list pid cr5id eidmp ptrectot if eidmp==1 , sepby(pid)
drop duppidcr5id
sort pid cr5id
quietly by pid cr5id :  gen duppidcr5id = cond(_N==1,0,_n)
sort pid cr5id
count if duppidcr5id>0 //17
//list pid cr5id record_id eidmp ptrectot primarysite duppidcr5id _merge_org if duppidcr5id>0
count if _merge_org==5 //39; 38 - some are correct so don't drop
//list pid cr5id record_id eidmp ptrectot primarysite duppidcr5id _merge_org if _merge_org==5
count if duppidcr5id>0 & _merge_org==5 //11
//list pid cr5id record_id eidmp ptrectot primarysite duppidcr5id _merge_org if duppidcr5id>0 & _merge_org==5
drop if pid=="20150481" & duppidcr5id==2 //1 deleted
** Need to avoid inadvertently deleting a correct source record so need to tag the duplicate cr5id
duplicates tag pid cr5id, gen(dup_cr5id)
count if dup_cr5id>0 & _merge_org==5 //11
//list pid cr5id dup_cr5id duppidcr5id _merge_org if dup_cr5id>0, nolabel sepby(pid)
drop if dup_cr5id>0 & _merge_org==5 //10; 11 deleted

count //2035; 2183

tab dxyr ,m 
tab dxyr eidmp ,m
tab sourcename ,m  //149 missing - missed death certificates from DCO list
replace sourcename=5 if sourcename==. //149 changes

** Create word doc for NS of duplicates for assessing completeness (sources per record) but want to retain this dataset
preserve
** % tumours - Duplicates
drop if dxyr!=2015 //65; 75 deleted: removed 2008, 2013, 2014 records
gen dupdqi=.
replace dupdqi=1 if eidmp==. & dupsource>1 & dupsource<5 //906 changes
replace dupdqi=1 if eidmp==. & dupsource==1 //4 changes
replace dupdqi=2 if eidmp==1 & dupsource==1 //930; 1066 changes
replace dupdqi=3 if dupsource==5|dupsource==6 //120 changes
tab dupdqi ,m
/*
     dupdqi |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |        910       46.19       46.19
          2 |        930       47.21       93.40
          3 |        120        6.09       99.49
          . |         10        0.51      100.00
------------+-----------------------------------
      Total |      1,970      100.00
	  
     dupdqi |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |        910       43.17       43.17
          2 |      1,066       50.57       93.74
          3 |        120        5.69       99.43
          . |         12        0.57      100.00
------------+-----------------------------------
      Total |      2,108      100.00
*/
tab dxyr dupdqi ,m
replace dupdqi=2 if dupdqi==. //10 changes
label define dupdqi_lab 1 "duplicates" 2 "non-duplicates" 3 "ineligibles" , modify
label values dupdqi dupdqi_lab
tab eidmp ,m
tab dupsource eidmp ,m
tab dupsource eidmp if dxyr==2015 ,m
tab dupdqi ,m
/*
        dupdqi |      Freq.     Percent        Cum.
---------------+-----------------------------------
    duplicates |        910       46.19       46.19
non-duplicates |        940       47.72       93.91
   ineligibles |        120        6.09      100.00
---------------+-----------------------------------
         Total |      1,970      100.00

        dupdqi |      Freq.     Percent        Cum.
---------------+-----------------------------------
    duplicates |        910       43.17       43.17
non-duplicates |      1,078       51.14       94.31
   ineligibles |        120        5.69      100.00
---------------+-----------------------------------
         Total |      2,108      100.00
*/
tab dupsource dupdqi ,m
contract dupdqi, freq(count) percent(percentage)

putdocx clear
putdocx begin, footer(foot1)
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
//stop - update totals after 163 DCO trace-back was completed
// Create a paragraph
putdocx paragraph, style(Title)
putdocx text ("CANCER 2015 Annual Report: DQI"), bold
putdocx textblock begin
Date Prepared: 20-JAN-2021. 
Prepared by: JC using Stata & Redcap data release date: 14-Nov-2019. 
Generated using Dofiles: 15_clean cancer.do and 20_analysis cancer.do
putdocx textblock end
putdocx paragraph, style(Heading1)
putdocx text ("Duplicates"), bold
putdocx paragraph
putdocx text ("# duplicates: "), bold font(Helvetica,10)
putdocx text ("910"), shading("yellow") bold font(Helvetica,10)
putdocx paragraph
putdocx text ("# non-duplicates: "), bold font(Helvetica,10)
putdocx text ("1,078"), shading("yellow") bold font(Helvetica,10)
putdocx paragraph
putdocx text ("# ineligibles: "), bold font(Helvetica,10)
putdocx text ("120"), shading("yellow") bold font(Helvetica,10)
putdocx paragraph, halign(center)
putdocx text ("Duplicates (total records/n=2,108)"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename dupdqi Total_Duplicates
rename count Total_Records
rename percentage Pct_Multiple_Duplicates
putdocx table tbl_dups = data("Total_Duplicates Total_Records Pct_Multiple_Duplicates"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_dups(1,.), bold

putdocx save "`datapath'\version02\3-output\2021-07-21_DQI.docx", replace
putdocx clear

save "`datapath'\version02\2-working\2015_cancer_dqi_dups.dta" ,replace
label data "BNR-Cancer 2015 Data Quality Index - Duplicates"
notes _dta :These data prepared for Natasha Sobers - 2015 annual report

restore

** Create word doc for SAF of sources but want to retain this dataset
** NB: some sources need updating from 7-BNRdb to 4-IPS and 1-QEH
preserve
drop if dxyr!=2015 //74 deleted: removed 2008, 2013, 2014 records
count if sourcename==7 & length(labnum)<8 //0
replace sourcename=4 if sourcename==7 & length(labnum)<8 //0 changes
count if sourcename==7
replace sourcename=1 if sourcename==7 //0 changes
contract sourcename, freq(count) percent(percentage)
gsort -count

putdocx clear
putdocx begin

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Sources"), bold
putdocx paragraph, halign(center)
putdocx text ("Sources (total records/n=2,108)"), bold font(Helvetica,14,"blue")
putdocx paragraph, halign(center)
putdocx text ("2015 Completeness: Sources per Record = 1.98"), bold font(Helvetica,12,"red")
//2108/1078=1.96: nonsurvival ds has 1062 tumours so 2108/1062=1.98 sources per record
putdocx paragraph, halign(center)
putdocx text ("2014 Completeness: Sources per Record = 2.75"), bold font(Helvetica,12,"lightpink")
putdocx paragraph
rename sourcename Source
rename count Total_Records
rename percentage Pct_Source
putdocx table tbl_source = data("Source Total_Records Pct_Source"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_source(1,.), bold

putdocx save "`datapath'\version02\3-output\2021-07-21_DQI.docx", append
putdocx clear

save "`datapath'\version02\2-working\2015_cancer_dqi_source.dta" ,replace
label data "BNR-Cancer 2015 Data Quality Index - Sources"
notes _dta :These data prepared for Natasha Sobers - 2015 annual report

restore

** Save dataset with duplicates
label data "BNR-Cancer data - Multiple Sources"
notes _dta :These data prepared from CanReg5 CLEAN (2015BNR-C) database
save "`datapath'\version02\2-working\2015_cancer_dups" ,replace
note: TS This dataset can be used for quality parameter of completeness in assessing number of sources per record

** Need to drop dup sources for multiple sources DQI and to use for upcoming dofiles
tab eidmp ,m
tab eidmp dxyr ,m
tab recstatus dxyr ,m
drop if eidmp==. //1062 deleted

count //973; 1121

tab dxyr ,m
/*
DiagnosisYe |
         ar |      Freq.     Percent        Cum.
------------+-----------------------------------
       2008 |          6        0.62        0.62
       2013 |         11        1.13        1.75
       2014 |         16        1.64        3.39
       2015 |        940       96.61      100.00
------------+-----------------------------------
      Total |        973      100.00

DiagnosisYe |
         ar |      Freq.     Percent        Cum.
------------+-----------------------------------
       2008 |          8        0.71        0.71
       2013 |         13        1.16        1.87
       2014 |         22        1.96        3.84
       2015 |      1,078       96.16      100.00
------------+-----------------------------------
      Total |      1,121      100.00
*/

tab dxyr if basis==0
/*
DiagnosisYe |
         ar |      Freq.     Percent        Cum.
------------+-----------------------------------
       2008 |          1        0.74        0.74
       2015 |        134       99.26      100.00
------------+-----------------------------------
      Total |        135      100.00
*/
rename record_id deathid

** Save dataset without duplicates
label data "BNR-Cancer data - 2015 Incidence: No duplicates"
notes _dta :These data prepared from CanReg5 CLEAN (2015BNR-C) database
save "`datapath'\version02\2-working\2015_cancer_nodups" ,replace
note: TS This dataset can be used for matching with 2019 deaths


*************************
** 2019 Death Matching **
*************************
use "`datapath'\version02\2-working\2015_cancer_nodups", clear

count //1122
count if slc==2 //597
gen match2019=1 if slc==2
label define match2019_lab 1 "Yes" 2 "No" , modify
label values match2019 match2019_lab
//gen dod=dlc if slc==2 - no blanks dod if slc==2
//format dod %tdCCYY-NN-DD
replace natregno=subinstr(natregno,"-","",.) if regexm(natregno,"-") //0 changes
count if natregno!="" & natregno!="." & length(natregno)!=10 //0

/* frames won't work unless each obs in current frame cancer links with one obs in deaths frame
frame rename default cancer
frame create deaths
frame change deaths
use "`datapath'\version02\3-output\2015-2018_deaths_for_matching", clear
frame change cancer
frame put pid fname lname natregno slc dlc dod, into(deaths)

frlink m:1 fname lname sex natregno, frame(deaths)
gen ddmatch=frval(deaths,natregno)=frval(cancer,natregno)
*/

tab sex ,m
//no need to convert sex as already F=1, M=2 in dataset
/*
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
*/
** Convert names to lower case and strip possible leading/trailing blanks
replace fname = lower(rtrim(ltrim(itrim(fname)))) //0 changes
replace lname = lower(rtrim(ltrim(itrim(lname)))) //0 changes

count //1122

drop _merge
merge m:m lname fname sex using "`datapath'\version02\3-output\2019_deaths_for_matching"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         3,812
        from master                     1,073  (_merge==1)
        from using                      2,739  (_merge==2)

    matched                                49  (_merge==3)
    -----------------------------------------
*/

count //3861

sort lname fname record_id pid
quietly by lname fname :  gen duppt_2019 = cond(_N==1,0,_n)
sort lname fname
count if duppt_2019>0 //125
count if duppt_2019>0 & duppid<2 //28
count if duppt_2019>0 & duppid<2 & slc!=2 //13
count if duppt_2019>0 & _merge==3 //2
count if slc!=2 & _merge==3 //40
sort lname fname pid
order pid fname lname natregno sex age primarysite dd2019_coddeath
//list pid record_id fname lname age dd2019_age natregno dd2019_nrn addr dd2019_address slc if slc!=2 & _merge==3, string(20)

** Remove death data from records where pt doesn't match but still had merged
replace _merge=4 if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace match2019=2 if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_coddeath="" if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_regnum=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_nrn=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_pname="" if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_age=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_dod=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_cancer=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_cod1a="" if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_address="" if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_parish=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_pod="" if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_mname="" if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_namematch=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_event=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_dddoa=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_ddda=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_odda="" if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_certtype=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_district=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_agetxt=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_nrnnd=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_mstatus=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_occu="" if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_durationnum=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_durationtxt=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_onsetnumcod1a=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_onsettxtcod1a=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_cod1b="" if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_onsetnumcod1b=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_onsettxtcod1b=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_cod1c="" if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_onsetnumcod1c=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_onsettxtcod1c=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_cod1d="" if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_onsetnumcod1d=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_onsettxtcod1d=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_cod2a="" if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_onsetnumcod2a=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_onsettxtcod2a=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_cod2b="" if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_onsetnumcod2b=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_onsettxtcod2b=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_deathparish=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_regdate=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_certifier="" if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_certifieraddr="" if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_cleaned=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_recstatdc=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_duprec=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_dodyear=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
replace dd2019_dod=. if record_id==27220|record_id==29620|record_id==28380|record_id==29540|record_id==29073|record_id==30020|record_id==28269|record_id==27602
				
				
sort pid lname fname
count if nrn!=dd2019_nrn & _merge==3 //41
//list pid record_id fname lname age dd2019_age nrn dd2019_nrn addr dd2019_address slc if nrn!=dd2019_nrn & _merge==3, string(20)

replace _merge=5 if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace match2019=2 if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_coddeath="" if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_regnum=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_nrn=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_pname="" if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_age=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_dod=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_cancer=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_cod1a="" if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_address="" if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_parish=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_pod="" if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_mname="" if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_namematch=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_event=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_dddoa=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_ddda=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_odda="" if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_certtype=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_district=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_agetxt=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_nrnnd=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_mstatus=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_occu="" if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_durationnum=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_durationtxt=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_onsetnumcod1a=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_onsettxtcod1a=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_cod1b="" if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_onsetnumcod1b=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_onsettxtcod1b=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_cod1c="" if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_onsetnumcod1c=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_onsettxtcod1c=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_cod1d="" if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_onsetnumcod1d=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_onsettxtcod1d=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_cod2a="" if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_onsetnumcod2a=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_onsettxtcod2a=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_cod2b="" if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_onsetnumcod2b=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_onsettxtcod2b=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_deathparish=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_regdate=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_certifier="" if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_certifieraddr="" if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_cleaned=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_recstatdc=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_duprec=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_dodyear=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210
replace dd2019_dod=. if record_id==29590|record_id==29996|record_id==28242|record_id==26993|record_id==28020|record_id==29621|record_id==27520|record_id==27210

** Update death data for records where pt correctly matched
replace dod=dd2019_dod if slc!=2 & _merge==3 //32 changes
replace slc=2 if slc!=2 & _merge==3 //32 changes


** Check for matches by nrn and pt names
sort nrn lname fname pid
quietly by nrn :  gen dupnrn_2019 = cond(_N==1,0,_n)
sort nrn
count if dupnrn_2019>0 //3332
sort lname fname pid record_id
order pid record_id fname lname sex age nrn dd2019_nrn
count if dupnrn_2019>0 & nrn!=. & nrn!=dd2019_nrn & _merge!=3 //22 - no matches (used data editor and filtered)
//list pid record_id fname lname age dd2019_age nrn dd2019_nrn addr dd2019_address slc if dupnrn_2019>0 & nrn!=. & _merge!=3, string(38)
** duplicate tumour found
drop if pid=="20150008" //1 deleted

drop duppt_2019
sort lname fname record_id pid
quietly by lname fname :  gen duppt_2019 = cond(_N==1,0,_n)
sort lname fname
count if duppt_2019>0 //125
sort lname fname pid record_id
count if duppt_2019>0 & _merge!=3 //123 - no matches (used data editor and filtered)
** duplicate tumours found
drop if pid=="20150051" //1 deleted


** Remove & change certain death variables
//drop tfdddoa tfddda tfregnumstart tfdistrictstart tfregnumend tfdistrictend tfddtxt recstattf nrnyear checkage2
replace cancer=dd2019_cancer if cancer==. & dd2019_cancer!=. //2772 changes
drop dd2019_cancer
//rename dds2* dd_*

** Remove unmerged deaths
count //3859
drop if pid=="" //2739 deleted
count //1120

** Re-assign deathid / record_id
replace deathid=record_id if deathid==. & record_id!=.
drop record_id

** Save dataset without duplicates & matched with 2019 deaths
label data "BNR-Cancer data - 2015 Incidence: No duplicates"
notes _dta :These data prepared from CanReg5 CLEAN (2015BNR-C) database
save "`datapath'\version02\2-working\2015_cancer_nodups_matched" ,replace
note: TS This dataset can be used for final cleaning

*****************************
**   Final Clean and Prep  **
*****************************
use "`datapath'\version02\2-working\2015_cancer_nodups_matched" ,clear


** Create variable called "deceased" - same as AR's 2008 dofile called '3_merge_cancer_deaths.do'
tab slc ,m
count if slc!=2 & dod!=. //0
gen deceased=1 if slc==2 //627 changes
label var deceased "whether patient is deceased"
label define deceased_lab 1 "dead" 2 "alive at last contact" , modify
label values deceased deceased_lab
replace deceased=2 if slc==1 //493 changes

tab slc deceased ,m

** Create the "patient" variable - same as AR's 2008 dofile called '3_merge_cancer_deaths.do'
gen patient=.  
label var patient "cancer patient"
label define pt_lab 1 "patient" 2 "separate event",modify
label values patient pt_lab
replace patient=1 if eidmp==1 //1108 changes
replace patient=2 if eidmp==2 //12 changes
tab patient ,m

** Convert names to lower case and strip possible leading/trailing blanks
replace fname = lower(rtrim(ltrim(itrim(fname)))) //0 changes
replace init = lower(rtrim(ltrim(itrim(init)))) //870 changes
replace lname = lower(rtrim(ltrim(itrim(lname)))) //0 changes
	  
** Ensure death date is correct IF PATIENT IS DEAD
count if dlc!=dod & slc==2 //48
replace dlc=dod if dlc!=dod & slc==2 //48 changes
format dod %dD_m_CY

count if dodyear==. & dod!=. //70
replace dodyear=year(dod) if dodyear==. & dod!=. //70 changes
count if dod==. & slc==2 //0
//list pid cr5id fname lname nftype dlc if dod==. & slc==2
/*
gen cr5dodyear = year(dod)
label var cr5dodyear "Year of CR5 death"
*/
count if slc==2 & recstatus==3 //0

** Check for cases where cancer=2-not cancer but it has been abstracted
count if cancer==2 & pid!="" //32
sort pid deathid
//list pid deathid fname lname top cr5cod cod if cancer==2 & pid!="", nolabel string(90)
//list cr5cod if cancer==2 & pid!=""
//list cod1a if cancer==2 & pid!=""
** Corrections from above list
replace cod=1 if pid=="20150063"|pid=="20150351"|pid=="20151023"|pid=="20151039"|pid=="20151050"| ///
				 pid=="20151095"|pid=="20151113"|pid=="20151278 "|pid=="20155201" //8 changes
replace cancer=1 if pid=="20150063"|pid=="20150351"|pid=="20151039"|pid=="20151095"|pid=="20151113"|pid=="20151278"|pid=="20155201" //7 changes
//replace dcostatus=1 if pid=="20140047" //1 change
preserve
drop if basis!=0
keep pid fname lname natregno dod cr5cod doctor docaddr certifier
capture export_excel pid fname lname natregno dod cr5cod doctor docaddr certifier using "`datapath'\version02\2-working\DCO2015V04.xlsx", sheet("2015 DCOs_cr5data_20200902") firstrow(variables)
//JC remember to change V01 to V02 when running list a 2nd time!
restore


** Export dataset to run data in IARCcrg Tools (Check Programme)
gen INCIDYR=year(dot)
tostring INCIDYR, replace
gen INCIDMONTH=month(dot)
gen str2 INCIDMM = string(INCIDMONTH, "%02.0f")
gen INCIDDAY=day(dot)
gen str2 INCIDDD = string(INCIDDAY, "%02.0f")
gen INCID=INCIDYR+INCIDMM+INCIDDD
replace INCID="" if INCID=="..." //0 changes
drop INCIDMONTH INCIDDAY INCIDYR INCIDMM INCIDDD
rename INCID dot_iarc
label var dot_iarc "IARC IncidenceDate"

gen BIRTHYR=year(dob)
tostring BIRTHYR, replace
gen BIRTHMONTH=month(dob)
gen str2 BIRTHMM = string(BIRTHMONTH, "%02.0f")
gen BIRTHDAY=day(dob)
gen str2 BIRTHDD = string(BIRTHDAY, "%02.0f")
gen BIRTHD=BIRTHYR+BIRTHMM+BIRTHDD
replace BIRTHD="" if BIRTHD=="..." //17 changes
drop BIRTHDAY BIRTHMONTH BIRTHYR BIRTHMM BIRTHDD
rename BIRTHD dob_iarc
label var dob_iarc "IARC BirthDate"

** mpseq was dropped so need to create
gen mpseq_iarc=0 if persearch==1
replace mpseq_iarc=1 if persearch!=1 & regexm(cr5id,"T1") //12 changes
replace mpseq_iarc=2 if persearch!=1 & !(strmatch(strupper(cr5id), "*T1*")) //10 changes

export delimited pid mpseq_iarc sex topography morph beh grade basis dot_iarc dob_iarc age cr5id eidmp dxyr persearch ///
using "`datapath'\version02\2-working\2015_nonsurvival_iarccrgtools.txt", nolabel replace

/*
IARC crg Tools - see SOP for steps on how to perform below checks:

(1) Perform file transfer using '2015_nonsuvival_iarccrgtools.txt'
(2) Perform check using '2015_iarccrgtools_to check.prn'
(3) Perform multiple primary check using ''

Results of IARC Check Program:
(Titles for each data column: pid sex top morph beh grade basis dot dob age)
    973 records processed
	0 errors
        
	32 warnings
        - 19 unlikely hx/site
		- 2 unlikely grade/hx
        - 10 unlikely basis/hx
		- 1 unlikely age/site/hx
*/
/*	
Results of IARC MP Program:
	21 excluded (non-malignant)
	24 MPs (multiple tumours)
	 0 Duplicate registration
*/
/*
Convert ICD-O-3 DCOs (153) to ICD10, ICCCcode:

*/
** Below updates from warnings/errors report
replace grade=9 if pid=="20151100"
replace grade=9 if pid=="20155222"

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
replace persearch=5 if beh<3 //21 changes

tab persearch ,m
//list pid cr5id if persearch==2
replace persearch=1 if pid=="20151369" //1 change

** Check DCOs
tab basis ,m
** Re-assign dcostatus for cases with updated death trace-back: still pending as of 19feb2020 TBD by NS
tab dcostatus ,m
replace dcostatus=1 if pid=="20150468" & dcostatus==. //1 change; 0 changes
count if dcostatus==2 & basis!=0
//list pid basis if dcostatus==2 & basis!=0 - autopsy w/ hx
/*
replace basis=1 if pid=="20140672" & cr5id=="T2S1"
replace dcostatus=1 if pid=="20140672" & cr5id=="T2S1"
replace nsdate=d(24jul2018) if pid=="20140672" & cr5id=="T2S1"
*/

** Rename cod in prep for death data matching
rename cod codcancer

** Remove non-residents (see IARC validity presentation)
tab resident ,m //45 missing
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
tab resident ,m //15 unknown

** Check parish
count if parish!=. & parish!=99 & addr=="" //0
count if parish==. & addr!="" & addr!="99" //0
//list pid fname lname natregno parish addr if parish!=. & parish!=99 & addr==""
//bysort pid (cr5id) : replace addr = addr[_n-1] if missing(addr) //1 change - 20140566/

** Check missing sex
tab sex ,m //none missing

** Check for missing age & 100+
tab age ,m //2 missing - none are 100+: f/u was done but age not found
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
tab beh ,m //3 benign; 18 in-situ
replace recstatus=3 if pid=="20151095" & cr5id=="T1S1" //1 change
replace recstatus=3 if pid=="20151221" & cr5id=="T1S1" //1 change
replace recstatus=3 if pid=="20151270" & cr5id=="T1S1" //1 change
tab morph if beh!=3 //18 CIN III

** Check for ineligibles
tab recstatus ,m
drop if recstatus==3 //3 deleted

** Check for duplicate tumours
tab persearch ,m //18 excluded

** Check dob
count if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*9999*")) //0
//list pid natregno if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*-9999*"))

** Check age
gen age2 = (dot - dob)/365.25
gen checkage2=int(age2)
drop age2
count if dob!=. & dot!=. & age!=checkage2 //3; 13
//list pid dot dob age checkage2 cr5id if dob!=. & dot!=. & age!=checkage2
replace age=checkage2 if dob!=. & dot!=. & age!=checkage2 //13 changes

** Check no missing dxyr so this can be used in analysis
tab dxyr ,m //0 missing

** To match with 2014 format, convert names to lower case and strip possible leading/trailing blanks
replace fname = lower(rtrim(ltrim(itrim(fname)))) //0 changes
replace init = lower(rtrim(ltrim(itrim(init)))) //0 changes
//replace mname = lower(rtrim(ltrim(itrim(mname)))) //0 changes
replace lname = lower(rtrim(ltrim(itrim(lname)))) //0 changes

count //1117

** Updates to non-2015 dx
** First check in 2008_2013_2014_cancer_nonsurvival_bnr_reportable.dta if to keep/remove them
count if dxyr!=2015 //43
//list pid cr5id fname lname primarysite morph dxyr slc dlc dot if dxyr!=2015
drop if pid=="20080292"|pid=="20080563"|pid=="20140817"|pid=="20141288" & cr5id=="T1S1" //4 deleted

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

tab siteiarc ,m //1 missing
//list pid cr5id primarysite top hx morph icd10 if siteiarc==.
replace iccc="11f" if pid=="20150298" & cr5id=="T1S1" //1 change
replace icd10="C059" if pid=="20150298" & cr5id=="T1S1" //1 change
replace siteiarc=3 if pid=="20150298" & cr5id=="T1S1" //1 change

gen allsites=1 if siteiarc<62 //951 changes - 18 missing values=CIN 3
label var allsites "All sites (ALL)"

gen allsitesbC44=1 if siteiarc<62 & siteiarc!=25
//951 changes - 18 missing values=CIN 3
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

tab siteiarchaem ,m //882 missing - correct!
count if (siteiarc>51 & siteiarc<59) & siteiarchaem==. //1
//list pid cr5id primarysite top hx morph morphcat iccc icd10 if (siteiarc>51 & siteiarc<59) & siteiarchaem==.
replace iccc="12b" if pid=="20159040" & cr5id=="T1S1" //0 changes
replace icd10="C80" if pid=="20159040" & cr5id=="T1S1" //1 change
replace siteiarchaem=15 if pid=="20159040" & cr5id=="T1S1" //1 change


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

tab sitecr5db ,m
//list pid cr5id top morph icd10 if sitecr5db==.
replace sitecr5db=21 if pid=="20159040" & cr5id=="T1S1" //1 change


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


tab siteicd10 ,m // missing - CIN3, beh /0,/1,/2 and MPDs
//list pid cr5id top morph icd10 if siteicd10==.

** Check non-2015 dxyrs are reportable
count if resident==2 & dxyr!=2015 //0
count if resident==99 & dxyr!=2015 //0
count if recstatus==3 & dxyr!=2015 //0
count if sex==9 & dxyr!=2015 //0
count if beh!=3 & dxyr!=2015 //0
count if persearch>2 & dxyr!=2015 //0
count if siteiarc==25 & dxyr!=2015 //0
** Remove non-reportable-non-2015 dx
//none to be removed

tab dxyr ,m

** Create missed 2008 dataset
preserve
drop if dxyr!=2008
list pid dot
count //4; 6

save "`datapath'\version02\2-working\2008_cancer_nonsurvival_2015extras", replace
label data "2015 BNR-Cancer analysed data - 2008 Cases"
note: This dataset was used for 2015 annual report
restore
//import 2008 cases to 2008_cancer_nonsurvival.dta below

** Create missed 2013 dataset
preserve
drop if dxyr!=2013
list pid dot
count //10; 13

save "`datapath'\version02\2-working\2013_cancer_nonsurvival_2015extras", replace
label data "2015 BNR-Cancer analysed data - 2013 Cases"
note: This dataset was used for 2015 annual report
restore

** Create missed 2014 dataset
preserve
drop if dxyr!=2014
list pid dot
count //14; 20

save "`datapath'\version02\2-working\2014_cancer_nonsurvival_2015extras", replace
label data "2015 BNR-Cancer analysed data - 2014 Cases"
note: This dataset was used for 2015 annual report
restore

** Remove reportable-non-2015 dx
drop if dxyr!=2015 //28; 39 deleted

count //1074

** Removing cases not included for international reporting: if case with MPs ensure record with persearch=1 is not dropped as used in survival dataset
duplicates tag pid, gen(dup_id)
//list pid cr5id if persearch==1 & (resident==2|resident==99|recstatus==3|sex==9|beh!=3|siteiarc==25), nolabel sepby(pid)
** Remove further down in this dofile as NS checked MEDDATA for unk residents and data is updated further down (in final clean of 2013-2015 ds)
/*
drop if resident==2 //0 deleted - nonresident
drop if resident==99 //15 deleted - resident unknown
drop if recstatus==3 //0 deleted - ineligible case definition
drop if sex==9 //0 deleted - sex unknown
drop if beh!=3 //18 deleted - nonmalignant
drop if persearch>2 //0 to be deleted; already deleted from above line
drop if siteiarc==25 //0 deleted - nonreportable skin cancers
*/

** Remove cases before 2014 from 2014 dataset
tab dxyr ,m //0 missing
//list pid dot if dxyr==.
//replace dxyr=2015 if dxyr==. //3 changes
//drop if dxyr!=2015 //43 deleted

tab eidmp ,m
/*
     CR5 tumour |
         events |      Freq.     Percent        Cum.
----------------+-----------------------------------
  single tumour |      1,029       98.85       98.85
multiple tumour |         12        1.15      100.00
----------------+-----------------------------------
          Total |      1,041      100.00
*/
tab persearch ,m
/*
              Person Search |      Freq.     Percent        Cum.
----------------------------+-----------------------------------
                   Done: OK |      1,029       98.85       98.85
                   Done: MP |         12        1.15      100.00
----------------------------+-----------------------------------
                      Total |      1,041      100.00
*/

count //1041

** For 2015 using internationally reportable standards, as decided by NS on 06-Oct-2020, email subject: BNR-C: 2015 cancer stats tables completed
** Save this corrected dataset with reportable cases
save "`datapath'\version02\2-working\2015_cancer_nonsurvival", replace
label data "2015 BNR-Cancer analysed data - Non-survival Dataset"
note: TS This dataset was NOT used for 2015 annual report
note: TS Includes ineligible case definition, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs - these are removed in dataset used for analysis

clear

*************************************************
** 2008, 2013, 2014, 2015 Non-survival Dataset **
*************************************************
** This done before 2015 data prepared so can be used by NS at CARPHA
** Load the dataset (2008-2013-2014)
use "`datapath'\version02\3-output\2008_2013_2014_cancer_nonsurvival_bnr_reportable", replace
count //2417; 2961
** 20130414 didn't merge with death 18963 from previous merge when 2014 annual report was done
preserve
drop if pid!="20130414"
replace record_id=18963 if pid=="20130414"
save "`datapath'\version02\2-working\20130414_18963_deathmatching" ,replace
restore

preserve
use "`datapath'\version02\3-output\2015-2018_deaths_for_matching", replace
drop if record_id!=18963
gen pid="20130414"
gen double nrn2=nrn
format nrn2 %15.0g
rename nrn2 natregno
tostring natregno ,replace
save "`datapath'\version02\2-working\18963_20130414_deathmatching" ,replace
restore

preserve
use "`datapath'\version02\2-working\20130414_18963_deathmatching", clear
drop dds2regnum dds2pname dds2age dds2cancer dds2cod1a dds2address dds2parish dds2pod dds2coddeath dds2mname dds2namematch dds2event dds2dddoa dds2ddda dds2odda dds2certtype dds2district dds2agetxt dds2nrnnd dds2mstatus dds2occu dds2durationnum dds2durationtxt dds2onsetnumcod1a dds2onsettxtcod1a dds2cod1b dds2onsetnumcod1b dds2onsettxtcod1b dds2cod1c dds2onsetnumcod1c dds2onsettxtcod1c dds2cod1d dds2onsetnumcod1d dds2onsettxtcod1d dds2cod2a dds2onsetnumcod2a dds2onsettxtcod2a dds2cod2b dds2onsetnumcod2b dds2onsettxtcod2b dds2deathparish dds2regdate dds2certifier dds2certifieraddr dds2cod dds2dod
drop _merge
merge 1:1 natregno using "`datapath'\version02\2-working\18963_20130414_deathmatching"
save "`datapath'\version02\2-working\18963_20130414_deathmatched" ,replace
restore

drop if pid=="20130414"
append using "`datapath'\version02\2-working\18963_20130414_deathmatched"

rename dds2* dd_*

format dd_dod %dD_m_CY
replace slc=2 if pid=="20130414"
replace deceased=1 if pid=="20130414"
replace dod=dd_dod if pid=="20130414"
replace cr5cod=dd_coddeath if pid=="20130414"
replace cod1a_cancer=dd_coddeath if pid=="20130414"
replace cancer=dd_cancer if pid=="20130414"
replace dcostatus=5 if pid=="20130414"

format dd_dod %tdCCYY-NN-DD

append using "`datapath'\version02\2-working\2008_cancer_nonsurvival_2015extras" ,force
count //2421; 2423; 2967
append using "`datapath'\version02\2-working\2013_cancer_nonsurvival_2015extras" ,force
count //2431; 2436; 2980
append using "`datapath'\version02\2-working\2014_cancer_nonsurvival_2015extras" ,force
count //2445; 2456; 3000
append using "`datapath'\version02\2-working\2015_cancer_nonsurvival_bnr_reportable" ,force
count //3349; 3530; 4074

tab dxyr ,m
/*
DiagnosisYe |
         ar |      Freq.     Percent        Cum.
------------+-----------------------------------
       2008 |      1,217       29.87       29.87
       2013 |        883       21.67       51.55
       2014 |        900       22.09       73.64
       2015 |      1,074       26.36      100.00
------------+-----------------------------------
      Total |      4,074      100.00
*/

replace dd_coddeath=cod1a_cancer if (dd_coddeath==""|dd_coddeath=="99") & cod1a_cancer!="" & cod1a_cancer!="99" //1477; 1575 changes
replace cr5cod=dd_coddeath if (cr5cod==""|cr5cod=="99") & dd_coddeath!="" & dd_coddeath!="99" //1123; 1217 changes
replace cod1a_cancer=dd_coddeath if (cod1a_cancer==""|cod1a_cancer=="99") & dd_coddeath!="" & dd_coddeath!="99" //482; 614; 619 changes

** Updates to 2013 cases found during 2015 reviews
replace dlc=d(19may2015) if pid=="20130804" //1 change
replace mname="i" if pid=="20130804" //1 change
replace init="i" if pid=="20130804" //1 change
replace dlc=d(15jan2015) if pid=="20141129" //1 change

** Check for duplicates and/or MPs
drop dupnrn
sort natregno lname fname pid
quietly by natregno :  gen dupnrn = cond(_N==1,0,_n)
sort natregno
count if dupnrn>0 //153; 167; 466 - check pid in Stata results then primarysite & cod1a in Stata data editor
count if dupnrn>0 & !(strmatch(strupper(natregno), "*9999*")) //133; 135; 251
sort lname fname pid
order pid fname lname natregno sex age primarysite cod1a
//list pid cr5id deathid fname lname sex age persearch eidmp namematch dxyr if dupnrn>0 & !(strmatch(strupper(natregno), "*9999*")) ,sepby(pid)

** Duplicate pt; duplicate tumour found - compare in Stata data editor and update and remove accordingly
** 5 missed merges
replace dlc=d(03jul2015) if pid=="20151042" //1 change
replace rx1=1 if pid=="20151042" //1 change
replace rx1d=d(23apr2015) if pid=="20151042" //1 change
replace rx2=8 if pid=="20151042" //1 change
replace rx2d=d(03jul2015) if pid=="20151042" //1 change
replace notesseen=1 if pid=="20151042" //1 change
replace nsdate=d(07mar2019) if pid=="20151042" //1 change
replace orxcheckcat=1 if pid=="20151042" //1 change
drop if pid=="20151368" //1 deleted

replace dot=d(29oct2015) if pid=="20150456" //1 change
replace dot_iarc="20151029" if pid=="20150456" //1 change
drop if pid=="20150204" //1 deleted

replace fname=subinstr(fname,"gu","gue",.) if pid=="20150302" //1 change
replace lname=subinstr(lname,"te","le",.) if pid=="20150302" //1 change
drop if pid=="20150563" //1 deleted

replace hx=subinstr(hx,"T ","T CELL ACUTE",.) if pid=="20150314" //1 change
replace hx=subinstr(hx,"T ","T CELL ACUTE",.) if pid=="20150314" //1 change
replace iccc="1a" if pid=="20150314" //1 change
replace icd10="C910" if pid=="20150314" //1 change
replace morph=9837 if pid=="20150314" //1 change
replace morphology="9837" if pid=="20150314" //1 change
replace morphcat=51 if pid=="20150314" //1 change
replace hxfamcat=. if pid=="20150314" //1 change
replace siteiarc=56 if pid=="20150314" //1 change
replace siteiarchaem=11 if pid=="20150314" //1 change
replace sitecr5db=22 if pid=="20150314" //1 change
drop if pid=="20150008" //1 deleted

replace cr5id="T3S1" if pid=="20151147" //1 change
replace eidmp=2 if pid=="20151147" & cr5id=="T3S1" //1 change
replace persearch=2 if pid=="20151147" & cr5id=="T3S1" //1 change
replace ptrectot=3 if pid=="20151147" & cr5id=="T3S1" //1 change
replace mpseq=3 if pid=="20151147" & cr5id=="T3S1" //1 change
replace mptot=3 if pid=="20151147" & cr5id=="T3S1" //1 change
replace pid="20080295" if pid=="20151147" & cr5id=="T3S1" //1 change
replace mpseq=1 if pid=="20080295" & cr5id=="T1S1" //0 changes
replace mptot=3 if pid=="20080295" & cr5id=="T1S1" //1 change
replace mpseq=2 if pid=="20080295" & cr5id=="T2S1" //0 changes
replace mptot=3 if pid=="20080295" & cr5id=="T2S1" //1 change
replace patient=2 if pid=="20080295" & cr5id=="T3S1"|pid=="20080295" & cr5id=="T2S1" //1 change
replace lname=subinstr(lname," - ","-",.) if pid=="20080295" //2 changes
replace lname=subinstr(lname,"on","er",.) if pid=="20080295" & cr5id=="T3S1" //1 change
replace cr5cod="" if pid=="20080295" & cr5id=="T1S1"|pid=="20080295" & cr5id=="T2S1" //2 changes
bysort pid : replace cr5cod = cr5cod[_n-1] if cr5cod=="" & pid=="20080295" //1 change
bysort pid : replace cr5cod = cr5cod[_n+1] if cr5cod=="" & pid=="20080295" //1 change
bysort pid : replace cr5cod = cr5cod[_n+2] if cr5cod=="" & pid=="20080295" //1 change
bysort pid : replace deathid = deathid[_n-1] if missing(deathid) & pid=="20080295" //1 change
bysort pid : replace deathid = deathid[_n+1] if missing(deathid) & pid=="20080295" //1 change
bysort pid : replace cancer = cancer[_n-1] if missing(cancer) & pid=="20080295" //1 change
bysort pid : replace cancer = cancer[_n+1] if missing(cancer) & pid=="20080295" //1 change
bysort pid : replace codcancer = codcancer[_n-1] if missing(codcancer) & pid=="20080295" //1 change
bysort pid : replace codcancer = codcancer[_n+1] if missing(codcancer) & pid=="20080295" //1 change

replace dlc=d(22jan2019) if pid=="20150247" //1 change
drop if pid=="20190030" //1 deleted

swapval fname lname if pid=="20140959" //ssc install swapval
replace dlc=d(04feb2015) if pid=="20140959" //1 change
drop if pid=="20150258" //1 deleted

replace morph=8140 if pid=="20155104" & cr5id=="T1S1" //1 change
replace morphology="8140" if pid=="20155104" & cr5id=="T1S1" //1 change
replace morphcat=6 if pid=="20155104" & cr5id=="T1S1" //1 change
replace top="161" if pid=="20155104" & cr5id=="T1S1" //1 change
replace topography=161 if pid=="20155104" & cr5id=="T1S1" //1 change
replace primarysite=subinstr(primarysite,"H","H-FUNDUS",.) if pid=="20155104" & cr5id=="T1S1" //1 change
replace grade=3 if pid=="20155104" & cr5id=="T1S1" //1 change
replace str_grade="3" if pid=="20155104" & cr5id=="T1S1" //1 change
replace iccc="11f" if pid=="20155104" & cr5id=="T1S1" //1 change
replace icd10="C161" if pid=="20155104" & cr5id=="T1S1" //1 change
drop if pid=="20150275" //1 deleted

replace eidmp=2 if pid=="20130885" & cr5id=="T2S1" //1 change
replace persearch=2 if pid=="20130885" & cr5id=="T2S1" //1 change
replace ptrectot=3 if pid=="20130885" & cr5id=="T2S1" //1 change
replace patient=2 if pid=="20130885" & cr5id=="T2S1" //1 change
replace mpseq=2 if pid=="20130885" & cr5id=="T2S1" //1 change
replace mptot=2 if pid=="20130885" & cr5id=="T2S1" //1 change
replace mpseq=1 if pid=="20130885" & cr5id=="T1S1" //0 changes
replace mptot=2 if pid=="20130885" & cr5id=="T1S1" //1 change
replace dlc=dod if pid=="20130885" & cr5id=="T1S1" //1 change

replace eidmp=2 if pid=="20080048" & cr5id=="T2S1" //1 change
replace persearch=2 if pid=="20080048" & cr5id=="T2S1" //1 change
replace ptrectot=3 if pid=="20080048" & cr5id=="T2S1" //1 change
replace patient=2 if pid=="20080048" & cr5id=="T2S1" //1 change
replace mpseq=2 if pid=="20080048" & cr5id=="T2S1" //1 change
replace mptot=2 if pid=="20080048" & cr5id=="T2S1" //1 change
replace mpseq=1 if pid=="20080048" & cr5id=="T1S1" //0 changes
replace mptot=2 if pid=="20080048" & cr5id=="T1S1" //1 change
replace dlc=d(10dec2018) if pid=="20080048" & cr5id=="T1S1" //1 change

replace dlc=dod if pid=="20130414" & cr5id=="T1S1" //1 change
drop if pid=="20159137" //1 deleted - duplicate of above pid

replace eidmp=2 if pid=="20080679" & cr5id=="T2S1" //1 change
replace persearch=2 if pid=="20080679" & cr5id=="T2S1" //1 change
replace ptrectot=3 if pid=="20080679" & cr5id=="T2S1" //1 change
replace patient=2 if pid=="20080679" & cr5id=="T2S1" //1 change
replace mpseq=2 if pid=="20080679" & cr5id=="T2S1" //1 change
replace mptot=2 if pid=="20080679" & cr5id=="T2S1" //1 change
replace mpseq=1 if pid=="20080679" & cr5id=="T1S1" //0 changes
replace mptot=2 if pid=="20080679" & cr5id=="T1S1" //1 change
replace dlc=d(14aug2015) if pid=="20080679" & cr5id=="T1S1" //1 change

drop if pid=="20150292" //1 deleted

replace parish=1 if pid=="20080588"
replace init="l" if pid=="20080588"
replace dlc=d(30jul2014) if pid=="20080588"
replace slc=1 if pid=="20080588"
replace deceased=2 if pid=="20080588"
replace dcostatus=6 if pid=="20080588"
replace morph=8140 if pid=="20080588"
replace morphcat=6 if pid=="20080588"
replace morphology="8140" if pid=="20080588"
replace hx=subinstr(hx,"SUSPICIOUS FOR ","ACINAR ADENO",.) if pid=="20080588" //1 change
replace cr5id="T2S1" if pid=="20141426"
replace pid="20080588" if pid=="20141426"
replace addr="" if pid=="20080588" & cr5id=="T1S1"
bysort pid : replace addr = addr[_n-1] if addr=="" & pid=="20080588" //1 change
bysort pid : replace addr = addr[_n+1] if addr=="" & pid=="20080588" //1 change
//bysort pid : replace addr = addr[_n+1] if addr=="" & pid=="20080588" //1 change
drop if pid=="20080588" & cr5id=="T2S1" //1 deleted

replace cr5id="T2S1" if pid=="20150484" //1 change
replace eidmp=2 if pid=="20150484" & cr5id=="T2S1" //1 change
replace persearch=2 if pid=="20150484" & cr5id=="T2S1" //1 change
replace ptrectot=3 if pid=="20150484" & cr5id=="T2S1" //1 change
replace mpseq=2 if pid=="20150484" & cr5id=="T2S1" //1 change
replace mptot=2 if pid=="20150484" & cr5id=="T2S1" //1 change
replace pid="20141031" if pid=="20150484" & cr5id=="T2S1" //1 change
replace mpseq=1 if pid=="20141031" & cr5id=="T1S1" //0 changes
replace mptot=2 if pid=="20141031" & cr5id=="T1S1" //1 change
replace patient=2 if pid=="20141031" & cr5id=="T2S1" //1 change
replace dlc=d(16jun2015) if pid=="20141031" & cr5id=="T1S1" //1 change

replace cr5cod=subinstr(cr5cod,"NA","CT",.) if pid=="20141067"|pid=="20150529" //2 changes
replace dd_coddeath=subinstr(dd_coddeath,"NA","CT",.) if pid=="20141067"|pid=="20150529" //2 changes
replace cr5id="T2S1" if pid=="20150529" //1 change
replace eidmp=2 if pid=="20150529" & cr5id=="T2S1" //1 change
replace persearch=2 if pid=="20150529" & cr5id=="T2S1" //1 change
replace ptrectot=3 if pid=="20150529" & cr5id=="T2S1" //1 change
replace mpseq=2 if pid=="20150529" & cr5id=="T2S1" //1 change
replace mptot=2 if pid=="20150529" & cr5id=="T2S1" //1 change
replace pid="20141067" if pid=="20150529" & cr5id=="T2S1" //1 change
replace mpseq=1 if pid=="20141067" & cr5id=="T1S1" //0 changes
replace mptot=2 if pid=="20141067" & cr5id=="T1S1" //1 change
replace patient=2 if pid=="20141067" & cr5id=="T2S1" //1 change

replace fname=subinstr(fname,"e","a",.) if pid=="20141306" //1 change
replace cr5id="T2S1" if pid=="20141306" //1 change
replace eidmp=2 if pid=="20141306" & cr5id=="T2S1" //1 change
replace persearch=2 if pid=="20141306" & cr5id=="T2S1" //1 change
replace ptrectot=3 if pid=="20141306" & cr5id=="T2S1" //1 change
replace mpseq=2 if pid=="20141306" & cr5id=="T2S1" //1 change
replace mptot=2 if pid=="20141306" & cr5id=="T2S1" //1 change
drop if pid=="20150506" & cr5id=="T2S1" //1 deleted
replace pid="20150506" if pid=="20141306" & cr5id=="T2S1" //1 change
replace mpseq=1 if pid=="20150506" & cr5id=="T1S1" //0 changes
replace mptot=2 if pid=="20150506" & cr5id=="T1S1" //1 change
replace codcancer=1 if pid=="20150506" & cr5id=="T1S1" //1 change
replace patient=2 if pid=="20150506" & cr5id=="T2S1" //1 change

drop if pid=="20151174" //1 deleted

drop if pid=="20150051" //1 deleted

replace cr5id="T2S1" if pid=="20150398" //1 change
replace eidmp=2 if pid=="20150398" & cr5id=="T2S1" //1 change
replace persearch=2 if pid=="20150398" & cr5id=="T2S1" //1 change
replace ptrectot=3 if pid=="20150398" & cr5id=="T2S1" //1 change
replace mpseq=2 if pid=="20150398" & cr5id=="T2S1" //1 change
replace mptot=2 if pid=="20150398" & cr5id=="T2S1" //1 change
replace pid="20141393" if pid=="20150398" & cr5id=="T2S1" //1 change
replace mpseq=1 if pid=="20141393" & cr5id=="T1S1" //0 changes
replace mptot=2 if pid=="20141393" & cr5id=="T1S1" //1 change
replace patient=2 if pid=="20141393" & cr5id=="T2S1" //1 change

replace fname=subinstr(fname,"nn","n",.) if pid=="20150408" //1 change
replace dlc=d(02nov2015) if pid=="20150408" //1 change
replace grade=2 if pid=="20150408" //1 change
drop if pid=="20150143" //1 deleted

** Check for duplicates by patient name
drop duppt
sort lname fname pid
quietly by lname fname :  gen duppt = cond(_N==1,0,_n)
sort lname fname pid
count if duppt>0 //184; 190; 364 - check pid in Stata results then primarysite & cod1a in Stata data editor for ones not matched in above 
//list pid cr5id fname lname natregno sex age top eidmp persearch ptrectot patient namematch dxyr if duppt>0 ,sepby(pid) string(10)
order pid fname lname natregno sex age primarysite cod1a
//list pid deathid fname lname natregno sex age persearch nm if duppt>0
rename namematch nm
replace nm=1 if pid=="20080196"
replace nm=1 if pid=="20155227"
replace nm=1 if pid=="20130162"
replace nm=1 if pid=="20155196"
replace nm=1 if pid=="20140907"
replace nm=1 if pid=="20155203"
replace nm=1 if pid==""
drop if pid=="20150287" //1 deleted; duplicate of pid=20150112
drop if pid=="20150268" //1 deleted; duplicate of 20145044
replace nm=1 if pid=="20150112"
replace nm=1 if pid=="20150287"
replace nm=1 if pid=="20150297"
replace nm=1 if pid=="20130079"
replace nm=1 if pid=="20155152"
replace nm=1 if pid=="20081035"
replace nm=1 if pid=="20155010"
replace nm=1 if pid=="20080408"
replace nm=1 if pid=="20150036"
replace nm=1 if pid=="20151184"
replace nm=1 if pid=="20140369"
replace nm=1 if pid=="20150351"
replace nm=1 if pid=="20080983"
replace nm=1 if pid=="20155072"
replace nm=. if pid=="20140176"
replace nm=. if pid=="20140339"
replace nm=1 if pid=="20130644"
replace nm=1 if pid=="20150463"
replace nm=. if pid=="20140786"
replace nm=1 if pid=="20080977"
replace nm=1 if pid=="20151180"
replace nm=1 if pid=="20150432"
replace nm=1 if pid=="20151177"
replace nm=. if pid=="20140672"
replace nm=1 if pid=="20080350"
replace nm=1 if pid=="20150550"
replace nm=1 if pid=="20141439"
replace nm=1 if pid=="20150498"
replace nm=1 if pid=="20080132"
replace nm=1 if pid=="20151244"
replace nm=. if pid=="20140077"
replace nm=1 if pid=="20080827"
replace nm=1 if pid=="20150403"
replace ptrectot=3 if pid=="20080567" & cr5id=="T2S1"
replace patient=2 if pid=="20080567" & cr5id=="T2S1"
replace eidmp=2 if pid=="20080567" & cr5id=="T2S1"

** Check eidmp
count if eidmp==. //0
count if patient==2 & eidmp!=2 //0
count if patient==1 & eidmp!=1 //0
count if eidmp!=2 & ptrectot==3 //22; 28
sort pid lname fname
order pid cr5id fname lname patient eidmp ptrectot dcostatus
//list pid cr5id fname lname patient eidmp ptrectot dcostatus if eidmp!=2 & ptrectot==3
replace patient=1 if pid=="20080215" & cr5id=="T1S1"
replace eidmp=1 if pid=="20080215" & cr5id=="T1S1"
replace patient=2 if pid=="20080215" & cr5id=="T3S1"
replace eidmp=2 if pid=="20080215" & cr5id=="T3S1"
replace patient=1 if pid=="20080381" & cr5id=="T1S1"
replace eidmp=1 if pid=="20080381" & cr5id=="T1S1"
replace patient=2 if pid=="20080381" & cr5id=="T2S1"
replace eidmp=2 if pid=="20080381" & cr5id=="T2S1"
replace patient=1 if pid=="20080460" & cr5id=="T1S1"
replace eidmp=1 if pid=="20080460" & cr5id=="T1S1"
replace patient=2 if pid=="20080460" & cr5id=="T2S1"
replace eidmp=2 if pid=="20080460" & cr5id=="T2S1"
replace patient=1 if pid=="20080662" & cr5id=="T1S1"
replace eidmp=1 if pid=="20080662" & cr5id=="T1S1"
replace patient=2 if pid=="20080662" & cr5id=="T2S1"
replace eidmp=2 if pid=="20080662" & cr5id=="T2S1"
replace patient=1 if pid=="20080733" & cr5id=="T1S1"
replace eidmp=1 if pid=="20080733" & cr5id=="T1S1"
replace patient=2 if pid=="20080733" & cr5id=="T4S1"
replace eidmp=2 if pid=="20080733" & cr5id=="T4S1"
replace patient=1 if pid=="20080738" & cr5id=="T1S1"
replace eidmp=1 if pid=="20080738" & cr5id=="T1S1"
replace patient=2 if pid=="20080738" & cr5id=="T2S1"
replace eidmp=2 if pid=="20080738" & cr5id=="T2S1"
replace patient=1 if pid=="20080739" & cr5id=="T1S1"
replace eidmp=1 if pid=="20080739" & cr5id=="T1S1"
replace patient=2 if pid=="20080739" & cr5id=="T3S1"
replace eidmp=2 if pid=="20080739" & cr5id=="T3S1"
replace ptrectot=1 if pid=="20080705"
replace ptrectot=1 if pid=="20140077" & cr5id=="T1S1"
replace ptrectot=1 if pid=="20140176" & cr5id=="T1S1"
replace ptrectot=1 if pid=="20140474"
replace ptrectot=1 if pid=="20140555"
replace ptrectot=1 if pid=="20140566" & cr5id=="T1S1"
replace ptrectot=1 if pid=="20140570" & cr5id=="T1S1"
replace ptrectot=1 if pid=="20140690" & cr5id=="T1S1"
replace ptrectot=1 if pid=="20140786" & cr5id=="T1S1"
replace ptrectot=1 if pid=="20140887"
replace ptrectot=1 if pid=="20141351"
replace ptrectot=1 if pid=="20150238" & cr5id=="T1S1"
replace ptrectot=1 if pid=="20150277" & cr5id=="T1S1"
replace ptrectot=1 if pid=="20150468" & cr5id=="T1S1"
replace ptrectot=1 if pid=="20150506" & cr5id=="T1S1"
replace ptrectot=1 if pid=="20151200" & cr5id=="T1S1"
replace ptrectot=1 if pid=="20151202" & cr5id=="T1S1"
replace ptrectot=1 if pid=="20151236" & cr5id=="T1S1"
replace ptrectot=1 if pid=="20155043" & cr5id=="T1S1"
replace ptrectot=1 if pid=="20155094" & cr5id=="T1S1"
replace ptrectot=1 if pid=="20155104" & cr5id=="T1S1"

** Check patient
count if patient==. //0
count if patient==1 & eidmp==2 //0
count if patient==1 & ptrectot==3 //0

** Check ptrectot
count if ptrectot==. //0
count if ptrectot==1 & eidmp==2 //7; 8
count if patient==2 & ptrectot==1 //7; 8
//list pid cr5id fname lname patient eidmp ptrectot dcostatus if ptrectot==1 & eidmp==2
//list pid cr5id fname lname patient eidmp ptrectot dcostatus if patient==2 & ptrectot==1
replace ptrectot=3 if ptrectot==1 & eidmp==2 //7; 8 changes

** Check persearch
count if persearch==. //0
count if persearch==1 & eidmp==2 //2; 8
count if persearch==2 & eidmp==1 //1
//list pid cr5id fname lname patient eidmp ptrectot dcostatus persearch if persearch==1 & eidmp==2
//list pid cr5id fname lname patient eidmp ptrectot dcostatus persearch if persearch==2 & eidmp==1
replace persearch=2 if pid=="20080567" & cr5id=="T2S1" //1 change
replace persearch=2 if pid=="20080215" & cr5id=="T3S1" //1 change
replace persearch=1 if pid=="20080215" & cr5id=="T1S1" //1 change
replace persearch=2 if pid=="20080381" & cr5id=="T2S1" //1 change
replace persearch=2 if pid=="20080460" & cr5id=="T2S1" //1 change
replace persearch=2 if pid=="20080662" & cr5id=="T2S1" //1 change
replace persearch=2 if pid=="20080733" & cr5id=="T4S1" //1 change
replace persearch=2 if pid=="20080738" & cr5id=="T2S1" //1 change
replace persearch=2 if pid=="20080739" & cr5id=="T3S1" //1 change

** Check dcostatus
count if dcostatus==. //0
count if slc==2 & dcostatus==. //0

** Check slc
count if slc==. //0
count if slc!=2 & dod!=. //1
count if slc!=2 & deceased==1 //0
//list pid cr5id fname lname patient eidmp ptrectot dcostatus slc deceased dod if slc!=2 & dod!=.
count if dod==. & slc==2 //0
replace dod=. if slc!=2 & dod!=. //1 change

** Check deceased
tab deceased slc ,m 
count if deceased==2 & slc==2 //0 
count if deceased==1 & slc==1 //0
//list pid fname lname natregno dlc dod if deceased==2 & slc==2


** mpseq was dropped so need to create
drop mpseq_iarc
gen mpseq_iarc=0 if persearch==1
replace mpseq_iarc=1 if persearch!=1 & regexm(cr5id,"T1") //1 change
replace mpseq_iarc=2 if persearch!=1 & !(strmatch(strupper(cr5id), "*T1*")) //48 changes

export delimited pid mpseq_iarc sex topography morph beh grade basis dot_iarc dob_iarc age cr5id dxyr eidmp persearch patient ///
using "`datapath'\version02\2-working\2008_2013_2014_2015_nonsurvival_iarccrgtools.txt", nolabel replace

** Perform MP check to identify MPs in 'multi-year' dataset and correctly assign persearch and mpseq
/*
IARC crg Tools - see SOP for steps on how to perform below checks:

(1) Perform file transfer using '2008_nonsuvival_iarccrgtools.txt'
(2) Perform check using '2008_iarccrgtools_to check.prn'
(3) Perform multiple primary check using ''

Results of IARC Check Program:
(Titles for each data column: pid sex top morph beh grade basis dot dob age)
    3335 records processed
	1 errors
        
	134 warnings
        - 37 unlikely hx/site
		- 38 unlikely grade/hx
        - 58 unlikely basis/hx
		- 1 unlikely age/site/hx
*/
/*	
Results of IARC MP Program:
	0 excluded (non-malignant)
	115 MPs (multiple tumours)
	 0 Duplicate registration
*/
** Updates from errors report
replace age=89 if pid=="20080887"
** Updates from warnings report

** Updates for multiple primary report:
replace patient=2 if pid=="20130410" & cr5id=="T2S1"
replace eidmp=2 if pid=="20130410" & cr5id=="T2S1"
replace persearch=2 if pid=="20130410" & cr5id=="T2S1"
replace patient=2 if pid=="20130885" & cr5id=="T2S1"
replace eidmp=2 if pid=="20130885" & cr5id=="T2S1"
replace persearch=2 if pid=="20130885" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20140570" & dxyr==2013
replace cr5id="T2S1" if pid=="20140570" & dxyr==2014
replace patient=1 if pid=="20140570" & cr5id=="T1S1"
replace eidmp=1 if pid=="20140570" & cr5id=="T1S1"
replace persearch=1 if pid=="20140570" & cr5id=="T1S1"
replace ptrectot=1 if pid=="20140570" & cr5id=="T1S1"
replace patient=2 if pid=="20140570" & cr5id=="T2S1"
replace eidmp=2 if pid=="20140570" & cr5id=="T2S1"
replace persearch=2 if pid=="20140570" & cr5id=="T2S1"
replace ptrectot=3 if pid=="20140570" & cr5id=="T2S1"
replace patient=2 if pid=="20141288" & cr5id=="T2S1"
replace eidmp=2 if pid=="20141288" & cr5id=="T2S1"
replace persearch=2 if pid=="20141288" & cr5id=="T2S1"
replace patient=2 if pid=="20141379" & cr5id=="T2S1"
replace eidmp=2 if pid=="20141379" & cr5id=="T2S1"
replace persearch=2 if pid=="20141379" & cr5id=="T2S1"
replace patient=2 if pid=="20145070" & cr5id=="T2S1"
replace eidmp=2 if pid=="20145070" & cr5id=="T2S1"
replace persearch=2 if pid=="20145070" & cr5id=="T2S1"
replace patient=2 if pid=="20151020" & cr5id=="T3S1"
replace eidmp=2 if pid=="20151020" & cr5id=="T3S1"
replace persearch=2 if pid=="20151020" & cr5id=="T3S1"

tab persearch ,m
replace persearch=4 if persearch==5 //18 changes

** Update mpseq mptot - 20080295 already corrected!
/*
list pid cr5id fname lname eidmp persearch ptrectot dcostatus mpseq mptot , inrange(obsid, 0, 900) sepby(pid)
list pid cr5id fname lname eidmp persearch ptrectot dcostatus mpseq mptot , inrange(obsid, 901, 1800) sepby(pid)
list pid cr5id fname lname eidmp persearch ptrectot dcostatus mpseq mptot , inrange(obsid, 1801, 2700) sepby(pid)
list pid cr5id fname lname eidmp persearch ptrectot dcostatus mpseq mptot , inrange(obsid, 2701, 3350) sepby(pid)
replace mpseq=0 if eidmp==1
replace mpseq=1 if eidmp==2
replace mptot=1 if eidmp==1
replace mptot=2 if eidmp==2
*/

** Check parish
count if parish!=. & parish!=99 & addr=="" //0
count if parish==. & addr!="" & addr!="99" //0
//list pid fname lname natregno parish addr if parish!=. & parish!=99 & addr==""

** Check missing sex
tab sex ,m //none missing

** Check for missing age & 100+
tab age ,m //3 missing - 4 are 100+; 2 are 0 age

** Check for missing follow-up
tab slc ,m //none missing
tab deceased ,m //none missing and parallels slc correctly
//tab dlc ,m //none missing
** Check missing in CR5db
//list pid if slc==99

** Check DCOs
tab basis ,m //146; 267; 272
** Re-assign dcostatus for cases with updated death trace-back
tab dcostatus ,m
//list pid basis dcostatus if basis==0 & dcostatus!=2
count if basis!=0 & dcostatus==2 //4-correct as autop w/ hx
replace dcostatus=2 if basis==0
//list pid cr5id basis dcostatus if basis!=0 & dcostatus==2

replace dcostatus=1 if slc==2 & basis!=0 //33; 35; 65 changes
replace dcostatus=6 if slc!=2 //0 changes
replace dcostatus=2 if basis==0 //0 changes

** Check for ineligibles
tab recstatus ,m //0 ineligible

** Check for non-malignant
tab beh ,m
/*
  Behaviour |      Freq.     Percent        Cum.
------------+-----------------------------------
     Benign |          8        0.20        0.20
  Uncertain |         10        0.25        0.44
    In situ |        134        3.30        3.74
  Malignant |      3,908       96.26      100.00
------------+-----------------------------------
      Total |      4,060      100.00
*/

** Check for duplicate tumours
tab persearch ,m //56; 60 MPs; 0 dups; 18 excluded (in-situ)

** Check dob
count if dob==. //27; 37; 156 -all missing natregno
//list pid cr5id age natregno nrn birthdate if dob==.
//count if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*99-*")) //0
//list pid age natregno if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*99-*"))
/*
gen birthd=substr(natregno,1,6) if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*99-*"))
destring birthd, replace
format birthd %06.0f
nsplit birthd, digits(2 2 2) gen(year month day)
format year month day %02.0f
tostring year, replace
replace year="19"+year
destring year, replace
gen dob2=mdy(month, day, year)
format dob2 %dD_m_CY
replace dob=dob2 if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*99-*")) //47 changes
drop birthd year month day dob2
*/

** Check age
gen age2 = (dot - dob)/365.25
drop checkage2
gen checkage2=int(age2)
drop age2
count if dob!=. & dot!=. & age!=checkage2 //1
//list pid dot dob age checkage2 cr5id if dob!=. & dot!=. & age!=checkage2 //0 correct
replace age=checkage2 if dob!=. & dot!=. & age!=checkage2 //1 change

** Check no missing dxyr so this can be used in analysis
tab dxyr ,m 
/*
DiagnosisYe |
         ar |      Freq.     Percent        Cum.
------------+-----------------------------------
       2008 |      1,217       29.98       29.98
       2013 |        883       21.75       51.72
       2014 |        898       22.12       73.84
       2015 |      1,062       26.16      100.00
------------+-----------------------------------
      Total |      4,060      100.00
*/

** Check for missing for cancer field
/*
replace natregno=subinstr(natregno,"-","",.)
rename address address_cancer
replace addr=subinstr(addr,"9999 ","",.)
replace addr=subinstr(addr,"99 ","",.)
count if regexm(address,"99") //0 - didn't replace true value for house #=99
rename cod1a cod1a_cancer
*/
count if cancer==. & slc==2 //47
//list pid deathid fname lname natregno dod if cancer==. & slc==2
tab notindd dxyr,m
count if cancer==. & slc==2 & notindd==. //34; 33
replace notindd=1 if cancer==. & slc==2 & notindd==. //34; 33 changes
count if cancer==1 & slc==2 & notindd==. //1781; 1794; 1964; 2006
replace notindd=2 if cancer==1 & slc==2 & notindd==. //1781; 1794; 1964; 2006 changes
count if cancer==2 & slc==2 & notindd==. //165; 164; 220
replace notindd=2 if cancer==2 & slc==2 & notindd==. //165; 164; 220 changes
count if notindd==. & slc!=2 //1339; 1784
/*
gen notindd=1 if cancer==. & slc==2 //14
replace notindd=2 if pid=="20130331"|pid=="20080885"
label var notindd "Not found in death data"
label define notindd_lab 1 "Searched, not found" 2 "Searched, found", modify
label values notindd notindd_lab
*/
count if cancer!=. & slc!=2 //0
//list pid deathid fname lname natregno dod if cancer!=. & slc!=2
replace cancer=. if cancer!=. & slc!=2 //387; 0 changes

** Update cancer variable if cod indicates cancer (check against 2008-2020 death data file)
count if cancer==. & slc==2 //47
//list pid deathid fname lname dd_coddeath if cancer==. & slc==2, string(100)
replace cod1a_cancer="REFRACTORY MULTIPLE MYELOMA ACUTE CONGESTIVE CARDIAC FAILURE CARDIAC AMYLOIDOSIS" if pid=="20150005"
replace cod1a_cancer="ASPIRATION PNEUMONIA DYSPHAGIA MULTIPLE MYELOMA" if pid=="20150007"
replace cod1a_cancer="REFRACTORY MULTIPLE MYELOMA" if pid=="20150031"
replace cod1a_cancer=cr5cod if cancer==. & slc==2 & cod1a_cancer=="" & cr5cod!="" //37 changes
label define cancer 1 "cancer" 2 "not cancer" 3 "unknown" ,modify
replace cancer=3 if cancer==. & slc==2 & cod1a_cancer=="99" //15 changes
replace cancer=1 if cancer==. & slc==2 //32 changes


** Check missing for cod field
count if cod==. & slc==2 //2175; 2274
count if dd_cod==. & slc==2 //2113; 2212
replace cod=dd_cod if dd_cod!=. & cod==. //63 changes
count if cod==. & slc==2 //2112; 2211
replace cod=1 if cancer==1 //1944; 1986 changes
replace cod=2 if cancer==2 //154; 210 changes
** one unknown causes of death in 2014 data - record_id 12323
replace cod=3 if cod1a_cancer=="99"|(regexm(cod1a_cancer,"INDETERMINATE")|regexm(cod1a_cancer,"UNDETERMINED")) //14; 15 changes
count if cod==. & slc==2 //0


count if slc==2 & dod==. //0
drop dodyear
gen dodyear_cancer=year(dod)
tab dodyear ,m
count if slc!=2 & dod!=. //0

drop dotyear
gen dotyear=year(dot)
tab dotyear ,m
/*
    dotyear |      Freq.     Percent        Cum.
------------+-----------------------------------
       2008 |      1,217       29.98       29.98
       2013 |        883       21.75       51.72
       2014 |        898       22.12       73.84
       2015 |      1,062       26.16      100.00
------------+-----------------------------------
      Total |      4,060      100.00
*/

** Check dot
count if dot>dlc //1
//list pid cr5id dot dlc if dot>dlc
replace dlc=d(07feb2013) if pid=="20080340"


** Check resident=yes if there's a local address (added on 12-Oct-2020 based on feedback from SF: see IARC, IARC-HUB, SEER publications)
count if resident!=1 & addr!="" & addr!="99" //6
//list pid fname lname resident addr if resident!=1 & addr!="" & addr!="99"
replace resident=1 if pid=="20081112"
replace resident=1 if pid=="20130397"
//replace resident=1 if pid=="20140456" - addr listed as QEH
replace resident=1 if pid=="20140545"
replace resident=1 if pid=="20140563"
//replace resident=1 if pid=="20140608" - addr listed as a guest house

** Update unk residents NS found in MEDDATA (23-Oct-2020)
preserve
clear
import excel using "`datapath'\version02\1-input\2013-2015MissingResidentsV01_NS.xlsx" , firstrow case(lower)
tostring pid ,replace
format ns_dot %dD_m_CY
format ns_natregno %15.0g
tostring ns_natregno ,replace
format ns_dob %dD_m_CY
format ns_dlc %dD_m_CY
format ns_dod %dD_m_CY
save "`datapath'\version02\2-working\2013-2015_unk_resident" ,replace
restore

drop _merge
merge 1:1 pid cr5id using "`datapath'\version02\2-working\2013-2015_unk_resident"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         3,947
        from master                     3,947  (_merge==1)
        from using                          0  (_merge==2)

    matched                               113  (_merge==3)
    -----------------------------------------
*/

replace init=ns_init if ns_init!="" //60 changes
replace natregno=ns_natregno if ns_natregno!="" //65 changes
replace dob=ns_dob if ns_dob!=. //67 changes
replace age=ns_age if ns_age!=. //8 changes
replace resident=ns_resident if ns_resident!=. //73 changes
replace slc=ns_slc if ns_slc!=. //14 changes
replace dlc=ns_dlc if ns_dlc!=. //14 changes
replace dod=ns_dod if ns_dod!=. //14 changes
replace cod=ns_cod if ns_cod!=. //14 changes
replace cancer=ns_cancer if ns_cancer!=. //14 changes
replace deceased=ns_deceased if ns_deceased!=. //14 changes
replace dd_coddeath=ns_dd_coddeath if ns_dd_coddeath!="" //15 changes
replace dd_cod1a=ns_dd_cod1a if ns_dd_cod1a!="" //15 changes
replace deathid=ns_deathid if ns_deathid!=. //15 changes
replace addr=ns_addr if ns_addr!="" //64 changes
replace dd_addr=ns_dd_addr if ns_dd_addr!="" //15 changes
replace dd_pod=ns_dd_pod if ns_dd_pod!="" //15 changes
replace dd_deathparish=ns_dd_deathparish if ns_dd_deathparish!=. //15 changes
replace parish=ns_parish if ns_parish!=. //65 changes
replace doctor=ns_doctor if ns_doctor!="" //0 changes

replace fname=ns_fname if pid=="20151107" & cr5id=="T1S1" //1 change
replace lname=ns_lname if pid=="20151107" & cr5id=="T1S1" //1 change

drop ns_* _merge

** Duplicate (same as pid 20130414) found incidentally in reviewing NS' MEDDATA list
drop if pid=="20130685"


** To match with 2014 format, convert names to lower case and strip possible leading/trailing blanks
replace fname = lower(rtrim(ltrim(itrim(fname)))) //0 changes
replace init = lower(rtrim(ltrim(itrim(init)))) //0 changes
replace mname = lower(rtrim(ltrim(itrim(mname)))) //0 changes
replace lname = lower(rtrim(ltrim(itrim(lname)))) //0 changes


** There are 2 sets of death data variables so sort and remove
replace dd_dddoa=dddoa if dd_dddoa==. & dddoa!=. //997;1091 changes
replace dd_ddda=ddda if dd_ddda==. & ddda!=. //997;1091 changes
replace redcap_event_name="1" if redcap_event_name=="death_data_collect_arm_1" //997; 999; 1139 changes
destring redcap_event_name ,replace
replace dd_event=redcap_event_name if dd_event==. & redcap_event_name==1 //997; 998; 1139 changes
replace dd_odda=odda if dd_odda=="" & odda!="" //997; 1091 changes
replace dd_certtype=certtype if dd_certtype==. & certtype!=. //1473; 1571 changes
replace dd_district=district if dd_district==. & district!=. //1473; 1571 changes
replace dd_address=address_cancer if dd_address=="" & address_cancer!="" //1473; 1472; 1570 changes
replace dd_parish=ddparish if dd_parish==. & ddparish!=. //997; 1091 changes
replace dd_age=ddage if dd_age==. & ddage!=. //997; 1091 changes
replace dd_agetxt=ddagetxt if dd_agetxt==. & ddagetxt!=. //997; 1089 changes
replace dd_mstatus=mstatus if dd_mstatus==. & mstatus!=. //1473; 1571 changes
replace dd_occu=occu if dd_occu=="" & occu!="" //1473; 1571 changes
replace dd_pod=pod if dd_pod=="" & pod!="" //1473; 1478; 1576 changes
replace dd_deathparish=deathparish if dd_deathparish==. & deathparish!=. //1473; 1477; 1575 changes
replace dd_regdate=regdate if dd_regdate==. & regdate!=. //1473; 1571 changes
replace dd_certifier=ddcertifier if dd_certifier=="" & ddcertifier!="" //997; 1091 changes
replace dd_namematch=ddnamematch if dd_namematch==. & ddnamematch!=. //997; 1091 changes
rename recstatdc dd_dcstatus
replace dd_dcstatus=dcstatus if dd_dcstatus==. & dcstatus!=. //997; 1091 changes
replace dd_duprec=duprec if dd_duprec==. & duprec!=. //0 changes
replace dd_mname=mname if dd_mname=="" & mname!="" //118; 119 changes
rename nm namematch
replace dd_durationnum=durationnum if dd_durationnum==. & durationnum!=. //476; 480 changes
replace dd_durationtxt=durationtxt if dd_durationtxt==. & durationtxt!=. //8 changes
replace dd_onsetnumcod1a=onsetnumcod1a if dd_onsetnumcod1a==. & onsetnumcod1a!=. //476; 480 changes
replace dd_onsettxtcod1a=onsettxtcod1a if dd_onsettxtcod1a==. & onsettxtcod1a!=. //7 changes
replace dd_certifieraddr=certifieraddr if dd_certifieraddr=="" & certifieraddr!="" //2353; 2352; 2896 changes
replace deathid=record_id if deathid==. & record_id!=. //0; 1 changes
replace dd_dod=dod if dd_dod==. & dod!=. //1528; 1529; 1658 changes
replace dod=dd_dod if dd_dod!=. & dod==. //0 changes
rename nrn dd_nrn
replace dd_pod=placeofdeath if dd_pod=="" & placeofdeath!="" //198; 210; 348 changes
destring notreat1 ,replace
destring notreat2 ,replace
destring norx2 ,replace
replace norx1=notreat1 if norx1==. & notreat1!=. //0 changes
replace norx2=notreat2 if norx2==. & notreat2!=. //0 changes
destring othtreat1 ,replace
replace orx1=othtreat1 if orx1==. & othtreat1!=. //0 changes

label var dd_coddeath "DeathData-combined CODs"
label var dd_mname "DeathData-middle name"
label var dd_dod "DeathData-date of death"
label var dotyear "Year of incidence"

** Remove unnecessary variables
drop cod1a_cancer tumouridsourcetable sid2 eid2 patientidtumourtable PatientRecordIDTumourTable ObsoleteFlagTumourTable TumourUnduplicationStatus ObsoleteFlagPatientTable pid2 str_sourcerecordid str_pid2 patienttotal patienttot str_patientidtumourtable mpseq2 sourceseq tumseq tumsourceseq str_sourcerecordid2 eidcorrect tumourtot sourcetot dobyear dobmonth dobday rx1year rx1month rx1day rx2year rx2month rx2day rx3year rx3month rx3day rx4year rx4month rx4day stdyear stdmonth stdday rdyear rdmonth rdday rptyear rptmonth rptday admyear admmonth admday dfcyear dfcmonth dfcday rtyear rtmonth rtday sname dotyear2 dupnrn duppt checkage2 redcap_event_name dddoa ddda odda certtype district address_cancer ddparish ddsex ddage ddagetxt mstatus occu pod deathparish regdate ddcertifier ddnamematch dcstatus duprec pnameextra duppid duppid_all case mppid monset age5 age_10 mname pfu age45 age55 age65 site _merge_icd10 notiftype durationnum durationtxt deathyear onsetnumcod1a onsettxtcod1a certifieraddr record_id dotyear2 nrnday dob_yr dob_year year2 dobchk nrnid morphology laterality behaviour str_grade bas diagyr dup_pid dd_dupname dd_dupdod placeofdeath _merge_org dupst obsid pidobsid pidobstot duppidcr5id dup_cr5id dupnrn duppt checkage2 dodyear_cancer othtreat1 notreat1 notreat2


** Put variables in order they are to appear	  
order pid cr5id dot fname lname init age sex dob natregno resident slc dlc dod /// 
	  parish cr5cod primarysite morph top lat beh hx grade eid sid

count //3336; 3346; 3516; 4060

** JC 12jan21: While reviewing IARC check warnings from Sarah for IARC Hub DQ assessment, incorrect morph noted for below case
** Note below code not included in dataset sent to Sarah or 2015 annual report analysis as of 12jan2021.
replace morph=9591 if pid=="20080839" & cr5id=="T1S1"
replace morphcat=41 if pid=="20080839" & cr5id=="T1S1"
replace hx="NEUROENDOCRINE CARCINOMA, SMALL CELL TYPE/NON HODGKIN LYMPHOMA" if pid=="20080839"

replace morph=8000 if pid=="20140046" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140046" & cr5id=="T1S1"

replace basis=7 if pid=="20140062" & cr5id=="T1S1"

replace morph=8000 if pid=="20140200" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140200" & cr5id=="T1S1"

replace morph=8000 if pid=="20140205" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140205" & cr5id=="T1S1"

replace basis=7 if pid=="20140214" & cr5id=="T1S1"

replace morph=8000 if pid=="20140229" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140229" & cr5id=="T1S1"

replace morph=8000 if pid=="20140230" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140230" & cr5id=="T1S1"

replace morph=8000 if pid=="20140245" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140245" & cr5id=="T1S1"

replace topography=421 if pid=="20140259" & cr5id=="T1S1"
replace top="421" if pid=="20140259" & cr5id=="T1S1"
replace topcat=38 if pid=="20140259" & cr5id=="T1S1"

replace basis=7 if pid=="20140281" & cr5id=="T1S1"

replace morph=8000 if pid=="20140318" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140318" & cr5id=="T1S1"
replace basis=0 if pid=="20140318" & cr5id=="T1S1"
replace dot=d(28jun2014) if pid=="20140318" & cr5id=="T1S1"

replace morph=8000 if pid=="20140320" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140320" & cr5id=="T1S1"

replace morph=8000 if pid=="20140332" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140332" & cr5id=="T1S1"

replace morph=8000 if pid=="20140343" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140343" & cr5id=="T1S1"

replace morph=8000 if pid=="20140365" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140365" & cr5id=="T1S1"

replace morph=8000 if pid=="20140367" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140367" & cr5id=="T1S1"

replace morph=8000 if pid=="20140381" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140381" & cr5id=="T1S1"

replace morph=8000 if pid=="20140385" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140385" & cr5id=="T1S1"

replace topography=421 if pid=="20140390" & cr5id=="T1S1"
replace top="421" if pid=="20140390" & cr5id=="T1S1"
replace topcat=38 if pid=="20140390" & cr5id=="T1S1"

replace morph=8000 if pid=="20140391" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140391" & cr5id=="T1S1"

replace morph=8000 if pid=="20140393" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140393" & cr5id=="T1S1"
replace basis=4 if pid=="20140393" & cr5id=="T1S1"

replace morph=8000 if pid=="20140411" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140411" & cr5id=="T1S1"

replace morph=8000 if pid=="20140418" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140418" & cr5id=="T1S1"

replace morph=8000 if pid=="20140430" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140430" & cr5id=="T1S1"

replace morph=8000 if pid=="20140467" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140467" & cr5id=="T1S1"

replace morph=8000 if pid=="20140505" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140505" & cr5id=="T1S1"

replace morph=8000 if pid=="20140514" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140514" & cr5id=="T1S1"

replace morph=8000 if pid=="20140517" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140517" & cr5id=="T1S1"

replace morph=8000 if pid=="20140522" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140522" & cr5id=="T1S1"

replace morph=8000 if pid=="20140536" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140536" & cr5id=="T1S1"

replace morph=8000 if pid=="20140576" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140576" & cr5id=="T1S1"

replace morph=8000 if pid=="20140578" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140578" & cr5id=="T1S1"

replace morph=8000 if pid=="20140586" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140586" & cr5id=="T1S1"

replace morph=8000 if pid=="20140595" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140595" & cr5id=="T1S1"

replace morph=8000 if pid=="20140619" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140619" & cr5id=="T1S1"

replace morph=8000 if pid=="20140627" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140627" & cr5id=="T1S1"
replace basis=4 if pid=="20140627" & cr5id=="T1S1"

replace morph=8000 if pid=="20140656" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140656" & cr5id=="T1S1"

replace morph=8000 if pid=="20140668" & cr5id=="T1S1"
replace morphcat=1 if pid=="20140668" & cr5id=="T1S1"

replace basis=5 if pid=="20140745" & cr5id=="T1S1"

replace topography=421 if pid=="20140825" & cr5id=="T1S1"
replace top="421" if pid=="20140825" & cr5id=="T1S1"
replace topcat=38 if pid=="20140825" & cr5id=="T1S1"

replace basis=7 if pid=="20141553" & cr5id=="T1S1"

replace morph=8000 if pid=="20145153" & cr5id=="T1S1"
replace morphcat=1 if pid=="20145153" & cr5id=="T1S1"

replace topography=445 if pid=="20150210" & cr5id=="T1S1"
replace top="445" if pid=="20150210" & cr5id=="T1S1"
replace topcat=39 if pid=="20150210" & cr5id=="T1S1"

replace morph=8500 if pid=="20150294" & cr5id=="T1S1"
replace morphcat=10 if pid=="20150294" & cr5id=="T1S1"

replace topography=421 if pid=="20150314" & cr5id=="T2S1"
replace top="421" if pid=="20150314" & cr5id=="T2S1"
replace topcat=38 if pid=="20150314" & cr5id=="T2S1"

replace morph=8000 if pid=="20155150" & cr5id=="T1S1"
replace morphcat=1 if pid=="20155150" & cr5id=="T1S1"

// 14jan21 JC: incidentally found an error in abs date field when performing below mean & median calculations
//list pid cr5id ttdoa if ttdoa<d(01jan2010)
replace ttdoa=d(01jan2000) if pid=="20140268" & cr5id=="T1S1" //1 change

** 14jan21 JC: Sarah from the IARC Hub needs the below to assess Timeliness
//	Mean and median duration in months from date of incident diagnosis to date of abstraction
** First calculate the difference in months between these 2 dates 
// (need to add in qualifier to ignore missing abstraction dates which are recorded as 01jan2000)
gen ttdoadotdiff = (ttdoa - dot) / (365/12) if ttdoa!=d(01jan2000) & ttdoa!=.
** Now calculate the overall mean & median
preserve
drop if ttdoadotdiff==. //209 deleted
summ ttdoadotdiff //displays mean
/*
    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
ttdoadotdiff |      3,850    46.61499     10.8229  -4.865754   139.3315
*/
summ ttdoadotdiff, detail //displays mean + median (median is the percentile next to 50%)
/*
                        ttdoadotdiff
-------------------------------------------------------------
      Percentiles      Smallest
 1%     22.48767      -4.865754
 5%     31.29863              0
10%     36.19726       1.775342       Obs               3,850
25%     40.93151       2.334247       Sum of Wgt.       3,850

50%         45.6                      Mean           46.61499
                        Largest       Std. Dev.       10.8229
75%     51.05753       126.2137
90%     60.31233       134.5973       Variance       117.1351
95%     65.49041       137.4904       Skewness       1.408448
99%     71.17809       139.3315       Kurtosis       13.09361
*/
restore

** Now calculate mean & median per diagnosis year
// 2008
preserve
drop if dxyr!=2008 //2,842 deleted
drop if ttdoadotdiff==. //3 deleted
summ ttdoadotdiff, detail
/*
                        ttdoadotdiff
-------------------------------------------------------------
      Percentiles      Smallest
 1%     30.18082       24.13151
 5%     34.81644       24.82192
10%     39.35342       24.88767       Obs               1,214
25%     47.67123       26.69589       Sum of Wgt.       1,214

50%      54.4274                      Mean           54.79226
                        Largest       Std. Dev.      12.74966
75%     62.20274       126.2137
90%      67.7589       134.5973       Variance       162.5539
95%     69.83014       137.4904       Skewness       1.641544
99%     114.8712       139.3315       Kurtosis       11.97042
*/
restore

// 2013
preserve
drop if dxyr!=2013 //3,177 deleted
drop if ttdoadotdiff==. //38 deleted
summ ttdoadotdiff, detail
/*
                        ttdoadotdiff
-------------------------------------------------------------
      Percentiles      Smallest
 1%     5.391781      -4.865754
 5%     22.94794              0
10%     25.74247       1.775342       Obs                 844
25%      34.2411       2.334247       Sum of Wgt.         844

50%     40.43835                      Mean           39.30524
                        Largest       Std. Dev.      10.14108
75%     46.10959       71.83562
90%     49.84109       77.68767       Variance       102.8416
95%     51.74794       81.89589       Skewness      -.3556102
99%     66.54247       82.35616       Kurtosis       5.095819
*/
restore

// 2014
preserve
drop if dxyr!=2014 //3,161 deleted
drop if ttdoadotdiff==. //30 deleted
summ ttdoadotdiff, detail
/*

                        ttdoadotdiff
-------------------------------------------------------------
      Percentiles      Smallest
 1%     39.41918       15.41918
 5%     40.60274       20.87671
10%     41.49041        38.9589       Obs                 868
25%     43.33151       38.99178       Sum of Wgt.         868

50%     46.06027                      Mean           46.23439
                        Largest       Std. Dev.      4.030377
75%     48.80548       58.22466
90%     51.22192       58.29041       Variance       16.24394
95%     52.66849       65.68767       Skewness      -.2638959
99%     54.93699       67.52877       Kurtosis       9.020942
*/
restore

// 2015
preserve
drop if dxyr!=2015 //2,997 deleted
drop if ttdoadotdiff==. //138 deleted
summ ttdoadotdiff, detail
/*
                        ttdoadotdiff
-------------------------------------------------------------
      Percentiles      Smallest
 1%     36.13151       34.38904
 5%     37.11781       35.50685
10%     37.84109       35.83562       Obs                 924
25%     39.78082       35.83562       Sum of Wgt.         924

50%     42.70685                      Mean           42.90568
                        Largest       Std. Dev.       3.86423
75%     46.04383       57.73151
90%     47.50685       58.22466       Variance       14.93227
95%     48.62466       58.81644       Skewness        .386649
99%     52.27397       59.37534       Kurtosis       3.187158
*/
restore

** JC 17-mar-2021 while reviewing IARC Hub's feedback that 20081039 should be coded to vagina not cervix
** This update will not affect 2015 annual rpt as 2008 cases not included in that report.
replace primarysite="VAGINA" if pid=="20081039"
replace top="529" if pid=="20081039"
replace topography=529 if pid=="20081039"
replace topcat=45 if pid=="20081039"

** JC 22-mar-2021 while reviewing 2017 data, noted this update
replace dlc=d(19jun2017) if pid=="20080158"
** JC 24-mar-2021 while reviewing duplicates list, noted this update in CR5db as new source added post-review but DA didn't update tumour fields or alert reviewers to the change
/*
replace primarysite="ENDOMETRIUM" if pid=="20151355"
replace top="541" if pid=="20151355"
replace topography=541 if pid=="20151355"
replace topcat=47 if pid=="20151355"
replace hx="CARCINOMA" if pid=="20151355"
replace morph=8010 if pid=="20151355"
replace lat=0 if pid=="20151355"
replace grade=1 if pid=="20151355"
replace basis=7 if pid=="20151355"
replace consultant="W WELCH" if pid=="20151355"
replace iccc="11f" if pid=="20151355"
replace icd10="C541" if pid=="20151355"
replace siteiarc=33 if pid=="20151355"
replace sitecr5db=12 if pid=="20151355"
replace rx2=1 if pid=="20151355"
replace rx2d=d(13sep2016) if pid=="20151355"
*/
//after seeing another pid 20160342, the above is a different pt - the DA entered the new source into 20151355 but it belongs to different pt - PIDs 20160342, 20161068

** JC 25-mar-2021 while reviewing duplicates list, noted this merge wasn't done with pid 20155164 but on review 20155164 wasn't merged because incorrect NRN, DOB were assigned to this pt in CR5 and it turns out this pt is non-resident according to CR5 comments
drop if pid=="20151151" //rectal ca; death record_id 17676
** JC 29-mar-2021 while reviewing KWG's feedback on the duplicates list, noted this update post-merging of 20160018 and 20160201
replace primarysite="STOMACH-LESSER CURVATURE" if pid=="20160018" & cr5id=="T1S1"
replace top="165" if pid=="20160018" & cr5id=="T1S1"
replace topography=165 if pid=="20160018" & cr5id=="T1S1"
replace topcat=17 if pid=="20160018" & cr5id=="T1S1"
replace iccc="2b" if pid=="20160018" & cr5id=="T1S1"
replace icd10="C844" if pid=="20160018" & cr5id=="T1S1"
//no changes for sites as already set to correct sites for M9702


** JC 11-may-2021: while reviewing duplicates list, noted this merge wasn't done with pid 20141171.
** Correct DOB errors flagged by merging with list of corrections manually created using electoral list (this ensures dofile remains de-identified)
preserve
clear
import excel using "`datapath'\version02\2-working\PostCleaningPartialUpdates20210721.xlsx" , firstrow case(lower)
save "`datapath'\version02\2-working\postcleanupdates" ,replace
restore
merge 1:1 pid using "`datapath'\version02\2-working\postcleanpartupdates" ,force
/*

*/
drop _merge

preserve
clear
import excel using "`datapath'\version02\2-working\PostCleaningFullUpdates20210721.xlsx" , firstrow case(lower)
save "`datapath'\version02\2-working\postcleanupdates" ,replace
restore
append using "`datapath'\version02\2-working\postcleanfullupdates" ,force
/*

*/

/*
	02jun2021 JC: Updates from post-clean cross-check review process.
	See dofile 45_prep cross-check.do
*/
replace dlc=d(09sep2020) if pid=="20080020" //path rpt added for recurrent disease
replace dlc=dod if pid=="20080154" //death certificate added in CR5db and this was already matched in Stata.
replace dlc=d(19jun2017) if pid=="20080158" //path rpt added for 2017 MP
replace dlc=d(09nov2018) if pid=="20080171" //path rpt added for 2018 MP
replace dlc=d(26sep2017) if pid=="20080173" //path rpt added for 2017 MP
replace dlc=d(31dec2014) if pid=="20080196" & cr5id=="T1S1" //merged in CR5db on 17mar2021 after dup list review
replace patient=2 if pid=="20080196" & cr5id=="T2S1"
replace eidmp=2 if pid=="20080196" & cr5id=="T2S1"
replace ptrectot=3 if pid=="20080196" & cr5id=="T2S1"
replace mpseq=2 if pid=="20080196" & cr5id=="T2S1"
replace mptot=2 if pid=="20080196" & cr5id=="T2S1"
//pid 20080208 reviewed but no update needed as was merged with 20145127 (death info) in CR5db after dup list review - death data was already matched in Stata.
replace dlc=d(05apr2018) if pid=="20080217" //path rpt added for 2018 MP
replace dlc=d(02may2017) if pid=="20080232" //merge done for 2016 MP
//pid 20080241 reviewed but no update needed as only death certificate added in CR5db and this was already matched in Stata.
replace dlc=dod if pid=="20080252" //merge done for 2016 MP
replace dlc=dod if pid=="20080261" //merge done for 2016 MP
replace dlc=d(30mar2017) if pid=="20080274" //merge done for recurrent disease
replace dlc=dod if pid=="20080295" //merge done for 2016 MP
replace dlc=dod if pid=="20080316" //death rec bk added - missed 2017 MP on death certificate; further investigation revealed death certificate added to wrong pid
replace dlc=d(04mar2019) if pid=="20080326" //path rpt added for progressive disease
replace dlc=dod if pid=="20080327" //death certificate added; already matched in Stata
replace dlc=dod if pid=="20080348" //death rec bk added; already matched in Stata
replace dlc=d(24jan2019) if pid=="20080390" //path rpt added for recurrent disease
replace dlc=d(02oct2019) if pid=="20080428" //path rpt added for 2019 MP
replace natregno=subinstr(natregno,"0030","9999",.) if pid=="20080428"
replace dlc=d(11jul2016) if pid=="20080560" //path rpt added for 2016 MP
//pid 20080624 reviewed but no update needed as cannot determine any reason for why record was saved 13feb2020, according to TT update date.
replace dlc=d(04jul2013) if pid=="20130686" //merged in CR5db on 17mar2021 after dup list review
replace patient=2 if pid=="20130686" & cr5id=="T1S1"
replace eidmp=2 if pid=="20130686" & cr5id=="T1S1"
replace ptrectot=3 if pid=="20130686" & cr5id=="T1S1"
replace persearch=2 if pid=="20130686" & cr5id=="T1S1"
replace mpseq=7 if pid=="20130686" & cr5id=="T1S1"
replace mptot=7 if pid=="20130686"
replace mptot=7 if pid=="20080626"
replace cr5id="T7S1" if pid=="20130686"
//ssc install fillmissing
gen nrn=natregno if pid=="20130686"
fillmissing nrn
replace natregno=nrn if pid=="20080626" //6 changes
gen dlc2=dlc if pid=="20130686"
format dlc2 %dD_m_CY
fillmissing dlc2
replace dlc=dlc2 if pid=="20080626" //6 changes
drop nrn dlc2
replace pid="20080626" if pid=="20130686"
//pid 20080626 was missing NRN and had old DLC so used above fillmissing command to copy the NRN + DLC values from pid 20130686 to 20080626
replace dlc=d(26nov2014) if pid=="20080659" //merge done for ineligible 2014 MP; DLC obtained from MasterDb frmCF_2009 #3598
replace dlc=d(15mar2019) if pid=="20080674" //path rpt added for 2019 MP
//pid 20080688 reviewed but no update needed as cannot determine any reason for why record was saved 19feb2020, according to TT update date.
replace patient=2 if pid=="20150409" & cr5id=="T1S1"
replace eidmp=2 if pid=="20150409" & cr5id=="T1S1"
replace ptrectot=3 if pid=="20150409" & cr5id=="T1S1"
replace persearch=2 if pid=="20150409" & cr5id=="T1S1"
replace mpseq=2 if pid=="20150409" & cr5id=="T1S1"
replace mptot=2 if pid=="20150409"
replace cr5id="T2S1" if pid=="20150409"
//ssc install fillmissing
gen nrn=natregno if pid=="20150409"
fillmissing nrn
replace natregno=nrn if pid=="20080696" //1 change
gen dlc2=dlc if pid=="20150409"
format dlc2 %dD_m_CY
fillmissing dlc2
replace dlc=dlc2 if pid=="20080696" //1 change
drop nrn dlc2
replace pid="20080696" if pid=="20150409"
//pid 20080696 was missing NRN and had old DLC so used above fillmissing command to copy the NRN + DLC values from pid 20150409 to 20080696
replace patient=2 if pid=="20150255" & cr5id=="T1S1"
replace eidmp=2 if pid=="20150255" & cr5id=="T1S1"
replace ptrectot=3 if pid=="20150255" & cr5id=="T1S1"
replace persearch=2 if pid=="20150255" & cr5id=="T1S1"
replace mpseq=5 if pid=="20150255" & cr5id=="T1S1"
replace mptot=5 if pid=="20150255"
replace mptot=5 if pid=="20080728"
replace cr5id="T5S1" if pid=="20150255" & cr5id=="T1S1"
replace slc=2 if pid=="20080728"
//ssc install fillmissing
gen nrn=natregno if pid=="20150255"
fillmissing nrn
replace natregno=nrn if pid=="20080728" //4 changes
gen dlc2=dlc if pid=="20150255"
format dlc2 %dD_m_CY
fillmissing dlc2
replace dlc=dlc2 if pid=="20080728" //4 changes
gen dod2=dod if pid=="20150255"
format dod2 %dD_m_CY
fillmissing dod2
replace dod=dod2 if pid=="20080728" //4 changes
drop nrn dlc2 dod2
replace pid="20080728" if pid=="20150255"
//pid 20080728 was missing NRN and had old DLC so used above fillmissing command to copy the NRN + DLC values from pid 20150255 to 20080728
replace dlc=d(25nov2014) if pid=="20080753" //merge done for ineligible 2014 MP; DLC obtained from MasterDb frmCF_2009 #3594
//pid 20080941 reviewed but no update needed as cannot determine any reason for why record was saved 19feb2020, according to TT update date (maybe updating death date).
//pid 20081031 reviewed but no update needed as cannot determine any reason for why record was saved 21may2021, according to TT update date.
replace slc=2 if pid=="20081058"
replace dlc=d(17Nov2019) if pid=="20081058"
replace dod=d(17Nov2019) if pid=="20081058"
replace deathid=28983 if pid=="20081058"
replace cancer=2 if pid=="20081058"
replace deceased=2 if pid=="20081058"
replace cod=2 if pid=="20081058"
replace mpseq=1 if pid=="20081058" & cr5id=="T1S1"
replace mptot=2 if pid=="20081058" & cr5id=="T1S1"
replace patient=2 if pid=="20130365" & cr5id=="T1S1"
replace eidmp=2 if pid=="20130365" & cr5id=="T1S1"
replace ptrectot=3 if pid=="20130365" & cr5id=="T1S1"
replace dcostatus=1 if pid=="20081058" & cr5id=="T1S1"|pid=="20130365" & cr5id=="T1S1"
replace persearch=2 if pid=="20130365" & cr5id=="T1S1"
replace mpseq=2 if pid=="20130365" & cr5id=="T1S1"
replace mptot=2 if pid=="20130365" & cr5id=="T1S1"
replace mpseq=1 if pid=="20081058" & cr5id=="T1S1"
replace mptot=2 if pid=="20081058" & cr5id=="T1S1"
replace cr5id="T2S1" if pid=="20130365"
replace pid="20081058" if pid=="20130365" & cr5id=="T2S1"
replace mpseq=0 if pid=="20081097" & cr5id=="T1S1"
replace dlc=d(10dec2020) if pid=="20130016" //path rpt added for recurrent disease
//pid 20130022 reviewed but no update needed as DA added death rec bk but already matched to death data in Stata.
replace dlc=dod if pid=="20130032" //merge done with priv phys NF added
replace dlc=d(11oct2016) if pid=="20130033"
replace top="503" if pid=="20130033" & cr5id=="T1S1"
replace topography=503 if pid=="20130033" & cr5id=="T1S1"
replace primarysite="BREAST-LOWER INNER" if pid=="20130033" & cr5id=="T1S1"
replace dlc=dod if pid=="20130038" //merge done with death rec bk added
replace dlc=dod if pid=="20130055" //merge done with death rec bk added
replace dlc=dod if pid=="20130063" //merge done with death rec bk added
replace dlc=dod if pid=="20130073" //merge done with death rec bk added
replace dlc=(14dec2020) if pid=="20130081" //merge done with path rpt added for recurrent disease
replace primarysite="SOFT PALATE" if pid=="20130081" & cr5id=="T1S1" //in re-reviewing the original tumour has incorrect info
replace top="051" if pid=="20130081" & cr5id=="T1S1"
replace topography=51 if pid=="20130081" & cr5id=="T1S1"
replace topcat=6 if pid=="20130081" & cr5id=="T1S1"
replace dlc=d(21apr2016) if pid=="20130087" //path rpt added for 2016 MP
replace dlc=dod if pid=="20130096" //merge done with death certificate added
replace dlc=dod if pid=="20130103" //merge done with death rec bk added
replace dlc=d(01nov2019) if pid=="20130110" //path rpt added for 2019 MP
replace dlc=dod if pid=="20130119" //merge done with death rec bk added
replace dlc=dod if pid=="20130130" //death certificate added
//pid 20130137 reviewed but no update needed as merge done with pid 20140789 + 20140792 ineligible path rpts added
//pid 20130152 reviewed but no update needed as merge done with pid 20170326 metastatic path rpts added
replace dlc=dod if pid=="20130154" //death rec bk added
replace dot=d(13may2014) if pid=="20130162" & cr5id=="T2S1" //merge done with 2014 + 2017 MPs
replace dlc=d(06jun2017) if pid=="20130162" //merge done with 2017 MP
replace dlc=dod if pid=="20130173" //death rec bk added
replace dlc=dod if pid=="20130234" //path rpt for mets + death certificate added
replace dlc=d(03mar2017) if pid=="20130244" //merge done with 2017 MP
replace dlc=d(05jan2017) if pid=="20130246" //merge done with 2016 MP + with 2017 path rpt for mets
//pid 20130272 reviewed but no update needed as merge done with pid 20180905 death certificate
//pid 20130278 reviewed but no update needed as death rec bk added
replace dlc=d(10jun2016) if pid=="20130325" //merge done with 2016 path rpt for mets
//pid 20130341 reviewed but no update needed as merge done with pid 20140554 + 20140840 + 20140914 + 20140915 metastatic path rpts added
replace dlc=dod if pid=="20130345" //death rec bk added
replace dlc=dod if pid=="20130361" //death rec bk added + merge with pid 20145098 path rpt
replace dlc=dod if pid=="20130374" //death rec bk added
//pid 20130552 reviewed but no update needed as death rec bk added
//pid 20130589 reviewed but no update needed as merge done with pid 20140494 death certificate added
//pid 20130618 reviewed but no update needed as merge done with pid 20160589 path rpt for MP added
replace dlc=dod if pid=="20130648" //death certificate added + merge with pid 20150270 path rpt
replace dlc=d(13feb2019) if pid=="20130670" //merge done with 2018 path rpt for mets
replace dlc=dod if pid=="20130674" //death rec bk added
replace dlc=dod if pid=="20130696" //death rec bk added
replace dlc=dod if pid=="20130768" //merge with pid 20140677 haem NF
replace dlc=dod if pid=="20130772" //death rec bk added
//pid 20130816 reviewed but no update needed as merge done with pid 20160984 death rec bk added
replace dlc=dod if pid=="20130830" //death certificate added
//pid 20130865 reviewed but updates from merge with pid 20140361 + 20141171 and these contain identifiable data so manually created an update excel sheet and merged with this dataset above
//pid 20130886 reviewed but no update needed as death rec bk added
//pid 20140529 reviewed but no update needed as this is ineligible dx and was already removed from ds
//pid 20140545 reviewed but updates contain identifiable data so manually created an update excel sheet and merged with this dataset above - also SF to review as discrepancies found between death data vs electoral list for NRNs
//pid 20140628 reviewed but no update needed as merge done with pid 20141184
replace dlc=dod if pid=="20140681" //death rec bk added
//pid 20140697 reviewed but no update needed as merge done with pid 20141123 + 20141474
//pid 20141557 reviewed but no update needed as merge done with pid 20140724
//pid 20140729 reviewed but no update needed - unsure what was updated by DAs.
//pid 20140733 reviewed but no update needed as merge done with pid 20140734 + 20141062 & death rec bk added
//pid 20140738 reviewed but not present in stata ds as was ineligible & merge done with pid 20141003 + 20141004 + 20150459
//pid 20140739 reviewed but no update needed as merge done with pid 20140740 + 20140741 + 20140935
//pid 20140836 reviewed (ineligible so not in iarc ds) but no update needed as merge done with pid 20140918
//pid 20140836 reviewed (ineligible so not in iarc ds) but no update needed as source added for 2020 MP
replace dot=d(23jan2014) if pid=="20140838" & cr5id=="T1S1" //merge with pid 20141186 showed new incidence date
//pid 20140841 reviewed but no update needed as merge done with pid 20141036
//pid 20140843 reviewed but no update needed as merge done with pid 20150167
replace slc=2 if pid=="20140849"
replace dlc=d(19may2019) if pid=="20140849"
replace dod=d(19may2019) if pid=="20140849" 
replace deathid=27856 if pid=="20140849"
//pid 20140855 reviewed (ineligible so not in iarc ds) but no update needed as merge done with pid 20140884
replace dlc=d(31jul2019) if pid=="20140871" //path rpt + RT sources added for mets
replace dlc=d(28oct2019) if pid=="20140890" //path rpt source added for same primary
replace dlc=dod if pid=="20140892" //merge done with 20150222
//pid 20140893 reviewed but no update needed - cannot determine what update was done by DA.
//pid 20140907 reviewed but no update needed as merge done with pid 20140905
//pid 20140911 reviewed but no update needed - cannot determine what update was done by DA.
replace dlc=d(10jan2020) if pid=="20140923" //path rpt source added for same primary
//pid 20140959 reviewed but no update needed as merge done with pid 20150258
//pid 20140975 reviewed but no update needed as merge done with pid 20140976 + 20180765
Sent pid 20140981 for KWG to review as I'm unsure what to do with it as it's very incomplete - KWG to f/u at Dr Hawkins-Voss (13jul2021).
//pid 20141031 reviewed but no update needed as merge done with pid 2015483 + 20150484
replace dlc=d(01oct2019) if pid=="20141063" //RT source added
replace dlc=dod if pid=="20141064" //Death Rec bk added
//pid 20141067 reviewed but no update needed as merge done with pid 20150529
replace dlc=d(28nov2019) if pid=="20141084" //merge done with 20141247; path rpts added for mets
//pid 20141095 reviewed but no update needed as merge done with pid 20140835
//pid 20141103 reviewed but no update needed - cannot determine what update was done by DA.
replace hx="MAMMARY CARCINOMA" if pid=="20141113" & cr5id=="T1S1"
replace morph=8500 if pid=="20141113" & cr5id=="T1S1"
replace morphcat=10 if pid=="20141113" & cr5id=="T1S1" //Death Rec bk added
replace dlc=dod if pid=="20141115" //merge done with pid 20150391 + Death Rec bk added
//pid 20141129 reviewed but no update needed as merge done with pid 20150399
//pid 20141130 reviewed but no update needed as merge done with pid 20145075 + 20155202
//pid 20141134 reviewed but no update needed as death certificate added.
//pid 20141145 reviewed but no update needed as death rec bk added.
replace dlc=d(04oct2019) if pid=="20141174" //path rpt added for recurrent disease
replace dlc=d(25mar2020) if pid=="20141205" //path rpt added for 2020 MP - missed by DA
replace dlc=dod if pid=="20141240" //death rec bk added
replace dlc=d(04dec2017) if pid=="20141253" //RT added for 2017 MP
//pid 20141258 reviewed but no update needed as death rec bk added.
//pid 20141262 reviewed but no update needed as merge done with pid 20150551
//pid 20141283 reviewed but no update needed - cannot determine what update was done by DA.
//pid 20141306 reviewed but no update needed as merge done with pid 20150506
replace dlc=dod if pid=="20141308" //death rec bk added
replace dlc=dod if pid=="20141320" //death rec bk added
//pid 20141324 reviewed but no update needed as merge done with pid 20160554
replace dlc=d(05feb2019) if pid=="20141348" //RT added for mets
//pid 20141361 reviewed but no update needed as merge done with pid 20180703
//pid 20141365 reviewed but no update needed as merge done with pid 20150508
replace dlc=d(12may2019) if pid=="20141376" //merge with 20190410 for 2019 MP
//pid 20141393 reviewed but no update needed as merge done with pid 20150398
//pid 20141412 reviewed but no update needed as merge done with pid 20140951
replace dlc=d(12mar2019) if pid=="20141414" //merge with 20191017 for 2019 MP
//pid 20141425 reviewed but no update needed - cannot determine what update was done by DA.
//pid 20141434 reviewed but no update needed as merge done with pid 20150559
//pid 20141448 reviewed but no update needed - cannot determine what update was done by DA.
//pid 20141463 reviewed but no update needed - cannot determine what update was done by DA.
//pid 20141486 reviewed but no update needed - cannot determine what update was done by DA.
replace dlc=d(01nov2017) if pid=="20141493" //RT added for same primary
//pid 20141503 reviewed but no update needed as merge done with pid 20145095
//pid 20141575 reviewed but no update needed as merge done with pid 20159009
//pid 20145033 reviewed but no update needed as merge done with pid 20141214
replace dlc=d(30jul2018) if pid=="20145038" //path rpt added for recurrent 2005 cancer
//pid 20145047 reviewed but updates contain identifiable data so manually created an update excel sheet and merged with this dataset above.
//pid 20145053 reviewed but no update needed - cannot determine what update was done by DA.
replace dlc=d(04aug2016) if pid=="20145054" //path rpt added for recurrent disease
//pid 20145055 reviewed but no update needed - cannot determine what update was done by DA.
//pid 20145106 reviewed but no update needed as death certificate added
//pid 20150005 reviewed but no update needed - cannot determine what update was done by DA.
//pid 20150013 reviewed but no update needed as death rec bk added
//pid 20150022 reviewed but no update needed as RT reg added.
//pid 20150025 reviewed but no update needed as RT reg added.
//pid 20150045 reviewed (ineligible so not in iarc ds) but no update needed as merge done with pid 20190307 for 2019 MP
replace dlc=d(14jan2016) if pid=="20150050" //merge done with pid 20150274 + RT reg added
replace dlc=d(22feb2016) if pid=="20150062" //merge done with pid 20150564 + RT reg added
replace dlc=d(30jan2017) if pid=="20150085" //merge done with pid 20150171 + RT reg added
//pid 20150099 reviewed but no update needed as merge done with pid 20150218 + 20170538
//pid 20150105 reviewed but no update needed as merge done with pid 20150191
//pid 20150112 reviewed but no update needed as merge done with pid 20150287
replace dlc=d(16mar2016) if pid=="20150114" //merge done with pid 20150510, 20160597 + RT reg added
//pid 20150115 reviewed but no update needed as merge done with pid 20150163 + RT reg added
//pid 20150140 reviewed but no update needed as death rec bk added
replace dlc=d(16feb2016) if pid=="20150160" //merge done with pid 20160158
//pid 20150165 reviewed but no update needed - cannot determine what update was done by DA.
//pid 20150170 reviewed but updates contain identifiable data so manually created an update excel sheet and merged with this dataset above; 2019 MP added.
replace dlc=d(21jun2017) if pid=="20150173" //merge done with pid 20170379 for path rpt of mets
//pid 20150174 reviewed but no update needed as merge done with pid 20150227
replace dlc=d(28jul2017) if pid=="20150180" //merge done with pid 20170506 for 2017 MP
//pid 20150188 reviewed but no update needed - cannot determine what update was done by DA.
replace dlc=d(23aug2016) if pid=="20150192" //Sx path rpt added
//pid 20150194 reviewed but no update needed as merge done with pid 20190229
replace dlc=d(04feb2016) if pid=="20150199" //merge done with pid 20160604 for 2016 MP
//pid 20150204 reviewed but no update needed as merge done with pid 20150456
//pid 20150208 reviewed (ineligible so not in iarc ds) but no update needed as merge done with pid 20150262
//pid 20150209 reviewed but no update needed as merge done with pid 20150248
//pid 20150215 reviewed but no update needed - cannot determine what update was done by DA.
//pid 20150228 reviewed but no update needed as RT reg added
replace dlc=d(25apr2016) if pid=="20150229" //RT reg added
replace dlc=d(04jan2016) if pid=="20150236" //RT reg added
replace hx="INVASIVE METAPLASTIC CARCINOMA" if pid=="20150240" & cr5id=="T1S1" //merge with pid 20160279 for Sx path rpt added
replace morph=8575 if pid=="20150240" & cr5id=="T1S1"
replace morphcat=12 if pid=="20150240" & cr5id=="T1S1"
//pid 20150242 reviewed but no update needed - cannot determine what update was done by DA.
replace dlc=d(23aug2016) if pid=="20150246" //Sx path rpt added
//pid 20150247 reviewed but no update needed as merge done with pid 20150055 + 20190030
//pid 20150251 reviewed but no update needed - cannot determine what update was done by DA.
replace dlc=d(29jan2016) if pid=="20150288" //RT reg added
//pid 20150296 reviewed but no update needed as RT reg added
replace primarysite="ANORECTAL JUNCTION" if pid=="20150297" & cr5id=="T1S1" //Sx path rpt added 
replace top="218" if pid=="20150297" & cr5id=="T1S1"
replace topography=218 if pid=="20150297" & cr5id=="T1S1"
replace dlc=d(11jan2016) if pid=="20150297"
//pid 20150302 reviewed but no update needed as merge done with pid 20150563 + 20155238
replace dlc=d(10feb2016) if pid=="20150303" //RT reg added
//pid 20150314 reviewed but no update needed as merge done with pid 20150008 + 20150090
replace dlc=d(18may2019) if pid=="20150329" //path rpt for mets added
//pid 20150333 reviewed but no update needed as T3S1 path rpt for 2016 MP added
replace dlc=d(05jan2016) if pid=="20150335" //RT reg added
replace dlc=d(29feb2016) if pid=="20150336" //RT reg added
replace dlc=d(15jun2016) if pid=="20150337" //merge with pid 20160038 + 20160359
replace dlc=d(03feb2016) if pid=="20150344" //merge with pid 20150126 + 20160354
//pid 20150359 reviewed but no update needed as merge done with pid 20160578
replace dlc=d(22mar2016) if pid=="20150368" //Sx path rpt added
//pid 20150375 reviewed but no update needed as merge done with pid 20150376
//pid 20150378 reviewed but no update needed as merge done with pid 20150051 + 20150377
//pid 20150404 reviewed but no update needed - cannot determine what update was done by DA.
replace dlc=d(29feb2016) if pid=="20150408" //merge with pid 20150143
//pid 20150415 reviewed but no update needed as merge done with pid 20150427 + 20160381
//pid 20150417 reviewed but no update needed as merge done with pid 20150150
replace dlc=d(19jan2016) if pid=="20150425" //merge with pid 20155065
replace dlc=d(01mar2016) if pid=="20150434" //Sx path rpt + RT reg added
//pid 20150440 reviewed but no update needed - cannot determine what update was done by DA.
replace dlc=d(08mar2016) if pid=="20150464" //merge with pid 20150111
//pid 20150482 reviewed but no update needed as 2017 MP sources added
replace dlc=d(07mar2017) if pid=="20150519" //merge with pid 20160462
replace dlc=d(15jan2016) if pid=="20150520" //RT reg added
//pid 20150521 reviewed but no update needed as Death Rec + RT reg added
//pid 20150522 reviewed but no update needed as 2016 MP sources added
//pid 20150527 reviewed (ineligible so not in iarc ds) but no update needed as merge done with pid 20150109 + 20190275
//pid 20150539 reviewed but no update needed as death certificate added
replace dlc=d(24may2017) if pid=="20151000" //merge with pid 20172152
replace dlc=d(20sep2016) if pid=="20151009" //2016 MP tumour added
//pid 20151010 reviewed (ineligible so not in iarc ds) but no update needed - cannot determine what update was done by DA.
replace dlc=d(06may2016) if pid=="20151020" //merge with pid 20150108 + 20150352 + 20160362
//pid 20151029 reviewed but no update needed - cannot determine what update was done by DA.
replace dlc=d(25aug2020) if pid=="20151033" //merge with pid 20190004 + 20201053 for 2019 MP
//pid 20151042 reviewed but no update needed as merge done with pid 20151368
replace dlc=d(19nov2018) if pid=="20151103" //merge with pid 20150042 + 20150518 for 2018 MP
//pid 20151109 reviewed but no update needed - cannot determine what update was done by DA.
//pid 20151113 reviewed but no update needed as Death Rec added
replace dlc=d(04dec2017) if pid=="20151120" //Death Rec added - this death certificate not found in death data or REDCap Deathdb
replace slc=2 if pid=="20151120" //Death Rec added - this death certificate not found in death data or REDCap Deathdb
replace comments="JC 19JUL2021: This death certificate not found in death data from Reg Dept or REDCap 2008-2020 Deathdb. No F/U needed. Abstracted from database." if pid=="20151120"
//pid 20151150 reviewed but no update needed as death certificate added
replace dlc=d(04mar2019) if pid=="20151168" //RT Reg added
//pid 20151171 reviewed but no update needed as RT reg + death certificate added for 2018 MP
//pid 20151189 reviewed but no update needed as RT reg + Sx path rpt added
//pid 20151193 reviewed but no update needed - cannot determine what update was done by DA.
** JC 24-mar-2021 while reviewing duplicates list, noted this update
//See email from 29mar2021 subject line "possibly incorrect merge - 2015" for KWG's feedback - AWAIT feedback from KWG then decide if to drop if pid=="20151197" //NPX ca is pid 20151313 - need to confirm with KWG first
drop if pid=="20151197" //this is a separate 2016 primary for a different pt with similar name see pid 20181093 + 20160340; Note KWG kept 20151197 and merged 20151313 into this pid but I removed 20151197 from IARC ds as this contains erroneous data and 20151313 has correct data.
//pid 20151226 reviewed but no update needed as merge done with pid 20170074 for 2017 MP
replace dlc=d(20apr2016) if pid=="20151248" //RT Reg added
replace dlc=d(05jan2016) if pid=="20151262" //RT Reg added
replace dlc=d(26jan2016) if pid=="20151301" //RT Reg added
replace dlc=d(09feb2016) if pid=="20151302" //RT Reg added
replace dlc=d(20mar2017) if pid=="20151307" //RT Reg added
//pid 20151309 reviewed but no update needed as MedData entry added
//pid 20151369 reviewed but no update needed - cannot determine what update was done by DA.
//pid 20155002 reviewed but no update needed as RT reg added
//pid 20155003 reviewed but no update needed as RT reg added
replace dlc=d(01feb2016) if pid=="20155005" //RT Reg added
//pid 20155006 reviewed but no update needed as RT reg added
replace dlc=d(07jan2016) if pid=="20155007" //RT Reg added
//pid 20155008 reviewed but no update needed as RT reg added
//pid 20155010 reviewed but no update needed as RT reg added
//pid 20155012 reviewed but no update needed as RT reg added
//pid 20155014 reviewed but no update needed as RT reg added
//pid 20155015 reviewed but no update needed as RT reg added
//pid 20155016 reviewed but no update needed as death certificate added
replace dlc=d(08feb2016) if pid=="20155017" //RT Reg added
replace dlc=d(08jun2017) if pid=="20155018" //Sx path rpt + RT Reg added
//pid 20155021 reviewed but no update needed as RT reg added
replace dlc=d(19apr2016) if pid=="20155027" //RT Reg added
//pid 20155028 reviewed but no update needed as RT reg + Death Rec added
replace dlc=d(28dec2016) if pid=="20155029" //Death Rec added - this death certificate not found in death data or REDCap Deathdb
replace slc=2 if pid=="20155029" //Death Rec added - this death certificate not found in death data or REDCap Deathdb
replace comments="JC 19JUL2021: This death certificate not found in death data from Reg Dept or REDCap 2008-2020 Deathdb. No F/U needed. Abstracted from database." if pid=="20155029"
//pid 20155030 reviewed but no update needed as RT reg added
replace dlc=d(29jan2016) if pid=="20155032" //RT Reg added
replace dlc=d(22feb2016) if pid=="20155033" //RT Reg added
replace dlc=d(29feb016) if pid=="20155037" //RT Reg added
//pid 20155039 reviewed but no update needed as RT reg added
//pid 20155043 reviewed but no update needed as RT reg added
//pid 20155046 reviewed but no update needed as RT reg added
replace dlc=d(16feb2016) if pid=="20155049" //RT Reg added
replace dlc=d(05apr2016) if pid=="20155052" //Sx path rpt + RT Reg added
replace primarysite="FUNDUS UTERI" if pid=="20155052" //Sx path rpt
replace top="543" if pid=="20155052" //Sx path rpt
replace topography=543 if pid=="20155052" //Sx path rpt
replace hx="ENDOMETRIOID ADENOCARCINOMA, SECRETORY TYPE" if pid=="20155052" //Sx path rpt
replace morph=8382 if pid=="20155052" //Sx path rpt
//pid 20155061 reviewed but no update needed - cannot determine what update was done by DA.
replace dlc=d(29jan2016) if pid=="20155064" //RT Reg added
//pid 20155070 reviewed but no update needed as merge done with pid 20161024
replace dlc=d(25feb2016) if pid=="20155071" //RT Reg added
replace dlc=d(03feb2016) if pid=="20155077" //RT Reg added
//pid 20155079 reviewed but no update needed as RT reg added
drop if pid=="20155094" & cr5id=="T2S1" //MedData entry added for 2015 MP but upon further investigation in MedData the prostate ca was dx on 18feb2010.
//pid 20155095 reviewed but no update needed as RT reg added
//pid 20155100 reviewed but no update needed as path rpt added
replace dot=d(04mar2015) if pid=="20155150" //MedData entry added - further review done in MedData by JC 19jul2021
replace admdate=d(04mar2015) if pid=="20155150"
replace ptrectot=1 if pid=="20155150"
replace dcostatus=1 if pid=="20155150"
replace basis=1 if pid=="20155150"
replace comments="JC 19JUL2021: Added in SF's CR5db comments - 12MAY21_KWG No F/U needed. 7APR21_SF Found in MedData, Dx C786 Secondary malignant neoplasm of retroperitoneum and preitoneum. Dx Date: 29MAR15. Doctor M Oshea. Admitted 4MAR15. To Abstract. No F/U needed. Mr Barrow unable to locate notes. Due to deadline to complete 2015 abstractions, case closed. 18JAN19_TH F/U Path Rpt for BOD and InciDate." if pid=="20155150"
replace dot=d(27feb2015) if pid=="20155161" //MedData entry added - further review done in MedData by JC 19jul2021
replace admdate=d(27feb2015) if pid=="20155161"
replace ptrectot=1 if pid=="20155161"
replace dcostatus=1 if pid=="20155161"
replace basis=1 if pid=="20155161"
replace lname=subinstr(lname,"e","a",.) if pid=="20155161"
replace comments="JC 19JUL2021: Added in SF's CR5db comments - 12MAY21_KWG No F/U needed. 7APR21_SF Found in MedData. Lastname spelt:... Dx Malignant neoplasm Liver unspecified IDC10 22.9. Dx Date 7MAR15. To Update. No F/U needed. Mr Barrow unable to locate notes. Due to deadline to complete 2015 abstractions case closed. 17JAN19_TH F/U Path Rpt for BOD and InciDate." if pid=="20155161"
drop if pid=="20151151" & cr5id=="T1S1" //merged with pid 20155164 and noted to be a visitor for rx and not a resident of Bdos.
replace ptrectot=1 if pid=="20155175" //MedData entry added
replace dcostatus=1 if pid=="20155175"
replace basis=1 if pid=="20155175"
replace comments="JC 19JUL2021: Added in SF's CR5db comments - 12MAY21_KWG No F/U needed. 7APR21_SF Found in MedData under LName... Dx Malignant Neoplasm: Colon Unspecified. Dx Date: 20MAY15. Doctor R Delice. To Update. No F/U needed. Mr Barrow unable to locate notes. Due to deadline to complete 2015 abstractions case closed. 17JAN19_TH F/U Path Rpt for BOD and InciDate. LastName changed from..." if pid=="20155175"
//pid 20155196 reviewed but no update needed - cannot determine what update was done by DA.
//pid 20155208 reviewed but no update needed as merge done with pid 20151174
//pid 20155211 reviewed but no update needed as merge done with pid 20160114
replace dot=d(22may2015) if pid=="20155216" //MedData entry added - further review done in MedData by JC 19jul2021
replace admdate=d(22may2015) if pid=="20155216"
replace ptrectot=1 if pid=="20155216"
replace dcostatus=1 if pid=="20155216"
replace basis=7 if pid=="20155216"
replace comments="JC 19JUL2021: Added in SF's CR5db comments - 12MAY21_KWG No F/U needed. 7APR21_SF Found on MedData. Dx: Malignanat neoplasm of gallbladder ICD10 23. Dx Date: 30JUN15. Doctor C Flower. To Update. No F/U needed. Check made with QEH Lab and no pathology done on this Pt. Case closed due to deadline to complete 2015 abstractions. 21MAR19_KWG No pathology seen in notes but mention made of Endoscopy and Biopsy. To F/U lab. 14JAN19_TH F/U Path Rpt for BOD and InciDate." if pid=="20155216"
replace dot=d(29may2015) if pid=="20155221" //MedData entry added
replace admdate=d(29may2015) if pid=="20155221"
replace ptrectot=1 if pid=="20155221"
replace dcostatus=1 if pid=="20155221"
replace basis=2 if pid=="20155221"
replace comments="JC 19JUL2021: Added in SF's CR5db comments - 12MAY21_KWG No F/U needed. 7APR21_SF Found on MedData. Dx: Malginant neoplasm of Breast Dx Date: 29MAY15. Dr Shenoy. To Update. No F/U needed. Mr Barrow unable to locate notes. Due to deadline to complete 2015 abstractions case closed. 14JAN19_TH F/U Path Rpt for BOD and InciDate." if pid=="20155221"
//pid 20155227 reviewed but no update needed - cannot determine what update was done by DA.
replace dot=d(14sep2015) if pid=="20155228" //MedData entry added
replace admdate=d(14sep2015) if pid=="20155228"
replace ptrectot=1 if pid=="20155228"
replace dcostatus=1 if pid=="20155228"
replace basis=1 if pid=="20155228"
replace comments="JC 19JUL2021: Added in SF's CR5db comments - 12MAY21_KWG No F/U needed. 7APR21_SF Found in MedData. Dx: Malignant neoplasm of prostate Dx Date: 14SEp15. Dr Wayne Clarke. To Updated.No F/U needed. Mr Barrow unable to locate notes. Due to deadline to complete 2015 abstractions case closed. 14JAN19_TH F/U Path Rpt for BOD and InciDate." if pid=="20155228"
replace dot=d(07oct2015) if pid=="20155251" //MedData entry added - further review done in MedData by JC 19jul2021
replace admdate=d(07oct2015) if pid=="20155251"
replace ptrectot=1 if pid=="20155251"
replace dcostatus=1 if pid=="20155251"
replace basis=1 if pid=="20155251"
replace comments="JC 19JUL2021: Added in SF's CR5db comments - 18MAY21_KWG Conflicting info found on MEDDATA, QEH Death Book records COD as Ovarian Cancer, case abstracted based on Death Book Info. 7APR21_SF Found in MedData. Dx: Malignant neoplasm: Intestinal tract ICD10 26.0. Dr Wayne Clarke. To update. No F/U needed. Mr Barrow unable to locate note. Due to deadline to complete 2015 abstractions, case closed. 14JAN19_TH F/U Path Rpt for BOD and InciDate." if pid=="20155251"
replace dot=d(02oct2015) if pid=="20155255" //MedData entry added
replace ptrectot=1 if pid=="20155255"
replace dcostatus=1 if pid=="20155255"
replace basis=1 if pid=="20155255"
replace comments="JC 19JUL2021: Added in SF's CR5db comments - 12MAY21_KWG No F/U needed. 7APR21_SF Found in MedData. Dx: Malignant neoplasm of uterus, NOS. Dx Date: 2OCT2015. Dr R Shenoy. To Update. No F/U needed. Mr Barrow unable to find note. Due to deadline to complete 2015 abstractions, case closed. 14JAN19_TH F/U Path Rpt for BOD and InciDate." if pid=="20155255"
//pid 20155265 reviewed but no update needed - cannot determine what update was done by DA.
//pid 20159000 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159001 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159002 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
replace init="m" if pid=="20159003"
replace comments="9APR21_KWG Notes seen, sparse and very old. No malignancy seen. Abstracted as a DCO pending MedData check." if pid=="20159003"
replace init="o" if pid=="20159004"
//pid 20159005 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159006 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159007 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159008 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159015 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159016 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159019 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159020 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
replace comments="23APR21_KWG Notes seen, old notes, no mention of cancer. Abstracted as a DCO pending MedData F/U." if pid=="20159021"
//pid 20159025 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159026 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159027 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159028 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159029 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159030 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159031 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159033 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159034 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159036 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159038 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159041 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159042 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159046 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
replace dot=d(25apr2015) if pid=="20159047" //MedData entry added - further review done in MedData by JC 21jul2021
replace admdate=d(25apr2015) if pid=="20159047"
replace ptrectot=1 if pid=="20159047"
replace dcostatus=1 if pid=="20159047"
replace basis=1 if pid=="20159047"
//pid 20159047 some updates contain identifiable data so manually created an update excel sheet and merged with this dataset above
replace dot=d(21mar2015) if pid=="20159048" //MedData entry added - further review done in MedData by JC 21jul2021
replace admdate=d(21mar2015) if pid=="20159048"
replace ptrectot=1 if pid=="20159048"
replace dcostatus=1 if pid=="20159048"
replace basis=1 if pid=="20159048"
replace init="a" if pid=="20159048"
replace comments="JC 21JUL2021: Added in SF's CR5db comments - 12MAY21_KWG No F/U needed. 10MAY21_SF To Abs. Found in MEDDATA. Dx: Prostate Cancer. Dx Date: 21MAR2015." if pid=="20159048"
//pid 20159051 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159053 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159055 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
replace dot=d(01may2015) if pid=="20159058" //MedData entry added
replace admdate=d(01may2015) if pid=="20159058"
replace ptrectot=1 if pid=="20159058"
replace dcostatus=1 if pid=="20159058"
replace basis=1 if pid=="20159058"
replace init="m" if pid=="20159058"
replace comments="JC 21JUL2021: Added in SF's CR5db comments - 12MAY21_KWG No F/U needed. 10MAY21_SF To Abs. Found in MEDDATA. Middle initial updated. Dx: Cancer of the Pancreas. Dx Date: 1MAY2015." if pid=="20159058"
replace dot=d(25may2015) if pid=="20159059" //MedData entry added
replace admdate=d(25may2015) if pid=="20159059"
replace ptrectot=1 if pid=="20159059"
replace dcostatus=1 if pid=="20159059"
replace basis=1 if pid=="20159059"
replace init="d" if pid=="20159059"
replace comments="JC 21JUL2021: Added in SF's CR5db comments - 12MAY21_KWG No F/U needed. 10MAY21_SF To Abstract. Found in MEDDATA. Middle Initial updated. Ca Prostate, Dx Date: 25MAY2015." if pid=="20159059"
//pid 20159060 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
replace dot=d(27may2015) if pid=="20159061" //Imaging added - death traceback done
replace admdate=d(27may2015) if pid=="20159061"
replace ptrectot=1 if pid=="20159061"
replace dcostatus=1 if pid=="20159061"
replace basis=2 if pid=="20159061"
replace comments="JC 21JUL2021: Added in KWG's CR5db comments - 21APR21_KWG 23MAY2015 Pt presents to AED c/o anorexia and weight los, decreased appetite, extremely lethargic and generally weak. U/S Abdomen ordered. 27MAY2015: U/S ABDOMEN FINDINGS: Liver: Enlarged in size and shows multiple mixed echogenic lesions - suggestive of metastasis. Largest lesion measures about 4 x 3cm. Pancreas, Spleen, Right kidney, Left kidney, Urinary bladder and Prostate are all normal. Bowel wall thickening measuring about 1.8cm is noted in the left upper quadrant - possibly the spenic flexure. IMP: 1. Multiple liver metastasis. 2. Possible bowel wall thickening in the splenic flexure - ?Carcinoma colon." if pid=="20159061"
replace dot=d(09apr2015) if pid=="20159062" //Death traceback done
replace admdate=d(09apr2015) if pid=="20159062"
replace ptrectot=1 if pid=="20159062"
replace dcostatus=1 if pid=="20159062"
replace basis=1 if pid=="20159062"
replace init="h" if pid=="20159062"
replace comments="JC 21JUL2021: Added in KWG's CR5db comments - 9APR21_KWG Notes seen and Pt suspected of bladder Ca due to perisitent haematuria. However Pt dceased before investigations could be completed. No reports seen in notes." if pid=="20159062"
//pid 20159063 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159064 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159065 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159068 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
replace dot=d(25mar2015) if pid=="20159070" //Imaging added - death traceback done
replace admdate=d(12jun2015) if pid=="20159070"
replace ptrectot=1 if pid=="20159070"
replace dcostatus=1 if pid=="20159070"
replace basis=2 if pid=="20159070"
replace init="i" if pid=="20159070"
replace comments="JC 21JUL2021: Added in KWG's CR5db comments - 23APR21_KWG Pt presented to AED 12JUN2015 c/o general malaise, anorexic, severe weight loss. Pt noted to have had pelvic ultrasound and no other intervention prior to presentation. Pt admitted. Family updated on possible prognosis of malignancy however declined any tests and wished discharge which was done 15Jun2015. 25MAR2015: ULTRASOUND PELVIS FINDINGS: Liver is normal in size and echo pattern and homogeneous in echotexture. Normal gallbladder. No calculi or other intraluminal abnormality is seen. No wall thickening, pericholecystic collection or intra or extrahepatic biliary duct dilatation. The pancreas was not well visualized. The spleen was not well visualized. Multiple enlarged periaortic lymph nodes are evident. In addition a 8.5cm soft tissue is seen in the right lower quadrant. This mass is causing right-sided urinary tract obstruction. Both kidneys are normal in size.....No free fluid or collection is seen. IMP: Diffuse intra-abdominal lymphadenopathy. Right lower quadrant soft tissue mass which is causing right sided urinary tract obstruction. Bladder diverticulum." if pid=="20159070"
//pid 20159071 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159072 reviewed but no update needed as notes in death trace-back consisted of 2 blank sheets + no dx/encounter info in MedData.
//pid 20159074 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
drop if pid=="20159075" //reviewed as COD=brain cancer but DA seen notes and meningioma not stated as malignant by NS, SF via email on 21jul2021
replace dot=d(24may2015) if pid=="20159077" //MedData entry added - further review done in MedData by JC 21jul2021
replace admdate=d(24may2015) if pid=="20159077"
replace ptrectot=1 if pid=="20159077"
replace dcostatus=1 if pid=="20159077"
replace basis=1 if pid=="20159077"
replace comments="JC 21JUL2021: TH lists dot as 15may2015 but no evidence of this date in MedData or CR5db comments. Added in TH's CR5db comments - No F/U needed." if pid=="20159077"
replace dot=d(20feb2015) if pid=="20159080" //Imaging added - death traceback done
replace admdate=d(20feb2015) if pid=="20159080"
replace ptrectot=1 if pid=="20159080"
replace dcostatus=1 if pid=="20159080"
replace basis=2 if pid=="20159080"
replace init="o" if pid=="20159080"
replace comments="JC 21JUL2021: Added in KWG's CR5db comments - 23APR21_KWG 20FEB2015 Pt presents to AED c/o rectal bleed, vomiting, pain to abdomen, weight loss and decreased appetite. Pt suspected of malignancy to colon and CT ordered for 21FEB2015. CT reported verbally but not seen in notes: 'Mass noted in the proximal transverse colon which has evidence of..perforation'. Surgery was only treatment option, however Pt was found to be too weak for further intervention and discharged." if pid=="20159080"
//pid 20159081 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159082 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
replace dot=d(15apr2014) if pid=="20159084" //MedData entry added - further review done in MedData by JC 21jul2021
replace dotyear=year(dot) if pid=="20159118"
replace dxyr=2014 if pid=="20159118"
replace admdate=d(15apr2014) if pid=="20159084"
replace ptrectot=1 if pid=="20159084"
replace dcostatus=1 if pid=="20159084"
replace basis=1 if pid=="20159084"
replace init="o" if pid=="20159084"
replace comments="JC 21JUL2021: JC 21JUL2021: Added in SF's CR5db comments - 12MAY21_KWG No F/U needed. 10MAY21_SF To Discuss. Found in MEDDATA. Dx: Abdominal Mass. Dx Date: 15UL14." if pid=="20159084"
//pid 20159085 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
replace dot=d(01jun2015) if pid=="20159086" //MedData entry added
replace admdate=d(01jun2015) if pid=="20159086"
replace ptrectot=1 if pid=="20159086"
replace dcostatus=1 if pid=="20159086"
replace basis=1 if pid=="20159086"
replace init="a" if pid=="20159086"
replace comments="JC 21JUL2021: JC 21JUL2021: Added in SF's CR5db comments - 12MAY21_KWG No F/U needed. 10MAY21_SF To Abs. Found in MEDDATA. Breast Cancer. Dx Date: 1JUN2015." if pid=="20159086"
replace dot=d(18jul2015) if pid=="20159089" //MedData entry added
replace admdate=d(18jul2015) if pid=="20159089"
replace ptrectot=1 if pid=="20159089"
replace dcostatus=1 if pid=="20159089"
replace basis=1 if pid=="20159089"
replace init="g" if pid=="20159089"
replace comments="JC 21JUL2021: JC 21JUL2021: Added in TH's CR5db comments - No F/U needed." if pid=="20159089"
//pid 20159090 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159091 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
replace dot=d(15jul2015) if pid=="20159092" //MedData entry added
replace admdate=d(15jul2015) if pid=="20159092"
replace ptrectot=1 if pid=="20159092"
replace dcostatus=1 if pid=="20159092"
replace basis=1 if pid=="20159092"
replace init="a" if pid=="20159092"
replace comments="JC 21JUL2021: Added in SF's CR5db comments - 12MAY21_KWG No F/U needed. 10MAY21_SF To Abs. Found in MEDDATA. Dx:Cancer of the Pancreas. Dx Date: 15JUL2015." if pid=="20159092"
replace dot=d(22may2015) if pid=="20159093" //MedData entry added - further review done in MedData by JC 21jul2021
replace admdate=d(22may2015) if pid=="20159093"
replace ptrectot=1 if pid=="20159093"
replace dcostatus=1 if pid=="20159093"
replace basis=1 if pid=="20159093"
//pid 20159093 some updates contain identifiable data so manually created an update excel sheet and merged with this dataset above
replace ptrectot=1 if pid=="20159096" //Death traceback done - DA didn't state last adm date before death and MedData missing the date of last admission.
replace dcostatus=1 if pid=="20159096"
replace basis=1 if pid=="20159096"
replace init="h" if pid=="20159096"
replace comments="JC 21JUL2021: Added in KWG's CR5db comments - 23APR21_KWG Notes seen, unclear when Pt diagnosed, no confirmation of prostate Ca seen. Abstracted as a DCO pending MedData F/U." if pid=="20159096"
replace ptrectot=1 if pid=="20159097" //Death traceback done - DA didn't state last adm date before death and MedData missing the date of last admission.
replace dcostatus=1 if pid=="20159097"
replace basis=1 if pid=="20159097"
replace init="e" if pid=="20159097"
replace comments="JC 21JUL2021: Added in KWG's CR5db comments - 23APR21_KWG Notes seen, unclear when Pt diagnosed, no confirmation of prostate Ca seen. Abstracted as a DCO pending MedData F/U." if pid=="20159097"
replace dot=d(07apr2015) if pid=="20159098" //MedData entry added
replace admdate=d(07apr2015) if pid=="20159098"
replace ptrectot=1 if pid=="20159098"
replace dcostatus=1 if pid=="20159098"
replace basis=1 if pid=="20159098"
replace init="d" if pid=="20159098"
replace comments="JC 21JUL2021: Added in SF's CR5db comments - 12MAY21_KWG No F/U needed. 10MAY21_SF To Abs. Found in MEDDATA. Dx: Colon Cancer. Dx Date: 7APR2015." if pid=="20159098"
//pid 20159102 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159103 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
replace dot=d(28jul2015) if pid=="20159104" //MedData entry added
replace admdate=d(28jul2015) if pid=="20159104"
replace ptrectot=1 if pid=="20159104"
replace dcostatus=1 if pid=="20159104"
replace basis=1 if pid=="20159104"
replace init="c" if pid=="20159104"
replace comments="JC 21JUL2021: Added in SF's CR5db comments - 12MAY21_KWG No F/U needed. 10MAY21_SF. To Abs. FName different from on list, should be: SONGOAN.  Middle Initials udpated. Dx: Ca Unspecified 80.9. Dx Date: 28JUL15." if pid=="20159104"
//pid 20159105 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159106 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159108 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159109 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159110 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159111 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159112 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159115 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
drop if pid=="20159116" //DA missed earlier encounters in MedData for prostate ca dx 11jan2012 and colon ca dx 01sep2011.
//pid 20159117 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
replace dot=d(30aug2013) if pid=="20159118" //MedData entry added - eligible prostate MP seen on MedData
replace dotyear=year(dot) if pid=="20159118"
replace dxyr=2013 if pid=="20159118"
replace admdate=d(30aug2013) if pid=="20159118"
replace ptrectot=3 if pid=="20159118"
replace dcostatus=1 if pid=="20159118"
replace basis=1 if pid=="20159118"
replace init="e" if pid=="20159118"
replace mpseq=1 if pid=="20159118" & cr5id=="T1S1"
replace mptot=2 if pid=="20159118" & cr5id=="T1S1"
replace patient=1 if pid=="20159118" & cr5id=="T1S1"
replace eidmp=1 if pid=="20159118" & cr5id=="T1S1"
replace ptrectot=3 if pid=="20159118" & cr5id=="T1S1"
replace persearch=1 if pid=="20159118" & cr5id=="T1S1"
replace comments="JC 21JUL2021: Added in SF's CR5db comments - 12MAY21_KWG No F/U needed. 10MAY21_SF To Abs. Found in MEDDATA. Middle Initial updated. Prostate and Bladder Cancer Diagnosed in 2013. Diagnosis dates: 13NOV13 and 30AUG13. Diagnosis year changed to 2013." if pid=="20159118"
expand=2 if pid=="20159118", gen (dupobs1do16)
replace dot=d(13nov2013) if pid=="20159118" & dupobs1do16>0
replace dotyear=year(dot) if pid=="20159118" & dupobs1do16>0
replace dxyr=2013 if pid=="20159118" & dupobs1do16>0
replace admdate=d(13nov2013) if pid=="20159118" & dupobs1do16>0
replace top="619" if pid=="20159118" & dupobs1do16>0
replace topography=619 if pid=="20159118" & dupobs1do16>0
replace topcat=53 if pid=="20159118" & dupobs1do16>0
replace primarysite="PROSTATE" if pid=="20159118" & dupobs1do16>0
replace morphology="8000" if pid=="20159118" & dupobs1do16>0
replace morph=8000 if pid=="20159118" & dupobs1do16>0
replace morphcat=1 if pid=="20159118" & dupobs1do16>0
replace hx="PROSTATE CANCER" if pid=="20159118" & dupobs1do16>0
replace lat=0 if pid=="20159118" & dupobs1do16>0
replace latcat=0 if pid=="20159118" & dupobs1do16>0
replace beh=3 if pid=="20159118" & dupobs1do16>0
replace grade=9 if pid=="20159118" & dupobs1do16>0
replace basis=1 if pid=="20159118" & dupobs1do16>0
replace dotyear=year(dot) if pid=="20159118" & dupobs1do16>0
replace dxyr=2013 if pid=="20159118" & dupobs1do16>0
replace ICD10="C61" if pid=="20159118" & dupobs1do16>0
replace ICCCcode="12b" if pid=="20159118" & dupobs1do16>0
replace cr5id="T2S1" if pid=="20159118" & dupobs1do16>0
replace mpseq=2 if pid=="20159118" & cr5id=="T2S1"
replace mptot=2 if pid=="20159118" & cr5id=="T2S1"
replace patient=2 if pid=="20159118" & cr5id=="T2S1"
replace eidmp=2 if pid=="20159118" & cr5id=="T2S1"
replace ptrectot=3 if pid=="20159118" & cr5id=="T2S1"
replace persearch=2 if pid=="20159118" & cr5id=="T2S1"
//pid 20159120 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159124 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
replace dot=d(01oct2015) if pid=="20159125" //Imaging added - death traceback done
replace admdate=d(02oct2015) if pid=="20159125"
replace dfc=d(01oct2015) if pid=="20159125"
replace ptrectot=1 if pid=="20159125"
replace dcostatus=1 if pid=="20159125"
replace basis=2 if pid=="20159125"
replace init="o" if pid=="20159125"
replace top="250" if pid=="20159125"
replace topography=250 if pid=="20159125"
replace comments="JC 21JUL2021: Added in KWG's CR5db comments - 21APR21_KWG REF Letter01OCT15 from Dr S King to AED: Dear Dr, Please continue management of Pt O Eversley. He presented yesterday and on examination revealed he was icteric with mild hepatomegaly along with obstructive jaundice. Ass: ?Pancreatic Ca. 01OCT15 Pt presents to AED c/o pale stools, dark urine, weight loss and decreased appetite. O/E: Abdomen soft, non-tender, mass on epigastrum, hard. ?Pancreatic mass ?Liver mass. U/S Abdomen ordered. 02OCT2015: U/S ABDOMEN. FINDINGS: The liver appears enlarged with multiple hypoechoic lesions noted. These may represent metastases. There is a 4.3cm x 4.6cm x 4.4cm heterogenous mass noted in the head of the pancreas. This may represent a pancreatic carcinoma. There is intra and extrahepatic biliary duct dilatation noted. The gallbladder is distended....IMP: 1. Hepatomegaly with hepatic metastases. 2. Likely pancreatic carcinoma of the head of the pancreas. Suggest contrast enhanced CT. 3. Intra and extrahepatic ductal dilatation with distended gallbladder." if pid=="20159125"
//pid 20159126 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159127 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159128 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
replace dot=d(27sep2015) if pid=="20159131" //MedData entry added - further review done by JC 21jul2021.
replace admdate=d(27sep2015) if pid=="20159131"
replace ptrectot=1 if pid=="20159131"
replace dcostatus=1 if pid=="20159131"
replace basis=1 if pid=="20159131"
replace comments="JC 21JUL2021: Added in SF's CR5db comments - 9APR21_KWG Notes seen and no mention of Ca seen. Abstracted as a DCO pending check in MedData." if pid=="20159131"
replace dot=d(19oct2015) if pid=="20159132" //Imaging added - death traceback done
replace admdate=d(19oct2015) if pid=="20159132"
replace ptrectot=1 if pid=="20159132"
replace dcostatus=1 if pid=="20159132"
replace basis=2 if pid=="20159132"
replace init="e" if pid=="20159132"
replace comments="JC 21JUL2021: Added in KWG's CR5db comments - 21APR21_KWG 18OCT2015 Pt presents to AED c/o hematuria and burning on urination. ?Bladder Ca. U/S ordered. 19OCT2021: U/S ABDOMEN/PELVIS FINDINGS: Abdominal aorta was visualized along its entire length. It is normal in caliber with atheromatous wall clacification....Urinary bladder: Partially distended with Foley's bulb in situ. Patient was unable to tolerate a full bladder. Aheterogeneous lesion measuring 3.6 x 2.4 x 2.3cm is noted within the bladder - ?Blood clot/mass. No free fluid in the peritoneal cavity. Please correlate with clinical findings." if pid=="20159132"
//pid 20159134 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159135 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
replace dot=d(26oct2015) if pid=="20159136" //MedData entry added
replace admdate=d(26oct2015) if pid=="20159136"
replace ptrectot=1 if pid=="20159136"
replace dcostatus=1 if pid=="20159136"
replace basis=1 if pid=="20159136"
replace init="c" if pid=="20159136"
replace comments="JC 21JUL2021: JC 21JUL2021: Added in TH's CR5db comments - No F/U needed." if pid=="20159136"
replace dot=d(08nov2015) if pid=="20159138" //Imaging added - death traceback done
replace admdate=d(08nov2015) if pid=="20159138"
replace ptrectot=1 if pid=="20159138"
replace dcostatus=1 if pid=="20159138"
replace basis=2 if pid=="20159138"
replace init="a" if pid=="20159138"
replace top="187" if pid=="20159138"
replace topography=187 if pid=="20159138"
replace comments="JC 21JUL2021: Added in KWG's CR5db comments - 23APR21_KWG 07NOV2015 Pt presented to AED c/o constipation, decreased oral intake, dehydration and distended abdomen. Pt appeared emaciated. 08NOV2015: CT ABDOMEN FINDINGS: Liver: There are multiple hypodensities noted in the liver likely hepatic metastases....Bowel: The large bowel appears prominent. There is apparent thickening of the walls of the caecum, ascending colon and rectum. There is an impression of a 2.5cm x 3.0cm soft tissue density noted in the sigmoid colon. Peritoneum: There is acites seen....Bones: There are lytic lesions in the imaged bones ?metastases. IMP: 1. ?Sigmoid tumour. 2. Bowel wall thickening of the rectum, caecum and ascending colon. 3. Hepatic metastases. 4. Ascites 5. Left renal cysts. 6. Bilateral pleural effusions and lower lobe consolidations. 7. ?Bony metastases." if pid=="20159138"
//pid 20159139 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
replace init="a" if pid=="20159140" //MedData entry added - further review done by JC 21jul2021.
replace comments="JC 21JUL2021: Added in KWG's CR5db comments - 9APR21_KWG Notes seen and Pt last seen in QEH on 03MAY2015 for unrelated reason. No malignancy seen in notes, abstracted as a DCO pending check in MedData." if pid=="20159140"
replace dot=d(09nov2015) if pid=="20159141" //MedData entry added - further review done by JC 21jul2021.
replace admdate=d(09nov2015) if pid=="20159141"
replace ptrectot=1 if pid=="20159141"
replace dcostatus=1 if pid=="20159141"
replace basis=1 if pid=="20159141"
replace init="e" if pid=="20159141"
replace comments="JC 21JUL2021: Added in SF's CR5db comments - 12MAY21_KWG No F/U needed. 10MAY21_SF To Abs. Found in MEDDATA. Dx: Malignant Neoplasm of Ovary. Dx Date: 20NOV2015. Middle Initial updated." if pid=="20159141"
//pid 20159142 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159143 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
replace dot=d(10nov2015) if pid=="20159144" //Imaging added - death traceback done
replace admdate=d(10nov2015) if pid=="20159144"
replace ptrectot=1 if pid=="20159144"
replace dcostatus=1 if pid=="20159144"
replace basis=2 if pid=="20159144"
replace init="l" if pid=="20159144"
replace comments="JC 21JUL2021: Added in KWG's CR5db comments - 9APR21_KWG Notes seen, Pt diagnosed from CT scan done on 13NOV15. Report not seen in notes, but summarized. See S1. Pt presented to QEH on 10NOV2015 c/o vomiting for 1/7 'black stuff' and weight loss for 2/12, decreased appetite, abdominal pain and back pain. 13NOV2015: CT ABDOMEN FINDINGS: Cystic mass ?Origin along with metastases to liver and omentum." if pid=="20159144"
replace dot=d(08dec2015) if pid=="20159145" //MedData entry added
replace admdate=d(08dec2015) if pid=="20159145"
replace ptrectot=1 if pid=="20159145"
replace dcostatus=1 if pid=="20159145"
replace basis=1 if pid=="20159145"
replace init="i" if pid=="20159145"
replace comments="JC 21JUL2021: Added in KWG's CR5db comments - 12MAY21_KWG No F/U needed. 10MAY21_SF To Abs. Found in MEDDATA. Middle Initial updated. Dx: Multiple Myeloma. Dx Date: 8DEC2015." if pid=="20159145"
replace comments="JC 21JUL2021: Added in KWG's CR5db comments - 21APR21_KWG Notes seen, very old, no information on Ca. Abstracted as a DCO pending check in MedData." if pid=="20159146" //MedData entry added - further review done by JC 21jul2021.
//pid 20159148 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20159150 reviewed but no update needed as accidentally abstracted by DA during death trace-back.
//pid 20160017 reviewed and abstracted - contain identifiable data so manually created an update excel sheet and merged with this dataset above
//pid 20160032 reviewed and abstracted - contain identifiable data so manually created an update excel sheet and merged with this dataset above
//pid 20160537 reviewed but no update needed as T2 merged incorrectly with this pid instead of 20151204 as noted in CR5db comments.
//pid 20160556 reviewed and abstracted - contain identifiable data so manually created an update excel sheet and merged with this dataset above
//pid 20172150 reviewed but no update needed as merge done with pid 20140942 (ineligible so not in iarc ds) for 2017 MP
//pid 20180030 reviewed and abstracted - contain identifiable data so manually created an update excel sheet and merged with this dataset above - MISSED ABS: emailed to KWG cc SF for review as it's blank but has F/U to be done.
//pid 20180587 reviewed and abstracted - contain identifiable data so manually created an update excel sheet and merged with this dataset above - MISSED ABS
//pid 20180701 reviewed but no update needed as case ineligible.
//pid 20180707 reviewed and abstracted - contain identifiable data so manually created an update excel sheet and merged with this dataset above - MISSED UPDATE AT MERGE
//pid 20180731 reviewed and abstracted - contain identifiable data so manually created an update excel sheet and merged with this dataset above
//pid 20180750 reviewed and abstracted - contain identifiable data so manually created an update excel sheet and merged with this dataset above - MISSED ABS
//pid 20180867 reviewed and abstracted - contain identifiable data so manually created an update excel sheet and merged with this dataset above
//pid 20180868 reviewed and abstracted - contain identifiable data so manually created an update excel sheet and merged with this dataset above - INCORRECT NRN
//pid 20180871 reviewed and NOT abstracted - MISSED ABS: DA doesn't state if tumour was malignant or not; If malignant then was eligible as dx in 2008 - but cannot abstract as uncertain malignancy (09MAR20_KWG Notes seen and case ineligible, Pt first seen in QEH for adrenal tumour in 2008. Record status updated. 07JAN20_KWG Case entered as a DCN from Death Data, traceback for eligibility.).
//pid 20181095 reviewed and abstracted - contain identifiable data so manually created an update excel sheet and merged with this dataset above - MISSED ABS: emailed to KWG cc SF for review as it's blank but has F/U to be done.
//pid 20181151 reviewed but no update needed as case ineligible.
//pid 20181162 reviewed but no update needed as case ineligible.
//pid 20200239 reviewed but no update needed as case is for 2020 but dxyr incorrectly noted as 2015 - emailed to DA to correct in main db.
//pid 20200243 reviewed but no update needed as case is for 2020 but dxyr incorrectly noted as 2015 - emailed to DA to correct in main db.













WHEN RUNNING ABOVE UPDATES, ENSURE ALL HAVE CHANGES.
IF SOME DON'T THEN CHECK IF THE MERGED PID WAS USED IN IARC DATASET INSTEAD AND UPDATE THE ABOVE CODE.








** SF noted on 29jun2021 during cancer mtg some 2016 prostate cases have morph=8550 for acinar adenoca but should=8140
** JC double checked 29jun2021 and found some 2008 etc prostate cases with morph=8550 instead of 8140
count if morph==8550 and topography==619 //173
replace morph=8140 if morph==8550 and topography==619 //173 changes



Check for persearch=Dup to remove
RE-RUN FINAL CHECKS
RE-RUN AGE CHECK + NAMES AND NRN DUPLICATES CHECKS
Check if pt deceased but dlc and dod do not match
Review DCOs in MedData (basis==0)
Check for resident=2 or 99 then look them up in MedData
2020 death prep and matching so can have 5yr survival for 2015 data
Run data through IARCcrgTools - Check + MP programs
Re-run 2008-2015 survival code to generate surv ds
NEED TO RE-RUN ALL IARC ANALYSIS AND 2015 ANN RPT ANALYSIS


stop
** Remove unused variables
drop pop_bb dd_dcstatus tfdddoa tfddda tfregnumstart tfdistrictstart tfregnumend tfdistrictend tfddtxt recstattf ttdoadotdiff

** JC 26-Oct-2020: For quality assessment by IARC Hub, save this corrected dataset with all malignant + non-malignant tumours 2008, 2013-2015
** See p131 version06 for more info on this data request
save "`datapath'\version02\3-output\2008_2013_2014_2015_iarchub_nonsurvival_nonreportable", replace
label data "2008 2013 2014 2015 BNR-Cancer analysed data - Non-survival Dataset for IARC Hub's Data Request"
note: TS This dataset was used for data prep for IARC Hub's quality assessment (see p131 v06)
note: TS Excludes ineligible case definition
note: TS Includes unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs

** Removing cases not included for reporting: if case with MPs ensure record with persearch=1 is not dropped as used in survival dataset
drop if resident==2 //4 deleted - nonresident
drop if resident==99 //40 deleted - resident unknown
drop if recstatus==3 //0 deleted - ineligible case definition
drop if sex==9 //0 deleted - sex unknown
drop if beh!=3 //51 deleted - non malignant
drop if persearch>2 //3 deleted
drop if siteiarc==25 //0 - non reportable skin cancers

** Check for cases wherein the non-reportable cancer had the below MP categories as the primary options
tag duplicate pid
using tag check if patient=separate event for a single pid
same for eidmp ptrectot

** JC 03-Jun-2021: For quality assessment by IARC Hub, save this corrected dataset with all malignant (non-reportable skin + non-malignant tumours removed) for 2008, 2013-2015
** See p131 version06 for more info on this data request
save "`datapath'\version02\3-output\2008_2013_2014_2015_iarchub_nonsurvival_reportable", replace
label data "2008 2013 2014 2015 BNR-Cancer analysed data - Non-survival Dataset for IARC Hub's Data Request"
note: TS This dataset was used for data prep for IARC Hub's quality assessment (see p131 v06)
note: TS Excludes ineligible case definition
note: TS Excludes ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs

** For 2015 annaul report remove 2008 cases as decided by NS on 06-Oct-2020, email subject: BNR-C: 2015 cancer stats tables completed
drop if dxyr==2008


** Removing cases not included for reporting: if case with MPs ensure record with persearch=1 is not dropped as used in survival dataset
**drop dup_id
sort pid
duplicates tag pid, gen(dup_id)
list pid cr5id patient eidmp persearch if dup_id>0, nolabel sepby(pid)
drop if resident==2 //4 deleted - nonresident
drop if resident==99 //40 deleted - resident unknown
drop if recstatus==3 //0 deleted - ineligible case definition
drop if sex==9 //0 deleted - sex unknown
drop if beh!=3 //51 deleted - non malignant
drop if persearch>2 //3 deleted
drop if siteiarc==25 //0 - non reportable skin cancers
drop dup_id

count //3484; 3488; 2744

capture export_excel using "`datapath'\version02\3-output\2013-2015BNRnonsurvivalV03.xlsx", sheet("2013_2014_2015_20201026") firstrow(varlabels) replace

** Save this corrected dataset with internationally reportable cases
save "`datapath'\version02\3-output\2013_2014_2015_cancer_nonsurvival", replace
label data "2013 2014 2015 BNR-Cancer analysed data - Non-survival Dataset"
note: TS This dataset was used for 2015 annual report
note: TS Excludes ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs


***********************
**   2013 2014 2015  **
** Survival Datasets **
***********************
/*
Data ineligible/excluded from survival analysis - taken from IARC 2012 summer school presented by Manuela Quaresma
Ineligible Criteria:
- Incomplete data
- Beh not=/3
- Not resident
- Inappropriate morph code

Excluded Criteria:
- Age 100+
- SLC unknown
- Duplicate
- Synchronous tumour
- Sex incompatible with site
- Dates invalid
- Inconsistency between dob, dot and dlc
- Multiple primary
- DCO / zero survival (true zero survival included i.e. dot=dod but not a DCO)
*/

**************************************************************************
* SURVIVAL ANALYSIS
* Survival analysis to 1 year, 3 years and 5 years
**************************************************************************
** 2008 cases to be dropped for 2015 annual report, as decided by NS on 06-Oct-2020, email subject: BNR-C: 2015 cancer stats tables completed
** Load the dataset
use "`datapath'\version02\3-output\2013_2014_2015_cancer_nonsurvival_bnr_reportable", clear

** Update dataset to meet IARC standards for calculating survival
tab patient ,m 
tab persearch ,m 
tab eidmp ,m 
count if patient==2 & persearch==1 //0
//list pid fname lname if patient==2 & persearch==1

** Note: most below figures will be less one(1) as found one(1) ineligible during 2015 reviews (pid=20141523)
count //2843

drop if basis==0 //217 deleted - DCO 
drop if age>100 //6 deleted - age 100+
drop if slc==99 //0 deleted - status at last contact unknown
drop if patient!=1 //51 deleted - MP
drop if resident==2 //0 deleted - nonresident
drop if resident==99 //109 deleted - resident unknown
drop if recstatus==3 //0 deleted - ineligible case definition
drop if sex==9 //0 deleted - sex unknown
drop if beh!=3 //48 deleted - nonmalignant
drop if persearch>2 //1 to be deleted
drop if siteiarc==25 //0 deleted - nonreportable skin cancers

count //2411

** now ensure everyone has a unique id
count if pid=="" //0

recode deceased 2=0 //1058 changes

gen deceased_1yr=deceased
gen deceased_3yr=deceased
gen deceased_5yr=deceased
label drop deceased_lab
label define deceased_lab 0 "censored" 1 "dead", modify
label values deceased deceased_1yr deceased_3yr deceased_5yr deceased_lab
label var deceased "Survival identifer"
label var deceased_1yr "Survival identifer at 1yr"
label var deceased_3yr "Survival identifer at 3yrs"
label var deceased_5yr "Survival identifer at 5yrs"

tab deceased ,m //1353 dead; 1058 censored
tab deceased_1yr ,m //1353 dead; 1058 censored
tab deceased_3yr ,m //1353 dead; 1058 censored
tab deceased_5yr ,m //1353 dead; 1058 censored
count if dlc==. //0
count if dod==. //1058

** check for all patients who are deceased but missing dod
count if deceased==1 & dod==. //0
count if deceased_1yr==1 & dod==. //0
count if deceased_3yr==1 & dod==. //0
count if deceased_5yr==1 & dod==. //0

count if dot==. //0

** Create end_date variables: 1 year, 3 years and 5 years from incidence
gen enddate_1yr=(dot+(365.25*1)) if dot!=.
gen enddate_3yr=(dot+(365.25*3)) if dot!=.
gen enddate_5yr=(dot+(365.25*5)) if dot!=. & dxyr<2015 //2019 death data not available as of 17nov2019; 2019 deaths now added 30-Sep-2020 so code updated from dxyr<2014

format enddate* %dD_m_CY

count if enddate_1yr==. //0
count if enddate_3yr==. //0
count if enddate_5yr==. & dxyr<2015 //0

** Since end_date is 1, 3, 5 years from incidence, reset deceased from dead to censored if pt died after end_date
count if dod!=. & dod>dot+(365.25*1) //517
//list pid deceased_1yr dot dod dlc enddate_1yr if dod!=. & dod>dot+(365.25*1)
count if dod!=. & dod>dot+(365.25*3) //151
//list pid deceased_3yr dot dod dlc enddate_3yr if dod!=. & dod>dot+(365.25*3)
count if dod!=. & dod>dot+(365.25*5) & dxyr<2015 //14
//list pid deceased_5yr dot dod dlc enddate_5yr if dod!=. & dod>dot+(365.25*5)

replace deceased_1yr=0 if dod!=. & dod>dot+(365.25*1) //517 changes
replace deceased_3yr=0 if dod!=. & dod>dot+(365.25*3) //151 changes
replace deceased_5yr=0 if dod!=. & dod>dot+(365.25*5) & dxyr<2015 //14 changes

** set to missing those who have dod>1 year from incidence date - but
** first create new variable for time to death/date last seen, called "time"
** (1) use dod to define time to death if died within 1, 3, 5 yrs
gen time_1yr=dod-dot if (dod!=. & deceased_1yr==1 & dod<dot+(365.25*1))
gen time_3yr=dod-dot if (dod!=. & deceased_3yr==1 & dod<dot+(365.25*3))
gen time_5yr=dod-dot if (dod!=. & deceased_5yr==1 & dod<dot+(365.25*5) & dxyr<2015)

** (2) next use 1, 3, 5 yrs as time, if died >1, >3, >5 yrs from incidence
count if (enddate_1yr<dod & dod!=. & deceased_1yr==1) //0
replace time_1yr=enddate_1yr-dot if (enddate_1yr<dod & dod!=. & deceased_1yr==1) //0 changes
count if (enddate_3yr<dod & dod!=. & deceased_3yr==1) //0
replace time_3yr=enddate_3yr-dot if (enddate_3yr<dod & dod!=. & deceased_3yr==1) //0 changes
count if (enddate_5yr<dod & dod!=. & deceased_5yr==1 & dxyr<2015) //0
replace time_5yr=enddate_5yr-dot if (enddate_5yr<dod & dod!=. & deceased_5yr==1 & dxyr<2015) //0 changes

** (2) next use dlc as end date, if alive and have date last seen (dlc)
count if (dlc<enddate_1yr & deceased_1yr==0) //916
replace time_1yr=dlc-dot if (dlc<enddate_1yr & deceased_1yr==0) //916 changes
count if (dlc<enddate_3yr & deceased_3yr==0) //1054
replace time_3yr=dlc-dot if (dlc<enddate_3yr & deceased_3yr==0) //1054 changes
count if (dlc<enddate_5yr & deceased_5yr==0 & dxyr<2015) //620
replace time_5yr=dlc-dot if (dlc<enddate_5yr & deceased_5yr==0 & dxyr<2015) //620 changes

//tab time_1yr ,m //875=missing; 298=0; 1060=missing; 546=0
//tab time_3yr ,m //292=missing; 298=0; 336=missing; 535=0
//tab time_5yr if dxyr<2015 ,m //48=missing; 86=0; 58=missing; 273=0
//list time_1yr dot dlc enddate_1yr dod deceased_1yr if time_1yr==.
replace time_1yr=enddate_1yr-dot if (enddate_1yr<dlc & deceased_1yr==0) & time_1yr==. & dlc!=. //659 changes
replace time_3yr=enddate_3yr-dot if (enddate_3yr<dlc & deceased_3yr==0) & time_3yr==. & dlc!=. //155 changes
replace time_5yr=enddate_5yr-dot if (enddate_5yr<dlc & deceased_5yr==0) & time_5yr==. & dlc!=. & dxyr<2015 //15 changes

count if time_1yr==. //0
count if time_3yr==. //0
count if time_5yr==. & dxyr<2015 //0

replace time_1yr=dlc-dot if deceased_1yr==0 & time_1yr==. //0 changes
replace time_3yr=dlc-dot if deceased_3yr==0 & time_3yr==. //0 changes
replace time_5yr=dlc-dot if deceased_5yr==0 & time_5yr==. & dxyr<2015 //0 changes

** these are from above - change dod to missing (deceased already
** set to 0 above) as they did not die within 1, 3, 5, 10 years
gen dod_1yr=dod
gen dod_3yr=dod
gen dod_5yr=dod 
format dod_* %tdCCYY-NN-DD

replace dod_1yr=. if enddate_1yr<dod_1yr & dod_1yr!=. //517 changes
replace dod_3yr=. if enddate_3yr<dod_3yr & dod_3yr!=. //151 changes
replace dod_5yr=. if enddate_5yr<dod_5yr & dod_5yr!=. & dxyr<2015 //14 changes

sort enddate_*
tab enddate_1yr ,m 
tab enddate_3yr ,m 
tab enddate_5yr if dxyr<2015 ,m

** Now to set up dataset for survival analysis, we need each patient's date of
** entry to study (incidence date, or dot), and exit date from study which is end_date
** UNLESS they died before end_date or were last seen before end_date in which case
** they should be censored... so now we create a NEW end_date as a combination of
** the above

** Below code added so that all 'censored' cases should have 
** newenddate = 31-dec-2018 if newenddate < 31-dec-2018
sort dot
sort pid
//list deceased_1yr dot newenddate_1yr if deceased_1yr!=1
//list deceased_3yr dot newenddate_3yr if deceased_3yr!=1
//list deceased_5yr dot dlc newenddate_5yr if deceased_5yr!=1
count if dlc>d(31dec2019) & deceased_1yr!=1 //4-dlc in 2019; 0
count if dlc>d(31dec2019) & deceased_3yr!=1 //4; 0
count if dlc>d(31dec2019) & deceased_5yr!=1 //4; 0
//list pid dot dlc deceased_1yr if dlc>d(31dec2019) & deceased_1yr!=1

** Create new end_date based on fixed censored date of 31dec2018 (last date of current death data)
//list pid dot deceased_1yr dod dlc end_date
count if (enddate_1yr>dod_1yr & dod_1yr!=. & deceased_1yr==1) //836
count if (enddate_3yr>dod_3yr & dod_3yr!=. & deceased_3yr==1) //1202
count if (enddate_5yr>dod_5yr & dod_5yr!=. & deceased_5yr==1 & dxyr<2015) //902
gen newenddate_1yr=d(31dec2019) if deceased_1yr!=1
gen newenddate_3yr=d(31dec2019) if deceased_3yr!=1
gen newenddate_5yr=d(31dec2019) if deceased_5yr!=1

/* old method
gen newenddate_1yr=dod_1yr if (enddate_1yr>dod_1yr & dod_1yr!=. & deceased_1yr==1)
gen newenddate_3yr=dod_3yr if (enddate_3yr>dod_3yr & dod_3yr!=. & deceased_3yr==1)
gen newenddate_5yr=dod_5yr if (enddate_5yr>dod_5yr & dod_5yr!=. & deceased_5yr==1 & dxyr<2014)

count if (dlc<enddate_1yr) & dod_1yr==. & deceased_1yr==0 //1034
count if (dlc<enddate_3yr) & dod_3yr==. & deceased_3yr==0 //1263
count if (dlc<enddate_5yr) & dod_5yr==. & deceased_5yr==0 & dxyr<2014 //571
replace newenddate_1yr=dlc if (dlc<enddate_1yr) & dod_1yr==. & deceased_1yr==0 //588 changes
replace newenddate_3yr=dlc if (dlc<enddate_3yr) & dod_3yr==. & deceased_3yr==0 //808 changes
replace newenddate_5yr=dlc if (dlc<enddate_5yr) & dod_5yr==. & deceased_5yr==0 & dxyr<2014 //572 changes
*/
count if newenddate_1yr==. //836
count if newenddate_3yr==. //1202
count if newenddate_5yr==. & dxyr<2015 //902

//list dot deceased_1yr dod_1yr dlc enddate_1yr if newenddate_1yr==.
replace newenddate_1yr=enddate_1yr if newenddate_1yr==. //836 changes
replace newenddate_3yr=enddate_3yr if newenddate_3yr==. //1202 changes
replace newenddate_5yr=enddate_5yr if newenddate_5yr==. & dxyr<2015 //902 changes
format newenddate_* %dD_m_CY

sort dot
tab time_1yr ,m //659=365.25
tab time_3yr ,m //155=1095.75
tab time_5yr if dxyr<2015 ,m //15=1826.25

replace time_1yr=365 if time_1yr==365.25 //659 changes
replace time_3yr=1095 if time_3yr==1095.75 //155 changes
replace time_5yr=1826 if time_5yr==1826.25 //15 changes

count if time_1yr==0 //520
count if time_3yr==0 //510
count if time_5yr==0 //257
//list basis deceased_1yr dot dod_1yr dlc enddate_1yr newenddate_1yr if time_1yr==0 ,noobs
//list basis deceased_3yr dot dod_3yr dlc enddate_3yr newenddate_3yr if time_3yr==0 ,noobs
//list basis deceased_5yr dot dod_5yr dlc enddate_5yr newenddate_5yr if time_5yr==0 ,noobs
//list basis deceased_10yr dot dod_10yr dlc enddate_10yr newenddate_10yr if time_10yr==0 ,noobs

** Since DCOs have been removed from this dataset, all cases whether dead or censored
** should have at least a value of 1 day
/* old method when DCOs were in ds
replace newend_date=newend_date+1 if (time==0 & deceased==0)
replace time=1 if (time==0 & deceased==0) //241 changes
*/
replace newenddate_1yr=newenddate_1yr+1 if time_1yr==0 //520 changes
replace time_1yr=1 if time_1yr==0 //520 changes
replace newenddate_3yr=newenddate_3yr+1 if time_3yr==0 //510 changes
replace time_3yr=1 if time_3yr==0 //510 changes
replace newenddate_5yr=newenddate_5yr+1 if time_5yr==0 //257 changes
replace time_5yr=1 if time_5yr==0 //257 changes

tab deceased ,m 
tab deceased_1yr ,m
tab deceased_3yr ,m 
tab deceased_5yr ,m 

count //2411


tab deceased_1yr dxyr ,m
tab deceased_3yr dxyr ,m
tab deceased_5yr dxyr if dxyr<2015 ,m


** Create survival variables by dxyr
gen surv1yr_2013=1 if deceased_1yr==1 & dxyr==2013
replace surv1yr_2013=0 if deceased_1yr==0 & dxyr==2013
gen surv3yr_2013=1 if deceased_3yr==1 & dxyr==2013
replace surv3yr_2013=0 if deceased_3yr==0 & dxyr==2013
gen surv5yr_2013=1 if deceased_5yr==1 & dxyr==2013
replace surv5yr_2013=0 if deceased_5yr==0 & dxyr==2013
gen surv1yr_2014=1 if deceased_1yr==1 & dxyr==2014
replace surv1yr_2014=0 if deceased_1yr==0 & dxyr==2014
gen surv3yr_2014=1 if deceased_3yr==1 & dxyr==2014
replace surv3yr_2014=0 if deceased_3yr==0 & dxyr==2014
gen surv5yr_2014=1 if deceased_5yr==1 & dxyr==2014
replace surv5yr_2014=0 if deceased_5yr==0 & dxyr==2014
gen surv1yr_2015=1 if deceased_1yr==1 & dxyr==2015
replace surv1yr_2015=0 if deceased_1yr==0 & dxyr==2015
gen surv3yr_2015=1 if deceased_3yr==1 & dxyr==2015
replace surv3yr_2015=0 if deceased_3yr==0 & dxyr==2015
label define surv_lab 0 "censored" 1 "dead", modify
label values surv1yr_2013 surv3yr_2013 surv5yr_2013 surv1yr_2014 surv3yr_2014 surv5yr_2014 surv1yr_2015 surv3yr_2015 surv_lab
label var surv1yr_2013 "Survival at 1yr - 2013"
label var surv3yr_2013 "Survival at 3yrs - 2013"
label var surv5yr_2013 "Survival at 5yrs - 2013"
label var surv1yr_2014 "Survival at 1yr - 2014"
label var surv3yr_2014 "Survival at 3yrs - 2014"
label var surv5yr_2014 "Survival at 5yrs - 2014"
label var surv1yr_2015 "Survival at 1yr - 2015"
label var surv3yr_2015 "Survival at 3yrs - 2015"

tab dxyr ,m
tab surv1yr_2013 if dxyr==2013 ,m
tab surv3yr_2013 if dxyr==2013 ,m
tab surv5yr_2013 if dxyr==2013 ,m
tab surv1yr_2014 if dxyr==2014 ,m
tab surv3yr_2014 if dxyr==2014 ,m
tab surv5yr_2014 if dxyr==2014 ,m
tab surv1yr_2015 if dxyr==2015 ,m
tab surv3yr_2015 if dxyr==2015 ,m


** Top 10 survival at 1, 3, 5 years by diagnosis year
**********
** 2013 **
**********
** PROSTATE
tab surv1yr_2013 if siteiarc==39 //prostate 1-yr survival
tab surv3yr_2013 if siteiarc==39 //prostate 3-yr survival
tab surv5yr_2013 if siteiarc==39 //prostate 5-yr survival
** BREAST
tab surv1yr_2013 if siteiarc==29 //breast 1-yr survival
tab surv3yr_2013 if siteiarc==29 //breast 3-yr survival
tab surv5yr_2013 if siteiarc==29 //breast 5-yr survival
** COLON
tab surv1yr_2013 if siteiarc==13 //colon 1-yr survival
tab surv3yr_2013 if siteiarc==13 //colon 3-yr survival
tab surv5yr_2013 if siteiarc==13 //colon 5-yr survival
** CORPUS UTERI
tab surv1yr_2013 if siteiarc==33 //corpus uteri 1-yr survival
tab surv3yr_2013 if siteiarc==33 //corpus uteri 3-yr survival
tab surv5yr_2013 if siteiarc==33 //corpus uteri 5-yr survival
** RECTUM
tab surv1yr_2013 if siteiarc==14 //rectum 1-yr survival
tab surv3yr_2013 if siteiarc==14 //rectum 3-yr survival
tab surv5yr_2013 if siteiarc==14 //rectum 5-yr survival
** LUNG
tab surv1yr_2013 if siteiarc==21 //lung 1-yr survival
tab surv3yr_2013 if siteiarc==21 //lung 3-yr survival
tab surv5yr_2013 if siteiarc==21 //lung 5-yr survival
** CERVIX
tab surv1yr_2013 if siteiarc==32 //cervix 1-yr survival
tab surv3yr_2013 if siteiarc==32 //cervix 3-yr survival
tab surv5yr_2013 if siteiarc==32 //cervix 5-yr survival
** STOMACH
tab surv1yr_2013 if siteiarc==11 //stomach 1-yr survival
tab surv3yr_2013 if siteiarc==11 //stomach 3-yr survival
tab surv5yr_2013 if siteiarc==11 //stomach 5-yr survival
** MULTIPLE MYELOMA 
tab surv1yr_2013 if siteiarc==55 //mm  1-yr survival
tab surv3yr_2013 if siteiarc==55 //mm  3-yr survival
tab surv5yr_2013 if siteiarc==55 //mm  5-yr survival
** NON-HODGKIN LYMPHOMA
tab surv1yr_2013 if siteiarc==53 //nhl  1-yr survival
tab surv3yr_2013 if siteiarc==53 //nhl  3-yr survival
tab surv5yr_2013 if siteiarc==53 //nhl  5-yr survival

**********
** 2014 **
**********
** PROSTATE
tab surv1yr_2014 if siteiarc==39 //prostate 1-yr survival
tab surv3yr_2014 if siteiarc==39 //prostate 3-yr survival
tab surv5yr_2014 if siteiarc==39 //prostate 5-yr survival
** BREAST
tab surv1yr_2014 if siteiarc==29 //breast 1-yr survival
tab surv3yr_2014 if siteiarc==29 //breast 3-yr survival
tab surv5yr_2014 if siteiarc==29 //breast 5-yr survival
** COLON
tab surv1yr_2014 if siteiarc==13 //colon 1-yr survival
tab surv3yr_2014 if siteiarc==13 //colon 3-yr survival
tab surv5yr_2014 if siteiarc==13 //colon 5-yr survival
** CORPUS UTERI
tab surv1yr_2014 if siteiarc==33 //corpus uteri 1-yr survival
tab surv3yr_2014 if siteiarc==33 //corpus uteri 3-yr survival
tab surv5yr_2014 if siteiarc==33 //corpus uteri 5-yr survival
** RECTUM
tab surv1yr_2014 if siteiarc==14 //rectum 1-yr survival
tab surv3yr_2014 if siteiarc==14 //rectum 3-yr survival
tab surv5yr_2014 if siteiarc==14 //rectum 5-yr survival
** LUNG
tab surv1yr_2014 if siteiarc==21 //lung 1-yr survival
tab surv3yr_2014 if siteiarc==21 //lung 3-yr survival
tab surv5yr_2014 if siteiarc==21 //lung 5-yr survival
** CERVIX
tab surv1yr_2014 if siteiarc==32 //cervix 1-yr survival
tab surv3yr_2014 if siteiarc==32 //cervix 3-yr survival
tab surv5yr_2014 if siteiarc==32 //cervix 5-yr survival
** STOMACH
tab surv1yr_2014 if siteiarc==11 //stomach 1-yr survival
tab surv3yr_2014 if siteiarc==11 //stomach 3-yr survival
tab surv5yr_2014 if siteiarc==11 //stomach 5-yr survival
** MULTIPLE MYELOMA 
tab surv1yr_2014 if siteiarc==55 //mm  1-yr survival
tab surv3yr_2014 if siteiarc==55 //mm  3-yr survival
tab surv5yr_2014 if siteiarc==55 //mm  5-yr survival
** NON-HODGKIN LYMPHOMA
tab surv1yr_2014 if siteiarc==53 //nhl  1-yr survival
tab surv3yr_2014 if siteiarc==53 //nhl  3-yr survival
tab surv5yr_2014 if siteiarc==53 //nhl  5-yr survival


**********
** 2015 **
**********
** PROSTATE
tab surv1yr_2015 if siteiarc==39 //prostate 1-yr survival
tab surv3yr_2015 if siteiarc==39 //prostate 3-yr survival
** BREAST
tab surv1yr_2015 if siteiarc==29 //breast 1-yr survival
tab surv3yr_2015 if siteiarc==29 //breast 3-yr survival
** COLON
tab surv1yr_2015 if siteiarc==13 //colon 1-yr survival
tab surv3yr_2015 if siteiarc==13 //colon 3-yr survival
** CORPUS UTERI
tab surv1yr_2015 if siteiarc==33 //corpus uteri 1-yr survival
tab surv3yr_2015 if siteiarc==33 //corpus uteri 3-yr survival
** RECTUM
tab surv1yr_2015 if siteiarc==14 //rectum 1-yr survival
tab surv3yr_2015 if siteiarc==14 //rectum 3-yr survival
** LUNG
tab surv1yr_2015 if siteiarc==21 //lung 1-yr survival
tab surv3yr_2015 if siteiarc==21 //lung 3-yr survival
** CERVIX
tab surv1yr_2015 if siteiarc==32 //cervix 1-yr survival
tab surv3yr_2015 if siteiarc==32 //cervix 3-yr survival
** STOMACH
tab surv1yr_2015 if siteiarc==11 //stomach 1-yr survival
tab surv3yr_2015 if siteiarc==11 //stomach 3-yr survival
** MULTIPLE MYELOMA 
tab surv1yr_2015 if siteiarc==55 //mm  1-yr survival
tab surv3yr_2015 if siteiarc==55 //mm  3-yr survival
** NON-HODGKIN LYMPHOMA
tab surv1yr_2015 if siteiarc==53 //nhl  1-yr survival
tab surv3yr_2015 if siteiarc==53 //nhl  3-yr survival


** Create patient total variables to use in 30_report cancer.do
tab patient dxyr ,m
egen pttotsurv_2015=count(patient) if patient==1 & dxyr==2015
egen pttotsurv_2014=count(patient) if patient==1 & dxyr==2014
egen pttotsurv_2013=count(patient) if patient==1 & dxyr==2013
egen pttotsurv_2008=count(patient) if patient==1 & dxyr==2008

count //2411

** Save this corrected dataset with only reportable cases
save "`datapath'\version02\3-output\2013_2014_2015_cancer_survival", replace
label data "2013 2014 2015 BNR-Cancer analysed data - Survival BNR Reportable Dataset"
note: TS This dataset was used for 2015 annual report
note: TS For survival analysis, use variables surv1yr_2013, surv1yr_2014, surv1yr_2015, surv3yr_2013, surv3yr_2014, surv3yr_2015, surv5yr_2013, surv5yr_2014



********************
** Death Matching **
**  with CF data  **
********************

** To reduce the # of DCOs and trace-back I performed below on data from MasterDb
** Check CF data to see if any match with unmatched 2015 death certificates (aim: to reduce DCO %)
use "`datapath'\version02\2-working\2015_death certificates_DCOs" ,clear
gen dco_deaths=1
count //163

preserve
use "`datapath'\version02\2-working\2015_cancer_nonsurvival" ,clear
drop if basis!=0 & basis!=. //891 deleted
gen dco_cancer=1
count //13
save "`datapath'\version02\2-working\2015_cancer_DCOs" ,replace
restore

append using "`datapath'\version02\2-working\2015_cancer_DCOs"

count //176

preserve
clear

import excel using "`datapath'\version02\1-input\20200220tblCaseFinding.xlsx", firstrow
rename No cfid_2008
rename FirstName fname
rename LastName lname
rename Age age
rename Sex sex
rename AbstrStatus absstatus
rename NRN natregno
rename NFDxYear cfdxyr
rename Comments comments_2008
replace natregno=subinstr(natregno,"-","",.)
replace fname = lower(rtrim(ltrim(itrim(fname))))
replace lname = lower(rtrim(ltrim(itrim(lname))))
replace absstatus="0" if absstatus=="Pending"
replace absstatus="1" if regexm(absstatus,"Abstracted -")|absstatus=="Abstracted"
replace absstatus="2" if regexm(absstatus,"Ineligible")
replace absstatus="3" if absstatus=="Not Abstracted"
destring absstatus ,replace
label define absstatus_lab 0 "pending" 1 "abstracted" 2 "abstracted-ineligible" 3 "not abstracted" , modify
label values absstatus absstatus_lab
keep cfid_2008 fname lname age sex natregno absstatus comments_2008 cfdxyr
count //4821
save "`datapath'\version02\2-working\2008_cancer_CF" ,replace
restore

preserve
clear
import excel using "`datapath'\version02\1-input\20200220tblCaseFinding_2009.xlsx", firstrow
rename No cfid_2013
rename FirstName fname
rename LastName lname
rename Age age
rename Sex sex
rename AbstrStatus absstatus
rename NRN natregno
rename DxYear cfdxyr
rename Comments comments_2013
replace natregno=subinstr(natregno,"-","",.)
replace fname = lower(rtrim(ltrim(itrim(fname))))
replace lname = lower(rtrim(ltrim(itrim(lname))))
replace absstatus="0" if absstatus=="Pending"
replace absstatus="1" if regexm(absstatus,"Abstracted -")|absstatus=="Abstracted"
replace absstatus="2" if regexm(absstatus,"Ineligible")
replace absstatus="3" if absstatus=="Not Abstracted"
destring absstatus ,replace
label define absstatus_lab 0 "pending" 1 "abstracted" 2 "abstracted-ineligible" 3 "not abstracted" , modify
label values absstatus absstatus_lab
keep cfid_2013 fname lname age sex natregno absstatus comments_2013 cfdxyr
count //4171
save "`datapath'\version02\2-working\2013_cancer_CF" ,replace
restore

preserve
clear
import excel using "`datapath'\version02\1-input\20200220tblCF_2014.xlsx", firstrow
rename cfid cfid_2014
rename abstatus absstatus
rename dxyear cfdxyr
rename comments comments_2014
replace natregno=subinstr(natregno,"-","",.)
replace fname = lower(rtrim(ltrim(itrim(fname))))
replace lname = lower(rtrim(ltrim(itrim(lname))))
replace absstatus="0" if absstatus=="Pending"
replace absstatus="1" if regexm(absstatus,"Abstracted -")|absstatus=="Abstracted"
replace absstatus="2" if regexm(absstatus,"Ineligible")
replace absstatus="3" if absstatus=="Not Abstracted"
destring absstatus ,replace
label define absstatus_lab 0 "pending" 1 "abstracted" 2 "abstracted-ineligible" 3 "not abstracted" , modify
label values absstatus absstatus_lab
keep cfid_2014 fname lname age sex natregno absstatus comments_2014 cfdxyr
count //788
save "`datapath'\version02\2-working\2014_cancer_CF" ,replace
append using "`datapath'\version02\2-working\2008_cancer_CF"
count //5609
append using "`datapath'\version02\2-working\2013_cancer_CF"

replace sex="1" if sex=="Female"
replace sex="2" if sex=="Male"
replace sex="99" if sex=="Not Stated"
destring sex ,replace
label define sex_lab 1 "Female" 2 "Male" 99 "ND" , modify
label values sex sex_lab

count //9780
save "`datapath'\version02\2-working\2008_2013_2014_cancer_CF" ,replace
restore

drop _merge
merge m:m fname lname using "`datapath'\version02\2-working\2008_2013_2014_cancer_CF"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         9,915
        from master                       162  (_merge==1)
        from using                      9,753  (_merge==2)

    matched                                27  (_merge==3)
    -----------------------------------------
*/
count //9942

//list pid record_id cfid_* fname lname absstatus cfdxyr dxyr comments_* if _merge==3 ,string(80)

drop duppt
sort lname fname record_id pid
quietly by lname fname :  gen duppt = cond(_N==1,0,_n)
sort lname fname
count if duppt>0 //7021
sort lname fname pid record_id
//list pid record_id fname lname natregno dotyear dodyear if duppt>0 //only CR5 records

//list pid record_id cfid_* fname lname absstatus cfdxyr dxyr comments_2008 comments_2013 if _merge==3 ,string(25)

replace cr5db=1 if dco_deaths==1 & cr5db==. & _merge==3 //25 changes
replace cr5db=1 if dco_cancer==1 & cr5db==. & _merge==3 //2 changes

drop if cr5db!=1 //9915 deleted
count //27

//capture export_excel pid record_id cfid_2008 cfid_2013 cfid_2014 fname lname absstatus cfdxyr comments_2008 comments_2013 if cr5db==1 using "`datapath'\version02\2-working\CFFoundDCO2015V01.xlsx", sheet("2015DCOs_death&cr5_20200220") firstrow(variables)  replace
//JC remember to change V01 to V02 when running list a 2nd time!

save "`datapath'\version02\2-working\CF_matched_2015DCOs" ,replace
