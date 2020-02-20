** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          30_report cancer.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      17-NOV-2019
    // 	date last modified      17-NOV-2019
    //  algorithm task          Preparing 2008-2015 cancer datasets for reporting
    //  status                  Completed
    //  objective               To have one dataset with report outputs for 2008-2015 data for 2015 annual report.
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
    log using "`logpath'\30_report cancer.smcl", replace
** HEADER -----------------------------------------------------
*************************
**  SUMMARY STATISTICS **
*************************
** Annual report: Table 1 (executive summary)
** Load the NON-SURVIVAL dataset
use "`datapath'\version02\3-output\2008_2013_2014_2015_cancer_nonsurvival", clear
//save "`datapath'\version02\2-working\2008_2013_2014_summstats_prerpt" , replace
//use "`datapath'\version02\2-working\2008_2013_2014_summstats_prerpt" , clear

** POPULATION
tab dxyr ,m 
unique pop_bb, by(pop_bb) gen(poptotal) //ssc install unique
egen poptot=total(pop_bb) if poptotal==1
** TUMOURS
egen tumourtot_2008=count(pid) if dxyr==2008
egen tumourtot_2013=count(pid) if dxyr==2013
egen tumourtot_2014=count(pid) if dxyr==2014
gen tumourtotper_2008=tumourtot_2008/poptot*100
gen tumourtotper_2013=tumourtot_2013/poptot*100
gen tumourtotper_2014=tumourtot_2014/poptot*100
format tumourtotper_2008 tumourtotper_2013 tumourtotper_2014 %04.2f
** PATIENTS
egen patienttot_2008=count(pid) if patient==1 & dxyr==2008
egen patienttot_2013=count(pid) if patient==1 & dxyr==2013
egen patienttot_2014=count(pid) if patient==1 & dxyr==2014
** ASIRs
** DCOs
egen dco_2008=count(pid) if basis==0 & dxyr==2008
egen dco_2013=count(pid) if basis==0 &  dxyr==2013
egen dco_2014=count(pid) if basis==0 &  dxyr==2014
gen dcoper_2008=dco_2008/tumourtot_2008*100
gen dcoper_2013=dco_2013/tumourtot_2013*100
gen dcoper_2014=dco_2014/tumourtot_2014*100
format dcoper_2008 dcoper_2013 dcoper_2014 %2.1f

** SURVIVAL
** Create frame for non-survival ds
frame rename default nonsurv
frame create surv 
frame change surv
** Copy patient totals from survival dataset into this dataset by creating new frame for survival dataset
use "`datapath'\version02\3-output\2008_2013_2014_2015_cancer_survival", clear
egen surv1yr_2014_censor=count(surv1yr_2014) if surv1yr_2014==0
egen surv1yr_2014_dead=count(surv1yr_2014) if surv1yr_2014==1
drop surv1yr_2014
gen surv1yr_2014=surv1yr_2014_censor/pttotsurv_2014*100
egen surv1yr_2013_censor=count(surv1yr_2013) if surv1yr_2013==0
egen surv1yr_2013_dead=count(surv1yr_2013) if surv1yr_2013==1
drop surv1yr_2013
gen surv1yr_2013=surv1yr_2013_censor/pttotsurv_2013*100
egen surv1yr_2008_censor=count(surv1yr_2008) if surv1yr_2008==0
egen surv1yr_2008_dead=count(surv1yr_2008) if surv1yr_2008==1
drop surv1yr_2008
gen surv1yr_2008=surv1yr_2008_censor/pttotsurv_2008*100
** 3-yr survival
egen surv3yr_2014_censor=count(surv3yr_2014) if surv3yr_2014==0
egen surv3yr_2014_dead=count(surv3yr_2014) if surv3yr_2014==1
drop surv3yr_2014
gen surv3yr_2014=surv3yr_2014_censor/pttotsurv_2014*100
egen surv3yr_2013_censor=count(surv3yr_2013) if surv3yr_2013==0
egen surv3yr_2013_dead=count(surv3yr_2013) if surv3yr_2013==1
drop surv3yr_2013
gen surv3yr_2013=surv3yr_2013_censor/pttotsurv_2013*100
egen surv3yr_2008_censor=count(surv3yr_2008) if surv3yr_2008==0
egen surv3yr_2008_dead=count(surv3yr_2008) if surv3yr_2008==1
drop surv3yr_2008
gen surv3yr_2008=surv3yr_2008_censor/pttotsurv_2008*100
** 5-yr survival
gen surv5yr_2014=.
egen surv5yr_2013_censor=count(surv5yr_2013) if surv5yr_2013==0
egen surv5yr_2013_dead=count(surv5yr_2013) if surv5yr_2013==1
drop surv5yr_2013
gen surv5yr_2013=surv5yr_2013_censor/pttotsurv_2013*100
egen surv5yr_2008_censor=count(surv5yr_2008) if surv5yr_2008==0
egen surv5yr_2008_dead=count(surv5yr_2008) if surv5yr_2008==1
drop surv5yr_2008
gen surv5yr_2008=surv5yr_2008_censor/pttotsurv_2008*100
format surv1yr_2014 surv1yr_2013 surv1yr_2008 surv3yr_2014 surv3yr_2013 surv3yr_2008 surv5yr_2014 surv5yr_2013 surv5yr_2008 %2.1f
** Input 1yr, 3yr, 5yr survival variables from survival ds to nonsurvival ds
frame change nonsurv
//frame surv:describe
//frame nonsurv: describe
frlink m:1 pid, frame(surv) //132 unmatched
//list pid fname lname if surv==.
frget surv1yr_2014 = surv1yr_2014, from(surv)
frget surv1yr_2013 = surv1yr_2013, from(surv)
frget surv1yr_2008 = surv1yr_2008, from(surv)
frget surv3yr_2014 = surv3yr_2014, from(surv)
frget surv3yr_2013 = surv3yr_2013, from(surv)
frget surv3yr_2008 = surv3yr_2008, from(surv)
frget surv5yr_2014 = surv5yr_2014, from(surv)
frget surv5yr_2013 = surv5yr_2013, from(surv)
frget surv5yr_2008 = surv5yr_2008, from(surv)

** Re-arrange dataset
gen id=_n
keep id tumourtot_* tumourtotper_* patienttot_* dco_* dcoper_* surv*yr_*
gen title=1 if id==1
order id title
label define title_lab 1 "Year" 2 "No.registrations(tumours)" 3 "% of entire population" 4 "No.registrations(patients)" 5 "Age-standardized Incidence Rate (ASIR) per 100,000" 6 "No.registered by death certificate only" 7 "% of tumours registered" 8 "1-year survival (%)" 9 "3-year survival (%)" 10 "5-year survival (%)",modify
label values title title_lab
label var title "Title"

replace title=2 if tumourtot_2014!=.
replace title=2 if tumourtot_2013!=.
replace title=2 if tumourtot_2008!=.
replace title=3 if tumourtotper_2014!=.
replace title=3 if tumourtotper_2013!=.
replace title=3 if tumourtotper_2008!=.
replace title=4 if patienttot_2014!=.
replace title=4 if patienttot_2013!=.
replace title=4 if patienttot_2008!=.
replace title=6 if dco_2014!=.
replace title=6 if dco_2013!=.
replace title=6 if dco_2008!=.
replace title=7 if dcoper_2014!=.
replace title=7 if dcoper_2013!=.
replace title=7 if dcoper_2008!=.
replace title=8 if surv1yr_2014!=.
replace title=8 if surv1yr_2013!=.
replace title=8 if surv1yr_2008!=.
replace title=9 if surv3yr_2014!=.
replace title=9 if surv3yr_2013!=.
replace title=9 if surv3yr_2008!=.
replace title=10 if surv5yr_2014!=.
replace title=10 if surv5yr_2013!=.
replace title=10 if surv5yr_2008!=.

tab title ,m //some title replaced so add in new obs
** % of entire population needs to be added in
list id tumourtotper_2008 if tumourtotper_2008!=.
expand=2 in 292, gen (tumtotper_2008)
replace id=9003 if tumtotper_2008==1
replace title=3 if tumtotper_2008!=0
list id tumourtotper_2013 if tumourtotper_2013!=.
expand=2 in 520, gen (tumtotper_2013)
replace id=9004 if tumtotper_2013==1
replace title=3 if tumtotper_2013!=0
list id tumourtotper_2014 if tumourtotper_2014!=.
expand=2 in 177, gen (tumtotper_2014)
replace id=9005 if tumtotper_2014==1
replace title=3 if tumtotper_2014!=0
** Add in ASIR observations
expand=2 in 1, gen (asir_2008)
replace id=9006 if asir_2008==1
expand=2 in 1, gen (asir_2013)
replace id=9007 if asir_2013==1
expand=2 in 1, gen (asir_2014)
replace id=9008 if asir_2014==1
replace title=5 if asir_2014!=0
replace title=5 if asir_2013!=0
replace title=5 if asir_2008!=0
** No.registered by death certificate only needs to be added in
list id dco_2008 if dco_2008!=.
expand=2 in 2, gen (dcotot_2008)
replace id=9009 if dcotot_2008==1
replace title=6 if dcotot_2008!=0
list id dco_2013 if dco_2013!=.
expand=2 in 12, gen (dcotot_2013)
replace id=9010 if dcotot_2013==1
replace title=6 if dcotot_2013!=0
list id dco_2014 if dco_2014!=.
expand=2 in 20, gen (dcotot_2014)
replace id=9011 if dcotot_2014==1
replace title=6 if dcotot_2014!=0
drop tumtotper_* dcotot_*

tab title ,m 

** Rearrange summ stats datast
egen tumtot_2014=max(tumourtot_2014)
egen tumtot_2013=max(tumourtot_2013)
egen tumtot_2008=max(tumourtot_2008)
egen tumtotper_2014=max(tumourtotper_2014)
egen tumtotper_2013=max(tumourtotper_2013)
egen tumtotper_2008=max(tumourtotper_2008)
format tumtotper_2008 tumtotper_2013 tumtotper_2014 %04.2f
egen pttot_2014=max(patienttot_2014)
egen pttot_2013=max(patienttot_2013)
egen pttot_2008=max(patienttot_2008)
egen asirtot_2014=max(asir_2014)
egen asirtot_2013=max(asir_2013)
egen asirtot_2008=max(asir_2008)
egen dcotot_2014=max(dco_2014)
egen dcotot_2013=max(dco_2013)
egen dcotot_2008=max(dco_2008)
egen dcototper_2014=max(dcoper_2014)
egen dcototper_2013=max(dcoper_2013)
egen dcototper_2008=max(dcoper_2008)
egen surv1yrtot_2014=max(surv1yr_2014)
egen surv1yrtot_2013=max(surv1yr_2013)
egen surv1yrtot_2008=max(surv1yr_2008)
egen surv3yrtot_2014=max(surv3yr_2014)
egen surv3yrtot_2013=max(surv3yr_2013)
egen surv3yrtot_2008=max(surv3yr_2008)
egen surv5yrtot_2014=max(surv5yr_2014)
egen surv5yrtot_2013=max(surv5yr_2013)
egen surv5yrtot_2008=max(surv5yr_2008)
format dcototper_2008 dcototper_2013 dcototper_2014 surv1yrtot_2014 surv1yrtot_2013 surv1yrtot_2008 surv3yrtot_2014 surv3yrtot_2013 surv3yrtot_2008 surv5yrtot_2013 surv5yrtot_2008 %2.1f

drop tumourtot_* tumourtotper_* patienttot_* dco_* dcoper_* asir_* surv1yr_* surv3yr_* surv5yr_*
order id title tumtot_2014 tumtot_2013 tumtot_2008 tumtotper_2014 tumtotper_2013 tumtotper_2008 pttot_2014 pttot_2013 pttot_2008 asirtot_2014 asirtot_2013 asirtot_2008 dcotot_2014 dcotot_2013 dcotot_2008 dcototper_2014 dcototper_2013 dcototper_2008 surv1yrtot_2014 surv1yrtot_2013 surv1yrtot_2008 surv3yrtot_2014 surv3yrtot_2013 surv3yrtot_2008 surv5yrtot_2014 surv5yrtot_2013 surv5yrtot_2008

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
rename tumtot_2014 results_2014
rename tumtot_2013 results_2013
rename tumtot_2008 results_2008

replace results_2014=tumtotper_2014 if id==3
replace results_2013=tumtotper_2013 if id==3
replace results_2008=tumtotper_2008 if id==3
drop tumtotper_*

replace results_2014=pttot_2014 if id==4
replace results_2013=pttot_2013 if id==4
replace results_2008=pttot_2008 if id==4
drop pttot_*

replace results_2014=asirtot_2014 if id==5
replace results_2013=asirtot_2013 if id==5
replace results_2008=asirtot_2008 if id==5
drop asirtot_*

replace results_2014=dcotot_2014 if id==6
replace results_2013=dcotot_2013 if id==6
replace results_2008=dcotot_2008 if id==6
drop dcotot_*

replace results_2014=dcototper_2014 if id==7
replace results_2013=dcototper_2013 if id==7
replace results_2008=dcototper_2008 if id==7
drop dcototper_*

replace results_2014=surv1yrtot_2014 if id==8
replace results_2013=surv1yrtot_2013 if id==8
replace results_2008=surv1yrtot_2008 if id==8
replace results_2014=surv3yrtot_2014 if id==9
replace results_2013=surv3yrtot_2013 if id==9
replace results_2008=surv3yrtot_2008 if id==9
replace results_2014=surv5yrtot_2014 if id==10
replace results_2013=surv5yrtot_2013 if id==10
replace results_2008=surv5yrtot_2008 if id==10
drop surv1yrtot_* surv3yrtot_* surv5yrtot_*

replace results_2014=2014 if id==1
replace results_2013=2013 if id==1
replace results_2008=2008 if id==1

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
Date Prepared: 17-Nov-2019. 
Prepared by: JC using Stata & Redcap data release date: 14-Nov-2019. 
Generated using Dofile: 30_report cancer.do
putdocx textblock end
putdocx paragraph, halign(center)
putdocx text ("Table 1. Summary Statistics for BNR-Cancer, 2015 (Population=277,814))"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Standards"), bold
putdocx paragraph, halign(center)
putdocx image "`datapath'\version02\1-input\standards.png", width(6.64) height(6.8)
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) No.(tumours): Excludes ineligible case definition, non-residents, REMOVE IF NO unk sex, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version02\3-output\2008_2013_2014_cancer_nonsurvival")
putdocx textblock end
putdocx textblock begin
(2) % of population: 2000 (census) population for 2008 diagnoses; 2010 (census) population for 2013 onwards (see p_117\2015AnnualReport branch\0_population.do)
putdocx textblock end
putdocx textblock begin
(3) No.(patients): Excludes ineligible case definition, non-residents, REMOVE IF NO unk sex, non-malignant tumours, IARC non-reportable MPs (variable used: patient; dataset used: "`datapath'\version02\3-output\2008_2013_2014_cancer_nonsurvival")
putdocx textblock end
putdocx textblock begin
(4) ASIR: Excludes ineligible case definition, non-residents, REMOVE IF NO unk sex, non-malignant tumours, IARC non-reportable MPs (distrate using barbados population: bb2010_10-2 and world population dataset: who2000_10-2; cancer dataset used: "`datapath'\version02\3-output\2008_2013_2014_cancer_nonsurvival")
putdocx textblock end
putdocx textblock begin
(5) No.(DCOs): Excludes ineligible case definition, non-residents, REMOVE IF NO unk sex, non-malignant tumours, IARC non-reportable MPs (variable used: basis; dataset used: "`datapath'\version02\3-output\2008_2013_2014_cancer_nonsurvival")
putdocx textblock end
putdocx textblock begin
(6) % of tumours: Excludes ineligible case definition, non-residents, REMOVE IF NO unk sex, non-malignant tumours, IARC non-reportable MPs (variable used: basis; dataset used: "`datapath'\version02\3-output\2008_2013_2014_cancer_nonsurvival")
putdocx textblock end
putdocx textblock begin
(7) 1-yr, 3-yr, 5-yr survival (%): Excludes dco, unk slc, age 100+, multiple primaries, ineligible case definition, non-residents, REMOVE IF NO unk sex, non-malignant tumours, IARC non-reportable MPs (variable used: surv1yr_2008, surv1yr_2013, surv1yr_2014, surv3yr_2008, surv3yr_2013, surv3yr_2014, surv5yr_2008, surv5yr_2013; dataset used: "`datapath'\version02\3-output\2008_2013_2014_cancer_survival")
putdocx textblock end
//putdocx pagebreak
putdocx table tbl1 = data(title results_2014 results_2013 results_2008), halign(center)
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(3,2), nformat(%04.2f)
putdocx table tbl1(3,3), nformat(%04.2f)
putdocx table tbl1(3,4), nformat(%04.2f)
putdocx table tbl1(7,2), nformat(%2.1f)
putdocx table tbl1(7,3), nformat(%2.1f)
putdocx table tbl1(7,4), nformat(%2.1f)
putdocx table tbl1(8,2), nformat(%2.1f)
putdocx table tbl1(8,3), nformat(%2.1f)
putdocx table tbl1(8,4), nformat(%2.1f)
putdocx table tbl1(9,2), nformat(%2.1f)
putdocx table tbl1(9,3), nformat(%2.1f)
putdocx table tbl1(9,4), nformat(%2.1f)
putdocx table tbl1(10,2), nformat(%2.1f)
putdocx table tbl1(10,3), nformat(%2.1f)
putdocx table tbl1(10,4), nformat(%2.1f)

putdocx save "`datapath'\version02\3-output\2019-12-04_annual_report_stats.docx", replace
putdocx clear

save "`datapath'\version02\3-output\2008_2013_2014_summstats" ,replace
restore

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
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, halign(center)
putdocx text ("Table 10. Top 10 Cancer Mortality Statistics for BNR-Cancer, 2015 (Population=276,633)"), bold font(Helvetica,10,"blue")
putdocx textblock begin
Date Prepared: 04-Dec-2019. 
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
putdocx table tbl1 = data(cancer_site year number percentage asmr ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)
putdocx save "`datapath'\version02\3-output\2019-12-04_annual_report_stats.docx", append
putdocx clear

save "`datapath'\version02\3-output\2008_2013_2014_2015_summstats" ,replace
restore


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
(1) Dataset: Excludes ineligible case definition, non-residents, non-malignant tumours, IARC non-reportable MPs; cancer dataset used: "`datapath'\version02\3-output\2008_2013_2014_cancer_nonsurvival")
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
(6) Population text files (BSS): saved in: "`datapath'\version02\2-working\BSS_population by sex_yyyy"
putdocx textblock end
putdocx textblock begin
(7) Population text files (WPP): saved in: "`datapath'\version02\2-working\WPP_population by sex_yyyy"
putdocx textblock end
putdocx textblock begin
(8) Population files (BSS): emailed to JCampbell from BSS' Socio-and-Demographic Statistics Division by Statistical Assistant on 29-Nov-2019.
putdocx textblock end
putdocx textblock begin
(9) Population files (WPP): generated from "https://population.un.org/wpp/Download/Standard/Population/" on 27-Nov-2019.
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
