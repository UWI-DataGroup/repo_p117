** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			15_review_2015_dc.do
    //  project:				BNR
    //  analysts:				Jacqueline CAMPBELL
    //  date first created      26-SEP-2019
    // 	date last modified	    26-SEP-2019
    //  algorithm task			Reporting on review process
    //  status                  Completed
    //  objectve                To check accuracy and efficiency of manual reviewing vs code only cleaning.


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
    log using "`logpath'\15_review_2015_dc.smcl", replace
** HEADER -----------------------------------------------------

* ************************************************************************
* PROGRESS REPORT: REVIEWING 2015 ABS
* Using Redcap BNR-Cancer database
**************************************************************************

** LOAD the dataset with recently matched death data
import excel using "`datapath'\version01\1-input\BNRCancer_DATA_2019-09-26_0456_excel.xlsx", firstrow

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
STOPPED HERE
** check 5
count if event==1 & instrument==. & rvdoaend==. //2
count if event==1 & instrument==. & rvdoaend>today //

** check 6
count if rvelapsed!=. & rvelapsed>100 //0
//list record_id rvreviewer rvelapsed if rvelapsed!=. & rvelapsed>100

** check 7
count if rverrtot!=. & rverrtot>50 //0

** check 8
count if rvformstatus!=. & rvformstatus!=2 //3
//list record_id rvreviewer rvformstatus if rvformstatus!=. & rvformstatus!=2

*********************
* Reviewing PT Form *
*********************
** check 9
count if instrument==1 & rvcr5pid==. //0
tostring rvcr5pid ,replace
count if instrument==1 & (length(rvcr5pid)<8|length(rvcr5pid)>8) //0

** check 10
count if instrument==1 & rvptda==.
count if instrument==1 & rvptda!=13 & rvptda!=14
count if rvptda==98 & rvptoda==.

** check 11
count if instrument==1 & rvpterrtot!=. & rvpterrtot>50

** check 12
count if instrument==1 & rvptcfda==.
count if instrument==1 & rvptdoa==.
count if instrument==1 & rvptcstatus==.
count if instrument==1 & rvptretsource==.
count if instrument==1 & rvptnotesseen==.
count if instrument==1 & rvptnsdate==.
count if instrument==1 & rvptfretsource==.
count if instrument==1 & rvptlname==.
count if instrument==1 & rvptfname==.
count if instrument==1 & rvptinit==.
count if instrument==1 & rvptdob==.
count if instrument==1 & rvptsex==.
count if instrument==1 & rvptnrn==.
count if instrument==1 & rvpthospnum==.
count if instrument==1 & rvptresident==.
count if instrument==1 & rvptslc==.
count if instrument==1 & rvptdlc==.
count if instrument==1 & rvptcomments==.

** check 13
count if instrument==1 & rvptdob==2 & rvptdobdqi==.
count if instrument==1 & rvptsex==2 & rvptsexdqi==.
count if instrument==1 & rvptresident==2 & rvptresidentdqi==.
count if instrument==1 & rvptslc==2 & rvptslcdqi==.
count if instrument==1 & rvptdlc==2 & rvptdlcdqi==.

** check 14
count if rvptformstatus!=. & rvptformstatus!=2

*********************
* Reviewing TT Form *
*********************
** check 15
count if instrument==2 & rvttcr5id==""
count if instrument==2 & (length(rvttcr5id)<2|length(rvttcr5id)>2)

** check 16
count if instrument==2 & rvttda==.
count if instrument==2 & rvttda!=13 & rvttda!=14 & rvttda!=99
count if rvttda==98 & rvttoda==""

** check 17
count if instrument==2 & rvtterrtot!=. & rvtterrtot>50

** check 18
count if instrument==2 & rvttabsda==.
count if instrument==2 & rvttadoa==.
count if instrument==2 & rvttparish==.
count if instrument==2 & rvttaddr==.
count if instrument==2 & rvttage==.
count if instrument==2 & rvttprimsite==.
count if instrument==2 & rvtttop==.
count if instrument==2 & rvtthx==.
count if instrument==2 & rvttmorph==.
count if instrument==2 & rvttlat==.
count if instrument==2 & rvttbeh==.
count if instrument==2 & rvttgrade==.
count if instrument==2 & rvttbasis==.
count if instrument==2 & rvttstaging==.
count if instrument==2 & rvttdot==.
count if instrument==2 & rvttdxyr==.
count if instrument==2 & rvttconsult==.
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
count if instrument==2 & rvttrecstatus==.

** check 19
count if instrument==2 & rvttage==2 & rvttagedqi==.
count if instrument==2 & rvtttop==2 & rvtttopdqi==.
count if instrument==2 & rvttmorph==2 & rvttmorphdqi==.
count if instrument==2 & rvttlat==2 & rvttlatdqi==.
count if instrument==2 & rvttbeh==2 & rvttbehdqi==.
count if instrument==2 & rvttbasis==2 & rvttbasisdqi==.
count if instrument==2 & rvttstaging==2 & rvttstagingdqi==.
count if instrument==2 & rvttdot==2 & rvttdotdqi==.
count if instrument==2 & rvttrx1==2 & rvttrx1dqi==.
count if instrument==2 & rvttrx1d==2 & rvttrx1ddqi==.
count if instrument==2 & rvttrx2==2 & rvttrx2dqi==.
count if instrument==2 & rvttrx2d==2 & rvttrx2ddqi==.
count if instrument==2 & rvttrx3==2 & rvttrx3dqi==.
count if instrument==2 & rvttrx3d==2 & rvttrx3ddqi==.
count if instrument==2 & rvttrx4==2 & rvttrx4dqi==.
count if instrument==2 & rvttrx4d==2 & rvttrx4ddqi==.
count if instrument==2 & rvttrx5==2 & rvttrx5dqi==.
count if instrument==2 & rvttrx5d==2 & rvttrx5ddqi==.

** check 20
count if rvttformstatus!=. & rvttformstatus!=2

*********************
* Reviewing ST Form *
*********************
** check 21
count if instrument==3 & rvstcr5id==""
count if instrument==3 & (length(rvstcr5id)<4|length(rvstcr5id)>4)

** check 22
count if instrument==3 & rvstda==.
count if instrument==3 & rvstda!=13 & rvstda!=14 & rvstda!=98 & rvstda!=99
count if rvstda==98 & rvstoda==""

** check 23
count if instrument==3 & rvsterrtot!=. & rvsterrtot>50

** check 24
count if instrument==3 & rvstrectype==.

** check 25
count if instrument==3 & rvstabsda==.
count if instrument==3 & rvstadoa==.
count if instrument==3 & rvstnftype==.
count if instrument==3 & rvstsourcename==.
count if instrument==3 & rvstdoc==.
count if instrument==3 & rvstdocaddr==.
count if instrument==3 & rvstrecnum==.
count if instrument==3 & rvstcfdx==.
count if instrument==3 & rvstlabnum==.
count if instrument==3 & rvstspecimen==.
count if instrument==3 & rvstsampledate==.
count if instrument==3 & rvstrecvdate==.
count if instrument==3 & rvstrptdate==.
count if instrument==3 & rvstclindets==.
count if instrument==3 & rvstcytofinds==.
count if instrument==3 & rvstmd==.
count if instrument==3 & rvstconsrpt==.
count if instrument==3 & rvstcod==.
count if instrument==3 & rvstduration==.
count if instrument==3 & rvstonset==.
count if instrument==3 & rvstcertifier==.
count if instrument==3 & rvstadmdate==.
count if instrument==3 & rvstdfc==.
count if instrument==3 & rvstrtdate==.

** check 26
count if rvstformstatus!=. & rvstformstatus!=2


*****************
* Reviewed Form *
*****************
** check 27
count if event==2 & rvdoa==.
count if event!=2 & rvdoa!=.

** check 28
count if event==2 & reviewtot==.
count if event!=2 & reviewtot!=.

** check 29
count if event==2 & reviewedtot==.
count if event!=2 & reviewedtot!=.

** check 30
count if event==2 & rvtotpending==.
count if event!=2 & rvtotpending!=.

** check 31
count if event==2 & rvtotpendingper==.
count if event!=2 & rvtotpendingper!=.

** check 32
count if rvedformstatus!=. & rvedformstatus!=1
count if event!=2 & rvedformstatus!=.


/*
** CREATE report variables
egen rvtotal=total(reviewingtot) if reviewingtot!=. | reviewingtot!=0
egen rvpterrtotal=total(rvpterrtot) if rvpterrtot!=. | rvpterrtot!=0



** CREATE progress report
count //



save "`datapath'\version01\2-working\2015_review_cancer_dc" ,replace
label data "BNR-Cancer prepared 2015 data"
notes _dta :These data prepared for 2015 cancer review report
