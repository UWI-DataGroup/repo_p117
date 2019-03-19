** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			2_prep_all_deaths_dc.do
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
    log using "`logpath'\2_prep_all_deaths_dc.smcl", replace
** HEADER -----------------------------------------------------

**************************************
** DATA PREPARATION  
**************************************

** LOAD the national registry deaths 2008-2017 dataset (prior to REDCap)
import excel using "`datapath'\version01\1-input\BNRDeathDataALL_DATA_2019-03-19_1012.xlsx" , firstrow case(lower) clear

count //24,188
format nrn %12.0g
tostring nrn, replace

save "`datapath'\version01\2-working\2008-2017_redcap_deaths_dc.dta" ,replace

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
merge 1:1 pname regnum dod using "`datapath'\version01\2-working\2008-2017_redcap_deaths_dc.dta"
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

count //24,198 - 10 (20) didn't merge because their names had an accented letter that caused incorrect format for pname
//24,188

**list record* pname* if _merge!=3
// Corrected in raw data ('Cleaned_DeathData...') and directly in redcap (BNR-DeathDataALL) so updated imported data
drop _merge

** Export list of all deaths with old deathid (record_idextra) and current (redcap) deathid (record_id)
rename record_id deathid

export_excel record_idextra deathid pname using "`datapath'\version01\2-working\20190319_deathid.xlsx",  firstrow(variables) replace

save "`datapath'\version01\2-working\2008-2017_deaths_dc.dta" ,replace
label data "BNR-DeathDataALL (redcap) prepared 2008-2017 national death data"
notes _dta :These data prepared for 2008 & 2013 inclusion in 2014 cancer report
