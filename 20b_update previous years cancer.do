** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          20b_update previous years cancer.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      28-JUL-2022
    // 	date last modified      11-AUG-2022
    //  algorithm task          Matching prepared all years CanReg5 dataset with cleaned previous (2008, 2013-2015) cancer dataset
    //  status                  Completed
    //  objective               To have a uncleaned but prepared current dataset to cross-check with cleaned previous dataset to update previous dataset
	//							To check and update any changes to the cleaned data done by DAs post cleaning using 
	//							the last date the CanReg5 export was generated for this process.
    //  methods                 (1) Creating a new unique ID to differentiate the PIDs for each dataset
	//							(2) Removing the check flags from the previous dataset
	//							(3) In prepared CanReg5 dataset, create a variable to identify which cases have been updated since last export date 
	//								(this performed at end of 15_prep all years cancer.do)
	//							(4) Join datasets together to perform the update


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
    log using "`logpath'\20b_update previous years cancer.smcl", replace
** HEADER -----------------------------------------------------
use "`datapath'\version09\1-input\2008_2013_2014_2015_iarchub_nonsurvival_nonreportable", clear
count //4024

** Create unique ID to differentiate the PIDs in this dataset from the all years CanReg5 dataset
gen pid_prev="prevds_"+pid

** Remove morphcheckcat from previous nonreportable ds so I can re-clean using the newly created checks in the allyrs prepped ds, e.g. morphcheckcat==97
drop topcheckcat morphcheckcat hxcheckcat agecheckcat sexcheckcat sitecheckcat latcheckcat behcheckcat behsitecheckcat gradecheckcat bascheckcat stagecheckcat dotcheckcat dxyrcheckcat rxcheckcat orxcheckcat norxcheckcat sourcecheckcat doccheckcat docaddrcheckcat rptcheckcat datescheckcat

** JC 14jul2022: picked up when cleaning 2016-2018 as filtered cases in CR5db with 'intramucosal' in hx (28jul2022: already corrected in previous ds)
replace morph=8140 if pid=="20150271" & regexm(cr5id, "T1") //0 changes
replace morphcat=6 if pid=="20150271" & regexm(cr5id, "T1") //0 changes

replace hx="ADENOCARCINOMA" if pid=="20130299" & regexm(cr5id, "T1") //0 changes
replace morph=8140 if pid=="20130299" & regexm(cr5id, "T1") //0 changes
replace morphcat=6 if pid=="20130299" & regexm(cr5id, "T1") //0 changes

gen crosschk_id=pid+"_"+cr5id
gen prev=1

preserve
use "`datapath'\version09\2-working\allyears_prepped cancer" ,clear
** Change sex label for matching with population data
tab sex ,m
labelbook sex_lab
label drop sex_lab
rename sex sex_old
gen sex=1 if sex_old==2
replace sex=2 if sex_old==1
drop sex_old
label define sex_lab 1 "female" 2 "male" 9 "unknown", modify
label values sex sex_lab
label var sex "Sex"
tab sex ,m

gen all=1
save "`datapath'\version09\2-working\allyears_crosschk cancer" ,replace
restore
append using "`datapath'\version09\2-working\allyears_crosschk cancer"

//fillmissing pid_prev
//fillmissing pid_all

/* 
	Method for cross-check review:
	(1) To determine which PIDs to check for updates, use list at the bottom of dofile: 15_prep all years cancer.do
		("`datapath'\version09\2-working\crosscheckPIDs_20220728.xlsx");
	(2) Check Comments in CR5db for each PID to determine what was updated on the above list;
	(3) Check for PID in Stata Browse/Edit window using the filter: pid_prev!=""
		(NOTE: for 2015 cases they were cross-checked in the CI5 ds: p117\version02\3-output\2013_2014_2015_cancer_ci5.dta)
	(4) Update the previous dataset if necessary;
	(5) Add the PID into the reviewed code below so you know how many records are left to be reviewed.
	(6) Instead of doing (5) above just add 'Yes' to 'Completed' column in excel list.

*/
order pid cr5id dxyr slc dlc dod tnmcatstage tnmantstage etnmcatstage etnmantstage staging recstatus ///
	  fname lname init age sex dob natregno resident hospnum /// 
	  primarysite top hx morph lat beh grade basis dxyr cr5cod parish notesseen pid_all pid_prev crosschk
	  
sort pid pid_prev pid_all

** Add in missed 2015 cases (20150095, 20151048 + 20160793) from CI5 dataset (v02 or 2015AnnualReportV03 branch)
preserve
use "`datapath'\version02\3-output\2013_2014_2015_cancer_ci5" ,clear
drop if pid!="20150095" & pid!="20151048" & pid!="20160793"
count //3
gen pid_prev="prevds_"+pid
gen prev=1
save "`datapath'\version09\2-working\20150095+20151048+20160793_ci5" ,replace
restore

append using "`datapath'\version09\2-working\20150095+20151048+20160793_ci5" ,force
erase "`datapath'\version09\2-working\20150095+20151048+20160793_ci5.dta"

sort pid

** Updates to previous dataset
replace dlc=d(25oct2021) if pid=="20080119"
replace dlc=d(22sep2021) if pid=="20080171" //date taken from MedData
replace dlc=d(22mar2018) if pid=="20080197"
replace slc=2 if pid=="20080217"
replace dod=d(06feb2021) if pid=="20080217"
replace hospnum="" if pid=="20080307" & pid_prev!=""
fillmissing hospnum if pid=="20080307"
replace hospnum="99" if pid=="20080332"
replace hospnum="" if pid=="20080362" & pid_prev!=""
fillmissing hospnum if pid=="20080362"
replace dob=. if pid=="20080362" & pid_prev!=""
fillmissing dob if pid=="20080362"
replace natregno="" if pid=="20080362" & pid_prev!=""
fillmissing natregno if pid=="20080362"
replace natregno=subinstr(natregno,"-","",.) if pid=="20080362" & pid_prev!=""
replace hospnum="" if pid=="20080558" & pid_prev!=""
fillmissing hospnum if pid=="20080558"
replace hospnum="" if pid=="20080578" & pid_prev!=""
fillmissing hospnum if pid=="20080578"
replace dlc=d(28aug2018) if pid=="20080724" //date taken from MedData
replace init="" if pid=="20080737" & pid_prev!=""
fillmissing init if pid=="20080737"
replace init=lower(init) if pid=="20080737" & pid_prev!=""
replace hospnum="" if pid=="20080737" & pid_prev!=""
fillmissing hospnum if pid=="20080737"
replace slc=. if pid=="20080737" & pid_prev!=""
fillmissing slc if pid=="20080737"
replace dod=. if pid=="20080737" & pid_prev!=""
fillmissing dod if pid=="20080737"
replace natregno="" if pid=="20080737" & pid_prev!=""
fillmissing natregno if pid=="20080737"
replace natregno=subinstr(natregno,"-","",.) if pid=="20080737" & pid_prev!=""
replace hospnum="" if pid=="20080739" & pid_prev!=""
fillmissing hospnum if pid=="20080739"
replace dlc=d(13may2021) if pid=="20080739" //date taken from MedData
replace dlc=sampledate if pid=="20080746" & cr5id=="T5S1"
replace dlc=. if pid=="20080746" & cr5id!="T5S1"
fillmissing dlc if pid=="20080746"
replace natregno="" if pid=="20080746" & pid_prev!=""
fillmissing natregno if pid=="20080746"
replace natregno=subinstr(natregno,"-","",.) if pid=="20080746" & pid_prev!=""
replace hospnum="" if pid=="20081031" & pid_prev!=""
fillmissing hospnum if pid=="20081031"
replace hospnum="" if pid=="20081122" & pid_prev!=""
fillmissing hospnum if pid=="20081122"
replace slc=. if pid=="20081122" & pid_prev!=""
fillmissing slc if pid=="20081122"
replace dod=. if pid=="20081122" & pid_prev!=""
fillmissing dod if pid=="20081122"
replace dlc=sampledate if pid=="20090045" & cr5id=="T5S1"
replace dlc=. if pid=="20090045" & cr5id!="T5S1"
fillmissing dlc if pid=="20090045"
replace slc=. if pid=="20090060" & pid_prev!=""
fillmissing slc if pid=="20090060"
replace dod=. if pid=="20090060" & pid_prev!=""
fillmissing dod if pid=="20090060"
replace dlc=. if pid=="20130083" & pid_prev!=""
fillmissing dlc if pid=="20130083"
replace slc=. if pid=="20130092" & pid_prev!=""
fillmissing slc if pid=="20130092"
replace dod=. if pid=="20130092" & pid_prev!=""
fillmissing dod if pid=="20130092"
replace dlc=. if pid=="20130110"
replace dlc=d(22apr2022) if pid=="20130110" //date taken from MedData
replace slc=. if pid=="20130149" & pid_prev!=""
fillmissing slc if pid=="20130149"
replace dod=. if pid=="20130149" & pid_prev!=""
fillmissing dod if pid=="20130149"
replace dlc=. if pid=="20130162" & pid_prev!=""
fillmissing dlc if pid=="20130162"
replace init="" if pid=="20130395" & pid_prev!=""
fillmissing init if pid=="20130395"
replace init=lower(init) if pid=="20130395" & pid_prev!=""
replace hospnum="" if pid=="20130426" & pid_prev!=""
fillmissing hospnum if pid=="20130426"
replace dlc=rtdate if pid=="20130432" & cr5id=="T1S2"
replace dlc=. if pid=="20130432" & cr5id!="T1S2"
fillmissing dlc if pid=="20130432"
replace dlc=. if pid=="20130507" & pid_prev!=""
fillmissing dlc if pid=="20130507"
replace init="" if pid=="20130696" & pid_prev!=""
fillmissing init if pid=="20130696"
replace init=lower(init) if pid=="20130696" & pid_prev!=""
replace init="" if pid=="20130724" & pid_prev!=""
fillmissing init if pid=="20130724"
replace init=lower(init) if pid=="20130724" & pid_prev!=""
replace dob=. if pid=="20130724" & pid_prev!=""
fillmissing dob if pid=="20130724"
replace natregno="" if pid=="20130724" & pid_prev!=""
fillmissing natregno if pid=="20130724"
replace natregno=subinstr(natregno,"-","",.) if pid=="20130724" & pid_prev!=""
replace hospnum="" if pid=="20130772" & pid_prev!=""
fillmissing hospnum if pid=="20130772"
replace slc=. if pid=="20130786" & pid_prev!=""
fillmissing slc if pid=="20130786"
replace dod=. if pid=="20130786" & pid_prev!=""
fillmissing dod if pid=="20130786"
replace hospnum="" if pid=="20130808" & pid_prev!=""
fillmissing hospnum if pid=="20130808"
replace init="" if pid=="20130816" & pid_prev!=""
fillmissing init if pid=="20130816"
replace init=lower(init) if pid=="20130816" & pid_prev!=""
replace dod=. if pid=="20130844" & pid_prev!=""
fillmissing dod if pid=="20130844"
replace dlc=. if pid=="20130844" & pid_prev!=""
fillmissing dlc if pid=="20130844"
replace dd_dod=dod if pid=="20130844" & pid_prev!=""
replace dd_dodyear=year(dd_dod) if pid=="20130844" & pid_prev!=""
replace dodyear=year(dod) if pid=="20130844" & pid_prev!=""
replace hospnum="" if pid=="20130844" & pid_prev!=""
fillmissing hospnum if pid=="20130844"
replace hospnum="" if pid=="20130874" & pid_prev!=""
fillmissing hospnum if pid=="20130874"
replace init="" if pid=="20130874" & pid_prev!=""
fillmissing init if pid=="20130874"
replace init=lower(init) if pid=="20130874" & pid_prev!=""
replace init="" if pid=="20130885" & pid_prev!=""
fillmissing init if pid=="20130885"
replace init=lower(init) if pid=="20130885" & pid_prev!=""
replace pid="20130888" if pid=="20139997" & pid_prev!=""
replace hospnum="" if pid=="20130888" & pid_prev!=""
fillmissing hospnum if pid=="20130888"
replace init="" if pid=="20139977" & pid_prev!=""
fillmissing init if pid=="20139977"
replace init=lower(init) if pid=="20139977" & pid_prev!=""
replace init="" if pid=="20139982" & pid_prev!=""
fillmissing init if pid=="20139982"
replace init=lower(init) if pid=="20139982" & pid_prev!=""
replace hospnum="" if pid=="20139985" & pid_prev!=""
fillmissing hospnum if pid=="20139985"
replace init="" if pid=="20139985" & pid_prev!=""
fillmissing init if pid=="20139985"
replace init=lower(init) if pid=="20139985" & pid_prev!=""
replace hospnum="" if pid=="20139986" & pid_prev!=""
fillmissing hospnum if pid=="20139986"
replace init="" if pid=="20139988" & pid_prev!=""
fillmissing init if pid=="20139988"
replace init=lower(init) if pid=="20139988" & pid_prev!=""
replace hospnum="" if pid=="20139990" & pid_prev!=""
fillmissing hospnum if pid=="20139990"
replace init="" if pid=="20139990" & pid_prev!=""
fillmissing init if pid=="20139990"
replace init=lower(init) if pid=="20139990" & pid_prev!=""
replace hospnum="" if pid=="20139991" & pid_prev!=""
fillmissing hospnum if pid=="20139991"
replace init="" if pid=="20139991" & pid_prev!=""
fillmissing init if pid=="20139991"
replace init=lower(init) if pid=="20139991" & pid_prev!=""
replace hospnum="" if pid=="20139992" & pid_prev!=""
fillmissing hospnum if pid=="20139992"
replace hospnum="" if pid=="20139993" & pid_prev!=""
fillmissing hospnum if pid=="20139993"
replace hospnum="" if pid=="20139994" & pid_prev!=""
fillmissing hospnum if pid=="20139994"
replace hospnum="" if pid=="20139996" & pid_prev!=""
fillmissing hospnum if pid=="20139996"
replace hospnum="" if pid=="20139999" & pid_prev!=""
fillmissing hospnum if pid=="20139999"
replace init="" if pid=="20139999" & pid_prev!=""
fillmissing init if pid=="20139999"
replace init=lower(init) if pid=="20139999" & pid_prev!=""
replace dlc=d(22apr2021) if pid=="20080729" //date taken from MedData by KWG 04aug2022
replace init="" if pid=="20140488" & pid_prev!=""
fillmissing init if pid=="20140488"
replace init=lower(init) if pid=="20140488" & pid_prev!=""
replace hospnum="" if pid=="20140659" & pid_prev!=""
fillmissing hospnum if pid=="20140659"
replace dlc=d(19jul2022) if pid=="20140878" //date taken from MedData
replace dlc=rtdate if pid=="20140983" & cr5id=="T2S1"
replace dlc=. if pid=="20140983" & cr5id!="T2S1"
fillmissing dlc if pid=="20140983"
replace dlc=d(10nov2021) if pid=="20140988" //date taken from MedData
replace hospnum="" if pid=="20140998" & pid_prev!=""
fillmissing hospnum if pid=="20140998"
replace slc=2 if pid=="20140998" & pid_prev!=""
replace dod=d(16apr2021) if pid=="20140998" & pid_prev!="" //date taken from MedData + multi-yr REDCap deathdb
replace dlc=d(05nov2021) if pid=="20141136" //date taken from MedData
replace slc=2 if pid=="20141174" & pid_prev!=""
replace dod=d(19jan2021) if pid=="20141174" & pid_prev!="" //date taken from MedData + multi-yr REDCap deathdb
replace slc=. if pid=="20141188" & pid_prev!=""
fillmissing slc if pid=="20141188"
replace dod=. if pid=="20141188" & pid_prev!=""
fillmissing dod if pid=="20141188"
replace dlc=d(09may2022) if pid=="20141205" //date taken from MedData

** JC 04aug2022 - missed MP: colon should be T2 and stomach T1
expand=2 if pid=="20141254" & pid_prev!="", gen (dupobs1)
replace cr5id="T2S1" if dupobs1==1

replace primarysite="STOMACH" if pid=="20141254" & regexm(cr5id,"T1") & pid_prev!=""
replace top="169" if pid=="20141254" & regexm(cr5id,"T1") & pid_prev!=""
replace topography=169 if pid=="20141254" & regexm(cr5id,"T1") & pid_prev!=""
replace topcat=17 if pid=="20141254" & regexm(cr5id,"T1") & pid_prev!=""
replace icd10="C169" if pid=="20141254" & regexm(cr5id,"T1") & pid_prev!=""
replace siteiarc=11 if pid=="20141254" & regexm(cr5id,"T1") & pid_prev!=""
replace sitecr5db=3 if pid=="20141254" & regexm(cr5id,"T1") & pid_prev!=""

replace grade=9 if pid=="20141254" & regexm(cr5id,"T2") & pid_prev!=""
replace dot=dlc if pid=="20141254" & regexm(cr5id,"T2") & pid_prev!=""
replace crosschk_id="20141254_T2S1" if pid=="20141254" & regexm(cr5id,"T2") & pid_prev!=""
replace eidmp=2 if pid=="20141254" & regexm(cr5id,"T2") & pid_prev!=""
replace ptrectot=3 if pid=="20141254" & regexm(cr5id,"T2") & pid_prev!=""
replace patient=2 if pid=="20141254" & regexm(cr5id,"T2") & pid_prev!=""
replace persearch=2 if pid=="20141254" & regexm(cr5id,"T2") & pid_prev!=""

replace comments="" if pid=="20141254" & pid_prev!=""
fillmissing comments if pid=="20141254"
replace slc=. if pid=="20141254" & pid_prev!=""
fillmissing slc if pid=="20141254"
replace dod=. if pid=="20141254" & pid_prev!=""
fillmissing dod if pid=="20141254"
*************************************************************************************************

replace hospnum="" if pid=="20141288" & pid_prev!=""
fillmissing hospnum if pid=="20141288"
replace dlc=d(20jul2022) if pid=="20141358" //date taken from MedData
replace hospnum="" if pid=="20141383" & pid_prev!=""
fillmissing hospnum if pid=="20141383"
replace slc=. if pid=="20141400" & pid_prev!=""
fillmissing slc if pid=="20141400"
replace dod=. if pid=="20141400" & pid_prev!=""
fillmissing dod if pid=="20141400"
replace hospnum="" if pid=="20141414" & pid_prev!=""
fillmissing hospnum if pid=="20141414"
replace dlc=d(25feb2020) if pid=="20141414" //date taken from MedData
replace slc=. if pid=="20141549" & pid_prev!=""
fillmissing slc if pid=="20141549"
replace dod=. if pid=="20141549" & pid_prev!=""
fillmissing dod if pid=="20141549"
replace dlc=d(05jun2022) if pid=="20145054" //date taken from MedData
replace slc=. if pid=="20145077" & pid_prev!=""
fillmissing slc if pid=="20145077"
replace dod=. if pid=="20145077" & pid_prev!=""
fillmissing dod if pid=="20145077"
replace slc=. if pid=="20150004" & pid_prev!=""
fillmissing slc if pid=="20150004"
replace dod=. if pid=="20150004" & pid_prev!=""
fillmissing dod if pid=="20150004"
replace hospnum="" if pid=="20150013" & pid_prev!=""
fillmissing hospnum if pid=="20150013"
replace hospnum="" if pid=="20150091" & pid_prev!=""
fillmissing hospnum if pid=="20150091"
replace dlc=. if pid=="20150091" & pid_prev!=""
fillmissing dlc if pid=="20150091"
replace dlc=. if pid=="20150093" & pid_prev!=""
fillmissing dlc if pid=="20150093"
replace hospnum="" if pid=="20150094" & pid_prev!=""
fillmissing hospnum if pid=="20150094"
replace dlc=. if pid=="20150094" & pid_prev!=""
fillmissing dlc if pid=="20150094"
replace dlc=d(08feb2022) if pid=="20150160" //date taken from MedData
replace hospnum="" if pid=="20150170" & pid_prev!=""
fillmissing hospnum if pid=="20150170"
replace dlc=d(19jul2022) if pid=="20150180" //date taken from MedData
replace dlc=d(18jul2022) if pid=="20150196" //date taken from MedData
replace slc=. if pid=="20150234" & pid_prev!=""
fillmissing slc if pid=="20150234"
replace dod=. if pid=="20150234" & pid_prev!=""
fillmissing dod if pid=="20150234"
replace hospnum="" if pid=="20150234" & pid_prev!=""
fillmissing hospnum if pid=="20150234"
replace hospnum="" if pid=="20150254" & pid_prev!=""
fillmissing hospnum if pid=="20150254"
replace dlc=d(08jun2022) if pid=="20150254" //date taken from MedData
replace dlc=d(12dec2021) if pid=="20150291" //date taken from MedData
replace init="o" if pid=="20150298"
replace hospnum="" if pid=="20150303" & pid_prev!=""
fillmissing hospnum if pid=="20150303"
replace dlc=d(07mar2022) if pid=="20150303" //date taken from MedData
replace slc=. if pid=="20150313" & pid_prev!=""
fillmissing slc if pid=="20150313"
replace dod=. if pid=="20150313" & pid_prev!=""
fillmissing dod if pid=="20150313"
replace hospnum="" if pid=="20150313" & pid_prev!=""
fillmissing hospnum if pid=="20150313"
replace hospnum="" if pid=="20150314" & pid_prev!=""
fillmissing hospnum if pid=="20150314"
replace hospnum="" if pid=="20150333" & pid_prev!=""
fillmissing hospnum if pid=="20150333"
replace dlc=d(11apr2017) if pid=="20150333" //date taken from MedData
replace slc=. if pid=="20150335" & pid_prev!=""
fillmissing slc if pid=="20150335"
replace dod=. if pid=="20150335" & pid_prev!=""
fillmissing dod if pid=="20150335"
replace hospnum="" if pid=="20150348" & pid_prev!=""
fillmissing hospnum if pid=="20150348"
replace dlc=d(18jul2022) if pid=="20150348" //date taken from MedData
replace resident=. if pid=="20150439" & pid_prev!=""
fillmissing resident if pid=="20150439"
replace recstatus=. if pid=="20150439" & pid_prev!="" //ineligible
fillmissing recstatus if pid=="20150439"
replace dlc=. if pid=="20150565" & pid_prev!=""
fillmissing dlc if pid=="20150565"
replace hospnum="" if pid=="20151012" & pid_prev!=""
fillmissing hospnum if pid=="20151012"
replace hospnum="" if pid=="20151033" & pid_prev!=""
fillmissing hospnum if pid=="20151033"
replace dlc=d(28apr2021) if pid=="20151033" //date taken from MedData
replace slc=. if pid=="20151103" & pid_prev!=""
fillmissing slc if pid=="20151103"
replace dod=. if pid=="20151103" & pid_prev!=""
fillmissing dod if pid=="20151103"
replace dlc=d(03aug2022) if pid=="20151115" //date taken from MedData
replace slc=2 if pid=="20151132" & pid_prev!=""
replace dod=d(14sep2021) if pid=="20151132" & pid_prev!="" //date taken from multi-yr REDCap deathdb
replace dlc=d(28jul2022) if pid=="20151190" //date taken from MedData
replace hospnum="" if pid=="20151240" & pid_prev!=""
fillmissing hospnum if pid=="20151240"
replace hospnum="" if pid=="20151296" & pid_prev!=""
fillmissing hospnum if pid=="20151296"
replace hospnum="" if pid=="20151300" & pid_prev!=""
fillmissing hospnum if pid=="20151300"
replace hospnum="" if pid=="20151323" & pid_prev!=""
fillmissing hospnum if pid=="20151323"
replace hospnum="" if pid=="20151381" & pid_prev!=""
fillmissing hospnum if pid=="20151381"
replace dlc=d(23mar2022) if pid=="20151381" //date taken from MedData
replace hospnum="" if pid=="20155021" & pid_prev!=""
fillmissing hospnum if pid=="20155021"
replace dlc=d(11jul2022) if pid=="20155211" //date taken from MedData
replace hospnum="" if pid=="20159021" & pid_prev!=""
fillmissing hospnum if pid=="20159021"
replace init="" if pid=="20159030" & pid_prev!=""
fillmissing init if pid=="20159030"
replace init=lower(init) if pid=="20159030" & pid_prev!=""
replace hospnum="" if pid=="20159030" & pid_prev!=""
fillmissing hospnum if pid=="20159030"
replace init="" if pid=="20159063" & pid_prev!=""
fillmissing init if pid=="20159063"
replace init=lower(init) if pid=="20159063" & pid_prev!=""
replace init="" if pid=="20159064" & pid_prev!=""
fillmissing init if pid=="20159064"
replace init=lower(init) if pid=="20159064" & pid_prev!=""
replace init="" if pid=="20159120" & pid_prev!=""
fillmissing init if pid=="20159120"
replace init=lower(init) if pid=="20159120" & pid_prev!=""
replace hospnum="" if pid=="20159120" & pid_prev!=""
fillmissing hospnum if pid=="20159120"
replace hospnum="" if pid=="20160029" & pid_prev!=""
fillmissing hospnum if pid=="20160029"
replace init="" if pid=="20180750" & pid_prev!=""
fillmissing init if pid=="20180750"
replace init=lower(init) if pid=="20180750" & pid_prev!=""

replace resident=1 if pid=="20150036" //JC 10aug2022: misread excel sheet for this instead of 20150536 but still keep these corrections
replace notesseen=4 if pid=="20150036"
replace dlc=d(04aug2022) if pid=="20150036"
replace lat=2 if pid=="20150036" & regexm(cr5id,"T1")
replace grade=6 if pid=="20150036" & regexm(cr5id,"T1")

/*
JC 10aug2022: NOT SURE THESE UPDATES WILL WORK AND ARE NECESSARY AT THIS POINT DUE TO STRINGENT DEADLINE

//fillmissing tnmcatstage if pid=="" & regexm()
count if notesseen!=. & notesseen!=3 & pid_prev!=""
gen nochange=1 if notesseen!=. & notesseen!=3 & pid_prev!=""

replace notesseen=. if nochange!=1 & pid_prev!=""
fillmissing notesseen if nochange!=1
drop nochange

count if hospnum="" & pid_prev!=""
gen change=1 if hospnum="" & pid_prev!=""
fillmissing hospnum if change==1
*/

** Remove the records from the allyears ds
count if prev==1 //4028
count if all==1 //19,818
drop if all==1 //19,818 deleted

** Create variable to differentiate current years from previous years in prep for death matching
gen previousds=1

count //4028

save "`datapath'\version09\3-output\2008_2013_2014_2015_crosschecked_nonreportable" ,replace
label data "BNR-Cancer prepared 2008-2022 cross-checked data"
notes _dta :These data prepared for 2008,2013-2015 cross-check matching for data updated post-cleaning from 2015 annual report (2016-2018 annual report)

erase "`datapath'\version09\2-working\allyears_crosschk cancer.dta" //not needed for later processes so delete to save space on SharePoint

** JC 28jul2022: See if there's a way in Stata to spot differences with observations that have same PID - METHOD BELOW DOESN'T WORK FOR THIS PROCESS AS THE DATASETS TO BE COMPARED HAVE DIFFERENT OBSERVATIONS TOTALS
//rename * *_prev
//rename crosschk_id_prev crosschk_id
/*
//ssc install compuse
compuse dlc using "`datapath'\version09\2-working\allyears_prepped cancer", sortvars(crosschk_id) new(prev) old(all) saving(crosschk, replace)
dir crosschk_dlc.dta
use crosschk_dlc.dta, clear
describe
summarize
tab dlc if dlc_prev<dlc_all
STOP

** Add on the prepared CanReg5 dataset
//append using "`datapath'\version09\2-working\allyears_prepped cancer"
//compare dlc dlc_prev by crosschk_id
//ssc install cf2

append using "`datapath'\version09\2-working\allyears_prepped cancer"
drop if dxyr>2015
count //12,574
drop dupcross
sort crosschk_id
quietly by crosschk_id:  gen dupcross = cond(_N==1,0,_n)
count if dupcross>1 //3966
count if dupcross==0 //4642
count if dupcross==0 & pid_all!="" //4584
order pid crosschk_id pid_prev pid_all dupcross dxyr
drop if dupcross==0 & pid_all!="" //4584 deleted
count if pid_all!=""
count if pid_prev!=""
save "`datapath'\version09\2-working\cross-check cancer" ,replace
drop if pid_all!="" //3966 deleted
cf2 _all using "`datapath'\version09\2-working\cross-check cancer", verbose id(crosschk_id)

cf dlc dlc_prev using "`datapath'\version09\2-working\allyears_prepped cancer"
*/