** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          5e_prep mort 2021.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      22-AUG-2022
    // 	date last modified      23-AUG-2022
    //  algorithm task          Prep and format death data using previously-prepared datasets and REDCap database export
    //  status                  Pending
    //  objective               To have multiple datasets with cleaned death data for:
	//							(1) matching with incidence data and 
	//							(2) analysis/reporting mortality rates.
    
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
    log using "`logpath'\5e_prep mort_2021.smcl", replace
** HEADER -----------------------------------------------------

/* 
	JC 13jun2022:
	
		NS requested the 2019 + 2020 ASMRs to compare with Globocan rates for B'dos.
		
	For the 2018 ASMRs (see 5a_prep mort.do in 2018AnnualReportV02 branch), the death data was corrected as there were numerous errors with NRN and names fields.
	This dofile uses the corrected dataset from that set of analysis.
	
	** JC 13jun2022: SF emailed on 02jun2022 with correction to dod year for record_id 26742 so corrected in 5a_prep mort.do (which created the dataset used in this dofile) 
					 and re-ran 10a_analysis mort.do
*/
/*
	JC 22aug2022:
	
		NS requested 2021 cancer deaths that also had COVID in the COD for Adanna Grandison to use at 
		the BNR CME 2022 webinar this week. 
*/

***************
** DATA IMPORT  
***************
use "`datapath'\version09\3-output\2015-2021_deaths_for_matching" ,clear

********************
**   Preparing    **
** 	2021 Deaths   **
**	for analysis  **
********************
count //18,560
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
       2015 |      2,482       13.37       13.37
       2016 |      2,488       13.41       26.78
       2017 |      2,530       13.63       40.41
       2018 |      2,527       13.62       54.02
       2019 |      2,785       15.01       69.03
       2020 |      2,606       14.04       83.07
       2021 |      3,142       16.93      100.00
------------+-----------------------------------
      Total |     18,560      100.00
*/
gen dodyr=year(dod)
count if dodyear!=dodyr //0
drop dodyr


drop if dodyear!=2021 //15,418 deleted
** Remove Tracking Form info (already previously removed)
//drop if event==2 //0 deleted

count //3142

** JC 13jun2022
/*
	NOTE: For accuracy, the above count of 2019 + 2020 deaths was cross-checked against the current multi-year REDCapdb 
		  using the reports called '2019 deaths' and '2020 deaths' which has the below filters:

	dod > 2018-12-31 AND dod < 2020-01-01 in Death Data Collection Arm 1
	Filter by event(s): Death Data Colleciton (Arm 1: Deaths)
	
	dod > 2019-12-31 AND dod < 2021-01-01 in Death Data Collection Arm 1
	Filter by event(s): Death Data Colleciton (Arm 1: Deaths)
*/

*****************
**  Formatting **
**    Names    **
*****************
** JC 13jun2022: The below was previously done when for 2015 annual report so code disabled

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
replace name3=name2+name3 if tempvarn==3 & name4=="" //3 changes
replace name2="" if tempvarn==3 & name4=="" //3 changes
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

rename deathid record_id
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
count if dupname>0 //64
/* 
Check below list (or Stata Browse window) for cases where namematch=no match but 
there is a pt with same name then:
 (1) check if same pt and remove duplicate pt;
 (2) check if same name but different pt and
	 update namematch variable to reflect this, i.e.
	 namematch=1
*/
//list record_id namematch fname lname nrn dod sex age if dupname>0
sort lname fname record_id
order record_id pname namematch nrn dod coddeath

replace namematch=1 if dupname>0 & namematch!=1 //28 changes

//replace namematch=2 if record_id==
/*
replace namematch=1 if record_id==|record_id==|record_id==|record_id==|record_id==|record_id== ///
					  |record_id==|record_id==|record_id==|record_id==|record_id==|record_id== ///
					  |record_id==|record_id==|record_id==|record_id==|record_id==|record_id== ///
					  |record_id==|record_id==|record_id==|record_id==|record_id==|record_id== ///
					  |record_id==|record_id==|record_id==|record_id==|record_id==|record_id== ///
					  |record_id==|record_id==|record_id==|record_id==|record_id==|record_id== ///
					  |record_id==|record_id==|record_id==|record_id==|record_id==|record_id== ///
					  |record_id==
//2 changes
*/

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
count if dupdod>0 //2 - no match; different pt
list record_id namematch fname lname nrn dod sex age if dupdod>0
count if dupdod>0 & namematch!=1 //0
drop dupname dupdod

count //3142


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
     cancer |        694       22.09       22.09
 not cancer |      2,448       77.91      100.00
------------+-----------------------------------
      Total |      3,142      100.00
*/

tab cancer dodyear ,m

** JC 13jun2022: The below was previously done when for 2015 annual report so code disabled

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
     Dead of cancer |        694       22.09       22.09
Dead of other cause |      2,421       77.05       99.14
          Not known |         27        0.86      100.00
--------------------+-----------------------------------
              Total |      3,142      100.00
*/

tab cod dodyear ,m

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
     Female |      1,543       49.11       49.11
       Male |      1,599       50.89      100.00
------------+-----------------------------------
      Total |      3,142      100.00
*/
tab sex dodyear ,m


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
					 11 "Other/Hotel" 12 "Isolation facility" 99 "ND", modify
label values pod pod_lab
label var pod "Place of Death from National Register"

replace pod=1 if regexm(placeofdeath, "ELIZABETH HOSP") & pod==. //0 changes
replace pod=1 if regexm(placeofdeath, "QUEEN ELZ") & pod==. //0 changes
replace pod=1 if regexm(placeofdeath, "QEH") & pod==. //1439 changes
replace pod=1 if regexm(placeofdeath, "Q.E.H") & pod==. //0 changes
replace pod=3 if regexm(placeofdeath, "GERIATRIC") & pod==. //80 changes
replace pod=3 if regexm(placeofdeath, "GERIACTIRC") & pod==. //0 chagnes
replace pod=3 if regexm(placeofdeath, "GERIACTRIC") & pod==. //0 chagnes
replace pod=5 if regexm(placeofdeath, "CHILDRENS HOME") & pod==. //0 chagnes
replace pod=4 if regexm(placeofdeath, "HOME") & pod==. //118 changes
replace pod=4 if regexm(placeofdeath, "ELDERLY") & pod==. //3 changes
replace pod=4 if regexm(placeofdeath, "SERENITY MANOR") & pod==. //0 changes
replace pod=4 if regexm(placeofdeath, "ADULT CARE") & pod==. //0 changes
replace pod=4 if regexm(placeofdeath, "AGE ASSIST") & pod==. //0 changes
replace pod=4 if regexm(placeofdeath, "SENIOR") & pod==. //0 changes
replace pod=4 if regexm(placeofdeath, "RETREAT") & pod==. //16 changes
replace pod=4 if regexm(placeofdeath, "RETIREMENT") & pod==. //0 changes
replace pod=4 if regexm(placeofdeath, "NURSING") & pod==. //1 change
replace pod=5 if regexm(placeofdeath, "PRISON") & pod==. //0 changes
replace pod=5 if regexm(placeofdeath, "MINISTRIES") & pod==. //0 changes
replace pod=5 if regexm(placeofdeath, "HIGHWAY") & pod==. //3 changes - FOR THESE CHECK COD TO DIFFERENTIATE BETWEEN ROAD ACCIDENT AND AT HOME DEATH
replace pod=5 if regexm(placeofdeath, "ROUNDABOUT") & pod==. //0 changes - FOR THESE CHECK COD TO DIFFERENTIATE BETWEEN ROAD ACCIDENT AND AT HOME DEATH
replace pod=5 if regexm(placeofdeath, "JUNCTION") & pod==. //1 change - FOR THESE CHECK COD TO DIFFERENTIATE BETWEEN ROAD ACCIDENT AND AT HOME DEATH
replace pod=6 if regexm(placeofdeath, "STRICT HOSP") & pod==. //19 changes
replace pod=6 if regexm(placeofdeath, "GORDON CUMM") & pod==. //2 changes
replace pod=7 if regexm(placeofdeath, "PSYCHIATRIC HOSP") & pod==. //1 change
replace pod=7 if regexm(placeofdeath, "PSYCIATRIC HOSP") & pod==. //0 changes
replace pod=7 if regexm(placeofdeath, "PSYCHIATRIC") & pod==. //14 changes
replace pod=8 if regexm(placeofdeath, "BAYVIEW") & pod==. //15 changes
replace pod=8 if regexm(placeofdeath, "BAY VIEW HOSP") & pod==. //0 changes
replace pod=9 if regexm(placeofdeath, "SANDY CREST") & pod==. //7 changes
replace pod=9 if regexm(placeofdeath, "FMH CLINIC") & pod==. //0 changes
replace pod=9 if regexm(placeofdeath, "FMH EMERGENCY") & pod==. //0 changes
replace pod=9 if regexm(placeofdeath, "SPARMAN CLINIC") & pod==. //0 changes
replace pod=9 if regexm(placeofdeath, "CLINIC") & pod==. //4 changes
replace pod=9 if regexm(placeofdeath, "POLYCLINIC") & pod==. //0 changes
replace pod=10 if regexm(placeofdeath, "BRIDGETOWN PORT") & pod==. //0 changes
replace pod=11 if regexm(placeofdeath, "HOTEL") & pod==. //3 changes
replace pod=99 if placeofdeath=="" & pod==. //0 changes
replace pod=99 if placeofdeath=="99" //20 changes

order record_id address placeofdeath parish deathparish coddeath
count if pod==. & parish!=deathparish & (regexm(coddeath, "CORONA")|regexm(coddeath, "COVID")) //217
replace pod=12 if pod==. & parish!=deathparish & (regexm(coddeath, "CORONA")|regexm(coddeath, "COVID")) //217 changes
count if pod==. & parish!=deathparish //88 - check COD to determine if road accident or at home death
//list record_id address parish placeofdeath deathparish if pod==. & parish!=deathparish
count if pod==. //1179 - check address against placeofdeath in Stata Browse window
//list record_id placeofdeath if pod==.
replace pod=2 if pod==. & address==placeofdeath //623 changes
replace pod=2 if pod==. & parish==deathparish //473 changes
replace pod=11 if pod==. & parish!=deathparish & address!=placeofdeath //83 changes

//drop placeofdeath
tab pod ,m //none unassigned


** JC 13jun2022: The below was previously done when for 2015 annual report so code disabled

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

count if natregno=="" & nrn!=. //0
//gen double nrn2=nrn if record_id==28513
//tostring nrn2 ,replace
//replace nrn2=subinstr(nrn2,"3","3-",.) if record_id==28513
//replace natregno=nrn2 if record_id==28513
//drop nrn2

count if natregno=="" //87
count if natregno=="" & age!=0 //87
count if natregno=="" & age!=0 & pod!=11 & !(strmatch(strupper(address), "*BRIDGETOWN PORT*")) & !(strmatch(strupper(address), "*BRIDGETOWN SEA PORT*")) & !(strmatch(strupper(address), "*HOTEL*")) & !(strmatch(strupper(address), "*BARBADOS PORT*")) & !(strmatch(strupper(address), "*AIRPORT*")) & !(strmatch(strupper(pname), "*BABY*")) //65 - checked against 2021 electoral list + updated NRN in REDCapdb
count if pod!=11 & (regexm(address,"BRIDGETOWN PORT")|regexm(address,"BARBADOS PORT")|regexm(address,"AIRPORT")|regexm(address,"HOTEL")) //9
replace pod=11 if pod==2 & (regexm(address,"BRIDGETOWN PORT")|regexm(address,"BARBADOS PORT")|regexm(address,"AIRPORT")|regexm(address,"HOTEL")) //3 changes
count if age==. //0

** Add missing NRNs flagged above with list of NRNs manually created using electoral list (this ensures dofile remains de-identified)
/*
preserve
clear
import excel using "`datapath'\version09\2-working\MissingNRNs_mort_20220614.xlsx" , firstrow case(lower)
format elec_nrn %15.0g
replace elec_natregno=subinstr(elec_natregno,"-","",.)
save "`datapath'\version09\2-working\electoral_missingnrn" ,replace
restore
merge 1:1 record_id using "`datapath'\version09\2-working\electoral_missingnrn" ,force
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                         5,337
        from master                     5,337  (_merge==1)
        from using                          0  (_merge==2)

    Matched                                50  (_merge==3)
    -----------------------------------------
*/
replace nrn=elec_nrn if _merge==3 //3 changes
replace natregno=elec_natregno if _merge==3 //3 changes
drop elec_* _merge
erase "`datapath'\version09\2-working\electoral_missingnrn.dta"
*/

** Check dob** Creating dob variable as none in national death data
** perform data cleaning on the age variable
order record_id natregno age
count if natregno==""|natregno=="." //87
gen tempvarn=6 if natregno==""|natregno=="."
gen yr = substr(natregno,1,1) if tempvarn!=6
gen yr1=. if tempvarn!=6
replace yr1 = 20 if yr=="0"
replace yr1 = 19 if yr!="0"
replace yr1 = 99 if natregno=="99"
order record_id natregno nrn age agetxt yr yr1
** Check age and yr1 in Stata browse
//list record_id natregno nrn age agetxt yr1 if yr1==20
count if yr1==19 & age<21 //25
replace yr1=20 if yr1==19 & age<21 //25 changes
** Initially need to run this code separately from entire dofile to determine which nrnyears should be '19' instead of '20' depending on age, e.g. for age 107 nrnyear=19
//replace yr1 = 19 if record_id==|record_id==

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
count if tempvarn!=6 & age!=ageyrs //7
sort record_id
list record_id fname lname address age agetxt ageyrs nrn natregno dob dobcheck dod yr1 if tempvarn!=6 & age!=ageyrs, string(15) //check against electoral list
count if dobcheck!=. & dob==. //0
replace dob=dobcheck if dobcheck!=. & dob==. //0 changes
//replace nrn=. if record_id==34112 - KG checked 24jun2022 and confirmed NRN and age are correct since pt's age = 18 months
//replace natregno="" if record_id==34112
replace age=ageyrs if tempvarn!=6 & age!=ageyrs & agetxt==6 & ageyrs<100 //3 changes
drop day month dyear nrnyr yr yr1 year2 nrndob age2 ageyrs tempvarn dobcheck

** Check age
gen age2 = (dod - dob)/365.25
gen checkage2=int(age2)
drop age2
count if dob!=. & dod!=. & age!=checkage2 //4
list record_id fname lname dod dob age agetxt checkage2 if dob!=. & dod!=. & age!=checkage2 //all correct
//replace age=checkage2 if dob!=. & dod!=. & age!=checkage2 //0 changes
drop checkage2

** Check no missing dxyr so this can be used in analysis
tab dodyear ,m //3142 - none missing

count if dodyear!=year(dod) //0
//list pid record_id dod dodyear if dodyear!=year(dod)
replace dodyear=year(dod) if dodyear!=year(dod) //0 changes


label data "BNR MORTALITY data 2021"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version09\3-output\2021_prep mort_ALL" ,replace
note: TS This dataset is used for analysis of age-standardized mortality rates
note: TS This dataset includes all 2021 CODs

preserve
** Create corrected dataset with reportable cases but de-identified data
drop fname lname natregno nrn pname mname dob parish regnum address certifier certifieraddr

label data "BNR MORTALITY data 2021: De-identified Dataset"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version09\3-output\2021_prep mort_ALL_deidentified" ,replace
note: TS This dataset is used for the BNR CME 2022 webinar
note: TS This dataset includes all 2021 CODs
restore

*******************
** Check for MPs **
**   in CODs     **
*******************
count //3142

//list record_id
//list cod1a
tab cancer ,m //694 cancer CODs
drop if cancer!=1 //2448 deleted

** MPs found above when assigning cancer variable in checking causes of death
sort coddeath record_id
order record_id coddeath //check Stata Browse window for MPs in CODs

** Create duplicate observations for MPs in CODs
expand=2 if record_id==36648, gen (dupobs1)
expand=2 if record_id==35270, gen (dupobs2)
expand=2 if record_id==34670, gen (dupobs3)
expand=2 if record_id==36419, gen (dupobs4)
expand=2 if record_id==36606, gen (dupobs5)
expand=2 if record_id==37099, gen (dupobs6)
expand=2 if record_id==34353, gen (dupobs7)
/*
drop if record_id== //myelodysplasia, NOS is considered benign - 1 deleted
drop if record_id== //tumour, uncertain/unk behaviour - 1 deleted
drop if record_id== //myelofibrosis, NOS is considered benign - 1 deleted
drop if record_id== //no cancer listed in CODs - 1 deleted
*/
drop if record_id==35924 //tumour - 1 deleted


** JC 15jun2022: below is an old note but kept in as maybe relevant in later years
//pid 20130770 CML in 2013 that transformed to either T-ALL or B-ALL in 2015 COD states C-CELL!
//M9811 (B-ALL) chosen as research shows "With few exceptions, Ph-positive ALL patients are diagnosed with B-ALL "
//https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4896164/
display `"{browse "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4896164/":Ph+ALL}"'

** JC 15jun2022: added the below corrections to excel list for KG to correct in REDCap multi-year deaht db: ...\Sync\BNR\Death Data Updates
replace coddeath=subinstr(coddeath,"CARCINOMAA","CARCINOMA",.) if record_id==36358
//replace coddeath=subinstr(coddeath,"ASPHYSCIATION","ASPHYXIATION",.) if record_id==

count //700

** Create variables to identify patients vs tumours
gen ptrectot=.
replace ptrectot=1 if dupobs1==0|dupobs2==0|dupobs3==0|dupobs4==0 ///
					 |dupobs5==0|dupobs6==0|dupobs7==0 //700 changes
replace ptrectot=2 if dupobs1>0|dupobs2>0|dupobs3>0|dupobs4>0 ///
					 |dupobs5>0|dupobs6>0|dupobs7>0 //7 changes
label define ptrectot_lab 1 "COD with single event" 2 "COD with multiple events" , modify
label values ptrectot ptrectot_lab

tab ptrectot ,m

** Now create id in this dataset so when merging icd10 for siteiarc variable at end of this dofile
sort record_id
gen did="T1" if ptrectot==1
replace did="T2" if ptrectot==2 //7 changes
//replace did="T3" in 523
//replace did="T3" in 1296

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
count //700
tab cancer ,m //700 cancers
tab cancer dodyear,m

** Note: Although siteiarc doesn't need sub-site, the specific icd10 code was used, where applicable
display `"{browse "https://icd.who.int/browse10/2015/en#/C09":ICD10,v2015}"'

** Use Stata browse instead of lists
order record_id coddeath did
sort record_id

gen icd10=""

count if regexm(coddeath,"LIP") & icd10=="" //3 - not lip so no replace
//list record_id coddeath if regexm(coddeath,"LIP"),string(120)
replace icd10="C189" if record_id==35115 //1 change
replace icd10="C499" if record_id==35356 //1 change
replace icd10="C751" if record_id==36586 //1 change

count if regexm(coddeath,"TONGUE") & icd10=="" //4 - all tongue, NOS
//list record_id coddeath if regexm(coddeath,"TONGUE"),string(120)
replace icd10="C029" if regexm(coddeath,"TONGUE") & icd10=="" //4 changes
replace icd10="C01" if record_id==37356 //1 change

count if regexm(coddeath,"MOUTH") & icd10=="" //0
//list record_id coddeath if regexm(coddeath,"MOUTH"),string(120)

count if regexm(coddeath,"SALIVARY") & icd10=="" //2
//list record_id coddeath if regexm(coddeath,"SALIVARY"),string(120)
replace icd10="C089" if regexm(coddeath,"SALIVARY") & icd10=="" //2 changes

count if regexm(coddeath,"TONSIL") & icd10=="" //0
//list record_id coddeath if regexm(coddeath,"TONSIL"),string(120)
replace icd10="C099" if regexm(coddeath,"TONSIL") & icd10=="" //0 changes

count if regexm(coddeath,"OROPHARYNX") & icd10=="" //0
//list record_id coddeath if regexm(coddeath,"OROPHARYNX"),string(120)
replace icd10="C109" if regexm(coddeath,"OROPHARYNX") & icd10=="" //0 changes

count if regexm(coddeath,"NASOPHARYNX") & icd10=="" //0
//list record_id coddeath if regexm(coddeath,"NASOPHARYNX"),string(120)
replace icd10="C119" if regexm(coddeath,"NASOPHARYNX") & icd10=="" //0 changes

count if regexm(coddeath,"HYPOPHARYNX") & icd10=="" //0
//list record_id coddeath if regexm(coddeath,"HYPOPHARYNX"),string(120)
//replace icd10="C139" if regexm(coddeath,"HYPOPHARYNX") & icd10=="" //1 change

count if (regexm(coddeath,"PHARYNX")|regexm(coddeath,"PHARNYX")) & icd10=="" //0
//list record_id coddeath if (regexm(coddeath,"PHARYNX")|regexm(coddeath,"PHARNYX")) & icd10=="",string(120)0
replace icd10="C140" if (regexm(coddeath,"PHARYNX")|regexm(coddeath,"PHARNYX")) & icd10=="" //0 changes

count if (regexm(coddeath,"OESOPHAG")|regexm(coddeath,"ESOPHAG")) & icd10=="" //9
replace icd10="C159" if (regexm(coddeath,"OESOPHAG")|regexm(coddeath,"ESOPHAG")) & icd10=="" //9 changes
replace icd10="C61" if record_id==35270 & did=="T2" //prostate
replace icd10="C900" if record_id==35776 //MM

count if (regexm(coddeath,"STOMACH")|regexm(coddeath,"GASTR"))  & !(strmatch(strupper(coddeath), "*GASTROINTESTINAL BLEED*"))  & !(strmatch(strupper(coddeath), "*GASTROINTESTINAL HAEMORR*"))  & !(strmatch(strupper(coddeath), "*GASTROENTER*")) & icd10=="" //22
replace icd10="C169" if (regexm(coddeath,"STOMACH")|regexm(coddeath,"GASTR"))  & !(strmatch(strupper(coddeath), "*GASTROINTESTINAL BLEED*"))  & !(strmatch(strupper(coddeath), "*GASTROINTESTINAL HAEMORR*"))  & !(strmatch(strupper(coddeath), "*GASTROENTER*")) & icd10=="" //22 changes
replace icd10="C269" if record_id==35795|record_id==36303 //gastronintestinal malignancy
replace icd10="C61" if record_id==34511 //prostate
replace icd10="C189" if record_id==36215 //colon,NOS
replace icd10="C259" if record_id==35712 //pancreas
replace icd10="C221" if record_id==34250 //cholangiocarcinoma

count if (regexm(coddeath,"DUODEN")|regexm(coddeath,"JEJUN")|regexm(coddeath,"ILEUM")|regexm(coddeath,"SMALL")) & !(strmatch(strupper(coddeath), "*SMALL CEL*")) & !(strmatch(strupper(coddeath), "*LARYNGEAL*")) & icd10=="" //9
replace icd10="C179" if (regexm(coddeath,"DUODEN")|regexm(coddeath,"JEJUN")|regexm(coddeath,"ILEUM")|regexm(coddeath,"SMALL")) & !(strmatch(strupper(coddeath), "*SMALL CEL*")) & !(strmatch(strupper(coddeath), "*LARYNGEAL*")) & icd10=="" //9 changes
replace icd10="C221" if record_id==34313 //cholangiocarcinoma
replace icd10="C172" if record_id==36449 //ileum
replace icd10="C170" if record_id==36455 //duodenum
//replace icd10="C171" if record_id== //jejunum
replace icd10="C259" if record_id==37099 & did=="T1" //pancreas
replace icd10="C509" if record_id==37099 & did=="T2" //breast

count if (regexm(coddeath,"CECUM")|regexm(coddeath,"APPEND")|regexm(coddeath,"COLON")) & !(strmatch(strupper(coddeath), "*COLONIC POLYPS*")) & icd10=="" //89
replace icd10="C189" if (regexm(coddeath,"CECUM")|regexm(coddeath,"APPEND")|regexm(coddeath,"COLON")) & !(strmatch(strupper(coddeath), "*COLONIC POLYPS*")) & icd10=="" //89 changes
replace icd10="C187" if record_id==34740|record_id==35824|record_id==35883 //sigmoid colon
replace icd10="C19" if record_id==36430|record_id==36496 //colorectal

count if (regexm(coddeath,"COLORECTAL")|regexm(coddeath,"RECTO")) & icd10=="" //11
replace icd10="C19" if (regexm(coddeath,"COLORECT")|regexm(coddeath,"RECTO")) & icd10=="" //11 changes
replace icd10="C61" if record_id==35665 //prostate
replace icd10="C64" if record_id==34778|record_id==36200 //kidney

count if (regexm(coddeath,"RECTUM")|regexm(coddeath,"RECTAL")) & !(strmatch(strupper(coddeath), "*ANORECT*")) & icd10=="" //17
replace icd10="C20" if (regexm(coddeath,"RECTUM")|regexm(coddeath,"RECTAL")) & !(strmatch(strupper(coddeath), "*ANORECT*")) & icd10=="" //17 changes
replace icd10="C444" if record_id==36419 & did=="T2" //skin,scalp/neck (taken from MedData)

count if (regexm(coddeath,"ANUS")|regexm(coddeath,"ANORECT")|regexm(coddeath,"ANAL")) & icd10=="" //1
replace icd10="C218" if (regexm(coddeath,"ANUS")|regexm(coddeath,"ANORECT")|regexm(coddeath,"ANAL")) & icd10=="" //1 change
replace icd10="C435" if record_id==33654 //melanoma, trunk

count if regexm(coddeath,"CHOLANGIO") & icd10=="" //6
replace icd10="C221" if regexm(coddeath,"CHOLANGIO") & icd10=="" //6 changes

count if (regexm(coddeath,"LIVER")|regexm(coddeath,"BILE")|regexm(coddeath,"HEPATO")) & !(strmatch(strupper(coddeath), "*CHOLANGIOCAR*")) & icd10=="" //9
replace icd10="C229" if (regexm(coddeath,"LIVER")|regexm(coddeath,"BILE")|regexm(coddeath,"HEPATO")) & !(strmatch(strupper(coddeath), "*CHOLANGIOCAR*")) & icd10=="" //9 changes
replace icd10="C64" if record_id==36582|record_id==36985 //kidney
replace icd10="C509" if record_id==34780|record_id==35808|record_id==36513 //breast
replace icd10="C259" if record_id==34276 //pancreas
replace icd10="C931" if record_id==37350 //CML

count if (regexm(coddeath,"GALLBLAD")|regexm(coddeath,"GALL BLAD")) & icd10=="" //3
replace icd10="C23" if (regexm(coddeath,"GALLBLAD")|regexm(coddeath,"GALL BLAD")) & icd10=="" //3 changes

count if regexm(coddeath,"BILIARY") & icd10=="" //0
//replace icd10="C249" if regexm(coddeath,"BILIARY") & icd10=="" //0 changes

count if (regexm(coddeath,"PANCREA") & regexm(coddeath,"HEAD")) & icd10=="" //2
replace icd10="C250" if (regexm(coddeath,"PANCREA") & regexm(coddeath,"HEAD")) & icd10=="" //2 changes
replace icd10="C509" if record_id==36648 & did=="T2" //breast

count if regexm(coddeath,"PANCREA") & icd10=="" //28
replace icd10="C259" if regexm(coddeath,"PANCREA") & icd10=="" //28 changes

count if (regexm(coddeath,"NASAL")|regexm(coddeath,"EAR")) & icd10=="" //12-no nasal/ear so no replace
replace icd10="C809" if record_id==34217 //PSU, NOS
replace icd10="C859" if record_id==34236 //NHL, NOS
replace icd10="C509" if record_id==34285|record_id==34591|record_id==37081 //breast
replace icd10="C349" if record_id==34362|record_id==36192 //lung
replace icd10="C61" if record_id==35190|record_id==35481|record_id==35654|record_id==36413|record_id==36852 //prostate

count if regexm(coddeath,"SINUS") & icd10=="" //0-no sinus

count if (regexm(coddeath,"LARYNX")|regexm(coddeath,"LARYNG")|regexm(coddeath,"GLOTTI")|regexm(coddeath,"VOCAL")) & icd10=="" //1
replace icd10="C329" if (regexm(coddeath,"LARYNX")|regexm(coddeath,"LARYNG")|regexm(coddeath,"GLOTTI")|regexm(coddeath,"VOCAL")) & icd10=="" //1 change

count if regexm(coddeath,"TRACHEA") & icd10=="" //0

count if (regexm(coddeath,"LUNG")|regexm(coddeath,"BRONCH")) & icd10=="" //47
replace icd10="C349" if (regexm(coddeath,"LUNG")|regexm(coddeath,"BRONCH")) & icd10=="" //47 changes
replace icd10="C509" if record_id==34548|record_id==36063|record_id==36206|record_id==36342|record_id==36650|record_id==36919|record_id==36972 //breast
replace icd10="C541" if record_id==34559 //endometrium
replace icd10="C61" if record_id==34353 & did=="T2"|record_id==34387 //prostate
replace icd10="C539" if record_id==35445 //cervix
replace icd10="C64" if record_id==36528 //kidney
replace icd10="C719" if record_id==35483 //brain,NOS
replace icd10="C859" if record_id==35553 //NHL, NOS

count if regexm(coddeath,"THYMUS") & icd10=="" //0

count if (regexm(coddeath,"HEART")|regexm(coddeath,"MEDIASTIN")|regexm(coddeath,"PLEURA")) & icd10=="" //5-none found so no replace
replace icd10="C859" if record_id==34999 //NHL, NOS
replace icd10="C851" if record_id==35606 //NHL, B-cell
replace icd10="C800" if record_id==35452 //PSU
replace icd10="C763" if record_id==35480 //pelvis,NOS
replace icd10="C900" if record_id==36346 //MM

count if (regexm(coddeath,"BONE")|regexm(coddeath,"OSTEO")|regexm(coddeath,"CARTILAGE")) & icd10=="" //7-none found so no replace
replace icd10="C61" if record_id==34569|record_id==35058|record_id==36399|record_id==36946 //prostate
replace icd10="C509" if record_id==35790|record_id==36990|record_id==37318 //breast

count if (regexm(coddeath,"SKIN")|regexm(coddeath,"MELANOMA")|regexm(coddeath,"SQUAMOUS")|regexm(coddeath,"BASAL")) & icd10=="" //7
replace icd10="C439" if (regexm(coddeath,"SKIN")|regexm(coddeath,"MELANOMA")|regexm(coddeath,"SQUAMOUS")|regexm(coddeath,"BASAL")) & icd10=="" //7 changes
replace icd10="C809" if record_id==35813 //PSU,NOS
replace icd10="C444" if record_id==34277 //SCC, BCC, neck
replace icd10="C449" if record_id==34781 //SCC, BCC, NOS
replace icd10="C443" if record_id==35927 //SCC, BCC, face
replace icd10="C446" if record_id==34800 //SCC, BCC, upper limb/shoulder

count if (regexm(coddeath,"MESOTHELIOMA")|regexm(coddeath,"KAPOSI")|regexm(coddeath,"NERVE")|regexm(coddeath,"PERITON")) & icd10=="" //4
replace icd10="C61" if record_id==37252 //prostate
replace icd10="C480" if record_id==36325 //retroperitoneum
replace icd10="C541" if record_id==35284 //endometrium
replace icd10="C451" if record_id==35196 //mesothelioma, peritoneum

count if regexm(coddeath,"BREAST") & icd10=="" //71
//list record_id coddeath if regexm(coddeath,"BREAST"),string(120)
replace icd10="C509" if regexm(coddeath,"BREAST") & icd10=="" //71 changes

count if regexm(coddeath,"VULVA") & icd10=="" //0
replace icd10="C519" if regexm(coddeath,"VULVA") & icd10=="" //0 changes

count if regexm(coddeath,"VAGINA") & icd10=="" //0
replace icd10="C52" if regexm(coddeath,"VAGINA") & icd10=="" //0 changes

count if (regexm(coddeath,"CERVICAL")|regexm(coddeath,"CERVIX")) & icd10=="" //14
replace icd10="C539" if (regexm(coddeath,"CERVICAL")|regexm(coddeath,"CERVIX")) & icd10=="" //14 changes


count if (regexm(coddeath,"ENDOMETRI")|regexm(coddeath,"CORPUS")) & icd10=="" //21
replace icd10="C541" if (regexm(coddeath,"ENDOMETRI")|regexm(coddeath,"CORPUS")) & icd10=="" //21 changes
//replace icd10="C689" if record_id== //urinary organ, NOS
replace icd10="C64" if record_id==34364 //kidney

count if (regexm(coddeath,"UTERINE")|regexm(coddeath,"UTERUS")) & icd10=="" //6
replace icd10="C55" if (regexm(coddeath,"UTERINE")|regexm(coddeath,"UTERUS")) & icd10=="" //6 changes

count if (regexm(coddeath,"OVARY")|regexm(coddeath,"OVARIAN")) & icd10=="" //11
replace icd10="C56" if (regexm(coddeath,"OVARY")|regexm(coddeath,"OVARIAN")) & icd10=="" //11 changes

count if (regexm(coddeath,"FALLOPIAN")|regexm(coddeath,"FEMALE")) & icd10=="" //0

count if (regexm(coddeath,"PENIS")|regexm(coddeath,"PENILE")) & icd10=="" //4
replace icd10="C609" if (regexm(coddeath,"PENIS")|regexm(coddeath,"PENILE")) & icd10=="" //4 changes

count if regexm(coddeath,"PROSTATE") & icd10=="" //127
replace icd10="C61" if regexm(coddeath,"PROSTATE") & icd10=="" //127 changes
replace icd10="C140" if record_id==36606 & did=="T2" //throat
replace icd10="C689" if record_id==34670 & did=="T2" //urinary organ, NOS

count if (regexm(coddeath,"TESTIS")|regexm(coddeath,"TESTES")) & icd10=="" //0

count if (regexm(coddeath,"SCROT")|regexm(coddeath,"MALE")) & icd10=="" //0

count if (regexm(coddeath,"KIDNEY")|regexm(coddeath,"RENAL")) & icd10=="" //20
replace icd10="C64" if (regexm(coddeath,"KIDNEY")|regexm(coddeath,"RENAL")) & icd10=="" //20 changes
replace icd10="C859" if record_id==34744 //NHL/lymphoma, NOS
replace icd10="C800" if record_id==36478 //PSU
replace icd10="C809" if record_id==34258|record_id==37088 //PSU, NOS
replace icd10="C61" if record_id==35554|record_id==36014 //prostate
replace icd10="C900" if record_id==34153|record_id==34338|record_id==34468|record_id==35453|record_id==35761|record_id==36052|record_id==36144|record_id==36169 //MM
replace icd10="C689" if record_id==34386|record_id==34724|record_id==35267|record_id==35694|record_id==36927 //urinary organ,NOS
replace icd10="D469" if record_id==36619 //myelodysplastic disorder

count if (regexm(coddeath,"BLADDER")|regexm(coddeath,"URIN")) & icd10=="" //7
replace icd10="C679" if (regexm(coddeath,"BLADDER")|regexm(coddeath,"URIN")) & icd10=="" //7 changes
replace icd10="C720" if record_id==37308 //spinal cord

count if (regexm(coddeath,"EYE")|regexm(coddeath,"RETINA")|regexm(coddeath,"NEURO")) & icd10=="" //3
//replace icd10="C699" if (regexm(coddeath,"EYE")|regexm(coddeath,"RETINA")|regexm(coddeath,"NEURO")) & icd10=="" //1 changes
replace icd10="C809" if record_id==34742|record_id==34847 //PSU, NOS
replace icd10="C441" if record_id==35178 //eyelid

count if (regexm(coddeath,"ASTROCY")|regexm(coddeath,"MULTIFORME")|regexm(coddeath,"BRAIN")) & icd10=="" //7
replace icd10="C719" if (regexm(coddeath,"ASTROCY")|regexm(coddeath,"MULTIFORME")|regexm(coddeath,"BRAIN")) & icd10=="" //7 changes

count if (regexm(coddeath,"THYROID")|regexm(coddeath,"ADRENAL")|regexm(coddeath,"ENDOCRI")) & icd10=="" //1
replace icd10="C73" if (regexm(coddeath,"THYROID")|regexm(coddeath,"ADRENAL")|regexm(coddeath,"ENDOCRI")) & icd10=="" //1 change

count if (regexm(coddeath,"UNKNOWN")|regexm(coddeath,"CULT")) & icd10=="" //15
replace icd10="C800" if (regexm(coddeath,"UNKNOWN")|regexm(coddeath,"CULT")) & icd10=="" //15 changes
replace icd10="C109" if record_id==37314 //oropharynx
replace icd10="C950" if record_id==34977 //acute leukaemia

count if (regexm(coddeath,"HODGKIN") & regexm(coddeath,"NON")) & icd10=="" //18
replace icd10="C859" if (regexm(coddeath,"HODGKIN") & regexm(coddeath,"NON")) & icd10=="" //18 changes
replace icd10="C829" if record_id==34533 //follicular lymphoma, NOS
replace icd10="C849" if record_id==35331|record_id==35866 //T-cell lymphoma,NOS
replace icd10="C830" if record_id==35491 //small cell lymphoma

count if regexm(coddeath,"HODGKIN") & icd10=="" //1
replace icd10="C819" if regexm(coddeath,"HODGKIN") & icd10=="" //1 change

count if (regexm(coddeath,"FOLLICUL") & regexm(coddeath,"LYMPH")) & icd10=="" //0

count if (regexm(coddeath,"MULTIPLE") & regexm(coddeath,"OMA")) & icd10=="" //20
replace icd10="C900" if (regexm(coddeath,"MULTIPLE") & regexm(coddeath,"OMA")) & icd10=="" //20 changes

count if regexm(coddeath,"PLASMACYTOMA") & icd10=="" //0
//replace icd10="C903" if regexm(coddeath,"PLASMACYTOMA") & icd10=="" //1 change

count if regexm(coddeath,"SEZARY") & icd10=="" //0
//replace icd10="C841" if regexm(coddeath,"SEZARY") & icd10=="" //1 change

count if (regexm(coddeath,"LYMPH")|regexm(coddeath,"EMIA")|regexm(coddeath,"PHOMA")) & icd10=="" //22
replace icd10="C950" if record_id==36689 //acute leukaemia
replace icd10="C959" if record_id==36616 //leukaemia, NOS
replace icd10="C920" if record_id==35084|record_id==36018|record_id==36176|record_id==37188  //AML
replace icd10="C910" if record_id==35382 //ALL, NOS
replace icd10="C911" if record_id==34175|record_id==34470|record_id==34956|record_id==36527|record_id==36544 //CLL
replace icd10="C915" if record_id==35997|record_id==36270 //ALL, T-cell
replace icd10="C809" if record_id==35576|record_id==36475 //PSU, NOS
replace icd10="C859" if record_id==35577|record_id==36526|record_id==36665|record_id==37154 //lymphoma NOS
replace icd10="C921" if record_id==35921|record_id==35941 //CML
//replace icd10="C880" if record_id== //lymphoplasmacytic lymphoma
//replace icd10="D464" if record_id== & did=="T1" //refractory anaemia, NOS
//replace icd10="C849" if record_id== //adult T-cell lymphoma
//replace icd10="C833" if record_id== //diffuse large b-cell lymphoma
//replace icd10="C849" if record_id== //t-cell lymphoma, NOS
//replace icd10="D469" if record_id== //MDS

** Assign codes to all unassigned
count if icd10=="" //34

replace icd10="C140" if record_id==36607 //throat
replace icd10="C61" if record_id==35972|record_id==37194 //prostate
replace icd10="C495" if record_id==34383 //fibrous histiocytoma, gluteal region
replace icd10="C762" if record_id==36612 //abdomen, NOS
replace icd10="C55" if record_id==34928 //uterus, NOS
replace icd10="C259" if record_id==35618|record_id==36281 //pancreas, NOS
replace icd10="C260" if record_id==35932 //bowel, NOS
replace icd10="C221" if record_id==35765 //cholangiocarcinoma
replace icd10="C809" if record_id==34128|record_id==34329|record_id==34538|record_id==35023 ///
						|record_id==35388 //PSU, NOS
replace icd10="C763" if record_id==35095 //perineum,NOS
replace icd10="C130" if record_id==35256 //postcricoid space
replace icd10="C679" if record_id==34335 //bladder,NOS
replace icd10="C740" if record_id==34485 //adenocortical
replace icd10="C109" if record_id==34224 //oropharynx
replace icd10="C73" if record_id==34834 //thyroid
replace icd10="C159" if record_id==35294 //esophagus, NOS
replace icd10="C119" if record_id==35947 //nasopharynx
replace icd10="C169" if record_id==34205 //stomach
replace icd10="C579" if record_id==35398|record_id==35688 //genitourinary tract (F)
replace icd10="D469" if record_id==34794 //MDS
replace icd10="C946" if record_id==34246 //myelodysplastic/myeloproliferative
replace icd10="C719" if record_id==34661 //brain, NOS
replace icd10="C509" if record_id==37162 //breast, NOS
replace icd10="C900" if record_id==34869|record_id==36357 //MM
replace icd10="C349" if record_id==35283|record_id==37108 //lung
//replace icd10="C052" if record_id== //uvula
//replace icd10="C763" if record_id== //pelvis, NOS
//replace icd10="C402" if record_id== //Ewing sarcoma, lower limb long bone (thigh)
//replace icd10="C492" if record_id==|record_id== //sarcoma, lower limb bone
//replace icd10="C493" if record_id==|record_id== //sarcoma, chest wall
//replace icd10="C56" if record_id== //ovary
//replace icd10="C541" if record_id== //endometrium
//replace icd10="C447" if record_id== //carcinoma skin, lower limb
//replace icd10="C139" if record_id==|record_id== //hypopharynx
//replace icd10="C248" if record_id==|record_id== //biliary tract, (not C22.0-C24.1)
//replace icd10="C180" if record_id== //colon, caecum
//replace icd10="C187" if record_id== //colon, sigmoid
//replace icd10="C445" if record_id== //carcinoma skin, chest wall
//replace icd10="C449" if record_id== //merkel
//replace icd10="C549" if record_id== //corpus uteri, NOS/mixed mullerian tumour
//replace icd10="C492" if record_id==|record_id== //sarcoma, upper limb
//replace icd10="C310" if record_id== //maxillary sinus
//replace icd10="C410" if record_id==|record_id== //bone, maxilla
//replace icd10="C700" if record_id== //intracranial meningioma, malignant
//replace icd10="D473" if record_id== //essential thrombocytosis
//replace icd10="C969" if record_id== //haem. malignancy
//replace icd10="C720" if record_id== //spinal cord
//replace icd10="C840" if record_id== //mycosis fungoides
//replace icd10="C051" if record_id== //soft palate
//replace icd10="C479" if record_id== //peripheral nerve
//replace icd10="C490" if record_id== //ear
//replace icd10="C229" if record_id==|record_id==|record_id== //liver, NOS
//replace icd10="C269" if record_id==|record_id== //gastronintestinal, NOS
//replace icd10="C411" if record_id== //mandible
//drop if record_id== //myeloproliferative disorder NOS is beh /1 - 1 deleted

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
replace siteiarc=2 if (regexm(icd10,"C01")|regexm(icd10,"C02")) //4 changes
replace siteiarc=3 if (regexm(icd10,"C03")|regexm(icd10,"C04")|regexm(icd10,"C05")|regexm(icd10,"C06")) //0 changes
replace siteiarc=4 if (regexm(icd10,"C07")|regexm(icd10,"C08")) //2 changes
replace siteiarc=5 if regexm(icd10,"C09") //0 changes
replace siteiarc=6 if regexm(icd10,"C10") //2 changes
replace siteiarc=7 if regexm(icd10,"C11") //1 change
replace siteiarc=8 if (regexm(icd10,"C12")|regexm(icd10,"C13")) //1 change
replace siteiarc=9 if regexm(icd10,"C14") //2 changes
replace siteiarc=10 if regexm(icd10,"C15") //8 changes
replace siteiarc=11 if regexm(icd10,"C16") //17 changes
replace siteiarc=12 if regexm(icd10,"C17") //6 changes
replace siteiarc=13 if regexm(icd10,"C18") //89 changes
replace siteiarc=14 if (regexm(icd10,"C19")|regexm(icd10,"C20")) //26 changes
replace siteiarc=15 if regexm(icd10,"C21") //1 change
replace siteiarc=16 if regexm(icd10,"C22") //11 changes
replace siteiarc=17 if (regexm(icd10,"C23")|regexm(icd10,"C24")) //3 changes
replace siteiarc=18 if regexm(icd10,"C25") //34 changes
replace siteiarc=19 if (regexm(icd10,"C30")|regexm(icd10,"C31")) //0 changes
replace siteiarc=20 if regexm(icd10,"C32") //1 change
replace siteiarc=21 if (regexm(icd10,"C33")|regexm(icd10,"C34")) //37 changes
replace siteiarc=22 if (regexm(icd10,"C37")|regexm(icd10,"C38")) //0 changes
replace siteiarc=23 if (regexm(icd10,"C40")|regexm(icd10,"C41")) //0 changes
replace siteiarc=24 if regexm(icd10,"C43") //2 changes
replace siteiarc=25 if regexm(icd10,"C44") //6 changes
replace siteiarc=26 if regexm(icd10,"C45") //1 change
replace siteiarc=27 if regexm(icd10,"C46") //0 changes
replace siteiarc=28 if (regexm(icd10,"C47")|regexm(icd10,"C49")) //2 changes
replace siteiarc=29 if regexm(icd10,"C50") //90 changes
replace siteiarc=30 if regexm(icd10,"C51") //0 changes
replace siteiarc=31 if regexm(icd10,"C52") //0 changes
replace siteiarc=32 if regexm(icd10,"C53") //15 changes
replace siteiarc=33 if regexm(icd10,"C54") //22 changes
replace siteiarc=34 if regexm(icd10,"C55") //7 changes
replace siteiarc=35 if regexm(icd10,"C56") //11 change
replace siteiarc=36 if regexm(icd10,"C57") //2 changes
replace siteiarc=37 if regexm(icd10,"C58") //0 changes
replace siteiarc=38 if regexm(icd10,"C60") //4 changes
replace siteiarc=39 if regexm(icd10,"C61") //144 changes
replace siteiarc=40 if regexm(icd10,"C62") //0 changes
replace siteiarc=41 if regexm(icd10,"C63") //0 changes
replace siteiarc=42 if regexm(icd10,"C64") //6 changes
replace siteiarc=43 if regexm(icd10,"C65") //0 changes
replace siteiarc=44 if regexm(icd10,"C66") //0 changes
replace siteiarc=45 if regexm(icd10,"C67") //7 changes
replace siteiarc=46 if regexm(icd10,"C68") //6 changes
replace siteiarc=47 if regexm(icd10,"C69") //0 changes
replace siteiarc=48 if (regexm(icd10,"C70")|regexm(icd10,"C71")|regexm(icd10,"C72")) //10 changes
replace siteiarc=49 if regexm(icd10,"C73") //2 changes
replace siteiarc=50 if regexm(icd10,"C74") //1 change
replace siteiarc=51 if regexm(icd10,"C75") //1 change
replace siteiarc=52 if regexm(icd10,"C81") //1 change
replace siteiarc=53 if (regexm(icd10,"C82")|regexm(icd10,"C83")|regexm(icd10,"C84")|regexm(icd10,"C85")|regexm(icd10,"C86")|regexm(icd10,"C96")) //27 changes
replace siteiarc=54 if regexm(icd10,"C88") //0 changes
replace siteiarc=55 if regexm(icd10,"C90") //32 changes
replace siteiarc=56 if regexm(icd10,"C91") //8 changes
replace siteiarc=57 if (regexm(icd10,"C92")|regexm(icd10,"C93")|regexm(icd10,"C94")) //8 changes
replace siteiarc=58 if regexm(icd10,"C95") //3 changes
replace siteiarc=59 if regexm(icd10,"D47") //0 changes
replace siteiarc=60 if regexm(icd10,"D46") //2 changes
replace siteiarc=61 if (regexm(icd10,"C26")|regexm(icd10,"C39")|regexm(icd10,"C48")|regexm(icd10,"C76")|regexm(icd10,"C80")) //35 changes
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
replace siteiarchaem=1 if icd10=="C859"|icd10=="C851"|icd10=="C826"|icd10=="C969" //23 changes
replace siteiarchaem=2 if icd10=="C819"|icd10=="C814"|icd10=="C813"|icd10=="C812"|icd10=="C811"|icd10=="C810" //1 change
replace siteiarchaem=3 if icd10=="C830"|icd10=="C831"|icd10=="C833"|icd10=="C837"|icd10=="C838"|icd10=="C857"|icd10=="C859"|icd10=="C852"|icd10=="C829"|icd10=="C821"|icd10=="C820"|icd10=="C822"|icd10=="C420"|icd10=="C421"|icd10=="C424"|icd10=="C884"|regexm(icd10,"C77") //24 changes
replace siteiarchaem=4 if icd10=="C840"|icd10=="C841"|icd10=="C844"|icd10=="C865"|icd10=="C863"|icd10=="C848"|icd10=="C838"|icd10=="C846"|icd10=="C861"|icd10=="C862"|icd10=="C866"|icd10=="C860"|icd10=="C849" //2 changes
replace siteiarchaem=5 if icd10=="C845"|icd10=="C835" //0 changes
replace siteiarchaem=6 if icd10=="C903"|icd10=="C900"|icd10=="C901"|icd10=="C902"|icd10=="C833" //32 changes
replace siteiarchaem=7 if icd10=="D470"|icd10=="C962"|icd10=="C943" //0 changes
replace siteiarchaem=8 if icd10=="C968"|icd10=="C966"|icd10=="C964" //0 changes
replace siteiarchaem=9 if icd10=="C889"|icd10=="C880"|icd10=="C882"|icd10=="C883"|icd10=="D472"|icd10=="C838"|icd10=="C865"|icd10=="D479"|icd10=="D477" //0 changes
replace siteiarchaem=10 if icd10=="C959"|icd10=="C950" //3 changes
replace siteiarchaem=11 if icd10=="C910"|icd10=="C919"|icd10=="C911"|icd10=="C918"|icd10=="C915"|icd10=="C917"|icd10=="C913"|icd10=="C916" //8 changes
replace siteiarchaem=12 if icd10=="C940"|icd10=="C929"|icd10=="C920"|icd10=="C921"|icd10=="C924"|icd10=="C925"|icd10=="C947"|icd10=="C922"|icd10=="C930"|icd10=="C928"|icd10=="C926"|icd10=="D471"|icd10=="C927"|icd10=="C942"|icd10=="C946"|icd10=="C923"|icd10=="C944"|icd10=="C914"|icd10=="C912" //7 changes
replace siteiarchaem=13 if icd10=="C931"|icd10=="C933"|icd10=="C947" //1 change
replace siteiarchaem=14 if icd10=="D45"|icd10=="D471"|icd10=="D474"|icd10=="D473"|icd10=="D475"|icd10=="C927"|icd10=="C967" //0 changes
replace siteiarchaem=15 if icd10=="D477"|icd10=="D471" //0 changes
replace siteiarchaem=16 if icd10=="D465"|icd10=="D466"|icd10=="D467"|icd10=="D469" //2 changes

tab siteiarchaem ,m //619 missing - correct!
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
					 |regexm(icd10,"C12")|regexm(icd10,"C13")|regexm(icd10,"C14")) //12 changes
replace sitecr5db=2 if regexm(icd10,"C15") //8 changes
replace sitecr5db=3 if regexm(icd10,"C16") //17 changes
replace sitecr5db=4 if (regexm(icd10,"C18")|regexm(icd10,"C19")|regexm(icd10,"C20")|regexm(icd10,"C21")) //116 changes
replace sitecr5db=5 if regexm(icd10,"C22") //11 changes
replace sitecr5db=6 if regexm(icd10,"C25") //34 changes
replace sitecr5db=7 if regexm(icd10,"C32") //1change
replace sitecr5db=8 if (regexm(icd10,"C33")|regexm(icd10,"C34")) //37 changes
replace sitecr5db=9 if regexm(icd10,"C43") //2 changes
replace sitecr5db=10 if regexm(icd10,"C50") //90 changes
replace sitecr5db=11 if regexm(icd10,"C53") //15 changes
replace sitecr5db=12 if (regexm(icd10,"C54")|regexm(icd10,"C55")) //29 changes
replace sitecr5db=13 if regexm(icd10,"C56") //11 changes
replace sitecr5db=14 if regexm(icd10,"C61") //144 changes
replace sitecr5db=15 if regexm(icd10,"C62") //0 changes
replace sitecr5db=16 if (regexm(icd10,"C64")|regexm(icd10,"C65")|regexm(icd10,"C66")|regexm(icd10,"C68")) //12 changes
replace sitecr5db=17 if regexm(icd10,"C67") //7 changes
replace sitecr5db=18 if (regexm(icd10,"C70")|regexm(icd10,"C71")|regexm(icd10,"C72")) //10 changes
replace sitecr5db=19 if regexm(icd10,"C73") //2 changes
replace sitecr5db=20 if siteiarc==61 //35 changes
replace sitecr5db=21 if (regexm(icd10,"C81")|regexm(icd10,"C82")|regexm(icd10,"C83")|regexm(icd10,"C84")|regexm(icd10,"C85")|regexm(icd10,"C88")|regexm(icd10,"C90")|regexm(icd10,"C96")) //60 changes
replace sitecr5db=22 if (regexm(icd10,"C91")|regexm(icd10,"C92")|regexm(icd10,"C93")|regexm(icd10,"C94")|regexm(icd10,"C95")) //19 changes
replace sitecr5db=23 if (regexm(icd10,"C17")|regexm(icd10,"C23")|regexm(icd10,"C24")) //9 changes
replace sitecr5db=24 if (regexm(icd10,"C30")|regexm(icd10,"C31")) //0 changes
replace sitecr5db=25 if (regexm(icd10,"C40")|regexm(icd10,"C41")|regexm(icd10,"C45")|regexm(icd10,"C47")|regexm(icd10,"C49")) //3 changes
replace sitecr5db=26 if siteiarc==25 //6 changes
replace sitecr5db=27 if (regexm(icd10,"C51")|regexm(icd10,"C52")|regexm(icd10,"C57")|regexm(icd10,"C58")) //2 changes
replace sitecr5db=28 if (regexm(icd10,"C60")|regexm(icd10,"C63")) //4 changes
replace sitecr5db=29 if (regexm(icd10,"C74")|regexm(icd10,"C75")) //2 changes
replace sitecr5db=30 if siteiarc==59 //0 changes
replace sitecr5db=31 if siteiarc==60 //2 changes
replace sitecr5db=32 if siteiarc==64 //0 changes
replace sitecr5db=34 if icd10=="C37"|icd10=="C380"|icd10=="C383"|icd10=="C468"|icd10=="C699"|icd10=="C865"|icd10=="C866" //0 changes

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
					 |regexm(icd10,"C12")|regexm(icd10,"C13")|regexm(icd10,"C14")) //12 changes
replace siteicd10=2 if (regexm(icd10,"C15")|regexm(icd10,"C16")|regexm(icd10,"C17") ///
					 |regexm(icd10,"C18")|regexm(icd10,"C19")|regexm(icd10,"C20") ///
					 |regexm(icd10,"C21")|regexm(icd10,"C22")|regexm(icd10,"C23") ///
					 |regexm(icd10,"C24")|regexm(icd10,"C25")|regexm(icd10,"C26")) //198 changes
replace siteicd10=3 if (regexm(icd10,"C30")|regexm(icd10,"C31")|regexm(icd10,"C32")|regexm(icd10,"C33")|regexm(icd10,"C34")|regexm(icd10,"C37")|regexm(icd10,"C38")|regexm(icd10,"C39")) //38 changes
replace siteicd10=4 if (regexm(icd10,"C40")|regexm(icd10,"C41")) //0 changes
replace siteicd10=5 if siteiarc==24 //2 changes
replace siteicd10=6 if siteiarc==25 //6 changes
replace siteicd10=7 if (regexm(icd10,"C45")|regexm(icd10,"C46")|regexm(icd10,"C47")|regexm(icd10,"C48")|regexm(icd10,"C49")) //4 changes
replace siteicd10=8 if regexm(icd10,"C50") //90 changes
replace siteicd10=9 if (regexm(icd10,"C51")|regexm(icd10,"C52")|regexm(icd10,"C53")|regexm(icd10,"C54")|regexm(icd10,"C55")|regexm(icd10,"C56")|regexm(icd10,"C57")|regexm(icd10,"C58")) //57 changes
replace siteicd10=10 if regexm(icd10,"C61") //144 changes
replace siteicd10=11 if (regexm(icd10,"C60")|regexm(icd10,"C62")|regexm(icd10,"C63")) //4 changes
replace siteicd10=12 if (regexm(icd10,"C64")|regexm(icd10,"C65")|regexm(icd10,"C66")|regexm(icd10,"C67")|regexm(icd10,"C68")) //19 changes
replace siteicd10=13 if (regexm(icd10,"C69")|regexm(icd10,"C70")|regexm(icd10,"C71")|regexm(icd10,"C72")) //10 changes
replace siteicd10=14 if (regexm(icd10,"C73")|regexm(icd10,"C74")|regexm(icd10,"C75")) //4 changes
replace siteicd10=15 if (regexm(icd10,"C76")|regexm(icd10,"C77")|regexm(icd10,"C78")|regexm(icd10,"C79")) //3 changes
replace siteicd10=16 if regexm(icd10,"C80") //28 changes
replace siteicd10=17 if (regexm(icd10,"C81")|regexm(icd10,"C82")|regexm(icd10,"C83") ///
					 |regexm(icd10,"C84")|regexm(icd10,"C85")|regexm(icd10,"C86") ///
					 |regexm(icd10,"C87")|regexm(icd10,"C88")|regexm(icd10,"C89") ///
					 |regexm(icd10,"C90")|regexm(icd10,"C91")|regexm(icd10,"C92") ///
					 |regexm(icd10,"C93")|regexm(icd10,"C94")|regexm(icd10,"C95") ///
					 |regexm(icd10,"C96")|regexm(icd10,"D46")|regexm(icd10,"D47")) //81 changes


tab siteicd10 ,m //0 missing

drop dupobs* dup_id

order record_id did fname lname age age5 age_10 sex dob nrn parish dod dodyear cancer siteiarc siteiarchaem pod coddeath

label data "BNR MORTALITY data 2021: Identifiable Dataset"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version09\3-output\2021_prep mort_identifiable" ,replace
note: TS This dataset is used for analysis of age-standardized mortality rates
note: TS This dataset includes patients with multiple eligible cancer causes of death

preserve
** Create corrected dataset with reportable cases but de-identified data
drop fname lname natregno nrn pname mname dob parish regnum address pod placeofdeath certifier certifieraddr
** Save this death dataset with de-identified data
label data "BNR MORTALITY data 2021: De-identified Dataset"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version09\3-output\2021_prep mort_deidentified" ,replace
note: TS This dataset is used for analysis of age-standardized mortality rates
note: TS This dataset includes patients with multiple eligible cancer causes of death
restore

preserve
** Create de-identified dataset that includes pod and placeofdeath for BNR CME 2022 webinar (p131/v16)
drop fname lname natregno nrn pname mname dob parish regnum address certifier certifieraddr
drop if did=="T2" //7 deleted
** Save this death dataset with de-identified data
label data "BNR MORTALITY data 2021: De-identified Dataset for BNR 2022 CME"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "X:/The University of the West Indies/DataGroup - repo_data/data_p131\version16\1-input\2021_prep mort_cancer_deidentified" ,replace
note: TS This dataset is used for analysis for the BNR CME 2022 webinar
note: TS This dataset DOES NOT include patients with multiple eligible cancer causes of death
restore