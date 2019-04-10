** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			3_2008_2013_dc_v01.do
    //  project:				BNR
    //  analysts:				Jacqueline CAMPBELL
    //  date first created      19-MAR-2019
    // 	date last modified	    19-MAR-2019
    //  algorithm task			Cleaning 2008 & 2013 cancer datasets, Creating site groupings
    //  release version         v01: using CanReg5 BNR-CLEAN 18-Mar-2019 dataset
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
    log using "`logpath'\3_2008_2013_dc.smcl", replace
** HEADER -----------------------------------------------------

* ***************************************************************************************************************
* MERGING
* Using cancer dataset and death dataset
* (1) merge using nrn
*****************************************************************************************************************

** Load the dataset with recently matched death data
use "`datapath'\version01\2-working\2008_2013_cancer_dp", clear

count //2,608


** Corrections based on updates already found when doing cleaning for NAACCR-IACR 
** (some may already be corrected as using different dataset than the one originally used that found these errors)
replace natregno="210620-0062" if pid=="20080497"
replace natregno="201130-0080" if pid=="20080730"
replace natregno="260722-7002" if pid=="20080457"
replace natregno="250323-0068" if pid=="20081054"
replace natregno="341125-0024" if pid=="20080305"
replace natregno="430906-7017" if pid=="20080739"
replace natregno="250612-8012" if pid=="20080738"
replace natregno="270715-0039" if pid=="20080462"
replace natregno="500612-8002" if pid=="20080686"
replace natregno="240612-0010" if pid=="20080484"
replace natregno="340429-0011" if pid=="20080353"
replace natregno="200830-0093" if pid=="20080416"
replace natregno="300620-0046" if pid=="20080043"
replace natregno="250312-0012" if pid=="20080434"
replace natregno="310330-0038" if pid=="20081064"
replace natregno="250808-0104" if pid=="20080432"
replace natregno="300408-0010" if pid=="20080472"
replace natregno="170830-8000" if pid=="20080435"
replace natregno="360916-0068" if pid=="20080543"
replace natregno="360713-8033" if pid=="20080410"
replace natregno="300902-0011" if pid=="20080578"
replace natregno="471204-0015" if pid=="20080341"
replace natregno="430601-8054" if pid=="20080719"
replace natregno="321017-0076" if pid=="20080327"
replace natregno="220929-0051" if pid=="20080775"
replace natregno="270112-0038" if pid=="20080576"

replace natregno="441219-0078" if pid=="20130772"
replace natregno="430916-0127" if pid=="20130361"
replace natregno="290210-0134" if pid=="20130396"
replace natregno="470831-0059" if pid=="20130886"
replace natregno="460928-0146" if pid=="20130814"
replace natregno="461123-0063" if pid=="20130818"
replace natregno="190511-0027" if pid=="20130661"
replace natregno="421121-9999" if pid=="20130650"
replace natregno="560725-0072" if pid=="20130696"
replace natregno="471124-0012" if pid=="20130830"
replace natregno="300608-0059" if pid=="20130362"
replace natregno="841016-0041" if pid=="20130674"
replace natregno="610630-0103" if pid=="20130631"
replace natregno="370126-0030" if pid=="20130426"
replace natregno="490110-0091" if pid=="20130813"
replace natregno="450902-0022" if pid=="20130374"
replace natregno="440214-0018" if pid=="20130874"
replace natregno="280214-0042" if pid=="20130319"

replace natregno="190923-0052" if pid=="20080421"
replace natregno="590829-9999" if pid=="20080177"
replace natregno="291003-0077" if pid=="20080344"
replace natregno="430715-0054" if pid=="20080766"
replace natregno="240826-0038" if pid=="20080465"
replace natregno="320518-0056" if pid=="20080592"
replace natregno="230104-0040" if pid=="20080301"
replace natregno="221127-0018" if pid=="20080377"
replace natregno="221219-0066" if pid=="20080654"
replace natregno="320402-7019" if pid=="20080450"
replace natregno="491113-0039" if pid=="20081109"
replace natregno="250906-0022" if pid=="20080461"
replace natregno="310705-0050" if pid=="20080533"
replace natregno="361011-0078" if pid=="20080504"
replace natregno="210130-0107" if pid=="20080476"
replace natregno="120821-8006" if pid=="20080385"
replace natregno="220708-9999" if pid=="20080205"
replace natregno="360722-7034" if pid=="20080720"
replace natregno="300818-7001" if pid=="20080740"

replace natregno="321016-0069" if pid=="20080494"
replace natregno="331130-0150" if pid=="20080978"
replace natregno="371114-0016" if pid=="20080965"
replace natregno="570327-0065" if pid=="20080001"

count //2,608

** In prep for merge, remove nrn variable as this a repeat of natregno
rename natregno nrn

merge m:1 nrn using "`datapath'\version01\2-working\2008-2017_redcap_deaths_nrn_dp"
/*
POST-CORRECTIONS
    Result                           # of obs.
    -----------------------------------------
    not matched                        22,199
        from master                     1,339  (_merge==1)
        from using                     20,860  (_merge==2)

    matched                             1,269  (_merge==3)
    -----------------------------------------
*/

** Check all merges are correct by comparing patient name in cancer dataset with patient name in death dataset
count if _merge==3 //1,290
//list pid deathid fname lname pname if _merge==3 ,notrim

gen pnameextra=fname+" "+lname
count if _merge==3 & pname!=pnameextra //408 - corrected in dofiles 2 and 3 and redcap db so now count==385 which are correct
//list pid deathid pname* if _merge==3 & pname!=pnameextra

** Remove unmatched deaths (didn't merge)
count if pid=="" //20,860
drop if pid=="" //20,860 deleted

rename nrn natregno

count //2,608

** Checking if any 2014 cancers didn't merge with deaths when cleaning done (see 2014 cleaning dofile '5_merge_cancer_dc.do' and BNR-CLEAN CanReg5 db)
count if slc!=2 & dod!=. //300
//list pid deathid slc dod if slc!=2 & dod!=.
replace slc=2 if slc!=2 & dod!=. //300 changes
sort pid
//list pid fname lname dod dxyr recstatus cr5id if slc==2
//list pid fname lname dod dxyr recstatus cr5id if slc==2 & (dxyr==2014|dxyr==.) //all 2014 cases were merged in previous dofile 5 above


* ************************************************************************
* CLEANING
* Using version02 dofiles created in 2014 data review folder (Sync) as 
* this previously flagged (not corrected) errors in 2008 & 2013 data that
* were then updated in BNR-CLEAN CanReg5 db by Shelly Forde.
**************************************************************************
/* 
Remove duplicates - first identify & label duplicate tumour and sources

Each multiple sources from CR5 dataset is imported into Stata as 
a separate observation and some tumour records are multiple sources for the abstracted tumour
so need to differentiate between 
multiple (duplicate) sources (MSs) for same pt vs multiple (primary) tumours (MPs) for same pt:
(1) The MSs will assessed for data quality index then dropped before death merge;
(2) The MPs will be kept throughout datasets.
*/
gen dupsource=0 //2,608
label var dupsource "Multiple Sources"
label define dupsource_lab  1 "MS-Conf Tumour Rec" 2 "MS-Conf Source Rec" ///
							3 "MS-Dup Tumour Rec" 4 "MS-Dup Tumour & Source Rec" ///
							5 "MS-Ineligible Tumour 1 Rec" 6 "MS-Ineligible Tumour 2~ & Source Rec" , modify
label values dupsource dupsource_lab

replace dupsource=1 if recstatus==1 & regexm(cr5id,"S1") //2,040 - this is the # eligible non-duplicate tumours
replace dupsource=2 if recstatus==1 & !strmatch(strupper(cr5id), "*S1") //136
replace dupsource=3 if recstatus==4 & regexm(cr5id,"S1") //160
replace dupsource=4 if recstatus==4 & !strmatch(strupper(cr5id), "*S1") //3
replace dupsource=5 if recstatus==3 & cr5id=="T1S1" //126
replace dupsource=6 if recstatus==3 & cr5id!="T1S1" //134

** Now identify MPs (multiple tumours for same pt) among eligible non-duplicate tumours (921; 955)
tab pid if dupsource==1

sort pid
bysort pid: gen duppid = _n if dupsource==1 //568 missing values so 2,040 changes

sort pid
bysort pid: gen duppid_all = _n

tab duppid_all ,m
sort lname fname pid

** Based on cr5id and dupsource, create variable to identify MPs
gen eidmp=1 if regexm(cr5id, "T1") & dupsource==1 //699 missing values - 1,909 changes
replace eidmp=2 if !strmatch(strupper(cr5id), "T1*") & dupsource==1 //131 changes
label var eidmp "CR5 tumour events"
label define eidmp_lab 1 "single tumour" 2 "multiple tumour" ,modify
label values eidmp eidmp_lab

** Check eidmp properly assigned
count if eidmp==1 & recstatus!=1 //0
count if eidmp==2 & recstatus!=1 //0
count if eidmp==. //568
count if eidmp==. & recstatus==1 //136
sort pid
list pid cr5id dupsource if eidmp==. & recstatus==1

** Create variable to identify patient records
gen ptrectot=. //2,608 missing values
replace ptrectot=1 if eidmp==1 //1,909 changes
replace ptrectot=3 if eidmp==2 //131 changes
label define ptrectot_lab 1 "CR5 pt with single event" 2 "DCO with single event" 3 "CR5 pt with multiple events" ///
						  4 "DCO with multiple events" 5 "CR5 pt: single event but multiple DC events" , modify
label values ptrectot ptrectot_lab
/*
Now check:
	eidmp and ptrectot are correctly assigned as patient records with 2 separate tumours may have both tumours (or only 1 confirmed/eligible tumour) listed as MP
    use Stata browse/edit and filter by pid in below list
*/
count if eidmp==2 & dupsource==1 //131
order pid cr5id dupsource eidmp ptrectot recstatus fname lname
//list pid ptrectot cr5id fname lname if eidmp==2 & dupsource==1

replace ptrectot=1 if pid=="20080310" & cr5id=="T2S1" & ptrectot!=. //1 change
replace eidmp=1 if pid=="20080310" & cr5id=="T2S1" & eidmp!=. //1 change
replace ptrectot=1 if pid=="20080384" & cr5id=="T2S1" & ptrectot!=. //1 change
replace eidmp=1 if pid=="20080384" & cr5id=="T2S1" & eidmp!=. //1 change
replace ptrectot=1 if pid=="20080387" & cr5id=="T2S1" & ptrectot!=. //1 change
replace eidmp=1 if pid=="20080387" & cr5id=="T2S1" & eidmp!=. //1 change
replace ptrectot=1 if pid=="20080438" & cr5id=="T2S1" & ptrectot!=. //1 change
replace eidmp=1 if pid=="20080438" & cr5id=="T2S1" & eidmp!=. //1 change
replace ptrectot=1 if pid=="20080477" & cr5id=="T3S1" & ptrectot!=. //1 change
replace eidmp=1 if pid=="20080477" & cr5id=="T3S1" & eidmp!=. //1 change
replace ptrectot=1 if pid=="20080690" & cr5id=="T2S1" & ptrectot!=. //1 change
replace eidmp=1 if pid=="20080690" & cr5id=="T2S1" & eidmp!=. //1 change
replace ptrectot=1 if pid=="20090016" & cr5id=="T2S1" & ptrectot!=. //1 change
replace eidmp=1 if pid=="20090016" & cr5id=="T2S1" & eidmp!=. //1 change
replace ptrectot=1 if pid=="20090045" & cr5id=="T3S1" & ptrectot!=. //1 change
replace eidmp=1 if pid=="20090045" & cr5id=="T3S1" & eidmp!=. //1 change
replace ptrectot=1 if pid=="20130169" & cr5id=="T2S1" & ptrectot!=. //1 change
replace eidmp=1 if pid=="20130169" & cr5id=="T2S1" & eidmp!=. //1 change
replace ptrectot=1 if pid=="20130172" & cr5id=="T2S1" & ptrectot!=. //1 change
replace eidmp=1 if pid=="20130172" & cr5id=="T2S1" & eidmp!=. //1 change
replace ptrectot=1 if pid=="20130727" & cr5id=="T2S1" & ptrectot!=. //1 change
replace eidmp=1 if pid=="20130727" & cr5id=="T2S1" & eidmp!=. //1 change
replace ptrectot=1 if pid=="20130798" & cr5id=="T2S1" & ptrectot!=. //1 change
replace eidmp=1 if pid=="20130798" & cr5id=="T2S1" & eidmp!=. //1 change


** Count # of patients with eligible non-dup tumours
count if ptrectot==1 //1,921

** Count # of eligible non-dup tumours
count if eidmp==1 //1,921

** Count # of eligible non-dup MPs
count if eidmp==2 //119

** Count # of patients with eligible non-dup tumours (2008)
count if ptrectot==1 & dxyr==2008 //1,113

** Count # of eligible non-dup tumours (2008)
count if eidmp==1 & dxyr==2008 //1,113

** Count # of eligible non-dup MPs (2008)
count if eidmp==2 & dxyr==2008 //96

** Count # of patients with eligible non-dup tumours (2013)
count if ptrectot==1 & dxyr==2013 //804

** Count # of eligible non-dup tumours (2013)
count if eidmp==1 & dxyr==2013 //804

** Count # of eligible non-dup MPs (2013)
count if eidmp==2 & dxyr==2013 //14


** Check for cases where T1 is not the abstraction
count if primarysite=="" & cr5id=="T1S1" //already corrected above

** Need to remove duplicate records
drop if eidmp==. //568 deleted

count //2,040
count if dxyr==2008 //1,209
count if dxyr==2008 & eidmp==2 //96
count if dxyr==2013 //818
count if dxyr==2013 & eidmp==2 //14

** Check for no missing icd10 values as need this for site groupings later
rename ICD10 icd10
rename ICCCcode iccc
count if icd10=="" //0

** Label non-reportable skin cancers
count if regexm(icd10,"C44") //304
gen skin=1 if regexm(icd10,"C44") //1,736 missing so 304 changes


** Add 'missed' 2013 cases found while cleaning 2014 data
** Ensure these are 'true' missed cases by checking dataset with 30 missed cases against this dataset
append using "`datapath'\version01\1-input\2013_cancer_clean_nodups_dc"
drop if pid=="20130338" & cr5id=="T1S1" & deathid=="14987"
replace deathid=20582 if pid=="20130338"


CHECK missed 2013 cases against this dataset then APPEND 2013 missed cases, next site groupings, then mortality, then onto analysis

** DROP all cases dx in 2014 onwards as 2014 cases already cleaned
** pre-2014 cases are to be cleaned
count if dxyr==. //0
count if dxyr!=2008 & dxyr!=2013 //13
drop if dxyr>2013 //13 deleted


* ************************************************************************
* SITE GROUPINGS
* Using ...?
**************************************************************************



count //

** Put variables in order you want them to appear
order pid fname lname init age sex dob natregno resident slc dlc ///
	    parish cr5cod primarysite morph top lat beh hx

save "`datapath'\version01\2-working\2008_2013_cancer_dc" ,replace
label data "BNR-Cancer prepared 2008 & 2013 data"
notes _dta :These data prepared for 2008 & 2013 inclusion in 2014 cancer report
