** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          50_death match.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      27-JUL-2021
    // 	date last modified      29-JUL-2021
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
use "`datapath'\version02\3-output\2008_2013_2014_2015_cancer ds_2015-2020 death matching", clear

** Remove deceased cases from cancer dataset
count //4,066
count if slc==2 //2,300
drop if slc==2 //2,300 deleted

** Add death dataset
append using "`datapath'\version02\3-output\2015-2020_deaths_for_appending"

count //17,182

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
//920 deleted
sort natregno 
quietly by natregno : gen dup = cond(_N==1,0,_n)
sort natregno lname fname pid record_id 
count if dup>0 //1048 - review these in Stata's Browse/Edit window
order pid record_id nrn natregno fname lname
restore

//gen match=1 if pid=="20081078"|record_id==17563
gen matchpid=pid if pid=="20081078"
//tostring matchpid ,replace
fillmissing matchpid
replace pid=matchpid if record_id==17563
//gen matchrecid=record_id if record_id==17563
//tostring matchrecid ,replace
//replace matchrecid="" if matchrecid=="."
//fillmissing matchrecid
//gen matchid=matchpid+"-"+matchrecid if match==1
//drop matchpid matchrecid
drop matchpid

gen matchpid=pid if pid=="20080474"
fillmissing matchpid
replace pid=matchpid if record_id==24264
drop matchpid

gen matchpid=pid if pid=="20130087"
fillmissing matchpid
replace pid=matchpid if record_id==31937
drop matchpid

gen matchpid=pid if pid=="20080512"
fillmissing matchpid
replace pid=matchpid if record_id==26039
drop matchpid

gen matchpid=pid if pid=="20080881"
fillmissing matchpid
replace pid=matchpid if record_id==20568
drop matchpid

gen matchpid=pid if pid=="20080370"
fillmissing matchpid
replace pid=matchpid if record_id==25205
drop matchpid

gen matchpid=pid if pid=="20151027"
fillmissing matchpid
replace pid=matchpid if record_id==24284
drop matchpid


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
gen dd_birthdate=dobyear+dobmonth+dobday if dobyear!="" & dobyear!="." //4,061 changes

gen dobyr=substr(natregno, 1, 2) if natregno!=""
gen dobmon=substr(natregno, 3, 2) if natregno!=""
gen dobdy=substr(natregno, 5, 2) if natregno!=""
replace dd_birthdate=dobyr+dobmon+dobdy if dd_birthdate=="" //12,395 changes

drop if dobmon=="99" | dobday=="99" //108 deleted
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
count if dup>0 //318 - review these in Stata's Browse/Edit window
order pid record_id fname lname natregno dot dod primarysite coddeath
restore


gen matchpid=pid if pid=="20130021"
fillmissing matchpid
replace pid=matchpid if record_id==32102
drop matchpid

gen matchpid=pid if pid=="20080009"
fillmissing matchpid
replace pid=matchpid if record_id==31975
drop matchpid

gen matchpid=pid if pid=="20080568"
fillmissing matchpid
replace pid=matchpid if record_id==32773
drop matchpid

gen matchpid=pid if pid=="20080008"
fillmissing matchpid
replace pid=matchpid if record_id==33803
drop matchpid

gen matchpid=pid if pid=="20130246"
fillmissing matchpid
replace pid=matchpid if record_id==29467
drop matchpid

gen matchpid=pid if pid=="20150170"
fillmissing matchpid
replace pid=matchpid if record_id==31491
drop matchpid

gen matchpid=pid if pid=="20080332"
fillmissing matchpid
replace pid=matchpid if record_id==33772
drop matchpid

gen matchpid=pid if pid=="20130424"
fillmissing matchpid
replace pid=matchpid if record_id==33012
drop matchpid

gen matchpid=pid if pid=="20130350"
fillmissing matchpid
replace pid=matchpid if record_id==27110
drop matchpid

gen matchpid=pid if pid=="20080454"
fillmissing matchpid
replace pid=matchpid if record_id==27354
drop matchpid

gen matchpid=pid if pid=="20151211"
fillmissing matchpid
replace pid=matchpid if record_id==31508
drop matchpid

gen matchpid=pid if pid=="20080186"
fillmissing matchpid
replace pid=matchpid if record_id==32101
drop matchpid

gen matchpid=pid if pid=="20080005"
fillmissing matchpid
replace pid=matchpid if record_id==29552
drop matchpid

gen matchpid=pid if pid=="20151102"
fillmissing matchpid
replace pid=matchpid if record_id==33877
drop matchpid

gen matchpid=pid if pid=="20130235"
fillmissing matchpid
replace pid=matchpid if record_id==33917
drop matchpid

gen matchpid=pid if pid=="20080603"
fillmissing matchpid
replace pid=matchpid if record_id==27426
drop matchpid

gen matchpid=pid if pid=="20151125"
fillmissing matchpid
replace pid=matchpid if record_id==33807
drop matchpid

gen matchpid=pid if pid=="20080691"
fillmissing matchpid
replace pid=matchpid if record_id==28354
drop matchpid

gen matchpid=pid if pid=="20130653"
fillmissing matchpid
replace pid=matchpid if record_id==29802
drop matchpid

gen matchpid=pid if pid=="20151306"
fillmissing matchpid
replace pid=matchpid if record_id==32224
drop matchpid

gen matchpid=pid if pid=="20130877"
fillmissing matchpid
replace pid=matchpid if record_id==33827
drop matchpid

gen matchpid=pid if pid=="20080244"
fillmissing matchpid
replace pid=matchpid if record_id==27135
drop matchpid

gen matchpid=pid if pid=="20140822"
fillmissing matchpid
replace pid=matchpid if record_id==27892
drop matchpid

gen matchpid=pid if pid=="20080462"
fillmissing matchpid
replace pid=matchpid if record_id==29771
drop matchpid

gen matchpid=pid if pid=="20080249"
fillmissing matchpid
replace pid=matchpid if record_id==32641
drop matchpid

gen matchpid=pid if pid=="20130124"
fillmissing matchpid
replace pid=matchpid if record_id==31884
drop matchpid

gen matchpid=pid if pid=="20080012"
fillmissing matchpid
replace pid=matchpid if record_id==27894
drop matchpid

gen matchpid=pid if pid=="20080363"
fillmissing matchpid
replace pid=matchpid if record_id==25653
drop matchpid

gen matchpid=pid if pid=="20140940"
fillmissing matchpid
replace pid=matchpid if record_id==29822
drop matchpid

gen matchpid=pid if pid=="20081109"
fillmissing matchpid
replace pid=matchpid if record_id==32810
drop matchpid

gen matchpid=pid if pid=="20080188"
fillmissing matchpid
replace pid=matchpid if record_id==27183
drop matchpid

gen matchpid=pid if pid=="20080443"
fillmissing matchpid
replace pid=matchpid if record_id==25481
drop matchpid

gen matchpid=pid if pid=="20141289"
fillmissing matchpid
replace pid=matchpid if record_id==27424
drop matchpid

gen matchpid=pid if pid=="20141250"
fillmissing matchpid
replace pid=matchpid if record_id==33696
drop matchpid

gen matchpid=pid if pid=="20141562"
fillmissing matchpid
replace pid=matchpid if record_id==33402
drop matchpid

gen matchpid=pid if pid=="20130506"
fillmissing matchpid
replace pid=matchpid if record_id==28246
drop matchpid

gen matchpid=pid if pid=="20080038"
fillmissing matchpid
replace pid=matchpid if record_id==29720
drop matchpid

gen matchpid=pid if pid=="20150024"
fillmissing matchpid
replace pid=matchpid if record_id==31893
drop matchpid

gen matchpid=pid if pid=="20130076"
fillmissing matchpid
replace pid=matchpid if record_id==28144
drop matchpid

gen matchpid=pid if pid=="20130619"
fillmissing matchpid
replace pid=matchpid if record_id==26967
drop matchpid

gen matchpid=pid if pid=="20141339"
fillmissing matchpid
replace pid=matchpid if record_id==28468
drop matchpid

gen matchpid=pid if pid=="20080579"
fillmissing matchpid
replace pid=matchpid if record_id==32337
drop matchpid

gen matchpid=pid if pid=="20150546"
fillmissing matchpid
replace pid=matchpid if record_id==32051
drop matchpid

gen matchpid=pid if pid=="20181132"
fillmissing matchpid
replace pid=matchpid if record_id==33285
drop matchpid

gen matchpid=pid if pid=="20130670"
fillmissing matchpid
replace pid=matchpid if record_id==27043
drop matchpid

gen matchpid=pid if pid=="20151004"
fillmissing matchpid
replace pid=matchpid if record_id==32787
drop matchpid

gen matchpid=pid if pid=="20141029"
fillmissing matchpid
replace pid=matchpid if record_id==28735
drop matchpid

gen matchpid=pid if pid=="20150565"
fillmissing matchpid
replace pid=matchpid if record_id==33614
drop matchpid

gen matchpid=pid if pid=="20141031"
fillmissing matchpid
replace pid=matchpid if record_id==32989
drop matchpid

gen matchpid=pid if pid=="20080369"
fillmissing matchpid
replace pid=matchpid if record_id==31796
drop matchpid

gen matchpid=pid if pid=="20140833"
fillmissing matchpid
replace pid=matchpid if record_id==28408
drop matchpid

gen matchpid=pid if pid=="20141348"
fillmissing matchpid
replace pid=matchpid if record_id==27336
drop matchpid

gen matchpid=pid if pid=="20080160"
fillmissing matchpid
replace pid=matchpid if record_id==32115
drop matchpid

gen matchpid=pid if pid=="20130503"
fillmissing matchpid
replace pid=matchpid if record_id==29817
drop matchpid

gen matchpid=pid if pid=="20080237"
fillmissing matchpid
replace pid=matchpid if record_id==33232
drop matchpid

gen matchpid=pid if pid=="20141356"
fillmissing matchpid
replace pid=matchpid if record_id==28329
drop matchpid

gen matchpid=pid if pid=="20150497"
fillmissing matchpid
replace pid=matchpid if record_id==32731
drop matchpid

gen matchpid=pid if pid=="20140744"
fillmissing matchpid
replace pid=matchpid if record_id==19185
drop matchpid

gen matchpid=pid if pid=="20141531"
fillmissing matchpid
replace pid=matchpid if record_id==28500
drop matchpid

gen matchpid=pid if pid=="20130117"
fillmissing matchpid
replace pid=matchpid if record_id==26958
drop matchpid

gen matchpid=pid if pid=="20145047"
fillmissing matchpid
replace pid=matchpid if record_id==32418
drop matchpid

gen matchpid=pid if pid=="20080060"
fillmissing matchpid
replace pid=matchpid if record_id==28411
drop matchpid

gen matchpid=pid if pid=="20130121"
fillmissing matchpid
replace pid=matchpid if record_id==27513
drop matchpid

gen matchpid=pid if pid=="20080717"
fillmissing matchpid
replace pid=matchpid if record_id==26083
drop matchpid

gen matchpid=pid if pid=="20081103"
fillmissing matchpid
replace pid=matchpid if record_id==29786
drop matchpid

gen matchpid=pid if pid=="20130071"
fillmissing matchpid
replace pid=matchpid if record_id==27454
drop matchpid

gen matchpid=pid if pid=="20151111"
fillmissing matchpid
replace pid=matchpid if record_id==33770
drop matchpid

gen matchpid=pid if pid=="20130088"
fillmissing matchpid
replace pid=matchpid if record_id==29040
drop matchpid

gen matchpid=pid if pid=="20080375"
fillmissing matchpid
replace pid=matchpid if record_id==32254
drop matchpid

gen matchpid=pid if pid=="20080173"
fillmissing matchpid
replace pid=matchpid if record_id==29615
drop matchpid

gen matchpid=pid if pid=="20130042"
fillmissing matchpid
replace pid=matchpid if record_id==32789
drop matchpid

gen matchpid=pid if pid=="20150361"
fillmissing matchpid
replace pid=matchpid if record_id==32204
drop matchpid

gen matchpid=pid if pid=="20130882"
fillmissing matchpid
replace pid=matchpid if record_id==32702
drop matchpid

gen matchpid=pid if pid=="20130054"
fillmissing matchpid
replace pid=matchpid if record_id==29339
drop matchpid

gen matchpid=pid if pid=="20141101"
fillmissing matchpid
replace pid=matchpid if record_id==31511
drop matchpid

gen matchpid=pid if pid=="20140679"
fillmissing matchpid
replace pid=matchpid if record_id==27502
drop matchpid

gen matchpid=pid if pid=="20150016"
fillmissing matchpid
replace pid=matchpid if record_id==32066
drop matchpid

gen matchpid=pid if pid=="20145010"
fillmissing matchpid
replace pid=matchpid if record_id==29889
drop matchpid

gen matchpid=pid if pid=="20130058"
fillmissing matchpid
replace pid=matchpid if record_id==33831
drop matchpid

gen matchpid=pid if pid=="20141288"
fillmissing matchpid
replace pid=matchpid if record_id==27112
drop matchpid

gen matchpid=pid if pid=="20141473"
fillmissing matchpid
replace pid=matchpid if record_id==33776
drop matchpid

gen matchpid=pid if pid=="20145021"
fillmissing matchpid
replace pid=matchpid if record_id==33810
drop matchpid

gen matchpid=pid if pid=="20080180"
fillmissing matchpid
replace pid=matchpid if record_id==32594
drop matchpid

gen matchpid=pid if pid=="20130065"
fillmissing matchpid
replace pid=matchpid if record_id==28698
drop matchpid

gen matchpid=pid if pid=="20080753"
fillmissing matchpid
replace pid=matchpid if record_id==29451
drop matchpid

gen matchpid=pid if pid=="20130236"
fillmissing matchpid
replace pid=matchpid if record_id==31963
drop matchpid


***********
** NAMES **
***********

sort lname fname
quietly by lname fname:  gen dup = cond(_N==1,0,_n)
count if dup>0 //1,953 - check these against electoral list as NRNs in death data often incorrect
order pid record_id fname lname natregno dot dod primarysite coddeath
stop
drop dup


gen matchpid=pid if pid=="20081090"
fillmissing matchpid
replace pid=matchpid if record_id==27433
drop matchpid

gen matchpid=pid if pid=="20150164"
fillmissing matchpid
replace pid=matchpid if record_id==27220
drop matchpid

gen matchpid=pid if pid=="20080215"
fillmissing matchpid
replace pid=matchpid if record_id==29496
drop matchpid

gen matchpid=pid if pid=="20130700"
fillmissing matchpid
replace pid=matchpid if record_id==29790
drop matchpid

gen matchpid=pid if pid=="20141491"
fillmissing matchpid
replace pid=matchpid if record_id==27477
drop matchpid

gen matchpid=pid if pid=="20080500"
fillmissing matchpid
replace pid=matchpid if record_id==29462
drop matchpid

gen matchpid=pid if pid=="20130034"
fillmissing matchpid
replace pid=matchpid if record_id==32603
drop matchpid

gen matchpid=pid if pid=="20080491"
fillmissing matchpid
replace pid=matchpid if record_id==27012
drop matchpid

gen matchpid=pid if pid=="20080270"
fillmissing matchpid
replace pid=matchpid if record_id==28742
drop matchpid

gen matchpid=pid if pid=="20140906"
fillmissing matchpid
replace pid=matchpid if record_id==33269
drop matchpid

gen matchpid=pid if pid=="20140910"
fillmissing matchpid
replace pid=matchpid if record_id==28075
drop matchpid

gen matchpid=pid if pid=="20140691"
fillmissing matchpid
replace pid=matchpid if record_id==32894
drop matchpid

gen matchpid=pid if pid=="20080490"
fillmissing matchpid
replace pid=matchpid if record_id==32497
drop matchpid

gen matchpid=pid if pid=="20080036"
fillmissing matchpid
replace pid=matchpid if record_id==32805
drop matchpid

gen matchpid=pid if pid=="20130580"
fillmissing matchpid
replace pid=matchpid if record_id==32975
drop matchpid

gen matchpid=pid if pid=="20140997"
fillmissing matchpid
replace pid=matchpid if record_id==29446
drop matchpid

gen matchpid=pid if pid=="20140985"
fillmissing matchpid
replace pid=matchpid if record_id==27828
drop matchpid

gen matchpid=pid if pid=="20151030"
fillmissing matchpid
replace pid=matchpid if record_id==33933
drop matchpid

gen matchpid=pid if pid=="20141013"
fillmissing matchpid
replace pid=matchpid if record_id==28530
drop matchpid

gen matchpid=pid if pid=="20150490"
fillmissing matchpid
replace pid=matchpid if record_id==33566
drop matchpid

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
drop matchpid

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
drop matchpid

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
drop matchpid

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
drop matchpid

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
drop matchpid

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
drop matchpid

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
drop matchpid

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
drop matchpid

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
drop matchpid

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
drop matchpid

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
drop matchpid

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
drop matchpid

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
drop matchpid

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
drop matchpid

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
drop matchpid

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
drop matchpid

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
drop matchpid

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
drop matchpid

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
drop matchpid

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
drop matchpid

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
drop matchpid

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
drop matchpid

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
drop matchpid

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
drop matchpid

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
drop matchpid

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
drop matchpid

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
drop matchpid

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
drop matchpid

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
drop matchpid



REMOVE ALL UNMATCHED RECORDS + CANCER RECORDS so keep matched death data with pid and record_id filled in to merge with cancer dataset