** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          22d_MIRs_2016-2018.do
	//  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      22-AUG-2022
    // 	date last modified      22-AUG-2022
    //  algorithm task          Creating for mortality:incidence ratios per year then grouped for 2016-2018
    //  status                  Completed
    //  objective               To assess completeness of incidence data for BNR-Cancer for 2016-2018
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
    log using "`logpath'\22d_MIRs_2016-2018.smcl", replace
** HEADER -----------------------------------------------------


* ************************************************************************
* PREP AND FORMAT DATA - MORTALITY:INCIDENCE RATIO
**************************************************************************
** Creating variable to assess MIR for 2013 only
use "`datapath'\version09\2-working\2016_mir_mort", clear
append using "`datapath'\version09\2-working\2016_mir_incid"

gen mort_2016 = cases if mortds==1 & dodyear==2016
fillmissing mort_2016 if sitecr5db==1 & sex==1
fillmissing mort_2016 if sitecr5db==1 & sex==2
fillmissing mort_2016 if sitecr5db==2 & sex==1
fillmissing mort_2016 if sitecr5db==2 & sex==2
fillmissing mort_2016 if sitecr5db==3 & sex==1
fillmissing mort_2016 if sitecr5db==3 & sex==2
fillmissing mort_2016 if sitecr5db==4 & sex==1
fillmissing mort_2016 if sitecr5db==4 & sex==2
fillmissing mort_2016 if sitecr5db==5 & sex==1
fillmissing mort_2016 if sitecr5db==5 & sex==2
fillmissing mort_2016 if sitecr5db==6 & sex==1
fillmissing mort_2016 if sitecr5db==6 & sex==2
fillmissing mort_2016 if sitecr5db==7 & sex==1
fillmissing mort_2016 if sitecr5db==7 & sex==2
fillmissing mort_2016 if sitecr5db==8 & sex==1
fillmissing mort_2016 if sitecr5db==8 & sex==2
fillmissing mort_2016 if sitecr5db==9 & sex==1
fillmissing mort_2016 if sitecr5db==9 & sex==2
fillmissing mort_2016 if sitecr5db==10 & sex==1
fillmissing mort_2016 if sitecr5db==10 & sex==2
fillmissing mort_2016 if sitecr5db==11 & sex==1
fillmissing mort_2016 if sitecr5db==11 & sex==2
fillmissing mort_2016 if sitecr5db==12 & sex==1
fillmissing mort_2016 if sitecr5db==12 & sex==2
fillmissing mort_2016 if sitecr5db==13 & sex==1
fillmissing mort_2016 if sitecr5db==13 & sex==2
fillmissing mort_2016 if sitecr5db==14 & sex==1
fillmissing mort_2016 if sitecr5db==14 & sex==2
fillmissing mort_2016 if sitecr5db==15 & sex==1
fillmissing mort_2016 if sitecr5db==15 & sex==2
fillmissing mort_2016 if sitecr5db==16 & sex==1
fillmissing mort_2016 if sitecr5db==16 & sex==2
fillmissing mort_2016 if sitecr5db==17 & sex==1
fillmissing mort_2016 if sitecr5db==17 & sex==2
fillmissing mort_2016 if sitecr5db==18 & sex==1
fillmissing mort_2016 if sitecr5db==18 & sex==2
fillmissing mort_2016 if sitecr5db==19 & sex==1
fillmissing mort_2016 if sitecr5db==19 & sex==2
fillmissing mort_2016 if sitecr5db==21 & sex==1
fillmissing mort_2016 if sitecr5db==21 & sex==2
fillmissing mort_2016 if sitecr5db==22 & sex==1
fillmissing mort_2016 if sitecr5db==22 & sex==2

gen incid_2016 = cases if incid==1 & dxyr==2016
fillmissing incid_2016 if sitecr5db==1 & sex==1
fillmissing incid_2016 if sitecr5db==1 & sex==2
fillmissing incid_2016 if sitecr5db==2 & sex==1
fillmissing incid_2016 if sitecr5db==2 & sex==2
fillmissing incid_2016 if sitecr5db==3 & sex==1
fillmissing incid_2016 if sitecr5db==3 & sex==2
fillmissing incid_2016 if sitecr5db==4 & sex==1
fillmissing incid_2016 if sitecr5db==4 & sex==2
fillmissing incid_2016 if sitecr5db==5 & sex==1
fillmissing incid_2016 if sitecr5db==5 & sex==2
fillmissing incid_2016 if sitecr5db==6 & sex==1
fillmissing incid_2016 if sitecr5db==6 & sex==2
fillmissing incid_2016 if sitecr5db==7 & sex==1
fillmissing incid_2016 if sitecr5db==7 & sex==2
fillmissing incid_2016 if sitecr5db==8 & sex==1
fillmissing incid_2016 if sitecr5db==8 & sex==2
fillmissing incid_2016 if sitecr5db==9 & sex==1
fillmissing incid_2016 if sitecr5db==9 & sex==2
fillmissing incid_2016 if sitecr5db==10 & sex==1
fillmissing incid_2016 if sitecr5db==10 & sex==2
fillmissing incid_2016 if sitecr5db==11 & sex==1
fillmissing incid_2016 if sitecr5db==11 & sex==2
fillmissing incid_2016 if sitecr5db==12 & sex==1
fillmissing incid_2016 if sitecr5db==12 & sex==2
fillmissing incid_2016 if sitecr5db==13 & sex==1
fillmissing incid_2016 if sitecr5db==13 & sex==2
fillmissing incid_2016 if sitecr5db==14 & sex==1
fillmissing incid_2016 if sitecr5db==14 & sex==2
fillmissing incid_2016 if sitecr5db==15 & sex==1
fillmissing incid_2016 if sitecr5db==15 & sex==2
fillmissing incid_2016 if sitecr5db==16 & sex==1
fillmissing incid_2016 if sitecr5db==16 & sex==2
fillmissing incid_2016 if sitecr5db==17 & sex==1
fillmissing incid_2016 if sitecr5db==17 & sex==2
fillmissing incid_2016 if sitecr5db==18 & sex==1
fillmissing incid_2016 if sitecr5db==18 & sex==2
fillmissing incid_2016 if sitecr5db==19 & sex==1
fillmissing incid_2016 if sitecr5db==19 & sex==2
fillmissing incid_2016 if sitecr5db==21 & sex==1
fillmissing incid_2016 if sitecr5db==21 & sex==2
fillmissing incid_2016 if sitecr5db==22 & sex==1
fillmissing incid_2016 if sitecr5db==22 & sex==2

gen mir_2016 = mort_2016/incid_2016 if sitecr5db==1
replace mir_2016 = mort_2016/incid_2016 if sitecr5db==2
replace mir_2016 = mort_2016/incid_2016 if sitecr5db==3
replace mir_2016 = mort_2016/incid_2016 if sitecr5db==4
replace mir_2016 = mort_2016/incid_2016 if sitecr5db==5
replace mir_2016 = mort_2016/incid_2016 if sitecr5db==6
replace mir_2016 = mort_2016/incid_2016 if sitecr5db==7
replace mir_2016 = mort_2016/incid_2016 if sitecr5db==8
replace mir_2016 = mort_2016/incid_2016 if sitecr5db==9
replace mir_2016 = mort_2016/incid_2016 if sitecr5db==10
replace mir_2016 = mort_2016/incid_2016 if sitecr5db==11
replace mir_2016 = mort_2016/incid_2016 if sitecr5db==12
replace mir_2016 = mort_2016/incid_2016 if sitecr5db==13
replace mir_2016 = mort_2016/incid_2016 if sitecr5db==14
replace mir_2016 = mort_2016/incid_2016 if sitecr5db==15
replace mir_2016 = mort_2016/incid_2016 if sitecr5db==16
replace mir_2016 = mort_2016/incid_2016 if sitecr5db==17
replace mir_2016 = mort_2016/incid_2016 if sitecr5db==18
replace mir_2016 = mort_2016/incid_2016 if sitecr5db==19
replace mir_2016 = mort_2016/incid_2016 if sitecr5db==21
replace mir_2016 = mort_2016/incid_2016 if sitecr5db==22


** Creating variable to assess MIR for 2017 only
append using "`datapath'\version09\2-working\2017_mir_mort"
append using "`datapath'\version09\2-working\2017_mir_incid"

gen mort_2017 = cases if mortds==1 & dodyear==2017
fillmissing mort_2017 if sitecr5db==1 & sex==1
fillmissing mort_2017 if sitecr5db==1 & sex==2
fillmissing mort_2017 if sitecr5db==2 & sex==1
fillmissing mort_2017 if sitecr5db==2 & sex==2
fillmissing mort_2017 if sitecr5db==3 & sex==1
fillmissing mort_2017 if sitecr5db==3 & sex==2
fillmissing mort_2017 if sitecr5db==4 & sex==1
fillmissing mort_2017 if sitecr5db==4 & sex==2
fillmissing mort_2017 if sitecr5db==5 & sex==1
fillmissing mort_2017 if sitecr5db==5 & sex==2
fillmissing mort_2017 if sitecr5db==6 & sex==1
fillmissing mort_2017 if sitecr5db==6 & sex==2
fillmissing mort_2017 if sitecr5db==7 & sex==1
fillmissing mort_2017 if sitecr5db==7 & sex==2
fillmissing mort_2017 if sitecr5db==8 & sex==1
fillmissing mort_2017 if sitecr5db==8 & sex==2
fillmissing mort_2017 if sitecr5db==9 & sex==1
fillmissing mort_2017 if sitecr5db==9 & sex==2
fillmissing mort_2017 if sitecr5db==10 & sex==1
fillmissing mort_2017 if sitecr5db==10 & sex==2
fillmissing mort_2017 if sitecr5db==11 & sex==1
fillmissing mort_2017 if sitecr5db==11 & sex==2
fillmissing mort_2017 if sitecr5db==12 & sex==1
fillmissing mort_2017 if sitecr5db==12 & sex==2
fillmissing mort_2017 if sitecr5db==13 & sex==1
fillmissing mort_2017 if sitecr5db==13 & sex==2
fillmissing mort_2017 if sitecr5db==14 & sex==1
fillmissing mort_2017 if sitecr5db==14 & sex==2
fillmissing mort_2017 if sitecr5db==15 & sex==1
fillmissing mort_2017 if sitecr5db==15 & sex==2
fillmissing mort_2017 if sitecr5db==16 & sex==1
fillmissing mort_2017 if sitecr5db==16 & sex==2
fillmissing mort_2017 if sitecr5db==17 & sex==1
fillmissing mort_2017 if sitecr5db==17 & sex==2
fillmissing mort_2017 if sitecr5db==18 & sex==1
fillmissing mort_2017 if sitecr5db==18 & sex==2
fillmissing mort_2017 if sitecr5db==19 & sex==1
fillmissing mort_2017 if sitecr5db==19 & sex==2
fillmissing mort_2017 if sitecr5db==21 & sex==1
fillmissing mort_2017 if sitecr5db==21 & sex==2
fillmissing mort_2017 if sitecr5db==22 & sex==1
fillmissing mort_2017 if sitecr5db==22 & sex==2

gen incid_2017 = cases if incid==1 & dxyr==2017
fillmissing incid_2017 if sitecr5db==1 & sex==1
fillmissing incid_2017 if sitecr5db==1 & sex==2
fillmissing incid_2017 if sitecr5db==2 & sex==1
fillmissing incid_2017 if sitecr5db==2 & sex==2
fillmissing incid_2017 if sitecr5db==3 & sex==1
fillmissing incid_2017 if sitecr5db==3 & sex==2
fillmissing incid_2017 if sitecr5db==4 & sex==1
fillmissing incid_2017 if sitecr5db==4 & sex==2
fillmissing incid_2017 if sitecr5db==5 & sex==1
fillmissing incid_2017 if sitecr5db==5 & sex==2
fillmissing incid_2017 if sitecr5db==6 & sex==1
fillmissing incid_2017 if sitecr5db==6 & sex==2
fillmissing incid_2017 if sitecr5db==7 & sex==1
fillmissing incid_2017 if sitecr5db==7 & sex==2
fillmissing incid_2017 if sitecr5db==8 & sex==1
fillmissing incid_2017 if sitecr5db==8 & sex==2
fillmissing incid_2017 if sitecr5db==9 & sex==1
fillmissing incid_2017 if sitecr5db==9 & sex==2
fillmissing incid_2017 if sitecr5db==10 & sex==1
fillmissing incid_2017 if sitecr5db==10 & sex==2
fillmissing incid_2017 if sitecr5db==11 & sex==1
fillmissing incid_2017 if sitecr5db==11 & sex==2
fillmissing incid_2017 if sitecr5db==12 & sex==1
fillmissing incid_2017 if sitecr5db==12 & sex==2
fillmissing incid_2017 if sitecr5db==13 & sex==1
fillmissing incid_2017 if sitecr5db==13 & sex==2
fillmissing incid_2017 if sitecr5db==14 & sex==1
fillmissing incid_2017 if sitecr5db==14 & sex==2
fillmissing incid_2017 if sitecr5db==15 & sex==1
fillmissing incid_2017 if sitecr5db==15 & sex==2
fillmissing incid_2017 if sitecr5db==16 & sex==1
fillmissing incid_2017 if sitecr5db==16 & sex==2
fillmissing incid_2017 if sitecr5db==17 & sex==1
fillmissing incid_2017 if sitecr5db==17 & sex==2
fillmissing incid_2017 if sitecr5db==18 & sex==1
fillmissing incid_2017 if sitecr5db==18 & sex==2
fillmissing incid_2017 if sitecr5db==19 & sex==1
fillmissing incid_2017 if sitecr5db==19 & sex==2
fillmissing incid_2017 if sitecr5db==21 & sex==1
fillmissing incid_2017 if sitecr5db==21 & sex==2
fillmissing incid_2017 if sitecr5db==22 & sex==1
fillmissing incid_2017 if sitecr5db==22 & sex==2

gen mir_2017 = mort_2017/incid_2017 if sitecr5db==1
replace mir_2017 = mort_2017/incid_2017 if sitecr5db==2
replace mir_2017 = mort_2017/incid_2017 if sitecr5db==3
replace mir_2017 = mort_2017/incid_2017 if sitecr5db==4
replace mir_2017 = mort_2017/incid_2017 if sitecr5db==5
replace mir_2017 = mort_2017/incid_2017 if sitecr5db==6
replace mir_2017 = mort_2017/incid_2017 if sitecr5db==7
replace mir_2017 = mort_2017/incid_2017 if sitecr5db==8
replace mir_2017 = mort_2017/incid_2017 if sitecr5db==9
replace mir_2017 = mort_2017/incid_2017 if sitecr5db==10
replace mir_2017 = mort_2017/incid_2017 if sitecr5db==11
replace mir_2017 = mort_2017/incid_2017 if sitecr5db==12
replace mir_2017 = mort_2017/incid_2017 if sitecr5db==13
replace mir_2017 = mort_2017/incid_2017 if sitecr5db==14
replace mir_2017 = mort_2017/incid_2017 if sitecr5db==15
replace mir_2017 = mort_2017/incid_2017 if sitecr5db==16
replace mir_2017 = mort_2017/incid_2017 if sitecr5db==17
replace mir_2017 = mort_2017/incid_2017 if sitecr5db==18
replace mir_2017 = mort_2017/incid_2017 if sitecr5db==19
replace mir_2017 = mort_2017/incid_2017 if sitecr5db==21
replace mir_2017 = mort_2017/incid_2017 if sitecr5db==22


** Creating variable to assess MIR for 2018 only
append using "`datapath'\version09\2-working\2018_mir_mort"
append using "`datapath'\version09\2-working\2018_mir_incid"

gen mort_2018 = cases if mortds==1 & dodyear==2018
fillmissing mort_2018 if sitecr5db==1 & sex==1
fillmissing mort_2018 if sitecr5db==1 & sex==2
fillmissing mort_2018 if sitecr5db==2 & sex==1
fillmissing mort_2018 if sitecr5db==2 & sex==2
fillmissing mort_2018 if sitecr5db==3 & sex==1
fillmissing mort_2018 if sitecr5db==3 & sex==2
fillmissing mort_2018 if sitecr5db==4 & sex==1
fillmissing mort_2018 if sitecr5db==4 & sex==2
fillmissing mort_2018 if sitecr5db==5 & sex==1
fillmissing mort_2018 if sitecr5db==5 & sex==2
fillmissing mort_2018 if sitecr5db==6 & sex==1
fillmissing mort_2018 if sitecr5db==6 & sex==2
fillmissing mort_2018 if sitecr5db==7 & sex==1
fillmissing mort_2018 if sitecr5db==7 & sex==2
fillmissing mort_2018 if sitecr5db==8 & sex==1
fillmissing mort_2018 if sitecr5db==8 & sex==2
fillmissing mort_2018 if sitecr5db==9 & sex==1
fillmissing mort_2018 if sitecr5db==9 & sex==2
fillmissing mort_2018 if sitecr5db==10 & sex==1
fillmissing mort_2018 if sitecr5db==10 & sex==2
fillmissing mort_2018 if sitecr5db==11 & sex==1
fillmissing mort_2018 if sitecr5db==11 & sex==2
fillmissing mort_2018 if sitecr5db==12 & sex==1
fillmissing mort_2018 if sitecr5db==12 & sex==2
fillmissing mort_2018 if sitecr5db==13 & sex==1
fillmissing mort_2018 if sitecr5db==13 & sex==2
fillmissing mort_2018 if sitecr5db==14 & sex==1
fillmissing mort_2018 if sitecr5db==14 & sex==2
fillmissing mort_2018 if sitecr5db==15 & sex==1
fillmissing mort_2018 if sitecr5db==15 & sex==2
fillmissing mort_2018 if sitecr5db==16 & sex==1
fillmissing mort_2018 if sitecr5db==16 & sex==2
fillmissing mort_2018 if sitecr5db==17 & sex==1
fillmissing mort_2018 if sitecr5db==17 & sex==2
fillmissing mort_2018 if sitecr5db==18 & sex==1
fillmissing mort_2018 if sitecr5db==18 & sex==2
fillmissing mort_2018 if sitecr5db==19 & sex==1
fillmissing mort_2018 if sitecr5db==19 & sex==2
fillmissing mort_2018 if sitecr5db==21 & sex==1
fillmissing mort_2018 if sitecr5db==21 & sex==2
fillmissing mort_2018 if sitecr5db==22 & sex==1
fillmissing mort_2018 if sitecr5db==22 & sex==2

gen incid_2018 = cases if incid==1 & dxyr==2018
fillmissing incid_2018 if sitecr5db==1 & sex==1
fillmissing incid_2018 if sitecr5db==1 & sex==2
fillmissing incid_2018 if sitecr5db==2 & sex==1
fillmissing incid_2018 if sitecr5db==2 & sex==2
fillmissing incid_2018 if sitecr5db==3 & sex==1
fillmissing incid_2018 if sitecr5db==3 & sex==2
fillmissing incid_2018 if sitecr5db==4 & sex==1
fillmissing incid_2018 if sitecr5db==4 & sex==2
fillmissing incid_2018 if sitecr5db==5 & sex==1
fillmissing incid_2018 if sitecr5db==5 & sex==2
fillmissing incid_2018 if sitecr5db==6 & sex==1
fillmissing incid_2018 if sitecr5db==6 & sex==2
fillmissing incid_2018 if sitecr5db==7 & sex==1
fillmissing incid_2018 if sitecr5db==7 & sex==2
fillmissing incid_2018 if sitecr5db==8 & sex==1
fillmissing incid_2018 if sitecr5db==8 & sex==2
fillmissing incid_2018 if sitecr5db==9 & sex==1
fillmissing incid_2018 if sitecr5db==9 & sex==2
fillmissing incid_2018 if sitecr5db==10 & sex==1
fillmissing incid_2018 if sitecr5db==10 & sex==2
fillmissing incid_2018 if sitecr5db==11 & sex==1
fillmissing incid_2018 if sitecr5db==11 & sex==2
fillmissing incid_2018 if sitecr5db==12 & sex==1
fillmissing incid_2018 if sitecr5db==12 & sex==2
fillmissing incid_2018 if sitecr5db==13 & sex==1
fillmissing incid_2018 if sitecr5db==13 & sex==2
fillmissing incid_2018 if sitecr5db==14 & sex==1
fillmissing incid_2018 if sitecr5db==14 & sex==2
fillmissing incid_2018 if sitecr5db==15 & sex==1
fillmissing incid_2018 if sitecr5db==15 & sex==2
fillmissing incid_2018 if sitecr5db==16 & sex==1
fillmissing incid_2018 if sitecr5db==16 & sex==2
fillmissing incid_2018 if sitecr5db==17 & sex==1
fillmissing incid_2018 if sitecr5db==17 & sex==2
fillmissing incid_2018 if sitecr5db==18 & sex==1
fillmissing incid_2018 if sitecr5db==18 & sex==2
fillmissing incid_2018 if sitecr5db==19 & sex==1
fillmissing incid_2018 if sitecr5db==19 & sex==2
fillmissing incid_2018 if sitecr5db==21 & sex==1
fillmissing incid_2018 if sitecr5db==21 & sex==2
fillmissing incid_2018 if sitecr5db==22 & sex==1
fillmissing incid_2018 if sitecr5db==22 & sex==2

gen mir_2018 = mort_2018/incid_2018 if sitecr5db==1
replace mir_2018 = mort_2018/incid_2018 if sitecr5db==2
replace mir_2018 = mort_2018/incid_2018 if sitecr5db==3
replace mir_2018 = mort_2018/incid_2018 if sitecr5db==4
replace mir_2018 = mort_2018/incid_2018 if sitecr5db==5
replace mir_2018 = mort_2018/incid_2018 if sitecr5db==6
replace mir_2018 = mort_2018/incid_2018 if sitecr5db==7
replace mir_2018 = mort_2018/incid_2018 if sitecr5db==8
replace mir_2018 = mort_2018/incid_2018 if sitecr5db==9
replace mir_2018 = mort_2018/incid_2018 if sitecr5db==10
replace mir_2018 = mort_2018/incid_2018 if sitecr5db==11
replace mir_2018 = mort_2018/incid_2018 if sitecr5db==12
replace mir_2018 = mort_2018/incid_2018 if sitecr5db==13
replace mir_2018 = mort_2018/incid_2018 if sitecr5db==14
replace mir_2018 = mort_2018/incid_2018 if sitecr5db==15
replace mir_2018 = mort_2018/incid_2018 if sitecr5db==16
replace mir_2018 = mort_2018/incid_2018 if sitecr5db==17
replace mir_2018 = mort_2018/incid_2018 if sitecr5db==18
replace mir_2018 = mort_2018/incid_2018 if sitecr5db==19
replace mir_2018 = mort_2018/incid_2018 if sitecr5db==21
replace mir_2018 = mort_2018/incid_2018 if sitecr5db==22

** Condense dataset
preserve
keep sitecr5db sex mir_2016 mort_2016 incid_2016 mir_2017 mort_2017 incid_2017 mir_2018 mort_2018 incid_2018
sort sitecr5db sex
contract sitecr5db sex mir_2016 mort_2016 incid_2016 mir_2017 mort_2017 incid_2017 mir_2018 mort_2018 incid_2018
drop _freq
gen id = _n
order id
drop if id==2|id==3|id==5|id==6|id==8|id==9|id==11|id==13|id==14 ///
		|id==16|id==17|id==19|id==20|id==22|id==23|id==25|id==26 ///
		|id==28|id==29|id==31|id==32|id==34|id==35|id==38|id==41 ///
		|id==42|id==44|id==45|id==47|id==49|id==51|id==52|id==54 ///
		|id==55|id==57|id==58|id==60|id==61|id==63|id==64|id==67 ///
		|id==69|id==70|id==72|id==73|id==75|id==76|id==78|id==80 ///
		|id==82|id==83|id==85|id==87|id==88|id==90|id==91|id==93 ///
		|id==94|id==96|id==97
//60 deleted
drop if id==12|id==40|id==81| ///
		id==100|id==101|id==103|id==104		
drop id
gen mir_iarc_2016 = mir_2016*100
gen mir_iarc_2017 = mir_2017*100
gen mir_iarc_2018 = mir_2018*100
format mir_iarc_2016 mir_iarc_2017 mir_iarc_2018 %3.1f
order sitecr5db sex mir_iarc_2016 mort_2016 incid_2016 mir_iarc_2017 mort_2017 incid_2017 mir_iarc_2018 mort_2018 incid_2018
save "`datapath'\version09\3-output\2016_2017_2018_mir", replace


** Create MS Word results table with absolute case totals + the MIRs for ungrouped years (2016, 2017, 2018), by site, by sex (see dofile 30b_report cancer ANNUALRPT.do)
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
Date Prepared: 08-AUG-2022. 
Prepared by: JC using Stata v17.0
CanReg5 v5.43 (incidence) data release date: 21-May-2021.
REDCap v12.3.3 (death) data release date: 06-May-2022.
Generated using Dofile: 22a_MIRs prep_2016.do; 22b_MIRs prep_2017.do; 22c_MIRs prep_2018.do; 22d_MIRs_2016-2018.do
putdocx textblock end
putdocx paragraph, halign(center)
putdocx text ("Table: Case Totals + Mortality:Incidence Ratios for BNR-Cancer Ungrouped Years (2016, 2017, 2018)"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Background"), bold
putdocx textblock begin
A data quality assessment performed by the IARC Hub noted large M:I ratios in certain sites. IARC Hub used mortality data from the CARPHA mortality database, which collects data from Ministry of Health and Wellness. This report performs a secondary check using mortality data collected directly from the Barbados Registration Dept. This data quality indicator is one method of assessing completeness.
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) For the incidence dataset, the 2016-2018 annual report incidence dataset was used to organize the data into a format to perform the M:I analysis (cancer dataset used: "`datapath'\version09\3-output\2008_2013-2018_cancer_reportable_nonsurvival_identifiable"; Note: 2008 cases were ultimately excluded)
putdocx textblock end
putdocx textblock begin
(2) For the mortality dataset, the 2016, 2017 and 2018 annual report mortality datasets were used to organize the data into a format to perform the M:I analysis (cancer dataset used: (2016) "`datapath'\version09\3-output\2016_prep mort_identifiable"; (2017) "`datapath'\version09\3-output\2017_prep mort_identifiable"; (2018) "`datapath'\version09\3-output\2018_prep mort_identifiable").
putdocx textblock end
putdocx textblock begin
(3) All the incidence and mortality datasets were checked to ensure the site variable, sitecr5db, was not missing and site codes were assigned if it was missing in the dataset.
putdocx textblock end
putdocx textblock begin
(4) The calculation used for the M:I ratio was number of death cases per site per sex / number of incident cases per site per sex.
putdocx textblock end
putdocx textblock begin
(5) Sites that had a M:I ratio exceeding a value of 1 (one) or >99% were checked case by case using the Mortality data + the Casefinding database to determine why that death case was excluded from the incidence dataset.  The datasets and database used for this comparison review process are: MORTALITY:"`datapath'\version09\2-working\yyyy_mir_mort_prep"; INCIDENCE:"`datapath'\version09\2-working\yyyy_mir_incid_prep" and "`datapath'\version09\3-output\2008_2013-2018_cancer_reportable_nonsurvival_identifiable"; CASEFINDING DATABASES:"...Sync\Cancer\CF Database\MasterDb\SyncDb\Databases\Master" and CanReg5 database. The outcome of this investigation can be found in the excel workbook saved in the pathway: "...The University of the West Indies\FORDE, Shelly-Ann - BNR\REPORTS\Annual Reports\2016-2018 Cancer Report\2022-08-22_mir_reviews.xlsx" and also in the pathway: "`datapath'\version09\3-output\2022-08-22_mir_reviews.xlsx".
putdocx textblock end
putdocx pagebreak
putdocx table tbl1 = data(sitecr5db sex mir_iarc_2016 mort_2016 incid_2016 mir_iarc_2017 mort_2017 incid_2017 mir_iarc_2018 mort_2018 incid_2018), halign(center) varnames
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

putdocx save "`datapath'\version09\3-output\2022-08-22_mir_ungrouped_stats_V01.docx", replace
putdocx clear
restore



** Creating variables to assess MIR for grouped years (2016-2018)
egen cases_mort_all = total(cases) if mortds==1 & sitecr5db==1 & sex==1
sum cases if mortds==1 & sitecr5db==1 & sex==2
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==1 & sex==2
sum cases if mortds==1 & sitecr5db==2 & sex==1
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==2 & sex==1
sum cases if mortds==1 & sitecr5db==2 & sex==2
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==2 & sex==2
sum cases if mortds==1 & sitecr5db==3 & sex==1
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==3 & sex==1
sum cases if mortds==1 & sitecr5db==3 & sex==2
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==3 & sex==2
sum cases if mortds==1 & sitecr5db==4 & sex==1
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==4 & sex==1
sum cases if mortds==1 & sitecr5db==4 & sex==2
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==4 & sex==2
sum cases if mortds==1 & sitecr5db==5 & sex==1
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==5 & sex==1
sum cases if mortds==1 & sitecr5db==5 & sex==2
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==5 & sex==2
sum cases if mortds==1 & sitecr5db==6 & sex==1
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==6 & sex==1
sum cases if mortds==1 & sitecr5db==6 & sex==2
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==6 & sex==2
sum cases if mortds==1 & sitecr5db==7 & sex==1
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==7 & sex==1
sum cases if mortds==1 & sitecr5db==7 & sex==2
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==7 & sex==2
sum cases if mortds==1 & sitecr5db==8 & sex==1
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==8 & sex==1
sum cases if mortds==1 & sitecr5db==8 & sex==2
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==8 & sex==2
sum cases if mortds==1 & sitecr5db==9 & sex==1
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==9 & sex==1
sum cases if mortds==1 & sitecr5db==9 & sex==2
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==9 & sex==2
sum cases if mortds==1 & sitecr5db==10 & sex==1
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==10 & sex==1
sum cases if mortds==1 & sitecr5db==10 & sex==2
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==10 & sex==2
sum cases if mortds==1 & sitecr5db==11 & sex==1
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==11 & sex==1
sum cases if mortds==1 & sitecr5db==11 & sex==2
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==11 & sex==2
sum cases if mortds==1 & sitecr5db==12 & sex==1
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==12 & sex==1
sum cases if mortds==1 & sitecr5db==12 & sex==2
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==12 & sex==2
sum cases if mortds==1 & sitecr5db==13 & sex==1
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==13 & sex==1
sum cases if mortds==1 & sitecr5db==13 & sex==2
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==13 & sex==2
sum cases if mortds==1 & sitecr5db==14 & sex==1
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==14 & sex==1
sum cases if mortds==1 & sitecr5db==14 & sex==2
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==14 & sex==2
sum cases if mortds==1 & sitecr5db==15 & sex==1
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==15 & sex==1
sum cases if mortds==1 & sitecr5db==15 & sex==2
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==15 & sex==2
sum cases if mortds==1 & sitecr5db==16 & sex==1
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==16 & sex==1
sum cases if mortds==1 & sitecr5db==16 & sex==2
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==16 & sex==2
sum cases if mortds==1 & sitecr5db==17 & sex==1
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==17 & sex==1
sum cases if mortds==1 & sitecr5db==17 & sex==2
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==17 & sex==2
sum cases if mortds==1 & sitecr5db==18 & sex==1
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==18 & sex==1
sum cases if mortds==1 & sitecr5db==18 & sex==2
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==18 & sex==2
sum cases if mortds==1 & sitecr5db==19 & sex==1
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==19 & sex==1
sum cases if mortds==1 & sitecr5db==19 & sex==2
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==19 & sex==2
sum cases if mortds==1 & sitecr5db==21 & sex==1
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==21 & sex==1
sum cases if mortds==1 & sitecr5db==21 & sex==2
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==21 & sex==2
sum cases if mortds==1 & sitecr5db==22 & sex==1
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==22 & sex==1
sum cases if mortds==1 & sitecr5db==22 & sex==2
replace cases_mort_all = r(sum) if mortds==1 & sitecr5db==22 & sex==2


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
save "`datapath'\version09\3-output\2016-2018_mir", replace

** Create MS Word results table with absolute case totals + the MIRs for grouped years (2016-2018), by site, by sex (see dofile 30b_report cancer ANNUALRPT.do)
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
Date Prepared: 22-AUG-2022. 
Prepared by: JC using Stata v17.0
CanReg5 v5.43 (incidence) data release date: 21-May-2021.
REDCap v12.3.3 (death) data release date: 06-May-2022.
Generated using Dofile: 22a_MIRs prep_2016.do; 22b_MIRs prep_2017.do; 22c_MIRs prep_2018.do; 22d_MIRs_2016-2018.do
putdocx textblock end
putdocx paragraph, halign(center)
putdocx text ("Table: Case Totals + Mortality:Incidence Ratios for BNR-Cancer Grouped Years (2016-2018)"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Background"), bold
putdocx textblock begin
A data quality assessment performed by the IARC Hub noted large M:I ratios in certain sites. IARC Hub used mortality data from the CARPHA mortality database, which collects data from Ministry of Health and Wellness. This report performs a secondary check using mortality data collected directly from the Barbados Registration Dept. This data quality indicator is one method of assessing completeness.
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) For the incidence dataset, the 2016-2018 annual report incidence dataset was used to organize the data into a format to perform the M:I analysis (cancer dataset used: "`datapath'\version09\3-output\2008_2013-2018_cancer_reportable_nonsurvival_identifiable"; Note: 2008 cases were ultimately excluded)
putdocx textblock end
putdocx textblock begin
(2) For the mortality dataset, the 2016, 2017 and 2018 annual report mortality datasets were used to organize the data into a format to perform the M:I analysis (cancer dataset used: (2016) "`datapath'\version09\3-output\2016_prep mort_identifiable"; (2017) "`datapath'\version09\3-output\2017_prep mort_identifiable"; (2018) "`datapath'\version09\3-output\2018_prep mort_identifiable").
putdocx textblock end
putdocx textblock begin
(3) All the incidence and mortality datasets were checked to ensure the site variable, sitecr5db, was not missing and site codes were assigned if it was missing in the dataset.
putdocx textblock end
putdocx textblock begin
(4) The calculation used for the M:I ratio was number of death cases per site per sex / number of incident cases per site per sex.
putdocx textblock end
putdocx textblock begin
(5) Sites that had a M:I ratio exceeding a value of 1 (one) or >99% were checked case by case using the Mortality data + the Casefinding database to determine why that death case was excluded from the incidence dataset.  The datasets and database used for this comparison review process are: MORTALITY:"`datapath'\version09\2-working\yyyy_mir_mort_prep"; INCIDENCE:"`datapath'\version09\2-working\yyyy_mir_incid_prep" and "`datapath'\version09\3-output\2008_2013-2018_cancer_reportable_nonsurvival_identifiable"; CASEFINDING DATABASES:"...Sync\Cancer\CF Database\MasterDb\SyncDb\Databases\Master" and CanReg5 database. The outcome of this investigation can be found in the excel workbook saved in the pathway: "...The University of the West Indies\FORDE, Shelly-Ann - BNR\REPORTS\Annual Reports\2016-2018 Cancer Report\2022-08-22_mir_reviews.xlsx" and also in the pathway: "`datapath'\version09\3-output\2022-08-22_mir_reviews.xlsx".
putdocx textblock end
putdocx pagebreak
putdocx table tbl1 = data(sitecr5db sex mir_all mir_iarc cases_mort_all cases_incid_all), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)

putdocx save "`datapath'\version09\3-output\2022-08-22_mir_grouped_stats_V01.docx", replace
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
//Subtract all deaths (2016-2018) that were captured at CF/ABS phase
replace cases_mort_all = cases_mort_all - 7 if sitecr5db==1 & sex==1 //Mouth & pharynx (female)
replace cases_mort_all = cases_mort_all - 38 if sitecr5db==1 & sex==2 //Mouth & pharynx (male)
replace cases_mort_all = cases_mort_all - 2 if sitecr5db==2 & sex==1 //Oesophagus (female)
replace cases_mort_all = cases_mort_all - 19 if sitecr5db==2 & sex==2 //Oesophagus (male)
replace cases_mort_all = cases_mort_all - 18 if sitecr5db==3 & sex==1 //Stomach (female)
replace cases_mort_all = cases_mort_all - 9 if sitecr5db==3 & sex==2 //Stomach (male)
replace cases_mort_all = cases_mort_all - 7 if sitecr5db==5 & sex==1 //Liver (female)
replace cases_mort_all = cases_mort_all - 3 if sitecr5db==5 & sex==2 //Liver (male)
replace cases_mort_all = cases_mort_all - 18 if sitecr5db==6 & sex==1 //Pancreas (female)
replace cases_mort_all = cases_mort_all - 14 if sitecr5db==6 & sex==2 //Pancreas (male)
replace cases_mort_all = cases_mort_all - 12 if sitecr5db==8 & sex==1 //Lung (female)
replace cases_mort_all = cases_mort_all - 21 if sitecr5db==8 & sex==2 //Lung (male)
replace cases_mort_all = cases_mort_all - 16 if sitecr5db==11 & sex==1 //Cervix (female)
replace cases_mort_all = cases_mort_all - 15 if sitecr5db==13 & sex==1 //Ovary (female)
replace cases_mort_all = cases_mort_all - 5 if sitecr5db==16 & sex==1 //Kidney (female)
replace cases_mort_all = cases_mort_all - 7 if sitecr5db==17 & sex==1 //Bladder (female)
replace cases_mort_all = cases_mort_all - 4 if sitecr5db==18 & sex==1 //Brain (female)
replace cases_mort_all = cases_mort_all - 7 if sitecr5db==18 & sex==2 //Brain (male)
replace cases_mort_all = cases_mort_all - 2 if sitecr5db==19 & sex==2 //Thyroid (male)
replace cases_mort_all = cases_mort_all - 32 if sitecr5db==22 & sex==1 //Leukaemia (female)
replace cases_mort_all = cases_mort_all - 22 if sitecr5db==22 & sex==2 //Leukaemia (male)

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

** Create MS Word results table with absolute case totals + the "adjusted" MIRs for grouped years (2016-2018), by site, by sex
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
Date Prepared: 22-AUG-2022. 
Prepared by: JC using Stata v17.0
CanReg5 v5.43 (incidence) data release date: 21-May-2021.
REDCap v12.3.3 (death) data release date: 06-May-2022.
Generated using Dofile: 22a_MIRs prep_2016.do; 22b_MIRs prep_2017.do; 22c_MIRs prep_2018.do; 22d_MIRs_2016-2018.do
putdocx textblock end
putdocx paragraph, halign(center)
putdocx text ("Case Totals + 'Adjusted' Mortality:Incidence Ratios for BNR-Cancer Grouped Years (2016-2018)"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Background"), bold
putdocx textblock begin
A data quality assessment performed by the IARC Hub noted large M:I ratios in certain sites. IARC Hub used mortality data from the CARPHA mortality database, which collects data from Ministry of Health and Wellness. This report performs a secondary check using mortality data collected directly from the Barbados Registration Dept. This data quality indicator is one method of assessing completeness.
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) For the incidence dataset, the 2016-2018 annual report incidence dataset was used to organize the data into a format to perform the M:I analysis (cancer dataset used: "`datapath'\version09\3-output\2008_2013-2018_cancer_reportable_nonsurvival_identifiable"; Note: 2008 cases were ultimately excluded)
putdocx textblock end
putdocx textblock begin
(2) For the mortality dataset, the 2016, 2017 and 2018 annual report mortality datasets were used to organize the data into a format to perform the M:I analysis (cancer dataset used: (2016) "`datapath'\version09\3-output\2016_prep mort_identifiable"; (2017) "`datapath'\version09\3-output\2017_prep mort_identifiable"; (2018) "`datapath'\version09\3-output\2018_prep mort_identifiable").
putdocx textblock end
putdocx textblock begin
(3) All the incidence and mortality datasets were checked to ensure the site variable, sitecr5db, was not missing and site codes were assigned if it was missing in the dataset.
putdocx textblock end
putdocx textblock begin
(4) The calculation used for the M:I ratio was number of death cases per site per sex / number of incident cases per site per sex.
putdocx textblock end
putdocx textblock begin
(5) Sites that had a M:I ratio exceeding a value of 1 (one) or >99% were checked case by case using the Mortality data + the Casefinding database to determine why that death case was excluded from the incidence dataset.  The datasets and database used for this comparison review process are: MORTALITY:"`datapath'\version09\2-working\yyyy_mir_mort_prep"; INCIDENCE:"`datapath'\version09\2-working\yyyy_mir_incid_prep" and "`datapath'\version09\3-output\2008_2013-2018_cancer_reportable_nonsurvival_identifiable"; CASEFINDING DATABASES:"...Sync\Cancer\CF Database\MasterDb\SyncDb\Databases\Master" and CanReg5 database. The outcome of this investigation can be found in the excel workbook saved in the pathway: "...The University of the West Indies\FORDE, Shelly-Ann - BNR\REPORTS\Annual Reports\2016-2018 Cancer Report\2022-08-22_mir_reviews.xlsx" and also in the pathway: "`datapath'\version09\3-output\2022-08-22_mir_reviews.xlsx".
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

putdocx save "`datapath'\version09\3-output\2022-08-22_adjusted_mir_grouped_stats_V01.docx", replace
putdocx clear

** In the above document, there are still some sites with 
drop mir_all mir_iarc

** Remove deaths flagged at review
//Subtract all deaths (2016-2018) that were captured at CF/ABS phase
replace cases_mort_all = cases_mort_all - 21 if sitecr5db==5 & sex==2 //Liver (male)
replace cases_mort_all = cases_mort_all - 3 if sitecr5db==9 & sex==1 //Melanoma, skin (female)


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
Date Prepared: 22-AUG-2022. 
Prepared by: JC using Stata v17.0
CanReg5 v5.43 (incidence) data release date: 21-May-2021.
REDCap v12.3.3 (death) data release date: 06-May-2022.
Generated using Dofile: 22a_MIRs prep_2016.do; 22b_MIRs prep_2017.do; 22c_MIRs prep_2018.do; 22d_MIRs_2016-2018.do
putdocx textblock end
putdocx paragraph, halign(center)
putdocx text ("Case Totals + 'Adjusted' Mortality:Incidence Ratios for BNR-Cancer Grouped Years (2016-2018)"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Background"), bold
putdocx textblock begin
A data quality assessment performed by the IARC Hub noted large M:I ratios in certain sites. IARC Hub used mortality data from the CARPHA mortality database, which collects data from Ministry of Health and Wellness. This report performs a secondary check using mortality data collected directly from the Barbados Registration Dept. This data quality indicator is one method of assessing completeness.
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) For the incidence dataset, the 2016-2018 annual report incidence dataset was used to organize the data into a format to perform the M:I analysis (cancer dataset used: "`datapath'\version09\3-output\2008_2013-2018_cancer_reportable_nonsurvival_identifiable"; Note: 2008 cases were ultimately excluded)
putdocx textblock end
putdocx textblock begin
(2) For the mortality dataset, the 2016, 2017 and 2018 annual report mortality datasets were used to organize the data into a format to perform the M:I analysis (cancer dataset used: (2016) "`datapath'\version09\3-output\2016_prep mort_identifiable"; (2017) "`datapath'\version09\3-output\2017_prep mort_identifiable"; (2018) "`datapath'\version09\3-output\2018_prep mort_identifiable").
putdocx textblock end
putdocx textblock begin
(3) All the incidence and mortality datasets were checked to ensure the site variable, sitecr5db, was not missing and site codes were assigned if it was missing in the dataset.
putdocx textblock end
putdocx textblock begin
(4) The calculation used for the M:I ratio was number of death cases per site per sex / number of incident cases per site per sex.
putdocx textblock end
putdocx textblock begin
(5) Sites that had a M:I ratio exceeding a value of 1 (one) or >99% were checked case by case using the Mortality data + the Casefinding database to determine why that death case was excluded from the incidence dataset.  The datasets and database used for this comparison review process are: MORTALITY:"`datapath'\version09\2-working\yyyy_mir_mort_prep"; INCIDENCE:"`datapath'\version09\2-working\yyyy_mir_incid_prep" and "`datapath'\version09\3-output\2008_2013-2018_cancer_reportable_nonsurvival_identifiable"; CASEFINDING DATABASES:"...Sync\Cancer\CF Database\MasterDb\SyncDb\Databases\Master" and CanReg5 database. The outcome of this investigation can be found in the excel workbook saved in the pathway: "...The University of the West Indies\FORDE, Shelly-Ann - BNR\REPORTS\Annual Reports\2016-2018 Cancer Report\2022-08-22_mir_reviews.xlsx" and also in the pathway: "`datapath'\version09\3-output\2022-08-22_mir_reviews.xlsx".
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

putdocx save "`datapath'\version09\3-output\2022-08-22_adjusted_mir_grouped_stats_V02.docx", replace
putdocx clear

save "`datapath'\version09\3-output\2016-2018_mirs_adjusted", replace