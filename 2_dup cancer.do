** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          2_dup cancer.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      11-MAR-2021
    // 	date last modified      11-MAR-2021
    //  algorithm task          Identifying duplicates in CanReg5 dataset
    //  status                  Completed
    //  objective               To have a complete list of duplicates for the cancer team to check for "missed merges" in prep for 2018 cancer report.
    //  methods                 Exporting entire CanReg5 dataset and using name and NRN variables for duplicate check

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
    log using "`logpath'\2_dup cancer.smcl", replace
** HEADER -----------------------------------------------------

** LOAD and SAVE the SOURCE+TUMOUR+PATIENT dataset (Source_+Tumour+Patient tables)
insheet using "`datapath'\version04\1-input\2021-03-11_MAIN Source+Tumour+Patient_JC.txt"

format tumourid %14.0g
format tumouridsourcetable %14.0g
format sourcerecordid %16.0g

save "`datapath'\version04\2-working\2008-2020_dup_cancer_import" ,replace
clear

use "`datapath'\version04\2-working\2008-2020_dup_cancer_import" , clear

** Delete unused variables as it will reduce time spent when exporting results in excel
drop tumouridsourcetable stdataabstractor stsourcedate nftype sourcename doctor doctoraddress recordnumber cfdiagnosis labnumber specimen sampletakendate receiveddate ///
	 reportdate clinicaldetails cytologicalfindings microscopicdescription consultationreport causesofdeath durationofillness onsetdeathinterval certifier admissiondate ///
	 datefirstconsultation rtregdate streviewer recordstatus checkstatus multipleprimary mpseq updatedate obsoleteflagtumourtable patientidtumourtable ///
	 patientrecordidtumourtable tumourupdatedby tumourunduplicationstatus ttdataabstractor ttabstractiondate parish address age primarysite topography histology ///
	 morphology laterality behaviour grade basisofdiagnosis tnmcatstage tnmantstage esstnmcatstage esstnmantstage summarystaging incidencedate consultant ///
	 iccccode icd10 treatment1 treatment1date treatment2 treatment2date treatment3 treatment3date treatment4 treatment4date treatment5 treatment5date ///
	 othertreatment1 othertreatment2 notreatment1 notreatment2 ttreviewer personsearch residentstatus statuslastcontact datelastcontact ///
	 comments ptdataabstractor ptcasefindingdate casestatus obsoleteflagpatienttable patientrecordid patientupdatedby patientupdatedate patientrecordstatus ///
	 patientcheckstatus retrievalsource notesseen notesseendate furtherretrievalsource ptreviewer 

** Generate variable for the excel duplicate lists called 'No' then label variables that will appear in list
gen str_no=""
gen str_da=""
gen str_dadate=""
gen str_action=""
label var registrynumber "Reg #"
label var lastname "Last Name"
label var firstname "First Name"
label var birthdate "DOB"
label var hospitalnumber "Hospital #"
label var diagnosisyear "Dx Year"
label var str_no "No."
label var str_da "DA to Take Action"
label var str_dadate "Date DA Took Action"
label var str_action "Action Taken"
** Drop cases where there are 2 tumours that have already been merged under 1 registry number
sort registrynumber
quietly by registrynumber:  gen dup = cond(_N==1,0,_n)
count if dup>1 //6441
drop if dup>1 //6441 deleted
drop dup

************************************** FIRST, run the code above this line then run the 3 different duplicate check lists **********************************************

** First check for if first or last name is missing
count if firstname=="" //1 - blank record
count if lastname=="" //2
drop if registrynumber==20159999
replace lastname=firstname if registrynumber==20190316
replace firstname=middleinitials if registrynumber==20190316
replace middleinitials="" if registrynumber==20190316

** Patient Names duplicate check
preserve
drop if lastname==""
sort lastname firstname
quietly by lastname firstname:  gen dup = cond(_N==1,0,_n)
sort lastname firstname registrynumber
count if dup>0 //702
capture export_excel str_no registrynumber lastname firstname sex birthdate hospitalnumber diagnosisyear str_da str_dadate str_action if dup>0 using "`datapath'\version04\3-output\20210311CancerDuplicates.xlsx", sheet("Names") firstrow(varlabels)
drop dup 
restore

** Check for matches using natregno
preserve
drop if nrn==""|nrn=="999999-9999"|regexm(nrn,"9999")
sort nrn 
quietly by nrn : gen dup = cond(_N==1,0,_n)
sort nrn registrynumber lastname firstname
count if dup>0 //229
capture export_excel str_no registrynumber lastname firstname sex nrn birthdate hospitalnumber diagnosisyear str_da str_dadate str_action if dup>0 using "`datapath'\version04\3-output\20210311CancerDuplicates.xlsx", sheet("NRN") firstrow(varlabels)
drop dup
restore

** Create var to identify DOBs with unknown month day and then to drop any that=99
** DOB duplicate check
** Since there are errors in DOB field, need to correct before proceeding
count if length(birthdate)<8|length(birthdate)>8 //22
replace birthdate=subinstr(birthdate,"8","18",.) if registrynumber==20160465 & birthdate!=""
replace birthdate="" if length(birthdate)<8 //10 changes
count if birthdate=="99999999" //617
replace birthdate="" if birthdate=="99999999" //619 changes
replace birthdate = lower(rtrim(ltrim(itrim(birthdate)))) //0 changes
count if birthdate!="" & (length(birthdate)<8|length(birthdate)>8) //0
count if regexm(birthdate, "99") & !(strmatch(strupper(birthdate), "*19*")) //722
gen birthd=substr(birthdate,-2,2)
replace birthdate="" if birthd=="99" //669 changes
drop birthd
count if regexm(birthdate,"-") //1
replace birthdate=subinstr(birthdate,"3","193",.) if registrynumber==20201091 & birthdate!=""
replace birthdate=subinstr(birthdate,"-0","",.) if registrynumber==20201091 & birthdate!=""

gen str_dob=birthdate
destring birthdate ,replace

NEXT TIME YOU RUN DUP LIST FOR DOB, TRY USING BELOW CODE FROM DEATH DATA
** Create string dod field so can using in duplicate matching
gen dod2=dod
format dod2 %tdCCYY-NN-DD
tostring dod2 ,replace

/* 
Check below list for cases where namematch=no match but 
there is a pt with same name then:
 (1) check if same pt and remove duplicate pt;
 (2) check if same name but different pt and
	 update namematch variable to reflect this, i.e.
	 namematch=1
*/
sort lname fname dod2 record_id
quietly by lname fname dod2 : gen dupnmdod2 = cond(_N==1,0,_n)
sort lname fname dod2 record_id
count if dupnmdod2>0 //22

preserve
//tostring birthdate, gen (str_dob)
gen dobyear = substr(str_dob,1,4)
gen dobmonth = substr(str_dob,5,2)
gen dobday = substr(str_dob,7,2)
drop if dobyear=="9999" | dobmonth=="99" | dobday=="99"
drop dobday dobmonth dobyear
drop if birthdate==. | birthdate==99999999
sort birthdate lastname firstname
quietly by birthdate:  gen dup = cond(_N==1,0,_n)
sort lastname firstname
quietly by lastname firstname:  gen dupname = cond(_N==1,0,_n)
drop if dupname==0
sort birthdate
count if dup>0 //271
capture export_excel str_no registrynumber lastname firstname birthdate sex hospitalnumber diagnosisyear str_da str_dadate str_action if dup>0 using "`datapath'\version04\3-output\20210311CancerDuplicates.xlsx", sheet("DOB") firstrow(varlabels)
drop dup
restore

** Hospital Number duplicate check
preserve
drop if hospitalnumber=="" | hospitalnumber=="99"
sort hospitalnumber lastname firstname
quietly by hospitalnumber :  gen dup = cond(_N==1,0,_n)
sort hospitalnumber
count if dup>0 //153
capture export_excel str_no registrynumber lastname firstname birthdate sex hospitalnumber diagnosisyear str_da str_dadate str_action if dup>0 using "`datapath'\version04\3-output\20210311CancerDuplicates.xlsx", sheet("Hosp#") firstrow(varlabels)
drop dup
restore

save "`datapath'\version04\3-output\2008-2020_duplicates_cancer.dta" ,replace
label data "BNR-Cancer Duplicates"
notes _dta :These data prepared for SDA to use in prep for 2018 annual report
