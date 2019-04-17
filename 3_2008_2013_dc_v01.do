** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			3_2008_2013_dc_v01.do
    //  project:				BNR
    //  analysts:				Jacqueline CAMPBELL
    //  date first created      19-MAR-2019
    // 	date last modified	    16-APR-2019
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
    log using "`logpath'\3_2008_2013_dc_v01.smcl", replace
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


** Check all deceased have been merged with national death data
count if slc==2 & cod1a=="" //129
sort pid
list pid fname lname natregno dod cr5id if slc==2 & cod1a=="" //Check these names against redcap death data
replace deathid=349 if pid=="20080081"
replace deathid=970 if pid=="20080086"
replace deathid=809 if pid=="20080089"
replace deathid=1967 if pid=="20080091"
replace deathid=1119 if pid=="20080108"
replace deathid=2378 if pid=="20080113"
replace deathid=263 if pid=="20080115"
replace deathid=1928 if pid=="20080118"
replace deathid=626 if pid=="20080122"
replace deathid=1651 if pid=="20080126"
replace deathid=4612 if pid=="20080127"
replace deathid=6277 if pid=="20080131"
replace deathid=1211 if pid=="20080138"
replace deathid=4393 if pid=="20080210"
replace deathid=4075 if pid=="20080271"
replace deathid=9774 if pid=="20080297"
replace deathid=4019 if pid=="20080299"
replace deathid=1810 if pid=="20080309"
replace deathid=3122 if pid=="20080355"
replace deathid=7444 if pid=="20080359"
replace deathid=9037 if pid=="20080411"
replace deathid=5676 if pid=="20080464" //2 changes
replace deathid=357 if pid=="20080478"
replace deathid=1254 if pid=="20080699"
replace deathid=2730 if pid=="20080759"
replace deathid=5653 if pid=="20080783"
replace deathid=1220 if pid=="20080788"
replace deathid=842 if pid=="20080798"
replace deathid=456 if pid=="20080803"
replace deathid=1226 if pid=="20080806"
replace deathid=1483 if pid=="20080807"
replace deathid=2291 if pid=="20080808"
replace deathid=1910 if pid=="20080809"
replace deathid=1529 if pid=="20080825"
replace deathid=2235 if pid=="20080829"
replace deathid=2181 if pid=="20080840"
replace deathid=1825 if pid=="20080842"
replace deathid=2113 if pid=="20080844"
replace deathid=470 if pid=="20080851" //2 changes
replace deathid=1755 if pid=="20080852"
replace deathid=9181 if pid=="20080865"
replace deathid=1633 if pid=="20080909"
replace deathid=1884 if pid=="20080914"
replace deathid=2451 if pid=="20080935"
replace deathid=5933 if pid=="20080949"
replace deathid=6895 if pid=="20080966" //2 changes
replace deathid=11240 if pid=="20080972"
replace deathid=8746 if pid=="20080976"
replace deathid=8246 if pid=="20080977"
replace deathid=7192 if pid=="20080993"
replace deathid=2895 if pid=="20080998"
replace deathid=3894 if pid=="20081039"
replace deathid=522 if pid=="20081113"
replace deathid=2450 if pid=="20081115"
replace deathid=5833 if pid=="20081121"
replace deathid=12646 if pid=="20130100"
replace deathid=12182 if pid=="20130177"
replace deathid=13121 if pid=="20130182"
replace deathid=13373 if pid=="20130193"
replace deathid=13379 if pid=="20130199"
replace deathid=13617 if pid=="20130220"
replace deathid=13968 if pid=="20130230"
replace deathid=13832 if pid=="20130231"
replace deathid=13939 if pid=="20130232"
replace deathid=14557 if pid=="20130247"
replace deathid=14379 if pid=="20130251"
replace deathid=14269 if pid=="20130256"
replace deathid=14837 if pid=="20130260"
replace deathid=13989 if pid=="20130265"
replace deathid=13586 if pid=="20130282"
replace deathid=16287 if pid=="20130286"
replace deathid=14025 if pid=="20130301"
replace deathid=15242 if pid=="20130316"
replace deathid=16320 if pid=="20130341"
replace deathid=13917 if pid=="20130370"
replace deathid=14947 if pid=="20130387"
replace deathid=14308 if pid=="20130389"
replace deathid=12191 if pid=="20130397"
replace deathid=12383 if pid=="20130399"
replace deathid=12393 if pid=="20130516"
replace deathid=12231 if pid=="20130518"
replace deathid=12194 if pid=="20130521"
replace deathid=12766 if pid=="20130535"
replace deathid=12955 if pid=="20130542"
replace deathid=13478 if pid=="20130571"
replace deathid=13838 if pid=="20130577"
replace deathid=13870 if pid=="20130578"
replace deathid=15424 if pid=="20130582"
replace deathid=14105 if pid=="20130598"
replace deathid=14097 if pid=="20130601"
replace deathid=12197 if pid=="20130624"
replace deathid=16153 if pid=="20130644"
replace deathid=16495 if pid=="20130661"
replace deathid=15067 if pid=="20130687"
replace deathid=11960 if pid=="20130688"
replace deathid=13966 if pid=="20130691"
replace deathid=14118 if pid=="20130708"
replace deathid=16370 if pid=="20130712"
replace deathid=13697 if pid=="20130721"
replace deathid=13957 if pid=="20130724"
replace deathid=16391 if pid=="20130727"
replace deathid=14226 if pid=="20130735"
replace deathid=14236 if pid=="20130736"
replace deathid=14386 if pid=="20130747"
replace deathid=12465 if pid=="20130755"
replace deathid=14517 if pid=="20130766"
replace deathid=12431 if pid=="20130777"
replace deathid=13913 if pid=="20130794"
replace deathid=16450 if pid=="20130800"
//died overseas so no death data - 20080179, 20080611, 20080664
//died but no national death data - 20081066, 20081106, 20130167, 20130245, 20130351, 20130549, 20130690, 20130773
//below were listed as dead but no indication in CR5/MasterDb they died
replace slc=1 if pid=="20080877"
replace slc=1 if pid=="20080881"
replace slc=1 if pid=="20080882"
replace slc=1 if pid=="20080884"
replace slc=1 if pid=="20080885"


** Change death variables as these will not copy into current death variables when merging 112/129 cases
rename regnum regnumcr5
rename pname pnamecr5
rename dod dodcr5
rename redcap_event_name redcap_event_namecr5
rename dddoa dddoacr5
rename ddda dddacr5
rename odda oddacr5
rename certtype certtypecr5
rename district districtcr5
rename address addresscr5
rename ddparish ddparishcr5
rename ddsex ddsexcr5
rename ddage ddagecr5
rename ddagetxt ddagetxtcr5
**rename nrn nrncr5
rename mstatus mstatuscr5
rename occu occucr5
rename cod1a cod1acr5
rename pod podcr5
rename deathparish deathparishcr5
rename regdate regdatecr5
rename ddcertifier ddcertifiercr5
rename ddnamematch ddnamematchcr5
rename dcstatus dcstatuscr5
rename duprec dupreccr5


** Create (in dofile '2_all_deaths_dp') national death file with only the '129' above that don't have death data and add these to this dataset
** Note: 112/129 matched; 3/129 no match-died overseas; 9/129 no match but died on island; 5/129 not deceased
drop _merge
merge m:1 deathid using "`datapath'\version01\2-working\unmerged_missed_redcap_deaths", force
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         1,928
        from master                     1,928  (_merge==1)
        from using                          0  (_merge==2)

    matched                               112  (_merge==3)
    -----------------------------------------
*/

** Re-join death dataset variables
count if regnumcr5==. & regnum!=. //112
replace regnumcr5=regnum if regnumcr5==. & regnum!=. //112 changes
count if pnamecr5=="" & pname!="" //112
replace pnamecr5=pname if pnamecr5=="" & pname!="" //112 changes
count if dodcr5==. & dod!=. //112
replace dodcr5=dod if dodcr5==. & dod!=. //112 changes
count if redcap_event_namecr5=="" & redcap_event_name!="" //112
replace redcap_event_namecr5=redcap_event_name if redcap_event_namecr5=="" & redcap_event_name!="" //112 changes
count if dddoacr5==. & dddoa!=. //112
replace dddoacr5=dddoa if dddoacr5==. & dddoa!=. //112 changes
count if dddacr5==. & ddda!=. //112
replace dddacr5=ddda if dddacr5==. & ddda!=. //112 changes
count if oddacr5=="" & odda!="" //112
replace oddacr5=odda if oddacr5=="" & odda!="" //112 changes
count if certtypecr5==. & certtype!=. //112
replace certtypecr5=certtype if certtypecr5==. & certtype!=. //112 changes
count if districtcr5==. & district!=. //112
replace districtcr5=district if districtcr5==. & district!=. //112 changes
count if addresscr5=="" & address!="" //111
replace addresscr5=address if addresscr5=="" & address!="" //111 changes
count if ddparishcr5==. & ddparish!=. //112
replace ddparishcr5=ddparish if ddparishcr5==. & ddparish!=. //112 changes
count if ddsexcr5==. & ddsex!=. //112
replace ddsexcr5=ddsex if ddsexcr5==. & ddsex!=. //112 changes
count if ddagecr5==. & ddage!=. //112
replace ddagecr5=ddage if ddagecr5==. & ddage!=. //112 changes
count if ddagetxtcr5==. & ddagetxt!=. //110
replace ddagetxtcr5=ddagetxt if ddagetxtcr5==. & ddagetxt!=. //110 changes
count if natregno=="" & nrn!="" //0 - keep natregno instead of nrn as many of the nrn from death dataset were incorrect when cross-checked with electoral list
count if mstatuscr5==. & mstatus!=. //112
replace mstatuscr5=mstatus if mstatuscr5==. & mstatus!=. //112 changes
count if occucr5=="" & occu!="" //112
replace occucr5=occu if occucr5=="" & occu!="" //112 changes
count if cod1acr5=="" & cod1a!="" //112
replace cod1acr5=cod1a if cod1acr5=="" & cod1a!="" //112 changes
count if podcr5=="" & pod!="" //112
replace podcr5=pod if podcr5=="" & pod!="" //112 changes
count if deathparishcr5==. & deathparish!=. //112
replace deathparishcr5=deathparish if deathparishcr5==. & deathparish!=. //112 changes
count if regdatecr5==. & regdate!=. //112
replace regdatecr5=regdate if regdatecr5==. & regdate!=. //112 changes
count if ddcertifiercr5=="" & ddcertifier!="" //112
replace ddcertifiercr5=ddcertifier if ddcertifiercr5=="" & ddcertifier!="" //112 changes
count if ddnamematchcr5==. & ddnamematch!=. //112
replace ddnamematchcr5=ddnamematch if ddnamematchcr5==. & ddnamematch!=. //112 changes
count if dcstatuscr5==. & dcstatus!=. //112
replace dcstatuscr5=dcstatus if dcstatuscr5==. & dcstatus!=. //112 changes
count if dupreccr5==. & duprec!=. //0


** Remove 112/129 death variables and change back to original name
drop regnum pname dod redcap_event_name dddoa ddda odda certtype district address ///
     ddparish ddsex ddage ddagetxt nrn mstatus occu cod1a pod deathparish regdate ddcertifier ///
     ddnamematch dcstatus duprec
rename regnumcr5 regnum
rename pnamecr5 pname
rename dodcr5 dod
rename redcap_event_namecr5 redcap_event_name
rename dddoacr5 dddoa
rename dddacr5 ddda
rename oddacr5 odda
rename certtypecr5 certtype
rename districtcr5 district
rename addresscr5 address
rename ddparishcr5 ddparish
rename ddsexcr5 ddsex
rename ddagecr5 ddage
rename ddagetxtcr5 ddagetxt
rename mstatuscr5 mstatus
rename occucr5 occu
rename cod1acr5 cod1a
rename podcr5 pod
rename deathparishcr5 deathparish
rename regdatecr5 regdate
rename ddcertifiercr5 ddcertifier
rename ddnamematchcr5 ddnamematch
rename dcstatuscr5 dcstatus
rename dupreccr5 duprec


** Check merge is correct
count if deathid==. & slc==2 //12 - correct; these 12/129 that didn't match
sort pid
//list pid fname lname if deathid==. & slc==2
count if dod==. & slc==2 //12
//list pid fname lname if dod==. & slc==2
count if slc==2 & cod1a=="" //12
//list pid fname lname if slc==2 & cod1a==""


** Create variable to identify potential cancers in CODs (to be used later in analysis dofiles)
gen cancer=.
label define cancer_lab 1 "cancer" 2 "not cancer", modify
label values cancer cancer_lab
label var cancer "cancer diagnoses"
label var deathid "Event identifier for registry deaths"

** searching cod1a for these terms
replace cancer=1 if regexm(cod1a, "CANCER") //291 changes
replace cancer=1 if regexm(cod1a, "TUMOUR") &  cancer==. //20 changes
replace cancer=1 if regexm(cod1a, "TUMOR") &  cancer==. //9 changes
replace cancer=1 if regexm(cod1a, "MALIGNANT") &  cancer==. //6 changes
replace cancer=1 if regexm(cod1a, "MALIGNANCY") &  cancer==. //26 changes
replace cancer=1 if regexm(cod1a, "NEOPLASM") &  cancer==. //4 changes
replace cancer=1 if regexm(cod1a, "CARCINOMA") &  cancer==. //350 changes
replace cancer=1 if regexm(cod1a, "CARCIMONA") &  cancer==. //1 change
replace cancer=1 if regexm(cod1a, "CARINOMA") &  cancer==. //0 changes
replace cancer=1 if regexm(cod1a, "MYELOMA") &  cancer==. //21 changes
replace cancer=1 if regexm(cod1a, "LYMPHOMA") &  cancer==. //24 changes
replace cancer=1 if regexm(cod1a, "LYMPHOMIA") &  cancer==. //0 changes
replace cancer=1 if regexm(cod1a, "LYMPHONA") &  cancer==. //1 change
replace cancer=1 if regexm(cod1a, "SARCOMA") &  cancer==. //8 changes
replace cancer=1 if regexm(cod1a, "TERATOMA") &  cancer==. //1 change
replace cancer=1 if regexm(cod1a, "LEUKEMIA") &  cancer==. //7 changes
replace cancer=1 if regexm(cod1a, "LEUKAEMIA") &  cancer==. //11 changes
replace cancer=1 if regexm(cod1a, "HEPATOMA") &  cancer==. //2 changes
replace cancer=1 if regexm(cod1a, "CARANOMA PROSTATE") &  cancer==. //0 changes
replace cancer=1 if regexm(cod1a, "MENINGIOMA") &  cancer==. //0 changes
replace cancer=1 if regexm(cod1a, "MYELOSIS") &  cancer==. //0 changes
replace cancer=1 if regexm(cod1a, "MYELOFIBROSIS") &  cancer==. //0 changes
replace cancer=1 if regexm(cod1a, "CYTHEMIA") &  cancer==. //0 changes
replace cancer=1 if regexm(cod1a, "CYTOSIS") &  cancer==. //0 changes
replace cancer=1 if regexm(cod1a, "BLASTOMA") &  cancer==. //0 changes
replace cancer=1 if regexm(cod1a, "METASTATIC") &  cancer==. //4 changes
replace cancer=1 if regexm(cod1a, "MASS") &  cancer==. //4 changes
replace cancer=1 if regexm(cod1a, "METASTASES") &  cancer==. //1 change
replace cancer=1 if regexm(cod1a, "METASTASIS") &  cancer==. //1 change
replace cancer=1 if regexm(cod1a, "REFRACTORY") &  cancer==. //0 changes
replace cancer=1 if regexm(cod1a, "FUNGOIDES") &  cancer==. //0 changes
replace cancer=1 if regexm(cod1a, "HODGKIN") &  cancer==. //0 changes
replace cancer=1 if regexm(cod1a, "MELANOMA") &  cancer==. //1 change
replace cancer=1 if regexm(cod1a,"MYELODYS") &  cancer==. //0 changes

** Strip possible leading/trailing blanks in cod1a
replace cod1a = rtrim(ltrim(itrim(cod1a))) //0 changes

tab cancer, missing
/*
     cancer |
  diagnoses |      Freq.     Percent        Cum.
------------+-----------------------------------
     cancer |        891       43.68       43.68
          . |      1,149       56.32      100.00
------------+-----------------------------------
      Total |      2,040      100.00
*/

** Update dod with dlc if slc=deceased
tab slc ,m
/*
StatusLastC |
     ontact |      Freq.     Percent        Cum.
------------+-----------------------------------
      Alive |        947       46.42       46.42
   Deceased |      1,093       53.58      100.00
------------+-----------------------------------
      Total |      2,040      100.00
*/
count if dod==. & slc==2 //12/129 that didn't match
//list pid if dod==. & slc==2
replace dod=dlc if slc==2 & dod==. //12 changes
gen deathyear=year(dod) //1,093 changes
tab deathyear cancer,m
/*
           |   cancer diagnoses
 deathyear |    cancer          . |     Total
-----------+----------------------+----------
      2008 |       202         45 |       247 
      2009 |        86         33 |       119 
      2010 |        53         13 |        66 
      2011 |        46          8 |        54 
      2012 |        18         13 |        31 
      2013 |       228         21 |       249 
      2014 |       121         16 |       137 
      2015 |        69         18 |        87 
      2016 |        48         15 |        63 
      2017 |        20         20 |        40 
         . |         0        947 |       947 
-----------+----------------------+----------
     Total |       891      1,149 |     2,040 
*/
//202 (1,093-891) whose cod not listed as cancer

** Check that all cancer CODs are eligible
sort cod1a deathid
order pid deathid cod1a cancer
count if cancer==1 & (dxyr==2008|dxyr==2013) //883
//list cod1a if cancer==1 & (dxyr==2008|dxyr==2013)
count if cancer!=1 & slc==2 & (dxyr==2008|dxyr==2013) //202
//list cod1a if cancer!=1 & slc==2 & (dxyr==2008|dxyr==2013) //12 are missing cod as these are 12/129 that didn't match

tab dxyr cancer,m
//883+202=1,085 but total deaths=1,093 - checked and 8 are not 2008/2013

** Update cases where COD=cancer but not captured in above due to spelling errors in COD, e.g.
** LYNPHOMA, MUTLIPLE MELOMA, CA COLON, LUKAEMIA, 
list cod1a if cancer!=1 & slc==2 & cod1a!="" //190
replace cancer=1 if deathid==18075|deathid==17895|deathid==16652|deathid==3589 ///
        |deathid==14097|deathid==18198|deathid==22959
//7 changes

replace cancer=2 if slc==2 & cancer!=1 & cod1a!="" //183 changes

** Create cod variable to be used in analysis dofiles
gen cod=.
label define cod_lab 1 "Dead of cancer" 2 "Dead of other cause" 3 "Not known", modify
label values cod cod_lab
label var cod "COD categories"
replace cod=1 if cancer==1 //898 changes
replace cod=2 if cancer==2 //183 changes
replace cod=3 if slc==2 & cancer==. & cod1a=="" //12 changes


** Create variable called "deceased" - same as 2008 dofile called '3_merge_cancer_deaths.do'
tab slc ,m
/*
StatusLastC |
     ontact |      Freq.     Percent        Cum.
------------+-----------------------------------
      Alive |        947       46.42       46.42
   Deceased |      1,093       53.58      100.00
------------+-----------------------------------
      Total |      2,040      100.00
*/
count if slc!=2 & dod!=. //0
gen deceased=1 if slc==2 //1,093 changes
label var deceased "whether patient is deceased"
label define deceased_lab 1 "dead" 2 "alive at last contact" , modify
label values deceased deceased_lab
replace deceased=2 if slc==1 //947 changes

tab deceased ,m
/*
   whether patient is |
             deceased |      Freq.     Percent        Cum.
----------------------+-----------------------------------
                 dead |      1,093       53.58       53.58
alive at last contact |        947       46.42      100.00
----------------------+-----------------------------------
                Total |      2,040      100.00
*/

** Create the "patient" variable - same as 2008 dofile called '3_merge_cancer_deaths.do'
tab eidmp ,m
/*

     CR5 tumour |
         events |      Freq.     Percent        Cum.
----------------+-----------------------------------
  single tumour |      1,921       94.17       94.17
multiple tumour |        119        5.83      100.00
----------------+-----------------------------------
          Total |      2,040      100.00
*/
gen patient=.  
label var patient "cancer patient"
label define pt_lab 1 "patient" 2 "separate event",modify
label values patient pt_lab
replace patient=1 if eidmp==1 //1,056 changes
replace patient=2 if eidmp==2 //19 changes
tab patient ,m
/*
cancer patient |      Freq.     Percent        Cum.
---------------+-----------------------------------
       patient |      1,921       94.17       94.17
separate event |        119        5.83      100.00
---------------+-----------------------------------
         Total |      2,040      100.00
*/

count //2,040

** Add 'missed' 2013 cases found while cleaning 2014 data
** Ensure these are 'true' missed cases by checking dataset with 30 missed cases against this dataset
append using "`datapath'\version01\2-working\missed2013_cancer_toappend"
count //2,070

** Check for missing deathyear
count if deathyear==. & slc==2 //1 - died in CR5 comments but not in death data
replace dod=dlc if pid=="20141542"
replace deathyear=2014 if pid=="20141542"

** Check for missing natregno
count if natregno=="" & nrn!="" //0
count if nrn!="" //21
//list pid deathid natregno nrn if nrn!="" - nrn match natregno
drop nrn

** Remove below case as was already in dataset but missed2013 dataset has more accurate info
** First, copy blank info from below case
drop if pid=="20130338" & deathidold==. //1 deleted
drop deathidold

** Check for unknown age/sex
tab sex ,m
/*
        Sex |      Freq.     Percent        Cum.
------------+-----------------------------------
       Male |      1,051       50.80       50.80
     Female |      1,017       49.15       99.95
    Unknown |          1        0.05      100.00
------------+-----------------------------------
      Total |      2,069      100.00
*/
//list pid deaithid fname lname natregno primarysite if sex==9
replace sex=2 if pid=="20081131" //1 change
count if age==.|age==999 //0

count //2,069

** Check icd10, top, morph not missing
count if icd10=="" //14
sort pid
//list pid deathid top morph if icd10==""
count if topography==. //0
count if morph==. //0

** Export 9 missing icd10 to run data in IARCcrg Tools (Conversion Programme)
** Convert ICD-O-3 to ICD-10(v2010)
preserve
drop if icd10!="" //2,055 deleted
export_excel pid sex topography morph beh grade ///
using "`datapath'\version01\2-working\2019-04-16_iarccrg_icd10missing.xlsx", firstrow(varlabels) nolabel replace
restore
/*
Steps how to convert from ICD-O-3 to ICD-10 using IARCcrg Tools
(1) Save excel export to Tab(text delimited)
(2) Format file using File transfer feature in IARCcrg Tools - save formatted file as 'yyyy-mm-dd_ICDO3-ICD10 format'
(3) Using formatted .prn file above, open Conversions feature and select ICD-O-3 -> ICD-10
(4) Save above converted file as 'yyyy-mm-dd_ICDO3-ICD10 conversion'
(5) To view converted file, click open folder icon in IARCcrg Tools
*/
replace icd10="C539" if pid=="20140015"
replace icd10="C765" if pid=="20140048"
replace icd10="C168" if pid=="20140062"
replace icd10="C73" if pid=="20140148"
replace icd10="C64" if pid=="20140151"
replace icd10="C61" if pid=="20140178"
replace icd10="C259" if pid=="20140204"
replace icd10="C508" if pid=="20140207"
replace icd10="C509" if pid=="20140211"
replace icd10="C840" if pid=="20140687"
replace icd10="C73" if pid=="20140723"
replace icd10="C64" if pid=="20141542"
replace icd10="C20" if pid=="20145009"
replace icd10="C508" if pid=="20145010"

count if icd10=="" //0

* ************************************************************************
* SITE GROUPINGS
* Using siteiarc as decided by NS
**************************************************************************

** Create new site variable with CI5-XI incidence classifications (see chapter 3 Table 3.1. of that volume) based on icd10
display `"{browse "http://ci5.iarc.fr/CI5-XI/Pages/Chapter3.aspx":IARC-CI5-XI-3}"'

gen siteiarc=.
label define siteiarc_lab ///
1 "Lip (C00)" 2 "Tongue (C01-02)" 3 "Mouth (C03-06)" ///
4 "Salivary gland (C07-08)" 5 "Tonsil (C09)" 6 "Other oropharynx (C10)" ///
7 "Nasopharynx (C11)" 8 "Hypopharynx (C12-13)" 9 "Pharynx unspecified (C14)" ///
10 "Oesophagus (C15)" 11 "Stomach (C16)" 12 "Small intestine (C17)" ///
13 "Colon (C18)" 14 "Rectum (C19-20)" 15 "Anus (C21)" ///
16 "Liver (C22)" 17 "Gallbladder etc. (C23-24)" 18 "Pancreas (C25)" ///
19 "Nose, sinuses etc. (C30-31)" 20 "Larynx (C32)" ///
21 "Lung (incl. trachea and bronchus) (C33-34)" 22 "Other thoracic organs (C37-38)" ///
23 "Bone (C40-41)" 24 "Melanoma of skin (C43)" 25 "Other skin (C44)" ///
26 "Mesothelioma (C45)" 27 "Kaposi sarcoma (C46)" 28 "Connective and soft tissue (C47+C49)" ///
29 "Breast (C50)" 30 "Vulva (C51)" 31 "Vagina (C52)" 32 "Cervix uteri (C53)" ///
33 "Corpus uteri (C54)" 34 "Uterus unspecified (C55)" 35 "Ovary (C56)" ///
36 "Other female genital organs (C57)" 37 "Placenta (C58)" ///
38 "Penis (C60)" 39 "Prostate (C61)" 40 "Testis (C62)" 41 "Other male genital organs (C63)" ///
42 "Kidney (C64)" 43 "Renal pelvis (C65)" 44 "Ureter (C66)" 45 "Bladder (C67)" ///
46 "Other urinary organs (C68)" 47 "Eye (C69)" 48 "Brain, nervous system (C70-72)" ///
49 "Thyroid (C73)" 50 "Adrenal gland (C74)" 51 "Other endocrine (C75)" ///
52 "Hodgkin lymphoma (C81)" 53 "Non-Hodgkin lymphoma (C82-86,C96)" ///
54 "Immunoproliferative diseases (C88)" 55 "Multiple myeloma (C90)" ///
56 "Lymphoid leukaemia (C91)" 57 "Myeloid leukaemia (C92-94)" 58 "Leukaemia unspecified (C95)" ///
59 "Myeloproliferative disorders (MPD)" 60 "Myelodysplastic syndromes (MDS)" ///
61 "Other and unspecified (O&U)" ///
62 "All sites(ALL)" 63 "All sites but skin (ALLbC44)" ///
64 "D069: CIN 3" ///
65 "All in-situ but CIN3" ///
66 "All uncertain behaviour" ///
67 "All benign"
label var siteiarc "IARC CI5-XI sites"
label values siteiarc siteiarc_lab

replace siteiarc=1 if regexm(icd10,"C00") //0 changes
replace siteiarc=2 if (regexm(icd10,"C01")|regexm(icd10,"C02")) //9 changes
replace siteiarc=3 if (regexm(icd10,"C03")|regexm(icd10,"C04")|regexm(icd10,"C05")|regexm(icd10,"C06")) //11 changes
replace siteiarc=4 if (regexm(icd10,"C07")|regexm(icd10,"C08")) //2 changes
replace siteiarc=5 if regexm(icd10,"C09") //4 changes
replace siteiarc=6 if regexm(icd10,"C10") //3 changes
replace siteiarc=7 if regexm(icd10,"C11") //5 changes
replace siteiarc=8 if (regexm(icd10,"C12")|regexm(icd10,"C13")) //4 changes
replace siteiarc=9 if regexm(icd10,"C14") //3 changes
replace siteiarc=10 if regexm(icd10,"C15") //14 changes
replace siteiarc=11 if regexm(icd10,"C16") //49 changes
replace siteiarc=12 if regexm(icd10,"C17") //5 changes
replace siteiarc=13 if regexm(icd10,"C18") //203 changes
replace siteiarc=14 if (regexm(icd10,"C19")|regexm(icd10,"C20")) //73 changes
replace siteiarc=15 if regexm(icd10,"C21") //13 changes
replace siteiarc=16 if regexm(icd10,"C22") //12 changes
replace siteiarc=17 if (regexm(icd10,"C23")|regexm(icd10,"C24")) //13 changes
replace siteiarc=18 if regexm(icd10,"C25") //37 changes
replace siteiarc=19 if (regexm(icd10,"C30")|regexm(icd10,"C31")) //6 changes
replace siteiarc=20 if regexm(icd10,"C32") //9 changes
replace siteiarc=21 if (regexm(icd10,"C33")|regexm(icd10,"C34")) //56 changes
replace siteiarc=22 if (regexm(icd10,"C37")|regexm(icd10,"C38")) //2 changes
replace siteiarc=23 if (regexm(icd10,"C40")|regexm(icd10,"C41")) //5 changes
replace siteiarc=24 if regexm(icd10,"C43") //8 changes
replace siteiarc=25 if regexm(icd10,"C44") //304 changes
replace siteiarc=26 if regexm(icd10,"C45") //1 change
replace siteiarc=27 if regexm(icd10,"C46") //0 changes
replace siteiarc=28 if (regexm(icd10,"C47")|regexm(icd10,"C49")) //8 changes
replace siteiarc=29 if regexm(icd10,"C50") //272 changes
replace siteiarc=30 if regexm(icd10,"C51") //2 changes
replace siteiarc=31 if regexm(icd10,"C52") //3 changes
replace siteiarc=32 if regexm(icd10,"C53") //54 changes
replace siteiarc=33 if regexm(icd10,"C54") //71 changes
replace siteiarc=34 if regexm(icd10,"C55") //6 changes
replace siteiarc=35 if regexm(icd10,"C56") //22 changes
replace siteiarc=36 if regexm(icd10,"C57") //4 changes
replace siteiarc=37 if regexm(icd10,"C58") //2 changes
replace siteiarc=38 if regexm(icd10,"C60") //4 changes
replace siteiarc=39 if regexm(icd10,"C61") //376 changes
replace siteiarc=40 if regexm(icd10,"C62") //1 change
replace siteiarc=41 if regexm(icd10,"C63") //0 changes
replace siteiarc=42 if regexm(icd10,"C64") //35 changes
replace siteiarc=43 if regexm(icd10,"C65") //0 changes
replace siteiarc=44 if regexm(icd10,"C66") //0 changes
replace siteiarc=45 if regexm(icd10,"C67") //19 changes
replace siteiarc=46 if regexm(icd10,"C68") //1 change
replace siteiarc=47 if regexm(icd10,"C69") //4 changes
replace siteiarc=48 if (regexm(icd10,"C70")|regexm(icd10,"C71")|regexm(icd10,"C72")) //7 changes
replace siteiarc=49 if regexm(icd10,"C73") //25 changes
replace siteiarc=50 if regexm(icd10,"C74") //0 changes
replace siteiarc=51 if regexm(icd10,"C75") //2 changes
replace siteiarc=52 if regexm(icd10,"C81") //8 changes
replace siteiarc=53 if (regexm(icd10,"C82")|regexm(icd10,"C83")|regexm(icd10,"C84")|regexm(icd10,"C85")|regexm(icd10,"C86")|regexm(icd10,"C96")) //37 changes
replace siteiarc=54 if regexm(icd10,"C88") //1 change
replace siteiarc=55 if regexm(icd10,"C90") //32 changes
replace siteiarc=56 if regexm(icd10,"C91") //8 changes
replace siteiarc=57 if (regexm(icd10,"C92")|regexm(icd10,"C93")|regexm(icd10,"C94")) //21 changes
replace siteiarc=58 if regexm(icd10,"C95") //4 changes
replace siteiarc=59 if morphcat==54|morphcat==55 //7 changes
replace siteiarc=60 if morphcat==56 //2 changes
replace siteiarc=61 if (regexm(icd10,"C26")|regexm(icd10,"C39")|regexm(icd10,"C48")|regexm(icd10,"C76")|regexm(icd10,"C80")) //67changes
**replace siteiarc=62 if siteiarc<62
**replace siteiarc=63 if siteiarc<62 & siteiarc!=25
replace siteiarc=64 if morph==8077 //43 changes
replace siteiarc=65 if beh==2 & siteiarc==. //50 changes
replace siteiarc=66 if beh==1 //12 changes
replace siteiarc=67 if beh==0 //8 changes

tab siteiarc ,m //70 missing - benign, uncertain and in-situ excl.CIN 3
//list pid top morph icd10 beh if siteiarc==.


** Create site variable for lymphoid and haematopoietic diseases for conversion of these from ICD-O-3 1st edition (M9590-M9992)
** (see chapter 3 Table 3.2 of CI5-XI)
gen siteiarchaem=.
label define siteiarchaem_lab ///
1 "Malignant lymphomas,NOS or diffuse" ///
2 "Hodgkin lymphoma" ///
3 "Mature B-cell lymphomas" ///
4 "Mature T- and NK-cell lymphomas" ///
5 "Precursor cell lymphoblastic lymphoma" ///
6 "Plasma cell tumours" ///
7 "Mast cell tumours" ///
8 "Neoplasms of histiocytes and accessory lymphoid cells" ///
9 "Immunoproliferative diseases" ///
10 "Leukemias, NOS" ///
11 "Lymphoid leukemias" ///
12 "Myeloid leukemias" ///
13 "Other leukemias" ///
14 "Chronic myeloproliferative disorders" ///
15 "Other hematologic disorders" ///
16 "Myelodysplastic syndromes"
label var siteiarchaem "IARC CI5-XI lymphoid & haem diseases"
label values siteiarchaem siteiarchaem_lab

** Note that morphcat is based on ICD-O-3 edition 3.1. so e.g. morphcat54
replace siteiarchaem=1 if morphcat==41 //19 changes
replace siteiarchaem=2 if morphcat==42 //8 changes
replace siteiarchaem=3 if morphcat==43 //13 changes
replace siteiarchaem=4 if morphcat==44 //6 changes
replace siteiarchaem=5 if morphcat==45 //0 changes
replace siteiarchaem=6 if morphcat==46 //32 changes
replace siteiarchaem=7 if morphcat==47 //0 changes
replace siteiarchaem=8 if morphcat==48 //0 changes
replace siteiarchaem=9 if morphcat==49 //0 changes
replace siteiarchaem=10 if morphcat==50 //4 changes
replace siteiarchaem=11 if morphcat==51 //8 changes
replace siteiarchaem=12 if morphcat==52 //18 changes
replace siteiarchaem=13 if morphcat==53 //3 changes
replace siteiarchaem=14 if morphcat==54 //7 changes
replace siteiarchaem=15 if morphcat==55 //0 changes
replace siteiarchaem=16 if morphcat==56 //2 changes

tab siteiarchaem ,m //967 missing - correct!
count if (siteiarc>51 & siteiarc<59) & siteiarchaem==. //0

count //2,069

** Remove all ineligible cases and cases dx in 2014 onwards as 2014 cases already cleaned
** pre-2014 cases are to be cleaned
count if siteiarc==25 & recstatus!=3 & dxyr!=2008 //1
//list pid fname lname if siteiarc==25 & recstatus!=3 & dxyr!=2008
replace recstatus=3 if pid=="20130253" //1 change
count if beh!=2 & beh!=3 //2
//list pid fname lname if beh!=2 & beh!=3
replace recstatus=3 if pid=="20130526" //1 change
replace recstatus=3 if pid=="20130224" //1 change
count if recstatus==3 //3
//list pid deathid dot top morph if recstatus==3
drop if recstatus==3 //3 deleted

count if dxyr==. //0
count if dxyr!=2008 & dxyr!=2013 //12
//list pid deathid dot dxyr if dxyr!=2008 & dxyr!=2013
drop if dxyr!=2008 & dxyr!=2013 //12 deleted

count //2,054

** Put variables in order you want them to appear
order pid fname lname init age sex dob natregno resident slc dlc ///
	    parish cr5cod primarysite morph top lat beh hx

save "`datapath'\version01\2-working\2008_2013_cancer_dc_v01" ,replace
label data "BNR-Cancer prepared 2008 & 2013 data"
notes _dta :These data prepared for 2008 & 2013 inclusion in 2014 cancer report
