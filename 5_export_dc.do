** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			5_export_dc.do
    //  project:				BNR
    //  analysts:				Jacqueline CAMPBELL
    //  date first created      21-MAY-2019
    // 	date last modified	    21-MAY-2019
    //  algorithm task			Creating 2008, 2013 and 2014 dataset to import into CanReg5 db
    //  status                  Completed
    //  objectve                To have one dataset with cleaned data to use CR5 graphs in 2014 annual report.


    ** General algorithm set-up
    version 15
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
    log using "`logpath'\5_export_dc.smcl", replace
** HEADER -----------------------------------------------------

* ************************************************************************
* COMPILE 2008, 2013, 2014 DATA INTO ONE DATASET
**************************************************************************

** Load the dataset with recently matched death data
use "`datapath'\version01\2-working\2008_cancer_rx_outcomes_da_v01", clear
append using "`datapath'\version01\2-working\2013_cancer_rx_outcomes_da_v01"
append using "`datapath'\version01\2-working\2014_cancer_rx_outcomes_da"

/*
NEED to add population dataset for CR5 2014 in 5 yr age groups to CR5db
"`datapath'\version01\2-working\\bb2010_5.dta"
*/

** Format above dataset to match variables in BNRC-2014 CanReg5 database
** PT
rename persearch PERS
rename lname FAMN
rename fname FIRSTN
gen MIDN=""
rename sex SEX
gen BIRTHYR=year(dob)
tostring BIRTHYR, replace
drop dobmonth
gen dobmonth=month(dob)
gen str2 BIRTHMM = string(dobmonth, "%02.0f")
drop dobday
gen dobday=day(dob)
gen str2 BIRTHDD = string(dobday, "%02.0f")
gen BIRTHD=BIRTHYR+BIRTHMM+BIRTHDD
replace BIRTHD="" if BIRTHD=="..." //151 changes
**rename natregno NRN
replace dlc=dod if dod!=. & dlc!=dod //27 changes
gen DLCYR=year(dlc)
tostring DLCYR, replace
gen dlcmonth=month(dlc)
gen str2 DLCMM = string(dlcmonth, "%02.0f")
gen dlcday=day(dlc)
gen str2 DLCDD = string(dlcday, "%02.0f")
gen DLC=DLCYR+DLCMM+DLCDD
replace DLC="" if DLC=="..." //0 changes
rename slc STAT
gen OBSOLETEFLAGPATIENTTABLE=.
gen PATIENTRECORDID=pid+"01"
gen PATIENTUPDATEDBY=""
gen PATIENTUPDATEDATE="20190521"
gen PATIENTRECORDSTATUS=.
gen PATIENTCHECKSTATUS=.
rename pid REGNO
** TT
rename recstatus RECS
gen CHEC=0
rename age AGE
gen str2 ADDR = string(parish, "%02.0f")
gen INCIDYR=year(dot)
tostring INCIDYR, replace
drop dotmonth
gen dotmonth=month(dot)
gen str2 INCIDMM = string(dotmonth, "%02.0f")
drop dotday
gen dotday=day(dot)
gen str2 INCIDDD = string(dotday, "%02.0f")
gen INCID=INCIDYR+INCIDMM+INCIDDD
replace INCID="" if INCID=="..." //0 changes
rename top TOP
rename morph MOR
rename beh BEH
rename basis BAS
rename icd10 I10
gen MPCODE=.
gen MPSEQ=0
gen MPTOT=1
gen UPDATE="20190521"
rename iccc ICCC
gen OBSOLETEFLAGTUMOURTABLE=.
rename eid TUMOURID
gen PATIENTIDTUMOURTABLE=REGNO
gen PATIENTRECORDIDTUMOURTABLE=PATIENTRECORDID
gen TUMOURUPDATEDBY=""
gen TUMOURUNDUPLICATIONSTATUS=.
** ST
destring nftype ,replace
gen NFTYPE=string(nftype, "%02.0f")
drop nftype
//rename nftype NFTYPE
rename sourcename SOURCE
rename labnum LABNO
gen CASNO=99
gen TUMOURIDSOURCETABLE=TUMOURID
gen SOURCERECORDID=TUMOURID+"01"
rename siteiarc SITE

destring TUMOURIDSOURCETABLE, replace
format TUMOURIDSOURCETABLE %14.0g
destring SOURCERECORDID, replace
format SOURCERECORDID %16.0g

destring TUMOURID, replace
format TUMOURID %14.0g
destring PATIENTIDTUMOURTABLE, replace
destring PATIENTRECORDIDTUMOURTABLE, replace
format PATIENTRECORDIDTUMOURTABLE %12.0g

destring REGNO, replace
destring PATIENTRECORDID, replace
format PATIENTRECORDID %12.0g
 
** One correction needed for import to CanReg5 db
replace DLC="20141231" if REGNO==20080196 //see DLC for 2nd patient record
replace DLC="20140701" if REGNO==20080242 //see dot for T2
replace DLC="20140319" if REGNO==20080690 //1 change
count if length(LABNO)>15 //0
//list REGNO LABNO if length(LABNO)>8

sort REGNO
//tab REGNO ,m //no missing REGNOs

count if substr(INCID, 1, 4) == "2008" //829
count if substr(INCID, 1, 4) == "2013" //831
count if substr(INCID, 1, 4) == "2014" //912

drop if regexm(I10,"C44") //0 deleted


** Create and save dataset to be exported
keep NFTYPE	SOURCE	LABNO	CASNO	TUMOURIDSOURCETABLE	SOURCERECORDID	RECS	CHEC	AGE	ADDR	INCID	TOP	MOR	BEH	BAS	I10	MPCODE	MPSEQ	MPTOT	UPDATE	ICCC ///
	 OBSOLETEFLAGTUMOURTABLE	TUMOURID	PATIENTIDTUMOURTABLE PATIENTRECORDIDTUMOURTABLE	TUMOURUPDATEDBY	TUMOURUNDUPLICATIONSTATUS	REGNO	PERS	FAMN	FIRSTN ///
	 SEX	BIRTHD	DLC	STAT	MIDN	OBSOLETEFLAGPATIENTTABLE PATIENTRECORDID	PATIENTUPDATEDBY	PATIENTUPDATEDATE	PATIENTRECORDSTATUS	PATIENTCHECKSTATUS SITE

order NFTYPE SOURCE	LABNO	CASNO	TUMOURIDSOURCETABLE	SOURCERECORDID	RECS	CHEC	AGE	ADDR	INCID	TOP	MOR	BEH	BAS	SITE I10	MPCODE	MPSEQ	MPTOT	UPDATE ///
	  ICCC OBSOLETEFLAGTUMOURTABLE	TUMOURID	PATIENTIDTUMOURTABLE PATIENTRECORDIDTUMOURTABLE	TUMOURUPDATEDBY	TUMOURUNDUPLICATIONSTATUS	REGNO	PERS	FAMN ///
	  FIRSTN SEX BIRTHD	DLC	STAT	MIDN	OBSOLETEFLAGPATIENTTABLE PATIENTRECORDID	PATIENTUPDATEDBY	PATIENTUPDATEDATE	PATIENTRECORDSTATUS	PATIENTCHECKSTATUS
	 
save "`datapath'\version01\2-working\2008_2013_2014_BNR-C_CR5db_dc.dta", replace

export delimited NFTYPE	SOURCE	LABNO	CASNO	TUMOURIDSOURCETABLE	SOURCERECORDID using "`datapath'\version01\2-working\2008_2013_2014_BNR-C_CR5db_dataset_ST.txt", delimiter(tab) nolabel replace

export delimited RECS	CHEC	AGE	ADDR	INCID	TOP	MOR	BEH	BAS	I10	MPCODE MPSEQ	MPTOT	UPDATE	ICCC	OBSOLETEFLAGTUMOURTABLE	TUMOURID	PATIENTIDTUMOURTABLE ///
				 PATIENTRECORDIDTUMOURTABLE	TUMOURUPDATEDBY	TUMOURUNDUPLICATIONSTATUS using "`datapath'\version01\2-working\2008_2013_2014_BNR-C_CR5db_dataset_TT.txt", delimiter(tab) nolabel replace

export delimited REGNO	PERS	FAMN	FIRSTN	SEX	BIRTHD	DLC	STAT	MIDN	OBSOLETEFLAGPATIENTTABLE ///
				 PATIENTRECORDID	PATIENTUPDATEDBY	PATIENTUPDATEDATE	PATIENTRECORDSTATUS	PATIENTCHECKSTATUS using "`datapath'\version01\2-working\2008_2013_2014_BNR-C_CR5db_dataset_PT.txt", delimiter(tab) nolabel replace

** Create 2008, 2013 & 2014 datasets for import into blank CR5db

/*
 To prepare above text files for import to CanReg5 db, manually update the below fields in blank excel book: 

 (1) import into excel the .txt files exported from CanReg5 and change the format from General to Text for the below fields in excel:
		- NFType
		- TumourIDSourceTable
		- SourceRecordID
		- Parish (ADDR)
		- Topography
		- TumourID
		- PatientIDTumourTable
		- PatientRecordIDTumourTable
		- RegistryNumber (REGNO)
		- PatientRecordID

 (2) save each file separately as tab delimited:
		"`datapath'\version01\3-output\2008_2013_2014_ALLBNR-C_CR5db_ST_excel_dc.txt"
		"`datapath'\version01\3-output\2008_2013_2014_ALLBNR-C_CR5db_TT_excel_dc.txt"
		"`datapath'\version01\3-output\2008_2013_2014_ALLBNR-C_CR5db_PT_excel_dc.txt"
*/
