** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			4_2014_dc.do
    //  project:				BNR
    //  analysts:				Jacqueline CAMPBELL
    //  date first created      12-MAR-2019
    // 	date last modified	    12-MAR-2019
    //  algorithm task			Cleaning 2014 cancer dataset, Creating site groupings
    //  status                  Completed
    //  objectve                To have one dataset with cleaned and grouped 2014 data for 2014 cancer report.


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
    log using "`logpath'\4_2014_dc.smcl", replace
** HEADER -----------------------------------------------------

* ************************************************************************
* CLEANING
* Using Sync 2014 data cleaning dofile (version02\5_merge_cancer_dc.do)
**************************************************************************

** Load the dataset with recently matched death data
use "`datapath'\version01\1-input\2014_cancer_merge_dc", clear

count //


** Re-assign deathid values to match BNR-DeathDataALL redcap database
count if deathid==. & slc==2 //4 - checked and not found in redcap death data
**list pid deathid fname lname dob natregno nrn if deathid==. & slc==2

** Cleaning cod field based on death data & CR5db
count if cod1a=="" & (cr5cod!="99" & cr5cod!="") //4
replace cod1a=cr5cod if cod1a=="" & (cr5cod!="99" & cr5cod!="") //4 changes

** Updated cod field based on primarysite/hx vs cod1a
count if slc==2 & cod==. //0
count if deceased==1 & cod==. //0

** Check for DCOs to ensure date of tumour = death of date (dot=dod)
count if basis==0 & dot!=dod //0
count if slc==2 & dod==. //0
count if patient==. //0
count if deceased==1 & dod==. //0

** Check for missing date(s) at last contact
count if dlc==. //3
list pid fname lname deceased dod if dlc==.
replace dlc=dod if dlc==. //3 changes

** Check for missing ICD-10 codes
count if icd10=="" //0


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
					 |regexm(icd10,"C12")|regexm(icd10,"C13")|regexm(icd10,"C14")) //34 changes
replace siteicd10=2 if (regexm(icd10,"C15")|regexm(icd10,"C16")|regexm(icd10,"C17") ///
					 |regexm(icd10,"C18")|regexm(icd10,"C19")|regexm(icd10,"C20") ///
					 |regexm(icd10,"C21")|regexm(icd10,"C22")|regexm(icd10,"C23") ///
					 |regexm(icd10,"C24")|regexm(icd10,"C25")|regexm(icd10,"C26")) // changes
replace siteicd10=3 if (regexm(icd10,"C30")|regexm(icd10,"C31")|regexm(icd10,"C32")|regexm(icd10,"C33")|regexm(icd10,"C34")|regexm(icd10,"C37")|regexm(icd10,"C38")|regexm(icd10,"C39")) //57 changes
replace siteicd10=4 if (regexm(icd10,"C40")|regexm(icd10,"C41")) //3 changes
replace siteicd10=5 if siteiarc==24 //7 changes
replace siteicd10=6 if siteiarc==25 //0 changes
replace siteicd10=7 if (regexm(icd10,"C45")|regexm(icd10,"C46")|regexm(icd10,"C47")|regexm(icd10,"C48")|regexm(icd10,"C49")) //12 changes
replace siteicd10=8 if regexm(icd10,"C50") //174 changes
replace siteicd10=9 if (regexm(icd10,"C51")|regexm(icd10,"C52")|regexm(icd10,"C53")|regexm(icd10,"C54")|regexm(icd10,"C55")|regexm(icd10,"C56")|regexm(icd10,"C57")|regexm(icd10,"C58")) //14 changes
replace siteicd10=10 if regexm(icd10,"C61") //216 changes
replace siteicd10=11 if (regexm(icd10,"C60")|regexm(icd10,"C62")|regexm(icd10,"C63")) //5 changes
replace siteicd10=12 if (regexm(icd10,"C64")|regexm(icd10,"C65")|regexm(icd10,"C66")|regexm(icd10,"C67")|regexm(icd10,"C68")) //37 changes
replace siteicd10=13 if (regexm(icd10,"C69")|regexm(icd10,"C70")|regexm(icd10,"C71")|regexm(icd10,"C72")) //6 changes
replace siteicd10=14 if (regexm(icd10,"C73")|regexm(icd10,"C74")|regexm(icd10,"C75")) //12 changes
replace siteicd10=15 if (regexm(icd10,"C76")|regexm(icd10,"C77")|regexm(icd10,"C78")|regexm(icd10,"C79")) //3 changess
replace siteicd10=16 if regexm(icd10,"C80") //43 changes
replace siteicd10=17 if (regexm(icd10,"C81")|regexm(icd10,"C82")|regexm(icd10,"C83") ///
					 |regexm(icd10,"C84")|regexm(icd10,"C85")|regexm(icd10,"C86") ///
					 |regexm(icd10,"C87")|regexm(icd10,"C88")|regexm(icd10,"C89") ///
					 |regexm(icd10,"C90")|regexm(icd10,"C91")|regexm(icd10,"C92") ///
					 |regexm(icd10,"C93")|regexm(icd10,"C94")|regexm(icd10,"C95")|regexm(icd10,"C96")) //34 changes


tab siteicd10 ,m //28 missing - CIN3, beh /0,/1,/2 and MPDs

count //927


** Put variables in order you want them to appear
order pid fname lname init age sex dob natregno resident slc dlc ///
	    parish cr5cod primarysite morph top lat beh hx

save "`datapath'\version01\2-working\2014_cancer_dc" ,replace
label data "BNR-Cancer prepared 2014 data"
notes _dta :These data prepared for 2014 cancer report
