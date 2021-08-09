** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          16_final clean.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      09-AUG-2021
    // 	date last modified      09-AUG-2021
    //  algorithm task          Final cleaning of 2008,2013-2015 cancer dataset; Preparing datasets for analysis
    //  status                  Completed
    //  objective               To have one dataset with cleaned and grouped 2008, 2013, 2014 data for inclusion in 2015 cancer report.
    //  methods                 Clean and update all years' data using IARCcrgTools Check and Multiple Primary

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
    log using "`logpath'\16_final clean.smcl", replace
** HEADER -----------------------------------------------------

** Load cleaned pre-matched cancer dataset from dofile 15
use "`datapath'\version02\2-working\2008_2013_2014_2015_cancer ds_2015-2020 death matching", clear

** Combine death matched dataset from dofile 50 to this cancer dataset
merge 1:1 pid cr5id using "`datapath'\version02\2-working\2008_2013_2014_2015_cancer ds_2015-2020 deaths matched" ,update replace
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         3,943
        from master                     3,943  (_merge==1)
        from using                          0  (_merge==2)

    matched                               123
        not updated                         0  (_merge==3)
        missing updated                     0  (_merge==4)
        nonmissing conflict               123  (_merge==5)
    -----------------------------------------
*/
drop _merge
count //4066

** Perform final checks on the post-clean updated + death matched cancer dataset
stop

(1) Combine all death data into one set of death variables
(1) Perform IARCcrgTools Check + MP
(2) Perform final checks
    - slc
    - dlc
    - dod
    - deceased
    - patient
    - eidmp
    - ptrectot
    - persearch
    - dcostatus
    - basis
    - behaviour
    - siteiarc
    - icd10
    - resident
    - sex
    - age
    - duplicates
(3) Create datasets
(4) Update and run dofile 55 - survival
(5) Update and run dofile 20 - analysis
(6) Update and run dofile 30 - report (drop 2008 figures) 

Check for persearch=Dup to remove
RE-RUN FINAL CHECKS
RE-RUN AGE CHECK + NAMES AND NRN DUPLICATES CHECKS
Check if pt deceased but dlc and dod do not match -  dod!=dlc & slc==2
Review DCOs in MedData (basis==0)
Check for resident=2 or 99 then look them up in MedData
2020 death prep and matching so can have 5yr survival for 2015 data
Run data through IARCcrgTools - Check + MP programs
Re-run 2008-2015 survival code to generate surv ds
NEED TO RE-RUN ALL IARC ANALYSIS AND 2015 ANN RPT ANALYSIS

/*
** Convert names to lower case and strip possible leading/trailing blanks
replace fname = lower(rtrim(ltrim(itrim(fname)))) //0 changes
replace init = lower(rtrim(ltrim(itrim(init)))) //870 changes
replace lname = lower(rtrim(ltrim(itrim(lname)))) //0 changes
	  
** Ensure death date is correct IF PATIENT IS DEAD
count if dlc!=dod & slc==2 //48
replace dlc=dod if dlc!=dod & slc==2 //48 changes
format dod %dD_m_CY

count if dodyear==. & dod!=. //70
replace dodyear=year(dod) if dodyear==. & dod!=. //70 changes
count if dod==. & slc==2 //0
//list pid cr5id fname lname nftype dlc if dod==. & slc==2
/*
gen cr5dodyear = year(dod)
label var cr5dodyear "Year of CR5 death"
*/
count if slc==2 & recstatus==3 //0

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
		using "`datapath'\version02\2-working\DCO2015V05.xlsx", sheet("2015 DCOs_cr5data_20210727") firstrow(variables)
//JC remember to change V01 to V02 when running list a 2nd time!
restore


** Export dataset to run data in IARCcrg Tools (Check Programme)
gen INCIDYR=year(dot)
tostring INCIDYR, replace
gen INCIDMONTH=month(dot)
gen str2 INCIDMM = string(INCIDMONTH, "%02.0f")
gen INCIDDAY=day(dot)
gen str2 INCIDDD = string(INCIDDAY, "%02.0f")
gen INCID=INCIDYR+INCIDMM+INCIDDD
replace INCID="" if INCID=="..." //0 changes
drop INCIDMONTH INCIDDAY INCIDYR INCIDMM INCIDDD
rename INCID dot_iarc
label var dot_iarc "IARC IncidenceDate"

gen BIRTHYR=year(dob)
tostring BIRTHYR, replace
gen BIRTHMONTH=month(dob)
gen str2 BIRTHMM = string(BIRTHMONTH, "%02.0f")
gen BIRTHDAY=day(dob)
gen str2 BIRTHDD = string(BIRTHDAY, "%02.0f")
gen BIRTHD=BIRTHYR+BIRTHMM+BIRTHDD
replace BIRTHD="" if BIRTHD=="..." //17 changes
drop BIRTHDAY BIRTHMONTH BIRTHYR BIRTHMM BIRTHDD
rename BIRTHD dob_iarc
label var dob_iarc "IARC BirthDate"

** mpseq was dropped so need to create
gen mpseq_iarc=0 if persearch==1
replace mpseq_iarc=1 if persearch!=1 & regexm(cr5id,"T1") //12 changes
replace mpseq_iarc=2 if persearch!=1 & !(strmatch(strupper(cr5id), "*T1*")) //10 changes

export delimited pid mpseq_iarc sex topography morph beh grade basis dot_iarc dob_iarc age cr5id eidmp dxyr persearch ///
using "`datapath'\version02\2-working\2015_nonsurvival_iarccrgtools.txt", nolabel replace

/*
IARC crg Tools - see SOP for steps on how to perform below checks:

(1) Perform file transfer using '2015_nonsuvival_iarccrgtools.txt'
(2) Perform check using '2015_iarccrgtools_to check.prn'
(3) Perform multiple primary check using ''

Results of IARC Check Program:
(Titles for each data column: pid sex top morph beh grade basis dot dob age)
    973 records processed
	0 errors
        
	32 warnings
        - 19 unlikely hx/site
		- 2 unlikely grade/hx
        - 10 unlikely basis/hx
		- 1 unlikely age/site/hx
*/
/*	
Results of IARC MP Program:
	21 excluded (non-malignant)
	24 MPs (multiple tumours)
	 0 Duplicate registration
*/
/*
Convert ICD-O-3 DCOs (153) to ICD10, ICCCcode:

*/
** Below updates from warnings/errors report
replace grade=9 if pid=="20151100"
replace grade=9 if pid=="20155222"

** Only report non-duplicate MPs (see IARC MP rules on recording and reporting)
display `"{browse "http://www.iacr.com.fr/images/doc/MPrules_july2004.pdf":IARC-MP}"'
tab persearch ,m
//list pid cr5id if persearch==3 //3

** Updates from multiple primary report (define which is the MP so can remove in survival dataset):
//no updates needed as none to exclude

** Updates from MP exclusion report (excludes in-situ/unreportable cancers)
label drop persearch_lab
label define persearch_lab 0 "Not done" 1 "Done: OK" 2 "Done: MP" 3 "Done: Duplicate" 4 "Done: Non-IARC MP" 5 "Done: IARCcrgTools Excluded", modify
label values persearch persearch_lab
tab beh ,m
replace persearch=5 if beh<3 //21 changes

tab persearch ,m
//list pid cr5id if persearch==2
replace persearch=1 if pid=="20151369" //1 change

** Check DCOs
tab basis ,m
** Re-assign dcostatus for cases with updated death trace-back: still pending as of 19feb2020 TBD by NS
tab dcostatus ,m
replace dcostatus=1 if pid=="20150468" & dcostatus==. //1 change; 0 changes
count if dcostatus==2 & basis!=0
//list pid basis if dcostatus==2 & basis!=0 - autopsy w/ hx
/*
replace basis=1 if pid=="20140672" & cr5id=="T2S1"
replace dcostatus=1 if pid=="20140672" & cr5id=="T2S1"
replace nsdate=d(24jul2018) if pid=="20140672" & cr5id=="T2S1"
*/

** Rename cod in prep for death data matching
rename cod codcancer

** Remove non-residents (see IARC validity presentation)
tab resident ,m //45 missing
label drop resident_lab
label define resident_lab 1 "Yes" 2 "No" 99 "Unknown", modify
label values resident resident_lab
replace resident=99 if resident==9 //45 changes
//list pid natregno nrn addr dd_address if resident==99
replace resident=1 if resident==99 & addr!="99" & addr!="" //29 changes
replace resident=1 if resident==99 & dd_address!="99" & dd_address!="" //0
//replace natregno=nrn if natregno=="" & nrn!="" & resident==99 //3 changes
replace resident=1 if natregno!="" & !(strmatch(strupper(natregno), "*9999*")) //1 change
** Check electoral list and CR5db for those resident=99
//list pid fname lname nrn natregno dob if resident==99
//list pid fname lname addr if resident==99
tab resident ,m //15 unknown

** Check parish
count if parish!=. & parish!=99 & addr=="" //0
count if parish==. & addr!="" & addr!="99" //0
//list pid fname lname natregno parish addr if parish!=. & parish!=99 & addr==""
//bysort pid (cr5id) : replace addr = addr[_n-1] if missing(addr) //1 change - 20140566/

** Check missing sex
tab sex ,m //none missing

** Check for missing age & 100+
tab age ,m //2 missing - none are 100+: f/u was done but age not found
//list pid natregno dd_natregno if age==999

** Check for missing follow-up
label drop slc_lab
label define slc_lab 1 "Alive" 2 "Deceased" 3 "Emigrated" 99 "Unknown", modify
label values slc slc_lab
replace slc=99 if slc==9 //0 changes
tab slc ,m 
** Check missing in CR5db
//list pid if slc==99
count if dlc==. //0
//tab dlc ,m

** Check for non-malignant
tab beh ,m //3 benign; 18 in-situ
replace recstatus=3 if pid=="20151095" & cr5id=="T1S1" //1 change
replace recstatus=3 if pid=="20151221" & cr5id=="T1S1" //1 change
replace recstatus=3 if pid=="20151270" & cr5id=="T1S1" //1 change
tab morph if beh!=3 //18 CIN III

** Check for ineligibles
tab recstatus ,m
drop if recstatus==3 //3 deleted

** Check for duplicate tumours
tab persearch ,m //18 excluded

** Check dob
count if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*9999*")) //0
//list pid natregno if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*-9999*"))

** Check age
gen age2 = (dot - dob)/365.25
gen checkage2=int(age2)
drop age2
count if dob!=. & dot!=. & age!=checkage2 //3; 13
//list pid dot dob age checkage2 cr5id if dob!=. & dot!=. & age!=checkage2
replace age=checkage2 if dob!=. & dot!=. & age!=checkage2 //13 changes

** Check no missing dxyr so this can be used in analysis
tab dxyr ,m //0 missing

** To match with 2014 format, convert names to lower case and strip possible leading/trailing blanks
replace fname = lower(rtrim(ltrim(itrim(fname)))) //0 changes
replace init = lower(rtrim(ltrim(itrim(init)))) //0 changes
//replace mname = lower(rtrim(ltrim(itrim(mname)))) //0 changes
replace lname = lower(rtrim(ltrim(itrim(lname)))) //0 changes

count //1117

** Updates to non-2015 dx
** First check in 2008_2013_2014_cancer_nonsurvival_bnr_reportable.dta if to keep/remove them
count if dxyr!=2015 //43
//list pid cr5id fname lname primarysite morph dxyr slc dlc dot if dxyr!=2015
drop if pid=="20080292"|pid=="20080563"|pid=="20140817"|pid=="20141288" & cr5id=="T1S1" //4 deleted

** Create new site variable with CI5-XI incidence classifications (see chapter 3 Table 3.1. of that volume) based on icd10
display `"{browse "http://ci5.iarc.fr/CI5-XI/Pages/Chapter3.aspx":IARC-CI5-XI-3}"'

rename ICCCcode iccc
rename ICD10 icd10

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
59 "Myeloproliferative disorders (MPD)" 60 "Myelodysplastic syndromes (MDS)" ///
61 "Other and unspecified (O&U)" ///
62 "All sites(ALL)" 63 "All sites but skin (ALLbC44)" ///
64 "D069: CIN 3"
label var siteiarc "IARC CI5-XI sites"
label values siteiarc siteiarc_lab

replace siteiarc=1 if regexm(icd10,"C00") //0 changes
replace siteiarc=2 if (regexm(icd10,"C01")|regexm(icd10,"C02")) //7 changes
replace siteiarc=3 if (regexm(icd10,"C03")|regexm(icd10,"C04")|regexm(icd10,"C05")|regexm(icd10,"C06")) //4 changes
replace siteiarc=4 if (regexm(icd10,"C07")|regexm(icd10,"C08")) //2 changes
replace siteiarc=5 if regexm(icd10,"C09") //4 changes
replace siteiarc=6 if regexm(icd10,"C10") //2 changes
replace siteiarc=7 if regexm(icd10,"C11") //5 changes
replace siteiarc=8 if (regexm(icd10,"C12")|regexm(icd10,"C13")) //0 changes
replace siteiarc=9 if regexm(icd10,"C14") //1 change
replace siteiarc=10 if regexm(icd10,"C15") //12 changes
replace siteiarc=11 if regexm(icd10,"C16") //37 changes
replace siteiarc=12 if regexm(icd10,"C17") //8 changes
replace siteiarc=13 if regexm(icd10,"C18") //117 changes
replace siteiarc=14 if (regexm(icd10,"C19")|regexm(icd10,"C20")) //49 changes
replace siteiarc=15 if regexm(icd10,"C21") //6 changes
replace siteiarc=16 if regexm(icd10,"C22") //7 changes
replace siteiarc=17 if (regexm(icd10,"C23")|regexm(icd10,"C24")) //12 changes
replace siteiarc=18 if regexm(icd10,"C25") //27 changes
replace siteiarc=19 if (regexm(icd10,"C30")|regexm(icd10,"C31")) //2 changes
replace siteiarc=20 if regexm(icd10,"C32") //7 changes
replace siteiarc=21 if (regexm(icd10,"C33")|regexm(icd10,"C34")) //32 changes
replace siteiarc=22 if (regexm(icd10,"C37")|regexm(icd10,"C38")) //1 change
replace siteiarc=23 if (regexm(icd10,"C40")|regexm(icd10,"C41")) //2 changes
replace siteiarc=24 if regexm(icd10,"C43") //10 changes
replace siteiarc=25 if regexm(icd10,"C44") //0 changes
replace siteiarc=26 if regexm(icd10,"C45") //0 changes
replace siteiarc=27 if regexm(icd10,"C46") //0 changes
replace siteiarc=28 if (regexm(icd10,"C47")|regexm(icd10,"C49")) //5 changes
replace siteiarc=29 if regexm(icd10,"C50") //209 changes
replace siteiarc=30 if regexm(icd10,"C51") //2 changes
replace siteiarc=31 if regexm(icd10,"C52") //4 changes
replace siteiarc=32 if regexm(icd10,"C53") //19 changes
replace siteiarc=33 if regexm(icd10,"C54") //46 changes
replace siteiarc=34 if regexm(icd10,"C55") //7 changes
replace siteiarc=35 if regexm(icd10,"C56") //19 changes
replace siteiarc=36 if regexm(icd10,"C57") //2 changes
replace siteiarc=37 if regexm(icd10,"C58") //0 changes
replace siteiarc=38 if regexm(icd10,"C60") //1 change
replace siteiarc=39 if regexm(icd10,"C61") //228 changes
replace siteiarc=40 if regexm(icd10,"C62") //2 changes
replace siteiarc=41 if regexm(icd10,"C63") //0 changes
replace siteiarc=42 if regexm(icd10,"C64") //17 changes
replace siteiarc=43 if regexm(icd10,"C65") //0 changes
replace siteiarc=44 if regexm(icd10,"C66") //1 change
replace siteiarc=45 if regexm(icd10,"C67") //17 changes
replace siteiarc=46 if regexm(icd10,"C68") //1 change
replace siteiarc=47 if regexm(icd10,"C69") //2 changes
replace siteiarc=48 if (regexm(icd10,"C70")|regexm(icd10,"C71")|regexm(icd10,"C72")) //11 changes
replace siteiarc=49 if regexm(icd10,"C73") //12 changes
replace siteiarc=50 if regexm(icd10,"C74") //0 changes
replace siteiarc=51 if regexm(icd10,"C75") //0 changes
replace siteiarc=52 if regexm(icd10,"C81") //6 changes
replace siteiarc=53 if (regexm(icd10,"C82")|regexm(icd10,"C83")|regexm(icd10,"C84")|regexm(icd10,"C85")|regexm(icd10,"C86")|regexm(icd10,"C96")) //30 changes
replace siteiarc=54 if regexm(icd10,"C88") //0 changes
replace siteiarc=55 if regexm(icd10,"C90") //32 changes
replace siteiarc=56 if regexm(icd10,"C91") //5 changes
replace siteiarc=57 if (regexm(icd10,"C92")|regexm(icd10,"C93")|regexm(icd10,"C94")) //6 changes
replace siteiarc=58 if regexm(icd10,"C95") //4 changes
replace siteiarc=59 if morphcat==54|morphcat==55 //6 changes
replace siteiarc=60 if morphcat==56 //6 changes
replace siteiarc=61 if (regexm(icd10,"C26")|regexm(icd10,"C39")|regexm(icd10,"C48")|regexm(icd10,"C76")|regexm(icd10,"C80")) //40 changes
**replace siteiarc=62 if siteiarc<62
**replace siteiarc=63 if siteiarc<62 & siteiarc!=25
replace siteiarc=64 if morph==8077 //18 changes

tab siteiarc ,m //1 missing
//list pid cr5id primarysite top hx morph icd10 if siteiarc==.
replace iccc="11f" if pid=="20150298" & cr5id=="T1S1" //1 change
replace icd10="C059" if pid=="20150298" & cr5id=="T1S1" //1 change
replace siteiarc=3 if pid=="20150298" & cr5id=="T1S1" //1 change

gen allsites=1 if siteiarc<62 //951 changes - 18 missing values=CIN 3
label var allsites "All sites (ALL)"

gen allsitesbC44=1 if siteiarc<62 & siteiarc!=25
//951 changes - 18 missing values=CIN 3
label var allsitesbC44 "All sites but skin (ALLbC44)"

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
replace siteiarchaem=1 if morphcat==41 //7 changes
replace siteiarchaem=2 if morphcat==42 //6 changes
replace siteiarchaem=3 if morphcat==43 //16 changes
replace siteiarchaem=4 if morphcat==44 //5 changes
replace siteiarchaem=5 if morphcat==45 //1 change
replace siteiarchaem=6 if morphcat==46 //32 changes
replace siteiarchaem=7 if morphcat==47 //0 changes
replace siteiarchaem=8 if morphcat==48 //0 changes
replace siteiarchaem=9 if morphcat==49 //0 changes
replace siteiarchaem=10 if morphcat==50 //4 changes
replace siteiarchaem=11 if morphcat==51 //5 changes
replace siteiarchaem=12 if morphcat==52 //6 changes
replace siteiarchaem=13 if morphcat==53 //0 changes
replace siteiarchaem=14 if morphcat==54 //5 changes
replace siteiarchaem=15 if morphcat==55 //1 change
replace siteiarchaem=16 if morphcat==56 //6 changes

tab siteiarchaem ,m //882 missing - correct!
count if (siteiarc>51 & siteiarc<59) & siteiarchaem==. //1
//list pid cr5id primarysite top hx morph morphcat iccc icd10 if (siteiarc>51 & siteiarc<59) & siteiarchaem==.
replace iccc="12b" if pid=="20159040" & cr5id=="T1S1" //0 changes
replace icd10="C80" if pid=="20159040" & cr5id=="T1S1" //1 change
replace siteiarchaem=15 if pid=="20159040" & cr5id=="T1S1" //1 change


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
31 "Myelodysplastic syndromes (MDS)" ///
32 "D069: CIN 3" ///
33 "Eye,Heart,etc (C69,C38)" ///
34 "All sites but C44"
label var sitecr5db "CR5db sites"
label values sitecr5db sitecr5db_lab

replace sitecr5db=1 if (regexm(icd10,"C00")|regexm(icd10,"C01")|regexm(icd10,"C02") ///
					 |regexm(icd10,"C03")|regexm(icd10,"C04")|regexm(icd10,"C05") ///
					 |regexm(icd10,"C06")|regexm(icd10,"C07")|regexm(icd10,"C08") ///
					 |regexm(icd10,"C09")|regexm(icd10,"C10")|regexm(icd10,"C11") ///
					 |regexm(icd10,"C12")|regexm(icd10,"C13")|regexm(icd10,"C14")) //26 changes
replace sitecr5db=2 if regexm(icd10,"C15") //12 changes
replace sitecr5db=3 if regexm(icd10,"C16") //37 changes
replace sitecr5db=4 if (regexm(icd10,"C18")|regexm(icd10,"C19")|regexm(icd10,"C20")|regexm(icd10,"C21")) //172 changes
replace sitecr5db=5 if regexm(icd10,"C22") //7 changes
replace sitecr5db=6 if regexm(icd10,"C25") //27 changes
replace sitecr5db=7 if regexm(icd10,"C32") //7 changes
replace sitecr5db=8 if (regexm(icd10,"C33")|regexm(icd10,"C34")) //32 changes
replace sitecr5db=9 if regexm(icd10,"C43") //10 changes
replace sitecr5db=10 if regexm(icd10,"C50") //209 changes
replace sitecr5db=11 if regexm(icd10,"C53") //19 changes
replace sitecr5db=12 if (regexm(icd10,"C54")|regexm(icd10,"C55")) //53 changes
replace sitecr5db=13 if regexm(icd10,"C56") //19 changes
replace sitecr5db=14 if regexm(icd10,"C61") //228 changes
replace sitecr5db=15 if regexm(icd10,"C62") //2 changes
replace sitecr5db=16 if (regexm(icd10,"C64")|regexm(icd10,"C65")|regexm(icd10,"C66")|regexm(icd10,"C68")) //19 changes
replace sitecr5db=17 if regexm(icd10,"C67") //17 changes
replace sitecr5db=18 if (regexm(icd10,"C70")|regexm(icd10,"C71")|regexm(icd10,"C72")) //11 changes
replace sitecr5db=19 if regexm(icd10,"C73") //12 changes
replace sitecr5db=20 if siteiarc==61 //40 changes
replace sitecr5db=21 if (regexm(icd10,"C81")|regexm(icd10,"C82")|regexm(icd10,"C83")|regexm(icd10,"C84")|regexm(icd10,"C85")|regexm(icd10,"C88")|regexm(icd10,"C90")|regexm(icd10,"C96")) //67 changes
replace sitecr5db=22 if (regexm(icd10,"C91")|regexm(icd10,"C92")|regexm(icd10,"C93")|regexm(icd10,"C94")|regexm(icd10,"C95")) //15 changes
replace sitecr5db=23 if (regexm(icd10,"C17")|regexm(icd10,"C23")|regexm(icd10,"C24")) //20 changes
replace sitecr5db=24 if (regexm(icd10,"C30")|regexm(icd10,"C31")) //2 changes
replace sitecr5db=25 if (regexm(icd10,"C40")|regexm(icd10,"C41")|regexm(icd10,"C45")|regexm(icd10,"C47")|regexm(icd10,"C49")) //7 changes
replace sitecr5db=26 if siteiarc==25 //0 changes
replace sitecr5db=27 if (regexm(icd10,"C51")|regexm(icd10,"C52")|regexm(icd10,"C57")|regexm(icd10,"C58")) //8 changes
replace sitecr5db=28 if (regexm(icd10,"C60")|regexm(icd10,"C63")) //1 change
replace sitecr5db=29 if (regexm(icd10,"C74")|regexm(icd10,"C75")) //0 changes
replace sitecr5db=30 if siteiarc==59 //6 changes
replace sitecr5db=31 if siteiarc==60 //6 changes
replace sitecr5db=32 if siteiarc==64 //18 changes
replace sitecr5db=33 if (regexm(icd10,"C38")|regexm(icd10,"C69")) //3 changes

tab sitecr5db ,m
//list pid cr5id top morph icd10 if sitecr5db==.
replace sitecr5db=21 if pid=="20159040" & cr5id=="T1S1" //1 change


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
					 |regexm(icd10,"C12")|regexm(icd10,"C13")|regexm(icd10,"C14")) //26 changes
replace siteicd10=2 if (regexm(icd10,"C15")|regexm(icd10,"C16")|regexm(icd10,"C17") ///
					 |regexm(icd10,"C18")|regexm(icd10,"C19")|regexm(icd10,"C20") ///
					 |regexm(icd10,"C21")|regexm(icd10,"C22")|regexm(icd10,"C23") ///
					 |regexm(icd10,"C24")|regexm(icd10,"C25")|regexm(icd10,"C26")) //280 changes
replace siteicd10=3 if (regexm(icd10,"C30")|regexm(icd10,"C31")|regexm(icd10,"C32")|regexm(icd10,"C33")|regexm(icd10,"C34")|regexm(icd10,"C37")|regexm(icd10,"C38")|regexm(icd10,"C39")) //42 changes
replace siteicd10=4 if (regexm(icd10,"C40")|regexm(icd10,"C41")) //2 changes
replace siteicd10=5 if siteiarc==24 //10 changes
replace siteicd10=6 if siteiarc==25 //0 changes
replace siteicd10=7 if (regexm(icd10,"C45")|regexm(icd10,"C46")|regexm(icd10,"C47")|regexm(icd10,"C48")|regexm(icd10,"C49")) //6 changes
replace siteicd10=8 if regexm(icd10,"C50") //209 changes
replace siteicd10=9 if (regexm(icd10,"C51")|regexm(icd10,"C52")|regexm(icd10,"C53")|regexm(icd10,"C54")|regexm(icd10,"C55")|regexm(icd10,"C56")|regexm(icd10,"C57")|regexm(icd10,"C58")) //99 changes
replace siteicd10=10 if regexm(icd10,"C61") //228 changes
replace siteicd10=11 if (regexm(icd10,"C60")|regexm(icd10,"C62")|regexm(icd10,"C63")) //3 changes
replace siteicd10=12 if (regexm(icd10,"C64")|regexm(icd10,"C65")|regexm(icd10,"C66")|regexm(icd10,"C67")|regexm(icd10,"C68")) //36 changes
replace siteicd10=13 if (regexm(icd10,"C69")|regexm(icd10,"C70")|regexm(icd10,"C71")|regexm(icd10,"C72")) //13 changes
replace siteicd10=14 if (regexm(icd10,"C73")|regexm(icd10,"C74")|regexm(icd10,"C75")) //12 changes
replace siteicd10=15 if (regexm(icd10,"C76")|regexm(icd10,"C77")|regexm(icd10,"C78")|regexm(icd10,"C79")) //0 changess
replace siteicd10=16 if regexm(icd10,"C80") //35 changes
replace siteicd10=17 if (regexm(icd10,"C81")|regexm(icd10,"C82")|regexm(icd10,"C83") ///
					 |regexm(icd10,"C84")|regexm(icd10,"C85")|regexm(icd10,"C86") ///
					 |regexm(icd10,"C87")|regexm(icd10,"C88")|regexm(icd10,"C89") ///
					 |regexm(icd10,"C90")|regexm(icd10,"C91")|regexm(icd10,"C92") ///
					 |regexm(icd10,"C93")|regexm(icd10,"C94")|regexm(icd10,"C95")|regexm(icd10,"C96")) //82 changes


tab siteicd10 ,m // missing - CIN3, beh /0,/1,/2 and MPDs
//list pid cr5id top morph icd10 if siteicd10==.

** Check non-2015 dxyrs are reportable
count if resident==2 & dxyr!=2015 //0
count if resident==99 & dxyr!=2015 //0
count if recstatus==3 & dxyr!=2015 //0
count if sex==9 & dxyr!=2015 //0
count if beh!=3 & dxyr!=2015 //0
count if persearch>2 & dxyr!=2015 //0
count if siteiarc==25 & dxyr!=2015 //0
** Remove non-reportable-non-2015 dx
//none to be removed

tab dxyr ,m

** Check parish
count if parish!=. & parish!=99 & addr=="" //0
count if parish==. & addr!="" & addr!="99" //0
//list pid fname lname natregno parish addr if parish!=. & parish!=99 & addr==""

** Check missing sex
tab sex ,m //none missing

** Check for missing age & 100+
tab age ,m //3 missing - 4 are 100+; 2 are 0 age

** Check for missing follow-up
tab slc ,m //none missing
tab deceased ,m //none missing and parallels slc correctly
//tab dlc ,m //none missing
** Check missing in CR5db
//list pid if slc==99

** Check DCOs
tab basis ,m //146; 267; 272
** Re-assign dcostatus for cases with updated death trace-back
tab dcostatus ,m
//list pid basis dcostatus if basis==0 & dcostatus!=2
count if basis!=0 & dcostatus==2 //4-correct as autop w/ hx
replace dcostatus=2 if basis==0
//list pid cr5id basis dcostatus if basis!=0 & dcostatus==2

replace dcostatus=1 if slc==2 & basis!=0 //33; 35; 65 changes
replace dcostatus=6 if slc!=2 //0 changes
replace dcostatus=2 if basis==0 //0 changes

** Check for ineligibles
tab recstatus ,m //0 ineligible

** Check for non-malignant
tab beh ,m
/*
  Behaviour |      Freq.     Percent        Cum.
------------+-----------------------------------
     Benign |          8        0.20        0.20
  Uncertain |         10        0.25        0.44
    In situ |        134        3.30        3.74
  Malignant |      3,908       96.26      100.00
------------+-----------------------------------
      Total |      4,060      100.00
*/

** Check for duplicate tumours
tab persearch ,m //56; 60 MPs; 0 dups; 18 excluded (in-situ)

** Check dob
count if dob==. //27; 37; 156 -all missing natregno
//list pid cr5id age natregno nrn birthdate if dob==.
//count if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*99-*")) //0
//list pid age natregno if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*99-*"))
/*
gen birthd=substr(natregno,1,6) if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*99-*"))
destring birthd, replace
format birthd %06.0f
nsplit birthd, digits(2 2 2) gen(year month day)
format year month day %02.0f
tostring year, replace
replace year="19"+year
destring year, replace
gen dob2=mdy(month, day, year)
format dob2 %dD_m_CY
replace dob=dob2 if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*99-*")) //47 changes
drop birthd year month day dob2
*/

** Check age
gen age2 = (dot - dob)/365.25
drop checkage2
gen checkage2=int(age2)
drop age2
count if dob!=. & dot!=. & age!=checkage2 //1
//list pid dot dob age checkage2 cr5id if dob!=. & dot!=. & age!=checkage2 //0 correct
replace age=checkage2 if dob!=. & dot!=. & age!=checkage2 //1 change

** Check no missing dxyr so this can be used in analysis
tab dxyr ,m 
/*
DiagnosisYe |
         ar |      Freq.     Percent        Cum.
------------+-----------------------------------
       2008 |      1,217       29.98       29.98
       2013 |        883       21.75       51.72
       2014 |        898       22.12       73.84
       2015 |      1,062       26.16      100.00
------------+-----------------------------------
      Total |      4,060      100.00
*/

** Check for missing for cancer field
/*
replace natregno=subinstr(natregno,"-","",.)
rename address address_cancer
replace addr=subinstr(addr,"9999 ","",.)
replace addr=subinstr(addr,"99 ","",.)
count if regexm(address,"99") //0 - didn't replace true value for house #=99
rename cod1a cod1a_cancer
*/
count if cancer==. & slc==2 //47
//list pid deathid fname lname natregno dod if cancer==. & slc==2
tab notindd dxyr,m
count if cancer==. & slc==2 & notindd==. //34; 33
replace notindd=1 if cancer==. & slc==2 & notindd==. //34; 33 changes
count if cancer==1 & slc==2 & notindd==. //1781; 1794; 1964; 2006
replace notindd=2 if cancer==1 & slc==2 & notindd==. //1781; 1794; 1964; 2006 changes
count if cancer==2 & slc==2 & notindd==. //165; 164; 220
replace notindd=2 if cancer==2 & slc==2 & notindd==. //165; 164; 220 changes
count if notindd==. & slc!=2 //1339; 1784
/*
gen notindd=1 if cancer==. & slc==2 //14
replace notindd=2 if pid=="20130331"|pid=="20080885"
label var notindd "Not found in death data"
label define notindd_lab 1 "Searched, not found" 2 "Searched, found", modify
label values notindd notindd_lab
*/
count if cancer!=. & slc!=2 //0
//list pid deathid fname lname natregno dod if cancer!=. & slc!=2
replace cancer=. if cancer!=. & slc!=2 //387; 0 changes

** Update cancer variable if cod indicates cancer (check against 2008-2020 death data file)
count if cancer==. & slc==2 //47
//list pid deathid fname lname dd_coddeath if cancer==. & slc==2, string(100)
replace cod1a_cancer="REFRACTORY MULTIPLE MYELOMA ACUTE CONGESTIVE CARDIAC FAILURE CARDIAC AMYLOIDOSIS" if pid=="20150005"
replace cod1a_cancer="ASPIRATION PNEUMONIA DYSPHAGIA MULTIPLE MYELOMA" if pid=="20150007"
replace cod1a_cancer="REFRACTORY MULTIPLE MYELOMA" if pid=="20150031"
replace cod1a_cancer=cr5cod if cancer==. & slc==2 & cod1a_cancer=="" & cr5cod!="" //37 changes
label define cancer 1 "cancer" 2 "not cancer" 3 "unknown" ,modify
replace cancer=3 if cancer==. & slc==2 & cod1a_cancer=="99" //15 changes
replace cancer=1 if cancer==. & slc==2 //32 changes


** Check missing for cod field
count if cod==. & slc==2 //2175; 2274
count if dd_cod==. & slc==2 //2113; 2212
replace cod=dd_cod if dd_cod!=. & cod==. //63 changes
count if cod==. & slc==2 //2112; 2211
replace cod=1 if cancer==1 //1944; 1986 changes
replace cod=2 if cancer==2 //154; 210 changes
** one unknown causes of death in 2014 data - record_id 12323
replace cod=3 if cod1a_cancer=="99"|(regexm(cod1a_cancer,"INDETERMINATE")|regexm(cod1a_cancer,"UNDETERMINED")) //14; 15 changes
count if cod==. & slc==2 //0


count if slc==2 & dod==. //0
drop dodyear
gen dodyear_cancer=year(dod)
tab dodyear ,m
count if slc!=2 & dod!=. //0

drop dotyear
gen dotyear=year(dot)
tab dotyear ,m
/*
    dotyear |      Freq.     Percent        Cum.
------------+-----------------------------------
       2008 |      1,217       29.98       29.98
       2013 |        883       21.75       51.72
       2014 |        898       22.12       73.84
       2015 |      1,062       26.16      100.00
------------+-----------------------------------
      Total |      4,060      100.00
*/

** Check dot
count if dot>dlc //1
//list pid cr5id dot dlc if dot>dlc
replace dlc=d(07feb2013) if pid=="20080340"


** Check resident=yes if there's a local address (added on 12-Oct-2020 based on feedback from SF: see IARC, IARC-HUB, SEER publications)
count if resident!=1 & addr!="" & addr!="99" //6
//list pid fname lname resident addr if resident!=1 & addr!="" & addr!="99"
replace resident=1 if pid=="20081112"
replace resident=1 if pid=="20130397"
//replace resident=1 if pid=="20140456" - addr listed as QEH
replace resident=1 if pid=="20140545"
replace resident=1 if pid=="20140563"
//replace resident=1 if pid=="20140608" - addr listed as a guest house

*/

** JC 26-Oct-2020: For quality assessment by IARC Hub, save this corrected dataset with all malignant + non-malignant tumours 2008, 2013-2015
** See p131 version06 for more info on this data request
save "`datapath'\version02\3-output\2008_2013_2014_2015_iarchub_nonsurvival_nonreportable", replace
label data "2008 2013 2014 2015 BNR-Cancer analysed data - Non-survival Dataset for IARC Hub's Data Request"
note: TS This dataset was used for data prep for IARC Hub's quality assessment (see p131 v06)
note: TS Excludes ineligible case definition
note: TS Includes unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs

** Removing cases not included for reporting: if case with MPs ensure record with persearch=1 is not dropped as used in survival dataset
drop if resident==2 //4 deleted - nonresident
drop if resident==99 //40 deleted - resident unknown
drop if recstatus==3 //0 deleted - ineligible case definition
drop if sex==9 //0 deleted - sex unknown
drop if beh!=3 //51 deleted - non malignant
drop if persearch>2 //3 deleted
drop if siteiarc==25 //0 - non reportable skin cancers

** Check for cases wherein the non-reportable cancer had the below MP categories as the primary options
tag duplicate pid
using tag check if patient=separate event for a single pid
same for eidmp ptrectot

** JC 03-Jun-2021: For quality assessment by IARC Hub, save this corrected dataset with all malignant (non-reportable skin + non-malignant tumours removed) for 2008, 2013-2015
** See p131 version06 for more info on this data request
save "`datapath'\version02\3-output\2008_2013_2014_2015_iarchub_nonsurvival_reportable", replace
label data "2008 2013 2014 2015 BNR-Cancer analysed data - Non-survival Dataset for IARC Hub's Data Request"
note: TS This dataset was used for data prep for IARC Hub's quality assessment (see p131 v06)
note: TS Excludes ineligible case definition
note: TS Excludes ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs

** For 2015 annaul report remove 2008 cases as decided by NS on 06-Oct-2020, email subject: BNR-C: 2015 cancer stats tables completed
drop if dxyr==2008


** Removing cases not included for reporting: if case with MPs ensure record with persearch=1 is not dropped as used in survival dataset
**drop dup_id
sort pid
duplicates tag pid, gen(dup_id)
list pid cr5id patient eidmp persearch if dup_id>0, nolabel sepby(pid)
drop if resident==2 //4 deleted - nonresident
drop if resident==99 //40 deleted - resident unknown
drop if recstatus==3 //0 deleted - ineligible case definition
drop if sex==9 //0 deleted - sex unknown
drop if beh!=3 //51 deleted - non malignant
drop if persearch>2 //3 deleted
drop if siteiarc==25 //0 - non reportable skin cancers
drop dup_id

count //3484; 3488; 2744

capture export_excel using "`datapath'\version02\3-output\2013-2015BNRnonsurvivalV05.xlsx", sheet("2013_2014_2015_20210727") firstrow(varlabels) replace

** Save this corrected dataset with internationally reportable cases
save "`datapath'\version02\3-output\2013_2014_2015_cancer_nonsurvival", replace
label data "2013 2014 2015 BNR-Cancer analysed data - Non-survival Dataset"
note: TS This dataset was used for 2015 annual report
note: TS Excludes ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs

/*
********************
** Death Matching **
**  with CF data  **
********************

** To reduce the # of DCOs and trace-back I performed below on data from MasterDb
** Check CF data to see if any match with unmatched 2015 death certificates (aim: to reduce DCO %)
use "`datapath'\version02\2-working\2015_death certificates_DCOs" ,clear
gen dco_deaths=1
count //163

preserve
use "`datapath'\version02\2-working\2015_cancer_nonsurvival" ,clear
drop if basis!=0 & basis!=. //891 deleted
gen dco_cancer=1
count //13
save "`datapath'\version02\2-working\2015_cancer_DCOs" ,replace
restore

append using "`datapath'\version02\2-working\2015_cancer_DCOs"

count //176

preserve
clear

import excel using "`datapath'\version02\1-input\20200220tblCaseFinding.xlsx", firstrow
rename No cfid_2008
rename FirstName fname
rename LastName lname
rename Age age
rename Sex sex
rename AbstrStatus absstatus
rename NRN natregno
rename NFDxYear cfdxyr
rename Comments comments_2008
replace natregno=subinstr(natregno,"-","",.)
replace fname = lower(rtrim(ltrim(itrim(fname))))
replace lname = lower(rtrim(ltrim(itrim(lname))))
replace absstatus="0" if absstatus=="Pending"
replace absstatus="1" if regexm(absstatus,"Abstracted -")|absstatus=="Abstracted"
replace absstatus="2" if regexm(absstatus,"Ineligible")
replace absstatus="3" if absstatus=="Not Abstracted"
destring absstatus ,replace
label define absstatus_lab 0 "pending" 1 "abstracted" 2 "abstracted-ineligible" 3 "not abstracted" , modify
label values absstatus absstatus_lab
keep cfid_2008 fname lname age sex natregno absstatus comments_2008 cfdxyr
count //4821
save "`datapath'\version02\2-working\2008_cancer_CF" ,replace
restore

preserve
clear
import excel using "`datapath'\version02\1-input\20200220tblCaseFinding_2009.xlsx", firstrow
rename No cfid_2013
rename FirstName fname
rename LastName lname
rename Age age
rename Sex sex
rename AbstrStatus absstatus
rename NRN natregno
rename DxYear cfdxyr
rename Comments comments_2013
replace natregno=subinstr(natregno,"-","",.)
replace fname = lower(rtrim(ltrim(itrim(fname))))
replace lname = lower(rtrim(ltrim(itrim(lname))))
replace absstatus="0" if absstatus=="Pending"
replace absstatus="1" if regexm(absstatus,"Abstracted -")|absstatus=="Abstracted"
replace absstatus="2" if regexm(absstatus,"Ineligible")
replace absstatus="3" if absstatus=="Not Abstracted"
destring absstatus ,replace
label define absstatus_lab 0 "pending" 1 "abstracted" 2 "abstracted-ineligible" 3 "not abstracted" , modify
label values absstatus absstatus_lab
keep cfid_2013 fname lname age sex natregno absstatus comments_2013 cfdxyr
count //4171
save "`datapath'\version02\2-working\2013_cancer_CF" ,replace
restore

preserve
clear
import excel using "`datapath'\version02\1-input\20200220tblCF_2014.xlsx", firstrow
rename cfid cfid_2014
rename abstatus absstatus
rename dxyear cfdxyr
rename comments comments_2014
replace natregno=subinstr(natregno,"-","",.)
replace fname = lower(rtrim(ltrim(itrim(fname))))
replace lname = lower(rtrim(ltrim(itrim(lname))))
replace absstatus="0" if absstatus=="Pending"
replace absstatus="1" if regexm(absstatus,"Abstracted -")|absstatus=="Abstracted"
replace absstatus="2" if regexm(absstatus,"Ineligible")
replace absstatus="3" if absstatus=="Not Abstracted"
destring absstatus ,replace
label define absstatus_lab 0 "pending" 1 "abstracted" 2 "abstracted-ineligible" 3 "not abstracted" , modify
label values absstatus absstatus_lab
keep cfid_2014 fname lname age sex natregno absstatus comments_2014 cfdxyr
count //788
save "`datapath'\version02\2-working\2014_cancer_CF" ,replace
append using "`datapath'\version02\2-working\2008_cancer_CF"
count //5609
append using "`datapath'\version02\2-working\2013_cancer_CF"

replace sex="1" if sex=="Female"
replace sex="2" if sex=="Male"
replace sex="99" if sex=="Not Stated"
destring sex ,replace
label define sex_lab 1 "Female" 2 "Male" 99 "ND" , modify
label values sex sex_lab

count //9780
save "`datapath'\version02\2-working\2008_2013_2014_cancer_CF" ,replace
restore

drop _merge
merge m:m fname lname using "`datapath'\version02\2-working\2008_2013_2014_cancer_CF"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         9,915
        from master                       162  (_merge==1)
        from using                      9,753  (_merge==2)

    matched                                27  (_merge==3)
    -----------------------------------------
*/
count //9942

//list pid record_id cfid_* fname lname absstatus cfdxyr dxyr comments_* if _merge==3 ,string(80)

drop duppt
sort lname fname record_id pid
quietly by lname fname :  gen duppt = cond(_N==1,0,_n)
sort lname fname
count if duppt>0 //7021
sort lname fname pid record_id
//list pid record_id fname lname natregno dotyear dodyear if duppt>0 //only CR5 records

//list pid record_id cfid_* fname lname absstatus cfdxyr dxyr comments_2008 comments_2013 if _merge==3 ,string(25)

replace cr5db=1 if dco_deaths==1 & cr5db==. & _merge==3 //25 changes
replace cr5db=1 if dco_cancer==1 & cr5db==. & _merge==3 //2 changes

drop if cr5db!=1 //9915 deleted
count //27

//capture export_excel pid record_id cfid_2008 cfid_2013 cfid_2014 fname lname absstatus cfdxyr comments_2008 comments_2013 if cr5db==1 using "`datapath'\version02\2-working\CFFoundDCO2015V01.xlsx", sheet("2015DCOs_death&cr5_20200220") firstrow(variables)  replace
//JC remember to change V01 to V02 when running list a 2nd time!

save "`datapath'\version02\2-working\CF_matched_2015DCOs" ,replace
