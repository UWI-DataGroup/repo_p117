** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    2_clean_2008.do
    //  project:				        BNR
    //  analysts:				       	Jacqueline CAMPBELL
    //  date first created      12-MAR-2019
    // 	date last modified	    12-MAR-2019
    //  algorithm task			    Cleaning 2008 & 2013 cancer datasets, Creating site groupings
    //  status                  Completed
    //  objectve                To have one dataset with cleaned and grouped 2008 data for inclusion in 2014 cancer report.


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
    log using "`logpath'\2_clean_2008_2013_dc.smcl", replace
** HEADER -----------------------------------------------------

* ************************************************************************
* CLEANING
* Using version02 dofiles created in 2014 data review folder (Sync)
**************************************************************************

** Load the dataset with recently matched death data
use "`datapath'\version01\2-working\2008_2013_cancer_prep_dc.dta", clear

count //2,608

*************************************************
** BLANK & INCONSISTENCY CHECKS - PATIENT TABLE
** CHECKS 1 - 46
** (1) CORRECT INCONSISTENCIES
** (2) EXPORT FOR CANREG5 DATABASE (CLEAN)
*************************************************

** Check 1 (ID)
count if pid==. //0

** Check 2 (Names)
count if fname=="" //0
count if init=="" //25
replace init="99" if init=="" //25 changes
count if lname=="" //0

** Check 3 (DOB, NRN)
count if dob==. //40
count if dob==. & natregno!="" & natregno!="99" & natregno!="999999-9999" //2
replace dob=d(28dec1935) if pid==20080885 //1 change
replace natregno="999999-9999" if pid==20081071 //1 change
count if natregno=="" & dob!=. //0
count if natregno=="" & nrn!="" & nrn!=natregno //0
//missing
gen currentd=c(current_date)
gen double currentdatedob=date(currentd, "DMY", 2017)
drop currentd
format currentdatedob %dD_m_CY
label var currentdate "Current date DOB"
count if dob!=. & dob>currentdatedob //0
//future date
count if length(natregno)<11 & natregno!="" //12
replace natregno="999999-9999" if pid==20080670 //1 change
replace natregno="999999-9999" if pid==20080685 //1 change
replace natregno="999999-9999" if pid==20080790 //2 changes
replace natregno="999999-9999" if pid==20080791 //1 change
replace natregno="999999-9999" if pid==20080792 //1 change
replace natregno="999999-9999" if pid==20080829 //1 change
replace natregno="999999-9999" if pid==20081112 //1 change
replace natregno="430823-0038" if pid==20080225 //1 change
replace natregno="460115-0065" if pid==20080277 //1 change
replace natregno="430121-0045" if pid==20080287 //1 change
replace natregno="470331-0112" if pid==20080297 //1 change
//length error
gen nrnday = substr(natregno,5,2)
count if dob==. & natregno!="" & natregno!="9999999999" & natregno!="999999-9999" & nrnday!="99" //0
//dob missing but full nrn available
gen dob_year = year(dob) if natregno!="" & natregno!="9999999999" & natregno!="999999-9999" & nrnday!="99" & length(natregno)==11
gen yr1=.
replace yr1 = 20 if dob_year>1999
replace yr1 = 19 if dob_year<2000
replace yr1 = 19 if dob_year==.
replace yr1 = 99 if natregno=="99"
list pid dob_year dob natregno yr yr1 if dob_year!=. & dob_year > 1999
gen str nrn2 = substr(natregno,1,6) if natregno!="" & natregno!="9999999999" & natregno!="999999-9999" & nrnday!="99" & length(natregno)==11
**gen nrnlen=length(nrn2)
**drop if nrnlen!=6
destring nrn2, replace
format nrn2 %06.0f
nsplit nrn2, digits(2 2 2) gen(yearnrn2 monthnrn2 daynrn2)
format yearnrn2 monthnrn2 daynrn2 %02.0f
tostring yr1, replace
gen year2 = string(yearnrn2,"%02.0f")
gen nrnyr = substr(yr1,1,2) + substr(year2,1,2)
destring nrnyr, replace
sort nrn2
gen dobchk=mdy(month, day, nrnyr)
format dobchk %dD_m_CY
count if dob!=dobchk & dobchk!=. //20
list pid age natregno nrn dob dobchk dob_year if dob!=dobchk & dobchk!=.
drop day month year nrnyr yr yr1 nrn2
replace dob=dobchk if dob!=dobchk & dobchk!=. //20 changes
//dob does not match nrn

** Check 4 (sex)
count if sex==. //0



**



** Check for dod
count if slc==2 & dod==.

*************************************************
** BLANK & INCONSISTENCY CHECKS - TUMOUR TABLE
** CHECKS 47 - ...
** (1) CORRECT INCONSISTENCIES
** (2) EXPORT FOR CANREG5 DATABASE (CLEAN)
*************************************************

** Check ... (DA)
count if ttda=="" //0
count if length(ttda)<1 //0

** Check ... (primary site, topography)
replace primarysite="OVERLAP-STOMACH INVOLV. BODY,PYLORIC AN." if pid==20080634
replace topography=168 if pid==20080634

* ************************************************************************
* SITE GROUPINGS
* Using ...?
**************************************************************************
count if icd10==""


count //
save "`datapath'\version01\2-working\2008_cancer_clean_dc.dta" ,replace
label data "BNR-Cancer prepared 2008 data"
notes _dta :These data prepared for 2008 inclusion in 2014 cancer report
