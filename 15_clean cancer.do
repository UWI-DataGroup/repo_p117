** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          15_clean cancer.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      02-DEC-2019
    // 	date last modified      02-DEC-2019
    //  algorithm task          Preparing 2015 cancer dataset for cleaning; Preparing previous years for combined dataset
    //  status                  Completed
    //  objective               To have one dataset with cleaned and grouped 2008, 2013, 2014 data for inclusion in 2015 cancer report.
    //  methods                 Clean and update all years' data using IARCcrgTools Check and Multiple Primary

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
    log using "`logpath'\15_clean cancer.smcl", replace
** HEADER -----------------------------------------------------

CLEAN IN 2015 DOFILE: 20150037 missed 2014 case abs as 2015 (see MasterDb frmCF_2014 #3649.)
20155112 missed 2014 case abs as 2015
20150258 missed 2014 case abs as 2015
APPEND AND RE-GENERATE 30_report.do based on this combined ds (2008, 2013, 2014, 2015)

Missed abstracted 2008 case 20150569.
Missed abstracted 2013 case 20155220.
Missed merge 2013 case 20155202 - drop from dataset (see 20141130)
Missed merge 2013 case 20150270 - drop from dataset (see 20130648)
Missed merge 2013 case 20150396 - drop from dataset after updating mname ("I"), dlc ("20150519") (see pid 20130804)
Missed merge 2013 case 20150399 - drop from dataset after updating dlc ("20150115") (see pid 20141129)
Missed merge 2014 case 20150559 - drop from dataset (see 20141434)

Check top=619 and comments=PSA to see if to change BOD=4(lab test) if BOD>3 and !=9
Check top=ovary and morph=8000-8799 and laterality!=4
Check BOD=1  (look at comments to see if pt notes seen and pt admitted with dx then BOD=9)
Check BOD=7 if top=421 (if bone marrow confirms leukemia then bod=7: see IARC manual pg.20)
Check BOD=5 if top=421 (if no bone marrow or dx confirmed by blood results: see IARC manual pg. 19/20)