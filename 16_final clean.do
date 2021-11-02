** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          16_final clean.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      09-AUG-2021
    // 	date last modified      28-OCT-2021
    //  algorithm task          Final cleaning of 2008,2013-2015 cancer dataset; Preparing datasets for analysis
    //  status                  Completed
    //  objective               To have one dataset with cleaned and grouped 2008, 2013, 2014 data for inclusion in 2015 cancer report.
    //  methods                 Clean and update all years' data using IARCcrgTools Check and Multiple Primary

    ** General algorithm set-up
    version 16.0
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
    log using "`logpath'\16_final clean.smcl", replace
** HEADER -----------------------------------------------------

** Load cleaned pre-matched cancer dataset from dofile 15
use "`datapath'\version02\2-working\2008_2013_2014_2015_cancer ds_2015-2020 death matching", clear

** Combine death matched dataset from dofile 50 to this cancer dataset
merge 1:1 pid cr5id using "`datapath'\version02\2-working\2008_2013_2014_2015_cancer ds_2015-2020 deaths matched" ,update replace
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         3,943
        from master                     3,943  (_merge==1)
        from using                          0  (_merge==2)

    matched                               123
        not updated                         0  (_merge==3)
        missing updated                     0  (_merge==4)
        nonmissing conflict               123  (_merge==5)
    -----------------------------------------
*/
drop _merge
count //4066


** Perform final checks on the post-clean updated + death matched cancer dataset

***************************************
**     Combining death data into     **
** one set of variables in cancer ds **
***************************************

** Creating one set of death data variables
replace dd_nrn=nrn if dd_nrn==. & nrn!=. //0 changes
replace dd_coddeath=coddeath if dd_coddeath=="" & coddeath!="" //0 changes
replace dd_regnum=regnum if dd_regnum==. & regnum!=. //1569 changes
replace dd_pname=pname if dd_pname=="" & pname!="" //1569 changes
replace dd_age=age if dd_age==. & age!=. //2194 changes/
replace dd_parish=parish if dd_parish==. & parish!=. //2192 changes/
replace dd_namematch=namematch if dd_namematch==. & namematch!=. //505 changes
replace dd_certifier=certifier if dd_certifier=="" & certifier!="" //1486 changes/
replace dd_dod=dod if dd_dod==. & dod!=. //0 changes

replace cancer=dd_cancer if cancer==. & dd_cancer!=. //0 changes
replace cod=dd_cod if cod==. & dd_cod!=. //0 changes

** Check all dd2019 variables have been combined into 'dd_' variables (performed in dofile 15)
count if dd_nrn==. & dd2019_nrn!=. //0
count if dd_coddeath=="" & dd2019_coddeath!="" //0
count if dd_regnum==. & dd2019_regnum!=. //0
count if dd_pname=="" & dd2019_pname!="" //0
count if dd_age==. & dd2019_age!=. //0
count if dd_cod1a=="" & dd2019_cod1a!="" //0
count if dd_address=="" & dd2019_address!="" //0
count if dd_parish==. & dd2019_parish!=. //0
count if dd_pod=="" & dd2019_pod!="" //0
count if dd_mname=="" & dd2019_mname!="" //0
count if dd_namematch==. & dd2019_namematch!=. //0
count if dd_dddoa==. & dd2019_dddoa!=. //0
count if dd_ddda==. & dd2019_ddda!=. //0
count if dd_odda=="" & dd2019_odda!="" //0
count if dd_certtype==. & dd2019_certtype!=. //0
count if dd_district==. & dd2019_district!=. //0
count if dd_agetxt==. & dd2019_agetxt!=. //0
count if dd_nrnnd==. & dd2019_nrnnd!=. //0
count if dd_mstatus==. & dd2019_mstatus!=. //0
count if dd_occu=="" & dd2019_occu!="" //0
count if dd_durationnum==. & dd2019_durationnum!=. //0
count if dd_durationtxt==. & dd2019_durationtxt!=. //0
count if dd_onsetnumcod1a==. & dd2019_onsetnumcod1a!=. //0
count if dd_onsettxtcod1a==. & dd2019_onsettxtcod1a!=. //0
count if dd_cod1b=="" & dd2019_cod1b!="" //0
count if dd_onsetnumcod1b==. & dd2019_onsetnumcod1b!=. //0
count if dd_onsettxtcod1b==. & dd2019_onsettxtcod1b!=. //0
count if dd_cod1c=="" & dd2019_cod1c!="" //0
count if dd_onsetnumcod1c==. & dd2019_onsetnumcod1c!=. //0
count if dd_onsettxtcod1c==. & dd2019_onsettxtcod1c!=. //0
count if dd_cod1d=="" & dd2019_cod1d!="" //0
count if dd_onsetnumcod1d==. & dd2019_onsetnumcod1d!=. //0
count if dd_onsettxtcod1d==. & dd2019_onsettxtcod1d!=. //0
count if dd_cod2a=="" & dd2019_cod2a!="" //0
count if dd_onsetnumcod2a==. & dd2019_onsetnumcod2a!=. //0
count if dd_onsettxtcod2a==. & dd2019_onsettxtcod2a!=. //0
count if dd_cod2b=="" & dd2019_cod2b!="" //0
count if dd_onsetnumcod2b==. & dd2019_onsetnumcod2b!=. //0
count if dd_onsettxtcod2b==. & dd2019_onsettxtcod2b!=. //0
count if dd_deathparish==. & dd2019_deathparish!=. //0
count if dd_regdate==. & dd2019_regdate!=. //0
count if dd_certifier=="" & dd2019_certifier!="" //0
count if dd_certifieraddr=="" & dd2019_certifieraddr!="" //0
count if dd_duprec==. & dd2019_duprec!=. //0
tab dd_dodyear,m
count if dd_dod==. & dd2019_dod!=. //0

** Remove unnecessary death variables
drop dd2019_* nrn coddeath regnum pname namematch


*****************************
** IARCcrgTools check + MP **
*****************************

** Copy the variables needed in Stata's Browse/Edit into an excel sheet in 2-working folder
//replace mpseq=1 if mpseq==0 //2918 changes
tab mpseq ,m //3 missing
//list pid fname lname mptot if mpseq==. //reviewed in Stata's Browse/Edit + CR5db
replace mptot=1 if mpseq==. & mptot==. //3 changes
replace mpseq=1 if mpseq==. //3 changes

tab icd10 ,m //none missing

** Create dates for use in IARCcrgTools
drop dob_iarc dot_iarc

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

** Organize the variables to be used in IARCcrgTools to appear at start of the dataset in Browse/Edit
order pid sex top morph beh grade basis dot_iarc dob_iarc age mpseq mptot cr5id
** Note: to copy results without value labels, I had to right-click Browse/Edit data, select Preferences --> Data Editor --> untick 'Copy value labels to the Clipboard instead of values'.
//Excel saved as .csv in 2-working\iarccrgtoolsV01.csv
//Excel saved as .csv in 2-working\iarccrgtoolsV02.csv - added in mptot + cr5id to spot any errors in these fields

** Using the IARC Hub's guide, I prepared the excel sheet for use in IARCcrgTools, i.e. re-inserted leading zeros into topography.
** IARCcrgTools Check results
/*
4066 records processed. Summary statistics:

2 errors (2 individual records) recorded in X:\The University of the West Indies\DataGroup - repo_data\data_p117\version02\2-working\iarccrgtoolsFileTransfer.err:

2 invalid age


98 warnings (97 individual records) recorded in X:\The University of the West Indies\DataGroup - repo_data\data_p117\version02\2-working\iarccrgtoolsFileTransfer.chk:

31 unlikely histology/site combination
1 unlikely behaviour/histology combination
40 unlikely grade/histology combination
25 unlikely basis/histology combination
1 unlikely age/site/histology combination
*/

** Corrections from IARCcrgTools Check
replace age=87 if pid=="20159118" //2 changes
replace morph=8081 if pid=="20080741" & cr5id=="T2S1" //1 change
replace morphcat=3 if pid=="20080741" & cr5id=="T2S1" //1 change

** IARCcrgTools MP results
/*
Records:	4066
Excluded:	 141
MPs:		 267
Duplicate:	  67
*/
** Only report non-duplicate MPs (see IARC MP rules on recording and reporting)
display `"{browse "http://www.iacr.com.fr/images/doc/MPrules_july2004.pdf":IARC-MP}"'

** Corrections from IARCcrgTools MP

//incidental correction
replace mptot=2 if pid=="20159029" & cr5id=="T1S1"
replace mpseq=1 if pid=="20159029" & cr5id=="T1S1"
replace mptot=2 if pid=="20159029" & cr5id=="T2S1"
replace mpseq=2 if pid=="20159029" & cr5id=="T2S1"

//incidental correction
replace mptot=2 if pid=="20151020" & cr5id=="T1S1"
replace mpseq=1 if pid=="20151020" & cr5id=="T1S1"
replace mptot=2 if pid=="20151020" & cr5id=="T3S1"
replace mpseq=2 if pid=="20151020" & cr5id=="T3S1"
replace cr5id="T2S1" if pid=="20151020" & cr5id=="T3S1"

//incidental correction
replace mptot=2 if pid=="20145070" & cr5id=="T1S1"
replace mpseq=1 if pid=="20145070" & cr5id=="T1S1"
replace mptot=2 if pid=="20145070" & cr5id=="T2S1"
replace mpseq=2 if pid=="20145070" & cr5id=="T2S1"

//incidental correction
replace mptot=2 if pid=="20141379" & cr5id=="T1S1"
replace mpseq=1 if pid=="20141379" & cr5id=="T1S1"
replace mptot=2 if pid=="20141379" & cr5id=="T2S1"
replace mpseq=2 if pid=="20141379" & cr5id=="T2S1"

//incidental correction
replace mptot=2 if pid=="20141288" & cr5id=="T1S1"
replace mpseq=1 if pid=="20141288" & cr5id=="T1S1"
replace mptot=2 if pid=="20141288" & cr5id=="T2S1"
replace mpseq=2 if pid=="20141288" & cr5id=="T2S1"

//incidental correction
replace mptot=2 if pid=="20130539" & cr5id=="T1S1"

//incidental correction
replace mptot=2 if pid=="20130410" & cr5id=="T1S1"
replace mpseq=1 if pid=="20130410" & cr5id=="T1S1"
replace mptot=2 if pid=="20130410" & cr5id=="T2S1"
replace mpseq=2 if pid=="20130410" & cr5id=="T2S1"

//incidental correction
replace mptot=2 if pid=="20130294" & cr5id=="T1S1"
replace mpseq=1 if pid=="20130294" & cr5id=="T1S1"
replace mptot=2 if pid=="20130294" & cr5id=="T2S1"
replace mpseq=2 if pid=="20130294" & cr5id=="T2S1"

//incidental correction
replace mptot=2 if pid=="20130275" & cr5id=="T1S1"
replace mpseq=1 if pid=="20130275" & cr5id=="T1S1"
replace mptot=2 if pid=="20130275" & cr5id=="T3S1"
replace mpseq=2 if pid=="20130275" & cr5id=="T3S1"
replace cr5id="T2S1" if pid=="20130275" & cr5id=="T3S1"

//incidental correction
replace mptot=2 if pid=="20130175" & cr5id=="T1S1"
replace mpseq=1 if pid=="20130175" & cr5id=="T1S1"
replace mptot=2 if pid=="20130175" & cr5id=="T2S1"
replace mpseq=2 if pid=="20130175" & cr5id=="T2S1"

//incidental correction
replace mptot=2 if pid=="20130162" & cr5id=="T1S1"
replace mpseq=1 if pid=="20130162" & cr5id=="T1S1"
replace mptot=2 if pid=="20130162" & cr5id=="T2S1"
replace mpseq=2 if pid=="20130162" & cr5id=="T2S1"

replace mpseq=0 if pid=="20130323" & cr5id=="T1S1"
replace mptot=1 if pid=="20130323" & cr5id=="T1S1"
drop if pid=="20130323" & cr5id=="T2S1"

drop if pid=="20130160" & cr5id=="T2S1"

replace mpseq=0 if pid=="20081104" & cr5id=="T1S1"
replace mptot=1 if pid=="20081104" & cr5id=="T1S1"
drop if pid=="20081104" & cr5id=="T2S1"

replace mpseq=0 if pid=="20081089" & cr5id=="T1S1"
replace mptot=1 if pid=="20081089" & cr5id=="T1S1"
drop if pid=="20081089" & cr5id=="T2S1"

//incidental correction
replace mptot=2 if pid=="20081085" & cr5id=="T1S1"
replace mpseq=1 if pid=="20081085" & cr5id=="T1S1"
replace mptot=2 if pid=="20081085" & cr5id=="T2S1"
replace mpseq=2 if pid=="20081085" & cr5id=="T2S1"

replace mpseq=0 if pid=="20081083" & cr5id=="T1S1"
replace mptot=1 if pid=="20081083" & cr5id=="T1S1"
drop if pid=="20081083" & cr5id=="T2S1"
drop if pid=="20081083" & cr5id=="T3S1"

replace mpseq=0 if pid=="20081076" & cr5id=="T1S1"
replace mptot=1 if pid=="20081076" & cr5id=="T1S1"
drop if pid=="20081076" & cr5id=="T2S1"
drop if pid=="20081076" & cr5id=="T3S1"

replace mpseq=0 if pid=="20080790" & cr5id=="T1S1"
replace mptot=1 if pid=="20080790" & cr5id=="T1S1"
drop if pid=="20080790" & cr5id=="T2S1"

replace mptot=2 if pid=="20080766" & cr5id=="T1S1"
replace mptot=2 if pid=="20080766" & cr5id=="T2S1"
drop if pid=="20080766" & cr5id=="T3S1"
drop if pid=="20080766" & cr5id=="T4S1"

replace mpseq=0 if pid=="20080740" & cr5id=="T1S1"
replace mptot=1 if pid=="20080740" & cr5id=="T1S1"
drop if pid=="20080740" & cr5id=="T2S1"

replace mpseq=0 if pid=="20080739" & cr5id=="T1S1"
replace mptot=1 if pid=="20080739" & cr5id=="T1S1"
drop if pid=="20080739" & cr5id=="T2S1"
drop if pid=="20080739" & cr5id=="T3S1"
drop if pid=="20080739" & cr5id=="T4S1"

replace mpseq=0 if pid=="20080738" & cr5id=="T1S1"
replace mptot=1 if pid=="20080738" & cr5id=="T1S1"
drop if pid=="20080738" & cr5id=="T2S1"

replace mpseq=0 if pid=="20080734" & cr5id=="T1S1"
replace mptot=1 if pid=="20080734" & cr5id=="T1S1"
drop if pid=="20080734" & cr5id=="T2S1"

replace mpseq=0 if pid=="20080733" & cr5id=="T1S1"
replace mptot=1 if pid=="20080733" & cr5id=="T1S1"
drop if pid=="20080733" & cr5id=="T4S1"

replace mpseq=0 if pid=="20080731" & cr5id=="T1S1"
replace mptot=1 if pid=="20080731" & cr5id=="T1S1"
drop if pid=="20080731" & cr5id=="T2S1"

//incidental correction
replace mptot=2 if pid=="20080730"

replace mptot=3 if pid=="20080728" & cr5id=="T1S1"
replace mptot=3 if pid=="20080728" & cr5id=="T2S1"
replace mptot=3 if pid=="20080728" & cr5id=="T5S1"
replace mpseq=3 if pid=="20080728" & cr5id=="T5S1"
drop if pid=="20080728" & cr5id=="T3S1"
drop if pid=="20080728" & cr5id=="T4S1"
replace cr5id="T3S1" if pid=="20080728" & cr5id=="T5S1"

replace mpseq=0 if pid=="20080725" & cr5id=="T1S1"
replace mptot=1 if pid=="20080725" & cr5id=="T1S1"
drop if pid=="20080725" & cr5id=="T2S1"

replace mpseq=0 if pid=="20080709" & cr5id=="T1S1"
replace mptot=1 if pid=="20080709" & cr5id=="T1S1"
drop if pid=="20080709" & cr5id=="T2S1"

//incidental correction
replace mptot=2 if pid=="20080708" & cr5id=="T1S1"
replace mptot=2 if pid=="20080708" & cr5id=="T4S1"
replace mpseq=2 if pid=="20080708" & cr5id=="T4S1"
replace cr5id="T2S1" if pid=="20080708" & cr5id=="T4S1"

replace mpseq=0 if pid=="20080705" & cr5id=="T2S1"
replace mptot=1 if pid=="20080705" & cr5id=="T2S1"
drop if pid=="20080705" & cr5id=="T1S1"
replace cr5id="T1S1" if pid=="20080705" & cr5id=="T2S1"

//incidental correction
replace mptot=2 if pid=="20080696" & cr5id=="T1S1"

//incidental correction
replace mptot=2 if pid=="20080690" & cr5id=="T2S1"
replace mpseq=1 if pid=="20080690" & cr5id=="T2S1"
replace mptot=2 if pid=="20080690" & cr5id=="T3S1"
replace mpseq=2 if pid=="20080690" & cr5id=="T3S1"
replace cr5id="T1S1" if pid=="20080690" & cr5id=="T2S1"
replace cr5id="T2S1" if pid=="20080690" & cr5id=="T3S1"

replace mptot=2 if pid=="20080667" & cr5id=="T1S1"
replace mptot=2 if pid=="20080667" & cr5id=="T2S1"
drop if pid=="20080667" & cr5id=="T3S1"

replace mpseq=0 if pid=="20080662" & cr5id=="T2S1"
replace mptot=1 if pid=="20080662" & cr5id=="T2S1"
drop if pid=="20080662" & cr5id=="T1S1"
replace cr5id="T1S1" if pid=="20080662" & cr5id=="T2S1"
replace patient=1 if pid=="20080662" & cr5id=="T1S1"
replace eidmp=1 if pid=="20080662" & cr5id=="T1S1"
replace ptrectot=1 if pid=="20080662" & cr5id=="T1S1"

replace mpseq=0 if pid=="20080655" & cr5id=="T1S1"
replace mptot=1 if pid=="20080655" & cr5id=="T1S1"
drop if pid=="20080655" & cr5id=="T2S1"

replace mptot=3 if pid=="20080626" & cr5id=="T1S1"
replace mptot=3 if pid=="20080626" & cr5id=="T2S1"
replace mptot=3 if pid=="20080626" & cr5id=="T7S1"
replace mpseq=3 if pid=="20080626" & cr5id=="T7S1"
drop if pid=="20080626" & cr5id=="T3S1"
drop if pid=="20080626" & cr5id=="T4S1"
drop if pid=="20080626" & cr5id=="T5S1"
drop if pid=="20080626" & cr5id=="T6S1"
replace cr5id="T3S1" if pid=="20080626" & cr5id=="T7S1"

//incidental correction
replace mptot=2 if pid=="20080567" & cr5id=="T1S1"
replace mpseq=1 if pid=="20080567" & cr5id=="T1S1"
replace mptot=2 if pid=="20080567" & cr5id=="T2S1"
replace mpseq=2 if pid=="20080567" & cr5id=="T2S1"

replace mpseq=0 if pid=="20080499" & cr5id=="T1S1"
replace mptot=1 if pid=="20080499" & cr5id=="T1S1"
drop if pid=="20080499" & cr5id=="T3S1"

//incidental correction
replace mptot=2 if pid=="20080477" & cr5id=="T3S1"
replace mpseq=1 if pid=="20080477" & cr5id=="T3S1"
replace mptot=2 if pid=="20080477" & cr5id=="T4S1"
replace mpseq=2 if pid=="20080477" & cr5id=="T4S1"
replace cr5id="T1S1" if pid=="20080477" & cr5id=="T3S1"
replace cr5id="T2S1" if pid=="20080477" & cr5id=="T4S1"

replace mpseq=0 if pid=="20080475" & cr5id=="T1S1"
replace mptot=1 if pid=="20080475" & cr5id=="T1S1"
drop if pid=="20080475" & cr5id=="T3S1"

replace mptot=2 if pid=="20080465" & cr5id=="T1S1"
replace mptot=2 if pid=="20080465" & cr5id=="T3S1"
replace mpseq=2 if pid=="20080465" & cr5id=="T3S1"
drop if pid=="20080465" & cr5id=="T2S1"
drop if pid=="20080465" & cr5id=="T4S1"
replace cr5id="T2S1" if pid=="20080465" & cr5id=="T3S1"

replace mpseq=0 if pid=="20080464" & cr5id=="T1S1"
replace mptot=1 if pid=="20080464" & cr5id=="T1S1"
drop if pid=="20080464" & cr5id=="T2S1"

replace mptot=2 if pid=="20080463" & cr5id=="T1S1"
replace mptot=2 if pid=="20080463" & cr5id=="T3S1"
replace mpseq=2 if pid=="20080463" & cr5id=="T3S1"
drop if pid=="20080463" & cr5id=="T2S1"
replace cr5id="T2S1" if pid=="20080463" & cr5id=="T3S1"

replace mpseq=0 if pid=="20080460" & cr5id=="T2S1"
replace mptot=1 if pid=="20080460" & cr5id=="T2S1"
drop if pid=="20080460" & cr5id=="T1S1"
replace cr5id="T1S1" if pid=="20080460" & cr5id=="T2S1"
replace patient=1 if pid=="20080460" & cr5id=="T1S1"
replace eidmp=1 if pid=="20080460" & cr5id=="T1S1"
replace ptrectot=1 if pid=="20080460" & cr5id=="T1S1"

replace mptot=2 if pid=="20080457" & cr5id=="T1S1"
replace mptot=2 if pid=="20080457" & cr5id=="T4S1"
replace mpseq=2 if pid=="20080457" & cr5id=="T4S1"
drop if pid=="20080457" & cr5id=="T2S1"
drop if pid=="20080457" & cr5id=="T3S1"
replace cr5id="T2S1" if pid=="20080457" & cr5id=="T4S1"

replace mpseq=0 if pid=="20080449" & cr5id=="T1S1"
replace mptot=1 if pid=="20080449" & cr5id=="T1S1"
drop if pid=="20080449" & cr5id=="T2S1"
drop if pid=="20080449" & cr5id=="T3S1"
drop if pid=="20080449" & cr5id=="T4S1"

replace mpseq=0 if pid=="20080446" & cr5id=="T1S1"
replace mptot=1 if pid=="20080446" & cr5id=="T1S1"
drop if pid=="20080446" & cr5id=="T2S1"

//incidental correction
replace mptot=2 if pid=="20080443"

replace mpseq=0 if pid=="20080441" & cr5id=="T1S1"
replace mptot=1 if pid=="20080441" & cr5id=="T1S1"
drop if pid=="20080441" & cr5id=="T2S1"

replace mpseq=0 if pid=="20080440" & cr5id=="T1S1"
replace mptot=1 if pid=="20080440" & cr5id=="T1S1"
drop if pid=="20080440" & cr5id=="T2S1"

replace mpseq=0 if pid=="20080432" & cr5id=="T1S1"
replace mptot=1 if pid=="20080432" & cr5id=="T1S1"
drop if pid=="20080432" & cr5id=="T2S1"

//incidental correction
replace mptot=2 if pid=="20080401" & cr5id=="T1S1"
replace mptot=2 if pid=="20080401" & cr5id=="T2S1"
replace mpseq=2 if pid=="20080401" & cr5id=="T2S1"

replace mpseq=0 if pid=="20080386" & cr5id=="T1S1"
replace mptot=1 if pid=="20080386" & cr5id=="T1S1"
drop if pid=="20080386" & cr5id=="T2S1"

replace mpseq=0 if pid=="20080381" & cr5id=="T2S1"
replace mptot=1 if pid=="20080381" & cr5id=="T2S1"
drop if pid=="20080381" & cr5id=="T1S1"
replace cr5id="T1S1" if pid=="20080381" & cr5id=="T2S1"
replace patient=1 if pid=="20080381" & cr5id=="T1S1"
replace eidmp=1 if pid=="20080381" & cr5id=="T1S1"
replace ptrectot=1 if pid=="20080381" & cr5id=="T1S1"

replace mpseq=0 if pid=="20080378" & cr5id=="T1S1"
replace mptot=1 if pid=="20080378" & cr5id=="T1S1"
drop if pid=="20080378" & cr5id=="T2S1"

replace mpseq=0 if pid=="20080372" & cr5id=="T1S1"
replace mptot=1 if pid=="20080372" & cr5id=="T1S1"
drop if pid=="20080372" & cr5id=="T2S1"

//incidental correction
replace mptot=2 if pid=="20080365" & cr5id=="T1S1"
replace mptot=2 if pid=="20080365" & cr5id=="T3S1"
replace mpseq=2 if pid=="20080365" & cr5id=="T3S1"
replace persearch=2 if pid=="20080365" & cr5id=="T3S1"
replace cr5id="T2S1" if pid=="20080365" & cr5id=="T3S1"

replace mpseq=0 if pid=="20080364" & cr5id=="T1S1"
replace mptot=1 if pid=="20080364" & cr5id=="T1S1"
drop if pid=="20080364" & cr5id=="T2S1"

replace mptot=3 if pid=="20080363" & cr5id=="T1S1"
replace mptot=3 if pid=="20080363" & cr5id=="T2S1"
replace mptot=3 if pid=="20080363" & cr5id=="T5S1"
replace mpseq=3 if pid=="20080363" & cr5id=="T5S1"
drop if pid=="20080363" & cr5id=="T3S1"
drop if pid=="20080363" & cr5id=="T4S1"
replace cr5id="T3S1" if pid=="20080363" & cr5id=="T5S1"

replace mptot=2 if pid=="20080362" & cr5id=="T1S1"
replace mptot=2 if pid=="20080362" & cr5id=="T2S1"
drop if pid=="20080362" & cr5id=="T3S1"
drop if pid=="20080362" & cr5id=="T4S1"

replace mpseq=0 if pid=="20080360" & cr5id=="T1S1"
replace mptot=1 if pid=="20080360" & cr5id=="T1S1"
drop if pid=="20080360" & cr5id=="T2S1"

//incidental correction
replace mptot=2 if pid=="20080336" & cr5id=="T1S1"
replace mpseq=1 if pid=="20080336" & cr5id=="T1S1"
replace mptot=2 if pid=="20080336" & cr5id=="T2S1"
replace mpseq=2 if pid=="20080336" & cr5id=="T2S1"
replace persearch=2 if pid=="20080336" & cr5id=="T2S1"

replace mptot=2 if pid=="20080317" & cr5id=="T1S1"
replace mptot=2 if pid=="20080317" & cr5id=="T2S1"
drop if pid=="20080317" & cr5id=="T3S1"
drop if pid=="20080317" & cr5id=="T4S1"
drop if pid=="20080317" & cr5id=="T5S1"
drop if pid=="20080317" & cr5id=="T6S1"

replace mpseq=0 if pid=="20080310" & cr5id=="T2S1"
replace mptot=1 if pid=="20080310" & cr5id=="T2S1"
drop if pid=="20080310" & cr5id=="T3S1"
drop if pid=="20080310" & cr5id=="T4S1"
drop if pid=="20080310" & cr5id=="T7S1"
replace cr5id="T1S1" if pid=="20080310" & cr5id=="T2S1"

replace mpseq=0 if pid=="20080308" & cr5id=="T1S1"
replace mptot=1 if pid=="20080308" & cr5id=="T1S1"
drop if pid=="20080308" & cr5id=="T2S1"
drop if pid=="20080308" & cr5id=="T3S1"

//incidental correction
replace mptot=2 if pid=="20080242" & cr5id=="T1S1"
replace mpseq=1 if pid=="20080242" & cr5id=="T1S1"
replace mptot=2 if pid=="20080242" & cr5id=="T2S1"
replace mpseq=2 if pid=="20080242" & cr5id=="T2S1"

//incidental correction
replace mptot=2 if pid=="20080215" & cr5id=="T1S1"
replace mpseq=1 if pid=="20080215" & cr5id=="T1S1"
replace mptot=2 if pid=="20080215" & cr5id=="T3S1"
replace mpseq=2 if pid=="20080215" & cr5id=="T3S1"
replace cr5id="T2S1" if pid=="20080215" & cr5id=="T3S1"

replace mpseq=0 if pid=="20080196" & cr5id=="T1S1"
replace mptot=1 if pid=="20080196" & cr5id=="T1S1"
drop if pid=="20080196" & cr5id=="T2S1"


count //3,999


** Import 2013 missed eligible DCOs 
** from 2013 annual report code path: data_cleaning/2013/cancer/versions/version03/data/clean/2013_cancer_tumours_with_deaths
** filter above dataset for 23 missed cases: regexm(eid,"201399")
** Also 12 cases also identified during the Mortality:Incidence Ratio process
** FIRST, I performed IARCcrgTools ICD-O-3 to ICD10 conversion, consistency checks and MP check (01nov2021 using MissedMIRsDCOs20211101_iarccrgtools.csv in 2-working)
/*
35 records processed. Summary statistics:

4 errors (3 individual records) recorded in X:\The University of the West Indies\DataGroup - repo_data\data_p117\version02\2-working\Formatted dataset_20211101.err:

1 invalid sex/site combination
3 invalid age


12 warnings (8 individual records) recorded in X:\The University of the West Indies\DataGroup - repo_data\data_p117\version02\2-working\Formatted dataset_20211101.chk:

3 unlikely histology/site combination
2 unlikely behaviour/histology combination
1 unlikely grade/histology combination
6 unlikely basis/histology combination
*/

** Flagged cases checked and corrected in the excel file directly then imported below; IARC flag value added also
** Create IARC flag variable for CI5 submission
gen iarcflag=.
label var iarcflag "IARC Flag"
label define iarcflag_lab 0 "Failed" 1 "OK" 2 "Checked" 9 "Unknown", modify
label values iarcflag iarcflag_lab


preserve
clear
import excel using "`datapath'\version02\2-working\MissedMIRsDCOs20211018.xlsx" , firstrow case(lower)
tostring pid ,replace
tostring natregno ,replace
tostring top ,replace
format eid %14.0g
tostring eid, gen(eid_full) format("%12.0f")
drop eid
rename eid_full eid
format sid %16.0g
tostring sid, gen(sid_full) format("%14.0f")
drop sid
rename sid_full sid
tostring recnum ,replace
tostring labnum ,replace
tostring cytofinds ,replace
tostring consrpt ,replace
tostring certifier ,replace
tostring duration ,replace
tostring onsetint ,replace
tostring orx2 ,replace
tostring hospnum ,replace
tostring sourcetotal ,replace
//tostring pname ,replace
tostring updatenotes1 ,replace
tostring updatenotes2 ,replace
tostring updatenotes3 ,replace
//tostring dot_iarc ,replace
//tostring dob_iarc ,replace
tostring dd_odda ,replace
tostring dd_cod1c ,replace
tostring dd_cod1d ,replace
//tostring tfdistrictstart ,replace
//tostring tfdistrictend ,replace
//tostring tfddtxt ,replace
tostring dd_natregno ,replace
tostring dd_coddeath ,replace
tostring dd_pname ,replace
tostring dd_cod1a ,replace
tostring dd_address ,replace
tostring dd_pod ,replace
tostring dd_mname ,replace
tostring dd_odda ,replace
tostring dd_occu ,replace
tostring dd_cod1b ,replace
tostring dd_cod1c ,replace
tostring dd_cod1d ,replace
tostring dd_cod2a ,replace
tostring dd_cod2b ,replace
tostring dd_certifier ,replace
tostring dd_certifieraddr ,replace
//tostring meddata ,replace
gen double deathid_full=deathid
drop deathid
rename deathid_full deathid
save "`datapath'\version02\2-working\missedMIRs" ,replace
restore
append using "`datapath'\version02\2-working\missedMIRs"

count //4,034


******************
** FINAL CHECKS **
******************
order pid top morph mpseq mptot persearch cr5id

*******************
** CLL/SLL M9823 **
*******************
count if morph==9823 & topography==421 //4 reviewed
//Review these cases - If unk if bone marrow involved then topography=lymph node-unk (C779)
display `"{browse "https://seer.cancer.gov/tools/heme/Hematopoietic_Instructions_and_Rules.pdf":HAEM-RULES}"'

replace primarysite="LYMPH NODES-UNK" if pid=="20180030" & cr5id=="T1S1"
replace top="779" if pid=="20180030" & cr5id=="T1S1"
replace topography=779 if pid=="20180030" & cr5id=="T1S1"
replace topography=779 if pid=="20180030" & cr5id=="T1S1"
replace comments="JC 01NOV2021: Based on Haem & Lymph Coding manual Module 3 PH5 and PH6 the primary site has been changed to LNs unk since no bone marrow report found to support that as the primary site. JC 26JUL2021: Abstracted during post-clean updates process; Missed eligible case; 02MAR20_KWG Notes seen and state that Pt diagnosed privately by Dr C Nicholls in 2013 and followed by him until 2016. F/U Dr Nicholls for BOD. 24SEPT19_KWG F/U notes for BOD, InciDate." if pid=="20180030" & cr5id=="T1S1"



******************
** MP variables **
******************
***************
** PERSEARCH **
***************

** persearch is used to identify MPs
** Check 1
count if persearch!=1 & (mpseq==0|mpseq==1) //144 - checked for any (1) in-situ NOT=Done: Exclude; (2) malignant NOT=Done: OK //143
//list pid mptot mpseq persearch beh cr5id if persearch!=1 & (mpseq==0|mpseq==1)

replace persearch=1 if pid=="20080381" & cr5id=="T1S1"
replace persearch=1 if pid=="20080460" & cr5id=="T1S1"
replace persearch=1 if pid=="20080662" & cr5id=="T1S1"
replace persearch=1 if pid=="20080733" & cr5id=="T1S1"
replace persearch=1 if pid=="20080738" & cr5id=="T1S1"
replace persearch=1 if pid=="20080739" & cr5id=="T1S1"

** Check 2
count if persearch==1 & cr5id!="T1S1" //28; 29
//list pid mptot mpseq persearch beh cr5id if persearch==1 & cr5id!="T1S1"

replace mpseq=0 if pid=="20080384" & cr5id=="T2S1"
replace mptot=1 if pid=="20080384" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20080384" & cr5id=="T2S1"

replace mpseq=0 if pid=="20080387" & cr5id=="T2S1"
replace mptot=1 if pid=="20080387" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20080387" & cr5id=="T2S1"

replace mpseq=0 if pid=="20080438" & cr5id=="T2S1"
replace mptot=1 if pid=="20080438" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20080438" & cr5id=="T2S1"

replace mpseq=2 if pid=="20080607" & cr5id=="T2S1"
replace mptot=2 if pid=="20080607" & cr5id=="T2S1"

replace mpseq=2 if pid=="20080677" & cr5id=="T2S1"
replace mptot=2 if pid=="20080677" & cr5id=="T2S1"

replace persearch=2 if pid=="20081085" & cr5id=="T2S1"

replace mpseq=0 if pid=="20090016" & cr5id=="T2S1"
replace mptot=1 if pid=="20090016" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20090016" & cr5id=="T2S1"

replace mpseq=0 if pid=="20090045" & cr5id=="T3S1"
replace mptot=1 if pid=="20090045" & cr5id=="T3S1"
replace cr5id="T1S1" if pid=="20090045" & cr5id=="T3S1"

replace mpseq=0 if pid=="20130169" & cr5id=="T2S1"
replace mptot=1 if pid=="20130169" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20130169" & cr5id=="T2S1"

replace mpseq=0 if pid=="20130172" & cr5id=="T2S1"
replace mptot=1 if pid=="20130172" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20130172" & cr5id=="T2S1"

replace mpseq=0 if pid=="20130727" & cr5id=="T2S1"
replace mptot=1 if pid=="20130727" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20130727" & cr5id=="T2S1"

replace mpseq=0 if pid=="20130798" & cr5id=="T2S1"
replace mptot=1 if pid=="20130798" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20130798" & cr5id=="T2S1"

replace mpseq=0 if pid=="20140490" & cr5id=="T2S1"
replace mptot=1 if pid=="20140490" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20140490" & cr5id=="T2S1"

replace mpseq=1 if pid=="20140822" & cr5id=="T1S1"
replace mptot=2 if pid=="20140822" & cr5id=="T1S1"

replace mpseq=0 if pid=="20140966" & cr5id=="T2S1"
replace mptot=1 if pid=="20140966" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20140966" & cr5id=="T2S1"

replace mpseq=0 if pid=="20141021" & cr5id=="T2S1"
replace mptot=1 if pid=="20141021" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20141021" & cr5id=="T2S1"

replace mpseq=0 if pid=="20141258" & cr5id=="T2S1"
replace mptot=1 if pid=="20141258" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20141258" & cr5id=="T2S1"

replace mpseq=0 if pid=="20141409" & cr5id=="T2S1"
replace mptot=1 if pid=="20141409" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20141409" & cr5id=="T2S1"

replace mpseq=0 if pid=="20150169" & cr5id=="T2S1"
replace mptot=1 if pid=="20150169" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20150169" & cr5id=="T2S1"

replace mpseq=0 if pid=="20150234" & cr5id=="T2S1"
replace mptot=1 if pid=="20150234" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20150234" & cr5id=="T2S1"

replace mpseq=0 if pid=="20150314" & cr5id=="T2S1"
replace mptot=1 if pid=="20150314" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20150314" & cr5id=="T2S1"

replace mpseq=0 if pid=="20150350" & cr5id=="T2S1"
replace mptot=1 if pid=="20150350" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20150350" & cr5id=="T2S1"

replace mpseq=0 if pid=="20150356" & cr5id=="T2S1"
replace mptot=1 if pid=="20150356" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20150356" & cr5id=="T2S1"

replace mpseq=0 if pid=="20150376" & cr5id=="T2S1"
replace mptot=1 if pid=="20150376" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20150376" & cr5id=="T2S1"

replace mpseq=0 if pid=="20150431" & cr5id=="T2S1"
replace mptot=1 if pid=="20150431" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20150431" & cr5id=="T2S1"

replace mpseq=0 if pid=="20150485" & cr5id=="T2S1"
replace mptot=1 if pid=="20150485" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20150485" & cr5id=="T2S1"

replace mpseq=0 if pid=="20150519" & cr5id=="T2S1"
replace mptot=1 if pid=="20150519" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20150519" & cr5id=="T2S1"

replace mpseq=0 if pid=="20151103" & cr5id=="T2S1"
replace mptot=1 if pid=="20151103" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20151103" & cr5id=="T2S1"

replace mpseq=1 if pid=="20080472" & cr5id=="T1S1"
replace mptot=2 if pid=="20080472" & cr5id=="T1S1"
replace mpseq=2 if pid=="20080472" & cr5id=="T2S1"
replace mptot=2 if pid=="20080472" & cr5id=="T2S1"

** Check 3
count if persearch==1 & mpseq>1 //5 - 2 incorrect; //6
//list pid mptot mpseq persearch beh cr5id if persearch==1 & mpseq>1

replace mpseq=1 if pid=="20140570" & cr5id=="T1S1"
replace mptot=2 if pid=="20140570" & cr5id=="T1S1"
replace mpseq=1 if pid=="20140570" & cr5id=="T2S1"
replace mptot=2 if pid=="20140570" & cr5id=="T2S1"

replace mpseq=0 if pid=="20150385" & cr5id=="T1S1"
replace mptot=1 if pid=="20150385" & cr5id=="T1S1"

replace persearch=2 if pid=="20080472" & cr5id=="T2S1"

** Check 4
tab persearch ,m
/*

              Person Search |      Freq.     Percent        Cum.
----------------------------+-----------------------------------
                   Done: OK |      3,773       94.35       94.35
                   Done: MP |         83        2.08       96.42
              Done: Exclude |        143        3.58      100.00
----------------------------+-----------------------------------
                      Total |      3,999      100.00
					  
              Person Search |      Freq.     Percent        Cum.
----------------------------+-----------------------------------
                   Done: OK |      3,805       94.32       94.32
                   Done: MP |         86        2.13       96.46
              Done: Exclude |        143        3.54      100.00
----------------------------+-----------------------------------
                      Total |      4,034      100.00					  
*/


*************
** PATIENT **
*************
order pid cr5id top morph mpseq mptot persearch patient eidmp ptrectot dcostatus

** Check 1
count if patient==1 & persearch==2 //3; 4
//list pid cr5id patient persearch eidmp ptrectot if patient==1 & persearch==2
replace patient=2 if pid=="20080336" & cr5id=="T2S1"
replace eidmp=2 if pid=="20080336" & cr5id=="T2S1"
replace ptrectot=3 if pid=="20080336" & cr5id=="T2S1"

replace patient=2 if pid=="20080365" & cr5id=="T2S1"
replace eidmp=2 if pid=="20080365" & cr5id=="T2S1"
replace ptrectot=3 if pid=="20080365" & cr5id=="T2S1"

replace patient=2 if pid=="20081085" & cr5id=="T2S1"
replace eidmp=2 if pid=="20081085" & cr5id=="T2S1"
replace ptrectot=3 if pid=="20081085" & cr5id=="T2S1"

replace patient=2 if pid=="20080472" & cr5id=="T2S1"
replace eidmp=2 if pid=="20080472" & cr5id=="T2S1"
replace ptrectot=3 if pid=="20080472" & cr5id=="T2S1"

** Check 2
count if patient==2 & persearch==1 //0

** Check 3
tab patient ,m
tab patient persearch ,m

***********
** EIDMP **
***********
** Check 1
count if eidmp==1 & persearch==2 //0

** Check 2
count if eidmp==1 & patient!=1 //0

** Check 3
count if eidmp==2 & patient!=2 //0

** Check 4
tab eidmp ,m
tab eidmp persearch ,m

**************
** PTRECTOT **
**************
** Check 1
count if ptrectot<3 & patient==2 //5
//list pid cr5id patient persearch eidmp ptrectot if ptrectot<3 & patient==2
replace ptrectot=3 if ptrectot<3 & patient==2 //5 changes

** Check 2
count if ptrectot<3 & persearch==2 //0

** Check 3
tab ptrectot ,m

*******************
** MPSEQ + MPTOT **
*******************
** Check 1
count if mptot==. & mpseq==0 //863
replace mptot=1 if mptot==. & mpseq==0 //863 changes

** Check 2
count if mptot==. & mpseq!=0 //19
//list pid cr5id mpseq mptot persearch patient eidmp ptrectot if mptot==. & mpseq!=0
replace mptot=2 if pid=="20140077"
replace cr5id="T2S1" if pid=="20140077" & cr5id=="T3S1"

replace mptot=2 if pid=="20140176"
replace cr5id="T2S1" if pid=="20140176" & cr5id=="T3S1"

replace mptot=2 if pid=="20140339"

replace mpseq=0 if pid=="20140474" & cr5id=="T1S1"
replace mptot=1 if pid=="20140474" & cr5id=="T1S1"

replace mptot=2 if pid=="20140526"

replace mptot=2 if pid=="20140566"

replace mptot=2 if pid=="20140672"

replace mptot=3 if pid=="20140690"
replace mpseq=1 if pid=="20140690" & cr5id=="T1S1"
replace mpseq=2 if pid=="20140690" & cr5id=="T4S1"
replace mpseq=3 if pid=="20140690" & cr5id=="T5S1"
replace cr5id="T2S1" if pid=="20140690" & cr5id=="T4S1"
replace cr5id="T3S1" if pid=="20140690" & cr5id=="T5S1"

replace mptot=2 if pid=="20140786"

replace mpseq=0 if pid=="20140887" & cr5id=="T1S1"
replace mptot=1 if pid=="20140887" & cr5id=="T1S1"

replace mpseq=0 if pid=="20141351" & cr5id=="T1S1"
replace mptot=1 if pid=="20141351" & cr5id=="T1S1"

replace mpseq=1 if pid=="20080539" & cr5id=="T1S1"
replace mptot=2 if pid=="20080539" & cr5id=="T1S1"

** Check 3
count if mpseq!=0 & mptot==1 //593
replace mpseq=0 if mpseq!=0 & mptot==1 //593 changes

** Check 5
tab mptot ,m
tab mpseq ,m
tab mpseq mptot ,m

** Check 6
count if mptot>3 //4
//list pid cr5id mpseq mptot persearch patient eidmp ptrectot if mptot>3

replace mpseq=0 if pid=="20080706" & cr5id=="T1S1"
replace mptot=1 if pid=="20080706" & cr5id=="T1S1"

replace mpseq=0 if pid=="20080715" & cr5id=="T1S1"
replace mptot=1 if pid=="20080715" & cr5id=="T1S1"

replace mpseq=0 if pid=="20080746" & cr5id=="T1S1"
replace mptot=1 if pid=="20080746" & cr5id=="T1S1"

replace mpseq=0 if pid=="20130341" & cr5id=="T1S1"
replace mptot=1 if pid=="20130341" & cr5id=="T1S1"

******************
** Vital Status **
******************

** Check 1
count if dlc!=dod & slc==2 //238
replace dlc=dod if dlc!=dod & slc==2 //48 changes

** Check 2
count if dod!=. & slc!=2 //0

** Check 3
count if slc==2 & deceased!=1 //6
replace deceased=1 if slc==2 & deceased!=1 //6 changes

** Check 4
drop dodyear
gen dodyear=year(dod)
count if dd_dodyear==. & dod!=. //6 - not found in death data but pt deceased //40
count if dodyear==. & dod!=. //0

** Check 5
count if dod==. & slc==2 //0

** Check 6
count if dod==. & deceased==1 //0

** Check 7
count if dcostatus!=6 & slc!=2 //3
replace dcostatus=6 if dcostatus!=6 & slc!=2 //3 changes

** Check 8
count if dcostatus!=2 & basis==0 //1
replace dcostatus=2 if dcostatus!=2 & basis==0 //1 change

** Check 9
tab slc ,m
tab deceased ,m
tab dod ,m
tab dcostatus ,m
tab dcostatus basis ,m

***************
** RECSTATUS **
***************
** Check 1
count if recstatus!=1 //0 //7 - all ineligibles from the imported missed DCOs from MIRs
//list pid cr5id fname lname recstatus if recstatus!=1
drop if recstatus==3 //7 deleted

** Check 2
tab recstatus ,m

***********
** BASIS **
***********
** Check 1
count if basis==. //0

** Check 2
tab basis ,m

***************
** BEHAVIOUR **
***************
** Check 1
count if beh==. //0

** Check 2
tab beh ,m


**************
** SITEIARC **
**************
** Check 1
tab siteiarc ,m

***********
** ICD10 **
***********
** Check 1
count if icd10=="" //0

** Check 2
tab siteicd10 ,m //all correct
//list pid cr5id fname lname icd10 siteiarc if  siteiarc<61 & siteicd10==.

************
** PARISH **
************
** Check 1
count if parish==. //2
replace parish=99 if pid=="20151156"
** Correct address flagged above
preserve
clear
import excel using "`datapath'\version02\2-working\AddressUpdate20210811.xlsx" , firstrow case(lower)
tostring pid ,replace
save "`datapath'\version02\2-working\addressupdate" ,replace
restore
merge 1:1 pid cr5id using "`datapath'\version02\2-working\addressupdate" ,update replace
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         3,998
        from master                     3,998  (_merge==1)
        from using                          0  (_merge==2)

    matched                                 1
        not updated                         0  (_merge==3)
        missing updated                     1  (_merge==4)
        nonmissing conflict                 0  (_merge==5)
    -----------------------------------------
*/
drop _merge

** Check 2
count if parish!=. & parish!=99 & addr=="" //0

** Check 3
count if parish==. & addr!="" & addr!="99" //0

** Check 4
count if parish==. & dd_parish!=.

** Check 5
tab parish ,m
tab parish resident ,m

**************
** RESIDENT **
**************
** Check 1
count if resident==. //0

** Check 2
count if resident!=1 //58

** Check 3
count if resident!=1 & addr!="99" & addr!="" //2 - correct

** Check 4
count if resident!=1 & dd_address!="99" & dd_address!="" //2

** Check 5
count if resident!=1 & natregno!="" & natregno!="9999999999" //37 - correct

** Check 6
tab resident ,m

** Reviewed all non-residents using MedData
order pid cr5id fname lname init age dob natregno resident slc dlc dod top morph mpseq mptot persearch patient eidmp ptrectot dcostatus

** Correct resident flagged above
preserve
clear
import excel using "`datapath'\version02\2-working\ResidentUpdate20210811.xlsx" , firstrow case(lower)
tostring pid ,replace
tostring natregno ,replace
save "`datapath'\version02\2-working\residentupdate" ,replace
restore
merge 1:1 pid cr5id using "`datapath'\version02\2-working\residentupdate" ,update replace
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         3,998
        from master                     3,998  (_merge==1)
        from using                          0  (_merge==2)

    matched                                 1
        not updated                         0  (_merge==3)
        missing updated                     0  (_merge==4)
        nonmissing conflict                 1  (_merge==5)
    -----------------------------------------
*/
drop _merge


*********
** SEX **
*********
** Check 1
tab sex ,m //none missing

*********
** AGE **
*********
** Check 1
count if age==.|age==999 //3

** Check 2
tab age ,m //3 missing - 4 are 100+: f/u was done but age not found

** Check 3
gen age2 = (dot - dob)/365.25
gen checkage2=int(age2)
count if dob!=. & dot!=. & age!=checkage2 //6; 8
//list pid dot dob age checkage2 cr5id if dob!=. & dot!=. & age!=checkage2
replace age=checkage2 if dob!=. & dot!=. & age!=checkage2 //6 changes; 8 changes
drop age2 checkage2


*********
** NRN **
********* 
count if length(natregno)==9 //0
count if length(natregno)==8 //0
count if length(natregno)==7 //0

** Identify possible matches using NRN
preserve
drop if natregno==""|natregno=="9999999999"|regexm(natregno,"9999") 
//remove blank/missing NRNs as these will be flagged as duplicates of each other
//216 deleted
sort natregno 
quietly by natregno : gen dup = cond(_N==1,0,_n)
sort natregno lname fname pid 
count if dup>0 //168; 175 - all MPs: reviewed in Stata's Browse/Edit window
order pid cr5id natregno fname lname
restore

** Remove duplicate registration
drop if pid=="20139979" & cr5id=="T1S1"
replace init="a" if pid=="20139979" & cr5id=="T2S1"
replace ptrectot=3 if pid=="20139979" & cr5id=="T2S1"
replace pid="20080714" if pid=="20139979" & cr5id=="T2S1"
replace mpseq=1 if pid=="20080714" & cr5id=="T1S1"
replace mptot=2 if pid=="20080714" & cr5id=="T1S1"

*********
** DOB **
********* 
preserve
count if dob_iarc=="99999999" //0
replace dob_iarc="" if dob_iarc=="99999999" //0 changes
replace dob_iarc = lower(rtrim(ltrim(itrim(dob_iarc)))) //0 changes
gen dobyear = substr(dob_iarc,1,4)
gen dobmonth = substr(dob_iarc,5,2)
gen dobday = substr(dob_iarc,7,2)
drop if dobyear=="9999" | dobmonth=="99" | dobday=="99" //0 deleted
drop dobday dobmonth dobyear
drop if dob_iarc=="" | dob_iarc=="99999999" //84 deleted

** Look for duplicates - METHOD #1
sort lname fname dob_iarc
quietly by lname fname dob_iarc : gen dup = cond(_N==1,0,_n)
sort lname fname dob_iarc pid
count if dup>0 //182 - mostly MPs: reviewed PIDs in Stata's Browse/Edit
restore

** Corrections from above
drop if pid=="20151107" //1 deleted - this is a duplicate of pid 20155185


***********
** NAMES **
***********
** Convert names to lower case and strip possible leading/trailing blanks
replace fname = lower(rtrim(ltrim(itrim(fname)))) //0 changes
replace init = lower(rtrim(ltrim(itrim(init)))) //0 changes
replace lname = lower(rtrim(ltrim(itrim(lname)))) //0 changes


****************
** DOT + DXYR **
****************
** Check 1
count if dxyr==. //0

** Check 2
count if dot==. //0


** Remove unnecessary variables
drop dot_iarc birthdate
rename dob_iarc birthdate

** Breakdown of in-situ for SF
tab beh dxyr ,m
/*
           |                DiagnosisYear
 Behaviour |      2008       2013       2014       2015 |     Total
-----------+--------------------------------------------+----------
    Benign |         8          0          0          0 |         8 
 Uncertain |        10          0          0          0 |        10 
   In situ |        83          9         24         19 |       135 
 Malignant |     1,054        876        877      1,038 |     3,845 
-----------+--------------------------------------------+----------
     Total |     1,155        885        901      1,057 |     3,998
	 
           |                DiagnosisYear
 Behaviour |      2008       2013       2014       2015 |     Total
-----------+--------------------------------------------+----------
    Benign |         8          0          0          0 |         8 
 Uncertain |        10          0          0          0 |        10 
   In situ |        83          9         24         19 |       135 
 Malignant |     1,056        894        878      1,044 |     3,872 
-----------+--------------------------------------------+----------
     Total |     1,157        903        902      1,063 |     4,025	 
*/

** JC 26-Oct-2020: For quality assessment by IARC Hub, save this corrected dataset with all malignant + non-malignant tumours 2008, 2013-2015
** See p131 version06 for more info on this data request
save "`datapath'\version02\3-output\2008_2013_2014_2015_iarchub_nonsurvival_nonreportable", replace
label data "2008 2013 2014 2015 BNR-Cancer analysed data - Non-survival Dataset for IARC Hub's Data Request"
note: TS This dataset was used for data prep for IARC Hub's quality assessment (see p131 v06)
note: TS Excludes ineligible case definition
note: TS Includes unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs

** Removing cases not included for reporting: if case with MPs ensure record with persearch=1 is not dropped as used in survival dataset
drop if resident==2 //3 deleted - nonresident
drop if resident==99 //54 deleted - resident unknown
drop if recstatus==3 //0 deleted - ineligible case definition
drop if sex==9 //0 deleted - sex unknown
drop if beh!=3 //151 deleted - non malignant
drop if persearch>2 //0 deleted
drop if siteiarc==25 //228 - non reportable skin cancers

** Check for cases wherein the non-reportable cancer had the below MP categories as the primary options
duplicates tag pid, gen(dup_pid)
count if dup_pid>0 //119; 123
count if dup_pid==0 //3443; 3466
//list pid cr5id dup_pid persearch patient eidmp ptrectot mpseq mptot if dup_pid>0, nolabel sepby(pid)
//list pid cr5id dup_pid persearch patient eidmp ptrectot mpseq mptot if dup_pid==0, nolabel sepby(pid)

replace mptot=2 if pid=="20140690" //2 changes

count if dup_pid==0 & persearch>1 //6; 7
//list pid cr5id dup_pid persearch patient eidmp ptrectot mpseq mptot if dup_pid==0 & persearch>1

replace mpseq=0 if pid=="20080336" & cr5id=="T2S1"
replace mptot=1 if pid=="20080336" & cr5id=="T2S1"
replace persearch=1 if pid=="20080336" & cr5id=="T2S1"
replace patient=1 if pid=="20080336" & cr5id=="T2S1"
replace eidmp=1 if pid=="20080336" & cr5id=="T2S1"
replace ptrectot=1 if pid=="20080336" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20080336" & cr5id=="T2S1"

replace mpseq=0 if pid=="20080365" & cr5id=="T2S1"
replace mptot=1 if pid=="20080365" & cr5id=="T2S1"
replace persearch=1 if pid=="20080365" & cr5id=="T2S1"
replace patient=1 if pid=="20080365" & cr5id=="T2S1"
replace eidmp=1 if pid=="20080365" & cr5id=="T2S1"
replace ptrectot=1 if pid=="20080365" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20080365" & cr5id=="T2S1"

replace mpseq=0 if pid=="20080626" & cr5id=="T3S1"
replace mptot=1 if pid=="20080626" & cr5id=="T3S1"
replace persearch=1 if pid=="20080626" & cr5id=="T3S1"
replace patient=1 if pid=="20080626" & cr5id=="T3S1"
replace eidmp=1 if pid=="20080626" & cr5id=="T3S1"
replace ptrectot=1 if pid=="20080626" & cr5id=="T3S1"
replace cr5id="T1S1" if pid=="20080626" & cr5id=="T3S1"

replace mpseq=0 if pid=="20080696" & cr5id=="T2S1"
replace mptot=1 if pid=="20080696" & cr5id=="T2S1"
replace persearch=1 if pid=="20080696" & cr5id=="T2S1"
replace patient=1 if pid=="20080696" & cr5id=="T2S1"
replace eidmp=1 if pid=="20080696" & cr5id=="T2S1"
replace ptrectot=1 if pid=="20080696" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20080696" & cr5id=="T2S1"

replace mpseq=0 if pid=="20080728" & cr5id=="T3S1"
replace mptot=1 if pid=="20080728" & cr5id=="T3S1"
replace persearch=1 if pid=="20080728" & cr5id=="T3S1"
replace patient=1 if pid=="20080728" & cr5id=="T3S1"
replace eidmp=1 if pid=="20080728" & cr5id=="T3S1"
replace ptrectot=1 if pid=="20080728" & cr5id=="T3S1"
replace cr5id="T1S1" if pid=="20080728" & cr5id=="T3S1"

replace mpseq=0 if pid=="20081085" & cr5id=="T2S1"
replace mptot=1 if pid=="20081085" & cr5id=="T2S1"
replace persearch=1 if pid=="20081085" & cr5id=="T2S1"
replace patient=1 if pid=="20081085" & cr5id=="T2S1"
replace eidmp=1 if pid=="20081085" & cr5id=="T2S1"
replace ptrectot=1 if pid=="20081085" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20081085" & cr5id=="T2S1"

replace mpseq=0 if pid=="20080472" & cr5id=="T2S1"
replace mptot=1 if pid=="20080472" & cr5id=="T2S1"
replace persearch=1 if pid=="20080472" & cr5id=="T2S1"
replace patient=1 if pid=="20080472" & cr5id=="T2S1"
replace eidmp=1 if pid=="20080472" & cr5id=="T2S1"
replace ptrectot=2 if pid=="20080472" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20080472" & cr5id=="T2S1"

drop dup_pid


** JC 03-Jun-2021: For quality assessment by IARC Hub, save this corrected dataset with all malignant (non-reportable skin + non-malignant tumours removed) for 2008, 2013-2015
** See p131 version06 for more info on this data request
save "`datapath'\version02\3-output\2008_2013_2014_2015_iarchub_nonsurvival_reportable", replace
label data "2008 2013 2014 2015 BNR-Cancer analysed data - Non-survival Dataset for IARC Hub's Data Request"
note: TS This dataset was used for data prep for IARC Hub's quality assessment (see p131 v06)
note: TS Excludes ineligible case definition
note: TS Excludes ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs

** For 2015 annaul report remove 2008 cases as decided by NS on 06-Oct-2020, email subject: BNR-C: 2015 cancer stats tables completed
drop if dxyr==2008 //812 deleted; 814 deleted


** Removing cases not included for reporting: if case with MPs ensure record with persearch=1 is not dropped as used in survival dataset
drop if resident==2 //0 deleted - nonresident
drop if resident==99 //0 deleted - resident unknown
drop if recstatus==3 //0 deleted - ineligible case definition
drop if sex==9 //0 deleted - sex unknown
drop if beh!=3 //0 deleted - non malignant
drop if persearch>2 //0 deleted
drop if siteiarc==25 //0 - non reportable skin cancers

** Check for cases wherein the non-reportable cancer had the below MP categories as the primary options
duplicates tag pid, gen(dup_pid)
count if dup_pid>0 //84; 86
count if dup_pid==0 //2666; 2689
//list pid cr5id dup_pid persearch patient eidmp ptrectot mpseq mptot if dup_pid>0, nolabel sepby(pid)
//list pid cr5id dup_pid persearch patient eidmp ptrectot mpseq mptot if dup_pid==0, nolabel sepby(pid)

count if dup_pid==0 & persearch>1 //11; 12
//list pid cr5id dup_pid persearch patient eidmp ptrectot mpseq mptot if dup_pid==0 & persearch>1

replace mpseq=0 if pid=="20080048" & cr5id=="T2S1"
replace mptot=1 if pid=="20080048" & cr5id=="T2S1"
replace persearch=1 if pid=="20080048" & cr5id=="T2S1"
replace patient=1 if pid=="20080048" & cr5id=="T2S1"
replace eidmp=1 if pid=="20080048" & cr5id=="T2S1"
replace ptrectot=1 if pid=="20080048" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20080048" & cr5id=="T2S1"

replace mpseq=0 if pid=="20080242" & cr5id=="T2S1"
replace mptot=1 if pid=="20080242" & cr5id=="T2S1"
replace persearch=1 if pid=="20080242" & cr5id=="T2S1"
replace patient=1 if pid=="20080242" & cr5id=="T2S1"
replace eidmp=1 if pid=="20080242" & cr5id=="T2S1"
replace ptrectot=1 if pid=="20080242" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20080242" & cr5id=="T2S1"

replace mpseq=0 if pid=="20080295" & cr5id=="T3S1"
replace mptot=1 if pid=="20080295" & cr5id=="T3S1"
replace persearch=1 if pid=="20080295" & cr5id=="T3S1"
replace patient=1 if pid=="20080295" & cr5id=="T3S1"
replace eidmp=1 if pid=="20080295" & cr5id=="T3S1"
replace ptrectot=1 if pid=="20080295" & cr5id=="T3S1"
replace cr5id="T1S1" if pid=="20080295" & cr5id=="T3S1"

replace mpseq=0 if pid=="20080340" & cr5id=="T2S1"
replace mptot=1 if pid=="20080340" & cr5id=="T2S1"
replace persearch=1 if pid=="20080340" & cr5id=="T2S1"
replace patient=1 if pid=="20080340" & cr5id=="T2S1"
replace eidmp=1 if pid=="20080340" & cr5id=="T2S1"
replace ptrectot=1 if pid=="20080340" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20080340" & cr5id=="T2S1"

replace mpseq=0 if pid=="20080401" & cr5id=="T2S1"
replace mptot=1 if pid=="20080401" & cr5id=="T2S1"
replace persearch=1 if pid=="20080401" & cr5id=="T2S1"
replace patient=1 if pid=="20080401" & cr5id=="T2S1"
replace eidmp=1 if pid=="20080401" & cr5id=="T2S1"
replace ptrectot=1 if pid=="20080401" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20080401" & cr5id=="T2S1"

replace mpseq=0 if pid=="20080539" & cr5id=="T2S1"
replace mptot=1 if pid=="20080539" & cr5id=="T2S1"
replace persearch=1 if pid=="20080539" & cr5id=="T2S1"
replace patient=1 if pid=="20080539" & cr5id=="T2S1"
replace eidmp=1 if pid=="20080539" & cr5id=="T2S1"
replace ptrectot=1 if pid=="20080539" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20080539" & cr5id=="T2S1"

replace mpseq=0 if pid=="20080567" & cr5id=="T2S1"
replace mptot=1 if pid=="20080567" & cr5id=="T2S1"
replace persearch=1 if pid=="20080567" & cr5id=="T2S1"
replace patient=1 if pid=="20080567" & cr5id=="T2S1"
replace eidmp=1 if pid=="20080567" & cr5id=="T2S1"
replace ptrectot=1 if pid=="20080567" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20080567" & cr5id=="T2S1"

replace mpseq=0 if pid=="20080636" & cr5id=="T2S1"
replace mptot=1 if pid=="20080636" & cr5id=="T2S1"
replace persearch=1 if pid=="20080636" & cr5id=="T2S1"
replace patient=1 if pid=="20080636" & cr5id=="T2S1"
replace eidmp=1 if pid=="20080636" & cr5id=="T2S1"
replace ptrectot=1 if pid=="20080636" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20080636" & cr5id=="T2S1"

replace mpseq=0 if pid=="20080679" & cr5id=="T2S1"
replace mptot=1 if pid=="20080679" & cr5id=="T2S1"
replace persearch=1 if pid=="20080679" & cr5id=="T2S1"
replace patient=1 if pid=="20080679" & cr5id=="T2S1"
replace eidmp=1 if pid=="20080679" & cr5id=="T2S1"
replace ptrectot=1 if pid=="20080679" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20080679" & cr5id=="T2S1"

replace mpseq=0 if pid=="20080690" & cr5id=="T2S1"
replace mptot=1 if pid=="20080690" & cr5id=="T2S1"
replace persearch=1 if pid=="20080690" & cr5id=="T2S1"
replace patient=1 if pid=="20080690" & cr5id=="T2S1"
replace eidmp=1 if pid=="20080690" & cr5id=="T2S1"
replace ptrectot=1 if pid=="20080690" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20080690" & cr5id=="T2S1"

replace mpseq=0 if pid=="20081058" & cr5id=="T2S1"
replace mptot=1 if pid=="20081058" & cr5id=="T2S1"
replace persearch=1 if pid=="20081058" & cr5id=="T2S1"
replace patient=1 if pid=="20081058" & cr5id=="T2S1"
replace eidmp=1 if pid=="20081058" & cr5id=="T2S1"
replace ptrectot=1 if pid=="20081058" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20081058" & cr5id=="T2S1"

replace mpseq=0 if pid=="20080714" & cr5id=="T2S1"
replace mptot=1 if pid=="20080714" & cr5id=="T2S1"
replace persearch=1 if pid=="20080714" & cr5id=="T2S1"
replace patient=1 if pid=="20080714" & cr5id=="T2S1"
replace eidmp=1 if pid=="20080714" & cr5id=="T2S1"
replace ptrectot=2 if pid=="20080714" & cr5id=="T2S1"
replace cr5id="T1S1" if pid=="20080714" & cr5id=="T2S1"

count if dup_pid==0 & mptot>1 //206
count if dup_pid==0 & mpseq>0 //206
//list pid cr5id fname lname mpseq mptot eidmp if dup_pid==0 & mptot>1

replace mpseq=0 if dup_pid==0 & mpseq>0 //206 changes
replace mptot=1 if dup_pid==0 & mptot>1 //206 changes

count //2750; 2775

** Save this corrected dataset with internationally reportable cases
save "`datapath'\version02\3-output\2013_2014_2015_cancer_nonsurvival", replace
label data "2013 2014 2015 BNR-Cancer analysed data - Non-survival Dataset"
note: TS This dataset was used for 2015 annual report
note: TS Excludes IARC flag, ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs

** Run IARC conversion, consistency checks and MP check one last time
** Assign IARC flag values based on outcomes of these checks (use IARC DQ assessment outputs from Sarah where I checked some of these warnings already)

*****************************
** IARCcrgTools check + MP **
*****************************

** Copy the variables needed in Stata's Browse/Edit into an excel sheet in 2-working folder
//replace mpseq=1 if mpseq==0 //2918 changes
tab mpseq ,m //3 missing
//list pid fname lname mptot if mpseq==. //reviewed in Stata's Browse/Edit + CR5db
replace mptot=1 if mpseq==. & mptot==. //3 changes
replace mpseq=1 if mpseq==. //3 changes

tab icd10 ,m //none missing

** Create dates for use in IARCcrgTools
//drop dob_iarc dot_iarc

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
replace BIRTHD="" if BIRTHD=="..." //27 changes
drop BIRTHDAY BIRTHMONTH BIRTHYR BIRTHMM BIRTHDD
rename BIRTHD dob_iarc
label var dob_iarc "IARC BirthDate"

** Organize the variables to be used in IARCcrgTools to appear at start of the dataset in Browse/Edit
order pid sex top morph beh grade basis dot_iarc dob_iarc age mpseq mptot cr5id iarcflag
** Note: to copy results without value labels, I had to right-click Browse/Edit data, select Preferences --> Data Editor --> untick 'Copy value labels to the Clipboard instead of values'.
//Excel saved as .csv in 2-working\iarccrgtoolsV03.csv - added in mptot, cr5id + iarcflag to spot any errors in these fields

** Using the IARC Hub's guide, I prepared the excel sheet for use in IARCcrgTools, i.e. re-inserted leading zeros into topography.
** IARCcrgTools Check results
/*
IARC-Check program - Monday 01 November 2021-20:30
Input file: X:\The University of the West Indies\DataGroup - repo_data\data_p117\version02\2-working\Formatted dataset_20211101V02.prn
Output file: X:\The University of the West Indies\DataGroup - repo_data\data_p117\version02\2-working\Checked dataset_20211101V02.prn

2775 records processed. Summary statistics:

0 errors

75 warnings (73 individual records) recorded in X:\The University of the West Indies\DataGroup - repo_data\data_p117\version02\2-working\Formatted dataset_20211101V02.chk:

28 unlikely histology/site combination
21 unlikely grade/histology combination
25 unlikely basis/histology combination
1 unlikely age/site/histology combination
*/

** Assign IARC flag to the checked records then to all other records
replace iarcflag=2 if pid=="20130002" & cr5id=="T1S1"|pid=="20130093" & cr5id=="T1S1"|pid=="20130127" & cr5id=="T1S1"|pid=="20130137" & cr5id=="T1S1" ///
					  |pid=="20130169" & cr5id=="T1S1"|pid=="20130176" & cr5id=="T1S1"|pid=="20130192" & cr5id=="T1S1"|pid=="20130198" & cr5id=="T1S1" ///
					  |pid=="20130201" & cr5id=="T1S1"|pid=="20130226" & cr5id=="T1S1"|pid=="20130229" & cr5id=="T1S1"|pid=="20130251" & cr5id=="T1S1" ///
					  |pid=="20130264" & cr5id=="T1S1"|pid=="20130321" & cr5id=="T1S1"|pid=="20130341" & cr5id=="T1S1"|pid=="20130383" & cr5id=="T1S1" ///
					  |pid=="20130416" & cr5id=="T1S1"|pid=="20130426" & cr5id=="T1S1"|pid=="20130590" & cr5id=="T1S1"|pid=="20130594" & cr5id=="T1S1" ///
					  |pid=="20130727" & cr5id=="T1S1"|pid=="20130761" & cr5id=="T1S1"|pid=="20130819" & cr5id=="T1S1"|pid=="20139991" & cr5id=="T1S1" ///
					  |pid=="20139994" & cr5id=="T1S1"|pid=="20140058" & cr5id=="T1S1"|pid=="20140190" & cr5id=="T1S1"|pid=="20140228" & cr5id=="T1S1" ///
					  |pid=="20140256" & cr5id=="T1S1"|pid=="20140395" & cr5id=="T1S1"|pid=="20140525" & cr5id=="T1S1"|pid=="20140558" & cr5id=="T1S1" ///
					  |pid=="20140570" & cr5id=="T2S1"|pid=="20140573" & cr5id=="T1S1"|pid=="20140622" & cr5id=="T1S1"|pid=="20140687" & cr5id=="T1S1" ///
					  |pid=="20140707" & cr5id=="T1S1"|pid=="20141535" & cr5id=="T1S1"|pid=="20141542" & cr5id=="T1S1"|pid=="20141558" & cr5id=="T1S1" ///
					  |pid=="20145112" & cr5id=="T1S1"|pid=="20150019" & cr5id=="T1S1"|pid=="20150094" & cr5id=="T1S1"|pid=="20150096" & cr5id=="T1S1" ///
					  |pid=="20150132" & cr5id=="T1S1"|pid=="20150139" & cr5id=="T1S1"|pid=="20150165" & cr5id=="T1S1"|pid=="20150182" & cr5id=="T1S1" ///
					  |pid=="20150249" & cr5id=="T1S1"|pid=="20150293" & cr5id=="T1S1"|pid=="20150295" & cr5id=="T1S1"|pid=="20150336" & cr5id=="T1S1" ///
					  |pid=="20150373" & cr5id=="T1S1"|pid=="20150506" & cr5id=="T1S1"|pid=="20150574" & cr5id=="T1S1"|pid=="20151366" & cr5id=="T1S1" ///
					  |pid=="20155003" & cr5id=="T1S1"|pid=="20155008" & cr5id=="T1S1"|pid=="20155015" & cr5id=="T1S1"|pid=="20155035" & cr5id=="T1S1" ///
					  |pid=="20155047" & cr5id=="T1S1"|pid=="20155061" & cr5id=="T1S1"|pid=="20155197" & cr5id=="T1S1"|pid=="20155229" & cr5id=="T1S1" ///
					  |pid=="20155245" & cr5id=="T1S1"|pid=="20155255" & cr5id=="T1S1"|pid=="20159074" & cr5id=="T1S1"|pid=="20159077" & cr5id=="T1S1" ///
					  |pid=="20159102" & cr5id=="T1S1"|pid=="20159128" & cr5id=="T1S1"|pid=="20159129" & cr5id=="T1S1"|pid=="20180030" & cr5id=="T1S1"
//69 changes

replace iarcflag=1 if pid=="20130081" & cr5id=="T1S1" //1 change

replace top="069" if pid=="20130081" & cr5id=="T1S1"
replace topography=69 if pid=="20130081" & cr5id=="T1S1"
replace primarysite="MOUTH" if pid=="20130081" & cr5id=="T1S1"

tab iarcflag ,m
/*
  IARC Flag |      Freq.     Percent        Cum.
------------+-----------------------------------
         OK |         23        0.83        0.83
    Checked |         72        2.59        3.42
          . |      2,680       96.58      100.00
------------+-----------------------------------
      Total |      2,775      100.00
*/

replace iarcflag=1 if iarcflag==. //2680 changes

count //2775

** Export the data for SF to use to create graphs
capture export_excel using "`datapath'\version02\3-output\2013-2015BNRnonsurvivalV08.xlsx", sheet("2013_2014_2015_20210812") firstrow(varlabels) replace

** Save this corrected dataset with internationally reportable cases
save "`datapath'\version02\3-output\2013_2014_2015_cancer_ci5", replace
label data "2013 2014 2015 BNR-Cancer analysed data - CI5 Vol.XII Submission Dataset"
note: TS This dataset was used for 2013-2015 CI5 submission Vol. XII
note: TS Excludes ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs
