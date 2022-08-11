** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          20d_death match.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      11-AUG-2022
    // 	date last modified      11-AUG-2022
    //  algorithm task          Matching cleaned, current and previous cancer datasets with cleaned death 2015-2021 dataset
    //  status                  Completed
    //  objective               To have a cleaned and matched dataset with updated vital status
    //  methods                 (1) Combine datasets of previous and current years (from dofiles 20a + 20b)
	//							(2) Create incidence matching ds by removing previously matched cases
	//							(3) Add 2008-2021 death matching dataset (from dofile 5d)
	//							(4) Perform duplicates checks using NRN, DOB and NAMES
	//							(5) Fill in pid and cr5id variables in matched death record 
	//							(6) Prep matched deaths for merge with ds in dofile 20e

    ** General algorithm set-up
    version 17.0
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
    log using "`logpath'\20d_death match.smcl", replace
** HEADER -----------------------------------------------------

*********************
** PREP AND FORMAT **
*********************
** Combine previous cancer incidence ds (from dofile 20b_update previous years cancer.do) with current cancer incidence ds (from dofile 20a_clean current years cancer.do)
use "`datapath'\version09\3-output\2016-2018_cancer_nonreportable_identifiable", clear

drop flag*

count //3260

append using "`datapath'\version09\3-output\2008_2013_2014_2015_crosschecked_nonreportable"
drop flag*

count //7288

** Save this ds for use in final clean dofile 20e
save "`datapath'\version09\3-output\2008_2013-2018_nonreportable_identifiable" ,replace

** Check for and remove cases that have been previously matched
count if deathid==. //4904
count if deathid!=. //2384 - cases that have previously matched with death data
count if deathid==. & slc==1 //3144 - alive cases
count if deathid==. & slc!=1 //1760 - deceased cases that have not been previously matched with death data
//count if dd_dod==. & slc!=1 //1729

** JC 11aug2022: with the old death matching method (merging based on name) some cases were incorrectly matched to the wrong person
** Identify and correct these previous incorrect matches
count if deathid!=. & slc==1 //7 - reviewed in multiyr REDCap deathdb: previously matched to different person with same name
list pid cr5id dxyr fname lname natregno slc dlc dod dd_dod dd_dodyear deathid if deathid!=. & slc==1
replace deathid=. if pid=="20081085"
replace deathid=. if pid=="20150033"
replace deathid=. if pid=="20150457"
replace deathid=. if pid=="20150514"
replace deathid=. if pid=="20151146"
replace deathid=. if pid=="20151206"
replace deathid=. if pid=="20151241"

count if deathid!=. & slc!=2 //0

count if deathid==. //4911
count if deathid!=. //2377 - cases that have previously matched with death data
count if deathid!=. & dd_coddeath=="" //41 - some cases seemed to have been matched but others have not although they have the correct deathid
replace dd_coddeath=dd_cod1a if deathid!=. & dd_coddeath=="" & dd_cod1a!="" //36 changes
list pid cr5id dxyr fname lname natregno slc dlc dod dd_dod dd_dodyear deathid if deathid!=. & dd_coddeath=="" //5 - 1 has incorrect deathid but all are correct but do not have death data merged so need to create a variable to identify cases that need to be matched
replace deathid=. if pid=="20080885"

count if deathid!=. & dd_cod1a=="" //1556
tab dxyr if deathid!=. & dd_cod1a=="" //2008, 2013-2015 (mainly 2008, 2013, 2014)
count if deathid==. & slc==1 //3151 - alive cases
count if deathid==. & slc!=1 //1761 - deceased cases that have not been previously matched with death data

** Since a few have correct deathid but no merged death data, create a variable to identify cases that need to be matched
gen tomatch=1 if deathid==. //4912 changes
replace tomatch=1 if deathid!=. & dd_coddeath=="" //4 changes

count if tomatch!=. //4916
count //7288
drop if tomatch==. //2372 deleted

count //4916

** Create cancer incidence ds for matching with 2015-2021 death ds
** Note only match with 2015-2021 deaths as the previous years were already matched to 2008-2014 deaths
save "`datapath'\version09\2-working\2008_2013-2018_cancer for death matching", replace


** Add death dataset created in dofile 5d_prep match mort.do
append using "`datapath'\version09\3-output\2015-2021_deaths_for_matching"

count //23,478

order pid record_id fname lname natregno dob age

********************************
** CHECK AND IDENTIFY MATCHES **
********************************
** Search for matches by NRN, DOB, NAMES

*********
** NRN **
********* 
** Check NRN is correctly formatted in prep for duplicate check
count if length(natregno)==9 //0
count if length(natregno)==8 //0
count if length(natregno)==7 //0

count if natregno=="" & dd_natregno!="" //17,753
replace natregno=dd_natregno if natregno=="" & dd_natregno!="" //17,753 changes

count if natregno==""|natregno=="999999-9999"|regexm(natregno,"9999") //1045 - a combo of missing NRNs from both cancer ds and death ds
count if dd_natregno=="" & dd_nrn!=. //1 - checked in electoral list and this is the correct NRN for this person; I corrected in 5d_prep match mort.do instead of below so this now is 0
/*
list pid record_id fname lname if dd_natregno=="" & dd_nrn!=.
gen nrn2=dd_nrn if dd_natregno=="" & dd_nrn!=.
tostring nrn2 ,replace
replace dd_natregno=nrn2 if record_id==28513
replace natregno=dd_natregno if record_id==28513
drop nrn2
*/
STOP
** Identify possible matches using NRN
preserve
drop if natregno==""|natregno=="999999-9999"|regexm(natregno,"9999") //remove blank/missing NRNs as these will be flagged as duplicates of each other
//1045 deleted
sort natregno 
quietly by natregno : gen dup = cond(_N==1,0,_n)
sort natregno lname fname pid record_id 
count if dup>0 //3808 - review these in Stata's Browse/Edit window
order pid cr5id record_id deathid dd_natregno natregno dd_fname dd_lname fname lname dd_age age dd_dodyear dxyr dd_coddeath morph
restore

gen matchpid=pid if pid=="20161011"
fillmissing matchpid
replace pid=matchpid if record_id==21416
gen matchcr5id=cr5id if pid=="20161011"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21416
drop matchpid matchcr5id
gen matched=1 if pid=="20161011"|record_id==21416

gen matchpid=pid if pid=="20170710"
fillmissing matchpid
replace pid=matchpid if record_id==22552
gen matchcr5id=cr5id if pid=="20170710"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22552
drop matchpid matchcr5id
replace matched=1 if pid=="20170710"|record_id==22552

gen matchpid=pid if pid=="20160655"
fillmissing matchpid
replace pid=matchpid if record_id==30043
gen matchcr5id=cr5id if pid=="20160655"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==30043
drop matchpid matchcr5id
replace matched=1 if pid=="20160655"|record_id==30043

gen matchpid=pid if pid=="20181178"
fillmissing matchpid
replace pid=matchpid if record_id==26175
gen matchcr5id=cr5id if pid=="20181178"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26175
drop matchpid matchcr5id
replace matched=1 if pid=="20181178"|record_id==26175

gen matchpid=pid if pid=="20170929"
fillmissing matchpid
replace pid=matchpid if record_id==24678
gen matchcr5id=cr5id if pid=="20170929"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24678
drop matchpid matchcr5id
replace matched=1 if pid=="20170929"|record_id==24678

gen matchpid=pid if pid=="20161220"
fillmissing matchpid
replace pid=matchpid if record_id==21047
gen matchcr5id=cr5id if pid=="20161220"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21047
drop matchpid matchcr5id
replace matched=1 if pid=="20161220"|record_id==21047

gen matchpid=pid if pid=="20160687"
fillmissing matchpid
replace pid=matchpid if record_id==20629
gen matchcr5id=cr5id if pid=="20160687"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20629
drop matchpid matchcr5id
replace matched=1 if pid=="20160687"|record_id==20629

gen matchpid=pid if pid=="20170947"
fillmissing matchpid
replace pid=matchpid if record_id==22943
gen matchcr5id=cr5id if pid=="20170947"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22943
drop matchpid matchcr5id
replace matched=1 if pid=="20170947"|record_id==22943

gen matchpid=pid if pid=="20160473"
fillmissing matchpid
replace pid=matchpid if record_id==20667
gen matchcr5id=cr5id if pid=="20160473"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20667
drop matchpid matchcr5id
replace matched=1 if pid=="20160473"|record_id==20667

gen matchpid=pid if pid=="20130290"
fillmissing matchpid
replace pid=matchpid if record_id==35859
gen matchcr5id=cr5id if pid=="20130290"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==35859
drop matchpid matchcr5id
replace matched=1 if pid=="20130290"|record_id==35859

gen matchpid=pid if pid=="20180401"
fillmissing matchpid
replace pid=matchpid if record_id==34432
gen matchcr5id=cr5id if pid=="20180401"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==34432
drop matchpid matchcr5id
replace matched=1 if pid=="20180401"|record_id==34432

gen matchpid=pid if pid=="20180192"
fillmissing matchpid
replace pid=matchpid if record_id==25129
gen matchcr5id=cr5id if pid=="20180192"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25129
drop matchpid matchcr5id
replace matched=1 if pid=="20180192"|record_id==25129

gen matchpid=pid if pid=="20180934"
fillmissing matchpid
replace pid=matchpid if record_id==25127
gen matchcr5id=cr5id if pid=="20180934"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25127
drop matchpid matchcr5id
replace matched=1 if pid=="20180934"|record_id==25127

gen matchpid=pid if pid=="20161215"
fillmissing matchpid
replace pid=matchpid if record_id==21409
gen matchcr5id=cr5id if pid=="20161215"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21409
drop matchpid matchcr5id
replace matched=1 if pid=="20161215"|record_id==21409

gen matchpid=pid if pid=="20161205"
fillmissing matchpid
replace pid=matchpid if record_id==19975
gen matchcr5id=cr5id if pid=="20161205"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==19975
drop matchpid matchcr5id
replace matched=1 if pid=="20161205"|record_id==19975

gen matchpid=pid if pid=="20180897"
fillmissing matchpid
replace pid=matchpid if record_id==26155
gen matchcr5id=cr5id if pid=="20180897"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26155
drop matchpid matchcr5id
replace matched=1 if pid=="20180897"|record_id==26155

gen matchpid=pid if pid=="20170992"
fillmissing matchpid
replace pid=matchpid if record_id==23387
gen matchcr5id=cr5id if pid=="20170992"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23387
drop matchpid matchcr5id
replace matched=1 if pid=="20170992"|record_id==23387

gen matchpid=pid if pid=="20170953"
fillmissing matchpid
replace pid=matchpid if record_id==22713
gen matchcr5id=cr5id if pid=="20170953"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22713
drop matchpid matchcr5id
replace matched=1 if pid=="20170953"|record_id==22713

gen matchpid=pid if pid=="20170714"
fillmissing matchpid
replace pid=matchpid if record_id==22623
gen matchcr5id=cr5id if pid=="20170714"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22623
drop matchpid matchcr5id
replace matched=1 if pid=="20170714"|record_id==22623

gen matchpid=pid if pid=="20080363"
fillmissing matchpid
replace pid=matchpid if record_id==25653
gen matchcr5id=cr5id if pid=="20080363"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25653
drop matchpid matchcr5id
replace matched=1 if pid=="20080363"|record_id==25653

gen matchpid=pid if pid=="20160740"
fillmissing matchpid
replace pid=matchpid if record_id==22148
gen matchcr5id=cr5id if pid=="20160740"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22148
drop matchpid matchcr5id
replace matched=1 if pid=="20160740"|record_id==22148

gen matchpid=pid if pid=="20180873"
fillmissing matchpid
replace pid=matchpid if record_id==26575
gen matchcr5id=cr5id if pid=="20180873"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26575
drop matchpid matchcr5id
replace matched=1 if pid=="20180873"|record_id==26575

gen matchpid=pid if pid=="20180787"
fillmissing matchpid
replace pid=matchpid if record_id==25590
gen matchcr5id=cr5id if pid=="20180787"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25590
drop matchpid matchcr5id
replace matched=1 if pid=="20180787"|record_id==25590

gen matchpid=pid if pid=="20180575"
fillmissing matchpid
replace pid=matchpid if record_id==25125
gen matchcr5id=cr5id if pid=="20180575"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25125
drop matchpid matchcr5id
replace matched=1 if pid=="20180575"|record_id==25125

gen matchpid=pid if pid=="20171025"
fillmissing matchpid
replace pid=matchpid if record_id==24600
gen matchcr5id=cr5id if pid=="20171025"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24600
drop matchpid matchcr5id
replace matched=1 if pid=="20171025"|record_id==24600

gen matchpid=pid if pid=="20160902"
fillmissing matchpid
replace pid=matchpid if record_id==20323
gen matchcr5id=cr5id if pid=="20160902"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20323
drop matchpid matchcr5id
replace matched=1 if pid=="20160902"|record_id==20323

gen matchpid=pid if pid=="20170899"
fillmissing matchpid
replace pid=matchpid if record_id==24673
gen matchcr5id=cr5id if pid=="20170899"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24673
drop matchpid matchcr5id
replace matched=1 if pid=="20170899"|record_id==24673

gen matchpid=pid if pid=="20180298"
fillmissing matchpid
replace pid=matchpid if record_id==34878
gen matchcr5id=cr5id if pid=="20180298"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==34878
drop matchpid matchcr5id
replace matched=1 if pid=="20180298"|record_id==34878

gen matchpid=pid if pid=="20170923"
fillmissing matchpid
replace pid=matchpid if record_id==23639
gen matchcr5id=cr5id if pid=="20170923"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23639
drop matchpid matchcr5id
replace matched=1 if pid=="20170923"|record_id==23639

gen matchpid=pid if pid=="20161102"
fillmissing matchpid
replace pid=matchpid if record_id==21297
gen matchcr5id=cr5id if pid=="20161102"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21297
drop matchpid matchcr5id
replace matched=1 if pid=="20161102"|record_id==21297

gen matchpid=pid if pid=="20161214"
fillmissing matchpid
replace pid=matchpid if record_id==19941
gen matchcr5id=cr5id if pid=="20161214"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==19941
drop matchpid matchcr5id
replace matched=1 if pid=="20161214"|record_id==19941

gen matchpid=pid if pid=="20150132"
fillmissing matchpid
replace pid=matchpid if record_id==35771
gen matchcr5id=cr5id if pid=="20150132"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==35771
drop matchpid matchcr5id
replace matched=1 if pid=="20150132"|record_id==35771

gen matchpid=pid if pid=="20160140"
fillmissing matchpid
replace pid=matchpid if record_id==21166
gen matchcr5id=cr5id if pid=="20160140"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21166
drop matchpid matchcr5id
replace matched=1 if pid=="20160140"|record_id==21166

gen matchpid=pid if pid=="20170996"
fillmissing matchpid
replace pid=matchpid if record_id==24259
gen matchcr5id=cr5id if pid=="20170996"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24259
drop matchpid matchcr5id
replace matched=1 if pid=="20170996"|record_id==24259

gen matchpid=pid if pid=="20172119"
fillmissing matchpid
replace pid=matchpid if record_id==32399
gen matchcr5id=cr5id if pid=="20172119"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==32399
drop matchpid matchcr5id
replace matched=1 if pid=="20172119"|record_id==32399

gen matchpid=pid if pid=="20161177"
fillmissing matchpid
replace pid=matchpid if record_id==21340
gen matchcr5id=cr5id if pid=="20161177"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21340
drop matchpid matchcr5id
replace matched=1 if pid=="20161177"|record_id==21340

gen matchpid=pid if pid=="20161227"
fillmissing matchpid
replace pid=matchpid if record_id==20763
gen matchcr5id=cr5id if pid=="20161227"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20763
drop matchpid matchcr5id
replace matched=1 if pid=="20161227"|record_id==20763

gen matchpid=pid if pid=="20161167"
fillmissing matchpid
replace pid=matchpid if record_id==21758
gen matchcr5id=cr5id if pid=="20161167"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21758
drop matchpid matchcr5id
replace matched=1 if pid=="20161167"|record_id==21758

gen matchpid=pid if pid=="20180560"
fillmissing matchpid
replace pid=matchpid if record_id==36390
gen matchcr5id=cr5id if pid=="20180560"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==36390
drop matchpid matchcr5id
replace matched=1 if pid=="20180560"|record_id==36390

gen matchpid=pid if pid=="20172159"
fillmissing matchpid
replace pid=matchpid if record_id==22056
gen matchcr5id=cr5id if pid=="20172159"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22056
drop matchpid matchcr5id
replace matched=1 if pid=="20172159"|record_id==22056

gen matchpid=pid if pid=="20161157"
fillmissing matchpid
replace pid=matchpid if record_id==19565
gen matchcr5id=cr5id if pid=="20161157"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==19565
drop matchpid matchcr5id
replace matched=1 if pid=="20161157"|record_id==19565

gen matchpid=pid if pid=="20160890"
fillmissing matchpid
replace pid=matchpid if record_id==20154
gen matchcr5id=cr5id if pid=="20160890"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20154
drop matchpid matchcr5id
replace matched=1 if pid=="20160890"|record_id==20154

gen matchpid=pid if pid=="20161119"
fillmissing matchpid
replace pid=matchpid if record_id==21542
gen matchcr5id=cr5id if pid=="20161119"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21542
drop matchpid matchcr5id
replace matched=1 if pid=="20161119"|record_id==21542

gen matchpid=pid if pid=="20181064"
fillmissing matchpid
replace pid=matchpid if record_id==24568
gen matchcr5id=cr5id if pid=="20181064"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24568
drop matchpid matchcr5id
replace matched=1 if pid=="20181064"|record_id==24568

gen matchpid=pid if pid=="20170973"
fillmissing matchpid
replace pid=matchpid if record_id==22275
gen matchcr5id=cr5id if pid=="20170973"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22275
drop matchpid matchcr5id
replace matched=1 if pid=="20170973"|record_id==22275

gen matchpid=pid if pid=="20170945"
fillmissing matchpid
replace pid=matchpid if record_id==22731
gen matchcr5id=cr5id if pid=="20170945"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22731
drop matchpid matchcr5id
replace matched=1 if pid=="20170945"|record_id==22731

gen matchpid=pid if pid=="20160205"
fillmissing matchpid
replace pid=matchpid if record_id==20193
gen matchcr5id=cr5id if pid=="20160205"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20193
drop matchpid matchcr5id
replace matched=1 if pid=="20160205"|record_id==20193

gen matchpid=pid if pid=="20180714"
fillmissing matchpid
replace pid=matchpid if record_id==25338
gen matchcr5id=cr5id if pid=="20180714"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25338
drop matchpid matchcr5id
replace matched=1 if pid=="20180714"|record_id==25338

gen matchpid=pid if pid=="20170958"
fillmissing matchpid
replace pid=matchpid if record_id==23903
gen matchcr5id=cr5id if pid=="20170958"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23903
drop matchpid matchcr5id
replace matched=1 if pid=="20170958"|record_id==23903

gen matchpid=pid if pid=="20170792"
fillmissing matchpid
replace pid=matchpid if record_id==23653
gen matchcr5id=cr5id if pid=="20170792"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23653
drop matchpid matchcr5id
replace matched=1 if pid=="20170792"|record_id==23653

gen matchpid=pid if pid=="20170888"
fillmissing matchpid
replace pid=matchpid if record_id==23249
gen matchcr5id=cr5id if pid=="20170888"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23249
drop matchpid matchcr5id
replace matched=1 if pid=="20170888"|record_id==23249

gen matchpid=pid if pid=="20170880"
fillmissing matchpid
replace pid=matchpid if record_id==23731
gen matchcr5id=cr5id if pid=="20170880"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23731
drop matchpid matchcr5id
replace matched=1 if pid=="20170880"|record_id==23731

gen matchpid=pid if pid=="20180904"
fillmissing matchpid
replace pid=matchpid if record_id==26258
gen matchcr5id=cr5id if pid=="20180904"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26258
drop matchpid matchcr5id
replace matched=1 if pid=="20180904"|record_id==26258

gen matchpid=pid if pid=="20180776"
fillmissing matchpid
replace pid=matchpid if record_id==26420
gen matchcr5id=cr5id if pid=="20180776"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26420
drop matchpid matchcr5id
replace matched=1 if pid=="20180776"|record_id==26420

gen matchpid=pid if pid=="20170928"
fillmissing matchpid
replace pid=matchpid if record_id==22737
gen matchcr5id=cr5id if pid=="20170928"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22737
drop matchpid matchcr5id
replace matched=1 if pid=="20170928"|record_id==22737

gen matchpid=pid if pid=="20180764"
fillmissing matchpid
replace pid=matchpid if record_id==25977
gen matchcr5id=cr5id if pid=="20180764"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25977
drop matchpid matchcr5id
replace matched=1 if pid=="20180764"|record_id==25977

gen matchpid=pid if pid=="20160772"
fillmissing matchpid
replace pid=matchpid if record_id==20931
gen matchcr5id=cr5id if pid=="20160772"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20931
drop matchpid matchcr5id
replace matched=1 if pid=="20160772"|record_id==20931

gen matchpid=pid if pid=="20170653"
fillmissing matchpid
replace pid=matchpid if record_id==21975
gen matchcr5id=cr5id if pid=="20170653"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21975
drop matchpid matchcr5id
replace matched=1 if pid=="20170653"|record_id==21975

gen matchpid=pid if pid=="20161224"
fillmissing matchpid
replace pid=matchpid if record_id==20916
gen matchcr5id=cr5id if pid=="20161224"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20916
drop matchpid matchcr5id
replace matched=1 if pid=="20161224"|record_id==20916

gen matchpid=pid if pid=="20160608"
fillmissing matchpid
replace pid=matchpid if record_id==22230
gen matchcr5id=cr5id if pid=="20160608"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22230
drop matchpid matchcr5id
replace matched=1 if pid=="20160608"|record_id==22230

gen matchpid=pid if pid=="20170745"
fillmissing matchpid
replace pid=matchpid if record_id==23225
gen matchcr5id=cr5id if pid=="20170745"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23225
drop matchpid matchcr5id
replace matched=1 if pid=="20170745"|record_id==23225

gen matchpid=pid if pid=="20171023"
fillmissing matchpid
replace pid=matchpid if record_id==23537
gen matchcr5id=cr5id if pid=="20171023"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23537
drop matchpid matchcr5id
replace matched=1 if pid=="20171023"|record_id==23537

gen matchpid=pid if pid=="20170725"
fillmissing matchpid
replace pid=matchpid if record_id==22743
gen matchcr5id=cr5id if pid=="20170725"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22743
drop matchpid matchcr5id
replace matched=1 if pid=="20170725"|record_id==22743

gen matchpid=pid if pid=="20170915"
fillmissing matchpid
replace pid=matchpid if record_id==22346
gen matchcr5id=cr5id if pid=="20170915"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22346
drop matchpid matchcr5id
replace matched=1 if pid=="20170915"|record_id==22346

gen matchpid=pid if pid=="20161216"
fillmissing matchpid
replace pid=matchpid if record_id==20666
gen matchcr5id=cr5id if pid=="20161216"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20666
drop matchpid matchcr5id
replace matched=1 if pid=="20161216"|record_id==20666

gen matchpid=pid if pid=="20160845"
fillmissing matchpid
replace pid=matchpid if record_id==19372
gen matchcr5id=cr5id if pid=="20160845"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==19372
drop matchpid matchcr5id
replace matched=1 if pid=="20160845"|record_id==19372

gen matchpid=pid if pid=="20180914"
fillmissing matchpid
replace pid=matchpid if record_id==26864
gen matchcr5id=cr5id if pid=="20180914"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26864
drop matchpid matchcr5id
replace matched=1 if pid=="20180914"|record_id==26864

gen matchpid=pid if pid=="20161131"
fillmissing matchpid
replace pid=matchpid if record_id==20485
gen matchcr5id=cr5id if pid=="20161131"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20485
drop matchpid matchcr5id
replace matched=1 if pid=="20161131"|record_id==20485

gen matchpid=pid if pid=="20170385"
fillmissing matchpid
replace pid=matchpid if record_id==24057
gen matchcr5id=cr5id if pid=="20170385"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24057
drop matchpid matchcr5id
replace matched=1 if pid=="20170385"|record_id==24057

gen matchpid=pid if pid=="20160846"
fillmissing matchpid
replace pid=matchpid if record_id==19434
gen matchcr5id=cr5id if pid=="20160846"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==19434
drop matchpid matchcr5id
replace matched=1 if pid=="20160846"|record_id==19434

gen matchpid=pid if pid=="20170806"
fillmissing matchpid
replace pid=matchpid if record_id==23896
gen matchcr5id=cr5id if pid=="20170806"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23896
drop matchpid matchcr5id
replace matched=1 if pid=="20170806"|record_id==23896

gen matchpid=pid if pid=="20180936"
fillmissing matchpid
replace pid=matchpid if record_id==26808
gen matchcr5id=cr5id if pid=="20180936"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26808
drop matchpid matchcr5id
replace matched=1 if pid=="20180936"|record_id==26808

gen matchpid=pid if pid=="20161091"
fillmissing matchpid
replace pid=matchpid if record_id==19807
gen matchcr5id=cr5id if pid=="20161091"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==19807
drop matchpid matchcr5id
replace matched=1 if pid=="20161091"|record_id==19807

gen matchpid=pid if pid=="20161218"
fillmissing matchpid
replace pid=matchpid if record_id==20838
gen matchcr5id=cr5id if pid=="20161218"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20838
drop matchpid matchcr5id
replace matched=1 if pid=="20161218"|record_id==20838

gen matchpid=pid if pid=="20160541"
fillmissing matchpid
replace pid=matchpid if record_id==24603
gen matchcr5id=cr5id if pid=="20160541"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24603
drop matchpid matchcr5id
replace matched=1 if pid=="20160541"|record_id==24603

gen matchpid=pid if pid=="20161140"
fillmissing matchpid
replace pid=matchpid if record_id==20191
gen matchcr5id=cr5id if pid=="20161140"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20191
drop matchpid matchcr5id
replace matched=1 if pid=="20161140"|record_id==20191

gen matchpid=pid if pid=="20170968"
fillmissing matchpid
replace pid=matchpid if record_id==23449
gen matchcr5id=cr5id if pid=="20170968"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23449
drop matchpid matchcr5id
replace matched=1 if pid=="20170968"|record_id==23449

gen matchpid=pid if pid=="20080661"
fillmissing matchpid
replace pid=matchpid if record_id==21371
gen matchcr5id=cr5id if pid=="20080661"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21371
drop matchpid matchcr5id
replace matched=1 if pid=="20080661"|record_id==21371

gen matchpid=pid if pid=="20180734"
fillmissing matchpid
replace pid=matchpid if record_id==24690
gen matchcr5id=cr5id if pid=="20180734"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24690
drop matchpid matchcr5id
replace matched=1 if pid=="20180734"|record_id==24690

gen matchpid=pid if pid=="20160907"
fillmissing matchpid
replace pid=matchpid if record_id==20378
gen matchcr5id=cr5id if pid=="20160907"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20378
drop matchpid matchcr5id
replace matched=1 if pid=="20160907"|record_id==20378

gen matchpid=pid if pid=="20170931"
fillmissing matchpid
replace pid=matchpid if record_id==22305
gen matchcr5id=cr5id if pid=="20170931"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22305
drop matchpid matchcr5id
replace matched=1 if pid=="20170931"|record_id==22305

gen matchpid=pid if pid=="20180674"
fillmissing matchpid
replace pid=matchpid if record_id==26185
gen matchcr5id=cr5id if pid=="20180674"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26185
drop matchpid matchcr5id
replace matched=1 if pid=="20180674"|record_id==26185

gen matchpid=pid if pid=="20161230"
fillmissing matchpid
replace pid=matchpid if record_id==21439
gen matchcr5id=cr5id if pid=="20161230"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21439
drop matchpid matchcr5id
replace matched=1 if pid=="20161230"|record_id==21439

gen matchpid=pid if pid=="20171015"
fillmissing matchpid
replace pid=matchpid if record_id==23341
gen matchcr5id=cr5id if pid=="20171015"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23341
drop matchpid matchcr5id
replace matched=1 if pid=="20171015"|record_id==23341

gen matchpid=pid if pid=="20150035"
fillmissing matchpid
replace pid=matchpid if record_id==35496
gen matchcr5id=cr5id if pid=="20150035"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==35496
drop matchpid matchcr5id
replace matched=1 if pid=="20150035"|record_id==35496

gen matchpid=pid if pid=="20161128"
fillmissing matchpid
replace pid=matchpid if record_id==19751
gen matchcr5id=cr5id if pid=="20161128"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==19751
drop matchpid matchcr5id
replace matched=1 if pid=="20161128"|record_id==19751

gen matchpid=pid if pid=="20161152"
fillmissing matchpid
replace pid=matchpid if record_id==20641
gen matchcr5id=cr5id if pid=="20161152"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20641
drop matchpid matchcr5id
replace matched=1 if pid=="20161152"|record_id==20641

gen matchpid=pid if pid=="20180681"
fillmissing matchpid
replace pid=matchpid if record_id==26388
gen matchcr5id=cr5id if pid=="20180681"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26388
drop matchpid matchcr5id
replace matched=1 if pid=="20180681"|record_id==26388

gen matchpid=pid if pid=="20161159"
fillmissing matchpid
replace pid=matchpid if record_id==20634
gen matchcr5id=cr5id if pid=="20161159"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20634
drop matchpid matchcr5id
replace matched=1 if pid=="20161159"|record_id==20634

gen matchpid=pid if pid=="20160413"
fillmissing matchpid
replace pid=matchpid if record_id==22145
gen matchcr5id=cr5id if pid=="20160413"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22145
drop matchpid matchcr5id
replace matched=1 if pid=="20160413"|record_id==22145

gen matchpid=pid if pid=="20150522"
fillmissing matchpid
replace pid=matchpid if record_id==19971
gen matchcr5id=cr5id if pid=="20150522"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==19971
drop matchpid matchcr5id
replace matched=1 if pid=="20150522"|record_id==19971

gen matchpid=pid if pid=="20180786"
fillmissing matchpid
replace pid=matchpid if record_id==24707
gen matchcr5id=cr5id if pid=="20180786"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24707
drop matchpid matchcr5id
replace matched=1 if pid=="20180786"|record_id==24707

gen matchpid=pid if pid=="20180760"
fillmissing matchpid
replace pid=matchpid if record_id==24811
gen matchcr5id=cr5id if pid=="20180760"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24811
drop matchpid matchcr5id
replace matched=1 if pid=="20180760"|record_id==24811

gen matchpid=pid if pid=="20160617"
fillmissing matchpid
replace pid=matchpid if record_id==33726
gen matchcr5id=cr5id if pid=="20160617"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==33726
drop matchpid matchcr5id
replace matched=1 if pid=="20160617"|record_id==33726

gen matchpid=pid if pid=="20180682"
fillmissing matchpid
replace pid=matchpid if record_id==25239
gen matchcr5id=cr5id if pid=="20180682"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25239
drop matchpid matchcr5id
replace matched=1 if pid=="20180682"|record_id==25239

gen matchpid=pid if pid=="20180752"
fillmissing matchpid
replace pid=matchpid if record_id==25000
gen matchcr5id=cr5id if pid=="20180752"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25000
drop matchpid matchcr5id
replace matched=1 if pid=="20180752"|record_id==25000

gen matchpid=pid if pid=="20161137"
fillmissing matchpid
replace pid=matchpid if record_id==21616
gen matchcr5id=cr5id if pid=="20161137"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21616
drop matchpid matchcr5id
replace matched=1 if pid=="20161137"|record_id==21616

gen matchpid=pid if pid=="20170693"
fillmissing matchpid
replace pid=matchpid if record_id==22377
gen matchcr5id=cr5id if pid=="20170693"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22377
drop matchpid matchcr5id
replace matched=1 if pid=="20170693"|record_id==22377

gen matchpid=pid if pid=="20170794"
fillmissing matchpid
replace pid=matchpid if record_id==23725
gen matchcr5id=cr5id if pid=="20170794"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23725
drop matchpid matchcr5id
replace matched=1 if pid=="20170794"|record_id==23725

gen matchpid=pid if pid=="20180566"
fillmissing matchpid
replace pid=matchpid if record_id==25034
gen matchcr5id=cr5id if pid=="20180566"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25034
drop matchpid matchcr5id
replace matched=1 if pid=="20180566"|record_id==25034

gen matchpid=pid if pid=="20170650"
fillmissing matchpid
replace pid=matchpid if record_id==21954
gen matchcr5id=cr5id if pid=="20170650"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21954
drop matchpid matchcr5id
replace matched=1 if pid=="20170650"|record_id==21954

gen matchpid=pid if pid=="20170760"
fillmissing matchpid
replace pid=matchpid if record_id==23220
gen matchcr5id=cr5id if pid=="20170760"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23220
drop matchpid matchcr5id
replace matched=1 if pid=="20170760"|record_id==23220

gen matchpid=pid if pid=="20170570"
fillmissing matchpid
replace pid=matchpid if record_id==24161
gen matchcr5id=cr5id if pid=="20170570"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24161
drop matchpid matchcr5id
replace matched=1 if pid=="20170570"|record_id==24161

gen matchpid=pid if pid=="20170927"
fillmissing matchpid
replace pid=matchpid if record_id==22817
gen matchcr5id=cr5id if pid=="20170927"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22817
drop matchpid matchcr5id
replace matched=1 if pid=="20170927"|record_id==22817

gen matchpid=pid if pid=="20172089"
fillmissing matchpid
replace pid=matchpid if record_id==23010
gen matchcr5id=cr5id if pid=="20172089"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23010
drop matchpid matchcr5id
replace matched=1 if pid=="20172089"|record_id==23010

gen matchpid=pid if pid=="20080215"
fillmissing matchpid
replace pid=matchpid if record_id==29496
gen matchcr5id=cr5id if pid=="20080215"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==29496
drop matchpid matchcr5id
replace matched=1 if pid=="20080215"|record_id==29496

gen matchpid=pid if pid=="20160892"
fillmissing matchpid
replace pid=matchpid if record_id==20229
gen matchcr5id=cr5id if pid=="20160892"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20229
drop matchpid matchcr5id
replace matched=1 if pid=="20160892"|record_id==20229

gen matchpid=pid if pid=="20080462"
fillmissing matchpid
replace pid=matchpid if record_id==29771
gen matchcr5id=cr5id if pid=="20080462"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==29771
drop matchpid matchcr5id
replace matched=1 if pid=="20080462"|record_id==29771

gen matchpid=pid if pid=="20161237"
fillmissing matchpid
replace pid=matchpid if record_id==20197
gen matchcr5id=cr5id if pid=="20161237"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20197
drop matchpid matchcr5id
replace matched=1 if pid=="20161237"|record_id==20197

gen matchpid=pid if pid=="20170965"
fillmissing matchpid
replace pid=matchpid if record_id==23629
gen matchcr5id=cr5id if pid=="20170965"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23629
drop matchpid matchcr5id
replace matched=1 if pid=="20170965"|record_id==23629

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
gen matchcr5id=cr5id if pid==""
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==
drop matchpid matchcr5id
replace matched=1 if pid==""|record_id==

gen matchpid=pid if pid=="20171016"
fillmissing matchpid
replace pid=matchpid if record_id==22762
gen matchcr5id=cr5id if pid=="20171016"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22762
drop matchpid matchcr5id
replace matched=1 if pid=="20171016"|record_id==22762

gen matchpid=pid if pid=="20180770"
fillmissing matchpid
replace pid=matchpid if record_id==26789
gen matchcr5id=cr5id if pid=="20180770"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26789
drop matchpid matchcr5id
replace matched=1 if pid=="20180770"|record_id==26789

gen matchpid=pid if pid=="20162064"
fillmissing matchpid
replace pid=matchpid if record_id==21635
gen matchcr5id=cr5id if pid=="20162064"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21635
drop matchpid matchcr5id
replace matched=1 if pid=="20162064"|record_id==21635

gen matchpid=pid if pid=="20161109"
fillmissing matchpid
replace pid=matchpid if record_id==20618
gen matchcr5id=cr5id if pid=="20161109"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20618
drop matchpid matchcr5id
replace matched=1 if pid=="20161109"|record_id==20618

gen matchpid=pid if pid=="20161212"
fillmissing matchpid
replace pid=matchpid if record_id==20661
gen matchcr5id=cr5id if pid=="20161212"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20661
drop matchpid matchcr5id
replace matched=1 if pid=="20161212"|record_id==20661

gen matchpid=pid if pid=="20160812"
fillmissing matchpid
replace pid=matchpid if record_id==21285
gen matchcr5id=cr5id if pid=="20160812"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21285
drop matchpid matchcr5id
replace matched=1 if pid=="20160812"|record_id==21285

gen matchpid=pid if pid=="20161185"
fillmissing matchpid
replace pid=matchpid if record_id==20925
gen matchcr5id=cr5id if pid=="20161185"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20925
drop matchpid matchcr5id
replace matched=1 if pid=="20161185"|record_id==20925

gen matchpid=pid if pid=="20170719"
fillmissing matchpid
replace pid=matchpid if record_id==22656
gen matchcr5id=cr5id if pid=="20170719"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22656
drop matchpid matchcr5id
replace matched=1 if pid=="20170719"|record_id==22656

gen matchpid=pid if pid=="20180755"
fillmissing matchpid
replace pid=matchpid if record_id==26071
gen matchcr5id=cr5id if pid=="20180755"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26071
drop matchpid matchcr5id
replace matched=1 if pid=="20180755"|record_id==26071

gen matchpid=pid if pid=="20170733"
fillmissing matchpid
replace pid=matchpid if record_id==22912
gen matchcr5id=cr5id if pid=="20170733"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22912
drop matchpid matchcr5id
replace matched=1 if pid=="20170733"|record_id==22912

gen matchpid=pid if pid=="20161142"
fillmissing matchpid
replace pid=matchpid if record_id==19702
gen matchcr5id=cr5id if pid=="20161142"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==19702
drop matchpid matchcr5id
replace matched=1 if pid=="20161142"|record_id==19702

gen matchpid=pid if pid=="20180774"
fillmissing matchpid
replace pid=matchpid if record_id==25676
gen matchcr5id=cr5id if pid=="20180774"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25676
drop matchpid matchcr5id
replace matched=1 if pid=="20180774"|record_id==25676

gen matchpid=pid if pid=="20161208"
fillmissing matchpid
replace pid=matchpid if record_id==21777
gen matchcr5id=cr5id if pid=="20161208"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21777
drop matchpid matchcr5id
replace matched=1 if pid=="20161208"|record_id==21777

gen matchpid=pid if pid=="20161174"
fillmissing matchpid
replace pid=matchpid if record_id==20480
gen matchcr5id=cr5id if pid=="20161174"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20480
drop matchpid matchcr5id
replace matched=1 if pid=="20161174"|record_id==20480

gen matchpid=pid if pid=="20181089"
fillmissing matchpid
replace pid=matchpid if record_id==24753
gen matchcr5id=cr5id if pid=="20181089"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24753
drop matchpid matchcr5id
replace matched=1 if pid=="20181089"|record_id==24753

gen matchpid=pid if pid=="20170906"
fillmissing matchpid
replace pid=matchpid if record_id==23483
gen matchcr5id=cr5id if pid=="20170906"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23483
drop matchpid matchcr5id
replace matched=1 if pid=="20170906"|record_id==23483

gen matchpid=pid if pid=="20171021"
fillmissing matchpid
replace pid=matchpid if record_id==24058
gen matchcr5id=cr5id if pid=="20171021"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24058
drop matchpid matchcr5id
replace matched=1 if pid=="20171021"|record_id==24058

gen matchpid=pid if pid=="20181056"
fillmissing matchpid
replace pid=matchpid if record_id==24530
gen matchcr5id=cr5id if pid=="20181056"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24530
drop matchpid matchcr5id
replace matched=1 if pid=="20181056"|record_id==24530

gen matchpid=pid if pid=="20161161"
fillmissing matchpid
replace pid=matchpid if record_id==20980
gen matchcr5id=cr5id if pid=="20161161"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20980
drop matchpid matchcr5id
replace matched=1 if pid=="20161161"|record_id==20980

gen matchpid=pid if pid=="20161089"
fillmissing matchpid
replace pid=matchpid if record_id==19750
gen matchcr5id=cr5id if pid=="20161089"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==19750
drop matchpid matchcr5id
replace matched=1 if pid=="20161089"|record_id==19750

gen matchpid=pid if pid=="20161165"
fillmissing matchpid
replace pid=matchpid if record_id==19792
gen matchcr5id=cr5id if pid=="20161165"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==19792
drop matchpid matchcr5id
replace matched=1 if pid=="20161165"|record_id==19792

gen matchpid=pid if pid=="20180838"
fillmissing matchpid
replace pid=matchpid if record_id==26567
gen matchcr5id=cr5id if pid=="20180838"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26567
drop matchpid matchcr5id
replace matched=1 if pid=="20180838"|record_id==26567

gen matchpid=pid if pid=="20160839"
fillmissing matchpid
replace pid=matchpid if record_id==19347
gen matchcr5id=cr5id if pid=="20160839"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==19347
drop matchpid matchcr5id
replace matched=1 if pid=="20160839"|record_id==19347

gen matchpid=pid if pid=="20170908"
fillmissing matchpid
replace pid=matchpid if record_id==24664
gen matchcr5id=cr5id if pid=="20170908"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24664
drop matchpid matchcr5id
replace matched=1 if pid=="20170908"|record_id==24664

gen matchpid=pid if pid=="20160759"
fillmissing matchpid
replace pid=matchpid if record_id==22073
gen matchcr5id=cr5id if pid=="20160759"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22073
drop matchpid matchcr5id
replace matched=1 if pid=="20160759"|record_id==22073

gen matchpid=pid if pid=="20160679"
fillmissing matchpid
replace pid=matchpid if record_id==21084
gen matchcr5id=cr5id if pid=="20160679"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21084
drop matchpid matchcr5id
replace matched=1 if pid=="20160679"|record_id==21084

gen matchpid=pid if pid=="20170675"
fillmissing matchpid
replace pid=matchpid if record_id==22199
gen matchcr5id=cr5id if pid=="20170675"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22199
drop matchpid matchcr5id
replace matched=1 if pid=="20170675"|record_id==22199

gen matchpid=pid if pid=="20180827"
fillmissing matchpid
replace pid=matchpid if record_id==26498
gen matchcr5id=cr5id if pid=="20180827"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26498
drop matchpid matchcr5id
replace matched=1 if pid=="20180827"|record_id==26498

gen matchpid=pid if pid=="20155130"
fillmissing matchpid
replace pid=matchpid if record_id==17157
gen matchcr5id=cr5id if pid=="20155130"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==17157
drop matchpid matchcr5id
replace matched=1 if pid=="20155130"|record_id==17157

gen matchpid=pid if pid=="20170752"
fillmissing matchpid
replace pid=matchpid if record_id==23085
gen matchcr5id=cr5id if pid=="20170752"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23085
drop matchpid matchcr5id
replace matched=1 if pid=="20170752"|record_id==23085

gen matchpid=pid if pid=="20170568"
fillmissing matchpid
replace pid=matchpid if record_id==26030
gen matchcr5id=cr5id if pid=="20170568"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26030
drop matchpid matchcr5id
replace matched=1 if pid=="20170568"|record_id==26030

gen matchpid=pid if pid=="20161097"
fillmissing matchpid
replace pid=matchpid if record_id==19952
gen matchcr5id=cr5id if pid=="20161097"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==19952
drop matchpid matchcr5id
replace matched=1 if pid=="20161097"|record_id==19952

gen matchpid=pid if pid=="20180672"
fillmissing matchpid
replace pid=matchpid if record_id==26234
gen matchcr5id=cr5id if pid=="20180672"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26234
drop matchpid matchcr5id
replace matched=1 if pid=="20180672"|record_id==26234

gen matchpid=pid if pid=="20170936"
fillmissing matchpid
replace pid=matchpid if record_id==23791
gen matchcr5id=cr5id if pid=="20170936"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23791
drop matchpid matchcr5id
replace matched=1 if pid=="20170936"|record_id==23791

gen matchpid=pid if pid=="20160376"
fillmissing matchpid
replace pid=matchpid if record_id==21747
gen matchcr5id=cr5id if pid=="20160376"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21747
drop matchpid matchcr5id
replace matched=1 if pid=="20160376"|record_id==21747

gen matchpid=pid if pid=="20170644"
fillmissing matchpid
replace pid=matchpid if record_id==21931
gen matchcr5id=cr5id if pid=="20170644"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21931
drop matchpid matchcr5id
replace matched=1 if pid=="20170644"|record_id==21931

gen matchpid=pid if pid=="20180685"
fillmissing matchpid
replace pid=matchpid if record_id==25709
gen matchcr5id=cr5id if pid=="20180685"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25709
drop matchpid matchcr5id
replace matched=1 if pid=="20180685"|record_id==25709

gen matchpid=pid if pid=="20170943"
fillmissing matchpid
replace pid=matchpid if record_id==23120
gen matchcr5id=cr5id if pid=="20170943"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23120
drop matchpid matchcr5id
replace matched=1 if pid=="20170943"|record_id==23120

gen matchpid=pid if pid=="20161108"
fillmissing matchpid
replace pid=matchpid if record_id==20185
gen matchcr5id=cr5id if pid=="20161108"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20185
drop matchpid matchcr5id
replace matched=1 if pid=="20161108"|record_id==20185

gen matchpid=pid if pid=="20170898"
fillmissing matchpid
replace pid=matchpid if record_id==22329
gen matchcr5id=cr5id if pid=="20170898"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22329
drop matchpid matchcr5id
replace matched=1 if pid=="20170898"|record_id==22329

gen matchpid=pid if pid=="20080728"
fillmissing matchpid
replace pid=matchpid if record_id==24191
gen matchcr5id=cr5id if pid=="20080728"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24191
drop matchpid matchcr5id
replace matched=1 if pid=="20080728"|record_id==24191

gen matchpid=pid if pid=="20180580"
fillmissing matchpid
replace pid=matchpid if record_id==25182
gen matchcr5id=cr5id if pid=="20180580"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25182
drop matchpid matchcr5id
replace matched=1 if pid=="20180580"|record_id==25182

gen matchpid=pid if pid=="20160339"
fillmissing matchpid
replace pid=matchpid if record_id==25566
gen matchcr5id=cr5id if pid=="20160339"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25566
drop matchpid matchcr5id
replace matched=1 if pid=="20160339"|record_id==25566

gen matchpid=pid if pid=="20171003"
fillmissing matchpid
replace pid=matchpid if record_id==23517
gen matchcr5id=cr5id if pid=="20171003"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23517
drop matchpid matchcr5id
replace matched=1 if pid=="20171003"|record_id==23517

gen matchpid=pid if pid=="20172055"
fillmissing matchpid
replace pid=matchpid if record_id==33533
gen matchcr5id=cr5id if pid=="20172055"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==33533
drop matchpid matchcr5id
replace matched=1 if pid=="20172055"|record_id==33533

gen matchpid=pid if pid=="20170694"
fillmissing matchpid
replace pid=matchpid if record_id==22380
gen matchcr5id=cr5id if pid=="20170694"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22380
drop matchpid matchcr5id
replace matched=1 if pid=="20170694"|record_id==22380

gen matchpid=pid if pid=="20172132"
fillmissing matchpid
replace pid=matchpid if record_id==22985
gen matchcr5id=cr5id if pid=="20172132"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22985
drop matchpid matchcr5id
replace matched=1 if pid=="20172132"|record_id==22985

gen matchpid=pid if pid=="20170877"
fillmissing matchpid
replace pid=matchpid if record_id==22020
gen matchcr5id=cr5id if pid=="20170877"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22020
drop matchpid matchcr5id
replace matched=1 if pid=="20170877"|record_id==22020

gen matchpid=pid if pid=="20151323"
fillmissing matchpid
replace pid=matchpid if record_id==19831
gen matchcr5id=cr5id if pid=="20151323"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==19831
drop matchpid matchcr5id
replace matched=1 if pid=="20151323"|record_id==19831

gen matchpid=pid if pid=="20181131"
fillmissing matchpid
replace pid=matchpid if record_id==30008
gen matchcr5id=cr5id if pid=="20181131"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==30008
drop matchpid matchcr5id
replace matched=1 if pid=="20181131"|record_id==30008

gen matchpid=pid if pid=="20170388"
fillmissing matchpid
replace pid=matchpid if record_id==23991
gen matchcr5id=cr5id if pid=="20170388"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23991
drop matchpid matchcr5id
replace matched=1 if pid=="20170388"|record_id==23991

gen matchpid=pid if pid=="20160094"
fillmissing matchpid
replace pid=matchpid if record_id==32269
gen matchcr5id=cr5id if pid=="20160094"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==32269
drop matchpid matchcr5id
replace matched=1 if pid=="20160094"|record_id==32269

gen matchpid=pid if pid=="20180686"
fillmissing matchpid
replace pid=matchpid if record_id==25980
gen matchcr5id=cr5id if pid=="20180686"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25980
drop matchpid matchcr5id
replace matched=1 if pid=="20180686"|record_id==25980

gen matchpid=pid if pid=="20170993"
fillmissing matchpid
replace pid=matchpid if record_id==21976
gen matchcr5id=cr5id if pid=="20170993"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21976
drop matchpid matchcr5id
replace matched=1 if pid=="20170993"|record_id==21976

gen matchpid=pid if pid=="20171018"
fillmissing matchpid
replace pid=matchpid if record_id==22721
gen matchcr5id=cr5id if pid=="20171018"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22721
drop matchpid matchcr5id
replace matched=1 if pid=="20171018"|record_id==22721

gen matchpid=pid if pid=="20170998"
fillmissing matchpid
replace pid=matchpid if record_id==22304
gen matchcr5id=cr5id if pid=="20170998"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22304
drop matchpid matchcr5id
replace matched=1 if pid=="20170998"|record_id==22304

gen matchpid=pid if pid=="20161181"
fillmissing matchpid
replace pid=matchpid if record_id==19446
gen matchcr5id=cr5id if pid=="20161181"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==19446
drop matchpid matchcr5id
replace matched=1 if pid=="20161181"|record_id==19446

gen matchpid=pid if pid=="20161198"
fillmissing matchpid
replace pid=matchpid if record_id==20782
gen matchcr5id=cr5id if pid=="20161198"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20782
drop matchpid matchcr5id
replace matched=1 if pid=="20161198"|record_id==20782

gen matchpid=pid if pid=="20170949"
fillmissing matchpid
replace pid=matchpid if record_id==24106
gen matchcr5id=cr5id if pid=="20170949"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24106
drop matchpid matchcr5id
replace matched=1 if pid=="20170949"|record_id==24106

gen matchpid=pid if pid=="20180792"
fillmissing matchpid
replace pid=matchpid if record_id==24506
gen matchcr5id=cr5id if pid=="20180792"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24506
drop matchpid matchcr5id
replace matched=1 if pid=="20180792"|record_id==24506

gen matchpid=pid if pid=="20160910"
fillmissing matchpid
replace pid=matchpid if record_id==20400
gen matchcr5id=cr5id if pid=="20160910"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20400
drop matchpid matchcr5id
replace matched=1 if pid=="20160910"|record_id==20400

gen matchpid=pid if pid=="20180716"
fillmissing matchpid
replace pid=matchpid if record_id==25830
gen matchcr5id=cr5id if pid=="20180716"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25830
drop matchpid matchcr5id
replace matched=1 if pid=="20180716"|record_id==25830

gen matchpid=pid if pid=="20180653"
fillmissing matchpid
replace pid=matchpid if record_id==24437
gen matchcr5id=cr5id if pid=="20180653"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24437
drop matchpid matchcr5id
replace matched=1 if pid=="20180653"|record_id==24437

gen matchpid=pid if pid=="20170896"
fillmissing matchpid
replace pid=matchpid if record_id==22128
gen matchcr5id=cr5id if pid=="20170896"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22128
drop matchpid matchcr5id
replace matched=1 if pid=="20170896"|record_id==22128

gen matchpid=pid if pid=="20161136"
fillmissing matchpid
replace pid=matchpid if record_id==20636
gen matchcr5id=cr5id if pid=="20161136"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20636
drop matchpid matchcr5id
replace matched=1 if pid=="20161136"|record_id==20636

gen matchpid=pid if pid=="20182218"
fillmissing matchpid
replace pid=matchpid if record_id==26334
gen matchcr5id=cr5id if pid=="20182218"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26334
drop matchpid matchcr5id
replace matched=1 if pid=="20182218"|record_id==26334

gen matchpid=pid if pid=="20171027"
fillmissing matchpid
replace pid=matchpid if record_id==23262
gen matchcr5id=cr5id if pid=="20171027"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23262
drop matchpid matchcr5id
replace matched=1 if pid=="20171027"|record_id==23262

gen matchpid=pid if pid=="20180387"
fillmissing matchpid
replace pid=matchpid if record_id==25516
gen matchcr5id=cr5id if pid=="20180387"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25516
drop matchpid matchcr5id
replace matched=1 if pid=="20180387"|record_id==25516

gen matchpid=pid if pid=="20170894"
fillmissing matchpid
replace pid=matchpid if record_id==22674
gen matchcr5id=cr5id if pid=="20170894"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22674
drop matchpid matchcr5id
replace matched=1 if pid=="20170894"|record_id==22674

gen matchpid=pid if pid=="20170756"
fillmissing matchpid
replace pid=matchpid if record_id==23125
gen matchcr5id=cr5id if pid=="20170756"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23125
drop matchpid matchcr5id
replace matched=1 if pid=="20170756"|record_id==23125

gen matchpid=pid if pid=="20180675"
fillmissing matchpid
replace pid=matchpid if record_id==24483
gen matchcr5id=cr5id if pid=="20180675"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24483
drop matchpid matchcr5id
replace matched=1 if pid=="20180675"|record_id==24483

gen matchpid=pid if pid=="20162049"
fillmissing matchpid
replace pid=matchpid if record_id==21501
gen matchcr5id=cr5id if pid=="20162049"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21501
drop matchpid matchcr5id
replace matched=1 if pid=="20162049"|record_id==21501

gen matchpid=pid if pid=="20180781"
fillmissing matchpid
replace pid=matchpid if record_id==26356
gen matchcr5id=cr5id if pid=="20180781"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26356
drop matchpid matchcr5id
replace matched=1 if pid=="20180781"|record_id==26356

gen matchpid=pid if pid=="20171024"
fillmissing matchpid
replace pid=matchpid if record_id==22155
gen matchcr5id=cr5id if pid=="20171024"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22155
drop matchpid matchcr5id
replace matched=1 if pid=="20171024"|record_id==22155

gen matchpid=pid if pid=="20170196"
fillmissing matchpid
replace pid=matchpid if record_id==23979
gen matchcr5id=cr5id if pid=="20170196"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23979
drop matchpid matchcr5id
replace matched=1 if pid=="20170196"|record_id==23979

gen matchpid=pid if pid=="20170578"
fillmissing matchpid
replace pid=matchpid if record_id==25785
gen matchcr5id=cr5id if pid=="20170578"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25785
drop matchpid matchcr5id
replace matched=1 if pid=="20170578"|record_id==25785

gen matchpid=pid if pid=="20170997"
fillmissing matchpid
replace pid=matchpid if record_id==21842
gen matchcr5id=cr5id if pid=="20170997"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21842
drop matchpid matchcr5id
replace matched=1 if pid=="20170997"|record_id==21842

gen matchpid=pid if pid=="20170919"
fillmissing matchpid
replace pid=matchpid if record_id==22156
gen matchcr5id=cr5id if pid=="20170919"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22156
drop matchpid matchcr5id
replace matched=1 if pid=="20170919"|record_id==22156

gen matchpid=pid if pid=="20180602"
fillmissing matchpid
replace pid=matchpid if record_id==25598
gen matchcr5id=cr5id if pid=="20180602"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25598
drop matchpid matchcr5id
replace matched=1 if pid=="20180602"|record_id==25598

gen matchpid=pid if pid=="20170358"
fillmissing matchpid
replace pid=matchpid if record_id==37064
gen matchcr5id=cr5id if pid=="20170358"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==37064
drop matchpid matchcr5id
replace matched=1 if pid=="20170358"|record_id==37064

gen matchpid=pid if pid=="20180819"
fillmissing matchpid
replace pid=matchpid if record_id==24228
gen matchcr5id=cr5id if pid=="20180819"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24228
drop matchpid matchcr5id
replace matched=1 if pid=="20180819"|record_id==24228

gen matchpid=pid if pid=="20151036"
fillmissing matchpid
replace pid=matchpid if record_id==18118
gen matchcr5id=cr5id if pid=="20151036"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==18118
drop matchpid matchcr5id
replace matched=1 if pid=="20151036"|record_id==18118

gen matchpid=pid if pid=="20180732"
fillmissing matchpid
replace pid=matchpid if record_id==25730
gen matchcr5id=cr5id if pid=="20180732"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25730
drop matchpid matchcr5id
replace matched=1 if pid=="20180732"|record_id==25730

gen matchpid=pid if pid=="20080046"
fillmissing matchpid
replace pid=matchpid if record_id==34684
gen matchcr5id=cr5id if pid=="20080046"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==34684
drop matchpid matchcr5id
replace matched=1 if pid=="20080046"|record_id==34684

gen matchpid=pid if pid=="20161188"
fillmissing matchpid
replace pid=matchpid if record_id==20472
gen matchcr5id=cr5id if pid=="20161188"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20472
drop matchpid matchcr5id
replace matched=1 if pid=="20161188"|record_id==20472

gen matchpid=pid if pid=="20151334"
fillmissing matchpid
replace pid=matchpid if record_id==19114
gen matchcr5id=cr5id if pid=="20151334"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==19114
drop matchpid matchcr5id
replace matched=1 if pid=="20151334"|record_id==19114

gen matchpid=pid if pid=="20180357"
fillmissing matchpid
replace pid=matchpid if record_id==27163
gen matchcr5id=cr5id if pid=="20180357"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==27163
drop matchpid matchcr5id
replace matched=1 if pid=="20180357"|record_id==27163

gen matchpid=pid if pid=="20180689"
fillmissing matchpid
replace pid=matchpid if record_id==25393
gen matchcr5id=cr5id if pid=="20180689"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25393
drop matchpid matchcr5id
replace matched=1 if pid=="20180689"|record_id==25393

gen matchpid=pid if pid=="20172004"
fillmissing matchpid
replace pid=matchpid if record_id==23763
gen matchcr5id=cr5id if pid=="20172004"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23763
drop matchpid matchcr5id
replace matched=1 if pid=="20172004"|record_id==23763

gen matchpid=pid if pid=="20170236"
fillmissing matchpid
replace pid=matchpid if record_id==24165
gen matchcr5id=cr5id if pid=="20170236"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24165
drop matchpid matchcr5id
replace matched=1 if pid=="20170236"|record_id==24165

gen matchpid=pid if pid=="20160518"
fillmissing matchpid
replace pid=matchpid if record_id==34157
gen matchcr5id=cr5id if pid=="20160518"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==34157
drop matchpid matchcr5id
replace matched=1 if pid=="20160518"|record_id==34157

gen matchpid=pid if pid=="20180788"
fillmissing matchpid
replace pid=matchpid if record_id==26408
gen matchcr5id=cr5id if pid=="20180788"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26408
drop matchpid matchcr5id
replace matched=1 if pid=="20180788"|record_id==26408

gen matchpid=pid if pid=="20170637"
fillmissing matchpid
replace pid=matchpid if record_id==21848
gen matchcr5id=cr5id if pid=="20170637"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21848
drop matchpid matchcr5id
replace matched=1 if pid=="20170637"|record_id==21848

gen matchpid=pid if pid=="20160134"
fillmissing matchpid
replace pid=matchpid if record_id==20988
gen matchcr5id=cr5id if pid=="20160134"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20988
drop matchpid matchcr5id
replace matched=1 if pid=="20160134"|record_id==20988

gen matchpid=pid if pid=="20171030"
fillmissing matchpid
replace pid=matchpid if record_id==21941
gen matchcr5id=cr5id if pid=="20171030"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21941
drop matchpid matchcr5id
replace matched=1 if pid=="20171030"|record_id==21941

gen matchpid=pid if pid=="20180766"
fillmissing matchpid
replace pid=matchpid if record_id==26811
gen matchcr5id=cr5id if pid=="20180766"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26811
drop matchpid matchcr5id
replace matched=1 if pid=="20180766"|record_id==26811

gen matchpid=pid if pid=="20180727"
fillmissing matchpid
replace pid=matchpid if record_id==26747
gen matchcr5id=cr5id if pid=="20180727"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26747
drop matchpid matchcr5id
replace matched=1 if pid=="20180727"|record_id==26747

gen matchpid=pid if pid=="20170873"
fillmissing matchpid
replace pid=matchpid if record_id==21856
gen matchcr5id=cr5id if pid=="20170873"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21856
drop matchpid matchcr5id
replace matched=1 if pid=="20170873"|record_id==21856

gen matchpid=pid if pid=="20170933"
fillmissing matchpid
replace pid=matchpid if record_id==22865
gen matchcr5id=cr5id if pid=="20170933"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22865
drop matchpid matchcr5id
replace matched=1 if pid=="20170933"|record_id==22865

gen matchpid=pid if pid=="20160721"
fillmissing matchpid
replace pid=matchpid if record_id==23722
gen matchcr5id=cr5id if pid=="20160721"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23722
drop matchpid matchcr5id
replace matched=1 if pid=="20160721"|record_id==23722

gen matchpid=pid if pid=="20161083"
fillmissing matchpid
replace pid=matchpid if record_id==19517
gen matchcr5id=cr5id if pid=="20161083"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==19517
drop matchpid matchcr5id
replace matched=1 if pid=="20161083"|record_id==19517

gen matchpid=pid if pid=="20180889"
fillmissing matchpid
replace pid=matchpid if record_id==26096
gen matchcr5id=cr5id if pid=="20180889"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26096
drop matchpid matchcr5id
replace matched=1 if pid=="20180889"|record_id==26096

gen matchpid=pid if pid=="20180757"
fillmissing matchpid
replace pid=matchpid if record_id==26437
gen matchcr5id=cr5id if pid=="20180757"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26437
drop matchpid matchcr5id
replace matched=1 if pid=="20180757"|record_id==26437

gen matchpid=pid if pid=="20160889"
fillmissing matchpid
replace pid=matchpid if record_id==20139
gen matchcr5id=cr5id if pid=="20160889"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20139
drop matchpid matchcr5id
replace matched=1 if pid=="20160889"|record_id==20139

gen matchpid=pid if pid=="20180303"
fillmissing matchpid
replace pid=matchpid if record_id==33549
gen matchcr5id=cr5id if pid=="20180303"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==33549
drop matchpid matchcr5id
replace matched=1 if pid=="20180303"|record_id==33549

gen matchpid=pid if pid=="20180647"
fillmissing matchpid
replace pid=matchpid if record_id==28977
gen matchcr5id=cr5id if pid=="20180647"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==28977
drop matchpid matchcr5id
replace matched=1 if pid=="20180647"|record_id==28977

gen matchpid=pid if pid=="20162060"
fillmissing matchpid
replace pid=matchpid if record_id==21619
gen matchcr5id=cr5id if pid=="20162060"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21619
drop matchpid matchcr5id
replace matched=1 if pid=="20162060"|record_id==21619

gen matchpid=pid if pid=="20180364"
fillmissing matchpid
replace pid=matchpid if record_id==25519
gen matchcr5id=cr5id if pid=="20180364"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25519
drop matchpid matchcr5id
replace matched=1 if pid=="20180364"|record_id==25519

gen matchpid=pid if pid=="20161120"
fillmissing matchpid
replace pid=matchpid if record_id==20534
gen matchcr5id=cr5id if pid=="20161120"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20534
drop matchpid matchcr5id
replace matched=1 if pid=="20161120"|record_id==20534

gen matchpid=pid if pid=="20170964"
fillmissing matchpid
replace pid=matchpid if record_id==24121
gen matchcr5id=cr5id if pid=="20170964"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24121
drop matchpid matchcr5id
replace matched=1 if pid=="20170964"|record_id==24121

gen matchpid=pid if pid=="20160943"
fillmissing matchpid
replace pid=matchpid if record_id==20675
gen matchcr5id=cr5id if pid=="20160943"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20675
drop matchpid matchcr5id
replace matched=1 if pid=="20160943"|record_id==20675

gen matchpid=pid if pid=="20161211"
fillmissing matchpid
replace pid=matchpid if record_id==21735
gen matchcr5id=cr5id if pid=="20161211"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21735
drop matchpid matchcr5id
replace matched=1 if pid=="20161211"|record_id==21735

gen matchpid=pid if pid=="20161096"
fillmissing matchpid
replace pid=matchpid if record_id==19915
gen matchcr5id=cr5id if pid=="20161096"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==19915
drop matchpid matchcr5id
replace matched=1 if pid=="20161096"|record_id==19915

gen matchpid=pid if pid=="20180733"
fillmissing matchpid
replace pid=matchpid if record_id==26519
gen matchcr5id=cr5id if pid=="20180733"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26519
drop matchpid matchcr5id
replace matched=1 if pid=="20180733"|record_id==26519

gen matchpid=pid if pid=="20161145"
fillmissing matchpid
replace pid=matchpid if record_id==20455
gen matchcr5id=cr5id if pid=="20161145"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20455
drop matchpid matchcr5id
replace matched=1 if pid=="20161145"|record_id==20455

gen matchpid=pid if pid=="20180678"
fillmissing matchpid
replace pid=matchpid if record_id==25918
gen matchcr5id=cr5id if pid=="20180678"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25918
drop matchpid matchcr5id
replace matched=1 if pid=="20180678"|record_id==25918

gen matchpid=pid if pid=="20170790"
fillmissing matchpid
replace pid=matchpid if record_id==23650
gen matchcr5id=cr5id if pid=="20170790"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23650
drop matchpid matchcr5id
replace matched=1 if pid=="20170790"|record_id==23650

gen matchpid=pid if pid=="20180526"
fillmissing matchpid
replace pid=matchpid if record_id==26883
gen matchcr5id=cr5id if pid=="20180526"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26883
drop matchpid matchcr5id
replace matched=1 if pid=="20180526"|record_id==26883

gen matchpid=pid if pid=="20080336"
fillmissing matchpid
replace pid=matchpid if record_id==17261
gen matchcr5id=cr5id if pid=="20080336"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==17261
drop matchpid matchcr5id
replace matched=1 if pid=="20080336"|record_id==17261

gen matchpid=pid if pid=="20180863"
fillmissing matchpid
replace pid=matchpid if record_id==24940
gen matchcr5id=cr5id if pid=="20180863"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24940
drop matchpid matchcr5id
replace matched=1 if pid=="20180863"|record_id==24940

gen matchpid=pid if pid=="20170771"
fillmissing matchpid
replace pid=matchpid if record_id==23402
gen matchcr5id=cr5id if pid=="20170771"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23402
drop matchpid matchcr5id
replace matched=1 if pid=="20170771"|record_id==23402

gen matchpid=pid if pid=="20170916"
fillmissing matchpid
replace pid=matchpid if record_id==23389
gen matchcr5id=cr5id if pid=="20170916"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23389
drop matchpid matchcr5id
replace matched=1 if pid=="20170916"|record_id==23389

gen matchpid=pid if pid=="20181043"
fillmissing matchpid
replace pid=matchpid if record_id==24430
gen matchcr5id=cr5id if pid=="20181043"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24430
drop matchpid matchcr5id
replace matched=1 if pid=="20181043"|record_id==24430

gen matchpid=pid if pid=="20180802"
fillmissing matchpid
replace pid=matchpid if record_id==25685
gen matchcr5id=cr5id if pid=="20180802"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25685
drop matchpid matchcr5id
replace matched=1 if pid=="20180802"|record_id==25685

gen matchpid=pid if pid=="20161146"
fillmissing matchpid
replace pid=matchpid if record_id==20200
gen matchcr5id=cr5id if pid=="20161146"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20200
drop matchpid matchcr5id
replace matched=1 if pid=="20161146"|record_id==20200

gen matchpid=pid if pid=="20181152"
fillmissing matchpid
replace pid=matchpid if record_id==26638
gen matchcr5id=cr5id if pid=="20181152"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26638
drop matchpid matchcr5id
replace matched=1 if pid=="20181152"|record_id==26638

gen matchpid=pid if pid=="20180817"
fillmissing matchpid
replace pid=matchpid if record_id==26102
gen matchcr5id=cr5id if pid=="20180817"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26102
drop matchpid matchcr5id
replace matched=1 if pid=="20180817"|record_id==26102

gen matchpid=pid if pid=="20171014"
fillmissing matchpid
replace pid=matchpid if record_id==22174
gen matchcr5id=cr5id if pid=="20171014"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22174
drop matchpid matchcr5id
replace matched=1 if pid=="20171014"|record_id==22174

gen matchpid=pid if pid=="20160762"
fillmissing matchpid
replace pid=matchpid if record_id==23696
gen matchcr5id=cr5id if pid=="20160762"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23696
drop matchpid matchcr5id
replace matched=1 if pid=="20160762"|record_id==23696

gen matchpid=pid if pid=="20160872"
fillmissing matchpid
replace pid=matchpid if record_id==19953
gen matchcr5id=cr5id if pid=="20160872"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==19953
drop matchpid matchcr5id
replace matched=1 if pid=="20160872"|record_id==19953

gen matchpid=pid if pid=="20180753"
fillmissing matchpid
replace pid=matchpid if record_id==25304
gen matchcr5id=cr5id if pid=="20180753"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25304
drop matchpid matchcr5id
replace matched=1 if pid=="20180753"|record_id==25304

gen matchpid=pid if pid=="20160237"
fillmissing matchpid
replace pid=matchpid if record_id==28328
gen matchcr5id=cr5id if pid=="20160237"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==28328
drop matchpid matchcr5id
replace matched=1 if pid=="20160237"|record_id==28328

gen matchpid=pid if pid=="20181160"
fillmissing matchpid
replace pid=matchpid if record_id==34389
gen matchcr5id=cr5id if pid=="20181160"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==34389
drop matchpid matchcr5id
replace matched=1 if pid=="20181160"|record_id==34389

gen matchpid=pid if pid=="20180842"
fillmissing matchpid
replace pid=matchpid if record_id==24481
gen matchcr5id=cr5id if pid=="20180842"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24481
drop matchpid matchcr5id
replace matched=1 if pid=="20180842"|record_id==24481

gen matchpid=pid if pid=="20180737"
fillmissing matchpid
replace pid=matchpid if record_id==24785
gen matchcr5id=cr5id if pid=="20180737"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24785
drop matchpid matchcr5id
replace matched=1 if pid=="20180737"|record_id==24785

gen matchpid=pid if pid=="20180724"
fillmissing matchpid
replace pid=matchpid if record_id==24556
gen matchcr5id=cr5id if pid=="20180724"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24556
drop matchpid matchcr5id
replace matched=1 if pid=="20180724"|record_id==24556

gen matchpid=pid if pid=="20170910"
fillmissing matchpid
replace pid=matchpid if record_id==21924
gen matchcr5id=cr5id if pid=="20170910"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21924
drop matchpid matchcr5id
replace matched=1 if pid=="20170910"|record_id==21924

gen matchpid=pid if pid=="20170670"
fillmissing matchpid
replace pid=matchpid if record_id==22146
gen matchcr5id=cr5id if pid=="20170670"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22146
drop matchpid matchcr5id
replace matched=1 if pid=="20170670"|record_id==22146

gen matchpid=pid if pid=="20161182"
fillmissing matchpid
replace pid=matchpid if record_id==20573
gen matchcr5id=cr5id if pid=="20161182"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20573
drop matchpid matchcr5id
replace matched=1 if pid=="20161182"|record_id==20573

gen matchpid=pid if pid=="20170980"
fillmissing matchpid
replace pid=matchpid if record_id==22314
gen matchcr5id=cr5id if pid=="20170980"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22314
drop matchpid matchcr5id
replace matched=1 if pid=="20170980"|record_id==22314

gen matchpid=pid if pid=="20170903"
fillmissing matchpid
replace pid=matchpid if record_id==21968
gen matchcr5id=cr5id if pid=="20170903"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21968
drop matchpid matchcr5id
replace matched=1 if pid=="20170903"|record_id==21968

gen matchpid=pid if pid=="20170995"
fillmissing matchpid
replace pid=matchpid if record_id==22137
gen matchcr5id=cr5id if pid=="20170995"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22137
drop matchpid matchcr5id
replace matched=1 if pid=="20170995"|record_id==22137

gen matchpid=pid if pid=="20170777"
fillmissing matchpid
replace pid=matchpid if record_id==23456
gen matchcr5id=cr5id if pid=="20170777"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23456
drop matchpid matchcr5id
replace matched=1 if pid=="20170777"|record_id==23456

gen matchpid=pid if pid=="20180851"
fillmissing matchpid
replace pid=matchpid if record_id==26365
gen matchcr5id=cr5id if pid=="20180851"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26365
drop matchpid matchcr5id
replace matched=1 if pid=="20180851"|record_id==26365

gen matchpid=pid if pid=="20170904"
fillmissing matchpid
replace pid=matchpid if record_id==23390
gen matchcr5id=cr5id if pid=="20170904"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23390
drop matchpid matchcr5id
replace matched=1 if pid=="20170904"|record_id==23390

gen matchpid=pid if pid=="20180554"
fillmissing matchpid
replace pid=matchpid if record_id==32700
gen matchcr5id=cr5id if pid=="20180554"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==32700
drop matchpid matchcr5id
replace matched=1 if pid=="20180554"|record_id==32700

gen matchpid=pid if pid=="20170661"
fillmissing matchpid
replace pid=matchpid if record_id==22049
gen matchcr5id=cr5id if pid=="20170661"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22049
drop matchpid matchcr5id
replace matched=1 if pid=="20170661"|record_id==22049

gen matchpid=pid if pid=="20161226"
fillmissing matchpid
replace pid=matchpid if record_id==20040
gen matchcr5id=cr5id if pid=="20161226"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20040
drop matchpid matchcr5id
replace matched=1 if pid=="20161226"|record_id==20040

gen matchpid=pid if pid=="20170922"
fillmissing matchpid
replace pid=matchpid if record_id==23074
gen matchcr5id=cr5id if pid=="20170922"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23074
drop matchpid matchcr5id
replace matched=1 if pid=="20170922"|record_id==23074

gen matchpid=pid if pid=="20161204"
fillmissing matchpid
replace pid=matchpid if record_id==20232
gen matchcr5id=cr5id if pid=="20161204"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20232
drop matchpid matchcr5id
replace matched=1 if pid=="20161204"|record_id==20232

gen matchpid=pid if pid=="20180929"
fillmissing matchpid
replace pid=matchpid if record_id==25409
gen matchcr5id=cr5id if pid=="20180929"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25409
drop matchpid matchcr5id
replace matched=1 if pid=="20180929"|record_id==25409

gen matchpid=pid if pid=="20170833"
fillmissing matchpid
replace pid=matchpid if record_id==24173
gen matchcr5id=cr5id if pid=="20170833"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24173
drop matchpid matchcr5id
replace matched=1 if pid=="20170833"|record_id==24173

gen matchpid=pid if pid=="20160308"
fillmissing matchpid
replace pid=matchpid if record_id==28124
gen matchcr5id=cr5id if pid=="20160308"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==28124
drop matchpid matchcr5id
replace matched=1 if pid=="20160308"|record_id==28124

gen matchpid=pid if pid=="20180704"
fillmissing matchpid
replace pid=matchpid if record_id==25434
gen matchcr5id=cr5id if pid=="20180704"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25434
drop matchpid matchcr5id
replace matched=1 if pid=="20180704"|record_id==25434

gen matchpid=pid if pid=="20160862"
fillmissing matchpid
replace pid=matchpid if record_id==19826
gen matchcr5id=cr5id if pid=="20160862"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==19826
drop matchpid matchcr5id
replace matched=1 if pid=="20160862"|record_id==19826

gen matchpid=pid if pid=="20180654"
fillmissing matchpid
replace pid=matchpid if record_id==25163
gen matchcr5id=cr5id if pid=="20180654"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25163
drop matchpid matchcr5id
replace matched=1 if pid=="20180654"|record_id==25163

gen matchpid=pid if pid=="20160996"
fillmissing matchpid
replace pid=matchpid if record_id==21216
gen matchcr5id=cr5id if pid=="20160996"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21216
drop matchpid matchcr5id
replace matched=1 if pid=="20160996"|record_id==21216

gen matchpid=pid if pid=="20161223"
fillmissing matchpid
replace pid=matchpid if record_id==19694
gen matchcr5id=cr5id if pid=="20161223"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==19694
drop matchpid matchcr5id
replace matched=1 if pid=="20161223"|record_id==19694

gen matchpid=pid if pid=="20161107"
fillmissing matchpid
replace pid=matchpid if record_id==19962
gen matchcr5id=cr5id if pid=="20161107"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==19962
drop matchpid matchcr5id
replace matched=1 if pid=="20161107"|record_id==19962

gen matchpid=pid if pid=="20150565"
fillmissing matchpid
replace pid=matchpid if record_id==33614
gen matchcr5id=cr5id if pid=="20150565"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==33614
drop matchpid matchcr5id
replace matched=1 if pid=="20150565"|record_id==33614

gen matchpid=pid if pid=="20170751"
fillmissing matchpid
replace pid=matchpid if record_id==23092
gen matchcr5id=cr5id if pid=="20170751"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23092
drop matchpid matchcr5id
replace matched=1 if pid=="20170751"|record_id==23092

gen matchpid=pid if pid=="20180706"
fillmissing matchpid
replace pid=matchpid if record_id==25497
gen matchcr5id=cr5id if pid=="20180706"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25497
drop matchpid matchcr5id
replace matched=1 if pid=="20180706"|record_id==25497

gen matchpid=pid if pid=="20171001"
fillmissing matchpid
replace pid=matchpid if record_id==22177
gen matchcr5id=cr5id if pid=="20171001"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22177
drop matchpid matchcr5id
replace matched=1 if pid=="20171001"|record_id==22177

gen matchpid=pid if pid=="20180191"
fillmissing matchpid
replace pid=matchpid if record_id==25821
gen matchcr5id=cr5id if pid=="20180191"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25821
drop matchpid matchcr5id
replace matched=1 if pid=="20180191"|record_id==25821

gen matchpid=pid if pid=="20180881"
fillmissing matchpid
replace pid=matchpid if record_id==25896
gen matchcr5id=cr5id if pid=="20180881"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25896
drop matchpid matchcr5id
replace matched=1 if pid=="20180881"|record_id==25896

gen matchpid=pid if pid=="20161178"
fillmissing matchpid
replace pid=matchpid if record_id==21154
gen matchcr5id=cr5id if pid=="20161178"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==21154
drop matchpid matchcr5id
replace matched=1 if pid=="20161178"|record_id==21154

gen matchpid=pid if pid=="20161104"
fillmissing matchpid
replace pid=matchpid if record_id==20538
gen matchcr5id=cr5id if pid=="20161104"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==20538
drop matchpid matchcr5id
replace matched=1 if pid=="20161104"|record_id==20538

gen matchpid=pid if pid=="20180668"
fillmissing matchpid
replace pid=matchpid if record_id==25327
gen matchcr5id=cr5id if pid=="20180668"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==25327
drop matchpid matchcr5id
replace matched=1 if pid=="20180668"|record_id==25327

gen matchpid=pid if pid=="20180917"
fillmissing matchpid
replace pid=matchpid if record_id==24265
gen matchcr5id=cr5id if pid=="20180917"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24265
drop matchpid matchcr5id
replace matched=1 if pid=="20180917"|record_id==24265

gen matchpid=pid if pid=="20170300"
fillmissing matchpid
replace pid=matchpid if record_id==36728
gen matchcr5id=cr5id if pid=="20170300"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==36728
drop matchpid matchcr5id
replace matched=1 if pid=="20170300"|record_id==36728

gen matchpid=pid if pid=="20150237"
fillmissing matchpid
replace pid=matchpid if record_id==33988
gen matchcr5id=cr5id if pid=="20150237"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==33988
drop matchpid matchcr5id
replace matched=1 if pid=="20150237"|record_id==33988

gen matchpid=pid if pid=="20190052"
fillmissing matchpid
replace pid=matchpid if record_id==34537
gen matchcr5id=cr5id if pid=="20190052"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==34537
drop matchpid matchcr5id
replace matched=1 if pid=="20190052"|record_id==34537

gen matchpid=pid if pid=="20180008"
fillmissing matchpid
replace pid=matchpid if record_id==26832
gen matchcr5id=cr5id if pid=="20180008"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26832
drop matchpid matchcr5id
replace matched=1 if pid=="20180008"|record_id==26832

gen matchpid=pid if pid=="20170878"
fillmissing matchpid
replace pid=matchpid if record_id==22872
gen matchcr5id=cr5id if pid=="20170878"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22872
drop matchpid matchcr5id
replace matched=1 if pid=="20170878"|record_id==22872

gen matchpid=pid if pid=="20171033"
fillmissing matchpid
replace pid=matchpid if record_id==23832
gen matchcr5id=cr5id if pid=="20171033"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23832
drop matchpid matchcr5id
replace matched=1 if pid=="20171033"|record_id==23832

gen matchpid=pid if pid=="20170231"
fillmissing matchpid
replace pid=matchpid if record_id==22927
gen matchcr5id=cr5id if pid=="20170231"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22927
drop matchpid matchcr5id
replace matched=1 if pid=="20170231"|record_id==22927

gen matchpid=pid if pid=="20180687"
fillmissing matchpid
replace pid=matchpid if record_id==26123
gen matchcr5id=cr5id if pid=="20180687"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26123
drop matchpid matchcr5id
replace matched=1 if pid=="20180687"|record_id==26123

gen matchpid=pid if pid=="20172079"
fillmissing matchpid
replace pid=matchpid if record_id==23193
gen matchcr5id=cr5id if pid=="20172079"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23193
drop matchpid matchcr5id
replace matched=1 if pid=="20172079"|record_id==23193

gen matchpid=pid if pid=="20170882"
fillmissing matchpid
replace pid=matchpid if record_id==24096
gen matchcr5id=cr5id if pid=="20170882"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24096
drop matchpid matchcr5id
replace matched=1 if pid=="20170882"|record_id==24096

gen matchpid=pid if pid=="20161085"
fillmissing matchpid
replace pid=matchpid if record_id==19646
gen matchcr5id=cr5id if pid=="20161085"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==19646
drop matchpid matchcr5id
replace matched=1 if pid=="20161085"|record_id==19646

gen matchpid=pid if pid=="20160138"
fillmissing matchpid
replace pid=matchpid if record_id==26758
gen matchcr5id=cr5id if pid=="20160138"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26758
drop matchpid matchcr5id
replace matched=1 if pid=="20160138"|record_id==26758

gen matchpid=pid if pid=="20180166"
fillmissing matchpid
replace pid=matchpid if record_id==24659
gen matchcr5id=cr5id if pid=="20180166"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24659
drop matchpid matchcr5id
replace matched=1 if pid=="20180166"|record_id==24659

gen matchpid=pid if pid=="20170900"
fillmissing matchpid
replace pid=matchpid if record_id==22463
gen matchcr5id=cr5id if pid=="20170900"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22463
drop matchpid matchcr5id
replace matched=1 if pid=="20170900"|record_id==22463

gen matchpid=pid if pid=="20080262"
fillmissing matchpid
replace pid=matchpid if record_id==35622
gen matchcr5id=cr5id if pid=="20080262"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==35622
drop matchpid matchcr5id
replace matched=1 if pid=="20080262"|record_id==35622

gen matchpid=pid if pid=="20181080"
fillmissing matchpid
replace pid=matchpid if record_id==24650
gen matchcr5id=cr5id if pid=="20181080"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24650
drop matchpid matchcr5id
replace matched=1 if pid=="20181080"|record_id==24650

gen matchpid=pid if pid=="20170983"
fillmissing matchpid
replace pid=matchpid if record_id==23813
gen matchcr5id=cr5id if pid=="20170983"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23813
drop matchpid matchcr5id
replace matched=1 if pid=="20170983"|record_id==23813

gen matchpid=pid if pid=="20181090"
fillmissing matchpid
replace pid=matchpid if record_id==24823
gen matchcr5id=cr5id if pid=="20181090"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24823
drop matchpid matchcr5id
replace matched=1 if pid=="20181090"|record_id==24823

gen matchpid=pid if pid=="20171042"
fillmissing matchpid
replace pid=matchpid if record_id==22462
gen matchcr5id=cr5id if pid=="20171042"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22462
drop matchpid matchcr5id
replace matched=1 if pid=="20171042"|record_id==22462

gen matchpid=pid if pid=="20181058"
fillmissing matchpid
replace pid=matchpid if record_id==24542
gen matchcr5id=cr5id if pid=="20181058"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24542
drop matchpid matchcr5id
replace matched=1 if pid=="20181058"|record_id==24542

gen matchpid=pid if pid=="20161103"
fillmissing matchpid
replace pid=matchpid if record_id==19963
gen matchcr5id=cr5id if pid=="20161103"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==19963
drop matchpid matchcr5id
replace matched=1 if pid=="20161103"|record_id==19963

gen matchpid=pid if pid=="20180725"
fillmissing matchpid
replace pid=matchpid if record_id==26294
gen matchcr5id=cr5id if pid=="20180725"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==26294
drop matchpid matchcr5id
replace matched=1 if pid=="20180725"|record_id==26294

gen matchpid=pid if pid=="20170187"
fillmissing matchpid
replace pid=matchpid if record_id==23972
gen matchcr5id=cr5id if pid=="20170187"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==23972
drop matchpid matchcr5id
replace matched=1 if pid=="20170187"|record_id==23972

gen matchpid=pid if pid=="20160389"
fillmissing matchpid
replace pid=matchpid if record_id==29315
gen matchcr5id=cr5id if pid=="20160389"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==29315
drop matchpid matchcr5id
replace matched=1 if pid=="20160389"|record_id==29315

gen matchpid=pid if pid=="20145048"
fillmissing matchpid
replace pid=matchpid if record_id==34899
gen matchcr5id=cr5id if pid=="20145048"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==34899
drop matchpid matchcr5id
replace matched=1 if pid=="20145048"|record_id==34899

gen matchpid=pid if pid=="20172101"
fillmissing matchpid
replace pid=matchpid if record_id==22765
gen matchcr5id=cr5id if pid=="20172101"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==22765
drop matchpid matchcr5id
replace matched=1 if pid=="20172101"|record_id==22765

gen matchpid=pid if pid=="20170343"
fillmissing matchpid
replace pid=matchpid if record_id==24164
gen matchcr5id=cr5id if pid=="20170343"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==24164
drop matchpid matchcr5id
replace matched=1 if pid=="20170343"|record_id==24164

gen matchpid=pid if pid=="20180156"
fillmissing matchpid
replace pid=matchpid if record_id==35318
gen matchcr5id=cr5id if pid=="20180156"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==35318
drop matchpid matchcr5id
replace matched=1 if pid=="20180156"|record_id==35318

gen matchpid=pid if pid=="20130092"
fillmissing matchpid
replace pid=matchpid if record_id==28926
gen matchcr5id=cr5id if pid=="20130092"
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==28926
drop matchpid matchcr5id
replace matched=1 if pid=="20130092"|record_id==28926

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
gen matchcr5id=cr5id if pid==""
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==
drop matchpid matchcr5id
replace matched=1 if pid==""|record_id==

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
gen matchcr5id=cr5id if pid==""
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==
drop matchpid matchcr5id
replace matched=1 if pid==""|record_id==

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
gen matchcr5id=cr5id if pid==""
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==
drop matchpid matchcr5id
replace matched=1 if pid==""|record_id==

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
gen matchcr5id=cr5id if pid==""
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==
drop matchpid matchcr5id
replace matched=1 if pid==""|record_id==

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
gen matchcr5id=cr5id if pid==""
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==
drop matchpid matchcr5id
replace matched=1 if pid==""|record_id==

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
gen matchcr5id=cr5id if pid==""
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==
drop matchpid matchcr5id
replace matched=1 if pid==""|record_id==

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
gen matchcr5id=cr5id if pid==""
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==
drop matchpid matchcr5id
replace matched=1 if pid==""|record_id==

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
gen matchcr5id=cr5id if pid==""
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==
drop matchpid matchcr5id
replace matched=1 if pid==""|record_id==

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
gen matchcr5id=cr5id if pid==""
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==
drop matchpid matchcr5id
replace matched=1 if pid==""|record_id==

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
gen matchcr5id=cr5id if pid==""
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==
drop matchpid matchcr5id
replace matched=1 if pid==""|record_id==

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
gen matchcr5id=cr5id if pid==""
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==
drop matchpid matchcr5id
replace matched=1 if pid==""|record_id==

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
gen matchcr5id=cr5id if pid==""
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==
drop matchpid matchcr5id
replace matched=1 if pid==""|record_id==

gen matchpid=pid if pid==""
fillmissing matchpid
replace pid=matchpid if record_id==
gen matchcr5id=cr5id if pid==""
fillmissing matchcr5id
replace cr5id=matchcr5id if record_id==
drop matchpid matchcr5id
replace matched=1 if pid==""|record_id==


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
count if dup>0 & matched!=1 //... - review these in Stata's Browse/Edit window
order pid record_id deathid fname lname natregno dot dod primarysite coddeath
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
save "`datapath'\version09\2-working\2008_2013_2014_2015_cancer ds_2015-2020 deaths matched", replace