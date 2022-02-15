** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          006_prep mdb.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      27-JAN-2022
    // 	date last modified      27-JAN-2022
    //  algorithm task          Preparing 2013 MasterDb dataset to extract stage from path reports for research
    //  status                  Completed
    //  objective               To have one dataset with 2013 colorectal data to compare staging with 2018 colorectal data
    //  methods                 Remove non-2013 cases and further check/clean staging variable if needed

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
    log using "`logpath'\006_prep mdb.smcl", replace
** HEADER -----------------------------------------------------

**********************************
** MasterDb CaseFinding Dataset **
**********************************

** Load the excel dataset from MasterDb tblCaseFinding first
import excel using "`datapath'\version08\1-input\20220127tblCaseFinding.xlsx", firstrow
count //4821


** Remove all non-2013 cases
list RegNo if NFDxYear=="2013" //no eligible cases in this dataset

drop if RegNo!="20130010" & RegNo!="20130014" & RegNo!="20130016" & RegNo!="20130020" & RegNo!="20130021" & RegNo!="20130027" & RegNo!="20130032" & RegNo!="20130039" ///
		& RegNo!="20130042" & RegNo!="20130050" & RegNo!="20130053" & RegNo!="20130054" & RegNo!="20130063" & RegNo!="20130065" & RegNo!="20130067" & RegNo!="20130070" ///
		& RegNo!="20130075" & RegNo!="20130076" & RegNo!="20130080" & RegNo!="20130082" & RegNo!="20130087" & RegNo!="20130089" & RegNo!="20130092" & RegNo!="20130101" ///
		& RegNo!="20130104" & RegNo!="20130130" & RegNo!="20130133" & RegNo!="20130134" & RegNo!="20130138" & RegNo!="20130140" & RegNo!="20130141" & RegNo!="20130143" ///
		& RegNo!="20130153" & RegNo!="20130154" & RegNo!="20130158" & RegNo!="20130159" & RegNo!="20130160" & RegNo!="20130161" & RegNo!="20130170" & RegNo!="20130171" ///
		& RegNo!="20130187" & RegNo!="20130191" & RegNo!="20130194" & RegNo!="20130195" & RegNo!="20130196" & RegNo!="20130199" & RegNo!="20130215" & RegNo!="20130216" ///
		& RegNo!="20130227" & RegNo!="20130231" & RegNo!="20130232" & RegNo!="20130235" & RegNo!="20130236" & RegNo!="20130247" & RegNo!="20130249" & RegNo!="20130259" ///
		& RegNo!="20130266" & RegNo!="20130267" & RegNo!="20130272" & RegNo!="20130276" & RegNo!="20130277" & RegNo!="20130282" & RegNo!="20130283" & RegNo!="20130292" ///
		& RegNo!="20130298" & RegNo!="20130299" & RegNo!="20130304" & RegNo!="20130305" & RegNo!="20130306" & RegNo!="20130308" & RegNo!="20130309" & RegNo!="20130328" ///
		& RegNo!="20130346" & RegNo!="20130348" & RegNo!="20130350" & RegNo!="20130355" & RegNo!="20130358" & RegNo!="20130360" & RegNo!="20130368" & RegNo!="20130380" ///
		& RegNo!="20130387" & RegNo!="20130388" & RegNo!="20130391" & RegNo!="20130396" & RegNo!="20130400" & RegNo!="20130508" & RegNo!="20130511" & RegNo!="20130512" ///
		& RegNo!="20130519" & RegNo!="20130528" & RegNo!="20130541" & RegNo!="20130548" & RegNo!="20130558" & RegNo!="20130560" & RegNo!="20130561" & RegNo!="20130562" ///
		& RegNo!="20130571" & RegNo!="20130572" & RegNo!="20130574" & RegNo!="20130578" & RegNo!="20130582" & RegNo!="20130587" & RegNo!="20130596" & RegNo!="20130597" ///
		& RegNo!="20130605" & RegNo!="20130606" & RegNo!="20130618" & RegNo!="20130619" & RegNo!="20130621" & RegNo!="20130631" & RegNo!="20130632" & RegNo!="20130634" ///
		& RegNo!="20130636" & RegNo!="20130637" & RegNo!="20130638" & RegNo!="20130647" & RegNo!="20130648" & RegNo!="20130658" & RegNo!="20130663" & RegNo!="20130668" ///
		& RegNo!="20130680" & RegNo!="20130682" & RegNo!="20130689" & RegNo!="20130690" & RegNo!="20130693" & RegNo!="20130695" & RegNo!="20130697" & RegNo!="20130700" ///
		& RegNo!="20130703" & RegNo!="20130707" & RegNo!="20130709" & RegNo!="20130711" & RegNo!="20130713" & RegNo!="20130719" & RegNo!="20130720" & RegNo!="20130731" ///
		& RegNo!="20130742" & RegNo!="20130750" & RegNo!="20130751" & RegNo!="20130754" & RegNo!="20130757" & RegNo!="20130772" & RegNo!="20130797" & RegNo!="20130798" ///
		& RegNo!="20130813" & RegNo!="20130817" & RegNo!="20130820" & RegNo!="20131001" & RegNo!="20139983" & RegNo!="20139992" & RegNo!="20140032" & RegNo!="20140127" ///
		& RegNo!="20140154" & RegNo!="20140268" & RegNo!="20145009"
		
count //0

clear

** Load the excel dataset from MasterDb tblCaseFinding_2009 now
import excel using "`datapath'\version08\1-input\20220127tblCaseFinding_2009.xlsx", firstrow
count //4171

** Remove all non-2013 cases
list RegNo if DxYear=="2013" //no eligible cases in this dataset
count if DxYear=="2013" & RegNo!="" //1713

drop if RegNo!="20130010" & RegNo!="20130014" & RegNo!="20130016" & RegNo!="20130020" & RegNo!="20130021" & RegNo!="20130027" & RegNo!="20130032" & RegNo!="20130039" ///
		& RegNo!="20130042" & RegNo!="20130050" & RegNo!="20130053" & RegNo!="20130054" & RegNo!="20130063" & RegNo!="20130065" & RegNo!="20130067" & RegNo!="20130070" ///
		& RegNo!="20130075" & RegNo!="20130076" & RegNo!="20130080" & RegNo!="20130082" & RegNo!="20130087" & RegNo!="20130089" & RegNo!="20130092" & RegNo!="20130101" ///
		& RegNo!="20130104" & RegNo!="20130130" & RegNo!="20130133" & RegNo!="20130134" & RegNo!="20130138" & RegNo!="20130140" & RegNo!="20130141" & RegNo!="20130143" ///
		& RegNo!="20130153" & RegNo!="20130154" & RegNo!="20130158" & RegNo!="20130159" & RegNo!="20130160" & RegNo!="20130161" & RegNo!="20130170" & RegNo!="20130171" ///
		& RegNo!="20130187" & RegNo!="20130191" & RegNo!="20130194" & RegNo!="20130195" & RegNo!="20130196" & RegNo!="20130199" & RegNo!="20130215" & RegNo!="20130216" ///
		& RegNo!="20130227" & RegNo!="20130231" & RegNo!="20130232" & RegNo!="20130235" & RegNo!="20130236" & RegNo!="20130247" & RegNo!="20130249" & RegNo!="20130259" ///
		& RegNo!="20130266" & RegNo!="20130267" & RegNo!="20130272" & RegNo!="20130276" & RegNo!="20130277" & RegNo!="20130282" & RegNo!="20130283" & RegNo!="20130292" ///
		& RegNo!="20130298" & RegNo!="20130299" & RegNo!="20130304" & RegNo!="20130305" & RegNo!="20130306" & RegNo!="20130308" & RegNo!="20130309" & RegNo!="20130328" ///
		& RegNo!="20130346" & RegNo!="20130348" & RegNo!="20130350" & RegNo!="20130355" & RegNo!="20130358" & RegNo!="20130360" & RegNo!="20130368" & RegNo!="20130380" ///
		& RegNo!="20130387" & RegNo!="20130388" & RegNo!="20130391" & RegNo!="20130396" & RegNo!="20130400" & RegNo!="20130508" & RegNo!="20130511" & RegNo!="20130512" ///
		& RegNo!="20130519" & RegNo!="20130528" & RegNo!="20130541" & RegNo!="20130548" & RegNo!="20130558" & RegNo!="20130560" & RegNo!="20130561" & RegNo!="20130562" ///
		& RegNo!="20130571" & RegNo!="20130572" & RegNo!="20130574" & RegNo!="20130578" & RegNo!="20130582" & RegNo!="20130587" & RegNo!="20130596" & RegNo!="20130597" ///
		& RegNo!="20130605" & RegNo!="20130606" & RegNo!="20130618" & RegNo!="20130619" & RegNo!="20130621" & RegNo!="20130631" & RegNo!="20130632" & RegNo!="20130634" ///
		& RegNo!="20130636" & RegNo!="20130637" & RegNo!="20130638" & RegNo!="20130647" & RegNo!="20130648" & RegNo!="20130658" & RegNo!="20130663" & RegNo!="20130668" ///
		& RegNo!="20130680" & RegNo!="20130682" & RegNo!="20130689" & RegNo!="20130690" & RegNo!="20130693" & RegNo!="20130695" & RegNo!="20130697" & RegNo!="20130700" ///
		& RegNo!="20130703" & RegNo!="20130707" & RegNo!="20130709" & RegNo!="20130711" & RegNo!="20130713" & RegNo!="20130719" & RegNo!="20130720" & RegNo!="20130731" ///
		& RegNo!="20130742" & RegNo!="20130750" & RegNo!="20130751" & RegNo!="20130754" & RegNo!="20130757" & RegNo!="20130772" & RegNo!="20130797" & RegNo!="20130798" ///
		& RegNo!="20130813" & RegNo!="20130817" & RegNo!="20130820" & RegNo!="20131001" & RegNo!="20139983" & RegNo!="20139992" & RegNo!="20140032" & RegNo!="20140127" ///
		& RegNo!="20140154" & RegNo!="20140268" & RegNo!="20145009"
//3828 deleted

count //343

** Determine % of eligible cases where the notes were seen (2013)
preserve

gen obsid = _n
rename RegNo pid
rename No mdbid
rename NotesSeen notesseen
gen cr5id=""

//replace cr5id="" if cr5id!="" //2 changes

duplicates tag pid, gen(dup)
count if dup>0 //315
count if dup==0 //28
//list pid obsid cr5id dup if dup>0, nolabel sepby(pid)
//list pid obsid cr5id dup if dup==0, nolabel sepby(pid)

replace cr5id="T1S1" if dup==0 //28 changes

drop dup
sort pid
quietly by pid :  gen dup = cond(_N==1,0,_n)
count if dup==0 //28
count if dup>0 //315

//list pid obsid cr5id dup if dup>0, nolabel sepby(pid)
replace cr5id="T1S1" if dup==1 //120
replace cr5id="T1S2" if dup==2 //120
replace cr5id="T1S3" if dup==3 //55
replace cr5id="T1S4" if dup==4 //16
replace cr5id="T1S5" if dup==5 //4

count if cr5id=="" //0
tab cr5id
tab notesseen if cr5id=="T1S1"

count //343

** Save this colorectal NotesSeen dataset
save "`datapath'\version08\3-output\2013_colorectal_notesseen", replace
label data "2013 BNR-Cancer Notes Seen data - COLORECTAL MasterDb Dataset"
note: TS This dataset was used for research paper on late stage presentation
note: TS Excludes all sites except C18-C20

restore


** Remove all non-pathology cases
drop if NFType!="Pathology Report" & NFType!="Post Mortem Report" //152 deleted

** Count the total number of colorectal path reports
count //191 path rpts for 2013 colorectal cases
gen tot_pathrpt=_N //save this value for the results table

** Count the total number of colorectal path reports with TNM stage listed
count if regexm(DiagnosisImpression, "pT") //21
egen tot_tnmdx=count(No) if regexm(DiagnosisImpression, "pT") //save this value for the results table
//list RegNo DiagnosisImpression if regexm(DiagnosisImpression, "pT"), string(120)

count if regexm(MD, "pT") & !strmatch(DiagnosisImpression, "*pT*") //5
list RegNo DiagnosisImpression MD if regexm(MD, "pT") & !strmatch(DiagnosisImpression, "*pT*")
egen tot_tnmmd=count(No) if regexm(MD, "pT") & !strmatch(DiagnosisImpression, "*pT*")

count if regexm(MD, "pT") //26
count if regexm(MD, "TNM") & !strmatch(MD, "*pT*") //1
count if regexm(MD, "tage") & !strmatch(MD, "*pT*") //13

count if regexm(MD, "pT") | (regexm(MD, "tage") & !strmatch(MD, "*pT*")) //39
egen tot_tnm=count(No) if regexm(MD, "pT") | (regexm(MD, "tage") & !strmatch(MD, "*pT*"))


preserve
contract tot_pathrpt tot_tnm
drop _freq
gen percent_tnm=(tot_tnm/tot_pathrpt)*100
replace percent_tnm=round(percent_tnm, 0.15)
gen year=2013
order year tot_tnm tot_pathrpt percent_tnm
drop if tot_tnm==. //1 deleted
save "`datapath'\version08\2-working\pathrpts_2013" ,replace
restore

** Save this colorectal dataset
save "`datapath'\version08\3-output\2013_colorectal_pathrpts", replace
label data "2013 BNR-Cancer Pathology Report data - COLORECTAL MasterDb Dataset"
note: TS This dataset was used for research paper on late stage presentation
note: TS Excludes all sites except C18-C20
