** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          20d_final clean.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      15-AUG-2022
    // 	date last modified      17-AUG-2022
    //  algorithm task          Final cleaning of 2008,2013-2018 cancer dataset; Preparing datasets for analysis
    //  status                  Completed
    //  objective               To have one dataset with cleaned and grouped 2008, 2013-2018 data for inclusion in 2016-2018 cancer report.
    //  methods                 Clean and update all years' data using IARCcrgTools Check and Multiple Primary

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
    log using "`logpath'\20d_final clean.smcl", replace
** HEADER -----------------------------------------------------

** Load 2008,2013-2018 incidence dataset created in 20c_death match.do
use "`datapath'\version09\3-output\2008_2013-2018_nonreportable_identifiable" ,clear

count //7288

** Merge death data by NRN using the NRN merge ds from 20c_death match.do
merge m:1 natregno using "`datapath'\version09\2-working\2015-2021_deaths_for_merging_NRN" ,update replace
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                         5,426
        from master                     5,426  (_merge==1)
        from using                          0  (_merge==2)

    Matched                             1,862
        not updated                         0  (_merge==3)
        missing updated                 1,638  (_merge==4)
        nonmissing conflict               224  (_merge==5)
    -----------------------------------------
*/
count //7288
drop if deathds==1 & _merge==2 //0 deleted

** Merge death data by DOB using the DOB merge ds from 20c_death match.do
drop _merge
merge m:1 fname lname birthdate using "`datapath'\version09\2-working\2015-2021_deaths_for_merging_DOB" ,update replace
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                         7,273
        from master                     7,273  (_merge==1)
        from using                          0  (_merge==2)

    Matched                                15
        not updated                         0  (_merge==3)
        missing updated                     0  (_merge==4)
        nonmissing conflict                15  (_merge==5)
    -----------------------------------------
*/
count //7288
drop if deathds==1 & _merge==2 //0 deleted

** Merge death data by DOB + LNAME using the DOBLN merge ds from 20c_death match.do
drop _merge
merge m:1 pid cr5id using "`datapath'\version09\2-working\2015-2021_deaths_for_merging_DOBLNAME" ,update replace
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                         7,280
        from master                     7,280  (_merge==1)
        from using                          0  (_merge==2)

    Matched                                 8
        not updated                         0  (_merge==3)
        missing updated                     0  (_merge==4)
        nonmissing conflict                 8  (_merge==5)
    -----------------------------------------
*/
count //7288
drop if deathds==1 & _merge==2 //0 deleted


** Merge death data by NAMES using the NRN merge ds from 20c_death match.do
drop _merge
merge m:1 pid cr5id using "`datapath'\version09\2-working\2015-2021_deaths_for_merging_NAMES" ,update replace
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                         7,240
        from master                     7,240  (_merge==1)
        from using                          0  (_merge==2)

    Matched                                48
        not updated                         0  (_merge==3)
        missing updated                    44  (_merge==4)
        nonmissing conflict                 4  (_merge==5)
    -----------------------------------------
*/
count //7288
drop if deathds==1 & _merge==2 //0 deleted

**JC 15aug2022: Correction found incidentally when reviewing possible death matches by NAMES in 20c_death match.do
replace slc=1 if pid=="20160225"
replace dod=. if pid=="20160225"
replace dlc=sampledate if pid=="20160225"
replace cr5cod="" if pid=="20160225"

** JC 16aug2022: Correction found incidentally so will merge single death record from 2013 into this ds
preserve
clear
import excel using "`datapath'\version09\2-working\MissingDeath_20220816.xlsx" , firstrow case(lower)
drop dd_dddoa
gen double dd_dddoa=tc(01jan2000 00:00)
//destring dd_dddoa ,replace
tostring pid, replace
tostring natregno, replace
tostring dd_mname ,replace
tostring dd_cod1b ,replace
tostring dd_cod1c ,replace
tostring dd_cod1d ,replace
tostring dd_cod2a ,replace
tostring dd_cod2b ,replace
tostring dd_certifier ,replace
tostring dd_certifieraddr ,replace
tostring dd_redcap_event_name ,replace
save "`datapath'\version09\2-working\missing_death" ,replace
restore

drop _merge
merge m:1 pid cr5id using "`datapath'\version09\2-working\missing_death" ,update replace
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                         7,287
        from master                     7,287  (_merge==1)
        from using                          0  (_merge==2)

    Matched                                 1
        not updated                         0  (_merge==3)
        missing updated                     0  (_merge==4)
        nonmissing conflict                 1  (_merge==5)
    -----------------------------------------
*/
drop _merge
erase "`datapath'\version09\2-working\missing_death.dta"

/*
JC 28jul2022: 
(1) After merging with death data, update slc and dod fields + fillmissing for those with MPs that only merge to T1S1, e.g. see PID 20080728; check all DCOs + slc=2 have deathid
(2) once both datasets have been joined then perform IARCcrgTools MP Check then update persearch eidmp etc.
(3) create dcostatus ptrectot variables and perform duplicates checks
(4) age check, etc.
(5) pid 20080661 is a missed 2008 NMSC so needs to be dropped from reportable ds
(6) check if dod!=. & dodyear==.
(7) drop sitear + flags
(8) create ds export for CR5db rpt system def file
*/
*********************************

** Check all death ds fields updated and merged correctly
count if slc!=2 & dod!=. //0
//list pid cr5id recstatus eidmp dupsource persearch dxyr if slc!=2 & dod!=.
count if dd_dod!=. & dod==. //255
//list pid cr5id deathid dd_dod if dd_dod!=. & dod==.
** Need to format death data's DOD
format dd_dod %dD_m_CY
replace dod=dd_dod if dd_dod!=. & dod==. //255 changes

count if basis==0 & (slc!=2|dd_coddeath==""|deathid==.) //1 - cannot find pt in death data but seen in electoral list + MedData
//list pid cr5id deathid fname lname dd_coddeath if basis==0 & (slc!=2|dd_coddeath==""|deathid==.)

count if dod!=. & dodyear==. //1909
replace dodyear=year(dod) if dod!=. & dodyear==. //1909 changes

count if slc!=2 & dd_dod!=. //255
replace slc=2 if slc!=2 & dd_dod!=. //255 changes
count if slc!=2 & deathid!=. //0

count if slc==2 & deathid==. //65 - not found in death data
//list pid cr5id recstatus dod basis fname lname natregno dd_coddeath if slc==2 & deathid==. ,string(15)


** Check BOD from <2016 for new codes (now using the codes in ICD-O-3 so codes 3 and 8 are grouped into code 2 and 6 + 7, respectively)
count if basis==3|basis==8 //51
//list pid cr5id dxyr basis fname lname if basis==3|basis==8
replace basis=2 if basis==3 //28 changes
** Review cases with code 8 in CR5db + MasterDb to determine which category to assign it to - either 6 hx of mets OR 7 hx of primary
//list pid cr5id dxyr basis fname lname if basis==3|basis==8 //23
replace basis=7 if (pid=="20080845"|pid=="20080897"|pid=="20080942"|pid=="20080943"|pid=="20130183"|pid=="20130187"|pid=="20130536"|pid=="20130570"|pid=="20140308"|pid=="20140325"|pid=="20140348"|pid=="20140390"|pid=="20140516"|pid=="20140538"|pid=="20140615"|pid=="20140826"|pid=="20151335"|pid=="20151337"|pid=="20151338"|pid=="20155110") & regexm(cr5id,"T1") //20 changes
replace basis=6 if (pid=="20130527"|pid=="20130724") & regexm(cr5id,"T1") //2 changes
replace basis=2 if pid=="20145157" & regexm(cr5id,"T1")
replace hx="CANCER" if pid=="20145157" & regexm(cr5id,"T1")
replace morph=8000 if pid=="20145157" & regexm(cr5id,"T1")
replace morphcat=1 if pid=="20145157" & regexm(cr5id,"T1")

** Check for cases where cancer=2-not cancer but it has been abstracted
count if cancer==2 & pid!="" //262
sort pid deathid
order pid dd_coddeath cancer dd_cancer cod
//list pid deathid fname lname top cr5cod cod if cancer==2 & pid!="", nolabel string(90)
//list cr5cod if cancer==2 & pid!=""
//list cod1a if cancer==2 & pid!=""
** Corrections from above list
replace cod=. if pid=="20150095"|pid=="20151048"
replace cancer=. if pid=="20150095"|pid=="20151048"


*******************
** CLL/SLL M9823 **
*******************
count if morph==9823 & topography==421 //8 reviewed
//Review these cases - If unk if bone marrow involved then topography=lymph node-unk (C779)
display `"{browse "https://seer.cancer.gov/tools/heme/Hematopoietic_Instructions_and_Rules.pdf":HAEM-RULES}"'
order pid cr5id dxyr recstatus morph top
/* 
	Reviewed in CR5db and no corrections needed for PIDs:
		20090060
		20130137
		20151380
		20160544
		20160645
		20160892
		20170028
		20170034

replace primarysite="LYMPH NODES-UNK" if pid=="" & regexm(cr5id,"T1")
replace top="779" if pid=="" & regexm(cr5id,"T1")
replace topography=779 if pid=="" & regexm(cr5id,"T1")
replace topcat=69 if pid=="" & regexm(cr5id,"T1")
replace comments="JC 16AUG2022: Based on Haem & Lymph Coding manual Module 3 PH5 and PH6 the primary site has been changed to LNs unk since no bone marrow report found to support that as the primary site."+" "+comments if pid=="" & regexm(cr5id,"T1")
*/

** To match with 2014 format, convert names to lower case and strip possible leading/trailing blanks
replace fname = lower(rtrim(ltrim(itrim(fname)))) //0 changes
replace init = lower(rtrim(ltrim(itrim(init)))) //0 changes
//replace mname = lower(rtrim(ltrim(itrim(mname)))) //0 changes
replace lname = lower(rtrim(ltrim(itrim(lname)))) //0 changes

** Check if morph and morphology do not match (added this check on 31may2022)
gen morph2=morph
tostring morph2 ,replace
count if morph2!=morphology //4025
replace morphology=morph2
drop morph2

** Check if morph and morphology do not match (added this check on 31may2022)
gen topography2=topography
tostring topography2 ,replace
count if topography2!=top //60
replace top=topography2
drop topography2

tab dxyr resident ,m
/*
 Diagnosis |               Resident Status
      Year |       Yes         No    Unknown         99 |     Total
-----------+--------------------------------------------+----------
      2008 |     1,142          0          0         16 |     1,158 
      2013 |       893          2          0         15 |       910 
      2014 |       909          1          0         15 |       925 
      2015 |     1,111          1          0          8 |     1,120 
      2016 |     1,113          1         17          0 |     1,131 
      2017 |     1,012          0         22          0 |     1,034 
      2018 |       998          0         12          0 |     1,010 
-----------+--------------------------------------------+----------
     Total |     7,178          5         51         54 |     7,288
*/

tab dxyr beh ,m 
/*
 Diagnosis |                       Behaviour
      Year |    Benign  Uncertain    In situ  Malignant          . |     Total
-----------+-------------------------------------------------------+----------
      2008 |         8         10         83      1,057          0 |     1,158 
      2013 |         0          0          9        901          0 |       910 
      2014 |         0          0         24        901          0 |       925 
      2015 |         0          0         19      1,101          0 |     1,120 
      2016 |         0          0         38      1,075         18 |     1,131 
      2017 |         0          0         33        979         22 |     1,034 
      2018 |         0          0         35        964         11 |     1,010 
-----------+-------------------------------------------------------+----------
     Total |         8         10        241      6,978         51 |     7,288
*/

tab recstatus dxyr ,m
/*
        Record Status |      2008       2013       2014       2015       2016       2017       2018 |     Total
----------------------+-----------------------------------------------------------------------------+----------
            Confirmed |     1,158        909        923      1,112        969        956        994 |     7,021 
           Ineligible |         0          0          0          1          0          0          0 |         1 
Eligible, Non-reporta |         0          0          0          0         18         22         12 |        52 
Abs, Pending REG Revi |         0          1          2          7        144         56          4 |       214 
----------------------+-----------------------------------------------------------------------------+----------
                Total |     1,158        910        925      1,120      1,131      1,034      1,010 |     7,288
*/


** JC 17aug2022: after running most of this dofile yesterday, I discovered I erroneously didn't drop 1 (one) nonreportable 2016-2018 case because code for unknown resident was 9 in 2008,2013-2015 ds but 99 in 2016-2018 ds so had to add below code before I created the reportable ds to exclude these nonreportable cases

** Remove non-residents (see IARC validity presentation)
tab resident ,m //0 missing
//list pid cr5id recstatus addr if resident!=1
label drop resident_lab
label define resident_lab 1 "Yes" 2 "No" 99 "Unknown", modify
label values resident resident_lab
replace resident=99 if resident==9 //51 changes
//list pid natregno nrn addr dd_address if resident==99
count if resident==99 & addr!="99" & addr!="" //3 - all non-resident
//list pid cr5id dxyr recstatus addr if resident==99 & addr!="99" & addr!=""
//replace resident=1 if resident==99 & addr!="99" & addr!="" //0 changes
//replace resident=1 if resident==99 & dd_address!="99" & dd_address!="" //0
//replace natregno=nrn if natregno=="" & nrn!="" & resident==99 //3 changes
count if resident!=1 & natregno!="" & !(strmatch(strupper(natregno), "*9999*")) //5 - all nonreportable
//list pid cr5id dxyr recstatus natregno addr if resident!=1 & natregno!="" & !(strmatch(strupper(natregno), "*9999*"))
//replace resident=1 if natregno!="" & !(strmatch(strupper(natregno), "*9999*")) //0 changes
** Check electoral list and CR5db for those resident=99
//list pid fname lname nrn natregno dob if resident==99
//list pid fname lname addr if resident==99
tab resident ,m //105 unknown

** Check parish
count if parish!=. & parish!=99 & addr=="" //1 - nonreportable
count if parish==. & addr!="" & addr!="99" //0
//list pid fname lname natregno parish addr if parish!=. & parish!=99 & addr==""
//bysort pid (cr5id) : replace addr = addr[_n-1] if missing(addr) //1 change - 20140566/

** Check missing sex
tab sex ,m //none missing

** Check for missing age & 100+
tab age ,m //4 missing - none are 100+: f/u was done but age not found; these are nonreportable
//list pid cr5id recstatus resident natregno dd_nrn if age==999

** Check for missing follow-up
label drop slc_lab
label define slc_lab 1 "Alive" 2 "Deceased" 3 "Emigrated" 99 "Unknown", modify
label values slc slc_lab
replace slc=99 if slc==9 //49 changes
tab slc ,m 
** Check missing in CR5db
//list pid if slc==99
count if dlc==. //46 - all nonreportable
//list pid cr5id dxyr recstatus resident if dlc==.
//tab dlc ,m

** Check for non-malignant
tab beh ,m //6978 malignant; 259 non-malignant; 51 missing
tab morph if beh!=3

** Check for ineligibles
tab recstatus ,m //198 Abs, Pending REG Review
/*
                       Record Status |      Freq.     Percent        Cum.
-------------------------------------+-----------------------------------
                           Confirmed |      7,021       96.34       96.34
                          Ineligible |          1        0.01       96.35
Eligible, Non-reportable(?residency) |         52        0.71       97.06
             Abs, Pending REG Review |        214        2.94      100.00
-------------------------------------+-----------------------------------
                               Total |      7,288      100.00
*/

** Check for duplicate tumours
tab persearch ,m //106 excluded
/*
              Person Search |      Freq.     Percent        Cum.
----------------------------+-----------------------------------
                   Not done |         52        0.71        0.71
                   Done: OK |      6,856       94.07       94.79
                   Done: MP |        131        1.80       96.58
          Done: Non-IARC MP |        143        1.96       98.55
Done: IARCcrgTools Excluded |        106        1.45      100.00
----------------------------+-----------------------------------
                      Total |      7,288      100.00
*/

** Check dob
count if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*9999*")) //1
//list pid natregno if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*-9999*"))
replace dob=dd_dob if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*9999*")) //1 change

** Check age
drop checkage2
gen age2 = (dot - dob)/365.25
gen checkage2=int(age2)
drop age2
count if dob!=. & dot!=. & age!=checkage2 //6
//list pid cr5id fname lname dot dob age checkage2 if dob!=. & dot!=. & age!=checkage2
replace age=checkage2 if dob!=. & dot!=. & age!=checkage2 //6 changes

** Check no missing dxyr so this can be used in analysis
tab dxyr ,m //0 missing
/*
  Diagnosis |
       Year |      Freq.     Percent        Cum.
------------+-----------------------------------
       2008 |      1,158       15.89       15.89
       2013 |        910       12.49       28.38
       2014 |        925       12.69       41.07
       2015 |      1,120       15.37       56.44
       2016 |      1,131       15.52       71.95
       2017 |      1,034       14.19       86.14
       2018 |      1,010       13.86      100.00
------------+-----------------------------------
      Total |      7,288      100.00
*/

** Check non-2018 dxyrs are reportable
count if resident==2 //5
count if resident==99|resident==9 //105
count if recstatus==3|recstatus==5 //53 - found during cross-check process in dofile 20b_update previous years cancer.do
count if sex==9 //0
count if beh!=3 //310
//count if persearch>2 //249 - do not delete as IARCcrgTools MP check not done
count if siteiarc==25 //250 - 7 are non-melanoma skin cancers but they don't fall into the non-reportable skin cancer category; 1 is missed 2008 NMSC to be included in 2008,2013-2015 nonreportable ds
//list pid cr5id dxyr primarysite topography top morph morphology icd10 if siteiarc==25 ,string(30)
count if siteiarc==25 & morph!=8832 & morph!=8247 & morph!=9700 & morph!=8410 //243
count if siteiarc==25 & (morph==8832|morph==8247|morph==9700|morph==8410) //7

count //7288

** Save non-reportable dataset with 2008, 2013-2018 diagnoses
save "`datapath'\version09\3-output\2008_2013-2018_nonsurvival_nonreportable", replace
label data "2008 2013-2018 BNR-Cancer analysed data - Non-survival Dataset with Nonreportable Dx"
note: TS Excludes ineligible case definition
note: TS Includes unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs


** Removing cases not included for reporting: if case with MPs ensure record with persearch=1 is not dropped as used in survival dataset
drop if resident==2 //5 deleted - nonresident
drop if resident==99|resident==9 //105 deleted - resident unknown
drop if recstatus==3|recstatus==5 //0 deleted - ineligible case definition (found during cross-check process)
drop if sex==9 //0 deleted - sex unknown
drop if beh!=3 //257 deleted - non malignant
//drop if persearch>2 //249 - do not delete as IARCcrgTools MP check not done
count if siteiarc==25 //239
count if siteiarc==25 & morph!=8832 & morph!=8247 & morph!=9700 & morph!=8410 //232
count if siteiarc==25 & (morph==8832|morph==8247|morph==9700|morph==8410) //7
drop if siteiarc==25 & morph!=8832 & morph!=8247 & morph!=9700 & morph!=8410 //232 deleted - non reportable skin cancers
count if siteiarc==25 //7

tab persearch ,m

count //6690; 6689

** Perform duplicates check before IARCcrgTools MP Check
** First tag multiple PIDs and NRNs to use when filtering duplicate checks lists
** Identify duplicate PIDs
drop dup
sort pid
quietly by pid:  gen dup = cond(_N==1,0,_n)
count if dup>1 //149
//drop if dup>1
//drop dup

** Check for matches by natregno and pt names
drop dupnrntag
duplicates tag natregno, gen(dupnrntag)
count if dupnrntag>0 //326
count if dupnrntag==0 //6363

**********************
** Duplicate by NRN **
**********************
drop dupnrn
sort natregno lname fname pid
quietly by natregno :  gen dupnrn = cond(_N==1,0,_n)
sort natregno
count if dupnrn>0 //326
sort lname fname pid cr5id
order pid cr5id fname lname sex age natregno
count if dupnrn>0 & natregno!="" & natregno!="9999999999" & natregno!="999999-9999" & dup==1 & dupnrntag==0 //0 - no matches (used data editor and filtered)
//list pid cr5id fname lname age natregno addr slc if dupnrn>0 & natregno!="" & natregno!="999999-9999" & dup==1 & dupnrntag==0, nolabel sepby(dupnrntag) string(38)


************************
** Duplicate by NAMES **
************************
sort lname fname cr5id pid
quietly by lname fname :  gen duppt = cond(_N==1,0,_n)
sort lname fname
count if duppt>0 //567
sort lname fname pid cr5id
count if duppt>0 & dup==1 //141 - no matches (used below lists)
drop obsid
gen obsid=_n
//list pid cr5id fname lname age natregno addr slc if duppt>0 & dup==1
//list pid cr5id fname lname age natregno addr slc if duppt>0 & dup==1 & inrange(obsid, 0, 1112), sepby(lname)
//list pid cr5id fname lname age natregno addr slc if duppt>0 & dup==1 & inrange(obsid, 1113, 2224), sepby(lname)
drop dupnrn duppt obsid


*****************************
** IARCcrgTools check + MP **
*****************************
//replace mpseq=1 if mpseq==0 //... changes
tab mpseq ,m //0 missing
//list pid fname lname mptot if mpseq==. //reviewed in Stata's Browse/Edit + CR5db
replace mptot=1 if mpseq==. & mptot==. //0 changes
replace mpseq=1 if mpseq==. //0 changes

tab icd10 ,m //none missing

** Create dates for use in IARCcrgTools
drop dob_iarc dot_iarc
** Export dataset to run data in IARCcrg Tools (MP Check Programme)
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
replace BIRTHD="" if BIRTHD=="..." //46 changes
drop BIRTHDAY BIRTHMONTH BIRTHYR BIRTHMM BIRTHDD
rename BIRTHD dob_iarc
label var dob_iarc "IARC BirthDate"

** Check if mpseq was dropped; if so then need to create
tab mpseq ,m //0 missing
//gen mpseq_iarc=0 if persearch==1
//replace mpseq_iarc=1 if persearch!=1 & regexm(cr5id,"T1") //12 changes
//replace mpseq_iarc=2 if persearch!=1 & !(strmatch(strupper(cr5id), "*T1*")) //10 changes
sort pid

//export delimited pid cr5id dxyr mpseq sex topography morph beh grade basis dot_iarc dob_iarc age persearch ///
//using "`datapath'\version09\2-working\2008_2013-2018_iarccrgtools.txt", nolabel replace
/*
IARC crg Tools - see SOP for steps on how to perform below checks:

(1) Perform file transfer using '2008_2013-2018_iarccrgtools.txt'
(2) Perform multiple primary check using:
	'...\Sync\Cancer\CanReg5\Backups\Data Cleaning\2022\2022-08-16_Tuesday\2008_2013-2018_iarccrgtools.txt'
(3) Copy results of the checks and perform reviews of Warnings, Errors and MPs saved in Excel workbook:
	'...\Sync\Cancer\CanReg5\Backups\Data Cleaning\2022\2022-08-16_Tuesday\2008_2013-2018_IARC Checks_20220816.xlsx'
	AND saved in '.../version09/2-working/2008_2013-2018_IARC Checks_20220816.xlsx'
	Update the data based on these reviews.

Results of IARC Check Program:
    
	6690 records processed 
	 157 warnings
	   1 error
	
Results of IARC MP Program:

	6690 records processed 
	   0 excluded (non-malignant)
	 291 MPs (multiple tumours)
	   6 Duplicate registration
*/

** Corrections from IARC-Check results
drop dotyear
gen dotyear=year(dot)
count if dotyear!=dxyr //1 - pid 20180662 flagged with age error in IARC-Check
replace dxyr=2018 if pid=="20180662" & regexm(cr5id,"T1") //1 change
replace age=65 if pid=="20180662" & regexm(cr5id,"T1") //1 change

replace grade=5 if pid=="20170951" & regexm(cr5id,"T1")
replace basis=9 if pid=="20170951" & regexm(cr5id,"T1") //Dx from MedData

replace grade=6 if pid=="20180030" & regexm(cr5id,"T1")

replace top="421" if pid=="20180401" & regexm(cr5id,"T1")
replace topography=421 if pid=="20180401" & regexm(cr5id,"T1")
replace topcat=38 if pid=="20180401" & regexm(cr5id,"T1")

replace basis=6 if pid=="20180615" & regexm(cr5id,"T1")

** Update mpseq and mptot variables
** Check for matches by PID
//drop duppidtag
duplicates tag pid, gen(duppidtag)
count if duppidtag>0 //291
count if duppidtag==0 //6398

** Updates from IARC-MP Check
** Only report non-duplicate MPs (see IARC MP rules on recording and reporting)
display `"{browse "http://www.iacr.com.fr/images/doc/MPrules_july2004.pdf":IARC-MP}"'
tab persearch ,m
/*
              Person Search |      Freq.     Percent        Cum.
----------------------------+-----------------------------------
                   Done: OK |      6,575       98.30       98.30
                   Done: MP |        114        1.70      100.00
----------------------------+-----------------------------------
                      Total |      6,689      100.00

              Person Search |      Freq.     Percent        Cum.
----------------------------+-----------------------------------
                   Not done |          1        0.01        0.01
                   Done: OK |      6,575       98.28       98.30
                   Done: MP |        114        1.70      100.00
----------------------------+-----------------------------------
                      Total |      6,690      100.00
*/
//list pid cr5id if persearch==3 //3
//list pid cr5id if persearch==0 //1
//replace persearch=1 if pid=="20182401" & regexm(cr5id,"T1") //1 change - JC 17aug2022 accidentally didn't delete previously it's a nonreportable (recstatus==5)

** Updates from multiple primary report (define which is the MP so can remove in survival dataset):
//no updates needed as none to exclude

** Updates from MP exclusion and MP reports (excludes in-situ/unreportable cancers)
label drop persearch_lab
label define persearch_lab 0 "Not done" 1 "Done: OK" 2 "Done: MP" 3 "Done: Duplicate" 4 "Done: Non-IARC MP" 5 "Done: IARCcrgTools Excluded", modify
label values persearch persearch_lab

tab beh recstatus,m
replace persearch=5 if beh<3 //0 changes

tab persearch ,m
//list pid cr5id if persearch==2
** Using MP output from IARCcrgTools above, assign the MPs that are not considered MPs according to IARC reporting rules
** Note: tumours with higher morph value were kept; if the lower morph value had an earlier InciDate then this was kept
/* JC 16aug2022: this is old code from 20a_clean current year cancer.do
replace persearch=4 if pid=="20182295" & regexm(cr5id, "T2")
replace persearch=4 if pid=="20182253" & regexm(cr5id, "T2")
replace persearch=4 if pid=="20182211" & regexm(cr5id, "T2")
replace persearch=4 if pid=="20182096" & regexm(cr5id, "T2")
replace persearch=4 if pid=="20180887" & regexm(cr5id, "T2")
replace persearch=4 if pid=="20180152" & regexm(cr5id, "T2")
replace persearch=4 if pid=="20180068" & regexm(cr5id, "T2")
replace persearch=4 if pid=="20172049" & regexm(cr5id, "T1")
replace persearch=4 if pid=="20172041" & regexm(cr5id, "T2")
replace persearch=4 if pid=="20172019" & regexm(cr5id, "T2")
replace persearch=4 if pid=="20170586" & regexm(cr5id, "T2")
replace persearch=4 if pid=="20170572" & regexm(cr5id, "T2")
replace persearch=4 if pid=="20170541" & regexm(cr5id, "T2")
replace persearch=4 if pid=="20170328" & regexm(cr5id, "T2")
replace persearch=4 if pid=="20170100" & regexm(cr5id, "T2")
replace persearch=4 if pid=="20170011" & regexm(cr5id, "T2")
replace persearch=4 if pid=="20160096" & regexm(cr5id, "T2")
replace persearch=4 if pid=="20160056" & regexm(cr5id, "T2")
replace persearch=4 if pid=="20140849" & regexm(cr5id, "T3")
replace persearch=4 if pid=="20090019" & regexm(cr5id, "T3")
*/

** Assign person search variable
tab persearch ,m
/*
              Person Search |      Freq.     Percent        Cum.
----------------------------+-----------------------------------
                   Done: OK |      6,575       98.30       98.30
                   Done: MP |        114        1.70      100.00
----------------------------+-----------------------------------
                      Total |      6,689      100.00
*/

** Assign MPs first based on IARCcrgTools MP report (use later InciDate as the MP)
** Review the excel sheet with MP Check output - determine if any need to be updated by checking the last column with persearch (if both are =1 then change; if one is=1 and one is=2 ensure they are in sequential order according to InciDate)
replace persearch=2 if pid=="20180743" & regexm(cr5id, "T1") //1 change
replace persearch=2 if pid=="20180094" & regexm(cr5id, "T2") //1 change
replace persearch=2 if pid=="20171002" & regexm(cr5id, "T2") //1 change
replace persearch=2 if pid=="20170903" & regexm(cr5id, "T2") //1 change
replace persearch=2 if pid=="20160346" & regexm(cr5id, "T2") //1 change
replace persearch=2 if pid=="20155215" & regexm(cr5id, "T2") //1 change
replace persearch=2 if pid=="20151226" & regexm(cr5id, "T2") //1 change
replace persearch=2 if pid=="20151171" & regexm(cr5id, "T2") //1 change
replace persearch=2 if pid=="20151103" & regexm(cr5id, "T4") //1 change
replace persearch=2 if pid=="20151012" & regexm(cr5id, "T2") //1 change
replace persearch=2 if pid=="20151009" & regexm(cr5id, "T2") //1 change
replace persearch=2 if pid=="20150565" & regexm(cr5id, "T3") //1 change
replace persearch=2 if pid=="20150522" & regexm(cr5id, "T2") //1 change
replace persearch=2 if pid=="20150482" & regexm(cr5id, "T2") //1 change
replace persearch=2 if pid=="20150333" & regexm(cr5id, "T3") //1 change
replace persearch=2 if pid=="20150199" & regexm(cr5id, "T2") //1 change
replace persearch=2 if pid=="20150093" & regexm(cr5id, "T2") //1 change
replace persearch=2 if pid=="20145047" & regexm(cr5id, "T2") //1 change
replace persearch=2 if pid=="20141451" & regexm(cr5id, "T2") //1 change
replace persearch=2 if pid=="20141271" & regexm(cr5id, "T2") //1 change
replace cr5id="T3S1" if pid=="20141254" & dxyr==2018 //1 change
replace persearch=2 if pid=="20141254" & regexm(cr5id, "T3") //1 change
replace persearch=2 if pid=="20141253" & regexm(cr5id, "T2") //1 change
replace persearch=2 if pid=="20140849" & regexm(cr5id, "T2") //0 changes
replace persearch=2 if pid=="20140849" & regexm(cr5id, "T4") //1 change
replace persearch=2 if pid=="20130819" & regexm(cr5id, "T3") //1 change
replace persearch=2 if pid=="20130618" & regexm(cr5id, "T2") //1 change
replace persearch=2 if pid=="20130244" & regexm(cr5id, "T2") //1 change
replace persearch=2 if pid=="20130131" & regexm(cr5id, "T2") //1 change
replace persearch=2 if pid=="20130092" & regexm(cr5id, "T2") //1 change
replace persearch=2 if pid=="20130087" & regexm(cr5id, "T2") //1 change
replace persearch=2 if pid=="20080881" & regexm(cr5id, "T2") //1 change
replace persearch=2 if pid=="20080295" & regexm(cr5id, "T4") //1 change
replace persearch=2 if pid=="20080261" & regexm(cr5id, "T2") //1 change
replace persearch=2 if pid=="20080252" & regexm(cr5id, "T2") //1 change
replace persearch=2 if pid=="20080232" & regexm(cr5id, "T2") //1 change
replace persearch=2 if pid=="20080217" & regexm(cr5id, "T2") //1 change
replace persearch=2 if pid=="20080038" & regexm(cr5id, "T2") //1 change

** Switch persearch so that earlier InciDate is in sequential order
replace persearch=2 if pid=="20151236" & regexm(cr5id, "T1") //1 change
replace persearch=1 if pid=="20151236" & regexm(cr5id, "T2") //1 change

replace persearch=2 if pid=="20151020" & regexm(cr5id, "T1") //1 change
replace persearch=1 if pid=="20151020" & regexm(cr5id, "T2") //1 change

replace persearch=2 if pid=="20150238" & regexm(cr5id, "T1") //1 change
replace persearch=1 if pid=="20150238" & regexm(cr5id, "T2") //1 change

replace persearch=2 if pid=="20130022" & regexm(cr5id, "T1") //1 change
replace persearch=1 if pid=="20130022" & regexm(cr5id, "T2") //1 change

replace persearch=2 if pid=="20080215" & regexm(cr5id, "T1") //1 change
replace persearch=1 if pid=="20080215" & regexm(cr5id, "T2") //1 change

** Update cases wherein the IARC-MP Check states: the histology of the excluded case marked with ** should be reported in the case with the non-specific diagnosis which is recorded in the output file.
replace cr5id="T2S1" if pid=="20160436" & dxyr==2016
replace persearch=4 if pid=="20160436" & regexm(cr5id, "T2")
sort pid cr5id
replace hx="" if pid=="20160436" & regexm(cr5id, "T1")
replace morph=. if pid=="20160436" & regexm(cr5id, "T1")
replace morphcat=. if pid=="20160436" & regexm(cr5id, "T1")
fillmissing hx if pid=="20160436"
fillmissing morph if pid=="20160436"
fillmissing morphcat if pid=="20160436"

** Update cases wherein the IARC-MP Check states: Those marked with * are duplicate registrations following the IARC/IACR rules (2004)
replace cr5id="T2S1" if pid=="20160018" & dxyr==2016
replace persearch=4 if pid=="20160018" & regexm(cr5id, "T2")

replace cr5id="T2S1" if pid=="20130246" & dxyr==2016
replace persearch=4 if pid=="20130246" & regexm(cr5id, "T2")

replace cr5id="T5S1" if pid=="20130162" & dxyr==2017
replace persearch=4 if pid=="20130162" & regexm(cr5id, "T5")

replace cr5id="T2S1" if pid=="20080062" & dxyr==2018
replace persearch=4 if pid=="20080062" & regexm(cr5id, "T2")

replace cr5id="T2S1" if pid=="20080021" & dxyr==2018
replace persearch=4 if pid=="20080021" & regexm(cr5id, "T2")

** Remove MPs considered duplicates by IARC-MP Check
tab persearch ,m
drop if persearch>2 //6 deleted

** Update mpseq and mptot variables
** Check for matches by PID
drop duppidtag
duplicates tag pid, gen(duppidtag)
count if duppidtag>0 //280
count if duppidtag==0 //6403

sort pid
by pid: generate mptot2 = _N

replace mpseq=2 if persearch==2 & dup>0 //24 changes see pid 20151236
replace mpseq=1 if persearch==1 & dup>0 //39 changes see pid 20151236
count if mptot!=mptot2 //583
//list pid cr5id persearch mpseq mptot mptot2 if mptot!=mptot2 ,sepby(pid) nolabel
replace mptot=mptot2 if mptot!=mptot2 //583 changes

** Review mpseq, mptot and persearch for all MPs
list pid cr5id dxyr dot persearch mpseq mptot if duppidtag>0 ,sepby(pid) nolabel
//Corrections from above list review
replace mpseq=3 if pid=="20080295" & dxyr==2015
replace mpseq=4 if pid=="20080295" & dxyr==2016

replace mpseq=3 if pid=="20140849" & dxyr==2018

replace mpseq=3 if pid=="20141254" & dxyr==2018

replace mpseq=3 if pid=="20160136" & regexm(cr5id,"T3")

replace mpseq=3 if pid=="20160811" & regexm(cr5id,"T1")
//list pid cr5id dxyr dot persearch mpseq mptot if mptot>2 ,sepby(pid) nolabel


count if persearch==. //0
tab persearch ,m
/*
              Person Search |      Freq.     Percent        Cum.
----------------------------+-----------------------------------
                   Done: OK |      6,533       97.76       97.76
                   Done: MP |        150        2.24      100.00
----------------------------+-----------------------------------
                      Total |      6,683      100.00
*/

tab dxyr persearch ,m
/*
 Diagnosis |     Person Search
      Year |  Done: OK   Done: MP |     Total
-----------+----------------------+----------
      2008 |       808          7 |       815 
      2013 |       866         18 |       884 
      2014 |       866         19 |       885 
      2015 |     1,065         27 |     1,092 
      2016 |     1,035         35 |     1,070 
      2017 |       959         18 |       977 
      2018 |       934         26 |       960 
-----------+----------------------+----------
     Total |     6,533        150 |     6,683
*/

** Based on persearch, create variable to identify MPs vs single tumours
drop eidmp
gen eidmp=1 if persearch==1
replace eidmp=2 if persearch==2
label var eidmp "CR5 tumour events"
label define eidmp_lab 1 "single tumour" 2 "multiple tumour" ,modify
label values eidmp eidmp_lab
tab eidmp ,m
/*
     CR5 tumour |
         events |      Freq.     Percent        Cum.
----------------+-----------------------------------
  single tumour |      6,533       97.76       97.76
multiple tumour |        150        2.24      100.00
----------------+-----------------------------------
          Total |      6,683      100.00
*/

tab dxyr eidmp ,m
/*
 Diagnosis |   CR5 tumour events
      Year | single tu  multiple  |     Total
-----------+----------------------+----------
      2008 |       808          7 |       815 
      2013 |       866         18 |       884 
      2014 |       866         19 |       885 
      2015 |     1,065         27 |     1,092 
      2016 |     1,035         35 |     1,070 
      2017 |       959         18 |       977 
      2018 |       934         26 |       960 
-----------+----------------------+----------
     Total |     6,533        150 |     6,683 
*/
drop if eidmp==. //0 deleted; non-IARC MPs


** Check for any merges from the death match process whose death data didn't merge into its MP
count if persearch==2 & slc==2 & deathid==. //2 - PIDs 20130245 + 20130786 are among those dead but that are not on multi-yr deathdb
//list pid cr5id fname lname mpseq mptot if persearch==2 & slc==2 & deathid==.

** Create variable called "deceased" - same as AR's 2008 dofile called '3_merge_cancer_deaths.do'
tab slc ,m
drop deceased
gen deceased=1 if slc==2 //4213 changes
label var deceased "whether patient is deceased"
label define deceased_lab 1 "dead" 2 "alive at last contact" , modify
label values deceased deceased_lab
replace deceased=2 if slc==1 //2470 changes

tab slc deceased ,m
tab dxyr deceased ,m
/*
           |  whether patient is
 Diagnosis |       deceased
      Year |      dead  alive at  |     Total
-----------+----------------------+----------
      2008 |       618        197 |       815 
      2013 |       608        276 |       884 
      2014 |       582        303 |       885 
      2015 |       686        406 |     1,092 
      2016 |       652        418 |     1,070 
      2017 |       577        400 |       977 
      2018 |       490        470 |       960 
-----------+----------------------+----------
     Total |     4,213      2,470 |     6,683
*/

** Create the "patient" variable - same as AR's 2008 dofile called '3_merge_cancer_deaths.do'
drop patient
gen patient=.  
label var patient "cancer patient"
label define pt_lab 1 "patient" 2 "separate event",modify
label values patient pt_lab
replace patient=1 if eidmp==1 //6534 changes
replace patient=2 if eidmp==2 //150 changes
tab patient ,m
tab dxyr patient ,m
/*
 Diagnosis |    cancer patient
      Year |   patient  separate  |     Total
-----------+----------------------+----------
      2008 |       808          7 |       815 
      2013 |       866         18 |       884 
      2014 |       866         19 |       885 
      2015 |     1,065         27 |     1,092 
      2016 |     1,035         35 |     1,070 
      2017 |       959         18 |       977 
      2018 |       934         26 |       960 
-----------+----------------------+----------
     Total |     6,533        150 |     6,683
*/

** Create variable to identify DCI/DCN vs DCO
drop dcostatus
gen dcostatus=.
label define dcostatus_lab ///
1 "Eligible DCI/DCN-cancer,in CR5db" ///
2 "DCO" ///
3 "Ineligible DCI/DCN" ///
4 "NA-not cancer,not in CR5db" ///
5 "NA-dead,CR5db no death source" ///
6 "NA-not deceased" ///
7 "NA-not alive/dead" , modify
label values dcostatus dcostatus_lab
label var dcostatus "death certificate status"

order pid deathid cr5id eidmp dupsource ptrectot dcostatus primarysite
** Assign DCO Status=NA for all events that are not cancer 
replace dcostatus=2 if nftype==8 //831 changes
replace dcostatus=2 if basis==0 //208 changes
replace dcostatus=4 if cancer==2 & pid=="" //0 changes
count if slc!=2 //2470
//list cr5cod if slc!=2
replace dcostatus=6 if slc==1 //2470 changes
replace dcostatus=7 if slc==9 //0 changes
count if dcostatus==. & cr5cod!="" //2857
replace dcostatus=1 if cr5cod!="" & dcostatus==. & pid!="" //2857 changes
count if dcostatus==. & deathid!=. //310
count if dcostatus==. & pid!="" & deathid!=. //310 leave as is; it's a multiple source
//list pid cr5id deathid basis recstatus eidmp nftype dcostatus if dcostatus==. & pid!="" & record_id!=. ,nolabel
//replace dcostatus=5 if dcostatus==. & pid!="" & deathid!=.
replace dcostatus=2 if basis==0 //0 changes
count if dcostatus==. //317
count if dcostatus==. & pid=="" //0
count if dcostatus==. & pid!="" //317
count if dcostatus==. & pid!="" & slc==2 //317
//list pid cr5id deathid slc basis recstatus eidmp nftype cr5cod dd_coddeath if dcostatus==. & pid!="" ,string(30) nolabel
replace dcostatus=1 if dcostatus==. & pid!="" //317 changes
tab dcostatus ,m
tab dcostatus dxyr ,m
/*
    death certificate |                                Diagnosis Year
               status |      2008       2013       2014       2015       2016       2017       2018 |     Total
----------------------+-----------------------------------------------------------------------------+----------
Eligible DCI/DCN-canc |       560        498        318        561        480        391        366 |     3,174 
                  DCO |        58        110        264        125        172        186        124 |     1,039 
      NA-not deceased |       197        276        303        406        418        400        470 |     2,470 
----------------------+-----------------------------------------------------------------------------+----------
                Total |       815        884        885      1,092      1,070        977        960 |     6,683
*/

** Create variable to identify patient records
drop ptrectot
gen ptrectot=.
replace ptrectot=2 if ptrectot==. & basis==0 & eidmp==1 //451 changes
replace ptrectot=4 if ptrectot==. & basis==0 & eidmp==2 //18 changes
replace ptrectot=1 if ptrectot==. & eidmp==1 //6082 changes
replace ptrectot=3 if ptrectot==. & eidmp==2 //132 changes
label define ptrectot_lab 1 "CR5 pt with single event" 2 "DC with single event" 3 "CR5 pt with multiple events" ///
						  4 "DC with multiple events" 5 "CR5 pt: single event but multiple DC events" , modify
label values ptrectot ptrectot_lab
/*
Now check:
	(1) patient record with T1 are included in category 3 of ptrectot but leave eidmp=single tumour so this var can be used to count MPs
	(2) patient records with only 1 tumour but maybe labelled as T2 are not included in eidmp and are included in category 1 of ptrectot
*/
count if eidmp==2 & dupsource==1 //149 - all correct
order pid cr5id deathid eidmp dupsource ptrectot primarysite
//list pid eidmp dupsource duppid cr5id fname lname if eidmp==2 & dupsource==1

count if ptrectot==. //0


** Convert names to lower case and strip possible leading/trailing blanks
replace fname = lower(rtrim(ltrim(itrim(fname)))) //0changes
replace init = lower(rtrim(ltrim(itrim(init)))) //0 changes
replace dd_mname = lower(rtrim(ltrim(itrim(dd_mname)))) //0 changes
replace lname = lower(rtrim(ltrim(itrim(lname)))) //0 changes
	  
** Ensure death date is correct IF PATIENT IS DEAD
count if dod==. & slc==2 //0
drop dodyear
gen dodyear=year(dod) if dod!=.
count if dodyear==. & dod!=. //0
//list pid cr5id fname lname nftype dlc if dod==. & slc==2


** Check DCOs
tab basis ,m
/*
                     Basis Of Diagnosis |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                    DCO |        469        7.02        7.02
                          Clinical only |        369        5.52       12.54
Clinical Invest./Ult Sound/Exploratory  |        359        5.37       17.91
             Lab test (biochem/immuno.) |         97        1.45       19.36
                          Cytology/Haem |        204        3.05       22.42
     Hx of mets/Autopsy with Hx of mets |        130        1.95       24.36
Hx of primary/Autopsy with Hx of primar |      4,838       72.39       96.75
                                Unknown |        217        3.25      100.00
----------------------------------------+-----------------------------------
                                  Total |      6,683      100.00
*/


******************
** FINAL CHECKS **
******************
order pid cr5id top morph mpseq mptot persearch


******************
** MP variables **
******************
***************
** PERSEARCH **
***************

** persearch is used to identify MPs
** Check 1
count if persearch!=1 & (mpseq==0|mpseq==1) //0 - checked for any (1) in-situ NOT=Done: Exclude; (2) malignant NOT=Done: OK //143
//list pid mptot mpseq persearch beh cr5id if persearch!=1 & (mpseq==0|mpseq==1)

** Check 2
count if persearch==1 & cr5id!="T1S1" //43 - all are correct; leave as is
//list pid cr5id mptot mpseq persearch beh if persearch==1 & cr5id!="T1S1"

** Check 3
drop mptot2
sort pid
by pid: generate mptot2 = _N

count if mptot!=mptot2 //0
//list pid cr5id persearch mpseq mptot mptot2 if mptot!=mptot2 ,sepby(pid) nolabel
replace mptot=mptot2 if mptot!=mptot2 //0 changes

count if persearch==1 & mpseq>1 //32
//list pid cr5id mptot mpseq persearch beh if persearch==1 & mpseq>1
count if mptot==1 & mpseq>1 //39
count if mptot==1 & mpseq!=0 //538
//list pid cr5id mpseq mptot eidmp if mptot==1 & mpseq!=0 ,sepby(pid)
replace mpseq=0 if mptot==1 //538 changes

count if mptot==1 & persearch!=1 //7
list pid cr5id mpseq mptot eidmp if mptot==1 & persearch!=1 ,sepby(pid)
count if mptot==1 & eidmp!=1 //7
//list pid cr5id mpseq mptot eidmp if mptot==1 & eidmp!=1 ,sepby(pid)
replace persearch=1 if mptot==1 & persearch!=1 //7 changes
replace eidmp=1 if mptot==1 & eidmp!=1 //7 changes


** Check 4
tab persearch ,m
/*
              Person Search |      Freq.     Percent        Cum.
----------------------------+-----------------------------------
                   Done: OK |      6,540       97.86       97.86
                   Done: MP |        143        2.14      100.00
----------------------------+-----------------------------------
                      Total |      6,683      100.00				  
*/


*************
** PATIENT **
*************
order pid cr5id top morph mpseq mptot persearch patient eidmp ptrectot dcostatus

** Check 1
count if patient==1 & persearch==2 //0
//list pid cr5id patient persearch eidmp ptrectot if patient==1 & persearch==2

** Check 2
count if patient==2 & persearch==1 //7
//list pid cr5id patient persearch eidmp ptrectot if patient==2 & persearch==1
replace patient=1 if patient==2 & persearch==1 //7 changes

** Check 3
tab patient ,m
tab patient persearch ,m

***********
** EIDMP **
***********
** Check 1
count if eidmp==1 & persearch==2 //0

** Check 2
count if eidmp==1 & patient!=1 //0

** Check 3
count if eidmp==2 & patient!=2 //0

** Check 4
tab eidmp ,m
tab eidmp persearch ,m

**************
** PTRECTOT **
**************
** Check 1
count if ptrectot<3 & patient==2 //0
//list pid cr5id patient persearch eidmp ptrectot if ptrectot<3 & patient==2
replace ptrectot=3 if ptrectot<3 & patient==2 //0 changes

** Check 2
count if ptrectot<3 & persearch==2 //0

** Check 3
tab ptrectot ,m

*******************
** MPSEQ + MPTOT **
*******************
** Check 1
count if mptot==. & mpseq==0 //0
replace mptot=1 if mptot==. & mpseq==0 //0 changes

** Check 2
count if mptot==. & mpseq!=0 //0
//list pid cr5id mpseq mptot persearch patient eidmp ptrectot if mptot==. & mpseq!=0

** Check 3
count if mpseq!=0 & mptot==1 //0
replace mpseq=0 if mpseq!=0 & mptot==1 //0 changes

** Check 5
tab mptot ,m
tab mpseq ,m
tab mpseq mptot ,m

** Check 6
count if mptot>3 //4
//list pid cr5id mpseq mptot persearch patient eidmp ptrectot if mptot>3


******************
** Vital Status **
******************

** Check 1
count if dlc!=dod & slc==2 //305 - leave as is since DLC and DOD are now separate variables in CR5db
//replace dlc=dod if dlc!=dod & slc==2 // changes

** Check 2
count if dod!=. & slc!=2 //0

** Check 3
count if slc==2 & deceased!=1 //0
replace deceased=1 if slc==2 & deceased!=1 //0 changes

** Check 4
drop dodyear
gen dodyear=year(dod)
count if dd_dodyear==. & dod!=. //70 - not found in death data but pt deceased
count if dd_dodyear==. & dd_dod!=. //2 - there's no deathid
replace dd_dod=. if dd_dodyear==. & dd_dod!=. //2 changes
count if dodyear==. & dod!=. //0

** Check 5
count if dod==. & slc==2 //0

** Check 6
count if dod==. & deceased==1 //0

** Check 7
count if dcostatus!=6 & slc!=2 //0
replace dcostatus=6 if dcostatus!=6 & slc!=2 //0 changes

** Check 8
count if dcostatus!=2 & basis==0 //0
replace dcostatus=2 if dcostatus!=2 & basis==0 //0 changes

** Check 9
tab slc ,m
tab deceased ,m
//tab dod ,m
tab dcostatus ,m
tab dcostatus basis ,m

***************
** RECSTATUS **
***************
** Check 1
count if recstatus!=1 //209 - all are code 7-Abs, Pending REG Review
//list pid cr5id fname lname recstatus if recstatus!=1
//drop if recstatus==3 //7 deleted

** Check 2
tab recstatus ,m

***********
** BASIS **
***********
** Check 1
count if basis==. //0

** Check 2
tab basis ,m

***************
** BEHAVIOUR **
***************
** Check 1
count if beh==. //0

** Check 2
tab beh ,m


**************
** SITEIARC **
**************
** Check 1
count if siteiarc==. //0
tab siteiarc ,m

***********
** ICD10 **
***********
** Check 1
count if icd10=="" //0

** Check 2
tab siteicd10 ,m //all correct
//list pid cr5id fname lname icd10 siteiarc if  siteiarc<61 & siteicd10==.

***************
** SITECR5db **
***************
** Check 1
count if sitecr5db==. //1619 - all correct
tab sitecr5db ,m


************
** PARISH **
************
** Check 1
count if parish==. //0

** Check 2
count if parish!=. & parish!=99 & addr=="" //0

** Check 3
count if parish==. & addr!="" & addr!="99" //0

** Check 4
count if parish==. & dd_parish!=.

** Check 5
tab parish ,m
tab parish resident ,m

**************
** RESIDENT **
**************
** Check 1
count if resident==. //0

** Check 2
count if resident!=1 //0

** Check 3
count if resident!=1 & addr!="99" & addr!="" //0

** Check 4
count if resident!=1 & dd_address!="99" & dd_address!="" //0

** Check 5
count if resident!=1 & natregno!="" & natregno!="9999999999" //37 - correct

** Check 6
tab resident ,m
/*
   Resident |
     Status |      Freq.     Percent        Cum.
------------+-----------------------------------
        Yes |      6,683      100.00      100.00
------------+-----------------------------------
      Total |      6,683      100.00
*/

** Reviewed all non-residents using MedData
order pid cr5id dxyr fname lname init age dob natregno resident slc dlc dod dot top morph mpseq mptot persearch patient eidmp ptrectot dcostatus

*********
** SEX **
*********
** Check 1
tab sex ,m //none missing

*********
** AGE **
*********
** Check 1
count if age==.|age==999 //0

** Check 2
tab age ,m //0 missing; 10 are age>100

** Check 3
drop checkage2
gen age2 = (dot - dob)/365.25
gen checkage2=int(age2)
count if dob!=. & dot!=. & age!=checkage2 //0
//list pid dot dob age checkage2 cr5id if dob!=. & dot!=. & age!=checkage2
replace age=checkage2 if dob!=. & dot!=. & age!=checkage2 //0 changes
drop age2 checkage2

*********
** NRN **
********* 
count if length(natregno)==9 //0
count if length(natregno)==8 //0
count if length(natregno)==7 //0

** Identify possible matches using NRN
preserve
drop if natregno==""|natregno=="9999999999"|regexm(natregno,"9999") 
//remove blank/missing NRNs as these will be flagged as duplicates of each other
//94 deleted
sort natregno 
quietly by natregno : gen dupnrn = cond(_N==1,0,_n)
sort natregno lname fname pid 
count if dupnrn>0 //278 - all MPs: reviewed in Stata's Browse/Edit window
order pid cr5id natregno fname lname
//list pid cr5id natregno fname lname patient eidmp persearch mpseq mptot if dupnrn>0 ,sepby(pid) nolabel
restore

** Correction name found in above NRN duplicate check
replace lname="" if pid=="20130244" & regexm(cr5id,"T1")
fillmissing lname if pid=="20130244"

** Rename PID as MP identified from above NRN duplicate check
replace pid="20130878" if pid=="20160746"
replace cr5id="T2S1" if pid=="20130878" & dxyr==2016
replace dlc=. if pid=="20130878" & regexm(cr5id,"T1")
fillmissing dlc if pid=="20130878"
replace mpseq=1 if pid=="20130878" & dxyr==2013
replace mpseq=2 if pid=="20130878" & dxyr==2016
replace mptot=2 if pid=="20130878"
replace persearch=2 if pid=="20130878" & dxyr==2016
replace patient=2 if pid=="20130878" & dxyr==2016
replace eidmp=2 if pid=="20130878" & dxyr==2016
replace ptrectot=3 if pid=="20130878"

** Rename PID and remove one of the records as duplicate primary identified from above NRN duplicate check
replace pid="20130396" if pid=="20140830"
replace age=. if pid=="20130396" & dxyr==2014
replace dot=. if pid=="20130396" & dxyr==2014
replace cancer=. if pid=="20130396" & dxyr==2014
replace cod=. if pid=="20130396" & dxyr==2014
replace cr5cod="" if pid=="20130396" & dxyr==2014
replace labnum="" if pid=="20130396" & dxyr==2014
replace staging=. if pid=="20130396" & dxyr==2014
replace codcancer=. if pid=="20130396" & dxyr==2014
replace comments="" if pid=="20130396" & dxyr==2014
fillmissing age dot cancer cod cr5cod labnum if pid=="20130396"
fillmissing staging codcancer comments if pid=="20130396"

replace comments="JC 17AUG2022: see MasterDb #2605 + 3755."+" "+comments if pid=="20130396" & dxyr==2014
drop if pid=="20130396" & dxyr==2013 //1 deleted
replace dxyr=2013 if pid=="20130396" & dxyr==2014
replace dotyear=2013 if pid=="20130396"


************
** CANCER **
************ 
count if cancer!=dd_cancer //4036
count if cancer!=. & dd_cancer==. //2196
replace dd_cancer=cancer if cancer!=. & dd_cancer==. //2196 changes
count if cancer==. & dd_cancer!=. //1839
replace cancer=dd_cancer if cancer==. & dd_cancer!=. //1839 changes
count if cancer!=dd_cancer //1 - cancer=3 but no label for this so need to re-do the label as 14 records in all have cancer=3
replace cancer=dd_cancer if pid=="20150072" //1 change

label drop cancer_lab
label define cancer_lab 1 "cancer" 2 "not cancer" 3 "COD unknown" , modify
label values cancer cancer_lab
label var cancer "cancer in CODs"


*********
** DOB **
********* 
preserve
count if dob_iarc=="99999999" //0
replace dob_iarc="" if dob_iarc=="99999999" //0 changes
replace dob_iarc = lower(rtrim(ltrim(itrim(dob_iarc)))) //0 changes
gen dobyear2 = substr(dob_iarc,1,4)
gen dobmonth2 = substr(dob_iarc,5,2)
gen dobday2 = substr(dob_iarc,7,2)
drop if dobyear2=="9999" | dobmonth2=="99" | dobday2=="99" //0 deleted
drop dobday2 dobmonth2 dobyear2
drop if dob_iarc=="" | dob_iarc=="99999999" //44 deleted

** Look for duplicates - METHOD #1
sort lname fname dob_iarc
quietly by lname fname dob_iarc : gen dupnmdob = cond(_N==1,0,_n)
sort lname fname dob_iarc pid
count if dupnmdob>0 //280 - all MPs: reviewed PIDs in Stata's Browse/Edit
//list pid cr5id dob natregno fname lname patient eidmp persearch mpseq mptot if dupnmdob>0 ,sepby(pid) nolabel
restore

** No corrections from above list needed
//drop if pid=="20151107" //1 deleted - this is a duplicate of pid 20155185


***********
** NAMES **
***********
** Convert names to lower case and strip possible leading/trailing blanks
replace fname = lower(rtrim(ltrim(itrim(fname)))) //0 changes
replace init = lower(rtrim(ltrim(itrim(init)))) //0 changes
replace lname = lower(rtrim(ltrim(itrim(lname)))) //0 changes


****************
** DOT + DXYR **
****************
** Check 1
count if dxyr==. //0

** Check 2
count if dot==. //0


** Remove unmatched death certificates
count if pid=="" //0
drop if pid=="" //0 deleted

count if dupsource==. //3
replace dupsource=1 if dupsource==. //3 changes
count if eidmp==. //0
count if cr5id=="" //0

** Look for duplicates in cr5id
sort pid cr5id
quietly by pid cr5id : gen dupcr5id = cond(_N==1,0,_n)
sort pid cr5id
count if dupcr5id>0 //0

** Check non-2018 dxyrs are reportable
count if resident==2 //0
count if resident==99|resident==9 //0
count if recstatus==3|recstatus==5 //0
count if sex==9 //0
count if beh!=3 //0
count if persearch>2 //0
count if siteiarc==25 //7 - all are non-melanoma skin cancers but they don't fall into the non-reportable skin cancer category
//list pid cr5id primarysite topography top morph morphology icd10 if siteiarc==25

count //6682


** Create + Export variables for creating a CanReg5 Report database
replace DuplicateCheck=1 //5749 changes
count if ICCCcode!=iccc //6596
count if ICD10!=icd10 //6682

tab iccc ,m //86 missing - leave as is
tab ICCCcode ,m //6682 missing

tab icd10 ,m //0 missing
tab ICD10 ,m //6682 missing

count if siteiarc==. //0
count if siteicd10==. //42 - MPDs so leave as is
count if sitecr5db==. //1868

replace sitecr5db=1 if (regexm(icd10,"C00")|regexm(icd10,"C01")|regexm(icd10,"C02") ///
					 |regexm(icd10,"C03")|regexm(icd10,"C04")|regexm(icd10,"C05") ///
					 |regexm(icd10,"C06")|regexm(icd10,"C07")|regexm(icd10,"C08") ///
					 |regexm(icd10,"C09")|regexm(icd10,"C10")|regexm(icd10,"C11") ///
					 |regexm(icd10,"C12")|regexm(icd10,"C13")|regexm(icd10,"C14")) //39 changes
replace sitecr5db=2 if regexm(icd10,"C15") //14 changes
replace sitecr5db=3 if regexm(icd10,"C16") //48 changes
replace sitecr5db=4 if (regexm(icd10,"C18")|regexm(icd10,"C19")|regexm(icd10,"C20")|regexm(icd10,"C21")) //284 changes
replace sitecr5db=5 if regexm(icd10,"C22") //11 changes
replace sitecr5db=6 if regexm(icd10,"C25") //37 changes
replace sitecr5db=7 if regexm(icd10,"C32") //9 changes
replace sitecr5db=8 if (regexm(icd10,"C33")|regexm(icd10,"C34")) //55 changes
replace sitecr5db=9 if regexm(icd10,"C43") //9 changes
replace sitecr5db=10 if regexm(icd10,"C50") //266 changes
replace sitecr5db=11 if regexm(icd10,"C53") //54 changes
replace sitecr5db=12 if (regexm(icd10,"C54")|regexm(icd10,"C55")) //75 changes
replace sitecr5db=13 if regexm(icd10,"C56") //22 changes
replace sitecr5db=14 if regexm(icd10,"C61") //366 changes
replace sitecr5db=15 if regexm(icd10,"C62") // change
replace sitecr5db=16 if (regexm(icd10,"C64")|regexm(icd10,"C65")|regexm(icd10,"C66")|regexm(icd10,"C68")) //36 changes
replace sitecr5db=17 if regexm(icd10,"C67") //20 changes
replace sitecr5db=18 if (regexm(icd10,"C70")|regexm(icd10,"C71")|regexm(icd10,"C72")) //6 changes
replace sitecr5db=19 if regexm(icd10,"C73") //25 changes
replace sitecr5db=20 if siteiarc==61 //68 changes
replace sitecr5db=21 if (regexm(icd10,"C81")|regexm(icd10,"C82")|regexm(icd10,"C83")|regexm(icd10,"C84")|regexm(icd10,"C85")|regexm(icd10,"C88")|regexm(icd10,"C90")|regexm(icd10,"C96")) //74 changes
replace sitecr5db=22 if (regexm(icd10,"C91")|regexm(icd10,"C92")|regexm(icd10,"C93")|regexm(icd10,"C94")|regexm(icd10,"C95")) //32 changes
replace sitecr5db=23 if (regexm(icd10,"C17")|regexm(icd10,"C23")|regexm(icd10,"C24")) //18 changes
replace sitecr5db=24 if (regexm(icd10,"C30")|regexm(icd10,"C31")) //5 changes
replace sitecr5db=25 if (regexm(icd10,"C40")|regexm(icd10,"C41")|regexm(icd10,"C45")|regexm(icd10,"C47")|regexm(icd10,"C49")) //14 changes
replace sitecr5db=26 if siteiarc==25 //1 change
replace sitecr5db=27 if (regexm(icd10,"C51")|regexm(icd10,"C52")|regexm(icd10,"C57")|regexm(icd10,"C58")) //11 changes
replace sitecr5db=28 if (regexm(icd10,"C60")|regexm(icd10,"C63")) //4 changes
replace sitecr5db=29 if (regexm(icd10,"C74")|regexm(icd10,"C75")) //2 changes
replace sitecr5db=30 if siteiarc==59 //7 changes
replace sitecr5db=31 if siteiarc==60 //2 changes
replace sitecr5db=32 if siteiarc==64 //0 changes
replace sitecr5db=33 if (regexm(icd10,"C38")|regexm(icd10,"C37")|regexm(icd10,"C69")) //5 changes

tab sitecr5db ,m //0 missing


** JC 17aug2022: add in COD variable to CR5rptdb but first need to clean COD variable by merging with mortality data
count if cod==. & dd_coddeath!="" //1871
count if cod==. & cancer!=. //1868
count if cod==. & dd_cancer!=. //1868
tab dxyr cod ,m

** SF requested by email 12aug2022 % pts who died at home vs hospital in 2018; since death matching ds doesn't have this categorized but the mortality ds does I'll merge POD from that ds using deathid
preserve
use "`datapath'\version04\3-output\2016+2017_prep mort_identifiable" ,clear
append using "`datapath'\version04\3-output\2018_prep mort_identifiable"
append using "`datapath'\version04\3-output\2019+2020_prep mort_identifiable"
gen mortds=1
rename record_id deathid
rename cod cod_mort
rename cancer cancer_mort
drop if did!="T1" //82 deleted
keep deathid pod cancer_mort cod_mort mortds
count //3261
save "`datapath'\version09\2-working\2016-2020_prep mort_identifiable_POD+COD" ,replace
restore

merge m:1 deathid using "`datapath'\version09\2-working\2016-2020_prep mort_identifiable_POD+COD"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                         5,957
        from master                     4,644  (_merge==1)
        from using                      1,313  (_merge==2)

    Matched                             2,038  (_merge==3)
    -----------------------------------------

    Result                      Number of obs
    -----------------------------------------
    Not matched                         6,841
        from master                     6,735  (_merge==1)
        from using                        106  (_merge==2)

    Matched                               553
        not updated                       553  (_merge==3)
        missing updated                     0  (_merge==4)
        nonmissing conflict                 0  (_merge==5)
    -----------------------------------------
*/
count if _merge==2 //1313
count if mortds==1 & _merge==2 //1313
drop if _merge==2 //1313 deleted

tab pod dxyr ,m
tab slc dxyr ,m
tab pod dxyr if slc==2
/*
  Place of Death from |                                Diagnosis Year
    National Register |      2008       2013       2014       2015       2016       2017       2018 |     Total
----------------------+-----------------------------------------------------------------------------+----------
                  QEH |        21         59         59        163        341        260        244 |     1,147 
              At Home |        21         39         38        106        187        183        121 |       695 
   Geriatric Hospital |         2          1          5          0          7          9          9 |        33 
     Con/Nursing Home |         3          0          2         12         16         19         10 |        62 
    District Hospital |         0          0          1          0          2          1          1 |         5 
 Psychiatric Hospital |         0          1          0          2          0          2          0 |         5 
     Bayview Hospital |         0          0          2          4          8         13          6 |        33 
Sandy Crest/FMH/Sparm |         0          0          0          1          0          1          1 |         3 
          Other/Hotel |         1          1          2          8         14         19          9 |        54 
                   ND |         0          0          0          0          0          0          1 |         1 
----------------------+-----------------------------------------------------------------------------+----------
                Total |        48        101        109        296        575        507        402 |     2,038 
*/

count if pod!=. & slc!=2 //0

count if dxyr==2018 & pod!=. //402
count if dxyr==2018 & slc==2 //490

count if cod==. & cod_mort!=. //1576
replace cod=cod_mort if cod==. & cod_mort!=. //1576 changes
count if cancer==. & cancer_mort!=. //0
count if cod==. & cancer!=. //292
replace cod=1 if cancer==1 & cod==. //162 changes
replace cod=2 if cancer==2 & cod==. //130 changes

count if cod==. & slc==2 //44
count if cod_mort==. & slc==2 //2174
count if cancer==. & slc==2 //44
count if cancer_mort==. & slc==2 //2174

tab cod cancer ,m
tab cod_mort cancer_mort ,m
drop cod_mort cancer_mort mortds

tab dxyr cod if slc==2 ,m
/*
 Diagnosis |               COD categories
      Year | Dead of c  Dead of o  Not known          . |     Total
-----------+--------------------------------------------+----------
      2008 |       486        125          7          0 |       618 
      2013 |       551         47          6          4 |       608 
      2014 |       563         18          0          0 |       581 
      2015 |       646         36          1          3 |       686 
      2016 |       592         38          0         22 |       652 
      2017 |       533         34          0         10 |       577 
      2018 |       451         34          0          5 |       490 
-----------+--------------------------------------------+----------
     Total |     3,822        332         14         44 |     4,212 
*/

sort pid mpseq cr5id

preserve
** Create IDs + CR5db-derived variables to match CR5db and the format of a CR5db export
gen str_mpseq=mpseq
tostring str_mpseq ,replace

gen TumourIDSourceTable=pid+"01"+"0"+str_mpseq
count if length(TumourIDSourceTable)!=12 //0
count if TumourIDSourceTable=="" //0

gen SourceRecordID=TumourIDSourceTable+"01"
count if length(SourceRecordID)!=14 //0
count if SourceRecordID=="" //0

rename stda STDataAbstractor

gen STYR=year(stdoa)
tostring STYR, replace
gen STMONTH=month(stdoa)
gen str2 STMM = string(STMONTH, "%02.0f")
gen STDAY=day(stdoa)
gen str2 STDD = string(STDAY, "%02.0f")
gen STDATE=STYR+STMM+STDD
replace STDATE="" if STDATE=="..." //0 changes
drop STMONTH STDAY STYR STMM STDD
rename STDATE STSourceDate

count if STSourceDate!="" & length(STSourceDate)!=8 //0

rename nftype NFType
rename sourcename SourceName
rename doctor Doctor
rename pod PlaceOfDeath
replace cod=9 if cod==3 // changes
rename cod CausesOfDeath

gen ADMYR=year(admdate)
tostring ADMYR, replace
gen ADMMONTH=month(admdate)
gen str2 ADMMM = string(ADMMONTH, "%02.0f")
gen ADMDAY=day(admdate)
gen str2 ADMDD = string(ADMDAY, "%02.0f")
gen ADMDATE=ADMYR+ADMMM+ADMDD
replace ADMDATE="" if ADMDATE=="..." //0 changes
drop ADMMONTH ADMDAY ADMYR ADMMM ADMDD
rename ADMDATE AdmissionDate

count if AdmissionDate!="" & length(AdmissionDate)!=8 //0

gen DFCYR=year(dfc)
tostring DFCYR, replace
gen DFCMONTH=month(dfc)
gen str2 DFCMM = string(DFCMONTH, "%02.0f")
gen DFCDAY=day(dfc)
gen str2 DFCDD = string(DFCDAY, "%02.0f")
gen DFCDATE=DFCYR+DFCMM+DFCDD
replace DFCDATE="" if DFCDATE=="..." //0 changes
drop DFCMONTH DFCDAY DFCYR DFCMM DFCDD
drop DateFirstConsultation
rename DFCDATE DateFirstConsultation

count if DateFirstConsultation!="" & length(DateFirstConsultation)!=8 //0


gen RTYR=year(rtdate)
tostring RTYR, replace
gen RTMONTH=month(rtdate)
gen str2 RTMM = string(RTMONTH, "%02.0f")
gen RTDAY=day(rtdate)
gen str2 RTDD = string(RTDAY, "%02.0f")
gen RTDATE=RTYR+RTMM+RTDD
replace RTDATE="" if RTDATE=="..." //0 changes
drop RTMONTH RTDAY RTYR RTMM RTDD
rename RTDATE RTRegDate

count if RTRegDate!="" & length(RTRegDate)!=8 //0


rename streviewer STReviewer

//cr5id

rename recstatus RecordStatus
rename checkstatus Checkstatus
rename mpseq MPSeq
rename mptot MPTot

gen UPDYR=year(ttupdate)
tostring UPDYR, replace
gen UPDMONTH=month(ttupdate)
gen str2 UPDMM = string(UPDMONTH, "%02.0f")
gen UPDDAY=day(ttupdate)
gen str2 UPDDD = string(UPDDAY, "%02.0f")
gen UPDDATE=UPDYR+UPDMM+UPDDD
replace UPDDATE="" if UPDDATE=="..." //0 changes
drop UPDMONTH UPDDAY UPDYR UPDMM UPDDD
rename UPDDATE UpdateDate

count if UpdateDate!="" & length(UpdateDate)!=8 //0

//ObsoleteFlagTumourTable

gen TumourID=TumourIDSourceTable
gen PatientIDTumourTable=pid
drop PatientRecordIDTumourTable
gen PatientRecordIDTumourTable=pid+"01"

rename tumourupdatedby TumourUpdatedBy
//TumourUnduplicationStatus 

rename patient MPStatus
rename siteiarc SiteIARC
rename siteicd10 SiteICD10
rename sitecr5db SiteCR5

rename ttda TTDataAbstractor

gen TTYR=year(ttdoa)
tostring TTYR, replace
gen TTMONTH=month(ttdoa)
gen str2 TTMM = string(TTMONTH, "%02.0f")
gen TTDAY=day(ttdoa)
gen str2 TTDD = string(TTDAY, "%02.0f")
gen TTDATE=TTYR+TTMM+TTDD
replace TTDATE="" if TTDATE=="..." //0 changes
drop TTMONTH TTDAY TTYR TTMM TTDD
rename TTDATE TTAbstractionDate

count if TTAbstractionDate!="" & length(TTAbstractionDate)!=8 //0

//DuplicateCheck

rename parish Parish
rename age Age
rename topography Topography
rename morph Morphology
rename lat Laterality
rename beh Behaviour
rename grade Grade
rename basis BasisOfDiagnosis
rename tnmcatstage TNMCatStage
rename tnmantstage TNMAntStage
rename etnmcatstage EssTNMCatStage
rename etnmantstage EssTNMAntStage
rename staging SummaryStaging

gen INCIDYR=year(dot)
tostring INCIDYR, replace
gen INCIDMONTH=month(dot)
gen str2 INCIDMM = string(INCIDMONTH, "%02.0f")
gen INCIDDAY=day(dot)
gen str2 INCIDDD = string(INCIDDAY, "%02.0f")
gen INCID=INCIDYR+INCIDMM+INCIDDD
replace INCID="" if INCID=="..." //0 changes
drop INCIDMONTH INCIDDAY INCIDYR INCIDMM INCIDDD
drop IncidenceDate
rename INCID IncidenceDate

count if IncidenceDate!="" //0
count if IncidenceDate!="" & length(IncidenceDate)!=8 //0

count if dxyr!=dotyear //0
rename dxyr DiagnosisYear
rename consultant Consultant
drop ICCCcode
rename iccc ICCCcode
drop ICD10
rename icd10 ICD10
rename rx1 Treatment1

gen RX1YR=year(rx1d)
tostring RX1YR, replace
gen RX1MONTH=month(rx1d)
gen str2 RX1MM = string(RX1MONTH, "%02.0f")
gen RX1DAY=day(rx1d)
gen str2 RX1DD = string(RX1DAY, "%02.0f")
gen RX1DATE=RX1YR+RX1MM+RX1DD
replace RX1DATE="" if RX1DATE=="..." //0 changes
drop RX1MONTH RX1DAY RX1YR RX1MM RX1DD
rename RX1DATE Treatment1Date

count if Treatment1Date!="" & length(Treatment1Date)!=8 //0

rename rx2 Treatment2

gen RX2YR=year(rx2d)
tostring RX2YR, replace
gen RX2MONTH=month(rx2d)
gen str2 RX2MM = string(RX2MONTH, "%02.0f")
gen RX2DAY=day(rx2d)
gen str2 RX2DD = string(RX2DAY, "%02.0f")
gen RX2DATE=RX2YR+RX2MM+RX2DD
replace RX2DATE="" if RX2DATE=="..." //0 changes
drop RX2MONTH RX2DAY RX2YR RX2MM RX2DD
rename RX2DATE Treatment2Date

count if Treatment2Date!="" & length(Treatment2Date)!=8 //0

rename rx3 Treatment3

gen RX3YR=year(rx3d)
tostring RX3YR, replace
gen RX3MONTH=month(rx3d)
gen str2 RX3MM = string(RX3MONTH, "%02.0f")
gen RX3DAY=day(rx3d)
gen str2 RX3DD = string(RX3DAY, "%02.0f")
gen RX3DATE=RX3YR+RX3MM+RX3DD
replace RX3DATE="" if RX3DATE=="..." //0 changes
drop RX3MONTH RX3DAY RX3YR RX3MM RX3DD
rename RX3DATE Treatment3Date

count if Treatment3Date!="" & length(Treatment3Date)!=8 //0

rename rx4 Treatment4

gen RX4YR=year(rx4d)
tostring RX4YR, replace
gen RX4MONTH=month(rx4d)
gen str2 RX4MM = string(RX4MONTH, "%02.0f")
gen RX4DAY=day(rx4d)
gen str2 RX4DD = string(RX4DAY, "%02.0f")
gen RX4DATE=RX4YR+RX4MM+RX4DD
replace RX4DATE="" if RX4DATE=="..." //0 changes
drop RX4MONTH RX4DAY RX4YR RX4MM RX4DD
rename RX4DATE Treatment4Date

count if Treatment4Date!="" & length(Treatment4Date)!=8 //0

rename rx5 Treatment5

gen RX5YR=year(rx5d)
tostring RX5YR, replace
gen RX5MONTH=month(rx5d)
gen str2 RX5MM = string(RX5MONTH, "%02.0f")
gen RX5DAY=day(rx5d)
gen str2 RX5DD = string(RX5DAY, "%02.0f")
gen RX5DATE=RX5YR+RX5MM+RX5DD
replace RX5DATE="" if RX5DATE=="..." //0 changes
drop RX5MONTH RX5DAY RX5YR RX5MM RX5DD
rename RX5DATE Treatment5Date

count if Treatment5Date!="" & length(Treatment5Date)!=8 //0

rename orx1 OtherTreatment1
rename orx2 OtherTreatment2
rename norx1 NoTreatment1
rename norx2 NoTreatment2
rename ttreviewer TTReviewer

rename pid RegistryNumber
rename persearch Personsearch
replace lname=""
rename lname LastName
replace fname=""
rename fname FirstName

gen BIRTHYR=year(dob)
tostring BIRTHYR, replace
gen BIRTHMONTH=month(dob)
gen str2 BIRTHMM = string(BIRTHMONTH, "%02.0f")
gen BIRTHDAY=day(dob)
gen str2 BIRTHDD = string(BIRTHDAY, "%02.0f")
gen BIRTHD=BIRTHYR+BIRTHMM+BIRTHDD
replace BIRTHD="" if BIRTHD=="..." //46 changes
drop BIRTHDAY BIRTHMONTH BIRTHYR BIRTHMM BIRTHDD
rename BIRTHD BirthDate

count if BirthDate!="" & length(BirthDate)!=8 //0

** Change sex label for matching with CR5db data
tab sex ,m
labelbook sex_lab
label drop sex_lab
rename sex sex_old
gen sex=1 if sex_old==2
replace sex=2 if sex_old==1
drop sex_old
label define sex_lab 1 "Male" 2 "Female" 9 "Unknown", modify
label values sex sex_lab
tab sex ,m

rename sex Sex
replace resident=9 if resident==99 //0 changes
rename resident ResidentStatus
rename slc StatusLastContact

gen DLCYR=year(dlc)
tostring DLCYR, replace
gen DLCMONTH=month(dlc)
gen str2 DLCMM = string(DLCMONTH, "%02.0f")
gen DLCDAY=day(dlc)
gen str2 DLCDD = string(DLCDAY, "%02.0f")
gen DLCD=DLCYR+DLCMM+DLCDD
replace DLCD="" if DLCD=="..." //46 changes
drop DLCDAY DLCMONTH DLCYR DLCMM DLCDD
rename DLCD DateLastContact

count if DateLastContact!="" & length(DateLastContact)!=8 //0

gen DODYR=year(dod)
tostring DODYR, replace
gen DODMONTH=month(dod)
gen str2 DODMM = string(DODMONTH, "%02.0f")
gen DODDAY=day(dod)
gen str2 DODDD = string(DODDAY, "%02.0f")
gen DODD=DODYR+DODMM+DODDD
replace DODD="" if DODD=="..." //46 changes
drop DODDAY DODMONTH DODYR DODMM DODDD
rename DODD DateOfDeath

count if DateOfDeath!="" & length(DateOfDeath)!=8 //0

rename ptda PTDataAbstractor

gen PTYR=year(ptdoa)
tostring PTYR, replace
gen PTMONTH=month(ptdoa)
gen str2 PTMM = string(PTMONTH, "%02.0f")
gen PTDAY=day(ptdoa)
gen str2 PTDD = string(PTDAY, "%02.0f")
gen PTD=PTYR+PTMM+PTDD
replace PTD="" if PTD=="..." //46 changes
drop PTDAY PTMONTH PTYR PTMM PTDD
rename PTD PTCasefindingDate

count if PTCasefindingDate!="" & length(PTCasefindingDate)!=8 //0

//ObsoleteFlagPatientTable

gen PatientRecordID = PatientRecordIDTumourTable

rename patientupdatedby PatientUpdatedBy

gen PTYR=year(ptupdate)
tostring PTYR, replace
gen PTMONTH=month(ptupdate)
gen str2 PTMM = string(PTMONTH, "%02.0f")
gen PTDAY=day(ptupdate)
gen str2 PTDD = string(PTDAY, "%02.0f")
gen PTD=PTYR+PTMM+PTDD
replace PTD="" if PTD=="..." //46 changes
drop PTDAY PTMONTH PTYR PTMM PTDD
rename PTD PatientUpdateDate

count if PatientUpdateDate!="" & length(PatientUpdateDate)!=8 //0

//PatientRecordStatus
//PatientCheckStatus

rename retsource RetrievalSource
rename notesseen NotesSeen

gen NSYR=year(nsdate)
tostring NSYR, replace
gen NSMONTH=month(nsdate)
gen str2 NSMM = string(NSMONTH, "%02.0f")
gen NSDAY=day(nsdate)
gen str2 NSDD = string(NSDAY, "%02.0f")
gen NSD=NSYR+NSMM+NSDD
replace NSD="" if NSD=="..." //46 changes
drop NSDAY NSMONTH NSYR NSMM NSDD
rename NSD NotesSeenDate

count if NotesSeenDate!="" & length(NotesSeenDate)!=8 //0

rename fretsource FurtherRetrievalSource
rename ptreviewer PTReviewer
rename alco RFAlcohol
rename alcoamount AlcoholAmount
rename alcofreq AlcoholFreq
rename smoke RFSmoking
rename smokeamount SmokingAmount
rename smokefreq SmokingFreq
rename smokedur SmokingDuration
rename smokedurfreq SmokingDurationFreq


sort RegistryNumber MPSeq cr5id

order TumourIDSourceTable SourceRecordID STDataAbstractor STSourceDate NFType SourceName Doctor PlaceOfDeath CausesOfDeath  AdmissionDate DateFirstConsultation RTRegDate STReviewer cr5id RecordStatus Checkstatus MultiplePrimary MPSeq MPTot UpdateDate ObsoleteFlagTumourTable TumourID PatientIDTumourTable PatientRecordIDTumourTable TumourUpdatedBy TumourUnduplicationStatus TTDataAbstractor TTAbstractionDate DuplicateCheck MPStatus SiteIARC SiteICD10 SiteCR5 Parish Age Topography Morphology Laterality Behaviour Grade BasisOfDiagnosis TNMCatStage TNMAntStage EssTNMCatStage EssTNMAntStage SummaryStaging IncidenceDate DiagnosisYear Consultant ICCCcode ICD10 Treatment1 Treatment1Date Treatment2 Treatment2Date Treatment3 Treatment3Date Treatment4 Treatment4Date Treatment5 Treatment5Date OtherTreatment1 OtherTreatment2 NoTreatment1 NoTreatment2 TTReviewer RegistryNumber Personsearch LastName FirstName BirthDate Sex ResidentStatus StatusLastContact DateLastContact DateOfDeath PTDataAbstractor PTCasefindingDate ObsoleteFlagPatientTable PatientRecordID PatientUpdatedBy PatientUpdateDate PatientRecordStatus PatientCheckStatus RetrievalSource NotesSeen NotesSeenDate FurtherRetrievalSource PTReviewer RFAlcohol AlcoholAmount AlcoholFreq RFSmoking SmokingAmount SmokingFreq SmokingDuration SmokingDurationFreq

export delimited TumourIDSourceTable SourceRecordID STDataAbstractor STSourceDate NFType SourceName Doctor PlaceOfDeath CausesOfDeath  AdmissionDate DateFirstConsultation RTRegDate STReviewer cr5id RecordStatus Checkstatus MultiplePrimary MPSeq MPTot UpdateDate ObsoleteFlagTumourTable TumourID PatientIDTumourTable PatientRecordIDTumourTable TumourUpdatedBy TumourUnduplicationStatus TTDataAbstractor TTAbstractionDate DuplicateCheck MPStatus SiteIARC SiteICD10 SiteCR5 Parish Age Topography Morphology Laterality Behaviour Grade BasisOfDiagnosis TNMCatStage TNMAntStage EssTNMCatStage EssTNMAntStage SummaryStaging IncidenceDate DiagnosisYear Consultant ICCCcode ICD10 Treatment1 Treatment1Date Treatment2 Treatment2Date Treatment3 Treatment3Date Treatment4 Treatment4Date Treatment5 Treatment5Date OtherTreatment1 OtherTreatment2 NoTreatment1 NoTreatment2 TTReviewer RegistryNumber Personsearch LastName FirstName BirthDate Sex ResidentStatus StatusLastContact DateLastContact DateOfDeath PTDataAbstractor PTCasefindingDate ObsoleteFlagPatientTable PatientRecordID PatientUpdatedBy PatientUpdateDate PatientRecordStatus PatientCheckStatus RetrievalSource NotesSeen NotesSeenDate FurtherRetrievalSource PTReviewer RFAlcohol AlcoholAmount AlcoholFreq RFSmoking SmokingAmount SmokingFreq SmokingDuration SmokingDurationFreq  ///
using "`datapath'\version09\3-output\2008_2013-2018_cr5rptdb.txt", nolabel replace

export_excel TumourIDSourceTable SourceRecordID STDataAbstractor STSourceDate NFType SourceName Doctor PlaceOfDeath CausesOfDeath  AdmissionDate DateFirstConsultation RTRegDate STReviewer cr5id RecordStatus Checkstatus MultiplePrimary MPSeq MPTot UpdateDate ObsoleteFlagTumourTable TumourID PatientIDTumourTable PatientRecordIDTumourTable TumourUpdatedBy TumourUnduplicationStatus TTDataAbstractor TTAbstractionDate DuplicateCheck MPStatus SiteIARC SiteICD10 SiteCR5 Parish Age Topography Morphology Laterality Behaviour Grade BasisOfDiagnosis TNMCatStage TNMAntStage EssTNMCatStage EssTNMAntStage SummaryStaging IncidenceDate DiagnosisYear Consultant ICCCcode ICD10 Treatment1 Treatment1Date Treatment2 Treatment2Date Treatment3 Treatment3Date Treatment4 Treatment4Date Treatment5 Treatment5Date OtherTreatment1 OtherTreatment2 NoTreatment1 NoTreatment2 TTReviewer RegistryNumber Personsearch LastName FirstName BirthDate Sex ResidentStatus StatusLastContact DateLastContact DateOfDeath PTDataAbstractor PTCasefindingDate ObsoleteFlagPatientTable PatientRecordID PatientUpdatedBy PatientUpdateDate PatientRecordStatus PatientCheckStatus RetrievalSource NotesSeen NotesSeenDate FurtherRetrievalSource PTReviewer RFAlcohol AlcoholAmount AlcoholFreq RFSmoking SmokingAmount SmokingFreq SmokingDuration SmokingDurationFreq  ///
using "`datapath'\version09\3-output\2008_2013-2018_cr5rptdb_excel.xlsx", firstrow(variables) nolabel replace

keep TumourIDSourceTable SourceRecordID STDataAbstractor STSourceDate NFType SourceName Doctor PlaceOfDeath CausesOfDeath  AdmissionDate DateFirstConsultation RTRegDate STReviewer cr5id RecordStatus Checkstatus MultiplePrimary MPSeq MPTot UpdateDate ObsoleteFlagTumourTable TumourID PatientIDTumourTable PatientRecordIDTumourTable TumourUpdatedBy TumourUnduplicationStatus TTDataAbstractor TTAbstractionDate DuplicateCheck MPStatus SiteIARC SiteICD10 SiteCR5 Parish Age Topography Morphology Laterality Behaviour Grade BasisOfDiagnosis TNMCatStage TNMAntStage EssTNMCatStage EssTNMAntStage SummaryStaging IncidenceDate DiagnosisYear Consultant ICCCcode ICD10 Treatment1 Treatment1Date Treatment2 Treatment2Date Treatment3 Treatment3Date Treatment4 Treatment4Date Treatment5 Treatment5Date OtherTreatment1 OtherTreatment2 NoTreatment1 NoTreatment2 TTReviewer RegistryNumber Personsearch LastName FirstName BirthDate Sex ResidentStatus StatusLastContact DateLastContact DateOfDeath PTDataAbstractor PTCasefindingDate ObsoleteFlagPatientTable PatientRecordID PatientUpdatedBy PatientUpdateDate PatientRecordStatus PatientCheckStatus RetrievalSource NotesSeen NotesSeenDate FurtherRetrievalSource PTReviewer RFAlcohol AlcoholAmount AlcoholFreq RFSmoking SmokingAmount SmokingFreq SmokingDuration SmokingDurationFreq

count //6682
save "`datapath'\version09\2-working\2008_2013-2018_cr5rptdb", replace
restore

count //6682

//erase "`datapath'\version09\2-working\2008_2013-2018_cr5rptdb.dta"


** SF requested by email 16aug2022: length of time between Dx and Death for 2015 and 2018
//	Mean and median duration in months from date of incident diagnosis to date of abstraction
** First calculate the difference in months between these 2 dates 
// (need to add in qualifier to ignore missing dod dates)
gen doddotdiff = (dod - dot) / (365/12) if dod!=. & dot!=.
** Now calculate the overall mean & median
preserve
drop if doddotdiff==. //209 deleted
summ doddotdiff //displays mean
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  doddotdiff |      4,212    17.06014    25.28071          0   165.9945
*/
summ doddotdiff, detail //displays mean + median (median is the percentile next to 50%)
/*
                         doddotdiff
-------------------------------------------------------------
      Percentiles      Smallest
 1%            0              0
 5%            0              0
10%            0              0       Obs               4,212
25%     .6246575              0       Sum of wgt.       4,212

50%      5.70411                      Mean           17.06014
                        Largest       Std. dev.      25.28071
75%     24.01644       155.9014
90%     49.70959       156.5918       Variance       639.1141
95%     71.17809        158.926       Skewness       2.329444
99%     121.1836       165.9945       Kurtosis        9.41532
*/
gen k=1
drop if k!=1

table k, stat(q2 doddotdiff) stat(min doddotdiff) stat(max doddotdiff) stat(mean doddotdiff)
** Now save the p50, min, max and mean for  SF's data request
sum doddotdiff
sum doddotdiff ,detail
gen median_doddotdiff=r(p50)
gen mean_doddotdiff=r(mean)
gen range_lower=r(min)
gen range_upper=r(max)
gen year=1

collapse year median_doddotdiff range_lower range_upper mean_doddotdiff
order year median_doddotdiff range_lower range_upper mean_doddotdiff
save "`datapath'\version09\2-working\doddotdiff" ,replace
restore

** Now calculate mean & median per diagnosis year
// 2015
preserve
drop if dxyr!=2015 //5590 deleted
drop if doddotdiff==. //406 deleted
summ doddotdiff, detail
/*
                         doddotdiff
-------------------------------------------------------------
      Percentiles      Smallest
 1%            0              0
 5%            0              0
10%            0              0       Obs                 686
25%     .4273973              0       Sum of wgt.         686

50%          4.8                      Mean           14.38797
                        Largest       Std. dev.      19.12978
75%     22.48767       77.72055
90%     44.77808       80.51507       Variance       365.9486
95%     58.22466       81.13972       Skewness       1.503493
99%     74.10411       81.20548       Kurtosis       4.437584
*/
gen k=1
drop if k!=1

table k, stat(q2 doddotdiff) stat(min doddotdiff) stat(max doddotdiff) stat(mean doddotdiff)
** Now save the p50, min, max and mean for  SF's data request
sum doddotdiff
sum doddotdiff ,detail
gen median_doddotdiff=r(p50)
gen mean_doddotdiff=r(mean)
gen range_lower=r(min)
gen range_upper=r(max)
gen year=2

collapse year median_doddotdiff range_lower range_upper mean_doddotdiff
append using "`datapath'\version09\2-working\doddotdiff"

sort year
order year median_doddotdiff range_lower range_upper mean_doddotdiff
save "`datapath'\version09\2-working\doddotdiff" ,replace
restore

// 2018
preserve
drop if dxyr!=2018 //5722 deleted
drop if doddotdiff==. //470 deleted
summ doddotdiff, detail
/*
                         doddotdiff
-------------------------------------------------------------
      Percentiles      Smallest
 1%            0              0
 5%            0              0
10%            0              0       Obs                 490
25%     .3287671              0       Sum of wgt.         490

50%     3.090411                      Mean           9.548471
                        Largest       Std. dev.      12.27191
75%     15.35343       43.79178
90%     31.47945       43.85753       Variance       150.5998
95%     36.59178       43.92329       Skewness       1.268874
99%     43.52877       44.97534       Kurtosis       3.358156
*/
gen k=1
drop if k!=1

table k, stat(q2 doddotdiff) stat(min doddotdiff) stat(max doddotdiff) stat(mean doddotdiff)
** Now save the p50, min, max and mean for  SF's data request
sum doddotdiff
sum doddotdiff ,detail
gen median_doddotdiff=r(p50)
gen mean_doddotdiff=r(mean)
gen range_lower=r(min)
gen range_upper=r(max)
gen year=3

collapse year median_doddotdiff range_lower range_upper mean_doddotdiff
append using "`datapath'\version09\2-working\doddotdiff"

sort year
order year median_doddotdiff range_lower range_upper mean_doddotdiff

label define year_lab 1 "2008,2013-2018" 2 "2015" 3 "2018" , modify
label values year year_lab

save "`datapath'\version09\2-working\doddotdiff" ,replace
restore

** Remove unnecessary variables
drop dotmonth dotday dotyear2 str_sourcerecordid sourcetotal sourcetot_orig str_pid2 patienttotal patienttot str_patientidtumourtable mpseq2 sourceseq tumseq tumsourceseq dobyear dobmonth dobday rx1year rx1month rx1day rx2year rx2month rx2day rx3year rx3month rx3day stdyear stdmonth stdday rdyear rdmonth rdday rptyear rptmonth rptday sxyear sxmonth sxday physyear physmonth physday imgyear imgmonth imgday admyear admmonth admday dfcyear dfcmonth dfcday rtyear rtmonth rtday topcheckcat morphcheckcat hxcheckcat agecheckcat hxfamcat sexcheckcat sitecheckcat latcheckcat behcheckcat behsitecheckcat gradecheckcat bascheckcat stagecheckcat dotcheckcat dxyrcheckcat rxcheckcat othtreat1 orxcheckcat notreat1 notreat2 norxcheckcat sname sourcecheckcat doccheckcat docaddrcheckcat rptcheckcat imagecheckcat datescheckcat residentcheckcat crosschk pid_all currentdatept nrnday dob_yr dob_year year2 dobchk nrnid currentdatett checkage morphology dupobs1 dupobs2 dupobs3 dupobs4 dupobs5 dupobs6 dupobs7 dupobs8 tempvarn dupobs9 currentdatest dupst pidobsid pidobstot nonreportable currentds pid_prev cstatus sourcetot skin codcancer miss2013abs sitear dd_dodyear iarcflag prev all SurgicalFindings SurgicalFindingsDate ImagingResults ImagingResultsDate PhysicalExam PhysicalExamDate tnmcat tnmant esstnmcat esstnmant rx4year rx4month rx4day rx5year rx5month rx5day laterality behaviour str_grade bas diagyr notiftype survtime_days survtime_months dup_pid previousds tomatch deathds matched nomatch dupdob duplndob dup dupnrntag dot_iarc dob_iarc duppidtag mptot2 dupcr5id _merge


** Tables for quick reference
tab dxyr eidmp ,m
/*
 Diagnosis |   CR5 tumour events
      Year | single tu  multiple  |     Total
-----------+----------------------+----------
      2008 |       808          7 |       815 
      2013 |       868         16 |       884 
      2014 |       865         19 |       884 
      2015 |     1,070         22 |     1,092 
      2016 |     1,034         36 |     1,070 
      2017 |       959         18 |       977 
      2018 |       934         26 |       960 
-----------+----------------------+----------
     Total |     6,538        144 |     6,682
*/

tab dxyr persearch ,m
/*
 Diagnosis |     Person Search
      Year |  Done: OK   Done: MP |     Total
-----------+----------------------+----------
      2008 |       808          7 |       815 
      2013 |       868         16 |       884 
      2014 |       865         19 |       884 
      2015 |     1,070         22 |     1,092 
      2016 |     1,034         36 |     1,070 
      2017 |       959         18 |       977 
      2018 |       934         26 |       960 
-----------+----------------------+----------
     Total |     6,538        144 |     6,682
*/

** Breakdown of in-situ
tab dxyr beh ,m
/*
 Diagnosis | Behaviour
      Year | Malignant |     Total
-----------+-----------+----------
      2008 |       815 |       815 
      2013 |       884 |       884 
      2014 |       884 |       884 
      2015 |     1,092 |     1,092 
      2016 |     1,070 |     1,070 
      2017 |       977 |       977 
      2018 |       960 |       960 
-----------+-----------+----------
     Total |     6,682 |     6,682
*/


** Count # of patients with eligible non-dup tumours
tab dxyr if patient==1
/*
  Diagnosis |
       Year |      Freq.     Percent        Cum.
------------+-----------------------------------
       2008 |        808       12.36       12.36
       2013 |        868       13.28       25.63
       2014 |        865       13.23       38.87
       2015 |      1,070       16.37       55.23
       2016 |      1,034       15.82       71.05
       2017 |        959       14.67       85.71
       2018 |        934       14.29      100.00
------------+-----------------------------------
      Total |      6,538      100.00
*/

** Count # of eligible non-dup tumours
tab dxyr if eidmp==1
/*
  Diagnosis |
       Year |      Freq.     Percent        Cum.
------------+-----------------------------------
       2008 |        808       12.36       12.36
       2013 |        868       13.28       25.63
       2014 |        865       13.23       38.87
       2015 |      1,070       16.37       55.23
       2016 |      1,034       15.82       71.05
       2017 |        959       14.67       85.71
       2018 |        934       14.29      100.00
------------+-----------------------------------
      Total |      6,538      100.00
*/

** Count # of eligible non-dup MPs
tab dxyr if eidmp==2
/*
  Diagnosis |
       Year |      Freq.     Percent        Cum.
------------+-----------------------------------
       2008 |          7        4.86        4.86
       2013 |         16       11.11       15.97
       2014 |         19       13.19       29.17
       2015 |         22       15.28       44.44
       2016 |         36       25.00       69.44
       2017 |         18       12.50       81.94
       2018 |         26       18.06      100.00
------------+-----------------------------------
      Total |        144      100.00
*/

count //6682


** Save this cleaned dataset with reportable cases and identifiable data
save "`datapath'\version09\3-output\2008_2013-2018_cancer_reportable_nonsurvival_identifiable", replace
label data "2008, 2013-2018 BNR-Cancer identifiable data - Reportable Non-survival Identifiable Dataset"
note: TS This dataset was NOT used for 2016-2018 annual report
note: TS Includes ineligible case definition, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs - these are removed in dataset used for analysis

** Create cleaned dataset with reportable cases but de-identified data
drop fname lname natregno init dob resident parish recnum cfdx labnum SurgicalNumber specimen clindets cytofinds md consrpt sxfinds physexam imaging duration onsetint certifier dfc streviewer addr birthdate hospnum comments

save "`datapath'\version09\3-output\2008_2013-2018_cancer_reportable_nonsurvival_deidentified", replace
label data "2008, 2013-2018 BNR-Cancer de-identified data - Reportable Non-survival De-identified Dataset"
note: TS This dataset was used for 2016-2018 annual report
note: TS Includes ineligible case definition, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs - these are removed in dataset used for analysis
note: TS Excludes identifiable data but contains unique IDs to allow for linking data back to identifiable data
