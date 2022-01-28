** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          005_prep stata.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      27-JAN-2022
    // 	date last modified      27-JAN-2022
    //  algorithm task          Preparing 2013-2015 nonsurvival 2015 annual report dataset for research
    //  status                  Completed
    //  objective               To have one dataset with cleaned 2013 colorectal data to compare staging with 2018 colorectal data
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
    log using "`logpath'\005_prep stata.smcl", replace
** HEADER -----------------------------------------------------

************************************
** 2013-2015 Non-survival Dataset **
************************************

** Load the dataset from 2015 annual report copied from `datapath'\version02\3-output
use "`datapath'\version08\1-input\2013_2014_2015_cancer_nonsurvival", replace
count //2774

tab dxyr ,m
/*
DiagnosisYe |
         ar |      Freq.     Percent        Cum.
------------+-----------------------------------
       2013 |        876       31.58       31.58
       2014 |        862       31.07       62.65
       2015 |      1,036       37.35      100.00
------------+-----------------------------------
      Total |      2,774      100.00
*/

** Table of basis of dx by year (2013-2015) for ALL SITES
tab basis dxyr
/*
                      |          DiagnosisYear
     BasisOfDiagnosis |      2013       2014       2015 |     Total
----------------------+---------------------------------+----------
                  DCO |        59         41        101 |       201 
        Clinical only |        21         38         65 |       124 
Clinical Invest./Ult  |        50         27         44 |       121 
Exploratory surg./aut |        10          5          5 |        20 
Lab test (biochem/imm |         5          5          3 |        13 
        Cytology/Haem |        31         45         28 |       104 
           Hx of mets |        13         13         18 |        44 
        Hx of primary |       637        626        742 |     2,005 
        Autopsy w/ Hx |         6          9          4 |        19 
              Unknown |        44         53         26 |       123 
----------------------+---------------------------------+----------
                Total |       876        862      1,036 |     2,774
*/
preserve
gen x = 1 
collapse (count) x, by(basis dxyr)
list
rename x count
order basis dxyr count
save "`datapath'\version08\2-working\basis_allsites_2013-2015" ,replace
restore


** Remove non-colorectal cases
labelbook siteiarc_lab
tab siteiarc ,m //110 colon 45 rectum

keep if siteiarc==13|siteiarc==14 //721 deleted


** Table of basis of dx by year (2013-2015) for COLORECTAL
tab basis dxyr
/*
                      |          DiagnosisYear
     BasisOfDiagnosis |      2013       2014       2015 |     Total
----------------------+---------------------------------+----------
                  DCO |         6          5         12 |        23 
        Clinical only |         1          4          5 |        10 
Clinical Invest./Ult  |         7          3          3 |        13 
Exploratory surg./aut |         4          1          1 |         6 
           Hx of mets |         2          2          2 |         6 
        Hx of primary |       127        109        133 |       369 
        Autopsy w/ Hx |         1          1          2 |         4 
              Unknown |         7          5          2 |        14 
----------------------+---------------------------------+----------
                Total |       155        130        160 |       445
*/
preserve
gen x = 1 
collapse (count) x, by(basis dxyr)
list
rename x count
order basis dxyr count
save "`datapath'\version08\2-working\basis_colorectal_2013-2015" ,replace
restore


** Remove non-2013 cases
drop if dxyr!=2013 //1898 deleted

** Additional cleaning check for staging variable
tab staging ,m //4 records = N/A: review in MasterDb and CR5db
//list pid cr5id slc top morph basis if staging==8
replace staging=9 if pid=="20140032" & cr5id=="T1S1" //stage 9 instead of 7 since the mets were noted a year after dot
replace staging=9 if pid=="20140127" & cr5id=="T1S1"
replace staging=9 if pid=="20140154" & cr5id=="T1S1"
replace staging=9 if pid=="20140268" & cr5id=="T1S1"

tab staging ,m
/*
                      Staging |      Freq.     Percent        Cum.
------------------------------+-----------------------------------
               Localised only |         36       23.23       23.23
        Regional: direct ext. |         25       16.13       39.35
           Regional: LNs only |         10        6.45       45.81
Regional: both dir. ext & LNs |         23       14.84       60.65
          Distant site(s)/LNs |         35       22.58       83.23
            Unknown; DCO case |         26       16.77      100.00
------------------------------+-----------------------------------
                        Total |        155      100.00
*/

preserve
contract staging, freq(count) percent(percentage)
summ 
describe
gsort -count
gen year=2013
list year staging
sort staging
order year staging count percentage
save "`datapath'\version08\2-working\staging_2013" ,replace
restore

tab basis ,m //none missing
tab basis staging
/*
                      |                              Staging
     BasisOfDiagnosis | Localised  Regional:  Regional:  Regional:  Distant s  Unknown;  |     Total
----------------------+------------------------------------------------------------------+----------
                  DCO |         0          0          0          0          0          6 |         6 
        Clinical only |         0          0          0          0          0          1 |         1 
Clinical Invest./Ult  |         2          1          0          0          3          1 |         7 
Exploratory surg./aut |         1          1          0          0          0          2 |         4 
           Hx of mets |         0          0          0          0          2          0 |         2 
        Hx of primary |        33         23         10         23         30          8 |       127 
        Autopsy w/ Hx |         0          0          0          0          0          1 |         1 
              Unknown |         0          0          0          0          0          7 |         7 
----------------------+------------------------------------------------------------------+----------
                Total |        36         25         10         23         35         26 |       155
*/

preserve
gen x = 1 
collapse (count) x, by(staging basis)
list
rename x count
gen year=2013
order year staging basis count
save "`datapath'\version08\2-working\stagingbasis_2013" ,replace
restore

count //155

** Save this colorectal dataset
save "`datapath'\version08\3-output\2013_colorectal_nonsurvival", replace
label data "2013 BNR-Cancer analysed data - COLORECTAL Non-survival BNR Reportable Dataset"
note: TS This dataset was used for research paper on late stage presentation
note: TS Excludes all sites except C18-C20, ineligible case definition, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs
