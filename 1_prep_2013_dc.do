** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    1_prep_2013.do
    //  project:				        BNR
    //  analysts:				       	Jacqueline CAMPBELL
    //  date first created      12-MAR-2019
    // 	date last modified	    12-MAR-2019
    //  algorithm task			    Preparing 2013 cancer dataset for cleaning
    //  status                  Completed
    //  objectve                To have one dataset with cleaned and grouped 2013 data for inclusion in 2014 cancer report.


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
    log using "`logpath'\1_prep_2013_dc.smcl", replace
** HEADER -----------------------------------------------------

* ************************************************************************
* PREP AND FORMAT
* Using version02 dofiles created in 2014 data cleaning folder (Sync)
**************************************************************************

** Load the dataset with recently matched death data
use "`datapath'\version01\1-input\datarequest_NAACCR-IACR_matched_2013", clear

count //

** Rename and Format varaibles
rename personsearch persearch
rename abstractorcode ttda
rename PatientRecordID pid2
rename RegistryNumber pid
rename TumourID eid2
rename Recordstatus recstatus
rename Checkstatus checkstatus
rename TumourUpdatedBy tumourupdatedby
rename PatientUpdatedBy patientupdatedby
rename SourceRecordID sid2
rename StatusLastContact slc
rename Parish parish
rename Address addr
rename Age age
rename PrimarySite primarysite
rename Topography topography
rename BasisOfDiagnosis basis
rename Histology hx
rename Morphology morph
rename Laterality lat
rename Behaviour beh
rename Grade grade
rename Staging staging
rename Consultant consultant
rename HospitalNumber hospnum
rename CausesOfDeath cr5cod
rename DiagnosisYear dxyr
rename Treat*1 rx1
rename Treat*2 rx2
rename Treat*3 rx3
rename Treat*4 rx4
rename Treat*5 rx5
rename Oth*Treat*1 orx1
rename Oth*Treat*2 orx2
rename NoTreat*1 norx1
rename NoTreat*2 norx2
rename NFType nftype
rename SourceName sourcename
rename Doctor doctor
rename DoctorAddress docaddr
rename RecordNumber recnum
rename CFDiagnosis cfdx
rename LabNumber labnum
rename Specimen specimen
rename ClinicalDetails clindets
rename CytologicalFindings cytofinds
rename MicroscopicDescription md
rename ConsultationReport consrpt
rename DurationOfIllness duration
rename OnsetDeathInterval onsetint
rename Certifier certifier
rename TumourIDSourceTable tumouridsourcetable


** Clean and/or Remove variables that did not merge properly
** address
count if m!=""
count if m!="" & addr!=""
replace addr=m+" "+n if addr=="" & m!=""

count if addr=="" & m!="" & n!=""
replace addr=m+" "+n if addr=="" & m!="" & n!=""
replace m="" if addr=="" & m!="" & n!=""

count if n!=""

** deathid
sort pid
order pid fname lname natregno addr cod1a
count if slc!=vstatus
count if slc==2 & deathid==.
list pid fname lname dod lineno if slc==2 & deathid==.
//check these against redcap death data (1-input) for deathid

replace deathid=7058 if pid==20080032
replace deathid=2818 if pid==20080053
replace deathid=8695 if pid==20080056
replace deathid=2220 if pid==20080070
replace deathid=1081 if pid==20080071
replace deathid=1072 if pid==20080072
replace deathid=597 if pid==20080073
replace deathid=2136 if pid==20080074
replace deathid=1739 if pid==20080075
replace deathid=2147 if pid==20080076
replace deathid=404 if pid==20080077
replace deathid=896 if pid==20080078
replace deathid=1353 if pid==20080079
replace deathid=973 if pid==20080080
replace deathid=349 if pid==20080081
replace deathid=702 if pid==20080082
replace deathid=1258 if pid==20080083
replace deathid=1022 if pid==20080084
replace deathid=1264 if pid==20080085
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==
replace deathid=1964 if pid==20080915
replace deathid=2496 if pid==20080938
replace deathid=6785 if pid==20080967
replace deathid=4458 if pid==20081034
replace deathid=3625 if pid==20081040
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==
replace deathid= if pid==

** Create unique id for each tumour (cr5id)
/*
Various record IDs auto-generated by CanReg5 which uniquely identify patients (pid), tumours (eid) and sources (sid)
Note: When records merged in CanReg5, the following can take place:
1) the pid can be kept so in these cases patientrecordid will differentiate between the 2 patient records for the same patient and/or
2) the first 8 digits in tumourid remains the same as the defunct (i.e. no longer used) pid while the new pid will be the pid into which
   that tumour was merged e.g. 20130303 has 2 tumours with different tumourids - 201303030102 and 201407170101.
*/
gen top = topography
destring topography, replace

gen str_sourcerecordid=sid2
gen sourcetotal = substr(str_sourcerecordid,-1,1)
destring sourcetot, gen (sourcetot_orig)

gen str_pid2 = pid2
gen patienttotal = substr(str_pid2,-1,1)
destring patienttot, gen (patienttot)

gen str_patientidtumourtable=patientidtumourtable
gen mpseq2=mpseq
replace mpseq2=1 if mpseq2==0
tostring mpseq2, replace
gen eid = str_patientidtumourtable + "010" + mpseq2
gen sourceseq = substr(str_sourcerecordid,13,2)
gen sid = eid + sourceseq

** Create variable to describe the record as T1S1 (tumour 1 source 1) etc.
** This will help the DA to know which record/table needs correcting.
gen tumseq = substr(eid,9,4)
gen tumsourceseq = tumseq + sourceseq
gen cr5id = ""
**************
** TUMOUR 1 **
**************
replace cr5id="T1S1" if tumsourceseq=="010101"
replace cr5id="T1S2" if tumsourceseq=="010102"
replace cr5id="T1S3" if tumsourceseq=="010103"
replace cr5id="T1S4" if tumsourceseq=="010104"
replace cr5id="T1S5" if tumsourceseq=="010105"
replace cr5id="T1S6" if tumsourceseq=="010106"
replace cr5id="T1S7" if tumsourceseq=="010107"
replace cr5id="T1S8" if tumsourceseq=="010108"
**************
** TUMOUR 2 **
**************
replace cr5id="T2S1" if tumsourceseq=="010201"
replace cr5id="T2S2" if tumsourceseq=="010202"
replace cr5id="T2S3" if tumsourceseq=="010203"
replace cr5id="T2S4" if tumsourceseq=="010204"
replace cr5id="T2S5" if tumsourceseq=="010205"
replace cr5id="T2S6" if tumsourceseq=="010206"
replace cr5id="T2S7" if tumsourceseq=="010207"
replace cr5id="T2S8" if tumsourceseq=="010208"
**************
** TUMOUR 3 **
**************
replace cr5id="T3S1" if tumsourceseq=="010301"
replace cr5id="T3S2" if tumsourceseq=="010302"
replace cr5id="T3S3" if tumsourceseq=="010303"
replace cr5id="T3S4" if tumsourceseq=="010304"
replace cr5id="T3S5" if tumsourceseq=="010305"
replace cr5id="T3S6" if tumsourceseq=="010306"
replace cr5id="T3S7" if tumsourceseq=="010307"
replace cr5id="T3S8" if tumsourceseq=="010308"
**************
** TUMOUR 4 **
**************
replace cr5id="T4S1" if tumsourceseq=="010401"
replace cr5id="T4S2" if tumsourceseq=="010402"
replace cr5id="T4S3" if tumsourceseq=="010403"
replace cr5id="T4S4" if tumsourceseq=="010404"
replace cr5id="T4S5" if tumsourceseq=="010405"
replace cr5id="T4S6" if tumsourceseq=="010406"
replace cr5id="T4S7" if tumsourceseq=="010407"
replace cr5id="T4S8" if tumsourceseq=="010408"
**************
** TUMOUR 5 **
**************
replace cr5id="T5S1" if tumsourceseq=="010501"
replace cr5id="T5S2" if tumsourceseq=="010502"
replace cr5id="T5S3" if tumsourceseq=="010503"
replace cr5id="T5S4" if tumsourceseq=="010504"
replace cr5id="T5S5" if tumsourceseq=="010505"
replace cr5id="T5S6" if tumsourceseq=="010506"
replace cr5id="T5S7" if tumsourceseq=="010507"
replace cr5id="T5S8" if tumsourceseq=="010508"
**************
** TUMOUR 6 **
**************
replace cr5id="T6S1" if tumsourceseq=="010601"
replace cr5id="T6S2" if tumsourceseq=="010602"
replace cr5id="T6S3" if tumsourceseq=="010603"
replace cr5id="T6S4" if tumsourceseq=="010604"
replace cr5id="T6S5" if tumsourceseq=="010605"
replace cr5id="T6S6" if tumsourceseq=="010606"
replace cr5id="T6S7" if tumsourceseq=="010607"
replace cr5id="T6S8" if tumsourceseq=="010608"
**************
** TUMOUR 7 **
**************
replace cr5id="T7S1" if tumsourceseq=="010701"
replace cr5id="T7S2" if tumsourceseq=="010702"
replace cr5id="T7S3" if tumsourceseq=="010703"
replace cr5id="T7S4" if tumsourceseq=="010704"
replace cr5id="T7S5" if tumsourceseq=="010705"
replace cr5id="T7S6" if tumsourceseq=="010706"
replace cr5id="T7S7" if tumsourceseq=="010707"
replace cr5id="T7S8" if tumsourceseq=="010708"
**************
** TUMOUR 8 **
**************
replace cr5id="T8S1" if tumsourceseq=="010801"
replace cr5id="T8S2" if tumsourceseq=="010802"
replace cr5id="T8S3" if tumsourceseq=="010803"
replace cr5id="T8S4" if tumsourceseq=="010804"
replace cr5id="T8S5" if tumsourceseq=="010805"
replace cr5id="T8S6" if tumsourceseq=="010806"
replace cr5id="T8S7" if tumsourceseq=="010807"
replace cr5id="T8S8" if tumsourceseq=="010808"

** Check for missing cr5ids that were not replaced above
count if cr5id=="" //0
list pid if cr5id==""

** Check (using Stata data editor - filter by 'pid' and check cr5id is unique for each pid) for ones where
** cases were merged but eid and cr5id not properly assigned (e.g. see 20140855) then
** correct the eids and cr5ids not correctly assigned
gen str_sourcerecordid2 = substr(str_sourcerecordid,1,8)
count if str_sourcerecordid2!=pid //418 28jun18; 470 08aug18/06sep18
list pid eid sid str_sourcerecordid str_sourcerecordid2 if str_sourcerecordid2!=pid
** Re-checked via previously printed list of 31 below (15feb18) and newly printed list of 33 below (18apr18) - 2 extra is pid 20080622 and pid 20145084 T2.
gen eidcorrect=""
** Mark as correct cases whose eid & cr5id were correctly assigned and do not need replacing
replace eidcorrect="yes" if pid=="20080200" | pid=="20080233" | pid=="20080482" | pid=="20080539" | pid=="20080553" ///
							| pid=="20080555" | pid=="20080562" | pid=="20080708" | pid=="20080839" | pid=="20130009" ///
							| pid=="20130010" | pid=="20130018" | pid=="20130025" | pid=="20130044" | pid=="20130049" ///
							| pid=="20130056" | pid=="20130070" | pid=="20130080" | pid=="20130101" | pid=="20130151" ///
							| pid=="20130162" | pid=="20130170" | pid=="20130171" | pid=="20130174" | pid=="20130175" ///
							| pid=="20130176" | pid=="20130210" | pid=="20130212" | pid=="20130239" | pid=="20130240" ///
							| pid=="20130241" | pid=="20130242" | pid=="20130247" | pid=="20130248" | pid=="20130249" ///
							| pid=="20130250" | pid=="20130251" | pid=="20130252" | pid=="20130253" | pid=="20130254" ///
							| pid=="20130257" | pid=="20130258" | pid=="20130260" | pid=="20130261" | pid=="20130262"
replace eidcorrect="yes" if pid=="20130264" | pid=="20130270" | pid=="20130275" | pid=="20130276" | pid=="20130285" ///
							| pid=="20130286" | pid=="20130293" | pid=="20130296" | pid=="20130298" | pid=="20130300" ///
							| pid=="20130303" | pid=="20130307" | pid=="20130313" | pid=="20130316" | pid=="20130317" ///
							| pid=="20130327" | pid=="20130328" | pid=="20130338" | pid=="20130341" | pid=="20130352" ///
							| pid=="20130353" | pid=="20130357" | pid=="20130372" | pid=="20130380" | pid=="20130381" ///
							| pid=="20130384" | pid=="20130385" | pid=="20130386" | pid=="20130387" | pid=="20130388" ///
							| pid=="20130389" | pid=="20130406" | pid=="20130412" | pid=="20130417" | pid=="20130508" ///
							| pid=="20130510" | pid=="20130581" | pid=="20130582" | pid=="20130583" | pid=="20130585" ///
							| pid=="20130586" | pid=="20130587" | pid=="20130588" | pid=="20130589" | pid=="20130590"
replace eidcorrect="yes" if pid=="20130594" | pid=="20130596" | pid=="20130597" | pid=="20130603" | pid=="20130612" ///
							| pid=="20130616" | pid=="20130620" | pid=="20130633" | pid=="20130639" | pid=="20130644" ///
							| pid=="20130658" | pid=="20130663" | pid=="20130673" | pid=="20130687" | pid=="20130689" ///
							| pid=="20130692" | pid=="20130702" | pid=="20130703" | pid=="20130712" | pid=="20130728" ///
							| pid=="20130730" | pid=="20130731" | pid=="20130747" | pid=="20130748" | pid=="20130751" ///
							| pid=="20130752" | pid=="20130762" | pid=="20130766" | pid=="20130768" | pid=="20130775" ///
							| pid=="20130778" | pid=="20130779" | pid=="20130780" | pid=="20130798" | pid=="20130809" ///
							| pid=="20130812" | pid=="20130819" | pid=="20130834" | pid=="20130861" | pid=="20140025" ///
							| pid=="20140025" | pid=="20140037" | pid=="20140058" | pid=="20140064" | pid=="20140074"
replace eidcorrect="yes" if pid=="20140077" | pid=="20140091" | pid=="20140093" | pid=="20140125" | pid=="20140138" ///
							| pid=="20140161" | pid=="20140161" | pid=="20140165" | pid=="20140166" | pid=="20140173" ///
							| pid=="20140176" | pid=="20140207" | pid=="20140260" | pid=="20140289" | pid=="20140301" ///
							| pid=="20140323" | pid=="20140349" | pid=="20140360" | pid=="20140371" | pid=="20140373" ///
							| pid=="20140375" | pid=="20140387" | pid=="20140394" | pid=="20140395" | pid=="20140398" ///
							| pid=="20140415" | pid=="20140429" | pid=="20140441" | pid=="20140459" | pid=="20140460" ///
							| pid=="20140463" | pid=="20140519" | pid=="20140525" | pid=="20140575" | pid=="20140592" ///
							| pid=="20140646" | pid=="20140647" | pid=="20140679" | pid=="20140690" | pid=="20140691" ///
							| pid=="20140692" | pid=="20140695" | pid=="20140697" | pid=="20140698" | pid=="20140703" ///
							| pid=="20140705" | pid=="20140707" | pid=="20140712" | pid=="20140716" | pid=="20140730"
replace eidcorrect="yes" if pid=="20140733" | pid=="20140735" | pid=="20140738" | pid=="20140742" | pid=="20140744" ///
							| pid=="20140750" | pid=="20140752" | pid=="20140759" | pid=="20140764" | pid=="20140776" ///
							| pid=="20140789" | pid=="20140802" | pid=="20140803" | pid=="20140804" | pid=="20140805" ///
							| pid=="20140806" | pid=="20140807" | pid=="20140809" | pid=="20140810" | pid=="20140811" ///
							| pid=="20140820" | pid=="20140826" | pid=="20140830" | pid=="20140831" | pid=="20140833" ///
							| pid=="20140836" | pid=="20140838" | pid=="20140839" | pid=="20140841" | pid=="20140845" ///
							| pid=="20140865" | pid=="20140872" | pid=="20140882" | pid=="20140903" | pid=="20140907" ///
							| pid=="20140945" | pid=="20140952" | pid=="20140973" | pid=="20140975" | pid=="20140988" ///
							| pid=="20141018" | pid=="20141021" | pid=="20141027" | pid=="20141029" | pid=="20141040"
replace eidcorrect="yes" if pid=="20141052" | pid=="20141068" | pid=="20141075" | pid=="20141079" | pid=="20141087" ///
							| pid=="20141124" | pid=="20141167" | pid=="20141211" | pid=="20141246" | pid=="20141320" ///
							| pid=="20141501" | pid=="20150026" | pid=="20150154" | pid=="20150155" | pid=="20160018" ///
							| pid=="20160024" | pid=="20160041" | pid=="20090016" | pid=="20130029" | pid=="20130107" ///
							| pid=="20130279" | pid=="20130398" | pid=="20140855" | pid=="20140869"

** Now replace eid, sid and cr5id for cases that were incorrectly assigned and need replacing
replace eidcorrect="no" if pid=="20140739" & str_sourcerecordid2=="20140741"
replace eid="201407390103" if pid=="20140739" & str_sourcerecordid2=="20140741"
replace cr5id="T3S1" if pid=="20140739" & str_sourcerecordid2=="20140741"
replace sid="20140739010301" if pid=="20140739" & str_sourcerecordid2=="20140741"
replace tumseq="0103" if pid=="20140739" & str_sourcerecordid=="20140741"
replace tumsourceseq="010301" if pid=="20140739" & str_sourcerecordid=="20140741"

** Re-check (using Stata data editor) for ones where cases were merged but eid not properly assigned then
** correct the eids not correctly assigned
count if str_sourcerecordid2!=pid & eidcorrect=="" //114 28jun18; 164 08aug18/06sep18
list pid eid sid str_sourcerecordid str_sourcerecordid2 if str_sourcerecordid2!=pid & eidcorrect==""
replace eidcorrect="yes" if pid=="20140739" & str_sourcerecordid2=="20140740"
** Mark as correct cases whose eid & cr5id were correctly assigned and do not need replacing
** Re-checked via previously printed list (15feb18) and newly printed list (18apr18) - added in pid "20080622"
replace eidcorrect="yes" if pid=="20080403" | pid=="20081036" | pid=="20130361" | pid=="20130591" | pid=="20130661" ///
							| pid=="20130769" | pid=="20130774" | pid=="20140129" | pid=="20140474" | pid=="20140928" ///
							| pid=="20140966" | pid=="20141083" | pid=="20141084" | pid=="20141098" | pid=="20141181" ///
							| pid=="20141273" | pid=="20141373" | pid=="20141411" | pid=="20141477" | pid=="20141489" ///
							| pid=="20141490" | pid=="20141532" | pid=="20145027" | pid=="20145030" | pid=="20145060" ///
							| pid=="20145077" | pid=="20145084" | pid=="20150004" | pid=="20080622"
** Re-check (using Stata data editor) for ones where cases were merged but eid not properly assigned then
** correct the eids not correctly assigned
count if str_sourcerecordid2!=pid & eidcorrect=="" //76 28jun18 - only corrected 8 at this time since SAF wants flags pre-2014; 126 08aug18/06sep18
** Left 46 to be done as these are not dx in 2014 (JC checked main CR5db on 06sep18 for cases where dxyr=2014 but reg.#>2014 and only 3 cases
** (reg.#s 20150001, 20150175, 20160029) and these do not appear on below list.)
list pid eid sid str_sourcerecordid str_sourcerecordid2 if str_sourcerecordid2!=pid & eidcorrect==""
replace eidcorrect="yes" if pid=="" & str_sourcerecordid2==""
** Mark as correct cases whose eid & cr5id were correctly assigned and do not need replacing
** Re-checked via previously printed list (15feb18) and newly printed list (18apr18) - added in pid "20080622"
replace eidcorrect="yes" if pid=="20080022" | pid=="20080184" | pid=="20080208" | pid=="20080242" | pid=="20080340" | pid=="20080365" | pid=="20080401" ///
							| pid=="20130606" | pid=="20130672" | pid=="20140121" | pid=="20140137" | pid=="20140157" | pid=="20140170" | pid=="20140206" ///
							| pid=="20140232" | pid=="20140286" | pid=="20140294" | pid=="20140308" | pid=="20140315" | pid=="20140407" | pid=="20140483" ///
							| pid=="20140540" | pid=="20140553" | pid=="20140555" | pid=="20140693" | pid=="20140694" | pid=="20140822" | pid=="20140843" ///
							| pid=="20140886" | pid=="20140929" | pid=="20140954" | pid=="20140962" | pid=="20141047" | pid=="20141059" | pid=="20141070" ///
							| pid=="20141108" | pid=="20141115" | pid=="20141117" | pid=="20141171" | pid=="20141174" | pid=="20141191" | pid=="20141236" ///
							| pid=="20141321" | pid=="20141335" | pid=="20141404" | pid=="20141409" | pid=="20141481" | pid=="20141544" | pid=="20141548" ///
							| pid=="20141550" | pid=="20141567" | pid=="20145138" | pid=="20150015" | pid=="20150041" | pid=="20150043" | pid=="20150050"

** Now replace eid, sid and cr5id for cases that were incorrectly assigned and need replacing
replace eidcorrect="no" if pid=="20081085" & str_sourcerecordid2=="20150340"
replace eid="200810850102" if pid=="20081085" & str_sourcerecordid2=="20150340"
replace cr5id="T2S1" if pid=="20081085" & str_sourcerecordid2=="20150340"
replace sid="20081085010201" if pid=="20081085" & str_sourcerecordid2=="20150340"
replace tumseq="0102" if pid=="20081085" & str_sourcerecordid=="20150340"
replace tumsourceseq="010201" if pid=="20081085" & str_sourcerecordid=="20150340"

replace eidcorrect="no" if pid=="20130160" & str_sourcerecordid2=="20130394"
replace eid="201301600102" if pid=="20130160" & str_sourcerecordid2=="20130394"
replace cr5id="T2S1" if pid=="20130160" & str_sourcerecordid2=="20130394"
replace sid="20130160010201" if pid=="20130160" & str_sourcerecordid2=="20130394"
replace tumseq="0102" if pid=="20130160" & str_sourcerecordid=="20130394"
replace tumsourceseq="010201" if pid=="20130160" & str_sourcerecordid=="20130394"

replace eidcorrect="no" if pid=="20150039" & str_sourcerecordid2=="20150197"
replace eid="201500390102" if pid=="20150039" & str_sourcerecordid2=="20150197"
replace cr5id="T2S1" if pid=="20150039" & str_sourcerecordid2=="20150197"
replace sid="20150039010201" if pid=="20150039" & str_sourcerecordid2=="20150197"
replace tumseq="0102" if pid=="20150039" & str_sourcerecordid=="20150197"
replace tumsourceseq="010201" if pid=="20150039" & str_sourcerecordid=="20150197"

** Re-check (using Stata data editor) for ones where cases were merged but eid not properly assigned then
** correct the eids not correctly assigned
count if str_sourcerecordid2!=pid & eidcorrect=="" //76 28jun18; 118 08aug2018; 46 06esp18 - left to be done when cleaning 2015 data
list pid eid sid str_sourcerecordid str_sourcerecordid2 if str_sourcerecordid2!=pid & eidcorrect==""


** Create variable to count # of tumour and source records per patient record using cr5id
gen tumourtot=.
gen sourcetot=.
replace tumourtot=1 if regexm(cr5id, "T1") //4586 changes made 18apr18
replace tumourtot=2 if regexm(cr5id, "T2") //442 changes made 18apr18
replace tumourtot=3 if regexm(cr5id, "T3") //75 changes made 18apr18
replace tumourtot=4 if regexm(cr5id, "T4") //26 changes made 18apr18
replace tumourtot=5 if regexm(cr5id, "T5") //13 changes made 18apr18
replace tumourtot=6 if regexm(cr5id, "T6") //11 changes made 18apr18
replace tumourtot=7 if regexm(cr5id, "T7") //4 changes made 18apr18
replace tumourtot=8 if regexm(cr5id, "T8") //1 changes made 18apr18
replace sourcetot=1 if regexm(cr5id, "S1") //4262 changes made 18apr18
replace sourcetot=2 if regexm(cr5id, "S2") //700 changes made 18apr18
replace sourcetot=3 if regexm(cr5id, "S3") //163 changes made 18apr18
replace sourcetot=4 if regexm(cr5id, "S4") //27 changes made 18apr18
replace sourcetot=5 if regexm(cr5id, "S5") //5 changes made 18apr18
replace sourcetot=6 if regexm(cr5id, "S6") //1 changes made 18apr18
replace sourcetot=7 if regexm(cr5id, "S7") //0 changes made 18apr18
replace sourcetot=8 if regexm(cr5id, "S8") //0 changes made 18apr18
** Check for missing cr5ids that were not replaced above
count if tumourtot==. //0
count if sourcetot==. //0
list pid cr5id tumourtot sourcetot if tumourtot==. | sourcetot==.


** Create diagnosis year varaible to match 2014 dataset
gen dxyr=year(dot)


** Create categories for topography according to groupings in ICD-O-3 book
gen topcat=. //5150 01mar18
replace topcat=1 if topography>-1 & topography<19
replace topcat=2 if topography==19
replace topcat=3 if topography>19 & topography<30
replace topcat=4 if topography>29 & topography<40
replace topcat=5 if topography>39 & topography<50
replace topcat=6 if topography>49 & topography<60
replace topcat=7 if topography>59 & topography<79
replace topcat=8 if topography==79
replace topcat=9 if topography>79 & topography<90
replace topcat=10 if topography>89 & topography<100
replace topcat=11 if topography>99 & topography<110
replace topcat=12 if topography>109 & topography<129
replace topcat=13 if topography==129
replace topcat=14 if topography>129 & topography<140
replace topcat=15 if topography>139 & topography<150
replace topcat=16 if topography>149 & topography<160
replace topcat=17 if topography>159 & topography<170
replace topcat=18 if topography>169 & topography<180
replace topcat=19 if topography>179 & topography<199
replace topcat=20 if topography==199
replace topcat=21 if topography==209
replace topcat=22 if topography>209 & topography<220
replace topcat=23 if topography>219 & topography<239
replace topcat=24 if topography==239
replace topcat=25 if topography>239 & topography<250
replace topcat=26 if topography>249 & topography<260
replace topcat=27 if topography>259 & topography<300
replace topcat=28 if topography>299 & topography<310
replace topcat=29 if topography>309 & topography<320
replace topcat=30 if topography>319 & topography<339
replace topcat=31 if topography==339
replace topcat=32 if topography>339 & topography<379
replace topcat=33 if topography==379
replace topcat=34 if topography>379 & topography<390
replace topcat=35 if topography>389 & topography<400
replace topcat=36 if topography>399 & topography<410
replace topcat=37 if topography>409 & topography<420
replace topcat=38 if topography>419 & topography<440
replace topcat=39 if topography>439 & topography<470
replace topcat=40 if topography>469 & topography<480
replace topcat=41 if topography>479 & topography<490
replace topcat=42 if topography>489 & topography<500
replace topcat=43 if topography>499 & topography<510
replace topcat=44 if topography>509 & topography<529
replace topcat=45 if topography==529
replace topcat=46 if topography>529 & topography<540
replace topcat=47 if topography>539 & topography<559
replace topcat=48 if topography==559
replace topcat=49 if topography==569
replace topcat=50 if topography>569 & topography<589
replace topcat=51 if topography==589
replace topcat=52 if topography>599 & topography<619
replace topcat=53 if topography==619
replace topcat=54 if topography>619 & topography<630
replace topcat=55 if topography>629 & topography<649
replace topcat=56 if topography==649
replace topcat=57 if topography==659
replace topcat=58 if topography==669
replace topcat=59 if topography>669 & topography<680
replace topcat=60 if topography>679 & topography<690
replace topcat=61 if topography>689 & topography<700
replace topcat=62 if topography>699 & topography<710
replace topcat=63 if topography>709 & topography<720
replace topcat=64 if topography>719 & topography<739
replace topcat=65 if topography==739
replace topcat=66 if topography>739 & topography<750
replace topcat=67 if topography>749 & topography<760
replace topcat=68 if topography>759 & topography<770
replace topcat=69 if topography>769 & topography<809
replace topcat=70 if topography==809
label var topcat "Topography Category"
label define topcat_lab 1 "Lip" 2 "Tongue-Base" 3 "Tongue-Other" 4 "Gum" 5 "Mouth-Floor" 6 "Palate" 7 "Mouth-Other" 8 "Parotid Gland" 9 "Major Saliva. Glands" ///
						10 "Tonsil" 11 "Oropharynx" 12 "Nasopharynx" 13 "Pyriform Sinus" 14 "Hypopharynx" 15 "Lip/Orocavity/Pharynx" 16 "Esophagus" 17 "Stomach" ///
						18 "Small Intestine" 19 "Colon" 20 "Rectosigmoid" 21 "Rectum" 22 "Anus" 23 "Liver/intrahep.ducts" 24 "Gallbladder" 25 "Biliary Tract-Other" ///
						26 "Pancreas" 27 "Digestive-Other" 28 "Nasocavity/Ear" 29 "Accessory Sinuses" 30 "Larynx" 31 "Trachea" 32 "Bronchus/Lung" 33 "Thymus" ///
						34 "Heart/Mediastinum/Pleura" 35 "Resp.System-Other" 36 "Bone/Joints/Cartilage-Limbs" 37 "Bone/Joints/Cartilage-Other" 38 "Heme/Reticulo." ///
						39 "Skin" 40 "Peripheral Nerves/ANS" 41 "Retro./Peritoneum" 42 "Connect./Subcutan.Soft Tissues" 43 "Breast" 44 "Vulva" 45 "Vagina" 46 "Cervix" ///
						47 "Corpus" 48 "Uterus,NOS" 49 "Ovary" 50 "FGS-Other" 51 "Placenta" 52 "Penis" 53 "Prostate Gland" 54 "Testis" 55 "MSG-Other" 56 "Kidney" ///
						57 "Renal Pelvis" 58 "Ureter" 59 "Bladder" 60 "Urinary-Other" 61 "Eye" 62 "Meninges" 63 "Brain" 64 "Spinal Cord/CNS" 65 "Thyroid" 66 "Adrenal Gland" ///
						67 "Endocrine-Other" 68 "Other/Ill defined" 69 "LNs" 70 "PSU" ,modify
label values topcat topcat_lab

** Create category for primarysite/topography check
gen topcheckcat=.
replace topcheckcat=1 if regexm(primarysite, "LIP") & !(strmatch(strupper(primarysite), "*SKIN*")|strmatch(strupper(primarysite), "*CERVIX*")) & (topography>9&topography!=148)
replace topcheckcat=2 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==8
replace topcheckcat=3 if regexm(primarysite, "TONGUE") & (topography<19|topography>29)
replace topcheckcat=4 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==28
replace topcheckcat=5 if regexm(primarysite, "GUM") & (topography<30|topography>39) & !(strmatch(strupper(primarysite), "*SKIN*"))
replace topcheckcat=6 if regexm(primarysite, "PALATE") & (topography<40|topography>69)
replace topcheckcat=7 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==48
replace topcheckcat=8 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==58
replace topcheckcat=9 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==68
replace topcheckcat=10 if regexm(primarysite, "GLAND") & (topography<79|topography>89) & !(strmatch(strupper(primarysite), "*MINOR*")|strmatch(strupper(primarysite), "*PROSTATE*")|strmatch(strupper(primarysite), "*THYROID*")|strmatch(strupper(primarysite), "*PINEAL*")|strmatch(strupper(primarysite), "*PITUITARY*"))
replace topcheckcat=11 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==88
replace topcheckcat=12 if regexm(primarysite, "TONSIL") & (topography<90|topography>99)
replace topcheckcat=13 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==98
replace topcheckcat=14 if regexm(primarysite, "OROPHARYNX") & (topography<100|topography>109)
replace topcheckcat=15 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==108
replace topcheckcat=16 if regexm(primarysite, "NASOPHARYNX") & (topography<110|topography>119)
replace topcheckcat=17 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==118
replace topcheckcat=18 if regexm(primarysite, "PYRIFORM") & (topography!=129&topography!=148)
replace topcheckcat=19 if regexm(primarysite, "HYPOPHARYNX") & (topography<130|topography>139)
replace topcheckcat=20 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==138
replace topcheckcat=21 if (regexm(primarysite, "PHARYNX") & regexm(primarysite, "OVERLAP")) & (topography!=140&topography!=148)
replace topcheckcat=22 if regexm(primarysite, "WALDEYER") & topography!=142
replace topcheckcat=23 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==148
replace topcheckcat=24 if regexm(primarysite, "PHAGUS") & !(strmatch(strupper(primarysite), "*JUNCT*")) & (topography<150|topography>159)
replace topcheckcat=25 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==158
replace topcheckcat=26 if (regexm(primarysite, "GASTR") | regexm(primarysite, "STOMACH")) & !(strmatch(strupper(primarysite), "*GASTROINTESTINAL*")|strmatch(strupper(primarysite), "*ABDOMEN*")) & (topography<160|topography>169)
replace topcheckcat=27 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==168
replace topcheckcat=28 if (regexm(primarysite, "NUM") | regexm(primarysite, "SMALL")) & !(strmatch(strupper(primarysite), "*STERNUM*")|strmatch(strupper(primarysite), "*MEDIA*")|strmatch(strupper(primarysite), "*POSITION*")) & (topography<170|topography>179)
replace topcheckcat=29 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==178
replace topcheckcat=30 if regexm(primarysite, "COLON") & !(strmatch(strupper(primarysite), "*RECT*")) & (topography<180|topography>189)
replace topcheckcat=31 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==188
replace topcheckcat=32 if regexm(primarysite, "RECTO") & topography!=199
replace topcheckcat=33 if regexm(primarysite, "RECTUM") & !(strmatch(strupper(primarysite), "*AN*")) & topography!=209
replace topcheckcat=34 if regexm(primarysite, "ANUS") & !(strmatch(strupper(primarysite), "*RECT*")) & (topography<210|topography>212)
replace topcheckcat=35 if !(strmatch(strupper(primarysite), "*OVERLAP*")|strmatch(strupper(primarysite), "*RECT*")|strmatch(strupper(primarysite), "*AN*")|strmatch(strupper(primarysite), "*JUNCT*")) & topography==218
replace topcheckcat=36 if (regexm(primarysite, "LIVER")|regexm(primarysite, "HEPTO")) & !(strmatch(strupper(primarysite), "*GLAND*")) & (topography<220|topography>221)
replace topcheckcat=37 if regexm(primarysite, "GALL") & topography!=239
replace topcheckcat=38 if (regexm(primarysite, "BILI")|regexm(primarysite, "VATER")) & !(strmatch(strupper(primarysite), "*INTRAHEP*")) & (topography<240|topography>241&topography!=249)
replace topcheckcat=39 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==248
replace topcheckcat=40 if regexm(primarysite, "PANCREA") & !(strmatch(strupper(primarysite), "*ABDOMEN*")) & (topography<250|topography>259)
replace topcheckcat=41 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==258
replace topcheckcat=42 if (regexm(primarysite, "BOWEL") | regexm(primarysite, "INTESTIN")) & !(strmatch(strupper(primarysite), "*SMALL*")|strmatch(strupper(primarysite), "*GASTRO*")) & (topography!=260&topography!=269)
replace topcheckcat=43 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==268
replace topcheckcat=44 if regexm(primarysite, "NASAL") & !(strmatch(strupper(primarysite), "*SIN*")) & topography!=300
replace topcheckcat=45 if regexm(primarysite, "EAR") & !(strmatch(strupper(primarysite), "*SKIN*")|strmatch(strupper(primarysite), "*FOREARM*")) & topography!=301
replace topcheckcat=46 if regexm(primarysite, "SINUS") & !(strmatch(strupper(primarysite), "*INTRA*")|strmatch(strupper(primarysite), "*PHARYN*")) & (topography<310|topography>319)
replace topcheckcat=47 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==318
replace topcheckcat=48 if (regexm(primarysite, "GLOTT") | regexm(primarysite, "CORD")) & !(strmatch(strupper(primarysite), "*TRANS*")|strmatch(strupper(primarysite), "*CNS*")|strmatch(strupper(primarysite), "*SPINAL*")) & (topography<320|topography>329)
replace topcheckcat=49 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==328
replace topcheckcat=50 if regexm(primarysite, "TRACH") & topography!=339
replace topcheckcat=51 if (regexm(primarysite, "LUNG") | regexm(primarysite, "BRONCH")) & (topography<340|topography>349)
replace topcheckcat=52 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==348
replace topcheckcat=53 if regexm(primarysite, "THYMUS") & topography!=379
replace topcheckcat=54 if (regexm(primarysite, "HEART")|regexm(primarysite, "CARD")|regexm(primarysite, "STINUM")|regexm(primarysite, "PLEURA")) & !(strmatch(strupper(primarysite), "*GASTR*")|strmatch(strupper(primarysite), "*STOMACH*")) & (topography<380|topography>384)
replace topcheckcat=55 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==388
replace topcheckcat=56 if regexm(primarysite, "RESP") & topography!=390
replace topcheckcat=57 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==398
replace topcheckcat=58 if regexm(primarysite, "RESP") & topography!=399
replace topcheckcat=59 if regexm(primarysite, "BONE") & !(strmatch(strupper(primarysite), "*MARROW*")) & (topography<400|topography>419)
replace topcheckcat=60 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==408
replace topcheckcat=61 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==418
replace topcheckcat=62 if regexm(primarysite, "BLOOD") & !(strmatch(strupper(primarysite), "*MARROW*")) & topography!=420
replace topcheckcat=63 if regexm(primarysite, "MARROW") & topography!=421
replace topcheckcat=64 if regexm(primarysite, "SPLEEN") & topography!=422
replace topcheckcat=65 if regexm(primarysite, "RETICU") & topography!=423
replace topcheckcat=66 if regexm(primarysite, "POIETIC") & topography!=424
replace topcheckcat=67 if regexm(primarysite, "SKIN") & (topography<440|topography>449)
replace topcheckcat=68 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==448
replace topcheckcat=69 if regexm(primarysite, "NERV") & (topography<470|topography>479)
replace topcheckcat=70 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==478
replace topcheckcat=71 if regexm(primarysite, "PERITON") & !(strmatch(strupper(primarysite), "*NODE*")) & (topography<480|topography>482)
replace topcheckcat=72 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==488
replace topcheckcat=73 if regexm(primarysite, "TISSUE") & (topography<490|topography>499)
replace topcheckcat=74 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==498
replace topcheckcat=75 if regexm(primarysite, "BREAST") & !(strmatch(strupper(primarysite), "*SKIN*")) & (topography<500|topography>509)
replace topcheckcat=76 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==508
replace topcheckcat=77 if regexm(primarysite, "VULVA") & (topography<510|topography>519)
replace topcheckcat=78 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==518
replace topcheckcat=79 if regexm(primarysite, "VAGINA") & topography!=529
replace topcheckcat=80 if regexm(primarysite, "CERVIX") & (topography<530|topography>539)
replace topcheckcat=81 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==538
replace topcheckcat=82 if (regexm(primarysite, "UTERI")|regexm(primarysite, "METRIUM")) & !(strmatch(strupper(primarysite), "*CERVIX*")|strmatch(strupper(primarysite), "*UTERINE*")|strmatch(strupper(primarysite), "*OVARY*")) & (topography<540|topography>549)
replace topcheckcat=83 if regexm(primarysite, "UTERINE") & !(strmatch(strupper(primarysite), "*CERVIX*")|strmatch(strupper(primarysite), "*CORPUS*")) & topography!=559
replace topcheckcat=84 if regexm(primarysite, "OVARY") & topography!=569
replace topcheckcat=85 if (regexm(primarysite, "FALLOPIAN")|regexm(primarysite, "LIGAMENT")|regexm(primarysite, "ADNEXA")|regexm(primarysite, "FEMALE")) & (topography<570|topography>579)
replace topcheckcat=86 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==578
replace topcheckcat=87 if regexm(primarysite, "PLACENTA") & topography!=589
replace topcheckcat=88 if (regexm(primarysite, "PENIS")|regexm(primarysite, "FORESKIN")) & (topography<600|topography>609)
replace topcheckcat=89 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==608
replace topcheckcat=90 if regexm(primarysite, "PROSTATE") & topography!=619
replace topcheckcat=91 if regexm(primarysite, "TESTIS") & (topography<620|topography>629)
replace topcheckcat=92 if (regexm(primarysite, "EPI")|regexm(primarysite, "SPERM")|regexm(primarysite, "SCROT")|regexm(primarysite, "MALE")) & !(strmatch(strupper(primarysite), "*FEMALE*")) & (topography<630|topography>639)
replace topcheckcat=93 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==638
replace topcheckcat=94 if regexm(primarysite, "KIDNEY") & topography!=649
replace topcheckcat=95 if regexm(primarysite, "RENAL") & topography!=659
replace topcheckcat=96 if regexm(primarysite, "URETER") & !(strmatch(strupper(primarysite), "*BLADDER*")) & topography!=669
replace topcheckcat=97 if regexm(primarysite, "BLADDER") & !(strmatch(strupper(primarysite), "*GALL*")) & (topography<670|topography>679)
replace topcheckcat=98 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==678
replace topcheckcat=99 if (regexm(primarysite, "URETHRA")|regexm(primarysite, "URINARY")) & !(strmatch(strupper(primarysite), "*BLADDER*")) & (topography<680|topography>689)
replace topcheckcat=100 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==688
replace topcheckcat=101 if (regexm(primarysite, "EYE")|regexm(primarysite, "RETINA")|regexm(primarysite, "CORNEA")|regexm(primarysite, "LACRIMAL")|regexm(primarysite, "CILIARY")|regexm(primarysite, "CHOROID")|regexm(primarysite, "ORBIT")|regexm(primarysite, "CONJUNCTIVA")) & !(strmatch(strupper(primarysite), "*SKIN*")) & (topography<690|topography>699)
replace topcheckcat=102 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==698
replace topcheckcat=103 if regexm(primarysite, "MENINGE") & (topography<700|topography>709)
replace topcheckcat=104 if regexm(primarysite, "BRAIN") & !strmatch(strupper(primarysite), "*MENINGE*") & (topography<710|topography>719)
replace topcheckcat=105 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==718
replace topcheckcat=106 if (regexm(primarysite, "SPIN")|regexm(primarysite, "CAUDA")|regexm(primarysite, "NERV")) & (topography<720|topography>729)
replace topcheckcat=107 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==728
replace topcheckcat=108 if regexm(primarysite, "THYROID") & topography!=739
replace topcheckcat=109 if regexm(primarysite, "ADRENAL") & (topography<740|topography>749)
replace topcheckcat=110 if (regexm(primarysite, "PARATHYROID")|regexm(primarysite, "PITUITARY")|regexm(primarysite, "CRANIOPHARYNGEAL")|regexm(primarysite, "CAROTID")|regexm(primarysite, "ENDOCRINE")) & (topography<750|topography>759)
replace topcheckcat=111 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==758
replace topcheckcat=112 if (regexm(primarysite, "NOS")|regexm(primarysite, "DEFINED")) & !(strmatch(strupper(primarysite), "*SKIN*")|strmatch(strupper(primarysite), "*NOSE*")|strmatch(strupper(primarysite), "*NOSTRIL*")|strmatch(strupper(primarysite), "*STOMACH*")|strmatch(strupper(primarysite), "*GENITAL*")|strmatch(strupper(primarysite), "*PENIS*")) & (topography<760|topography>767)
replace topcheckcat=113 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==768
replace topcheckcat=114 if regexm(primarysite, "NODE") & (topography<770|topography>779)
replace topcheckcat=115 if !(strmatch(strupper(primarysite), "*OVERLAP*")) & topography==778
replace topcheckcat=116 if regexm(primarysite, "UNKNOWN") & topography!=809
label var topcheckcat "PrimSite<>Top Check Category"
label define topcheckcat_lab 	1 "Check 1: Lip" 2 "Check 2: Lip-Overlap" 3 "Check 3: Tongue" 4 "Check 4: Tongue-Overlap" 5 "Check 5: Gum" 6 "Check 6: Mouth" ///
								7 "Check 7: Mouth-Overlap" 8 "Check 8: Palate-Overlap" 9 "Check 9: Mouth Other-Overlap" 10 "Check 10: Glands" 11 "Check 11: Glands-Overlap" ///
							   12 "Check 12: Tonsil" 13 "Check 13: Tonsil-Overlap" 14 "Check 14: Oropharynx" 15 "Check 15: Oropharynx-Overlap" 16 "Check 16: Nasopharynx" ///
							   17 "Check 17: Nasopharynx-Overlap" 18 "Check 18: Pyriform Sinus" 19 "Check 19: Hypopharynx" 20 "Check 20: Hypopharynx-Overlap" ///
							   21 "Check 21: Pharynx" 22 "Check 22: Waldeyer" 23 "Check 23: Lip/Orocavity/Pharynx-Overlap" 24 "Check 24: Esophagus" ///
							   25 "Check 25: Esophagus-Overlap" 26 "Check 26: Stomach" 27 "Check 27: Stomach-Overlap" 28 "Check 28: Small Intestine" ///
							   29 "Check 29: Small Intestine-Overlap" 30 "Check 30: Colon" 31 "Check 31: Colon-Overlap" 32 "Check 32: Rectosigmoid" 33 "Check 33: Rectum" ///
							   34 "Check 34: Anus" 35 "Check 35: Rectum/Anus-Overlap" 36 "Check 36: Liver/intrahep.ducts" 37 "Check 37: Gallbladder" ///
							   38 "Check 38: Biliary Tract-Other" 39 "Check 39: Biliary Tract-Overlap" 40 "Check 40: Pancreas" 41 "Check 41: Pancreas-Overlap" ///
							   42 "Check 42: Digestive-Other" 43 "Check 43: Digestive-Overlap" 44 "Check 44: Nasocavity/Ear" 45 "Check 45: Ear" ///
							   46 "Check 46: Accessory Sinuses" 47 "Check 47: Acc. Sinuses-Overlap" 48 "Check 48: Larynx" 49 "Check 49: Larynx-Overlap" ///
							   50 "Check 50: Trachea" 51 "Check 51: Bronchus/Lung" 53 "Check 52: Lung-Overlap" 53 "Check 53: Thymus" 54 "Check 54: Heart/Mediastinum/Pleura" ///
							   55 "Check 55: Heart/Mediastinum/Pleura-Overlap" 56 "Check 56: Resp.System-Other" 57 "Check 57: Resp.System-Overlap" ///
							   58 "Check 58: Resp.System-Ill defined" 59 "Check 59: Bone/Joints/Cartilage-Limbs" 60 "Check 60: Bone Limbs-Overlap" ///
							   61 "Check 61: Bone Other-Overlap" 62 "Check 62: Blood" 63 "Check 63: Bone Marrow" 64 "Check 64: Spleen" ///
							   65 "Check 65: Reticulo. System" 66 "Check 66: Haem. System" 67 "Check 67: Skin" 68 "Check 68: Skin-Overlap" ///
							   69 "Check 69: Peripheral Nerves/ANS" 70 "Check 70: Peri.Nerves/ANS-Overlap" 71 "Check 71: Retro./Peritoneum" ///
							   72 "Check 72: Retro/Peritoneum-Overlap" 73 "Check 73: Connect./Subcutan.Soft Tissues" ///
							   74 "Check 74: Con/Sub/Soft Tissue-Overlap" 75 "Check 75: Breast" 76 "Check 76: Breast-Overlap" 77 "Check 77: Vulva" ///
							   78 "Check 78: Vulva-Overlap" 79 "Check 79: Vagina" 80 "Check 80: Cervix" 81 "Check 81: Cervix-Overlap" ///
							   82 "Check 82: Corpus" 83 "Check 83: Uterus,NOS" 84 "Check 84: Ovary" 85 "Check 85: FGS-Other" ///
							   86 "Check 86: FGS-Overlap" 87 "Check 87: Placenta" 88 "Check 88: Penis" 89 "Check 89: Penis-Overlap" ///
							   90 "Check 90: Prostate Gland" 91 "Check 91: Testis" 92 "Check 92: MSG-Other" 93 "Check 93: MGS-Overlap" ///
							   94 "Check 94: Kidney" 95 "Check 95: Renal Pelvis" 96 "Check 96: Ureter" 97 "Check 97: Bladder" ///
							   98 "Check 98: Bladder-Overlap" 99 "Check 99: Urinary-Other" 100 "Check 100: Urinary-Overlap" 101 "Check 101: Eye" ///
							   102 "Check 102: Eye-Overlap" 103 "Check 103: Meninges" 104 "Check 104: Brain" 105 "Check 105: Brain-Overlap" ///
							   106 "Check 106: Spinal Cord/CNS" 107 "Check 107: Brain/CNS-Overlap" 108 "Check 108: Thyroid" ///
							   109 "Check 109: Adrenal Gland" 110 "Check 110: Endocrine-Other" 111 "Check 111: Endocrine-Overalp" ///
							   112 "Check 112: Other/Ill defined" 113 "Check 113: Ill-defined-Overlap" 114 "Check 114: LNs" ///
							   115 "Check 115: LNs-Overlap" 116 "Check 116: PSU" ,modify
label values topcheckcat topcheckcat_lab

** Create category for morphology according to groupings in ICD-O-3 book
gen morphcat=. //5150 01mar18
replace morphcat=1 if morph>7999 & morph<8006
replace morphcat=2 if morph>8009 & morph<8050
replace morphcat=3 if morph>8049 & morph<8090
replace morphcat=4 if morph>8089 & morph<8120
replace morphcat=5 if morph>8119 & morph<8140
replace morphcat=6 if morph>8139 & morph<8390
replace morphcat=7 if morph>8389 & morph<8430
replace morphcat=8 if morph>8429 & morph<8440
replace morphcat=9 if morph>8439 & morph<8500
replace morphcat=10 if morph>8499 & morph<8550
replace morphcat=11 if morph>8549 & morph<8560
replace morphcat=12 if morph>8559 & morph<8580
replace morphcat=13 if morph>8579 & morph<8590
replace morphcat=14 if morph>8589 & morph<8680
replace morphcat=15 if morph>8679 & morph<8720
replace morphcat=16 if morph>8719 & morph<8800
replace morphcat=17 if morph>8799 & morph<8810
replace morphcat=18 if morph>8809 & morph<8840
replace morphcat=19 if morph>8839 & morph<8850
replace morphcat=20 if morph>8849 & morph<8890
replace morphcat=21 if morph>8889 & morph<8930
replace morphcat=22 if morph>8929 & morph<9000
replace morphcat=23 if morph>8999 & morph<9040
replace morphcat=24 if morph>9039 & morph<9050
replace morphcat=25 if morph>9049 & morph<9060
replace morphcat=26 if morph>9059 & morph<9100
replace morphcat=27 if morph>9099 & morph<9110
replace morphcat=28 if morph>9109 & morph<9120
replace morphcat=29 if morph>9119 & morph<9170
replace morphcat=30 if morph>9169 & morph<9180
replace morphcat=31 if morph>9179 & morph<9250
replace morphcat=32 if morph>9249 & morph<9260
replace morphcat=33 if morph>9259 & morph<9270
replace morphcat=34 if morph>9269 & morph<9350
replace morphcat=35 if morph>9349 & morph<9380
replace morphcat=36 if morph>9379 & morph<9490
replace morphcat=37 if morph>9489 & morph<9530
replace morphcat=38 if morph>9529 & morph<9540
replace morphcat=39 if morph>9539 & morph<9580
replace morphcat=40 if morph>9579 & morph<9590
replace morphcat=41 if morph>9589 & morph<9650
replace morphcat=42 if morph>9649 & morph<9670
replace morphcat=43 if morph>9669 & morph<9700
replace morphcat=44 if morph>9699 & morph<9727
replace morphcat=45 if morph>9726 & morph<9731
replace morphcat=46 if morph>9730 & morph<9740
replace morphcat=47 if morph>9739 & morph<9750
replace morphcat=48 if morph>9749 & morph<9760
replace morphcat=49 if morph>9759 & morph<9800
replace morphcat=50 if morph>9799 & morph<9820
replace morphcat=51 if morph>9819 & morph<9840
replace morphcat=52 if morph>9839 & morph<9940
replace morphcat=53 if morph>9939 & morph<9950
replace morphcat=54 if morph>9949 & morph<9970
replace morphcat=55 if morph>9969 & morph<9980
replace morphcat=56 if morph>9979 & morph<9999
label var morphcat "Morphology Category"
label define morphcat_lab 1 "Neoplasms,NOS" 2 "Epithelial Neo.,NOS" 3 "Squamous C. Neo." 4 "Basal C. Neo." 5 "Transitional C. Ca" 6 "Adenoca." 7 "Adnex./Skin Appendage Neoplasms" ///
						  8 "Mucoepidermoid Neo." 9 "Cystic/Mucinous/Serous Neo." 10 "Ductal/Lobular Neo." 11 "Acinar C. Neo." 12 "Complex Epithelial Neo." ///
						  13 "Thymic Epithelial Neo." 14 "Specialized Gonadal Neo." 15 "Paragangliomas/Glomus Tum." 16 "Nevi/Melanomas" 17 "Soft Tissue Tum./Sar.,NOS" ///
						  18 "Fibromatous Neo." 19 "Myxomatous Neo." 20 "Lipmatous Neo." 21 "Myomatous Neo." 22 "Complex Mixed/Stromal Neo." 23 "Fibroepithelial Neo." ///
						  24 "Synovial-like Neo." 25 "Mesothelial Neo." 26 "Germ C. Neo." 27 "Trophoblastic Neo." 28 "Mesonephromas" 29 "Blood Vessel Tum." ///
						  30 "Lymphatic Vessel Tum." 31 "Osseous/Chondromatous Neo." 32 "Giant C. Tum." 33 "Misc. Bone Tum." 34 "Odontogenic Tum." 35 "Misc. Tum." ///
						  36 "Gliomas" 37 "Neuroepitheliomatous Neo." 38 "Meningiomas" 39 "Nerve Sheath Tum." 40 "Granular C. Tum/Alveolar Soft Part Sar." ///
						  41 "Malig. Lymphomas,NOS/Diffuse/Non-Hodgkin Lym." 42 "Hodgkin Lymph." 43 "Mature B-C. Lymph." 44 "Mature T/NK-C. Lymph." ///
						  45 "Precursor C. Lymphoblastic Lymph." 46 "Plasma C. Tum." 47 "Mast C. Tum." 48 "Neo.-Histiocytes/Accessory Lymph. C." 49 "Immunoproliferative Dis." ///
						  50 "Leukemias" 51 "Lymphoid Leukemias" 52 "Myeloid Leukemias" 53 "Leukemias-Other" 54 "Chronic Myeloproliferative Dis." 55 "Heme. Dis.-Other" ///
						  56 "Myelodysplastic Syndromes" ,modify
label values morphcat morphcat_lab

** Create category for histology/morphology check
gen morphcheckcat=.
replace morphcheckcat=1 if (regexm(hx, "UNDIFF")&regexm(hx, "CARCIN")) & morph!=8020
replace morphcheckcat=2 if !strmatch(strupper(hx), "*DIFF*") & morph==8020
replace morphcheckcat=3 if regexm(hx, "PAPIL") & (!strmatch(strupper(hx), "*ADENO*")&!strmatch(strupper(hx), "*SEROUS*")&!strmatch(strupper(hx), "*HURTHLE*")&!strmatch(strupper(hx), "*RENAL*")&!strmatch(strupper(hx), "*UROTHE*")&!strmatch(strupper(hx), "*FOLLIC*")) & morph!=8050
replace morphcheckcat=4 if regexm(hx, "PAPILLARY SEROUS") & (topcat!=49 & topcat!=41) & morph!=8460
replace morphcheckcat=5 if (regexm(hx, "PAPIL")&regexm(hx, "INTRA")) & morph!=8503
replace morphcheckcat=6 if regexm(hx, "KERATO") & morph!=8070
replace morphcheckcat=7 if (regexm(hx, "SQUAMOUS")&regexm(hx, "MICROINVAS")) & morph!=8076
replace morphcheckcat=8 if regexm(hx, "BOWEN") & !strmatch(strupper(hx), "*CLINICAL*") & (basis==6|basis==7|basis==8) & morph!=8081
replace morphcheckcat=9 if (regexm(hx, "ADENOID")&regexm(hx, "BASAL")) & morph!=8098
replace morphcheckcat=10 if (regexm(hx, "INFIL")&regexm(hx, "BASAL")) & !strmatch(strupper(hx), "*NODU*") & morph!=8092
replace morphcheckcat=11 if (regexm(hx, "SUPER")&regexm(hx, "BASAL")) & !strmatch(strupper(hx), "*NODU*") & (basis==6|basis==7|basis==8) & morph!=8091
replace morphcheckcat=12 if (regexm(hx, "SCLER")&regexm(hx, "BASAL")) & !strmatch(strupper(hx), "*NODU*") & morph!=8092
replace morphcheckcat=13 if (regexm(hx, "NODU")&regexm(hx, "BASAL")) & !strmatch(strupper(hx), "*CLINICAL*") & morph!=8097
replace morphcheckcat=14 if regexm(hx, "BASAL") & !strmatch(strupper(hx), "*NODU*") & morph==8097
replace morphcheckcat=15 if (regexm(hx, "SQUA")&regexm(hx, "BASAL")) & !strmatch(strupper(hx), "*BASALOID*") & morph!=8094
replace morphcheckcat=16 if regexm(hx, "BASAL") & !strmatch(strupper(hx), "*SQUA*") & morph==8094
replace morphcheckcat=17 if (!strmatch(strupper(hx), "*TRANS*")&!strmatch(strupper(hx), "*UROTHE*")) & morph==8120
replace morphcheckcat=18 if (regexm(hx, "TRANSITION")|regexm(hx, "UROTHE")) & !strmatch(strupper(hx), "*PAPIL*") & morph!=8120
replace morphcheckcat=19 if (regexm(hx, "TRANS")|regexm(hx, "UROTHE")) & regexm(hx, "PAPIL") & morph!=8130
replace morphcheckcat=20 if (regexm(hx, "VILL")&regexm(hx, "ADENOM")) & !strmatch(strupper(hx), "*TUBUL*") & morph!=8261
replace morphcheckcat=21 if regexm(hx, "INTESTINAL") & !strmatch(strupper(hx), "*STROMA*") & morph!=8144
replace morphcheckcat=22 if regexm(hx, "VILLOGLANDULAR") & morph!=8263
replace morphcheckcat=23 if !strmatch(strupper(hx), "*CLEAR*") & morph==8310
replace morphcheckcat=24 if regexm(hx, "CLEAR") & !strmatch(strupper(hx), "*RENAL*") & morph!=8310
replace morphcheckcat=25 if (regexm(hx, "CYST")&regexm(hx, "RENAL")) & morph!=8316
replace morphcheckcat=26 if (regexm(hx, "CHROMO")&regexm(hx, "RENAL")) & morph!=8317
replace morphcheckcat=27 if (regexm(hx, "SARCO")&regexm(hx, "RENAL")) & morph!=8318
replace morphcheckcat=28 if regexm(hx, "FOLLIC") & (!strmatch(strupper(hx), "*MINIMAL*")&!strmatch(strupper(hx), "*PAPIL*")) & morph!=8330
replace morphcheckcat=29 if (regexm(hx, "FOLLIC")&regexm(hx, "MINIMAL")) & morph!=8335
replace morphcheckcat=30 if regexm(hx, "MICROCARCINOMA") & morph!=8341
replace morphcheckcat=31 if (!strmatch(strupper(hx), "*OID*")&!strmatch(strupper(hx), "*IOD*")) & morph==8380
replace morphcheckcat=32 if regexm(hx, "POROMA") & morph!=8409 & mptot<2
replace morphcheckcat=33 if regexm(hx, "SEROUS") & !strmatch(strupper(hx), "*PAPIL*") & morph!=8441
replace morphcheckcat=34 if regexm(hx, "MUCIN") & (!strmatch(strupper(hx), "*CERVI*")&!strmatch(strupper(hx), "*PROD*")&!strmatch(strupper(hx), "*SECRE*")&!strmatch(strupper(hx), "*DUCT*")) & morph!=8480
replace morphcheckcat=35 if (!strmatch(strupper(hx), "*MUCIN*")&!strmatch(strupper(hx), "*PERITONEI*")) & morph==8480
replace morphcheckcat=36 if (regexm(hx, "ACIN")&regexm(hx, "DUCT")) & morph!=8552
replace morphcheckcat=37 if ((regexm(hx, "INTRADUCT")&regexm(hx, "MICROPAP")) | (regexm(hx, "INTRADUCT")&regexm(hx, "CLING"))) & morph!=8507
replace morphcheckcat=38 if (!strmatch(strupper(hx), "*MICROPAP*")|!strmatch(strupper(hx), "*CLING*")) & morph==8507
replace morphcheckcat=39 if !strmatch(strupper(hx), "*DUCTULAR*") & morph==8521
replace morphcheckcat=40 if regexm(hx, "LOBUL") & !strmatch(strupper(hx), "*DUCT*") & morph!=8520
replace morphcheckcat=41 if (regexm(hx, "DUCT")&regexm(hx, "LOB")) & morph!=8522
replace morphcheckcat=42 if !strmatch(strupper(hx), "*ACIN*") & morph==8550
replace morphcheckcat=43 if !strmatch(strupper(hx), "*ADENOSQUA*") & morph==8560
replace morphcheckcat=44 if !strmatch(strupper(hx), "*THECOMA*") & morph==8600
replace morphcheckcat=45 if !strmatch(strupper(hx), "*SARCOMA*") & morph==8800
replace morphcheckcat=46 if (regexm(hx, "SPIN")&regexm(hx, "SARCOMA")) & morph!=8801
replace morphcheckcat=47 if (regexm(hx, "UNDIFF")&regexm(hx, "SARCOMA")) & morph!=8805
replace morphcheckcat=48 if regexm(hx, "FIBROSARCOMA") & (!strmatch(strupper(hx), "*MYXO*")&!strmatch(strupper(hx), "*DERMA*")&!strmatch(strupper(hx), "*MESOTHE*")) & morph!=8810
replace morphcheckcat=49 if (regexm(hx, "FIBROSARCOMA")&regexm(hx, "MYXO")) & morph!=8811
replace morphcheckcat=50 if (regexm(hx, "FIBRO")&regexm(hx, "HISTIOCYTOMA")) & morph!=8830
replace morphcheckcat=51 if (!strmatch(strupper(hx), "*DERMA*")&!strmatch(strupper(hx), "*FIBRO*")&!strmatch(strupper(hx), "*SARCOMA*")) & morph==8832
replace morphcheckcat=52 if (regexm(hx, "STROMAL")&regexm(hx, "SARCOMA")&regexm(hx, "HIGH")) & morph!=8930
replace morphcheckcat=53 if (regexm(hx, "STROMAL")&regexm(hx, "SARCOMA")&regexm(hx, "LOW")) & morph!=8931
replace morphcheckcat=54 if (regexm(hx, "GASTRO")&regexm(hx, "STROMAL")|regexm(hx, "GIST")) & morph!=8936
replace morphcheckcat=55 if (regexm(hx, "MIXED")&regexm(hx, "MULLER")) & !strmatch(strupper(hx), "*MESO*") & morph!=8950
replace morphcheckcat=56 if (regexm(hx, "MIXED")&regexm(hx, "MESO")) & morph!=8951
replace morphcheckcat=57 if (regexm(hx, "WILM")|regexm(hx, "NEPHR")) & morph!=8960
replace morphcheckcat=58 if regexm(hx, "MESOTHE") & (!strmatch(strupper(hx), "*FIBR*")&!strmatch(strupper(hx), "*SARC*")&!strmatch(strupper(hx), "*EPITHE*")&!strmatch(strupper(hx), "*PAPIL*")&!strmatch(strupper(hx), "*CYST*")) & morph!=9050
replace morphcheckcat=59 if (regexm(hx, "MESOTHE")&regexm(hx, "FIBR")|regexm(hx, "MESOTHE")&regexm(hx, "SARC")) & (!strmatch(strupper(hx), "*EPITHE*")&!strmatch(strupper(hx), "*PAPIL*")&!strmatch(strupper(hx), "*CYST*")) & morph!=9051
replace morphcheckcat=60 if (regexm(hx, "MESOTHE")&regexm(hx, "EPITHE")|regexm(hx, "MESOTHE")&regexm(hx, "PAPIL")) & (!strmatch(strupper(hx), "*FIBR*")&!strmatch(strupper(hx), "*SARC*")&!strmatch(strupper(hx), "*CYST*")) & morph!=9052
replace morphcheckcat=61 if (regexm(hx, "MESOTHE")&regexm(hx, "BIPHAS")) & morph!=9053
replace morphcheckcat=62 if regexm(hx, "ADENOMATOID") & morph!=9054
replace morphcheckcat=63 if (regexm(hx, "MESOTHE")&regexm(hx, "CYST")) & morph!=9055
replace morphcheckcat=64 if regexm(hx, "YOLK") & morph!=9071
replace morphcheckcat=65 if regexm(hx, "TERATOMA") & morph!=9080
replace morphcheckcat=66 if regexm(hx, "TERATOMA") & (!strmatch(strupper(hx), "*METAS*")&!strmatch(strupper(hx), "*MALIG*")&!strmatch(strupper(hx), "*EMBRY*")&!strmatch(strupper(hx), "*BLAST*")&!strmatch(strupper(hx), "*IMMAT*")) & morph==9080
replace morphcheckcat=67 if regexm(hx, "MOLE") & !strmatch(strupper(hx), "*CHORIO*") & beh==3 & morph==9100
replace morphcheckcat=68 if regexm(hx, "CHORIO") & morph!=9100
replace morphcheckcat=69 if (regexm(hx, "EPITHE")&regexm(hx, "HEMANGIOENDOTHELIOMA")) & !strmatch(strupper(hx), "*MALIG*") & morph==9133
replace morphcheckcat=70 if regexm(hx, "OSTEOSARC") & morph!=9180
replace morphcheckcat=71 if regexm(hx, "CHONDROSARC") & morph!=9220
replace morphcheckcat=72 if regexm(hx, "MYXOID") & !strmatch(strupper(hx), "*CHONDROSARC*") & morph==9231
replace morphcheckcat=73 if regexm(hx, "RETINOBLASTOMA") & (regexm(hx, "POORLY")|regexm(hx, "UNDIFF")) & morph==9511
replace morphcheckcat=74 if regexm(hx, "MENINGIOMA") & (!strmatch(strupper(hx), "*THELI*")&!strmatch(strupper(hx), "*SYN*")) & morph==9531
replace morphcheckcat=75 if (regexm(hx, "MANTLE")&regexm(hx, "LYMPH")) & morph!=9673
replace morphcheckcat=76 if (regexm(hx, "T CELL")&regexm(hx, "LYMPH")|regexm(hx, "T-CELL")&regexm(hx, "LYMPH")) & (!strmatch(strupper(hx), "*LEU*")&!strmatch(strupper(hx), "*HTLV*")&!strmatch(strupper(hx), "*CUTANE*")) & morph!=9702
replace morphcheckcat=77 if (regexm(hx, "NON")&regexm(hx, "HODGKIN")&regexm(hx, "LYMPH")) & !strmatch(strupper(hx), "*CELL*") & morph!=9591
replace morphcheckcat=78 if (regexm(hx, "PRE")&regexm(hx, "T CELL")&regexm(hx, "LYMPH")&regexm(hx, "LEU")|regexm(hx, "PRE")&regexm(hx, "T-CELL")&regexm(hx, "LYMPH")&regexm(hx, "LEU")) & morph!=9837
replace morphcheckcat=79 if (hx=="CHRONIC MYELOGENOUS LEUKAEMIA"|hx=="CHRONIC MYELOGENOUS LEUKEMIA"|hx=="CHRONIC MYELOID LEUKAEMIA"|hx=="CHRONIC MYELOID LEUKEMIA"|hx=="CML") & morph!=9863
replace morphcheckcat=80 if (regexm(hx, "CHRON")&regexm(hx, "MYELO")&regexm(hx, "LEU")) & (!strmatch(strupper(hx), "*BCR*")|!strmatch(strupper(hx), "*ABL1*")) & morph==9875
replace morphcheckcat=81 if (regexm(hx, "ACUTE")&regexm(hx, "MYELOID")&regexm(hx, "LEU")) & (!strmatch(strupper(hx), "*DYSPLAST*")&!strmatch(strupper(hx), "*DOWN*")) & (basis>4&basis<9) & morph!=9861
replace morphcheckcat=82 if (regexm(hx, "DOWN")&regexm(hx, "MYELOID")&regexm(hx, "LEU")) & morph!=9898
replace morphcheckcat=83 if (regexm(hx, "SECOND")&regexm(hx, "MYELOFIBR")) & recstatus!=3 & (morph==9931|morph==9961)
replace morphcheckcat=84 if regexm(hx, "POLYCYTHEMIA") & (!strmatch(strupper(hx), "*VERA*")&!strmatch(strupper(hx), "*PROLIF*")&!strmatch(strupper(hx), "*PRIMARY*")) & morph==9950
replace morphcheckcat=85 if regexm(hx, "MYELOPROLIFERATIVE") & !strmatch(strupper(hx), "*ESSENTIAL*") & dxyr<2010 & morph==9975
replace morphcheckcat=86 if regexm(hx, "MYELOPROLIFERATIVE") & !strmatch(strupper(hx), "*ESSENTIAL*") & dxyr>2009 & morph==9960
replace morphcheckcat=87 if (regexm(hx, "REFRACTORY")&regexm(hx, "AN")) & (!strmatch(strupper(hx), "*SIDERO*")&!strmatch(strupper(hx), "*BLAST*")) & morph!=9980
replace morphcheckcat=88 if (regexm(hx, "REFRACTORY")&regexm(hx, "AN")&regexm(hx, "SIDERO")) & !strmatch(strupper(hx), "*EXCESS*") & morph!=9982
replace morphcheckcat=89 if (regexm(hx, "REFRACTORY")&regexm(hx, "AN")&regexm(hx, "EXCESS")) & !strmatch(strupper(hx), "*SIDERO*") & morph!=9983
replace morphcheckcat=90 if regexm(hx, "MYELODYSPLASIA") & !strmatch(strupper(hx), "*SYNDROME*") & recstatus!=3 & morph==9989
replace morphcheckcat=91 if regexm(hx, "ACIN") & topography!=619 & morph!=8550
replace morphcheckcat=92 if (!strmatch(strupper(hx), "*FIBRO*")|!strmatch(strupper(hx), "*HISTIOCYTOMA*")) & morph==8830
replace morphcheckcat=93 if regexm(hx, "ACIN") & topography==619 & morph!=8140
replace morphcheckcat=94 if (morph>9582 & morph<9650) & !strmatch(strupper(hx), "*NON*") & regexm(hx, "HODGKIN")
replace morphcheckcat=95 if morph==9729 & regexm(hx,"LEU")
replace morphcheckcat=96 if morph==9837 & regexm(hx,"OMA")

label var morphcheckcat "Hx<>Morph Check Category"
label define morphcheckcat_lab 	1 "Check 1: Hx=Undifferentiated Ca & Morph!=8020" 2 "Check 2: Hx!=Undifferentiated Ca & Morph==8020" 3 "Check 3: Hx=Papillary ca & Morph!=8050" ///
								4 "Check 4: Hx=Papillary serous adenoca & Morph!=8460" 5 "Check 5: Hx=Papillary & intraduct/intracyst & Morph!=8503" ///
								6 "Check 6: Hx=Keratoacanthoma & Morph!=8070" 7 "Check 7: Hx=Squamous & microinvasive & Morph!=8076" ///
								8 "Check 8: Hx=Bowen & morph!=8081" 9 "Check 9: Hx=adenoid BCC & morph!=8098" 10 "Check 10: Hx=infiltrating BCC excluding nodular & morph!=8092" ///
								11 "Check 11: Hx=superficial BCC excluding nodular & basis=6/7/8 & morph!=8091" 12 "Check 12: Hx=sclerotic/sclerosing BCC excluding nodular & morph!=8091" ///
								13 "Check 13: Hx=nodular BCC excluding clinical & morph!=8097" 14 "Check 14: Hx!=nodular BCC & morph==8097" ///
								15 "Check 15: Hx=BCC & SCC excluding basaloid & morph!=8094" 16 "Check 16: Hx!=BCC & SCC & morph==8094" 17 "Check 17: Hx!=transitional/urothelial & morph==8120" ///
								18 "Check 18: Hx=transitional/urothelial excluding papillary & morph!=8120" 19 "Check 19: Hx=transitional/urothelial & papillary & morph!=8130" ///
								20 "Check 20: Hx=villous & adenoma excl. tubulo & morph!=8261" 21 "Check 21: Hx=intestinal excl. stromal(GISTs) & morph!=8144" ///
								22 "Check 22: Hx=villoglandular & morph!=8263" 23 "Check 23: Hx!=clear cell & morph==8310" 24 "Check 24: Hx==clear cell & morph!=8310" ///
								25 "Check 25: Hx==cyst & renal & morph!=8316" 26 "Check 26: Hx==chromophobe & renal & morph!=8317" ///
								27 "Check 27: Hx==sarcomatoid & renal & morph!=8318" 28 "Check 28: Hx==follicular excl.minimally invasive & morph!=8330" ///
								29 "Check 29: Hx==follicular & minimally invasive & morph!=8335" 30 "Check 30: Hx==microcarcinoma & morph!=8341" ///
								31 "Check 31: Hx!=endometrioid & morph==8380" 32 "Check 32: Hx==poroma & morph!=8409 & mptot<2" ///
								33 "Check 33: Hx==serous excl. papillary & morph!=8441" 34 "Check 34: Hx=mucinous excl. endocervical,producing,secreting,infil.duct & morph!=8480" ///
								35 "Check 35: Hx!=mucinous & morph==8480" 36 "Check 36: Hx==acinar & duct & morph!=8552" ///
								37 "Check 37: Hx==intraduct & micropapillary or intraduct & clinging & morph!=8507" ///
								38 "Check 28: Hx!=intraduct & micropapillary or intraduct & clinging & morph==8507" 39 "Check 39: Hx!=ductular & morph==8521" ///
								40 "Check 40: Hx!=duct & Hx==lobular & morph!=8520" 41 "Check 41: Hx==duct & lobular & morph!=8522" ///
								42 "Check 42: Hx!=acinar & morph==8550" 43 "Check 43: Hx!=adenosquamous & morph==8560" 44 "Check 44: Hx!=thecoma & morph==8600" ///
								45 "Check 45: Hx!=sarcoma & morph==8800" 46 "Check 46: Hx=spindle & sarcoma & morph!=8801" ///
								47 "Check 47: Hx=undifferentiated & sarcoma & morph!=8805" 48 "Check 48: Hx=fibrosarcoma & Hx!=myxo or dermato & morph!=8810" ///
								49 "Check 49: Hx=fibrosarcoma & Hx=myxo & morph!=8811" 50 "Check 50: Hx=fibro & histiocytoma & morph!=8830" ///
								51 "Check 51: Hx!=dermatofibrosarcoma & morph==8832" 52 "Check 52: Hx==stromal sarcoma high grade & morph!=8930" ///
								53 "Check 53: Hx==stromal sarcoma low grade & morph!=8931" 54 "Check 54: Hx==gastrointestinal stromal tumour & morph!=8936" ///
								55 "Check 55: Hx==mixed mullerian tumour & Hx!=mesodermal & morph!=8950" 56 "Check 56: Hx==mesodermal mixed & morph!=8951" ///
								57 "Check 57: Hx==wilms or nephro & morph!=8960" ///
								58 "Check 58: Hx==mesothelioma & Hx!=fibrous or sarcoma or epithelioid/papillary or cystic & morph!=9050" ///
								59 "Check 59: Hx==fibrous or sarcomatoid mesothelioma & Hx!=epithelioid/papillary or cystic & morph!=9051" ///
								60 "Check 60: Hx==epitheliaoid or papillary mesothelioma & Hx!=fibrous or sarcomatoid or cystic & morph!=9052" ///
								61 "Check 61: Hx==biphasic mesothelioma & morph!=9053" 62 "Check 62: Hx==adenomatoid tumour & morph!=9054" ///
								63 "Check 63: Hx==cystic mesothelioma & morph!=9055" 64 "Check 64: Hx==yolk & morph!=9071" 65 "Check 65: Hx==teratoma & morph!=9080" ///
								66 "Check 66: Hx==teratoma & Hx!=metastatic or malignant or embryonal or teratoblastoma or immature & morph==9080" ///
								67 "Check 67: Hx==complete hydatidiform mole & Hx!=choriocarcinoma & beh==3 & morph==9100" ///
								68 "Check 68: Hx==choriocarcinoma & morph!=9100" 69 "Check 69: Hx==epithelioid hemangioendothelioma & Hx!=malignant & morph==9133" ///
								70 "Check 70: Hx==osteosarcoma & morph!=9180" 71 "Check 71: Hx==chondrosarcoma & morph!=9220" ///
								72 "Check 72: Hx=myxoid and Hx!=chondrosarcoma & morph==9231" ///
								73 "Check 73: Hx=retinoblastoma and poorly or undifferentiated & morph==9511" ///
								74 "Check 74: Hx=meningioma & Hx!=meningothelial/endotheliomatous/syncytial & morph==9531" ///
								75 "Check 75: Hx=mantle cell lymphoma & morph!=9673" 76 "Check 76: Hx=T-cell lymphoma & Hx!=leukemia & morph!=9702" ///
								77 "Check 77: Hx=non-hodgkin lymphoma & Hx!=cell & morph!=9591" 78 "Check 78: Hx=precursor t-cell ALL & morph!=9837" ///
								79 "Check 79: Hx=CML (chronic myeloid/myelogenous leukemia) & Hx!=genetic studies & morph==9863" ///
								80 "Check 80: Hx=CML (chronic myeloid/myelogenous leukemia) & Hx!=BCR/ABL1 & morph==9875" ///
								81 "Check 81: Hx=acute myeloid leukemia & Hx!=myelodysplastic/down syndrome & basis==cyto/heme/histology... & morph!=9861" ///
								82 "Check 82: Hx=acute myeloid leukemia & down syndrome & morph!=9898" ///
								83 "Check 83: Hx=secondary myelofibrosis & recstatus!=3 & morph==9931 or 9961" ///
								84 "Check 84: Hx=polycythemia & Hx!=vera/proliferative/primary & morph==9950" ///
								85 "Check 85: Hx=myeloproliferative & Hx!=essential & dxyr<2010 & morph==9975" ///
								86 "Check 86: Hx=myeloproliferative & Hx!=essential & dxyr>2009 & morph==9960" ///
								87 "Check 87: Hx=refractory anemia & Hx!=sideroblast or blast & morph!=9980" ///
								88 "Check 88: Hx=refractory anemia & sideroblast & Hx!=excess blasts & morph!=9982" ///
								89 "Check 89: Hx=refractory anemia & excess blasts &  Hx!=sidero & morph!=9983" ///
								90 "Check 90: Hx=myelodysplasia & Hx!=syndrome & recstatus!=inelig. & morph==9989" 91 "Check 91: Hx=acinar & morph!=8550" ///
								92 "Check 92: Hx!=fibro & histiocytoma & morph=8830" 93 "Check 93: Hx=acinar & top=prostate & morph!=8140" ///
								94 "Check 94: Hx=hodgkin & morph=non-hodgkin" 95 "Check 95: Hx=leukaemia & morph=9729" 96 "Check 96: Hx=lymphoma & morph=9837" ,modify
label values morphcheckcat morphcheckcat_lab

** Create category for histology/primarysite check
gen hxcheckcat=.
replace hxcheckcat=1 if topcat==38 & (morphcat>40 & morphcat<46)
replace hxcheckcat=2 if topcat==33 & morphcat!=13 & !strmatch(strupper(hx), "*CARCINOMA*")
replace hxcheckcat=3 if topography!=421 & morphcat==56
replace hxcheckcat=4 if (regexm(hx, "PAPIL")&regexm(hx, "RENAL")) & topography!=739 & morph!=8260
replace hxcheckcat=5 if (regexm(hx, "PAPIL")&regexm(hx, "ADENO")) & !strmatch(strupper(hx), "*RENAL*") & topography==739 & morph!=8260
replace hxcheckcat=6 if (regexm(hx, "PAPILLARY")&regexm(hx, "SEROUS")) & (topcat==41|topcat==49) & morph!=8461
replace hxcheckcat=7 if (regexm(hx, "PAPILLARY")&regexm(hx, "SEROUS")) & topography==541 & morph!=8460
replace hxcheckcat=8 if regexm(hx, "PLASMA") & (topcat!=36&topcat!=37) & morph==9731
replace hxcheckcat=9 if regexm(hx, "PLASMA") & (topcat==36|topcat==37) & morph==9734
replace hxcheckcat=10 if topcat!=62 & morphcat==38
replace hxcheckcat=11 if topcat==38 & morph==9827
label var hxcheckcat "Hx<>PrimSite Check Category"
label define hxcheckcat_lab	1 "Check 1: PrimSite=Blood/Bone Marrow & Hx=Lymphoma" 2 "Check 2: PrimSite=Thymus & MorphCat!=Thymic epi.neo. & Hx!=carcinoma" ///
							3 "Check 3: PrimSite!=Bone Marrow & MorphCat==Myelodys." 4 "Check 4: PrimSite!=thyroid & Hx=Renal & Hx=Papillary ca & Morph!=8260" ///
							5 "Check 5: PrimSite==thyroid & Hx!=Renal & Hx=Papillary ca & adenoca & Morph!=8260" 6 "Check 6: PrimSite!=ovary/peritoneum & Hx=Papillary & Serous & Morph!=8461" ///
							7 "Check 7: PrimSite!=endometrium & Hx=Papillary & Serous & Morph!=8460" 8 "Check 8: PrimSite!=bone; Hx=plasmacytoma & Morph==9731(bone)" ///
							9 "Check 9: PrimSite==bone; Hx=plasmacytoma & Morph==9734(not bone)" 10 "Check 10: PrimSite!=meninges; Hx=meningioma" ///
							11 "Check 11: PrimSite=Blood/Bone Marrow & Hx=HTLV+T-cell Lymphoma" ,modify
label values hxcheckcat hxcheckcat_lab

** Create category for age/site/histology check: IARCcrgTools pg 6
gen agecheckcat=.
replace agecheckcat=1 if morphcat==42 & age<3
replace agecheckcat=2 if (morph==9490|morph==9500|morph==9522) & (age>9 & age<15)
replace agecheckcat=3 if (morph>9509 & morph<9515) & (age>5 & age<15)
replace agecheckcat=4 if (morph==8959|morph==8960) & (age>8 & age<15)
replace agecheckcat=5 if ((morph==8260 | morph==8361 | morph==8312 | morph>8315 & morph<8320) & age<9) | (topcat==56 & (morphcat!=4 & morphcat>1 & morphcat<13) & age<9)
replace agecheckcat=6 if morph==8970 & (age>5 & age<15)
replace agecheckcat=7 if ((morph>8159 & morph<8181) & age<9) | (topcat==23 & morph & (morphcat!=4 & morphcat>1 & morphcat<13) & age<9)
replace agecheckcat=8 if (morph>9179 & morph<9201) & (topcat==36|topcat==37|topcat==68|topcat==70) & age<6
replace agecheckcat=9 if ((morph>9220 & morph<9244) & age<6) | ((morph==9210|morph==9220|morph==9240) & (topcat==36|topcat==37|topcat==68|topcat==70) & age<6)
replace agecheckcat=10 if morph==9260 & age<4
replace agecheckcat=11 if (morphcat==26 | morphcat==27) & (topcat!=49 & topcat!=54) & (age>7 & age<15)
replace agecheckcat=12 if ((morph>8440 & morph<8445 | morph>8449 & morph<8452 | morph>8459 & morph<8474) & age<5) | ((topcat==54|topcat==55) & (morphcat!=4 & morphcat==23 & morphcat>1 & morphcat<13) & age<5)
replace agecheckcat=13 if ((morph>8329 & morph<8338 | morph>8339 & morph<8348 | morph==8350) & age<6) | (topcat==65 & (morphcat!=4 & morphcat>1 & morphcat<13) & age<6)
replace agecheckcat=14 if topcat==12 & (morphcat!=4 & morphcat>1 & morphcat<13) & age<6
replace agecheckcat=15 if topcat==39 & (morphcat>1 & morphcat<13 |morph==8940|morph==8941) & age<5
replace agecheckcat=16 if (morphcat==1|morphcat==2) & (topcat!=23 & topcat!=36 & topcat!=37 & topcat!=49 & topcat!=54 & topcat!=56 & topcat!=62 & topcat>64) & age<5
replace agecheckcat=17 if morphcat==25 & age<15
replace agecheckcat=18 if topcat==53 & morphcat==6 & age<40
replace agecheckcat=19 if ((topcat==16 | topcat>19 & topcat<23 | topcat==24 | topcat==25 | topcat==43 | topcat>45 & topcat<49) & age<20)  | (topography==384 & age<20)
replace agecheckcat=20 if topcat==18 & morph<9590 & age<20
replace agecheckcat=21 if (topcat==19 | topcat==31 | topcat==32) & (morph<8240 & morph>8249) & age<20
replace agecheckcat=22 if topcat==51 & morph==9100 & age>45
replace agecheckcat=23 if (morph==9732|morph==9823) & age<26
replace agecheckcat=24 if (morph==8910|morph==8960|morph==8970|morph==8981|morph==8991|morph==9072|morph==9470|morph==9490|morph==9500|morph==9687|morph>9509&morph<9520) & age>15
replace agecheckcat=25 if morph==9724 & age<15
label var agecheckcat "Age/Site/Hx Check Category"
label define agecheckcat_lab 1 "Check 1: Age<3 & Hx=Hodgkin Lymphoma" 2 "Check 2: Age 10-14 & Hx=Neuroblastoma" 3 "Check 3: Age 6-14 & Hx=Retinoblastoma" ///
							 4 "Check 4: Age 9-14 & Hx=Wilm's Tumour" 5 "Check 5: Age 0-8 & Hx=Renal carcinoma" 6 "Check 6: Age 6-14 & Hx=Hepatoblastoma" ///
							 7 "Check 7: Age 0-8 & Hx=Hepatic carcinoma" 8 "Check 8: Age 0-5 & Hx=Osteosarcoma" 9 "Check 9: Age 0-5 & Hx=Chondrosarcoma" ///
							 10 "Check 10: Age 0-3 & Hx=Ewing sarcoma" 11 "Check 11: Age 8-14 & Hx=Non-gonadal germ cell" 12 "Check 12: Age 0-4 & Hx=Gonadal carcinoma" ///
							 13 "Check 13: Age 0-5 & Hx=Thyroid carcinoma" 14 "Check 14: Age 0-5 & Hx=Nasopharyngeal carcinoma" 15 "Check 15: Age 0-4 & Hx=Skin carcinoma" ///
							 16 "Check 16: Age 0-4 & Hx=Carcinoma, NOS" 17 "Check 17: Age 0-14 & Hx=Mesothelial neoplasms" 18 "Check 18: Age <40 & Hx=814_ & Top=61_" ///
							 19 "Check 19: Age <20 & Top=15._,19._,20._,21._,23._,24._,38.4,50._53._,54._,55._" 20 "Check 20: Age <20 & Top=17._ & Morph<9590(ie.not lymphoma)" ///
							 21 "Check 21: Age <20 & Top=33._ or 34._ or 18._ & Morph!=824_(ie.not carcinoid)" 22 "Check 22: Age >45 & Top=58._ & Morph==9100(chorioca.)" ///
							 23 "Check 23: Age <26 & Morph==9732(myeloma) or 9823(BCLL)" 24 "Check 24: Age >15 & Morph==8910/8960/8970/8981/8991/9072/9470/9490/9500/951_/9687" ///
							 25 "Check 25: Age <15 & Morph==9724" ,modify
label values agecheckcat agecheckcat_lab

** Create category for histological family groups according to family number in IARCcrgTools Check Program Appendix 1 pgs 11-31
gen hxfamcat=. //5150 26mar18
** Group 1 - Tumours with non-specific site-profile
replace hxfamcat=1 if (morph>7999 & morph<8005) | (morphcat==41 & morph!=9597) | morphcat==42 | (morphcat==43 & morph!=9679 & morph!=9689) ///
					   | (morphcat==44 & morph!=9700 & morph!=9708 & morph!=9709 & morph!=9717 & morph!=9718 & morph!=9726) | morphcat==45 ///
					   | (morphcat==46 & morph!=9732 & morph!=9733 & morph!=9734) | (morphcat==47 & morph!=9742) | morphcat==48 ///
					   | (morphcat==49 & morph!=9761 & morph!=9764 & morph!=9765) | morph==9930 | morphcat==55
** Group 2 - Tumours with specific site-profile
replace hxfamcat=2 if (morph==8561|morph==8974) & (topcat==8|topcat==9)
replace hxfamcat=3 if (morph==8142|morph==8214) & topcat==17
replace hxfamcat=4 if (morph==8683|morph==9764) & topcat==18
replace hxfamcat=5 if (morph==8213|morph==8220|morph==8261|morph==8265) & (topcat==19|topcat==20|topcat==21|topcat==27|topcat==70|topography==762|topography==763|topography==767|topography==768)
replace hxfamcat=6 if (morph==8124|morph==8215) & (topcat==21|topcat==22)
replace hxfamcat=7 if (morph==8144|morph==8145|morph==8221|morph==8936|morph==9717) & (topcat>15 & topcat<22|topcat==27|topcat==70|topography==762|topography==763|topography==767|topography==768)
replace hxfamcat=8 if (morph>8169 & morph<8176|morph==8970|morph==8975|morph==9124) & topcat==23
replace hxfamcat=9 if (morph>8159 & morph<8164|morph==8180|morph==8264) & (topcat>22 & topcat<26)
replace hxfamcat=10 if (morph>8149 & morph<8156 & morph!=8153|morph==8202|morph==8452|morph==8453|morph==8971) & topcat==26
replace hxfamcat=11 if (morph>9519 & morph<9524) & (topcat==28|topcat==29)
replace hxfamcat=12 if (morph>8039 & morph<8047|morph>8249 & morph<8256 & morph!=8251|morph==8012|morph==8827|morph==8972) & (topcat==32|topcat==35 & topography!=390|topography==761|topography==767|topography==768|topcat==70)
replace hxfamcat=13 if (morphcat==25 & morph!=9054|morph==8973) & (topcat==32|topography==483|topcat==35 & topography!=390|topcat==68 & topography!=760 & topography!=764 & topography!=765|topcat==70)
replace hxfamcat=14 if (morphcat==13|morph==9679) & (topcat==33|topcat==34)
replace hxfamcat=15 if morph==8454 & topography==380
replace hxfamcat=16 if morph==9365 & (topcat>34 & topcat<38|topcat==42|topography==761|topography==767|topography==768|topcat==70)
replace hxfamcat=17 if morph==9261 & (topcat==36 & topography!=401 & topography!=403)
replace hxfamcat=18 if (morph>9179 & morph<9211|morph==8812|morph==9250|morph==9262|morphcat==34) & (topcat==36|topcat==37)
replace hxfamcat=19 if (morphcat>49 & morphcat<55 & morph!=9807 & morph!=9930|morph==9689|morph==9732|morph==9733|morph==9742|morph==9761|morph==9765|morphcat==56) & topcat==38
replace hxfamcat=20 if (morphcat==4 & morph!=8098|morphcat==7|morph==8081|morph==8542|morph==8790|morph==9597|morph==9700|morph==9709|morph==9718|morph==9726) & (topcat==1|topcat==39|topcat==44|topcat==52|topography==632|topcat==68|topcat==70)
replace hxfamcat=21 if (morph==8247|morph==8832|morph==8833|morph==9507|morph==9708) & (topcat==1|topcat==39|topcat==42|topcat==44|topcat==52|topography==632|topography==638|topography==639|topcat==68|topcat==70)
replace hxfamcat=22 if (morph>8504 & morph<8544 & morph!=8510 & morph!=8514 & morph!=8525 & morph!=8542 | morph>9009 & morph<9013 | morph>9015 & morph<9031|morph==8204|morph==8314|morph==8315|morph==8501|morph==8502|morph==8983) & (topcat==43|topography==761|topography==767|topography==768|topcat==70)
replace hxfamcat=23 if morph==8905 & (topcat==44|topcat==45|topography==578|topography==579)
replace hxfamcat=24 if (morph==8930|morph==8931) & (topcat==47|topcat==48|topography==578|topography==579)
replace hxfamcat=25 if (morph>8440 & morph<8445 | morph>8459 & morph<8474 & morph!=8461 | morph>8594 & morph<8624 | morph>9012 & morph<9016 |morph==8313|morph==8451|morph==8632|morph==8641|morph==8660|morph==8670|morph==9000|morph==9090|morph==9091) & (topcat==49|topcat==50|topography==762|topography==763|topography==767|topography==768|topcat==70)
replace hxfamcat=26 if (morph==9103|morph==9104) & topcat==51
replace hxfamcat=27 if (morph>8379 & morph<8385|morph==8482|morph==8934|morph==8950|morph==8951) & (topcat==41|topography>493 & topography<500|topcat>45 & topcat<51|topography==762|topography==763|topography==767|topography==768|topcat==70)
replace hxfamcat=28 if morph==8080 & topcat==52
replace hxfamcat=29 if (morph>9060 & morph<9064 |morph==9102) & (topcat==54|topcat==55)
replace hxfamcat=30 if (morph>8315 & morph<8320 | morph>8958 & morph<8968 & morph!=8963|morph==8312|morph==8325|morph==8361) & (topcat==56|topography==688|topography==689)
replace hxfamcat=31 if (morph>9509 & morph<9515) & (topography==692|topography==698|topography==699)
replace hxfamcat=32 if (morph==8726|morph==8773|morph==8774) & topcat==61
replace hxfamcat=33 if (morphcat==38|morph==8728) & (topcat>61 & topcat<65)
replace hxfamcat=34 if (morph>9469 & morph<9481 & morph!=9473|morph==9493) & (topography==716|topography==718|topography==719|topography==728|topography==729)
replace hxfamcat=35 if (morph==9381|morph==9390|morph==9444) & (topcat==63|topography==728|topography==729)
replace hxfamcat=36 if (morph>9120 & morph<9124 | morphcat==36 & morph!=9381 & morph!=9390 & morph!=9395 & morph!=9444 & morph!=9470 & morph!=9471 & morph!=9472 & morph!=9474 & morph!=9480|morph==9131|morph==9505|morph==9506|morph==9508|morph==9509) & (topcat>61 & topcat<65|topography==753)
replace hxfamcat=37 if (morph>8329 & morph<8351) & topcat==65
replace hxfamcat=38 if (morph>8369 & morph<8376|morph==8700) & topcat==66
replace hxfamcat=39 if (morph==8321|morph==8322) & topography==750
replace hxfamcat=40 if (morph>8269 & morph<8282 | morph>9349 & morph<9353|morph==8300|morph==9582) & (topography==751|topography==752)
replace hxfamcat=41 if (morph>9359 & morph<9363|morph==9395) & topography==753
replace hxfamcat=42 if morph==8692 & topography==754
replace hxfamcat=43 if (morph==8690|morph==8691) & topography==755
replace hxfamcat=44 if morph==8098 & (topcat==39|topcat==46|topography==578|topography==579)
replace hxfamcat=45 if (morph==8153|morph==8156|morph==8157|morph==8158) & (topcat==17|topcat==18|topcat==26|topcat==27|topography==762|topography==767|topography==768|topcat==70)
replace hxfamcat=46 if morph==8290 & (topcat==8|topcat==9|topcat==56|topography==688|topography==689|topcat==65|topography==758|topography==759|topography==760|topography==762|topography==767|topography==768|topcat==70)
replace hxfamcat=47 if morph==8450 & (topcat==26|topcat==27|topcat==49|topcat==50)
replace hxfamcat=48 if morph==8461 & (topcat==41|topcat==49)
replace hxfamcat=49 if (morph>8589 & morph<8593 | morph>8629 & morph<8651 & morph!=8632 & morph!=8641|morph==9054) & (topcat==49|topography==578|topography==579|topcat==54|topography==638|topography==639|topography==762|topography==763|topography==767|topography==768|topcat==70)
replace hxfamcat=50 if (morphcat==16 & morph!=8726 & morph!=8728 & morph!=8773 & morph!=8774 & morph!=8790) & (topcat==21|topcat==22|topcat==28|topcat==39|topcat==44|topcat==52|topography==632|topcat==61|topcat==62|topcat==68|topcat==70)
replace hxfamcat=51 if (morph==8932|morph==8933|morphcat==28) & (topcat>43 & topcat<51 | topcat>55 & topcat<61|topography==762|topography==763|topography==767|topography==768|topcat==70)
replace hxfamcat=52 if morph==8935 & (topcat>45 & topcat<51|topcat==68 & topography!=760 & topography!=764 & topography!=765|topcat==43|topcat==70)
replace hxfamcat=53 if (morphcat==24|morphcat==32 & morph!=9250|morph==9260) & (topcat==36|topcat==37|topcat==42|topcat==68|topcat==70)
replace hxfamcat=54 if (morph>9219 & morph<9244) & (topography==300|topcat==29|topography>322 & topography<330|topcat==31|topcat>34 & topcat<38|topcat==42|topcat==68|topcat==70)
replace hxfamcat=55 if (morph==8077|morph==8148) & (topcat==22|topcat>43 & topcat<47|topcat==53)
replace hxfamcat=56 if (morphcat==5 & morph!=8123 & morph!=8124) & (topcat==12|topcat==15|topcat==21|topcat==22|topcat>26 & topcat<30|topcat==35|topcat==46|topcat==53|topcat>55 & topcat<61|topcat==68 & topography!=764 & topography!=765|topcat==70)
replace hxfamcat=57 if (morph>8239 & morph<8250 & morph!=8247) & (topcat>15 & topcat<28|topcat==32|topcat==33|topography>380 & topography<384|topcat==35 & topography!=390|topcat==49|topography==578|topography==579|topcat==65|topcat==68 & topography!=764 & topography!=765|topcat==70)
replace hxfamcat=58 if (morph==8500|morph==8503|morph==8504|morph==8514|morph==8525) & (topography==69|topcat==8|topcat==9|topcat>21 & topcat<27|topography==268|topography==269|topcat==43|topcat==53|topography==638|topography==639|topography==758|topography==759|topcat==68 & topography!=761 & topography!=764 & topography!=765|topcat==70)
replace hxfamcat=59 if (morphcat==15 & morph!=8683 & morph!=8690 & morph!=8691 & morph!=8692 & morph!=8700) & (topcat==34|topcat==35 & topography!=390|topcat>39 & topcat<43|topcat==59|topcat==60|topcat>62 & topcat<69|topcat==70)
replace hxfamcat=60 if (morphcat==26 & morph!=9061 & morph!=9062 & morph!=9063 & morph!=9090 & morph!=9091|morph==9105) & (topcat==34|topcat==35 & topography!=390|topcat==41|topcat==42|topcat==49|topcat==50|topcat==54|topcat==55|topcat==63|topcat==64|topcat==67|topcat==68 & topography!=764 & topography!=765|topcat==70)
replace hxfamcat=61 if (morph==9100|morph==9101) & (topcat==34|topcat>48 & topcat<52|topcat==54|topcat==68 & topography!=760 & topography!=764 & topography!=765|topcat==70)
replace hxfamcat=62 if (morph>9369 & morph<9374) & (topcat==12|topcat==15|topcat==28|topcat==29|topcat>34 & topcat<38|topcat==42|topcat==63|topcat==64|topcat==67|topcat==68|topcat==70)
replace hxfamcat=63 if (morph>9489 & morph<9505 & morph!=9493) & (topcat==34|topcat==35 & topography!=390|topcat>39 & topcat<43|topcat>60 & topcat<65|topcat==66|topography==758|topography==759|topcat==68|topcat==70)
replace hxfamcat=64 if morphcat==39 & (topcat==34|topcat==35 & topography!=390|topcat>39 & topcat<43|topcat>60 & topcat<65|topcat==68|topcat==70)
** Group 3 - Tumours with inverse site-profile
replace hxfamcat=65 if (morph>8833 & morph<8837|morph==8004|morph==8005|morph==8831|morphcat==30) & topcat==38
replace hxfamcat=66 if (morph>8009 & morph<8036 & morph!=8012|morphcat==3 & morph!=8077 & morph!=8080 & morph!=8081|morph>8139 & morph<8150 & morph!=8142 & morph!=8144 & morph!=8145 & morph!=8148|morph>8189 & morph<8213 & morph!=8202 & morph!=8204|morphcat==11|morphcat==12 & morph!=8561|morph>8979 & morph<8983|morph==8123|morph==8230|morph==8231|morph==8251|morph==8260|morph==8262|morph==8263|morph==8310|morph==8311|morph==8320|morph==8323|morph==8324|morph==8360|morph==8430|morph==8440|morph==8480|morph==8481|morph==8490|morph==8510|morph==8940|morph==8941) & (topcat>35 & topcat<39|topcat>39 & topcat<43|topcat>61 & topcat<65 | topcat==69)
replace hxfamcat=67 if (morphcat==17 & morph!=8802|morphcat==29 & morph!=9121 & morph!=9122 & morph!=9123 & morph!=9124 & morph!=9131 & morph!=9132 & morph!=9140|morphcat==40 & morph!=9582|morph==8671|morph==8963|morph==9363|morph==9364) & (topcat==38 & topography!=422|topcat==69)
replace hxfamcat=68 if morph==8802 & (topcat==36|topcat==37|topcat==38 & topography!=422|topcat==69)
replace hxfamcat=69 if (morphcat>17 & morphcat<22 & morph!=8812 & morph!=8827 & morph!=8831 & morph!=8832 & morph!=8833 & morph!=8834 & morph!=8835 & morph!=8836 & morph!=8905|morph==8990|morph==8991|morph==9132) & (topcat==38 & topography!=422|topcat>61 & topcat<65|topcat==69)
replace hxfamcat=70 if morph==9140 & (topcat==8|topcat==9|topcat>22 & topcat<27|topcat>35 & topcat<39|topcat==40|topcat==41|topcat>42 & topcat<52|topcat==53|topcat==54|topcat>55 & topcat<61|topcat>61 & topcat<68)
replace hxfamcat=71 if morph==9734 & (topcat==36|topcat==37)
label var hxfamcat "Hx Family Category(IARCcrgTools)"
label define hxfamcat_lab 1 "Tumours accepted with any site code" 2 "Salivary Gland tumours" 3 "Stomach tumours" 4 "Small Intestine tumours" 5 "Colorectal tumours" ///
						  6 "Anal tumours" 7 "Gastrointestinal tumours" 8 "Liver tumours" 9 "Biliary tumours" 10 "Pancreatic tumours" 11 "Olfactory tumours" ///
						  12 "Lung tumours" 13 "Mesotheliomas & pleuropulmonary Blastomas" 14 "Thymus tumours" 15 "Cystic tumours of atrio-ventricular node" ///
						  16 "Askin tumours" 17 "Adamantinomas of long bones" 18 "Bone tumours" 19 "Haematopoietic tumours" 20 "Skin tumours" ///
						  21 "Tumours of skin & subcutaneous tissue" 22 "Breast tumours" 23 "Genital rhabdomyomas" 24 "Endometrial stromal sarcomas" ///
						  25 "Ovarian tumours" 26 "Placental tumours" 27 "Tumours of female genital organs" 28 "Queyrat erythroplasias" 29 "Testicular tumours" ///
						  30 "Renal tumours" 31 "Retinoblastomas" 32 "Naevi & melanomas of eye" 33 "Meningeal tumours" 34 "Cerebellar tumours" 35 "Cerebral tumours" ///
						  36 "CNS tumours" 37 "Thyroid tumours" 38 "Adrenal tumours" 39 "Parathyroid tumours" 40 "Pituitary tumours" 41 "Pineal tumours" ///
						  42 "Carotid body tumours" 43 "Tumours of glomus jugulare/aortic body" 44 "Adenoid basal carcinomas" ///
						  45 "Gastrinomas/Somatostatinomas/Enteroglucagonomas" 46 "Oxyphilic adenocarcinomas" 47 "Papillary (cyst)adenocarcinomas" ///
						  48 "Serous surface papillary carcinomas" 49 "Gonadal tumours" 50 "Naevi & Melanomas" 51 "Adenosarcomas & Mesonephromas" 52 "Stromal sarcomas" ///
						  53 "Tumours of bone & connective tissue" 54 "Chondromatous tumours" 55 "Intraepithelial tumours" 56 "Transitional cell tumours" ///
						  57 "Carcinoid tumours" 58 "Ductal and lobular tumours" 59 "Paragangliomas" 60 "Germ cell & trophoblastic tumours" 61 "Choriocarcinomas" ///
						  62 "Chordomas" 63 "Neuroepitheliomatous tumours" 64 "Nerve sheath tumours" 65 "NOT haematopoietic tumours" 66 "NOT site-specific carcinomas" ///
						  67 "NOT site-specific sarcomas" 68 "NOT Bone-Giant cell sarcomas" 69 "NOT CNS affecting sarcomas" 70 "NOT sites of Kaposi sarcoma" ///
						  71 "NOT Bone-Plasmacytomas, extramedullary" ///
						  ,modify
label values hxfamcat hxfamcat_lab

** Create category for sex/histology check: IARCcrgTools pg 7
gen sexcheckcat=.
replace sexcheckcat=1 if sex==1 & (hxfamcat>22 & hxfamcat<28)
replace sexcheckcat=2 if sex==2 & (hxfamcat==28|hxfamcat==29)
label var sexcheckcat "Sex/Hx Check Category"
label define sexcheckcat_lab 1 "Check 1: Sex=male & HxFam=23,24,25,26,27" 2 "Check 2: Sex=female & Hx family=28,29" ///
							 ,modify
label values sexcheckcat sexcheckcat_lab

** Create category for site/histology check: IARCcrgTools pg 7
gen sitecheckcat=.
replace sitecheckcat=1 if hxfamcat==65
replace sitecheckcat=2 if hxfamcat==66
replace sitecheckcat=3 if hxfamcat==67
replace sitecheckcat=4 if hxfamcat==68
replace sitecheckcat=5 if hxfamcat==69
replace sitecheckcat=6 if hxfamcat==70
replace sitecheckcat=7 if hxfamcat==71
label var sitecheckcat "Site/Hx Check Category"
label define sexcheckcat_lab 1 "Check 1: NOT haem. tumours" 2 "Check 2: NOT site-specific ca." 3 "Check 3: NOT site-specific sarcomas" ///
							 4 "Check 4: Top=Bone; Hx=Giant cell sarc.except bone" 5 "Check 5: NOT sarcomas affecting CNS" 6 "Check 6: NOT sites for Kaposi sarcoma" ///
							 7 "Check 7: Top=Bone; Hx=extramedullary plasmacytoma" ,modify
label values sexcheckcat sexcheckcat_lab

** Create category for CODs as needed in LATERALITY category so non-cancer CODs with the terms 'left' & 'right' are not flagged
gen codcat=.
replace codcat=1 if cr5cod!="99" & cr5cod!="" & cr5cod!="NIL." & cr5cod!="Not Stated." & !strmatch(strupper(cr5cod), "*CANCER*") & !strmatch(strupper(cr5cod), "*OMA*") ///
		 & !strmatch(strupper(cr5cod), "*MALIG*") & !strmatch(strupper(cr5cod), "*TUM*") & !strmatch(strupper(cr5cod), "*LYMPH*") ///
		 & !strmatch(strupper(cr5cod), "*LEU*") & !strmatch(strupper(cr5cod), "*MYELO*") & !strmatch(strupper(cr5cod), "*METASTA*")
label var codcat "Laterality Category"
label define codcat_lab 1 "Non-cancer COD" ,modify
label values codcat codcat_lab

** Create category for laterality so can perform checks on this category
** Category determined using SEER Program Coding Staging Manual 2016 pgs 82-84
gen latcat=. //5150 04apr18
replace latcat=0 if latcat==.
replace latcat=1 if topography==79
replace latcat=2 if topography==80
replace latcat=3 if topography==81
replace latcat=4 if topography==90
replace latcat=5 if topography==91
replace latcat=6 if topography==98
replace latcat=7 if topography==99
replace latcat=8 if topography==300
replace latcat=9 if topography==301
replace latcat=10 if topography==310
replace latcat=11 if topography==312
replace latcat=12 if topography==340
replace latcat=13 if topography>340 & topography<350
replace latcat=14 if topography==384
replace latcat=15 if topography==400
replace latcat=16 if topography==401
replace latcat=17 if topography==402
replace latcat=18 if topography==403
replace latcat=19 if topography==413
replace latcat=20 if topography==414
replace latcat=21 if topography==441
replace latcat=22 if topography==442
replace latcat=23 if topography==443
replace latcat=24 if topography==445
replace latcat=25 if topography==446
replace latcat=26 if topography==447
replace latcat=27 if topography==471
replace latcat=28 if topography==472
replace latcat=29 if topography==491
replace latcat=30 if topography==492
replace latcat=31 if topography>499 & topography<510
replace latcat=32 if topography==569
replace latcat=33 if topography==570
replace latcat=34 if topography>619 & topography<630
replace latcat=35 if topography==630
replace latcat=36 if topography==631
replace latcat=37 if topography==649
replace latcat=38 if topography==659
replace latcat=39 if topography==669
replace latcat=40 if topography>689 & topography<700
replace latcat=41 if topography==700
replace latcat=42 if topography==710
replace latcat=43 if topography==711
replace latcat=44 if topography==712
replace latcat=45 if topography==713
replace latcat=46 if topography==714
replace latcat=47 if topography==722
replace latcat=48 if topography==723
replace latcat=49 if topography==724
replace latcat=50 if topography==725
replace latcat=51 if topography>739 & topography<750
replace latcat=52 if topography==754
label var latcat "Laterality Category(SEER)"
label define latcat_lab   0 "No lat cat" 1 "Lat-Parotid gland" 2 "Lat-Submandibular gland" 3 "Lat-Sublingual gland" 4 "Lat-Tonsillar fossa" 5 "Lat-Tonsillar pillar" ///
						  6 "Lat-Overlapping lesion: tonsil" 7 "Lat-Tonsil, NOS" 8 "Lat-Nasal cavity(excl. nasal cartilage,nasal septum)" 9 "Lat-Middle ear" ///
						  10 "Lat-Maxillary sinus" 11 "Lat-Frontal sinus" 12 "Lat-Main bronchus (excl. carina)" 13 "Lat-Lung" 14 "Lat-Pleura" ///
						  15 "Lat-Long bones:upper limb,scapula,associated joints" 16 "Lat-Short bones:upper limb,associated joints" ///
						  17 "Lat-Long bones:lower limb,associated joints" 18 "Lat-Short bones:lower limb,associated joints" 19 "Lat-Rib,clavicle(excl.sternum)" ///
						  20 "Lat-Pelvic bones(excl.sacrum,coccyx,symphysis pubis)" 21 "Lat-Skin:eyelid" 22 "Lat-Skin:external ear" 23 "Lat-Skin:face" ///
						  24 "Lat-Skin:trunk" 25 "Lat-Skin:upper limb,shoulder" 26 "Lat-Skin:lower limb,hip" 27 "Lat-ANS:upper limb,shoulder" 28 "Lat-ANS:lower limb,hip" ///
						  29 "Lat-Tissues:upper limb,shoulder" 30 "Lat-Tissues:lower limb,hip" 31 "Lat-Breast" 32 "Lat-Ovary" 33 "Lat-Fallopian tube" 34 "Lat-Testis" ///
						  35 "Lat-Epididymis" 36 "Lat-Spermatic cord" 37 "Lat-Kidney,NOS" 38 "Lat-Renal pelvis" 39 "Lat-Ureter" 40 "Lat-Eye,adnexa" ///
						  41 "Lat-Cerebral meninges" 42 "Lat-Cerebrum" 43 "Lat-Frontal lobe" 44 "Lat-Temporal lobe" 45 "Lat-Parietal lobe" 46 "Lat-Occipital lobe" ///
						  47 "Lat-Olfactory nerve" 48 "Lat-Optic nerve" 49 "Lat-Acoustic nerve" 50 "Lat-Cranial nerve" 51 "Lat-Adrenal gland" 52 "Lat-Carotid body" ,modify
label values latcat latcat_lab


** Create category for laterality checks
** Checks 5-10 are taken from SEER Program Coding Staging manual pgs 82-84
gen latcheckcat=.
replace latcheckcat=1 if (regexm(cr5cod, "LEFT")|regexm(cr5cod, "left")) & codcat!=1 & latcat>0 & (lat!=. & lat!=2)
replace latcheckcat=2 if (regexm(cr5cod, "RIGHT")|regexm(cr5cod, "right")) & codcat!=1 & latcat>0 & (lat!=. & lat!=1)
replace latcheckcat=3 if (regexm(cfdx, "LEFT")|regexm(cfdx, "left")) & latcat>0 & (lat!=. & lat!=2)
replace latcheckcat=4 if (regexm(cfdx, "RIGHT")|regexm(cfdx, "right")) & latcat>0 & (lat!=. & lat!=1)
replace latcheckcat=5 if topography==809 & (lat!=. & lat!=0)
replace latcheckcat=6 if latcat>0 & (lat==0|lat==8)
replace latcheckcat=7 if (latcat!=13 & latcat!=32 & latcat!=37 & latcat!=40) & lat==4
replace latcheckcat=8 if (latcat>40 & latcat<51|latcat==23|latcat==24) & dxyr>2009 & (lat!=. & lat!=5 & lat==8)
replace latcheckcat=9 if (latcat<41 & latcat>50 & latcat!=23 & latcat!=24) & dxyr>2009 & lat==5
replace latcheckcat=10 if (latcat!=0 & latcat!=8 & latcat!=12 & latcat!=19 & latcat!=20) & basis==0 & (lat!=. & lat==8)
replace latcheckcat=11 if topcat==65 & lat!=0
replace latcheckcat=12 if latcat==0 & topography!=809 & (lat!=0 & lat!=. & lat!=8) & latcheckcat==.
replace latcheckcat=13 if lat==8 & dxyr>2013
replace latcheckcat=14 if lat==8 & latcat!=0
label var latcheckcat "Laterality Check Category"
label define latcheckcat_lab 1 "Check 1: COD='left'; COD=cancer (codcat!=1); lat!=left" 2 "Check 2: COD='right'; COD=cancer (codcat!=1); lat!=right" ///
							 3 "Check 3: CFdx='left'; lat!=left"  4 "Check 4: CFdx='right'; lat!=right" 5 "Check 5: topog==809 & lat!=0-paired site" ///
							 6 "Check 6: latcat>0 & lat==0 or 8" 7 "Check 7: latcat!=ovary,lung,eye,kidney & lat==4" ///
							 8 "Check 8: latcat=meninges/brain/CNS/skin-face,trunk & dxyr>2009 & lat!=5 & lat=NA" ///
							 9 "Check 9: latcat!=meninges/brain/CNS/skin-face,trunk & dxyr>2009 & lat==5" 10 "Check 10: latcat!=0,8,12,19,20 & basis==0 & lat=NA" ///
							 11 "Check 11: primsite=thyroid and lat!=NA" 12 "Check 12: latcat=no lat cat; topog!=809; lat!=N/A; latcheckcat==." ///
							 13 "Check 13: laterality=N/A & dxyr>2013" 14 "Check 14: lat=N/A and latcat!=no lat cat" ,modify
label values latcheckcat latcheckcat_lab


** Create category for behaviour/morphology check
** Check 7 is taken from IARCcrgTools pg 8 (behaviour/histology)
gen behcheckcat=.
replace behcheckcat=1 if beh!=2 & morph==8503
replace behcheckcat=2 if beh!=2 & morph==8077
replace behcheckcat=3 if (regexm(hx, "SQUAMOUS")&regexm(hx, "MICROINVAS")) & beh!=3 & morph!=8076
replace behcheckcat=4 if regexm(hx, "BOWEN") & beh!=2
replace behcheckcat=5 if topography==181 & morph==8240 & beh!=1
replace behcheckcat=6 if regexm(hx, "ADENOMA") & (!strmatch(strupper(hx), "*ADENOCARCINOMA*")&!strmatch(strupper(hx), "*INVASION*")) & beh!=2 & morph==8263
replace behcheckcat=7 if morphcat==. & morph!=.
replace behcheckcat=8 if beh>1 & (hx=="TUMOUR"|hx=="TUMOR")
label var behcheckcat "Beh<>Morph Check Category"
label define behcheckcat_lab 1 "Check 1: Beh!=2 & Morph==8503" 2 "Check 2: Beh!=2 & Morph==8077" 3 "Check 3: Hx=Squamous & microinvasive & Beh=2 & Morph!=8076" ///
							 4 "Check 4: Hx=Bowen & Beh!=2" 5 "Check 5: Prim=appendix, Morph=carcinoid & Beh!=uncertain" ///
							 6 "Check 6: Hx=adenoma excl. adenoca. & invasion & Morph==8263 & Beh!=2" 7 "Check 7: Morph not listed in ICD-O-3" ///
							 8 "Check 8: Hx=tumour & beh>1" ,modify
label values behcheckcat behcheckcat_lab

** Create category for behaviour/site check: IARCcrgTools pg 8
gen behsitecheckcat=.
replace behsitecheckcat=1 if beh==2 & topcat==36
replace behsitecheckcat=2 if beh==2 & topcat==37
replace behsitecheckcat=3 if beh==2 & topcat==38
replace behsitecheckcat=4 if beh==2 & topcat==40
replace behsitecheckcat=5 if beh==2 & topcat==42
replace behsitecheckcat=6 if beh==2 & topcat==62
replace behsitecheckcat=7 if beh==2 & topcat==63
replace behsitecheckcat=8 if beh==2 & topcat==64
label var behsitecheckcat "Beh/Site Check Category"
label define behsitecheckcat_lab 1 "Check 1: Beh==2 & Top==C40._(bone)" 2 "Check 2: Beh==2 & Top==C41._(bone,NOS)" 3 "Check 3: Beh==2 & Top==C42._(haem)" ///
								 4 "Check 4: Beh==2 & Top==C47._(ANS)" 5 "Check 5: Beh==2 & Top==C49._(tissues)" 6 "Check 6: Beh==2 & Top==C70._(meninges)" ///
								 7 "Check 7: Beh==2 & Top==C71._(brain)" 8 "Check 8: Beh==2 & Top==C72._(CNS)" ,modify
label values behsitecheckcat behsitecheckcat_lab

** Create category for grade/histology check: IARCcrgTools pg 9
gen gradecheckcat=.
replace gradecheckcat=1 if beh<3 & grade<9 & dxyr>2013
replace gradecheckcat=2 if (grade>4 & grade<9) & morph<9590 & dxyr>2013
replace gradecheckcat=3 if (grade>0 & grade<5) & morph>9589 & dxyr>2013
replace gradecheckcat=4 if grade!=5 & (morph>9701 & morph<9710 | morph>9715 & morph <9727 & morph!=9719 | morph==9729 | morph==9827 | morph==9834 | morph==9837) & dxyr>2013
replace gradecheckcat=5 if (grade!=5|grade!=7) & morph==9714 & dxyr>2013
replace gradecheckcat=6 if (grade!=5|grade!=8) & (morph==9700 | morph==9701 | morph==9719 | morph==9831) & dxyr>2013
replace gradecheckcat=7 if grade!=6 & (morph>9669 & morph<9700|morph==9712|morph==9728|morph==9737|morph==9738|morph>9810 & morph<9819|morph==9823|morph==9826|morph==9833|morph==9836) & dxyr>2013
replace gradecheckcat=8 if grade!=8 & morph==9948 & dxyr>2013
replace gradecheckcat=9 if grade!=1 & (morph==8331 | morph==8851 | morph==9187 | morph==9511) & dxyr>2013
replace gradecheckcat=10 if grade!=2 & (morph==8249 | morph==8332 | morph==8858 | morph==9083 | morph==9243 | morph==9372) & dxyr>2013
replace gradecheckcat=11 if grade!=3 & (morph==8631|morph==8634) & dxyr>2013
replace gradecheckcat=12 if grade!=4 & (morph==8020|morph==8021|morph==8805|morph==9062|morph==9082|morph==9392|morph==9401|morph==9451|morph==9505|morph==9512) & dxyr>2013
replace gradecheckcat=13 if grade==9 & (regexm(cfdx, "GLEASON")|regexm(cfdx, "Gleason")|regexm(md, "GLEASON")|regexm(md, "Gleason")|regexm(consrpt, "GLEASON")|regexm(consrpt, "Gleason")) & dxyr>2013
replace gradecheckcat=14 if grade==9 & (regexm(cfdx, "NOTTINGHAM")|regexm(cfdx, "Nottingham")|regexm(md, "NOTTINGHAM")|regexm(md, "Nottingham")|regexm(consrpt, "NOTTINGHAM")|regexm(consrpt, "Nottingham") ///
							|regexm(cfdx, "BLOOM")|regexm(cfdx, "Bloom")|regexm(md, "BLOOM")|regexm(md, "Bloom")|regexm(consrpt, "BLOOM")|regexm(consrpt, "Bloom")) & dxyr>2013
replace gradecheckcat=15 if grade==9 & (regexm(cfdx, "FUHRMAN")|regexm(cfdx, "Fuhrman")|regexm(md, "FUHRMAN")|regexm(md, "Fuhrman")|regexm(consrpt, "FUHRMAN")|regexm(consrpt, "Fuhrman")) & dxyr>2013
replace gradecheckcat=16 if grade!=6 & morph==9732 & dxyr>2013
label var gradecheckcat "Grade/Hx Check Category"
label define gradecheckcat_lab 	 1 "Check 1: Beh<3 & Grade<9 & DxYr>2013" 2 "Check 2: Grade>=5 & <=8 & Hx<9590 & DxYr>2013" ///
								 3 "Check 3: Grade>=1 & <=4 & Hx>=9590 & DxYr>2013" ///
								 4 "Check 4: Grade!=5 & Hx=9702-9709,9716-9726(!=9719),9729,9827,9834,9837 & DxYr>2013" 5 "Check 5: Grade!=5 or 7 & Hx=9714 & DxYr>2013" ///
								 6 "Check 6: Grade!=5 or 8 & Hx=9700/9701/9719/9831 & DxYr>2013" ///
								 7 "Check 7: Grade!=6 & Hx=>=9670,<=9699,9712,9728,9737,9738,>=9811,<=9818,9823,9826,9833,9836 & DxYr>2013" ///
								 8 "Check 8: Grade!=8 & Hx=9948 & DxYr>2013" 9 "Check 9: Grade!=1 & Hx=8331/8851/9187/9511 & DxYr>2013" ///
								 10 "Check 10: Grade!=2 & Hx=8249/8332/8858/9083/9243/9372 & DxYr>2013" 11 "Check 11: Grade!=3 & HX=8631/8634 & DxYr>2013" ///
								 12 "Check 12: Grade!=4 & Hx=8020/8021/8805/9062/9082/9392/9401/9451/9505/9512 & DxYr>2013" ///
								 13 "Check 13: Grade=9 & cfdx/md/consrpt=Gleason & DxYr>2013" 14 "Check 14: Grade=9 & cfdx/md/consrpt=Nottingham/Bloom & DxYr>2013" ///
								 15 "Check 15: Grade=9 & cfdx/md/consrpt=Fuhrman & DxYr>2013" 16 "Check 16: Grade!=6 & Hx=9732(MM) & DxYr>2013" ,modify
label values gradecheckcat gradecheckcat_lab

** Create category for basis/morphology check
gen bascheckcat=.
replace bascheckcat=1 if morph==8000 & (basis>5 & basis<9)
replace bascheckcat=2 if regexm(hx, "OMA") & (basis<6 & basis>8)
replace bascheckcat=3 if basis!=. & morph!=8000 & (basis<5 & basis>8) & (morph<8150 & morph>8154) & morph!=8170 & (morph<8270 & morph>8281) ///
						& (morph!=8800 & morph!=8960 & morph!=9100 & morph!=9140 & morph!=9350 & morph!=9380 & morph!=9384 & morph!=9500 & morph!=9510) ///
						& (morph!=9590 & morph!=9732 & morph!=9761 & morph!=9800)
replace bascheckcat=4 if basis==0 & morph==8000 & regexm(hx, "MASS") & recstatus!=3
replace bascheckcat=5 if basis==0 & regexm(comments, "Notes seen")
label var bascheckcat "Basis<>Morph Check Category"
label define bascheckcat_lab 1 "Check 1: morph==8000 & (basis==6|basis==7|basis==8)" 2 "Check 2: hx=...OMA & basis!=6/7/8" ///
							 3 "Check 3: Basis not missing & basis!=cyto/heme/hist & morph on BOD/Hx Control IARCcrgTools" 4 "Check 4: Hx=mass; Basis=DCO; Morph==8000" ///
							 5 "Check 5: Basis=DCO; Comments=Notes seen" ,modify
label values bascheckcat bascheckcat_lab

** Create category for staging check
gen stagecheckcat=.
replace stagecheckcat=1 if (basis!=0 & basis!=9) & staging==9
replace stagecheckcat=2 if beh!=2 & staging==0
replace stagecheckcat=3 if topography==778 & staging==1
replace stagecheckcat=4 if (staging!=. & staging!=8) & dxyr!=2013
replace stagecheckcat=5 if (staging!=. & staging!=9) & topography==809 & dxyr==2013
replace stagecheckcat=6 if (basis==0|basis==9) & staging!=9 & dxyr==2013
replace stagecheckcat=7 if beh==2 & staging!=0 & dxyr==2013
label var stagecheckcat "Staging Check Category"
label define stagecheckcat_lab 1 "Check 1: basis!=0(DCO) or 9(unk) & staging=9(DCO)" 2 "Check 2: beh!=2(in-situ) & staging=0(in-situ)" ///
							   3 "Check 3: topog=778(overlap LNs) & staging=1(local.)" 4 "Check 4: staging!=8(NA) & dxyr!=2013" ///
							   5 "Check 5: staging!=9(NK) & topog=809 & dxyr=2013" 6 "Check 6: basis=0(DCO)/9(unk) & staging!=9(DCO) & dxyr=2013" ///
							   7 "Check 7: beh==2(in-situ) & staging!=0(in-situ) & dxyr=2013" ,modify
label values stagecheckcat stagecheckcat_lab

** Create category for incidence date check
gen dotcheckcat=.
replace dotcheckcat=1 if dot!=. & dob!=. & dot<dob
replace dotcheckcat=2 if dot!=. & dlc!=. & dot>dlc
replace dotcheckcat=3 if dot!=. & dlc!=. & basis==0 & dot!=dlc
replace dotcheckcat=4 if dot!=. & dxyr>2013 & dfc!=d(01jan2000) & admdate!=d(01jan2000) & rtdate!=d(01jan2000) & sampledate!=d(01jan2000) & recvdate!=d(01jan2000) & rptdate!=d(01jan2000) & (dot!=dfc & dot!=admdate & dot!=rtdate & dot!=sampledate & dot!=recvdate & dot!=rptdate & dot!=dlc) & regexm(cr5id, "S1")
replace dotcheckcat=5 if dot!=. & dxyr>2013 & admdate!=d(01jan2000) & rtdate!=d(01jan2000) & sampledate!=d(01jan2000) & recvdate!=d(01jan2000) & rptdate!=d(01jan2000) & dot==dfc & (dfc>admdate|dfc>rtdate|dfc>sampledate|dfc>recvdate|dfc>rptdate)
replace dotcheckcat=6 if dot!=. & dxyr>2013 & dfc!=d(01jan2000) & rtdate!=d(01jan2000) & sampledate!=d(01jan2000) & recvdate!=d(01jan2000) & rptdate!=d(01jan2000) & dot==admdate & (admdate>dfc|admdate>rtdate|admdate>sampledate|admdate>recvdate|admdate>rptdate)
replace dotcheckcat=7 if dot!=. & dxyr>2013 & dfc!=d(01jan2000) & admdate!=d(01jan2000) & sampledate!=d(01jan2000) & recvdate!=d(01jan2000) & rptdate!=d(01jan2000) & dot==rtdate & (rtdate>dfc|rtdate>admdate|rtdate>sampledate|rtdate>recvdate|rtdate>rptdate)
replace dotcheckcat=8 if dot!=. & dxyr>2013 & dfc!=d(01jan2000) & admdate!=d(01jan2000) & rtdate!=d(01jan2000) & recvdate!=d(01jan2000) & rptdate!=d(01jan2000) & dot==sampledate & (sampledate>dfc|sampledate>admdate|sampledate>rtdate|sampledate>recvdate|sampledate>rptdate)
replace dotcheckcat=9 if dot!=. & dxyr>2013 & dfc!=d(01jan2000) & admdate!=d(01jan2000) & rtdate!=d(01jan2000) & sampledate!=d(01jan2000) & rptdate!=d(01jan2000) & dot==recvdate & (recvdate>dfc|recvdate>admdate|recvdate>rtdate|recvdate>sampledate|recvdate>rptdate)
replace dotcheckcat=10 if dot!=. & dxyr>2013 & dfc!=d(01jan2000) & admdate!=d(01jan2000) & rtdate!=d(01jan2000) & sampledate!=d(01jan2000) & recvdate!=d(01jan2000) & dot==rptdate & (rptdate>dfc|rptdate>admdate|rptdate>rtdate|rptdate>sampledate|rptdate>recvdate)
label var dotcheckcat "InciDate Check Category"
label define dotcheckcat_lab 1 "Check 1: InciDate before DOB" ///
							 2 "Check 2: InciDate after DLC" 3 "Check 3: Basis=DCO & InciDate!=DLC" ///
							 4 "Check 4: InciDate<>DFC/AdmDate/RTdate/SampleDate/ReceiveDate/RptDate/DLC(2014 onwards)" ///
							 5 "Check 5: InciDate=DFC; DFC after AdmDate/RTdate/SampleDate/ReceiveDate/RptDate(2014 onwards)" ///
							 6 "Check 6: InciDate=AdmDate; AdmDate after DFC/RTdate/SampleDate/ReceiveDate/RptDate(2014 onwards)" ///
							 7 "Check 7: InciDate=RTdate; RTdate after DFC/AdmDate/SampleDate/ReceiveDate/RptDate(2014 onwards)" ///
							 8 "Check 8: InciDate=SampleDate; SampleDate after DFC/AdmDate/RTdate/ReceiveDate/RptDate(2014 onwards)" ///
							 9 "Check 9: InciDate=ReceiveDate; ReceiveDate after DFC/AdmDate/RTdate/SampleDate/RptDate(2014 onwards)" ///
							 10 "Check 10: InciDate=RptDate; RptDate after DFC/AdmDate/RTdate/SampleDate/ReceiveDate(2014 onwards)" ///
							 ,modify
label values dotcheckcat dotcheckcat_lab

** Create category for DxYr check
gen dxyrcheckcat=.
replace dxyrcheckcat=1 if dotyear!=. & dxyr!=. & dotyear!=dxyr
replace dxyrcheckcat=2 if (admyear!=. & admyear!=2000) & dxyr!=. & dxyr>2013 & admyear!=dxyr
replace dxyrcheckcat=3 if (dfcyear!=. & dfcyear!=2000) & dxyr!=. & dxyr>2013 & dfcyear!=dxyr
replace dxyrcheckcat=4 if (rtyear!=. & rtyear!=2000) & dxyr!=. & dxyr>2013 & rtyear!=dxyr
label var dxyrcheckcat "DxYr Check Category"
label define dxyrcheckcat_lab 1 "Check 1: dotyear!=dxyr" 2 "Check 2: admyear!=dxyr & dxyr>2013" 3 "Check 3: dfcyear!=dxyr & dxyr>2013" ///
							  4 "Check 4: rtyear!=dxyr & dxyr>2013" ///
							 ,modify
label values dxyrcheckcat dxyrcheckcat_lab

** Create category for Treatments 1-5 check
gen rxcheckcat=.
replace rxcheckcat=1 if rx1==0 & (rx1d!=. & rx1d!=d(01jan2000))
replace rxcheckcat=2 if rx1==9 & (rx1d!=. & rx1d!=d(01jan2000))
replace rxcheckcat=3 if rx1!=. & rx1!=0 & rx1!=9 & (rx1d==.|rx1d==d(01jan2000))
replace rxcheckcat=4 if rx1d > rx2d
replace rxcheckcat=5 if rx1d > rx3d
replace rxcheckcat=6 if rx1d > rx4d
replace rxcheckcat=7 if rx1d > rx5d
replace rxcheckcat=8 if rx2==0|rx2==9
replace rxcheckcat=9 if rx2==. & (rx2d!=. & rx2d!=d(01jan2000))
replace rxcheckcat=10 if rx2!=. & rx2!=0 & rx2!=9 & (rx2d==.|rx2d==d(01jan2000))
replace rxcheckcat=11 if rx2d > rx3d
replace rxcheckcat=12 if rx2d > rx4d
replace rxcheckcat=13 if rx2d > rx5d
replace rxcheckcat=14 if rx3==0|rx3==9
replace rxcheckcat=15 if rx3==. & (rx3d!=. & rx3d!=d(01jan2000))
replace rxcheckcat=16 if rx3!=. & rx3!=0 & rx3!=9 & (rx3d==.|rx3d==d(01jan2000))
replace rxcheckcat=17 if rx3d > rx4d
replace rxcheckcat=18 if rx3d > rx5d
replace rxcheckcat=19 if rx4==0|rx4==9
replace rxcheckcat=20 if rx4==. & (rx4d!=. & rx4d!=d(01jan2000))
replace rxcheckcat=21 if rx4!=. & rx4!=0 & rx4!=9 & (rx4d==.|rx4d==d(01jan2000))
replace rxcheckcat=22 if rx4d > rx5d
replace rxcheckcat=23 if rx5==0|rx5==9
replace rxcheckcat=24 if rx5==. & (rx5d!=. & rx5d!=d(01jan2000))
replace rxcheckcat=25 if rx5!=. & rx5!=0 & rx5!=9 & (rx5d==.|rx5d==d(01jan2000))
replace rxcheckcat=26 if dot!=. & rx1d!=. & rx1d!=d(01jan2000) & rx1d<dot
replace rxcheckcat=27 if dot!=. & rx2d!=. & rx2d!=d(01jan2000) & rx2d<dot
replace rxcheckcat=28 if dot!=. & rx3d!=. & rx3d!=d(01jan2000) & rx3d<dot
replace rxcheckcat=29 if dot!=. & rx4d!=. & rx4d!=d(01jan2000) & rx4d<dot
replace rxcheckcat=30 if dot!=. & rx5d!=. & rx5d!=d(01jan2000) & rx5d<dot
replace rxcheckcat=31 if dlc!=. & rx1d!=. & rx1d!=d(01jan2000) & rx1d>dlc
replace rxcheckcat=32 if dlc!=. & rx2d!=. & rx2d!=d(01jan2000) & rx2d>dlc
replace rxcheckcat=33 if dlc!=. & rx3d!=. & rx3d!=d(01jan2000) & rx3d>dlc
replace rxcheckcat=34 if dlc!=. & rx4d!=. & rx4d!=d(01jan2000) & rx4d>dlc
replace rxcheckcat=35 if dlc!=. & rx5d!=. & rx5d!=d(01jan2000) & rx5d>dlc
replace rxcheckcat=36 if regexm(comments, "proterone") & primarysite!="" & (rx1!=5 & rx2!=5 & rx3!=5 & rx4!=5 & rx5!=5)
replace rxcheckcat=37 if regexm(comments, "alidomide") & primarysite!="" & (rx1!=4 & rx2!=4 & rx3!=4 & rx4!=4 & rx5!=4)
replace rxcheckcat=38 if regexm(comments, "ximab") & primarysite!="" & (rx1!=4 & rx2!=4 & rx3!=4 & rx4!=4 & rx5!=4)
replace rxcheckcat=39 if regexm(comments, "xametha") & primarysite!="" & (rx1!=5 & rx2!=5 & rx3!=5 & rx4!=5 & rx5!=5)
replace rxcheckcat=40 if regexm(comments, "rednisone") & primarysite!="" & (rx1!=5 & rx2!=5 & rx3!=5 & rx4!=5 & rx5!=5)
replace rxcheckcat=41 if regexm(comments, "cortisone") & primarysite!="" & (rx1!=5 & rx2!=5 & rx3!=5 & rx4!=5 & rx5!=5)
replace rxcheckcat=42 if regexm(comments, "rimid") & primarysite!="" & (rx1!=5 & rx2!=5 & rx3!=5 & rx4!=5 & rx5!=5)
replace rxcheckcat=43 if rx1==0 & (rx2!=.|rx3!=.|rx4!=.|rx5!=.)
/*
replace rxcheckcat=36 if regexm(comments, "proterone") & ((rx1!=. & rx1!=5) & (rx2!=. & rx2!=5) & (rx3!=. & rx3!=5) & (rx4!=. & rx4!=5) & (rx5!=. & rx5!=5))
replace rxcheckcat=37 if regexm(comments, "alidomide") & ((rx1!=. & rx1!=4) & (rx2!=. & rx2!=4) & (rx3!=. & rx3!=4) & (rx4!=. & rx4!=4) & (rx5!=. & rx5!=4))
replace rxcheckcat=38 if regexm(comments, "ximab") & ((rx1!=. & rx1!=4) & (rx2!=. & rx2!=4) & (rx3!=. & rx3!=4) & (rx4!=. & rx4!=4) & (rx5!=. & rx5!=4))
*/
label var rxcheckcat "Rx1-5 Check Category"
label define rxcheckcat_lab 1 "Check 1: rx1=0-no rx & rx1d!=./01jan00" 2 "Check 2: rx1=9-unk & rx1d!=./01jan00" ///
							3 "Check 3: rx1!=. & rx1!=0-no rx & rx1!=9-unk & rx1d==./01jan00" 4 "Check 4: rx1d after rx2d" 5 "Check 5: rx1d after rx3d" ///
							6 "Check 6: rx1d after rx4d" 7 "Check 7: rx1d after rx5d" 8 "Check 8: rx2=0-no rx or 9-unk" 9 "Check 9: rx2==. & rx2d!=./01jan00" ///
							10 "Check 10: rx2!=. & rx2!=0-no rx & rx2!=9-unk & rx2d==./01jan00" 11 "Check 11: rx2d after rx3d" 12 "Check 12: rx2d after rx4d" ///
							13 "Check 13: rx2d after rx5d" 14 "Check 14: rx3=0-no rx or 9-unk" 15 "Check 15: rx3==. & rx3d!=./01jan00" ///
							16 "Check 16: rx3!=. & rx3!=0-no rx & rx3!=9-unk & rx3d==./01jan00" 17 "Check 17: rx3d after rx4d" 18 "Check 18: rx3d after rx5d" ///
							19 "Check 19: rx4=0-no rx or 9-unk" 20 "Check 20: rx4==. & rx4d!=./01jan00" ///
							21 "Check 21: rx4!=. & rx4!=0-no rx & rx4!=9-unk & rx4d==./01jan00" 22 "Check 22: rx4d after rx5d" 23 "Check 23: rx5=0-no rx or 9-unk" ///
							24 "Check 24: rx5==. & rx5d!=./01jan00" 25 "Check 25: rx5!=. & rx5!=0-no rx & rx5!=9-unk & rx5d==./01jan00" ///
							26 "Check 26: Rx1 before InciD" 27 "Check 27: Rx2 before InciD" 28 "Check 28: Rx3 before InciD" 29 "Check 29: Rx4 before InciD" ///
							30 "Check 30: Rx5 before InciD" 31 "Check 31: Rx1 after DLC" 32 "Check 32: Rx2 after DLC" 33 "Check 33: Rx3 after DLC" ///
							34 "Check 34: Rx4 after DLC" 35 "Check 35: Rx5 after DLC" 36 "Check 36: Rx1-5!=hormono & Comments=Cyproterone" ///
							37 "Check 37: Rx1-5!=immuno & Comments=Thalidomide" 38 "Check 38: Rx1-5!=immuno & Comments=Rituximab" ///
							39 "Check 39: Rx1-5!=hormono & Comments=Dexamethasone" 40 "Check 40: Rx1-5!=hormono & Comments=Prednisone" ///
							41 "Check 41: Rx1-5!=hormono & Comments=Hydrocortisone" 42 "Check 42: Rx1-5!=hormono & Comments=Arimidex" ///
							43 "Check 43: Rx1=no rx & Rx2-5!=." ///
							,modify
label values rxcheckcat rxcheckcat_lab

** Create category for Other Treatments 1 & 2 check
** Need to create string variable for OtherRx1
** Need to change all othtreat1=="." to othtreat1==""
gen othtreat1=orx1
tostring othtreat1, replace
replace othtreat1="" if othtreat1=="." //5021 23apr18
gen orxcheckcat=.
replace orxcheckcat=1 if orx1==. & (rx1==8|rx2==8|rx3==8|rx4==8|rx5==8)
replace orxcheckcat=2 if orx1!=. & orx2==""
replace orxcheckcat=3 if othtreat1!="" & length(othtreat1)!=1
replace orxcheckcat=4 if regexm(orx2, "UNK")
label var orxcheckcat "OthRx1&2 Check Category"
label define orxcheckcat_lab 1 "Check 1: OtherRx 1 missing" 2 "Check 2: OtherRx 2 missing" 3 "Check 3: OtherRx1 invalid length" 4 "Check 4: orx2=UNKNOWN" ///
							,modify
label values orxcheckcat orxcheckcat_lab

** Create category for No Treatments 1 & 2 check
** Need to create string variable for NoRx1 & NoRx2
** Need to change all notreat1=="." to notreat1==""
** Need to change all notreat2=="." to notreat2==""
gen notreat1=norx1
tostring notreat1, replace
gen notreat2=norx2
tostring notreat2, replace
replace notreat1="" if notreat1=="." //4809 23apr18
replace notreat2="" if notreat2=="." //5139 23apr18
gen norxcheckcat=.
replace norxcheckcat=1 if norx1==. & (rx1==0|rx2==0|rx3==0|rx4==0|rx5==0)
replace norxcheckcat=2 if norx1!=. & (rx1!=0 & rx2!=0 & rx3!=0 & rx4!=0 & rx5!=0)
replace norxcheckcat=3 if norx1==. & norx2!=.
replace norxcheckcat=4 if notreat1!="" & length(notreat1)!=1
replace norxcheckcat=5 if notreat2!="" & length(notreat2)!=1
label var norxcheckcat "NoRx1&2 Check Category"
label define norxcheckcat_lab 1 "Check 1: NoRx 1 missing" 2 "Check 2: rx1-5!=0 & norx1!=." 3 "Check 3: norx1==. & norx2!=." 4 "Check 4: NoRx1 invalid length" ///
							  5 "Check 5: NoRx2 invalid length" ,modify
label values norxcheckcat norxcheckcat_lab

** Create category for Source Name check
** Need to create string variable for sourcename
** Need to change all sname=="." to sname==""
gen sname=sourcename
tostring sname, replace
replace sname="" if sname=="." //45 24apr18
gen sourcecheckcat=.
replace sourcecheckcat=1 if sname!="" & length(sname)!=1
replace sourcecheckcat=2 if (sourcename!=1 & sourcename!=2) & nftype==1 & dxyr>2013
replace sourcecheckcat=3 if sourcename==4 & nftype!=3 & dxyr>2013
replace sourcecheckcat=4 if sourcename==5 & nftype!=8 & dxyr>2013
replace sourcecheckcat=5 if sourcename!=1 & (nftype==9|nftype==10) & dxyr>2013
replace sourcecheckcat=6 if sourcename!=2 & nftype==12 & dxyr>2013
replace sourcecheckcat=7 if sourcename!=6 & nftype==2 & dxyr>2013
replace sourcecheckcat=8 if sourcename==8
label var sourcecheckcat "SourceName Check Category"
label define sourcecheckcat_lab 1 "Check 1: SourceName invalid length" 2 "Check 2: SourceName!=QEH/BVH; NFType=Hospital; dxyr>2013" ///
								3 "Check 3: SourceName=IPS-ARS; NFType!=Pathology; dxyr>2013" 4 "Check 4: SourceName=DeathRegistry; NFType!=Death Certif/PM; dxyr>2013" ///
								5 "Check 5: SourceName!=QEH; NFType=QEH Death Rec/RT bk; dxyr>2013" 6 "Check 6: SourceName!=BVH; NFType=BVH bk; dxyr>2013" ///
								7 "Check 7: SourceName!=Polyclinic; NFType=Poly/Dist.Hosp; dxyr>2013" 8 "Check 8: SourceName=Other(possibly invalid)" ///
								,modify
label values sourcecheckcat sourcecheckcat_lab

** Create category for Doctor check
gen doccheckcat=.
replace doccheckcat=1 if doctor=="Not Stated"
label var doccheckcat "Doctor Check Category"
label define doccheckcat_lab 1 "Check 1: Doctor invalid entry" ///
								,modify
label values doccheckcat doccheckcat_lab

** Create category for Doctor's Address check
gen docaddrcheckcat=.
replace docaddrcheckcat=1 if docaddr=="Not Stated"|docaddr=="NONE"
label var docaddrcheckcat "Doc Address Check Category"
label define docaddrcheckcat_lab 1 "Check 1: Doc Address invalid entry" ///
								,modify
label values docaddrcheckcat docaddrcheckcat_lab

** Create category for Sample Taken, Received and Report Dates check
gen rptcheckcat=.
replace rptcheckcat=1 if sampledate==. & (nftype>2 & nftype<6)
replace rptcheckcat=2 if recvdate==. & (nftype>2 & nftype<6)
replace rptcheckcat=3 if rptdate==. & (nftype>2 & nftype<6)
replace rptcheckcat=4 if (recvdate!=. & recvdate!=d(01jan2000)) & sampledate > recvdate
replace rptcheckcat=5 if (rptdate!=. & rptdate!=d(01jan2000)) & sampledate > rptdate
replace rptcheckcat=6 if (rptdate!=. & rptdate!=d(01jan2000)) & recvdate > rptdate
replace rptcheckcat=7 if dot!=. & sampledate!=. & sampledate!=d(01jan2000) & sampledate<dot
replace rptcheckcat=8 if dot!=. & recvdate!=. & recvdate!=d(01jan2000) & recvdate<dot
replace rptcheckcat=9 if dot!=. & rptdate!=. & rptdate!=d(01jan2000) & rptdate<dot
replace rptcheckcat=10 if dlc!=. & sampledate!=. & sampledate!=d(01jan2000) & sampledate>dlc
replace rptcheckcat=11 if sampledate!=. & sampledate!=d(01jan2000) & (nftype!=3 & nftype!=4 & nftype!=5) & (labnum==""|labnum=="99")
replace rptcheckcat=12 if recvdate!=. & recvdate!=d(01jan2000) & (nftype!=3 & nftype!=4 & nftype!=5) & (labnum==""|labnum=="99")
replace rptcheckcat=13 if rptdate!=. & rptdate!=d(01jan2000) & (nftype!=3 & nftype!=4 & nftype!=5) & (labnum==""|labnum=="99")
label var rptcheckcat "Rpt Dates Check Category"
label define rptcheckcat_lab 1 "Check 1: Sample Date missing" 2 "Check 2: Received Date missing" 3 "Check 3: Report Date missing" 4 "Check 4: sampledate after recvdate" ///
							 5 "Check 5: sampledate after rptdate" 6 "Check 6: recvdate after rptdate" 7 "Check 7: sampledate before InciD" ///
							 8 "Check 8: recvdate before InciD" 9 "Check 9: rptdate before InciD" 10 "Check 10: sampledate after DLC" ///
							 11 "Check 11: sampledate!=. & nftype!=lab~" 12 "Check 12: recvdate!=. & nftype!=lab~" 13 "Check 13: rptdate!=. & nftype!=lab~" ///
							 ,modify
label values rptcheckcat rptcheckcat_lab

** Create category for Admission, DFC and RT Dates check
gen datescheckcat=.
replace datescheckcat=1 if admdate==. & sourcename<3
replace datescheckcat=2 if dfc==. & (sourcename==3|sourcename==4)
replace datescheckcat=3 if rtdate==. & nftype==10
replace datescheckcat=4 if ((admdate!=. & admdate!=d(01jan2000)) & (dfc!=. & dfc!=d(01jan2000)) & (rtdate!=. & rtdate!=d(01jan2000))) & (dot!=.) & (admdate<dot|dfc<dot|rtdate<dot)
replace datescheckcat=5 if ((admdate!=. & admdate!=d(01jan2000)) & (dfc!=. & dfc!=d(01jan2000)) & (rtdate!=. & rtdate!=d(01jan2000))) & (dlc!=.) & (admdate>dlc|dfc>dlc|rtdate>dlc)
replace datescheckcat=6 if (admdate!=. & admdate!=d(01jan2000)) & (sourcename!=1 & sourcename!=2)
replace datescheckcat=7 if (dfc!=. & dfc!=d(01jan2000)) & (sourcename!=3 & sourcename!=4)
replace datescheckcat=8 if (rtdate!=. & rtdate!=d(01jan2000)) & nftype!=10
label var datescheckcat "Rpt Dates Check Category"
label define datescheckcat_lab 1 "Check 1: Admission Date missing" 2 "Check 2: DFC missing" 3 "Check 3: RT Date missing" 4 "Check 4: admdate/dfc/rtdate BEFORE InciD" ///
							 5 "Check 5: admdate/dfc/rtdate after DLC" 6 "Check 6: admdate!=. & sourcename!=hosp" 7 "Check 7: dfc!=. & sourcename!=PrivPhys/IPS" ///
							 8 "Check 8: rtdate!=. & nftype!=RT" ///
							 ,modify
label values datescheckcat datescheckcat_lab


** Put variables in order they are to appear
order pid fname lname init age sex dob natregno resident slc dlc ///
	    parish cr5cod primarysite morph top lat beh hx

count //

save "`datapath'\version01\2-working\2013_cancer_prep_dc.dta" ,replace
label data "BNR-Cancer prepared 2013 data"
notes _dta :These data prepared for 2013 inclusion in 2014 cancer report
