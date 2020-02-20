** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			35_review cancer.do
    //  project:				BNR
    //  analysts:				Jacqueline CAMPBELL
    //  date first created                26-SEP-2019
    //  date last modified	              06-FEB-2020
    //  algorithm task			Reporting on review process
    //  status                            Completed
    //  objectve                          To check accuracy and efficiency of manual reviewing vs code only cleaning.


    ** General algorithm set-up
    version 16
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
    log using "`logpath'\35_review cancer.smcl", replace
** HEADER -----------------------------------------------------

STOP - add cancer API dofile to this dofile and run after first set of code is run
** Import BNR-Cancer log that was filtered with username=shellyann.forde and events=created(only)
** L:\ is on DG laptop 2
clear
import delimited "L:\BNRCancer_Logging_2019-12-05_1326.csv"
rename v2 username
drop if username!="shellyann.forde"
egen temp=sieve(v3), char(0123456789)
gen rec_id=substr(temp,1,3)
rename v1 rvdate
drop temp v3 v4
save "L:\BNRCancer_Log.dta",replace
clear
** Import Incorrect Reviewer report
import delimited "L:\BNRCancer_DATA_2019-12-05_1321.csv"
tostring record_id, gen(rec_id)
save "L:\BNRCancer_Reviewer.dta",replace
clear
use "L:\BNRCancer_Log.dta", replace
merge m:1 rec_id using "L:\BNRCancer_Reviewer.dta"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         2,046
        from master                     2,046  (_merge==1)
        from using                          0  (_merge==2)

    matched                               410  (_merge==3)
    -----------------------------------------
*/
list rec_id _merge if rvreviewer==13 //all matched
count if rvreviewer==13 & _merge!=3 //0

STOP Update BNR-Cancer redcap via API, see below dofile:
/*
	(1) This dofile saved in PROJECTS p_117
	(2) Import data from REDCap into Stata via redcap API using project called 'BNR-CVD'
	(3) A user must have API rights to the redcap project for this process to work
*/
version 16.0
set more off
clear 

**********************
** IMPORT DATA FROM **
** REDCAP TO STATA  **
**********************
local token "4E70DFD2A50F62E535E12C53D14E41FB"
local outfile "exported_cancer_reviewer_20190925.csv"

shell curl		///
	--output `outfile' 		///
	--form token=`token'	///
	--form content=record 	///
	--form format=csv 		///
	--form type=flat 		///
	--form fields[]=record_id ///
	--form fields[]=redcap_event_name ///
	--form fields[]=rvreviewer "https://caribdata.org/redcap/api/"

import delimited `outfile'

keep if rvreviewer==13
export delimited using "cancer_reviewer_20190925.csv", replace
br

**********************
** EXPORT DATA FROM **
** STATA TO REDCAP  **
**********************
version 16.0
set more off
clear 

local token "4E70DFD2A50F62E535E12C53D14E41FB"
local outfile "cancer_reviewer_20190925.csv"

shell curl --output `outfile' --form token=`token' --form content=record --form format=csv --form type=flat --form fields[]=record_id --form fields[]=rvreviewer"https://caribdata.org/redcap/api/"
import delimited `outfile'

replace rvreviewer=09 // corrrect reviewer from KWG to SF
local fileforimport "data_for_import_cancer_20190925.csv"
export delimited using `fileforimport', nolabel replace


local cmd="C:\Windows\System32\curl.exe" 			///
          + " --form token=`token'" 	///
          + " --form content=record" 	///
          + " --form format=csv" 		///
          + " --form type=flat" 		///
          + " --form data="+char(34)+"<`fileforimport'"+char(34) /// The < is critical! It causes curl to read the contents of the file, not just send the file name.
          + " https://caribdata.org/redcap/api/"

shell `cmd'



Update below flag names to match BNR-Cancer redcap db reviewer instruments

*****************
** DATA QUALITY  
*****************
** Create quality report - corrections per reviewer
forvalues j=1/55 {
	gen flag`j'=0
}

label var flag1 "Record ID"
label var flag2 "Redcap Event"
label var flag3 "ABS DateTime"
label var flag4 "ABS DA"
label var flag5 "ABS Other DA"
label var flag6 "Certificate Type"
label var flag7 "ABS Reg Dept #"
label var flag8 "ABS District"
label var flag9 "Pt Name"
label var flag10 "Pt Address"
label var flag11 "Pt Parish"
label var flag12 "Sex"
label var flag13 "Age"
label var flag14 "Age (time period)"
label var flag15 "Date of Death"
label var flag16 "Death Year"
label var flag17 "NRN documented?"
label var flag18 "NRN"
label var flag19 "Marital Status"
label var flag20 "Occupation"
label var flag21 "Duration"
label var flag22 "Duration (time period)"
label var flag23 "COD 1a"
label var flag24 "Onset 1a"
label var flag25 "Onset 1a (time period)"
label var flag26 "COD 1b"
label var flag27 "Onset 1b"
label var flag28 "Onset 1b (time period)"
label var flag29 "COD 1c"
label var flag30 "Onset 1c"
label var flag31 "Onset 1c (time period)"
label var flag32 "COD 1d"
label var flag33 "Onset 1d"
label var flag34 "Onset 1d (time period)"
label var flag35 "COD 2a"
label var flag36 "Onset 2a"
label var flag37 "Onset 2a (time period)"
label var flag38 "COD 2b"
label var flag39 "Onset 2b"
label var flag40 "Onset 2b (time period)"
label var flag41 "Place of Death"
label var flag42 "Death Parish"
label var flag43 "Reg Date"
label var flag44 "Certifier"
label var flag45 "Certifer Address"
label var flag46 "Name Match"
label var flag47 "ABS Complete?"
label var flag48 "TF DateTime"
label var flag49 "TF DA"
label var flag50 "TF Reg # START"
label var flag51 "TF District START"
label var flag52 "TF Reg # END"
label var flag53 "TF District END"
label var flag54 "TF Comments"
label var flag55 "TF Complete?"

replace flag1=flag1+1 if record_id==...|rvreviewer==...

* ************************************************************************
* PROGRESS REPORT: REVIEWING 2015 ABS
* Using Redcap BNR-Cancer database
**************************************************************************

** LOAD the review dataset
import excel using "`datapath'\version02\1-input\BNRCancer_DATA_2020-02-06_1344_excel.xlsx", firstrow

count //1,388 at 20190926 08:00


** PREP dataset
******************
* Reviewing Form *
******************
gen event=.
replace event=1 if redcap_event_name=="reviewing_arm_3"
replace event=2 if redcap_event_name=="reviewed_arm_4"
drop redcap_event_name
label var event "Redcap Event Name"
label define event_lab 1 "reviewing_arm_3" 2 "reviewed_arm_4", modify
label values event event_lab

gen instrument=.
replace instrument=1 if redcap_repeat_instrument=="reviewing_pt"
replace instrument=2 if redcap_repeat_instrument=="reviewing_tt"
replace instrument=3 if redcap_repeat_instrument=="reviewing_st"
drop redcap_repeat_instrument
label var instrument "Redcap Instrument Name"
label define instrument_lab 1 "reviewing_pt" 2 "reviewing_tt" 3 "reviewing_st", modify
label values instrument instrument_lab

rename redcap_repeat_instance instance
label var instance "Redcap Instance ID"

format rvdoastart %tcCCYY-NN-DD_HH:MM:SS
label var rvdoastart "Review Start DateTime"

label var rvreviewer "Reviewer"
label define rvreviewer_lab 1 "JC" 9 "SF", modify
label values rvreviewer rvreviewer_lab

label var rvdxyr "Diagnosis Year Reviewed"

label var reviewingtot "Total Cases Reviewed"

format rvdoaend %tcCCYY-NN-DD_HH:MM:SS
label var rvdoaend "Review End DateTime"

label var rvelapsed "Time Review Total"

label var rverrtot "Reviewing-PT+TT+ST Error Total"

rename reviewing_complete rvformstatus
label var rvformstatus "Reviewing Form Status"
*********************
* Reviewing PT Form *
*********************
label var rvcr5pid "CR5 PID"
label var rvptda "Reviewing-PT DA"
label var rvptoda "Reviewing-PT Oth. DA"
label var rvpterrtot "Reviewing-PT Error Total"
label var rvptcfda "CR5 PT DA"
label var rvptdoa "CR5 PT Date"
label var rvptcstatus "CR5 Case Status"
label var rvptretsource "CR5 Ret. Source"
label var rvptnotesseen "CR5 Notes Seen"
label var rvptnsdate "CR5 Notes Seen Date"
label var rvptfretsource "CR5 Fur.Ret. Source"
label var rvptlname "CR5 Last Name"
label var rvptfname "CR5 First Name"
label var rvptinit "CR5 Initials"
label var rvptdob "CR5 DOB"
label var rvptsex "CR5 Sex"
label var rvptnrn "CR5 NRN"
label var rvpthospnum "CR5 Hospital #"
label var rvptresident "CR5 Resident Status"
label var rvptslc "CR5 Status Last Contact"
label var rvptdlc "CR5 Date Last Contact"
label var rvptcomments "CR5 Comments"

label var rvptcfdaold "CR5 PT DA: old value"
label var rvptcfdanew "CR5 PT DA: new value"
label var rvptdoaold "CR5 PT Date: old value"
label var rvptdoanew "CR5 PT Date: new value"
label var rvptcstatusold "CR5 Case Status: old value"
label var rvptcstatusnew "CR5 Case Status: new value"
label var rvptretsourceold "CR5 Ret. Source: old value"
label var rvptretsourcenew "CR5 Ret. Source: new value"
label var rvptnotesseenold "CR5 Notes Seen: old value"
label var rvptnotesseennew "CR5 Notes Seen: new value"
label var rvptnsdateold "CR5 Notes Seen Date: old value"
label var rvptnsdatenew "CR5 Notes Seen Date: new value"
label var rvptfretsourceold "CR5 Fur.Ret. Source: old value"
label var rvptfretsourcenew "CR5 Fur.Ret. Source: new value"
label var rvptlnameold "CR5 Last Name: old value"
label var rvptlnamenew "CR5 Last Name: new value"
label var rvptfnameold "CR5 First Name: old value"
label var rvptfnamenew "CR5 First Name: new value"
label var rvptinitold "CR5 Initials: old value"
label var rvptinitnew "CR5 Initials: new value"
label var rvptdobold "CR5 DOB: old value"
label var rvptdobnew "CR5 DOB: new value"
label var rvptdobdqi "DOB DQI"
label var rvptsexold "CR5 Sex: old value"
label var rvptsexnew "CR5 Sex: new value"
label var rvptsexdqi "Sex DQI"
label var rvptnrnold "CR5 NRN: old value"
label var rvptnrnnew "CR5 NRN: new value"
label var rvpthospnumold "CR5 Hospital #: old value"
label var rvpthospnumnew "CR5 Hospital #: new value"
label var rvptresidentold "CR5 Resident Status: old value"
label var rvptresidentnew "CR5 Resident Status: new value"
label var rvptresidentdqi "Resident Status DQI"
label var rvptslcold "CR5 Status Last Contact: old value"
label var rvptslcnew "CR5 Status Last Contact: new value"
label var rvptslcdqi "Status Last Contact DQI"
label var rvptdlcold "CR5 Date Last Contact: old value"
label var rvptdlcnew "CR5 Date Last Contact: new value"
label var rvptdlcdqi "Date Last Contact DQI"
label var rvptcommentsold "CR5 Comments: old value"
label var rvptcommentsnew "CR5 Comments: new value"

rename reviewing_pt_complete rvptformstatus
label var rvptformstatus "Reviewing-PT Form Status"
*********************
* Reviewing TT Form *
*********************
label var rvttcr5id "CR5 Tumour ID"
label var rvttda "Reviewing-TT DA"
label var rvttoda "Reviewing-TT Oth. DA"
label var rvtterrtot "Reviewing-TT Error Total"
label var rvttabsda "CR5 TT DA"
label var rvttadoa "CR5 TT Date"
label var rvttparish "CR5 Parish"
label var rvttaddr "CR5 Address"
label var rvttage "CR5 Age"
label var rvttprimsite "CR5 Primary Site"
label var rvtttop "CR5 Topography"
label var rvtthx "CR5 Histology"
label var rvttmorph "CR5 Morphology"
label var rvttlat "CR5 Laterality"
label var rvttbeh "CR5 Behaviour"
label var rvttgrade "CR5 Grade"
label var rvttbasis "CR5 Basis of Dx"
label var rvttstaging "CR5 Staging"
label var rvttdot "CR5 Incidence Date"
label var rvttdxyr "CR5 Diagnosis Year"
label var rvttconsult "CR5 Consultant"
label var rvttrx1 "CR5 Treatment 1"
label var rvttrx1d "CR5 Treatment 1 Date"
label var rvttrx2 "CR5 Treatment 2"
label var rvttrx2d "CR5 Treatment 2 Date"
label var rvttrx3 "CR5 Treatment 3"
label var rvttrx3d "CR5 Treatment 3 Date"
label var rvttrx4 "CR5 Treatment 4"
label var rvttrx4d "CR5 Treatment 4 Date"
label var rvttrx5 "CR5 Treatment 5"
label var rvttrx5d "CR5 Treatment 5 Date"
label var rvttorx1 "CR5 Other Treatment 1"
label var rvttorx2 "CR5 Other Treatment 2"
label var rvttnorx1 "CR5 No Treatment 1"
label var rvttnorx2 "CR5 No Treatment 2"
label var rvttrecstatus "CR5 Record Status"

label var rvttabsdaold "CR5 TT DA: old value"
label var rvttabsdanew "CR5 TT DA: new value"
label var rvttadoaold "CR5 TT Date: old value"
label var rvttadoanew "CR5 TT Date: new value"
label var rvttparishold "CR5 Parish: old value"
label var rvttparishnew "CR5 Parish: new value"
label var rvttaddrold "CR5 Address: old value"
label var rvttaddrnew "CR5 Address: new value"
label var rvttageold "CR5 Age: old value"
label var rvttagenew "CR5 Age: new value"
label var rvttagedqi "Age DQI"
label var rvttprimsiteold "CR5 Primary Site: old value"
label var rvttprimsitenew "CR5 Primary Site: new value"
label var rvtttopold "CR5 Topography: old value"
label var rvtttopnew "CR5 Topography: new value"
label var rvtttopdqi "Topography DQI"
label var rvtthxold "CR5 Histology: old value"
label var rvtthxnew "CR5 Histology: new value"
label var rvttmorphold "CR5 Morphology: old value"
label var rvttmorphnew "CR5 Morphology: new value"
label var rvttmorphdqi "Morphology DQI"
label var rvttlatold "CR5 Laterality: old value"
label var rvttlatnew "CR5 Laterality: new value"
label var rvttlatdqi "Laterality DQI"
label var rvttbehold "CR5 Behaviour: old value"
label var rvttbehnew "CR5 Behaviour: new value"
label var rvttbehdqi "Behaviour DQI"
label var rvttgradeold "CR5 Grade: old value"
label var rvttgradenew "CR5 Grade: new value"
label var rvttbasisold "CR5 Basis of Dx: old value"
label var rvttbasisnew "CR5 Basis of Dx: new value"
label var rvttbasisdqi "Basis of Dx DQI"
label var rvttstagingold "CR5 Staging: old value"
label var rvttstagingnew "CR5 Staging: new value"
label var rvttstagingdqi "Staging DQI"
label var rvttdotold "CR5 Incidence Date: old value"
label var rvttdotnew "CR5 Incidence Date: new value"
label var rvttdotdqi "Incidence Date DQI"
label var rvttdxyrold "CR5 Diagnosis Year: old value"
label var rvttdxyrnew "CR5 Diagnosis Year: new value"
label var rvttconsultold "CR5 Consultant: old value"
label var rvttconsultnew "CR5 Consultant: new value"
label var rvttrx1old "CR5 Treatment 1: old value"
label var rvttrx1new "CR5 Treatment 1: new value"
label var rvttrx1dqi "Treatment 1 DQI"
label var rvttrx1dold "CR5 Treatment 1 Date: old value"
label var rvttrx1dnew "CR5 Treatment 1 Date: new value"
label var rvttrx1ddqi "Treatment 1 Date DQI"
label var rvttrx2old "CR5 Treatment 2: old value"
label var rvttrx2new "CR5 Treatment 2: new value"
label var rvttrx2dqi "Treatment 2 DQI"
label var rvttrx2dold "CR5 Treatment 2 Date: old value"
label var rvttrx2dnew "CR5 Treatment 2 Date: new value"
label var rvttrx2ddqi "Treatment 2 Date DQI"
label var rvttrx3old "CR5 Treatment 3: old value"
label var rvttrx3new "CR5 Treatment 3: new value"
label var rvttrx3dqi "Treatment 3 DQI"
label var rvttrx3dold "CR5 Treatment 3 Date: old value"
label var rvttrx3dnew "CR5 Treatment 3 Date: new value"
label var rvttrx3ddqi "Treatment 3 Date DQI"
label var rvttrx4old "CR5 Treatment 4: old value"
label var rvttrx4new "CR5 Treatment 4: new value"
label var rvttrx4dqi "Treatment 4 DQI"
label var rvttrx4dold "CR5 Treatment 4 Date: old value"
label var rvttrx4dnew "CR5 Treatment 4 Date: new value"
label var rvttrx4ddqi "Treatment 4 Date DQI"
label var rvttrx5old "CR5 Treatment 5: old value"
label var rvttrx5new "CR5 Treatment 5: new value"
label var rvttrx5dqi "Treatment 5 DQI"
label var rvttrx5dold "CR5 Treatment 5 Date: old value"
label var rvttrx5dnew "CR5 Treatment 5 Date: new value"
label var rvttrx5ddqi "Treatment 5 Date DQI"
label var rvttorx1old "CR5 Other Treatment 1: old value"
label var rvttorx1new "CR5 Other Treatment 1: new value"
label var rvttorx2old "CR5 Other Treatment 2: old value"
label var rvttorx2new "CR5 Other Treatment 2: new value"
label var rvttnorx1old "CR5 No Treatment 1: old value"
label var rvttnorx1new "CR5 No Treatment 1: new value"
label var rvttnorx2old "CR5 No Treatment 2: old value"
label var rvttnorx2new "CR5 No Treatment 2: new value"
label var rvttrecstatusold "CR5 Record Status: old value"
label var rvttrecstatusnew "CR5 Record Status: new value"

rename reviewing_tt_complete rvttformstatus
label var rvttformstatus "Reviewing-TT Form Status"
*********************
* Reviewing ST Form *
*********************
label var rvstcr5id "CR5 Source ID"
label var rvstda "Reviewing-ST DA"
label var rvstoda "Reviewing-ST Oth. DA"
label var rvsterrtot "Reviewing-ST Error Total"
label var rvstrectype "Reviewing-ST Record Type"
label var rvstabsda "CR5 ST DA"
label var rvstadoa "CR5 ST Date"
label var rvstnftype "CR5 NF Type"
label var rvstsourcename "CR5 Source Name"
label var rvstdoc "CR5 Doctor"
label var rvstdocaddr "CR5 Doctor's Address"
label var rvstrecnum "CR5 Record #"
label var rvstcfdx "CR5 CF Diagnosis"
label var rvstlabnum "CR5 Lab #"
label var rvstspecimen "CR5 Specimen"
label var rvstsampledate "CR5 Sample Date"
label var rvstrecvdate "CR5 Received Date"
label var rvstrptdate "CR5 Report Date"
label var rvstclindets "CR5 Clinical Details"
label var rvstcytofinds "CR5 Cytological Findings"
label var rvstmd "CR5 Microscopic Description"
label var rvstconsrpt "CR5 Consultation Report"
label var rvstcod "CR5 COD"
label var rvstduration "CR5 Duration of Illness"
label var rvstonset "CR5 Onset & Death Interval"
label var rvstcertifier "CR5 Certifier"
label var rvstadmdate "CR5 Admission Date"
label var rvstdfc "CR5 Date First Consultation"
label var rvstrtdate "CR5 RT Reg. Date"

label var rvstabsdaold "CR5 ST DA: old value"
label var rvstabsdanew "CR5 ST DA: new value"
label var rvstadoaold "CR5 ST Date: old value"
label var rvstadoanew "CR5 ST Date: new value"
label var rvstnftypeold "CR5 NF Type: old value"
label var rvstnftypenew "CR5 NF Type: new value"
label var rvstsourcenameold "CR5 Source Name: old value"
label var rvstsourcenamenew "CR5 Source Name: new value"
label var rvstdocold "CR5 Doctor: old value"
label var rvstdocnew "CR5 Doctor: new value"
label var rvstdocaddrold "CR5 Doctor's Address: old value"
label var rvstdocaddrnew "CR5 Doctor's Address: new value"
label var rvstrecnumold "CR5 Record #: old value"
label var rvstrecnumnew "CR5 Record #: new value"
label var rvstcfdxold "CR5 CF Diagnosis: old value"
label var rvstcfdxnew "CR5 CF Diagnosis: new value"
label var rvstlabnumold "CR5 Lab #: old value"
label var rvstlabnumnew "CR5 Lab #: new value"
label var rvstspecimenold "CR5 Specimen: old value"
label var rvstspecimennew "CR5 Specimen: new value"
label var rvstsampledateold "CR5 Sample Date: old value"
label var rvstsampledatenew "CR5 Sample Date: new value"
label var rvstrecvdateold "CR5 Received Date: old value"
label var rvstrecvdatenew "CR5 Received Date: new value"
label var rvstrptdateold "CR5 Report Date: old value"
label var rvstrptdatenew "CR5 Report Date: new value"
label var rvstclindetsold "CR5 Clinical Details: old value"
label var rvstclindetsnew "CR5 Clinical Details: new value"
label var rvstcytofindsold "CR5 Cytological Findings: old value"
label var rvstcytofindsnew "CR5 Cytological Findings: new value"
label var rvstmdold "CR5 Microscopic Description: old value"
label var rvstmdnew "CR5 Microscopic Description: new value"
label var rvstconsrptold "CR5 Consultation Report: old value"
label var rvstconsrptnew "CR5 Consultation Report: new value"
label var rvstcodold "CR5 COD: old value"
label var rvstcodnew "CR5 COD: new value"
label var rvstdurationold "CR5 Duration of Illness: old value"
label var rvstdurationnew "CR5 Duration of Illness: new value"
label var rvstonsetold "CR5 Onset & Death Interval: old value"
label var rvstonsetnew "CR5 Onset & Death Interval: new value"
label var rvstcertifierold "CR5 Certifier: old value"
label var rvstcertifiernew "CR5 Certifier: new value"
label var rvstadmdateold "CR5 Admission Date: old value"
label var rvstadmdatenew "CR5 Admission Date: new value"
label var rvstdfcold "CR5 Date First Consultation: old value"
label var rvstdfcnew "CR5 Date First Consultation: new value"
label var rvstrtdateold "CR5 RT Reg. Date: old value"
label var rvstrtdatenew "CR5 RT Reg. Date: new value"

rename reviewing_st_complete rvstformstatus
label var rvstformstatus "Reviewing-ST Form Status"
*****************
* Reviewed Form *
*****************
format rvdoa %tdCCYY-NN-DD
label var rvdoa "Reviewed: Date"
label var reviewtot "Reviewed: # to review"
label var reviewedtot "Reviewed: # reviewed"
label var rvtotpending "Reviewed: # pending review"
label var rvtotpendingper "Reviewed: % pending review"

rename reviewed_complete rvedformstatus
label var rvedformstatus "Reviewed Form Status"
*************
* ALL Forms *
*************
label define corrstatus_lab 1 "Correct" 2 "Error" 8 "NA", modify
label values rvptcfda rvptdoa rvptcstatus rvptretsource rvptnotesseen rvptnsdate rvptfretsource rvptlname ///
             rvptfname rvptinit rvptdob rvptsex rvptnrn rvpthospnum rvptresident rvptslc rvptdlc rvptcomments ///
             rvttabsda rvttadoa rvttparish rvttaddr rvttage rvttprimsite rvtttop rvtthx rvttmorph rvttlat rvttbeh ///
             rvttgrade rvttbasis rvttstaging rvttdot rvttdxyr rvttconsult rvttrx1 rvttrx1d rvttrx2 rvttrx2d rvttrx3 ///
             rvttrx3d rvttrx4 rvttrx4d rvttrx5 rvttrx5d rvttorx1 rvttorx2 rvttnorx1 rvttnorx2 rvttrecstatus ///
             rvstabsda rvstadoa rvstnftype rvstsourcename rvstdoc rvstdocaddr rvstrecnum rvstcfdx rvstlabnum ///
             rvstspecimen rvstsampledate rvstrecvdate rvstrptdate rvstclindets rvstcytofinds rvstmd rvstconsrpt ///
             rvstcod rvstduration rvstonset rvstcertifier rvstadmdate rvstdfc rvstrtdate corrstatus_lab

label define dqistatus_lab 1 "Major" 2 "Minor" 8 "NA", modify
label values rvptdobdqi rvptsexdqi rvptresidentdqi rvptslcdqi rvptdlcdqi rvttagedqi rvtttopdqi rvttmorphdqi rvttlatdqi ///
             rvttbehdqi rvttbasisdqi rvttstagingdqi rvttdotdqi rvttrx1dqi rvttrx1ddqi rvttrx2dqi rvttrx2ddqi rvttrx3dqi ///
             rvttrx3ddqi rvttrx4dqi rvttrx4ddqi rvttrx5dqi rvttrx5ddqi dqistatus_lab

label define formstatus_lab 0 "Incomplete" 1 "Unverified" 2 "Complete", modify
label values rvformstatus rvptformstatus rvttformstatus rvstformstatus rvedformstatus formstatus_lab

label define da_lab 1 "JC" 9 "SF" 13 "KWG" 14 "TH" 98 "Other", modify
label values rvptda rvttda rvstda da_lab

order record_id event instrument


** CHECK for invalid data
******************
* Reviewing Form *
******************
gen currentd=c(current_date)
gen double today=date(currentd, "DMYHM")
drop currentd
format today %tdCCYY-NN-DD

** check 1
count if event==1 & instrument==. & rvdoastart==. //0
count if event==1 & instrument==. & rvdoastart>today //0

** check 2
count if event==1 & instrument==. & rvreviewer==. //0

** check 3
count if event==1 & instrument==. & rvdxyr!=2015 //0

** check 4
count if reviewingtot!=. & reviewingtot>10 //1 - corrected in redcapdb
replace reviewingtot=1 if reviewingtot==20140962
//list record_id reviewingtot if reviewingtot!=. & reviewingtot>10

** check 5
count if event==1 & instrument==. & rvdoaend==. //2 - 1 corrected in redcapdb; the other is still pending review completion
replace rvdoaend=clock("2019-09-12 14:39:00", "YMD hms") if record_id==138 & rvreviewer==9 //1 change
replace rvelapsed=14 if record_id==138 & rvreviewer==9 //1 change
replace rverrtot=4 if record_id==138 & rvreviewer==9 //1 change
//list record_id rvreviewer rvdoaend if event==1 & instrument==. & rvdoaend==.
count if event==1 & instrument==. & rvdoaend>today //0

** check 6
count if rvelapsed!=. & rvelapsed>100 //0
//list record_id rvreviewer rvelapsed if rvelapsed!=. & rvelapsed>100

** check 7
count if rverrtot!=. & rverrtot>50 //0

** check 8
count if rvformstatus!=. & rvformstatus!=2 //3 - leave as is; review pending completion
//list record_id rvreviewer rvformstatus if rvformstatus!=. & rvformstatus!=2

*********************
* Reviewing PT Form *
*********************
** check 9
count if instrument==1 & rvcr5pid==. //0
tostring rvcr5pid ,replace
count if instrument==1 & (length(rvcr5pid)<8|length(rvcr5pid)>8) //0

** check 10
count if instrument==1 & rvptda==. //0
count if instrument==1 & rvptda!=9 & rvptda!=13 & rvptda!=14 //6 - corrected in redcapdb
//list record_id rvptda rvreviewer if instrument==1 & rvptda!=9 & rvptda!=13 & rvptda!=14
replace rvptda=13 if record_id==94 & rvptda==98 //1 change
replace rvptoda=. if record_id==94 & rvptoda==99 //1 change
replace rvptda=13 if record_id==98 & rvptda==98 //1 change
replace rvptoda=. if record_id==98 & rvptoda==99 //1 change
replace rvptda=13 if record_id==121 & rvptda==98 //1 change
replace rvptoda=. if record_id==121 & rvptoda==99 //1 change
replace rvptda=13 if record_id==132 & rvptda==98 //1 change
replace rvptoda=. if record_id==132 & rvptoda==99 //1 change
replace rvptda=13 if record_id==185 & rvptda==1 //1 change
replace rvptda=13 if record_id==263 & rvptda==98 //1 change
replace rvptoda=. if record_id==263 & rvptoda==99 //1 change
count if rvptda==98 & rvptoda==. //0

** check 11
count if instrument==1 & rvpterrtot!=. & rvpterrtot>50 //0

** check 12
count if instrument==1 & rvptcfda==. //0
count if instrument==1 & rvptdoa==. //0
count if instrument==1 & rvptcstatus==. //0
count if instrument==1 & rvptretsource==. //0
count if instrument==1 & rvptnotesseen==. //0
count if instrument==1 & rvptnsdate==. //0
count if instrument==1 & rvptfretsource==. //0
count if instrument==1 & rvptlname==. //0
count if instrument==1 & rvptfname==. //0
count if instrument==1 & rvptinit==. //0
count if instrument==1 & rvptdob==. //0
count if instrument==1 & rvptsex==. //0
count if instrument==1 & rvptnrn==. //0
count if instrument==1 & rvpthospnum==. //0
count if instrument==1 & rvptresident==. //0
count if instrument==1 & rvptslc==. //0
count if instrument==1 & rvptdlc==. //0
count if instrument==1 & rvptcomments==. //0

** check 13
count if instrument==1 & rvptdob==2 & rvptdobdqi==. //0
count if instrument==1 & rvptsex==2 & rvptsexdqi==. //0
count if instrument==1 & rvptresident==2 & rvptresidentdqi==. //0
count if instrument==1 & rvptslc==2 & rvptslcdqi==. //0
count if instrument==1 & rvptdlc==2 & rvptdlcdqi==. //0

** check 14
count if rvptformstatus!=. & rvptformstatus!=2 //0

*********************
* Reviewing TT Form *
*********************
** check 15
count if instrument==2 & rvttcr5id=="" //0
count if instrument==2 & (length(rvttcr5id)<2|length(rvttcr5id)>2) //4 - corrected in redcapdb
//list record_id rvreviewer rvttcr5id if instrument==2 & (length(rvttcr5id)<2|length(rvttcr5id)>2)
replace rvttcr5id="T2" if record_id==10 & event==1 & instrument==2 //1 change
replace rvttcr5id="T1" if record_id==133 & event==1 & instrument==2 //1 change
replace rvttcr5id="T1" if record_id==169 & event==1 & instrument==2 //1 change
replace rvttcr5id="T1" if record_id==218 & event==1 & instrument==2 //1 change

** check 16
count if instrument==2 & rvttda==. //0
count if instrument==2 & rvttda!=9 & rvttda!=13 & rvttda!=14 & rvttda!=98 //0
//list record_id rvttda rvreviewer if instrument==2 & rvttda!=9 & rvttda!=13 & rvttda!=14 & rvttda!=98
count if rvttda==98 & rvttoda=="" //0

** check 17
count if instrument==2 & rvtterrtot!=. & rvtterrtot>50 //0

** check 18
count if instrument==2 & rvttabsda==. //1 - leave as is; review pending completion
count if instrument==2 & rvttadoa==. //1 - leave as is; review pending completion
count if instrument==2 & rvttparish==. //1 - leave as is; review pending completion
count if instrument==2 & rvttaddr==. //1 - leave as is; review pending completion
count if instrument==2 & rvttage==. //1 - leave as is; review pending completion
count if instrument==2 & rvttprimsite==. //1 - leave as is; review pending completion
count if instrument==2 & rvtttop==. //1 - leave as is; review pending completion
count if instrument==2 & rvtthx==. //1 - leave as is; review pending completion
count if instrument==2 & rvttmorph==. //1 - leave as is; review pending completion
count if instrument==2 & rvttlat==. //1 - leave as is; review pending completion
count if instrument==2 & rvttbeh==. //1 - leave as is; review pending completion
count if instrument==2 & rvttgrade==. //1 - leave as is; review pending completion
count if instrument==2 & rvttbasis==. //1 - leave as is; review pending completion
count if instrument==2 & rvttstaging==. //1 - leave as is; review pending completion
count if instrument==2 & rvttdot==. //1 - leave as is; review pending completion
count if instrument==2 & rvttdxyr==. //1 - leave as is; review pending completion
count if instrument==2 & rvttconsult==. //1 - leave as is; review pending completion
/* - not currently in use; hidden on redcap form
count if instrument==2 & rvttrx1==.
count if instrument==2 & rvttrx1d==.
count if instrument==2 & rvttrx2==.
count if instrument==2 & rvttrx2d==.
count if instrument==2 & rvttrx3==.
count if instrument==2 & rvttrx3d==.
count if instrument==2 & rvttrx4==.
count if instrument==2 & rvttrx4d==.
count if instrument==2 & rvttrx5==.
count if instrument==2 & rvttrx5d==.
count if instrument==2 & rvttorx1==.
count if instrument==2 & rvttorx2==.
count if instrument==2 & rvttnorx1==.
count if instrument==2 & rvttnorx2==.
*/
count if instrument==2 & rvttrecstatus==. //1 - leave as is; review pending completion

** check 19
count if instrument==2 & rvttage==2 & rvttagedqi==. //0
count if instrument==2 & rvtttop==2 & rvtttopdqi==. //0
count if instrument==2 & rvttmorph==2 & rvttmorphdqi==. //0
count if instrument==2 & rvttlat==2 & rvttlatdqi==. //0
count if instrument==2 & rvttbeh==2 & rvttbehdqi==. //0
count if instrument==2 & rvttbasis==2 & rvttbasisdqi==. //0
count if instrument==2 & rvttstaging==2 & rvttstagingdqi==. //0
count if instrument==2 & rvttdot==2 & rvttdotdqi==. //0
count if instrument==2 & rvttrx1==2 & rvttrx1dqi==. //0
count if instrument==2 & rvttrx1d==2 & rvttrx1ddqi==. //0
count if instrument==2 & rvttrx2==2 & rvttrx2dqi==. //0
count if instrument==2 & rvttrx2d==2 & rvttrx2ddqi==. //0
count if instrument==2 & rvttrx3==2 & rvttrx3dqi==. //0
count if instrument==2 & rvttrx3d==2 & rvttrx3ddqi==. //0
count if instrument==2 & rvttrx4==2 & rvttrx4dqi==. //0
count if instrument==2 & rvttrx4d==2 & rvttrx4ddqi==. //0
count if instrument==2 & rvttrx5==2 & rvttrx5dqi==. //0
count if instrument==2 & rvttrx5d==2 & rvttrx5ddqi==. //0

** check 20
count if rvttformstatus!=. & rvttformstatus!=2 //1 - leave as is; review pending completion

*********************
* Reviewing ST Form *
*********************
** check 21
count if instrument==3 & rvstcr5id=="" //0
count if instrument==3 & (length(rvstcr5id)<4|length(rvstcr5id)>4) //4
//list record_id rvreviewer instance rvstcr5id if instrument==3 & (length(rvstcr5id)<4|length(rvstcr5id)>4)
replace rvstcr5id="T1S1" if record_id==120 & instrument==3 & instance==1 //1 change
replace rvstcr5id="T1S1" if record_id==180 & instrument==3 & instance==1 //1 change
replace rvstcr5id="T1S1" if record_id==181 & instrument==3 & instance==1 //1 change
replace rvstabsda=14 if record_id==180 & instrument==3 & instance==1 //1 change
replace rvstcr5id="T1S1" if record_id==184 & instrument==3 & instance==1 //1 change

** check 22
count if instrument==3 & rvstda==. //0
count if instrument==3 & rvstda!=9 & rvstda!=13 & rvstda!=14 & rvstda!=98 & rvstda!=99 //2 - corrected in redcapdb
//list record_id rvreviewer instance rvstda if instrument==3 & rvstda!=9 & rvstda!=13 & rvstda!=14 & rvstda!=98 & rvstda!=99
replace rvstda=13 if record_id==235 & instrument==3 & instance==3 //1 change
replace rvstda=13 if record_id==253 & instrument==3 & instance==2 //1 change
count if rvstda==98 & rvstoda=="" //0

** check 23
count if instrument==3 & rvsterrtot!=. & rvsterrtot>50 //0

** check 24
count if instrument==3 & rvstrectype==. //0

** check 25
count if instrument==3 & rvstabsda==. //0
count if instrument==3 & rvstadoa==. //1 - leave as is; review pending completion
count if instrument==3 & rvstnftype==. //1 - leave as is; review pending completion
count if instrument==3 & rvstsourcename==. //1 - leave as is; review pending completion
count if instrument==3 & rvstdoc==. //1 - leave as is; review pending completion
count if instrument==3 & rvstdocaddr==. //1 - leave as is; review pending completion
count if instrument==3 & rvstrecnum==. //1 - leave as is; review pending completion
count if instrument==3 & rvstcfdx==. //1 - leave as is; review pending completion
count if instrument==3 & rvstlabnum==. & (rvstrectype==1|rvstrectype==2) //1 - leave as is; review pending completion
count if instrument==3 & rvstspecimen==. & (rvstrectype==1|rvstrectype==2) //1 - leave as is; review pending completion
count if instrument==3 & rvstsampledate==. & (rvstrectype==1|rvstrectype==2) //1 - leave as is; review pending completion
count if instrument==3 & rvstrecvdate==. & (rvstrectype==1|rvstrectype==2) //1 - leave as is; review pending completion
count if instrument==3 & rvstrptdate==. & (rvstrectype==1|rvstrectype==2) //1 - leave as is; review pending completion
count if instrument==3 & rvstclindets==. & (rvstrectype==1|rvstrectype==2) //1 - leave as is; review pending completion
count if instrument==3 & rvstcytofinds==. & rvstrectype==2 //0
count if instrument==3 & rvstmd==. & rvstrectype==1 //1 - leave as is; review pending completion
count if instrument==3 & rvstconsrpt==. & rvstrectype==1 //1 - leave as is; review pending completion
count if instrument==3 & rvstcod==. & rvstrectype>4 & rvstrectype<8 //0
count if instrument==3 & rvstduration==. & rvstrectype>4 & rvstrectype<8 & rvstrectype!=5 //0
count if instrument==3 & rvstonset==. & rvstrectype>4 & rvstrectype<8 & rvstrectype!=5 //0
count if instrument==3 & rvstcertifier==. & rvstrectype>4 & rvstrectype<8 //0
count if instrument==3 & rvstadmdate==. & (rvstrectype==5|rvstrectype==8|rvstrectype==9) //0
count if instrument==3 & rvstdfc==. & (rvstrectype==8|rvstrectype==9) //0
count if instrument==3 & rvstrtdate==. & rvstrectype==4 //0

** check 26
count if rvstformstatus!=. & rvstformstatus!=2 //1 - leave as is; review pending completion


*****************
* Reviewed Form *
*****************
** check 27
count if event==2 & rvdoa==. //0
count if event!=2 & rvdoa!=. //1

** check 28
count if event==2 & reviewtot==. //0
count if event!=2 & reviewtot!=. //2

** check 29
count if event==2 & reviewedtot==. //0
count if event!=2 & reviewedtot!=. //0

** check 30
count if event==2 & rvtotpending==. //0
count if event!=2 & rvtotpending!=. //2

** check 31
count if event==2 & rvtotpendingper==. //0
count if event!=2 & rvtotpendingper!=. //2

** check 32
count if rvedformstatus!=. & rvedformstatus!=1 //2 - leave record_id=5 as is
count if event!=2 & rvedformstatus!=. //1

replace rvdoa=. if record_id==3 & instrument==. //1 change
replace reviewtot=. if record_id==3 & instrument==. //1 change
replace rvtotpending=. if record_id==3 & instrument==. //1 change
replace rvtotpendingper=. if record_id==3 & instrument==. //1 change
replace rvedformstatus=. if record_id==3 & instrument==. //1 change

replace reviewtot=. if record_id==4 & instrument==. //1 change
replace rvtotpending=. if record_id==4 & instrument==. //1 change
replace rvtotpendingper=. if record_id==4 & instrument==. //1 change


** CREATE report variables
** Total records reviewed
egen rvtotal=total(reviewingtot) if reviewingtot!=.|reviewingtot!=0
//egen rvtotal_SF=count(rvptda|rvttda|rvstda) if rvptda==9|rvttda==9|rvstda==9
//egen rvtotal_KWG=count(rvptda|rvttda|rvstda) if rvptda==13|rvttda==13|rvstda==13
//egen rvtotal_TH=count(rvptda|rvttda|rvstda) if rvptda==14|rvttda==14|rvstda==14
//egen rvtotal_intern=count(rvptda|rvttda|rvstda) if rvptda==98|rvttda==98|rvstda==98
** Percentage records reviewed
//gen rvtotalper_SF=rvtotal_SF/rvtotal*100
//gen rvtotalper_KWG=rvtotal_KWG/rvtotal*100
//gen rvtotalper_TH=rvtotal_TH/rvtotal*100
//gen rvtotalper_intern=rvtotal_intern/rvtotal*100

** Total variables reviewed
egen vartot_pt=count(instrument) if instrument==1 //18 vars
egen vartot_tt=count(instrument) if instrument==2 //18 vars (no rx); 32 vars (w/ rx) 
egen vartot_st=count(instrument) if instrument==3 //24 vars
gen vartotal_pt=vartot_pt*18 //4,752
gen vartotal_tt=vartot_tt*18 //5,472
gen vartotal_st=vartot_st*24 //13,272
gen vartotal=4752+5472+13272

** Total errors
egen rvpterrtotal=total(rvpterrtot) //614
egen rvtterrtotal=total(rvtterrtot) //752
egen rvsterrtotal=total(rvsterrtot) //86
gen rverrtotal=rvpterrtotal + rvtterrtotal + rvsterrtotal //1452
** Total errors for IARC quality variables
/*
egen rverrtotal_iarc_dob=count(rvptdobdqi) if rvptdobdqi!=8|rvptdobdqi!=. //
egen rverrtotal_iarc_sex=count(rvptsexdqi) if rvptsexdqi!=8|rvptsexdqi!=. //
egen rverrtotal_iarc_resident=count(rvptresidentdqi) if rvptresidentdqi!=8|rvptresidentdqi!=. //
egen rverrtotal_iarc_slc=count(rvptslcdqi) if rvptslcdqi!=8|rvptslcdqi!=. //
egen rverrtotal_iarc_dlc=count(rvptdlcdqi) if rvptdlcdqi!=8|rvptdlcdqi!=. //
egen rverrtotal_iarc_age=count(rvttagedqi) if rvttagedqi!=8|rvttagedqi!=. //
egen rverrtotal_iarc_top=count(rvtttopdqi) if rvtttopdqi!=8|rvtttopdqi!=. //
egen rverrtotal_iarc_morph=count(rvttmorphdqi) if rvttmorphdqi!=8|rvttmorphdqi!=. //
egen rverrtotal_iarc_lat=count(rvttlatdqi) if rvttlatdqi!=8|rvttlatdqi!=. //
egen rverrtotal_iarc_beh=count(rvttbehdqi) if rvttbehdqi!=8|rvttbehdqi!=. //
egen rverrtotal_iarc_basis=count(rvttbasisdqi) if rvttbasisdqi!=8|rvttbasisdqi!=. //
egen rverrtotal_iarc_staging=count(rvttstagingdqi) if rvttstagingdqi!=8|rvttstagingdqi!=. //
egen rverrtotal_iarc_dot=count(rvttdotdqi) if rvttdotdqi!=8|rvttdotdqi!=. //
egen rverrtotal_iarc_rx1=count(rvttrx1dqi) if rvttrx1dqi!=8|rvttrx1dqi!=. //0
egen rverrtotal_iarc_rx1d=count(rvttrx1dqi) if rvttrx1ddqi!=8|rvttrx1ddqi!=. //0
egen rverrtotal_iarc_rx2=count(rvttrx2dqi) if rvttrx2dqi!=8|rvttrx2dqi!=. //0
egen rverrtotal_iarc_rx2d=count(rvttrx2dqi) if rvttrx2ddqi!=8|rvttrx2ddqi!=. //0
egen rverrtotal_iarc_rx3=count(rvttrx3dqi) if rvttrx3dqi!=8|rvttrx3dqi!=. //0
egen rverrtotal_iarc_rx3d=count(rvttrx3dqi) if rvttrx3ddqi!=8|rvttrx3ddqi!=. //0
egen rverrtotal_iarc_rx4=count(rvttrx4dqi) if rvttrx4dqi!=8|rvttrx4dqi!=. //0
egen rverrtotal_iarc_rx4d=count(rvttrx4dqi) if rvttrx4ddqi!=8|rvttrx4ddqi!=. //0
egen rverrtotal_iarc_rx5=count(rvttrx5dqi) if rvttrx5dqi!=8|rvttrx5dqi!=. //0
egen rverrtotal_iarc_rx5d=count(rvttrx5dqi) if rvttrx5ddqi!=8|rvttrx5ddqi!=. //0

egen rverrtotal_iarc=count(rvptdob|rvptsex|rvptresident|rvptslc|rvptdlc|rvttage|rvtttop|rvttmorph|rvttlat|rvttbeh|rvttbasis|rvttstaging|rvttdot) if ///
       rvptdob==2|rvptsex==2|rvptresident==2|rvptslc==2|rvptdlc==2|rvttage==2|rvtttop==2|rvttmorph==2| ///
       rvttlat==2|rvttbeh==2|rvttbasis==2|rvttstaging==2|rvttdot==2 //418 - not correct, use below code instead
*/
count if rvptdob==2 //3
count if rvptsex==2 //4
count if rvptresident==2 //148
count if rvptslc==2 //29
count if rvptdlc==2 //85
count if rvttage==2 //13
count if rvtttop==2 //37
count if rvttmorph==2 //35
count if rvttlat==2 //86
count if rvttbeh==2 //13
count if rvttbasis==2 //35
count if rvttstaging==2 //218
count if rvttdot==2 //49
gen rverrtotal_iarc=755

** TOTAL errors - distributed by variable
** PT (614)
count if rvptcfda==2 //0
count if rvptdoa==2 //0
count if rvptcstatus==2 //5
count if rvptretsource==2 //53
count if rvptnotesseen==2 //240
count if rvptnsdate==2 //23
count if rvptfretsource==2 //2
count if rvptlname==2 //1
count if rvptfname==2 //1
count if rvptinit==2 //5
count if rvptdob==2 //3
count if rvptsex==2 //4
count if rvptnrn==2 //3
count if rvpthospnum==2 //1
count if rvptresident==2 //148
count if rvptslc==2 //29
count if rvptdlc==2 //85
count if rvptcomments==2 //11
** TT (752)
count if rvttabsda==2 //21
count if rvttadoa==2 //22
count if rvttparish==2 //12
count if rvttaddr==2 //13
count if rvttage==2 //13
count if rvttprimsite==2 //44
count if rvtttop==2 //37
count if rvtthx==2 //42
count if rvttmorph==2 //35
count if rvttlat==2 //86
count if rvttbeh==2 //13
count if rvttgrade==2 //24
count if rvttbasis==2 //35
count if rvttstaging==2 //218
count if rvttdot==2 //49
count if rvttdxyr==2 //28
count if rvttconsult==2 //21
/*
count if rvttrx1==2 //
count if rvttrx1d==2 //
count if rvttrx2==2 //
count if rvttrx2d==2 //
count if rvttrx3==2 //
count if rvttrx3d==2 //
count if rvttrx4==2 //
count if rvttrx4d==2 //
count if rvttrx5==2 //
count if rvttrx5d==2 //
count if rvttorx1==2 //
count if rvttorx2==2 //
count if rvttnorx1==2 //
count if rvttnorx2==2 //
*/
count if rvttrecstatus==2 //39
** ST (86)
count if rvstabsda==2 //8
count if rvstadoa==2 //3
count if rvstnftype==2 //4
count if rvstsourcename==2 //4
count if rvstdoc==2 //12
count if rvstdocaddr==2 //6
count if rvstrecnum==2 //9
count if rvstcfdx==2 //3
count if rvstlabnum==2 //3
count if rvstspecimen==2 //1
count if rvstsampledate==2 //6
count if rvstrecvdate==2 //5
count if rvstrptdate==2 //6
count if rvstclindets==2 //2
count if rvstcytofinds==2 //1
count if rvstmd==2 //1
count if rvstconsrpt==2 //0
count if rvstcod==2 //2
count if rvstduration==2 //3
count if rvstonset==2 //3
count if rvstcertifier==2 //3
count if rvstadmdate==2 //1
count if rvstdfc==2 //0
count if rvstrtdate==2 //0

** Total errors - major, by variable
egen rverrtotal_major_dob=count(rvptdobdqi) if rvptdobdqi==1 //2
egen rverrtotal_major_sex=count(rvptsexdqi) if rvptsexdqi==1 //2
egen rverrtotal_major_resident=count(rvptresidentdqi) if rvptresidentdqi==1 //63
egen rverrtotal_major_slc=count(rvptslcdqi) if rvptslcdqi==1 //9
egen rverrtotal_major_dlc=count(rvptdlcdqi) if rvptdlcdqi==1 //58
egen rverrtotal_major_age=count(rvttagedqi) if rvttagedqi==1 //4
egen rverrtotal_major_top=count(rvtttopdqi) if rvtttopdqi==1 //19
egen rverrtotal_major_morph=count(rvttmorphdqi) if rvttmorphdqi==1 //25
egen rverrtotal_major_lat=count(rvttlatdqi) if rvttlatdqi==1 //0
egen rverrtotal_major_beh=count(rvttbehdqi) if rvttbehdqi==1 //13
egen rverrtotal_major_basis=count(rvttbasisdqi) if rvttbasisdqi==1 //31
egen rverrtotal_major_staging=count(rvttstagingdqi) if rvttstagingdqi==1 //1
egen rverrtotal_major_dot=count(rvttdotdqi) if rvttdotdqi==1 //27
egen rverrtotal_major_rx1=count(rvttrx1dqi) if rvttrx1dqi==1 //0
egen rverrtotal_major_rx1d=count(rvttrx1dqi) if rvttrx1ddqi==1 //0
egen rverrtotal_major_rx2=count(rvttrx2dqi) if rvttrx2dqi==1 //0
egen rverrtotal_major_rx2d=count(rvttrx2dqi) if rvttrx2ddqi==1 //0
egen rverrtotal_major_rx3=count(rvttrx3dqi) if rvttrx3dqi==1 //0
egen rverrtotal_major_rx3d=count(rvttrx3dqi) if rvttrx3ddqi==1 //0
egen rverrtotal_major_rx4=count(rvttrx4dqi) if rvttrx4dqi==1 //0
egen rverrtotal_major_rx4d=count(rvttrx4dqi) if rvttrx4ddqi==1 //0
egen rverrtotal_major_rx5=count(rvttrx5dqi) if rvttrx5dqi==1 //0
egen rverrtotal_major_rx5d=count(rvttrx5dqi) if rvttrx5ddqi==1 //0
** Total errors - major
gen rverrtotal_major=254 //total from above errors by variable
** Percentage errors - major
gen rverrtotalper_major=rverrtotal_major/rverrtotal_iarc*100
gen rverrtotalper_major_all=rverrtotal_major/rverrtotal*100

** Total errors - minor, by variable
egen rverrtotal_minor_dob=count(rvptdobdqi) if rvptdobdqi==2 //1
egen rverrtotal_minor_sex=count(rvptsexdqi) if rvptsexdqi==2 //0
egen rverrtotal_minor_resident=count(rvptresidentdqi) if rvptresidentdqi==2 //6
egen rverrtotal_minor_slc=count(rvptslcdqi) if rvptslcdqi==2 //0
egen rverrtotal_minor_dlc=count(rvptdlcdqi) if rvptdlcdqi==2 //6
egen rverrtotal_minor_age=count(rvttagedqi) if rvttagedqi==2 //0
egen rverrtotal_minor_top=count(rvtttopdqi) if rvtttopdqi==2 //18
egen rverrtotal_minor_morph=count(rvttmorphdqi) if rvttmorphdqi==2 //10
egen rverrtotal_minor_lat=count(rvttlatdqi) if rvttlatdqi==2 //74
egen rverrtotal_minor_beh=count(rvttbehdqi) if rvttbehdqi==2 //0
egen rverrtotal_minor_basis=count(rvttbasisdqi) if rvttbasisdqi==2 //4
egen rverrtotal_minor_staging=count(rvttstagingdqi) if rvttstagingdqi==2 //6
egen rverrtotal_minor_dot=count(rvttdotdqi) if rvttdotdqi==2 //22
egen rverrtotal_minor_rx1=count(rvttrx1dqi) if rvttrx1dqi==2 //0
egen rverrtotal_minor_rx1d=count(rvttrx1dqi) if rvttrx1ddqi==2 //0
egen rverrtotal_minor_rx2=count(rvttrx2dqi) if rvttrx2dqi==2 //0
egen rverrtotal_minor_rx2d=count(rvttrx2dqi) if rvttrx2ddqi==2 //0
egen rverrtotal_minor_rx3=count(rvttrx3dqi) if rvttrx3dqi==2 //0
egen rverrtotal_minor_rx3d=count(rvttrx3dqi) if rvttrx3ddqi==2 //0
egen rverrtotal_minor_rx4=count(rvttrx4dqi) if rvttrx4dqi==2 //0
egen rverrtotal_minor_rx4d=count(rvttrx4dqi) if rvttrx4ddqi==2 //0
egen rverrtotal_minor_rx5=count(rvttrx5dqi) if rvttrx5dqi==2 //0
egen rverrtotal_minor_rx5d=count(rvttrx5dqi) if rvttrx5ddqi==2 //0
** Total errors - minor
gen rverrtotal_minor=147 //total from above errors by variable
** Percentage errors - minor
gen rverrtotalper_minor=rverrtotal_minor/rverrtotal_iarc*100
gen rverrtotalper_minor_all=rverrtotal_minor/rverrtotal*100

** TOTAL review time
egen rvtime_mins=total(rvelapsed)
gen rvtime_hrs=rvtime_mins/60
gen rvtime_days=rvtime_hrs/7
gen rvtime_wks=rvtime_days/2
format rvtime_wks %4.0g


save "`datapath'\version02\2-working\2015_review_dc" ,replace

** CREATE progress report
** CREATE dataset with results to be used in pdf report
preserve
collapse rvtotpendingper rvtotal rverrtotal rverrtotal_iarc rverrtotal_major rverrtotalper_major rverrtotalper_major_all rverrtotal_minor rverrtotalper_minor_all rverrtotalper_minor rvtime_wks
format rverrtotalper_major rverrtotalper_major_all rverrtotalper_minor rverrtotalper_minor_all %9.0f
save "`datapath'\version02\3-output\2015_review_dqi_da" ,replace

				****************************
				*	  PDF REPORT        *
				*    QUANTITY & QUALITY    *
				****************************

putdocx clear
putdocx begin

//Create a paragraph
putdocx paragraph
putdocx text ("Quantity & Quality Report"), bold
putdocx paragraph
putdocx text ("Cancer: 2015"), font(Helvetica,10)
putdocx paragraph
putdocx text ("Date Prepared: 24-Oct-2019"),  font(Helvetica,10)
putdocx paragraph
putdocx text ("Prepared by: JC using Stata & Redcap data release date: 25-Sep-2019"),  font(Helvetica,10)
putdocx paragraph
putdocx text ("Review of 74 CanReg5 Variables"), shading("pink") font(Helvetica,10)
putdocx paragraph, halign(center)
putdocx text ("QUANTITY"), bold font(Helvetica,20,"blue")
putdocx paragraph
qui sum rvtime_wks
local sum : display %3.0f `r(sum)'
putdocx text ("TOTAL time for review: `sum' work wks")
putdocx paragraph
qui sum rvtotal
local sum : display %3.0f `r(sum)'
putdocx text ("TOTAL records reviewed: `sum' (27%)")
putdocx paragraph, halign(center)
putdocx text ("QUALITY - IARC ONLY"), bold font(Helvetica,20,"blue")
putdocx paragraph
qui sum rvtotpendingper
local sum : display %3.0f `r(sum)'
putdocx text ("TOTAL pending review: `sum'%")
putdocx paragraph
qui sum rverrtotal_iarc
local sum : display %3.0f `r(sum)'
putdocx text ("TOTAL errors: `sum'"), bold shading("yellow")
putdocx paragraph
qui sum rverrtotal_major
local sum : display %3.0f `r(sum)'
putdocx text ("TOTAL errors MAJOR: `sum'")
putdocx paragraph
qui sum rverrtotalper_major
local sum : display %2.0f `r(sum)'
putdocx text ("TOTAL errors MAJOR: `sum'%"), bold shading("yellow")
putdocx paragraph
qui sum rverrtotal_minor
local sum : display %3.0f `r(sum)'
putdocx text ("TOTAL errors MINOR: `sum'")
putdocx paragraph
qui sum rverrtotalper_minor
local sum : display %2.0f `r(sum)'
putdocx text ("TOTAL errors MINOR: `sum'%"), bold shading("yellow")

putdocx save "`datapath'\version02\3-output\2019-10-24_review_quality_report.docx", replace
putdocx clear
restore


preserve
collapse rverrtotal_major_*
drop *rx* //remove treatment fields as not needed for this report

drop _all
input errorvar case
1	2
2	2
3      63
4	9
5	58
6	4
7      19
8      25
9      0
10     13
11     31
12     1
13     27
end

label var errorvar "Variable"
label define errorvar_lab 1 "DOB" 2 "Sex" 3 "Resident" 4 "StatusLastContact" 5 "DateLastContact" ///
                          6 "Age" 7 "Topography" 8 "Morphology" 9 "Laterality" 10 "Behaviour" ///
                          11 "BasisOfDiagnosis" 12 "Staging" 13 "IncidenceDate", modify
label values errorvar errorvar_lab
gen errorper=case/254*100
format errorper %9.0f
gsort -case

putdocx clear
putdocx begin

putdocx paragraph, halign(center)
putdocx text ("QUALITY - MAJOR"), bold font(Helvetica,20,"blue")
rename errorvar Variable
rename case Total_Errors
rename errorper Percentage
putdocx table tbl_major = data("Variable Total_Errors Percentage"), varnames ///
       border(start, nil) border(insideV, nil) border(end, nil)


putdocx save "`datapath'\version02\3-output\2019-10-24_review_quality_report.docx", append
putdocx clear
restore


preserve
collapse rverrtotal_minor_*
drop *rx* //remove treatment fields as not needed for this report

drop _all
input errorvar case
1	1
2	0
3      6
4	0
5	6
6	0
7      18
8      10
9      74
10     0
11     4
12     6
13     22
end

label var errorvar "Variable"
label define errorvar_lab 1 "DOB" 2 "Sex" 3 "Resident" 4 "StatusLastContact" 5 "DateLastContact" ///
                          6 "Age" 7 "Topography" 8 "Morphology" 9 "Laterality" 10 "Behaviour" ///
                          11 "BasisOfDiagnosis" 12 "Staging" 13 "IncidenceDate", modify
label values errorvar errorvar_lab
gen errorper=case/147*100
format errorper %9.0f
gsort -case

putdocx clear
putdocx begin

putdocx paragraph, halign(center)
putdocx text ("QUALITY - MINOR"), bold font(Helvetica,20,"blue")
rename errorvar Variable
rename case Total_Errors
rename errorper Percentage
putdocx table tbl_major = data("Variable Total_Errors Percentage"), varnames ///
       border(start, nil) border(insideV, nil) border(end, nil)


putdocx save "`datapath'\version02\3-output\2019-10-24_review_quality_report.docx", append
putdocx clear
restore

preserve
collapse rvtotpendingper rvtotal rverrtotal rverrtotal_iarc rverrtotal_major rverrtotalper_major rverrtotalper_major_all rverrtotal_minor rverrtotalper_minor_all rverrtotalper_minor rvtime_wks
format rverrtotalper_major rverrtotalper_major_all rverrtotalper_minor rverrtotalper_minor_all %9.0f
save "`datapath'\version02\3-output\2015_review_dqi_da" ,replace

				****************************
				*	  PDF REPORT        *
				*         QUALITY          *
				****************************

putdocx clear
putdocx begin


putdocx paragraph, halign(center)
putdocx text ("QUALITY - ALL"), bold font(Helvetica,20,"blue")
putdocx paragraph
qui sum rvtotpendingper
local sum : display %3.0f `r(sum)'
putdocx text ("TOTAL pending review: `sum'%")
putdocx paragraph
qui sum rverrtotal
local sum : display %3.0f `r(sum)'
putdocx text ("TOTAL errors: `sum'"), bold shading("yellow")
putdocx paragraph
qui sum rverrtotal_major
local sum : display %3.0f `r(sum)'
putdocx text ("TOTAL errors MAJOR: `sum'")
putdocx paragraph
qui sum rverrtotalper_major_all
local sum : display %2.0f `r(sum)'
putdocx text ("TOTAL errors MAJOR: `sum'%"), bold shading("yellow")
putdocx paragraph
qui sum rverrtotal_minor
local sum : display %3.0f `r(sum)'
putdocx text ("TOTAL errors MINOR: `sum'")
putdocx paragraph
qui sum rverrtotalper_minor_all
local sum : display %2.0f `r(sum)'
putdocx text ("TOTAL errors MINOR: `sum'%"), bold shading("yellow")
putdocx paragraph

putdocx save "`datapath'\version02\3-output\2019-10-24_review_quality_report.docx", append
putdocx clear
restore

preserve
drop _all
input errorvar case
1	0
2	0
3	5
4	53
5	240
6	23
7	2
8	1
9	1
10	5
11	3
12	4
13	3
14	1
15	148
16	29
17	85
18	11
19	21
20	22
21	12
22	13
23	13
24	44
25	37
26	42
27	35
28	86
29	13
30	24
31	35
32	218
33	49
34	28
35	21
36	39
37	8
38	3
39	4
40	4
41	12
42	6
43	9
44	3
45	3
46	1
47	6
48	5
49	6
50	2
51	1
52	1
53	0
54	2
55	3
56	3
57	3
58	1
59	0
60	0
end

label var errorvar "Variable"
label define errorvar_lab 1 "CF DA" 2 "CF Date" 3 "Case Status" 4 "Ret.Source" 5 "Notes Seen" 6 "Notes Seen Date" ///
                          7 "Fur.Ret.Source" 8 "Last Name" 9 "First Name" 10 "Initials" 11 "DOB" 12 "Sex" 13 "NRN" ///
                          14 "Hospital #" 15 "Resident" 16 "StatusLastContact" 17 "DateLastContact" 18 "CR5 Comments" ///
                          19 "ABS DA" 20 "ABS Date" 21 "Parish" 22 "Address" 23 "Age" 24 "Primary Site" 25 "Topography" ///
                          26 "Histology" 27 "Morphology" 28 "Laterality" 29 "Behaviour" 30 "Grade" 31 "BasisOfDiagnosis" ///
                          32 "Staging" 33 "IncidenceDate" 34 "Dx Year" 35 "Consultant" 36 "Record Status" ///
                          37 "Source DA" 38 "Source Date" 39 "NF Type" 40 "Source Name" 41 "Doctor" 42 "Doc Address" ///
                          43 "Record #" 44 "CF Dx" 45 "Lab #" 46 "Specimen" 47 "Sample Taken Date" 48 "Received Date" ///
                          49 "Report Date" 50 "Clinical Details" 51 "Cytological Findings" 52 "Microscopic Des." ///
                          53 "Consultation Rpt" 54 "COD" 55 "Duration" 56 "Onset & Death Interval" 57 "Certifier" ///
                          58 "Admission Date" 59 "Date First Consultation" 60 "RT Date", modify
label values errorvar errorvar_lab
gen errorper=case/1452*100
format errorper %9.0f
gsort -case
drop if case==.|case==0 // deleted

putdocx clear
putdocx begin


rename errorvar Variable
rename case Total_Errors
rename errorper Percentage
putdocx table tbl_all = data("Variable Total_Errors Percentage"), varnames ///
       border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_all(3,.), bold shading("yellow")
putdocx table tbl_all(4,.), bold shading("yellow")
putdocx table tbl_all(5,.), bold shading("yellow")
putdocx table tbl_all(6,.), bold shading("yellow")
putdocx table tbl_all(8,.), bold shading("yellow")
putdocx table tbl_all(12,.), bold shading("yellow")
putdocx table tbl_all(13,.), bold shading("yellow")
putdocx table tbl_all(14,.), bold shading("yellow")
putdocx table tbl_all(15,.), bold shading("yellow")
**STOPPED HERE - trying to fix order of Variable in docx

putdocx table tbl_all(22,1) = ("Behaviour"), bold shading("yellow")
putdocx table tbl_all(22,.), bold shading("yellow")
putdocx table tbl_all(23,1) = ("Age"), bold shading("yellow")
putdocx table tbl_all(23,.), bold shading("yellow")
putdocx table tbl_all(24,1) = ("Address")
putdocx table tbl_all(36,1) = ("Sex"), bold shading("yellow")
putdocx table tbl_all(36,.), bold shading("yellow")
putdocx table tbl_all(37,1) = ("Source Name")
putdocx table tbl_all(38,1) = ("NF Type")
putdocx table tbl_all(39,1) = ("DOB"), bold shading("yellow")
putdocx table tbl_all(39,.), bold shading("yellow")
putdocx table tbl_all(40,1) = ("NRN")
putdocx table tbl_all(41,1) = ("Lab #")
putdocx table tbl_all(42,1) = ("Duration")
putdocx table tbl_all(43,1) = ("CF Dx")
putdocx table tbl_all(44,1) = ("Source Date")
putdocx table tbl_all(45,1) = ("Certifier")
putdocx table tbl_all(46,1) = ("Onset & Death Interval")
/*
putdocx table tbl_all(23,.), bold
putdocx table tbl_all(24,.), bold
putdocx table tbl_all(38,.), bold
putdocx table tbl_all(43,.), bold
*/
putdocx save "`datapath'\version02\3-output\2019-10-24_review_quality_report.docx", append
putdocx clear
restore
