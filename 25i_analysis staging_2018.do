
cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          25i_analysis staging_2018.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      05-SEP-2022
    // 	date last modified      05-SEP-2022
    //  algorithm task          Analyzing combined cancer dataset: Staging for prostate for 2016-2018 annual report
    //  status                  Completed
    //  objective               To have one dataset with cleaned and grouped 2018 prostate data for inclusion in the 2016-2018 annual report.
    //  methods                 See 30a_report cancer_WORD.do for detailed methods of each statistic

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
    log using "`logpath'/25i_analysis staging_2018.smcl", replace
** HEADER -----------------------------------------------------

** JC 05sep2022: SF requested via phone prostate staging outputs same as the ones in p117/version08 + VS branch '2022ResearchV01' for colorectal staging

**********
** 2018 **
**********
** Load the dataset
use "`datapath'\version09\2-working\2013-2018_cancer_numbers", clear

drop if dxyr!=2018 //4907 deleted
drop if siteiarc!=39 //739 deleted
count //221

** Same as was done for NAACCR 2022 abstract, create time variable for time from:
** incidence date to death/last contact
gen time_alive=dlc-dot if slc==1
label var time_alive "Alive Cases: Time between incidence and last contact in Days"

gen time_dead=dod-dot if slc==2
label var time_dead "Deceased Cases: Time between incidence and last contact in Days"

tab tnmantstage ,m
/*
    TNM Ant |
      Stage |      Freq.     Percent        Cum.
------------+-----------------------------------
          I |         95       42.99       42.99
         II |         64       28.96       71.95
        III |         14        6.33       78.28
         IV |         25       11.31       89.59
          . |         23       10.41      100.00
------------+-----------------------------------
      Total |        221      100.00
*/

tab tnmantstage
/*
    TNM Ant |
      Stage |      Freq.     Percent        Cum.
------------+-----------------------------------
          I |         95       47.98       47.98
         II |         64       32.32       80.30
        III |         14        7.07       87.37
         IV |         25       12.63      100.00
------------+-----------------------------------
      Total |        198      100.00
*/

tab etnmantstage ,m
/*
  Essential |
    TNM Ant |
      Stage |      Freq.     Percent        Cum.
------------+-----------------------------------
          I |         10        4.52        4.52
         II |          5        2.26        6.79
        III |          9        4.07       10.86
         IV |         20        9.05       19.91
          . |        177       80.09      100.00
------------+-----------------------------------
      Total |        221      100.00
*/

tab etnmantstage
/*
  Essential |
    TNM Ant |
      Stage |      Freq.     Percent        Cum.
------------+-----------------------------------
          I |         10       22.73       22.73
         II |          5       11.36       34.09
        III |          9       20.45       54.55
         IV |         20       45.45      100.00
------------+-----------------------------------
      Total |         44      100.00
*/

tab staging ,m
/*
                      Staging |      Freq.     Percent        Cum.
------------------------------+-----------------------------------
               Localised only |        155       70.14       70.14
        Regional: direct ext. |         17        7.69       77.83
           Regional: LNs only |          2        0.90       78.73
Regional: both dir. ext & LNs |          2        0.90       79.64
                Regional: NOS |          3        1.36       81.00
     Not enough info to stage |          9        4.07       85.07
          Distant site(s)/LNs |         17        7.69       92.76
            Unknown; DCO case |          8        3.62       96.38
                            . |          8        3.62      100.00
------------------------------+-----------------------------------
                        Total |        221      100.00
*/

** Check if stage missing for any 2018 prostate cases
count if tnmantstage==. & etnmantstage==. & staging==. //0

** Change staging=6 to staging=9 for uniformity when reporting as code 6 is a data collection code
count if staging==6 //9
replace staging=9 if staging==6 //9 changes

tab staging ,m
/*
                      Staging |      Freq.     Percent        Cum.
------------------------------+-----------------------------------
               Localised only |        155       70.14       70.14
        Regional: direct ext. |         17        7.69       77.83
           Regional: LNs only |          2        0.90       78.73
Regional: both dir. ext & LNs |          2        0.90       79.64
                Regional: NOS |          3        1.36       81.00
          Distant site(s)/LNs |         17        7.69       88.69
            Unknown; DCO case |         17        7.69       96.38
                            . |          8        3.62      100.00
------------------------------+-----------------------------------
                        Total |        221      100.00
*/


preserve
contract staging, freq(count) percent(percentage)
summ 
describe
gsort -count
gen year=2018
list year staging
sort staging
order year staging count percentage
save "`datapath'\version09\2-working\staging_2018" ,replace
restore

tab time_alive tnmantstage
tab time_alive etnmantstage

tab time_dead tnmantstage
tab time_dead etnmantstage

tab basis ,m
/*
                     Basis Of Diagnosis |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                    DCO |          7        3.17        3.17
                          Clinical only |         10        4.52        7.69
             Lab test (biochem/immuno.) |          5        2.26        9.95
Hx of primary/Autopsy with Hx of primar |        198       89.59       99.55
                                Unknown |          1        0.45      100.00
----------------------------------------+-----------------------------------
                                  Total |        221      100.00
*/

tab staging basis ,m
/*
                      |                   Basis Of Diagnosis
              Staging |       DCO  Clinical   Lab test   Hx of pri    Unknown |     Total
----------------------+-------------------------------------------------------+----------
       Localised only |         0          0          1        154          0 |       155 
Regional: direct ext. |         0          0          0         17          0 |        17 
   Regional: LNs only |         0          0          0          2          0 |         2 
Regional: both dir. e |         0          0          0          2          0 |         2 
        Regional: NOS |         0          1          0          2          0 |         3 
  Distant site(s)/LNs |         0          1          1         15          0 |        17 
    Unknown; DCO case |         7          7          1          2          0 |        17 
                    . |         0          1          2          4          1 |         8 
----------------------+-------------------------------------------------------+----------
                Total |         7         10          5        198          1 |       221
*/

preserve
gen x = 1 
collapse (count) x, by(staging basis)
list
rename x count
gen year=2018
order year staging basis count
save "`datapath'\version09\2-working\stagingbasis_2018" ,replace
restore

replace staging=8 if staging==. & (tnmantstage!=.|etnmantstage!=.) //8 changes
tab staging ,m
/*
                      Staging |      Freq.     Percent        Cum.
------------------------------+-----------------------------------
               Localised only |        155       70.14       70.14
        Regional: direct ext. |         17        7.69       77.83
           Regional: LNs only |          2        0.90       78.73
Regional: both dir. ext & LNs |          2        0.90       79.64
                Regional: NOS |          3        1.36       81.00
          Distant site(s)/LNs |         17        7.69       88.69
                           NA |          8        3.62       92.31
            Unknown; DCO case |         17        7.69      100.00
------------------------------+-----------------------------------
                        Total |        221      100.00
*/

tab notesseen ,m
/*
                            Notes Seen |      Freq.     Percent        Cum.
---------------------------------------+-----------------------------------
                                   Yes |         25       11.31       11.31
                                    No |        195       88.24       99.55
            Cannot retrieve-3 attempts |          1        0.45      100.00
---------------------------------------+-----------------------------------
                                 Total |        221      100.00
*/


** Put variables in order they are to appear	  
order pid cr5id age sex dob resident slc dlc dod dot /// 
	  parish cr5cod primarysite morph top lat beh hx grade basis time_alive time_dead

count //221

** Save this specialized dataset with staging of prostate reportable cases (DE-IDENTIFIED)
save "`datapath'\version09\3-output\2018_prostate_staging_nonsurvival_deidentified", replace
label data "2018 BNR-Cancer analysed data - Prostate Non-survival Dataset"
note: TS This dataset was used for 2016-2018 annual report
note: TS Excludes IARC flag, ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs
