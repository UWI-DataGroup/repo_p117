cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          30_report cancer.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL/ Kern ROCKE
    //  date first created      17-NOV-2019
    // 	date last modified      23-OCT-2020
    //  algorithm task          Preparing 2013-2015 cancer datasets for reporting
    //  status                  In progress
    //  objective               To have one dataset with report outputs for 2013-2015 data for 2015 annual report.
    //  methods                 Use putdocx and Stata memory to produce tables and figures

    ** General algorithm set-up
    version 15
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
    log using "`logpath'\30_report cancer.smcl", replace // error r(603)
** HEADER -----------------------------------------------------
*************************
**  SUMMARY STATISTICS **
*************************
** Annual report: Table 1 (executive summary)
** Load the NON-SURVIVAL dataset
use "`datapath'\version02\3-output\2013_2014_2015_cancer_nonsurvival", clear // note pop_bb removed in the 

** POPULATION
gen poptot_2015=285327
gen poptot_2014=284825
gen poptot_2013=284294

** TUMOURS
egen tumourtot_2013=count(pid) if dxyr==2013
egen tumourtot_2014=count(pid) if dxyr==2014
egen tumourtot_2015=count(pid) if dxyr==2015
gen tumourtotper_2013=tumourtot_2013/poptot_2013*100
gen tumourtotper_2014=tumourtot_2014/poptot_2014*100
gen tumourtotper_2015=tumourtot_2015/poptot_2015*100
format tumourtotper_2013 tumourtotper_2014 tumourtotper_2015 %04.2f
** PATIENTS
egen patienttot_2013=count(pid) if patient==1 & dxyr==2013
egen patienttot_2014=count(pid) if patient==1 & dxyr==2014
egen patienttot_2015=count(pid) if patient==1 & dxyr==2015
** DCOs
egen dco_2013=count(pid) if basis==0 &  dxyr==2013
egen dco_2014=count(pid) if basis==0 &  dxyr==2014
egen dco_2015=count(pid) if basis==0 &  dxyr==2015
gen dcoper_2013=dco_2013/tumourtot_2013*100
gen dcoper_2014=dco_2014/tumourtot_2014*100
gen dcoper_2015=dco_2015/tumourtot_2015*100
format dcoper_2013 dcoper_2014 dcoper_2015 %2.1f

** SURVIVAL
** Create frame for non-survival ds
frame rename default nonsurv
frame create surv 
frame change surv
** Copy patient totals from survival dataset into this dataset by creating new frame for survival dataset
use "`datapath'\version02\3-output\2013_2014_2015_cancer_survival", clear
egen surv1yr_2015_censor=count(surv1yr_2015) if surv1yr_2015==0
egen surv1yr_2015_dead=count(surv1yr_2015) if surv1yr_2015==1
drop surv1yr_2015
gen surv1yr_2015=surv1yr_2015_censor/pttotsurv_2015*100
egen surv1yr_2014_censor=count(surv1yr_2014) if surv1yr_2014==0
egen surv1yr_2014_dead=count(surv1yr_2014) if surv1yr_2014==1
drop surv1yr_2014
gen surv1yr_2014=surv1yr_2014_censor/pttotsurv_2014*100
egen surv1yr_2013_censor=count(surv1yr_2013) if surv1yr_2013==0
egen surv1yr_2013_dead=count(surv1yr_2013) if surv1yr_2013==1
drop surv1yr_2013
gen surv1yr_2013=surv1yr_2013_censor/pttotsurv_2013*100
** 3-yr survival
egen surv3yr_2015_censor=count(surv3yr_2015) if surv3yr_2015==0
egen surv3yr_2015_dead=count(surv3yr_2015) if surv3yr_2015==1
drop surv3yr_2015
gen surv3yr_2015=surv3yr_2015_censor/pttotsurv_2015*100
egen surv3yr_2014_censor=count(surv3yr_2014) if surv3yr_2014==0
egen surv3yr_2014_dead=count(surv3yr_2014) if surv3yr_2014==1
drop surv3yr_2014
gen surv3yr_2014=surv3yr_2014_censor/pttotsurv_2014*100
egen surv3yr_2013_censor=count(surv3yr_2013) if surv3yr_2013==0
egen surv3yr_2013_dead=count(surv3yr_2013) if surv3yr_2013==1
drop surv3yr_2013
gen surv3yr_2013=surv3yr_2013_censor/pttotsurv_2013*100
** 5-yr survival
gen surv5yr_2015=.
egen surv5yr_2014_censor=count(surv5yr_2014) if surv5yr_2014==0
egen surv5yr_2014_dead=count(surv5yr_2014) if surv5yr_2014==1
egen surv5yr_2013_censor=count(surv5yr_2013) if surv5yr_2013==0
egen surv5yr_2013_dead=count(surv5yr_2013) if surv5yr_2013==1
drop surv5yr_2013
gen surv5yr_2013=surv5yr_2013_censor/pttotsurv_2013*100
format surv1yr_2015 surv1yr_2014 surv1yr_2013 surv3yr_2015 surv3yr_2014 surv3yr_2013 surv5yr_2015 surv5yr_2014 surv5yr_2013 %2.1f
** Input 1yr, 3yr, 5yr, 10yr survival variables from survival ds to nonsurvival ds
frame change nonsurv
**remove duplicates
frame nonsurv: duplicates drop pid, force
frame surv: duplicates drop pid, force
//frame surv:describe
//frame nonsurv: describe
frlink m:1 pid, frame(surv) //132 unmatched
//list pid fname lname if surv==.
frget surv1yr_2015 = surv1yr_2015, from(surv)
frget surv1yr_2014 = surv1yr_2014, from(surv)
frget surv1yr_2013 = surv1yr_2013, from(surv)
frget surv3yr_2015 = surv3yr_2015, from(surv)
frget surv3yr_2014 = surv3yr_2014, from(surv)
frget surv3yr_2013 = surv3yr_2013, from(surv)
frget surv5yr_2015 = surv5yr_2015, from(surv)
frget surv5yr_2014 = surv5yr_2014, from(surv)
frget surv5yr_2013 = surv5yr_2013, from(surv)

** ASIRs
** Copy ASIR totals from ASIRs dataset into this dataset by creating new frame for ASIRs dataset
append using "`datapath'\version02\2-working\ASIRs"
gen asir_2015=asir if cancer_site==1 & year==1
gen asir_2014=asir if cancer_site==1 & year==2
gen asir_2013=asir if cancer_site==1 & year==3
format asir_* %04.2f

** Re-arrange dataset
gen id=_n
keep id tumourtot_* tumourtotper_* patienttot_* dco_* dcoper_* asir_* surv*yr_*
gen title=1 if id==1
order id title
label define title_lab 1 "Year" 2 "No.registrations(tumours)" 3 "% of entire population" 4 "No.registrations(patients)" 5 "Age-standardized Incidence Rate (ASIR) per 100,000" 6 "No.registered by death certificate only" 7 "% of tumours registered" 8 "1-year survival (%)" 9 "3-year survival (%)" 10 "5-year survival (%)" ,modify
label values title title_lab
label var title "Title"

replace title=2 if tumourtot_2015!=.
replace title=2 if tumourtot_2014!=.
replace title=2 if tumourtot_2013!=.
replace title=3 if tumourtotper_2015!=.
replace title=3 if tumourtotper_2014!=.
replace title=3 if tumourtotper_2013!=.
replace title=4 if patienttot_2015!=.
replace title=4 if patienttot_2014!=.
replace title=4 if patienttot_2013!=.
replace title=5 if asir_2015!=.
replace title=5 if asir_2014!=.
replace title=5 if asir_2013!=.
replace title=6 if dco_2015!=.
replace title=6 if dco_2014!=.
replace title=6 if dco_2013!=.
replace title=7 if dcoper_2015!=.
replace title=7 if dcoper_2014!=.
replace title=7 if dcoper_2013!=.
replace title=8 if surv1yr_2015!=.
replace title=8 if surv1yr_2014!=.
replace title=8 if surv1yr_2013!=.
replace title=9 if surv3yr_2015!=.
replace title=9 if surv3yr_2014!=.
replace title=9 if surv3yr_2013!=.
replace title=10 if surv5yr_2015!=.
replace title=10 if surv5yr_2014!=.
replace title=10 if surv5yr_2013!=.

*-------------------------------------------------------------------------------

tab title ,m //some titles got replaced so add in new obs
** % of entire population needs to be added in
//list id tumourtotper_2013 if tumourtotper_2013!=.
expand=2 in 333, gen (tumtotper_2013)
replace id=9001 if tumtotper_2013==1
replace title=3 if tumtotper_2013!=0
//list id tumourtotper_2014 if tumourtotper_2014!=.
expand=2 in 14, gen (tumtotper_2014)
replace id=9002 if tumtotper_2014==1
replace title=3 if tumtotper_2014!=0
//list id tumourtotper_2015 if tumourtotper_2015!=.
expand=2 in 15, gen (tumtotper_2015) // Note to change the in input
replace id=9003 if tumtotper_2015==1
replace title=3 if tumtotper_2015!=0

/*
** Add in ASIR observations
expand=2 in 1, gen (asir_2008)
replace id=9007 if asirtot_2008!=.
expand=2 in 1, gen (asir_2013)
replace id=9008 if asirtot_2013!=.
expand=2 in 1, gen (asir_2014)
replace id=9009 if asirtot_2014!=.
replace title=5 if asir_2014!=0
replace title=5 if asir_2013!=0
replace title=5 if asir_2008!=0
expand=2 in 1, gen (asir_2015)
replace id=9010 if asirtot_2015!=.
replace title=6 if asir_2015!=0
replace title=6 if asir_2014!=0
replace title=6 if asir_2013!=0
replace title=6 if asir_2008!=0
*/

** No.registered by death certificate only needs to be added in
//list id dco_2013 if dco_2013!=.
expand=2 in 226, gen (dcotot_2013)
replace id=9005 if dcotot_2013==1
replace title=6 if dcotot_2013!=0
//list id dco_2014 if dco_2014!=.
expand=2 in 16, gen (dcotot_2014)
replace id=9006 if dcotot_2014==1
replace title=6 if dcotot_2014!=0
//list id dco_2015 if dco_2015!=.
expand=2 in 2295, gen (dcotot_2015) // Note check the in input
replace id=9007 if dcotot_2015==1
replace title=6 if dcotot_2015!=0


** No.registrations(tumours) needs to be added in
//list id tumourtot_2013 if tumourtot_2013!=.
expand=2 in 100, gen (tumtot_2013)
replace id=9008 if tumtot_2013==1
replace title=2 if tumtot_2013!=0
//list id tumourtot_2014 if tumourtot_2014!=.
expand=2 in 791, gen (tumtot_2014)
replace id=9009 if tumtot_2014==1
replace title=2 if tumtot_2014!=0
//list id tumourtot_2015 if tumourtot_2015!=.
expand=2 in 1136, gen (tumtot_2015) // Note to change the in input
replace id=9010 if tumtot_2015==1
replace title=2 if tumtot_2015!=0

drop tumtotper_* dcotot_* tumtot_*

tab title ,m //40 missing - remove blank titles as no data in any of the corresponding fields for those blank titles
drop if title==. //40 deleted

** Rearrange summ stats datast
egen tumtot_2015=max(tumourtot_2015)
egen tumtot_2014=max(tumourtot_2014)
egen tumtot_2013=max(tumourtot_2013)

egen tumtotper_2015=max(tumourtotper_2015)
egen tumtotper_2014=max(tumourtotper_2014)
egen tumtotper_2013=max(tumourtotper_2013)
format tumtotper_2013 tumtotper_2014 tumtotper_2015 %04.2f

egen pttot_2015=max(patienttot_2015)
egen pttot_2014=max(patienttot_2014)
egen pttot_2013=max(patienttot_2013)

egen asirtot_2015=max(asir_2015)
egen asirtot_2014=max(asir_2014)
egen asirtot_2013=max(asir_2013)

egen dcotot_2015=max(dco_2015)
egen dcotot_2014=max(dco_2014)
egen dcotot_2013=max(dco_2013)

egen dcototper_2015=max(dcoper_2015)
egen dcototper_2014=max(dcoper_2014)
egen dcototper_2013=max(dcoper_2013)

egen surv1yrtot_2015=max(surv1yr_2015)
egen surv1yrtot_2014=max(surv1yr_2014)
egen surv1yrtot_2013=max(surv1yr_2013)

egen surv3yrtot_2015=max(surv3yr_2015)
egen surv3yrtot_2014=max(surv3yr_2014)
egen surv3yrtot_2013=max(surv3yr_2013)

egen surv5yrtot_2015=max(surv5yr_2015)
egen surv5yrtot_2014=max(surv5yr_2014)
egen surv5yrtot_2013=max(surv5yr_2013)


**  Using format below displays all correctly but this one as it need rounding up first
replace dcototper_2013=round(dcototper_2013, 0.15)
replace dcototper_2014=round(dcototper_2014, 0.15)
replace dcototper_2015=round(dcototper_2015, 0.15)
replace surv1yrtot_2015=round(surv1yrtot_2015, 0.15)
replace surv1yrtot_2014=round(surv1yrtot_2014, 0.15)
replace surv1yrtot_2013=round(surv1yrtot_2013, 0.15)
replace surv3yrtot_2015=round(surv3yrtot_2015, 0.15)
replace surv3yrtot_2014=round(surv3yrtot_2014, 0.15)
replace surv3yrtot_2013=round(surv3yrtot_2013, 0.15)
replace surv5yrtot_2014=round(surv5yrtot_2014, 0.15)
replace surv5yrtot_2013=round(surv5yrtot_2013, 0.15)
format dcototper_2013 dcototper_2014 dcototper_2015 surv1yrtot_2015 surv1yrtot_2014 surv1yrtot_2013 surv3yrtot_2015 surv3yrtot_2014 surv3yrtot_2013 surv5yrtot_2014 surv5yrtot_2013 %2.1f

*-------------------------------------------------------------------------------

drop tumourtot_* tumourtotper_* patienttot_* dco_* dcoper_* asir_* surv1yr_* surv3yr_* surv5yr_*
order id title tumtot_2015 tumtot_2014 tumtot_2013 tumtotper_2015 tumtotper_2014 tumtotper_2013 pttot_2015 pttot_2014 pttot_2013 asirtot_2015 asirtot_2014 asirtot_2013 dcotot_2015 dcotot_2014 dcotot_2013 dcototper_2015 dcototper_2014 dcototper_2013 surv1yrtot_2015 surv1yrtot_2014 surv1yrtot_2013 surv3yrtot_2015 surv3yrtot_2014 surv3yrtot_2013 surv5yrtot_2015 surv5yrtot_2014 surv5yrtot_2013

replace title=1 if id==1
replace title=2 if id==2
replace title=3 if id==3
replace title=4 if id==4
replace title=5 if id==5
replace title=6 if id==6
replace title=7 if id==7
replace title=8 if id==8
replace title=9 if id==9
replace title=10 if id==10

drop if id>10
rename tumtot_2015 results_2015
rename tumtot_2014 results_2014
rename tumtot_2013 results_2013

format tumtotper_2013 tumtotper_2014 tumtotper_2015 %04.2f
replace results_2015=tumtotper_2015 if id==3
replace results_2014=tumtotper_2014 if id==3
replace results_2013=tumtotper_2013 if id==3
replace results_2013=round(results_2013, 0.01) if id==3
replace results_2014=round(results_2014, 0.01) if id==3
replace results_2015=round(results_2015, 0.01) if id==3
drop tumtotper_*

replace results_2015=pttot_2015 if id==4
replace results_2014=pttot_2014 if id==4
replace results_2013=pttot_2013 if id==4
drop pttot_*

format asirtot_* %04.2f
replace results_2015=asirtot_2015 if id==5
replace results_2014=asirtot_2014 if id==5
replace results_2013=asirtot_2013 if id==5
//if id==5 format results_* %04.2f
//replace results_2014=204.80 if id==5
drop asirtot_*

replace results_2015=dcotot_2015 if id==6
replace results_2014=dcotot_2014 if id==6
replace results_2013=dcotot_2013 if id==6
drop dcotot_*

replace results_2015=dcototper_2015 if id==7
replace results_2014=dcototper_2014 if id==7
replace results_2013=dcototper_2013 if id==7
drop dcototper_*

replace results_2015=surv1yrtot_2015 if id==8
replace results_2014=surv1yrtot_2014 if id==8
replace results_2013=surv1yrtot_2013 if id==8

replace results_2015=surv3yrtot_2015 if id==9
replace results_2014=surv3yrtot_2014 if id==9
replace results_2013=surv3yrtot_2013 if id==9

replace results_2015=surv5yrtot_2015 if id==10
replace results_2014=surv5yrtot_2014 if id==10
replace results_2013=surv5yrtot_2013 if id==10

drop surv1yrtot_* surv3yrtot_* surv5yrtot_*

replace results_2015=2015 if id==1
replace results_2014=2014 if id==1
replace results_2013=2013 if id==1

preserve
				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
				****************************
putdocx clear
putdocx begin, footer(foot1)
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER 2015 Annual Report: Stata Results"), bold
putdocx textblock begin
Date Prepared: 23-OCT-2020. 
Prepared by: JC using Stata & Redcap data release date: 14-Nov-2019. 
Generated using Dofile: 30_report cancer.do
putdocx textblock end
putdocx paragraph, halign(center)
putdocx text ("Table 1. Summary Statistics for BNR-Cancer, 2015 (Population=285,327), 2014 (Population=284,825), 2013 (Population=284,294))"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Standards"), bold
putdocx paragraph, halign(center)
putdocx image "`datapath'\version02\1-input\standards.png", width(6.64) height(6.8)
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) No.(tumours): Includes standardized case definition, i.e. includes unk residents, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version02\3-output\2013_2014_2015_cancer_nonsurvival")
putdocx textblock end
putdocx textblock begin
(2) % of population: WPP population for 2013, 2014 and 2015 (see p_117\2015AnnualReportV02 branch\0_population.do)
putdocx textblock end
putdocx textblock begin
(3) No.(patients): Includes standardized case definition, i.e. includes unk residents, non-malignant tumours, IARC non-reportable MPs (variable used: patient; dataset used: "`datapath'\version02\3-output\2013_2014_2015_cancer_nonsurvival")
putdocx textblock end
putdocx textblock begin
(4) ASIR: Includes standardized case definition, i.e. includes unk residents, IARC non-reportable MPs but excludes non-malignant tumours; stata command distrate used with pop_wpp_2015-10, pop_wpp_2014-10, pop_wpp_2013-10 for 2015,2014,2013 cancer incidence, respectively, and world population dataset: who2000_10-2; (population datasets used: "`datapath'\version02\2-working\pop_wpp_2015-10;pop_wpp_2014-10;pop_wpp_2013-10"; cancer dataset used: "`datapath'\version02\2-working\2013_2014_2015_cancer_numbers")
putdocx textblock end
putdocx textblock begin
(5) Site Order: These tables show where the order of 2015 top 10 sites in 2015,2014,2013, respectively; site order datasets used: "`datapath'\version02\2-working\siteorder_2015; siteorder_2014; siteorder_2013")
putdocx textblock end
putdocx textblock begin
(6) ASIR by sex: Includes standardized case definition, i.e. includes unk residents, IARC non-reportable MPs but excludes non-malignant tumours; unk/missing ages were included in the median age group; stata command distrate used with pop_wpp_2015-10 for 2015 cancer incidence, ONLY, and world population dataset: who2000_10-2; (population datasets used: "`datapath'\version02\2-working\pop_wpp_2015-10"; cancer dataset used: "`datapath'\version02\2-working\2013_2014_2015_cancer_numbers")
putdocx textblock end
putdocx textblock begin
(7) Population text files (WPP): saved in: "`datapath'\version02\2-working\WPP_population by sex_yyyy"
putdocx textblock end
putdocx textblock begin
(8) Population files (WPP): generated from "https://population.un.org/wpp/Download/Standard/Population/" on 27-Nov-2019.
putdocx textblock end
putdocx textblock begin
(9) No.(DCOs): Includes standardized case definition, i.e. includes unk residents, non-malignant tumours, IARC non-reportable MPs. (variable used: basis. dataset used: "`datapath'\version02\3-output\2013_2014_2015_cancer_nonsurvival")
putdocx textblock end
putdocx textblock begin
(10) % of tumours: Includes standardized case definition, i.e. includes unk residents, non-malignant tumours, IARC non-reportable MPs (variable used: basis; dataset used: "`datapath'\version02\3-output\2013_2014_2015_cancer_nonsurvival")
putdocx textblock end
putdocx textblock begin
(11) 1-yr, 3-yr, 5-yr (%): Excludes dco, unk slc, age 100+, multiple primaries, ineligible case definition, non-residents, REMOVE IF NO unk sex, non-malignant tumours, IARC non-reportable MPs (variable used: surv1yr_2013, surv1yr_2014, surv1yr_2015, surv3yr_2013, surv3yr_2014, surv3yr_2015, surv5yr_2013, surv5yr_2014; dataset used: "`datapath'\version02\3-output\2013_2014_2015_cancer_survival")
putdocx textblock end
//putdocx pagebreak
putdocx table tbl1 = data(title results_2015 results_2014 results_2013), halign(center)
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(3,2), nformat(%04.2f)
putdocx table tbl1(3,3), nformat(%04.2f)
putdocx table tbl1(3,4), nformat(%04.2f)
putdocx table tbl1(3,5), nformat(%04.2f)
putdocx table tbl1(7,2), nformat(%2.1f)
putdocx table tbl1(7,3), nformat(%2.1f)
putdocx table tbl1(7,4), nformat(%2.1f)
putdocx table tbl1(7,5), nformat(%2.1f)
putdocx table tbl1(8,2), nformat(%2.1f)
putdocx table tbl1(8,3), nformat(%2.1f)
putdocx table tbl1(8,4), nformat(%2.1f)
putdocx table tbl1(8,5), nformat(%2.1f)
putdocx table tbl1(9,2), nformat(%2.1f)
putdocx table tbl1(9,3), nformat(%2.1f)
putdocx table tbl1(9,4), nformat(%2.1f)                       
putdocx table tbl1(10,2), nformat(%2.1f)
putdocx table tbl1(10,3), nformat(%2.1f)
putdocx table tbl1(10,4), nformat(%2.1f)
putdocx table tbl1(10,5), nformat(%2.1f)

putdocx save "`datapath'\version02\3-output\2020-10-23_annual_report_stats.docx", replace
putdocx clear

save "`datapath'\version02\3-output\2013_2014_2015summstats" ,replace
restore

clear

** Output for above ASIRs
preserve
use "`datapath'\version02\2-working\ASIRs", clear
format asir %04.2f
sort cancer_site year number

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *       ASIRs - ALL        *
				****************************

putdocx clear
putdocx begin

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("ASIRs"), bold
putdocx paragraph, halign(center)
putdocx text ("All Sites by Year"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx table tbl1 = data(cancer_site year number percent asir ci_lower ci_upper), halign(center) varnames
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
putdocx save "`datapath'\version02\3-output\2020-10-23_annual_report_stats.docx", append
putdocx clear
restore

clear

** Output for above Site Order tables
preserve
use "`datapath'\version02\2-working\siteorder_2015", clear
sort order_id siteiarc

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *     SITE ORDER - 2015    *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak
// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Site Order Tables"), bold
putdocx paragraph, halign(center)
putdocx text ("2015"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx table tbl1 = data(order_id siteiarc count percentage), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(2,.), bold shading("yellow")
putdocx table tbl1(3,.), bold shading("yellow")
putdocx table tbl1(4,.), bold shading("yellow")
putdocx table tbl1(5,.), bold shading("yellow")
putdocx table tbl1(6,.), bold shading("yellow")
putdocx table tbl1(7,.), bold shading("yellow")
putdocx table tbl1(8,.), bold shading("yellow")
putdocx table tbl1(9,.), bold shading("yellow")
putdocx table tbl1(10,.), bold shading("yellow")
putdocx table tbl1(11,.), bold shading("yellow")
//putdocx table tbl1(12,.), bold shading("yellow")
putdocx save "`datapath'\version02\3-output\2020-10-23_annual_report_stats.docx", append
putdocx clear
restore

clear

** Output for above Site Order tables
preserve
use "`datapath'\version02\2-working\siteorder_2014", clear
sort order_id siteiarc

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *     SITE ORDER - 2014    *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak
// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Site Order Tables"), bold
putdocx paragraph, halign(center)
putdocx text ("2014"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx table tbl1 = data(order_id siteiarc count percentage), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(2,.), bold shading("yellow")
putdocx table tbl1(3,.), bold shading("yellow")
putdocx table tbl1(4,.), bold shading("yellow")
putdocx table tbl1(5,.), bold shading("yellow")
putdocx table tbl1(6,.), bold shading("yellow")
putdocx table tbl1(7,.), bold shading("yellow")
putdocx table tbl1(8,.), bold shading("yellow")
putdocx table tbl1(10,.), bold shading("yellow")
putdocx table tbl1(11,.), bold shading("yellow")
putdocx table tbl1(13,.), bold shading("yellow")
//putdocx table tbl1(17,.), bold shading("yellow")
putdocx save "`datapath'\version02\3-output\2020-10-23_annual_report_stats.docx", append
putdocx clear
restore

clear

** Output for above Site Order tables
preserve
use "`datapath'\version02\2-working\siteorder_2013", clear
sort order_id siteiarc

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *     SITE ORDER - 2013    *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, halign(center)
putdocx text ("2013"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx table tbl1 = data(order_id siteiarc count percentage), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(2,.), bold shading("yellow")
putdocx table tbl1(3,.), bold shading("yellow")
putdocx table tbl1(4,.), bold shading("yellow")
putdocx table tbl1(5,.), bold shading("yellow")
putdocx table tbl1(7,.), bold shading("yellow")
putdocx table tbl1(8,.), bold shading("yellow")
putdocx table tbl1(9,.), bold shading("yellow")
putdocx table tbl1(11,.), bold shading("yellow")
putdocx table tbl1(12,.), bold shading("yellow")
//putdocx table tbl1(13,.), bold shading("yellow")
putdocx table tbl1(14,.), bold shading("yellow")
//putdocx table tbl1(15,.), bold shading("yellow")
putdocx save "`datapath'\version02\3-output\2020-10-23_annual_report_stats.docx", append
putdocx clear
restore

clear

** Output for top10 by sex
preserve
use "`datapath'\version02\2-working\2015_top10_sex", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *    Top 10 by SEX: 2015   *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Number of cases for 2015 Top 10 cancers by Sex: 2015"), bold
putdocx paragraph, halign(center)
putdocx text ("2015 Top 10 - 2015"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex number), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx save "`datapath'\version02\3-output\2020-10-23_annual_report_stats.docx", append
putdocx clear
restore

clear

** Output for top10 by sex
preserve
use "`datapath'\version02\2-working\2014_top10_sex", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *    Top 10 by SEX: 2014   *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Number of cases for 2015 Top 10 cancers by Sex: 2014"), bold
putdocx paragraph, halign(center)
putdocx text ("2015 Top 10 - 2014"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex number), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx save "`datapath'\version02\3-output\2020-10-23_annual_report_stats.docx", append
putdocx clear
restore

clear

** Output for top10 by sex
preserve
use "`datapath'\version02\2-working\2013_top10_sex", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *    Top 10 by SEX: 2013   *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Number of cases for 2015 Top 10 cancers by Sex: 2013"), bold
putdocx paragraph, halign(center)
putdocx text ("2015 Top 10 - 2013"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex number), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx save "`datapath'\version02\3-output\2020-10-23_annual_report_stats.docx", append
putdocx clear
restore

clear

** Output for above ASIRs by sex
preserve
use "`datapath'\version02\2-working\ASIRs_female", clear
format asir %04.2f
sort cancer_site asir

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *       ASIRs - FEMALE     *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("ASIRs"), bold
putdocx paragraph, halign(center)
putdocx text ("Top 5 - FEMALE"), bold font(Helvetica,14,"blue")
putdocx paragraph, halign(center)
putdocx text ("Basis (# tumours/n=1,035)"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx table tbl1 = data(cancer_site number percent asir ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx save "`datapath'\version02\3-output\2020-10-23_annual_report_stats.docx", append
putdocx clear
restore

clear

** Output for above ASIRs by sex
preserve
use "`datapath'\version02\2-working\ASIRs_male", clear
format asir %04.2f
sort cancer_site asir

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *       ASIRs - MALE       *
				****************************

putdocx clear
putdocx begin

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("ASIRs"), bold
putdocx paragraph, halign(center)
putdocx text ("Top 5 - MALE"), bold font(Helvetica,14,"blue")
putdocx paragraph, halign(center)
putdocx text ("Basis (# tumours/n=1,035)"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx table tbl1 = data(cancer_site number percent asir ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx save "`datapath'\version02\3-output\2020-10-23_annual_report_stats.docx", append
putdocx clear
restore

clear

** Output for top10 age-specific rates by sex
preserve
use "`datapath'\version02\2-working\2015_top10_age+sex_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				*       by sex: 2015       *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific rates for 2015 Top 10 cancers by Sex: 2015"), bold
putdocx paragraph, halign(center)
putdocx text ("2015 Top 10 - 2015"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no cases (dataset used: "`datapath'\version02\2-working\2015_top10_age+sex_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx save "`datapath'\version02\3-output\2020-10-23_annual_report_stats.docx", append
putdocx clear
restore

clear

** Output for top10 age-specific rates by sex
preserve
use "`datapath'\version02\2-working\2014_top10_age+sex_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				*       by sex: 2014       *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific rates for 2015 Top 10 cancers by Sex: 2014"), bold
putdocx paragraph, halign(center)
putdocx text ("2015 Top 10 - 2014"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no cases (dataset used: "`datapath'\version02\2-working\2014_top10_age+sex_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx save "`datapath'\version02\3-output\2020-10-23_annual_report_stats.docx", append
putdocx clear
restore

clear

** Output for top10 age-specific rates by sex
preserve
use "`datapath'\version02\2-working\2013_top10_age+sex_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				*       by sex: 2013       *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific rates for 2015 Top 10 cancers by Sex: 2013"), bold
putdocx paragraph, halign(center)
putdocx text ("2015 Top 10 - 2013"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no cases (dataset used: "`datapath'\version02\2-working\2013_top10_age+sex_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx save "`datapath'\version02\3-output\2020-10-23_annual_report_stats.docx", append
putdocx clear
restore

clear

** JC 03mar20: neither of the below reports will be used in the 2015 annual report so code has been disabled
** JC 15oct20: NS decided to include ASMRs on 14-OCT-2020.
				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *           ASMRs          *
				****************************

** Output for above ASIRs comparison using BSS vs WPP populations
use "`datapath'\version02\2-working\ASMRs", clear
//format asmr %04.2f
//format percentage %04.1f
sort cancer_site year asmr

preserve
putdocx clear
putdocx begin, footer(foot1)
putdocx pagebreak
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER 2015 Annual Report: ASMRs"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 10. Top 10 Cancer Mortality Statistics for BNR-Cancer, 2015 (Population=276,633)"), bold font(Helvetica,10,"blue")
putdocx textblock begin
Date Prepared: 15-Oct-2020.
Prepared by: JC using Stata & Redcap data release date: 14-Nov-2019. 
Generated using Dofile: 25_analysis mort.do
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) No.(tumours): Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version02\3-output\2015_prep mort")
putdocx textblock end
putdocx textblock begin
(2) ASMR: Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (distrate using barbados population: pop_bss_2015-10 and world population dataset: who2000_10-2; cancer dataset used: "`datapath'\version02\3-output\2015 prep mort")
putdocx textblock end
//putdocx pagebreak
putdocx table tbl1 = data(cancer_site year number percent asmr ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)
putdocx save "`datapath'\version02\3-output\2020-10-23_annual_report_stats.docx", append
putdocx clear

save "`datapath'\version02\3-output\2013_2014_2015_summstats" ,replace
restore

/*
** Output for above ASIRs comparison using BSS vs WPP populations
use "`datapath'\version02\2-working\ASIRs_BSS_WPP", clear
format asir %04.2f
sort cancer_site year asir

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
				****************************
putdocx clear
putdocx begin, footer(foot1)
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER Population Report: BSS vs WPP"), bold
putdocx textblock begin
Date Prepared: 02-Dec-2019. 
Prepared by: JC using Stata & Redcap data release date: 14-Nov-2019. 
Generated using Dofile: repo_p117\20_analysis cancer.do
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) Dataset: Excludes ineligible case definition, non-residents, non-malignant tumours, IARC non-reportable MPs; cancer dataset used: "`datapath'\version02\3-output\2008_2013_2014__2015_cancer_nonsurvival")
putdocx textblock end
putdocx textblock begin
(2) ASIR (BSS_2013): stata command distrate used with pop_bss_2013-10 for 2013 cancer incidence and world population dataset: who2000_10-2; population datasets used: "`datapath'\version02\2-working\pop_bss_2013-10")
putdocx textblock end
putdocx textblock begin
(3) ASIR (WPP_2013): stata command distrate used with pop_wpp_2013-10 for 2013 cancer incidence and world population dataset: who2000_10-2; population datasets used: "`datapath'\version02\2-working\pop_wpp_2013-10")
putdocx textblock end
putdocx textblock begin
(4) ASIR (BSS_2014): stata command distrate used with pop_bss_2014-10 for 2014 cancer incidence and world population dataset: who2000_10-2; population datasets used: "`datapath'\version02\2-working\pop_bss_2014-10")
putdocx textblock end
putdocx textblock begin
(5) ASIR (WPP_2014): stata command distrate used with pop_wpp_2014-10 for 2014 cancer incidence and world population dataset: who2000_10-2; population datasets used: "`datapath'\version02\2-working\pop_wpp_2014-10")
putdocx textblock end
putdocx textblock begin
(6) ASIR (BSS_2015): stata command distrate used with pop_bss_2015-10 for 2015 cancer incidence and world population dataset: who2000_10-2; population datasets used: "`datapath'\version02\2-working\pop_bss_2015-10")
putdocx textblock end
putdocx textblock begin
(7) ASIR (WPP_2015): stata command distrate used with pop_wpp_2015-10 for 2015 cancer incidence and world population dataset: who2000_10-2; population datasets used: "`datapath'\version02\2-working\pop_wpp_2015-10")
putdocx textblock end
putdocx textblock begin
(8) Population text files (BSS): saved in: "`datapath'\version02\2-working\BSS_population by sex_yyyy"
putdocx textblock end
putdocx textblock begin
(9) Population text files (WPP): saved in: "`datapath'\version02\2-working\WPP_population by sex_yyyy"
putdocx textblock end
putdocx textblock begin
(10) Population files (BSS): emailed to JCampbell from BSS' Socio-and-Demographic Statistics Division by Statistical Assistant on 29-Nov-2019.
putdocx textblock end
putdocx textblock begin
(11) Population files (WPP): generated from "https://population.un.org/wpp/Download/Standard/Population/" on 27-Nov-2019.
putdocx textblock end
putdocx pagebreak
putdocx table tbl1 = data(population cancer_site year asir ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx save "`datapath'\version02\3-output\2019-12-02_population_comparison.docx", replace
putdocx clear

save "`datapath'\version02\3-output\population_comparison_BSS_WPP" ,replace
