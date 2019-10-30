** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          5_prep cancer.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      28-OCT-2019
    // 	date last modified      28-OCT-2019
    //  algorithm task          Preparing 2015 cancer dataset for cleaning; Preparing previous years for combined dataset
    //  status                  Completed
    //  objectve                To have one dataset with cleaned and grouped 2008 & 2013 data for inclusion in 2014 cancer report.
    //  methods                 Clean and update all years' data using IARCcrgTools Check and Multiple Primary

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
    log using "`logpath'\5_prep cancer.smcl", replace
** HEADER -----------------------------------------------------

*******************************
** 2008 Non-survival Dataset **
*******************************

** Load the dataset (2008)
use "`datapath'\version02\1-input\2008_cancer_sites_da_v01", replace

** Remove non-reportable skin cancers
drop if siteiarc==25 //303 deleted

** Remove non-malignant and non-insitu tumours
drop if beh!=2 & beh!=3 //18 deleted

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

export delimited pid sex topography morph beh grade basis dot_iarc dob_iarc age ///
using "`datapath'\version02\2-working\2008_nonsurvival_iarccrgtools.txt", nolabel replace

/*
IARC crg Tools - see SOP for steps on how to perform below checks:

(1) Perform file transfer using '2008_nonsuvival_iarccrgtools.txt'
(2) Perform check using '2008_iarccrgtools_to check.prn'
(3) Perform multiple primary check using ''

Results of IARC Check Program:
(Titles for each data column: pid sex top morph beh grade basis dot dob age)
    888 records processed
	0 errors
        
	26 warnings
        - 7 unlikely hx/site
		- 1 unlikely beh/hx
        - 18 unlikely grade/hx
*/

/*	
Results of IARC MP Program:
	24 excluded (non-malignant)
	28 MPs (multiple tumours)
	 3 Duplicate registrations
*/
/*
tab eidmp pid if eidmp==2
count if eidmp==2 //15
sort pid
list pid top morph cr5id if eidmp==2
count if pid=="20140077"|pid=="20140176" ///
	|pid=="20140339"|pid=="20140474"|pid=="20140490"|pid=="20140526" ///
	|pid=="20140555"|pid=="20140566"|pid=="20140570"|pid=="20140672" ///
	|pid=="20140690"|pid=="20140786"|pid=="20140887"|pid=="20141351"
** 29 - 20140690 T5S1 excluded from IARC MP as it's non-malignant (beh=2)
list pid top morph eidmp cr5id if pid=="20140077"|pid=="20140176" ///
	|pid=="20140339"|pid=="20140474"|pid=="20140490"|pid=="20140526" ///
	|pid=="20140555"|pid=="20140566"|pid=="20140570"|pid=="20140672" ///
	|pid=="20140690"|pid=="20140786"|pid=="20140887"|pid=="20141351"

tab beh ,m //24 in-situ

drop if persearch== //remove duplicate MPs
*/

** Save this corrected dataset
save "`datapath'\version02\2-working\2008_cancer_nonsurvival", replace
label data "2008 BNR-Cancer analysed data - Non-survival Dataset"
note: This dataset was used for 2015 annual report
