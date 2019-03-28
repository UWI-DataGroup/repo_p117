** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			2_all_deaths_dp.do
    //  project:				BNR
    //  analysts:				Jacqueline CAMPBELL
    //  date first created      19-MAR-2019
    // 	date last modified	    19-MAR-2019
    //  algorithm task			Merging death datasets, Creating one death dataset
    //  status                  Completed
    //  objectve                To have one dataset with 2008-2017 death data with redcap (BNR-DeathDataALL) record_id = deathid

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
    log using "`logpath'\2_all_deaths_dp.smcl", replace
** HEADER -----------------------------------------------------

**************************************
** DATA PREPARATION  
**************************************

** LOAD the national registry deaths 2008-2017 dataset (prior to REDCap)
import excel using "`datapath'\version01\1-input\BNRDeathDataALL_DATA_2019-03-19_1012.xlsx" , firstrow case(lower) clear

count //24,188
format nrn %12.0g
tostring nrn, replace

**format dod %tdCCYY-NN-DD
**format regdate %tdCCYY-NN-DD //importing as string as regdate for deathid 19520 is incorrect - corrected in excel raw data.

save "`datapath'\version01\2-working\2008-2017_import_deaths_dp" ,replace

** LOAD the national registry deaths 2008-2017 dataset (prior to REDCap)
import excel using "`datapath'\version01\1-input\Cleaned_DeathData_2008-2017_JC_20190319_excel.xlsx" , firstrow case(lower) clear

count //24,188

rename record_id record_idextra
rename cfdate cfdateextra
rename cfda cfdaextra
rename certtype certtypeextra
**rename regnum regnumextra
rename district districtextra
**rename pname pnameextra
rename address addressextra
rename parish parishextra
rename sex sexextra
rename age ageextra
rename nrnnd nrnndextra
rename nrn nrnextra
rename mstatus mstatusextra
rename occu occuextra
rename durationnum durationnumextra
rename durationtxt durationtxtextra
**rename dod dodextra
rename deathyear deathyearextra
rename cod1a cod1aextra
rename onsetnumcod1a onsetnumcod1aextra
rename onsettxtcod1a onsettxtcod1aextra
rename cod1b cod1bextra
rename onsetnumcod1b onsetnumcod1bextra
rename onsettxtcod1b onsettxtcod1bextra
rename cod1c cod1cextra
rename onsetnumcod1c onsetnumcod1cextra
rename onsettxtcod1c onsettxtcod1cextra
rename cod1d cod1dextra
rename onsetnumcod1d onsetnumcod1dextra
rename onsettxtcod1d onsettxtcod1dextra
rename cod2a cod2aextra
rename onsetnumcod2a onsetnumcod2aextra
rename onsettxtcod2a onsettxtcod2aextra
rename cod2b cod2bextra
rename onsetnumcod2b onsetnumcod2bextra
rename onsettxtcod2b onsettxtcod2bextra
rename pod podextra
rename deathparish deathparishextra
rename regdate regdateextra
rename certifier certifieraddrextra
rename namematch namematchextra
rename death_certificate_complete death_certificate_completeextra


** MERGE the national registry deaths 2008-2017 dataset (exported from REDCap: BNR-DeathDataALL)
merge 1:1 pname regnum dod using "`datapath'\version01\2-working\2008-2017_import_deaths_dp"
/*
Before raw data corrections

    Result                           # of obs.
    -----------------------------------------
    not matched                            20
        from master                        10  (_merge==1)
        from using                         10  (_merge==2)

    matched                            24,178  (_merge==3)
    -----------------------------------------

After raw data corrections

    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                            24,188  (_merge==3)
    -----------------------------------------
*/

count //24,198 - 10 (20) didn't merge because their names had an accented letter (unicode) that caused incorrect format for pname
//24,188

**list record* pname* if _merge!=3
// Corrected in raw data ('Cleaned_DeathData...') and directly in redcap (BNR-DeathDataALL) so updated imported data
drop _merge


** Export list of all deaths with old deathid (record_idextra) and current (redcap) deathid (record_id)
rename record_id deathid

export_excel record_idextra deathid pname using "`datapath'\version01\2-working\20190319_deathid.xlsx",  firstrow(variables) replace

** Remove unused variables
drop *extra nrnnd duration* cod1b cod1c cod1d cod2a cod2b onset* *addr tf* tracking*

** Format variables in prep for merge with cancer data
format dddoa %tcDDmonCCYY_HH:MM:SS
label var dddoa "DateTime of Death Abstraction"

label var ddda "Death Data Abstractor"
label define ddda_lab 1 "JC" 4 "KG" 9 "SAF" 13 "KWG" 14 "TH" 17 "CS" 18 "AROB" 19 "MF" 20 "NR" 98 "Other" 99 "Unknown", modify
label values ddda ddda_lab

label var odda "Death Data Abstractor - Other"

label var certtype "Death Certificate Type"
label define certtype_lab 1 "medical" 2 "post mortem" 3 "coroner" 99 "Unknown", modify
label values certtype certtype_lab

label var regnum "Death Registry Number"

label var district "Death Registry District"
label define district_lab 1 "A" 2 "B" 3 "C" 4 "D" 5 "E" 6 "F" 99 "Unknown", modify
label values district district_lab

label var pname "Death Registry Name"

label var address "Death Registry Address"

rename parish ddparish
label var ddparish "Death Registry Parish"
label define ddparish_lab 1 "Christ Church" 2 "St. Andrew" 3 "St. George" 4 "St. James" 5 "St. John" 6 "St. Joseph" ///
						  7 "St. Lucy" 8 "St. Michael" 9 "St. Peter" 10 "St. Philip" 11 "St. Thomas" 99 "Unknown", modify
label values ddparish ddparish_lab

rename sex ddsex
label var ddsex "Death Registry Sex"
label define ddsex_lab 1 "Male" 2 "Female" 99 "Unknown", modify
label values ddsex ddsex_lab

rename age ddage
label var ddage "Death Registry Age"

rename agetxt ddagetxt
label var ddagetxt "Death Registry Age Period"
label define ddagetxt_lab 1 "Days" 2 "Weeks" 3 "Months" 4 "Years" 99 "Unknown", modify
label values ddagetxt ddagetxt_lab

** NRN - formatting and cleaning
label var nrn "Death Registry NRN"
replace nrn="" if nrn=="." //2,302 changes
count if nrn!="" & length(nrn)<10 //240 - all missing leading zero
sort deathid
**list deathid nrn pname if nrn!="" & length(nrn)<10
replace nrn="0" + nrn if nrn!="" & length(nrn)<10 //240 changes
count if nrn!="" & length(nrn)<10 //13 - these had more than leading zero missing so checked against redcap death db
replace nrn="00" + nrn if nrn!="" & length(nrn)==8 //10 changes
replace nrn="0" + nrn if nrn!="" & length(nrn)==9 //3 changes
**list deathid nrn pname if nrn!="" & length(nrn)<10
replace nrn=substr(nrn,1,6)+"-"+substr(nrn,7,4) //create nrn with symbol '-' so can merge with cancer dataset
replace nrn="" if nrn=="-" //2,302 changes
** Updates to NRNs from dofile '3_clean_2008_2013_dc' so only one merge with cancer dataset maybe needed
replace nrn="210130-0107" if deathid==6776
replace nrn="220708-9999" if deathid==7199
replace nrn="290329-9999" if deathid==7239
replace nrn="590829-9999" if deathid==11208
replace nrn="240517-0040" if deathid==11206
replace nrn="241010-0032" if deathid==10655
replace nrn="260111-0055" if deathid==9794
replace nrn="260626-0096" if deathid==4783
replace nrn="280316-0031" if deathid==11204
replace nrn="290716-0044" if deathid==6533
replace nrn="310514-0036" if deathid==22722
replace nrn="320625-0064" if deathid==11523
replace nrn="321113-0061" if deathid==12296
replace nrn="330524-0016" if deathid==12790
replace nrn="360102-0039" if deathid==11928
replace nrn="361022-0059" if deathid==22999
replace nrn="380426-0010" if deathid==13720
replace nrn="381215-0013" if deathid==13899
replace nrn="391028-0027" if deathid==14013
replace nrn="431005-0150" if deathid==12122
replace nrn="451213-0024" if deathid==5862 //has 2 NRNs in electoral list with nrn=441213-0140
replace nrn="460822-0010" if deathid==6496
replace nrn="500612-8002" if deathid==19016
replace nrn="510210-0269" if deathid==13836
replace nrn="520926-0016" if deathid==11650
replace nrn="751003-0070" if deathid==21141

replace nrn="160429-7000" if deathid==16500
replace nrn="321016-0028" if deathid==3881
replace nrn="331130-0028" if deathid==1111
replace nrn="510103-0012" if deathid==16398
replace nrn="310711-0060" if deathid==16246
replace nrn="360305-0034" if deathid==16287
replace nrn="371114-0024" if deathid==6053
replace nrn="421115-0109" if deathid==16385
replace nrn="570327-0057" if deathid==6102
replace nrn="260929-0065" if deathid==16158
replace nrn="360731-7025" if deathid==16276

label var mstatus "Death Registry Marital Status"
label define mstatus_lab 1 "Single" 2 "Married" 3 "Separated/Divorced" 4 "Widowed" 99 "Unknown", modify
label values mstatus mstatus_lab

label var occu "Death Registry Occupation"

format dod %dD_m_CY
label var dod "Date of death"

label var cod1a "Death Registry Cause(s) of Death"

label var pod "Death Registry Place of Death"

label var deathparish "Death Registry Parish"
label define deathparish_lab 1 "Christ Church" 2 "St. Andrew" 3 "St. George" 4 "St. James" 5 "St. John" 6 "St. Joseph" ///
						     7 "St. Lucy" 8 "St. Michael" 9 "St. Peter" 10 "St. Philip" 11 "St. Thomas" 99 "Unknown", modify
label values deathparish deathparish_lab

format regdate %dD_m_CY
label var regdate "Date of death registration"

rename certifier ddcertifier
label var ddcertifier "Death Registry Certifier"

rename namematch ddnamematch
label var ddnamematch "Death Name Match"
label define ddnamematch_lab 1 "name match-different pt" 2 "no name match" 3 "duplicate", modify
label values ddnamematch ddnamematch_lab

gen duprec=.
label var duprec "Death DuplicateID"
** Below corrections found when creating second dataset for merging (see below)
** redcap db also corrected!
replace ddnamematch=3 if deathid==18039
replace duprec=18038 if deathid==18039
replace ddnamematch=3 if deathid==18490
replace duprec=18489 if deathid==18490
replace nrn="341212-0010" if deathid==21778

rename death_certificate_complete dcstatus
label var dcstatus "Death Certificate Status"
label define dcstatus_lab 0 "Incomplete" 1 "Unverified" 2 "Complete", modify
label values dcstatus dcstatus_lab


save "`datapath'\version01\2-working\2008-2017_redcap_deaths_dp" ,replace
label data "BNR-DeathDataALL (redcap) prepared 2008-2017 national death data"
notes _dta :These data prepared for 2008 & 2013 inclusion in 2014 cancer report

** Need 2nd death dataset for merging cases not previously identified
drop if nrn==""
drop if deathid==18039|deathid==18490 //duplicates found below

sort nrn
quietly by nrn:  gen dup = cond(_N==1,0,_n)
sort deathid
count if dup>0 //6 - duplicates in redcap deaths so updated above and in redcap so now count==0
sort nrn deathid
list deathid pname nrn ddnamematch if dup>0

drop if dup>0 //41 deleted
drop dup

save "`datapath'\version01\2-working\2008-2017_redcap_deaths_nrn_dp" ,replace
label data "BNR-DeathDataALL (redcap) prepared 2008-2017 national death data"
notes _dta :These data prepared for 2008 & 2013 inclusion in 2014 cancer report
