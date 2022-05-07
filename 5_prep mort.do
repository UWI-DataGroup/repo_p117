** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          5_prep_mort.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      06-MAY-2022
    // 	date last modified      06-MAY-2022
    //  algorithm task          Prep and format death data using previously-prepared datasets and REDCap database export
    //  status                  Completed
    //  objective               To have multiple datasets with cleaned death data for:
	//							(1) matching with incidence data and 
	//							(2) analysis/reporting mortality rates.
    
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
    log using "`logpath'\5_prep_mort.smcl", replace
** HEADER -----------------------------------------------------

/* 
	JC 06may2022:
	
	Unlike previous iterations of this dofile, errors in NRN and names were detected in REDCap 2008-2020 death db.
	The errors were corrected manually by the DAs using the electoral list.
	As a result, previously-prepared Stata death matching dataset (`datapath'\version02\2015-2020_deaths_for_matching.dta) contains the erroneous data.
	Before proceeding with the regular death prep, the death matching dataset needs to be corrected.
	
	To correct the dataset, the below steps will be taken:
	(1) prep NRN and names variables of current 2015-2020 deaths from export of REDCap data;
	(2) merge with previously-prepared dataset (2015-2020_deaths_for_matching.dta) using record_id;
	(3) check for any cases whose NRN and names do not match;
	(4) correct errors in previously-prepared dataset (2015-2020_deaths_for_matching.dta);
	(5) drop REDCap death data and save corrected 2015-2020_deaths_for_matching.dta which will be used for appending cleaned 2021 death data.
	
	Then proceed with:
	(1) prep of 2018 death data for analysis/reporting
	(2) prep of cleaned 2021 death data for matching with incidence data 
		(2021 data to be appended to 2015-2020_deaths_for_matching.dta)
*/

***************
** DATA IMPORT  
***************
** LOAD the national registry deaths 2008-2020 excel dataset
import excel using "`datapath'\version04\1-input\BNRDeathData20082020_DATA_2022-05-06_1222_excel.xlsx" , firstrow case(lower)

count //32,467

*******************
** DATA FORMATTING  
*******************
** PREPARE each variable according to the format and order in which they appear in DeathData REDCap database.
** Note JC 06may2022: only select variables from the original code were prepared and kept for this corrective process.

************************
**  DEATH CERTIFICATE **
**        FORM        **
************************
** (9) pname: Text, if missing=99
label var pname "Deceased's Name"
replace pname = rtrim(ltrim(itrim(pname))) //5 changes

** (15) nrnnd: 1=Yes 2=No
label var nrnnd "Is National ID # documented?"

** (16) nrn: dob-####, partial missing=dob-9999, if missing=.
label var nrn "National ID #"
format nrn %15.0g

** (21) dod: Y-M-D
format dod %tdCCYY-NN-DD
label var dod "Date of Death"

** (22) dodyear (not included in single year Redcap db but done for multi-year Redcap db)
drop dodyear
gen int dodyear=year(dod)
label var dodyear "Year of Death"

** Remove TF form and years before 2015
drop if dodyear<2015 //16,795 deleted
drop if redcap_event_name!="death_data_collect_arm_1" //255 deleted
count //15,417

** Reminder to self (JC 19-Aug-2021): For 2016 and onwards annual report cleaning, re-do below code when creating natregno string variable using gen double code as this changes the NRNs
/*
//format nrn %10.0g
gen double nrn2=nrn
format nrn2 %15.0g
rename nrn2 natregno
tostring natregno ,replace
*/
gen double natregno = nrn
format natregno %15.0g
tostring natregno ,replace
count if length(natregno)==9 //64
count if length(natregno)==8 //2
count if length(natregno)==7 //12
replace natregno="0" + natregno if length(natregno)==9 //64 changes
replace natregno="00" + natregno if length(natregno)==8 //2 changes
replace natregno="000" + natregno if length(natregno)==7 //12 changes
count if natregno=="." //723
replace natregno="" if natregno=="." //723 changes
count if natregno!="" & length(natregno)!=10 //0
count if nrn!=. & natregno=="" //0
count if nrn!=. & natregno=="" //0

** In combining the previously-prepared dataset and the REDCap export, the below errors in record_id need to be corrected
replace record_id=18490 if record_id==18489
replace record_id=27642 if record_id==27644
drop if record_id==25341 //record is 34120 in REDCapdb but with different pname - checked MedData and Electoral list and cannot find this pt is deceased in either; manually deleted 25341 from REDCapdb.

** Remove variables not needed for this corrective process
keep record_id pname nrnnd nrn dod dodyear natregno

** Change variable names (except record_id) in prep for merge
rename pname rc_pname
rename nrnnd rc_nrnnd
rename nrn rc_nrn
rename dod rc_dod
rename dodyear rc_dodyear
rename natregno rc_natregno

order record_id rc_pname rc_nrnnd rc_nrn rc_dod rc_dodyear rc_natregno

count //15,416

label data "BNR MORTALITY data 2015-2020: REDCap"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version04\2-working\2015-2020_deaths_redcap" ,replace
note: TS Only select data is included in this dataset


**************************
**     Merging with     ** 
**	previously-prepared **
** 	  2015-2020 Deaths  **
**************************
use "`datapath'\version04\1-input\2015-2020_deaths_for_matching" ,clear

rename dd6yrs_* dd_*
rename dob dd_dob

** Remove duplicates found during this process
drop if dd_record_id==27566 //duplicate of 27600
drop if dd_record_id==27730 //duplicate of 27634
drop if dd_record_id==27644 //duplicate of 27642
replace dd_record_id=34120 if dd_record_id==25341 //record is 34120 in REDCapdb but with NRN of 25341

** Update corrected NRNs + COD info from above duplicates
preserve
clear
import excel using "`datapath'\version04\2-working\NRNelectoral_20220506.xlsx" , firstrow case(lower)
tostring elec_natregno ,replace
save "`datapath'\version04\2-working\electoral_nrn" ,replace
restore

merge 1:1 dd_record_id using "`datapath'\version04\2-working\electoral_nrn" ,force
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                        15,411
        from master                    15,411  (_merge==1)
        from using                          0  (_merge==2)

    Matched                                 2  (_merge==3)
    -----------------------------------------
*/
format elec_nrn %15.0g
replace dd_nrn=elec_nrn if _merge==3 //1 change
replace dd_natregno=elec_natregno if _merge==3 //2 changes
replace dd_certtype=elec_certtype if _merge==3 //1 change
replace dd_cod1a=elec_cod1a if _merge==3 //1 change
replace dd_cod1b=elec_cod1b if _merge==3 //1 change
replace dd_cod1c=elec_cod1c if _merge==3 //1 change
replace dd_onsetnumcod1c=elec_onsetnumcod1c if _merge==3 //1 change
replace dd_onsettxtcod1c=elec_onsettxtcod1c if _merge==3 //1 change
replace dd_coddeath=elec_coddeath if _merge==3 //1 change
drop elec_* _merge

** Add in three 2018 cases from REDCapdb that were missing from previously-prepared dataset
preserve
clear
import excel using "`datapath'\version04\2-working\MissingDeaths_20220506.xlsx" , firstrow case(lower)
destring dd_regnum ,replace
tostring dd_mname ,replace
tostring dd_natregno ,replace
save "`datapath'\version04\2-working\missingdeaths" ,replace
restore

append using "`datapath'\version04\2-working\missingdeaths"
erase "`datapath'\version04\2-working\missingdeaths.dta" //remove datasets to reduce storage space on SharePoint

replace dd_mname="" if dd_mname=="." //3 changes
replace dd_cod1d="99" if dd_cod1d=="099" //3 changes
generate double date_dddoa = clock(dddoa, "YMDhms")
format date_dddoa %tcCCYY-NN-DD_HH:MM
replace dd_dddoa=date_dddoa if date_dddoa!=.
drop dddoa date_dddoa

count //15,416


** Combine previously-prepared dataset with REDCap dataset
preserve
append using "`datapath'\version04\2-working\2015-2020_deaths_redcap"
count //30,832

replace record_id=dd_record_id if record_id==. & dd_record_id!=.
replace rc_pname=dd_pname if rc_pname=="" & dd_pname!=""
count if record_id==. //0

sort record_id
quietly by record_id:  gen dupid = cond(_N==1,0,_n)
sort record_id
count if dupid>0 //30,824
count if dupid==0 //9 - all corrected above so now it's 0

//list dd_record_id record_id dd_pname rc_pname dd_dod rc_dod dd_dodyear rc_dodyear dd_natregno rc_natregno if dupid==0


sort rc_pname
quietly by rc_pname:  gen dup = cond(_N==1,0,_n)
sort rc_pname
count if dup>0 //30,566
count if dup==0 //266
sort rc_pname record_id
//list dd_record_id record_id dd_pname rc_pname dd_dod rc_dod dd_dodyear rc_dodyear dd_natregno rc_natregno if dup==0
restore



** Now that some of the data has been corrected, merge the datasets for a final check
rename dd_record_id record_id

merge 1:1 record_id using "`datapath'\version04\2-working\2015-2020_deaths_redcap"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                            15,416  (_merge==3)
    -----------------------------------------
*/
//list record_id dd_pname rc_pname if _merge==1|_merge==2

** Correcting NRN ND variable
count if dd_nrnnd!=rc_nrnnd //2
list record_id dd_nrnnd rc_nrnnd dd_nrn rc_nrn if dd_nrnnd!=rc_nrnnd
replace dd_nrnnd=2 if record_id==26253
replace dd_nrnnd=1 if record_id==27600

** Correcting NRN variable
count if dd_nrn!=rc_nrn //10
//list record_id dd_nrn rc_nrn if dd_nrn!=rc_nrn
replace dd_nrn=rc_nrn if dd_nrn!=rc_nrn & record_id!=28513 //9 changes
count if rc_nrn!=dd_nrn //1
replace rc_nrn=dd_nrn if rc_nrn!=dd_nrn //updated 28513 directly in REDCapdb
count if dd_natregno!=rc_natregno //5,137
replace dd_natregno=rc_natregno if dd_natregno!=rc_natregno //5,137 changes

** Correcting Pt Name variable
count if rc_pname!=dd_pname //137
count if dd_pname!=rc_pname //137
list record_id dd_nrn dd_pname rc_pname if rc_pname!=dd_pname
gen fixpname=1 if rc_pname!=dd_pname
replace dd_pname=rc_pname if rc_pname!=dd_pname //137 changes
count if dd_pname!=rc_pname //0

** Correcting First, Middle and Last Names variables
gen ptname=dd_pname if fixpname==1
split ptname, parse(", "" ") gen(name)
order record_id ptname name1 name2 name3 name4 name5 dd_pname dd_fname dd_mname dd_lname
sort record_id

replace name5=name2 if name2!="" & name3=="" & name4=="" & name5=="" & fixpname==1 //95 changes
replace name2="" if name5==name2 & fixpname==1 //95 changes
replace name5=name3 if name3!="" & name4=="" & name5=="" & fixpname==1 //36 changes
replace name3="" if name5==name3 & fixpname==1 //36 changes
replace name5=name4+" "+name5 if name4!="" & fixpname==1 //6 changes
replace name5=name2+name5 if (name2=="MC"|name2=="MAC"|name2=="ST.") & fixpname==1 //6 changes
replace name5=name2+" "+name5 if name2=="ST" & fixpname==1 //1 change
replace name2="" if (name2=="MC"|name2=="MAC"|name2=="ST."|name2=="ST") & fixpname==1 //7 changes
replace name5=name3+name5 if (name3=="MC"|name3=="MAC"|name3=="ST.") & fixpname==1 //3 changes
replace name5=name3+" "+name5 if name3=="ST" & fixpname==1 //1 change
replace name3="" if (name3=="MC"|name3=="MAC"|name3=="ST."|name3=="ST") & fixpname==1 //4 changes
replace name5=name2+" "+name5 if name5=="JR" & fixpname==1 //1 change
replace name2=name2+" "+name3 if record_id==26864|record_id==27422
replace name2="" if record_id==30079
replace dd_fname=name1 if fixpname==1 //137 changes
replace dd_mname=name2 if fixpname==1 //44 changes
replace dd_lname=name5 if fixpname==1 //137 changes

replace dd_fname = lower(rtrim(ltrim(itrim(dd_fname)))) if fixpname==1 //137 changes
replace dd_mname = lower(rtrim(ltrim(itrim(dd_mname)))) if fixpname==1 //34 changes
replace dd_lname = lower(rtrim(ltrim(itrim(dd_lname)))) if fixpname==1 //137 changes
drop ptname fixpname name1 name2 name3 name4 name5

** Remove redcap variables
drop rc_pname rc_nrnnd rc_nrn rc_dod rc_dodyear rc_natregno _merge
erase "`datapath'\version04\2-working\2015-2020_deaths_redcap.dta"

label data "BNR MORTALITY data 2015-2020"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version04\3-output\2015-2020_deaths_for_matching" ,replace
note: TS This dataset can be used for matching 2015-2020 deaths with incidence data

stop
*********************
**     Preparing   **
** 	  2018 Deaths  **
**	 for analysis  **
*********************
use "`datapath'\version04\3-output\2015-2020_deaths_for_matching" ,clear
/*
This dataset preparation differs from above (2017-2018) in below ways:
 (1) 2017-2018 ds used for matching with cancer ds for survival analysisas
 (2) 2015 ds used for reporting on ASMR (age-standardized mortality rates)
	 - need to identify deaths with multiple eligible cancer CODs
	 - need to assign each death by site as ASMR reported by site 
*/
** Next we get rid of those who died pre-2017 (there are previously unmatched 2017 cases in dataset)
drop if dod<d(01jan2015) | dod>d(31dec2015) //21778 deleted
** Remove Tracking Form info
drop if event==2 //0 deleted

count //2494

*****************
**  Formatting **
**    Names    **
*****************
** Change variables that contain 'name' so that names can be easily parsed
rename namematch nm

** Need to check for duplicate death registrations
** First split full name into first, middle and last names
** Also - code to split full name into 2 variables fname and lname - else can't merge! 
split pname, parse(", "" ") gen(name)
order record_id pname name*
sort record_id

** Use Stata browse to view results as changes are made
** (1) sort cases that contain only a first name and a last name
count if name5=="" & name4=="" & name3=="" //1767
count if name4=="" & name3=="" & name2=="" //0
count if name3=="" & name2=="" //0
count if name2=="" //0
count if name1=="" //0
replace name5=name2 if name5=="" & name3=="" & name4=="" //1767
replace name2="" if name3=="" & name4=="" //1767

** (2) sort cases with name 'baby' or 'b/o' in name1 variable
count if (regexm(name1,"BABY")|regexm(name1,"B/O")|regexm(name1,"MALE")|regexm(name1,"FEMALE")) //8
gen tempvarn=1 if (regexm(name1,"BABY")|regexm(name1,"B/O")|regexm(name1,"MALE")|regexm(name1,"FEMALE"))
//list record_id pname name1 name2 name3 name4 name5 if tempvarn==1
//list record_id pname name6 name7 if tempvarn==1
replace name1=name1+" "+name2 if tempvarn==1 //8 changes
replace name2="" if tempvarn==1 //8 changes
replace name1=name1+" "+name3 if tempvarn==1 & name4!="" //6 changes
replace name3=name4 if tempvarn==1 & name4!="" //6 changes
replace name4="" if tempvarn==1 & name4!="" //6 changes
drop if record_id==17407 //duplicate registration

** (3)
** Names containing 'ST' are being interpreted as 'ST'=name1/fname so correct
count if name1=="ST" | name1=="ST." //3
replace tempvarn=2 if name1=="ST" | name1=="ST." //3 changes
//list record_id pname name1 name2 name5 if tempvarn==2
replace name1=name1+"."+""+name2 if tempvarn==2 //3 changes
replace name2="" if tempvarn==2 //6 changes
replace name2=name3+" "+name4 if record_id==18395
replace name3=name5 if record_id==18395
replace name4="" if record_id==18395
replace name5="" if record_id==18395
replace name1 = subinstr(name1, ".", "",1) if record_id==16807
** Names containing 'ST' are being interpreted as 'ST'=name2/fname so correct
count if name2=="ST" | name2=="ST." //12
replace tempvarn=3 if name2=="ST" | name2=="ST." //12 changes
replace name3=name2+name3 if tempvarn==3 & name4=="" //3 changess
replace name2="" if tempvarn==3 & name4=="" //3 changess
replace name2=name2+"."+""+name3 if tempvarn==3 & name4!="" //9 changes
replace name2 = subinstr(name2, ".", "",1) if tempvarn==3 & record_id==17454|record_id==18739
replace name3=name4 if tempvarn==3 & name4!="" //9 changes
replace name4="" if tempvarn==3 //21 changes
** Names containing 'ST' are being interpreted as 'ST'=name3/fname so correct
count if name3=="ST" | name3=="ST." //3
replace tempvarn=4 if name3=="ST" | name3=="ST."
replace name3=name3+"."+""+name4 if tempvarn==4 //3 changes
replace name4="" if tempvarn==4 //3 changes
replace name3 = subinstr(name3, ".", "",1) if tempvarn==4 & record_id==17658|record_id==17863

** (4) sort cases with name in name5 variable
count if name5!="" //1768
count if name5!="" & name4=="" & name3=="" //1767
count if name5!="" & name4!="" & name3!="" //1
//list record_id *name* if name5!=""
replace name2=name2+" "+name3+" "+name4 if record_id==18380
replace name3=name5 if record_id==18380
replace name5="" if record_id==18380
replace name4="" if record_id==18380
replace name3=name5 if name5!="" & name4=="" & name3=="" //1767 chagnes
replace name5="" if name3!="" & name4=="" //1767 changes

** (6) sort cases with name in name4 variable
count if name4!="" //45
//list record_id *name* if name4!=""
replace name2=name2+" "+name3 if name4!="" //45 changes
replace name3=name4 if name4!="" //45 changes
replace name4="" if name4!="" //45 changes

** (7) sort cases with NO name in name3 variable
count if name3=="" //0
//list record_id *name* if name3==""

** (8) sort cases with suffixes
count if (name3!="" & name3!="99") & length(name3)<4 //17 - 1 needs correcting
replace tempvarn=5 if (name3!="" & name3!="99") & length(name3)<4 //17 changes
//list record_id pname fname mname lname if (lname!="" & lname!="99") & length(lname)<3
replace name3=name2+" "+name3 if record_id==18039
replace name2="" if record_id==18039

** Now rename, check and remove unnecessary variables
rename name1 fname
rename name2 mname
rename name3 lname
count if fname=="" //0
count if lname=="" //0
drop name4 name5 tempvarn

** Convert names to lower case and strip possible leading/trailing blanks
replace fname = lower(rtrim(ltrim(itrim(fname)))) //2493 changes
replace mname = lower(rtrim(ltrim(itrim(mname)))) //713 changes
replace lname = lower(rtrim(ltrim(itrim(lname)))) //2493 changes

rename nm namematch
order record_id pname fname mname lname namematch

*************************
** Checking & Removing ** 
**   Duplicate Death   **
**    Registrations    **
*************************
/* 
NB: These deaths were cleaned previously for importing into DeathData REDCapdb 
so the field namematch can be used as a guide for checking duplicates
	1=names match but different person
	2=no name match
*/
//label define namematch_lab 1 "deaths only namematch,diff.pt" 2 "no namematch" 3 "cr5 & death namematch,diff.pt" 4 "slc=2/9,not in deathdata", modify
//label values namematch namematch_lab
sort lname fname record_id
quietly by lname fname : gen dupname = cond(_N==1,0,_n)
sort lname fname record_id
count if dupname>0 //51
/* 
Check below list for cases where namematch=no match but 
there is a pt with same name then:
 (1) check if same pt and remove duplicate pt;
 (2) check if same name but different pt and
	 update namematch variable to reflect this, i.e.
	 namematch=1
*/
//list record_id namematch fname lname nrn dod sex age if dupname>0
sort record_id
drop if record_id==17986 //1 deleted - duplicate registration for record_id=17987
drop if record_id==17614 //1 deleted - duplicate registration for record_id=17613
replace deathparish=9 if record_id==17613
drop if record_id==18430 //1 deleted - duplicate registration for record_id=18431
replace sex=1 if record_id==18431
drop if record_id==17167 //1 deleted - duplicate registration for record_id=17166
drop if record_id==16871 //1 deleted - duplicate registration for record_id=16872
drop if record_id==18505 //1 deleted - duplicate registration for record_id=18504
drop if record_id==17862 //1 deleted - duplicate registration for record_id=17863
drop if record_id==17077 //1 deleted - duplicate registration for record_id=17078
drop if record_id==17064 //1 deleted - duplicate registration for record_id=17065
drop if record_id==18489 //1 deleted - duplicate registration for record_id=18490
replace agetxt=6 if record_id==18490
replace namematch=2 if record_id==18490
replace namematch=1 if record_id==18323|record_id==18343|record_id==19255|record_id==17135 /// 	 
						|record_id==17796|record_id==17000|record_id==17724	//8 changes

preserve
drop if nrn==.
sort nrn 
quietly by nrn : gen dupnrn = cond(_N==1,0,_n)
sort nrn record_id lname fname
count if dupnrn>0 //2
//list record_id namematch fname lname nrn dod sex age if dupnrn>0
restore
drop if record_id==18039 //1 deleted

** Final check for duplicates by name and dod 
sort lname fname dod
quietly by lname fname dod: gen dupdod = cond(_N==1,0,_n)
sort lname fname dod record_id
count if dupdod>0 //2 - diff.pt & namematch already=1
list record_id namematch fname lname nrn dod sex age if dupdod>0
count if dupdod>0 & namematch!=1 //0

count //2482

** Now generate a new variable which will select out all the potential cancers
gen cancer=.
label define cancer_lab 1 "cancer" 2 "not cancer", modify
label values cancer cancer_lab
label var cancer "cancer diagnoses"
label var record_id "Event identifier for registry deaths"

** searching cod1a for these terms
replace cod1a="99" if cod1a=="999" //0 changes
replace cod1b="99" if cod1b=="999" //0 changes
replace cod1c="99" if cod1c=="999" //0 changes
replace cod1d="99" if cod1d=="999" //0 changes
replace cod2a="99" if cod2a=="999" //0 changes
replace cod2b="99" if cod2b=="999" //0 changes
count if cod1c!="99" //0
count if cod1d!="99" //0
count if cod2a!="99" //0
count if cod2b!="99" //0
//ssc install unique
//ssc install distinct
** Create variable with combined CODs
gen coddeath=cod1a+" "+cod1b+" "+cod1c+" "+cod1d+" "+cod2a+" "+cod2b
replace coddeath=subinstr(coddeath,"99 ","",.) //2482
replace coddeath=subinstr(coddeath," 99","",.) //2482

** Identify cancer deaths using variable called 'cancer'
replace cancer=1 if regexm(coddeath, "CANCER") & cancer==. //297 changes
replace cancer=1 if regexm(coddeath, "TUMOUR") &  cancer==. //15 changes
replace cancer=1 if regexm(coddeath, "TUMOR") &  cancer==. //11 changes
replace cancer=1 if regexm(coddeath, "MALIGNANT") &  cancer==. //8 changes
replace cancer=1 if regexm(coddeath, "MALIGNANCY") &  cancer==. //20 changes
replace cancer=1 if regexm(coddeath, "NEOPLASM") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath, "CARCINOMA") &  cancer==. //200 changes
replace cancer=1 if regexm(coddeath, "CARCIMONA") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath, "CARINOMA") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath, "MYELOMA") &  cancer==. //23 changes
replace cancer=1 if regexm(coddeath, "LYMPHOMA") &  cancer==. //17 changes
replace cancer=1 if regexm(coddeath, "LYMPHOMIA") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath, "LYMPHONA") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath, "SARCOMA") &  cancer==. //5 changes
replace cancer=1 if regexm(coddeath, "TERATOMA") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath, "LEUKEMIA") &  cancer==. //5 changes
replace cancer=1 if regexm(coddeath, "LEUKAEMIA") &  cancer==. //2 changes
//replace cancer=1 if regexm(coddeath, "LUKAEMIA") &  cancer==. //discovered when checking lists below
//replace cancer=1 if regexm(coddeath, "LUKEMIA") &  cancer==. //discovered when checking lists below
//replace cancer=1 if regexm(coddeath, "ANAPLASTIC") &  cancer==. //discovered when checking lists below
//replace cancer=1 if regexm(coddeath, "CARCINOMIA") &  cancer==. //discovered when checking lists below
//replace cancer=1 if regexm(coddeath, "LYNPHOMA") &  cancer==. //discovered when checking lists below
//replace cancer=1 if regexm(coddeath, "MELOMA") &  cancer==. //discovered when checking lists below
//replace cancer=1 if regexm(coddeath, "GLIOBIASTOMA") &  cancer==. //discovered when checking lists below
//replace cancer=1 if regexm(coddeath, "SEZARY") &  cancer==. //discovered when checking lists below - include in future
//replace cancer=1 if regexm(coddeath, "MESOTHELIOMA") &  cancer==. //discovered when checking lists below - include in future
//replace cancer=1 if regexm(coddeath, "MYELODYP") &  cancer==. //discovered when checking lists below
replace cancer=1 if regexm(coddeath, "HEPATOMA") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath, "CARANOMA PROSTATE") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath, "MENINGIOMA") &  cancer==. //1 change
replace cancer=1 if regexm(coddeath, "MYELOSIS") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath, "MYELOFIBROSIS") &  cancer==. //1 change
replace cancer=1 if regexm(coddeath, "CYTHEMIA") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath, "CYTOSIS") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath, "BLASTOMA") &  cancer==. //3 changes
replace cancer=1 if regexm(coddeath, "METASTATIC") &  cancer==. //4 changes
replace cancer=1 if regexm(coddeath, "MASS") &  cancer==. //13 changes
replace cancer=1 if regexm(coddeath, "METASTASES") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath, "METASTASIS") &  cancer==. //1 change
replace cancer=1 if regexm(coddeath, "REFRACTORY") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath, "FUNGOIDES") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath, "HODGKIN") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath, "MELANOMA") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath,"MYELODYS") &  cancer==. //0 changes

** Strip possible leading/trailing blanks in cod1a
replace coddeath = rtrim(ltrim(itrim(coddeath))) //0 changes
replace cod1a = rtrim(ltrim(itrim(cod1a))) //0 changes
replace cod1b = rtrim(ltrim(itrim(cod1b))) //0 changes
replace cod1c = rtrim(ltrim(itrim(cod1c))) //0 changes
replace cod1d = rtrim(ltrim(itrim(cod1d))) //0 changes
replace cod2a = rtrim(ltrim(itrim(cod2a))) //0 changes
replace cod2b = rtrim(ltrim(itrim(cod2b))) //0 changes

tab cancer, missing

drop dodyear
gen dodyear=year(dod)
tab dodyear cancer,m

** Check that all cancer CODs and for MULTIPLE PRIMARY CODs for 2015 are eligible (use Stata browse)
sort coddeath record_id
order record_id coddeath
count if cancer==1 & inrange(record_id, 0, 18000)
//list coddeath if cancer==1 & inrange(record_id, 0, 17500)
** 312
count if cancer==1 & inrange(record_id, 18001, 20000)
//list coddeath if cancer==1 & inrange(record_id, 17501, 20000)
** 317
//list coddeath if cancer==1

** Replace 2015 cases that are not cancer according to eligibility SOP:
/*
	(1) After merge with CR5 data then may need to reassign some of below 
		deaths as CR5 data may indicate eligibility while COD may exclude
		(e.g. see record_id==15458)
	(2) use obsid to check for CODs that incomplete in Results window with 
		Data Editor in browse mode-copy and paste record_id below from here
*/
replace cancer=2 if ///
record_id==18388|record_id==19237|record_id==19173|record_id==18879|record_id==17681| ///
record_id==18647|record_id==19200|record_id==17037|record_id==18847|record_id==18994| ///
record_id==17655|record_id==17529|record_id==17126|record_id==16945|record_id==17014| ///
record_id==17348|record_id==16853|record_id==17156|record_id==16967|record_id==19083| ///
record_id==19017|record_id==17963|record_id==18814|record_id==18316|record_id==18178| ///
record_id==18355
//26 changes

** Check that all 2015 CODs that are not cancer for eligibility and for MULTIPLE PRIMARY CODs (use Stata browse)
sort coddeath record_id
order record_id coddeath
count if cancer==. & inrange(record_id, 0, 18000)
//list coddeath if cancer!=1 & inrange(record_id, 0, 17500)
** 896
count if cancer==. & inrange(record_id, 18001, 20000)
//list coddeath if cancer!=1 & inrange(record_id, 17501, 20000)
** 983
//list coddeath if cancer!=1

** Updates needed from above list - cancers found
replace cancer=1 if ///
record_id==17914|record_id==18073|record_id==18364|record_id==18818|record_id==18075| ///
record_id==17895|record_id==18909|record_id==18399|record_id==17975|record_id==18198| ///
record_id==17571|record_id==17815|record_id==18059
//13 changes

replace cancer=2 if cancer==. //1840 changes

** Create cod variable 
gen cod=.
label define cod_lab 1 "Dead of cancer" 2 "Dead of other cause" 3 "Not known" 4 "NA", modify
label values cod cod_lab
label var cod "COD categories"
replace cod=1 if cancer==1 //616 changes
replace cod=2 if cancer==2 //1840 changes
** one unknown causes of death in 2014 data - record_id 12323
replace cod=3 if coddeath=="99"|(regexm(coddeath,"INDETERMINATE")|regexm(coddeath,"UNDETERMINED")) //14 changes
tab cod ,m

** Change sex to match cancer dataset
tab sex ,m
rename sex sex_old
gen sex=1 if sex_old==2 //2467 changes
replace sex=2 if sex_old==1 //2587 changes
drop sex_old
label define sex_lab 1 "Female" 2 "Male", modify
label values sex sex_lab
label var sex "Sex"
tab sex ,m

********************
**   Formatting   **
** Place of Death **
********************
rename pod placeofdeath
gen pod=.

label define pod_lab 1 "QEH" 2 "At Home" 3 "Geriatric Hospital" ///
					 4 "Con/Nursing Home" 5 "Other" 6 "District Hospital" ///
					 7 "Psychiatric Hospital" 8 "Bayview Hospital" ///
					 9 "Sandy Crest" 10 "Bridgetown Port" ///
					 11 "Other/Hotel" 99 "ND", modify
label values pod pod_lab
label var pod "Place of Death from National Register"

replace pod=1 if regexm(placeofdeath, "ELIZABETH HOSP") & pod==. //0 changes
replace pod=1 if regexm(placeofdeath, "QUEEN ELZ") & pod==. //0 changes
replace pod=1 if regexm(placeofdeath, "QEH") & pod==. //1260 changes
replace pod=3 if regexm(placeofdeath, "GERIATRIC") & pod==. //69 changes
replace pod=5 if regexm(placeofdeath, "CHILDRENS HOME") & pod==. //0 chagnes
replace pod=4 if regexm(placeofdeath, "HOME") & pod==. //81 changes
replace pod=4 if regexm(placeofdeath, "ELDERLY") & pod==. //3 changes
replace pod=4 if regexm(placeofdeath, "SERENITY MANOR") & pod==. //0 changes
replace pod=4 if regexm(placeofdeath, "ADULT CARE") & pod==. //0 changes
replace pod=4 if regexm(placeofdeath, "AGE ASSIST") & pod==. //0 changes
replace pod=4 if regexm(placeofdeath, "SENIOR") & pod==. //3 changes
replace pod=4 if regexm(placeofdeath, "RETREAT") & pod==. //8 changes
replace pod=4 if regexm(placeofdeath, "RETIREMENT") & pod==. //0 changes
replace pod=4 if regexm(placeofdeath, "NURSING") & pod==. //4 changes
replace pod=5 if regexm(placeofdeath, "PRISON") & pod==. //0 changes
replace pod=5 if regexm(placeofdeath, "POLYCLINIC") & pod==. //2 changes
replace pod=5 if regexm(placeofdeath, "MINISTRIES") & pod==. //0 changes
replace pod=6 if regexm(placeofdeath, "STRICT HOSP") & pod==. //17 changes
replace pod=6 if regexm(placeofdeath, "GORDON CUMM") & pod==. //2 changes
replace pod=7 if regexm(placeofdeath, "PSYCHIATRIC HOSP") & pod==. //9 changes
replace pod=7 if regexm(placeofdeath, "PSYCIATRIC HOSP") & pod==. //1 change
replace pod=8 if regexm(placeofdeath, "BAYVIEW") & pod==. //27 changes
replace pod=9 if regexm(placeofdeath, "SANDY CREST") & pod==. //3 changes
replace pod=10 if regexm(placeofdeath, "BRIDGETOWN PORT") & pod==. //2 changes
replace pod=11 if regexm(placeofdeath, "HOTEL") & pod==. //6 changes
replace pod=99 if placeofdeath=="" & pod==. //0 changes

count if pod==. //985
//list record_id placeofdeath if pod==.
replace pod=2 if pod==. //985

//drop placeofdeath
tab pod ,m 

** Check NRN
//format nrn %10.0g
gen double nrn2=nrn
format nrn2 %15.0g
rename nrn2 natregno
tostring natregno ,replace
//gen nrn4=mod(nrn,10000) - extracting digits from NRN(number)
count if natregno!="" & natregno!="." & length(natregno)!=10 //11
//list record_id fname lname dod age agetxt nrn natregno if natregno!="" & natregno!="." & length(natregno)!=10
replace natregno=subinstr(natregno,"707","0707",.) if record_id==18843
replace natregno=subinstr(natregno,"4","0004",.) if record_id==18621
replace natregno=subinstr(natregno,"9","09",.) if record_id==18028
replace natregno=subinstr(natregno,"30","030",.) if record_id==18001
replace natregno=subinstr(natregno,"5","05",.) if record_id==19064
replace natregno=subinstr(natregno,"8","08",.) if record_id==17360
replace natregno=subinstr(natregno,"9","09",.) if record_id==17517
replace natregno=subinstr(natregno,"90","090",.) if record_id==17587
replace natregno=subinstr(natregno,"64","93",.) if record_id==17587
replace natregno=subinstr(natregno,"9","09",.) if record_id==17960
replace natregno=subinstr(natregno,"111","000111",.) if record_id==18870
replace natregno=subinstr(natregno,"9","09",.) if record_id==18428
count if natregno!="" & natregno!="." & length(natregno)!=10 //0
//list record_id fname lname natregno age agetxt if age>100

** Check dob** Creating dob variable as none in national death data
** perform data cleaning on the age variable
order record_id natregno age
count if natregno==""|natregno=="." //117
gen tempvarn=6 if natregno==""|natregno=="."
gen yr = substr(natregno,1,1) if tempvarn!=6
gen yr1=. if tempvarn!=6
replace yr1 = 20 if yr=="0"
replace yr1 = 19 if yr!="0"
replace yr1 = 99 if natregno=="99"
order record_id nrn age yr yr1
** Check age and yr1 in Stata browse
//list record_id nrn age yr1 if yr1==20
** Initially need to run this code separately from entire dofile to determine which nrnyears should be '19' instead of '20' depending on age, e.g. for age 107 nrnyear=19
replace yr1 = 19 if record_id==17360
replace yr1 = 19 if record_id==17517
replace yr1 = 19 if record_id==17587
replace yr1 = 19 if record_id==17960
gen nrndob = substr(natregno,1,6) 
destring nrndob, replace
format nrndob %06.0f
nsplit nrndob, digits(2 2 2) gen(dyear month day)
format dyear month day %02.0f
tostring yr1, replace
gen year2 = string(dyear,"%02.0f")
gen nrnyr = substr(yr1,1,2) + substr(year2,1,2)
destring nrnyr, replace
sort nrndob
gen nrn1=mdy(month, day, nrnyr)
format nrn1 %dD_m_CY
rename nrn1 dob
gen age2 = (dod - dob)/365.25
gen ageyrs=int(age2)
sort record_id
list record_id fname lname address age ageyrs nrn natregno dob dod if tempvarn!=6 & age!=ageyrs, string(20) //check against electoral list
count if tempvarn!=6 & age!=ageyrs //0
drop day month dyear nrnyr yr yr1 nrndob age2 ageyrs tempvarn

** Check age
gen age2 = (dod - dob)/365.25
gen checkage2=int(age2)
drop age2
count if dob!=. & dod!=. & age!=checkage2 //0
//list pid dot dob age checkage2 cr5id if dob!=. & dot!=. & age!=checkage2 //0 correct
replace age=checkage2 if dob!=. & dod!=. & age!=checkage2 //0 changes

** Check no missing dxyr so this can be used in analysis
tab dodyear ,m 

count if dodyear!=year(dod) //0
//list pid record_id dod dodyear if dodyear!=year(dod)
replace dodyear=year(dod) if dodyear!=year(dod) //0 changes

label data "BNR MORTALITY data 2015"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version04\3-output\2015_prep mort_ALL" ,replace
note: TS This dataset is used for analysis of age-standardized mortality rates
note: TS This dataset includes all 2015 CODs

*******************
** Check for MPs **
**   in CODs     **
*******************
count //2482

//list record_id
//list cod1a
tab cancer ,m //616 cancer CODs
** MPs found above when assigning cancer variable in checking causes of death
** Create duplicate observations for MPs in CODs
expand=2 if record_id==18753, gen (dupobs1)
expand=2 if record_id==17916, gen (dupobs2)
expand=2 if record_id==18568, gen (dupobs3)
//(GIST not stated as malignant so ineligible?? - yes, see CR5db pid 20130343)
expand=2 if record_id==18693, gen (dupobs4)
expand=2 if record_id==18669, gen (dupobs5)
expand=2 if record_id==19201, gen (dupobs6)
expand=2 if record_id==16897, gen (dupobs7)
expand=2 if record_id==17461, gen (dupobs8)
expand=2 if record_id==16817, gen (dupobs9)
expand=2 if record_id==16979, gen (dupobs10)
expand=2 if record_id==16883, gen (dupobs11)
expand=2 if record_id==18027, gen (dupobs12)
expand=2 if record_id==18845, gen (dupobs13)
expand=2 if record_id==19189, gen (dupobs14)
expand=2 if record_id==18198, gen (dupobs15) 
//M9811(9) vs M9837(10) and M9875(8)
//pid 20130770 CML in 2013 that transformed to either T-ALL or B-ALL in 2015 COD states C-CELL!
//M9811 (B-ALL) chosen as research shows "With few exceptions, Ph-positive ALL patients are diagnosed with B-ALL "
//https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4896164/
display `"{browse "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4896164/":Ph+ALL}"'

count //2497

** Create variables to identify patients vs tumours
gen ptrectot=.
replace ptrectot=1 if dupobs1==0|dupobs2==0|dupobs3==0|dupobs4==0 ///
					 |dupobs5==0|dupobs6==0|dupobs7==0|dupobs8==0 ///
					 |dupobs9==0|dupobs10==0|dupobs11==0|dupobs12==0 ///
					 |dupobs13==0|dupobs14==0|dupobs15==0 //2497 changes
replace ptrectot=2 if dupobs1>0|dupobs2>0|dupobs3>0|dupobs4>0 ///
					 |dupobs5>0|dupobs6>0|dupobs7>0|dupobs8>0 ///
					 |dupobs9>0|dupobs10>0|dupobs11>0|dupobs12>0 ///
					 |dupobs13>0|dupobs14>0|dupobs15>0 //15 changes
label define ptrectot_lab 1 "COD with single event" 2 "COD with multiple events" , modify
label values ptrectot ptrectot_lab

tab ptrectot ,m

** Now create id in this dataset so when merging icd10 for siteiarc variable at end of this dofile
gen did="T1" if ptrectot==1
replace did="T2" if ptrectot==2 //15 changes

***********************************
** 1.4 Number of cases by age-group
***********************************
** Age labelling
gen age5 = recode(age,4,9,14,19,24,29,34,39,44,49,54,59,64,69,74,79,84,200)
recode age5 4=1 9=2 14=3 19=4 24=5 29=6 34=7 39=8 44=9 49=10 54=11 59=12 64=13 /// 
			69=14 74=15 79=16 84=17 200=18
label define age5_lab 	1 "0-4"	   2 "5-9"    3 "10-14"		///
						4 "15-19"  5 "20-24"  6 "25-29"		///
						7 "30-34"  8 "35-39"  9 "40-44"		///
						10 "45-49" 11 "50-54" 12 "55-59"	///
						13 "60-64" 14 "65-69" 15 "70-74"	///
						16 "75-79" 17 "80-84" 18 "85 & over", modify
label values age5 age5_lab

gen age_10 = recode(age5,3,5,7,9,11,13,15,17,200)
recode age_10 3=1 5=2 7=3 9=4 11=5 13=6 15=7 17=8 200=9
label define age_10_lab 	1 "0-14"   2 "15-24"  3 "25-34"	///
							4 "35-44"  5 "45-54"  6 "55-64"	///
							7 "65-74"  8 "75-84"  9 "85 & over" , modify
label values age_10 age_10_lab
sort sex age_10

tab age_10 sex ,m
** None missing age or sex

************************
** Creating IARC Site **
************************
count //2497
tab cancer ,m 
drop if cancer!=1 //1866 deleted

** Note: Although siteiarc doesn't need sub-site, the specific icd10 code was used, where applicable
display `"{browse "https://icd.who.int/browse10/2015/en#/C09":ICD10,v2015}"'

** Use Stata browse instead of lists
order record_id coddeath

gen icd10=""
count if regexm(coddeath,"LIP") & icd10=="" //2 - not lip so no replace
//list record_id coddeath if regexm(coddeath,"LIP"),string(120)

count if regexm(coddeath,"TONGUE") & icd10=="" //5 - all tongue, NOS
//list record_id coddeath if regexm(coddeath,"TONGUE"),string(120)
replace icd10="C029" if regexm(coddeath,"TONGUE") & icd10=="" //5 changes

count if regexm(coddeath,"MOUTH") & icd10=="" //0
//list record_id coddeath if regexm(coddeath,"MOUTH"),string(120)

count if regexm(coddeath,"SALIVARY") & icd10=="" //0
//list record_id coddeath if regexm(coddeath,"SALIVARY"),string(120)

count if regexm(coddeath,"TONSIL") & icd10=="" //1
//list record_id coddeath if regexm(coddeath,"TONSIL"),string(120)
replace icd10="C099" if regexm(coddeath,"TONSIL") & icd10=="" //1 change

count if regexm(coddeath,"OROPHARYNX") & icd10=="" //0
//list record_id coddeath if regexm(coddeath,"OROPHARYNX"),string(120)

count if regexm(coddeath,"NASOPHARYNX") & icd10=="" //0
//list record_id coddeath if regexm(coddeath,"NASOPHARYNX"),string(120)

count if regexm(coddeath,"HYPOPHARYNX") & icd10=="" //0
//list record_id coddeath if regexm(coddeath,"HYPOPHARYNX"),string(120)

count if (regexm(coddeath,"PHARYNX")|regexm(coddeath,"PHARNYX")) & icd10=="" //2
//list record_id coddeath if (regexm(coddeath,"PHARYNX")|regexm(coddeath,"PHARNYX")) & icd10=="",string(120)
replace icd10="C140" if record_id==17926
replace icd10="C148" if record_id==18057

count if (regexm(coddeath,"OESOPHAG")|regexm(coddeath,"ESOPHAG")) & icd10=="" //10
replace icd10="C159" if (regexm(coddeath,"OESOPHAG")|regexm(coddeath,"ESOPHAG")) & icd10=="" //10 changes
replace icd10="C159" if record_id==17149

count if (regexm(coddeath,"STOMACH")|regexm(coddeath,"GASTR"))  & !(strmatch(strupper(coddeath), "*GASTROINTESTINAL BLEED*"))  & !(strmatch(strupper(coddeath), "*GASTROINTESTINAL HAEMORR*"))  & !(strmatch(strupper(coddeath), "*GASTROENTER*")) & icd10=="" //37
replace icd10="C169" if (regexm(coddeath,"STOMACH")|regexm(coddeath,"GASTR"))  & !(strmatch(strupper(coddeath), "*GASTROINTESTINAL BLEED*"))  & !(strmatch(strupper(coddeath), "*GASTROINTESTINAL HAEMORR*"))  & !(strmatch(strupper(coddeath), "*GASTROENTER*")) & icd10=="" //33 changes
replace icd10="C859" if record_id==17446 //gastric lymphoma
replace icd10="C269" if record_id==17585|record_id==17966|record_id==19107 //gastronintestinal malignancy

count if (regexm(coddeath,"DUODEN")|regexm(coddeath,"JEJUN")|regexm(coddeath,"ILEUM")|regexm(coddeath,"SMALL")) & !(strmatch(strupper(coddeath), "*SMALL CEL*")) & !(strmatch(strupper(coddeath), "*LARYNGEAL*")) & icd10=="" //3
replace coddeath=subinstr(coddeath," H"," L",.) if record_id==17901 //see CR5db pid 20155189
replace cod1a=subinstr(cod1a," H"," L",.) if record_id==17901
replace icd10="C179" if (regexm(coddeath,"DUODEN")|regexm(coddeath,"JEJUN")|regexm(coddeath,"ILEUM")|regexm(coddeath,"SMALL")) & !(strmatch(strupper(coddeath), "*SMALL CEL*")) & !(strmatch(strupper(coddeath), "*LARYNGEAL*")) & icd10=="" //2 changes
replace icd10="C170" if record_id==19066 //1 change
replace icd10="C172" if record_id==17310 //1 change

count if (regexm(coddeath,"CECUM")|regexm(coddeath,"APPEND")|regexm(coddeath,"COLON")) & !(strmatch(strupper(coddeath), "*COLONIC POLYPS*")) & icd10=="" //78
replace icd10="C189" if (regexm(coddeath,"CECUM")|regexm(coddeath,"APPEND")|regexm(coddeath,"COLON")) & !(strmatch(strupper(coddeath), "*COLONIC POLYPS*")) & icd10=="" //78 changes
replace icd10="C187" if record_id==16864 //1 change
replace icd10="C186" if record_id==18753 //1 change

count if (regexm(coddeath,"COLORECTAL")|regexm(coddeath,"RECTO")) & icd10=="" //8
replace icd10="C19" if (regexm(coddeath,"COLORECT")|regexm(coddeath,"RECTO")) & icd10=="" //8 changes

count if (regexm(coddeath,"RECTUM")|regexm(coddeath,"RECTAL")) & !(strmatch(strupper(coddeath), "*ANORECT*")) & icd10=="" //16
replace icd10="C20" if (regexm(coddeath,"RECTUM")|regexm(coddeath,"RECTAL")) & !(strmatch(strupper(coddeath), "*ANORECT*")) & icd10=="" //16 changes

count if (regexm(coddeath,"ANUS")|regexm(coddeath,"ANORECT")|regexm(coddeath,"ANAL")) & icd10=="" //2
replace icd10="C218" if (regexm(coddeath,"ANUS")|regexm(coddeath,"ANORECT")|regexm(coddeath,"ANAL")) & icd10=="" //2 changes

count if (regexm(coddeath,"LIVER")|regexm(coddeath,"BILE")|regexm(coddeath,"HEPATO")) & !(strmatch(strupper(coddeath), "*CHOLANGIOCAR*")) & icd10=="" //15
replace icd10="C800" if record_id==19076|record_id==18222|record_id==17843
replace icd10="C220" if record_id==17665|record_id==18381
replace icd10="C229" if record_id==17761|record_id==18531|record_id==17069
replace icd10="C249" if record_id==17868

count if regexm(coddeath,"CHOLANGIO") & icd10=="" //3
replace icd10="C221" if regexm(coddeath,"CHOLANGIO") & icd10=="" //3 changes

count if (regexm(coddeath,"GALLBLAD")|regexm(coddeath,"GALL BLAD")) & icd10=="" //4
replace icd10="C23" if (regexm(coddeath,"GALLBLAD")|regexm(coddeath,"GALL BLAD")) & icd10=="" //4 changes

count if regexm(coddeath,"BILIARY") & icd10=="" //0

count if (regexm(coddeath,"PANCREA") & regexm(coddeath,"HEAD")) & icd10=="" //3
replace icd10="C250" if (regexm(coddeath,"PANCREA") & regexm(coddeath,"HEAD")) & icd10=="" //3 changes
count if regexm(coddeath,"PANCREA") & icd10=="" //27
replace icd10="C259" if regexm(coddeath,"PANCREA") & icd10=="" //27 changes

count if (regexm(coddeath,"NASAL")|regexm(coddeath,"EAR")) & icd10=="" //14-none nasal/ear so no replace

count if regexm(coddeath,"SINUS") & icd10=="" //1-not sinus so no replace

count if (regexm(coddeath,"LARYNX")|regexm(coddeath,"LARYNG")|regexm(coddeath,"GLOTTI")|regexm(coddeath,"VOCAL")) & icd10=="" //3
replace icd10="C329" if (regexm(coddeath,"LARYNX")|regexm(coddeath,"LARYNG")|regexm(coddeath,"GLOTTI")|regexm(coddeath,"VOCAL")) & icd10=="" //3 changes
replace icd10="C320" if record_id==18064

count if regexm(coddeath,"TRACHEA") & icd10=="" //0

count if (regexm(coddeath,"LUNG")|regexm(coddeath,"BRONCH")) & icd10=="" //39
replace icd10="C349" if (regexm(coddeath,"LUNG")|regexm(coddeath,"BRONCH")) & icd10=="" //39 changes
replace icd10="C809" if record_id==19100
replace icd10="C719" if record_id==18722
replace icd10="C509" if record_id==18424|record_id==18106|record_id==19042
replace icd10="C541" if record_id==18974
replace icd10="C64" if record_id==19225
replace icd10="C900" if record_id==18702
replace icd10="C419" if record_id==18689
replace icd10="C61" if record_id==19256|record_id==18195|record_id==18863

count if regexm(coddeath,"THYMUS") & icd10=="" //0

count if (regexm(coddeath,"HEART")|regexm(coddeath,"MEDIASTIN")|regexm(coddeath,"PLEURA")) & icd10=="" //15-none found so no replace
replace icd10="C809" if record_id==16956 //C782 code for malignant pleural effusion, NOS (met code) ?eligibility so change to PSU

count if (regexm(coddeath,"BONE")|regexm(coddeath,"OSTEO")|regexm(coddeath,"CARTILAGE")) & icd10=="" //9-none found so no replace
replace icd10="C439" if record_id==18148

count if (regexm(coddeath,"SKIN")|regexm(coddeath,"MELANOMA")|regexm(coddeath,"SQUAMOUS")|regexm(coddeath,"BASAL")) & icd10=="" //11
replace icd10="C439" if (regexm(coddeath,"SKIN")|regexm(coddeath,"MELANOMA")|regexm(coddeath,"SQUAMOUS")|regexm(coddeath,"BASAL")) & icd10=="" //11 changes
replace icd10="C445" if record_id==17780|record_id==18228
replace icd10="C447" if record_id==17989
replace icd10="C52" if record_id==16979 & ptrectot==1
replace icd10="C800" if record_id==16979 & ptrectot==2
replace icd10="C809" if record_id==17070|record_id==17684
replace icd10="C439" if record_id==16835|record_id==17350 //0 changes
replace icd10="C140" if record_id==17926

count if (regexm(coddeath,"MESOTHELIOMA")|regexm(coddeath,"KAPOSI")|regexm(coddeath,"NERVE")|regexm(coddeath,"PERITON")) & icd10=="" //2
replace icd10="C459" if record_id==17975
replace icd10="C482" if record_id==17671

count if regexm(coddeath,"BREAST") & icd10=="" //60
//list record_id coddeath if regexm(coddeath,"BREAST"),string(120)
replace icd10="C509" if regexm(coddeath,"BREAST") & icd10=="" //60 changes

count if regexm(coddeath,"VULVA") & icd10=="" //2
replace icd10="C519" if regexm(coddeath,"VULVA") & icd10=="" //2 changes

count if regexm(coddeath,"VAGINA") & icd10=="" //2
replace icd10="C52" if regexm(coddeath,"VAGINA") & icd10=="" //2 changes
replace icd10="C541" if record_id==18350

count if (regexm(coddeath,"CERVICAL")|regexm(coddeath,"CERVIX")) & icd10=="" //16
replace icd10="C539" if (regexm(coddeath,"CERVICAL")|regexm(coddeath,"CERVIX")) & icd10=="" //16 changes

count if (regexm(coddeath,"ENDOMETRI")|regexm(coddeath,"CORPUS")) & icd10=="" //20
replace icd10="C541" if (regexm(coddeath,"ENDOMETRI")|regexm(coddeath,"CORPUS")) & icd10=="" //20 changes

count if (regexm(coddeath,"UTERINE")|regexm(coddeath,"UTERUS")) & icd10=="" //9
replace icd10="C55" if (regexm(coddeath,"UTERINE")|regexm(coddeath,"UTERUS")) & icd10=="" //9 changes

count if (regexm(coddeath,"OVARY")|regexm(coddeath,"OVARIAN")) & icd10=="" //13
replace icd10="C56" if (regexm(coddeath,"OVARY")|regexm(coddeath,"OVARIAN")) & icd10=="" //13 changes

count if (regexm(coddeath,"FALLOPIAN")|regexm(coddeath,"FEMALE")) & icd10=="" //0

count if (regexm(coddeath,"PENIS")|regexm(coddeath,"PENILE")) & icd10=="" //0

count if regexm(coddeath,"PROSTATE") & icd10=="" //94
replace icd10="C61" if regexm(coddeath,"PROSTATE") & icd10=="" //94 changes

count if (regexm(coddeath,"TESTIS")|regexm(coddeath,"TESTES")) & icd10=="" //0

count if (regexm(coddeath,"SCROT")|regexm(coddeath,"MALE")) & icd10=="" //0

count if (regexm(coddeath,"KIDNEY")|regexm(coddeath,"RENAL")) & icd10=="" //16
replace icd10="C64" if (regexm(coddeath,"KIDNEY")|regexm(coddeath,"RENAL")) & icd10=="" //16 changes
replace icd10="C900" if record_id==17216|record_id==19290|record_id==18303 //3 changes
replace icd10="C809" if record_id==19056
replace icd10="C679" if record_id==16804
replace icd10="C859" if record_id==18217|record_id==18293 //2 changes
replace icd10="C61" if record_id==17714

count if (regexm(coddeath,"BLADDER")|regexm(coddeath,"URIN")) & icd10=="" //12
replace icd10="C679" if (regexm(coddeath,"BLADDER")|regexm(coddeath,"URIN")) & icd10=="" //12 changes
replace icd10="D469" if record_id==18059
replace icd10="C819" if record_id==18639

count if (regexm(coddeath,"EYE")|regexm(coddeath,"RETINA")|regexm(coddeath,"NEURO")) & icd10=="" //5
replace icd10="C699" if (regexm(coddeath,"EYE")|regexm(coddeath,"RETINA")|regexm(coddeath,"NEURO")) & icd10=="" //5 changes
replace icd10="C809" if record_id==19088|record_id==17793|record_id==17145 //3 changes
replace icd10="C800" if record_id==19112

count if (regexm(coddeath,"ASTROCY")|regexm(coddeath,"MULTIFORME")|regexm(coddeath,"BRAIN")) & icd10=="" //8
replace icd10="C719" if (regexm(coddeath,"ASTROCY")|regexm(coddeath,"MULTIFORME")|regexm(coddeath,"BRAIN")) & icd10=="" //8 changes

count if (regexm(coddeath,"THYROID")|regexm(coddeath,"ADRENAL")|regexm(coddeath,"ENDOCRI")) & icd10=="" //6
replace icd10="C73" if (regexm(coddeath,"THYROID")|regexm(coddeath,"ADRENAL")|regexm(coddeath,"ENDOCRI")) & icd10=="" //6 changes
replace icd10="C900" if record_id==19062

count if (regexm(coddeath,"UNKNOWN")|regexm(coddeath,"CULT")) & icd10=="" //9
replace icd10="C800" if (regexm(coddeath,"UNKNOWN")|regexm(coddeath,"CULT")) & icd10=="" //9 changes

count if (regexm(coddeath,"HODGKIN") & regexm(coddeath,"NON")) & icd10=="" //8
replace icd10="C859" if (regexm(coddeath,"HODGKIN") & regexm(coddeath,"NON")) & icd10=="" //8 changes
replace icd10="C910" if record_id==17476

count if regexm(coddeath,"HODGKIN") & icd10=="" //3
replace icd10="C819" if regexm(coddeath,"HODGKIN") & icd10=="" //3 changes

count if (regexm(coddeath,"FOLLICUL") & regexm(coddeath,"LYMPH")) & icd10=="" //0

count if (regexm(coddeath,"MULTIPLE") & regexm(coddeath,"OMA")) & icd10=="" //19
replace icd10="C900" if (regexm(coddeath,"MULTIPLE") & regexm(coddeath,"OMA")) & icd10=="" //19 changes

count if regexm(coddeath,"PLASMACYTOMA") & icd10=="" //1
replace icd10="C903" if regexm(coddeath,"PLASMACYTOMA") & icd10=="" //1 change

count if regexm(coddeath,"SEZARY") & icd10=="" //1
replace icd10="C841" if regexm(coddeath,"SEZARY") & icd10=="" //1 change

count if (regexm(coddeath,"LYMPH")|regexm(coddeath,"EMIA")|regexm(coddeath,"PHOMA")) & icd10=="" //22
replace icd10="C910" if record_id==18428|record_id==18198
replace icd10="C959" if record_id==18407|record_id==17699|record_id==17282
replace icd10="C915" if record_id==17815
replace icd10="C579" if record_id==18954
replace icd10="C800" if record_id==18989
replace icd10="C911" if record_id==17914
replace icd10="D469" if record_id==18970|record_id==17000
replace icd10="C848" if record_id==17845
replace icd10="C866" if record_id==16907
replace icd10="C920" if record_id==18182|record_id==16859
replace icd10="C833" if record_id==18519
replace icd10="C865" if record_id==18552
replace icd10="C859" if record_id==17998|record_id==18075
replace icd10="C809" if record_id==19281
replace icd10="C921" if record_id==18787
replace icd10="C924" if record_id==17571

count if icd10=="" //40
replace icd10="C159" if record_id==18215
replace icd10="C541" if record_id==17762
replace icd10="D474" if record_id==18903
replace icd10="C349" if record_id==17385
replace icd10="C180" if record_id==18451
replace icd10="C189" if record_id==16808
replace icd10="C321" if record_id==18058
replace icd10="C900" if record_id==18893|record_id==17713
replace icd10="C109" if record_id==18672
replace icd10="C23" if record_id==17656
replace icd10="C380" if record_id==19188
replace icd10="C490" if record_id==18849
replace icd10="C61" if record_id==17718
replace icd10="D469" if record_id==18498
replace icd10="C444" if record_id==18302
replace icd10="C221" if record_id==18585
replace icd10="C969" if record_id==17635
replace icd10="C809" if icd10=="" //22 changes

tab icd10 ,m

** Check icd10 for MP CODs
duplicates tag record_id, gen(dup_id)
sort record_id
//list record_id icd10 coddeath ptrectot if dup_id>0, nolabel sepby(record_id) string(120)
replace icd10="C800" if record_id==16817 & ptrectot==2 //1 change
replace icd10="C56" if record_id==16883 & ptrectot==1 //1 change
replace icd10="C61" if record_id==16897 & ptrectot==2 //1 change
replace icd10="C900" if record_id==17461 & ptrectot==1 //1 change
replace icd10="C61" if record_id==17916 & ptrectot==1 //1 change
replace icd10="C509" if record_id==18027 & ptrectot==2 //1 change
replace icd10="C921" if record_id==18198 & ptrectot==2 //1 change
replace icd10="C509" if record_id==18568 & ptrectot==2 //1 change
replace icd10="C64" if record_id==18669 & ptrectot==2 //1 change
replace icd10="C61" if record_id==18693 & ptrectot==1 //1 change
replace icd10="C61" if record_id==18753 & ptrectot==2 //1 change
replace icd10="C412" if record_id==18845 & ptrectot==2 //1 change
replace icd10="C61" if record_id==19189 & ptrectot==1 //1 change
replace icd10="C541" if record_id==19201 & ptrectot==2 //1 change

tab icd10 ,m

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
59 "Myeloproliferative disorders (MPD)" 60 "Myselodysplastic syndromes (MDS)" ///
61 "Other and unspecified (O&U)" ///
62 "All sites(ALL)" 63 "All sites but skin (ALLbC44)" ///
64 "D069: CIN 3"
label var siteiarc "IARC CI5-XI sites"
label values siteiarc siteiarc_lab

replace siteiarc=1 if regexm(icd10,"C00") //0 changes
replace siteiarc=2 if (regexm(icd10,"C01")|regexm(icd10,"C02")) //5 changes
replace siteiarc=3 if (regexm(icd10,"C03")|regexm(icd10,"C04")|regexm(icd10,"C05")|regexm(icd10,"C06")) //0 changes
replace siteiarc=4 if (regexm(icd10,"C07")|regexm(icd10,"C08")) //0 changes
replace siteiarc=5 if regexm(icd10,"C09") //1 change
replace siteiarc=6 if regexm(icd10,"C10") //1 change
replace siteiarc=7 if regexm(icd10,"C11") //0 changes
replace siteiarc=8 if (regexm(icd10,"C12")|regexm(icd10,"C13")) //0 changes
replace siteiarc=9 if regexm(icd10,"C14") //2 changes
replace siteiarc=10 if regexm(icd10,"C15") //12 changes
replace siteiarc=11 if regexm(icd10,"C16") //31 changes
replace siteiarc=12 if regexm(icd10,"C17") //4 changes
replace siteiarc=13 if regexm(icd10,"C18") //75 changes
replace siteiarc=14 if (regexm(icd10,"C19")|regexm(icd10,"C20")) //23 changes
replace siteiarc=15 if regexm(icd10,"C21") //2 changes
replace siteiarc=16 if regexm(icd10,"C22") //9 changes
replace siteiarc=17 if (regexm(icd10,"C23")|regexm(icd10,"C24")) //6 changes
replace siteiarc=18 if regexm(icd10,"C25") //29 changes
replace siteiarc=19 if (regexm(icd10,"C30")|regexm(icd10,"C31")) //0 changes
replace siteiarc=20 if regexm(icd10,"C32") //1 change
replace siteiarc=21 if (regexm(icd10,"C33")|regexm(icd10,"C34")) //28 changes
replace siteiarc=22 if (regexm(icd10,"C37")|regexm(icd10,"C38")) //1 change
replace siteiarc=23 if (regexm(icd10,"C40")|regexm(icd10,"C41")) //2 changes
replace siteiarc=24 if regexm(icd10,"C43") //3 changes
replace siteiarc=25 if regexm(icd10,"C44") //4 changes
replace siteiarc=26 if regexm(icd10,"C45") //1 change
replace siteiarc=27 if regexm(icd10,"C46") //0 changes
replace siteiarc=28 if (regexm(icd10,"C47")|regexm(icd10,"C49")) //1 change
replace siteiarc=29 if regexm(icd10,"C50") //64 changes
replace siteiarc=30 if regexm(icd10,"C51") //2 changes
replace siteiarc=31 if regexm(icd10,"C52") //2 changes
replace siteiarc=32 if regexm(icd10,"C53") //15 changes
replace siteiarc=33 if regexm(icd10,"C54") //24 changes
replace siteiarc=34 if regexm(icd10,"C55") //9 changes
replace siteiarc=35 if regexm(icd10,"C56") //1 change
replace siteiarc=36 if regexm(icd10,"C57") //1 change
replace siteiarc=37 if regexm(icd10,"C58") //0 changes
replace siteiarc=38 if regexm(icd10,"C60") //0 changes
replace siteiarc=39 if regexm(icd10,"C61") //104 changes
replace siteiarc=40 if regexm(icd10,"C62") //0 changes
replace siteiarc=41 if regexm(icd10,"C63") //0 changes
replace siteiarc=42 if regexm(icd10,"C64") //10 changes
replace siteiarc=43 if regexm(icd10,"C65") //0 changes
replace siteiarc=44 if regexm(icd10,"C66") //0 changes
replace siteiarc=45 if regexm(icd10,"C67") //11 changes
replace siteiarc=46 if regexm(icd10,"C68") //0 changes
replace siteiarc=47 if regexm(icd10,"C69") //1 change
replace siteiarc=48 if (regexm(icd10,"C70")|regexm(icd10,"C71")|regexm(icd10,"C72")) //9 changes
replace siteiarc=49 if regexm(icd10,"C73") //5 changes
replace siteiarc=50 if regexm(icd10,"C74") //0 changes
replace siteiarc=51 if regexm(icd10,"C75") //0 changes
replace siteiarc=52 if regexm(icd10,"C81") //3 changes
replace siteiarc=53 if (regexm(icd10,"C82")|regexm(icd10,"C83")|regexm(icd10,"C84")|regexm(icd10,"C85")|regexm(icd10,"C86")|regexm(icd10,"C96")) //17 changes
replace siteiarc=54 if regexm(icd10,"C88") //0 changes
replace siteiarc=55 if regexm(icd10,"C90") //27 changes
replace siteiarc=56 if regexm(icd10,"C91") //5 changes
replace siteiarc=57 if (regexm(icd10,"C92")|regexm(icd10,"C93")|regexm(icd10,"C94")) //5 changes
replace siteiarc=58 if regexm(icd10,"C95") //3 changes
replace siteiarc=59 if regexm(icd10,"D47") //1 change
replace siteiarc=60 if regexm(icd10,"D46") //4 changes
replace siteiarc=61 if (regexm(icd10,"C26")|regexm(icd10,"C39")|regexm(icd10,"C48")|regexm(icd10,"C76")|regexm(icd10,"C80")) //50 changes
**replace siteiarc=62 if siteiarc<62
**replace siteiarc=63 if siteiarc<62 & siteiarc!=25
replace siteiarc=64 if regexm(icd10,"D06") //0 changes - no CIN 3 in death data

tab siteiarc ,m //none missing

gen allsites=1 if siteiarc<62 //651 changes
label var allsites "All sites (ALL)"

gen allsitesnoC44=1 if siteiarc<62 & siteiarc!=25 //4 missing so 4=C44 (NMSCs)
label var allsitesnoC44 "All sites but skin (ALLbC44)"

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
replace siteiarchaem=1 if icd10=="C859"|icd10=="C851"|icd10=="C826"|icd10=="C969" //12 changes
replace siteiarchaem=2 if icd10=="C819"|icd10=="C814"|icd10=="C813"|icd10=="C812"|icd10=="C811"|icd10=="C810" //3 changes
replace siteiarchaem=3 if icd10=="C830"|icd10=="C831"|icd10=="C833"|icd10=="C837"|icd10=="C838"|icd10=="C859"|icd10=="C852"|icd10=="C829"|icd10=="C821"|icd10=="C820"|icd10=="C822"|icd10=="C420"|icd10=="C421"|icd10=="C424"|icd10=="C884"|regexm(icd10,"C77") //12 changes
replace siteiarchaem=4 if icd10=="C840"|icd10=="C841"|icd10=="C844"|icd10=="C865"|icd10=="C863"|icd10=="C848"|icd10=="C838"|icd10=="C846"|icd10=="C861"|icd10=="C862"|icd10=="C866"|icd10=="C860" //4 changes
replace siteiarchaem=5 if icd10=="C845"|icd10=="C835" //0 changes
replace siteiarchaem=6 if icd10=="C903"|icd10=="C900"|icd10=="C901"|icd10=="C902"|icd10=="C833" //28 changes
replace siteiarchaem=7 if icd10=="D470"|icd10=="C962"|icd10=="C943" //0 changes
replace siteiarchaem=8 if icd10=="C968"|icd10=="C966"|icd10=="C964" //0 changes
replace siteiarchaem=9 if icd10=="C889"|icd10=="C880"|icd10=="C882"|icd10=="C883"|icd10=="D472"|icd10=="C838"|icd10=="C865"|icd10=="D479"|icd10=="D477" //1 change
replace siteiarchaem=10 if icd10=="C959"|icd10=="C950" //3 changes
replace siteiarchaem=11 if icd10=="C910"|icd10=="C919"|icd10=="C911"|icd10=="C918"|icd10=="C915"|icd10=="C917"|icd10=="C913"|icd10=="C916" //5 changes
replace siteiarchaem=12 if icd10=="C940"|icd10=="C929"|icd10=="C920"|icd10=="C921"|icd10=="C924"|icd10=="C925"|icd10=="C947"|icd10=="C922"|icd10=="C930"|icd10=="C928"|icd10=="C926"|icd10=="D471"|icd10=="C927"|icd10=="C942"|icd10=="C946"|icd10=="C923"|icd10=="C944"|icd10=="C914" //5 changes
replace siteiarchaem=13 if icd10=="C931"|icd10=="C933"|icd10=="C947" //0 changes
replace siteiarchaem=14 if icd10=="D45"|icd10=="D471"|icd10=="D474"|icd10=="D473"|icd10=="D475"|icd10=="C927"|icd10=="C967" //1 change
replace siteiarchaem=15 if icd10=="D477"|icd10=="D471" //0 changes
replace siteiarchaem=16 if icd10=="D465"|icd10=="D466"|icd10=="D467"|icd10=="D469" //4 changes

tab siteiarchaem ,m //593 missing - correct!
count if (siteiarc>51 & siteiarc<59) & siteiarchaem==. //0

** Create ICD-10 groups according to analysis tables in CR5 db (added after analysis dofiles 4,6)
gen sitecr5db=.
label define sitecr5db_lab ///
1 "Mouth & pharynx (C00-14)" ///
2 "Oesophagus (C15)" ///
3 "Stomach (C16)" ///
4 "Colon, rectum, anus (C18-21)" ///
5 "Liver (C22)" ///
6 "Pancreas (C25)" ///
7 "Larynx (C32)" ///
8 "Lung, trachea, bronchus (C33-34)" ///
9 "Melanoma of skin (C43)" ///
10 "Breast (C50)" ///
11 "Cervix (C53)" ///
12 "Corpus & Uterus NOS (C54-55)" ///
13 "Ovary & adnexa (C56)" ///
14 "Prostate (C61)" ///
15 "Testis (C62)" ///
16 "Kidney & urinary NOS (C64-66,68)" ///
17 "Bladder (C67)" ///
18 "Brain, nervous system (C70-72)" ///
19 "Thyroid (C73)" ///
20 "O&U (C26,39,48,76,80)" ///
21 "Lymphoma (C81-85,88,90,96)" ///
22 "Leukaemia (C91-95)" ///
23 "Other digestive (C17,23-24)" ///
24 "Nose, sinuses (C30-31)" ///
25 "Bone, cartilage, etc (C40-41,45,47,49)" ///
26 "Other skin (C44)" ///
27 "Other female organs (C51-52,57-58)" ///
28 "Other male organs (C60,63)" ///
29 "Other endocrine (C74-75)" ///
30 "Myeloproliferative disorders (MPD)" ///
31 "Myselodysplastic syndromes (MDS)" ///
32 "D069: CIN 3" ///
33 "All sites but C44" ///
34 "Excluded from CR5db"
label var sitecr5db "CR5db sites"
label values sitecr5db sitecr5db_lab

replace sitecr5db=1 if (regexm(icd10,"C00")|regexm(icd10,"C01")|regexm(icd10,"C02") ///
					 |regexm(icd10,"C03")|regexm(icd10,"C04")|regexm(icd10,"C05") ///
					 |regexm(icd10,"C06")|regexm(icd10,"C07")|regexm(icd10,"C08") ///
					 |regexm(icd10,"C09")|regexm(icd10,"C10")|regexm(icd10,"C11") ///
					 |regexm(icd10,"C12")|regexm(icd10,"C13")|regexm(icd10,"C14")) //21 changes
replace sitecr5db=2 if regexm(icd10,"C15") //10 changes
replace sitecr5db=3 if regexm(icd10,"C16") //20 changes
replace sitecr5db=4 if (regexm(icd10,"C18")|regexm(icd10,"C19")|regexm(icd10,"C20")|regexm(icd10,"C21")) //92 changes
replace sitecr5db=5 if regexm(icd10,"C22") //9 changes
replace sitecr5db=6 if regexm(icd10,"C25") //29 changes
replace sitecr5db=7 if regexm(icd10,"C32") //1 change
replace sitecr5db=8 if (regexm(icd10,"C33")|regexm(icd10,"C34")) //41 changes
replace sitecr5db=9 if regexm(icd10,"C43") //1 change
replace sitecr5db=10 if regexm(icd10,"C50") //72 changes
replace sitecr5db=11 if regexm(icd10,"C53") //12 changes
replace sitecr5db=12 if (regexm(icd10,"C54")|regexm(icd10,"C55")) //24 changes
replace sitecr5db=13 if regexm(icd10,"C56") //1 change
replace sitecr5db=14 if regexm(icd10,"C61") //150 changes
replace sitecr5db=15 if regexm(icd10,"C62") //0 changes
replace sitecr5db=16 if (regexm(icd10,"C64")|regexm(icd10,"C65")|regexm(icd10,"C66")|regexm(icd10,"C68")) //11 changes
replace sitecr5db=17 if regexm(icd10,"C67") //13 changes
replace sitecr5db=18 if (regexm(icd10,"C70")|regexm(icd10,"C71")|regexm(icd10,"C72")) //0 changes
replace sitecr5db=19 if regexm(icd10,"C73") //3 changes
replace sitecr5db=20 if siteiarc==61 //57 changes
replace sitecr5db=21 if (regexm(icd10,"C81")|regexm(icd10,"C82")|regexm(icd10,"C83")|regexm(icd10,"C84")|regexm(icd10,"C85")|regexm(icd10,"C88")|regexm(icd10,"C90")|regexm(icd10,"C96")) //43 changes
replace sitecr5db=22 if (regexm(icd10,"C91")|regexm(icd10,"C92")|regexm(icd10,"C93")|regexm(icd10,"C94")|regexm(icd10,"C95")) //12 changes
replace sitecr5db=23 if (regexm(icd10,"C17")|regexm(icd10,"C23")|regexm(icd10,"C24")) //11 changes
replace sitecr5db=24 if (regexm(icd10,"C30")|regexm(icd10,"C31")) //1 change
replace sitecr5db=25 if (regexm(icd10,"C40")|regexm(icd10,"C41")|regexm(icd10,"C45")|regexm(icd10,"C47")|regexm(icd10,"C49")) //3 changes
replace sitecr5db=26 if siteiarc==25 //7 changes
replace sitecr5db=27 if (regexm(icd10,"C51")|regexm(icd10,"C52")|regexm(icd10,"C57")|regexm(icd10,"C58")) //2 changes
replace sitecr5db=28 if (regexm(icd10,"C60")|regexm(icd10,"C63")) //2 changes
replace sitecr5db=29 if (regexm(icd10,"C74")|regexm(icd10,"C75")) //0 changes
replace sitecr5db=30 if siteiarc==59 //2 changes
replace sitecr5db=31 if siteiarc==60 //1 change
replace sitecr5db=32 if siteiarc==64 //0 changes
replace sitecr5db=34 if icd10=="C380"|icd10=="C699"|icd10=="C865"|icd10=="C866" //4 changes

tab sitecr5db ,m

***********************
** Create ICD10 site **
***********************
** Create variable based on ICD-10 2010 version to use in graphs (dofile 12) - may not use
gen siteicd10=.
label define siteicd10_lab ///
1 "C00-C14: lip,oral cavity & pharynx" ///
2 "C15-C26: digestive organs" ///
3 "C30-C39: respiratory & intrathoracic organs" ///
4 "C40-C41: bone & articular cartilage" ///
5 "C43: melanoma" ///
6 "C44: other skin" ///
7 "C45-C49: mesothelial & soft tissue" ///
8 "C50: breast" ///
9 "C51-C58: female genital organs" ///
10 "C61: prostate" ///
11 "C60-C62,C63: male genital organs" ///
12 "C64-C68: urinary tract" ///
13 "C69-C72: eye,brain,other CNS" ///
14 "C73-C75: thyroid & other endocrine glands" ///
15 "C76-C79: ill-defined sites" ///
16 "C80: primary site unknown" ///
17 "C81-C96: lymphoid & haem"
label var siteicd10 "ICD-10 site of tumour"
label values siteicd10 siteicd10_lab


replace siteicd10=1 if (regexm(icd10,"C00")|regexm(icd10,"C01")|regexm(icd10,"C02") ///
					 |regexm(icd10,"C03")|regexm(icd10,"C04")|regexm(icd10,"C05") ///
					 |regexm(icd10,"C06")|regexm(icd10,"C07")|regexm(icd10,"C08") ///
					 |regexm(icd10,"C09")|regexm(icd10,"C10")|regexm(icd10,"C11") ///
					 |regexm(icd10,"C12")|regexm(icd10,"C13")|regexm(icd10,"C14")) //9 changes
replace siteicd10=2 if (regexm(icd10,"C15")|regexm(icd10,"C16")|regexm(icd10,"C17") ///
					 |regexm(icd10,"C18")|regexm(icd10,"C19")|regexm(icd10,"C20") ///
					 |regexm(icd10,"C21")|regexm(icd10,"C22")|regexm(icd10,"C23") ///
					 |regexm(icd10,"C24")|regexm(icd10,"C25")|regexm(icd10,"C26")) //194 changes
replace siteicd10=3 if (regexm(icd10,"C30")|regexm(icd10,"C31")|regexm(icd10,"C32")|regexm(icd10,"C33")|regexm(icd10,"C34")|regexm(icd10,"C37")|regexm(icd10,"C38")|regexm(icd10,"C39")) //33 changes
replace siteicd10=4 if (regexm(icd10,"C40")|regexm(icd10,"C41")) //2 changes
replace siteicd10=5 if siteiarc==24 //4 changes
replace siteicd10=6 if siteiarc==25 //4 changes
replace siteicd10=7 if (regexm(icd10,"C45")|regexm(icd10,"C46")|regexm(icd10,"C47")|regexm(icd10,"C48")|regexm(icd10,"C49")) //3 changes
replace siteicd10=8 if regexm(icd10,"C50") //64 changes
replace siteicd10=9 if (regexm(icd10,"C51")|regexm(icd10,"C52")|regexm(icd10,"C53")|regexm(icd10,"C54")|regexm(icd10,"C55")|regexm(icd10,"C56")|regexm(icd10,"C57")|regexm(icd10,"C58")) //67 changes
replace siteicd10=10 if regexm(icd10,"C61") //104 changes
replace siteicd10=11 if (regexm(icd10,"C60")|regexm(icd10,"C62")|regexm(icd10,"C63")) //0 changes
replace siteicd10=12 if (regexm(icd10,"C64")|regexm(icd10,"C65")|regexm(icd10,"C66")|regexm(icd10,"C67")|regexm(icd10,"C68")) //21 changes
replace siteicd10=13 if (regexm(icd10,"C69")|regexm(icd10,"C70")|regexm(icd10,"C71")|regexm(icd10,"C72")) //10 changes
replace siteicd10=14 if (regexm(icd10,"C73")|regexm(icd10,"C74")|regexm(icd10,"C75")) //5 changes
replace siteicd10=15 if (regexm(icd10,"C76")|regexm(icd10,"C77")|regexm(icd10,"C78")|regexm(icd10,"C79")) //0 changess
replace siteicd10=16 if regexm(icd10,"C80") //46 changes
replace siteicd10=17 if (regexm(icd10,"C81")|regexm(icd10,"C82")|regexm(icd10,"C83") ///
					 |regexm(icd10,"C84")|regexm(icd10,"C85")|regexm(icd10,"C86") ///
					 |regexm(icd10,"C87")|regexm(icd10,"C88")|regexm(icd10,"C89") ///
					 |regexm(icd10,"C90")|regexm(icd10,"C91")|regexm(icd10,"C92") ///
					 |regexm(icd10,"C93")|regexm(icd10,"C94")|regexm(icd10,"C95") ///
					 |regexm(icd10,"C96")|regexm(icd10,"D46")|regexm(icd10,"D47")) //65 changes


tab siteicd10 ,m //0 missing

drop recstatdc tfdddoa tfddda tfregnumstart tfdistrictstart tfregnumend tfdistrictend tfddtxt recstattf
	 
order record_id did fname lname age age5 age_10 sex dob nrn parish dod dodyear cancer siteiarc siteiarchaem pod coddeath


label data "BNR MORTALITY data 2015"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version04\3-output\2015_prep mort" ,replace
note: TS This dataset is used for analysis of age-standardized mortality rates
note: TS This dataset includes patients with multiple eligible cancer causes of death

stop
***************************
** Preparing 2021 deaths **
***************************
***************
** DATA IMPORT  
***************
** LOAD the cleaned national registry deaths 2008-2020 excel/REDCap dataset
clear
import excel using "`datapath'\version02\1-input\BNRDeathData20082020_DATA_2021-07-27_1326_excel.xlsx" , firstrow case(lower)

count //32,467

*******************
** DATA FORMATTING  
*******************
** PREPARE each variable according to the format and order in which they appear in DeathData REDCap database
** Next we get rid of those who died pre-and-post-2019 (KEEP record_id 31475 + 31473 : post-prep updates for 2018 + 2019 deaths)
drop if record_id!=31475 & record_id!=31473 & (dod<d(01jan2020) | dod>d(31dec2020)) //29,862 deleted


count //2605

************************
**  DEATH CERTIFICATE **
**        FORM        **
************************

** (1) record_id (auto-generated by REDCap)
label var record_id "DeathID"

** (2) redcap_event_name (auto-generated by REDCap)
gen event=.
replace event=1 if redcap_event_name=="death_data_collect_arm_1"
replace event=2 if redcap_event_name=="tracking_arm_2"

label var event "Redcap Event Name"
label define event_lab 1 "DC arm 1" 2 "TF arm 2", modify
label values event event_lab

** Remove Tracking Form info
drop if event==2 //0 deleted - TFs got deleted with dod remove code above

count //2605

** (3) dddoa: Y-M-D H:M, readonly
gen double dddoa2 = clock(dddoa, "YMDhm")
format dddoa2 %tcCCYY-NN-DD_HH:MM
drop dddoa
rename dddoa2 dddoa
label var dddoa "ABS DateTime"

** (4) ddda
label var ddda "ABS DA"
label define ddda_lab 4 "KG" 13 "KWG" 14 "TH" 20 "NR" 25 "AH" 98 "intern", modify
label values ddda ddda_lab

** (5) odda
label var odda "ABS Other DA"

** (6) certtype: 1=MEDICAL 2=POST MORTEM 3=CORONER 99=ND, required
label var certtype "Certificate Type"
label define certtype_lab 1 "Medical" 2 "Post Mortem" 3 "Coroner" 99 "ND", modify
label values certtype certtype_lab

** (7) regnum: integer, if missing=9999
label var regnum "Registry Dept #"

** (8) district: 1=A 2=B 3=C 4=D 5=E 6=F
/* Districts are assigned based on death parish
	District A - anything below top rock christ church and st. michael 
	District B - anything above top rock christ church and st. george
	District C - st. philip and st. john
	District D - st. thomas
	District E - st. james, st. peter, st. lucy
	District F - st. joseph, st. andrew
*/
label var district "District"
label define district_lab 1 "A" 2 "B" 3 "C" 4 "D" 5 "E" 6 "F", modify
label values district district_lab

** (9) pname: Text, if missing=99
label var pname "Deceased's Name"
replace pname = rtrim(ltrim(itrim(pname))) //5 changes

** (10) address: Text, if missing=99
label var address "Deceased's Address"
replace address = rtrim(ltrim(itrim(address))) //20 changes

** (11) parish
label var parish "Deceased's Parish"
label define parish_lab 1 "Christ Church" 2 "St. Andrew" 3 "St. George" 4 "St. James" 5 "St. John" 6 "St. Joseph" ///
						7 "St. Lucy" 8 "St. Michael" 9 "St. Peter" 10 "St. Philip" 11 "St. Thomas" 99 "ND", modify
label values parish parish_lab

** (12) sex:	1=Male 2=Female 99=ND
label var sex "Sex"
label define sex_lab 1 "Male" 2 "Female" 99 "ND", modify
label values sex sex_lab

** (13) age: Integer - min=0, max=999
label var age "Age"

** (14) agetxt
label var agetxt "Age Qualifier"
label define agetxt_lab 1 "Minutes" 2 "Hours" 3 "Days" 4 "Weeks" 5 "Months" 6 "Years" 99 "ND", modify
label values agetxt agetxt_lab

** (15) nrnnd: 1=Yes 2=No
label define nrnnd_lab 1 "Yes" 2 "No", modify
label values nrnnd nrnnd_lab
label var nrnnd "Is National ID # documented?"

** (16) nrn: dob-####, partial missing=dob-9999, if missing=.
label var nrn "National ID #"
format nrn %15.0g

** (17) mstatus: 1=Single 2=Married 3=Separated/Divorced 4=Widowed/Widow/Widower 99=ND
label var mstatus "Marital Status"
label define mstatus_lab 1 "Single" 2 "Married" 3 "Separated/Divorced" 4 "Widowed/Widow/Widower" 99 "ND", modify
label values mstatus mstatus_lab

** (18) occu: Text, if missing=99
label var occu "Occupation"

** (19) durationnum: Integer - min=0, max=99, if missing=99
label var durationnum "Duration of Illness"

** (20) durationtxt
label var durationtxt "Duration Qualifier"
label define durationtxt_lab 1 "Days" 2 "Weeks" 3 "Months" 4 "Years" 99 "ND", modify
label values durationtxt durationtxt_lab

** (21) dod: Y-M-D
format dod %tdCCYY-NN-DD
label var dod "Date of Death"

** (22) dodyear (not included in single year Redcap db but done for multi-year Redcap db)
drop dodyear
gen int dodyear=year(dod)
label var dodyear "Year of Death"

** (23) cod1a: Text, if missing=99
label var cod1a "COD 1a"

** (24) onsetnumcod1a: Integer - min=0, max=99, if missing=99
label var onsetnumcod1a "Onset Death Interval-COD 1a"

** (25) onsettxtcod1a: 1=DAYS 2=WEEKS 3=MONTHS 4=YEARS
label var onsettxtcod1a "Onset Qualifier-COD 1a"
label define onsettxtcod1a_lab 1 "Days" 2 "Weeks" 3 "Months" 4 "Years" 99 "ND", modify
label values onsettxtcod1a onsettxtcod1a_lab

** (26) cod1b: Text, if missing=99
label var cod1b "COD 1b"

** (27) onsetnumcod1b: Integer - min=0, max=99, if missing=99
label var onsetnumcod1b "Onset Death Interval-COD 1b"

** (28) onsettxtcod1b: 1=DAYS 2=WEEKS 3=MONTHS 4=YEARS
label var onsettxtcod1b "Onset Qualifier-COD 1b"
label define onsettxtcod1b_lab 1 "Days" 2 "Weeks" 3 "Months" 4 "Years" 99 "ND", modify
label values onsettxtcod1b onsettxtcod1b_lab

** (29) cod1c: Text, if missing=99
label var cod1c "COD 1c"

** (30) onsetnumcod1c: Integer - min=0, max=99, if missing=99
label var onsetnumcod1c "Onset Death Interval-COD 1c"

** (31) onsettxtcod1c: 1=DAYS 2=WEEKS 3=MONTHS 4=YEARS
label var onsettxtcod1c "Onset Qualifier-COD 1c"
label define onsettxtcod1c_lab 1 "Days" 2 "Weeks" 3 "Months" 4 "Years" 99 "ND", modify
label values onsettxtcod1c onsettxtcod1c_lab

** (32) cod1d: Text, if missing=99
label var cod1d "COD 1d"

** (33) onsetnumcod1d: Integer - min=0, max=99, if missing=99
label var onsetnumcod1d "Onset Death Interval-COD 1d"

** (34) onsettxtcod1d: 1=DAYS 2=WEEKS 3=MONTHS 4=YEARS
label var onsettxtcod1d "Onset Qualifier-COD 1d"
label define onsettxtcod1d_lab 1 "Days" 2 "Weeks" 3 "Months" 4 "Years" 99 "ND", modify
label values onsettxtcod1d onsettxtcod1d_lab

** (35) cod2a: Text, if missing=99
label var cod2a "COD 2a"

** (36) onsetnumcod2a: Integer - min=0, max=99, if missing=99
label var onsetnumcod2a "Onset Death Interval-COD 2a"

** (37) onsettxtcod2a: 1=DAYS 2=WEEKS 3=MONTHS 4=YEARS
label var onsettxtcod2a "Onset Qualifier-COD 2a"
label define onsettxtcod2a_lab 1 "Days" 2 "Weeks" 3 "Months" 4 "Years" 99 "ND", modify
label values onsettxtcod2a onsettxtcod2a_lab

** (38) cod2b: Text, if missing=99
label var cod2b "COD 2b"

** (39) onsetnumcod2b: Integer - min=0, max=99, if missing=99
label var onsetnumcod2b "Onset Death Interval-COD 2b"

** (40) onsettxtcod2b: 1=DAYS 2=WEEKS 3=MONTHS 4=YEARS
label var onsettxtcod2b "Onset Qualifier-COD 2b"
label define onsettxtcod2b_lab 1 "Days" 2 "Weeks" 3 "Months" 4 "Years" 99 "ND", modify
label values onsettxtcod2b onsettxtcod2b_lab

** (41) pod: Text, if missing=99
label var pod "Place of Death"

** (42) deathparish
label var deathparish "Death Parish"
label define deathparish_lab 1 "Christ Church" 2 "St. Andrew" 3 "St. George" 4 "St. James" 5 "St. John" 6 "St. Joseph" ///
						7 "St. Lucy" 8 "St. Michael" 9 "St. Peter" 10 "St. Philip" 11 "St. Thomas" 99 "ND", modify
label values deathparish deathparish_lab

** (43) regdate: Y-M-D
label var regdate "Date of Registration"
format regdate %tdCCYY-NN-DD

** (44) certifier: Text, if missing=99
label var certifier "Name of Certifier"

** (45) certifieraddr: Text, if missing=99
label var certifieraddr "Address of Certifier"

** (46) namematch: readonly
label var namematch "Name Match"
label define namematch_lab 1 "names match but different person" 2 "no name match", modify
label values namematch namematch_lab

** (47) death_certificate_complete (auto-generated by REDCap): 0=Incomplete 1=Unverified 2=Complete
rename death_certificate_complete recstatdc
label var recstatdc "Record Status-DC Form"
label define recstatdc_lab 0 "Incomplete" 1 "Unverified" 2 "Complete", modify
label values recstatdc recstatdc_lab


*******************
** TRACKING FORM **
*******************

** (48) tfdddoa: Y-M-D H:M, readonly
//replace tfdddoa = rtrim(ltrim(itrim(tfdddoa))) //30 changes
//generate tfdddoa2=date(tfdddoa,"MDY")
//format tfdddoa2 %tdYYYY-NN-DD
//drop tfdddoa
//rename tfdddoa2 tfdddoa
format tfdddoa %tdYYYY-NN-DD
label var tfdddoa "TF Date-Start"

** (49) tfdddoatstart: HH:MM
format tfdddoatstart %tcHH:MM
label var tfdddoatstart "TF Time-Start"

** (50) tfddda: readonly, user logged into redcap
gen tfddda1=.
replace tfddda1=25 if tfddda=="ashley.henry" //using codebook tfddda to see all possible entries in this field
replace tfddda1=25 if tfddda=="ashleyhenry"
replace tfddda1=4 if tfddda=="karen.greene"
replace tfddda1=13 if tfddda=="kirt.gill"
replace tfddda1=20 if tfddda=="nicolette.roachford"
replace tfddda1=14 if tfddda=="tamisha.hunte"
replace tfddda1=98 if tfddda=="t.g"
replace tfddda1=98 if tfddda=="ivanna.bascombe"
replace tfddda1=98 if tfddda=="ib"
replace tfddda1=98 if tfddda=="asia.blackman"
replace tfddda1=98 if tfddda=="ab"
replace tfddda1=98 if tfddda=="shay.morrisdoty"
rename tfddda tfddda2
rename tfddda1 tfddda

label var tfddda "TF DA"
label define tfddda_lab 4 "KG" 13 "KWG" 14 "TH" 20 "NR" 25 "AH" 98 "intern", modify
label values tfddda tfddda_lab

** (51) tfregnumstart: integer
label var tfregnumstart "Registry #-Start"

** (52) tfdistrictstart: letters only
label var tfdistrictstart "District-Start"

** (53) tfregnumend: integer
label var tfregnumend "Registry #-End"

** (54) tfdistrictend: letters only
label var tfdistrictend "District-End"

** (55) tfdddoaend: Y-M-D
format tfdddoaend %tdCCYY-NN-DD
label var tfdddoaend "TF Date-End"

** (56) tfdddoatend: HH:MM
format tfdddoatend %tcHH:MM
label var tfdddoatend "TF Time-End"

** (57) tfddelapsedh: integer (imported to Stata as byte)
recast int tfddelapsedh
label var tfddelapsedh "Time Elpased (hrs)"

** (58) tfddelapsedm: integer
label var tfddelapsedm "Time Elpased (mins)"

** (59) tfddtxt
label var tfddtxt "TF Comments"

** (60) tracking_complete (auto-generated by REDCap): 0=Incomplete 1=Unverified 2=Complete
rename tracking_complete recstattf
label var recstattf "Record Status-TF Form"
label define recstattf_lab 0 "Incomplete" 1 "Unverified" 2 "Complete", modify
label values recstattf recstattf_lab

order record_id event dddoa ddda odda certtype regnum district pname address parish sex ///
      age agetxt nrnnd nrn mstatus occu durationnum durationtxt dod dodyear ///
      cod1a onsetnumcod1a onsettxtcod1a cod1b onsetnumcod1b onsettxtcod1b ///
      cod1c onsetnumcod1c onsettxtcod1c cod1d onsetnumcod1d onsettxtcod1d ///
      cod2a onsetnumcod2a onsettxtcod2a cod2b onsetnumcod2b onsettxtcod2b ///
      pod deathparish regdate certifier certifieraddr namematch cleaned recstatdc

drop tfdddoa tfdddoatstart tfddda tfddda2 tfregnumstart tfdistrictstart tfregnumend tfdistrictend tfdddoaend tfdddoatend tfddelapsedh tfddelapsedm tfddtxt recstattf

count //2605

label data "BNR MORTALITY data 2020"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version02\2-working\2020_deaths_prepped_dp" ,replace

**************************************
**     Prep 2020 death variables    **
** for matching with cancer dataset **
**************************************
use "`datapath'\version02\2-working\2020_deaths_prepped_dp" ,clear

count //2605


*****************
**  Formatting **
**    Names    **
*****************
rename namematch nm

** Need to check for duplicate death registrations
** First split full name into first, middle and last names
** Also - code to split full name into 2 variables fname and lname - else can't merge! 
split pname, parse(", "" ") gen(name)
order record_id pname name*
sort record_id

** Use Stata browse to view results as changes are made
** (1) sort cases that contain only a first name and a last name
count if name7=="" & name6=="" & name5=="" & name4=="" & name3=="" & name2=="" //0
count if name6=="" & name5=="" & name4=="" & name3=="" & name2=="" //0
count if name5=="" & name4=="" & name3=="" & name2=="" //0
count if name5=="" & name4=="" & name3=="" //1862
count if name7!="" //2
count if name6!="" //2
count if name5!="" //6
count if name4!="" //70
count if name3!="" //742
count if name2!="" //2605
count if name1!="" //2605

** (2) sort name7 field
replace name7=name3+" "+name4+" "+name5+" "+name6+" "+name7 if record_id==32932
replace name3=name2 if record_id==32932
replace name2=name7 if record_id==32932
replace name7=name4+" "+name5+" "+name6+" "+name7 if record_id==33097
replace name2=name2+" "+name7 if record_id==33097
replace name5="" if record_id==32932|record_id==33097
replace name4="" if record_id==32932|record_id==33097
drop name7
drop name6

** (3) sort name5 field
replace name2=name2+" "+name3+" "+name4 if record_id==32096|record_id==32980
replace name3=name5 if record_id==32096|record_id==32980
replace name4="" if record_id==32096|record_id==32980
replace name5="" if record_id==32096|record_id==32980
replace name3=name3+" "+name4+" "+name5 if record_id==32116
replace name4="" if record_id==32116
replace name5="" if record_id==32116

** (4) sort cases with name 'baby' or 'b/o' in name1 variable
count if (regexm(name1,"BABY")|regexm(name1,"B/O")|regexm(name1,"MALE")|regexm(name1,"FEMALE")) //5
gen tempvarn=1 if (regexm(name1,"BABY")|regexm(name1,"B/O")|regexm(name1,"MALE")|regexm(name1,"FEMALE"))
//list record_id pname name1 name2 name3 name4 name5 if tempvarn==1
//list record_id pname name6 name7 if tempvarn==1
replace tempvarn=. if record_id==31995|record_id==32479
replace name1=name1+" "+name2 if tempvarn==1 //3 changes
replace name2="" if tempvarn==1 //3 changes
replace name1=name1+" "+name3 if tempvarn==1 & name4!="" //3 changes
replace name3=name4 if tempvarn==1 & name4!="" //3 changes
replace name4="" if tempvarn==1 & name4!="" //3 changes
replace tempvarn=. if tempvarn!=. //3 changes
count if (regexm(name2,"BABY")|regexm(name2,"B/O")|regexm(name2,"MALE")|regexm(name2,"FEMALE")) //2 - already sorted in step (2) above
replace tempvarn=1 if (regexm(name2,"BABY")|regexm(name2,"B/O")|regexm(name2,"MALE")|regexm(name2,"FEMALE"))
replace tempvarn=. if tempvarn!=. //2 changes
count if (regexm(name3,"BABY")|regexm(name3,"B/O")|regexm(name3,"MALE")|regexm(name3,"FEMALE")) //0
count if (regexm(name4,"BABY")|regexm(name4,"B/O")|regexm(name4,"MALE")|regexm(name4,"FEMALE")) //0

** (5)
** Names containing 'ST' are being interpreted as 'ST'=name1/fname so correct
count if name1=="ST" | name1=="ST." //4
replace tempvarn=2 if name1=="ST" | name1=="ST." //4 changes
//list record_id pname name1 name2 name5 if tempvarn==2
replace name1=name1+"."+""+name2 if tempvarn==2 //4 changes
replace name2="" if tempvarn==2 //4 changes
replace name2=name3 if record_id==32344|record_id==33923
replace name2=name2+" "+name4 if record_id==33923
replace name3=name4 if record_id==32344
replace name3=name5 if record_id==33923
replace name4="" if tempvarn==2
replace name5="" if tempvarn==2
drop name5
** Names containing 'ST' are being interpreted as 'ST'=name2/fname so correct
count if name2=="ST" | name2=="ST." //9
replace tempvarn=3 if name2=="ST" | name2=="ST." //9 changes
replace name3=name2+"."+name3 if tempvarn==3 & name4=="" //3 changes
replace name2="" if tempvarn==3 & name4=="" //3 changes
replace tempvarn=. if tempvarn==3 & name4=="" //3 changes
replace name2=name2+"."+name3 if tempvarn==3 //6 changes
replace name2 = subinstr(name2, ".", "",1) if record_id==33570
replace name3=name4 if tempvarn==3 //6 changes
replace name4="" if tempvarn==3 //6 changes
** Names containing 'ST' are being interpreted as 'ST'=name3/fname so correct
count if name3=="ST" | name3=="ST." //2
replace tempvarn=4 if name3=="ST" | name3=="ST."
replace name3=name3+"."+""+name4 if tempvarn==4 //2 changes
replace name4="" if tempvarn==4 //2 changes

** (6) sort cases with name in name4 variable
count if name4!="" //52
//list record_id *name* if name4!=""
replace name2=name2+" "+name3 if name4!="" //52 changes
replace name3=name4 if name4!="" //52 changes
replace name4="" if name4!="" //52 changes
drop name4

** (7) sort cases with suffixes
count if (name3!="" & name3!="99") & length(name3)<4 //4 - 0 need correcting
replace tempvarn=5 if (name3!="" & name3!="99") & length(name3)<4 //4 changes
//list record_id pname fname mname lname if (lname!="" & lname!="99") & length(lname)<3

** (8) sort cases with NO name in name3 variable
count if name3=="" //1863
//list record_id *name* if name3==""
replace tempvarn=6 if name3=="" //1863 changes
replace name3=name2 if tempvarn==6 //1863 changes
replace name2="" if tempvarn==6 //1863 changes


** Now rename, check and remove unnecessary variables
count if name1=="" //0
count if name2=="" //8
count if name3=="" //0
rename name1 fname
rename name2 mname
rename name3 lname
count if fname=="" //0
count if lname=="" //0

** Convert names to lower case and strip possible leading/trailing blanks
replace fname = lower(rtrim(ltrim(itrim(fname)))) //2605 changes
replace mname = lower(rtrim(ltrim(itrim(mname)))) //734 changes
replace lname = lower(rtrim(ltrim(itrim(lname)))) //2605 changes

rename nm namematch
order record_id pname fname mname lname namematch


** Now generate a new variable which will select out all the potential cancers
gen cancer=.
label define cancer_lab 1 "cancer" 2 "not cancer", modify
label values cancer cancer_lab
label var cancer "cancer diagnoses"
label var record_id "Event identifier for registry deaths"

** searching cod1a for these terms
replace cod1a="99" if cod1a=="999" //0 changes
replace cod1b="99" if cod1b=="999" //0 changes
replace cod1c="99" if cod1c=="999" //1 changes
replace cod1d="99" if cod1d=="999" //1 changes
replace cod2a="99" if cod2a=="999" //2 changes
replace cod2b="99" if cod2b=="999" //2 changes
count if cod1c!="99" //635
count if cod1d!="99" //198
count if cod2a!="99" //1086
count if cod2b!="99" //531
//ssc install unique
//ssc install distinct
** Create variable with combined CODs
gen coddeath=cod1a+" "+cod1b+" "+cod1c+" "+cod1d+" "+cod2a+" "+cod2b
replace coddeath=subinstr(coddeath,"99 ","",.) //2485 changes
replace coddeath=subinstr(coddeath," 99","",.) //2071 changes
** Identify cancer deaths using variable called 'cancer'
replace cancer=1 if regexm(coddeath, "CANCER") & cancer==. //388 changes
replace cancer=1 if regexm(coddeath, "TUMOUR") &  cancer==. //10 changes
replace cancer=1 if regexm(coddeath, "TUMOR") &  cancer==. //7 changes
replace cancer=1 if regexm(coddeath, "MALIGNANT") &  cancer==. //9 changes
replace cancer=1 if regexm(coddeath, "MALIGNANCY") &  cancer==. //22 changes
replace cancer=1 if regexm(coddeath, "NEOPLASM") &  cancer==. //4 changes
replace cancer=1 if regexm(coddeath, "CARCINOMA") &  cancer==. //159 changes
replace cancer=1 if regexm(coddeath, "CARCIMONA") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath, "CARINOMA") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath, "MYELOMA") &  cancer==. //23 changes
replace cancer=1 if regexm(coddeath, "LYMPHOMA") &  cancer==. //15 changes
replace cancer=1 if regexm(coddeath, "LYMPHOMIA") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath, "LYMPHONA") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath, "SARCOMA") &  cancer==. //11 changes
replace cancer=1 if regexm(coddeath, "TERATOMA") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath, "LEUKEMIA") &  cancer==. //11 changes
replace cancer=1 if regexm(coddeath, "LEUKAEMIA") &  cancer==. //2 changes
replace cancer=1 if regexm(coddeath, "HEPATOMA") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath, "CARANOMA PROSTATE") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath, "MENINGIOMA") &  cancer==. //3 changes
replace cancer=1 if regexm(coddeath, "MYELOSIS") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath, "MYELOFIBROSIS") &  cancer==. //1 change
replace cancer=1 if regexm(coddeath, "CYTHEMIA") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath, "CYTOSIS") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath, "BLASTOMA") &  cancer==. //2 changes
replace cancer=1 if regexm(coddeath, "METASTATIC") &  cancer==. //1 change
replace cancer=1 if regexm(coddeath, "MASS") &  cancer==. //27 changes
replace cancer=1 if regexm(coddeath, "METASTASES") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath, "METASTASIS") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath, "REFRACTORY") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath, "FUNGOIDES") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath, "HODGKIN") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath, "MELANOMA") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath,"MYELODYS") &  cancer==. //4 changes
replace cancer=1 if regexm(coddeath,"ASTROCYTOMA") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath,"CARCINOME") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath,"MALIGANCY") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath,"MULTIFORME") &  cancer==. //0 changes
replace cancer=1 if regexm(coddeath,"GLIOMA") &  cancer==. //0 changes

** Strip possible leading/trailing blanks in cod1a
replace coddeath = rtrim(ltrim(itrim(coddeath))) //0 changes

tab cancer, missing //1905 missing

sort coddeath record_id
order record_id coddeath

drop dodyear
gen dodyear=year(dod)
tab dodyear cancer,m


** Check that all cancer CODs for 2016 are eligible
sort coddeath record_id
order record_id coddeath
//list coddeath if cancer==1 & inrange(record_id, 0, 24000)
** 588
//list coddeath if cancer==1 & inrange(record_id, 24001, 27000)
** 778

** Replace 2014 cases that are not cancer according to eligibility SOP:
/*
	(1) After merge with CR5 data then may need to reassign some of below 
		deaths as CR5 data may indicate eligibility while COD may exclude
		(e.g. see record_id==15458)
	(2) use obsid to check for CODs that incomplete in Results window with 
		Data Editor in browse mode-copy and paste record_id below from here
*/

** Check that all 2014 CODs that are not cancer for eligibility
tab dodyear cancer,m
count if cancer==. & inrange(record_id, 0, 23000) //873
count if cancer==. & inrange(record_id, 23001, 24000) //761
count if cancer==. & inrange(record_id, 24001, 2000) //725
//list coddeath if cancer==. & inrange(record_id, 0, 24000)
//list coddeath if cancer==. & inrange(record_id, 24001, 27000)

replace cancer=2 if ///
record_id==34006|record_id==32443|record_id==33181|record_id==32506|record_id==32057| ///
record_id==33680|record_id==32543|record_id==33718|record_id==33626|record_id==33808| ///
record_id==31747|record_id==33278|record_id==33198|record_id==31709|record_id==33670| ///
record_id==33735|record_id==33140|record_id==31923|record_id==32744|record_id==32895| ///
record_id==32615|record_id==31583|record_id==33149|record_id==33192|record_id==33237| ///
record_id==33469|record_id==33400|record_id==33609|record_id==34038|record_id==33122| ///
record_id==34002|record_id==33961|record_id==32035|record_id==32944|record_id==33257| ///
record_id==31882|record_id==32928|record_id==32606|record_id==33628|record_id==32768| ///
record_id==33043|record_id==32946|record_id==32143|record_id==33412|record_id==33446| ///
record_id==31492
//46 changes

replace cancer=1 if record_id==33524|record_id==32579|record_id==33998|record_id==33453 //4 changes

replace cancer=2 if cancer==. //1902 changes

** Create cod variable 
gen cod=.
label define cod_lab 1 "Dead of cancer" 2 "Dead of other cause" 3 "Not known" 4 "NA", modify
label values cod cod_lab
label var cod "COD categories"
replace cod=1 if cancer==1 //657 changes
replace cod=2 if cancer==2 //1948 changes
** one unknown causes of death in 2014 data - record_id 12323
replace cod=3 if coddeath=="99"|(regexm(coddeath,"INDETERMINATE")|regexm(coddeath,"UNDETERMINED")|regexm(coddeath,"UNKNOWN CAUSE")|regexm(coddeath,"NO ANATOMICAL CAUSE")) //24 changes
//list record_id coddeath if cod==3
replace cod=1 if record_id==32240


** Change sex to match cancer dataset
tab sex ,m
/*
        Sex |      Freq.     Percent        Cum.
------------+-----------------------------------
       Male |      1,330       51.06       51.06
     Female |      1,275       48.94      100.00
------------+-----------------------------------
      Total |      2,605      100.00
*/
rename sex sex_old
gen sex=1 if sex_old==2 //2467 changes
replace sex=2 if sex_old==1 //2587 changes
drop sex_old
label define sex_lab 1 "Female" 2 "Male", modify
label values sex sex_lab
label var sex "Sex"
tab sex ,m
/*
        Sex |      Freq.     Percent        Cum.
------------+-----------------------------------
     Female |      1,275       48.94       48.94
       Male |      1,330       51.06      100.00
------------+-----------------------------------
      Total |      2,605      100.00
*/


** Spotting some duplicates so re-check for duplicates (since 2019 Pt.1 death cleaning was done at different time to 2019 Pt.2 these duplicates were missed)
** Delete records in multi-year REDCap database
sort regnum district
quietly by regnum district:  gen dupreg = cond(_N==1,0,_n)
sort regnum district
count if event==1 & dupreg>0  //177 - same reg #s but different pts
sort regnum pname record_id
//list record_id dddoa ddda odda pname regnum district nrn if event==1 & dupreg>0
//list record_id dddoa ddda odda pname regnum district nrn if event==1 & dupreg>0 & inrange(record_id, 26000, 28000)
//list record_id dddoa ddda odda pname regnum district nrn if event==1 & dupreg>0 & inrange(record_id, 28001, 30000)
drop dupreg


sort pname
quietly by pname:  gen dup = cond(_N==1,0,_n)
sort pname
count if event==1 & dup>0  //28 - all different pts with same name
sort pname record_id
//list record_id dddoa ddda odda pname regnum district nrn namematch if event==1 & dup>0
/*
replace namematch=1 if record_id==|record_id==|record_id==|record_id==|record_id== ///
					   |record_id==|record_id==|record_id==|record_id==|record_id== ///
					   |record_id==|record_id==|record_id==|record_id==|record_id== ///
					   |record_id==|record_id==|record_id==|record_id== // changes
drop if record_id==|record_id== // deleted
*/
//drop if event==1 & dup>0 & namematch==. // deleted
drop dup


** Remove, relabel certain variables for merging with cancer ds
gen dd2020_dod=dod
format dd2020_dod %tdCCYY-NN-DD

order record_id regnum nrn pname fname lname sex age dod cancer cod1a addr parish pod

** Create dataset for combining 2015-2020 deaths for matching (change variable names AFTER all datasets are combined and BEFORE matching with cancer dataset)
label data "BNR MORTALITY data 2020"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version02\2-working\2020_deaths_norenaming" ,replace
note: TS This dataset can be used for combining 2020 deaths with 2015-2019 deaths into one dataset for matching with cancer data


** Change variable names to distinguish between cancer and 2020 death variables
rename nrn dd2020_nrn
rename regnum dd2020_regnum 
rename pname dd2020_pname 
rename age dd2020_age 
rename cancer dd2020_cancer 
rename cod1a dd2020_cod1a 
rename address dd2020_address 
rename parish dd2020_parish 
rename pod dd2020_pod 
rename coddeath dd2020_coddeath
rename mname dd2020_mname 
rename namematch dd2020_namematch 
rename event dd2020_event 
rename dddoa dd2020_dddoa 
rename ddda dd2020_ddda 
rename odda dd2020_odda 
rename certtype dd2020_certtype 
rename district dd2020_district 
rename agetxt dd2020_agetxt 
rename nrnnd dd2020_nrnnd
rename mstatus dd2020_mstatus 
rename occu dd2020_occu 
rename durationnum dd2020_durationnum 
rename durationtxt dd2020_durationtxt 
rename onsetnumcod1a dd2020_onsetnumcod1a 
rename onsettxtcod1a dd2020_onsettxtcod1a 
rename cod1b dd2020_cod1b
rename onsetnumcod1b dd2020_onsetnumcod1b 
rename onsettxtcod1b dd2020_onsettxtcod1b 
rename cod1c dd2020_cod1c 
rename onsetnumcod1c dd2020_onsetnumcod1c 
rename onsettxtcod1c dd2020_onsettxtcod1c 
rename cod1d dd2020_cod1d 
rename onsetnumcod1d dd2020_onsetnumcod1d
rename onsettxtcod1d dd2020_onsettxtcod1d 
rename cod2a dd2020_cod2a 
rename onsetnumcod2a dd2020_onsetnumcod2a 
rename onsettxtcod2a dd2020_onsettxtcod2a 
rename cod2b dd2020_cod2b 
rename onsetnumcod2b dd2020_onsetnumcod2b 
rename onsettxtcod2b dd2020_onsettxtcod2b
rename deathparish dd2020_deathparish 
rename regdate dd2020_regdate 
rename certifier dd2020_certifier 
rename certifieraddr dd2020_certifieraddr
rename cleaned dd2020_cleaned
rename recstatdc dd2020_recstatdc 
//rename tfdddoa dd2020_tfdddoa 
//rename tfddda dd2020_tfddda 
//rename tfregnumstart dd2020_tfregnumstart
//rename tfdistrictstart dd2020_tfdistrictstart 
//rename tfregnumend dd2020_tfregnumend 
//rename tfdistrictend dd2020_tfdistrictend 
//rename tfddtxt dd2020_tfddtxt 
//rename recstattf dd2020_recstattf 
rename duprec dd2020_duprec 
//rename dupname dd2020_dupname 
//rename dupdod dd2020_dupdod
rename dodyear dd2020_dodyear 
//rename cod dd2020_cod
//rename record_id dd2020_record_id

count //2605

label data "BNR MORTALITY data 2020"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version02\3-output\2020_deaths_for_matching" ,replace
note: TS This dataset can be used for matching 2020 deaths with incidence data

***************************
**    2015-2020 Deaths   **
** Prepared for Matching **
***************************

clear

use "`datapath'\version02\2-working\2020_deaths_norenaming" ,clear

** Adding earlier death matching datasets as some deaths added post-cleaning
append using "`datapath'\version02\2-working\2015-2018_deaths_norenaming"
append using "`datapath'\version02\2-working\2019_deaths_norenaming"


drop dodyear
gen dodyear=year(dod)
tab dodyear,m
/*
    dodyear |      Freq.     Percent        Cum.
------------+-----------------------------------
       2015 |      2,482       16.10       16.10
       2016 |      2,488       16.14       32.24
       2017 |      2,530       16.41       48.65
       2018 |      2,525       16.38       65.03
       2019 |      2,788       18.09       83.11
       2020 |      2,603       16.89      100.00
------------+-----------------------------------
      Total |     15,416      100.00
*/

replace pod=placeofdeath if pod=="" & placeofdeath!="" // changes


** Remove unnecessary variables
drop event redcap_event_name recstatdc tempvarn dd2020_dod tfdddoa tfddda tfregnumstart tfdistrictstart tfregnumend tfdistrictend tfddtxt recstattf ///
	 placeofdeath dupname dupdod nrnyear year2 checkage2 dd2019_dod

** Populate natregno (string) field with NRNs
count if length(natregno)==9 //1
count if length(natregno)==8 //0
count if length(natregno)==7 //0
replace natregno="0" + natregno if length(natregno)==9 //1 change
replace natregno="00" + natregno if length(natregno)==8 //0 changes
replace natregno="000" + natregno if length(natregno)==7 //0 changes

** Reminder to JC (19-Aug-2021): For 2016 annual report cleaning, re-do below code when creating natregno string variable using gen double code as this changes the NRNs
/*
//format nrn %10.0g
gen double nrn2=nrn
format nrn2 %15.0g
rename nrn2 natregno
tostring natregno ,replace
*/
count if nrn!=. & natregno=="" //5,158
gen natregno2 = nrn
tostring natregno2 ,replace
count if length(natregno2)==9 & natregno=="" //27
count if length(natregno2)==8 & natregno=="" //0
count if length(natregno2)==7 & natregno=="" //5
replace natregno2="0" + natregno2 if length(natregno2)==9 & natregno=="" //27 changes
replace natregno2="000" + natregno2 if length(natregno2)==7 & natregno=="" //5 changes
count if natregno2!="" & natregno2!="." & natregno=="" //5,158
count if nrn!=. & natregno=="" //5,158
replace natregno=natregno2 if natregno2!="" & natregno2!="." & natregno=="" //5,158 changes
count if nrn!=. & natregno=="" //0
drop natregno2

** Create dataset without name changes for matching (see dofile 50)
label data "BNR MORTALITY data 2015-2020"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version02\3-output\2015-2020_deaths_for_appending" ,replace
note: TS This dataset can be used for matching 2015-2020 deaths with incidence data

** Change variable names in prep for matching with cancer dataset
rename record_id dd6yrs_record_id
rename regnum dd6yrs_regnum
rename nrn dd6yrs_nrn
rename pname dd6yrs_pname
rename fname dd6yrs_fname
rename lname dd6yrs_lname
rename sex dd6yrs_sex
rename age dd6yrs_age
rename dod dd6yrs_dod
rename cancer dd6yrs_cancer
rename cod1a dd6yrs_cod1a
rename address dd6yrs_address
rename parish dd6yrs_parish
rename pod dd6yrs_pod
rename coddeath dd6yrs_coddeath
rename mname dd6yrs_mname
rename namematch dd6yrs_namematch
rename dddoa dd6yrs_dddoa
rename ddda dd6yrs_ddda
rename odda dd6yrs_odda
rename certtype dd6yrs_certtype
rename district dd6yrs_district
rename agetxt dd6yrs_agetxt
rename nrnnd dd6yrs_nrnnd
rename mstatus dd6yrs_mstatus
rename occu dd6yrs_occu
rename durationnum dd6yrs_durationnum
rename durationtxt dd6yrs_durationtxt
rename onsetnumcod1a dd6yrs_onsetnumcod1a
rename onsettxtcod1a dd6yrs_onsettxtcod1a
rename cod1b dd6yrs_cod1b
rename onsetnumcod1b dd6yrs_onsetnumcod1b
rename onsettxtcod1b dd6yrs_onsettxtcod1b
rename cod1c dd6yrs_cod1c
rename onsetnumcod1c dd6yrs_onsetnumcod1c
rename onsettxtcod1c dd6yrs_onsettxtcod1c
rename cod1d dd6yrs_cod1d
rename onsetnumcod1d dd6yrs_onsetnumcod1d
rename onsettxtcod1d dd6yrs_onsettxtcod1d
rename cod2a dd6yrs_cod2a
rename onsetnumcod2a dd6yrs_onsetnumcod2a
rename onsettxtcod2a dd6yrs_onsettxtcod2a
rename cod2b dd6yrs_cod2b
rename onsetnumcod2b dd6yrs_onsetnumcod2b
rename onsettxtcod2b dd6yrs_onsettxtcod2b
rename deathparish dd6yrs_deathparish
rename regdate dd6yrs_regdate
rename certifier dd6yrs_certifier
rename certifieraddr dd6yrs_certifieraddr
rename cleaned dd6yrs_cleaned
rename duprec dd6yrs_duprec
rename elecmatch dd6yrs_elecmatch
rename cod dd6yrs_cod
rename natregno dd6yrs_natregno
rename dodyear dd6yrs_dodyear

label data "BNR MORTALITY data 2015-2020"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version02\3-output\2015-2020_deaths_for_matching" ,replace
note: TS This dataset can be used for matching 2015-2020 deaths with incidence data


** Since the below datasets (2016 + 2017) were already created in 2015AnnualReportV02 branch, I'll use those datasets instead of these for the pre-clean death matching for those years
** Create 2016 death dataset for pre-cleaning matching with CR5 dataset for DAs to use in final further retrieval and DCO trace-back for 2016 cases
preserve
drop if dodyear!=2016 // deleted

** Prep NRN field for merging with cancer dataset
//nsplit nrn, digits(6 4) gen(nrndob nrnnum)
gen double nrn2=nrn
format nrn2 %15.0g
tostring nrn2 ,replace
gen nrndob=substr(nrn2,1,6) if length(nrn2)==10
gen nrnnum=substr(nrn2,7,4) if length(nrn2)==10
gen natregno=nrndob+"-"+nrnnum if length(nrn2)==10
drop nrn2 nrndob nrnnum

label data "BNR MORTALITY data 2016"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version05\3-output\2016_deaths_for_matching" ,replace
note: TS This dataset can be used for matching 2016 deaths with pre-cleaning incidence data
restore

** Create 2017 death dataset for pre-cleaning matching with CR5 dataset for DAs to use in final further retrieval and DCO trace-back for 2017 cases
preserve
drop if dodyear!=2017 // deleted

** Prep NRN field for merging with cancer dataset
//nsplit nrn, digits(6 4) gen(nrndob nrnnum)
gen double nrn2=nrn
format nrn2 %15.0g
tostring nrn2 ,replace
gen nrndob=substr(nrn2,1,6) if length(nrn2)==10
gen nrnnum=substr(nrn2,7,4) if length(nrn2)==10
gen natregno=nrndob+"-"+nrnnum if length(nrn2)==10
drop nrn2 nrndob nrnnum

label data "BNR MORTALITY data 2017"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version06\3-output\2017_deaths_for_matching" ,replace
note: TS This dataset can be used for matching 2017 deaths with pre-cleaning incidence data
restore

** Create 2018 death dataset for pre-cleaning matching with CR5 dataset for DAs to use in final further retrieval and DCO trace-back for 2018 cases
preserve
drop if dodyear!=2018 // deleted

** Prep NRN field for merging with cancer dataset
//nsplit nrn, digits(6 4) gen(nrndob nrnnum)
gen double nrn2=nrn
format nrn2 %15.0g
tostring nrn2 ,replace
gen nrndob=substr(nrn2,1,6) if length(nrn2)==10
gen nrnnum=substr(nrn2,7,4) if length(nrn2)==10
gen natregno=nrndob+"-"+nrnnum if length(nrn2)==10
drop nrn2 nrndob nrnnum

label data "BNR MORTALITY data 2018"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version04\3-output\2018_deaths_for_matching" ,replace
note: TS This dataset can be used for matching 2018 deaths with pre-cleaning incidence data
restore
