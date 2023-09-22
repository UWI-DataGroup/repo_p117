cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          20b_clean current year cancer.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL & Kern ROCKE
    //  date first created      21-SEPT-2023
    // 	date last modified      21-SEPT-2023
    //  algorithm task          Cleaning 2019 cancer dataset
    //  status                  Completed
    //  objective               To have one dataset with cleaned and grouped 2008, 2013-2015 data for PAB 07-Jun-2022.
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
    *local datapath "X:/The University of the West Indies/DataGroup - repo_data/data_p117"
	local datapath "/Volumes/Drive 2/BNR Consultancy/Sync/Sync/DM/Data/BNR-Cancer/data_p117_decrypted" // Kern encrypted local machine
		
	
    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    *local logpath X:/OneDrive - The University of the West Indies/repo_datagroup/repo_p117

    ** Close any open log file and open a new log file
    *capture log close
    *log using "`logpath'/20b_clean current year cancer.smcl", replace
** HEADER -----------------------------------------------------

*************************************************
/*
BLANK & INCONSISTENCY CHECKS - PATIENT TABLE
CHECKS 1 - 46
IDENTIFY, REVIEW & CORRECT ERRORS
Note: Checks not always in sequential order due
	  to previous review format
*/
*************************************************

use "`datapath'/version13/2-working/2019_prepped cancer", clear

ssc install swapval, replace // Adding user written command 

count //2223

/*
	In order for the cancer team to correct the data in CanReg5 database based on the errors and corrections found and performed 
	during this Stata cleaning process, a file with the erroneous and corrected data needs to be created.
	Using the cancer duplicates process for flagging errors and corrections,
	
	(1)	Create flags for errors within found in all the variables
	(2)	Create flags for corrections performed on all the erroneous data by variable
	(3)	Create list with these error and correction flags that is exported to an excel workbook for SDA to correct in CR5db
	
	Note: JC 31may2022 - remove previous flags from '20a_prep current year cancer.do' as that list will be separate from 
		  this one so rather than duplicate work for the SDA, re-create these flags.
*/
drop flag*

forvalues j=1/94 {
	gen flag`j'=""
}

label var flag1 "Error: STDataAbstractor"
label var flag2 "Error: STSourceDate"
label var flag3 "Error: NFType"
label var flag4 "Error: SourceName"
label var flag5 "Error: Doctor"
label var flag6 "Error: DoctorAddress"
label var flag7 "Error: RecordNumber"
label var flag8 "Error: CFDiagnosis"
label var flag9 "Error: LabNumber"
label var flag10 "Error: SurgicalNumber"
label var flag11 "Error: Specimen"
label var flag12 "Error: SampleTakenDate"
label var flag13 "Error: ReceivedDate"
label var flag14 "Error: ReportDate"
label var flag15 "Error: ClinicalDetails"
label var flag16 "Error: CytologicalFindings"
label var flag17 "Error: MicroscopicDescription"
label var flag18 "Error: ConsultationReport"
label var flag19 "Error: SurgicalFindings"
label var flag20 "Error: SurgicalFindingsDate"
label var flag21 "Error: PhysicalExam"
label var flag22 "Error: PhysicalExamDate"
label var flag23 "Error: ImagingResults"
label var flag24 "Error: ImagingResultsDate"
label var flag25 "Error: CausesOfDeath"
label var flag26 "Error: DurationOfIllness"
label var flag27 "Error: OnsetDeathInterval"
label var flag28 "Error: Certifier"
label var flag29 "Error: AdmissionDate"
label var flag30 "Error: DateFirstConsultation"
label var flag31 "Error: RTRegDate"
label var flag32 "Error: Recordstatus"
label var flag33 "Error: TTDataAbstractor"
label var flag34 "Error: TTAbstractionDate"
label var flag35 "Error: DuplicateCheck"
label var flag36 "Error: Parish"
label var flag37 "Error: Address"
label var flag38 "Error: Age"
label var flag39 "Error: PrimarySite"
label var flag40 "Error: Topography"
label var flag41 "Error: Histology"
label var flag42 "Error: Morphology"
label var flag43 "Error: Laterality"
label var flag44 "Error: Behaviour"
label var flag45 "Error: Grade"
label var flag46 "Error: BasisOfDiagnosis"
label var flag47 "Error: TNMCatStage"
label var flag48 "Error: TNMAntStage"
label var flag49 "Error: EssTNMCatStage"
label var flag50 "Error: EssTNMAntStage"
label var flag51 "Error: SummaryStaging"
label var flag52 "Error: IncidenceDate"
label var flag53 "Error: DiagnosisYear"
label var flag54 "Error: Consultant"
label var flag55 "Error: Treatment1"
label var flag56 "Error: Treatment1Date"
label var flag57 "Error: Treatment2"
label var flag58 "Error: Treatment2Date"
label var flag59 "Error: Treatment3"
label var flag60 "Error: Treatment3Date"
label var flag61 "Error: Treatment4"
label var flag62 "Error: Treatment4Date"
label var flag63 "Error: Treatment5"
label var flag64 "Error: Treatment5Date"
label var flag65 "Error: OtherTreatment1"
label var flag66 "Error: OtherTreatment2"
label var flag67 "Error: NoTreatment1"
label var flag68 "Error: NoTreatment2"
label var flag69 "Error: LastName"
label var flag70 "Error: FirstName"
label var flag71 "Error: MiddleInitials"
label var flag72 "Error: BirthDate"
label var flag73 "Error: Sex"
label var flag74 "Error: NRN"
label var flag75 "Error: HospitalNumber"
label var flag76 "Error: ResidentStatus"
label var flag77 "Error: StatusLastContact"
label var flag78 "Error: DateLastContact"
label var flag79 "Error: DateOfDeath"
label var flag80 "Error: Comments"
label var flag81 "Error: PTDataAbstractor"
label var flag82 "Error: PTCasefindingDate"
label var flag83 "Error: RetrievalSource"
label var flag84 "Error: NotesSeen"
label var flag85 "Error: NotesSeenDate"
label var flag86 "Error: FurtherRetrievalSource"
label var flag87 "Error: RFAlcohol"
label var flag88 "Error: AlcoholAmount"
label var flag89 "Error: AlcoholFreq"
label var flag90 "Error: RFSmoking"
label var flag91 "Error: SmokingAmount"
label var flag92 "Error: SmokingFreq"
label var flag93 "Error: SmokingDuration"
label var flag94 "Error: SmokingDurationFreq"

forvalues j=95/189 {
	gen flag`j'=""
}
label var flag95 "Correction: STDataAbstractor"
label var flag96 "Correction: STSourceDate"
label var flag97 "Correction: NFType"
label var flag98 "Correction: SourceName"
label var flag99 "Correction: Doctor" //repeated below in error
label var flag100 "Correction: Doctor"
label var flag101 "Correction: DoctorAddress"
label var flag102 "Correction: RecordNumber"
label var flag103 "Correction: CFDiagnosis"
label var flag104 "Correction: LabNumber"
label var flag105 "Correction: SurgicalNumber"
label var flag106 "Correction: Specimen"
label var flag107 "Correction: SampleTakenDate"
label var flag108 "Correction: ReceivedDate"
label var flag109 "Correction: ReportDate"
label var flag110 "Correction: ClinicalDetails"
label var flag111 "Correction: CytologicalFindings"
label var flag112 "Correction: MicroscopicDescription"
label var flag113 "Correction: ConsultationReport"
label var flag114 "Correction: SurgicalFindings"
label var flag115 "Correction: SurgicalFindingsDate"
label var flag116 "Correction: PhysicalExam"
label var flag117 "Correction: PhysicalExamDate"
label var flag118 "Correction: ImagingResults"
label var flag119 "Correction: ImagingResultsDate"
label var flag120 "Correction: CausesOfDeath"
label var flag121 "Correction: DurationOfIllness"
label var flag122 "Correction: OnsetDeathInterval"
label var flag123 "Correction: Certifier"
label var flag124 "Correction: AdmissionDate"
label var flag125 "Correction: DateFirstConsultation"
label var flag126 "Correction: RTRegDate"
label var flag127 "Correction: Recordstatus"
label var flag128 "Correction: TTDataAbstractor"
label var flag129 "Correction: TTAbstractionDate"
label var flag130 "Correction: DuplicateCheck"
label var flag131 "Correction: Parish"
label var flag132 "Correction: Address"
label var flag133 "Correction: Age"
label var flag134 "Correction: PrimarySite"
label var flag135 "Correction: Topography"
label var flag136 "Correction: Histology"
label var flag137 "Correction: Morphology"
label var flag138 "Correction: Laterality"
label var flag139 "Correction: Behaviour"
label var flag140 "Correction: Grade"
label var flag141 "Correction: BasisOfDiagnosis"
label var flag142 "Correction: TNMCatStage"
label var flag143 "Correction: TNMAntStage"
label var flag144 "Correction: EssTNMCatStage"
label var flag145 "Correction: EssTNMAntStage"
label var flag146 "Correction: SummaryStaging"
label var flag147 "Correction: IncidenceDate"
label var flag148 "Correction: DiagnosisYear"
label var flag149 "Correction: Consultant"
label var flag150 "Correction: Treatment1"
label var flag151 "Correction: Treatment1Date"
label var flag152 "Correction: Treatment2"
label var flag153 "Correction: Treatment2Date"
label var flag154 "Correction: Treatment3"
label var flag155 "Correction: Treatment3Date"
label var flag156 "Correction: Treatment4"
label var flag157 "Correction: Treatment4Date"
label var flag158 "Correction: Treatment5"
label var flag159 "Correction: Treatment5Date"
label var flag160 "Correction: OtherTreatment1"
label var flag161 "Correction: OtherTreatment2"
label var flag162 "Correction: NoTreatment1"
label var flag163 "Correction: NoTreatment2"
label var flag164 "Correction: LastName"
label var flag165 "Correction: FirstName"
label var flag166 "Correction: MiddleInitials"
label var flag167 "Correction: BirthDate"
label var flag168 "Correction: Sex"
label var flag169 "Correction: NRN"
label var flag170 "Correction: HospitalNumber"
label var flag171 "Correction: ResidentStatus"
label var flag172 "Correction: StatusLastContact"
label var flag173 "Correction: DateLastContact"
label var flag174 "Correction: DateOfDeath"
label var flag175 "Correction: Comments"
label var flag176 "Correction: PTDataAbstractor"
label var flag177 "Correction: PTCasefindingDate"
label var flag178 "Correction: RetrievalSource"
label var flag179 "Correction: NotesSeen"
label var flag180 "Correction: NotesSeenDate"
label var flag181 "Correction: FurtherRetrievalSource"
label var flag182 "Correction: RFAlcohol"
label var flag183 "Correction: AlcoholAmount"
label var flag184 "Correction: AlcoholFreq"
label var flag185 "Correction: RFSmoking"
label var flag186 "Correction: SmokingAmount"
label var flag187 "Correction: SmokingFreq"
label var flag188 "Correction: SmokingDuration"
label var flag189 "Correction: SmokingDurationFreq"

********************** 
** Unique PatientID **
**********************
count if pid=="" //0

** Person Search
count if persearch==0 //2214 - person serach not done; can ignore as will check duplicates in this dofile
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
count if ptdoa!=stdoa & ptdoa!=d(01jan2000) & stdoa!=d(01jan2000) //& (tumourtot<2 & sourcetot<2) //1097 - no correction necessary
//list pid eid sid ptdoa stdoa dxyr cr5id if ptdoa!=stdoa & ptdoa!=d(01jan2000) & stdoa!=d(01jan2000) & (tumourtot<2 & sourcetot<2)

** Check 5 - invalid (future date)
** Need to create a variable with current date - to be used when cleaning dates
gen currentd=c(current_date)
gen double currentdatept=date(currentd, "DMY", 2017)
drop currentd
format currentdatept %dD_m_CY
label var currentdate "Current date PT"
count if ptdoa!=. & ptdoa>currentdatept //0

/*
JC 30may2022: Case Status was removed from CR5db since Record Status was expanded this field no longer served any purpose.

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
*/

****************
** Notes Seen **
****************
** Added after these checks were sequentially written
** Additional check for PT variable
** Check 174 - Notes Seen (check for missed 2018 cases that were abstracted in this dofile) 
count if notesseen==0 & dxyr==2018 //25
//list pid cr5id recstatus notesseen sourcename if notesseen==0 & dxyr==2018
** Check main CR5db then correct
destring flag84 ,replace
destring flag179 ,replace
replace flag84=notesseen if notesseen==0 & dxyr==2018
replace notesseen=5 if notesseen==0 & dxyr==2018 & recstatus==1 //2 changes
replace notesseen=3 if notesseen==0 & dxyr==2018 & recstatus==3 //23 changes
replace flag179=notesseen if flag84!=.

** Check 175 - Notes Seen=pending retrieval; dxyr>2013 (for 2018 data collection this check will be revised)
count if notesseen==0 & dxyr>2013 //0
//list pid dxyr cr5id if notesseen==0 & dxyr>2013
** Check main CRdb or add to above code: (regexm(comments, "Notes seen")|comments, "Notes seen"))
//replace notesseen=4 if notesseen==0 & dxyr>2013 //0 changes

** Check 176 - Notes Seen=Yes but NS date=blank; dxyr=2018
count if notesseen==1 & nsdate==. & dxyr==2018 //3 - unnecessary to check each case for data cleaning but will flag in data review code
//list pid comments cr5id if notesseen==1 & nsdate==. & dxyr==2018
//replace nsdate=d(01jan2000) if notesseen==1 & nsdate==. & dxyr==2018 //81 changes
replace flag84=notesseen if notesseen==1 & nsdate==. & dxyr==2018
replace notesseen=3 if notesseen==1 & nsdate==. & dxyr==2018 //3 changes
replace flag179=notesseen if pid=="20182229"
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
count if dob!=. & dob_yr>2018 //0
//list pid age dob dob_yr if dob!=. & dob_yr>2018

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
count if dob!=dobchk & dobchk!=. //16
list pid fname lname age natregno dob dobchk dob_year dot if dob!=dobchk & dobchk!=. //checked against electoral list
drop day month year nrnyr yr yr1 nrn
** Correct dob, where applicable
destring flag72 ,replace
destring flag167 ,replace
replace flag72=dob if dob!=dobchk & dobchk!=. //16 changes
replace dob=dobchk if dob!=dobchk & dobchk!=. //16 changes
replace flag167=dob if flag72!=. //16 changes
//replace natregno=subinstr(natregno,"61","91",.) if pid=="20150294" //2 changes
//replace dob=dobchk if dob!=dobchk & dobchk!=. & pid!="20151250" & pid!="20150521" & pid!="20150294" //6 changes

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
count if sex==. | sex==9 //1
//list pid sex fname primarysite top if sex==.|sex==9
destring flag73 ,replace
destring flag168 ,replace
replace flag73=sex if sex==. | sex==9 //1 change
replace sex=2 if sex==.|sex==9 //1 change
replace flag168=sex if flag73!=. //1 change


** Check 33 - possibly invalid (first name, NRN and sex check: MALES)
gen nrnid=substr(natregno, -4,4)
count if sex==2 & nrnid!="9999" & regex(substr(natregno,-2,1), "[1,3,5,7,9]") //3
//list pid fname lname sex natregno primarysite top cr5id if sex==2 & nrnid!="9999" & regex(substr(natregno,-2,1), "[1,3,5,7,9]")
replace flag73=sex if sex==2 & nrnid!="9999" & regex(substr(natregno,-2,1), "[1,3,5,7,9]") //1 change
replace sex=1 if sex==2 & nrnid!="9999" & regex(substr(natregno,-2,1), "[1,3,5,7,9]") //1 change
replace flag168=sex if pid=="20180248"|pid=="20180611" //3 changes

** Check 34 - possibly invalid (sex=M; site=breast)
tostring top, replace
count if sex==1 & (regexm(cr5cod, "BREAST") | regexm(top, "^50")) //4 - no changes; all correct
//list pid fname lname natregno sex top cr5cod cr5id if sex==1 & (regexm(cr5cod, "BREAST") | regexm(top, "^50"))

** Check 35 - invalid (sex=M; site=FGS)
count if sex==1 & topcat>43 & topcat<52	& (regexm(cr5cod, "VULVA") | regexm(cr5cod, "VAGINA") | regexm(cr5cod, "CERVIX") | regexm(cr5cod, "CERVICAL") ///
								| regexm(cr5cod, "UTER") | regexm(cr5cod, "OVAR") | regexm(cr5cod, "PLACENTA")) //0
//list pid fname lname natregno sex top cr5cod cr5id if sex==1 & topcat>43 & topcat<52 & (regexm(cr5cod, "VULVA") | regexm(cr5cod, "VAGINA") ///
//								| regexm(cr5cod, "CERVIX") | regexm(cr5cod, "CERVICAL") | regexm(cr5cod, "UTER") | regexm(cr5cod, "OVAR") | regexm(cr5cod, "PLACENTA"))
								
** Check 36 - possibly invalid (first name, NRN and sex check: FEMALES)
count if sex==1 & nrnid!="9999" & regex(substr(natregno,-2,1), "[0,2,4,6,8]") //2 - 1 correct; 1 error
//list pid fname lname sex natregno primarysite top cr5id if sex==1 & nrnid!="9999" & regex(substr(natregno,-2,1), "[0,2,4,6,8]")
replace flag73=sex if pid=="20180009" //1 change
replace sex=2 if pid=="20180009" //1 change
replace flag168=sex if pid=="20180009" //1 change

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
count if slc==. & recstatus!=2 & recstatus!=3 & recstatus!=5 //0

//list pid slc recstatus cr5id if slc==. & recstatus!=2 & recstatus!=3 & recstatus!=5
tab slc recstatus,m

** Check 41 - invalid (slc=died;dlc=blank)
count if slc==2 & dlc==. //0
//list pid slc dlc cr5id if slc==2 & dlc==.

** Check 42 - invalid (slc=alive;dlc=blank)
count if slc==1 & dlc==. //0
//list pid slc dlc recstatus cr5id if slc==1 & dlc==.

** Check 43 - invalid (slc=alive;nftype=death info)
count if slc==1 & (nftype==8 | nftype==9) //4
//list pid slc nftype cr5id if slc==1 & (nftype==8 | nftype==9)
destring flag77 ,replace
destring flag172 ,replace
replace flag77=slc if slc==1 & (nftype==8 | nftype==9) //4 changes
replace slc=2 if slc==1 & (nftype==8 | nftype==9) //4 changes
replace flag172=slc if flag77!=.

destring flag79 ,replace
destring flag174 ,replace
replace flag79=dod if flag77!=. //4 changes
replace dod=d(12jul2019) if pid=="20180188"
replace dod=d(01jan2022) if pid=="20180419"
replace dod=d(13feb2019) if pid=="20180493"
replace dod=d(07jan2020) if pid=="20180529"
replace flag174=dod if flag77!=. //4 changes


***********************
** Date Last Contact **
***********************
** Check 44 - missing
count if dlc==. & slc!=9 & recstatus!=2 & recstatus!=3 & recstatus!=5 //0
//list pid recstatus slc dlc cr5id if dlc==. & slc!=9 & recstatus!=2 & recstatus!=3 & recstatus!=5

** Check 45 - invalid (future date)
** Use already created variable called 'currentdatept';
** to be used when cleaning dates
count if dlc!=. & dlc>currentdatept //0

*******************
** Date Of Death **
*******************
** Check 44 - missing
count if dod==. & slc==2 & recstatus!=2 & recstatus!=3 & recstatus!=5 //0
//list pid slc dlc cr5id if dod==. & slc==2

** Check 45 - invalid (future date)
** Use already created variable called 'currentdatept';
** to be used when cleaning dates
count if dod!=. & dod>currentdatept //0

**************
** Comments **
**************
** Check 46 - missing
count if comments=="" //4 - no update needed
//list pid recstatus comments cr5id if comments==""
//replace comments="99" if comments=="" //4 changes


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
count if recstatus==0 & dxyr!=. //1
//list pid dxyr cr5id resident age if recstatus==0 & dxyr!=.
drop if pid=="20180879" //KWG updated dxyr=2017 after this data was exported from CR5db
//replace recstatus=1 if recstatus==0 & dxyr!=. //3 changes

** JC 31may2022: this check no longer applicable as Case Status has been removed from CR5db.
** Check 48 - invalid(cstatus=CF;recstatus<>Pending)
//count if recstatus!=0 & cstatus==0 & ttdoa!=. //6 - no changes needed
//list pid cstatus recstatus dxyr ttdoa pid2 cr5id if recstatus!=0 & cstatus==0 & ttdoa!=.

** Check 49a - possibly invalid (tumour record listed as deleted)
count if recstatus==2 //0

** REVIEW ALL dxyr>2013 CASES FLAGGED AS INELIGIBLE SINCE SOME DISCOVERED IN 2014 AS INELIGIBLE WHICH ARE ELIGIBLE FOR REGISTRATION
** Points to note: (1) reason for ineligibility should be recorded by DA in Comments field; (2) dxyr should be updated with correct year.
count if recstatus==3 //137 - already reviewed
//list pid cr5id dxyr ttda recstatus if recstatus==3

** Check 49b - review all cases flagged as ineligible to check for missed 2013 cases
** JC 30oct18: In later checks I incidentally discovered missed 2013 cases so added in this new check
count if recstatus==3 & cr5id=="T1S1" //108 - already reviewed

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
count if addr=="" & parish!=. & cr5id=="T1S1" //3
//list pid parish addr sourcename recstatus cr5id if addr=="" & parish!=. & cr5id=="T1S1"

replace flag37=addr if addr=="" & parish!=. & cr5id=="T1S1" //3 changes
replace addr="99" if pid=="20180260"|pid=="20180616"
replace flag132=addr if pid=="20180260"|pid=="20180616"
//replace addr="99" if addr=="" & parish!=. & cr5id=="T1S1" //7 changes - all ineligibles
* addr=="" & parish!=. & cstatus!=0 & cr5id=="T1S1" & recstatus==3 //7 changes

preserve
clear
import excel using "`datapath'/version04/2-working/MissingAddr_20220531.xlsx" , firstrow case(lower)
tostring pid, replace
save "`datapath'/version13/2-working/missing_addr" ,replace
restore

*merge 1:1 pid cr5id using "`datapath'/version13/2-working/missing_addr" ,force
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                         2,221
        from master                     2,221  (_merge==1)
        from using                          0  (_merge==2)

    Matched                                 1  (_merge==3)
    -----------------------------------------
*/
*replace addr=meddata_addr if _merge==3 //1 change
*drop meddata_* _merge
*erase "`datapath'/version13/2-working/missing_addr.dta"
*replace flag132=addr if pid=="20182046"

**********	
**	Age **
**********
** Check 58 - missing
count if (age==-1 | age==.) & dot!=. //0
//list pid cr5id if (age==-1 | age==.) & dot!=.
count if age==-1 //2
//list pid cr5id age recstatus if age==-1
destring flag38 ,replace
destring flag133 ,replace
replace flag38=age if age==-1 //2 changes
replace age=999 if age==-1 //2 changes
replace flag133=age if flag38!=. //2 changes

** Check 59 - invalid (age<>incidencedate-dob); checked no errors
** Age (at INCIDENCE - to nearest year)
gen ageyrs = (dot - dob)/365.25 //
gen checkage=int(ageyrs)
drop ageyrs
label var checkage "Age in years at INCIDENCE"
count if dob!=. & dot!=. & age!=checkage //8 - 4 are correct according to CR5 as same day & month for dob & dot
//list pid dot dob dotday dobday dotmonth dobmonth age checkage cr5id if dob!=. & dot!=. & age!=checkage
count if (dobday!=dotday & dobmonth!=dotmonth) & dob!=. & dot!=. & age!=checkage //4
//list pid dotday dobday dotmonth dobmonth if (dobday!=dotday & dobmonth!=dotmonth) & dob!=. & dot!=. & age!=checkage
replace flag38=age if pid=="20180305"|pid=="20181211" //4 changes
replace age=checkage if pid=="20180305"|pid=="20181211" //4 changes
replace flag133=age if pid=="20180305"|pid=="20181211" //4 changes

******************
** Primary Site **
******************
** Check 61 - missing
count if primarysite=="" & topography!=. //0
//list pid primarysite topography recstatus cr5id if primarysite=="" & topography!=.

** Check 63 - invalid(primarysite<>top)
sort topography pid
count if topcheckcat!=. //44
//list pid primarysite topography topcat cr5id if topcheckcat!=.

replace flag39=primarysite if topcheckcat!=. & pid!="20180031" & pid!="20180276" & pid!="20180897" & pid!="20180232" ///
							  & pid!="20190609" & pid!="20180067" & pid!="20180582" //27 changes
replace primarysite="PANCREAS-OVERLAP. HEAD NECK" if pid=="20180861" & regexm(cr5id, "T1")
replace primarysite="PANCREAS-OVERLAP. HEAD NECK BODY" if pid=="20181163" & regexm(cr5id, "T1")
replace primarysite="BONE MARROW" if pid=="20180004" & regexm(cr5id, "T1")
replace primarysite="BONE MARROW" if pid=="20180015" & regexm(cr5id, "T1")
replace primarysite="SKIN-EYELID UPPER" if pid=="20181154" & regexm(cr5id, "T1")
replace primarysite="SKIN-NOS" if pid=="20180934" & regexm(cr5id, "T1")
replace primarysite="BREAST-OVERLAP. UPPER HALF" if pid=="20180237" & regexm(cr5id, "T1")
replace primarysite="BREAST-OVERLAP. UPPER" if pid=="20180458" & regexm(cr5id, "T1")
replace primarysite="BREAST-OVERLAP. INNER" if pid=="20182230" & regexm(cr5id, "T1")
replace primarysite="BREAST-OVERLAP. INNER QUADRANT" if pid=="20182255" & regexm(cr5id, "T1")
replace primarysite="BREAST-OVERLAP. OUTER" if pid=="20182318" & regexm(cr5id, "T1")
replace primarysite="RENAL PELVIS" if pid=="20155215" & regexm(cr5id, "T2")
replace primarysite="RENAL PELVIS" if pid=="20180050" & regexm(cr5id, "T2")
replace primarysite="RENAL PELVIS" if pid=="20182250" & regexm(cr5id, "T1")
replace flag134=primarysite if topcheckcat!=. & pid!="20180031" & pid!="20180276" & pid!="20180897" & pid!="20180232" ///
							  & pid!="20190609" & pid!="20180067" & pid!="20180582" //27 changes

/* 
Below cases are incorrect data that have been cleaned in Stata or MPs that were missed by cancer team at abstraction and should have been abstracted.
JC 25sep2018 corrected below as NS instructed for 2014 data cleaning I will clean data but for the future SDA to clean data:
JC 31may2022: cases flagged below have already been corrected above.
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
** JC 31may2022: cases flagged below have already been corrected above.
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
** JC 31may2022: cases flagged below have already been corrected above.
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
replace morphology="" if morphology=="." //247 changes
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
		 |strmatch(strupper(hx), "*INTRA-EPITHELIAL NEOPLASIA*")) & hx!="CLL" & hx!="PIN" & hx!="HGCGIN /  AIS" //9
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

replace flag41=hx if pid=="20180068" //3 changes
replace hx="CRIBIFORM CARCINOMA WITH MUCINOUS FEATURES" if pid=="20180068" & regexm(cr5id, "T1")
replace hx="MUCINOUS CARCINOMA" if pid=="20180068" & regexm(cr5id, "T2")
replace flag136=hx if pid=="20180068" //3 changes

destring flag42 ,replace
destring flag137 ,replace
replace flag42=morph if pid=="20180068"|pid=="" //3 changes
replace morph=8201 if pid=="20180068" & regexm(cr5id, "T1")
replace morph=8480 if pid=="20180068" & regexm(cr5id, "T2")
replace flag137=morph if pid=="20180068"|pid=="" //3 changes
replace morphcat=6 if pid=="20180068" & regexm(cr5id,"T1")
replace morphcat=9 if pid=="20180068" & regexm(cr5id,"T2")

replace flag80=comments if pid=="20180068"|pid=="20182346" //4 changes
replace comments="JC 31MAY2022: Please verify T1 MORPH with Prof Prussia, as the ICD-O-3 rules state code to higher morph if 2 terms used don't have a single code but since this says '...with mucinous features' I'm unsure if to apply this rule."+" "+comments if pid=="20180068"
replace comments="JC 31MAY2022: Please verify T1 BEHAVIOUR with Prof Prussia, as the path and IHC don't specify malignancy and this type of tumour can be begnin."+" "+comments if pid=="20182346"
replace flag175=comments if pid=="20180068"|pid=="20182346" //4 changes

destring flag32 ,replace
destring flag127 ,replace
replace flag32=recstatus if pid=="20180068" & regexm(cr5id, "T1")|pid=="20182346" & regexm(cr5id, "T1") //3 changes
replace recstatus=6 if pid=="20180068" & regexm(cr5id, "T1")|pid=="20182346" & regexm(cr5id, "T1")
replace flag127=recstatus if pid=="20180068" & regexm(cr5id, "T1")|pid=="20182346" & regexm(cr5id, "T1") //3 changes
	  
** Check 72 - invalid (morph vs basis)
count if morph==8000 & (basis==6|basis==7|basis==8) //6 - all correct
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
count if morphcheckcat==3 //7 - all correct
//list pid hx morphology top basis beh cr5id if morphcheckcat==3
replace flag42=morph if pid=="20180247"
replace morph=8504 if pid=="20180247" & regexm(cr5id, "T1")
replace flag137=morph if pid=="20180247"

replace flag42=morph if pid=="20180447"
replace morph=8265 if pid=="20180447" & regexm(cr5id, "T1")
replace flag137=morph if pid=="20180447"

replace flag80=comments if pid=="20180447"
replace comments="JC 31MAY2022: Please verify T1 MORPH with Prof Prussia, path rpt dx and MD differ slightly and I'm unsure M8265 (see pg60 of ICD-O-3.2 online) is the correct code or if M8500 should be used as 'micropapillary' seems to be a specific coding term so best if Prof confirms."+" "+comments if pid=="20180447"
replace flag175=comments if pid=="20180447"

replace flag32=recstatus if pid=="20180447" & regexm(cr5id, "T1")
replace recstatus=6 if pid=="20180447" & regexm(cr5id, "T1")
replace flag127=recstatus if pid=="20180447" & regexm(cr5id, "T1")

** morphcheckcat 4: Hx=Papillary serous adenoca & Morph!=8460 & Top!=ovary/peritoneum
count if morphcheckcat==4 //0 (thyroid/renal=M8260 & ovary/peritoneum=M8461 & endometrium=M8460)
//list pid top hx morph morphology top basis beh cr5id if morphcheckcat==4
replace flag42=morph if pid=="20180515"
replace morph=8460 if pid=="20180515" & regexm(cr5id, "T1")
replace flag137=morph if pid=="20180515"

** morphcheckcat 5: Hx=Papillary & intraduct/intracyst & Morph!=8503
count if morphcheckcat==5 //2 - all correct
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==5

** morphcheckcat 6: Hx=Keratoacanthoma & Morph!=8070
count if morphcheckcat==6 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==6

** morphcheckcat 7: Hx=Squamous & microinvasive & Morph!=8076
count if morphcheckcat==7 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==7

** morphcheckcat 8: Hx=Bowen excluding clinical & basis==6/7/8 & morph!=8081 (want to check skin SCCs that have bowen disease is coded to M8081) 
count if morphcheckcat==8 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==8

** morphcheckcat 9: Hx=adenoid BCC & morph!=8098
count if morphcheckcat==9 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==9

** morphcheckcat 10: Hx=infiltrating BCC excluding nodular & morph!=8092
count if morphcheckcat==10 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==10

** morphcheckcat 11: Hx=superficial BCC excluding nodular & basis=6/7/8 & morph!=8091
count if morphcheckcat==11 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==11

** morphcheckcat 12: Hx=sclerotic/sclerosing BCC excluding nodular & morph!=8091
count if morphcheckcat==12 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==12

** morphcheckcat 13: Hx=nodular BCC excluding clinical & morph!=8097
count if morphcheckcat==13 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==13

** morphcheckcat 14: Hx!=nodular BCC excluding clinical & morph==8097
count if morphcheckcat==14 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==14

** morphcheckcat 15: Hx=BCC & SCC excluding basaloid & morph!=8094
count if morphcheckcat==15 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==15

** morphcheckcat 16: Hx!=BCC & SCC & morph==8094
count if morphcheckcat==16 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==16

** morphcheckcat 17: Hx!=transitional/urothelial & morph==8120
count if morphcheckcat==17 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==17

** morphcheckcat 18: Hx=transitional/urothelial excluding papillary & morph!=8120
count if morphcheckcat==18 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==18

** morphcheckcat 19: Hx=transitional/urothelial & papillary & morph!=8130
count if morphcheckcat==19 //2 - 1 correct
//list pid primarysite hx morph morphology basis beh  cr5id if morphcheckcat==19
replace flag42=morph if pid=="20181184"
replace morph=8130 if pid=="20181184" & regexm(cr5id, "T1")
replace flag137=morph if pid=="20181184"

** morphcheckcat 20: Hx=villous & adenoma excluding tubulo & morph!=8261
count if morphcheckcat==20 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==20

** morphcheckcat 21: Hx=intestinal excl. stromal (GISTs) & morph!=8144
count if morphcheckcat==21 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==21

** morphcheckcat 22: Hx=villoglandular & morph!=8263
count if morphcheckcat==22 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==22

** morphcheckcat 23: Hx!=clear cell & morph==8310
count if morphcheckcat==23 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==23

** morphcheckcat 24: Hx==clear cell & morph!=8310
count if morphcheckcat==24 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==24

** morphcheckcat 25: Hx==cyst & renal & morph!=8316
count if morphcheckcat==25 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==25

** morphcheckcat 26: Hx==chromophobe & renal & morph!=8317
count if morphcheckcat==26 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==26

** morphcheckcat 27: Hx==sarcomatoid & renal & morph!=8318
count if morphcheckcat==27 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==27

** morphcheckcat 28: Hx==follicular excl.minimally invasive & morph!=8330
count if morphcheckcat==28 //2 - all correct
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==28

** morphcheckcat 29: Hx==follicular & minimally invasive & morph!=8335
count if morphcheckcat==29 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==29

** morphcheckcat 30: Hx==microcarcinoma & morph!=8341
count if morphcheckcat==30 //2
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==30
replace flag42=morph if pid=="20180283"
replace morph=8341 if pid=="20180283" & regexm(cr5id, "T1")
replace flag137=morph if pid=="20180283"

replace flag80=comments if pid=="20180283"
replace comments="JC 31MAY2022: Please verify T1 MORPH with Prof Prussia, 'microcarcinoma' M8341 is a specific term that has higher code than M8340 so best to confirm with Prof."+" "+comments if pid=="20180283"
replace flag175=comments if pid=="20180283"

replace flag32=recstatus if pid=="20180283" & regexm(cr5id, "T1")
replace recstatus=6 if pid=="20180283" & regexm(cr5id, "T1")
replace flag127=recstatus if pid=="20180283" & regexm(cr5id, "T1")

** morphcheckcat 31: Hx!=endometrioid & morph==8380
count if morphcheckcat==31 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==31

** morphcheckcat 32: Hx==poroma & morph!=8409 & mptot<2
count if morphcheckcat==32 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==32

** morphcheckcat 33: Hx==serous excl. papillary & morph!=8441
count if morphcheckcat==33 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==33

** morphcheckcat 34: Hx==mucinous excl. endocervical,producing,secreting,infiltrating duct & morph!=8480
count if morphcheckcat==34 //2
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==34
replace flag42=morph if pid=="20182014"
replace morph=8480 if pid=="20182014" & regexm(cr5id, "T1")
replace flag137=morph if pid=="20182014"
replace morphcat=9 if pid=="20182014" & regexm(cr5id,"T1")

** morphcheckcat 35: Hx!=mucinous/pseudomyxoma peritonei & morph==8480
count if morphcheckcat==35 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==35

** morphcheckcat 36: Hx==acinar & duct & morph!=8552
count if morphcheckcat==36 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==36

** morphcheckcat 37: Hx==intraduct & micropapillary or intraduct & clinging & morph!=8507
count if morphcheckcat==37 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==37

** morphcheckcat 38: Hx!=intraduct & micropapillary or intraduct & clinging & morph==8507
count if morphcheckcat==38 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==38

** morphcheckcat 39: Hx!=ductular & morph==8521
count if morphcheckcat==39 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==39

** morphcheckcat 40: Hx!=duct & Hx==lobular & morph!=8520
count if morphcheckcat==40 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==40

** morphcheckcat 41: Hx==duct & lobular & morph!=8522
count if morphcheckcat==41 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==41

** morphcheckcat 42: Hx!=acinar & morph==8550
count if morphcheckcat==42 //1
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==42
replace flag42=morph if pid=="20182177"
replace morph=8500 if pid=="20182177" & regexm(cr5id, "T1")
replace flag137=morph if pid=="20182177"
replace morphcat=10 if pid=="20182177" & regexm(cr5id,"T1")

** morphcheckcat 43: Hx!=adenosquamous & morph==8560
count if morphcheckcat==43 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==43

** morphcheckcat 44: Hx!=thecoma & morph==8600
count if morphcheckcat==44 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==44

** morphcheckcat 45: Hx!=sarcoma & morph==8800
count if morphcheckcat==45 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==45

** morphcheckcat 46: Hx=spindle & sarcoma & morph!=8801
count if morphcheckcat==46 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==46

** morphcheckcat 47: Hx=undifferentiated & sarcoma & morph!=8805
count if morphcheckcat==47 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==47

** morphcheckcat 48: Hx=fibrosarcoma & Hx!=myxo/dermato/mesothelioma & morph!=8810
count if morphcheckcat==48 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==48

** morphcheckcat 49: Hx=fibrosarcoma & Hx=myxo & morph!=8811
count if morphcheckcat==49 //2
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==49
replace flag42=morph if pid=="20180344"
replace morph=8811 if pid=="20180344" & regexm(cr5id, "T1")
replace flag137=morph if pid=="20180344"
replace morphcat=18 if pid=="20180344" & regexm(cr5id,"T1")

** morphcheckcat 50: Hx=fibro & histiocytoma & morph!=8830 (see morphcheckcat=92 also!)
count if morphcheckcat==50 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==50

** morphcheckcat 51: Hx!=dermatofibrosarcoma & morph==8832
count if morphcheckcat==51 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==51

** morphcheckcat 52: Hx==stromal sarcoma high grade & morph!=8930
count if morphcheckcat==52 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==52

** morphcheckcat 53: Hx==stromal sarcoma low grade & morph!=8931
count if morphcheckcat==53 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==53

** morphcheckcat 54: Hx==gastrointestinal stromal tumour & morph!=8936
count if morphcheckcat==54 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==54

** morphcheckcat 55: Hx==mixed mullerian tumour & Hx!=mesodermal & morph!=8950
count if morphcheckcat==55 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==55

** morphcheckcat 56: Hx==mesodermal mixed & morph!=8951
count if morphcheckcat==56 //0 20mar18; 0 04jul18
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==56

** morphcheckcat 57: Hx==wilms or nephro & morph!=8960
count if morphcheckcat==57 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==57

** morphcheckcat 58: Hx==mesothelioma & Hx!=fibrous or sarcoma or epithelioid/papillary or cystic & morph!=9050
count if morphcheckcat==58 //2
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==58
replace flag39=primarysite if pid=="20180469"
replace primarysite="UNKNOWN" if pid=="20180469" & regexm(cr5id, "T1")
replace flag134=primarysite if pid=="20180469"

destring flag40 ,replace
destring flag135 ,replace
replace flag40=topography if pid=="20180469"
replace topography=809 if pid=="20180469" & regexm(cr5id, "T1")
replace flag135=topography if pid=="20180469"
replace topcat=70 if pid=="20180469" & regexm(cr5id,"T1")

replace flag42=morph if pid=="20180469"
replace morph=9050 if pid=="20180469" & regexm(cr5id, "T1")
replace flag137=morph if pid=="20180469"

replace flag80=comments if pid=="20180469"
replace comments="JC 31MAY2022: Please verify T1 TOPOGRAPHY with Prof Prussia + NS, the path rpt indicates mass in lung/pleura was metastatic - maybe using too much interpretation/inference here instead of performing surveillance."+" "+comments if pid=="20180469"
replace flag175=comments if pid=="20180469"

replace flag32=recstatus if pid=="20180469" & regexm(cr5id, "T1")
replace recstatus=6 if pid=="20180469" & regexm(cr5id, "T1")
replace flag127=recstatus if pid=="20180469" & regexm(cr5id, "T1")
			  
** morphcheckcat 59: Hx==fibrous or sarcomatoid mesothelioma & Hx!=epithelioid/papillary or cystic & morph!=9051
count if morphcheckcat==59 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==59

** morphcheckcat 60: Hx==epitheliaoid or papillary mesothelioma & Hx!=fibrous or sarcomatoid or cystic & morph!=9052
count if morphcheckcat==60 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==60

** morphcheckcat 61: Hx==biphasic mesothelioma & morph!=9053
count if morphcheckcat==61 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==61

** morphcheckcat 62: Hx==adenomatoid tumour & morph!=9054
count if morphcheckcat==62 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==62

** morphcheckcat 63: Hx==cystic mesothelioma & morph!=9055
count if morphcheckcat==63 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==63

** morphcheckcat 64: Hx==yolk & morph!=9071
count if morphcheckcat==64 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==64

** morphcheckcat 65: Hx==teratoma & morph!=9080
count if morphcheckcat==65 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==65

** morphcheckcat 66: Hx==teratoma & Hx!=metastatic or malignant or embryonal or teratoblastoma or immature & morph==9080
count if morphcheckcat==66 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==66

** morphcheckcat 67: Hx==complete hydatidiform mole & Hx!=choriocarcinoma & beh==3 & morph==9100
count if morphcheckcat==67 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==67

** morphcheckcat 68: Hx==choriocarcinoma & morph!=9100
count if morphcheckcat==68 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==68

** morphcheckcat 69: Hx==epithelioid hemangioendothelioma & Hx!=malignant & morph==9133
count if morphcheckcat==69 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==69

** morphcheckcat 70: Hx==osteosarcoma & morph!=9180
count if morphcheckcat==70 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==70

** morphcheckcat 71: Hx==chondrosarcoma & morph!=9220
count if morphcheckcat==71 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==71

** morphcheckcat 72: Hx=myxoid and Hx!=chondrosarcoma & morph==9231
count if morphcheckcat==72 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==72

** morphcheckcat 73: Hx=retinoblastoma and poorly or undifferentiated & morph==9511
count if morphcheckcat==73 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==73

** morphcheckcat 74: Hx=meningioma & Hx!=meningothelial/endotheliomatous/syncytial & morph==9531
count if morphcheckcat==74 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==74

** morphcheckcat 75: Hx=mantle cell lymphoma & morph!=9673
count if morphcheckcat==75 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==75

** morphcheckcat 76: Hx=T-cell lymphoma & Hx!=leukemia & morph!=9702
count if morphcheckcat==76 //1
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==76
replace flag41=hx if pid=="20180932" //3 changes
replace hx="ADULT T-CELL LYMPHOMA LEUKEMIA" if pid=="20180932" & regexm(cr5id, "T1")
replace flag136=hx if pid=="20180932" //3 changes

** morphcheckcat 77: Hx=non-hodgkin lymphoma & Hx!=cell (to excl. mantle, large, cleaved, small, etc) & morph!=9591
count if morphcheckcat==77 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==77

** morphcheckcat 78: Hx=precursor t-cell acute lymphoblastic leukemia & morph!=9837
** note: ICD-O-3 has another matching code (M9729) but WHO Classification notes that M9837 more accurate
count if morphcheckcat==78 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==78

** morphcheckcat 79: Hx=CML (chronic myeloid/myelogenous leukemia) & Hx!=genetic studies & morph==9863
** note: HemeDb under CML, NOS notes 'Presumably myelogenous leukemia without genetic studies done would be coded to M9863.'
count if morphcheckcat==79 //2
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==79
replace flag42=morph if pid=="20180006"
replace morph=9863 if pid=="20180006" & regexm(cr5id, "T1")
replace flag137=morph if pid=="20180006"

** morphcheckcat 80: Hx=CML (chronic myeloid/myelogenous leukemia) & Hx!=BCR/ABL1 & morph==9875
** note: HemeDb under CML, NOS notes 'Presumably myelogenous leukemia without genetic studies done would be coded to M9863.'
count if morphcheckcat==80 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==80

** morphcheckcat 81: Hx=acute myeloid leukemia & Hx!=myelodysplastic/down syndrome & basis==cyto/heme/histology... & morph!=9861
count if morphcheckcat==81 //3 - all correct
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==81

** morphcheckcat 82: Hx=acute myeloid leukemia & down syndrome & morph!=9898
count if morphcheckcat==82 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==82

** morphcheckcat 83: Hx=secondary myelofibrosis & recstatus!=3 & morph==9931 or 9961
count if morphcheckcat==83 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==83

** morphcheckcat 84: Hx=polycythemia & Hx!=vera/proliferative/primary & morph==9950
count if morphcheckcat==84 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==84

** morphcheckcat 85: Hx=myeloproliferative & Hx!=essential & dxyr<2010 & morph==9975
count if morphcheckcat==85 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==85

** morphcheckcat 86: Hx=myeloproliferative & Hx!=essential & dxyr>2009 & morph==9960
count if morphcheckcat==86 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==86

** morphcheckcat 87: Hx=refractory anemia & Hx!=sideroblast or blast & morph!=9980
count if morphcheckcat==87 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==87

** morphcheckcat 88: Hx=refractory anemia & sideroblast & Hx!=excess blasts & morph!=9982
count if morphcheckcat==88 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==88

** morphcheckcat 89: Hx=refractory anemia & excess blasts &  Hx!=sidero & morph!=9983
count if morphcheckcat==89 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==89

** morphcheckcat 90: Hx=myelodysplasia & Hx!=syndrome & recstatus!=inelig. & morph==9989
count if morphcheckcat==90 //0
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==90

** morphcheckcat 91: Hx=acinar & top!=619 & morph!=8550
count if morphcheckcat==91 //35 - on 22oct18 JC added in top!=619 to this code so now count=0
//list pid primarysite hx morph morphology cr5id if morphcheckcat==91

** morphcheckcat 92: Hx!=fibro & histiocytoma & morph=8830 (see morphcheckcat=50 also!)
count if morphcheckcat==92 //1
//list pid primarysite hx morph morphology basis beh cr5id if morphcheckcat==92

** morphcheckcat 93: Hx=acinar & top=619 & morph!=8140
/*
This check added on 22oct18 after update re morphcheckcat 91 above.  
*/
count if morphcheckcat==93 //1
//list pid primarysite hx morph morphology cr5id if morphcheckcat==93
replace morph=8140 if morphcheckcat==93 //1 change

** morphcheckcat 94: Hx=hodgkin & morph=non-hodgkin
count if morphcheckcat==94 //3 - corrected in Check 76 subcheck 1 below
//list pid hx morph morphology cr5id if morphcheckcat==94

** morphcheckcat 95: Hx=leukaemia & morph=9729
count if morphcheckcat==95 //0
//list pid hx morph morphology cr5id if morphcheckcat==95

** morphcheckcat 96: Hx=lymphoma & morph=9837
count if morphcheckcat==96 //0
//list pid hx morph morphology cr5id if morphcheckcat==96

** Check 76 - invalid(primarysite vs hx)
** hxcheckcat 1: PrimSite=Blood/Bone Marrow & Hx=Lymphoma 
count if hxcheckcat==1 //3
//list pid top hx morph morphology cr5id if hxcheckcat==1
replace flag39=primarysite if pid=="20180019"
replace primarysite="LYMPH NODE-NECK" if pid=="20180019" & regexm(cr5id, "T1")
replace flag134=primarysite if pid=="20180019"

replace flag40=topography if pid=="20180019"
replace topography=770 if pid=="20180019" & regexm(cr5id, "T1")
replace flag135=topography if pid=="20180019"
replace topcat=69 if pid=="20180019" & regexm(cr5id,"T1")

** hxcheckcat 2: PrimSite=Thymus & MorphCat!=13 (Thymic epithe. neo.) & Hx!=carcinoma
count if hxcheckcat==2 //0
//list pid primarysite top hx morph morphology cr5id if hxcheckcat==2

** hxcheckcat 3: PrimSite!=Bone Marrow & MorphCat==56 (Myelodysplastic Syn.)
count if hxcheckcat==3 //0
//list pid primarysite top hx morph morphology cr5id if hxcheckcat==3

** hxcheckcat 4: PrimSite!=thyroid & Hx=Renal & Hx=Papillary ca & Morph!=8260
count if hxcheckcat==4 //0
//list pid primarysite hx morph morphology cr5id if hxcheckcat==4

** hxcheckcat 5: PrimSite==thyroid & Hx!=Renal & Hx=Papillary ca & adenoca & Morph!=8260
count if hxcheckcat==5 //0
//list pid primarysite hx morph morphology cr5id if hxcheckcat==5

** hxcheckcat 6: PrimSite==ovary or peritoneum & Hx=Papillary & Serous & Morph!=8461
count if hxcheckcat==6 //0
//list pid hx morph morphology cr5id if hxcheckcat==6

** hxcheckcat 7: PrimSite==endometrium & Hx=Papillary & Serous & Morph!=8460
count if hxcheckcat==7 //2 - corrected in morphcheckcat==4
//list pid primarysite hx morph morphology cr5id if hxcheckcat==7

** hxcheckcat 8: PrimSite!=bone; Hx=plasmacytoma & Morph==9731(bone)
count if hxcheckcat==8 //0
//list pid primarysite hx morph morphology cr5id if hxcheckcat==8

** hxcheckcat 9: PrimSite==bone; Hx=plasmacytoma & Morph==9734(not bone)
count if hxcheckcat==9 //0
//list pid primarysite hx morph morphology cr5id if hxcheckcat==9

** hxcheckcat 10: PrimSite!=meninges; Hx=meningioma
count if hxcheckcat==10 //0
//list pid primarysite top hx morph morphology cr5id if hxcheckcat==10

** hxcheckcat 11: PrimSite=Blood/Bone Marrow & Hx=HTLV+T-cell Lymphoma 
count if hxcheckcat==11 //3
//list pid top hx morph morphology cr5id if hxcheckcat==11
replace flag39=primarysite if pid=="20180028"|pid=="20180932"
replace primarysite="LYMPH NODE-NOS" if pid=="20180028" & regexm(cr5id, "T1")|pid=="20180932" & regexm(cr5id, "T1")
replace flag134=primarysite if pid=="20180028"|pid=="20180932"

replace flag40=topography if pid=="20180028"|pid=="20180932"
replace topography=779 if pid=="20180028" & regexm(cr5id, "T1")|pid=="20180932" & regexm(cr5id, "T1")
replace flag135=topography if pid=="20180028"|pid=="20180932"
replace topcat=69 if pid=="20180028" & regexm(cr5id,"T1")|pid=="20180932" & regexm(cr5id, "T1")

** Check 78 - invalid(age/site/histology)
** agecheckcat 1: Age<3 & Hx=Hodgkin Lymphoma
count if agecheckcat==1 //0
//list pid cr5id age hx morph morphology dxyr if agecheckcat==1

** agecheckcat 2: Age 10-14 & Hx=Neuroblastoma
count if agecheckcat==2 //0
//list pid cr5id age hx morph morphology dxyr if agecheckcat==2

** agecheckcat 3: Age 6-14 & Hx=Retinoblastoma
count if agecheckcat==3 //0
//list pid cr5id age hx morph morphology dxyr if agecheckcat==3

** agecheckcat 4: Age 9-14 & Hx=Wilm's Tumour
count if agecheckcat==4 //0
//list pid cr5id age hx morph morphology dxyr if agecheckcat==4

** agecheckcat 5: Age 0-8 & Hx=Renal carcinoma
count if agecheckcat==5 //0
//list pid cr5id age hx morph morphology dxyr if agecheckcat==5

** agecheckcat 6: Age 6-14 & Hx=Hepatoblastoma
count if agecheckcat==6 //0
//list pid cr5id age hx morph morphology dxyr if agecheckcat==6

** agecheckcat 7: Age 0-8 & Hx=Hepatic carcinoma
count if agecheckcat==7 //0
//list pid cr5id age hx morph morphology dxyr if agecheckcat==7

** agecheckcat 8: Age 0-5 & Hx=Osteosarcoma
count if agecheckcat==8 //0
//list pid cr5id age hx morph morphology dxyr if agecheckcat==8

** agecheckcat 9: Age 0-5 & Hx=Chondrosarcoma
count if agecheckcat==9 //0
//list pid cr5id age hx morph morphology dxyr if agecheckcat==9

** agecheckcat 10: Age 0-3 & Hx=Ewing sarcoma
count if agecheckcat==10 //0
//list pid cr5id age hx morph morphology dxyr if agecheckcat==10

** agecheckcat 11: Age 8-14 & Hx=Non-gonadal germ cell
count if agecheckcat==11 //0
//list pid cr5id age hx morph morphology dxyr if agecheckcat==11

** agecheckcat 12: Age 0-4 & Hx=Gonadal carcinoma
count if agecheckcat==12 //0
//list pid cr5id age hx morph morphology dxyr if agecheckcat==12

** agecheckcat 13: Age 0-5 & Hx=Thyroid carcinoma
count if agecheckcat==13 //0
//list pid cr5id age hx morph morphology dxyr if agecheckcat==13

** agecheckcat 14: Age 0-5 & Hx=Nasopharyngeal carcinoma
count if agecheckcat==14 //0
//list pid cr5id age hx morph morphology dxyr if agecheckcat==14

** agecheckcat 15: Age 0-4 & Hx=Skin carcinoma
count if agecheckcat==15 //0
//list pid cr5id age hx morph morphology dxyr if agecheckcat==15

** agecheckcat 16: Age 0-4 & Hx=Carcinoma, NOS
count if agecheckcat==16 //0
//list pid cr5id age hx morph morphology dxyr if agecheckcat==16

** agecheckcat 17: Age 0-14 & Hx=Mesothelial neoplasms
count if agecheckcat==17 //0
//list pid cr5id age hx morph morphology dxyr if agecheckcat==17

** agecheckcat 18: Age <40 & Hx=814_ & Top=61_
count if agecheckcat==18 //0
//list pid cr5id age hx morph morphology dxyr if agecheckcat==18

** agecheckcat 19: Age <20 & Top=15._,19._,20._,21._,23._,24._,38.4,50._53._,54._,55._
count if agecheckcat==19 //0
//list pid cr5id age primarysite top hx morph morphology dxyr if agecheckcat==19

** agecheckcat 20: Age <20 & Top=17._ & Morph<9590(ie.not lymphoma)
count if agecheckcat==20 //0
//list pid cr5id age hx morph morphology dxyr if agecheckcat==20

** agecheckcat 21: Age <20 & Top=33._ or 34._ or 18._ & Morph!=824_(ie.not carcinoid)
count if agecheckcat==21 //0
//list pid cr5id age hx morph morphology dxyr if agecheckcat==21

** agecheckcat 22: Age >45 & Top=58._ & Morph==9100(chorioca.)
count if agecheckcat==22 //0
//list pid cr5id age hx morph morphology dxyr if agecheckcat==22

** agecheckcat 23: Age <26 & Morph==9732(myeloma) or 9823(BCLL)
count if agecheckcat==23 //0
//list pid cr5id age hx morph morphology dxyr if agecheckcat==23

** agecheckcat 24: Age >15 & Morph==8910/8960/8970/8981/8991/9072/9470/9490/9500/951_/9687
count if agecheckcat==24 //0
//list pid cr5id age hx morph morphology dxyr if agecheckcat==24

** agecheckcat 25: Age <15 & Morph==9724
count if agecheckcat==25 //0
//list pid cr5id age hx morph morphology dxyr if agecheckcat==25


** Check 80 - invalid(sex/histology)
** sexcheckcat 1: Sex=male & Hx family=23,24,25,26,27
count if sexcheckcat==1 //0
//list pid cr5id age hx morph morphology hxfamcat dxyr if sexcheckcat==1

** sexcheckcat 2: Sex=female & Hx family=28 or 29
count if sexcheckcat==2 //0
//list pid cr5id age hx morph morphology hxfamcat dxyr if sexcheckcat==2


** Check 82 - invalid(site/histology)
** sitecheckcat 1: NOT haem. tumours
count if sitecheckcat==1 //0
//list pid cr5id age hx morph morphology dxyr if sitecheckcat==1

** sitecheckcat 2: NOT site-specific carcinomas
count if sitecheckcat==2 //0
//list pid cr5id age hx morph morphology dxyr if sitecheckcat==2

** sitecheckcat 3: NOT site-specific sarcomas
count if sitecheckcat==3 //0
//list pid cr5id age hx morph morphology dxyr if sitecheckcat==3

** sitecheckcat 4: Top=Bone; Hx=Giant cell sarc. except bone
count if sitecheckcat==4 //0
//list pid cr5id age hx morph morphology dxyr if sitecheckcat==4

** sitecheckcat 5: NOT sarcomas affecting CNS
count if sitecheckcat==5 //0
//list pid cr5id age hx morph morphology dxyr if sitecheckcat==5

** sitecheckcat 6: NOT sites for Kaposi sarcoma
count if sitecheckcat==6 //0
//list pid cr5id age hx morph morphology dxyr if sitecheckcat==6

** sitecheckcat 7: Top=Bone; Hx=extramedullary plasmacytoma
count if sitecheckcat==7 //0
//list pid cr5id age hx morph morphology dxyr if sitecheckcat==7


****************
** Laterality **
****************
** Check 83 - Laterality missing
count if lat==. & primarysite!="" //0
//list pid lat primarysite cr5id if lat==. & primarysite!=""
count if latcat==. & lat!=. //0 - some latcats may change due to corrections in clean dofile being run after prep dofile
//list pid lat primarysite cr5id if latcat==. & lat!=.
count if lat==8 //25 - lat should=0(not paired site) if latcat=0 or blank
//list pid lat primarysite latcat cr5id if lat==8
count if lat==8 & (latcat==0|latcat==.) //25
//list pid lat top latcat cr5id if lat==8 & (latcat==0|latcat==.)

destring flag43 ,replace
destring flag138 ,replace
replace flag43=lat if lat==8 & (latcat==0|latcat==.) //25 changes
replace lat=0 if lat==8 & (latcat==0|latcat==.)
replace flag138=lat if flag43!=. //25 changes

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
count if latcheckcat==1 //1 - this is not an error as 'left' is incorrect on COD but correct in other source records
//list pid cr5id primarysite lat cr5cod dxyr if latcheckcat==1

** latcheckcat 2: COD='right'; COD=cancer (codcat!=1); latcat>0; lat!=right
count if latcheckcat==2 //0
//list pid cr5id primarysite lat cr5cod dxyr if latcheckcat==2

** latcheckcat 3: CFdx='left'; latcat>0; lat!=left
count if latcheckcat==3 //8 - 7 correct
//list pid cr5id primarysite lat cfdx dxyr if latcheckcat==3 ,string(100)
replace flag43=lat if pid=="20182193" & regexm(cr5id, "T1")
replace lat=2 if pid=="20182193" & regexm(cr5id, "T1")
replace flag138=lat if pid=="20182193" & regexm(cr5id, "T1")

replace flag39=primarysite if pid=="20182253" & regexm(cr5id, "T1")
replace primarysite="LUNG-LOWER LOBE" if pid=="20182253" & regexm(cr5id, "T1")
replace flag134=primarysite if pid=="20182253" & regexm(cr5id, "T1")

replace flag40=topography if pid=="20182253" & regexm(cr5id, "T1")
replace topography=343 if pid=="20182253" & regexm(cr5id, "T1")
replace flag135=topography if pid=="20182253" & regexm(cr5id, "T1")

replace flag43=lat if pid=="20182253" & regexm(cr5id, "T1")
replace lat=2 if pid=="20182253" & regexm(cr5id, "T1")
replace flag138=lat if pid=="20182253" & regexm(cr5id, "T1")

** JC 31may2022: missed MP 20182253 (lat=4 does not apply if diffuse lung tumours were not present at time of dx)
expand=2 if pid=="20182253" & cr5id=="T1S1", gen (dupobs1)
replace cr5id="T2S1" if dupobs1==1

replace flag39=primarysite if pid=="20182253" & regexm(cr5id, "T2")
replace primarysite="LUNG-UPPER LOBE" if pid=="20182253" & regexm(cr5id, "T2")
replace flag134=primarysite if pid=="20182253" & regexm(cr5id, "T2")

replace flag40=topography if pid=="20182253" & regexm(cr5id, "T2")
replace topography=341 if pid=="20182253" & regexm(cr5id, "T2")
replace flag135=topography if pid=="20182253" & regexm(cr5id, "T2")

replace flag43=lat if pid=="20182253" & regexm(cr5id, "T2")
replace lat=1 if pid=="20182253" & regexm(cr5id, "T2")
replace flag138=lat if pid=="20182253" & regexm(cr5id, "T2")

destring flag45 ,replace
destring flag140 ,replace
replace flag45=grade if pid=="20182253" & regexm(cr5id, "T2")
replace grade=9 if pid=="20182253" & regexm(cr5id, "T2")
replace flag140=grade if pid=="20182253" & regexm(cr5id, "T2")

destring flag52 ,replace
destring flag147 ,replace
format flag52 flag147 %dD_m_CY
replace flag52=dot if pid=="20182253" & regexm(cr5id, "T2")
replace dot=d(05dec2018) if pid=="20182253" & regexm(cr5id, "T2")
replace flag147=dot if pid=="20182253" & regexm(cr5id, "T2")

replace flag80=comments if pid=="20182253" & cr5id=="T2S1"
replace comments="JC 31MAY2022: missed Lung MP, right - please abstract (Note: laterality=4 does not apply if diffuse lung tumours were not present at time of dx."+" "+comments if pid=="20182253" & cr5id=="T2S1"
replace flag175=comments if pid=="20182253" & cr5id=="T2S1"

** latcheckcat 4: CFdx='right'; latcat>0; lat!=right
count if latcheckcat==4 //5 - all correct
//list pid cr5id primarysite lat cfdx dxyr if latcheckcat==4 ,string(100)

** latcheckcat 5: topog==809 & lat!=0-paired site (in accord with SEER Prog. Coding manual 2016 pg 82 #1.a.)
count if latcheckcat==5 //38
//list pid cr5id primarysite topography lat dxyr if latcheckcat==5
count if lat!=0 & topography==809 //40
//list pid cr5id primarysite topography lat dxyr if lat!=0 & topography==809
replace flag39=primarysite if pid=="20181081" & regexm(cr5id, "T1")
replace primarysite="SKIN-NOS" if pid=="20181081" & regexm(cr5id, "T1")
replace flag134=primarysite if pid=="20181081" & regexm(cr5id, "T1")

replace flag40=topography if pid=="20181081" & regexm(cr5id, "T1")
replace topography=449 if pid=="20181081" & regexm(cr5id, "T1")
replace flag135=topography if pid=="20181081" & regexm(cr5id, "T1")
replace topcat=39 if pid=="20181081" & regexm(cr5id,"T1")

replace flag43=lat if pid=="20181081" & regexm(cr5id, "T1")
replace lat=0 if pid=="20181081" & regexm(cr5id, "T1")|latcheckcat==5|lat!=0 & topography==809 //40 changes
replace flag138=lat if pid=="20181081" & regexm(cr5id, "T1")

** latcheckcat 6: latcat>0 & lat==0 or 8 (in accord with SEER Prog. Coding manual 2016 pg 82 #2)
count if latcheckcat==6 //8
//list pid cr5id topography lat latcat dxyr if latcheckcat==6
replace flag43=lat if pid=="20140849" & regexm(cr5id, "T3")|pid=="20180031" & regexm(cr5id, "T1")|pid=="20180634" & regexm(cr5id, "T1")|pid=="20181211" & regexm(cr5id, "T1")|pid=="20182138" & regexm(cr5id, "T1")
replace lat=2 if pid=="20181211" & regexm(cr5id, "T1")
replace lat=5 if pid=="20140849" & regexm(cr5id, "T3")|pid=="20180031" & regexm(cr5id, "T1")|pid=="20180634" & regexm(cr5id, "T1")
replace lat=9 if pid=="20182138" & regexm(cr5id, "T1")
replace flag138=lat if pid=="20140849" & regexm(cr5id, "T3")|pid=="20180031" & regexm(cr5id, "T1")|pid=="20180634" & regexm(cr5id, "T1")|pid=="20181211" & regexm(cr5id, "T1")|pid=="20182138" & regexm(cr5id, "T1")

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
count if latcheckcat==12 //13
//list pid cr5id topography lat latcat dxyr if latcheckcat==12
replace flag43=lat if latcheckcat==12
replace lat=0 if latcheckcat==12 //13 changes
replace flag138=lat if latcheckcat==12

** latcheckcat 13: lat=N/A & dxyr>2013 (cases dx>2013 should use code '0-not paired site')
count if latcheckcat==13 //25 - all corrected above
//list pid cr5id topography lat latcat if latcheckcat==13
count if lat==8 & dxyr>2013 //0 - flagged and corrected in below latcheckcat 14
//list pid cr5id topography lat latcat if lat==8 & dxyr>2013

** latcheckcat 14: lat=N/A & latcat!=0
count if latcheckcat==14 //0
//list pid cr5id topography lat latcat if latcheckcat==14

** latcheckcat 15: lat=unk for a paired site
count if latcheckcat==15 //41
//list pid cr5id topography lat latcat cfdx if latcheckcat==15, string(50)
replace latcat=0 if pid=="20180469" & regexm(cr5id, "T1")

replace flag41=hx if pid=="20180639" //3 changes
replace hx="POORLY DIFFERENTIATED MAMMARY CARCINOMA, LOBULAR SUBTYPE" if pid=="20180639" & regexm(cr5id, "T1")
replace flag136=hx if pid=="20180639" //3 changes

replace flag42=morph if pid=="20180639"
replace morph=8522 if pid=="20180639" & regexm(cr5id, "T1")
replace flag137=morph if pid=="20180639"

replace flag43=lat if pid=="20180639"
replace lat=1 if pid=="20180639" & regexm(cr5id, "T1")
replace flag138=lat if pid=="20180639"

replace flag39=primarysite if pid=="20180920" & regexm(cr5id, "T1")
replace primarysite="UNKNOWN" if pid=="20180920" & regexm(cr5id, "T1")
replace flag134=primarysite if pid=="20180920" & regexm(cr5id, "T1")

replace flag40=topography if pid=="20180920" & regexm(cr5id, "T1")
replace topography=809 if pid=="20180920" & regexm(cr5id, "T1")
replace flag135=topography if pid=="20180920" & regexm(cr5id, "T1")
replace topcat=70 if pid=="20180920" & regexm(cr5id,"T1")

replace flag43=lat if pid=="20180920" & regexm(cr5id, "T1")
replace lat=0 if pid=="20180920" & regexm(cr5id, "T1")
replace flag138=lat if pid=="20180920" & regexm(cr5id, "T1")
replace latcat=0 if pid=="20180920" & regexm(cr5id,"T1")

destring flag46 ,replace
destring flag141 ,replace
replace flag46=basis if pid=="20181079"|pid=="20181161"|pid=="20182303"
replace basis=6 if pid=="20181079" & regexm(cr5id, "T1")|pid=="20181161" & regexm(cr5id, "T1")|pid=="20182303" & regexm(cr5id, "T1")
replace flag141=basis if pid=="20181079"|pid=="20181161"|pid=="20182303"

** latcheckcat 16: lat=9 & top=ovary
count if latcheckcat==16 //20
//list pid cr5id topography lat latcat cfdx if latcheckcat==16, string(100)
replace flag46=basis if pid=="20180350"|pid==""|pid==""
replace basis=6 if pid=="20180350" & regexm(cr5id, "T1")|pid=="" & regexm(cr5id, "T1")|pid=="" & regexm(cr5id, "T1")
replace flag141=basis if pid=="20180350"|pid==""|pid==""

replace flag43=lat if pid=="20180405" & regexm(cr5id, "T1")
replace lat=1 if pid=="20180405" & regexm(cr5id, "T1")
replace flag138=lat if pid=="20180405" & regexm(cr5id, "T1")

replace flag39=primarysite if pid=="20180493" & regexm(cr5id, "T1")
replace primarysite="ENDOMETRIUM" if pid=="20180493" & regexm(cr5id, "T1")
replace flag134=primarysite if pid=="20180493" & regexm(cr5id, "T1")

replace flag40=topography if pid=="20180493" & regexm(cr5id, "T1")
replace topography=541 if pid=="20180493" & regexm(cr5id, "T1")
replace flag135=topography if pid=="20180493" & regexm(cr5id, "T1")
replace topcat=47 if pid=="20180493" & regexm(cr5id,"T1")

replace flag41=hx if pid=="20180493" //3 changes
replace hx="SEROUS PAPILLARY CARCINOMA" if pid=="20180493" & regexm(cr5id, "T1")
replace flag136=hx if pid=="20180493" //3 changes

replace flag42=morph if pid=="20180493"
replace morph=8460 if pid=="20180493" & regexm(cr5id, "T1")
replace flag137=morph if pid=="20180493"
replace morphcat=9 if pid=="20180493" & regexm(cr5id,"T1")

replace flag43=lat if pid=="20180493" & regexm(cr5id, "T1")
replace lat=0 if pid=="20180493" & regexm(cr5id, "T1")
replace flag138=lat if pid=="20180493" & regexm(cr5id, "T1")
replace latcat=0 if pid=="20180493" & regexm(cr5id,"T1")


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
//list pid hx morph morphology basis beh cr5id if behcheckcat==5

** behcheckcat 2: Beh!=2 & Morph==8077
count if behcheckcat==2 //0
//list pid primarysite hx morph morphology basis beh cr5id if behcheckcat==2

** behcheckcat 3: Hx=Squamous & microinvasive & Beh=2 & Morph!=8076
count if behcheckcat==3 //0
//list pid primarysite hx morph morphology basis beh cr5id if behcheckcat==3

** behcheckcat 4: Hx=Bowen & Beh!=2 (want to check skin SCCs that have bowen disease is coded to beh=in-situ)
count if behcheckcat==4 //0
//list pid primarysite hx morph morphology basis beh cr5id if behcheckcat==4

** behcheckcat 5: PrimSite==appendix & Morph==8240 & Beh!=1
count if behcheckcat==5 //0
//list pid primarysite hx morph morphology basis beh cr5id if behcheckcat==5

** behcheckcat 6: Hx=adenoma excl. adenocarcinoma & invasion & Morph==8263 & Beh!=2
count if behcheckcat==6 //0
//list pid hx morph morphology beh cr5id if behcheckcat==6

** behcheckcat 7: Morph not listed in ICD-O-3 (IARCcrgTools Check pg 8)
count if behcheckcat==7 //0
//list pid hx morph morphology beh cr5id if behcheckcat==7

** behcheckcat 8: Hx=tumour & beh>1
count if behcheckcat==8 //0
//list pid hx morph morphology beh recstatus cr5id if behcheckcat==8

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
//list pid grade beh morph morphology cr5id if gradecheckcat==1

** gradecheckcat 2: Grade>=5 & <=8 & Hx<9590 & DxYr>2013
count if gradecheckcat==2 //0
//list pid grade beh morph morphology cr5id if gradecheckcat==2

** gradecheckcat 3: Grade>=1 & <=4 & Hx>=9590 & DxYr>2013
count if gradecheckcat==3 //0
//list pid hx morph grade beh morph morphology cr5id if gradecheckcat==3 ,string(100)

** gradecheckcat 4: Grade!=5 & Hx=9702-9709,9716-9726(!=9719),9729,9827,9834,9837 & DxYr>2013
count if gradecheckcat==4 //0
//list pid grade beh morph morphology cr5id if gradecheckcat==4

** gradecheckcat 5: Grade!=5 or 7 & Hx=9714 & DxYr>2013
count if gradecheckcat==5 //0
//list pid grade beh morph morphology cr5id if gradecheckcat==5

** gradecheckcat 6: Grade!=5 or 8 & Hx=9700/9701/9719/9831 & DxYr>2013
count if gradecheckcat==6 //0
//list pid grade beh morph morphology cr5id if gradecheckcat==6

** gradecheckcat 7: Grade!=6 & Hx=>=9670,<=9699,9712,9728,9737,9738,>=9811,<=9818,9823,9826,9833,9836 & DxYr>2013
count if gradecheckcat==7 //0
//list pid hx grade beh morph morphology cr5id if gradecheckcat==7 ,string(100)

** gradecheckcat 8: Grade!=8 & Hx=9948 & DxYr>2013
count if gradecheckcat==8 //0
//list pid grade beh morph morphology cr5id if gradecheckcat==8

** gradecheckcat 9: Grade!=1 & Hx=8331/8851/9187/9511 & DxYr>2013
count if gradecheckcat==9 //0
//list pid grade beh morph morphology cr5id if gradecheckcat==9

** gradecheckcat 10: Grade!=2 & Hx=8249/8332/8858/9083/9243/9372 & DxYr>2013
count if gradecheckcat==10 //0
//list pid grade beh morph morphology cr5id if gradecheckcat==10

** gradecheckcat 11: Grade!=3 & HX=8631/8634 & DxYr>2013
count if gradecheckcat==11 //0
//list pid grade beh morph morphology cr5id if gradecheckcat==11

** gradecheckcat 12: Grade!=4 & Hx=8020/8021/8805/9062/9082/9392/9401/9451/9505/9512 & DxYr>2013
count if gradecheckcat==12 //0
//list pid grade beh morph morphology cr5id if gradecheckcat==12

** gradecheckcat 13: Grade=9 & cfdx/md/consrpt=Gleason & DxYr>2013
count if gradecheckcat==13 //0
** list pid grade cfdx md consrpt cr5id if gradecheckcat==13
//list pid grade cr5id if gradecheckcat==13

** gradecheckcat 14: Grade=9 & cfdx/md/consrpt=Nottingham/Bloom & DxYr>2013
count if gradecheckcat==14 //2 - all correct
//list pid grade cfdx md consrpt cr5id if gradecheckcat==14

** gradecheckcat 15: Grade=9 & cfdx/md/consrpt=Fuhrman & DxYr>2013
count if gradecheckcat==15 //0
//list pid grade cfdx md consrpt cr5id if gradecheckcat==15

** gradecheckcat 16: Grade!=6 & Hx=9732 & DxYr>2013 (see MM in HemeDb for grade)
count if gradecheckcat==16 //73
//list pid grade beh morph morphology cr5id if gradecheckcat==16
replace flag45=grade if gradecheckcat==16
replace grade=6 if gradecheckcat==16
replace flag140=grade if gradecheckcat==16 //73 changes

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
count if bascheckcat==1 //6
//list pid cr5id hx basis dxyr if bascheckcat==1
replace flag46=basis if pid=="20181076"
replace basis=2 if pid=="20181076" & regexm(cr5id, "T1")
replace flag141=basis if pid=="20181076"

replace flag41=hx if pid=="20181177" //3 changes
replace hx="MALIGNANT EPITHELIAL NEOPLASM" if pid=="20181177" & regexm(cr5id, "T1")
replace flag136=hx if pid=="20181177" //3 changes

replace flag42=morph if pid=="20181177"
replace morph=8010 if pid=="20181177" & regexm(cr5id, "T1")
replace flag137=morph if pid=="20181177"
replace morphcat=2 if pid=="20181177" & regexm(cr5id,"T1")

** bascheckcat 2: hx=...OMA & basis!=6/7/8
count if bascheckcat==2 //0
//list pid cr5id hx basis dxyr if bascheckcat==2

** bascheckcat 3: Basis not missing & basis!=cyto/heme/histology... & Hx!=...see BOD/Hx Control pg 47,48 of IARCcrgTools Check Program
count if bascheckcat==3 //0
//list pid primarysite hx morph morphology basis cr5id if bascheckcat==3

** bascheckcat 4: Hx=mass; Basis=DCO; Morph==8000 - If topog=CNS then terms such as neoplasm & tumour eligible criteria (see Eligibility SOP)
count if bascheckcat==4 //0
//list pid cr5id primarysite hx morph morphology basis dxyr if bascheckcat==4

** bascheckcat 5: Basis=DCO; Comments='Notes seen'
count if bascheckcat==5 //11 - all correct
//list pid basis dxyr cr5id comments if bascheckcat==5 ,string(100)
** Check in main CR5 db to see if true DCO then dot=dlc or if to correct basis,dot,dxyr (e.g. if notes seen by DA etc.)

** bascheckcat 6: Basis!=lab test; Comments=PSA; top=prostate
count if bascheckcat==6 //3 - 2 correct
//list pid basis dxyr cr5id comment if bascheckcat==6 ,string(100)
replace flag52=dot if pid=="20170324" & regexm(cr5id, "T1")
replace dot=d(11sep2017) if pid=="20170324" & regexm(cr5id, "T1")
replace flag147=dot if pid=="20170324" & regexm(cr5id, "T1")

destring flag53 ,replace
destring flag148 ,replace
replace flag53=dxyr if pid=="20170324"
replace dxyr=2017 if pid=="20170324" & regexm(cr5id, "T1")
replace flag148=dxyr if pid=="20170324"

replace flag46=basis if pid=="20170324"
replace basis=7 if pid=="20170324" & regexm(cr5id, "T1")
replace flag141=basis if pid=="20170324"

replace flag80=comments if pid=="20170324" & regexm(cr5id, "T1")
replace comments="JC 01JUN2022: conclusive/confirmatory term 'suspicious for' used in 2017 bx (see eligibility criteria SOP) so please update InciDate, dxyr and BOD."+" "+comments if pid=="20170324" & regexm(cr5id, "T1")
replace flag175=comments if pid=="20170324" & regexm(cr5id, "T1")

** bascheckcat 7: Basis=unk; Comments=Notes seen
count if bascheckcat==7 //1 - correct
//list pid basis dxyr cr5id comment if bascheckcat==7 ,string(100)

** bascheckcat 8: Basis!=hx of prim; top=haem; nftype=BM
count if bascheckcat==8 //2
//list pid basis dxyr cr5id comment if bascheckcat==8 ,string(100)
replace flag46=basis if pid=="20180019"|pid=="20180219"
replace basis=7 if pid=="20180019" & regexm(cr5id, "T1")|pid=="20180219" & regexm(cr5id, "T1")
replace flag141=basis if pid=="20180019"|pid=="20180219"

** bascheckcat 9: Basis!=haem/hx of prim; top=haem; Comments=blood
count if bascheckcat==9 //6 - 2 correct
//list pid basis dxyr cr5id comment if bascheckcat==9 ,string(100)
replace flag46=basis if pid=="20180021"
replace basis=7 if pid=="20180021" & regexm(cr5id, "T1")
replace flag141=basis if pid=="20180021"

*************
** Staging **
*************
** NOTE 1: Staging only done at 5 year intervals so staging done on 2013 data then 2018 and so on;
** NOTE 2: In upcoming years of data collection (2018 dc year), more stagecheckcat checks will be compiled based on site in SEER Summary Staging manual.

** Check 99 - For 2014 data, replace blank and non-blank stage with code 'NA'
count if staging==. & dot!=. & dxyr!=2013 & dxyr!=2018 //0
//list pid cr5id recstatus dxyr if staging==. & dot!=. & dxyr!=2013
replace staging=8 if staging==. & dot!=. & dxyr!=2013 & dxyr!=2018 //0 changes
count if staging!=8 & dot!=. & dxyr>2013 & dxyr!=2018 //1 - leave as is since was previously staged as 2018 but then on review dxyr=2017
//list pid cr5id staging recstatus dxyr if staging!=8 & dot!=. & dxyr>2013 & dxyr!=2018
//replace staging=8 if staging!=8 & dot!=. & dxyr>2013 & dxyr!=2018 // changes

** stagecheckcat 1: basis!=0(DCO) or 9(unk) & staging=9(DCO)
count if stagecheckcat==1 //115
order pid basis
//list pid cr5id dxyr topography basis *stage staging if stagecheckcat==1
destring flag51 ,replace
destring flag146 ,replace
replace flag51=staging if stagecheckcat==1 //JC 01jun2022: ask SF if need to add dictionary option for unstageable due to lack of info? 
//replace staging= if stagecheckcat==1
//replace flag146=staging if stagecheckcat==1

** stagecheckcat 2: beh!=2(in-situ) & staging=0(in-situ)
count if stagecheckcat==2 //0

** stagecheckcat 3: topog=778(overlap LNs) & staging=1(local.)
count if stagecheckcat==3 //0

** stagecheckcat 4: staging!=8(NA) & dxyr!=2013 & dxyr!=2018
count if stagecheckcat==4 //0
//list pid cr5id dxyr topography basis *stag* if stagecheckcat==4

** stagecheckcat 5: staging!=9(NK) & topog=809 & dxyr=2013
count if stagecheckcat==5 //0

** stagecheckcat 6: basis=0(DCO)/9(unk) & staging!=9(DCO) & dxyr=2013
count if stagecheckcat==6 //0

** stagecheckcat 7: beh==2(in-situ) & staging!=0(in-situ) & dxyr=2013
count if stagecheckcat==7 //0

** stagecheckcat 8: staging=8(NA) & dxyr=2013
count if stagecheckcat==8 //0

** stagecheckcat 9: TNM, Essential TNM and Summary Staging are all missing & dxyr=2018
count if stagecheckcat==9 //0

** stagecheckcat 10: Summary Staging!=8(NA) & Site!=Prostate/Breast/Colorectal & dxyr=2018
count if stagecheckcat==10 //0

** stagecheckcat 11: TNM, Essential TNM and Summary Staging are all missing for prostate, breast, colorectal & dxyr=2018
count if stagecheckcat==11 //39
//list pid cr5id dxyr topography basis *stage staging if stagecheckcat==11, string(30)
count if stagecheckcat==11 & topcat!=43 //13 - breast not staged, only colorectal + prostate as confirmed by SF 01JUN2022 on WhatsApp
//list pid cr5id dxyr topography basis *stage staging if stagecheckcat==11 & topcat!=43, string(30)
replace flag51=staging if pid=="20180602"|pid=="20180643"|pid=="20180697"|pid=="20180827"|pid=="20180914"|pid=="20181020"|pid=="20181181"|pid=="20181187"|pid=="20181196"|pid=="20182181"
replace staging=1 if pid=="20180643" & regexm(cr5id, "T1")|pid=="20181181" & regexm(cr5id, "T1")|pid=="20182181" & regexm(cr5id, "T1")
replace staging=7 if pid=="20180602" & regexm(cr5id, "T1")
replace staging=9 if pid=="20180697" & regexm(cr5id, "T1")|pid=="20180827" & regexm(cr5id, "T1")|pid=="20180914" & regexm(cr5id, "T1")|pid=="20181020" & regexm(cr5id, "T1")|pid=="20181187" & regexm(cr5id, "T1")|pid=="20181196" & regexm(cr5id, "T1")
replace flag146=staging if pid=="20180602"|pid=="20180643"|pid=="20180697"|pid=="20180827"|pid=="20180914"|pid=="20181020"|pid=="20181181"|pid=="20181187"|pid=="20181196"|pid=="20182181"

replace flag46=basis if pid=="20180602"
replace basis=5 if pid=="20180602" & regexm(cr5id, "T1")
replace flag141=basis if pid=="20180602"

replace flag47=tnmcatstage if pid=="20182181"
replace tnmcatstage="pT2N0Mx" if pid=="20182181" & regexm(cr5id, "T1")
replace flag142=tnmcatstage if pid=="20182181"

destring flag48 ,replace
destring flag143 ,replace
replace flag48=tnmantstage if pid=="20182181"
replace tnmantstage=1 if pid=="20182181" & regexm(cr5id, "T1")
replace flag143=tnmantstage if pid=="20182181"

replace flag49=etnmcatstage if pid=="20180602"|pid=="20180643"|pid=="20182181"|pid=="20181181"
replace etnmcatstage="TXR-M+" if pid=="20180602" & regexm(cr5id, "T1")
replace etnmcatstage="TXR-M-" if pid=="20180643" & regexm(cr5id, "T1")|pid=="20181181" & regexm(cr5id, "T1")
replace etnmcatstage="L2R-M-" if pid=="20182181" & regexm(cr5id, "T1")
replace flag144=etnmcatstage if pid=="20180602"|pid=="20180643"|pid=="20182181"|pid=="20181181"

destring flag50 ,replace
destring flag145 ,replace
replace flag50=etnmantstage if pid=="20180602"|pid=="20180643"|pid=="20182181"|pid=="20181181"
replace etnmantstage=1 if pid=="20180643" & regexm(cr5id, "T1")|pid=="20182181" & regexm(cr5id, "T1")|pid=="20181181" & regexm(cr5id, "T1")
replace etnmantstage=4 if pid=="20180602" & regexm(cr5id, "T1")
replace flag145=etnmantstage if pid=="20180602"|pid=="20180643"|pid=="20182181"|pid=="20181181"

** stagecheckcat 12: TNM, Essential TNM and Summary Staging are NOT missing for non-prostate/breast/colorectal & dxyr=2018
count if stagecheckcat==12 //0

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
count if dotcheckcat==4 //83 - all correct
//list pid dot dfc admdate rtdate sampledate recvdate rptdate dlc dod cr5id if dotcheckcat==4

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
count if dotcheckcat==8 //5
//list pid cr5id dot dfc admdate rtdate sampledate recvdate rptdate dlc dod ttda dxyr if dotcheckcat==8
destring flag12 ,replace
destring flag107 ,replace
destring flag13 ,replace
destring flag108 ,replace
destring flag14 ,replace
destring flag109 ,replace
format flag12 flag13 flag14 flag107 flag108 flag109 %dD_m_CY
replace flag12=sampledate if pid=="20180175" & cr5id=="T1S1"|pid=="20182043" & cr5id=="T1S1"|pid=="20182246" & cr5id=="T1S1"
replace flag13=recvdate if pid=="20180175" & cr5id=="T1S1"|pid=="20180470" & cr5id=="T1S1"|pid=="20182043" & cr5id=="T1S1"|pid=="20182246" & cr5id=="T1S1"
replace flag14=rptdate if pid=="20180175" & cr5id=="T1S1"|pid=="20181219" & cr5id=="T1S1"
*swapval recvdate rptdate if pid=="20180175" & cr5id=="T1S1"
*swapval sampledate recvdate if pid=="20180175" & cr5id=="T1S1"|pid=="20182043" & cr5id=="T1S1"|pid=="20182246" & cr5id=="T1S1"
replace recvdate=rptdate if pid=="20180470" & cr5id=="T1S1"
replace rptdate=d(02jan2019) if pid=="20181219" & cr5id=="T1S1"
replace flag107=sampledate if pid=="20180175" & cr5id=="T1S1"|pid=="20182043" & cr5id=="T1S1"|pid=="20182246" & cr5id=="T1S1"
replace flag108=recvdate if pid=="20180175" & cr5id=="T1S1"|pid=="20180470" & cr5id=="T1S1"|pid=="20182043" & cr5id=="T1S1"|pid=="20182246" & cr5id=="T1S1"
replace flag109=rptdate if pid=="20180175" & cr5id=="T1S1"|pid=="20181219" & cr5id=="T1S1"

replace flag52=dot if pid=="20180175" & regexm(cr5id, "T1")|pid=="20182043" & regexm(cr5id, "T1")|pid=="20182246" & regexm(cr5id, "T1")
replace dot=sampledate if pid=="20180175" & cr5id=="T1S1"|pid=="20182043" & cr5id=="T1S1"|pid=="20182246" & cr5id=="T1S1"
replace dot=. if pid=="20180175" & regexm(cr5id, "T1") & cr5id!="T1S1"|pid=="20182043" & regexm(cr5id, "T1") & cr5id!="T1S1"|pid=="20182246" & regexm(cr5id, "T1") & cr5id!="T1S1"
fillmissing dot if pid=="20180175" & regexm(cr5id, "T1")
fillmissing dot if pid=="20182043" & regexm(cr5id, "T1")
fillmissing dot if pid=="20182246" & regexm(cr5id, "T1")
replace flag147=dot if pid=="20180175" & regexm(cr5id, "T1")|pid=="20182043" & regexm(cr5id, "T1")|pid=="20182246" & regexm(cr5id, "T1")

** dotcheckcat 9: InciDate=ReceiveDate; ReceiveDate after DFC/AdmDate/RTdate/SampleDate/RptDate (2014 onwards)
count if dotcheckcat==9 //0
//list pid cr5id dot dfc admdate rtdate sampledate recvdate rptdate ttda dxyr if dotcheckcat==9

** dotcheckcat 10: InciDate=RptDate; RptDate after DFC/AdmDate/RTdate/SampleDate/ReceiveDate (2014 onwards)
count if dotcheckcat==10 //2 - leave 20155071 as is since not confirmed
//list pid cr5id dot dfc admdate rtdate sampledate recvdate rptdate ttda dxyr if dotcheckcat==10
replace flag52=dot if pid=="20180160" & regexm(cr5id, "T1")|pid=="20180490" & regexm(cr5id, "T1")
replace dot=recvdate if pid=="20180160" & cr5id=="T1S3"
replace dot=sampledate if pid=="20180490" & cr5id=="T1S2"
replace dot=. if pid=="20180160" & regexm(cr5id, "T1") & cr5id!="T1S3"|pid=="20180490" & regexm(cr5id, "T1") & cr5id!="T1S2"
fillmissing dot if pid=="20180160" & regexm(cr5id, "T1")
fillmissing dot if pid=="20180490" & regexm(cr5id, "T1")
replace flag147=dot if pid=="20180160" & regexm(cr5id, "T1")|pid=="20180490" & regexm(cr5id, "T1")


********************
** Diagnosis Year **
********************
** Check 107 - DxYr missing
count if dxyr==. //0
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
count if dxyrcheckcat==1 //0
//list pid cr5id dot dotyear dxyr ttda if dxyrcheckcat==1

** dxyrcheckcat 2: admyear!=dxyr & dxyr>2013
count if dxyrcheckcat==2 //49 - all correct
//list pid cr5id admdate admyear dxyr ttda if dxyrcheckcat==2

** dxyrcheckcat 3: dfcyear!=dxyr & dxyr>2013
count if dxyrcheckcat==3 //0
//list pid cr5id dfc dfcyear dxyr ttda if dxyrcheckcat==3

** dxyrcheckcat 4: rtyear!=dxyr & dxyr>2013
count if dxyrcheckcat==4 //88 - all correct
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
** NOTE 3: JC 01JUN2022 due to problems in retrieving notes from QEH death records, treatment was only partially collected for 2018.

** Check 111 - For 2014 data, replace blank and non-blank treatment with code 'ND'
count if rx1==. & dxyr==2018 //1126
count if rx1==. & dxyr==2018 & recstatus!=3 & recstatus!=4 //882
//list pid recstatus cr5id if rx1==. & dxyr==2018
//list pid recstatus cr5id if rx1==. & dxyr==2018 & recstatus!=3 & recstatus!=4
//replace rx1=9 if rx1==. & dxyr==2018 //1,658 changes
count if (rx1!=. & rx1!=9) & dxyr==2018 //1095
//list pid rx1 dxyr cr5id if (rx1!=. & rx1!=9) & dxyr==2018
//replace rx1=9 if (rx1!=. & rx1!=9) & dxyr==2018 //814 changes

count if rx2!=. & dxyr==2018 //365
//list pid rx2 cr5id if rx2!=. & dxyr==2018
//replace rx2=. if rx2!=. & dxyr==2018 //249 changes

count if rx3!=. //7
count if rx4!=. //0
count if rx5!=. //0

*************************
** Treatments 1-5 Date **
*************************
** Missing dates already captured in checkflags in Rx1-5

** Check 115 - For 2014 data, replace non-blank treatment dates with missing value
count if rx1d!=. & dxyr==2018 //796
//replace rx1d=. if rx1d!=. & dxyr==2018 //796 changes

count if rx2d!=. & dxyr==2018 //246
//list pid rx2d cr5id if rx2d!=. & dxyr==2018
//replace rx2d=. if rx2d!=. & dxyr==2018 //246 changes

count if rx3d!=. & dxyr==2018 //0
count if rx4d!=. & dxyr==2018 //0
count if rx5d!=. & dxyr==2018 //0

***************************
** Other Treatment 1 & 2 **
***************************
** NOTE 1: Treatment only collected at 5 year intervals so treatment collected on 2013 data then 2018 and so on;
** NOTE 2: In upcoming years of data collection (2018 dc year), more rxcheckcat checks will be compiled based on data.

** Check 116 - For 2014 data, replace non-blank other treatment with missing value
count if orx1!=. & dxyr!=2013 & dxyr!=2018 //0

count if orx2!="" & dxyr!=2013 & dxyr!=2018 //0
//list pid orx2 dxyr cr5id if orx2!="" & dxyr==2014
//replace orx2="" if orx2!="" & dxyr==2014 //3 changes


***************************
** No Treatments 1 and 2 **
***************************
** NOTE 1: Treatment only collected at 5 year intervals so treatment collected on 2013 data then 2018 and so on;
** NOTE 2: In upcoming years of data collection (2018 dc year), more rxcheckcat checks will be compiled based on data.


** Check 119 - For 2014 data, replace non-blank no treatment with missing value
count if norx1!=. & dxyr!=2013 & dxyr!=2018 //0
//list pid norx1 dxyr cr5id if norx1!=. & dxyr==2014
//replace norx1=. if norx1!=. & dxyr==2014 //5 changes

count if norx2!=. & dxyr!=2013 & dxyr!=2018 //0




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
count if stda==. //4 - 3 leave blank as source is blank
//list pid cr5id if stda==.
destring flag1 ,replace
destring flag95 ,replace
replace flag1=stda if pid=="20180635"
replace stda=14 if pid=="20180635" & regexm(cr5id, "T1")
replace flag95=stda if pid=="20180635"

** Length check not needed as this field is numeric
** Check 121 - invalid code
count if stda!=. & stda>14 & (stda!=22 & stda!=26 & stda!=88 & stda!=98 & stda!=99) //0
//list pid stda cr5id if stda!=. & stda>14 & (stda!=22 & stda!=26 & stda!=88 & stda!=98 & stda!=99)

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
count if nftype==. //5 - 4 leave blank as source is blank
//list pid nftype dxyr cr5id if nftype==.
destring flag3 ,replace
destring flag97 ,replace
replace flag3=nftype if pid=="20180358" & cr5id=="T1S3"
replace nftype=3 if pid=="20180358" & cr5id=="T1S3"
replace flag97=nftype if pid=="20180358" & cr5id=="T1S3"

destring flag4 ,replace
destring flag98 ,replace
replace flag4=sourcename if pid=="20180358" & cr5id=="T1S3"
replace sourcename=1 if pid=="20180358" & cr5id=="T1S3"
replace flag98=sourcename if pid=="20180358" & cr5id=="T1S3"

replace flag5=doctor if pid=="20180358" & cr5id=="T1S3"
replace doctor="99" if pid=="20180358" & cr5id=="T1S3"
replace flag100=doctor if pid=="20180358" & cr5id=="T1S3"

replace flag6=docaddr if pid=="20180358" & cr5id=="T1S3"
replace docaddr="99" if pid=="20180358" & cr5id=="T1S3"
replace flag101=docaddr if pid=="20180358" & cr5id=="T1S3"

** Check 125 - NFtype length
** Need to create string variable for nftype
gen notiftype=nftype
tostring notiftype, replace
** Need to change all notiftype"." to notiftype""
replace notiftype="" if notiftype=="." //4 changes made
count if notiftype!="" & length(notiftype)>2 //0
//list pid notiftype nftype dxyr cr5id if notiftype!="" & length(notiftype)>2

** Check 126 - NFtype=Other(possibly invalid)
count if nftype==13 //1 - all correct
//list pid nftype dxyr cr5id if nftype==13


*****************
** Source Name **
*****************
** NOTE 1: Patient notes only to be seen at 5 year intervals so e.g. notes seen on 2013 data then 2018 and so on;
** NOTE 2: In upcoming years of data collection (2018 dc year), more checks may be compiled based on data.

** Check 127 - Source Name missing (NB: some may have been since corrected in main CR5 by cancer team as this was first run on 24apr18 using 05mar2018 data)
count if sourcename==. //5 - 4 leave as blank as source is blank
//list pid nftype sourcename dxyr cr5id if sourcename==.
replace flag4=sourcename if pid=="20180222" & cr5id=="T1S3"
replace sourcename=1 if pid=="20180222" & cr5id=="T1S3"
replace flag98=sourcename if pid=="20180222" & cr5id=="T1S3"

** Check 129 - invalid(sourcename)

** sourcecheckcat 1: SourceName invalid length
count if sourcecheckcat==1 //0
//list pid cr5id sname sourcename dxyr stda if sourcecheckcat==1

** sourcecheckcat 2: SourceName!=QEH/BVH; NFType=Hospital; dxyr>2013
count if sourcecheckcat==2 //0
//list pid cr5id nftype sourcename dxyr stda if sourcecheckcat==2

** sourcecheckcat 3: SourceName=IPS-ARS; NFType!=Pathology; dxyr>2013
count if sourcecheckcat==3 //2 - 1 correct
//list pid cr5id nftype sourcename dxyr stda if sourcecheckcat==3
replace flag4=sourcename if pid=="20140849" & cr5id=="T3S2"
replace sourcename=1 if pid=="20140849" & cr5id=="T3S2"
replace flag98=sourcename if pid=="20140849" & cr5id=="T3S2"

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
count if sourcecheckcat==8 //5 - all correct
//list pid cr5id nftype sourcename dxyr stda if sourcecheckcat==8


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
count if doccheckcat==1 //0
//list pid cr5id doctor dxyr stda if doccheckcat==1


**********************
** Doctor's Address **
**********************
** NOTE 1: Patient notes only to be seen at 5 year intervals so e.g. notes seen on 2013 data then 2018 and so on;
** NOTE 2: In upcoming years of data collection (2018 dc year), more checks may be compiled based on data.

** Check 133 - Doctor's Address missing
count if docaddr=="" //5 - 3 leave blank as source is blank
//list pid consultant doctor docaddr dxyr cr5id if docaddr==""
replace flag54=consultant if pid=="20180223"
replace consultant="J NEBNHANI" if pid=="20180223" & regexm(cr5id, "T1")
replace flag149=consultant if pid=="20180223"

replace flag6=docaddr if pid=="20180223" & cr5id=="T1S3"|pid=="20180419" & cr5id=="T1S2"
replace docaddr="99" if pid=="20180223" & cr5id=="T1S3"|pid=="20180419" & cr5id=="T1S2"
replace flag101=docaddr if pid=="20180223" & cr5id=="T1S3"|pid=="20180419" & cr5id=="T1S2"

replace flag8=cfdx if pid=="20180223" & cr5id=="T1S3"|pid=="20180419" & cr5id=="T1S2"
replace cfdx="99" if pid=="20180223" & cr5id=="T1S3"|pid=="20180419" & cr5id=="T1S2"
replace flag103=cfdx if pid=="20180223" & cr5id=="T1S3"|pid=="20180419" & cr5id=="T1S2"

** Check 135 - invalid(docaddr)

** docaddrcheckcat 1: Doc Address invalid ND code
count if docaddrcheckcat==1 //0
//list pid cr5id doctor docaddr dxyr stda if docaddrcheckcat==1


******************
** CF Diagnosis **
******************
** NOTE 1: Patient notes only to be seen at 5 year intervals so e.g. notes seen on 2013 data then 2018 and so on;
** NOTE 2: In upcoming years of data collection (2018 dc year), more checks may be compiled based on data.

** Check 138 - CF Dx missing / CF Dx missing if nftype!=death~/cyto
** Discussed with SAF & KWG on 22may2018 and determined that CFDx to change from blank to 99 if CFDiagnosis=''(total of 314 records changed);
** IMPORTANT: WHEN IMPORTING BATCH CORRECTIONS - UNTICK 'Do Checks' IN MAIN CR5! WHEN CHECKS ARE RUN THE RECORD STATUS CHANGES.
** saving excel workbook as .txt and then importing into main CR5
count if cfdx=="" //7 - leave blank as source is blank
//list pid cfdx doctor dxyr cr5id if cfdx==""
replace flag8=cfdx if pid=="20180049" & cr5id=="T1S3"|pid=="20180056" & cr5id=="T1S2"|pid=="20182114" & cr5id=="T1S2"|pid=="20182378" & cr5id=="T1S3"
replace cfdx="99" if pid=="20180049" & cr5id=="T1S3"|pid=="20180056" & cr5id=="T1S2"|pid=="20182114" & cr5id=="T1S2"|pid=="20182378" & cr5id=="T1S3"
replace flag103=cfdx if pid=="20180049" & cr5id=="T1S3"|pid=="20180056" & cr5id=="T1S2"|pid=="20182114" & cr5id=="T1S2"|pid=="20182378" & cr5id=="T1S3"

count if cfdx=="" & (nftype!=8 & nftype!=9) //3  - leave blank as source is blank
//list pid cfdx doctor dxyr cr5id if cfdx=="" & (nftype!=8 & nftype!=9)
count if cfdx=="" & (nftype!=4 & nftype!=8 & nftype!=9) //3  - leave blank as source is blank
//list pid nftype cfdx doctor dxyr cr5id if cfdx=="" & (nftype!=4 & nftype!=8 & nftype!=9)

** Check 139 - CF Dx invalid ND code
** (Checked data in main CR5 to determine invalid ND values by filtering in CR5 Browse/Edit by Source table, sorted by field, looking at all variables and scrolling through entire field column.)
count if cfdx=="Not Stated"|cfdx=="9" //0
//list pid cfdx dxyr cr5id if cfdx=="Not Stated"|cfdx=="9"

** No more checks as difficult to perform standardized checks on this field as sometimes it has topographic info and sometimes has morphologic info so
** no consistency to perform a set of checks
** See visual lists in 'Specimen' category below

****************
** Lab Number **
****************

** Check 140 - Lab # missing / Lab # missing if nftype=Lab~
count if labnum=="" //870
//list pid nftype labnum dxyr cr5id if labnum==""
count if labnum=="" & (nftype>2 & nftype<6) //32
//list pid nftype labnum docaddr dxyr cr5id if labnum=="" & (nftype>2 & nftype<6)
replace labnum="99" if labnum=="" & (nftype>2 & nftype<6) //32 changes

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
count if specimen=="" //882
//list pid nftype specimen dxyr cr5id if specimen==""
count if specimen=="" & (nftype>2 & nftype<6) //41
//list pid nftype specimen docaddr dxyr cr5id if specimen=="" & (nftype>2 & nftype<6)
replace specimen="99" if specimen=="" & (nftype>2 & nftype<6) //41 changes

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
replace sampledate=d(01jan2000) if sampledate==. & recvdate!=. //894 changes

** rptcheckcat 2: Received Date missing
count if rptcheckcat==2 //0
//list pid cr5id nftype sampledate recvdate rptdate dxyr stda if rptcheckcat==2

** rptcheckcat 3: Report Date missing
count if rptcheckcat==3 //38
//list pid cr5id nftype sampledate recvdate rptdate dxyr stda if rptcheckcat==3
replace rptdate=d(01jan2000) if rptcheckcat==3 //38 changes

** rptcheckcat 4: sampledate after recvdate
count if rptcheckcat==4 //2
//list pid cr5id sampledate recvdate rptdate dxyr stda if rptcheckcat==4
replace sampledate=d(01jan2000) if pid=="20180005" & cr5id=="T1S2" //1 change

** rptcheckcat 5: sampledate after rptdate
count if rptcheckcat==5 //26 - all sample dates are missing so use missing date value
//list pid cr5id sampledate recvdate rptdate dxyr stda if rptcheckcat==5
//list pid cr5id sampledate if rptcheckcat==5
replace sampledate=d(01jan2000) if rptcheckcat==5 //0 changes - changed above

** rptcheckcat 6: recvdate after rptdate
count if rptcheckcat==6 //21
//list pid cr5id sampledate recvdate rptdate dxyr stda if rptcheckcat==6
replace flag13=recvdate if rptcheckcat==6
swapval recvdate rptdate if rptcheckcat==6 & pid!="20182113"
replace rptdate=d(19mar2018) if pid=="20182113" & cr5id=="T2S1"
replace flag108=recvdate if rptcheckcat==6

replace flag14=rptdate if pid=="20182113" & cr5id=="T2S1"
replace rptdate=d(19mar2018) if pid=="20182113" & cr5id=="T2S1"
replace flag109=rptdate if pid=="20182113" & cr5id=="T2S1"

** rptcheckcat 7: sampledate before InciD
count if rptcheckcat==7 //2
//list pid cr5id dot sampledate recvdate rptdate dxyr stda if rptcheckcat==7
replace flag52=dot if pid=="20180023" & regexm(cr5id, "T1")|pid=="20180583" & regexm(cr5id, "T1")
replace dot=sampledate if pid=="20180023" & cr5id=="T1S3"|pid=="20180583" & cr5id=="T1S2"
replace dot=. if pid=="20180023" & regexm(cr5id, "T1") & cr5id!="T1S3"|pid=="20180583" & regexm(cr5id, "T1") & cr5id!="T1S2"
fillmissing dot if pid=="20180023" & regexm(cr5id, "T1")
fillmissing dot if pid=="20180583" & regexm(cr5id, "T1")
replace flag147=dot if pid=="20180023" & regexm(cr5id, "T1")|pid=="20180583" & regexm(cr5id, "T1")

** rptcheckcat 8: recvdate before InciD
count if rptcheckcat==8 //10
//list pid cr5id dot sampledate recvdate rptdate dxyr stda if rptcheckcat==8
replace flag52=dot if pid=="20180002" & regexm(cr5id, "T1")|pid=="20180020" & regexm(cr5id, "T1")|pid=="20180048" & regexm(cr5id, "T1")|pid=="20181006" & regexm(cr5id, "T1")|pid=="20181160" & regexm(cr5id, "T1")
replace dot=sampledate if pid=="20180002" & cr5id=="T1S2"|pid=="20180020" & cr5id=="T1S2"|pid=="20180048" & cr5id=="T1S2"|pid=="20181006" & cr5id=="T1S1"|pid=="20181160" & cr5id=="T1S2"
replace dot=. if pid=="20180002" & regexm(cr5id, "T1") & cr5id!="T1S2"|pid=="20180020" & regexm(cr5id, "T1") & cr5id!="T1S2"|pid=="20180048" & regexm(cr5id, "T1") & cr5id!="T1S2"|pid=="20181006" & regexm(cr5id, "T1") & cr5id!="T1S1"|pid=="20181160" & regexm(cr5id, "T1") & cr5id!="T1S2"
fillmissing dot if pid=="20180002" & regexm(cr5id, "T1")
fillmissing dot if pid=="20180020" & regexm(cr5id, "T1")
fillmissing dot if pid=="20180048" & regexm(cr5id, "T1")
fillmissing dot if pid=="20181006" & regexm(cr5id, "T1")
fillmissing dot if pid=="20181160" & regexm(cr5id, "T1")
replace flag147=dot if pid=="20180002" & regexm(cr5id, "T1")|pid=="20180020" & regexm(cr5id, "T1")|pid=="20180048" & regexm(cr5id, "T1")|pid=="20181006" & regexm(cr5id, "T1")|pid=="20181160" & regexm(cr5id, "T1")


** rptcheckcat 9: rptdate before InciD
count if rptcheckcat==9 //29
//list pid cr5id dot sampledate recvdate rptdate dxyr stda if rptcheckcat==9
replace flag13=recvdate if pid=="20180602" & cr5id=="T1S1"
*swapval recvdate rptdate if pid=="20180602" & cr5id=="T1S1"
replace flag108=recvdate if pid=="20180602" & cr5id=="T1S1"

replace flag52=dot if pid=="20180119" & regexm(cr5id, "T1")|pid=="20180172" & regexm(cr5id, "T1")|pid=="20180183" & regexm(cr5id, "T1")|pid=="20180219" & regexm(cr5id, "T1")|pid=="20180272" & regexm(cr5id, "T1")|pid=="20180345" & regexm(cr5id, "T1")|pid=="20180350" & regexm(cr5id, "T1")|pid=="20180385" & regexm(cr5id, "T1")|pid=="20180391" & regexm(cr5id, "T1")|pid=="20180456" & regexm(cr5id, "T1")|pid=="20180494" & regexm(cr5id, "T1")|pid=="20180507" & regexm(cr5id, "T1")|pid=="20180598" & regexm(cr5id, "T1")|pid=="20180602" & regexm(cr5id, "T1")|pid=="20182295" & regexm(cr5id, "T1")

replace dot=sampledate if pid=="20180119" & cr5id=="T1S2"|pid=="20180183" & cr5id=="T1S1"|pid=="20180219" & cr5id=="T1S2"|pid=="20180272" & cr5id=="T1S2"|pid=="20180385" & cr5id=="T1S2"|pid=="20180456" & cr5id=="T1S3"|pid=="20180598" & cr5id=="T1S3"|pid=="20182295" & cr5id=="T1S2"

replace dot=recvdate if pid=="20180172" & cr5id=="T1S2"|pid=="20180345" & cr5id=="T1S2"|pid=="20180350" & cr5id=="T1S2"|pid=="20180391" & cr5id=="T1S1"|pid=="20180494" & cr5id=="T1S2"|pid=="20180507" & cr5id=="T1S2"|pid=="20180602" & cr5id=="T1S1"

replace dot=. if pid=="20180119" & regexm(cr5id, "T1") & cr5id!="T1S2"|pid=="20180172" & regexm(cr5id, "T1") & cr5id!="T1S2"|pid=="20180183" & regexm(cr5id, "T1") & cr5id!="T1S1"|pid=="20180219" & regexm(cr5id, "T1") & cr5id!="T1S2"|pid=="20180272" & regexm(cr5id, "T1") & cr5id!="T1S2"|pid=="20180345" & regexm(cr5id, "T1") & cr5id!="T1S2"|pid=="20180350" & regexm(cr5id, "T1") & cr5id!="T1S2"|pid=="20180385" & regexm(cr5id, "T1") & cr5id!="T1S2"|pid=="20180391" & regexm(cr5id, "T1") & cr5id!="T1S2"|pid=="20180456" & regexm(cr5id, "T1") & cr5id!="T1S3"|pid=="20180494" & regexm(cr5id, "T1") & cr5id!="T1S2"|pid=="20180507" & regexm(cr5id, "T1") & cr5id!="T1S2"|pid=="20180598" & regexm(cr5id, "T1") & cr5id!="T1S3"|pid=="20180602" & regexm(cr5id, "T1") & cr5id!="T1S1"|pid=="20182295" & regexm(cr5id, "T1") & cr5id!="T1S2"

fillmissing dot if pid=="20180119" & regexm(cr5id, "T1")
fillmissing dot if pid=="20180172" & regexm(cr5id, "T1")
fillmissing dot if pid=="20180183" & regexm(cr5id, "T1")
fillmissing dot if pid=="20180219" & regexm(cr5id, "T1")
fillmissing dot if pid=="20180272" & regexm(cr5id, "T1")
fillmissing dot if pid=="20180345" & regexm(cr5id, "T1")
fillmissing dot if pid=="20180350" & regexm(cr5id, "T1")
fillmissing dot if pid=="20180385" & regexm(cr5id, "T1")
fillmissing dot if pid=="20180391" & regexm(cr5id, "T1")
fillmissing dot if pid=="20180456" & regexm(cr5id, "T1")
fillmissing dot if pid=="20180494" & regexm(cr5id, "T1")
fillmissing dot if pid=="20180507" & regexm(cr5id, "T1")
fillmissing dot if pid=="20180598" & regexm(cr5id, "T1")
fillmissing dot if pid=="20180602" & regexm(cr5id, "T1")
fillmissing dot if pid=="20182295" & regexm(cr5id, "T1")

replace flag147=dot if pid=="20180119" & regexm(cr5id, "T1")|pid=="20180172" & regexm(cr5id, "T1")|pid=="20180183" & regexm(cr5id, "T1")|pid=="20180219" & regexm(cr5id, "T1")|pid=="20180272" & regexm(cr5id, "T1")|pid=="20180345" & regexm(cr5id, "T1")|pid=="20180350" & regexm(cr5id, "T1")|pid=="20180385" & regexm(cr5id, "T1")|pid=="20180391" & regexm(cr5id, "T1")|pid=="20180456" & regexm(cr5id, "T1")|pid=="20180494" & regexm(cr5id, "T1")|pid=="20180507" & regexm(cr5id, "T1")|pid=="20180598" & regexm(cr5id, "T1")|pid=="20180602" & regexm(cr5id, "T1")|pid=="20182295" & regexm(cr5id, "T1")

replace flag14=rptdate if pid=="20180401" & cr5id=="T1S2"|pid=="20180487" & cr5id=="T1S1"|pid=="20180525" & cr5id=="T1S1"
replace rptdate=d(04jan2019) if pid=="20180401" & cr5id=="T1S2"
replace rptdate=d(07jan2019) if pid=="20180487" & cr5id=="T1S1"
replace rptdate=d(18jan2019) if pid=="20180525" & cr5id=="T1S1"
replace flag109=rptdate if pid=="20180401" & cr5id=="T1S2"|pid=="20180487" & cr5id=="T1S1"|pid=="20180525" & cr5id=="T1S1"

replace flag13=recvdate if pid=="20180487" & cr5id=="T1S1"
replace recvdate=d(07jan2019) if pid=="20180487" & cr5id=="T1S1"
replace flag108=recvdate if pid=="20180487" & cr5id=="T1S1"

** JC 01jun2022: missed MP 20182295
replace flag42=morph if pid=="20182295"
replace morph=8312 if pid=="20182295" & regexm(cr5id, "T1")
replace flag137=morph if pid=="20182295"

expand=2 if pid=="20182295" & cr5id=="T1S3", gen (dupobs2)
replace cr5id="T2S1" if dupobs2==1

replace flag43=lat if pid=="20182295" & regexm(cr5id, "T2")
replace lat=1 if pid=="20182295" & regexm(cr5id, "T2")
replace flag138=lat if pid=="20182295" & regexm(cr5id, "T2")

replace flag80=comments if pid=="20182295" & cr5id=="T2S1"
replace comments="JC 01JUN2022: missed Kidney MP, right - please abstract according to corrections excel sheet."+" "+comments if pid=="20182295" & cr5id=="T2S1"
replace flag175=comments if pid=="20182295" & cr5id=="T2S1"


** rptcheckcat 10: sampledate after DLC
count if rptcheckcat==10 //37
//list pid cr5id basis dlc sampledate recvdate rptdate dxyr stda if rptcheckcat==10
order pid cr5id
destring flag78 ,replace
destring flag173 ,replace
format flag78 flag173 %dD_m_CY
replace flag78=dlc if rptcheckcat==10 & pid!="20180636" & pid!="20182111" & pid!="20182117"
replace dlc=sampledate if rptcheckcat==10 & pid!="20180636" & pid!="20182111" & pid!="20182117"
egen dlc2=max(dlc) if pid=="20180019"
replace dlc=dlc2 if pid=="20180019"
drop dlc2
egen dlc2=max(dlc) if pid=="20180152"
replace dlc=dlc2 if pid=="20180152"
drop dlc2
egen dlc2=max(dlc) if pid=="20180199"
replace dlc=dlc2 if pid=="20180199"
drop dlc2
egen dlc2=max(dlc) if pid=="20180203"
replace dlc=dlc2 if pid=="20180203"
drop dlc2
egen dlc2=max(dlc) if pid=="20180334"
replace dlc=dlc2 if pid=="20180334"
drop dlc2
egen dlc2=max(dlc) if pid=="20180393"
replace dlc=dlc2 if pid=="20180393"
drop dlc2
egen dlc2=max(dlc) if pid=="20180412"
replace dlc=dlc2 if pid=="20180412"
drop dlc2
egen dlc2=max(dlc) if pid=="20180459"
replace dlc=dlc2 if pid=="20180459"
drop dlc2
egen dlc2=max(dlc) if pid=="20181010"
replace dlc=dlc2 if pid=="20181010"
drop dlc2
egen dlc2=max(dlc) if pid=="20181190"
replace dlc=dlc2 if pid=="20181190"
drop dlc2
egen dlc2=max(dlc) if pid=="20181201"
replace dlc=dlc2 if pid=="20181201"
drop dlc2
egen dlc2=max(dlc) if pid=="20182040"
replace dlc=dlc2 if pid=="20182040"
drop dlc2
egen dlc2=max(dlc) if pid=="20182043"
replace dlc=dlc2 if pid=="20182043"
drop dlc2
egen dlc2=max(dlc) if pid=="20182044"
replace dlc=dlc2 if pid=="20182044"
drop dlc2
egen dlc2=max(dlc) if pid=="20182048"
replace dlc=dlc2 if pid=="20182048"
drop dlc2
egen dlc2=max(dlc) if pid=="20182051"
replace dlc=dlc2 if pid=="20182051"
drop dlc2
egen dlc2=max(dlc) if pid=="20182075"
replace dlc=dlc2 if pid=="20182075"
drop dlc2
egen dlc2=max(dlc) if pid=="20182080"
replace dlc=dlc2 if pid=="20182080"
drop dlc2
egen dlc2=max(dlc) if pid=="20182131"
replace dlc=dlc2 if pid=="20182131"
drop dlc2
egen dlc2=max(dlc) if pid=="20182143"
replace dlc=dlc2 if pid=="20182143"
drop dlc2
egen dlc2=max(dlc) if pid=="20182152"
replace dlc=dlc2 if pid=="20182152"
drop dlc2
egen dlc2=max(dlc) if pid=="20182182"
replace dlc=dlc2 if pid=="20182182"
drop dlc2
egen dlc2=max(dlc) if pid=="20182208"
replace dlc=dlc2 if pid=="20182208"
drop dlc2
egen dlc2=max(dlc) if pid=="20182209"
replace dlc=dlc2 if pid=="20182209"
drop dlc2
egen dlc2=max(dlc) if pid=="20182246"
replace dlc=dlc2 if pid=="20182246"
drop dlc2
egen dlc2=max(dlc) if pid=="20182266"
replace dlc=dlc2 if pid=="20182266"
drop dlc2
egen dlc2=max(dlc) if pid=="20182283"
replace dlc=dlc2 if pid=="20182283"
drop dlc2
egen dlc2=max(dlc) if pid=="20182300"
replace dlc=dlc2 if pid=="20182300"
drop dlc2
egen dlc2=max(dlc) if pid=="20182325"
replace dlc=dlc2 if pid=="20182325"
drop dlc2
egen dlc2=max(dlc) if pid=="20182382"
replace dlc=dlc2 if pid=="20182382"
drop dlc2
replace flag173=dlc if rptcheckcat==10 & pid!="20180636" & pid!="20182111" & pid!="20182117"

replace flag78=dlc if pid=="20180636" & regexm(cr5id, "T1")|pid=="20182111" & regexm(cr5id, "T1")|pid=="20182117" & regexm(cr5id, "T1")
replace dlc=sampledate if pid=="20180636" & cr5id=="T1S2"|pid=="20182111" & cr5id=="T1S3"|pid=="20182117" & cr5id=="T1S3"
replace dlc=. if pid=="20180636" & regexm(cr5id, "T1") & cr5id!="T1S2"|pid=="20182111" & regexm(cr5id, "T1") & cr5id!="T1S3"|pid=="20182117" & regexm(cr5id, "T1") & cr5id!="T1S3"
fillmissing dlc if pid=="20180636"
fillmissing dlc if pid=="20182111"
fillmissing dlc if pid=="20182117"
replace flag173=dlc if pid=="20180636" & regexm(cr5id, "T1")|pid=="20182111" & regexm(cr5id, "T1")|pid=="20182117" & regexm(cr5id, "T1")

** rptcheckcat 11: sampledate!=. & nftype!=lab~ & labnum=. (to filter out autopsies with hx)
count if rptcheckcat==11 //3 - correct all PMs
//list pid cr5id basis nftype sampledate dxyr stda if rptcheckcat==11

** rptcheckcat 12: recvdate!=. & nftype!=lab~ & labnum=. (to filter out autopsies with hx)
count if rptcheckcat==12 //0
//list pid cr5id basis nftype recvdate dxyr stda if rptcheckcat==12

** rptcheckcat 13: rptdate!=. & nftype!=lab~ & labnum=. (to filter out autopsies with hx)
count if rptcheckcat==13 //11 - correct no hx seen
//list pid cr5id basis nftype rptdate dxyr stda if rptcheckcat==13

** JC 01JUN2022: add this code to the prep dofile when performing 2016-2018 annual report
rename SurgicalFindings sxfinds 
//rename SurgicalFindingsDate sxfindsdate 
rename PhysicalExam physexam
//rename PhysicalExamDate physexamdate 
rename ImagingResults imaging 
//rename ImagingResultsDate imagingdate

** Surgical Findings
label var sxfinds "Surgical Findings"
** Surgical Findings Date
replace SurgicalFindingsDate=20000101 if SurgicalFindingsDate==99999999
nsplit SurgicalFindingsDate, digits(4 2 2) gen(sxyear sxmonth sxday)
gen sxfindsdate=mdy(sxmonth, sxday, sxyear)
format sxfindsdate %dD_m_CY
drop SurgicalFindingsDate
label var sxfindsdate "Surgical Findings Date"

** Physical Exam
label var physexam "Physical Exam"
** Physical Exam Date
replace PhysicalExamDate=20000101 if PhysicalExamDate==99999999
nsplit PhysicalExamDate, digits(4 2 2) gen(physyear physmonth physday)
gen physexamdate=mdy(physmonth, physday, physyear)
format physexamdate %dD_m_CY
drop PhysicalExamDate
label var physexamdate "Physical Exam Date"

** Imaging Results
label var imaging "Imaging Results"
** Imaging Results Date
replace ImagingResultsDate=20000101 if ImagingResultsDate==99999999
nsplit ImagingResultsDate, digits(4 2 2) gen(imgyear imgmonth imgday)
gen imagingdate=mdy(imgmonth, imgday, imgyear)
format imagingdate %dD_m_CY
drop ImagingResultsDate
label var imagingdate "Imaging Results Date"

count if nftype==6 & imaging=="" //9
gen imagingcheckcat=1 if nftype==6 & imaging==""
//list pid cr5id basis nftype rptdate dxyr stda if imagingcheckcat==1
//list pid cr5id cytofinds md nftype rptdate dxyr stda if imagingcheckcat==1, string(10)

replace flag23=imaging if imagingcheckcat==1
replace imaging=cytofinds if imagingcheckcat==1 & cytofinds!="" & cytofinds!="99"
replace imaging=md if imagingcheckcat==1 & md!="" & md!="99"
replace flag118=imaging if imagingcheckcat==1

replace imagingcheckcat=2 if nftype==6 & (imagingdate==.|imagingdate==d(01jan2000))
//list pid cr5id basis nftype rptdate dxyr stda if imagingcheckcat==2
//list pid cr5id cytofinds md nftype rptdate dxyr stda if imagingcheckcat==2, string(10)
//list pid cr5id rptdate nftype imagingdate dxyr stda if imagingcheckcat==2, string(10)

destring flag24 ,replace
destring flag119 ,replace
format flag24 flag119 %dD_m_CY
replace flag24=imagingdate if imagingcheckcat==2
replace imagingdate=rptdate if imagingcheckcat==2 & pid!="20180575"
replace imagingdate=d(15feb2018) if pid=="20180575" & cr5id=="T1S2" //used unk day missing value
replace flag119=imagingdate if imagingcheckcat==2

**********************
** Clinical Details **
**********************
** Check 149 - Clinical Details missing / Clinical Details missing if nftype=Lab~
count if clindets=="" //885
//list pid nftype clindets dxyr cr5id if clindets==""
count if clindets=="" & (nftype>2 & nftype<6) //50
//list pid nftype clindets dxyr cr5id if clindets=="" & (nftype>2 & nftype<6)
replace clindets="99" if clindets=="" & (nftype>2 & nftype<6) //16 changes

** Check 150 - Clinical Details invalid ND code
** (Checked data in main CR5 to determine invalid ND values by filtering in CR5 Browse/Edit by Source table, sorted by field, looking at all variables and scrolling through entire field column.)
count if clindets=="Not Stated"|clindets=="NIL"|regexm(clindets, "NONE")|clindets=="9" //0
//list pid clindets dxyr cr5id if clindets=="Not Stated"|clindets=="NIL"|regexm(clindets, "NONE")|clindets=="9"
replace clindets="99" if clindets=="Not Stated"|clindets=="NIL"|regexm(clindets, "NONE")|clindets=="9" //5 changes


**************************
** Cytological Findings **
**************************
** Check 151 - Cytological Findings missing / Cytological Findings missing if nftype=Lab-Cyto
count if cytofinds=="" //1974
count if cytofinds=="" & (nftype>2 & nftype<6) //1134
count if nftype!=4 & (regexm(specimen, "FNA")|regexm(specimen, "Aspirat")|regexm(specimen, "ASPIRAT")) //13 - leave as is
//list pid nftype specimen cytofinds dxyr cr5id if nftype!=4 & (regexm(specimen, "FNA")|regexm(specimen, "Aspirat")|regexm(specimen, "ASPIRAT"))
/*
replace flag3=nftype if pid=="20180303" & cr5id=="T2S1"|pid=="20180306" & cr5id=="T2S1"|pid=="20180823" & cr5id=="T1S3"|pid=="20182029" & cr5id=="T1S1"|pid=="20182089" & cr5id=="T2S1"|pid=="20182120" & cr5id=="T1S1"|pid=="20182180" & cr5id=="T1S2"
replace nftype=4 if pid=="20180303" & cr5id=="T2S1"|pid=="20180306" & cr5id=="T2S1"|pid=="20182029" & cr5id=="T1S1"|pid=="20182089" & cr5id=="T2S1"|pid=="20182120" & cr5id=="T1S1"|pid=="20182180" & cr5id=="T1S2"
replace nftype=5 if pid=="20180823" & cr5id=="T1S3"|pid=="" & cr5id=="T2S1"
replace flag97=nftype if pid=="20180303" & cr5id=="T2S1"|pid=="20180306" & cr5id=="T2S1"|pid=="20180823" & cr5id=="T1S3"|pid=="20182029" & cr5id=="T1S1"|pid=="20182089" & cr5id=="T2S1"|pid=="20182120" & cr5id=="T1S1"|pid=="20182180" & cr5id=="T1S2"
*/
count if cytofinds=="" & nftype==4 //1 - leave as is
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
count if md=="" //891
count if md=="" & (nftype>2 & nftype<6) //64
count if md=="" & (nftype==3|nftype==5) //27
//list pid nftype specimen md dxyr cr5id if md=="" & (nftype==3|nftype==5)
replace flag17=md if pid=="20181121" & cr5id=="T1S2"
replace md=consrpt if pid=="20181121" & cr5id=="T1S2"
replace flag112=md if pid=="20181121" & cr5id=="T1S2"

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
count if consrpt=="" & (nftype==3|nftype==5) //1031
//list pid nftype consrpt dxyr cr5id if consrpt=="" & (nftype==3|nftype==5)
replace consrpt="99" if consrpt=="" & (nftype==3|nftype==5) //1031

** Check 156 - Consult.Rpt invalid ND code
** (Checked data in main CR5 to determine invalid ND values by filtering in CR5 Browse/Edit by Source table, sorted by field, looking at all variables and scrolling through entire field column.)
count if consrpt=="Not Stated"|consrpt=="Not Stated."|consrpt=="9" //0
//list pid consrpt dxyr cr5id if consrpt=="Not Stated"|consrpt=="Not Stated."|consrpt=="9"
replace consrpt="99" if consrpt=="Not Stated"|consrpt=="Not Stated."|consrpt=="9" //0 changes


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
duplicates tag pid, gen(dup)
count if dup>0 //1845
count if dup==0 //379

count if (cr5cod!="" & cr5cod!="99") & dxyr==2018 //400
count if (cr5cod!="" & cr5cod!="99") & dxyr==2018 & dup>0 //299 - none with differing CODs
//list pid cr5id cr5cod if (cr5cod!="" & cr5cod!="99") & dxyr==2018 & dup>0, nolabel sepby(pid) string(50)
//list pid cr5id cr5cod if (cr5cod!="" & cr5cod!="99") & dxyr==2018, string(50)
//list pid cr5id cr5cod if (cr5cod!="" & cr5cod!="99") & dxyr==2018 & dup>0, string(50)
//list cr5cod if (cr5cod!="" & cr5cod!="99") & dxyr==2018

** Check 157b - COD missing / COD missing if nftype=Death~
count if cr5cod=="" //1801
//list pid nftype cr5cod dxyr cr5id if cr5cod==""
count if cr5cod=="" & (nftype==8|nftype==9) //9 - all are PMs
//list pid nftype cr5cod dxyr cr5id if cr5cod=="" & (nftype==8|nftype==9)


** Check 158 - COD invalid ND code
** (Checked data in main CR5 to determine invalid ND values by filtering in CR5 Browse/Edit by Source table, sorted by field, looking at all variables and scrolling through entire field column.)
count if regexm(cr5cod, "Not")|regexm(cr5cod, "not")|cr5cod=="NIL."|cr5cod=="Not Stated"|cr5cod=="9" //0
//list pid cr5cod dxyr cr5id if regexm(cr5cod, "Not")|regexm(cr5cod, "not")|cr5cod=="NIL."|cr5cod=="Not Stated"|cr5cod=="9"

** Check 159 - COD invalid entry(lowercase)
count if cr5cod!="99" & cr5cod!="" & regexm(cr5cod, "[a-z]") //87
//list pid cr5cod dxyr cr5id if cr5cod!="99" & cr5cod!="" & regexm(cr5cod, "[a-z]")
replace cr5cod=upper(cr5cod) if cr5cod!="99" & cr5cod!="" & regexm(cr5cod, "[a-z]") //87 changes


*************************
** Duration of Illness **
*************************
** Check 160 - Duration of Illness missing / Duration of Illness missing if nftype=Death~
count if duration=="" & nftype==8 //285 - 06nov18 SAF (by email) indicated to run code only on death certificates and not QEH death bks so removed 'nftype==9' from code.
//list pid nftype duration onsetint dxyr cr5id if duration=="" & nftype==8
replace duration="99" if duration=="" & nftype==8 //285 changes

** Check 161 - Duration of Illness invalid ND code
** (Checked data in main CR5 to determine invalid ND values by filtering in CR5 Browse/Edit by Source table, sorted by field, looking at all variables and scrolling through entire field column.)
count if regexm(duration, "UNKNOWN")|regexm(duration, "Not")|regexm(duration, "not")|duration=="NIL."|duration=="Not Stated"|duration=="9" //0
//list pid duration dxyr cr5id if regexm(duration, "UNKNOWN")|regexm(duration, "Not")|regexm(duration, "not")|duration=="NIL."|duration=="Not Stated"|duration=="9"

** Check 162 - Duration of Illness invalid entry(lowercase)
count if duration!="99" & duration!="" & regexm(duration, "[a-z]") //1
//list pid duration dxyr cr5id if duration!="99" & duration!="" & regexm(duration, "[a-z]")
replace duration=upper(duration) if duration!="99" & duration!="" & regexm(duration, "[a-z]") //1 change

*****************************
** Onset to Death Interval **
*****************************
** Check 163 - Onset to Death Interval missing / Onset to Death Interval missing if nftype=Death~
count if onsetint=="" & nftype==8 //286 - 06nov18 SAF (by email) indicated to run code only on death certificates and not QEH death bks so removed 'nftype==9' from code.
//list pid nftype onsetint dxyr cr5id if onsetint=="" & nftype==8
replace onsetint="99" if onsetint=="" & nftype==8 //286 changes

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
count if certifier=="" & (nftype==8|nftype==9) //14
//list pid nftype certifier dxyr cr5id if certifier=="" & (nftype==8|nftype==9)
replace certifier="99" if certifier=="" & (nftype==8|nftype==9) //14 changes

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
count if datescheckcat==1 //1303 - leave as is since SAF/KWG to decide if to collect missing dates
//list pid cr5id sourcename nftype admdate dfc rtdate dxyr stda if datescheckcat==1

** datescheckcat 2: DFC missing
count if datescheckcat==2 //501 - leave as is since SAF/KWG to decide if to collect missing dates
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
count if datescheckcat==6 //1
//list pid cr5id sourcename nftype admdate dfc rtdate dxyr stda if datescheckcat==6
replace flag52=dot if pid=="20180662" & cr5id=="T1S1"
replace dot=admdate if pid=="20180662" & cr5id=="T1S1"
replace flag147=dot if pid=="20180662" & cr5id=="T1S1"

** datescheckcat 7: dfc!=. & sourcename!=PrivPhys/IPS
count if datescheckcat==7 //0
//list pid cr5id sourcename nftype admdate dfc rtdate dxyr stda if datescheckcat==7

** datescheckcat 8: rtdate!=. & nftype!=RT
count if datescheckcat==8 //0
//list pid cr5id sourcename nftype admdate dfc rtdate dxyr stda if datescheckcat==8


*****************
** Final Clean **
**  PAB ASIRs  **
*****************
** Check if morph and morphology do not match (added this check on 31may2022)
gen morph2=morph
tostring morph2 ,replace
count if morph2!=morphology //281
replace morphology=morph2
drop morph2

** Check if morph and morphology do not match (added this check on 31may2022)
gen topography2=topography
tostring topography2 ,replace
count if topography2!=top //297
replace top=topography2
drop topography2

drop laterality behaviour str_grade bas diagyr notiftype

** Identify duplicate PIDs
drop dup
sort pid
quietly by pid:  gen dup = cond(_N==1,0,_n)
count if dup>1 //1138
//drop if dup>1
//drop dup

** Check for matches by natregno and pt names
duplicates tag natregno, gen(dupnrntag)
count if dupnrntag>0 //1863
count if dupnrntag==0 //361

sort natregno lname fname pid
quietly by natregno :  gen dupnrn = cond(_N==1,0,_n)
sort natregno
count if dupnrn>0 //1863
sort lname fname pid cr5id
order pid cr5id fname lname sex age natregno
count if dupnrn>0 & natregno!="" & natregno!="9999999999" & natregno!="999999-9999" & dup==1 & dupnrntag==0 //0 - no matches (used data editor and filtered)
//list pid cr5id fname lname age natregno addr slc if dupnrn>0 & natregno!="" & natregno!="999999-9999" & dup==1 & dupnrntag==0, nolabel sepby(dupnrntag) string(38)


sort lname fname cr5id pid
quietly by lname fname :  gen duppt = cond(_N==1,0,_n)
sort lname fname
count if duppt>0 //2198
sort lname fname pid cr5id
count if duppt>0 & dup==1 //707 - no matches (used below lists)
gen obsid=_n
//list pid cr5id fname lname age natregno addr slc if duppt>0 & dup==1 & inrange(obsid, 0, 1112), sepby(lname)
//list pid cr5id fname lname age natregno addr slc if duppt>0 & dup==1 & inrange(obsid, 1113, 2224), sepby(lname)
drop dup dupnrn duppt obsid

/*
** Export corrections before dropping duplicate tumours/sources since errors maybe in dup source records
** Prepare this dataset for export to excel (prior to removing non-2018 cases)
preserve
sort pid
** Checked for those that are not string by using Variables Manager and filtering by 'flag' and sorting by Type
drop if  flag1==. & flag2=="" & flag3==. & flag4==. & flag5=="" & flag6=="" & flag7=="" & flag8=="" & flag9=="" & flag10=="" ///
		 & flag11=="" & flag12==. & flag13==. & flag14==. & flag15=="" & flag16=="" & flag17=="" & flag18=="" & flag19=="" & flag20=="" ///
		 & flag21=="" & flag22=="" & flag23=="" & flag24==. & flag25=="" & flag26=="" & flag27=="" & flag28=="" & flag29=="" & flag30=="" ///
		 & flag31=="" & flag32==. & flag33=="" & flag34=="" & flag35=="" & flag36=="" & flag37=="" & flag38==. & flag39=="" & flag40==. ///
		 & flag41=="" & flag42==. & flag43==. & flag44=="" & flag45==. & flag46==. & flag47=="" & flag48==. & flag49=="" & flag50==. ///
		 & flag51==. & flag52==. & flag53==. & flag54=="" & flag55=="" & flag56=="" & flag57=="" & flag58=="" & flag59=="" & flag60=="" ///
		 & flag61=="" & flag62=="" & flag63=="" & flag64=="" & flag65=="" & flag66=="" & flag67=="" & flag68=="" & flag69=="" & flag70=="" ///
		 & flag71=="" & flag72==. & flag73==. & flag74=="" & flag75=="" & flag76=="" & flag77==. & flag78==. & flag79==. & flag80=="" ///
		 & flag81=="" & flag82=="" & flag83=="" & flag84==. & flag85=="" & flag86=="" & flag87=="" & flag88=="" & flag89=="" & flag90=="" ///
		 & flag91=="" & flag92=="" & flag93=="" & flag94=="" & flag95==. & flag96=="" & flag97==. & flag98==. & flag99=="" & flag100=="" ///
		 & flag101=="" & flag102=="" & flag103=="" & flag104=="" & flag105=="" & flag106=="" & flag107==. & flag108==. & flag109==. & flag110=="" ///
		 & flag111=="" & flag112=="" & flag113=="" & flag114=="" & flag115=="" & flag116=="" & flag117=="" & flag118=="" & flag119==. & flag120=="" ///
		 & flag121=="" & flag122=="" & flag123=="" & flag124=="" & flag125=="" & flag126=="" & flag127==. & flag128=="" & flag129=="" & flag130=="" ///
		 & flag131=="" & flag132=="" & flag133==. & flag134=="" & flag135==. & flag136=="" & flag137==. & flag138==. & flag139=="" & flag140==. ///
		 & flag141==. & flag142=="" & flag143==. & flag144=="" & flag145==. & flag146==. & flag147==. & flag148==. & flag149=="" & flag150=="" ///
		 & flag151=="" & flag152=="" & flag153=="" & flag154=="" & flag155=="" & flag156=="" & flag157=="" & flag158=="" & flag159=="" & flag160=="" ///
		 & flag161=="" & flag162=="" & flag163=="" & flag164=="" & flag165=="" & flag166=="" & flag167==. & flag168==. & flag169=="" & flag170=="" ///
		 & flag171=="" & flag172==. & flag173==. & flag174==. & flag175=="" & flag176=="" & flag177=="" & flag178=="" & flag179==. & flag180=="" ///
		 & flag181=="" & flag182=="" & flag183=="" & flag184=="" & flag185=="" & flag186=="" & flag187=="" & flag188=="" & flag189==""
// deleted

gen str_no= _n
label var str_no "No."

** Create excel errors list before deleting incorrect records
** Use below code to automate file names using current date
local listdate = string( d(`c(current_date)'), "%dCYND" )
capture export_excel str_no pid cr5id flag1-flag94 if ///
		flag1!=. | flag2!="" | flag3!=. | flag4!=. | flag5!="" | flag6!="" | flag7!="" | flag8!="" | flag9!="" | flag10!="" ///
		|flag11!="" | flag12!=. | flag13!=. | flag14!=. | flag15!="" | flag16!="" | flag17!="" | flag18!="" | flag19!="" | flag20!="" ///
		|flag21!="" | flag22!="" | flag23!="" | flag24!=. | flag25!="" | flag26!="" | flag27!="" | flag28!="" | flag29!="" | flag30!="" ///
		|flag31!="" | flag32!=. | flag33!="" | flag34!="" | flag35!="" | flag36!="" | flag37!="" | flag38!=. | flag39!="" | flag40!=. ///
		|flag41!="" | flag42!=. | flag43!=. | flag44!="" | flag45!=. | flag46!=. | flag47!="" | flag48!=. | flag49!="" | flag50!=. ///
		|flag51!=. | flag52!=. | flag53!=. | flag54!="" | flag55!="" | flag56!="" | flag57!="" | flag58!="" | flag59!="" | flag60!="" ///
		|flag61!="" | flag62!="" | flag63!="" | flag64!="" | flag65!="" | flag66!="" | flag67!="" | flag68!="" | flag69!="" | flag70!="" ///
		|flag71!="" | flag72!=. | flag73!=. | flag74!="" | flag75!="" | flag76!="" | flag77!=. | flag78!=. | flag79!=. | flag80!="" ///
		|flag81!="" | flag82!="" | flag83!="" | flag84!=. | flag85!="" | flag86!="" | flag87!="" | flag88!="" | flag89!="" | flag90!="" ///
		|flag91!="" | flag92!="" | flag93!="" | flag94!="" ///
using "`datapath'/version13/3-output/CancerCleaning2018_`listdate'.xlsx", sheet("ERRORS") firstrow(varlabels)
capture export_excel str_no pid cr5id flag95-flag189 if ///
		 flag95!=. | flag96!="" | flag97!=. | flag98!=. | flag99!="" | flag100!="" ///
		 |flag101!="" | flag102!="" | flag103!="" | flag104!="" | flag105!="" | flag106!="" | flag107!=. | flag108!=. | flag109!=. | flag110!="" ///
		 |flag111!="" | flag112!="" | flag113!="" | flag114!="" | flag115!="" | flag116!="" | flag117!="" | flag118!="" | flag119!=. | flag120!="" ///
		 |flag121!="" | flag122!="" | flag123!="" | flag124!="" | flag125!="" | flag126!="" | flag127!=. | flag128!="" | flag129!="" | flag130!="" ///
		 |flag131!="" | flag132!="" | flag133!=. | flag134!="" | flag135!=. | flag136!="" | flag137!=. | flag138!=. | flag139!="" | flag140!=. ///
		 |flag141!=. | flag142!="" | flag143!=. | flag144!="" | flag145!=. | flag146!=. | flag147!=. | flag148!=. | flag149!="" | flag150!="" ///
		 |flag151!="" | flag152!="" | flag153!="" | flag154!="" | flag155!="" | flag156!="" | flag157!="" | flag158!="" | flag159!="" | flag160!="" ///
		 |flag161!="" | flag162!="" | flag163!="" | flag164!="" | flag165!="" | flag166!="" | flag167!=. | flag168!=. | flag169!="" | flag170!="" ///
		 |flag171!="" | flag172!=. | flag173!=. | flag174!=. | flag175!="" | flag176!="" | flag177!="" | flag178!="" | flag179!=. | flag180!="" ///
		 |flag181!="" | flag182!="" | flag183!="" | flag184!="" | flag185!="" | flag186!="" | flag187!="" | flag188!="" | flag189!="" ///
using "`datapath'/version13/3-output/CancerCleaning2018_`listdate'.xlsx", sheet("CORRECTIONS") firstrow(varlabels)
restore
*/


************************
**  Prep dataset for  **
** PAB ASIRs analysis **
************************
//delete ineligibles (recstatus, resident), dxyr!=2018 etc.

tab dxyr ,m
drop if dxyr!=2019 //1 deleted - 2017 case

*****************************
** Identifying & Labelling **
** 		  Duplicate		   **
**	 Tumours and Sources   **
*****************************

sort pid cr5id lname fname
 gen dupst = cond(_N==1,0,_n)
sort pid cr5id
count if dupst>0 //1845
sort pid cr5id lname fname
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

tab resident ,m

//list pid cr5id recstatus addr if resident!=1 & recstatus!=3 & recstatus!=5
replace recstatus=5 if pid=="20182401"
replace resident=1 if resident!=1 & recstatus!=3 & recstatus!=5 //12 changes

count if (topography>439 & topography<450 & morph!=8720)|morph==8832 //7
//list pid cr5id primarysite topography top morph morphology if (topography>439 & topography<450 & morph!=8720)|morph==8832
replace recstatus=3 if pid=="20180031" & regexm(cr5id, "T1")|pid=="20180634" & regexm(cr5id, "T1") //SCC of skin, anus
replace top="444" if pid=="20180559" & cr5id=="T1S1" //dermatofibrosarcoma = top - skin
replace topography=444 if pid=="20180559" & cr5id=="T1S1"


tab recstatus ,m
/*
                       Record Status |      Freq.     Percent        Cum.
-------------------------------------+-----------------------------------
                           Confirmed |      1,932       86.91       86.91
                          Ineligible |        141        6.34       93.25
                           Duplicate |        111        4.99       98.25
Eligible, Non-reportable(?residency) |         12        0.54       98.79
              Abs, Pending CD Review |          9        0.40       99.19
             Abs, Pending REG Review |         18        0.81      100.00
-------------------------------------+-----------------------------------
                               Total |      2,223      100.00
*/

replace dupsource=1 if (recstatus==1|recstatus>4) & regexm(cr5id,"S1") //986 confirmed - this is the # eligible non-duplicate tumours
replace dupsource=2 if (recstatus==1|recstatus>4) & !strmatch(strupper(cr5id), "*S1") //985 - confirmed
replace dupsource=3 if recstatus==4 & regexm(cr5id,"S1") //102 - duplicate
replace dupsource=4 if recstatus==4 & !strmatch(strupper(cr5id), "*S1") //9 - duplicate
replace dupsource=5 if recstatus==3 & cr5id=="T1S1" //110 - ineligible
replace dupsource=6 if recstatus==3 & cr5id!="T1S1" //31 - duplicate

sort pid
gen obsid = _n
by pid: generate pidobsid=_n //gives sequence id for each pid that appears in dataset
by pid: generate pidobstot=_N //give total count for each pid that is duplicated in dataset

sort pid obsid
** Now check list of only eligible non-duplicate tumours for 'true' and 'false' MPs by first & last names
count if dupsource==1 //986
//list pid cr5id fname lname dupsource recstatus duppid duppid_all obsid if inrange(obsid, 0, 700), sepby(pid)
//list pid cr5id fname lname dupsource recstatus duppid duppid_all obsid if inrange(obsid, 701, 1400), sepby(pid)
//list pid cr5id fname lname dupsource recstatus duppid duppid_all obsid if inrange(obsid, 1401, 2035), sepby(pid)


/*
	IARC crg Tools - see output results in the path:

	L:/Sync/Cancer/CanReg5/Backups/Data Cleaning/2022/2022-05-30_Monday/Checked_MP dataset.prn


	Results of IARC MP Program:
		24 excluded (non-malignant)
		19 MPs (multiple tumours)
		 5 Duplicate registration
*/

** Only report non-duplicate MPs (see IARC MP rules on recording and reporting)
display `"{browse "http://www.iacr.com.fr/images/doc/MPrules_july2004.pdf":IARC-MP}"'
tab persearch ,m
//list pid cr5id if persearch==3 //3

** Updates from multiple primary report (define which is the MP so can remove in survival dataset):
//no updates needed as none to exclude

** Updates from MP exclusion and MP reports (excludes in-situ/unreportable cancers)
label drop persearch_lab
label define persearch_lab 0 "Not done" 1 "Done: OK" 2 "Done: MP" 3 "Done: Duplicate" 4 "Done: Non-IARC MP" 5 "Done: IARCcrgTools Excluded", modify
label values persearch persearch_lab

tab beh ,m
replace beh=3 if pid=="20180247" & regexm(cr5id, "T1")
replace persearch=5 if beh<3 //40 changes

tab persearch ,m
//list pid cr5id if persearch==2
replace persearch=4 if pid=="20182211" & regexm(cr5id, "T2")
replace persearch=4 if pid=="20182096" & regexm(cr5id, "T2")
replace persearch=4 if pid=="20180152" & regexm(cr5id, "T1")
replace persearch=4 if pid=="20180068" & regexm(cr5id, "T1")
replace persearch=4 if pid=="20140849" & regexm(cr5id, "T3")

** Assign person search variable
tab persearch ,m
/*
              Person Search |      Freq.     Percent        Cum.
----------------------------+-----------------------------------
                   Not done |      2,166       97.44       97.44
          Done: Non-IARC MP |         10        0.45       97.89
Done: IARCcrgTools Excluded |         40        1.80       99.69
                          . |          7        0.31      100.00
----------------------------+-----------------------------------
                      Total |      2,223      100.00
*/

** Assign MPs first based on IARCcrgTools MP report
replace persearch=2 if pid=="20181005" & regexm(cr5id, "T1")
replace persearch=2 if pid=="20180910" & regexm(cr5id, "T2")
replace persearch=2 if pid=="20180788" & regexm(cr5id, "T2")
replace persearch=2 if pid=="20180416" & regexm(cr5id, "T2")
replace persearch=2 if pid=="20180396" & regexm(cr5id, "T2")
replace persearch=2 if pid=="20180190" & regexm(cr5id, "T2")
replace persearch=2 if pid=="20180050" & regexm(cr5id, "T2")

replace persearch=1 if dupsource==1 & (persearch==0|persearch==.) //951
replace persearch=3 if (dupsource>1 & dupsource<5) & (persearch==0|persearch==.) //1074
count if recstatus==4 & persearch!=3 //0
count if recstatus==3 //141
count if recstatus==3 & (persearch==0|persearch==.) //139
replace persearch=0 if recstatus==3 & persearch==. //0 changes

tab persearch ,m
/*
              Person Search |      Freq.     Percent        Cum.
----------------------------+-----------------------------------
                   Not done |        139        6.25        6.25
                   Done: OK |        951       42.78       49.03
                   Done: MP |          9        0.40       49.44
            Done: Duplicate |      1,074       48.31       97.75
          Done: Non-IARC MP |         10        0.45       98.20
Done: IARCcrgTools Excluded |         40        1.80      100.00
----------------------------+-----------------------------------
                      Total |      2,223      100.00
*/

** Based on above list, create variable to identify MPs
gen eidmp=1 if persearch==1
replace eidmp=2 if persearch==2
label var eidmp "CR5 tumour events"
label define eidmp_lab 1 "single tumour" 2 "multiple tumour" ,modify
label values eidmp eidmp_lab
tab eidmp ,m
/*
     CR5 tumour |
         events |      Freq.     Percent        Cum.
----------------+-----------------------------------
  single tumour |        951       42.78       42.78
multiple tumour |          9        0.40       43.18
              . |      1,263       56.82      100.00
----------------+-----------------------------------
          Total |      2,223      100.00
*/
tab eidmp dxyr
** Check if eidmp below match with MPs identified on hardcopy list
count if dupsource==1 //988
sort pid lname fname
//list pid eidmp dupsource duppid cr5id fname lname if dupsource==1 
**no corrections needed

count //2223

** Save dataset with source duplicates
label data "BNR-Cancer data - 2018 PAB Incidence: source duplicates"
notes _dta :These data prepared from CanReg5 2022-05-24_KWG (BNR-C) database
save "`datapath'/version08/2-working/2018_cancer_dups" ,replace
note: TS This dataset can be used for assessing sources per record


** Remove duplicate source records, ineligible and non-reportable cases
tab recstatus ,m
/*
                       Record Status |      Freq.     Percent        Cum.
-------------------------------------+-----------------------------------
                           Confirmed |      1,932       86.91       86.91
                          Ineligible |        141        6.34       93.25
                           Duplicate |        111        4.99       98.25
Eligible, Non-reportable(?residency) |         12        0.54       98.79
              Abs, Pending CD Review |          9        0.40       99.19
             Abs, Pending REG Review |         18        0.81      100.00
-------------------------------------+-----------------------------------
                               Total |      2,223      100.00
*/
drop if recstatus>1 & recstatus<6 //264 deleted

tab persearch ,m
/*
              Person Search |      Freq.     Percent        Cum.
----------------------------+-----------------------------------
                   Done: OK |        940       47.98       47.98
                   Done: MP |          9        0.46       48.44
            Done: Duplicate |        962       49.11       97.55
          Done: Non-IARC MP |         10        0.51       98.06
Done: IARCcrgTools Excluded |         38        1.94      100.00
----------------------------+-----------------------------------
                      Total |      1,959      100.00
*/
tab dupsource ,m
tab eidmp dxyr ,m
tab recstatus dxyr ,m
tab eidmp ,m
/*
     CR5 tumour |
         events |      Freq.     Percent        Cum.
----------------+-----------------------------------
  single tumour |        940       47.98       47.98
multiple tumour |          9        0.46       48.44
              . |      1,010       51.56      100.00
----------------+-----------------------------------
          Total |      1,959      100.00
*/
drop if eidmp==. //1010 deleted

count //949

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
replace patient=1 if eidmp==1 //940 changes
replace patient=2 if eidmp==2 //9 changes
tab patient ,m

** Convert names to lower case and strip possible leading/trailing blanks
replace fname = lower(rtrim(ltrim(itrim(fname)))) //0 changes
replace init = lower(rtrim(ltrim(itrim(init)))) //870 changes
replace lname = lower(rtrim(ltrim(itrim(lname)))) //0 changes
	  
** Ensure death date is correct IF PATIENT IS DEAD
count if dod==. & slc==2 //0
gen dodyear=year(dod) if dod!=.
count if dodyear==. & dod!=. //0
//list pid cr5id fname lname nftype dlc if dod==. & slc==2

** JC 02JUN2022: below check not done as death matching not done for PAB ASIRs
/*
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
capture export_excel pid fname lname natregno dod cr5cod doctor docaddr certifier ///
		using "`datapath'/version13/2-working/DCO2015V05.xlsx", sheet("2015 DCOs_cr5data_20210727") firstrow(variables)
//JC remember to change V01 to V02 when running list a 2nd time!
restore
*/

** Check DCOs
tab basis ,m
** Re-assign dcostatus for cases with updated death trace-back: still pending as of 19feb2020 TBD by NS
//tab dcostatus ,m
//replace dcostatus=1 if pid=="20150468" & dcostatus==. //1 change; 0 changes
//count if dcostatus==2 & basis!=0
//list pid basis if dcostatus==2 & basis!=0 - autopsy w/ hx

** Remove non-residents (see IARC validity presentation)
tab resident ,m //0 missing
//list pid cr5id recstatus addr if resident!=1
label drop resident_lab
label define resident_lab 1 "Yes" 2 "No" 99 "Unknown", modify
label values resident resident_lab
replace resident=99 if resident==9 //45 changes
//list pid natregno nrn addr dd_address if resident==99
replace resident=1 if resident==99 & addr!="99" & addr!="" //0 changes
//replace resident=1 if resident==99 & dd_address!="99" & dd_address!="" //0
//replace natregno=nrn if natregno=="" & nrn!="" & resident==99 //3 changes
replace resident=1 if natregno!="" & !(strmatch(strupper(natregno), "*9999*")) //0 changes
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
tab beh ,m //951 malignant
tab morph if beh!=3

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
count if dob!=. & dot!=. & age!=checkage2 //5
//list pid dot dob age checkage2 cr5id if dob!=. & dot!=. & age!=checkage2
replace age=checkage2 if dob!=. & dot!=. & age!=checkage2 //5 changes

** Check no missing dxyr so this can be used in analysis
tab dxyr ,m //0 missing

** To match with 2014 format, convert names to lower case and strip possible leading/trailing blanks
replace fname = lower(rtrim(ltrim(itrim(fname)))) //0 changes
replace init = lower(rtrim(ltrim(itrim(init)))) //0 changes
//replace mname = lower(rtrim(ltrim(itrim(mname)))) //0 changes
replace lname = lower(rtrim(ltrim(itrim(lname)))) //0 changes

count //949

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
//list pid cr5id primarysite top hx morph iccc icd10 if siteiarc==.
replace icd10="C509" if pid=="20180247" & cr5id=="T1S1" //1 change
replace siteiarc=29 if pid=="20180247" & cr5id=="T1S1" //1 change

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

tab siteiarchaem ,m //869 missing - correct!
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

tab sitecr5db ,m
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


tab siteicd10 ,m //9 missing - CIN3, beh /0,/1,/2 and MPDs
//list pid cr5id top morph morphology icd10 hx if siteicd10==.
replace hx="MYELOPROLIFERATIVE NEOPLASM" if pid=="20180004" & cr5id=="T1S1"|pid=="20180029" & cr5id=="T1S1"

** Check non-2018 dxyrs are reportable
count if resident==2 //0
count if resident==99 //0
count if recstatus==3 //0
count if sex==9 //0
count if beh!=3 //0
count if persearch>2 //0
count if siteiarc==25 //2 - these are non-melanoma skin cancers but they don't fall into the non-reportable skin cancer category
//list pid cr5id primarysite topography top morph morphology icd10 if siteiarc==25

** Remove reportable-non-2018 dx
drop if dxyr!=2019 //0 deleted

count //

** Removing cases not included for international reporting: if case with MPs ensure record with persearch=1 is not dropped as used in survival dataset
//duplicates tag pid, gen(dup_id)
//list pid cr5id if persearch==1 & (resident==2|resident==99|recstatus==3|sex==9|beh!=3|siteiarc==25), nolabel sepby(pid)

tab eidmp ,m
/*
     CR5 tumour |
         events |      Freq.     Percent        Cum.
----------------+-----------------------------------
  single tumour |        940       99.05       99.05
multiple tumour |          9        0.95      100.00
----------------+-----------------------------------
          Total |        949      100.00
*/
tab persearch ,m
/*
              Person Search |      Freq.     Percent        Cum.
----------------------------+-----------------------------------
                   Done: OK |        940       99.05       99.05
                   Done: MP |          9        0.95      100.00
----------------------------+-----------------------------------
                      Total |        949      100.00
*/

** Change sex label for matching with population data
tab sex ,m
labelbook sex_lab
label drop sex_lab
rename sex sex_old
gen sex=1 if sex_old==2
replace sex=2 if sex_old==1
drop sex_old
label define sex_lab 1 "female" 2 "male" 9 "unknown", modify
label values sex sex_lab
label var sex "Sex"
tab sex ,m


count //949

** Save this corrected dataset with reportable cases and identifiable data
save "`datapath'/version13/3-output/2019_cancer_nonsurvival_identifiable", replace
label data "2019 BNR-Cancer identifiable data - Non-survival Identifiable Dataset"
note: TS This dataset was NOT used for 2018 annual report; it was used for PAB 22-SEPT-2023
note: TS Includes ineligible case definition, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs - these are removed in dataset used for analysis


** Create corrected dataset with reportable cases but de-identified data
drop fname lname natregno init dob resident parish recnum cfdx labnum SurgicalNumber specimen clindets cytofinds md consrpt sxfinds physexam imaging duration onsetint certifier dfc streviewer addr birthdate hospnum comments dobyear dobmonth dobday dob_yr dob_year dobchk sname nrnday nrnid dupnrntag

save "`datapath'/version13/3-output/2019_cancer_nonsurvival_deidentified", replace
label data "2019 BNR-Cancer de-identified data - Non-survival De-identified Dataset"
note: TS This dataset was NOT used for 2019 annual report; it was used for PAB 22-SEPT-2023
note: TS Includes ineligible case definition, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs - these are removed in dataset used for analysis
note: TS Excludes identifiable data but contains unique IDs to allow for linking data back to identifiable data

