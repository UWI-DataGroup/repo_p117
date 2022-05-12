** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          5_prep_mort 2016+2017.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      06-MAY-2022
    // 	date last modified      12-MAY-2022
    //  algorithm task          Prep and format death data using previously-prepared datasets and REDCap database export
    //  status                  Pending
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
    log using "`logpath'\5_prep_mort 2016+2017.smcl", replace
** HEADER -----------------------------------------------------

/* 
	JC 12may2022:
	
	Prep and analysis of 2018 mortality data preceded 2016 + 2017 as:
	(1) cancer team decided to complete 2018 prior to 2016 + 2017 as they had started 2018 note retrieval prior to COVID-19 pandemic QEH records dept restrictions.
	(2) NS requested the 2018 ASMRs first to compare with Globocan rates for B'dos and then 
		requested 2016 + 2017 ASMRs as a follow-up to the outcomes of the 2018 ASMRs comparison.
		
	For the 2018 ASMRs (see 5a_prep mort.do in 2018AnnualReportV02 branch), the death data was corrected as there were numerous errors with NRN and names fields.
	This dofile uses the corrected dataset from that set of analysis.
*/

***************
** DATA IMPORT  
***************
use "`datapath'\version04\3-output\2015-2020_deaths_for_matching" ,clear

************************
**     Preparing      **
** 2016 + 2017 Deaths **
**	 for analysis     **
************************
count //15,416
/*
This dataset preparation differs from the death matching ds in below ways:
 (1) death matching ds used for matching with cancer incidence ds for survival analysis 
	 - contains all deaths from all years
 (2) mortality rates ds used for reporting on ASMR (age-standardized mortality rates)
	 - need to identify deaths with multiple eligible cancer CODs
	 - need to assign each death by site as ASMR reported by site
	 - only need cancer deaths for specific reporting year
*/

** Remove death data prefix from variable names for this process (only needed when matching death and incidence datasets)
rename dd_* *

** Next we get rid of those who died pre-2017 (there are previously unmatched 2017 cases in dataset)
** First ensure dodyear and dod match by performing a quick count check
tab dodyear ,m
/*
    dodyear |      Freq.     Percent        Cum.
------------+-----------------------------------
       2015 |      2,482       16.10       16.10
       2016 |      2,488       16.14       32.24
       2017 |      2,530       16.41       48.65
       2018 |      2,528       16.40       65.05
       2019 |      2,785       18.07       83.11
       2020 |      2,603       16.89      100.00
------------+-----------------------------------
      Total |     15,416      100.00
*/
gen dodyr=year(dod)
count if dodyear!=dodyr //0
drop dodyr

drop if dodyear!=2016 & dodyear!=2017 //12,888 deleted
** Remove Tracking Form info (already previously removed)
//drop if event==2 //0 deleted

count //5018

** NOTE: For accuracy, the above count of 2018 deaths was cross-checked against the current multi-year REDCapdb using the report called '2018 deaths' which has the below filters:
//JC 09may2022
/*
	dod > 2017-12-31 AND dod < 2019-01-01 in Death Data Collection Arm 1
	Filter by event(s): Death Data Colleciton (Arm 1: Deaths)
*/

*****************
**  Formatting **
**    Names    **
*****************
** JC 09may2022: The below was previously done when for 2015 annual report so code disabled

/*
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

rename nm namematch
*/
** Convert names to lower case and strip possible leading/trailing blanks
replace fname = lower(rtrim(ltrim(itrim(fname)))) //2493 changes
replace mname = lower(rtrim(ltrim(itrim(mname)))) //713 changes
replace lname = lower(rtrim(ltrim(itrim(lname)))) //2493 changes

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
count if dupname>0 //162
/* 
Check below list (or Stata Browse window) for cases where namematch=no match but 
there is a pt with same name then:
 (1) check if same pt and remove duplicate pt;
 (2) check if same name but different pt and
	 update namematch variable to reflect this, i.e.
	 namematch=1
*/
//list record_id namematch fname lname nrn dod sex age if dupname>0
sort record_id
//replace namematch=2 if record_id==
replace namematch=1 if record_id==21256|record_id==23722|record_id==19593|record_id==24674|record_id==21235|record_id==22846 ///
					  |record_id==21754|record_id==22773|record_id==19769|record_id==21840|record_id==19455|record_id==21728 ///
					  |record_id==21780|record_id==20893|record_id==21994|record_id==20564|record_id==22816|record_id==21595 ///
					  |record_id==23390|record_id==22909|record_id==23053|record_id==21627|record_id==23169|record_id==20004 ///
					  |record_id==23184|record_id==19302|record_id==23571|record_id==21579|record_id==23333|record_id==20047 ///
					  |record_id==22713|record_id==19925|record_id==23808|record_id==20745|record_id==22331|record_id==20684 ///
					  |record_id==22946|record_id==20609|record_id==22251|record_id==20644|record_id==22027|record_id==21121 ///
					  |record_id==22765
//2 changes

preserve
drop if nrn==.
sort nrn 
quietly by nrn : gen dupnrn = cond(_N==1,0,_n)
sort nrn record_id lname fname
count if dupnrn>0 //0
list record_id namematch fname lname nrn dod sex age if dupnrn>0
restore

//drop if record_id== // deleted

** Final check for duplicates by name and dod 
sort lname fname dod
quietly by lname fname dod: gen dupdod = cond(_N==1,0,_n)
sort lname fname dod record_id
count if dupdod>0 //2
list record_id namematch fname lname nrn dod sex age if dupdod>0
count if dupdod>0 & namematch!=1 //0
drop dupname dupdod
drop if record_id==24065 //this record is a combination of info from record_id 24066 + 24073 so deleted this record in REDcapdb also

count //5017


** JC 09may2022: The below was previously done when for 2015 annual report so code disabled

/*
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
*/

tab cancer ,m
/*
     cancer |
  diagnoses |      Freq.     Percent        Cum.
------------+-----------------------------------
     cancer |      1,293       25.77       25.77
 not cancer |      3,724       74.23      100.00
------------+-----------------------------------
      Total |      5,017      100.00
*/

tab cancer dodyear ,m
/*

    cancer |        dodyear
 diagnoses |      2016       2017 |     Total
-----------+----------------------+----------
    cancer |       640        653 |     1,293 
not cancer |     1,848      1,876 |     3,724 
-----------+----------------------+----------
     Total |     2,488      2,529 |     5,017
*/

** JC 09may2022: The below was previously done when for 2015 annual report so code disabled

/*
** Create cod variable 
gen cod=.
label define cod_lab 1 "Dead of cancer" 2 "Dead of other cause" 3 "Not known" 4 "NA", modify
label values cod cod_lab
label var cod "COD categories"
replace cod=1 if cancer==1 //616 changes
replace cod=2 if cancer==2 //1840 changes
** one unknown causes of death in 2014 data - record_id 12323
replace cod=3 if coddeath=="99"|(regexm(coddeath,"INDETERMINATE")|regexm(coddeath,"UNDETERMINED")) //14 changes
*/

tab cod ,m
/*
     COD categories |      Freq.     Percent        Cum.
--------------------+-----------------------------------
     Dead of cancer |      1,293       25.77       25.77
Dead of other cause |      3,690       73.55       99.32
          Not known |         34        0.68      100.00
--------------------+-----------------------------------
              Total |      5,017      100.00
*/

tab cod dodyear ,m
/*
                    |        dodyear
     COD categories |      2016       2017 |     Total
--------------------+----------------------+----------
     Dead of cancer |       640        653 |     1,293 
Dead of other cause |     1,837      1,853 |     3,690 
          Not known |        11         23 |        34 
--------------------+----------------------+----------
              Total |     2,488      2,529 |     5,017
*/

** JC 09may2022: The below was previously done when for 2015 annual report so code disabled

/*
** Change sex to match cancer dataset
tab sex ,m
rename sex sex_old
gen sex=1 if sex_old==2 //2467 changes
replace sex=2 if sex_old==1 //2587 changes
drop sex_old
label define sex_lab 1 "Female" 2 "Male", modify
label values sex sex_lab
label var sex "Sex"
*/
tab sex ,m
/*
        Sex |      Freq.     Percent        Cum.
------------+-----------------------------------
     Female |      2,468       49.19       49.19
       Male |      2,549       50.81      100.00
------------+-----------------------------------
      Total |      5,017      100.00
*/
tab sex dodyear ,m
/*
           |        dodyear
       Sex |      2016       2017 |     Total
-----------+----------------------+----------
    Female |     1,237      1,231 |     2,468 
      Male |     1,251      1,298 |     2,549 
-----------+----------------------+----------
     Total |     2,488      2,529 |     5,017
*/

********************
**   Formatting   **
** Place of Death **
********************
rename pod placeofdeath
gen pod=.

label define pod_lab 1 "QEH" 2 "At Home" 3 "Geriatric Hospital" ///
					 4 "Con/Nursing Home" 5 "Other Homes" 6 "District Hospital" ///
					 7 "Psychiatric Hospital" 8 "Bayview Hospital" ///
					 9 "Sandy Crest/FMH/Sparman/Clinic" 10 "Bridgetown Port" ///
					 11 "Other/Hotel" 99 "ND", modify
label values pod pod_lab
label var pod "Place of Death from National Register"

replace pod=1 if regexm(placeofdeath, "ELIZABETH HOSP") & pod==. //23 changes
replace pod=1 if regexm(placeofdeath, "QUEEN ELZ") & pod==. //0 changes
replace pod=1 if regexm(placeofdeath, "QEH") & pod==. //2664 changes
replace pod=3 if regexm(placeofdeath, "GERIATRIC") & pod==. //128 changes
replace pod=3 if regexm(placeofdeath, "GERIACTIRC") & pod==. //0 chagnes
replace pod=3 if regexm(placeofdeath, "GERIACTRIC") & pod==. //0 chagnes
replace pod=5 if regexm(placeofdeath, "CHILDRENS HOME") & pod==. //0 chagnes
replace pod=4 if regexm(placeofdeath, "HOME") & pod==. //179 changes
replace pod=4 if regexm(placeofdeath, "ELDERLY") & pod==. //7 changes
replace pod=4 if regexm(placeofdeath, "SERENITY MANOR") & pod==. //0 changes
replace pod=4 if regexm(placeofdeath, "ADULT CARE") & pod==. //0 changes
replace pod=4 if regexm(placeofdeath, "AGE ASSIST") & pod==. //0 changes
replace pod=4 if regexm(placeofdeath, "SENIOR") & pod==. //6 changes
replace pod=4 if regexm(placeofdeath, "RETREAT") & pod==. //23 changes
replace pod=4 if regexm(placeofdeath, "RETIREMENT") & pod==. //2 changes
replace pod=4 if regexm(placeofdeath, "NURSING") & pod==. //4 changes
replace pod=5 if regexm(placeofdeath, "PRISON") & pod==. //0 changes
replace pod=5 if regexm(placeofdeath, "POLYCLINIC") & pod==. //1 change
replace pod=5 if regexm(placeofdeath, "MINISTRIES") & pod==. //0 changes
replace pod=5 if regexm(placeofdeath, "HIGHWAY") & pod==. //5 changes - FOR THESE CHECK COD TO DIFFERENTIATE BETWEEN ROAD ACCIDENT AND AT HOME DEATH
replace pod=5 if regexm(placeofdeath, "ROUNDABOUT") & pod==. //2 changes - FOR THESE CHECK COD TO DIFFERENTIATE BETWEEN ROAD ACCIDENT AND AT HOME DEATH
replace pod=5 if regexm(placeofdeath, "JUNCTION") & pod==. //0 changes - FOR THESE CHECK COD TO DIFFERENTIATE BETWEEN ROAD ACCIDENT AND AT HOME DEATH
replace pod=6 if regexm(placeofdeath, "STRICT HOSP") & pod==. //35 changes
replace pod=6 if regexm(placeofdeath, "GORDON CUMM") & pod==. //3 changes
replace pod=7 if regexm(placeofdeath, "PSYCHIATRIC HOSP") & pod==. //11 changes
replace pod=7 if regexm(placeofdeath, "PSYCIATRIC HOSP") & pod==. //0 changes
replace pod=8 if regexm(placeofdeath, "BAYVIEW") & pod==. //45 changes
replace pod=9 if regexm(placeofdeath, "SANDY CREST") & pod==. //6 changes
replace pod=9 if regexm(placeofdeath, "FMH CLINIC") & pod==. //0 changes
replace pod=9 if regexm(placeofdeath, "FMH EMERGENCY") & pod==. //0 changes
replace pod=9 if regexm(placeofdeath, "SPARMAN CLINIC") & pod==. //4 changes
replace pod=9 if regexm(placeofdeath, "CLINIC") & pod==. //2 changes
replace pod=10 if regexm(placeofdeath, "BRIDGETOWN PORT") & pod==. //8 changes
replace pod=11 if regexm(placeofdeath, "HOTEL") & pod==. //1 change
replace pod=99 if placeofdeath=="" & pod==. //0 changes
replace pod=99 if placeofdeath=="99" //16 changes

order record_id address placeofdeath parish deathparish coddeath
count if pod==. //1865 - check address against placeofdeath in Stata Browse window
//list record_id placeofdeath if pod==.
count if pod==. & parish!=deathparish //126 - check COD to determine if road accident or at home death
//list record_id address parish placeofdeath deathparish if pod==. & parish!=deathparish
replace pod=2 if pod==. & address==placeofdeath //560 changes
replace pod=2 if pod==. & parish==deathparish //1179 changes
replace pod=11 if pod==. & parish!=deathparish & address!=placeofdeath //126 changes

//drop placeofdeath
tab pod ,m //none unassigned


** JC 09may2022: The below was previously done when for 2015 annual report so code disabled

/*
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
*/

order record_id pname fname mname lname address parish age dod
count if natregno=="" & nrn!=. //
count if natregno=="" //239
count if natregno=="" & age!=0 //189
count if natregno=="" & age!=0 & !(strmatch(strupper(address), "*BRIDGETOWN PORT*")) //176 - checked against 2021 electoral list + updated NRN in REDCapdb
count if age==. //0

** Add missing NRNs flagged above with list of NRNs manually created using electoral list (this ensures dofile remains de-identified)
preserve
clear
import excel using "`datapath'\version04\2-working\MissingNRNs_mort_20220512.xlsx" , firstrow case(lower)
format elec_nrn %15.0g
replace elec_natregno=subinstr(elec_natregno,"-","",.)
save "`datapath'\version04\2-working\electoral_missingnrn" ,replace
restore
merge 1:1 record_id using "`datapath'\version04\2-working\electoral_missingnrn" ,force
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                         5,004
        from master                     5,004  (_merge==1)
        from using                          0  (_merge==2)

    Matched                                13  (_merge==3)
    -----------------------------------------
*/
replace nrn=elec_nrn if _merge==3 //3 changes
replace natregno=elec_natregno if _merge==3 //3 changes
drop elec_* _merge
erase "`datapath'\version04\2-working\electoral_missingnrn.dta"

** Check dob** Creating dob variable as none in national death data
** perform data cleaning on the age variable
order record_id natregno age
count if natregno==""|natregno=="." //226
gen tempvarn=6 if natregno==""|natregno=="."
gen yr = substr(natregno,1,1) if tempvarn!=6
gen yr1=. if tempvarn!=6
replace yr1 = 20 if yr=="0"
replace yr1 = 19 if yr!="0"
replace yr1 = 99 if natregno=="99"
order record_id natregno nrn age yr yr1
** Check age and yr1 in Stata browse
//list record_id natregno nrn age yr1 if yr1==20
** Initially need to run this code separately from entire dofile to determine which nrnyears should be '19' instead of '20' depending on age, e.g. for age 107 nrnyear=19
replace yr1 = 19 if record_id==20866
replace yr1 = 19 if record_id==21017

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
rename nrn1 dobcheck
gen age2 = (dod - dobcheck)/365.25
gen ageyrs=int(age2)
count if tempvarn!=6 & age!=ageyrs //6
sort record_id
list record_id fname lname address age ageyrs nrn natregno dob dobcheck dod yr1 if tempvarn!=6 & age!=ageyrs, string(20) //check against electoral list
count if dobcheck!=. & dob==. //4,791
replace dob=dobcheck if dobcheck!=. & dob==. //4,791 changes
replace age=ageyrs if tempvarn!=6 & age!=ageyrs & record_id!=24637 & record_id!=24537 //4 changes
drop day month dyear nrnyr yr yr1 year2 nrndob age2 ageyrs tempvarn dobcheck

** Check age
gen age2 = (dod - dob)/365.25
gen checkage2=int(age2)
drop age2
count if dob!=. & dod!=. & age!=checkage2 //3
list record_id fname lname dod dob age checkage2 if dob!=. & dod!=. & age!=checkage2 //2 correct
//replace age=checkage2 if dob!=. & dod!=. & age!=checkage2 //0 changes
drop checkage2

** Check no missing dxyr so this can be used in analysis
tab dodyear ,m //5017 - none missing

count if dodyear!=year(dod) //0
//list pid record_id dod dodyear if dodyear!=year(dod)
replace dodyear=year(dod) if dodyear!=year(dod) //0 changes

label data "BNR MORTALITY data 2016 + 2017"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version04\3-output\2016_2017_prep mort_ALL" ,replace
note: TS This dataset is used for analysis of age-standardized mortality rates
note: TS This dataset includes all 2016 + 2017 CODs

*******************
** Check for MPs **
**   in CODs     **
*******************
count //5017

//list record_id
//list cod1a
tab cancer ,m //646 cancer CODs
tab cancer dodyear ,m //640 cancer CODS in 2016; 653 in 2017
drop if cancer!=1 //3,724 deleted

** MPs found above when assigning cancer variable in checking causes of death
sort coddeath record_id
order record_id coddeath //check Stata Browse window for MPs in CODs

STOP

** Create duplicate observations for MPs in CODs
expand=2 if record_id==24223, gen (dupobs1)
expand=2 if record_id==24310, gen (dupobs2)
expand=2 if record_id==25389, gen (dupobs3)
//(GIST not stated as malignant so ineligible?? - yes, see CR5db pid 20130343)
expand=2 if record_id==25402, gen (dupobs4)
expand=2 if record_id==25618, gen (dupobs5)
expand=2 if record_id==25628, gen (dupobs6)
expand=2 if record_id==25822, gen (dupobs7)
expand=2 if record_id==25914, gen (dupobs8)
expand=2 if record_id==25942, gen (dupobs9)
expand=2 if record_id==26148, gen (dupobs10)
expand=2 if record_id==26172, gen (dupobs11)
expand=2 if record_id==26258, gen (dupobs12)
expand=2 if record_id==26407, gen (dupobs13)
expand=2 if record_id==26408, gen (dupobs14)
expand=2 if record_id==26540, gen (dupobs15)
//M9811(9) vs M9837(10) and M9875(8)
//pid 20130770 CML in 2013 that transformed to either T-ALL or B-ALL in 2015 COD states C-CELL!
//M9811 (B-ALL) chosen as research shows "With few exceptions, Ph-positive ALL patients are diagnosed with B-ALL "
//https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4896164/
display `"{browse "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4896164/":Ph+ALL}"'

replace coddeath=subinstr(coddeath,"OLON","COLON",.) if record_id==26655 //colon spelt olon when checking above list
replace coddeath=subinstr(coddeath,"STOMALIA","STOMACH",.) if record_id==25971 //stomach spelt stomalia when checking above list


count //2,543

** Create variables to identify patients vs tumours
gen ptrectot=.
replace ptrectot=1 if dupobs1==0|dupobs2==0|dupobs3==0|dupobs4==0 ///
					 |dupobs5==0|dupobs6==0|dupobs7==0|dupobs8==0 ///
					 |dupobs9==0|dupobs10==0|dupobs11==0|dupobs12==0 ///
					 |dupobs13==0|dupobs14==0|dupobs15==0 //2,542 changes
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
count //2543
tab cancer ,m //661 cancers

** Note: Although siteiarc doesn't need sub-site, the specific icd10 code was used, where applicable
display `"{browse "https://icd.who.int/browse10/2015/en#/C09":ICD10,v2015}"'

** Use Stata browse instead of lists
order record_id coddeath did
sort record_id

gen icd10=""

count if regexm(coddeath,"LIP") & icd10=="" //2 - not lip so no replace
//list record_id coddeath if regexm(coddeath,"LIP"),string(120)

count if regexm(coddeath,"TONGUE") & icd10=="" //2 - all tongue, NOS
//list record_id coddeath if regexm(coddeath,"TONGUE"),string(120)
replace icd10="C029" if regexm(coddeath,"TONGUE") & icd10=="" //5 changes

count if regexm(coddeath,"MOUTH") & icd10=="" //0
//list record_id coddeath if regexm(coddeath,"MOUTH"),string(120)

count if regexm(coddeath,"SALIVARY") & icd10=="" //0
//list record_id coddeath if regexm(coddeath,"SALIVARY"),string(120)

count if regexm(coddeath,"TONSIL") & icd10=="" //1
//list record_id coddeath if regexm(coddeath,"TONSIL"),string(120)
replace icd10="C099" if regexm(coddeath,"TONSIL") & icd10=="" //1 change

count if regexm(coddeath,"OROPHARYNX") & icd10=="" //2
//list record_id coddeath if regexm(coddeath,"OROPHARYNX"),string(120)
replace icd10="C109" if regexm(coddeath,"OROPHARYNX") & icd10=="" //2 changes

count if regexm(coddeath,"NASOPHARYNX") & icd10=="" //0
//list record_id coddeath if regexm(coddeath,"NASOPHARYNX"),string(120)

count if regexm(coddeath,"HYPOPHARYNX") & icd10=="" //1
//list record_id coddeath if regexm(coddeath,"HYPOPHARYNX"),string(120)
replace icd10="C139" if regexm(coddeath,"HYPOPHARYNX") & icd10=="" //1 change

count if (regexm(coddeath,"PHARYNX")|regexm(coddeath,"PHARNYX")) & icd10=="" //0
//list record_id coddeath if (regexm(coddeath,"PHARYNX")|regexm(coddeath,"PHARNYX")) & icd10=="",string(120)0

count if (regexm(coddeath,"OESOPHAG")|regexm(coddeath,"ESOPHAG")) & icd10=="" //9
replace icd10="C159" if (regexm(coddeath,"OESOPHAG")|regexm(coddeath,"ESOPHAG")) & icd10=="" & record_id!=26695 //8 changes
replace icd10="C160" if record_id==26695

count if (regexm(coddeath,"STOMACH")|regexm(coddeath,"GASTR"))  & !(strmatch(strupper(coddeath), "*GASTROINTESTINAL BLEED*"))  & !(strmatch(strupper(coddeath), "*GASTROINTESTINAL HAEMORR*"))  & !(strmatch(strupper(coddeath), "*GASTROENTER*")) & icd10=="" //33
replace icd10="C169" if (regexm(coddeath,"STOMACH")|regexm(coddeath,"GASTR"))  & !(strmatch(strupper(coddeath), "*GASTROINTESTINAL BLEED*"))  & !(strmatch(strupper(coddeath), "*GASTROINTESTINAL HAEMORR*"))  & !(strmatch(strupper(coddeath), "*GASTROENTER*")) & icd10=="" //33 changes
replace icd10="C164" if record_id==25025 //pylorus
replace icd10="C509" if record_id==26172 & did=="T2" //breast MP
replace icd10="C189" if record_id==25813 //colon
replace icd10="C269" if record_id==25906|record_id==25826|record_id==26392 //gastronintestinal malignancy
replace icd10="C349" if record_id==25438 //lung
replace icd10="C61" if record_id==25829 //prostate

count if (regexm(coddeath,"DUODEN")|regexm(coddeath,"JEJUN")|regexm(coddeath,"ILEUM")|regexm(coddeath,"SMALL")) & !(strmatch(strupper(coddeath), "*SMALL CEL*")) & !(strmatch(strupper(coddeath), "*LARYNGEAL*")) & icd10=="" //8
replace icd10="C179" if (regexm(coddeath,"DUODEN")|regexm(coddeath,"JEJUN")|regexm(coddeath,"ILEUM")|regexm(coddeath,"SMALL")) & !(strmatch(strupper(coddeath), "*SMALL CEL*")) & !(strmatch(strupper(coddeath), "*LARYNGEAL*")) & icd10=="" //8 changes
replace icd10="C509" if record_id==24603 //breast
replace icd10="C349" if record_id==26102 //lung
replace icd10="C259" if record_id==26747 //pancreas
replace icd10="C56" if record_id==25125 //ovary
replace icd10="C61" if record_id==25400 //prostate

count if (regexm(coddeath,"CECUM")|regexm(coddeath,"APPEND")|regexm(coddeath,"COLON")) & !(strmatch(strupper(coddeath), "*COLONIC POLYPS*")) & icd10=="" //62
replace icd10="C189" if (regexm(coddeath,"CECUM")|regexm(coddeath,"APPEND")|regexm(coddeath,"COLON")) & !(strmatch(strupper(coddeath), "*COLONIC POLYPS*")) & icd10=="" //62 changes
replace icd10="C182" if record_id==24470|record_id==24707 //2 changes
replace icd10="C187" if record_id==25405|record_id==26229|record_id==26567 //3 changes
replace icd10="C61" if record_id==25402 & did=="T2" //prostate MP
replace icd10="C439" if record_id==25822 & did=="T2" //melanoma MP
replace icd10="C20" if record_id==26103 //rectum
replace icd10="C19" if record_id==25053 //colorectal

count if (regexm(coddeath,"COLORECTAL")|regexm(coddeath,"RECTO")) & icd10=="" //7
replace icd10="C19" if (regexm(coddeath,"COLORECT")|regexm(coddeath,"RECTO")) & icd10=="" //7 changes

count if (regexm(coddeath,"RECTUM")|regexm(coddeath,"RECTAL")) & !(strmatch(strupper(coddeath), "*ANORECT*")) & icd10=="" //17
replace icd10="C20" if (regexm(coddeath,"RECTUM")|regexm(coddeath,"RECTAL")) & !(strmatch(strupper(coddeath), "*ANORECT*")) & icd10=="" //17 changes

count if (regexm(coddeath,"ANUS")|regexm(coddeath,"ANORECT")|regexm(coddeath,"ANAL")) & icd10=="" //1 - no replace
//replace icd10="C218" if (regexm(coddeath,"ANUS")|regexm(coddeath,"ANORECT")|regexm(coddeath,"ANAL")) & icd10=="" //2 changes
replace icd10="C349" if record_id==24625 //lung

count if (regexm(coddeath,"LIVER")|regexm(coddeath,"BILE")|regexm(coddeath,"HEPATO")) & !(strmatch(strupper(coddeath), "*CHOLANGIOCAR*")) & icd10=="" //16
replace icd10="C250" if record_id==24300 //pancreas
replace icd10="C259" if record_id==25085|record_id==25892|record_id==26701 //pancreas
replace icd10="C809" if record_id==25545|record_id==24654|record_id==25492 //PSU, NOS
replace icd10="C800" if record_id==26808 //PSU
replace icd10="C61" if record_id==25915 //prostate
replace icd10="C509" if record_id==26418|record_id==26663 //breast
replace icd10="C220" if record_id==24331|record_id==25171|record_id==25414|record_id==26597|record_id==26849

count if regexm(coddeath,"CHOLANGIO") & icd10=="" //4
replace icd10="C221" if regexm(coddeath,"CHOLANGIO") & icd10=="" //4 changes

count if (regexm(coddeath,"GALLBLAD")|regexm(coddeath,"GALL BLAD")) & icd10=="" //3
replace icd10="C23" if (regexm(coddeath,"GALLBLAD")|regexm(coddeath,"GALL BLAD")) & icd10=="" //3 changes

count if regexm(coddeath,"BILIARY") & icd10=="" //0

count if (regexm(coddeath,"PANCREA") & regexm(coddeath,"HEAD")) & icd10=="" //0
//replace icd10="C250" if (regexm(coddeath,"PANCREA") & regexm(coddeath,"HEAD")) & icd10=="" //3 changes
count if regexm(coddeath,"PANCREA") & icd10=="" //28
replace icd10="C259" if regexm(coddeath,"PANCREA") & icd10=="" //28 changes
replace icd10="C509" if record_id==25389 & did=="T2" //breast MP

count if (regexm(coddeath,"NASAL")|regexm(coddeath,"EAR")) & icd10=="" //23-no nasal/ear so no replace

count if regexm(coddeath,"SINUS") & icd10=="" //3-not sinus so no replace

count if (regexm(coddeath,"LARYNX")|regexm(coddeath,"LARYNG")|regexm(coddeath,"GLOTTI")|regexm(coddeath,"VOCAL")) & icd10=="" //4
replace icd10="C329" if (regexm(coddeath,"LARYNX")|regexm(coddeath,"LARYNG")|regexm(coddeath,"GLOTTI")|regexm(coddeath,"VOCAL")) & icd10=="" //4 changes
replace icd10="C61" if record_id==25618 & did=="T2" //prostate

count if regexm(coddeath,"TRACHEA") & icd10=="" //1- no trachea so no replace

count if (regexm(coddeath,"LUNG")|regexm(coddeath,"BRONCH")) & icd10=="" //48
replace icd10="C349" if (regexm(coddeath,"LUNG")|regexm(coddeath,"BRONCH")) & icd10=="" //48 changes
replace icd10="C809" if record_id==24265|record_id==24569 //PSU, NOS
replace icd10="C509" if record_id==24368|record_id==24774|record_id==25448|record_id==25652|record_id==25751|record_id==25820|record_id==25939 //breast
replace icd10="C541" if record_id==24593|record_id==25253 //endometrium
replace icd10="C539" if record_id==25223 //cervix
replace icd10="C61" if (record_id==25942 & did=="T2") | (record_id==26148 & did=="T2") | record_id==26861 //prostate + MPs
replace icd10="C55" if record_id==26451 //uterus
replace icd10="C56" if record_id==26473 //ovary
replace icd10="C73" if record_id==26520 //thyroid

count if regexm(coddeath,"THYMUS") & icd10=="" //0

count if (regexm(coddeath,"HEART")|regexm(coddeath,"MEDIASTIN")|regexm(coddeath,"PLEURA")) & icd10=="" //28-none found so no replace
replace icd10="C809" if record_id==25753|record_id==26083|record_id==26191 //PSU, NOS

count if (regexm(coddeath,"BONE")|regexm(coddeath,"OSTEO")|regexm(coddeath,"CARTILAGE")) & icd10=="" //5-none found so no replace
replace icd10="C56" if record_id==25332 //ovary
replace icd10="C509" if record_id==25352 //breast
replace icd10="C541" if record_id==25453 //endometrium
replace icd10="C229" if record_id==26826 //liver

count if (regexm(coddeath,"SKIN")|regexm(coddeath,"MELANOMA")|regexm(coddeath,"SQUAMOUS")|regexm(coddeath,"BASAL")) & icd10=="" //12
replace icd10="C439" if (regexm(coddeath,"SKIN")|regexm(coddeath,"MELANOMA")|regexm(coddeath,"SQUAMOUS")|regexm(coddeath,"BASAL")) & icd10=="" //12 changes
replace icd10="C449" if record_id==24430 | (record_id==26407 & did=="T1") //SCC, BCC, NOS
replace icd10="C61" if record_id==26407 & did=="T2" //prostate MP
replace icd10="C441" if record_id==24579 //SCC, BCC, eye
replace icd10="C539" if record_id==24887 //cervix
replace icd10="C109" if record_id==24899 //oropharynx
replace icd10="C911" if record_id==25628 & did=="T2" //CLL
replace icd10="C443" if record_id==26672 //SCC, BCC, face
replace icd10="C444" if record_id==26715 //SCC, BCC, head

count if (regexm(coddeath,"MESOTHELIOMA")|regexm(coddeath,"KAPOSI")|regexm(coddeath,"NERVE")|regexm(coddeath,"PERITON")) & icd10=="" //1
replace icd10="C459" if record_id==24405

count if regexm(coddeath,"BREAST") & icd10=="" //92
//list record_id coddeath if regexm(coddeath,"BREAST"),string(120)
replace icd10="C509" if regexm(coddeath,"BREAST") & icd10=="" //92 changes
replace icd10="C269" if record_id==24223 & did=="T2" //gastronintestinal malignancy MP
replace icd10="C541" if record_id==24310 & did=="T1" //endometrium MP
replace icd10="C859" if record_id==26258 & did=="T1" //lymphoma MP
replace icd10="C56" if record_id==26408 & did=="T2" //ovary MP

count if regexm(coddeath,"VULVA") & icd10=="" //0
//replace icd10="C519" if regexm(coddeath,"VULVA") & icd10=="" //0 changes

count if regexm(coddeath,"VAGINA") & icd10=="" //2
replace icd10="C52" if regexm(coddeath,"VAGINA") & icd10=="" //2 changes


count if (regexm(coddeath,"CERVICAL")|regexm(coddeath,"CERVIX")) & icd10=="" //6
replace icd10="C539" if (regexm(coddeath,"CERVICAL")|regexm(coddeath,"CERVIX")) & icd10=="" //6 changes

count if (regexm(coddeath,"ENDOMETRI")|regexm(coddeath,"CORPUS")) & icd10=="" //17
replace icd10="C541" if (regexm(coddeath,"ENDOMETRI")|regexm(coddeath,"CORPUS")) & icd10=="" //17 changes

count if (regexm(coddeath,"UTERINE")|regexm(coddeath,"UTERUS")) & icd10=="" //1
replace icd10="C55" if (regexm(coddeath,"UTERINE")|regexm(coddeath,"UTERUS")) & icd10=="" //1 change

count if (regexm(coddeath,"OVARY")|regexm(coddeath,"OVARIAN")) & icd10=="" //11
replace icd10="C56" if (regexm(coddeath,"OVARY")|regexm(coddeath,"OVARIAN")) & icd10=="" //11 changes

count if (regexm(coddeath,"FALLOPIAN")|regexm(coddeath,"FEMALE")) & icd10=="" //0

count if (regexm(coddeath,"PENIS")|regexm(coddeath,"PENILE")) & icd10=="" //1
replace icd10="C609" if (regexm(coddeath,"PENIS")|regexm(coddeath,"PENILE")) & icd10=="" //1 change

count if regexm(coddeath,"PROSTATE") & icd10=="" //125
replace icd10="C61" if regexm(coddeath,"PROSTATE") & icd10=="" //125 changes
replace icd10="C920" if record_id==24571 //AML
replace icd10="C859" if record_id==25914 & did=="T2" //NHL MP
replace icd10="C719" if record_id==26540 & did=="T2" //brain MP

count if (regexm(coddeath,"TESTIS")|regexm(coddeath,"TESTES")) & icd10=="" //0

count if (regexm(coddeath,"SCROT")|regexm(coddeath,"MALE")) & icd10=="" //0

count if (regexm(coddeath,"KIDNEY")|regexm(coddeath,"RENAL")) & icd10=="" //28
replace icd10="C64" if (regexm(coddeath,"KIDNEY")|regexm(coddeath,"RENAL")) & icd10=="" //28 changes
replace icd10="C851" if record_id==24293 //b-cell lymphoma
replace icd10="C73" if record_id==24346 //thyroid
replace icd10="C800" if record_id==24489|record_id==25251|record_id==25336|record_id==26154 //PSU
replace icd10="C809" if record_id==24561|record_id==25344|record_id==26007 //PSU, NOS
replace icd10="C859" if record_id==25132 //lymphoma NOS
replace icd10="C900" if record_id==25666|record_id==25709|record_id==25888|record_id==25889|record_id==26477|record_id==26645 //MM
replace icd10="C679" if record_id==25896 //bladder
replace icd10="C189" if record_id==26460 //colon

count if (regexm(coddeath,"BLADDER")|regexm(coddeath,"URIN")) & icd10=="" //13
replace icd10="C679" if (regexm(coddeath,"BLADDER")|regexm(coddeath,"URIN")) & icd10=="" //13 changes
replace icd10="C579" if record_id==26155 //genitourinary tract (F)

count if (regexm(coddeath,"EYE")|regexm(coddeath,"RETINA")|regexm(coddeath,"NEURO")) & icd10=="" //1
//replace icd10="C699" if (regexm(coddeath,"EYE")|regexm(coddeath,"RETINA")|regexm(coddeath,"NEURO")) & icd10=="" //1 changes
replace icd10="C809" if record_id==25129 //PSU, NOS

count if (regexm(coddeath,"ASTROCY")|regexm(coddeath,"MULTIFORME")|regexm(coddeath,"BRAIN")) & icd10=="" //5
replace icd10="C719" if (regexm(coddeath,"ASTROCY")|regexm(coddeath,"MULTIFORME")|regexm(coddeath,"BRAIN")) & icd10=="" //5 changes
replace icd10="C809" if record_id==24566 //PSU, NOS

count if (regexm(coddeath,"THYROID")|regexm(coddeath,"ADRENAL")|regexm(coddeath,"ENDOCRI")) & icd10=="" //2
replace icd10="C73" if (regexm(coddeath,"THYROID")|regexm(coddeath,"ADRENAL")|regexm(coddeath,"ENDOCRI")) & icd10=="" //2 changes

count if (regexm(coddeath,"UNKNOWN")|regexm(coddeath,"CULT")) & icd10=="" //17
replace icd10="C800" if (regexm(coddeath,"UNKNOWN")|regexm(coddeath,"CULT")) & icd10=="" //17 changes
replace icd10="C269" if record_id==24601|record_id==25215 //gastronintestinal malignancy

count if (regexm(coddeath,"HODGKIN") & regexm(coddeath,"NON")) & icd10=="" //6
replace icd10="C859" if (regexm(coddeath,"HODGKIN") & regexm(coddeath,"NON")) & icd10=="" //6 changes
replace icd10="C857" if record_id==25965|record_id==26135 //NHL large cell type

count if regexm(coddeath,"HODGKIN") & icd10=="" //0
replace icd10="C819" if regexm(coddeath,"HODGKIN") & icd10=="" //0 changes

count if (regexm(coddeath,"FOLLICUL") & regexm(coddeath,"LYMPH")) & icd10=="" //0

count if (regexm(coddeath,"MULTIPLE") & regexm(coddeath,"OMA")) & icd10=="" //13
replace icd10="C900" if (regexm(coddeath,"MULTIPLE") & regexm(coddeath,"OMA")) & icd10=="" //13 changes

count if regexm(coddeath,"PLASMACYTOMA") & icd10=="" //0
//replace icd10="C903" if regexm(coddeath,"PLASMACYTOMA") & icd10=="" //1 change

count if regexm(coddeath,"SEZARY") & icd10=="" //0
//replace icd10="C841" if regexm(coddeath,"SEZARY") & icd10=="" //1 change

count if (regexm(coddeath,"LYMPH")|regexm(coddeath,"EMIA")|regexm(coddeath,"PHOMA")) & icd10=="" //22
replace icd10="C950" if record_id==24270|record_id==25330|record_id==25637 //acute leukaemia
replace icd10="C920" if record_id==24556|record_id==24809|record_id==24846|record_id==25210|record_id==25325|record_id==25610|record_id==26126 //AML
replace icd10="C919" if record_id==24890 //lymphoid leukaemia
replace icd10="C851" if record_id==24981 //b-cell lymphoma/lympho.disorder
replace icd10="C910" if record_id==25045 //ALL, NOS
replace icd10="C833" if record_id==25816|record_id==26328 //diffuse large b-cell lymphoma
replace icd10="C914" if record_id==26049 //hairy cell leukaemia
replace icd10="C911" if record_id==26061|record_id==26213|record_id==26832 //CLL
replace icd10="C915" if record_id==26175|record_id==26279 //ALL, T-cell
replace icd10="C959" if record_id==26267 //leukaemia, NOS


count if icd10=="" //33
replace icd10="C61" if record_id==24314|record_id==25100|record_id==26030|record_id==26192 //prostate
replace icd10="C051" if record_id==24434 //soft palate
replace icd10="C410" if record_id==24563 //maxilla
replace icd10="C549" if record_id==24596 //corpus uteri, NOS
replace icd10="C809" if record_id==24624|record_id==25112|record_id==25246|record_id==25501|record_id==26241|record_id==26403|record_id==26456 //PSU, NOS
replace icd10="C050" if record_id==24781 //hard palate
replace icd10="C119" if record_id==24901|record_id==25558|record_id==26613 //nasopharynx
drop if record_id==24903|record_id==26781 //meningioma NOS is beh /0 - 2 deleted
replace icd10="C492" if record_id==25181 //sarcoma, knee
replace icd10="D469" if record_id==25409 //MDS
replace icd10="C491" if record_id==25615 //sarcoma, upper limb
replace icd10="C37" if record_id==25701 //thymus
replace icd10="C509" if record_id==25956 //breast
replace icd10="C720" if record_id==25964 //spinal cord
replace icd10="C499" if record_id==26069 //angiosarcoma
replace icd10="C189" if record_id==26097 //colon
replace icd10="C444" if record_id==26147 //carcinoma skin, neck
replace icd10="C55" if record_id==26151 //uterus
replace icd10="C109" if record_id==26306 //oropharynx
replace icd10="C900" if record_id==26615 //MM
replace icd10="C840" if record_id==26636 //mycosis fungoides


tab icd10 ,m

** Check icd10 for MP CODs
duplicates tag record_id, gen(dup_id) //all correct
sort record_id
//list record_id icd10 coddeath ptrectot if dup_id>0, nolabel sepby(record_id) string(120)
//tab icd10 ,m

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
replace siteiarc=2 if (regexm(icd10,"C01")|regexm(icd10,"C02")) //2 changes
replace siteiarc=3 if (regexm(icd10,"C03")|regexm(icd10,"C04")|regexm(icd10,"C05")|regexm(icd10,"C06")) //2 changes
replace siteiarc=4 if (regexm(icd10,"C07")|regexm(icd10,"C08")) //0 changes
replace siteiarc=5 if regexm(icd10,"C09") //1 change
replace siteiarc=6 if regexm(icd10,"C10") //4 changes
replace siteiarc=7 if regexm(icd10,"C11") //3 changes
replace siteiarc=8 if (regexm(icd10,"C12")|regexm(icd10,"C13")) //1 change
replace siteiarc=9 if regexm(icd10,"C14") //0 changes
replace siteiarc=10 if regexm(icd10,"C15") //8 changes
replace siteiarc=11 if regexm(icd10,"C16") //27 changes
replace siteiarc=12 if regexm(icd10,"C17") //3 changes
replace siteiarc=13 if regexm(icd10,"C18") //61 changes
replace siteiarc=14 if (regexm(icd10,"C19")|regexm(icd10,"C20")) //26 changes
replace siteiarc=15 if regexm(icd10,"C21") //0 changes
replace siteiarc=16 if regexm(icd10,"C22") //10 changes
replace siteiarc=17 if (regexm(icd10,"C23")|regexm(icd10,"C24")) //3 changes
replace siteiarc=18 if regexm(icd10,"C25") //32 changes
replace siteiarc=19 if (regexm(icd10,"C30")|regexm(icd10,"C31")) //0 changes
replace siteiarc=20 if regexm(icd10,"C32") //3 changes
replace siteiarc=21 if (regexm(icd10,"C33")|regexm(icd10,"C34")) //33 changes
replace siteiarc=22 if (regexm(icd10,"C37")|regexm(icd10,"C38")) //1 change
replace siteiarc=23 if (regexm(icd10,"C40")|regexm(icd10,"C41")) //1 change
replace siteiarc=24 if regexm(icd10,"C43") //4 changes
replace siteiarc=25 if regexm(icd10,"C44") //6 changes
replace siteiarc=26 if regexm(icd10,"C45") //1 change
replace siteiarc=27 if regexm(icd10,"C46") //0 changes
replace siteiarc=28 if (regexm(icd10,"C47")|regexm(icd10,"C49")) //3 changes
replace siteiarc=29 if regexm(icd10,"C50") //102 changes
replace siteiarc=30 if regexm(icd10,"C51") //0 changes
replace siteiarc=31 if regexm(icd10,"C52") //2 changes
replace siteiarc=32 if regexm(icd10,"C53") //8 changes
replace siteiarc=33 if regexm(icd10,"C54") //22 changes
replace siteiarc=34 if regexm(icd10,"C55") //3 changes
replace siteiarc=35 if regexm(icd10,"C56") //15 change
replace siteiarc=36 if regexm(icd10,"C57") //1 change
replace siteiarc=37 if regexm(icd10,"C58") //0 changes
replace siteiarc=38 if regexm(icd10,"C60") //1 change
replace siteiarc=39 if regexm(icd10,"C61") //135 changes
replace siteiarc=40 if regexm(icd10,"C62") //0 changes
replace siteiarc=41 if regexm(icd10,"C63") //0 changes
replace siteiarc=42 if regexm(icd10,"C64") //10 changes
replace siteiarc=43 if regexm(icd10,"C65") //0 changes
replace siteiarc=44 if regexm(icd10,"C66") //0 changes
replace siteiarc=45 if regexm(icd10,"C67") //13 changes
replace siteiarc=46 if regexm(icd10,"C68") //0 changes
replace siteiarc=47 if regexm(icd10,"C69") //0 changes
replace siteiarc=48 if (regexm(icd10,"C70")|regexm(icd10,"C71")|regexm(icd10,"C72")) //6 changes
replace siteiarc=49 if regexm(icd10,"C73") //4 changes
replace siteiarc=50 if regexm(icd10,"C74") //0 changes
replace siteiarc=51 if regexm(icd10,"C75") //0 changes
replace siteiarc=52 if regexm(icd10,"C81") //0 changes
replace siteiarc=53 if (regexm(icd10,"C82")|regexm(icd10,"C83")|regexm(icd10,"C84")|regexm(icd10,"C85")|regexm(icd10,"C86")|regexm(icd10,"C96")) //14 changes
replace siteiarc=54 if regexm(icd10,"C88") //0 changes
replace siteiarc=55 if regexm(icd10,"C90") //20 changes
replace siteiarc=56 if regexm(icd10,"C91") //9 changes
replace siteiarc=57 if (regexm(icd10,"C92")|regexm(icd10,"C93")|regexm(icd10,"C94")) //8 changes
replace siteiarc=58 if regexm(icd10,"C95") //4 changes
replace siteiarc=59 if regexm(icd10,"D47") //0 changes
replace siteiarc=60 if regexm(icd10,"D46") //1 change
replace siteiarc=61 if (regexm(icd10,"C26")|regexm(icd10,"C39")|regexm(icd10,"C48")|regexm(icd10,"C76")|regexm(icd10,"C80")) //46 changes
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
replace siteiarchaem=1 if icd10=="C859"|icd10=="C851"|icd10=="C826"|icd10=="C969" //9 changes
replace siteiarchaem=2 if icd10=="C819"|icd10=="C814"|icd10=="C813"|icd10=="C812"|icd10=="C811"|icd10=="C810" //0 changes
replace siteiarchaem=3 if icd10=="C830"|icd10=="C831"|icd10=="C833"|icd10=="C837"|icd10=="C838"|icd10=="C857"|icd10=="C859"|icd10=="C852"|icd10=="C829"|icd10=="C821"|icd10=="C820"|icd10=="C822"|icd10=="C420"|icd10=="C421"|icd10=="C424"|icd10=="C884"|regexm(icd10,"C77") //11 changes
replace siteiarchaem=4 if icd10=="C840"|icd10=="C841"|icd10=="C844"|icd10=="C865"|icd10=="C863"|icd10=="C848"|icd10=="C838"|icd10=="C846"|icd10=="C861"|icd10=="C862"|icd10=="C866"|icd10=="C860" //1 change
replace siteiarchaem=5 if icd10=="C845"|icd10=="C835" //0 changes
replace siteiarchaem=6 if icd10=="C903"|icd10=="C900"|icd10=="C901"|icd10=="C902"|icd10=="C833" //22 changes
replace siteiarchaem=7 if icd10=="D470"|icd10=="C962"|icd10=="C943" //0 changes
replace siteiarchaem=8 if icd10=="C968"|icd10=="C966"|icd10=="C964" //0 changes
replace siteiarchaem=9 if icd10=="C889"|icd10=="C880"|icd10=="C882"|icd10=="C883"|icd10=="D472"|icd10=="C838"|icd10=="C865"|icd10=="D479"|icd10=="D477" //0 changes
replace siteiarchaem=10 if icd10=="C959"|icd10=="C950" //4 changes
replace siteiarchaem=11 if icd10=="C910"|icd10=="C919"|icd10=="C911"|icd10=="C918"|icd10=="C915"|icd10=="C917"|icd10=="C913"|icd10=="C916" //8 changes
replace siteiarchaem=12 if icd10=="C940"|icd10=="C929"|icd10=="C920"|icd10=="C921"|icd10=="C924"|icd10=="C925"|icd10=="C947"|icd10=="C922"|icd10=="C930"|icd10=="C928"|icd10=="C926"|icd10=="D471"|icd10=="C927"|icd10=="C942"|icd10=="C946"|icd10=="C923"|icd10=="C944"|icd10=="C914" //9 changes
replace siteiarchaem=13 if icd10=="C931"|icd10=="C933"|icd10=="C947" //0 changes
replace siteiarchaem=14 if icd10=="D45"|icd10=="D471"|icd10=="D474"|icd10=="D473"|icd10=="D475"|icd10=="C927"|icd10=="C967" //0 changes
replace siteiarchaem=15 if icd10=="D477"|icd10=="D471" //0 changes
replace siteiarchaem=16 if icd10=="D465"|icd10=="D466"|icd10=="D467"|icd10=="D469" //1 change

tab siteiarchaem ,m //603 missing - correct!
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
					 |regexm(icd10,"C12")|regexm(icd10,"C13")|regexm(icd10,"C14")) //13 changes
replace sitecr5db=2 if regexm(icd10,"C15") //8 changes
replace sitecr5db=3 if regexm(icd10,"C16") //27 changes
replace sitecr5db=4 if (regexm(icd10,"C18")|regexm(icd10,"C19")|regexm(icd10,"C20")|regexm(icd10,"C21")) //87 changes
replace sitecr5db=5 if regexm(icd10,"C22") //10 changes
replace sitecr5db=6 if regexm(icd10,"C25") //32 changes
replace sitecr5db=7 if regexm(icd10,"C32") //3 changes
replace sitecr5db=8 if (regexm(icd10,"C33")|regexm(icd10,"C34")) //33 changes
replace sitecr5db=9 if regexm(icd10,"C43") //4 changes
replace sitecr5db=10 if regexm(icd10,"C50") //102 changes
replace sitecr5db=11 if regexm(icd10,"C53") //8 changes
replace sitecr5db=12 if (regexm(icd10,"C54")|regexm(icd10,"C55")) //25 changes
replace sitecr5db=13 if regexm(icd10,"C56") //15 changes
replace sitecr5db=14 if regexm(icd10,"C61") //135 changes
replace sitecr5db=15 if regexm(icd10,"C62") //0 changes
replace sitecr5db=16 if (regexm(icd10,"C64")|regexm(icd10,"C65")|regexm(icd10,"C66")|regexm(icd10,"C68")) //10 changes
replace sitecr5db=17 if regexm(icd10,"C67") //13 changes
replace sitecr5db=18 if (regexm(icd10,"C70")|regexm(icd10,"C71")|regexm(icd10,"C72")) //6 changes
replace sitecr5db=19 if regexm(icd10,"C73") //4 changes
replace sitecr5db=20 if siteiarc==61 //46 changes
replace sitecr5db=21 if (regexm(icd10,"C81")|regexm(icd10,"C82")|regexm(icd10,"C83")|regexm(icd10,"C84")|regexm(icd10,"C85")|regexm(icd10,"C88")|regexm(icd10,"C90")|regexm(icd10,"C96")) //34 changes
replace sitecr5db=22 if (regexm(icd10,"C91")|regexm(icd10,"C92")|regexm(icd10,"C93")|regexm(icd10,"C94")|regexm(icd10,"C95")) //21 changes
replace sitecr5db=23 if (regexm(icd10,"C17")|regexm(icd10,"C23")|regexm(icd10,"C24")) //6 changes
replace sitecr5db=24 if (regexm(icd10,"C30")|regexm(icd10,"C31")) //0 changes
replace sitecr5db=25 if (regexm(icd10,"C40")|regexm(icd10,"C41")|regexm(icd10,"C45")|regexm(icd10,"C47")|regexm(icd10,"C49")) //5 changes
replace sitecr5db=26 if siteiarc==25 //6 changes
replace sitecr5db=27 if (regexm(icd10,"C51")|regexm(icd10,"C52")|regexm(icd10,"C57")|regexm(icd10,"C58")) //3 changes
replace sitecr5db=28 if (regexm(icd10,"C60")|regexm(icd10,"C63")) //1 change
replace sitecr5db=29 if (regexm(icd10,"C74")|regexm(icd10,"C75")) //0 changes
replace sitecr5db=30 if siteiarc==59 //0 changes
replace sitecr5db=31 if siteiarc==60 //1 change
replace sitecr5db=32 if siteiarc==64 //0 changes
replace sitecr5db=34 if icd10=="C37"|icd10=="C380"|icd10=="C699"|icd10=="C865"|icd10=="C866" //1 change

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
					 |regexm(icd10,"C12")|regexm(icd10,"C13")|regexm(icd10,"C14")) //13 changes
replace siteicd10=2 if (regexm(icd10,"C15")|regexm(icd10,"C16")|regexm(icd10,"C17") ///
					 |regexm(icd10,"C18")|regexm(icd10,"C19")|regexm(icd10,"C20") ///
					 |regexm(icd10,"C21")|regexm(icd10,"C22")|regexm(icd10,"C23") ///
					 |regexm(icd10,"C24")|regexm(icd10,"C25")|regexm(icd10,"C26")) //176 changes
replace siteicd10=3 if (regexm(icd10,"C30")|regexm(icd10,"C31")|regexm(icd10,"C32")|regexm(icd10,"C33")|regexm(icd10,"C34")|regexm(icd10,"C37")|regexm(icd10,"C38")|regexm(icd10,"C39")) //37 changes
replace siteicd10=4 if (regexm(icd10,"C40")|regexm(icd10,"C41")) //1 change
replace siteicd10=5 if siteiarc==24 //4 changes
replace siteicd10=6 if siteiarc==25 //6 changes
replace siteicd10=7 if (regexm(icd10,"C45")|regexm(icd10,"C46")|regexm(icd10,"C47")|regexm(icd10,"C48")|regexm(icd10,"C49")) //4 changes
replace siteicd10=8 if regexm(icd10,"C50") //102 changes
replace siteicd10=9 if (regexm(icd10,"C51")|regexm(icd10,"C52")|regexm(icd10,"C53")|regexm(icd10,"C54")|regexm(icd10,"C55")|regexm(icd10,"C56")|regexm(icd10,"C57")|regexm(icd10,"C58")) //51 changes
replace siteicd10=10 if regexm(icd10,"C61") //135 changes
replace siteicd10=11 if (regexm(icd10,"C60")|regexm(icd10,"C62")|regexm(icd10,"C63")) //1 change
replace siteicd10=12 if (regexm(icd10,"C64")|regexm(icd10,"C65")|regexm(icd10,"C66")|regexm(icd10,"C67")|regexm(icd10,"C68")) //23 changes
replace siteicd10=13 if (regexm(icd10,"C69")|regexm(icd10,"C70")|regexm(icd10,"C71")|regexm(icd10,"C72")) //6 changes
replace siteicd10=14 if (regexm(icd10,"C73")|regexm(icd10,"C74")|regexm(icd10,"C75")) //4 changes
replace siteicd10=15 if (regexm(icd10,"C76")|regexm(icd10,"C77")|regexm(icd10,"C78")|regexm(icd10,"C79")) //0 changess
replace siteicd10=16 if regexm(icd10,"C80") //40 changes
replace siteicd10=17 if (regexm(icd10,"C81")|regexm(icd10,"C82")|regexm(icd10,"C83") ///
					 |regexm(icd10,"C84")|regexm(icd10,"C85")|regexm(icd10,"C86") ///
					 |regexm(icd10,"C87")|regexm(icd10,"C88")|regexm(icd10,"C89") ///
					 |regexm(icd10,"C90")|regexm(icd10,"C91")|regexm(icd10,"C92") ///
					 |regexm(icd10,"C93")|regexm(icd10,"C94")|regexm(icd10,"C95") ///
					 |regexm(icd10,"C96")|regexm(icd10,"D46")|regexm(icd10,"D47")) //56 changes


tab siteicd10 ,m //0 missing

drop dupobs* dup_id
	 
order record_id did fname lname age age5 age_10 sex dob nrn parish dod dodyear cancer siteiarc siteiarchaem pod coddeath


label data "BNR MORTALITY data 2018"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version04\3-output\2018_prep mort" ,replace
note: TS This dataset is used for analysis of age-standardized mortality rates
note: TS This dataset includes patients with multiple eligible cancer causes of death
