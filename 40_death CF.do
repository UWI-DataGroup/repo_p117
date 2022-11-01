** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          40_death CF.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      07-JUL-2022
    // 	date last modified      07-JUL-2022
    //  algorithm task          Prep and format death data using previously-prepared datasets for import into CR5db
    //  status                  Pending
    //  objective               To have a dataset with cleaned death data with cancer deaths only for:
	//							(1) importing into main CanReg5 database by death year and 
	//							(2) to be used for death trace-back and
	//							(3) merging with other CR5db records that match.
	//							Note: this process to occur after deaths prep for ASMR analysis has been completed
    
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
    log using "`logpath'\40_deathcf_2019+2020.smcl", replace
** HEADER -----------------------------------------------------

**********
** 2019 **
**********
** Load cancer only identifiable death dataset (created in dofile 5x_prep mort yyyy.do)
use "`datapath'\version04\3-output\2019_prep mort_identifiable" ,clear
count //688

** Remove death MPs
drop if did=="T2" //13
count //675
sort dod record_id

** Create RegistryNumber and other ID variables to match with CR5db format
gen id=_n
gen pid=1400 + id
tostring pid ,replace
gen RegistryNumber="2019"+pid
drop id pid

gen TumourIDSourceTable=RegistryNumber+"0101"
gen SourceRecordID=RegistryNumber+"010101"
gen TumourID=RegistryNumber+"0101"
gen PatientIDTumourTable=RegistryNumber
gen PatientRecordIDTumourTable=RegistryNumber+"01"
gen PatientRecordID=RegistryNumber+"01"

** Format each variable according to CR5db format
gen STDataAbstractor="01"
gen	STSourceDate="20220707"
gen	NFType="08"
gen	SourceName="5"
gen	Doctor=""
gen	DoctorAddress=certifieraddr
gen	RecordNumber=record_id
gen	CFDiagnosis=""
gen	LabNumber=""
gen	SurgicalNumber=""
gen	Specimen=""
gen	SampleTakenDate=""
gen	ReceivedDate=""
gen	ReportDate=""
gen	ClinicalDetails=""
gen	CytologicalFindings=""
gen	MicroscopicDescription=""
gen	ConsultationReport=""
gen	SurgicalFindings=""
gen	SurgicalFindingsDate=""
gen	PhysicalExam=""
gen	PhysicalExamDate=""
gen	ImagingResults=""
gen	ImagingResultsDate=""
gen	CausesOfDeath=coddeath

replace durationtxt=. if durationnum==999
gen durationtxt2="DAYS" if durationtxt=="Days":durationtxt_lab
replace durationtxt2="WEEKS" if durationtxt=="Weeks":durationtxt_lab
replace durationtxt2="MONTHS" if durationtxt=="Months":durationtxt_lab
replace durationtxt2="YEARS" if durationtxt=="Years":durationtxt_lab
replace durationnum=99 if durationnum==999
tostring durationnum ,replace
gen	DurationOfIllness=durationnum+" "+durationtxt2
drop durationtxt2

replace onsettxtcod1a=. if onsetnumcod1a==999
gen onsettxtcod1a2="DAYS" if onsettxtcod1a=="Days":onsettxtcod1a_lab
replace onsettxtcod1a2="WEEKS" if onsettxtcod1a=="Weeks":onsettxtcod1a_lab
replace onsettxtcod1a2="MONTHS" if onsettxtcod1a=="Months":onsettxtcod1a_lab
replace onsettxtcod1a2="YEARS" if onsettxtcod1a=="Years":onsettxtcod1a_lab
replace onsetnumcod1a=99 if onsetnumcod1a==999
tostring onsetnumcod1a ,replace
gen	OnsetDeathInterval=onsetnumcod1a+" "+onsettxtcod1a2+";"
drop onsettxtcod1a2

replace onsettxtcod1b=. if onsetnumcod1b==999
gen onsettxtcod1b2="DAYS" if onsettxtcod1b=="Days":onsettxtcod1b_lab
replace onsettxtcod1b2="WEEKS" if onsettxtcod1b=="Weeks":onsettxtcod1b_lab
replace onsettxtcod1b2="MONTHS" if onsettxtcod1b=="Months":onsettxtcod1b_lab
replace onsettxtcod1b2="YEARS" if onsettxtcod1b=="Years":onsettxtcod1b_lab
replace onsetnumcod1b=99 if onsetnumcod1b==999
tostring onsetnumcod1b ,replace
replace	OnsetDeathInterval=OnsetDeathInterval+" "+onsetnumcod1b+" "+onsettxtcod1b2+";"
drop onsettxtcod1b2

replace onsettxtcod1c=. if onsetnumcod1c==999
gen onsettxtcod1c2="DAYS" if onsettxtcod1c=="Days":onsettxtcod1c_lab
replace onsettxtcod1c2="WEEKS" if onsettxtcod1c=="Weeks":onsettxtcod1c_lab
replace onsettxtcod1c2="MONTHS" if onsettxtcod1c=="Months":onsettxtcod1c_lab
replace onsettxtcod1c2="YEARS" if onsettxtcod1c=="Years":onsettxtcod1c_lab
replace onsetnumcod1c=99 if onsetnumcod1c==999
tostring onsetnumcod1c ,replace
replace	OnsetDeathInterval=OnsetDeathInterval+" "+onsetnumcod1c+" "+onsettxtcod1c2+";"
drop onsettxtcod1c2

replace onsettxtcod1d=. if onsetnumcod1d==999
gen onsettxtcod1d2="DAYS" if onsettxtcod1d=="Days":onsettxtcod1d_lab
replace onsettxtcod1d2="WEEKS" if onsettxtcod1d=="Weeks":onsettxtcod1d_lab
replace onsettxtcod1d2="MONTHS" if onsettxtcod1d=="Months":onsettxtcod1d_lab
replace onsettxtcod1d2="YEARS" if onsettxtcod1d=="Years":onsettxtcod1d_lab
replace onsetnumcod1d=99 if onsetnumcod1d==999
tostring onsetnumcod1d ,replace
replace	OnsetDeathInterval=OnsetDeathInterval+" "+onsetnumcod1d+" "+onsettxtcod1d2+";"
drop onsettxtcod1d2

replace onsettxtcod2a=. if onsetnumcod2a==999
gen onsettxtcod2a2="DAYS" if onsettxtcod2a=="Days":onsettxtcod2a_lab
replace onsettxtcod2a2="WEEKS" if onsettxtcod2a=="Weeks":onsettxtcod2a_lab
replace onsettxtcod2a2="MONTHS" if onsettxtcod2a=="Months":onsettxtcod2a_lab
replace onsettxtcod2a2="YEARS" if onsettxtcod2a=="Years":onsettxtcod2a_lab
replace onsetnumcod2a=99 if onsetnumcod2a==999
tostring onsetnumcod2a ,replace
replace	OnsetDeathInterval=OnsetDeathInterval+" "+onsetnumcod2a+" "+onsettxtcod2a2+";"
drop onsettxtcod2a2

replace onsettxtcod2b=. if onsetnumcod2b==999
gen onsettxtcod2b2="DAYS" if onsettxtcod2b=="Days":onsettxtcod2b_lab
replace onsettxtcod2b2="WEEKS" if onsettxtcod2b=="Weeks":onsettxtcod2b_lab
replace onsettxtcod2b2="MONTHS" if onsettxtcod2b=="Months":onsettxtcod2b_lab
replace onsettxtcod2b2="YEARS" if onsettxtcod2b=="Years":onsettxtcod2b_lab
replace onsetnumcod2b=99 if onsetnumcod2b==999
tostring onsetnumcod2b ,replace
replace	OnsetDeathInterval=OnsetDeathInterval+" "+onsetnumcod2b+" "+onsettxtcod2b2+";"
drop onsettxtcod2b2

//list record_id OnsetDeathInterval if OnsetDeathInterval!=""
//list record_id OnsetDeathInterval onsetnumcod1a onsettxtcod1a onsetnumcod1b onsettxtcod1b onsetnumcod1c onsettxtcod1c onsetnumcod1d onsettxtcod1d onsetnumcod2a onsettxtcod2a onsetnumcod2b onsettxtcod2b if OnsetDeathInterval!="" , string(10)

gen	Certifier=certifier
gen	AdmissionDate=""
gen	DateFirstConsultation=""
gen	RTRegDate=""
gen	STReviewer=""
gen	cr5id=""
gen	Recordstatus="0"
gen	Checkstatus="0"
gen	MultiplePrimary=""
gen	MPSeq="0"
gen	MPTot="1"
gen	UpdateDate="20220707"
gen	ObsoleteFlagTumourTable="0"
gen	TumourUpdatedBy="jacqui"
gen	TumourUnduplicationStatus=""
gen	TTDataAbstractor=""
gen	TTAbstractionDate=""
gen	DuplicateCheck=""
gen	Parish=parish
tostring Parish ,replace
replace Parish="0"+Parish if length(Parish)<2

gen	Address=address
gen	Age=age
gen	PrimarySite=""
gen	Topography=""
gen	Histology=""
gen	Morphology=""
gen	Laterality=""
gen	Behaviour=""
gen	Grade=""
gen	BasisOfDiagnosis=""
gen	TNMCatStage=""
gen	TNMAntStage=""
gen	EssTNMCatStage=""
gen	EssTNMAntStage=""
gen	SummaryStaging=""
gen	IncidenceDate=""
gen	DiagnosisYear=dodyear
gen	Consultant=""
gen	ICCCcode=""
gen	ICD10=""
gen	Treatment1=""
gen	Treatment1Date=""
gen	Treatment2=""
gen	Treatment2Date=""
gen	Treatment3=""
gen	Treatment3Date=""
gen	Treatment4=""
gen	Treatment4Date=""
gen	Treatment5=""
gen	Treatment5Date=""
gen	OtherTreatment1=""
gen	OtherTreatment2=""
gen	NoTreatment1=""
gen	NoTreatment2=""
gen	TTReviewer=""
gen	Personsearch=""

replace lname=upper(lname)
replace fname=upper(fname)
replace mname=upper(mname)
gen	LastName=lname
gen	FirstName=fname
gen mname2 = substr(mname,1,1)
gen MiddleInitials=mname2
drop mname2

gen BIRTHYR=year(dob)
tostring BIRTHYR, replace
gen BIRTHMONTH=month(dob)
gen str2 BIRTHMM = string(BIRTHMONTH, "%02.0f")
gen BIRTHDAY=day(dob)
gen str2 BIRTHDD = string(BIRTHDAY, "%02.0f")
gen BIRTHD=BIRTHYR+BIRTHMM+BIRTHDD
replace BIRTHD="" if BIRTHD=="..."
drop BIRTHDAY BIRTHMONTH BIRTHYR BIRTHMM BIRTHDD
rename BIRTHD BirthDate

gen	Sex=1 if sex==2
replace Sex=2 if sex==1
replace Sex=99 if sex==99

gen nrn2 = substr(natregno, 1,6) + "-"+ substr(natregno, -4,4)
replace nrn2="" if nrn2=="-"
gen NRN=nrn2
drop nrn2

gen	HospitalNumber="99"

gen	ResidentStatus=1 if NRN!=""
replace ResidentStatus=9 if NRN==""

gen	StatusLastContact=2

gen DODYR=year(dod)
tostring DODYR, replace
gen DODMONTH=month(dod)
gen str2 DODMM = string(DODMONTH, "%02.0f")
gen DODDAY=day(dod)
gen str2 DODDD = string(DODDAY, "%02.0f")
gen DODD=DODYR+DODMM+DODDD
replace DODD="" if DODD=="..."
drop DODDAY DODMONTH DODYR DODMM DODDD
rename DODD DateOfDeath

gen	DateLastContact=DateOfDeath
gen	Comments="JC 07JUL2022: Imported cancer deaths from ASMR prep Stata dataset."
gen	PTDataAbstractor="01"
gen	PTCasefindingDate="20220707"
gen	ObsoleteFlagPatientTable="0"
gen	PatientUpdatedBy="jacqui"
gen	PatientUpdateDate="20220707"
gen	PatientRecordStatus="0"
gen	PatientCheckStatus=""
gen	RetrievalSource="02"
gen	NotesSeen="0"
gen	NotesSeenDate=""
gen	FurtherRetrievalSource=""
gen	PTReviewer=""
gen	RFAlcohol="99"
gen	AlcoholAmount=""
gen	AlcoholFreq=""
gen	RFSmoking="99"
gen	SmokingAmount=""
gen	SmokingFreq=""
gen	SmokingDuration=""
gen	SmokingDurationFreq=""


order TumourIDSourceTable	SourceRecordID	STDataAbstractor	STSourceDate	NFType	SourceName	Doctor	DoctorAddress	RecordNumber	CFDiagnosis	LabNumber	SurgicalNumber	Specimen	SampleTakenDate	ReceivedDate	ReportDate	ClinicalDetails	CytologicalFindings	MicroscopicDescription	ConsultationReport	SurgicalFindings	SurgicalFindingsDate	PhysicalExam	PhysicalExamDate	ImagingResults	ImagingResultsDate	CausesOfDeath	DurationOfIllness	OnsetDeathInterval	Certifier	AdmissionDate	DateFirstConsultation	RTRegDate	STReviewer	cr5id	Recordstatus	Checkstatus	MultiplePrimary	MPSeq	MPTot	UpdateDate	ObsoleteFlagTumourTable	TumourID	PatientIDTumourTable	PatientRecordIDTumourTable	TumourUpdatedBy	TumourUnduplicationStatus	TTDataAbstractor	TTAbstractionDate	DuplicateCheck	Parish	Address	Age	PrimarySite	Topography	Histology	Morphology	Laterality	Behaviour	Grade	BasisOfDiagnosis	TNMCatStage	TNMAntStage	EssTNMCatStage	EssTNMAntStage	SummaryStaging	IncidenceDate	DiagnosisYear	Consultant	ICCCcode	ICD10	Treatment1	Treatment1Date	Treatment2	Treatment2Date	Treatment3	Treatment3Date	Treatment4	Treatment4Date	Treatment5	Treatment5Date	OtherTreatment1	OtherTreatment2	NoTreatment1	NoTreatment2	TTReviewer	RegistryNumber	Personsearch	LastName	FirstName	MiddleInitials	BirthDate	Sex	NRN	HospitalNumber	ResidentStatus	StatusLastContact	DateLastContact	DateOfDeath	Comments	PTDataAbstractor	PTCasefindingDate	ObsoleteFlagPatientTable	PatientRecordID	PatientUpdatedBy	PatientUpdateDate	PatientRecordStatus	PatientCheckStatus	RetrievalSource	NotesSeen	NotesSeenDate	FurtherRetrievalSource	PTReviewer	RFAlcohol	AlcoholAmount	AlcoholFreq	RFSmoking	SmokingAmount	SmokingFreq	SmokingDuration	SmokingDurationFreq


keep TumourIDSourceTable SourceRecordID STDataAbstractor STSourceDate NFType SourceName Doctor DoctorAddress RecordNumber CFDiagnosis LabNumber SurgicalNumber Specimen SampleTakenDate ReceivedDate ReportDate ClinicalDetails CytologicalFindings MicroscopicDescription ConsultationReport SurgicalFindings SurgicalFindingsDate PhysicalExam PhysicalExamDate ImagingResults ImagingResultsDate CausesOfDeath DurationOfIllness OnsetDeathInterval Certifier AdmissionDate DateFirstConsultation RTRegDate STReviewer cr5id Recordstatus Checkstatus MultiplePrimary MPSeq MPTot UpdateDate ObsoleteFlagTumourTable TumourID PatientIDTumourTable PatientRecordIDTumourTable TumourUpdatedBy TumourUnduplicationStatus TTDataAbstractor TTAbstractionDate DuplicateCheck Parish Address Age PrimarySite Topography Histology Morphology Laterality Behaviour Grade BasisOfDiagnosis TNMCatStage TNMAntStage EssTNMCatStage EssTNMAntStage SummaryStaging IncidenceDate DiagnosisYear Consultant ICCCcode ICD10 Treatment1 Treatment1Date Treatment2 Treatment2Date Treatment3 Treatment3Date Treatment4 Treatment4Date Treatment5 Treatment5Date OtherTreatment1 OtherTreatment2 NoTreatment1 NoTreatment2 TTReviewer RegistryNumber Personsearch LastName FirstName MiddleInitials BirthDate Sex NRN HospitalNumber ResidentStatus StatusLastContact DateLastContact DateOfDeath Comments PTDataAbstractor PTCasefindingDate ObsoleteFlagPatientTable PatientRecordID PatientUpdatedBy PatientUpdateDate PatientRecordStatus PatientCheckStatus RetrievalSource NotesSeen NotesSeenDate FurtherRetrievalSource PTReviewer RFAlcohol AlcoholAmount AlcoholFreq RFSmoking SmokingAmount SmokingFreq SmokingDuration SmokingDurationFreq

sort RegistryNumber

** Export file for import into CR5db
export delimited using "`datapath'\version09\2-working\2019_deathCF.txt", nolabel replace

**********
** 2020 **
**********
** Load cancer only identifiable death dataset (created in dofile 5x_prep mort yyyy.do)
use "`datapath'\version04\3-output\2020_prep mort_identifiable" ,clear
count //669

** Remove death MPs
drop if did=="T2" //16
count //653
sort dod record_id

** Create RegistryNumber and other ID variables to match with CR5db format
gen id=_n
gen pid=1400 + id
tostring pid ,replace
gen RegistryNumber="2020"+pid
drop id pid

gen TumourIDSourceTable=RegistryNumber+"0101"
gen SourceRecordID=RegistryNumber+"010101"
gen TumourID=RegistryNumber+"0101"
gen PatientIDTumourTable=RegistryNumber
gen PatientRecordIDTumourTable=RegistryNumber+"01"
gen PatientRecordID=RegistryNumber+"01"

** Format each variable according to CR5db format
gen STDataAbstractor="01"
gen	STSourceDate="20220707"
gen	NFType="08"
gen	SourceName="5"
gen	Doctor=""
gen	DoctorAddress=certifieraddr
gen	RecordNumber=record_id
gen	CFDiagnosis=""
gen	LabNumber=""
gen	SurgicalNumber=""
gen	Specimen=""
gen	SampleTakenDate=""
gen	ReceivedDate=""
gen	ReportDate=""
gen	ClinicalDetails=""
gen	CytologicalFindings=""
gen	MicroscopicDescription=""
gen	ConsultationReport=""
gen	SurgicalFindings=""
gen	SurgicalFindingsDate=""
gen	PhysicalExam=""
gen	PhysicalExamDate=""
gen	ImagingResults=""
gen	ImagingResultsDate=""
gen	CausesOfDeath=coddeath

replace durationtxt=. if durationnum==999
gen durationtxt2="DAYS" if durationtxt=="Days":durationtxt_lab
replace durationtxt2="WEEKS" if durationtxt=="Weeks":durationtxt_lab
replace durationtxt2="MONTHS" if durationtxt=="Months":durationtxt_lab
replace durationtxt2="YEARS" if durationtxt=="Years":durationtxt_lab
replace durationnum=99 if durationnum==999
tostring durationnum ,replace
gen	DurationOfIllness=durationnum+" "+durationtxt2
drop durationtxt2

replace onsettxtcod1a=. if onsetnumcod1a==999
gen onsettxtcod1a2="DAYS" if onsettxtcod1a=="Days":onsettxtcod1a_lab
replace onsettxtcod1a2="WEEKS" if onsettxtcod1a=="Weeks":onsettxtcod1a_lab
replace onsettxtcod1a2="MONTHS" if onsettxtcod1a=="Months":onsettxtcod1a_lab
replace onsettxtcod1a2="YEARS" if onsettxtcod1a=="Years":onsettxtcod1a_lab
replace onsetnumcod1a=99 if onsetnumcod1a==999
tostring onsetnumcod1a ,replace
gen	OnsetDeathInterval=onsetnumcod1a+" "+onsettxtcod1a2+";"
drop onsettxtcod1a2

replace onsettxtcod1b=. if onsetnumcod1b==999
gen onsettxtcod1b2="DAYS" if onsettxtcod1b=="Days":onsettxtcod1b_lab
replace onsettxtcod1b2="WEEKS" if onsettxtcod1b=="Weeks":onsettxtcod1b_lab
replace onsettxtcod1b2="MONTHS" if onsettxtcod1b=="Months":onsettxtcod1b_lab
replace onsettxtcod1b2="YEARS" if onsettxtcod1b=="Years":onsettxtcod1b_lab
replace onsetnumcod1b=99 if onsetnumcod1b==999
tostring onsetnumcod1b ,replace
replace	OnsetDeathInterval=OnsetDeathInterval+" "+onsetnumcod1b+" "+onsettxtcod1b2+";"
drop onsettxtcod1b2

replace onsettxtcod1c=. if onsetnumcod1c==999
gen onsettxtcod1c2="DAYS" if onsettxtcod1c=="Days":onsettxtcod1c_lab
replace onsettxtcod1c2="WEEKS" if onsettxtcod1c=="Weeks":onsettxtcod1c_lab
replace onsettxtcod1c2="MONTHS" if onsettxtcod1c=="Months":onsettxtcod1c_lab
replace onsettxtcod1c2="YEARS" if onsettxtcod1c=="Years":onsettxtcod1c_lab
replace onsetnumcod1c=99 if onsetnumcod1c==999
tostring onsetnumcod1c ,replace
replace	OnsetDeathInterval=OnsetDeathInterval+" "+onsetnumcod1c+" "+onsettxtcod1c2+";"
drop onsettxtcod1c2

replace onsettxtcod1d=. if onsetnumcod1d==999
gen onsettxtcod1d2="DAYS" if onsettxtcod1d=="Days":onsettxtcod1d_lab
replace onsettxtcod1d2="WEEKS" if onsettxtcod1d=="Weeks":onsettxtcod1d_lab
replace onsettxtcod1d2="MONTHS" if onsettxtcod1d=="Months":onsettxtcod1d_lab
replace onsettxtcod1d2="YEARS" if onsettxtcod1d=="Years":onsettxtcod1d_lab
replace onsetnumcod1d=99 if onsetnumcod1d==999
tostring onsetnumcod1d ,replace
replace	OnsetDeathInterval=OnsetDeathInterval+" "+onsetnumcod1d+" "+onsettxtcod1d2+";"
drop onsettxtcod1d2

replace onsettxtcod2a=. if onsetnumcod2a==999
gen onsettxtcod2a2="DAYS" if onsettxtcod2a=="Days":onsettxtcod2a_lab
replace onsettxtcod2a2="WEEKS" if onsettxtcod2a=="Weeks":onsettxtcod2a_lab
replace onsettxtcod2a2="MONTHS" if onsettxtcod2a=="Months":onsettxtcod2a_lab
replace onsettxtcod2a2="YEARS" if onsettxtcod2a=="Years":onsettxtcod2a_lab
replace onsetnumcod2a=99 if onsetnumcod2a==999
tostring onsetnumcod2a ,replace
replace	OnsetDeathInterval=OnsetDeathInterval+" "+onsetnumcod2a+" "+onsettxtcod2a2+";"
drop onsettxtcod2a2

replace onsettxtcod2b=. if onsetnumcod2b==999
gen onsettxtcod2b2="DAYS" if onsettxtcod2b=="Days":onsettxtcod2b_lab
replace onsettxtcod2b2="WEEKS" if onsettxtcod2b=="Weeks":onsettxtcod2b_lab
replace onsettxtcod2b2="MONTHS" if onsettxtcod2b=="Months":onsettxtcod2b_lab
replace onsettxtcod2b2="YEARS" if onsettxtcod2b=="Years":onsettxtcod2b_lab
replace onsetnumcod2b=99 if onsetnumcod2b==999
tostring onsetnumcod2b ,replace
replace	OnsetDeathInterval=OnsetDeathInterval+" "+onsetnumcod2b+" "+onsettxtcod2b2+";"
drop onsettxtcod2b2

//list record_id OnsetDeathInterval if OnsetDeathInterval!=""
//list record_id OnsetDeathInterval onsetnumcod1a onsettxtcod1a onsetnumcod1b onsettxtcod1b onsetnumcod1c onsettxtcod1c onsetnumcod1d onsettxtcod1d onsetnumcod2a onsettxtcod2a onsetnumcod2b onsettxtcod2b if OnsetDeathInterval!="" , string(10)

gen	Certifier=certifier
gen	AdmissionDate=""
gen	DateFirstConsultation=""
gen	RTRegDate=""
gen	STReviewer=""
gen	cr5id=""
gen	Recordstatus="0"
gen	Checkstatus="0"
gen	MultiplePrimary=""
gen	MPSeq="0"
gen	MPTot="1"
gen	UpdateDate="20220707"
gen	ObsoleteFlagTumourTable="0"
gen	TumourUpdatedBy="jacqui"
gen	TumourUnduplicationStatus=""
gen	TTDataAbstractor=""
gen	TTAbstractionDate=""
gen	DuplicateCheck=""
gen	Parish=parish
tostring Parish ,replace
replace Parish="0"+Parish if length(Parish)<2

gen	Address=address
gen	Age=age
gen	PrimarySite=""
gen	Topography=""
gen	Histology=""
gen	Morphology=""
gen	Laterality=""
gen	Behaviour=""
gen	Grade=""
gen	BasisOfDiagnosis=""
gen	TNMCatStage=""
gen	TNMAntStage=""
gen	EssTNMCatStage=""
gen	EssTNMAntStage=""
gen	SummaryStaging=""
gen	IncidenceDate=""
gen	DiagnosisYear=dodyear
gen	Consultant=""
gen	ICCCcode=""
gen	ICD10=""
gen	Treatment1=""
gen	Treatment1Date=""
gen	Treatment2=""
gen	Treatment2Date=""
gen	Treatment3=""
gen	Treatment3Date=""
gen	Treatment4=""
gen	Treatment4Date=""
gen	Treatment5=""
gen	Treatment5Date=""
gen	OtherTreatment1=""
gen	OtherTreatment2=""
gen	NoTreatment1=""
gen	NoTreatment2=""
gen	TTReviewer=""
gen	Personsearch=""

replace lname=upper(lname)
replace fname=upper(fname)
replace mname=upper(mname)
gen	LastName=lname
gen	FirstName=fname
gen mname2 = substr(mname,1,1)
gen MiddleInitials=mname2
drop mname2

gen BIRTHYR=year(dob)
tostring BIRTHYR, replace
gen BIRTHMONTH=month(dob)
gen str2 BIRTHMM = string(BIRTHMONTH, "%02.0f")
gen BIRTHDAY=day(dob)
gen str2 BIRTHDD = string(BIRTHDAY, "%02.0f")
gen BIRTHD=BIRTHYR+BIRTHMM+BIRTHDD
replace BIRTHD="" if BIRTHD=="..."
drop BIRTHDAY BIRTHMONTH BIRTHYR BIRTHMM BIRTHDD
rename BIRTHD BirthDate

gen	Sex=1 if sex==2
replace Sex=2 if sex==1
replace Sex=99 if sex==99

gen nrn2 = substr(natregno, 1,6) + "-"+ substr(natregno, -4,4)
replace nrn2="" if nrn2=="-"
gen NRN=nrn2
drop nrn2

gen	HospitalNumber="99"

gen	ResidentStatus=1 if NRN!=""
replace ResidentStatus=9 if NRN==""

gen	StatusLastContact=2

gen DODYR=year(dod)
tostring DODYR, replace
gen DODMONTH=month(dod)
gen str2 DODMM = string(DODMONTH, "%02.0f")
gen DODDAY=day(dod)
gen str2 DODDD = string(DODDAY, "%02.0f")
gen DODD=DODYR+DODMM+DODDD
replace DODD="" if DODD=="..."
drop DODDAY DODMONTH DODYR DODMM DODDD
rename DODD DateOfDeath

gen	DateLastContact=DateOfDeath
gen	Comments="JC 07JUL2022: Imported cancer deaths from ASMR prep Stata dataset."
gen	PTDataAbstractor="01"
gen	PTCasefindingDate="20220707"
gen	ObsoleteFlagPatientTable="0"
gen	PatientUpdatedBy="jacqui"
gen	PatientUpdateDate="20220707"
gen	PatientRecordStatus="0"
gen	PatientCheckStatus=""
gen	RetrievalSource="02"
gen	NotesSeen="0"
gen	NotesSeenDate=""
gen	FurtherRetrievalSource=""
gen	PTReviewer=""
gen	RFAlcohol="99"
gen	AlcoholAmount=""
gen	AlcoholFreq=""
gen	RFSmoking="99"
gen	SmokingAmount=""
gen	SmokingFreq=""
gen	SmokingDuration=""
gen	SmokingDurationFreq=""


order TumourIDSourceTable	SourceRecordID	STDataAbstractor	STSourceDate	NFType	SourceName	Doctor	DoctorAddress	RecordNumber	CFDiagnosis	LabNumber	SurgicalNumber	Specimen	SampleTakenDate	ReceivedDate	ReportDate	ClinicalDetails	CytologicalFindings	MicroscopicDescription	ConsultationReport	SurgicalFindings	SurgicalFindingsDate	PhysicalExam	PhysicalExamDate	ImagingResults	ImagingResultsDate	CausesOfDeath	DurationOfIllness	OnsetDeathInterval	Certifier	AdmissionDate	DateFirstConsultation	RTRegDate	STReviewer	cr5id	Recordstatus	Checkstatus	MultiplePrimary	MPSeq	MPTot	UpdateDate	ObsoleteFlagTumourTable	TumourID	PatientIDTumourTable	PatientRecordIDTumourTable	TumourUpdatedBy	TumourUnduplicationStatus	TTDataAbstractor	TTAbstractionDate	DuplicateCheck	Parish	Address	Age	PrimarySite	Topography	Histology	Morphology	Laterality	Behaviour	Grade	BasisOfDiagnosis	TNMCatStage	TNMAntStage	EssTNMCatStage	EssTNMAntStage	SummaryStaging	IncidenceDate	DiagnosisYear	Consultant	ICCCcode	ICD10	Treatment1	Treatment1Date	Treatment2	Treatment2Date	Treatment3	Treatment3Date	Treatment4	Treatment4Date	Treatment5	Treatment5Date	OtherTreatment1	OtherTreatment2	NoTreatment1	NoTreatment2	TTReviewer	RegistryNumber	Personsearch	LastName	FirstName	MiddleInitials	BirthDate	Sex	NRN	HospitalNumber	ResidentStatus	StatusLastContact	DateLastContact	DateOfDeath	Comments	PTDataAbstractor	PTCasefindingDate	ObsoleteFlagPatientTable	PatientRecordID	PatientUpdatedBy	PatientUpdateDate	PatientRecordStatus	PatientCheckStatus	RetrievalSource	NotesSeen	NotesSeenDate	FurtherRetrievalSource	PTReviewer	RFAlcohol	AlcoholAmount	AlcoholFreq	RFSmoking	SmokingAmount	SmokingFreq	SmokingDuration	SmokingDurationFreq


keep TumourIDSourceTable SourceRecordID STDataAbstractor STSourceDate NFType SourceName Doctor DoctorAddress RecordNumber CFDiagnosis LabNumber SurgicalNumber Specimen SampleTakenDate ReceivedDate ReportDate ClinicalDetails CytologicalFindings MicroscopicDescription ConsultationReport SurgicalFindings SurgicalFindingsDate PhysicalExam PhysicalExamDate ImagingResults ImagingResultsDate CausesOfDeath DurationOfIllness OnsetDeathInterval Certifier AdmissionDate DateFirstConsultation RTRegDate STReviewer cr5id Recordstatus Checkstatus MultiplePrimary MPSeq MPTot UpdateDate ObsoleteFlagTumourTable TumourID PatientIDTumourTable PatientRecordIDTumourTable TumourUpdatedBy TumourUnduplicationStatus TTDataAbstractor TTAbstractionDate DuplicateCheck Parish Address Age PrimarySite Topography Histology Morphology Laterality Behaviour Grade BasisOfDiagnosis TNMCatStage TNMAntStage EssTNMCatStage EssTNMAntStage SummaryStaging IncidenceDate DiagnosisYear Consultant ICCCcode ICD10 Treatment1 Treatment1Date Treatment2 Treatment2Date Treatment3 Treatment3Date Treatment4 Treatment4Date Treatment5 Treatment5Date OtherTreatment1 OtherTreatment2 NoTreatment1 NoTreatment2 TTReviewer RegistryNumber Personsearch LastName FirstName MiddleInitials BirthDate Sex NRN HospitalNumber ResidentStatus StatusLastContact DateLastContact DateOfDeath Comments PTDataAbstractor PTCasefindingDate ObsoleteFlagPatientTable PatientRecordID PatientUpdatedBy PatientUpdateDate PatientRecordStatus PatientCheckStatus RetrievalSource NotesSeen NotesSeenDate FurtherRetrievalSource PTReviewer RFAlcohol AlcoholAmount AlcoholFreq RFSmoking SmokingAmount SmokingFreq SmokingDuration SmokingDurationFreq

sort RegistryNumber

** Export file for import into CR5db
export delimited using "`datapath'\version09\2-working\2020_deathCF.txt", nolabel replace

** JC 07JUL2022: OLD METHOD BELOW
/*
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			40_death CF.do
    //  project:				BNR
    //  analysts:				Jacqueline CAMPBELL
    //  date first created      19-MAY-2021
    //  date last modified	    19-MAY-2021
    //  algorithm task			Generating list of cancer and non-cancer deaths for case-finding (CF) process
    //  status                  Completed
    //  objectve                Exporting all 2016 deaths from REDCap death db to generate list of all possible cancer deaths for that year.


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
    log using "`logpath'\40_death CF_2016.smcl", replace
** HEADER -----------------------------------------------------

/*
	(1) This dofile saved in PROJECTS p_117
	(2) Import data from REDCap into Stata via redcap API using project called 'BNR-CVD'
	(3) A user must have API rights to the redcap project for this process to work
*/
version 16.1
set more off
clear 

**********************
** IMPORT DATA FROM **
** REDCAP TO STATA  **
**********************
local token "insert API token here"
local outfile "exported_deaths.csv"

shell curl		///
	--output `outfile' 		///
	--form token=`token'	///
	--form content=record 	///
	--form format=csv 		///
	--form type=flat 		///
	--form event=redcap_event_name ///
	--form fields[]=record_id ///
	--form fields[]=pname ///
	--form fields[]=address ///
	--form fields[]=sex ///
	--form fields[]=age ///
	--form fields[]=nrn ///
	--form fields[]=dod ///
	--form fields[]=dodyear ///
	--form fields[]=cod1a ///
	--form fields[]=cod1b ///
	--form fields[]=cod1c ///
	--form fields[]=cod1d ///
	--form fields[]=cod2a ///
	--form fields[]=cod2b ///
	--form fields[]=pod ///
	--form fields[]=certifier ///
	--form fields[]=certifieraddr "https://caribdata.org/redcap/api/"

import delimited `outfile'

** Format
format nrn %12.0g
replace dod=subinstr(dod,"-","",.)
gen dod2=date(dod, "YMD")
format dod2 %dD_m_CY
drop dod
rename dod2 dod

** Filter data for 2018 deaths only
drop dodyear
gen dodyear=year(dod)
drop if dodyear!=2016

** Now generate a new variable which will select out all the potential cancers
gen cancer=.
label define cancer_lab 1 "cancer" 2 "not cancer", modify
label values cancer cancer_lab
label var cancer "cancer diagnoses"
label var record_id "Event identifier for registry deaths"

** searching cod1a for these terms
replace cod1a="99" if cod1a=="999"
replace cod1b="99" if cod1b=="999"
replace cod1c="99" if cod1c=="999"
replace cod1d="99" if cod1d=="999"
replace cod2a="99" if cod2a=="999"
replace cod2b="99" if cod2b=="999"
count if cod1c!="99"
count if cod1d!="99"
count if cod2a!="99"
count if cod2b!="99"
** Create variable with combined CODs
gen coddeath=cod1a+" "+cod1b+" "+cod1c+" "+cod1d+" "+cod2a+" "+cod2b
replace coddeath=subinstr(coddeath,"99 ","",.) //4990
replace coddeath=subinstr(coddeath," 99","",.) //4591
** Identify cancer deaths using variable called 'cancer'
replace cancer=1 if regexm(coddeath, "CANCER") & cancer==.
replace cancer=1 if regexm(coddeath, "TUMOUR") &  cancer==.
replace cancer=1 if regexm(coddeath, "TUMOR") &  cancer==.
replace cancer=1 if regexm(coddeath, "MALIGNANT") &  cancer==.
replace cancer=1 if regexm(coddeath, "MALIGNANCY") &  cancer==.
replace cancer=1 if regexm(coddeath, "NEOPLASM") &  cancer==.
replace cancer=1 if regexm(coddeath, "CARCINOMA") &  cancer==.
replace cancer=1 if regexm(coddeath, "CARCIMONA") &  cancer==.
replace cancer=1 if regexm(coddeath, "CARINOMA") &  cancer==.
replace cancer=1 if regexm(coddeath, "MYELOMA") &  cancer==.
replace cancer=1 if regexm(coddeath, "LYMPHOMA") &  cancer==.
replace cancer=1 if regexm(coddeath, "LYMPHOMIA") &  cancer==.
replace cancer=1 if regexm(coddeath, "LYMPHONA") &  cancer==.
replace cancer=1 if regexm(coddeath, "SARCOMA") &  cancer==.
replace cancer=1 if regexm(coddeath, "TERATOMA") &  cancer==.
replace cancer=1 if regexm(coddeath, "LEUKEMIA") &  cancer==.
replace cancer=1 if regexm(coddeath, "LEUKAEMIA") &  cancer==.
replace cancer=1 if regexm(coddeath, "HEPATOMA") &  cancer==.
replace cancer=1 if regexm(coddeath, "CARANOMA PROSTATE") &  cancer==.
replace cancer=1 if regexm(coddeath, "MENINGIOMA") &  cancer==.
replace cancer=1 if regexm(coddeath, "MYELOSIS") &  cancer==.
replace cancer=1 if regexm(coddeath, "MYELOFIBROSIS") &  cancer==.
replace cancer=1 if regexm(coddeath, "CYTHEMIA") &  cancer==.
replace cancer=1 if regexm(coddeath, "CYTOSIS") &  cancer==.
replace cancer=1 if regexm(coddeath, "BLASTOMA") &  cancer==.
replace cancer=1 if regexm(coddeath, "METASTATIC") &  cancer==.
replace cancer=1 if regexm(coddeath, "MASS") &  cancer==.
replace cancer=1 if regexm(coddeath, "METASTASES") &  cancer==.
replace cancer=1 if regexm(coddeath, "METASTASIS") &  cancer==.
replace cancer=1 if regexm(coddeath, "REFRACTORY") &  cancer==.
replace cancer=1 if regexm(coddeath, "FUNGOIDES") &  cancer==.
replace cancer=1 if regexm(coddeath, "HODGKIN") &  cancer==.
replace cancer=1 if regexm(coddeath, "MELANOMA") &  cancer==.
replace cancer=1 if regexm(coddeath,"MYELODYS") &  cancer==.
replace cancer=1 if regexm(coddeath,"GLIOMA") &  cancer==.
replace cancer=1 if regexm(coddeath,"MULTIFORME") &  cancer==.

** Strip possible leading/trailing blanks in cod1a
replace coddeath = rtrim(ltrim(itrim(coddeath)))

replace cancer=2 if cancer==.

** Check that all cancer CODs for 2014 are eligible
sort coddeath record_id

tab cancer ,m 

** Use below code to automate file names using current date
local listdate = string( d(`c(current_date)'), "%dCYND" )
capture export_excel record_id pname sex age nrn coddeath address pod certifier certifieraddr dod if cancer==1 using "`datapath'\version05\3-output\2016DeathCF`listdate'.xlsx", sheet("Cancer") firstrow(variables)

capture export_excel record_id pname sex age nrn coddeath address pod certifier certifieraddr dod if cancer==2 using "`datapath'\version05\3-output\2016DeathCF`listdate'.xlsx", sheet("Non Cancer") firstrow(variables)

/*
    Since this dofile is pulling data via the REDCap API, the above code needs to be slightly adjusted for it to run as noted below. 
    Also the dofile needs to be placed in the same folder on your system where the Stata programme application file is located:
*/
/*
	(1) This dofile saved in PROJECTS p_117
	(2) Import data from REDCap into Stata via redcap API using project called 'BNR-CVD'
	(3) A user must have API rights to the redcap project for this process to work
*/
version 16.1
set more off
clear 

**********************
** IMPORT DATA FROM **
** REDCAP TO STATA  **
**********************
local token "insert API token here"
local outfile "exported_deaths.csv"

shell curl		///
	--output `outfile' 		///
	--form token=`token'	///
	--form content=record 	///
	--form format=csv 		///
	--form type=flat 		///
	--form event=redcap_event_name ///
	--form fields[]=record_id ///
	--form fields[]=pname ///
	--form fields[]=address ///
	--form fields[]=sex ///
	--form fields[]=age ///
	--form fields[]=nrn ///
	--form fields[]=dod ///
	--form fields[]=dodyear ///
	--form fields[]=cod1a ///
	--form fields[]=cod1b ///
	--form fields[]=cod1c ///
	--form fields[]=cod1d ///
	--form fields[]=cod2a ///
	--form fields[]=cod2b ///
	--form fields[]=pod ///
	--form fields[]=certifier ///
	--form fields[]=certifieraddr "https://caribdata.org/redcap/api/"

import delimited `outfile'

** Format
format nrn %12.0g
replace dod=subinstr(dod,"-","",.)
gen dod2=date(dod, "YMD")
format dod2 %dD_m_CY
drop dod
rename dod2 dod

** Filter data for 2018 deaths only
drop dodyear
gen dodyear=year(dod)
drop if dodyear!=2016

** Now generate a new variable which will select out all the potential cancers
gen cancer=.
label define cancer_lab 1 "cancer" 2 "not cancer", modify
label values cancer cancer_lab
label var cancer "cancer diagnoses"
label var record_id "Event identifier for registry deaths"

** searching cod1a for these terms
replace cod1a="99" if cod1a=="999"
replace cod1b="99" if cod1b=="999"
replace cod1c="99" if cod1c=="999"
replace cod1d="99" if cod1d=="999"
replace cod2a="99" if cod2a=="999"
replace cod2b="99" if cod2b=="999"
count if cod1c!="99"
count if cod1d!="99"
count if cod2a!="99"
count if cod2b!="99"
** Create variable with combined CODs
gen coddeath=cod1a+" "+cod1b+" "+cod1c+" "+cod1d+" "+cod2a+" "+cod2b
replace coddeath=subinstr(coddeath,"99 ","",.) //4990
replace coddeath=subinstr(coddeath," 99","",.) //4591
** Identify cancer deaths using variable called 'cancer'
replace cancer=1 if regexm(coddeath, "CANCER") & cancer==.
replace cancer=1 if regexm(coddeath, "TUMOUR") &  cancer==.
replace cancer=1 if regexm(coddeath, "TUMOR") &  cancer==.
replace cancer=1 if regexm(coddeath, "MALIGNANT") &  cancer==.
replace cancer=1 if regexm(coddeath, "MALIGNANCY") &  cancer==.
replace cancer=1 if regexm(coddeath, "NEOPLASM") &  cancer==.
replace cancer=1 if regexm(coddeath, "CARCINOMA") &  cancer==.
replace cancer=1 if regexm(coddeath, "CARCIMONA") &  cancer==.
replace cancer=1 if regexm(coddeath, "CARINOMA") &  cancer==.
replace cancer=1 if regexm(coddeath, "MYELOMA") &  cancer==.
replace cancer=1 if regexm(coddeath, "LYMPHOMA") &  cancer==.
replace cancer=1 if regexm(coddeath, "LYMPHOMIA") &  cancer==.
replace cancer=1 if regexm(coddeath, "LYMPHONA") &  cancer==.
replace cancer=1 if regexm(coddeath, "SARCOMA") &  cancer==.
replace cancer=1 if regexm(coddeath, "TERATOMA") &  cancer==.
replace cancer=1 if regexm(coddeath, "LEUKEMIA") &  cancer==.
replace cancer=1 if regexm(coddeath, "LEUKAEMIA") &  cancer==.
replace cancer=1 if regexm(coddeath, "HEPATOMA") &  cancer==.
replace cancer=1 if regexm(coddeath, "CARANOMA PROSTATE") &  cancer==.
replace cancer=1 if regexm(coddeath, "MENINGIOMA") &  cancer==.
replace cancer=1 if regexm(coddeath, "MYELOSIS") &  cancer==.
replace cancer=1 if regexm(coddeath, "MYELOFIBROSIS") &  cancer==.
replace cancer=1 if regexm(coddeath, "CYTHEMIA") &  cancer==.
replace cancer=1 if regexm(coddeath, "CYTOSIS") &  cancer==.
replace cancer=1 if regexm(coddeath, "BLASTOMA") &  cancer==.
replace cancer=1 if regexm(coddeath, "METASTATIC") &  cancer==.
replace cancer=1 if regexm(coddeath, "MASS") &  cancer==.
replace cancer=1 if regexm(coddeath, "METASTASES") &  cancer==.
replace cancer=1 if regexm(coddeath, "METASTASIS") &  cancer==.
replace cancer=1 if regexm(coddeath, "REFRACTORY") &  cancer==.
replace cancer=1 if regexm(coddeath, "FUNGOIDES") &  cancer==.
replace cancer=1 if regexm(coddeath, "HODGKIN") &  cancer==.
replace cancer=1 if regexm(coddeath, "MELANOMA") &  cancer==.
replace cancer=1 if regexm(coddeath,"MYELODYS") &  cancer==.
replace cancer=1 if regexm(coddeath,"GLIOMA") &  cancer==.
replace cancer=1 if regexm(coddeath,"MULTIFORME") &  cancer==.

** Strip possible leading/trailing blanks in cod1a
replace coddeath = rtrim(ltrim(itrim(coddeath)))

replace cancer=2 if cancer==.

** Check that all cancer CODs for 2014 are eligible
sort coddeath record_id

tab cancer ,m 

** Use below code to automate file names using current date
local listdate = string( d(`c(current_date)'), "%dCYND" )
capture export_excel record_id pname sex age nrn coddeath address pod certifier certifieraddr dod if cancer==1 using "X:/The University of the West Indies/DataGroup - repo_data/data_p117\version05\3-output\2016DeathCF`listdate'.xlsx", sheet("Cancer") firstrow(variables)

capture export_excel record_id pname sex age nrn coddeath address pod certifier certifieraddr dod if cancer==2 using "X:/The University of the West Indies/DataGroup - repo_data/data_p117\version05\3-output\2016DeathCF`listdate'.xlsx", sheet("Non Cancer") firstrow(variables)

***********************************************************************************************************
** JC 01nov2022: Attempting to update this process now that cancer incidence data collection has caught up with death data collection

** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          40_death CF.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      01-NOV-2022
    // 	date last modified      01-NOV-2022
    //  algorithm task          Prep and format death data using previously-prepared datasets for import into CR5db
    //  status                  Pending
    //  objective               To have a dataset with cleaned death data with cancer deaths only for:
	//							(1) importing into main CanReg5 database by death year and 
	//							(2) to be used for death trace-back and
	//							(3) merging with other CR5db records that match.
	//							Note: this process to occur after deaths prep for ASMR analysis has been completed
    
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
    log using "`logpath'\40_deathcf_2019+2020.smcl", replace
** HEADER -----------------------------------------------------

******************
**  ALL YEARS   **
** Incidence ds **
******************
** LOAD and SAVE the SOURCE+TUMOUR+PATIENT dataset from cancer duplicates V06 process (Source_+Tumour+Patient tables)
insheet using "`datapath'\version07\1-input\2022-10-28_MAIN Source+Tumour+Patient_KWG.txt"

** Format the IDs from the CR5db dataset
format tumourid %14.0g
format tumouridsourcetable %14.0g
format sourcerecordid %16.0g

** JC 31oct2022 - incorrectly formatted Reg #s and an incorrect merge of a patient record found so need to temporarily assign correctly formatted Reg #s until KWG is able to correct these in his main db
generate byte non_numeric_reg = indexnot(registrynumber, "0123456789.-")
count if non_numeric_reg //15 (8)
list registrynumber patientrecordid sourcerecordid cr5id if non_numeric_reg
count if length(registrynumber)<8 //4 (2)
list registrynumber patientrecordid sourcerecordid cr5id if length(registrynumber)<8

replace registrynumber="20220001" if registrynumber=="2020/064"
replace registrynumber="20220002" if registrynumber=="2020/177"
replace registrynumber="20220003" if registrynumber=="2020/178"
replace registrynumber="20220004" if registrynumber=="2020/398"
replace registrynumber="20220005" if registrynumber=="2021/082"
replace registrynumber="20220006" if registrynumber=="2021/090"
replace registrynumber="20220007" if registrynumber=="2021/092"
replace registrynumber="20220008" if registrynumber=="2021/101"
replace registrynumber="20220009" if registrynumber=="" & patientrecordid==2021028901
replace registrynumber="20220010" if registrynumber=="" & patientrecordid==2021500101
replace registrynumber="20220011" if registrynumber=="99" & patientrecordid==2020116401
replace registrynumber="20220012" if registrynumber=="99" & patientrecordid==2020065001
drop patientrecordid
destring registrynumber ,replace

** Remove non-2019 non-2020 cases
count if diagnosisyear==. //1
replace diagnosisyear=2021 if registrynumber==20212236
drop if diagnosisyear!=2019 & diagnosisyear!=2020 //16,746
count //3945

** Remove hyphen in NRN to match with previous and death datasets
count if regexm(nrn,"-") //3924
replace nrn=subinstr(nrn,"-","",.) if regexm(nrn,"-") //3924 changes

** Format variables used in identifying matches
label var nftype "NFType"
label define nftype_lab 1 "Hospital" 2 "Polyclinic/Dist.Hosp." 3 "Lab-Path" 4 "Lab-Cyto" 5 "Lab-Haem" 6 "Imaging" ///
						7 "Private Physician" 8 "Death Certif./Post Mort." 9 "QEH Death Rec Bks" 10 "RT Reg. Bk" ///
						11 "Haem NF" 12 "Bay View Bk" 13 "Other" 14 "Unknown" 15 "NFs" 16 "Phone Call" ///
						17 "MEDDATA" 18 "QEH A&E List" , modify
label values nftype nftype_lab

label var sourcename "SourceName"
label define sourcename_lab 1 "QEH" 2 "Bay View" 3 "Private Physician" 4 "IPS-ARS" 5 "Death Registry" ///
							6 "Polyclinic" 7 "BNR Database" 8 "Other" 9 "Unknown" , modify
label values sourcename sourcename_lab

rename registrynumber pid
gen incids=1
save "`datapath'\version09\3-output\deathcf_prep_cr5" ,replace

clear

*****************
** 2019 + 2020 **
**  Death ds   **
*****************
** Load cancer only identifiable death dataset (created in dofile 5x_prep mort yyyy.do for annual report process)
use "`datapath'\version09\3-output\2019+2020_prep mort_identifiable" ,clear
rename * dd_*
count //1357
gen deathds=1
drop if dd_did=="T2" //29 deleted
rename dd_record_id dd_deathid

append using "`datapath'\version09\3-output\deathcf_prep_cr5"

count //5273

replace nrn=dd_natregno if nrn=="" & dd_natregno!="" //1307
replace dd_fname=firstname if dd_fname=="" & firstname!="" //3382
replace dd_lname=lastname if dd_lname=="" & lastname!="" //3382

** Check NRN is correctly formatted in prep for duplicate check
count if length(nrn)==9 //0
count if length(nrn)==8 //0
count if length(nrn)==7 //0

replace nrn="" if nrn=="9999999999" //563

** Identify possible matches using NRN
preserve
drop if nrn=="" //remove blank/missing NRNs as these will be flagged as duplicates of each other
// deleted
sort nrn 
quietly by nrn : gen dup = cond(_N==1,0,_n)
sort nrn dd_lname dd_fname pid dd_deathid 
count if dup>0 //2996 - review these in Stata's Browse/Edit window
order pid dd_deathid nftype sourcename nrn dd_fname dd_lname firstname lastname cr5id dd_age age dd_dodyear diagnosisyear dd_coddeath histology
//check there are no duplicate NRNs in the death ds as then it won't merge in 20d_final clean.do
//keep if deathds==1 & dup>0 //20,655 deleted
restore