** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          68_MIR.do
	//  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      06-OCT-2021
    // 	date last modified      07-OCT-2021
    //  algorithm task          Creating for mortality:incidence ratios per year then grouped for 2013-2015
    //  status                  Completed
    //  objective               To assess completeness of incidence data for BNR-Cancer for 2013-2015
    //  methods                 Using IARC's CI5 M/I ratio, i.e. The number of cancer deaths/number of cancer cases

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
    log using "`logpath'\68_MIR.smcl", replace
** HEADER -----------------------------------------------------


* ************************************************************************
* PREP AND FORMAT DATA - MORTALITY:INCIDENCE RATIO
**************************************************************************
** Creating variable to assess MIR for 2013 only
use "`datapath'\version02\2-working\2013_mir_mort", clear
append using "`datapath'\version02\2-working\2013_mir_incid"

gen mort_2013 = cases if mort==1 & year==2013
fillmissing mort_2013 if sitecr5db==1 & sex==1
fillmissing mort_2013 if sitecr5db==1 & sex==2
fillmissing mort_2013 if sitecr5db==2 & sex==1
fillmissing mort_2013 if sitecr5db==2 & sex==2
fillmissing mort_2013 if sitecr5db==3 & sex==1
fillmissing mort_2013 if sitecr5db==3 & sex==2
fillmissing mort_2013 if sitecr5db==4 & sex==1
fillmissing mort_2013 if sitecr5db==4 & sex==2
fillmissing mort_2013 if sitecr5db==5 & sex==1
fillmissing mort_2013 if sitecr5db==5 & sex==2
fillmissing mort_2013 if sitecr5db==6 & sex==1
fillmissing mort_2013 if sitecr5db==6 & sex==2
fillmissing mort_2013 if sitecr5db==7 & sex==1
fillmissing mort_2013 if sitecr5db==7 & sex==2
fillmissing mort_2013 if sitecr5db==8 & sex==1
fillmissing mort_2013 if sitecr5db==8 & sex==2
fillmissing mort_2013 if sitecr5db==9 & sex==1
fillmissing mort_2013 if sitecr5db==9 & sex==2
fillmissing mort_2013 if sitecr5db==10 & sex==1
fillmissing mort_2013 if sitecr5db==10 & sex==2
fillmissing mort_2013 if sitecr5db==11 & sex==1
fillmissing mort_2013 if sitecr5db==11 & sex==2
fillmissing mort_2013 if sitecr5db==12 & sex==1
fillmissing mort_2013 if sitecr5db==12 & sex==2
fillmissing mort_2013 if sitecr5db==13 & sex==1
fillmissing mort_2013 if sitecr5db==13 & sex==2
fillmissing mort_2013 if sitecr5db==14 & sex==1
fillmissing mort_2013 if sitecr5db==14 & sex==2
fillmissing mort_2013 if sitecr5db==15 & sex==1
fillmissing mort_2013 if sitecr5db==15 & sex==2
fillmissing mort_2013 if sitecr5db==16 & sex==1
fillmissing mort_2013 if sitecr5db==16 & sex==2
fillmissing mort_2013 if sitecr5db==17 & sex==1
fillmissing mort_2013 if sitecr5db==17 & sex==2
fillmissing mort_2013 if sitecr5db==18 & sex==1
fillmissing mort_2013 if sitecr5db==18 & sex==2
fillmissing mort_2013 if sitecr5db==19 & sex==1
fillmissing mort_2013 if sitecr5db==19 & sex==2
fillmissing mort_2013 if sitecr5db==21 & sex==1
fillmissing mort_2013 if sitecr5db==21 & sex==2
fillmissing mort_2013 if sitecr5db==22 & sex==1
fillmissing mort_2013 if sitecr5db==22 & sex==2

gen incid_2013 = cases if incid==1 & dxyr==2013
fillmissing incid_2013 if sitecr5db==1 & sex==1
fillmissing incid_2013 if sitecr5db==1 & sex==2
fillmissing incid_2013 if sitecr5db==2 & sex==1
fillmissing incid_2013 if sitecr5db==2 & sex==2
fillmissing incid_2013 if sitecr5db==3 & sex==1
fillmissing incid_2013 if sitecr5db==3 & sex==2
fillmissing incid_2013 if sitecr5db==4 & sex==1
fillmissing incid_2013 if sitecr5db==4 & sex==2
fillmissing incid_2013 if sitecr5db==5 & sex==1
fillmissing incid_2013 if sitecr5db==5 & sex==2
fillmissing incid_2013 if sitecr5db==6 & sex==1
fillmissing incid_2013 if sitecr5db==6 & sex==2
fillmissing incid_2013 if sitecr5db==7 & sex==1
fillmissing incid_2013 if sitecr5db==7 & sex==2
fillmissing incid_2013 if sitecr5db==8 & sex==1
fillmissing incid_2013 if sitecr5db==8 & sex==2
fillmissing incid_2013 if sitecr5db==9 & sex==1
fillmissing incid_2013 if sitecr5db==9 & sex==2
fillmissing incid_2013 if sitecr5db==10 & sex==1
fillmissing incid_2013 if sitecr5db==10 & sex==2
fillmissing incid_2013 if sitecr5db==11 & sex==1
fillmissing incid_2013 if sitecr5db==11 & sex==2
fillmissing incid_2013 if sitecr5db==12 & sex==1
fillmissing incid_2013 if sitecr5db==12 & sex==2
fillmissing incid_2013 if sitecr5db==13 & sex==1
fillmissing incid_2013 if sitecr5db==13 & sex==2
fillmissing incid_2013 if sitecr5db==14 & sex==1
fillmissing incid_2013 if sitecr5db==14 & sex==2
fillmissing incid_2013 if sitecr5db==15 & sex==1
fillmissing incid_2013 if sitecr5db==15 & sex==2
fillmissing incid_2013 if sitecr5db==16 & sex==1
fillmissing incid_2013 if sitecr5db==16 & sex==2
fillmissing incid_2013 if sitecr5db==17 & sex==1
fillmissing incid_2013 if sitecr5db==17 & sex==2
fillmissing incid_2013 if sitecr5db==18 & sex==1
fillmissing incid_2013 if sitecr5db==18 & sex==2
fillmissing incid_2013 if sitecr5db==19 & sex==1
fillmissing incid_2013 if sitecr5db==19 & sex==2
fillmissing incid_2013 if sitecr5db==21 & sex==1
fillmissing incid_2013 if sitecr5db==21 & sex==2
fillmissing incid_2013 if sitecr5db==22 & sex==1
fillmissing incid_2013 if sitecr5db==22 & sex==2

gen mir_2013 = mort_2013/incid_2013 if sitecr5db==1
replace mir_2013 = mort_2013/incid_2013 if sitecr5db==2
replace mir_2013 = mort_2013/incid_2013 if sitecr5db==3
replace mir_2013 = mort_2013/incid_2013 if sitecr5db==4
replace mir_2013 = mort_2013/incid_2013 if sitecr5db==5
replace mir_2013 = mort_2013/incid_2013 if sitecr5db==6
replace mir_2013 = mort_2013/incid_2013 if sitecr5db==7
replace mir_2013 = mort_2013/incid_2013 if sitecr5db==8
replace mir_2013 = mort_2013/incid_2013 if sitecr5db==9
replace mir_2013 = mort_2013/incid_2013 if sitecr5db==10
replace mir_2013 = mort_2013/incid_2013 if sitecr5db==11
replace mir_2013 = mort_2013/incid_2013 if sitecr5db==12
replace mir_2013 = mort_2013/incid_2013 if sitecr5db==13
replace mir_2013 = mort_2013/incid_2013 if sitecr5db==14
replace mir_2013 = mort_2013/incid_2013 if sitecr5db==15
replace mir_2013 = mort_2013/incid_2013 if sitecr5db==16
replace mir_2013 = mort_2013/incid_2013 if sitecr5db==17
replace mir_2013 = mort_2013/incid_2013 if sitecr5db==18
replace mir_2013 = mort_2013/incid_2013 if sitecr5db==19
replace mir_2013 = mort_2013/incid_2013 if sitecr5db==21
replace mir_2013 = mort_2013/incid_2013 if sitecr5db==22


** Creating variable to assess MIR for 2014 only
append using "`datapath'\version02\2-working\2014_mir_mort"
append using "`datapath'\version02\2-working\2014_mir_incid"

gen mort_2014 = cases if mort==1 & dodyear==2014
fillmissing mort_2014 if sitecr5db==1 & sex==1
fillmissing mort_2014 if sitecr5db==1 & sex==2
fillmissing mort_2014 if sitecr5db==2 & sex==1
fillmissing mort_2014 if sitecr5db==2 & sex==2
fillmissing mort_2014 if sitecr5db==3 & sex==1
fillmissing mort_2014 if sitecr5db==3 & sex==2
fillmissing mort_2014 if sitecr5db==4 & sex==1
fillmissing mort_2014 if sitecr5db==4 & sex==2
fillmissing mort_2014 if sitecr5db==5 & sex==1
fillmissing mort_2014 if sitecr5db==5 & sex==2
fillmissing mort_2014 if sitecr5db==6 & sex==1
fillmissing mort_2014 if sitecr5db==6 & sex==2
fillmissing mort_2014 if sitecr5db==7 & sex==1
fillmissing mort_2014 if sitecr5db==7 & sex==2
fillmissing mort_2014 if sitecr5db==8 & sex==1
fillmissing mort_2014 if sitecr5db==8 & sex==2
fillmissing mort_2014 if sitecr5db==9 & sex==1
fillmissing mort_2014 if sitecr5db==9 & sex==2
fillmissing mort_2014 if sitecr5db==10 & sex==1
fillmissing mort_2014 if sitecr5db==10 & sex==2
fillmissing mort_2014 if sitecr5db==11 & sex==1
fillmissing mort_2014 if sitecr5db==11 & sex==2
fillmissing mort_2014 if sitecr5db==12 & sex==1
fillmissing mort_2014 if sitecr5db==12 & sex==2
fillmissing mort_2014 if sitecr5db==13 & sex==1
fillmissing mort_2014 if sitecr5db==13 & sex==2
fillmissing mort_2014 if sitecr5db==14 & sex==1
fillmissing mort_2014 if sitecr5db==14 & sex==2
fillmissing mort_2014 if sitecr5db==15 & sex==1
fillmissing mort_2014 if sitecr5db==15 & sex==2
fillmissing mort_2014 if sitecr5db==16 & sex==1
fillmissing mort_2014 if sitecr5db==16 & sex==2
fillmissing mort_2014 if sitecr5db==17 & sex==1
fillmissing mort_2014 if sitecr5db==17 & sex==2
fillmissing mort_2014 if sitecr5db==18 & sex==1
fillmissing mort_2014 if sitecr5db==18 & sex==2
fillmissing mort_2014 if sitecr5db==19 & sex==1
fillmissing mort_2014 if sitecr5db==19 & sex==2
fillmissing mort_2014 if sitecr5db==21 & sex==1
fillmissing mort_2014 if sitecr5db==21 & sex==2
fillmissing mort_2014 if sitecr5db==22 & sex==1
fillmissing mort_2014 if sitecr5db==22 & sex==2

gen incid_2014 = cases if incid==1 & dxyr==2014
fillmissing incid_2014 if sitecr5db==1 & sex==1
fillmissing incid_2014 if sitecr5db==1 & sex==2
fillmissing incid_2014 if sitecr5db==2 & sex==1
fillmissing incid_2014 if sitecr5db==2 & sex==2
fillmissing incid_2014 if sitecr5db==3 & sex==1
fillmissing incid_2014 if sitecr5db==3 & sex==2
fillmissing incid_2014 if sitecr5db==4 & sex==1
fillmissing incid_2014 if sitecr5db==4 & sex==2
fillmissing incid_2014 if sitecr5db==5 & sex==1
fillmissing incid_2014 if sitecr5db==5 & sex==2
fillmissing incid_2014 if sitecr5db==6 & sex==1
fillmissing incid_2014 if sitecr5db==6 & sex==2
fillmissing incid_2014 if sitecr5db==7 & sex==1
fillmissing incid_2014 if sitecr5db==7 & sex==2
fillmissing incid_2014 if sitecr5db==8 & sex==1
fillmissing incid_2014 if sitecr5db==8 & sex==2
fillmissing incid_2014 if sitecr5db==9 & sex==1
fillmissing incid_2014 if sitecr5db==9 & sex==2
fillmissing incid_2014 if sitecr5db==10 & sex==1
fillmissing incid_2014 if sitecr5db==10 & sex==2
fillmissing incid_2014 if sitecr5db==11 & sex==1
fillmissing incid_2014 if sitecr5db==11 & sex==2
fillmissing incid_2014 if sitecr5db==12 & sex==1
fillmissing incid_2014 if sitecr5db==12 & sex==2
fillmissing incid_2014 if sitecr5db==13 & sex==1
fillmissing incid_2014 if sitecr5db==13 & sex==2
fillmissing incid_2014 if sitecr5db==14 & sex==1
fillmissing incid_2014 if sitecr5db==14 & sex==2
fillmissing incid_2014 if sitecr5db==15 & sex==1
fillmissing incid_2014 if sitecr5db==15 & sex==2
fillmissing incid_2014 if sitecr5db==16 & sex==1
fillmissing incid_2014 if sitecr5db==16 & sex==2
fillmissing incid_2014 if sitecr5db==17 & sex==1
fillmissing incid_2014 if sitecr5db==17 & sex==2
fillmissing incid_2014 if sitecr5db==18 & sex==1
fillmissing incid_2014 if sitecr5db==18 & sex==2
fillmissing incid_2014 if sitecr5db==19 & sex==1
fillmissing incid_2014 if sitecr5db==19 & sex==2
fillmissing incid_2014 if sitecr5db==21 & sex==1
fillmissing incid_2014 if sitecr5db==21 & sex==2
fillmissing incid_2014 if sitecr5db==22 & sex==1
fillmissing incid_2014 if sitecr5db==22 & sex==2

gen mir_2014 = mort_2014/incid_2014 if sitecr5db==1
replace mir_2014 = mort_2014/incid_2014 if sitecr5db==2
replace mir_2014 = mort_2014/incid_2014 if sitecr5db==3
replace mir_2014 = mort_2014/incid_2014 if sitecr5db==4
replace mir_2014 = mort_2014/incid_2014 if sitecr5db==5
replace mir_2014 = mort_2014/incid_2014 if sitecr5db==6
replace mir_2014 = mort_2014/incid_2014 if sitecr5db==7
replace mir_2014 = mort_2014/incid_2014 if sitecr5db==8
replace mir_2014 = mort_2014/incid_2014 if sitecr5db==9
replace mir_2014 = mort_2014/incid_2014 if sitecr5db==10
replace mir_2014 = mort_2014/incid_2014 if sitecr5db==11
replace mir_2014 = mort_2014/incid_2014 if sitecr5db==12
replace mir_2014 = mort_2014/incid_2014 if sitecr5db==13
replace mir_2014 = mort_2014/incid_2014 if sitecr5db==14
replace mir_2014 = mort_2014/incid_2014 if sitecr5db==15
replace mir_2014 = mort_2014/incid_2014 if sitecr5db==16
replace mir_2014 = mort_2014/incid_2014 if sitecr5db==17
replace mir_2014 = mort_2014/incid_2014 if sitecr5db==18
replace mir_2014 = mort_2014/incid_2014 if sitecr5db==19
replace mir_2014 = mort_2014/incid_2014 if sitecr5db==21
replace mir_2014 = mort_2014/incid_2014 if sitecr5db==22


** Creating variable to assess MIR for 2015 only
append using "`datapath'\version02\2-working\2015_mir_mort"
append using "`datapath'\version02\2-working\2015_mir_incid"

gen mort_2015 = cases if mort==1 & dodyear==2015
fillmissing mort_2015 if sitecr5db==1 & sex==1
fillmissing mort_2015 if sitecr5db==1 & sex==2
fillmissing mort_2015 if sitecr5db==2 & sex==1
fillmissing mort_2015 if sitecr5db==2 & sex==2
fillmissing mort_2015 if sitecr5db==3 & sex==1
fillmissing mort_2015 if sitecr5db==3 & sex==2
fillmissing mort_2015 if sitecr5db==4 & sex==1
fillmissing mort_2015 if sitecr5db==4 & sex==2
fillmissing mort_2015 if sitecr5db==5 & sex==1
fillmissing mort_2015 if sitecr5db==5 & sex==2
fillmissing mort_2015 if sitecr5db==6 & sex==1
fillmissing mort_2015 if sitecr5db==6 & sex==2
fillmissing mort_2015 if sitecr5db==7 & sex==1
fillmissing mort_2015 if sitecr5db==7 & sex==2
fillmissing mort_2015 if sitecr5db==8 & sex==1
fillmissing mort_2015 if sitecr5db==8 & sex==2
fillmissing mort_2015 if sitecr5db==9 & sex==1
fillmissing mort_2015 if sitecr5db==9 & sex==2
fillmissing mort_2015 if sitecr5db==10 & sex==1
fillmissing mort_2015 if sitecr5db==10 & sex==2
fillmissing mort_2015 if sitecr5db==11 & sex==1
fillmissing mort_2015 if sitecr5db==11 & sex==2
fillmissing mort_2015 if sitecr5db==12 & sex==1
fillmissing mort_2015 if sitecr5db==12 & sex==2
fillmissing mort_2015 if sitecr5db==13 & sex==1
fillmissing mort_2015 if sitecr5db==13 & sex==2
fillmissing mort_2015 if sitecr5db==14 & sex==1
fillmissing mort_2015 if sitecr5db==14 & sex==2
fillmissing mort_2015 if sitecr5db==15 & sex==1
fillmissing mort_2015 if sitecr5db==15 & sex==2
fillmissing mort_2015 if sitecr5db==16 & sex==1
fillmissing mort_2015 if sitecr5db==16 & sex==2
fillmissing mort_2015 if sitecr5db==17 & sex==1
fillmissing mort_2015 if sitecr5db==17 & sex==2
fillmissing mort_2015 if sitecr5db==18 & sex==1
fillmissing mort_2015 if sitecr5db==18 & sex==2
fillmissing mort_2015 if sitecr5db==19 & sex==1
fillmissing mort_2015 if sitecr5db==19 & sex==2
fillmissing mort_2015 if sitecr5db==21 & sex==1
fillmissing mort_2015 if sitecr5db==21 & sex==2
fillmissing mort_2015 if sitecr5db==22 & sex==1
fillmissing mort_2015 if sitecr5db==22 & sex==2

gen incid_2015 = cases if incid==1 & dxyr==2015
fillmissing incid_2015 if sitecr5db==1 & sex==1
fillmissing incid_2015 if sitecr5db==1 & sex==2
fillmissing incid_2015 if sitecr5db==2 & sex==1
fillmissing incid_2015 if sitecr5db==2 & sex==2
fillmissing incid_2015 if sitecr5db==3 & sex==1
fillmissing incid_2015 if sitecr5db==3 & sex==2
fillmissing incid_2015 if sitecr5db==4 & sex==1
fillmissing incid_2015 if sitecr5db==4 & sex==2
fillmissing incid_2015 if sitecr5db==5 & sex==1
fillmissing incid_2015 if sitecr5db==5 & sex==2
fillmissing incid_2015 if sitecr5db==6 & sex==1
fillmissing incid_2015 if sitecr5db==6 & sex==2
fillmissing incid_2015 if sitecr5db==7 & sex==1
fillmissing incid_2015 if sitecr5db==7 & sex==2
fillmissing incid_2015 if sitecr5db==8 & sex==1
fillmissing incid_2015 if sitecr5db==8 & sex==2
fillmissing incid_2015 if sitecr5db==9 & sex==1
fillmissing incid_2015 if sitecr5db==9 & sex==2
fillmissing incid_2015 if sitecr5db==10 & sex==1
fillmissing incid_2015 if sitecr5db==10 & sex==2
fillmissing incid_2015 if sitecr5db==11 & sex==1
fillmissing incid_2015 if sitecr5db==11 & sex==2
fillmissing incid_2015 if sitecr5db==12 & sex==1
fillmissing incid_2015 if sitecr5db==12 & sex==2
fillmissing incid_2015 if sitecr5db==13 & sex==1
fillmissing incid_2015 if sitecr5db==13 & sex==2
fillmissing incid_2015 if sitecr5db==14 & sex==1
fillmissing incid_2015 if sitecr5db==14 & sex==2
fillmissing incid_2015 if sitecr5db==15 & sex==1
fillmissing incid_2015 if sitecr5db==15 & sex==2
fillmissing incid_2015 if sitecr5db==16 & sex==1
fillmissing incid_2015 if sitecr5db==16 & sex==2
fillmissing incid_2015 if sitecr5db==17 & sex==1
fillmissing incid_2015 if sitecr5db==17 & sex==2
fillmissing incid_2015 if sitecr5db==18 & sex==1
fillmissing incid_2015 if sitecr5db==18 & sex==2
fillmissing incid_2015 if sitecr5db==19 & sex==1
fillmissing incid_2015 if sitecr5db==19 & sex==2
fillmissing incid_2015 if sitecr5db==21 & sex==1
fillmissing incid_2015 if sitecr5db==21 & sex==2
fillmissing incid_2015 if sitecr5db==22 & sex==1
fillmissing incid_2015 if sitecr5db==22 & sex==2

gen mir_2015 = mort_2015/incid_2015 if sitecr5db==1
replace mir_2015 = mort_2015/incid_2015 if sitecr5db==2
replace mir_2015 = mort_2015/incid_2015 if sitecr5db==3
replace mir_2015 = mort_2015/incid_2015 if sitecr5db==4
replace mir_2015 = mort_2015/incid_2015 if sitecr5db==5
replace mir_2015 = mort_2015/incid_2015 if sitecr5db==6
replace mir_2015 = mort_2015/incid_2015 if sitecr5db==7
replace mir_2015 = mort_2015/incid_2015 if sitecr5db==8
replace mir_2015 = mort_2015/incid_2015 if sitecr5db==9
replace mir_2015 = mort_2015/incid_2015 if sitecr5db==10
replace mir_2015 = mort_2015/incid_2015 if sitecr5db==11
replace mir_2015 = mort_2015/incid_2015 if sitecr5db==12
replace mir_2015 = mort_2015/incid_2015 if sitecr5db==13
replace mir_2015 = mort_2015/incid_2015 if sitecr5db==14
replace mir_2015 = mort_2015/incid_2015 if sitecr5db==15
replace mir_2015 = mort_2015/incid_2015 if sitecr5db==16
replace mir_2015 = mort_2015/incid_2015 if sitecr5db==17
replace mir_2015 = mort_2015/incid_2015 if sitecr5db==18
replace mir_2015 = mort_2015/incid_2015 if sitecr5db==19
replace mir_2015 = mort_2015/incid_2015 if sitecr5db==21
replace mir_2015 = mort_2015/incid_2015 if sitecr5db==22


** Condense dataset
preserve
keep sitecr5db sex mir_2013 mort_2013 incid_2013 mir_2014 mort_2014 incid_2014 mir_2015 mort_2015 incid_2015
sort sitecr5db sex
contract sitecr5db sex mir_2013 mort_2013 incid_2013 mir_2014 mort_2014 incid_2014 mir_2015 mort_2015 incid_2015
drop _freq
gen id = _n
drop if id==2|id==3|id==5|id==6|id==8|id==9|id==11|id==13|id==14 ///
		|id==16|id==17|id==19|id==20|id==22|id==23|id==25|id==26 ///
		|id==28|id==29|id==31|id==32|id==34|id==35|id==38|id==41 ///
		|id==42|id==44|id==45|id==47|id==49|id==51|id==52|id==54 ///
		|id==55|id==57|id==58|id==60|id==61|id==63|id==64|id==67 ///
		|id==69|id==70|id==72|id==73|id==75|id==76|id==78|id==80 ///
		|id==82|id==83|id==85|id==87|id==88|id==90|id==91|id==93 ///
		|id==94|id==96|id==97
//60 deleted
drop if id==12|id==40|id==50|id==68|id==79|id==99|id==100 ///
		|id==102|id==103|id==105|id==106		
drop id
gen mir_iarc_2013 = mir_2013*100
gen mir_iarc_2014 = mir_2014*100
gen mir_iarc_2015 = mir_2015*100
format mir_iarc_2013 mir_iarc_2014 mir_iarc_2015 %3.1f
order sitecr5db sex mir_iarc_2013 mort_2013 incid_2013 mir_iarc_2014 mort_2014 incid_2014 mir_iarc_2015 mort_2015 incid_2015
save "`datapath'\version02\3-output\2013_2014_2015_mir", replace

** Create MS Word results table with absolute case totals + the MIRs for ungrouped years (2013, 2014, 2015), by site, by sex
				**************************
				*	   MS WORD REPORT    *
				* 	Mortality:Incidence  * 
				*       Ratio RESULTS    *
				**************************
putdocx clear
putdocx begin, footer(foot1)
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER Data Quality Report: Mortality/Incidence Ratio"), bold
putdocx textblock begin
Date Prepared: 06-OCT-2021. 
Prepared by: JC using Stata & Redcap data release date: 21-May-2021. 
Generated using Dofile: 68_MIR.do
putdocx textblock end
putdocx paragraph, halign(center)
putdocx text ("Table: Case Totals + Mortality:Incidence Ratios for BNR-Cancer Ungrouped Years (2013, 2014, 2015)"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Background"), bold
putdocx textblock begin
A data quality assessment performed by the IARC Hub noted large M:I ratios in certain sites. IARC Hub used mortality data from the CARPHA mortality database, which collects data from Ministry of Health and Wellness. This report performs a secondary check using mortality data collected directly from the Barbados Registration Dept. This data quality indicator is one method of assessing completeness.
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) For the incidence dataset, the 2015 annual report incidence dataset was used to organize the data into a format to perform the M:I analysis (cancer dataset used: "`datapath'\version02\3-output\2008_2013_2014_2015_iarchub_nonsurvival_reportable"; Note: 2008 cases were ultimately excluded)
putdocx textblock end
putdocx textblock begin
(2) For the mortality dataset, the 2013, 2014 and 2015 annual report mortality datasets were used to organize the data into a format to perform the M:I analysis (cancer dataset used: (2013) "`datapath'\version02\1-input\2013_cancer_for_MR_only"; (2014) "`datapath'\version02\1-input\2014_cancer_mort_dc"; (2015) "`datapath'\version02\3-output\2015_prep mort").
putdocx textblock end
putdocx textblock begin
(3) All the incidence and mortality datasets were checked to ensure the site variable, sitecr5db, was not missing and site codes were assigned if it was missing in the dataset.
putdocx textblock end
putdocx textblock begin
(4) The calculation used for the M:I ratio was number of death cases per site per sex / number of incident cases per site per sex.
putdocx textblock end
putdocx textblock begin
(5) Sites that had a M:I ratio exceeding a value of 1 (one) or >99% were checked case by case using the Mortality data + the Casefinding database to determine why that death case was excluded from the incidence dataset.  The datasets and database used for this comparison review process are: MORTALITY:"`datapath'\version02\2-working\yyyy_mir_mort_prep"; INCIDENCE:"`datapath'\version02\2-working\yyyy_mir_incid_prep" and "`datapath'\version02\3-output\2008_2013_2014_2015_iarchub_nonsurvival_nonreportable"; CASEFINDING DATABASES:"...Sync\Cancer\CF Database\MasterDb\SyncDb\Databases\Master" and CanReg5 database. The outcome of this investigation can be found in the excel workbook saved in the pathway: '...The University of the West Indies\FORDE, Shelly-Ann - BNR\REPORTS\Annual Reports\2015 Cancer Report\2021-10-07_mir_ungrouped_reviews.xlsx'.
putdocx textblock end
putdocx pagebreak
putdocx table tbl1 = data(sitecr5db sex mir_iarc_2013 mort_2013 incid_2013 mir_iarc_2014 mort_2014 incid_2014 mir_iarc_2015 mort_2015 incid_2015), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)
putdocx table tbl1(1,8), bold shading(lightgray)
putdocx table tbl1(1,9), bold shading(lightgray)
putdocx table tbl1(1,10), bold shading(lightgray)
putdocx table tbl1(1,11), bold shading(lightgray)

putdocx save "`datapath'\version02\3-output\2021-10-07_mir_ungrouped_stats_V03.docx", replace
putdocx clear
restore


** Creating variables to assess MIR for grouped years (2013-2015)
egen cases_mort_all = total(cases) if mort==1 & sitecr5db==1 & sex==1
sum cases if mort==1 & sitecr5db==1 & sex==2
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==1 & sex==2
sum cases if mort==1 & sitecr5db==2 & sex==1
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==2 & sex==1
sum cases if mort==1 & sitecr5db==2 & sex==2
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==2 & sex==2
sum cases if mort==1 & sitecr5db==3 & sex==1
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==3 & sex==1
sum cases if mort==1 & sitecr5db==3 & sex==2
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==3 & sex==2
sum cases if mort==1 & sitecr5db==4 & sex==1
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==4 & sex==1
sum cases if mort==1 & sitecr5db==4 & sex==2
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==4 & sex==2
sum cases if mort==1 & sitecr5db==5 & sex==1
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==5 & sex==1
sum cases if mort==1 & sitecr5db==5 & sex==2
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==5 & sex==2
sum cases if mort==1 & sitecr5db==6 & sex==1
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==6 & sex==1
sum cases if mort==1 & sitecr5db==6 & sex==2
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==6 & sex==2
sum cases if mort==1 & sitecr5db==7 & sex==1
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==7 & sex==1
sum cases if mort==1 & sitecr5db==7 & sex==2
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==7 & sex==2
sum cases if mort==1 & sitecr5db==8 & sex==1
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==8 & sex==1
sum cases if mort==1 & sitecr5db==8 & sex==2
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==8 & sex==2
sum cases if mort==1 & sitecr5db==9 & sex==1
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==9 & sex==1
sum cases if mort==1 & sitecr5db==9 & sex==2
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==9 & sex==2
sum cases if mort==1 & sitecr5db==10 & sex==1
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==10 & sex==1
sum cases if mort==1 & sitecr5db==10 & sex==2
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==10 & sex==2
sum cases if mort==1 & sitecr5db==11 & sex==1
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==11 & sex==1
sum cases if mort==1 & sitecr5db==11 & sex==2
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==11 & sex==2
sum cases if mort==1 & sitecr5db==12 & sex==1
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==12 & sex==1
sum cases if mort==1 & sitecr5db==12 & sex==2
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==12 & sex==2
sum cases if mort==1 & sitecr5db==13 & sex==1
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==13 & sex==1
sum cases if mort==1 & sitecr5db==13 & sex==2
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==13 & sex==2
sum cases if mort==1 & sitecr5db==14 & sex==1
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==14 & sex==1
sum cases if mort==1 & sitecr5db==14 & sex==2
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==14 & sex==2
sum cases if mort==1 & sitecr5db==15 & sex==1
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==15 & sex==1
sum cases if mort==1 & sitecr5db==15 & sex==2
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==15 & sex==2
sum cases if mort==1 & sitecr5db==16 & sex==1
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==16 & sex==1
sum cases if mort==1 & sitecr5db==16 & sex==2
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==16 & sex==2
sum cases if mort==1 & sitecr5db==17 & sex==1
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==17 & sex==1
sum cases if mort==1 & sitecr5db==17 & sex==2
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==17 & sex==2
sum cases if mort==1 & sitecr5db==18 & sex==1
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==18 & sex==1
sum cases if mort==1 & sitecr5db==18 & sex==2
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==18 & sex==2
sum cases if mort==1 & sitecr5db==19 & sex==1
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==19 & sex==1
sum cases if mort==1 & sitecr5db==19 & sex==2
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==19 & sex==2
sum cases if mort==1 & sitecr5db==21 & sex==1
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==21 & sex==1
sum cases if mort==1 & sitecr5db==21 & sex==2
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==21 & sex==2
sum cases if mort==1 & sitecr5db==22 & sex==1
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==22 & sex==1
sum cases if mort==1 & sitecr5db==22 & sex==2
replace cases_mort_all = r(sum) if mort==1 & sitecr5db==22 & sex==2


egen cases_incid_all = total(cases) if incid==1 & sitecr5db==1 & sex==1
sum cases if incid==1 & sitecr5db==1 & sex==2
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==1 & sex==2
sum cases if incid==1 & sitecr5db==2 & sex==1
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==2 & sex==1
sum cases if incid==1 & sitecr5db==2 & sex==2
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==2 & sex==2
sum cases if incid==1 & sitecr5db==3 & sex==1
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==3 & sex==1
sum cases if incid==1 & sitecr5db==3 & sex==2
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==3 & sex==2
sum cases if incid==1 & sitecr5db==4 & sex==1
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==4 & sex==1
sum cases if incid==1 & sitecr5db==4 & sex==2
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==4 & sex==2
sum cases if incid==1 & sitecr5db==5 & sex==1
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==5 & sex==1
sum cases if incid==1 & sitecr5db==5 & sex==2
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==5 & sex==2
sum cases if incid==1 & sitecr5db==6 & sex==1
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==6 & sex==1
sum cases if incid==1 & sitecr5db==6 & sex==2
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==6 & sex==2
sum cases if incid==1 & sitecr5db==7 & sex==1
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==7 & sex==1
sum cases if incid==1 & sitecr5db==7 & sex==2
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==7 & sex==2
sum cases if incid==1 & sitecr5db==8 & sex==1
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==8 & sex==1
sum cases if incid==1 & sitecr5db==8 & sex==2
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==8 & sex==2
sum cases if incid==1 & sitecr5db==9 & sex==1
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==9 & sex==1
sum cases if incid==1 & sitecr5db==9 & sex==2
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==9 & sex==2
sum cases if incid==1 & sitecr5db==10 & sex==1
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==10 & sex==1
sum cases if incid==1 & sitecr5db==10 & sex==2
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==10 & sex==2
sum cases if incid==1 & sitecr5db==11 & sex==1
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==11 & sex==1
sum cases if incid==1 & sitecr5db==11 & sex==2
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==11 & sex==2
sum cases if incid==1 & sitecr5db==12 & sex==1
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==12 & sex==1
sum cases if incid==1 & sitecr5db==12 & sex==2
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==12 & sex==2
sum cases if incid==1 & sitecr5db==13 & sex==1
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==13 & sex==1
sum cases if incid==1 & sitecr5db==13 & sex==2
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==13 & sex==2
sum cases if incid==1 & sitecr5db==14 & sex==1
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==14 & sex==1
sum cases if incid==1 & sitecr5db==14 & sex==2
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==14 & sex==2
sum cases if incid==1 & sitecr5db==15 & sex==1
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==15 & sex==1
sum cases if incid==1 & sitecr5db==15 & sex==2
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==15 & sex==2
sum cases if incid==1 & sitecr5db==16 & sex==1
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==16 & sex==1
sum cases if incid==1 & sitecr5db==16 & sex==2
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==16 & sex==2
sum cases if incid==1 & sitecr5db==17 & sex==1
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==17 & sex==1
sum cases if incid==1 & sitecr5db==17 & sex==2
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==17 & sex==2
sum cases if incid==1 & sitecr5db==18 & sex==1
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==18 & sex==1
sum cases if incid==1 & sitecr5db==18 & sex==2
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==18 & sex==2
sum cases if incid==1 & sitecr5db==19 & sex==1
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==19 & sex==1
sum cases if incid==1 & sitecr5db==19 & sex==2
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==19 & sex==2
sum cases if incid==1 & sitecr5db==21 & sex==1
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==21 & sex==1
sum cases if incid==1 & sitecr5db==21 & sex==2
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==21 & sex==2
sum cases if incid==1 & sitecr5db==22 & sex==1
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==22 & sex==1
sum cases if incid==1 & sitecr5db==22 & sex==2
replace cases_incid_all = r(sum) if incid==1 & sitecr5db==22 & sex==2

keep sitecr5db sex cases_mort_all cases_incid_all
sort sitecr5db sex
contract sitecr5db sex cases_mort_all cases_incid_all
drop _freq

fillmissing cases_mort_all if sitecr5db==1 & sex==1
fillmissing cases_mort_all if sitecr5db==1 & sex==2
fillmissing cases_mort_all if sitecr5db==2 & sex==1
fillmissing cases_mort_all if sitecr5db==2 & sex==2
fillmissing cases_mort_all if sitecr5db==3 & sex==1
fillmissing cases_mort_all if sitecr5db==3 & sex==2
fillmissing cases_mort_all if sitecr5db==4 & sex==1
fillmissing cases_mort_all if sitecr5db==4 & sex==2
fillmissing cases_mort_all if sitecr5db==5 & sex==1
fillmissing cases_mort_all if sitecr5db==5 & sex==2
fillmissing cases_mort_all if sitecr5db==6 & sex==1
fillmissing cases_mort_all if sitecr5db==6 & sex==2
fillmissing cases_mort_all if sitecr5db==7 & sex==1
fillmissing cases_mort_all if sitecr5db==7 & sex==2
fillmissing cases_mort_all if sitecr5db==8 & sex==1
fillmissing cases_mort_all if sitecr5db==8 & sex==2
fillmissing cases_mort_all if sitecr5db==9 & sex==1
fillmissing cases_mort_all if sitecr5db==9 & sex==2
fillmissing cases_mort_all if sitecr5db==10 & sex==1
fillmissing cases_mort_all if sitecr5db==10 & sex==2
fillmissing cases_mort_all if sitecr5db==11 & sex==1
fillmissing cases_mort_all if sitecr5db==11 & sex==2
fillmissing cases_mort_all if sitecr5db==12 & sex==1
fillmissing cases_mort_all if sitecr5db==12 & sex==2
fillmissing cases_mort_all if sitecr5db==13 & sex==1
fillmissing cases_mort_all if sitecr5db==13 & sex==2
fillmissing cases_mort_all if sitecr5db==14 & sex==1
fillmissing cases_mort_all if sitecr5db==14 & sex==2
fillmissing cases_mort_all if sitecr5db==15 & sex==1
fillmissing cases_mort_all if sitecr5db==15 & sex==2
fillmissing cases_mort_all if sitecr5db==16 & sex==1
fillmissing cases_mort_all if sitecr5db==16 & sex==2
fillmissing cases_mort_all if sitecr5db==17 & sex==1
fillmissing cases_mort_all if sitecr5db==17 & sex==2
fillmissing cases_mort_all if sitecr5db==18 & sex==1
fillmissing cases_mort_all if sitecr5db==18 & sex==2
fillmissing cases_mort_all if sitecr5db==19 & sex==1
fillmissing cases_mort_all if sitecr5db==19 & sex==2
fillmissing cases_mort_all if sitecr5db==21 & sex==1
fillmissing cases_mort_all if sitecr5db==21 & sex==2
fillmissing cases_mort_all if sitecr5db==22 & sex==1
fillmissing cases_mort_all if sitecr5db==22 & sex==2
//35 deleted
drop if cases_incid_all==.

gen mir_all = cases_mort_all/cases_incid_all if sitecr5db==1
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==2
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==3
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==4
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==5
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==6
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==7
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==8
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==9
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==10
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==11
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==12
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==13
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==14
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==15
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==16
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==17
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==18
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==19
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==21
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==22

order sitecr5db sex mir_all
gen mir_iarc = mir_all*100
format mir_iarc %3.1f
save "`datapath'\version02\3-output\2013-2015_mir", replace

** Create MS Word results table with absolute case totals + the MIRs for grouped years (2013-2015), by site, by sex
				**************************
				*	   MS WORD REPORT    *
				* 	Mortality:Incidence  * 
				*       Ratio RESULTS    *
				**************************
putdocx clear
putdocx begin, footer(foot1)
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER Data Quality Report: Mortality/Incidence Ratio"), bold
putdocx textblock begin
Date Prepared: 06-OCT-2021. 
Prepared by: JC using Stata & Redcap data release date: 21-May-2021. 
Generated using Dofile: 68_MIR.do
putdocx textblock end
putdocx paragraph, halign(center)
putdocx text ("Table: Case Totals + Mortality:Incidence Ratios for BNR-Cancer Grouped Years (2013-2015)"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Background"), bold
putdocx textblock begin
A data quality assessment performed by the IARC Hub noted large M:I ratios in certain sites. IARC Hub used mortality data from the CARPHA mortality database, which collects data from Ministry of Health and Wellness. This report performs a secondary check using mortality data collected directly from the Barbados Registration Dept. This data quality indicator is one method of assessing completeness.
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) For the incidence dataset, the 2015 annual report incidence dataset was used to organize the data into a format to perform the M:I analysis (cancer dataset used: "`datapath'\version02\3-output\2008_2013_2014_2015_iarchub_nonsurvival_reportable"; Note: 2008 cases were ultimately excluded)
putdocx textblock end
putdocx textblock begin
(2) For the mortality dataset, the 2013, 2014 and 2015 annual report mortality datasets were used to organize the data into a format to perform the M:I analysis (cancer dataset used: (2013) "`datapath'\version02\1-input\2013_cancer_for_MR_only"; (2014) "`datapath'\version02\1-input\2014_cancer_mort_dc"; (2015) "`datapath'\version02\3-output\2015_prep mort").
putdocx textblock end
putdocx textblock begin
(3) All the incidence and mortality datasets were checked to ensure the site variable, sitecr5db, was not missing and site codes were assigned if it was missing in the dataset.
putdocx textblock end
putdocx textblock begin
(4) The calculation used for the M:I ratio was number of death cases per site per sex / number of incident cases per site per sex.
putdocx textblock end
putdocx textblock begin
(5) Sites that had a M:I ratio exceeding a value of 1 (one) or >99% were checked case by case using the Mortality data + the Casefinding database to determine why that death case was excluded from the incidence dataset.  The datasets and database used for this comparison review process are: MORTALITY:"`datapath'\version02\2-working\yyyy_mir_mort_prep"; INCIDENCE:"`datapath'\version02\2-working\yyyy_mir_incid_prep" and "`datapath'\version02\3-output\2008_2013_2014_2015_iarchub_nonsurvival_nonreportable"; CASEFINDING DATABASES:"...Sync\Cancer\CF Database\MasterDb\SyncDb\Databases\Master" and CanReg5 database. The outcome of this investigation can be found in the excel workbook saved in the pathway: '...The University of the West Indies\FORDE, Shelly-Ann - BNR\REPORTS\Annual Reports\2015 Cancer Report\2021-10-07_mir_ungrouped_reviews.xlsx'.
putdocx textblock end
putdocx pagebreak
putdocx table tbl1 = data(sitecr5db sex mir_all mir_iarc cases_mort_all cases_incid_all), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)

putdocx save "`datapath'\version02\3-output\2021-10-07_mir_grouped_stats_V03.docx", replace
putdocx clear


*******************
** Adjusted MIRs **
*******************
/* 
	After reviewing, on a case-by-case basis, all sites that had a MIR of >=100, 
	the deaths that were captured either at casefinding or abstraction were
	removed from the deaths totals and the MIRs were re-calculated.
	Note: missed eligible cases were not removed but flagged and sent to DAs to abstract
*/

drop mir_all mir_iarc

** Remove deaths flagged at review
//Subtract all deaths (2013-2015) that were captured at CF/ABS phase
replace cases_mort_all = cases_mort_all - 20 if sitecr5db==1 & sex==2 //Mouth & pharynx (male)
replace cases_mort_all = cases_mort_all - 11 if sitecr5db==2 & sex==1 //Oesophagus (female)
replace cases_mort_all = cases_mort_all - 14 if sitecr5db==2 & sex==2 //Oesophagus (male)
replace cases_mort_all = cases_mort_all - 5 if sitecr5db==5 & sex==1 //Liver (female)
replace cases_mort_all = cases_mort_all - 4 if sitecr5db==5 & sex==2 //Liver (male)
replace cases_mort_all = cases_mort_all - 16 if sitecr5db==6 & sex==1 //Pancreas (female)
replace cases_mort_all = cases_mort_all - 11 if sitecr5db==6 & sex==2 //Pancreas (male)
replace cases_mort_all = cases_mort_all - 4 if sitecr5db==7 & sex==2 //Larynx (male)
replace cases_mort_all = cases_mort_all - 26 if sitecr5db==8 & sex==1 //Lung (female)
replace cases_mort_all = cases_mort_all - 24 if sitecr5db==8 & sex==2 //Lung (male)
replace cases_mort_all = cases_mort_all - 2 if sitecr5db==9 & sex==1 //Melanoma of skin (female)
replace cases_mort_all = cases_mort_all - 7 if sitecr5db==16 & sex==2 //Kidney (male)
replace cases_mort_all = cases_mort_all - 7 if sitecr5db==17 & sex==1 //Bladder (female)
replace cases_mort_all = cases_mort_all - 4 if sitecr5db==18 & sex==1 //Brain (female)
replace cases_mort_all = cases_mort_all - 8 if sitecr5db==18 & sex==2 //Brain (male)
replace cases_mort_all = cases_mort_all - 1 if sitecr5db==19 & sex==2 //Thyroid (male)
replace cases_mort_all = cases_mort_all - 20 if sitecr5db==22 & sex==1 //Leukaemia (female)
replace cases_mort_all = cases_mort_all - 9 if sitecr5db==22 & sex==2 //Leukaemia (male)

** Create adjusted MIRs
gen mir_all = cases_mort_all/cases_incid_all if sitecr5db==1
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==2
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==3
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==4
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==5
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==6
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==7
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==8
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==9
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==10
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==11
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==12
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==13
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==14
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==15
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==16
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==17
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==18
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==19
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==21
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==22

order sitecr5db sex mir_all
gen mir_iarc = mir_all*100
format mir_iarc %3.1f

** Create MS Word results table with absolute case totals + the "adjusted" MIRs for grouped years (2013-2015), by site, by sex
				**************************
				*	   MS WORD REPORT    *
				* 	Mortality:Incidence  * 
				*       Ratio RESULTS    *
				**************************
putdocx clear
putdocx begin, footer(foot1)
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER Data Quality Report: Mortality/Incidence Ratio"), bold
putdocx textblock begin
Date Prepared: 12-OCT-2021. 
Prepared by: JC using Stata & Redcap data release date: 21-May-2021. 
Generated using Dofile: 68_MIR.do
putdocx textblock end
putdocx paragraph, halign(center)
putdocx text ("Case Totals + 'Adjusted' Mortality:Incidence Ratios for BNR-Cancer Grouped Years (2013-2015)"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Background"), bold
putdocx textblock begin
A data quality assessment performed by the IARC Hub noted large M:I ratios in certain sites. IARC Hub used mortality data from the CARPHA mortality database, which collects data from Ministry of Health and Wellness. This report performs a secondary check using mortality data collected directly from the Barbados Registration Dept. This data quality indicator is one method of assessing completeness.
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) For the incidence dataset, the 2015 annual report incidence dataset was used to organize the data into a format to perform the M:I analysis (cancer dataset used: "`datapath'\version02\3-output\2008_2013_2014_2015_iarchub_nonsurvival_reportable"; Note: 2008 cases were ultimately excluded)
putdocx textblock end
putdocx textblock begin
(2) For the mortality dataset, the 2013, 2014 and 2015 annual report mortality datasets were used to organize the data into a format to perform the M:I analysis (cancer dataset used: (2013) "`datapath'\version02\1-input\2013_cancer_for_MR_only"; (2014) "`datapath'\version02\1-input\2014_cancer_mort_dc"; (2015) "`datapath'\version02\3-output\2015_prep mort").
putdocx textblock end
putdocx textblock begin
(3) All the incidence and mortality datasets were checked to ensure the site variable, sitecr5db, was not missing and site codes were assigned if it was missing in the dataset.
putdocx textblock end
putdocx textblock begin
(4) The calculation used for the M:I ratio was number of death cases per site per sex / number of incident cases per site per sex.
putdocx textblock end
putdocx textblock begin
(5) Sites that had a M:I ratio exceeding a value of 1 (one) or >99% were checked case by case using the Mortality data + the Casefinding database to determine why that death case was excluded from the incidence dataset.  The datasets and database used for this comparison review process are: MORTALITY:"`datapath'\version02\2-working\yyyy_mir_mort_prep"; INCIDENCE:"`datapath'\version02\2-working\yyyy_mir_incid_prep" and "`datapath'\version02\3-output\2008_2013_2014_2015_iarchub_nonsurvival_nonreportable"; CASEFINDING DATABASES:"...Sync\Cancer\CF Database\MasterDb\SyncDb\Databases\Master" and CanReg5 database. The outcome of this investigation can be found in the excel workbook saved in the pathway: '...The University of the West Indies\FORDE, Shelly-Ann - BNR\REPORTS\Annual Reports\2015 Cancer Report\2021-10-07_mir_ungrouped_reviews.xlsx'.
putdocx textblock end
putdocx textblock begin
(6) Based on the above review, the deaths that were captured either at casefinding or abstraction were removed from the deaths totals and the MIRs were re-calculated. Note: missed eligible cases were not removed but were sent to BNR-C DAs to abstract for inclusion in the next annual report.
putdocx textblock end
putdocx pagebreak
putdocx table tbl1 = data(sitecr5db sex mir_all mir_iarc cases_mort_all cases_incid_all), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)

putdocx save "`datapath'\version02\3-output\2021-10-12_adjusted_mir_grouped_stats_V01.docx", replace
putdocx clear

** In the above document, there are still some sites with 
drop mir_all mir_iarc

** Remove deaths flagged at review
//Subtract all deaths (2013-2015) that were captured at CF/ABS phase
replace cases_mort_all = cases_mort_all - 29 if sitecr5db==3 & sex==1 //Stomach (female)
replace cases_mort_all = cases_mort_all - 14 if sitecr5db==5 & sex==1 //Liver (female)
replace cases_mort_all = cases_mort_all - 39 if sitecr5db==6 & sex==2 //Pancreas (male)

** Create adjusted MIRs
gen mir_all = cases_mort_all/cases_incid_all if sitecr5db==1
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==2
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==3
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==4
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==5
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==6
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==7
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==8
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==9
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==10
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==11
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==12
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==13
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==14
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==15
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==16
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==17
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==18
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==19
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==21
replace mir_all = cases_mort_all/cases_incid_all if sitecr5db==22

order sitecr5db sex mir_all
gen mir_iarc = mir_all*100
format mir_iarc %3.1f

** Create MS Word results table with absolute case totals + the "adjusted" MIRs for grouped years (2013-2015), by site, by sex
				**************************
				*	   MS WORD REPORT    *
				* 	Mortality:Incidence  * 
				*       Ratio RESULTS    *
				**************************
putdocx clear
putdocx begin, footer(foot1)
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER Data Quality Report: Mortality/Incidence Ratio"), bold
putdocx textblock begin
Date Prepared: 13-OCT-2021. 
Prepared by: JC using Stata & Redcap data release date: 21-May-2021. 
Generated using Dofile: 68_MIR.do
putdocx textblock end
putdocx paragraph, halign(center)
putdocx text ("Case Totals + 'Adjusted' Mortality:Incidence Ratios for BNR-Cancer Grouped Years (2013-2015)"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Background"), bold
putdocx textblock begin
A data quality assessment performed by the IARC Hub noted large M:I ratios in certain sites. IARC Hub used mortality data from the CARPHA mortality database, which collects data from Ministry of Health and Wellness. This report performs a secondary check using mortality data collected directly from the Barbados Registration Dept. This data quality indicator is one method of assessing completeness.
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) For the incidence dataset, the 2015 annual report incidence dataset was used to organize the data into a format to perform the M:I analysis (cancer dataset used: "`datapath'\version02\3-output\2008_2013_2014_2015_iarchub_nonsurvival_reportable"; Note: 2008 cases were ultimately excluded)
putdocx textblock end
putdocx textblock begin
(2) For the mortality dataset, the 2013, 2014 and 2015 annual report mortality datasets were used to organize the data into a format to perform the M:I analysis. The mortality data is based on all deaths collected by the BNR from the national Registration Department (cancer dataset used: (2013) "`datapath'\version02\1-input\2013_cancer_for_MR_only"; (2014) "`datapath'\version02\1-input\2014_cancer_mort_dc"; (2015) "`datapath'\version02\3-output\2015_prep mort").
putdocx textblock end
putdocx textblock begin
(3) All the incidence and mortality datasets were checked to ensure the site variable, sitecr5db, was not missing and site codes were assigned if it was missing in the dataset.
putdocx textblock end
putdocx textblock begin
(4) The calculation used for the M:I ratio was number of death cases per site per sex / number of incident cases per site per sex.
putdocx textblock end
putdocx textblock begin
(5) Sites that had a M:I ratio exceeding a value of 1 (one) or >99% were checked case by case using the Mortality data + the Casefinding database to determine why that death case was excluded from the incidence dataset.  The datasets and database used for this comparison review process are: MORTALITY:"`datapath'\version02\2-working\yyyy_mir_mort_prep"; INCIDENCE:"`datapath'\version02\2-working\yyyy_mir_incid_prep" and "`datapath'\version02\3-output\2008_2013_2014_2015_iarchub_nonsurvival_nonreportable"; CASEFINDING DATABASES:"...Sync\Cancer\CF Database\MasterDb\SyncDb\Databases\Master" and CanReg5 database. The outcome of this investigation can be found in the excel workbook saved in the pathway: '...The University of the West Indies\FORDE, Shelly-Ann - BNR\REPORTS\Annual Reports\2015 Cancer Report\2021-10-07_mir_ungrouped_reviews.xlsx'.
putdocx textblock end
putdocx textblock begin
(6) Based on the above review, the deaths that were captured either at casefinding or abstraction were removed from the deaths totals and the MIRs were re-calculated. Note: missed eligible cases were not removed but were sent to BNR-C DAs to abstract for inclusion in the next annual report.
putdocx textblock end
putdocx pagebreak
putdocx table tbl1 = data(sitecr5db sex mir_all mir_iarc cases_mort_all cases_incid_all), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)

putdocx save "`datapath'\version02\3-output\2021-10-13_adjusted_mir_grouped_stats_V02.docx", replace
putdocx clear