** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          45_prep cross-check.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      26-MAY-2021
    // 	date last modified      27-MAY-2021
    //  algorithm task          Matching uncleaned, current cancer dataset with cleaned cancer dataset
    //  status                  Completed
    //  objective               To have a uncleaned but prepared dataset with no duplicate sources to merge with cleaned dataset
	//							To check and update any changes to the cleaned data done by DAs post cleaning.
    //  methods                 Using same prep code from 15_clean cancer.do but appending "_2" to variable names

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
    log using "`logpath'\45_prep cross-check.smcl", replace
** HEADER -----------------------------------------------------

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
 (2) import the .xlsx file into Stata using XML backup 2021-05-21_KWG already saved from 2016AnnualReportV02 branch
*/
import excel using "`datapath'\version05\1-input\2021-05-21_MAIN Source+Tumour+Patient_JC_excel.xlsx", firstrow

count //16,022

** Format incidence date to create tumour year
nsplit IncidenceDate, digits(4 2 2) gen(dotyear_2 dotmonth dotday)
gen dot_2=mdy(dotmonth, dotday, dotyear)
format dot_2 %dD_m_CY
gen dotyear2 = year(dot_2)
label var dot_2 "IncidenceDate"
label var dotyear_2 "Incidence year"
drop IncidenceDate

count //16,022

** Renaming CanReg5 variables
rename Personsearch persearch_2
rename PTDataAbstractor ptda_2
rename TTDataAbstractor ttda_2
rename STDataAbstractor stda_2
rename CaseStatus cstatus_2
rename RetrievalSource retsource_2
rename FurtherRetrievalSource fretsource_2
rename NotesSeen notesseen_2
rename BirthDate birthdate_2
rename Sex sex_2
rename MiddleInitials init_2
rename FirstName fname_2
rename LastName lname_2
rename NRN natregno_2
rename ResidentStatus resident_2
rename Comments comments_2
rename PTReviewer ptreviewer_2
rename TTReviewer ttreviewer_2
rename STReviewer streviewer_2
rename MPTot mptot_2
rename MPSeq mpseq_2
rename PatientIDTumourTable patientidtumourtable_2
rename PatientRecordID pid2_2
rename RegistryNumber pid
rename TumourID eid2_2
rename Recordstatus recstatus_2
rename Checkstatus checkstatus_2
rename TumourUpdatedBy tumourupdatedby_2
rename PatientUpdatedBy patientupdatedby_2
rename SourceRecordID sid2_2
rename StatusLastContact slc_2
rename Parish parish_2
rename Address addr_2
rename Age age_2
rename PrimarySite primarysite_2
rename Topography topography_2
rename BasisOfDiagnosis basis_2
rename Histology hx_2
rename Morphology morph_2
rename Laterality lat_2
rename Behaviour beh_2
rename Grade grade_2
rename TNMCatStage tnmcatstage_2
rename TNMAntStage tnmantstage_2
rename EssTNMCatStage esstnmcatstage_2
rename EssTNMAntStage esstnmantstage_2
rename SummaryStaging staging_2
rename Consultant consultant_2
rename HospitalNumber hospnum_2
rename CausesOfDeath cr5cod_2
rename DiagnosisYear dxyr_2
rename Treat*1 rx1_2
rename Treat*2 rx2_2
rename Treat*3 rx3_2
rename Treat*4 rx4_2
rename Treat*5 rx5_2
rename Oth*Treat*1 orx1_2
rename Oth*Treat*2 orx2_2
rename NoTreat*1 norx1_2
rename NoTreat*2 norx2_2
rename NFType nftype_2
rename SourceName sourcename_2
rename Doctor doctor_2
rename DoctorAddress docaddr_2
rename RecordNumber recnum_2
rename CFDiagnosis cfdx_2
rename LabNumber labnum_2
rename Specimen specimen_2
rename ClinicalDetails clindets_2
rename CytologicalFindings cytofinds_2
rename MicroscopicDescription md_2
rename ConsultationReport consrpt_2
rename DurationOfIllness duration_2
rename OnsetDeathInterval onsetint_2
rename Certifier certifier_2
rename TumourIDSourceTable tumouridsourcetable_2
rename SurgicalFindings SurgicalFindings_2
rename SurgicalFindingsDate SurgicalFindingsDate_2
rename ImagingResults ImagingResults_2
rename ImagingResultsDate ImagingResultsDate_2
rename PhysicalExam PhysicalExam_2
rename PhysicalExamDate PhysicalExamDate_2
rename cr5id cr5id_2
rename MultiplePrimary MultiplePrimary_2 
rename ObsoleteFlagTumourTable ObsoleteFlagTumourTable_2
rename PatientRecordIDTumourTable PatientRecordIDTumourTable_2
rename TumourUnduplicationStatus TumourUnduplicationStatus_2
rename DuplicateCheck DuplicateCheck_2
rename ICCCcode ICCCcode_2
rename ICD10 ICD10_2
rename ObsoleteFlagPatientTable ObsoleteFlagPatientTable_2
rename PatientRecordStatus PatientRecordStatus_2
rename PatientCheckStatus PatientCheckStatus_2

/*
Creating and formatting various record IDs auto-generated by CanReg5 which uniquely identify patients (pid), tumours (eid) and sources (sid)
Note: When records are merged in CanReg5, the following can take place:
1) the pid can be kept so in these cases patientrecordid will differentiate between the 2 patient records for the same patient and/or
2) the first 8 digits in tumourid remains the same as the defunct (i.e. no longer used) pid while the new pid will be the pid into which
   that tumour was merged e.g. 20130303 has 2 tumours with different tumourids - 201303030102 and 201407170101.
*/
gen top_2 = topography_2
destring topography_2, replace

gen str_sourcerecordid_2=sid2_2
gen sourcetotal_2 = substr(str_sourcerecordid_2,-1,1)
destring sourcetotal_2, gen (sourcetot_2)

gen str_pid2_2 = pid2_2
gen patienttotal_2 = substr(str_pid2_2,-1,1)
destring patienttotal_2, gen (patienttot_2)
gen str_patientidtumourtable_2=patientidtumourtable_2

gen mpseq2_2=mpseq_2
replace mpseq2_2=1 if mpseq2_2==0
tostring mpseq2_2, replace
gen eid_2 = str_patientidtumourtable_2 + "010" + mpseq2_2

gen sourceseq_2 = substr(str_sourcerecordid_2,13,2)
gen sid_2 = eid_2 + sourceseq_2


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
label var persearch_2 "Person Search"
label define persearch_2_lab 0 "Not done" 1 "Done: OK" 2 "Done: MP" 3 "Done: Duplicate" 4 "Done: Non-IARC MP", modify
label values persearch_2 persearch_2_lab

** Patient record updated by
label var patientupdatedby_2 "PT updated by"

** Date patient record updated
nsplit PatientUpdateDate, digits(4 2 2) gen(year month day)
gen ptupdate_2=mdy(month, day, year)
format ptupdate_2 %dD_m_CY
drop day month year PatientUpdateDate
label var ptupdate_2 "Date PT updated"

** PT Data Abstractor
** contains non-numeric character so need to find and correct
generate byte non_numeric_ptda_2 = indexnot(ptda_2, "0123456789.-")
count if non_numeric_ptda_2 //2
//list pid ptda cr5id if non_numeric_ptda
replace ptda_2="09" if pid=="20145017"
destring ptda_2,replace
count if ptda_2==. //1
//list pid ptda cr5id if ptda==.
replace ptda_2=9 if ptda_2==.
label var ptda_2 "PTDataAbstractor"
label define ptda_2_lab 1 "JC" 2 "RH" 3 "PM" 4 "WB" 5 "LM" 6 "NE" 7 "TD" 8 "TM" 9 "SAF" 10 "PP" 11 "LC" 12 "AJB" ///
					  13 "KWG" 14 "TH" 22 "MC" 88 "Doctor" 98 "Intern" 99 "Unknown", modify
label values ptda_2 ptda_2_lab

** Casefinding Date
replace PTCasefindingDate=20000101 if PTCasefindingDate==99999999
nsplit PTCasefindingDate, digits(4 2 2) gen(year month day)
gen ptdoa_2=mdy(month, day, year)
format ptdoa_2 %dD_m_CY
drop day month year PTCasefindingDate
label var ptdoa_2 "PTCasefindingDate"

** Case Status
label var cstatus_2 "CaseStatus"
label define cstatus_2_lab 0 "CF" 1 "ABS" 2 "Deleted" 3 "Ineligible" 4 "Duplicate" 5 "Pending CD Review", modify
label values cstatus_2 cstatus_2_lab

** Retrieval Source
destring retsource_2, replace
label var retsource_2 "RetrievalSource"
label define retsource_2_lab 1 "QEH Medical Records" 2 "QEH Death Records" 3 "QEH Radiotherapy Dept" 4 "QEH Colposcopy Clinic" ///
						   5 "QEH Haematology Dept" 6 "QEH Private Consulting" 7 "QEH Respiratory Unit" 8 "Bay View" ///
						   9 "Barbados Cancer Society" 10 "Private Physician" 11 "PP-I Lewis" 12 "PP-J Emtage" 13 "PP-B Lynch" ///
						   14 "PP-D Greaves" 15 "PP-S Smith Connell" 16 "PP-R Shenoy" 17 "PP-S Ferdinand" 18 "PP-T Shepherd" ///
						   19 "PP-G S Griffith" 20 "PP-J Nebhnani" 21 "PP-J Ramesh" 22 "PP-J Clarke" 23 "PP-T Laurent" ///
						   24 "PP-S Jackman" 25 "PP-W Crookendale" 26 "PP-C Warner" 27 "PP-H Thani" 28 "Polyclinic" ///
						   29 "Emergency Clinic" 30 "Nursing Home" 31 "None" 32 "Other", modify
label values retsource_2 retsource_2_lab

** Notes Seen
label var notesseen_2 "NotesSeen"
label define notesseen_2_lab 0 "Pending Retrieval" 1 "Yes" 2 "Yes-Pending Further Retrieval" 3 "No" 4 "Cannot retrieve-Year Closed" ///
						   5 "Cannot retrieve-3 attempts" 6 "Cannot retrieve-Permission not granted" 7 "Cannot retrieve-Not found by Clerk", modify
label values notesseen_2 notesseen_2_lab

** Notes Seen Date
replace NotesSeenDate=20000101 if NotesSeenDate==99999999
nsplit NotesSeenDate, digits(4 2 2) gen(year month day)
gen nsdate_2=mdy(month, day, year)
format nsdate_2 %dD_m_CY
drop day month year NotesSeenDate
label var nsdate_2 "NotesSeenDate"

** Further Retrieval Source
destring fretsource_2, replace
label var fretsource_2 "RetrievalSource"
label define fretsource_2_lab 1 "QEH Medical Records" 2 "QEH Death Records" 3 "QEH Radiotherapy Dept" 4 "QEH Colposcopy Clinic" ///
						   5 "QEH Haematology Dept" 6 "QEH Private Consulting" 7 "QEH Respiratory Unit" 8 "Bay View" ///
						   9 "Barbados Cancer Society" 10 "Private Physician" 11 "PP-I Lewis" 12 "PP-J Emtage" 13 "PP-B Lynch" ///
						   14 "PP-D Greaves" 15 "PP-S Smith Connell" 16 "PP-R Shenoy" 17 "PP-S Ferdinand" 18 "PP-T Shepherd" ///
						   19 "PP-G S Griffith" 20 "PP-J Nebhnani" 21 "PP-J Ramesh" 22 "PP-J Clarke" 23 "PP-T Laurent" ///
						   24 "PP-S Jackman" 25 "PP-W Crookendale" 26 "PP-C Warner" 27 "PP-H Thani" 28 "Polyclinic" ///
						   29 "Emergency Clinic" 30 "Nursing Home" 31 "None" 32 "Other", modify
label values fretsource_2 fretsource_2_lab

** First, Middle & Last Names
label var fname_2 "FirstName"
label var init_2 "MiddleInitials"
label var lname_2 "LastName"

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
nsplit birthdate_2, digits(4 2 2) gen(dobyear_2 dobmonth_2 dobday_2)
gen dob_2=mdy(dobmonth_2, dobday_2, dobyear_2)
format dob_2 %dD_m_CY
label var dob_2 "BirthDate"

** Sex
label var sex_2 "Sex"
label define sex_2_lab 1 "Male" 2 "Female" 9 "Unknown", modify
label values sex_2 sex_2_lab

** National Reg. No.
label var natregno_2 "NRN"

** Hospital Number
label var hospnum_2 "HospitalNumber"

** Resident Status
label var resident_2 "ResidentStatus"
label define resident_2_lab 1 "Yes" 2 "No" 9 "Unknown", modify
label values resident_2 resident_2_lab

** Status Last Contact
label var slc_2 "StatusLastContact"
label define slc_2_lab 1 "Alive" 2 "Deceased" 3 "Emigrated" 9 "Unknown", modify
label values slc_2 slc_2_lab

** Date Last Contact
replace DateLastContact=20000101 if DateLastContact==99999999
nsplit DateLastContact, digits(4 2 2) gen(year month day)
gen dlc_2=mdy(month, day, year)
format dlc_2 %dD_m_CY
drop day month year DateLastContact
label var dlc_2 "DateLastContact"

** Comments
label var comments_2 "Comments"

** PT Reviewer
destring ptreviewer_2, replace
label var ptreviewer_2 "PTReviewer"
label define ptreviewer_2_lab 0 "Pending" 1 "JC" 2 "LM" 3 "PP" 4 "AR" 5 "AH" 6 "JK" 7 "TM" 8 "SAW" 9 "SAF" 99 "Unknown", modify
label values ptreviewer_2 ptreviewer_2_lab


**********************************************************
** NAMING & FORMATTING - TUMOUR TABLE
** Note:
** (1)Label as they appear in CR5 record
** (2)Don't clean where possible as
**    corrections to be flagged in 3_cancer_corrections.do
**********************************************************

** Unique TumourID
label var eid_2 "TumourID"

** TT Record Status
label var recstatus_2 "TTRecordStatus"
label define recstatus_2_lab 0 "Pending" 1 "Confirmed" 2 "Deleted" 3 "Ineligible" 4 "Duplicate" , modify
label values recstatus_2 recstatus_2_lab

** TT Check Status
label var checkstatus_2 "TTCheckStatus"
label define checkstatus_2_lab 0 "Not done" 1 "Done: OK" 2 "Done: Rare" 3 "Done: Invalid" , modify
label values checkstatus_2 checkstatus_2_lab

** MP Sequence
label var mpseq_2 "MP Sequence"

** MP Total
label var mptot_2 "MP Total"

** Tumour record updated by
label var tumourupdatedby_2 "TT updated by"

** Date tumour record updated
nsplit UpdateDate, digits(4 2 2) gen(year month day)
gen ttupdate_2=mdy(month, day, year)
format ttupdate_2 %dD_m_CY
drop day month year UpdateDate
label var ttupdate_2 "Date TT updated"

** TT Data Abstractor
destring ttda_2, replace
label var ttda_2 "TTDataAbstractor"
label define ttda_2_lab 1 "JC" 2 "RH" 3 "PM" 4 "WB" 5 "LM" 6 "NE" 7 "TD" 8 "TM" 9 "SAF" 10 "PP" 11 "LC" 12 "AJB" ///
					  13 "KWG" 14 "TH" 22 "MC" 88 "Doctor" 98 "Intern" 99 "Unknown", modify
label values ttda_2 ttda_2_lab

** Abstraction Date
replace TTAbstractionDate=20000101 if TTAbstractionDate==99999999
nsplit TTAbstractionDate, digits(4 2 2) gen(year month day)
gen ttdoa_2=mdy(month, day, year)
format ttdoa_2 %dD_m_CY
drop day month year TTAbstractionDate
label var ttdoa_2 "TTAbstractionDate"

** Parish
destring parish_2, replace
label var parish_2 "Parish"
label define parish_2_lab 1 "Christ Church" 2 "St. Andrew" 3 "St. George" 4 "St. James" 5 "St. John" 6 "St. Joseph" ///
						7 "St. Lucy" 8 "St. Michael" 9 "St. Peter" 10 "St. Philip" 11 "St. Thomas" 99 "Unknown", modify
label values parish_2 parish_2_lab

** Address
label var addr_2 "Address"

**	Age
label var age_2 "Age"

** Primary Site
label var primarysite_2 "PrimarySite"

** Topography
label var topography_2 "Topography"

** Histology
label var hx_2 "Histology"

** Morphology
label var morph_2 "Morphology"

** Laterality
label var lat_2 "Laterality"
label define lat_2_lab 0 "Not a paired site" 1 "Right" 2 "Left" 3 "Only one side, origin unspecified" 4 "Bilateral" ///
					 5 "Midline tumour" 8 "NA" 9 "Unknown", modify
label values lat_2 lat_2_lab

** Behaviour
label var beh_2 "Behaviour"
label define beh_2_lab 0 "Benign" 1 "Uncertain" 2 "In situ" 3 "Malignant", modify
label values beh_2 beh_2_lab

** Grade
label var grade_2 "Grade"
label define grade_2_lab 1 "(well) differentiated" 2 "(mod.) differentiated" 3 "(poor.) differentiated" ///
					   4 "undifferentiated" 5 "T-cell" 6 "B-cell" 7 "Null cell (non-T/B)" 8 "NK cell" ///
					   9 "Undetermined; NA; Not stated", modify
label values grade_2 grade_2_lab

** Basis of Diagnosis
label var basis_2 "BasisOfDiagnosis"
label define basis_2_lab 0 "DCO" 1 "Clinical only" 2 "Clinical Invest./Ult Sound" 3 "Exploratory surg./autopsy" ///
					   4 "Lab test (biochem/immuno.)" 5 "Cytology/Haem" 6 "Hx of mets" 7 "Hx of primary" ///
					   8 "Autopsy w/ Hx" 9 "Unknown", modify
label values basis_2 basis_2_lab

** TNM Categorical Stage
label var tnmcatstage_2 "TNM Cat Stage"

** TNM Anatomical Stage
label var tnmantstage_2 "TNM Ant Stage"

** Essential TNM Categorical Stage
label var esstnmcatstage_2 "Essential TNM Cat Stage"

** Essential TNM Anatomical Stage
label var esstnmantstage_2 "Essential TNM Ant Stage"

** Summary Staging
label var staging_2 "Staging"
label define staging_2_lab 0 "In situ" 1 "Localised only" 2 "Regional: direct ext." 3 "Regional: LNs only" ///
						 4 "Regional: both dir. ext & LNs" 5 "Regional: NOS" 7 "Distant site(s)/LNs" ///
						 8 "NA" 9 "Unknown; DCO case", modify
label values staging_2 staging_2_lab

** Incidence Date
** already formatted above

** Diagnosis Year
label var dxyr_2 "DiagnosisYear"
** Check for blanks as may accidentally drop 2014 cases in 2nd dofile
count if dxyr_2==. //3
list pid dot_2 ttda_2 stda_2 cr5id_2 if dxyr_2==.
replace dxyr_2=2015 if dxyr_2==. //3 changes

** Consultant
label var consultant_2 "Consultant"

** Treatments 1-5
label var rx1_2 "Treatment1"
label define rx_2_lab 0 "No treatment" 1 "Surgery" 2 "Radiotherapy" 3 "Chemotherapy" 4 "Immunotherapy" ///
					5 "Hormonotherapy" 8 "Other relevant therapy" 9 "Unknown" ,modify
label values rx1_2 rx2_2 rx3_2 rx4_2 rx5_2 rx_2_lab

label var rx2_2 "Treatment2"
label var rx3_2 "Treatment3"
label var rx4_2 "Treatment4"
label var rx5_2 "Treatment5"

** Treatments 1-5 Date
replace Treatment1Date=20000101 if Treatment1Date==99999999
nsplit Treatment1Date, digits(4 2 2) gen(rx1year_2 rx1month_2 rx1day_2)
gen rx1d_2=mdy(rx1month_2, rx1day_2, rx1year_2)
format rx1d_2 %dD_m_CY
drop Treatment1Date
label var rx1d_2 "Treatment1Date"

replace Treatment2Date=20000101 if Treatment2Date==99999999
nsplit Treatment2Date, digits(4 2 2) gen(rx2year_2 rx2month_2 rx2day_2)
gen rx2d_2=mdy(rx2month_2, rx2day_2, rx2year_2)
format rx2d_2 %dD_m_CY
drop Treatment2Date
label var rx2d_2 "Treatment2Date"

replace Treatment3Date=20000101 if Treatment3Date==99999999
nsplit Treatment3Date, digits(4 2 2) gen(rx3year_2 rx3month_2 rx3day_2)
gen rx3d_2=mdy(rx3month_2, rx3day_2, rx3year_2)
format rx3d_2 %dD_m_CY
drop Treatment3Date
label var rx3d_2 "Treatment3Date"

replace Treatment4Date=20000101 if Treatment4Date==99999999
nsplit Treatment4Date, digits(4 2 2) gen(rx4year_2 rx4month_2 rx4day_2)
gen rx4d_2=mdy(rx4month_2, rx4day_2, rx4year_2)
format rx4d_2 %dD_m_CY
drop Treatment4Date
label var rx4d_2 "Treatment4Date"

** Treatment 5 has no observations so had to slightly adjust code
replace Treatment5Date=20000101 if Treatment5Date==99999999
if Treatment5Date !=. nsplit Treatment5Date, digits(4 2 2) gen(rx5year_2 rx5month_2 rx5day_2)
if Treatment5Date !=. gen rx5d_2=mdy(rx5month_2, rx5day_2, rx5year_2)
if Treatment5Date !=. format rx5d_2 %dD_m_CY
if Treatment5Date==. rename Treatment5Date rx5d_2
label var rx5d_2 "Treatment5Date"

** Other Treatment 1
label var orx1_2 "OtherTreatment1"
label define orx_2_lab 1 "Cryotherapy" 2 "Laser therapy" 3 "Treated Abroad" ///
					 4 "Palliative therapy" 9 "Unknown" ,modify
label values orx1_2 orx_2_lab

** Other Treatment 2
label var orx2_2 "OtherTreatment2"

** No Treatments 1 and 2
label var norx1_2 "NoTreatment1"
label define norx_2_lab 1 "Alternative rx" 2 "Symptomatic rx" 3 "Died before rx" ///
					  4 "Refused rx" 5 "Postponed rx"  6 "Watchful waiting" ///
					  7 "Defaulted from care" 8 "NA" 9 "Unknown" ,modify
label values norx1_2 norx_2_lab

** No Treatment 2
** contains a nonnumeric character so field needs correcting!
label var norx2_2 "NoTreatment2"

** TT Reviewer
destring ttreviewer_2, replace
label var ttreviewer_2 "TTReviewer"
label define ttreviewer_2_lab 0 "Pending" 1 "JC" 2 "LM" 3 "PP" 4 "AR" 5 "AH" 6 "JK" 7 "TM" 8 "SAW" 9 "SAF" 99 "Unknown", modify
label values ttreviewer_2 ttreviewer_2_lab


**********************************************************
** NAMING & FORMATTING - SOURCE TABLE
** Note:
** (1)Label as they appear in CR5 record
** (2)Don't clean where possible as
**    corrections to be flagged in 3_cancer_corrections.do
**********************************************************

** Unique SourceID
label var sid_2 "SourceRecordID"

** ST Data Abstractor
destring stda_2, replace
** DOES NOT contain a nonnumeric character so no correction needed
label var stda_2 "STDataAbstractor"
label define stda_2_lab 1 "JC" 2 "RH" 3 "PM" 4 "WB" 5 "LM" 6 "NE" 7 "TD" 8 "TM" 9 "SAF" 10 "PP" 11 "LC" 12 "AJB" ///
					  13 "KWG" 14 "TH" 22 "MC" 88 "Doctor" 98 "Intern" 99 "Unknown", modify
label values stda_2 stda_2_lab

** Source Date
replace STSourceDate=20000101 if STSourceDate==99999999
nsplit STSourceDate, digits(4 2 2) gen(year month day)
gen stdoa_2=mdy(month, day, year)
format stdoa_2 %dD_m_CY
drop day month year STSourceDate
label var stdoa_2 "STSourceDate"

** NF Type
destring nftype_2, replace
label var nftype_2 "NFType"
label define nftype_2_lab 1 "Hospital" 2 "Polyclinic/Dist.Hosp." 3 "Lab-Path" 4 "Lab-Cyto" 5 "Lab-Haem" 6 "Imaging" ///
						7 "Private Physician" 8 "Death Certif./Post Mort." 9 "QEH Death Rec Bks" 10 "RT Reg. Bk" ///
						11 "Haem NF" 12 "Bay View Bk" 13 "Other" 14 "Unknown" 15 "NFs", modify
label values nftype_2 nftype_2_lab

** Source Name
label var sourcename_2 "SourceName"
label define sourcename_2_lab 1 "QEH" 2 "Bay View" 3 "Private Physician" 4 "IPS-ARS" 5 "Death Registry" ///
							6 "Polyclinic" 7 "BNR Database" 8 "Other" 9 "Unknown", modify
label values sourcename_2 sourcename_2_lab

** Doctor
label var doctor_2 "Doctor"

** Doctor's Address
label var docaddr_2 "DoctorAddress"

** Record Number
label var recnum_2 "RecordNumber"

** CF Diagnosis
label var cfdx_2 "CFDiagnosis"

** Lab Number
label var labnum_2 "LabNumber"

** Specimen
label var specimen_2 "Specimen"

** Sample Taken Date
replace SampleTakenDate=20000101 if SampleTakenDate==99999999
nsplit SampleTakenDate, digits(4 2 2) gen(stdyear_2 stdmonth_2 stdday_2)
gen sampledate_2=mdy(stdmonth_2, stdday_2, stdyear_2)
format sampledate_2 %dD_m_CY
drop SampleTakenDate
label var sampledate_2 "SampleTakenDate"

** Received Date
replace ReceivedDate=20000101 if ReceivedDate==99999999 | ReceivedDate==.
nsplit ReceivedDate, digits(4 2 2) gen(rdyear_2 rdmonth_2 rdday_2)
gen recvdate_2=mdy(rdmonth_2, rdday_2, rdyear_2)
format recvdate_2 %dD_m_CY
replace recvdate_2=d(01jan2000) if recvdate_2==.
drop ReceivedDate
label var recvdate_2 "ReceivedDate"

** Report Date
replace ReportDate=20000101 if ReportDate==99999999
nsplit ReportDate, digits(4 2 2) gen(rptyear_2 rptmonth_2 rptday_2)
gen rptdate_2=mdy(rptmonth_2, rptday_2, rptyear_2)
format rptdate_2 %dD_m_CY
drop ReportDate
label var rptdate_2 "ReportDate"

** Clinical Details
label var clindets_2 "ClinicalDetails"

** Cytological Findings
label var cytofinds_2 "CytologicalFindings"

** Microscopic Description
label var md_2 "MicroscopicDescription"

** Consultation Report
label var consrpt_2 "ConsultationReport"

** Cause(s) of Death
label var cr5cod_2 "CausesOfDeath"

** Duration of Illness
label var duration_2 "DurationOfIllness"

** Onset to Death Interval
label var onsetint_2 "OnsetDeathInterval"

** Certifier
label var certifier_2 "Certifier"

** Admission Date
replace AdmissionDate=20000101 if AdmissionDate==99999999
nsplit AdmissionDate, digits(4 2 2) gen(admyear_2 admmonth_2 admday_2)
gen admdate_2=mdy(admmonth_2, admday_2, admyear_2)
format admdate_2 %dD_m_CY
drop AdmissionDate
label var admdate_2 "AdmissionDate"

** Date First Consultation
replace DateFirstConsultation=20000101 if DateFirstConsultation==99999999
nsplit DateFirstConsultation, digits(4 2 2) gen(dfcyear_2 dfcmonth_2 dfcday_2)
gen dfc_2=mdy(dfcmonth_2, dfcday_2, dfcyear_2)
format dfc_2 %dD_m_CY
drop DateFirstConsultation
label var dfc_2 "DateFirstConsultation"

** RT Registration Date
replace RTRegDate=20000101 if RTRegDate==99999999
nsplit RTRegDate, digits(4 2 2) gen(rtyear_2 rtmonth_2 rtday_2)
gen rtdate_2=mdy(rtmonth_2, rtday_2, rtyear_2)
format rtdate_2 %dD_m_CY
drop RTRegDate
label var rtdate_2 "RTRegDate"

** ST Reviewer
destring streviewer_2, replace
label var streviewer_2 "STReviewer"
label define streviewer_2_lab 0 "Pending" 1 "JC" 2 "LM" 3 "PP" 4 "AR" 5 "AH" 6 "JK" 7 "TM" 8 "SAW" 9 "SAF" 99 "Unknown", modify
label values streviewer_2 streviewer_2_lab

** CanReg5 ID
label var cr5id_2 "CanReg5 ID"

count //16,022

** Change name format to match death data
replace fname_2=lower(fname_2) //16,022 changes
replace fname_2=lower(rtrim(ltrim(itrim(fname_2)))) //424 changes
replace lname_2=lower(lname_2) //16,022 changes
replace lname_2=lower(rtrim(ltrim(itrim(lname_2)))) //598 changes

** Look for matches
sort lname_2 fname_2 pid
quietly by lname_2 fname_2 : gen dupname_2 = cond(_N==1,0,_n)
sort lname_2 fname_2 pid
count if dupname_2>0 //11,218

order pid fname_2 lname_2 natregno_2
drop if dupname_2>1 //7,052 deleted

count //8,970

save "`datapath'\version02\2-working\2008-2020_cancer_crosschk_dp" ,replace
label data "BNR-Cancer prepared 2008-2020 cross-check data"
notes _dta :These data prepared for 2015 cross-check matching for data updated post-cleaning (2015 annual report)
