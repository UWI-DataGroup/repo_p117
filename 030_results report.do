cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          030_results report.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      27-JAN-2022
    // 	date last modified      15-FEB-2022
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
**  2018 STAGING PROFILE **
***************************
** Load the 2018 staging dataset
use "`datapath'\version08\3-output\2018_colorectal_naaccr_nonsurvival", clear

preserve
				****************************
				*	   MS WORD REPORT      *
				*       2018 STAGING       *
				****************************
putdocx clear
putdocx begin, footer(foot1)
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER Staging Report: 2018 COLORECTAL"), bold
putdocx textblock begin
Date Prepared: 15-FEB-2022. 
Prepared by: JC using Stata & Redcap data release date: 2022-02-15_KWG CR5db XML backup. 
Generated using Dofile: 007_prep cr5db.do & 030_results report.do of data_p117 version08
putdocx textblock end
putdocx paragraph, halign(center)
putdocx text ("Methods"), bold
putdocx textblock begin
(1) Table 1. 2018 Colorectal TNM Anatomical Stage: Includes standardized case definition, i.e. excludes IARC flag, ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs; Excludes non-2018 cases and all sites except colorectal (C18-C20) (dataset used: "`datapath'\version08\3-output\2018_colorectal_naaccr_nonsurvival")
putdocx textblock end
putdocx textblock begin
(2) Table 2. 2018 Colorectal Essential TNM Anatomical Stage: Includes standardized case definition, i.e. excludes IARC flag, ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs; Excludes non-2018 cases and all sites except colorectal (C18-C20) (dataset used: "`datapath'\version08\3-output\2018_colorectal_naaccr_nonsurvival")
putdocx textblock end
putdocx textblock begin
(3) Table 3. 2018 Colorectal Summary Stage: Includes standardized case definition, i.e. excludes IARC flag, ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs; Excludes non-2018 cases and all sites except colorectal (C18-C20) (dataset used: "`datapath'\version08\3-output\2018_colorectal_naaccr_nonsurvival")
putdocx textblock end
putdocx textblock begin
(4a-4d) Table 4a-4d. 2018 Colorectal Time Between Incidence and Last Contact by TNM Anatomical Stage: Includes standardized case definition, i.e. excludes IARC flag, ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs; Excludes non-2018 cases and all sites except colorectal (C18-C20) (dataset used: "`datapath'\version08\3-output\2018_colorectal_naaccr_nonsurvival"); 
Uses Stata user-written command called 'tab2docx' to mimic Stata results when creating a 2-way table using Stata's table command.
putdocx textblock end
putdocx textblock begin
(5a-5d)  Table 5a-5d. 2018 Colorectal Time Between Incidence and Last Contact by Essential TNM Anatomical Stage: Includes standardized case definition, i.e. excludes IARC flag, ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs; Excludes non-2018 cases and all sites except colorectal (C18-C20) (dataset used: "`datapath'\version08\3-output\2018_colorectal_naaccr_nonsurvival"); 
Uses Stata user-written command called 'tab2docx' to mimic Stata results when creating a 2-way table using Stata's table command.
putdocx textblock end
putdocx textblock begin
(6a-6d) Table 6a-6d. 2018 Colorectal Time Between Incidence and Death by TNM Anatomical Stage: Includes standardized case definition, i.e. excludes IARC flag, ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs; Excludes non-2018 cases and all sites except colorectal (C18-C20) (dataset used: "`datapath'\version08\3-output\2018_colorectal_naaccr_nonsurvival"); 
Uses Stata user-written command called 'tab2docx' to mimic Stata results when creating a 2-way table using Stata's table command.
putdocx textblock end
putdocx textblock begin
(7a-7d)  Table 7a-7d. 2018 Colorectal Time Between Incidence and Death by Essential TNM Anatomical Stage: Includes standardized case definition, i.e. excludes IARC flag, ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs; Excludes non-2018 cases and all sites except colorectal (C18-C20) (dataset used: "`datapath'\version08\3-output\2018_colorectal_naaccr_nonsurvival"); 
Uses Stata user-written command called 'tab2docx' to mimic Stata results when creating a 2-way table using Stata's table command.
putdocx textblock end
putdocx textblock begin
(8) Table 8. 2018 Colorectal Basis of Diagnosis: Includes standardized case definition, i.e. excludes IARC flag, ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs; Excludes non-2018 cases and all sites except colorectal (C18-C20) (dataset used: "`datapath'\version08\3-output\2018_colorectal_naaccr_nonsurvival")
putdocx textblock end
putdocx textblock begin
(9a-9b) Table 9a-9b. 2018 Colorectal Summary Stage by Basis of Diagnosis: Includes standardized case definition, i.e. excludes IARC flag, ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs; Excludes non-2018 cases and all sites except colorectal (C18-C20) (dataset used: "`datapath'\version08\3-output\2018_colorectal_naaccr_nonsurvival"); 
Uses Stata user-written command called 'tab2docx' to mimic Stata results when creating a 2-way table using Stata's table command.
putdocx textblock end
putdocx textblock begin
(10) Table 10. 2018 Colorectal Notes Seen: Includes standardized case definition, i.e. excludes IARC flag, ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs; Excludes non-2018 cases and all sites except colorectal (C18-C20) (dataset used: "`datapath'\version08\3-output\2018_colorectal_naaccr_nonsurvival"); Used CanReg5 variables notesseen + comments to search for cases where the notes were seen by the DA.
putdocx textblock end

putdocx pagebreak
putdocx paragraph, halign(center)
putdocx text ("Table 1. TNM Anatomical Stage"), bold font(Helvetica,10,"blue")
capture tab2docx tnmantstage
putdocx paragraph, halign(center)
putdocx text ("Table 2. Essential TNM Anatomical Stage"), bold font(Helvetica,10,"blue")
capture tab2docx etnmantstage
putdocx paragraph, halign(center)
putdocx text ("Table 3. SEER Summary Stage"), bold font(Helvetica,10,"blue")
capture tab2docx staging
putdocx paragraph, halign(center)
putdocx text ("Table 4a. Time Between Incidence and Last Contact by TNM Stage I"), bold font(Helvetica,10,"blue")
capture tab2docx time_alive if tnmantstage==1
putdocx paragraph, halign(center)
putdocx text ("Table 4b. Time Between Incidence and Last Contact by TNM Stage II"), bold font(Helvetica,10,"blue")
capture tab2docx time_alive if tnmantstage==2
putdocx paragraph, halign(center)
putdocx text ("Table 4c. Time Between Incidence and Last Contact by TNM Stage III"), bold font(Helvetica,10,"blue")
capture tab2docx time_alive if tnmantstage==3
putdocx pagebreak
putdocx paragraph, halign(center)
putdocx text ("Table 4d. Time Between Incidence and Last Contact by TNM Stage IV"), bold font(Helvetica,10,"blue")
capture tab2docx time_alive if tnmantstage==4
putdocx paragraph, halign(center)
putdocx text ("Table 5a. Time Between Incidence and Last Contact by Essential TNM Stage I"), bold font(Helvetica,10,"blue")
capture tab2docx time_alive if etnmantstage==1
putdocx paragraph, halign(center)
putdocx text ("Table 5b. Time Between Incidence and Last Contact by Essential TNM Stage II"), bold font(Helvetica,10,"blue")
capture tab2docx time_alive if etnmantstage==2
putdocx paragraph, halign(center)
putdocx text ("Table 5c. Time Between Incidence and Last Contact by Essential TNM Stage III"), bold font(Helvetica,10,"blue")
capture tab2docx time_alive if etnmantstage==3
putdocx paragraph, halign(center)
putdocx text ("Table 5d. Time Between Incidence and Last Contact by Essential TNM Stage IV"), bold font(Helvetica,10,"blue")
capture tab2docx time_alive if etnmantstage==4
putdocx paragraph, halign(center)
putdocx text ("Table 6a. Time Between Incidence and Death by TNM Stage I"), bold font(Helvetica,10,"blue")
capture tab2docx time_dead if tnmantstage==1
putdocx paragraph, halign(center)
putdocx text ("Table 6b. Time Between Incidence and Death by TNM Stage II"), bold font(Helvetica,10,"blue")
capture tab2docx time_dead if tnmantstage==2
putdocx paragraph, halign(center)
putdocx text ("Table 6c. Time Between Incidence and Death by TNM Stage III"), bold font(Helvetica,10,"blue")
capture tab2docx time_dead if tnmantstage==3
putdocx paragraph, halign(center)
putdocx text ("Table 6d. Time Between Incidence and Death by TNM Stage IV"), bold font(Helvetica,10,"blue")
capture tab2docx time_dead if tnmantstage==4
putdocx paragraph, halign(center)
putdocx text ("Table 7a. Time Between Incidence and Death by Essential TNM Stage I"), bold font(Helvetica,10,"blue")
capture tab2docx time_dead if etnmantstage==1
putdocx paragraph, halign(center)
putdocx text ("Table 7b. Time Between Incidence and Death by Essential TNM Stage II"), bold font(Helvetica,10,"blue")
capture tab2docx time_dead if etnmantstage==2
putdocx paragraph, halign(center)
putdocx text ("Table 7c. Time Between Incidence and Death by Essential TNM Stage III"), bold font(Helvetica,10,"blue")
capture tab2docx time_dead if etnmantstage==3
putdocx paragraph, halign(center)
putdocx text ("Table 7d. Time Between Incidence and Death by Essential TNM Stage IV"), bold font(Helvetica,10,"blue")
capture tab2docx time_dead if etnmantstage==4
putdocx pagebreak
putdocx paragraph, halign(center)
putdocx text ("Table 8. Basis of Diagnosis"), bold font(Helvetica,10,"blue")
capture tab2docx basis
putdocx paragraph, halign(center)
putdocx text ("Table 9a. SEER Summary Stage by Clinical BOD"), bold font(Helvetica,10,"blue")
capture tab2docx staging if basis==1
putdocx paragraph, halign(center)
putdocx text ("Table 9b. SEER Summary Stage by Histology of Primary BOD"), bold font(Helvetica,10,"blue")
capture tab2docx staging if basis==7
putdocx paragraph
putdocx textblock begin
Note: While 2013 had a separate Casefinding database where the NotesSeen field was regularly updated; 2018 used CanReg5 as the Casefinding +Abstracting database and the NotesSeen field was not regularly updated.
putdocx textblock end
putdocx paragraph, halign(center)
putdocx text ("Table 10. Notes Seen Table"), bold font(Helvetica,10,"blue")
capture tab2docx notesseen

putdocx pagebreak
putdocx paragraph, halign(center)
putdocx text ("Note 1. The process of cancer staging in a Caribbean registry (JC)"), bold font(Helvetica,10,"blue")
putdocx textblock begin
A short definition for staging is "the grouping of cases into broad categories based on extent of disease." (https://training.seer.cancer.gov/staging/intro/)
putdocx textblock end
putdocx textblock begin
To stage a case, registry staff needs access to patient records, such as physician notes and examinations, lab tests, imaging tests, surgical findings.
putdocx textblock end
putdocx textblock begin
Below describe some difficulties a Caribbean registry faces when trying to staging their cases in a timely manner:
putdocx textblock end
putdocx textblock begin
•	Paper-based records + paper-based record management systems;
putdocx textblock end
putdocx textblock begin
•	Person (individual) based processes for record management;
putdocx textblock end
putdocx textblock begin
•	"Shopping around" by patients + poor referral letter correspondence between physicians;
putdocx textblock end
putdocx textblock begin
•	Lack of permission to access electronic hospital information system.
putdocx textblock end
putdocx textblock begin
If registry staff cannot stage and attempt to use the stage in the records, they at times encounter some of the below difficulties:
putdocx textblock end
putdocx textblock begin
•	Unstaged physician (clinical) records;
putdocx textblock end
putdocx textblock begin
•	Unstaged pathology reports.
putdocx textblock end
putdocx save "`datapath'\version08\3-output\2022-02-15_research_stage_stats_2018V03.docx", replace
putdocx clear
restore

clear


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
putdocx text ("CANCER Staging Report: 2013 COLORECTAL"), bold
putdocx textblock begin
Date Prepared: 15-FEB-2022. 
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
(2a-2j) Table 2a-2j. 2013 Staging by EACH Basis of Diagnosis Totals: Includes standardized case definition, i.e. includes unk residents, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version08\1-input\2013_2014_2015_cancer_nonsurvival"); 
Excludes non-2013 cases and all sites except colorectal (C18-C20) - dataset used: "`datapath'\version08\2-working\stagingbasis_2013"); 
Uses Stata user-written command called 'tab2docx' to mimic Stata results when creating a 2-way table using Stata's table command; 
Dofile: 005_prep stata.do
putdocx textblock end
putdocx textblock begin
(3) Table 3. 2013-2015 Basis of Diagnosis Totals (ALL SITES): Includes standardized case definition, i.e. includes unk residents, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version08\1-input\2013_2014_2015_cancer_nonsurvival"); 
Includes all sites - dataset used: "`datapath'\version08\2-working\basis_allsites_2013-2015"); 
Dofile: 005_prep stata.do
putdocx textblock end
putdocx textblock begin
(3a-3c) Table 3a-3c. 2013-2015 Basis of Diagnosis Totals (ALL SITES by YEAR): Includes standardized case definition, i.e. includes unk residents, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version08\1-input\2013_2014_2015_cancer_nonsurvival"); 
Includes all sites - dataset used: "`datapath'\version08\2-working\basis_allsites_2013-2015"); 
Uses Stata user-written command called 'tab2docx' to mimic Stata results when creating a 2-way table using Stata's table command; 
Dofile: 005_prep stata.do
putdocx textblock end
putdocx textblock begin
(4) Table 4. 2013-2015 Basis of Diagnosis Totals (COLORECTAL): Includes standardized case definition, i.e. includes unk residents, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version08\1-input\2013_2014_2015_cancer_nonsurvival"); 
Excludes all sites except colorectal (C18-C20) - dataset used: "`datapath'\version08\2-working\basis_colorectal_2013-2015"); 
Dofile: 005_prep stata.do
putdocx textblock end
putdocx textblock begin
(4a-4c) Table 4a-4c. 2013-2015 Basis of Diagnosis Totals (COLORECTAL by YEAR): Includes standardized case definition, i.e. includes unk residents, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version08\1-input\2013_2014_2015_cancer_nonsurvival"); 
Excludes all sites except colorectal (C18-C20) - dataset used: "`datapath'\version08\2-working\basis_colorectal_2013-2015"); 
Uses Stata user-written command called 'tab2docx' to mimic Stata results when creating a 2-way table using Stata's table command; 
Dofile: 005_prep stata.do
putdocx textblock end
putdocx textblock begin
(5)  Table 5. 2013 Staging Pathology Report Totals: Data from CaseFinding MasterDb (dataset used: "`datapath'\version08\1-input\20220127tblCaseFinding_2009.xlsx"); 
Excludes non-2013 cases and all sites except colorectal (C18-C20) - dataset used: "`datapath'\version08\2-working\pathrpts _2013"); 
Dofile: 006_prep mdb.do
putdocx textblock end
putdocx textblock begin
(6) Table 6. 2013 Colorectal Notes Seen: Includes standardized case definition, i.e. excludes IARC flag, ineligible case definition, unk residents, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs; Excludes non-2018 cases and all sites except colorectal (C18-C20) (dataset used: "`datapath'\version08\3-output\2013_colorectal_notesseen"); Used MasterDb variable NotesSeen and CanReg5 variables notesseen + comments to search for cases where the notes were seen by the DA.
putdocx textblock end

putdocx pagebreak
putdocx paragraph, halign(center)
putdocx text ("Table 1. SEER Summary Staging, 2013 (ICD-10: C18-C20)"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx table tbl1 = data("year staging count percentage"), varnames halign(center)
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
//putdocx table basis dxyr = table, title("Table 1. SEER Summary Staging, 2013 (ICD-10: C18-C20)")
putdocx save "`datapath'\version08\3-output\2022-02-15_research_stage_stats_2013V03.docx", replace
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
//putdocx pagebreak
putdocx paragraph, halign(center)
putdocx text ("Table 2. SEER Summary Staging by Basis of Diagnosis, 2013 (ICD-10: C18-C20)"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx table tbl1 = data(year staging basis count), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx save "`datapath'\version08\3-output\2022-02-15_research_stage_stats_2013V03.docx", append
putdocx clear
restore

clear


use "`datapath'\version08\3-output\2013_colorectal_nonsurvival", clear

preserve

putdocx clear
putdocx begin
putdocx pagebreak

putdocx paragraph, halign(center)
putdocx text ("Table 2a. SEER Summary Staging by DCO, 2013 (ICD-10: C18-C20)"), bold font(Helvetica,8,"blue")
capture tab2docx staging if basis==0
putdocx paragraph, halign(center)
putdocx text ("Table 2b. SEER Summary Staging by Clinical, 2013 (ICD-10: C18-C20)"), bold font(Helvetica,8,"blue")
capture tab2docx staging if basis==1
putdocx paragraph, halign(center)
putdocx text ("Table 2c. SEER Summary Staging by Clinical Investigation, 2013 (ICD-10: C18-C20)"), bold font(Helvetica,8,"blue")
capture tab2docx staging if basis==2
putdocx paragraph, halign(center)
putdocx text ("Table 2d. SEER Summary Staging by Exploratory Sx/Autopsy, 2013 (ICD-10: C18-C20)"), bold font(Helvetica,8,"blue")
capture tab2docx staging if basis==3
putdocx paragraph, halign(center)
putdocx text ("Table 2e. SEER Summary Staging by Lab Test, 2013 (ICD-10: C18-C20)"), bold font(Helvetica,8,"blue")
capture tab2docx staging if basis==4
putdocx paragraph, halign(center)
putdocx text ("Table 2f. SEER Summary Staging by Cytology/Haematology, 2013 (ICD-10: C18-C20)"), bold font(Helvetica,8,"blue")
capture tab2docx staging if basis==5
putdocx paragraph, halign(center)
putdocx text ("Table 2g. SEER Summary Staging by Histology of Mets, 2013 (ICD-10: C18-C20)"), bold font(Helvetica,8,"blue")
capture tab2docx staging if basis==6
putdocx pagebreak
putdocx paragraph, halign(center)
putdocx text ("Table 2h. SEER Summary Staging by Histology of Primary, 2013 (ICD-10: C18-C20)"), bold font(Helvetica,8,"blue")
capture tab2docx staging if basis==7
putdocx paragraph, halign(center)
putdocx text ("Table 2i. SEER Summary Staging by Autopsy w/ Histology, 2013 (ICD-10: C18-C20)"), bold font(Helvetica,8,"blue")
capture tab2docx staging if basis==8
putdocx paragraph, halign(center)
putdocx text ("Table 2j. SEER Summary Staging by Unknown, 2013 (ICD-10: C18-C20)"), bold font(Helvetica,8,"blue")
capture tab2docx staging if basis==9
putdocx save "`datapath'\version08\3-output\2022-02-15_research_stage_stats_2013V03.docx", append
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
putdocx save "`datapath'\version08\3-output\2022-02-15_research_stage_stats_2013V03.docx", append
putdocx clear
restore

clear

use "`datapath'\version08\1-input\2013_2014_2015_cancer_nonsurvival", clear

preserve

putdocx clear
putdocx begin

putdocx paragraph, halign(center)
putdocx text ("Table 3a. Basis of Diagnosis, 2013 (ALL SITES)"), bold font(Helvetica,8,"blue")
tab2docx basis if dxyr==2013
putdocx paragraph, halign(center)
putdocx text ("Table 3b. Basis of Diagnosis, 2014 (ALL SITES)"), bold font(Helvetica,8,"blue")
tab2docx basis if dxyr==2014
putdocx paragraph, halign(center)
putdocx text ("Table 3c. Basis of Diagnosis, 2015 (ALL SITES)"), bold font(Helvetica,8,"blue")
tab2docx basis if dxyr==2015
putdocx save "`datapath'\version08\3-output\2022-02-15_research_stage_stats_2013V03.docx", append
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
putdocx save "`datapath'\version08\3-output\2022-02-15_research_stage_stats_2013V03.docx", append
putdocx clear
restore

clear


use "`datapath'\version08\3-output\2013-2015_colorectal_nonsurvival", clear

preserve

putdocx clear
putdocx begin
putdocx pagebreak

putdocx paragraph, halign(center)
putdocx text ("Table 4a. Basis of Diagnosis, 2013 (COLORECTAL)"), bold font(Helvetica,8,"blue")
tab2docx basis if dxyr==2013
putdocx paragraph, halign(center)
putdocx text ("Table 4b. Basis of Diagnosis, 2014 (COLORECTAL)"), bold font(Helvetica,8,"blue")
tab2docx basis if dxyr==2014
putdocx paragraph, halign(center)
putdocx text ("Table 4c. Basis of Diagnosis, 2015 (COLORECTAL)"), bold font(Helvetica,8,"blue")
tab2docx basis if dxyr==2015
putdocx save "`datapath'\version08\3-output\2022-02-15_research_stage_stats_2013V03.docx", append
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
//putdocx pagebreak
putdocx paragraph

// Create a paragraph
putdocx paragraph, halign(center)
putdocx text ("Table 5. Staging in Pathology Reports, 2013 (ICD-10: C18-C20)"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx textblock begin
Note: The pathology reports that are staged are usually only the surgical path reports and the total path reports represents both diagnostic and surgical reports.
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year tot_tnm tot_pathrpt percent_tnm), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx save "`datapath'\version08\3-output\2022-02-15_research_stage_stats_2013V03.docx", append
putdocx clear
restore

clear

clear

*********************
** 2013 Notes Seen **
*********************
use "`datapath'\version08\3-output\2013_colorectal_notesseen", clear

preserve

putdocx clear
putdocx begin
//putdocx pagebreak
putdocx paragraph
putdocx textblock begin
Note: There were some missed cases abstracted during the Stata cleaning process so the missing 7 in the below table from the total of 155 CRCs most likely had NotesSeen=No.
putdocx textblock end

putdocx paragraph, halign(center)
putdocx text ("Table 10. Notes Seen Table"), bold font(Helvetica,10,"blue")
capture tab2docx notesseen if cr5id=="T1S1"
putdocx save "`datapath'\version08\3-output\2022-02-15_research_stage_stats_2013V03.docx", append
putdocx clear
restore

clear

