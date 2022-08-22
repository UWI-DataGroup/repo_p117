** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          22a_MIRs prep_2016.do
	//  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      22-AUG-2022
    // 	date last modified      22-AUG-2022
    //  algorithm task          Creating IARC site variable on 2016 mortality dataset in preparation for mortality:incidence ratio analysis
    //  status                  Completed
    //  objective               To have cause(s) of death assigned the same site codes as the incidence data
	//							To have multiple cancer causes of death identified and labelled with the correct site code
    //  methods                 Using Angie's previous site variable to transcribe into the IARC site variable

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
    log using "`logpath'\22a_MIRs prep_2016.smcl", replace
** HEADER -----------------------------------------------------


* ************************************************************************
* PREP AND FORMAT: MORTALITY DATA
**************************************************************************
use "`datapath'\version09\3-output\2016_prep mort_identifiable", clear

** Ensure all deaths have an IARC site code assigned
tab siteiarc ,m
count if siteiarc==. //0

tab sitecr5db ,m
count if sitecr5db==. //0

** Create death dataset with CODs assigned a site code
save "`datapath'\version09\2-working\2016_mir_mort_prep", replace

** Create variable for site groupings by sex to be used for M:I ratios
***********
** MALES **
***********
** Mouth & pharynx (C00-14)
count if sitecr5db==1 & sex==2
gen cases = r(N) if sitecr5db==1 & sex==2

** Oesophagus (C15)
count if sitecr5db==2 & sex==2
replace cases = r(N) if sitecr5db==2 & sex==2

** Stomach (C16)
count if sitecr5db==3 & sex==2
replace cases = r(N) if sitecr5db==3 & sex==2

** Colon, rectum, anus (C18-21)
count if sitecr5db==4 & sex==2
replace cases = r(N) if sitecr5db==4 & sex==2

** Liver (C22)
count if sitecr5db==5 & sex==2
replace cases = r(N) if sitecr5db==5 & sex==2

** Pancreas (C25)
count if sitecr5db==6 & sex==2
replace cases = r(N) if sitecr5db==6 & sex==2

** Larynx (C32)
count if sitecr5db==7 & sex==2
replace cases = r(N) if sitecr5db==7 & sex==2

** Lung, trachea, bronchus (C33-34)
count if sitecr5db==8 & sex==2
replace cases = r(N) if sitecr5db==8 & sex==2

** Melanoma of skin (C43)
count if sitecr5db==9 & sex==2
replace cases = r(N) if sitecr5db==9 & sex==2

** Prostate (C61)
count if sitecr5db==14 & sex==2
replace cases = r(N) if sitecr5db==14 & sex==2

** Testis (C62)
count if sitecr5db==15 & sex==2
replace cases = r(N) if sitecr5db==15 & sex==2

** Kidney & urinary NOS (C64-66,68)
count if sitecr5db==16 & sex==2
replace cases = r(N) if sitecr5db==16 & sex==2

** Bladder (C67)
count if sitecr5db==17 & sex==2
replace cases = r(N) if sitecr5db==17 & sex==2

** Brain, nervous system (C70-72)
count if sitecr5db==18 & sex==2
replace cases = r(N) if sitecr5db==18 & sex==2

** Thyroid (C73)
count if sitecr5db==19 & sex==2
replace cases = r(N) if sitecr5db==19 & sex==2

** Lymphoma (C81-85,88,90,96)
count if sitecr5db==21 & sex==2
replace cases = r(N) if sitecr5db==21 & sex==2

** Leukaemia (C91-95)
count if sitecr5db==22 & sex==2
replace cases = r(N) if sitecr5db==22 & sex==2

*************
** FEMALES **
*************
** Mouth & pharynx (C00-14)
count if sitecr5db==1 & sex==1
replace cases = r(N) if sitecr5db==1 & sex==1

** Oesophagus (C15)
count if sitecr5db==2 & sex==1
replace cases = r(N) if sitecr5db==2 & sex==1

** Stomach (C16)
count if sitecr5db==3 & sex==1
replace cases = r(N) if sitecr5db==3 & sex==1

** Colon, rectum, anus (C18-21)
count if sitecr5db==4 & sex==1
replace cases = r(N) if sitecr5db==4 & sex==1

** Liver (C22)
count if sitecr5db==5 & sex==1
replace cases = r(N) if sitecr5db==5 & sex==1

** Pancreas (C25)
count if sitecr5db==6 & sex==1
replace cases = r(N) if sitecr5db==6 & sex==1

** Larynx (C32)
count if sitecr5db==7 & sex==1
replace cases = r(N) if sitecr5db==7 & sex==1

** Lung, trachea, bronchus (C33-34)
count if sitecr5db==8 & sex==1
replace cases = r(N) if sitecr5db==8 & sex==1

** Melanoma of skin (C43)
count if sitecr5db==9 & sex==1
replace cases = r(N) if sitecr5db==9 & sex==1

** Breast (C50)
count if sitecr5db==10 & sex==1
replace cases = r(N) if sitecr5db==10 & sex==1

** Cervix (C53)
count if sitecr5db==11 & sex==1
replace cases = r(N) if sitecr5db==11 & sex==1

** Corpus & Uterus NOS (C54-55)
count if sitecr5db==12 & sex==1
replace cases = r(N) if sitecr5db==12 & sex==1

** Ovary & adnexa (C56)
count if sitecr5db==13 & sex==1
replace cases = r(N) if sitecr5db==13 & sex==1

** Kidney & urinary NOS (C64-66,68)
count if sitecr5db==16 & sex==1
replace cases = r(N) if sitecr5db==16 & sex==1

** Bladder (C67)
count if sitecr5db==17 & sex==1
replace cases = r(N) if sitecr5db==17 & sex==1

** Brain, nervous system (C70-72)
count if sitecr5db==18 & sex==1
replace cases = r(N) if sitecr5db==18 & sex==1

** Thyroid (C73)
count if sitecr5db==19 & sex==1
replace cases = r(N) if sitecr5db==19 & sex==1

** Lymphoma (C81-85,88,90,96)
count if sitecr5db==21 & sex==1
replace cases = r(N) if sitecr5db==21 & sex==1

** Leukaemia (C91-95)
count if sitecr5db==22 & sex==1
replace cases = r(N) if sitecr5db==22 & sex==1


** Condense dataset
drop if cases==.
sort sitecr5db sex
contract dodyear sitecr5db sex cases
drop _freq
order dodyear sitecr5db sex cases

gen mortds=1

** Create death dataset to use for mortality:incidence ratio
save "`datapath'\version09\2-working\2016_mir_mort", replace

clear

* ************************************************************************
* PREP AND FORMAT: INCIDENCE DATA
**************************************************************************
use "`datapath'\version09\3-output\2008_2013-2018_cancer_reportable_nonsurvival_identifiable", clear

drop if dxyr!=2016
count if sitecr5db==. //0

tab sitecr5db ,m
count if sitecr5db==. //0

** Create death dataset with CODs assigned a site code
save "`datapath'\version09\2-working\2016_mir_incid_prep", replace

** Create variable for site groupings by sex to be used for M:I ratios
***********
** MALES **
***********
** Mouth & pharynx (C00-14)
count if sitecr5db==1 & sex==2
gen cases = r(N) if sitecr5db==1 & sex==2

** Oesophagus (C15)
count if sitecr5db==2 & sex==2
replace cases = r(N) if sitecr5db==2 & sex==2

** Stomach (C16)
count if sitecr5db==3 & sex==2
replace cases = r(N) if sitecr5db==3 & sex==2

** Colon, rectum, anus (C18-21)
count if sitecr5db==4 & sex==2
replace cases = r(N) if sitecr5db==4 & sex==2

** Liver (C22)
count if sitecr5db==5 & sex==2
replace cases = r(N) if sitecr5db==5 & sex==2

** Pancreas (C25)
count if sitecr5db==6 & sex==2
replace cases = r(N) if sitecr5db==6 & sex==2

** Larynx (C32)
count if sitecr5db==7 & sex==2
replace cases = r(N) if sitecr5db==7 & sex==2

** Lung, trachea, bronchus (C33-34)
count if sitecr5db==8 & sex==2
replace cases = r(N) if sitecr5db==8 & sex==2

** Melanoma of skin (C43)
count if sitecr5db==9 & sex==2
replace cases = r(N) if sitecr5db==9 & sex==2

** Prostate (C61)
count if sitecr5db==14 & sex==2
replace cases = r(N) if sitecr5db==14 & sex==2

** Testis (C62)
count if sitecr5db==15 & sex==2
replace cases = r(N) if sitecr5db==15 & sex==2

** Kidney & urinary NOS (C64-66,68)
count if sitecr5db==16 & sex==2
replace cases = r(N) if sitecr5db==16 & sex==2

** Bladder (C67)
count if sitecr5db==17 & sex==2
replace cases = r(N) if sitecr5db==17 & sex==2

** Brain, nervous system (C70-72)
count if sitecr5db==18 & sex==2
replace cases = r(N) if sitecr5db==18 & sex==2

** Thyroid (C73)
count if sitecr5db==19 & sex==2
replace cases = r(N) if sitecr5db==19 & sex==2

** Lymphoma (C81-85,88,90,96)
count if sitecr5db==21 & sex==2
replace cases = r(N) if sitecr5db==21 & sex==2

** Leukaemia (C91-95)
count if sitecr5db==22 & sex==2
replace cases = r(N) if sitecr5db==22 & sex==2

*************
** FEMALES **
*************
** Mouth & pharynx (C00-14)
count if sitecr5db==1 & sex==1
replace cases = r(N) if sitecr5db==1 & sex==1

** Oesophagus (C15)
count if sitecr5db==2 & sex==1
replace cases = r(N) if sitecr5db==2 & sex==1

** Stomach (C16)
count if sitecr5db==3 & sex==1
replace cases = r(N) if sitecr5db==3 & sex==1

** Colon, rectum, anus (C18-21)
count if sitecr5db==4 & sex==1
replace cases = r(N) if sitecr5db==4 & sex==1

** Liver (C22)
count if sitecr5db==5 & sex==1
replace cases = r(N) if sitecr5db==5 & sex==1

** Pancreas (C25)
count if sitecr5db==6 & sex==1
replace cases = r(N) if sitecr5db==6 & sex==1

** Larynx (C32)
count if sitecr5db==7 & sex==1
replace cases = r(N) if sitecr5db==7 & sex==1

** Lung, trachea, bronchus (C33-34)
count if sitecr5db==8 & sex==1
replace cases = r(N) if sitecr5db==8 & sex==1

** Melanoma of skin (C43)
count if sitecr5db==9 & sex==1
replace cases = r(N) if sitecr5db==9 & sex==1

** Breast (C50)
count if sitecr5db==10 & sex==1
replace cases = r(N) if sitecr5db==10 & sex==1

** Cervix (C53)
count if sitecr5db==11 & sex==1
replace cases = r(N) if sitecr5db==11 & sex==1

** Corpus & Uterus NOS (C54-55)
count if sitecr5db==12 & sex==1
replace cases = r(N) if sitecr5db==12 & sex==1

** Ovary & adnexa (C56)
count if sitecr5db==13 & sex==1
replace cases = r(N) if sitecr5db==13 & sex==1

** Kidney & urinary NOS (C64-66,68)
count if sitecr5db==16 & sex==1
replace cases = r(N) if sitecr5db==16 & sex==1

** Bladder (C67)
count if sitecr5db==17 & sex==1
replace cases = r(N) if sitecr5db==17 & sex==1

** Brain, nervous system (C70-72)
count if sitecr5db==18 & sex==1
replace cases = r(N) if sitecr5db==18 & sex==1

** Thyroid (C73)
count if sitecr5db==19 & sex==1
replace cases = r(N) if sitecr5db==19 & sex==1

** Lymphoma (C81-85,88,90,96)
count if sitecr5db==21 & sex==1
replace cases = r(N) if sitecr5db==21 & sex==1

** Leukaemia (C91-95)
count if sitecr5db==22 & sex==1
replace cases = r(N) if sitecr5db==22 & sex==1


** Condense dataset
drop if cases==.
sort sitecr5db sex
contract dxyr sitecr5db sex cases
drop _freq
order dxyr sitecr5db sex cases

gen incid=1

** Create death dataset to use for mortality:incidence ratio
save "`datapath'\version09\2-working\2016_mir_incid", replace
