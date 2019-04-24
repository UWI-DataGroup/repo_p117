** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			6_mort_2008_2013_dc.do
    //  project:				BNR
    //  analysts:				Jacqueline CAMPBELL
    //  date first created      23-APR-2019
    // 	date last modified	    23-APR-2019
    //  algorithm task			Cleaning 2008,2013 cancer dataset, Creating site groupings
    //  status                  Completed
    //  objectve                To have one dataset with cleaned and grouped 2008 & 2013 data for 2014 cancer report.


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
    log using "`logpath'\6_mort_2008_2013_dc.smcl", replace
** HEADER -----------------------------------------------------


**************************************
** DATA PREPARATION  
**************************************
** LOAD the national registry deaths 2008-2017 dataset (from REDCap so deathid matches record_id in REDCap project)
use "`datapath'\version01\2-working\2008-2017_redcap_deaths_dp" ,clear

count //24,188


** Format and drop necessary variables
gen dodyear=year(dod)
label var dodyear "Year of death"

drop dddoa ddda odda

** Remove irrelevant CODs e.g "unnatural" causes of death (cod1a starts with a lone "E")
drop if regexm(cod1a, "^E") //736 obs deleted


tab dodyear ,m //none missing, 2,400 in 2008 and 2,321 in 2013
count if dod==. //0

count //23,452 - drop all not in 2008 & 2013
drop if (dod<d(01jan2008) | dod>d(31dec2008)) & (dod<d(01jan2013) | dod>d(31dec2013)) //18,731 obs deleted
count //4,721

** Strip possible leading/trailing blanks in cod1a 
** Create another cause field so that lists can be done alphabetically when checking below field 'mrcancer'
replace cod1a = rtrim(ltrim(itrim(cod1a))) //0 changes
count if regexm(cod1a,"^N ") //4,721
gen tempcod1a=1 if regexm(cod1a,"^N ") 
//list deathid if tempcod1a==. //deathid 15786 is unnatural so remove
drop if deathid==15786 //0 obs deleted - 2014 death

count //4,721

gen cod1a_orig=cod1a
drop cod1a
gen cod1a=substr(cod1a_orig, 2, .) if regexm(cod1a,"^N ") //0 changes so none missing
//list deathid cod1a if cod1a==""
//list cod1a_orig if cod1a==""
replace cod1a=cod1a_orig if cod1a=="" //0 changes

** Now generate a new variable which will select out all the potential cancers
gen mrcancer=.
label define mrcancer_lab 1 "cancer" 2 "not cancer", modify
label values mrcancer mrcancer_lab
label var mrcancer "cancer patients"
label var deathid "Event identifier for registry deaths"

** searching cod1a for these terms
replace mrcancer=1 if regexm(cod1a, "CANCER") //362 changes
replace mrcancer=1 if regexm(cod1a, "TUMOUR") &  mrcancer==. //36 changes
replace mrcancer=1 if regexm(cod1a, "TUMOR") &  mrcancer==. //15 changes
replace mrcancer=1 if regexm(cod1a, "MALIGNANT") &  mrcancer==. //11 changes
replace mrcancer=1 if regexm(cod1a, "MALIGNANCY") &  mrcancer==. //43 changes
replace mrcancer=1 if regexm(cod1a, "NEOPLASM") &  mrcancer==. //4 changes
replace mrcancer=1 if regexm(cod1a, "CARCINOMA") &  mrcancer==. //473 changes
replace mrcancer=1 if regexm(cod1a, "CARCIMONA") &  mrcancer==. //1 change
replace mrcancer=1 if regexm(cod1a, "CARINOMA") &  mrcancer==. //1 change
replace mrcancer=1 if regexm(cod1a, "MYELOMA") &  mrcancer==. //32 changes
replace mrcancer=1 if regexm(cod1a, "MELOMA") &  mrcancer==. //0 changes
replace mrcancer=1 if regexm(cod1a, "LYMPHOMA") &  mrcancer==. //24 changes
replace mrcancer=1 if regexm(cod1a, "LYMPHOMIA") &  mrcancer==. //1 change
replace mrcancer=1 if regexm(cod1a, "LYMPHONA") &  mrcancer==. //1 change
replace mrcancer=1 if regexm(cod1a, "LYNPHOMA") &  mrcancer==. //0 changes
replace mrcancer=1 if regexm(cod1a, "SARCOMA") &  mrcancer==. //11 changes
replace mrcancer=1 if regexm(cod1a, "TERATOMA") &  mrcancer==. //1 change
replace mrcancer=1 if regexm(cod1a, "LEUKEMIA") &  mrcancer==. //14 changes
replace mrcancer=1 if regexm(cod1a, "LEUKAEMIA") &  mrcancer==. //21 changes
replace mrcancer=1 if regexm(cod1a, "LUKAEMIA") &  mrcancer==. //0 changes
replace mrcancer=1 if regexm(cod1a, "HEPATOMA") &  mrcancer==. //1 change
replace mrcancer=1 if regexm(cod1a, "CARANOMA PROSTATE") &  mrcancer==. //1 change
replace mrcancer=1 if regexm(cod1a, "MENINGIOMA") &  mrcancer==. //2 changes
replace mrcancer=1 if regexm(cod1a, "MYELOSIS") &  mrcancer==. //0 changes
replace mrcancer=1 if regexm(cod1a, "MYELOFIBROSIS") &  mrcancer==. //3 changes
replace mrcancer=1 if regexm(cod1a, "CYTHEMIA") &  mrcancer==. //0 changes
replace mrcancer=1 if regexm(cod1a, "CYTOSIS") &  mrcancer==. //1 change
replace mrcancer=1 if regexm(cod1a, "BLASTOMA") &  mrcancer==. //3 changes
replace mrcancer=1 if regexm(cod1a, "METASTATIC") &  mrcancer==. //9 changes
replace mrcancer=1 if regexm(cod1a, "MASS") &  mrcancer==. //40 changes
replace mrcancer=1 if regexm(cod1a, "METASTASES") &  mrcancer==. //4 changes
replace mrcancer=1 if regexm(cod1a, "METASTASIS") &  mrcancer==. //0 changes
replace mrcancer=1 if regexm(cod1a, "REFRACTORY") &  mrcancer==. //0 changes
replace mrcancer=1 if regexm(cod1a, "FUNGOIDES") &  mrcancer==. //0 changes
replace mrcancer=1 if regexm(cod1a, "HODGKIN") &  mrcancer==. //1 change
replace mrcancer=1 if regexm(cod1a, "MELANOMA") &  mrcancer==. //0 changes
replace mrcancer=1 if regexm(cod1a,"MYELODYS") &  mrcancer==. //0 changes
replace mrcancer=1 if regexm(cod1a,"ASTROCY") &  mrcancer==. //0 changes
replace mrcancer=1 if regexm(cod1a,"CA COLON") &  mrcancer==. //0 changes
replace mrcancer=1 if regexm(cod1a,"PAGET") &  mrcancer==. //2 changes
replace mrcancer=1 if regexm(cod1a,"PLASMACY") &  mrcancer==. //0 changes


tab mrcancer, m
** Check that all cancer CODs for 2008 & 2013 are eligible
sort cod1a deathid
order deathid cod1a
//list cod1a if mrcancer==1 //1,118

** Replace 2014 cases that are not cancer according to eligibility SOP:
/*
	(1) below list with deathid taken from dofile 4 so re-check then update
		mrcancer var as need be
	(2) use obsid to check for CODs that incomplete in Results window with 
		Data Editor in browse mode-copy and paste deathid below from here
*/
sort deathid
/*list cod1a if ///

*/
replace mrcancer=2 if ///
deathid==2379|deathid==14008|deathid==1552|deathid==14067|deathid==14062| ///
deathid==13589|deathid==13806|deathid==13742|deathid==977|deathid==154| ///
deathid==12865|deathid==13045|deathid==12112|deathid==13679|deathid==14089| ///
deathid==12652|deathid==14123|deathid==13756|deathid==11911|deathid==2070| ///
deathid==13821|deathid==12513|deathid==887|deathid==2113|deathid==13852| ///
deathid==2451|deathid==1298|deathid==785|deathid==141|deathid==896| ///
deathid==12273|deathid==2023|deathid==571|deathid==13701|deathid==13708| ///
deathid==12340|deathid==12600|deathid==13156|deathid==12837|deathid==12233| ///
deathid==12498|deathid==182|deathid==12927|deathid==13950|deathid==1639| ///
deathid==1802|deathid==165|deathid==831|deathid==12673|deathid==12880| ///
deathid==14259|deathid==13320|deathid==12830|deathid==1071|deathid==1794| ///
deathid==12551|deathid==12568|deathid==13263|deathid==13991|deathid==13296| ///
deathid==729|deathid==13225|deathid==13811|deathid==1908|deathid==1626
//65 changes
** MPs in CODs - to duplicate later in this dofile
/*
deathid
12474 - breast and endometrial
13920 - liver(2013) and prostate(5Y)
956 - cervix and bladder
1669 - breast(12Y) and lung(2008)
1675 - tonsil and soft palate
2358 - soft palate and vocal cord
13899 - lung and MPD
13018 - CML and prostate
14269 - gallbladder and pancreas
13476 - prostate and colon
14288 - lymphoma and prostate
13793 - uterus and breast
13633 - pancreas and MM
13395 - prostate and stomach
*/
** Check that all 2014 CODs that are not cancer for eligibility
count if mrcancer==. //3,603
count if mrcancer==. & (deathid>0 & deathid<5000) //1,894
count if mrcancer==. & (deathid>5000 & deathid<10000) //0
count if mrcancer==. & (deathid>10000 & deathid<15000) //1,709
count if mrcancer==. & (deathid>15000 & deathid<20000) //0
count if mrcancer==. & (deathid>20000 & deathid<25000) //0
count if mrcancer==. & (deathid>25000 & deathid<30000) //0

//list cod1a if mrcancer==. & (deathid>0 & deathid<5000)
//list cod1a if mrcancer==. & (deathid>5000 & deathid<10000)
//list cod1a if mrcancer==. & (deathid>10000 & deathid<15000)
//list cod1a if mrcancer==. & (deathid>15000 & deathid<20000)
//list cod1a if mrcancer==. & (deathid>20000 & deathid<25000)
//list cod1a if mrcancer==. & (deathid>25000 & deathid<30000)

** No updates needed from above list (misspelling in death data - CARCINOMO, CARCINONA)
replace mrcancer=1 if ///
deathid==91|deathid==857
//2 changes

tab mrcancer ,m
replace mrcancer=2 if mrcancer==. //3,601 changes

drop if mrcancer!=1 //3,666 obs deleted
count //1,055

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
replace pod=1 if regexm(placeofdeath, "QEH") & pod==. //630 changes
replace pod=3 if regexm(placeofdeath, "GERIATRIC") & pod==. //14 changes
replace pod=5 if regexm(placeofdeath, "CHILDRENS HOME") & pod==. //0 chagnes
replace pod=4 if regexm(placeofdeath, "HOME") & pod==. //15 changes
replace pod=4 if regexm(placeofdeath, "ELDERLY") & pod==. //0 changes
replace pod=4 if regexm(placeofdeath, "SERENITY MANOR") & pod==. //2 changes
replace pod=4 if regexm(placeofdeath, "ADULT CARE") & pod==. //0 changes
replace pod=4 if regexm(placeofdeath, "AGE ASSIST") & pod==. //0 changes
replace pod=4 if regexm(placeofdeath, "SENIOR") & pod==. //0 changes
replace pod=5 if regexm(placeofdeath, "PRISON") & pod==. //0 changes
replace pod=5 if regexm(placeofdeath, "POLYCLINIC") & pod==. //0 changes
replace pod=5 if regexm(placeofdeath, "MINISTRIES") & pod==. //0 changes
replace pod=6 if regexm(placeofdeath, "STRICT HOSP") & pod==. //6 changes
replace pod=6 if regexm(placeofdeath, "GORDON CUMM") & pod==. //0 changes
replace pod=7 if regexm(placeofdeath, "PSYCHIATRIC HOSP") & pod==. //2 changes
replace pod=8 if regexm(placeofdeath, "BAYVIEW") & pod==. //12 changes
replace pod=9 if regexm(placeofdeath, "SANDY CREST") & pod==. //0 changes
replace pod=10 if regexm(placeofdeath, "BRIDGETOWN PORT") & pod==. //0 changes
replace pod=11 if regexm(placeofdeath, "HOTEL") & pod==. //0 changes
replace pod=99 if (placeofdeath==""|placeofdeath=="99") & pod==. //53 changes

count if pod==. //321
//list deathid address placeofdeath if pod==.
replace pod=2 if pod==. //321 changes

drop placeofdeath
tab pod ,m

*****************
**  Formatting **
**    Names    **
*****************

** Need to check for duplicate death registrations
** First split full name into first, middle and last names
** Also - code to split full name into 2 variables fname and lname - else can't merge! 
split pname, parse(", "" ") gen(name)
order deathid pname name*

** First, sort cases that contain a value in name5
count if name3=="" & name4=="" & name5=="" //809
count if name5!="" //1 - look at these in Stata data editor
replace name3=name3+" "+name4+" "+name5 if name5!="" //1 change
replace name4="" if name5!="" //1 change
drop name5

** Second, check for cases with name1=ST.
** name1
count if regexm(name1,"^ST") //9
//list deathid name* if regexm(name1,"^ST")
replace name1="ST." if deathid==1680|deathid==12760
replace name1=name1+""+name2 if deathid==1680|deathid==12760|deathid==13749|deathid==14180 //4 changes
replace name2="" if deathid==1680|deathid==12760|deathid==13749|deathid==14180 //4 changes
** name2
count if regexm(name2,"^ST") //14
//list deathid name* if regexm(name2,"^ST")
replace name2="ST." if deathid==54|deathid==144
replace name2=name2+""+name3 if deathid==54|deathid==144|deathid==1097|deathid==12809|deathid==13479|deathid==13659 //6 changes
replace name3="" if deathid==54|deathid==144|deathid==1097|deathid==12809|deathid==13479|deathid==13659 //6 changes
** name3
count if regexm(name3,"^ST") //4 - no changes needed as correct
//list deathid name* if regexm(name3,"^ST")

** Third, sort cases that contain a value in name4
count if name4!="" //13 - look at these in Stata data editor
replace name2=name2+" "+name3 if deathid==987 //1 change
replace name3="" if deathid==987 //1 change
replace name3=name3+" "+name4 if deathid==856
replace name4="" if deathid==856
replace name3=name4 if name3=="" & name4!="" //5 changes
replace name4="" if name3==name4 //5 changes
replace name2=name2+name3 if deathid==2426
replace name3=name4 if deathid==2426
replace name4="" if deathid==2426

** Fourth, sort cases that do not contain a value in name3
count if name3=="" //811 - look at these in Stata data editor
count if name3=="" & name4!="" //0
replace name4=name2 if name3=="" //811 changes
replace name2="" if name4==name2 //811 changes

** Fifth, sort cases that contains a value in name3
count if name3!="" & name2=="" //4 - look at these in Stata data editor
replace name4=name3 if name3!="" & name2=="" //4 changes
replace name3="" if name3!="" & name2=="" //4 changes
count if name3!="" & name4!="" //6 - look at these in Stata data editor
replace name2=name2+" "+name3 if name3!="" & name4!="" //6 changes
replace name3="" if name3!="" & name4!="" //6 changes
count if name3!="" //234 - look at these in Stata data editor
replace name4=name3 if name3!="" //234 changes
replace name3="" if name4==name3 //234 changes
drop name3

** Fourth, check for cases with name 'baby' or 'b/o' in name1 variable
count if (regexm(name1,"BABY")|regexm(name1,"B/O")) //0

** Now rename, check and remove unnecessary variables
rename name1 fname
rename name2 mname
rename name4 lname
count if fname=="" //0
count if lname=="" //0

** Check for cases where lname is very short as maybe error with splitting
count if (lname!="" & lname!="99") & length(lname)<3 //0

** Convert names to lower case and strip possible leading/trailing blanks
replace fname = lower(rtrim(ltrim(itrim(fname)))) //1,055 changes
replace mname = lower(rtrim(ltrim(itrim(mname)))) //240 changes
replace lname = lower(rtrim(ltrim(itrim(lname)))) //1,055 changes

order deathid pname fname mname lname ddnamematch

sort deathid

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
label define ddnamematch_lab 1 "deaths only namematch,diff.pt" 2 "no namematch", modify
label values ddnamematch namematch_lab
sort lname fname deathid
quietly by lname fname : gen dupname = cond(_N==1,0,_n)
sort lname fname deathid
count if dupname>0 //6
/* 
Check below list for cases where namematch=no match but 
there is a pt with same name then:
 (1) check if same pt and remove duplicate pt;
 (2) check if same name but different pt and
	 update namematch variable to reflect this, i.e.
	 namematch=1
*/
//list deathid ddnamematch fname lname nrn dod ddsex ddage if dupname>0
replace ddnamematch=1 if dupname>0 //1 change - 5 others already ddnamematch=1

preserve
drop if nrn==""
sort nrn 
quietly by nrn : gen dupnrn = cond(_N==1,0,_n)
sort nrn deathid lname fname
count if dupnrn>0 //0
//list deathid ddnamematch fname lname nrn dod ddsex ddage if dupnrn>0
restore

** Final check for duplicates by name and dod 
sort lname fname dod
quietly by lname fname dod: gen dupdod = cond(_N==1,0,_n)
sort lname fname dod deathid
count if dupdod>0 //0
//list deathid namematch fname lname nrn dod sex age if dupdod>0
count if dupdod>0 & ddnamematch!=1 //0

** Visual check for duplicates by name
sort lname fname
//list deathid namematch nrn dod fname lname
** No duplicates found but need to correct lname for below deathid
**replace lname= subinstr(lname,"0","o",.) if deathid==10212 //1 change - 2012 death


*******************
** Check for MPs **
**   in CODs     **
*******************
//list deathid
//list cod1a

** From list above checking if cancer or not, below are the MPs found
/*
deathid
12474 - breast and endometrial
13920 - liver(2013) and prostate(5Y)
956 - cervix and bladder
1669 - breast(12Y) and lung(2008)
1675 - tonsil and soft palate
2358 - soft palate and vocal cord
13899 - lung and MPD
13018 - CML and prostate
14269 - gallbladder and pancreas
13476 - prostate and colon
14288 - lymphoma and prostate
13793 - uterus and breast
13633 - pancreas and MM
13395 - prostate and stomach
*/

count //1,055

** Create duplicate observations for MPs in CODs
expand=2 if deathid==12474, gen (dupobs1do6)
expand=2 if deathid==13920, gen (dupobs2do6)
expand=2 if deathid==956, gen (dupobs3do6)
expand=2 if deathid==1669, gen (dupobs4do6)
expand=2 if deathid==1675, gen (dupobs5do6)
expand=2 if deathid==2358, gen (dupobs6do6)
expand=2 if deathid==13899, gen (dupobs7do6)
expand=2 if deathid==13018, gen (dupobs8do6)
expand=2 if deathid==14269, gen (dupobs9do6)
expand=2 if deathid==13476, gen (dupobs10do6)
expand=2 if deathid==14288, gen (dupobs11do6)
expand=2 if deathid==13793, gen (dupobs12do6)
expand=2 if deathid==13633, gen (dupobs13do6)
expand=2 if deathid==13395, gen (dupobs14do6)

count //1,069

** Create variables to identify patients vs tumours
gen ptrectot=.
replace ptrectot=1 if dupobs1do6==0|dupobs2do6==0|dupobs3do6==0|dupobs4do6==0 ///
					 |dupobs5do6==0|dupobs6do6==0|dupobs7do6==0|dupobs8do6==0 ///
					 |dupobs9do6==0|dupobs10do6==0|dupobs11do6==0|dupobs12do6==0 ///
					 |dupobs13do6==0|dupobs14do6==0 //1,069
replace ptrectot=2 if dupobs1do6>0|dupobs2do6>0|dupobs3do6>0|dupobs4do6>0 ///
					 |dupobs5do6>0|dupobs6do6>0|dupobs7do6>0|dupobs8do6>0 ///
					 |dupobs9do6>0|dupobs10do6>0|dupobs11do6>0|dupobs12do6>0 ///
					 |dupobs13do6>0|dupobs14do6>0 //14
label define ptrectot_lab 1 "DCO with single event" 2 "DCO with multiple events" , modify
label values ptrectot ptrectot_lab

tab ptrectot ,m
/*
                ptrectot |      Freq.     Percent        Cum.
-------------------------+-----------------------------------
   DCO with single event |      1,055       98.69       98.69
DCO with multiple events |         14        1.31      100.00
-------------------------+-----------------------------------
                   Total |      1,069      100.00
*/

** Now create id in this dataset so when merging icd10 for siteiarc variable at end of this dofile
gen did="T1" if ptrectot==1 //1,055 changes
replace did="T2" if ptrectot==2 //14 changes


*******************
** Grouping CODs **
**    by site    **
*******************

** These groupings are based on AR's 2008 code but for 2014, in addition to this,
** I have added another grouping, at end of this dofile, which is used by IARC in CI5 Vol XI
sort cod1a

gen site=1 if (regexm(cod1a, "LIP")	| regexm(cod1a, "MOUTH") | ///
			   regexm(cod1a, "PHARYNX") | regexm(cod1a, "TONSIL") | ///
			   regexm(cod1a, "TONGUE") | ///
			   regexm(cod1a, "PHARNYX") | regexm(cod1a, "OF THE SOFT PALATE") | ///
			   regexm(cod1a, "PHARYNGEAL CARCINOMA") | regexm(cod1a, "PAROTIDSALIVARY GLAND") | ///
			   regexm(cod1a, "EPIGLOTTIS LATERAL PHARYNGEAL WALL") | ///
			   regexm(cod1a, "NASOPHARYN")| regexm(cod1a, "THROAT CANCER") | ///
			   regexm(cod1a, "CANCER OF THE THROAT") | regexm(cod1a, "OMA OF THROAT") | ///
			   regexm(cod1a, "CANCER OF SUBMANDIBULAR GLAND") | regexm(cod1a, "OMA OF SOFT PALATE") | ///
			   regexm(cod1a, "PHARYNGEAL CANCER"))
** 24 changes

replace site=2 if (regexm(cod1a, "GASTRIC CARCINOMA") | regexm(cod1a, "GASTRIC CANCER") | /// 
				  regexm(cod1a, "GASTRIC ADENO") | regexm(cod1a, "STOMACH") | ///
                  regexm(cod1a, "GASTRO-ESOPHAGEAL JUNC") | regexm(cod1a, "GASTRO OESOPHAGEAL JUNCTION") | ///
                  regexm(cod1a, "CANCER OF GASTRO-OESOPHAGEAL JUNC")) & site==.
** 48 changes

replace site=3 if (regexm(cod1a, "COLON") | regexm(cod1a, "OF BOWEL") | ///
				  regexm(cod1a, "OF THE BOWEL") | ///
				  regexm(cod1a, "CAECAL CARCINOMA") | regexm(cod1a, "CARCINOMA OF THE CAECUM") | ///
				  regexm(cod1a, "OMA OF THE SIGMOID") | regexm(cod1a, "APPENDIX") | ///
				  regexm(cod1a, "SIGMOID CANCER") | regexm(cod1a, "CANCER CAECUM") | ///
				  regexm(cod1a, "CAECAL TUMOUR") | regexm(cod1a, "OMA OF CAECUM") | ///
				  regexm(cod1a, "SIGMOID ADENOCAR")) & site==.
** 128

replace site=4 if (regexm(cod1a, "COLORECTAL") | regexm(cod1a, "RECTOSIGMOID CANCER") | ///
				  regexm(cod1a, "RECTO SIGMOID CARCINOMA")) & site==.
** 7 changes

replace site=5 if (regexm(cod1a, "RECTUM") | regexm(cod1a, "RECTAL CARCINOMA") | ///
				   regexm(cod1a, "OF THE ANAL CANAL") | regexm(cod1a, "RECTAL CANCER") | ///
				   regexm(cod1a, "RECTAL ADENOCARCINOMA") | regexm(cod1a, "ANUS")) & site==.
** 24 changes

replace site=6 if regexm(cod1a, "PANCREA") & site==.
** 53 changes

replace site=7 if (regexm(cod1a, "CANCER OF THE LIVER")  | ///
				  regexm(cod1a, "LIVER CARCIN") | regexm(cod1a, "CARCINOMA OF LIVER") | ///
				  regexm(cod1a, "GALL BLADDER") | regexm(cod1a, "GALLBLADDER") |  ///
				  regexm(cod1a, "GASTROINTESTINAL MALIGN") | regexm(cod1a, "HEPATIC CARCIN") | ///
				  regexm(cod1a, "OESOPHAGEAL CANCER") | ///
				  regexm(cod1a, "CARCINOMA OF OESOPHA") | regexm(cod1a, "OF THE ESOPHAGUS") | ///
				  regexm(cod1a, "CARCINOMA OF THE OESOPHAG") | regexm(cod1a, "JEJUNUM") | ///
				  regexm(cod1a, "HEPATIC CYST") | regexm(cod1a, "CHOLANGIO") | ///
				  regexm(cod1a, "TUMOUR OF ILEUM") | regexm(cod1a, "OESOPHAGEAL CARCINO") | ///
				  regexm(cod1a, "SMALL BOWEL") | regexm(cod1a, "DUODENAL CARCIN") | ///
				  regexm(cod1a, "LIVER MALIGNANCY") | regexm(cod1a, "HEPATOCELLULAR CARCINOMA") | ///
				  regexm(cod1a, "GASTROINTESTINAL STROMAL TUMOUR") | regexm(cod1a, "GASTROINTESTINAL CARCIN") | ///
				  regexm(cod1a, "ESOPHAGEAL CANCER") | regexm(cod1a, "CARCINOMA OF THE LIVER") | ///
				  regexm(cod1a, "OESOPHAGEAL ADENOCAR") | regexm(cod1a, "DUODENAL ULCER WITH LIVER METAS") | ///
				  regexm(cod1a, "CANCER OF OESOPHA") | regexm(cod1a, "OMA OF HEPATOBILIARY") | ///
				  regexm(cod1a, "LIVER CANCER") | regexm(cod1a, "HEPATIC ADENOCARCIN") | ///
				  regexm(cod1a, "PERIAMPULLARY MALIGN") | ///
				  regexm(cod1a, "CANCER OF THE OESOPHA")) & site==. 	  
** 51 changes
				  
replace site=8 if (regexm(cod1a, "LUNG") | regexm(cod1a, "PLEURA") | ///
				  regexm(cod1a, "LARYNX") | regexm(cod1a, "BRONCHOGENIC") | ///
				  regexm(cod1a, "BRONCHOALVEOLAR CARCIN") | regexm(cod1a, "LARYNGEAL CANCER") | ///
				  regexm(cod1a, "LARYNGEAL CARCINOMA") | regexm(cod1a, "SINONASAL CARCINOMA") | ///
				  regexm(cod1a, "CANCER ETHMOID SINUS") | regexm(cod1a, "VOCAL CORD")) & site==. 
** 93 changes
				  
replace site=9 if (regexm(cod1a, "BONE") | regexm(cod1a, "OMA OF SKULL") | ///
				  regexm(cod1a, "CANCER RIGHT MAXILLA")) & site==.
** 14 changes

replace site=10 if (regexm(cod1a, "MYELOMA") | regexm(cod1a, "MYELODYSPLASTIC") | ///
				    regexm(cod1a, "LEUKAEMIA") | regexm(cod1a, "LEUKEMIA") | ///
					regexm(cod1a, "HAEMA") | regexm(cod1a, "LYMPHO") | ///
					regexm(cod1a, "HODGKIN") | regexm(cod1a, "MYELOFIBROSIS") | ///
					regexm(cod1a, "MYELOPROLIFERATIVE")) & site==.	
** 104 changes
** JC 08oct2017: lymphomas & haem cancers are generally reported together so I've grouped these for 2013 since they were separate for 2008	
	
replace site=11 if regexm(cod1a, "MELANOMA") 
** 1 change

replace site=12 if regexm(cod1a, "SKIN") & site==.
** 2 changes
		
replace site=13 if regexm(cod1a, "MESOTHE") & site==.
** 0 changes
				  
replace site=14 if regexm(cod1a, "BREAST") & site==.
** 100 changes

replace site=15 if regexm(cod1a, "CERVI") & site==.
** 47 changes

replace site=16 if (regexm(cod1a, "UTER") | regexm(cod1a, "OMA OF THE VULVA") | ///
				    regexm(cod1a, "CHORIOCARCIN") | regexm(cod1a, "ENDOMETRIAL CARCINOMA") | ///
					regexm(cod1a, "ENDOMETRIAL CANC") | regexm(cod1a, "OF ENDOMETRIUM") | ///
					regexm(cod1a, "OF THE ENDOMETRIUM")) & site==.
** 36 changes
					
replace site=17 if (regexm(cod1a, "OVARY") | regexm(cod1a, "OVARIAN") | ///				   
				   regexm(cod1a, "GERM CELL")|regexm(cod1a, "VAGINAL CANCER") | ///
				   regexm(cod1a, "VULVA CARCINOMA") | regexm(cod1a, "VULVAL CANCER") | ///
				   regexm(cod1a, "VAGINAL CARCINOMA") | regexm(cod1a, "ENDOMETRIUM")) & site==.
** 25 changes
				   
replace site=18 if (regexm(cod1a, "PENILE") | regexm(cod1a, "OF THE TESTES") | ///
					regexm(cod1a, "GERM CELL")) & site==.
** 3 changes
					
replace site=19 if regexm(cod1a, "PROSTAT") & site==.
** 187 changes
				  
replace site=20 if (regexm(cod1a, "URIN") | regexm(cod1a, "BLADDER") | /// 
					regexm(cod1a, "KIDNEY") | regexm(cod1a, "RENAL CELL CARCIN") | ///
					regexm(cod1a, "RENAL CARCIN") | regexm(cod1a, "WILMS") | ///
					regexm(cod1a, "TRANSITIONAL CELL") | regexm(cod1a, "RENAL CELL CANCER") | ///
					regexm(cod1a, "OMA OF THE URETHRA")) & site==.
** 26 changes
					
replace site=21 if (regexm(cod1a, "EYE") | regexm(cod1a, "BRAIN") | regexm(cod1a, "CEREBRO") | ///
				   regexm(cod1a, "MENINGIO")  | regexm(cod1a, "INTRA-CRANIAL TUMOR") | ///
				   regexm(cod1a, "OITUTARY") | regexm(cod1a, "CEREBRAL NEOPLASM") | ///
				   regexm(cod1a, "GLIOSARCOMA") | regexm(cod1a, "INTRACEREBRAL TUMOUR") | ///
				   regexm(cod1a, "CEREBRAL ASTROCYTOMA") | regexm(cod1a, "GLIOBLASTOMA MULTIFORME") | ///
				   regexm(cod1a, "NEUROBLASTOMA")) & site==.
** 8 changes
				   
replace site=22 if (regexm(cod1a, "THYROID") | regexm(cod1a, "ENDOCRIN") ) & site==.
** 13 changes

** site 23 is ill-defined sites which can be assigned when checking the unassigned (i.e. site==.) in below list
		
replace site=24 if (regexm(cod1a, "LYMPH NODE")) & site==.
** Lymph - Secondary and unspecified malignant neoplasm of lymph nodes
**Excl.:malignant neoplasm of lymph nodes, specified as primary (C81-C86, C96.-)
** 0 changes

replace site=25 if (regexm(cod1a, "OCCULT") | regexm(cod1a, "OMA OF UNKNOWN ORIGIN")) & site==.
** 25 changes

label define site_lab 1 "C00-C14: lip, oral cavity & pharynx" 2 "C16: stomach"  3 "C18: colon" /// 
  					  4 "C19: colon and rectum"  5 "C20-C21: rectum & anus" 6 "C25: pancreas" ///
					  7 "C15, C17, C22-C24, C26: other digestive organs" ///
					  8 "C30-C39: respiratory and intrathoracic organs" 9 "C40-41: bone and articular cartilage" ///
					  10 "C42,C77: haem & lymph systems" ///
					  11 "C43: melanoma" 12 "C44: skin (non-reportable cancers)" ///
					  13 "C45-C49: mesothelial and soft tissue" 14 "C50: breast" 15 "C53: cervix" ///
					  16 "C54,C55: uterus" 17 "C51-C52, C56-58: other female genital organs" ///
					  18 "C60, C62, C63: male genital organs" 19 "C61: prostate" ///
					  20 "C64-C68: urinary tract" 21 "C69-C72: eye, brain, other CNS" ///
					  22 "C73-C75: thyroid and other endocrine glands"  /// 
					  23 "C76: other and ill-defined sites" ///
					  24 "C77: lymph nodes" 25 "C80: unknown primary site"
label var site "site of tumour"
label values site site_lab

** Check if site not assigned and update groupings above
tab site ,m //50 missing


sort deathid
order deathid cod1a
count if site==. //50 - use below filter in Stata editor
//list deathid ptrectot if site==.
//list cod1a if site==.

** Update missing sites based on above list
replace site=5 if deathid==1302|deathid==13575
//2 changes

replace site=7 if deathid==1257|deathid==1870|deathid==1958
//3 changes

replace site=8 if deathid==522
//1 change

replace site=12 if deathid==13711
//1 change

replace site=17 if deathid==12191
//1 change

replace site=21 if deathid==604
//1 change

replace site=23 if deathid==30|deathid==1181|deathid==11968|deathid==13121 ///
                  |deathid==13401
//5 changes

replace site=25 if deathid==273|deathid==343|deathid==537|deathid==625 ///
				  |deathid==653|deathid==950|deathid==1222|deathid==1303 ///
				  |deathid==1603|deathid==1645|deathid==1649|deathid==1755 ///
				  |deathid==1825|deathid==1969|deathid==2118|deathid==2122 ///
				  |deathid==2253|deathid==2375|deathid==11896|deathid==12080 ///
				  |deathid==12197|deathid==12332|deathid==12383|deathid==12617 ///
				  |deathid==12807|deathid==13003|deathid==13007|deathid==13055 ///
                  |deathid==13695|deathid==13717|deathid==13825|deathid==13884 ///
                  |deathid==13957|deathid==14097|deathid==14185|deathid==14190
//36 changes


tab site ,m
//list deathid cod1a if site==.

** Update sites of MPs
sort deathid
//list deathid did site cod1a if ptrectot==2
//list cod1a if ptrectot==2
/*
deathid
956 - cervix and bladder
1669 - breast(12Y) and lung(2008)
1675 - tonsil and soft palate
2358 - soft palate and vocal cord
12474 - breast and endometrium
13018 - CML and prostate
13395 - prostate and stomach
13476 - prostate and colon
13633 - pancreas and MM
13793 - uterus and breast
13899 - lung and MPD
13920 - liver(2013) and prostate(5Y)
14269 - gallbladder and pancreas
14288 - lymphoma and prostate
*/
replace site=15 if deathid==956 & did=="T1" //0 changes
replace site=20 if deathid==956 & did=="T2" //1 change

replace site=14 if deathid==1669 & did=="T1" //1 change
replace site=8 if deathid==1669 & did=="T2" //0 changes

replace site=1 if deathid==1675 & did=="T1" //0 changes - according to IARC MP rules these are 2 separate tumours
replace site=1 if deathid==1675 & did=="T2" //0 changes - tonsil and soft palate

replace site=1 if deathid==2358 & did=="T1" //0 changes
replace site=8 if deathid==2358 & did=="T2" //1 change

replace site=14 if deathid==12474 & did=="T1" //0 changes
replace site=16 if deathid==12474 & did=="T2" //1 change

replace site=10 if deathid==13018 & did=="T1" //0 changes
replace site=19 if deathid==13018 & did=="T2" //1 change

replace site=19 if deathid==13395 & did=="T1" //1 change
replace site=2 if deathid==13395 & did=="T2" //0 changes

replace site=19 if deathid==13476 & did=="T1" //0 changes
replace site=3 if deathid==13476 & did=="T2" //1 change

replace site=6 if deathid==13633 & did=="T1" //0 changes
replace site=10 if deathid==13633 & did=="T2" //1 change

replace site=16 if deathid==13793 & did=="T1" //1 change
replace site=14 if deathid==13793 & did=="T2" //0 changes

replace site=8 if deathid==13899 & did=="T1" //0 changes
replace site=10 if deathid==13899 & did=="T2" //1 change

replace site=7 if deathid==13920 & did=="T1" //0 changes
replace site=19 if deathid==13920 & did=="T2" //1 change

replace site=7 if deathid==14269 & did=="T1" //1 change
replace site=6 if deathid==14269 & did=="T2" //0 changes

replace site=10 if deathid==14288 & did=="T1" //0 changes
replace site=19 if deathid==14288 & did=="T2" //1 change

** Last check to ensure MPs have different sites
duplicates list deathid, nolabel sepby(deathid) 
duplicates tag deathid, gen(mpsite)
//list deathid site cod1a did if mpsite>0 ,sepby(deathid)

** Check to ensure site properly assigned
sort site deathid
order deathid cod1a site
//list deathid cod1a if site==1
replace site=25 if deathid==11998
replace site=7 if deathid==12412
//list deathid cod1a if site==2
replace site=19 if deathid==114
//list deathid cod1a if site==3
replace site=4 if deathid==577|deathid==12266
replace site=7 if deathid==13889
replace site=19 if deathid==1285
//list deathid cod1a if site==4
//list deathid cod1a if site==5
//list deathid cod1a if site==6
//list deathid cod1a if site==7
replace site=2 if deathid==162|deathid==12766 //0 changes
//list deathid cod1a if site==8
replace site=19 if deathid==1192|deathid==12624
replace site=16 if deathid==1218|deathid==1629
replace site=14 if deathid==1321|deathid==1572|deathid==1583|deathid==1656|deathid==1729|deathid==11903|deathid==11904|deathid==11962|deathid==12903|deathid==13344
replace site=22 if deathid==1537
replace site=25 if deathid==1879|deathid==12293|deathid==12431
replace site=15 if deathid==2147|deathid==13387|deathid==13984
replace site=13 if deathid==2462
replace site=1 if deathid==11913|deathid==12001
//list deathid cod1a if site==9
replace site=19 if deathid==54|deathid==232|deathid==2248|deathid==2404|deathid==12704|deathid==12786|deathid==13008|deathid==13085|deathid==13297|deathid==13409|deathid==13480
replace site=10 if deathid==1789
replace site=14 if deathid==12543
//list deathid cod1a if site==10
//list deathid cod1a if site==11
//list deathid cod1a if site==12
replace site=7 if deathid==12890
//list deathid cod1a if site==13
//list deathid cod1a if site==14
//list deathid cod1a if site==15
replace site=25 if deathid==14295
//list deathid cod1a if site==16
replace site=17 if deathid==1731
//list deathid cod1a if site==17
replace site=16 if deathid==12843
//list deathid cod1a if site==18
//list deathid cod1a if site==19
//list deathid cod1a if site==20
//list deathid cod1a if site==21
**NB: double check CR5db if brain tumours beh=3 as 2008 has /0,/1.
replace mrcancer=2 if deathid==1877
//list deathid cod1a if site==22
replace site=7 if deathid==11960|deathid==13472
replace site=25 if deathid==12120|deathid==12909|deathid==13569|deathid==14134
//list deathid cod1a if site==23
//list deathid cod1a if site==24
//list deathid cod1a if site==25
replace site=25 if deathid==12395

count if site==. //0

count //1,069
drop if mrcancer==2 //1 deleted

tab site ,m
count //1,068


***********************************************************
** Final cleaning checks using some checks from dofile 3 **
***********************************************************
** Creating dob variable as none in national death data
** perform data cleaning on the age variable
preserve
order deathid nrn ddage
rename nrn natregno
count if natregno==""
drop if natregno==""
gen yr = substr(natregno,1,1)
gen yr1=.
replace yr1 = 20 if yr=="0"
replace yr1 = 19 if yr!="0"
replace yr1 = 99 if natregno=="99"
order deathid natregno ddage yr yr1
** Initially need to run this code separately from entire dofile to determine which nrnyears should be '19' instead of '20' depending on age, e.g. for age 107 nrnyear=19
replace yr1 = 19 if deathid==16127
gen nrn = substr(natregno,1,6) 
destring nrn, replace
format nrn %06.0f
nsplit nrn, digits(2 2 2) gen(dyear month day)
format dyear month day %02.0f
tostring yr1, replace
gen year2 = string(dyear,"%02.0f")
gen nrnyr = substr(yr1,1,2) + substr(year2,1,2)
destring nrnyr, replace
sort nrn
gen nrn1=mdy(month, day, nrnyr)
format nrn1 %dD_m_CY
rename nrn1 dob
drop day month dyear nrnyr yr yr1 nrn
gen age2 = (dod - dob)/365.25
gen ageyrs=int(age2)
sort deathid
count if ddage!=ageyrs //4 - all ages correct
//list deathid ddage ageyrs natregno dod if ddage!=ageyrs
drop age2
restore

** Check 31 - invalid length
count if length(nrn)<11 & nrn!="" //0

** Check 32 - missing
count if ddsex==. | ddsex==9 //0

** Check 33 - possibly invalid (first name, NRN and ddsex check: MALES)
gen nrnid=substr(nrn, -4,4)
count if ddsex==2 & nrnid!="9999" & regex(substr(nrn,-2,1), "[1,3,5,7,9]") //1 - no changes, all correct
//list deathid fname lname ddsex nrn did if ddsex==2 & nrnid!="9999" & regex(substr(nrn,-2,1), "[1,3,5,7,9]")

** Check 34 - possibly invalid (ddsex=M; site=breast)
count if ddsex==1 & regexm(cod1a, "BREAST") //6 - no changes; all correct
//list deathid fname lname ddsex nrn did if ddsex==1 & regexm(cod1a, "BREAST")

** Check 35 - invalid (ddsex=M; site=FGS)
count if ddsex==1 & (regexm(cod1a, "VULVA") | regexm(cod1a, "VAGINA") | regexm(cod1a, "CERVIX") | regexm(cod1a, "CERVICAL") ///
								| regexm(cod1a, "UTER") | regexm(cod1a, "OVAR") | regexm(cod1a, "PLACENTA")) //2 - no changes; all correct
//list deathid fname lname ddsex nrn did cod1a if ddsex==1 & (regexm(cod1a, "VULVA") | regexm(cod1a, "VAGINA") | regexm(cod1a, "CERVIX") | regexm(cod1a, "CERVICAL") ///
//								| regexm(cod1a, "UTER") | regexm(cod1a, "OVAR") | regexm(cod1a, "PLACENTA"))

** Check 36 - possibly invalid (first name, NRN and ddsex check: FEMALES)
count if ddsex==1 & nrnid!="9999" & regex(substr(nrn,-2,1), "[0,2,4,6,8]") //1 - no changes, all correct
//list deathid fname lname ddsex nrn did if ddsex==1 & nrnid!="9999" & regex(substr(nrn,-2,1), "[0,2,4,6,8]")

** Check 37 - invalid (ddsex=F; site=MGS)
count if ddsex==2 & (regexm(cod1a, "PENIS")|regexm(cod1a, "PROSTAT") ///
		|regexm(cod1a, "TESTIS")|regexm(cod1a, "TESTIC")) //0

** Check 58 - missing
count if ddage==. & dod!=. //0

** Check 59 - invalid (age<>dod-dob); checked no errors
** Age (at DEATH - to nearest year)
gen dobnrn = substr(nrn,1,6) if nrn!="" 
destring dobnrn, replace
format dobnrn %06.0f
nsplit dobnrn, digits(2 2 2) gen(year month day)
format year month day %02.0f
tostring dobnrn ,replace
gen yr = substr(dobnrn,1,1)
gen yr1=.
replace yr1 = 20 if yr=="0"
replace yr1 = 19 if yr!="0"
replace yr1 = 99 if nrn=="99"
replace yr1 = 19 if deathid==16127
tostring yr1, replace
gen year2 = string(year,"%02.0f")
gen dobyr = substr(yr1,1,2) + substr(year2,1,2)
destring dobyr, replace
sort dobnrn
gen dob=mdy(month, day, dobyr)
format dob %dD_m_CY
drop day month year year2 dobyr yr yr1 dobnrn
gen ageyrs2 = (dod - dob)/365.25 //
gen checkage=int(ageyrs2)
drop ageyrs2
label var checkage "Age in years at DEATH"
count if dob!=. & dod!=. & ddage!=checkage //5
//list deathid nrn dob dod ddage checkage if dob!=. & dod!=. & ddage!=checkage
replace dob=d(29mar2001) if deathid==840
replace dob=d(12jan2000) if deathid==13508
replace dob=d(06jan2002) if deathid==13124
replace dob=d(30jan2002) if deathid==2122
replace dob=d(10oct2009) if deathid==13514

** Check 103 - Date of death missing
count if dod==. //0


***********************************
** 1.4 Number of cases by age-group
***********************************
** Age labelling
gen age5 = recode(ddage,4,9,14,19,24,29,34,39,44,49,54,59,64,69,74,79,84,200)
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
sort ddsex age_10

tab age_10 ddsex ,m
** None missing age or sex


** convert sex from string to numeric with labelled values
** 1=F and 2=M to match population dataset (NOTE: different from BNR-Cancer!)
gen numsex=1 if ddsex==2
replace numsex=2 if ddsex==1
label define numsex_lab 1 "female" 2 "male", modify
label values numsex numsex_lab
label var numsex "Patient sex"
drop ddsex
rename numsex ddsex

tab ddsex, m
/*
Patient sex |      Freq.     Percent        Cum.
------------+-----------------------------------
     female |        507       47.47       47.47
       male |        561       52.53      100.00
------------+-----------------------------------
      Total |      1,068      100.00
*/


************************
** Creating IARC Site **
************************
count //1,068

rename ptrectot ptrectotmort
sort deathid did
count if mpsite>0 //32
//list deathid did site if mpsite>0 ,sepby(deathid)
//list cod1a if mpsite>0

gen noexcelimp=1

** Create Stata dataset to merge icd10 codes with current dataset
preserve
save "`datapath'\version01\2-working\2008_2013_deaths_preicd10_dc_v01" ,replace
clear

import excel using "`datapath'\version01\2-working\2019-04-23_deaths_icd10.xlsx", firstrow
count //2,054
drop if deathid==. //0 obs deleted
drop if dodyear!=2008 & dodyear!=2013 //0 obs deleted
duplicates list deathid cr5id icd10, nolabel sepby(deathid) 
duplicates tag deathid, gen(mpicd10)
sort deathid cr5id
list deathid topography morph ptrectot cr5id icd10 if mpicd10>0 ,sepby(deathid)
//need to update these 'did' variable to match import so merge below will not swap icd10 codes for MPs: deathid 5446, 14323, 19104, 19119, 19431
**drop if deathid==13088 & cr5id=="T2S1" //1 obs deleted - MP from cr5db not from cod1a
sort deathid cr5id

gen did="T1" if regexm(cr5id,"T1")
tab did,m //7 missing
list deathid topography morph cr5id icd10 mpicd10 if did==""
//need to update 'did' variable for those whose cr5id!="T1S1" and not a MP
replace did="T1" if deathid==11976 //1 change
replace did="T2" if did=="" //6 changes
replace did="T2" if deathid==1669 & icd10=="C341" //1 change
replace did="T2" if deathid==13395 & icd10=="C160" //1 change
replace did="T1" if deathid==13899 & icd10=="C340" //1 change
replace did="T2" if deathid==13899 & icd10=="D473" //1 change


tab did ,m
/*
        did |      Freq.     Percent        Cum.
------------+-----------------------------------
         T1 |        483       98.77       98.77
         T2 |          6        1.23      100.00
------------+-----------------------------------
      Total |        489      100.00
*/
drop ptrectot
rename siteiarc siteiarc1
rename siteiarchaem siteiarchaem1
count //489
gen excelimp=1
//used to compare with noexcelimp=1 as there are ... cases with no cod1a after merge as these from dofile 3 are either
//(1)not cancer (2)cancer with ptrectot=DCO with single event i.e. national DCO in dofile 3
/*
drop if deathid==1146|deathid==6700|deathid==9699|deathid==11945|deathid==13009 ///
		|deathid==15458|deathid==19815|deathid==20241|deathid==20504 ///
		|deathid==21532|deathid==23771|deathid==14526
** 12 obs deleted
*/
count //489

save "`datapath'\version01\2-working\2008_2013_deaths_icd10_dc_v01" ,replace
restore


** Merge IARC ICD-10 coded dataset with this one using deathid
//list deathid did mrcancer if deathid==8621|deathid==8711|deathid==6944
//list cod1a if deathid==8621|deathid==8711|deathid==6944
** kidney(1), prostate(2)
count //1,068
merge m:m deathid did using "`datapath'\version01\2-working\2008_2013_deaths_icd10_dc_v01"
/* 
    Result                           # of obs.
    -----------------------------------------
    not matched                           717
        from master                       648  (_merge==1)
        from using                         69  (_merge==2)

    matched                               420  (_merge==3)
    -----------------------------------------
*/
count //1,137

** Check 69 from using that did not merge - none to check after 2nd attempt
//list deathid topography morph dodyear siteiarc1 siteiarchaem1 cr5id did icd10 if _merge==2
//list cod1a if _merge==2

duplicates tag deathid, gen(unmatched)
sort deathid did cr5id

** Assign topography and icd10 codes to unmatched/unmerged deaths that are MPs
** Assign morphology and icd10 codes to haem & lymph. cancers for unmatched deaths that are MPs 
**(use excel '2018-12-05_iarccrg_icd10_conversion code.xlsx' in raw data to filter by top to assign icd10)
//list deathid did topography morph cr5id site icd10 if unmatched>0 & icd10=="" ,sepby(deathid)
//list cod1a if unmatched>0 & icd10==""

replace icd10="C539" if deathid==956 & did=="T1" //1 change
replace icd10="C679" if deathid==956 & did=="T2" //1 change

replace icd10="C509" if deathid==1669 & did=="T1" //1 change
replace icd10="C341" if deathid==1669 & did=="T2" //0 changes

replace icd10="C099" if deathid==1675 & did=="T1" //1 change
replace icd10="C051" if deathid==1675 & did=="T2" //1 change

replace icd10="C051" if deathid==2358 & did=="T1" //1 change
replace icd10="C320" if deathid==2358 & did=="T2" //1 change

replace icd10="C509" if deathid==12474 & did=="T1" //1 change
replace icd10="C541" if deathid==12474 & did=="T2" //1 change

replace icd10="C921" if deathid==13018 & did=="T1" //0 changes
replace icd10="C61" if deathid==13018 & did=="T2" //1 change

replace icd10="C61" if deathid==13395 & did=="T1" //1 change
replace icd10="C160" if deathid==13395 & did=="T2" //0 changes

replace icd10="C61" if deathid==13476 & did=="T1" //1 change
replace icd10="C189" if deathid==13476 & did=="T2" //1 change

replace icd10="C259" if deathid==13633 & did=="T1" //0 changes
replace icd10="C900" if deathid==13633 & did=="T2" //1 change

replace icd10="C55" if deathid==13793 & did=="T1" //1 change
replace icd10="C509" if deathid==13793 & did=="T2" //1 change

replace icd10="C220" if deathid==13920 & did=="T1" //0 changes
replace icd10="C61" if deathid==13920 & did=="T2" //1 change

replace icd10="C23" if deathid==14269 & did=="T1" //0 changes
replace icd10="C259" if deathid==14269 & did=="T2" //1 change

replace icd10="C859" if deathid==14288 & did=="T1" //1 change
replace icd10="C61" if deathid==14288 & did=="T2" //1 change

STOPPED HERE
** Now check how many missing topography codes 
tab topography ,m
tab morph ,m
tab icd10 ,m

//list deathid did topography morph cr5id _merge icd10 if unmatched>0 & _merge!=3 ,sepby(deathid)

** Assign topography codes unmatched/unmerged deaths
sort deathid did
count if icd10=="" //229
//list deathid did site if icd10==""
//list cod1a if icd10==""

replace topography=29 if (regexm(cod1a,"TONGUE") & regexm(cod1a,"CARCIN") & icd10=="")|(regexm(cod1a,"TONGUE") & regexm(cod1a,"CANCER") & icd10=="")
** 1 change
replace topography=119 if (regexm(cod1a,"NASOPHARYNX") & regexm(cod1a,"CARCIN")& icd10=="")|(regexm(cod1a,"NASOPHARYNX") & regexm(cod1a,"CANCER") & icd10=="")
** 1 change
replace topography=169 if (regexm(cod1a,"CANCER STOMATCH")|regexm(cod1a,"OMA OF STOMACH")|regexm(cod1a,"OMA OF THE STOMACH")|regexm(cod1a,"GASTRIC CARCIN")|regexm(cod1a,"GASTRIC CANCER")) & icd10==""
** 2 changes
replace topography=180 if (regexm(cod1a,"CAECUM") & regexm(cod1a,"CANCER")& icd10=="")|(regexm(cod1a,"CAECUM") & regexm(cod1a,"CARCIN") & icd10=="")
** 1 change
replace topography=189 if (regexm(cod1a,"COLON") & regexm(cod1a,"CANCER")& icd10=="")|(regexm(cod1a,"COLON") & regexm(cod1a,"CARCIN") & icd10=="")
** 17 changes
replace topography=209 if (regexm(cod1a,"CANCER RECTUM")|regexm(cod1a,"OMA OF RECTUM")|regexm(cod1a,"OMA OF THE RECTUM")|regexm(cod1a,"RECTAL CARCIN")) & icd10==""
** 5 changes
replace topography=239 if (regexm(cod1a,"GALL") & regexm(cod1a,"CARCIN")& icd10=="")|(regexm(cod1a,"GALL") & regexm(cod1a,"CANCER") & icd10=="")
** 1 change
replace topography=249 if regexm(cod1a,"CHOLANGIO-CARCINOMA") & icd10==""
** 1 change
replace topography=259 if (regexm(cod1a,"PANCREA") & regexm(cod1a,"CARCIN")& icd10=="")|(regexm(cod1a,"PANCREA") & regexm(cod1a,"CANCER") & icd10=="")
** 8 changes
replace topography=269 if regexm(cod1a,"GASTROINTESTINAL CARCIN") & icd10==""
** 1 change
replace topography=349 if (regexm(cod1a,"LUNG CANCER")|regexm(cod1a,"CANCER OF THE RIGHT LUNG")|regexm(cod1a,"CANCER OF THE LUNG")) & icd10==""
** 5 changes
replace topography=509 if (regexm(cod1a,"BREAST") & regexm(cod1a,"CARCIN")& icd10=="")|(regexm(cod1a,"BREAST") & regexm(cod1a,"CANCER") & icd10=="")
** 37 changes
replace topography=539 if (regexm(cod1a,"CERVI") & regexm(cod1a,"CARCIN")& icd10=="")|(regexm(cod1a,"CERVI") & regexm(cod1a,"CANCER") & icd10=="")
** 5 changes
replace topography=541 if (regexm(cod1a,"ENDOMETRI") & regexm(cod1a,"CARCINOMA")& icd10=="")|(regexm(cod1a,"ENDOMETRI") & regexm(cod1a,"CANCER") & icd10=="")
** 3 changes
replace topography=619 if (regexm(cod1a,"PROSTAT") & regexm(cod1a,"CARCINOMA")& icd10=="")|(regexm(cod1a,"PROSTAT") & regexm(cod1a,"CANCER") & icd10=="")
** 81 changes
replace topography=649 if (regexm(cod1a,"RENAL CELL") & regexm(cod1a,"CARCINOMA")& icd10=="")|(regexm(cod1a,"RENAL CELL") & regexm(cod1a,"CANCER") & icd10=="")
** 2 changes
replace topography=679 if (regexm(cod1a,"BLADDER") & regexm(cod1a,"CARCINOMA")& icd10=="")|(regexm(cod1a,"BLADDER") & regexm(cod1a,"CANCER") & icd10=="")
** 4 changes
replace topography=739 if (regexm(cod1a,"CANCER THYROID")|regexm(cod1a,"THYROID CANCER")) & icd10==""
** 2 changes
replace topography=809 if regexm(cod1a,"OCCULT") & icd10==""
** 3 changes
** 180 changes in total so 49 still missing

replace icd10="C029" if topography==29 & icd10=="" & site!=10 //1 change
replace icd10="C119" if topography==119 & icd10=="" & site!=10 //1 change
replace icd10="C159" if topography==159 & icd10=="" & site!=10 //0 changes
replace icd10="C169" if topography==169 & icd10=="" & site!=10 //2 changes
replace icd10="C180" if topography==180 & icd10=="" & site!=10 //1 change
replace icd10="C189" if topography==189 & icd10=="" & site!=10 //17 changes
replace icd10="C20" if topography==209 & icd10=="" & site!=10 //4 changes
replace icd10="C210" if topography==210 & icd10=="" & site!=10 //0 changes
replace icd10="C23" if topography==239 & icd10=="" & site!=10 //0 changes
replace icd10="C249" if topography==249 & icd10=="" & site!=10 //1 change
replace icd10="C259" if topography==259 & icd10=="" & site!=10 //8 changes
replace icd10="C269" if topography==269 & icd10=="" & site!=10 //1 change
replace icd10="C349" if topography==259 & icd10=="" & site!=10 //0 changes
replace icd10="C449" if topography==449 & icd10=="" & site!=10 //0 changes
replace icd10="C509" if topography==509 & icd10=="" & site!=10 //38 changes
replace icd10="C539" if topography==539 & icd10=="" & site!=10 //5 changes
replace icd10="C541" if topography==541 & icd10=="" & site!=10 //3 changes
replace icd10="C61" if topography==619 & icd10=="" & site!=10 //80 changes
replace icd10="C64" if topography==649 & icd10=="" & site!=10 //2 changes
replace icd10="C679" if topography==679 & icd10=="" & site!=10 //4 changes
replace icd10="C73" if topography==739 & icd10=="" & site!=10 //2 changes
replace icd10="C800" if topography==809 & icd10=="" & site!=10 //3 changes
** 170 changes in total so 59 still missing

count if icd10=="" //59; 56
//list deathid did site if icd10==""
//list cod1a if icd10==""
** Assign top & morph for lymphomas
//list deathid cod1a if icd10=="" & regexm(cod1a,"LYMPHOMA")

replace topography=779 if deathid==516 & icd10=="" //1 change
replace morph=9650 if deathid==516 & icd10=="" //1 change

replace topography=779 if deathid==678 & icd10=="" //1 change
replace morph=9591 if deathid==678 & icd10=="" //1 change

replace topography=779 if deathid==5475 & icd10=="" //1 change
replace morph=9591 if deathid==5475 & icd10=="" //1 change

replace topography=779 if deathid==5643 & icd10=="" //1 change
replace morph=9650 if deathid==5643 & icd10=="" //1 change

replace topography=779 if deathid==7947 & icd10=="" //1 change
replace morph=9591 if deathid==7947 & icd10=="" //1 change

replace topography=779 if deathid==16653 & icd10=="" //1 change
replace morph=9591 if deathid==16653 & icd10=="" //1 change

replace topography=779 if deathid==20760 & icd10=="" //1 change
replace morph=9591 if deathid==20760 & icd10=="" //1 change

replace topography=779 if deathid==21858 & icd10=="" //1 change
replace morph=9827 if deathid==21858 & icd10=="" //1 change

replace topography=779 if deathid==22371 & icd10=="" //1 change
replace morph=9591 if deathid==22371 & icd10=="" //1 change

replace topography=779 if deathid==23966 & icd10=="" //1 change
replace morph=9591 if deathid==23966 & icd10=="" //1 change

** Assign top & morph for myelomas
//list deathid cod1a if icd10=="" & regexm(cod1a,"MYELOMA")

replace topography=421 if deathid==6905 & icd10=="" //1 change
replace morph=9732 if deathid==6905 & icd10=="" //1 change

replace topography=421 if deathid==15349 & icd10=="" //1 change
replace morph=9732 if deathid==15349 & icd10=="" //1 change

replace topography=421 if deathid==15507 & icd10=="" //1 change
replace morph=9732 if deathid==15507 & icd10=="" //1 change

replace topography=421 if deathid==20823 & icd10=="" //1 change
replace morph=9732 if deathid==20823 & icd10=="" //1 change

replace topography=421 if deathid==22354 & icd10=="" //1 change
replace morph=9732 if deathid==22354 & icd10=="" //1 change

** Assign top & morph for myelomas
//list deathid cod1a if icd10=="" & regexm(cod1a,"LEUK")

replace topography=421 if deathid==3208 & icd10=="" //1 change
replace morph=9823 if deathid==3208 & icd10=="" //1 change

replace topography=421 if deathid==4714 & icd10=="" //1 change
replace morph=9823 if deathid==4714 & icd10=="" //1 change

replace topography=421 if deathid==19903 & icd10=="" //1 change
replace morph=9863 if deathid==19903 & icd10=="" //1 change

replace topography=421 if deathid==21209 & icd10=="" //1 change
replace morph=9863 if deathid==21209 & icd10=="" //1 change

** Assign icd10 codes to haem & lymph. cancers
replace icd10="C819" if morph==9650 & icd10=="" //2 changes
replace icd10="C859" if (morph==9590|morph==9591) & icd10=="" //7 changes
replace icd10="C900" if morph==9732 & icd10=="" //5 changes
replace icd10="C911" if morph==9823 & icd10=="" //2 changes
replace icd10="C915" if morph==9827 & icd10=="" //1 changes
replace icd10="C921" if morph==9863 & icd10=="" //2 changes

** Assign remaining missing icd10 cases
count if icd10=="" //37
//list deathid cod1a if icd10==""

replace topography=159 if deathid==4007 & icd10=="" //1 change
replace icd10="C159" if deathid==4007 & icd10=="" //1 change

replace topography=160 if deathid==22928 & icd10=="" //1 change
replace icd10="C160" if deathid==22928 & icd10=="" //1 change

replace topography=169 if deathid==10423 & icd10=="" //1 change
replace icd10="C169" if deathid==10423 & icd10=="" //1 change

replace topography=181 if deathid==19926 & icd10=="" //1 change
replace icd10="C181" if deathid==19926 & icd10=="" //1 change

replace topography=209 if (deathid==10371|deathid==18867) & icd10=="" //2 changes
replace icd10="C20" if (deathid==10371|deathid==18867) & icd10=="" //2 changes

replace topography=220 if deathid==21909 & icd10=="" //1 change
replace icd10="C227" if deathid==21909 & icd10=="" //1 change

replace topography=269 if deathid==3964 & icd10=="" //1 change
replace icd10="C269" if deathid==3964 & icd10=="" //1 change

replace topography=311 if deathid==10809 & icd10=="" //1 change
replace icd10="C311" if deathid==10809 & icd10=="" //1 change

replace topography=349 if (deathid==1955|deathid==4926|deathid==4946|deathid==5478|deathid==14378|deathid==16656) & icd10=="" //2 changes
replace icd10="C349" if (deathid==1955|deathid==4926|deathid==4946|deathid==5478|deathid==14378|deathid==16656) & icd10=="" //6 changes

replace topography=410 if deathid==8061 & icd10=="" //1 change
replace icd10="C410" if deathid==8061 & icd10=="" //1 change

replace topography=441 if deathid==5807 & icd10=="" //1 change
replace icd10="C441" if deathid==5807 & icd10=="" //1 change

replace topography=443 if deathid==8574 & icd10=="" //1 change
replace icd10="C443" if deathid==8574 & icd10=="" //1 change

replace topography=444 if (deathid==3849|deathid==23750) & icd10=="" //2 changes
replace icd10="C444" if (deathid==3849|deathid==23750) & icd10=="" //2 changes

replace topography=445 if deathid==7726 & icd10=="" //1 change
replace icd10="C445" if deathid==7726 & icd10=="" //1 change

replace topography=449 if deathid==20031 & icd10=="" //1 change
replace icd10="C449" if deathid==20031 & icd10=="" //1 change

replace topography=559 if deathid==12150 & icd10=="" //1 change
replace icd10="C55" if deathid==12150 & icd10=="" //1 change

replace topography=619 if (deathid==8401|deathid==6313) & icd10=="" //1 change
replace icd10="C61" if (deathid==8401|deathid==6313) & icd10=="" //2 changes

replace topography=649 if deathid==11614 & icd10=="" //1 change
replace icd10="C64" if deathid==11614 & icd10=="" //1 change

replace topography=765 if deathid==16127 & icd10=="" //1 change
replace icd10="C765" if deathid==16127 & icd10=="" //1 change

replace topography=809 if (deathid==1690|deathid==5543|deathid==8665|deathid==9950|deathid==10565|deathid==14778|deathid==16076|deathid==16544|deathid==13062) & icd10=="" //9 changes
replace icd10="C800" if (deathid==1690|deathid==5543|deathid==8665|deathid==9950|deathid==10565|deathid==14778|deathid==16076|deathid==16544|deathid==13062) & icd10=="" //9 changes

replace topography=421 if deathid==12478 & icd10=="" //1 change
replace morph=9961 if deathid==12478 & icd10=="" //1 change
replace icd10="D474" if deathid==12478 & icd10=="" //1 change

tab icd10 ,m

** Check for duplicate pid identified above using ptrectot to ensure icd10 codes not swapped
count if ptrectot==2 //16 - all correct
//list deathid did icd10 top morph if ptrectot==2


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
replace siteiarc=3 if (regexm(icd10,"C03")|regexm(icd10,"C04")|regexm(icd10,"C05")|regexm(icd10,"C06")) //2 changes
replace siteiarc=4 if (regexm(icd10,"C07")|regexm(icd10,"C08")) //1 change
replace siteiarc=5 if regexm(icd10,"C09") //1 change
replace siteiarc=6 if regexm(icd10,"C10") //5 changes
replace siteiarc=7 if regexm(icd10,"C11") //3 changes
replace siteiarc=8 if (regexm(icd10,"C12")|regexm(icd10,"C13")) //4 changes
replace siteiarc=9 if regexm(icd10,"C14") //1 change
replace siteiarc=10 if regexm(icd10,"C15") //10 changes
replace siteiarc=11 if regexm(icd10,"C16") //20 changes
replace siteiarc=12 if regexm(icd10,"C17") //2 changes
replace siteiarc=13 if regexm(icd10,"C18") //71 changes
replace siteiarc=14 if (regexm(icd10,"C19")|regexm(icd10,"C20")) //20 changes
replace siteiarc=15 if regexm(icd10,"C21") //1 change
replace siteiarc=16 if regexm(icd10,"C22") //9 changes
replace siteiarc=17 if (regexm(icd10,"C23")|regexm(icd10,"C24")) //9 changes
replace siteiarc=18 if regexm(icd10,"C25") //29 changes
replace siteiarc=19 if (regexm(icd10,"C30")|regexm(icd10,"C31")) //1 change
replace siteiarc=20 if regexm(icd10,"C32") //1 change
replace siteiarc=21 if (regexm(icd10,"C33")|regexm(icd10,"C34")) //41 changes
replace siteiarc=22 if (regexm(icd10,"C37")|regexm(icd10,"C38")) //0 changes
replace siteiarc=23 if (regexm(icd10,"C40")|regexm(icd10,"C41")) //2 changes
replace siteiarc=24 if regexm(icd10,"C43") //1 change
replace siteiarc=25 if regexm(icd10,"C44") //7 change
replace siteiarc=26 if regexm(icd10,"C45") //1 change
replace siteiarc=27 if regexm(icd10,"C46") //0 changes
replace siteiarc=28 if (regexm(icd10,"C47")|regexm(icd10,"C49")) //0 changes
replace siteiarc=29 if regexm(icd10,"C50") //72 changes
replace siteiarc=30 if regexm(icd10,"C51") //0 changes
replace siteiarc=31 if regexm(icd10,"C52") //2 changes
replace siteiarc=32 if regexm(icd10,"C53") //12 changes
replace siteiarc=33 if regexm(icd10,"C54") //21 changes
replace siteiarc=34 if regexm(icd10,"C55") //3 changes
replace siteiarc=35 if regexm(icd10,"C56") //1 change
replace siteiarc=36 if regexm(icd10,"C57") //0 changes
replace siteiarc=37 if regexm(icd10,"C58") //0 changes
replace siteiarc=38 if regexm(icd10,"C60") //2 changes
replace siteiarc=39 if regexm(icd10,"C61") //150 changes
replace siteiarc=40 if regexm(icd10,"C62") //0 changes
replace siteiarc=41 if regexm(icd10,"C63") //0 changes
replace siteiarc=42 if regexm(icd10,"C64") //11 changes
replace siteiarc=43 if regexm(icd10,"C65") //0 changes
replace siteiarc=44 if regexm(icd10,"C66") //0 changes
replace siteiarc=45 if regexm(icd10,"C67") //13 changes
replace siteiarc=46 if regexm(icd10,"C68") //0 changes
replace siteiarc=47 if regexm(icd10,"C69") //0 changes
replace siteiarc=48 if (regexm(icd10,"C70")|regexm(icd10,"C71")|regexm(icd10,"C72")) //0 changes
replace siteiarc=49 if regexm(icd10,"C73") //3 changes
replace siteiarc=50 if regexm(icd10,"C74") //0 changes
replace siteiarc=51 if regexm(icd10,"C75") //0 changes
replace siteiarc=52 if regexm(icd10,"C81") //2 changes
replace siteiarc=53 if (regexm(icd10,"C82")|regexm(icd10,"C83")|regexm(icd10,"C84")|regexm(icd10,"C85")|regexm(icd10,"C86")|regexm(icd10,"C96")) //18 changes
replace siteiarc=54 if regexm(icd10,"C88") //1 change
replace siteiarc=55 if regexm(icd10,"C90") //22 changes
replace siteiarc=56 if regexm(icd10,"C91") //5 changes
replace siteiarc=57 if (regexm(icd10,"C92")|regexm(icd10,"C93")|regexm(icd10,"C94")) //4 changes
replace siteiarc=58 if regexm(icd10,"C95") //3 changes
replace siteiarc=59 if (morph>9949 & morph<9970)|(morph>9969 & morph<9980) //2 changes
replace siteiarc=60 if morph>9979 & morph<9999 //1 change
replace siteiarc=61 if (regexm(icd10,"C26")|regexm(icd10,"C39")|regexm(icd10,"C48")|regexm(icd10,"C76")|regexm(icd10,"C80")) //57 changes
**replace siteiarc=62 if siteiarc<62
**replace siteiarc=63 if siteiarc<62 & siteiarc!=25
replace siteiarc=64 if morph==8077 //0 changes - no CIN 3 in death data

tab siteiarc ,m //none missing

gen allsites=1 if siteiarc<62 //651 changes
label var allsites "All sites (ALL)"

gen allsitesnoC44=1 if siteiarc<62 & siteiarc!=25 //7 missing so 7=C44
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
replace siteiarchaem=1 if morph>9589 & morph<9650 //14 changes
replace siteiarchaem=2 if morph>9649 & morph<9670 //2 changes
replace siteiarchaem=3 if morph>9669 & morph<9700 //4 changes
replace siteiarchaem=4 if morph>9699 & morph<9727 //0 changes
replace siteiarchaem=5 if morph>9726 & morph<9731 //1 change
replace siteiarchaem=6 if morph>9730 & morph<9740 //22 changes
replace siteiarchaem=7 if morph>9739 & morph<9750 //0 changes
replace siteiarchaem=8 if morph>9749 & morph<9760 //0 changes
replace siteiarchaem=9 if morph>9759 & morph<9800 //0 changes
replace siteiarchaem=10 if morph>9799 & morph<9820 //3 changes
replace siteiarchaem=11 if morph>9819 & morph<9840 //5 changes
replace siteiarchaem=12 if morph>9839 & morph<9940 //4 changes
replace siteiarchaem=13 if morph>9939 & morph<9950 //0 changes
replace siteiarchaem=14 if morph>9949 & morph<9970 //1 change
replace siteiarchaem=15 if morph>9969 & morph<9980 //1 change
replace siteiarchaem=16 if morph>9979 & morph<9999 //1 change

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
33 "All sites but C44"
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

tab sitecr5db ,m


** Create ICD-10 groups according to Angie's previous site labels but more standardized site assignment based on all ICD-10 not mixtured of ICD-10 & ICD-O-3 (added after analysis dofiles 4,6)
tab icd10 ,m
gen sitear=.
label define sitear_lab 1 "C00-C14: lip, oral cavity & pharynx" 2 "C16: stomach"  3 "C18: colon" /// 
  					  4 "C19: colon and rectum"  5 "C20-C21: rectum & anus" 6 "C25: pancreas" ///
					  7 "C15, C17, C22-C24, C26: other digestive organs" ///
					  8 "C30-C39: respiratory and intrathoracic organs" 9 "C40-41: bone and articular cartilage" ///
					  10 "C42,C77: haem & lymph systems" ///
					  11 "C43: melanoma & reportable skin cancers" 12 "C44: skin (non-reportable)" ///
					  13 "C45-C49: mesothelial and soft tissue" 14 "C50: breast" 15 "C53: cervix" ///
					  16 "C54,55: uterus" 17 "C51-C52, C56-58: other female genital organs" ///
					  18 "C60, C62, C63: male genital organs" 19 "C61: prostate" ///
					  20 "C64-C68: urinary tract" 21 "C69-C72: eye, brain, other CNS" ///
					  22 "C73-C75: thyroid and other endocrine glands"  /// 
					  23 "C76: other and ill-defined sites" ///
					  24 "C77: lymph nodes" 25 "C80: unknown primary site"
label var sitear "site of tumour"
label values sitear site_lab

replace sitear=1 if (regexm(icd10,"C00")|regexm(icd10,"C01")|regexm(icd10,"C02") ///
					 |regexm(icd10,"C03")|regexm(icd10,"C04")|regexm(icd10,"C05") ///
					 |regexm(icd10,"C06")|regexm(icd10,"C07")|regexm(icd10,"C08") ///
					 |regexm(icd10,"C09")|regexm(icd10,"C10")|regexm(icd10,"C11") ///
					 |regexm(icd10,"C12")|regexm(icd10,"C13")|regexm(icd10,"C14")) //34 changes
replace sitear=2 if regexm(icd10,"C16") //23 changes
replace sitear=3 if regexm(icd10,"C18") //131 changes
replace sitear=4 if regexm(icd10,"C19") //5 changes
replace sitear=5 if (regexm(icd10,"C20")|regexm(icd10,"C21")) //28 changes
replace sitear=6 if regexm(icd10,"C25") //23 changes
replace sitear=7 if (regexm(icd10,"C15")|regexm(icd10,"C17")|regexm(icd10,"C22")|regexm(icd10,"C23")|regexm(icd10,"C24")|regexm(icd10,"C26")) //40 changes
replace sitear=8 if (regexm(icd10,"C30")|regexm(icd10,"C31")|regexm(icd10,"C32")|regexm(icd10,"C33")|regexm(icd10,"C34")|regexm(icd10,"C37")|regexm(icd10,"C38")|regexm(icd10,"C39")) //57 changes
replace sitear=9 if (regexm(icd10,"C40")|regexm(icd10,"C41")) //3 changes
replace sitear=10 if sitecr5db==21|sitecr5db==22|sitecr5db==30|sitecr5db==31 //73 changes
replace sitear=11 if siteiarc==24 //7 changes
replace sitear=12 if siteiarc==25 //0 changes
replace sitear=13 if (regexm(icd10,"C45")|regexm(icd10,"C46")|regexm(icd10,"C47")|regexm(icd10,"C48")|regexm(icd10,"C49")) //12 changes
replace sitear=14 if regexm(icd10,"C50") //174 changes
replace sitear=15 if regexm(icd10,"C53") //21 changes
replace sitear=16 if (regexm(icd10,"C54")|regexm(icd10,"C55")) //49 changes
replace sitear=17 if (regexm(icd10,"C51")|regexm(icd10,"C52")|regexm(icd10,"C56")|regexm(icd10,"C57")|regexm(icd10,"C58")) //14 changes
replace sitear=18 if (regexm(icd10,"C60")|regexm(icd10,"C62")|regexm(icd10,"C63")) //5 changes
replace sitear=19 if regexm(icd10,"C61") //216 changes
replace sitear=20 if (regexm(icd10,"C64")|regexm(icd10,"C65")|regexm(icd10,"C66")|regexm(icd10,"C67")|regexm(icd10,"C68")) //37 changes
replace sitear=21 if (regexm(icd10,"C69")|regexm(icd10,"C70")|regexm(icd10,"C71")|regexm(icd10,"C72")) //6 changes
replace sitear=22 if (regexm(icd10,"C73")|regexm(icd10,"C74")|regexm(icd10,"C75")) //12 changes
replace sitear=23 if regexm(icd10,"C76") //3 changes
**replace sitear=24 if  // captured in sitear 10
replace sitear=25 if regexm(icd10,"C80") //43 changes

tab sitear ,m //0 missing

drop cod1b cod1c cod1d cod2a cod2b onsetnumcod1b onsettxtcod1b onsetnumcod1c ///
	 onsettxtcod1c onsetnumcod1d onsettxtcod1d onsetnumcod2a onsettxtcod2a ///
	 onsetnumcod2b onsettxtcod2b death_certificate_complete tempcod1a
	 
order deathid did fname lname age age5 age_10 sex dob nrn parish dod dodyear mrcancer siteiarc siteiarchaem site pod cod1a

count // 651

save "`datapath'\version01\2-working\2014_mort_dc" ,replace
label data "National deaths prepared 2014 data"
notes _dta :These data prepared for 2014 cancer report
