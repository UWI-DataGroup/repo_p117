cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          030_results report.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      27-JAN-2022
    // 	date last modified      27-JAN-2022
    //  algorithm task          Preparing 2013 + 2018 colorectal staging datasets for reporting
    //  status                  Completed
    //  objective               To have one dataset with report outputs for 2013 + 2018 data to compare staging for colorectal data.
    //  methods                 Use putdocx and Stata memory to produce tables and figures

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
    log using "`logpath'\030_results report.smcl", replace // error r(603)
** HEADER -----------------------------------------------------


***************************
**  2013 STAGING PROFILE **
***************************
** Load the 2013 staging dataset
use "`datapath'\version08\2-working\staging_2013", clear

preserve
				****************************
				*	   MS WORD REPORT      *
				*       2013 STAGING       *
				****************************
putdocx clear
putdocx begin, footer(foot1)
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER Staging Report: COLORECTAL"), bold
putdocx textblock begin
Date Prepared: 27-JAN-2022. 
Prepared by: JC using Stata & Redcap data release date: 21-May-2021.
Generated using Dofile: 005_prep stata.do & 030_results report.do of data_p117 version08
putdocx textblock end
putdocx paragraph, halign(center)
putdocx text ("Methods"), bold
putdocx textblock begin
(1) Table 1. 2013 Staging Totals: Includes standardized case definition, i.e. includes unk residents, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version08\1-input\2013_2014_2015_cancer_nonsurvival"); 
Excludes non-2013 cases and all sites except colorectal (C18-C20) - dataset used: "`datapath'\version08\2-working\staging_2013"); 
Dofile: 005_prep stata.do
putdocx textblock end
putdocx textblock begin
(2) Table 2. 2013 Staging by Basis of Diagnosis Totals: Includes standardized case definition, i.e. includes unk residents, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version08\1-input\2013_2014_2015_cancer_nonsurvival"); 
Excludes non-2013 cases and all sites except colorectal (C18-C20) - dataset used: "`datapath'\version08\2-working\stagingbasis_2013"); 
Dofile: 005_prep stata.do
putdocx textblock end
putdocx textblock begin
(3) Table 3. 2013-2015 Basis of Diagnosis Totals (ALL SITES): Includes standardized case definition, i.e. includes unk residents, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version08\1-input\2013_2014_2015_cancer_nonsurvival"); 
Includes all sites - dataset used: "`datapath'\version08\2-working\basis_allsites_2013-2015"); 
Dofile: 005_prep stata.do
putdocx textblock end
putdocx textblock begin
(4) Table 4. 2013-2015 Basis of Diagnosis Totals (COLORECTAL): Includes standardized case definition, i.e. includes unk residents, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version08\1-input\2013_2014_2015_cancer_nonsurvival"); 
Excludes all sites except colorectal (C18-C20) - dataset used: "`datapath'\version08\2-working\basis_colorectal_2013-2015"); 
Dofile: 005_prep stata.do
putdocx textblock end
putdocx textblock begin
(5)  Table 5. 2013 Staging Pathology Report Totals: Data from CaseFinding MasterDb (dataset used: "`datapath'\version08\1-input\20220127tblCaseFinding_2009.xlsx"); 
Excludes non-2013 cases and all sites except colorectal (C18-C20) - dataset used: "`datapath'\version08\2-working\pathrpts _2013"); 
Dofile: 006_prep mdb.do
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
putdocx paragraph, halign(center)
putdocx text ("Table 1. SEER Summary Staging, 2013 (ICD-10: C18-C20)"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx table tbl1 = data("year staging count percentage"), varnames halign(center)
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx save "`datapath'\version08\3-output\2022-01-27_research_stage_stats.docx", replace
putdocx clear
restore

clear


** Output for 2013 Staging by Basis of Diagnosis
preserve
use "`datapath'\version08\2-working\stagingbasis_2013", clear

				****************************
				*	   MS WORD REPORT      *
				* 	2013 STAGING X BASIS   *
				****************************

putdocx clear
putdocx begin

// Create a paragraph
putdocx pagebreak
putdocx paragraph, halign(center)
putdocx text ("Table 2. SEER Summary Staging by Basis of Diagnosis, 2013 (ICD-10: C18-C20)"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx table tbl1 = data(year staging basis count), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx save "`datapath'\version08\3-output\2022-01-27_research_stage_stats.docx", append
putdocx clear
restore

clear


** Output for 2013-2015 Basis of Diagnosis (ALL SITES)
preserve
use "`datapath'\version08\2-working\basis_allsites_2013-2015", clear

				****************************
				*	   MS WORD REPORT      *
				* 	2013-2015 BASIS OF DX  *
				****************************

putdocx clear
putdocx begin

// Create a paragraph
putdocx pagebreak
putdocx paragraph, halign(center)
putdocx text ("Table 3. Basis of Diagnosis, 2013-2015 (ALL SITES)"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx table tbl1 = data(basis dxyr count), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx save "`datapath'\version08\3-output\2022-01-27_research_stage_stats.docx", append
putdocx clear
restore

clear

** Output for 2013-2015 Basis of Diagnosis (COLORECTAL)
preserve
use "`datapath'\version08\2-working\basis_colorectal_2013-2015", clear

				****************************
				*	   MS WORD REPORT      *
				* 	2013-2015 BASIS OF DX  *
				****************************

putdocx clear
putdocx begin

// Create a paragraph
putdocx pagebreak
putdocx paragraph, halign(center)
putdocx text ("Table 4. Basis of Diagnosis, 2013-2015 (COLORECTAL)"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx table tbl1 = data(basis dxyr count), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx save "`datapath'\version08\3-output\2022-01-27_research_stage_stats.docx", append
putdocx clear
restore

clear


** Output for 2013 Staging in Pathology Reports
preserve
use "`datapath'\version08\2-working\pathrpts_2013", clear


				****************************
				*	   MS WORD REPORT      *
				* 	 2013 PATH REPORTS     *
				****************************

putdocx clear
putdocx begin

// Create a paragraph
//putdocx pagebreak
putdocx paragraph, halign(center)
putdocx text ("Table 5. Staging in Pathology Reports, 2013 (ICD-10: C18-C20)"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx table tbl1 = data(year tot_tnm tot_pathrpt percent_tnm), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx save "`datapath'\version08\3-output\2022-01-27_research_stage_stats.docx", append
putdocx clear
restore

clear