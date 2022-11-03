** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          DeathCF_2019.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      01-NOV-2022
    // 	date last modified      03-NOV-2022
    //  algorithm task          Prep and format death data using previously-prepared datasets for import into CR5db
    //  status                  Completed
    //  objective               To have a dataset with cleaned death data with cancer deaths only for:
	//							(1) importing into main CanReg5 database by death year and 
	//							(2) to be used for death trace-back and
	//							(3) merging with other CR5db records that match.
	//							Note: this process to occur after deaths prep for ASMR analysis for the annual report has been completed
    
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
    log using "`logpath'\DeathCF_2019.smcl", replace
** HEADER -----------------------------------------------------

******************
**  ALL YEARS   **
** Incidence ds **
******************
** LOAD and SAVE the SOURCE+TUMOUR+PATIENT dataset from cancer duplicates V06 process (Source_+Tumour+Patient tables)
insheet using "`datapath'\version07\1-input\2022-10-28_MAIN Source+Tumour+Patient_KWG.txt"

** Format the IDs from the CR5db dataset
format tumourid %14.0g
format tumouridsourcetable %14.0g
format sourcerecordid %16.0g

** JC 31oct2022 - incorrectly formatted Reg #s and an incorrect merge of a patient record found so need to temporarily assign correctly formatted Reg #s until KWG is able to correct these in his main db
generate byte non_numeric_reg = indexnot(registrynumber, "0123456789.-")
count if non_numeric_reg //15 (8)
list registrynumber patientrecordid sourcerecordid cr5id if non_numeric_reg
count if length(registrynumber)<8 //4 (2)
list registrynumber patientrecordid sourcerecordid cr5id if length(registrynumber)<8

replace registrynumber="20220001" if registrynumber=="2020/064"
replace registrynumber="20220002" if registrynumber=="2020/177"
replace registrynumber="20220003" if registrynumber=="2020/178"
replace registrynumber="20220004" if registrynumber=="2020/398"
replace registrynumber="20220005" if registrynumber=="2021/082"
replace registrynumber="20220006" if registrynumber=="2021/090"
replace registrynumber="20220007" if registrynumber=="2021/092"
replace registrynumber="20220008" if registrynumber=="2021/101"
replace registrynumber="20220009" if registrynumber=="" & patientrecordid==2021028901
replace registrynumber="20220010" if registrynumber=="" & patientrecordid==2021500101
replace registrynumber="20220011" if registrynumber=="99" & patientrecordid==2020116401
replace registrynumber="20220012" if registrynumber=="99" & patientrecordid==2020065001
drop patientrecordid
destring registrynumber ,replace

** Remove non-2019 non-2020 cases
count if diagnosisyear==. //1
replace diagnosisyear=2021 if registrynumber==20212236
drop if diagnosisyear!=2019 & diagnosisyear!=2020 //16,746
count //3945

** Remove hyphen in NRN to match with previous and death datasets
count if regexm(nrn,"-") //3924
replace nrn=subinstr(nrn,"-","",.) if regexm(nrn,"-") //3924 changes

** Format variables used in identifying matches
label var nftype "NFType"
label define nftype_lab 1 "Hospital" 2 "Polyclinic/Dist.Hosp." 3 "Lab-Path" 4 "Lab-Cyto" 5 "Lab-Haem" 6 "Imaging" ///
						7 "Private Physician" 8 "Death Certif./Post Mort." 9 "QEH Death Rec Bks" 10 "RT Reg. Bk" ///
						11 "Haem NF" 12 "Bay View Bk" 13 "Other" 14 "Unknown" 15 "NFs" 16 "Phone Call" ///
						17 "MEDDATA" 18 "QEH A&E List" , modify
label values nftype nftype_lab

label var sourcename "SourceName"
label define sourcename_lab 1 "QEH" 2 "Bay View" 3 "Private Physician" 4 "IPS-ARS" 5 "Death Registry" ///
							6 "Polyclinic" 7 "BNR Database" 8 "Other" 9 "Unknown" , modify
label values sourcename sourcename_lab

rename registrynumber pid
gen incids=1
save "`datapath'\version09\3-output\deathcf_prep_cr5" ,replace

clear

*****************
** 2019 + 2020 **
**  Death ds   **
*****************
** Load cancer only identifiable death dataset (created in dofile 5x_prep mort yyyy.do for annual report process)
use "`datapath'\version09\3-output\2019+2020_prep mort_identifiable" ,clear
rename * dd_*
count //1357
gen deathds=1
drop if dd_did=="T2" //29 deleted
rename dd_record_id dd_deathid

append using "`datapath'\version09\3-output\deathcf_prep_cr5"

count //5273

replace nrn=dd_natregno if nrn=="" & dd_natregno!="" //1307
replace dd_fname=firstname if dd_fname=="" & firstname!="" //3382
replace dd_lname=lastname if dd_lname=="" & lastname!="" //3382

** Check NRN is correctly formatted in prep for duplicate check
count if length(nrn)==9 //0
count if length(nrn)==8 //0
count if length(nrn)==7 //0

replace nrn="" if nrn=="9999999999" //563

** Identify possible matches using NRN
//preserve
drop if nrn=="" //remove blank/missing NRNs as these will be flagged as duplicates of each other
// deleted
sort nrn 
quietly by nrn : gen dup = cond(_N==1,0,_n)
sort nrn dd_lname dd_fname pid dd_deathid 
count if dup>0 //2996 - review these in Stata's Browse/Edit window
order pid dd_deathid nftype sourcename nrn dd_fname dd_lname firstname lastname cr5id dd_age age dd_dodyear diagnosisyear dd_coddeath histology
//check there are no duplicate NRNs in the death ds as then it won't merge in 20d_final clean.do
//keep if deathds==1 & dup>0 //20,655 deleted
//restore

drop if dd_dodyear==2020 //643 deleted
** Review and remove death record from NRN matches that have a match with CR5db record that Death Registry as a source and NFType = QEH Death Rec Bks
gen completed=1 if dd_deathid==29559|dd_deathid==27397|dd_deathid==27601|dd_deathid==28516|dd_deathid==28176 ///
				  |dd_deathid==30005|dd_deathid==27071|dd_deathid==27690|dd_deathid==28787|dd_deathid==27947 ///
				  |dd_deathid==28414|dd_deathid==28717|dd_deathid==29830|dd_deathid==28780|dd_deathid==30056 ///
				  |dd_deathid==27372|dd_deathid==28893|dd_deathid==28157|dd_deathid==29059|dd_deathid==28784 ///
				  |dd_deathid==30076|dd_deathid==29585|dd_deathid==30020|dd_deathid==29037|dd_deathid==29704 ///
				  |dd_deathid==28587|dd_deathid==29607|dd_deathid==28969|dd_deathid==27602|dd_deathid==28692 ///
				  |dd_deathid==28830|dd_deathid==30034|dd_deathid==28873|dd_deathid==28550|dd_deathid==29160 ///
				  |dd_deathid==29371|dd_deathid==27250|dd_deathid==27179|dd_deathid==28390|dd_deathid==29882 ///
				  |dd_deathid==28381|dd_deathid==29049|dd_deathid==28837|dd_deathid==28305|dd_deathid==27750 ///
				  |dd_deathid==27280|dd_deathid==27481|dd_deathid==29650|dd_deathid==28265|dd_deathid==29064 ///
				  |dd_deathid==28077|dd_deathid==29151|dd_deathid==28306|dd_deathid==28539|dd_deathid==28031 ///
				  |dd_deathid==28974|dd_deathid==29082|dd_deathid==28883|dd_deathid==28509|dd_deathid==28980 ///
				  |dd_deathid==27788|dd_deathid==29016|dd_deathid==26978|dd_deathid==27329|dd_deathid==29078 ///
				  |dd_deathid==28384|dd_deathid==28835|dd_deathid==27538|dd_deathid==28471|dd_deathid==29758 ///
				  |dd_deathid==28109|dd_deathid==27795|dd_deathid==28032|dd_deathid==27445|dd_deathid==29760 ///
				  |dd_deathid==29096|dd_deathid==29922|dd_deathid==28908|dd_deathid==29021|dd_deathid==28066 ///
				  |dd_deathid==27857|dd_deathid==27191|dd_deathid==28816|dd_deathid==27905|dd_deathid==28701 ///
				  |dd_deathid==28666|dd_deathid==29901|dd_deathid==27855
//88 changes

** Remove cases flagged above as completed so excel list will only have the cases to be searcheddrop
drop if completed==1 //88 deleted
** Remove CR5db records so that the ds only contains 2019 death records that need to be checked by cancer team
drop if pid!=. //3382 deleted
drop pid nftype sourcename nrn firstname lastname cr5id age diagnosisyear histology deathds tumouridsourcetable sourcerecordid stdataabstractor stsourcedate doctor doctoraddress recordnumber cfdiagnosis labnumber surgicalnumber specimen sampletakendate receiveddate reportdate clinicaldetails cytologicalfindings microscopicdescription consultationreport surgicalfindings surgicalfindingsdate physicalexam physicalexamdate imagingresults imagingresultsdate causesofdeath durationofillness onsetdeathinterval certifier admissiondate datefirstconsultation rtregdate streviewer recordstatus checkstatus multipleprimary mpseq mptot updatedate obsoleteflagtumourtable tumourid patientidtumourtable patientrecordidtumourtable tumourupdatedby tumourunduplicationstatus ttdataabstractor ttabstractiondate duplicatecheck parish address primarysite topography morphology laterality behaviour grade basisofdiagnosis tnmcatstage tnmantstage esstnmcatstage esstnmantstage summarystaging incidencedate consultant iccccode icd10 treatment1 treatment1date treatment2 treatment2date treatment3 treatment3date treatment4 treatment4date treatment5 treatment5date othertreatment1 othertreatment2 notreatment1 notreatment2 ttreviewer personsearch middleinitials birthdate sex hospitalnumber residentstatus statuslastcontact datelastcontact dateofdeath comments ptdataabstractor ptcasefindingdate obsoleteflagpatienttable patientupdatedby patientupdatedate patientrecordstatus patientcheckstatus retrievalsource notesseen notesseendate furtherretrievalsource ptreviewer rfalcohol alcoholamount alcoholfreq rfsmoking smokingamount smokingfreq smokingduration smokingdurationfreq non_numeric_reg incids dup completed

** Order ds and then copy and paste into an Excel workbook and save to Sync\Cancer\CanReg5\Deaths for CF\2022\2022-11-03_Thursday
rename dd_* *
gen dod_cr5=string(dod, "%tdCCYY-NN-DD")
replace dod_cr5=subinstr(dod_cr5,"-","",.)
order deathid fname mname lname age dod_cr5 coddeath certifier certifieraddr durationnum durationtxt onsetnumcod1a onsettxtcod1a onsetnumcod1b onsettxtcod1b onsetnumcod1c onsettxtcod1c onsetnumcod1d onsettxtcod1d onsetnumcod2a onsettxtcod2a onsetnumcod2b onsettxtcod2b
sort deathid

** JC 02nov2022: Email reminder to double check if COD contains MP and if not already captured in CR5db to add in a 2nd tumour.
