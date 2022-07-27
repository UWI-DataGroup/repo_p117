** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          50_death match.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      27-JUL-2021
    // 	date last modified      09-AUG-2021
    //  algorithm task          Matching cleaned, current cancer dataset with cleaned death 2015-2020 dataset
    //  status                  Completed
    //  objective               To have a cleaned and matched dataset with updated vital status
    //  methods                 Using same prep code from 15_clean cancer.do

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
    log using "`logpath'\50_death match.smcl", replace
** HEADER -----------------------------------------------------

* ************************************************************************
* PREP AND FORMAT
**************************************************************************
use "`datapath'\version02\2-working\2008_2013_2014_2015_cancer ds_2015-2020 death matching", clear

** Remove deceased cases from cancer dataset
count //4,066
count if slc==2 //2,303

JC 20jul2022: don't drop deceased cases instead drop cases wherein deathid/record_id is blank so the ones wherein dod was entered at abstraction can be merged with death dataset
drop if slc==2 //2,303 deleted

Below taken from 20a dofile - maybe perform after death matching completed in final clean dofile?:
/*
** JC 02JUN2022: below check not done as death matching not done for PAB ASIRs

** Check for cases where cancer=2-not cancer but it has been abstracted
count if cancer==2 & pid!="" //32
sort pid deathid
//list pid deathid fname lname top cr5cod cod if cancer==2 & pid!="", nolabel string(90)
//list cr5cod if cancer==2 & pid!=""
//list cod1a if cancer==2 & pid!=""
** Corrections from above list
replace cod=1 if pid=="20150063"|pid=="20150351"|pid=="20151023"|pid=="20151039"|pid=="20151050"| ///
				 pid=="20151095"|pid=="20151113"|pid=="20151278 "|pid=="20155201" //8 changes
replace cancer=1 if pid=="20150063"|pid=="20150351"|pid=="20151039"|pid=="20151095"|pid=="20151113"|pid=="20151278"|pid=="20155201" //7 changes
//replace dcostatus=1 if pid=="20140047" //1 change
preserve
drop if basis!=0
keep pid fname lname natregno dod cr5cod doctor docaddr certifier
capture export_excel pid fname lname natregno dod cr5cod doctor docaddr certifier ///
		using "`datapath'\version09\2-working\DCO2015V05.xlsx", sheet("2015 DCOs_cr5data_20210727") firstrow(variables)
//JC remember to change V01 to V02 when running list a 2nd time!
restore
*/

** Create variable to identify patient records
gen ptrectot=.
replace ptrectot=1 if eidmp==1 //971; 1119 changes
replace ptrectot=3 if eidmp==2 //13; 15 changes
replace ptrectot=2 if regexm(pid, "20159") //149 changes
label define ptrectot_lab 1 "CR5 pt with single event" 2 "DC with single event" 3 "CR5 pt with multiple events" ///
						  4 "DC with multiple events" 5 "CR5 pt: single event but multiple DC events" , modify
label values ptrectot ptrectot_lab
/*
Now check:
	(1) patient record with T1 are included in category 3 of ptrectot but leave eidmp=single tumour so this var can be used to count MPs
	(2) patient records with only 1 tumour but maybe labelled as T2 are not included in eidmp and are included in category 1 of ptrectot
*/
count if eidmp==2 & dupsource==1 //11; 13
order pid record_id cr5id eidmp dupsource ptrectot primarysite
//list pid eidmp dupsource duppid cr5id fname lname if eidmp==2 & dupsource==1

replace ptrectot=3 if pid=="20150238" & cr5id=="T1S1" //1 change
replace ptrectot=3 if pid=="20150277" & cr5id=="T1S1" //1 change
replace ptrectot=3 if pid=="20150468" & cr5id=="T1S1" //1 change
replace ptrectot=3 if pid=="20150506" & cr5id=="T1S1" //1 change
replace ptrectot=3 if pid=="20151200" & cr5id=="T1S1" //1 change
replace ptrectot=3 if pid=="20151202" & cr5id=="T1S1" //1 change
replace ptrectot=3 if pid=="20151236" & cr5id=="T1S1" //1 change
replace ptrectot=1 if pid=="20151369" & cr5id=="T1S1" //1 change
replace eidmp=1 if pid=="20151369" & cr5id=="T1S1" //1 change
replace eidmp=. if pid=="20151369" & cr5id=="T1S2" //1 change
replace eidmp=. if pid=="20151369" & cr5id=="T1S3" //1 change
replace ptrectot=3 if pid=="20155043" & cr5id=="T1S1" //1 change
replace ptrectot=3 if pid=="20155094" & cr5id=="T1S1" //1 change
replace ptrectot=3 if pid=="20155104" & cr5id=="T1S1" //1 change
replace ptrectot=4 if pid=="20159029" //2 changes
replace ptrectot=4 if pid=="20159116" //2 changes

count if ptrectot==.

** Count # of patients with eligible non-dup tumours
count if ptrectot==1 //962; 963

** Count # of eligible non-dup tumours
count if eidmp==1 //972; 1120

** Count # of eligible non-dup MPs
count if eidmp==2 //10; 12

** JC 14nov18 - I forgot about missed 2013 cases in dataset so stats for 2014 only:
** Count # of patients with eligible non-dup tumours
count if ptrectot==1 & dxyr==2015 //926; 927

** Count # of eligible non-dup tumours
count if eidmp==1 & dxyr==2015 //936; 1074

** Count # of eligible non-dup MPs
count if eidmp==2 & dxyr==2015 //10; 12

/* 
Count # of multiple source records per tumour:
(1)Create variables based on built-in Stata variables (_n, _N) to calculate obs count:
		(a) _n is Stata notation for the current observation number (varname: pidobsid)
		(b) _N is Stata notation for the total number of observations (varname: pidobstot)
(2)Create variables to store overall obs # and obs total (obsid, obstot) for DQI
*/

tab pidobstot ,m //all tumours - need to drop dup sources records to assess DQI for multiple sources per tumour
/*
  pidobstot |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |        642       25.15       25.15
          2 |        832       32.59       57.74
          3 |        669       26.20       83.94
          4 |        280       10.97       94.91
          5 |        110        4.31       99.22
          6 |         12        0.47       99.69
          8 |          8        0.31      100.00
------------+-----------------------------------
      Total |      2,553      100.00

  pidobstot |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |        548       24.98       24.98
          2 |        776       35.37       60.35
          3 |        621       28.30       88.65
          4 |        180        8.20       96.86
          5 |         55        2.51       99.36
          6 |          6        0.27       99.64
          8 |          8        0.36      100.00
------------+-----------------------------------
      Total |      2,194      100.00
*/

** Create variable to identify DCI/DCN vs DCO
gen dcostatus=.
label define dcostatus_lab ///
1 "Eligible DCI/DCN-cancer,in CR5db" ///
2 "DCO" ///
3 "Ineligible DCI/DCN" ///
4 "NA-not cancer,not in CR5db" ///
5 "NA-dead,CR5db no death source" ///
6 "NA-alive" ///
7 "NA-not alive/dead" , modify
label values dcostatus dcostatus_lab
label var dcostatus "death certificate status"

order pid record_id cr5id eidmp dupsource ptrectot dcostatus primarysite
** Assign DCO Status=NA for all events that are not cancer 
replace dcostatus=2 if nftype==8 //256; 265
replace dcostatus=2 if basis==0 //14; 136
replace dcostatus=4 if cancer==2 //7463; 85 changes
count if slc!=2 //10524; 978
//list cr5cod if slc!=2
replace dcostatus=6 if slc==1 //962 changes
replace dcostatus=7 if slc==9 //0 changes
count if dcostatus==. & cr5cod!="" //2898; 755
replace dcostatus=1 if cr5cod!="" & dcostatus==. & pid!="" //730; 755 changes
count if dcostatus==. & record_id!=. //2169; 3
count if dcostatus==. & pid!="" & record_id!=. //2-leave as is; it's a multiple source
//list pid cr5id record_id basis recstatus eidmp nftype dcostatus if dcostatus==. & pid!="" & record_id!=. ,nolabel
//replace dcostatus=5 if dcostatus==. & pid!="" & record_id!=.
replace dcostatus=1 if pid=="20150468" & cr5id=="T2S1" //1 change
count if dcostatus==. //2189; 22
count if dcostatus==. & pid=="" //2168; 0
count if dcostatus==. & pid!="" //21; 22
count if dcostatus==. & pid!="" & slc==2 //5; 6
//list pid cr5id record_id basis recstatus eidmp nftype if dcostatus==. & pid!=""
replace dcostatus=1 if pid=="20150031" //2 changes
replace dcostatus=1 if pid=="20150506" //2 changes
replace dcostatus=1 if pid=="20155213" //2 changes

** Remove unmatched death certificates
count if pid=="" //9546 - deaths from all years (2008-2018)
count if _merge==2 & pid=="" //0
drop if pid=="" //9546 deleted; 0 deleted

count //2045; 2194
count if dupsource==. //0
count if eidmp==. //1062
count if cr5id=="" //0

** Additional records have been added so need to drop these as they are duplicates created by Stata bysort/missing
count if eidmp==1 //1120
//list pid cr5id eidmp ptrectot if eidmp==1 , sepby(pid)
drop duppidcr5id
sort pid cr5id
quietly by pid cr5id :  gen duppidcr5id = cond(_N==1,0,_n)
sort pid cr5id
count if duppidcr5id>0 //17
//list pid cr5id record_id eidmp ptrectot primarysite duppidcr5id _merge_org if duppidcr5id>0
count if _merge_org==5 //39 - some are correct so don't drop
//list pid cr5id record_id eidmp ptrectot primarysite duppidcr5id _merge_org if _merge_org==5
count if duppidcr5id>0 & _merge_org==5 //10
//list pid cr5id record_id eidmp ptrectot primarysite duppidcr5id _merge_org if duppidcr5id>0 & _merge_org==5
** Need to avoid inadvertently deleting a correct source record so need to tag the duplicate cr5id
duplicates tag pid cr5id, gen(dup_cr5id)
count if dup_cr5id>0 & _merge_org==5 //10
//list pid cr5id dup_cr5id duppidcr5id _merge_org if dup_cr5id>0, nolabel sepby(pid)
drop if dup_cr5id>0 & _merge_org==5 //10; 11 deleted

count //2035; 2183

tab dxyr ,m 
tab dxyr eidmp ,m
*/

** Add death dataset
append using "`datapath'\version02\3-output\2015-2020_deaths_for_appending"

count //17,179

order pid record_id fname lname natregno dob age

** Search for matches by NRN, DOB, NAMES

*********
** NRN **
********* 
count if length(natregno)==9 //0
count if length(natregno)==8 //0
count if length(natregno)==7 //0

** Identify possible matches using NRN
preserve
drop if natregno==""|natregno=="999999-9999"|regexm(natregno,"9999") //remove blank/missing NRNs as these will be flagged as duplicates of each other
//919 deleted
sort natregno 
quietly by natregno : gen dup = cond(_N==1,0,_n)
sort natregno lname fname pid record_id 
count if dup>0 //1048 - review these in Stata's Browse/Edit window
order pid record_id nrn natregno fname lname
restore

gen matchpid=pid if pid=="20081078"
fillmissing matchpid
replace pid=matchpid if record_id==17563
gen matchcr5id=cr5id if pid=="20081078"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==17563
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080474"
fillmissing matchpid
replace pid=matchpid if record_id==24264
gen matchcr5id=cr5id if pid=="20080474"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24264
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130087"
fillmissing matchpid
replace pid=matchpid if record_id==31937
gen matchcr5id=cr5id if pid=="20130087"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==31937
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080512"
fillmissing matchpid
replace pid=matchpid if record_id==26039
gen matchcr5id=cr5id if pid=="20080512"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26039
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080881"
fillmissing matchpid
replace pid=matchpid if record_id==20568
gen matchcr5id=cr5id if pid=="20080881"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20568
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080370"
fillmissing matchpid
replace pid=matchpid if record_id==25205
gen matchcr5id=cr5id if pid=="20080370"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25205
drop matchpid matchcr5id

gen matchpid=pid if pid=="20151027"
fillmissing matchpid
replace pid=matchpid if record_id==24284
gen matchcr5id=cr5id if pid=="20151027"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24284
drop matchpid matchcr5id


*********
** DOB **
*********
** Create DOB as not in death dataset
preserve
gen dobyear=year(dob) if dob!=.
tostring dobyear ,replace
gen dobmonth=month(dob) if dob!=.
tostring dobmonth ,replace
replace dobmonth="0"+dobmonth if length(dobmonth)<2 & dobmonth!="."
gen dobday=day(dob) if dob!=.
tostring dobday ,replace
replace dobday="0"+dobday if length(dobday)<2 & dobday!="."
gen dd_birthdate=dobyear+dobmonth+dobday if dobyear!="" & dobyear!="." //4,060 changes

gen dobyr=substr(natregno, 1, 2) if natregno!=""
gen dobmon=substr(natregno, 3, 2) if natregno!=""
gen dobdy=substr(natregno, 5, 2) if natregno!=""
replace dd_birthdate=dobyr+dobmon+dobdy if dd_birthdate=="" //12,394 changes

drop if dobmon=="99" | dobday=="99" //107 deleted
count if length(dd_birthdate)<8 //13,051

replace dobyr="19"+dobyr if regex(substr(dobyr,1,1),"[0]") & age>90 & length(dd_birthdate)<8 & dd_birthdate!="" //5 changes
replace dobyr="19"+dobyr if age>90 & length(dd_birthdate)<8 & dd_birthdate!="" & length(dobyr)<4 //1,679 changes
replace dobyr="19"+dobyr if age>20 & length(dd_birthdate)<8 & dd_birthdate!="" & length(dobyr)<4 //10,524 changes
count if length(dd_birthdate)<8 & length(dobyr)<4 & dd_birthdate!="" //117
replace dobyr="20"+dobyr if length(dd_birthdate)<8 & length(dobyr)<4 & dd_birthdate!="" //117 changes

replace dd_birthdate=dobyr+dobmon+dobdy if length(dd_birthdate)<8 & dd_birthdate!="" //12,325 changes
count if length(dd_birthdate)<8 & dd_birthdate!="" //0


count if dd_birthdate=="99999999" //0
replace dd_birthdate="" if dd_birthdate=="99999999" //0 changes
replace dd_birthdate = lower(rtrim(ltrim(itrim(dd_birthdate)))) //0 changes
drop dobdy dobmon dobyr dobday dobmonth dobyear
drop if dd_birthdate=="" | dd_birthdate=="99999999" //726 deleted


** Look for matches using DOB
sort lname fname dd_birthdate
quietly by lname fname dd_birthdate : gen dup = cond(_N==1,0,_n)
sort lname fname dd_birthdate pid
count if dup>0 //314 - review these in Stata's Browse/Edit window
order pid record_id fname lname natregno dot dod primarysite coddeath
restore


gen matchpid=pid if pid=="20130021"
fillmissing matchpid
replace pid=matchpid if record_id==32102
gen matchcr5id=cr5id if pid=="20130021"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==32102
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080009"
fillmissing matchpid
replace pid=matchpid if record_id==31975
gen matchcr5id=cr5id if pid=="20080009"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==31975
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080568"
fillmissing matchpid
replace pid=matchpid if record_id==32773
gen matchcr5id=cr5id if pid=="20080568"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==32773
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080008"
fillmissing matchpid
replace pid=matchpid if record_id==33803
gen matchcr5id=cr5id if pid=="20080008"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==33803
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130246"
fillmissing matchpid
replace pid=matchpid if record_id==29467
gen matchcr5id=cr5id if pid=="20130246"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==29467
drop matchpid matchcr5id

gen matchpid=pid if pid=="20150170"
fillmissing matchpid
replace pid=matchpid if record_id==31491
gen matchcr5id=cr5id if pid=="20150170"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==31491
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080332"
fillmissing matchpid
replace pid=matchpid if record_id==33772
gen matchcr5id=cr5id if pid=="20080332"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==33772
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130424"
fillmissing matchpid
replace pid=matchpid if record_id==33012
gen matchcr5id=cr5id if pid=="20130424"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==33012
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130350"
fillmissing matchpid
replace pid=matchpid if record_id==27110
gen matchcr5id=cr5id if pid=="20130350"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==27110
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080454"
fillmissing matchpid
replace pid=matchpid if record_id==27354
gen matchcr5id=cr5id if pid=="20080454"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==27354
drop matchpid matchcr5id

gen matchpid=pid if pid=="20151211"
fillmissing matchpid
replace pid=matchpid if record_id==31508
gen matchcr5id=cr5id if pid=="20151211"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==31508
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080186"
fillmissing matchpid
replace pid=matchpid if record_id==32101
gen matchcr5id=cr5id if pid=="20080186"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==32101
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080005"
fillmissing matchpid
replace pid=matchpid if record_id==29552
gen matchcr5id=cr5id if pid=="20080005"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==29552
drop matchpid matchcr5id

gen matchpid=pid if pid=="20151102"
fillmissing matchpid
replace pid=matchpid if record_id==33877
gen matchcr5id=cr5id if pid=="20151102"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==33877
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130235"
fillmissing matchpid
replace pid=matchpid if record_id==33917
gen matchcr5id=cr5id if pid=="20130235"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==33917
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080603"
fillmissing matchpid
replace pid=matchpid if record_id==27426
gen matchcr5id=cr5id if pid=="20080603"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==27426
drop matchpid matchcr5id

gen matchpid=pid if pid=="20151125"
fillmissing matchpid
replace pid=matchpid if record_id==33807
gen matchcr5id=cr5id if pid=="20151125"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==33807
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080691"
fillmissing matchpid
replace pid=matchpid if record_id==28354
gen matchcr5id=cr5id if pid=="20080691"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==28354
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130653"
fillmissing matchpid
replace pid=matchpid if record_id==29802
gen matchcr5id=cr5id if pid=="20130653"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==29802
drop matchpid matchcr5id

gen matchpid=pid if pid=="20151306"
fillmissing matchpid
replace pid=matchpid if record_id==32224
gen matchcr5id=cr5id if pid=="20151306"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==32224
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130877"
fillmissing matchpid
replace pid=matchpid if record_id==33827
gen matchcr5id=cr5id if pid=="20130877"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==33827
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080244"
fillmissing matchpid
replace pid=matchpid if record_id==27135
gen matchcr5id=cr5id if pid=="20080244"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==27135
drop matchpid matchcr5id

gen matchpid=pid if pid=="20140822"
fillmissing matchpid
replace pid=matchpid if record_id==27892
gen matchcr5id=cr5id if pid=="20140822"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==27892
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080462"
fillmissing matchpid
replace pid=matchpid if record_id==29771
gen matchcr5id=cr5id if pid=="20080462"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==29771
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080249"
fillmissing matchpid
replace pid=matchpid if record_id==32641
gen matchcr5id=cr5id if pid=="20080249"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==32641
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130124"
fillmissing matchpid
replace pid=matchpid if record_id==31884
gen matchcr5id=cr5id if pid=="20130124"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==31884
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080012"
fillmissing matchpid
replace pid=matchpid if record_id==27894
gen matchcr5id=cr5id if pid=="20080012"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==27894
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080363"
fillmissing matchpid
replace pid=matchpid if record_id==25653
gen matchcr5id=cr5id if pid=="20080363"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25653
drop matchpid matchcr5id

gen matchpid=pid if pid=="20140940"
fillmissing matchpid
replace pid=matchpid if record_id==29822
gen matchcr5id=cr5id if pid=="20140940"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==29822
drop matchpid matchcr5id

gen matchpid=pid if pid=="20081109"
fillmissing matchpid
replace pid=matchpid if record_id==32810
gen matchcr5id=cr5id if pid=="20081109"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==32810
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080188"
fillmissing matchpid
replace pid=matchpid if record_id==27183
gen matchcr5id=cr5id if pid=="20080188"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==27183
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080443"
fillmissing matchpid
replace pid=matchpid if record_id==25481
gen matchcr5id=cr5id if pid=="20080443"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25481
drop matchpid matchcr5id

gen matchpid=pid if pid=="20141289"
fillmissing matchpid
replace pid=matchpid if record_id==27424
gen matchcr5id=cr5id if pid=="20141289"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==27424
drop matchpid matchcr5id

gen matchpid=pid if pid=="20141250"
fillmissing matchpid
replace pid=matchpid if record_id==33696
gen matchcr5id=cr5id if pid=="20141250"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==33696
drop matchpid matchcr5id

gen matchpid=pid if pid=="20141562"
fillmissing matchpid
replace pid=matchpid if record_id==33402
gen matchcr5id=cr5id if pid=="20141562"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==33402
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130506"
fillmissing matchpid
replace pid=matchpid if record_id==28246
gen matchcr5id=cr5id if pid=="20130506"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==28246
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080038"
fillmissing matchpid
replace pid=matchpid if record_id==29720
gen matchcr5id=cr5id if pid=="20080038"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==29720
drop matchpid matchcr5id

gen matchpid=pid if pid=="20150024"
fillmissing matchpid
replace pid=matchpid if record_id==31893
gen matchcr5id=cr5id if pid=="20150024"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==31893
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130076"
fillmissing matchpid
replace pid=matchpid if record_id==28144
gen matchcr5id=cr5id if pid=="20130076"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==28144
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130619"
fillmissing matchpid
replace pid=matchpid if record_id==26967
gen matchcr5id=cr5id if pid=="20130619"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26967
drop matchpid matchcr5id

gen matchpid=pid if pid=="20141339"
fillmissing matchpid
replace pid=matchpid if record_id==28468
gen matchcr5id=cr5id if pid=="20141339"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==28468
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080579"
fillmissing matchpid
replace pid=matchpid if record_id==32337
gen matchcr5id=cr5id if pid=="20080579"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==32337
drop matchpid matchcr5id

gen matchpid=pid if pid=="20150546"
fillmissing matchpid
replace pid=matchpid if record_id==32051
gen matchcr5id=cr5id if pid=="20150546"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==32051
drop matchpid matchcr5id

gen matchpid=pid if pid=="20181132"
fillmissing matchpid
replace pid=matchpid if record_id==33285
gen matchcr5id=cr5id if pid=="20181132"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==33285
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130670"
fillmissing matchpid
replace pid=matchpid if record_id==27043
gen matchcr5id=cr5id if pid=="20130670"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==27043
drop matchpid matchcr5id

gen matchpid=pid if pid=="20151004"
fillmissing matchpid
replace pid=matchpid if record_id==32787
gen matchcr5id=cr5id if pid=="20151004"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==32787
drop matchpid matchcr5id

gen matchpid=pid if pid=="20141029"
fillmissing matchpid
replace pid=matchpid if record_id==28735
gen matchcr5id=cr5id if pid=="20141029"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==28735
drop matchpid matchcr5id

gen matchpid=pid if pid=="20150565"
fillmissing matchpid
replace pid=matchpid if record_id==33614
gen matchcr5id=cr5id if pid=="20150565"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==33614
drop matchpid matchcr5id

gen matchpid=pid if pid=="20141031"
fillmissing matchpid
replace pid=matchpid if record_id==32989
gen matchcr5id=cr5id if pid=="20141031"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==32989
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080369"
fillmissing matchpid
replace pid=matchpid if record_id==31796
gen matchcr5id=cr5id if pid=="20080369"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==31796
drop matchpid matchcr5id

gen matchpid=pid if pid=="20140833"
fillmissing matchpid
replace pid=matchpid if record_id==28408
gen matchcr5id=cr5id if pid=="20140833"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==28408
drop matchpid matchcr5id

gen matchpid=pid if pid=="20141348"
fillmissing matchpid
replace pid=matchpid if record_id==27336
gen matchcr5id=cr5id if pid=="20141348"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==27336
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080160"
fillmissing matchpid
replace pid=matchpid if record_id==32115
gen matchcr5id=cr5id if pid=="20080160"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==32115
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130503"
fillmissing matchpid
replace pid=matchpid if record_id==29817
gen matchcr5id=cr5id if pid=="20130503"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==29817
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080237"
fillmissing matchpid
replace pid=matchpid if record_id==33232
gen matchcr5id=cr5id if pid=="20080237"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==33232
drop matchpid matchcr5id

gen matchpid=pid if pid=="20141356"
fillmissing matchpid
replace pid=matchpid if record_id==28329
gen matchcr5id=cr5id if pid=="20141356"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==28329
drop matchpid matchcr5id

gen matchpid=pid if pid=="20150497"
fillmissing matchpid
replace pid=matchpid if record_id==32731
gen matchcr5id=cr5id if pid=="20150497"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==32731
drop matchpid matchcr5id

gen matchpid=pid if pid=="20140744"
fillmissing matchpid
replace pid=matchpid if record_id==19185
gen matchcr5id=cr5id if pid=="20140744"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==19185
drop matchpid matchcr5id

gen matchpid=pid if pid=="20141531"
fillmissing matchpid
replace pid=matchpid if record_id==28500
gen matchcr5id=cr5id if pid=="20141531"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==28500
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130117"
fillmissing matchpid
replace pid=matchpid if record_id==26958
gen matchcr5id=cr5id if pid=="20130117"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26958
drop matchpid matchcr5id

gen matchpid=pid if pid=="20145047"
fillmissing matchpid
replace pid=matchpid if record_id==32418
gen matchcr5id=cr5id if pid=="20145047"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==32418
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080060"
fillmissing matchpid
replace pid=matchpid if record_id==28411
gen matchcr5id=cr5id if pid=="20080060"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==28411
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130121"
fillmissing matchpid
replace pid=matchpid if record_id==27513
gen matchcr5id=cr5id if pid=="20130121"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==27513
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080717"
fillmissing matchpid
replace pid=matchpid if record_id==26083
gen matchcr5id=cr5id if pid=="20080717"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26083
drop matchpid matchcr5id

gen matchpid=pid if pid=="20081103"
fillmissing matchpid
replace pid=matchpid if record_id==29786
gen matchcr5id=cr5id if pid=="20081103"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==29786
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130071"
fillmissing matchpid
replace pid=matchpid if record_id==27454
gen matchcr5id=cr5id if pid=="20130071"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==27454
drop matchpid matchcr5id

gen matchpid=pid if pid=="20151111"
fillmissing matchpid
replace pid=matchpid if record_id==33770
gen matchcr5id=cr5id if pid=="20151111"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==33770
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130088"
fillmissing matchpid
replace pid=matchpid if record_id==29040
gen matchcr5id=cr5id if pid=="20130088"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==29040
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080375"
fillmissing matchpid
replace pid=matchpid if record_id==32254
gen matchcr5id=cr5id if pid=="20080375"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==32254
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080173"
fillmissing matchpid
replace pid=matchpid if record_id==29615
gen matchcr5id=cr5id if pid=="20080173"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==29615
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130042"
fillmissing matchpid
replace pid=matchpid if record_id==32789
gen matchcr5id=cr5id if pid=="20130042"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==32789
drop matchpid matchcr5id

gen matchpid=pid if pid=="20150361"
fillmissing matchpid
replace pid=matchpid if record_id==32204
gen matchcr5id=cr5id if pid=="20150361"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==32204
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130882"
fillmissing matchpid
replace pid=matchpid if record_id==32702
gen matchcr5id=cr5id if pid=="20130882"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==32702
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130054"
fillmissing matchpid
replace pid=matchpid if record_id==29339
gen matchcr5id=cr5id if pid=="20130054"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==29339
drop matchpid matchcr5id

gen matchpid=pid if pid=="20141101"
fillmissing matchpid
replace pid=matchpid if record_id==31511
gen matchcr5id=cr5id if pid=="20141101"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==31511
drop matchpid matchcr5id

gen matchpid=pid if pid=="20140679"
fillmissing matchpid
replace pid=matchpid if record_id==27502
gen matchcr5id=cr5id if pid=="20140679"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==27502
drop matchpid matchcr5id

gen matchpid=pid if pid=="20150016"
fillmissing matchpid
replace pid=matchpid if record_id==32066
gen matchcr5id=cr5id if pid=="20150016"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==32066
drop matchpid matchcr5id

gen matchpid=pid if pid=="20145010"
fillmissing matchpid
replace pid=matchpid if record_id==29889
gen matchcr5id=cr5id if pid=="20145010"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==29889
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130058"
fillmissing matchpid
replace pid=matchpid if record_id==33831
gen matchcr5id=cr5id if pid=="20130058"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==33831
drop matchpid matchcr5id

gen matchpid=pid if pid=="20141288"
fillmissing matchpid
replace pid=matchpid if record_id==27112
gen matchcr5id=cr5id if pid=="20141288"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==27112
drop matchpid matchcr5id

gen matchpid=pid if pid=="20141473"
fillmissing matchpid
replace pid=matchpid if record_id==33776
gen matchcr5id=cr5id if pid=="20141473"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==33776
drop matchpid matchcr5id

gen matchpid=pid if pid=="20145021"
fillmissing matchpid
replace pid=matchpid if record_id==33810
gen matchcr5id=cr5id if pid=="20145021"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==33810
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080180"
fillmissing matchpid
replace pid=matchpid if record_id==32594
gen matchcr5id=cr5id if pid=="20080180"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==32594
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130065"
fillmissing matchpid
replace pid=matchpid if record_id==28698
gen matchcr5id=cr5id if pid=="20130065"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==28698
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080753"
fillmissing matchpid
replace pid=matchpid if record_id==29451
gen matchcr5id=cr5id if pid=="20080753"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==29451
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130236"
fillmissing matchpid
replace pid=matchpid if record_id==31963
gen matchcr5id=cr5id if pid=="20130236"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==31963
drop matchpid matchcr5id


***********
** NAMES **
***********

sort lname fname
quietly by lname fname:  gen dup = cond(_N==1,0,_n)
count if dup>0 //1,949 - check these against electoral list as NRNs in death data often incorrect
order pid record_id fname lname natregno dot dod primarysite coddeath
drop dup


gen matchpid=pid if pid=="20081090"
fillmissing matchpid
replace pid=matchpid if record_id==27433
gen matchcr5id=cr5id if pid=="20081090"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==27433
drop matchpid matchcr5id

gen matchpid=pid if pid=="20150164"
fillmissing matchpid
replace pid=matchpid if record_id==27220
gen matchcr5id=cr5id if pid=="20150164"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==27220
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080215"
fillmissing matchpid
replace pid=matchpid if record_id==29496
gen matchcr5id=cr5id if pid=="20080215"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==29496
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130700"
fillmissing matchpid
replace pid=matchpid if record_id==29790
gen matchcr5id=cr5id if pid=="20130700"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==29790
drop matchpid matchcr5id

gen matchpid=pid if pid=="20141491"
fillmissing matchpid
replace pid=matchpid if record_id==27477
gen matchcr5id=cr5id if pid=="20141491"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==27477
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080500"
fillmissing matchpid
replace pid=matchpid if record_id==29462
gen matchcr5id=cr5id if pid=="20080500"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==29462
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130034"
fillmissing matchpid
replace pid=matchpid if record_id==32603
gen matchcr5id=cr5id if pid=="20130034"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==32603
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080491"
fillmissing matchpid
replace pid=matchpid if record_id==27012
gen matchcr5id=cr5id if pid=="20080491"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==27012
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080270"
fillmissing matchpid
replace pid=matchpid if record_id==28742
gen matchcr5id=cr5id if pid=="20080270"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==28742
drop matchpid matchcr5id

gen matchpid=pid if pid=="20140906"
fillmissing matchpid
replace pid=matchpid if record_id==33269
gen matchcr5id=cr5id if pid=="20140906"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==33269
drop matchpid matchcr5id

gen matchpid=pid if pid=="20140910"
fillmissing matchpid
replace pid=matchpid if record_id==28075
gen matchcr5id=cr5id if pid=="20140910"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==28075
drop matchpid matchcr5id

gen matchpid=pid if pid=="20140691"
fillmissing matchpid
replace pid=matchpid if record_id==32894
gen matchcr5id=cr5id if pid=="20140691"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==32894
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080490"
fillmissing matchpid
replace pid=matchpid if record_id==32497
gen matchcr5id=cr5id if pid=="20080490"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==32497
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080036"
fillmissing matchpid
replace pid=matchpid if record_id==32805
gen matchcr5id=cr5id if pid=="20080036"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==32805
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130580"
fillmissing matchpid
replace pid=matchpid if record_id==32975
gen matchcr5id=cr5id if pid=="20130580"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==32975
drop matchpid matchcr5id

gen matchpid=pid if pid=="20140997"
fillmissing matchpid
replace pid=matchpid if record_id==29446
gen matchcr5id=cr5id if pid=="20140997"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==29446
drop matchpid matchcr5id

gen matchpid=pid if pid=="20140985"
fillmissing matchpid
replace pid=matchpid if record_id==27828
gen matchcr5id=cr5id if pid=="20140985"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==27828
drop matchpid matchcr5id

gen matchpid=pid if pid=="20151030"
fillmissing matchpid
replace pid=matchpid if record_id==33933
gen matchcr5id=cr5id if pid=="20151030"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==33933
drop matchpid matchcr5id

gen matchpid=pid if pid=="20141013"
fillmissing matchpid
replace pid=matchpid if record_id==28530
gen matchcr5id=cr5id if pid=="20141013"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==28530
drop matchpid matchcr5id

gen matchpid=pid if pid=="20150490"
fillmissing matchpid
replace pid=matchpid if record_id==33566
gen matchcr5id=cr5id if pid=="20150490"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==33566
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130808"
fillmissing matchpid
replace pid=matchpid if record_id==27243
gen matchcr5id=cr5id if pid=="20130808"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==27243
drop matchpid matchcr5id

gen matchpid=pid if pid=="20141163"
fillmissing matchpid
replace pid=matchpid if record_id==28466
gen matchcr5id=cr5id if pid=="20141163"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==28466
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130155"
fillmissing matchpid
replace pid=matchpid if record_id==31969
gen matchcr5id=cr5id if pid=="20130155"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==31969
drop matchpid matchcr5id
replace natregno=subinstr(natregno,"43","48",.) if pid=="20130155" //1 change

gen matchpid=pid if pid=="20130285"
fillmissing matchpid
replace pid=matchpid if record_id==29617
gen matchcr5id=cr5id if pid=="20130285"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==29617
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130159"
fillmissing matchpid
replace pid=matchpid if record_id==27677
gen matchcr5id=cr5id if pid=="20130159"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==27677
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080428"
fillmissing matchpid
replace pid=matchpid if record_id==33795
gen matchcr5id=cr5id if pid=="20080428"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==33795
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130203"
fillmissing matchpid
replace pid=matchpid if record_id==31604
gen matchcr5id=cr5id if pid=="20130203"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==31604
drop matchpid matchcr5id

gen matchpid=pid if pid=="20145017"
fillmissing matchpid
replace pid=matchpid if record_id==33470
gen matchcr5id=cr5id if pid=="20145017"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==33470
drop matchpid matchcr5id

gen matchpid=pid if pid=="20130430"
fillmissing matchpid
replace pid=matchpid if record_id==27320
gen matchcr5id=cr5id if pid=="20130430"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==27320
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080546"
fillmissing matchpid
replace pid=matchpid if record_id==33769
gen matchcr5id=cr5id if pid=="20080546"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==33769
drop matchpid matchcr5id

gen matchpid=pid if pid=="20155037"
fillmissing matchpid
replace pid=matchpid if record_id==31991
gen matchcr5id=cr5id if pid=="20155037"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==31991
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080551"
fillmissing matchpid
replace pid=matchpid if record_id==29565
gen matchcr5id=cr5id if pid=="20080551"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==29565
drop matchpid matchcr5id


** Remove unmatched death records + cancer records
count //17,179
drop if record_id!=. & pid=="" //15,293 deleted
drop if pid!="" & record_id==. //1,763

count //123


** Format variables to be merged with cancer dataset
replace deathid=record_id //123 changes
drop record_id
replace slc=2 if slc==. //123 changes
replace dlc=dod if dlc==. & dod!=. //123 changes
replace deceased=1 if deceased==. //123 changes
replace codcancer=cod //123 changes

** Creating one set of death data variables
replace dd_natregno=natregno if dd_natregno=="" & natregno!="" // changes
replace dd_nrn=nrn if dd_nrn==. & nrn!=. //123 changes
replace dd_coddeath=coddeath if dd_coddeath=="" & coddeath!="" //123 changes
replace dd_regnum=regnum if dd_regnum==. & regnum!=. //123 changes
replace dd_pname=pname if dd_pname=="" & pname!="" //123 changes
replace dd_age=age if dd_age==. & age!=. //123 changes
replace dd_cod1a=cod1a if dd_cod1a=="" & cod1a!="" //123 changes
replace dd_address=address if dd_address=="" & address!="" //123 changes
replace dd_parish=parish if dd_parish==. & parish!=. //123 changes
replace dd_pod=pod if dd_pod=="" & pod!="" //123 changes
replace dd_mname=mname if dd_mname=="" & mname!="" //31 changes
replace dd_namematch=namematch if dd_namematch==. & namematch!=. //123 changes
replace dd_dddoa=dddoa if dd_dddoa==. & dddoa!=. //123 changes
replace dd_ddda=ddda if dd_ddda==. & ddda!=. //123 changes
replace dd_odda=odda if dd_odda=="" & odda!="" //24 changes
replace dd_certtype=certtype if dd_certtype==. & certtype!=. //123 changes
replace dd_district=district if dd_district==. & district!=. //123 changes
replace dd_agetxt=agetxt if dd_agetxt==. & agetxt!=. //123 changes
replace dd_nrnnd=nrnnd if dd_nrnnd==. & nrnnd!=. //123 changes
replace dd_mstatus=mstatus if dd_mstatus==. & mstatus!=. //123 changes
replace dd_occu=occu if dd_occu=="" & occu!="" //123 changes
replace dd_durationnum=durationnum if dd_durationnum==. & durationnum!=. //123 changes
replace dd_durationtxt=durationtxt if dd_durationtxt==. & durationtxt!=. //107 changes
replace dd_onsetnumcod1a=onsetnumcod1a if dd_onsetnumcod1a==. & onsetnumcod1a!=. //123 changes
replace dd_onsettxtcod1a=onsettxtcod1a if dd_onsettxtcod1a==. & onsettxtcod1a!=. //89 changes
replace dd_cod1b=cod1b if dd_cod1b=="" & cod1b!="" //123 changes
replace dd_onsetnumcod1b=onsetnumcod1b if dd_onsetnumcod1b==. & onsetnumcod1b!=. //57 changes
replace dd_onsettxtcod1b=onsettxtcod1b if dd_onsettxtcod1b==. & onsettxtcod1b!=. //39 changes
replace dd_cod1c=cod1c if dd_cod1c=="" & cod1c!="" //123 changes
replace dd_onsetnumcod1c=onsetnumcod1c if dd_onsetnumcod1c==. & onsetnumcod1c!=. //21 changes
replace dd_onsettxtcod1c=onsettxtcod1c if dd_onsettxtcod1c==. & onsettxtcod1c!=. //13 changes
replace dd_cod1d=cod1d if dd_cod1d=="" & cod1d!="" //123 changes
replace dd_onsetnumcod1d=onsetnumcod1d if dd_onsetnumcod1d==. & onsetnumcod1d!=. //11 changes
replace dd_onsettxtcod1d=onsettxtcod1d if dd_onsettxtcod1d==. & onsettxtcod1d!=. //5 changes
replace dd_cod2a=cod2a if dd_cod2a=="" & cod2a!="" //123 changes
replace dd_onsetnumcod2a=onsetnumcod2a if dd_onsetnumcod2a==. & onsetnumcod2a!=. //50 changes
replace dd_onsettxtcod2a=onsettxtcod2a if dd_onsettxtcod2a==. & onsettxtcod2a!=. //37 changes
replace dd_cod2b=cod2b if dd_cod2b=="" & cod2b!="" //123 changes
replace dd_onsetnumcod2b=onsetnumcod2b if dd_onsetnumcod2b==. & onsetnumcod2b!=. //25 changes
replace dd_onsettxtcod2b=onsettxtcod2b if dd_onsettxtcod2b==. & onsettxtcod2b!=. //17 changes
replace dd_deathparish=deathparish if dd_deathparish==. & deathparish!=. //123 changes
replace dd_regdate=regdate if dd_regdate==. & regdate!=. //123 changes
replace dd_certifier=certifier if dd_certifier=="" & certifier!="" //123 changes
replace dd_certifieraddr=certifieraddr if dd_certifieraddr=="" & certifieraddr!="" //123 changes
replace dd_cleaned=cleaned if dd_cleaned==. & cleaned!=. //123 changes
replace dd_duprec=duprec if dd_duprec==. & duprec!=. //0 changes
replace dd_dodyear=dodyear if dd_dodyear==. & dodyear!=. //123 changes
replace dd_dod=dod if dd_dod==. & dod!=. //123 changes


** Remove variables NOT to be updated when merging with cancer dataset
drop fname lname natregno dot primarysite dob age init sex resident ///
	 cr5cod morph top lat beh hx grade eid sid patient eidmp ptrectot dcostatus ///
	 dupsource recstatus stda nftype sourcename doctor docaddr recnum cfdx labnum ///
	 specimen clindets cytofinds md consrpt duration onsetint streviewer checkstatus ///
	 MultiplePrimary mpseq mptot tumourupdatedby ttda addr topography basis staging ///
	 dxyr consultant iccc icd10 rx1 rx2 rx3 rx4 rx5 rx5d orx1 orx2 norx1 norx2 ttreviewer ///
	 persearch birthdate hospnum comments ptda cstatus patientupdatedby PatientRecordStatus ///
	 PatientCheckStatus retsource notesseen fretsource ptreviewer dotmonth dotday sourcetotal ///
	 ptupdate ptdoa nsdate ttupdate ttdoa rx1d rx2d rx3d rx4d stdoa sampledate recvdate rptdate ///
	 admdate dfc rtdate topcat topcheckcat morphcat morphcheckcat hxcheckcat agecheckcat hxfamcat ///
	 sexcheckcat sitecheckcat codcat latcat latcheckcat behcheckcat behsitecheckcat gradecheckcat ///
	 bascheckcat stagecheckcat dotcheckcat dxyrcheckcat rxcheckcat orxcheckcat norxcheckcat ///
	 sourcecheckcat doccheckcat docaddrcheckcat rptcheckcat datescheckcat miss2013abs siteiarc ///
	 siteiarchaem siteicd10 allsites allsitesbC44 sitecr5db sitear updatenotes1 updatenotes2 ///
	 updatenotes3 dot_iarc dob_iarc namematch nrnyear dd2019_nrn dd2019_coddeath dd2019_regnum ///
	 dd2019_pname dd2019_age dd2019_cod1a dd2019_address dd2019_parish dd2019_pod dd2019_mname ///
	 dd2019_namematch dd2019_dddoa dd2019_ddda dd2019_odda dd2019_certtype dd2019_district ///
	 dd2019_agetxt dd2019_nrnnd dd2019_mstatus dd2019_occu dd2019_durationnum dd2019_durationtxt ///
	 dd2019_onsetnumcod1a dd2019_onsettxtcod1a dd2019_cod1b dd2019_onsetnumcod1b dd2019_onsettxtcod1b ///
	 dd2019_cod1c dd2019_onsetnumcod1c dd2019_onsettxtcod1c dd2019_cod1d dd2019_onsetnumcod1d ///
	 dd2019_onsettxtcod1d dd2019_cod2a dd2019_onsetnumcod2a dd2019_onsettxtcod2a dd2019_cod2b ///
	 dd2019_onsetnumcod2b dd2019_onsettxtcod2b dd2019_deathparish dd2019_regdate dd2019_certifier ///
	 dd2019_certifieraddr dd2019_duprec dd2019_dodyear dd2019_dod dotyear multipleprimary ///
	 patientrecordstatus patientcheckstatus allsitesbc44 nrn cod1a address pod mname dddoa ddda odda ///
	 certtype district agetxt nrnnd mstatus occu durationnum durationtxt onsetnumcod1a onsettxtcod1a ///
	 cod1b onsetnumcod1b onsettxtcod1b cod1c onsetnumcod1c onsettxtcod1c cod1d onsetnumcod1d onsettxtcod1d ///
	 cod2a onsetnumcod2a onsettxtcod2a cod2b onsetnumcod2b onsettxtcod2b deathparish regdate certifieraddr ///
	 cleaned duprec elecmatch dodyear
	 
** Create death dataset to merge with cancer dataset (see dofile 16)
save "`datapath'\version02\2-working\2008_2013_2014_2015_cancer ds_2015-2020 deaths matched", replace