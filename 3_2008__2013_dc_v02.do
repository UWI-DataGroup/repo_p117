** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			3_2008_2013_dc_v2.do
    //  project:				BNR
    //  analysts:				Jacqueline CAMPBELL
    //  date first created      19-MAR-2019
    // 	date last modified	    19-MAR-2019
    //  algorithm task			Cleaning 2008 & 2013 cancer datasets, Creating site groupings
    //  release version         v02: ????using CanReg5 BNR-CLEAN 18-Mar-2019 dataset
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

STOPPED HERE: need to think how to combine this data file with CR5 2015 REVIEW DB as some 2008/2013 updated in there
pid 20080563 DLC updated in REVIEW db.
pid 20080169 SLC, DLC updated in REVIEW db.
pid 20141523 changed to ineligible in REVIEW db.
pid 20080563 DLC updated in REVIEW db.
pid 20080169 DLC updated in REVIEW db.
pid 20080336 DLC updated in REVIEW db.
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

*************************************************
** BLANK & INCONSISTENCY CHECKS - PATIENT TABLE
** CHECKS 1 - 46
** (1) CORRECT INCONSISTENCIES
** (2) EXPORT FOR CANREG5 DATABASE (CLEAN)
*************************************************

** CHECK 1 (PatientID)
count if pid=="" //0

** No checks for below as not applicable for pre-2014 DATA
/*
 Person Search
 Patient record updated by
 Date patient record updated
 PT Data Abstractor
 Casefinding Date
 Case Status
 Retrieval Source
 Notes Seen
 Notes Seen Date
 Further Retrieval Source
 Hospital Number
*/

** CHECK 2 (Case Status)
count if cstatus==. //0
//missing
count if cstatus==4
//possibly invalid - checking if it is a true duplicate (i.e. source info applies to same tumour vs multiple primary)
count if cstatus==2 //0
//possibly invalid - pt record=deleted
count if cstatus==3 & recstatus<3 //0
//possibly invalid as pt record=ineligible/duplicate but tumour record not ineligible
count if cstatus==1 & recstatus==4 //162
**list pid deathid cstatus dxyr cr5id if cstatus==1 & recstatus==4
replace recstatus=3 if pid=="20080622" & cr5id=="T2S1" //1 change
replace recstatus=3 if pid=="20130239" & cr5id=="T2S1" //1 change

replace primarysite="SKIN-RT GROIN" if pid=="20130253" & regexm(cr5id, "T1") //1 change - found incidentally when checking casestatus

replace hx="FOCALLY INVASIVE ADENOCARCINOMA ARISING FROM VILLOUS ADENOMA" if pid=="20130275" & regexm(cr5id, "T3") //1 change - found incidentally when checking casestatus
replace morph=8261 if pid=="20130275" & regexm(cr5id, "T3") //1 change - found incidentally when checking casestatus
replace morphcat=6 if pid=="20130275" & regexm(cr5id, "T3") //0 changes - found incidentally when checking casestatus

replace hx="NON HODGKINS LYMPHOMA, SMALL LYMPHOCYTIC VARIANT" if pid=="20130303" & regexm(cr5id, "T1") //1 change - found incidentally when checking casestatus
replace morph=9670 if pid=="20130303" & regexm(cr5id, "T1") //1 change - found incidentally when checking casestatus
replace morphcat=43 if pid=="20130303" & regexm(cr5id, "T1") //1 change - found incidentally when checking casestatus
replace staging=1 if pid=="20130303" & regexm(cr5id, "T1") //1 change - found incidentally when checking casestatus

replace primarysite="STOMACH-ANTRUM/PYLORUS" if pid=="20130307" & regexm(cr5id, "T1") //1 change - found incidentally when checking casestatus
replace top="168" if pid=="20130307" & regexm(cr5id, "T1") //1 change - found incidentally when checking casestatus
replace topography=168 if pid=="20130307" & regexm(cr5id, "T1") //1 change - found incidentally when checking casestatus
replace topcat=17 if pid=="20130307" & regexm(cr5id, "T1") //0 changes - found incidentally when checking casestatus
replace hx="ADENOCARCINOMA, DIFFUSE TYPE" if pid=="20130307" & regexm(cr5id, "T1") //1 change - found incidentally when checking casestatus
replace morph=8145 if pid=="20130307" & regexm(cr5id, "T1") //1 change - found incidentally when checking casestatus
replace morphcat=6 if pid=="20130307" & regexm(cr5id, "T1") //0 changes - found incidentally when checking casestatus
replace staging=3 if pid=="20130307" & regexm(cr5id, "T1") //1 change - found incidentally when checking casestatus

replace hx="MIXED CARCINOMA-ENDOMETRIOID & CLEAR CELL" if pid=="20130313" & regexm(cr5id, "T1") //2 changes - found incidentally when checking casestatus
replace morph=8380 if pid=="20130313" & regexm(cr5id, "T1") //2 changes - found incidentally when checking casestatus
replace morphcat=6 if pid=="20130313" & regexm(cr5id, "T1") //2 changes - found incidentally when checking casestatus
replace staging=1 if pid=="20130313" & regexm(cr5id, "T1") //2 changes - found incidentally when checking casestatus
replace rx1=1 if pid=="20130313" & regexm(cr5id, "T1") //2 changes - found incidentally when checking casestatus
replace rx1d=d(19feb2014) if pid=="20130313" & regexm(cr5id, "T1") //2 changes - found incidentally when checking casestatus

replace staging=2 if pid=="20130317" & regexm(cr5id, "T1") //2 changes - found incidentally when checking casestatus

replace staging=8 if pid=="20130338" & regexm(cr5id, "T1") //2 changes - found incidentally when checking casestatus

replace staging=7 if pid=="20130338" & regexm(cr5id, "T1") //2 changes - found incidentally when checking casestatus
replace dot=d(31dec2013) if pid=="20130338" & regexm(cr5id, "T1") //2 changes - found incidentally when checking casestatus
replace dxyr=2013 if pid=="20130338" & regexm(cr5id, "T1") //2 changes - found incidentally when checking casestatus
replace sampledate=d(31dec2013) if pid=="20130338" & regexm(cr5id, "T1") //2 changes - found incidentally when checking casestatus
replace recvdate=d(02jan2014) if pid=="20130338" & regexm(cr5id, "T1") //2 changes - found incidentally when checking casestatus

replace primarysite="LYMPH NODE-MESENTERIC" if pid=="20130341" & regexm(cr5id, "T1") //1 change - found incidentally when checking casestatus
replace top="772" if pid=="20130341" & regexm(cr5id, "T1") //1 change - found incidentally when checking casestatus
replace topography=772 if pid=="20130341" & regexm(cr5id, "T1") //1 change - found incidentally when checking casestatus
replace topcat=69 if pid=="20130341" & regexm(cr5id, "T1") //1 change - found incidentally when checking casestatus
replace staging=1 if pid=="20130341" & regexm(cr5id, "T1") //1 change - found incidentally when checking casestatus
replace rx1=3 if pid=="20130341" & regexm(cr5id, "T1") //1 change - found incidentally when checking casestatus

replace primarysite="OVERLAP BREAST-3 O'CLOCK" if pid=="20130361" & regexm(cr5id, "T1") //1 change - found incidentally when checking casestatus

replace hx="UNDIFFERENTIATED CARCINOMA - METASTATIC" if pid=="20130389" & regexm(cr5id, "T1") //2 changes - found incidentally when checking casestatus
replace morph=8020 if pid=="20130389" & regexm(cr5id, "T1") //2 changes - found incidentally when checking casestatus
replace morphcat=2 if pid=="20130389" & regexm(cr5id, "T1") //2 changes - found incidentally when checking casestatus
replace staging=7 if pid=="20130389" & regexm(cr5id, "T1") //2 changes - found incidentally when checking casestatus

replace staging=4 if pid=="20130606" & regexm(cr5id, "T1") //1 change - found incidentally when checking casestatus

replace primarysite="BREAST-UOQ" if pid=="20130620" & regexm(cr5id, "T1") //1 change - found incidentally when checking casestatus

STOPPED HERE
NB: 20080139 - change hx=HEPATOMA LIVER, morph=8170 (beh still=3)
//checking tumour records=duplicate that it is a true duplicate (i.e. source info applies to same tumour vs multiple primary)



** CHECK 3 (Names)
count if fname=="" //0
count if init=="" //0
**replace init="99" if init=="" //0 changes
count if lname=="" //0


** CHECK 4 (DOB, NRN)
count if dob==. //189
count if dob==. & natregno!="" & natregno!="99" & natregno!="999999-9999"  & !(strmatch(natregno), "*99-*") //15
sort pid
//list pid deathid pnameex* natregno if dob==. & natregno!="" & natregno!="99" & natregno!="999999-9999"  & !(strmatch(natregno), "*99-*")
replace dob=d(28dec1935) if pid=="20080885" //1 change
replace dob=d(16sep1943) if pid=="20130361" //1 change
replace dob=d(08jun1930) if pid=="20130362" //1 change
replace dob=d(02sep1945) if pid=="20130374" //1 change
replace dob=d(10feb1929) if pid=="20130396" //1 change
replace dob=d(30jun1961) if pid=="20130631" //1 change
replace dob=d(16oct1984) if pid=="20130674" //1 change
replace dob=d(25jul1956) if pid=="20130696" //1 change
replace dob=d(19dec1944) if pid=="20130772" //1 change
replace dob=d(10jan1949) if pid=="20130813" //1 change
replace dob=d(28sep1946) if pid=="20130814" //1 change
replace dob=d(23nov1946) if pid=="20130818" //1 change
replace dob=d(24nov1947) if pid=="20130830" //1 change
replace dob=d(14feb1944) if pid=="20130874" //1 change
replace dob=d(31aug1947) if pid=="20130886" //1 change
**replace natregno="999999-9999" if pid=="20081071" //1 change
count if natregno=="" & dob!=. //0
count if (natregno=="999999-9999"|regexm(natregno,"99-")) & dob!=. //91
//list pid deathid dob pnameex* if natregno=="999999-9999" & dob!=.
drop dobday dobmonth dobyear
gen dobday=day(dob)
gen dobmonth=month(dob)
gen dobyear=year(dob)
tostring dobday ,replace
tostring dobmonth ,replace
tostring dobyear ,replace
replace dobday="0"+dobday if length(dobday)<2 & dobday!=""
replace dobmonth="0"+dobmonth if length(dobmonth)<2 & dobmonth!=""
gen dobnrn=substr(dobyear,-2,2)+dobmonth+dobday
replace natregno=dobnrn+"-9999" if (natregno=="999999-9999"|regexm(natregno,"99-")) & dob!=. //91 changes
drop dobday dobmonth dobyear dobnrn
//missing
gen currentd=c(current_date)
gen double currentdatedob=date(currentd, "DMY", 2017)
drop currentd
format currentdatedob %dD_m_CY
label var currentdate "Current date DOB"
count if dob!=. & dob>currentdatedob //0
drop currentdatedob
//future date
count if length(natregno)<11 & natregno!="" //0
//length error
gen nrnday = substr(natregno,5,2)
count if dob==. & natregno!="" & natregno!="9999999999" & natregno!="999999-9999" & nrnday!="99" //0
//dob missing but full nrn available
gen dob_year = year(dob) if natregno!="" & natregno!="9999999999" & natregno!="999999-9999" & nrnday!="99" & length(natregno)==11
gen yr1=.
replace yr1 = 20 if dob_year>1999
replace yr1 = 19 if dob_year<2000
replace yr1 = 19 if dob_year==.
replace yr1 = 99 if natregno=="99"
**list pid dob_year dob natregno yr yr1 if dob_year!=. & dob_year > 1999
gen str nrn = substr(natregno,1,6) if natregno!="" & natregno!="9999999999" & natregno!="999999-9999" & nrnday!="99" & length(natregno)==11
**gen nrnlen=length(nrn)
**drop if nrnlen!=6
destring nrn, replace
format nrn %06.0f
nsplit nrn, digits(2 2 2) gen(year month day)
format year month day %02.0f
tostring yr1, replace
gen year2 = string(year,"%02.0f")
gen nrnyr = substr(yr1,1,2) + substr(year2,1,2)
destring nrnyr, replace
sort nrn
gen dobchk=mdy(month, day, nrnyr)
format dobchk %dD_m_CY
count if dob!=dobchk & dobchk!=. //2
**list pid age natregno nrn dob dobchk dob_year if dob!=dobchk & dobchk!=.
replace dob=dobchk if dob!=dobchk & dobchk!=. //2 changes
drop dob_year day month year nrnday nrnyr year2 yr yr1 nrn dobchk
//dob does not match nrn


** CHECK 5 (sex)
count if sex==. //0
count if deathid!=. & ddsex==. //0
//missing
count if sex!=ddsex & sex!=. & ddsex!=. //4
**list pid deathid pname* *sex natregno cod1a if sex!=ddsex & sex!=. & ddsex!=.
replace sex=2 if pid=="20081131" //1 change
replace sex=1 if pid=="20080022" //2 changes
replace ddsex=2 if deathid==975 //1 change
//not matching
gen nrnid=substr(natregno, -4,4)
count if sex==2 & nrnid!="9999" & regex(substr(natregno,-2,1), "[1,3,5,7,9]") //1 - checked electoral list sex is correct but fname is incorrect
**list pid deathid fname lname sex natregno primarysite cr5id if sex==2 & nrnid!="9999" & regex(substr(natregno,-2,1), "[1,3,5,7,9]")
replace fname="AGNES" if pid=="20090060" //1 change
replace init="VICTORIA" if pid=="20090060" //1 change
replace natregno="4203158003" if pid=="20090060" //1 change - pt has 2 NRNs in electoral list 4203158011
//possibly invalid (fname, nrn=MALE)
count if sex==1 & nrnid!="9999" & regex(substr(natregno,-2,1), "[0,2,4,6,8]") //2 - correct sex
//possibly invalid (fname, nrn=FEMALE)
count if sex==1 & (regexm(cr5cod, "BREAST") | regexm(top, "^50")) //8 - all correct
//possibly invalid (site=breast, sex=MALE)
count if cr5id=="T1S1" & sex==1 & topcat>43 & topcat<52	& (regexm(cr5cod, "VULVA") | regexm(cr5cod, "VAGINA") | regexm(cr5cod, "CERVIX") | regexm(cr5cod, "CERVICAL") ///
								| regexm(cr5cod, "UTER") | regexm(cr5cod, "OVAR") | regexm(cr5cod, "PLACENTA")) //0
//possibly invalid (site=female, sex=MALE)
count if sex==2 & topcat>51 & topcat<56 & (regexm(cr5cod, "PENIS")|regexm(cr5cod, "PROSTAT")|regexm(cr5cod, "TESTIS")|regexm(cr5cod, "TESTIC")) //0
//possibly invalid (site=male, sex=FEMALE)


** Resident Status

** Status Last Contact

** Date Last Contact
replace dlc=d(31dec2014) if pid=="20080196" //see DLC for 2nd patient record
replace dlc=d(01jul2014) if pid=="20080242" //see dot for T2
replace dlc=d(19mar2014) if pid=="20080690" //see DLC for 2nd patient record

** Comments

** PT Reviewer





** Death data variables - to clean
regnum pname dod deathid recap_event_name dddoa ddda odda certtype district address ddparish ddage ddagetxt mstatus occu cod1a pod deathparish regdate ddcertifier ddnamematch dcstatus duprec

**

** slc
replace slc=2 if slc==. & deathid!=. & pid=="" //merged deaths

** Check for dod
count if slc==2 & dod==.

*************************************************
** BLANK & INCONSISTENCY CHECKS - TUMOUR TABLE
** CHECKS 47 - ...
** (1) CORRECT INCONSISTENCIES
** (2) EXPORT FOR CANREG5 DATABASE (CLEAN)
*************************************************

** Check ... (DA)
count if ttda=="" //0
count if length(ttda)<1 //0

** Check ... (primary site, topography)
replace primarysite="OVERLAP-STOMACH INVOLV. BODY,PYLORIC AN." if pid==20080634
replace topography=168 if pid=="20080634"

* ************************************************************************
* SITE GROUPINGS
* Using ...?
**************************************************************************
count if icd10==""


** DROP all cases dx in 2014 onwards as 2014 cases already cleaned
** pre-2014 cases are to be cleaned
count if dxyr==. //0
drop if dxyr>2013 //42 deleted

count //

** Put variables in order you want them to appear
order pid fname lname init age sex dob natregno resident slc dlc ///
	    parish cr5cod primarysite morph top lat beh hx

save "`datapath'\version01\2-working\2008_2013_cancer_dc" ,replace
label data "BNR-Cancer prepared 2008 & 2013 data"
notes _dta :These data prepared for 2008 & 2013 inclusion in 2014 cancer report
