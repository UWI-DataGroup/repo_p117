** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          5c_prep_mort 2019+2020.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      13-JUN-2022 (version04)
    // 	date last modified      29-JUN-2022 (version04)
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
    log using "`logpath'\5c_prep_mort 2019+2020.smcl", replace
** HEADER -----------------------------------------------------

/* 
	JC 13jun2022:
	
		NS requested the 2019 + 2020 ASMRs to compare with Globocan rates for B'dos.
		
	For the 2018 ASMRs (see 5a_prep mort.do in 2018AnnualReportV02 branch), the death data was corrected as there were numerous errors with NRN and names fields.
	This dofile uses the corrected dataset from that set of analysis.
	
	** JC 13jun2022: SF emailed on 02jun2022 with correction to dod year for record_id 26742 so corrected in 5a_prep mort.do (which created the dataset used in this dofile) 
					 and re-ran 10a_analysis mort.do
*/

***************
** DATA IMPORT  
***************
** JC 22aug2022: mortality analyses was done in p117version04 for the Globocan comparison requested by NS + the 2022 BNR CME webinar so using the dofiles and ds from that version (version04/3-output)
use "`datapath'\version09\3-output\2015-2020_deaths_for_matching" ,clear

************************
**     Preparing      **
** 2019 + 2020 Deaths **
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
       2018 |      2,527       16.39       65.04
       2019 |      2,786       18.07       83.11
       2020 |      2,603       16.89      100.00
------------+-----------------------------------
      Total |     15,416      100.00
*/
gen dodyr=year(dod)
count if dodyear!=dodyr //0
drop dodyr


drop if dodyear!=2019 & dodyear!=2020 //10,027 deleted
** Remove Tracking Form info (already previously removed)
//drop if event==2 //0 deleted

count //5389

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
count if dupname>0 //216
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

drop if record_id==28415 //duplicate of record_id 32639 //1 deleted - in 16jun2022 email KG checked and indicated dod should be 2019 .
replace dod=dod-366 if record_id==32639
replace regdate=regdate-366 if record_id==32639
replace dodyear=2019 if record_id==32639
replace namematch=1 if dupname>0 & namematch!=1 //108 changes

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
count if dupdod>0 //0
list record_id namematch fname lname nrn dod sex age if dupdod>0
count if dupdod>0 & namematch!=1 //0
drop dupname dupdod
drop if record_id==24065 //this record is a combination of info from record_id 24066 + 24073 so deleted this record in REDcapdb also

count //5388


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
     cancer |      1,333       24.74       24.74
 not cancer |      4,055       75.26      100.00
------------+-----------------------------------
      Total |      5,388      100.00
*/

tab cancer dodyear ,m
/*
    cancer |        dodyear
 diagnoses |      2019       2020 |     Total
-----------+----------------------+----------
    cancer |       676        657 |     1,333 
not cancer |     2,109      1,946 |     4,055 
-----------+----------------------+----------
     Total |     2,785      2,603 |     5,388
*/

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
     Dead of cancer |      1,333       24.74       24.74
Dead of other cause |      4,006       74.35       99.09
          Not known |         49        0.91      100.00
--------------------+-----------------------------------
              Total |      5,388      100.00
*/

tab cod dodyear ,m
/*
                    |        dodyear
     COD categories |      2019       2020 |     Total
--------------------+----------------------+----------
     Dead of cancer |       676        657 |     1,333 
Dead of other cause |     2,083      1,923 |     4,006 
          Not known |        26         23 |        49 
--------------------+----------------------+----------
              Total |     2,785      2,603 |     5,388
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
     Female |      2,659       49.35       49.35
       Male |      2,729       50.65      100.00
------------+-----------------------------------
      Total |      5,388      100.00
*/
tab sex dodyear ,m
/*
           |        dodyear
       Sex |      2019       2020 |     Total
-----------+----------------------+----------
    Female |     1,386      1,273 |     2,659 
      Male |     1,399      1,330 |     2,729 
-----------+----------------------+----------
     Total |     2,785      2,603 |     5,388
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
					 11 "Other/Hotel" 12 "Isolation facility" 99 "ND", modify
label values pod pod_lab
label var pod "Place of Death from National Register"

replace pod=1 if regexm(placeofdeath, "ELIZABETH HOSP") & pod==. //62 changes
replace pod=1 if regexm(placeofdeath, "QUEEN ELZ") & pod==. //0 changes
replace pod=1 if regexm(placeofdeath, "QEH") & pod==. //2747 changes
replace pod=1 if regexm(placeofdeath, "Q.E.H") & pod==. //59 changes
replace pod=3 if regexm(placeofdeath, "GERIATRIC") & pod==. //163 changes
replace pod=3 if regexm(placeofdeath, "GERIACTIRC") & pod==. //0 chagnes
replace pod=3 if regexm(placeofdeath, "GERIACTRIC") & pod==. //0 chagnes
replace pod=5 if regexm(placeofdeath, "CHILDRENS HOME") & pod==. //0 chagnes
replace pod=4 if regexm(placeofdeath, "HOME") & pod==. //221 changes
replace pod=4 if regexm(placeofdeath, "ELDERLY") & pod==. //4 changes
replace pod=4 if regexm(placeofdeath, "SERENITY MANOR") & pod==. //0 changes
replace pod=4 if regexm(placeofdeath, "ADULT CARE") & pod==. //0 changes
replace pod=4 if regexm(placeofdeath, "AGE ASSIST") & pod==. //0 changes
replace pod=4 if regexm(placeofdeath, "SENIOR") & pod==. //6 changes
replace pod=4 if regexm(placeofdeath, "RETREAT") & pod==. //27 changes
replace pod=4 if regexm(placeofdeath, "RETIREMENT") & pod==. //3 changes
replace pod=4 if regexm(placeofdeath, "NURSING") & pod==. //4 changes
replace pod=5 if regexm(placeofdeath, "PRISON") & pod==. //0 changes
replace pod=5 if regexm(placeofdeath, "POLYCLINIC") & pod==. //10 changes
replace pod=5 if regexm(placeofdeath, "MINISTRIES") & pod==. //0 changes
replace pod=5 if regexm(placeofdeath, "HIGHWAY") & pod==. //2 changes - FOR THESE CHECK COD TO DIFFERENTIATE BETWEEN ROAD ACCIDENT AND AT HOME DEATH
replace pod=5 if regexm(placeofdeath, "ROUNDABOUT") & pod==. //0 changes - FOR THESE CHECK COD TO DIFFERENTIATE BETWEEN ROAD ACCIDENT AND AT HOME DEATH
replace pod=5 if regexm(placeofdeath, "JUNCTION") & pod==. //0 changes - FOR THESE CHECK COD TO DIFFERENTIATE BETWEEN ROAD ACCIDENT AND AT HOME DEATH
replace pod=6 if regexm(placeofdeath, "STRICT HOSP") & pod==. //30 changes
replace pod=6 if regexm(placeofdeath, "GORDON CUMM") & pod==. //0 changes
replace pod=7 if regexm(placeofdeath, "PSYCHIATRIC HOSP") & pod==. //24 changes
replace pod=7 if regexm(placeofdeath, "PSYCIATRIC HOSP") & pod==. //0 changes
replace pod=7 if regexm(placeofdeath, "PSYCHIATRIC") & pod==. //2 changes
replace pod=8 if regexm(placeofdeath, "BAYVIEW") & pod==. //50 changes
replace pod=8 if regexm(placeofdeath, "BAY VIEW HOSP") & pod==. //1 change
replace pod=9 if regexm(placeofdeath, "SANDY CREST") & pod==. //8 changes
replace pod=9 if regexm(placeofdeath, "FMH CLINIC") & pod==. //0 changes
replace pod=9 if regexm(placeofdeath, "FMH EMERGENCY") & pod==. //0 changes
replace pod=9 if regexm(placeofdeath, "SPARMAN CLINIC") & pod==. //4 changes
replace pod=9 if regexm(placeofdeath, "CLINIC") & pod==. //3 changes
replace pod=10 if regexm(placeofdeath, "BRIDGETOWN PORT") & pod==. //12 changes
replace pod=11 if regexm(placeofdeath, "HOTEL") & pod==. //3 changes
replace pod=99 if placeofdeath=="" & pod==. //0 changes
replace pod=99 if placeofdeath=="99" //46 changes

order record_id address placeofdeath parish deathparish coddeath
count if pod==. //1897 - check address against placeofdeath in Stata Browse window
//list record_id placeofdeath if pod==.
count if pod==. & parish!=deathparish //139 - check COD to determine if road accident or at home death
//list record_id address parish placeofdeath deathparish if pod==. & parish!=deathparish
count if pod==. & parish!=deathparish & (regexm(coddeath, "CORONA")|regexm(coddeath, "COVID")) //12

replace pod=2 if pod==. & address==placeofdeath //913 changes
replace pod=2 if pod==. & parish==deathparish //852 changes
replace pod=12 if pod==. & parish!=deathparish & (regexm(coddeath, "CORONA")|regexm(coddeath, "COVID")) //12 changes
replace pod=11 if pod==. & parish!=deathparish & address!=placeofdeath //120 changes

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

count if natregno=="" & nrn!=. //1
gen double nrn2=nrn if record_id==28513
tostring nrn2 ,replace
replace nrn2=subinstr(nrn2,"3","3-",.) if record_id==28513
replace natregno=nrn2 if record_id==28513
drop nrn2

count if natregno=="" //231
count if natregno=="" & age!=0 //231
count if natregno=="" & age!=0 & !(strmatch(strupper(address), "*BRIDGETOWN PORT*")) & !(strmatch(strupper(pname), "*BABY*")) //204 - checked against 2021 electoral list + updated NRN in REDCapdb
replace pod=11 if record_id==29351|record_id==28202|record_id==27410
drop if record_id==29548 //duplicate of record_id 27369
count if age==. //0

** Add missing NRNs flagged above with list of NRNs manually created using electoral list (this ensures dofile remains de-identified)
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
replace yr1 = 19 if record_id==29610|record_id==30063

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
count if tempvarn!=6 & age!=ageyrs //27
sort record_id
list record_id fname lname address age ageyrs nrn natregno dob dobcheck dod yr1 if tempvarn!=6 & age!=ageyrs, string(20) //check against electoral list
count if dobcheck!=. & dob==. //5,206
replace dob=dobcheck if dobcheck!=. & dob==. //5,206 changes
//replace nrn=. if record_id==34112 - KG checked 24jun2022 and confirmed NRN and age are correct since pt's age = 18 months
//replace natregno="" if record_id==34112
replace age=ageyrs if tempvarn!=6 & age!=ageyrs & ageyrs<100 //11 changes
drop day month dyear nrnyr yr yr1 year2 nrndob age2 ageyrs tempvarn dobcheck

** Check age
gen age2 = (dod - dob)/365.25
gen checkage2=int(age2)
drop age2
count if dob!=. & dod!=. & age!=checkage2 //15
list record_id fname lname dod dob age checkage2 if dob!=. & dod!=. & age!=checkage2 //all correct
//replace age=checkage2 if dob!=. & dod!=. & age!=checkage2 //0 changes
drop checkage2

** Check no missing dxyr so this can be used in analysis
tab dodyear ,m //5387 - none missing
/*
    dodyear |      Freq.     Percent        Cum.
------------+-----------------------------------
       2019 |      2,785       51.70       51.70
       2020 |      2,602       48.30      100.00
------------+-----------------------------------
      Total |      5,387      100.00
*/

count if dodyear!=year(dod) //0
//list pid record_id dod dodyear if dodyear!=year(dod)
replace dodyear=year(dod) if dodyear!=year(dod) //0 changes

label data "BNR MORTALITY data 2019 + 2020"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version09\3-output\2019_2020_prep mort_ALL" ,replace
note: TS This dataset is used for analysis of age-standardized mortality rates
note: TS This dataset includes all 2019 + 2020 CODs

** Create corrected dataset with reportable cases but de-identified data (2020 only)
preserve
drop if dodyear!=2020
drop fname lname natregno nrn pname mname dob parish regnum address certifier certifieraddr

count //2602

label data "BNR MORTALITY data 2020: De-identified Dataset"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version09\3-output\2020_prep mort_ALL_deidentified" ,replace
note: TS This dataset is used for the BNR CME 2022 webinar
note: TS This dataset includes all 2020 CODs
restore

** JC 26sep2022: SF requested proportion of cancer deaths of all deaths (comments on ann. rpt from Natalie Greaves)
preserve
egen morttot_2019=count(record_id) if dodyear==2019
egen morttot_2020=count(record_id) if dodyear==2020
contract morttot_*
drop _freq

append using "`datapath'\version09\2-working\mort_proportions"
fillmissing morttot_2016 morttot_2017 morttot_2018 morttot_2019 morttot_2020
save "`datapath'\version09\2-working\mort_proportions" ,replace
restore

*******************
** Check for MPs **
**   in CODs     **
*******************
count //5387

//list record_id
//list cod1a
tab cancer ,m //1333 cancer CODs
tab cancer dodyear ,m //676 cancer CODS in 2019; 657 in 2020
drop if cancer!=1 //4054 deleted

** MPs found above when assigning cancer variable in checking causes of death
sort coddeath record_id
order record_id coddeath //check Stata Browse window for MPs in CODs

** Create duplicate observations for MPs in CODs
expand=2 if record_id==27809, gen (dupobs1)
expand=2 if record_id==29720, gen (dupobs2)
expand=2 if record_id==27922, gen (dupobs3)
expand=2 if record_id==27043, gen (dupobs4)
expand=2 if record_id==29768, gen (dupobs5)
expand=2 if record_id==31999, gen (dupobs6)
expand=2 if record_id==28921, gen (dupobs7)
expand=2 if record_id==32399, gen (dupobs8)
expand=2 if record_id==32957, gen (dupobs9)
expand=2 if record_id==27947, gen (dupobs10) //checked MedData and the renal mass was listed as malignant; Emailed KWG with this update (15jun2022).
expand=2 if record_id==32418, gen (dupobs11)
expand=2 if record_id==27678, gen (dupobs12)
expand=2 if record_id==26923, gen (dupobs13)
expand=2 if record_id==32312, gen (dupobs14)
expand=2 if record_id==27492, gen (dupobs15)
expand=2 if record_id==33620, gen (dupobs16)
expand=2 if record_id==33272, gen (dupobs17)
expand=2 if record_id==31827, gen (dupobs18)
expand=2 if record_id==33660, gen (dupobs19)
expand=2 if record_id==33084, gen (dupobs20)
expand=2 if record_id==28926, gen (dupobs21)
expand=2 if record_id==27737, gen (dupobs22)
expand=2 if record_id==32999, gen (dupobs23)
expand=2 if record_id==33332, gen (dupobs24)
expand=2 if record_id==29451, gen (dupobs25)
expand=2 if record_id==33558, gen (dupobs26)
expand=2 if record_id==31683, gen (dupobs27)
expand=2 if record_id==32276, gen (dupobs28)
expand=2 if record_id==33614, gen (dupobs29)
/*
expand=2 if record_id==, gen (dupobs30)
expand=2 if record_id==, gen (dupobs31)
expand=2 if record_id==, gen (dupobs32)
expand=2 if record_id==, gen (dupobs33)
expand=2 if record_id==, gen (dupobs34) //found in below ICD10 lists
expand=2 if record_id==, gen (dupobs35) //found in below ICD10 lists
expand=2 if record_id==, gen (dupobs36) //found in below ICD10 lists
*/
drop if record_id==33843 //myelodysplasia, NOS is considered benign - 1 deleted
drop if record_id==27282 //tumour, uncertain/unk behaviour - 1 deleted
drop if record_id==31961 //myelofibrosis, NOS is considered benign - 1 deleted
drop if record_id==32786 //no cancer listed in CODs - 1 deleted
drop if record_id==33515 //mass - 1 deleted

** JC 15jun2022: below is an old note but kept in as maybe relevant in later years
//pid 20130770 CML in 2013 that transformed to either T-ALL or B-ALL in 2015 COD states C-CELL!
//M9811 (B-ALL) chosen as research shows "With few exceptions, Ph-positive ALL patients are diagnosed with B-ALL "
//https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4896164/
display `"{browse "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4896164/":Ph+ALL}"'

** JC 15jun2022: added the below corrections to excel list for KG to correct in REDCap multi-year deaht db: ...\Sync\BNR\Death Data Updates
replace coddeath=subinstr(coddeath,"ENDORIETRIAL","ENDOMETRIAL",.) if record_id==27356 //cancer spelt vancer when checking above list
replace coddeath=subinstr(coddeath,"ASPHYSCIATION","ASPHYXIATION",.) if record_id==32636
replace coddeath=subinstr(coddeath,"BENIGH","BENIGN",.) if record_id==28183
replace coddeath=subinstr(coddeath,"FALL","GALL",.) if record_id==29614
replace coddeath=subinstr(coddeath,"METASTATIS","METASTASIS",.) if record_id==27482
replace coddeath=subinstr(coddeath,"METASTAES","METASTASES",.) if record_id==29882
replace coddeath=subinstr(coddeath,"GLIOBESTOMA","GLIOBLASTOMA",.) if record_id==32579
replace coddeath=subinstr(coddeath,"MALGINANT","MALIGNANT",.) if record_id==31827
replace coddeath=subinstr(coddeath,"MELONMA","MELANOMA",.) if record_id==33714
replace coddeath=subinstr(coddeath,"OVERIAN","OVARIAN",.) if record_id==28392
replace coddeath=subinstr(coddeath,"OUCT","DUCT",.) if record_id==28305
replace coddeath=subinstr(coddeath,"AMPOLLA","AMPULLA",.) if record_id==29108
replace coddeath=subinstr(coddeath,"OFVATER","OF VATER",.) if record_id==29108
replace coddeath=subinstr(coddeath,"CELLED","CELL",.) if record_id==29149

count //1357

** Corrections from KG's checks on 24jun2022 (see L:\Sync\BNR\Death Data Updates\Updates for KG_20220614_KGedits.xlsx)
replace coddeath=subinstr(coddeath,"MYOCARDIAL","MYELOID",.) if record_id==32593
list record_id coddeath if regexm(coddeath, "PROSTAE") //JC emailed this correction to KG on 28jun2022
list record_id coddeath if regexm(coddeath, "LNG CANCER") //JC emailed this correction to KG on 28jun2022
replace coddeath=subinstr(coddeath,"PROSTAE","PROSTATE",.) if record_id==28287|record_id==32504
replace coddeath=subinstr(coddeath,"LNG CANCER","LUNG CANCER",.) if record_id==33372

** Create variables to identify patients vs tumours
gen ptrectot=.
replace ptrectot=1 if dupobs1==0|dupobs2==0|dupobs3==0|dupobs4==0 ///
					 |dupobs5==0|dupobs6==0|dupobs7==0|dupobs8==0 ///
					 |dupobs9==0|dupobs10==0|dupobs11==0|dupobs12==0 ///
					 |dupobs13==0|dupobs14==0|dupobs15==0|dupobs16==0 ///
					 |dupobs17==0|dupobs18==0|dupobs19==0|dupobs20==0 ///
					 |dupobs21==0|dupobs22==0|dupobs23==0|dupobs24==0 ///
					 |dupobs25==0|dupobs26==0|dupobs27==0|dupobs28==0 ///
					 |dupobs29==0 
					 //|dupobs30==0|dupobs31==0|dupobs32==0 ///
					 //|dupobs33==0|dupobs34==0|dupobs35==0|dupobs36==0 //1329 changes
replace ptrectot=2 if dupobs1>0|dupobs2>0|dupobs3>0|dupobs4>0 ///
					 |dupobs5>0|dupobs6>0|dupobs7>0|dupobs8>0 ///
					 |dupobs9>0|dupobs10>0|dupobs11>0|dupobs12>0 ///
					 |dupobs13>0|dupobs14>0|dupobs15>0|dupobs16>0 ///
					 |dupobs17>0|dupobs18>0|dupobs19>0|dupobs20>0 ///
					 |dupobs21>0|dupobs22>0|dupobs23>0|dupobs24>0 ///
					 |dupobs25>0|dupobs26>0|dupobs27>0|dupobs28>0 ///
					 |dupobs29>0
					 //|dupobs30>0|dupobs31>0|dupobs32>0 ///
					 //|dupobs33>0|dupobs34>0|dupobs35>0|dupobs36>0 //38 changes
label define ptrectot_lab 1 "COD with single event" 2 "COD with multiple events" , modify
label values ptrectot ptrectot_lab

tab ptrectot ,m

** Now create id in this dataset so when merging icd10 for siteiarc variable at end of this dofile
sort record_id
gen did="T1" if ptrectot==1
replace did="T2" if ptrectot==2 //29 changes
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
count //1357
tab cancer ,m //1357 cancers
tab cancer dodyear,m //688 cancers in 2019; 669 cancers in 2020

** Note: Although siteiarc doesn't need sub-site, the specific icd10 code was used, where applicable
display `"{browse "https://icd.who.int/browse10/2015/en#/C09":ICD10,v2015}"'

** Use Stata browse instead of lists
order record_id coddeath did
sort record_id

gen icd10=""

count if regexm(coddeath,"LIP") & icd10=="" //4 - not lip so no replace
//list record_id coddeath if regexm(coddeath,"LIP"),string(120)
replace icd10="C61" if record_id==27872 //1 change
replace icd10="C679" if record_id==32631 //1 change
replace icd10="C169" if record_id==32703 //1 change
replace icd10="C809" if record_id==33576 //1 change

count if regexm(coddeath,"TONGUE") & icd10=="" //5 - all tongue, NOS
//list record_id coddeath if regexm(coddeath,"TONGUE"),string(120)
replace icd10="C029" if regexm(coddeath,"TONGUE") & icd10=="" //5 changes

count if regexm(coddeath,"MOUTH") & icd10=="" //0
//list record_id coddeath if regexm(coddeath,"MOUTH"),string(120)

count if regexm(coddeath,"SALIVARY") & icd10=="" //0
//list record_id coddeath if regexm(coddeath,"SALIVARY"),string(120)
replace icd10="C089" if regexm(coddeath,"SALIVARY") & icd10=="" //0 changes

count if regexm(coddeath,"TONSIL") & icd10=="" //0
//list record_id coddeath if regexm(coddeath,"TONSIL"),string(120)
replace icd10="C099" if regexm(coddeath,"TONSIL") & icd10=="" //0 changes

count if regexm(coddeath,"OROPHARYNX") & icd10=="" //4
//list record_id coddeath if regexm(coddeath,"OROPHARYNX"),string(120)
replace icd10="C109" if regexm(coddeath,"OROPHARYNX") & icd10=="" //4 changes

count if regexm(coddeath,"NASOPHARYNX") & icd10=="" //1
//list record_id coddeath if regexm(coddeath,"NASOPHARYNX"),string(120)
replace icd10="C119" if regexm(coddeath,"NASOPHARYNX") & icd10=="" //1 change

count if regexm(coddeath,"HYPOPHARYNX") & icd10=="" //0
//list record_id coddeath if regexm(coddeath,"HYPOPHARYNX"),string(120)
//replace icd10="C139" if regexm(coddeath,"HYPOPHARYNX") & icd10=="" //1 change

count if (regexm(coddeath,"PHARYNX")|regexm(coddeath,"PHARNYX")) & icd10=="" //0
//list record_id coddeath if (regexm(coddeath,"PHARYNX")|regexm(coddeath,"PHARNYX")) & icd10=="",string(120)0
replace icd10="C140" if (regexm(coddeath,"PHARYNX")|regexm(coddeath,"PHARNYX")) & icd10=="" //0 changes

count if (regexm(coddeath,"OESOPHAG")|regexm(coddeath,"ESOPHAG")) & icd10=="" //22
replace icd10="C259" if record_id==31800
replace icd10="C189" if record_id==32418 & did=="T1"
replace icd10="C900" if record_id==32418 & did=="T2"
replace icd10="C800" if record_id==32960
replace icd10="C679" if record_id==33272 & did=="T1"
replace icd10="C159" if (regexm(coddeath,"OESOPHAG")|regexm(coddeath,"ESOPHAG")) & icd10=="" & record_id!=19807 & record_id!=19933 //17 changes

count if (regexm(coddeath,"STOMACH")|regexm(coddeath,"GASTR"))  & !(strmatch(strupper(coddeath), "*GASTROINTESTINAL BLEED*"))  & !(strmatch(strupper(coddeath), "*GASTROINTESTINAL HAEMORR*"))  & !(strmatch(strupper(coddeath), "*GASTROENTER*")) & icd10=="" //52
replace icd10="C169" if (regexm(coddeath,"STOMACH")|regexm(coddeath,"GASTR"))  & !(strmatch(strupper(coddeath), "*GASTROINTESTINAL BLEED*"))  & !(strmatch(strupper(coddeath), "*GASTROINTESTINAL HAEMORR*"))  & !(strmatch(strupper(coddeath), "*GASTROENTER*")) & icd10=="" //52 changes
replace icd10="C509" if record_id==27474 //breast
replace icd10="C859" if record_id==27219|record_id==28258|record_id==33620 & did=="T1" //lymphoma
replace icd10="C269" if record_id==28193|record_id==28822|record_id==32342 //gastronintestinal malignancy
replace icd10="C61" if record_id==27492 & did=="T2"|record_id==29937 //prostate
replace icd10="C187" if record_id==32999 & did=="T2" //colon, sigmoid
replace icd10="C189" if record_id==33620 & did=="T2"|record_id==33660 & did=="T2" //colon, NOS
replace icd10="C259" if record_id==27930 //pancreas

count if (regexm(coddeath,"DUODEN")|regexm(coddeath,"JEJUN")|regexm(coddeath,"ILEUM")|regexm(coddeath,"SMALL")) & !(strmatch(strupper(coddeath), "*SMALL CEL*")) & !(strmatch(strupper(coddeath), "*LARYNGEAL*")) & icd10=="" //15
replace icd10="C179" if (regexm(coddeath,"DUODEN")|regexm(coddeath,"JEJUN")|regexm(coddeath,"ILEUM")|regexm(coddeath,"SMALL")) & !(strmatch(strupper(coddeath), "*SMALL CEL*")) & !(strmatch(strupper(coddeath), "*LARYNGEAL*")) & icd10=="" //15 changes
replace icd10="C170" if record_id==32735|record_id==32787 //duodenum
replace icd10="C171" if record_id==33657 //jejunum
replace icd10="C189" if record_id==27488|record_id==28791|record_id==32038|record_id==33558 & did=="T2" //colon, NOS
replace icd10="C800" if record_id==29987
replace icd10="C809" if record_id==28519
replace icd10="C19" if record_id==28938 //colorectal
replace icd10="C20" if record_id==33047 //rectum
replace icd10="C61" if record_id==33558 & did=="T1" //prostate

count if (regexm(coddeath,"CECUM")|regexm(coddeath,"APPEND")|regexm(coddeath,"COLON")) & !(strmatch(strupper(coddeath), "*COLONIC POLYPS*")) & icd10=="" //152
replace icd10="C189" if (regexm(coddeath,"CECUM")|regexm(coddeath,"APPEND")|regexm(coddeath,"COLON")) & !(strmatch(strupper(coddeath), "*COLONIC POLYPS*")) & icd10=="" //152 changes
replace icd10="C180" if record_id==28124 //caecum
replace icd10="C181" if record_id==33776 //appendix
replace icd10="C182" if record_id==33812 //right or ascending colon
replace icd10="C187" if record_id==29559 //sigmoid colon
replace icd10="C509" if record_id==28926 & did=="T2"|record_id==29720 & did=="T1"|record_id==33084 & did=="T1" //breast MP
replace icd10="C19" if record_id==27426 //colorectal
replace icd10="C61" if record_id==32399 & did=="T2" //prostate
replace icd10="C66" if record_id==29768 & did=="T1" //ureter
replace icd10="C719" if record_id==27678 & did=="T2" //brain

count if (regexm(coddeath,"COLORECTAL")|regexm(coddeath,"RECTO")) & icd10=="" //5
replace icd10="C19" if (regexm(coddeath,"COLORECT")|regexm(coddeath,"RECTO")) & icd10=="" //5 changes
replace icd10="C61" if record_id==33161 //prostate

count if (regexm(coddeath,"RECTUM")|regexm(coddeath,"RECTAL")) & !(strmatch(strupper(coddeath), "*ANORECT*")) & icd10=="" //26
replace icd10="C20" if (regexm(coddeath,"RECTUM")|regexm(coddeath,"RECTAL")) & !(strmatch(strupper(coddeath), "*ANORECT*")) & icd10=="" //26 changes
replace icd10="C61" if record_id==27737 & did=="T1"|record_id==33261 //prostate

count if (regexm(coddeath,"ANUS")|regexm(coddeath,"ANORECT")|regexm(coddeath,"ANAL")) & icd10=="" //4
replace icd10="C218" if (regexm(coddeath,"ANUS")|regexm(coddeath,"ANORECT")|regexm(coddeath,"ANAL")) & icd10=="" //4 changes
replace icd10="C435" if record_id==33654 //melanoma, trunk

count if (regexm(coddeath,"LIVER")|regexm(coddeath,"BILE")|regexm(coddeath,"HEPATO")) & !(strmatch(strupper(coddeath), "*CHOLANGIOCAR*")) & icd10=="" //31
replace icd10="C229" if (regexm(coddeath,"LIVER")|regexm(coddeath,"BILE")|regexm(coddeath,"HEPATO")) & !(strmatch(strupper(coddeath), "*CHOLANGIOCAR*")) & icd10=="" //31 changes
replace icd10="C679" if record_id==28437 //bladder
replace icd10="C541" if record_id==33060 //endometrium
replace icd10="C248" if record_id==27604|record_id==28305 //hepatobiliary
replace icd10="C809" if record_id==26911|record_id==27111|record_id==27329|record_id==27698|record_id==27952|record_id==32039|record_id==32199 //PSU, NOS
replace icd10="C61" if record_id==27443|record_id==28107|record_id==28200|record_id==28706|record_id==32166 //prostate
replace icd10="C509" if record_id==26941|record_id==27353|record_id==27507|record_id==29573|record_id==33285 //breast
replace icd10="C220" if record_id==27150|record_id==30059|record_id==32280|record_id==32438 ///
						|record_id==32676|record_id==34051 //liver, specified/hepatocellular
replace icd10="C259" if record_id==29021|record_id==32677|record_id==32866 //pancreas
replace icd10="C249" if record_id==32210 //biliary tract

count if regexm(coddeath,"CHOLANGIO") & icd10=="" //5
replace icd10="C221" if regexm(coddeath,"CHOLANGIO") & icd10=="" //5 changes

count if (regexm(coddeath,"GALLBLAD")|regexm(coddeath,"GALL BLAD")) & icd10=="" //14
replace icd10="C23" if (regexm(coddeath,"GALLBLAD")|regexm(coddeath,"GALL BLAD")) & icd10=="" //14 changes

count if regexm(coddeath,"BILIARY") & icd10=="" //1
//replace icd10="C249" if regexm(coddeath,"BILIARY") & icd10=="" //1 change
replace icd10="C259" if record_id==27855

count if (regexm(coddeath,"PANCREA") & regexm(coddeath,"HEAD")) & icd10=="" //3
replace icd10="C250" if (regexm(coddeath,"PANCREA") & regexm(coddeath,"HEAD")) & icd10=="" //3 changes

count if regexm(coddeath,"PANCREA") & icd10=="" //45
replace icd10="C259" if regexm(coddeath,"PANCREA") & icd10=="" //45 changes

count if (regexm(coddeath,"NASAL")|regexm(coddeath,"EAR")) & icd10=="" //33-no nasal/ear so no replace

count if regexm(coddeath,"SINUS") & icd10=="" //1-no sinus

count if (regexm(coddeath,"LARYNX")|regexm(coddeath,"LARYNG")|regexm(coddeath,"GLOTTI")|regexm(coddeath,"VOCAL")) & icd10=="" //6
replace icd10="C329" if (regexm(coddeath,"LARYNX")|regexm(coddeath,"LARYNG")|regexm(coddeath,"GLOTTI")|regexm(coddeath,"VOCAL")) & icd10=="" //6 changes

count if regexm(coddeath,"TRACHEA") & icd10=="" //0

count if (regexm(coddeath,"LUNG")|regexm(coddeath,"BRONCH")) & icd10=="" //87
replace icd10="C349" if (regexm(coddeath,"LUNG")|regexm(coddeath,"BRONCH")) & icd10=="" //87 changes
replace icd10="C809" if record_id==26945 //PSU, NOS
replace icd10="C800" if record_id==28126|record_id==32899|record_id==33372 //PSU
replace icd10="C509" if record_id==27554|record_id==28158|record_id==29333|record_id==29581|record_id==33696|record_id==33706 //breast
replace icd10="C900" if record_id==29483 //MM
replace icd10="C541" if record_id==28921 & did=="T1" //endometrium
replace icd10="C61" if record_id==28157|record_id==28244|(record_id==31999 & did=="T2") //prostate
replace icd10="C859" if record_id==29604 //lymphoma, NOS
replace icd10="C539" if record_id==29975 //cervix
replace icd10="C402" if record_id==30043 //bone, femur
replace icd10="C609" if record_id==32663 //penis
replace icd10="C711" if record_id==28017 //brain, frontal

count if regexm(coddeath,"THYMUS") & icd10=="" //0

count if (regexm(coddeath,"HEART")|regexm(coddeath,"MEDIASTIN")|regexm(coddeath,"PLEURA")) & icd10=="" //39-none found so no replace
replace icd10="C37" if record_id==28746 //thymus
replace icd10="C383" if record_id==33945 //mediastinal

count if (regexm(coddeath,"BONE")|regexm(coddeath,"OSTEO")|regexm(coddeath,"CARTILAGE")) & icd10=="" //10-none found so no replace
replace icd10="C241" if record_id==29108 //ampulla vater
replace icd10="C419" if record_id==33638 //bone, NOS

count if (regexm(coddeath,"SKIN")|regexm(coddeath,"MELANOMA")|regexm(coddeath,"SQUAMOUS")|regexm(coddeath,"BASAL")) & icd10=="" //18
replace icd10="C439" if (regexm(coddeath,"SKIN")|regexm(coddeath,"MELANOMA")|regexm(coddeath,"SQUAMOUS")|regexm(coddeath,"BASAL")) & icd10=="" //18 changes

replace icd10="C449" if record_id==29451 & did=="T2"|record_id==31580 //SCC, BCC, NOS
replace icd10="C439" if record_id==27602|record_id==32276 & did=="T2"|record_id==32312 & did=="T1"|record_id==33555|record_id==33714 //melanoma, NOS
replace icd10="C443" if record_id==27411|record_id==27715|record_id==28769 //SCC, BCC, face
replace icd10="C61" if record_id==27910|record_id==28863 //prostate
replace icd10="C441" if record_id==27964 //SCC, BCC, eye
replace icd10="C447" if record_id==28300 //SCC, BCC, lower limb
replace icd10="C539" if record_id==29149 //cervix
replace icd10="C679" if record_id==29451 & did=="T1"|record_id==32312 & did=="T2" //bladder
replace icd10="C762" if record_id==32276 & did=="T1" //abdomen


count if (regexm(coddeath,"MESOTHELIOMA")|regexm(coddeath,"KAPOSI")|regexm(coddeath,"NERVE")|regexm(coddeath,"PERITON")) & icd10=="" //2
replace icd10="C689" if record_id==33318 //urinary organ, NOS
replace icd10="C459" if record_id==27556 //mesothelioma, NOS

count if regexm(coddeath,"BREAST") & icd10=="" //159
//list record_id coddeath if regexm(coddeath,"BREAST"),string(120)
replace icd10="C509" if regexm(coddeath,"BREAST") & icd10=="" //137 changes
replace icd10="C443" if record_id==26923 & did=="T2" //SCC, BCC, face
replace icd10="C61" if record_id==27043 & did=="T2"|record_id==32957 & did=="T1" //prostate MP
replace icd10="C539" if record_id==27809 & did=="T1" //cervix
replace icd10="C541" if record_id==27922 & did=="T2" //endometrium MP

count if regexm(coddeath,"VULVA") & icd10=="" //0
replace icd10="C519" if regexm(coddeath,"VULVA") & icd10=="" //0 changes

count if regexm(coddeath,"VAGINA") & icd10=="" //4
replace icd10="C52" if regexm(coddeath,"VAGINA") & icd10=="" //4 changes
replace icd10="C55" if record_id==33614 & did=="T1" //uterus, NOS

count if (regexm(coddeath,"CERVICAL")|regexm(coddeath,"CERVIX")) & icd10=="" //17
replace icd10="C539" if (regexm(coddeath,"CERVICAL")|regexm(coddeath,"CERVIX")) & icd10=="" //17 changes


count if (regexm(coddeath,"ENDOMETRI")|regexm(coddeath,"CORPUS")) & icd10=="" //52
replace icd10="C541" if (regexm(coddeath,"ENDOMETRI")|regexm(coddeath,"CORPUS")) & icd10=="" //52 changes
replace icd10="C64" if record_id==31827 & did=="T1" //urinary organ, NOS


count if (regexm(coddeath,"UTERINE")|regexm(coddeath,"UTERUS")) & icd10=="" //17
replace icd10="C55" if (regexm(coddeath,"UTERINE")|regexm(coddeath,"UTERUS")) & icd10=="" //17 changes


count if (regexm(coddeath,"OVARY")|regexm(coddeath,"OVARIAN")) & icd10=="" //21
replace icd10="C56" if (regexm(coddeath,"OVARY")|regexm(coddeath,"OVARIAN")) & icd10=="" //21 changes


count if (regexm(coddeath,"FALLOPIAN")|regexm(coddeath,"FEMALE")) & icd10=="" //0

count if (regexm(coddeath,"PENIS")|regexm(coddeath,"PENILE")) & icd10=="" //1
replace icd10="C609" if (regexm(coddeath,"PENIS")|regexm(coddeath,"PENILE")) & icd10=="" //1 changes

count if regexm(coddeath,"PROSTATE") & icd10=="" //291
replace icd10="C61" if regexm(coddeath,"PROSTATE") & icd10=="" //291 changes
replace icd10="C859" if record_id==31683 & did=="T2" //NHL, NOS
replace icd10="C64" if record_id==31925 //urinary organ, NOS
replace icd10="C900" if record_id==33332 & did=="T2" //MM MP

count if (regexm(coddeath,"TESTIS")|regexm(coddeath,"TESTES")) & icd10=="" //0

count if (regexm(coddeath,"SCROT")|regexm(coddeath,"MALE")) & icd10=="" //0

count if (regexm(coddeath,"KIDNEY")|regexm(coddeath,"RENAL")) & icd10=="" //43
replace icd10="C64" if (regexm(coddeath,"KIDNEY")|regexm(coddeath,"RENAL")) & icd10=="" //43 changes
replace icd10="C74" if record_id==27104 //adrenal gland
replace icd10="C73" if record_id==27947 & did=="T2" //thyroid
replace icd10="C859" if record_id==28069 //NHL, NOS
replace icd10="C800" if record_id==26929|record_id==31523|record_id==31924|record_id==32947 //PSU
replace icd10="C809" if record_id==28565|record_id==31764|record_id==32209|record_id==33534 //PSU, NOS
replace icd10="C61" if record_id==32423 //prostate
replace icd10="C900" if record_id==27262|record_id==28127|record_id==28550|record_id==28911|record_id==29765|record_id==32240|record_id==32729|record_id==33256 //MM
replace icd10="C931" if record_id==32810 //CML
replace icd10="C910" if record_id==32207 //B-cell ALL
replace icd10="C859" if record_id==28968 //lymphoma NOS
replace icd10="C950" if record_id==32535 //acute leukaemia

count if (regexm(coddeath,"BLADDER")|regexm(coddeath,"URIN")) & icd10=="" //21
replace icd10="C679" if (regexm(coddeath,"BLADDER")|regexm(coddeath,"URIN")) & icd10=="" //21 changes
replace icd10="C709" if record_id==33009 //meninges
replace icd10="C809" if record_id==32449 //PSU, NOS

count if (regexm(coddeath,"EYE")|regexm(coddeath,"RETINA")|regexm(coddeath,"NEURO")) & icd10=="" //3
//replace icd10="C699" if (regexm(coddeath,"EYE")|regexm(coddeath,"RETINA")|regexm(coddeath,"NEURO")) & icd10=="" //1 changes
replace icd10="C809" if record_id==32540 //PSU, NOS
replace icd10="C080" if record_id==32681 //submandibular
replace icd10="C719" if record_id==34074 //brain, NOS

count if (regexm(coddeath,"ASTROCY")|regexm(coddeath,"MULTIFORME")|regexm(coddeath,"BRAIN")) & icd10=="" //3
replace icd10="C719" if (regexm(coddeath,"ASTROCY")|regexm(coddeath,"MULTIFORME")|regexm(coddeath,"BRAIN")) & icd10=="" //3 changes
replace icd10="C711" if record_id==28346 //brain, frontal lobe

count if (regexm(coddeath,"THYROID")|regexm(coddeath,"ADRENAL")|regexm(coddeath,"ENDOCRI")) & icd10=="" //4
replace icd10="C73" if (regexm(coddeath,"THYROID")|regexm(coddeath,"ADRENAL")|regexm(coddeath,"ENDOCRI")) & icd10=="" //4 changes
replace icd10="C809" if record_id==33475 //PSU, NOS

count if (regexm(coddeath,"UNKNOWN")|regexm(coddeath,"CULT")) & icd10=="" //31
replace icd10="C800" if (regexm(coddeath,"UNKNOWN")|regexm(coddeath,"CULT")) & icd10=="" //31 changes
replace icd10="C859" if record_id==28830 //lymphoma NOS

count if (regexm(coddeath,"HODGKIN") & regexm(coddeath,"NON")) & icd10=="" //15
replace icd10="C859" if (regexm(coddeath,"HODGKIN") & regexm(coddeath,"NON")) & icd10=="" //15 changes

count if regexm(coddeath,"HODGKIN") & icd10=="" //3
replace icd10="C819" if regexm(coddeath,"HODGKIN") & icd10=="" //3 changes
replace icd10="C812" if record_id==27247 //mixed cellularity HL

count if (regexm(coddeath,"FOLLICUL") & regexm(coddeath,"LYMPH")) & icd10=="" //1
replace icd10="C829" if record_id==33900 //follicular lymphoma, NOS

count if (regexm(coddeath,"MULTIPLE") & regexm(coddeath,"OMA")) & icd10=="" //41
replace icd10="C900" if (regexm(coddeath,"MULTIPLE") & regexm(coddeath,"OMA")) & icd10=="" //41 changes

count if regexm(coddeath,"PLASMACYTOMA") & icd10=="" //0
//replace icd10="C903" if regexm(coddeath,"PLASMACYTOMA") & icd10=="" //1 change

count if regexm(coddeath,"SEZARY") & icd10=="" //0
//replace icd10="C841" if regexm(coddeath,"SEZARY") & icd10=="" //1 change

count if (regexm(coddeath,"LYMPH")|regexm(coddeath,"EMIA")|regexm(coddeath,"PHOMA")) & icd10=="" //46
replace icd10="C950" if record_id==30074 //acute leukaemia
replace icd10="C959" if record_id==27729 //leukaemia, NOS
replace icd10="C920" if record_id==27151|record_id==28031|record_id==28282|record_id==28384 ///
						|record_id==28386|record_id==28653|record_id==31859|record_id==31893 ///
						|record_id==32062|record_id==33124|record_id==34028|record_id==32593 //AML
replace icd10="C910" if record_id==27284|record_id==33033 //ALL, NOS
replace icd10="C849" if record_id==27405 //adult T-cell lymphoma
replace icd10="C833" if record_id==29922 //diffuse large b-cell lymphoma
replace icd10="C911" if record_id==29332|record_id==29906|record_id==31532|record_id==33852 //CLL
replace icd10="C915" if record_id==27136 //ALL, T-cell
replace icd10="C809" if record_id==29763|record_id==33792 //PSU, NOS
replace icd10="C859" if record_id==27531|record_id==28660|record_id==28865|record_id==31524 ///
						|record_id==33144|record_id==34025 //lymphoma NOS
replace icd10="C61" if record_id==32504|record_id==33771 //prostate
//replace icd10="C880" if record_id== //lymphoplasmacytic lymphoma
//replace icd10="D464" if record_id== & did=="T1" //refractory anaemia, NOS
replace icd10="C849" if record_id==33782 //t-cell lymphoma, NOS
replace icd10="C269" if record_id==33178 //gastronintestinal, NOS
replace icd10="C419" if record_id==27955 //bone, NOS
replace icd10="C921" if record_id==27745|record_id==27864|record_id==27915|record_id==28716 ///
						|record_id==33125|record_id==33268 //CML
replace icd10="C900" if record_id==28900 //MM
replace icd10="C349" if record_id==32724 //lung, NOS
replace icd10="D469" if record_id==32364 //MDS
replace icd10="C109" if record_id==33793 //oropharynx

count if icd10=="" //78
replace icd10="C61" if record_id==28203|record_id==28287|record_id==28453 ///
					  |record_id==29507|record_id==29566|record_id==32253 //prostate
//replace icd10="C052" if record_id== //uvula
replace icd10="C763" if record_id==31822 //pelvis, NOS
replace icd10="C402" if record_id==32865 //Ewing sarcoma, lower limb long bone (thigh)
//replace icd10="C492" if record_id==|record_id== //sarcoma, lower limb bone
replace icd10="C493" if record_id==29527|record_id==33049 //sarcoma, chest wall
replace icd10="C762" if record_id==26909|record_id==27457 //abdomen, NOS
replace icd10="C55" if record_id==33975 //uterus, NOS
//replace icd10="C56" if record_id== //ovary
replace icd10="C541" if record_id==28883 //endometrium
//replace icd10="C447" if record_id== //carcinoma skin, lower limb
replace icd10="C809" if record_id==27373|record_id==27527|record_id==27804|record_id==27835 ///
						|record_id==27874|record_id==27999|record_id==28032|record_id==28074 ///
						|record_id==28225|record_id==28243|record_id==28257|record_id==28390 ///
						|record_id==28562|record_id==28701|record_id==28760|record_id==28780 ///
						|record_id==28816|record_id==29054|record_id==29345|record_id==31501 ///
						|record_id==31562|record_id==31627|record_id==31649|record_id==32188 ///
						|record_id==32315|record_id==32834|record_id==33629|record_id==33844 //PSU, NOS
replace icd10="C109" if record_id==32788 //oropharynx
//replace icd10="C139" if record_id==|record_id== //hypopharynx
replace icd10="C119" if record_id==28500|record_id==31590 //nasopharynx
replace icd10="C169" if record_id==28176|record_id==28974|record_id==32514 //stomach
//replace icd10="C248" if record_id==|record_id== //biliary tract, (not C22.0-C24.1)
replace icd10="C180" if record_id==34029 //colon, caecum
replace icd10="C187" if record_id==33180 //colon, sigmoid
//replace icd10="C445" if record_id== //carcinoma skin, chest wall
replace icd10="C449" if record_id==27485 //merkel
//replace icd10="C549" if record_id== //corpus uteri, NOS/mixed mullerian tumour
//replace icd10="C492" if record_id==|record_id== //sarcoma, upper limb
//replace icd10="C310" if record_id== //maxillary sinus
replace icd10="C410" if record_id==27167|record_id==28506 //bone, maxilla
//replace icd10="C700" if record_id== //intracranial meningioma, malignant
replace icd10="D473" if record_id==28850 //essential thrombocytosis
replace icd10="C969" if record_id==32983 //haem. malignancy
//replace icd10="C579" if record_id== //genitourinary tract (F)
//replace icd10="C720" if record_id== //spinal cord
//replace icd10="C840" if record_id== //mycosis fungoides
replace icd10="D469" if record_id==28227|record_id==31686|record_id==33986|record_id==33998 //MDS
replace icd10="C946" if record_id==27338|record_id==27514 //myelodysplastic/myeloproliferative
replace icd10="C051" if record_id==27986 //soft palate
//replace icd10="C479" if record_id== //peripheral nerve
//replace icd10="C490" if record_id== //ear
replace icd10="C719" if record_id==28731|record_id==29650|record_id==32579|record_id==32987 //brain, NOS
replace icd10="C229" if record_id==28048|record_id==29625|record_id==32158 //liver, NOS
replace icd10="C509" if record_id==27854 //breast, NOS
replace icd10="C900" if record_id==27539|record_id==28113|record_id==32226|record_id==33524 //MM
replace icd10="C269" if record_id==28253|record_id==31498 //gastronintestinal, NOS
replace icd10="C411" if record_id==29881 //mandible
//replace icd10="C349" if record_id==33372 //lung
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
replace siteiarc=2 if (regexm(icd10,"C01")|regexm(icd10,"C02")) //5 changes
replace siteiarc=3 if (regexm(icd10,"C03")|regexm(icd10,"C04")|regexm(icd10,"C05")|regexm(icd10,"C06")) //1 change
replace siteiarc=4 if (regexm(icd10,"C07")|regexm(icd10,"C08")) //1 change
replace siteiarc=5 if regexm(icd10,"C09") //0 changes
replace siteiarc=6 if regexm(icd10,"C10") //6 changes
replace siteiarc=7 if regexm(icd10,"C11") //3 changes
replace siteiarc=8 if (regexm(icd10,"C12")|regexm(icd10,"C13")) //0 changes
replace siteiarc=9 if regexm(icd10,"C14") //0 changes
replace siteiarc=10 if regexm(icd10,"C15") //17 changes
replace siteiarc=11 if regexm(icd10,"C16") //43 changes
replace siteiarc=12 if regexm(icd10,"C17") //6 changes
replace siteiarc=13 if regexm(icd10,"C18") //155 changes
replace siteiarc=14 if (regexm(icd10,"C19")|regexm(icd10,"C20")) //31 changes
replace siteiarc=15 if regexm(icd10,"C21") //3 changes
replace siteiarc=16 if regexm(icd10,"C22") //14 changes
replace siteiarc=17 if (regexm(icd10,"C23")|regexm(icd10,"C24")) //18 changes
replace siteiarc=18 if regexm(icd10,"C25") //54 changes
replace siteiarc=19 if (regexm(icd10,"C30")|regexm(icd10,"C31")) //0 changes
replace siteiarc=20 if regexm(icd10,"C32") //6 changes
replace siteiarc=21 if (regexm(icd10,"C33")|regexm(icd10,"C34")) //70 changes
replace siteiarc=22 if (regexm(icd10,"C37")|regexm(icd10,"C38")) //2 changes
replace siteiarc=23 if (regexm(icd10,"C40")|regexm(icd10,"C41")) //7 changes
replace siteiarc=24 if regexm(icd10,"C43") //6 changes
replace siteiarc=25 if regexm(icd10,"C44") //9 changes
replace siteiarc=26 if regexm(icd10,"C45") //1 change
replace siteiarc=27 if regexm(icd10,"C46") //0 changes
replace siteiarc=28 if (regexm(icd10,"C47")|regexm(icd10,"C49")) //2 changes
replace siteiarc=29 if regexm(icd10,"C50") //170 changes
replace siteiarc=30 if regexm(icd10,"C51") //0 changes
replace siteiarc=31 if regexm(icd10,"C52") //3 changes
replace siteiarc=32 if regexm(icd10,"C53") //20 changes
replace siteiarc=33 if regexm(icd10,"C54") //55 changes
replace siteiarc=34 if regexm(icd10,"C55") //19 changes
replace siteiarc=35 if regexm(icd10,"C56") //21 change
replace siteiarc=36 if regexm(icd10,"C57") //0 changes
replace siteiarc=37 if regexm(icd10,"C58") //0 changes
replace siteiarc=38 if regexm(icd10,"C60") //2 changes
replace siteiarc=39 if regexm(icd10,"C61") //317 changes
replace siteiarc=40 if regexm(icd10,"C62") //0 changes
replace siteiarc=41 if regexm(icd10,"C63") //0 changes
replace siteiarc=42 if regexm(icd10,"C64") //21 changes
replace siteiarc=43 if regexm(icd10,"C65") //0 changes
replace siteiarc=44 if regexm(icd10,"C66") //1 change
replace siteiarc=45 if regexm(icd10,"C67") //24 changes
replace siteiarc=46 if regexm(icd10,"C68") //1 change
replace siteiarc=47 if regexm(icd10,"C69") //0 changes
replace siteiarc=48 if (regexm(icd10,"C70")|regexm(icd10,"C71")|regexm(icd10,"C72")) //11 changes
replace siteiarc=49 if regexm(icd10,"C73") //4 changes
replace siteiarc=50 if regexm(icd10,"C74") //1 change
replace siteiarc=51 if regexm(icd10,"C75") //0 changes
replace siteiarc=52 if regexm(icd10,"C81") //3 changes
replace siteiarc=53 if (regexm(icd10,"C82")|regexm(icd10,"C83")|regexm(icd10,"C84")|regexm(icd10,"C85")|regexm(icd10,"C86")|regexm(icd10,"C96")) //34 changes
replace siteiarc=54 if regexm(icd10,"C88") //0 changes
replace siteiarc=55 if regexm(icd10,"C90") //57 changes
replace siteiarc=56 if regexm(icd10,"C91") //8 changes
replace siteiarc=57 if (regexm(icd10,"C92")|regexm(icd10,"C93")|regexm(icd10,"C94")) //20 changes
replace siteiarc=58 if regexm(icd10,"C95") //4 changes
replace siteiarc=59 if regexm(icd10,"D47") //1 change
replace siteiarc=60 if regexm(icd10,"D46") //5 changes
replace siteiarc=61 if (regexm(icd10,"C26")|regexm(icd10,"C39")|regexm(icd10,"C48")|regexm(icd10,"C76")|regexm(icd10,"C80")) //95 changes
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
replace siteiarchaem=1 if icd10=="C859"|icd10=="C851"|icd10=="C826"|icd10=="C969" //30 changes
replace siteiarchaem=2 if icd10=="C819"|icd10=="C814"|icd10=="C813"|icd10=="C812"|icd10=="C811"|icd10=="C810" //3 changes
replace siteiarchaem=3 if icd10=="C830"|icd10=="C831"|icd10=="C833"|icd10=="C837"|icd10=="C838"|icd10=="C857"|icd10=="C859"|icd10=="C852"|icd10=="C829"|icd10=="C821"|icd10=="C820"|icd10=="C822"|icd10=="C420"|icd10=="C421"|icd10=="C424"|icd10=="C884"|regexm(icd10,"C77") //31 changes
replace siteiarchaem=4 if icd10=="C840"|icd10=="C841"|icd10=="C844"|icd10=="C865"|icd10=="C863"|icd10=="C848"|icd10=="C838"|icd10=="C846"|icd10=="C861"|icd10=="C862"|icd10=="C866"|icd10=="C860"|icd10=="C849" //2 changes
replace siteiarchaem=5 if icd10=="C845"|icd10=="C835" //0 changes
replace siteiarchaem=6 if icd10=="C903"|icd10=="C900"|icd10=="C901"|icd10=="C902"|icd10=="C833" //58 changes
replace siteiarchaem=7 if icd10=="D470"|icd10=="C962"|icd10=="C943" //0 changes
replace siteiarchaem=8 if icd10=="C968"|icd10=="C966"|icd10=="C964" //0 changes
replace siteiarchaem=9 if icd10=="C889"|icd10=="C880"|icd10=="C882"|icd10=="C883"|icd10=="D472"|icd10=="C838"|icd10=="C865"|icd10=="D479"|icd10=="D477" //0 changes
replace siteiarchaem=10 if icd10=="C959"|icd10=="C950" //4 changes
replace siteiarchaem=11 if icd10=="C910"|icd10=="C919"|icd10=="C911"|icd10=="C918"|icd10=="C915"|icd10=="C917"|icd10=="C913"|icd10=="C916" //8 changes
replace siteiarchaem=12 if icd10=="C940"|icd10=="C929"|icd10=="C920"|icd10=="C921"|icd10=="C924"|icd10=="C925"|icd10=="C947"|icd10=="C922"|icd10=="C930"|icd10=="C928"|icd10=="C926"|icd10=="D471"|icd10=="C927"|icd10=="C942"|icd10=="C946"|icd10=="C923"|icd10=="C944"|icd10=="C914"|icd10=="C912" //19 changes
replace siteiarchaem=13 if icd10=="C931"|icd10=="C933"|icd10=="C947" //1 change
replace siteiarchaem=14 if icd10=="D45"|icd10=="D471"|icd10=="D474"|icd10=="D473"|icd10=="D475"|icd10=="C927"|icd10=="C967" //1 change
replace siteiarchaem=15 if icd10=="D477"|icd10=="D471" //0 changes
replace siteiarchaem=16 if icd10=="D465"|icd10=="D466"|icd10=="D467"|icd10=="D469" //5 changes

tab siteiarchaem ,m //1225 missing - correct!
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
					 |regexm(icd10,"C12")|regexm(icd10,"C13")|regexm(icd10,"C14")) //16 changes
replace sitecr5db=2 if regexm(icd10,"C15") //17 changes
replace sitecr5db=3 if regexm(icd10,"C16") //43 changes
replace sitecr5db=4 if (regexm(icd10,"C18")|regexm(icd10,"C19")|regexm(icd10,"C20")|regexm(icd10,"C21")) //189 changes
replace sitecr5db=5 if regexm(icd10,"C22") //14 changes
replace sitecr5db=6 if regexm(icd10,"C25") //54 changes
replace sitecr5db=7 if regexm(icd10,"C32") //6 changes
replace sitecr5db=8 if (regexm(icd10,"C33")|regexm(icd10,"C34")) //70 changes
replace sitecr5db=9 if regexm(icd10,"C43") //6 changes
replace sitecr5db=10 if regexm(icd10,"C50") //170 changes
replace sitecr5db=11 if regexm(icd10,"C53") //20 changes
replace sitecr5db=12 if (regexm(icd10,"C54")|regexm(icd10,"C55")) //74 changes
replace sitecr5db=13 if regexm(icd10,"C56") //21 changes
replace sitecr5db=14 if regexm(icd10,"C61") //317 changes
replace sitecr5db=15 if regexm(icd10,"C62") //0 changes
replace sitecr5db=16 if (regexm(icd10,"C64")|regexm(icd10,"C65")|regexm(icd10,"C66")|regexm(icd10,"C68")) //23 changes
replace sitecr5db=17 if regexm(icd10,"C67") //24 changes
replace sitecr5db=18 if (regexm(icd10,"C70")|regexm(icd10,"C71")|regexm(icd10,"C72")) //11 changes
replace sitecr5db=19 if regexm(icd10,"C73") //4 changes
replace sitecr5db=20 if siteiarc==61 //95 changes
replace sitecr5db=21 if (regexm(icd10,"C81")|regexm(icd10,"C82")|regexm(icd10,"C83")|regexm(icd10,"C84")|regexm(icd10,"C85")|regexm(icd10,"C88")|regexm(icd10,"C90")|regexm(icd10,"C96")) //94 changes
replace sitecr5db=22 if (regexm(icd10,"C91")|regexm(icd10,"C92")|regexm(icd10,"C93")|regexm(icd10,"C94")|regexm(icd10,"C95")) //32 changes
replace sitecr5db=23 if (regexm(icd10,"C17")|regexm(icd10,"C23")|regexm(icd10,"C24")) //24 changes
replace sitecr5db=24 if (regexm(icd10,"C30")|regexm(icd10,"C31")) //0 changes
replace sitecr5db=25 if (regexm(icd10,"C40")|regexm(icd10,"C41")|regexm(icd10,"C45")|regexm(icd10,"C47")|regexm(icd10,"C49")) //10 changes
replace sitecr5db=26 if siteiarc==25 //9 changes
replace sitecr5db=27 if (regexm(icd10,"C51")|regexm(icd10,"C52")|regexm(icd10,"C57")|regexm(icd10,"C58")) //3 changes
replace sitecr5db=28 if (regexm(icd10,"C60")|regexm(icd10,"C63")) //2 changes
replace sitecr5db=29 if (regexm(icd10,"C74")|regexm(icd10,"C75")) //1 change
replace sitecr5db=30 if siteiarc==59 //1 change
replace sitecr5db=31 if siteiarc==60 //5 changes
replace sitecr5db=32 if siteiarc==64 //0 changes
replace sitecr5db=34 if icd10=="C37"|icd10=="C380"|icd10=="C383"|icd10=="C468"|icd10=="C699"|icd10=="C865"|icd10=="C866" //2 changes

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
					 |regexm(icd10,"C12")|regexm(icd10,"C13")|regexm(icd10,"C14")) //16 changes
replace siteicd10=2 if (regexm(icd10,"C15")|regexm(icd10,"C16")|regexm(icd10,"C17") ///
					 |regexm(icd10,"C18")|regexm(icd10,"C19")|regexm(icd10,"C20") ///
					 |regexm(icd10,"C21")|regexm(icd10,"C22")|regexm(icd10,"C23") ///
					 |regexm(icd10,"C24")|regexm(icd10,"C25")|regexm(icd10,"C26")) //347 changes
replace siteicd10=3 if (regexm(icd10,"C30")|regexm(icd10,"C31")|regexm(icd10,"C32")|regexm(icd10,"C33")|regexm(icd10,"C34")|regexm(icd10,"C37")|regexm(icd10,"C38")|regexm(icd10,"C39")) //78 changes
replace siteicd10=4 if (regexm(icd10,"C40")|regexm(icd10,"C41")) //7 changes
replace siteicd10=5 if siteiarc==24 //6 changes
replace siteicd10=6 if siteiarc==25 //9 changes
replace siteicd10=7 if (regexm(icd10,"C45")|regexm(icd10,"C46")|regexm(icd10,"C47")|regexm(icd10,"C48")|regexm(icd10,"C49")) //3 changes
replace siteicd10=8 if regexm(icd10,"C50") //170 changes
replace siteicd10=9 if (regexm(icd10,"C51")|regexm(icd10,"C52")|regexm(icd10,"C53")|regexm(icd10,"C54")|regexm(icd10,"C55")|regexm(icd10,"C56")|regexm(icd10,"C57")|regexm(icd10,"C58")) //118 changes
replace siteicd10=10 if regexm(icd10,"C61") //317 changes
replace siteicd10=11 if (regexm(icd10,"C60")|regexm(icd10,"C62")|regexm(icd10,"C63")) //2 changes
replace siteicd10=12 if (regexm(icd10,"C64")|regexm(icd10,"C65")|regexm(icd10,"C66")|regexm(icd10,"C67")|regexm(icd10,"C68")) //47 changes
replace siteicd10=13 if (regexm(icd10,"C69")|regexm(icd10,"C70")|regexm(icd10,"C71")|regexm(icd10,"C72")) //11 changes
replace siteicd10=14 if (regexm(icd10,"C73")|regexm(icd10,"C74")|regexm(icd10,"C75")) //5 changes
replace siteicd10=15 if (regexm(icd10,"C76")|regexm(icd10,"C77")|regexm(icd10,"C78")|regexm(icd10,"C79")) //4 changes
replace siteicd10=16 if regexm(icd10,"C80") //85 changes
replace siteicd10=17 if (regexm(icd10,"C81")|regexm(icd10,"C82")|regexm(icd10,"C83") ///
					 |regexm(icd10,"C84")|regexm(icd10,"C85")|regexm(icd10,"C86") ///
					 |regexm(icd10,"C87")|regexm(icd10,"C88")|regexm(icd10,"C89") ///
					 |regexm(icd10,"C90")|regexm(icd10,"C91")|regexm(icd10,"C92") ///
					 |regexm(icd10,"C93")|regexm(icd10,"C94")|regexm(icd10,"C95") ///
					 |regexm(icd10,"C96")|regexm(icd10,"D46")|regexm(icd10,"D47")) //132 changes


tab siteicd10 ,m //0 missing

drop dupobs* dup_id

order record_id did fname lname age age5 age_10 sex dob nrn parish dod dodyear cancer siteiarc siteiarchaem pod coddeath

label data "BNR MORTALITY data 2019 + 2020: Identifiable Dataset"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version09\3-output\2019+2020_prep mort_identifiable" ,replace
note: TS This dataset is used for analysis of age-standardized mortality rates
note: TS This dataset includes patients with multiple eligible cancer causes of death

preserve
** Create corrected dataset with reportable cases but de-identified data
drop fname lname natregno nrn pname mname dob parish regnum address pod placeofdeath certifier certifieraddr
** Save this death dataset with de-identified data
label data "BNR MORTALITY data 2019 + 2020: De-identified Dataset"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version09\3-output\2019+2020_prep mort_deidentified" ,replace
note: TS This dataset is used for analysis of age-standardized mortality rates
note: TS This dataset includes patients with multiple eligible cancer causes of death
restore

** Save separate datasets for 2019 and 2020
preserve
drop if dodyear!=2019
label data "BNR MORTALITY data 2019: Identifiable Dataset"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version09\3-output\2019_prep mort_identifiable" ,replace
note: TS This dataset is used for analysis of age-standardized mortality rates
note: TS This dataset includes patients with multiple eligible cancer causes of death
** Create corrected dataset with reportable cases but de-identified data
drop fname lname natregno nrn pname mname dob parish regnum address pod placeofdeath certifier certifieraddr
** Save this death dataset with de-identified data
label data "BNR MORTALITY data 2019: De-identified Dataset"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version09\3-output\2019_prep mort_deidentified" ,replace
note: TS This dataset is used for analysis of age-standardized mortality rates
note: TS This dataset includes patients with multiple eligible cancer causes of death
restore

preserve
drop if dodyear!=2020
label data "BNR MORTALITY data 2020: Identifiable Dataset"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version09\3-output\2020_prep mort_identifiable" ,replace
note: TS This dataset is used for analysis of age-standardized mortality rates
note: TS This dataset includes patients with multiple eligible cancer causes of death
** Create corrected dataset with reportable cases but de-identified data
drop fname lname natregno nrn pname mname dob parish regnum address pod placeofdeath certifier certifieraddr
** Save this death dataset with de-identified data
label data "BNR MORTALITY data 2020: De-identified Dataset"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version09\3-output\2020_prep mort_deidentified" ,replace
note: TS This dataset is used for analysis of age-standardized mortality rates
note: TS This dataset includes patients with multiple eligible cancer causes of death
restore

preserve
** Create de-identified dataset that includes pod and placeofdeath for BNR CME 2022 webinar (p131/v16)
drop fname lname natregno nrn pname mname dob parish regnum address certifier certifieraddr
drop if did=="T2" //29 deleted
drop if dodyear!=2020 //675 deleted
** Save this death dataset with de-identified data
label data "BNR MORTALITY data 2020: De-identified Dataset for BNR 2022 CME"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "X:/The University of the West Indies/DataGroup - repo_data/data_p131\version16\1-input\2020_prep mort_cancer_deidentified" ,replace
note: TS This dataset is used for analysis for the BNR CME 2022 webinar
note: TS This dataset DOES NOT include patients with multiple eligible cancer causes of death
restore

** JC 26sep2022: SF requested proportion of cancer deaths of all deaths (comments on ann. rpt from Natalie Greaves)
preserve
egen mortcan_2019=count(record_id) if dodyear==2019
egen mortcan_2020=count(record_id) if dodyear==2020
contract mortcan_*
drop _freq

append using "`datapath'\version09\2-working\mort_proportions"
fillmissing mortcan_2016 mortcan_2017 mortcan_2018 mortcan_2019 mortcan_2020 morttot_2016 morttot_2017 morttot_2018 morttot_2019 morttot_2020
save "`datapath'\version09\2-working\mort_proportions" ,replace
restore