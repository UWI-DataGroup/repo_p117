** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          60_uncertainty.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      22-SEP-2021
    // 	date last modified      04-OCT-2021
    //  algorithm task          Performing sensitivity analysis using select sites from cleaned, current cancer dataset
    //  status                  Completed
    //  objective               To have a tornado diagram for select sites to determine reason for fluctuations in cases over 2013-2015
    //  methods                 Using bootstrap and bsample commands for repetitions and replacements

    ** General algorithm set-up
    version 16.1
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
    log using "`logpath'\60_uncertainty.smcl", replace
** HEADER -----------------------------------------------------

* ************************************************************************
* PREP AND FORMAT
**************************************************************************
use "`datapath'\version02\3-output\2008_2013_2014_2015_iarchub_nonsurvival_reportable", clear


** Use top 10 from 2015 annual report along with sites identified with fluctuations from IARC Hub DQ assessment
keep age siteiarc dxyr sex
drop if dxyr==2008

** Create dataset with absolute case totals for sites based on fluctuations noted in IARC DQ excel sheet
** (X:\The University of the West Indies\FORDE, Shelly-Ann - BNR\REPORTS\Annual Reports\2015 Cancer Report\Data Discussion with IARC.xlsx)

** Cervix
count if dxyr==2013 & siteiarc==32
gen absolutetot = r(N) if dxyr==2013 & siteiarc==32

count if dxyr==2014 & siteiarc==32
replace absolutetot = r(N) if dxyr==2014 & siteiarc==32

count if dxyr==2015 & siteiarc==32
replace absolutetot = r(N) if dxyr==2015 & siteiarc==32

** Rectum (male + female)
count if dxyr==2013 & siteiarc==14
replace absolutetot = r(N) if dxyr==2013 & siteiarc==14

count if dxyr==2014 & siteiarc==14
replace absolutetot = r(N) if dxyr==2014 & siteiarc==14

count if dxyr==2015 & siteiarc==14
replace absolutetot = r(N) if dxyr==2015 & siteiarc==14

** Multiple Myeloma (female only)
count if dxyr==2013 & siteiarc==55 & sex==1
replace absolutetot = r(N) if dxyr==2013 & siteiarc==55 & sex==1

count if dxyr==2014 & siteiarc==55 & sex==1
replace absolutetot = r(N) if dxyr==2014 & siteiarc==55 & sex==1

count if dxyr==2015 & siteiarc==55 & sex==1
replace absolutetot = r(N) if dxyr==2015 & siteiarc==55 & sex==1

** Stomach (female only)
count if dxyr==2013 & siteiarc==11 & sex==1
replace absolutetot = r(N) if dxyr==2013 & siteiarc==11 & sex==1

count if dxyr==2014 & siteiarc==11 & sex==1
replace absolutetot = r(N) if dxyr==2014 & siteiarc==11 & sex==1

count if dxyr==2015 & siteiarc==11 & sex==1
replace absolutetot = r(N) if dxyr==2015 & siteiarc==11 & sex==1

** Lung (female only)
count if dxyr==2013 & siteiarc==21 & sex==1
replace absolutetot = r(N) if dxyr==2013 & siteiarc==21 & sex==1

count if dxyr==2014 & siteiarc==21 & sex==1
replace absolutetot = r(N) if dxyr==2014 & siteiarc==21 & sex==1

count if dxyr==2015 & siteiarc==21 & sex==1
replace absolutetot = r(N) if dxyr==2015 & siteiarc==21 & sex==1

** Bladder (female only)
count if dxyr==2013 & siteiarc==45 & sex==1
replace absolutetot = r(N) if dxyr==2013 & siteiarc==45 & sex==1

count if dxyr==2014 & siteiarc==45 & sex==1
replace absolutetot = r(N) if dxyr==2014 & siteiarc==45 & sex==1

count if dxyr==2015 & siteiarc==45 & sex==1
replace absolutetot = r(N) if dxyr==2015 & siteiarc==45 & sex==1
/*
** All Sites (male + female)
count if dxyr==2013
gen absolutetotall = r(N) if dxyr==2013

count if dxyr==2014
replace absolutetotall = r(N) if dxyr==2014

count if dxyr==2015
replace absolutetotall = r(N) if dxyr==2015
*/

** Condense dataset to add absolute case totals to final dataset with the uncertainty results
preserve
drop if absolutetot==.
drop age
sort siteiarc dxyr
contract siteiarc dxyr absolutetot //absolutetotall
drop _freq
rename dxyr year
sort siteiarc year
save "`datapath'\version02\2-working\2013_2014_2015_absolutetotals", replace 
restore


** Create 5-year age group, age group identifier and mid-age variable
gen agegroup = 1 if age<5
replace agegroup = 2 if age>4 & age<10
replace agegroup = 3 if age>10 & age<15
replace agegroup = 4 if age>14 & age<20
replace agegroup = 5 if age>19 & age<25
replace agegroup = 6 if age>24 & age<30
replace agegroup = 7 if age>29 & age<35
replace agegroup = 8 if age>34 & age<40
replace agegroup = 9 if age>39 & age<45
replace agegroup = 10 if age>44 & age<50
replace agegroup = 11 if age>49 & age<55
replace agegroup = 12 if age>54 & age<60
replace agegroup = 13 if age>59 & age<65
replace agegroup = 14 if age>64 & age<70
replace agegroup = 15 if age>69 & age<75
replace agegroup = 16 if age>74 & age<80
replace agegroup = 17 if age>79 & age<85
replace agegroup = 18 if age>84

label define agegroup_lab 	1 "00-04"  2 "05-09"  3 "10-14"		///
						4 "15-19"  5 "20-24"  6 "25-29"		///
						7 "30-34"  8 "35-39"  9 "40-44"		///
						10 "45-49" 11 "50-54" 12 "55-59"	///
						13 "60-64" 14 "65-69" 15 "70-74"	///
						16 "75-79" 17 "80-84" 18 "85+", modify
label values agegroup agegroup_lab

/*
gen midage = 2 if agegroup==1
replace midage = 7 if agegroup==2
replace midage = 12 if agegroup==3
replace midage = 17 if agegroup==4
replace midage = 22 if agegroup==5
replace midage = 27 if agegroup==6
replace midage = 32 if agegroup==7
replace midage = 37 if agegroup==8
replace midage = 42 if agegroup==9
replace midage = 47 if agegroup==10
replace midage = 52 if agegroup==11
replace midage = 57 if agegroup==12
replace midage = 62 if agegroup==13
replace midage = 67 if agegroup==14
replace midage = 72 if agegroup==15
replace midage = 77 if agegroup==16
replace midage = 82 if agegroup==17
replace midage = 92 if agegroup==18
*/

** Create variables with count of cases per age group per site
** Using top 10 from 2015 annual rpt + sites from IARC Hub DQ assessment
labelbook siteiarc_lab

** Prostate
count if agegroup==1 & siteiarc==39
gen cases = r(N) if agegroup==1 & siteiarc==39
count if agegroup==2 & siteiarc==39
replace cases = r(N) if agegroup==2 & siteiarc==39
count if agegroup==3 & siteiarc==39
replace cases = r(N) if agegroup==3 & siteiarc==39
count if agegroup==4 & siteiarc==39
replace cases = r(N) if agegroup==4 & siteiarc==39
count if agegroup==5 & siteiarc==39
replace cases = r(N) if agegroup==5 & siteiarc==39
count if agegroup==6 & siteiarc==39
replace cases = r(N) if agegroup==6 & siteiarc==39
count if agegroup==7 & siteiarc==39
replace cases = r(N) if agegroup==7 & siteiarc==39
count if agegroup==8 & siteiarc==39
replace cases = r(N) if agegroup==8 & siteiarc==39
count if agegroup==9 & siteiarc==39
replace cases = r(N) if agegroup==9 & siteiarc==39
count if agegroup==10 & siteiarc==39
replace cases = r(N) if agegroup==10 & siteiarc==39
count if agegroup==11 & siteiarc==39
replace cases = r(N) if agegroup==11 & siteiarc==39
count if agegroup==12 & siteiarc==39
replace cases = r(N) if agegroup==12 & siteiarc==39
count if agegroup==13 & siteiarc==39
replace cases = r(N) if agegroup==13 & siteiarc==39
count if agegroup==14 & siteiarc==39
replace cases = r(N) if agegroup==14 & siteiarc==39
count if agegroup==15 & siteiarc==39
replace cases = r(N) if agegroup==15 & siteiarc==39
count if agegroup==16 & siteiarc==39
replace cases = r(N) if agegroup==16 & siteiarc==39
count if agegroup==17 & siteiarc==39
replace cases = r(N) if agegroup==17 & siteiarc==39
count if agegroup==18 & siteiarc==39
replace cases = r(N) if agegroup==18 & siteiarc==39

** Breast
count if agegroup==1 & siteiarc==29
replace cases = r(N) if agegroup==1 & siteiarc==29
count if agegroup==2 & siteiarc==29
replace cases = r(N) if agegroup==2 & siteiarc==29
count if agegroup==3 & siteiarc==29
replace cases = r(N) if agegroup==3 & siteiarc==29
count if agegroup==4 & siteiarc==29
replace cases = r(N) if agegroup==4 & siteiarc==29
count if agegroup==5 & siteiarc==29
replace cases = r(N) if agegroup==5 & siteiarc==29
count if agegroup==6 & siteiarc==29
replace cases = r(N) if agegroup==6 & siteiarc==29
count if agegroup==7 & siteiarc==29
replace cases = r(N) if agegroup==7 & siteiarc==29
count if agegroup==8 & siteiarc==29
replace cases = r(N) if agegroup==8 & siteiarc==29
count if agegroup==9 & siteiarc==29
replace cases = r(N) if agegroup==9 & siteiarc==29
count if agegroup==10 & siteiarc==29
replace cases = r(N) if agegroup==10 & siteiarc==29
count if agegroup==11 & siteiarc==29
replace cases = r(N) if agegroup==11 & siteiarc==29
count if agegroup==12 & siteiarc==29
replace cases = r(N) if agegroup==12 & siteiarc==29
count if agegroup==13 & siteiarc==29
replace cases = r(N) if agegroup==13 & siteiarc==29
count if agegroup==14 & siteiarc==29
replace cases = r(N) if agegroup==14 & siteiarc==29
count if agegroup==15 & siteiarc==29
replace cases = r(N) if agegroup==15 & siteiarc==29
count if agegroup==16 & siteiarc==29
replace cases = r(N) if agegroup==16 & siteiarc==29
count if agegroup==17 & siteiarc==29
replace cases = r(N) if agegroup==17 & siteiarc==29
count if agegroup==18 & siteiarc==29
replace cases = r(N) if agegroup==18 & siteiarc==29

** Colon
count if agegroup==1 & siteiarc==13
replace cases = r(N) if agegroup==1 & siteiarc==13
count if agegroup==2 & siteiarc==13
replace cases = r(N) if agegroup==2 & siteiarc==13
count if agegroup==3 & siteiarc==13
replace cases = r(N) if agegroup==3 & siteiarc==13
count if agegroup==4 & siteiarc==13
replace cases = r(N) if agegroup==4 & siteiarc==13
count if agegroup==5 & siteiarc==13
replace cases = r(N) if agegroup==5 & siteiarc==13
count if agegroup==6 & siteiarc==13
replace cases = r(N) if agegroup==6 & siteiarc==13
count if agegroup==7 & siteiarc==13
replace cases = r(N) if agegroup==7 & siteiarc==13
count if agegroup==8 & siteiarc==13
replace cases = r(N) if agegroup==8 & siteiarc==13
count if agegroup==9 & siteiarc==13
replace cases = r(N) if agegroup==9 & siteiarc==13
count if agegroup==10 & siteiarc==13
replace cases = r(N) if agegroup==10 & siteiarc==13
count if agegroup==11 & siteiarc==13
replace cases = r(N) if agegroup==11 & siteiarc==13
count if agegroup==12 & siteiarc==13
replace cases = r(N) if agegroup==12 & siteiarc==13
count if agegroup==13 & siteiarc==13
replace cases = r(N) if agegroup==13 & siteiarc==13
count if agegroup==14 & siteiarc==13
replace cases = r(N) if agegroup==14 & siteiarc==13
count if agegroup==15 & siteiarc==13
replace cases = r(N) if agegroup==15 & siteiarc==13
count if agegroup==16 & siteiarc==13
replace cases = r(N) if agegroup==16 & siteiarc==13
count if agegroup==17 & siteiarc==13
replace cases = r(N) if agegroup==17 & siteiarc==13
count if agegroup==18 & siteiarc==13
replace cases = r(N) if agegroup==18 & siteiarc==13

** Rectum
count if agegroup==1 & siteiarc==14
replace cases = r(N) if agegroup==1 & siteiarc==14
count if agegroup==2 & siteiarc==14
replace cases = r(N) if agegroup==2 & siteiarc==14
count if agegroup==3 & siteiarc==14
replace cases = r(N) if agegroup==3 & siteiarc==14
count if agegroup==4 & siteiarc==14
replace cases = r(N) if agegroup==4 & siteiarc==14
count if agegroup==5 & siteiarc==14
replace cases = r(N) if agegroup==5 & siteiarc==14
count if agegroup==6 & siteiarc==14
replace cases = r(N) if agegroup==6 & siteiarc==14
count if agegroup==7 & siteiarc==14
replace cases = r(N) if agegroup==7 & siteiarc==14
count if agegroup==8 & siteiarc==14
replace cases = r(N) if agegroup==8 & siteiarc==14
count if agegroup==9 & siteiarc==14
replace cases = r(N) if agegroup==9 & siteiarc==14
count if agegroup==10 & siteiarc==14
replace cases = r(N) if agegroup==10 & siteiarc==14
count if agegroup==11 & siteiarc==14
replace cases = r(N) if agegroup==11 & siteiarc==14
count if agegroup==12 & siteiarc==14
replace cases = r(N) if agegroup==12 & siteiarc==14
count if agegroup==13 & siteiarc==14
replace cases = r(N) if agegroup==13 & siteiarc==14
count if agegroup==14 & siteiarc==14
replace cases = r(N) if agegroup==14 & siteiarc==14
count if agegroup==15 & siteiarc==14
replace cases = r(N) if agegroup==15 & siteiarc==14
count if agegroup==16 & siteiarc==14
replace cases = r(N) if agegroup==16 & siteiarc==14
count if agegroup==17 & siteiarc==14
replace cases = r(N) if agegroup==17 & siteiarc==14
count if agegroup==18 & siteiarc==14
replace cases = r(N) if agegroup==18 & siteiarc==14

** Corpus uteri
count if agegroup==1 & siteiarc==33
replace cases = r(N) if agegroup==1 & siteiarc==33
count if agegroup==2 & siteiarc==33
replace cases = r(N) if agegroup==2 & siteiarc==33
count if agegroup==3 & siteiarc==33
replace cases = r(N) if agegroup==3 & siteiarc==33
count if agegroup==4 & siteiarc==33
replace cases = r(N) if agegroup==4 & siteiarc==33
count if agegroup==5 & siteiarc==33
replace cases = r(N) if agegroup==5 & siteiarc==33
count if agegroup==6 & siteiarc==33
replace cases = r(N) if agegroup==6 & siteiarc==33
count if agegroup==7 & siteiarc==33
replace cases = r(N) if agegroup==7 & siteiarc==33
count if agegroup==8 & siteiarc==33
replace cases = r(N) if agegroup==8 & siteiarc==33
count if agegroup==9 & siteiarc==33
replace cases = r(N) if agegroup==9 & siteiarc==33
count if agegroup==10 & siteiarc==33
replace cases = r(N) if agegroup==10 & siteiarc==33
count if agegroup==11 & siteiarc==33
replace cases = r(N) if agegroup==11 & siteiarc==33
count if agegroup==12 & siteiarc==33
replace cases = r(N) if agegroup==12 & siteiarc==33
count if agegroup==13 & siteiarc==33
replace cases = r(N) if agegroup==13 & siteiarc==33
count if agegroup==14 & siteiarc==33
replace cases = r(N) if agegroup==14 & siteiarc==33
count if agegroup==15 & siteiarc==33
replace cases = r(N) if agegroup==15 & siteiarc==33
count if agegroup==16 & siteiarc==33
replace cases = r(N) if agegroup==16 & siteiarc==33
count if agegroup==17 & siteiarc==33
replace cases = r(N) if agegroup==17 & siteiarc==33
count if agegroup==18 & siteiarc==33
replace cases = r(N) if agegroup==18 & siteiarc==33

** Stomach
count if agegroup==1 & siteiarc==11
replace cases = r(N) if agegroup==1 & siteiarc==11
count if agegroup==2 & siteiarc==11
replace cases = r(N) if agegroup==2 & siteiarc==11
count if agegroup==3 & siteiarc==11
replace cases = r(N) if agegroup==3 & siteiarc==11
count if agegroup==4 & siteiarc==11
replace cases = r(N) if agegroup==4 & siteiarc==11
count if agegroup==5 & siteiarc==11
replace cases = r(N) if agegroup==5 & siteiarc==11
count if agegroup==6 & siteiarc==11
replace cases = r(N) if agegroup==6 & siteiarc==11
count if agegroup==7 & siteiarc==11
replace cases = r(N) if agegroup==7 & siteiarc==11
count if agegroup==8 & siteiarc==11
replace cases = r(N) if agegroup==8 & siteiarc==11
count if agegroup==9 & siteiarc==11
replace cases = r(N) if agegroup==9 & siteiarc==11
count if agegroup==10 & siteiarc==11
replace cases = r(N) if agegroup==10 & siteiarc==11
count if agegroup==11 & siteiarc==11
replace cases = r(N) if agegroup==11 & siteiarc==11
count if agegroup==12 & siteiarc==11
replace cases = r(N) if agegroup==12 & siteiarc==11
count if agegroup==13 & siteiarc==11
replace cases = r(N) if agegroup==13 & siteiarc==11
count if agegroup==14 & siteiarc==11
replace cases = r(N) if agegroup==14 & siteiarc==11
count if agegroup==15 & siteiarc==11
replace cases = r(N) if agegroup==15 & siteiarc==11
count if agegroup==16 & siteiarc==11
replace cases = r(N) if agegroup==16 & siteiarc==11
count if agegroup==17 & siteiarc==11
replace cases = r(N) if agegroup==17 & siteiarc==11
count if agegroup==18 & siteiarc==11
replace cases = r(N) if agegroup==18 & siteiarc==11

** Lung
count if agegroup==1 & siteiarc==21
replace cases = r(N) if agegroup==1 & siteiarc==21
count if agegroup==2 & siteiarc==21
replace cases = r(N) if agegroup==2 & siteiarc==21
count if agegroup==3 & siteiarc==21
replace cases = r(N) if agegroup==3 & siteiarc==21
count if agegroup==4 & siteiarc==21
replace cases = r(N) if agegroup==4 & siteiarc==21
count if agegroup==5 & siteiarc==21
replace cases = r(N) if agegroup==5 & siteiarc==21
count if agegroup==6 & siteiarc==21
replace cases = r(N) if agegroup==6 & siteiarc==21
count if agegroup==7 & siteiarc==21
replace cases = r(N) if agegroup==7 & siteiarc==21
count if agegroup==8 & siteiarc==21
replace cases = r(N) if agegroup==8 & siteiarc==21
count if agegroup==9 & siteiarc==21
replace cases = r(N) if agegroup==9 & siteiarc==21
count if agegroup==10 & siteiarc==21
replace cases = r(N) if agegroup==10 & siteiarc==21
count if agegroup==11 & siteiarc==21
replace cases = r(N) if agegroup==11 & siteiarc==21
count if agegroup==12 & siteiarc==21
replace cases = r(N) if agegroup==12 & siteiarc==21
count if agegroup==13 & siteiarc==21
replace cases = r(N) if agegroup==13 & siteiarc==21
count if agegroup==14 & siteiarc==21
replace cases = r(N) if agegroup==14 & siteiarc==21
count if agegroup==15 & siteiarc==21
replace cases = r(N) if agegroup==15 & siteiarc==21
count if agegroup==16 & siteiarc==21
replace cases = r(N) if agegroup==16 & siteiarc==21
count if agegroup==17 & siteiarc==21
replace cases = r(N) if agegroup==17 & siteiarc==21
count if agegroup==18 & siteiarc==21
replace cases = r(N) if agegroup==18 & siteiarc==21

** Multiple Myeloma
count if agegroup==1 & siteiarc==55
replace cases = r(N) if agegroup==1 & siteiarc==55
count if agegroup==2 & siteiarc==55
replace cases = r(N) if agegroup==2 & siteiarc==55
count if agegroup==3 & siteiarc==55
replace cases = r(N) if agegroup==3 & siteiarc==55
count if agegroup==4 & siteiarc==55
replace cases = r(N) if agegroup==4 & siteiarc==55
count if agegroup==5 & siteiarc==55
replace cases = r(N) if agegroup==5 & siteiarc==55
count if agegroup==6 & siteiarc==55
replace cases = r(N) if agegroup==6 & siteiarc==55
count if agegroup==7 & siteiarc==55
replace cases = r(N) if agegroup==7 & siteiarc==55
count if agegroup==8 & siteiarc==55
replace cases = r(N) if agegroup==8 & siteiarc==55
count if agegroup==9 & siteiarc==55
replace cases = r(N) if agegroup==9 & siteiarc==55
count if agegroup==10 & siteiarc==55
replace cases = r(N) if agegroup==10 & siteiarc==55
count if agegroup==11 & siteiarc==55
replace cases = r(N) if agegroup==11 & siteiarc==55
count if agegroup==12 & siteiarc==55
replace cases = r(N) if agegroup==12 & siteiarc==55
count if agegroup==13 & siteiarc==55
replace cases = r(N) if agegroup==13 & siteiarc==55
count if agegroup==14 & siteiarc==55
replace cases = r(N) if agegroup==14 & siteiarc==55
count if agegroup==15 & siteiarc==55
replace cases = r(N) if agegroup==15 & siteiarc==55
count if agegroup==16 & siteiarc==55
replace cases = r(N) if agegroup==16 & siteiarc==55
count if agegroup==17 & siteiarc==55
replace cases = r(N) if agegroup==17 & siteiarc==55
count if agegroup==18 & siteiarc==55
replace cases = r(N) if agegroup==18 & siteiarc==55

** Non-Hodgkin lymphoma
count if agegroup==1 & siteiarc==53
replace cases = r(N) if agegroup==1 & siteiarc==53
count if agegroup==2 & siteiarc==53
replace cases = r(N) if agegroup==2 & siteiarc==53
count if agegroup==3 & siteiarc==53
replace cases = r(N) if agegroup==3 & siteiarc==53
count if agegroup==4 & siteiarc==53
replace cases = r(N) if agegroup==4 & siteiarc==53
count if agegroup==5 & siteiarc==53
replace cases = r(N) if agegroup==5 & siteiarc==53
count if agegroup==6 & siteiarc==53
replace cases = r(N) if agegroup==6 & siteiarc==53
count if agegroup==7 & siteiarc==53
replace cases = r(N) if agegroup==7 & siteiarc==53
count if agegroup==8 & siteiarc==53
replace cases = r(N) if agegroup==8 & siteiarc==53
count if agegroup==9 & siteiarc==53
replace cases = r(N) if agegroup==9 & siteiarc==53
count if agegroup==10 & siteiarc==53
replace cases = r(N) if agegroup==10 & siteiarc==53
count if agegroup==11 & siteiarc==53
replace cases = r(N) if agegroup==11 & siteiarc==53
count if agegroup==12 & siteiarc==53
replace cases = r(N) if agegroup==12 & siteiarc==53
count if agegroup==13 & siteiarc==53
replace cases = r(N) if agegroup==13 & siteiarc==53
count if agegroup==14 & siteiarc==53
replace cases = r(N) if agegroup==14 & siteiarc==53
count if agegroup==15 & siteiarc==53
replace cases = r(N) if agegroup==15 & siteiarc==53
count if agegroup==16 & siteiarc==53
replace cases = r(N) if agegroup==16 & siteiarc==53
count if agegroup==17 & siteiarc==53
replace cases = r(N) if agegroup==17 & siteiarc==53
count if agegroup==18 & siteiarc==53
replace cases = r(N) if agegroup==18 & siteiarc==53

** Pancreas
count if agegroup==1 & siteiarc==18
replace cases = r(N) if agegroup==1 & siteiarc==18
count if agegroup==2 & siteiarc==18
replace cases = r(N) if agegroup==2 & siteiarc==18
count if agegroup==3 & siteiarc==18
replace cases = r(N) if agegroup==3 & siteiarc==18
count if agegroup==4 & siteiarc==18
replace cases = r(N) if agegroup==4 & siteiarc==18
count if agegroup==5 & siteiarc==18
replace cases = r(N) if agegroup==5 & siteiarc==18
count if agegroup==6 & siteiarc==18
replace cases = r(N) if agegroup==6 & siteiarc==18
count if agegroup==7 & siteiarc==18
replace cases = r(N) if agegroup==7 & siteiarc==18
count if agegroup==8 & siteiarc==18
replace cases = r(N) if agegroup==8 & siteiarc==18
count if agegroup==9 & siteiarc==18
replace cases = r(N) if agegroup==9 & siteiarc==18
count if agegroup==10 & siteiarc==18
replace cases = r(N) if agegroup==10 & siteiarc==18
count if agegroup==11 & siteiarc==18
replace cases = r(N) if agegroup==11 & siteiarc==18
count if agegroup==12 & siteiarc==18
replace cases = r(N) if agegroup==12 & siteiarc==18
count if agegroup==13 & siteiarc==18
replace cases = r(N) if agegroup==13 & siteiarc==18
count if agegroup==14 & siteiarc==18
replace cases = r(N) if agegroup==14 & siteiarc==18
count if agegroup==15 & siteiarc==18
replace cases = r(N) if agegroup==15 & siteiarc==18
count if agegroup==16 & siteiarc==18
replace cases = r(N) if agegroup==16 & siteiarc==18
count if agegroup==17 & siteiarc==18
replace cases = r(N) if agegroup==17 & siteiarc==18
count if agegroup==18 & siteiarc==18
replace cases = r(N) if agegroup==18 & siteiarc==18

//IARC Hub DQ Assessment
** Cervix
count if agegroup==1 & siteiarc==32
replace cases = r(N) if agegroup==1 & siteiarc==32
count if agegroup==2 & siteiarc==32
replace cases = r(N) if agegroup==2 & siteiarc==32
count if agegroup==3 & siteiarc==32
replace cases = r(N) if agegroup==3 & siteiarc==32
count if agegroup==4 & siteiarc==32
replace cases = r(N) if agegroup==4 & siteiarc==32
count if agegroup==5 & siteiarc==32
replace cases = r(N) if agegroup==5 & siteiarc==32
count if agegroup==6 & siteiarc==32
replace cases = r(N) if agegroup==6 & siteiarc==32
count if agegroup==7 & siteiarc==32
replace cases = r(N) if agegroup==7 & siteiarc==32
count if agegroup==8 & siteiarc==32
replace cases = r(N) if agegroup==8 & siteiarc==32
count if agegroup==9 & siteiarc==32
replace cases = r(N) if agegroup==9 & siteiarc==32
count if agegroup==10 & siteiarc==32
replace cases = r(N) if agegroup==10 & siteiarc==32
count if agegroup==11 & siteiarc==32
replace cases = r(N) if agegroup==11 & siteiarc==32
count if agegroup==12 & siteiarc==32
replace cases = r(N) if agegroup==12 & siteiarc==32
count if agegroup==13 & siteiarc==32
replace cases = r(N) if agegroup==13 & siteiarc==32
count if agegroup==14 & siteiarc==32
replace cases = r(N) if agegroup==14 & siteiarc==32
count if agegroup==15 & siteiarc==32
replace cases = r(N) if agegroup==15 & siteiarc==32
count if agegroup==16 & siteiarc==32
replace cases = r(N) if agegroup==16 & siteiarc==32
count if agegroup==17 & siteiarc==32
replace cases = r(N) if agegroup==17 & siteiarc==32
count if agegroup==18 & siteiarc==32
replace cases = r(N) if agegroup==18 & siteiarc==32

** Bladder
count if agegroup==1 & siteiarc==45
replace cases = r(N) if agegroup==1 & siteiarc==45
count if agegroup==2 & siteiarc==45
replace cases = r(N) if agegroup==2 & siteiarc==45
count if agegroup==3 & siteiarc==45
replace cases = r(N) if agegroup==3 & siteiarc==45
count if agegroup==4 & siteiarc==45
replace cases = r(N) if agegroup==4 & siteiarc==45
count if agegroup==5 & siteiarc==45
replace cases = r(N) if agegroup==5 & siteiarc==45
count if agegroup==6 & siteiarc==45
replace cases = r(N) if agegroup==6 & siteiarc==45
count if agegroup==7 & siteiarc==45
replace cases = r(N) if agegroup==7 & siteiarc==45
count if agegroup==8 & siteiarc==45
replace cases = r(N) if agegroup==8 & siteiarc==45
count if agegroup==9 & siteiarc==45
replace cases = r(N) if agegroup==9 & siteiarc==45
count if agegroup==10 & siteiarc==45
replace cases = r(N) if agegroup==10 & siteiarc==45
count if agegroup==11 & siteiarc==45
replace cases = r(N) if agegroup==11 & siteiarc==45
count if agegroup==12 & siteiarc==45
replace cases = r(N) if agegroup==12 & siteiarc==45
count if agegroup==13 & siteiarc==45
replace cases = r(N) if agegroup==13 & siteiarc==45
count if agegroup==14 & siteiarc==45
replace cases = r(N) if agegroup==14 & siteiarc==45
count if agegroup==15 & siteiarc==45
replace cases = r(N) if agegroup==15 & siteiarc==45
count if agegroup==16 & siteiarc==45
replace cases = r(N) if agegroup==16 & siteiarc==45
count if agegroup==17 & siteiarc==45
replace cases = r(N) if agegroup==17 & siteiarc==45
count if agegroup==18 & siteiarc==45
replace cases = r(N) if agegroup==18 & siteiarc==45


** Condense dataset
drop if cases==.
drop age
sort siteiarc agegroup
contract siteiarc agegroup cases dxyr sex absolutetot
drop _freq

sort siteiarc agegroup


** Create dataset with all sites
save "`datapath'\version02\2-working\2013_2014_2015_pre-uncertainty_allsites", replace


** Create dataset by year by site by sex (where applicable) - CERVIX (2013)
use "`datapath'\version02\2-working\2013_2014_2015_pre-uncertainty_allsites", clear

drop if siteiarc!=32
drop if dxyr!=2013
//drop if sex==2

summ cases


save "`datapath'\version02\2-working\2013_nouncertainty_cervix", replace

local boots = 5000

** Create blank dataset to store the estimations
clear

set obs `boots'

gen store_means = .
gen store_low = .
gen store_high = .

quietly {
forvalues i = 1(1)`boots' {
	if floor((`i'-1)/100) == (`i'-1)/100 {
		noisily display "Working on `i' out of `boots' at $S_TIME"
	}
	
	preserve
	
	use "`datapath'\version02\2-working\2013_nouncertainty_cervix", clear
	
	bsample
	
	summ cases
	local mean_got = r(mean)
	
	restore
	
	replace store_means = `mean_got' in `i'
	}
}
summ store_means

save "`datapath'\version02\2-working\2013_boots_cervix", replace

quietly {
gen table_means = r(mean)
gen table_low = r(min)
gen table_high = r(max)
gen siteiarc = 32
gen year = 2013

drop store_means store_low store_high

gen obsid = _n
drop if obsid != 1

drop obsid
}

order siteiarc year table_means table_low table_high
save "`datapath'\version02\3-output\2013_uncertainty_cervix", replace

use "`datapath'\version02\2-working\2013_nouncertainty_cervix", clear
mean cases

clear

** Create dataset by year by site by sex (where applicable) - CERVIX (2014)
use "`datapath'\version02\2-working\2013_2014_2015_pre-uncertainty_allsites", clear

drop if siteiarc!=32
drop if dxyr!=2014
//drop if sex==2

summ cases


save "`datapath'\version02\2-working\2014_nouncertainty_cervix", replace

local boots = 5000

** Create blank dataset to store the estimations
clear

set obs `boots'

gen store_means = .
gen store_low = .
gen store_high = .

quietly {
forvalues i = 1(1)`boots' {
	if floor((`i'-1)/100) == (`i'-1)/100 {
		noisily display "Working on `i' out of `boots' at $S_TIME"
	}
	
	preserve
	
	use "`datapath'\version02\2-working\2014_nouncertainty_cervix", clear
	
	bsample
	
	summ cases
	local mean_got = r(mean)
	
	restore
	
	replace store_means = `mean_got' in `i'
	}
}
summ store_means

save "`datapath'\version02\2-working\2014_boots_cervix", replace

quietly {
gen table_means = r(mean)
gen table_low = r(min)
gen table_high = r(max)
gen siteiarc = 32
gen year = 2014

drop store_means store_low store_high

gen obsid = _n
drop if obsid != 1

drop obsid
}

order siteiarc year table_means table_low table_high
save "`datapath'\version02\3-output\2014_uncertainty_cervix", replace

use "`datapath'\version02\2-working\2014_nouncertainty_cervix", clear
mean cases

clear

** Create dataset by year by site by sex (where applicable) - CERVIX (2015)
use "`datapath'\version02\2-working\2013_2014_2015_pre-uncertainty_allsites", clear

drop if siteiarc!=32
drop if dxyr!=2015
//drop if sex==2

summ cases

save "`datapath'\version02\2-working\2015_nouncertainty_cervix", replace

local boots = 5000

** Create blank dataset to store the estimations
clear

set obs `boots'

gen store_means = .
gen store_low = .
gen store_high = .

quietly {
forvalues i = 1(1)`boots' {
	if floor((`i'-1)/100) == (`i'-1)/100 {
		noisily display "Working on `i' out of `boots' at $S_TIME"
	}
	
	preserve
	
	use "`datapath'\version02\2-working\2015_nouncertainty_cervix", clear
	
	bsample
	
	summ cases
	local mean_got = r(mean)
	
	restore
	
	replace store_means = `mean_got' in `i'
	}
}
summ store_means

save "`datapath'\version02\2-working\2015_boots_cervix", replace

quietly {
gen table_means = r(mean)
gen table_low = r(min)
gen table_high = r(max)
gen siteiarc = 32
gen year = 2015

drop store_means store_low store_high

gen obsid = _n
drop if obsid != 1

drop obsid
}

order siteiarc year table_means table_low table_high
save "`datapath'\version02\3-output\2015_uncertainty_cervix", replace

use "`datapath'\version02\2-working\2015_nouncertainty_cervix", clear
mean cases

clear


** Create dataset by year by site by sex (where applicable) - RECTUM (2013)
use "`datapath'\version02\2-working\2013_2014_2015_pre-uncertainty_allsites", clear

drop if siteiarc!=14
drop if dxyr!=2013
//drop if sex==2

summ cases


save "`datapath'\version02\2-working\2013_nouncertainty_rectum", replace

local boots = 5000

** Create blank dataset to store the estimations
clear

set obs `boots'

gen store_means = .
gen store_low = .
gen store_high = .

quietly {
forvalues i = 1(1)`boots' {
	if floor((`i'-1)/100) == (`i'-1)/100 {
		noisily display "Working on `i' out of `boots' at $S_TIME"
	}
	
	preserve
	
	use "`datapath'\version02\2-working\2013_nouncertainty_rectum", clear
	
	bsample
	
	summ cases
	local mean_got = r(mean)
	
	restore
	
	replace store_means = `mean_got' in `i'
	}
}
summ store_means

save "`datapath'\version02\2-working\2013_boots_rectum", replace

quietly {
gen table_means = r(mean)
gen table_low = r(min)
gen table_high = r(max)
gen siteiarc = 14
gen year = 2013

drop store_means store_low store_high

gen obsid = _n
drop if obsid != 1

drop obsid
}

order siteiarc year table_means table_low table_high
save "`datapath'\version02\3-output\2013_uncertainty_rectum", replace

use "`datapath'\version02\2-working\2013_nouncertainty_rectum", clear
mean cases

clear

** Create dataset by year by site by sex (where applicable) - RECTUM (2014)
use "`datapath'\version02\2-working\2013_2014_2015_pre-uncertainty_allsites", clear

drop if siteiarc!=14
drop if dxyr!=2014
//drop if sex==2

summ cases


save "`datapath'\version02\2-working\2014_nouncertainty_rectum", replace

local boots = 5000

** Create blank dataset to store the estimations
clear

set obs `boots'

gen store_means = .
gen store_low = .
gen store_high = .

quietly {
forvalues i = 1(1)`boots' {
	if floor((`i'-1)/100) == (`i'-1)/100 {
		noisily display "Working on `i' out of `boots' at $S_TIME"
	}
	
	preserve
	
	use "`datapath'\version02\2-working\2014_nouncertainty_rectum", clear
	
	bsample
	
	summ cases
	local mean_got = r(mean)
	
	restore
	
	replace store_means = `mean_got' in `i'
	}
}
summ store_means

save "`datapath'\version02\2-working\2014_boots_rectum", replace

quietly {
gen table_means = r(mean)
gen table_low = r(min)
gen table_high = r(max)
gen siteiarc = 14
gen year = 2014

drop store_means store_low store_high

gen obsid = _n
drop if obsid != 1

drop obsid
}

order siteiarc year table_means table_low table_high
save "`datapath'\version02\3-output\2014_uncertainty_rectum", replace

use "`datapath'\version02\2-working\2014_nouncertainty_rectum", clear
mean cases

clear

** Create dataset by year by site by sex (where applicable) - RECTUM (2015)
use "`datapath'\version02\2-working\2013_2014_2015_pre-uncertainty_allsites", clear

drop if siteiarc!=14
drop if dxyr!=2015
//drop if sex==2

summ cases

save "`datapath'\version02\2-working\2015_nouncertainty_rectum", replace

local boots = 5000

** Create blank dataset to store the estimations
clear

set obs `boots'

gen store_means = .
gen store_low = .
gen store_high = .

quietly {
forvalues i = 1(1)`boots' {
	if floor((`i'-1)/100) == (`i'-1)/100 {
		noisily display "Working on `i' out of `boots' at $S_TIME"
	}
	
	preserve
	
	use "`datapath'\version02\2-working\2015_nouncertainty_rectum", clear
	
	bsample
	
	summ cases
	local mean_got = r(mean)
	
	restore
	
	replace store_means = `mean_got' in `i'
	}
}
summ store_means

save "`datapath'\version02\2-working\2015_boots_rectum", replace

quietly {
gen table_means = r(mean)
gen table_low = r(min)
gen table_high = r(max)
gen siteiarc = 14
gen year = 2015

drop store_means store_low store_high

gen obsid = _n
drop if obsid != 1

drop obsid
}

order siteiarc year table_means table_low table_high
save "`datapath'\version02\3-output\2015_uncertainty_rectum", replace

use "`datapath'\version02\2-working\2015_nouncertainty_rectum", clear
mean cases

clear


** Create dataset by year by site by sex (where applicable) - MULTIPLE MYELOMA (2013)
use "`datapath'\version02\2-working\2013_2014_2015_pre-uncertainty_allsites", clear

drop if siteiarc!=55
drop if dxyr!=2013
drop if sex==2

summ cases


save "`datapath'\version02\2-working\2013_nouncertainty_multiplemyeloma", replace

local boots = 5000

** Create blank dataset to store the estimations
clear

set obs `boots'

gen store_means = .
gen store_low = .
gen store_high = .

quietly {
forvalues i = 1(1)`boots' {
	if floor((`i'-1)/100) == (`i'-1)/100 {
		noisily display "Working on `i' out of `boots' at $S_TIME"
	}
	
	preserve
	
	use "`datapath'\version02\2-working\2013_nouncertainty_multiplemyeloma", clear
	
	bsample
	
	summ cases
	local mean_got = r(mean)
	
	restore
	
	replace store_means = `mean_got' in `i'
	}
}
summ store_means

save "`datapath'\version02\2-working\2013_boots_multiplemyeloma", replace

quietly {
gen table_means = r(mean)
gen table_low = r(min)
gen table_high = r(max)
gen siteiarc = 55
gen year = 2013

drop store_means store_low store_high

gen obsid = _n
drop if obsid != 1

drop obsid
}

order siteiarc year table_means table_low table_high
save "`datapath'\version02\3-output\2013_uncertainty_multiplemyeloma", replace

use "`datapath'\version02\2-working\2013_nouncertainty_multiplemyeloma", clear
mean cases

clear

** Create dataset by year by site by sex (where applicable) - MULTIPLE MYELOMA (2014)
use "`datapath'\version02\2-working\2013_2014_2015_pre-uncertainty_allsites", clear

drop if siteiarc!=55
drop if dxyr!=2014
drop if sex==2

summ cases


save "`datapath'\version02\2-working\2014_nouncertainty_multiplemyeloma", replace

local boots = 5000

** Create blank dataset to store the estimations
clear

set obs `boots'

gen store_means = .
gen store_low = .
gen store_high = .

quietly {
forvalues i = 1(1)`boots' {
	if floor((`i'-1)/100) == (`i'-1)/100 {
		noisily display "Working on `i' out of `boots' at $S_TIME"
	}
	
	preserve
	
	use "`datapath'\version02\2-working\2014_nouncertainty_multiplemyeloma", clear
	
	bsample
	
	summ cases
	local mean_got = r(mean)
	
	restore
	
	replace store_means = `mean_got' in `i'
	}
}
summ store_means

save "`datapath'\version02\2-working\2014_boots_multiplemyeloma", replace

quietly {
gen table_means = r(mean)
gen table_low = r(min)
gen table_high = r(max)
gen siteiarc = 55
gen year = 2014

drop store_means store_low store_high

gen obsid = _n
drop if obsid != 1

drop obsid
}

order siteiarc year table_means table_low table_high
save "`datapath'\version02\3-output\2014_uncertainty_multiplemyeloma", replace

use "`datapath'\version02\2-working\2014_nouncertainty_multiplemyeloma", clear
mean cases

clear

** Create dataset by year by site by sex (where applicable) - MULTIPLE MYELOMA (2015)
use "`datapath'\version02\2-working\2013_2014_2015_pre-uncertainty_allsites", clear

drop if siteiarc!=55
drop if dxyr!=2015
drop if sex==2

summ cases

save "`datapath'\version02\2-working\2015_nouncertainty_multiplemyeloma", replace

local boots = 5000

** Create blank dataset to store the estimations
clear

set obs `boots'

gen store_means = .
gen store_low = .
gen store_high = .

quietly {
forvalues i = 1(1)`boots' {
	if floor((`i'-1)/100) == (`i'-1)/100 {
		noisily display "Working on `i' out of `boots' at $S_TIME"
	}
	
	preserve
	
	use "`datapath'\version02\2-working\2015_nouncertainty_multiplemyeloma", clear
	
	bsample
	
	summ cases
	local mean_got = r(mean)
	
	restore
	
	replace store_means = `mean_got' in `i'
	}
}
summ store_means

save "`datapath'\version02\2-working\2015_boots_multiplemyeloma", replace

quietly {
gen table_means = r(mean)
gen table_low = r(min)
gen table_high = r(max)
gen siteiarc = 55
gen year = 2015

drop store_means store_low store_high

gen obsid = _n
drop if obsid != 1

drop obsid
}

order siteiarc year table_means table_low table_high
save "`datapath'\version02\3-output\2015_uncertainty_multiplemyeloma", replace

use "`datapath'\version02\2-working\2015_nouncertainty_multiplemyeloma", clear
mean cases

clear


** Create dataset by year by site by sex (where applicable) - STOMACH (2013)
use "`datapath'\version02\2-working\2013_2014_2015_pre-uncertainty_allsites", clear

drop if siteiarc!=11
drop if dxyr!=2013
drop if sex==2

summ cases


save "`datapath'\version02\2-working\2013_nouncertainty_stomach", replace

local boots = 5000

** Create blank dataset to store the estimations
clear

set obs `boots'

gen store_means = .
gen store_low = .
gen store_high = .

quietly {
forvalues i = 1(1)`boots' {
	if floor((`i'-1)/100) == (`i'-1)/100 {
		noisily display "Working on `i' out of `boots' at $S_TIME"
	}
	
	preserve
	
	use "`datapath'\version02\2-working\2013_nouncertainty_stomach", clear
	
	bsample
	
	summ cases
	local mean_got = r(mean)
	
	restore
	
	replace store_means = `mean_got' in `i'
	}
}
summ store_means

save "`datapath'\version02\2-working\2013_boots_stomach", replace

quietly {
gen table_means = r(mean)
gen table_low = r(min)
gen table_high = r(max)
gen siteiarc = 11
gen year = 2013

drop store_means store_low store_high

gen obsid = _n
drop if obsid != 1

drop obsid
}

order siteiarc year table_means table_low table_high
save "`datapath'\version02\3-output\2013_uncertainty_stomach", replace

use "`datapath'\version02\2-working\2013_nouncertainty_stomach", clear
mean cases

clear

** Create dataset by year by site by sex (where applicable) - STOMACH (2014)
use "`datapath'\version02\2-working\2013_2014_2015_pre-uncertainty_allsites", clear

drop if siteiarc!=11
drop if dxyr!=2014
drop if sex==2

summ cases


save "`datapath'\version02\2-working\2014_nouncertainty_stomach", replace

local boots = 5000

** Create blank dataset to store the estimations
clear

set obs `boots'

gen store_means = .
gen store_low = .
gen store_high = .

quietly {
forvalues i = 1(1)`boots' {
	if floor((`i'-1)/100) == (`i'-1)/100 {
		noisily display "Working on `i' out of `boots' at $S_TIME"
	}
	
	preserve
	
	use "`datapath'\version02\2-working\2014_nouncertainty_stomach", clear
	
	bsample
	
	summ cases
	local mean_got = r(mean)
	
	restore
	
	replace store_means = `mean_got' in `i'
	}
}
summ store_means

save "`datapath'\version02\2-working\2014_boots_stomach", replace

quietly {
gen table_means = r(mean)
gen table_low = r(min)
gen table_high = r(max)
gen siteiarc = 11
gen year = 2014

drop store_means store_low store_high

gen obsid = _n
drop if obsid != 1

drop obsid
}

order siteiarc year table_means table_low table_high
save "`datapath'\version02\3-output\2014_uncertainty_stomach", replace

use "`datapath'\version02\2-working\2014_nouncertainty_stomach", clear
mean cases

clear

** Create dataset by year by site by sex (where applicable) - STOMACH (2015)
use "`datapath'\version02\2-working\2013_2014_2015_pre-uncertainty_allsites", clear

drop if siteiarc!=11
drop if dxyr!=2015
drop if sex==2

summ cases


save "`datapath'\version02\2-working\2015_nouncertainty_stomach", replace


local boots = 5000

** Create blank dataset to store the estimations
clear

set obs `boots'

gen store_means = .
gen store_low = .
gen store_high = .

quietly {
forvalues i = 1(1)`boots' {
	if floor((`i'-1)/100) == (`i'-1)/100 {
		noisily display "Working on `i' out of `boots' at $S_TIME"
	}
	
	preserve
	
	use "`datapath'\version02\2-working\2015_nouncertainty_stomach", clear
	
	bsample
	
	summ cases
	local mean_got = r(mean)
	
	restore
	
	replace store_means = `mean_got' in `i'
	}
}
summ store_means

save "`datapath'\version02\2-working\2015_boots_stomach", replace

quietly {
gen table_means = r(mean)
gen table_low = r(min)
gen table_high = r(max)
gen siteiarc = 11
gen year = 2015

drop store_means store_low store_high

gen obsid = _n
drop if obsid != 1

drop obsid
}

order siteiarc year table_means table_low table_high
save "`datapath'\version02\3-output\2015_uncertainty_stomach", replace

use "`datapath'\version02\2-working\2015_nouncertainty_stomach", clear
mean cases

clear

** Create dataset by year by site by sex (where applicable) - LUNG (2013)
use "`datapath'\version02\2-working\2013_2014_2015_pre-uncertainty_allsites", clear

drop if siteiarc!=21
drop if dxyr!=2013
drop if sex==2

summ cases


save "`datapath'\version02\2-working\2013_nouncertainty_lung", replace

local boots = 5000

** Create blank dataset to store the estimations
clear

set obs `boots'

gen store_means = .
gen store_low = .
gen store_high = .

quietly {
forvalues i = 1(1)`boots' {
	if floor((`i'-1)/100) == (`i'-1)/100 {
		noisily display "Working on `i' out of `boots' at $S_TIME"
	}
	
	preserve
	
	use "`datapath'\version02\2-working\2013_nouncertainty_lung", clear
	
	bsample
	
	summ cases
	local mean_got = r(mean)
	
	restore
	
	replace store_means = `mean_got' in `i'
	}
}
summ store_means

save "`datapath'\version02\2-working\2013_boots_lung", replace

quietly {
gen table_means = r(mean)
gen table_low = r(min)
gen table_high = r(max)
gen siteiarc = 21
gen year = 2013

drop store_means store_low store_high

gen obsid = _n
drop if obsid != 1

drop obsid
}

order siteiarc year table_means table_low table_high
save "`datapath'\version02\3-output\2013_uncertainty_lung", replace

use "`datapath'\version02\2-working\2013_nouncertainty_lung", clear
mean cases

clear

** Create dataset by year by site by sex (where applicable) - LUNG (2014)
use "`datapath'\version02\2-working\2013_2014_2015_pre-uncertainty_allsites", clear

drop if siteiarc!=21
drop if dxyr!=2014
drop if sex==2

summ cases


save "`datapath'\version02\2-working\2014_nouncertainty_lung", replace

local boots = 5000

** Create blank dataset to store the estimations
clear

set obs `boots'

gen store_means = .
gen store_low = .
gen store_high = .

quietly {
forvalues i = 1(1)`boots' {
	if floor((`i'-1)/100) == (`i'-1)/100 {
		noisily display "Working on `i' out of `boots' at $S_TIME"
	}
	
	preserve
	
	use "`datapath'\version02\2-working\2014_nouncertainty_lung", clear
	
	bsample
	
	summ cases
	local mean_got = r(mean)
	
	restore
	
	replace store_means = `mean_got' in `i'
	}
}
summ store_means

save "`datapath'\version02\2-working\2014_boots_lung", replace

quietly {
gen table_means = r(mean)
gen table_low = r(min)
gen table_high = r(max)
gen siteiarc = 21
gen year = 2014

drop store_means store_low store_high

gen obsid = _n
drop if obsid != 1

drop obsid
}

order siteiarc year table_means table_low table_high
save "`datapath'\version02\3-output\2014_uncertainty_lung", replace

use "`datapath'\version02\2-working\2014_nouncertainty_lung", clear
mean cases

clear

** Create dataset by year by site by sex (where applicable) - LUNG (2015)
use "`datapath'\version02\2-working\2013_2014_2015_pre-uncertainty_allsites", clear

drop if siteiarc!=21
drop if dxyr!=2015
drop if sex==2

summ cases

save "`datapath'\version02\2-working\2015_nouncertainty_lung", replace

local boots = 5000

** Create blank dataset to store the estimations
clear

set obs `boots'

gen store_means = .
gen store_low = .
gen store_high = .

quietly {
forvalues i = 1(1)`boots' {
	if floor((`i'-1)/100) == (`i'-1)/100 {
		noisily display "Working on `i' out of `boots' at $S_TIME"
	}
	
	preserve
	
	use "`datapath'\version02\2-working\2015_nouncertainty_lung", clear
	
	bsample
	
	summ cases
	local mean_got = r(mean)
	
	restore
	
	replace store_means = `mean_got' in `i'
	}
}
summ store_means

save "`datapath'\version02\2-working\2015_boots_lung", replace

quietly {
gen table_means = r(mean)
gen table_low = r(min)
gen table_high = r(max)
gen siteiarc = 21
gen year = 2015

drop store_means store_low store_high

gen obsid = _n
drop if obsid != 1

drop obsid
}

order siteiarc year table_means table_low table_high
save "`datapath'\version02\3-output\2015_uncertainty_lung", replace

use "`datapath'\version02\2-working\2015_nouncertainty_lung", clear
mean cases

clear


** Create dataset by year by site by sex (where applicable) - BLADDER (2013)
use "`datapath'\version02\2-working\2013_2014_2015_pre-uncertainty_allsites", clear

drop if siteiarc!=45
drop if dxyr!=2013
drop if sex==2

summ cases


save "`datapath'\version02\2-working\2013_nouncertainty_bladder", replace

local boots = 5000

** Create blank dataset to store the estimations
clear

set obs `boots'

gen store_means = .
gen store_low = .
gen store_high = .

quietly {
forvalues i = 1(1)`boots' {
	if floor((`i'-1)/100) == (`i'-1)/100 {
		noisily display "Working on `i' out of `boots' at $S_TIME"
	}
	
	preserve
	
	use "`datapath'\version02\2-working\2013_nouncertainty_bladder", clear
	
	bsample
	
	summ cases
	local mean_got = r(mean)
	
	restore
	
	replace store_means = `mean_got' in `i'
	}
}
summ store_means

save "`datapath'\version02\2-working\2013_boots_bladder", replace

quietly {
gen table_means = r(mean)
gen table_low = r(min)
gen table_high = r(max)
gen siteiarc = 45
gen year = 2013

drop store_means store_low store_high

gen obsid = _n
drop if obsid != 1

drop obsid
}

order siteiarc year table_means table_low table_high
save "`datapath'\version02\3-output\2013_uncertainty_bladder", replace

use "`datapath'\version02\2-working\2013_nouncertainty_bladder", clear
mean cases

clear

** Create dataset by year by site by sex (where applicable) - BLADDER (2014)
use "`datapath'\version02\2-working\2013_2014_2015_pre-uncertainty_allsites", clear

drop if siteiarc!=45
drop if dxyr!=2014
drop if sex==2

summ cases


save "`datapath'\version02\2-working\2014_nouncertainty_bladder", replace

local boots = 5000

** Create blank dataset to store the estimations
clear

set obs `boots'

gen store_means = .
gen store_low = .
gen store_high = .

quietly {
forvalues i = 1(1)`boots' {
	if floor((`i'-1)/100) == (`i'-1)/100 {
		noisily display "Working on `i' out of `boots' at $S_TIME"
	}
	
	preserve
	
	use "`datapath'\version02\2-working\2014_nouncertainty_bladder", clear
	
	bsample
	
	summ cases
	local mean_got = r(mean)
	
	restore
	
	replace store_means = `mean_got' in `i'
	}
}
summ store_means

save "`datapath'\version02\2-working\2014_boots_bladder", replace

quietly {
gen table_means = r(mean)
gen table_low = r(min)
gen table_high = r(max)
gen siteiarc = 45
gen year = 2014

drop store_means store_low store_high

gen obsid = _n
drop if obsid != 1

drop obsid
}

order siteiarc year table_means table_low table_high
save "`datapath'\version02\3-output\2014_uncertainty_bladder", replace

use "`datapath'\version02\2-working\2014_nouncertainty_bladder", clear
mean cases

clear

** Create dataset by year by site by sex (where applicable) - BLADDER (2015)
use "`datapath'\version02\2-working\2013_2014_2015_pre-uncertainty_allsites", clear

drop if siteiarc!=45
drop if dxyr!=2015
drop if sex==2

summ cases

save "`datapath'\version02\2-working\2015_nouncertainty_bladder", replace

local boots = 5000

** Create blank dataset to store the estimations
clear

set obs `boots'

gen store_means = .
gen store_low = .
gen store_high = .

quietly {
forvalues i = 1(1)`boots' {
	if floor((`i'-1)/100) == (`i'-1)/100 {
		noisily display "Working on `i' out of `boots' at $S_TIME"
	}
	
	preserve
	
	use "`datapath'\version02\2-working\2015_nouncertainty_bladder", clear
	
	bsample
	
	summ cases
	local mean_got = r(mean)
	
	restore
	
	replace store_means = `mean_got' in `i'
	}
}
summ store_means

save "`datapath'\version02\2-working\2015_boots_bladder", replace

quietly {
gen table_means = r(mean)
gen table_low = r(min)
gen table_high = r(max)
gen siteiarc = 45
gen year = 2015

drop store_means store_low store_high

gen obsid = _n
drop if obsid != 1

drop obsid
}

order siteiarc year table_means table_low table_high
save "`datapath'\version02\3-output\2015_uncertainty_bladder", replace

use "`datapath'\version02\2-working\2015_nouncertainty_bladder", clear
mean cases

clear

/*
** Create dataset by year by site by sex (where applicable) - ALL SITES (2013)
use "`datapath'\version02\2-working\2013_2014_2015_pre-uncertainty_allsites", clear

//drop if siteiarc!=45
drop if dxyr!=2013
//drop if sex==2

summ cases


save "`datapath'\version02\2-working\2013_nouncertainty_all", replace

local boots = 5000

** Create blank dataset to store the estimations
clear

set obs `boots'

gen store_means = .
gen store_low = .
gen store_high = .

quietly {
forvalues i = 1(1)`boots' {
	if floor((`i'-1)/100) == (`i'-1)/100 {
		noisily display "Working on `i' out of `boots' at $S_TIME"
	}
	
	preserve
	
	use "`datapath'\version02\2-working\2013_nouncertainty_all", clear
	
	bsample
	
	summ cases
	local mean_got = r(mean)
	
	restore
	
	replace store_means = `mean_got' in `i'
	}
}
summ store_means

save "`datapath'\version02\2-working\2013_boots_all", replace

quietly {
gen table_means = r(mean)
gen table_low = r(min)
gen table_high = r(max)
gen siteiarc = 62
gen year = 2013

drop store_means store_low store_high

gen obsid = _n
drop if obsid != 1

drop obsid
}

order siteiarc year table_means table_low table_high
save "`datapath'\version02\3-output\2013_uncertainty_all", replace

use "`datapath'\version02\2-working\2013_nouncertainty_all", clear
mean cases

clear

** Create dataset by year by site by sex (where applicable) - ALL SITES (2014)
use "`datapath'\version02\2-working\2013_2014_2015_pre-uncertainty_allsites", clear

//drop if siteiarc!=45
drop if dxyr!=2014
//drop if sex==2

summ cases


save "`datapath'\version02\2-working\2014_nouncertainty_all", replace

local boots = 5000

** Create blank dataset to store the estimations
clear

set obs `boots'

gen store_means = .
gen store_low = .
gen store_high = .

quietly {
forvalues i = 1(1)`boots' {
	if floor((`i'-1)/100) == (`i'-1)/100 {
		noisily display "Working on `i' out of `boots' at $S_TIME"
	}
	
	preserve
	
	use "`datapath'\version02\2-working\2014_nouncertainty_all", clear
	
	bsample
	
	summ cases
	local mean_got = r(mean)
	
	restore
	
	replace store_means = `mean_got' in `i'
	}
}
summ store_means

save "`datapath'\version02\2-working\2014_boots_all", replace

quietly {
gen table_means = r(mean)
gen table_low = r(min)
gen table_high = r(max)
gen siteiarc = 62
gen year = 2014

drop store_means store_low store_high

gen obsid = _n
drop if obsid != 1

drop obsid
}

order siteiarc year table_means table_low table_high
save "`datapath'\version02\3-output\2014_uncertainty_all", replace

use "`datapath'\version02\2-working\2014_nouncertainty_all", clear
mean cases

clear

** Create dataset by year by site by sex (where applicable) - ALL SITES (2015)
use "`datapath'\version02\2-working\2013_2014_2015_pre-uncertainty_allsites", clear

//drop if siteiarc!=45
drop if dxyr!=2015
//drop if sex==2

summ cases

save "`datapath'\version02\2-working\2015_nouncertainty_all", replace

local boots = 5000

** Create blank dataset to store the estimations
clear

set obs `boots'

gen store_means = .
gen store_low = .
gen store_high = .

quietly {
forvalues i = 1(1)`boots' {
	if floor((`i'-1)/100) == (`i'-1)/100 {
		noisily display "Working on `i' out of `boots' at $S_TIME"
	}
	
	preserve
	
	use "`datapath'\version02\2-working\2015_nouncertainty_all", clear
	
	bsample
	
	summ cases
	local mean_got = r(mean)
	
	restore
	
	replace store_means = `mean_got' in `i'
	}
}
summ store_means

save "`datapath'\version02\2-working\2015_boots_all", replace

quietly {
gen table_means = r(mean)
gen table_low = r(min)
gen table_high = r(max)
gen siteiarc = 62
gen year = 2015

drop store_means store_low store_high

gen obsid = _n
drop if obsid != 1

drop obsid
}

order siteiarc year table_means table_low table_high
save "`datapath'\version02\3-output\2015_uncertainty_all", replace

use "`datapath'\version02\2-working\2015_nouncertainty_all", clear
mean cases

clear
*/

** Create one table with absolute case totals + uncertainty results from all sites
use "`datapath'\version02\3-output\2013_uncertainty_cervix", clear
append using "`datapath'\version02\3-output\2014_uncertainty_cervix"
append using "`datapath'\version02\3-output\2015_uncertainty_cervix"
append using "`datapath'\version02\3-output\2013_uncertainty_rectum"
append using "`datapath'\version02\3-output\2014_uncertainty_rectum"
append using "`datapath'\version02\3-output\2015_uncertainty_rectum"
append using "`datapath'\version02\3-output\2013_uncertainty_multiplemyeloma"
append using "`datapath'\version02\3-output\2014_uncertainty_multiplemyeloma"
append using "`datapath'\version02\3-output\2015_uncertainty_multiplemyeloma"
append using "`datapath'\version02\3-output\2013_uncertainty_stomach"
append using "`datapath'\version02\3-output\2014_uncertainty_stomach"
append using "`datapath'\version02\3-output\2015_uncertainty_stomach"
append using "`datapath'\version02\3-output\2013_uncertainty_lung"
append using "`datapath'\version02\3-output\2014_uncertainty_lung"
append using "`datapath'\version02\3-output\2015_uncertainty_lung"
append using "`datapath'\version02\3-output\2013_uncertainty_bladder"
append using "`datapath'\version02\3-output\2014_uncertainty_bladder"
append using "`datapath'\version02\3-output\2015_uncertainty_bladder"
/*
append using "`datapath'\version02\3-output\2013_uncertainty_all"
append using "`datapath'\version02\3-output\2014_uncertainty_all"
append using "`datapath'\version02\3-output\2015_uncertainty_all"
*/

** Re-add siteiarc label
label define siteiarc_lab ///
1 "Lip (C00)" 2 "Tongue (C01-02)" 3 "Mouth (C03-06)" ///
4 "Salivary gland (C07-08)" 5 "Tonsil (C09)" 6 "Other oropharynx (C10)" ///
7 "Nasopharynx (C11)" 8 "Hypopharynx (C12-13)" 9 "Pharynx unspecified (C14)" ///
10 "Oesophagus (C15)" 11 "Stomach (C16)" 12 "Small intestine (C17)" ///
13 "Colon (C18)" 14 "Rectum (C19-20)" 15 "Anus (C21)" ///
16 "Liver (C22)" 17 "Gallbladder etc. (C23-24)" 18 "Pancreas (C25)" ///
19 "Nose, sinuses etc. (C30-31)" 20 "Larynx (C32)" ///
21 "Lung (incl. trachea and bronchus) (C33-34)" 22 "Other thoracic organs (C37-38)" ///
23 "Bone (C40-41)" 24 "Melanoma of skin (C43)" 25 "Other skin (C44)" ///
26 "Mesothelioma (C45)" 27 "Kaposi sarcoma (C46)" 28 "Connective and soft tissue (C47+C49)" ///
29 "Breast (C50)" 30 "Vulva (C51)" 31 "Vagina (C52)" 32 "Cervix uteri (C53)" ///
33 "Corpus uteri (C54)" 34 "Uterus unspecified (C55)" 35 "Ovary (C56)" ///
36 "Other female genital organs (C57)" 37 "Placenta (C58)" ///
38 "Penis (C60)" 39 "Prostate (C61)" 40 "Testis (C62)" 41 "Other male genital organs (C63)" ///
42 "Kidney (C64)" 43 "Renal pelvis (C65)" 44 "Ureter (C66)" 45 "Bladder (C67)" ///
46 "Other urinary organs (C68)" 47 "Eye (C69)" 48 "Brain, nervous system (C70-72)" ///
49 "Thyroid (C73)" 50 "Adrenal gland (C74)" 51 "Other endocrine (C75)" ///
52 "Hodgkin lymphoma (C81)" 53 "Non-Hodgkin lymphoma (C82-86,C96)" ///
54 "Immunoproliferative diseases (C88)" 55 "Multiple myeloma (C90)" ///
56 "Lymphoid leukaemia (C91)" 57 "Myeloid leukaemia (C92-94)" 58 "Leukaemia unspecified (C95)" ///
59 "Myeloproliferative disorders (MPD)" 60 "Myelodysplastic syndromes (MDS)" ///
61 "Other and unspecified (O&U)" ///
62 "All sites(ALL)" 63 "All sites but skin (ALLbC44)" ///
64 "D069: CIN 3"
label var siteiarc "IARC CI5-XI sites"
label values siteiarc siteiarc_lab

merge 1:1 siteiarc year using "`datapath'\version02\2-working\2013_2014_2015_absolutetotals"
/*

    Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                                18  (_merge==3)
    -----------------------------------------
*/
drop _merge

** Create a variable to identify which sites had fluctations in their sex only
gen sex = "Female only" if siteiarc!=14 & siteiarc!=62
replace sex = "Male + Female" if siteiarc==14|siteiarc==62

rename table_means mean
rename table_low min
rename table_high max
rename absolutetot cases
order siteiarc year sex cases mean min max
sort siteiarc year meansmin max
format min max %2.0f
format mean %2.1f

** Create MS Word results table with absolute case totals + the uncertainty means, min and max values by year, by site, by sex (where applicable)
				**************************
				*	   MS WORD REPORT    *
				* 	UNCERTAINTY RESULTS  *
				**************************
putdocx clear
putdocx begin, footer(foot1)
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER 2015 Annual Report: Uncertainty Results"), bold
putdocx textblock begin
Date Prepared: 04-OCT-2021. 
Prepared by: JC using Stata & Redcap data release date: 21-May-2021.
Generated using Dofile: 60_uncertainty.do
putdocx textblock end
putdocx paragraph, halign(center)
putdocx text ("Table: Absolute Case Totals + Uncertainty Results for BNR-Cancer for 2013-2015"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Background"), bold
putdocx textblock begin
A data quality assessment performed by the IARC Hub noted fluctuations in certain sites. A thorough investigation into possible causes for the fluctuations did not reveal any significant changes in abstractor quality or changes at the data sources. As a result, uncertainty analysis was performed to ascertain if the fluctuations were simply the result of the small case numbers due to the smaller population size of Barbados compared to other international territories. For a summary of the above investigation, see the 'Conclusions' tab of this excel workbook: 
'X:\The University of the West Indies\FORDE, Shelly-Ann - BNR\REPORTS\Annual Reports\2015 Cancer Report\Data Discussion with IARC.xlsx'
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) 2015 annual report dataset was used to organize the data into a format to perform the uncertainty analysis (cancer dataset used: "`datapath'\version02\3-output\2008_2013_2014_2015_iarchub_nonsurvival_reportable"; Note: 2008 cases were ultimately excluded)
putdocx textblock end
putdocx textblock begin
(2) Stata command bootstrap used to create multiple repetitions (5,000) per site per year per sex (where applicable)
putdocx textblock end
putdocx textblock begin
(3) Stata command bsample used to perform replacements to the bootstrap repetitions per site per year per sex (where applicable)
putdocx textblock end
putdocx pagebreak
putdocx table tbl1 = data(siteiarc year sex cases mean min max), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)

putdocx save "`datapath'\version02\3-output\2021-10-04_uncertainty_stats_V03.docx", replace
putdocx clear

save "`datapath'\version02\3-output\2013_2014_2015_uncertaintystats" ,replace


** See below links for info on bootstrap command
display `"{browse "https://www.stata.com/features/overview/bootstrap-sampling-and-estimation/":Bootstrap}"'
display `"{browse "https://www.youtube.com/watch?v=_8-2QBL-9UM":Bootstrap-Video}"'