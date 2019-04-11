** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			3_2008_2013_dc_v01.do
    //  project:				BNR
    //  analysts:				Jacqueline CAMPBELL
    //  date first created      19-MAR-2019
    // 	date last modified	    19-MAR-2019
    //  algorithm task			Cleaning 2008 & 2013 cancer datasets, Creating site groupings
    //  release version         v01: using CanReg5 BNR-CLEAN 18-Mar-2019 dataset
    //  status                  Completed
    //  objectve                To have one dataset with cleaned and grouped 2008 data for inclusion in 2014 cancer report.


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
    log using "`logpath'\3_2008_2013_dc.smcl", replace
** HEADER -----------------------------------------------------

* ***************************************************************************************************************
* MERGING
* Using cancer dataset and death dataset
* (1) merge using nrn
*****************************************************************************************************************

** Load the dataset with recently matched death data
use "`datapath'\version01\2-working\2008_2013_cancer_dp", clear

count //2,608


** Corrections based on updates already found when doing cleaning for NAACCR-IACR 
** (some may already be corrected as using different dataset than the one originally used that found these errors)
replace natregno="210620-0062" if pid=="20080497"
replace natregno="201130-0080" if pid=="20080730"
replace natregno="260722-7002" if pid=="20080457"
replace natregno="250323-0068" if pid=="20081054"
replace natregno="341125-0024" if pid=="20080305"
replace natregno="430906-7017" if pid=="20080739"
replace natregno="250612-8012" if pid=="20080738"
replace natregno="270715-0039" if pid=="20080462"
replace natregno="500612-8002" if pid=="20080686"
replace natregno="240612-0010" if pid=="20080484"
replace natregno="340429-0011" if pid=="20080353"
replace natregno="200830-0093" if pid=="20080416"
replace natregno="300620-0046" if pid=="20080043"
replace natregno="250312-0012" if pid=="20080434"
replace natregno="310330-0038" if pid=="20081064"
replace natregno="250808-0104" if pid=="20080432"
replace natregno="300408-0010" if pid=="20080472"
replace natregno="170830-8000" if pid=="20080435"
replace natregno="360916-0068" if pid=="20080543"
replace natregno="360713-8033" if pid=="20080410"
replace natregno="300902-0011" if pid=="20080578"
replace natregno="471204-0015" if pid=="20080341"
replace natregno="430601-8054" if pid=="20080719"
replace natregno="321017-0076" if pid=="20080327"
replace natregno="220929-0051" if pid=="20080775"
replace natregno="270112-0038" if pid=="20080576"

replace natregno="441219-0078" if pid=="20130772"
replace natregno="430916-0127" if pid=="20130361"
replace natregno="290210-0134" if pid=="20130396"
replace natregno="470831-0059" if pid=="20130886"
replace natregno="460928-0146" if pid=="20130814"
replace natregno="461123-0063" if pid=="20130818"
replace natregno="190511-0027" if pid=="20130661"
replace natregno="421121-9999" if pid=="20130650"
replace natregno="560725-0072" if pid=="20130696"
replace natregno="471124-0012" if pid=="20130830"
replace natregno="300608-0059" if pid=="20130362"
replace natregno="841016-0041" if pid=="20130674"
replace natregno="610630-0103" if pid=="20130631"
replace natregno="370126-0030" if pid=="20130426"
replace natregno="490110-0091" if pid=="20130813"
replace natregno="450902-0022" if pid=="20130374"
replace natregno="440214-0018" if pid=="20130874"
replace natregno="280214-0042" if pid=="20130319"

replace natregno="190923-0052" if pid=="20080421"
replace natregno="590829-9999" if pid=="20080177"
replace natregno="291003-0077" if pid=="20080344"
replace natregno="430715-0054" if pid=="20080766"
replace natregno="240826-0038" if pid=="20080465"
replace natregno="320518-0056" if pid=="20080592"
replace natregno="230104-0040" if pid=="20080301"
replace natregno="221127-0018" if pid=="20080377"
replace natregno="221219-0066" if pid=="20080654"
replace natregno="320402-7019" if pid=="20080450"
replace natregno="491113-0039" if pid=="20081109"
replace natregno="250906-0022" if pid=="20080461"
replace natregno="310705-0050" if pid=="20080533"
replace natregno="361011-0078" if pid=="20080504"
replace natregno="210130-0107" if pid=="20080476"
replace natregno="120821-8006" if pid=="20080385"
replace natregno="220708-9999" if pid=="20080205"
replace natregno="360722-7034" if pid=="20080720"
replace natregno="300818-7001" if pid=="20080740"

replace natregno="321016-0069" if pid=="20080494"
replace natregno="331130-0150" if pid=="20080978"
replace natregno="371114-0016" if pid=="20080965"
replace natregno="570327-0065" if pid=="20080001"

count //2,608

** In prep for merge, remove nrn variable as this a repeat of natregno
rename natregno nrn

merge m:1 nrn using "`datapath'\version01\2-working\2008-2017_redcap_deaths_nrn_dp"
/*
POST-CORRECTIONS
    Result                           # of obs.
    -----------------------------------------
    not matched                        22,199
        from master                     1,339  (_merge==1)
        from using                     20,860  (_merge==2)

    matched                             1,269  (_merge==3)
    -----------------------------------------
*/

** Check all merges are correct by comparing patient name in cancer dataset with patient name in death dataset
count if _merge==3 //1,290
//list pid deathid fname lname pname if _merge==3 ,notrim

gen pnameextra=fname+" "+lname
count if _merge==3 & pname!=pnameextra //408 - corrected in dofiles 2 and 3 and redcap db so now count==385 which are correct
//list pid deathid pname* if _merge==3 & pname!=pnameextra

** Remove unmatched deaths (didn't merge)
count if pid=="" //20,860
drop if pid=="" //20,860 deleted

rename nrn natregno

count //2,608

** Checking if any 2014 cancers didn't merge with deaths when cleaning done (see 2014 cleaning dofile '5_merge_cancer_dc.do' and BNR-CLEAN CanReg5 db)
count if slc!=2 & dod!=. //300
//list pid deathid slc dod if slc!=2 & dod!=.
replace slc=2 if slc!=2 & dod!=. //300 changes
sort pid
//list pid fname lname dod dxyr recstatus cr5id if slc==2
//list pid fname lname dod dxyr recstatus cr5id if slc==2 & (dxyr==2014|dxyr==.) //all 2014 cases were merged in previous dofile 5 above


* ************************************************************************
* CLEANING
* Using version02 dofiles created in 2014 data review folder (Sync) as 
* this previously flagged (not corrected) errors in 2008 & 2013 data that
* were then updated in BNR-CLEAN CanReg5 db by Shelly Forde.
**************************************************************************
/* 
Remove duplicates - first identify & label duplicate tumour and sources

Each multiple sources from CR5 dataset is imported into Stata as 
a separate observation and some tumour records are multiple sources for the abstracted tumour
so need to differentiate between 
multiple (duplicate) sources (MSs) for same pt vs multiple (primary) tumours (MPs) for same pt:
(1) The MSs will assessed for data quality index then dropped before death merge;
(2) The MPs will be kept throughout datasets.
*/
gen dupsource=0 //2,608
label var dupsource "Multiple Sources"
label define dupsource_lab  1 "MS-Conf Tumour Rec" 2 "MS-Conf Source Rec" ///
							3 "MS-Dup Tumour Rec" 4 "MS-Dup Tumour & Source Rec" ///
							5 "MS-Ineligible Tumour 1 Rec" 6 "MS-Ineligible Tumour 2~ & Source Rec" , modify
label values dupsource dupsource_lab

replace dupsource=1 if recstatus==1 & regexm(cr5id,"S1") //2,040 - this is the # eligible non-duplicate tumours
replace dupsource=2 if recstatus==1 & !strmatch(strupper(cr5id), "*S1") //136
replace dupsource=3 if recstatus==4 & regexm(cr5id,"S1") //160
replace dupsource=4 if recstatus==4 & !strmatch(strupper(cr5id), "*S1") //3
replace dupsource=5 if recstatus==3 & cr5id=="T1S1" //126
replace dupsource=6 if recstatus==3 & cr5id!="T1S1" //134

** Now identify MPs (multiple tumours for same pt) among eligible non-duplicate tumours (921; 955)
tab pid if dupsource==1

sort pid
bysort pid: gen duppid = _n if dupsource==1 //568 missing values so 2,040 changes

sort pid
bysort pid: gen duppid_all = _n

tab duppid_all ,m
sort lname fname pid

** Based on cr5id and dupsource, create variable to identify MPs
gen eidmp=1 if regexm(cr5id, "T1") & dupsource==1 //699 missing values - 1,909 changes
replace eidmp=2 if !strmatch(strupper(cr5id), "T1*") & dupsource==1 //131 changes
label var eidmp "CR5 tumour events"
label define eidmp_lab 1 "single tumour" 2 "multiple tumour" ,modify
label values eidmp eidmp_lab

** Check eidmp properly assigned
count if eidmp==1 & recstatus!=1 //0
count if eidmp==2 & recstatus!=1 //0
count if eidmp==. //568
count if eidmp==. & recstatus==1 //136
sort pid
list pid cr5id dupsource if eidmp==. & recstatus==1

** Create variable to identify patient records
gen ptrectot=. //2,608 missing values
replace ptrectot=1 if eidmp==1 //1,909 changes
replace ptrectot=3 if eidmp==2 //131 changes
label define ptrectot_lab 1 "CR5 pt with single event" 2 "DCO with single event" 3 "CR5 pt with multiple events" ///
						  4 "DCO with multiple events" 5 "CR5 pt: single event but multiple DC events" , modify
label values ptrectot ptrectot_lab
/*
Now check:
	eidmp and ptrectot are correctly assigned as patient records with 2 separate tumours may have both tumours (or only 1 confirmed/eligible tumour) listed as MP
    use Stata browse/edit and filter by pid in below list
*/
count if eidmp==2 & dupsource==1 //131
order pid cr5id dupsource eidmp ptrectot recstatus fname lname
//list pid ptrectot cr5id fname lname if eidmp==2 & dupsource==1

replace ptrectot=1 if pid=="20080310" & cr5id=="T2S1" & ptrectot!=. //1 change
replace eidmp=1 if pid=="20080310" & cr5id=="T2S1" & eidmp!=. //1 change
replace ptrectot=1 if pid=="20080384" & cr5id=="T2S1" & ptrectot!=. //1 change
replace eidmp=1 if pid=="20080384" & cr5id=="T2S1" & eidmp!=. //1 change
replace ptrectot=1 if pid=="20080387" & cr5id=="T2S1" & ptrectot!=. //1 change
replace eidmp=1 if pid=="20080387" & cr5id=="T2S1" & eidmp!=. //1 change
replace ptrectot=1 if pid=="20080438" & cr5id=="T2S1" & ptrectot!=. //1 change
replace eidmp=1 if pid=="20080438" & cr5id=="T2S1" & eidmp!=. //1 change
replace ptrectot=1 if pid=="20080477" & cr5id=="T3S1" & ptrectot!=. //1 change
replace eidmp=1 if pid=="20080477" & cr5id=="T3S1" & eidmp!=. //1 change
replace ptrectot=1 if pid=="20080690" & cr5id=="T2S1" & ptrectot!=. //1 change
replace eidmp=1 if pid=="20080690" & cr5id=="T2S1" & eidmp!=. //1 change
replace ptrectot=1 if pid=="20090016" & cr5id=="T2S1" & ptrectot!=. //1 change
replace eidmp=1 if pid=="20090016" & cr5id=="T2S1" & eidmp!=. //1 change
replace ptrectot=1 if pid=="20090045" & cr5id=="T3S1" & ptrectot!=. //1 change
replace eidmp=1 if pid=="20090045" & cr5id=="T3S1" & eidmp!=. //1 change
replace ptrectot=1 if pid=="20130169" & cr5id=="T2S1" & ptrectot!=. //1 change
replace eidmp=1 if pid=="20130169" & cr5id=="T2S1" & eidmp!=. //1 change
replace ptrectot=1 if pid=="20130172" & cr5id=="T2S1" & ptrectot!=. //1 change
replace eidmp=1 if pid=="20130172" & cr5id=="T2S1" & eidmp!=. //1 change
replace ptrectot=1 if pid=="20130727" & cr5id=="T2S1" & ptrectot!=. //1 change
replace eidmp=1 if pid=="20130727" & cr5id=="T2S1" & eidmp!=. //1 change
replace ptrectot=1 if pid=="20130798" & cr5id=="T2S1" & ptrectot!=. //1 change
replace eidmp=1 if pid=="20130798" & cr5id=="T2S1" & eidmp!=. //1 change


** Count # of patients with eligible non-dup tumours
count if ptrectot==1 //1,921

** Count # of eligible non-dup tumours
count if eidmp==1 //1,921

** Count # of eligible non-dup MPs
count if eidmp==2 //119

** Count # of patients with eligible non-dup tumours (2008)
count if ptrectot==1 & dxyr==2008 //1,113

** Count # of eligible non-dup tumours (2008)
count if eidmp==1 & dxyr==2008 //1,113

** Count # of eligible non-dup MPs (2008)
count if eidmp==2 & dxyr==2008 //96

** Count # of patients with eligible non-dup tumours (2013)
count if ptrectot==1 & dxyr==2013 //804

** Count # of eligible non-dup tumours (2013)
count if eidmp==1 & dxyr==2013 //804

** Count # of eligible non-dup MPs (2013)
count if eidmp==2 & dxyr==2013 //14


** Check for cases where T1 is not the abstraction
count if primarysite=="" & cr5id=="T1S1" //already corrected above

** Need to remove duplicate records
drop if eidmp==. //568 deleted

count //2,040
count if dxyr==2008 //1,209
count if dxyr==2008 & eidmp==2 //96
count if dxyr==2013 //818
count if dxyr==2013 & eidmp==2 //14

** Check for no missing icd10 values as need this for site groupings later
rename ICD10 icd10
rename ICCCcode iccc
count if icd10=="" //0

** Label non-reportable skin cancers
count if regexm(icd10,"C44") //304
gen skin=1 if regexm(icd10,"C44") //1,736 missing so 304 changes

STOPPED HERE
** Create variable to identify potential cancers in CODs
gen cancer=.
label define cancer_lab 1 "2014 cancer" 2 "not cancer/not 2014", modify
label values cancer cancer_lab
label var cancer "cancer diagnoses"
label var deathid "Event identifier for registry deaths"

** searching cod1a for these terms
replace cancer=1 if regexm(cod1a, "CANCER") //1,524 changes
replace cancer=1 if regexm(cod1a, "TUMOUR") &  cancer==. //82 changes
replace cancer=1 if regexm(cod1a, "TUMOR") &  cancer==. //35 changes
replace cancer=1 if regexm(cod1a, "MALIGNANT") &  cancer==. //31 changes
replace cancer=1 if regexm(cod1a, "MALIGNANCY") &  cancer==. //138 changes
replace cancer=1 if regexm(cod1a, "NEOPLASM") &  cancer==. //9 changes
replace cancer=1 if regexm(cod1a, "CARCINOMA") &  cancer==. //961 changes
replace cancer=1 if regexm(cod1a, "CARCIMONA") &  cancer==. //1 change
replace cancer=1 if regexm(cod1a, "CARINOMA") &  cancer==. //1 change
replace cancer=1 if regexm(cod1a, "MYELOMA") &  cancer==. //107 changes
replace cancer=1 if regexm(cod1a, "LYMPHOMA") &  cancer==. //85 changes
replace cancer=1 if regexm(cod1a, "LYMPHOMIA") &  cancer==. //0 changes
replace cancer=1 if regexm(cod1a, "LYMPHONA") &  cancer==. //1 change
replace cancer=1 if regexm(cod1a, "SARCOMA") &  cancer==. //33 changes
replace cancer=1 if regexm(cod1a, "TERATOMA") &  cancer==. //0 changes
replace cancer=1 if regexm(cod1a, "LEUKEMIA") &  cancer==. //40 changes
replace cancer=1 if regexm(cod1a, "LEUKAEMIA") &  cancer==. //31 changes
replace cancer=1 if regexm(cod1a, "HEPATOMA") &  cancer==. //0 changes
replace cancer=1 if regexm(cod1a, "CARANOMA PROSTATE") &  cancer==. //0 changes
replace cancer=1 if regexm(cod1a, "MENINGIOMA") &  cancer==. //11 changes
replace cancer=1 if regexm(cod1a, "MYELOSIS") &  cancer==. //0 changes
replace cancer=1 if regexm(cod1a, "MYELOFIBROSIS") &  cancer==. //4 changes
replace cancer=1 if regexm(cod1a, "CYTHEMIA") &  cancer==. //0 changes
replace cancer=1 if regexm(cod1a, "CYTOSIS") &  cancer==. //2 changes
replace cancer=1 if regexm(cod1a, "BLASTOMA") &  cancer==. //9 changes
replace cancer=1 if regexm(cod1a, "METASTATIC") &  cancer==. //26 changes
replace cancer=1 if regexm(cod1a, "MASS") &  cancer==. //97 changes
replace cancer=1 if regexm(cod1a, "METASTASES") &  cancer==. //5 changes
replace cancer=1 if regexm(cod1a, "METASTASIS") &  cancer==. //3 changes
replace cancer=1 if regexm(cod1a, "REFRACTORY") &  cancer==. //0 changes
replace cancer=1 if regexm(cod1a, "FUNGOIDES") &  cancer==. //1 change
replace cancer=1 if regexm(cod1a, "HODGKIN") &  cancer==. //0 changes
replace cancer=1 if regexm(cod1a, "MELANOMA") &  cancer==. //1 change
replace cancer=1 if regexm(cod1a,"MYELODYS") &  cancer==. //8 changes

** Strip possible leading/trailing blanks in cod1a
replace cod1a = rtrim(ltrim(itrim(cod1a))) //0 changes

tab cancer, missing
/*
     cancer |
  diagnoses |      Freq.     Percent        Cum.
------------+-----------------------------------
     cancer |      3,245       26.41       26.41
          . |      9,041       73.59      100.00
------------+-----------------------------------
      Total |     12,286      100.00
*/
tab deathyear cancer,m
/*
           |   cancer diagnoses
 deathyear |    cancer          . |     Total
-----------+----------------------+----------
      2013 |       614      1,796 |     2,410 
      2014 |       692      1,804 |     2,496 
      2015 |       629      1,853 |     2,482 
      2016 |       668      1,820 |     2,488 
      2017 |       642      1,768 |     2,410 
-----------+----------------------+----------
     Total |     3,245      9,041 |    12,286
*/

** Check that all cancer CODs for 2014 are eligible
sort cod1a deathid
order deathid cod1a
list cod1a if cancer==1 & deathyear==2014 //692

** Replace 2014 cases that are not cancer according to eligibility SOP:
/*
	(1) After merge with CR5 data then may need to reassign some of below 
		deaths as CR5 data may indicate eligibility while COD may exclude
		(e.g. see deathid==15458)
	(2) use obsid to check for CODs that incomplete in Results window with 
		Data Editor in browse mode-copy and paste deathid below from here
*/
replace cancer=2 if ///
deathid==16285 |deathid==1292  |deathid==15458 |deathid==11987 |deathid==1552| ///
deathid==23771 |deathid==19815 |deathid==11910 |deathid==23750 |deathid==8118| ///
deathid==3725  |deathid==932   |deathid==3419  |deathid==23473 |deathid==19097| ///
deathid==16546 |deathid==20819 |deathid==20241 |deathid==13572 |deathid==6444| ///
deathid==4644  |deathid==14413 |deathid==16702 |deathid==14249 |deathid==14688| ///
deathid==5469  |deathid==15378 |deathid==2231  |deathid==22807 |deathid==12102| ///
deathid==22127 |deathid==23906 |deathid==6243  |deathid==22248 |deathid==18365| ///
deathid==17054 |deathid==13194 |deathid==19770 |deathid==2742  |deathid==20031| ///
deathid==8574  |deathid==10793 |deathid==20504 |deathid==20634 |deathid==5531| ///
deathid==17077 |deathid==11945 |deathid==19303 |deathid==1429  |deathid==17327| ///
deathid==7925  |deathid==23413 |deathid==5189  |deathid==12137 |deathid==16726| ///
deathid==19979 |deathid==21864 |deathid==2477  |deathid==19620 |deathid==5741| ///
deathid==183
//61 changes

** Check that all 2014 CODs that are not cancer for eligibility
tab deathyear cancer,m
/*
           |         cancer diagnoses
 deathyear |    cancer  not cancer         . |     Total
-----------+---------------------------------+----------
      2013 |       614          0      1,796 |     2,410 
      2014 |       631         61      1,804 |     2,496 
      2015 |       629          0      1,853 |     2,482 
      2016 |       668          0      1,820 |     2,488 
      2017 |       642          0      1,768 |     2,410 
-----------+---------------------------------+----------
     Total |     3,184         61      9,041 |    12,286
*/
count if cancer==. & deathyear==2014 & (deathid>0 & deathid<5000) //376
count if cancer==. & deathyear==2014 & (deathid>5000 & deathid<10000) //374
count if cancer==. & deathyear==2014 & (deathid>10000 & deathid<15000) //368
count if cancer==. & deathyear==2014 & (deathid>15000 & deathid<20000) //374
count if cancer==. & deathyear==2014 & (deathid>20000 & deathid<25000) //311
count if cancer==. & deathyear==2014 & (deathid>25000 & deathid<30000) //0

list cod1a if cancer==. & deathyear==2014 & (deathid>0 & deathid<5000)
list cod1a if cancer==. & deathyear==2014 & (deathid>5000 & deathid<10000)
list cod1a if cancer==. & deathyear==2014 & (deathid>10000 & deathid<15000)
list cod1a if cancer==. & deathyear==2014 & (deathid>15000 & deathid<20000)
list cod1a if cancer==. & deathyear==2014 & (deathid>20000 & deathid<25000)
list cod1a if cancer==. & deathyear==2014 & (deathid>25000 & deathid<30000)

** No updates needed from above list
/*
replace cancer=1 if ///
deathid==|deathid==|deathid==|deathid==|deathid==| ///
*/

replace cancer=2 if cancer==. //9,041 changes

** Create cod variable 
gen cod=.
label define cod_lab 1 "Dead of cancer" 2 "Dead of other cause" 3 "Not known" 4 "NA", modify
label values cod cod_lab
label var cod "COD categories"
replace cod=1 if cancer==1 //3,184 changes
replace cod=2 if cancer==2 //9,102 changes
** one unknown causes of death in 2014 data - deathid 12323
replace cod=3 if regexm(cod1a,"INDETERMINATE")|regexm(cod1a,"UNDETERMINED") //56 changes


** Create variable called "deceased" - same as 2008 dofile called '3_merge_cancer_deaths.do'
tab slc ,m
count if slc!=2 & dod!=. //0
gen deceased=1 if slc!=1 //645 changes
label var deceased "whether patient is deceased"
label define deceased_lab 1 "dead" 2 "alive at last contact" , modify
label values deceased deceased_lab
replace deceased=2 if slc==1 //430 changes

tab deceased ,m
/*
   whether patient is |
             deceased |      Freq.     Percent        Cum.
----------------------+-----------------------------------
                 dead |        645       60.00       60.00
alive at last contact |        430       40.00      100.00
----------------------+-----------------------------------
                Total |      1,075      100.00
*/

** Create the "patient" variable - same as 2008 dofile called '3_merge_cancer_deaths.do'
gen patient=.  
label var patient "cancer patient"
label define pt_lab 1 "patient" 2 "separate event",modify
label values patient pt_lab
replace patient=1 if eidmp==1 //1,056 changes
replace patient=2 if eidmp==2 //19 changes
tab patient ,miss


** Add 'missed' 2013 cases found while cleaning 2014 data
** Ensure these are 'true' missed cases by checking dataset with 30 missed cases against this dataset
append using "`datapath'\version01\1-input\2013_cancer_clean_nodups_dc"
count //

drop if pid=="20130338" & cr5id=="T1S1" & deathid=="20582"

count //
replace dot=d(31dec2013) if pid=="20130338"
replace dxyr=2013 if pid=="20130338"


CHECK missed 2013 cases against this dataset then APPEND 2013 missed cases, next site groupings, then mortality, then onto analysis

** DROP all cases dx in 2014 onwards as 2014 cases already cleaned
** pre-2014 cases are to be cleaned
count if dxyr==. //0
count if dxyr!=2008 & dxyr!=2013 //13
drop if dxyr>2013 //13 deleted


* ************************************************************************
* SITE GROUPINGS
* Using ...?
**************************************************************************



count //

** Put variables in order you want them to appear
order pid fname lname init age sex dob natregno resident slc dlc ///
	    parish cr5cod primarysite morph top lat beh hx

save "`datapath'\version01\2-working\2008_2013_cancer_dc" ,replace
label data "BNR-Cancer prepared 2008 & 2013 data"
notes _dta :These data prepared for 2008 & 2013 inclusion in 2014 cancer report
