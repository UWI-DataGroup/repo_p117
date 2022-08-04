** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          20b_update previous years cancer.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      28-JUL-2022
    // 	date last modified      03-AUG-2022
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
//gen prev=1

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

//gen all=1
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
	(4) Update the previous dataset if necessary;
	(5) Add the PID into the reviewed code below so you know how many records are left to be reviewed.
	(6) Instead of doing (5) above just add 'Yes' to 'Completed' column in excel list.

*/
order pid cr5id dxyr slc dlc dod tnmcatstage tnmantstage etnmcatstage etnmantstage staging recstatus ///
	  fname lname init age sex dob natregno resident hospnum /// 
	  primarysite top hx morph lat beh grade basis dxyr cr5cod parish notesseen pid_all pid_prev crosschk
	  
sort pid pid_prev pid_all

STOP
13% reviewed as of 28jul2022
87% pending review as of 28jul2022

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


replace dlc=d() if pid==""
replace dlc=d() if pid==""
replace dlc=d() if pid==""
replace dlc=d() if pid==""
replace dlc=d() if pid==""
replace dlc=d() if pid==""
replace dlc=d() if pid==""
replace dlc=d() if pid==""
replace dlc=d() if pid==""
replace dlc=d() if pid==""
replace dlc=d() if pid==""
replace dlc=d() if pid==""
replace dlc=d() if pid==""
replace dlc=d() if pid==""
replace dlc=d() if pid==""
replace dlc=d() if pid==""
replace dlc=d() if pid==""
replace dlc=d() if pid==""
replace dlc=d() if pid==""
replace dlc=d() if pid==""
replace dlc=d() if pid==""
replace dlc=d() if pid==""


//fillmissing tnmcatstage if pid=="" & regexm()


count //

save "`datapath'\version09\2-working\2008-2022_cancer_crosschk_dp" ,replace
label data "BNR-Cancer prepared 2008-2022 cross-check data"
notes _dta :These data prepared for 2008,2013-2015 cross-check matching for data updated post-cleaning (2016-2018 annual report)

drop if pid_prev==""

JC 28JUL2022: save updated nonsurvival nonreportable ds for reference but will use reportable ds for appending to 2016-2018 ds in prep for death matching and final clean

** Removing cases not included for reporting: if case with MPs ensure record with persearch=1 is not dropped as used in survival dataset
//drop dup_id
sort pid
duplicates tag pid, gen(dup_id)
list pid cr5id patient eidmp persearch if dup_id>0, nolabel sepby(pid)
drop if resident==2 //0 deleted - nonresident
drop if resident==99 //0 deleted - resident unknown
drop if recstatus==3 //0 deleted - ineligible case definition
drop if sex==9 //0 deleted - sex unknown
drop if beh!=3 //0 deleted - nonmalignant
drop if persearch>2 //1 to be deleted
drop if siteiarc==25 //0 deleted - nonreportable skin cancers

count //2418

** Save this corrected dataset with only internationally reportable cases
save "`datapath'\version09\2-working\2008_2013-2015_cancer_nonsurvival_reportable", replace
label data "2008 2013 2014 2015 BNR-Cancer analysed + updated data - Non-survival Reportable Dataset"
note: TS This dataset was used for 2016-2018 annual report
note: TS Excludes ineligible case definition, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs

AFTER COMBINING PREVIOUS AND CURRENT YEARS - PERFORM DUP PID SEARCH + IARC MP CHECK

CREATE IDENTIFIABLE AND DE-IDENTIFIED DS
** Save this corrected dataset with reportable cases and identifiable data
save "`datapath'\version09\3-output\2018_cancer_nonsurvival_identifiable", replace
label data "2018 BNR-Cancer identifiable data - Non-survival Identifiable Dataset"
note: TS This dataset was NOT used for 2018 annual report; it was used for PAB 07-June-2022
note: TS Includes ineligible case definition, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs - these are removed in dataset used for analysis


** Create corrected dataset with reportable cases but de-identified data
drop fname lname natregno init dob resident parish recnum cfdx labnum SurgicalNumber specimen clindets cytofinds md consrpt sxfinds physexam imaging duration onsetint certifier dfc streviewer addr birthdate hospnum comments dobyear dobmonth dobday dob_yr dob_year dobchk sname nrnday nrnid dupnrntag

save "`datapath'\version09\3-output\2018_cancer_nonsurvival_deidentified", replace
label data "2018 BNR-Cancer de-identified data - Non-survival De-identified Dataset"
note: TS This dataset was NOT used for 2018 annual report; it was used for PAB 07-June-2022
note: TS Includes ineligible case definition, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs - these are removed in dataset used for analysis
note: TS Excludes identifiable data but contains unique IDs to allow for linking data back to identifiable data

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