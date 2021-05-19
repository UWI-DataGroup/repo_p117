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
    log using "`logpath'\40_death CF.smcl", replace
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
drop if dodyear!=2018

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
capture export_excel record_id pname sex age nrn coddeath address pod certifier certifieraddr dod if cancer==1 using "`datapath'\version05\3-output\2016DeathCF`listdate'.xlsx", sheet("Cancer") firstrow(varlabels)

capture export_excel record_id pname sex age nrn coddeath address pod certifier certifieraddr dod if cancer==2 using "`datapath'\version05\3-output\2016DeathCF`listdate'.xlsx", sheet("Non Cancer") firstrow(varlabels)

